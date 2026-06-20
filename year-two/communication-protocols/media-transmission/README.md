# Communication Protocls
# Media Transmission Protocol

## Overview

The purpose of this assignment is to develop a connection-oriented protocol over the UDP API, which will be used to
transmit books and images as a stream of bytes, without errors, between to applications (client and server), while
efficiently utilising the bandwidth of the link.

In addition, the programs `client.cpp` and `server.cpp` are to be considered read-only and part of the skeleton.
The protocol needs to be able to deliver the segments successfully between these two applications without operating
any changes inside their source code. The actual implementation is treated as a library of helper functions that the
superior layer in the network stack uses.

## Topology

The testing infrastructure used for this implementation can be represented as follows:

```
         8 Mb/s, 1 ms, 5% loss	       8 Mb/s, 1 ms, 5% loss
client <---------------------> router <----------------------> server
 (h1)				            (r0)				            (h2)
```

For more details see `checker/topo.py`, where the Shell `checker.sh` script also lives

## Protocol Features

- Three-way handshake mechanism, followed by the allocation of a random port for that connection
- Selective Repeat ARQ technique, for improved throughput
- Fast Retransmit technique on third duplicate acknowledgement
- Sliding windows as circular buffers using the C++ `std::optional` STL for each segment
- One timer per connection, when sending segments
- Separated thread for communication with a client
- Synchronization primitives such as POSIX semaphores and mutexes
- Multiplexing client connections using `poll`
