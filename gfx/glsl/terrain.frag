#version 410 compatibility

in vec2 uv;
in vec3 color;

uniform sampler2D tex;
// TODO: Fog distance parameter
uniform vec3 fog;

const float near = 0.1;
const float far = 256.0;

float linearDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}

float fogFactor(float d) {
    const float fMax = far * (4.0 / 5.0);
    const float fMin = 50.0;

    if (d>=fMax) return 1.0;
    if (d<=fMin) return 0.0;

    return 1.0 - (fMax - d) / (fMax - fMin);
}

void main() {
	vec4 color = texture(tex, uv).rgba * vec4(color, 1.0);
	if (color.a == 0) {
		discard;
	}

	float depth = linearDepth(gl_FragCoord.z);
	float fog_factor = fogFactor(depth);

	gl_FragColor = mix(color, vec4(fog, 1.0), fog_factor);
}
