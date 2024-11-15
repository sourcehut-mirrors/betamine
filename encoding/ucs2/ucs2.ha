// Note: this module performs a conversion from big-endian UCS-2 to/from UTF-8.
use encoding::utf8;
use endian;
use strings;

// Return value must be freed by the caller.
export fn toucs2(s: str) []u16 = {
	let out: []u16 = alloc([], len(s) * 2);

	const iter = strings::iter(s);
	for (const rn => strings::next(&iter)) {
		const rn = rn: u32;
		assert(rn: u32 <= 0xFFFF);
		append(out, endian::htonu16(rn: u16));
	};

	return out;
};

// Return value must be freed by the user.
export fn fromucs2(ucs2: []u16) str = {
	let data: []u8 = alloc([], len(ucs2));
	for (let rn .. ucs2) {
		const rn = endian::ntohu16(rn): u32: rune;
		append(data, utf8::encoderune(rn)...);
	};
	return strings::fromutf8_unsafe(data);
};
