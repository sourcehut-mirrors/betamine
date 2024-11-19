use glm;

// Function that generates a axis-aligned bounding box(es) for a [[block]].
export type aabbfunc = fn(
	b: *block,
	v: *voxel,
	out: *[][2]glm::v3,
) void;
