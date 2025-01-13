use block;
use glm;
use math;
use sort;
use world;

// Acceleration due to gravity in m/s²
//
// Note: I have doubled the value that is used by Minecraft because it was
// too... floaty without. There's something off about my physics sim but
// whatever.
def GRAVITY: f32 = 0.8 * 40.0;

// Physics simulation state.
export type physics_sim = struct {
	world: *world::world,
	entities: []*entity,
};

// Initializes the physics simulation.
export fn physics_init(sim: *physics_sim, world: *world::world) void = {
	*sim = physics_sim {
		world = world,
		...
	};
};

// Adds an entity to the physics simulation. The entity is borrowed from the
// caller until [[physics_despawn]] is called.
export fn physics_spawn(sim: *physics_sim, ent: *entity) void = {
	const i = sort::lbisect(sim.entities, size(*entity),
		&ent, &entity_cmp);
	insert(sim.entities[i], ent)!;
};

// Advances the physics simulation by one tick (1/20th of a second).
export fn physics_tick(sim: *physics_sim) void = {
	for (let e .. sim.entities) {
		if (e.etype == entity_type::PLAYER) {
			// Player entities are not handled during a normal tick.
			// THE player's physics simulation runs every frame, to
			// ensure smooth motion, and OTHER players are not
			// simulated at all, since their motion is governed by
			// their own clients (and moderated by the server --
			// either way, not us).
			continue;
		};

		physics_entity_tick(sim, e, 1.0 / 20.0);
	};
};

// Runs the physics simulation for a single [[entity]].
export fn physics_entity_tick(
	sim: *physics_sim,
	ent: *entity,
	delta: f32,
) void = {
	let aabb: [2]glm::v3 = [
		// Entity bounding box is centered over its position
		[
			ent.pos[0] - ent.dims[0] / 2.0,
			ent.pos[1],
			ent.pos[2] - ent.dims[0] / 2.0,
		],
		[
			ent.pos[0] + ent.dims[0] / 2.0,
			ent.pos[1] + ent.dims[1],
			ent.pos[2] + ent.dims[0] / 2.0,
		],
	];
	let move: glm::v3 = glm::V3_ZERO;
	let gravity = GRAVITY;

	if (entity_isliving(ent)) {
		let living = ent: *living_entity;
		physics_living_tick(sim, living, &move, delta);
		if (living.flags & entity_flag::FLYING != 0) {
			gravity = 0.0;
		};
	};

	// TODO:
	// - Slippery blocks
	// - Water, lava, and web movement
	const v: glm::v3 = [
		ent.vel[0] * delta,
		ent.vel[1] * delta,
		ent.vel[2] * delta,
	];

	move = glm::v3_add(&move, &v);

	static let collisions: [][2]glm::v3 = [];
	collisions = collisions[..0];
	const valid = physics_gather_collisions(&collisions, sim, &aabb, &move);
	if (!valid) {
		// Entity is not in a valid chunk, abort
		return;
	};

	// Only update ground state if the entity is moving in the Y axis
	let ground = ent.ground;
	if (move[1] != 0.0) {
		ground = false;
	};

	// Y axis
	for (let nearby &.. collisions) {
		const outcome = collision_test(&move, &aabb, nearby, 1);
		if (outcome) {
			ground = true;
			ent.vel[1] = 0.0;
		};
	};

	ent.pos[1] += move[1];
	aabb[0][1] += move[1];
	aabb[1][1] += move[1];
	ent.ground = ground;

	// X axis
	for (let nearby &.. collisions) {
		if (collision_test(&move, &aabb, nearby, 0)) {
			ent.vel[0] = 0.0;
		};
	};

	ent.pos[0] += move[0];
	aabb[0][0] += move[0];
	aabb[1][0] += move[0];

	// Z axis
	for (let nearby &.. collisions) {
		if (collision_test(&move, &aabb, nearby, 2)) {
			ent.vel[2] = 0.0;
		};
	};

	ent.pos[2] += move[2];
	aabb[0][2] += move[2];
	aabb[1][2] += move[2];

	ent.vel[1] -= gravity * delta;
};

fn collision_test(
	delta: *glm::v3,
	self: *[2]glm::v3,
	nearby: const *[2]glm::v3,
	axis: size,
) bool = {
	def MIN = 0;
	def MAX = 1;

	// Cross axes
	const (c1, c2) = [
		(1, 2),
		(0, 2),
		(0, 1),
	][axis];

	// Bail out early if not coplanar
	if (self[MAX][c1] <= nearby[MIN][c1] || self[MIN][c1] >= nearby[MAX][c1]) {
		return false;
	};
	if (self[MAX][c2] <= nearby[MIN][c2] || self[MIN][c2] >= nearby[MAX][c2]) {
		return false;
	};

	let collision = false;
	if (delta[axis] > 0.0 && self[MAX][axis] <= nearby[MIN][axis]) {
		const diff = nearby[MIN][axis] - self[MAX][axis];
		if (diff < delta[axis]) {
			delta[axis] = diff;
			collision = true;
		};
	};

	if (delta[axis] < 0.0 && self[MIN][axis] >= nearby[MAX][axis]) {
		const diff = nearby[MAX][axis] - self[MIN][axis];
		if (diff > delta[axis]) {
			delta[axis] = diff;
			collision = true;
		};
	};

	return collision;
};

