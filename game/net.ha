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
	last_pos: engine::entity,
	next_pos: u32,
};

// Initializes the network manager.
export fn network_init(state: *state) void = {
	const netmgr = alloc(network_manager {
		update = &network_update,
		next_pos = types::U32_MAX,
		last_pos = *(&state.player: *engine::entity),
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
		net_update_player(net, state);
		net.next_pos = state.frame_time + 50;
	};
};

fn net_update_player(
	net: *network_manager,
	state: *state,
) void = {
	defer net.last_pos = *(&state.player: *engine::entity);
	const player = &state.player, prev = &net.last_pos;
	const pos_diff =
		player.pos[0] != prev.pos[0] ||
		player.pos[1] != prev.pos[1] ||
		player.pos[2] != prev.pos[2];
	const look_diff =
		player.yaw != prev.yaw ||
		player.pitch != prev.pitch;
	const yaw = -(rad2deg(player.yaw) - 180.0) + 180.0;
	const pitch = -(rad2deg(player.pitch) - 180.0) + 180.0;
	const stance = player.pos[1] + player.stance;

	if (pos_diff && look_diff) {
		mc::write_player_pos_look(state.conn, &mc::player_pos_look {
			x = player.pos[0],
			y = player.pos[1],
			z = player.pos[2],
			stance = stance,
			yaw = yaw,
			pitch = pitch,
			ground = player.ground,
		})!;
	} else if (pos_diff) {
		mc::write_player_pos(state.conn, &mc::player_pos {
			x = player.pos[0],
			y = player.pos[1],
			z = player.pos[2],
			stance = stance,
			ground = player.ground,
		})!;
	} else if (look_diff) {
		mc::write_player_look(state.conn, &mc::player_look {
			yaw = yaw,
			pitch = pitch,
			ground = player.ground,
		})!;
	} else {
		mc::write_player(state.conn, &mc::player {
			ground = player.ground,
		})!;
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
		state.player.ground = ppl.ground;
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
	case mc::BLOCK_CHANGE =>
		const bc = &packet.block_change;
		world::set(&state.world, (bc.x, bc.y, bc.z),
			&world::voxel {
				id = bc.block_id: u8,
				data = bc.metadata: u8,
				...
			})!;
		const coords = world::world_to_chunk((bc.x, bc.y, bc.z));
		const chunk = world::get_chunk(&state.world, coords)!;
		chunkmgr_enqueue(state.chunkmgr, chunk);
	case => void;
	};
};

fn deg2rad(deg: f32) f32 = {
	return (deg: f64 * math::PI / 180.0): f32;
};

fn rad2deg(rad: f32) f32 = {
	return (rad: f64 * 180.0 / math::PI): f32;
};
