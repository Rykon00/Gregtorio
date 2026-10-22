#!/usr/bin/env python3
"""GTNH's ore veins as data (issue #496, plan #494): reads GT5-Unofficial's OreMixes.java, DimensionDef.java and
gtneioreplugin's DimensionHelper.java and writes prototypes/data/ore-mixes.lua.

Every mix of OreMixes.java in its order (id = its position, the id 165-fork-ore-veins.lua's generator uses), with GT's
weight, density, size, its dimensions and its four ores (primary, secondary, in between, sporadic) as Gregtorio's
material names: the raw ore is raw-<material>. GT's names are kept next to them. The dimensions are DimNames
constants (OW, NETHER, TWILIGHT_FOREST, THE_END, ...) with the name and the tier of DimensionHelper.java.
Issue #497: each mix's label is GT's localized name (OreMixBuilder.getLocalizedName: the primary ore and the materials of
setLocalizedName, joined by StringUtils.formatList), and the materials of GT's MaterialsInit.java have their English
name and colour (setDefaultLocalName, setARGB) for the map veins' resources.

    python tools/gen_ore_mixes.py --gt C:/00_Repositories/GT5-Unofficial [--ref f2814df]

With --ref the files are read from that commit of the checkout (git show), without it from the working tree.
"""
import argparse
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "prototypes/data/ore-mixes.lua"
FILES = {
    "mixes": "src/main/java/gregtech/api/enums/OreMixes.java",
    "defs": "src/main/java/galacticgreg/api/enums/DimensionDef.java",
    "helper": "src/main/java/gtneioreplugin/util/DimensionHelper.java",
    "materials": "src/main/java/gregtech/loaders/materials/MaterialsInit.java",
}
ROLES = ("primary", "secondary", "between", "sporadic")
GT_CALL = {"primary": "primary", "secondary": "secondary", "between": "inBetween", "sporadic": "sporadic"}

# GT material names whose Gregtorio material is not the kebab-case of the name
NAMES = {
    "Cooperite": "sheldonite", "Uranium": "uraninite", "NaquadahEnriched": "enriched-naquadah",
    "DraconiumAwakened": "awakened-draconium", "GarnetRed": "red-garnet", "GarnetYellow": "yellow-garnet",
    # bartworks' Werkstoffe (German names)
    "Bismuthinit": "bismuthinite", "Djurleit": "djurleite", "Fayalit": "fayalite", "Forsterit": "forsterite",
    "Hedenbergit": "hedenbergite", "Huebnerit": "huebnerite", "Loellingit": "loellingite", "Olenit": "olenite",
    "Roquesit": "roquesite", "Thorianit": "thorianite", "Wittichenit": "wittichenite",
    "FluorBuergerit": "fluor-buergerite", "ChromoAluminoPovondrait": "chromo-alumino-povondraite",
    "VanadioOxyDravit": "vanadio-oxy-dravite", "DescloiziteCUVO4": "red-descloizite",
    "DescloiziteZNVO4": "orange-descloizite", "FuchsitAL": "green-fuchsite", "FuchsitCR": "red-fuchsite",
    "BArTiMaEuSNeK": "bartimaeusnek",
    # GT++'s ores
    "CROCROITE": "crocoite", "FLUORITE": "fluorite-f", "RADIOBARITE": "barite-ra", "ZIRCONILITE": "zirconolite",
}


def material(gt):
    if gt in NAMES:
        return NAMES[gt]
    if gt.isupper() or "_" in gt:
        return gt.lower().replace("_", "-")
    return re.sub(r"(?<=[a-z0-9])(?=[A-Z])", "-", gt).lower()


def read(gt, ref, key):
    if ref:
        return subprocess.run(["git", "-C", str(gt), "show", f"{ref}:{FILES[key]}"], check=True, capture_output=True,
                              text=True, encoding="utf8").stdout
    return (Path(gt) / FILES[key]).read_text(encoding="utf8")


def dimensions(defs, helper):
    """DimensionDef enum name -> DimNames constant; DimNames constant -> (name, tier) of DimensionHelper"""
    enum = {m.group(1): m.group(2) for m in re.finditer(r"^\s*(\w+)\(new ModDimensionDef\(\s*DimNames\.(\w+)", defs, re.M)}
    reg = {}
    for m in re.finditer(r'register\(\s*"([^"]+)",\s*(\w+),\s*"([^"]+)",\s*"([^"]+)",\s*T(\d+)', helper):
        reg[m.group(2)] = (m.group(3), int(m.group(5)))
    return enum, reg


def gt_materials(src):
    """GT material name -> (English name, (r, g, b)) of MaterialsInit.java (the builder of each load function)"""
    out = {}
    for block in src.split("new MaterialBuilder()")[1:]:
        block = block[:block.find(";")]
        n = re.search(r'\.setName\("([^"]+)"', block)
        if not n:
            continue
        local = re.search(r'\.setDefaultLocalName\("([^"]+)"', block)
        c = re.search(r"\.setARGB\((0x[0-9a-fA-F]+)", block)
        v = int(c.group(1), 16) if c else 0xffffff
        out[n.group(1)] = (local.group(1) if local else n.group(1), ((v >> 16) & 255, (v >> 8) & 255, v & 255))
    return out


