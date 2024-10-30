const float[] ambientLight = {
	1.0, // Top
	0.6, // North
	0.8, // East
	0.6, // South
	0.8, // West
	0.5, // Bottom
};

const float[] block_light = {
	0.050, 0.067, 0.085, 0.106, // [ 0..3 ]
	0.129, 0.156, 0.186, 0.221, // [ 4..7 ]
	0.261, 0.309, 0.367, 0.437, // [ 8..11]
	0.525, 0.638, 0.789, 1.000 //  [12..15]
};

vec4 light_ambient(vec4 color, vec3 normal) {
	float factor;
	if (normal.y > 0.0) {
		factor = ambientLight[0];
	} else if (normal.y < 0.0) {
		factor = ambientLight[5];
	} else if (normal.z < 0.0) {
		factor = ambientLight[1];
	} else if (normal.z > 0.0) {
		factor = ambientLight[3];
	} else if (normal.x < 0.0) {
		factor = ambientLight[4];
	} else {
		factor = ambientLight[2];
	};

	return color * vec4(vec3(factor), 1.0);
}
