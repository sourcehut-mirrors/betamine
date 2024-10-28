use block;
use engine;
use gl;
use gl::{
	glGenBuffers,
	glBindBuffer,
	glBufferData,
	glDisableVertexAttribArray,
	glEnableVertexAttribArray,
	glVertexAttribPointer,
};
use world;

// Chunk mesh.
export type chunk_mesh = struct {
	opaque_vbo: uint,
	nopaque: size,
	transparent_vbo: uint,
	ntransparent: size,
};

// Uploads [[engine::chunk_mesh]] geography to the GPU. The
// [[engine::chunk_mesh]] can be freed following this operation.
export fn chunk_init(mesh: *engine::chunk_mesh) chunk_mesh = {
	let vbo = [0u, 0u];
	glGenBuffers(2, &vbo[0]);
	glBindBuffer(gl::GL_ARRAY_BUFFER, vbo[0]);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(block::vertex) * len(mesh.vert_opaque)): uintptr,
		&mesh.vert_opaque[0],
		gl::GL_STATIC_DRAW);
	glcheck()!;

	if (len(mesh.vert_translucent) != 0) {
		glBindBuffer(gl::GL_ARRAY_BUFFER, vbo[1]);
		glBufferData(gl::GL_ARRAY_BUFFER,
			(size(block::vertex) * len(mesh.vert_translucent)): uintptr,
			&mesh.vert_translucent[0],
			gl::GL_STATIC_DRAW);
		glcheck()!;
	};

	return chunk_mesh {
		opaque_vbo = vbo[0],
		nopaque = len(mesh.vert_opaque),
		transparent_vbo = vbo[1],
		ntransparent = len(mesh.vert_translucent),
	};
};

// Binds a chunk VBO.
export fn chunk_begin(mesh: *chunk_mesh, transparent: bool) void = {
	let vbo = if (transparent) {
		yield mesh.transparent_vbo;
	} else {
		yield mesh.opaque_vbo;
	};

	glBindBuffer(gl::GL_ARRAY_BUFFER, vbo);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0,
		(8 * size(f32)): i32,
		(0 * size(f32)): uintptr: *opaque);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, gl::GL_FLOAT, 0,
		(8 * size(f32)): i32,
		(3 * size(f32)): uintptr: *opaque);

	glEnableVertexAttribArray(2);
	glVertexAttribPointer(2, 3, gl::GL_FLOAT, 0,
		(8 * size(f32)): i32,
		(5 * size(f32)): uintptr: *opaque);
};

// Cleans up the chunk VBO.
export fn chunk_end(mesh: *chunk_mesh) void = {
	glDisableVertexAttribArray(0);
	glDisableVertexAttribArray(1);
	glDisableVertexAttribArray(2);
};
