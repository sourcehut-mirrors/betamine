use block;
use block::{flag, face};
use glm;
use world;
// XXX TEMP
use fmt;

// A chunk mesh.
export type chunk_mesh = struct {
	// List of opaque verticies
	vert_opaque: []block::vertex,
	// List of translucent verticies
	vert_translucent: []block::vertex,
};

def CW = world::CHUNK_WIDTH: int;
def CH = world::CHUNK_HEIGHT: int;

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(
	world: *world::world,
	chunk: const *world::chunk,
	out: *chunk_mesh,
) void = {
	assert(len(out.vert_opaque) == 0);
	assert(len(out.vert_translucent) == 0);

	def FW = world::CHUNK_WIDTH: f32;
	def FH = world::CHUNK_HEIGHT: f32;

	const coords = chunk.coords;
	const neighboring_chunks: [4]const *world::chunk = [
		world::get_chunk(world, (coords.0, coords.1 - 1))!, // North
		world::get_chunk(world, (coords.0, coords.1 + 1))!, // South
		world::get_chunk(world, (coords.0 - 1, coords.1))!, // West
		world::get_chunk(world, (coords.0 + 1, coords.1))!, // East
	];

	let i = 0;
	let voxel = block::voxel { ... };
	for (let x = 0; x < CW; x += 1)
	for (let z = 0; z < CW; z += 1)
	for (let y = 0; y < CH; y += 1) {
		defer i += 1;

		const id = chunk.blocks[i];
		if (id == 0) continue;

		const block = block::blocks[id];
		fill_voxel_data(chunk, &voxel, i);

		let faces: face = 0;
		let coords: world::coords3D = (x, y, z);
		voxel_neighbors(chunk, &neighboring_chunks,
			&voxel, &faces, &coords, i);

		let vbo = &out.vert_opaque;
		if (block.flags & flag::TRANSLUCENT != 0) {
			vbo = &out.vert_translucent;
		};

		const pos: glm::v3 = [x: f32, y: f32, z: f32];
		block.model(block, &voxel, vbo, &pos, faces);
	};
};

fn fill_voxel_data(
	chunk: const *world::chunk,
	vox: *block::voxel_data,
	ix: int,
) void = {
	const hi = ix / 2;
	const ho = (ix % 2): u8 * 4;
	vox.id = chunk.blocks[ix];
	vox.data = chunk.metadata[hi] >> ho & 0xF;
	vox.sky_light = chunk.sky_light[hi] >> ho & 0xF;
	vox.block_light = chunk.block_light[hi] >> ho & 0xF;
};

// Offset for each of a block's neighbors
const neighbors: [_]int = [
	1,		// Top
	-1,		// Bottom
	-CH,		// North
	CH,		// South
	-(CH * CW),	// West
	CH * CW,	// East
];

const neighbors_coordwise: [_]world::coords2D = [
	(0, -1), // North
	(0,  1), // South
	(-1, 0), // West
	( 1, 0), // East
];

fn voxel_neighbors(
	chunk: const *world::chunk,
	neighbor_chunks: *[4]const *world::chunk,
	v: *block::voxel,
	faces: *face,
	coords: *world::coords3D,
	ix: int,
) void = {
	const map = [
		(&v.neighbors.top,	face::T, coords.1, CH - 1),
		(&v.neighbors.bottom,	face::B, coords.1, 0),
		(&v.neighbors.north,	face::N, coords.2, 0),
		(&v.neighbors.south,	face::S, coords.2, CW - 1),
		(&v.neighbors.west,	face::W, coords.0, 0),
		(&v.neighbors.east,	face::E, coords.0, CW - 1),
	];

	for (let i = 0z; i < len(map); i += 1) {
		const (ptr, f, axis, edge) = map[i];

		let chunk = chunk;
		let nix = ix + neighbors[i];

		if (axis == edge && (f == face::T || f == face::B)) {
			*ptr = block::voxel_data { block_light = 15, ... };
			*faces |= 1 << f;
			continue;
		};

		if (axis == edge) {
			chunk = neighbor_chunks[f - 2];
			let c: world::coords3D = (
				coords.0 + neighbors_coordwise[f - 2].0,
				coords.1,
				coords.2 + neighbors_coordwise[f - 2].1,
			);
			c.0 = c.0 % CW + (if (c.0 < 0) CW else 0);
			c.2 = c.2 % CW + (if (c.2 < 0) CW else 0);
			nix = c.0 * (CW * CH) + c.2 * CH + c.1;
		};

		fill_voxel_data(chunk, ptr, nix);

		const block = block::blocks[ptr.id];
		if (block.flags & flag::NON_OCCLUDING != 0) {
			*faces |= 1 << f;
		};
	};
};

@test fn neighbors() void = {
	// Double checking my work here...
	let x = 8;
	let y = 9;
	let z = 10;

	const ix_base = getindex(x, y, z);
	const ix_top = getindex(x, y + 1, z);
	const ix_bottom = getindex(x, y - 1, z);
	const ix_north = getindex(x, y, z - 1);
	const ix_east = getindex(x + 1, y, z);
	const ix_south = getindex(x, y, z + 1);
	const ix_west = getindex(x - 1, y, z);

	assert(ix_top == ix_base + neighbors[0]);
	assert(ix_bottom == ix_base + neighbors[1]);
	assert(ix_north == ix_base + neighbors[2]);
	assert(ix_east == ix_base + neighbors[3]);
	assert(ix_south == ix_base + neighbors[4]);
	assert(ix_west == ix_base + neighbors[5]);
};

fn getindex(x: int, y: int, z: int) int = x * (CW * CH) + z * CH + y;
