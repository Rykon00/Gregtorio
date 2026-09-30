#!/usr/bin/env python3
"""Contact sheets to review graphics changes without starting the game (issues #40, #41).

Every entry shows the file at a git ref ("before", default origin/main) next to the working copy
("after"), with its name, grouped by line. Icons are drawn at 64x64 on a dark background; entity
sprites at up to 192 pixels.

    python tools/gen_review_sheet.py icons                  # the items of tools/gt-icon-items.txt
    python tools/gen_review_sheet.py techs                  # changed technology icons
    python tools/gen_review_sheet.py sprites                # changed entity sprites
    python tools/gen_review_sheet.py all --ref origin/main --out docs/graphics-review

Output: <out>/icons-<n>-<group>.png, techs.png, sprites-<n>-<group>.png
"""
import argparse, io, re, subprocess, warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
BG, PANEL, TEXT, DIM = (34, 34, 38), (52, 52, 58), (235, 235, 235), (150, 150, 160)

# (group title, regex on the item name); the first match wins
ICON_GROUPS = [
    ("Tier components", r"^(luv|zpm|uv|uhv|uev|uiv|umv|uxv)-(motor|pump|conveyor-module|piston|robot-arm|emitter|sensor|field-generator)$"),
    ("Casings, hulls and power hatches", r"^(luv|zpm|uv|uhv|uev|uiv|umv|uxv)-(machine-casing|machine-hull|energy-hatch|dynamo-hatch|circuit)$"),
    ("Wetware line and stem cells", r"^(wetware-|stem-cells|neuro-)"),
    ("Bio line", r"^(bio-|bioware-)"),
    ("Optical line", r"^optical-"),
    ("Exotic line", r"^exotic-"),
    ("Temporal line", r"^temporal-"),
    ("Crystal chips and boards", r"crystal|multilayered"),
    ("Water purification: wafers, power ICs, SMDs, catalyst", r"wafer$|power-ic$|integrated-circuit$|^complex-smd|quark"),
    ("Chip and SMD wraps", r"-wrap$"),
    ("Fusion", r"^fusion-|^advanced-fusion"),
    ("Coils", r"coil"),
    ("Power: plutonium, cells, storage, turbines, reactors", r"plutonium|space-cell|coolant|energy|lapotronic|sludge|turbine|naquadah-reactor"),
    ("Stargate parts", r"^stargate-"),
    ("Multiblocks", r"assembly-line|bacterial-vat"),
    ("Endgame materials (issue #36)", r"fluxed-electrum|bedrockium|quantium|callisto"),
    ("Superconductors", r"superconduct|itbtc|palladium-naqindium|naquamiridium|triamerotronium|dracofinium|chromnorox|hypocosmium|eternity"),
    ("UEV to UXV metals", r"cosmic-neutronium|draconium|infinity|transcendent|spacetime|universium|rhugnor|nether-star"),
    ("UV and UHV metals", r"neutronium|tritanium|naquadah|naquadria|americium|europium|trinium|osmiridium|ruridit|rhodium"),
    ("Other materials", r"."),
]


def font(size):
    for f in ("DejaVuSans.ttf", "arial.ttf", "segoeui.ttf"):
        try:
            return ImageFont.truetype(f, size)
        except OSError:
            pass
    return ImageFont.load_default()


def at_ref(ref, rel):
    r = subprocess.run(["git", "show", f"{ref}:{rel}"], cwd=ROOT, capture_output=True)
    return Image.open(io.BytesIO(r.stdout)).convert("RGBA") if r.returncode == 0 else None


def now(rel):
    p = ROOT / rel
    return Image.open(p).convert("RGBA") if p.exists() else None


def first_frame(img, w=None, h=None):
    if img is None:
        return None
    w = w or img.width
    h = h or min(img.height, w)
    return img.crop((0, 0, w, h))


