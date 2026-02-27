#ifndef __TIME_H__
#define __TIME_H__	1

struct timespec {
    long tv_sec, tv_nsec;
};

// To be used by sleep.c
int nanosleep(const struct timespec *duration, struct timespec *rem);

#endif
