use block;
use block::{flag, face};
use glm;
use world;

// A chunk mesh.
export type chunk_mesh = struct {
	// List of opaque verticies
	vert_opaque: []block::vertex,
	// List of translucent verticies
	vert_translucent: []block::vertex,
};

def CW = world::CHUNK_WIDTH: int;
def CH = world::CHUNK_HEIGHT: int;

// Offset for each of a block's neighbors
const neighbors: [_]int = [
	1,		// Top
	-1,		// Bottom
	-CH,		// North
	CH * CW,	// East
	CH,		// South
	-(CH * CW),	// West
];

fn getindex(x: int, y: int, z: int) int = x * (CW * CH) + z * CH + y;

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

fn fill_voxel_data(
	chunk: *world::chunk,
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

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(chunk: *world::chunk) chunk_mesh = {
	def FW = world::CHUNK_WIDTH: f32;
	def FH = world::CHUNK_HEIGHT: f32;

	let mesh = chunk_mesh { ... };

	let voxel = block::voxel { ... };

	let i = 0;
	for (let x = 0; x < CW; x += 1)
	for (let z = 0; z < CW; z += 1)
	for (let y = 0; y < CH; y += 1) {
		defer i += 1;

		const id = chunk.blocks[i];
		if (id == 0) continue;

		const block = block::blocks[id];
		fill_voxel_data(chunk, &voxel, i);

		let faces: face = 0;
		voxel_neighbors(chunk, &voxel, &faces, i, x, y, z);

		let vbo = &mesh.vert_opaque;
		if (block.flags & flag::TRANSLUCENT != 0) {
			vbo = &mesh.vert_translucent;
		};

		const pos: glm::v3 = [x: f32, y: f32, z: f32];
		block.model(block, &voxel, vbo, &pos, faces);
	};

	return mesh;
};

fn voxel_neighbors(
	chunk: *world::chunk,
	v: *block::voxel,
	faces: *face,
	ix: int,
	x: int,
	y: int,
	z: int,
) void = {
	const map = [
		(&v.neighbors.top,	face::T, y, CH - 1),
		(&v.neighbors.bottom,	face::B, y, 0),
		(&v.neighbors.north,	face::N, z, 0),
		(&v.neighbors.east,	face::E, x, CW - 1),
		(&v.neighbors.south,	face::S, z, CW - 1),
		(&v.neighbors.west,	face::W, x, 0),
	];

	for (let i = 0z; i < len(map); i += 1) {
		const (ptr, face, axis, edge) = map[i];

		// Unconditionally render faces on chunk edges
		if (axis == edge) {
			*ptr = 0;
			*faces |= 1 << face;
			continue;
		};

		const nix = ix + neighbors[i];
		const id = chunk.blocks[nix];
		*ptr = id;

		const block = block::blocks[id];
		if (block.flags & flag::NON_OCCLUDING != 0) {
			*faces |= 1 << face;
		};
	};
};
