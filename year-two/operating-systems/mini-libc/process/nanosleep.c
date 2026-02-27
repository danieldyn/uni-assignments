#include <internal/syscall.h>
#include <errno.h>
#include <time.h>

// Header according to the Linux man page
int nanosleep(const struct timespec *duration, struct timespec *rem)
{
    int ret;

    ret = syscall(__NR_nanosleep, duration, rem);
    if (ret < 0) {
        errno = -ret;
        return -1;
    }

    return ret;
}
