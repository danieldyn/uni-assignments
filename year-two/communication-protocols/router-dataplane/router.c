#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include "protocols.h"
#include "queue.h"
#include "trie.h"
#include "lib.h"

/**
 * Logarithmic implementation of the LPM algorithm
 */
RTable get_best_route(uint32_t dest_ip, Trie root)
{
	RTable route = NULL;
	Trie curr_node = root;
	uint32_t ip = ntohl(dest_ip);

	for (uint32_t bit = 1U << 31; bit != 0; bit >>= 1) {
		if (curr_node->value != NULL)
			route = curr_node->value;

		int idx = (ip & bit) != 0;
		if (curr_node->children[idx] == NULL)
			return route; // Partial match ended

		curr_node = curr_node->children[idx];
	}

	// Check if there is a perfect match at the end of the traversal
	if (curr_node->value != NULL)
		return curr_node->value;

	return route;
}

/**
 * ARP cache lookup function
 */
ArpTable get_mac_entry(uint32_t next_ip, ArpTable arp_table, int arp_table_len)
{
	for (int i = 0 ; i < arp_table_len; i++)
		if (arp_table[i].ip == next_ip)
			return arp_table + i;

	return NULL;
}

/**
 * ARP packet handler function (requests or replies)
 */
void handle_arp(char *buf, size_t len, size_t interface, ArpTable arp_table, int *arp_table_len, queue packet_queue)
{
	EtherHdr *eth_hdr = (EtherHdr *) buf;
	ArpHdr *arphdr = (ArpHdr *) (buf + sizeof(EtherHdr));

	if (ntohs(arphdr->opcode) == ARP_REQUEST) {
		uint32_t router_addr = inet_addr(get_interface_ip(interface));

		if (arphdr->tprotoa == router_addr) { // The target is the router's interface
			// Save the sender's MAC address for future use
			arp_table[*arp_table_len].ip = arphdr->sprotoa;
			memcpy(arp_table[*arp_table_len].mac, arphdr->shwa, MAC_ADDR_LEN);
			(*arp_table_len)++;

			// Return an ARP_REPLY packet to the requester (swapping all addresses)
			arphdr->opcode = htons(ARP_REPLY);
			arphdr->tprotoa = arphdr->sprotoa;
			arphdr->sprotoa = router_addr;
			memcpy(arphdr->thwa, arphdr->shwa, MAC_ADDR_LEN);
			get_interface_mac(interface, arphdr->shwa);
			memcpy(eth_hdr->ethr_dhost, eth_hdr->ethr_shost, MAC_ADDR_LEN);
			get_interface_mac(interface, eth_hdr->ethr_shost);

			// Send reply
			send_to_link(len, buf, interface);
		}
	} else if (ntohs(arphdr->opcode) == ARP_REPLY) {
		// Save the ARP reply in the local cache
		arp_table[*arp_table_len].ip = arphdr->sprotoa;
		memcpy(arp_table[*arp_table_len].mac, arphdr->shwa, MAC_ADDR_LEN);
		(*arp_table_len)++;

		// Find which packet was waiting for this reply
		queue aux_queue = create_queue();
		while (!queue_empty(packet_queue)) {
			QueuePacket *pkt = (QueuePacket *) queue_deq(packet_queue);

			if (pkt->route->next_hop == arphdr->sprotoa) {
				EtherHdr *pkt_eth = (EtherHdr *) pkt->buf;
				memcpy(pkt_eth->ethr_dhost, arphdr->shwa, MAC_ADDR_LEN);
				get_interface_mac(pkt->route->interface, pkt_eth->ethr_shost);
				send_to_link(pkt->len, pkt->buf, pkt->route->interface);
				free(pkt);
			} else {
				queue_enq(aux_queue, pkt); // Put the packet back in waiting
			}
		}

		// Restore packet queue
		while (!queue_empty(aux_queue))
			queue_enq(packet_queue, queue_deq(aux_queue));

		free(aux_queue);
	}
}

/**
 * Gnerates an ICMP answer with the specified type and code, populating a given buffer
 */
