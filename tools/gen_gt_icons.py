#!/usr/bin/env python3
"""Item icons from GregTech textures instead of the recolored placeholders of gen_icons.py (issue #40).

Sources (all redistributable, see the License section of README.md):
  * GT5-Unofficial (GTNewHorizons, LGPL-3.0), including the mods merged into it (GoodGenerator,
    bartworks, GT++ "miscutils", TecTech):            --gt   <checkout>
  * NewHorizonsCoreMod (GTNewHorizons, GPL-3.0; stargate parts, the UMV/UXV circuits):
                                                       --core <checkout>

How an icon is made (first frame of animated textures, 16x16 scaled 2x to Gregtorio's 32x32, like
the other fork icons):
  * the GT texture of the same item (tier components, circuits, wafers, chips, SMDs, fusion casings)
  * materials (ingot, plate, foil, rod, gear, dust, ...): GT's material icon set tinted with GT's
    material colour, overlay on top untinted, the way GT renders them (the colours and sets are read
    from GT's MaterialsInit.java; materials GT lacks or keeps elsewhere are in MATERIALS)
  * where GT has no texture, a composition of GT parts (a base plus an overlay): wires and cables
    (GT renders them as blocks), wraps, hatches, hulls, coils, controllers

Writes graphics/icons/<name>.png for every item listed in tools/gt-icon-items.txt (the items that had a
placeholder icon; an item without a GT source is reported and keeps its icon).

    python tools/gen_gt_icons.py --gt C:/00_Repositories/GT5-Unofficial --core C:/00_Repositories/NewHorizonsCoreMod
    python tools/gen_gt_icons.py --gt ... --core ... --only uhv-motor tritanium-plate
"""
import argparse, re, warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "graphics/icons"
LIST = ROOT / "tools/gt-icon-items.txt"
SIZE = 32

TIERS = ["lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"]
GT_TIER = {"lv": "LV", "mv": "MV", "hv": "HV", "ev": "EV", "iv": "IV", "luv": "LuV", "zpm": "ZPM", "uv": "UV",
           "uhv": "UHV", "uev": "UEV", "uiv": "UIV", "umv": "UMV", "uxv": "UXV", "max": "MAX"}
# tier colour of the fork's machine casings (same as TIER_TINT in gen_sprites.py)
TIER_TINT = {"iv": (100, 100, 160), "luv": (255, 205, 225), "zpm": (140, 225, 245), "uv": (130, 215, 140),
             "uhv": (235, 120, 120), "uev": (240, 200, 90), "uiv": (120, 150, 255), "umv": (190, 120, 235),
             "uxv": (245, 245, 250), "max": (255, 255, 255)}

M1 = "gt:gregtech/textures/items/gt.metaitem.01/"
M3 = "gt:gregtech/textures/items/gt.metaitem.03/"
BLK = "gt:gregtech/textures/blocks/iconsets/"
GTPP = "gt:miscutils/textures/blocks/iconsets/"
GTPP_TE = "gt:miscutils/textures/blocks/TileEntities/"
GG = "gt:goodgenerator/textures/"
CORE = "core:dreamcraft/textures/items/"

# GT component ids (gt.metaitem.01), LuV .. MAX
COMPONENT_IDS = {
    "motor": [606, 607, 608, 596, 595, 17, 18, 19, 20],
    "pump": [615, 616, 617, 618, 619, 25, 26, 27, 28],
    "conveyor-module": [635, 636, 637, 638, 639, 29, 30, 31, 32],
    "piston": [645, 646, 647, 648, 649, 21, 22, 23, 24],
    "robot-arm": [655, 656, 657, 658, 659, 33, 34, 35, 36],
    "emitter": [685, 686, 687, 688, 689, 37, 38, 39, 40],
    "sensor": [695, 696, 697, 698, 699, 41, 42, 43, 44],
    "field-generator": [675, 676, 677, 678, 679, 45, 46, 47, 48],
}
HIGH_TIERS = ["luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"]
# Composer.readable: gamma for the dark tones and the colour of the outline of the component icons
READABLE_GAMMA = 0.6
READABLE_OUTLINE = (176, 176, 184)

# fusion reactor MK -> (casing, coil, controller face): GT MK1-MK3, then the casings of GT++ and the coils and
# screens of GoodGenerator's compact fusion computers MK-IV and MK-V (the same art gen_sprites.py uses)
FUSION = {
    1: (f"{BLK}MACHINE_CASING_FUSION", f"{BLK}MACHINE_CASING_FUSION_COIL", f"{BLK}OVERLAY_FUSION1"),
    2: (f"{BLK}MACHINE_CASING_FUSION_2", f"{BLK}MACHINE_CASING_FUSION_COIL", f"{BLK}OVERLAY_FUSION2"),
    3: (f"{BLK}MACHINE_CASING_FUSION_2", f"{BLK}MACHINE_CASING_FUSION_COIL", f"{BLK}OVERLAY_FUSION3"),
    4: (f"{GTPP}MACHINE_CASING_FUSION_3", f"{GG}blocks/fuison/4", f"{GTPP_TE}adv_machine_screen_random3"),
    5: (f"{GTPP}MACHINE_CASING_FUSION_4", f"{GG}blocks/fuison/5", f"{GTPP_TE}overlay_rainbowscreen"),
}

