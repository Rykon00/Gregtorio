#!/usr/bin/env python3
"""Issue #227: the parts GT New Horizons generates for every metal of Gregtorio, as data for
prototypes/158-fork-gt-parts.lua.

Reads GT5-Unofficial (MaterialsInit.java: the material builders; Element.java: element protons and neutrons;
LoaderGTBlockFluid.java: the storage blocks; gtPlusPlus MaterialsAlloy.java / MaterialsElements.java: the GT++ alloys
and elements; bartworks WerkstoffLoader.java and goodgenerator GGMaterial.java: the Werkstoffe) and the items of a
devcheck run (the I rows of the DUMP section of .devcheck/last-run.log: the items Gregtorio has), and writes
prototypes/gt-parts-data.lua: per Gregtorio material its source (GT, GT++ or a Werkstoff), GT mass, dust item, recipe
tier, blast furnace temperature and the forms GT generates that Gregtorio lacks.

    python tools/devcheck/devcheck.py check
    python tools/gen_gt_parts.py --gt C:/00_Repositories/GT5-Unofficial

GT materials (MaterialBuilder.addMetalItems and the OrePrefixes conditions): nugget, plate, double plate, dense and
superdense plate (not NO_SMASHING), triple to quintuple plate (MULTI_PLATE), foil, rod, long rod, bolt, screw, round,
ring, fine wire, small spring and spring (not NO_SMASHING), item casing, frame box (LoaderMetaPipeEntities.java: every
metal), the storage block (LoaderGTBlockFluid.java), small gear, gear and rotor (addGearItems; rotor not CRYSTAL).
GT++ alloys (MaterialGenerator.generate, generateEverything): block, frame, nugget, plate, double plate, dense plate,
bolt, rod, long rod, ring, screw, rotor, gear (GT++'s gear is GT's gearGt). Not made: tool heads, turbine blades, cells.
GT++ elements of MaterialsElements.STANDALONE (issue #228, rhugnor): MaterialGenerator.generate(x, false, ...) in
ModItems.java gives block, nugget, plate and double plate, generateComponentAndAssignToAMaterial the components named
there (fine wire, foil, superdense plate, gear, bolt, ...).
Werkstoffe (issue #228: bartworks' ruridit and rhodium-plated palladium, goodgenerator's Incoloy-903): the prefixes of
Werkstoff.GenerationFeatures (initPrefixLogic): METALS nugget and block; SIMPLE_METALWORKING plate, foil, rod, long
rod; CRAFTING_METALWORKING screw, bolt, ring, small gear, gear, rotor, fine wire, small spring, spring, frame;
DOUBLE_DENSE_PLATES double, dense and superdense plate; MULTI_PLATES triple to quintuple plate (no round, no item
casing). Their mass is the amount-weighted average of their components' (Werkstoff constructor), their tier the
processing tier they set, their temperature the melting point.
"""
import argparse, ast, re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "prototypes/gt-parts-data.lua"

#: Gregtorio material -> GT material where the names differ (besides tools/gen_gt_icons.py's MATERIALS)
GT_NAME = {"hsse": "HSSE", "hssg": "HSSG", "hsss": "HSSS", "enriched-naquadah": "NaquadahEnriched",
           "chromium": "Chrome", "rtm-alloy": "RTMAlloy", "red-alloy": "RedAlloy"}
#: Gregtorio material -> GT++ alloy constant (MaterialsAlloy.java) where the names differ
GTPP_NAME = {"maraging-steel-250": "MARAGING250", "maraging-steel-300": "MARAGING300",
             "hastelloy-c276": "HASTELLOY_C276", "nitinol-60": "NITINOL_60", "tantalloy-60": "TANTALLOY_60",
             "zeron-100": "ZERON_100", "inconel-625": "INCONEL_625", "inconel-690": "INCONEL_690",
             "inconel-792": "INCONEL_792", "incoloy-020": "INCOLOY_020", "incoloy-ds": "INCOLOY_DS",
             "incoloy-ma956": "INCOLOY_MA956", "watertight-steel": "AQUATIC_STEEL", "grisium": "LEAGRISIUM"}
