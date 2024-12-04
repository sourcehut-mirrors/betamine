use glm;
use item;

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
	// Row & column of texture from terrain.png
	tex: (int, int),
	// Block hardness.
	hardness: f64,
	// Axis-aligned bounding box
	aabb: ([2]glm::v3 | *aabbfunc | void),
	// Tools effective for mining this block.
	//
	// Note that NONE is distinct from HAND is distinct from ANY. NONE is
	// used for blocks which cannot be mined under any circumstances, such
	// as bedrock. HAND is used for tools which can be mined by hand, such
	// as dirt. ANY is blocks which can be mined with any tool, including by
	// hand.
	tool: item::tool,
	// Tool materials effective for mining this block.
	//
	// Note that NONE is distinct from ANY. NONE refers to blocks which can
	// be mined with tools of any or no particular material, such as dirt,
	// which can be mined with a shovel or with a loaf of bread, it doesn't
	// matter. ANY refers to blocks which can be mined with any tool
	// material, but not by hand.
	material: item::material,
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

// Faces of a cube.
export type face = enum uint {
	T = 0,
	B = 1,
	N = 2,
	S = 3,
	W = 4,
	E = 5,
};
