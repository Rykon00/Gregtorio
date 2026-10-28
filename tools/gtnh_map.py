#!/usr/bin/env python3
"""Issue #679: maps the GT New Horizons recipe dump (tools/gtnh_dump/gtnh-recipes.json.gz, made by tools/gtnh_dump/)
onto Gregtorio's names, and compares Gregtorio's recipes with GT's. `devcheck.py gtnh-diff` runs it on a fresh load
of the mod; it can also run on its own on the log of a `devcheck.py check` run:

    python tools/devcheck/devcheck.py gtnh-diff
    python tools/gtnh_map.py --log .devcheck/last-run.log

Mapping:
  * items: an explicit table (`ITEMS`, GT registry name:meta -> Gregtorio item), then GT's unification (the prefix and
    material GTOreDictUnificator knows, else a prefix and material read from an ore dictionary name) through
    `PREFIX` (GT OrePrefixes -> Gregtorio's `<material>-<form>` patterns, as tools/gen_gt_parts.py names the parts),
    then the English name (Gregtorio's locale, the name written as an item name, GT's "<part> (<tier>)" as
    "<tier>-<part>"). GT's ore dictionary circuits (circuitBasic, ...) are Gregtorio's one circuit per tier (`ORES`).
    A GT material is a Gregtorio material when its name without case equals the Gregtorio name without hyphens
    (StainlessSteel = stainless-steel), else through `MATERIALS` (and the GT names of tools/gen_gt_parts.py and
    tools/gen_gt_icons.py). Cells are their fluid (1000 L each); empty cells, programmed circuits and GT's tools are
    dropped; inputs that are not consumed (molds, shapes, lenses, catalysts: count 0) are not compared.
  * fluids: `FLUIDS`, then `molten.x` -> molten-x, `plasma.x` -> x-plasma and the plain name, again without hyphens.
  * recipe maps: `MAPS` (GT map -> Gregtorio machine families). A Gregtorio category's family is its name without the
    tier in front (lv-, mk1-), the sub-tier at the end (-mk2, -t3, -2) and -recipes: mv-macerator-recipes ->
    macerator. GT's own categories split a map: `<map> [recycling]` (every part back into dust, ingots or a melt) and
    `<map> [molding]`. GT's furnace recipes and crafting table recipes are the pseudo maps `furnace` (`furnace
    [recycling]` for a part smelted back) and `crafting`; crafting recipes of GT tools are not compared.
  * tier: from EU/t, GT's voltage tiers (ULV recipes count as LV, Gregtorio's lowest electric tier).
  * time: GT ticks / 20 = seconds of a machine of the recipe's tier; a Gregtorio recipe's seconds are its
    energy_required / 2^tier of its category (LV 1, MV 2, ...; Gregtorio's rule: GT seconds x the speed of the tier, so
    both agree when the recipe is GT's), for a category without a tier / the slowest crafting speed of its machines.
  * fluid scale: Gregtorio writes most fluids in a tenth of GT's litres (164's rule); the report says per map which
    ratio GT litres / Gregtorio amount its matched recipes have, and counts a recipe off that ratio as different.

A GT recipe is
  * `unmapped` when one of its items or fluids has no Gregtorio name (the report lists the GT items that block the
    most recipes, input for the tables below),
  * `duplicate` when an earlier GT recipe of the same machine has the same items (GT++'s multiblock copies, GT's
    explosive variants),
  * `matched` when a Gregtorio recipe of the map's families has the same items and fluids in and out (amounts aside);
    its numbers are compared (time, amounts, chances, tier),
  * `elsewhere` when such a recipe exists in another machine,
  * `variant` when a Gregtorio recipe of the families takes the GT recipe's first ingredient and makes its first
    product (other byproducts, another cutting fluid, ...),
  * `missing` else: a gap.
"""
import argparse, ast, gzip, json, re, sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DUMP = ROOT / "tools/gtnh_dump/gtnh-recipes.json.gz"
TIERS = ["lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max"]
#: GT's voltages V[0] ULV .. V[14] MAX
GT_V = [8 * 4 ** i for i in range(15)]

