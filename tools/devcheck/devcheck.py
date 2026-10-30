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
    python tools/devcheck/devcheck.py menusim --sim gregtorio_steam_age --rebuild
                                                # issue #588: save a Gregtorio menu scene again, shrunk, with today's mods
    python tools/devcheck/devcheck.py handover  # issue #83: prototype of the ME state hand-over to me-network
    python tools/devcheck/devcheck.py gtnh-diff # issue #679: report of Gregtorio's recipes against GTNH's (not in `all`)

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
  * an enabled technology cannot be researched and is not in UNRESEARCHABLE_OK (empty since issue #640: the
    vanilla techs behind a disabled one are disabled), or one of the issue #29 QoL techs is neither researchable nor hidden
  * a fluid that is not hidden (the parameter fluids excepted) is not in the Fluids tab: its subgroup is missing or
    not in the item group "fluids"; fluids in the fallback row gregtorio-fluids-unsorted are a warning
It also reports how many technologies are researchable and where progression stops.
"""
import argparse, json, math, os, re, shutil, subprocess, sys, tarfile, urllib.parse, urllib.request
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
# (issue #535: Factorio 2.1 adds the built-in mod recycler, which space-age and quality depend on)
BUILTIN = {"base", "core", "space-age", "quality", "elevated-rails", "recycler"}
# the Factorio version the mod is written for (info.json factorio_version; the dependency mods are picked by it)
FACTORIO_VERSION = "2.1"


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
        rels = [r for r in meta["releases"] if r["info_json"].get("factorio_version") == FACTORIO_VERSION]
        if not rels:
            sys.exit(f"{name} has no release for Factorio {FACTORIO_VERSION} on the mod portal")
        rel = rels[-1]
        q = urllib.parse.urlencode({"username": user, "token": token})
        download(f"https://mods.factorio.com{rel['download_url']}?{q}", MODS / rel["file_name"])
    print("setup done")


# --------------------------------------------------------------------------------------------
# running factorio
# --------------------------------------------------------------------------------------------

MOD_NAMES = ("Gregtorio", "gregtorio-continued")   # the mod before and since 0.3.0
ME_NETWORK = "me-network"                           # the ME network since issue #83 (docs/SPLIT.md), a dependency
TEXTURES = "me-network-ae2-textures"                # me-network's texture mod, required since me-network #325
STAND_IN = "stand-in of the texture mod (Gregtorio devcheck, issue #231)"


def me_network_dir():
    """me-network as a checkout: ME_NETWORK_DIR, else the sibling ../me-network; None: the me-network_*.zip in
    .devcheck/mods is used (setup downloads it from the mod portal like the other dependencies)"""
    d = Path(os.environ.get("ME_NETWORK_DIR") or (ROOT.parent / ME_NETWORK))
    return d if (d / "info.json").exists() else None


def needs_me_network(info):
    return any(re.split(r"\s*[<>=]", dep.strip())[0].strip() == ME_NETWORK for dep in info.get("dependencies", []))


def engine_version(fdir=None):
    """issue #535: major.minor of the Factorio in `fdir` (default: .devcheck/factorio), from its data/base/info.json"""
    try:
        v = json.loads((Path(fdir or FACTORIO) / "data" / "base" / "info.json").read_text(encoding="utf-8"))["version"]
    except (OSError, ValueError, KeyError):
        return FACTORIO_VERSION
    return ".".join(v.split(".")[:2])


def helper_dir(src, files=None):
    """issue #535: a helper mod (checkmod/, runtimemod/, migratemod/) as it is when the Factorio in use is the one it is
    written for (FACTORIO_VERSION), else a copy in the work folder whose info.json says that Factorio's version: the
    helpers run in a 2.0 Factorio too (the old save of `migrate --old-factorio`). files: {name: text} written into a
    copy (also for this Factorio), e.g. the old version's migrations for the migrate helper (issue #552)"""
    v = engine_version()
    if v == FACTORIO_VERSION and not files:
        return src
    dest = WORK / ("helper-" + v) / src.name
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(src, dest)
    if v != FACTORIO_VERSION:
        f = dest / "info.json"
        info = json.loads(f.read_text(encoding="utf-8"))
        info["factorio_version"] = v
        f.write_text(json.dumps(info, indent=2), encoding="utf-8")
    for name, text in (files or {}).items():
        (dest / name).write_text(text, encoding="utf-8")
    return dest


def zip_migrations(path):
    """the file names in migrations/ of a mod zip (issue #552: Factorio runs a Lua migration once per save, so the
    migrate helper skips the check of a migration the old version already ran)"""
    import zipfile
    with zipfile.ZipFile(path) as z:
        return sorted(n.split("/")[-1] for n in z.namelist() if n.count("/") == 2 and n.split("/")[1] == "migrations"
                      and n.split("/")[-1])


def texture_stand_in(me_info, me_dir):
    """Issue #231: me-network 0.5.3 and later require its texture mod (me-network #325, `~ me-network-ae2-textures`).
    A Gregtorio run never loads the texture mod's graphics (CC BY-NC-SA, me-network #239; me-network's own harness does
    the same), so the mods folder gets an empty stand-in of its name: an info.json only, with the version of the
    checkout's ae2-textures/info.json (else the lowest version the dependency allows). Nothing for a me-network that
    does not require it (the older ones of `migrate`). Returns True when the stand-in was made."""
    dep = next((d.strip() for d in me_info.get("dependencies", [])
                if re.split(r"\s*[<>=]", d.strip().lstrip("~").strip())[0].strip() == TEXTURES), None)
    if not dep or dep.startswith(("!", "?", "(?)")):
        return False
    real = me_dir / "ae2-textures" / "info.json" if me_dir else None
    if real and real.exists():
        version = json.loads(real.read_text(encoding="utf-8"))["version"]
    else:
        m = re.search(r">=?\s*([\d.]+)", dep)
        version = m.group(1) if m else "0.0.1"
    stub = MODS / TEXTURES
    stub.mkdir()
    v = engine_version()                  # (issue #535: the Factorio in use, 2.0 for an old save)
    (stub / "info.json").write_text(json.dumps({"name": TEXTURES, "version": version, "title": STAND_IN,
                                                "author": "devcheck", "factorio_version": v,
                                                "dependencies": [f"base >= {v}"]}), encoding="utf-8")
    return True


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
                 settings=None, old_migrations=(), with_switch=False, helper=True):
    """mods/ = dependency zips + the mod (working copy or a zip) + devcheck helper mods.
    menusim: name of a main menu simulation for the menusim helper mod, or {"name": ..., more config} (written into the
    helper's config.lua); gregtorio=False leaves the mod out; helper=False leaves out the check helper too (issue #588:
    a menu scene's save is saved with the players' mods only).
    old_migrations: the migration files of the old save's version, for the migrate helper (`old-version.lua`).
    settings: {startup setting name: bool} forced for this run (`check --set`); without it every setting has its
    default, because mod-settings.dat is removed (a value stored by an earlier run would win over the default)."""
    remove_path(MODS / "mod-settings.dat")
    for p in MODS.iterdir():
        if p.name.startswith(MOD_NAMES + ("zz-gregtorio-devcheck",)) or p.name == "mod-list.json" or (
                p.name in (ME_NETWORK, TEXTURES) and not p.is_file()):
            remove_path(p)
    if list(MODS.glob(f"{TEXTURES}_*.zip")):
        sys.exit(f"{MODS}: remove {TEXTURES}_*.zip; a Gregtorio run loads the empty stand-in of the texture mod "
                 "(issue #231), never its graphics")
    if not gregtorio:
        info = None
    elif gregtorio_zip:
        info = zip_info(gregtorio_zip)
        # Factorio insists on <name>_<version>.zip
        shutil.copy2(gregtorio_zip, MODS / f"{info['name']}_{info['version']}.zip")
    else:
        info = json.loads((ROOT / "info.json").read_text(encoding="utf-8"))
        link_dir(MODS / info["name"], ROOT)
    if helper:
        link_dir(MODS / "zz-gregtorio-devcheck", helper_dir(HERE / "checkmod"))
    # the built-in mods of the Factorio in use (issue #535: 2.1 adds recycler; a 2.0 Factorio for an old save has none)
    builtin = [n for n in ("space-age", "quality", "elevated-rails", "recycler") if (FACTORIO / "data" / n).is_dir()]
    enabled = ["base"] + builtin + ([info["name"]] if info else []) + (["zz-gregtorio-devcheck"] if helper else [])
    zips = [z.name.rsplit("_", 1)[0] for z in MODS.glob("*.zip") if not z.name.startswith(MOD_NAMES)]
    enabled += [n for n in zips if n != ME_NETWORK]
    disabled = []
    if info and needs_me_network(info):
        # issue #83: a me-network checkout (ME_NETWORK_DIR or ../me-network) wins over the portal zip
        me_dir = me_network_dir()
        if me_dir:
            link_dir(MODS / ME_NETWORK, me_dir)
            me_info = json.loads((me_dir / "info.json").read_text(encoding="utf-8"))
        else:
            me_zips = sorted(MODS.glob(f"{ME_NETWORK}_*.zip"), key=lambda p: version_tuple(p.stem.rsplit("_", 1)[1]))
            me_info = zip_info(me_zips[-1]) if me_zips else {}
        enabled.append(ME_NETWORK)
        if texture_stand_in(me_info, me_dir):
            enabled.append(TEXTURES)
    elif ME_NETWORK in zips:
        # older versions of the mod (migrate) contain the ME network themselves and refuse to load next to it
        disabled.append(ME_NETWORK)
    if with_runtime:
        link_dir(MODS / "zz-gregtorio-devcheck-runtime", helper_dir(HERE / "runtimemod"))
        enabled.append("zz-gregtorio-devcheck-runtime")
    if with_migrate:
        lua = "return { migrations = {" + "".join(f" [{json.dumps(n)}] = true," for n in old_migrations) + " } }\n"
        link_dir(MODS / "zz-gregtorio-devcheck-migrate", helper_dir(HERE / "migratemod", {"old-version.lua": lua}))
        enabled.append("zz-gregtorio-devcheck-migrate")
    if with_switch:
        link_dir(MODS / "zz-gregtorio-devcheck-switch", helper_dir(HERE / "switchmod"))
        enabled.append("zz-gregtorio-devcheck-switch")
    if menusim:
        # a copy, not a link: config.lua names the simulation to run
        shutil.copytree(HERE / "menusimmod", MODS / "zz-gregtorio-devcheck-menusim")
        config = menusim if isinstance(menusim, dict) else {"name": menusim}
        (MODS / "zz-gregtorio-devcheck-menusim" / "config.lua").write_text(f"return {lua_literal(config)}\n")
        enabled.append("zz-gregtorio-devcheck-menusim")
    if settings:
        # a generated mod: forces the settings in the settings stage, after the mod defined them
        d = MODS / "zz-gregtorio-devcheck-settings"
        d.mkdir()
        (d / "info.json").write_text(json.dumps({
            "name": "zz-gregtorio-devcheck-settings", "version": "1.0.0", "title": "Gregtorio devcheck settings",
            "author": "rykon_", "factorio_version": engine_version(), "dependencies": ["? " + n for n in MOD_NAMES]}))
        # (issue #563: a string setting takes its value as the only allowed one; issue #593: a number setting too)
        (d / "settings-final-fixes.lua").write_text("".join(
            (f"do local s = data.raw['bool-setting'][{json.dumps(n)}] "
             f"assert(s, 'devcheck --set: no bool setting ' .. {json.dumps(n)}) "
             f"s.hidden = true s.forced_value = {'true' if v else 'false'} s.default_value = s.forced_value end\n")
            if isinstance(v, bool) else
            (f"do local s = data.raw['double-setting'][{json.dumps(n)}] or data.raw['int-setting'][{json.dumps(n)}] "
             f"assert(s, 'devcheck --set: no double or int setting ' .. {json.dumps(n)}) "
             f"s.hidden = true s.minimum_value = nil s.maximum_value = nil s.allowed_values = {{ {v!r} }} "
             f"s.default_value = {v!r} end\n")
            if isinstance(v, (int, float)) else
            (f"do local s = data.raw['string-setting'][{json.dumps(n)}] "
             f"assert(s, 'devcheck --set: no string setting ' .. {json.dumps(n)}) "
             f"s.hidden = true s.allowed_values = {{ {json.dumps(v)} }} s.default_value = {json.dumps(v)} end\n")
            for n, v in settings.items()))
        enabled.append("zz-gregtorio-devcheck-settings")
    (MODS / "mod-list.json").write_text(json.dumps({"mods": [{"name": n, "enabled": True} for n in enabled]
                                                    + [{"name": n, "enabled": False} for n in disabled]}))


def lua_literal(v):
    """a Lua literal of a JSON-like value (dict with string keys, list, str, number, bool, None)"""
    if isinstance(v, dict):
        return "{ " + " ".join(f"[{json.dumps(str(k))}] = {lua_literal(x)}," for k, x in v.items()) + " }"
    if isinstance(v, (list, tuple)):
        return "{ " + " ".join(f"{lua_literal(x)}," for x in v) + " }"
    if isinstance(v, bool):
        return "true" if v else "false"
    return "nil" if v is None else json.dumps(v)


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
        self.ctype = {}                     # crafter -> its prototype type (issue #560: furnaces pick their recipe)
        self.burnt, self.burners = [], {}   # (fuel item, burnt result, fuel categories); burner entity -> categories
        self.tools = {}                     # recipe -> the mold or lens it needs in the module slot (issue #316)
        self.itype, self.uses = {}, {}      # item -> its prototype type; item -> its uses besides recipes (issue #547)
        self.spoil = {}                     # item -> its spoil ticks, 0 when it does not spoil (issue #602)
        self.base = {"water", "steam"}
        mined, reach = {}, {}   # issue #501: resource -> its mined items; resource -> technologies of its planets
        gt_ores = set()         # issue #563: the resources of the map veins (category gt-ore)
        for p in rows:
            k = p[0]
            if k == "R":
                # (issue #535: a recipe has a list of categories since Factorio 2.1; `cat` is the first, a Gregtorio recipe's one)
                cats = [c for c in p[2].split(",") if c] or ["crafting"]
                self.R[p[1]] = dict(cat=cats[0], cats=set(cats), en=p[3] == "true", ing=split(p[4]), ingk=kinds(p[4]),
                                    res=split(p[5]), resk=kinds(p[5]),
                                    fin=kinds(p[4]).count("fluid"), fout=kinds(p[5]).count("fluid"),
                                    hidden=p[6] == "true", hide_craft=p[7] == "true", sg=p[8], group=p[9],
                                    icon=p[10] if len(p) > 10 else "")
            elif k == "C":
                self.C[p[1]] = p[3].split(",") if p[3] else []
                self.ctype[p[1]] = p[2]
                self.CF[p[1]] = (int(p[4]), int(p[5]))
            elif k == "I":
                self.I[p[1]] = p[3] if len(p) > 3 else ""
                self.itype[p[1]] = p[2]
                self.uses[p[1]] = [x for x in p[4].split(",") if x] if len(p) > 4 else []
                self.spoil[p[1]] = float(p[5]) if len(p) > 5 and p[5] else 0
            elif k == "T":
                self.T[p[1]] = dict(pre=[x for x in p[2].split(",") if x], eff=[x for x in p[3].split(",") if x],
                                    sci=[x for x in p[4].split(",") if x], trig=p[5], en=p[6] == "true",
                                    count=float(p[7]) if len(p) > 7 and p[7] else None)   # (issue #605)
            elif k == "M" and p[4] != "gregtorio-disabled":
                mined[p[1]] = ([p[2]] if p[2] else []) + [x.split(":", 1)[1] for x in p[3].split(",") if x]
                if p[4] == "gt-ore":
                    gt_ores.add(p[1])
            elif k == "P":
                reach.setdefault(p[1], set()).add(p[3] if len(p) > 3 else "")
            elif k == "O" and p[2]:
                self.base.add(p[2])
            elif k == "B":
                self.burnt.append((p[1], p[2], set(p[3].split(","))))     # (issue #535: fuel_categories since 2.1)
            elif k == "U":
                self.burners[p[1]] = p[2].split(",")
            elif k == "K":
                self.tools[p[1]] = p[2]
        # issue #501: a resource is there from the start unless every planet that places it is reached by a technology
        # (the Nether's map veins); then the technology unlocks a pseudo recipe `planet-mining:<resource>` that gives its
        # items, in the category `planet-mining` of the character
        # (issue #563: an ore of the map veins that no planet places, classic mode, gives nothing)
        for res, items in mined.items():
            techs = reach.get(res)
            if not techs and res in gt_ores:
                continue
            if not techs or "" in techs:
                self.base.update(items)
                continue
            name = "planet-mining:" + res
            self.R[name] = dict(cat="planet-mining", cats={"planet-mining"}, en=False, ing=[], res=items, fin=0, fout=0, hidden=False,
                                hide_craft=False, sg="", group="", icon="")
            for t in techs:
                if t in self.T:
                    self.T[t]["eff"].append(name)
        self.C.setdefault("character", []).append("planet-mining")
        # issue #316: a recipe needs its mold or lens (150, in the module slot) as if it were an ingredient
        for r, item in self.tools.items():
            if r in self.R and item not in self.R[r]["ing"]:
                self.R[r]["ing"].append(item)
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
                if v["cats"] & cats and all(i in self.avail for i in v["ing"]):
                    for x in v["res"]:
                        if x not in self.avail:
                            self.avail.add(x)
                            changed = True
            # a fuel burnt in a burner that can be built leaves its burnt result (the depleted fuel rods)
            fuel_cats = {c for e, cs in self.burners.items() if any(i in self.avail for i in item_of.get(e, []))
                         for c in cs}
            for fuel, burnt, cat in self.burnt:
                if fuel in self.avail and cat & fuel_cats and burnt not in self.avail:
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
            machines = [m for m in self.crafters if v["cats"] & set(self.C.get(m, []))]
            if not machines:
                out.append((r, f"no machine for category {v['cat']}"))
            elif missing:
                out.append((r, "ingredients never obtainable: " + ", ".join(missing)))
            elif (v["fin"] or v["fout"]) and not any(
                    self.CF.get(m, (0, 0))[0] >= v["fin"] and self.CF.get(m, (0, 0))[1] >= v["fout"] for m in machines):
                out.append((r, f"needs {v['fin']} fluid in / {v['fout']} out, no reachable machine has that"))
        return out

    def obtainable(self, techs):
        """Issue #237: what can be obtained with the recipes enabled from the start or unlocked by `techs` (as solve,
        without research; a worklist instead of the fixed point loop). Returns (items and fluids, recipe categories
        with a buildable machine)."""
        R, C = self.R, self.C
        if not hasattr(self, "_ob"):
            uses, by_cat, entity_of, burner_of = {}, {}, {}, {}
            for r, v in R.items():
                for i in set(v["ing"]):
                    uses.setdefault(i, []).append(r)
                by_cat.setdefault(v["cat"], []).append(r)
            for it, pr in self.I.items():
                if pr in C:
                    entity_of.setdefault(it, []).append(pr)
                if pr in self.burners:
                    burner_of.setdefault(it, []).extend(self.burners[pr])
            unl = {}
            for t, v in self.T.items():
                for r in v["eff"]:
                    unl.setdefault(r, []).append(t)
            self._ob = uses, by_cat, entity_of, burner_of, unl
        uses, by_cat, entity_of, burner_of, unl = self._ob
        ok = {r for r, v in R.items() if not v["hidden"] and (v["en"] or any(t in techs for t in unl.get(r, [])))}
        need = {r: len(set(R[r]["ing"])) for r in ok}
        avail, cats, crafters, fuel_cats = set(), set(), set(), set()
        queue, ready = [], [r for r in ok if need[r] == 0]

        def add(x):
            if x not in avail:
                avail.add(x)
                queue.append(x)

        def crafter(e):
            if e in crafters:
                return
            crafters.add(e)
            for c in C.get(e, []):
                if c not in cats:
                    cats.add(c)
                    ready.extend(r for r in by_cat.get(c, []) if r in ok and need[r] == 0)
        crafter("character")
        for x in self.base:
            add(x)
        while queue or ready:
            while ready:
                r = ready.pop()
                if R[r]["cats"] & cats:
                    for x in R[r]["res"]:
                        add(x)
            if not queue:
                break
            x = queue.pop()
            for e in entity_of.get(x, []):
                crafter(e)
            fuel_cats.update(burner_of.get(x, []))
            # a fuel burnt in a burner that can be built leaves its burnt result
            for fuel, burnt, cat in self.burnt:
                if fuel in avail and cat & fuel_cats:
                    add(burnt)
            for r in uses.get(x, []):
                if r in need:
                    need[r] -= 1
                    if need[r] == 0:
                        ready.append(r)
        return avail, cats


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
        if v["cat"] == "planet-mining":   # issue #501: the ores of a planet's map veins, mined there (no hand recipe)
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


