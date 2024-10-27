use glm;
use world;

export def Q = world::CHUNK_WIDTH + 1;
export def Q2 = Q * Q;
export def NVERTEX = Q2 * (world::CHUNK_HEIGHT + 1);

// Shared vertex position grid for all chunks
//
// Vertex for block index <X,Y,Z> is at
//
// let Q = CHUNK_WIDTH + 1
//
// IX = <Y × Q² + Z × Q + X>
let chunk_vpos: [NVERTEX]glm::v3 = [[0.0, 0.0, 0.0]...];

@init fn chunk_init() void = {
	for (let y = 0z; y < world::CHUNK_HEIGHT + 1; y += 1)
	for (let z = 0z; z < world::CHUNK_WIDTH + 1; z += 1)
	for (let x = 0z; x < world::CHUNK_WIDTH + 1; x += 1) {
		let ix = y * Q2 + z * Q + x;
		chunk_vpos[ix] = [x: f32, y: f32, z: f32];
	};
};

// A vertex in a chunk mesh.
export type chunk_vertex = struct @packed {
	// Index of the vertex position in the common vertex buffer
	pos: uint,
	// Texture coordinates
	uv: glm::v2,
	// Vertex color (TODO: use v2 for temp/downfall)
	color: glm::v3,
};

// A chunk mesh.
export type chunk_mesh = struct {
	// List of vertex positions, shared among all chunks
	position: *[NVERTEX]glm::v3,
	// List of opaque verticies
	vert_opaque: []chunk_vertex,
	// List of transparent verticies
	vert_transp: []chunk_vertex,
	// List of vertex indicies for each polygon
	polys: []int,
};

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(chunk: *world::chunk) chunk_mesh = {
	abort(); // TODO
};
