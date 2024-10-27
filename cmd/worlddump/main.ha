use compress::zlib;
use fmt;
use io;
use memio;
use nbt;
use nbt::{nbt_tag};
use os;
use types;
use world;

export fn main() void = {
	const region = world::region_open(os::args[1])!;
	defer world::region_close(&region);

	const chunk = world::region_getchunk(&region, 0, 0) as *world::chunk_header;
	assert(chunk.scheme == world::compression::DEFLATE);
	const data = world::chunk_data(chunk);
	fmt::errorfln("Chunk <{},{}>: {} bytes", 0, 0, len(data))!;

	const data = memio::fixed(data);
	const zrd = zlib::decompress(&data)!;
	const rd = nbt::read(&zrd);
	nbt::dump(os::stdout, &rd)!;

	io::seek(&data, 0, io::whence::SET)!;
	const zrd = zlib::decompress(&data)!;
	const rd = nbt::read(&zrd);
	let chunk = world::chunk { ... };
	world::chunk_fromnbt(&chunk, &rd)!;

	fmt::printfln("Last update: {}", chunk.last_update)!;
	fmt::printfln("Populated: {}", chunk.populated)!;
};