def check_trigger_items(m, sec):
    """Issue #547: an item that a technology's craft-item trigger asks for and that has no use besides it fails: no recipe
    (enabled or unlocked by a researchable technology, not hidden, not a recycling recipe) takes it, no technology's
    research unit takes it (science packs), it places nothing,
    it is a plain `item` (tools, armor, capsules, modules and the like have their own use) and no fuel, tile, equipment
    or plant; unless it is in the allow-list FORK_TRIGGER_ONLY_ITEMS of prototypes/100-fork-fixes.lua with its reason
    (section TRIGGERONLYOK); an entry that is no such item fails too. Returns (info line, problems)."""
    allow = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("TRIGGERONLYOK", [])}
    triggers = {}
    for t, v in sorted(m.T.items()):
        mt = re.search(r'item = "([^"]+)"', v["trig"])
        if v["en"] and mt and 'type = "craft-item"' in v["trig"]:
            triggers.setdefault(mt.group(1), []).append(t)
    taken = set()
    for r in m.unlocked:
        v = m.R[r]
        if v["hidden"] or r.endswith("-recycling") or r.startswith("recycling-") or v["cat"] in ("recycling", "parameters"):
            continue
        taken.update(v["ing"])
    taken.update(s for v in m.T.values() if v["en"] for s in v["sci"])   # science packs: research units of a lab
    dead ={i: ts for i, ts in triggers.items() if i not in taken and not m.I.get(i) and m.itype.get(i) == "item"
            and not m.uses.get(i)}
    problems = [f"{i}: no recipe takes it and it has no other use than the craft trigger of {', '.join(ts)} (give it a "
                "consumer, or add it to FORK_TRIGGER_ONLY_ITEMS with its reason)" for i, ts in sorted(dead.items())
                if i not in allow]
    problems += [f"FORK_TRIGGER_ONLY_ITEMS: {i} has no reason" for i, why in sorted(allow.items()) if not why]
    problems += [f"FORK_TRIGGER_ONLY_ITEMS: {i} is not an item whose only use is a craft trigger (remove the entry)"
                 for i in sorted(allow) if i not in dead]
    return f"{len(triggers)} items of craft-item triggers, {len(dead)} without another use, {len(allow)} of them on " \
           f"purpose (FORK_TRIGGER_ONLY_ITEMS)", problems


def check_spoiling(m, sec):
    """Issue #602: GT New Horizons has no spoiling, so an item that spoils (`spoil_ticks` of the `I` rows) and that a
    recipe makes that is enabled or unlocked by a researchable technology and not hidden fails, unless it is in the
    allow-list FORK_SPOILING_KEPT of data-final-fixes.lua with its reason (section SPOILOK); an entry that is no such item
    fails too. Returns (info line, problems)."""
    allow = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("SPOILOK", [])}
    made = {}
    for r in m.unlocked:
        v = m.R[r]
        if not v["hidden"]:
            for x in v["res"]:
                if m.spoil.get(x):
                    made.setdefault(x, []).append(r)
    problems = [f"{i}: spoils after {m.spoil[i] / 60:g} s and {', '.join(sorted(rs)[:3])} makes it (take its spoiling off "
                "in data-final-fixes.lua, or add it to FORK_SPOILING_KEPT with its reason)"
                for i, rs in sorted(made.items()) if i not in allow]
    problems += [f"FORK_SPOILING_KEPT: {i} has no reason" for i, why in sorted(allow.items()) if not why]
    problems += [f"FORK_SPOILING_KEPT: {i} is not an item that spoils and that a reachable recipe makes (remove the entry)"
                 for i in sorted(allow) if i not in made]
    return f"{sum(1 for s in m.spoil.values() if s)} items spoil, {len(made)} of them made by a reachable recipe, " \
           f"{len(allow)} on purpose (FORK_SPOILING_KEPT)", problems
RESEARCH_BAND_LOW = 50    # the count of the reach, void miner and space elevator technologies (issue #605)


def check_research_counts(m, sec):
    """Issue #605: prototypes/138-fork-research-balance.lua scales the counts from UV science up (9 packs and more). A
    researchable technology of 9 or more packs with a count outside the band of its pack count fails: from
    RESEARCH_BAND_LOW (or the lowest count of 138's table at that pack count, if lower) to the highest count that 138's
    table (section RESEARCHCOUNTS) gives a technology of that pack count; unless it is in the allow-list FORK_RESEARCH_OUTLIERS of 138 with its reason (section RESEARCHOK). Infinite
    technologies (a count formula, no count) are left out. An entry that is no such technology fails too. Returns (info
    line, problems)."""
    allow = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("RESEARCHOK", [])}
    target = {r[0]: float(r[1]) for r in sec.get("RESEARCHCOUNTS", []) if len(r) > 1}
    low, high, rows = {}, {}, []
    for t in sorted(m.researched):
        v = m.T.get(t)
        if not v or v.get("count") is None or len(v["sci"]) < 9:
            continue
        n = len(v["sci"])
        rows.append((t, n, v["count"]))
        if t in target:   # the band comes from the table's counts, not from what the load made of them
            high[n] = max(high.get(n, 0), target[t])
            low[n] = min(low.get(n, RESEARCH_BAND_LOW), target[t])
    outside = {t: (n, c) for t, n, c in rows if n in high and not low[n] <= c <= high[n]}
    problems = [f"{t}: {c:g} units of {n} packs, outside the band {low[n]:g}-{high[n]:g} of its pack count (scale it in "
                "prototypes/138-fork-research-balance.lua, or add it to FORK_RESEARCH_OUTLIERS with its reason)"
                for t, (n, c) in sorted(outside.items()) if t not in allow]
    problems += [f"FORK_RESEARCH_OUTLIERS: {t} has no reason" for t, why in sorted(allow.items()) if not why]
    problems += [f"FORK_RESEARCH_OUTLIERS: {t} is not a technology outside its band (remove the entry)"
                 for t in sorted(allow) if t not in outside]
    bands = ", ".join(f"{n} packs {low[n]:g}-{h:g}" for n, h in sorted(high.items()))
    return f"{len(rows)} researchable technologies of 9 or more packs, bands {bands}; {len(allow)} outside on purpose " \
           "(FORK_RESEARCH_OUTLIERS)", problems
NYI_ICON = "graphics/technology/nyi.png"


def check_nyi_icons(sec):
    """Issue #639: a shown technology, item, fluid or recipe of the load (the `shown` column of section NAMES) whose own
    icon (section ICONS: the mod's files of `icon` and `icons`) is the NYI placeholder, graphics/technology/nyi.png or
    a file of the mod with the same bytes, fails unless it is in the allow-list FORK_NYI_ICONS of
    prototypes/199-fork-finalize.lua with its reason (section NYIOK); an entry that is no such prototype fails too.
    Returns (info line, problems)."""
    allow = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("NYIOK", [])}
    nyi = (ROOT / NYI_ICON).read_bytes()
    same = {}

    def is_nyi(path):
        if path not in same:
            f = ROOT / path.split("__gregtorio-continued__/", 1)[-1]
            same[path] = f.is_file() and f.stat().st_size == len(nyi) and f.read_bytes() == nyi
        return same[path]
    shown = {(r[0], r[2]) for r in sec.get("NAMES", []) if len(r) > 5 and r[5]}
    found = {}
    for r in sec.get("ICONS", []):
        if len(r) < 3:
            continue
        hits = [p for p in r[2].split(",") if is_nyi(p)]
        if hits and (r[0], r[1]) in shown:
            found[r[1]] = (r[0], hits[0])
    copies = sorted({p for p, v in same.items() if v})
    problems = [f"{cls} {name}: shows the NYI placeholder ({path}; give it an icon, e.g. tools/gen_tech_icons.py with "
                "tools/tech-icons.tsv, or add it to FORK_NYI_ICONS with its reason)"
                for name, (cls, path) in sorted(found.items()) if name not in allow]
    problems += [f"FORK_NYI_ICONS: {n} has no reason" for n, why in sorted(allow.items()) if not why]
    problems += [f"FORK_NYI_ICONS: {n} does not show the NYI placeholder (remove the entry)" for n in sorted(allow)
                 if n not in found]
    return f"{len(copies)} placeholder files in use, {len(found)} shown prototypes with one, {len(allow)} on purpose " \
           "(FORK_NYI_ICONS)", problems


OVERCLOCK = "gregtorio-continued-gt-overclocking"


def check_overclocking(sec):
    """Issue #616 (prototypes/fork-gt-overclocking.lua, section OVERCLOCK): with the setting on, every electric crafting
    machine with a crafting speed of 2 or more draws its power times 2^floor(log2(speed)) (GT's 4x power per tier) and the
    others are left; with it off, none is changed. Returns (info line, problems)."""
    rows = sec.get("OVERCLOCK", [])
    if not rows:
        return "no section OVERCLOCK (older version)", []
    on = rows[0][1] == "true"
    problems, changed = [], 0
    for r in rows[1:]:
        name, speed, factor = r[0], float(r[1]), float(r[2])
        want = 2 ** math.floor(math.log2(speed) + 1e-9) if on and speed >= 2 else 1
        changed += factor != 1
        if abs(factor - want) > 1e-9:
            problems.append(f"{name}: crafting speed {speed:g}, power factor {factor:g}, expected {want:g}")
    return f"setting {'on' if on else 'off'}: {changed} of {len(rows) - 1} electric crafting machines draw more power", problems


VANILLA_MODS = {"base", "space-age", "quality", "elevated-rails"}


def check_engraver_lenses(m, sec):
    """Issue #325: GT engraves with a lens that stays (prototypes/150-fork-molds.lua puts it into the engraver's lens slot,
    `K` rows of the dump). Every laser engraver recipe needs one, except the allow-list FORK_ENGRAVER_NO_LENS of
    prototypes/155-fork-ore-chain.lua with its reason (section ENGRAVERNOLENS); an entry that is not a laser engraver
    recipe without a lens fails too. Returns (info line, problems)."""
    kept = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("ENGRAVERNOLENS", [])}
    engraver = [r for r, v in m.R.items() if "laser-engraver" in v["cat"] and not v["hidden"]]
    without = sorted(r for r in engraver if r not in m.tools)
    problems = [f"{r}: a laser engraver recipe without a lens (GTNH's lens of the recipe, or FORK_ENGRAVER_NO_LENS)"
                for r in without if r not in kept]
    problems += [f"FORK_ENGRAVER_NO_LENS: {r} has no reason" for r, why in sorted(kept.items()) if not why]
    problems += [f"FORK_ENGRAVER_NO_LENS: {r} is not a laser engraver recipe without a lens" for r in sorted(kept)
                 if r not in without]
    return f"{len(engraver)} laser engraver recipes, {len(engraver) - len(without)} with a lens in the lens slot, " \
           f"{len(kept)} without one on purpose (FORK_ENGRAVER_NO_LENS)", problems


def check_electric_mine(m, sec):
    """Issue #335 (prototypes/163-fork-electric-mine.lua): every recipe of the Manual Mine and the Dig Site has an electric
    twin for the Ore Drilling Plants (the same results, Drilling Fluid and, issues #341 and #346, mining pipes as
    ingredients, category electric-mine-recipes) and (issue #337) one for the Miners (category miner-recipes, the same
    results, mining pipes as the ingredient), unless it is in the allow-list FORK_ELECTRIC_MINE_EXCLUDED with its reason (section
    ELECTRICMINE); an entry that is no such recipe or has a twin fails too. Returns (info line, problems)."""
    rows = [r + [""] * (5 - len(r)) for r in sec.get("ELECTRICMINE", [])]
    manual = [r for r in rows if r[1] == "manual"]
    problems = [f"{r[0]}: a Manual Mine or Dig Site recipe without an electric twin (163 makes one for a mining-<vein> "
                "recipe it sees, or add it to FORK_ELECTRIC_MINE_EXCLUDED with its reason)"
                for r in manual if r[2] == "-" and not r[3]]
    problems += [f"{r[0]}: a Manual Mine recipe with the Ore Drilling Plant's twin but no Miner twin" for r in manual
                 if r[2] != "-" and r[4] in ("", "-")]
    problems += [f"FORK_ELECTRIC_MINE_EXCLUDED: {r[0]} " + ("is not a Manual Mine or Dig Site recipe" if r[1] != "manual"
                 else f"has the twin {r[2]}") + " (remove the entry)" for r in rows if r[3] and (r[1] != "manual" or r[2] != "-")]
    for r in manual:
        if r[0] not in m.R:
            continue
        res = sorted(m.R[r[0]]["res"])
        twin = m.R.get(r[2])
        if twin is not None and (twin["cat"] != "electric-mine-recipes"
                                 or sorted(twin["ing"]) != ["drilling-fluid", "mining-pipe"]
                                 or sorted(twin["res"]) != res):
            problems.append(f"{r[2]}: not the twin of {r[0]} (category {twin['cat']}, ingredients {twin['ing']}, "
                            f"results {twin['res']} against {m.R[r[0]]['res']})")
        miner = m.R.get(r[4])
        if miner is not None and (miner["cat"] != "miner-recipes" or miner["ing"] != ["mining-pipe"]
                                  or sorted(miner["res"]) != res):
            problems.append(f"{r[4]}: not the Miner twin of {r[0]} (category {miner['cat']}, ingredients {miner['ing']}, "
                            f"results {miner['res']} against {m.R[r[0]]['res']})")
    twins = sum(1 for r in manual if r[2] != "-")
    miners = sum(1 for r in manual if r[4] not in ("", "-"))
    return (f"{len(manual)} Manual Mine and Dig Site recipes, {twins} with an electric twin, {miners} with a Miner twin, "
            f"{sum(1 for r in manual if r[3])} without one on purpose (FORK_ELECTRIC_MINE_EXCLUDED)", sorted(problems))


def check_vanilla_recipes(m, sec):
    """Issues #317 and #318: a vanilla recipe that no technology unlocks (and that is not enabled), whose every product
    a reachable recipe of another kind makes, and that is not hidden, is an alternative in Factoriopedia that nobody can
    use (the vanilla battery next to GTNH's filled battery hulls). data-final-fixes.lua deletes such recipes
    (VANILLA_RECIPES_REMOVED); one that stays on purpose goes into FORK_VANILLA_RECIPES_KEPT with its reason. Returns
    (info line, problems)."""
    owner = {r[0]: r[1] for r in sec.get("OWNERS", []) if len(r) > 1}
    kept = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("VANILLAKEPT", [])}
    unlocked_by_tech = {r for v in m.T.values() if v["en"] for r in v["eff"]}
    makers = {}
    for r, v in m.R.items():
        if v["hidden"] or v["cat"] in ("recycling", "parameters") or r.endswith("-recycling"):
            continue
        for x in v["res"]:
            makers.setdefault(x, []).append(r)
    found = []
    for r, v in sorted(m.R.items()):
        if owner.get(r) not in VANILLA_MODS or v["hidden"] or v["en"] or r in unlocked_by_tech or not v["res"]:
            continue
        if r.endswith("-recycling") or r.startswith("void-") or v["cat"] in ("recycling", "parameters"):
            continue
        if all(any(o != r and o in m.unlocked for o in makers.get(x, [])) for x in v["res"]):
            found.append(r)
    problems = [f"{r} ({owner[r]}): makes {', '.join(m.R[r]['res'])}, which Gregtorio makes another way; no technology "
                f"unlocks it" for r in found if r not in kept]
    problems += [f"FORK_VANILLA_RECIPES_KEPT: {r} has no reason" for r, why in sorted(kept.items()) if not why]
    problems += [f"FORK_VANILLA_RECIPES_KEPT: {r} is not such a recipe (any more)" for r in sorted(kept) if r not in found]
    return f"{len(found)} vanilla recipes without a technology of items Gregtorio makes, {len(kept)} kept on purpose " \
           f"(FORK_VANILLA_RECIPES_KEPT)", problems


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


def check_me_tab(sec):
    """Issue #519: every ME item (ME_NETWORK.items, Gregtorio's own FORK_ME_TAB_ITEMS of the compat file) sits in a row of
    me-network's tab "ME Network" (the item group ME_NETWORK.GROUP), unless it is in the allow-list FORK_ME_TAB_OUTSIDE
    with its reason; a Gregtorio recipe of an ME item (FORK_ME_RECIPES) that sits in the tab sits in its item's row (the
    other ones keep their machine rows). An allow-list entry that is no ME item or sits in the tab fails too. Returns
    (info line, problems)."""
    rows = sec.get("METAB", [])
    group = next((r[1] for r in rows if r[0] == "group"), "-")
    items = {r[1]: r for r in rows if r[0] == "item"}
    allow = {r[1]: (r[2] if len(r) > 2 else "") for r in rows if r[0] == "allow"}
    recipes = [r for r in rows if r[0] == "recipe"]
    outside = {n: r for n, r in items.items() if r[3] != group}
    problems = [f"{n}: subgroup {r[2]}, group {r[3]}: not in the tab {group} (move it into a row of the tab or add it to "
                "FORK_ME_TAB_OUTSIDE)" for n, r in outside.items() if n not in allow]
    problems += [f"FORK_ME_TAB_OUTSIDE: {n} has no reason" for n, why in allow.items() if not why]
    problems += [f"FORK_ME_TAB_OUTSIDE: {n} is " + ("no ME item" if n not in items else "in the tab") + " (remove the entry)"
                 for n in allow if n not in outside]
    problems += [f"recipe {r[1]}: row {r[2]} of the tab, its item's row is {r[3]}" for r in recipes if r[2] != r[3]]
    if rows and group == "-":
        problems.append("no ME_NETWORK.GROUP (me-network before 0.5.7?)")
    return (f"{len(items) - len(outside)} of {len(items)} ME items in the tab {group}, {len(allow)} outside on purpose; "
            f"{len(recipes)} recipes in the tab", sorted(problems))


ORE_MODE = "gregtorio-continued-ore-mode"


VEIN_TABLE_BEGIN = "<!-- vein table: written by `devcheck.py check --vein-table` (issue #574), do not edit -->"
VEIN_TABLE_END = "<!-- end of the vein table -->"
VEIN_TABLE_DOC = ROOT / "docs" / "ORE-VEINS.md"
PLANET_NAMES = {"nauvis": "Nauvis", "gt-nether": "Nether", "gt-twilight": "Twilight Forest", "gt-end": "The End"}


def vein_table(sec):
    """Issue #574: the placed veins (section VEINTABLE) as a markdown table, by surface and GT's weight."""
    order = list(PLANET_NAMES)
    rows = [r + [""] * (10 - len(r)) for r in sec.get("VEINTABLE", [])]

    def key(r):
        first = min((order.index(p) if p in order else 9) for p in r[2].split(","))
        return first, -int(r[7]), r[1]
    out = ["| Vein | Surfaces | Primary | Secondary | In between | Sporadic | Weight | Density | Size |",
           "|---|---|---|---|---|---|---|---|---|"]
    for r in sorted(rows, key=key):
        ores = [x.replace("-", " ") if x else "-" for x in r[3:7]]
        out.append(f"| {r[1]} Vein | {', '.join(PLANET_NAMES.get(p, p) for p in r[2].split(','))} | "
                   + " | ".join(ores) + f" | {r[7]} | {r[8]} | {r[9]} |")
    return "\n".join(out)


