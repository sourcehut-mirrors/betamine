#version 410 compatibility

uniform vec3 color_in;

out vec4 color;

void main() {
	color = vec4(color_in.rgb, 1.0);
}
