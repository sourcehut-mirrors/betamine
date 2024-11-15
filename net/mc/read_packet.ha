use errors;
use io;

type read_packet_fn = fn(rd: *reader, payload: *opaque) (void | io::error);

fn read_invalid(rd: *reader, payload: *opaque) (void | io::error) = {
	return errors::invalid;
};

fn read_keep_alive(rd: *reader, payload: *opaque) (void | io::error) = {
	void; // Empty packet
};

fn read_login_request(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *login_request;
	switch (rd.mode) {
	case reader_mode::CLIENT =>
		p.entity_id = read_int(rd)?;
		p.username = read_string16(rd)?;
		p.seed = read_i64(rd)?;
		p.dimension = read_i8(rd)?;
	case reader_mode::SERVER =>
		p.version = read_int(rd)?;
		p.username = read_string16(rd)?;
		p.seed = read_i64(rd)?;
		p.dimension = read_i8(rd)?;
	};
};

fn read_handshake(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *handshake;
	switch (rd.mode) {
	case reader_mode::CLIENT =>
		p.connection_hash = read_string16(rd)?;
	case reader_mode::SERVER =>
		p.username = read_string16(rd)?;
	};
};

fn read_chat_message(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *chat_message;
	p.message = read_string16(rd)?;
};

fn read_time_update(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *time_update;
	p.time = read_i64(rd)?;
};

fn read_entity_equip(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_equip;
	p.entity_id = read_int(rd)?;
	p.slot = read_i16(rd)?;
	p.item_id = read_i16(rd)?;
	p.metadata = read_i16(rd)?;
};

fn read_spawn_position(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_position;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
};

fn read_use_entity(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *use_entity;
	p.user_id = read_int(rd)?;
	p.targ_id = read_int(rd)?;
	p.left = read_bool(rd)?;
};

fn read_update_health(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *update_health;
	p.health = read_i16(rd)?;
};

fn read_respawn(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *respawn;
	p.dim = read_i8(rd)?;
};

fn read_player(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player;
	p.ground = read_bool(rd)?;
};

fn read_player_pos(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player_pos;
	p.x = read_f64(rd)?;
	p.y = read_f64(rd)?;
	p.stance = read_f64(rd)?;
	p.z = read_f64(rd)?;
	p.ground = read_bool(rd)?;
};

fn read_player_look(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player_look;
	p.yaw = read_f32(rd)?;
	p.pitch = read_f32(rd)?;
	p.ground = read_bool(rd)?;
};

fn read_player_pos_look(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player_pos_look;
	switch (rd.mode) {
	case reader_mode::CLIENT =>
		p.x = read_f64(rd)?;
		p.stance = read_f64(rd)?;
		p.y = read_f64(rd)?;
		p.z = read_f64(rd)?;
		p.yaw = read_f32(rd)?;
		p.pitch = read_f32(rd)?;
		p.ground = read_bool(rd)?;
	case reader_mode::SERVER =>
		p.x = read_f64(rd)?;
		p.y = read_f64(rd)?;
		p.stance = read_f64(rd)?;
		p.z = read_f64(rd)?;
		p.yaw = read_f32(rd)?;
		p.pitch = read_f32(rd)?;
		p.ground = read_bool(rd)?;
	};
};

fn read_player_digging(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player_digging;
	p.status = read_i8(rd)?: dig_status;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
	p.face = read_i8(rd)?: face;
};

fn read_player_placeblock(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *player_placeblock;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
	p.face = read_i8(rd)?: face;
	p.item_id = read_i16(rd)?;
	p.amount = read_i8(rd)?;
	p.metadata = read_i16(rd)?;
};

fn read_hold_change(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *held_item_change;
	p.slot_id = read_i16(rd)?;
};

fn read_use_bed(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *use_bed;
	p.entity_id = read_int(rd)?;
	p.zero = read_i8(rd)?;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
};

fn read_animation(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *animation;
	p.entity_id = read_int(rd)?;
	p.animation = read_i8(rd)?: animation_type;
};

