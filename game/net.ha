use errors;
use io;
use log;
use net::mc;
use world;

// The network manager manages the state of the network connection.
export type network_manager = struct {
	module,
	next_keepalive: u32,
};

// Initializes the network manager.
export fn network_init(state: *state) void = {
	const netmgr = alloc(network_manager {
		update = &network_update,
		...
	});
	append(state.modules, netmgr);
};

fn network_update(mod: *module, state: *state) void = {
	let net = mod: *network_manager;

	// Process all pending packets
	let packet = mc::EMPTY_PACKET;
	for (true) {
		match (mc::read_packet(state.conn, &packet)) {
		case let err: io::error =>
			if (err is errors::again) {
				break;
			};
			log::fatal(io::strerror(err));
		case void => void;
		};

		network_incoming(net, state, &packet);
	};

	// Other housekeeping
	//
	// Send keep alives every 30 seconds
	if (state.frame_time >= net.next_keepalive) {
		mc::write_keep_alive(state.conn)!;
		net.next_keepalive = state.frame_time + 30000;
	};
};

fn network_incoming(
	net: *network_manager,
	state: *state,
	packet: *mc::packet,
) void = {
	switch (packet.id) {
	case mc::SPAWN_POSITION =>
		const sp = &packet.spawn_position;
		state.world.level.spawn = (sp.x, sp.y, sp.z);
	case mc::PLAYER_POS_LOOK =>
		const ppl = &packet.player_pos_look;
		state.camera.pos = [
			ppl.x: f32,
			ppl.y: f32,
			ppl.z: f32,
		];
		state.camera.yaw = deg2rad(ppl.yaw);
		state.camera.pitch = deg2rad(ppl.pitch);
		mc::write_player_pos_look(state.conn, ppl)!;
	case => void;
	};
};
