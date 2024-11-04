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

	for (const tag => nbt::next(rd)?) {
		if (tag.tag == nbt::nbt_tag::END) {
			break;
		};

		// TODO: Load the rest of the player stuff
		switch (tag.name) {
		case "Pos" =>
			tag = nbt::next(rd)? as nbt::value;
			player.pos[0] = tag._f64;
			tag = nbt::next(rd)? as nbt::value;
			player.pos[1] = tag._f64;
			tag = nbt::next(rd)? as nbt::value;
			player.pos[2] = tag._f64;
		case "Rotation" =>
			tag = nbt::next(rd)? as nbt::value;
			const yaw = tag._f32;
			tag = nbt::next(rd)? as nbt::value;
			const pitch = tag._f32;
			player.rotation = (yaw, pitch);
		case =>
			nbt::skip(rd, tag)?;
		};
	};

	return player;
};
