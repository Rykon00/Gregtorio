#!/usr/bin/env python3
"""Generates entity sprites and icons for the fork machines (prototypes/101-fork-machines.lua).

Sources:
  * GregTech 5 textures from a checkout of GTNewHorizons/GT5-Unofficial (LGPL-3.0)
  * existing Gregtorio icons (casings, controllers)

    python tools/gen_sprites.py --gt C:/00_Repositories/GT5-Unofficial

Output:
  graphics/entity/fork/<name>-idle.png / -working.png   (working = vertical frame strip)
  graphics/icons/fork/<name>.png                         (32x32)
A file whose pixels did not change is not rewritten.

The basic machines from IV up are upstream's LV to EV assets with the casing in the tier's colour (issue #148, route b of
docs/graphics-review/machine-tiers-block-routes.png): the sprite, its working strip and the icon of the LV machine (MV's where
upstream has no LV one), with the casing pixels (the pixels that differ between the LV and the MV asset, frame by frame) as a
ramp of their brightness through the tier colour; from UHV up the brightness of the GT hull texture of the tier runs through
it (HULL_TIERS). The silhouette, the contours, the bevelled frame, the window and the depth are upstream's, so a row LV to MAX
is one family; the strips have the frame count of the EV machine, whose graphics set the IV one copies (101).

Tier look (issue #41): the large plasma turbines and naquadah reactors show the GT
dynamo hatches of their tier in the corners (TIER_COPIES) instead of a tinted copy. The IV to MAX upgrade
multiblocks keep the EV sprite and get a layer with GT energy hatches of their tier (UPGRADE_MULTIBLOCKS).
"""
import argparse, re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "graphics/icons"
OUT_ENTITY = ROOT / "graphics/entity/fork"
OUT_ICON = ROOT / "graphics/icons/fork"

TILE = 32          # Factorio pixels per tile in Gregtorio

# the basic machines from IV up (101's IV_BASIC_MACHINES), drawn from upstream's LV to EV assets
BASIC_MACHINES = [
    "wiremill", "bending-machine", "extruder", "rock-crusher", "lathe", "macerator", "centrifuge",
    "extractor", "electrolyzer", "assembling-machine", "cutting-machine", "canning-machine", "mixer", "ore-washer",
    "laser-engraver", "fluid-solidifier", "chemical-bath", "polarizer", "circuit-assembler", "autoclave",
    "alloy-smelter", "compressor", "forge-hammer", "arc-furnace", "forming-press",
    "electric-furnace", "sifting-machine", "thermal-centrifuge", "electromagnetic-separator",
    "brewery", "fermenter",  # issue #360
]
# issue #152: the Fluid Extractors are copies of the Extractor (151); from IV up they are drawn like the other basic
# machines from their LV and MV sprites (fluid_extractor_lv_ev), with the Extractor's frame count
FLUID_EXTRACTOR = "fluid-extractor"
EV_FRAMES_OF = {FLUID_EXTRACTOR: "extractor"}
# issue #170: the electric Forge Hammers LV to EV are made in a loop of 101 (no make_electric_machine("ev-forge-hammer"
# to read) and play the 5 frames of the Steam Forge Hammer's strip; their LV and MV sprites come from it
# (forge_hammer_lv_mv)
EV_FRAMES = {"forge-hammer": 5, "arc-furnace": 1, "forming-press": 1, "electric-furnace": 1,
             "sifting-machine": 4, "thermal-centrifuge": 1, "electromagnetic-separator": 4,
             "brewery": 1, "fermenter": 1}
# issue #171: the Arc Furnace has no upstream picture either: its LV and MV ones are the compressor's frame with GT's arc
# furnace overlay in the window (arc_furnace_lv_mv), one frame
ARC_OVERLAY = "gregtech:basicmachines/arc_furnace/OVERLAY_FRONT"
ARC_WINDOW = (16, 21, 70, 54)   # the window of the LV and MV compressor (x0, y0, x1, y1)
# issue #173: the Forming Press likewise: the wiremill's frame (its wide upper window) with GT's press front, cut to
# its content
PRESS_OVERLAY = "gregtech:basicmachines/press/OVERLAY_FRONT"
PRESS_WINDOW = (11, 11, 75, 38)  # the upper window of the LV and MV wiremill
# issue #174: the Electric Furnace: the assembling machine's frame (its plain window) with GT's electric furnace front
FURNACE_OVERLAY = "gregtech:basicmachines/electric_furnace/OVERLAY_FRONT"
FURNACE_WINDOW = (17, 21, 71, 54)  # the window of the LV and MV assembling machine
# issue #175: the Sifting Machine: the lathe's frame with GT's sifter front, its 4 active frames as the working strip
SIFTER_OVERLAY = "gregtech:basicmachines/sifter/OVERLAY_FRONT"
SIFTER_WINDOW = (17, 17, 71, 55)  # the window of the LV and MV lathe
# issue #185: the Thermal Centrifuge: the fluid solidifier's frame with GT's thermal centrifuge front
THERMAL_OVERLAY = "gregtech:basicmachines/thermal_centrifuge/OVERLAY_FRONT"
THERMAL_WINDOW = (16, 22, 71, 66)  # the window of the LV and MV fluid solidifier
# issue #187: the Electromagnetic Separator: the polarizer's frame (its magnet poles) with GT's separator front between them
EMS_OVERLAY = "gregtech:basicmachines/electromagnetic_separator/OVERLAY_FRONT"
EMS_WINDOW = (21, 16, 64, 44)  # the upper window of the LV and MV polarizer, between its poles
# issue #360: the Brewery (the assembling machine's frame with GT's potion brewer front) and the Fermenter (the fluid
# solidifier's frame with GT's fermenter front, which glows while it works)
BREWERY_OVERLAY = "gregtech:basicmachines/potionbrewer/OVERLAY_FRONT_POTIONBREWER"
FERMENTER_OVERLAY = "gregtech:basicmachines/fermenter/OVERLAY_FRONT"
# issue #152: the fluid extractor's icons carry a molten fluid in the bottom right corner, so they differ from the
# extractor's in the inventory; its LV to EV sprites are the extractor's with the liquid in the tubes molten
FLUID_BADGE_MACHINES = {"fluid-extractor"}

# tier color GT uses to tint the (gray) machine casings (EV = titanium, IV = tungstensteel)
TIER_TINT = {"EV": (220, 160, 240), "IV": (100, 100, 160), "LuV": (255, 205, 225), "ZPM": (140, 225, 245), "UV": (130, 215, 140),
             "UHV": (235, 120, 120), "UEV": (240, 200, 90), "UIV": (120, 150, 255),
             "UMV": (190, 120, 235), "UXV": (245, 245, 250), "MAX": (255, 255, 255)}

# casing item -> flat GT texture ("mod:path" under textures/blocks). Without an entry the item icon is used.
CASING_TEXTURE = {
    "high-temperature-smelting-casing": "miscutils:TileEntities/MACHINE_CASING_STABLE_ZIRCONIUM_CARBIDE",
    "nichrome-coil-block": "gregtech:iconsets/MACHINE_COIL_NICHROME",
    "solid-steel-machine-casing": "gregtech:iconsets/MACHINE_CASING_SOLID_STEEL",
    "stable-titanium-machine-casing": "gregtech:iconsets/MACHINE_CASING_STABLE_TITANIUM",
    "robust-tungstensteel-machine-casing": "gregtech:iconsets/MACHINE_CASING_ROBUST_TUNGSTENSTEEL",
    "wire-factory-casing": "gregtech:iconsets/MACHINE_CASING_CABLE",
    "material-press-machine-casing": "miscutils:TileEntities/MACHINE_CASING_STABLE_TUMBAGA",
    "electric-compressor-casing": "gregtech:iconsets/MACHINE_CASING_HIGH_PRESSURE_RESISTANT",
    "magtech-casing": "gregtech:iconsets/MACHINE_CASING_EMS",
    "solidifier-casing": "gregtech:iconsets/MACHINE_CASING_CHEMICALLY_INERT",
    "cutting-factory-frame": "miscutils:TileEntities/MACHINE_CASING_STABLE_TALONITE",
    "bath-plant-casing": "gregtech:iconsets/MACHINE_CASING_CLEAN_STAINLESSSTEEL",
    "electrolyzer-casing": "miscutils:TileEntities/MACHINE_CASING_STABLE_POTIN",
    "laser-containment-casing": "gregtech:iconsets/MACHINE_CASING_LASER",
    "inconel-reinforced-casing": "miscutils:TileEntities/MACHINE_CASING_STABLE_HASTELLOY_X",
    "multi-use-casing": "miscutils:TileEntities/MACHINE_CASING_STABLE_STELLITE",
    "assembler-machine-casing": "gregtech:iconsets/MACHINE_CASING_ASSEMBLER",
    "grate-machine-casing": "gregtech:iconsets/MACHINE_CASING_GRATE",
    "clean-stainless-steel-casing": "gregtech:iconsets/MACHINE_CASING_CLEAN_STAINLESSSTEEL",
    "titanium-reinforced-borosilicate-glass-block": "bartworks:TitaniumReinforcedBoronSilicateGlassBlock",
}
# per-multiblock casing override (e.g. the centrifuge)
CASING_OVERRIDE = {
    "iv-industrial-centrifuge": "miscutils:TileEntities/MACHINE_CASING_CENTRIFUGE",
}

