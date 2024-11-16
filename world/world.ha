use compress::gzip;
use compress::zlib;
use errors;
use fmt;
use fs;
use io;
use log;
use memio;
use nbt;
use os;
use path;
use sort;
use strings;

// Configures the desired behavior when fetching data outside of the bounds of
// the currently loaded chunks.
export type mode = enum uint {
	// Return empty voxels/chunks (full of air blocks)
	EMPTY = 0,
	// Load additional chunks from disk if necessary. If the chunks are not
	// available on disk and GENERATE is also set, new chunks are generated;
	// otherwise empty chunks/voxels are returned.
	LOAD = 1 << 0,
	// Generate new chunks if necessary
	GENERATE = 1 << 1,
};

// A game world on disk.
export type world = struct {
	basedir: str,
	level: level,

	// List of loaded chunks, sorted by coordinates. If the world is backed
	// by the filesystem, all loaded chunks at runtime are sourced from a
	// mapped region.
	chunks: []*chunk,

	// List of mapped regions, sorted by coordinates.
	regions: []*region,
};

// Opens a world directory from disk.
export fn open(path: str) (world | fs::error | io::error) = {
	let pathbuf = path::init(path)!;
	path::push(&pathbuf, "level.dat")!;

	const file = os::open(path::string(&pathbuf))?;
	defer io::close(file)!;
	const (_, gzrd) = gzip::decompress(file)!;
	const rd = nbt::read(&gzrd);
	nbt::openroot(&rd)?;

	const level = level_decode(&rd)?;

	path::pop(&pathbuf);

	return world {
		basedir = strings::dup(path::string(&pathbuf)),
		level = level,
		...
	};
};

// Opens an in-memory world.
export fn memory() world = {
	return world {
		...
	};
};

// Returns true if this world is only represented in memory (and not persisted
// on disk).
export fn is_memory(w: *world) bool = {
	return w.basedir == "";
};

// Frees resources associated with this world.
export fn finish(w: *world) void = {
	for (let c .. w.chunks) {
		assert(c.flags & chunk_flag::DIRTY == 0);
		free(c);
	};
	free(w.chunks);

	for (let r .. w.regions) {
		region_close(r);
	};
	free(w.regions);
};

// Fetches a [[voxel]] from the world.
export fn get(
	w: *world,
	out: *voxel,
	c: coords3D,
	mode: mode = mode::EMPTY,
) (void | error) = {
	if (c.1 < 0 || c.1 >= 128) {
		return range;
	};

	const cc = world_to_chunk(c, &c);
	const chunk = get_chunk(w, cc, mode)?;

	const ix = c.0 * (CHUNK_WIDTH * CHUNK_HEIGHT) + c.2 * CHUNK_HEIGHT + c.1;
	const hi = ix / 2;
	const ho = (ix % 2): u8 * 4;
	out.id = chunk.blocks[ix];
	out.data = chunk.metadata[hi] >> ho & 0xF;
	out.sky_light = chunk.sky_light[hi] >> ho & 0xF;
	out.block_light = chunk.block_light[hi] >> ho & 0xF;
};

// Fetches a [[chunk]] from the world. Increments the chunk's reference count;
// see [[put_chunk]] to free this reference.
export fn get_chunk(
	w: *world,
	c: coords2D,
	mode: mode = mode::EMPTY,
) (const *chunk | error) = {
	const model = &c;
	const cix = sort::lbisect(w.chunks, size(*chunk),
		&model, &coords2D_cmp);
	if (cix < len(w.chunks) && coords2D_equal(w.chunks[cix].coords, c)) {
		w.chunks[cix].refs += 1;
		return w.chunks[cix];
	};

	if (mode == mode::EMPTY || is_memory(w)) {
		return &empty_chunk;
	};

	let rcc: coords2D = (0, 0);
	const rc = chunk_to_region(c, &rcc);

	const model = &rc;
	const rix = sort::lbisect(w.regions, size(*region),
		&model, &coords2D_cmp);

	const region = if (rix < len(w.regions)
		&& coords2D_equal(w.regions[rix].coords, rc)) {
		yield w.regions[rix];
	} else match (world_mapregion(w, rc, rix)) {
	case let r: *region =>
		yield r;
	case let err: fs::error =>
		if (!(err is errors::noentry)) {
			return err;
		};
		if (mode & mode::GENERATE == 0) {
			return &empty_chunk;
		};
		abort(); // TODO: create new region file
	case let err: error =>
		return err;
	};

	const header = match (region_getchunk(region, rcc)) {
	case let hdr: *chunk_header =>
		region_ref(region);
		yield hdr;
	case null =>
		if (mode & mode::GENERATE == 0) {
			return &empty_chunk;
		};
		abort(); // TODO: create new region file
	};

	assert(header.scheme == compression::DEFLATE);
	const data = chunk_data(header);
	const data = memio::fixed(data);
	const zrd = zlib::decompress(&data)!;
	const rd = nbt::read(&zrd);
	let chunk = alloc(chunk {
		refs = 1,
		...
	});
	match (chunk_fromnbt(chunk, &rd)) {
	case let err: io::error =>
		log::printfln("[world]: WARNING: Error loading chunk <{},{}>: {}",
			c.0, c.1, io::strerror(err));
	case void => void;
	};

	chunk.coords = c;
	insert(w.chunks[cix], chunk);
	return chunk;
};

// Decrements the reference count of a [[chunk]], freeing it if necessary.
export fn put_chunk(w: *world, ch: *chunk) void = {
	ch.refs -= 1;
	if (ch.refs > 0) {
		return;
	};

	let model = &ch.coords;
	const cix = sort::lbisect(w.chunks, size(*chunk),
		&model, &coords2D_cmp);
	assert(cix < len(w.chunks) && coords2D_equal(w.chunks[cix].coords, ch.coords));
	delete(w.chunks[cix]);
	defer free(ch);

	if (is_memory(w)) {
		return;
	};

	const rc = chunk_to_region(ch.coords);
	model = &rc;
	const rix = sort::lbisect(w.regions, size(*region), &model, &coords2D_cmp);
	assert(rix < len(w.regions) && coords2D_equal(rc, w.regions[rix].coords));
	const region = w.regions[rix];

	const rrefs = region_unref(region);
	if (rrefs == 0) {
		delete(w.regions[rix]);
	};
};

// Map a region file into the [[world]]. The coordinates should be in the region
// coordinate system.
fn world_mapregion(w: *world, c: coords2D, ix: size) (*region | error) = {
	assert(!is_memory(w));

	let buf: [32]u8 = [0...];
	const filename = fmt::bsprintf(buf, "r.{}.{}.mcr", c.0, c.1);
	const path = path::init(w.basedir, "region", filename)!;
	const path = path::string(&path);

	const region = region_open(c, path)?;
	insert(w.regions[ix], region);
	return region;
};
