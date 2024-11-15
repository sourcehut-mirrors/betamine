// A Minecraft protocol packet.
export type packet = struct {
	id: u8,
	union {
		_payload: u8,
		login_request: login_request,
		handshake: handshake,
		chat_message: chat_message,
		time_update: time_update,
		entity_equip: entity_equip,
		spawn_position: spawn_position,
		use_entity: use_entity,
		update_health: update_health,
		respawn: respawn,
		player: player,
		player_pos: player_pos,
		player_look: player_look,
		player_pos_look: player_pos_look,
		player_digging: player_digging,
		player_placeblock: player_placeblock,
		held_item_change: held_item_change,
		use_bed: use_bed,
		animation: animation,
		entity_action: entity_action,
		spawn_player: spawn_player,
		spawn_item: spawn_item,
		collect_item: collect_item,
		spawn_object: spawn_object,
		spawn_mob: spawn_mob,
		spawn_painting: spawn_painting,
		entity: entity,
		entity_velocity: entity_velocity,
		entity_destroy: entity_destroy,
		entity_move: entity_move,
		entity_look: entity_look,
		entity_move_look: entity_move_look,
		entity_teleport: entity_teleport,
		entity_status: entity_status,
		entity_attach: entity_attach,
		entity_metadata: entity_metadata,
		chunk_allocate: chunk_allocate,
		chunk_data: chunk_data,
		bulk_block_change: bulk_block_change,
		block_change: block_change,
		block_action: block_action,
		explosion: explosion,
		sound_effect: sound_effect,
		environment_state: environment_state,
		thunderbolt: thunderbolt,
		window_open: window_open,
		window_close: window_close,
		window_click: window_click,
		window_set_slot: window_set_slot,
		window_items: window_items,
		window_progress: window_progress,
		window_transaction: window_transaction,
		update_sign: update_sign,
		map_data: map_data,
		update_stat: update_stat,
		disconnect: disconnect,
	},
};

// UCS-16 string.
export type string16 = []u16;

// Login request packet
export type login_request = struct {
	union {
		version: int,
		entity_id: int,
	},
	username: string16,
	seed: i64,
	dimension: i8,
};

// Handshake packet
export type handshake = struct {
	union {
		username: string16,
		connection_hash: string16,
	},
};

// Chat message packet
export type chat_message = struct {
	message: string16,
};

// Time update packet
export type time_update = struct {
	time: i64,
};

// Entity equipment packet
export type entity_equip = struct {
	entity_id: int,
	slot: i16,
	item_id: i16,
	metadata: i16,
};

// Spawn position packet
export type spawn_position = struct {
	x: int,
	y: int,
	z: int,
};

// "Use" entity packet
export type use_entity = struct {
	user_id: int,
	targ_id: int,
	left: bool,
};

// Update health packet
export type update_health = struct {
	health: i16,
};

// Respawn packet
export type respawn = struct {
	dim: i8,
};

// Player update packet
export type player = struct {
	ground: bool,
};

// Player position packet
export type player_pos = struct {
	player,
	x: f64,
	y: f64,
	z: f64,
	stance: f64,
};

// Player look packet
export type player_look = struct {
	player,
	yaw: f32,
	pitch: f32,
};

// Player position & look packet
export type player_pos_look = struct {
	player,
	x: f64,
	y: f64,
	z: f64,
	stance: f64,
	yaw: f32,
	pitch: f32,
};

// Status of a [[player_digging]] packet
export type dig_status = enum i8 {
	DIG_BEGIN = 0,
	DIG_END = 2,
	ITEM_DROP = 4,
};

// Block face
export type face = enum i8 {
	T = 0,
	B = 1,
	N = 2,
	S = 3,
	W = 4,
	E = 5,
};

// Player digging packet
export type player_digging = struct {
	status: dig_status,
	face: face,
	x: int,
	y: i8,
	z: int,
};

// Player block placement packet
export type player_placeblock = struct {
	x: int,
	y: i8,
	z: int,
	face: face,
	item_id: i16,
	amount: i8,
	metadata: i16,
};

