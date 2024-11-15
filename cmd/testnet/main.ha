use encoding::ucs2;
use errors;
use io;
use log;
use net::mc;
use os;

export fn main() void = {
	const conn = mc::dial(os::args[1])!;
	const user = ucs2::toucs2("betamine");
	defer free(user);

	mc::write_handshake(&conn, &mc::handshake {
		username = user,
	})!;

	for (true) {
		let packet = mc::EMPTY_PACKET;
		match (mc::read_packet(&conn, &packet)) {
		case let err: io::error =>
			if (err is errors::again) {
				continue;
			};
			log::fatal(io::strerror(err));
		case void => void;
		};

		mc::log_packet(&packet, true);

		switch (packet.id) {
		case mc::HANDSHAKE =>
			mc::write_login_request(&conn, &mc::login_request {
				version = mc::VERSION,
				username = user,
				...
			})!;
		case => void;
		};
	};
};
