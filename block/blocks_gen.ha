// File generated with scripts/genblocks.py

// Block information database, indexed by block ID.
export const blocks: [256]nullable *block = [
	&block_air,
	&block_stone,
	&block_grass,
	&block_dirt,
	&block_cobble,
	&block_wood_plank,
	&block_sapling,
	&block_bedrock,
	&block_water,
	&block_water_stationary,
	&block_lava,
	&block_lava_stationary,
	&block_sand,
	&block_gravel,
	&block_gold_ore,
	&block_iron_ore,
	&block_coal_ore,
	&block_wood,
	&block_leaves,
	&block_sponge,
	&block_glass,
	&block_lapis_ore,
	&block_lapis_block,
	&block_dispenser,
	&block_sandstone,
	&block_note,
	&block_bed,
	&block_rail_powered,
	&block_rail_detector,
	&block_piston_sticky,
	&block_web,
	&block_tall_grass,
	&block_dry_bush,
	&block_piston,
	&block_piston_head,
	&block_wool,
	&block_piston_placeholder,
	&block_dandelion,
	&block_rose,
	&block_mushroom_brown,
	&block_mushroom_red,
	&block_gold_block,
	&block_iron_block,
	&block_slab_double,
	&block_slab_single,
	&block_bricks,
	&block_tnt,
	&block_bookshelf,
	&block_cobble_moss,
	&block_obsidian,
	&block_torch,
	&block_fire,
	&block_spawner,
	&block_stairs_wooden,
	&block_chest,
	&block_redstone,
	&block_diamond_ore,
	&block_diamond_block,
	&block_craft_bench,
	&block_seeds,
	&block_farmland,
	&block_furnace,
	&block_furnace_lit,
	&block_signpost,
	&block_door,
	&block_ladder,
	&block_rail,
	&block_stairs_stone,
	&block_sign_wall,
	&block_lever,
	&block_plate_stone,
	&block_door_iron,
	&block_plate_wood,
	&block_redstone_ore_dim,
	&block_redstone_ore_lit,
	&block_redstone_torch_dim,
	&block_redstone_torch_lit,
	&block_button,
	&block_snow,
	&block_ice,
	&block_snow_block,
	&block_cactus,
	&block_clay,
	&block_sugarcane,
	&block_jukebox,
	&block_fence,
	&block_pumpkin,
	&block_netherrack,
	&block_soul_sand,
	&block_glowstone,
	&block_portal,
	&block_jack_o_lantern,
	&block_cake,
	&block_repeater_dim,
	&block_repeater_lit,
	&block_locked_chest,
	&block_trapdoor,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
];

const block_air = block {
	id = AIR,
	model = &model_none,
	flags = flag::NON_OCCLUDING,
	...
};


const block_stone = block {
	id = STONE,
	model = &model_cube,
	display_name = "Stone",
	tex = (1, 0),
	hardness = 1.50,
	...
};

const block_grass = block {
	id = GRASS,
	model = &model_grass,
	display_name = "Grass",
	tex = (3, 0),
	hardness = 0.60,
	...
};

const block_dirt = block {
	id = DIRT,
	model = &model_cube,
	display_name = "Dirt",
	tex = (2, 0),
	hardness = 0.50,
	...
};

const block_cobble = block {
	id = COBBLE,
	model = &model_cube,
	display_name = "Cobblestone",
	tex = (0, 1),
	hardness = 2.00,
	...
};

const block_wood_plank = block {
	id = WOOD_PLANK,
	model = &model_cube,
	display_name = "Wooden Planks",
	tex = (4, 0),
	hardness = 2.00,
	...
};

const block_sapling = block {
	id = SAPLING,
	model = &model_twoquad,
	display_name = "Sapling",
	tex = (15, 0),
	hardness = 0.00,
	...
};

const block_bedrock = block {
	id = BEDROCK,
	model = &model_cube,
	display_name = "Bedrock",
	tex = (1, 1),
	hardness = 0.00,
	...
};

const block_water = block {
	id = WATER,
	model = &model_fluid,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Water",
	hardness = 100.00,
	...
};

