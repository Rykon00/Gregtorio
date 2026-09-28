#!/usr/bin/env python3
"""Generates entity sprites and icons for the fork machines (prototypes/101-fork-machines.lua).

Sources:
  * GregTech 5 textures from a checkout of GTNewHorizons/GT5-Unofficial (LGPL-3.0)
  * existing Gregtorio icons (casings, controllers)

    python tools/gen_sprites.py --gt C:/00_Repositories/GT5-Unofficial

Output:
  graphics/entity/fork/<name>-idle.png / -working.png   (working = vertical frame strip)
  graphics/icons/fork/<name>.png                         (32x32)
"""
import argparse, re
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "graphics/icons"
OUT_ENTITY = ROOT / "graphics/entity/fork"
OUT_ICON = ROOT / "graphics/icons/fork"

TILE = 32          # Factorio pixels per tile in Gregtorio
BASIC_FRAMES = 6   # frames for basic machines (must match 101-fork-machines.lua)

# basic machine -> GT folder under textures/blocks/basicmachines (or an iconsets overlay)
BASIC_GT = {
    "wiremill": "wiremill", "bending-machine": "bender", "extruder": "extruder",
    "rock-crusher": "iconsets:OVERLAY_FRONT_ROCK_BREAKER", "lathe": "lathe", "macerator": "macerator",
    "centrifuge": "centrifuge", "air-collector": "pump", "extractor": "extractor",
    "electrolyzer": "electrolyzer", "assembling-machine": "assembler", "cutting-machine": "cutter",
    "canning-machine": "canner", "mixer": "mixer", "ore-washer": "ore_washer",
    "laser-engraver": "laser_engraver", "fluid-solidifier": "fluid_solidifier",
    "chemical-bath": "chemical_bath", "polarizer": "polarizer", "circuit-assembler": "circuitassembler",
    "autoclave": "autoclave", "alloy-smelter": "alloy_smelter", "compressor": "compressor",
}

# tier color GT uses to tint the (gray) machine casings (IV = tungstensteel)
TIER_TINT = {"IV": (100, 100, 160), "LuV": (255, 205, 225)}

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
}
# multiblocks without an upstream item icon: the icon is the controller tile
CONTROLLER_ICONS = {"neutron-activator"}
# items whose icon is a GT block texture (written to graphics/icons/fork/)
TEXTURE_ICONS = {
    "titanium-reinforced-borosilicate-glass-block": "bartworks:TitaniumReinforcedBoronSilicateGlassBlock",
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


def save_strip(frames, path):
    w, h = frames[0].size
    strip = Image.new("RGBA", (w, h * len(frames)))
    for i, f in enumerate(frames):
        strip.paste(f, (0, i * h))
    strip.save(path)


def tint(img, rgb):
    r, g, b = rgb
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            p = px[x, y]
            px[x, y] = (p[0] * r // 255, p[1] * g // 255, p[2] * b // 255, p[3])
    return img


def casing_tile(gt, casing, override=None):
    spec = override or CASING_TEXTURE.get(casing) or (casing if ":" in casing else None)
    if spec and gt_path(gt, spec).exists():
        return frames_of(load(gt_path(gt, spec)))[0].resize((TILE, TILE), Image.NEAREST)
    return scaled(load(ICONS / f"{casing}.png"), TILE)


def basic_machine(gt, base, tier="IV"):
    # Factorio is top-down: use the top face (MACHINE_TOP + OVERLAY_TOP), otherwise the front
    src = BASIC_GT[base]
    if src.startswith("iconsets:"):
        side = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), TIER_TINT[tier])
        front = gt_path(gt, "gregtech:iconsets/" + src.split(":", 1)[1])
        active = front.with_name(front.stem + "_ACTIVE.png")
    else:
        d = gt / "src/main/resources/assets/gregtech/textures/blocks/basicmachines" / src
        if (d / "OVERLAY_TOP.png").exists():
            side = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_TOP")), TIER_TINT[tier])
            front, active = d / "OVERLAY_TOP.png", d / "OVERLAY_TOP_ACTIVE.png"
        else:
            side = tint(load(gt_path(gt, f"gregtech:iconsets/MACHINE_{tier}_SIDE")), TIER_TINT[tier])
            front, active = d / "OVERLAY_FRONT.png", d / "OVERLAY_FRONT_ACTIVE.png"
    idle = side.copy()
    if front.exists():
        f = frames_of(load(front))[0]
        idle.alpha_composite(f.resize(idle.size, Image.NEAREST))
    act_frames = frames_of(load(active)) if active.exists() else [frames_of(load(front))[0]] if front.exists() else []
    working = []
    for i in range(BASIC_FRAMES):
        fr = side.copy()
        if act_frames:
            fr.alpha_composite(act_frames[i % len(act_frames)].resize(fr.size, Image.NEAREST))
        working.append(scaled(fr, 3 * TILE))
    name = f"{tier.lower()}-{base}"
    scaled(idle, 3 * TILE).save(OUT_ENTITY / f"{name}-idle.png")
    save_strip(working, OUT_ENTITY / f"{name}-working.png")
    scaled(idle, TILE).save(OUT_ICON / f"{name}.png")


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

    build(False).save(OUT_ENTITY / f"{name}-idle.png")
    build(True).save(OUT_ENTITY / f"{name}-working.png")
    if name in CONTROLLER_ICONS:
        # no upstream item icon: the controller tile
        img = build(False)
        cx, cy = w // 2, h - 1 if h > 3 else h // 2
        img.crop((cx * TILE, cy * TILE, (cx + 1) * TILE, (cy + 1) * TILE)).save(OUT_ICON / f"{name}.png")


def icon_machine(name):
    img = scaled(load(ICONS / f"{name}.png"), 3 * TILE)
    img.save(OUT_ENTITY / f"{name}-idle.png")
    img.save(OUT_ENTITY / f"{name}-working.png")


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

    for tier in ("IV", "LuV"):
        for base in BASIC_GT:
            basic_machine(a.gt, base, tier)
    for name, spec in MULTIBLOCKS.items():
        multiblock(a.gt, name, *spec)
    for name, casing in iv_multiblock_casings().items():
        controller = name[3:] + "-controller"
        multiblock(a.gt, name, (3, 3), casing, controller, IV_MULTIBLOCK_FACES.get(name), None)
    for name in ICON_MACHINES:
        icon_machine(name)
    for name, spec in TEXTURE_ICONS.items():
        casing_tile(gt=a.gt, casing=name, override=spec).save(OUT_ICON / f"{name}.png")
    print("Sprites:", len(list(OUT_ENTITY.glob("*.png"))), "Icons:", len(list(OUT_ICON.glob("*.png"))))


if __name__ == "__main__":
    main()
