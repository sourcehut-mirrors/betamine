use block;
use engine;
use gl;
use gl::{
	glBindBuffer,
	glBindVertexArray,
	glBufferData,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGenVertexArrays,
	glVertexAttribPointer,
};
use world;

// Chunk mesh.
export type chunk_mesh = struct {
	opaque_vao: uint,
	nopaque: size,
	transparent_vao: uint,
	ntransparent: size,
};

// Uploads [[engine::chunk_mesh]] geography to the GPU. The
// [[engine::chunk_mesh]] can be freed following this operation.
export fn chunk_init(mesh: *engine::chunk_mesh) chunk_mesh = {
	let vbo = [0u, 0u];
	let vao = [0u, 0u];
	glGenBuffers(2, &vbo[0]);
	glGenVertexArrays(2, &vao[0]);
	if (len(mesh.vert_opaque) != 0) {
		glBindVertexArray(vao[0]);
		defer glBindVertexArray(0);

		glBindBuffer(gl::GL_ARRAY_BUFFER, vbo[0]);
		glBufferData(gl::GL_ARRAY_BUFFER,
			(size(block::vertex) * len(mesh.vert_opaque)): uintptr,
			&mesh.vert_opaque[0],
			gl::GL_STATIC_DRAW);

		glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(0 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(0);

		glVertexAttribPointer(1, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(3 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(1);

		glVertexAttribPointer(2, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(6 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(2);

		glVertexAttribPointer(3, 2, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(9 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(3);

		glcheck()!;
	};

	if (len(mesh.vert_translucent) != 0) {
		glBindVertexArray(vao[1]);
		defer glBindVertexArray(0);

		glBindBuffer(gl::GL_ARRAY_BUFFER, vbo[1]);
		glBufferData(gl::GL_ARRAY_BUFFER,
			(size(block::vertex) * len(mesh.vert_translucent)): uintptr,
			&mesh.vert_translucent[0],
			gl::GL_STATIC_DRAW);
		glcheck()!;

		glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(0 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(0);

		glVertexAttribPointer(1, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(3 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(1);

		glVertexAttribPointer(2, 3, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(6 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(2);

		glVertexAttribPointer(3, 2, gl::GL_FLOAT, 0,
			(11 * size(f32)): i32,
			(9 * size(f32)): uintptr: *opaque);
		glEnableVertexAttribArray(3);

		glcheck()!;
	};

	return chunk_mesh {
		opaque_vao = vao[0],
		nopaque = len(mesh.vert_opaque),
		transparent_vao = vao[1],
		ntransparent = len(mesh.vert_translucent),
	};
};

// Binds a chunk VBO.
export fn chunk_begin(mesh: *chunk_mesh, transparent: bool) void = {
	if (transparent) {
		glBindVertexArray(mesh.transparent_vao);
	} else {
		glBindVertexArray(mesh.opaque_vao);
	};
};

// Cleans up the chunk VBO.
export fn chunk_end(mesh: *chunk_mesh) void = {
	glBindVertexArray(0);
};
