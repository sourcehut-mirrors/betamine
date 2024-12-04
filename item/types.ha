// TODO: Merge items with blocks? We'll see if and when the need arises

// Data structure defining game engine data for an item.
export type item = struct {
	// Item ID
	id: i16,
	// Display name
	display_name: str,
	// Row & column of texture from items.png
	tex: (int, int),
	// Item material
	material: material,
	// Tool type
	tool: tool,
	// Armor type
	armor: armor,
	// Number of hearts restored when eaten
	food: uint,
};

// Note: a single item cannot have multiple materials or tool types, but these
// are a bitfield in order to support features in the block database in
// [[block::]]. For example, diamond blocks can be mined by both iron and
// diamond tools, which are OR'd together in its database entry.

// Tool material, if applicable.
export type material = enum uint {
	NONE,
	WOOD		= 1 << 0,
	STONE		= 1 << 1,
	IRON		= 1 << 2,
	GOLD		= 1 << 3,
	DIAMOND		= 1 << 4,
	ANY		= WOOD | STONE | IRON | GOLD | DIAMOND,
};

// Tool type, if applicable.
export type tool = enum uint {
	NONE,
	SWORD	= 1 << 0,
	SHOVEL	= 1 << 1,
	PICKAXE	= 1 << 2,
	AXE	= 1 << 3,
	HOE	= 1 << 4,
	HAND	= 1 << 5, // Special case
	ANY	= SWORD | SHOVEL | PICKAXE | AXE | HOE | HAND,
};

// Armor type, if applicable.
export type armor = enum uint {
	NONE,
	HELMET,
	CHESTPLATE,
	LEGGINGS,
	BOOTS,
};
