#include <pthread.h>
#include <cstdlib>
#include <map>
#include <cstdint>
#include "include/lib.h"
#include "include/utils.h"
#include "include/protocol.h"
#include <poll.h>
#include <cassert>
#include <sys/timerfd.h>
#include <string.h>
#include <unistd.h>

#define SERVER_PORT 8032

using namespace std;

std::map<int, struct connection *> cons;
struct pollfd data_fds[MAX_CONNECTIONS];
/* Used for timers per connection */
struct pollfd timer_fds[MAX_CONNECTIONS];
int fdmax = 0;
int listenfd = -1;
int max_recv_window_packets = 80;

extern pthread_mutex_t cons_lock;

int recv_data(int conn_id, char *buffer, int len)
{
	pthread_mutex_lock(&cons_lock);
	connection *con = cons[conn_id];
	pthread_mutex_unlock(&cons_lock);

	// Wait for the next in-order packet is posted
	sem_wait(&con->expected_packet);

	pthread_mutex_lock(&con->con_lock);

	/* We will write code here as to not have sync problems with recv_handler */

	// Obtain expected packet data, then remove it from its slot
	uint16_t seq = con->expected_seq_for_app;
	int idx = seq % RING_BUFFER_SIZE;
	packet p = con->recv_window[idx].value();
	int size = min((int)p.len, len);
	memcpy(buffer, p.data, size);
	con->recv_window[idx].reset();
	con->recv_buffered_count--;
	con->expected_seq_for_app++;

	uint16_t free_slots = (uint16_t)(max_recv_window_packets - con->recv_buffered_count);
	CtrlHdr ack;
	ack.protocol_id = POLI_PROTOCOL_ID;
	ack.conn_id = con->conn_id;
	ack.type = TYPE_ACK;
	ack.ack_num = htons(con->expected_seq); // Cumulative ACK
	ack.recv_window = htons(free_slots);

	sendto(con->sockfd, &ack, sizeof(ack), 0, (sockaddr *) &con->servaddr, sizeof(con->servaddr));

	pthread_mutex_unlock(&cons[conn_id]->con_lock);

	return size;
}

void *receiver_handler(void *arg)
{

	char segment[MAX_SEGMENT_SIZE];
	int res;
	DEBUG_PRINT("Starting recviver handler\n");

	while (1) {
		int conn_id = -1;
		res = recv_message_or_timeout(segment, MAX_SEGMENT_SIZE, &conn_id);

		if (res <= 0 || conn_id == -1) {
			// Nothing to poll or timeout
			usleep(1000);
			continue;
		}

		pthread_mutex_lock(&cons_lock);
		connection *con = cons[conn_id];
		pthread_mutex_unlock(&cons_lock);

		pthread_mutex_lock(&con->con_lock);

		/* Handle segment received from the sender. We use this between locks
		as to not have synchronization issues with the recv_data calls which are
		on the main thread */
		DataHdr *hdr = (DataHdr *) segment;

		// Ignore non-data segments
		if (hdr->type != TYPE_DATA) {
			pthread_mutex_unlock(&con->con_lock);
			continue;
		}

		uint16_t seq = ntohs(hdr->seq_num);
		uint16_t data_len = ntohs(hdr->len);

		// Allowed interval: [expectd_seq, expected_seq + windiw)
		uint16_t offset = (uint16_t)(seq - con->expected_seq);
		if (offset < (uint16_t)con->max_window_seq) {
			int idx = seq % RING_BUFFER_SIZE;

			// Check if the slot is empty at that index
			if (!con->recv_window[idx].has_value()) {
				packet p;
				memcpy(p.data, segment + sizeof(DataHdr), data_len);
				p.len = data_len;
				p.ack_or_recv = true;
				con->recv_window[idx] = p;
				con->recv_buffered_count++;
			}
		}

		// Slide the window
		while (con->recv_window[con->expected_seq % RING_BUFFER_SIZE].has_value()) {
			con->expected_seq++;
			sem_post(&con->expected_packet);
		}

		// Determine the window that will be advertised in the ACK
		uint16_t free_slots = (uint16_t)(max_recv_window_packets - con->recv_buffered_count);
		CtrlHdr ack;
		ack.protocol_id = POLI_PROTOCOL_ID;
		ack.conn_id = con->conn_id;
		ack.type = TYPE_ACK;
		ack.ack_num = htons(con->expected_seq); // Cumulative ACK
		ack.recv_window = htons(free_slots);

		sendto(con->sockfd, &ack, sizeof(ack), 0, (sockaddr *) &con->servaddr, sizeof(con->servaddr));

		pthread_mutex_unlock(&con->con_lock);
	}
}

