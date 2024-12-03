#!/usr/bin/python3
from jinja2 import Environment, FileSystemLoader, select_autoescape
import json
import sys

env = Environment(
    loader=FileSystemLoader("scripts"),
    autoescape=select_autoescape(default=False),
)

# Blocks whose mesh is a single quad
onequad_models = [
    "LADDER",
    "RAIL",
    "RAIL_DETECTOR",
    "RAIL_POWERED",
    "REDSTONE",
]

# Blocks whose mesh is two quads in an "X" configuration
twoquad_models = [
    "SAPLING",
    "WEB",
    "TALL_GRASS",
    "DRY_BUSH",
    "DANDELION",
    "ROSE",
    "MUSHROOM_BROWN",
    "MUSHROOM_RED",
    "FIRE",
    "SEEDS",
    "SUGARCANE",
]

custom_models = {
    "GRASS": "grass",
    "SNOW": "snow",
    "WATER": "fluid",
    "WATER_STATIONARY": "fluid",
    "LAVA": "fluid",
    "LAVA_STATIONARY": "fluid",
    "SLAB_SINGLE": "slab",
    "TORCH": "torch",
    "REDSTONE_TORCH_DIM": "torch",
    "REDSTONE_TORCH_LIT": "torch",
    "TRAPDOOR": "trapdoor",
    "DOOR": "door",
    "DOOR_IRON": "door",
    "STAIRS_STONE": "stairs",
    "STAIRS_WOODEN": "stairs",
    "CACTUS": "cactus",
    "PISTON": "piston",
    "PISTON_STICKY": "piston",
    "PISTON_HEAD": "piston_head",
}

# Blocks with no bounding box
no_aabb = [
    "WATER",
    "WATER_STATIONARY",
    "LAVA",
    "LAVA_STATIONARY",
    "TORCH",
    "REDSTONE_TORCH_DIM",
    "REDSTONE_TORCH_LIT",
    "SNOW",
    "PORTAL",
    "REPEATER_LIT",
    "REPEATER_DIM",
    "BUTTON",
    "SIGN_WALL",
    "SIGNPOST",
    "PLATE_STONE",
    "PLATE_WOOD",
    "LEVER",
]

# Blocks with a custom bounding box
custom_aabb = {
    "SLAB_SINGLE": "aabb_slab",
    # TODO:
    # CAKE
    # PISTON_HEAD
    # BED
    # SLAB
    # DOOR
    # CACTUS
    # TRAPDOOR
    # FENCE
}

# Blocks that do not fully occlude their neighbors
non_occluding = [
    "LEAVES",
    "SNOW",
    "CAKE",
    "TORCH",
    "REDSTONE_TORCH_DIM",
    "REDSTONE_TORCH_LIT",
    "SPAWNER",
    "GLASS",
    "TRAPDOOR",
    "SLAB_SINGLE",
    "DOOR",
    "DOOR_IRON",
    "LEVER",
    "PLATE_STONE",
    "PLATE_WOOD",
    "STAIRS_WOODEN",
    "STAIRS_STONE",
    "BED",
    "CACTUS",
    "PISTON_HEAD",
    # Note: technically these are occluding when retracted
    "PISTON",
    "PISTON_STICKY",
]

# Blocks which are transparent or translucent
transparent_blocks = [
    "WATER",
    "WATER_STATIONARY",
    "LAVA",
    "LAVA_STATIONARY",
    "ICE",
    "PORTAL",
]

# betamine uses more intuitive names than Minecraft, so we hardcode these
# instead of using the Burger dump
block_names = [
    "AIR",
    "STONE",
    "GRASS",
    "DIRT",
    "COBBLE",
    "WOOD_PLANK",
    "SAPLING",
    "BEDROCK",
    "WATER",
    "WATER_STATIONARY",
    "LAVA",
    "LAVA_STATIONARY",
    "SAND",
    "GRAVEL",
    "GOLD_ORE",
    "IRON_ORE",
    "COAL_ORE",
    "WOOD",
    "LEAVES",
    "SPONGE",
    "GLASS",
    "LAPIS_ORE",
    "LAPIS_BLOCK",
    "DISPENSER",
    "SANDSTONE",
    "NOTE",
    "BED",
    "RAIL_POWERED",
    "RAIL_DETECTOR",
    "PISTON_STICKY",
    "WEB",
    "TALL_GRASS",
    "DRY_BUSH",
    "PISTON",
    "PISTON_HEAD",
    "WOOL",
    "PISTON_PLACEHOLDER",
    "DANDELION",
    "ROSE",
    "MUSHROOM_BROWN",
    "MUSHROOM_RED",
    "GOLD_BLOCK",
    "IRON_BLOCK",
    "SLAB_DOUBLE",
    "SLAB_SINGLE",
    "BRICKS",
    "TNT",
    "BOOKSHELF",
    "COBBLE_MOSS",
    "OBSIDIAN",
    "TORCH",
    "FIRE",
    "SPAWNER",
    "STAIRS_WOODEN",
    "CHEST",
    "REDSTONE",
    "DIAMOND_ORE",
    "DIAMOND_BLOCK",
    "CRAFT_BENCH",
    "SEEDS",
    "FARMLAND",
    "FURNACE",
    "FURNACE_LIT",
    "SIGNPOST",
    "DOOR",
    "LADDER",
    "RAIL",
    "STAIRS_STONE",
    "SIGN_WALL",
    "LEVER",
    "PLATE_STONE",
    "DOOR_IRON",
    "PLATE_WOOD",
    "REDSTONE_ORE_DIM",
    "REDSTONE_ORE_LIT",
    "REDSTONE_TORCH_DIM",
    "REDSTONE_TORCH_LIT",
    "BUTTON",
    "SNOW",
    "ICE",
    "SNOW_BLOCK",
    "CACTUS",
    "CLAY",
    "SUGARCANE",
    "JUKEBOX",
    "FENCE",
    "PUMPKIN",
    "NETHERRACK",
    "SOUL_SAND",
    "GLOWSTONE",
    "PORTAL",
    "JACK_O_LANTERN",
    "CAKE",
    "REPEATER_DIM",
    "REPEATER_LIT",
    "LOCKED_CHEST",
    "TRAPDOOR",
]

f = open("scripts/burger-b1.7.json")
db = json.loads(f.read())
blocks = db[0]["blocks"]["block"]
blocks = [blocks[key] for key in blocks]

def getmodel(block):
    name = block_names[block["id"]]
    if name in onequad_models:
        return "model_onequad"
    if name in twoquad_models:
        return "model_twoquad"
    if name in custom_models:
        return f"model_{custom_models[name]}"
    return "model_cube"

def getaabb(block):
    name = block_names[block["id"]]
    if name in custom_aabb:
        return custom_aabb[name]
    elif name in onequad_models or name in twoquad_models or name in no_aabb:
        return "void"
    else:
        return "[[0.0, 0.0, 0.0], [1.0, 1.0, 1.0]]"

def getflags(block):
    flags = []

    name = block_names[block["id"]]
    transparent = name in transparent_blocks

    if transparent:
        flags.append("flag::TRANSLUCENT")
    if name in onequad_models + twoquad_models \
            or transparent \
            or name in non_occluding:
        flags.append("flag::NON_OCCLUDING")

    return " | ".join(flags)

template = env.get_template("blocks.ha.in")
print(template.render(
    blocks=blocks,
    block_names=block_names,
    num_null=256-len(block_names),
    model=getmodel,
    aabb=getaabb,
    flags=getflags,
))
