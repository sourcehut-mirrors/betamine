def CHAR_WIDTH = 8;
def CHAR_HEIGHT = 8;

export type fontmap = struct {
	tex: texture,
	uv: [256](u8, u8),
};

// Font singleton.
export let font = fontmap { ... };

fn font_init() void = {
	font.tex = texture_load("assets/font/default.png")!;
};
