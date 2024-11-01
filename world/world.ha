use compress::gzip;
use compress::zlib;
use errors;
use fmt;
use fs;
use io;
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
	// Load additional chunks from disk if necessary
	LOAD = 1 << 0,
	// Generate new chunks if necessary
	GENERATE = 1 << 1,
};

// A game world on disk.
export type world = struct {
	basedir: str,
	level: level,

	// List of loaded chunks, sorted by coordinates. All loaded chunks at
	// runtime are sourced from a mapped region.
	//
	// XXX: Should we move these into [[region]]? Maybe
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

// Fetches a [[voxel]] from the world.
export fn get(
	w: *world,
	out: *voxel,
	c: coords3D,
	mode: mode = mode::EMPTY,
) (void | error) = {
	const (x, y, z) = c;
	if (y < 0 || y >= 128) {
		return range;
	};

	abort(); // TODO
};

// Fetches a [[chunk]] from the world.
export fn get_chunk(
	w: *world,
	c: coords2D,
	mode: mode = mode::EMPTY,
) (const *chunk | error) = {
	const model = &c;
	const cix = sort::lbisect(w.chunks, size(*chunk),
		&model, &coords2D_cmp);
	if (cix < len(w.chunks) && coords2D_equal(w.chunks[cix].coords, c)) {
		return w.chunks[cix];
	};

	if (mode == mode::EMPTY) {
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
	let chunk = alloc(chunk { ... });
	chunk_fromnbt(chunk, &rd)!;
	chunk.coords = c;
	insert(w.chunks[cix], chunk);
	return chunk;
};

// Map a region file into the [[world]]. The coordinates should be in the region
// coordinate system.
fn world_mapregion(w: *world, c: coords2D, ix: size) (*region | error) = {
	let buf: [32]u8 = [0...];
	const filename = fmt::bsprintf(buf, "r.{}.{}.mcr", c.0, c.1);
	const path = path::init(w.basedir, "region", filename)!;
	const path = path::string(&path);

	const region = region_open(c, path)?;
	insert(w.regions[ix], region);
	return region;
};
