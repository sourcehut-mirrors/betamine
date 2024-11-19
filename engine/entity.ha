use glm;

// Entity type.
export type entity_type = enum uint {
	PLAYER,
	CREEPER,
	SKELETON,
	SPIDER,
	GIANT_ZOMBIE,
	ZOMBIE,
	SLIME,
	GHAST,
	ZOMBIE_PIGMAN,
	PIG,
	SHEEP,
	COW,
	CHICKEN,
	SQUID,
	WOLF,
	MAX_ANIMATE = WOLF,

	BOAT,
	MINECART,
	STORAGE_CART,
	POWERED_CART,
	TNT,
	ARROW,
	SNOWBALL,
	EGG,
	SAND,
	GRAVEL,
	FISHING_FLOAT,
	MAX_INANIMATE = FISHING_FLOAT,
};

// Entity.
export type entity = struct {
	id: int,
	etype: entity_type,

	pos: glm::v3,
	yaw: f32,
	pitch: f32,
	ground: bool,

	dims: glm::v2,
	vel: glm::v3,
};

// Entity movement
export type movement = enum uint {
	NONE		= 0,
	LEFT		= 1 << 0,
	RIGHT		= 1 << 1,
	FORWARD		= 1 << 2,
	BACKWARD	= 1 << 3,
	// Only used if flying is enabled:
	UP		= 1 << 4,
	DOWN		= 1 << 5,
};

// Living entity
export type living_entity = struct {
	entity,
	move: movement,
	health: uint,
};

// Returns true if this is a [[living_entity]].
export fn entity_isliving(ent: *entity) bool = {
	return ent.etype <= entity_type::MAX_ANIMATE;
};

// Initializes entity state.
export fn entity_init(
	ent: *entity,
	entity_id: int,
	etype: entity_type,
	width: f32,
	height: f32,
) void = {
	*ent = entity {
		id = entity_id,
		etype = etype,
		dims = [width, height],
		ground = true,
		...
	};
};

// Entity comparison function for sorted lists. Compares *[[entity]] to
// *[[entity]] (and not [[entity]] to [[entity]]).
export fn entity_cmp(
	a: const *opaque,
	b: const *opaque,
) int = {
	const a = a: const **entity;
	const b = b: const **entity;
	if (a.id < b.id) {
		return -1;
	} else if (a.id > b.id) {
		return 1;
	} else {
		return 0;
	};
};
