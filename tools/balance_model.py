"""Full-chain cost model for balance passes (docs/ROADMAP.md, "Balance pass: endgame", issues #30, #31, #33).

Input: the balance dump of devcheck (`python tools/devcheck/devcheck.py check --balance-out dump.json`), i.e. the
final prototypes. For every item, work(item) sums the machine-seconds per machine class (at speed 1) down to the
raw inputs; byproducts are free except the loop fluids in CREDIT. The time of an item in a reference factory is
the largest work / capacity over the classes that limit the endgame: fusion reactors (nested: a MKk recipe runs
in any reactor >= MKk), ZPM assembly lines, circuit assembly lines, bacterial vats and water purification plants.
Recipes of basic machines from IV up are counted but never limit (built as needed), below IV they are commodity.

    python tools/balance_model.py dump.json [--json out.json]
    python tools/balance_model.py dump.json --dtpf     # phase 6a: DTPF route against the fusion route

The fusion reactors are the default route for every metal; the recipes of the dimensionally transcendent plasma
forge and the quantum force transformer (phase 6a) are only used with `dtpf=` (see compare_dtpf).
"""
import json, re, sys, collections, math

TIERS = ["lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv"]
TI = {t: i for i, t in enumerate(TIERS)}
MK_SPEED = {1: 32, 2: 64, 3: 128, 4: 512, 5: 1024}
FUSION_CAT = {  # category -> minimum MK
    "mk1-fusion-reactor-recipes": 1, "luv-fusion-reactor-recipes": 1,
    "mk2-fusion-reactor-recipes": 2, "zpm-fusion-reactor-recipes": 2,
    "mk3-fusion-reactor-recipes": 3, "uv-fusion-reactor-recipes": 3,
    "mk4-fusion-reactor-recipes": 4, "uhv-fusion-reactor-recipes": 4, "uev-fusion-reactor-recipes": 4,
    "mk5-fusion-reactor-recipes": 5, "uiv-fusion-reactor-recipes": 5,
}
FIXED = {  # category -> (class, speed of the best machine)
    "zpm-assembly-line-recipes": ("assembly-line", 32), "luv-assembly-line-recipes": ("assembly-line", 32),
    "iv-assembly-line-recipes": ("assembly-line", 32),
    "luv-circuit-assembly-line-recipes": ("circuit-assembly-line", 64),
    "water-purification-recipes": ("water-purification", 1),
    "bacterial-vat-recipes": ("bacterial-vat", 1),
    "dimensionally-transcendent-plasma-forge-recipes": ("dtpf", 2048),
    "quantum-force-transformer-recipes": ("qft", 2048),
}
DTPF_CAT = "dimensionally-transcendent-plasma-forge-recipes"
OPTIONAL_CATS = {DTPF_CAT, "quantum-force-transformer-recipes"}  # phase 6a: not part of the default route
# metals the DTPF makes (prototypes/139-fork-endgame-multiblocks.lua): molten-X -> molten-X-dtpf-<tier>
DTPF_METALS = ["molten-neutronium", "molten-cosmic-neutronium", "molten-infinity", "molten-transcendent-metal",
               "molten-spacetime", "molten-universium"]
# power per crafting speed (MW): every fusion recipe runs in the MK4/MK5 of the endgame factories
# (327.68 MW / 512, 655.36 MW / 1024), the DTPF draws 1310.72 MW at speed 2048
MW_PER_SPEED = {"fusion": 0.64, "dtpf": 1310.72 / 2048}
FREE_RAW = {"p507"}  # loop reagent of the naquadah line
GLOBAL_OV = {"raw-crystal-chip": "raw-crystal-chip-loop"}  # steady state of the GT loop
CREDIT = {"bacterial-sludge", "p507"}  # loop byproducts: a recipe that returns them is credited


def load(path):
    d = json.load(open(path, encoding="utf-8"))
    R = {x["name"]: x for x in d if x["kind"] == "recipe"}
    C = {x["name"]: x for x in d if x["kind"] == "crafter"}
    T = {x["name"]: x for x in d if x["kind"] == "tech"}
    for r in R.values():
        for k in ("ingredients", "results"):
            if isinstance(r[k], dict):
                r[k] = []
    for c in C.values():
        if isinstance(c["categories"], dict):
            c["categories"] = []
    for t in T.values():
        if isinstance(t["ingredients"], dict):
            t["ingredients"] = []
        if isinstance(t["unlocks"], dict):
            t["unlocks"] = []
        if isinstance(t["prerequisites"], dict):
            t["prerequisites"] = []
    return R, C, T


