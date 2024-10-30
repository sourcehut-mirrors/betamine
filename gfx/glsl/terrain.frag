#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/fog.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D tex;

in vec3 normal;
in vec3 color;
in vec2 uv;

void main() {
	vec4 color = texture(tex, uv).rgba * vec4(color, 1.0);
	if (color.a == 0) {
		discard;
	}

	color = light_ambient(color, normal);
	color = apply_fog(color);

	gl_FragColor = color;
}
