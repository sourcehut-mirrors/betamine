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
use sdl3;
use sdl3::{EventType, Scancode};

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
	})!;
	append(state.modules, input)!;
};

fn input_update(mod: *module, state: *state) void = {
	if (state.focus != input_focus::GAMEPLAY) {
		return;
	};

	let mod = mod: *input_module;
	let camera = &state.camera;
	let player = &state.player;

	let mx = 0.0f32, my = 0.0f32;
	let ev = sdl3::Event { ... };
	for (sdl3::PollEvent(&ev)) {
		switch (ev.event_type) {
		case EventType::QUIT =>
			state.quit = true;
		case EventType::KEY_DOWN =>
			switch (ev.key.scancode) {
			case Scancode::S_W =>
				player.move |= movement::FORWARD;
			case Scancode::S_S =>
				player.move |= movement::BACKWARD;
			case Scancode::S_A =>
				player.move |= movement::LEFT;
			case Scancode::S_D =>
				player.move |= movement::RIGHT;
			case Scancode::S_LSHIFT =>
				player.move |= movement::DOWN;
			case Scancode::S_SPACE =>
				do_jump(player);
			case Scancode::S_1, Scancode::S_2,
				Scancode::S_3, Scancode::S_4,
				Scancode::S_5, Scancode::S_6,
				Scancode::S_7, Scancode::S_8,
				Scancode::S_9, Scancode::S_0 =>
				const ix = (ev.key.scancode - Scancode::S_1): uint;
				state.hotbar_ix = ix;
				mc::write_hold_change(state.conn, &mc::held_item_change {
					slot_id = ix: i16,
				})!;
			case => void;
			};
		case EventType::KEY_UP =>
			switch (ev.key.scancode) {
			case Scancode::S_W =>
				player.move &= ~movement::FORWARD;
			case Scancode::S_S =>
				player.move &= ~movement::BACKWARD;
			case Scancode::S_A =>
				player.move &= ~movement::LEFT;
			case Scancode::S_D =>
				player.move &= ~movement::RIGHT;
			case Scancode::S_LSHIFT =>
				player.move &= ~movement::DOWN;
			case Scancode::S_SPACE =>
				player.move &= ~movement::UP;
			case Scancode::S_F3 =>
				state.debug = !state.debug;
			case Scancode::S_T =>
				chat_begin(state);
			case => void;
			};
		case EventType::MOUSE_MOTION =>
			mx = ev.motion.xrel;
			my = ev.motion.yrel;
		case EventType::MOUSE_WHEEL =>
			const ilen = len(state.player.inventory.hotbar): i32;
			let ix = state.hotbar_ix: i32 - ev.wheel.y: i32;
			if (ix < 0) {
				ix = ilen - 1;
			} else if (ix >= ilen) {
				ix = 0;
			};
			state.hotbar_ix = ix: uint;
			mc::write_hold_change(state.conn, &mc::held_item_change {
				slot_id = ix: i16,
			})!;
		case EventType::MOUSE_BUTTON_DOWN =>
			switch (ev.button.button) {
			case sdl3::MouseButton::LEFT =>
				begin_mine(state);
			case sdl3::MouseButton::RIGHT =>
				place_block(state);
			case => void;
			};
		case EventType::MOUSE_BUTTON_UP =>
			switch (ev.button.button) {
			case sdl3::MouseButton::RIGHT =>
				abort_mine(state);
			case => void;
			};
		case => void;
		};
	};
	sdl3::get_error()!;

	const delta = (state.frame_time - state.prev_frame_time): f32 / 1000.0;

	player.yaw += MOUSE_SPEED * delta * -mx;
	player.pitch += MOUSE_SPEED * delta * -my;

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

fn place_block(state: *state) void = {
	let pos = state.lookat.pos;

	if (state.lookat.vox.id == 0) {
		pos = (-1, -1, -1);
	};

	const inventory = &state.player.inventory;
	const held = &inventory.hotbar[state.hotbar_ix];

	mc::write_player_placeblock(state.conn, &mc::player_placeblock {
		x = pos.0,
		y = pos.1: i8,
		z = pos.2,
		face = state.lookat.face: mc::face,
		item_id = if (held.id == 0) -1 else held.id,
		amount = held.count,
		metadata = held.metadata,
	})!;
};
