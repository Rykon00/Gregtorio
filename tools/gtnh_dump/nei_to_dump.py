#!/usr/bin/env python3
"""Issue #714: converts the full-pack recipe dump of Learwin's NEI fork (`/recipeid dump`, see README.md) into the
format of gtnh-recipes.json.gz (issue #679's GT5-Unofficial dump) and merges both into gtnh-merged.json.gz, which
`devcheck.py gtnh-diff` reads when it exists:

    python tools/gtnh_dump/nei_to_dump.py <recipeid.zip or the recipeid folder> --pack "GTNH daily 2026-10-28+804"
    python tools/gtnh_dump/nei_to_dump.py --selftest

Kept from the NEI dump (README.md, "The NEI format"):
  * every line with a GTRecipe (`mRecipe`): GT's recipe maps, the map from the recipe's category (`recipeType`, the
    categories of the GT5-Unofficial dump name their map; an unknown one is a map of its own), EU/t, ticks, chances;
    count 0 is not consumed, the programmed circuit is `circuit`. GT's special value is not in the NEI dump.
  * NEI's crafting table and furnace handlers, when the product's mod is one of the GT5-Unofficial dump's or the core
    mod: ingredients (an ore dictionary ingredient as its first item, no shape) and the product.
Everything else is counted per handler (crafting and furnace products of other mods per mod) in the report.

Merge: a GT recipe with the same items and fluids in and out as one of the GT5-Unofficial dump's map keeps that line
(source `both`; the report counts the ones with other EU/t, ticks or chances); a crafting recipe matches one with the
same product whose ingredients fit (the same item, an item of the ore dictionary name, an item of the list); a furnace
recipe one with the same input and product. The rest is added with source `nei`; the GT5-Unofficial dump's other
recipes keep source `gt5u`.
"""
import argparse, copy, datetime, gzip, hashlib, io, json, re, sys, zipfile
from collections import Counter, defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
GT5U = HERE / "gtnh-recipes.json.gz"
MERGED = HERE / "gtnh-merged.json.gz"
FIXTURE = HERE / "nei_fixture"
REPORT = ROOT / ".devcheck/nei-to-dump.md"
FORK = "Learwin/NotEnoughItems data-export d987255"
#: the repository's limit for the merged dump (GitHub warns at 50 MB)
MAX_BYTES = 45 * 2 ** 20
CIRCUIT = "gregtech:gt.integrated_circuit:"
WILDCARD = "32767"
#: NEI's handlers of the crafting table (value: shapeless) and of the furnace
CRAFTING = {"codechicken.nei.recipe.ShapedRecipeHandler": False, "codechicken.nei.recipe.ShapelessRecipeHandler": True}
FURNACE = {"codechicken.nei.recipe.FurnaceRecipeHandler"}
#: packages of GT's mods and the core mod: their lines in an unknown shape are reported as such, not as other mods'
KEEP_HANDLER = re.compile(r"^(gregtech|gtPlusPlus|gtnhlanth|bartworks|goodgenerator|kekztech|kubatech|tectech|"
                          r"gtnhintergalactic|ggfab|com\.dreammaster)\.")
#: mods whose crafting and furnace products are kept besides the GT5-Unofficial dump's mod list
EXTRA_MODS = {"minecraft", "dreamcraft"}


def nbt_int(v, default=0):
    """an NBT number as NEI writes it: a number, or a string with NBT's type letter (25600L, 3S, 1B)"""
    if v is None:
        return default
    if isinstance(v, str):
        return int(float(v.rstrip("bBsSlLfFdD") or 0))
    return int(v)


def same_id(a, b):
    """item keys a and b are the same, a meta of 32767 (any) matching every meta"""
    if a == b:
        return True
    (an, am), (bn, bm) = a.rsplit(":", 1), b.rsplit(":", 1)
    return an == bn and WILDCARD in (am, bm)


