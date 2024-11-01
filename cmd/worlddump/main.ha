use compress::gzip;
use compress::zlib;
use fmt;
use io;
use memio;
use nbt;
use nbt::{nbt_tag};
use os;
use path;
use types;
use world;

export fn main() void = {
	let path = path::init(os::args[1], "level.dat")!;
	const level = os::open(path::string(&path))!;
	defer io::close(level)!;
	const (_, gzrd) = gzip::decompress(level)!;
	const rd = nbt::read(&gzrd);
	const tag = nbt::next(&rd)! as nbt::value;
	assert(tag.tag == nbt::nbt_tag::COMPOUND && tag.name == "");
	const level = world::level_decode(&rd)!;
	fmt::printfln("Level name: {}", level.name)!;
	fmt::printfln("Seed: {}", level.seed)!;
	fmt::printfln("Spawn: <{},{},{}>",
		level.spawn.x, level.spawn.y, level.spawn.z)!;

	fmt::println()!;

	path::set(&path, os::args[1], "region", "r.0.0.mcr")!;
	const region = world::region_open(path::string(&path))!;
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