# Fork material -> GT material name (MaterialsInit.java) or ("SET", (r, g, b)) for the ones GT keeps
# elsewhere (bartworks Werkstoffe, GT++ materials) or does not have. Superconductor bases the fork names
# itself take GT's base of the same tier.
MATERIALS = {
    "americium": "Americium", "bedrockium": "Bedrockium", "cosmic-neutronium": "CosmicNeutronium",
    "draconium": "Draconium", "enderium": "Enderium", "eternity": "Eternity", "europium": "Europium",
    "fluxed-electrum": "ElectrumFlux", "hsss": "HSSS", "infinity": "Infinity", "magnetic-samarium": "SamariumMagnetic",
    "naquadah": "Naquadah", "naquadah-alloy": "NaquadahAlloy", "naquadria": "Naquadria", "nether-star": "NetherStar",
    "neutronium": "Neutronium", "niobium-titanium": "NiobiumTitanium", "osmiridium": "Osmiridium",
    "quantium": "Quantium", "samarium": "Samarium", "spacetime": "SpaceTime", "transcendent-metal": "TranscendentMetal",
    "trinium": "Trinium", "tritanium": "Tritanium", "universium": "Universium", "vanadium-gallium": "VanadiumGallium",
    "manganese": "Manganese", "uranium": "Uranium", "vanadium": "Vanadium", "indium": "Indium", "arsenic": "Arsenic",   # issue #375: the melts of the transmutations
    "calcium-carbide": "CacliumCarbide", "calcium-hydroxide": ("DULL", (255, 255, 255)),   # issue #378
    "cobalt-ii-nitrate": ("POWDER", (170, 0, 0)), "cobalt-ii-hydroxide": "CobaltIIHydroxide",
    "cobalt-ii-naphthenate": ("POWDER", (90, 60, 30)), "terephthaloyl-chloride": "TerephthaloylChloride",
    "cupric-oxide": "CupricOxide", "bismuth-iii-oxide": "BismuthIIIOxide", "2-butyne-1-4-diol": ("POWDER", (240, 240, 200)),
    "nickel-aluminide": "NickelAluminide", "raney-nickel": "RaneyNickelActivated",
    "p-phenylenediamine": ("POWDER", (100, 60, 30)), "diphenylmethane-diisocyanate": "DiphenylmethaneDiisocyanate",
    "pentaerythritol": "Pentaerythritol", "rhodium-chloride": "RhodiumChloride", "triphenylphosphine": "Triphenylphosphene",
    "sodium-hydride": "SodiumHydride", "sodium-borohydride": "SodiumBorohydride", "sodium-methoxide": "SodiumMethoxide",
    "organorhodium-catalyst": "OrganorhodiumCatalyst", "polyurethane-catalyst-a": ("DULL", (200, 200, 100)), "kevlar": "Kevlar", "radox-polymer": "RadoxPoly",
    "antimony-trioxide": "AntimonyTrioxide",   # issue #378
    # issue #386: the isotopes (GT++'s MaterialsElements colours and texture sets) and GT++'s fluorides (MaterialsFluorides)
    "thorium-232": ("NUCLEAR", (15, 60, 15)), "uranium-232": ("NUCLEAR", (88, 220, 103)),
    "uranium-233": ("NUCLEAR", (73, 220, 83)), "plutonium-238": ("NUCLEAR", (240, 50, 50)), "plutonium-241": "Plutonium241",
    "polonium": ("NUCLEAR", (180, 170, 180)), "thallium": ("METALLIC", (175, 175, 175)), "lutetium": "Lutetium",
    "uranium-235": "Uranium235", "plutonium-239": "Plutonium", "lithium-7": ("SHINY", (225, 220, 255)),
    "lithium-hydroxide": ("DULL", (220, 220, 220)), "lithium-fluoride": ("DULL", (240, 240, 240)),
    "beryllium-hydroxide": ("DULL", (100, 140, 100)), "beryllium-fluoride": ("DULL", (120, 200, 120)),
    "zirconium-tetrafluoride": ("DULL", (170, 170, 170)), "cooked-zirconium-tetrachloride": ("DULL", (180, 160, 140)),
    "thorium-hydroxide": ("DULL", (60, 80, 60)),
    "zirconium-chloride-pellet": ("ROUGH", (180, 180, 170)),
    "hastelloy-n": ("METALLIC", (150, 150, 170)),   # GT++ alloy (colour from its components)
    "lithium-tetrafluoroberyllate": ("DULL", (200, 230, 200)), "sodium-fluoride": ("DULL", (230, 230, 240)),
    "protactinium": ("NUCLEAR", (190, 140, 60)), "talonite": ("METALLIC", (228, 200, 200)),
    "niobium-carbide": ("DULL", (100, 100, 100)), "hastelloy-x": ("METALLIC", (160, 160, 180)),
    "rhenium": ("METALLIC", (180, 180, 190)), "hs188-a": ("METALLIC", (160, 140, 180)), "uranium-233": ("NUCLEAR", (73, 220, 83)),   # (GT++'s itemZirconiumPellet texture is not in the checkout)
    "callisto-ice": "CallistoIce", "plutonium": "Plutonium241", "tungstensteel": "TungstenSteel",
    # superconductor bases (fork names, GT's base of the same tier)
    "itbtc-alloy": "Tetraindiumditindibariumtitaniumheptacoppertetrakaidekaoxid",       # LuV
    "palladium-naqindium": "Tetranaquadahdiindiumhexaplatiumosminid",                    # ZPM
    "naquamiridium": "Longasssuperconductornameforuvwire",                               # UV
    "triamerotronium": "Longasssuperconductornameforuhvwire",                            # UHV
    "dracofinium": "SuperconductorUEVBase",                                              # UEV
    "chromnorox": "SuperconductorUIVBase",                                               # UIV
    "hypocosmium": "SuperconductorUMVBase",                                              # UMV
    # bartworks Werkstoffe (WerkstoffLoader.java)
    "ruridit": ("METALLIC", (0xA4, 0xA4, 0xA4)),
    "rhodium-plated-palladium": ("SHINY", (0xDC, 0xDC, 0xF0)),      # Materials.Chrome colour, like bartworks
    # goodgenerator Werkstoff (GGMaterial.java, issue #228)
    "incoloy-903": ("METALLIC", (0xA4, 0x8F, 0x8B)),
    # GT++ (MaterialsElements.java)
    "rhugnor": ("CUSTOM/rhugnor", (190, 0, 255)),
    # GT builds magmatter with a material builder (TextureSet.SET_MAGMATTER, no colour)
    "magmatter": ("CUSTOM/magmatter", (255, 255, 255)),
    # GT++ (MaterialMisc.java): the glue line of issue #91
    "sodium-cyanide": ("DULL", (180, 190, 255)), "cyanoacetic-acid": ("DULL", (130, 130, 40)),
    # issue #99: GT's gasoline (SET_FLUID, orange) for its cell
    "gasoline": "Gasoline",
    # issue #98: black plutonium (hot ingot, ingot), the high octane cell, sodium bisulfate
    "black-plutonium": "BlackPlutonium", "high-octane-gasoline": "HighOctaneGasoline", "sodium-bisulfate": "SodiumBisulfate",
    # issue #295: GT++'s H8N4C2O4 Rocket Fuel (GTPPFluids.java:371-377: a fluid, RGB 50, 220, 50) for its cell
    "rocket-fuel": ("FLUID", (50, 220, 50)),
    # issue #362: GT++'s other rocket fuels (GTPPFluids.java:379-401) for their cells, phthalic anhydride (ModItems.java:686)
    "rp-1-rocket-fuel": ("FLUID", (250, 50, 50)), "dense-hydrazine-fuel-mixture": ("FLUID", (175, 80, 120)),
    "cn3h7o3-rocket-fuel": ("FLUID", (125, 75, 180)), "phthalic-anhydride": ("DULL", (175, 175, 175)),
    # issue #96: bartworks Werkstoffe of the platinum line (WerkstoffLoader.java, their colours; dusts)
    "platinum-salt": ("DULL", (255, 255, 200)), "refined-platinum-salt": ("DULL", (255, 255, 200)),
    "reprecipitated-platinum": ("DULL", (255, 255, 200)), "platinum-residue": ("DULL", (100, 99, 46)),
    "palladium-salt": ("DULL", (177, 177, 177)), "reprecipitated-palladium": ("DULL", (177, 177, 177)),
    "potassium-disulfate": ("DULL", (251, 187, 102)), "rhodium-filter-cake": ("DULL", (119, 102, 73)),
    "reprecipitated-rhodium": ("DULL", (119, 102, 73)), "iridium-dioxide": ("DULL", (132, 102, 73)),
    "sludge-dust-residue": ("DULL", (132, 102, 73)), "iridium-chloride": ("DULL", (132, 102, 73)),
    "metallic-sludge-dust-residue": ("DULL", (132, 102, 73)),
    # issue #185: the ores of the ore chain (their purified, centrifuged, impure and pure forms) and the nine byproduct
    # dusts Gregtorio lacked (GT material of the same ore; bornite: the bartworks Werkstoff colour, WerkstoffLoader.java:336)
    "iron": "Iron", "vanadium-magnetite": "VanadiumMagnetite", "gold": "Gold", "fullers-earth": "FullersEarth",
    "copper": "Copper", "tin": "Tin", "realgar": "Realgar", "galena": "Galena", "lead": "Lead", "silver": "Silver",
    "cryolite": "Cryolite", "tetrahedrite": "Tetrahedrite", "stibnite": "Stibnite", "sphalerite": "Sphalerite",
    "bauxite": "Bauxite", "aluminium": "Aluminium", "ilmenite": "Ilmenite", "redstone": "Redstone", "ruby": "Ruby",
    "cinnabar": "Cinnabar", "coal": "Coal", "graphite": "Graphite", "diamond": "Diamond", "salt": "Salt",
    "rock-salt": "RockSalt", "lepidolite": "Lepidolite", "nether-quartz": "NetherQuartz", "barite": "Barite",
    "certus-quartz": "CertusQuartz", "apatite": "Apatite", "tricalcium-phosphate": "TricalciumPhosphate",
    "pyrochlore": "Pyrochlore", "nickel": "Nickel", "pentlandite": "Pentlandite", "cobaltite": "Cobaltite",
    "lazurite": "Lazurite", "sodalite": "Sodalite", "lapis": "Lapis", "beryllium": "Beryllium", "emerald": "Emerald",
    "thorium": "Thorium", "bastnasite": "Bastnasite", "monazite": "Monazite", "molybdenite": "Molybdenite",
    "neodymium": "Neodymium", "grossular": "Grossular", "spessartine": "Spessartine", "pyrolusite": "Pyrolusite",
    "tantalite": "Tantalite", "bornite": ("DULL", (0x97, 0x66, 0x2B)), "sheldonite": "Cooperite",
    "scheelite": "Scheelite", "tungstate": "Tungstate", "pitchblende": "Pitchblende", "uraninite": "Uraninite",
    "chromite": "Chromite", "ledox": "Ledox", "adamantium": "Adamantium", "borax": "Borax",
    "infinity-catalyst": "InfinityCatalyst", "andradite": "Andradite", "red-garnet": "GarnetRed",
    "yellow-garnet": "GarnetYellow", "lignite": "Lignite", "magnetite": "Magnetite",
    "netherrack": "Netherrack", "pyrite": "Pyrite", "quartzite": "Quartzite",
    "dark-ash": "DarkAsh",  # issue #193
    "cassiterite": "Cassiterite",  # issue #202: its own crushed ore, dust and ore chain
    "ender-pearl": "EnderPearl", "ender-eye": "EnderEye",  # issue #325: dust, plate and lens of the NAND/NOR lenses
    "antimony": "Antimony", "molybdenum": "Molybdenum",  # issue #205: their ingots
    # issue #203: the crushed ores and chains of gypsum, sulfur and calcite, calcite's byproduct malachite; issue #207:
    # the garnet minerals, bartworks' platinum metallic powder (WerkstoffLoader.java:811, platinum's colour)
    "gypsum": "Gypsum", "sulfur": "Sulfur", "calcite": "Calcite", "malachite": "Malachite", "pyrope": "Pyrope",
    "almandine": "Almandine", "uvarovite": "Uvarovite", "metallic-platinum-powder": ("METALLIC", (255, 255, 200)),
    # issue #205: goodgenerator's Werkstoffe of the naquadah line (GGMaterial.java, their colours; dusts)
    "naquadria-oxide-mixture": ("METALLIC", (77, 77, 85)), "indium-phosphate": ("DULL", (43, 46, 112)),
    "low-quality-naquadria-phosphate": ("DULL", (77, 77, 85)),
    "ash": "Ash",  # issue #223: GT's Ashes (bricked blast furnace with coke, malachite's blast furnace recipe)
    "potash": "Potash", "banded-iron": "BandedIron",  # issue #225: GT's dusts of the ash centrifuge
    # issue #262: gtnhlanth's Werkstoffe of the monazite line (WerkstoffMaterialPool.java, SET_DULL and their colours);
    # gadolinium is GT's element
    "monazite-sulfate": ("DULL", (152, 118, 84)),
    "acidic-monazite-powder": ("DULL", (50, 23, 77)),
    "monazite-rare-earth-filtrate": ("DULL", (72, 60, 50)),
    "thorium-phosphate-cake": ("DULL", (188, 143, 143)),
    "thorium-phosphate-concentrate": ("DULL", (217, 144, 88)),
    "neutralized-monazite-rare-earth-filtrate": ("DULL", (50, 23, 77)),
    "monazite-rare-earth-hydroxide-concentrate": ("DULL", (193, 154, 107)),
    "uranium-filtrate": ("DULL", (190, 240, 94)),
    "neutralized-uranium-filtrate": ("DULL", (217, 120, 88)),
    "dried-monazite-rare-earth-concentrate": ("DULL", (250, 214, 165)),
    "cerium-dioxide": ("DULL", (255, 255, 255)),
    "cooled-monazite-rare-earth-concentrate": ("DULL", (250, 214, 165)),
    "monazite-rarer-earth-sediment": ("DULL", (250, 214, 165)),
    "heterogenous-halogenic-monazite-rare-earth-mixture": ("DULL", (250, 214, 165)),
    "saturated-monazite-rare-earth": ("DULL", (250, 214, 165)),
    "samaric-residue": ("DULL", (248, 243, 231)),
    "gadolinium": "Gadolinium",
    # issue #269: the Werkstoffe of the bastnasite and cerium lines (gtnhlanth WerkstoffMaterialPool.java, SET_DULL;
    # vanadium pentoxide is GoodGenerator's GGMaterial.java, SET_SHINY); cerium and lanthanum are GT's elements
    "bastnasite-rare-earth-oxides": ("DULL", (205, 133, 63)),
    "acid-leached-bastnasite-rare-earth-oxides": ("DULL", (205, 133, 63)),
    "roasted-rare-earth-oxides": ("DULL", (160, 82, 45)),
    "wet-rare-earth-oxides": ("DULL", (160, 82, 49)),
    "cerium-oxidised-rare-earth-oxides": ("DULL", (160, 82, 49)),
    "bastnasite-rarer-earth-oxides": ("DULL", (160, 82, 49)),
    "neodymium-rare-earth-concentrate": ("DULL", (170, 90, 60)),
    "lanthanum-chloride": ("DULL", (82, 112, 102)),
    "neodymium-oxide": ("DULL", (82, 112, 102)),
    "cerium-chloride": ("DULL", (255, 255, 255)),
    "cerium-oxalate": ("DULL", (255, 255, 224)),
    "cerium-iii-oxide": ("DULL", (255, 255, 102)),
    "vanadium-pentoxide": ("SHINY", (0xDE, 0x8D, 0x12)),
    "cerium": "Cerium", "lanthanum": "Lanthanum",
    # issue #272: europium, zirconium, lanthanum hexaboride and the samaric branch (gtnhlanth WerkstoffMaterialPool.java;
    # zirconium and red zircon are bartworks' WerkstoffLoader.java, ammonium nitrate GT++'s dust, ModItems.java);
    # europium, holmium and terbium are GT's elements
    "europium-iii-oxide": ("DULL", (255, 230, 255)),
    "europium-oxide": ("DULL", (255, 255, 255)),
    "hafnia-zirconia-blend": ("DULL", (247, 223, 203)),
    "zirconia": ("SHINY", (177, 152, 101)),
    "zirconium-tetrachloride": ("DULL", (179, 164, 151)),
    "zirconium": ("METALLIC", (175, 175, 175)),
    "red-zircon": ("GEM_VERTICAL", (195, 19, 19)),
    "lanthanum-oxide": ("DULL", (105, 209, 180)),
    "boron-trioxide": ("DULL", (238, 222, 209)),
    "lanthanum-hexaboride": ("GEM_HORIZONTAL", (140, 110, 120)),
    "samaric-rare-earth-concentrate": ("DULL", (170, 90, 60)),
    "fluorinated-samaric-concentrate": ("DULL", (255, 182, 193)),
    "samarium-terbium-mixture": ("DULL", (223, 182, 193)),
    "nitrogenated-samarium-terbium-mixture": ("DULL", (223, 182, 193)),
    "terbium-nitrate": ("DULL", (167, 252, 0)),
    "ammonium-nitrate": ("DULL", (150, 75, 150)),
    "holmium": "Holmium", "terbium": "Terbium",
    # issue #274: bartworks' hafnium (gtnhlanth WerkstoffMaterialPool.java) and gangue
    "hafnium": ("METALLIC", (232, 224, 219)),
    # issue #249: GT's amalgatite (MaterialsInit.java loadAmalgatite, the stargate crystal texture set)
    "amalgatite": "Amalgatite",
    "gangue": ("DULL", (0, 0, 0)),
    # issue #227: the metals whose GT parts are new (GT materials; GT++ alloys: set and colour of MaterialsAlloy.java)
    "annealed-copper": "AnnealedCopper",
    "battery-alloy": "BatteryAlloy",
    "black-steel": "BlackSteel",
    "blue-steel": "BlueSteel",
    "brass": "Brass",
    "bronze": "Bronze",
    "chromium": "Chrome",
    "cobalt-brass": "CobaltBrass",
    "conductive-iron": "ConductiveIron",
    "cupronickel": "Cupronickel",
    "dark-steel": "DarkSteel",
    "eglin-steel": ("METALLIC", (139, 69, 19)),  # GT++ EGLIN_STEEL
    "electrical-steel": "ElectricalSteel",
    "electrum": "Electrum",
    "end-steel": "EndSteel",
    "energetic-alloy": "EnergeticAlloy",
    "enriched-naquadah": "NaquadahEnriched",
    "gallium": "Gallium",
    "grisium": ("METALLIC", (53, 93, 106)),  # GT++ LEAGRISIUM
    "hastelloy-c276": ("METALLIC", (90, 74, 88)),  # GT++ HASTELLOY_C276 (GT++ mixes the colour of its parts: here the ingot icon's)
    "hastelloy-w": ("METALLIC", (97, 94, 122)),  # GT++ HASTELLOY_W (GT++ mixes the colour of its parts: here the ingot icon's)
    "hastelloy-x": ("METALLIC", (100, 98, 109)),  # GT++ HASTELLOY_X (GT++ mixes the colour of its parts: here the ingot icon's)
    "hsse": "HSSE",
    "hssg": "HSSG",
    "incoloy-020": ("METALLIC", (120, 96, 90)),  # GT++ INCOLOY_020 (GT++ mixes the colour of its parts: here the ingot icon's)
    "incoloy-ds": ("METALLIC", (97, 93, 123)),  # GT++ INCOLOY_DS (GT++ mixes the colour of its parts: here the ingot icon's)
    "incoloy-ma956": ("METALLIC", (35, 101, 70)),  # GT++ INCOLOY_MA956 (GT++ mixes the colour of its parts: here the ingot icon's)
    "inconel-625": ("METALLIC", (128, 200, 128)),  # GT++ INCONEL_625
    "inconel-690": ("METALLIC", (118, 220, 138)),  # GT++ INCONEL_690
    "inconel-792": ("METALLIC", (108, 240, 118)),  # GT++ INCONEL_792
    "invar": "Invar",
    "iridium": "Iridium",
    "kanthal": "Kanthal",
    "magnalium": "Magnalium",
    "maraging-steel-250": ("SHINY", (104, 97, 141)),  # GT++ MARAGING250 (GT++ mixes the colour of its parts: here the ingot icon's)
    "maraging-steel-300": ("SHINY", (98, 99, 143)),  # GT++ MARAGING300 (GT++ mixes the colour of its parts: here the ingot icon's)
    "nichrome": "Nichrome",
    "nickel-zinc-ferrite": "NickelZincFerrite",
    "nitinol-60": ("SHINY", (136, 117, 159)),  # GT++ NITINOL_60 (GT++ mixes the colour of its parts: here the ingot icon's)
    "osmium": "Osmium",
    "palladium": "Palladium",
    "platinum": "Platinum",
    "potin": ("METALLIC", (201, 151, 129)),  # GT++ POTIN
    "pulsating-iron": "PulsatingIron",
    "red-alloy": "RedAlloy",
    "silicon": "Silicon",
    "soularium": "Soularium",
    "staballoy": ("SHINY", (68, 75, 66)),  # GT++ STABALLOY
    "stainless-steel": "StainlessSteel",
    "steel": "Steel",
    "stellite": ("SHINY", (130, 117, 157)),  # GT++ STELLITE (GT++ mixes the colour of its parts: here the ingot icon's)
    "talonite": ("METALLIC", (124, 121, 113)),  # GT++ TALONITE (GT++ mixes the colour of its parts: here the ingot icon's)
    "tantalloy-60": ("SHINY", (213, 231, 237)),  # GT++ TANTALLOY_60
    "tantalum": "Tantalum",
    "tantalum-carbide": ("SHINY", (139, 136, 120)),  # GT++ TANTALUM_CARBIDE
    "titanium": "Titanium",
    "tumbaga": ("SHINY", (255, 178, 15)),  # GT++ TUMBAGA
    "tungsten": "Tungsten",
    "tungsten-carbide": "TungstenCarbide",
    "ultimet": "Ultimet",
    "vanadium-steel": "VanadiumSteel",
    "vibrant-alloy": "VibrantAlloy",
    "watertight-steel": ("METALLIC", (120, 120, 180)),  # GT++ AQUATIC_STEEL
    "yttrium-barium-cuprate": "YttriumBariumCuprate",
    "zeron-100": ("METALLIC", (180, 180, 20)),  # GT++ ZERON_100
    "zinc": "Zinc",
    "amber": "Amber", "topaz": "Topaz",  # issue #332: the Twilight Forest's ores
    "sapphire": "Sapphire", "green-sapphire": "GreenSapphire",  # issue #364: the sapphire vein
    "desh": "Desh",  # issue #365: the Desh vein of Mars
    "bio-diesel": "BioDiesel", "glycerol": "Glycerol",  # issue #360: their cells
    # issue #358: the polymers' sheets (GT's plates) and raw SBR (a dust)
    "polystyrene": "Polystyrene", "styrene-butadiene-rubber": "StyreneButadieneRubber", "polycaprolactam": "Polycaprolactam",
    "raw-styrene-butadiene-rubber": "RawStyreneButadieneRubber",
    "natural-gas": "NatruralGas", "lpg": "LPG",  # issue #361: their cells (GT spells NatruralGas so)
    # issue #357: goodgenerator's fuels (Werkstoffe: FLUID set in their colour) for their cells, ferrocene (a dust)
    "ether": ("FLUID", (234, 234, 234)),
    "naquadah-gas": ("FLUID", (51, 51, 51)),
    "ethanol-gasoline": ("FLUID", (255, 140, 50)),
    "cyclopentadiene": ("FLUID", (255, 246, 220)),
    "jet-fuel-no-3": ("FLUID", (215, 175, 77)),
    "jet-fuel-a": ("FLUID", (242, 177, 92)),
    "ferrocene": ("DULL", (249, 166, 71)),
    "uranium-carbide-thorium-mixture": ("DULL", (22, 50, 7)),   # issue #357, part 2: the thorium fuel's mixture
    # issue #363, part 2: the Twilight Forest's and the Nether's ores
    "olivine": "Olivine", "bentonite": "Bentonite", "magnesite": "Magnesite", "garnierite": "Garnierite",
    "wulfenite": "Wulfenite", "powellite": "Powellite", "saltpeter": "Saltpeter", "tanzanite": "Tanzanite",
    "amethyst": "Amethyst", "opal": "Opal", "jasper": "Jasper", "blue-topaz": "BlueTopaz", "spinel": "FoolsRuby",
    "jade": "Jade",
    # issue #363: the ores of GTNH's Overworld veins
    "brown-limonite": "BrownLimonite", "yellow-limonite": "YellowLimonite", "chalcopyrite": "Chalcopyrite",
    "spodumene": "Spodumene", "soapstone": "Soapstone", "talc": "Talc", "glauconite": "Glauconite",
    "vermiculite": "Vermiculite", "alunite": "Alunite", "basaltic-mineral-sand": "BasalticMineralSand",
    "granitic-mineral-sand": "GraniticMineralSand", "cassiterite-sand": "CassiteriteSand",
    "garnet-sand": "GarnetSand", "asbestos": "Asbestos", "diatomite": "Diatomite", "kaolinite": "Kaolinite",
    "zeolite": "Zeolite", "glauconite-sand": "GlauconiteSand", "kyanite": "Kyanite", "mica": "Mica",
    "pollucite": "Pollucite", "dolomite": "Dolomite", "wollastonite": "Wollastonite", "trona": "Trona",
    "zirconium-carbide": ("SHINY", (222, 202, 180)),  # GT++ ZIRCONIUM_CARBIDE
}

