#!/usr/bin/python3
from jinja2 import Environment, FileSystemLoader, select_autoescape
import json
import sys

# TODO: Add additional item details, such as material, durability, max stack
# size, etc

env = Environment(
    loader=FileSystemLoader("scripts"),
    autoescape=select_autoescape(default=False),
)

WOOD = "WOOD"
STONE = "STONE"
IRON = "IRON"
GOLD = "GOLD"
DIAMOND = "DIAMOND"
SWORD = "SWORD"
SHOVEL = "SHOVEL"
PICKAXE = "PICKAXE"
AXE = "AXE"
HOE = "HOE"
HELMET = "HELMET"
CHESTPLATE = "CHESTPLATE"
LEGGINGS = "LEGGINGS"
BOOTS = "BOOTS"

class Addendum:
    def __init__(self, material="NONE", tool="NONE", armor="NONE"):
        self.material = material
        self.tool = tool
        self.armor = armor

addendums = {
    "SHOVEL_IRON": Addendum(material=IRON, tool=SHOVEL),
    "PICK_IRON": Addendum(material=IRON, tool=PICKAXE),
    "AXE_IRON": Addendum(material=IRON, tool=AXE),
    "SWORD_IRON": Addendum(material=IRON, tool=SWORD),
    "SWORD_WOOD": Addendum(material=WOOD, tool=SWORD),
    "SHOVEL_WOOD": Addendum(material=WOOD, tool=SHOVEL),
    "PICK_WOOD": Addendum(material=WOOD, tool=PICKAXE),
    "AXE_WOOD": Addendum(material=WOOD, tool=AXE),
    "SWORD_STONE": Addendum(material=STONE, tool=SWORD),
    "SHOVEL_STONE": Addendum(material=STONE, tool=SHOVEL),
    "PICK_STONE": Addendum(material=STONE, tool=PICKAXE),
    "AXE_STONE": Addendum(material=STONE, tool=AXE),
    "SWORD_DIAMOND": Addendum(material=DIAMOND, tool=SWORD),
    "SHOVEL_DIAMOND": Addendum(material=DIAMOND, tool=SHOVEL),
    "PICK_DIAMOND": Addendum(material=DIAMOND, tool=PICKAXE),
    "AXE_DIAMOND": Addendum(material=DIAMOND, tool=AXE),
    "SWORD_GOLD": Addendum(material=GOLD, tool=SWORD),
    "SHOVEL_GOLD": Addendum(material=GOLD, tool=SHOVEL),
    "PICK_GOLD": Addendum(material=GOLD, tool=PICKAXE),
    "AXE_GOLD": Addendum(material=GOLD, tool=AXE),
    "HOE_WOOD": Addendum(material=WOOD, tool=HOE),
    "HOE_STONE": Addendum(material=STONE, tool=HOE),
    "HOE_IRON": Addendum(material=IRON, tool=HOE),
    "HOE_DIAMOND": Addendum(material=DIAMOND, tool=HOE),
    "HOE_GOLD": Addendum(material=GOLD, tool=HOE),
    "CAP_LEATHER": Addendum(armor=HELMET),
    "TUNIC_LEATHER": Addendum(armor=CHESTPLATE),
    "PANTS_LEATHER": Addendum(armor=LEGGINGS),
    "BOOTS_LEATHER": Addendum(armor=BOOTS),
    "HELMET_CHAIN": Addendum(armor=HELMET),
    "CHESTPLATE_CHAIN": Addendum(armor=CHESTPLATE),
    "LEGGINGS_CHAIN": Addendum(armor=LEGGINGS),
    "BOOTS_CHAIN": Addendum(armor=BOOTS),
    "HELMET_IRON": Addendum(armor=HELMET),
    "CHESTPLATE_IRON": Addendum(armor=CHESTPLATE),
    "LEGGINGS_IRON": Addendum(armor=LEGGINGS),
    "BOOTS_IRON": Addendum(armor=BOOTS),
    "HELMET_DIAMOND": Addendum(armor=HELMET),
    "CHESTPLATE_DIAMOND": Addendum(armor=CHESTPLATE),
    "LEGGINGS_DIAMOND": Addendum(armor=LEGGINGS),
    "BOOTS_DIAMOND": Addendum(armor=BOOTS),
    "HELMET_GOLD": Addendum(armor=HELMET),
    "CHESTPLATE_GOLD": Addendum(armor=CHESTPLATE),
    "LEGGINGS_GOLD": Addendum(armor=LEGGINGS),
    "BOOTS_GOLD": Addendum(armor=BOOTS),
}

