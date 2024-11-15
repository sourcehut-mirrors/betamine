use endian;
use errors;
use fs;
use io;
use os;
use strings;

def INIT_BUFSZ = 4096;

// Packet reader mode of operation
export type reader_mode = enum {
	CLIENT,
	SERVER,
};

export type reader = struct {
	sock: io::file,
	mode: reader_mode,
	buf: []u8,
	off: size,
	avail: size,
};

// Initializes a new Minecraft packet reader.
export fn newreader(
	sock: io::file,
	mode: reader_mode = reader_mode::CLIENT,
) reader = {
	const fl = os::getfl(sock)!;
	os::setfl(sock, fl | fs::flag::NONBLOCK)!;
	return reader {
		sock = sock,
		mode = mode,
		buf = alloc([0...], INIT_BUFSZ),
		...
	};
};

// Frees resources associated with a Minecraft packet [[reader]]. Does not close
// the underlying socket.
export fn reader_finish(rd: *reader) void = {
	free(rd.buf);
};

// Reads the next packet from the connection, or returns void if none are ready.
// Note that the packet's contents may be borrowed from the packet reader and
// may be overwritten on the next call to [[read_packet]]. The packet's value is
// undefined if the return value is void.
export fn read_packet(rd: *reader, out: *packet) (void | io::error) = {
	match (_read_packet(rd, out)) {
	case let err: io::error =>
		if (err is errors::again) {
			read_reset(rd);
		};
		return err;
	case void =>
		read_flush(rd);
	};
};

fn _read_packet(rd: *reader, out: *packet) (void | io::error) = {
	out.id = read_i8(rd)?: u8;
	packet_readers[out.id](rd, &out._payload)?;
};

fn read(rd: *reader, n: size) ([]u8 | io::error) = {
	// This function accumulates bytes in the reader's buffer until we can
	// read an entire packet without hitting EAGAIN
	if (rd.off + n <= rd.avail) {
		defer rd.off += n;
		return rd.buf[rd.off..rd.off+n];
	};

	const need = rd.off + n - rd.avail;
	if (rd.off + need > len(rd.buf)) {
		append(rd.buf, [0...], need - len(rd.buf));
	};

	for (rd.avail < rd.off + n) {
		match (io::read(rd.sock, rd.buf[rd.avail..])) {
		case let z: size =>
			rd.avail += z;
		case io::EOF =>
			return errors::invalid;
		case let err: io::error =>
			return err;
		};
	};

	defer rd.off += n;
	return rd.buf[rd.off..rd.off+n];
};

// Resets the buffer offset to zero. Handles the [[errors::again]] case.
fn read_reset(rd: *reader) void = {
	rd.off = 0;
};

// Resets the reader buffer state entirely, ready for the next packet.
fn read_flush(rd: *reader) void = {
	rd.off = 0;
	rd.avail = 0;
};

fn read_i8(rd: *reader) (i8 | io::error) = {
	return read(rd, 1)?[0]: i8;
};

fn read_u8(rd: *reader) (u8 | io::error) = {
	return read(rd, 1)?[0];
};

fn read_i16(rd: *reader) (i16 | io::error) = {
	const buf = read(rd, size(i16))?;
	return endian::begetu16(buf): i16;
};

fn read_i32(rd: *reader) (i32 | io::error) = {
	const buf = read(rd, size(i32))?;
	return endian::begetu16(buf): i32;
};

fn read_int(rd: *reader) (int | io::error) = read_i32(rd)?: int;

fn read_i64(rd: *reader) (i64 | io::error) = {
	const buf = read(rd, size(i64))?;
	return endian::begetu16(buf): i64;
};

fn read_f32(rd: *reader) (f32 | io::error) = {
	return *(&read_i32(rd)?: *f32);
};

fn read_f64(rd: *reader) (f64 | io::error) = {
	return *(&read_i64(rd)?: *f64);
};

fn read_bool(rd: *reader) (bool | io::error) = {
	return read_i8(rd)? != 0;
};

// Return value is borrowed from reader
fn read_string8(rd: *reader) (str | io::error) = {
	const length = read_i16(rd)?: size;
	const buf = read(rd, length)?;
	// XXX: This is strictly speaking Java's dumb "modified UTF-8" format
	match (strings::fromutf8(buf)) {
	case let s: str =>
		return s;
	case =>
		return errors::invalid;
	};
};

// Return value is borrowed from reader
fn read_string16(rd: *reader) ([]u16 | io::error) = {
	const length = read_i16(rd)?: size;
	const buf = read(rd, length * 2)?;
	const buf = &buf[0]: *[*]u16;
	return buf[..length];
};

// TODO: Implement this properly
fn read_metadata(rd: *reader) (void | io::error) = {
	for (true) {
		const key = read_u8(rd)?;
		if (key == 0x7F) {
			break;
		};
		const kind = (key & 0xE0) >> 5;
		const index = key & 0x1F;
		switch (kind) {
		case 0x00 =>
			read_i8(rd)?;
		case 0x01 =>
			read_i16(rd)?;
		case 0x02 =>
			read_int(rd)?;
		case 0x03 =>
			read_f32(rd)?;
		case 0x04 =>
			read_string16(rd)?;
		case 0x05 =>
			// Inventory slot
			read_i16(rd)?; // Item ID
			read_i8(rd)?;  // Count
			read_i16(rd)?; // Metadata
		case 0x06 =>
			// Vector
			read_int(rd)?; // x
			read_int(rd)?; // y
			read_int(rd)?; // z
		case =>
			return errors::invalid;
		};
	};
};
