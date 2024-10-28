use block;
use glm;
use world;

// A chunk mesh.
export type chunk_mesh = struct {
	// List of opaque verticies
	vert_opaque: []block::vertex,
	// List of transparent verticies
	vert_transp: []block::vertex,
};

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(chunk: *world::chunk) chunk_mesh = {
	let mesh = chunk_mesh { ... };

	let i = 0u;
	for (let x = 0u; x < world::CHUNK_WIDTH; x += 1)
	for (let z = 0u; z < world::CHUNK_WIDTH; z += 1)
	for (let y = 0u; y < world::CHUNK_HEIGHT; y += 1) {
		defer i += 1;
		const id = chunk.blocks[i];
	};

	return mesh;
};