// Held item change packet
export type held_item_change = struct {
	slot_id: i16,
};

// Use bed packet
export type use_bed = struct {
	entity_id: int,
	// Always zero
	zero: i8,
	// Block coordinates of the headboard
	x: int,
	y: i8,
	z: int,
};

// Animation type for [[animation]] packet
export type animation_type = enum i8 {
	NONE = 0,
	SWING_ARM = 1,
	DAMAGE = 2,
	LEAVE_BED = 3,
	CROUCH = 104,
	UNCROUCH = 105,
	UNKNOWN = 102,
};

// Animation packet
export type animation = struct {
	entity_id: int,
	animation: animation_type,
};

// Action type for [[entity_action]] packet
export type action_type = enum i8 {
	CROUCH = 1,
	UNCROUCH = 2,
	LEAVE_BED = 3,
};

// Entity action packet
export type entity_action = struct {
	entity_id: int,
	action: action_type,
};

// Spawn player packet
export type spawn_player = struct {
	entity_id: int,
	name: string16,
	x: int, // x * 32.0
	y: int, // y * 32.0
	z: int, // z * 32.0
	yaw: i8,
	pitch: i8,
	// Zero indicates no item held
	item_id: i16,
};

// Spawn item packet
export type spawn_item = struct {
	entity_id: int,
	item_id: i16,
	count: i8,
	metadata: i16,
	x: int,
	y: int,
	z: int,
	yaw: i8,
	pitch: i8,
	roll: i8,
};

// Collect item packet
export type collect_item = struct {
	collected_id: int,
	collector_id: int,
};

// Type of object entity
export type object_type = enum i8 {
	BOAT = 1,
	MINECART = 10,
	STORAGE_CART = 11,
	POWERED_CART = 12,
	TNT = 50,
	ARROW = 60,
	SNOWBALL = 61,
	EGG = 61,
	SAND = 70,
	GRAVEL = 71,
	FISHING_FLOAT = 90,
};

// Spawn object packet
export type spawn_object = struct {
	entity_id: int,
	object_type: object_type,
	x: int,
	y: int,
	z: int,
	data: int,
	vel_x: i16,
	vel_y: i16,
	vel_z: i16,
};

// Mob type for [[spawn_mob]] packet
export type mob_type = enum i8 {
	CREEPER = 50,
	SKELETON = 51,
	SPIDER = 52,
	GIANT_ZOMBIE = 53,
	ZOMBIE = 54,
	SLIME = 55,
	GHAST = 56,
	ZOMBIE_PIGMAN = 57,
	PIG = 90,
	SHEEP = 91,
	COW = 92,
	CHICKEN = 93,
	SQUID = 94,
	WOLF = 95,
};

// Spawn mob packet
export type spawn_mob = struct {
	entity_id: int,
	mob_type: mob_type,
	x: int,
	y: int,
	z: int,
	yaw: i8,
	pitch: i8,
	// Includes the terminating 0x7F byte
	metadata: []u8,
};

// Spawn painting packet
export type spawn_painting = struct {
	entity_id: int,
	title: string16,
	x: int,
	y: int,
	z: int,
	direction: int,
};

// Entity packet
export type entity = struct {
	entity_id: int,
};

// Entity velocity packet
export type entity_velocity = struct {
	entity,
	vel_x: i16,
	vel_y: i16,
	vel_z: i16,
};

// Entity destroy packet
export type entity_destroy = struct {
	entity,
};

// Entity move packet
export type entity_move = struct {
	entity,
	dx: i8,
	dy: i8,
	dz: i8,
};

// Entity look
export type entity_look = struct {
	entity,
	yaw: i8,
	pitch: i8,
};

// Entity move & look packet
export type entity_move_look = struct {
	entity,
	dx: i8,
	dy: i8,
	dz: i8,
	yaw: i8,
	pitch: i8,
};