# multiblock -> (size in tiles, casing item, controller icon, GT controller face (optional), middle row item)
MULTIBLOCKS = {
    "ev-alloy-blast-smelter": ((3, 4), "high-temperature-smelting-casing", None,
                               "miscutils:iconsets/controllerFaces/alloyBlastSmelter", "nichrome-coil-block"),
    "luv-assembly-line": ((9, 3), "assembler-machine-casing", None,
                          "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE", "grate-machine-casing"),
    "ev-extreme-entity-crusher": ((3, 3), "solid-steel-machine-casing", "extreme-entity-crusher",
                                  "gregtech:iconsets/OVERLAY_FRONT_DISASSEMBLER", None),
    # LuV endgame (125-fork-luv-endgame.lua); a casing with ":" is a GT texture, a face tuple is (idle, working)
    "neutron-activator": ((3, 3), "gregtech:iconsets/MACHINE_CASING_RADIATIONPROOF", None,
                          ("gregtech:icons/NeutronActivator_Off", "gregtech:icons/NeutronActivator_On"), None),
    "bacterial-vat": ((5, 5), "clean-stainless-steel-casing", None,
                      "gregtech:iconsets/OVERLAY_FRONT_BIOLOGICAL_COORDINATION",
                      "titanium-reinforced-borosilicate-glass-block"),
    "luv-circuit-assembly-line": ((9, 3), "assembler-machine-casing", None,
                                  "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_MATRIX", "reinforced-glass"),
    "fusion-reactor-mk1": ((9, 9), "gregtech:iconsets/MACHINE_CASING_FUSION", None,
                           "gregtech:iconsets/OVERLAY_FUSION1", "gregtech:iconsets/MACHINE_CASING_FUSION_COIL"),
    # UV (127-fork-uv.lua)
    "zpm-assembly-line": ((9, 3), "assembler-machine-casing", None,
                          "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE", "grate-machine-casing"),
    # issue #99: the component assembly line (142-fork-recipe-unlocks.lua; GoodGenerator's MTEComponentAssemblyLine):
    # GT's iridium casing (its casing index 183), GoodGenerator's UV component assembly line casing as the middle
    # row, the CoAL controller face (idle, active)
    "component-assembly-line": ((9, 3), "gregtech:iconsets/MACHINE_CASING_IRIDIUM", None,
                                ("gregtech:iconsets/OVERLAY_FRONT_COMPONENT_ASSEMBLY_LINE",
                                 "gregtech:iconsets/OVERLAY_FRONT_COMPONENT_ASSEMBLY_LINE_ACTIVE"),
                                "goodgenerator:compAsslineCasing/7"),
    "fusion-reactor-mk2": ((9, 9), "gregtech:iconsets/MACHINE_CASING_FUSION_2", None,
                           "gregtech:iconsets/OVERLAY_FUSION2", "gregtech:iconsets/MACHINE_CASING_FUSION_COIL"),
    # UHV (128-fork-uhv.lua)
    "fusion-reactor-mk3": ((9, 9), "gregtech:iconsets/MACHINE_CASING_FUSION_2", None,
                           "gregtech:iconsets/OVERLAY_FUSION3", "gregtech:iconsets/MACHINE_CASING_FUSION_COIL"),
    # UEV (131-fork-uev.lua) and UMV (133-fork-umv.lua): GT has no MK4/MK5 reactor of its own; the art of
    # GoodGenerator's compact fusion computers MK-IV and MK-V: GT++ fusion machine casing MK-III / MK-IV,
    # compact fusion coil Mk-II prototype / finaltype, the GT++ screen (idle, working)
    "fusion-reactor-mk4": ((9, 9), "miscutils:iconsets/MACHINE_CASING_FUSION_3", None,
                           ("miscutils:TileEntities/adv_machine_screen_random1",
                            "miscutils:TileEntities/adv_machine_screen_random3"), "goodgenerator:fuison/4"),
    "fusion-reactor-mk5": ((9, 9), "miscutils:iconsets/MACHINE_CASING_FUSION_4", None,
                           ("miscutils:TileEntities/adv_machine_screen_random1",
                            "miscutils:TileEntities/overlay_rainbowscreen"), "goodgenerator:fuison/5"),
    # water purification (129-fork-water-purification.lua)
    "water-purification-plant": ((5, 5), "gregtech:iconsets/MACHINE_CASING_INDUSTRIAL_WATER_PLANT", None,
                                 "gregtech:iconsets/OVERLAY_FRONT_PURIFICATION_PLANT",
                                 "titanium-reinforced-borosilicate-glass-block"),
    # phase 6a (139-fork-endgame-multiblocks.lua; item icons from tools/gen_gt_icons.py): GT's dimensionally
    # transcendent plasma forge (dimensionally transcendent casing, dimensional bridge, the DTPF screen) and the
    # quantum force transformer (GT++ bulk production frame, QFT coil, the GT++ controller face)
    "dimensionally-transcendent-plasma-forge": ((11, 11), "gregtech:iconsets/MACHINE_DIM_TRANS_CASING", None,
                                                ("gregtech:iconsets/OVERLAY_DTPF_OFF",
                                                 "gregtech:iconsets/OVERLAY_DTPF_ON"),
                                                "gregtech:iconsets/MACHINE_DIM_BRIDGE"),
    "quantum-force-transformer": ((9, 9), "miscutils:TileEntities/machine_top", None,
                                  "miscutils:iconsets/controllerFaces/quantumForceTransformer",
                                  "gregtech:iconsets/MACHINE_CASING_QFT_COIL"),
    # phase 6b (140-fork-godforge.lua): GT's forge of the gods (its support casing, its inner casing
    # as the middle rows, the controller with its glowing eye)
    "godforge": ((13, 13), "gregtech:iconsets/GODFORGE_SUPPORT", None,
                 ("gregtech:iconsets/GODFORGE_CONTROLLER", "gregtech:iconsets/GODFORGE_CONTROLLER_GLOW"),
                 "gregtech:iconsets/GODFORGE_INNER"),
    # endgame power (136-fork-power.lua): the large naquadah reactor (UHV to UXV: TIER_COPIES)
    "uv-large-naquadah-reactor": ((5, 5), "gregtech:iconsets/NAQUADAH_REACTOR_CASING", None,
                                  ("gregtech:iconsets/NAQUADAH_REACTOR_FLUID_FRONT",
                                   "gregtech:iconsets/NAQUADAH_REACTOR_FLUID_FRONT_ACTIVE"),
                                  "gregtech:iconsets/MACHINE_CASING_RADIATIONPROOF"),
    # issue #97 (145-fork-power-multiblocks.lua): GT's large heat exchanger (stable titanium casing, titanium pipe
    # casings in the middle row, its controller face) and the fluid nuclear reactor (GT's radiation proof casing
    # around the upstream reactor icon; IC2's reactor has no texture in GT)
    "large-heat-exchanger": ((3, 3), "stable-titanium-machine-casing", None,
                             "gregtech:iconsets/OVERLAY_FRONT_HEAT_EXCHANGER",
                             "gregtech:iconsets/MACHINE_CASING_PIPE_TITANIUM"),
    "fluid-nuclear-reactor": ((3, 3), "gregtech:iconsets/MACHINE_CASING_RADIATIONPROOF", "fluid-nuclear-reactor",
                              None, None),
    # issues #254 and #255 (145-fork-power-multiblocks.lua): GT's large titanium boiler (stable titanium casing, the
    # titanium firebox as the middle row, the large boiler front) and large combustion engine (stable titanium casing,
    # titanium gearboxes in the middle row, the diesel engine front)
    "large-titanium-boiler": ((3, 3), "gregtech:iconsets/MACHINE_CASING_STABLE_TITANIUM", None,
                              ("gregtech:iconsets/OVERLAY_FRONT_LARGE_BOILER",
                               "gregtech:iconsets/OVERLAY_FRONT_LARGE_BOILER_ACTIVE"),
                              "gregtech:iconsets/MACHINE_CASING_FIREBOX_TITANIUM"),
    # issue #262 (159-fork-lanthanides.lua): gtnhlanth's digester (robust tungstensteel casing, heat proof casings in
    # the middle row) and dissolution tank (clean stainless steel casing, glass in the middle row), both with the oil
    # cracker front gtnhlanth gives them
    "digester": ((3, 3), "gregtech:iconsets/MACHINE_CASING_ROBUST_TUNGSTENSTEEL", None,
                 ("gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER", "gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER_ACTIVE"),
                 "gregtech:iconsets/MACHINE_HEATPROOFCASING"),
    "dissolution-tank": ((3, 3), "gregtech:iconsets/MACHINE_CASING_CLEAN_STAINLESSSTEEL", None,
                         ("gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER",
                          "gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER_ACTIVE"),
                         "reinforced-glass"),
    # issue #272 (159-fork-lanthanides.lua): GT++'s ExxonMobil Chemical Plant (solid steel casings, the casing tier its
    # recipe needs, steel pipe casings in the middle row) and the MV and HV Dehydrators (the GT hull of the tier with
    # the dehydrator front)
    "exxonmobil-chemical-plant": ((3, 3), "solid-steel-machine-casing", None,
                                  ("miscutils:iconsets/controllerFaces/chemicalPlant",
                                   "miscutils:iconsets/controllerFaces/chemicalPlantActive"),
                                  "gregtech:iconsets/MACHINE_CASING_PIPE_STEEL"),
    "mv-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_MV_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    "hv-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_HV_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    # issue #286 (160-fork-dimension-mines.lua): bartworks' Void Miners I to III, their mining casings and the ore drill
    # front
    "void-miner-i": ((3, 3), "gregtech:iconsets/MACHINE_CASING_MINING_OSMIRIDIUM", None,
                      ("gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL", "gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL_ACTIVE"),
                      None),
    "void-miner-ii": ((3, 3), "gregtech:iconsets/MACHINE_CASING_MINING_BLACKPLUTONIUM", None,
                      ("gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL", "gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL_ACTIVE"),
                      None),
    "void-miner-iii": ((3, 3), "gregtech:iconsets/MACHINE_CASING_MINING_NEUTRONIUM", None,
                      ("gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL", "gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL_ACTIVE"),
                      None),
    # issue #335 (163-fork-electric-mine.lua): GT's Ore Drilling Plants I to IV on the Manual Mine's 5x5 footprint, the
    # casing of each Mk (MTEOreDrillingPlant1-4 getCasingBlockItem) and the ore drill front
    **{f"ore-drilling-plant-mk{t}": ((5, 5), f"gregtech:iconsets/{casing}", None,
                                     ("gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL",
                                      "gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL_ACTIVE"), None)
       for t, casing in enumerate(("MACHINE_CASING_SOLID_STEEL", "MACHINE_CASING_STABLE_TITANIUM",
                                   "MACHINE_CASING_ROBUST_TUNGSTENSTEEL", "MACHINE_CASING_MINING_OSMIRIDIUM"), 1)},
    # issue #337 (163): GT's Miners LV to HV on the same footprint, the hull of the tier and the miner's front
    **{f"{t}-miner": ((5, 5), f"gregtech:iconsets/MACHINE_{t.upper()}_SIDE", None,
                      ("gregtech:basicmachines/miner/OVERLAY_FRONT", "gregtech:basicmachines/miner/OVERLAY_FRONT_ACTIVE"),
                      None) for t in ("lv", "mv", "hv")},
    # issue #274: the Chemical Dehydrators I to IV, like the MV and HV ones
    "ev-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_EV_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    "iv-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_IV_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    "luv-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_LuV_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    "zpm-dehydrator": ((3, 3), "gregtech:iconsets/MACHINE_ZPM_SIDE", None,
                      ("gregtech:basicmachines/dehydrator/OVERLAY_FRONT",
                       "gregtech:basicmachines/dehydrator/OVERLAY_FRONT_ACTIVE"), None),
    "large-combustion-engine": ((3, 3), "gregtech:iconsets/MACHINE_CASING_STABLE_TITANIUM", None,
                                ("gregtech:iconsets/OVERLAY_FRONT_DIESEL_ENGINE",
                                 "gregtech:iconsets/OVERLAY_FRONT_DIESEL_ENGINE_ACTIVE"),
                                "gregtech:iconsets/MACHINE_CASING_GEARBOX_TITANIUM"),
    # issue #295: GT++'s rocket engines (MTERocketFuelGenerator: the casing of its tier, the diesel motor overlay)
    "ev-rocket-engine": ((3, 3), "miscutils:TileEntities/machine_top", None,
                         ("miscutils:TileEntities/machine_top_dieselmotor2",
                          "miscutils:TileEntities/machine_top_dieselmotor2_active"), None),
    "iv-rocket-engine": ((3, 3), "miscutils:TileEntities/high_adv_machine", None,
                         ("miscutils:TileEntities/machine_top_dieselmotor2",
                          "miscutils:TileEntities/machine_top_dieselmotor2_active"), None),
    "luv-rocket-engine": ((3, 3), "miscutils:TileEntities/adv_machine_lesu", None,
                          ("miscutils:TileEntities/machine_top_dieselmotor2",
                           "miscutils:TileEntities/machine_top_dieselmotor2_active"), None),
    # issue #304: GT++'s Large Rocket Engine (its Turbodyne Casing, the controller face, the Inconel gear boxes in the middle row)
    "large-rocket-engine": ((3, 3), "miscutils:TileEntities/MACHINE_CASING_ROCKETDYNE", None,
                            "miscutils:iconsets/controllerFaces/largeRocketEngine",
                            "miscutils:TileEntities/MACHINE_CASING_STABLE_HASTELLOY_X"),
    # issue #357: goodgenerator's Universal Chemical Fuel Engine (its stable titanium casing, the diesel engine front, the
    # chemically inert casings of its middle row)
    "universal-chemical-fuel-engine": ((3, 3), "gregtech:iconsets/MACHINE_CASING_STABLE_TITANIUM", None,
                                       ("gregtech:iconsets/OVERLAY_FRONT_DIESEL_ENGINE",
                                        "gregtech:iconsets/OVERLAY_FRONT_DIESEL_ENGINE_ACTIVE"),
                                       "gregtech:iconsets/MACHINE_CASING_CHEMICALLY_INERT"),
    # issue #386: GT++'s Reactor Fuel Processing Plant (its Hastelloy-X structural casing, GT's multi smelter front that
    # MTERefinery.java shows, the Incoloy-DS fluid containment blocks of its middle row)
    "reactor-fuel-processing-plant": ((3, 3), "miscutils:TileEntities/MACHINE_CASING_STABLE_HASTELLOY_X", None,
                                      ("gregtech:iconsets/OVERLAY_FRONT_MULTI_SMELTER",
                                       "gregtech:iconsets/OVERLAY_FRONT_MULTI_SMELTER_ACTIVE"),
                                      "miscutils:TileEntities/MACHINE_CASING_FLUID_INCOLOY_DS"),
    # issue #386 (3): GT++'s LFTR (its Hastelloy-N reactor casing, GT's nuclear reactor front, the reactor shield casings
    # of its middle rings), the Sparge Tower (its exterior casing and front) and the Cold Trap I and Reactor Processing
    # Unit I (single blocks: GT's IV hull with their fronts)
    "liquid-fluoride-thorium-reactor": ((3, 3), "miscutils:TileEntities/MACHINE_CASING_STABLE_HASTELLOY_N", None,
                                        ("gregtech:iconsets/OVERLAY_FRONT_NUCLEAR_REACTOR",
                                         "gregtech:iconsets/OVERLAY_FRONT_NUCLEAR_REACTOR_ACTIVE"),
                                        "miscutils:TileEntities/MACHINE_CASING_STABLE_ZERON100"),
    "sparge-tower": ((3, 3), "gregtech:iconsets/SPARGE_TOWER_EXTERIOR_CASING", None,
                     "miscutils:iconsets/controllerFaces/spargeTower", None),
    "cold-trap-i": ((3, 3), "gregtech:iconsets/MACHINE_IV_SIDE", None,
                    ("gregtech:basicmachines/cold_trap/OVERLAY_FRONT", "gregtech:basicmachines/cold_trap/OVERLAY_FRONT_ACTIVE"),
                    None),
    "reactor-processing-unit-i": ((3, 3), "gregtech:iconsets/MACHINE_IV_SIDE", None,
                                  ("gregtech:basicmachines/reactor_processing_unit/OVERLAY_FRONT",
                                   "gregtech:basicmachines/reactor_processing_unit/OVERLAY_FRONT_ACTIVE"), None),
    # issue #356: GT++'s Algae Farm (its algae casing and controller face, MTEAlgaePond.java) and Industrial Dehydrator
    # (Utupu-Tanuri: the vacuum casing and its controller face, MTEIndustrialDehydrator.java)
    "algae-farm": ((3, 3), "gregtech:iconsets/ALGAE_CASING", None,
                   ("miscutils:iconsets/controllerFaces/algaePondBase", "miscutils:iconsets/controllerFaces/algaePondBaseActive"),
                   None),
    "industrial-dehydrator": ((3, 3), "gregtech:iconsets/VACUUM_CASING_SIDE", None,
                              ("miscutils:iconsets/controllerFaces/industrialDehydrator",
                               "miscutils:iconsets/controllerFaces/industrialDehydratorActive"), None),
    # issue #356: the Naquadah Fuel Refinery (goodgenerator's FRF casing, GT's black plutonium mining casing; the assembly
    # line front MTENaquadahFuelRefinery.java shows), both coil tiers
    "naquadah-fuel-refinery": ((3, 3), "gregtech:iconsets/MACHINE_CASING_MINING_BLACKPLUTONIUM", None,
                               ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE",
                                "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"), None),
    **{f"naquadah-fuel-refinery-t{t}": ((3, 3), "gregtech:iconsets/MACHINE_CASING_MINING_BLACKPLUTONIUM", None,
                                        ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE",
                                         "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"), None)
       for t in range(2, 5)},   # (issue #356: T3 and T4 too)
    # issue #355 step 4: the beamline (gtnhlanth's shielded accelerator casing; the fronts MTESourceChamber and
    # MTEBeamCrafter show, the electrode casings and the beam input hatches of the middle row) and GT's mass fabricator
    "source-chamber": ((3, 3), "gtnhlanth:casing.shielded_accelerator", None,
                       ("gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER", "gregtech:iconsets/OVERLAY_FRONT_OIL_CRACKER_ACTIVE"),
                       "gtnhlanth:casing.electrode"),
    "beam-crafter": ((3, 3), "gtnhlanth:casing.shielded_accelerator", None,
                     ("gregtech:iconsets/OVERLAY_FRONT_BEAMCRAFTER", "gregtech:iconsets/OVERLAY_FRONT_BEAMCRAFTER_ACTIVE"),
                     "gtnhlanth:casing.shielded_accelerator_glass"),
    "luv-mass-fabricator": ((3, 3), "gregtech:iconsets/MACHINE_LuV_SIDE", None,
                            ("gregtech:iconsets/OVERLAY_FRONT_MASSFAB", "gregtech:iconsets/OVERLAY_FRONT_MASSFAB_ACTIVE"), None),
    # the Large Hadron Collider per module stage (GT's collider casing and LHC front, the module's casings in the middle row)
    **{n: ((3, 3), "gregtech:iconsets/COLLIDER_CASING", None,
           ("gregtech:iconsets/OVERLAY_FRONT_LHC", "gregtech:iconsets/OVERLAY_FRONT_LHC_COLLIDER"), f"gregtech:iconsets/{m}")
       for n, m in (("large-hadron-collider", "CMS_CASING"), ("large-hadron-collider-weak", "ATLAS_CASING"),
                    ("large-hadron-collider-lhcb", "LHCB_CASING"))},
    # issue #355 step 5: the Nano Forge (GT's Radiant Naquadah Alloy Casing and the assembly line front MTENanoForge.java
    # shows; tier 2 with the assembler casings of its tier 2 piece in the middle row)
    "nano-forge": ((3, 3), "gregtech:iconsets/MACHINE_CASING_RADIANT_NAQUADAH_ALLOY", None,
                   ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE", "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"), None),
    "nano-forge-t2": ((3, 3), "gregtech:iconsets/MACHINE_CASING_RADIANT_NAQUADAH_ALLOY", None,
                      ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE", "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"),
                      "gregtech:iconsets/MACHINE_CASING_ASSEMBLER"),
    # issue #487: tier 3 with the Stellar Alloy frames of its tier 3 piece in the middle row
    "nano-forge-t3": ((3, 3), "gregtech:iconsets/MACHINE_CASING_RADIANT_NAQUADAH_ALLOY", None,
                      ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE", "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"),
                      "gregtech:materialicons/CUSTOM/stellar/frameGt"),
    # issue #489: the Draconic Evolution Fusion Crafter per casing tier (kubatech's Naquadah Alloy Fusion Casing, the
    # teleporter front MTEDEFusionCrafter.java shows, the tier's Fusion Casings in the middle row)
    **{f"draconic-evolution-fusion-crafter-t{k}": ((3, 3), "kubatech:casing/defc_0", None,
                                                    ("gregtech:iconsets/OVERLAY_TELEPORTER",
                                                     "gregtech:iconsets/OVERLAY_TELEPORTER_ACTIVE"), f"kubatech:casing/defc_{k}")
       for k in range(1, 5)},
    # issue #406: GT++'s ZPM tiers of the two blocks (GregtechLFTR.java: the same overlays on the ZPM machine casing)
    "cold-trap-ii": ((3, 3), "gregtech:iconsets/MACHINE_ZPM_SIDE", None,
                     ("gregtech:basicmachines/cold_trap/OVERLAY_FRONT", "gregtech:basicmachines/cold_trap/OVERLAY_FRONT_ACTIVE"),
                     None),
    "reactor-processing-unit-ii": ((3, 3), "gregtech:iconsets/MACHINE_ZPM_SIDE", None,
                                   ("gregtech:basicmachines/reactor_processing_unit/OVERLAY_FRONT",
                                    "gregtech:basicmachines/reactor_processing_unit/OVERLAY_FRONT_ACTIVE"), None),
    # issue #406: GT++'s Nuclear Salt Processing Plant (GT's IV machine casing, the disassembler front MTENuclearSaltProcessing
    # Plant.java shows, its thermally insulated casings of the middle row)
    "nuclear-salt-processing-plant": ((3, 3), "gregtech:iconsets/MACHINE_IV_SIDE", None,
                                      ("gregtech:iconsets/OVERLAY_FRONT_DISASSEMBLER",
                                       "gregtech:iconsets/OVERLAY_FRONT_DISASSEMBLER_ACTIVE"),
                                      "miscutils:TileEntities/machine_top"),
    # issue #355: GoodGenerator's Precise Auto-Assembler MT-3662 per casing tier (the machine casing of its voltage, its
    # quantum chest and tank front, MTEPreciseAssembler.java, the Precise Electronic Unit Casings of the middle row)
    **{f"precise-assembler-mk{i}": ((3, 3), f"gregtech:iconsets/MACHINE_{v}_SIDE", None,
                                    ("gregtech:iconsets/OVERLAY_QCHEST", "gregtech:iconsets/OVERLAY_QTANK"),
                                    f"goodgenerator:preciseUnitCasing/{i}")
       for i, v in ((1, "LuV"), (2, "ZPM"), (3, "UHV"))},
    # issue #301: the Space Elevator per motor tier (gtnhintergalactic's base casing, support structure and the motor)
    **{f"space-elevator-mk{t}": ((11, 11), "gtnhintergalactic:spaceElevator/BaseCasing", None,
                                 f"gtnhintergalactic:spaceElevator/MotorT{t}_Side",
                                 "gtnhintergalactic:spaceElevator/SupportStructure_Side") for t in range(1, 6)},
    # issue #302: the Space Elevator Mining Modules (the elevator's base casing, GT's ore drill front)
    **{f"space-elevator-mining-module-mk{t}": ((3, 3), "gtnhintergalactic:spaceElevator/BaseCasing", None,
                                               ("gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL",
                                                "gregtech:iconsets/OVERLAY_FRONT_ORE_DRILL_ACTIVE"),
                                               f"gtnhintergalactic:spaceElevator/MotorT{t}_Side") for t in range(1, 4)},
    # issue #485: the Space Elevator Assembler Module Mk-I (the elevator's base casing, GT's assembly line front, its
    # motor tier)
    "space-elevator-assembler-module-mk1": ((3, 3), "gtnhintergalactic:spaceElevator/BaseCasing", None,
                                            ("gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE",
                                             "gregtech:iconsets/OVERLAY_FRONT_ASSEMBLY_LINE_ACTIVE"),
                                            "gtnhintergalactic:spaceElevator/MotorT1_Side"),
    # issue #303: the Planetary Gas Siphon (its siphon casing and front) and the Space Elevator Pump Modules (the elevator's
    # base casing, GT's oil drill front, the motor they need: Mk-II to Mk-IV)
    "planetary-gas-siphon": ((3, 3), "gtnhintergalactic:gasSiphon/SiphonCasing", None,
                             ("gregtech:iconsets/OVERLAY_FRONT_PLANETARYSIPHON",
                              "gregtech:iconsets/OVERLAY_FRONT_PLANETARYSIPHON"), None),   # (GT has no active front, only its glow)
    **{f"space-elevator-pump-module-mk{t}": ((3, 3), "gtnhintergalactic:spaceElevator/BaseCasing", None,
                                             ("gregtech:iconsets/OVERLAY_FRONT_OIL_DRILL",
                                              "gregtech:iconsets/OVERLAY_FRONT_OIL_DRILL_ACTIVE"),
                                             f"gtnhintergalactic:spaceElevator/MotorT{t + 1}_Side") for t in range(1, 4)},
}
# multiblocks without an upstream item icon: the icon is the controller tile
CONTROLLER_ICONS = {"neutron-activator", "water-purification-plant", "uv-large-naquadah-reactor"}
# multiblocks whose icon is the whole idle sprite, scaled down (issues #254, #255: their GT controller fronts look alike,
# the middle row tells them apart)
WHOLE_ICONS = {"large-titanium-boiler", "large-combustion-engine", "digester", "dissolution-tank",
               "exxonmobil-chemical-plant", "mv-dehydrator", "hv-dehydrator", "ev-dehydrator", "iv-dehydrator",
               "luv-dehydrator", "zpm-dehydrator", "void-miner-i", "void-miner-ii", "void-miner-iii",
               "ev-rocket-engine", "iv-rocket-engine", "luv-rocket-engine", "large-rocket-engine",
               "universal-chemical-fuel-engine", "reactor-fuel-processing-plant", "liquid-fluoride-thorium-reactor",
               "sparge-tower", "cold-trap-i", "reactor-processing-unit-i", "nuclear-salt-processing-plant", "cold-trap-ii", "reactor-processing-unit-ii",
               "algae-farm", "industrial-dehydrator", "naquadah-fuel-refinery", "naquadah-fuel-refinery-t2",
               "naquadah-fuel-refinery-t3", "naquadah-fuel-refinery-t4", "source-chamber", "beam-crafter",
               "luv-mass-fabricator", "nano-forge", "nano-forge-t2", "nano-forge-t3", *(f"draconic-evolution-fusion-crafter-t{k}" for k in range(1, 5)), "large-hadron-collider", "large-hadron-collider-weak", "large-hadron-collider-lhcb",
               *(f"precise-assembler-mk{i}" for i in range(1, 4)),
               *(f"space-elevator-mk{t}" for t in range(1, 6)),
               *(f"space-elevator-mining-module-mk{t}" for t in range(1, 4)),
               "planetary-gas-siphon", *(f"space-elevator-pump-module-mk{t}" for t in range(1, 4)),
               "space-elevator-assembler-module-mk1",
               *(f"ore-drilling-plant-mk{t}" for t in range(1, 5)), "lv-miner", "mv-miner", "hv-miner"}
