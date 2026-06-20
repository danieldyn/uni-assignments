
#pragma once

#include <cstdint>
#include "utils.h"
#include <arpa/inet.h>
#include <map>
#include <vector>
#include <optional>
#include <semaphore.h>

/* Maximum segment size, change as you see fit */
#define MAX_DATA_SIZE 512
#define MAX_SEGMENT_SIZE (MAX_DATA_SIZE + sizeof(poli_tcp_data_hdr))

#define MAX_CONNECTIONS 32
#define RING_BUFFER_SIZE 1024

struct packet {
    char data[MAX_DATA_SIZE];
    uint16_t len;
    bool ack_or_recv;
};

/* Protocol control block. Used track different parameters about a connection. 
 * Will need to be extendended to solve the homework with other parameters such as
 * last_ack or status depending on how you implement your protocol. */
struct connection {
    /* common window for both the sender and receiver. */
    /* list window: A window representation */
    int sockfd; /* socket used for this connection */
    int conn_id; /* connection identifier */
    struct sockaddr_in servaddr; /* used to identify the destination */
    pthread_mutex_t con_lock; /* Used for syncronization with the handler thread and read/send calls.*/

    /* Parameters used only by the sender */
    int max_window_seq; /* Used to store the max number of packets that can be inflight, since we can
                           have many more packets in our window */
    uint16_t oldest_nack; /* The oldest unacknowledged sequence number */
    uint16_t next_seq; /* Next sequence number that can be used for new data */
    std::vector<std::optional<packet>> send_window; /* Packets without ACK */
    sem_t available_slots; /* Primitive used to notify that there is a slot in the sender window */
    uint16_t last_ack_num; /* Tracker for fast retransmission */ 
    uint8_t dup_ack_count; /* Duplicate tracker for fast retransmission */
    uint16_t remote_window; /* The announced receiver window */

    /* Parameters used only by the client */
    uint16_t expected_seq; /* Next sequence number, from the network's perspective */
    uint16_t expected_seq_for_app; /* Next sequence number, from the app's perspective */
    std::vector<std::optional<packet>> recv_window; /* Packets that are out of order */
    uint16_t recv_buffered_count; /* Tracker for the buffered packets by the client */
    sem_t expected_packet; /* Primitive used to notify that a newly arrived packet fills in a gap */
};

/* ########## API that we expose to the application ########### */

/* Equivalent of listen. Ran by the server to waits for a connection from a
 * client. Returns a connection id. Blocking untill it receives a connection
 * request */
int wait4connect(uint32_t ip, uint16_t port);
/* Equivalent of connect. Used by the client to connect to a server. */
int setup_connection(uint32_t ip, uint16_t port);
/* Equivalent to recv. Blocking if there is no data to be written in buffer */
int recv_data(int connectionid, char *buffer, int len);
/* Equivalent to send. Used by the client to send a stream of bytes as segments */
int send_data(int conn_id, char *buffer, int len);
/* Used to initialize your protocol on the receiver side. */
void init_receiver(int recv_buffer_bytes);
/* Used to initialize your protocol on the sender side */
void init_sender(int speed, int delay);

/* ######### Internal API used by sender and receiver ########### */
int recv_message_or_timeout(char *buff, size_t len, int *conn_id);
