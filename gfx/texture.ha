use gl;
use gl::{
	glBindTexture,
	glGenTextures,
	glGetError,
	glTexImage2D,
	glTexParameteri,
};
use sdl2;
use sdl2::image;

// A texture loaded onto the GPU.
export type texture = struct {
	id: uint,
	w: i32,
	h: i32,
};

// Loads a texture from the filesystem.
export fn texture_load(path: str) (texture | sdl2::error | glerror) = {
	let id = 0u;
	glGenTextures(1, &id);
	glBindTexture(gl::GL_TEXTURE_2D, id);

	const image = image::IMG_Load(path)?;
	defer sdl2::SDL_FreeSurface(image);

	assert(image.format.format == 0x16762004); // SDL_PIXELFORMAT_ABGR8888

	glTexImage2D(gl::GL_TEXTURE_2D, 0,
		gl::GL_BGRA: i32,
		image.w, image.h, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		image.pixels);
	glcheck()?;

	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST: i32);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST: i32);

	return texture {
		id = id,
		w = image.w,
		h = image.h,
	};
};

// Binds the specified texture.
export fn texture_bind(tex: *texture) void = {
	glBindTexture(gl::GL_TEXTURE_2D, tex.id);
	glcheck()!;
};