def check_vein_table(sec, write=False):
    """Issue #574: docs/ORE-VEINS.md holds the table of the placed veins between its markers; `check --vein-table`
    writes it, `check` fails when it differs from the mod's veins. Returns (info line, problems)."""
    if "VEINTABLE" not in sec:
        return "skipped (no VEINTABLE section)", []
    table = vein_table(sec)
    text = VEIN_TABLE_DOC.read_text(encoding="utf-8")
    nl = "\r\n" if "\r\n" in text else "\n"
    i, j = text.find(VEIN_TABLE_BEGIN), text.find(VEIN_TABLE_END)
    if i < 0 or j < i:
        return "no markers", [f"{VEIN_TABLE_DOC.name}: the markers of the vein table are missing"]
    current = text[i + len(VEIN_TABLE_BEGIN):j].strip().replace("\r\n", "\n")
    if current == table:
        return f"{len(sec['VEINTABLE'])} veins, the table is up to date", []
    if write:
        new = text[:i + len(VEIN_TABLE_BEGIN)] + nl + table.replace("\n", nl) + nl + text[j:]
        VEIN_TABLE_DOC.write_bytes(new.encode("utf-8"))
        return f"{len(sec['VEINTABLE'])} veins, the table written", []
    return "differs", [f"{VEIN_TABLE_DOC.name}: the vein table differs from the mod's veins (run `devcheck.py check "
                       f"--vein-table`)"]


ITEM_RENAMES = ROOT / "prototypes" / "data" / "item-renames.lua"


def item_renames(m):
    """Issue #580: the item renames of the JSON migrations (migrations/*.json, "item": [[old, new], ...]) in file and row
    order, as (old, new, file); and the ones whose target is no item of the loaded game (the engine drops those items, so
    the ME network does too)"""
    rows, skipped = [], []
    for f in sorted((ROOT / "migrations").glob("*.json")):
        for pair in json.loads(f.read_text(encoding="utf-8")).get("item", []):
            old, new = pair[0], pair[1]
            (rows if new in m.I else skipped).append((old, new, f.name))
    return rows, skipped


def item_renames_lua(rows):
    out = ["--- Generated by `tools/devcheck/devcheck.py check --item-renames` from the JSON migrations (migrations/*.json, issue",
           "--- #580); do not edit, run it again. Every item rename of them whose target is an item of the game, in file order:",
           "--- { old, new }. prototypes/120-fork-me-network-compat.lua tells the ME network each (ME_NETWORK.replace_item): a JSON",
           "--- migration renames items in the engine's inventories only, the ME network keeps its contents in script storage.",
           "return {"]
    last = None
    for old, new, f in rows:
        if f != last:
            out.append(f"\t-- {f}")
            last = f
        out.append(f'\t{{ "{old}", "{new}" }},')
    out.append("}")
    return "\n".join(out) + "\n"


def read_item_renames():
    """the pairs of prototypes/data/item-renames.lua (None: no file)"""
    if not ITEM_RENAMES.exists():
        return None
    return re.findall(r'\{ "([^"]+)", "([^"]+)" \}', ITEM_RENAMES.read_text(encoding="utf-8"))


def check_item_renames(m, write=False):
    """Issue #580: prototypes/data/item-renames.lua holds every item rename of the JSON migrations whose target is an item
    (`check --item-renames` writes it); `check` fails for a migration's item rename that the table lacks and for a pair of
    the table that no migration has. Returns (info line, problems)."""
    rows, skipped = item_renames(m)
    want = [(o, n) for o, n, _ in rows]
    info = (f"{len(want)} item renames of {len({f for _, _, f in rows})} JSON migrations"
            + (f"; {len(skipped)} whose target is no item, left out: "
               + ", ".join(f"{o} -> {n} ({f})" for o, n, f in skipped) if skipped else ""))
    have = read_item_renames()
    text = item_renames_lua(rows)
    if have == want and ITEM_RENAMES.read_text(encoding="utf-8").replace("\r\n", "\n") == text:
        return info + ", the table is up to date", []
    if write:
        ITEM_RENAMES.write_bytes(text.encode("utf-8"))
        return info + ", the table written", []
    if have is None:
        return info + ", no table", [f"{ITEM_RENAMES.name} is missing (run `devcheck.py check --item-renames`)"]
    problems = [f"{o} -> {n}: a JSON migration renames this item, {ITEM_RENAMES.name} does not have it" for o, n in want
                if (o, n) not in have]
    problems += [f"{o} -> {n}: in {ITEM_RENAMES.name}, but no JSON migration renames the item so (or its target is no item)"
                 for o, n in have if (o, n) not in want]
    if not problems:
        problems = [f"{ITEM_RENAMES.name} is not what `devcheck.py check --item-renames` writes (order or text)"]
    return info, problems


def check_gtnh_numbers(sec, write=False):
    """Issue #689 (prototypes/168-fork-gtnh-numbers.lua): every Gregtorio recipe with a GT recipe of the same items and
    fluids (tools/gtnh_map.py on the GT New Horizons dump) has GT's time, item amounts, chances and (downward) tier, by
    prototypes/data/gtnh-numbers.lua, which `check --gtnh-numbers` writes; `check` fails for a table that is not what it
    writes, for a recipe of the table whose numbers still differ (made or changed after 168), and for an entry of
    FORK_GTNH_NUMBERS_KEPT without a reason or without a GT recipe of other numbers. Returns (info line, problems)."""
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    kept = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("GTNHKEPT", [])}
    state = {}
    gtnh_map.run(gtnh_map.load_dump(gtnh_map.DUMP), sec, None, state=state)
    old = gtnh_map.numbers_names()
    table, diffs, left = gtnh_map.numbers(state, set(kept), old)
    _, kept_diffs, _ = gtnh_map.numbers(state, (), ())
    text = gtnh_map.numbers_lua(table)
    path = gtnh_map.NUMBERS_FILE
    have = path.read_text(encoding="utf-8").replace("\r\n", "\n") if path.exists() else None
    info = (f"{len(state['pending'])} GT recipes matched, {len(table)} Gregtorio recipes with GT's numbers from "
            f"{path.name}, {len(kept)} kept (FORK_GTNH_NUMBERS_KEPT); left to other issues: "
            + ", ".join(f"{k} {v}" for k, v in sorted(left.items())))
    problems = [f"FORK_GTNH_NUMBERS_KEPT: {n} has no reason" for n, why in sorted(kept.items()) if not why]
    problems += [f"FORK_GTNH_NUMBERS_KEPT: {n} has no GT recipe of other numbers (remove the entry)"
                 for n in sorted(kept) if n not in kept_diffs]
    if have != text:
        if write:
            path.write_bytes(text.encode("utf-8"))
            return info + "; the table written (run `check` again to see it applied)", problems
        return info, problems + [f"{path.name} is not what `devcheck.py check --gtnh-numbers` writes ({len(diffs)} "
                                 f"recipes with other numbers than GT's: run it, or keep a recipe in FORK_GTNH_NUMBERS_KEPT "
                                 f"of prototypes/168-fork-gtnh-numbers.lua with its reason)"]
    problems += [f"{n}: {', '.join(d)} (the table has GT's numbers, a file after 168-fork-gtnh-numbers.lua changes them: "
                 f"set GT's numbers there or keep the recipe in FORK_GTNH_NUMBERS_KEPT)" for n, d in sorted(diffs.items())]
    return info + "; the table is up to date", problems


def check_gtnh_recycling(sec, write=False):
    """Issue #686 (prototypes/157-fork-recycling.lua): prototypes/data/gtnh-recycling.lua holds GT New Horizons'
    recycling of every material part that maps onto Gregtorio's names (tools/gtnh_map.py `recycling_imports` on the
    dump), `check --gtnh-recycling` writes it; `check` fails when it is not what that writes and for an entry whose
    recipe the load lacks. Returns (info line, problems)."""
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    entries, items, skipped = gtnh_map.recycling_imports(gtnh_map.load_dump(gtnh_map.DUMP), gtnh_map.Gregtorio(sec))
    text = gtnh_map.recycling_lua(entries, items)
    path = gtnh_map.RECYCLING_FILE
    have = path.read_text(encoding="utf-8").replace("\r\n", "\n") if path.exists() else None
    from collections import Counter
    kinds = Counter(e["kind"] for e in entries)
    info = (f"{len(entries)} part recycling recipes of GT (" + ", ".join(f"{k} {v}" for k, v in sorted(kinds.items()))
            + f"), {len(items)} other items GT recycles (157's rule), parts whose machine takes them already: " + (", ".join(f"{k} {v}" for k, v in sorted(skipped.items())) or "0"))
    if have != text:
        if write:
            path.write_bytes(text.encode("utf-8"))
            return info + "; the table written (run `check` again to load it)", []
        return info, [f"{path.name} is not what `devcheck.py check --gtnh-recycling` writes (run it)"]
    # (a recipe of an item that data-final-fixes.lua deletes, a vanilla or Space Age item, goes with it)
    recipes = {r[1] for r in sec.get("DUMP", []) if r[0] == "R"}
    gone = [e for e in entries if f"recycling-{e['kind']}-{e['item']}" not in recipes]
    return info + f"; the table is up to date ({len(gone)} deleted with their item)", []


def check_gtnh_routes(sec, write=False):
    """Issue #687 (prototypes/158-fork-gt-parts.lua, section 3): prototypes/data/gtnh-part-routes.lua holds GT New
    Horizons' recipes of the cutting machine, bender, extruder, wiremill, forge hammer, fluid solidifier and lathe that
    Gregtorio lacks (tools/gtnh_map.py `route_imports` on the dump), `check --gtnh-routes` writes it; `check` fails when
    it is not what that writes. Returns (info line, problems)."""
    from collections import Counter
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    entries, left = gtnh_map.route_imports(gtnh_map.load_dump(gtnh_map.DUMP), gtnh_map.Gregtorio(sec))
    text = gtnh_map.routes_lua(entries)
    path = gtnh_map.ROUTES_FILE
    have = path.read_text(encoding="utf-8").replace("\r\n", "\n") if path.exists() else None
    verbs = Counter(e["name"].split("-")[1] for e in entries)
    recipes = {r[1] for r in sec.get("DUMP", []) if r[0] == "R"}
    gone = {e["name"] for e in entries if e["name"] not in recipes}
    info = (f"{len(entries)} GT part routes (" + ", ".join(f"{k} {v}" for k, v in sorted(verbs.items())) + "); left out: "
            + (", ".join(f"{k} {v}" for k, v in sorted(left.items())) or "none"))
    if have != text:
        if write:
            path.write_bytes(text.encode("utf-8"))
            return info + "; the table written (run `check` again to load it)", []
        return info, [f"{path.name} is not what `devcheck.py check --gtnh-routes` writes (run it)"]
    # (a route whose items and fluids all exist in the load must have been made)
    have_items = {r[1] for r in sec.get("DUMP", []) if r[0] in ("I", "F")}
    names = lambda e: list(e["i"]) + list(e["f"]) + [o[0] for o in e["o"]] + list(e["fo"])
    skipped = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("GTROUTESKIP", [])}
    why = Counter(skipped[n] for n in gone if n in skipped)
    problems = [f"{n}: in {path.name}, but 158 neither made it nor says why (FORK_GT_PARTS.routes_skipped)"
                for n in sorted(gone) if n not in skipped and all(x in have_items for x in names(next(
                    e for e in entries if e["name"] == n)))]
    return info + f"; the table is up to date ({len(gone)} not made: " + ", ".join(
        f"{k} {v}" for k, v in sorted(why.items())) + ")", problems


def check_gtnh_crafting(sec, write=False):
    """Issue #688 (prototypes/158-fork-gt-parts.lua, section 4): prototypes/data/gtnh-part-crafting.lua holds GT New
    Horizons' crafting table recipes of the material parts and dust piles that Gregtorio lacks, GT's tools as #612's
    charges (tools/gtnh_map.py `crafting_imports`), `check --gtnh-crafting` writes it; `check` fails when it is not what
    that writes and for a recipe of it that 158 neither made nor says why. Returns (info line, problems)."""
    from collections import Counter
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    entries, left = gtnh_map.crafting_imports(gtnh_map.load_dump(gtnh_map.DUMP), gtnh_map.Gregtorio(sec))
    text = gtnh_map.crafting_lua(entries)
    path = gtnh_map.CRAFTING_FILE
    have = path.read_text(encoding="utf-8").replace("\r\n", "\n") if path.exists() else None
    info = (f"{len(entries)} crafting table recipes of GT's parts; left out: "
            + (", ".join(f"{k} {v}" for k, v in sorted(left.items())) or "none"))
    if have != text:
        if write:
            path.write_bytes(text.encode("utf-8"))
            return info + "; the table written (run `check` again to load it)", []
        return info, [f"{path.name} is not what `devcheck.py check --gtnh-crafting` writes (run it)"]
    recipes = {r[1] for r in sec.get("DUMP", []) if r[0] == "R"}
    skipped = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("GTROUTESKIP", [])}
    gone = [e["name"] for e in entries if e["name"] not in recipes]
    why = Counter(skipped.get(n, "?") for n in gone)
    problems = [f"{n}: in {path.name}, but 158 neither made it nor says why" for n in gone if n not in skipped]
    return info + f"; the table is up to date ({len(gone)} not made: " + ", ".join(
        f"{k} {v}" for k, v in sorted(why.items())) + ")", problems


def check_gtnh_chemistry(sec, write=False):
    """Issue #691 (prototypes/158-fork-gt-parts.lua, section 3): prototypes/data/gtnh-chemistry.lua holds GT New
    Horizons' recipes of the distillery, electrolyzer, autoclave, centrifuge, chemical reactors, mixer and chemical bath
    that Gregtorio lacks (tools/gtnh_map.py `route_imports` with CHEM_IMPORT), `check --gtnh-chemistry` writes it; `check`
    fails when it is not what that writes and for a recipe of it that 158 neither made nor says why. Returns (info line,
    problems)."""
    from collections import Counter
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    entries, left = gtnh_map.route_imports(gtnh_map.load_dump(gtnh_map.DUMP), gtnh_map.Gregtorio(sec),
                                           gtnh_map.CHEM_IMPORT, chemistry=True)
    text = gtnh_map.routes_lua(entries, chemistry=True)
    path = gtnh_map.CHEMISTRY_FILE
    have = path.read_text(encoding="utf-8").replace(chr(13) + chr(10), chr(10)) if path.exists() else None
    verbs = Counter(e["name"].split("-")[1] for e in entries)
    info = (f"{len(entries)} GT chemistry recipes (" + ", ".join(f"{k} {v}" for k, v in sorted(verbs.items()))
            + "); left out: " + (", ".join(f"{k} {v}" for k, v in sorted(left.items())) or "none"))
    if have != text:
        if write:
            path.write_bytes(text.encode("utf-8"))
            return info + "; the table written (run `check` again to load it)", []
        return info, [f"{path.name} is not what `devcheck.py check --gtnh-chemistry` writes (run it)"]
    recipes = {r[1] for r in sec.get("DUMP", []) if r[0] == "R"}
    skipped = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("GTROUTESKIP", [])}
    gone = [e["name"] for e in entries if e["name"] not in recipes]
    why = Counter(skipped.get(n, "?") for n in gone)
    problems = [f"{n}: in {path.name}, but 158 neither made it nor says why" for n in gone if n not in skipped]
    return info + f"; the table is up to date ({len(gone)} not made: " + ", ".join(
        f"{k} {v}" for k, v in sorted(why.items())) + ")", problems


def check_classic_veins(m, sec):
    """Issue #563 (prototypes/166-fork-classic-veins.lua): every vein the map places (GT's mixes on a planet with map
    veins, read by checkmod from FORK_ORE_MIXES) has its classic vein recipe and both twins, and the recipe gives the
    vein's ores (a kept recipe, upstream's Copper Tin Vein, at least them); in classic mode (the startup setting
    gregtorio-continued-ore-mode = vein-recipes) a researchable technology unlocks the three, in map-vein mode they are
    hidden. Returns (info line, problems)."""
    mode = next((r[1] for r in sec.get("SETTINGS", []) if r[0] == ORE_MODE), "absent")
    rows = [r + [""] * (7 - len(r)) for r in sec.get("CLASSICVEINS", [])]
    problems = []
    for mix, recipe, twin, miner, ores, res, kept in rows:
        for kind, name in (("recipe", recipe), ("twin", twin), ("Miner twin", miner)):
            if name == "-":
                problems.append(f"{mix}: no classic {kind}")
            elif mode == "vein-recipes" and name not in m.unlocked:
                problems.append(f"{mix}: {name} is not unlocked in classic mode")
            elif mode != "vein-recipes" and not kept and name in m.R and not m.R[name]["hidden"]:
                problems.append(f"{mix}: {name} is not hidden in map-vein mode")
        want, got = set(filter(None, ores.split(","))), set(filter(None, res.split(",")))
        if recipe != "-" and (not want <= got if kept else want != got):
            problems.append(f"{mix}: {recipe} gives {', '.join(sorted(got))}, the vein holds {', '.join(sorted(want))}")
    return f"{len(rows)} placed veins, {sum(1 for r in rows if r[1] != '-')} with their classic recipe (mode {mode})", problems


def check_ore_mixes(m, sec):
    """Issue #496 (prototypes/165-fork-ore-veins.lua, plan #494): every ore of a GT vein in a dimension that is one of
    Gregtorio's surfaces (FORK_ORE_MIX_SURFACES) has a raw ore raw-<material> with GTNH's ore chain (the ore washer's
    purified-<material>), unless the material or the vein ("mix:<name>") is in FORK_ORE_MIX_SKIPPED or the material in
    FORK_ORE_MIX_NO_CHAIN (GT processes it another way; it needs the raw ore all the same), each with its reason; every
    dimension of GT's veins is a surface or skipped ("dimension:<DimNames>"). An entry that matches nothing fails too.
    Returns (info line, problems)."""
    rows = sec.get("OREMIXES", [])
    surfaces = {r[1] for r in rows if r[0] == "surface"}
    mixes = {r[1]: r[2].split(",") if len(r) > 2 and r[2] else [] for r in rows if r[0] == "mix"}
    ores = [r for r in rows if r[0] == "ore"]
    skip = {r[1]: (r[2] if len(r) > 2 else "") for r in rows if r[0] == "skip"}
    nochain = {r[1]: (r[2] if len(r) > 2 else "") for r in rows if r[0] == "nochain"}
    if not mixes:
        return "no ore mixes (an older version)", []
    on_surface = {n for n, dims in mixes.items() if set(dims) & surfaces}
    kept = on_surface - {n for n in on_surface if f"mix:{n}" in skip}
    problems, used, checked = [], set(), set()
    for n, dims in sorted(mixes.items()):
        problems += [f"{n}: dimension {d} is neither a Gregtorio surface (FORK_ORE_MIX_SURFACES) nor in "
                     f"FORK_ORE_MIX_SKIPPED as dimension:{d}" for d in dims if d not in surfaces and f"dimension:{d}" not in skip]
    for _, mix, role, x, raw in ores:
        if mix not in on_surface:
            continue
        used.add(x)
        if mix not in kept or x in skip or x in checked:
            continue
        checked.add(x)
        if raw == "-":
            problems.append(f"{x} ({mix} {role}): no raw ore raw-{x} (create it with GTNH's chain in 155, or add the "
                            "material to FORK_ORE_MIX_SKIPPED with its reason)")
        elif x not in nochain and (f"purified-{x}" not in m.R or m.R[f"purified-{x}"]["hidden"]):
            problems.append(f"{x} ({mix} {role}): raw-{x} has no ore chain (purified-{x}; 155's NEW_ORES, or "
                            "FORK_ORE_MIX_NO_CHAIN with the reason)")
    dims_used = {d for dims in mixes.values() for d in dims}
    for key, why in sorted(skip.items()):
        kind, _, name = key.partition(":") if ":" in key else ("material", "", key)
        if not why:
            problems.append(f"FORK_ORE_MIX_SKIPPED: {key} has no reason")
        if kind == "mix" and name not in on_surface:
            problems.append(f"FORK_ORE_MIX_SKIPPED: {key} is no vein on a Gregtorio surface (remove the entry)")
        elif kind == "dimension" and (name not in dims_used or name in surfaces):
            problems.append(f"FORK_ORE_MIX_SKIPPED: {key} is " + ("a surface" if name in surfaces else "no dimension of GT's veins")
                            + " (remove the entry)")
        elif kind == "material" and key not in used:
            problems.append(f"FORK_ORE_MIX_SKIPPED: {key} is no ore of a vein on a Gregtorio surface (remove the entry)")
    for x, why in sorted(nochain.items()):
        if not why:
            problems.append(f"FORK_ORE_MIX_NO_CHAIN: {x} has no reason")
        if x not in used or f"purified-{x}" in m.R:
            problems.append(f"FORK_ORE_MIX_NO_CHAIN: {x} is " + ("no ore of a vein on a surface" if x not in used
                            else "an ore with a chain") + " (remove the entry)")
    return (f"{len(mixes)} GT veins, {len(kept)} on Gregtorio's surfaces with {len(checked)} ores, "
            f"{len(on_surface) - len(kept)} veins and {sum(1 for k in skip if ':' not in k)} ores left out, "
            f"{len(nochain)} without an ore chain", problems)


