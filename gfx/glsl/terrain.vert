#version 420 compatibility
#extension GL_ARB_shading_language_include : require
#include "/lib/global.glsl"

layout(location = 0) in vec3 vert_pos;
layout(location = 1) in vec2 vert_uv;
layout(location = 2) in vec3 vert_color;

out vec2 uv;
out vec3 color;

uniform mat4 mvp;

void main() {
	gl_Position = mvp * vec4(vert_pos, 1);
	uv = vert_uv;
	color = vert_color;
}
