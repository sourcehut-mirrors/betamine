use engine::{movement};
use gfx;
use glm;
use math;
use sdl2;
use sdl2::{
	SDL_EventType,
	SDL_Scancode,
};

// Enable flying in any direction
def FLYING: bool = false;

// Player speed in meters per second
def SPEED: f32 = 4.317;

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
				player.move |= movement::UP;
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
		case => void;
		};
	};

	const delta = (state.frame_time - state.prev_frame_time): f32 / 1000.0;

	let forward: glm::v3 = glm::V3_ZERO;
	if (FLYING) {
		forward = [
			camera.dir[0] * delta: f32 * SPEED * 2.5,
			camera.dir[1] * delta: f32 * SPEED * 2.5,
			camera.dir[2] * delta: f32 * SPEED * 2.5,
		];
	} else {
		forward = [
			math::sinf64(player.yaw): f32 * delta * SPEED,
			0.0,
			math::cosf64(player.yaw): f32 * delta * SPEED,
		];
	};

	const right: glm::v3 = [
		camera.right[0] * delta * SPEED,
		0.0,
		camera.right[2] * delta * SPEED,
	];
	const up: glm::v3 = [0.0, delta * SPEED * 2.0, 0.0];

	if (player.move & movement::FORWARD != 0) {
		player.pos = glm::v3_add(&player.pos, &forward);
	};
	if (player.move & movement::BACKWARD != 0) {
		player.pos = glm::v3_sub(&player.pos, &forward);
	};
	if (player.move & movement::LEFT != 0) {
		player.pos = glm::v3_sub(&player.pos, &right);
	};
	if (player.move & movement::RIGHT != 0) {
		player.pos = glm::v3_add(&player.pos, &right);
	};
	if (player.move & movement::UP != 0 && FLYING) {
		player.pos = glm::v3_add(&player.pos, &up);
	};
	if (player.move & movement::DOWN != 0 && FLYING) {
		player.pos = glm::v3_sub(&player.pos, &up);
	};

	player.yaw += MOUSE_SPEED * delta * -mx: f32;
	player.pitch += MOUSE_SPEED * delta * -my: f32;

	if (player.pitch < PITCH_MIN) player.pitch = PITCH_MIN;
	if (player.pitch > PITCH_MAX) player.pitch = PITCH_MAX;
};
