use fs;
use gl;
use gl::{
	glActiveTexture,
	glGetUniformLocation,
	glUniform1i,
	glUniformMatrix4fv,
};
use glm;
use types::c;

// Terrain shader.
export type terrain = struct {
	shader,
	texture: texture,
	uniform: struct {
		mvp: i32,
		tex: i32,
	},
};

// Loads the terrain shader.
export fn load_terrain() (terrain | error) = {
	const shader = shader_loadfrom(
		"gfx/glsl/terrain.vert",
		"gfx/glsl/terrain.frag")?;
	const umvp = glGetUniformLocation(shader.id, c::nulstr("mvp\0"): *i8);
	const utex = glGetUniformLocation(shader.id, c::nulstr("tex\0"): *i8);

	const texture = texture_load("assets/terrain.png")?;

	return terrain {
		id = shader.id,
		texture = texture,
		uniform = struct {
			mvp: i32 = umvp,
			tex: i32 = utex,
		},
	};
};

// Binds the terrain shader to the OpenGL context with a provided terrain
// texture and model-view-projection matrix.
export fn terrain_bind(
	shader: *terrain,
	mvp: *glm::m4,
) void = {
	shader_bind(shader);

	glUniformMatrix4fv(shader.uniform.mvp, 1, 0, &mvp[0][0]);

	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(&shader.texture);
	glUniform1i(shader.uniform.tex, 0);

	glcheck()!;
};
