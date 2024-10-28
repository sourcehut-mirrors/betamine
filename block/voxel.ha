use glm;

// A voxel in a chunk. Provides context for model renderers.
export type voxel = struct {
	id: u8,
	data: u8,

	neighbors: struct {
		top: u8,
		bottom: u8,
		north: u8,
		east: u8,
		south: u8,
		west: u8,
	},
};
