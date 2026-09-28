#!/usr/bin/env python3
"""Generates placeholder icons for items in the draft tiers (LuV+) that have none.

For every missing icon a "donor" icon is picked and recolored:
  * tier components (luv-motor) -> icon of the tier below (iv-motor), recolored in the tier color
  * metal parts (hsss-plate) -> same part of another material, tinted with the material color
  * otherwise the existing icon with the longest common name suffix
    (hot-atomic-separation-catalyst-ingot -> hot-...-ingot, thaumium-dust -> ...-dust)
The fallback color is derived from the name so items stay distinguishable.

    python tools/gen_icons.py name1 name2 ...
    python tools/gen_icons.py --from-file list.txt
"""
import argparse, colorsys, hashlib, warnings
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
    "npic-wafer": ("uhpic-wafer", 190), "ppic-wafer": ("uhpic-wafer", 130), "qpic-wafer": ("uhpic-wafer", 0),
    "nano-power-ic": ("ultra-high-powered-integrated-circuit", 190),
    "pico-power-ic": ("ultra-high-powered-integrated-circuit", 130),
    "quantum-power-ic": ("ultra-high-powered-integrated-circuit", 0),
    # phase 5a metals: the ingots get a hue, their parts take the ingot color
    "cosmic-neutronium-ingot": ("neutronium-ingot", 275), "draconium-ingot": ("tritanium-ingot", 355),
    "infinity-ingot": ("tritanium-ingot", 45), "transcendent-metal-ingot": ("neutronium-ingot", 185),
    "dracofinium-ingot": ("tritanium-ingot", 330), "chromnorox-ingot": ("tritanium-ingot", 200),
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="*")
    ap.add_argument("--from-file", type=Path)
    a = ap.parse_args()
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
