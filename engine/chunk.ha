use block;
use glm;
use world;

// A chunk mesh.
export type chunk_mesh = struct {
	// List of opaque verticies
	vert_opaque: []block::vertex,
	// List of translucent verticies
	vert_translucent: []block::vertex,
};

// Generate meshes for a given [[world::chunk]].
export fn chunk_genmesh(chunk: *world::chunk) chunk_mesh = {
	let mesh = chunk_mesh { ... };

	let i = 0u;
	let pos: glm::v3 = glm::V3_ZERO;
	//def FW = world::CHUNK_WIDTH: f32;
	//def FH = world::CHUNK_HEIGHT: f32;
	def FW = 1.0;
	def FH = 1.0;
	for (pos[0] < FW; pos[0] += 1.0)
	for (pos[2] < FW; pos[2] += 1.0)
	for (pos[1] < FH; pos[1] += 1.0) {
		defer i += 1;
		const id = chunk.blocks[i];
		if (id == 0) continue;

		const block = match (block::blocks[id]) {
		case let b: *block::block =>
			yield b;
		case null => continue;
		};

		let vbo = &mesh.vert_opaque;
		if (block.flags & block::flag::TRANSLUCENT != 0) {
			vbo = &mesh.vert_translucent;
		};
		block.model(block, vbo, &pos, block::faces::ALL);
	};

	return mesh;
};
