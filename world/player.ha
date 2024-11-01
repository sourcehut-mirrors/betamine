use io;
use nbt;

// Player NBT data.
export type player = struct {
	motion: [3]f64,
	sleep_timer: i16,
	health: i16,
	air: i16,
	onground: bool,
	dimension: int,
	rotation: (f32, f32),
	fall_distance: f32,
	score: int,
	sleeping: bool,
	pos: [3]f64,
	death_time: i16,
	fire: i16,
	hurt_time: i16,
	attack_time: i16,
	// TODO: Inventory
};

// Decodes player data from a world's level.dat or players directory.
fn player_decode(rd: *nbt::reader) (player | io::error) = {
	let player = player { ... };
	// TODO
	return player;
};