fn physics_living_tick(
	sim: *physics_sim,
	ent: *living_entity,
	move: *glm::v3,
	delta: f32,
) void = {
	const forward: glm::v3 = [
		math::sinf64(ent.yaw): f32 * delta * ent.speed,
		0.0,
		math::cosf64(ent.yaw): f32 * delta * ent.speed,
	];
	const right: glm::v3 = [
		math::sinf64(ent.yaw - 3.14 / 2.0): f32 * delta * ent.speed,
		0.0,
		math::cosf64(ent.yaw - 3.14 / 2.0): f32 * delta * ent.speed,
	];
	const up: glm::v3 = [0.0, delta * ent.speed, 0.0];

	if (ent.move & movement::FORWARD != 0) {
		*move = glm::v3_add(move, &forward);
	};
	if (ent.move & movement::BACKWARD != 0) {
		*move = glm::v3_sub(move, &forward);
	};
	if (ent.move & movement::LEFT != 0) {
		*move = glm::v3_sub(move, &right);
	};
	if (ent.move & movement::RIGHT != 0) {
		*move = glm::v3_add(move, &right);
	};

	if (ent.flags & entity_flag::FLYING != 0) {
		if (ent.move & movement::UP != 0) {
			*move = glm::v3_add(move, &up);
		};
		if (ent.move & movement::DOWN != 0) {
			*move = glm::v3_sub(move, &up);
		};
	};

	// Collect blocks which are of interest to other parts of the game
	// engine, such as the type of block beneath the entity's feet
	const pos = [ent.pos[0]: int, ent.pos[1]: int, ent.pos[2]: int];
	const head = ent.pos[1] + ent.dims[1];
	const blocks_of_interest: [_](*world::voxel, world::coords3D) = [
		(&ent.blocks.ground, (pos[0], pos[1] - 1, pos[2])),
		(&ent.blocks.feet,   (pos[0], pos[1], pos[2])),
		(&ent.blocks.head,   (pos[0], head: int, pos[2])),
	];
	for (let (voxel, coords) .. blocks_of_interest) {
		match (world::get(sim.world, voxel, coords)) {
		case world::error =>
			*voxel = world::voxel { ... };
		case void => void;
		};
	};

	const feet = ent.blocks.feet.id;
	const head = ent.blocks.head.id;
	const flags = [
		(feet, entity_flag::FEET_IN_WATER, entity_flag::FEET_IN_LAVA),
		(head, entity_flag::HEAD_IN_WATER, entity_flag::HEAD_IN_LAVA),
	];
	for (let (id, water, lava) .. flags) {
		if (block::is_water(id)) {
			ent.flags |= water;
		} else {
			ent.flags &= ~water;
		};
		if (block::is_lava(id)) {
			ent.flags |= lava;
		} else {
			ent.flags &= ~lava;
		};
	};
};

fn physics_gather_collisions(
	out: *[][2]glm::v3,
	sim: *physics_sim,
	aabb: const *[2]glm::v3,
	move: *glm::v3,
) bool = {
	let aabb = *aabb;

	if (move[0] < 0.0)	aabb[0][0] += move[0]
	else			aabb[1][0] += move[0];

	if (move[1] < 0.0)	aabb[0][1] += move[1]
	else			aabb[1][1] += move[1];

	if (move[2] < 0.0)	aabb[0][2] += move[2]
	else			aabb[1][2] += move[2];

	for (let axis &.. aabb[0]) *axis -= 0.25;
	for (let axis &.. aabb[1]) *axis += 0.25;

	let aabbi: [2][3]int = [
		[
			math::floorf64(aabb[0][0]): int,
			math::floorf64(aabb[0][1]): int,
			math::floorf64(aabb[0][2]): int,
		],
		[
			math::ceilf64(aabb[1][0]): int,
			math::ceilf64(aabb[1][1]): int,
			math::ceilf64(aabb[1][2]): int,
		],
	];

	let vox = world::voxel { ... };
	for (let x = aabbi[0][0]; x < aabbi[1][0]; x += 1)
	for (let y = aabbi[0][1]; y < aabbi[1][1]; y += 1)
	for (let z = aabbi[0][2]; z < aabbi[1][2]; z += 1) {
		match (world::get(sim.world, &vox, (x, y, z), world::mode::ERROR)) {
		case world::range =>
			continue;
		case world::nochunk =>
			return false;
		case world::error =>
			abort();
		case => void;
		};
		if (vox.id == 0) continue;

		const block = block::blocks[vox.id];

		let pos: glm::v3 = [x: f32, y: f32, z: f32];
		match (block.aabb) {
		case let aabb: [2]glm::v3 =>
			aabb[0] = glm::v3_add(&aabb[0], &pos);
			aabb[1] = glm::v3_add(&aabb[1], &pos);
			append(out, aabb)!;
		case let func: *block::aabbfunc =>
			abort(); // TODO
		case void => continue;
		};
	};

	return true;
};
