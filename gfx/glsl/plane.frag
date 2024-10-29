#version 410 compatibility
#extension GL_ARB_shading_language_include : require
#define FRAGMENT_SHADER
#include "/lib/fog.glsl"

uniform sampler2D tex;
uniform vec3 fog;

in vec2 uv;

out vec4 color;

void main() {
	vec4 color = texture(tex, uv).rgba;
	if (color.a != 1.0) {
		discard;
	}
	gl_FragColor = mix(color, vec4(fog, 1.0), fog_factor());
}
