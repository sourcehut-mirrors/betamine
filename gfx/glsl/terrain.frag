#version 410 compatibility

in vec2 uv;
in vec3 vcolor;

out vec4 color;

uniform sampler2D tex;
uniform sampler2D grass;

void main() {
	color = texture(tex, uv).rgba * vec4(vcolor, 1.0);
}
