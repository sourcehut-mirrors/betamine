use fs;
use gl;
use io;
use sdl2;

// An OpenGL error.
export type glerror = !gl::gl_enum;

// Tests for an OpenGL error. Only returns the last error.
export fn glcheck() (void | glerror) = {
	let err = gl::glGetError();
	if (err == gl::GL_NO_ERROR) {
		return;
	};
	return err: glerror;
};

// Possible errors produced by the game engine.
export type error = !(fs::error | io::error | sdl2::error | glerror);
