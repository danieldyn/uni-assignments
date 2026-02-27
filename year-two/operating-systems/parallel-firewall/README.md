# Assignment Parallel Firewall

A firewall is a program that checks network packets against a series of filters which provide a decision regarding dropping or allowing the packets to continue to their intended destination.

In this assignment, instead of real network packets, we deal with made up packets consisting of a made up source (a number), a made up destination (also a number), a timestamp (also a number) and some payload.
And instead of the network card providing the packets, we have a **producer thread** creating these packets.

The created packets are inserted into a **circular buffer**, out of which **consumer threads** (which implement the firewall logic) will take packets and process them in order to decide whether they advance to the destination.

The result of this processing is a log file in which the firewall will record the decision taken (PASS or DROP) for each packet, along with other information such as timestamp.

The purpose of this assignment was to:

- implement the circular buffer, along with synchronisation mechanisms for it to work in a multithreaded program

- implement the consumer threads, which consume packets and process them

- provide the log file containing the result of the packet processing