def cell(img, box):
    """img scaled into a box x box square: pixel-exact where it fits, else smooth"""
    out = Image.new("RGBA", (box, box), PANEL + (255,))
    if img is None:
        ImageDraw.Draw(out).line([(0, 0), (box, box)], fill=(120, 60, 60), width=2)
        return out
    f = box / max(img.size)
    size = (max(1, int(img.width * f)), max(1, int(img.height * f)))
    img = img.resize(size, Image.NEAREST if f >= 1 and f == int(f) else Image.LANCZOS)
    out.alpha_composite(img, ((box - size[0]) // 2, (box - size[1]) // 2))
    return out


def sheet(title, entries, box, cols, path):
    """entries: (name, before, after); one row of cols pairs"""
    ft, fn = font(20), font(12)
    cw, ch = 2 * box + 24, box + 22
    rows = (len(entries) + cols - 1) // cols
    img = Image.new("RGBA", (cols * cw + 16, rows * ch + 56), BG + (255,))
    d = ImageDraw.Draw(img)
    d.text((10, 8), title, fill=TEXT, font=ft)
    d.text((10, 32), "left: before (main)   right: after", fill=DIM, font=fn)
    for i, (name, before, after) in enumerate(entries):
        x, y = 8 + (i % cols) * cw, 52 + (i // cols) * ch
        img.alpha_composite(cell(before, box), (x, y))
        img.alpha_composite(cell(after, box), (x + box + 4, y))
        label = name if len(name) <= (cw // 7) else name[: cw // 7 - 1] + "…"
        d.text((x, y + box + 3), label, fill=TEXT, font=fn)
    img.convert("RGB").save(path, optimize=True)
    print("written", path)


def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")[:40]


def icons(ref, out):
    names = [l.split("#")[0].strip() for l in (ROOT / "tools/gt-icon-items.txt").read_text().splitlines()]
    groups = {}
    for n in filter(None, names):
        g = next(t for t, rx in ICON_GROUPS if re.search(rx, n))
        groups.setdefault(g, []).append(n)
    k = 0
    for title, _ in ICON_GROUPS:
        if title not in groups:
            continue
        k += 1
        rel = lambda n: f"graphics/icons/{n}.png"
        entries = [(n, at_ref(ref, rel(n)), now(rel(n))) for n in groups[title]]
        sheet(f"Item icons: {title} ({len(entries)})", entries, 64, 6, out / f"icons-{k:02d}-{slug(title)}.png")


def changed(ref, pattern):
    r = subprocess.run(["git", "diff", "--name-only", ref, "--", pattern], cwd=ROOT, capture_output=True, text=True)
    r2 = subprocess.run(["git", "ls-files", "--others", "--exclude-standard", "--", pattern], cwd=ROOT,
                        capture_output=True, text=True)
    return sorted(set(r.stdout.split()) | set(r2.stdout.split()))


def techs(ref, out):
    files = [f for f in changed(ref, "graphics/technology/fork/*.png") if f.endswith(".png")]
    entries = [(Path(f).stem, at_ref(ref, f), now(f)) for f in files]
    for i in range(0, len(entries), 60):
        sheet(f"Technology icons ({len(entries)}, part {i // 60 + 1})", entries[i:i + 60], 64, 6,
              out / f"techs-{i // 60 + 1}.png")


def sprites(ref, out):
    files = [f for f in changed(ref, "graphics/entity/fork/*.png") if f.endswith("-idle.png") or
             (f.endswith("-working.png") and not Path(f.replace("-working", "-idle")).exists())]
    groups = {}
    for f in files:
        n = Path(f).stem
        g = ("Fusion reactors" if "fusion" in n else "Large plasma turbines" if "plasma-turbine" in n else
             "Large naquadah reactors" if "naquadah-reactor" in n else "Basic machines " + n.split("-")[0].upper())
        groups.setdefault(g, []).append(f)
    for k, (title, fs) in enumerate(sorted(groups.items()), 1):
        entries = []
        for f in fs:
            b, a = at_ref(ref, f), now(f)
            # basic machines: idle frame; working strips: first frame
            entries.append((Path(f).stem, first_frame(b), first_frame(a)))
            w = f.replace("-idle.png", "-working.png")
            if w != f and (ROOT / w).exists():
                entries.append((Path(w).stem, first_frame(at_ref(ref, w)), first_frame(now(w))))
        box = 192 if "Fusion" in title or "naquadah" in title else 128 if "turbine" in title else 96
        sheet(f"Entity sprites: {title}", entries, box, 4 if box > 128 else 6, out / f"sprites-{k:02d}-{slug(title)}.png")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("what", choices=["icons", "techs", "sprites", "all"])
    ap.add_argument("--ref", default="origin/main")
    ap.add_argument("--out", type=Path, default=ROOT / "docs/graphics-review")
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    for what, fn in (("icons", icons), ("techs", techs), ("sprites", sprites)):
        if a.what in (what, "all"):
            fn(a.ref, a.out)


if __name__ == "__main__":
    main()
