use gl;
use gl::{
	glActiveTexture,
	glBindBuffer,
	glBindVertexArray,
	glBufferData,
	glDisable,
	glDrawArrays,
	glEnable,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGenVertexArrays,
	glGetUniformLocation,
	glUniform1i,
	glUniform4fv,
	glUniformMatrix4fv,
	glVertexAttribPointer,
};
use glm;
use types::c;

// Verticies of the unit plane in the x/z coordinate space
const unit_plane_verticies: [_]f32 = [
	// Position      UV
	-0.5, 0.0, -0.5, 0.0, 0.0,
	-0.5, 0.0,  0.5, 0.0, 1.0,
	 0.5, 0.0,  0.5, 1.0, 1.0,
	-0.5, 0.0, -0.5, 0.0, 0.0,
	 0.5, 0.0, -0.5, 1.0, 0.0,
	 0.5, 0.0,  0.5, 1.0, 1.0,
];

type _plane = struct {
	shader: uint,
	vao: uint,
	uniform: struct {
		mvp: i32,
		tex: i32,
		color: i32,
	},
};

let plane = _plane { ... };

fn plane_init() void = {
	plane.shader = shader_loadfrom(
		"gfx/glsl/plane.vert",
		"gfx/glsl/plane.frag")!;
	shader_uniforms(plane.shader,
		("mvp\0", &plane.uniform.mvp),
		("tex\0", &plane.uniform.tex),
		("color\0", &plane.uniform.color),
	);

	let vbo = 0u;
	glGenBuffers(1, &vbo);
	glGenVertexArrays(1, &plane.vao);

	glBindVertexArray(plane.vao);
	defer glBindVertexArray(0);

	glBindBuffer(gl::GL_ARRAY_BUFFER, vbo);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(unit_plane_verticies)): uintptr,
		&unit_plane_verticies[0],
		gl::GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0,
		(5 * size(f32)): i32,
		(0 * size(f32)): uintptr: *opaque);

	glEnableVertexAttribArray(1);
	glVertexAttribPointer(1, 2, gl::GL_FLOAT, 0,
		(5 * size(f32)): i32,
		(3 * size(f32)): uintptr: *opaque);

	glcheck()!;
};

// Draws a unit plane with the given matrix applied.
export fn render_plane(
	mat: *glm::m4,
	tex: *texture,
	color: *glm::v4,
) void = {
	shader_bind(plane.shader);

	glDisable(gl::GL_CULL_FACE);
	defer glEnable(gl::GL_CULL_FACE);
	glBindVertexArray(plane.vao);
	defer glBindVertexArray(0);

	glUniform4fv(plane.uniform.color, 1, &color[0]);
	glUniformMatrix4fv(plane.uniform.mvp, 1, 0, &mat[0][0]);

	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(tex);
	glUniform1i(plane.uniform.tex, 0);
	glcheck()!;

	glDrawArrays(gl::GL_TRIANGLES, 0, 6);
};
