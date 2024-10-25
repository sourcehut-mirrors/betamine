use gl;
use gl::{
	glBindTexture,
	glGenTextures,
	glGetError,
	glTexImage2D,
	glTexParameteri,
};
use sdl2::image;

// Returns OpenGL texture ID
fn load_texture(path: str) uint = {
	let tex_id = 0u;
	glGenTextures(1, &tex_id);
	glBindTexture(gl::GL_TEXTURE_2D, tex_id);

	const image = image::IMG_Load(path)!;

	// TODO: Free surface
	glTexImage2D(gl::GL_TEXTURE_2D, 0,
		gl::GL_BGRA: i32,
		image.w: i32, image.h: i32, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		image.pixels);
	assert(glGetError() == gl::GL_NO_ERROR);

	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST: i32);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST: i32);

	return tex_id;
};
