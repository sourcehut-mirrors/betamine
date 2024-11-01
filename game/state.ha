use gfx;
use sdl2;

// Game state type.
export type state = struct {
	quit: bool,

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

	// Number of game ticks ellapsed
	ticks: u64,

	// Total number of frames rendered
	frames: uint,
	// Monotonic timestamp of current frame, ms
	frame_time: u32,
	// Monotonic timestamp of previous frame, ms
	prev_frame_time: u32,

	// Show debug overlay?
	debug: bool,
};

// Update callback.
export type updatefunc = fn(mod: *module, state: *state) void;

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
