use gfx;
use gl;
use gl::{glBlendFunc};
use glm;

def GUI_SCALE = 3;
def GUI_FSCALE = GUI_SCALE: f32;
def HOTBAR_WIDTH = 182;
def HOTBAR_HEIGHT = 22;
def HEART_WIDTH = 9;

let tex_gui = gfx::texture { ... };
let tex_icons = gfx::texture { ... };

// Initialize the heads-up-display module.
export fn hud_init(state: *state) void = {
	tex_gui = gfx::texture_load("assets/gui/gui.png")!;
	tex_icons = gfx::texture_load("assets/gui/icons.png")!;

	const hud = alloc(layer {
		update = &no_update,
		draw = &hud_draw,
	});
	append(state.layers, hud);
};

// Draw the head's-up display.
export fn hud_draw(layer: *layer, state: *state) void = {
	hud_draw_crosshair(state);
	hud_draw_hotbar(state);
	hud_draw_health(state);
};

fn hud_draw_crosshair(state: *state) void = {
	glBlendFunc(gl::GL_ONE_MINUS_DST_COLOR, gl::GL_ONE_MINUS_SRC_COLOR);
	defer glBlendFunc(gl::GL_SRC_ALPHA, gl::GL_ONE_MINUS_SRC_ALPHA);

	const x = state.width / 2 - 8 * GUI_SCALE;
	const y = state.height / 2 - 8 * GUI_SCALE;
	let model = glm::M4_IDENT;
	let pos: glm::v3 = [x: f32, y: f32, 0.0];
	let clip: glm::v4 = [
		239.0,
		0.0,
		17.0,
		17.0,
	];
	let scale: glm::v3 = [GUI_FSCALE, GUI_FSCALE, 1.0];
	glm::scale(&model, &scale);
	glm::translate(&model, &pos);
	gfx::sprite_draw(&tex_gui, &model, clip);
};

fn hud_draw_hotbar(state: *state) void = {
	// Hotbar base
	const x = state.width / 2 - (HOTBAR_WIDTH * GUI_SCALE / 2);
	const y = state.height - HOTBAR_HEIGHT * GUI_SCALE;
	let model = glm::M4_IDENT;
	let pos: glm::v3 = [x: f32, y: f32, 0.0];
	let clip: glm::v4 = [
		0.0,
		0.0,
		HOTBAR_WIDTH: f32,
		HOTBAR_HEIGHT: f32,
	];
	let scale: glm::v3 = [GUI_FSCALE, GUI_FSCALE, 1.0];
	glm::scale(&model, &scale);
	glm::translate(&model, &pos);
	gfx::sprite_draw(&tex_gui, &model, clip);

	for (let item &.. state.player.inventory.hotbar) {
		draw_item(item, x, y);
		x += 20 * GUI_SCALE;
	};

	// Selected item (TODO: move to appropriate location)
	let clip: glm::v4 = [
		0.0,
		HOTBAR_HEIGHT: f32,
		HOTBAR_WIDTH: f32,
		HOTBAR_HEIGHT: f32,
	];
	gfx::sprite_draw(&tex_gui, &model, clip);
};

fn hud_draw_health(state: *state) void = {
	const x = state.width / 2 - (HOTBAR_WIDTH * GUI_SCALE / 2);
	const y = state.height - HOTBAR_HEIGHT * GUI_SCALE
		- HEART_WIDTH * GUI_SCALE;

	for (let _x = 0u; _x < 10; _x += 1) {
		let pos: glm::v3 = [
			(x + _x * HEART_WIDTH * GUI_SCALE): f32,
			y: f32,
			0.0,
		];
		let scale: glm::v3 = [GUI_FSCALE, GUI_FSCALE, 1.0];

		// Heart container background
		let clip: glm::v4 = [
			16.0,
			0.0,
			HEART_WIDTH: f32,
			HEART_WIDTH: f32,
		];
		let model = glm::M4_IDENT;
		glm::scale(&model, &scale);
		glm::translate(&model, &pos);
		gfx::sprite_draw(&tex_icons, &model, clip);

		// Heart sprite foreground
		let clip: glm::v4 = [
			52.0,
			0.0,
			HEART_WIDTH: f32,
			HEART_WIDTH: f32,
		];

		let model = glm::M4_IDENT;
		glm::scale(&model, &scale);
		glm::translate(&model, &pos);
		gfx::sprite_draw(&tex_icons, &model, clip);
	};
};
