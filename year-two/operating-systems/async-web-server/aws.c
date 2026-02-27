// SPDX-License-Identifier: BSD-3-Clause

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/sendfile.h>
#include <sys/eventfd.h>
#include <libaio.h>
#include <errno.h>

#include "aws.h"
#include "utils/util.h"
#include "utils/debug.h"
#include "utils/sock_util.h"
#include "utils/w_epoll.h"

#define MAX_EVENTS 1024
#define IOCB_COUNT 1

/* server socket file descriptor */
static int listenfd;

/* epoll file descriptor */
static int epollfd;

static io_context_t ctx;

static int aws_on_path_cb(http_parser *p, const char *buf, size_t len)
{
	struct connection *conn;
	size_t current_len;

	conn = (struct connection *)p->data;
	current_len = strlen(conn->request_path);

	memcpy(conn->request_path + current_len, buf, len);
	conn->request_path[current_len + len] = '\0';

	// Debugging
	dlog(LOG_INFO, "Current Path: '%s'\n", conn->request_path);

	return 0;
}

static void connection_prepare_send_reply_header(struct connection *conn)
{
	/* Prepare the connection buffer to send the reply header. */
	snprintf(conn->send_buffer, BUFSIZ,
		"HTTP/1.1 200 OK\r\n"
		"Date: Sun, 08 May 2011 09:26:16 GMT\r\n"
		"Server: Apache/2.2.9\r\n"
		"Last-Modified: Mon, 02 Aug 2010 17:55:28 GMT\r\n"
		"Accept-Ranges: bytes\r\n"
		"Content-Length: %zu\r\n"
		"Vary: Accept-Encoding\r\n"
		"Connection: close\r\n"
		"Content-Type: text/html\r\n"
		"\r\n",
		conn->file_size
	);

	conn->send_len = strlen(conn->send_buffer);
	conn->send_pos = 0;
}

static void connection_prepare_send_404(struct connection *conn)
{
	/* Prepare the connection buffer to send the 404 header. */
	snprintf(conn->send_buffer, BUFSIZ,
		"HTTP/1.1 404 Not Found\r\n"
		"Date: Sun, 08 May 2011 09:26:16 GMT\r\n"
		"Server: Apache/2.2.9\r\n"
		"Last-Modified: Mon, 02 Aug 2010 17:55:28 GMT\r\n"
		"Accept-Ranges: bytes\r\n"
		"Content-Length: 0\r\n"
		"Vary: Accept-Encoding\r\n"
		"Connection: close\r\n"
		"Content-Type: text/html\r\n"
		"\r\n");

	conn->send_len = strlen(conn->send_buffer);
	conn->send_pos = 0;
}

static enum resource_type connection_get_resource_type(struct connection *conn)
{
	/* Get resource type depending on request path/filename. Filename should
	 * point to the static or dynamic folder.
	 */
	if (strstr(conn->request_path, AWS_REL_STATIC_FOLDER) != NULL)
		return RESOURCE_TYPE_STATIC;

	if (strstr(conn->request_path, AWS_REL_DYNAMIC_FOLDER) != NULL)
		return RESOURCE_TYPE_DYNAMIC;

	return RESOURCE_TYPE_NONE;
}


struct connection *connection_create(int sockfd)
{
	/*  Initialise connection structure on given socket. */
	struct connection *conn;

	conn = calloc(1, sizeof(struct connection));
	DIE(conn == NULL, "calloc");

	conn->sockfd = sockfd;
	conn->state = STATE_INITIAL;
	conn->fd = -1; // File-related
	conn->eventfd = -1; // Notification

	return conn;
}

void connection_start_async_io(struct connection *conn)
{
	/* Start asynchronous operation (read from file).
	 * Use io_submit(2) & friends for reading data asynchronously.
	 */

	int rc;
	struct iocb *control_block = &conn->iocb;

	// Check if the eventfd is registered
	if (conn->eventfd < 0) {
		rc = eventfd(0, EFD_NONBLOCK);
		DIE(rc < 0, "eventfd");

		// Add the eventfd to input epoll
		conn->eventfd = rc;
		w_epoll_add_ptr_in(epollfd, conn->eventfd, conn);
	}

	// Prepare the control block's fields
	io_prep_pread(control_block, conn->fd, conn->send_buffer, BUFSIZ, conn->file_pos);
	io_set_eventfd(control_block, conn->eventfd);

	// Submit the control block pointer array
	conn->piocb[0] = control_block;
	rc = io_submit(ctx, IOCB_COUNT, conn->piocb);
	if (rc != IOCB_COUNT) { // The iocb wasn't submitted successfully
		conn->state = STATE_CONNECTION_CLOSED;
		return;
	}

	conn->state = STATE_ASYNC_ONGOING;

	// Start listening for input
	w_epoll_update_fd_in(epollfd, conn->sockfd);
}