#: GT OrePrefixes -> Gregtorio name patterns (%s = the material); the first that is a Gregtorio item wins
PREFIX = {
    "dust": ["%s-dust", "%s"], "dustSmall": ["small-pile-of-%s-dust"], "dustTiny": ["tiny-pile-of-%s-dust"],
    "dustImpure": ["impure-%s-dust"], "dustPure": ["pure-%s-dust"], "crushed": ["crushed-%s"],
    "crushedPurified": ["purified-%s"], "crushedCentrifuged": ["centrifuged-%s"],
    "ore": ["raw-%s", "raw-%s-ore"], "rawOre": ["raw-%s", "raw-%s-ore"],
    "ingot": ["%s-ingot", "%s"], "ingotHot": ["hot-%s-ingot"], "nugget": ["%s-nugget"],
    "plate": ["%s-plate", "%s-sheet"], "plateDouble": ["double-%s-plate"], "plateTriple": ["triple-%s-plate"],
    "plateQuadruple": ["quadruple-%s-plate"], "plateQuintuple": ["quintuple-%s-plate"],
    "plateDense": ["dense-%s-plate"], "plateSuperdense": ["superdense-%s-plate"], "foil": ["%s-foil"],
    "stick": ["%s-rod"], "stickLong": ["long-%s-rod"], "bolt": ["%s-bolt"], "screw": ["%s-screw"],
    "round": ["%s-round"], "ring": ["%s-ring"], "wireFine": ["fine-%s-wire"], "springSmall": ["small-%s-spring"],
    "spring": ["%s-spring"], "itemCasing": ["%s-item-casing"], "frameGt": ["%s-frame"],
    "block": ["block-of-%s", "%s-block", "%s"], "gearGtSmall": ["%s-gear"], "gearGt": ["large-%s-gear"],
    "rotor": ["%s-rotor"], "turbineBlade": ["%s-turbine-blade"], "lens": ["%s-lens"],
    "gem": ["%s-gem", "%s"], "gemChipped": ["chipped-%s"], "gemFlawed": ["flawed-%s"],
    "gemFlawless": ["flawless-%s"], "gemExquisite": ["exquisite-%s"],
    "wireGt01": ["%s-wire"], "wireGt02": ["%s-wire-2x"], "wireGt04": ["%s-wire-4x"], "wireGt08": ["%s-wire-8x"],
    "wireGt12": ["%s-wire-12x"], "wireGt16": ["%s-wire-16x"],
    "cableGt01": ["%s-cable"], "cableGt02": ["%s-cable-2x"], "cableGt04": ["%s-cable-4x"],
    "cableGt08": ["%s-cable-8x"], "cableGt12": ["%s-cable-12x"], "cableGt16": ["%s-cable-16x"],
    "pipeTiny": ["tiny-%s-fluid-pipe"], "pipeSmall": ["small-%s-fluid-pipe"], "pipeMedium": ["%s-fluid-pipe"],
    "pipeLarge": ["large-%s-fluid-pipe"], "pipeHuge": ["huge-%s-fluid-pipe"],
    "nanite": ["%s-nanite", "%s-nanites"], "dustRefined": ["refined-%s-dust"],
    "milled": ["milled-%s"], "plateDoubleHybrid": [], "sheetmetal": [],
}
#: ore dictionary prefixes GT's ore blocks use (oreEndstone, oreNetherrack, ...): all are the raw ore
ORE_BLOCK = re.compile(r"^ore[A-Z]\w*$")
#: prefixes of items that are fluid containers: the fluid they hold, 1000 L per item
CELL = {"cell": "", "cellMolten": "molten.", "cellPlasma": "plasma."}

#: GT material (mName) -> Gregtorio material, where the names differ beyond case and hyphens; tools/gen_gt_parts.py's
#: GT_NAME and tools/gen_gt_icons.py's MATERIALS are added at load time
MATERIALS = {"NaquadahEnriched": "enriched-naquadah", "Chrome": "chromium", "ElectrumFlux": "fluxed-electrum",
             "SamariumMagnetic": "magnetic-samarium", "Wood": "wood", "AnyCopper": "copper", "AnyIron": "iron",
             "AnyBronze": "bronze", "AnyRubber": "rubber", "AnySyntheticRubber": "rubber", "Steeleaf": "steeleaf",
             "NetherQuartz": "nether-quartz", "CertusQuartz": "certus-quartz", "Lapis": "lapis",
             "NeodymiumMagnetic": "magnetic-neodymium", "SteelMagnetic": "magnetic-steel",
             "IronMagnetic": "magnetic-iron", "Silicone": "silicone-rubber", "PolyvinylChloride": "pvc",
             "Polystyrene": "polystyrene", "Plastic": "polyethylene"}
#: ore dictionary names -> Gregtorio items: Gregtorio has one circuit per tier where GT has an ore dictionary entry
#: per tier (issue #164's circuit variants), and a few others
ORES = {"circuitPrimitive": "ulv-circuit", "circuitBasic": "electronic-circuit", "circuitGood": "advanced-circuit",
        "circuitAdvanced": "processing-unit", "circuitData": "ev-circuit", "circuitElite": "iv-circuit",
        "circuitMaster": "luv-circuit", "circuitUltimate": "zpm-circuit", "circuitSuperconductor": "uv-circuit",
        "circuitInfinite": "uhv-circuit", "circuitBio": "uev-circuit", "circuitOptical": "uiv-circuit",
        "circuitExotic": "umv-circuit", "circuitCosmic": "uxv-circuit", "circuitTranscendent": "max-circuit",
        "stickWood": "stick", "plankWood": "plank", "logWood": "wood", "slabWood": "plank",
        "craftingChest": "wooden-chest", "chestWood": "wooden-chest", "plateAnyRubber": "rubber-sheet", "plateAnySyntheticRubber": "styrene-butadiene-rubber-sheet"}
#: GT's component names "<thing> (<tier>)" -> Gregtorio's "<tier>-<thing>" with these words left out
COMPONENT_WORDS = re.compile(r"^(electric|basic|advanced|elite|ultimate)-")
#: prefixes of the parts made from a material: a furnace recipe that smelts one back is GT's recycling
PARTS = re.compile(r"^(plate\w*|foil|stick\w*|bolt|screw|round|ring|wireFine|spring\w*|itemCasing|frameGt|gearGt\w*|"
                   r"rotor|wireGt\d+|cableGt\d+|toolHead\w*|turbineBlade|pipe\w+|lens)$")