class Model:
    def __init__(self, path, tier, overrides=None, dtpf=None):
        """dtpf: None (fusion route), "crude" or "resplendent" (the DTPF metals of that catalyst tier)"""
        self.R, self.C, self.T = load(path)
        self.tier = tier
        self.overrides = dict(GLOBAL_OV, **(overrides or {}))
        if dtpf:
            self.overrides.update({m: f"{m}-dtpf-{dtpf}" for m in DTPF_METALS})
        unlocked = set()
        for t in self.T.values():
            if t["enabled"]:
                unlocked.update(t["unlocks"])
        self.usable = {n for n, r in self.R.items()
                       if (r["enabled"] or n in unlocked) and not r["hidden"]
                       and "recycling" not in r["category"] and not n.endswith("-recycling")
                       and r["category"] not in ("fluid-voiding-recipes",)
                       and (dtpf or r["category"] not in OPTIONAL_CATS)}
        self.producers = collections.defaultdict(list)
        for n in self.usable:
            for res in self.R[n]["results"]:
                self.producers[res["name"]].append(n)
        # best basic machine speed per category at this tier
        self.cat_speed = {}
        for c in self.C.values():
            m = re.match(r"(lv|mv|hv|ev|iv|luv|zpm|uv|uhv|uev|uiv|umv|uxv)-", c["name"])
            if m and TI[m.group(1)] > TI[tier]:
                continue
            for cat in c["categories"] or []:
                self.cat_speed[cat] = max(self.cat_speed.get(cat, 0), c["speed"])
        self.memo = {}
        self.choice = {}

    def cls(self, cat):
        if cat in FUSION_CAT:
            return "fusion-mk%d" % FUSION_CAT[cat], 1.0  # fusion work kept at speed 1, divided later
        if cat in FIXED:
            c, sp = FIXED[cat]
            if c == "assembly-line" and TI[self.tier] < TI["zpm"]:
                sp = 16
            return c, sp
        m = re.match(r"^(lv|mv|hv|ev|iv|luv|zpm|uv|uhv|uev|uiv|umv|uxv)-(.*)", cat)
        if not m or TI[m.group(1)] < TI["iv"]:
            return "commodity", self.cat_speed.get(cat, 0) or 1
        return "basic:" + m.group(2), self.cat_speed.get(cat, 0) or 1

    def amount(self, stack):
        a = stack.get("amount")
        if a is None:
            a = (stack.get("amount_min", 0) + stack.get("amount_max", 0)) / 2
        return a * (stack.get("probability") or 1)

    def pick(self, item, stack):
        if item in self.overrides:
            return self.overrides[item]
        cands = list(self.producers.get(item, []))
        if not cands:
            return None
        def score(r):
            rec = self.R[r]
            main = rec["results"][0]["name"] == item
            ing = {i["name"] for i in rec["ingredients"]}
            bootstrap = "bootstrap" in r
            cyc = bool(ing & set(stack)) or item in ing
            m = re.match(r"^(lv|mv|hv|ev|iv|luv|zpm|uv|uhv|uev|uiv|umv|uxv)-", rec["category"])
            tier = TI[m.group(1)] if m else 0
            return (cyc, not main, bootstrap, tier, len(rec["ingredients"]), r)
        return sorted(cands, key=score)[0]

    def work(self, item, stack=()):
        """machine-seconds per class for one unit of item"""
        if item in self.memo:
            return self.memo[item]
        r = None if item in FREE_RAW else self.pick(item, stack)
        w = collections.Counter()
        if r is None:
            self.memo[item] = w
            return w
        self.choice[item] = r
        rec = self.R[r]
        out = sum(self.amount(s) for s in rec["results"] if s["name"] == item)
        # catalysts: net ingredient = ingredient - returned amount
        ret = collections.Counter()
        for s in rec["results"]:
            ret[s["name"]] += self.amount(s)
        if out <= 0:
            self.memo[item] = w
            return w
        c, speed = self.cls(rec["category"])
        w[c] += rec["time"] / speed / out
        for s in rec["results"]:
            n = s["name"]
            if n in CREDIT and n != item and n not in stack:
                ing_amt = sum(self.amount(i) for i in rec["ingredients"] if i["name"] == n)
                extra = self.amount(s) - ing_amt
                if extra > 0:
                    for k, v in self.work(n, stack + (item,)).items():
                        w[k] -= v * extra / out
        for s in rec["ingredients"]:
            n = s["name"]
            net = self.amount(s) - (ret[n] if n != item else 0)
            if net <= 0 or n in stack or n == item:
                continue
            sub = self.work(n, stack + (item,))
            for k, v in sub.items():
                w[k] += v * net / out
        self.memo[item] = w
        return w

    def raw_counts(self, item, qty=1.0):
        """expanded quantity of every intermediate per `qty` of item (memoized per unit)"""
        if not hasattr(self, "qmemo"):
            self.qmemo = {}
        self.work(item)
        def q(it, stack=()):
            if it in self.qmemo:
                return self.qmemo[it]
            acc = collections.Counter({it: 1.0})
            r = self.choice.get(it)
            if r is not None:
                rec = self.R[r]
                out = sum(self.amount(s) for s in rec["results"] if s["name"] == it)
                ret = collections.Counter()
                for s in rec["results"]:
                    ret[s["name"]] += self.amount(s)
                for s in rec["ingredients"]:
                    n = s["name"]
                    net = self.amount(s) - (ret[n] if n != it else 0)
                    if net > 0 and n not in stack and n != it:
                        for k, v in q(n, stack + (it,)).items():
                            acc[k] += v * net / out
            self.qmemo[it] = acc
            return acc
        return collections.Counter({k: v * qty for k, v in q(item).items()})


