/* SPDX-License-Identifier: BSD-3-Clause */

#ifndef __SO_CONSUMER_H__
#define __SO_CONSUMER_H__

#include <pthread.h>
#include "ring_buffer.h"
#include "packet.h"

typedef struct so_consumer_ctx_t {
	struct so_ring_buffer_t *producer_rb;
	int out_fd;
    /* TODO: add synchronization primitives for timestamp ordering */
	pthread_mutex_t read_mutex, write_mutex;
	pthread_cond_t write_available; // signals that it's someone's turn to write in the log file
	unsigned long count; // how many threads have waited or are waiting to write in the log file
	unsigned long next_writer; // the index of the thread that needs to write in the log file
} so_consumer_ctx_t;

int create_consumers(pthread_t *tids,
					int num_consumers,
					so_ring_buffer_t *rb,
					const char *out_filename);

#endif /* __SO_CONSUMER_H__ */
