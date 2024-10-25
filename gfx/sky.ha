// Reference: https://github.com/ddevault/TrueCraft/wiki/Sky
use gl;
use gl::{
	glClearColor,
	glClear,
	glDisable,
	glEnable,
};
use glm;
use math;

// https://stackoverflow.com/questions/2353211/hsl-to-rgb-color-conversion
def ONE_THIRD: f32 = 1.0 / 3.0;
def ONE_SIXTH: f32 = 1.0 / 6.0;
def TWO_THIRD: f32 = 2.0 / 3.0;

fn hsl_rgb(h: f32, s: f32, l: f32) glm::v3 = {
	if (s == 0.0) {
		return [l, l, l]; // achromatic
	};

	const q = if (l <= 0.5) l * (1.0 + s) else l+s - l*s;
	const p = 2.0 * l - q;

	const r = hue_rgb(p, q, h + ONE_THIRD);
	const g = hue_rgb(p, q, h);
	const b = hue_rgb(p, q, h - ONE_THIRD);
	return [r, g, b];
};

fn hue_rgb(p: f32, q: f32, t: f32) f32 = {
	if (t < 0.0) t += 1.0;
	if (t > 1.0) t -= 1.0;

	if (t < ONE_SIXTH) return p + (q - p) * 6.0 * t;
	if (t < 0.5) return q;
	if (t < TWO_THIRD) return p + (q - p) * (TWO_THIRD - t) * 6.0;
	return p;
};

// Calculates the celestial angle from the current ticks.
export fn celestial_angle(ticks: u64) f32 = {
	const x = (ticks % 24000): f32 / 24000.0 - 0.25;
	if (x < 0.0) x += 1.0;
	return x + ((1.0 - (math::cosf64(x * math::PI): f32 + 1.0) / 2.0) - x) / 3.0;
};

// Calculates the world sky color.
export fn world_sky_color(cangle: f32) glm::v3 = {
	// TODO: Account for biome and celestial angle
	return [0.476, 0.65, 1.0];
};

// Calculates the world fog color for the given celestial angle.
export fn world_fog_color(cangle: f32) glm::v3 = {
	let y = math::cosf64(cangle * math::PI * 2.0): f32 * 2.0 + 0.5;
	if (y < 0.0) y = 0.0;
	if (y > 1.0) y = 1.0;
	const r = 0.7529412 * y * 0.94 + 0.06;
	const g = 0.8470588 * y * 0.94 + 0.06;
	const b = 1.0 * y * 0.91 + 0.09;
	return [r, g, b];
};

// Draws the sky.
export fn render_sky(cam: *camera, ticks: u64) void = {
	const ca = celestial_angle(ticks);
	const sky_color = world_sky_color(ca);
	const fog_color = world_fog_color(ca);

	// TODO: There are other considerations for the atmosphere color
	let atmo: glm::v3 = fog_color;

	glClearColor(atmo[0], atmo[1], atmo[2], 1.0);
	glClear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

	// TODO: Fog
	// http://www.ozone3d.net/tutorials/glsl_fog/index.php
};
