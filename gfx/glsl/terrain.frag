#version 410 compatibility

in vec2 uv;
in vec3 vcolor;

uniform sampler2D tex;

void main() {
	gl_FragColor = texture(tex, uv).rgba * vec4(vcolor, 1.0);
}
