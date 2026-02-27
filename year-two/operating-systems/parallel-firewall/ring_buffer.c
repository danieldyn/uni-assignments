// SPDX-License-Identifier: BSD-3-Clause

#include "ring_buffer.h"
#include <stdlib.h>
#include "packet.h"

int ring_buffer_init(so_ring_buffer_t *ring, size_t cap)
{
	/* TODO: implement ring_buffer_init */

	ring->data = (char *)malloc(cap);
	if (!ring->data)
		return -1;

	ring->cap = cap;
	ring->read_pos = 0;
	ring->write_pos = 0;
	ring->len = 0;

	// Initialise chosen sync primitives
	// The buffer is empty (nothing to read, all spaces are available for writing)
	pthread_mutex_init(&ring->mutex, NULL);
	sem_init(&ring->pkt_sem, 0, 0);
	sem_init(&ring->space_sem, 0, cap / PKT_SZ);

	return 1;
}

ssize_t ring_buffer_enqueue(so_ring_buffer_t *ring, void *data, size_t size)
{
	/* TODO: implement ring_buffer_enqueue */

	// Wait while there isn't space using the semaphore
	sem_wait(&ring->space_sem);
	pthread_mutex_lock(&ring->mutex);

	// Perform data writing to buffer
	memcpy(ring->data + ring->write_pos, data, size);
	ring->write_pos += size;
	ring->len += size;

	// Simple condition to keep the buffer "circular"
	if (ring->write_pos == ring->cap)
		ring->write_pos = 0;

	// Set the semaphore for consumers
	pthread_mutex_unlock(&ring->mutex);
	sem_post(&ring->pkt_sem);

	return size;
}

ssize_t ring_buffer_dequeue(so_ring_buffer_t *ring, void *data, size_t size)
{
	/* TODO: Implement ring_buffer_dequeue */

	// Waiting at the consumer semaphore is done in consumer.c
	//sem_wait(&ring->pkt_sem);
	pthread_mutex_lock(&ring->mutex);

	// Look at the buffer length if awakened by the semaphore
	if (ring->len == 0) {
		pthread_mutex_unlock(&ring->mutex);
		// Propagate the semaphore to other consumers
		sem_post(&ring->pkt_sem);
		return 0;
	}

	// Perform data extraction from buffer
	memcpy(data, ring->data + ring->read_pos, size);
	ring->read_pos += size;
	ring->len -= size;

	// Simple condition to keep the buffer "circular"
	if (ring->read_pos == ring->cap)
		ring->read_pos = 0;

	// Set the semaphore for producers
	pthread_mutex_unlock(&ring->mutex);
	sem_post(&ring->space_sem);

	return size;
}

void ring_buffer_destroy(so_ring_buffer_t *ring)
{
	/* TODO: Implement ring_buffer_destroy */

	pthread_mutex_destroy(&ring->mutex);
	sem_destroy(&ring->pkt_sem);
	sem_destroy(&ring->space_sem);
	free(ring->data);
}

void ring_buffer_stop(so_ring_buffer_t *ring)
{
	/* TODO: Implement ring_buffer_stop */

	// Set the consumer semaphore to make them wake up on an empty buffer
	sem_post(&ring->pkt_sem);
}
