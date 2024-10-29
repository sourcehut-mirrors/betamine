layout (std140) uniform FogParams {
	float FogFactor;
	float NearPlane, FarPlane;
	vec3 FogColor;
};

float linear_depth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * NearPlane * FarPlane) / (FarPlane + NearPlane - z * (FarPlane - NearPlane));
}

float fog_for_depth(float d) {
    float fog_max = FarPlane * (4.0 / 5.0);
    float fog_min = 50.0;

    if (d >= fog_max) return 1.0;
    if (d <= fog_min) return 0.0;

    return 1.0 - (fog_max - d) / (fog_max - fog_min);
}

vec4 apply_fog(vec4 color) {
	float depth = linear_depth(gl_FragCoord.z);
	float fog = fog_for_depth(depth);
	return mix(color, vec4(FogColor, 1.0), fog * FogFactor);
}
