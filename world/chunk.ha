use compress::zlib;
use io;
use log;
use memio;
use nbt;
use net::mc;

// Width and depth of a world chunk in blocks.
export def CHUNK_WIDTH = 16;

// Height of a world chunk in blocks.
export def CHUNK_HEIGHT = 128;

export def CHUNK_BLOCKS = CHUNK_WIDTH * CHUNK_WIDTH * CHUNK_HEIGHT;

// Chunk flags
export type chunk_flag = enum uint {
	NONE = 0,
	// Has the terrain generator been here yet?
	POPULATED = 1 << 0,
	// Pending updates to flush to disk
	DIRTY = 1 << 1,
};

// A 16x16x128 chunk of the game world.
export type chunk = struct {
	coords: coords2D,
	refs: int,
	// TODO: Store entities and tile entities
	blocks: [CHUNK_BLOCKS]u8,
	metadata: [CHUNK_BLOCKS / 2]u8,
	block_light: [CHUNK_BLOCKS / 2]u8,
	sky_light: [CHUNK_BLOCKS / 2]u8,
	heightmap: [CHUNK_WIDTH * CHUNK_WIDTH]u8,
	last_update: i64,
	flags: chunk_flag,
};

const empty_chunk = chunk { ... };

// Returns true if this is the empty chunk (i.e. from [[mode::EMPTY]]).
export fn chunk_isempty(c: *chunk) bool = {
	if (c == &empty_chunk) {
		return true;
	};
	return c.flags & chunk_flag::POPULATED == 0;
};

// Increment the reference count for a chunk.
export fn chunk_ref(c: *chunk) void = {
	if (c == &empty_chunk) {
		return;
	};
	c.refs += 1;
};

// Populates a chunk from an [[nbt::reader]].
export fn chunk_fromnbt(chunk: *chunk, rd: *nbt::reader) (void | io::error) = {
	assert(chunk != &empty_chunk);

	let tag = nbt::next(rd)? as nbt::value;
	assert(tag.tag == nbt::nbt_tag::COMPOUND && tag.name == "");

	let tag = nbt::next(rd)? as nbt::value;
	assert(tag.tag == nbt::nbt_tag::COMPOUND && tag.name == "Level");

	for (const tag => nbt::next(rd)?) {
		switch (tag.name) {
		case "Blocks" =>
			assert(tag.tag == nbt::nbt_tag::BYTE_ARRAY);
			assert(len(chunk.blocks) == tag.length);
			io::readall(rd, chunk.blocks)?;
		case "Data" =>
			assert(tag.tag == nbt::nbt_tag::BYTE_ARRAY);
			assert(len(chunk.metadata) == tag.length);
			io::readall(rd, chunk.metadata)?;
		case "BlockLight" =>
			assert(tag.tag == nbt::nbt_tag::BYTE_ARRAY);
			assert(len(chunk.block_light) == tag.length);
			io::readall(rd, chunk.block_light)?;
		case "SkyLight" =>
			assert(tag.tag == nbt::nbt_tag::BYTE_ARRAY);
			assert(len(chunk.sky_light) == tag.length);
			io::readall(rd, chunk.sky_light)?;
		case "HeightMap" =>
			assert(tag.tag == nbt::nbt_tag::BYTE_ARRAY);
			assert(len(chunk.heightmap) == tag.length);
			io::readall(rd, chunk.heightmap)?;
		case "LastUpdate" =>
			assert(tag.tag == nbt::nbt_tag::LONG);
			chunk.last_update = tag._i64;
		case "TerrainPopulated" =>
			assert(tag.tag == nbt::nbt_tag::BYTE);
			if (tag._i8 != 0) {
				chunk.flags |= chunk_flag::POPULATED;
			};
		case =>
			nbt::skip(rd, tag)?;
		};
	};
};

