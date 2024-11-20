use endian;
use errors;
use fs;
use io;
use log;
use memio;
use os;
use strings;

def INIT_BUFSZ = 4096;

// Packet conn mode of operation
export type conn_mode = enum {
	CLIENT,
	SERVER,
};

export type conn = struct {
	sock: io::file,
	mode: conn_mode,
	wbuf: memio::stream,
	rbuf: []u8,
	roff: size,
	ravail: size,
};

fn newconn(
	sock: io::file,
	mode: conn_mode = conn_mode::CLIENT,
) conn = {
	const fl = os::getflags(sock)!;
	os::setflags(sock, fl | fs::flag::NONBLOCK)!;
	return conn {
		sock = sock,
		mode = mode,
		wbuf = memio::dynamic(),
		rbuf = alloc([0...], INIT_BUFSZ),
		...
	};
};

// Frees resources associated with a Minecraft packet [[conn]]. Does not close
// the underlying socket.
fn conn_finish(c: *conn) void = {
	io::close(&c.wbuf)!;
	free(c.rbuf);
};

// Reads the next packet from the connection, or returns [[errors::again]] if
// none are ready. Note that the packet's contents may be borrowed from the
// packet conn and may be overwritten on the next call to [[read_packet]].
export fn read_packet(c: *conn, out: *packet) (void | io::error) = {
	match (_read_packet(c, out)) {
	case let err: io::error =>
		if (err is errors::again) {
			read_reset(c);
		};
		return err;
	case void =>
		read_flush(c);
	};
};

fn write_begin(c: *conn, id: u8) void = {
	memio::reset(&c.wbuf);
	write_u8(c, id);
};

fn write_end(c: *conn) (void | io::error) = {
	const data = memio::buffer(&c.wbuf);
	io::writeall(c.sock, data)?;
};

fn _read_packet(c: *conn, out: *packet) (void | io::error) = {
	out.id = read_i8(c)?: u8;

	const decoder = packet_conns[out.id];
	if (decoder == &read_invalid) {
		log::printfln("Invalid packet with ID {:x}", out.id);
	};

	decoder(c, &out._payload)?;
};

fn read(c: *conn, n: size) ([]u8 | io::error) = {
	// This function accumulates bytes in the conn's buffer until we can
	// read an entire packet without hitting EAGAIN
	if (c.roff + n <= c.ravail) {
		defer c.roff += n;
		return c.rbuf[c.roff..c.roff+n];
	};

	const need = c.roff + n - c.ravail;
	if (c.roff + need > len(c.rbuf)) {
		append(c.rbuf, [0...], c.roff + need - len(c.rbuf));
	};

	for (c.ravail < c.roff + n) {
		match (io::read(c.sock, c.rbuf[c.ravail..c.roff+n])) {
		case let z: size =>
			c.ravail += z;
		case let err: io::error =>
			return err;
		case io::EOF =>
			return errors::netunreachable;
		};
	};

	defer c.roff += n;
	return c.rbuf[c.roff..c.roff+n];
};

// Resets the buffer offset to zero. Handles the [[errors::again]] case.
fn read_reset(c: *conn) void = {
	c.roff = 0;
};

// Resets the conn buffer state entirely, ready for the next packet.
fn read_flush(c: *conn) void = {
	c.roff = 0;
	c.ravail = 0;
};

fn tell(c: *conn) size = c.roff;

fn read_i8(c: *conn) (i8 | io::error) = {
	return read(c, 1)?[0]: i8;
};

fn write_i8(c: *conn, v: i8) void = {
	io::write(&c.wbuf, [v: u8])!;
};

fn read_u8(c: *conn) (u8 | io::error) = {
	return read(c, 1)?[0];
};

fn write_u8(c: *conn, v: u8) void = {
	io::write(&c.wbuf, [v])!;
};

