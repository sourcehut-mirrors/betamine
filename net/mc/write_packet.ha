use encoding::ucs2;
use endian;
use io;

// Writes a [[KEEP_ALIVE]] packet to the connection.
export fn write_keep_alive(c: *conn) (void | io::error) = {
	write_begin(c, KEEP_ALIVE);
	write_end(c)?;
};

// Write a [[handshake]] packet to the connection.
export fn write_handshake(
	c: *conn,
	packet: *handshake,
) (void | io::error) = {
	write_begin(c, HANDSHAKE);
	write_string16(c, packet.username);
	write_end(c)?;
};

// Writes a [[login_request]] packet to the connection.
export fn write_login_request(
	c: *conn,
	packet: *login_request,
) (void | io::error) = {
	write_begin(c, LOGIN_REQ);
	write_i32(c, packet.version);
	write_string16(c, packet.username);
	write_i64(c, packet.seed);
	write_i8(c, packet.dimension);
	write_end(c)?;
};

// Writes a [[disconnect_packet]] to the connection. Does not close the socket
// or otherwise clean up the connection -- just sends a DISCONNECT packet.
export fn write_disconnect(
	c: *conn,
	packet: *disconnect_packet,
) (void | io::error) = {
	write_begin(c, DISCONNECT);
	write_string16(c, packet.reason);
	write_end(c)?;
};
