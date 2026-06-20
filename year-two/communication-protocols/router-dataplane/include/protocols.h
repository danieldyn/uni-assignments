#include <unistd.h>
#include <stdint.h>

#define ETHERTYPE_IPV4 0x800
#define ETHERTYPE_ARP 0x806
#define PROTOTYPE_ICMP 1 // From RFC 990
#define IPV4_ADDR_LEN 4
#define MAC_ADDR_LEN 6

#define HWTYPE_ETHERNET 1 // IANA Hardware Type
#define ARP_REQUEST 1 // IANA Operation Code
#define ARP_REPLY 2 // IANA Operation Code

#define ECHO_REPLY 0 //ICMP message type
#define DESTINATION_UNREACHABLE 3 // ICMP message type
#define ECHO_REQUEST 8 // ICMP message type
#define TIME_EXCEEDED 11 // ICMP message type

#define NET_UNREACHABLE 0 // ICMP message code

/* Useful typedefs for every prtocol header */
typedef struct ether_hdr EtherHdr;
typedef struct ip_hdr IpHdr;
typedef struct arp_hdr ArpHdr;
typedef struct icmp_hdr IcmpHdr;

/* Ethernet ARP packet from RFC 826 */
struct arp_hdr {
	uint16_t hw_type;   /* Format of hardware address */
	uint16_t proto_type;   /* Format of protocol address */
	uint8_t hw_len;    /* Length of hardware address */
	uint8_t proto_len;    /* Length of protocol address */
	uint16_t opcode;    /* ARP opcode (command) */
	uint8_t shwa[6];  /* Sender hardware address */
	uint32_t sprotoa;   /* Sender IP address */
	uint8_t thwa[6];  /* Target hardware address */
	uint32_t tprotoa;   /* Target IP address */
} __attribute__((packed));

/* Ethernet frame header*/
struct  ether_hdr {
    uint8_t  ethr_dhost[6]; //adresa mac destinatie
    uint8_t  ethr_shost[6]; //adresa mac sursa
    uint16_t ethr_type;     // identificator protocol encapsulat
};

/* IP Header */
struct ip_hdr {
    // this means that version uses 4 bits, and ihl 4 bits
    uint8_t    ihl:4, ver:4;   // we use version = 4
    uint8_t    tos;         // Nu este relevant pentru temă (set pe 0)
    uint16_t   tot_len;     // total length = ipheader + data
    uint16_t   id;          // Nu este relevant pentru temă, (set pe 4)
    uint16_t   frag;        // Nu este relevant pentru temă, (set pe 0)
    uint8_t    ttl;         // Time to Live -> to avoid loops, we will decrement
    uint8_t    proto;       // Identificator al protocolului encapsulat (e.g. ICMP)
    uint16_t   checksum;    // checksum     -> Since we modify TTL,
    uint32_t   source_addr; // Adresa IP sursă  
    uint32_t   dest_addr;   // Adresa IP destinație
};

struct icmp_hdr
{
  uint8_t mtype;                /* message type */
  uint8_t mcode;                /* type sub-code */
  uint16_t check;               /* checksum */
  union
  {
    struct
    {
      uint16_t        id;
      uint16_t        seq;
    } echo_t;                        /* echo datagram.  Vom folosi doar acest câmp din union*/
    uint32_t        gateway_addr;        /* Gateway address. Nu este relevant pentru tema */
    struct
    {
      uint16_t        __unused;
      uint16_t        mtu;
    } frag_t;                        /* Nu este relevant pentru tema */
  } un_t;
};