// Entity teleport packet
export type entity_teleport = struct {
	entity,
	x: int,
	y: int,
	z: int,
	yaw: i8,
	pitch: i8,
};

// Status change associated with [[entity_status]] packet
export type entity_status_type = enum i8 {
	ENTITY_HURT = 2,
	ENTITY_KILLED = 3,
	WOLF_TAMING = 6,
	WOLF_TAMED = 7,
	WOLF_SHAKING = 8,
};

// Entity status packet
export type entity_status = struct {
	entity,
	status: entity_status_type,
};

// Entity attach packet
export type entity_attach = struct {
	entity,
	target_id: int,
};

// Entity metadata packet
export type entity_metadata = struct {
	entity,
	// Includes terminating 0x7F
	metadata: []u8,
};

// Chunk allocate packet
export type chunk_allocate = struct {
	x: int,
	z: int,
	// If false, unload the chunk
	load: bool,
};

// Chunk data packet
export type chunk_data = struct {
	x: int,
	y: i16,
	z: int,
	size_x: i8,
	size_y: i8,
	size_z: i8,
	// Compressed with zlib
	data: []u8,
};

// Bulk block change packet
export type bulk_block_change = struct {
	chunk_x: int,
	chunk_z: int,
	coords: []i16,
	block_ids: []i8,
	metadata: []i8,
};

// Block change packet
export type block_change = struct {
	x: int,
	y: i8,
	z: int,
	block_id: i8,
	metadata: i8,
};

// Block action packet
export type block_action = struct {
	x: int,
	y: i16,
	z: int,
	union {
		note: struct {
			instrument: i8,
			pitch: i8,
		},
		piston: struct {
			state: i8,
			direction: i8,
		},
	},
};

// Explosion packet
export type explosion = struct {
	x: f64,
	y: f64,
	z: f64,
	radius: f32,
	blocks: [](i8, i8, i8),
};

// Sound effect packet
export type sound_effect = struct {
	effect_id: int,
	x: int,
	y: i8,
	z: int,
	data: int,
};

// State change associated with an [[environment_state]] packet
export type environment_state_change = enum i8 {
	INVALID_BED,
	RAIN_BEGIN,
	RAIN_END,
};

// Environment state change packet
export type environment_state = struct {
	state_change: environment_state_change,
};

// Thunderbolt spawn packet
export type thunderbolt = struct {
	entity_id: int,
	x: int,
	y: int,
	z: int,
};

// Kind of inventory associated with [[open_window]].
export type inventory_kind = enum i8 {
	CHEST,
	WORKBENCH,
	FURNACE,
	DISPENSER,
};

// Window open packet
export type window_open = struct {
	window_id: i8,
	kind: inventory_kind,
	window_title: str,
	nslot: i8,
};

// Window close packet
export type window_close = struct {
	window_id: i8,
};

// An inventory slot.
export type slot = struct {
	id: i16,
	count: i8,
	metadata: i16,
};

// Window click packet
export type window_click = struct {
	window_id: i8,
	index: i16,
	right: bool,
	transaction: i16,
	shift: bool,
	item: slot,
};

// Window set slot packet
export type window_set_slot = struct {
	window_id: i8,
	index: i16,
	item: slot,
};

// Window items packet
export type window_items = struct {
	window_id: i8,
	nitem: i16,
	// Decode with [[slots_decode]]
	items: []u8,
};

// Window progress packet
export type window_progress = struct {
	window_id: i8,
	scalar: i16,
	value: i16,
};

// Window transaction packet
export type window_transaction = struct {
	window_id: i8,
	transaction: i16,
	accepted: bool,
};

// Update sign packet
export type update_sign = struct {
	x: int,
	y: i8,
	z: int,
	text: [4]string16,
};

// Map data packet
export type map_data = struct {
	item_id: i16,
	metadata: i16,
	data: []u8,
};

// Update statistic packet
export type update_stat = struct {
	stat_id: int,
	amount: i8,
};

// Disconnect packet
export type disconnect = struct {
	reason: string16,
};
