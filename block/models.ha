use glm;

// TODO: Source this color from the biome
def VEGITATION: glm::v3 = [0.57, 0.74, 0.35];

// Minecraft renders a constant ambient lighting factor based on the face
const ambient: [_]f32 = [
	1.0, // Top
	0.6, // North
	0.8, // East
	0.6, // South
	0.8, // West
	0.5, // Bottom
];

const block_light: [_]f32 = [
	0.050, 0.067, 0.085, 0.106, // [ 0..3 ]
	0.129, 0.156, 0.186, 0.221, // [ 4..7 ]
	0.261, 0.309, 0.367, 0.437, // [ 8..11]
	0.525, 0.638, 0.789, 1.000 //  [12..15]
];

fn light(v: *voxel, f: face, c: glm::v3) glm::v3 = {
	const factor = block_light[15]; // TODO
	c[0] *= ambient[f] * factor;
	c[1] *= ambient[f] * factor;
	c[2] *= ambient[f] * factor;
	return c;
};

// Vertex of a block model.
export type vertex = struct @packed {
	pos: glm::v3,
	uv: glm::v2,
	color: glm::v3,
};

// Faces of a cube.
export type face = enum uint {
	T = 0,
	B = 1,
	N = 2,
	E = 3,
	S = 4,
	W = 5,
};

// Function that generates a 3D model for a [[block]].
export type modelfunc = fn(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void;

// Placeholder function for blocks which do not have a model (just air, really).
fn model_none(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void = void;

const face_map = [
	(face::T, &cube_mesh.top, &cube_uv.top),
	(face::B, &cube_mesh.bottom, &cube_uv.bottom),
	(face::N, &cube_mesh.north, &cube_uv.north),
	(face::E, &cube_mesh.east, &cube_uv.east),
	(face::S, &cube_mesh.south, &cube_uv.south),
	(face::W, &cube_mesh.west, &cube_uv.west),
];

// Generates a mesh for a basic cuboid block.
fn model_cube(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	face: face,
) void = {
	let color = glm::V3_ONE;
	if (b.id == LEAVES) {
		color = VEGITATION;
	};

	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if ((1 << mask) & face == 0) {
			continue;
		};

		for (let i = 0u; i < 6; i += 1) {
			const vert_pos = &mesh[i];
			const vert_uv = &uv[i];
			const ux = b.tex.0: f32 / 16.0;
			const uy = b.tex.1: f32 / 16.0;
			append(out, vertex {
				pos = [
					vert_pos[0] + pos[0],
					vert_pos[1] + pos[1],
					vert_pos[2] + pos[2],
				],
				uv = [
					vert_uv[0] * (1.0 / 16.0) + ux,
					vert_uv[1] * (1.0 / 16.0) + uy,
				],
				color = light(v, mask, color),
			});
		};
	};
};

// Generates a mesh for a "onequad", a model which is just one quad (e.g.
// ladder).
fn model_onequad(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void = {
	return; // TODO
};

// Generates a mesh for a "twoquad", a model which is two intersecting quads
// (e.g. sugarcane).
fn model_twoquad(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void = {
	return; // TODO
};

fn model_grass(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	face: face,
) void = {
	// TODO: Render proper biome color and replace with snow if beneath a
	// snow block (requires depth func = GL_LEQUAL)

	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if ((1 << mask) & face == 0) {
			continue;
		};

		for (let i = 0u; i < 6; i += 1) {
			const vert_pos = &mesh[i];
			const vert_uv = &uv[i];
			let ux = b.tex.0: f32 / 16.0;
			let uy = b.tex.1: f32 / 16.0;
			let color = glm::V3_ONE;

			if (mask == face::T) {
				ux = 0.0;
				uy = 0.0;
				color = VEGITATION;
			};

			append(out, vertex {
				pos = [
					vert_pos[0] + pos[0],
					vert_pos[1] + pos[1],
					vert_pos[2] + pos[2],
				],
				uv = [
					vert_uv[0] * (1.0 / 16.0) + ux,
					vert_uv[1] * (1.0 / 16.0) + uy,
				],
				color = light(v, mask, color),
			});
		};
	};
};

fn model_snow(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	face: face,
) void = {
	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		for (let i = 0u; i < 6; i += 1) {
			const vert_pos = &mesh[i];
			const vert_uv = &uv[i];
			let _vux = vert_uv[0] * (1.0 / 16.0);
			let _vuy = vert_uv[1] * (1.0 / 16.0);
			const ux = b.tex.0: f32 / 16.0;
			const uy = b.tex.1: f32 / 16.0;

			if (mask != face::T && mask != face::B) {
				_vuy *= 1.0 / 8.0;
			};

			append(out, vertex {
				pos = [
					vert_pos[0] + pos[0],
					(1.0 / 8.0) * vert_pos[1] + pos[1],
					vert_pos[2] + pos[2],
				],
				uv = [
					_vux + ux,
					_vuy + uy,
				],
				color = light(v, mask, glm::V3_ONE),
			});
		};
	};
};

fn isfluid(id: u8) bool = {
	return id == WATER || id == WATER_STATIONARY
		|| id == LAVA || id == LAVA_STATIONARY;
};

fn model_fluid(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void = {
	// TODO: Implement this properly
	let b = *b;
	if (b.id == WATER || b.id == WATER_STATIONARY) {
		b.tex = (15, 13);
	};
	if (b.id == LAVA || b.id == LAVA_STATIONARY) {
		b.tex = (15, 15);
	};

	if (isfluid(v.neighbors.top)) f &= ~(1 << face::T);
	if (isfluid(v.neighbors.bottom)) f &= ~(1 << face::B);
	if (isfluid(v.neighbors.north)) f &= ~(1 << face::N);
	if (isfluid(v.neighbors.east)) f &= ~(1 << face::E);
	if (isfluid(v.neighbors.south)) f &= ~(1 << face::S);
	if (isfluid(v.neighbors.west)) f &= ~(1 << face::W);

	model_cube(&b, v, out, pos, f);
};
