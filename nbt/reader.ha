use bufio;
use bytes;
use errors;
use endian;
use io;
use memio;
use math;

export type reader = struct {
	scan: bufio::scanner,
	strvec: memio::stream,
	stack: []rdstate,
};

export type rdstate = struct {
	// COMPOUND or LIST
	tag: nbt_tag,
	// Only valid if LIST
	length: uint,
	etype: nbt_tag,
};

// Reads data from an NBT file. Scan tags with [[next]].
export fn read(in: io::handle) reader = {
	let rd = reader {
		scan = bufio::newscanner(in),
		strvec = memio::dynamic(),
		stack = [],
	};
	insert(rd.stack[0], rdstate {
		tag = nbt_tag::COMPOUND,
		...
	});
	return rd;
};

// Opens the root compound tag of an NBT file.
export fn openroot(rd: *reader) (value | io::error) = {
	const val = next(rd)? as value;
	assert(val.tag == nbt_tag::COMPOUND && val.name == "");
	return val;
};

// Reads the next tag from an NBT [[reader]]. The return value is borrowed from
// the NBT decoder. Following a tag of type BYTE_ARRAY or STRING, the caller is
// expected to [[io::read]] bytes equal to the length provided by
// [[value]].length (and no more) before calling [[next]] again.
export fn next(rd: *reader) (value | io::EOF | io::error) = {
	let state = &rd.stack[0];

	let rdbuf: [8]u8 = [0...];
	let val = value { ... };

	for (state.tag == nbt_tag::LIST) {
		val.tag = state.etype;
		if (state.length != 0) {
			state.length -= 1;
			break;
		};
		delete(rd.stack[0]);
	};

	switch (state.tag) {
	case nbt_tag::COMPOUND =>
		match (bufio::scan_byte(&rd.scan)?) {
		case let t: u8 =>
			val.tag = t: nbt_tag;
		case io::EOF =>
			return io::EOF;
		};
		if (val.tag == nbt_tag::END) yield;

		io::read(&rd.scan, rdbuf[..2])?;
		let n = endian::begetu16(rdbuf): size;

		// XXX: rdbuf is a bit small for this but most strings are not
		// very large so it's fine
		memio::reset(&rd.strvec);
		for (n > 0) {
			const max = if (n > len(rdbuf)) len(rdbuf) else n;
			match (io::read(&rd.scan, rdbuf[..max])?) {
			case let z: size =>
				io::write(&rd.strvec, rdbuf[..z])!;
				n -= z;
			case io::EOF =>
				return io::EOF;
			};
		};

		match (memio::string(&rd.strvec)) {
		case let s: str =>
			val.name = s;
		case =>
			return errors::invalid;
		};
	case nbt_tag::LIST =>
		yield;
	case => abort(); // Invariant
	};

	switch (val.tag) {
	case nbt_tag::END =>
		delete(rd.stack[0]);
		if (len(rd.stack) == 0) {
			return io::EOF;
		};
	case nbt_tag::BYTE =>
		io::read(&rd.scan, rdbuf[..1])?;
		val._i8 = rdbuf[0]: i8;
	case nbt_tag::SHORT =>
		io::read(&rd.scan, rdbuf[..2])?;
		val._i16 = endian::begetu16(rdbuf): i16;
	case nbt_tag::INT =>
		io::read(&rd.scan, rdbuf[..4])?;
		val._i32 = endian::begetu32(rdbuf): i32;
	case nbt_tag::LONG =>
		io::read(&rd.scan, rdbuf[..8])?;
		val._i64 = endian::begetu64(rdbuf): i64;
	case nbt_tag::FLOAT =>
		io::read(&rd.scan, rdbuf[..4])?;
		const u = endian::begetu32(rdbuf): u32;
		val._f32 = math::f32frombits(u);
	case nbt_tag::DOUBLE =>
		io::read(&rd.scan, rdbuf[..8])?;
		const u = endian::begetu64(rdbuf): u64;
		val._f64 = math::f64frombits(u);
	case nbt_tag::BYTE_ARRAY =>
		io::read(&rd.scan, rdbuf[..4])?;
		val.length = endian::begetu32(rdbuf);
	case nbt_tag::STRING =>
		io::read(&rd.scan, rdbuf[..2])?;
		val.length = endian::begetu16(rdbuf);
	case nbt_tag::LIST =>
		io::read(&rd.scan, rdbuf[..1])?;
		const etype = rdbuf[0];

		io::read(&rd.scan, rdbuf[..4])?;
		val.length = endian::begetu32(rdbuf);

		insert(rd.stack[0], rdstate {
			tag = val.tag,
			length = val.length,
			etype = etype: nbt_tag,
		});
	case nbt_tag::COMPOUND =>
		insert(rd.stack[0], rdstate {
			tag = nbt_tag::COMPOUND,
			...
		});
	case =>
		return errors::invalid;
	};

	return val;
};

// Skips the current value (recursively, if compound or list) from an NBT
// [[reader]], advancing to the next position.
export fn skip(rd: *reader, tag: value) (void | io::error) = {
	switch (tag.tag) {
	case nbt_tag::LIST =>
		for (let l = tag.length; l > 0; l -= 1) {
			match (next(rd)?) {
			case io::EOF =>
				break;
			case let t: value =>
				skip(rd, t)?;
			};
		};
	case nbt_tag::COMPOUND =>
		for (const t => next(rd)?) {
			if (t.tag == nbt_tag::END) {
				break;
			};
			skip(rd, t)?;
		};
	case nbt_tag::STRING, nbt_tag::BYTE_ARRAY =>
		const lim = io::limitreader(rd, tag.length);
		io::copy(io::empty, &lim)!;
	case => void; // no-op
	};
};
