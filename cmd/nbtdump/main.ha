use fmt;
use io;
use nbt;
use nbt::{nbt_tag};
use os;
use types;

export fn main() void = {
	const rd = nbt::read(os::stdin);
	dump(&rd, types::UINT_MAX, 0);
};

fn dump(rd: *nbt::reader, items: uint, ident: uint) void = {
	for (const tag => nbt::next(rd)!) {
		if (items == 0) {
			return;
		};
		defer items -= 1;

		for (let i = 0z; i < ident; i += 1) {
			fmt::print("\t")!;
		};

		if (tag.name != "") {
			fmt::printf("{}: ", tag.name)!;
		};

		switch (tag.tag) {
		case nbt_tag::END =>
			fmt::println("<end>")!;
			break;
		case nbt_tag::BYTE =>
			fmt::printfln("{}\t[byte]", tag._i8)!;
		case nbt_tag::SHORT =>
			fmt::printfln("{}\t[short]", tag._i16)!;
		case nbt_tag::INT =>
			fmt::printfln("{}\t[int]", tag._i32)!;
		case nbt_tag::LONG =>
			fmt::printfln("{}\t[long]", tag._i64)!;
		case nbt_tag::FLOAT =>
			fmt::printfln("{}\t[float]", tag._f32)!;
		case nbt_tag::DOUBLE =>
			fmt::printfln("{}\t[double]", tag._f64)!;
		case nbt_tag::BYTE_ARRAY =>
			fmt::printfln("[{} bytes]", tag.length)!;
			const lim = io::limitreader(rd, tag.length);
			io::copy(io::empty, &lim)!;
		case nbt_tag::STRING =>
			const lim = io::limitreader(rd, tag.length);
			io::copy(os::stdout, &lim)!;
			fmt::printfln("\t[{} bytes]", tag.length)!;
		case nbt_tag::LIST =>
			fmt::printfln("[list, {} items]", tag.length)!;
			if (tag.length > 0) {
				dump(rd, tag.length, ident + 1);
			};
		case nbt_tag::COMPOUND =>
			fmt::println("[compound]")!;
			dump(rd, types::UINT_MAX, ident + 1);
		};
	};
};
