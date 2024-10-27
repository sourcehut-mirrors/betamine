use glm;
use world;

// A vertex in a chunk mesh.
export type chunk_vertex = struct @packed {
	pos: glm::v3,
	color: glm::v3,
	uv: glm::v2,
};

// A chunk mesh.
export type chunk_mesh = struct {
	// List of opaque verticies
	vert_opaque: []chunk_vertex,
	// List of transparent verticies
	vert_transp: []chunk_vertex,
};

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(chunk: *world::chunk) chunk_mesh = {
	abort(); // TODO
};