size_t create_icmp_answer(char *answer, char *buf, int interface, uint8_t mtype, uint8_t mcode)
{
	// Headers from the received packet (buf)
	EtherHdr *eth_hdr = (EtherHdr *) buf;
	IpHdr *ipv4_hdr = (IpHdr *) (buf + sizeof(EtherHdr));
	// Headers for the ICMP answer
	EtherHdr *ans_eth = (EtherHdr *) answer;
	IpHdr *ans_ipv4 = (IpHdr *) (answer + sizeof(EtherHdr));
	IcmpHdr *ans_icmp = (IcmpHdr *) (answer + sizeof(EtherHdr) + sizeof(IpHdr));
	uint16_t icmp_payload_len = sizeof(IpHdr) + 8;
	uint32_t router_addr = inet_addr(get_interface_ip(interface));

	// Fill in Ethernet header fields
	ans_eth->ethr_type = htons(ETHERTYPE_IPV4);
	memcpy(ans_eth->ethr_dhost, eth_hdr->ethr_shost, MAC_ADDR_LEN);
	get_interface_mac(interface, ans_eth->ethr_shost);

	// Fill in IPv4 header fields
	ans_ipv4->ver = 4;
	ans_ipv4->ihl = 5;
	ans_ipv4->tos = 0;
	ans_ipv4->ttl = 64;
	ans_ipv4->proto = PROTOTYPE_ICMP;
	ans_ipv4->id = htons(4);
	ans_ipv4->frag = 0;
	ans_ipv4->dest_addr = ipv4_hdr->source_addr;
	ans_ipv4->source_addr = router_addr;
	ans_ipv4->tot_len = htons(sizeof(IpHdr) + sizeof(IcmpHdr) + icmp_payload_len);
	ans_ipv4->checksum = 0;
	ans_ipv4->checksum = htons(checksum((uint16_t *) ans_ipv4, sizeof (IpHdr)));

	// Fill in ICMP header fields
	ans_icmp->mtype = mtype;
	ans_icmp->mcode = mcode;
	memcpy((char *) ans_icmp + sizeof(IcmpHdr), ipv4_hdr, icmp_payload_len);
	ans_icmp->check = 0;
	ans_icmp->check = htons(checksum((uint16_t *) ans_icmp, sizeof (IcmpHdr) + icmp_payload_len));

	// Return the total length of the created packet
	return sizeof(EtherHdr) + sizeof(IpHdr) + sizeof(IcmpHdr) + icmp_payload_len;
}

/**
 * Sends an ARP request using the broadcast address
 */
void broadcast_arp_request(RTable route)
{
	char request[MAX_PACKET_LEN];
	memset(&request, 0, MAX_PACKET_LEN);
	EtherHdr *req_eth = (EtherHdr*) request;
	ArpHdr *req_arp = (ArpHdr *) (request + sizeof(EtherHdr));
	size_t len = sizeof(EtherHdr) + sizeof(ArpHdr);

	// Fill in Ethernet header fields
	req_eth->ethr_type = htons(ETHERTYPE_ARP);
	hwaddr_aton("ff:ff:ff:ff:ff:ff", req_eth->ethr_dhost);
	get_interface_mac(route->interface, req_eth->ethr_shost);

	// Fill in ARP header fields
	req_arp->hw_type = htons(HWTYPE_ETHERNET);
	req_arp->hw_len = MAC_ADDR_LEN;
	req_arp->proto_type = htons(ETHERTYPE_IPV4);
	req_arp->proto_len = IPV4_ADDR_LEN;
	req_arp->opcode = htons(ARP_REQUEST);
	get_interface_mac(route->interface, req_arp->shwa);
	req_arp->sprotoa = inet_addr(get_interface_ip(route->interface));
	hwaddr_aton("00:00:00:00:00:00", req_arp->thwa);
	req_arp->tprotoa = route->next_hop;

	// Send ARP request
	send_to_link(len, request, route->interface);
}

/**
 * IPv4 packet handler function (includes forwarding and ICMP variations)
 */
