use endian;

// An inventory slot.
export type slot = struct {
	id: i16,
	count: i8,
	metadata: i16,
};

export type slot_iterator = struct {
	data: []u8,
	i: uint,
};

// Decodes the inventory slots of a [[window_items]] packet. Use [[slots_next]]
// to enumerate items.
export fn slots_decode(slots: []u8) slot_iterator = {
	return slot_iterator {
		data = slots,
		i = 0,
	};
};

// Returns the next item from a [[slot_iterator]].
export fn slots_next(iter: *slot_iterator) (slot | done) = {
	if (iter.i >= len(iter.data)) {
		return done;
	};

	const data = iter.data;
	let i = iter.i;
	defer iter.i = i;

	let slot = slot { ... };
	slot.id = endian::begetu16(data[i..]): i16;
	i += 2;

	if (slot.id != -1) {
		slot.count = data[i]: i8;
		i += 1;
		slot.metadata = endian::begetu16(data[i..]): i16;
		i += 2;
	};

	return slot;
};
