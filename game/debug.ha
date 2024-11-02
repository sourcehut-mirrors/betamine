use engine;
use fmt;
use gfx;
use glm;
use world;

// Debug layer
export type debug_layer = struct {
	layer,
	fps: uint,
	nframe: uint,
};

fn debug_init(state: *state) void = {
	const debug = alloc(debug_layer {
		update = &debug_update,
		draw = &debug_draw,
		...
	});
	append(state.layers, debug);
	append(state.modules, debug);

	state.debug = true;
};

fn debug_update(mod: *module, state: *state) void = {
	let mod = mod: *debug_layer;
	defer mod.nframe += 1;

	if (state.prev_frame_time / 1000 != state.frame_time / 1000) {
		mod.fps = mod.nframe;
		mod.nframe = 0;
	};
};

fn debug_draw(layer: *layer, state: *state) void = {
	const mod = layer: *debug_layer;
	if (!state.debug) {
		return;
	};

	static let buf: [512]u8 = [0...];
	const pos = fmt::bsprintf(buf, "x: {}\ny: {}\nz: {}",
		state.camera.pos[0],
		state.camera.pos[1],
		state.camera.pos[2]);

	gfx::font_draw(&glm::v2_new(0.0, 0.0 * 24.0), "Betamine 0.0.0");
	gfx::font_draw(&glm::v2_new(0.0, 1.0 * 24.0), pos);

	const dir = engine::radtocard(state.camera.yaw);
	const look = fmt::bsprintf(buf, "  look: {}\n   yaw: {}\npitch: {}",
		engine::cardtostr(dir),
		state.camera.pitch, state.camera.yaw);
	gfx::font_draw(&glm::v2_new(300.0, 2.0 * 24.0), look);

	const ccoords = world::world_to_chunk((
		state.camera.pos[0]: int,
		state.camera.pos[1]: int,
		state.camera.pos[2]: int,
	));
	const rcoords = world::chunk_to_region(ccoords);
	const world_pos = fmt::bsprintf(buf, "C: <{},{}> R: <{},{}>",
		ccoords.0, ccoords.1, rcoords.0, rcoords.1);
	gfx::font_draw(&glm::v2_new(0.0, 4.0 * 24.0), world_pos);

	const fps = fmt::bsprintf(buf, "FPS: {}", mod.fps);
	const (fw, _) = gfx::font_measure(fps);
	gfx::font_draw(&glm::v2_new((state.width - fw): f32, 0.0), fps);

	const time = fmt::bsprintf(buf, "ticks: {} (time: {})",
		state.ticks, state.ticks % 24000);
	const (fw, _) = gfx::font_measure(time);
	gfx::font_draw(&glm::v2_new((state.width - fw): f32, 1.0 * 24.0), time);

	const gfx = fmt::bsprintf(buf, "C: {} V: {} V/C: {}",
		state.nchunk, state.nvertex,
		state.nvertex / state.nchunk);
	const (fw, _) = gfx::font_measure(gfx);
	gfx::font_draw(&glm::v2_new((state.width - fw): f32, 2.0 * 24.0), gfx);
};