# fork part name -> GT OrePrefix texture; "{m}" is the material
PARTS = [
    # issue #185: the forms of the ore chain (before "{m}-dust", which would take pure-<m>-dust as a dust of "pure-<m>")
    ("impure-{m}-dust", "dustImpure"), ("pure-{m}-dust", "dustPure"), ("purified-{m}", "crushedPurified"),
    ("centrifuged-{m}", "crushedCentrifuged"), ("crushed-{m}", "crushed"),  # issue #203: crushed sulfur
    ("raw-{m}", "oreRaw"),  # issue #332: the raw ores of new ores (upstream drew the others)
    # issues #187 and #188: small dusts of the separator, the gem grades of the sifter, the gems Gregtorio lacked
    ("small-pile-of-{m}-dust", "dustSmall"), ("chipped-{m}", "gemChipped"), ("flawed-{m}", "gemFlawed"),
    ("flawless-{m}", "gemFlawless"), ("exquisite-{m}", "gemExquisite"), ("{m}-gem", "gem"),
    # issue #193: dark ash, the lenses of the laser engraver
    ("tiny-pile-of-{m}-dust", "dustTiny"), ("{m}-lens", "lens"),
    ("hot-{m}-ingot", "ingotHot"), ("superdense-{m}-plate", "plateSuperdense"), ("dense-{m}-plate", "plateDense"),
    ("long-{m}-rod", "stickLong"), ("large-{m}-gear", "gearGt"), ("fine-{m}-wire", "wireFine"),
    ("{m}-superconductive-wire", "@superconductor"), ("{m}-wire-4x", "@wire4"), ("{m}-wire", "@wire"),
    ("{m}-cable", "@cable"), ("{m}-ingot", "ingot"), ("{m}-plate", "plate"), ("{m}-foil", "foil"),
    ("{m}-rod", "stick"), ("{m}-gear", "gearGtSmall"), ("{m}-ring", "ring"), ("{m}-bolt", "bolt"),
    ("{m}-screw", "screw"), ("{m}-rotor", "rotor"), ("{m}-round", "round"), ("{m}-nugget", "nugget"),
    ("{m}-dust", "dust"), ("{m}-frame", "@frame"), ("{m}-turbine-blade", "turbineBlade"),
    # issue #222: GT's other parts of the metals of #205 (the item casing is GT's casingSmall texture)
    ("double-{m}-plate", "plateDouble"), ("small-{m}-spring", "springSmall"), ("{m}-spring", "spring"),
    ("{m}-item-casing", "casingSmall"), ("block-of-{m}", "@block"),
    # issue #227: GT's multi plates
    ("triple-{m}-plate", "plateTriple"), ("quadruple-{m}-plate", "plateQuadruple"), ("quintuple-{m}-plate", "plateQuintuple"),
]


