use block;
use block::{flag};
use item;
use item::{tool, material};
use types;

// Milliseconds after a block is successfully mined to wait before starting on
// the next when the mouse button is held down.
def MINING_DELAY: uint = 250;

// Calculates the time in milliseconds to mine the specified block with the
// specified item. If "damage" is non-null, the amount of damage to be applied
// to the item is stored in this value.
export fn calc_mining_time(
	block: *block::block,
	item: nullable *item::item,
	damage: nullable *i16 = null,
) uint = {
	// https://minecraft.wiki/w/Breaking?oldid=138286
	let dmg = 0i16;
	defer match (damage) {
	case let d: *i16 =>
		*d = dmg;
	case null => void;
	};

	let hardness = block.hardness;
	if (hardness < 0.0) {
		return types::UINT_MAX;
	};

	let tool = tool::HAND;
	let material = material::NONE;
	let item_id = -1i16;
	match (item) {
	case let i: *item::item =>
		item_id = i.id;
		tool = i.tool;
		material = i.material;
	case null => void;
	};

	let time = hardness * 1.5;

	const appropriate_tool = (block.tool & tool) != 0;
	const appropriate_material = (block.material & material) != 0;
	if (block.flags & flag::TOOL_REQUIRED != 0) {
		// Apply penalty for ineffective tools
		if (!appropriate_tool || !appropriate_material) {
			time *= 3.33;
		};
	};

	if (appropriate_tool) {
		switch (material) {
		case material::WOOD =>
			time /= 2.0;
		case material::STONE =>
			time /= 4.0;
		case material::IRON =>
			time /= 6.0;
		case material::DIAMOND =>
			time /= 8.0;
		case material::GOLD =>
			time /= 12.0;
		case => void;
		};
	};

	switch (tool) {
	case tool::SHOVEL, tool::AXE, tool::PICKAXE =>
		dmg = if (hardness != 0.0) 1 else 0;
	case tool::SWORD =>
		dmg = if (hardness != 0.0) 2 else 0;
		time /= 1.5;
	case tool::HOE =>
		dmg = 0;
	case => void;
	};

	if (item_id == item::SHEARS) {
		switch (block.id) {
		case block::WOOL =>
			time /= 5.0;
		case block::LEAVES, block::WEB =>
			time /= 15.0;
			dmg = 1;
		case block::TALL_GRASS =>
			dmg = 1;
		case => void;
		};
	};

	return (time * 1000.0): uint;
};