#: the dust item of a material where it is not <material>-dust
DUST = {"antimony": "antimony", "chromium": "chromium-dust"}
TIERS = ["lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"]
GT_TIER = {"LV": "lv", "MV": "mv", "HV": "hv", "EV": "ev", "IV": "iv", "LuV": "luv", "ZPM": "zpm", "UV": "uv",
           "UHV": "uhv", "UEV": "uev", "UIV": "uiv", "UMV": "umv", "UXV": "uxv", "MAX": "max"}

GT_FORMS = ["nugget", "plate", "double-plate", "triple-plate", "quadruple-plate", "quintuple-plate", "dense-plate",
            "superdense-plate", "foil", "rod", "long-rod", "bolt", "screw", "round", "ring", "fine-wire", "small-spring",
            "spring", "item-casing", "frame", "block", "gear", "large-gear", "rotor"]
GTPP_FORMS = ["nugget", "plate", "double-plate", "dense-plate", "rod", "long-rod", "bolt", "screw", "ring", "frame",
              "block", "large-gear", "rotor"]
#: GT++ elements: MaterialGenerator.generate(x, false, ...) and the ComponentTypes of generateComponentAndAssignToAMaterial
GTPP_SIMPLE_FORMS = ["block", "nugget", "plate", "double-plate"]
GTPP_COMPONENT = {"FINEWIRE": "fine-wire", "FOIL": "foil", "PLATESUPERDENSE": "superdense-plate", "GEAR": "large-gear",
                  "SMALLGEAR": "gear", "BOLT": "bolt", "ROD": "rod", "RODLONG": "long-rod", "RING": "ring",
                  "SCREW": "screw", "ROTOR": "rotor", "PLATEDENSE": "dense-plate", "PLATEDOUBLE": "double-plate",
                  "SPRING": "spring", "SMALLSPRING": "small-spring", "FRAMEBOX": "frame"}
#: Werkstoff feature bits -> Gregtorio forms (Werkstoff.GenerationFeatures.initPrefixLogic)
BW_BITS = {"METALS": ["nugget", "block"], "SIMPLE": ["plate", "foil", "rod", "long-rod"],
           "CRAFTING": ["screw", "large-gear", "gear", "bolt", "ring", "spring", "small-spring", "rotor", "fine-wire",
                        "frame"],
           "DOUBLE_DENSE": ["double-plate", "dense-plate", "superdense-plate"],
           "MULTI": ["triple-plate", "quadruple-plate", "quintuple-plate"]}
#: GenerationFeatures methods -> the bits they set
BW_METHODS = {"addMetalItems": {"METALS", "SIMPLE"}, "addSimpleMetalWorkingItems": {"SIMPLE"},
              "addCraftingMetalWorkingItems": {"CRAFTING"}, "addDoubleAndDensePlates": {"DOUBLE_DENSE"},
              "addCasings": {"SIMPLE", "CRAFTING", "DOUBLE_DENSE", "METALS"}, "addMultiPlates": {"MULTI"},
              "addGems": {"SIMPLE"}}
#: form -> item name pattern
PATTERN = {"nugget": "%s-nugget", "plate": "%s-plate", "double-plate": "double-%s-plate",
           "triple-plate": "triple-%s-plate", "quadruple-plate": "quadruple-%s-plate",
           "quintuple-plate": "quintuple-%s-plate", "dense-plate": "dense-%s-plate",
           "superdense-plate": "superdense-%s-plate", "foil": "%s-foil", "rod": "%s-rod", "long-rod": "long-%s-rod",
           "bolt": "%s-bolt", "screw": "%s-screw", "round": "%s-round", "ring": "%s-ring", "fine-wire": "fine-%s-wire",
           "small-spring": "small-%s-spring", "spring": "%s-spring", "item-casing": "%s-item-casing",
           "frame": "%s-frame", "block": "block-of-%s", "gear": "%s-gear", "large-gear": "large-%s-gear",
           "rotor": "%s-rotor"}