def fusion_time(w, reactors):
    """reactors: {mk: count}; nested capacity"""
    t = 0.0
    for k in range(1, 6):
        need = sum(v for c, v in w.items() if c.startswith("fusion-mk") and int(c[-1]) >= k)
        cap = sum(MK_SPEED[m] * n for m, n in reactors.items() if m >= k)
        if need > 0:
            t = max(t, need / cap if cap else math.inf)
    return t


def part_time(w, factory):
    """seconds for one unit in the factory; returns (time, bottleneck class, per-class times)"""
    per = {}
    per["fusion"] = fusion_time(w, factory["fusion"])
    for c, v in w.items():
        if c.startswith("fusion-mk") or c == "commodity":
            continue
        n = factory["count"].get(c, factory["count"].get("basic", 1)) if c.startswith("basic:") else factory["count"].get(c, 1)
        per[c] = v / n if n else math.inf
    b = max(per, key=per.get)
    return per[b], b, per


# Reference factory per tier: one power unit = 12.5 large plasma turbines of the tier on helium plasma
# (LuV 1 MK1, ZPM 1 MK2, UV 2 MK2, UHV 2 MK3, UEV 1 MK4, UIV 1 MK5, UMV 2 MK5, UXV 4 MK5).
# Metal reactors: twice the power reactors of the newest MK plus 2 of the MK before.
def fac(power, fusion, lines, vats, plants, dtpf=0):
    return {"power": power, "fusion": fusion,
            "count": {"assembly-line": lines, "circuit-assembly-line": lines, "bacterial-vat": vats,
                      "water-purification": plants, "basic": 10 ** 9, "dtpf": dtpf, "qft": 10 ** 9}}
FACTORY = {
    "luv": fac({1: 1}, {1: 2},       1, 4, 1),
    "zpm": fac({2: 1}, {2: 2, 1: 2}, 2, 4, 1),
    "uv":  fac({2: 2}, {2: 4, 1: 2}, 2, 8, 2),
    "uhv": fac({3: 2}, {3: 4, 2: 2}, 2, 8, 2),
    "uev": fac({4: 1}, {4: 2, 3: 2}, 4, 16, 4),
    "uiv": fac({5: 1}, {5: 2, 4: 2}, 4, 16, 4),
    "umv": fac({5: 2}, {5: 4, 4: 2}, 8, 32, 8),
    "uxv": fac({5: 4}, {5: 8, 4: 2}, 8, 32, 8),
}


