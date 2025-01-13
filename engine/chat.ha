use encoding::utf8;
use io;
use memio;
use strings;

// Chat color
export type chat_color = enum uint {
	BLACK,
	DARK_BLUE,
	DARK_GREEN,
	DARK_CYAN,
	DARK_RED,
	PURPLE,
	GOLD,
	GRAY,
	DARK_GRAY,
	BLUE,
	BRIGHT_GREEN,
	CYAN,
	RED,
	PINK,
	YELLOW,
	WHITE,
};

// [[chat_color]] to RGB mapping.
export const chat_colors: [16]u32 = [
	0x000000,
	0x0000aa,
	0x00aa00,
	0x00aaaa,
	0xaa0000,
	0xaa00aa,
	0xffaa00,
	0xaaaaaa,
	0x555555,
	0x5555ff,
	0x55ff55,
	0x55ffff,
	0xff5555,
	0xff55ff,
	0xffff55,
	0xffffff,
];

// Span of colored chat text
export type chat_text = struct {
	color: chat_color,
	text: str,
};

// Parses a chat message into a series of formatted spans of text.
export fn chat_parse(in: str) []chat_text = {
	let buf = memio::dynamic();
	defer io::close(&buf)!;

	let spans: []chat_text = [];

	let ix = 0z;
	let iter = strings::iter(in);
	let color = chat_color::WHITE;
	for (const rn => strings::next(&iter)) {
		defer ix += 1;

		if (rn != '§') {
			io::write(&buf, utf8::encoderune(rn))!;
			continue;
		};

		const code = match (strings::next(&iter)) {
		case let code: rune =>
			yield code;
		case done =>
			io::write(&buf, utf8::encoderune(rn))!;
			break;
		};

		const new_color = switch (code) {
		case '0' => yield chat_color::BLACK;
		case '1' => yield chat_color::DARK_BLUE;
		case '2' => yield chat_color::DARK_GREEN;
		case '3' => yield chat_color::DARK_CYAN;
		case '4' => yield chat_color::DARK_RED;
		case '5' => yield chat_color::PURPLE;
		case '6' => yield chat_color::GOLD;
		case '7' => yield chat_color::GRAY;
		case '8' => yield chat_color::DARK_GRAY;
		case '9' => yield chat_color::BLUE;
		case 'a' => yield chat_color::BRIGHT_GREEN;
		case 'b' => yield chat_color::CYAN;
		case 'c' => yield chat_color::RED;
		case 'd' => yield chat_color::PINK;
		case 'e' => yield chat_color::YELLOW;
		case 'f' => yield chat_color::WHITE;
		case =>
			io::write(&buf, utf8::encoderune(rn))!;
			io::write(&buf, utf8::encoderune(code))!;
			continue;
		};

		chat_append_span(&spans, &buf, color);
		color = new_color;
	};

	chat_append_span(&spans, &buf, color);
	return spans;
};

// Frees a parsed chat message.
export fn chat_free(text: []chat_text) void = {
	for (let span .. text) {
		free(span.text);
	};
	free(text);
};

fn chat_append_span(
	spans: *[]chat_text,
	buf: *memio::stream,
	color: chat_color,
) void = {
	const text = memio::string(buf)!;
	if (len(text) == 0) {
		return;
	};

	append(spans, chat_text {
		text = strings::dup(text)!,
		color = color,
	})!;

	memio::reset(buf);
};

@test fn chat_parse() void = {
	const msg = chat_parse("Hello world!");
	defer chat_free(msg);
	assert(len(msg) == 1);
	assert(msg[0].text == "Hello world!");
	assert(msg[0].color == chat_color::WHITE);

	const msg = chat_parse("Hello §3world§f!");
	defer chat_free(msg);
	assert(len(msg) == 3);
	assert(msg[0].text == "Hello ");
	assert(msg[0].color == chat_color::WHITE);
	assert(msg[1].text == "world");
	assert(msg[1].color == chat_color::DARK_CYAN);
	assert(msg[2].text == "!");
	assert(msg[2].color == chat_color::WHITE);
};