def gt_materials(gt):
    src = (gt / "src/main/java/gregtech/loaders/materials/MaterialsInit.java").read_text(encoding="utf-8")
    elem = {}
    for m in re.finditer(r"^    (\w+)\((-?\d+), (-?\d+), ", (gt / "src/main/java/gregtech/api/enums/Element.java")
                         .read_text(encoding="utf-8"), re.M):
        elem[m.group(1)] = (int(m.group(2)), int(m.group(3)))
    mats = {}
    for m in re.finditer(r"private static Materials load\w+\(\) \{(.*?)\n    \}", src, re.S):
        body = m.group(1)
        name = re.search(r'setName\("([^"]+)"\)', body)
        if not name:
            continue
        d = {"metal": ".addMetalItems()" in body, "gear": ".addGearItems()" in body, "dust": ".addDustItems()" in body,
             "tags": set(re.findall(r"SubTag\.(\w+)", body))}
        x = re.search(r"setElement\(Element\.(\w+)\)", body)
        d["element"] = x.group(1) if x else None
        d["comp"] = [(a, int(b)) for a, b in re.findall(r"addMaterial\(Materials\.(\w+), (\d+)\)", body)]
        x = re.search(r"setDensity\((\d+), (\d+)\)", body)
        d["density"] = (int(x.group(1)), int(x.group(2))) if x else (1, 1)
        x = re.search(r"setProcessingMaterialTierEU\(TierEU\.RECIPE_(\w+)\)", body)
        d["tier"] = GT_TIER.get(x.group(1)) if x else None
        x = re.search(r"\.setBlastFurnaceTemp\(([\d_]+)\)", body)
        d["temp"] = int(x.group(1).replace("_", "")) if x else 0
        mats[name.group(1)] = d
    memo = {}

    def value(n, i, depth=0):
        """GT's Materials.getProtons (i 0), getNeutrons (1) or getMass (2): the element's, else the amount weighted
        average of the components x the density, else technetium's (43, 55)"""
        if (n, i) in memo:
            return memo[(n, i)]
        d = mats.get(n)
        if d is None or depth > 20:
            return (43, 55, 98)[i]
        if d["element"] and d["element"] in elem:
            pn = elem[d["element"]]
            r = pn[i] if i < 2 else pn[0] + pn[1]
        elif not d["comp"]:
            r = (43, 55, 98)[i]
        else:
            t = sum(a for _, a in d["comp"])
            r = sum(a * value(c, i, depth + 1) for c, a in d["comp"]) * d["density"][0] // (d["density"][1] * t)
        memo[(n, i)] = r
        return r
    for n in mats:
        mats[n]["protons"], mats[n]["neutrons"], mats[n]["mass"] = value(n, 0), value(n, 1), value(n, 2)
    return mats


def gt_blocks(gt):
    src = (gt / "src/main/java/gregtech/loaders/preload/LoaderGTBlockFluid.java").read_text(encoding="utf-8")
    out = set()
    for m in re.finditer(r"new BlockMetal\(\s*\"gt\.block(?:metal|gem)\d+\",\s*new Materials\[\] \{(.*?)\}", src, re.S):
        out.update(re.findall(r"Materials\.(\w+)", m.group(1)))
    return out