COMP = ["motor", "pump", "conveyor-module", "piston", "robot-arm", "emitter", "sensor", "field-generator"]
TIER_OV = {t: {"molten-neutronium": "molten-neutronium-bootstrap"} for t in ("luv", "zpm", "uv")}
ITEMS = {  # tier of the factory that makes it -> items
    "uv": [f"uv-{c}" for c in COMP] + ["uv-energy-hatch", "agricultural-science-pack", "uv-circuit"],
    "uhv": [f"uhv-{c}" for c in COMP if c != "field-generator"] + ["uhv-energy-hatch", "electromagnetic-science-pack", "uhv-circuit", "fusion-reactor-mk3-controller"],
    "uev": ["uhv-field-generator"] + [f"uev-{c}" for c in COMP] + ["uev-energy-hatch", "cryogenic-science-pack", "uev-circuit", "fusion-reactor-mk4-controller"],
    "uiv": [f"uiv-{c}" for c in COMP] + ["uiv-energy-hatch", "promethium-science-pack", "uiv-circuit", "fusion-reactor-mk5-controller"],
    "umv": [f"umv-{c}" for c in COMP if c != "field-generator"] + ["umv-energy-hatch", "umv-science-pack", "umv-circuit"],
    "uxv": ["umv-field-generator"] + [f"uxv-{c}" for c in COMP] + ["uxv-energy-hatch", "uxv-science-pack", "uxv-circuit",
            "stargate-frame-part", "stargate-radiation-containment-plate", "stargate-chevron", "stargate-iris-blade",
            "stargate-ring-block", "stargate-chevron-block", "stargate-base", "stargate-power-unit", "stargate-controller",
            "stargate-chevron-upgrade", "stargate-iris-upgrade", "stargate", "max-science-pack"],
}


PACKS = ["automation", "logistic", "military", "chemical", "production", "utility", "space", "metallurgic",
         "agricultural", "electromagnetic", "cryogenic", "promethium", "umv", "uxv", "max"]
PACK_TIER = dict(zip([p + "-science-pack" for p in PACKS],
                     ["steam", "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"]))
LABS = 20 * 3.7  # 20 labs with research speed 6

# Phase 6a: the reference factory of a tier with n DTPFs of the same power as the MK5 metal reactors they
# replace (one DTPF, 1310.72 MW, for two MK5); the rest of the factory is unchanged
def dtpf_factory(tier, n):
    f = FACTORY[tier]
    fusion = dict(f["fusion"])
    fusion[5] -= 2 * n
    return fac(f["power"], fusion, f["count"]["assembly-line"], f["count"]["bacterial-vat"],
               f["count"]["water-purification"], dtpf=n)


