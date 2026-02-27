// SPDX-License-Identifier: BSD-3-Clause

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <elf.h>
#include <string.h>
#include <sys/resource.h>

void *map_elf(const char *filename)
{
	// This part helps you store the content of the ELF file inside the buffer.
	struct stat st;
	void *file;
	int fd;

	fd = open(filename, O_RDONLY);
	if (fd < 0) {
		perror("open");
		exit(1);
	}

	fstat(fd, &st);

	file = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
	if (file == MAP_FAILED) {
		perror("mmap");
		close(fd);
		exit(1);
	}

	return file;
}

size_t lower_align(size_t initial, const size_t page_size)
{
	//return initial - initial % page_size;
	return initial & ~(page_size - 1);
}

size_t upper_align(size_t initial, const size_t page_size)
{
	return (initial + page_size - 1) & ~(page_size - 1);
}

void load_and_run(const char *filename, int argc, char **argv, char **envp)
{
	// Contents of the ELF file are in the buffer: elf_contents[x] is the x-th byte of the ELF file.
	void *elf_contents = map_elf(filename);

	/**
	 * TODO: ELF Header Validation
	 * Validate ELF magic bytes - "Not a valid ELF file" + exit code 3 if invalid.
	 * Validate ELF class is 64-bit (ELFCLASS64) - "Not a 64-bit ELF" + exit code 4 if invalid.
	 */

	char *magic_bytes = (char *)elf_contents;

	if (strncmp(magic_bytes, ELFMAG, 4) != 0) // ELFMAG expands as a string, so anything else creates warnings
		exit(3);

	// The fifth byte is at start_addr + EI_CLASS (start_addr + 4)
	char class_byte = *((char *) elf_contents + EI_CLASS);

	if (class_byte != ELFCLASS64)
		exit(4);

	/**
	 * TODO: Load PT_LOAD segments
	 * For minimal syscall-only binaries.
	 * For each PT_LOAD segment:
	 * - Map the segments in memory. Permissions can be RWX for now.
	 */

	Elf64_Ehdr *elf_header;
	Elf64_Phdr *segment_header;
	uintptr_t segment_vaddr, segment_offset, segment_start, segment_end;
	uintptr_t base_addr, min_vaddr, max_vaddr; // useful to determine early
	size_t segment_filesz, segment_memsz, map_len, offset_diff;
	int i, prot_rwx, prot, map_flags;
	void *map_addr;
	char *cpy_dest, *cpy_src;
	const size_t PAGE_SIZE = sysconf(_SC_PAGESIZE);

	elf_header = (Elf64_Ehdr *)elf_contents;
	segment_header = (Elf64_Phdr *)((char *)elf_header + elf_header->e_phoff);
	prot_rwx = PROT_READ | PROT_WRITE | PROT_EXEC;
	map_flags = MAP_PRIVATE | MAP_ANONYMOUS;

	// Check for PIE / no-PIE, this part was inserted for Task 5 fit
	if (elf_header->e_type != ET_DYN)
		base_addr = 0; // no-PIE, move on to directly map segments
	else {
		// Simulate ASLR (random memory region with 0 permissions)
		min_vaddr = 0xffffffffffffffff;
		max_vaddr = 0x0;
		// Determine the size of all segments
		for (i = 0; i < elf_header->e_phnum; i++)
			if (segment_header[i].p_type == PT_LOAD) {
				segment_vaddr = segment_header[i].p_vaddr;
				segment_memsz = segment_header[i].p_memsz;
				segment_start = lower_align(segment_vaddr, PAGE_SIZE);
				segment_end = upper_align(segment_vaddr + segment_memsz, PAGE_SIZE);
				// Update min and max
				if (min_vaddr > segment_start)
					min_vaddr = segment_start;
				if (max_vaddr < segment_end)
					max_vaddr = segment_end;
			}

		// Reserve a zone large enough for all segments, chosen by the kernel
		map_len = upper_align((size_t)(max_vaddr - min_vaddr), PAGE_SIZE);
		map_addr = mmap(NULL, map_len, PROT_NONE, map_flags, -1, 0);
		if (map_addr == MAP_FAILED) {
			perror("mmap PIE");
			exit(1);
		}
		// Calculate the random base address to use in the future
		// p_vaddr + base_addr >= map_addr, for every segment
		base_addr = (uintptr_t)map_addr - min_vaddr;
	}

	map_flags |= MAP_FIXED; // Needed by the next section for fixed mapping

	for (i = 0; i < elf_header->e_phnum; i++)
		if (segment_header[i].p_type == PT_LOAD) {
			// Reusable parameters, base_addr won't influence no-PIE because it's zero then
			segment_vaddr = segment_header[i].p_vaddr + base_addr;
			segment_offset = segment_header[i].p_offset;
			segment_filesz = segment_header[i].p_filesz;
			segment_memsz = segment_header[i].p_memsz;

			// Determine page alignment (necessary for MAP_FIXED)
			segment_start = lower_align(segment_vaddr, PAGE_SIZE);
			offset_diff = segment_vaddr - segment_start;
			map_len = upper_align(segment_memsz + offset_diff, PAGE_SIZE);

			// Map virtual memory for the segment
			map_addr = mmap((void *)segment_start, map_len, prot_rwx, map_flags, -1, 0);
			if (map_addr == MAP_FAILED) {
				perror("mmap segment");
				exit(1);
			}

			// Copy file section in the new memory region
			cpy_dest = map_addr + offset_diff;
			cpy_src = elf_contents + segment_offset;
			memcpy(cpy_dest, cpy_src, segment_filesz);

			// Pad with zeros if filesz and memsz differ
			if (segment_filesz < segment_memsz)
				memset(cpy_dest + segment_filesz, 0, segment_memsz - segment_filesz);
		}

	/**
	 * TODO: Load Memory Regions with Correct Permissions
	 * For each PT_LOAD segment:
	 *	- Set memory permissions according to program header p_flags (PF_R, PF_W, PF_X).
	 *	- Use mprotect() or map with the correct permissions directly using mmap().
	 */

	for (i = 0; i < elf_header->e_phnum; i++)
		if (segment_header[i].p_type == PT_LOAD) {
			// Same as before to determine start address and length
			segment_vaddr = segment_header[i].p_vaddr + base_addr;
			segment_memsz = segment_header[i].p_memsz;
			segment_start = lower_align(segment_vaddr, PAGE_SIZE);
			offset_diff = segment_vaddr - segment_start;
			map_len = upper_align(segment_memsz + offset_diff, PAGE_SIZE);

			// Apply correct permissions according to set bits (1)
			prot = 0;

			if (segment_header[i].p_flags & PF_R)
				prot |= PROT_READ;
			if (segment_header[i].p_flags & PF_W)
				prot |= PROT_WRITE;
			if (segment_header[i].p_flags & PF_X)
				prot |= PROT_EXEC;

			mprotect((void *)segment_start, map_len, prot);
		}

	/**
	 * TODO: Support Static Non-PIE Binaries with libc
	 * Must set up a valid process stack, including:
	 *	- argc, argv, envp
	 *	- auxv vector (with entries like AT_PHDR, AT_PHENT, AT_PHNUM, etc.)
	 * Note: Beware of the AT_RANDOM, AT_PHDR entries, the application will crash if you do not set them up properly.
	 */

	struct rlimit stack_limit;
	void *sp, *entry, *stack_map, *rand_addr;
	uintptr_t *ptr, *top, *base;

	int prot_rw = PROT_READ | PROT_WRITE;

	int stack_space = 0;

	map_flags = MAP_PRIVATE | MAP_ANONYMOUS;

	FILE *urandom = fopen("/dev/urandom", "rb");

	if (!urandom) {
		perror("file error");
		exit(1);
	}

	// Reserve memory region according to the stack soft limit from getrlimit
	getrlimit(RLIMIT_STACK, &stack_limit);
	stack_map = mmap(NULL, stack_limit.rlim_cur, prot_rw, map_flags, -1, 0);
	if (stack_map == MAP_FAILED) {
		perror("mmap stack");
		exit(1);
	}
	// Get the top address of the stack (anything abovve this should be unmapped)
	top = (uintptr_t *)((char *)stack_map + stack_limit.rlim_cur);

	// Calculate the required space
	stack_space++; // argc
	stack_space += argc + 1; // argv pointers and NULL
	for (i = 0; envp[i]; i++)
		stack_space++; // envp pointers
	stack_space++; // one more NULL
	stack_space += 7 * 2; // pairs of auxv entries
	stack_space += 2; // 16 bytes for random data

	// Calculate the base address according to needed space
	base = (uintptr_t *)(top - stack_space);
	ptr = base;

	// Put argc and argv on the stack
	*ptr++ = argc;
	for (i = 0; i < argc; i++)
		*ptr++ = (uintptr_t)argv[i];
	*ptr++ = 0x0; // NULL to separate argv and envp

	// Put envp on the stack
	for (i = 0; envp[i]; i++)
		*ptr++ = (uintptr_t)envp[i];
	*ptr++ = 0x0; // NULL to separate envp and auxv

	// Put auxv on the stack, element by element, AT_NULL must be last
	*ptr++ = AT_PAGESZ;
	*ptr++ = (uintptr_t)PAGE_SIZE; // previously used constant

	// AT_PHDR needs to be calculated depending on ELF type
	*ptr++ = AT_PHDR;
	if (elf_header->e_type == ET_DYN)
		*ptr++ = base_addr + elf_header->e_phoff;
	else {
		// Find the first loadable segment
		i = 0;
		while (segment_header[i].p_type != PT_LOAD)
			i++;
		// Headers are directly at the found vaddr + the offset
		*ptr++ = segment_header[i].p_vaddr + elf_header->e_phoff;
	}

	*ptr++ = AT_PHENT;
	*ptr++ = (uintptr_t)elf_header->e_phentsize;

	*ptr++ = AT_PHNUM;
	*ptr++ = (uintptr_t)elf_header->e_phnum;

	*ptr++ = AT_ENTRY;
	*ptr++ = (uintptr_t)elf_header->e_entry + base_addr;

	// Place the random bytes after the remaining auxv entries (2 pairs)
	rand_addr = ptr + 4;
	fread(rand_addr, 1, 16, urandom);
	fclose(urandom);
	*ptr++ = AT_RANDOM;
	*ptr++ = (uintptr_t)rand_addr;

	*ptr++ = AT_NULL;
	*ptr++ = 0x0;

	/**
	 * TODO: Support Static PIE Executables
	 * Map PT_LOAD segments at a random load base.
	 * Adjust virtual addresses of segments and entry point by load_base.
	 * Stack setup (argc, argv, envp, auxv) same as above.
	 */

	// TODO: Set the entry point and the stack pointer
	entry = (void *)((uintptr_t)elf_header->e_entry + base_addr);
	sp = (void *)base;

	// Transfer control
	__asm__ __volatile__(
			"mov %0, %%rsp\n"
			"xor %%rbp, %%rbp\n"
			"jmp *%1\n"
			:
			: "r"(sp), "r"(entry)
			: "memory"
			);
}

int main(int argc, char **argv, char **envp)
{
	if (argc < 2) {
		fprintf(stderr, "Usage: %s <static-elf-binary>\n", argv[0]);
		exit(1);
	}

	load_and_run(argv[1], argc - 1, &argv[1], envp);
	return 0;
}
