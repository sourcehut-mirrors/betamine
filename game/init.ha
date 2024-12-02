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
		chat = null: *chat_layer,

		physics = engine::physics_sim {
			world = null: *world::world,
			...
		},
		...
	});

	let level = &state.world.level;
	level.seed = login.seed;

	state.camera = gfx::camera_new();
	engine::player_init(&state.player, login.entity_id, username);
	engine::physics_init(&state.physics, &state.world);
	engine::physics_spawn(&state.physics, &state.player);

	// Initialize modules
	input_init(state);
	network_init(state);
	chunk_manager_init(state);
	clouds_init(state);
	hud_init(state);
	debug_init(state);
	chat_init(state);
	items_init();

	return state;
};

// Destroy resources associated with the game engine.
export fn destroy(state: *state) void = {
	// TODO: Other stuff
	free(state);
};