const block_water_stationary = block {
	id = WATER_STATIONARY,
	model = &model_fluid,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Water",
	hardness = 100.00,
	...
};

const block_lava = block {
	id = LAVA,
	model = &model_fluid,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Lava",
	hardness = 0.00,
	...
};

const block_lava_stationary = block {
	id = LAVA_STATIONARY,
	model = &model_fluid,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Lava",
	hardness = 100.00,
	...
};

const block_sand = block {
	id = SAND,
	model = &model_cube,
	display_name = "Sand",
	tex = (2, 1),
	hardness = 0.50,
	...
};

const block_gravel = block {
	id = GRAVEL,
	model = &model_cube,
	display_name = "Gravel",
	tex = (3, 1),
	hardness = 0.60,
	...
};

const block_gold_ore = block {
	id = GOLD_ORE,
	model = &model_cube,
	display_name = "Gold Ore",
	tex = (0, 2),
	hardness = 3.00,
	...
};

const block_iron_ore = block {
	id = IRON_ORE,
	model = &model_cube,
	display_name = "Iron Ore",
	tex = (1, 2),
	hardness = 3.00,
	...
};

const block_coal_ore = block {
	id = COAL_ORE,
	model = &model_cube,
	display_name = "Coal Ore",
	tex = (2, 2),
	hardness = 3.00,
	...
};

const block_wood = block {
	id = WOOD,
	model = &model_cube,
	display_name = "Wood",
	tex = (4, 1),
	hardness = 2.00,
	...
};

const block_leaves = block {
	id = LEAVES,
	model = &model_cube,
	flags = flag::NON_OCCLUDING,
	display_name = "Leaves",
	tex = (4, 3),
	hardness = 0.20,
	...
};

const block_sponge = block {
	id = SPONGE,
	model = &model_cube,
	display_name = "Sponge",
	tex = (0, 3),
	hardness = 0.60,
	...
};

const block_glass = block {
	id = GLASS,
	model = &model_cube,
	display_name = "Glass",
	tex = (1, 3),
	hardness = 0.30,
	...
};

const block_lapis_ore = block {
	id = LAPIS_ORE,
	model = &model_cube,
	display_name = "Lapis Lazuli Ore",
	tex = (0, 10),
	hardness = 3.00,
	...
};

const block_lapis_block = block {
	id = LAPIS_BLOCK,
	model = &model_cube,
	display_name = "Lapis Lazuli Block",
	tex = (0, 9),
	hardness = 3.00,
	...
};

const block_dispenser = block {
	id = DISPENSER,
	model = &model_cube,
	display_name = "Dispenser",
	tex = (13, 2),
	hardness = 3.50,
	...
};

const block_sandstone = block {
	id = SANDSTONE,
	model = &model_cube,
	display_name = "Sandstone",
	tex = (0, 12),
	hardness = 0.80,
	...
};

const block_note = block {
	id = NOTE,
	model = &model_cube,
	display_name = "Note Block",
	tex = (10, 4),
	hardness = 0.80,
	...
};

const block_bed = block {
	id = BED,
	model = &model_cube,
	display_name = "Bed",
	tex = (6, 8),
	hardness = 0.20,
	...
};

const block_rail_powered = block {
	id = RAIL_POWERED,
	model = &model_onequad,
	display_name = "Powered Rail",
	tex = (3, 11),
	hardness = 0.70,
	...
};

const block_rail_detector = block {
	id = RAIL_DETECTOR,
	model = &model_onequad,
	display_name = "Detector Rail",
	tex = (3, 12),
	hardness = 0.70,
	...
};

const block_piston_sticky = block {
	id = PISTON_STICKY,
	model = &model_cube,
	display_name = "Sticky Piston",
	tex = (10, 6),
	hardness = 0.00,
	...
};

const block_web = block {
	id = WEB,
	model = &model_twoquad,
	display_name = "Cobweb",
	tex = (11, 0),
	hardness = 4.00,
	...
};

