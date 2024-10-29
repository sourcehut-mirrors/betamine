#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/fog.glsl"

uniform sampler2D tex;
uniform vec4 color;

in vec2 uv;

void main() {
	vec4 texcolor = texture(tex, uv);
	if (texcolor.a < 0.1) {
		discard;
	}
	texcolor *= color;
	gl_FragColor = apply_fog(texcolor);
}
