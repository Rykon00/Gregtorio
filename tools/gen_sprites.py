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
from PIL import Image, ImageOps

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
]
# issue #152: the Fluid Extractors are copies of the Extractor (151); from IV up they are drawn like the other basic
# machines from their LV and MV sprites (fluid_extractor_lv_ev), with the Extractor's frame count
FLUID_EXTRACTOR = "fluid-extractor"
EV_FRAMES_OF = {FLUID_EXTRACTOR: "extractor"}
# issue #170: the electric Forge Hammers LV to EV are made in a loop of 101 (no make_electric_machine("ev-forge-hammer"
# to read) and play the 5 frames of the Steam Forge Hammer's strip; their LV and MV sprites come from it
# (forge_hammer_lv_mv)
EV_FRAMES = {"forge-hammer": 5, "arc-furnace": 1, "forming-press": 1, "electric-furnace": 1,
             "sifting-machine": 4, "thermal-centrifuge": 1, "electromagnetic-separator": 4}
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
}
# multiblocks without an upstream item icon: the icon is the controller tile
CONTROLLER_ICONS = {"neutron-activator", "water-purification-plant", "uv-large-naquadah-reactor"}
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
    "microverse-projector": ("small-microverse-projector/small-microverse-projector", "small-microverse-projector"),
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
}
# items whose icon is a GT block texture (written to graphics/icons/fork/)
TEXTURE_ICONS = {
    "titanium-reinforced-borosilicate-glass-block": "bartworks:TitaniumReinforcedBoronSilicateGlassBlock",
    "tungstensteel-turbine-casing": "gregtech:iconsets/MACHINE_CASING_TURBINE_TUNGSTENSTEEL",
    "naquadah-reactor-casing": "gregtech:iconsets/NAQUADAH_REACTOR_CASING",
    # issue #97: kekztech's LuV and ZPM lapotronic capacitor blocks
    "lapotronic-capacitor-luv": "kekztech:LapotronicEnergyUnit2_side",
    "lapotronic-capacitor-zpm": "kekztech:LapotronicEnergyUnit3_side",
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
# issue #99: the ender tanks (name -> GT tier of the air collector they copy, tint of the ender fluid link)
ENDER_LINK = "gregtech:iconsets/ENDERFLUIDLINK_OVERLAY"
ENDER_TANKS = {
    "nether-air-ender-tank": ("HV", ((40, 0, 0), (255, 140, 70))),     # recoloured from dark red to glowing orange
    "ender-air-ender-tank": ("EV", None),                               # GT's teal as it is
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

    icons = [load(ICONS / f"{t}-{base}.png") for t in ("lv", "mv", "hv", "ev") if (ICONS / f"{t}-{base}.png").exists()]
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


def in_hull(hull, top, size):
    """the machine top (16 px) on the middle of a frame of the tier's hull: 3x3 hull tiles and the top on
    the middle 2x2 for a sprite, the hull at 2x and the top at 1x for an icon"""
    img = Image.new("RGBA", (size, size))
    step = size // 3 if size > TILE else size
    for y in range(0, size, step):
        for x in range(0, size, step):
            img.paste(scaled(hull, step), (x, y))
    inner = size * 2 // 3 if size > TILE else size // 2
    img.alpha_composite(scaled(top, inner), ((size - inner) // 2, (size - inner) // 2))
    return img


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


def recolour(img, dark, light):
    """the image's brightness as a ramp from `dark` to `light` (alpha kept)"""
    out = ImageOps.colorize(ImageOps.autocontrast(img.convert("L")), dark, light).convert("RGBA")
    out.putalpha(img.getchannel("A"))
    return out


def ender_tank(gt, name, tier, ramp):
    """Issue #99: the ender tanks (142-fork-recipe-unlocks.lua, copies of the HV and EV air collector): the GT hull of
    their tier around GT's ender fluid link (the tank of TecTech's ender fluid link cover, animated: the working
    strip), recoloured per air (nether red, ender as GT draws it), so they are no longer air collectors on the map."""
    hull = load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE"))
    frames = frames_of(load(gt_path(gt, ENDER_LINK)))
    if ramp:
        frames = [recolour(f, *ramp) for f in frames]
    save(in_hull(hull, frames[0], 3 * TILE), OUT_ENTITY / f"{name}-idle.png")
    save_strip([in_hull(hull, f, 3 * TILE) for f in frames], OUT_ENTITY / f"{name}-working.png")


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
    for name, (tier, ramp) in ENDER_TANKS.items():
        ender_tank(a.gt, name, tier, ramp)
    print("Sprites:", len(list(OUT_ENTITY.glob("*.png"))), "Icons:", len(list(OUT_ICON.glob("*.png"))))


if __name__ == "__main__":
    main()
