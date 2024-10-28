use glm;

// Vertex of a block model.
export type vertex = struct @packed {
	pos: glm::v3,
	color: glm::v3,
	uv: glm::v2,
};

// Faces of a cube.
export type faces = enum uint {
	N = 1 << 0,
	E = 1 << 1,
	S = 1 << 2,
	W = 1 << 3,
	T = 1 << 4,
	B = 1 << 5,
};

// Function that generates a 3D model for a [[block]].
export type modelfunc = fn(b: *block, out: *[]vertex, f: faces) void;

// Placeholder function for blocks which do not have a model (just air, really).
fn model_none(b: *block, out: *[]vertex, f: faces) void = void;

// Generates a mesh for a basic cuboid block.
fn model_cube(b: *block, out: *[]vertex, f: faces) void = {
	return; // TODO
};

// Generates a mesh for a "onequad", a model which is just one quad (e.g.
// ladder).
fn model_onequad(b: *block, out: *[]vertex, f: faces) void = {
	return; // TODO
};

// Generates a mesh for a "twoquad", a model which is two intersecting quads
// (e.g. sugarcane).
fn model_twoquad(b: *block, out: *[]vertex, f: faces) void = {
	return; // TODO
};
