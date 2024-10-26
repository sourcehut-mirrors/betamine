use gl;
use gl::{
	glBlendFunc,
	glEnable,
};

// Initiailze the graphics system.
export fn init() void = {
	glEnable(gl::GL_DEPTH_TEST);
	glEnable(gl::GL_BLEND);
	//glEnable(gl::GL_CULL_FACE); // TODO: Fix cube model
	glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

	// Initialize subsystems
	plane_init();
	sprites_init();
	font_init();
};
