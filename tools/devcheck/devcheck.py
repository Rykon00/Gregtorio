#!/usr/bin/env python3
"""Headless test harness for Gregtorio (Linux, e.g. cloud sessions / CI).

    python tools/devcheck/devcheck.py setup     # download headless Factorio + dependency mods
    python tools/devcheck/devcheck.py check     # load the mod and run all static checks
    python tools/devcheck/devcheck.py runtime   # place every machine on a map and run it
    python tools/devcheck/devcheck.py migrate --from-ref 0e935ba
                                                # create a save with an older version (git ref or
                                                # --from-zip), load it with the working copy
    python tools/devcheck/devcheck.py all       # check + runtime
    python tools/devcheck/devcheck.py menusim --sim all --compare
                                                # run the main menu simulations with and without the mod
    python tools/devcheck/devcheck.py handover  # issue #83: prototype of the ME state hand-over to me-network

Everything is kept in .devcheck/ in the repository root (git-ignored).

Setup needs network access to factorio.com and *.factorio.com. The required dependency
mods (see info.json) are downloaded from the mod portal, which needs a Factorio account:
set FACTORIO_USERNAME and FACTORIO_TOKEN (token: factorio.com -> your profile), or put the
zips into a folder and pass --mods-from DIR.

`check` fails (exit code 1) when any of these is true:
  * the mod does not load
  * a recipe/tech still references a missing prototype after the draft guard
  * a referenced __gregtorio-continued__/ file does not exist (headless Factorio does not load graphics,
    the real game crashes on missing files)
  * a sprite sheet is smaller than its width/height/frame_count need
  * an unlocked recipe cannot be crafted: no machine for its category, an ingredient that can
    never be obtained, or no reachable machine with enough fluid inputs/outputs
  * an enabled technology cannot be researched and is not in UNRESEARCHABLE_OK (the vanilla
    armor/equipment techs), or one of the issue #29 QoL techs is neither researchable nor hidden
  * a fluid that is not hidden (the parameter fluids excepted) is not in the Fluids tab: its subgroup is missing or
    not in the item group "fluids"; fluids in the fallback row gregtorio-fluids-unsorted are a warning
It also reports how many technologies are researchable and where progression stops.
"""
import argparse, json, os, re, shutil, subprocess, sys, tarfile, urllib.parse, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
WORK = ROOT / ".devcheck"
FACTORIO = WORK / "factorio"
MODS = WORK / "mods"
LOG = WORK / "last-run.log"
# `runtime` and `migrate` create their maps with this seed, so a run is reproducible (issue #47);
# `--seed N` or `--seed random` picks another one, the output prints the seed of every run
DEFAULT_SEED = 3115102263
BUILTIN = {"base", "core", "space-age", "quality", "elevated-rails"}


# --------------------------------------------------------------------------------------------
# setup
# --------------------------------------------------------------------------------------------

# factorio.com (Cloudflare) answers the default "Python-urllib" user agent with 403
USER_AGENT = "gregtorio-devcheck/1.0 (+https://github.com/Rykon00/Gregtorio)"


