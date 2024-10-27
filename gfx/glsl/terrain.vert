#version 410 compatibility

#define CHUNK_WIDTH 16
#define CHUNK_HEIGHT 128

#define Q CHUNK_WIDTH+1
#define QQ Q * Q
#define NVERTEX Q*Q*(CHUNK_HEIGHT+1)

layout(location = 0) in uint vert_pos;
layout(location = 1) in vec2 vert_uv;
layout(location = 2) in vec3 vert_color;

out vec2 uv;
out vec3 vcolor;

uniform vec3 vert_common[NVERTEX];
uniform mat4 mvp;

void main() {
	vec3 pos = vert_common[vert_pos];
	gl_Position = mvp * vec4(pos, 1);
	uv = vert_uv;
	vcolor = vec3(1.0);
}
