use glm;

// "Twoquad" vertex position mesh. Twoquads are used for blocks which are
// rendered with two intersecting quads, such as sugarcane or fire. Funnily
// enough, a "twoquad" actually has four quads in it, so that we can see it from
// behind when backface culling is enabled.
const twoquad_mesh: [4 * 6]glm::v3 = [
	// North-east
	[0.0,	0.0,	0.0],
	[1.0,	1.0,	1.0],
	[1.0,	0.0,	1.0],

	[0.0,	0.0,	0.0],
	[0.0,	1.0,	0.0],
	[1.0,	1.0,	1.0],

	// North-west
	[1.0,	0.0,	0.0],
	[0.0,	0.0,	1.0],
	[0.0,	1.0,	1.0],

	[1.0,	0.0,	0.0],
	[0.0,	1.0,	1.0],
	[1.0,	1.0,	0.0],

	// South-east
	[1.0,	0.0,	0.0],
	[0.0,	1.0,	1.0],
	[0.0,	0.0,	1.0],

	[1.0,	0.0,	0.0],
	[1.0,	1.0,	0.0],
	[0.0,	1.0,	1.0],

	// South-west
	[0.0,	0.0,	0.0],
	[1.0,	0.0,	1.0],
	[1.0,	1.0,	1.0],

	[0.0,	0.0,	0.0],
	[1.0,	1.0,	1.0],
	[0.0,	1.0,	0.0],
];

let twoquad_norm: [4]glm::v3 = [
	[ 1.0,  0.0, -1.0],	// NE
	[-1.0,  0.0, -1.0],	// NW
	[ 1.0,  0.0,  1.0],	// SE
	[-1.0,  0.0,  1.0],	// SW
];

@init fn twoquad_norm() void = {
	// Don't mind me...
	glm::v3_normalize(&twoquad_norm[0]);
	glm::v3_normalize(&twoquad_norm[1]);
	glm::v3_normalize(&twoquad_norm[2]);
	glm::v3_normalize(&twoquad_norm[3]);
};

// Twoquad vertex UV mesh.
const twoquad_uv: [4*6]glm::v2 = [
	// North-east
	[1.0,	1.0],
	[0.0,	0.0],
	[0.0,	1.0],

	[1.0,	1.0],
	[1.0,	0.0],
	[0.0,	0.0],

	// North-west
	[0.0,	1.0],
	[1.0,	1.0],
	[1.0,	0.0],

	[0.0,	1.0],
	[1.0,	0.0],
	[0.0,	0.0],

	// South-east
	[1.0,	1.0],
	[0.0,	0.0],
	[0.0,	1.0],

	[1.0,	1.0],
	[1.0,	0.0],
	[0.0,	0.0],

	// South-west
	[0.0,	1.0],
	[1.0,	1.0],
	[1.0,	0.0],

	[0.0,	1.0],
	[1.0,	0.0],
	[0.0,	0.0],
];