ORE_CHAIN_SKIP = {"crushed-platinum", "crushed-palladium", "crushed-firestone"}   # 155-fork-ore-chain.lua's skip list
def check_ore_chain(m):
    """Issue #185 (prototypes/155-fork-ore-chain.lua): every ore with a purified form has GTNH's whole chain (washer,
    thermal centrifuge from crushed and purified ore, the three macerator steps, the centrifuge of impure and pure dust;
    issue #427: the cauldron of impure and pure dust), and no ore washer turns a crushed ore straight into something else
    (the shortcut of upstream; the platinum line's washing and firestone are skipped)."""
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
                         f"centrifuging-impure-{x}-dust", f"centrifuging-pure-{x}-dust",
                         f"cauldron-impure-{x}-dust", f"cauldron-pure-{x}-dust"):
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
# issue #363: the new ores of GTNH's Overworld veins (their first byproduct tagged for the bath)
ORE_BATHS["mercury"].update({"magnetite": "gold-dust", "chalcopyrite": "gold-dust"})
ORE_BATHS["sodium-persulfate"].update({"yellow-limonite": "nickel-dust", "malachite": "copper-dust",
                                       "chalcopyrite": "cobalt-dust", "garnierite": "nickel-dust"})
# issue #636: Mars's and Phobos's antimony (its byproduct zinc, GT's chemical bath in the GTNH recipe dump)
ORE_BATHS["sodium-persulfate"]["antimony"] = "zinc-dust"
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
                 "chromite": "iron", "bornite": "iron", "bastnasite": "neodymium", "monazite": "neodymium",
                 # issue #363: the new ores of GTNH's Overworld veins
                 "brown-limonite": "iron", "yellow-limonite": "iron", "banded-iron": "iron", "magnetite": "gold",
                 "pyrite": "iron", "glauconite": "iron", "vermiculite": "iron", "basaltic-mineral-sand": "gold",
                 "granitic-mineral-sand": "gold", "glauconite-sand": "iron", "yellow-garnet": "iron"}
# Issue #262: the other separator recipes of GTNH (gtnhlanth's monazite line, prototypes/159-fork-lanthanides.lua)
SEPARATOR_OTHER = {"monazite-rarer-earth-sediment"}
# issue #629: raw tengam dust into purified tengam dust (the GTNH recipe dump; prototypes/164-fork-chemistry.lua section 53)
SEPARATOR_OTHER.add("purified-tengam-dust")
# Issue #188: the gem ores of GTNH's sifter (table, crystallisable for the autoclave) and their gem items
ORE_GEMS = {"ruby": ("ruby", False), "emerald": ("emerald", False), "diamond": ("diamond", False),
            "nether-quartz": ("nether-quartz", True), "certus-quartz": ("certus-quartz", True),
            "apatite": ("apatite-gem", True), "tricalcium-phosphate": ("tricalcium-phosphate-gem", False),
            "lazurite": ("lazurite-gem", True), "sodalite": ("sodalite-gem", True), "lapis": ("lapis-lazuli", True),
            "monazite": ("monazite-gem", True),
            "amber": ("amber-gem", False), "topaz": ("topaz-gem", False),   # issue #332: the Twilight Forest's gems
            "sapphire": ("sapphire-gem", False), "green-sapphire": ("green-sapphire-gem", False),   # issue #364
            "lignite": ("lignite-gem", False),   # issue #363: GTNH's LigniteCoal vein
            # issue #363, part 2: the Twilight Forest's olivine vein and small ores
            "olivine": ("olivine-gem", False), "tanzanite": ("tanzanite-gem", False), "amethyst": ("amethyst-gem", False),
            "opal": ("opal-gem", False), "jasper": ("jasper-gem", False), "blue-topaz": ("blue-topaz-gem", False),
            "spinel": ("spinel-gem", False), "jade": ("jade-gem", True), "red-garnet": ("red-garnet-gem", False),
            "yellow-garnet": ("yellow-garnet-gem", False),
            # issue #373: bartworks' gem ores of Ross128b and Ross128ba
            "bismutite": ("bismutite-gem", False), "olenite": ("olenite-gem", False),
            "fluor-buergerite": ("fluor-buergerite-gem", False),
            "chromo-alumino-povondraite": ("chromo-alumino-povondraite-gem", False),
            "vanadio-oxy-dravite": ("vanadio-oxy-dravite-gem", False), "forsterite": ("forsterite-gem", False),
            "fayalite": ("fayalite-gem", False), "hedenbergite": ("hedenbergite-gem", False),
            "red-zircon": ("red-zircon-gem", False), "tiberium": ("tiberium-gem", False),
            "bartimaeusnek": ("bartimaeusnek-gem", False), "prasiolite": ("prasiolite-gem", False),
            "fluorspar": ("fluorspar-gem", False),
            "dilithium": ("dilithium-gem", True), "vinteum": ("vinteum-gem", False),   # issue #373: Neper
            "quartzite": ("quartzite-gem", True)}   # issue #496: the Nether's quartzite
# Issue #193: the laser engraver steps of the grades, with the lens of the gem's colour (red ruby, green emerald, white
# diamond; issues #328 and #370: cyan the green sapphire lens, blue the sapphire lens; certus quartz's light gray has no lens; issue
# #332: orange amber)
ORE_GEM_LENS = {"ruby": "ruby-lens", "emerald": "emerald-lens", "monazite": "emerald-lens", "diamond": "diamond-lens",
                "nether-quartz": "diamond-lens", "apatite": "green-sapphire-lens", "lazurite": "green-sapphire-lens",
                "sodalite": "sapphire-lens", "lapis": "sapphire-lens", "amber": "amber-lens", "topaz": "amber-lens",
                "sapphire": "sapphire-lens", "green-sapphire": "green-sapphire-lens",   # issue #370: blue and cyan
                # issue #363: lime, purple and pink their own lenses, the other colours the mod's lens of the colour
                "olivine": "olivine-lens", "tanzanite": "tanzanite-lens", "amethyst": "amethyst-lens",
                "jasper": "ruby-lens", "spinel": "ruby-lens", "opal": "sapphire-lens", "blue-topaz": "sapphire-lens",
                "jade": "emerald-lens", "red-garnet": "ruby-lens", "yellow-garnet": "yellow-garnet-lens",
                # issue #373: bartworks' gems, the lens of their dye (none for light gray olenite, black
                # fluor-buergerite and fayalite)
                "bismutite": "yellow-garnet-lens", "prasiolite": "yellow-garnet-lens",
                "chromo-alumino-povondraite": "green-sapphire-lens", "vanadio-oxy-dravite": "green-sapphire-lens",
                "forsterite": "diamond-lens", "hedenbergite": "emerald-lens", "tiberium": "emerald-lens",
                "bartimaeusnek": "emerald-lens", "red-zircon": "ruby-lens", "fluorspar": "ruby-lens",
                "dilithium": "diamond-lens", "quartzite": "diamond-lens"}   # issue #496: white quartzite
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
            if x is None and name in SEPARATOR_OTHER:
                continue
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
                # issue #316: the lens stays in the engraver's lens slot (150), it is neither used up nor a result
                if live(e) and m.R[e]["cat"].endswith("-laser-engraver-recipes") and m.tools.get(e) == lens \
                        and lens not in m.R[e]["res"] and hi in m.R[e]["res"]:
                    engraves += 1
                else:
                    out.append(f"{x}: the laser engraver lacks {e} (3 x {lo}, the {lens} in its lens slot)")
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
# issue #633: the HTGR's tungsten fuel gives osmium dust in GTNH's centrifuge as it is (the GTNH dump)
PGM_DUST_SOURCES["osmium-dust"].add("burned-triso-fuel-tungsten-centrifuging")
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
# issue #670: the dusts of prototypes/gt-parts-data.lua whose item name has no -dust (Gregtorio's antimony dust is antimony)
RECYCLE_DUSTS = set(re.findall(r'dust = "([^"]+)"', (ROOT / "prototypes" / "gt-parts-data.lua").read_text(encoding="utf-8")))
# issue #686: the material dusts and ingots named after their bare material (calcium, carbon, gallium dust; purified
# tengam, the arc smelting material of attuned tengam)
RECYCLE_BARE = {"calcium", "carbon", "gallium", "lithium", "purified-tengam"}
def check_recycling(m, sec):
    """Issue #190 (prototypes/157-fork-recycling.lua): GTNH recycles an item into its materials, never into its parts. Every
    recipe recycling-<machine>-<item> takes the one item (and oxygen in the arc furnace, the mold in the alloy smelter,
    issue #686) and gives dusts, ingots, nuggets, a melt or the platinum line's powders; every entry of FORK_RECYCLING_BLACKLIST names an item and says why. Returns
    (info line, problems)."""
    out, kinds = [], {"macerator": 0, "arc-furnace": 0, "fluid-extractor": 0, "alloy-smelter": 0, "furnace": 0}
    for name, r in sorted(m.R.items()):
        if not name.startswith("recycling-"):
            continue
        kind = next((k for k in kinds if name.startswith(f"recycling-{k}-")), None)
        if kind is None:
            out.append(f"{name}: not a macerator, arc furnace, fluid extractor, alloy smelter or furnace recycling recipe")
            continue
        kinds[kind] += 1
        item = name[len(f"recycling-{kind}-"):]
        extra = [i for i in r["ing"] if i != item and not (kind == "arc-furnace" and i == "oxygen")
                 and not (kind == "alloy-smelter" and i == "mold")]
        if item not in r["ing"] or extra:
            out.append(f"{name}: takes {', '.join(r['ing'])}, not {item}" + (" and oxygen" if kind == "arc-furnace" else ""))
        for x, xk in zip(r["res"], r["resk"]):
            # (issue #686: GT gives a part's material back as nuggets too, a plastic's melt has no molten- in its name)
            ok = (x.endswith("-dust") or x.endswith("-ingot") or x.endswith("-nugget") or x.startswith("molten-")
                  or x in RECYCLE_PGM or x in RECYCLE_DUSTS or x in RECYCLE_BARE or xk == "fluid" or x == "mold")
            if not ok:
                out.append(f"{name}: gives {x}, not a material (GTNH recycles into materials, not parts)")
    for item, why, exists in sec.get("RECYCLEBLACK", []):
        if not why:
            out.append(f"FORK_RECYCLING_BLACKLIST[{item}]: no reason")
        if exists != "true":
            out.append(f"FORK_RECYCLING_BLACKLIST[{item}]: no such item")
    info = (f"{sum(kinds.values())} recipes: {kinds['macerator']} macerator, {kinds['arc-furnace']} arc furnace, "
            f"{kinds['fluid-extractor']} fluid extractor, {kinds['alloy-smelter']} alloy smelter, {kinds['furnace']} furnace; "
            f"blacklist {len(sec.get('RECYCLEBLACK', []))}")
    return info, out
# Issue #670: the categories of Factorio 2.1's recycler (Space Age's recycling, deleted in data-final-fixes.lua)
RECYCLER_CATEGORIES = {"recycling", "recycling-or-hand-crafting"}
def check_blocks(m, sec):
    """Issue #670 (prototypes/157-fork-recycling.lua): a material block (block-of-<material> or <material>-block that a
    recipe of one ingredient makes: 9 ingots, gems or dusts, or the melt of 9 ingots) that a reachable recipe makes and no
    reachable recipe takes (recycling counts) fails, unless it is in the allow-list FORK_BLOCKS_DEAD_END with its reason
    (section BLOCKDEADOK); an entry that is no such block fails too. A recipe of a category of the recycler that is left
    fails (data-final-fixes.lua deletes Space Age's recycling). Returns (info line, problems)."""
    allow = {r[0]: (r[1] if len(r) > 1 else "") for r in sec.get("BLOCKDEADOK", [])}
    material, reach, taken = set(), set(), set()
    for r, v in m.R.items():
        if v["hidden"]:
            continue
        for x in v["res"]:
            if (x.startswith("block-of-") or x.endswith("-block")) and \
                    len([i for i in v["ing"] if i != m.tools.get(r)]) == 1:
                material.add(x)
                if r in m.unlocked:
                    reach.add(x)
        if r in m.unlocked:
            taken.update(v["ing"])
    dead = sorted(b for b in material & reach if b not in taken)
    problems = [f"{b}: no recipe takes it (give it GT's recipes in 157, or add it to FORK_BLOCKS_DEAD_END with its "
                "reason)" for b in dead if b not in allow]
    problems += [f"FORK_BLOCKS_DEAD_END: {b} has no reason" for b, why in sorted(allow.items()) if not why]
    problems += [f"FORK_BLOCKS_DEAD_END: {b} is not a reachable material block that no recipe takes (remove the entry)"
                 for b in sorted(allow) if b not in dead]
    left = sorted(r for r, v in m.R.items() if v["cats"] & RECYCLER_CATEGORIES)
    problems += [f"{r}: a recipe of the recycler's categories ({', '.join(sorted(m.R[r]['cats']))}) is left (Gregtorio "
                 "has no recycler; data-final-fixes.lua deletes them)" for r in left]
    return f"{len(material)} material blocks, {len(reach)} reachable, {len(dead)} that no recipe takes, {len(allow)} of " \
           f"them on purpose (FORK_BLOCKS_DEAD_END); {len(left)} recycler recipes left", problems
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


# issue #625: the entity types of the machines, which must have a description
MACHINE_TYPES = ("assembling-machine", "furnace", "mining-drill", "generator", "burner-generator", "boiler", "reactor",
                 "lab", "rocket-silo", "fusion-reactor", "fusion-generator", "agricultural-tower")
NAME_CLASSES = ("item", "fluid", "recipe", "technology", "entity", "equipment", "tile", "item-group", "item-subgroup",
                "autoplace-control")


def locale_keys():
    """{"<section>.<key>": file} of every English locale file the game loads in a devcheck run: this mod's
    (locale/en/*.cfg), the base game's and Space Age's (factorio/data/*/locale/en) and the dependencies' (zips and the
    me-network checkout). A key of this mod wins, so a missing name points at this mod's files."""
    import zipfile
    keys = {}

    def read(text, where):
        section = None
        for line in text.splitlines():
            line = line.strip()
            if line.startswith("[") and line.endswith("]"):
                section = line[1:-1]
            elif "=" in line and section and not line.startswith((";", "#")):
                keys.setdefault(f"{section}.{line.split('=', 1)[0].strip()}", where)

    for f in sorted((ROOT / "locale/en").glob("*.cfg")):
        read(f.read_text(encoding="utf-8"), f"locale/en/{f.name}")
    for f in sorted((FACTORIO / "data").glob("*/locale/en/*.cfg")):
        read(f.read_text(encoding="utf-8"), f.parent.parent.parent.name)
    for z in sorted(MODS.glob("*.zip")):
        if z.name.startswith(MOD_NAMES):
            continue
        with zipfile.ZipFile(z) as zf:
            for n in zf.namelist():
                if re.search(r"^[^/]+/locale/en/[^/]+\.cfg$", n):
                    read(zf.read(n).decode("utf-8-sig"), z.name)
    if me_network_dir():
        for f in sorted(me_network_dir().glob("locale/en/*.cfg")):
            read(f.read_text(encoding="utf-8"), ME_NETWORK)
    return keys


def missing_keys(ls, keys):
    """the keys of a localised string that no locale file has; [] if the game shows a name. A string is literal text,
    {"", ...} joins its parameters, {"?", ...} shows the first one that resolves, {"<key>", ...} needs the key and its
    parameters (__1__ ...)."""
    if not isinstance(ls, list):
        return []
    if not ls:
        return ["(empty localised string)"]
    head, params = ls[0], ls[1:]
    if head == "?":
        alts = [missing_keys(p, keys) for p in params]
        return [] if any(not a for a in alts) else [k for a in alts for k in a]
    out = [] if head == "" or head in keys else [head]
    for p in params:
        out += missing_keys(p, keys)
    return out


def defining_files():
    """{quoted string: first file of this mod that has it}, to name where a prototype is defined"""
    out = {}
    for f in [ROOT / "data.lua", ROOT / "data-final-fixes.lua"] + sorted((ROOT / "prototypes").glob("*.lua")):
        for s in re.findall(r'"([A-Za-z0-9_.-]+)"', f.read_text(encoding="utf-8")):
            out.setdefault(s, f.relative_to(ROOT).as_posix())
    return out


def check_placeable(sec):
    """Issue #336: a player-built entity of this mod that gives items when mined must be placeable again by one of them
    (section PLACEABLE of checkmod/control.lua: the runtime prototypes, the mined items and items_to_place_this); the T1
    robots' items had no place_result, so no roboport took them. Returns (info line, problems)."""
    rows = [r + [""] * (4 - len(r)) for r in sec.get("PLACEABLE", [])]
    problems = []
    for etype, name, mined, placers in rows:
        mined_set, placer_set = set(filter(None, mined.split(","))), set(filter(None, placers.split(",")))
        if not mined_set & placer_set:
            problems.append(f"{etype} {name}: mined it gives {', '.join(sorted(mined_set))}, which "
                            + (f"does not place it (placed by {', '.join(sorted(placer_set))})" if placer_set
                               else "has no place_result for it (no item places it)"))
    return f"{len(rows)} player-built entities that give items when mined", sorted(problems)


