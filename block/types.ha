// Data structures defining game engine data for a block.
export type block = struct {
	// Block ID
	id: u8,
	// Flags that apply to this block.
	flags: flag,
	// Display name
	display_name: str,
	// Mesh generation implementation
	model: *modelfunc,
	// Row & column of texture from terrain.png (only used for simple cube
	// models)
	tex: (uint, uint),
	// Block hardness.
	hardness: f64,
};

// Flags that apply to a block descriptor.
export type flag = enum uint {
	NONE = 0,
	// Block does not entirely occlude its neighbors, i.e. does not
	// completely fill its 1x1x1 voxel, or its texture includes pixels with
	// an alpha channel <1.0. Serves to imply that the mesh generator should
	// always include this block's neighbors.
	NON_OCCLUDING	= 1 << 0,
	// Block includes pixels with an alpha channel <1.0. Implies
	// NON_OCCLUDING, and sorts these blocks into a separate mesh for a
	// separate rendering pass.
	TRANSLUCENT	= 1 << 1,
	// Block is flammable.
	FLAMMABLE	= 1 << 2,
	// Block stores useful metadata (e.g. wheat).
	METADATA	= 1 << 3,
	// Block stores useful tile entities (e.g. chests).
	TILEDATA	= 1 << 4,
};