#: GT tools (gt.metatool.*): they wear in a crafting grid and are not consumed; Gregtorio has none
TOOL = re.compile(r"^gregtech:gt\.(?:detrav\.)?metatool\.")
#: GT item (registry name:meta) -> Gregtorio item, for what neither unification nor the name finds
ITEMS = {
    "minecraft:sand:0": "sand", "minecraft:cobblestone:0": "stone", "minecraft:stone:0": "stone",
    "minecraft:gravel:0": "gravel", "minecraft:glass:0": "glass", "minecraft:redstone:0": "redstone-dust",
    "minecraft:glowstone_dust:0": "glowstone-dust", "minecraft:coal:0": "coal", "minecraft:coal:1": "charcoal",
    "minecraft:log:0": "wood", "minecraft:planks:0": "plank", "minecraft:stick:0": "stick",
    "minecraft:paper:0": "paper", "minecraft:string:0": "string", "minecraft:flint:0": "flint",
    "minecraft:clay_ball:0": "clay", "minecraft:brick:0": "brick", "minecraft:ender_pearl:0": "ender-pearl",
    "minecraft:ender_eye:0": "ender-eye", "minecraft:blaze_powder:0": "blaze-powder", "minecraft:blaze_rod:0": "blaze-rod",
    "minecraft:nether_star:0": "nether-star", "minecraft:obsidian:0": "obsidian", "minecraft:netherrack:0": "netherrack",
    "minecraft:end_stone:0": "end-stone", "minecraft:soul_sand:0": "soul-sand", "minecraft:ice:0": "ice",
    "minecraft:snowball:0": "snowball", "minecraft:sugar:0": "sugar", "minecraft:wheat:0": "wheat",
    "minecraft:slime_ball:0": "slime-ball", "minecraft:leather:0": "leather", "minecraft:bone:0": "bone",
    "minecraft:dye:15": "bone-meal", "minecraft:gunpowder:0": "gunpowder", "minecraft:diamond:0": "diamond",
    "minecraft:emerald:0": "emerald", "minecraft:quartz:0": "nether-quartz",
    # the implosion compressor's explosives: Gregtorio has one, GT four variants of each recipe
    "minecraft:tnt:0": "explosives", "IC2:blockITNT:0": "explosives", "IC2:itemDynamite:0": "explosives",
    "gregtech:gt.blockreinforced:5": "explosives",
}
#: items whose amounts are not compared: several GT items with their own amounts map onto them
NO_AMOUNT = {"explosives"}
#: GT fluid -> Gregtorio fluid, for what the name rules do not find
FLUIDS = {"molten.silicone": "silicone-rubber", "ic2distilledwater": "distilled-water", "ic2steam": "steam", "ic2superheatedsteam": "superheated-steam",
          "ic2uumatter": "uu-matter", "ic2coolant": "coolant", "ic2hotcoolant": "hot-coolant",
          "hydrochloricacid_gt5u": "hydrochloric-acid", "liquid_drillingfluid": "drilling-fluid",
          "molten.rubber": "liquid-rubber", "molten.plastic": "polyethylene", "molten.polyethylene": "polyethylene",
          "molten.glass": "molten-glass", "molten.concrete": "liquid-concrete", "lava": "lava"}

#: GT recipe map -> Gregtorio machine families (the first is the machine GT means; the others take the same
#: recipes in Gregtorio). None: a machine Gregtorio does not have; "copy": a GT++ multiblock whose map repeats a
#: single block's (compared as that machine, duplicates once)
MAPS = {
    "gt.recipe.macerator": ["macerator"], "gt.recipe.fluidextractor": ["fluid-extractor"],
    "gt.recipe.arcfurnace": ["arc-furnace"], "gt.recipe.cuttingsaw": ["cutting-machine"],
    "gt.recipe.fakecuttingsaw": ["cutting-machine"],
    "gt.recipe.alloysmelter": ["alloy-smelter"], "gt.recipe.assembler": ["assembling-machine", "crafting-or-assembling"],
    "gt.recipe.cable": ["assembling-machine", "crafting-or-assembling"],
    "gt.recipe.hammer": ["forge-hammer"], "gt.recipe.fluidsolidifier": ["fluid-solidifier"],
    "gt.recipe.extruder": ["extruder"], "gt.recipe.metalbender": ["bending-machine"],
    "gt.recipe.canner": ["canning-machine"], "gt.recipe.laserengraver": ["laser-engraver"],
    "gt.recipe.lathe": ["lathe"], "gt.recipe.wiremill": ["wiremill"], "gt.recipe.centrifuge": ["centrifuge"],
    "gt.recipe.multicentrifuge": ["centrifuge"], "gt.recipe.cauldron": ["cauldron"],
    "gt.recipe.implosioncompressor": ["implosion-compressor"],
    "gt.recipe.electricimplosioncompressor": ["electric-implosion-compressor"],
    "gt.recipe.chemicalreactor": ["chemical-reactor"], "gt.recipe.largechemicalreactor": ["chemical-reactor"],
    "gt.recipe.compressor": ["compressor"], "gt.recipe.blastfurnace": ["electric-blast-furnace"],
    "gt.recipe.thermalcentrifuge": ["thermal-centrifuge"], "gt.recipe.orewasher": ["ore-washer"],
    "gt.recipe.distillery": ["distillation"], "gt.recipe.distillationtower": ["tall-distillation"],
    "gt.recipe.chemicalbath": ["chemical-bath"], "gt.recipe.electrolyzer": ["electrolyzer"],
    "gt.recipe.multielectro": ["electrolyzer"], "gt.recipe.mixer": ["mixer"], "gt.recipe.multimixer": ["mixer"],
    "gt.recipe.primitiveblastfurnace": ["pbf"], "gt.recipe.vacuumfreezer": ["vacuum-freezer"],
    "gt.recipe.press": ["forming-press"], "gt.recipe.autoclave": ["autoclave"], "gt.recipe.polarizer": ["polarizer"],
    "gt.recipe.alloyblastsmelter": ["alloy-blast-smelter"], "gt.recipe.fakeAssemblylineProcess": ["assembly-line"],
    "gt.recipe.circuitassembler": ["circuit-assembler"], "bw.recipe.cal": ["circuit-assembly-line"],
    "gt.recipe.craker": ["cracker"], "gt.recipe.sifter": ["sifter"], "gt.recipe.chemicaldehydrator": ["dehydrator"],
    "gt.recipe.multidehydrator": ["dehydrator", "industrial-dehydrator"],
    "gt.recipe.fusionreactor": ["fusion-reactor"], "gt.recipe.extractor": ["extractor"],
    "gt.recipe.electromagneticseparator": ["electromagnetic-separator"], "gt.recipe.pyro": ["pyrolyse-oven"],
    "gt.recipe.fermenter": ["fermenter"], "gt.recipe.brewer": ["brewery"],
    "gt.recipe.quantumforcesmelter": ["quantum-force-transformer"], "gt.recipe.beamcrafter": ["beam-crafter"],
    "gt.recipe.algae_pond": ["algae-farm"], "gt.recipe.vacfurnace": ["vacuum-furnace"],
    "gt.recipe.treefarm": ["greenhouse"], "gt.recipe.nanoforge": ["nano-forge"],
    "gg.recipe.neutron_activator": ["neutron-activator"], "gg.recipe.precise_assembler": ["precise-assembler"],
    "gt.recipe.plasmaforge": ["dimensionally-transcendent-plasma-forge"],
    "gg.recipe.naquadah_fuel_refine_factory": ["naquadah-fuel-refinery"],
    "kubatech.defusioncrafter": ["draconic-evolution-fusion-crafter"], "gtnhlanth.recipe.sc": ["source-chamber"],
    "gtnhlanth.recipe.disstank": ["dissolution-tank"], "gtnhlanth.recipe.digester": ["digester"],
    "gt.recipe.reactorprocessingunit": ["reactor-processing-unit"], "gt.recipe.lftr": ["lftr"],
    "gt.recipe.lftr.sparging": ["sparge-tower"], "gt.recipe.massfab": ["mass-fabricator"],
    "gt.recipe.coldtrap": ["cold-trap"], "bw.recipe.BacteriaVat": ["bacterial-vat"],
    "gt.recipe.fluidchemicaleactor": ["chemical-plant"], "gt.recipe.spaceMining": ["space-mining"],
    "gt.recipe.spaceAssembler": ["space-assembler"], "gg.recipe.extreme_heat_exchanger": ["large-heat-exchanger"],
    "gt.recipe.large_hadron_collider": ["lhc-em", "lhc-weak", "lhc-lhcb"],
    "gt.recipe.rockbreaker": ["rock-crusher"], "gt.recipe.multiblockrockbreaker": ["rock-crusher"],
    "gt.recipe.purificationplantclarifier": ["water-purification"],
    "gt.recipe.purificationplantozonation": ["water-purification"],
    "gt.recipe.purificationplantflocculation": ["water-purification"],
    "gt.recipe.purificationplantphadjustment": ["water-purification"],
    "gt.recipe.purificationplantplasmaheating": ["water-purification"],
    "gt.recipe.purificationplantuvtreatment": ["water-purification"],
    "gt.recipe.purificationplantdegasifier": ["water-purification"],
    "gt.recipe.purificationplantquarkextractor": ["water-purification"],
    "furnace": ["smelting", "multismelter"],
    "crafting": ["crafting", "crafting-table", "crafting-or-assembling", "manual-only"],
}
#: families that repeat other machines' recipes in Gregtorio and are left out of the comparison
COPY_FAMILIES = {"steam-macerator", "steam-compressor", "steam-forge-hammer", "steam-extractor", "steam-alloy-smelter",
                 "fluid-voiding", "parameters", "recycling"}
