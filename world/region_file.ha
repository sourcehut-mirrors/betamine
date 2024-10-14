use endian;
use errors;
use fs;
use io;
use os;

def PAGE_SIZE = 4096;

// 32x32 chunk region of the world, mapped to a file on disk.
export type region = struct {
	file: io::file,
	length: size,
	data: *region_file,
};

// Memory-mapped region file data structure.
export type region_file = struct {
	offs: [1024]u32,
	mtime: [1024]u32,
	pages: [*][PAGE_SIZE]u8,
};

// Header of the chunk data stored in a [[region_file]].
export type chunk_hdr = struct {
	length: u32,
	scheme: u8,
	data: [*]u8,
};

// Opens a [[region]] file from disk.
export fn region_open(
	path: str,
	flag: fs::flag = fs::flag::RDONLY,
) (region | io::error | fs::error | errors::error) = {
	const file = os::open(path, flag)?;
	const length = io::seek(file, 0, io::whence::END)!: size;
	io::seek(file, 0, io::whence::SET)!;

	const prot =
		if (flag & fs::flag::RDWR != 0) io::prot::READ | io::prot::WRITE
		else io::prot::READ;

	const addr = io::mmap(null, length, prot,
		io::mflag::PRIVATE, file, 0)?;

	return region {
		file = file,
		length = length,
		data = addr: *region_file,
	};
};

// Closes a [[region]].
export fn region_close(r: *region) void = {
	io::munmap(r.data, r.length)!;
	io::close(r.file)!;
};
