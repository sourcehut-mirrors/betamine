use glm;
use math;

def DEFAULT_FOV: f32 = 70.0;

// Encapsulates state for the player's point-of-view "camera".
export type camera = struct {
	pos: glm::v3,

	pitch: f32,	// Radians
	yaw: f32,	// Radians

	fov: f32,	// Degrees
	ratio: f32,
	znear: f32,
	zfar: f32,

	// Depends on the above
	dir: glm::v3,
	right: glm::v3,

	view: glm::m4,
	proj: glm::m4,
	vp: glm::m4,
};

// Creates a new camera with the desired aspect ratio.
export fn camera_new() camera = {
	const (w, h) = dims;
	let c = camera {
		fov = DEFAULT_FOV,
		ratio = w: f32 / h: f32,
		znear = 0.2,
		zfar = 256.0,
		...
	};
	camera_apply(&c);
	return c;
};

// Applies the camera configuration to its saved matricies.
export fn camera_apply(c: *camera) void = {
	// XXX: math:: should probably have cosf32 et al
	c.dir = [
		(math::cosf64(c.pitch) * math::sinf64(c.yaw)): f32,
		(math::sinf64(c.pitch)): f32,
		(math::cosf64(c.pitch) * math::cosf64(c.yaw)): f32,
	];
	c.right = [
		math::sinf64(c.yaw - 3.14 / 2.0): f32,
		0.0,
		math::cosf64(c.yaw - 3.14 / 2.0): f32,
	];

	const up = glm::v3_cross(&c.right, &c.dir);
	glm::perspective(&c.proj, c.fov, c.ratio, c.znear, c.zfar);
	c.view = glm::lookat(&c.pos, &glm::v3_add(&c.pos, &c.dir), &up);
	glm::m4_mul_to(&c.proj, &c.view, &c.vp);
};

// Returns the view × projection matrix for this camera.
export fn camera_matrix(c: *camera, mat: *glm::m4) void = {
	*mat = c.vp;
};
