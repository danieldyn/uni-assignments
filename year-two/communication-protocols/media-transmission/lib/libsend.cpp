#include <pthread.h>
#include <cstdlib>
#include <map>
#include <cstdint>
#include "include/lib.h"
#include "include/utils.h"
#include "include/protocol.h"
#include <cassert>
#include <poll.h>
#include <sys/timerfd.h>
#include <string.h>
#include <unistd.h>

using namespace std;

std::map<int, struct connection *> cons;
struct pollfd data_fds[MAX_CONNECTIONS];
/* Used for timers per connection */
struct pollfd timer_fds[MAX_CONNECTIONS];
int fdmax = 0;
int sender_speed = 0;
int sender_delay = 0;
int sender_window_packets = 0;

extern pthread_mutex_t cons_lock;

int send_data(int conn_id, char *buffer, int len)
{
	// Find the connection in the map structure
	pthread_mutex_lock(&cons_lock);
	if (cons.find(conn_id) == cons.end()) {
		pthread_mutex_unlock(&cons_lock);
		return -1;
	}
	struct connection *con = cons[conn_id];
	pthread_mutex_unlock(&cons_lock);

	int total_sent = 0;
	while (total_sent < len) {
		// Try grabbing a slot in the window
		if (sem_trywait(&con->available_slots) != 0) {
			if (total_sent == 0)
				return -1;

			// Finish sending the other chunk
			sem_wait(&con->available_slots);
		}

		pthread_mutex_lock(&con->con_lock);

		uint16_t in_flight = (uint16_t)(con->next_seq - con->oldest_nack);
		if (in_flight >= con->remote_window || con->remote_window == 0) {
			pthread_mutex_unlock(&con->con_lock);
			sem_post(&con->available_slots); // Give up on the slot

			if (total_sent == 0)
				return -1;

			usleep(1000); // Allow other threads to run
			continue;
		}

		// Calculate the chunk size for the current packet
		int chunk_size = min(len - total_sent, MAX_DATA_SIZE);

		char segment[MAX_SEGMENT_SIZE];
		DataHdr *hdr = (DataHdr *) segment;
		hdr->protocol_id = POLI_PROTOCOL_ID;
		hdr->conn_id = con->conn_id;
		hdr->type = TYPE_DATA;
		hdr->seq_num = htons(con->next_seq);
		hdr->len = htons(chunk_size);
		memcpy(segment + sizeof(DataHdr), buffer + total_sent, chunk_size);

		// Buffer the packet in the send_window for potential retransmission
		int idx = con->next_seq % RING_BUFFER_SIZE;
		packet p;
		memcpy(p.data, buffer + total_sent, chunk_size);
		p.len = chunk_size;
		p.ack_or_recv = false;
		con->send_window[idx] = p;

		// Transmit the segment
		sendto(con->sockfd, segment, sizeof(DataHdr) + chunk_size, 0, (sockaddr *) &con->servaddr, sizeof(con->servaddr));

		con->next_seq++;

		pthread_mutex_unlock(&con->con_lock);

		total_sent += chunk_size;
	}

	return total_sent;
}

void retransmit_unacked(connection *con)
{
	if (con->remote_window == 0)
		return;

	uint16_t seq = con->oldest_nack; // Starting point for retransmission

	while (seq != con->next_seq) {
		int idx = seq % RING_BUFFER_SIZE;

		// Check if the slot actually contains a packet
		if (con->send_window[idx].has_value()) {
			packet pkt = con->send_window[idx].value();
			char segment[MAX_SEGMENT_SIZE];
			DataHdr *hdr = (DataHdr *) segment;

			hdr->protocol_id = POLI_PROTOCOL_ID;
			hdr->conn_id = con->conn_id;
			hdr->type = TYPE_DATA;
			hdr->seq_num = htons(seq);
			hdr->len = htons(pkt.len);
			memcpy(segment + sizeof(DataHdr), pkt.data, pkt.len);

			sendto(con->sockfd, segment, sizeof(DataHdr) + pkt.len, 0, (sockaddr *) &con->servaddr, sizeof(con->servaddr));
		}

		seq++; // Move to the next packet in flight
	}
}

