use glm;

// Function that generates a axis-aligned bounding box(es) for a [[block]].
export type aabbfunc = fn(
	b: *block,
	v: *voxel,
	out: *[][2]glm::v3,
) void;

def aabb_slab: [2]glm::v3 = [
	[0.0, 0.0, 0.0],
	[1.0, 0.5, 1.0],
];
