#!/usr/bin/env python3
"""Contact sheets to review graphics changes without starting the game (issues #40, #41).

Every entry shows the file at a git ref ("before", default origin/main) next to the working copy
("after"), with its name, grouped by line. Icons are drawn at 64x64 on a dark background; entity
sprites at up to 192 pixels.

    python tools/gen_review_sheet.py icons                  # the items of tools/gt-icon-items.txt
    python tools/gen_review_sheet.py techs                  # changed technology icons
    python tools/gen_review_sheet.py sprites                # changed entity sprites
    python tools/gen_review_sheet.py upgrades               # IV to MAX upgrade multiblocks: EV look vs tier hatches
    python tools/gen_review_sheet.py fluid-icons            # changed fluid icons (graphics/fluids)
    python tools/gen_review_sheet.py fluids --fluids <file> # the Fluids tab, rows per subgroup (no before/after);
                                                            # <file> from `devcheck.py check --fluids-out <file>`
    python tools/gen_review_sheet.py all --ref origin/main --out docs/graphics-review

Output: <out>/icons-<n>-<group>.png, techs.png, sprites-<n>-<group>.png, upgrades-<tier>.png, upgrades-icons.png,
fluid-icons.png, fluids-tab.png
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
    ("Plasma forge and quantum force transformer (phase 6a)", r"^dimensional|^quantum-force"),
    ("MAX tier and godforge (phase 6b)", r"^max-|^maximum-|magmatter|^planck|^godforge|graviton|stellar"),
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


def fluid_icons(ref, out):
    """issue #99: the fluid icons that changed (the melts of issue #91 that were too dark)"""
    files = [f for f in changed(ref, "graphics/fluids/*.png") if f.endswith(".png")]
    if files:
        entries = [(Path(f).stem, at_ref(ref, f), now(f)) for f in files]
        sheet(f"Fluid icons ({len(entries)})", entries, 64, 6, out / "fluid-icons.png")