const block_tall_grass = block {
	id = TALL_GRASS,
	model = &model_twoquad,
	display_name = "tallgrass",
	tex = (7, 2),
	hardness = 0.00,
	...
};

const block_dry_bush = block {
	id = DRY_BUSH,
	model = &model_twoquad,
	display_name = "deadbush",
	tex = (7, 3),
	hardness = 0.00,
	...
};

const block_piston = block {
	id = PISTON,
	model = &model_cube,
	display_name = "Piston",
	tex = (11, 6),
	hardness = 0.00,
	...
};

const block_piston_head = block {
	id = PISTON_HEAD,
	model = &model_cube,
	display_name = "",
	tex = (11, 6),
	hardness = 0.00,
	...
};

const block_wool = block {
	id = WOOL,
	model = &model_cube,
	display_name = "Wool",
	tex = (0, 4),
	hardness = 0.80,
	...
};

const block_piston_placeholder = block {
	id = PISTON_PLACEHOLDER,
	model = &model_cube,
	display_name = "",
	hardness = 0.00,
	...
};

const block_dandelion = block {
	id = DANDELION,
	model = &model_twoquad,
	display_name = "Flower",
	tex = (13, 0),
	hardness = 0.00,
	...
};

const block_rose = block {
	id = ROSE,
	model = &model_twoquad,
	display_name = "Rose",
	tex = (12, 0),
	hardness = 0.00,
	...
};

const block_mushroom_brown = block {
	id = MUSHROOM_BROWN,
	model = &model_twoquad,
	display_name = "Mushroom",
	tex = (13, 1),
	hardness = 0.00,
	...
};

const block_mushroom_red = block {
	id = MUSHROOM_RED,
	model = &model_twoquad,
	display_name = "Mushroom",
	tex = (12, 1),
	hardness = 0.00,
	...
};

const block_gold_block = block {
	id = GOLD_BLOCK,
	model = &model_cube,
	display_name = "Block of Gold",
	tex = (7, 1),
	hardness = 3.00,
	...
};

const block_iron_block = block {
	id = IRON_BLOCK,
	model = &model_cube,
	display_name = "Block of Iron",
	tex = (6, 1),
	hardness = 5.00,
	...
};

const block_slab_double = block {
	id = SLAB_DOUBLE,
	model = &model_cube,
	display_name = "stoneSlab",
	tex = (6, 0),
	hardness = 2.00,
	...
};

const block_slab_single = block {
	id = SLAB_SINGLE,
	model = &model_cube,
	display_name = "stoneSlab",
	tex = (6, 0),
	hardness = 2.00,
	...
};

const block_bricks = block {
	id = BRICKS,
	model = &model_cube,
	display_name = "Bricks",
	tex = (7, 0),
	hardness = 2.00,
	...
};

const block_tnt = block {
	id = TNT,
	model = &model_cube,
	display_name = "TNT",
	tex = (8, 0),
	hardness = 0.00,
	...
};

const block_bookshelf = block {
	id = BOOKSHELF,
	model = &model_cube,
	display_name = "Bookshelf",
	tex = (3, 2),
	hardness = 1.50,
	...
};

const block_cobble_moss = block {
	id = COBBLE_MOSS,
	model = &model_cube,
	display_name = "Moss Stone",
	tex = (4, 2),
	hardness = 2.00,
	...
};

const block_obsidian = block {
	id = OBSIDIAN,
	model = &model_cube,
	display_name = "Obsidian",
	tex = (5, 2),
	hardness = 10.00,
	...
};

const block_torch = block {
	id = TORCH,
	model = &model_cube,
	display_name = "Torch",
	tex = (0, 5),
	hardness = 0.00,
	...
};

const block_fire = block {
	id = FIRE,
	model = &model_twoquad,
	display_name = "Fire",
	tex = (15, 1),
	hardness = 0.00,
	...
};

const block_spawner = block {
	id = SPAWNER,
	model = &model_cube,
	display_name = "Monster Spawner",
	tex = (1, 4),
	hardness = 5.00,
	...
};

