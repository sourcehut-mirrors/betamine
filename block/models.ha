use glm;

// TODO: Source this color from the biome
def VEGITATION: glm::v3 = [0.57, 0.74, 0.35];

// Vertex of a block model.
export type vertex = struct @packed {
	pos: glm::v3,
	uv: glm::v2,
	color: glm::v3,
};

// Faces of a cube.
export type faces = enum uint {
	NONE = 0,

	T = 1 << 0,
	B = 1 << 1,
	N = 1 << 2,
	E = 1 << 3,
	S = 1 << 4,
	W = 1 << 5,

	ALL = T | B | N | E | S | W,
};

// Function that generates a 3D model for a [[block]].
export type modelfunc = fn(
	b: *block,
	out: *[]vertex,
	pos: *glm::v3,
	f: faces,
) void;

// Placeholder function for blocks which do not have a model (just air, really).
fn model_none(b: *block, out: *[]vertex, pos: *glm::v3, f: faces) void = void;

const face_map = [
	(faces::T, &cube_mesh.top, &cube_uv.top),
	(faces::B, &cube_mesh.bottom, &cube_uv.bottom),
	(faces::N, &cube_mesh.north, &cube_uv.north),
	(faces::E, &cube_mesh.east, &cube_uv.east),
	(faces::S, &cube_mesh.south, &cube_uv.south),
	(faces::W, &cube_mesh.west, &cube_uv.west),
];

// Generates a mesh for a basic cuboid block.
fn model_cube(b: *block, out: *[]vertex, pos: *glm::v3, face: faces) void = {
	let color = glm::V3_ONE;
	if (b.id == LEAVES) {
		color = VEGITATION;
	};

	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if (mask & face == 0) {
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
				color = color,
			});
		};
	};
};

// Generates a mesh for a "onequad", a model which is just one quad (e.g.
// ladder).
fn model_onequad(b: *block, out: *[]vertex, pos: *glm::v3, f: faces) void = {
	return; // TODO
};

// Generates a mesh for a "twoquad", a model which is two intersecting quads
// (e.g. sugarcane).
fn model_twoquad(b: *block, out: *[]vertex, pos: *glm::v3, f: faces) void = {
	return; // TODO
};

fn model_grass(b: *block, out: *[]vertex, pos: *glm::v3, face: faces) void = {
	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if (mask & face == 0) {
			continue;
		};

		for (let i = 0u; i < 6; i += 1) {
			const vert_pos = &mesh[i];
			const vert_uv = &uv[i];
			let ux = b.tex.0: f32 / 16.0;
			let uy = b.tex.1: f32 / 16.0;
			let color = glm::V3_ONE;

			if (mask == faces::T) {
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
				color = color,
			});
		};
	};
};

fn model_snow(b: *block, out: *[]vertex, pos: *glm::v3, face: faces) void = {
	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		for (let i = 0u; i < 6; i += 1) {
			const vert_pos = &mesh[i];
			const vert_uv = &uv[i];
			let _vux = vert_uv[0] * (1.0 / 16.0);
			let _vuy = vert_uv[1] * (1.0 / 16.0);
			const ux = b.tex.0: f32 / 16.0;
			const uy = b.tex.1: f32 / 16.0;

			if (mask != faces::T && mask != faces::B) {
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
				color = glm::V3_ONE,
			});
		};
	};
};
