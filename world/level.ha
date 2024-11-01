use io;
use nbt;
use strings;

def LEVEL_VERSION: int = 19132;

// level.dat data structure
export type level = struct {
	version: int,
	name: str,
	seed: i64,
	time: i64,
	last_played: i64,
	spawn: coords3D,
	player: player,
	raining: bool,
	rain_time: int,
	thundering: bool,
	thunder_time: int,
	disk_size: i64,
};

// Decode a [[level]] from NBT.
export fn level_decode(rd: *nbt::reader) (level | io::error) = {
	let tag = nbt::next(rd)? as nbt::value;
	assert(tag.tag == nbt::nbt_tag::COMPOUND);

	let level = level { ... };
	for (const tag => nbt::next(rd)?) {
		if (tag.tag == nbt::nbt_tag::END) {
			break;
		};

		switch (tag.name) {
		case "version" =>
			level.version = tag._i32;
		case "LevelName" =>
			const lim = io::limitreader(rd, tag.length);
			const name = io::drain(&lim)?;
			level.name = strings::fromutf8(name)!;
		case "Time" =>
			level.time = tag._i64;
		case "LastPlayed" =>
			level.last_played = tag._i64;
		case "RandomSeed" =>
			level.seed = tag._i64;
		case "SpawnX" =>
			level.spawn.x = tag._i32;
		case "SpawnY" =>
			level.spawn.y = tag._i32;
		case "SpawnZ" =>
			level.spawn.z = tag._i32;
		case "Player" =>
			nbt::skip(rd, tag)?; // TODO
		case "raining" =>
			level.raining = tag._i8 != 0;
		case "rainTime" =>
			level.rain_time = tag._i32;
		case "thundering" =>
			level.thundering = tag._i8 != 0;
		case "thunderTime" =>
			level.thunder_time = tag._i32;
		case "SizeOnDisk" =>
			level.disk_size = tag._i64;
		case =>
			nbt::skip(rd, tag)?;
		};
	};

	return level;
};
