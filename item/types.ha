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

// Item material, if applicable.
export type material = enum uint {
	NONE,
	WOOD,
	STONE,
	IRON,
	GOLD,
	DIAMOND,
	LEATHER,
	CHAINMAIL,
};

// Tool type, if applicable.
export type tool = enum uint {
	NONE,
	SWORD,
	SHOVEL,
	PICKAXE,
	AXE,
	HOE,
};

// Armor type, if applicable.
export type armor = enum uint {
	NONE,
	HELMET,
	CHESTPLATE,
	LEGGINGS,
	BOOTS,
};
