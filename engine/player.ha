// Player height in meters
export def PLAYER_HEIGHT: f32 = 1.85;

// Camera height when player is standing upright.
export def STANCE_UPRIGHT: f32 = 1.6;

// Camera height when player is crouching.
export def STANCE_CROUCH: f32 = 1.5;

// Player state
export type player = struct {
	entity,
	stance: f32,
	name: str,
};