def gt_key(r):
    """the items and fluids in and out of a GT recipe, amounts included, numbers left out"""
    ins = sorted((s.get("id") or "ore:" + s.get("ore", "?"), s.get("n", 1), bool(s.get("nc"))) for s in r["in"])
    outs = sorted((s["id"], s.get("n", 1)) for s in r["out"])
    fl = lambda xs: tuple(sorted((f["fluid"], f["l"]) for f in xs or []))
    return tuple(ins), tuple(outs), fl(r.get("fin")), fl(r.get("fout"))


def gt_numbers(r):
    return r.get("eut"), r.get("duration"), tuple(sorted((s["id"], s.get("chance", 10000)) for s in r["out"]))


class Nei:
    """the NEI dump, converted: GT recipes per map, crafting and furnace recipes, item names and the counts"""

    def __init__(self, categories, keep_mods):
        self.categories, self.keep_mods = categories, keep_mods
        self.maps = defaultdict(list)
        self.crafting, self.furnace = [], []
        self.names = {}
        self.handlers = defaultdict(Counter)
        self.formats = {}
        self.no_format = Counter()
        self.other_mods = Counter()
        self.gt_fields = Counter()
        self.lines = 0
        self._raw, self._conv = set(), set()

    # -- items

    def stack(self, o):
        """an NEI item -> ("item", {"id", "n", "nbt"}) | ("fluid", {"fluid", "l"}) | (None, None)"""
        if not isinstance(o, dict):
            return None, None
        for k in ("neiFluidName", "gtFluidName"):
            if k in o:
                return "fluid", {"fluid": o[k], "l": nbt_int(o.get("Count"))}
        if "FluidName" in o:
            return "fluid", {"fluid": o["FluidName"], "l": nbt_int(o.get("Amount"))}
        if "strId" not in o:
            return None, None
        key = f"{o['strId']}:{nbt_int(o.get('Damage'))}"
        if o.get("Name"):
            self.names.setdefault(key, o["Name"])
        s = {"id": key, "n": nbt_int(o.get("Count"), 1)}
        if o.get("tag"):
            s["nbt"] = json.dumps(o["tag"], sort_keys=True, separators=(",", ":"))
        return "item", s

    def items(self, xs):
        return [s for kind, s in map(self.stack, xs or []) if kind == "item"]

    # -- recipes

    def gt(self, g):
        """a GTRecipe -> (map, recipe in gtnh-recipes.json's shape)"""
        cat = g.get("recipeType") or "?"
        r = {"eut": nbt_int(g.get("mEUt")), "duration": nbt_int(g.get("mDuration")), "category": cat,
             "in": [], "out": [], "fin": [], "fout": []}
        for s in self.items(g.get("mInputs")):
            if s["id"].startswith(CIRCUIT):
                s.update(n=0, nc=True, circuit=int(s["id"][len(CIRCUIT):]))
            elif not s["n"]:
                s["nc"] = True
            r["in"].append(s)
        chances = g.get("chances") or []
        for i, o in enumerate(g.get("mOutputs") or []):
            kind, s = self.stack(o)
            if kind == "item":
                c = nbt_int(chances[i], 10000) if i < len(chances) else 10000
                if c < 10000:
                    s["chance"] = c
                r["out"].append(s)
        for key, dest in (("mFluidInputs", "fin"), ("mFluidOutputs", "fout")):
            for o in g.get(key) or []:
                kind, s = self.stack(o)
                if kind == "fluid":
                    r[dest].append(s)
        return self.categories.get(cat, cat), r

    def new(self, *key):
        """True the first time a converted recipe is seen"""
        h = hashlib.blake2b(json.dumps(key, sort_keys=True).encode(), digest_size=12).digest()
        if h in self._conv:
            return False
        self._conv.add(h)
        return True

    def add(self, mode, cls, o, st):
        if "mRecipe" in o or mode == "gt":
            if not isinstance(o.get("mRecipe"), dict):
                st["unknown shape"] += 1
                return
            self.gt_fields.update(o["mRecipe"].keys())
            mp, r = self.gt(o["mRecipe"])
            if self.new("gt", mp, r):
                self.maps[mp].append(r)
                st["kept"] += 1
            return
        if mode == "crafting":
            ins, (kind, out) = self.items(o.get("ingredients")), self.stack(o.get("result"))
            r = {"class": "nei:" + cls.rsplit(".", 1)[-1], "out": out, "in": ins}
            if CRAFTING[cls]:
                r["shapeless"] = True
            dest = self.crafting
        elif mode == "furnace":
            (ik, inp), (kind, out) = self.stack(o.get("ingred")), self.stack(o.get("result"))
            ins = [inp] if ik == "item" else []
            r = {"in": inp, "out": out}
            dest = self.furnace
        else:
            st["unknown shape"] += 1
            return
        if kind != "item" or not ins:
            st["unknown shape"] += 1
            return
        if not self.new(mode, r):
            return
        mod = out["id"].split(":", 1)[0]
        if mod not in self.keep_mods:
            self.other_mods[f"{mode}: {mod}"] += 1
            st["other mod"] += 1
            return
        dest.append(r)
        st["kept"] += 1

    # -- files

    def read(self, path):
        for name, fh in members(path):
            base = name.rsplit("/", 1)[-1]
            if "/handlerformat/" in "/" + name:
                try:
                    fmt = json.load(io.TextIOWrapper(fh, encoding="utf-8")) or {}
                except ValueError:
                    fmt = {}
                self.formats[base[:-5]] = [(f.get("field"), f.get("type")) for f in fmt.get("format") or []]
            elif base.endswith("_recipes.json"):
                self.read_handler(base[:-len("_recipes.json")], fh)
            else:
                self.read_recipe_ids(fh)
        return self

    def unique(self, raw):
        h = hashlib.blake2b(raw, digest_size=12).digest()
        if h in self._raw:
            return False
        self._raw.add(h)
        return True

    def read_handler(self, simple, fh):
        mode = cls = st = None
        for raw in fh:
            raw = raw.strip()
            if not raw:
                continue
            self.lines += 1
            if st is None:
                first = parse(raw)
                if first is None:
                    self.handlers[simple]["broken line"] += 1
                    continue
                cls = first.get("handler") or simple
                mode = ("gt" if "mRecipe" in first else "crafting" if cls in CRAFTING else "furnace" if cls in FURNACE
                        else "keep" if KEEP_HANDLER.match(cls) else "other")
                st = self.handlers[cls]
                st["mode:" + mode] = 1
            st["lines"] += 1
            if not self.unique(raw):
                continue
            st["unique"] += 1
            if mode != "other":
                o = parse(raw)
                if o is None:
                    st["broken line"] += 1
                else:
                    self.add(mode, cls, o, st)

    def read_recipe_ids(self, fh):
        """recipeId.json: NEI's recipe ids of handlers without a format file (no numbers): counted per handler"""
        for raw in fh:
            raw = raw.strip()
            if raw:
                self.lines += 1
                if self.unique(raw):
                    o = parse(raw)
                    self.no_format[(o or {}).get("handlerName") or "(broken line)"] += 1


