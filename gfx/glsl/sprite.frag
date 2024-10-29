#version 420 compatibility

in vec2 uv;

uniform sampler2D image;
uniform vec4 sprite_color;
// <x, y, w, h>; [0..1]
uniform vec4 clip;

void main() {
	vec2 uv_clip = uv * clip.zw + clip.xy;
	vec4 color = sprite_color * texture2D(image, uv_clip);
	// TODO: Fix sort order of font sprites; make sprite batch system
	if (color.a == 0.0) discard;
	gl_FragColor = color;
}
