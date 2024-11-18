use encoding::ucs2;
use encoding::utf8;
use engine;
use gfx;
use glm;
use io;
use memio;
use net::mc;
use sdl2;
use sdl2::{SDL_EventType, SDL_Scancode};
use strings;
use types::c;

def CHAT_MARGIN = gfx::CHAR_WIDTH * 2;

export type chat_message = struct {
	time: u32,
	text: []engine::chat_text,
};

export type chat_layer = struct {
	layer,
	buffer: memio::stream,
	// Most recent first
	messages: []chat_message,
};

// Initialize the chat module.
export fn chat_init(state: *state) void = {
	const chat = alloc(chat_layer {
		update = &chat_update,
		draw = &chat_draw,
		buffer = memio::dynamic(),
		...
	});
	state.chat = chat;
	append(state.modules, chat);
	append(state.layers, chat);
};

// Appends a chat message to the chat window.
export fn chat_receivemsg(state: *state, msg: str) void = {
	const text = engine::chat_parse(msg);
	insert(state.chat.messages[0], chat_message {
		time = state.frame_time,
		text = text,
	});
};

// Begin a new chat message
export fn chat_begin(state: *state) void = {
	let chat = state.chat;
	memio::reset(&chat.buffer);
	state.focus = input_focus::CHAT;
	sdl2::SDL_SetRelativeMouseMode(false);
	sdl2::SDL_StartTextInput(state.win);
};

fn chat_abort(state: *state) void = {
	state.focus = input_focus::GAMEPLAY;
	sdl2::SDL_SetRelativeMouseMode(true);
	sdl2::SDL_StopTextInput(state.win);
};

fn chat_commit(state: *state) void = {
	let chat = state.chat;
	const input = memio::string(&chat.buffer)!;
	if (len(input) == 0) {
		chat_abort(state);
		return;
	};

	const msg = ucs2::toucs2(input);
	defer free(msg);
	mc::write_chat_message(state.conn, &mc::chat_message {
		message = msg,
	})!;

	chat_abort(state);
};

fn chat_update(mod: *module, state: *state) void = {
	if (state.focus != input_focus::CHAT) {
		return;
	};

	let chat = mod: *chat_layer;
	let ev = sdl2::event { ... };
	for (sdl2::SDL_PollEvent(&ev)! == 1) {
		switch (ev.event_type) {
		case SDL_EventType::QUIT =>
			state.quit = true;
		case SDL_EventType::KEYUP =>
			switch (ev.key.keysym.scancode) {
			case SDL_Scancode::RETURN =>
				chat_commit(state);
			case SDL_Scancode::ESCAPE =>
				chat_abort(state);
			case SDL_Scancode::BACKSPACE =>
				void; // TODO
			case => void;
			};
		case SDL_EventType::TEXTINPUT =>
			const input = c::tostr(&ev.text.text[0])!;
			io::write(&chat.buffer, strings::toutf8(input))!;
		case => void;
		};
	};
};

fn chat_draw(layer: *layer, state: *state) void = {
	static let refheight = 0u;
	if (refheight == 0) {
		refheight = gfx::font_measure("Reference").1;
	};

	const chat = layer: *chat_layer;
	if (state.focus == input_focus::CHAT) {
		chat_draw_input(chat, state, refheight);
	};

	let x: uint = CHAT_MARGIN;
	let y: uint = state.height - HOTBAR_HEIGHT * GUI_SCALE - CHAT_MARGIN - 2;
	y -= refheight * 3; // Reserve space for text input

	// TODO: Deal with text wrapping
	const min_y = state.height / 3;
	for (let msg &.. chat.messages) {
		for (let text &.. msg.text) {
			chat_drawmsg(state, text, &x, &y);
			if (y <= min_y) {
				break;
			};
		};
		x = CHAT_MARGIN;
	};
};

fn chat_draw_input(chat: *chat_layer, state: *state, ref: uint) void = {
	let x: uint = CHAT_MARGIN;
	let y: uint = state.height;
	y -= HOTBAR_HEIGHT * GUI_SCALE;
	y -= CHAT_MARGIN - 2;
	y -= ref * 2;

	chat_drawrect(
		x, y,
		state.width - (CHAT_MARGIN * 2),
		ref,
		[0.0, 0.0, 0.0, 0.5],
	);

	const input = memio::string(&chat.buffer)!;
	let (mw, mh) = gfx::font_measure(input);

	let pos: glm::v2 = [x: f32, y: f32];
	gfx::font_draw(&pos, input);

	let pos: glm::v2 = [(x + mw): f32, y: f32];
	gfx::font_draw(&pos, "_");
};

fn chat_drawmsg(
	state: *state,
	span: *engine::chat_text,
	x: *uint,
	y: *uint,
) void = {
	let (mw, mh) = gfx::font_measure(span.text);
	*y -= mh;

	// Background
	chat_drawrect(
		*x, *y,
		state.width - (CHAT_MARGIN * 2),
		mh,
		[0.0, 0.0, 0.0, 0.5],
	);

	const color = engine::chat_colors[span.color];
	const color: glm::v4 = [
		(color >> 16 & 0xFF): f32 / 255.0,
		(color >> 8 & 0xFF): f32 / 255.0,
		(color & 0xFF): f32 / 255.0,
		1.0,
	];

	// Text
	let pos: glm::v2 = [*x: f32, *y: f32];
	gfx::font_draw(&pos, span.text, color);

	*x += mw;
};

// XXX: Should this be put somewhere more general-purpose?
fn chat_drawrect(
	x: uint,
	y: uint,
	w: uint,
	h: uint,
	color: glm::v4,
) void = {
	let model = glm::M4_IDENT;
	let scale: glm::v3 = [w: f32, h: f32, 1.0];
	let trans: glm::v3 = [x: f32, y: f32, 0.0];
	glm::scale(&model, &scale);
	glm::translate(&model, &trans);

	gfx::sprite_draw(&gfx::white1x1, &model,
		glm::v4_new_zero(), color);
};
