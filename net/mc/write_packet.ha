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

// Writes a [[player]] packet to the connection.
export fn write_player(
	c: *conn,
	packet: *player,
) (void | io::error) = {
	write_begin(c, PLAYER);
	write_bool(c, packet.ground);
	write_end(c)?;
};

// Writes a [[player_pos_look]] packet to the connection.
export fn write_player_pos_look(
	c: *conn,
	packet: *player_pos_look,
) (void | io::error) = {
	write_begin(c, PLAYER_POS_LOOK);

	switch (c.mode) {
	case conn_mode::CLIENT =>
		write_f64(c, packet.x);
		write_f64(c, packet.y);
		write_f64(c, packet.stance);
		write_f64(c, packet.z);
		write_f32(c, packet.yaw);
		write_f32(c, packet.pitch);
		write_bool(c, packet.ground);
	case conn_mode::SERVER =>
		write_f64(c, packet.x);
		write_f64(c, packet.stance);
		write_f64(c, packet.y);
		write_f64(c, packet.z);
		write_f32(c, packet.yaw);
		write_f32(c, packet.pitch);
		write_bool(c, packet.ground);
	};

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
