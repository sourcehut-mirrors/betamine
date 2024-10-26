use gl;
use gl::{
	glBlendFunc,
	glEnable,
	glViewport,
};
use sdl2;

let dims = (0i32, 0i32);

// Initiailze the graphics system, providing the game's SDL window as a
// reference for the graphics subsystem.
export fn init(width: i32, height: i32) void = {
	dims = (width, height);

	gl::load();

	glViewport(0, 0, width, height);

	glEnable(gl::GL_DEPTH_TEST);
	glEnable(gl::GL_BLEND);
	//glEnable(gl::GL_CULL_FACE); // TODO: Fix cube model
	glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

	// Initialize subsystems
	plane_init();
	sprites_init();
	font_init();
};
