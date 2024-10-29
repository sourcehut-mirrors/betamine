#version 410 compatibility
#extension GL_ARB_shading_language_include : require
#define FRAGMENT_SHADER
#include "/lib/fog.glsl"

in vec2 uv;
in vec3 color;

uniform sampler2D tex;
uniform vec3 fog;

void main() {
	vec4 color = texture(tex, uv).rgba * vec4(color, 1.0);
	if (color.a == 0) {
		discard;
	}
	gl_FragColor = mix(color, vec4(fog, 1.0), fog_factor());
}
