use engine;
use gfx;
use os;
use sdl2;
use world;

// Initializes the game engine.
export fn init(win: *sdl2::SDL_Window) *state = {
	let w = 0, h = 0;
	sdl2::SDL_GL_GetDrawableSize(win, &w, &h);
	gfx::init(w, h);

	let state = alloc(state {
		quit = false,
		win = win,
		width = w: uint,
		height = h: uint,
		...
	});

	// XXX TEMP
	state.world = world::open(os::args[1])!;

	// TODO: Spawn at player's previous location (or world spawn point)
	state.camera = gfx::camera_new();
	state.camera.pos = [0.0, 80.0 + engine::PLAYER_HEIGHT, 0.0];

	// Initialize modules
	input_init(state);
	chunk_manager_init(state);
	clouds_init(state);

	debug_init(state);

	return state;
};

// Destroy resources associated with the game engine.
export fn destroy(state: *state) void = {
	// TODO: Other stuff
	free(state);
};
