#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/fog.glsl"

uniform sampler2D tex;
uniform vec4 color;
uniform bool texture_enabled;

in vec2 uv;

void main() {
	vec4 texcolor = texture_enabled ? texture(tex, uv) : vec4(1.0);
	if (texcolor.a < 0.1) {
		discard;
	}
	texcolor *= color;
	gl_FragColor = apply_fog(texcolor);
}
