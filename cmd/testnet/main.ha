use encoding::ucs2;
use errors;
use io;
use log;
use net::dial;
use net::mc;
use os;

export fn main() void = {
	const conn = dial::dial("tcp", os::args[1], "minecraft")!;
	const mcrd = mc::newreader(conn);

	const user = ucs2::toucs2("betamine");
	defer free(user);

	let packet = mc::packet {
		id = mc::HANDSHAKE,
		handshake = mc::handshake {
			username = user,
		},
	};
	mc::log_packet(&packet, false);
	mc::write_handshake(conn, &packet.handshake)!;

	for (true) {
		match (mc::read_packet(&mcrd, &packet)) {
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
			packet.id = mc::LOGIN_REQ;
			let req = &packet.login_request;
			req.version = mc::VERSION;
			req.username = user;
			req.seed = 0;
			req.dimension = 0;
			mc::log_packet(&packet, false);
			mc::write_login_request(conn, req)!;
		case => void;
		};
	};
};
