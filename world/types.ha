// A single voxel.
export type voxel = struct {
	id: u8,
	data: u8,
	block_light: u8,
	sky_light: u8,
};

// Block coordinates in three dimensions, X, Y, and Z.
export type coords3D = (int, int, int);

// Block coordinates in two dimensions, X and Z.
export type coords2D = (int, int);

// Returns true if two pairs of [[coords2D]] are equal.
export fn coords2D_equal(a: coords2D, b: coords2D) bool = {
	return a.0 == b.0 && a.1 == b.1;
};

// [[sort::cmp]] function for lists sorted by a [[coords2D]].
export fn coords2D_cmp(a: const *opaque, b: const *opaque) int = {
	let a = a: const **coords2D;
	let b = b: const **coords2D;
	if (a.0 < b.0) {
		return -1;
	} else if (a.0 > b.0) {
		return 1;
	} else if (a.1 < b.1) {
		return -1;
	} else if (a.1 > b.1) {
		return 1;
	} else {
		return 0;
	};
};

// Returns the chunk coordinates in which the given block coordinates reside,
// optionally also returning the coordinates normalized to the chunk dimensions.
export fn world_to_chunk(
	world: coords3D,
	out: nullable *coords3D = null,
) coords2D = {
	match (out) {
	case let c: *coords3D =>
		*c = (
			if (world.0 >= 0) world.0 % CHUNK_WIDTH
			else (CHUNK_WIDTH - 1) + world.0 % CHUNK_WIDTH,
			world.1,
			if (world.2 >= 0) world.2 % CHUNK_WIDTH
			else (CHUNK_WIDTH - 1) + world.2 % CHUNK_WIDTH,
		);
	case null => void;
	};

	return (
		world.0 / CHUNK_WIDTH - (if (world.0 < 0) 1 else 0),
		world.2 / CHUNK_WIDTH - (if (world.2 < 0) 1 else 0),
	);
};

// Returns the region coordinates in which the given chunk resides, optionally
// also returning the coordinates normalized to the region dimensions.
export fn chunk_to_region(
	chunk: coords2D,
	out: nullable *coords2D = null,
) coords2D = {
	match (out) {
	case let c: *coords2D =>
		*c = (
			if (chunk.0 >= 0) chunk.0 % REGION_WIDTH
			else (REGION_WIDTH - 1) + chunk.0 % REGION_WIDTH,
			if (chunk.1 >= 0) chunk.1 % REGION_WIDTH
			else (REGION_WIDTH - 1) + chunk.1 % REGION_WIDTH,
		);
	case null => void;
	};

	return (
		chunk.0 / REGION_WIDTH - (if (chunk.0 < 0) 1 else 0),
		chunk.1 / REGION_WIDTH - (if (chunk.1 < 0) 1 else 0),
	);
};