def parse(raw):
    """a line of the NEI dump as a dict, None for a broken one (a dump cut off while writing)"""
    try:
        o = json.loads(raw)
    except ValueError:
        return None
    return o if isinstance(o, dict) else None


def members(path):
    """(name, binary file) of every .json file of the NEI dump: a zip of recipeid/ or the folder itself"""
    p = Path(path)
    if p.is_dir():
        for f in sorted(p.rglob("*.json")):
            with open(f, "rb") as fh:
                yield "recipeid/" + f.relative_to(p).as_posix(), fh
        return
    with zipfile.ZipFile(p) as z:
        for info in sorted(z.infolist(), key=lambda i: i.filename):
            if info.filename.endswith(".json"):
                with z.open(info) as fh:
                    yield info.filename, fh


def categories(base):
    """GT recipe category -> its map, from the GT5-Unofficial dump"""
    out = {}
    for name, m in base["recipe_maps"].items():
        out[name] = name
        for r in m["recipes"]:
            out.setdefault(r.get("category") or name, name)
    return out


def fits(b, c):
    """a crafting recipe b of the GT5-Unofficial dump takes the ingredients of the NEI recipe c"""
    want = [s for s in b.get("in") or [] if s]
    have = [s["id"] for s in c["in"]]
    if len(want) != len(have):
        return False
    used = [False] * len(have)
    # (plain items first, then lists, then ore dictionary names: the narrowest slots take their item first)
    for s in sorted(want, key=lambda s: 0 if "id" in s else 1 if "any" in s else 2):
        ok = None
        for j, h in enumerate(have):
            if used[j]:
                continue
            if "id" in s:
                hit = same_id(s["id"], h)
            elif "any" in s:
                hit = any(same_id(x["id"], h) for x in s["any"] if isinstance(x, dict) and "id" in x)
            else:
                hit = s.get("ore") in c["_ores"][j]
            if hit:
                ok = j
                break
        if ok is None:
            return False
        used[ok] = True
    return True


