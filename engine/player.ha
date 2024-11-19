// Player height in meters
export def PLAYER_HEIGHT: f32 = 1.85;

// Player (bounding box) width in meters
export def PLAYER_WIDTH: f32 = 0.6;

// Camera height when player is standing upright.
export def STANCE_UPRIGHT: f32 = 1.6;

// Camera height when player is crouching.
export def STANCE_CROUCH: f32 = 1.5;

// Initial health points for player entities
export def PLAYER_HEALTH: uint = 20;

// Player state
export type player = struct {
	living_entity,
	stance: f32,
	name: str,
};

// Initializes a player entity.
export fn player_init(p: *player, id: int, username: str) void = {
	entity_init(p, id,
		entity_type::PLAYER,
		PLAYER_WIDTH,
		PLAYER_HEIGHT);
	p.stance = STANCE_UPRIGHT;
	p.name = username;
	p.health = PLAYER_HEALTH;
};