def gtpp_alloys(gt, gtmats):
    """GT++ alloys: name -> (melting point C, mass). GT++'s Material (Material.java:444-454): protons and neutrons are
    the plain averages of the listed components, unless given (protons when not -1; the neutron argument whenever a
    boiling point is given), the mass their sum; components are MaterialsElements (GT materials) or other alloys"""
    src = (gt / "src/main/java/gtPlusPlus/core/material/MaterialsAlloy.java").read_text(encoding="utf-8")
    el = (gt / "src/main/java/gtPlusPlus/core/material/MaterialsElements.java").read_text(encoding="utf-8")
    from_gt = dict(re.findall(r"public final Material (\w+) = MaterialUtils\.generateMaterialFromGtENUM\("
                              r"\s*Materials\.(\w+)", el))
    defs = {}
    for m in re.finditer(r"public static final Material (\w+) = new Material\((.*?)\);", src, re.S):
        body = re.sub(r"//[^\n]*", "", m.group(2))
        head = body.split("new MaterialStack")[0]
        head = re.sub(r"new short\[\] \{[^}]*\}", "", head)
        nums = [int(x) for x in re.findall(r"(?<![\w.])(-?\d+)\s*,", head)]
        comps = re.findall(r"new MaterialStack\(\s*(MaterialsElements\.getInstance\(\)|MaterialsAlloy)\.(\w+)", body)
        defs[m.group(1)] = (nums, comps)
    memo = {}

    def pn(kind, n, depth=0):
        if kind.startswith("MaterialsElements"):
            g = gtmats.get(from_gt.get(n, ""))
            return (g["protons"], g["neutrons"]) if g else (43, 55)
        if n in memo or depth > 10:
            return memo.get(n, (43, 55))
        nums, comps = defs.get(n, ([], []))
        parts = [pn(k, c, depth + 1) for k, c in comps]
        avg_p = sum(p for p, _ in parts) // len(parts) if parts else 0
        avg_n = sum(q for _, q in parts) // len(parts) if parts else 0
        # numbers after the colour: melting point, boiling point, protons, neutrons
        boil = nums[1] if len(nums) > 1 else -1
        prot = nums[2] if len(nums) > 2 else -1
        neut = nums[3] if len(nums) > 3 else -1
        memo[n] = (prot if prot != -1 else avg_p, neut if boil != -1 else avg_n)
        return memo[n]
    out = {}
    for name, (nums, _) in defs.items():
        p_, n_ = pn("MaterialsAlloy", name)
        out[name] = (nums[0] if nums else 0, p_ + n_)
    return out


def java_calls(src, head):
    """the argument text of every `<head>(...)` in src (balanced parentheses), with the name before it"""
    out = []
    for m in re.finditer(head, src):
        i, depth = m.end(), 1
        while depth and i < len(src):
            depth += {"(": 1, ")": -1}.get(src[i], 0)
            i += 1
        out.append((m.group(1), src[m.end():i - 1]))
    return out


def werkstoffe(gt, gtmats):
    """bartworks and goodgenerator Werkstoffe: Gregtorio name (the display name, lower case, spaces as dashes) ->
    {name, forms, mass, tier, temp}"""
    elem = {}
    for m in re.finditer(r"^    (\w+)\((-?\d+), (-?\d+), ", (gt / "src/main/java/gregtech/api/enums/Element.java")
                         .read_text(encoding="utf-8"), re.M):
        elem[m.group(1)] = int(m.group(2)) + int(m.group(3))
    defs = {}
    for f in ["bartworks/system/material/WerkstoffLoader.java", "goodgenerator/items/GGMaterial.java"]:
        src = re.sub(r"//[^\n]*", "", (gt / "src/main/java" / f).read_text(encoding="utf-8"))
        for var, body in java_calls(src, r"public static final Werkstoff (\w+) = new Werkstoff\("):
            name = re.search(r'"([^"]+)"', body)
            if not name:
                continue
            bits = set()
            feats = re.search(r"new Werkstoff\.GenerationFeatures\(\)(.*?)(?:,\s*(?:OffsetID|\d))", body, re.S)
            for meth in re.findall(r"\.(\w+)\(", feats.group(1) if feats else ""):
                if meth == "disable":
                    bits = set()
                bits |= BW_METHODS.get(meth, set())
            x = re.search(r"setMeltingPoint\((\d+)\)", body)
            melt = int(x.group(1)) if x else 0
            x = re.search(r"setProcessingMaterialTierEU\(TierEU\.RECIPE_(\w+)\)", body)
            tier = GT_TIER.get(x.group(1)) if x else None
            x = re.search(r"setMass\(Element\.(\w+)\.getMass\(\)\)", body)
            mass = elem.get(x.group(1)) if x else None
            x = re.search(r"setMass\((\d+)\)", body)        # issue #467: a mass given as a number (shirabon 128)
            if mass is None and x:
                mass = int(x.group(1))
            comps = [(re.sub(r"^(Materials|WerkstoffLoader|GGMaterial)\.", "", a), int(n))
                     for a, n in re.findall(r"Pair\.of\(\s*([\w.]+),\s*(\d+)\)", body)]
            defs[var] = {"name": name.group(1), "bits": bits, "melt": melt, "tier": tier, "mass": mass, "comps": comps}

    def mass_of(var, depth=0):
        d = defs[var]
        if d["mass"] is None:
            total, count = 0, 0
            for c, n in d["comps"]:
                cm = gtmats[c]["mass"] if c in gtmats else (mass_of(c, depth + 1) if c in defs and depth < 10 else None)
                if cm is None:
                    continue
                total, count = total + cm * n, count + n
            d["mass"] = total // count if count else 0
        return d["mass"]
    out = {}
    for var, d in defs.items():
        forms = [f for b in ("METALS", "SIMPLE", "CRAFTING", "DOUBLE_DENSE", "MULTI") if b in d["bits"]
                 for f in BW_BITS[b]]
        key = re.sub(r"\s+", "-", d["name"].lower())
        out[key] = {"name": d["name"], "forms": forms, "mass": mass_of(var), "tier": d["tier"], "temp": d["melt"]}
    return out


