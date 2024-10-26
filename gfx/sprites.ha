use glm;
use gl;
use gl::{
	glActiveTexture,
	glBindBuffer,
	glBufferData,
	glDisableVertexAttribArray,
	glDrawArrays,
	glEnableVertexAttribArray,
	glGenBuffers,
	glUniform1i,
	glUniform4fv,
	glUniformMatrix4fv,
	glVertexAttribPointer,
};
use types::c;

const sprite_vert: [_]f32 = [
        // pos    // tex
        0.0, 1.0, 0.0, 1.0,
        1.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 0.0,

        0.0, 1.0, 0.0, 1.0,
        1.0, 1.0, 1.0, 1.0,
        1.0, 0.0, 1.0, 0.0,
];

type _sprite = struct {
	shader,
	vbo: uint,
	uniform: struct {
		clip: i32,
		color: i32,
		image: i32,
		mp: i32,
	},
};

let sprite = _sprite { ... };

fn sprites_init() void = {
	const shader = shader_loadfrom("gfx/glsl/sprite.vert", "gfx/glsl/sprite.frag")!;
	sprite.id = shader.id;
	shader_uniforms(&sprite,
		("clip\0", &sprite.uniform.clip),
		("sprite_color\0", &sprite.uniform.color),
		("image\0", &sprite.uniform.image),
		("mp\0", &sprite.uniform.mp),
	);

	glGenBuffers(1, &sprite.vbo);
	glBindBuffer(gl::GL_ARRAY_BUFFER, sprite.vbo);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(sprite_vert)): uintptr,
		&sprite_vert[0],
		gl::GL_STATIC_DRAW);
	glcheck()!;
};

// Draws a sprite.
export fn sprite_draw(
	texture: *texture,
	proj: *glm::m4,
	model: *glm::m4,
	clip: glm::v4 = [0.0, 0.0, 1.0, 1.0],
	color: glm::v4 = [1.0, 1.0, 1.0, 1.0],
) void = {
	shader_bind(&sprite);

	glEnableVertexAttribArray(0);
	glBindBuffer(gl::GL_ARRAY_BUFFER, sprite.vbo);
	glVertexAttribPointer(0, 4, gl::GL_FLOAT, 0, 0, null);
	defer glDisableVertexAttribArray(0);

	const mat = glm::m4_mul(proj, model);
	glUniformMatrix4fv(sprite.uniform.mp, 1, 0, &mat[0][0]);
	glUniform4fv(sprite.uniform.color, 1, &color[0]);
	glUniform4fv(sprite.uniform.clip, 1, &clip[0]);
	glcheck()!;

	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(texture);
	glUniform1i(sprite.uniform.image, 0);
	glcheck()!;

	glDrawArrays(gl::GL_TRIANGLES, 0, 6);
};
