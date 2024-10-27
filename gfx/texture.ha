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
	const surf = image::IMG_Load(path)?;
	defer sdl2::SDL_FreeSurface(surf);
	return texture_fromsurf(surf)?;
};

// Similar to [[texture_load]] but the caller provides an [[sdl2::SDL_Surface]]
// to load from.
export fn texture_fromsurf(surf: *sdl2::SDL_Surface) (texture | glerror) = {
	assert(surf.format.format == 0x16762004); // SDL_PIXELFORMAT_ABGR8888

	let id = 0u;
	glGenTextures(1, &id);
	glBindTexture(gl::GL_TEXTURE_2D, id);

	glTexImage2D(gl::GL_TEXTURE_2D, 0,
		gl::GL_BGRA: i32,
		surf.w, surf.h, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		surf.pixels);
	glcheck()?;

	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MAG_FILTER, gl::GL_NEAREST: i32);
	glTexParameteri(gl::GL_TEXTURE_2D,
		gl::GL_TEXTURE_MIN_FILTER, gl::GL_NEAREST: i32);

	return texture {
		id = id,
		w = surf.w,
		h = surf.h,
	};
};

// Binds the specified texture.
export fn texture_bind(tex: *texture) void = {
	glBindTexture(gl::GL_TEXTURE_2D, tex.id);
	glcheck()!;
};
