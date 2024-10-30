use glm;

// Vertex of a block model.
export type vertex = struct @packed {
	pos: glm::v3,
	norm: glm::v3,
	color: glm::v3,
	uv: glm::v2,
};

// Faces of a cube.
export type face = enum uint {
	T = 0,
	B = 1,
	N = 2,
	S = 3,
	W = 4,
	E = 5,
};

// Function that generates a 3D model for a [[block]].
export type modelfunc = fn(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	f: face,
) void;

fn light(v: *voxel, f: face, c: *glm::v3) glm::v3 = {
	const source = &v.neighbors.faces[f];
	let light = source.block_light + source.sky_light;
	if (light > 15) light = 15;
	const factor = block_light[light];

	let c = *c;
	c[0] *= factor;
	c[1] *= factor;
	c[2] *= factor;
	return c;
};

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
	(face::S, &cube_mesh.south, &cube_uv.south),
	(face::W, &cube_mesh.west, &cube_uv.west),
	(face::E, &cube_mesh.east, &cube_uv.east),
];

// Generates a mesh for a single face of a cuboid given a model vertex with the
// desired position, U/V coordinates, and color filled in.
fn model_face(
	v: *voxel,
	out: *[]vertex,
	model: *vertex,
	which: face,
	rotuv: bool = false,
) void = {
	const uv_off = if (rotuv) 6u else 0u;
	const (mask, mesh, uv) = face_map[which];
	for (let i = 0u; i < 6; i += 1) {
		const vert_pos = &mesh[i];
		const vert_uv = &uv[uv_off + i];
		append(out, vertex {
			pos = [
				vert_pos[0] + model.pos[0],
				vert_pos[1] + model.pos[1],
				vert_pos[2] + model.pos[2],
			],
			norm = cube_norm[mask],
			uv = [
				vert_uv[0] * (1.0 / 16.0) + model.uv[0],
				vert_uv[1] * (1.0 / 16.0) + model.uv[1],
			],
			color = light(v, mask, &model.color),
		});
	};
};

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
		const (mask, _, _) = *f;
		if ((1 << mask) & faces == 0) {
			continue;
		};

		let tex = b.tex;
		let rotuv = false;
		switch (b.id) {
		case LEAVES =>
			switch (v.data) {
			case 0x01 =>	// Spruce
				tex = (4, 8);
			case 0x02 =>	// Birch
				tex = (4, 3);
			case =>
				tex = (4, 3);
			};
		case WOOD =>
			if (mask == face::T || mask == face::B) {
				tex = (5, 1);
			} else switch (v.data) {
			case 0x01 =>	// Spruce
				tex = (4, 7);
			case 0x02 =>	// Birch
				tex = (5, 7);
			case =>		// Default
				tex = (4, 1);
			};
		case BOOKSHELF =>
			if (mask == face::T) {
				tex = (4, 0);
			};
		case CRAFT_BENCH =>
			switch (mask) {
			case face::T =>
				tex = (11, 2);
			case face::B =>
				tex = (4, 0);
			case face::N, face::S =>
				tex = (11, 3);
			case face::W, face::E =>
				tex = (12, 3);
			};
		case TNT =>
			switch (mask) {
			case face::T =>
				tex = (9, 0);
			case face::B =>
				tex = (10, 0);
			case => void;
			};
		case PUMPKIN, JACK_O_LANTERN =>
			const dir = switch (v.data) {
			case 0 => yield face::S;
			case 1 => yield face::W;
			case 2 => yield face::N;
			case 3 => yield face::E;
			case =>   yield face::T;
			};
			const front = if (b.id == PUMPKIN) 7 else 8;
			if (mask == face::T || mask == face::B) {
				tex = (6, 6);
			} else if (dir == mask) {
				tex = (front, 7);
			} else {
				tex = (6, 7);
			};
		case FURNACE, FURNACE_LIT, DISPENSER =>
			const front = switch (b.id) {
			case FURNACE =>		yield (12, 2);
			case FURNACE_LIT =>	yield (13, 3);
			case DISPENSER =>	yield (14, 2);
			case =>			abort();
			};
			if (mask == face::T || mask == face::B) {
				tex = (14, 3);
			} else if (v.data == mask) {
				tex = front;
			} else {
				tex = (13, 2);
			};
		case CHEST =>
			// TODO: Join double chests in a special renderer
			if (mask == face::T || mask == face::B) {
				tex = (9, 1);
			} else if (v.data == mask) {
				tex = (11, 1);
			} else {
				tex = (10, 1);
			};
		case PISTON =>
			const orient = v.data & 0b111;
			tex = piston_uv[orient][mask];
			rotuv = piston_rotuv[orient][mask];
		case PISTON_STICKY =>
			const orient = v.data & 0b111;
			tex = spiston_uv[orient][mask];
			rotuv = piston_rotuv[orient][mask];
		case => void;
		};

		const model = vertex {
			pos = *pos,
			color = color,
			uv = [
				tex.0: f32 / 16.0,
				tex.1: f32 / 16.0,
			],
			norm = glm::V3_ZERO,
		};
		model_face(v, out, &model, mask, rotuv);
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
	// snow block
	for (let f &.. face_map) {
		const (mask, _, _) = *f;
		if ((1 << mask) & faces == 0) {
			continue;
		};

		let tex = b.tex;
		let color = glm::V3_ONE;
		if (mask == face::T) {
			tex = (0, 0);
			color = VEGITATION;
		};

		let model = vertex {
			pos = *pos,
			color = color,
			uv = [
				tex.0: f32 / 16.0,
				tex.1: f32 / 16.0,
			],
			norm = glm::V3_ZERO,
		};
		model_face(v, out, &model, mask);
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
		const (mask, _, _) = *f;

		let verticies: [6]vertex = [
			vertex { ... }...
		];

		const model = vertex {
			pos = glm::V3_ZERO,
			color = glm::V3_ONE,
			uv = [0.0, 0.0],
			norm = glm::V3_ZERO,
		};
		model_face(v, &verticies[..0], &model, mask);

		for (let vx &.. verticies) {
			const vuv0 = vx.uv[0];
			const vuv1 = vx.uv[1];
			const ux = b.tex.0: f32 / 16.0;
			const uy = b.tex.1: f32 / 16.0;

			if (mask != face::T && mask != face::B) {
				vuv1 *= 2.0 / 16.0;
			};

			vx.uv[0] = vuv0 + ux;
			vx.uv[1] = vuv1 + uy;

			vx.pos[0] += pos[0];
			vx.pos[1] = vx.pos[1] * (2.0 / 16.0) + pos[1];
			vx.pos[2] += pos[2];
		};

		append(out, verticies...);
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

fn model_slab(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	faces: face,
) void = {
	def SCALE = 8.0 / 16.0;

	for (let f &.. face_map) {
		const (mask, _, _) = *f;

		let verticies: [6]vertex = [
			vertex { ... }...
		];

		const model = vertex {
			pos = glm::V3_ZERO,
			color = glm::V3_ONE,
			uv = [0.0, 0.0],
			norm = glm::V3_ZERO,
		};
		model_face(v, &verticies[..0], &model, mask);

		let tex = b.tex;
		switch (v.data) {
		case 0x1 =>	// cobblestone
			if (mask == face::T) {
				tex = (0, 11);
			} else {
				tex = (0, 12);
			};
		case 0x2 =>	// sandstone
			tex = (4, 0);
		case 0x3 =>	// wooden
			tex = (0, 1);
		case =>		// 0x00, stone (default)
			if (mask != face::T) {
				tex.0 -= 1;
			};
		};

		for (let vx &.. verticies) {
			const vuv0 = vx.uv[0];
			const vuv1 = vx.uv[1];
			const ux = tex.0: f32 / 16.0;
			const uy = tex.1: f32 / 16.0;

			if (mask != face::T && mask != face::B) {
				vuv1 *= SCALE;
			};

			vx.uv[0] = vuv0 + ux;
			vx.uv[1] = vuv1 + uy;

			vx.pos[0] += pos[0];
			vx.pos[1] = vx.pos[1] * SCALE + pos[1];
			vx.pos[2] += pos[2];
		};

		append(out, verticies...);
	};
};

const torch_face_map = [
	(face::T, &torch_mesh.top, &torch_uv.top),
	(face::B, &torch_mesh.bottom, &torch_uv.bottom),
	(face::N, &torch_mesh.north, &torch_uv.north),
	(face::S, &torch_mesh.south, &torch_uv.south),
	(face::W, &torch_mesh.west, &torch_uv.west),
	(face::E, &torch_mesh.east, &torch_uv.east),
];

fn model_torch(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	faces: face,
) void = {
	for (let f &.. torch_face_map) {
		const (mask, mesh, uv) = *f;
		for (let i = 0u; i < 6; i += 1) {
			let vpos = mesh[i];
			switch (v.data) {
			case 1 => // Affixed to the west
				if (vpos[1] == 0.0) {
					vpos[0] -= 8.0 / 16.0;
				} else {
					vpos[0] -= 3.0 / 16.0;
				};
				vpos[1] += 0.5 / 16.0;
			case 2 => // Affixed to the east
				if (vpos[1] == 0.0) {
					vpos[0] += 8.0 / 16.0;
				} else {
					vpos[0] += 3.0 / 16.0;
				};
				vpos[1] += 0.5 / 16.0;
			case 3 => // Affixed to the north
				if (vpos[1] == 0.0) {
					vpos[2] -= 8.0 / 16.0;
				} else {
					vpos[2] -= 3.0 / 16.0;
				};
				vpos[1] += 0.5 / 16.0;
			case 4 => // Affixed to the south
				if (vpos[1] == 0.0) {
					vpos[2] += 8.0 / 16.0;
				} else {
					vpos[2] += 3.0 / 16.0;
				};
				vpos[1] += 0.5 / 16.0;
			case =>   // Affixed to the ground (5)
				void;
			};

			append(out, vertex {
				pos = [
					vpos[0] + pos[0],
					vpos[1] + pos[1],
					vpos[2] + pos[2],
				],
				norm = cube_norm[mask],
				uv = uv[i],
				color = glm::V3_ONE,
			});
		};
	};
};

fn model_trapdoor(
	b: *block,
	v: *voxel,
	out: *[]vertex,
	pos: *glm::v3,
	faces: face,
) void = {
	def SCALE = 3.0 / 16.0;

	const open = v.data & 0x4 != 0;
	const eastwest = v.data & 0b11 < 2;	// X axis
	let scale_faces = (1 << face::T) | (1 << face::B);

	static const scale_open = [
		(1 << face::N) | (1 << face::S), // 0x00
		(1 << face::N) | (1 << face::S), // 0x01
		(1 << face::W) | (1 << face::E), // 0x02
		(1 << face::W) | (1 << face::E), // 0x03
	];
	if (open) {
		scale_faces = scale_open[v.data & 0b11];
	};

	for (let f &.. face_map) {
		const (mask, _, _) = *f;

		let verticies: [6]vertex = [
			vertex { ... }...
		];

		const model = vertex {
			pos = glm::V3_ZERO,
			color = glm::V3_ONE,
			uv = [0.0, 0.0],
			norm = glm::V3_ZERO,
		};
		model_face(v, &verticies[..0], &model, mask);

		const fmask = 1 << mask;

		const tex = b.tex;
		for (let vx &.. verticies) {
			const vuv0 = vx.uv[0];
			const vuv1 = vx.uv[1];
			const ux = tex.0: f32 / 16.0;
			const uy = tex.1: f32 / 16.0;

			if (open) {
				switch (v.data & 3) {
				case 0x00 => // Affixed to north
					vx.pos[0] += pos[0];
					vx.pos[1] += pos[1];
					vx.pos[2]  = vx.pos[2] * SCALE + pos[2];
					vx.pos[2] += 13.0 / 16.0;
				case 0x01 => // Affixed to south
					vx.pos[0] += pos[0];
					vx.pos[1] += pos[1];
					vx.pos[2]  = vx.pos[2] * SCALE + pos[2];
				case 0x02 => // Affixed to west
					vx.pos[0]  = vx.pos[0] * SCALE + pos[0];
					vx.pos[1] += pos[1];
					vx.pos[2] += pos[2];
					vx.pos[0] += 13.0 / 16.0;
				case 0x03 => // Affixed to east
					vx.pos[0]  = vx.pos[0] * SCALE + pos[0];
					vx.pos[1] += pos[1];
					vx.pos[2] += pos[2];
				case => abort();
				};

				if (fmask & ~scale_faces != 0) {
					if (eastwest) {
						vuv1 *= SCALE;
					} else {
						vuv0 *= SCALE;
					};
				};
			} else {
				if (fmask & ~scale_faces != 0) {
					vuv1 *= SCALE;
				};

				vx.pos[0] += pos[0];
				vx.pos[1]  = vx.pos[1] * SCALE + pos[1];
				vx.pos[2] += pos[2];
			};

			vx.uv[0] = vuv0 + ux;
			vx.uv[1] = vuv1 + uy;
		};

		append(out, verticies...);
	};
};
