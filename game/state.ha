use block;
use engine;
use gfx;
use glm;
use net::mc;
use sdl3;
use world;

// Which module has input focus
// This is a bit hacky... it will work but maybe some kind of stack is better
export type input_focus = enum uint {
	GAMEPLAY,
	CHAT,
};

// In-progress mining operation.
export type mine_op = struct {
	// Coordinates of block being mined
	pos: world::coords3D,
	// Face being mined
	face: block::face,
	// Voxel being mined
	vox: world::voxel,

	// frame_time at which the operation commenced
	start: u64,
	// frame_time at which the operation will complete
	finish: u64,
};

// Game state type.
export type state = struct {
	quit: bool,
	conn: *mc::conn,

	// Player state
	player: engine::player,
	hotbar_ix: uint,
	lookat: struct {
		pos: world::coords3D,
		face: block::face,
		vox: world::voxel,
		aabb: [2]glm::v3,
	},
	mining: (mine_op | void),

	// SDL window
	win: *sdl3::Window,
	width: uint,
	height: uint,

	// Game modules
	modules: []*module,
	layers: []*layer,

	// Input state
	focus: input_focus,

	// Camera state
	camera: gfx::camera,
	vp: glm::m4,
	frustrum: [6]glm::v4,

	// Game state
	world: world::world,
	chunkmgr: *chunk_manager,
	chat: *chat_layer,
	physics: engine::physics_sim,

	// Number of game ticks ellapsed
	ticks: u64,

	// Debug info

	// Show debug overlay?
	debug: bool,

	// Total number of frames rendered
	frames: uint,
	// Monotonic timestamp of current frame, ms
	frame_time: u64,
	// Monotonic timestamp of previous frame, ms
	prev_frame_time: u64,

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
