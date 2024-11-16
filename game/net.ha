use engine;
use errors;
use io;
use log;
use math;
use net::mc;
use types;
use world;

// The network manager manages the state of the network connection.
export type network_manager = struct {
	module,
	next_keepalive: u32,
	next_pos: u32,
};

// Initializes the network manager.
export fn network_init(state: *state) void = {
	const netmgr = alloc(network_manager {
		update = &network_update,
		next_pos = types::U32_MAX,
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
	let player = &state.player;

	// Send keep alives every 30 seconds
	if (state.frame_time >= net.next_keepalive) {
		mc::write_keep_alive(state.conn)!;
		net.next_keepalive = state.frame_time + 30000;
	};

	if (state.frame_time >= net.next_pos) {
		// TODO: Choose appropriate packet based on last position/look
		// sent to the server
		mc::write_player_pos_look(state.conn, &mc::player_pos_look {
			x = player.pos[0],
			y = player.pos[1],
			z = player.pos[2],
			stance = player.pos[1] + player.stance,
			yaw = -(rad2deg(player.yaw) - 180.0) + 180.0,
			pitch = rad2deg(player.pitch),
			ground = true,
		})!;
		net.next_pos = state.frame_time + 50;
	};
};

fn network_incoming(
	net: *network_manager,
	state: *state,
	packet: *mc::packet,
) void = {
	switch (packet.id) {
	case mc::TIME_UPDATE =>
		state.ticks = packet.time_update.time: u64;
	case mc::SPAWN_POSITION =>
		const sp = &packet.spawn_position;
		state.world.level.spawn = (sp.x, sp.y, sp.z);
	case mc::PLAYER_POS_LOOK =>
		const ppl = &packet.player_pos_look;
		state.player.pos = [
			ppl.x: f32,
			ppl.y: f32,
			ppl.z: f32,
		];
		state.player.yaw = deg2rad(-(ppl.yaw - 180.0) + 180.0);
		state.player.pitch = deg2rad(ppl.pitch);
		mc::write_player_pos_look(state.conn, ppl)!;
		net.next_pos = 0;
	case mc::CHUNK_ALLOCATE =>
		const ca = &packet.chunk_allocate;
		if (ca.load) {
			world::get_chunk(&state.world, (ca.x, ca.z))!;
		} else {
			chunkmgr_unload(state.chunkmgr, (ca.x, ca.z));
		};
	case mc::CHUNK_DATA =>
		const cd = &packet.chunk_data;
		const coords: world::coords2D = (
			cd.x >> 4,
			cd.z >> 4,
		);
		let chunk = world::get_chunk(&state.world, coords)!;
		match (world::chunk_frompacket(chunk, cd)) {
		case let err: io::error =>
			log::printfln("WARNING: Error loading chunk <{},{}>: {}",
				cd.x, cd.y, io::strerror(err));
		case void =>
			chunkmgr_enqueue(state.chunkmgr, chunk,
				chunk_neighbor::ALL);
		};
	case => void;
	};
};

fn deg2rad(deg: f32) f32 = {
	return (deg: f64 * math::PI / 180.0): f32;
};

fn rad2deg(rad: f32) f32 = {
	return (rad: f64 * 180.0 / math::PI): f32;
};
