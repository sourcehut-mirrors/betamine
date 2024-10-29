use glm;

fn light(v: *voxel, f: face, c: glm::v3) glm::v3 = {
	const source = &v.neighbors.faces[f];
	let light = source.block_light + source.sky_light;
	if (light > 15) light = 15;

	// TODO: Proper lighting depends on fetching data from neighboring
	// chunks
	const factor = block_light[light];

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
	faces: face,
) void = {
	let color = glm::V3_ONE;
	switch (b.id) {
	case LEAVES =>
		color = VEGITATION;
	case WOOL =>
		color = wool_color[v.data];
	case => void;
	};

	if (b.flags & flag::TRANSLUCENT != 0) {
		const tt = blocks[v.neighbors.top.id].flags & flag::TRANSLUCENT;
		const bt = blocks[v.neighbors.bottom.id].flags & flag::TRANSLUCENT;
		const nt = blocks[v.neighbors.north.id].flags & flag::TRANSLUCENT;
		const et = blocks[v.neighbors.east.id].flags & flag::TRANSLUCENT;
		const st = blocks[v.neighbors.south.id].flags & flag::TRANSLUCENT;
		const wt = blocks[v.neighbors.west.id].flags & flag::TRANSLUCENT;

		if (tt != 0) faces &= ~(1 << face::T);
		if (bt != 0) faces &= ~(1 << face::B);
		if (nt != 0) faces &= ~(1 << face::N);
		if (et != 0) faces &= ~(1 << face::E);
		if (st != 0) faces &= ~(1 << face::S);
		if (wt != 0) faces &= ~(1 << face::W);
	};

	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if ((1 << mask) & faces == 0) {
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
	faces: face,
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
	faces: face,
) void = {
	return; // TODO
};

fn model_grass(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	faces: face,
) void = {
	// TODO: Render proper biome color and replace with snow if beneath a
	// snow block (requires depth func = GL_LEQUAL)

	for (let f &.. face_map) {
		const (mask, mesh, uv) = *f;
		if ((1 << mask) & faces == 0) {
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
	faces: face,
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

fn isfluid(vox: *voxel_data) bool = {
	return vox.id == WATER || vox.id == WATER_STATIONARY
		|| vox.id == LAVA || vox.id == LAVA_STATIONARY;
};

fn model_fluid(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	faces: face,
) void = {
	// TODO: Implement this properly
	let b = *b;
	if (b.id == WATER || b.id == WATER_STATIONARY) {
		b.tex = (15, 13);
	};
	if (b.id == LAVA || b.id == LAVA_STATIONARY) {
		b.tex = (15, 15);
	};

	if (isfluid(&v.neighbors.top)) faces &= ~(1 << face::T);
	if (isfluid(&v.neighbors.bottom)) faces &= ~(1 << face::B);
	if (isfluid(&v.neighbors.north)) faces &= ~(1 << face::N);
	if (isfluid(&v.neighbors.east)) faces &= ~(1 << face::E);
	if (isfluid(&v.neighbors.south)) faces &= ~(1 << face::S);
	if (isfluid(&v.neighbors.west)) faces &= ~(1 << face::W);

	model_cube(&b, v, out, pos, faces);
};