#: GT maps of fuels and generators (Gregtorio keeps fuels as fuel values, not recipes) and other maps with nothing to
#: compare; listed in the report as "not compared"
NOT_RECIPES = re.compile(r"fuel|generator|reactor$|boiler|gt\.recipe\.(scanner|replicator|researchStation|printer|"
                         r"upgrade_costs|ic2nuke|fakespaceprojects|spaceResearch|uuamplifier|matterfab2|packager|"
                         r"unpackager|icecreammachine|eyeofharmony|solartower|thermalboiler|fissionfuel|RTGgenerators)$")


def family(cat):
    """Gregtorio category -> machine family: mv-macerator-recipes -> macerator, mk2-fusion-reactor-recipes ->
    fusion-reactor, precise-assembler-mk2-recipes -> precise-assembler, space-mining-2-recipes -> space-mining"""
    f = re.sub(r"-recipes$", "", cat)
    f = re.sub(r"^(?:%s|ulv|mk\d)-" % "|".join(TIERS), "", f)
    return re.sub(r"-(?:mk\d|t\d|\d)$", "", f)


def cat_tier(cat):
    m = re.match(r"^(%s)-" % "|".join(TIERS), cat)
    return m.group(1) if m else None


def gt_tier(eut):
    """index into TIERS of a GT recipe's EU/t (ULV counts as LV)"""
    eut = abs(eut)
    for i, v in enumerate(GT_V):
        if eut <= v:
            return max(i - 1, 0)
    return len(TIERS) - 1


def nohyphen(s):
    return re.sub(r"[^a-z0-9]", "", s.lower())


def kebab(s):
    s = re.sub(r"(?<=[a-z0-9])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|(?<=[a-zA-Z])(?=\d)", "-", s)
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")


def tool_tables():
    """GT names of Gregtorio materials from tools/gen_gt_parts.py (GT_NAME) and tools/gen_gt_icons.py (MATERIALS,
    the string values), read as literals so no image library is needed"""
    out = {}
    for f, var in (("gen_gt_parts.py", "GT_NAME"), ("gen_gt_icons.py", "MATERIALS")):
        src = (ROOT / "tools" / f).read_text(encoding="utf-8")
        m = re.search(r"^%s = (\{.*?\n\})" % var, src, re.M | re.S) or re.search(r"^%s = (\{[^\n]*\})" % var, src, re.M)
        if not m:
            continue
        try:
            table = ast.literal_eval(m.group(1))
        except (ValueError, SyntaxError):
            continue
        for greg, gt in table.items():
            if isinstance(gt, str):
                out.setdefault(gt, greg)
    return out


