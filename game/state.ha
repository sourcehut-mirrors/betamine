use gfx;
use glm;
use net::mc;
use sdl2;
use world;

// Game state type.
export type state = struct {
	quit: bool,

	// Network state
	conn: *mc::conn,
	entity_id: int,

	// SDL window
	win: *sdl2::SDL_Window,
	width: uint,
	height: uint,

	// Game modules
	modules: []*module,
	layers: []*layer,

	// Input state
	input: input_state,

	// Player state
	camera: gfx::camera,
	vp: glm::m4,
	frustrum: [6]glm::v4,

	// Game state
	world: world::world,

	// Number of game ticks ellapsed
	ticks: u64,

	// Debug info

	// Show debug overlay?
	debug: bool,

	// Total number of frames rendered
	frames: uint,
	// Monotonic timestamp of current frame, ms
	frame_time: u32,
	// Monotonic timestamp of previous frame, ms
	prev_frame_time: u32,

	// Render stats
	nvertex: size,
	nchunk: size,
	chunks_rendered: size,
};

// Update callback.
export type updatefunc = fn(mod: *module, state: *state) void;

fn no_update(mod: *module, state: *state) void = void;

// Game module which runs an update on every frame.
export type module = struct {
	update: *updatefunc,
};

// Draw callback.
export type drawfunc = fn(layer: *layer, state: *state) void;

// Drawable game layer.
export type layer = struct {
	module,
	draw: *drawfunc,
};
