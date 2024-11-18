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

	// TODO: I want to refactor this so that all of the standard gameplay
	// modules/etc are accessible via a scene object
	let state = alloc(state {
		quit = false,
		conn = conn,
		win = win,
		width = w: uint,
		height = h: uint,
		world = world::memory(),
		chunkmgr = null: *chunk_manager,
		chat = null: *chat_layer,
		...
	});

	let level = &state.world.level;
	level.seed = login.seed;

	state.camera = gfx::camera_new();
	engine::player_init(&state.player, login.entity_id, username);

	// Initialize modules
	input_init(state);
	network_init(state);
	chunk_manager_init(state);
	clouds_init(state);
	hud_init(state);
	debug_init(state);
	chat_init(state);

	return state;
};

// Destroy resources associated with the game engine.
export fn destroy(state: *state) void = {
	// TODO: Other stuff
	free(state);
};
