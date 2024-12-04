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

# https://minecraft.wiki/w/Breaking?oldid=138286
# Tools effective for mining this block
tools = {
    "BEDROCK": ["tool::NONE"],
    "PORTAL": ["tool::NONE"],
    "OBSIDIAN": ["tool::PICKAXE"],
    "DOOR_IRON": ["tool::PICKAXE"],
    "DIAMOND_BLOCK": ["tool::PICKAXE"],
    "IRON_BLOCK": ["tool::PICKAXE"],
    "SPAWNER": ["tool::PICKAXE"],
    "DISPENSER": ["tool::PICKAXE"],
    "FURNACE": ["tool::PICKAXE"],
    "FURNACE_LIT": ["tool::PICKAXE"],
    "COAL_ORE": ["tool::PICKAXE"],
    "IRON_ORE": ["tool::PICKAXE"],
    "GOLD_ORE": ["tool::PICKAXE"],
    "DIAMOND_ORE": ["tool::PICKAXE"],
    "LAPIS_ORE": ["tool::PICKAXE"],
    "REDSTONE_ORE": ["tool::PICKAXE"],
    "GOLD_BLOCK": ["tool::PICKAXE"],
    "LAPIS_BLOCK": ["tool::PICKAXE"],
    "BRICKS": ["tool::PICKAXE"],
    "COBBLE": ["tool::PICKAXE"],
    "COBBLE_MOSS": ["tool::PICKAXE"],
    "SLAB_DOUBLE": ["tool::PICKAXE"],
    "SLAB_SINGLE": ["tool::PICKAXE"],
    "CHEST": ["tool::AXE"],
    "WOOD": ["tool::AXE"],
    "WOOD_PLANK": ["tool::AXE"],
    "BOOKSHELF": ["tool::AXE"],
    "STONE": ["tool::PICKAXE"],
    "SANDSTONE": ["tool::PICKAXE"],
    "CLAY": ["tool::SHOVEL"],
    "GRASS": ["tool::SHOVEL"],
    "GRAVEL": ["tool::SHOVEL"],
    "DIRT": ["tool::SHOVEL"],
    "ICE": ["tool::PICKAXE"],
    "PLATE_STONE": ["tool::PICKAXE"],
    "PLATE_WOOD": ["tool::PICKAXE"],
    "SAND": ["tool::SHOVEL"],
    "NETHERRACK": ["tool::PICKAXE"],
    "SNOW_BLOCK": ["tool::SHOVEL"],
    "SNOW": ["tool::SHOVEL"],
}

# Tool materials effective for mining this block
#
# ANY: Requires a tool to be mined
materials = {
    "COAL_ORE": ["material::ANY"],
    "COBBLE": ["material::ANY"],
    "COBBLE_MOSS": ["material::ANY"],
    "BRICKS": ["material::ANY"],
    "SLAB_SINGLE": ["material::ANY"],
    "SLAB_DOUBLE": ["material::ANY"],
    "STAIRS_STONE": ["material::ANY"],
    "STONE": ["material::ANY"],
    "DOOR_IRON": ["material::ANY"],
    "SANDSTONE": ["material::ANY"],
    "ICE": ["material::ANY"],
    "PLATE_WOOD": ["material::ANY"],
    "PLATE_STONE": ["material::ANY"],
    "NETHERRACK": ["material::ANY"],
    "SNOW": ["material::ANY"],
    "SNOW_BLOCK": ["material::ANY"],
    "OBSIDIAN": ["material::DIAMOND"],
    "DIAMOND_BLOCK": ["material::IRON", "material::DIAMOND"],
    "IRON_BLOCK": ["material::IRON", "material::DIAMOND"],
    "DIAMOND_ORE": ["material::IRON", "material::DIAMOND"],
    "GOLD_ORE": ["material::STONE", "material::IRON", "material::DIAMOND"],
    "IRON_ORE": ["material::STONE", "material::IRON", "material::DIAMOND"],
    "LAPIS_ORE": ["material::STONE", "material::IRON", "material::DIAMOND"],
    "REDSTONE_ORE_DIM": ["material::IRON", "material::DIAMOND"],
    "REDSTONE_ORE_LIT": ["material::IRON", "material::DIAMOND"],
    "GOLD_BLOCK": ["material::IRON", "material::DIAMOND"],
    "LAPIS_BLOCK": ["material::STONE", "material::IRON", "material::DIAMOND"],
}

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

# Fix up hardness of bedrock, should be -1
blocks["7"]["hardness"] = -1

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
    tools=tools,
    materials=materials,
))
