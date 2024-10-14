use fmt;
use io;
use types;

// Dump a plain-text representation of an NBT reader to an I/O handle.
export fn dump(out: io::handle, rd: *reader) (void | io::error) = {
	return _dump(out, rd, 0, types::UINT_MAX);
};

fn nbt_tag_name(tag: nbt_tag) const str = {
	switch (tag) {
	case nbt_tag::END =>
		return "TAG_End";
	case nbt_tag::BYTE =>
		return "TAG_Byte";
	case nbt_tag::SHORT =>
		return "TAG_Short";
	case nbt_tag::INT =>
		return "TAG_Int";
	case nbt_tag::LONG =>
		return "TAG_Long";
	case nbt_tag::FLOAT =>
		return "TAG_Float";
	case nbt_tag::DOUBLE =>
		return "TAG_Double";
	case nbt_tag::BYTE_ARRAY =>
		return "TAG_Byte_Array";
	case nbt_tag::STRING =>
		return "TAG_String";
	case nbt_tag::LIST =>
		return "TAG_List";
	case nbt_tag::COMPOUND =>
		return "TAG_Compound";
	};
};

fn do_indent(out: io::handle, depth: uint) (void | io::error) = {
	for (let i = 0z; i < depth; i += 1) {
		fmt::fprint(out, "  ")!;
	};
};

fn _dump(
	out: io::handle,
	rd: *reader,
	depth: uint,
	length: uint = types::UINT_MAX,
) (void | io::error) = {
	for (const tag => next(rd)!) {
		if (length == 0) {
			return;
		};
		defer length -= 1;

		if (tag.tag != nbt_tag::END) {
			do_indent(out, depth)?;

			if (tag.name == "") {
				fmt::fprintf(out, "{}(None): ",
					nbt_tag_name(tag.tag))?;
			} else {
				fmt::fprintf(out, "{}('{}'): ",
					nbt_tag_name(tag.tag),
					tag.name)?;
			};
		};

		switch (tag.tag) {
		case nbt_tag::END =>
			break;
		case nbt_tag::BYTE =>
			fmt::fprintfln(out, "{}", tag._i8)!;
		case nbt_tag::SHORT =>
			fmt::fprintfln(out, "{}", tag._i16)!;
		case nbt_tag::INT =>
			fmt::fprintfln(out, "{}", tag._i32)!;
		case nbt_tag::LONG =>
			fmt::fprintfln(out, "{}", tag._i64)!;
		case nbt_tag::FLOAT =>
			fmt::fprintfln(out, "{}", tag._f32)!;
		case nbt_tag::DOUBLE =>
			fmt::fprintfln(out, "{}", tag._f64)!;
		case nbt_tag::BYTE_ARRAY =>
			fmt::fprintfln(out, "[{} bytes]", tag.length)!;
			const lim = io::limitreader(rd, tag.length);
			io::copy(io::empty, &lim)!;
		case nbt_tag::STRING =>
			fmt::fprint(out, "'")!;
			const lim = io::limitreader(rd, tag.length);
			io::copy(out, &lim)!;
			fmt::fprintln(out, "'")!;
		case nbt_tag::LIST =>
			fmt::fprintfln(out, "{} entries", tag.length)!;
			if (tag.length > 0) {
				do_indent(out, depth)?;
				fmt::fprintln(out, "{")?;

				_dump(out, rd, depth + 1, tag.length)?;

				do_indent(out, depth)?;
				fmt::fprintln(out, "}")?;
			};
		case nbt_tag::COMPOUND =>
			fmt::fprintln(out)?;

			do_indent(out, depth)?;
			fmt::fprintln(out, "{")?;

			_dump(out, rd, depth + 1)?;

			do_indent(out, depth)?;
			fmt::fprintln(out, "}")!;
		};
	};
};
