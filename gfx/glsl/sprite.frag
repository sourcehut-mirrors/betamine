#version 410 compatibility

in vec2 uv;
out vec4 color;

uniform sampler2D image;
uniform vec4 sprite_color;
// <x, y, w, h>; [0..1]
uniform vec4 clip;

void main() {
	vec2 uv_clip = uv * clip.zw + clip.xy;
	color = sprite_color * texture(image, uv_clip);
}