# tier versions of a generator (136-fork-power.lua): the base sprite with dynamo hatches of the tier
# (GT hull of the tier + GT's dynamo hatch overlay) on the corner tiles; the base itself gets its own
# tier's hatches too. The icon gets the hatch as a badge.
TIER_COPIES = {
    "uv-large-naquadah-reactor": ["UV", "UHV", "UEV", "UIV", "UMV", "UXV"],
    "luv-large-plasma-turbine": ["LuV", "ZPM", "UV", "UHV", "UEV", "UIV", "UMV", "UXV", "MAX"],
}
DYNAMO_OVERLAY = "gregtech:iconsets/OVERLAY_ENERGY_OUT_MULTI_2A_{}"
# basic machines of these tiers: the tier's hull (MACHINE_<tier>_SIDE) as a frame of 3x3 tiles, the
# machine's top (MACHINE_<tier>_TOP + overlay) on the middle 2x2 tiles
HULL_TIERS = {"UHV", "UEV", "UIV", "UMV", "UXV", "MAX"}
# upgrade multiblocks (IV_UPGRADE_MACHINES in 101-fork-machines.lua): IV to UXV keep the upstream sprite of
# the EV version (base -> (sprite without "-idle.png" under graphics/entity, item icon under graphics/icons));
# each tier gets <tier>-<base>-hatches.png, an extra layer of the sprite's size with GT energy hatches of the
# tier (hull of the tier + GT's energy input overlay) in its two bottom corners, next to the controller that
# most of these sprites show in the middle of the bottom row, and an icon with the hatch as a badge
UPGRADE_MULTIBLOCKS = {
    "electric-blast-furnace": ("mv-electric-blast-furnace/mv-electric-blast-furnace", "hv-electric-blast-furnace"),
    "vacuum-freezer": ("vacuum-freezer/vacuum-freezer", "vacuum-freezer"),
    "large-chemical-reactor": ("large-chemical-reactor/large-chemical-reactor", "large-chemical-reactor"),
    "tall-distillation-tower": ("tall-distillation-tower/tall-distillation-tower", "tall-distillation-tower"),
    "short-distillation-tower": ("short-distillation-tower/short-distillation-tower", "short-distillation-tower"),
    "implosion-compressor": ("implosion-compressor/implosion-compressor", "implosion-compressor"),
    "cracker": ("cracker/cracker", "cracker"),
    "multismelter": ("mv-multismelter/mv-multismelter", "hv-multismelter"),
    "pyrolyse-oven": ("mv-pyrolyse-oven/mv-pyrolyse-oven", "hv-pyrolyse-oven"),
    "drilling-rig": ("mv-drilling-rig/mv-drilling-rig", "mv-drilling-rig"),
    "alloy-blast-smelter": ("fork/ev-alloy-blast-smelter", "alloy-blast-smelter"),
}
UPGRADE_TIERS = ["IV", "LuV", "ZPM", "UV", "UHV", "UEV", "UIV", "UMV", "UXV", "MAX"]
ENERGY_OVERLAY = "gregtech:iconsets/OVERLAY_ENERGY_IN_MULTI_2A_{}"
# large plasma turbine (136-fork-power.lua): the 3x3 front of GT's large turbine (tungstensteel
# rotor, animated when active); the icon is the middle tile
PLASMA_TURBINE = "luv-large-plasma-turbine"
PLASMA_TURBINE_FACE = "gregtech:iconsets/LARGETURBINE_TU"
# issue #97 (145-fork-power-multiblocks.lua): the steam turbines, GT's large turbine face of their casing (steel,
# titanium) with the dynamo hatch of their recipe on the corner tiles; the item icons are upstream's
STEAM_TURBINES = {
    "large-steam-turbine": ("gregtech:iconsets/LARGETURBINE_ST", "EV"),
    "high-pressure-steam-turbine": ("gregtech:iconsets/LARGETURBINE_TI", "IV"),
    # issue #256 (145): the large gas turbine, GT's stainless steel turbine face; no upstream item icon, so the icon is
    # the face's middle tile (STEAM_TURBINE_ICONS)
    "large-gas-turbine": ("gregtech:iconsets/LARGETURBINE_SS", "EV"),
}
STEAM_TURBINE_ICONS = {"large-gas-turbine"}
# items whose icon is a GT block texture (written to graphics/icons/fork/)
TEXTURE_ICONS = {
    "turbodyne-casing": "miscutils:TileEntities/MACHINE_CASING_ROCKETDYNE",   # issue #304
    "titanium-reinforced-borosilicate-glass-block": "bartworks:TitaniumReinforcedBoronSilicateGlassBlock",
    "tungstensteel-turbine-casing": "gregtech:iconsets/MACHINE_CASING_TURBINE_TUNGSTENSTEEL",
    "naquadah-reactor-casing": "gregtech:iconsets/NAQUADAH_REACTOR_CASING",
    # issue #97: kekztech's LuV and ZPM lapotronic capacitor blocks
    "lapotronic-capacitor-luv": "kekztech:LapotronicEnergyUnit2_side",
    "lapotronic-capacitor-zpm": "kekztech:LapotronicEnergyUnit3_side",
    # issues #254 to #256: the casings of the new power multiblocks
    "titanium-firebox-casing": "gregtech:iconsets/MACHINE_CASING_FIREBOX_TITANIUM",
    "engine-intake-casing": "gregtech:iconsets/MACHINE_CASING_ENGINE_INTAKE",
    "stainless-steel-turbine-casing": "gregtech:iconsets/MACHINE_CASING_TURBINE_STAINLESSSTEEL",
    # issue #301: the Space Elevator's parts (gtnhintergalactic's block and item textures)
    "space-elevator-base-casing": "gtnhintergalactic:spaceElevator/BaseCasing",
    "space-elevator-support-structure": "gtnhintergalactic:spaceElevator/SupportStructure_Side",
    "space-elevator-internal-structure": "gtnhintergalactic:spaceElevator/InternalStructure_Side",
    "space-elevator-cable": "gtnhintergalactic:spaceElevator/CablePart",
    "space-elevator-controller": "gtnhintergalactic:spaceElevator/MotorT1_Side",
    "nanotube-spool": "gtnhintergalactic:../items/nanotubeSpool",
    **{f"space-elevator-motor-mk{t}": f"gtnhintergalactic:spaceElevator/MotorT{t}_Side" for t in range(1, 6)},
    # issue #302: the mining drones (gtnhintergalactic's item textures)
    **{f"mining-drone-{t.lower()}": f"gtnhintergalactic:../items/drones/MiningDrone{t}"
       for t in ("LV", "MV", "HV", "EV", "IV", "LuV", "ZPM", "UV", "UHV", "UEV", "UIV", "UMV", "UXV")},
    # issue #249: GT's timepiece (MetaGeneratedItem03, meta 757)
    "timepiece": "gregtech:../items/gt.metaitem.03/757",
    # issue #274: GT++'s dehydrator coil wires and coils (item textures)
    "ev-dehydrator-coil-wire": "miscutils:../items/itemDehydratorCoilWire_0",
    "ev-dehydrator-coil": "miscutils:../items/itemDehydratorCoil_0",
    "iv-dehydrator-coil-wire": "miscutils:../items/itemDehydratorCoilWire_1",
    "iv-dehydrator-coil": "miscutils:../items/itemDehydratorCoil_1",
    "luv-dehydrator-coil-wire": "miscutils:../items/itemDehydratorCoilWire_2",
    "luv-dehydrator-coil": "miscutils:../items/itemDehydratorCoil_2",
    "zpm-dehydrator-coil-wire": "miscutils:../items/itemDehydratorCoilWire_3",
    "zpm-dehydrator-coil": "miscutils:../items/itemDehydratorCoil_3",
}
# issue #97: the lapotronic supercapacitors (one 5x5 accumulator per capacitor tier): kekztech's LSC casing as the
# border, the capacitor blocks of the tier inside, the controller in the top middle, GT's energy and dynamo hatch of
# the tier in the bottom corners; the LuV and ZPM icons are the upstream icon with the tier's dynamo hatch as a badge
SUPERCAPACITORS = {
    "lapotronic-supercapacitor": ("IV", "kekztech:LapotronicEnergyUnit1_side"),
    "luv-lapotronic-supercapacitor": ("LuV", "kekztech:LapotronicEnergyUnit2_side"),
    "zpm-lapotronic-supercapacitor": ("ZPM", "kekztech:LapotronicEnergyUnit3_side"),
}
SUPERCAPACITOR_CASING = "kekztech:LSCBase_side"
# sprites derived from existing fork graphics (name -> (source name, tint)): the turbine output
# hatch is the ME fluid interface in orange
DERIVED = {
    "turbine-output-hatch": ("me-fluid-interface", (255, 170, 80)),
}
# IV multiblocks: the casing is read from the recipe in 20-iv-age-entity.lua
IV_MULTIBLOCK_FACES = {
    "iv-industrial-electrolyzer": "miscutils:iconsets/controllerFaces/industrialElectrolyzer",
    "iv-industrial-cutting-factory": "miscutils:iconsets/controllerFaces/industrialCuttingMachine",
    "iv-industrial-extrusion-machine": "miscutils:iconsets/controllerFaces/industrialExtruder",
    "iv-industrial-mixer": "miscutils:iconsets/controllerFaces/industrialMixer",
    "iv-industrial-material-press": "miscutils:iconsets/controllerFaces/industrialPlatePress",
    "iv-industrial-wire-factory": "miscutils:iconsets/controllerFaces/industrialWiremill",
    "iv-industrial-centrifuge": "miscutils:iconsets/controllerFaces/industrialThermalCentrifuge",
    "iv-large-extractor": "gregtech:iconsets/OVERLAY_FRONT_INDUSTRIAL_EXTRACTOR",
    "iv-industrial-precision-lathe": "gregtech:iconsets/OVERLAY_FRONT_MULTI_LATHE",
    "iv-large-electric-compressor": "gregtech:iconsets/OVERLAY_FRONT_MULTI_COMPRESSOR",
    "iv-turbocan-pro": "gregtech:iconsets/OVERLAY_FRONT_MULTI_CANNER",
    "iv-fluid-shaper": "gregtech:iconsets/OVERLAY_FRONT_MASS_SOLIDIFIER",
    "iv-hyper-intensity-laser-engraver": "gregtech:iconsets/OVERLAY_FRONT_ENGRAVER",
    "iv-zyngen": "gregtech:iconsets/OVERLAY_FRONT_STEAM_ALLOY_SMELTER_MULTI",
    "iv-industrial-maceration-stack": "gregtech:iconsets/OVERLAY_FRONT_ORE_FACTORY",
    "iv-magnetic-flux-exhibiter": "gregtech:iconsets/OVERLAY_FRONT_EMS",
    "iv-chemical-bath-plant": "gregtech:iconsets/OVERLAY_FRONT_LARGE_CHEMICAL_REACTOR",
}
# single-block machines (Ender IO): icon upscaled 3x
ICON_MACHINES = ["slice-n-splice", "soul-binder", "powered-spawner"]


