#version 410 compatibility

in vec2 uv;
in vec3 color;

uniform sampler2D tex;

void main() {
	vec4 color = texture(tex, uv).rgba * vec4(color, 1.0);
	if (color.a == 0) {
		discard;
	}
	gl_FragColor = color;
}