// Populates a chunk from a [[net::mc::chunk_data]] packet.
export fn chunk_frompacket(chunk: *chunk, p: *mc::chunk_data) (void | io::error) = {
	assert(chunk != &empty_chunk);
	const rd = memio::fixed(p.data);
	const zrd = zlib::decompress(&rd)!;

	if (p.size_x == 15 && p.size_z == 15 && p.size_y == 127 && p.y == 0) {
		io::readall(&zrd, chunk.blocks)!;
		io::readall(&zrd, chunk.metadata)!;
		io::readall(&zrd, chunk.block_light)!;
		io::readall(&zrd, chunk.sky_light)!;
	} else {
		let data = io::drain(&zrd)!;
		defer free(data);

		const l =
			(p.size_x: size + 1) *
			(p.size_y: size + 1) *
			(p.size_z: size + 1);
		const hl = l / 2;

		const off_data = l;
		const off_blight = l + hl;
		const off_slight = l + hl * 2;

		const id = data[..l];
		const metadata = data[off_data..off_blight];
		const blight = data[off_blight..off_slight];
		const slight = data[off_slight..];

		const base_x = p.x & 0xF;
		const base_y = p.y & 0x7F;
		const base_z = p.z & 0xF;

		for (let z = 0; z < p.size_z+1; z += 1)
		for (let x = 0; x < p.size_x+1; x += 1)
		for (let y = 0; y < p.size_y+1; y += 1) {
			const in_ix =
				y +
				(z * (p.size_y+1)) +
				(x * (p.size_y+1) * (p.size_z+1));
			const out_ix =
				(base_x+x) * (CHUNK_WIDTH * CHUNK_HEIGHT) +
				(base_z+z) * CHUNK_HEIGHT +
				(base_y+y);
			chunk.blocks[out_ix] = id[in_ix];

			const in_hi = in_ix / 2;
			const in_ho = (in_ix % 2): u8 * 4;
			const out_hi = out_ix / 2;
			const out_ho = (out_ix % 2): u8 * 4;

			const in_data = metadata[in_hi] >> in_ho & 0xF;
			chunk.metadata[out_hi] &= 0xF << out_ho;
			chunk.metadata[out_hi] |= (in_data & 0xF) << out_ho;

			const in_slight = slight[in_hi] >> in_ho & 0xF;
			chunk.sky_light[out_hi] &= 0xF << out_ho;
			chunk.sky_light[out_hi] |= (in_slight & 0xF) << out_ho;

			const in_blight = blight[in_hi] >> in_ho & 0xF;
			chunk.block_light[out_hi] &= 0xF << out_ho;
			chunk.block_light[out_hi] |= (in_blight & 0xF) << out_ho;
		};
	};

	chunk.flags |= chunk_flag::POPULATED;
};

// Gets the block ID from a [[chunk]] at the given coordinates.
export fn chunk_getid(c: *chunk, x: uint, y: uint, z: uint) u8 = {
	assert(x < CHUNK_WIDTH && z < CHUNK_WIDTH);
	assert(y < CHUNK_HEIGHT);
	const ix = x * (CHUNK_WIDTH * CHUNK_HEIGHT) + z * CHUNK_HEIGHT + y;
	return c.blocks[ix];
};

// Gets the metadata from a [[chunk]] at the given coordinates.
export fn chunk_getmeta(c: *chunk, x: uint, y: uint, z: uint) u8 = {
	assert(x < CHUNK_WIDTH && z < CHUNK_WIDTH);
	assert(y < CHUNK_HEIGHT);
	const base = x * (CHUNK_WIDTH * CHUNK_HEIGHT) + z * CHUNK_HEIGHT + y;
	const ix = base / 2, off = (base % 2): u8;
	return (c.metadata[ix] >> (off * 4)) & 0xF;
};

// Gets the block light from a [[chunk]] at the given coordinates.
export fn chunk_getblocklight(c: *chunk, x: uint, y: uint, z: uint) u8 = {
	assert(x < CHUNK_WIDTH && z < CHUNK_WIDTH);
	assert(y < CHUNK_HEIGHT);
	const base = x * (CHUNK_WIDTH * CHUNK_HEIGHT) + z * CHUNK_HEIGHT + y;
	const ix = base / 2, off = (base % 2): u8;
	return (c.block_light[ix] >> (off * 4)) & 0xF;
};

// Gets the sky light from a [[chunk]] at the given coordinates.
export fn chunk_getskylight(c: *chunk, x: uint, y: uint, z: uint) u8 = {
	assert(x < CHUNK_WIDTH && z < CHUNK_WIDTH);
	assert(y < CHUNK_HEIGHT);
	const base = x * (CHUNK_WIDTH * CHUNK_HEIGHT) + z * CHUNK_HEIGHT + y;
	const ix = base / 2, off = (base % 2): u8;
	return (c.sky_light[ix] >> (off * 4)) & 0xF;
};

// Gets the height from a [[chunk]] at the given coordinates.
export fn chunk_getheight(c: *chunk, x: uint, z: uint) u8 = {
	assert(x < CHUNK_WIDTH && z < CHUNK_WIDTH);
	return c.heightmap[x * CHUNK_WIDTH + z];
};
