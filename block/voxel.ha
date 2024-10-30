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

	neighbors: union {
		struct {
			top: voxel_data,
			bottom: voxel_data,
			north: voxel_data,
			south: voxel_data,
			west: voxel_data,
			east: voxel_data,
		},
		// By face
		faces: [6]voxel_data,
	},
};