class Gregtorio:
    """Gregtorio's items, fluids, recipes and machines from a devcheck log (sections DUMP and BALANCE)."""

    def __init__(self, sec):
        self.items = {r[1] for r in sec["DUMP"] if r[0] == "I"}
        self.fluids = {r[1] for r in sec["DUMP"] if r[0] == "F"}
        self.recipes, speeds = [], defaultdict(list)
        L = lambda x: x if isinstance(x, list) else []
        for row in sec["BALANCE"]:
            o = json.loads("\t".join(row))
            if o["kind"] == "recipe":
                o["ingredients"], o["results"] = L(o["ingredients"]), L(o["results"])
                self.recipes.append(o)
            elif o["kind"] == "crafter":
                for c in L(o.get("categories")):
                    speeds[c].append(o.get("speed") or 1)
        self.speed = {c: min(v) for c, v in speeds.items()}
        self.by_key, self.by_main = defaultdict(list), defaultdict(list)
        self.families = Counter()
        for r in self.recipes:
            fam = family(r["category"])
            r["family"] = fam
            if fam in COPY_FAMILIES or r["name"].startswith("void-") or r.get("hidden"):
                continue
            self.families[fam] += 1
            ins = frozenset(s["name"] for s in r["ingredients"])
            outs = frozenset(s["name"] for s in r["results"])
            self.by_key[(ins, outs)].append(r)
            for i in ins:
                for o in outs:
                    self.by_main[(fam, i, o)].append(r)
        self.locale = {}
        for f in sorted((ROOT / "locale/en").glob("*.cfg")):
            section = None
            for line in f.read_text(encoding="utf-8").splitlines():
                m = re.match(r"^\[(.+)\]$", line)
                if m:
                    section = m.group(1)
                elif "=" in line and section in ("item-name", "entity-name", "fluid-name"):
                    k, v = line.split("=", 1)
                    if k in self.items or k in self.fluids:
                        self.locale.setdefault(v.strip().lower(), k)
        # material index per pattern: nohyphen(material) -> item
        self.forms = {}
        pats = {p for ps in PREFIX.values() for p in ps}
        for p in pats:
            rx = re.compile("^" + re.escape(p).replace("%s", "(.+)") + "$")
            idx = {}
            for it in self.items:
                m = rx.match(it)
                if m:
                    idx.setdefault(nohyphen(m.group(1)), it)
            self.forms[p] = idx
        self.fluid_idx = {}
        for fl in self.fluids:
            self.fluid_idx.setdefault(nohyphen(fl), fl)


class Mapper:
    def __init__(self, dump, greg):
        self.dump, self.g = dump, greg
        self.items = dump["items"]
        self.alias = {nohyphen(k): v for k, v in {**tool_tables(), **MATERIALS}.items()}
        self.cache = {}
        self.prefixes = sorted(PREFIX, key=len, reverse=True) + sorted(CELL, key=len, reverse=True)

    def material_key(self, mat):
        """GT material name -> the nohyphen key of the Gregtorio material"""
        a = self.alias.get(nohyphen(mat))
        return nohyphen(a) if a else nohyphen(mat)

    def form(self, prefix, mat):
        """(kind, name): ("item", x), ("fluid", x) or (None, None)"""
        if prefix in CELL:
            if mat in ("Empty", "None"):
                return "drop", None
            f = self.fluid(CELL[prefix] + nohyphen(mat))
            return ("fluid", f) if f else (None, None)
        if ORE_BLOCK.match(prefix) and prefix not in PREFIX:
            prefix = "ore"
        key = self.material_key(mat)
        for p in PREFIX.get(prefix, []):
            it = self.g.forms.get(p, {}).get(key)
            if it:
                return "item", it
        return None, None

    def split_ore(self, ore):
        for p in self.prefixes:
            if ore.startswith(p) and len(ore) > len(p) and ore[len(p)].isupper():
                return p, ore[len(p):]
        m = re.match(r"^(ore[A-Z][a-z]+)([A-Z]\w+)$", ore)
        return (m.group(1), m.group(2)) if m else (None, None)

    def item(self, key):
        """GT item key -> ("item", name) | ("fluid", name) | ("drop", None) | (None, None)"""
        if key in self.cache:
            return self.cache[key]
        r = self._item(key)
        self.cache[key] = r
        return r

    def _item(self, key):
        if key in ITEMS:
            return "item", ITEMS[key]
        if TOOL.match(key):
            return "drop", None
        info = self.items.get(key, {})
        for ore in info.get("ore", []):
            if ore in ORES and ORES[ore] in self.g.items:
                return "item", ORES[ore]
        if info.get("prefix") and info.get("material"):
            r = self.form(info["prefix"], info["material"])
            if r[0]:
                return r
        for ore in info.get("ore", []):
            p, mat = self.split_ore(ore)
            if p:
                r = self.form(p, mat)
                if r[0]:
                    return r
        name = (info.get("name") or "").strip()
        if name:
            it = self.g.locale.get(name.lower())
            if it:
                return ("fluid" if it in self.g.fluids and it not in self.g.items else "item"), it
            k = kebab(name)
            if k in self.g.items:
                return "item", k
            m = re.match(r"^(.+?) \((%s)\)$" % "|".join(["ULV"] + TIERS), name, re.I)
            if m:
                base = kebab(m.group(1))
                for b in (base, COMPONENT_WORDS.sub("", base)):
                    if f"{m.group(2).lower()}-{b}" in self.g.items:
                        return "item", f"{m.group(2).lower()}-{b}"
        return None, None

    def ore(self, ore):
        """an ore dictionary entry of a crafting recipe -> like item()"""
        if ore.startswith("craftingTool"):
            return "drop", None
        if ore in ORES and ORES[ore] in self.g.items:
            return "item", ORES[ore]
        p, mat = self.split_ore(ore)
        if p:
            r = self.form(p, mat)
            if r[0]:
                return r
        return None, None

    def fluid(self, name):
        if name in FLUIDS:
            return FLUIDS[name] if FLUIDS[name] in self.g.fluids else None
        n = re.sub(r"_gt5u$", "", name)
        n = re.sub(r"^ic2", "", n)
        cands = [n]
        if n.startswith("molten."):
            cands = ["molten" + n[7:], n[7:]]
        elif n.startswith("plasma."):
            cands = [n[7:] + "plasma"]
        for c in cands:
            f = self.g.fluid_idx.get(nohyphen(c))
            if f:
                return f
        return None


