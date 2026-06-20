# Communication Protocls
# Router Dataplane Assignment

## Overview

A router normally contains two components:

- The dataplane (the forwarding logic according to a routing table)
- The control plane (the distributed routing algorithms)

This assignment focuses strictly on the first one.

## Topology

The testing infrastructure used for this implementation includes:

- Two hosts `h0` and `h1` connected to router `r0`
- Two hosts `h2` and `h3` connected to router `r1`
- A direct link between the two routers
- For more details see `checker/topo.py`, where the Shell `checker.sh` script also lives

## Protocol Features

- Standard IPv4 packet forwarding logic (TTL + checksum check, next hop discovery, etc.)
- Longest Prefix Match, optimised using a **Trie** data structure for improved lookup times
- ARP Protocol implementation using permanent caching and a **waiting queue** for packets expecting ARP replies
- ICMP Protocol minimal implementation for **Destination unreachable** and **Time exceeded**