# ------------------------------------------------------------------------------------------------
# texture access
# ------------------------------------------------------------------------------------------------

class Tex:
    def __init__(self, gt, core):
        self.roots = {"gt": gt / "src/main/resources/assets", "core": core / "src/main/resources/assets" if core else None}
        self.gt = gt
        self.used = set()
        self.trace = []

    def path(self, spec):
        src, rel = spec.split(":", 1)
        if self.roots.get(src) is None:
            return None
        return self.roots[src] / (rel if rel.endswith(".png") else rel + ".png")

    def exists(self, spec):
        p = self.path(spec)
        return p is not None and p.exists()

    def load(self, spec):
        """First frame (GT animations are vertical strips of square frames)."""
        p = self.path(spec)
        if p is None or not p.exists():
            raise FileNotFoundError(spec)
        self.used.add(spec.split("/textures/")[0])
        self.trace.append(spec)
        img = Image.open(p).convert("RGBA")
        w, h = img.size
        return img.crop((0, 0, w, w)) if h > w else img


def fit(img, size=SIZE):
    """Scale to the icon size: integer factors pixel-exact, anything else smooth."""
    if img.size == (size, size):
        return img
    if size % img.width == 0 or img.width % size == 0:
        return img.resize((size, size), Image.NEAREST)
    return img.resize((size, size), Image.LANCZOS)