def gt_recipes(dump):
    """(map, recipe) for every recipe of the dump, the furnace and crafting lists as the pseudo maps furnace and
    crafting in the same shape"""
    for name, m in dump["recipe_maps"].items():
        for r in m["recipes"]:
            # (GT's own categories inside a map: the recycling recipes of every part, the alloy smelter's molds)
            cat = re.match(r"^gt\.recipe\.category\.\w+?_(recycling|molding)$", r.get("category") or "")
            yield (f"{name} [{cat.group(1)}]" if cat else name), r
    for f in dump.get("furnace", []):
        part = PARTS.match(dump["items"].get(f["in"]["id"], {}).get("prefix") or "")
        yield ("furnace [recycling]" if part else "furnace"), {"in": [f["in"]], "out": [f["out"]], "fin": [], "fout": [], "eut": 0, "duration": 0}
    for c in dump.get("crafting", []):
        if TOOL.match(c["out"]["id"]):
            yield "crafting:tool", None
            continue
        ins = []
        for s in c.get("in", []):
            if isinstance(s, dict) and s.get("any"):
                s = s["any"][0]     # (a list of items without an ore dictionary name: its first)
            if isinstance(s, dict) and ("id" in s or "ore" in s):
                ins.append({**s, "n": s.get("n", 1)})
        yield "crafting", {"in": ins, "out": [c["out"]], "fin": [], "fout": [], "eut": 0, "duration": 0}


def map_recipe(mp, r):
    """GT recipe -> (ins, outs, unmapped): ins/outs {name: amount}, outs with chances; fluids in GT litres"""
    ins, outs, chances, fl_in, fl_out, bad = Counter(), Counter(), {}, Counter(), Counter(), []
    for s in r["in"]:
        if s.get("nc") or s.get("circuit") is not None or not s.get("n", 1):
            continue
        if "ore" in s and "id" not in s:
            kind, name = mp.ore(s["ore"])
            key = "ore:" + s["ore"]
        else:
            kind, name = mp.item(s["id"])
            key = s["id"]
        n = s.get("n", 1)
        if kind == "item":
            ins[name] += n
        elif kind == "fluid":
            fl_in[name] += 1000 * n
        elif kind is None:
            bad.append(key)
    for s in r["out"]:
        kind, name = mp.item(s["id"])
        if kind == "item":
            outs[name] += s["n"]
            if s.get("chance"):
                chances[name] = s["chance"] / 10000
        elif kind == "fluid":
            fl_out[name] += 1000 * s["n"]
        elif kind is None:
            bad.append(s["id"])
    for key, dest in (("fin", fl_in), ("fout", fl_out)):
        for f in r.get(key, []):
            name = mp.fluid(f["fluid"])
            if name:
                dest[name] += f["l"]
            else:
                bad.append("fluid:" + f["fluid"])
    return dict(ins=ins, outs=outs, chances=chances, fin=fl_in, fout=fl_out), bad


def compare(mapped, gr, gtr, g, scale):
    """differences between a GT recipe (mapped) and a Gregtorio recipe gr: list of strings"""
    out = []
    # (a multismelter recipe is a batch of its furnace recipe: compare per item of the first ingredient)
    batch = 1
    if gr["family"] == "multismelter" and gr["ingredients"] and mapped["ins"]:
        first = gr["ingredients"][0]
        batch = (first.get("amount") or 1) / (mapped["ins"].get(first["name"]) or 1)
    amounts = {(s["type"], s["name"], "in"): s.get("amount") or 0 for s in gr["ingredients"]}
    amounts.update({(s["type"], s["name"], "out"): s.get("amount") or s.get("amount_max") or 0 for s in gr["results"]})
    probs = {s["name"]: s.get("probability") for s in gr["results"]}
    for kind, d, io in (("item", mapped["ins"], "in"), ("item", mapped["outs"], "out")):
        for name, n in d.items():
            if name in NO_AMOUNT:
                continue
            got = amounts.get((kind, name, io))
            if got is not None:
                got = got / batch
            if got is not None and abs(got - n) > 1e-9:
                out.append(f"{name} {io} {got} (GT {n})")
    for d, io in ((mapped["fin"], "in"), (mapped["fout"], "out")):
        for name, l in d.items():
            got = amounts.get(("fluid", name, io))
            if got and scale and abs(l / got - scale) > 1e-6 * scale:
                out.append(f"{name} {io} {got:g} (GT {l} L, map scale {scale:g})")
    for name, c in mapped["chances"].items():
        p = probs.get(name)
        if p is None or abs(p - c) > 1e-4:
            out.append(f"{name} chance {p if p is not None else 1} (GT {c:g})")
    for name, p in probs.items():
        if p is not None and p < 1 and name in mapped["outs"] and name not in mapped["chances"]:
            out.append(f"{name} chance {p:g} (GT 1)")
    if gtr.get("duration"):
        t = cat_tier(gr["category"])
        speed = 2 ** TIERS.index(t) if t else (g.speed.get(gr["category"], 1) or 1)
        secs = (gr.get("time") or 0.5) / speed
        gt_secs = gtr["duration"] / 20
        if abs(secs - gt_secs) > 0.02 * gt_secs + 1e-9:
            out.append(f"time {secs:g} s (GT {gt_secs:g} s)")
    t = cat_tier(gr["category"])
    if t and gtr.get("eut") and TIERS.index(t) != gt_tier(gtr["eut"]):
        out.append(f"tier {t} (GT {TIERS[gt_tier(gtr['eut'])]}, {gtr['eut']} EU/t)")
    return out