def merge(base, nei, pack):
    """the GT5-Unofficial dump base with the NEI dump merged in, and the merge counts"""
    out = copy.deepcopy(base)
    items = out["items"]
    for m in out["recipe_maps"].values():
        for r in m["recipes"]:
            r["source"] = "gt5u"
    for r in out.get("crafting", []) + out.get("furnace", []):
        r["source"] = "gt5u"
    stats = defaultdict(Counter)
    for mp, recipes in sorted(nei.maps.items()):
        m = out["recipe_maps"].get(mp)
        if m is None:
            m = out["recipe_maps"][mp] = {"count": 0, "recipes": [], "nei_only": True}
        idx = defaultdict(list)
        for r in m["recipes"]:
            idx[gt_key(r)].append(r)
        st = stats[mp]
        for r in recipes:
            st["nei"] += 1
            hits = idx.get(gt_key(r))
            if hits:
                b = next((x for x in hits if x["source"] == "gt5u"), hits[0])
                b["source"] = "both"
                st["both"] += 1
                if gt_numbers(b) != gt_numbers(r):
                    st["both, other numbers"] += 1
            else:
                r["source"] = "nei"
                m["recipes"].append(r)
                st["nei only"] += 1
        m["count"] = len(m["recipes"])
    for mp, m in out["recipe_maps"].items():
        stats[mp]["gt5u only"] = sum(1 for r in m["recipes"] if r["source"] == "gt5u")

    by_out = defaultdict(list)
    for b in out.get("crafting", []):
        by_out[(b["out"]["id"], b["out"].get("n", 1))].append(b)
    st = stats["crafting"]
    for c in nei.crafting:
        st["nei"] += 1
        c["_ores"] = [set(items.get(s["id"], {}).get("ore") or ()) for s in c["in"]]
        hit = next((b for b in by_out.get((c["out"]["id"], c["out"]["n"]), []) if fits(b, c)), None)
        del c["_ores"]
        if hit:
            hit["source"] = "both"
            st["both"] += 1
        else:
            c["source"] = "nei"
            out["crafting"].append(c)
            st["nei only"] += 1
    st["gt5u only"] = sum(1 for b in out["crafting"] if b["source"] == "gt5u")
    by_in = defaultdict(list)
    for b in out.get("furnace", []):
        by_in[b["in"]["id"].rsplit(":", 1)[0]].append(b)
    st = stats["furnace"]
    for f in nei.furnace:
        st["nei"] += 1
        hit = next((b for b in by_in.get(f["in"]["id"].rsplit(":", 1)[0], [])
                    if same_id(b["in"]["id"], f["in"]["id"]) and same_id(b["out"]["id"], f["out"]["id"])), None)
        if hit:
            hit["source"] = "both"
            st["both"] += 1
        else:
            f["source"] = "nei"
            out["furnace"].append(f)
            st["nei only"] += 1
    st["gt5u only"] = sum(1 for b in out["furnace"] if b["source"] == "gt5u")

    added = 0
    for key, name in nei.names.items():
        if key not in items:
            items[key] = {"name": name, "source": "nei"}
            added += 1
    out["sources"] = {
        "gt5u": {k: base.get(k) for k in ("gt_version", "git_commit", "git_describe", "created")},
        "nei": {"pack": pack, "fork": FORK, "converted": datetime.date.today().isoformat(), "lines": nei.lines,
                "items_added": added,
                "handlers": {c: dict(st) for c, st in sorted(nei.handlers.items())},
                "no_format": dict(nei.no_format), "other_mods": dict(nei.other_mods)}}
    return out, stats


