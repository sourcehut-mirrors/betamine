use engine;
use gfx;
use net::mc;
use os;
use sdl2;
use world;

// Initializes the game engine.
export fn init(
	win: *sdl2::SDL_Window,
	conn: *mc::conn,
	login: *mc::login_request,
	username: str,
) *state = {
	let w = 0, h = 0;
	sdl2::SDL_GL_GetDrawableSize(win, &w, &h);
	gfx::init(w, h);

	let state = alloc(state {
		quit = false,
		conn = conn,
		win = win,
		width = w: uint,
		height = h: uint,
		world = world::memory(),
		chunkmgr = null: *chunk_manager,
		...
	});

	let level = &state.world.level;
	level.seed = login.seed;

	state.camera = gfx::camera_new();
	state.player = engine::player {
		id = login.entity_id,
		name = username,
		stance = engine::STANCE_UPRIGHT,
		ground = true,
		...
	};

	// Initialize modules
	input_init(state);
	network_init(state);
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