def gt_path(gt, spec):
    mod, rel = spec.split(":", 1)
    return gt / "src/main/resources/assets" / mod / "textures/blocks" / (rel + ".png")


def frames_of(img):
    """GT animations are vertical strips of square frames."""
    w, h = img.size
    n = max(1, h // w)
    return [img.crop((0, i * w, w, (i + 1) * w)) for i in range(n)]


def load(p):
    return Image.open(p).convert("RGBA")


def scaled(img, size):
    return img.resize((size, size), Image.NEAREST)


def save(img, path):
    """write only when the pixels changed (keeps the diff to the sprites that really changed)"""
    if path.exists():
        old = Image.open(path).convert("RGBA")
        if old.size == img.size and old.tobytes() == img.convert("RGBA").tobytes():
            return
    img.save(path, optimize=True)


def save_strip(frames, path):
    w, h = frames[0].size
    strip = Image.new("RGBA", (w, h * len(frames)))
    for i, f in enumerate(frames):
        strip.paste(f, (0, i * h))
    save(strip, path)


def tint(img, rgb):
    r, g, b = rgb
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            p = px[x, y]
            px[x, y] = (p[0] * r // 255, p[1] * g // 255, p[2] * b // 255, p[3])
    return img


def shade(p, f):
    return (min(255, int(p[0] * f)), min(255, int(p[1] * f)), min(255, int(p[2] * f)), p[3])


def casing_tile(gt, casing, override=None):
    spec = override or CASING_TEXTURE.get(casing) or (casing if ":" in casing else None)
    if spec and gt_path(gt, spec).exists():
        return frames_of(load(gt_path(gt, spec)))[0].resize((TILE, TILE), Image.NEAREST)
    return scaled(load(ICONS / f"{casing}.png"), TILE)


ENTITY = ROOT / "graphics/entity"


def ev_frames(base):
    """the frame count of the EV machine's working strip (make_electric_machine in the upstream entity files): the IV
    machine copies the EV machine's graphics set (101), so its strip has as many frames (the Fluid Extractor: the
    Extractor's, EV_FRAMES_OF)"""
    base = EV_FRAMES_OF.get(base, base)
    if base in EV_FRAMES:
        return EV_FRAMES[base]
    pat = re.compile(r'make_electric_machine\(\s*"ev-%s"\s*,\s*"[^"]*"\s*,\s*"[^"]*"\s*,\s*\{[^}]*\}\s*,\s*"[^"]*"\s*,'
                     r'\s*[\w.]+\s*,\s*[\d.]+\s*,\s*(\d+)' % re.escape(base))
    for f in sorted((ROOT / "prototypes").glob("*.lua")):
        m = pat.search(f.read_text(encoding="utf-8"))
        if m:
            return int(m.group(1))
    raise SystemExit(f"no make_electric_machine for ev-{base}")


def strip_frames(path, n=None):
    img = load(path)
    w = img.width
    frames = [img.crop((0, i * w, w, (i + 1) * w)) for i in range(img.height // w)]
    return frames[:n] if n else frames


def upstream(base, tier, kind):
    p = ENTITY / f"{tier}-{base}" / f"{tier}-{base}-{kind}.png"
    return p if p.exists() else None


_MV_PALETTE = None


def mv_casing_palette():
    """the colours of the MV casing: the MV pixels that differ from the LV asset, over every machine that has both"""
    global _MV_PALETTE
    if _MV_PALETTE is None:
        _MV_PALETTE = set()
        for base in BASIC_MACHINES:
            lv, mv = upstream(base, "lv", "idle"), upstream(base, "mv", "idle")
            if lv and mv:
                a, b = load(lv).load(), load(mv).load()
                for y in range(3 * TILE):
                    for x in range(3 * TILE):
                        if a[x, y] != b[x, y]:
                            _MV_PALETTE.add(b[x, y])
    return _MV_PALETTE


def casing_mask(base_img, other_img, palette):
    """the casing: the pixels where the LV and the MV picture differ and the base picture has a casing colour; without an
    LV picture (other_img None) the pixels of the MV picture in the MV casing colours"""
    a = base_img.load()
    b = other_img.load() if other_img is not None else None
    w, h = base_img.size
    return [(x, y) for y in range(h) for x in range(w)
            if a[x, y][3] and a[x, y] in palette and (b is None or a[x, y] != b[x, y])]


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) / 1000


def tier_ramp(tier):
    c = TIER_TINT[tier]
    return tuple(int(v * 0.28) for v in c), c, tuple(min(255, int(v * 0.55 + 255 * 0.45)) for v in c)


def recolour_casing(img, mask, tier, lo, hi, hull=None):
    """the casing pixels as a ramp of their brightness (lo..hi of the casing of the idle picture) from a dark tone through
    the tier colour to a light one; with a hull texture its brightness runs through the casing"""
    dark, mid, light = tier_ramp(tier)
    out = img.copy()
    px = out.load()
    hp = hull.load() if hull is not None else None
    for x, y in mask:
        p = px[x, y]
        t = min(1.0, max(0.0, (lum(p) - lo) / max(1.0, hi - lo)))
        a, b, f = (dark, mid, t * 2) if t < 0.5 else (mid, light, t * 2 - 1)
        q = tuple(int(a[i] + (b[i] - a[i]) * f) for i in range(3)) + (p[3],)
        if hp is not None:
            q = shade(q, 0.75 + 0.5 * sum(hp[x % hull.width, y % hull.height][:3]) / 765)
        px[x, y] = q
    return out


def basic_machine(gt, base, tier="IV"):
    """Issue #148: the upstream asset of the machine (LV's, else MV's) with its casing in the tier's colour: the idle
    picture, the working strip (the EV machine's frame count, the casing found frame by frame: moving parts cross it)
    and the icon (the casing: the pixels that differ between the LV, MV, HV and EV icons, those upstream has)."""
    lv, mv = upstream(base, "lv", "idle"), upstream(base, "mv", "idle")
    if base in LV_DERIVED:
        lv = None                # (drawn from the MV picture by lv_from_mv, not upstream's)
    src, other = (lv, mv) if lv else (mv, None)
    idle_src = load(src)
    other_idle = load(other) if other else None
    if other:
        a, b = idle_src.load(), other_idle.load()
        palette = {a[x, y] for y in range(idle_src.height) for x in range(idle_src.width) if a[x, y] != b[x, y]}
    else:
        palette = mv_casing_palette()
    mask = casing_mask(idle_src, other_idle, palette)
    lo, hi = min(lum(idle_src.getpixel(p)) for p in mask), max(lum(idle_src.getpixel(p)) for p in mask)
    hull = None
    if tier in HULL_TIERS:
        hull = scaled(tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), TIER_TINT[tier]), TILE)
    name = f"{tier.lower()}-{base}"
    save(recolour_casing(idle_src, mask, tier, lo, hi, hull), OUT_ENTITY / f"{name}-idle.png")

    n = ev_frames(base)
    kind_src = src.with_name(src.name.replace("-idle.png", "-working.png"))
    work = strip_frames(kind_src, n)
    work_other = strip_frames(other.with_name(other.name.replace("-idle.png", "-working.png")), n) if other else None
    if len(work) < n:
        raise SystemExit(f"{kind_src} has {len(work)} frames, the EV machine plays {n}")
    frames = [recolour_casing(f, casing_mask(f, work_other[i] if work_other else None, palette), tier, lo, hi, hull)
              for i, f in enumerate(work)]
    save_strip(frames, OUT_ENTITY / f"{name}-working.png")

    icons = [load(ICONS / f"{t}-{base}.png") for t in ("lv", "mv", "hv", "ev") if (ICONS / f"{t}-{base}.png").exists()
             and not (t == "lv" and base == "laser-engraver")]   # (lv_from_mv's icon; the extruder's LV icon is upstream's)
    ip = [i.load() for i in icons]
    imask = [(x, y) for y in range(TILE) for x in range(TILE)
             if ip[0][x, y][3] and len({p[x, y] for p in ip}) > 1]
    ilo, ihi = min(lum(icons[0].getpixel(p)) for p in imask), max(lum(icons[0].getpixel(p)) for p in imask)
    save(recolour_casing(icons[0], imask, tier, ilo, ihi, scaled(hull, TILE // 2) if hull else None),
         OUT_ICON / f"{name}.png")


MOLTEN = [(120, 30, 0), (200, 70, 0), (255, 130, 0), (255, 190, 40), (255, 240, 150)]
# a drop of melt, 9 x 12 pixels: '#' outline, 'a' to 'd' dark to light
DROP = ["....#....",
        "...#c#...",
        "...#c#...",
        "..#cdb#..",
        ".#cddbb#.",
        ".#cdbbb#.",
        "#cdbbbba#",
        "#cbbbbba#",
        "#bbbbbaa#",
        ".#bbaaa#.",
        "..#aaa#..",
        "...###..."]


def badged(base, icon):
    """FLUID_BADGE_MACHINES: the icon with a drop of melt in its bottom right corner"""
    if base not in FLUID_BADGE_MACHINES:
        return icon
    out = icon.copy()
    col = {"#": (40, 12, 0, 255), "a": MOLTEN[1] + (255,), "b": MOLTEN[2] + (255,), "c": MOLTEN[3] + (255,),
           "d": MOLTEN[4] + (255,)}
    x0, y0 = TILE - len(DROP[0]), TILE - len(DROP)
    for y, row in enumerate(DROP):
        for x, ch in enumerate(row):
            if ch in col:
                out.putpixel((x0 + x, y0 + y), col[ch])
    return out


def molten(p):
    """a liquid pixel of the extractor's tubes (teal, green) as molten metal of the same brightness"""
    lum = (p[0] * 299 + p[1] * 587 + p[2] * 114) / 255000
    i = min(len(MOLTEN) - 1, int(lum * len(MOLTEN)))
    return MOLTEN[i] + (p[3],)


def is_liquid(p):
    return p[3] and max(p[:3]) - min(p[:3]) > 40


def casing_palette(base, tier, kind="idle"):
    """the colours of the casing of an upstream LV or MV asset (the pixels that differ between its LV and MV picture),
    sorted dark to light"""
    a, b = load(upstream(base, "lv", kind)).load(), load(upstream(base, "mv", kind)).load()
    src = a if tier == "lv" else b
    cols = {src[x, y] for y in range(3 * TILE) for x in range(3 * TILE) if a[x, y] != b[x, y] and src[x, y][3]}
    return sorted(cols, key=lum)


def quantile_map(colours, palette):
    """each colour onto the palette colour at the same rank of brightness"""
    order = sorted(set(colours), key=lum)
    n, m = max(1, len(order) - 1), len(palette) - 1
    return {c: palette[round(i * m / n)] for i, c in enumerate(order)}


HAMMER_WINDOW = (11, 16, 75, 70)   # the window of the steam forge hammer (its PSD's layers 7 and 8)


def forge_hammer_lv_mv():
    """Issue #170: upstream has no electric forge hammer, only the Steam Forge Hammer's picture (graphics/entity/psds
    forge-hammer-*.psd are its sources). The LV and MV forge hammer are that picture with the bronze casing (every pixel
    outside the window) in the casing colours of the LV and the MV extractor, rank for rank of brightness, so the
    texture stays and the colours are upstream's; the window (anvil, hammer, sparks) stays. The LV to EV icons: the steam
    hammer's icon with its bronze pixels in the colours of the LV, MV, HV and EV extractor icons."""
    d = ENTITY / "steam-forge-hammer"
    idle = load(d / "steam-forge-hammer-idle.png")
    frames = strip_frames(d / "steam-forge-hammer-working.png")
    x0, y0, x1, y1 = HAMMER_WINDOW
    outside = lambda x, y: not (x0 <= x < x1 and y0 <= y < y1)
    ip = idle.load()
    casing = [(x, y) for y in range(idle.height) for x in range(idle.width) if ip[x, y][3] and outside(x, y)]
    for t in ("lv", "mv"):
        cmap = quantile_map([ip[p] for p in casing], casing_palette("extractor", t))
        dst = ENTITY / f"{t}-forge-hammer"
        dst.mkdir(exist_ok=True)

        def recolour(img):
            out = img.copy()
            px = out.load()
            for p in casing:
                if px[p] in cmap:
                    c = cmap[px[p]]
                    px[p] = c[:3] + (px[p][3],)
            return out
        save(recolour(idle), dst / f"{t}-forge-hammer-idle.png")
        save_strip([recolour(f) for f in frames], dst / f"{t}-forge-hammer-working.png")
    icon = load(ICONS / "steam-forge-hammer.png")
    ic = icon.load()
    bronze = [(x, y) for y in range(icon.height) for x in range(icon.width)
              if ic[x, y][3] and ic[x, y][0] > ic[x, y][2] + 25 and ic[x, y][0] >= ic[x, y][1]]
    icons = [load(ICONS / f"{t}-extractor.png") for t in ("lv", "mv", "hv", "ev")]
    ep = [i.load() for i in icons]
    imask = [(x, y) for y in range(TILE) for x in range(TILE) if ep[0][x, y][3] and len({e[x, y] for e in ep}) > 1]
    for t, e in zip(("lv", "mv", "hv", "ev"), ep):
        cmap = quantile_map([ic[p] for p in bronze], sorted({e[p] for p in imask}, key=lum))
        out = icon.copy()
        px = out.load()
        for p in bronze:
            px[p] = cmap[ic[p]][:3] + (ic[p][3],)
        save(out, ICONS / f"{t}-forge-hammer.png")


def framed_overlay_lv_mv(gt, base, frame, window, overlay, glow=False, crop=False, animated=False):
    """LV and MV pictures of a machine upstream has no picture of: the LV and MV <frame> machine's idle picture with
    GT's front overlay of the machine at 2x in its window (x0, y0, x1, y1), the plain overlay at rest and the active one
    (with its glow) while it works; with crop the overlay is cut to its content first. The LV to EV icons: the frame
    machine's with the active overlay as a badge in the bottom right corner. With animated the working strip has every
    frame of the active overlay (cut to the box of the plain one)."""
    def front(name, i=0):
        img = frames_of(load(gt_path(gt, overlay + name)))[i]
        if crop:
            img = img.crop(frames_of(load(gt_path(gt, overlay)))[0].getbbox() if animated else img.getbbox())
        return img.resize((img.width * 2, img.height * 2), Image.NEAREST)
    idle_front = front("")
    work_front = front("_ACTIVE")
    if glow:
        work_front.alpha_composite(front("_ACTIVE_GLOW"))
    work_fronts = ([front("_ACTIVE", i) for i in range(len(frames_of(load(gt_path(gt, overlay + "_ACTIVE")))))]
                   if animated else None)
    x0, y0, x1, y1 = window
    at = (x0 + (x1 - x0 - idle_front.width) // 2, y0 + (y1 - y0 - idle_front.height) // 2)
    for t in ("lv", "mv"):
        img0 = load(ENTITY / f"{t}-{frame}" / f"{t}-{frame}-idle.png")
        dst = ENTITY / f"{t}-{base}"
        dst.mkdir(exist_ok=True)
        for kind, f in (("idle", idle_front), ("working", work_front)):
            img = img0.copy()
            img.alpha_composite(f, at)
            if kind == "working" and work_fronts:
                frames = []
                for wf in work_fronts:
                    fr = img0.copy()
                    fr.alpha_composite(wf, at)
                    frames.append(fr)
                save_strip(frames, dst / f"{t}-{base}-{kind}.png")
                continue
            save(img, dst / f"{t}-{base}-{kind}.png")
    badge = frames_of(load(gt_path(gt, overlay + "_ACTIVE")))[0]
    if crop:
        badge = badge.crop(badge.getbbox())
    k = 12 / max(badge.size)
    badge = badge.resize((max(1, round(badge.width * k)), max(1, round(badge.height * k))), Image.NEAREST)
    for t in ("lv", "mv", "hv", "ev"):
        icon = load(ICONS / f"{t}-{frame}.png")
        icon.alpha_composite(badge, (TILE - badge.width, TILE - badge.height))
        save(icon, ICONS / f"{t}-{base}.png")


def arc_furnace_lv_mv(gt):
    """Issue #171: upstream has no arc furnace: the LV and MV compressor's frame with GT's arc furnace front (dark slots
    at rest, glowing ones while it works)"""
    framed_overlay_lv_mv(gt, "arc-furnace", "compressor", ARC_WINDOW, ARC_OVERLAY, glow=True)


def forming_press_lv_mv(gt):
    """Issue #173: upstream has no forming press: the LV and MV wiremill's frame with GT's press front"""
    framed_overlay_lv_mv(gt, "forming-press", "wiremill", PRESS_WINDOW, PRESS_OVERLAY, crop=True)


def electric_furnace_lv_mv(gt):
    """Issue #174: upstream has no electric furnace: the LV and MV assembling machine's frame with GT's electric furnace
    front (dark at rest, glowing while it works)"""
    framed_overlay_lv_mv(gt, "electric-furnace", "assembling-machine", FURNACE_WINDOW, FURNACE_OVERLAY, glow=True, crop=True)


def sifting_machine_lv_mv(gt):
    """Issue #175: upstream has no basic sifter: the LV and MV lathe's frame with GT's sifter front (its active overlay is
    animated, 4 frames)"""
    framed_overlay_lv_mv(gt, "sifting-machine", "lathe", SIFTER_WINDOW, SIFTER_OVERLAY, crop=True, animated=True)


def thermal_centrifuge_lv_mv(gt):
    """Issue #185: upstream has no thermal centrifuge: the LV and MV fluid solidifier's frame with GT's thermal centrifuge
    front (its lamps and gauge glow while it works)"""
    framed_overlay_lv_mv(gt, "thermal-centrifuge", "fluid-solidifier", THERMAL_WINDOW, THERMAL_OVERLAY, glow=True, crop=True)


def electromagnetic_separator_lv_mv(gt):
    """Issue #187: upstream has no electromagnetic separator: the LV and MV polarizer's frame with GT's separator front
    (4 frames while it works) between the poles"""
    framed_overlay_lv_mv(gt, "electromagnetic-separator", "polarizer", EMS_WINDOW, EMS_OVERLAY, crop=True, animated=True)



def brewery_lv_mv(gt):
    """Issue #360: upstream has no brewery: the LV and MV assembling machine's frame with GT's potion brewer front"""
    framed_overlay_lv_mv(gt, "brewery", "assembling-machine", FURNACE_WINDOW, BREWERY_OVERLAY, crop=True)


def fermenter_lv_mv(gt):
    """Issue #360: upstream has no fermenter: the LV and MV fluid solidifier's frame with GT's fermenter front (it glows
    while it works)"""
    framed_overlay_lv_mv(gt, "fermenter", "fluid-solidifier", THERMAL_WINDOW, FERMENTER_OVERLAY, glow=True, crop=True)


# issue #449: the LV machines upstream has no picture of, drawn from the MV one (lv_from_mv); the IV and higher tiers of
# the extruder and the laser engraver keep coming from the MV picture and the upstream icons (basic_machine skips these)
LV_DERIVED = {"extruder", "laser-engraver"}


def lv_from_mv(base, icon=True, icon_palette=False):
    """Issues #193 and #449: upstream has no LV picture of the machine (GT's Basic Autoclave, Basic Extruder, Basic
    Precision Laser Engraver, Basic Combustion Generator). Its picture is the MV one's with the MV casing colours
    (mv_casing_palette) in the LV extractor's casing colours, rank for rank of brightness, as the forge hammer's; the icon
    the MV icon with the pixels that differ from the HV and EV icons (those upstream has) in the colours of the LV
    extractor icon's casing."""
    lv_pal, mv_pal = casing_palette("extractor", "lv"), mv_casing_palette()
    dst = ENTITY / f"lv-{base}"
    dst.mkdir(exist_ok=True)
    for kind in ("idle", "working"):
        src = ENTITY / f"mv-{base}" / f"mv-{base}-{kind}.png"
        frames = strip_frames(src) if kind == "working" else [load(src)]
        masks = [casing_mask(f, None, mv_pal) for f in frames]
        cmap = quantile_map([f.getpixel(xy) for f, m in zip(frames, masks) for xy in m], lv_pal)
        out = []
        for f, m in zip(frames, masks):
            g = f.copy()
            for xy in m:
                g.putpixel(xy, cmap[f.getpixel(xy)])
            out.append(g)
        if kind == "working":
            save_strip(out, dst / f"lv-{base}-{kind}.png")
        else:
            save(out[0], dst / f"lv-{base}-{kind}.png")
    if not icon:
        return
    icons = [load(ICONS / f"{t}-{base}.png") for t in ("mv", "hv", "ev") if (ICONS / f"{t}-{base}.png").exists()]
    ip = [i.load() for i in icons]
    if icon_palette:
        # (the laser engraver's MV, HV and EV icons differ in their front too: the casing is the MV icon's pixels in the
        # MV casing colours of the icons, those of every basic machine whose LV and MV icons upstream has)
        pal = set()
        for other in BASIC_MACHINES:
            lvi, mvi = ICONS / f"lv-{other}.png", ICONS / f"mv-{other}.png"
            if lvi.exists() and mvi.exists() and other not in LV_DERIVED:
                c, d = load(lvi).load(), load(mvi).load()
                pal |= {d[x, y] for y in range(TILE) for x in range(TILE) if c[x, y] != d[x, y] and d[x, y][3]}
        imask = [(x, y) for y in range(TILE) for x in range(TILE) if ip[0][x, y][3] and ip[0][x, y] in pal]
    else:
        imask = [(x, y) for y in range(TILE) for x in range(TILE) if ip[0][x, y][3] and len({q[x, y] for q in ip}) > 1]
    a, b = load(ICONS / "lv-extractor.png").load(), load(ICONS / "mv-extractor.png").load()
    ext = sorted({a[x, y] for y in range(TILE) for x in range(TILE) if a[x, y] != b[x, y] and a[x, y][3]}, key=lum)
    cmap = quantile_map([icons[0].getpixel(xy) for xy in imask], ext)
    out_icon = icons[0].copy()
    for xy in imask:
        out_icon.putpixel(xy, cmap[icons[0].getpixel(xy)])
    save(out_icon, ICONS / f"lv-{base}.png")


# issue #446: GT New Horizons' steam age (Large Coal Boiler, Reinforced Lava Boiler, Simple and Advanced Solar Boiler,
# Steam Furnace and the High Pressure steam machines)
STEAM_MACHINES = ["alloy-smelter", "compressor", "forge-hammer", "macerator", "extractor"]
BOILER_WINDOW = (16, 54, 70, 81)       # the fire opening of the small coal boiler (its on and off pictures differ there)
STEAM_WINDOW = (11, 21, 70, 60)        # the window of the steam compressor


def steel(img):
    """GT's high pressure (steel) machines: the bronze casing pixels (hue 20-50 degrees, saturated, not the fire's bright
    yellow) in grey of the same brightness with a cold cast"""
    import colorsys
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if not a:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if 20 / 360 <= h <= 50 / 360 and s >= 0.3 and not (s > 0.8 and v > 0.85):
                l = lum((r, g, b)) * 1.05
                px[x, y] = (min(255, int(l * 0.90)), min(255, int(l * 0.94)), min(255, int(l * 1.0)), a)
    return out


def in_window(img, overlay, window, scale=2):
    """the overlay at scale in the middle of the window, cut to it"""
    x0, y0, x1, y1 = window
    o = overlay.resize((overlay.width * scale, overlay.height * scale), Image.NEAREST)
    at = (x0 + (x1 - x0 - o.width) // 2, y0 + (y1 - y0 - o.height) // 2)
    cut = o.crop((max(0, x0 - at[0]), max(0, y0 - at[1]), min(o.width, x1 - at[0]), min(o.height, y1 - at[1])))
    out = img.copy()
    out.alpha_composite(cut, (max(x0, at[0]), max(y0, at[1])))
    return out


def badged_icon(icon, overlay):
    k = 12 / max(overlay.size)
    b = overlay.resize((max(1, round(overlay.width * k)), max(1, round(overlay.height * k))), Image.NEAREST)
    out = icon.copy()
    out.alpha_composite(b, (TILE - b.width, TILE - b.height))
    return out


def steam_age(gt):
    """Issue #446: the high pressure machines are the steam machines in steel (steel()); the Steam Furnace the steam
    compressor's frame with GT's steam furnace front in its window; the Large Coal Boiler the small coal boiler in steel;
    the Reinforced Lava Boiler that with GT's lava boiler front in the fire opening, the Simple Solar Boiler the small coal
    boiler with GT's solar boiler top there (the Advanced one in steel). Icons: the source's in steel, or with the front as
    a badge."""
    def tex(name, i=0):
        return frames_of(load(gt_path(gt, "gregtech:iconsets/" + name)))[i]
    def entity_dir(name):
        d = ENTITY / name
        d.mkdir(exist_ok=True)
        return d
    # the steam furnace
    comp = load(ENTITY / "steam-compressor" / "steam-compressor-idle.png")
    work = tex("OVERLAY_FRONT_STEAM_FURNACE_ACTIVE")
    work.alpha_composite(tex("OVERLAY_FRONT_STEAM_FURNACE_ACTIVE_GLOW"))
    d = entity_dir("steam-furnace")
    save(in_window(comp, tex("OVERLAY_FRONT_STEAM_FURNACE"), STEAM_WINDOW), d / "steam-furnace-idle.png")
    save(in_window(comp, work, STEAM_WINDOW), d / "steam-furnace-working.png")
    save(badged_icon(load(ICONS / "steam-compressor.png"), work), ICONS / "steam-furnace.png")
    # the high pressure machines
    for m in STEAM_MACHINES + ["furnace"]:
        src, dst = f"steam-{m}", f"hp-steam-{m}"
        d = entity_dir(dst)
        for kind in ("idle", "working"):
            save(steel(load(ENTITY / src / f"{src}-{kind}.png")), d / f"{dst}-{kind}.png")
        save(steel(load(ICONS / f"{src}.png")), ICONS / f"{dst}.png")
    # the boilers
    on = load(ENTITY / "small-coal-boiler" / "small-coal-boiler.png")
    off = load(ENTITY / "small-coal-boiler" / "steam-boiler-off.png")
    icon = load(ICONS / "small-coal-boiler.png")
    d = entity_dir("large-coal-boiler")
    save(steel(on), d / "large-coal-boiler.png")
    save(steel(off), d / "large-coal-boiler-off.png")
    save(steel(icon), ICONS / "large-coal-boiler.png")
    lava_on = tex("BOILER_LAVA_FRONT_ACTIVE")
    lava_on.alpha_composite(tex("BOILER_LAVA_FRONT_ACTIVE_GLOW"))
    d = entity_dir("reinforced-lava-boiler")
    save(in_window(steel(off), tex("BOILER_LAVA_FRONT"), BOILER_WINDOW), d / "reinforced-lava-boiler-idle.png")
    save(in_window(steel(off), lava_on, BOILER_WINDOW), d / "reinforced-lava-boiler-working.png")
    save(badged_icon(steel(icon), lava_on), ICONS / "reinforced-lava-boiler.png")
    solar = tex("BOILER_SOLAR")
    for name, look in (("simple-solar-boiler", lambda i: i), ("advanced-solar-boiler", steel)):
        d = entity_dir(name)
        pic = in_window(look(off), solar, BOILER_WINDOW)
        save(pic, d / f"{name}-idle.png")
        save(pic, d / f"{name}-working.png")
        save(badged_icon(look(icon), solar), ICONS / f"{name}.png")


# issue #444: the battery buffers LV to HV, 1 to 16 batteries (prototypes/145-fork-power-multiblocks.lua, section 8)
BUFFER_TINT = {"LV": (150, 144, 136), "MV": (175, 225, 250), "HV": (220, 220, 236)}


def battery_buffers(gt):
    """GT's battery buffer: the tier's hull (MACHINE_<tier>_SIDE in the colour of Gregtorio's hull of the tier) with GT's
    energy output overlay on top and the battery slots below, n x n dark slots with a lit battery each (2 x 2 tiles,
    and the icon the same at half the size)"""
    for tier in ("LV", "MV", "HV"):
        side = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), BUFFER_TINT[tier])
        face = side.copy()
        face.alpha_composite(frames_of(load(gt_path(gt, "gregtech:iconsets/OVERLAY_ENERGY_OUT")))[0])
        for n in (1, 2, 3, 4):
            name = f"{tier.lower()}-battery-buffer-{n * n}"
            for size, path in ((64, OUT_ENTITY / f"{name}.png"), (TILE, ICONS / f"{name}.png")):
                img = Image.new("RGBA", (size, size))
                img.alpha_composite(side.resize((size, size), Image.NEAREST))
                top = face.resize((size // 2, size // 2), Image.NEAREST)
                img.alpha_composite(top, (size // 4, 0))
                box = (size // 8, size // 2 + size // 16, size - size // 8, size - size // 16)
                cw, ch = (box[2] - box[0]) // n, (box[3] - box[1]) // n
                px = img.load()
                for i in range(n):
                    for j in range(n):
                        x0, y0 = box[0] + i * cw, box[1] + j * ch
                        for y in range(y0, y0 + ch):
                            for x in range(x0, x0 + cw):
                                edge = x in (x0, x0 + cw - 1) or y in (y0, y0 + ch - 1)
                                px[x, y] = (30, 30, 34, 255) if edge else (90, 200, 120, 255)
                save(img, path)


def fluid_extractor_lv_ev():
    """Issue #152: the LV and MV fluid extractor sprites (HV and EV use MV's, like the extractor) are upstream's
    extractor with the liquid in its tubes molten; the idle picture keeps a low melt in the tubes, so the two machines
    differ at rest too. The LV to EV icons are the extractor's with the molten badge."""
    ent = ROOT / "graphics/entity"
    for t in ("lv", "mv"):
        src, dst = ent / f"{t}-extractor", ent / f"{t}-fluid-extractor"
        dst.mkdir(exist_ok=True)
        idle = load(src / f"{t}-extractor-idle.png")
        strip = load(src / f"{t}-extractor-working.png")
        w = strip.width
        frames = [strip.crop((0, i * w, w, (i + 1) * w)) for i in range(strip.height // w)]
        ip = idle.load()
        out = []
        for f in frames:
            g = f.copy()
            px = g.load()
            for y in range(w):
                for x in range(w):
                    # the liquid: coloured and not in the idle picture (the MV casing is coloured too)
                    if is_liquid(px[x, y]) and px[x, y] != ip[x, y]:
                        px[x, y] = molten(px[x, y])
            out.append(g)
        save_strip(out, dst / f"{t}-fluid-extractor-working.png")
        # the liquid of the first frame, its lower part (the lowest 35 % of its height) in the idle tubes
        f0 = frames[0].load()
        cells = [(x, y) for y in range(w) for x in range(w) if is_liquid(f0[x, y]) and f0[x, y] != ip[x, y]]
        top, bottom = min(y for _, y in cells), max(y for _, y in cells)
        level = bottom - (bottom - top) * 0.35
        img = idle.copy()
        for x, y in cells:
            if y >= level:
                img.putpixel((x, y), molten(f0[x, y]))
        save(img, dst / f"{t}-fluid-extractor-idle.png")
    for t in ("lv", "mv", "hv", "ev"):
        save(badged("fluid-extractor", load(ICONS / f"{t}-extractor.png")), ICONS / f"{t}-fluid-extractor.png")


def multiblock(gt, name, size, casing, controller, face, middle):
    w, h = size
    cas = casing_tile(gt, casing, CASING_OVERRIDE.get(name))
    mid = casing_tile(gt, middle) if middle else None

    def build(active):
        img = Image.new("RGBA", (w * TILE, h * TILE))
        for y in range(h):
            for x in range(w):
                tile = mid if (mid and 0 < y < h - 1) else cas
                img.paste(tile, (x * TILE, y * TILE))
        ctrl = cas.copy()
        if isinstance(face, tuple):
            ctrl.alpha_composite(frames_of(load(gt_path(gt, face[1 if active else 0])))[0].resize((TILE, TILE), Image.NEAREST))
        elif face:
            p = gt_path(gt, face + ("Active" if active and "controllerFaces" in face else "_ACTIVE" if active else ""))
            if not p.exists():
                p = gt_path(gt, face)
            ctrl.alpha_composite(frames_of(load(p))[0].resize((TILE, TILE), Image.NEAREST))
        elif controller and (ICONS / f"{controller}.png").exists():
            ctrl = scaled(load(ICONS / f"{controller}.png"), TILE)
        cx, cy = w // 2, h - 1 if h > 3 else h // 2
        img.paste(ctrl, (cx * TILE, cy * TILE), ctrl)
        return img

    save(build(False), OUT_ENTITY / f"{name}-idle.png")
    save(build(True), OUT_ENTITY / f"{name}-working.png")
    if name in CONTROLLER_ICONS:
        # no upstream item icon: the controller tile
        img = build(False)
        cx, cy = w // 2, h - 1 if h > 3 else h // 2
        save(img.crop((cx * TILE, cy * TILE, (cx + 1) * TILE, (cy + 1) * TILE)), OUT_ICON / f"{name}.png")
    if name in WHOLE_ICONS:
        save(scaled(build(False), TILE), OUT_ICON / f"{name}.png")


def turbine_face(gt, face, active):
    """3x3 face of GT's large turbine: tiles 1..9 idle, the ACTIVE strips animated (frame 0 used)."""
    img = Image.new("RGBA", (3 * TILE, 3 * TILE))
    for i in range(9):
        spec = face + ("_ACTIVE" if active else "") + str(i + 1)
        tile = frames_of(load(gt_path(gt, spec)))[0].resize((TILE, TILE), Image.NEAREST)
        img.paste(tile, ((i % 3) * TILE, (i // 3) * TILE))
    return img


def plasma_turbine(gt, name):
    save(turbine_face(gt, PLASMA_TURBINE_FACE, False), OUT_ENTITY / f"{name}-idle.png")
    save(turbine_face(gt, PLASMA_TURBINE_FACE, True), OUT_ENTITY / f"{name}-working.png")
    save(turbine_face(gt, PLASMA_TURBINE_FACE, False).crop((TILE, TILE, 2 * TILE, 2 * TILE)), OUT_ICON / f"{name}.png")


def steam_turbine(gt, name, face, tier):
    """issue #97: the turbine face with the dynamo hatches of its tier on the corner tiles (like TIER_COPIES)"""
    hatch = scaled(dynamo_hatch(gt, tier), TILE)
    for active, suffix in ((False, "-idle.png"), (True, "-working.png")):
        img = turbine_face(gt, face, active)
        for x, y in ((0, 0), (2 * TILE, 0), (0, 2 * TILE), (2 * TILE, 2 * TILE)):
            img.paste(hatch, (x, y))
        save(img, OUT_ENTITY / f"{name}{suffix}")
    if name in STEAM_TURBINE_ICONS:
        save(turbine_face(gt, face, False).crop((TILE, TILE, 2 * TILE, 2 * TILE)), OUT_ICON / f"{name}.png")


def supercapacitor(gt, name, tier, unit):
    """issue #97: 5x5, casing border, capacitor blocks inside, controller top middle, hatches in the bottom corners"""
    cas, cap = casing_tile(gt, SUPERCAPACITOR_CASING), casing_tile(gt, unit)
    img = Image.new("RGBA", (5 * TILE, 5 * TILE))
    for y in range(5):
        for x in range(5):
            img.paste(cap if 0 < x < 4 and 0 < y < 4 else cas, (x * TILE, y * TILE))
    ctrl = scaled(load(ICONS / "lapotronic-supercapacitor-controller.png"), TILE)
    img.alpha_composite(ctrl, (2 * TILE, 0))
    img.paste(scaled(energy_hatch(gt, tier), TILE), (0, 4 * TILE))
    img.paste(scaled(dynamo_hatch(gt, tier), TILE), (4 * TILE, 4 * TILE))
    save(img, OUT_ENTITY / f"{name}.png")
    if tier != "IV":
        icon = load(ICONS / "lapotronic-supercapacitor.png").copy()
        hatch = dynamo_hatch(gt, tier)
        icon.alpha_composite(hatch, (TILE - hatch.width, TILE - hatch.height))
        save(icon, OUT_ICON / f"{name}.png")


def dynamo_hatch(gt, tier):
    """GT's dynamo hatch of a tier: the tier's hull with the tier's dynamo overlay (16 px)"""
    img = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), TIER_TINT[tier])
    img.alpha_composite(frames_of(load(gt_path(gt, DYNAMO_OVERLAY.format(tier))))[0])
    return img


def tier_copies(gt, base, tiers):
    """<tier>-<rest of base name>: the base sprites with the tier's dynamo hatches on the corner tiles,
    the base icon with the hatch as a badge in its bottom right corner"""
    rest = base.split("-", 1)[1]
    src = {suffix: load(folder / f"{base}{suffix}")
           for suffix, folder in (("-idle.png", OUT_ENTITY), ("-working.png", OUT_ENTITY), (".png", OUT_ICON))}
    for tier in tiers:
        name = f"{tier.lower()}-{rest}"
        hatch = dynamo_hatch(gt, tier)
        for suffix in ("-idle.png", "-working.png"):
            img = src[suffix].copy()
            w, h = img.size
            for x, y in ((0, 0), (w - TILE, 0), (0, h - TILE), (w - TILE, h - TILE)):
                img.paste(scaled(hatch, TILE), (x, y))
            save(img, OUT_ENTITY / f"{name}{suffix}")
        icon = src[".png"].copy()
        icon.alpha_composite(hatch, (TILE - hatch.width, TILE - hatch.height))
        save(icon, OUT_ICON / f"{name}.png")


def energy_hatch(gt, tier):
    """GT's energy hatch of a tier: the tier's hull with the tier's 2A energy input overlay (16 px)"""
    img = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), TIER_TINT[tier])
    img.alpha_composite(frames_of(load(gt_path(gt, ENERGY_OVERLAY.format(tier))))[0])
    return img


def hatch_spots(sprites):
    """one tile per bottom corner for a hatch: the spot nearest to the corner, inside the corner's quarter of
    the sprite, on which every given sprite (idle, working) is opaque (the sprites are not all rectangular);
    the top corners stay free, so the hatches cover no pipe ports or tower tops"""
    w, h = sprites[0].size
    alphas = [s.getchannel("A").load() for s in sprites]

    def solid(x0, y0):
        return all(a[x, y] >= 128 for a in alphas for y in range(y0, y0 + TILE, 2) for x in range(x0, x0 + TILE, 2))

    spots = []
    for right, bottom in ((0, 1), (1, 1)):
        cands = [(dx + dy, dx, dy) for dx in range(0, w // 2 - TILE + 1) for dy in range(0, h // 2 - TILE + 1)]
        for _, dx, dy in sorted(cands):
            x, y = (w - TILE - dx) if right else dx, (h - TILE - dy) if bottom else dy
            if solid(x, y):
                spots.append((x, y))
                break
    return spots


def upgrade_hatches(gt, base, sprite, icon):
    """<tier>-<base>-hatches.png (layer on the unchanged EV sprite) and <tier>-<base>.png (badged icon)"""
    src = [load(ROOT / "graphics/entity" / f"{sprite}{s}.png") for s in ("-idle", "-working")]
    spots = hatch_spots(src)
    base_icon = load(ICONS / f"{icon}.png")
    for tier in UPGRADE_TIERS:
        name = f"{tier.lower()}-{base}"
        hatch = energy_hatch(gt, tier)
        layer = Image.new("RGBA", src[0].size)
        for xy in spots:
            layer.paste(scaled(hatch, TILE), xy)
        save(layer, OUT_ENTITY / f"{name}-hatches.png")
        img = base_icon.copy()
        img.alpha_composite(hatch, (TILE - hatch.width, TILE - hatch.height))
        save(img, OUT_ICON / f"{name}.png")


def derived(name, source, rgb):
    """Tinted copy of a fork sprite and icon (the AE2 sprites live in graphics/entity/fork/ae2/)."""
    for folder, src in ((OUT_ENTITY, OUT_ENTITY / "ae2" / f"{source}.png"), (OUT_ICON, OUT_ICON / f"{source}.png")):
        if not src.exists():
            src = folder / f"{source}.png"
        if src.exists():
            save(tint(load(src), rgb), folder / f"{name}.png")


def icon_machine(name):
    img = scaled(load(ICONS / f"{name}.png"), 3 * TILE)
    save(img, OUT_ENTITY / f"{name}-idle.png")
    save(img, OUT_ENTITY / f"{name}-working.png")


def iv_multiblock_casings():
    """Casing = the ingredient with 'casing' in its name and the largest amount in the multiblock recipe."""
    txt = (ROOT / "prototypes/20-iv-age-entity.lua").read_text(encoding="utf-8")
    out = {}
    for m in re.finditer(r'create_item\{\s*name\s*=\s*"(iv-[^"]+)"(.*?)\n\}', txt, re.S):
        name, body = m.group(1), m.group(2)
        best = None
        for im in re.finditer(r'name\s*=\s*"([^"]*(?:casing|factory-frame)[^"]*)",\s*amount\s*=\s*(\d+)', body):
            if "hull" in im.group(1):
                continue
            if best is None or int(im.group(2)) > best[1]:
                best = (im.group(1), int(im.group(2)))
        if best:
            out[name] = best[0]
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--gt", type=Path, required=True, help="path to the GT5-Unofficial checkout")
    a = ap.parse_args()
    OUT_ENTITY.mkdir(parents=True, exist_ok=True)
    OUT_ICON.mkdir(parents=True, exist_ok=True)

    fluid_extractor_lv_ev()      # first: the LV and MV fluid extractor are the source of its tiers
    forge_hammer_lv_mv()         # and the LV and MV forge hammer of the forge hammer's
    arc_furnace_lv_mv(a.gt)      # and the LV and MV arc furnace of the arc furnace's
    forming_press_lv_mv(a.gt)    # and the LV and MV forming press of the forming press's
    electric_furnace_lv_mv(a.gt) # and the LV and MV electric furnace of the electric furnace's
    sifting_machine_lv_mv(a.gt)  # and the LV and MV sifting machine of the sifting machine's
    thermal_centrifuge_lv_mv(a.gt)  # and the LV and MV thermal centrifuge of the thermal centrifuge's
    electromagnetic_separator_lv_mv(a.gt)  # and the LV and MV separator of the separator's
    brewery_lv_mv(a.gt)          # issue #360: the LV and MV brewery and fermenter of their tiers
    fermenter_lv_mv(a.gt)
    lv_from_mv("autoclave")      # before the autoclave's tiers (it reads the MV autoclave)
    steam_age(a.gt)              # issue #446
    battery_buffers(a.gt)        # issue #444
    lv_from_mv("extruder", icon=False)          # issue #449 (the LV extruder icon is upstream's)
    lv_from_mv("laser-engraver", icon_palette=True)
    lv_from_mv("combustion-generator", icon=False)   # (the LV icon is upstream's)
    for tier in ("IV", "LuV", "ZPM", "UV", "UHV", "UEV", "UIV", "UMV", "UXV", "MAX"):
        for base in BASIC_MACHINES + [FLUID_EXTRACTOR]:
            basic_machine(a.gt, base, tier)
    for name, spec in MULTIBLOCKS.items():
        multiblock(a.gt, name, *spec)
    for name, casing in iv_multiblock_casings().items():
        controller = name[3:] + "-controller"
        multiblock(a.gt, name, (3, 3), casing, controller, IV_MULTIBLOCK_FACES.get(name), None)
    for name in ICON_MACHINES:
        icon_machine(name)
    for name, spec in TEXTURE_ICONS.items():
        save(casing_tile(gt=a.gt, casing=name, override=spec), OUT_ICON / f"{name}.png")
    plasma_turbine(a.gt, PLASMA_TURBINE)
    for name, (face, tier) in STEAM_TURBINES.items():
        steam_turbine(a.gt, name, face, tier)
    for name, (tier, unit) in SUPERCAPACITORS.items():
        supercapacitor(a.gt, name, tier, unit)
    for base, tiers in TIER_COPIES.items():
        tier_copies(a.gt, base, tiers)
    for base, (sprite, icon) in UPGRADE_MULTIBLOCKS.items():
        upgrade_hatches(a.gt, base, sprite, icon)
    for name, (source, rgb) in DERIVED.items():
        derived(name, source, rgb)
    print("Sprites:", len(list(OUT_ENTITY.glob("*.png"))), "Icons:", len(list(OUT_ICON.glob("*.png"))))


if __name__ == "__main__":
    main()