def report(nei, stats, pack, path):
    lines = [f"# NEI dump merged into the GT5-Unofficial dump (issue #714)", "",
             f"NEI dump: {pack} with {FORK}; {nei.lines} lines.", "",
             "## What the GT handlers carry", "",
             "Keys of the GTRecipe objects (lines with a GTRecipe): "
             + (", ".join(f"`{k}` {n}" for k, n in nei.gt_fields.most_common()) or "none") + ". GT's special value "
             "(coil heat, fusion start energy), the special slot item and the map metadata are not written by the fork.",
             "", "| handler | format fields | lines | unique | kept | other mod | unknown shape | broken |",
             "|---|---|---|---|---|---|---|---|"]
    for cls, st in sorted(nei.handlers.items(), key=lambda kv: -kv[1]["lines"]):
        if not any(st[k] for k in ("kept", "other mod", "unknown shape", "broken line")):
            continue
        fmt = nei.formats.get(cls.rsplit(".", 1)[-1], [])
        fields = ", ".join(f"`{f}` ({re.sub(r'[\w$]+\.', '', t or '?')})" for f, t in fmt) or "(no format file)"
        lines.append(f"| {cls} | {fields} | {st['lines']} | {st['unique']} | {st['kept']} | {st['other mod']} | "
                     f"{st['unknown shape']} | {st['broken line']} |")
    lines += ["", "## Merge per map", "", "Columns: NEI recipes; both (the GT5-Unofficial dump has it, its line is "
              "kept); of them with other EU/t, ticks or chances; NEI only (added); GT5-Unofficial only.", "",
              "| map | NEI | both | both, other numbers | NEI only | GT5-Unofficial only |", "|---|---|---|---|---|---|"]
    tot = Counter()
    for mp, st in sorted(stats.items(), key=lambda kv: -kv[1]["nei"]):
        tot.update(st)
        lines.append(f"| {mp} | {st['nei']} | {st['both']} | {st['both, other numbers']} | {st['nei only']} | "
                     f"{st['gt5u only']} |")
    lines.append(f"| **all** | **{tot['nei']}** | **{tot['both']}** | **{tot['both, other numbers']}** | "
                 f"**{tot['nei only']}** | **{tot['gt5u only']}** |")
    other = Counter()
    for cls, st in nei.handlers.items():
        if st["mode:other"]:
            other[cls] = st["unique"]
    lines += ["", "## Not kept", "", "Handlers of other mods (unique lines): "
              + (", ".join(f"{c} {n}" for c, n in other.most_common()) or "none") + ".", "",
              "Crafting and furnace products of other mods: "
              + (", ".join(f"{c} {n}" for c, n in nei.other_mods.most_common()) or "none") + ".", "",
              "Handlers without a format file (`recipeId.json`): "
              + (", ".join(f"{c} {n}" for c, n in nei.no_format.most_common()) or "none") + "."]
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    Path(path).write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    return tot


def load(path):
    p = Path(path)
    with (gzip.open(p, "rt", encoding="utf-8") if p.suffix == ".gz" else open(p, encoding="utf-8")) as f:
        return json.load(f)


def convert(src, base, pack):
    keep = set(base.get("mods") or {}) | EXTRA_MODS
    nei = Nei(categories(base), keep).read(src)
    merged, stats = merge(base, nei, pack)
    return nei, merged, stats


