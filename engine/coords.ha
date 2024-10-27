use glm;
use math;
use fmt;

export def NORTH: glm::v3	= [ 0.0,  0.0, -1.0];
export def SOUTH: glm::v3	= [ 0.0,  0.0,  1.0];
export def EAST: glm::v3	= [ 1.0,  0.0,  0.0];
export def WEST: glm::v3	= [-1.0,  0.0,  0.0];
export def UP: glm::v3		= [ 0.0,  1.0,  0.0];
export def DOWN: glm::v3	= [ 0.0, -1.0,  0.0];

// Cardinal direction (north, south, east, west)
export type cardinal = enum uint {
	S,
	SE,
	E,
	NE,
	N,
	NW,
	W,
	SW,
};

// Converts an angle radians to a cardinal direction.
export fn radtocard(rad: f64) cardinal = {
	// 0 rad is positive Z, PI/2 is positive X
	def TWOPI = math::PI * 2.0;

	rad += math::PI / 8.0;
	rad = math::modf64(rad, TWOPI);
	if (rad < 0.0) {
		rad += TWOPI;
	};

	static const thresh: [8]f64 = [
		0.0 / 8.0 * TWOPI,
		1.0 / 8.0 * TWOPI,
		2.0 / 8.0 * TWOPI,
		3.0 / 8.0 * TWOPI,
		4.0 / 8.0 * TWOPI,
		5.0 / 8.0 * TWOPI,
		6.0 / 8.0 * TWOPI,
		7.0 / 8.0 * TWOPI,
	];
	for (let i = len(thresh); i > 0; i -= 1) {
		if (rad >= thresh[i - 1]) {
			return (i - 1): cardinal;
		};
	};

	return cardinal::N;
};

// Converts a cardinal direction into a string.
export fn cardtostr(c: cardinal) const str = {
	switch (c) {
	case cardinal::N	=> return "N";
	case cardinal::NE	=> return "NE";
	case cardinal::E	=> return "E";
	case cardinal::SE	=> return "SE";
	case cardinal::S	=> return "S";
	case cardinal::SW	=> return "SW";
	case cardinal::W	=> return "W";
	case cardinal::NW	=> return "NW";
	};
};
