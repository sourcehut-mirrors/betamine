// Reference: https://github.com/ddevault/TrueCraft/wiki/Sky
use gl;
use gl::{
	glBlendFunc,
	glClear,
	glClearColor,
	glDepthMask,
	glDisable,
	glEnable,
};
use glm;
use math;

let sun = texture { ... };
let moon = texture { ... };

fn sky_init() void = {
	sun = texture_load("assets/terrain/sun.png")!;
	moon = texture_load("assets/terrain/moon.png")!;
};

// Calculates the celestial angle from the current ticks.
export fn celestial_angle(ticks: u64) f32 = {
	const x = (ticks % 24000): f32 / 24000.0 - 0.25;
	if (x < 0.0) x += 1.0;
	if (x > 1.0) x -= 1.0;
	return x + ((1.0 - (math::cosf64(x * math::PI): f32 + 1.0) / 2.0) - x) / 3.0;
};

// Calculates the world sky color.
export fn world_sky_color(cangle: f32) glm::v3 = {
	// It took me far too long to realize that this is the temperature from
	// the biome generator's noise function, NOT the "temperature" of the
	// biome itself.
	def TEMP: f32 = 1.8;
	let temp = TEMP / 3.0;

	let h: f32 = 0.6222222 - temp * 0.05;
	let s: f32 = 0.5 + temp * 0.1;
	let v: f32 = 1.0;
	let color = hsv_rgb(h, s, v);

	const b = math::cosf64(cangle * math::PI * 2.0): f32 * 2.0 + 0.5;
	if (b < 0.0) b = 0.0;
	if (b > 1.0) b = 1.0;
	color[0] *= b;
	color[1] *= b;
	color[2] *= b;
	return color;
};

// Calculates the world fog color for the given celestial angle.
export fn world_fog_color(cangle: f32) glm::v3 = {
	let y = math::cosf64(cangle * math::PI * 2.0): f32 * 2.0 + 0.5;
	if (y < 0.0) y = 0.0;
	if (y > 1.0) y = 1.0;
	const r = 0.4929412 * y * 0.94 + 0.06;
	const g = 0.6370588 * y * 0.94 + 0.06;
	const b = 1.0 * y * 0.91 + 0.09;
	return [r, g, b];
};

// Draws the sky and configures the fog color.
export fn render_sky(cam: *camera, ticks: u64) void = {
	const ca = celestial_angle(ticks);
	const sky_color = world_sky_color(ca);
	const fog_color = world_fog_color(ca);

	// Notes:
	// - The constant 0.29 is in practice based on draw distance
	// - Weather can affect this calculation
	// - This value changes when the player is submerged
	// - Many of these constants change in the Nether
	let atmo: glm::v3 = fog_color;
	atmo[0] = atmo[0] + (sky_color[0] - atmo[0]) * 0.29;
	atmo[1] = atmo[1] + (sky_color[1] - atmo[1]) * 0.29;
	atmo[2] = atmo[2] + (sky_color[2] - atmo[2]) * 0.29;

	glClearColor(atmo[0], atmo[1], atmo[2], 1.0);
	glClear(gl::GL_COLOR_BUFFER_BIT | gl::GL_DEPTH_BUFFER_BIT);

	fog_config.color = atmo;
	fog_apply();

	let vp = glm::M4_ZERO;
	let model = glm::M4_IDENT, mvp = glm::M4_ZERO;
	camera_matrix(cam, &vp);

	// Sky plane
	{
		glDepthMask(0);
		defer glDepthMask(1);

		model = glm::M4_IDENT;
		glm::scale(&model, &glm::v3_new(512.0, 1.0, 512.0));
		glm::translate(&model, &glm::v3_new(0.0, 16.0, 0.0));
		glm::translate(&model, &cam.pos);
		glm::m4_mul_to(&vp, &model, &mvp);
		render_plane(&mvp, null, &glm::v4_new(
			sky_color[0],
			sky_color[1],
			sky_color[2],
			1.0,
		));
	};

	// Sun & moon
	{
		fog_disable();
		glDepthMask(0);
		glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE);
		defer fog_enable();
		defer glDepthMask(1);
		defer glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

		model = glm::M4_IDENT;
		glm::scale(&model, &glm::v3_new(60.0, 1.0, 60.0));
		glm::translate(&model, &glm::v3_new(0.0, 100.0, 0.0));
		glm::rotate(&model, ca * (math::PI * 2.0): f32, &glm::v3_new(1.0, 0.0, 0.0));
		glm::translate(&model, &cam.pos);

		glm::m4_mul_to(&vp, &model, &mvp);
		render_plane(&mvp, &sun, &glm::v4_new_fill(1.0));

		model = glm::M4_IDENT;
		glm::scale(&model, &glm::v3_new(60.0, 1.0, 60.0));
		glm::translate(&model, &glm::v3_new(0.0, -100.0, 0.0));
		glm::rotate(&model, ca * (math::PI * 2.0): f32, &glm::v3_new(1.0, 0.0, 0.0));
		glm::translate(&model, &cam.pos);

		glm::m4_mul_to(&vp, &model, &mvp);
		render_plane(&mvp, &moon, &glm::v4_new_fill(1.0));
	};

	// Void plane
	{
		glDepthMask(0);
		defer glDepthMask(1);

		model = glm::M4_IDENT;
		glm::scale(&model, &glm::v3_new(512.0, 1.0, 512.0));
		glm::translate(&model, &glm::v3_new(0.0, -16.0, 0.0));
		glm::translate(&model, &cam.pos);
		glm::m4_mul_to(&vp, &model, &mvp);
		render_plane(&mvp, null, &glm::v4_new(
			sky_color[0] * 0.2 + 0.04,
			sky_color[1] * 0.2 + 0.04,
			sky_color[2] * 0.6 + 0.01,
			1.0,
		));
	};
};

fn hsv_rgb(h: f64, s: f64, v: f64) glm::v3 = {
	let r = 0.0;
	let g = 0.0;
	let b = 0.0;

	let i = math::floorf64(h * 6.0);
	let f = h * 6.0 - i;
	let p = v * (1.0 - s);
	let q = v * (1.0 - f * s);
	let t = v * (1.0 - (1.0 - f) * s);

	switch (i: int % 6) {
	case 0 => r = v; g = t; b = p;
	case 1 => r = q; g = v; b = p;
	case 2 => r = p; g = v; b = t;
	case 3 => r = p; g = q; b = v;
	case 4 => r = t; g = p; b = v;
	case 5 => r = v; g = p; b = q;
	case => abort();
	};

	return [r: f32, g: f32, b: f32];
};