def sprites(ref, out):
    files = [f for f in changed(ref, "graphics/entity/fork/*.png") if f.endswith("-idle.png") or
             (f.endswith("-working.png") and not Path(f.replace("-working", "-idle")).exists())]
    groups = {}
    for f in files:
        n = Path(f).stem
        g = ("Fusion reactors" if "fusion" in n else "Large plasma turbines" if "plasma-turbine" in n else
             "Plasma forge and quantum force transformer" if n.startswith(("dimensional", "quantum-force")) else
             "Godforge" if n.startswith("godforge") else
             "Component assembly line" if n.startswith("component-assembly-line") else
             "Ender tanks" if "ender-tank" in n else
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


def upgrades(ref, out):
    """the upgrade multiblocks (gen_sprites.UPGRADE_MULTIBLOCKS): before = the EV sprite and icon every tier
    showed, after = the EV sprite with the tier's hatch layer and the badged icon"""
    from gen_sprites import UPGRADE_MULTIBLOCKS, UPGRADE_TIERS
    icons = []
    for tier in UPGRADE_TIERS:
        entries = []
        for base, (sprite, icon) in UPGRADE_MULTIBLOCKS.items():
            name = f"{tier.lower()}-{base}"
            ev = at_ref(ref, f"graphics/entity/{sprite}-idle.png")
            after, layer = now(f"graphics/entity/{sprite}-idle.png"), now(f"graphics/entity/fork/{name}-hatches.png")
            if after is not None and layer is not None:
                after.alpha_composite(layer)
            entries.append((name, ev, after))
            icons.append((name, at_ref(ref, f"graphics/icons/{icon}.png"), now(f"graphics/icons/fork/{name}.png")))
        sheet(f"Upgrade multiblocks {tier}: EV sprite + {tier} energy hatches", entries, 128, 5,
              out / f"upgrades-{tier.lower()}.png")
    by_base = sorted(icons, key=lambda e: [b for b in UPGRADE_MULTIBLOCKS if e[0].endswith("-" + b)][0])
    sheet("Upgrade multiblock icons IV to MAX (one row per multiblock)", by_base, 48, len(UPGRADE_TIERS),
          out / "upgrades-icons.png")


def locale_names(paths):
    """[fluid-name] entries of Factorio .cfg locale files"""
    names = {}
    for p in paths:
        section = None
        for line in p.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line.startswith("["):
                section = line.strip("[]")
            elif section == "fluid-name" and "=" in line:
                k, v = line.split("=", 1)
                names[k.strip()] = v.strip()
    return names


def fluids(listing, out, data_dir, cols=10):
    """The Fluids tab as the signal and fluid choosers show it: one block per subgroup (a subgroup starts a new
    row, a long one wraps after `cols` icons), in subgroup order, inside it in fluid order then name. Input: the
    list of `devcheck.py check --fluids-out`; vanilla icons and names come from the game's data folder."""
    rows = {}
    for line in Path(listing).read_text(encoding="utf-8").splitlines():
        name, sg, group, sg_order, hidden, param, order, icon, size = line.split("\t")
        if hidden == "true" or param == "true":
            continue
        rows.setdefault((group != "fluids", sg_order, sg), []).append((order, name, icon, int(float(size))))
    loc = locale_names(sorted((ROOT / "locale/en").glob("*.cfg"))
                       + [p for m in ("base", "space-age") for p in sorted((data_dir / m / "locale/en").glob("*.cfg"))])

    def icon_image(path, size):
        mod, rel = re.match(r"__([^_]+(?:_[^_]+)*)__/(.*)", path).groups()
        f = ROOT / rel if mod == "gregtorio-continued" else data_dir / mod / rel
        return Image.open(f).convert("RGBA").crop((0, 0, size, size)) if f.exists() else None

    box, cw, ch, head = 40, 112, 70, 26
    lines = sum(1 + (len(v) + cols - 1) // cols for v in rows.values())
    img = Image.new("RGBA", (cols * cw + 24, 64 + lines * ch - len(rows) * (ch - head)), BG + (255,))
    d = ImageDraw.Draw(img)
    ft, fh, fn = font(20), font(14), font(11)
    total = sum(len(v) for v in rows.values())
    d.text((10, 8), f"Fluids tab: {total} fluids in {len(rows)} rows (subgroups)", fill=TEXT, font=ft)
    d.text((10, 34), "one block per subgroup; Factorio's chooser starts a new row per subgroup and wraps long ones",
           fill=DIM, font=fn)
    y = 58
    for (outside, _, sg), entries in sorted(rows.items()):
        title = f"{sg}  ({len(entries)})" + ("  NOT IN THE FLUIDS TAB" if outside else "")
        d.line([(8, y + 2), (cols * cw + 16, y + 2)], fill=PANEL, width=1)
        d.text((10, y + 6), title, fill=(255, 120, 120) if outside else TEXT, font=fh)
        y += head
        for i, (_, name, icon, size) in enumerate(sorted(entries)):
            x, yy = 12 + (i % cols) * cw, y + (i // cols) * ch
            img.alpha_composite(cell(icon_image(icon, size), box), (x + (cw - box) // 2 - 6, yy))
            for k, text in enumerate((loc.get(name, name), name)):
                text = text if len(text) <= 18 else text[:17] + "…"
                tw = d.textlength(text, font=fn)
                d.text((x + (cw - tw) / 2 - 6, yy + box + 2 + k * 12), text, fill=TEXT if k == 0 else DIM, font=fn)
        y += ((len(entries) + cols - 1) // cols) * ch
    path = out / "fluids-tab.png"
    img.convert("RGB").save(path, optimize=True)
    print("written", path)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("what", choices=["icons", "techs", "sprites", "upgrades", "fluid-icons", "fluids", "all"])
    ap.add_argument("--ref", default="origin/main")
    ap.add_argument("--out", type=Path, default=ROOT / "docs/graphics-review")
    ap.add_argument("--fluids", help="fluids: the list of `devcheck.py check --fluids-out <file>`")
    ap.add_argument("--factorio-data", type=Path, default=ROOT / ".devcheck/factorio/data",
                    help="fluids: the game's data folder, for the vanilla icons and names")
    a = ap.parse_args()
    a.out.mkdir(parents=True, exist_ok=True)
    for what, fn in (("icons", icons), ("techs", techs), ("sprites", sprites), ("upgrades", upgrades),
                     ("fluid-icons", fluid_icons)):
        if a.what in (what, "all"):
            fn(a.ref, a.out)
    if a.what == "fluids" or (a.what == "all" and a.fluids):
        if not a.fluids:
            ap.error("fluids needs --fluids <file> (devcheck.py check --fluids-out <file>)")
        fluids(a.fluids, a.out, a.factorio_data)


if __name__ == "__main__":
    main()
