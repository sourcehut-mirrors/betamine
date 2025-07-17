use block;
use engine;
use gfx;
use glm;
use sdl3;
use world;

// Set the scale at which ticks pass
def TIMESCALE: u64 = 1;

// Runs the client game loop.
export fn run(state: *state) void = {
	state.quit = false;

	let next_tick = 0u64;
	for (!state.quit; state.frames += 1) {
		const frame_time = sdl3::GetTicks();
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

		sdl3::GL_SwapWindow(state.win);
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

	let min = engine::PLAYER_REACH: f32 * 2.0;
	const look = engine::ray {
		orig = camera.pos,
		dir = camera.dir,
	};

	for (let x: int = -engine::PLAYER_REACH; x <= engine::PLAYER_REACH; x += 1)
	for (let y: int = -engine::PLAYER_REACH; y <= engine::PLAYER_REACH; y += 1)
	for (let z: int = -engine::PLAYER_REACH; z <= engine::PLAYER_REACH; z += 1) {
		const coords: world::coords3D = (
			look.orig[0]: int + x,
			look.orig[1]: int + y,
			look.orig[2]: int + z,
		);
		if (!world::coords3D_valid(coords)) {
			continue;
		};

		let voxel = world::voxel { ... };
		world::get(&state.world, &voxel, coords)!;
		if (voxel.id == 0) {
			continue;
		};

		const block = block::blocks[voxel.id];
		let aabb: [2]glm::v3 = [glm::V3_ZERO...];
		match (block.aabb) {
		case let ref: [2]glm::v3 =>
			aabb = ref;
		case let func: *block::aabbfunc =>
			let boxes: [][2]glm::v3 = [];
			func(block, &block::voxel {
				id = voxel.id,
				data = voxel.data,
				...
			}, &boxes);
			// TODO: Minecraft has separate physics and interaction
			// AABBs. This only matters for stairs, which should use
			// the full voxel's volume as its AABB for interactions
			// and two separate AABBs for physics.
			aabb = boxes[0];
			free(boxes);
		case void =>
			continue;
		};

		// Translate voxel AABB to its world position
		let vox_pos: glm::v3 = [
			coords.0: f32,
			coords.1: f32,
			coords.2: f32,
		];
		aabb[0] = glm::v3_add(&aabb[0], &vox_pos);
		aabb[1] = glm::v3_add(&aabb[1], &vox_pos);

		let dist = 0.0f32, face = block::face::N;
		if (engine::ray_aabb_intersect(&look, &aabb, &dist, &face)) {
			if (dist < min) {
				min = dist;
				state.lookat.face = face;
				state.lookat.pos = coords;
				state.lookat.vox = voxel;
				state.lookat.aabb = aabb;
			};
		};
	};

	if (min > engine::PLAYER_REACH: f32) {
		state.lookat.pos = (-1, -1, -1);
		state.lookat.vox = world::voxel { ... };
	};
};
