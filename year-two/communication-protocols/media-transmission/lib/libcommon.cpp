#include <sys/socket.h>
#include <sys/types.h>
#include <sys/timerfd.h>
#include <netinet/ip.h> 
#include <stdio.h>
#include <cstdint>
#include "include/lib.h"
#include <vector>
#include <map>
#include <cstring>
#include <assert.h>
#include <unistd.h>
#include <cstdlib>
#include <pthread.h>
#include <sys/poll.h>
#include <fcntl.h>

using namespace std;

/* We use extern to use the variables defined either in
   librecv or libsend */
extern std::map<int, struct connection *> cons;
extern struct pollfd data_fds[MAX_CONNECTIONS];
extern struct pollfd timer_fds[MAX_CONNECTIONS];
extern int fdmax;

pthread_mutex_t cons_lock = PTHREAD_MUTEX_INITIALIZER; // Synchronisation mechanism for the global shared map of connections

int recv_message_or_timeout(char *buff, size_t len, int *conn_id)
{
    int ret, i;

    pthread_mutex_lock(&cons_lock);
    int local_fdmax = fdmax;
    pthread_mutex_unlock(&cons_lock);

    if (local_fdmax == 0)
        return -14;

    /* We check if data is available on a socket or if a timer has expired */
    ret = poll(data_fds, local_fdmax, 0); 
    assert(ret >= 0);
    ret = poll(timer_fds, local_fdmax, 0); 
    assert(ret >= 0);

    for (i = 0; i < local_fdmax; i++) {
        /* Data available on a socket */
        if (data_fds[i].revents & POLLIN) {

            struct sockaddr_in servaddr;
            socklen_t slen = sizeof(struct sockaddr_in);

            int n = recvfrom(data_fds[i].fd, buff, len, MSG_WAITALL, (struct sockaddr *) &servaddr , &slen);
            int j = -1; 

            /* Find which connection this socket coresponds to */
            pthread_mutex_lock(&cons_lock);
            for (auto const& x : cons) {
                if(x.second->sockfd == data_fds[i].fd) {
                    j = x.first;
                    break;
                }
            }
            pthread_mutex_unlock(&cons_lock);

            assert(j != -1);
            /* Write in the conn_id the connection of the socket*/
            *conn_id = j;
            return n;
        }
        /* A timer has expired on a connection */
        if (timer_fds[i].revents & POLLIN) {

            char dummybuf[8];
            read(timer_fds[i].fd, dummybuf, 8);

            /* Find which connection this coresponds to */
            int j = -1; 
            pthread_mutex_lock(&cons_lock);
            for (auto const& x : cons) {
                if(x.second->sockfd == data_fds[i].fd) {
                    j = x.first;
                    break;
                }
            }
            pthread_mutex_unlock(&cons_lock);

            assert(j != -1);

            /* Write in the conn_id the connection of the socket*/
            *conn_id = j;
            return -1;
        }
    }

    /* If nothing happened, return -14. */
    return -14;
}
