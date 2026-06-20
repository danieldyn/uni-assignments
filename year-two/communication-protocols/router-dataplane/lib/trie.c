#include <arpa/inet.h>
#include "trie.h"

Trie build_node()
{
	Trie node = (Trie) calloc(1, sizeof(TrieNode));
	DIE(node == NULL, "calloc");
	return node;
}

void insert_route(Trie root, RTable route)
{
	Trie curr_node = root;
	uint32_t prefix = ntohl(route->prefix);
	uint32_t mask = ntohl(route->mask);

	for (uint32_t bit = 1U << 31; (mask & bit) != 0; bit >>= 1) {
		int idx = (prefix & bit) != 0;
		if (curr_node->children[idx] == NULL)
			curr_node->children[idx] = build_node(); // Extend the tree

		curr_node = curr_node->children[idx];
	}

	// Store the route at the end of the path in the tree
	curr_node->value = route;
}
