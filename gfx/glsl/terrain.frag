#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/fog.glsl"

uniform sampler2D tex;

in vec2 uv;
in vec3 color;

void main() {
	vec4 color = texture(tex, uv).rgba * vec4(color, 1.0);
	if (color.a == 0) {
		discard;
	}
	gl_FragColor = apply_fog(color);
}
