use gfx;
use glm;
use strings;

def CHAT_MARGIN = gfx::CHAR_WIDTH * 2;

export type chat_message = struct {
	time: u32,
	// TODO: Parse and split up colored segments
	text: str,
};

export type chat_layer = struct {
	layer,
	// Most recent first
	messages: []chat_message,
};

// Initialize the chat module.
export fn chat_init(state: *state) void = {
	const chat = alloc(chat_layer {
		update = &no_update,
		draw = &chat_draw,
		...
	});
	state.chat = chat;
	append(state.layers, chat);
};

// Appends a chat message to the chat window.
export fn chat_receivemsg(state: *state, msg: str) void = {
	insert(state.chat.messages[0], chat_message {
		time = state.frame_time,
		text = strings::dup(msg),
	});
};

fn chat_draw(layer: *layer, state: *state) void = {
	static let refheight = 0u;
	if (refheight == 0) {
		refheight = gfx::font_measure("reference").1;
	};

	const chat = layer: *chat_layer;
	let y = state.height - CHAT_MARGIN - 2;
	y -= refheight * 3; // Reserve space for text input

	const min_y = state.height / 3;
	for (let msg &.. chat.messages) {
		y = chat_drawmsg(state, msg, y);
		if (y <= min_y) {
			break;
		};
	};
};

fn chat_drawmsg(
	state: *state,
	msg: *chat_message,
	y: uint,
) uint = {
	let (mw, mh) = gfx::font_measure(msg.text);
	y -= mh;

	// Background
	chat_drawrect(
		CHAT_MARGIN,
		y,
		state.width - (CHAT_MARGIN * 2),
		mh,
		[0.0, 0.0, 0.0, 0.5],
	);

	// Text
	// TODO: Deal with text wrapping
	let pos: glm::v2 = [CHAT_MARGIN: f32, y: f32];
	gfx::font_draw(&pos, msg.text);

	return y;
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
