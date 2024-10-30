#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/global.glsl"

layout(location = 0) in vec3 vert_pos;
layout(location = 1) in vec3 vert_norm;
layout(location = 2) in vec3 vert_color;
layout(location = 3) in vec2 vert_uv;

out vec3 normal;
out vec3 color;
out vec2 uv;

uniform mat4 mvp;

void main() {
	gl_Position = mvp * vec4(vert_pos, 1);
	normal = vert_norm;
	color = vert_color;
	uv = vert_uv;
}
