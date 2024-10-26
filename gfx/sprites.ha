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
	tex: *texture,
	model: *glm::m4,
	clip: glm::v4 = [0.0, 0.0, 0.0, 0.0],
	color: glm::v4 = [1.0, 1.0, 1.0, 1.0],
) void = {
	let noclip = true;
	for (let v .. clip) {
		if (v != 0.0) {
			noclip = false;
			break;
		};
	};

	// Set default clip to 0..1 if unspecified
	if (noclip) {
		clip = [0.0, 0.0, 1.0, 1.0];
	} else {
		clip[0] /= tex.w: f32;
		clip[1] /= tex.h: f32;
		clip[2] /= tex.w: f32;
		clip[3] /= tex.h: f32;
	};

	shader_bind(&sprite);

	glEnableVertexAttribArray(0);
	glBindBuffer(gl::GL_ARRAY_BUFFER, sprite.vbo);
	glVertexAttribPointer(0, 4, gl::GL_FLOAT, 0, 0, null);
	defer glDisableVertexAttribArray(0);

	const (w, h) = dims;
	let ortho = glm::M4_ZERO;
	glm::ortho(&ortho, 0.0, w: f32, h: f32, 0.0, -1.0, 1.0);
	const mp = glm::m4_mul(&ortho, model);

	glUniformMatrix4fv(sprite.uniform.mp, 1, 0, &mp[0][0]);
	glUniform4fv(sprite.uniform.color, 1, &color[0]);
	glUniform4fv(sprite.uniform.clip, 1, &clip[0]);
	glcheck()!;

	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(tex);
	glUniform1i(sprite.uniform.image, 0);
	glcheck()!;

	glDrawArrays(gl::GL_TRIANGLES, 0, 6);
};
