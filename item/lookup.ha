use errors;
use sort;

// Looks up an [[item]] by its id.
export fn lookup(id: i16) (*item | errors::noentry) = {
	match (sort::search(items, size(*item), &id, &item_cmp)) {
	case let ix: size =>
		return items[ix];
	case void =>
		return errors::noentry;
	};
};

fn item_cmp(a: const *opaque, b: const *opaque) int = {
	const a = a: *i16;
	const b = b: **item;
	if (*a < b.id) {
		return -1;
	} else if (*a > b.id) {
		return 1;
	} else {
		return 0;
	};
};
