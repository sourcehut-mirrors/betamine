use glm;

export type voxel_data = struct {
	id: u8,
	data: u8,
	block_light: u8,
	sky_light: u8,
};

// A voxel in a chunk. Provides context for model renderers.
export type voxel = struct {
	voxel_data,

	neighbors: struct {
		top: u8,
		bottom: u8,
		north: u8,
		east: u8,
		south: u8,
		west: u8,
	},
};