fn read_entity_action(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_action;
	p.entity_id = read_int(rd)?;
	p.action = read_i8(rd)?: action_type;
};

fn read_spawn_player(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_player;
	p.entity_id = read_int(rd)?;
	p.name = read_string16(rd)?;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
	p.item_id = read_i16(rd)?;
};

fn read_spawn_item(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_item;
	p.entity_id = read_int(rd)?;
	p.item_id = read_i16(rd)?;
	p.count = read_i8(rd)?;
	p.metadata = read_i16(rd)?;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
	p.roll = read_i8(rd)?;
};

fn read_collect_item(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *collect_item;
	p.collected_id = read_int(rd)?;
	p.collector_id = read_int(rd)?;
};

fn read_spawn_object(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_object;
	p.entity_id = read_int(rd)?;
	p.object_type = read_i8(rd)?: object_type;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.data = read_int(rd)?;
	if (p.data > 0) {
		p.vel_x = read_i16(rd)?;
		p.vel_y = read_i16(rd)?;
		p.vel_z = read_i16(rd)?;
	};
};

fn read_spawn_mob(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_mob;
	p.entity_id = read_int(rd)?;
	p.mob_type = read_i8(rd)?: mob_type;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
	read_metadata(rd)?; // TODO
};

fn read_spawn_painting(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *spawn_painting;
	p.entity_id = read_int(rd)?;
	p.title = read_string16(rd)?;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.direction = read_int(rd)?;
};

fn read_entity_velocity(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_velocity;
	p.entity_id = read_int(rd)?;
	p.vel_x = read_i16(rd)?;
	p.vel_y = read_i16(rd)?;
	p.vel_z = read_i16(rd)?;
};

fn read_entity_destroy(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_destroy;
	p.entity_id = read_int(rd)?;
};

fn read_entity(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity;
	p.entity_id = read_int(rd)?;
};

fn read_entity_move(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_move;
	p.entity_id = read_int(rd)?;
	p.dx = read_i8(rd)?;
	p.dy = read_i8(rd)?;
	p.dz = read_i8(rd)?;
};