def best_dtpf_split(w, tier):
    """(time, n DTPFs) for the split of the MK5 metal reactors that makes the item fastest"""
    return min((part_time(w, dtpf_factory(tier, n))[0], n) for n in range(1, FACTORY[tier]["fusion"][5] // 2 + 1))


INGOT = 14.4  # mB per ingot


def energy(w):
    """GJ of fusion reactors and DTPFs for one unit (work at speed 1 for fusion, seconds of one DTPF)"""
    e = sum(v for c, v in w.items() if c.startswith("fusion-mk")) * MW_PER_SPEED["fusion"]
    e += w.get("dtpf", 0) * MW_PER_SPEED["dtpf"] * 2048
    return e / 1000


def compare_dtpf(f):
    """DTPF route against the fusion route: per ingot (energy of the metal machines, inputs) and per item in
    the reference factory with DTPFs of the same power as the MK5s they replace (the best split)"""
    sys.setrecursionlimit(10000)
    out = {"ingot": {}, "items": {}}
    routes = {"fusion": Model(f, "uxv"), "crude": Model(f, "uxv", dtpf="crude"),
              "resplendent": Model(f, "uxv", dtpf="resplendent")}
    melts = ["molten-americium", "molten-naquadria", "molten-tritanium", "molten-draconium", "krypton-plasma",
             "molten-flerovium", "molten-neutronium", "molten-cosmic-neutronium", "molten-infinity",
             "molten-transcendent-metal", "molten-rhugnor", "molten-spacetime"]
    for metal in DTPF_METALS:
        out["ingot"][metal] = {}
        for route, m in routes.items():
            q = m.raw_counts(metal, INGOT)
            out["ingot"][metal][route] = {"gj": energy(m.work(metal)) * INGOT,
                                          "inputs": {k: q[k] / INGOT for k in melts if q.get(k) and k != metal}}
    items = ["uxv-motor", "uxv-field-generator", "uxv-science-pack", "umv-science-pack", "stargate"]
    for it in items:
        tier = "umv" if it == "umv-science-pack" else "uxv"
        w = Model(f, tier).work(it)
        row = {"fusion": part_time(w, FACTORY[tier])[0], "gj": {"fusion": energy(w)}, "split": {}}
        for t in ("crude", "resplendent"):
            if tier == "umv" and t == "resplendent":
                continue  # the resplendent catalyst is UXV science
            w = Model(f, tier, dtpf=t).work(it)
            row[t], row["split"][t] = best_dtpf_split(w, tier)
            row["gj"][t] = energy(w)
        out["items"][it] = {"tier": tier, **row}
    return out


def fmt(s):
    return f"{s/3600:.1f} h" if s >= 5400 else f"{s/60:.1f} min"

def run(f, verbose=True):
    res = {"parts": {}, "research": {}}
    models = {}
    for tier, items in ITEMS.items():
        m = models[tier] = Model(f, tier, TIER_OV.get(tier, {}))
        for it in items:
            w = m.work(it)
            t, b, per = part_time(w, FACTORY[tier])
            tx, bx, _ = part_time(w, FACTORY["uxv"])
            res["parts"][it] = {"tier": tier, "time": t, "bottleneck": b, "uxv_time": tx,
                                "per": {k: v for k, v in per.items()}}
    # research: techs whose highest pack is UIV or above, in the factory of their highest pack
    mx = models["uxv"]
    for n, t in mx.T.items():
        if not t["enabled"] or not t["ingredients"]:
            continue
        top = t["ingredients"][-1]["name"]
        if PACK_TIER.get(top) not in ("luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"):
            continue
        tier = {"max": "uxv"}.get(PACK_TIER[top], PACK_TIER[top])
        if tier not in models:
            models[tier] = Model(f, tier, TIER_OV.get(tier, {}))
        m = models[tier]
        count = t.get("count") or eval(t["count_formula"].replace("^", "**").replace("L", "1"))
        w = collections.Counter()
        packs = {}
        for ing in t["ingredients"]:
            q = count * ing["amount"]
            packs[ing["name"]] = q
            for k, v in m.work(ing["name"]).items():
                w[k] += v * q
        pt, b, per = part_time(w, FACTORY[tier])
        lab = count * t["time"] / LABS
        res["research"][n] = {"tier": tier, "count": count, "unit_time": t["time"], "pack_time": pt, "bottleneck": b,
                              "lab_time": lab, "packs": {k: v for k, v in packs.items() if PACK_TIER[k] in ("uiv", "umv", "uxv", "max")}, "top": top}
    return res

if __name__ == "__main__":
    sys.setrecursionlimit(10000)
    if "--dtpf" in sys.argv:
        c = compare_dtpf(sys.argv[1])
        for metal, routes in c["ingot"].items():
            f0 = routes["fusion"]["gj"]
            print(metal, "  ".join(f"{r}: {x['gj']:.1f} GJ/ingot (x{f0 / x['gj']:.2f})" for r, x in routes.items()))
            for r, x in routes.items():
                print(f"    {r:12s}", ", ".join(f"{k} {v:.3g}" for k, v in x["inputs"].items()))
        for it, x in c["items"].items():
            print(f"{x['tier']:4s} {it:22s}", "  ".join(
                f"{r} {fmt(x[r])}" + (f" ({x['split'][r]} DTPF)" if r in x["split"] else "") + f" {x['gj'][r]:.0f} GJ"
                for r in ("fusion", "crude", "resplendent") if r in x))
        sys.exit(0)
    r = run(sys.argv[1])
    if "--json" in sys.argv:
        json.dump(r, open(sys.argv[sys.argv.index("--json") + 1], "w"), indent=1)
    for it, p in r["parts"].items():
        print(f"{p['tier']:4s} {it:38s} {fmt(p['time']):>10s} {p['bottleneck']:22s} uxv-factory {fmt(p['uxv_time']):>10s}")
    tot = collections.Counter()
    for n, x in sorted(r["research"].items(), key=lambda kv: (kv[1]["tier"], kv[0])):
        tot[x["tier"]] += x["pack_time"]
        print(f"{x['tier']:4s} {n:34s} {x['count']:6.0f} x {x['unit_time']:5.0f}s packs {fmt(x['pack_time']):>9s} ({x['bottleneck']}) labs {fmt(x['lab_time']):>9s}  {x['packs']}")
    print({k: fmt(v) for k, v in tot.items()})
