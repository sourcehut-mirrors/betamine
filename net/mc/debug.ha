use encoding::hex;
use encoding::ucs2;
use log;
use io;

// Prints a human-readable representation of a [[packet]] to the given
// [[io::handle]].
export fn log_packet(
	packet: *packet,
	incoming: bool,
	concise: bool = true,
) void = {
	log::printfln("{} {}",
		if (incoming) "<=" else "=>",
		packet_id_str(packet.id));
	switch (packet.id) {
	case HANDSHAKE =>
		const user = ucs2::fromucs2(packet.handshake.username);
		defer free(user);
		log::printfln("   username: {}", user);
	case LOGIN_REQ =>
		const user = ucs2::fromucs2(packet.login_request.username);
		defer free(user);
		log::printfln("   version: {}", packet.login_request.version);
		log::printfln("   username: {}", user);
		log::printfln("   seed: {}", packet.login_request.seed);
		log::printfln("   dimension: {}", packet.login_request.dimension);
	case CHAT_MESSAGE =>
		const msg = ucs2::fromucs2(packet.chat_message.message);
		defer free(msg);
		log::printfln("   message: {}", msg);
	case PLAYER_POS =>
		log::printfln("   x: {}", packet.player_pos.x);
		log::printfln("   y: {}", packet.player_pos.y);
		log::printfln("   z: {}", packet.player_pos.z);
		log::printfln("   stance: {}", packet.player_pos.stance);
		log::printfln("   ground: {}", packet.player_pos.ground);
	case ENTITY, ENTITY_MOVE, ENTITY_LOOK, ENTITY_MOVE_LOOK, ENTITY_DESTROY =>
		log::printfln("   entity ID: {}", packet.entity.entity_id);
	case CHUNK_ALLOCATE =>
		log::printfln("   <{},{}>; load: {}",
			packet.chunk_allocate.x,
			packet.chunk_allocate.z,
			packet.chunk_allocate.load);
	case BULK_BLOCK_CHANGE =>
		log::printfln("   <{},{}>; {} blocks",
			packet.bulk_block_change.chunk_x,
			packet.bulk_block_change.chunk_z,
			len(packet.bulk_block_change.coords));
	case => void;
	};
};

fn packet_id_str(id: u8) const str = {
	switch (id) {
	case KEEP_ALIVE =>
		return "KEEP_ALIVE";
	case LOGIN_REQ =>
		return "LOGIN_REQ";
	case HANDSHAKE =>
		return "HANDSHAKE";
	case CHAT_MESSAGE =>
		return "CHAT_MESSAGE";
	case TIME_UPDATE =>
		return "TIME_UPDATE";
	case ENTITY_EQUIP =>
		return "ENTITY_EQUIP";
	case SPAWN_POSITION =>
		return "SPAWN_POSITION";
	case USE_ENTITY =>
		return "USE_ENTITY";
	case UPDATE_HEALTH =>
		return "UPDATE_HEALTH";
	case RESPAWN =>
		return "RESPAWN";
	case PLAYER =>
		return "PLAYER";
	case PLAYER_POS =>
		return "PLAYER_POS";
	case PLAYER_LOOK =>
		return "PLAYER_LOOK";
	case PLAYER_POS_LOOK =>
		return "PLAYER_POS_LOOK";
	case PLAYER_DIGGING =>
		return "PLAYER_DIGGING";
	case PLAYER_PLACEBLOCK =>
		return "PLAYER_PLACEBLOCK";
	case HOLD_CHANGE =>
		return "HOLD_CHANGE";
	case USE_BED =>
		return "USE_BED";
	case ANIMATION =>
		return "ANIMATION";
	case ENTITY_ACTION =>
		return "ENTITY_ACTION";
	case SPAWN_PLAYER =>
		return "SPAWN_PLAYER";
	case SPAWN_ITEM =>
		return "SPAWN_ITEM";
	case COLLECT_ITEM =>
		return "COLLECT_ITEM";
	case SPAWN_OBJECT =>
		return "SPAWN_OBJECT";
	case SPAWN_MOB =>
		return "SPAWN_MOB";
	case SPAWN_PAINTING =>
		return "SPAWN_PAINTING";
	case ENTITY_VELOCITY =>
		return "ENTITY_VELOCITY";
	case ENTITY_DESTROY =>
		return "ENTITY_DESTROY";
	case ENTITY =>
		return "ENTITY";
	case ENTITY_MOVE =>
		return "ENTITY_MOVE";
	case ENTITY_LOOK =>
		return "ENTITY_LOOK";
	case ENTITY_MOVE_LOOK =>
		return "ENTITY_MOVE_LOOK";
	case ENTITY_TELEPORT =>
		return "ENTITY_TELEPORT";
	case ENTITY_STATUS =>
		return "ENTITY_STATUS";
	case ENTITY_ATTACH =>
		return "ENTITY_ATTACH";
	case ENTITY_METADATA =>
		return "ENTITY_METADATA";
	case CHUNK_ALLOCATE =>
		return "CHUNK_ALLOCATE";
	case CHUNK_DATA =>
		return "CHUNK_DATA";
	case BULK_BLOCK_CHANGE =>
		return "BULK_BLOCK_CHANGE";
	case BLOCK_CHANGE =>
		return "BLOCK_CHANGE";
	case BLOCK_ACTION =>
		return "BLOCK_ACTION";
	case EXPLOSION =>
		return "EXPLOSION";
	case SOUND_EFFECT =>
		return "SOUND_EFFECT";
	case ENVIRONMENT_STATE =>
		return "ENVIRONMENT_STATE";
	case THUNDERBOLT =>
		return "THUNDERBOLT";
	case WINDOW_OPEN =>
		return "WINDOW_OPEN";
	case WINDOW_CLOSE =>
		return "WINDOW_CLOSE";
	case WINDOW_CLICK =>
		return "WINDOW_CLICK";
	case WINDOW_SET_SLOT =>
		return "WINDOW_SET_SLOT";
	case WINDOW_ITEMS =>
		return "WINDOW_ITEMS";
	case WINDOW_PROGRESS =>
		return "WINDOW_PROGRESS";
	case WINDOW_TRANSACTION =>
		return "WINDOW_TRANSACTION";
	case UPDATE_SIGN =>
		return "UPDATE_SIGN";
	case MAP_DATA =>
		return "MAP_DATA";
	case UPDATE_STAT =>
		return "UPDATE_STAT";
	case DISCONNECT =>
		return "DISCONNECT";
	case =>
		return "UNKNOWN";
	};
};
