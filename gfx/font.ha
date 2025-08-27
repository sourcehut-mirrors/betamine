use ascii;
use glm;
use sdl3;
use sdl3::image;
use strings;
use types::c;

export def CHAR_WIDTH = 8;
export def CHAR_HEIGHT = 8;
export def CHAR_FWIDTH: f32 = 8.0;
export def CHAR_FHEIGHT: f32 = 8.0;

export type fontmap = struct {
	tex: texture,
	// Horizontal advance/width of each character
	hadv: [0x100]u8,
};

// Font singleton.
export let font = fontmap { ... };

fn font_init() void = {
	const surf = image::Load(c::nulstr("assets/font/default.png\0"))!;
	defer sdl3::DestroySurface(surf);

	// Calculate horizontal advance
	const pixels = surf.pixels: *[*]u32;
	for (let ord = 0u; ord < 0x100; ord += 1) {
		if (ord == ' ') {
			font.hadv[ord] = 2;
			continue;
		};

		const row = (ord & 0xF0) >> 4;
		const col = (ord & 0x0F);
		const base_x = col * CHAR_WIDTH;
		const base_y = row * CHAR_HEIGHT;

		let cw = 0u8;
		for (cw < CHAR_WIDTH; cw += 1) {
			let sum = 0u;
			for (let y = 0u; y < CHAR_HEIGHT; y += 1) {
				let _x = base_x + cw;
				let _y = base_y + y;
				let ix = _y * surf.w: uint + _x;
				if (pixels[ix] != 0) {
					sum += 1;
				};
			};
			if (sum == 0) {
				break;
			};
		};
		font.hadv[ord] = cw + 1;
	};

	font.tex = texture_fromsurf(surf)!;
};

// Returns the ordinal font index associated with this rune.
fn rune_ord(rn: rune) u8 = {
	if (ascii::valid(rn)) {
		return rn: u32: u8;
	} else {
		// TODO: The font includes some non-ASCII characters
		// Use ▪ as replacement char
		return 0xFE;
	};
};

// Draws text at the given location.
export fn font_draw(
	pos: *glm::v2,
	text: str,
	color: glm::v4 = [1.0, 1.0, 1.0, 1.0],
	fsize: uint = 3,
) void = {
	let cur = *pos;
	const iter = strings::iter(text);
	for (const rn => strings::next(&iter)) {
		const ord = rune_ord(rn);
		switch (rn) {
		case '\n' =>
			cur[0] = pos[0];
			cur[1] += CHAR_FHEIGHT * fsize: f32;
		case =>
			// Shadow
			font_drawrune(&glm::v2_new(
				cur[0] + fsize: f32,
				cur[1] + fsize: f32,
			), rn, [0.25, 0.25, 0.25, 1.0], fsize);

			// Body
			font_drawrune(&cur, rn, color, fsize);

			cur[0] += font.hadv[ord]: f32 * fsize: f32;
		};
	};
};

// Draws a single rune at the desired location.
export fn font_drawrune(
	pos: *glm::v2,
	rn: rune,
	color: glm::v4 = [1.0, 1.0, 1.0, 1.0],
	fsize: uint = 3,
) void = {
	const ord = rune_ord(rn);
	const row = ord >> 4;
	const col = ord & 0xF;

	let model = glm::M4_IDENT;
	glm::scale(&model, &glm::v3_new(fsize: f32, fsize: f32, 1.0));
	glm::translate(&model, &glm::v3_new(pos[0], pos[1], 0.0));
	sprite_draw(&font.tex, &model, [
		col: f32 * CHAR_FWIDTH,
		row: f32 * CHAR_FHEIGHT,
		CHAR_FWIDTH,
		CHAR_FHEIGHT,
	], color);
};

// Returns the pixel size of the specified text when rendered.
export fn font_measure(
	text: str,
	fsize: uint = 3,
) (uint, uint) = {
	let w: uint = 0, h: uint = CHAR_HEIGHT * fsize;
	const iter = strings::iter(text);
	for (const rn => strings::next(&iter)) {
		const ord = rune_ord(rn);
		switch (rn) {
		case '\n' =>
			abort(); // TODO
		case =>
			w += font.hadv[ord] * fsize;
		};
	};
	return (w, h);
};
