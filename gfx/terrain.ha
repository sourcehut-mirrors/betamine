use fs;
use gl;
use gl::{
	glActiveTexture,
	glUniform1i,
	glUniformMatrix4fv,
	glUniform3fv,
};
use glm;
use types::c;

type _terrain = struct {
	shader: uint,
	texture: texture,
	uniform: struct {
		mvp: i32,
		tex: i32,
	},
};

let terrain = _terrain { ... };

fn terrain_init() void = {
	const texture = texture_load("assets/terrain.png")!;
	const shader = shader_loadfrom(
		"gfx/glsl/terrain.vert",
		"gfx/glsl/terrain.frag")!;

	terrain.shader = shader;
	terrain.texture = texture;
	shader_uniforms(shader,
		("mvp\0", &terrain.uniform.mvp),
		("tex\0", &terrain.uniform.tex),
	);
};

// Binds the terrain shader to the OpenGL context with a provided terrain
// texture and model-view-projection matrix.
export fn terrain_bind(mvp: *glm::m4) void = {
	shader_bind(terrain.shader);

	glUniformMatrix4fv(terrain.uniform.mvp, 1, 0, &mvp[0][0]);

	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(&terrain.texture);
	glUniform1i(terrain.uniform.tex, 0);

	glcheck()!;
};