def selftest():
    """the fixture (nei_fixture/: a few NEI lines of every kind and a small GT5-Unofficial dump) gives the expected
    counts, and tools/gtnh_map.py reads the merged dump"""
    base = load(FIXTURE / "base.json")
    nei, merged, stats = convert(FIXTURE / "recipeid", base, "fixture")
    h = nei.handlers
    expect = [
        (h["gregtech.nei.GTNEIDefaultHandler"]["lines"], 8), (h["gregtech.nei.GTNEIDefaultHandler"]["unique"], 7),
        (h["gregtech.nei.GTNEIDefaultHandler"]["kept"], 6),
        (dict(stats["gt.recipe.macerator"]), {"nei": 2, "both": 2, "gt5u only": 0}),
        (stats["gt.recipe.centrifuge"]["both"], 1), (stats["gt.recipe.centrifuge"]["both, other numbers"], 0),
        (stats["gt.recipe.circuitassembler"]["both, other numbers"], 1),
        (stats["gt.recipe.circuitassembler"]["nei only"], 1), (stats["gt.recipe.fixture_only"]["nei only"], 1),
        (merged["recipe_maps"]["gt.recipe.circuitassembler"]["recipes"][-1]["in"][-1],
         {"id": "gregtech:gt.integrated_circuit:2", "n": 0, "nc": True, "circuit": 2}),
        (h["bartworks.neiHandler.BioLabNEIHandler"]["unknown shape"], 1),
        (dict(stats["crafting"]), {"nei": 3, "both": 1, "nei only": 2, "gt5u only": 0}),
        (dict(nei.other_mods), {"crafting: Thaumcraft": 1}),
        (dict(stats["furnace"]), {"nei": 2, "both": 1, "nei only": 1, "gt5u only": 0}),
        (h["com.djgiannuzz.thaumcraftneiplugin.nei.recipehandler.InfusionRecipeHandler"]["unique"], 1),
        (dict(nei.no_format), {"gendustry.Mutation": 1}),
        (merged["items"]["dreamcraft:item.SteelBars:0"], {"name": "Steel Bars", "source": "nei"}),
        (Counter(r["source"] for r in merged["crafting"]), Counter({"both": 1, "nei": 2})),
    ]
    bad = [(i, got, want) for i, (got, want) in enumerate(expect) if got != want]
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    sources = Counter(r.get("source") for _, r in gtnh_map.gt_recipes(merged) if r)
    # (GT: 4 both, 2 NEI only; crafting: 1 both, 2 NEI only; furnace: 1 both, 1 NEI only)
    if sources != Counter({"both": 6, "nei": 5}):
        bad.append(("gtnh_map sources", dict(sources), None))
    for b in bad:
        print("selftest: FAILED", b)
    print("selftest: " + ("FAILED" if bad else "OK"))
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("nei", nargs="?", help="the zip of .minecraft/recipeid/ or that folder")
    ap.add_argument("--pack", default="GTNH (version not given)", help="the GTNH version the dump was made with")
    ap.add_argument("--base", default=str(GT5U), help="the GT5-Unofficial dump (issue #679)")
    ap.add_argument("--out", default=str(MERGED))
    ap.add_argument("--report", default=str(REPORT))
    ap.add_argument("--selftest", action="store_true", help="run the converter on nei_fixture/ and check the counts")
    a = ap.parse_args()
    if a.selftest:
        return selftest()
    if not a.nei:
        ap.error("the NEI dump (zip or folder) is needed")
    nei, merged, stats = convert(a.nei, load(a.base), a.pack)
    tot = report(nei, stats, a.pack, a.report)
    data = gzip.compress(json.dumps(merged, separators=(",", ":")).encode("utf-8"), 9)
    if len(data) > MAX_BYTES:
        sys.exit(f"the merged dump would be {len(data) / 2 ** 20:.1f} MB (limit {MAX_BYTES / 2 ** 20:.0f} MB): "
                 f"nothing written; report: {a.report}")
    Path(a.out).write_bytes(data)
    print(f"NEI lines {nei.lines}: recipes {tot['nei']} kept, {tot['both']} also in the GT5-Unofficial dump "
          f"({tot['both, other numbers']} with other numbers), {tot['nei only']} added; "
          f"{a.out} ({len(data) / 2 ** 20:.1f} MB); report: {a.report}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
