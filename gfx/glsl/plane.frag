#version 410 compatibility
#extension GL_ARB_shading_language_include : require
#define FRAGMENT_SHADER
#include "/lib/fog.glsl"

uniform sampler2D tex;
uniform vec3 fog;
uniform vec4 color;

in vec2 uv;

void main() {
	vec4 texcolor = texture(tex, uv);
	if (texcolor.a < 0.1) {
		discard;
	}
	texcolor *= color;
	// TODO: re-enable fog (breaks sun & moon)
	gl_FragColor = mix(texcolor, vec4(fog, 1.0), 0.0);
}
