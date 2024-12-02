use net::mc;

// A slot in an inventory window.
export type slot = mc::slot;

// An inventory window, e.g. a player inventory, a furnace, etc.
export type window = struct {
	id: i8,
};

// A player's inventory.
export type inventory = struct {
	window,

	union {
		slots: [45]slot,

		struct {
			crafting: struct {
				out: slot,
				in: [4]slot,
			},
			armor: [4]slot,
			inventory: [9 * 3]slot,
			hotbar: [9]slot,
		},
	},
};
