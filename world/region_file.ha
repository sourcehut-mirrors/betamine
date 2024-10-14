use endian;
use errors;
use fs;
use io;
use math;
use os;

export def PAGE_SIZE = 4096;

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

// Chunk data compression scheme. In practice only DEFLATE is used.
export type compression = enum u8 {
	PLAIN = 0,
	GZIP = 1,
	DEFLATE = 2,
};

// Header of the chunk data stored in a [[region_file]].
export type chunk_header = struct {
	length: u32,
	scheme: compression,
	data: [*]u8,
};

// Returns a slice of chunk data represented by a [[chunk_header]].
export fn chunk_data(chdr: *chunk_header) const []u8 = {
	const length = endian::ntohu32(chdr.length);
	return chdr.data[..length];
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

// Returns the chunk header associated with the given coordinates, if any,
// specified in global chunk coordinates.
export fn region_getchunk(r: *region, x: int, z: int) nullable *chunk_header = {
	const ix = math::absi(x % 32) + math::absi(z % 32) * 32;

	let offs = endian::ntohu32(r.data.offs[ix]);
	if (offs == 0) {
		return null;
	};

	const length = (offs & 0xFF) * PAGE_SIZE;
	offs >>= 8;

	const chdr = &r.data.pages[offs - 2]: *chunk_header;
	assert(endian::ntohu32(chdr.length) <= length);
	return chdr;
};
