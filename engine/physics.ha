use glm;
use math;
use sort;
use world;

// Entity speed in meters per second
// (This might be on a per-entity basis?)
def SPEED: f32 = 4.317;

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
	insert(sim.entities[i], ent);
};

// Advances the physics simulation by one tick (1/20th of a second).
export fn physics_tick(sim: *physics_sim) void = {
	for (let e .. sim.entities) {
		if (e.etype == entity_type::PLAYER) {
			// Handled separately
			continue;
		};

		physics_entity_tick(sim, e, 1.0 / 2.0);
	};
};

// Runs the physics simulation for a single [[entity]].
export fn physics_entity_tick(
	sim: *physics_sim,
	ent: *entity,
	delta: f32,
) void = {
	if (entity_isliving(ent)) {
		physics_living_tick(sim, ent: *living_entity, delta);
	};
};

fn physics_living_tick(
	sim: *physics_sim,
	ent: *living_entity,
	delta: f32,
) void = {
	let forward: glm::v3 = [
		math::sinf64(ent.yaw): f32 * delta * SPEED,
		0.0,
		math::cosf64(ent.yaw): f32 * delta * SPEED,
	];

	const right: glm::v3 = [
		math::sinf64(ent.yaw - 3.14 / 2.0): f32 * delta * SPEED,
		0.0,
		math::cosf64(ent.yaw - 3.14 / 2.0): f32 * delta * SPEED,
	];
	if (ent.move & movement::FORWARD != 0) {
		ent.pos = glm::v3_add(&ent.pos, &forward);
	};
	if (ent.move & movement::BACKWARD != 0) {
		ent.pos = glm::v3_sub(&ent.pos, &forward);
	};
	if (ent.move & movement::LEFT != 0) {
		ent.pos = glm::v3_sub(&ent.pos, &right);
	};
	if (ent.move & movement::RIGHT != 0) {
		ent.pos = glm::v3_add(&ent.pos, &right);
	};
};