void *sender_handler(void *arg)
{
	int res = 0;
	char buf[MAX_SEGMENT_SIZE];

	while (1) {
		pthread_mutex_lock(&cons_lock);
		bool empty_map = (cons.size() == 0);
		pthread_mutex_unlock(&cons_lock);

		if (empty_map) {
			usleep(1000); // Wait a bit for the creation of a connection
			continue;
		}

		int conn_id = -1;
		res = recv_message_or_timeout(buf, MAX_SEGMENT_SIZE, &conn_id);

		if (res == -14 || conn_id == -1) {
			usleep(1000); // Allow other threads to run
			continue;
		}

		pthread_mutex_lock(&cons_lock);
		connection *con = cons[conn_id];
		pthread_mutex_unlock(&cons_lock);

		if (res == -1) {
			// Retransmit using Selective Repeat ARQ
			pthread_mutex_lock(&con->con_lock);
			retransmit_unacked(con);
			pthread_mutex_unlock(&con->con_lock);
			continue;
		}

		if (res > 0 && conn_id != -1) {
			pthread_mutex_lock(&con->con_lock);

			/* Handle segment received from the receiver. We use this between locks
			as to not have synchronization issues with the send_data calls which are
			on the main thread */
			CtrlHdr *ctrl = (CtrlHdr *) buf;

			if (ctrl->protocol_id != POLI_PROTOCOL_ID || ctrl->type != TYPE_ACK) {
				pthread_mutex_unlock(&con->con_lock);
				continue;
			}

			uint16_t ack_seq = ntohs(ctrl->ack_num);
			con->remote_window = ntohs(ctrl->recv_window); // Flow control update on remote_window field

			// Detect duplicate ACKs for potential fast retransmit
			if (ack_seq == con->last_ack_num) {
				con->dup_ack_count++;
				if (con->dup_ack_count == 3 && con->remote_window > 0) {
					// Fast retransmit triggered on third consecutive duplicate
					int idx = con->oldest_nack % RING_BUFFER_SIZE;
					if (con->send_window[idx].has_value() && !con->send_window[idx].value().ack_or_recv) {
						packet pkt = con->send_window[idx].value();
						char segment[MAX_SEGMENT_SIZE];
						DataHdr *hdr = (DataHdr *) segment;

						hdr->protocol_id = POLI_PROTOCOL_ID;
						hdr->conn_id = con->conn_id;
						hdr->type = TYPE_DATA;
						hdr->seq_num = htons(con->oldest_nack);
						hdr->len = htons(pkt.len);
						memcpy(segment + sizeof(DataHdr), pkt.data, pkt.len);

						sendto(con->sockfd, segment, sizeof(DataHdr) + pkt.len, 0, (sockaddr *) &con->servaddr, sizeof(con->servaddr));
					}
				}
			} else {
				con->last_ack_num  = ack_seq;
				con->dup_ack_count = 0; // Clear duplicate history
			}

			// Slide the window to allow new slots to be filled
			int freed_slots = (int16_t)(ack_seq - con->oldest_nack);
			if (freed_slots > 0) {
				while ((int16_t)(ack_seq - con->oldest_nack) > 0) {
					con->send_window[con->oldest_nack % RING_BUFFER_SIZE].reset();
					con->oldest_nack++;
				}
				pthread_mutex_unlock(&con->con_lock);

				// Send the notification for free slots
				for (int i = 0; i < freed_slots; i++)
					sem_post(&con->available_slots);
			} else {
				pthread_mutex_unlock(&con->con_lock);
			}
		}
	}
}