void connection_remove(struct connection *conn)
{
	/* Remove connection handler. */
	if (conn->fd >= 0)
		close(conn->fd);

	if (conn->eventfd >= 0)
		close(conn->eventfd);

	// Remove socket from epoll object
	w_epoll_remove_ptr(epollfd, conn->sockfd, conn);
	close(conn->sockfd);

	free(conn);
}

void handle_new_connection(void)
{
	/* Handle a new connection request on the server socket. */
	static int sockfd;
	int rc, flags;
	struct sockaddr_in addr;
	struct connection *conn;
	socklen_t addrlen = sizeof(addr);

	/* Accept new connection. */
	sockfd = accept(listenfd, (SSA *) &addr, &addrlen);
	DIE(sockfd < 0, "accept");

	/* Set socket to be non-blocking. */
	flags = fcntl(sockfd, F_GETFL, 0);
	fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);

	/* Instantiate new connection handler. */
	conn = connection_create(sockfd);

	/* Add socket to epoll. */
	rc = w_epoll_add_ptr_in(epollfd, sockfd, conn);
	DIE(rc < 0, "w_epoll_add_in");

	/* Initialise HTTP_REQUEST parser. */
	http_parser_init(&conn->request_parser, HTTP_REQUEST);
	conn->request_parser.data = conn;
}

void receive_data(struct connection *conn)
{
	/* Receive message on socket.
	 * Store message in recv_buffer in struct connection.
	 */
	ssize_t bytes_read;
	size_t bytes_remaining = BUFSIZ - conn->recv_len;

	// Receive in the buffer from where we left off
	bytes_read = recv(conn->sockfd, conn->recv_buffer + conn->recv_len, bytes_remaining, 0);

	// Debugging
	dlog(LOG_INFO, "FD: %d, Read Bytes: %ld\n", conn->sockfd, bytes_read);

	if (bytes_read < 0)
		return;

	if (bytes_read == 0) { // According to the protocol, connection must be closed
		conn->state = STATE_CONNECTION_CLOSED;
		return;
	}

	// Connection updates
	conn->recv_len += bytes_read;

	// Check for the end of the header to change states
	if (strstr(conn->recv_buffer, "\r\n\r\n") != NULL) {
		conn->state = STATE_REQUEST_RECEIVED;
		conn->have_path = 1;
		return;
	}

	conn->state = STATE_RECEIVING_DATA;
}

int connection_open_file(struct connection *conn)
{
	/* Open file and update connection fields. */
	int rc;
	struct stat stbuf;

	// Path interpretation (ignoring leading '/' in the path, since we already have it in AWS_DOCUMENT_ROOT)
	memcpy(conn->filename, AWS_DOCUMENT_ROOT, strlen(AWS_DOCUMENT_ROOT));
	memcpy(conn->filename + strlen(conn->filename), conn->request_path + 1, strlen(conn->request_path));
	conn->filename[strlen(conn->filename)] = '\0';

	// Debugging
	dlog(LOG_INFO, "Opening filename: '%s' (Type: %d)\n", conn->filename, conn->res_type);

	// Obtain file attributes
	rc = stat(conn->filename, &stbuf);
	if (rc < 0)
		return -1;

	// Debugging
	dlog(LOG_INFO, "Opened FD: %d, Size: %zu\n", conn->fd, conn->file_size);

	// Connection updates
	conn->res_type = connection_get_resource_type(conn);
	conn->file_size = stbuf.st_size;
	conn->fd = open(conn->filename, O_RDONLY);

	return conn->fd;
}

