// SPDX-License-Identifier: BSD-3-Clause

#include <internal/mm/mem_list.h>
#include <internal/types.h>
#include <internal/essentials.h>
#include <sys/mman.h>
#include <string.h>
#include <stdlib.h>

void *malloc(size_t size)
{
	int fd = -1; // To create an anonymous mapping, file descriptor -1 is used
	long offset = 0; // There's no file to offset into
	void *new_map = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, fd, offset);

	// Add mapping to the memory list
	mem_list_add(new_map, size);

	return new_map;
}

void *calloc(size_t nmemb, size_t size)
{
	void *new_map;

	// calloc = malloc + memset all bytes to 0
	new_map = malloc(nmemb * size);
	if (new_map != NULL)
		memset(new_map, 0, nmemb * size);

	return new_map;
}

void free(void *ptr)
{
	struct mem_list *target_item;

	// Find targeted mapping
	target_item = mem_list_find(ptr);
	if (target_item == NULL)
		return; // Avoid unmapping something not mapped in the first place

	// Unmap if found and remove from the memory list
	munmap(target_item->start, target_item->len);
	mem_list_del(target_item->start);
}

void *realloc(void *ptr, size_t size)
{
	struct mem_list *old_map_item;
	void *new_map;

	// Find existing mapping
	old_map_item = mem_list_find(ptr);
	if (old_map_item == NULL)
		return NULL;

	// Remap if found
	new_map = mremap(ptr, old_map_item->len, size, MREMAP_MAYMOVE);

	return new_map;
}

void *reallocarray(void *ptr, size_t nmemb, size_t size)
{
	// Arrays are continuous in memory, we can use realloc with the total size
	return realloc(ptr, nmemb * size);
}
