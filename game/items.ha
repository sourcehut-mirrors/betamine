use block;
use engine;
use errors;
use fmt;
use gfx;
use glm;
use item;

let tex_items = gfx::texture { ... };

// Initialize the item module.
export fn items_init() void = {
	tex_items = gfx::texture_load("assets/gui/items.png")!;
};

// Draws an item sprite (or a block model) at the given coordinates.
fn draw_item(slot: *engine::slot, x: uint, y: uint) void = {
	if (slot.id <= 0) {
		return;
	};

	defer if (slot.count > 1) {
		let buf: [8]u8 = [0...];
		const count = fmt::bsprintf(buf, "{}", slot.count);
		const (w, h) = gfx::font_measure(count);

		const pos: glm::v2 = [
			(x + 20 * GUI_SCALE - w): f32,
			(y + 20 * GUI_SCALE - h): f32,
		];
		gfx::font_draw(&pos, count);
	};

	if (slot.id < 256) {
		// TODO: Draw block models
		return;
	};

	const item = match (item::lookup(slot.id)) {
	case let i: *item::item =>
		yield i;
	case errors::noentry =>
		abort();
	};

	let model = glm::M4_IDENT;
	let pos: glm::v3 = [
		(x + 3 * GUI_SCALE): f32,
		(y + 3 * GUI_SCALE): f32,
		0.0,
	];

	const (tx, ty) = item.tex;
	let clip: glm::v4 = [
		tx: f32 * 16.0,
		ty: f32 * 16.0,
		16.0,
		16.0,
	];

	let scale: glm::v3 = [GUI_FSCALE, GUI_FSCALE, 1.0];
	glm::scale(&model, &scale);
	glm::translate(&model, &pos);
	gfx::sprite_draw(&tex_items, &model, clip);
};
