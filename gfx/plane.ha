// Reference: https://github.com/ddevault/TrueCraft/wiki/Sky
use gl;
use gl::{
	glBindBuffer,
	glBufferData,
	glDisableVertexAttribArray,
	glDrawArrays,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGetUniformLocation,
	glUniform3f,
	glUniformMatrix4fv,
	glUseProgram,
	glVertexAttribPointer,
};
use glm;
use io;
use os;
use strings;
use types::c;

// Verticies of the unit plane in the x/z coordinate space
const unit_plane_verticies: [_]f32 = [
	-0.5, 0.0, -0.5,
	-0.5, 0.0,  0.5,
	 0.5, 0.0,  0.5,
	-0.5, 0.0, -0.5,
	 0.5, 0.0, -0.5,
	 0.5, 0.0,  0.5,
];

let unit_plane_vbo: uint = 0;
let plane_shader: uint = 0;
let plane_mvp: i32 = 0;
let plane_color: i32 = 0;

fn plane_init() void = {
	glGenBuffers(1, &unit_plane_vbo);
	glBindBuffer(gl::GL_ARRAY_BUFFER, unit_plane_vbo);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(unit_plane_verticies)): uintptr,
		&unit_plane_verticies[0],
		gl::GL_STATIC_DRAW);

	glcheck()!;

	const file = os::open("gfx/glsl/plane.vert")!;
	defer io::close(file)!;
	const data = io::drain(file)!;
	const vert = strings::fromutf8(data)!;
	defer free(vert);

	const file = os::open("gfx/glsl/plane.frag")!;
	defer io::close(file)!;
	const data = io::drain(file)!;
	const frag = strings::fromutf8(data)!;
	defer free(frag);

	const shader = shader_load(vert, frag)!;
	plane_shader = shader.id;
	plane_mvp = glGetUniformLocation(shader.id, c::nulstr("mvp\0"): *i8);
	plane_color = glGetUniformLocation(shader.id, c::nulstr("color_in\0"): *i8);
};

// Draws a unit plane with the given matrix applied.
// TODO: I feel like this is kind of lame? Should organize shaders better
export fn render_plane(mat: *glm::m4, color: glm::v3) void = {
	glUseProgram(plane_shader);

	glEnableVertexAttribArray(0);
	glBindBuffer(gl::GL_ARRAY_BUFFER, unit_plane_vbo);
	glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0, 0, null);
	defer glDisableVertexAttribArray(0);

	glUniformMatrix4fv(plane_mvp, 1, 0, &mat[0][0]);
	glUniform3f(plane_color, color[0], color[1], color[2]);
	glcheck()!;

	glDrawArrays(gl::GL_TRIANGLES, 0, 6);
};
