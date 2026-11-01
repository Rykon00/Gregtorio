#!/usr/bin/env python3
"""Issue #713: item icons from GT New Horizons' own rendering, for GregTech's own mods only.

The source is NEI's item panel icon dump of the GTNH client (NEI options -> Data Dumps -> Item Panel -> PNG, 64 x 64):
one PNG per item panel entry, named after the item's English display name (a second item of the same name gets "_2",
"_3", ...; the characters \\ / : * ? " < > | become "_"). A display name is joined to its mod and registry name through
the NEI recipe dump of #714 (recipeid.zip: every item stack with strId, Damage and Name). The texture dump of the same
client (`/texturedump`, one PNG per block registry name) tells which registry names are blocks.

Kept (the maintainer's licence rule): only items of GregTech's own mods, the mods in GT5-Unofficial (LGPL-3.0) -
GT_MODS below, taken from the asset folders of its repository. Every other mod's icons stay out (Minecraft, IC2,
Thaumcraft, ... and AE2, which never enters Gregtorio).

An icon is imported for a Gregtorio item when
  * its English name (locale/en: item-name, else entity-name) is the display name of exactly one item of the NEI dump
    and that item is of a GT mod (a name another mod shares, or several GT items share, is skipped), and the panel
    has exactly one PNG of that name;
  * the item is a block (casing, coil, glass, pipe casing, multiblock controller or structure block), whose rendered
    3D icon is the point of #713; left out are the tier hulls and machine casings (Gregtorio draws them in its tier
    colours, issue #148) and the tiered single-block machines and hatches of gt.blockmachines (same reason). Item
    icons (not blocks) are GT's flat textures already, the same picture GTNH shows.

Writes graphics/icons/gtnh/<item>.png (the 64 x 64 PNG as dumped), the manifest graphics/icons/GTNH-ICONS.tsv (one row
per file: its source) and prototypes/data/gtnh-icons.lua (FORK_GTNH_ICONS, applied in prototypes/199-fork-finalize.lua).
devcheck fails for a file without a manifest row, a row without a file, or an item that does not show its file.

    python tools/devcheck/devcheck.py check            # the item list and icons (section ICONS of .devcheck/last-run.log)
    python tools/import_gtnh_icons.py --panel <itempanel_icons> --recipes <recipeid.zip> --blocks <texturedump> \\
        --pack "GTNH daily 2026-10-28+804" --dumped 2026-11-01 [--skipped skipped.tsv]
"""
import argparse, collections, json, re, shutil, zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "graphics/icons/gtnh"
MANIFEST = ROOT / "graphics/icons/GTNH-ICONS.tsv"
LUA = ROOT / "prototypes/data/gtnh-icons.lua"
LOG = ROOT / ".devcheck/last-run.log"
# GT5-Unofficial's own mods (src/main/resources/assets; FML mod IDs as NEI writes them); its asset folders minecraft,
# ic2, forestry, stevescarts, spiceoflife and gtceu are other mods' textures and do not count
GT_MODS = {"gregtech", "miscutils", "bartworks", "GoodGenerator", "tectech", "gtnhlanth", "kekztech", "kubatech",
           "gtnhintergalactic", "ggfab", "galacticgreg", "detravscannermod", "gtneioreplugin"}
TIERS = "ulv|lv|mv|hv|ev|iv|luv|zpm|uv|uhv|uev|uiv|umv|uxv|max"
HULL = re.compile(rf"^({TIERS})-machine-(casing|hull)$")
# gt.blockmachines: the tiered single-block machines and the hatches and buses (Gregtorio draws them in tier colours)
SINGLE = re.compile(rf"^({TIERS})-|hatch|-bus$|dynamo")
STACK = re.compile(rb'"Damage":(-?\d+),"Name":"((?:[^"\\]|\\.)*)","strId":"([^"]+)"')


def locale():
    out = collections.defaultdict(dict)
    for f in sorted((ROOT / "locale/en").glob("*.cfg")):
        sec = None
        for line in f.read_text(encoding="utf-8").splitlines():
            if line.startswith("[") and line.endswith("]"):
                sec = line[1:-1]
            elif "=" in line and sec and not line.startswith((";", "#")):
                k, v = line.split("=", 1)
                out[sec].setdefault(k.strip(), v)
    return out


def plain(s):
    return re.sub(r"\[[a-z-]+=[^\]]*\]\s*", "", s).strip()


def item_icons():
    """{item: icon} of the section ICONS of the last devcheck run"""
    icons, on = {}, False
    for line in LOG.read_text(encoding="utf-8", errors="replace").splitlines():
        if "DEVCHECK-ICONS-BEGIN" in line:
            on = True
        elif line.startswith("DEVCHECK-ICONS-END"):
            break
        elif on:
            p = line.split("\t")
            if len(p) >= 3 and p[0] == "item":
                icons[p[1]] = p[2]
    if not icons:
        raise SystemExit(f"no section ICONS in {LOG}: run `devcheck.py check` first")
    return icons


