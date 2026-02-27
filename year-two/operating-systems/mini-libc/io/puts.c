#include <internal/io.h>
#include <string.h>
#include <errno.h>

// header according to the Linux man page
int puts(const char *s)
{
    int ret;

    ret = write(1, s, strlen(s));
    if (ret < 0) {
        errno = -ret;
        return -1;
    }

    ret = write(1, "\n", 1);
    if (ret < 0) {
        errno = -ret;
        return -1;
    }

    return ret;
}