def check_names(sec):
    """Issue #230: every prototype this mod creates that a player can see (item, fluid, recipe, technology, entity,
    equipment, tile, item group and subgroup, issue #529: autoplace control; section NAMES of checkmod/control.lua: the runtime prototypes, so the name
    is the one the engine resolves from the final data stage) must have a name: every key of its localised name must be
    in a locale file. The engine names a recipe after its product only when the recipe has the product's name;
    any other recipe shows `recipe-name.<recipe>`, with a main product or not (prototypes/fork-locale.lua gives
    Gregtorio's recipes their product's name as the fallback). Shown: not hidden (an item or fluid also when a recipe
    that is not hidden takes or makes it), a technology that is enabled, an entity placed by an item, minable or a
    resource, a group or subgroup with a shown prototype. Allow-list FORK_LOCALE_MISSING (section LOCALEOK, "class:name"
    -> reason). Returns (info lines, problems, missing default keys as "section\\tname" rows for tools/gen_locale.py)."""
    if "NAMES" not in sec:
        return [], ["no DEVCHECK-NAMES section in the log (checkmod/control.lua did not run)"], []
    keys, files = locale_keys(), defining_files()
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("LOCALEOK", [])}
    seen, counts, problems, gen, machines = set(), {}, [], [], {}
    for r in sec["NAMES"]:
        cls, typ, name, created, shown = r[0], r[1], r[2], r[3], r[5]
        ls = json.loads(r[7]).get("n")
        extra = r[8] if len(r) > 8 else ""
        if created not in MOD_NAMES:
            continue
        seen.add(f"{cls}:{name}")
        if not shown:
            continue
        c = counts.setdefault(cls, [0, 0])
        c[0] += 1
        if cls == "autoplace-control" and name.startswith("gt-vein-"):
            # issue #574: a vein's control lists its ores in its description (prototypes/165-fork-ore-veins.lua)
            desc = json.loads(extra).get("d") if extra.startswith("{") else None
            if not desc or missing_keys(desc, keys):
                problems.append(f"{cls} {name}: no description of its ores"
                                + (f" (unknown key {', '.join(missing_keys(desc, keys))})" if desc else ""))
        if cls == "entity" and typ in MACHINE_TYPES:
            # issue #625: a machine the player builds says what it does (prototypes/167-fork-tips.lua)
            desc = json.loads(extra).get("d") if extra.startswith("{") else None
            m = machines.setdefault(typ, [0, 0])
            m[0] += 1
            if not desc or missing_keys(desc, keys):
                m[1] += 1
                problems.append(f"{cls} {name} ({typ}, {files.get(name, 'built in a loop, no literal name')}): no "
                                f"description (unknown key {', '.join(missing_keys(desc, keys)) if desc else '-'})")
        miss = missing_keys(ls, keys)
        if not miss or f"{cls}:{name}" in allowed:
            continue
        c[1] += 1
        why = ""
        if cls == "recipe":
            main, n = extra.split(" ")
            why = (", no results" if main == "-" and n == "0" else
                   f", {n} results and no main product" if main == "-" else
                   f", its name differs from its main product {main}" if main.split(":", 1)[1] != name else "")
        where = files.get(name, "built in a loop, no literal name")
        problems.append(f"{cls} {name} ({typ}, {where}): unknown key {', '.join(miss)}{why}")
        for k in miss:
            s, _, n = k.partition(".")
            if n and s.endswith("-name"):
                gen.append(f"{s}\t{n}")
    for k, why in sorted(allowed.items()):
        cls, _, name = k.partition(":")
        row = next((r for r in sec["NAMES"] if r[0] == cls and r[2] == name), None)
        if k not in seen:
            problems.append(f"{k}: in FORK_LOCALE_MISSING but no prototype of this mod (remove the entry)")
        elif row and not missing_keys(json.loads(row[7]).get("n"), keys):
            problems.append(f"{k}: in FORK_LOCALE_MISSING but has a name (remove the entry)")
    info = [f"{cls}: {counts[cls][0]} shown, {counts[cls][1]} without a name" for cls in NAME_CLASSES if cls in counts]
    info.append(f"{len(allowed)} kept without a name (FORK_LOCALE_MISSING)")
    info.append("machines (issue #625): " + ", ".join(f"{t} {m[0]} shown, {m[1]} without a description"
                                                       for t, m in sorted(machines.items())))
    return info, sorted(problems), sorted(set(gen))


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
# issue #535: removed prototype keys of other mods (a dependency's leftover Gregtorio cannot change: Factorio ignores it),
# by the prototype's "<type>/<name>" -> the reason; reported as information, never a failure
REMOVED_KEYS_OTHER_MODS = {
    "pump/configurable-valve": "configurable-valves 2.0.2 (for Factorio 2.1) still sets hide_connection_info on its fluid box",
    "storage-tank/configurable-valve-guage-input": "configurable-valves 2.0.2, as above",
    "storage-tank/configurable-valve-guage-output": "configurable-valves 2.0.2, as above",
}

# Issue #640: empty since data-final-fixes.lua disables every vanilla technology behind a disabled one (the 19 armor,
# equipment, explosives, fusion reactor and spidertron technologies that stood in the tree for good before)
UNRESEARCHABLE_OK = []
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


STEAM_RATES_EXPECTED = {"small-coal-boiler": 1.2, "large-bronze-boiler": 160, "steam-alloy-smelter": 3.2,
                        "simple-solar-boiler": 1.2}
# issue #593: what these boilers burn per second at the boiler output setting's default (GTNH); both rise by the factor
STEAM_WATTS_EXPECTED = {"small-coal-boiler": 36e3, "large-bronze-boiler": 4.8e6}
BOILER_OUTPUT = "gregtorio-continued-boiler-output"
BOILERS_SET = 4   # the factor of `all`'s extra load (issue #593)


def boiler_factor(sec):
    """the boiler output setting the mod was loaded with (section BOILEROUTPUT, issue #593; 1 in older versions)"""
    for r in sec.get("BOILEROUTPUT", []):
        if r[0] == "factor" and len(r) > 1:
            return float(r[1])
    return 1.0


def check_steam_rates(sec):
    """Issue #564 (prototypes/fork-steam-rates.lua): the descriptions say steam per second; the computed rates of the Small
    Coal Boiler (1.2), the Large Bronze Boiler (160), the Simple Solar Boiler (1.2 by day) and the Steam Alloy Smelter
    (3.2) must be GTNH's, and every rate is positive; the line is in the description of the entity and of every item that
    places it (the first version reached only the item of the same name). Issue #593: the boilers' rates and what the
    coal and bronze boiler burn per second times the boiler output setting, the smelter's unchanged. Returns (info line,
    problems)."""
    rows = {r[0]: r for r in sec.get("STEAMRATES", []) if len(r) >= 4}
    factor = boiler_factor(sec)
    problems = []
    for name, want in STEAM_RATES_EXPECTED.items():
        got = float(rows[name][3]) if name in rows else None
        want = want * factor if name in rows and rows[name][1] != "uses" else want
        # (1e-5: a solar boiler's steam is on the grid of 2^-24, issue #117)
        if got is None or abs(got - want) > want * 1e-5:
            problems.append(f"{name}: {got} steam/s, not {want}")
    for name, want in STEAM_WATTS_EXPECTED.items():
        got = float(rows[name][7]) if name in rows and len(rows[name]) > 7 and rows[name][7] else None
        if got is None or abs(got - want * factor) > want * factor * 1e-6:
            problems.append(f"{name}: burns {got} W, not {want * factor} (the boiler output setting is {factor})")
    problems += [f"{n}: rate {r[3]}" for n, r in sorted(rows.items()) if not float(r[3]) > 0]
    for n, r in sorted(rows.items()):
        if len(r) > 5 and r[5] not in ("entity", "game"):   # (game: a boiler, whose output the game shows)
            problems.append(f"{n}: the entity's description lacks the steam line")
        if len(r) > 6 and r[6]:
            problems.append(f"{n}: the description of its item {r[6]} lacks the steam line")
    kinds = {}
    for r in rows.values():
        kinds[r[1]] = kinds.get(r[1], 0) + 1
    return (f"{len(rows)} entities with steam per second (" + ", ".join(f"{k} {v}" for k, v in sorted(kinds.items()))
            + ")", problems)


def check_boiler_output(sec):
    """Issue #593 (prototypes/fork-boiler-output.lua): every entity that makes steam by itself (a STEAMRATES row of kind
    boiler or solar) is multiplied by the boiler output setting or left out with a reason. Returns (info line, problems)."""
    rows = sec.get("BOILEROUTPUT", [])
    changed = sorted(r[0] for r in rows if len(r) > 2 and r[1] == "changed")
    left = {r[0]: r[2] for r in rows if len(r) > 2 and r[1] == "left"}
    problems = [f"{r[0]}: makes steam ({r[1]}) but is neither multiplied nor left out with a reason"
                for r in sec.get("STEAMRATES", []) if len(r) > 1 and r[1] != "uses" and r[0] not in changed
                and r[0] not in left]
    info = (f"factor {boiler_factor(sec):g}, {len(changed)} multiplied ({', '.join(changed)}), {len(left)} left out ("
            + "; ".join(f"{n}: {why}" for n, why in sorted(left.items())) + ")")
    return info, problems


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


#: the science packs in Gregtorio's tier order (103's PACKS, then the endgame packs of 127 to 141)
SCIENCE_ORDER = ["automation", "logistic", "military", "chemical", "production", "utility", "space", "metallurgic",
                 "agricultural", "electromagnetic", "cryogenic", "promethium", "umv", "uxv", "max"]


def check_unlock_gaps(m, sec):
    """Issue #237: a Gregtorio recipe that a technology unlocks must be makeable with the technologies of that science:
    every ingredient obtainable and a machine for its category buildable with the recipes of every researchable
    technology whose highest science pack is not above the technology's effective science: the highest of its own
    and its prerequisites' (issue #239: a technology that needs an IV prerequisite is researched with IV science at hand).
    Gregtorio's tree is not closed under prerequisites: siblings of the same science are researched anyway, so ancestors
    alone would flag thousands. A
    recipe whose products are all obtainable anyway is an alternative that waits for its input (water / distilled water)
    and passes. For a failing recipe the check names the causes (the first missing link: an item whose recipes all come
    with higher science, or a category without a buildable machine; recycling never counts as a source), one row per
    technology and cause; allow-list FORK_UNLOCK_GAPS ("<technology>:<cause>" -> reason, section UNLOCKGAPOK; an entry
    that matches no cause fails). Returns (info line, problems)."""
    rank = {p + "-science-pack": i for i, p in enumerate(SCIENCE_ORDER)}
    T, R = m.T, m.R

    def tier(t):
        return max((rank.get(p, len(SCIENCE_ORDER)) for p in T[t]["sci"]), default=-1)
    mod = MOD_NAMES[1]
    greg = {r[0] for r in sec.get("OWNERS", [])
            if len(r) > 1 and (r[1] == mod or mod in (r[2] if len(r) > 2 else "").split(","))}
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("UNLOCKGAPOK", [])}
    unl, makers = {}, {}
    for t, v in T.items():
        for r in v["eff"]:
            unl.setdefault(r, []).append(t)
    for r, v in R.items():
        if not v["hidden"] and "recycling" not in r:
            for x in v["res"]:
                makers.setdefault(x, []).append(r)
    eff_memo, solved, techs_at = {}, {}, {}

    def effective(t):
        """the highest science of t and its prerequisites"""
        if t not in eff_memo:
            eff_memo[t] = max([tier(t)] + [effective(p) for p in T[t]["pre"] if p in T])
        return eff_memo[t]

    def key_of(t):
        k = effective(t)
        if k not in solved:
            techs_at[k] = {x for x in m.researched if tier(x) <= k}
            solved[k] = m.obtainable(techs_at[k])
        return k

    def causes(x, k, seen):
        if x in seen:
            return set()
        seen.add(x)
        avail, cats = solved[k]
        cands = [p for p in makers.get(x, []) if p in m.unlocked]
        here = [p for p in cands if R[p]["en"] or any(t in techs_at[k] for t in unl.get(p, []))]
        if not here:
            later = sorted({t for p in cands for t in unl.get(p, []) if t in m.researched}, key=tier)
            return {(x, f"comes with {later[0] if later else 'no researchable technology'}")}
        out = set()
        for p in here:
            if not R[p]["cats"] & cats:
                out.add((x, f"no machine for {R[p]['cat']}"))
                continue
            for i in R[p]["ing"]:
                if i not in avail:
                    out |= causes(i, k, seen)
        return out
    found, n_recipes = {}, 0
    for t in sorted(m.researched):
        k = key_of(t)
        avail, cats = solved[k]
        for r in T[t]["eff"]:
            v = R.get(r)
            if not v or v["hidden"] or r not in greg or r not in m.unlocked or "recycling" in r or r.startswith("void-") \
                    or v["cat"] in ("recycling", "parameters"):
                continue
            miss = [i for i in v["ing"] if i not in avail and i in m.avail]
            if not (miss or not v["cats"] & cats) or all(x in avail for x in v["res"]):
                continue
            n_recipes += 1
            got = set()
            for i in miss:
                got |= causes(i, k, set())
            if not v["cats"] & cats:
                got.add((r, f"no machine for {v['cat']}"))
            if not got:
                got.add((r, "its inputs only come from each other at this science"))
            for x, why in got:
                found.setdefault(f"{t}:{x}", (why, r))
    sci = lambda t: SCIENCE_ORDER[effective(t)] if 0 <= effective(t) < len(SCIENCE_ORDER) else "-"
    problems = [f"{k} ({sci(k.split(':')[0])} science): {why}, needed by {r}"
                for k, (why, r) in sorted(found.items()) if k not in allowed]
    problems += [f"{k}: in FORK_UNLOCK_GAPS but no such gap (remove the entry)" for k in sorted(allowed) if k not in found]
    info = (f"{n_recipes} recipes not makeable with the science of the technology that unlocks them, {len(found)} causes, "
            f"{sum(1 for k in found if k in allowed)} kept on purpose (FORK_UNLOCK_GAPS)")
    return info, problems


def check_unlock_tree(m, sec):
    """Issue #252, the maintainer's rule: every item and fluid is unlocked at the technology where it can first be
    consumed, never later. For every Gregtorio recipe a technology T unlocks (same selection as check_unlock_gaps) and
    every ingredient X that can be obtained at all, a recipe that makes X (recycling never counts) must be enabled from
    the start or unlocked by T or a technology in T's prerequisite closure, or X is a raw resource (mining, offshore,
    the burnt result of a fuel that is there); the recipe's category needs a machine whose item is made that way (the
    character for hand recipes). A recipe whose products all come from other recipes of that closure is an alternative
    and passes (as in #237), unless those recipes need an item the recipe misses (issues #502, #517). One row per technology and missing item (for a machine: its item with the nearest
    producer), naming the nearest producer and its technology; allow-list FORK_UNLOCK_TREE_GAPS
    ("<technology>:<item>" -> reason, section UNLOCKTREEOK; an entry that matches nothing fails). Returns (info line,
    problems, findings as {key: (recipes, nearest)})."""
    rank = {p + "-science-pack": i for i, p in enumerate(SCIENCE_ORDER)}
    T, R = m.T, m.R
    mod = MOD_NAMES[1]
    greg = {r[0] for r in sec.get("OWNERS", [])
            if len(r) > 1 and (r[1] == mod or mod in (r[2] if len(r) > 2 else "").split(","))}
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("UNLOCKTREEOK", [])}
    unl, makers, item_of, machines = {}, {}, {}, {}
    for t, v in T.items():
        for r in v["eff"]:
            unl.setdefault(r, []).append(t)
    for r, v in R.items():
        if not v["hidden"] and "recycling" not in r and r in m.unlocked:
            for x in set(v["res"]):
                makers.setdefault(x, []).append(r)
    for it, pr in m.I.items():
        if pr in m.C:
            item_of.setdefault(pr, []).append(it)
    for e, cats in m.C.items():
        for c in cats:
            machines.setdefault(c, []).append(e)
    start = {r for r, v in R.items() if v["en"] and not v["hidden"] and "recycling" not in r}
    memo, eff_memo = {}, {}

    def closure(t):
        """(the technologies, the recipes they unlock)"""
        if t not in memo:
            s, rs = {t}, set(T[t]["eff"])
            for p in T[t]["pre"]:
                if p in T:
                    ps, prs = closure(p)
                    s |= ps
                    rs |= prs
            memo[t] = (frozenset(s), frozenset(rs))
        return memo[t]

    def effective(t):
        if t not in eff_memo:
            eff_memo[t] = max([max((rank.get(p, len(SCIENCE_ORDER)) for p in T[t]["sci"]), default=-1)]
                              + [effective(p) for p in T[t]["pre"] if p in T])
        return eff_memo[t]

    def made(rs):
        """what the recipes rs and those of the start make, raw resources and the burnt results of what is there"""
        out = set(m.base)
        for r in rs | start:
            v = R.get(r)
            if v and not v["hidden"] and "recycling" not in r:
                out.update(v["res"])
        for fuel, burnt, _ in m.burnt:
            if fuel in out:
                out.add(burnt)
        return out

    # issue #502: a recipe that needs a missing ore whose nearest producer is a planet's map vein (planet-mining) makes
    # no alternative: the galena recipes of Galena made each other's products from the same missing ore; issue #517:
    # the same for every item the recipe misses
    def other_maker(x, r, rs, lacks=frozenset()):
        return x in m.base or any(p != r and (p in rs or p in start) and not lacks.intersection(R[p]["ing"])
                                  for p in makers.get(x, []))

    def machine_items(cat):
        return [it for e in machines.get(cat, []) for it in item_of.get(e, [])]

    def has_machine(cat, have):
        return "character" in machines.get(cat, []) or any(it in have for it in machine_items(cat))

    def nearest(xs):
        """the producer whose technology has the lowest science: (science rank, item, recipe, technology)"""
        best = [(effective(u), x, p, u) for x in xs for p in makers.get(x, []) for u in unl.get(p, [])
                if u in m.researched]
        return min(best) if best else None
    found, n_recipes = {}, 0
    for t in sorted(m.researched):
        rs = closure(t)[1]
        have = made(rs)
        for r in T[t]["eff"]:
            v = R.get(r)
            if not v or v["hidden"] or r not in greg or r not in m.unlocked or "recycling" in r or r.startswith("void-") \
                    or v["cat"] in ("recycling", "parameters"):
                continue
            miss = [(x, nearest([x])) for x in sorted(set(v["ing"])) if x in m.avail and x not in have]
            if not any(has_machine(c, have) for c in v["cats"]):
                near = nearest(machine_items(v["cat"]))
                miss.append((near[1] if near else "<machine for " + v["cat"] + ">", near))
            lacks = {x for x, _ in miss}
            if not miss or all(other_maker(x, r, rs, lacks) for x in v["res"]):
                continue
            n_recipes += 1
            for x, near in miss:
                found.setdefault(f"{t}:{x}", ([], near))[0].append(r)
    sci = lambda k: SCIENCE_ORDER[k] if 0 <= k < len(SCIENCE_ORDER) else "-"
    problems = []
    for k, (rs, near) in sorted(found.items()):
        if k in allowed:
            continue
        t = k.split(":")[0]
        where = f"nearest producer {near[2]} with {near[3]} ({sci(near[0])} science)" if near else "no producer"
        problems.append(f"{k} ({sci(effective(t))} science): not made in its prerequisites; {where}; needed by "
                        f"{', '.join(sorted(rs)[:4])}{' and %d more' % (len(rs) - 4) if len(rs) > 4 else ''}")
    problems += [f"{k}: in FORK_UNLOCK_TREE_GAPS but no such gap (remove the entry)" for k in sorted(allowed)
                 if k not in found]
    info = (f"{n_recipes} recipes need something their technology's prerequisites do not make, {len(found)} items, "
            f"{sum(1 for k in found if k in allowed)} kept on purpose (FORK_UNLOCK_TREE_GAPS)")
    return info, problems, found