void handle_ipv4(char *buf, size_t len, size_t interface, Trie root, ArpTable arp_table, int arp_table_len, queue packet_queue)
{
	EtherHdr *eth_hdr = (EtherHdr *) buf;
	IpHdr *ipv4_hdr = (IpHdr *) (buf + sizeof(EtherHdr));
	uint32_t router_addr = inet_addr(get_interface_ip(interface));

	// Verify checksum
	uint16_t recv_checksum = ntohs(ipv4_hdr->checksum);
	ipv4_hdr->checksum = 0;
	int sum_ok = (checksum((uint16_t *) ipv4_hdr, sizeof(IpHdr)) == recv_checksum);
	if (!sum_ok)
		return;

	// Check if the router is the destination of the packet
	if (ipv4_hdr->dest_addr == router_addr) {
		IcmpHdr *icmp_hdr = (IcmpHdr *) (buf + sizeof(EtherHdr) + sizeof(IpHdr));

		if (ipv4_hdr->proto == PROTOTYPE_ICMP && icmp_hdr->mtype == ECHO_REQUEST) {
			// Swap Ethernet addresses
			uint8_t aux[MAC_ADDR_LEN];
			memcpy(aux, eth_hdr->ethr_dhost, MAC_ADDR_LEN);
			memcpy(eth_hdr->ethr_dhost, eth_hdr->ethr_shost, MAC_ADDR_LEN);
			memcpy(eth_hdr->ethr_shost, aux, MAC_ADDR_LEN);

			// Edit relevant IP fields (ttl, addresses, checksum)
			ipv4_hdr->ttl = 64;
			uint32_t tmp = ipv4_hdr->dest_addr;
			ipv4_hdr->dest_addr = ipv4_hdr->source_addr;
			ipv4_hdr->source_addr = tmp;
			ipv4_hdr->checksum = 0;
			ipv4_hdr->checksum = htons(checksum((uint16_t *) ipv4_hdr, sizeof(IpHdr)));

			// Edit relevant ICMP fields (mtype, checksum)
			uint16_t icmp_payload_len = ntohs(ipv4_hdr->tot_len) - sizeof(IpHdr);
			icmp_hdr->mtype = ECHO_REPLY;
			icmp_hdr->check = 0;
			icmp_hdr->check = htons(checksum((uint16_t *) icmp_hdr, icmp_payload_len));

			// Send back "Echo Reply" packet
			send_to_link(len, buf, interface);
		}

		return;
	}

	// Verify TTL
	if (ipv4_hdr->ttl <= 1) {
		// Send back ICMP "Time Exceeded" packet
		char answer[MAX_PACKET_LEN];
		memset(&answer, 0, MAX_PACKET_LEN);
		len = create_icmp_answer(answer, buf, interface, TIME_EXCEEDED, NET_UNREACHABLE);
		send_to_link(len, answer, interface);
		return;
	}

	// Solve destination address
	RTable route = get_best_route(ipv4_hdr->dest_addr, root);
	if (route == NULL) {
		// Send back ICMP "Destination Unreachable" packet
		char answer[MAX_PACKET_LEN];
		memset(&answer, 0, MAX_PACKET_LEN);
		len = create_icmp_answer(answer, buf, interface, DESTINATION_UNREACHABLE, NET_UNREACHABLE);
		send_to_link(len, answer, interface);
		return;
	}

	// Update valid TTl
	ipv4_hdr->ttl--;

	// Update checksum
	ipv4_hdr->checksum = 0;
	ipv4_hdr->checksum = htons(checksum((uint16_t *) ipv4_hdr, sizeof(IpHdr)));

	// Overwrite L2 addresses
	ArpTable arp_entry = get_mac_entry(route->next_hop, arp_table, arp_table_len);
	if (arp_entry == NULL) { // Address not known yet
		// Save packet (need the content, the length and the route that was found for it)
		QueuePacket *pkt = (QueuePacket *) malloc(sizeof(QueuePacket));
		DIE(pkt == NULL, "malloc");
		memcpy(pkt->buf, buf, len);
		pkt->len = len;
		pkt->route = route;
		queue_enq(packet_queue, pkt);

		// Generate ARP request using broadcast address
		broadcast_arp_request(route);
		return;
	}
	
	// The packet can be forwarded directly
	memcpy(eth_hdr->ethr_dhost, arp_entry->mac, MAC_ADDR_LEN);
	get_interface_mac(route->interface, eth_hdr->ethr_shost);

	// Send packet to next hop
	send_to_link(len, buf, route->interface);
}

int main(int argc, char *argv[])
{
	char buf[MAX_PACKET_LEN];

	// Do not modify this line
	init(argv + 2, argc - 2);

	// Initialise routing table
	RTable rtable = (RTable) malloc(ROUTING_TABLE_SIZE * sizeof(RTableEntry));
	DIE(rtable == NULL, "malloc");
	int rtable_len = read_rtable(ROUTING_TABLE_PATH, rtable);

	// Build the trie tree based on the routing table
	Trie root = build_node();
	for (int i = 0; i < rtable_len; i++)
		insert_route(root, rtable + i);

	// Initialise dynamic ARP table and the packet queue
	ArpTable arp_table = (ArpTable) malloc(ARP_TABLE_SIZE * sizeof(ArpTableEntry));
	DIE(arp_table == NULL, "malloc");
	int arp_table_len = 0;
	queue packet_queue = create_queue();
	DIE(packet_queue == NULL, "malloc");

	while (1) {
		size_t interface;
		size_t len;

		interface = recv_from_any_link(buf, &len);
		DIE(interface < 0, "recv_from_any_links");

    // Implement the router forwarding logic

    /* Note that packet_queue received are in network order,
		any header field which has more than 1 byte will need to be conerted to
		host order. For example, ntohs(eth_hdr->ether_type). The oposite is needed when
		sending a packet on the link, */

		// Extract the Ethernet header and check packet type
		EtherHdr *eth_hdr = (EtherHdr *) buf;

		if (ntohs(eth_hdr->ethr_type) == ETHERTYPE_ARP) {
			handle_arp(buf, len, interface, arp_table, &arp_table_len, packet_queue);
			continue;
		} else if (ntohs(eth_hdr->ethr_type) == ETHERTYPE_IPV4) {
			handle_ipv4(buf, len, interface, root, arp_table, arp_table_len, packet_queue);
		}
	}

	free(rtable);
	free(arp_table);
	free(packet_queue);

	return 0;
}