def gtpp_elements(gt):
    """GT++ elements of MaterialsElements.STANDALONE that ModItems.java generates as metals: constant ->
    (melting point C, mass, forms)"""
    el = (gt / "src/main/java/gtPlusPlus/core/material/MaterialsElements.java").read_text(encoding="utf-8")
    items = re.sub(r"//[^\n]*", "", (gt / "src/main/java/gtPlusPlus/core/item/ModItems.java").read_text(encoding="utf-8"))
    out = {}
    for const, body in java_calls(el, r"public static final Material (\w+) = new Material\("):
        if "MaterialState.SOLID" not in body:
            continue
        nums = [int(x) for x in re.findall(r"(?<![\w.])(-?\d+)\s*,", re.sub(r"new short\[\] \{[^}]*\}", "", body))]
        g = re.search(r"MaterialGenerator\.generate\(\s*MaterialsElements\.STANDALONE\." + const + r"\s*(?:,\s*(\w+))?",
                      items)
        if not g or len(nums) < 4:
            continue
        forms = list(GTPP_SIMPLE_FORMS) if g.group(1) == "false" else list(GTPP_FORMS)
        for comp in re.findall(r"generateComponentAndAssignToAMaterial\(\s*(\w+),\s*MaterialsElements\.STANDALONE\."
                               + const + r"\s*\)", items):
            f = GTPP_COMPONENT.get(comp)
            if f and f not in forms:
                forms.append(f)
        # numbers after the colour: melting point, boiling point, protons, neutrons
        out[const] = (nums[0], nums[2] + nums[3], forms)
    return out