def check_machines_early(m, sec):
    """Issue #556, the other half of #252's rule: a machine comes with the technology where it is first used, so a
    technology that unlocks a machine (a Gregtorio recipe of an item that places a crafting machine) must have a recipe
    the machine can run (one of its categories, not hidden, not recycling) enabled from the start or unlocked by itself
    or a technology in its prerequisite closure; else the machine stands there without a recipe. One row per technology
    and machine, naming the first technologies of a recipe it runs; allow-list FORK_MACHINES_BEFORE_RECIPES
    ("<technology>:<machine>" -> reason, section MACHINEEARLYOK; an entry that matches nothing fails). Returns (info
    line, problems)."""
    T, R = m.T, m.R
    mod = MOD_NAMES[1]
    greg = {r[0] for r in sec.get("OWNERS", [])
            if len(r) > 1 and (r[1] == mod or mod in (r[2] if len(r) > 2 else "").split(","))}
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("MACHINEEARLYOK", [])}
    unl, memo = {}, {}
    for t, v in T.items():
        for r in v["eff"]:
            unl.setdefault(r, []).append(t)

    def closure(t):
        if t not in memo:
            memo[t] = frozenset({t}).union(*[closure(p) for p in T[t]["pre"] if p in T])
        return memo[t]

    def runs(r, v):
        return not v["hidden"] and "recycling" not in r and v["cat"] not in ("recycling", "parameters")
    by_cat = {}
    for r, v in R.items():
        if runs(r, v) and r in m.unlocked:
            for c in v["cats"]:
                by_cat.setdefault(c, []).append(r)
    entity_of = {it: pr for it, pr in m.I.items() if pr in m.C and pr != "character"}
    found, n = {}, 0
    for r, v in R.items():
        if r not in greg or v["hidden"] or r not in m.unlocked or "recycling" in r:
            continue
        for e in sorted({entity_of[x] for x in v["res"] if x in entity_of}):
            recipes = sorted({x for c in m.C[e] for x in by_cat.get(c, [])})
            if any(R[x]["en"] for x in recipes):
                continue
            techs = {t for x in recipes for t in unl.get(x, []) if t in m.researched}
            first = sorted(u for u in techs if not any(w != u and w in closure(u) for w in techs))
            if v["en"]:
                n += 1
                found.setdefault(f"start:{e}", (r, first))
            for t in unl.get(r, []):
                if t not in m.researched:
                    continue
                n += 1
                if not techs & closure(t):
                    found.setdefault(f"{t}:{e}", (r, first))
    problems = [f"{k}: {r} unlocks it before any recipe it can run (first: {', '.join(first[:4]) or 'none'})"
                for k, (r, first) in sorted(found.items()) if k not in allowed]
    problems += [f"{k}: in FORK_MACHINES_BEFORE_RECIPES but no such machine (remove the entry)" for k in sorted(allowed)
                 if k not in found]
    info = (f"{n} unlocks of a machine checked, {len(found)} before any recipe the machine runs, "
            f"{sum(1 for k in found if k in allowed)} kept on purpose (FORK_MACHINES_BEFORE_RECIPES)")
    return info, problems


def check_furnace_inputs(m, sec):
    """Issue #560: a furnace picks the first enabled recipe of its categories (by subgroup and order) that matches its
    input, so two recipes a furnace machine runs with the same inputs (the same item and fluid names; amounts do not
    count) leave all but one unreachable. Counted are the recipes enabled from the start or unlocked by a technology,
    hidden or not. A group fails unless it is in the allow-list FORK_FURNACE_SAME_INPUTS of
    prototypes/101-fork-machines.lua ("<recipe>+<recipe>", sorted, -> the recipe that wins and why; section
    FURNACESAMEOK; an entry that matches no group, or names a winner outside it, fails too). A recipe in a furnace's
    category that a furnace cannot run (two item or two fluid ingredients) fails as well. Returns (info line,
    problems)."""
    R = m.R
    allowed = {r[0]: (r[1] if len(r) > 1 else "", r[2] if len(r) > 2 else "") for r in sec.get("FURNACESAMEOK", [])}
    furnaces = sorted(e for e, t in m.ctype.items() if t == "furnace")
    by_cat = {}
    for r, v in R.items():
        if v["en"] or r in m.unlocked:
            for c in v["cats"]:
                by_cat.setdefault(c, []).append(r)
    groups, unrunnable, n = {}, {}, set()
    for e in furnaces:
        sig = {}
        for r in sorted({x for c in m.C[e] for x in by_cat.get(c, [])}):
            v = R[r]
            kinds = v.get("ingk", [])
            items = tuple(sorted(i for i, k in zip(v["ing"], kinds) if k == "item"))
            fluids = tuple(sorted(i for i, k in zip(v["ing"], kinds) if k == "fluid"))
            n.add(r)
            if len(items) > 1 or len(fluids) > 1:
                unrunnable.setdefault(r, []).append(e)
                continue
            sig.setdefault((items, fluids), []).append(r)
        for (items, fluids), rs in sig.items():
            if len(rs) > 1:
                groups.setdefault("+".join(sorted(rs)), (items + fluids, []))[1].append(e)
    problems = []
    for key, (inputs, es) in sorted(groups.items()):
        if key not in allowed:
            problems.append(f"{key}: the same inputs ({', '.join(inputs) or 'none'}) in {len(es)} furnace machine(s) "
                            f"({', '.join(es[:3])}{', ...' if len(es) > 3 else ''}); only the first by subgroup and order runs")
        elif allowed[key][0] not in key.split("+"):
            problems.append(f"{key}: FORK_FURNACE_SAME_INPUTS names {allowed[key][0]} as the winner, which is not in the group")
    problems += [f"{r}: two item or two fluid ingredients, the furnace machine(s) {', '.join(es[:3])} cannot run it"
                 for r, es in sorted(unrunnable.items())]
    problems += [f"{k}: in FORK_FURNACE_SAME_INPUTS but no such group (remove the entry)" for k in sorted(allowed)
                 if k not in groups]
    info = (f"{len(furnaces)} furnace machines, {len(n)} recipes they run, {len(groups)} groups with the same inputs, "
            f"{sum(1 for k in groups if k in allowed)} kept on purpose (FORK_FURNACE_SAME_INPUTS)")
    return info, problems


STEAM_ORE_HOME = "steam-macerator"
STEAM_ORE_INPUTS = r"(raw|crushed|purified|centrifuged)-"   # the ore forms (FORK_STEAM_ORE.inputs of 101)
# issue #571: the steam macerator doubles these ores in the steam age (Raw Tin's copy is named after its LV recipe
# macerating-raw-tin), and so does its crushed ore -> impure dust
STEAM_ORE_TEST = ["steam-crushed-copper", "steam-crushed-iron", "steam-macerating-raw-tin",
                  "steam-impure-copper-dust", "steam-impure-iron-dust", "steam-impure-tin-dust"]


def check_steam_ores(m, sec):
    """Issue #571: the steam macerator's copies of the ore recipes (prototypes/101-fork-machines.lua) come with the steam
    age. The recipes of STEAM_ORE_TEST must be unlocked by a technology of red science only (its own and its
    prerequisites' packs), and each product must have a furnace recipe (category smelting, the product alone) enabled from
    the start or unlocked by that technology or one of its prerequisites. Rule: a copy of an ore form (category
    steam-macerator-recipes, input STEAM_ORE_INPUTS) whose technologies all have a higher effective science than Steam
    Macerator, while its input
    can be obtained at Steam Macerator's science (as #237) and a recipe of that science takes each of its products (#252's
    rule the other way round: the impure dust of an ore without a furnace recipe waits for the LV cauldron, washer and
    centrifuge, and so does its copy), fails unless it is in the allow-list FORK_STEAM_LATE with its
    reason (section STEAMLATEOK; an entry that matches nothing fails too). Returns (info line, problems)."""
    rank = {p + "-science-pack": i for i, p in enumerate(SCIENCE_ORDER)}
    T, R = m.T, m.R
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("STEAMLATEOK", [])}
    unl, memo, eff_memo = {}, {}, {}
    for t, v in T.items():
        for r in v["eff"]:
            unl.setdefault(r, []).append(t)

    def closure(t):
        if t not in memo:
            memo[t] = frozenset({t}).union(*[closure(p) for p in T[t]["pre"] if p in T])
        return memo[t]

    def tier(t):
        return max((rank.get(p, len(SCIENCE_ORDER)) for p in T[t]["sci"]), default=-1)

    def effective(t):
        if t not in eff_memo:
            eff_memo[t] = max([tier(t)] + [effective(p) for p in T[t]["pre"] if p in T])
        return eff_memo[t]
    if STEAM_ORE_HOME not in T:
        return "no technology " + STEAM_ORE_HOME, [f"{STEAM_ORE_HOME}: no such technology"]
    smelting = {}
    for r, v in R.items():
        if v["cat"] == "smelting" and not v["hidden"] and len(v["ing"]) == 1:
            smelting.setdefault(v["ing"][0], []).append(r)
    problems = []
    red = rank["automation-science-pack"]
    for r in STEAM_ORE_TEST:
        techs = [t for t in unl.get(r, []) if t in m.researched]
        if r not in R or not techs:
            problems.append(f"{r}: no such recipe or no researchable technology unlocks it")
            continue
        ok = [t for t in techs if effective(t) == red]
        if not ok:
            problems.append(f"{r}: unlocked by {', '.join(sorted(techs))}, not by a technology of red science only")
            continue
        for x in R[r]["res"]:
            if not any(R[s]["en"] or any(u in closure(ok[0]) for u in unl.get(s, [])) for s in smelting.get(x, [])):
                problems.append(f"{r}: {x} has no furnace recipe at {ok[0]} or before "
                                f"(furnace recipes: {', '.join(sorted(smelting.get(x, []))) or 'none'})")
    home = effective(STEAM_ORE_HOME)
    avail, _ = m.obtainable({t for t in m.researched if tier(t) <= home})
    takers = {}
    for r, v in R.items():
        if not v["hidden"] and "recycling" not in r:
            for i in set(v["ing"]):
                takers.setdefault(i, []).append(r)

    def taken(x):
        """something takes x at Steam Macerator's science"""
        return any(R[c]["en"] or any(t in m.researched and effective(t) <= home for t in unl.get(c, []))
                   for c in takers.get(x, []))
    found, n = {}, 0
    for r, v in sorted(R.items()):
        if v["cat"] != "steam-macerator-recipes" or v["hidden"] or r not in m.unlocked \
                or not re.match(STEAM_ORE_INPUTS, v["ing"][0] if v["ing"] else ""):
            continue
        n += 1
        techs = [t for t in unl.get(r, []) if t in m.researched]
        if techs and min(effective(t) for t in techs) > home and all(i in avail for i in v["ing"]) \
                and all(taken(x) for x in v["res"]):
            found[r] = sorted(techs)
    problems += [f"{r}: unlocked by {', '.join(ts)} ({SCIENCE_ORDER[min(effective(t) for t in ts)]} science), but "
                 f"{', '.join(R[r]['ing'])} is there at {STEAM_ORE_HOME}'s science" for r, ts in found.items()
                 if r not in allowed]
    problems += [f"{r}: in FORK_STEAM_LATE but no such copy (remove the entry)" for r in sorted(allowed) if r not in found]
    info = (f"{len(STEAM_ORE_TEST)} test recipes, {n} steam macerator recipes of ore forms, {len(found)} later than their input, "
            f"{sum(1 for r in found if r in allowed)} kept on purpose (FORK_STEAM_LATE)")
    return info, problems


NUGGET_ORE_FORMS = r"(crushed|purified|centrifuged)-"   # the ore forms whose furnace recipe gives nuggets (FORK_NUGGET_ORES)


def check_nugget_ingots(m, sec):
    """Issue #586: the furnace smelts an ore form (crushed, purified, centrifuged ore) into nuggets, so each technology
    that unlocks such a furnace recipe (category smelting, the ore form alone; enabled from the start counts as "start")
    must have a recipe that turns the nugget into an ingot (it takes the nugget and gives an ingot, not hidden) enabled
    from the start or unlocked by itself or a technology in its prerequisite closure. A row "<technology>:<nugget>" fails
    unless it is in the allow-list FORK_NUGGETS_BEFORE_INGOTS of prototypes/101-fork-machines.lua with its reason
    (section NUGGETINGOTOK; an entry that matches nothing fails too). The other half (nugget_ingot_unlocks of 101): a
    nugget -> ingot recipe whose technologies all have a prerequisite that already has the nugget and the recipe's mold
    (its producer's technology) comes later than it must and fails. Returns (info line, problems)."""
    T, R = m.T, m.R
    allowed = {r[0]: r[1] if len(r) > 1 else "" for r in sec.get("NUGGETINGOTOK", [])}
    unl, memo = {}, {}
    for t, v in T.items():
        for r in v["eff"]:
            unl.setdefault(r, []).append(t)

    def closure(t):
        if t not in memo:
            memo[t] = frozenset({t}).union(*[closure(p) for p in T[t]["pre"] if p in T])
        return memo[t]

    def techs(r):
        return {t for t in unl.get(r, []) if t in m.researched}
    furnace, producers = {}, {}
    for r, v in R.items():
        if v["hidden"] or "recycling" in r:
            continue
        for x in v["res"]:
            producers.setdefault(x, []).append(r)
        if v["cat"] == "smelting" and len(v["ing"]) == 1 and re.match(NUGGET_ORE_FORMS, v["ing"][0]):
            for x in v["res"]:
                if x.endswith("-nugget"):
                    furnace.setdefault(x, []).append(r)
    ingots = {}
    for r, v in R.items():
        if not v["hidden"] and "recycling" not in r and any(x.endswith("-ingot") for x in v["res"]):
            for i in set(v["ing"]):
                if i in furnace:
                    ingots.setdefault(i, []).append(r)
    found, late, n = {}, [], 0
    for nug in sorted(furnace):
        made = {t for s in furnace[nug] for t in techs(s)}
        start = any(R[s]["en"] for s in furnace[nug])
        rs = ingots.get(nug, [])
        ing_t = {t for r in rs for t in techs(r)}
        first = sorted(u for u in ing_t if not any(w != u and w in closure(u) for w in ing_t))
        for f in sorted(made) + (["start"] if start else []):
            n += 1
            if any(R[r]["en"] for r in rs) or (f != "start" and ing_t & closure(f)):
                continue
            found[f"{f}:{nug}"] = ", ".join(sorted(s for s in furnace[nug] if R[s]["en"] or f in techs(s))) + \
                f"; nugget -> ingot: {', '.join(sorted(rs)) or 'none'} ({', '.join(first) or 'no technology'})"
        for r in rs:
            mold = m.tools.get(r)
            mold_t = {t for p in producers.get(mold, []) for t in techs(p)} if mold else set()
            mold_en = not mold or any(R[p]["en"] for p in producers.get(mold, []))
            us = techs(r)
            if R[r]["en"] or not us:
                continue

            def ready(p):
                return (start or made & closure(p)) and (mold_en or mold_t & closure(p))
            early = {u: sorted(p for p in closure(u) if p != u and ready(p)) for u in us}
            if all(early[u] for u in us):
                u = sorted(us)[0]
                ps = [p for p in early[u] if not any(q != p and q in closure(p) for q in early[u])]
                late.append(f"{r}: comes with {', '.join(sorted(us))}, but {', '.join(ps[:3])} already has {nug}"
                            + (f" and the mold {mold}" if mold else "") + " (nugget_ingot_unlocks of 101)")
    problems = [f"{k}: {why}" for k, why in sorted(found.items()) if k not in allowed]
    problems += late
    problems += [f"{k}: in FORK_NUGGETS_BEFORE_INGOTS but no such technology and nugget (remove the entry)"
                 for k in sorted(allowed) if k not in found]
    info = (f"{len(furnace)} nuggets of ore forms' furnace recipes, {n} technologies that make one, {len(found)} before "
            f"a nugget -> ingot recipe, {sum(1 for k in found if k in allowed)} kept on purpose (FORK_NUGGETS_BEFORE_INGOTS), "
            f"{len(late)} nugget -> ingot recipes later than the nugget and the mold")
    return info, problems


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
    """--set NAME=VALUE: true or false for a bool startup setting, a number for a double or int setting (issue #593), any
    other value for a string setting (issue #563)."""
    out = {}
    for p in pairs or []:
        name, _, value = p.partition("=")
        if not value:
            sys.exit(f"--set {p}: expected <startup setting>=<value>")
        if value in ("true", "false"):
            out[name] = value == "true"
        elif re.fullmatch(r"-?\d+(\.\d+)?", value):
            out[name] = float(value) if "." in value else int(value)
        else:
            out[name] = value
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
    stale_unlocks = [f"{t} names {r}" for t, r in re.findall(r"FORK-STALE-UNLOCK: (\S+) (\S+)", log)]
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
    gaps_info, gaps = check_unlock_gaps(m, sec)
    print(f"\nrecipes unlocked before what they need (issue #237): {gaps_info}")
    report("recipes a technology unlocks before its science can make them (the cause, the recipe that needs it; fix the "
           "unlock or a prerequisite, or add the cause to FORK_UNLOCK_GAPS of prototypes/142-fork-recipe-unlocks.lua)", gaps)
    tree_info, tree, _ = check_unlock_tree(m, sec)
    print(f"\nitems unlocked after their first use (issue #252): {tree_info}")
    report("items a technology's recipes take that its prerequisites do not make (the technology, the item, the nearest "
           "producer; unlock the producer there or earlier, make the producer's technology a prerequisite, or add "
           "<technology>:<item> to FORK_UNLOCK_TREE_GAPS of prototypes/142-fork-recipe-unlocks.lua)", tree, limit=400)
    early_info, early = check_machines_early(m, sec)
    print(f"\nmachines unlocked before their first recipe (issue #556): {early_info}")
    report("technologies that unlock a machine before any recipe it can run (the technology, the machine, the first "
           "technologies of a recipe it runs; unlock the machine there, or add <technology>:<machine> to "
           "FORK_MACHINES_BEFORE_RECIPES of prototypes/142-fork-recipe-unlocks.lua)", early, limit=200)
    furnace_info, furnace = check_furnace_inputs(m, sec)
    print(f"\nfurnace machines (issue #560): {furnace_info}")
    report("recipes of a furnace machine with the same inputs, or that a furnace cannot run (a furnace runs the first "
           "matching recipe by subgroup and order; remove or move one, or add the group with its winner to "
           "FORK_FURNACE_SAME_INPUTS of prototypes/101-fork-machines.lua)", furnace, limit=200)
    steam_info, steam = check_steam_ores(m, sec)
    print(f"\nsteam macerator ore recipes (issue #571): {steam_info}")
    report("steam macerator copies later than the steam age that has their input, or test recipes off the steam age "
           "(fix the unlock in steam_ore_unlocks of prototypes/101-fork-machines.lua, or add the copy to "
           "FORK_STEAM_LATE there with its reason)", steam, limit=200)
    nugget_info, nugget = check_nugget_ingots(m, sec)
    print(f"\nnuggets of ore forms back into ingots (issue #586): {nugget_info}")
    report("technologies whose ore form furnace recipes give a nugget that no nugget -> ingot recipe of theirs or of their "
           "prerequisites takes, or nugget -> ingot recipes later than the nugget and the mold (fix the unlock in "
           "nugget_ingot_unlocks of prototypes/101-fork-machines.lua, or add <technology>:<nugget> to "
           "FORK_NUGGETS_BEFORE_INGOTS there with its reason)", nugget, limit=200)
    report("draft recipes outside DRAFTS_OK (issue #39)", new_drafts)
    report("technologies that unlock a recipe the ore chain removes (issue #388: delete the unlock from "
           "prototypes/98-technology.lua or the table of 142; FORK-STALE-UNLOCK in the log)", stale_unlocks)
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
    trigger_info, trigger_only = check_trigger_items(m, sec)
    print(f"\nitems of craft triggers (issue #547): {trigger_info}")
    report("items whose only use is a technology's craft trigger (prototypes/100-fork-fixes.lua)", trigger_only)
    oc_info, overclock = check_overclocking(sec)
    print(f"\nGT overclocking (issue #616): {oc_info}")
    report("machines whose power does not follow the GT overclocking setting (prototypes/fork-gt-overclocking.lua)", overclock)
    spoil_info, spoiling = check_spoiling(m, sec)
    print(f"\nspoiling items (issue #602): {spoil_info}")
    report("items that spoil and that a reachable recipe makes (data-final-fixes.lua)", spoiling)
    research_info, research_counts = check_research_counts(m, sec)
    print(f"\nresearch counts from UV up (issue #605): {research_info}")
    report("technologies whose count lies outside the band of their pack count (prototypes/138-fork-research-balance.lua)",
           research_counts)
    nyi_info, nyi_icons = check_nyi_icons(sec)
    print(f"\nNYI placeholder icons (issue #639): {nyi_info}")
    report("shown prototypes with the NYI placeholder icon (prototypes/199-fork-finalize.lua)", nyi_icons)
    lens_info, lenses = check_engraver_lenses(m, sec)
    print(f"\nlaser engraver lenses (issue #325): {lens_info}")
    report("laser engraver recipes without a lens (prototypes/155-fork-ore-chain.lua)", lenses)
    mine_info, mine_twins = check_electric_mine(m, sec)
    print(f"\nelectric mine (issue #335): {mine_info}")
    report("Manual Mine recipes without an electric twin of the Ore Drilling Plants (prototypes/163-fork-electric-mine.lua)",
           mine_twins)
    place_info, unplaceable = check_placeable(sec)
    print(f"\nplaceable entities (issue #336): {place_info}")
    report("entities whose mined item does not place them again (place_result missing or wrong)", unplaceable)
    vanilla_info, vanilla = check_vanilla_recipes(m, sec)
    print(f"\nvanilla recipes of Gregtorio's items (issues #317, #318): {vanilla_info}")
    report("vanilla recipes without a technology whose products Gregtorio makes another way (delete them in "
           "VANILLA_RECIPES_REMOVED of data-final-fixes.lua, or keep one in FORK_VANILLA_RECIPES_KEPT with its reason)",
           vanilla)
    me_info, me_recipes = check_me_recipes(sec)
    print(f"\nME recipes (issue #214): {me_info}")
    report("me-network recipes without a Gregtorio recipe (prototypes/120-fork-me-network-compat.lua)", me_recipes)
    tab_info, me_tab = check_me_tab(sec)
    print(f"\nME tab (issue #519): {tab_info}")
    report("ME items outside the tab ME Network, or ME recipes outside their item's row", me_tab)
    parts_info, parts_unranked = check_material_parts(sec)
    print(f"\nmaterial parts (issue #118): {parts_info}")
    report("WARNING: materials of the material parts without a tier (prototypes/200-fork-material-parts.lua)", parts_unranked)
    mixes_info, ore_mixes = check_ore_mixes(m, sec)
    print(f"\nGT's ore veins (issue #496): {mixes_info}")
    report("ores of GT's veins on Gregtorio's surfaces without a raw ore and its chain (prototypes/165-fork-ore-veins.lua)",
           ore_mixes)
    rates_info, steam_rates = check_steam_rates(sec)
    print(f"\nsteam per second in the descriptions (issue #564): {rates_info}")
    report("steam per second that differs from GTNH's (prototypes/fork-steam-rates.lua)", steam_rates)
    boilers_info, boiler_output = check_boiler_output(sec)
    print(f"\nboiler output (issue #593): {boilers_info}")
    report("steam makers neither multiplied nor left out (prototypes/fork-boiler-output.lua)", boiler_output)
    classic_info, classic_veins = check_classic_veins(m, sec)
    print(f"\nclassic vein recipes (issue #563): {classic_info}")
    report("placed veins without their classic vein recipe and twins, or with other ores (prototypes/166-fork-classic-veins.lua)",
           classic_veins)
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
    blocks_info, blocks = check_blocks(m, sec)
    print(f"\nmaterial blocks and Space Age's recycling (issue #670): {blocks_info}")
    report("material blocks that no recipe takes, and recipes of the recycler (prototypes/157-fork-recycling.lua, "
           "data-final-fixes.lua)", blocks)
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
    # issue #535: a key Factorio removed (2.0 -> 2.1) that a prototype still carries; 2.1 ignores most of them on load
    rows = [r for r in sec.get("REMOVEDKEYS", []) if len(r) > 1]
    other = [r for r in rows if re.split(r"[.\[]", r[0])[0] in REMOVED_KEYS_OTHER_MODS]
    removed_keys = [f"{r[0]}: {r[1]}" for r in rows if r not in other]
    report("prototype keys that Factorio removed, of other mods (information: REMOVED_KEYS_OTHER_MODS)",
           [f"{r[0]}: {r[1]} ({REMOVED_KEYS_OTHER_MODS[re.split(r'[.[]', r[0])[0]]})" for r in other])
    print(f"\nprototype keys removed by Factorio {FACTORIO_VERSION} (checkmod/removed-keys.lua): {len(removed_keys)}")
    report("prototype keys that Factorio removed (ignored when loaded: they fail silently; tools/devcheck/removed_keys.py)",
           removed_keys)
    names_info, names, names_gen = check_names(sec)
    print("\nnames of the shown prototypes of this mod (issue #230):")
    for line in names_info:
        print("  " + line)
    report("prototypes without a name (\"Unknown key\" in the game; add the locale entry, a main product or the "
           "allow-list FORK_LOCALE_MISSING of prototypes/fork-locale.lua) and machines without a description (issue #625: "
           "an entity-description or a kind of [fork-machine] in prototypes/167-fork-tips.lua)", names, limit=60)
    table_info, vein_doc = check_vein_table(sec, getattr(a, "vein_table", False))
    print(f"\nvein table of docs/ORE-VEINS.md (issue #574): {table_info}")
    report("the vein table of docs/ORE-VEINS.md", vein_doc)
    renames_info, renames = check_item_renames(m, getattr(a, "item_renames", False))
    print(f"\nitem renames for the ME network (issue #580, prototypes/data/item-renames.lua): {renames_info}")
    report("the item renames of prototypes/data/item-renames.lua", renames)
    gtnh_info, gtnh_numbers = check_gtnh_numbers(sec, getattr(a, "gtnh_numbers", False))
    print(f"\nGT New Horizons' numbers (issue #689, prototypes/data/gtnh-numbers.lua): {gtnh_info}")
    report("recipes with other numbers than GT New Horizons' (prototypes/168-fork-gtnh-numbers.lua)", gtnh_numbers)
    parts_rec_info, parts_recycling = check_gtnh_recycling(sec, getattr(a, "gtnh_recycling", False))
    print(f"\nGT's recycling of the material parts (issue #686, prototypes/data/gtnh-recycling.lua): {parts_rec_info}")
    report("GT's part recycling (prototypes/157-fork-recycling.lua)", parts_recycling)
    routes_info, part_routes = check_gtnh_routes(sec, getattr(a, "gtnh_routes", False))
    print("\nGT's part routes of the cutting machine, bender, extruder, wiremill, forge hammer, solidifier and lathe "
          f"(issue #687, prototypes/data/gtnh-part-routes.lua): {routes_info}")
    report("GT's part routes (prototypes/158-fork-gt-parts.lua)", part_routes)
    craft_info, part_crafting = check_gtnh_crafting(sec, getattr(a, "gtnh_crafting", False))
    print("\nGT's crafting table recipes of the parts (issue #688, prototypes/data/gtnh-part-crafting.lua): " + craft_info)
    report("GT's crafting table recipes of the parts (prototypes/158-fork-gt-parts.lua)", part_crafting)
    chem_info, chemistry = check_gtnh_chemistry(sec, getattr(a, "gtnh_chemistry", False))
    print(chr(10) + "GT's chemistry and separation recipes (issue #691, prototypes/data/gtnh-chemistry.lua): " + chem_info)
    report("GT's chemistry and separation recipes (prototypes/158-fork-gt-parts.lua)", chemistry)
    if getattr(a, "fluids_out", None):
        Path(a.fluids_out).write_text("\n".join("\t".join(r) for r in sec.get("FLUIDS", [])) + "\n", encoding="utf-8")
        print(f"\nfluid list written to {a.fluids_out} (input for tools/gen_review_sheet.py fluids)")
    if a.locale_out:
        Path(a.locale_out).write_text("".join(r + "\n" for r in names_gen), encoding="utf-8")
        print(f"\nmissing names written to {a.locale_out} ({len(names_gen)} keys, input for tools/gen_locale.py)")
    if getattr(a, "balance_out", None):
        rows = ["\t".join(r) for r in sec.get("BALANCE", [])]
        Path(a.balance_out).write_text("[\n" + ",\n".join(rows) + "\n]\n", encoding="utf-8")
        print(f"\nbalance data written to {a.balance_out} (recipes, machines, technologies as JSON)")
    ok = not (files or [s for s in sprites if not s.startswith("(")] or uncraft or menu or required or unresearchable
              or new_drafts or fluid_problems or locked or one_pack or fluid_steps or table_only or me_recipes or me_tab
              or extractor_split or ore_mixes or ore_chain or ore_baths or ore_o34 or ore_hammer
              or circuit_icons or pgm_dusts or recycling or blocks or names or gaps or tree or vanilla or lenses or mine_twins
              or unplaceable or stale_unlocks or removed_keys or trigger_only or spoiling or classic_veins or early
              or furnace or research_counts or nyi_icons or overclock
              or steam or nugget or steam_rates or boiler_output or vein_doc or renames or gtnh_numbers or parts_recycling or part_routes or part_crafting or chemistry)
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


