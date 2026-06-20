#ifndef TRIE_H
#define TRIE_H

#include "lib.h"

// The structure of a node in the Trie tree used to model the routing table's content
typedef struct node {
	RTable value;
	struct node *children[2];
} TrieNode, *Trie;

/* Returns a dynamically allocated Trie node with NULL children */
extern Trie build_node(void);

/* Adds a new route to the routing table via the Trie */
extern void insert_route(Trie root, RTable route);

#endif