int wait4connect(uint32_t ip, uint16_t port)
{
	/* Implement the Three Way Handshake on the receiver part. This blocks
	 * until a connection is established. */

	connection *con = new connection();
	int ret, conn_id = (int)cons.size();
	sockaddr_in client_addr;
	socklen_t clen = sizeof(client_addr);
	CtrlHdr req;
	bool done = false;

	while (!done) {
		int bytes_recv = recvfrom(listenfd, &req, sizeof(req), 0, (sockaddr *) &client_addr, &clen);
		if (bytes_recv < 0 || req.type != TYPE_SYN)
			continue;

		/* Receive SYN on the connection socket. Create a new socket and bind it to
	 	* the chosen port. Send the data port number via SYN-ACK to the client */
		con->sockfd = socket(AF_INET, SOCK_DGRAM, 0);
		assert(con->sockfd >= 0);

		sockaddr_in rand_addr;
		int slen = sizeof(rand_addr);
		memset(&rand_addr, 0, clen);
		rand_addr.sin_family = AF_INET;
		rand_addr.sin_addr.s_addr = ip;
		rand_addr.sin_port = 0;

		// Let the kernel decide a random port for the connection
		ret = bind(con->sockfd, (sockaddr *) &rand_addr, slen);
		assert(ret >= 0);

		socklen_t alen = sizeof(rand_addr);
		ret = getsockname(con->sockfd, (sockaddr*) &rand_addr, &alen);
		assert(ret >= 0);
		uint16_t new_port = ntohs(rand_addr.sin_port);

		// Send SYN-ACK with random port as payload
		char syn_ack[sizeof(CtrlHdr) + sizeof(uint16_t)];
		CtrlHdr *ack_hdr = (CtrlHdr *) syn_ack;
		uint16_t *payload = (uint16_t *)(syn_ack + sizeof(CtrlHdr));
		ack_hdr->protocol_id = POLI_PROTOCOL_ID;
		ack_hdr->type = TYPE_SYN_ACK;
		ack_hdr->conn_id = conn_id;
		ack_hdr->recv_window = htons(max_recv_window_packets);
		ack_hdr->ack_num = 0;
		*payload = htons(new_port);


		// Send SYN-ACK back to the client
		sendto(listenfd, syn_ack, sizeof(syn_ack), 0, (sockaddr *) &client_addr, clen);

		/* This can be used to set a timer on a socket, useful once we received a
		* SYN. You may want to disable by setting the time to 0 (tv_sec = 0,
		* tv_usec = 0)
		*/
		timeval tv;
		tv.tv_sec = 0;
		tv.tv_usec = 50000;
		ret = setsockopt(con->sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
		assert(ret >= 0);

		// Wait for final ACK or DATA
		bool ack_done = false;
		while (!ack_done) {
			CtrlHdr ack;
			// Take a peek at the packet
			bytes_recv = recvfrom(con->sockfd, &ack, sizeof(ack), MSG_PEEK, NULL, NULL);

			if (bytes_recv < 0) {
				// Timeout, receiver needs to resend SYN-ACK
				sendto(listenfd, syn_ack, sizeof(syn_ack), 0, (sockaddr *) &client_addr, clen);
				continue;
			}

			if (ack.type == TYPE_ACK) {
				recvfrom(con->sockfd, &ack, sizeof(ack), 0, NULL, NULL);
				ack_done = true; // Final ACK received
			} else if (ack.type == TYPE_DATA) {
				// Final ACK was lost, but the client now sent data
				ack_done = true;
			} else {
				// Ignore anything else
				recvfrom(con->sockfd, &ack, sizeof(ack), 0, NULL, NULL);
			}
		}

		// Connection successfully set up, initialise the data
		tv.tv_usec = 0;
		ret = setsockopt(con->sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
		assert(ret >= 0);

		con->servaddr = client_addr;
		con->conn_id = conn_id;
		con->max_window_seq = max_recv_window_packets;
		con->next_seq = 0;
		con->oldest_nack = 0;
		con->expected_seq = 0;
		con->expected_seq_for_app = 0;
		con->dup_ack_count = 0;
		con->last_ack_num = 0;
		con->send_window.resize(RING_BUFFER_SIZE);
		con->recv_window.resize(RING_BUFFER_SIZE);
		con->recv_buffered_count = 0;

		ret = sem_init(&con->expected_packet, 0, 0);
		assert(ret == 0);
		done = true;
	}

	// Initialise lock and insert the new connection in the map
	pthread_mutex_init(&con->con_lock, NULL);
	pthread_mutex_lock(&cons_lock);
	cons.insert({conn_id, con});

	/* Since we can have multiple connections, we want to know if data is available
	   on the socket used by a given connection. We use POLL for this */
	data_fds[fdmax].fd = con->sockfd;
	data_fds[fdmax].events = POLLIN;

	/* This creates a timer and sets it to trigger every 1 sec. We use this
	   to know if a timeout has happend on a connection */
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

void init_receiver(int recv_buffer_bytes)
{
	pthread_t thread1;
	int ret;
	sockaddr_in serv_addr;
	socklen_t slen = sizeof(serv_addr);
	const int enable = 1;

	max_recv_window_packets = recv_buffer_bytes / MAX_DATA_SIZE;
	if (max_recv_window_packets <= 0)
		max_recv_window_packets = 1; // Sanity check

	/* Create the connection socket and bind it to 8031 */
	listenfd = socket(AF_INET, SOCK_DGRAM, 0);
	assert(listenfd >= 0);

	ret = setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));
	assert(ret >= 0);

	memset(&serv_addr, 0, slen);
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(SERVER_PORT);
	serv_addr.sin_addr.s_addr = INADDR_ANY;

	ret = bind(listenfd, (sockaddr *) &serv_addr, slen);
	assert(ret >= 0);

	ret = pthread_create(&thread1, NULL, receiver_handler, NULL);
	assert(ret == 0);
}
