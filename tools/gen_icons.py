#!/usr/bin/env python3
"""Generates placeholder icons for items in the draft tiers (LuV+) that have none.

These are stand-ins: add the item to tools/gt-icon-items.txt and let tools/gen_gt_icons.py make the real
icon from GT textures (issue #40); every item that had a placeholder so far has one.

For every missing icon a "donor" icon is picked and recolored:
  * tier components (luv-motor) -> icon of the tier below (iv-motor), recolored in the tier color
  * metal parts (hsss-plate) -> same part of another material, tinted with the material color
  * otherwise the existing icon with the longest common name suffix
    (hot-atomic-separation-catalyst-ingot -> hot-...-ingot, thaumium-dust -> ...-dust)
The fallback color is derived from the name so items stay distinguishable.

    python tools/gen_icons.py name1 name2 ...
    python tools/gen_icons.py --from-file list.txt

Graphics with no GT texture and no donor are drawn here as code (issue #431: the cauldron, GTNH's is Minecraft's own
block, whose texture is not used); --drawn writes their icon and entity sprites (a file whose pixels did not change is
not rewritten):

    python tools/gen_icons.py --drawn
"""
import argparse, colorsys, hashlib, math, warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "graphics/icons"
TIERS = ["lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv"]
# GT tier colors (hue in degrees)
TIER_HUE = {"luv": 320, "zpm": 190, "uv": 130, "uhv": 0, "uev": 90, "uiv": 150, "umv": 260, "uxv": 45}


# explicit donors (icon to recolor, hue in degrees) where the longest-suffix guess picks a bad one
DONORS = {
    "gasoline-cell": ("diesel-cell", 50),   # issue #91
    # issue #355 step 2: Minecraft's ghast tear and the Twilight Forest's Ur-Ghast trophy and Fiery Tears vial (their
    # textures are not in the GT checkouts)
    "ghast-tear": ("ender-pearl", 200), "ur-ghast-trophy": ("wither-skull", 0), "fiery-tears": ("filled-soul-vial-enderman", 15),
    # issue #355 step 4: Chisel's neonite (not in the GT checkouts)
    "neonite": ("borosilicate-glass-block", 320),
    "npic-wafer": ("uhpic-wafer", 190), "ppic-wafer": ("uhpic-wafer", 130), "qpic-wafer": ("uhpic-wafer", 0),
    "nano-power-ic": ("ultra-high-powered-integrated-circuit", 190),
    "pico-power-ic": ("ultra-high-powered-integrated-circuit", 130),
    "quantum-power-ic": ("ultra-high-powered-integrated-circuit", 0),
    # issue #35: FPIC and APIC (UEV and UIV hue), complex SMDs, quark creation catalyst
    "fpic-wafer": ("uhpic-wafer", 90), "apic-wafer": ("uhpic-wafer", 150),
    "femto-power-ic": ("ultra-high-powered-integrated-circuit", 90),
    "atto-power-ic": ("ultra-high-powered-integrated-circuit", 150),
    "complex-smd-transistor": ("advanced-smd-transistor", 0), "complex-smd-resistor": ("advanced-smd-resistor", 0),
    "complex-smd-capacitor": ("advanced-smd-capacitor", 0), "complex-smd-diode": ("advanced-smd-diode", 0),
    "complex-smd-inductor": ("advanced-smd-inductor", 0),
    "quark-creation-catalyst": ("uev-field-generator", 300),
    # phase 5a metals: the ingots get a hue, their parts take the ingot color
    "cosmic-neutronium-ingot": ("neutronium-ingot", 275), "draconium-ingot": ("tritanium-ingot", 355),
    "infinity-ingot": ("tritanium-ingot", 45), "transcendent-metal-ingot": ("neutronium-ingot", 185),
    "dracofinium-ingot": ("tritanium-ingot", 330), "chromnorox-ingot": ("tritanium-ingot", 200),
    # phase 5b metals (spacetime and universium are the UMV and UXV metals, rhugnor a fusion melt)
    "spacetime-ingot": ("neutronium-ingot", 265), "universium-ingot": ("tritanium-ingot", 205),
    "rhugnor-ingot": ("tritanium-ingot", 320), "hypocosmium-ingot": ("tritanium-ingot", 290),
    # issue #36: quantium (the fluxed electrum and bedrockium ingots have upstream icons), the new dusts
    "quantium-ingot": ("neutronium-ingot", 285), "quantium-dust": ("naquadah-dust", 285),
    "callisto-ice-dust": ("naquadah-dust", 195), "fluxed-electrum-dust": ("naquadah-dust", 50),
    "wheat-seeds": ("wheat", 75),   # issue #360: the greenhouse wheat's seeds
    "mox-fuel": ("uranium-235-dust", 30),   # issue #359: IC2's MOX fuel (no IC2 texture here)
}