def classic(a):
    """Part of `all` (issue #563): check and runtime once more with the classic ore mode (gregtorio-continued-ore-mode =
    vein-recipes), as the one-pack research setting is loaded a second time."""
    c = argparse.Namespace(**vars(a))
    c.set, c.balance_out, c.fluids_out, c.locale_out, c.techs = [f"{ORE_MODE}=vein-recipes"], None, None, None, None
    print(f"\n=== classic ore mode ({ORE_MODE}=vein-recipes): check ===")
    if check(c):
        return 1
    print(f"\n=== classic ore mode ({ORE_MODE}=vein-recipes): runtime ===")
    if runtime(c):
        return 1
    print("\n=== switching the ore mode of a save ===")
    return switch(a)


def boilers(a):
    """Part of `all` (issue #593): check and runtime once more with the boiler output setting at BOILERS_SET (the rates of
    the check and the coal and solar boiler tests of the runtime follow the setting)."""
    c = argparse.Namespace(**vars(a))
    c.set, c.balance_out, c.fluids_out, c.locale_out, c.techs = [f"{BOILER_OUTPUT}={BOILERS_SET}"], None, None, None, None
    print(f"\n=== boiler output ({BOILER_OUTPUT}={BOILERS_SET}): check ===")
    if check(c):
        return 1
    print(f"\n=== boiler output ({BOILER_OUTPUT}={BOILERS_SET}): runtime ===")
    return runtime(c)


def overclocking(a):
    """Part of `all` (issue #616): check and runtime once more with GT overclocking on (every machine from MV up draws 4x
    power per tier)."""
    c = argparse.Namespace(**vars(a))
    c.set, c.balance_out, c.fluids_out, c.locale_out, c.techs = [f"{OVERCLOCK}=true"], None, None, None, None
    print(f"\n=== GT overclocking ({OVERCLOCK}=true): check ===")
    if check(c):
        return 1
    print(f"\n=== GT overclocking ({OVERCLOCK}=true): runtime ===")
    return runtime(c)


def switch(a):
    """Issue #563: a map made in one ore mode, loaded in the other, both ways (switchmod/control.lua: the scene and its
    checks; scripts/fork-ore-veins.lua migrates the save in on_configuration_changed)."""
    failed = False
    for frm, to in (("map-veins", "vein-recipes"), ("vein-recipes", "map-veins")):
        prepare_mods(with_switch=True, settings={ORE_MODE: frm})
        log = factorio("--create", str(WORK / "switch-map.zip"), *seed_args(a))
        setup = re.search(r"DEVCHECK-SWITCH-SETUP (.*)", log)
        if load_errors(log) or not setup or not setup.group(1).startswith("ok"):
            print(f"{frm} -> {to}: the map was not made: {load_errors(log) or (setup.group(1) if setup else 'no set-up')}")
            failed = True
            continue
        prepare_mods(with_switch=True, settings={ORE_MODE: to})
        log = factorio("--benchmark", str(WORK / "switch-map.zip"), "--benchmark-ticks", "400")
        res = re.search(r"DEVCHECK-SWITCH (.*)", log)
        print(f"{frm} -> {to}: {res.group(1) if res else 'no result ' + (load_errors(log) or script_error(log) or '')}")
        for f in re.findall(r"DEVCHECK-SWITCH-FAIL (.*)", log):
            print("  - " + f)
        failed |= not (res and res.group(1).startswith("ok"))
    print("\nRESULT: " + ("PROBLEMS FOUND" if failed else "OK"))
    return 1 if failed else 0


def seed_args(a):
    if a.seed == "random":
        return []
    return ["--map-gen-seed", str(int(a.seed))]


