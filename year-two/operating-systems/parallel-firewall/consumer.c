// SPDX-License-Identifier: BSD-3-Clause

#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#include "consumer.h"
#include "ring_buffer.h"
#include "packet.h"
#include "utils.h"

void *consumer_thread(so_consumer_ctx_t *ctx)
{
	/* TODO: implement consumer thread */
	struct so_packet_t *packet;
	ssize_t size;
	char data[PKT_SZ], log_entry[256];
	int action, entry_len;
	unsigned long hash, timestamp, idx;

	while (1) {
		// Wait while there aren't any packets using the semaphore
		// This is better than having threads wait inside ring_buffer_dequeue()
		sem_wait(&ctx->producer_rb->pkt_sem);

		// Grab a packet from the ring buffer
		pthread_mutex_lock(&ctx->read_mutex);
		size = ring_buffer_dequeue(ctx->producer_rb, data, PKT_SZ);
		if (size < 1) { // No packets produced, need to quit
			pthread_mutex_unlock(&ctx->read_mutex);
			break;
		}

		// Save own index and allow other threads to read their packet
		idx = ctx->count++;
		pthread_mutex_unlock(&ctx->read_mutex);

		// Parallel processing
		packet = (struct so_packet_t *)data;
		action = process_packet(packet);
		hash = packet_hash(packet);
		timestamp = packet->hdr.timestamp;

		// Store log file entry locally (similar to serial.c)
		entry_len = snprintf(log_entry, 256, "%s %016lx %lu\n",
					RES_TO_STR(action), hash, timestamp);

		// Wait in line for writing in the correct order
		pthread_mutex_lock(&ctx->write_mutex);
		while (idx != ctx->next_writer)
			pthread_cond_wait(&ctx->write_available, &ctx->write_mutex);

		// Write and wake up other threads for writing
		write(ctx->out_fd, log_entry, entry_len);
		ctx->next_writer++;
		pthread_cond_broadcast(&ctx->write_available);
		pthread_mutex_unlock(&ctx->write_mutex);
	}

	return NULL;
}

int create_consumers(pthread_t *tids,
					 int num_consumers,
					 struct so_ring_buffer_t *rb,
					 const char *out_filename)
{
	int fd, flags;
	so_consumer_ctx_t *ctx;

	// Allocate one context, shareable to all consumers
	ctx = malloc(sizeof(so_consumer_ctx_t));
	if (!ctx)
		return -1;

	// Open the log file
	flags = O_RDWR | O_APPEND | O_CREAT | O_TRUNC;
	fd = open(out_filename, flags, 0644);
	if (fd < 0)
		return -1;

	// Complete the fields of the shared structure
	ctx->out_fd = fd;
	ctx->producer_rb = rb;

	// Initialise chosen sync primitives
	ctx->count = 0;
	ctx->next_writer = 0;
	pthread_mutex_init(&ctx->read_mutex, NULL);
	pthread_mutex_init(&ctx->write_mutex, NULL);
	pthread_cond_init(&ctx->write_available, NULL);

	for (int i = 0; i < num_consumers; i++) {
		/*
		 * TODO: Launch consumer threads
		 **/
		pthread_create(tids + i, NULL, (void *(*)(void *))consumer_thread, (void *)ctx);
	}

	return num_consumers;
}