void connection_complete_async_io(struct connection *conn)
{
	/* Complete asynchronous operation; operation returns successfully.
	 * Prepare socket for sending.
	 */

	struct io_event event;
	uint64_t eventfd_counter;
	int rc;

	// Reset eventfd counter using read() - according to man page
	rc = read(conn->eventfd, &eventfd_counter, sizeof(uint64_t));
	if (rc < 0)
		return;

	// Read the event from the queue with infinite timeout
	rc = io_getevents(ctx, IOCB_COUNT, IOCB_COUNT, &event, NULL);
	if (rc == 0)
		return; // No event found

	// Update fields influenced by reading data
	conn->async_read_len = event.res;
	conn->file_pos += event.res;

	// Prepare for sending
	conn->send_len = event.res;
	conn->send_pos = 0;
	conn->state = STATE_SENDING_DATA;

	// Start listening for output events
	w_epoll_update_ptr_out(epollfd, conn->sockfd, conn);
}

int parse_header(struct connection *conn)
{
	/* Parse the HTTP header and extract the file path. */
	/* Use mostly null settings except for on_path callback. */
	size_t bytes_remaining, bytes_parsed;
	http_parser_settings settings_on_path = {
		.on_message_begin = 0,
		.on_header_field = 0,
		.on_header_value = 0,
		.on_path = aws_on_path_cb,
		.on_url = 0,
		.on_fragment = 0,
		.on_query_string = 0,
		.on_body = 0,
		.on_headers_complete = 0,
		.on_message_complete = 0
	};

	bytes_parsed = conn->request_parser.nread;
	bytes_remaining = conn->recv_len - bytes_parsed;
	if (bytes_remaining == 0)
		return 0;

	// Parse the remaining part (the parser will update its fields)
	http_parser_execute(&conn->request_parser, &settings_on_path, conn->recv_buffer + bytes_parsed, bytes_remaining);

	return 0;
}

enum connection_state connection_send_static(struct connection *conn)
{
	/* Send static data using sendfile(2). */
	ssize_t bytes_sent;
	size_t bytes_remaining = conn->file_size - conn->file_pos;
	off_t offset = conn->file_pos; // Solves sendfile pointer type warning

	bytes_sent = sendfile(conn->sockfd, conn->fd, &offset, bytes_remaining);

	// Debugging
	dlog(LOG_INFO, "Sendfile FD: %d, Sent: %ld, New Offset: %ld\n", conn->sockfd, bytes_sent, offset);

	if (bytes_sent < 0)
		return STATE_CONNECTION_CLOSED;

	// Offset update and check
	conn->file_pos = offset;
	if (conn->file_pos >= conn->file_size)
		return STATE_DATA_SENT;

	return STATE_SENDING_DATA;
}

int connection_send_data(struct connection *conn)
{
	/* May be used as a helper function. */
	/* Send as much data as possible from the connection send buffer.
	 * Returns the number of bytes sent or -1 if an error occurred
	 */
	ssize_t bytes_sent;
	size_t bytes_remaining = conn->send_len - conn->send_pos;

	bytes_sent = send(conn->sockfd, conn->send_buffer + conn->send_pos, bytes_remaining, 0);

	// Debugging
	dlog(LOG_INFO, "Send FD: %d, Sent: %ld\n", conn->sockfd, bytes_sent);

	if (bytes_sent < 0)
		return -1;

	// Connection update
	conn->send_pos += bytes_sent;

	return bytes_sent;
}


int connection_send_dynamic(struct connection *conn)
{
	/* Send data asynchronously.
	 * Returns 0 on success and -1 on error.
	 */

	int rc;

	rc = connection_send_data(conn);
	if (rc < 0) // Error
		return -1;

	if (conn->send_pos < conn->send_len)
		return 1; // Still sending

	if (conn->file_pos == conn->file_size)
		return 0; // Success

	// Start next chunk
	connection_start_async_io(conn);

	return 1;
}


