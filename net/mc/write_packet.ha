// TODO: rethink this bit
use encoding::ucs2;
use endian;
use io;

fn write_string16(out: io::handle, data: string16) (void | io::error) = {
	let buf: [2]u8 = [0...];
	endian::beputu16(buf, len(data): u16);
	io::write(out, buf)?;

	const data = (data: *[*]u8)[..len(data)*2];
	io::write(out, data)?;
};

export fn write_handshake(
	out: io::handle,
	packet: *handshake,
) (void | io::error) = {
	io::write(out, [HANDSHAKE])?;
	write_string16(out, packet.username)?;
};

export fn write_login_request(
	out: io::handle,
	packet: *login_request,
) (void | io::error) = {
	io::write(out, [LOGIN_REQ])?;

	let buf: [8]u8 = [0...];
	endian::beputu32(buf, packet.version: u32);
	io::write(out, buf[..4])?;

	write_string16(out, packet.username)?;

	endian::beputu64(buf, packet.seed: u64);
	io::write(out, buf[..8])?;

	buf[0] = packet.dimension: u8;
	io::write(out, buf[..1])?;
};