def run(dump, sec, out_md, out_json=None, limit=50):
    g = Gregtorio(sec)
    mp = Mapper(dump, g)
    per_map = defaultdict(Counter)
    blockers = Counter()
    blocker_maps = defaultdict(Counter)
    seen = set()
    missing, differs, ratios, variants = defaultdict(list), defaultdict(list), defaultdict(Counter), defaultdict(list)
    pending = []
    for mname, r in gt_recipes(dump):
        if r is None:
            # (a GT tool made in the crafting grid: Gregtorio has no GT tools)
            per_map[mname.split(":")[0]]["gt"] += 1
            per_map[mname.split(":")[0]]["not compared"] += 1
            continue
        st = per_map[mname]
        st["gt"] += 1
        fams = MAPS.get(mname.split(" [")[0])
        if fams is None:
            st["not compared" if NOT_RECIPES.search(mname) else "no machine"] += 1
            continue
        if not any(f in g.families for f in fams):
            st["no machine"] += 1
            continue
        if (mname.endswith("[recycling]") or mname == "gt.recipe.canner") and any(
                dump["items"].get(x.get("id"), {}).get("prefix") in CELL for x in r["in"] + r["out"]):
            # (GT recycles its fluid cells with the fluid still in them: the container's metal, not the fluid; the
            # canner fills and empties cells, which Gregtorio does not have)
            st["not compared"] += 1
            continue
        mapped, bad = map_recipe(mp, r)
        if bad:
            st["unmapped"] += 1
            for b in set(bad):
                blockers[b] += 1
                blocker_maps[b][mname] += 1
            continue
        ins = frozenset(list(mapped["ins"]) + list(mapped["fin"]))
        outs = frozenset(list(mapped["outs"]) + list(mapped["fout"]))
        if not outs or not ins:
            st["unmapped"] += 1
            continue
        key = (fams[0], ins, outs)
        if key in seen:
            st["duplicate"] += 1
            continue
        seen.add(key)
        st["mapped"] += 1
        cands = [x for x in g.by_key.get((ins, outs), []) if x["family"] in fams]
        if cands:
            st["matched"] += 1
            pending.append((mname, mapped, r, cands))
            continue
        if g.by_key.get((ins, outs)):
            st["elsewhere"] += 1
            continue
        main_in = next(iter(mapped["ins"]), None) or next(iter(mapped["fin"]), None)
        main_out = next(iter(mapped["outs"]), None) or next(iter(mapped["fout"]), None)
        var = next((x for f in fams for x in g.by_main.get((f, main_in, main_out), [])), None)
        if var:
            st["variant"] += 1
            variants[mname].append((describe(mapped, r), var["name"], describe_greg(var)))
            continue
        st["missing"] += 1
        missing[mname].append((r, mapped))
    # fluid scale per map from the matched recipes, then the comparison of their numbers
    for mname, mapped, r, cands in pending:
        for d, io in ((mapped["fin"], "in"), (mapped["fout"], "out")):
            for name, l in d.items():
                got = next((s.get("amount") for s in cands[0]["ingredients" if io == "in" else "results"]
                            if s["type"] == "fluid" and s["name"] == name), None)
                if got:
                    ratios[mname][round(l / got, 3)] += 1
    scale = {m: c.most_common(1)[0][0] for m, c in ratios.items() if c}
    for mname, mapped, r, cands in pending:
        best = min((compare(mapped, c, r, g, scale.get(mname)), c["name"]) for c in cands)
        if best[0]:
            per_map[mname]["differs"] += 1
            differs[mname].append((best[1], best[0]))

    # gaps grouped by map and material family of the main product
    groups = Counter()
    examples = defaultdict(list)
    for mname, rows in missing.items():
        for r, mapped in rows:
            main = r["out"][0]["id"] if r["out"] else None
            info = dump["items"].get(main, {}) if main else {}
            grp = info.get("material") or (next(iter(mapped["outs"]), None) or next(iter(mapped["fout"]), "?"))
            if mname.endswith("[recycling]"):
                grp = "(every material)"
            elif mname == "crafting" and info.get("prefix"):
                grp = "every " + info["prefix"]
            groups[(mname, grp)] += 1
            if len(examples[(mname, grp)]) < 3 and (grp != "(every material)" or len(examples[(mname, grp)]) < 3):
                    examples[(mname, grp)].append(describe(mapped, r))

    tot = Counter()
    for st in per_map.values():
        tot.update(st)
    lines = [f"# GT New Horizons recipes against Gregtorio (issue #679)", "",
             f"Dump: GT5-Unofficial {dump.get('git_describe') or dump.get('gt_version')} "
             f"(commit {dump.get('git_commit', '?')[:10]})"
             + (f", NewHorizonsCoreMod {dump['mods']['dreamcraft']}" if "dreamcraft" in dump.get("mods", {}) else "")
             + f", {dump.get('created', '')}.", "",
             "Columns: GT recipes; not compared (fuels, scanners, GT tools, cells, ...); no machine (Gregtorio has no "
             "recipe of that machine, or no such machine); unmapped (an item or fluid "
             "without a Gregtorio name); duplicate (the same items again, e.g. a GT++ multiblock's copy); mapped; "
             "matched (same items in and out); differs (matched, other numbers); elsewhere (same items in another "
             "machine); variant (same products or same ingredients); missing (gap). Fluid scale: GT litres per "
             "Gregtorio unit in the matched recipes.", "",
             "| map | GT | not compared | no machine | unmapped | duplicate | mapped | matched | differs | elsewhere "
             "| variant | missing | fluid scale |", "|" + "---|" * 13]
    cols = ["gt", "not compared", "no machine", "unmapped", "duplicate", "mapped", "matched", "differs", "elsewhere",
            "variant", "missing"]
    for mname, st in sorted(per_map.items(), key=lambda kv: -kv[1]["gt"]):
        sc = ratios.get(mname)
        sc_s = ", ".join(f"{k:g} ({v})" for k, v in sc.most_common(3)) if sc else ""
        lines.append(f"| {mname} | " + " | ".join(str(st[c]) for c in cols) + f" | {sc_s} |")
    lines.append("| **all** | " + " | ".join(f"**{tot[c]}**" for c in cols) + " | |")
    lines += ["", f"## The {limit} largest gaps (missing recipes by map and material of the main product)", "",
              "| map | material / product | missing | examples |", "|---|---|---|---|"]
    for (mname, grp), n in groups.most_common(limit):
        lines.append(f"| {mname} | {grp} | {n} | " + "<br>".join(examples[(mname, grp)]) + " |")
    lines += ["", f"## The {limit} GT items and fluids that block the most recipes (no Gregtorio name)", "",
              "| GT item | name | prefix / material | recipes | maps |", "|---|---|---|---|---|"]
    for b, n in blockers.most_common(limit):
        info = dump["items"].get(b, {})
        pm = f"{info.get('prefix', '')} {info.get('material', '')}".strip()
        maps = ", ".join(f"{m} {c}" for m, c in blocker_maps[b].most_common(3))
        lines.append(f"| {b} | {info.get('name', '')} | {pm} | {n} | {maps} |")
    lines += ["", "## Matched recipes with other numbers (first 10 per map)", "",
              "Kinds: recipes of the map with another time, tier, item amount, fluid amount (beyond the map's fluid "
              "scale) or chance.", ""]
    for mname, rows in sorted(differs.items(), key=lambda kv: -len(kv[1])):
        kinds = Counter(k for _, d in rows for k in {diff_kind(x) for x in d})
        lines.append(f"- **{mname}** ({len(rows)}; " + ", ".join(f"{k} {v}" for k, v in kinds.most_common()) + "): "
                     + "; ".join(f"`{n}` " + ", ".join(d[:3]) for n, d in rows[:10]))
    Path(out_md).parent.mkdir(parents=True, exist_ok=True)
    Path(out_md).write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    if out_json:
        Path(out_json).write_text(json.dumps({
            "dump": {k: dump.get(k) for k in ("gt_version", "git_commit", "git_describe", "created")},
            "maps": per_map, "scale": {m: dict(c) for m, c in ratios.items()},
            "gaps": [{"map": m, "group": grp, "missing": n, "examples": examples[(m, grp)]}
                     for (m, grp), n in groups.most_common()],
            "missing": {m: [describe(mapped, r) for r, mapped in rows] for m, rows in missing.items()},
            "differs": {m: [{"recipe": n, "diff": d} for n, d in rows] for m, rows in differs.items()},
            "variants": {m: [{"gt": a, "gregtorio": n, "recipe": b} for a, n, b in rows] for m, rows in variants.items()},
            "blockers": [{"id": b, "recipes": n, "name": dump["items"].get(b, {}).get("name"),
                          "maps": dict(blocker_maps[b])} for b, n in blockers.most_common()],
        }, indent=1), encoding="utf-8", newline="\n")
    return per_map, tot, groups


