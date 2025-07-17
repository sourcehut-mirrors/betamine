use encoding::ucs2;
use errors;
use io;
use log;
use net::dial;

// Minecraft protocol version (for beta 1.7.3)
export def VERSION: int = 14;

@init fn init() void = {
	dial::registersvc("tcp", "minecraft", [], 25565)!;
};

// Dials a Minecraft server.
export fn dial(address: str) (conn | dial::error) = {
	const sock = dial::dial("tcp", address, "minecraft")?;
	return newconn(sock, conn_mode::CLIENT);
};

// Closes a Minecraft connection (without first sending a graceful disconnect
// packet; see [[disconnect]] for this purpose).
export fn close(conn: *conn) void = {
	io::close(conn.sock)!;
	conn_finish(conn);
};

// Disconnects with the given reason and closes the socket.
export fn disconnect(conn: *conn, reason: str) void = {
	const reason = ucs2::toucs2(reason)!;
	defer free(reason);
	write_disconnect(conn, &disconnect_packet {
		reason = reason,
	})!;
	close(conn);
};

// Logs into the server with the given username. Returns the [[login_request]]
// response from the server, or the [[disconnect]] if the connection is refused.
export fn login(
	conn: *conn,
	user: str,
) (login_request | disconnect_packet | io::error) = {
	const user = ucs2::toucs2(user)!;
	defer free(user);

	write_handshake(conn, &handshake {
		username = user,
	})?;

	let packet = EMPTY_PACKET;
	for (true) {
		match (read_packet(conn, &packet)) {
		case let err: io::error =>
			if (err is errors::again) {
				continue;
			};
			return err;
		case void => void;
		};

		switch (packet.id) {
		case HANDSHAKE =>
			const hs = &packet.handshake;
			const chash = ucs2::fromucs2(hs.connection_hash)!;
			defer free(chash);
			if (chash != "-") {
				log::println("Error: online mode servers are not supported");
				return errors::noaccess;
			};
			write_login_request(conn, &login_request {
				version = VERSION,
				username = user,
				...
			})?;
		case LOGIN_REQ =>
			return packet.login_request;
		case DISCONNECT =>
			return packet.disconnect;
		case =>
			return errors::invalid;
		};
	};
};
