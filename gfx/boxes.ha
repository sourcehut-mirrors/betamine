use gl;
use gl::{
	glBindBuffer,
	glBindVertexArray,
	glBindVertexArray,
	glBufferData,
	glDepthFunc,
	glDrawArrays,
	glEnable,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGenVertexArrays,
	glGenVertexArrays,
	glLineWidth,
	glUniform4fv,
	glUniformMatrix4fv,
	glVertexAttribPointer,
};
use glm;
use types::c;

type _boxes = struct {
	shader: uint,
	vao: uint,
	uniform: struct {
		mvp: i32,
		color: i32,
	},
};

let boxes = _boxes { ... };

const lines: [_]glm::v3 = [
	// Top face
	[ 0.5,  0.5,  0.5],
	[ 0.5,  0.5, -0.5],

	[ 0.5,  0.5, -0.5],
	[-0.5,  0.5, -0.5],

	[-0.5,  0.5, -0.5],
	[-0.5,  0.5,  0.5],

	[-0.5,  0.5,  0.5],
	[ 0.5,  0.5,  0.5],

	// Bottom face
	[ 0.5, -0.5,  0.5],
	[ 0.5, -0.5, -0.5],

	[ 0.5, -0.5, -0.5],
	[-0.5, -0.5, -0.5],

	[-0.5, -0.5, -0.5],
	[-0.5, -0.5,  0.5],

	[-0.5, -0.5,  0.5],
	[ 0.5, -0.5,  0.5],

	// Lateral corners
	[ 0.5,  0.5,  0.5],
	[ 0.5, -0.5,  0.5],

	[-0.5,  0.5,  0.5],
	[-0.5, -0.5,  0.5],

	[-0.5,  0.5, -0.5],
	[-0.5, -0.5, -0.5],

	[ 0.5,  0.5, -0.5],
	[ 0.5, -0.5, -0.5],
];

fn boxes_init() void = {
	boxes.shader = shader_loadfrom(
		"gfx/glsl/boxes.vert",
		"gfx/glsl/boxes.frag")!;
	shader_uniforms(boxes.shader,
		("mvp\0", &boxes.uniform.mvp),
		("color\0", &boxes.uniform.color),
	);

	let vbo = 0u;
	glGenBuffers(1, &vbo);
	glGenVertexArrays(1, &boxes.vao);

	glBindVertexArray(boxes.vao);
	defer glBindVertexArray(0);

	glBindBuffer(gl::GL_ARRAY_BUFFER, vbo);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(glm::v3) * len(lines)): uintptr,
		&lines[0],
		gl::GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 3, gl::GL_FLOAT, 0,
		size(glm::v3): i32, null: *opaque);

	glEnable(gl::GL_LINE_SMOOTH);

	glcheck()!;
};

// Draws the outline of a unit cube at the origin.
export fn render_box(
	mat: *glm::m4,
	color: *glm::v4,
) void = {
	shader_bind(boxes.shader);

	glBindVertexArray(boxes.vao);
	defer glBindVertexArray(0);

	glUniform4fv(boxes.uniform.color, 1, &color[0]);
	glUniformMatrix4fv(boxes.uniform.mvp, 1, 0, &mat[0][0]);

	glDrawArrays(gl::GL_LINES, 0, len(lines): i32);
};