def urlopen(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": USER_AGENT}))


def download(url, dest):
    print(f"downloading {url.split('?')[0]}")
    with urlopen(url) as r, open(dest, "wb") as f:
        shutil.copyfileobj(r, f)


def required_mods():
    info = json.loads((ROOT / "info.json").read_text(encoding="utf-8"))
    out = []
    for dep in info.get("dependencies", []):
        dep = dep.strip()
        if dep[:1] in "?!(~":
            continue
        name = re.split(r"\s*[<>=]", dep)[0].strip()
        if name not in BUILTIN:
            out.append(name)
    return out


def setup(a):
    WORK.mkdir(exist_ok=True)
    binary = FACTORIO / "bin/x64/factorio"
    if a.factorio:
        if FACTORIO.exists() or FACTORIO.is_symlink():
            FACTORIO.unlink() if FACTORIO.is_symlink() else shutil.rmtree(FACTORIO)
        FACTORIO.symlink_to(Path(a.factorio).resolve(), target_is_directory=True)
    elif not binary.exists():
        tar = WORK / "factorio-headless.tar.xz"
        download(f"https://factorio.com/get-download/{a.version}/headless/linux64", tar)
        with tarfile.open(tar) as t:
            t.extractall(WORK)
        tar.unlink()
    print("factorio:", subprocess.run([str(binary), "--version"], capture_output=True, text=True).stdout.splitlines()[0])

    MODS.mkdir(exist_ok=True)
    for name in required_mods():
        if list(MODS.glob(f"{name}_*.zip")) or (name == ME_NETWORK and me_network_dir()):
            continue
        if a.mods_from:
            found = sorted(Path(a.mods_from).glob(f"{name}_*.zip"))
            if not found:
                sys.exit(f"{name}_*.zip not found in {a.mods_from}")
            shutil.copy2(found[-1], MODS / found[-1].name)
            print(f"copied {found[-1].name}")
            continue
        user, token = os.environ.get("FACTORIO_USERNAME"), os.environ.get("FACTORIO_TOKEN")
        if not user or not token:
            sys.exit(f"need {name}: set FACTORIO_USERNAME/FACTORIO_TOKEN or pass --mods-from DIR")
        meta = json.load(urlopen(f"https://mods.factorio.com/api/mods/{urllib.parse.quote(name)}"))
        rel = [r for r in meta["releases"] if r["info_json"].get("factorio_version") == "2.0"][-1]
        q = urllib.parse.urlencode({"username": user, "token": token})
        download(f"https://mods.factorio.com{rel['download_url']}?{q}", MODS / rel["file_name"])
    print("setup done")


# --------------------------------------------------------------------------------------------
# running factorio
# --------------------------------------------------------------------------------------------

MOD_NAMES = ("Gregtorio", "gregtorio-continued")   # the mod before and since 0.3.0
ME_NETWORK = "me-network"                           # the ME network since issue #83 (docs/SPLIT.md), a dependency


def me_network_dir():
    """me-network as a checkout: ME_NETWORK_DIR, else the sibling ../me-network; None: the me-network_*.zip in
    .devcheck/mods is used (setup downloads it from the mod portal like the other dependencies)"""
    d = Path(os.environ.get("ME_NETWORK_DIR") or (ROOT.parent / ME_NETWORK))
    return d if (d / "info.json").exists() else None


def needs_me_network(info):
    return any(re.split(r"\s*[<>=]", dep.strip())[0].strip() == ME_NETWORK for dep in info.get("dependencies", []))


def zip_info(path):
    """info.json of a mod zip"""
    import zipfile
    with zipfile.ZipFile(path) as z:
        return json.loads(z.read(next(n for n in z.namelist() if n.endswith("/info.json") and n.count("/") == 1)))


def link_dir(link, target):
    """Directory link; on Windows without symlink rights a junction (never follow it when deleting)."""
    try:
        link.symlink_to(target, target_is_directory=True)
    except OSError:
        if os.name != "nt":
            raise
        subprocess.run(["cmd", "/c", "mklink", "/J", str(link), str(target)], check=True, capture_output=True)


def remove_path(p):
    if p.is_symlink() or (hasattr(p, "is_junction") and p.is_junction()):
        os.rmdir(p) if os.name == "nt" and p.is_dir() else p.unlink()
    elif p.is_file():
        p.unlink()
    elif p.exists():   # a run whose load failed leaves no mod-settings.dat
        shutil.rmtree(p)


def prepare_mods(with_runtime=False, gregtorio_zip=None, with_migrate=False, menusim=None, gregtorio=True,
                 settings=None):
    """mods/ = dependency zips + the mod (working copy or a zip) + devcheck helper mods.
    menusim: name of a main menu simulation for the menusim helper mod; gregtorio=False leaves the mod out.
    settings: {startup setting name: bool} forced for this run (`check --set`); without it every setting has its
    default, because mod-settings.dat is removed (a value stored by an earlier run would win over the default)."""
    remove_path(MODS / "mod-settings.dat")
    for p in MODS.iterdir():
        if p.name.startswith(MOD_NAMES + ("zz-gregtorio-devcheck",)) or p.name == "mod-list.json" or (
                p.name == ME_NETWORK and not p.is_file()):
            remove_path(p)
    if not gregtorio:
        info = None
    elif gregtorio_zip:
        info = zip_info(gregtorio_zip)
        # Factorio insists on <name>_<version>.zip
        shutil.copy2(gregtorio_zip, MODS / f"{info['name']}_{info['version']}.zip")
    else:
        info = json.loads((ROOT / "info.json").read_text(encoding="utf-8"))
        link_dir(MODS / info["name"], ROOT)
    link_dir(MODS / "zz-gregtorio-devcheck", HERE / "checkmod")
    enabled = ["base", "space-age", "quality", "elevated-rails"] + ([info["name"]] if info else []) + ["zz-gregtorio-devcheck"]
    zips = [z.name.rsplit("_", 1)[0] for z in MODS.glob("*.zip") if not z.name.startswith(MOD_NAMES)]
    enabled += [n for n in zips if n != ME_NETWORK]
    disabled = []
    if info and needs_me_network(info):
        # issue #83: a me-network checkout (ME_NETWORK_DIR or ../me-network) wins over the portal zip
        if me_network_dir():
            link_dir(MODS / ME_NETWORK, me_network_dir())
        enabled.append(ME_NETWORK)
    elif ME_NETWORK in zips:
        # older versions of the mod (migrate) contain the ME network themselves and refuse to load next to it
        disabled.append(ME_NETWORK)
    if with_runtime:
        link_dir(MODS / "zz-gregtorio-devcheck-runtime", HERE / "runtimemod")
        enabled.append("zz-gregtorio-devcheck-runtime")
    if with_migrate:
        link_dir(MODS / "zz-gregtorio-devcheck-migrate", HERE / "migratemod")
        enabled.append("zz-gregtorio-devcheck-migrate")
    if menusim:
        # a copy, not a link: config.lua names the simulation to run
        shutil.copytree(HERE / "menusimmod", MODS / "zz-gregtorio-devcheck-menusim")
        (MODS / "zz-gregtorio-devcheck-menusim" / "config.lua").write_text(f"return {{ name = {json.dumps(menusim)} }}\n")
        enabled.append("zz-gregtorio-devcheck-menusim")
    if settings:
        # a generated mod: forces the settings in the settings stage, after the mod defined them
        d = MODS / "zz-gregtorio-devcheck-settings"
        d.mkdir()
        (d / "info.json").write_text(json.dumps({
            "name": "zz-gregtorio-devcheck-settings", "version": "1.0.0", "title": "Gregtorio devcheck settings",
            "author": "rykon_", "factorio_version": "2.0", "dependencies": ["? " + n for n in MOD_NAMES]}))
        (d / "settings-final-fixes.lua").write_text("".join(
            f"do local s = data.raw['bool-setting'][{json.dumps(n)}] "
            f"assert(s, 'devcheck --set: no bool setting ' .. {json.dumps(n)}) "
            f"s.hidden = true s.forced_value = {'true' if v else 'false'} s.default_value = s.forced_value end\n"
            for n, v in settings.items()))
        enabled.append("zz-gregtorio-devcheck-settings")
    (MODS / "mod-list.json").write_text(json.dumps({"mods": [{"name": n, "enabled": True} for n in enabled]
                                                    + [{"name": n, "enabled": False} for n in disabled]}))


def factorio(*args):
    binary = FACTORIO / ("bin/x64/factorio.exe" if os.name == "nt" else "bin/x64/factorio")
    if not binary.exists():
        sys.exit("run `devcheck.py setup` first")
    r = subprocess.run([str(binary), "--mod-directory", str(MODS), *args], capture_output=True, text=True)
    LOG.write_text(r.stdout + r.stderr)
    return r.stdout + r.stderr


def sections(log):
    out = {}
    for m in re.finditer(r"DEVCHECK-([A-Z]+)-BEGIN\n(.*?)\nDEVCHECK-\1-END", log, re.S):
        out[m.group(1)] = [l.split("\t") for l in m.group(2).splitlines() if l]
    return out


def load_errors(log):
    if "Map version" in log or "Performed" in log:
        return None
    m = re.search(r"(Error.*?)(\n\s*\d+\.\d+ |\Z)", log, re.S)
    return m.group(1).strip() if m else "unknown error (see .devcheck/last-run.log)"


def script_error(log):
    """the first error of a mod's event handler (e.g. me-network refusing an old save in on_configuration_changed),
    which load_errors misses because the map itself was read"""
    m = re.search(r"Error while running event (\S+)\n(.*?)(?=\nstack traceback|\n-{5}|\Z)", log, re.S)
    return (m.group(1) + ": " + " ".join(l.strip() for l in m.group(2).splitlines() if l.strip())) if m else None


def not_saved(log):
    """--create runs on_init and then saves; a failed save (e.g. a function in `storage`) or an error in on_init
    (e.g. a test helper calling a remote function the mod version does not have) keeps the previous map file, so
    the next run would test an old map and report its results"""
    m = re.search(r"Writing .* failed.*|Error while running event .*\n.*", log)
    return "the map was not saved: " + m.group(0).strip() if m else None


# --------------------------------------------------------------------------------------------
# analysis
# --------------------------------------------------------------------------------------------

class Model:
    def __init__(self, rows):
        split = lambda s: [x.split(":", 1)[1] for x in s.split(",") if x]
        kinds = lambda s: [x.split(":", 1)[0] for x in s.split(",") if x]
        self.R, self.C, self.CF, self.I, self.T = {}, {}, {}, {}, {}
        self.burnt, self.burners = [], {}   # (fuel item, burnt result, fuel category); burner entity -> categories
        self.base = {"water", "steam"}
        for p in rows:
            k = p[0]
            if k == "R":
                self.R[p[1]] = dict(cat=p[2], en=p[3] == "true", ing=split(p[4]), res=split(p[5]),
                                    fin=kinds(p[4]).count("fluid"), fout=kinds(p[5]).count("fluid"),
                                    hidden=p[6] == "true", hide_craft=p[7] == "true", sg=p[8], group=p[9],
                                    icon=p[10] if len(p) > 10 else "")
            elif k == "C":
                self.C[p[1]] = p[3].split(",") if p[3] else []
                self.CF[p[1]] = (int(p[4]), int(p[5]))
            elif k == "I":
                self.I[p[1]] = p[3]
            elif k == "T":
                self.T[p[1]] = dict(pre=[x for x in p[2].split(",") if x], eff=[x for x in p[3].split(",") if x],
                                    sci=[x for x in p[4].split(",") if x], trig=p[5], en=p[6] == "true")
            elif k == "M" and p[4] != "gregtorio-disabled":
                if p[2]:
                    self.base.add(p[2])
                self.base.update(x.split(":", 1)[1] for x in p[3].split(",") if x)
            elif k == "O" and p[2]:
                self.base.add(p[2])
            elif k == "B":
                self.burnt.append((p[1], p[2], p[3]))
            elif k == "U":
                self.burners[p[1]] = p[2].split(",")
        self.solve()

    def solve(self):
        """Fixed point: what can be obtained, crafted and researched from the start."""
        R, C, T = self.R, self.C, self.T
        item_of = {}
        for it, pr in self.I.items():
            if pr:
                item_of.setdefault(pr, []).append(it)
        self.avail, self.researched = set(self.base), set()
        self.unlocked = {r for r, v in R.items() if v["en"]}
        self.crafters = {"character"}
        changed = True
        while changed:
            changed = False
            for e in C:
                if e not in self.crafters and any(i in self.avail for i in item_of.get(e, [])):
                    self.crafters.add(e)
                    changed = True
            cats = {c for m in self.crafters for c in C.get(m, [])}
            for r in self.unlocked:
                v = R[r]
                if v["cat"] in cats and all(i in self.avail for i in v["ing"]):
                    for x in v["res"]:
                        if x not in self.avail:
                            self.avail.add(x)
                            changed = True
            # a fuel burnt in a burner that can be built leaves its burnt result (the depleted fuel rods)
            fuel_cats = {c for e, cs in self.burners.items() if any(i in self.avail for i in item_of.get(e, []))
                         for c in cs}
            for fuel, burnt, cat in self.burnt:
                if fuel in self.avail and cat in fuel_cats and burnt not in self.avail:
                    self.avail.add(burnt)
                    changed = True
            for t, v in T.items():
                if t in self.researched or not v["en"] or not all(p in self.researched for p in v["pre"]):
                    continue
                if v["sci"] and not all(s in self.avail for s in v["sci"]):
                    continue
                m = re.search(r'item = "([^"]+)"', v["trig"])
                if m and "craft" in v["trig"] and m.group(1) not in self.avail:
                    continue
                self.researched.add(t)
                changed = True
                self.unlocked.update(r for r in v["eff"] if r in R)
        self.cats = {c for m in self.crafters for c in C.get(m, [])}

    def frontier(self):
        out = []
        for t, v in sorted(self.T.items()):
            if t not in self.researched and v["en"] and all(p in self.researched for p in v["pre"]):
                out.append((t, [s for s in v["sci"] if s not in self.avail]))
        return out

    def blockers(self, t, seen=None):
        """Root causes why a technology cannot be researched: disabled or missing prerequisites (recursively),
        science packs nobody can make, a craft trigger nobody can satisfy."""
        seen = seen if seen is not None else set()
        if t in seen:
            return []
        seen.add(t)
        v = self.T.get(t)
        if v is None:
            return [f"{t} (does not exist)"]
        if not v["en"]:
            return [f"{t} (disabled)"]
        out = []
        for p in v["pre"]:
            if p not in self.researched:
                out += self.blockers(p, seen)
        missing = [x for x in v["sci"] if x not in self.avail]
        if missing:
            out.append(f"{t} (no way to make {', '.join(missing)})")
        if not out and t not in self.researched:
            out.append(f"{t} (craft trigger or unknown)")
        return out

    def uncraftable(self):
        out = []
        for r in sorted(self.unlocked):
            v = self.R[r]
            if r.endswith("-recycling") or r.startswith("void-") or v["cat"] in ("recycling", "parameters"):
                continue
            missing = [i for i in v["ing"] if i not in self.avail]
            machines = [m for m in self.crafters if v["cat"] in self.C.get(m, [])]
            if not machines:
                out.append((r, f"no machine for category {v['cat']}"))
            elif missing:
                out.append((r, "ingredients never obtainable: " + ", ".join(missing)))
            elif (v["fin"] or v["fout"]) and not any(
                    self.CF.get(m, (0, 0))[0] >= v["fin"] and self.CF.get(m, (0, 0))[1] >= v["fout"] for m in machines):
                out.append((r, f"needs {v['fin']} fluid in / {v['fout']} out, no reachable machine has that"))
        return out


def check_crafting_menu(m, sec):
    """Issue #49: every recipe that is enabled or unlocked by a technology and whose category has a
    machine is listed in the crafting menu (not hide_from_player_crafting), except the allow-list
    FORK_CRAFTING_MENU_HIDDEN of prototypes/198-fork-crafting-menu.lua. Returns (info lines, problems)."""
    rows = sec.get("CRAFTMENU", [])
    setting = next((r[1] for r in rows if r[0] == "setting"), "absent")
    allow = {k: {} for k in ("categories", "subgroups", "recipes")}
    for r in rows:
        if r[0] in allow:
            allow[r[0]][r[1]] = r[2]
    if setting == "false":
        return ["skipped: startup setting gregtorio-continued-show-machine-recipes is off"], []
    machine_cats = {c for e, cats in m.C.items() if e != "character" for c in cats}
    reach = {r for r, v in m.R.items() if v["en"]}
    for v in m.T.values():
        if v["en"]:
            reach.update(r for r in v["eff"] if r in m.R)
    shown, kept, problems, tabs = 0, 0, [], {}
    for r in sorted(reach):
        v = m.R[r]
        if v["hidden"]:
            continue
        if not v["hide_craft"]:
            tabs[v["group"]] = tabs.get(v["group"], 0) + 1
        if v["cat"] not in machine_cats:
            continue
        if not v["hide_craft"]:
            shown += 1
        elif v["cat"] in allow["categories"] or v["sg"] in allow["subgroups"] or r in allow["recipes"]:
            kept += 1
        else:
            problems.append(f"{r} (category {v['cat']}, subgroup {v['sg']})")
    stale = [f"{k} {n} (allow-list entry matches nothing)" for k, names in allow.items() for n in names
             if (k == "recipes" and n not in m.R) or (k == "categories" and not any(v["cat"] == n for v in m.R.values()))
             or (k == "subgroups" and not any(v["sg"] == n for v in m.R.values()))]
    info = [f"machine recipes (enabled or unlocked by a technology): {shown} shown, {kept} kept hidden by the "
            f"allow-list, {len(problems)} hidden without an allow-list entry",
            "recipes shown per crafting menu tab: " + ", ".join(f"{g} {n}" for g, n in sorted(tabs.items(), key=lambda x: -x[1]))]
    return info, problems + stale


FLUID_FALLBACK = "gregtorio-fluids-unsorted"
MICROMINER_TAB = "microminer-tab"


def check_fluids_tab(sec):
    """Every fluid that is not hidden is in the Fluids tab: its subgroup belongs to the group "fluids" (Factorio puts
    a fluid without one into "Unsorted"); the base game's parameter fluids are excepted. The check covers every fluid
    of the devcheck load (vanilla, Gregtorio and its dependencies), so a vanilla fluid that Gregtorio redefines
    counts too. Returns (info lines, fluids in the fallback row as a warning, problems)."""
    rows, fallback, problems = {}, [], []
    for name, sg, group, _sgo, hidden, param, *_ in sec.get("FLUIDS", []):
        if hidden == "true" or param == "true":
            continue
        if group != "fluids":
            problems.append(f"{name} (subgroup {sg}, group {group})")
            continue
        rows[sg] = rows.get(sg, 0) + 1
        if sg == FLUID_FALLBACK:
            fallback.append(name)
    info = [f"{sum(rows.values())} fluids in {len(rows)} rows: " + ", ".join(f"{sg} {n}" for sg, n in rows.items())]
    return info, sorted(fallback), sorted(problems)


TABLE_MACHINES = {"crafting-table", "me-molecular-assembler"}


def check_table_only(m, sec):
    """Issue #126 (prototypes/148-fork-gtnh-table-items.lua): an item that can only be made at the crafting table, in the ME
    Molecular Assembler or by hand cannot be automated (the ME Molecular Assembler apart). GregTech New Horizons decides: a
    reachable item whose every recipe is such a recipe fails unless the recipes are in the allow-list
    FORK_RECIPES_TABLE_ONLY with their reason; an entry that is not (or no longer) such a recipe fails too. A recipe is
    "table or hand only" when no obtainable machine but the crafting table and the ME Molecular Assembler has its category
    (the character is not a machine). Returns (info line, problems)."""
    allow = {r[0]: r[1] for r in sec.get("TABLEONLYOK", [])}
    machines = {}
    def table_only(r):
        cat = m.R[r]["cat"]
        if cat not in machines:
            machines[cat] = {e for e in m.crafters if e != "character" and cat in m.C.get(e, [])}
        return not (machines[cat] - TABLE_MACHINES)
    makers = {}
    for r in sorted(m.unlocked):
        v = m.R[r]
        if v["hidden"] or r.endswith("-recycling") or r.startswith("void-") or v["cat"] in ("recycling", "parameters"):
            continue
        for x in v["res"]:
            if x in m.I:
                makers.setdefault(x, []).append(r)
    problems, only_items, flagged = [], 0, set()
    for item, recipes in sorted(makers.items()):
        if all(table_only(r) for r in recipes):
            only_items += 1
            flagged.update(recipes)
            open_ = [r for r in recipes if r not in allow]
            if open_:
                problems.append(f"{item}: only {', '.join(f'{r} ({m.R[r]['cat']})' for r in open_)}")
    stale = [f"{r} (allow-list entry: not a recipe of an item that only the crafting table or the hand makes)"
             for r in sorted(allow) if r not in flagged]
    return f"{only_items} reachable items with only crafting table or hand recipes, {len(allow)} recipes in the allow-list", problems + stale


def check_me_recipes(sec):
    """Issue #214 (prototypes/120-fork-me-network-compat.lua): every recipe me-network defines (ME_NETWORK.recipes) has a
    Gregtorio recipe in the compat file (FORK_ME_RECIPES), so a new me-network item cannot keep its standalone vanilla
    ingredients unnoticed; a recipe kept standalone on purpose is in the allow-list FORK_ME_RECIPES_STANDALONE with its
    reason. An allow-list entry that is no me-network recipe or has a Gregtorio recipe fails too. Returns (info line,
    problems)."""
    rows = [r + [""] * (4 - len(r)) for r in sec.get("MERECIPES", [])]
    me = [r for r in rows if r[1] == "me"]
    greg = sum(1 for r in me if r[2] == "gregtorio")
    allowed = sum(1 for r in me if r[2] != "gregtorio" and r[3])
    problems = [f"{r[0]}: me-network's standalone recipe (give it a GT recipe in the compat file or add it to "
                "FORK_ME_RECIPES_STANDALONE)" for r in me if r[2] != "gregtorio" and not r[3]]
    problems += [f"{r[0]}: in FORK_ME_RECIPES_STANDALONE but " +
                 ("not a recipe of me-network" if r[1] != "me" else "it has a Gregtorio recipe") + " (remove the entry)"
                 for r in rows if r[3] and (r[1] != "me" or r[2] == "gregtorio")]
    return (f"{len(me)} recipes of me-network, {greg} with a Gregtorio recipe, {allowed} standalone in the allow-list",
            sorted(problems))


def check_microminer_tab(sec):
    """Issue #120 (prototypes/195-fork-microminer-tab.lua): the missions of every Microverse Projector (the recipes of its
    categories) and the projectors themselves (and their controller) are recipes of the Microminer tab, so a projector's
    recipe window has one tab and a search for "micro" finds the machines next to the microminers. The recycling recipes
    of a projector (issue #190) are recycling, in the rows of their machine."""
    out = []
    for r in sec.get("DUMP", []):
        if r[0] == "R" and not r[6] == "true" and not r[1].startswith("recycling-") and (
                r[2].endswith("-microverse-projector-recipes") or r[1].endswith("microverse-projector")
                or r[1] == "microverse-projector-controller"):
            if r[9] != MICROMINER_TAB:
                out.append(f"{r[1]} ({r[2]}): row {r[8]}, tab {r[9]}")
    return sorted(out)
ORE_CHAIN_SKIP = {"crushed-platinum", "crushed-palladium", "crushed-firestone"}   # 155-fork-ore-chain.lua's skip list
def check_ore_chain(m):
    """Issue #185 (prototypes/155-fork-ore-chain.lua): every ore with a purified form has GTNH's whole chain (washer,
    thermal centrifuge from crushed and purified ore, the three macerator steps, the centrifuge of impure and pure dust),
    and no ore washer turns a crushed ore straight into something else (the shortcut of upstream; the platinum line's
    washing and firestone are skipped)."""
    out, ores = [], 0
    for name, r in sorted(m.R.items()):
        if r["hidden"]:
            continue
        if r["cat"] == "lv-ore-washer-recipes":
            crushed = [i for i in r["ing"] if i.startswith("crushed-")]
            if crushed and crushed[0] not in ORE_CHAIN_SKIP and not any(x.startswith("purified-") for x in r["res"]):
                out.append(f"{name}: the ore washer turns {crushed[0]} into {', '.join(r['res'])}, not a purified ore")
        if r["cat"] == "lv-ore-washer-recipes" and name.startswith("purified-") and not name.endswith("-distilled-water"):
            ores += 1
            x = name[len("purified-"):]
            for need in (f"purified-{x}-distilled-water", f"centrifuged-{x}", f"centrifuged-{x}-from-crushed",
                         f"impure-{x}-dust", f"pure-{x}-dust", f"centrifuged-{x}-maceration",
                         f"centrifuging-impure-{x}-dust", f"centrifuging-pure-{x}-dust"):
                if need not in m.R or m.R[need]["hidden"]:
                    out.append(f"{x}: the ore chain lacks {need}")
    return ores, out
# Issue #186: GTNH's chemical bath washing per ore (docs/ORE-CHAIN.md appendix B, columns Hg and Na2S2O8), with
# Gregtorio's dust of the tagged material (cobaltite's dust is cobalt dust)
ORE_BATHS = {
    # nickel's platinum dust is GTNH's platinum metallic powder (PlatinumSludgeOutputs, issue #199)
    "mercury": {"gold": "gold-dust", "copper": "gold-dust", "nickel": "metallic-platinum-powder", "sheldonite": "sheldonite-dust",
                "galena": "silver-dust", "lead": "silver-dust", "silver": "silver-dust", "tungstate": "silver-dust"},
    "sodium-persulfate": {"iron": "nickel-dust", "gold": "copper-dust", "copper": "copper-dust", "tin": "zinc-dust",
                          "tetrahedrite": "tetrahedrite-dust", "sphalerite": "zinc-dust", "nickel": "nickel-dust",
                          "pentlandite": "cobalt-dust", "cobaltite": "cobalt-dust", "sheldonite": "nickel-dust"},
}
def check_ore_baths(m):
    """Issue #186 (prototypes/155-fork-ore-chain.lua, phase O2): the chemical bath washes exactly the ores of ORE_BATHS
    with mercury or sodium persulfate into purified ore and the tagged material's dust, as in GTNH. Returns (number of
    bath recipes, problems)."""
    out, n, seen = [], 0, set()
    for name, r in sorted(m.R.items()):
        if r["hidden"] or not r["cat"].endswith("-chemical-bath-recipes"):
            continue
        crushed = [i for i in r["ing"] if i.startswith("crushed-")]
        if not crushed:
            continue
        x = crushed[0][len("crushed-"):]
        for fl, ores in ORE_BATHS.items():
            if fl in r["ing"]:
                n += 1
                seen.add((fl, x))
                if x not in ores:
                    out.append(f"{name}: GTNH has no {fl} washing of {x}")
                elif f"purified-{x}" not in r["res"] or ores[x] not in r["res"]:
                    out.append(f"{name}: gives {', '.join(r['res'])}, GTNH purified-{x} and {ores[x]}")
    for fl, ores in ORE_BATHS.items():
        for x in sorted(ores):
            if (fl, x) not in seen:
                out.append(f"{x}: the chemical bath lacks the {fl} washing (purified-{x}-{fl})")
    return n, out
# Issue #187: GTNH's electromagnetic separator per ore (docs/ORE-CHAIN.md appendix B, column EM separator)
ORE_SEPARATOR = {"vanadium-magnetite": "gold", "tin": "iron", "ilmenite": "iron", "nickel": "iron", "pentlandite": "iron",
                 "chromite": "iron", "bornite": "iron", "bastnasite": "neodymium", "monazite": "neodymium"}
# Issue #188: the gem ores of GTNH's sifter (table, crystallisable for the autoclave) and their gem items
ORE_GEMS = {"ruby": ("ruby", False), "emerald": ("emerald", False), "diamond": ("diamond", False),
            "nether-quartz": ("nether-quartz", True), "certus-quartz": ("certus-quartz", True),
            "apatite": ("apatite-gem", True), "tricalcium-phosphate": ("tricalcium-phosphate-gem", False),
            "lazurite": ("lazurite-gem", True), "sodalite": ("sodalite-gem", True), "lapis": ("lapis-lazuli", True),
            "monazite": ("monazite-gem", True)}
# Issue #193: the laser engraver steps of the grades, with the lens of the gem's colour (red ruby, green emerald, white
# diamond; GT's other colours need lenses of materials Gregtorio lacks)
ORE_GEM_LENS = {"ruby": "ruby-lens", "emerald": "emerald-lens", "monazite": "emerald-lens", "diamond": "diamond-lens",
                "nether-quartz": "diamond-lens"}
def check_ore_o3_o4(m):
    """Issues #187 and #188 (prototypes/155-fork-ore-chain.lua, phases O3 and O4): the electromagnetic separator works
    exactly the pure dusts of ORE_SEPARATOR (dust, small dust and nugget of the metal); every ore of ORE_GEMS is sifted
    from its purified ore into the five grades and the dust, the crystallisable ones grow their gem in the autoclave
    from impure and pure dust (water and distilled water); every ore with a purified form is crushed in the forge
    hammer at each step. Returns (info line, problems)."""
    out, seps, sifts, autos, hammers = [], set(), 0, 0, 0
    def live(n):
        return n in m.R and not m.R[n]["hidden"]
    for name, r in sorted(m.R.items()):
        if r["hidden"]:
            continue
        if r["cat"] == "lv-electromagnetic-separator-recipes":
            pure = [i for i in r["ing"] if i.startswith("pure-") and i.endswith("-dust")]
            x = pure[0][len("pure-"):-len("-dust")] if pure else None
            if x not in ORE_SEPARATOR:
                out.append(f"{name}: GTNH's separator has no recipe for {', '.join(r['ing'])}")
                continue
            seps.add(x)
            metal = ORE_SEPARATOR[x]
            for need in (f"small-pile-of-{metal}-dust", f"{metal}-nugget"):
                if need not in r["res"]:
                    out.append(f"{name}: no {need} (GTNH: small dust 40 %, nugget 20 %)")
    for x in sorted(set(ORE_SEPARATOR) - seps):
        if live(f"pure-{x}-dust"):
            out.append(f"{x}: the electromagnetic separator lacks separating-pure-{x}-dust")
    for x, (gem, crystal) in sorted(ORE_GEMS.items()):
        if not live(f"purified-{x}"):
            out.append(f"{x}: no purified ore to sift")
            continue
        sift = [n for n, r in m.R.items() if not r["hidden"] and r["cat"] == "lv-sifter-recipes"
                and r["ing"] == [f"purified-{x}"]]
        if not sift:
            out.append(f"{x}: the sifter does not sift purified-{x}")
        else:
            sifts += 1
            res = m.R[sift[0]]["res"]
            for need in (f"exquisite-{x}", f"flawless-{x}", gem, f"flawed-{x}", f"chipped-{x}"):
                if need not in res:
                    out.append(f"{sift[0]}: no {need}")
        if crystal:
            for d in ("impure", "pure"):
                for w in ("", "-distilled-water"):
                    n = f"autoclave-{d}-{x}-dust{w}"
                    if live(n) and m.R[n]["cat"].endswith("-autoclave-recipes") and gem in m.R[n]["res"]:
                        autos += 1
                    else:
                        out.append(f"{x}: the autoclave lacks {n} ({gem})")
    for name, r in sorted(m.R.items()):
        if r["hidden"] or r["cat"] != "lv-ore-washer-recipes" or not name.startswith("purified-") \
                or name.endswith("-distilled-water"):
            continue
        x = name[len("purified-"):]
        for src in (f"crushed-{x}", f"purified-{x}", f"centrifuged-{x}"):
            if live(f"hammering-{src}") and m.R[f"hammering-{src}"]["cat"] == "lv-forge-hammer-recipes":
                hammers += 1
            else:
                out.append(f"{x}: the forge hammer does not crush {src}")
    # issue #193: dark ash from every grade implosion, small piles from chipped and flawed gems, the engraver steps,
    # the LV autoclave
    engraves = 0
    for x, (gem, crystal) in sorted(ORE_GEMS.items()):
        grades = [f"chipped-{x}", f"flawed-{x}", gem, f"flawless-{x}", f"exquisite-{x}"]
        for lo, hi in zip(grades, grades[1:]):
            n = f"implosion-{lo}-to-{'gem' if hi == gem else hi.split('-')[0]}"
            if live(n) and "tiny-pile-of-dark-ash-dust" not in m.R[n]["res"]:
                out.append(f"{n}: no dark ash (GT: 2 tiny piles)")
            lens = ORE_GEM_LENS.get(x)
            if lens:
                e = f"engraving-{lo}-to-{'gem' if hi == gem else hi.split('-')[0]}"
                if live(e) and m.R[e]["cat"].endswith("-laser-engraver-recipes") and lens in m.R[e]["ing"] \
                        and lens in m.R[e]["res"] and hi in m.R[e]["res"]:
                    engraves += 1
                else:
                    out.append(f"{x}: the laser engraver lacks {e} (3 x {lo} and the {lens}, which stays)")
        for k, n in (("chipped", 1), ("flawed", 2)):
            r = m.R.get(f"{k}-{x}-maceration")
            if r and f"small-pile-of-{x}-dust" not in r["res"]:
                out.append(f"{k}-{x}-maceration: not into small piles of {x} dust")
    if "lv-autoclave-recipes" not in m.C.get("lv-autoclave", []):
        out.append("lv-autoclave: no LV autoclave running the LV autoclave category (GT's Basic Autoclave)")
    info = (f"{len(seps)} ores in the electromagnetic separator, {sifts} gem ores sifted, {autos} autoclave recipes, "
            f"{hammers} forge hammer steps, {engraves} laser engraver steps")
    return info, out
MACERATOR_CAT, HAMMER_CAT = "lv-macerator-recipes", "lv-forge-hammer-recipes"
def check_ore_hammer(sec):
    """Issue #202 (prototypes/155-fork-ore-chain.lua, phase O4): GTNH's raw ore recipes (ProcessingRawOre.java). A raw ore
    with a macerator recipe to a crushed item (2 x the ore multiplier) needs a forge hammer recipe with half the yield, of
    the same crushed item or of GT's gem (FORK_ORE_HAMMER_GEM, section HAMMERGEM), unless it is in the allow-list
    FORK_ORE_HAMMER_SKIP with its reason (an entry that has a hammer recipe or no macerator recipe fails too); the
    macerator recipe has one byproduct at 5 % x GT's byproduct multiplier (1, 2 or 4); a raw ore that the forge hammer or
    any other recipe crushes needs a macerator recipe. Amounts from the section BALANCE. Returns (info line, problems)."""
    allow = {r[0]: r[1] for r in sec.get("HAMMERSKIPOK", [])}
    gems = {r[0]: r[1] for r in sec.get("HAMMERGEM", [])}
    mac, ham, other = {}, {}, {}   # raw ore -> [(recipe, results)]
    for row in sec.get("BALANCE", []):
        o = json.loads("	".join(row))
        if o.get("kind") != "recipe" or o.get("hidden") or o["name"].startswith("recycling-"):
            continue
        ing = o.get("ingredients") or []
        if len(ing) != 1 or ing[0]["type"] != "item" or not ing[0]["name"].startswith("raw-") or ing[0].get("amount") != 1:
            continue
        res = [r for r in o.get("results") or [] if r["type"] == "item"]
        crushes = any(r["name"].startswith("crushed-") for r in res)
        if o["category"] == MACERATOR_CAT and crushes:
            mac.setdefault(ing[0]["name"], []).append((o["name"], res))
        elif o["category"] == HAMMER_CAT:
            ham.setdefault(ing[0]["name"], []).append((o["name"], res))
        elif crushes:
            other.setdefault(ing[0]["name"], []).append((o["name"], res))
    out, pairs_ok, byp_ok = [], 0, 0
    for raw in sorted(set(ham) | set(other)):
        if raw not in mac:
            names = sorted(r[0] for r in ham.get(raw, []) + other.get(raw, []))
            out.append(f"{raw}: crushed by {', '.join(names)} but no macerator recipe (GTNH: every ore is macerated)")
    for raw, macs in sorted(mac.items()):
        if raw in allow:
            if raw in ham:
                out.append(f"{raw}: in FORK_ORE_HAMMER_SKIP but crushed by {', '.join(h[0] for h in ham[raw])} (remove the entry)")
            continue
        for name, res in macs:
            byp = [r for r in res if not r["name"].startswith("crushed-")]
            if len(byp) == 1 and round((byp[0].get("probability") or 1) / 0.05, 6) in (1, 2, 4):
                byp_ok += 1
            else:
                out.append(f"{name}: byproducts {[(r['name'], r.get('probability')) for r in byp]} (GTNH: the first "
                           f"byproduct at 5 % x the byproduct multiplier)")
        if raw not in ham:
            out.append(f"{raw}: macerated by {', '.join(m[0] for m in macs)} but no forge hammer recipe (GTNH: every ore, "
                       f"half the macerator's yield; or add it to FORK_ORE_HAMMER_SKIP with the reason)")
            continue
        for hname, hres in ham[raw]:
            for mname, mres in macs:
                crushed = next(r for r in mres if r["name"].startswith("crushed-"))
                want = gems.get(raw, crushed["name"])
                if len(hres) != 1 or hres[0]["name"] != want or hres[0]["amount"] * 2 != crushed["amount"]:
                    out.append(f"{hname}: {[(r['name'], r['amount']) for r in hres]}, the macerator's {mname} "
                               f"{crushed['amount']:g} {crushed['name']} (GTNH: half as many, of {want})")
                else:
                    pairs_ok += 1
    for raw in sorted(allow):
        if raw not in mac:
            out.append(f"{raw}: in FORK_ORE_HAMMER_SKIP but no macerator recipe crushes it (remove the entry)")
    for raw, gem in sorted(gems.items()):
        if raw not in ham:
            out.append(f"{raw}: in FORK_ORE_HAMMER_GEM but no forge hammer recipe takes it (remove the entry)")
    return (f"{len(mac)} raw ores macerated to a crushed ore ({byp_ok} recipes with GT's byproduct), {pairs_ok} with a "
            f"forge hammer recipe of half the yield ({len(gems)} of them gems), {len(allow)} in FORK_ORE_HAMMER_SKIP"), out
# Issue #164: the tier circuit items up to UV that the variant recipes (processor, assembly, supercomputer, mainframe)
# share; above UV each tier item has one recipe (the mainframe of its line)
CIRCUIT_TIER_ITEMS = {"electronic-circuit", "advanced-circuit", "processing-unit", "ev-circuit", "iv-circuit",
                      "luv-circuit", "zpm-circuit", "uv-circuit"}
def check_circuit_icons(m):
    """Issue #164 (prototypes/156-fork-circuit-icons.lua): every recipe that makes a tier circuit up to UV shows its own
    icon (GT's texture of the variant it is in GTNH), since the variants share the tier item; recycling and scrap
    recipes do not count. Returns (number of variant recipes, recipes without their own icon)."""
    n, out = 0, []
    for name, r in sorted(m.R.items()):
        if r["hidden"] or "recycl" in r["cat"] or "recycling" in name or "scrap" in name:
            continue
        if CIRCUIT_TIER_ITEMS & set(r["res"]):
            n += 1
            if not r["icon"]:
                out.append(f"{name} ({r['cat']}): makes {', '.join(sorted(CIRCUIT_TIER_ITEMS & set(r['res'])))} without an "
                           "icon of its own (prototypes/156-fork-circuit-icons.lua, tools/gen_gt_icons.py)")
    return n, out
# Issue #199 (and the platinum line, #96): the dusts of the platinum group come only from the platinum line's own steps
# (reprecipitation, the residue branches) and the quantum force transformer; GTNH turns every ore processing output of
# them into the line's powders and residues (bartworks PlatinumSludgeOutputs)
PGM_DUST_SOURCES = {"platinum-dust": {"reprecipitated-platinum-processing"},
                    "palladium-dust": {"reprecipitated-palladium-processing"},
                    "iridium-dust": {"iridium-dust"}, "osmium-dust": {"osmium-dust"}}
def check_pgm_dusts(m):
    """Issue #199: no recipe but the platinum line's and the quantum force transformer's (`-qft-`) makes a dust of the
    platinum group; recycling does not count."""
    out = []
    for name, r in sorted(m.R.items()):
        if r["hidden"] or "recycl" in r["cat"] or name.endswith("-recycling") or "-qft-" in name:
            continue
        for dust in sorted(PGM_DUST_SOURCES.keys() & set(r["res"])):
            if name not in PGM_DUST_SOURCES[dust]:
                out.append(f"{name} ({r['cat']}): makes {dust} outside the platinum line (GTNH: its powder or residue)")
    return out
# Issue #190: what a recycling recipe may give (prototypes/157-fork-recycling.lua)
RECYCLE_PGM = {"metallic-platinum-powder", "metallic-palladium-powder", "iridium-metal-residue", "rarest-metal-mixture"}
def check_recycling(m, sec):
    """Issue #190 (prototypes/157-fork-recycling.lua): GTNH recycles an item into its materials, never into its parts. Every
    recipe recycling-<machine>-<item> takes the one item (and oxygen in the arc furnace) and gives whole dusts, ingots, a
    melt or the platinum line's powders; every entry of FORK_RECYCLING_BLACKLIST names an item and says why. Returns
    (info line, problems)."""
    out, kinds = [], {"macerator": 0, "arc-furnace": 0, "fluid-extractor": 0}
    for name, r in sorted(m.R.items()):
        if not name.startswith("recycling-"):
            continue
        kind = next((k for k in ("macerator", "arc-furnace", "fluid-extractor") if name.startswith(f"recycling-{k}-")), None)
        if kind is None:
            out.append(f"{name}: not a macerator, arc furnace or fluid extractor recycling recipe")
            continue
        kinds[kind] += 1
        item = name[len(f"recycling-{kind}-"):]
        extra = [i for i in r["ing"] if i != item and not (kind == "arc-furnace" and i == "oxygen")]
        if item not in r["ing"] or extra:
            out.append(f"{name}: takes {', '.join(r['ing'])}, not {item}" + (" and oxygen" if kind == "arc-furnace" else ""))
        for x in r["res"]:
            ok = (x.endswith("-dust") or x.endswith("-ingot") or x.startswith("molten-") or x in RECYCLE_PGM)
            if not ok:
                out.append(f"{name}: gives {x}, not a material (GTNH recycles into materials, not parts)")
    for item, why, exists in sec.get("RECYCLEBLACK", []):
        if not why:
            out.append(f"FORK_RECYCLING_BLACKLIST[{item}]: no reason")
        if exists != "true":
            out.append(f"FORK_RECYCLING_BLACKLIST[{item}]: no such item")
    info = (f"{sum(kinds.values())} recipes: {kinds['macerator']} macerator, {kinds['arc-furnace']} arc furnace, "
            f"{kinds['fluid-extractor']} fluid extractor; blacklist {len(sec.get('RECYCLEBLACK', []))}")
    return info, out
def check_extractor_split(m):
    """Issue #152 (prototypes/151-fork-fluid-extractor.lua): as in GTNH, the Extractor makes items and the Fluid Extractor
    fluids. A recipe of an extractor category with a fluid result, or of a fluid extractor category without one, is in
    the wrong machine (hidden recipes do not count)."""
    out = []
    for name, r in sorted(m.R.items()):
        if r["hidden"]:
            continue
        if re.fullmatch(r"[a-z]+-fluid-extractor-recipes", r["cat"]):
            if not r["fout"]:
                out.append(f"{name} ({r['cat']}): no fluid result, belongs in the Extractor")
        elif re.fullmatch(r"[a-z]+-extractor-recipes", r["cat"]) and r["fout"]:
            out.append(f"{name} ({r['cat']}): a fluid result, belongs in the Fluid Extractor")
    return out
def check_fluid_icons(sec):
    """Issue #119 (a warning): a fluid of the Fluids tab whose icon is not a Gregtorio file shows the base game's or Space
    Age's icon next to the others. The ones kept on purpose are in FORK_FLUID_ICONS_KEPT (prototypes/196-fork-subgroups.lua,
    with the reason); an entry that matches nothing is listed too. Hidden and parameter fluids do not count."""
    kept = {r[0] for r in sec.get("FLUIDICONSOK", [])}
    seen, out = set(), []
    for name, sg, group, _sgo, hidden, param, _order, icon, *_ in sec.get("FLUIDS", []):
        if hidden == "true" or param == "true" or group != "fluids":
            continue
        seen.add(name)
        if not icon.startswith("__gregtorio-continued__/") and name not in kept:
            out.append(f"{name} ({icon})")
    out += [f"{n} (in FORK_FLUID_ICONS_KEPT, but not a visible fluid of the Fluids tab)" for n in sorted(kept - seen)]
    return sorted(out)
def check_fluid_steps(sec):
    """Issue #117 (prototypes/197-fork-fluid-steps.lua): every fluid amount of a recipe is a multiple of 2^-24, the
    step the game keeps amounts in. The game cuts every amount off at the step below, so one that is not on the grid
    gives and takes less than it says (14.4 becomes 14.399999976, nine melts no longer fill a block cast)."""
    return [f"{r} ({kind}) {fluid}: {amount}" for r, kind, fluid, amount in sec.get("FLUIDSTEPS", [])]


def check_material_parts(sec):
    """Issue #118 (prototypes/200-fork-material-parts.lua): the material parts are in the rows of the item group "Material
    parts", one per form, the materials by tier. A material with no tier (no solidifier tier, no recipe that makes one of its
    parts) goes last in its rows: a warning, its place is the table of tiers in 143 or a recipe. Returns (info line,
    materials without a tier)."""
    rows = sec.get("MATERIALPARTS", [])
    count = next((r for r in rows if r[0] == "count"), None)
    info = f"{count[1]} parts of {count[2]} materials in rows by form" if count else "absent (older version)"
    return info, sorted(r[1] for r in rows if r[0] == "unranked")


def check_files(sec):
    missing = []
    for path, owner in sec.get("PATHS", []):
        if not (ROOT / path[len("__gregtorio-continued__/"):]).exists():
            missing.append(f"{path} ({owner})")
    return sorted(set(missing))


def check_sprites(sec):
    try:
        from PIL import Image
    except ImportError:
        return ["(Pillow not installed, sprite sizes not checked: pip install pillow)"]
    bad = []
    for name, key, fn, w, h, fc, ll, x, y in sec.get("SPRITES", []):
        if not fn.startswith("__gregtorio-continued__/"):
            continue
        f = ROOT / fn[len("__gregtorio-continued__/"):]
        if not f.exists():
            continue
        w, h, fc, ll, x, y = map(int, (w, h, fc, ll, x, y))
        ll = ll or fc
        W, H = Image.open(f).size
        need_w, need_h = x + min(ll, fc) * w, y + -(-fc // ll) * h
        if need_w > W or need_h > H:
            bad.append(f"{name} {key}: {fn} needs {need_w}x{need_h}, image is {W}x{H}")
    return bad


def report(title, items, limit=40):
    print(f"\n{title}: {len(items)}")
    for i in items[:limit]:
        print("  -", i)
    if len(items) > limit:
        print(f"  ... {len(items) - limit} more")


# Recipes that must stay unlocked by a researchable technology and craftable in the progression model
# (issue #35: grades 7 and 8, FPIC/APIC, complex SMDs, which the runtime test also crafts once in a machine;
# issues #39 and #36: the drafts made real and the new endgame materials; phase 6a: plasma forge and QFT).
REQUIRED_RECIPES = [
    "grade-7-water", "grade-8-water", "quark-creation-catalyst", "fpic-wafer", "apic-wafer", "femto-power-ic",
    "atto-power-ic", "complex-smd-transistor", "complex-smd-resistor", "complex-smd-capacitor", "complex-smd-diode",
    "complex-smd-inductor",
    # issues #39 and #36: the drafts made real and the endgame materials
    "lapotronic-energy-orb-cluster", "high-density-plutonium", "plutonium-based-liquid-fuel", "super-coolant",
    "1080k-super-coolant-cell", "molten-fluxed-electrum", "fine-fluxed-electrum-wire", "bedrockium-cable",
    "bedrockium-plate", "molten-quantium", "quantium-cable",
    # phase 6a: the plasma forge, its catalysts and metals, the quantum force transformer and its recipes
    "dimensionally-transcendent-plasma-forge", "excited-dimensionally-transcendent-crude-catalyst",
    "excited-dimensionally-transcendent-resplendent-catalyst", "molten-spacetime-dtpf-crude",
    "molten-universium-dtpf-resplendent", "molten-transcendent-metal-dtpf-crude", "quantum-force-transformer",
    "metallic-platinum-powder-qft-platinum-dust", "iridium-group-sludge-qft-iridium-dust",
    "naquadah-oxide-mixture-qft-naquadahine-dust", "enriched-naquadah-oxide-mixture-qft-trinium-dust",
    # phase 6b: the godforge and its products, the stellar catalyst, the MAX line, components, hatches and machines
    "godforge", "raw-star-matter", "lead-plasma", "thorium-plasma", "naquadria-plasma", "molten-universium-godforge",
    "spacetime-time-space-separation", "molten-magmatter-from-neutronium", "molten-magmatter-from-infinity",
    "excited-dimensionally-transcendent-stellar-catalyst", "molten-universium-dtpf-stellar", "magmatter-plate",
    "magmatter-cable", "planck-processor-mainframe", "max-motor", "max-field-generator", "max-machine-hull",
    "max-energy-hatch", "max-dynamo-hatch", "max-assembling-machine", "max-electric-blast-furnace",
    "max-large-plasma-turbine", "max-science-pack-from-magmatter",
]


# Issues #39 and #36: the draft recipes the draft guard may still hide (docs/ROADMAP.md, "Drafts and endgame
# materials"); any other FORK-DRAFT recipe is a problem. Removed drafts are deleted in
# prototypes/137-fork-endgame-materials.lua (FORK-REMOVED in the log) and must not come back as drafts.
DRAFTS_OK = []


# Technologies that stay enabled but cannot be researched on purpose: vanilla armor, equipment and
# military techs whose vanilla prerequisites Gregtorio disables (docs/ROADMAP.md, "Final pass").
# Every other enabled technology must be researchable.
UNRESEARCHABLE_OK = [
    "battery-equipment", "battery-mk2-equipment", "battery-mk3-equipment", "belt-immunity-equipment",
    "energy-shield-equipment", "energy-shield-mk2-equipment", "exoskeleton-equipment", "explosives",
    "fission-reactor-equipment", "fusion-reactor", "fusion-reactor-equipment", "mech-armor", "modular-armor",
    "night-vision-equipment", "personal-roboport-equipment", "personal-roboport-mk2-equipment", "power-armor",
    "power-armor-mk2", "spidertron",
]
# Issue #29: the quality-of-life techs whose vanilla gate is disabled; each must be researchable or hidden
# (prototypes/103-fork-qol-techs.lua re-gates them onto Gregtorio techs)
QOL_TECHS = (["bulk-inserter", "stack-inserter", "logistics-3", "turbo-transport-belt",
              "transport-belt-capacity-1", "transport-belt-capacity-2"]
             + [f"inserter-capacity-bonus-{i}" for i in range(1, 8)]
             + [f"worker-robots-speed-{i}" for i in range(1, 8)]
             + [f"worker-robots-storage-{i}" for i in range(1, 4)])


def check_unresearchable(m):
    """Enabled but unresearchable technologies outside UNRESEARCHABLE_OK, QoL techs that are neither
    researchable nor hidden, and allow-list entries that are researchable, hidden or gone."""
    out = []
    for t in QOL_TECHS:
        if t not in m.T:
            out.append(f"{t}: issue #29 technology does not exist")
        elif m.T[t]["en"] and t not in m.researched:
            out.append(f"{t}: issue #29 technology is neither researchable nor hidden")
    for t, v in sorted(m.T.items()):
        if v["en"] and t not in m.researched and t not in UNRESEARCHABLE_OK and t not in QOL_TECHS:
            out.append(f"{t}: cannot be researched and is not in UNRESEARCHABLE_OK")
    for t in UNRESEARCHABLE_OK:
        if t not in m.T or not m.T[t]["en"] or t in m.researched:
            out.append(f"{t}: in UNRESEARCHABLE_OK but researchable, hidden or missing (remove the entry)")
    return out


def check_required(m):
    out = []
    for r in REQUIRED_RECIPES:
        if r not in m.R:
            out.append(f"{r}: recipe does not exist")
        elif r not in m.unlocked:
            out.append(f"{r}: not unlocked by a researchable technology")
        elif not all(x in m.avail for x in m.R[r]["res"]):
            out.append(f"{r}: products never obtainable")
    return out


def check_locked(m, sec):
    """Issue #91: every recipe of Gregtorio (created or changed by it: prototypes.get_history, logged by
    checkmod/control.lua) that is not hidden must be enabled or unlocked by a researchable technology, unless it is in
    the allow-list FORK_RECIPES_LOCKED (prototypes/142-fork-recipe-unlocks.lua); an allow-list entry must exist and
    stay locked. Returns (problems, number of Gregtorio recipes checked, allow-list size)."""
    if "OWNERS" not in sec:
        return ["no DEVCHECK-OWNERS section in the log (checkmod/control.lua did not run)"], 0, 0
    allowed = {r[0] for r in sec.get("LOCKEDOK", [])}
    mod = MOD_NAMES[1]
    greg = {r[0] for r in sec["OWNERS"]
            if len(r) > 1 and (r[1] == mod or mod in (r[2] if len(r) > 2 else "").split(","))}
    out, n = [], 0
    for r in sorted(greg):
        v = m.R.get(r)
        if not v or v["hidden"] or r.endswith("-recycling") or r.startswith("void-") or \
                v["cat"] in ("recycling", "parameters", "fluid-voiding-recipes"):
            continue
        n += 1
        if r not in m.unlocked and r not in allowed:
            out.append(f"{r}: no researchable technology unlocks it (unlock it or add it to FORK_RECIPES_LOCKED)")
    for r in sorted(allowed):
        if r not in m.R:
            out.append(f"{r}: in FORK_RECIPES_LOCKED but does not exist (remove the entry)")
        elif r in m.unlocked:
            out.append(f"{r}: in FORK_RECIPES_LOCKED but unlocked (remove the entry)")
    return out, n, len(allowed)


ONE_PACK = "gregtorio-continued-one-pack-research"


def check_one_pack(sec):
    """Startup setting gregtorio-continued-one-pack-research (prototypes/fork-one-pack-research.lua): when it is on,
    every technology with science packs costs one unit of one pack of each kind; when it is off, at least one
    technology costs more (the setting must not be on by default). Returns (info line, problems)."""
    value = next((r[1] for r in sec.get("SETTINGS", []) if r[0] == ONE_PACK), "absent")
    techs = [json.loads("\t".join(r)) for r in sec.get("BALANCE", [])]
    techs = [t for t in techs if t.get("kind") == "tech" and (t.get("count") or t.get("count_formula"))]

    def cheap(t):
        return (t.get("count") == 1 or t.get("count_formula") == "1") and all(
            i.get("amount") == 1 for i in t.get("ingredients") or [])
    n = sum(1 for t in techs if cheap(t))
    if value == "true":
        return (f"on: {n} of {len(techs)} technologies cost one science pack of each kind",
                [t["name"] for t in techs if not cheap(t)])
    return (f"{value}: {len(techs) - n} of {len(techs)} technologies cost more than one science pack of each kind",
            [f"setting is {value} but every technology is cheap"] if techs and n == len(techs) else [])


def parse_settings(pairs):
    out = {}
    for p in pairs or []:
        name, _, value = p.partition("=")
        if value not in ("true", "false"):
            sys.exit(f"--set {p}: expected <bool startup setting>=true|false")
        out[name] = value == "true"
    return out


def check(a):
    prepare_mods(settings=parse_settings(getattr(a, "set", None)))
    log = factorio("--create", str(WORK / "check-map.zip"))
    err = load_errors(log)
    sec = sections(log)
    validate = [" ".join(r) for r in sec.get("VALIDATE", [])]
    drafts = re.findall(r"FORK-DRAFT: recipe (\S+)", log)
    print(f"load: {'FAILED' if err else 'ok'}")
    if validate:
        report("references to missing prototypes (not caught by the draft guard)", validate)
    if err:
        print("\n" + err)
        return 1
    print(f"draft recipes hidden by the draft guard: {len(drafts)} (FORK-DRAFT in .devcheck/last-run.log)")
    removed = re.findall(r"FORK-REMOVED: (\S+ \S+)", log)
    print(f"drafts removed for good: {len(removed)} prototypes (FORK-REMOVED)")
    new_drafts = [d for d in drafts if d not in DRAFTS_OK]
    m = Model(sec["DUMP"])
    files, sprites, uncraft = check_files(sec), check_sprites(sec), m.uncraftable()
    print(f"\nresearchable technologies: {len(m.researched)} of {sum(1 for v in m.T.values() if v['en'])}")
    for t, miss in m.frontier():
        print(f"  progression stops at {t}" + (f" (missing science: {', '.join(miss)})" if miss else ""))
    stuck = [f"{t}: blocked by {', '.join(sorted(set(m.blockers(t))))}"
             for t, v in sorted(m.T.items()) if v["en"] and t not in m.researched]
    report("technologies that cannot be researched", stuck, limit=100)
    unresearchable = check_unresearchable(m)
    print(f"  intentional (UNRESEARCHABLE_OK): {len(UNRESEARCHABLE_OK)}; issue #29 QoL technologies researchable: "
          f"{sum(1 for t in QOL_TECHS if t in m.researched)} of {len(QOL_TECHS)}, hidden: "
          f"{sum(1 for t in QOL_TECHS if t in m.T and not m.T[t]['en'])}")
    report("unexpected unresearchable technologies", unresearchable)
    if a.techs:
        rx = re.compile(a.techs)
        rows = []
        for t, v in sorted(m.T.items()):
            if rx.search(t) and v["en"]:
                state = "researchable" if t in m.researched else "NOT researchable"
                sci = ", ".join(s.replace("-science-pack", "") for s in v["sci"])
                rows.append(f"{t}: {state} [{sci}] unlocks {len(v['eff'])} recipes")
        report(f"technologies matching /{a.techs}/", rows, limit=400)
    report("missing graphics files", files)
    report("sprite sheets too small", sprites)
    report("unlocked but uncraftable recipes", [f"{r}: {why}" for r, why in uncraft])
    required = check_required(m)
    print(f"\nrequired recipes (issues #35, #36, #39, phases 6a and 6b): {len(REQUIRED_RECIPES) - len(required)} of {len(REQUIRED_RECIPES)} unlocked and craftable")
    report("required recipes not unlocked or not craftable", required)
    locked, n_greg, n_allowed = check_locked(m, sec)
    print(f"\nGregtorio recipes (issue #91): {n_greg} not hidden, {n_greg - n_allowed - len(locked)} enabled or unlocked "
          f"by a researchable technology, {n_allowed} kept locked (FORK_RECIPES_LOCKED)")
    report("Gregtorio recipes that no researchable technology unlocks", locked)
    report("draft recipes outside DRAFTS_OK (issue #39)", new_drafts)
    menu_info, menu = check_crafting_menu(m, sec)
    print("\ncrafting menu (issue #49):")
    for line in menu_info:
        print("  " + line)
    report("machine recipes hidden from the crafting menu without an allow-list entry", menu)
    fluid_info, fluid_fallback, fluid_problems = check_fluids_tab(sec)
    print("\nfluids tab:")
    for line in fluid_info:
        print("  " + line)
    report(f"WARNING: fluids in the fallback row {FLUID_FALLBACK} (sort them in prototypes/196-fork-subgroups.lua)",
           fluid_fallback)
    report("fluids outside the Fluids tab (subgroup missing or not in the group fluids)", fluid_problems)
    table_info, table_only = check_table_only(m, sec)
    print(f"\ncrafting table and hand only items (issue #126): {table_info}")
    report("items that only the crafting table or the hand can make, without an entry in FORK_RECIPES_TABLE_ONLY", table_only)
    me_info, me_recipes = check_me_recipes(sec)
    print(f"\nME recipes (issue #214): {me_info}")
    report("me-network recipes without a Gregtorio recipe (prototypes/120-fork-me-network-compat.lua)", me_recipes)
    parts_info, parts_unranked = check_material_parts(sec)
    print(f"\nmaterial parts (issue #118): {parts_info}")
    report("WARNING: materials of the material parts without a tier (prototypes/200-fork-material-parts.lua)", parts_unranked)
    microminer = check_microminer_tab(sec)
    report("Microverse Projector recipes outside the Microminer tab (issue #120)", microminer)
    chain_ores, ore_chain = check_ore_chain(m)
    print(f"\nore chain (issue #185): {chain_ores} ores with GTNH's chain")
    report("ore chain gaps and ore washer shortcuts (prototypes/155-fork-ore-chain.lua)", ore_chain)
    bath_n, ore_baths = check_ore_baths(m)
    print(f"\nchemical bath washing (issue #186): {bath_n} recipes")
    report("chemical bath washing that differs from GTNH (prototypes/155-fork-ore-chain.lua)", ore_baths)
    o34_info, ore_o34 = check_ore_o3_o4(m)
    circuit_n, circuit_icons = check_circuit_icons(m)
    pgm_dusts = check_pgm_dusts(m)
    recycle_info, recycling = check_recycling(m, sec)
    print(f"\nseparator, gems and forge hammer of the ore chain (issues #187, #188): {o34_info}")
    report("separator, gem and forge hammer steps that differ from GTNH (prototypes/155-fork-ore-chain.lua)", ore_o34)
    hammer_info, ore_hammer = check_ore_hammer(sec)
    print(f"\nraw ore crushing in the macerator and the forge hammer (issue #202): {hammer_info}")
    report("raw ores whose macerator and forge hammer crushing differ from GTNH (prototypes/155-fork-ore-chain.lua)",
           ore_hammer)
    print(f"\ncircuit variant recipes up to UV (issue #164): {circuit_n}")
    report("circuit recipes without their own icon (issue #164)", circuit_icons)
    report("platinum group dusts made outside the platinum line (issue #199)", pgm_dusts)
    print(f"\nrecycling (issue #190): {recycle_info}")
    report("recycling recipes that differ from GTNH's rule (prototypes/157-fork-recycling.lua)", recycling)
    extractor_split = check_extractor_split(m)
    report("extractor recipes in the wrong machine (issue #152: items in the Extractor, fluids in the Fluid Extractor)",
           extractor_split)
    report("WARNING: fluids of the Fluids tab with an icon of the base game or Space Age (issue #119; "
           "FORK_FLUID_ICONS_KEPT in prototypes/196-fork-subgroups.lua keeps one on purpose)", check_fluid_icons(sec))
    fluid_steps = check_fluid_steps(sec)
    print(f"\nfluid amounts off the grid of 2^-24 (issue #117): {len(fluid_steps)}")
    report("fluid amounts of recipes that are not a multiple of 2^-24 (prototypes/197-fork-fluid-steps.lua)", fluid_steps)
    one_pack_info, one_pack = check_one_pack(sec)
    print(f"\ncheap research ({ONE_PACK}): {one_pack_info}")
    report("technologies that cost more than one science pack of each kind although the setting is on", one_pack)
    if getattr(a, "fluids_out", None):
        Path(a.fluids_out).write_text("\n".join("\t".join(r) for r in sec.get("FLUIDS", [])) + "\n", encoding="utf-8")
        print(f"\nfluid list written to {a.fluids_out} (input for tools/gen_review_sheet.py fluids)")
    if a.locale_out:
        Path(a.locale_out).write_text("\n".join("\t".join(r) for r in sec.get("LOCALE", [])))
        print(f"\nlocale name list written to {a.locale_out} (input for tools/gen_locale.py)")
    if getattr(a, "balance_out", None):
        rows = ["\t".join(r) for r in sec.get("BALANCE", [])]
        Path(a.balance_out).write_text("[\n" + ",\n".join(rows) + "\n]\n", encoding="utf-8")
        print(f"\nbalance data written to {a.balance_out} (recipes, machines, technologies as JSON)")
    ok = not (files or [s for s in sprites if not s.startswith("(")] or uncraft or menu or required or unresearchable
              or new_drafts or fluid_problems or locked or one_pack or fluid_steps or microminer or table_only or me_recipes
              or extractor_split or ore_chain or ore_baths or ore_o34 or ore_hammer
              or circuit_icons or pgm_dusts or recycling)
    print("\nRESULT:", "OK" if ok else "PROBLEMS FOUND")
    return 0 if ok else 1


def one_pack(a):
    """Part of `all`: loads the mod with the cheap research setting on and checks every technology."""
    prepare_mods(settings={ONE_PACK: True})
    log = factorio("--create", str(WORK / "check-map.zip"))
    if load_errors(log):
        print(f"\nload with {ONE_PACK}=true: FAILED\n" + load_errors(log))
        return 1
    info, problems = check_one_pack(sections(log))
    print(f"\ncheap research, loaded with the setting on: {info}")
    report("technologies that cost more than one science pack of each kind although the setting is on", problems)
    print("\nRESULT:", "PROBLEMS FOUND" if problems else "OK")
    return 1 if problems else 0


def seed_args(a):
    if a.seed == "random":
        return []
    return ["--map-gen-seed", str(int(a.seed))]


def runtime(a):
    prepare_mods(with_runtime=True)
    log = factorio("--create", str(WORK / "runtime-map.zip"), *seed_args(a))
    if load_errors(log):
        print(load_errors(log))
        return 1
    if not_saved(log):
        print(not_saved(log))
        return 1
    placed = re.search(r"DEVCHECK-RUNTIME (placed=.*)", log)
    fails = re.findall(r"DEVCHECK-RUNTIME-FAIL (.*)", log)
    print("runtime setup:", placed.group(1) if placed else "no result")
    seed = re.search(r"DEVCHECK-RUNTIME-SEED (.*)", log)
    print("map seed:", seed.group(1) if seed else "unknown")
    log = factorio("--benchmark", str(WORK / "runtime-map.zip"), "--benchmark-ticks", str(a.ticks))
    ran = re.search(r"Performed (\d+) updates", log)
    err = re.search(r"(Error.*|non-recoverable.*)", log)
    fails += re.findall(r"DEVCHECK-RUNTIME-FAIL (.*)", log)
    print(f"benchmark: {ran.group(0) if ran else 'did not run'}")
    # the ME network's runtime tests are in me-network since issue #83 (its tools/devcheck)
    tests = (("MOLD", "mold test"), ("POWER", "power test"), ("FUEL", "fuel check test"), ("COOLED", "cooled fluid test"),
             ("TIERS", "turbine tier test"), ("RECIPES", "recipe test"), ("CRUSH", "raw ore crushing test"), ("STEAM", "steam turbine test"), ("CHAIN", "nuclear chain test"), ("LSC", "supercapacitor test"), ("LSUP", "supercapacitor upgrade test"), ("MELT", "melt and cast test"), ("OFFER", "offered recipes test"), ("VICTORY", "victory test"),
             ("POSTVICTORY", "post-victory test"))
    for key, label in tests:
        m = re.search(rf"DEVCHECK-RUNTIME-{key} (.*)", log)
        print(f"{label}: {m.group(1) if m else 'did not run'}")
        if not m:
            fails.append(f"{label} did not run (needs --ticks >= 1500)")
        elif not m.group(1).startswith("ok"):
            fails.append(f"{label} failed")
    report("runtime problems (placement, " + ", ".join(label for _, label in tests) + ")", fails)
    if err or not ran or fails:
        print(err.group(1) if err else "")
        print("\nRESULT: PROBLEMS FOUND")
        return 1
    print("\nRESULT: OK")
    return 0


def zip_from_ref(ref):
    """Build a mod zip of an older git ref (tag or commit), e.g. the upstream 0.1.9 import."""
    info = json.loads(subprocess.run(["git", "-C", str(ROOT), "show", f"{ref}:info.json"],
                                     capture_output=True, text=True, check=True).stdout)
    out = WORK / f"{info['name']}_{info['version']}.zip"
    subprocess.run(["git", "-C", str(ROOT), "archive", "--format=zip",
                    f"--prefix={info['name']}_{info['version']}/", "-o", str(out), ref], check=True)
    return out


def old_me_network(ref, use="old save created with"):
    """The me-network release an old Gregtorio shipped with (a git ref of the me-network checkout, e.g. v0.1.0 for
    Gregtorio 0.5.0), exported to .devcheck/me-network-<ref>: the old save is created with it, the working copy loads
    it with the current checkout (the old version's ME blocks may be gone from the current me-network). Also the
    me-network of the intermediate load (issue #209)."""
    src = me_network_dir()
    if not src:
        sys.exit("--old-me-network needs a me-network checkout (../me-network or ME_NETWORK_DIR)")
    out = WORK / f"me-network-{re.sub(r'[^A-Za-z0-9._-]', '_', ref)}"
    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)
    tar = subprocess.run(["git", "-C", str(src), "archive", ref], capture_output=True, check=True).stdout
    import io
    with tarfile.open(fileobj=io.BytesIO(tar)) as t:
        t.extractall(out)
    print(f"{use} me-network {ref} ({json.loads((out / 'info.json').read_text())['version']})")
    return out


class me_network_from:
    """with me_network_from(dir): prepare_mods links that me-network export (None: the usual checkout or zip)"""
    def __init__(self, d):
        self.d, self.env = d, os.environ.get("ME_NETWORK_DIR")

    def __enter__(self):
        if self.d:
            os.environ["ME_NETWORK_DIR"] = str(self.d)

    def __exit__(self, *exc):
        if self.d:
            os.environ.pop("ME_NETWORK_DIR") if self.env is None else os.environ.update(ME_NETWORK_DIR=self.env)


# issue #209: me-network 0.5.1 refuses a save from before me-network 0.5.0 (its issue #146: "Load the save once with
# me-network 0.5.0"), and a Gregtorio Continued 0.4.x save whose ME state waits for the hand-over. `migrate` takes the
# player's way for such a save: it is loaded once with me-network 0.5.0 and the last Gregtorio release that works with
# it, saved, and that save is loaded with the working copies.
STEP_GREGTORIO, STEP_ME_NETWORK = "v0.5.2", "v0.5.0"
ME_CUT_OFF = (0, 5, 0)


def version_tuple(v):
    return tuple(int(n) for n in re.findall(r"\d+", v)[:3])


def save_me_network(old_zip, old_me):
    """the me-network version the old save is created with, or None for a version of the mod from before issue #83
    (the ME network inside the mod, no me-network)"""
    if not needs_me_network(zip_info(old_zip)):
        return None
    d = old_me or me_network_dir()
    if d:
        return json.loads((d / "info.json").read_text(encoding="utf-8"))["version"]
    z = sorted(MODS.glob(f"{ME_NETWORK}_*.zip"), key=lambda p: version_tuple(p.stem.rsplit("_", 1)[1]))
    return z[-1].stem.rsplit("_", 1)[1] if z else None


def rcon(sock, kind, body, req_id):
    """one Source RCON request (kind 3: auth, 2: command) and its response body (as in me-network's devcheck)"""
    import struct
    data = body.encode("utf-8")
    sock.sendall(struct.pack("<iii", 4 + 4 + len(data) + 2, req_id, kind) + data + b"\x00\x00")

    def read(n):
        out = b""
        while len(out) < n:
            chunk = sock.recv(n - len(out))
            if not chunk:
                raise OSError("rcon: connection closed")
            out += chunk
        return out
    rest = read(struct.unpack("<i", read(4))[0])
    rid, _ = struct.unpack("<ii", rest[:8])
    if kind == 3 and rid == -1:
        raise OSError("rcon: authentication refused")
    return rest[8:-2].decode("utf-8", errors="replace")


def load_and_save(mapfile, log_path):
    """Loads `mapfile` in a headless server with nobody connected and `auto_pause`, so no tick runs: only the load with
    the mods' on_init / on_configuration_changed and the migrations. Quits through RCON at once (a Lua command would run
    a tick, and the helper mod's checks with it): the server saves the map when it quits (`--benchmark` cannot save),
    the save is copied over `mapfile`. Returns the server log and None, or the log and a reason. The ports are free
    ones (another devcheck may run a server at the same time)."""
    import socket, time

    def free_port(kind):
        with socket.socket(socket.AF_INET, kind) as s:
            s.bind(("127.0.0.1", 0))
            return s.getsockname()[1]
    rcon_port, game_port = free_port(socket.SOCK_STREAM), free_port(socket.SOCK_DGRAM)
    binary = FACTORIO / ("bin/x64/factorio.exe" if os.name == "nt" else "bin/x64/factorio")
    settings = WORK / "server-settings.json"
    settings.write_text(json.dumps({"name": "devcheck", "description": "devcheck migrate: the intermediate load",
                                    "visibility": {"public": False, "lan": False}, "auto_pause": True,
                                    "require_user_verification": False, "max_players": 1}), encoding="utf-8")
    step = WORK / "migrate-step.zip"                   # the server saves the map back into this file when it quits
    shutil.copy2(mapfile, step)
    reason = None
    with open(log_path, "w", encoding="utf-8") as out:
        proc = subprocess.Popen([str(binary), "--mod-directory", str(MODS), "--start-server", str(step),
                                 "--server-settings", str(settings), "--bind", f"127.0.0.1:{game_port}",
                                 "--rcon-bind", f"127.0.0.1:{rcon_port}", "--rcon-password", "devcheck"],
                                stdout=out, stderr=subprocess.STDOUT)
        sock = None
        deadline = time.time() + 300
        try:
            while time.time() < deadline and proc.poll() is None:
                try:
                    sock = socket.create_connection(("127.0.0.1", rcon_port), timeout=5)
                    rcon(sock, 3, "devcheck", 1)
                    break
                except OSError:
                    sock = None
                    time.sleep(0.5)
            if not sock:
                reason = "the server did not load the save or answer RCON"
            else:
                try:
                    rcon(sock, 2, "/quit", 2)
                except OSError:
                    pass
        finally:
            if sock:
                sock.close()
            # (on Windows the server can hang after closing the game, its map saved: stopped a few seconds later)
            closed = None
            while proc.poll() is None and time.time() < deadline + 60:
                if closed is None and "to(Closed)" in log_path.read_text(encoding="utf-8", errors="replace"):
                    closed = time.time()
                if closed is not None and time.time() > closed + 5:
                    break
                time.sleep(0.5)
            if proc.poll() is None:
                proc.kill()
                proc.wait()
    log = log_path.read_text(encoding="utf-8", errors="replace")
    if not reason and not re.search(r"Saving map as .*\n(?:.*\n)*?.*Saving progress: 100", log):
        reason = "the server did not save the map when it quit"
    if not reason and re.search(r"DEVCHECK-MIGRATE-(?!SETUP)[A-Z]+ ", log):
        reason = "a tick ran in the intermediate load (the helper mod's checks ran there)"
    ticks = re.findall(r"updateTick\((\d+)\) changing state from\(InGame\)", log)
    if not reason:
        shutil.copy2(step, mapfile)
        print(f"  saved when the server quit (tick {ticks[-1] if ticks else '?'}, no tick run)")
    return log, reason


def bumped_working_copy(old_zip):
    """None (the linked working copy), or, when the working copy has the version of the old save (between releases
    `info.json` keeps the last released version), a zip of it one patch version up, as the release will be: Factorio
    runs a mod's on_configuration_changed with its mod_changes only when its version changed, and Gregtorio resets
    the technology effects there (issue #91)."""
    import zipfile
    info = json.loads((ROOT / "info.json").read_text(encoding="utf-8"))
    m = re.search(r"_(\d+\.\d+\.\d+)\.zip$", str(old_zip))
    old_version = m and m.group(1)
    if info["version"] != old_version:
        return None
    major, minor, patch = info["version"].split(".")
    info["version"] = f"{major}.{minor}.{int(patch) + 1}"
    prefix = f"{info['name']}_{info['version']}/"
    out = WORK / f"working-copy_{info['version']}.zip"
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(ROOT.rglob("*")):
            rel = p.relative_to(ROOT).as_posix()
            if p.is_dir() or rel.split("/")[0] in (".git", ".devcheck", ".github", "tools", "docs"):
                continue
            z.writestr(prefix + rel, json.dumps(info, indent=2) if rel == "info.json" else p.read_bytes())
    print(f"working copy has the version of the old save ({old_version}): loaded as {info['version']}, as the release "
          f"will be (on_configuration_changed with mod changes)")
    return out


def migrate(a):
    """Create a map with an older version (also "Gregtorio" before 0.3.0), then load and run it with the working copy."""
    old = a.from_zip or zip_from_ref(a.from_ref)
    old_me = old_me_network(a.old_me_network) if getattr(a, "old_me_network", None) else None
    with me_network_from(old_me):
        prepare_mods(gregtorio_zip=old, with_migrate=True)
    log = factorio("--create", str(WORK / "migrate-map.zip"), *seed_args(a))
    print(f"map seed: {'random' if a.seed == 'random' else a.seed}")
    if load_errors(log):
        print("could not create the map with the old version:\n" + load_errors(log))
        return 1
    if not_saved(log):
        print(not_saved(log))
        if not old_me:
            print("an old version may need the me-network of its time: --old-me-network <ref> "
                  "(v0.1.0 for --from-ref v0.5.0)")
        return 1
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP (.*)", log)
    print(f"old save with loaded fluid drives: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-POWER (.*)", log)
    print(f"old save with a reactor on steam: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-TURBINE (.*)", log)
    print(f"old save with a plasma turbine: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-PATTERNS (.*)", log)
    print(f"old save with pattern providers: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-JOB (.*)", log)
    print(f"old save with a crafting job: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-MAINTAINER (.*)", log)
    print(f"old save with a level maintainer: {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-ITEMS (.*)", log)
    print(f"old save with a logistic ME network (items): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-HANDOVER (.*)", log)
    print(f"old save with a network for the hand-over (issue #83): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-TECHS (.*)", log)
    print(f"old save with researched technologies (issue #91): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-REMOVED (.*)", log)
    print(f"old save with removed fluids and items (issues #98, #96): {setup.group(1) if setup else 'no result'}")
    # issue #209: a save from before me-network 0.5.0 goes through the intermediate load first (--direct: not)
    save_me = save_me_network(old, old_me)
    step_log = ""
    if (save_me is None or version_tuple(save_me) < ME_CUT_OFF) and not a.direct:
        print(f"old save made {'without me-network' if save_me is None else 'with me-network ' + save_me}, before "
              f"me-network {'.'.join(map(str, ME_CUT_OFF))}: loaded once with Gregtorio {STEP_GREGTORIO} and me-network "
              f"{STEP_ME_NETWORK} and saved (issue #209), as a player has to before updating")
        step_me = old_me_network(STEP_ME_NETWORK, "intermediate load with")
        old = zip_from_ref(STEP_GREGTORIO)
        with me_network_from(step_me):
            prepare_mods(gregtorio_zip=old, with_migrate=True)
        step_log, why = load_and_save(WORK / "migrate-map.zip", WORK / "migrate-step.log")
        if why:
            print(f"intermediate load: FAILED, {why}: "
                  f"{script_error(step_log) or load_errors(step_log) or ''} (see .devcheck/migrate-step.log)")
            return 1
        print("intermediate load: ok")
    elif save_me is not None and version_tuple(save_me) < ME_CUT_OFF:
        print(f"--direct: the old save of me-network {save_me} is loaded with the working copies (me-network 0.5.1 and "
              f"later refuse it)")
    prepare_mods(with_migrate=True, gregtorio_zip=bumped_working_copy(old))
    log = factorio("--benchmark", str(WORK / "migrate-map.zip"), "--benchmark-ticks", str(a.ticks))
    ran = re.search(r"Performed (\d+) updates", log)
    fluids = re.search(r"DEVCHECK-MIGRATE-FLUIDS (.*)", log)
    print(f"old save loaded with working copy: {'ok, ' + ran.group(0) if ran else 'FAILED'}")
    print(f"fluid drives of the old save: {fluids.group(1) if fluids else 'no result'}")
    power = re.search(r"DEVCHECK-MIGRATE-POWER (.*)", log)
    print(f"reactor on steam in the old save: {power.group(1) if power else 'no result'}")
    turbine = re.search(r"DEVCHECK-MIGRATE-TURBINE (.*)", log)
    print(f"plasma turbine of the old save: {turbine.group(1) if turbine else 'no result'}")
    patterns = re.search(r"DEVCHECK-MIGRATE-PATTERNS (.*)", log)
    print(f"pattern providers of the old save: {patterns.group(1) if patterns else 'no result'}")
    job = re.search(r"DEVCHECK-MIGRATE-JOB (.*)", log)
    print(f"crafting job of the old save: {job.group(1) if job else 'no result'}")
    items = re.search(r"DEVCHECK-MIGRATE-ITEMS (.*)", log)
    print(f"ME network of the old save converted (issue #68): {items.group(1) if items else 'no result'}")
    handover = re.search(r"DEVCHECK-MIGRATE-HANDOVER (.*)", log)
    print(f"ME state handed over to me-network (issue #83): {handover.group(1) if handover else 'no result'}")
    techs = re.search(r"DEVCHECK-MIGRATE-TECHS (.*)", log)
    print(f"technology effects of the old save (issue #91): {techs.group(1) if techs else 'no result'}")
    removed = re.search(r"DEVCHECK-MIGRATE-REMOVED (.*)", log)
    print(f"removed fluids and items of the old save (issues #98, #96): {removed.group(1) if removed else 'no result'}")
    # issue #83: the fingerprints of what gregtorio-continued gave and what me-network got must be equal (issue #209:
    # the hand-over and the conversions of me-network 0.5.0 happen in the intermediate load)
    both = step_log + log
    gave = re.findall(r"FORK-ME-HANDOVER: gave (\S+) (\S+)", both)
    took = re.search(r"ME-NETWORK-HANDOVER: (ok|MISMATCH.*|refused.*)", both)
    print(f"hand-over fingerprints: {(took.group(1) if took else 'no hand-over') if gave else 'nothing to hand over'}"
          + (f" ({sum(1 for _, f in gave if f != 'nil')} of {len(gave)} tables with state)" if gave else ""))
    handover_ok = (not gave or (took and took.group(1) == "ok")) and not (handover and handover.group(1).startswith("failed"))
    for line in re.findall(r"FORK-ME-MIGRATE: (.*)", both):
        print("  migration: " + line)
    for f in re.findall(r"DEVCHECK-MIGRATE-FAIL (.*)", log):
        print("  - " + f)
    if not ran:
        print(load_errors(log) or script_error(log) or "")
    ok = ran and fluids and not fluids.group(1).startswith("failed") and power and not power.group(1).startswith("failed") \
        and turbine and not turbine.group(1).startswith("failed") \
        and patterns and not patterns.group(1).startswith("failed") and job and not job.group(1).startswith("failed") \
        and items and not items.group(1).startswith("failed") and handover_ok \
        and techs and not techs.group(1).startswith("failed") \
        and removed and not removed.group(1).startswith("failed")
    return 0 if ok else 1


HANDOVER = HERE / "handover"
HANDOVER_MODS = WORK / "handover-mods"


def handover_mods(giver=None, taker=False, skip=None):
    """mods for the hand-over prototype: the giver (1 = old Gregtorio, 2 = new Gregtorio, depends on the taker),
    the taker (me-network); skip = a storage table the giver leaves out"""
    if HANDOVER_MODS.exists():
        shutil.rmtree(HANDOVER_MODS)
    HANDOVER_MODS.mkdir()
    enabled = ["base"]
    for name, src, version, deps in (
            ("zz-handover-giver", "giver", f"{giver}.0.0", ["zz-handover-taker >= 1.0.0"] if giver == 2 else []),
            ("zz-handover-taker", "taker", "1.0.0", [])):
        if (name == "zz-handover-giver" and not giver) or (name == "zz-handover-taker" and not taker):
            continue
        d = HANDOVER_MODS / name
        shutil.copytree(HANDOVER / src, d)
        shutil.copy2(HANDOVER / "shared.lua", d / "shared.lua")
        (d / "info.json").write_text(json.dumps({"name": name, "version": version, "title": name, "author": "devcheck",
                                                 "factorio_version": "2.0", "dependencies": ["base"] + deps}))
        if src == "giver":
            (d / "config.lua").write_text(f"return {{ skip = {json.dumps(skip)} }}\n" if skip else "return {}\n")
        enabled.append(name)
    (HANDOVER_MODS / "mod-list.json").write_text(json.dumps({"mods": [{"name": n, "enabled": True} for n in enabled]}))


def handover_run(*args):
    binary = FACTORIO / ("bin/x64/factorio.exe" if os.name == "nt" else "bin/x64/factorio")
    r = subprocess.run([str(binary), "--mod-directory", str(HANDOVER_MODS), *args], capture_output=True, text=True)
    LOG.write_text(r.stdout + r.stderr)
    return r.stdout + r.stderr


def handover(a):
    """Issue #83: prototype of the one-time hand-over of the ME state from gregtorio-continued to me-network, with two
    stand-in mods (tools/devcheck/handover/): the event order when the taker is added and the giver updated in the
    same load, what survives the remote call, the guards, and a broken hand-over that must be noticed."""
    save = WORK / "handover-map.zip"
    fails = []
    handover_mods(giver=1)
    log = handover_run("--create", str(save))
    if load_errors(log) or not_saved(log):
        print("could not create the old save:\n" + (load_errors(log) or not_saved(log)))
        return 1

    def load(skip=None):
        handover_mods(giver=2, taker=True, skip=skip)
        return handover_run("--benchmark", str(save), "--benchmark-ticks", "2")

    log = load()
    print("event order (giver = gregtorio-continued updated, taker = me-network added):")
    for line in re.findall(r"HANDOVER-ORDER (.*)", log):
        print("  " + line)
    for line in re.findall(r"HANDOVER-CHECK (.*)", log):
        print("  check: " + line)
    result = re.search(r"HANDOVER-RESULT (.*)", log)
    print(f"hand-over: {result.group(1) if result else 'did not run'}")
    script_err = re.search(r"Error while running event .*", log)
    if not (result and result.group(1) == "ok") or script_err or not re.search(r"Performed \d+ updates", log):
        fails.append("the hand-over failed" + (": " + script_err.group(0) if script_err else ""))
    log = load(skip="fork_me_io")
    result = re.search(r"HANDOVER-RESULT (.*)", log)
    missing = re.findall(r"HANDOVER-CHECK failed: (.*)", log)
    print(f"broken hand-over (fork_me_io left out): {result.group(1) if result else 'did not run'}"
          + (f" ({'; '.join(missing)})" if missing else ""))
    if not (result and result.group(1) == "failed"):
        fails.append("a hand-over without fork_me_io was not noticed")
    handover_mods(giver=1, taker=True)
    err = load_errors(handover_run("--benchmark", str(save), "--benchmark-ticks", "2")) or ""
    guard = re.search(r"zz-handover-taker: .*", err)
    print(f"old giver with the taker: {'refused: ' + guard.group(0) if guard else ('refused: ' + err if err else 'LOADED')}")
    if "contains the ME network itself" not in err:
        fails.append("the taker loaded next to the old giver")
    handover_mods(giver=2)
    err = load_errors(handover_run("--benchmark", str(save), "--benchmark-ticks", "2")) or ""
    dep = re.search(r"Missing required dependency [^\n]*", err)
    print(f"new giver without the taker: {'refused: ' + dep.group(0) if dep else ('refused: ' + err if err else 'LOADED')}")
    if not err:
        fails.append("the new giver loaded without the taker")
    report("hand-over prototype problems", fails)
    print("\nRESULT:", "OK" if not fails else "PROBLEMS FOUND")
    return 1 if fails else 0


def menusim_list(gregtorio):
    """{name: (save file, length)} of the main menu simulations, as the game has them with this mod set"""
    prepare_mods(menusim="none", gregtorio=gregtorio)
    log = factorio("--create", str(WORK / "menusim-list.zip"))
    if load_errors(log):
        sys.exit("the mods do not load:\n" + load_errors(log))
    return {r[0]: (r[1], int(r[2])) for r in sections(log).get("MENUSIMS", [])}


def save_path(path):
    m = re.match(r"__([\w-]+)__/(.*)", path)
    if not m:
        return None
    if m.group(1) in BUILTIN:
        return FACTORIO / "data" / m.group(1) / m.group(2)
    return ROOT / m.group(2) if m.group(1) in MOD_NAMES else None


def run_menusim(name, save, length, gregtorio):
    """Load the simulation's save with --benchmark for its length; the helper mod runs its init and update chunks"""
    prepare_mods(menusim=name, gregtorio=gregtorio)
    path = save_path(save)
    if not path or not path.exists():
        return f"skipped (no save file: {save or 'none'})", []
    log = factorio("--benchmark", str(path), "--benchmark-ticks", str(length))
    lines = re.findall(r"DEVCHECK-MENUSIM (.*)", log)
    ran = re.search(r"Performed (\d+) updates", log)
    err = re.search(r"(Error while running.*|non-recoverable.*|Error.*)(\n.*){0,3}", log)
    if any(l.startswith("FAIL") for l in lines):
        return next(l for l in lines if l.startswith("FAIL")), lines
    if err and not ran:
        return "ERROR " + " ".join(x.strip() for x in err.group(0).splitlines()), lines
    if not any(l == "init done" for l in lines):
        return "ERROR init did not run", lines
    deaths = sum(1 for l in lines if l.startswith("DIED"))
    return f"ok ({ran.group(1)} ticks{f', {deaths} characters died' if deaths else ''})", lines


def menusim(a):
    """Run main menu simulations with the mod (and with --compare also without it) and report errors."""
    variants = [True, False] if a.compare else [True]
    failed = False
    for gregtorio in variants:
        label = "with Gregtorio" if gregtorio else "without Gregtorio"
        sims = menusim_list(gregtorio)
        names = sorted(sims) if a.sim == "all" else [a.sim]
        print(f"== {label}: {len(sims)} menu simulations{'' if a.sim == 'all' else ', running ' + a.sim}")
        for name in names:
            if name not in sims:
                print(f"{name}: not in main_menu_simulations")
                continue
            save, length = sims[name]
            result, lines = run_menusim(name, save, a.ticks or length, gregtorio)
            print(f"{name}: {result}")
            if a.sim != "all" or a.verbose:
                for l in lines:
                    print("    " + l)
            failed |= result.startswith(("ERROR", "FAIL"))
    print("\nRESULT: " + ("PROBLEMS FOUND" if failed else "OK"))
    return 1 if failed else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("setup")
    s.add_argument("--version", default="stable", help="Factorio version, e.g. 2.0.77 (default: stable)")
    s.add_argument("--factorio", help="use an existing unpacked headless Factorio instead of downloading")
    s.add_argument("--mods-from", help="folder with the dependency mod zips instead of downloading them")
    c = sub.add_parser("check")
    c.add_argument("--locale-out", help="also write the locale name list for tools/gen_locale.py")
    c.add_argument("--techs", help="regex: list matching technologies and whether they are researchable")
    c.add_argument("--balance-out", help="also write recipes (amounts, times), machine speeds and technology counts as JSON")
    c.add_argument("--fluids-out", help="also write the fluids with subgroup, order and icon (for gen_review_sheet.py fluids)")
    c.add_argument("--set", action="append", metavar="SETTING=true|false",
                   help="force a bool startup setting for this run, e.g. gregtorio-continued-one-pack-research=true")
    r = sub.add_parser("runtime")
    r.add_argument("--ticks", type=int, default=1500)
    r.add_argument("--seed", default=str(DEFAULT_SEED), help=f"map seed or `random` (default {DEFAULT_SEED})")
    m = sub.add_parser("migrate")
    src = m.add_mutually_exclusive_group(required=True)
    src.add_argument("--from-zip", help="older Gregtorio_x.y.z.zip to create the save with")
    src.add_argument("--from-ref", help="git tag or commit of an older version, e.g. 0e935ba (upstream 0.1.9)")
    m.add_argument("--ticks", type=int, default=600)
    m.add_argument("--old-me-network", help="git ref of the me-network checkout to create the old save with, "
                   "e.g. v0.1.0 for --from-ref v0.5.0 (default: the current checkout for both)")
    m.add_argument("--direct", action="store_true",
                   help=f"issue #209: load a save from before me-network {'.'.join(map(str, ME_CUT_OFF))} with the "
                   f"working copies directly, without the intermediate load with Gregtorio {STEP_GREGTORIO} and "
                   f"me-network {STEP_ME_NETWORK} (me-network 0.5.1 and later refuse it)")
    m.add_argument("--seed", default=str(DEFAULT_SEED), help=f"map seed or `random` (default {DEFAULT_SEED})")
    ms = sub.add_parser("menusim", help="run main menu simulations")
    ms.add_argument("--sim", default="nauvis_biter_base_laser_defense", help="simulation name or `all`")
    ms.add_argument("--compare", action="store_true", help="also run without Gregtorio")
    ms.add_argument("--ticks", type=int, help="ticks to run (default: the simulation's length)")
    ms.add_argument("--verbose", action="store_true", help="print the log lines with --sim all too")
    sub.add_parser("handover", help="issue #83: prototype of the ME state hand-over to me-network")
    al = sub.add_parser("all")
    al.add_argument("--ticks", type=int, default=1500)
    al.add_argument("--locale-out")
    al.add_argument("--techs")
    al.add_argument("--seed", default=str(DEFAULT_SEED), help=f"map seed of the runtime map or `random` (default {DEFAULT_SEED})")
    a = ap.parse_args()
    if a.cmd == "setup":
        return setup(a)
    if a.cmd == "check":
        return check(a)
    if a.cmd == "runtime":
        return runtime(a)
    if a.cmd == "migrate":
        return migrate(a)
    if a.cmd == "menusim":
        return menusim(a)
    if a.cmd == "handover":
        return handover(a)
    return check(a) or one_pack(a) or runtime(a)


if __name__ == "__main__":
    sys.exit(main())
