// SPDX-License-Identifier: BSD-3-Clause

#include <sys/stat.h>
#include <internal/types.h>
#include <unistd.h>
#include <internal/syscall.h>
#include <fcntl.h>
#include <errno.h>

#define makedev(x, y) ( \
		(((x)&0xfffff000ULL) << 32) | \
	(((x)&0x00000fffULL) << 8) | \
		(((y)&0xffffff00ULL) << 12) | \
	(((y)&0x000000ffULL)) \
	)

/* Structure describing file characteristics as defined in linux/stat.h */
struct statx {
	uint32_t stx_mask;
	uint32_t stx_blksize;
	uint64_t stx_attributes;
	uint32_t stx_nlink;
	uint32_t stx_uid;
	uint32_t stx_gid;
	uint16_t stx_mode;
	uint16_t pad1;
	uint64_t stx_ino;
	uint64_t stx_size;
	uint64_t stx_blocks;
	uint64_t stx_attributes_mask;
	struct {
		int64_t tv_sec;
		uint32_t tv_nsec;
		int32_t pad;
	} stx_atime, stx_btime, stx_ctime, stx_mtime;
	uint32_t stx_rdev_major;
	uint32_t stx_rdev_minor;
	uint32_t stx_dev_major;
	uint32_t stx_dev_minor;
	uint64_t spare[14];
};

int fstatat_statx(int fd, const char *restrict path, struct stat *restrict st, int flag)
{
	/* Linux statx(2) man page 
	 int statx(int dirfd, const char *_Nullable restrict path,
                 int flags, unsigned int mask,
                 struct statx *restrict statxbuf); 
		This function returns information about a file, storing it in the
       buffer pointed to by statxbuf. */
	struct statx stax;
	int ret;

	ret = syscall(__NR_statx, fd, path, flag, STATX_BASIC_STATS, &stax);
	if (ret < 0) {
		errno = -ret;
		return -1;
	}

	/* Complete the fields of the stat struct using the contents of the statx struct (stored after statx syscall)
	   Using the field order from sys/stat.h */
	st->st_dev = makedev(stax.stx_dev_major, stax.stx_dev_minor);
	st->st_ino = stax.stx_ino;
	st->st_nlink = stax.stx_nlink;

	st->st_mode = stax.stx_mode;
	st->st_uid = stax.stx_uid;
	st->st_gid = stax.stx_gid;
	st->__pad0 = stax.pad1;
	st->st_rdev = makedev(stax.stx_rdev_major, stax.stx_rdev_minor);
	st->st_size = stax.stx_size;
	st->st_blksize = stax.stx_blksize;
	st->st_blocks = stax.stx_blocks;

	st->st_atime = stax.stx_atime.tv_sec;
	st->st_atime_nsec = stax.stx_atime.tv_nsec;
	st->st_mtime = stax.stx_mtime.tv_sec;
	st->st_mtime_nsec = stax.stx_mtime.tv_nsec;
	st->st_ctime = stax.stx_ctime.tv_sec;
	st->st_ctime_nsec = stax.stx_ctime.tv_nsec;

	return ret;
}

int fstatat(int fd, const char *restrict path, struct stat *restrict st, int flag)
{
	return fstatat_statx(fd, path, st, flag);
}
