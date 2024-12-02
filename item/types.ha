// TODO: Merge items with blocks? We'll see if and when the need arises

// Data structure defining game engine data for an item.
export type item = struct {
	// Item ID
	id: i16,
	// Display name
	display_name: str,
	// Row & column of texture from items.png
	tex: (int, int),
};