fn read_i16(c: *conn) (i16 | io::error) = {
	const buf = read(c, size(i16))?;
	return endian::begetu16(buf): i16;
};

fn write_i16(c: *conn, v: i16) void = {
	let buf: [size(i16)]u8 = [0...];
	endian::beputu16(buf, v: u16);
	io::write(&c.wbuf, buf)!;
};

fn read_i32(c: *conn) (i32 | io::error) = {
	const buf = read(c, size(i32))?;
	return endian::begetu32(buf): i32;
};

fn write_i32(c: *conn, v: i32) void = {
	let buf: [size(i32)]u8 = [0...];
	endian::beputu32(buf, v: u32);
	io::write(&c.wbuf, buf)!;
};

fn read_i64(c: *conn) (i64 | io::error) = {
	const buf = read(c, size(i64))?;
	return endian::begetu64(buf): i64;
};

fn write_i64(c: *conn, v: i64) void = {
	let buf: [size(i64)]u8 = [0...];
	endian::beputu64(buf, v: u64);
	io::write(&c.wbuf, buf)!;
};

fn read_int(c: *conn) (int | io::error) = {
	return read_i32(c)?: int;
};

fn write_int(c: *conn, i: int) void = {
	write_i32(c, i);
};

fn read_f32(c: *conn) (f32 | io::error) = {
	return *(&read_i32(c)?: *f32);
};

fn write_f32(c: *conn, v: f32) void = {
	write_i32(c, *(&v: *i32));
};

fn read_f64(c: *conn) (f64 | io::error) = {
	return *(&read_i64(c)?: *f64);
};

fn write_f64(c: *conn, v: f64) void = {
	write_i64(c, *(&v: *i64));
};

fn read_bool(c: *conn) (bool | io::error) = {
	return read_i8(c)? != 0;
};

fn write_bool(c: *conn, v: bool) void = {
	write_i8(c, if (v) 1 else 0);
};

// Return value is borrowed from conn
fn read_string8(c: *conn) (str | io::error) = {
	const length = read_i16(c)?: size;
	if (length == 0) {
		return "";
	};
	const buf = read(c, length)?;
	// XXX: This is strictly speaking Java's dumb "modified UTF-8" format
	match (strings::fromutf8(buf)) {
	case let s: str =>
		return s;
	case =>
		return errors::invalid;
	};
};

fn write_string8(c: *conn, data: str) void = {
	write_i16(c, len(data): i16);
	io::write(&c.wbuf, strings::toutf8(data))!;
};

// Return value is borrowed from conn
fn read_string16(c: *conn) ([]u16 | io::error) = {
	const length = read_i16(c)?: size;
	if (length == 0) {
		return [];
	};
	const buf = read(c, length * 2)?;
	const buf = &buf[0]: *[*]u16;
	return buf[..length];
};

fn write_string16(c: *conn, data: string16) void = {
	write_i16(c, len(data): i16);
	const data = (data: *[*]u8)[..len(data)*2];
	io::write(&c.wbuf, data)!;
};

// TODO: Implement this properly
fn read_metadata(c: *conn) (void | io::error) = {
	for (true) {
		const key = read_u8(c)?;
		if (key == 0x7F) {
			break;
		};
		const kind = (key & 0xE0) >> 5;
		const index = key & 0x1F;
		switch (kind) {
		case 0x00 =>
			read_i8(c)?;
		case 0x01 =>
			read_i16(c)?;
		case 0x02 =>
			read_int(c)?;
		case 0x03 =>
			read_f32(c)?;
		case 0x04 =>
			read_string16(c)?;
		case 0x05 =>
			// Inventory slot
			read_i16(c)?; // Item ID
			read_i8(c)?;  // Count
			read_i16(c)?; // Metadata
		case 0x06 =>
			// Vector
			read_int(c)?; // x
			read_int(c)?; // y
			read_int(c)?; // z
		case =>
			return errors::invalid;
		};
	};
};
