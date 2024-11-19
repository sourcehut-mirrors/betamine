use engine;
use gfx;
use glm;
use sdl2;

// Set the scale at which ticks pass
def TIMESCALE: u32 = 1;

// Runs the client game loop.
export fn run(state: *state) void = {
	state.quit = false;

	let next_tick = 0u32;
	for (!state.quit; state.frames += 1) {
		const frame_time = sdl2::SDL_GetTicks();
		state.frame_time = frame_time;
		defer state.prev_frame_time = state.frame_time;

		// Update
		for (let mod .. state.modules) {
			mod.update(mod, state);
		};

		// Run ticks 20x/sec
		if (frame_time > next_tick) {
			state.ticks += TIMESCALE;
			next_tick = frame_time + 50 / TIMESCALE;
			engine::physics_tick(&state.physics);
		};

		update_camera(state);

		// TODO: Move to module
		gfx::render_sky(&state.camera, state.ticks);

		// Draw
		for (let layer .. state.layers) {
			layer.draw(layer, state);
		};

		sdl2::SDL_GL_SwapWindow(state.win);
	};
};

fn update_camera(state: *state) void = {
	let camera = &state.camera;
	let player = &state.player;

	let camera_current = glm::v3_equal(camera.pos, player.pos);
	camera_current &&= camera.yaw == player.yaw;
	camera_current &&= camera.pitch == player.pitch;
	if (camera_current) {
		return;
	};

	camera.pos = [
		player.pos[0],
		player.pos[1] + player.stance,
		player.pos[2],
	];
	camera.pitch = player.pitch;
	camera.yaw = player.yaw;
	gfx::camera_apply(camera);
	gfx::camera_matrix(&state.camera, &state.vp);
	glm::frustrum_planes(&state.vp, &state.frustrum);
};