int setup_connection(uint32_t ip, uint16_t port)
{
	/* Implement the sender part of the Three Way Handshake. Blocks
	until the connection is established */

	connection *con = new connection();
	int ret, conn_id = 0;
	con->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	assert(con->sockfd >= 0);

	// Prepare the server address using the initial port (8032)
	sockaddr_in serv_addr;
	memset(&serv_addr, 0, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = ip;
	serv_addr.sin_port = port;
	bool done = false;

	CtrlHdr syn;
	memset(&syn, 0, sizeof(syn));
	syn.protocol_id = POLI_PROTOCOL_ID;
	syn.type = TYPE_SYN;

	/* We will send the SYN on 8031. Then we will receive a SYN-ACK with the connection
	 * port. We can use con->sockfd for both cases, but we will need to update server_addr
	 * with the port received via SYN-ACK */
	while (!done) {
		// Send initial SYN
		sendto(con->sockfd, &syn, sizeof(syn), 0, (sockaddr *) &serv_addr, sizeof(serv_addr));

		// This can be used to set a timer on a socket
		struct timeval tv;
		tv.tv_sec = 0;
		tv.tv_usec = 50000;
		ret = setsockopt(con->sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
		assert(ret >= 0);

		char buf[sizeof(CtrlHdr) + sizeof(uint16_t)];
		sockaddr_in recv_addr;
		socklen_t recv_len = sizeof(recv_addr);
		int bytes_recv = recvfrom(con->sockfd, buf, sizeof(buf), 0, (sockaddr *) &recv_addr, &recv_len);
		if (bytes_recv < 0)
			continue;

		CtrlHdr *syn_ack = (CtrlHdr *) buf;
		if (syn_ack->protocol_id != POLI_PROTOCOL_ID || syn_ack->type != TYPE_SYN_ACK)
			continue;

		uint16_t *port_payload = (uint16_t *)(buf + sizeof(CtrlHdr));
		uint16_t new_port = ntohs(*port_payload);
		conn_id = syn_ack->conn_id;
		int recv_win = ntohs(syn_ack->recv_window);
		serv_addr.sin_port = htons(new_port);

		// Send final ACK to the new data port
		CtrlHdr ack;
		memset(&ack, 0, sizeof(ack));
		ack.protocol_id = POLI_PROTOCOL_ID;
		ack.type = TYPE_ACK;
		ack.conn_id = conn_id;
		sendto(con->sockfd, &ack, sizeof(ack), 0, (sockaddr *) &serv_addr, sizeof(serv_addr));

		tv.tv_usec = 0;
		ret = setsockopt(con->sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
		assert(ret >= 0);

		// Update connection metadata
		con->servaddr = serv_addr;
		con->conn_id = conn_id;
		con->max_window_seq = recv_win;
		con->remote_window = recv_win;
		con->expected_seq = 0;
		con->next_seq = 0;
		con->oldest_nack = 0;
		con->dup_ack_count = 0;
		con->last_ack_num = 0;
		con->send_window.resize(RING_BUFFER_SIZE);
		con->recv_window.resize(RING_BUFFER_SIZE);
		con->recv_buffered_count = 0;

		ret = sem_init(&con->available_slots, 0, sender_window_packets);
		assert(ret == 0);
		done = true;

	}

	// Initialise lock and insert the new connection in the map
	pthread_mutex_init(&con->con_lock, NULL);
	pthread_mutex_lock(&cons_lock);
	cons.insert({conn_id, con});

	/* Since we can have multiple connection, we want to know if data is available
	   on the socket used by a given connection. We use POLL for this */
	data_fds[fdmax].fd = con->sockfd;
	data_fds[fdmax].events = POLLIN;

	/* This creates a timer and sets it to trigger every 1 sec. We use this
	   to know if a timeout has happend on our connection */
	timer_fds[fdmax].fd = timerfd_create(CLOCK_REALTIME,  0);
	timer_fds[fdmax].events = POLLIN;
	struct itimerspec spec;
	spec.it_value.tv_sec = 0;
	spec.it_value.tv_nsec = 15000000; // 15 ms
	spec.it_interval.tv_sec = 0;
	spec.it_interval.tv_nsec = 15000000;
	timerfd_settime(timer_fds[fdmax].fd, 0, &spec, NULL);
	fdmax++;

	pthread_mutex_unlock(&cons_lock);

	DEBUG_PRINT("Connection established!");

	return conn_id;
}

void init_sender(int speed, int delay)
{
	pthread_t thread1;

	sender_speed = speed;
	sender_delay = delay;

	// BDP (bytes) = (speed * 1,000,000 / 8) * (2 * delay / 1,000) = speed * delay * 250
	int bdp_bytes = speed * delay * 250 * 4;
	sender_window_packets = bdp_bytes / MAX_DATA_SIZE;
	if (sender_window_packets <= 0)
		sender_window_packets = 1; // Sanity check

	/* Create a thread that will*/
	int ret = pthread_create( &thread1, NULL, sender_handler, NULL);
	assert(ret == 0);
}