const block_stairs_wooden = block {
	id = STAIRS_WOODEN,
	model = &model_cube,
	display_name = "Wooden Stairs",
	hardness = 0.00,
	...
};

const block_chest = block {
	id = CHEST,
	model = &model_cube,
	display_name = "Chest",
	tex = (10, 1),
	hardness = 2.50,
	...
};

const block_redstone = block {
	id = REDSTONE,
	model = &model_twoquad,
	display_name = "Redstone Dust",
	tex = (4, 10),
	hardness = 0.00,
	...
};

const block_diamond_ore = block {
	id = DIAMOND_ORE,
	model = &model_cube,
	display_name = "Diamond Ore",
	tex = (2, 3),
	hardness = 3.00,
	...
};

const block_diamond_block = block {
	id = DIAMOND_BLOCK,
	model = &model_cube,
	display_name = "Block of Diamond",
	tex = (8, 1),
	hardness = 5.00,
	...
};

const block_craft_bench = block {
	id = CRAFT_BENCH,
	model = &model_cube,
	display_name = "Crafting Table",
	tex = (11, 3),
	hardness = 2.50,
	...
};

const block_seeds = block {
	id = SEEDS,
	model = &model_twoquad,
	display_name = "Crops",
	tex = (8, 5),
	hardness = 0.00,
	...
};

const block_farmland = block {
	id = FARMLAND,
	model = &model_cube,
	display_name = "Farmland",
	tex = (7, 5),
	hardness = 0.60,
	...
};

const block_furnace = block {
	id = FURNACE,
	model = &model_cube,
	display_name = "Furnace",
	tex = (13, 2),
	hardness = 3.50,
	...
};

const block_furnace_lit = block {
	id = FURNACE_LIT,
	model = &model_cube,
	display_name = "Furnace",
	tex = (13, 2),
	hardness = 3.50,
	...
};

const block_signpost = block {
	id = SIGNPOST,
	model = &model_cube,
	display_name = "Sign",
	tex = (4, 0),
	hardness = 1.00,
	...
};

const block_door = block {
	id = DOOR,
	model = &model_cube,
	display_name = "Wooden Door",
	tex = (1, 6),
	hardness = 3.00,
	...
};

const block_ladder = block {
	id = LADDER,
	model = &model_onequad,
	display_name = "Ladder",
	tex = (3, 5),
	hardness = 0.40,
	...
};

const block_rail = block {
	id = RAIL,
	model = &model_onequad,
	display_name = "Rail",
	tex = (0, 8),
	hardness = 0.70,
	...
};

const block_stairs_stone = block {
	id = STAIRS_STONE,
	model = &model_cube,
	display_name = "Stone Stairs",
	hardness = 0.00,
	...
};

const block_sign_wall = block {
	id = SIGN_WALL,
	model = &model_cube,
	display_name = "Sign",
	tex = (4, 0),
	hardness = 1.00,
	...
};

const block_lever = block {
	id = LEVER,
	model = &model_cube,
	display_name = "Lever",
	tex = (0, 6),
	hardness = 0.50,
	...
};

const block_plate_stone = block {
	id = PLATE_STONE,
	model = &model_cube,
	display_name = "Pressure Plate",
	hardness = 0.50,
	...
};

const block_door_iron = block {
	id = DOOR_IRON,
	model = &model_cube,
	display_name = "Iron Door",
	tex = (1, 6),
	hardness = 5.00,
	...
};

const block_plate_wood = block {
	id = PLATE_WOOD,
	model = &model_cube,
	display_name = "Pressure Plate",
	hardness = 0.50,
	...
};

const block_redstone_ore_dim = block {
	id = REDSTONE_ORE_DIM,
	model = &model_cube,
	display_name = "Redstone Ore",
	tex = (3, 3),
	hardness = 3.00,
	...
};

const block_redstone_ore_lit = block {
	id = REDSTONE_ORE_LIT,
	model = &model_cube,
	display_name = "Redstone Ore",
	tex = (3, 3),
	hardness = 3.00,
	...
};