def dump_items(log):
    """the items of a devcheck run: the I rows of the DUMP section"""
    text = log.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"DEVCHECK-DUMP-BEGIN\n(.*?)\nDEVCHECK-DUMP-END", text, re.S)
    if not m:
        raise SystemExit(f"no DEVCHECK-DUMP section in {log}: run `python tools/devcheck/devcheck.py check` first")
    return {l.split("\t")[1] for l in m.group(1).splitlines() if l.startswith("I\t")}


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--gt", required=True, type=Path)
    ap.add_argument("--log", type=Path, default=ROOT / ".devcheck/last-run.log",
                    help="log of a `devcheck.py check` run (its DUMP section has the items; default: the last run)")
    a = ap.parse_args()
    items = dump_items(a.log)
    icons = (ROOT / "tools/gen_gt_icons.py").read_text(encoding="utf-8")
    icon_mats = ast.literal_eval(re.search(r"^MATERIALS = (\{.*?^\})", icons, re.S | re.M).group(1))
    mats = gt_materials(a.gt)
    blocks, alloys = gt_blocks(a.gt), gtpp_alloys(a.gt, mats)
    elements, works = gtpp_elements(a.gt), werkstoffe(a.gt, mats)
    metals = sorted({n[:-6] for n in items if n.endswith("-ingot") and not n.startswith("hot-")})
    rows, skipped = [], []
    for m in metals:
        src_name = GT_NAME.get(m) or (icon_mats.get(m) if isinstance(icon_mats.get(m), str) else None) \
            or "".join(w.capitalize() for w in m.split("-"))
        pp = GTPP_NAME.get(m) or m.upper().replace("-", "_")
        d = mats.get(src_name)
        if d and d["metal"]:
            ns = "NO_SMASHING" in d["tags"] and "STRETCHY" not in d["tags"]
            forms = []
            for f in GT_FORMS:
                if f in ("double-plate", "dense-plate", "superdense-plate", "small-spring", "spring") and ns:
                    continue
                if f in ("triple-plate", "quadruple-plate", "quintuple-plate") and "MULTI_PLATE" not in d["tags"]:
                    continue
                if f == "block" and src_name not in blocks:
                    continue
                if f in ("gear", "large-gear", "rotor") and not d["gear"]:
                    continue
                if f == "rotor" and d["tags"] & {"CRYSTAL", "STONE", "BOUNCY"}:
                    continue
                forms.append(f)
            source, mass, tier, temp, label = "gt", d["mass"], d["tier"], d["temp"], "GT " + src_name
        elif pp in alloys:
            melt, mass = alloys[pp]
            t = 0 if melt < 1000 else int(melt / 1000 + 0.5)   # MaterialUtils.getTierOfMaterial
            forms, source, tier, temp, label = list(GTPP_FORMS), "gtpp", TIERS[max(0, t - 1)], 0, "GT++ " + pp
        elif pp in elements:
            melt, mass, forms = elements[pp]
            t = 0 if melt < 1000 else int(melt / 1000 + 0.5)   # MaterialUtils.getTierOfMaterial
            source, tier, temp, label = "gtpp", TIERS[max(0, t - 1)], 0, "GT++ element " + pp
        elif m in works and works[m]["forms"]:
            w = works[m]
            forms = [f for f in GT_FORMS if f in w["forms"]]
            source, mass, tier, temp, label = "bw", w["mass"], w["tier"], w["temp"], "Werkstoff " + w["name"]
        else:
            skipped.append((m, src_name))
            continue
        missing = [f for f in forms if (PATTERN[f] % m) not in items]   # for the count only: 158 skips what exists
        dust = DUST.get(m, m + "-dust")
        rows.append((m, source, label, mass, dust if dust in items else None, tier, forms, temp, missing))
    lines = ["--- Generated by tools/gen_gt_parts.py (issues #227, #228) from GT5-Unofficial: do not edit by hand.",
             "--- material -> { source (gt: a GT material, gtpp: a GT++ alloy or element, bw: a bartworks or goodgenerator",
             "--- Werkstoff), GT mass, dust item, tier (gt and bw: the processing voltage, nil: each recipe's own; gtpp: the",
             "--- voltage of the melting point), blast furnace temperature (bw: the melting point), the forms GT generates",
             "--- (158 makes those Gregtorio lacks) }",
             "return {"]
    for m, source, label, mass, dust, tier, forms, temp, _ in rows:
        fl = ", ".join('"%s"' % f for f in forms)
        lines.append('\t["%s"] = { source = "%s", mass = %d, dust = %s, tier = %s, temp = %d, forms = { %s } },   -- %s' % (
            m, source, max(1, mass), '"%s"' % dust if dust else "nil", '"%s"' % tier if tier else "nil", temp, fl,
            label))
    lines.append("}")
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    print(f"{len(rows)} materials, {sum(1 for r in rows if r[8])} with {sum(len(r[8]) for r in rows)} missing parts -> {OUT}")
    for m, s in skipped:
        print(f"  no GT or GT++ source: {m} ({s})")


if __name__ == "__main__":
    main()
