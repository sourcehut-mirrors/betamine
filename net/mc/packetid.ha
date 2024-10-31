export def KEEP_ALIVE: u8 = 0x00;
export def LOGIN_REQ: u8 = 0x01;
export def HANDSHAKE: u8 = 0x02;
export def CHAT_MESSAGE: u8 = 0x03;
export def TIME_UPDATE: u8 = 0x04;
export def ENTITY_EQUIP: u8 = 0x05;
export def SPAWN_POSITION: u8 = 0x06;
export def USE_ENTITY: u8 = 0x07;
export def UPDATE_HEALTH: u8 = 0x08;
export def RESPAWN: u8 = 0x09;
export def PLAYER: u8 = 0x0a;
export def PLAYER_POS: u8 = 0x0b;
export def PLAYER_LOOK: u8 = 0x0c;
export def PLAYER_POS_LOOK: u8 = 0x0d;
export def PLAYER_DIGGING: u8 = 0x0e;
export def PLAYER_PLACEBLOCK: u8 = 0x0f;
export def HOLD_CHANGE: u8 = 0x10;
export def USE_BED: u8 = 0x11;
export def ANIMATION: u8 = 0x12;
export def ENTITY_ACTION: u8 = 0x13;
export def SPAWN_PLAYER: u8 = 0x14;
export def SPAWN_ITEM: u8 = 0x15;
export def COLLECT_ITEM: u8 = 0x16;
export def SPAWN_OBJECT: u8 = 0x17;
export def SPAWN_MOB: u8 = 0x18;
export def SPAWN_PAINTING: u8 = 0x19;

export def ENTITY_VELOCITY: u8 = 0x1C;
export def DESTROY_ENTITY: u8 = 0x1D;
export def ENTITY: u8 = 0x1E;
export def ENTITY_MOVE: u8 = 0x1F;
export def ENTITY_LOOK: u8 = 0x20;
export def ENTITY_MOVE_LOOK: u8 = 0x21;
export def ENTITY_TELEPORT: u8 = 0x22;

export def ENTITY_STATUS: u8 = 0x26;
export def ATTACH_ENTITY: u8 = 0x27;
export def ENTITY_METADATA: u8 = 0x28;

export def CHUNK_PREAMBLE: u8 = 0x32;
export def CHUNK_DATA: u8 = 0x33;
export def BULK_BLOCK_CHANGE: u8 = 0x34;
export def BLOCK_CHANGE: u8 = 0x35;
export def BLOCK_ACTION: u8 = 0x36;

export def EXPLOSION: u8 = 0x3C;
export def SOUND_EFFECT: u8 = 0x3D;

export def ENVIRONMENT_STATE: u8 = 0x46;
export def THUNDERBOLT: u8 = 0x47;

export def OPEN_WINDOW: u8 = 0x64;
export def CLOSE_WINDOW: u8 = 0x65;
export def WINDOW_CLICK: u8 = 0x66;
export def SET_SLOT: u8 = 0x67;
export def WINDOW_ITEMS: u8 = 0x68;
export def UPDATE_PROGRESS: u8 = 0x69;
export def TRANSACTION: u8 = 0x6a;

export def UPDATE_SIGN: u8 = 0x82;
export def MAP_DATA: u8 = 0x83;

export def UPDATE_STAT: u8 = 0xC8;

export def DISCONNECT: u8 = 0xFF;
