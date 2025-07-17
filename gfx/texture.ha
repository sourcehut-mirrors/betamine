use gl;
use gl::{
	glBindTexture,
	glGenTextures,
	glGetError,
	glTexImage2D,
	glTexParameteri,
};
use sdl3;
use sdl3::image;
use types::c;

// Texture of a 1x1 opaque white pixel
export let white1x1 = texture { ... };

// A texture loaded onto the GPU.
export type texture = struct {
	id: uint,
	w: i32,
	h: i32,
};

fn textures_init() void = {
	let id = 0u;
	glGenTextures(1, &id);
	glBindTexture(gl::GL_TEXTURE_2D, id);

	let pixel: [4]u8 = [0xFF...];
	glTexImage2D(gl::GL_TEXTURE_2D, 0,
		gl::GL_RGBA: i32, 1, 1, 0,
		gl::GL_RGBA, gl::GL_UNSIGNED_BYTE,
		&pixel);
	glcheck()!;

	white1x1 = texture { id = id, w = 1, h = 1 };
};

// Loads a texture from the filesystem.
export fn texture_load(path: str) (texture | sdl3::error | glerror) = {
	const path = c::fromstr(path)!;
	defer free(path);
	const surf = image::Load(path);
	sdl3::get_error()?;
	defer sdl3::DestroySurface(surf);
	return texture_fromsurf(surf as *sdl3::Surface)?;
};

// Similar to [[texture_load]] but the caller provides an [[sdl3::Surface]]
// to load from.
export fn texture_fromsurf(surf: *sdl3::Surface) (texture | glerror) = {
	assert(surf.format == sdl3::PixelFormat::ABGR8888);

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
