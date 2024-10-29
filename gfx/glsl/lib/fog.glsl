layout (std140) uniform FogParams {
	float fogFactor;
	float nearPlane, farPlane;
	vec3 fogColor;
};

float linear_depth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * nearPlane * farPlane) / (farPlane + nearPlane - z * (farPlane - nearPlane));
}

float fog_for_depth(float d) {
    float fog_max = farPlane * (4.0 / 5.0);
    float fog_min = 50.0;

    if (d >= fog_max) return 1.0;
    if (d <= fog_min) return 0.0;

    return 1.0 - (fog_max - d) / (fog_max - fog_min);
}

vec4 apply_fog(vec4 color) {
	float depth = linear_depth(gl_FragCoord.z);
	float fog = fog_for_depth(depth);
	return mix(color, vec4(fogColor, 1.0), fog * fogFactor);
}