const block_redstone_torch_dim = block {
	id = REDSTONE_TORCH_DIM,
	model = &model_cube,
	display_name = "Redstone Torch",
	tex = (3, 7),
	hardness = 0.00,
	...
};

const block_redstone_torch_lit = block {
	id = REDSTONE_TORCH_LIT,
	model = &model_cube,
	display_name = "Redstone Torch",
	tex = (3, 6),
	hardness = 0.00,
	...
};

const block_button = block {
	id = BUTTON,
	model = &model_cube,
	display_name = "Button",
	hardness = 0.50,
	...
};

const block_snow = block {
	id = SNOW,
	model = &model_snow,
	flags = flag::NON_OCCLUDING,
	display_name = "Snow",
	tex = (2, 4),
	hardness = 0.10,
	...
};

const block_ice = block {
	id = ICE,
	model = &model_cube,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Ice",
	tex = (3, 4),
	hardness = 0.50,
	...
};

const block_snow_block = block {
	id = SNOW_BLOCK,
	model = &model_cube,
	display_name = "Snow",
	tex = (2, 4),
	hardness = 0.20,
	...
};

const block_cactus = block {
	id = CACTUS,
	model = &model_cube,
	display_name = "Cactus",
	tex = (6, 4),
	hardness = 0.40,
	...
};

const block_clay = block {
	id = CLAY,
	model = &model_cube,
	display_name = "Clay",
	tex = (8, 4),
	hardness = 0.60,
	...
};

const block_sugarcane = block {
	id = SUGARCANE,
	model = &model_twoquad,
	display_name = "Sugar cane",
	tex = (9, 4),
	hardness = 0.00,
	...
};

const block_jukebox = block {
	id = JUKEBOX,
	model = &model_cube,
	display_name = "Jukebox",
	tex = (10, 4),
	hardness = 2.00,
	...
};

const block_fence = block {
	id = FENCE,
	model = &model_cube,
	display_name = "Fence",
	tex = (4, 0),
	hardness = 2.00,
	...
};

const block_pumpkin = block {
	id = PUMPKIN,
	model = &model_cube,
	display_name = "Pumpkin",
	tex = (6, 6),
	hardness = 1.00,
	...
};

const block_netherrack = block {
	id = NETHERRACK,
	model = &model_cube,
	display_name = "Netherrack",
	tex = (7, 6),
	hardness = 0.40,
	...
};

const block_soul_sand = block {
	id = SOUL_SAND,
	model = &model_cube,
	display_name = "Soul Sand",
	tex = (8, 6),
	hardness = 0.50,
	...
};

const block_glowstone = block {
	id = GLOWSTONE,
	model = &model_cube,
	display_name = "Glowstone",
	tex = (9, 6),
	hardness = 0.30,
	...
};

const block_portal = block {
	id = PORTAL,
	model = &model_cube,
	flags = flag::TRANSLUCENT | flag::NON_OCCLUDING,
	display_name = "Portal",
	tex = (14, 0),
	hardness = -1.00,
	...
};

const block_jack_o_lantern = block {
	id = JACK_O_LANTERN,
	model = &model_cube,
	display_name = "Jack 'o' Lantern",
	tex = (6, 6),
	hardness = 1.00,
	...
};

const block_cake = block {
	id = CAKE,
	model = &model_cube,
	display_name = "Cake",
	tex = (9, 7),
	hardness = 0.50,
	...
};

const block_repeater_dim = block {
	id = REPEATER_DIM,
	model = &model_cube,
	display_name = "diode",
	tex = (6, 0),
	hardness = 0.00,
	...
};

const block_repeater_lit = block {
	id = REPEATER_LIT,
	model = &model_cube,
	display_name = "diode",
	tex = (6, 0),
	hardness = 0.00,
	...
};

const block_locked_chest = block {
	id = LOCKED_CHEST,
	model = &model_cube,
	display_name = "Locked chest",
	tex = (10, 1),
	hardness = 0.00,
	...
};

const block_trapdoor = block {
	id = TRAPDOOR,
	model = &model_cube,
	display_name = "Trapdoor",
	tex = (4, 5),
	hardness = 3.00,
	...
};
