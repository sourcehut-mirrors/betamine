use block;
use block::{face};
use engine;
use errors;
use fmt;
use gfx;
use gl;
use gl::{
	glDisable,
	glDrawArrays,
	glEnable,
};
use glm;
use item;
use log;
use math;

let tex_items = gfx::texture { ... };
let block_meshes: [0x100]gfx::chunk_mesh = [
	gfx::chunk_mesh { ... }...
];
let block_view = glm::M4_ZERO;

// Initialize the item module.
export fn items_init() void = {
	tex_items = gfx::texture_load("assets/gui/items.png")!;

	// Generate block models
	const pos: glm::v3 = [-0.5...];

	let verts: []block::vertex = [];
	defer free(verts);

	for (let b .. block::blocks) {
		if (b == block::blocks[0]) {
			continue;
		};

		// TODO: Some block models are affected by metadata
		let voxel = block::voxel { id = b.id, ... };
		voxel.neighbors.faces[..] = [block::voxel_data {
			block_light = 15,
			sky_light = 15,
			...
		}...];

		verts = verts[..0];
		b.model(b, &voxel, &verts, &pos, ~0);

		const chunk_mesh = engine::chunk_mesh {
			vert_opaque = verts,
			...
		};
		block_meshes[b.id] = gfx::chunk_init(&chunk_mesh);
	};

	block_view = glm::lookat(
		&glm::v3_new(0.0, 0.0, 1.0),
		&glm::v3_new(0.0, 0.0, 0.0),
		&glm::v3_new(0.0, 1.0, 0.0));
};

// Draws an item sprite (or a block model) at the given coordinates.
fn draw_item(
	state: *state,
	slot: *engine::slot,
	x: uint,
	y: uint,
) void = {
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
		draw_block_item(state, slot, x, y);
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

fn draw_block_item(
	state: *state,
	slot: *engine::slot,
	x: uint,
	y: uint,
) void = {
	const mesh = &block_meshes[slot.id];
	if (mesh.nopaque == 0) {
		return;
	};

	glDisable(gl::GL_DEPTH_TEST);
	defer glEnable(gl::GL_DEPTH_TEST);

	let mvp = glm::M4_ZERO;
	let model = glm::M4_IDENT;

	let scale: glm::v3 = [0.6...];
	glm::scale(&model, &scale);
	glm::rotate(&model, (math::PI / 4.0): f32, &glm::v3_new(0.0, 1.0, 0.0));
	glm::rotate(&model, deg2rad(210.0), &glm::v3_new(1.0, 0.0, 0.0));

	let scale: glm::v3 = [
		(16.0 * GUI_FSCALE): f32,
		(16.0 * GUI_FSCALE): f32,
		1.0,
	];
	glm::scale(&model, &scale);

	const y = y: f32;
	const w = gfx::dims.0: f32;
	const h = gfx::dims.1: f32;

	glm::translate(&model, &glm::v3_new(
		x: f32 + 11.0 * GUI_FSCALE,
		y: f32 + 11.0 * GUI_FSCALE,
		0.0,
	));

	let vp = glm::M4_ZERO;
	glm::m4_mul_to(&gfx::ortho, &block_view, &vp);
	glm::m4_mul_to(&vp, &model, &mvp);
	gfx::terrain_bind(&mvp);

	gfx::chunk_begin(mesh, false);
	defer gfx::chunk_end(mesh);

	glDrawArrays(gl::GL_TRIANGLES, 0, mesh.nopaque: i32);
};
