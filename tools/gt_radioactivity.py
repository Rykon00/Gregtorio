"""Issue #621: GT New Horizons' radioactive materials and their levels from the GT5-Unofficial source, written to
tools/gtnh_dump/gt-radioactivity.json (committed, so devcheck needs no GT checkout; run this again after a GT update).

GT applies radiation to a player carrying an item of a material with the radioactivity enchantment
(GTUtility.java:2037-2046, 2084: the level of the material's armor or tool enchantment; GTProxy.java:1312), bartworks
to its werkstoffs with `setRadioactive(true)` (BridgeMaterialsLoader.java:95-97: the stats' enchantment level, 3 unless
set), GT++ to the items of its materials with a radiation level (Material.java:476-492: the level given, else for an
alloy the average of its components' levels, rounded down; BaseItemComponent.java:199).

    python tools/gt_radioactivity.py [C:/00_Repositories/GT5-Unofficial]
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "tools" / "gtnh_dump" / "gt-radioactivity.json"


def strip_comments(s):
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
    return re.sub(r"//[^\n]*", "", s)


def call_args(s, start):
    """the top-level arguments of the call whose '(' is at s[start], and the index after its ')'"""
    depth, i, args, cur = 0, start, [], []
    while i < len(s):
        c = s[i]
        if c == '"':
            j = i + 1
            while s[j] != '"':
                j += 2 if s[j] == "\\" else 1
            cur.append(s[i:j + 1])
            i = j + 1
            continue
        if c in "([{":
            depth += 1
            if depth > 1:
                cur.append(c)
        elif c in ")]}":
            depth -= 1
            if depth == 0:
                args.append("".join(cur).strip())
                return args, i + 1
            cur.append(c)
        elif c == "," and depth == 1:
            args.append("".join(cur).strip())
            cur = []
        else:
            cur.append(c)
        i += 1
    raise ValueError("unbalanced call")


def gt_materials(src):
    """GT's materials with the radioactivity enchantment: {mName: level}"""
    text = strip_comments((src / "src/main/java/gregtech/loaders/materials/MaterialsInit.java").read_text(encoding="utf-8"))
    out = {}
    for m in re.finditer(r"new MaterialBuilder\(\)\.setName\(\"([^\"]+)\"\)(.*?)\.constructMaterial\(\)", text, re.S):
        lv = re.search(r"set(?:Armor|Tool)Enchantment\(\s*\(\)\s*->\s*EnchantmentRadioactivity\.INSTANCE,\s*(\d+)\)", m.group(2))
        if lv:
            out[m.group(1)] = int(lv.group(1))
    return out


def bartworks(src):
    """bartworks' radioactive werkstoffs: {default name: level}"""
    text = strip_comments((src / "src/main/java/bartworks/system/material/WerkstoffLoader.java").read_text(encoding="utf-8"))
    out = {}
    for m in re.finditer(r"new Werkstoff\(", text):
        args, _ = call_args(text, m.end() - 1)
        stats = next((a for a in args if a.startswith("new Werkstoff.Stats()")), "")
        if ".setRadioactive(true)" in stats:
            name = next(a for a in args if a.startswith('"'))[1:-1]
            lv = re.search(r"setEnchantmentlvl\(\(byte\)\s*(\d+)\)", stats)
            out[name] = int(lv.group(1)) if lv else 3
    return out


INT = re.compile(r"^-?\d+$")


def gtpp(src):
    """GT++'s materials with a radiation level, the alloys' from their components: {name: level}"""
    fields = {}
    for f in sorted((src / "src/main/java/gtPlusPlus/core/material").rglob("*.java")):
        text = strip_comments(f.read_text(encoding="utf-8"))
        for m in re.finditer(r"(\w+)\s*=\s*new Material\(", text):
            args, _ = call_args(text, m.end() - 1)
            name = args[0][1:-1] if args[0].startswith('"') else None
            if not name:
                continue
            level = 0
            b = next((i for i, a in enumerate(args) if a in ("true", "false")), None)
            if b is not None:
                k = b + 1
                if k < len(args) and not INT.match(args[k]) and not args[k].startswith("new MaterialStack"):
                    k += 1     # the chemical symbol
                if k < len(args) and INT.match(args[k]):
                    level = int(args[k])
            elif len(args) > 8 and INT.match(args[8]):
                level = int(args[8])     # (name, state, set, rgba, melting, boiling, protons, neutrons, radiation, stacks)
            stacks = [re.findall(r"(\w+)\s*$", a.split(",")[0][len("new MaterialStack("):])[0]
                      for a in args if a.startswith("new MaterialStack(")]
            fields[m.group(1)] = {"name": name, "level": level, "stacks": stacks}
    levels = {k: v["level"] for k, v in fields.items()}
    for _ in range(10):
        for k, v in fields.items():
            if v["level"] <= 0 and v["stacks"]:
                levels[k] = sum(levels.get(s, 0) for s in v["stacks"]) // len(v["stacks"])
    return {fields[k]["name"]: lv for k, lv in levels.items() if lv > 0}


def main():
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/00_Repositories/GT5-Unofficial")
    data = {"gt": gt_materials(src), "bartworks": bartworks(src), "gtpp": gtpp(src)}
    OUT.write_text(json.dumps(data, indent=1, sort_keys=True) + "\n", encoding="utf-8", newline="\n")
    print(OUT, {k: len(v) for k, v in data.items()})


if __name__ == "__main__":
    main()
