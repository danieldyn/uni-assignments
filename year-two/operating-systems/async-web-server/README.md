# Assignment Asynchronous Web Server

A web server that uses the following advanced I/O operations:

- Asynchronous operations on files
- Non-blocking operations on sockets
- Zero-copying
- Multiplexing I/O operations

The server implements a limited functionality of the HTTP protocol: passing files to clients.

The web server uses the multiplexing API to wait for connections from clients - `epoll`.
On the established connections, requests from clients will be received and then responses will be distributed to them.

The server serves files from the `AWS_DOCUMENT_ROOT` directory.
Files are only found in subdirectories `AWS_DOCUMENT_ROOT/static/` and `AWS_DOCUMENT_ROOT/dynamic/`.
The corresponding request paths will be, for example, `AWS_DOCUMENT_ROOT/static/test.dat` and `AWS_DOCUMENT_ROOT/dynamic/test.dat`.
The file processing will be:

- The files in the `AWS_DOCUMENT_ROOT/static/` directory are static files that will be transmitted to clients using the zero-copying API - `sendfile`
- Files in the `AWS_DOCUMENT_ROOT/dynamic/` directory are files that are supposed to require a server-side post-processing phase. These files will be read from disk using the asynchronous API and then pushed to the clients. Streaming uses non-blocking sockets (Linux)
- An `HTTP 404` message is sent for invalid request paths

After transmitting a file, according to the HTTP protocol, the connection is closed.

