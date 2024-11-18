use gfx;
use gl;
use gl::{glBlendFunc};
use glm;

let tex_gui = gfx::texture { ... };

// Initialize the heads-up-display module.
export fn hud_init(state: *state) void = {
	tex_gui = gfx::texture_load("assets/gui/gui.png")!;

	const hud = alloc(layer {
		update = &no_update,
		draw = &hud_draw,
	});
	append(state.layers, hud);
};

// Draw the head's-up display.
export fn hud_draw(layer: *layer, state: *state) void = {
	let x = state.width / 2 - 8;
	let y = state.height / 2 - 8;

	let model = glm::M4_IDENT;
	let pos: glm::v3 = [
		x: f32,
		y: f32,
		0.0,
	];
	let clip: glm::v4 = [
		239.0,
		0.0,
		17.0,
		17.0,
	];
	let scale: glm::v3 = [3.0, 3.0, 1.0];
	glm::scale(&model, &scale);
	glm::translate(&model, &pos);

	glBlendFunc(gl::GL_ONE_MINUS_DST_COLOR, gl::GL_ONE_MINUS_SRC_COLOR);

	gfx::sprite_draw(&tex_gui, &model, clip);

	glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);
};
