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
	def FW = world::CHUNK_WIDTH: f32;
	def FH = world::CHUNK_HEIGHT: f32;

	let mesh = chunk_mesh { ... };

	let i = 0u;
	for (let x: f32 = 0.0; x < FW; x += 1.0)	// x
	for (let z: f32 = 0.0; z < FW; z += 1.0)	// z
	for (let y: f32 = 0.0; y < FH; y += 1.0) {	// y
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

		const pos: glm::v3 = [x, y, z];
		block.model(block, vbo, &pos, block::faces::ALL);
	};

	return mesh;
};