food = {
    "BREAD": 5,
    "PORKCHOP_RAW": 3,
    "PORKCHOP_COOKED": 8,
    "APPLE_GOLDEN": 20,
    "MUSHROOM_SOUP": 10,
    "FISH_RAW": 2,
    "FISH_COOKED": 5,
    "COOKIE": 1,
    "APPLE": 4,
}

# betamine uses more intuitive names than Minecraft, so we hardcode these
# instead of using the Burger dump
item_names = {
    256: "SHOVEL_IRON",
    257: "PICK_IRON",
    258: "AXE_IRON",
    259: "FLINT_STEEL",
    260: "APPLE",
    261: "BOW",
    262: "ARROW",
    263: "COAL",
    264: "DIAMOND",
    265: "IRON_INGOT",
    266: "GOLD_INGOT",
    267: "SWORD_IRON",
    268: "SWORD_WOOD",
    269: "SHOVEL_WOOD",
    270: "PICK_WOOD",
    271: "AXE_WOOD",
    272: "SWORD_STONE",
    273: "SHOVEL_STONE",
    274: "PICK_STONE",
    275: "AXE_STONE",
    276: "SWORD_DIAMOND",
    277: "SHOVEL_DIAMOND",
    278: "PICK_DIAMOND",
    279: "AXE_DIAMOND",
    280: "STICK",
    281: "BOWL",
    282: "MUSHROOM_SOUP",
    283: "SWORD_GOLD",
    284: "SHOVEL_GOLD",
    285: "PICK_GOLD",
    286: "AXE_GOLD",
    287: "STRING",
    288: "FEATHER",
    289: "GUNPOWDER",
    290: "HOE_WOOD",
    291: "HOE_STONE",
    292: "HOE_IRON",
    293: "HOE_DIAMOND",
    294: "HOE_GOLD",
    295: "SEEDS",
    296: "WHEAT",
    297: "BREAD",
    298: "CAP_LEATHER",
    299: "TUNIC_LEATHER",
    300: "PANTS_LEATHER",
    301: "BOOTS_LEATHER",
    302: "HELMET_CHAIN",
    303: "CHESTPLATE_CHAIN",
    304: "LEGGINGS_CHAIN",
    305: "BOOTS_CHAIN",
    306: "HELMET_IRON",
    307: "CHESTPLATE_IRON",
    308: "LEGGINGS_IRON",
    309: "BOOTS_IRON",
    310: "HELMET_DIAMOND",
    311: "CHESTPLATE_DIAMOND",
    312: "LEGGINGS_DIAMOND",
    313: "BOOTS_DIAMOND",
    314: "HELMET_GOLD",
    315: "CHESTPLATE_GOLD",
    316: "LEGGINGS_GOLD",
    317: "BOOTS_GOLD",
    318: "FLINT",
    319: "PORKCHOP_RAW",
    320: "PORKCHOP_COOKED",
    321: "PAINTING",
    322: "APPLE_GOLDEN",
    323: "SIGN",
    324: "DOOR_WOOD",
    325: "BUCKET",
    326: "BUCKET_WATER",
    327: "BUCKET_LAVA",
    328: "MINECART",
    329: "SADDLE",
    330: "DOOR_IRON",
    331: "REDSTONE",
    332: "SNOWBALL",
    333: "BOAT",
    334: "LEATHER",
    335: "BUCKET_MILK",
    336: "BRICK",
    337: "CLAY",
    338: "SUGARCANE",
    339: "PAPER",
    340: "BOOK",
    341: "SLIMEBALL",
    342: "MINECART_CHEST",
    343: "MINECART_FURNACE",
    344: "EGG",
    345: "COMPASS",
    346: "FISHING_ROD",
    347: "CLOCK",
    348: "GLOWSTONE_DUST",
    349: "FISH_RAW",
    350: "FISH_COOKED",
    351: "DYE",
    352: "BONE",
    353: "SUGAR",
    354: "CAKE",
    355: "BED",
    356: "REDSTONE_REPEATER",
    357: "COOKIE",
    358: "MAP",
    359: "SHEARS",
    2256: "DISC_13",
    2257: "DISC_CAT",
}

f = open("scripts/burger-b1.7.json")
db = json.loads(f.read())
items = db[0]["items"]["item"]
items = [items[key] for key in items]

def item_material(item):
    name = item_names[item["id"]]
    if name in addendums:
        return addendums[name].material
    return "NONE"

def item_tool(item):
    name = item_names[item["id"]]
    if name in addendums:
        return addendums[name].tool
    return "NONE"

def item_armor(item):
    name = item_names[item["id"]]
    if name in addendums:
        return addendums[name].armor
    return "NONE"

template = env.get_template("items.ha.in")
print(template.render(
    items=items,
    item_names=item_names,
    item_material=item_material,
    item_tool=item_tool,
    item_armor=item_armor,
    food=food,
))
