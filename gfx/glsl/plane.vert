#version 410 compatibility

in vec3 vert_pos;

uniform mat4 mvp;

void main() {
	gl_Position = mvp * vec4(vert_pos, 1);
}