def dump_names(path):
    """{display name: {(strId, meta)}} of every item stack in the NEI recipe dump"""
    names = collections.defaultdict(set)
    with zipfile.ZipFile(path) as z:
        for info in z.infolist():
            if info.filename.endswith(".json"):
                with z.open(info) as f:
                    for line in f:
                        for m in STACK.finditer(line):
                            names[json.loads(b'"' + m.group(2) + b'"')].add((m.group(3).decode(), int(m.group(1))))
    return names


def panel_file(name):
    return re.sub(r'[\\/:*?"<>|]', "_", name)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--panel", required=True, help="NEI's item panel icon dump (dumps/itempanel_icons)")
    ap.add_argument("--recipes", required=True, help="the NEI recipe dump of #714 (recipeid.zip)")
    ap.add_argument("--blocks", required=True, help="the /texturedump folder (one PNG per block registry name)")
    ap.add_argument("--pack", required=True, help='the GTNH version, e.g. "GTNH daily 2026-10-28+804"')
    ap.add_argument("--dumped", required=True, help="the date of the dump (YYYY-MM-DD)")
    ap.add_argument("--skipped", help="write every skipped Gregtorio item with its reason to this TSV")
    a = ap.parse_args()
    panel = {p.name for p in Path(a.panel).glob("*.png")}
    blocks = {p.stem for p in Path(a.blocks).glob("*.png")}
    loc, icons, names = locale(), item_icons(), dump_names(a.recipes)

    take, skip, why = [], [], collections.Counter()
    for item in sorted(icons):
        raw = loc["item-name"].get(item) or loc["entity-name"].get(item)
        n = plain(raw) if raw else ""
        stacks = names.get(n) if n else None
        mods = {s.split(":")[0] for s, _ in stacks or ()}
        f = panel_file(n) + ".png"
        reason = None
        if not n:
            reason = "no English name"
        elif not stacks:
            reason = "name not in the NEI dump"
        elif not mods & GT_MODS:
            reason = "not an item of a GT mod"
        elif not mods <= GT_MODS:
            reason = "another mod's item has the same name"
        elif len(stacks) > 1:
            reason = "several GT items have the same name"
        elif f not in panel:
            reason = "no panel icon (the panel hides it)"
        elif panel_file(n) + "_2.png" in panel:
            reason = "several panel icons of that name"
        else:
            s, meta = next(iter(stacks))
            mod, reg = s.split(":", 1)
            if f"{mod}_{reg}" not in blocks:
                reason = "an item, not a block (GT's flat texture already)"
            elif HULL.match(item):
                reason = "tier hull or machine casing (Gregtorio's tier colours)"
            elif reg == "gt.blockmachines" and SINGLE.search(item):
                reason = "tiered single-block machine or hatch (Gregtorio's tier colours)"
            else:
                take.append((item, n, mod, reg, meta, f))
        if reason:
            why[reason] += 1
            skip.append((item, n, reason))

    OUT.mkdir(parents=True, exist_ok=True)
    keep = {f"{t[0]}.png" for t in take}
    for old in OUT.glob("*.png"):
        if old.name not in keep:
            old.unlink()
    for item, n, mod, reg, meta, f in take:
        shutil.copyfile(Path(a.panel) / f, OUT / f"{item}.png")
    rows = ["file\titem\tdisplay name\tmod id\tregistry name\tmeta\tdumped\tpack"]
    rows += [f"gtnh/{t[0]}.png\t{t[0]}\t{t[1]}\t{t[2]}\t{t[3]}\t{t[4]}\t{a.dumped}\t{a.pack}" for t in take]
    MANIFEST.write_text("\n".join(rows) + "\n", encoding="utf-8")
    lua = ["--- Generated by tools/import_gtnh_icons.py (issue #713): items whose icon is GT New Horizons' rendered",
           "--- icon in graphics/icons/gtnh/ (sources in graphics/icons/GTNH-ICONS.tsv); applied in",
           "--- prototypes/199-fork-finalize.lua. Do not edit.", "FORK_GTNH_ICONS = {"]
    lua += [f'\t["{t[0]}"] = true,' for t in take] + ["}"]
    LUA.write_text("\n".join(lua) + "\n", encoding="utf-8")
    if a.skipped:
        Path(a.skipped).write_text("item\tEnglish name\treason\n" + "".join(f"{i}\t{n}\t{r}\n" for i, n, r in skip),
                                   encoding="utf-8")
    print(f"{len(icons)} items: {len(take)} icons imported")
    for r, c in sorted(why.items(), key=lambda x: -x[1]):
        print(f"  {c:5}  {r}")
    print(collections.Counter(t[2] for t in take))


if __name__ == "__main__":
    main()
