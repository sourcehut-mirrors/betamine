use glm;
use gl;
use gl::{
	glActiveTexture,
	glBindBuffer,
	glBindVertexArray,
	glBufferData,
	glDisable,
	glDisableVertexAttribArray,
	glDrawArrays,
	glEnable,
	glEnableVertexAttribArray,
	glGenBuffers,
	glGenVertexArrays,
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
	shader: uint,
	vao: uint,
	uniform: struct {
		clip: i32,
		color: i32,
		image: i32,
		mp: i32,
	},
};

let sprite = _sprite { ... };

fn sprites_init() void = {
	const shader = shader_loadfrom(
		"gfx/glsl/sprite.vert", "gfx/glsl/sprite.frag")!;
	sprite.shader = shader;
	shader_uniforms(shader,
		("clip\0", &sprite.uniform.clip),
		("sprite_color\0", &sprite.uniform.color),
		("image\0", &sprite.uniform.image),
		("mp\0", &sprite.uniform.mp),
	);

	let vbo = 0u;
	glGenBuffers(1, &vbo);
	glGenVertexArrays(1, &sprite.vao);

	glBindVertexArray(sprite.vao);
	defer glBindVertexArray(0);

	glBindBuffer(gl::GL_ARRAY_BUFFER, vbo);
	glBufferData(gl::GL_ARRAY_BUFFER,
		(size(f32) * len(sprite_vert)): uintptr,
		&sprite_vert[0],
		gl::GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 4, gl::GL_FLOAT, 0, 0, null);

	glcheck()!;
};

// Draws a sprite.
//
// The model matrix can be used to scale, rotate, or translate the sprite. Note
// that the sprite is scaled to the pixel dimensions of the texture (factoring
// in the clip, if specified), and the model matrix is applied on top of this
// initial scale factor.
//
// clip, if specified, gives the [x, y, w, h] coordinates to clip from the
// source texture. color, if specified, is multiplied to each pixel.
export fn sprite_draw(
	tex: *texture,
	model: *glm::m4,
	clip: glm::v4 = [0.0, 0.0, 0.0, 0.0],
	color: glm::v4 = [1.0, 1.0, 1.0, 1.0],
) void = {
	shader_bind(sprite.shader);

	glDisable(gl::GL_DEPTH_TEST);
	defer glEnable(gl::GL_DEPTH_TEST);

	glBindVertexArray(sprite.vao);
	defer glBindVertexArray(0);

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

	let mm = glm::M4_IDENT;
	glm::scale(&mm, &glm::v3_new(
		tex.w: f32 * clip[2],
		tex.h: f32 * clip[3],
		1.0,
	));
	mm = glm::m4_mul(model, &mm);

	const model_proj = glm::m4_mul(&ortho, &mm);
	glUniformMatrix4fv(sprite.uniform.mp, 1, 0, &model_proj[0][0]);
	glUniform4fv(sprite.uniform.color, 1, &color[0]);
	glUniform4fv(sprite.uniform.clip, 1, &clip[0]);
	glActiveTexture(gl::GL_TEXTURE0);
	texture_bind(tex);
	glUniform1i(sprite.uniform.image, 0);
	glcheck()!;

	glDrawArrays(gl::GL_TRIANGLES, 0, 6);
};
