use block;
use glm;

export type ray = struct {
	orig: glm::v3,
	dir: glm::v3,
};

// Tests for an intersection between a ray and an AABB at a given location. If
// the dist_out and face_out parameters are non-null, they are respectively set
// to the distance from the ray's origin that the intersection occurs at and the
// face of the AABB which the ray intersects with.
export fn ray_aabb_intersect(
	ray: *ray,
	aabb: *[2]glm::v3,
	dist_out: nullable *f32 = null,
	face_out: nullable *block::face = null,
) bool = {
	def X = 0;
	def Y = 1;
	def Z = 2;
	def MIN = 0;
	def MAX = 1;

	// Defer setting the out parameters
	let dist = 0.0f32;
	let face = block::face::T;
	defer {
		match (dist_out) {
		case let out: *f32 =>
			*out = dist;
		case null => void;
		};

		match (face_out) {
		case let out: *block::face =>
			*out = face;
		case null => void;
		};
	};

	// Test for intersection
	if (glm::aabb_point(aabb, &ray.orig)) {
		return true;
	};

	let max: glm::v3 = [-1.0...];

	if (ray.dir[X] != 0.0) {
		if (ray.orig[X] < aabb[MIN][X]) {
			max[X] = (aabb[MIN][X] - ray.orig[X]) / ray.dir[X];
		} else if (ray.orig[X] > aabb[MAX][X]) {
			max[X] = (aabb[MAX][X] - ray.orig[X]) / ray.dir[X];
		};
	};

	if (ray.dir[Y] != 0.0) {
		if (ray.orig[Y] < aabb[MIN][Y]) {
			max[Y] = (aabb[MIN][Y] - ray.orig[Y]) / ray.dir[Y];
		} else if (ray.orig[Y] > aabb[MAX][Y]) {
			max[Y] = (aabb[MAX][Y] - ray.orig[Y]) / ray.dir[Y];
		};
	};

	if (ray.dir[Z] != 0.0) {
		if (ray.orig[Z] < aabb[MIN][Z]) {
			max[Z] = (aabb[MIN][Z] - ray.orig[Z]) / ray.dir[Z];
		} else if (ray.orig[Z] > aabb[MAX][Z]) {
			max[Z] = (aabb[MAX][Z] - ray.orig[Z]) / ray.dir[Z];
		};
	};

	if (max[X] > max[Y] && max[X] > max[Z]) {
		// Is ray cast away from the voxel?
		if (max[X] < 0.0) {
			return false;
		};

		// Is the planar intersection bounded by the quad?
		const zpoint = ray.orig[Z] + max[X] * ray.dir[Z];
		if (zpoint < aabb[MIN][Z] || zpoint > aabb[MAX][Z]) {
			return false;
		};
		const ypoint = ray.orig[Y] + max[X] * ray.dir[Y];
		if (ypoint < aabb[MIN][Y] || ypoint > aabb[MAX][Y]) {
			return false;
		};

		// Intersection detected in the X plane
		dist = max[X];
		if (ray.orig[X] < aabb[MIN][X]) {
			face = block::face::W;
		} else {
			face = block::face::E;
		};

		return true;
	};

	if (max[Y] > max[X] && max[Y] > max[Z]) {
		if (max[Y] < 0.0) {
			return false;
		};

		const zpoint = ray.orig[Z] + max[Y] * ray.dir[Z];
		if (zpoint < aabb[MIN][Z] || zpoint > aabb[MAX][Z]) {
			return false;
		};
		const xpoint = ray.orig[X] + max[Y] * ray.dir[X];
		if (xpoint < aabb[MIN][X] || xpoint > aabb[MAX][X]) {
			return false;
		};

		dist = max[Y];
		if (ray.orig[Y] < aabb[MIN][Y]) {
			face = block::face::B;
		} else {
			face = block::face::T;
		};

		return true;
	};

	if (max[Z] > max[X] && max[Z] > max[Y]) {
		if (max[Z] < 0.0) {
			return false;
		};

		const xpoint = ray.orig[X] + max[Z] * ray.dir[X];
		if (xpoint < aabb[MIN][X] || xpoint > aabb[MAX][X]) {
			return false;
		};
		const ypoint = ray.orig[Y] + max[Z] * ray.dir[Y];
		if (ypoint < aabb[MIN][Y] || ypoint > aabb[MAX][Y]) {
			return false;
		};

		dist = max[Z];
		if (ray.orig[Z] < aabb[MIN][Z]) {
			face = block::face::N;
		} else {
			face = block::face::S;
		};

		return true;
	};

	return false;
};
