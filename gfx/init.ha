use gl;
use gl::{
	glBlendFunc,
	glDepthFunc,
	glEnable,
	glViewport,
};
use glm;
use sdl2;

let dims = (0i32, 0i32);
let ortho = glm::M4_ZERO;

// Initiailze the graphics system, providing the game's SDL window as a
// reference for the graphics subsystem.
export fn init(width: i32, height: i32) void = {
	dims = (width, height);
	glm::ortho(&ortho, 0.0, width: f32, height: f32, 0.0, -1.0, 1.0);

	gl::load();

	glViewport(0, 0, width, height);

	glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);
	glEnable(gl::GL_BLEND);

	glDepthFunc(gl::GL_LESS);
	glEnable(gl::GL_DEPTH_TEST);
	glEnable(gl::GL_CULL_FACE);

	// Load shader meta
	fog_init();
	shaders_init();

	// Initialize subsystems
	font_init();
	plane_init();
	sky_init();
	sprites_init();
	terrain_init();
};
