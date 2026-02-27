#include <internal/syscall.h>
#include <time.h>

// Header according to the Linux man page
unsigned int sleep(unsigned int seconds)
{
    int ret;
    struct timespec time = {seconds, 0};

    ret = nanosleep(&time, &time);
    if (ret != 0) // The requested time hasn't elapsed
        return time.tv_sec;

    return 0;
}
