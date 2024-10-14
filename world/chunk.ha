// Width and depth of a world chunk in blocks.
export def CHUNK_WIDTH: size = 16;

// Height of a world chunk in blocks.
export def CHUNK_HEIGHT: size = 128;

export def CHUNK_BLOCKS = CHUNK_WIDTH * 2 * CHUNK_HEIGHT;

// A 16x16x128 chunk of the game world.
export type chunk = struct {
	blocks: [CHUNK_BLOCKS]u8,
	metadata: [CHUNK_BLOCKS / 2]u8,
	block_light: [CHUNK_BLOCKS / 2]u8,
	sky_light: [CHUNK_BLOCKS / 2]u8,
};