def split_name(gt):
    return gt.replace("_", " ").title() if gt.isupper() else re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", gt)


def format_list(names):
    """GT's StringUtils.formatList: "a, b & c\""""
    return ", ".join(names[:-1]) + (" & " if len(names) > 1 else "") + names[-1]


def mixes(src, enum):
    body = src[src.index("public enum OreMixes {"):]
    starts = list(re.finditer(r"^    (\w+)\(new OreMixBuilder\(\)", body, re.M))
    out = []
    for i, m in enumerate(starts):
        text = body[m.end():(starts[i + 1].start() if i + 1 < len(starts) else len(body))]
        dims = []
        for d in re.finditer(r"\.enableInDim\((.*?)\)", text, re.S):
            for x in d.group(1).split(","):
                x = x.strip().split(".")[-1]   # DimensionDef.Europa, DimNames.OW
                if x:
                    dims.append(enum.get(x, x))
        rec = {"id": i + 1, "name": m.group(1), "dims": list(dict.fromkeys(dims))}
        for k in ("weight", "density", "size"):
            rec[k] = int(re.search(r"\." + k + r"\((\d+)\)", text).group(1))
        for role in ROLES:
            rec[role] = re.search(r"\." + GT_CALL[role] + r"\(([^()]*?)\)", text).group(1).strip().split(".")[-1]
        # OreMixBuilder: primary() names the mix unless setLocalizedName came first; setLocalizedName adds its materials
        loc = re.search(r"\.setLocalizedName\(([^()]*)\)", text)
        keys = [x.strip().split(".")[-1] for x in loc.group(1).split(",")] if loc else []
        if not loc or text.index(".primary(") < loc.start():
            keys = [rec["primary"]] + keys
        rec["label"] = keys
        out.append(rec)
    return out


def lua(gt_ref, recs, reg, mats):
    used = sorted({d for r in recs for d in r["dims"]}, key=lambda d: (reg.get(d, ("", 99))[1], d))
    lines = [
        "--- Generated by tools/gen_ore_mixes.py from GT5-Unofficial " + gt_ref + " (OreMixes.java, DimensionDef.java,",
        "--- gtneioreplugin DimensionHelper.java); do not edit, run the tool again. Issue #496, plan #494.",
        "--- mixes: GT's ore mixes in their order (id = position), weight, density, size, the dimensions (DimNames",
        "--- constants) and the four ores as Gregtorio's materials (raw ore raw-<material>), GT's names in gt.",
        "--- dimensions: DimNames constant -> name and tier of DimensionHelper.java.",
        "--- label: GT's name of the mix (issue #497); materials: Gregtorio material -> GT's English name and colour",
        "--- (MaterialsInit.java) of the ores GT's Materials has.",
        "return {",
        '\tsource = "GT5-Unofficial ' + gt_ref + '",',
        "\tdimensions = {",
    ]
    for d in used:
        name, tier = reg.get(d, (d, -1))
        lines.append(f'\t\t{d} = {{ name = "{name}", tier = {tier} }},')
    lines += ["\t},", "\tmixes = {"]
    for r in recs:
        dims = ", ".join(f'"{d}"' for d in r["dims"])
        ores = ", ".join(f'{k} = "{material(r[k])}"' for k in ROLES)
        gt = ", ".join(f'"{r[k]}"' for k in ROLES)
        lines.append(f'\t\t{{ id = {r["id"]}, name = "{r["name"]}", weight = {r["weight"]}, density = {r["density"]}, '
                     f'size = {r["size"]}, dimensions = {{ {dims} }},')
        label = format_list([mats[k][0] if k in mats else split_name(k) for k in r["label"]])
        lines.append(f'\t\t\t{ores}, gt = {{ {gt} }}, label = "{label}" }},')
    lines += ["\t},", "\tmaterials = {"]
    seen = {}
    for r in recs:
        for k in ROLES:
            if r[k] in mats:
                seen[material(r[k])] = mats[r[k]]
    for x in sorted(seen):
        name, rgb = seen[x]
        lines.append(f'\t\t["{x}"] = {{ name = "{name}", color = {{ {rgb[0]}, {rgb[1]}, {rgb[2]} }} }},')
    lines += ["\t},", "}", ""]
    return "\n".join(lines)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gt", required=True, help="GT5-Unofficial checkout")
    ap.add_argument("--ref", default="f2814df", help="commit to read (default f2814df); '' for the working tree")
    a = ap.parse_args()
    enum, reg = dimensions(read(a.gt, a.ref, "defs"), read(a.gt, a.ref, "helper"))
    recs = mixes(read(a.gt, a.ref, "mixes"), enum)
    unknown = sorted({d for r in recs for d in r["dims"] if d not in reg})
    if unknown:
        raise SystemExit("dimensions without a DimensionHelper entry: " + ", ".join(unknown))
    OUT.parent.mkdir(exist_ok=True)
    mats = gt_materials(read(a.gt, a.ref, "materials"))
    OUT.write_bytes(lua(a.ref or "working tree", recs, reg, mats).encode("utf8"))
    print(f"{OUT.relative_to(ROOT)}: {len(recs)} mixes, {len({d for r in recs for d in r['dims']})} dimensions")


if __name__ == "__main__":
    main()