fn read_entity_look(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_look;
	p.entity_id = read_int(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
};

fn read_entity_move_look(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_move_look;
	p.dx = read_i8(rd)?;
	p.dy = read_i8(rd)?;
	p.dz = read_i8(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
};

fn read_entity_teleport(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_teleport;
	p.entity_id = read_int(rd)?;
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
	p.yaw = read_i8(rd)?;
	p.pitch = read_i8(rd)?;
};

fn read_entity_status(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_status;
	p.entity_id = read_int(rd)?;
	p.status = read_i8(rd)?: entity_status_type;
};

fn read_entity_attach(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_attach;
	p.entity_id = read_int(rd)?;
	p.target_id = read_int(rd)?;
};

fn read_entity_metadata(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *entity_metadata;
	p.entity_id = read_int(rd)?;
	read_metadata(rd)?; // TODO
};

fn read_chunk_allocate(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *chunk_allocate;
	p.x = read_int(rd)?;
	p.z = read_int(rd)?;
	p.load = read_bool(rd)?;
};

fn read_chunk_data(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *chunk_data;
	p.x = read_int(rd)?;
	p.y = read_i16(rd)?;
	p.z = read_int(rd)?;
	p.size_x = read_i8(rd)?;
	p.size_y = read_i8(rd)?;
	p.size_z = read_i8(rd)?;

	const length = read_int(rd)?;
	if (length < 0) return errors::invalid;
	const length = length: size;

	p.data = read(rd, length)?;
};

fn read_bulk_block_change(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *bulk_block_change;
	p.chunk_x = read_int(rd)?;
	p.chunk_z = read_int(rd)?;

	const length = read_i16(rd)?;
	if (length < 0) return errors::invalid;
	const length = length: size;

	const coords = read(rd, length / size(i16))?;
	p.coords = (coords: *[*]i16)[..length];
	p.block_ids = read(rd, length)?: []i8;
	p.metadata = read(rd, length)?: []i8;
};

fn read_block_change(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *block_change;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
	p.block_id = read_i8(rd)?;
	p.metadata = read_i8(rd)?;
};

fn read_block_action(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *block_action;
	p.x = read_int(rd)?;
	p.y = read_i16(rd)?;
	p.z = read_int(rd)?;
	p.note.instrument = read_i8(rd)?;
	p.note.pitch = read_i8(rd)?;
};

fn read_explosion(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *explosion;
	p.x = read_f64(rd)?;
	p.y = read_f64(rd)?;
	p.z = read_f64(rd)?;
	p.radius = read_f32(rd)?;

	const length = read_int(rd)?;
	if (length < 0) return errors::invalid;
	const length = length: size;

	const record_size = size((i8, i8, i8));
	const data = read(rd, length * record_size)?;
	p.blocks = (data: *[*](i8, i8, i8))[..length];
};

fn read_sound_effect(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *sound_effect;
	p.effect_id = read_int(rd)?;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
	p.data = read_int(rd)?;
};

fn read_environment_state(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *environment_state;
	p.state_change = read_i8(rd)?: environment_state_change;
};

fn read_thunderbolt(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *thunderbolt;
	p.entity_id = read_int(rd)?;
	read_bool(rd)?; // unused field
	p.x = read_int(rd)?;
	p.y = read_int(rd)?;
	p.z = read_int(rd)?;
};

fn read_window_open(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_open;
	p.window_id = read_i8(rd)?;
	p.kind = read_i8(rd)?: inventory_kind;
	p.window_title = read_string8(rd)?;
	p.nslot = read_i8(rd)?;
};

fn read_window_close(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_close;
	p.window_id = read_i8(rd)?;
};

fn read_slot(rd: *reader, out: *slot) (void | io::error) = {
	out.id = read_i16(rd)?;
	if (out.id == -1) {
		return;
	};
	out.count = read_i8(rd)?;
	out.metadata = read_i16(rd)?;
};

fn read_window_click(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_click;
	p.window_id = read_i8(rd)?;
	p.index = read_i16(rd)?;
	p.right = read_bool(rd)?;
	p.transaction = read_i16(rd)?;
	p.shift = read_bool(rd)?;
	read_slot(rd, &p.item)?;
};

fn read_window_set_slot(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_set_slot;
	p.window_id = read_i8(rd)?;
	p.index = read_i16(rd)?;
	read_slot(rd, &p.item)?;
};

fn read_window_items(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_items;
	p.window_id = read_i8(rd)?;
	p.nitem = read_i16(rd)?;

	const start = tell(rd);
	assert(start == 3);

	for (let i = 0z; i < p.nitem: size; i += 1) {
		let slot = slot { ... };
		read_slot(rd, &slot)?;
	};

	const end = tell(rd);
	p.items = rd.buf[start..end];
};

fn read_window_progress(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_progress;
	p.window_id = read_i8(rd)?;
	p.scalar = read_i16(rd)?;
	p.value = read_i16(rd)?;
};

fn read_window_transaction(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *window_transaction;
	p.window_id = read_i8(rd)?;
	p.transaction = read_i16(rd)?;
	p.accepted = read_bool(rd)?;
};

fn read_update_sign(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *update_sign;
	p.x = read_int(rd)?;
	p.y = read_i8(rd)?;
	p.z = read_int(rd)?;
	for (let s &.. p.text) {
		*s = read_string16(rd)?;
	};
};

fn read_map_data(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *map_data;
	p.item_id = read_i16(rd)?;
	p.metadata = read_i16(rd)?;

	const length = read_u8(rd)?;
	p.data = read(rd, length)?;
};

fn read_update_stat(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *update_stat;
	p.stat_id = read_int(rd)?;
	p.amount = read_i8(rd)?;
};

fn read_disconnect(rd: *reader, payload: *opaque) (void | io::error) = {
	let p = payload: *disconnect;
	p.reason = read_string16(rd)?;
};

const packet_readers: [0x100]*read_packet_fn = [
	&read_keep_alive,		// 0x00 KEEP_ALIVE
	&read_login_request,		// 0x01 LOGIN_REQ
	&read_handshake,		// 0x02 HANDSHAKE
	&read_chat_message,		// 0x03 CHAT_MESSAGE
	&read_time_update,		// 0x04 TIME_UPDATE
	&read_entity_equip,		// 0x05 ENTITY_EQUIP
	&read_spawn_position,		// 0x06 SPAWN_POSITION
	&read_use_entity,		// 0x07 USE_ENTITY
	&read_update_health,		// 0x08 UPDATE_HEALTH
	&read_respawn,			// 0x09 RESPAWN
	&read_player,			// 0x0a PLAYER
	&read_player_pos,		// 0x0b PLAYER_POS
	&read_player_look,		// 0x0c PLAYER_LOOK
	&read_player_pos_look,		// 0x0d PLAYER_POS_LOOK
	&read_player_digging,		// 0x0e PLAYER_DIGGING
	&read_player_placeblock,	// 0x0f PLAYER_PLACEBLOCK
	&read_hold_change,		// 0x10 HOLD_CHANGE
	&read_use_bed,			// 0x11 USE_BED
	&read_animation,		// 0x12 ANIMATION
	&read_entity_action,		// 0x13 ENTITY_ACTION
	&read_spawn_player,		// 0x14 SPAWN_PLAYER
	&read_spawn_item,		// 0x15 SPAWN_ITEM
	&read_collect_item,		// 0x16 COLLECT_ITEM
	&read_spawn_object,		// 0x17 SPAWN_OBJECT
	&read_spawn_mob,		// 0x18 SPAWN_MOB
	&read_spawn_painting,		// 0x19 SPAWN_PAINTING
	&read_invalid,			// 0x1a
	&read_invalid,			// 0x1b
	&read_entity_velocity,		// 0x1c ENTITY_VELOCITY
	&read_entity_destroy,		// 0x1d ENTITY_DESTROY
	&read_entity,			// 0x1e ENTITY
	&read_entity_move,		// 0x1f ENTITY_MOVE
	&read_entity_look,		// 0x20 ENTITY_LOOK
	&read_entity_move_look,		// 0x21 ENTITY_MOVE_LOOK
	&read_entity_teleport,		// 0x22 ENTITY_TELEPORT
	&read_invalid,			// 0x23
	&read_invalid,			// 0x24
	&read_invalid,			// 0x25
	&read_entity_status,		// 0x26 ENTITY_STATUS
	&read_entity_attach,		// 0x27 ENTITY_ATTACH
	&read_entity_metadata,		// 0x28 ENTITY_METADATA
	&read_invalid,			// 0x29
	&read_invalid,			// 0x2a
	&read_invalid,			// 0x2b
	&read_invalid,			// 0x2c
	&read_invalid,			// 0x2d
	&read_invalid,			// 0x2e
	&read_invalid,			// 0x2f
	&read_invalid,			// 0x30
	&read_invalid,			// 0x31
	&read_chunk_allocate,		// 0x32 CHUNK_ALLOCATE
	&read_chunk_data,		// 0x33 CHUNK_DATA
	&read_bulk_block_change,	// 0x34 BULK_BLOCK_CHANGE
	&read_block_change,		// 0x35 BLOCK_CHANGE
	&read_block_action,		// 0x36 BLOCK_ACTION
	&read_invalid,			// 0x37
	&read_invalid,			// 0x38
	&read_invalid,			// 0x39
	&read_invalid,			// 0x3a
	&read_invalid,			// 0x3b
	&read_explosion,		// 0x3c EXPLOSION
	&read_sound_effect,		// 0x3d SOUND_EFFECT
	&read_invalid,			// 0x3e
	&read_invalid,			// 0x3f
	&read_invalid,			// 0x40
	&read_invalid,			// 0x41
	&read_invalid,			// 0x42
	&read_invalid,			// 0x43
	&read_invalid,			// 0x44
	&read_invalid,			// 0x45
	&read_environment_state,	// 0x46 ENVIRONMENT_STATE
	&read_thunderbolt,		// 0x47 THUNDERBOLT
	&read_invalid,			// 0x48
	&read_invalid,			// 0x49
	&read_invalid,			// 0x4a
	&read_invalid,			// 0x4b
	&read_invalid,			// 0x4c
	&read_invalid,			// 0x4d
	&read_invalid,			// 0x4e
	&read_invalid,			// 0x4f
	&read_invalid,			// 0x50
	&read_invalid,			// 0x51
	&read_invalid,			// 0x52
	&read_invalid,			// 0x53
	&read_invalid,			// 0x54
	&read_invalid,			// 0x55
	&read_invalid,			// 0x56
	&read_invalid,			// 0x57
	&read_invalid,			// 0x58
	&read_invalid,			// 0x59
	&read_invalid,			// 0x5a
	&read_invalid,			// 0x5b
	&read_invalid,			// 0x5c
	&read_invalid,			// 0x5d
	&read_invalid,			// 0x5e
	&read_invalid,			// 0x5f
	&read_invalid,			// 0x60
	&read_invalid,			// 0x61
	&read_invalid,			// 0x62
	&read_invalid,			// 0x63
	&read_window_open,		// 0x64 WINDOW_OPEN
	&read_window_close,		// 0x65 WINDOW_CLOSE
	&read_window_click,		// 0x66 WINDOW_CLICK
	&read_window_set_slot,		// 0x67 WINDOW_SET_SLOT
	&read_window_items,		// 0x68 WINDOW_ITEMS
	&read_window_progress,		// 0x69 WINDOW_PROGRESS
	&read_window_transaction,	// 0x6a WINDOW_TRANSACTION
	&read_invalid,			// 0x6b
	&read_invalid,			// 0x6c
	&read_invalid,			// 0x6d
	&read_invalid,			// 0x6e
	&read_invalid,			// 0x6f
	&read_invalid,			// 0x70
	&read_invalid,			// 0x71
	&read_invalid,			// 0x72
	&read_invalid,			// 0x73
	&read_invalid,			// 0x74
	&read_invalid,			// 0x75
	&read_invalid,			// 0x76
	&read_invalid,			// 0x77
	&read_invalid,			// 0x78
	&read_invalid,			// 0x79
	&read_invalid,			// 0x7a
	&read_invalid,			// 0x7b
	&read_invalid,			// 0x7c
	&read_invalid,			// 0x7d
	&read_invalid,			// 0x7e
	&read_invalid,			// 0x7f
	&read_invalid,			// 0x80
	&read_invalid,			// 0x81
	&read_update_sign,		// 0x82 UPDATE_SIGN
	&read_map_data,			// 0x83 MAP_DATA
	&read_invalid,			// 0x84
	&read_invalid,			// 0x85
	&read_invalid,			// 0x86
	&read_invalid,			// 0x87
	&read_invalid,			// 0x88
	&read_invalid,			// 0x89
	&read_invalid,			// 0x8a
	&read_invalid,			// 0x8b
	&read_invalid,			// 0x8c
	&read_invalid,			// 0x8d
	&read_invalid,			// 0x8e
	&read_invalid,			// 0x8f
	&read_invalid,			// 0x90
	&read_invalid,			// 0x91
	&read_invalid,			// 0x92
	&read_invalid,			// 0x93
	&read_invalid,			// 0x94
	&read_invalid,			// 0x95
	&read_invalid,			// 0x96
	&read_invalid,			// 0x97
	&read_invalid,			// 0x98
	&read_invalid,			// 0x99
	&read_invalid,			// 0x9a
	&read_invalid,			// 0x9b
	&read_invalid,			// 0x9c
	&read_invalid,			// 0x9d
	&read_invalid,			// 0x9e
	&read_invalid,			// 0x9f
	&read_invalid,			// 0xa0
	&read_invalid,			// 0xa1
	&read_invalid,			// 0xa2
	&read_invalid,			// 0xa3
	&read_invalid,			// 0xa4
	&read_invalid,			// 0xa5
	&read_invalid,			// 0xa6
	&read_invalid,			// 0xa7
	&read_invalid,			// 0xa8
	&read_invalid,			// 0xa9
	&read_invalid,			// 0xaa
	&read_invalid,			// 0xab
	&read_invalid,			// 0xac
	&read_invalid,			// 0xad
	&read_invalid,			// 0xae
	&read_invalid,			// 0xaf
	&read_invalid,			// 0xb0
	&read_invalid,			// 0xb1
	&read_invalid,			// 0xb2
	&read_invalid,			// 0xb3
	&read_invalid,			// 0xb4
	&read_invalid,			// 0xb5
	&read_invalid,			// 0xb6
	&read_invalid,			// 0xb7
	&read_invalid,			// 0xb8
	&read_invalid,			// 0xb9
	&read_invalid,			// 0xba
	&read_invalid,			// 0xbb
	&read_invalid,			// 0xbc
	&read_invalid,			// 0xbd
	&read_invalid,			// 0xbe
	&read_invalid,			// 0xbf
	&read_invalid,			// 0xc0
	&read_invalid,			// 0xc1
	&read_invalid,			// 0xc2
	&read_invalid,			// 0xc3
	&read_invalid,			// 0xc4
	&read_invalid,			// 0xc5
	&read_invalid,			// 0xc6
	&read_invalid,			// 0xc7
	&read_update_stat,		// 0xc8 UPDATE_STAT
	&read_invalid,			// 0xc9
	&read_invalid,			// 0xca
	&read_invalid,			// 0xcb
	&read_invalid,			// 0xcc
	&read_invalid,			// 0xcd
	&read_invalid,			// 0xce
	&read_invalid,			// 0xcf
	&read_invalid,			// 0xd0
	&read_invalid,			// 0xd1
	&read_invalid,			// 0xd2
	&read_invalid,			// 0xd3
	&read_invalid,			// 0xd4
	&read_invalid,			// 0xd5
	&read_invalid,			// 0xd6
	&read_invalid,			// 0xd7
	&read_invalid,			// 0xd8
	&read_invalid,			// 0xd9
	&read_invalid,			// 0xda
	&read_invalid,			// 0xdb
	&read_invalid,			// 0xdc
	&read_invalid,			// 0xdd
	&read_invalid,			// 0xde
	&read_invalid,			// 0xdf
	&read_invalid,			// 0xe0
	&read_invalid,			// 0xe1
	&read_invalid,			// 0xe2
	&read_invalid,			// 0xe3
	&read_invalid,			// 0xe4
	&read_invalid,			// 0xe5
	&read_invalid,			// 0xe6
	&read_invalid,			// 0xe7
	&read_invalid,			// 0xe8
	&read_invalid,			// 0xe9
	&read_invalid,			// 0xea
	&read_invalid,			// 0xeb
	&read_invalid,			// 0xec
	&read_invalid,			// 0xed
	&read_invalid,			// 0xee
	&read_invalid,			// 0xef
	&read_invalid,			// 0xf0
	&read_invalid,			// 0xf1
	&read_invalid,			// 0xf2
	&read_invalid,			// 0xf3
	&read_invalid,			// 0xf4
	&read_invalid,			// 0xf5
	&read_invalid,			// 0xf6
	&read_invalid,			// 0xf7
	&read_invalid,			// 0xf8
	&read_invalid,			// 0xf9
	&read_invalid,			// 0xfa
	&read_invalid,			// 0xfb
	&read_invalid,			// 0xfc
	&read_invalid,			// 0xfd
	&read_invalid,			// 0xfe
	&read_disconnect,		// 0xff DISCONNECT
];