def tint(img, rgb):
    """GT's colour modulation: every channel multiplied with the material colour."""
    r, g, b = rgb
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            p = px[x, y]
            if p[3]:
                px[x, y] = (p[0] * r // 255, p[1] * g // 255, p[2] * b // 255, p[3])
    return out


def over(base, *layers):
    out = fit(base).copy()
    for l in layers:
        out.alpha_composite(fit(l))
    return out


def shrink(img, factor, dx=0, dy=0):
    """A smaller copy placed on an empty icon (for badges and bundles)."""
    s = int(SIZE * factor)
    small = fit(img).resize((s, s), Image.NEAREST if SIZE % s == 0 else Image.LANCZOS)
    out = Image.new("RGBA", (SIZE, SIZE))
    out.alpha_composite(small, ((SIZE - s) // 2 + dx, (SIZE - s) // 2 + dy))
    return out


# ------------------------------------------------------------------------------------------------
# GT materials
# ------------------------------------------------------------------------------------------------

def gt_materials(gt):
    """name -> (icon set, (r, g, b)) from GT's MaterialsInit.java"""
    src = (gt / "src/main/java/gregtech/loaders/materials/MaterialsInit.java").read_text(encoding="utf-8")
    out = {}
    for block in src.split("new MaterialBuilder()")[1:]:
        block = block[:block.find(";")]
        n = re.search(r'\.setName\("([^"]+)"', block)
        if not n:
            continue
        s = re.search(r"\.setIconSet\(TextureSet\.SET_(\w+)", block)
        c = re.search(r"\.setARGB\((0x[0-9a-fA-F]+)", block)
        rgb = (255, 255, 255)
        if c:
            v = int(c.group(1), 16)
            rgb = ((v >> 16) & 255, (v >> 8) & 255, v & 255)
        out[n.group(1)] = (s.group(1) if s else "NONE", rgb)
    # custom sets live in materialicons/CUSTOM/<name> (TextureSet.java)
    ts = (gt / "src/main/java/gregtech/api/enums/TextureSet.java").read_text(encoding="utf-8")
    custom = {m.group(1): m.group(2) for m in re.finditer(r'SET_(\w+) = new TextureSet\("([^"]+)", (?:true|false)\)', ts)}
    return {k: ("CUSTOM/" + custom[s] if s in custom else s, rgb) for k, (s, rgb) in out.items()}


class Materials:
    def __init__(self, tex):
        self.tex = tex
        self.gt = gt_materials(tex.gt)

    def get(self, mat):
        spec = MATERIALS.get(mat)
        if isinstance(spec, tuple):
            return spec
        if spec is None:
            raise KeyError(f"no GT material for {mat}")
        return self.gt[spec]

    def icon(self, mat, prefix, kind="items"):
        """GT's material icon: <set>/<prefix> (fallback NONE) tinted, <prefix>_OVERLAY untinted"""
        iset, rgb = self.get(mat)
        base_dir = f"gt:gregtech/textures/{kind}/materialicons/"
        base = next((f"{base_dir}{s}/{prefix}" for s in (iset, "NONE") if self.tex.exists(f"{base_dir}{s}/{prefix}")), None)
        if base is None:
            raise FileNotFoundError(f"{mat} {prefix}")
        img = tint(fit(self.tex.load(base)), rgb)
        ov = next((f"{base_dir}{s}/{prefix}_OVERLAY" for s in (iset, "NONE") if self.tex.exists(f"{base_dir}{s}/{prefix}_OVERLAY")), None)
        if ov:
            img.alpha_composite(fit(self.tex.load(ov)))
        return img

    def colour(self, mat):
        """GT's material colour; materials with their own texture set and no colour (white: bedrockium,
        eternity, spacetime, ...) take the average colour of their own ingot or dust texture"""
        iset, rgb = self.get(mat)
        if rgb == (255, 255, 255) and iset.startswith("CUSTOM/"):
            for prefix in ("ingot", "dust"):
                spec = f"gt:gregtech/textures/items/materialicons/{iset}/{prefix}"
                if self.tex.exists(spec):
                    px = [p for p in self.tex.load(spec).getdata() if p[3] > 128]
                    return tuple(sum(p[i] for p in px) // len(px) for i in range(3))
        return rgb


# ------------------------------------------------------------------------------------------------
# compositions of GT parts
# ------------------------------------------------------------------------------------------------

def bar(rgb, width, shade_rgb=None, n=1, ends=None):
    """A diagonal wire bar like Gregtorio's upstream wires (GT renders wires as blocks): n parallel
    strands, lit from the top left, optionally with coloured ends (a cable shows its core there)."""
    img = Image.new("RGBA", (SIZE, SIZE))
    d = ImageDraw.Draw(img)
    hi = tuple(min(255, c + 70) for c in rgb)
    lo = shade_rgb or tuple(c * 55 // 100 for c in rgb)
    offs = [0] if n == 1 else [(-1.5 + i) * (width + 1) for i in range(n)] if n == 4 else [-(width + 1) / 2, (width + 1) / 2]
    for o in offs:
        a, b = (7 + o, 25 + o), (25 + o, 7 + o)
        d.line([a, b], fill=lo + (255,), width=width + 2)
        d.line([a, b], fill=rgb + (255,), width=width)
        d.line([(a[0], a[1] - width // 3), (b[0], b[1] - width // 3)], fill=hi + (255,), width=max(1, width // 3))
        if ends:
            for p in (a, b):
                d.ellipse([p[0] - width / 2, p[1] - width / 2, p[0] + width / 2, p[1] + width / 2], fill=ends + (255,))
    return img


class Composer:
    def __init__(self, tex, mats):
        self.t, self.m = tex, mats

    def gt(self, spec):
        return fit(self.t.load(spec))

    # material parts ------------------------------------------------------------------------------
    def part(self, mat, prefix):
        name = MATERIALS[mat] if isinstance(MATERIALS[mat], str) else mat
        rgb = self.m.colour(mat) if prefix.startswith("@") and prefix != "@frame" else self.m.get(mat)[1]
        if rgb != (255, 255, 255):
            self.t.trace.append("colour of %s #%02x%02x%02x" % ((name,) + rgb))
        if prefix == "@wire":
            return bar(self.m.colour(mat), 4)
        if prefix == "@wire4":
            return bar(self.m.colour(mat), 3, n=2)
        if prefix == "@cable":
            return bar((40, 40, 44), 6, shade_rgb=(15, 15, 18), ends=self.m.colour(mat))
        if prefix == "@superconductor":
            # GT's superconductor wires: the base metal with a pale blue sheen
            img = bar(self.m.colour(mat), 4)
            glow = bar((150, 220, 255), 2)
            glow.putalpha(glow.getchannel("A").point(lambda a: a * 140 // 255))
            img.alpha_composite(glow)
            return img
        if prefix == "@frame":
            return self.m.icon(mat, "frameGt", kind="blocks")
        if prefix == "@block":   # issue #222: GT's storage block texture of the material
            spec = f"{BLK}BLOCK_{name.upper()}"
            if self.t.exists(spec):
                return fit(self.t.load(spec))
            # issue #227: GT++'s blocks (BlockBaseModular.java) are the material icon set's block1 (block5 above tier 4)
            return self.m.icon(mat, "block1", kind="blocks")
        return self.m.icon(mat, prefix)

    # machines ------------------------------------------------------------------------------------
    def casing(self, tier):
        return tint(self.gt(f"{BLK}MACHINE_{GT_TIER[tier]}_SIDE"), TIER_TINT[tier])

    def hatch(self, tier, overlay):
        return over(self.casing(tier), self.t.load(f"{BLK}{overlay.format(T=GT_TIER[tier])}"))

    def wrap(self, spec):
        """bartworks' circuit wraps: the item with the wrap band on top (at 55 % so the item stays visible)"""
        band = fit(self.t.load("gt:bartworks/textures/items/WrapOverlay"))
        band.putalpha(band.getchannel("A").point(lambda a: a * 55 // 100))
        return over(self.t.load(spec), band)

    def face(self, casing, overlay):
        return over(self.t.load(casing), self.t.load(overlay))

    def coil(self, winding):
        """a GT coil block: the frame of GT's trinium coil, its striped winding in another texture or
        colour (winding: (r, g, b) or a texture spec)"""
        frame = self.gt(f"{BLK}MACHINE_COIL_TRINIUM_BACKGROUND")
        fg = self.gt(f"{BLK}MACHINE_COIL_TRINIUM_FOREGROUND")
        if isinstance(winding, tuple):
            peak = max(winding) or 1
            fg = tint(fg, tuple(c * 230 // peak for c in winding))      # GT colour, brightened to be visible
        else:
            tex, px, f = self.gt(winding).copy(), None, fg.load()
            px = tex.load()
            for y in range(SIZE):
                for x in range(SIZE):
                    l = sum(f[x, y][:3]) // 3
                    px[x, y] = tuple(min(255, c * (l + 60) // 255) for c in px[x, y][:3]) + (f[x, y][3],)
            fg = tex
        return over(frame, fg)

    def mini(self, casing, inner, face):
        """a multiblock item: 2x2 GT tiles at their own 16 px (casing, inner block twice, controller face)"""
        out = Image.new("RGBA", (SIZE, SIZE))
        tile = lambda spec: self.t.load(spec).resize((SIZE // 2, SIZE // 2), Image.NEAREST)
        f = tile(casing)
        f.alpha_composite(tile(face))
        for (x, y), img in zip(((0, 0), (1, 0), (0, 1), (1, 1)), (tile(casing), tile(inner), tile(inner), f)):
            out.alpha_composite(img, (x * SIZE // 2, y * SIZE // 2))
        return out

    def recolour(self, spec, rgb):
        """keep the grey metal of a GT item, give its coloured parts another colour (by luminance)"""
        img = self.gt(spec).copy()
        px = img.load()
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, a = px[x, y]
                if a and max(r, g, b) - min(r, g, b) > 40:
                    l = (r * 3 + g * 6 + b) / 10 / 255
                    px[x, y] = tuple(min(255, int(c * (0.35 + l))) for c in rgb) + (a,)
        return img

    def readable(self, img):
        """For Factorio's dark slots: GT draws its components in one untinted pass for Minecraft's light
        grey slot, many in near-black greys or as thin outlines. Dark tones are lifted with a gamma curve
        (keeps the hue, so the tier colour stays) and the shape gets a 1 px light outline."""
        self.t.trace.append("lifted for dark slots, light outline")
        img = fit(img).copy()
        px = img.load()
        for y in range(SIZE):
            for x in range(SIZE):
                r, g, b, a = px[x, y]
                if a:
                    px[x, y] = tuple(int(255 * (c / 255) ** READABLE_GAMMA) for c in (r, g, b)) + (a,)
        mask = img.getchannel("A").point(lambda a: 255 if a else 0).filter(ImageFilter.MaxFilter(3))
        out = Image.new("RGBA", (SIZE, SIZE), READABLE_OUTLINE + (0,))
        out.putalpha(mask)
        out.alpha_composite(img)
        return out

    def badge(self, base, mark, factor=0.5):
        """a small GT part in the bottom right corner of a GT texture"""
        out = fit(base).copy()
        s = int(SIZE * factor)
        small = fit(mark).resize((s, s), Image.NEAREST)
        out.alpha_composite(small, (SIZE - s, SIZE - s))
        return out


# ------------------------------------------------------------------------------------------------
# the items
# ------------------------------------------------------------------------------------------------

def icon_table(c):
    """name -> function returning the icon (evaluated lazily, so --only needs only its sources)"""
    T = {}

    # tier components (LuV .. UXV) and the tier parts GT has
    for part, ids in COMPONENT_IDS.items():
        for tier, i in zip(HIGH_TIERS, ids):
            T[f"{tier}-{part}"] = lambda i=i: c.readable(c.gt(f"{M1}{i}"))
    for tier in HIGH_TIERS:
        T[f"{tier}-machine-casing"] = lambda t=tier: c.casing(t)
        T[f"{tier}-machine-hull"] = lambda t=tier: c.hatch(t, "OVERLAY_ENERGY_OUT_{T}")
        T[f"{tier}-energy-hatch"] = lambda t=tier: c.hatch(t, "OVERLAY_ENERGY_IN_MULTI_2A_{T}")
        T[f"{tier}-dynamo-hatch"] = lambda t=tier: c.hatch(t, "OVERLAY_ENERGY_OUT_MULTI_2A_{T}")
    # tier circuits of the core mod (the fork's generic UMV/UXV circuit)
    T["umv-circuit"] = lambda: c.gt(f"{CORE}itemCircuitUMV")
    T["uxv-circuit"] = lambda: c.gt(f"{CORE}itemCircuitUXV")
    # voltage coils (gt.metaitem.03)
    for name, i in {"ludicrous-voltage-coil": 146, "zero-point-module-voltage-coil": 147, "ultimate-voltage-coil": 148,
                    "highly-ultimate-voltage-coil": 149, "extremely-ultimate-voltage-coil": 259,
                    "insanely-ultimate-voltage-coil": 260, "mega-ultimate-voltage-coil": 261,
                    "extended-mega-ultimate-voltage-coil": 262, "maximum-voltage-coil": 263}.items():
        T[name] = lambda i=i: c.gt(f"{M3}{i}")

    # circuit lines: GT's wetware, bio, optical, exotic and (for the fork's temporal line) the
    # "temporally transcendent" circuits
    for line, ids in {"wetware": (105, 92, 93, 94), "bio": (107, 97, 98, 99), "optical": (728, 154, 155, 156),
                      "exotic": (729, 166, 167, 168), "temporal": (731, 174, 175, 176)}.items():
        board, proc, asm, sup = ids
        T[f"{line}-printed-circuit-board"] = lambda i=board: c.gt(f"{M3}{i}")
        T[f"{line}-processor"] = lambda i=proc: c.gt(f"{M3}{i}")
        T[f"{line}-processor-assembly"] = lambda i=asm: c.gt(f"{M3}{i}")
        T[f"{line}-processor-supercomputer"] = lambda i=sup: c.gt(f"{M3}{i}")
    T["bioware-printed-circuit-board"] = lambda: c.gt(f"{M3}8")
    T["kevlar-fiber"] = lambda: c.gt(f"{M3}192")   # issue #378
    T["woven-kevlar"] = lambda: c.gt(f"{M3}193")
    T["neuro-processing-unit"] = lambda: c.gt(f"{M3}72")
    T["stem-cells"] = lambda: c.gt(f"{M3}73")
    T["bio-cells"] = lambda: c.gt(f"{M3}76")
    T["bio-processing-unit"] = lambda: c.gt(f"{M3}77")
    T["optical-processing-unit"] = lambda: c.gt(f"{M3}726")
    # GT has no exotic/temporal chip: its optical CPU with the board of the line as a badge
    T["exotic-processing-unit"] = lambda: c.badge(c.gt(f"{M3}726"), c.gt(f"{M3}729"))
    T["temporal-processing-unit"] = lambda: c.badge(c.gt(f"{M3}726"), c.gt(f"{M3}731"))
    # phase 6b: the fork's MAX line (Planck) takes GT's cosmic circuits, which the fork does not use otherwise (its
    # UXV line has the transcendent ones); the MAX circuit is GTNH's Planck-scale circuit of the core mod
    for name, i in {"planck-printed-circuit-board": 730, "planck-processor": 170, "planck-processor-assembly": 171,
                    "planck-processor-supercomputer": 172}.items():
        T[name] = lambda i=i: c.gt(f"{M3}{i}")
    T["planck-processing-unit"] = lambda: c.badge(c.gt(f"{M3}726"), c.gt(f"{M3}730"))
    T["max-circuit"] = lambda: c.gt(f"{CORE}itemPlanckCircuit")
    # issue #164: the circuit variant recipes up to UV (prototypes/156-fork-circuit-icons.lua), the texture of their GTNH item
    for name, src in {
            "electronic-circuit": (M3, 305), "basic-electronic-circuit": (M3, 305), "basic-integrated-circuit": (M1, 701),
            "microchip": (M3, 78), "microchip-smd": (M3, 78), "microchip-cheap": (M3, 78),
            "advanced-circuit": (M1, 702), "good-electronic-circuit": (M1, 702), "good-integrated-circuit": (M3, 79),
            "microprocessor": (M3, 80), "microprocessor-smd": (M3, 80), "microprocessor-cheap": (M3, 80),
            "processing-unit": (M3, 306), "microprocessor-assembly": (M1, 703), "microprocessor-assembly-smd": (M1, 703),
            "nanoprocessor": (M3, 82), "nanoprocessor-asoc": (M3, 82),   # (issue #355: its ASoC variant)
            "microprocessor-supercomputer": (M1, 704), "microprocessor-supercomputer-smd": (M1, 704),
            "nanoprocessor-assembly": (M3, 83), "quantum-processor": (M3, 85), "quantum-processor-asoc": (M3, 85),
            "microprocessor-mainframe": (M1, 705), "nanoprocessor-supercomputer": (M3, 84),
            "quantum-processor-assembly": (M3, 86), "crystal-processor": (M3, 89),
            "nanoprocessor-mainframe": (M1, 706), "quantum-processor-supercomputer": (M3, 87),
            "crystal-processor-assembly": (M3, 96),
            "quantum-processor-mainframe": (M3, 88), "crystal-processor-supercomputer": (M3, 90),
            "crystal-processor-mainframe": (M3, 91)}.items():
        T[f"circuit-recipe-{name}"] = lambda s=src: c.gt(f"{s[0]}{s[1]}")
    T["crystal-cpu"] = lambda: c.gt(f"{M3}70")
    T["raw-crystal-chip"] = lambda: c.gt(f"{M3}69")
    T["raw-crystal-chip-part"] = lambda: c.gt(f"{M3}74")
    T["engraved-crystal-chip"] = lambda: c.gt(f"{M1}713")
    T["multilayered-fiber-reinforced-circuit-board"] = lambda: c.gt(f"{M1}712")
    T["multilayered-fiber-reinforced-printed-circuit-board"] = lambda: c.gt(f"{M3}104")
    T["optical-fiber"] = lambda: c.gt("gt:gregtech/textures/items/gt.circuitcomponent/processed/processedcableopticalfiber")

    # wafers, power ICs, SMDs, wraps
    for name, i in {"uhpic-wafer": 58, "ultra-high-powered-integrated-circuit": 59, "npic-wafer": 160,
                    "nano-power-ic": 161, "ppic-wafer": 162, "pico-power-ic": 163, "qpic-wafer": 164,
                    "quantum-power-ic": 165, "fpic-wafer": 266, "femto-power-ic": 267, "apic-wafer": 268,
                    "atto-power-ic": 269, "asoc-wafer": 48, "advanced-system-on-chip": 49, "complex-smd-resistor": 178, "complex-smd-diode": 179,
                    "complex-smd-transistor": 180, "complex-smd-capacitor": 181, "complex-smd-inductor": 184}.items():
        T[name] = lambda i=i: c.gt(f"{M3}{i}")
    for name, i in {"advanced-smd-capacitor-wrap": 27, "advanced-smd-inductor-wrap": 183,
                    "advanced-smd-transistor-wrap": 26, "nand-memory-chip-wrap": 41, "nor-memory-chip-wrap": 43,
                    "ram-chip-wrap": 39, "nano-cpu-chip-wrap": 55}.items():
        T[name] = lambda i=i: c.wrap(f"{M3}{i}")
    T["quark-creation-catalyst"] = lambda: c.gt(f"{M3}241")

    # energy storage and nuclear
    T["energy-module"] = lambda: c.gt(f"{M1}736")
    T["lapotronic-energy-orb-cluster"] = lambda: c.gt(f"{M1}599")
    T["high-density-plutonium"] = lambda: c.gt(f"{GG}items/highDensityPlutonium")
    T["high-density-plutonium-nugget"] = lambda: c.gt(f"{GG}items/highDensityPlutoniumNugget")
    T["wrapped-plutonium-ingot"] = lambda: c.gt(f"{GG}items/wrappedPlutoniumIngot")
    T["radioactive-sludge"] = lambda: c.gt(f"{GG}items/radioactiveWaste")
    for k in (180, 540, 1080):
        T[f"{k}k-space-cell"] = lambda k=k: c.gt(f"gt:gregtech/textures/items/gt.{k}k_Space_Coolantcell")
    # GT has no super coolant cell: the 1080k space cell with super coolant (GT's colour) inside
    T["1080k-super-coolant-cell"] = lambda: c.recolour("gt:gregtech/textures/items/gt.1080k_Space_Coolantcell",
                                                       (0x02, 0x87, 0xB8))

    # fusion: GT casings MK1/MK2, GT++ casings MK3/MK4 and coils, GoodGenerator compact fusion faces
    T["fusion-machine-casing"] = lambda: c.gt(f"{BLK}MACHINE_CASING_FUSION")
    T["fusion-machine-casing-mk2"] = lambda: c.gt(f"{BLK}MACHINE_CASING_FUSION_2")
    T["fusion-machine-casing-mk3"] = lambda: c.gt(f"{GTPP}MACHINE_CASING_FUSION_3")
    T["fusion-machine-casing-mk4"] = lambda: c.gt(f"{GTPP}MACHINE_CASING_FUSION_4")
    T["fusion-coil-block"] = lambda: c.gt(f"{BLK}MACHINE_CASING_FUSION_COIL")
    T["advanced-fusion-coil"] = lambda: c.gt(f"{GTPP}MACHINE_CASING_FUSION_COIL_II")
    T["advanced-fusion-coil-ii"] = lambda: c.gt(f"{GTPP}MACHINE_CASING_FUSION_COIL_III")
    for mk, (cas, coil, ov) in FUSION.items():
        T[f"fusion-reactor-mk{mk}-controller"] = lambda cas=cas, ov=ov: c.face(cas, ov)
        T[f"fusion-reactor-mk{mk}"] = lambda cas=cas, coil=coil, ov=ov: c.mini(cas, coil, ov)

    # coil blocks
    T["superconducting-coil-block"] = lambda: c.gt(f"{BLK}MACHINE_COIL_SUPERCONDUCTOR")
    T["naquadah-coil-block"] = lambda: c.gt(f"{BLK}MACHINE_COIL_NAQUADAH")
    T["trinium-coil-block"] = lambda: c.gt(f"{BLK}MACHINE_COIL_TRINIUM")
    T["eternal-coil-block"] = lambda: c.gt(f"{BLK}MACHINE_COIL_ETERNAL")
    # GT has no tritanium or spacetime coil: a GT coil winding in the metal's colour
    T["tritanium-coil-block"] = lambda: c.coil(c.m.colour("tritanium"))
    T["spacetime-coil-block"] = lambda: c.coil("gt:gregtech/textures/blocks/materialicons/CUSTOM/spacetime/BLOCK_SPACETIME")

    # multiblock controllers (the GT face used by gen_sprites.py) and the multiblock items
    T["bacterial-vat-controller"] = lambda: c.face(f"{BLK}MACHINE_CASING_CLEAN_STAINLESSSTEEL",
                                                   f"{BLK}OVERLAY_FRONT_BIOLOGICAL_COORDINATION")
    T["bacterial-vat"] = lambda: c.mini(f"{BLK}MACHINE_CASING_CLEAN_STAINLESSSTEEL",
                                        "gt:bartworks/textures/blocks/TitaniumReinforcedBoronSilicateGlassBlock",
                                        f"{BLK}OVERLAY_FRONT_BIOLOGICAL_COORDINATION")
    T["circuit-assembly-line-controller"] = lambda: c.face(f"{BLK}MACHINE_CASING_ASSEMBLER",
                                                           f"{BLK}OVERLAY_FRONT_ASSEMBLY_MATRIX")
    T["luv-circuit-assembly-line"] = lambda: c.mini(f"{BLK}MACHINE_CASING_ASSEMBLER", f"{BLK}MACHINE_CASING_GRATE",
                                                    f"{BLK}OVERLAY_FRONT_ASSEMBLY_MATRIX")
    T["zpm-assembly-line"] = lambda: c.mini(f"{BLK}MACHINE_CASING_ASSEMBLER", f"{BLK}MACHINE_CASING_GRATE",
                                            f"{BLK}OVERLAY_FRONT_ASSEMBLY_LINE")
    T["large-naquadah-reactor-controller"] = lambda: c.face(f"{BLK}NAQUADAH_REACTOR_CASING",
                                                            f"{BLK}NAQUADAH_REACTOR_FLUID_FRONT")
    T["large-plasma-turbine-controller"] = lambda: c.face(f"{BLK}MACHINE_CASING_TURBINE_TUNGSTENSTEEL",
                                                          f"{BLK}LARGETURBINE_TU5")
    T["tungstensteel-turbine-rotor"] = lambda: c.part("tungstensteel", "toolTurbine")
    # phase 6a: GT's dimensionally transcendent plasma forge and GT++'s quantum force transformer (their blocks,
    # the controller faces gen_sprites.py uses)
    T["dimensionally-transcendent-casing"] = lambda: c.gt(f"{BLK}MACHINE_DIM_TRANS_CASING")
    T["dimensional-bridge"] = lambda: c.gt(f"{BLK}MACHINE_DIM_BRIDGE")
    T["dimensionally-transcendent-plasma-forge-controller"] = lambda: c.face(f"{BLK}MACHINE_DIM_TRANS_CASING",
                                                                              f"{BLK}OVERLAY_DTPF_ON")
    T["dimensionally-transcendent-plasma-forge"] = lambda: c.mini(f"{BLK}MACHINE_DIM_TRANS_CASING",
                                                                  f"{BLK}MACHINE_DIM_BRIDGE", f"{BLK}OVERLAY_DTPF_ON")
    T["quantum-force-transformer-coil-casing"] = lambda: c.gt(f"{BLK}MACHINE_CASING_QFT_COIL")
    T["quantum-force-transformer-controller"] = lambda: c.face(f"{GTPP_TE}machine_top",
                                                               f"{GTPP}controllerFaces/quantumForceTransformer")
    T["quantum-force-transformer"] = lambda: c.mini(f"{GTPP_TE}machine_top", f"{BLK}MACHINE_CASING_QFT_COIL",
                                                    f"{GTPP}controllerFaces/quantumForceTransformer")

    # phase 6b: the forge of the gods (its blocks, the controller face gen_sprites.py uses)
    T["stellar-energy-siphon-casing"] = lambda: c.gt(f"{BLK}GODFORGE_ENERGY")
    T["singularity-reinforced-stellar-shielding-casing"] = lambda: c.gt(f"{BLK}GODFORGE_SUPPORT")
    T["remote-graviton-flow-modulator"] = lambda: c.gt(f"{BLK}GRAVITON_CASING_0")
    T["godforge-controller"] = lambda: c.face(f"{BLK}GODFORGE_SUPPORT", f"{BLK}GODFORGE_CONTROLLER")
    T["godforge"] = lambda: c.mini(f"{BLK}GODFORGE_SUPPORT", f"{BLK}GODFORGE_ENERGY", f"{BLK}GODFORGE_CONTROLLER")

    # stargate (NewHorizonsCoreMod)
    T["stargate-chevron"] = lambda: c.gt(f"{CORE}itemStargateChevron")
    T["stargate-frame-part"] = lambda: c.gt(f"{CORE}itemStargateFramePart")
    T["stargate-radiation-containment-plate"] = lambda: c.gt(f"{CORE}itemStargateShieldingFoil")
    # GT has no iris blade: GT's turbine blade shape in the neutronium of the stargate frame
    T["stargate-iris-blade"] = lambda: c.part("neutronium", "turbineBlade")

    # issue #91: the component assembly line (GoodGenerator: its UV casing, GT's controller face) and the dusts of
    # the glue line, which the fork names without "-dust"
    T["component-assembly-line"] = lambda: c.mini(f"{GG}blocks/compAsslineCasing/7", f"{BLK}MACHINE_CASING_ASSEMBLER",
                                                  f"{BLK}OVERLAY_FRONT_COMPONENT_ASSEMBLY_LINE")
    # issue #99: the gasoline cell of #94 (GT: Materials.Gasoline's cell, the FLUID icon set in its orange)
    T["gasoline-cell"] = lambda: c.part("gasoline", "cell")
    T["sodium-cyanide"] = lambda: c.part("sodium-cyanide", "dust")
    T["cyanoacetic-acid"] = lambda: c.part("cyanoacetic-acid", "dust")
    for m in ("naquadria-oxide-mixture", "indium-phosphate", "low-quality-naquadria-phosphate"):   # issue #205
        T[m] = (lambda m=m: lambda: c.part(m, "dust"))()
    # issue #207: the tiny pile of the platinum metallic powder (crushed platinum in the furnace)
    T["tiny-pile-of-metallic-platinum-powder"] = lambda: c.part("metallic-platinum-powder", "dustTiny")
    # issue #98: the high octane cell (like the gasoline cell), sodium bisulfate (GT: a dust)
    T["high-octane-gasoline-cell"] = lambda: c.part("high-octane-gasoline", "cell")
    T["rocket-fuel-cell"] = lambda: c.part("rocket-fuel", "cell")   # issue #295
    for m in ("rp-1-rocket-fuel", "dense-hydrazine-fuel-mixture", "cn3h7o3-rocket-fuel"):   # issue #362
        T[m + "-cell"] = (lambda m=m: lambda: c.part(m, "cell"))()
    T["bio-diesel-cell"] = lambda: c.part("bio-diesel", "cell")   # issue #360
    T["glycerol-cell"] = lambda: c.part("glycerol", "cell")   # issue #360
    for m in ("polystyrene", "styrene-butadiene-rubber", "polycaprolactam"):   # issue #358: the sheets are GT's plates
        T[m + "-sheet"] = (lambda m=m: lambda: c.part(m, "plate"))()
    T["raw-styrene-butadiene-rubber-dust"] = lambda: c.part("raw-styrene-butadiene-rubber", "dust")
    for m in ("natural-gas", "lpg", "ether", "naquadah-gas", "ethanol-gasoline", "cyclopentadiene", "jet-fuel-no-3",
              "jet-fuel-a"):   # issues #361, #357
        T[m + "-cell"] = (lambda m=m: lambda: c.part(m, "cell"))()
    T["ferrocene-dust"] = lambda: c.part("ferrocene", "dust")   # issue #357
    # issue #359: GT's dual and quad fuel rods and the MOX rods (gregtech/textures/items/gt.rod*.png), full and depleted
    for fuel, gt in (("uranium", "Uranium"), ("thorium", "Thorium"), ("mox", "MOX"), ("naquadah", "Naquadah")):   # + #386
        for size, suffix in (("", ""), ("dual-", "2"), ("quad-", "4")):
            if fuel in ("uranium", "thorium") and size == "":
                continue   # (the single uranium and thorium rods keep upstream's icons)
            T[f"{size}{fuel}-fuel-rod"] = (lambda g=gt, s=suffix: lambda: c.gt(f"gt:gregtech/textures/items/gt.rod{g}{s}"))()
            T[f"depleted-{size}{fuel}-fuel-rod"] = (
                lambda g=gt, s=suffix: lambda: c.gt(f"gt:gregtech/textures/items/gt.depletedRod{g}{s}"))()
    T["zirconium-pellet"] = lambda: c.part("zirconium-chloride-pellet", "nugget")   # issue #386
    # issue #386: the Reactor Fuel Processing Plant's parts (GT++'s casing blocks, GT's data orb, tank casing and pipes)
    T["data-orb"] = lambda: c.gt(M1 + "707")
    T["gregtech-computer-cube"] = lambda: c.gt("gt:miscutils/textures/items/MU-metaitem.01/55")
    T["hastelloy-n-sealant-block"] = lambda: c.gt(f"{GTPP_TE}MACHINE_CASING_STABLE_HASTELLOY_N")
    T["hastelloy-x-structural-block"] = lambda: c.gt(f"{GTPP_TE}MACHINE_CASING_STABLE_HASTELLOY_X")
    T["incoloy-ds-fluid-containment-block"] = lambda: c.gt(f"{GTPP_TE}MACHINE_CASING_FLUID_INCOLOY_DS")
    T["reactor-shield-casing"] = lambda: c.gt(f"{GTPP_TE}MACHINE_CASING_STABLE_ZERON100")
    T["hermetic-casing-v"] = lambda: c.gt(f"{BLK}MACHINE_CASING_TANK_5")
    T["super-tank-iv"] = lambda: c.face(f"{BLK}MACHINE_CASING_TANK_5", f"{BLK}OVERLAY_STANK")
    T["huge-staballoy-fluid-pipe"] = lambda: c.m.icon("staballoy", "pipeHuge", kind="blocks")
    T["large-titanium-fluid-pipe"] = lambda: c.m.icon("titanium", "pipeLarge", kind="blocks")
    # issue #386 (3): the LFTR's parts (IC2's reactor platings, GT++'s casings and control circuit)
    T["reactor-plating"] = lambda: c.part("lead", "plateDense")   # (IC2's textures are not in the checkouts)
    T["heat-capacity-reactor-plating"] = lambda: c.part("copper", "plateDense")
    T["hastelloy-n-reactor-casing"] = lambda: c.gt(f"{GTPP_TE}MACHINE_CASING_STABLE_HASTELLOY_N")
    T["lftr-control-circuit"] = lambda: c.gt("gt:miscutils/textures/items/itemCircuitLFTR")
    T["integral-encasement-iv"] = lambda: c.gt(f"{BLK}INTEGRAL_FRAMEWORK_HV")
    T["sparge-tower-exterior-casing"] = lambda: c.gt(f"{BLK}SPARGE_TOWER_EXTERIOR_CASING")
    T["empty-large-tungstensteel-fluid-cell"] = lambda: c.gt(M1 + "406")   # issue #386: ItemList.Large_Fluid_Cell_TungstenSteel
    # issue #357, part 2: goodgenerator's thorium fuel line (its items as the plutonium line's above)
    T["uranium-carbide-thorium-mixture"] = lambda: c.part("uranium-carbide-thorium-mixture", "dust")
    T["wrapped-thorium-ingot"] = lambda: c.gt(f"{GG}items/wrappedThoriumIngot")
    T["high-density-thorium-nugget"] = lambda: c.gt(f"{GG}items/highDensityThoriumNugget")
    T["high-density-thorium"] = lambda: c.gt(f"{GG}items/highDensityThorium")
    T["phthalic-anhydride"] = lambda: c.part("phthalic-anhydride", "dust")
    T["sodium-bisulfate"] = lambda: c.part("sodium-bisulfate", "dust")
    # issue #302: the drill heads of the Space Elevator's mining drones (GT's toolHeadDrill of the material)
    for m in ("steel", "titanium", "tungstensteel", "iridium", "trinium", "naquadah", "naquadah-alloy", "naquadria",
              "neutronium", "cosmic-neutronium", "infinity", "transcendent-metal", "spacetime", "eternity"):
        T[m + "-drill-head"] = (lambda m=m: lambda: c.part(m, "toolHeadDrill"))()
    # issue #96: the dusts of the platinum line, which the fork names without "-dust"
    for m in ("platinum-salt", "refined-platinum-salt", "reprecipitated-platinum", "platinum-residue", "palladium-salt",
              "reprecipitated-palladium", "potassium-disulfate", "rhodium-filter-cake", "reprecipitated-rhodium",
              "iridium-dioxide", "sludge-dust-residue", "iridium-chloride", "metallic-sludge-dust-residue"):
        T[m] = lambda m=m: c.part(m, "dust")

    # issue #262: the dusts of the monazite line, which the fork names without "-dust"
    for m in ("monazite-sulfate", "acidic-monazite-powder", "monazite-rare-earth-filtrate", "thorium-phosphate-cake", "thorium-phosphate-concentrate", "neutralized-monazite-rare-earth-filtrate", "monazite-rare-earth-hydroxide-concentrate", "uranium-filtrate", "neutralized-uranium-filtrate", "dried-monazite-rare-earth-concentrate", "cerium-dioxide", "cooled-monazite-rare-earth-concentrate", "monazite-rarer-earth-sediment", "heterogenous-halogenic-monazite-rare-earth-mixture", "saturated-monazite-rare-earth", "samaric-residue"):
        T[m] = lambda m=m: c.part(m, "dust")

    # issue #274: lanthanum hexaboride's gem, which the fork names without "-gem" (its dust is "-dust")
    T["lanthanum-hexaboride"] = lambda: c.part("lanthanum-hexaboride", "gem")

    # issue #272: the dusts of section 6 of 159, which the fork names without "-dust"
    for m in ("europium-iii-oxide", "europium-oxide", "hafnia-zirconia-blend", "zirconia", "zirconium-tetrachloride", "lanthanum-oxide", "boron-trioxide", "samaric-rare-earth-concentrate", "fluorinated-samaric-concentrate", "samarium-terbium-mixture", "nitrogenated-samarium-terbium-mixture", "terbium-nitrate"):
        T[m] = lambda m=m: c.part(m, "dust")

    # issue #269: the dusts of the bastnasite and cerium lines, which the fork names without "-dust"
    for m in ("bastnasite-rare-earth-oxides", "acid-leached-bastnasite-rare-earth-oxides", "roasted-rare-earth-oxides", "wet-rare-earth-oxides", "cerium-oxidised-rare-earth-oxides", "bastnasite-rarer-earth-oxides", "neodymium-rare-earth-concentrate", "lanthanum-chloride", "neodymium-oxide", "cerium-chloride", "cerium-oxalate", "cerium-iii-oxide", "vanadium-pentoxide"):
        T[m] = lambda m=m: c.part(m, "dust")

    # issue #337: the miners' mining pipe (IC2's item, whose texture is not in GT): GT's mining pipe slot overlay in
    # steel's colour
    T["mining-pipe"] = lambda: c.readable(tint(c.gt("gt:gregtech/textures/gui/overlay_slot/mining_pipe").convert("RGBA"),
                                               c.m.colour("steel")))

    # multi-amp wires (upstream: 16x = a block of the metal)
    T["luv-superconductor-wire-16x"] = lambda: bar(c.m.colour("itbtc-alloy"), 2, n=4)
    return T


def material_items(names):
    """fork item names that are material parts (for every PARTS pattern and material)"""
    out = {}
    for n in names:
        for pat, prefix in PARTS:
            rx = "^" + re.escape(pat).replace(re.escape("{m}"), "(?P<m>[a-z0-9-]+?)") + "$"
            m = re.match(rx, n)
            if m and m.group("m") in MATERIALS:
                out[n] = (m.group("m"), prefix)
                break
    return out


# issue #99: GT's own molten colour (MaterialBuilder.setMoltenARGB, MaterialsInit.java) and the GT++ alloys GT keeps
# in gtPlusPlus/core/material/MaterialsAlloy.java ("Material Colour"), which the CamelCase lookup does not find
MOLTEN = {
    "enriched-naquadah": ((0x40, 0xFF, 0x40), "GT NaquadahEnriched setMoltenARGB"),
    "eglin-steel": ((139, 69, 19), "GT++ EGLIN_STEEL"),
    "tumbaga": ((255, 178, 15), "GT++ TUMBAGA"),
    "potin": ((201, 151, 129), "GT++ POTIN"),
    "zirconium-carbide": ((222, 202, 180), "GT++ ZIRCONIUM_CARBIDE"),
}
# issue #99: GT draws a melt glowing; a melt whose colour has no channel above this is lifted (hue and saturation
# kept, brightness v -> 0.45 + 0.55 v), else near-black materials (the ZPM superconductor base, bedrockium) give
# black melts that cannot be told apart in the Fluids tab and in pipes
MOLTEN_MIN = 153


def glowing(rgb):
    v = max(rgb) / 255
    if max(rgb) >= MOLTEN_MIN:
        return rgb
    target = 0.45 + 0.55 * v
    if v == 0:
        return (round(target * 255),) * 3
    return tuple(min(255, round(c * target / v)) for c in rgb)


def molten_colour(tex, mats, mat):
    """GT's colour of a material (MOLTEN, MATERIALS, else GT's material of the same name in CamelCase); materials GT
    does not have take the average colour of the fork's own ingot icon; dark colours are lifted (glowing)"""
    rgb, src = molten_source(tex, mats, mat)
    lit = glowing(rgb)
    return lit, src + ("" if lit == rgb else " (lifted from %d %d %d)" % rgb)


def molten_source(tex, mats, mat):
    if mat in MOLTEN:
        return MOLTEN[mat]
    gt_name = "".join(w.capitalize() for w in mat.split("-"))
    try:
        if mat in MATERIALS:
            return mats.colour(mat), "GT " + str(MATERIALS[mat] if isinstance(MATERIALS[mat], str) else mat)
        if gt_name in mats.gt:
            iset, rgb = mats.gt[gt_name]
            if rgb != (255, 255, 255):
                return rgb, "GT " + gt_name
    except KeyError:
        pass
    px = [p for p in Image.open(ICONS / f"{mat}-ingot.png").convert("RGBA").getdata() if p[3] > 128]
    return tuple(sum(p[i] for p in px) // len(px) for i in range(3)), "ingot icon"


def molten_icons(tex, mats, names):
    """Issue #91: the molten fluids of the materials that had none, drawn like GT's: its molten fluid texture (first
    frame) in the material colour. Prints name, colour and its source (for the fluid's base colour in the prototype)."""
    base = fit(tex.load("gt:gregtech/textures/blocks/fluids/fluid.molten.autogenerated"))
    for mat in names:
        rgb, src = molten_colour(tex, mats, mat)
        img = tint(base, rgb)
        target = ROOT / "graphics/fluids" / f"molten-{mat}.png"
        if not (target.exists() and Image.open(target).convert("RGBA").tobytes() == img.tobytes()):
            img.save(target, optimize=True)
        print(f"{mat}	{rgb[0]} {rgb[1]} {rgb[2]}	{src}")


def fluid_icons(tex, names):
    """Issue #119: the icon of a fluid that has a texture of its own in GT (name=texture, e.g.
    steam=fluid.steam): that texture's first frame, GT's colours as they are, scaled to the icon size."""
    for spec in names:
        name, texture = spec.split("=", 1)
        img = fit(tex.load("gt:gregtech/textures/blocks/fluids/" + texture))
        target = ROOT / "graphics/fluids" / f"{name}.png"
        if not (target.exists() and Image.open(target).convert("RGBA").tobytes() == img.tobytes()):
            img.save(target, optimize=True)
        print(f"{name}	gt:{texture}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gt", type=Path, required=True, help="GT5-Unofficial checkout")
    ap.add_argument("--core", type=Path, help="NewHorizonsCoreMod checkout (stargate parts, tier circuits)")
    ap.add_argument("--only", nargs="*", help="only these items")
    ap.add_argument("--list", type=Path, default=LIST, help="items whose icon this tool makes (default: %(default)s)")
    ap.add_argument("--sources", type=Path, help="write a TSV: item, GT textures it is made of (for the review)")
    ap.add_argument("--molten", nargs="*", help="issue #91: write graphics/fluids/molten-<material>.png for these materials"
                    " (GT's molten fluid texture in the material colour) and print the colours")
    ap.add_argument("--fluid", nargs="*", metavar="NAME=TEXTURE", help="issue #119: write graphics/fluids/<name>.png from"
                    " GT's fluid texture <texture> (first frame, as GT draws it)")
    a = ap.parse_args()
    tex = Tex(a.gt, a.core)
    mats = Materials(tex)
    if a.fluid:
        return fluid_icons(tex, a.fluid)
    if a.molten:
        return molten_icons(tex, mats, a.molten)
    c = Composer(tex, mats)
    table = icon_table(c)
    names = [l.split("#")[0].strip() for l in a.list.read_text().splitlines()]
    names = [n for n in names if n]
    for n, (mat, prefix) in material_items(names).items():
        table.setdefault(n, lambda mat=mat, prefix=prefix: c.part(mat, prefix))
    todo = a.only or names
    done, failed, sources = 0, [], []
    for n in todo:
        if n not in table:
            failed.append((n, "no entry"))
            continue
        tex.trace = []
        try:
            img = table[n]()
            sources.append((n, " + ".join(dict.fromkeys(tex.trace))))
        except (FileNotFoundError, KeyError) as e:
            failed.append((n, str(e)))
            continue
        assert img.size == (SIZE, SIZE), n
        target = ICONS / f"{n}.png"
        if not (target.exists() and Image.open(target).convert("RGBA").tobytes() == img.tobytes()):
            img.save(target, optimize=True)                 # unchanged pixels: file left alone
        done += 1
    if a.sources:
        a.sources.write_text("".join(f"{n}\t{s}\n" for n, s in sources), encoding="utf-8")
    print(f"{done} icons written")
    for n, why in failed:
        print(f"  skipped {n}: {why}")
    print("sources used:", ", ".join(sorted(tex.used)))


if __name__ == "__main__":
    main()
