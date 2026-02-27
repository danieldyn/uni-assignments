# Assignment ELF Loader

Implementing a custom minimal ELF loader, capable of loading and executing statically linked binaries in Linux, supporting:

- Minimal static binaries that make direct Linux syscalls (without `libc`)
- Statically linked **non-PIE** C programs using `libc`
- Statically linked **PIE** executables