void handle_input(struct connection *conn)
{
	/* Handle input information: may be a new message or notification of
	 * completion of an asynchronous I/O operation.
	 */

	int rc;

	// Debugging
	dlog(LOG_INFO, "Input Event on FD %d in state %d\n", conn->sockfd, conn->state);

	switch (conn->state) {
	case STATE_INITIAL: // Is also ready to receive
	case STATE_RECEIVING_DATA:
		receive_data(conn);

		// Check connection state after reading the data
		if (conn->state == STATE_CONNECTION_CLOSED) {
			connection_remove(conn);
			break;
		}

		// Try to extract and interpret header
		parse_header(conn);

		if (conn->have_path == 1) {
			rc = connection_open_file(conn);
			if (rc < 0) { // Invalid path
				conn->state = STATE_SENDING_404;
				connection_prepare_send_404(conn);
			} else { // All good
				conn->state = STATE_SENDING_HEADER;
				connection_prepare_send_reply_header(conn);
			}

			// Start listening for output
			w_epoll_update_ptr_out(epollfd, conn->sockfd, conn);
		}

		break;

	default:
		printf("shouldn't get here %d\n", conn->state);
	}
}

void handle_output(struct connection *conn)
{
	/* Handle output information: may be a new valid requests or notification of
	 * completion of an asynchronous I/O operation or invalid requests.
	 */

	int rc;
	enum connection_state next_state;

	// Debugging
	dlog(LOG_INFO, "Output Event on FD %d in state %d\n", conn->sockfd, conn->state);

	switch (conn->state) {
	case STATE_SENDING_HEADER: // Same action as 404, just a header at first
	case STATE_SENDING_404:
		rc = connection_send_data(conn);
		if (rc < 0) { // Error
			connection_remove(conn);
			break;
		}

		// Wait for the next event if the header isn't finished
		if (conn->send_pos < conn->send_len)
			break;

		// Header is sent, check for the easy case (404)
		if (conn->state == STATE_SENDING_404) {
			connection_remove(conn);
			break;
		}

		// State update for 200 to intentionally fall down to the next "case"
		conn->state = STATE_SENDING_DATA;

	case STATE_SENDING_DATA:
		if (conn->res_type == RESOURCE_TYPE_STATIC) {
			next_state = connection_send_static(conn);
			if (next_state == STATE_DATA_SENT || next_state == STATE_CONNECTION_CLOSED)
				connection_remove(conn);
		} else {
			// Check if it's the first chunk
			if (conn->file_pos == 0 && conn->async_read_len == 0) {
				connection_start_async_io(conn);
			} else {
				rc = connection_send_dynamic(conn);
				if (rc <= 0)
					connection_remove(conn);
			}
		}
		break;

	case STATE_ASYNC_ONGOING: // Wait for disk
		break;

	default:
		ERR("Unexpected state\n");
		exit(1);
	}
}

void handle_client(uint32_t event, struct connection *conn)
{
	/* Handle new client. There can be input and output connections.
	 * Take care of what happened at the end of a connection.
	 */

	if ((event & EPOLLIN) != 0) {
		if (conn->state == STATE_ASYNC_ONGOING)
			connection_complete_async_io(conn);
		else
			handle_input(conn);
	}

	if ((event & EPOLLOUT) != 0)
		handle_output(conn);
}

int main(void)
{
	int rc;

	/* Initialise asynchronous operations. */
	rc = io_setup(MAX_EVENTS, &ctx);
	DIE(rc < 0, "io_setup");

	/* Initialise multiplexing. */
	epollfd = w_epoll_create();
	DIE(epollfd < 0, "w_epoll_create");

	/* Create server socket. */
	listenfd = tcp_create_listener(AWS_LISTEN_PORT, DEFAULT_LISTEN_BACKLOG);
	DIE(listenfd < 0, "tcp_create_listener");

	/* Add server socket to epoll object. */
	rc = w_epoll_add_fd_in(epollfd, listenfd);
	DIE(rc < 0, "w_epoll_add_fd_in");

	/* Uncomment the following line for debugging. */
	dlog(LOG_INFO, "Server waiting for connections on port %d\n", AWS_LISTEN_PORT);

	/* server main loop */
	while (1) {
		struct epoll_event rev;

		/* Wait for events. */
		rc = w_epoll_wait_infinite(epollfd, &rev);
		DIE(rc < 0, "w_epoll_wait_infinite");

		/* Switch event types; consider
		 *   - new connection requests (on server socket)
		 *   - socket communication (on connection sockets)
		 */

		if (rev.data.fd == listenfd)
			handle_new_connection();
		else
			handle_client(rev.events, rev.data.ptr);
	}

	return 0;
}
