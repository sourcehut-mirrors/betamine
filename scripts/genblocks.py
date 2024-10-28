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
    "RAIL_POWERED",
    "RAIL_DETECTOR",
    "LADDER",
    "RAIL",
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
    "REDSTONE",
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
}

non_occluding = [
    "LEAVES",
]

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

def getflags(block):
    flags = []

    name = block_names[block["id"]]
    model = getmodel(block)
    transparent = name in transparent_blocks

    if transparent:
        flags.append("flag::TRANSLUCENT")
    if model in onequad_models + twoquad_models or transparent or name in non_occluding:
        flags.append("flag::NON_OCCLUDING")

    return " | ".join(flags)

template = env.get_template("blocks.ha.in")
print(template.render(
    blocks=blocks,
    block_names=block_names,
    num_null=256-len(block_names),
    model=getmodel,
    flags=getflags,
))
