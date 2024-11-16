use engine;
use gfx;
use math;
use net::mc;
use os;
use sdl2;
use world;

// Initializes the game engine.
export fn init(win: *sdl2::SDL_Window, conn: *mc::conn) *state = {
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
		...
	});

	const level = &state.world.level;
	const player = &level.player;

	state.camera = gfx::camera_new();
	state.camera.pos = [
		player.pos[0]: f32,
		player.pos[1]: f32,
		player.pos[2]: f32,
	];
	state.camera.pitch = deg2rad(player.rotation.0);
	state.camera.yaw = deg2rad(player.rotation.1);

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

fn deg2rad(deg: f32) f32 = {
	return (deg: f64 / 360.0 * math::PI * 2.0): f32;
};
