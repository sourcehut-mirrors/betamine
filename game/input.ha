use block;
use engine;
use engine::{entity_flag, movement};
use errors;
use gfx;
use glm;
use item;
use log;
use math;
use net::mc;
use sdl2;
use sdl2::{
	SDL_EventType,
	SDL_Scancode,
};

// Mouse speed modifier
def MOUSE_SPEED: f32 = 2.0;

def PITCH_MIN = -(math::PI / 2.0): f32;
def PITCH_MAX = (math::PI / 2.0): f32;

// Input module
export type input_module = struct {
	module,
};

fn input_init(state: *state) void = {
	const input = alloc(input_module {
		update = &input_update,
	});
	append(state.modules, input);
};

fn input_update(mod: *module, state: *state) void = {
	if (state.focus != input_focus::GAMEPLAY) {
		return;
	};

	let mod = mod: *input_module;
	let camera = &state.camera;
	let player = &state.player;

	let mx = 0i32, my = 0i32;
	let ev = sdl2::event { ... };
	for (sdl2::SDL_PollEvent(&ev)! == 1) {
		switch (ev.event_type) {
		case SDL_EventType::QUIT =>
			state.quit = true;
		case SDL_EventType::KEYDOWN =>
			switch (ev.key.keysym.scancode) {
			case SDL_Scancode::W =>
				player.move |= movement::FORWARD;
			case SDL_Scancode::S =>
				player.move |= movement::BACKWARD;
			case SDL_Scancode::A =>
				player.move |= movement::LEFT;
			case SDL_Scancode::D =>
				player.move |= movement::RIGHT;
			case SDL_Scancode::LSHIFT =>
				player.move |= movement::DOWN;
			case SDL_Scancode::SPACE =>
				do_jump(player);
			case SDL_Scancode::ONE, SDL_Scancode::TWO,
				SDL_Scancode::THREE, SDL_Scancode::FOUR,
				SDL_Scancode::FIVE, SDL_Scancode::SIX,
				SDL_Scancode::SEVEN, SDL_Scancode::EIGHT,
				SDL_Scancode::NINE, SDL_Scancode::ZERO =>
				const ix = (ev.key.keysym.scancode - SDL_Scancode::ONE): uint;
				state.hotbar_ix = ix;
				mc::write_hold_change(state.conn, &mc::held_item_change {
					slot_id = ix: i16,
				})!;
			case => void;
			};
		case SDL_EventType::KEYUP =>
			switch (ev.key.keysym.scancode) {
			case SDL_Scancode::W =>
				player.move &= ~movement::FORWARD;
			case SDL_Scancode::S =>
				player.move &= ~movement::BACKWARD;
			case SDL_Scancode::A =>
				player.move &= ~movement::LEFT;
			case SDL_Scancode::D =>
				player.move &= ~movement::RIGHT;
			case SDL_Scancode::LSHIFT =>
				player.move &= ~movement::DOWN;
			case SDL_Scancode::SPACE =>
				player.move &= ~movement::UP;
			case SDL_Scancode::F3 =>
				state.debug = !state.debug;
			case SDL_Scancode::T =>
				chat_begin(state);
			case => void;
			};
		case SDL_EventType::MOUSEMOTION =>
			mx = ev.motion.xrel;
			my = ev.motion.yrel;
		case SDL_EventType::MOUSEWHEEL =>
			const ilen = len(state.player.inventory.hotbar): i32;
			let ix = state.hotbar_ix: i32 - ev.wheel.y;
			if (ix < 0) {
				ix = ilen - 1;
			} else if (ix >= ilen) {
				ix = 0;
			};
			state.hotbar_ix = ix: uint;
			mc::write_hold_change(state.conn, &mc::held_item_change {
				slot_id = ix: i16,
			})!;
		case SDL_EventType::MOUSEBUTTONDOWN =>
			begin_mine(state);
		case SDL_EventType::MOUSEBUTTONUP =>
			abort_mine(state);
		case => void;
		};
	};

	const delta = (state.frame_time - state.prev_frame_time): f32 / 1000.0;

	player.yaw += MOUSE_SPEED * delta * -mx: f32;
	player.pitch += MOUSE_SPEED * delta * -my: f32;

	if (player.pitch < PITCH_MIN) player.pitch = PITCH_MIN;
	if (player.pitch > PITCH_MAX) player.pitch = PITCH_MAX;

	engine::physics_entity_tick(&state.physics, &state.player, delta);

	if (state.mining is mine_op) {
		update_mine(state);
	};
};

fn do_jump(player: *engine::player) void = {
	if (player.flags & entity_flag::FLYING != 0) {
		player.move |= movement::UP;
	} else if (player.ground) {
		player.vel[1] += engine::PLAYER_JUMP;
	};
};

fn begin_mine(state: *state) void = {
	// TODO: Mining several blocks with mouse held down
	if (state.lookat.vox.id == 0) {
		return;
	};

	const inventory = &state.player.inventory;
	const held = inventory.hotbar[state.hotbar_ix];

	const block = block::blocks[state.lookat.vox.id];
	const item = match (item::lookup(held.id)) {
	case let i: *item::item =>
		yield i;
	case errors::noentry =>
		yield null;
	};

	let damage = 0i16;
	const ms = engine::calc_mining_time(block, item, &damage);
	const item_name = match (item) {
	case let i: *item::item =>
		yield i.display_name;
	case null =>
		yield "Hand";
	};

	log::printfln("Mine {} with {}: {}ms + {} damage",
		block.display_name, item_name, ms, damage);

	const op = mine_op {
		pos = state.lookat.pos,
		face = state.lookat.face,
		vox = state.lookat.vox,
		start = state.frame_time,
		finish = state.frame_time + ms: u32,
	};
	state.mining = op;

	mc::write_player_digging(state.conn, &mc::player_digging {
		status = mc::dig_status::DIG_BEGIN,
		face = op.face: mc::face,
		x = op.pos.0,
		y = op.pos.1: i8,
		z = op.pos.2,
	})!;
};

fn update_mine(state: *state) void = {
	const op = match (&state.mining) {
	case let op: *mine_op =>
		yield op;
	case void =>
		return;
	};

	if (state.frame_time < op.finish) {
		return;
	};

	mc::write_player_digging(state.conn, &mc::player_digging {
		status = mc::dig_status::DIG_END,
		face = op.face: mc::face,
		x = op.pos.0,
		y = op.pos.1: i8,
		z = op.pos.2,
	})!;

	state.mining = void;
};

fn abort_mine(state: *state) void = {
	state.mining = void;
};