def runtime(a):
    prepare_mods(with_runtime=True, settings=parse_settings(getattr(a, "set", None)))
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
    tests = (("MOLD", "mold test"), ("LENS", "lens test"), ("MOLDCLONE", "cloned mold machine test"), ("POWER", "power test"), ("FUEL", "fuel check test"), ("COOLED", "cooled fluid test"),
             ("TIERS", "turbine tier test"), ("RECIPES", "recipe test"), ("CRUSH", "raw ore crushing test"), ("OREFURNACE", "ore furnace line test"), ("STEAM", "steam turbine test"), ("CHAIN", "nuclear chain test"), ("LFTR", "LFTR test"), ("DYSON", "Dyson Swarm test"), ("LSC", "supercapacitor test"), ("LSUP", "supercapacitor upgrade test"), ("ELEVATOR", "space elevator test"), ("MELT", "melt and cast test"), ("OFFER", "offered recipes test"), ("EMINE", "electric mine test"), ("SOLAR", "solar boiler test"), ("COALBOILER", "coal boiler test"),("TORCH", "torch test"), ("BATTERY", "battery buffer test"), ("VEINS", "map vein test"), ("CLASSIC", "classic vein test"), ("DRILLS", "mining drill test"), ("PORTAL", "portal test"), ("ENDER", "ender storage test"), ("VICTORY", "victory test"),
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
    the save is copied over `mapfile`. Returns the server log and None, or the log and a reason."""
    step = WORK / "migrate-step.zip"                   # the server saves the map back into this file when it quits
    shutil.copy2(mapfile, step)
    log, reason, _ = server_session(step, log_path, "devcheck migrate: the intermediate load")
    if not reason and re.search(r"DEVCHECK-MIGRATE-(?!SETUP)[A-Z]+ ", log):
        reason = "a tick ran in the intermediate load (the helper mod's checks ran there)"
    ticks = re.findall(r"updateTick\((\d+)\) changing state from\(InGame\)", log)
    if not reason:
        shutil.copy2(step, mapfile)
        print(f"  saved when the server quit (tick {ticks[-1] if ticks else '?'}, no tick run)")
    return log, reason


def server_session(step, log_path, description, commands=()):
    """Loads the save `step` in a headless server with nobody connected and `auto_pause`, sends `commands` through RCON
    (each Lua command runs one tick), quits through RCON: the server saves the map back into `step` when it quits.
    Returns the server log, None or a reason, and the RCON answers of the commands. The ports are free ones (another
    devcheck may run a server at the same time)."""
    import socket, time

    def free_port(kind):
        with socket.socket(socket.AF_INET, kind) as s:
            s.bind(("127.0.0.1", 0))
            return s.getsockname()[1]
    rcon_port, game_port = free_port(socket.SOCK_STREAM), free_port(socket.SOCK_DGRAM)
    binary = FACTORIO / ("bin/x64/factorio.exe" if os.name == "nt" else "bin/x64/factorio")
    settings = WORK / "server-settings.json"
    settings.write_text(json.dumps({"name": "devcheck", "description": description,
                                    "visibility": {"public": False, "lan": False}, "auto_pause": True,
                                    "require_user_verification": False, "max_players": 1}), encoding="utf-8")
    reason, answers = None, []
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
                for i, command in enumerate(commands):
                    answers.append(rcon(sock, 2, command, 10 + i))
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
    return log, reason, answers


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
    # the skipped folders are left out before the walk enters them: `.devcheck` holds junctions (me-network's checkout
    # with its own `.devcheck/mods/me-network` junction to itself), which Path.rglob follows on Windows without end
    skip = (".git", ".devcheck", ".github", "tools", "docs")
    files = []
    for top in sorted(ROOT.iterdir()):
        if top.name in skip:
            continue
        if top.is_file():
            files.append(top)
            continue
        for dirpath, _, filenames in os.walk(top):
            files.extend(Path(dirpath) / f for f in filenames)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for p in sorted(files):
            rel = p.relative_to(ROOT).as_posix()
            z.writestr(prefix + rel, json.dumps(info, indent=2) if rel == "info.json" else p.read_bytes())
    print(f"working copy has the version of the old save ({old_version}): loaded as {info['version']}, as the release "
          f"will be (on_configuration_changed with mod changes)")
    return out


class old_factorio:
    """issue #535: `with old_factorio(a, old_zip):` runs Factorio from --old-factorio with a mods folder of its own
    (.devcheck/mods-old: the dependency zips of --old-mods) when the old version is for another Factorio (2.0), so its
    save is made as a player of that version made it; nothing changes for a version of this Factorio"""
    def __init__(self, a, old_zip):
        self.a, self.fv = a, zip_info(old_zip).get("factorio_version")

    def __enter__(self):
        global FACTORIO, MODS
        self.kept = (FACTORIO, MODS)
        if not self.fv or self.fv == engine_version():
            return self
        if not (self.a.old_factorio and self.a.old_mods):
            sys.exit(f"the old version is for Factorio {self.fv}, this one is {engine_version()}: pass --old-factorio DIR "
                     f"(an unpacked Factorio {self.fv}) and --old-mods DIR (its dependency zips), see tools/devcheck/README.md")
        FACTORIO, MODS = Path(self.a.old_factorio).resolve(), WORK / "mods-old"
        if engine_version() != self.fv:
            sys.exit(f"--old-factorio {self.a.old_factorio} is Factorio {engine_version()}, the old version needs {self.fv}")
        MODS.mkdir(exist_ok=True)
        for z in MODS.glob("*.zip"):
            z.unlink()
        for z in Path(self.a.old_mods).glob("*.zip"):
            if not z.name.startswith(MOD_NAMES + (ME_NETWORK + "_", TEXTURES)):
                shutil.copy2(z, MODS / z.name)
        print(f"old version for Factorio {self.fv}: {FACTORIO} with the mods of {self.a.old_mods}")
        return self

    def __exit__(self, *exc):
        global FACTORIO, MODS
        FACTORIO, MODS = self.kept


def migrate(a):
    """Create a map with an older version (also "Gregtorio" before 0.3.0), then load and run it with the working copy."""
    old = a.from_zip or zip_from_ref(a.from_ref)
    old_migs = zip_migrations(old)
    old_me = old_me_network(a.old_me_network) if getattr(a, "old_me_network", None) else None
    with old_factorio(a, old):
        with me_network_from(old_me):
            prepare_mods(gregtorio_zip=old, with_migrate=True, old_migrations=old_migs)
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
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-FURNACES (.*)", log)
    print(f"old save with every ore machine placed, loaded and mid-craft (issue #560): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-PLANETS (.*)", log)
    print(f"old save with surfaces of the Space Age planets (issue #529): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-VEINGRID (.*)", log)
    print(f"old save with the size of gt-ore-veins at 1.5 (issue #529): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-VEINORES (.*)", log)
    print(f"old save whose vein ores are deleted (issue #534): {setup.group(1) if setup else 'no result'}")
    setup = re.search(r"DEVCHECK-MIGRATE-SETUP-MAPGEN (.*)", log)
    print(f"old save with the map generation of its time (issue #540): {setup.group(1) if setup else 'no result'}")
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
            prepare_mods(gregtorio_zip=old, with_migrate=True, old_migrations=old_migs)
        step_log, why = load_and_save(WORK / "migrate-map.zip", WORK / "migrate-step.log")
        if why:
            print(f"intermediate load: FAILED, {why}: "
                  f"{script_error(step_log) or load_errors(step_log) or ''} (see .devcheck/migrate-step.log)")
            return 1
        print("intermediate load: ok")
    elif save_me is not None and version_tuple(save_me) < ME_CUT_OFF:
        print(f"--direct: the old save of me-network {save_me} is loaded with the working copies (me-network 0.5.1 and "
              f"later refuse it)")
    # (issue #563: --set forces a startup setting of the working copy's load, e.g. the classic ore mode)
    prepare_mods(with_migrate=True, gregtorio_zip=bumped_working_copy(old), old_migrations=old_migs,
                 settings=parse_settings(getattr(a, "set", None)))
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
    furnaces = re.search(r"DEVCHECK-MIGRATE-FURNACES (.*)", log)
    print(f"ore machines of the old save as furnaces (issue #560): {furnaces.group(1) if furnaces else 'no result'}")
    for line in re.findall(r"FORK-ORE-FURNACES: (.*)", log):
        print("  migration: " + line)
    planets = re.search(r"DEVCHECK-MIGRATE-PLANETS (.*)", log)
    print(f"surfaces of the deleted Space Age planets (issue #529): {planets.group(1) if planets else 'no result'}")
    veingrid = re.search(r"DEVCHECK-MIGRATE-VEINGRID (.*)", log)
    print(f"vein controls of the old save (issue #529): {veingrid.group(1) if veingrid else 'no result'}")
    veinores = re.search(r"DEVCHECK-MIGRATE-VEINORES (.*)", log)
    print(f"vein ores of the old save regenerated (issue #534): {veinores.group(1) if veinores else 'no result'}")
    mapgen = re.search(r"DEVCHECK-MIGRATE-MAPGEN (.*)", log)
    print(f"map generation of the old save (issue #540): {mapgen.group(1) if mapgen else 'no result'}")
    lenses = re.search(r"DEVCHECK-MIGRATE-MELENSES (.*)", log)
    print(f"lenses of the old save in its ME network renamed (issue #580): {lenses.group(1) if lenses else 'no result'}")
    for line in re.findall(r"FORK-ORE-VEINS: (.*other planets.*)", log):
        print("  migration: " + line)
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
        and removed and not removed.group(1).startswith("failed")         and furnaces and not furnaces.group(1).startswith("failed")         and planets and not planets.group(1).startswith("failed")         and veingrid and not veingrid.group(1).startswith("failed")         and veinores and not veinores.group(1).startswith("failed") \
        and mapgen and not mapgen.group(1).startswith("failed")         and lenses and not lenses.group(1).startswith("failed")
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
                                                 "factorio_version": engine_version(), "dependencies": ["base"] + deps}))
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


MENUSIM_TOOLS = ROOT / "tools" / "menusim"     # issue #588: resave.lua and a <name>.json per Gregtorio scene
REPLAY_FILES = ("level-init.dat", "script-init.dat")


def own_scene(save):
    """issue #588: a scene of Gregtorio's own (its save is in this mod)"""
    return bool(re.match(r"__(%s)__/" % "|".join(MOD_NAMES), save or ""))


def run_menusim(name, save, length, gregtorio):
    """Load the simulation's save with --benchmark for its length; the helper mod runs its init and update chunks.
    Issue #588: a scene of Gregtorio's own also has its save's entities checked against tools/menusim/<name>.json and
    the machines in the camera's view watched (menusimmod/control.lua)."""
    path = save_path(save)
    own = own_scene(save)
    if not path or not path.exists():
        return (f"ERROR no save file: {save}" if own else f"skipped (no save file: {save or 'none'})"), []
    config = {"name": name, "ticks": length}
    if own:
        scene = MENUSIM_TOOLS / f"{name}.json"
        if not scene.exists():
            return f"ERROR {scene.relative_to(ROOT).as_posix()} is missing: run `menusim --sim {name} --rebuild`", []
        config["expect"] = json.loads(scene.read_text(encoding="utf-8"))["entities"]
    prepare_mods(menusim=config, gregtorio=gregtorio)
    log = factorio("--benchmark", str(path), "--benchmark-ticks", str(length))
    lines = re.findall(r"DEVCHECK-MENUSIM (.*)", log)
    ran = re.search(r"Performed (\d+) updates", log)
    err = re.search(r"(Error while running.*|non-recoverable.*|Error.*)(\n.*){0,3}", log)
    if any(l.startswith("FAIL") for l in lines):
        fails = [l for l in lines if l.startswith("FAIL")]
        return fails[0] + (f" (and {len(fails) - 1} more FAIL lines)" if len(fails) > 1 else ""), lines
    if err and not ran:
        # (issue #597: an error in a scene's chunk is named with its cause, e.g. "update:2: LuaSimulation doesn't ...")
        return "ERROR " + (script_error(log) or " ".join(x.strip() for x in err.group(0).splitlines())), lines
    if not any(l == "init done" for l in lines):
        return "ERROR init did not run", lines
    if own and not any(l.startswith("view ") for l in lines):
        return "ERROR the machines in view were not checked to the end", lines
    deaths = sum(1 for l in lines if l.startswith("DIED"))
    facts = "".join(f"; {l}" for l in lines if l.startswith(("entities:", "view ")))
    return f"ok ({ran.group(1)} ticks{f', {deaths} characters died' if deaths else ''}{facts})", lines


def menusim(a):
    """Run main menu simulations with the mod (and with --compare also without it) and report errors.
    `--sim own` (part of `all`): Gregtorio's own scenes only. `--rebuild`: issue #588, menusim_rebuild.
    Issue #595: with Gregtorio the menu has only Gregtorio's scenes; any other one left fails."""
    if getattr(a, "rebuild", False):
        return menusim_rebuild(a)
    variants = [True, False] if a.compare else [True]
    failed = False
    for gregtorio in variants:
        label = "with Gregtorio" if gregtorio else "without Gregtorio"
        sims = menusim_list(gregtorio)
        if a.sim == "all":
            names = sorted(sims)
        elif a.sim == "own":
            names = sorted(n for n, (save, _) in sims.items() if own_scene(save))
        else:
            names = [a.sim]
        print(f"== {label}: {len(sims)} menu simulations{'' if a.sim in ('all', 'own') else ', running ' + a.sim}")
        others = sorted(n for n, (save, _) in sims.items() if not own_scene(save))
        if gregtorio and others:
            print(f"FAIL not Gregtorio's own, still in the menu (issue #595): {', '.join(others)}")
            failed = True
        for name in names:
            if name not in sims:
                print(f"{name}: not in main_menu_simulations")
                failed |= gregtorio
                continue
            save, length = sims[name]
            result, lines = run_menusim(name, save, a.ticks or length, gregtorio)
            print(f"{name}: {result}")
            if a.sim not in ("all", "own") or a.verbose:
                for l in lines:
                    print("    " + l)
            failed |= result.startswith(("ERROR", "FAIL"))
    print("\nRESULT: " + ("PROBLEMS FOUND" if failed else "OK"))
    return 1 if failed else 0


def menusim_own(a):
    """Part of `all` (issue #588): Gregtorio's own menu scenes"""
    print("\n=== Gregtorio's main menu scenes ===")
    return menusim(argparse.Namespace(sim="own", compare=False, ticks=None, verbose=False, rebuild=False))


def player_entities(answer, what):
    try:
        return json.loads(answer)
    except ValueError:
        sys.exit(f"{what}: no answer from the server's Lua command: {answer!r}")


def menusim_rebuild(a):
    """Issue #588: saves a Gregtorio scene's save again with today's mods and shrinks it, in the headless game.
    1. --made-with GREGTORIO_REF[:ME_NETWORK_REF]: loads the save with the versions it was made with and counts the
       player force's entities by name (the menusim helper's count mode).
    2. Loads it in a headless server with today's mods (no helper mod: the save keeps the players' mod list), runs
       tools/menusim/resave.lua over RCON (chunks cut to the factory, the blueprint library and the replay off) and
       saves it when the server quits; the replay's start state (REPLAY_FILES), which the engine keeps in every save, is
       left out of the zip.
    3. Fails when an entity name has fewer entities after the load or the resave than with the save's own versions;
       otherwise the save replaces the one in menu-simulations/ and tools/menusim/<name>.json gets today's counts (what
       `menusim` checks every load against) and the facts of the rebuild. The source is the save of the working copy
       or, with --save-from, the one of a git ref (the save as its builder made it)."""
    import zipfile
    sims = menusim_list(True)
    if a.sim not in sims or not own_scene(sims[a.sim][0]):
        sys.exit(f"--rebuild: {a.sim} is not a main menu simulation of Gregtorio's own")
    save, length = sims[a.sim]
    path = save_path(save)
    rel = path.relative_to(ROOT).as_posix()
    work = WORK / "menusim"
    work.mkdir(exist_ok=True)
    src = work / "source.zip"
    if a.save_from:
        src.write_bytes(subprocess.run(["git", "-C", str(ROOT), "show", f"{a.save_from}:{rel}"],
                                       capture_output=True, check=True).stdout)
    else:
        shutil.copy2(path, src)
    print(f"== {a.sim}: {rel} from {a.save_from or 'the working copy'}, {src.stat().st_size / 1e6:.2f} MB")
    baseline = None
    if a.made_with:
        g_ref, _, me_ref = a.made_with.partition(":")
        g_zip = zip_from_ref(g_ref)
        me_dir = old_me_network(me_ref, "the save's own versions:") if me_ref else None
        with me_network_from(me_dir):
            prepare_mods(gregtorio_zip=g_zip, menusim={"name": a.sim, "count_only": True})
            log = factorio("--benchmark", str(src), "--benchmark-ticks", "2")
        m = re.search(r"DEVCHECK-MENUSIM COUNTS (.*)", log)
        if not m:
            sys.exit("the load with the save's own versions failed:\n" + (load_errors(log) or script_error(log) or log[-2000:]))
        baseline = json.loads(m.group(1))
        print(f"loaded with Gregtorio {g_ref}{' and me-network ' + me_ref if me_ref else ''}: "
              f"{sum(baseline.values())} entities of the player force")
    prepare_mods(helper=False)
    step = work / path.name                      # the zip's folder takes the file's name
    shutil.copy2(src, step)
    count = ("/sc local by, n = {}, 0 for _, e in pairs(game.surfaces.nauvis.find_entities_filtered({ force = 'player' }))"
             " do if e.type ~= 'character' then by[e.name] = (by[e.name] or 0) + 1 end end"
             " for _ in game.surfaces.nauvis.get_chunks() do n = n + 1 end"
             " rcon.print(helpers.table_to_json({ entities = by, chunks = n, players = #game.players }))")
    lua = (MENUSIM_TOOLS / "resave.lua").read_text(encoding="utf-8")
    log, reason, answers = server_session(step, work / "server.log", f"devcheck menusim --rebuild {a.sim}", [
        "/sc rcon.print('ready')",            # (the first Lua command of a session may get the achievements warning)
        f"/sc local MARGIN = {a.margin}\n{lua}", count])
    if reason:
        sys.exit(f"the headless save failed: {reason}\n{load_errors(log) or log[-2000:]}")
    resave, resaved = player_entities(answers[1], "resave.lua"), player_entities(answers[2], "count")
    after = resaved["entities"]
    out = work / "rebuilt.zip"
    with zipfile.ZipFile(step) as zin, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
        for info in zin.infolist():
            if info.filename.rsplit("/", 1)[-1] not in REPLAY_FILES:
                zout.writestr(info, zin.read(info.filename))
    before = resave["entities"]
    names = sorted(set(before) | set(after) | set(baseline or {}))
    lost = [n for n in names if after.get(n, 0) < before.get(n, 0) or (baseline and before.get(n, 0) < baseline.get(n, 0))]
    print(f"{'entity':32} {'own versions':>12} {'today':>8} {'resaved':>8}")
    for n in names:
        print(f"{n:32} {baseline.get(n, '-') if baseline else '-':>12} {before.get(n, '-'):>8} {after.get(n, '-'):>8}"
              f"{'   LOST' if n in lost else ''}")
    print(f"chunks: {resave['chunks']} -> {resaved['chunks']} (margin {a.margin}); blueprint library records deleted: "
          f"{resave['blueprint_records']}; players removed: {resave['players']} ({resaved['players']} left); "
          f"replay files left out: {', '.join(REPLAY_FILES)}")
    print(f"size: {src.stat().st_size / 1e6:.2f} MB -> {out.stat().st_size / 1e6:.2f} MB")
    if resaved["players"]:
        lost.append(f"{resaved['players']} players")       # (issue #599: the menu draws a player's GUI over the scene)
    if lost:
        print("\nRESULT: PROBLEMS FOUND (entities lost or players left: " + ", ".join(lost) + "; the save was not replaced)")
        return 1
    shutil.copy2(out, path)
    scene = MENUSIM_TOOLS / f"{a.sim}.json"
    scene.write_text(json.dumps({
        "save": rel, "rebuilt_from": a.save_from or "working copy", "made_with": a.made_with, "margin": a.margin,
        "chunks": {"before": resave["chunks"], "kept": resaved["chunks"]}, "players_removed": resave["players"],
        "size": {"before": src.stat().st_size, "after": out.stat().st_size},
        "entities": dict(sorted(after.items()))}, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"wrote {rel} and {scene.relative_to(ROOT).as_posix()}\n")
    result, lines = run_menusim(a.sim, save, length, True)
    print(f"{a.sim}: {result}")
    for l in lines:
        print("    " + l)
    failed = result.startswith(("ERROR", "FAIL"))
    print("\nRESULT: " + ("PROBLEMS FOUND" if failed else "OK"))
    return 1 if failed else 0


def gtnh_diff(a):
    """Issue #679 (a report, not part of `all`): Gregtorio's recipes against the GT New Horizons recipe dump
    (tools/gtnh_dump/gtnh-recipes.json.gz; issue #714: gtnh-merged.json.gz, merged with the full-pack NEI dump, when it
    exists) through tools/gtnh_map.py; per GT recipe map the recipes Gregtorio has, has with other numbers or lacks,
    written to .devcheck/gtnh-diff.md and .json. Loads the mod like `check` unless `--log` names the log of an earlier
    `check` run."""
    sys.path.insert(0, str(ROOT / "tools"))
    import gtnh_map
    if a.log:
        log = Path(a.log).read_text(encoding="utf-8", errors="replace")
    else:
        prepare_mods()
        log = factorio("--create", str(WORK / "check-map.zip"))
        if load_errors(log):
            print("load: FAILED\n" + load_errors(log))
            return 1
    sec = sections(log)
    if "BALANCE" not in sec or "DUMP" not in sec:
        sys.exit("the log has no DUMP/BALANCE section (a `check` run's .devcheck/last-run.log is needed)")
    dump = gtnh_map.load_dump(a.dump or gtnh_map.DUMP)
    per_map, tot, groups = gtnh_map.run(dump, sec, a.out, a.json)
    print(gtnh_map.summary(tot, a.out))
    print("\nlargest gaps (map, material or form, missing recipes):")
    for (mname, grp), n in groups.most_common(10):
        print(f"  {mname}: {grp}: {n}")
    return 0


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
    c.add_argument("--vein-table", action="store_true",
                   help="issue #574: write the vein table of docs/ORE-VEINS.md from the mod's placed veins")
    c.add_argument("--item-renames", action="store_true",
                   help="issue #580: write prototypes/data/item-renames.lua from the item renames of the JSON migrations")
    c.add_argument("--gtnh-chemistry", action="store_true",
                   help="issue #691: write prototypes/data/gtnh-chemistry.lua, GT's chemistry recipes Gregtorio lacks")
    c.add_argument("--gtnh-crafting", action="store_true",
                   help="issue #688: write prototypes/data/gtnh-part-crafting.lua, GT's crafting table recipes of the parts")
    c.add_argument("--gtnh-routes", action="store_true",
                   help="issue #687: write prototypes/data/gtnh-part-routes.lua, GT New Horizons' part routes Gregtorio lacks")
    c.add_argument("--gtnh-recycling", action="store_true",
                   help="issue #686: write prototypes/data/gtnh-recycling.lua, GT New Horizons' recycling of the material parts")
    c.add_argument("--gtnh-numbers", action="store_true",
                   help="issue #689: write prototypes/data/gtnh-numbers.lua, GT New Horizons' numbers of the matched recipes")
    c.add_argument("--set", action="append", metavar="SETTING=VALUE",
                   help="force a startup setting for this run (bool, number or string), e.g. "
                   "gregtorio-continued-one-pack-research=true or gregtorio-continued-boiler-output=4")
    r = sub.add_parser("runtime")
    r.add_argument("--ticks", type=int, default=1500)
    r.add_argument("--seed", default=str(DEFAULT_SEED), help=f"map seed or `random` (default {DEFAULT_SEED})")
    r.add_argument("--set", action="append", metavar="SETTING=VALUE", help="force a startup setting, as for check")
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
    m.add_argument("--set", action="append", metavar="SETTING=VALUE",
                   help="issue #563: force a startup setting of the working copy's load, e.g. "
                   "gregtorio-continued-ore-mode=vein-recipes")
    m.add_argument("--old-factorio", metavar="DIR", help="issue #535: an unpacked Factorio of the old version's "
                   "factorio_version (bin/ and data/), which makes the old save when it is not this one's (a 2.0 version)")
    m.add_argument("--old-mods", metavar="DIR", help="issue #535: with --old-factorio, a folder with the old version's "
                   "dependency zips (configurable-valves, autocraft-logistics of Factorio 2.0)")
    ms = sub.add_parser("menusim", help="run main menu simulations")
    ms.add_argument("--sim", default="nauvis_biter_base_laser_defense",
                    help="simulation name, `all` or `own` (Gregtorio's own scenes, part of `all`)")
    ms.add_argument("--compare", action="store_true", help="also run without Gregtorio")
    ms.add_argument("--ticks", type=int, help="ticks to run (default: the simulation's length)")
    ms.add_argument("--verbose", action="store_true", help="print the log lines with --sim all too")
    ms.add_argument("--rebuild", action="store_true", help="issue #588: save a Gregtorio scene's save again with "
                    "today's mods in the headless game, cut to the chunks of its factory (tools/menusim/resave.lua), "
                    "and write tools/menusim/<sim>.json")
    ms.add_argument("--save-from", metavar="REF", help="with --rebuild: take the save of this git ref (e.g. the commit "
                    "that added it as its builder made it) instead of the working copy's")
    ms.add_argument("--made-with", metavar="GREGTORIO_REF[:ME_NETWORK_REF]", help="with --rebuild: also load the save "
                    "with the versions it was made with and fail when the load with today's mods loses an entity, "
                    "e.g. v0.5.8:v0.5.8")
    ms.add_argument("--margin", type=int, default=0, help="with --rebuild: chunks kept around the factory's chunks")
    sub.add_parser("handover", help="issue #83: prototype of the ME state hand-over to me-network")
    sw = sub.add_parser("switch", help="issue #563: a save switches its ore mode, both ways")
    sw.add_argument("--seed", default=str(DEFAULT_SEED), help=f"map seed or `random` (default {DEFAULT_SEED})")
    gd = sub.add_parser("gtnh-diff", help="issue #679: report of Gregtorio's recipes against GT New Horizons' recipe dump")
    gd.add_argument("--dump", help="default: tools/gtnh_dump/gtnh-merged.json.gz (issue #714) if it exists, else "
                                   "tools/gtnh_dump/gtnh-recipes.json.gz")
    gd.add_argument("--log", help="use the log of an earlier `check` run instead of loading the mod")
    gd.add_argument("--out", default=str(WORK / "gtnh-diff.md"))
    gd.add_argument("--json", default=str(WORK / "gtnh-diff.json"))
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
    if a.cmd == "switch":
        return switch(a)
    if a.cmd == "gtnh-diff":
        return gtnh_diff(a)
    return check(a) or one_pack(a) or runtime(a) or classic(a) or boilers(a) or overclocking(a) or menusim_own(a)


if __name__ == "__main__":
    sys.exit(main())