def existing():
    return {p.stem for p in ICONS.glob("*.png")}


def donor_for(name, have):
    tok = name.split("-")
    if tok[0] in TIERS:
        i = TIERS.index(tok[0])
        for j in range(i - 1, -1, -1):
            cand = "-".join([TIERS[j]] + tok[1:])
            if cand in have:
                return cand, TIER_HUE.get(tok[0])
    best, best_len = None, 0
    for h in sorted(have):
        ht = h.split("-")
        n = 0
        while n < min(len(ht), len(tok)) and ht[-1 - n] == tok[-1 - n]:
            n += 1
        if n > best_len:
            best, best_len = h, n
    if best is None:
        best = "nyi" if "nyi" in have else sorted(have)[0]
    return best, None


PART_TOKENS = {"plate", "rod", "long", "gear", "large", "frame", "ring", "bolt", "screw", "rotor", "round",
               "foil", "wire", "fine", "cable", "dust", "ingot", "nugget", "spring", "dense", "hot", "16x", "magnetic"}


def material_color(name, have):
    """Material color from its ingot/dust icon (for metal parts like hsss-plate)."""
    tok = [t for t in name.split("-") if t not in PART_TOKENS]
    if not tok or len(tok) == len(name.split("-")):
        return None
    mat = "-".join(tok)
    for cand in (f"{mat}-ingot", f"{mat}-dust", f"{mat}-plate"):
        if cand in have and cand != name:
            img = Image.open(ICONS / f"{cand}.png").convert("RGBA")
            px = [p for p in img.getdata() if p[3] > 128]
            if px:
                return tuple(sum(p[i] for p in px) // len(px) for i in range(3))
    return None


def colorize(img, rgb):
    """Like GT: multiply a grayscale template with the material color."""
    img = img.convert("RGBA")
    px = img.load()
    lums = [(0.3 * r + 0.59 * g + 0.11 * b) for r, g, b, a in img.getdata() if a > 16]
    mean = sum(lums) / len(lums) if lums else 128
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            l = (0.3 * r + 0.59 * g + 0.11 * b) / mean
            px[x, y] = tuple(min(255, int(c * l)) for c in rgb) + (a,)
    return img


def recolor(img, hue_deg):
    img = img.convert("RGBA")
    px = img.load()
    sat_px = 0
    total = 0
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            total += 1
            _, _, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
            if s > 0.25:
                sat_px += 1
    colorful = total and sat_px / total > 0.15
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if a < 16:
                continue
            h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
            if colorful:
                if s > 0.2:
                    h = hue_deg / 360
            else:
                h, s = hue_deg / 360, max(s, 0.45)
            nr, ng, nb = colorsys.hls_to_rgb(h, l, s)
            px[x, y] = (int(nr * 255), int(ng * 255), int(nb * 255), a)
    return img


# --- issue #431: the cauldron, drawn from scratch ---------------------------------------------------------------------
# An iron pot seen from the front above: a rim with a lip, a round belly, three short legs, lit from the upper left like
# the other 32 x 32 machine icons, with their 1 px dark outline. Shapes are ellipses tested at the pixel centres; the
# shading picks one of a few tones (pixel art, no smooth gradients).
ENTITY = ROOT / "graphics/entity/fork"
IRON = [(16, 16, 19), (31, 31, 35), (44, 44, 50), (58, 58, 65), (74, 74, 82), (93, 93, 102), (118, 118, 128)]
WATER = [(20, 46, 102), (30, 70, 140), (46, 100, 178), (84, 146, 214), (176, 214, 246)]
CAULDRON_CX, CAULDRON_RIM_Y, CAULDRON_RIM_RX, CAULDRON_RIM_RY = 16, 9.5, 13.5, 5.0
CAULDRON_HOLE_RX, CAULDRON_HOLE_RY = 10.5, 3.3
CAULDRON_BELLY_Y, CAULDRON_BELLY_RX, CAULDRON_BELLY_RY = 16.5, 14.0, 11.0
CAULDRON_LEGS = [(5, 9, 23, 29), (23, 27, 23, 29), (14, 18, 26, 31)]   # x0, x1, y0, y1: pixel columns and rows [0, 1)
CAULDRON_FRAMES = 4   # the working strip: the glints on the water drift one pixel a frame


def tone(palette, s):
    return palette[max(0, min(len(palette) - 1, int(round(s * (len(palette) - 1)))))] + (255,)


def in_ellipse(x, y, ex, ey, rx, ry):
    return ((x - ex) / rx) ** 2 + ((y - ey) / ry) ** 2 <= 1


def cauldron_part(x, y):
    cx, rim_y, X, Y = CAULDRON_CX, CAULDRON_RIM_Y, x + 0.5, y + 0.5
    if in_ellipse(X, Y, cx, rim_y, CAULDRON_HOLE_RX, CAULDRON_HOLE_RY):
        return "hole"
    if in_ellipse(X, Y, cx, rim_y, CAULDRON_RIM_RX, CAULDRON_RIM_RY):
        return "rim"
    if any(in_ellipse(X, Y, cx, rim_y + d, CAULDRON_RIM_RX, CAULDRON_RIM_RY) for d in (0.5, 1.0, 1.5)):
        return "lip"
    if Y >= rim_y and in_ellipse(X, Y, cx, CAULDRON_BELLY_Y, CAULDRON_BELLY_RX, CAULDRON_BELLY_RY):
        return "body"
    if any(x0 <= x < x1 and y0 <= y < y1 for x0, x1, y0, y1 in CAULDRON_LEGS):
        return "leg"
    return None


def draw_cauldron(frame=None):
    """32 x 32 RGBA: the empty pot (frame None), or with water and the glints of that frame"""
    cx, rim_y = CAULDRON_CX, CAULDRON_RIM_Y
    water = (cx, rim_y + 0.9, CAULDRON_HOLE_RX - 0.6, CAULDRON_HOLE_RY - 0.5)
    parts = {(x, y): cauldron_part(x, y) for y in range(32) for x in range(32)}
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for (x, y), p in parts.items():
        X, Y = x + 0.5, y + 0.5
        if p is None:
            continue
        if p == "rim":     # the top of the rim, the lightest part
            s = 0.8 - 0.25 * (X - cx) / CAULDRON_RIM_RX - 0.1 * (Y - rim_y) / CAULDRON_RIM_RY
        elif p == "lip":   # the outer face of the rim
            s = 0.55 - 0.4 * (X - cx) / CAULDRON_RIM_RX
        elif p == "body":  # round belly: light on the left, a highlight band, dark below and under the lip
            half = CAULDRON_BELLY_RX * math.sqrt(max(0.0, 1 - ((Y - CAULDRON_BELLY_Y) / CAULDRON_BELLY_RY) ** 2)) or 1
            n = (X - cx) / half
            s = 0.5 - 0.32 * n - 0.35 * max(0.0, (Y - 18) / 9)
            if -0.8 < n < -0.45 and Y < 21:
                s += 0.17
            if parts.get((x, y - 1)) == "lip":
                s -= 0.3
        elif p == "leg":
            x0 = next(l[0] for l in CAULDRON_LEGS if l[0] <= x < l[1])
            s = 0.5 if x == x0 + 1 else 0.3
        else:              # the inside: the far wall lit, darker towards the front
            v = (Y - (rim_y - CAULDRON_HOLE_RY)) / (2 * CAULDRON_HOLE_RY)
            s = 0.36 - 0.3 * v + 0.08 * (cx - X) / CAULDRON_HOLE_RX
        px[x, y] = tone(IRON, s)
        if p == "hole" and frame is not None and in_ellipse(X, Y, *water):
            px[x, y] = tone(WATER, 0.55 - 0.25 * (X - cx) / CAULDRON_HOLE_RX - 0.1 * (Y - rim_y) / CAULDRON_HOLE_RY)
    out = img.copy()
    o = out.load()
    for (x, y), p in parts.items():
        if p is None:
            continue
        nb = [parts.get((x + dx, y + dy)) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
        if None in nb:
            o[x, y] = IRON[0] + (255,)          # the outline
        elif p == "hole" and "rim" in nb and y + 0.5 < rim_y:
            o[x, y] = IRON[1] + (255,)          # the shadow of the far rim on the inside
    if frame is not None:
        glint = (water[0], water[1], water[2] - 0.6, water[3] - 0.3)
        for gx, gy, length in ((10, 10, 3), (17, 11, 2)):
            for i in range(length):
                x = gx + (frame + i) % 8
                if parts.get((x, gy)) == "hole" and in_ellipse(x + 0.5, gy + 0.5, *glint):
                    o[x, gy] = WATER[-1] + (255,)
    return out


# --- issue #501: the Nether Portal and the Flint and Steel, drawn from scratch -----------------------------------------
# The portal seen from above, a 3 x 3 tile pad (Minecraft's frame lies flat in Factorio's top-down view): a ring of
# obsidian blocks with their bevels around a purple swirl. Drawn at 32 px per tile, the sprite scaled 2x (nearest).
OBSIDIAN = [(10, 6, 16), (20, 12, 30), (32, 20, 48), (46, 32, 66), (70, 52, 96)]
PORTAL = [(58, 10, 110), (88, 22, 156), (122, 44, 196), (160, 86, 228), (210, 160, 250)]
STEEL = [(36, 38, 44), (70, 74, 84), (112, 118, 130), (168, 174, 186), (220, 224, 232)]
FLINT = [(24, 24, 26), (44, 44, 48), (66, 66, 72), (96, 96, 104)]


def draw_portal(size):
    """size x size RGBA: the obsidian ring (a fifth of the side) and the swirl inside"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    c, ring = size / 2, max(2, size // 5)
    block = max(2, ring)
    for y in range(size):
        for x in range(size):
            X, Y = x + 0.5, y + 0.5
            inner = ring <= x < size - ring and ring <= y < size - ring
            if not inner:
                bx, by = x % block, y % block
                s = 0.55 + (0.3 if bx == 0 or by == 0 else 0) - (0.35 if bx == block - 1 or by == block - 1 else 0)
                s += 0.08 * (((x // block) * 7 + (y // block) * 3) % 3 - 1)
                px[x, y] = tone(OBSIDIAN, s)
            else:
                dx, dy = (X - c) / (c - ring), (Y - c) / (c - ring)
                r = math.hypot(dx, dy)
                a = math.atan2(dy, dx)
                s = 0.5 + 0.35 * math.sin(3 * a + 7 * r) - 0.25 * r
                px[x, y] = tone(PORTAL, s)
    for i in range(size):   # the outline
        for x, y in ((i, 0), (i, size - 1), (0, i), (size - 1, i)):
            px[x, y] = OBSIDIAN[0] + (255,)
    return img


def draw_flint_and_steel():
    """32 x 32 RGBA: a dark flint (lower left) and a steel striker ring (upper right), each with its outline"""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for y in range(32):
        for x in range(32):
            X, Y = x + 0.5, y + 0.5
            if in_ellipse(X, Y, 11, 21, 8.5, 6.5):            # the flint
                s = 0.7 - 0.06 * (X - 6) - 0.04 * (Y - 16)
                px[x, y] = tone(FLINT, s)
            ring = in_ellipse(X, Y, 20, 12, 9.5, 8) and not in_ellipse(X, Y, 20, 12.5, 5.5, 4.2)
            if ring and not (Y > 16 and 15 < X < 25):            # the striker, open at the bottom
                px[x, y] = tone(STEEL, 0.75 - 0.05 * (X - 12) - 0.03 * (Y - 5))
    out = img.copy()
    o = out.load()
    for y in range(32):
        for x in range(32):
            if px[x, y][3] and any(not (0 <= x + dx < 32 and 0 <= y + dy < 32) or px[x + dx, y + dy][3] == 0
                                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                o[x, y] = (12, 12, 14, 255)
    return out


GRASS = [(30, 62, 26), (44, 88, 36), (62, 116, 46), (88, 146, 62), (124, 176, 86)]
TWILIGHT = [(16, 22, 60), (30, 40, 96), (52, 66, 140), (86, 104, 186), (150, 170, 232)]
FLOWERS = [(214, 46, 46), (240, 210, 60), (236, 236, 240)]
CRYSTAL = [(40, 30, 96), (70, 62, 156), (104, 104, 210), (150, 160, 240), (214, 224, 255)]


def draw_twilight_portal(size):
    """size x size RGBA: GTNH's 2x2 pool of the Twilight Portal, a grass border with 12 flowers (a quarter of the side)
    and the lit pool inside"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    c, ring = size / 2, max(2, size // 4)
    for y in range(size):
        for x in range(size):
            X, Y = x + 0.5, y + 0.5
            if ring <= x < size - ring and ring <= y < size - ring:
                dx, dy = (X - c) / (c - ring), (Y - c) / (c - ring)
                s = 0.45 + 0.3 * math.sin(5 * dx + 3 * dy) * math.cos(4 * dy - 2 * dx) - 0.2 * math.hypot(dx, dy)
                px[x, y] = tone(TWILIGHT, s)
            else:
                px[x, y] = tone(GRASS, 0.55 + 0.12 * (((x * 5 + y * 3) % 7) / 6 - 0.5))
    #  the 12 flowers: one in each cell of the 4x4 ring around the 2x2 pool
    f, cell = max(1, size // 16), size / 4
    seen = [((i + 0.5) * cell, (j + 0.5) * cell) for j in range(4) for i in range(4) if i in (0, 3) or j in (0, 3)]
    for i, (u, t) in enumerate(seen):
        col = FLOWERS[i % len(FLOWERS)] + (255,)
        for y in range(int(t - f), int(t + f) + 1):
            for x in range(int(u - f), int(u + f) + 1):
                if 0 <= x < size and 0 <= y < size and (x - u + 0.5) ** 2 + (y - t + 0.5) ** 2 <= (f + 0.3) ** 2:
                    px[x, y] = col
    for i in range(size):   # the outline
        for x, y in ((i, 0), (i, size - 1), (0, i), (size - 1, i)):
            px[x, y] = GRASS[0] + (255,)
    return img


def draw_twilight_crystal():
    """32 x 32 RGBA: an upright blue-violet crystal (a hexagon of facets), lit from the upper left, with its outline"""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for y in range(32):
        for x in range(32):
            X, Y = x + 0.5, y + 0.5
            w = 9 - abs(Y - 16) * 0.55 if abs(Y - 16) > 8 else 9
            if abs(X - 16) <= w and 2 <= Y <= 30:
                facet = 0.85 if X < 13 else (0.55 if X < 19 else 0.3)
                px[x, y] = tone(CRYSTAL, facet - 0.012 * (Y - 2))
    out = img.copy()
    o = out.load()
    for y in range(32):
        for x in range(32):
            if px[x, y][3] and any(not (0 <= x + dx < 32 and 0 <= y + dy < 32) or px[x + dx, y + dy][3] == 0
                                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                o[x, y] = (14, 10, 30, 255)
    return out


END_FRAME = [(64, 84, 70), (96, 120, 98), (150, 170, 128), (196, 204, 150), (226, 228, 182)]
END_EYE = [(20, 60, 40), (40, 110, 70), (80, 170, 110), (160, 230, 170)]
END_SKY = [(4, 6, 12), (10, 16, 28), (22, 34, 54)]


def draw_end_portal(size):
    """size x size RGBA: Minecraft's End Portal, a 5x5 grid: 12 frame blocks (3 per side, the corners empty) each with an
    Eye of Ender, the 3x3 starry void inside"""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = img.load()
    cell = size / 5
    for y in range(size):
        for x in range(size):
            i, j = int(x // cell), int(y // cell)
            u, v = (x % cell) / cell, (y % cell) / cell
            if 1 <= i <= 3 and 1 <= j <= 3:
                h = (x * 73 + y * 151) % 97
                px[x, y] = (230, 240, 255, 255) if h == 0 else tone(END_SKY, 0.3 + 0.35 * math.sin(x * 0.7 + y * 0.3))
            elif (i in (0, 4)) != (j in (0, 4)):
                s = 0.55 + (0.25 if u < 0.12 or v < 0.12 else 0) - (0.3 if u > 0.88 or v > 0.88 else 0)
                px[x, y] = tone(END_FRAME, s)
                if (u - 0.5) ** 2 + (v - 0.5) ** 2 <= 0.07:
                    px[x, y] = tone(END_EYE, 0.85 - 1.5 * math.hypot(u - 0.45, v - 0.45))
    return img


ENDER_BODY = [(14, 18, 22), (26, 34, 40), (40, 54, 60), (62, 82, 86), (96, 120, 120)]
ENDER_TRIM = [(30, 70, 60), (50, 120, 100), (90, 180, 150), (170, 230, 210)]
ENDER_CODE = [(240, 240, 240), (230, 128, 40), (190, 70, 190)]   # white, orange, magenta: three wool colours


def outline(img, colour):
    out = img.copy()
    px, o = img.load(), out.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            if px[x, y][3] and any(not (0 <= x + dx < w and 0 <= y + dy < h) or px[x + dx, y + dy][3] == 0
                                   for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))):
                o[x, y] = colour
    return out


def draw_ender_chest():
    """32 x 32 RGBA: EnderStorage's Ender Chest: a dark chest with green trim and the three-colour code on its lid"""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for y in range(6, 29):
        for x in range(3, 29):
            lid = y < 13
            s = 0.6 - 0.012 * (x - 3) - (0.15 if not lid else 0) + (0.2 if y in (6, 13) else 0)
            px[x, y] = tone(ENDER_BODY, s)
            if x in (3, 28) or y in (6, 28) or y == 13:
                px[x, y] = tone(ENDER_TRIM, 0.55)
    for i, c in enumerate(ENDER_CODE):   # the three colour buttons on the lid
        for y in range(8, 11):
            for x in range(8 + 6 * i, 12 + 6 * i):
                px[x, y] = c + (255,)
    for y in range(13, 18):   # the latch
        for x in range(14, 18):
            px[x, y] = tone(ENDER_TRIM, 0.85)
    return outline(img, (6, 8, 10, 255))


def draw_ender_tank():
    """32 x 32 RGBA: EnderStorage's Ender Tank: a dark tank with a green window and the three-colour code on top"""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for y in range(3, 30):
        for x in range(6, 26):
            s = 0.62 - 0.018 * (x - 6)
            px[x, y] = tone(ENDER_BODY, s)
            if x in (6, 25) or y in (3, 29, 8):
                px[x, y] = tone(ENDER_TRIM, 0.55)
    for y in range(11, 27):   # the window with the fluid
        for x in range(10, 22):
            px[x, y] = tone(ENDER_TRIM, 0.3 + 0.03 * (y - 11) if y > 16 else 0.15)
    for i, c in enumerate(ENDER_CODE):
        for y in range(4, 7):
            for x in range(9 + 5 * i, 12 + 5 * i):
                px[x, y] = c + (255,)
    return outline(img, (6, 8, 10, 255))


# --- issue #555: the torch, drawn from scratch (GTNH's is Minecraft's own, whose texture is not used): a wooden stick with
# a coal head and its flame, standing upright; the entity sprite is the icon scaled 2x (nearest), drawn at scale 0.5
WOOD = [(66, 42, 20), (96, 64, 32), (128, 88, 46), (158, 114, 64)]
COAL_HEAD = [(20, 18, 16), (40, 36, 32), (62, 56, 50)]
FLAME = [(196, 70, 14), (238, 128, 24), (252, 190, 48), (255, 236, 150), (255, 252, 226)]


def draw_torch():
    """32 x 32 RGBA: the stick (x 14..17, y 13..30), the coal head (y 10..12) and the flame above it"""
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    px = img.load()
    for y in range(13, 31):
        for x in range(14, 18):
            px[x, y] = tone(WOOD, 0.85 - 0.25 * (x - 14) - 0.01 * (y - 13))
    for y in range(10, 13):
        for x in range(14, 18):
            px[x, y] = tone(COAL_HEAD, 0.8 - 0.3 * (x - 14))
    for y in range(1, 11):
        for x in range(10, 22):
            X, Y = x + 0.5, y + 0.5
            if in_ellipse(X, Y, 16, 7.5, 4.2, 6.0) and not (Y < 4 and abs(X - 16) > 2.2):
                core = 1 - math.hypot((X - 16) / 4.2, (Y - 8.5) / 6.0)
                px[x, y] = tone(FLAME, 0.15 + 0.95 * core)
    return outline(img, (24, 14, 6, 255))


def save_if_changed(img, path):
    if path.exists():
        old = Image.open(path).convert("RGBA")
        if old.size == img.size and old.tobytes() == img.tobytes():
            return
    img.save(path, optimize=True)
    print("written", path.relative_to(ROOT))


def drawn():
    """the drawn graphics: icon, idle sprite (the empty pot) and working strip (water, vertical frames)"""
    idle = draw_cauldron()
    save_if_changed(idle, ICONS / "cauldron.png")
    save_if_changed(idle, ENTITY / "cauldron-idle.png")
    strip = Image.new("RGBA", (32, 32 * CAULDRON_FRAMES), (0, 0, 0, 0))
    for i in range(CAULDRON_FRAMES):
        strip.paste(draw_cauldron(i), (0, 32 * i))
    save_if_changed(strip, ENTITY / "cauldron-working.png")
    #  issue #501: the Nether Portal (icon and sprite) and the Flint and Steel
    save_if_changed(draw_portal(32), ICONS / "nether-portal.png")
    save_if_changed(draw_portal(96).resize((192, 192), Image.NEAREST), ENTITY / "nether-portal.png")
    save_if_changed(draw_flint_and_steel(), ICONS / "flint-and-steel.png")
    #  issue #502: the Twilight Portal (icon and sprite, 4x4) and the Twilight Crystal
    save_if_changed(draw_twilight_portal(32), ICONS / "twilight-portal.png")
    save_if_changed(draw_twilight_portal(128).resize((256, 256), Image.NEAREST), ENTITY / "twilight-portal.png")
    save_if_changed(draw_twilight_crystal(), ICONS / "twilight-crystal.png")
    #  issue #503: the End Portal (icon and sprite, 5x5)
    save_if_changed(draw_end_portal(32), ICONS / "end-portal.png")
    save_if_changed(draw_end_portal(160).resize((320, 320), Image.NEAREST), ENTITY / "end-portal.png")
    #  issue #504: the Ender Chest and the Ender Tank
    save_if_changed(draw_ender_chest(), ICONS / "ender-chest.png")
    save_if_changed(draw_ender_tank(), ICONS / "ender-tank.png")
    #  issue #555: the torch (icon and sprite)
    save_if_changed(draw_torch(), ICONS / "gt-torch.png")
    save_if_changed(draw_torch().resize((64, 64), Image.NEAREST), ENTITY / "gt-torch.png")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="*")
    ap.add_argument("--from-file", type=Path)
    ap.add_argument("--drawn", action="store_true", help="write the graphics drawn as code (issue #431)")
    a = ap.parse_args()
    if a.drawn:
        drawn()
    names = list(a.names)
    if a.from_file:
        names += [l.strip() for l in a.from_file.read_text().splitlines() if l.strip()]
    have = existing()
    for n in names:
        if n in have:
            continue
        donor, hue = DONORS.get(n) or donor_for(n, have)
        mc = material_color(n, have) if hue is None else None
        if mc:
            img = colorize(Image.open(ICONS / f"{donor}.png"), mc)
        else:
            if hue is None:
                hue = int(hashlib.md5(n.encode()).hexdigest()[:4], 16) % 360
            img = recolor(Image.open(ICONS / f"{donor}.png"), hue)
        img.save(ICONS / f"{n}.png")
        print(f"{n:55s} <- {donor}")


if __name__ == "__main__":
    main()
