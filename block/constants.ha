use glm;

// TODO: Source this color from the biome
def VEGITATION: glm::v3 = [0.57, 0.74, 0.35];
def FOILAGE: glm::v3 = [0.39, 0.66, 0.28];

const block_light: [_]f32 = [
	0.050, 0.067, 0.085, 0.106, // [ 0..3 ]
	0.129, 0.156, 0.186, 0.221, // [ 4..7 ]
	0.261, 0.309, 0.367, 0.437, // [ 8..11]
	0.525, 0.638, 0.789, 1.000 //  [12..15]
];

const wool_color: [_]glm::v3 = [
	[233.0 / 255.0,	236.0 / 255.0,	236.0 / 255.0],
	[240.0 / 255.0,	118.0 / 255.0,	 19.0 / 255.0],
	[189.0 / 255.0,	 68.0 / 255.0,	179.0 / 255.0],
	[ 58.0 / 255.0,	175.0 / 255.0,	217.0 / 255.0],
	[248.0 / 255.0,	198.0 / 255.0,	 39.0 / 255.0],
	[112.0 / 255.0,	185.0 / 255.0,	 25.0 / 255.0],
	[237.0 / 255.0,	141.0 / 255.0,	172.0 / 255.0],
	[ 62.0 / 255.0,	 68.0 / 255.0,	 71.0 / 255.0],
	[142.0 / 255.0,	142.0 / 255.0,	134.0 / 255.0],
	[ 21.0 / 255.0,	137.0 / 255.0,	145.0 / 255.0],
	[121.0 / 255.0,	 42.0 / 255.0,	172.0 / 255.0],
	[ 53.0 / 255.0,	 57.0 / 255.0,	157.0 / 255.0],
	[114.0 / 255.0,	 71.0 / 255.0,	 40.0 / 255.0],
	[ 84.0 / 255.0,	109.0 / 255.0,	 27.0 / 255.0],
	[161.0 / 255.0,	 39.0 / 255.0,	 34.0 / 255.0],
	[ 20.0 / 255.0,	 21.0 / 255.0,	 25.0 / 255.0],
];

def SP_TOP: (int, int) = (10, 6);	// Sticky top
def PS_TOP: (int, int) = (11, 6);	// Normal top
def PS_BOT: (int, int) = (13, 6);	// Bottom
def PS_SID: (int, int) = (12, 6);	// Side
def PS_SDR: (int, int) = (12, -7);	// Side, reversed

// UVs for various piston orientations
const piston_uv = [
	// top     bottom  north   south   west    east
	[  PS_BOT, PS_TOP, PS_SDR, PS_SDR, PS_SDR, PS_SDR  ], // 0x00: Down
	[  PS_TOP, PS_BOT, PS_SID, PS_SID, PS_SID, PS_SID  ], // 0x01: Up
	[  PS_SID, PS_SID, PS_TOP, PS_BOT, PS_SID, PS_SID  ], // 0x00: North
	[  PS_SDR, PS_SDR, PS_BOT, PS_TOP, PS_SDR, PS_SDR  ], // 0x02: South
	[  PS_SID, PS_SID, PS_SDR, PS_SDR, PS_TOP, PS_BOT  ], // 0x03: West
	[  PS_SDR, PS_SDR, PS_SID, PS_SID, PS_BOT, PS_TOP  ], // 0x04: East
];

// UVs for various sticky piston orientations
const spiston_uv = [
	// top     bottom  north   south   west    east
	[  PS_BOT, SP_TOP, PS_SDR, PS_SDR, PS_SDR, PS_SDR  ], // 0x00: Down
	[  SP_TOP, PS_BOT, PS_SID, PS_SID, PS_SID, PS_SID  ], // 0x01: Up
	[  PS_SID, PS_SID, SP_TOP, PS_BOT, PS_SID, PS_SID  ], // 0x00: North
	[  PS_SDR, PS_SDR, PS_BOT, SP_TOP, PS_SDR, PS_SDR  ], // 0x02: South
	[  PS_SID, PS_SID, PS_SDR, PS_SDR, SP_TOP, PS_BOT  ], // 0x03: West
	[  PS_SDR, PS_SDR, PS_SID, PS_SID, PS_BOT, SP_TOP  ], // 0x04: East
];

// Whether or not a given piston orientation requires rotating the UV's 90°
const piston_rotuv = [
	// top    bottom north  south  west   east
	[  false, false, false, false, false, false  ], // 0x00: Down
	[  false, false, false, false, false, false  ], // 0x01: Up
	[  false, false, false, false, true,  true   ], // 0x00: North
	[  false, false, false, false, true,  true   ], // 0x02: South
	[  true,  true,  true,  true,  false, false  ], // 0x03: West
	[  true,  true,  true,  true,  false, false  ], // 0x04: East
];
