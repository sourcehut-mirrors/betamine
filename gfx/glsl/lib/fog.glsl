// TODO: near/far plane should be uniforms
const float near = 0.5;
const float far = 256.0;

float linear_depth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}

float fog_for_depth(float d) {
    const float fog_max = far * (4.0 / 5.0);
    const float fog_min = 50.0;

    if (d >= fog_max) return 1.0;
    if (d <= fog_min) return 0.0;

    return 1.0 - (fog_max - d) / (fog_max - fog_min);
}

#ifdef FRAGMENT_SHADER

float fog_factor() {
	float depth = linear_depth(gl_FragCoord.z);
	return fog_for_depth(depth);
}

#endif