def diff_kind(x):
    return ("time" if x.startswith("time ") else "tier" if x.startswith("tier ") else "chance" if " chance " in x
            else "fluid" if " L" in x else "amount")


def describe_greg(gr):
    part = lambda xs: " + ".join(f"{s.get('amount') or s.get('amount_max') or 0:g}{' L' if s['type'] == 'fluid' else 'x'} "
                                 f"{s['name']}" for s in xs)
    return f"{part(gr['ingredients'])} -> {part(gr['results'])}"


def describe(mapped, r):
    def part(items, fluids):
        return " + ".join([f"{n}x {k}" for k, n in items.items()] + [f"{l:g} L {k}" for k, l in fluids.items()])
    t = f" ({r['duration'] / 20:g} s, {r['eut']} EU/t)" if r.get("duration") else ""
    return f"{part(mapped['ins'], mapped['fin'])} -> {part(mapped['outs'], mapped['fout'])}{t}"


def load_dump(path):
    with gzip.open(path, "rt", encoding="utf-8") as f:
        return json.load(f)


def sections(log):
    out = {}
    for m in re.finditer(r"DEVCHECK-([A-Z]+)-BEGIN\n(.*?)\nDEVCHECK-\1-END", log, re.S):
        out[m.group(1)] = [l.split("\t") for l in m.group(2).splitlines() if l]
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", default=str(DUMP))
    ap.add_argument("--log", default=str(ROOT / ".devcheck/last-run.log"), help="log of a devcheck check run")
    ap.add_argument("--out", default=str(ROOT / ".devcheck/gtnh-diff.md"))
    ap.add_argument("--json", default=str(ROOT / ".devcheck/gtnh-diff.json"))
    a = ap.parse_args()
    sec = sections(Path(a.log).read_text(encoding="utf-8", errors="replace"))
    if "BALANCE" not in sec or "DUMP" not in sec:
        sys.exit(f"{a.log} has no DUMP/BALANCE section: run `devcheck.py check` first (or `devcheck.py gtnh-diff`)")
    per_map, tot, groups = run(load_dump(a.dump), sec, a.out, a.json)
    print(summary(tot, a.out))


def summary(tot, out):
    return (f"GT recipes {tot['gt']}: not compared {tot['not compared']}, no Gregtorio machine {tot['no machine']}, "
            f"unmapped {tot['unmapped']}, duplicates {tot['duplicate']}, mapped {tot['mapped']} (matched "
            f"{tot['matched']}, of them with other numbers {tot['differs']}; elsewhere {tot['elsewhere']}; variant "
            f"{tot['variant']}; missing {tot['missing']}); report: {out}")


if __name__ == "__main__":
    main()
