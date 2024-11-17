use glm;

// Entity type.
export type entity_type = enum uint {
	PLAYER,
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
};

// Entity.
export type entity = struct {
	id: int,
	etype: entity_type,
	pos: glm::v3,
	yaw: f32,
	pitch: f32,
	ground: bool,
};
