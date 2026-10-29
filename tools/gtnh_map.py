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

Issue #714: a merged dump (tools/gtnh_dump/nei_to_dump.py) has a `source` on every recipe; the report then counts the
statuses per source (gt5u, nei, both) and the NEI-only recipes of each gap.
"""
import argparse, ast, gzip, json, re, sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
#: issue #714: the GT5-Unofficial dump merged with the full-pack NEI dump (tools/gtnh_dump/nei_to_dump.py) when it
#: exists, else the GT5-Unofficial dump alone; each recipe of the merged dump has its `source` (gt5u, nei, both)
DUMP = next((p for p in (ROOT / "tools/gtnh_dump/gtnh-merged.json.gz", ROOT / "tools/gtnh_dump/gtnh-recipes.json.gz")
             if p.exists()), ROOT / "tools/gtnh_dump/gtnh-recipes.json.gz")
SOURCES = ["gt5u", "nei", "both"]
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
    "block": ["block-of-%s", "%s-block"], "gearGtSmall": ["%s-gear"], "gearGt": ["large-%s-gear"],
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
    # issue #687: GT's wood dust is Gregtorio's wood pulp (the material Wood would map it onto the log)
    "gregtech:gt.metaitem.01:2809": "wood-pulp",
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
        # (issue #687: the machine families whose machines are furnaces, which pick one recipe per input)
        self.furnace_families = {family(c) for r in sec["DUMP"] if r[0] == "C" and len(r) > 3 and r[2] == "furnace"
                                 for c in r[3].split(",") if c}
        # (issue #691: per category the most fluid boxes in and out any of its machines has)
        self.fluid_cap = {}
        for r in sec["DUMP"]:
            if r[0] == "C" and len(r) > 5:
                for c in r[3].split(","):
                    if c:
                        fi, fo = self.fluid_cap.get(c, (0, 0))
                        self.fluid_cap[c] = (max(fi, int(r[4] or 0)), max(fo, int(r[5] or 0)))
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
        # (issue #687: the dump's placeholder of an item of a mod the dev environment lacks)
        if (info.get("name") or "").startswith("§cMissing Item"):
            return None, None
        # (issue #689: Gregtorio's raw ores are GT's raw ore items, rawOre; GT's ore blocks of every stone (ore,
        # oreNetherrack, oreEndstone, ...) give more crushed ore and other byproducts)
        if info.get("prefix") == "ore" or ORE_BLOCK.match(info.get("prefix") or ""):
            return "oreblock", None
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
        """an ore dictionary entry of a crafting recipe -> like item(); issue #688: GT's tools are #612's charges where
        Gregtorio has the tool, else nothing (the recipe is unmapped)"""
        if ore.startswith("craftingTool"):
            charge = TOOL_CHARGES.get(ore)
            return ("item", charge) if charge in self.g.items else (None, None)
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
        yield ("furnace [recycling]" if part else "furnace"), {"in": [f["in"]], "out": [f["out"]], "fin": [], "fout": [], "eut": 0, "duration": 0,
                                                               "source": f.get("source", "gt5u")}
    for c in dump.get("crafting", []):
        if TOOL.match(c["out"]["id"]):
            yield "crafting:tool", {"tool": True, "source": c.get("source", "gt5u")}
            continue
        ins = []
        for s in c.get("in", []):
            if isinstance(s, dict) and s.get("any"):
                s = s["any"][0]     # (a list of items without an ore dictionary name: its first)
            if isinstance(s, dict) and ("id" in s or "ore" in s):
                ins.append({**s, "n": s.get("n", 1)})
        yield "crafting", {"in": ins, "out": [c["out"]], "fin": [], "fout": [], "eut": 0, "duration": 0,
                           "source": c.get("source", "gt5u")}


def map_recipe(mp, r):
    """GT recipe -> (ins, outs, unmapped): ins/outs {name: amount}, outs with chances; fluids in GT litres; `stacks`:
    the output stacks per item, [(amount, chance)] (issue #689: GT gives an item twice, once sure and once by chance)"""
    ins, outs, chances, fl_in, fl_out, bad = Counter(), Counter(), {}, Counter(), Counter(), []
    stacks = defaultdict(list)
    # (several GT items that map onto one Gregtorio item: their amounts are not compared)
    ids = defaultdict(set)
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
        if kind == "oreblock":
            return dict(oreblock=True), []
        if kind == "item":
            ins[name] += n
            ids[("in", name)].add(key)
        elif kind == "fluid":
            fl_in[name] += 1000 * n
        elif kind is None:
            bad.append(key)
    for s in r["out"]:
        kind, name = mp.item(s["id"])
        if kind == "item":
            outs[name] += s["n"]
            chance = min(s["chance"] / 10000, 1) if s.get("chance") else 1
            if chance < 1:
                chances[name] = chance
            stacks[name].append((s["n"], chance))
            ids[("out", name)].add(s["id"])
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
    merged = {k for k, v in ids.items() if len(v) > 1}
    return dict(ins=ins, outs=outs, chances=chances, stacks=dict(stacks), fin=fl_in, fout=fl_out, merged=merged), bad


def batch_of(mapped, gr):
    """how many GT recipes one Gregtorio recipe is: a multismelter recipe is a batch of its furnace recipe (its first
    ingredient's amount per GT's); issue #689: a recipe whose every item amount is the same multiple of GT's (16 rods
    -> 64 bolts) is that many GT recipes at once"""
    if gr["family"] == "multismelter" and gr["ingredients"] and mapped["ins"]:
        first = gr["ingredients"][0]
        return (first.get("amount") or 1) / (mapped["ins"].get(first["name"]) or 1)
    have = Counter()
    for io, key in (("in", "ingredients"), ("out", "results")):
        for s in gr[key]:
            if s["type"] == "item":
                have[(io, s["name"])] += s.get("amount") or s.get("amount_max") or 0
    ratios = set()
    for io, d in (("in", mapped["ins"]), ("out", mapped["outs"])):
        for name, n in d.items():
            if name in NO_AMOUNT or (io, name) in mapped["merged"] or not n or not have.get((io, name)):
                continue
            ratios.add(round(have[(io, name)] / n, 6))
    return ratios.pop() if len(ratios) == 1 else 1


def greg_stacks(gr, batch=1):
    """a Gregtorio recipe's item results per item, [(amount, chance)] (per batch)"""
    st = defaultdict(list)
    for s in gr["results"]:
        if s["type"] == "item":
            p = s.get("probability")
            st[s["name"]].append(((s.get("amount") or s.get("amount_max") or 0) / batch, 1 if p is None else p))
    return st


def by_chance(stacks):
    """[(amount, chance)] -> {chance (4 places): the amount at that chance}"""
    out = Counter()
    for a, c in stacks:
        out[round(c, 4)] += a
    return {c: round(a, 9) for c, a in out.items()}


def tier_speed(gr, gtr, g):
    """the speed a Gregtorio recipe's time is written for: its category's tier (Gregtorio's rule: GT seconds x the
    speed of the recipe's tier), for a category without a tier GT's tier from EU/t (as 164's steps write a
    multiblock's recipe), without EU/t the slowest machine of the category"""
    t = cat_tier(gr["category"])
    if t:
        return 2 ** TIERS.index(t)
    if gtr.get("eut"):
        return 2 ** gt_tier(gtr["eut"])
    return g.speed.get(gr["category"], 1) or 1


def compare(mapped, gr, gtr, g, scale):
    """differences between a GT recipe (mapped) and a Gregtorio recipe gr: list of strings"""
    out = []
    batch = batch_of(mapped, gr)
    amounts = Counter()
    for s in gr["ingredients"]:
        amounts[(s["type"], s["name"], "in")] += s.get("amount") or 0
    for s in gr["results"]:
        amounts[(s["type"], s["name"], "out")] += s.get("amount") or s.get("amount_max") or 0
    for name, n in mapped["ins"].items():
        if name in NO_AMOUNT or ("in", name) in mapped["merged"]:
            continue
        got = amounts.get(("item", name, "in"))
        if got is not None and abs(got / batch - n) > 1e-9:
            out.append(f"{name} in {got / batch} (GT {n})")
    # (issue #689: the output stacks of an item, its sure and its chanced amounts, compared as the amount per chance;
    # GT splits more than 64 into stacks of 64)
    have = greg_stacks(gr, batch)
    for name, want in mapped["stacks"].items():
        if name in NO_AMOUNT or name not in have or ("out", name) in mapped["merged"]:
            continue
        got, exp = by_chance(have[name]), by_chance(want)
        if got == exp:
            continue
        gs, ws = sum(got.values()), sum(exp.values())
        if abs(gs - ws) > 1e-9:
            out.append(f"{name} out {gs:g} (GT {ws:g})")
        if sorted(got) != sorted(exp) or abs(gs - ws) <= 1e-9:
            show = lambda d: "/".join(f"{c:g}" for c in sorted(d) if c < 1) or "1"
            out.append(f"{name} chance {show(got)} (GT {show(exp)})")
    for d, io in ((mapped["fin"], "in"), (mapped["fout"], "out")):
        for name, l in d.items():
            got = amounts.get(("fluid", name, io))
            # (197 puts an amount on the engine's grid: up, and a result nine steps of 2^-24 more)
            if got and scale and abs(got / batch - l / scale) > max(1e-5, 1e-6 * l / scale):
                out.append(f"{name} {io} {got / batch:g} (GT {l} L, map scale {scale:g})")
    if gtr.get("duration"):
        speed = tier_speed(gr, gtr, g)
        secs = (gr.get("time") or 0.5) / speed / batch
        gt_secs = gtr["duration"] / 20
        if abs(secs - gt_secs) > 0.02 * gt_secs + 1e-9:
            out.append(f"time {secs:g} s (GT {gt_secs:g} s)")
    t = cat_tier(gr["category"])
    if t and gtr.get("eut") and TIERS.index(t) != gt_tier(gtr["eut"]):
        out.append(f"tier {t} (GT {TIERS[gt_tier(gtr['eut'])]}, {gtr['eut']} EU/t)")
    return out


def run(dump, sec, out_md, out_json=None, limit=50, state=None):
    """the report (out_md None: none); `state` (a dict) gets the mapping, the matched recipes and the fluid scales"""
    g = Gregtorio(sec)
    mp = Mapper(dump, g)
    per_map = defaultdict(Counter)
    blockers = Counter()
    blocker_maps = defaultdict(Counter)
    seen = set()
    missing, differs, ratios, variants = defaultdict(list), defaultdict(list), defaultdict(Counter), defaultdict(list)
    pending = []
    # issue #714: the statuses per source of the merged dump (gt5u, nei, both)
    per_src = defaultdict(Counter)
    for mname, r in gt_recipes(dump):
        src = r.get("source", "gt5u")
        if r.get("tool"):
            # (a GT tool made in the crafting grid: Gregtorio has no GT tools)
            for c in (per_map[mname.split(":")[0]], per_src[src]):
                c["gt"] += 1
                c["not compared"] += 1
            continue
        st = per_map[mname]

        def count(k):
            st[k] += 1
            per_src[src][k] += 1
        count("gt")
        fams = MAPS.get(mname.split(" [")[0])
        if fams is None:
            count("not compared" if NOT_RECIPES.search(mname) else "no machine")
            continue
        if not any(f in g.families for f in fams):
            count("no machine")
            continue
        if (mname.endswith("[recycling]") or mname == "gt.recipe.canner") and any(
                dump["items"].get(x.get("id"), {}).get("prefix") in CELL for x in r["in"] + r["out"]):
            # (GT recycles its fluid cells with the fluid still in them: the container's metal, not the fluid; the
            # canner fills and empties cells, which Gregtorio does not have)
            count("not compared")
            continue
        mapped, bad = map_recipe(mp, r)
        if mapped.get("oreblock"):
            # (a GT ore block, not the raw ore item: see Mapper._item)
            count("not compared")
            continue
        if bad:
            count("unmapped")
            for b in set(bad):
                blockers[b] += 1
                blocker_maps[b][mname] += 1
            continue
        ins = frozenset(list(mapped["ins"]) + list(mapped["fin"]))
        outs = frozenset(list(mapped["outs"]) + list(mapped["fout"]))
        if not outs or not ins:
            count("unmapped")
            continue
        key = (fams[0], ins, outs)
        if key in seen:
            count("duplicate")
            continue
        seen.add(key)
        count("mapped")
        cands = [x for x in g.by_key.get((ins, outs), []) if x["family"] in fams]
        if cands:
            count("matched")
            pending.append((mname, mapped, r, cands))
            continue
        if g.by_key.get((ins, outs)):
            count("elsewhere")
            continue
        main_in = next(iter(mapped["ins"]), None) or next(iter(mapped["fin"]), None)
        main_out = next(iter(mapped["outs"]), None) or next(iter(mapped["fout"]), None)
        var = next((x for f in fams for x in g.by_main.get((f, main_in, main_out), [])), None)
        if var:
            count("variant")
            variants[mname].append((describe(mapped, r), var["name"], describe_greg(var)))
            continue
        count("missing")
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
        best = min(((compare(mapped, c, r, g, scale.get(mname)), c["name"]) for c in cands), key=lambda x: (len(x[0]), x[1]))
        if best[0]:
            per_map[mname]["differs"] += 1
            per_src[r.get("source", "gt5u")]["differs"] += 1
            differs[mname].append((best[1], best[0]))
    if state is not None:
        state.update(g=g, pending=pending, scale=scale)

    # gaps grouped by map and material family of the main product
    groups = Counter()
    group_nei = Counter()
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
            if r.get("source") == "nei":
                group_nei[(mname, grp)] += 1
            if len(examples[(mname, grp)]) < 3 and (grp != "(every material)" or len(examples[(mname, grp)]) < 3):
                    examples[(mname, grp)].append(describe(mapped, r))

    tot = Counter()
    for st in per_map.values():
        tot.update(st)
    lines = [f"# GT New Horizons recipes against Gregtorio (issue #679)", "",
             f"Dump: GT5-Unofficial {dump.get('git_describe') or dump.get('gt_version')} "
             f"(commit {dump.get('git_commit', '?')[:10]})"
             + (f", NewHorizonsCoreMod {dump['mods']['dreamcraft']}" if "dreamcraft" in dump.get("mods", {}) else "")
             + f", {dump.get('created', '')}."
             + (f" Merged with the NEI dump of {nei['pack']} ({nei['fork']}, issue #714)."
                if (nei := dump.get("sources", {}).get("nei")) else ""), "",
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
    if "sources" in dump:
        lines += ["", "## Per source (issue #714)", "",
                  "gt5u: only in the GT5-Unofficial dump; nei: only in the NEI dump (what it adds); both: in both (the "
                  "GT5-Unofficial dump's line).", "",
                  "| source | " + " | ".join(cols) + " |", "|" + "---|" * (len(cols) + 1)]
        for s in SOURCES:
            c = per_src.get(s, Counter())
            lines.append(f"| {s} | " + " | ".join(str(c[k]) for k in cols) + " |")
    lines += ["", f"## The {limit} largest gaps (missing recipes by map and material of the main product)", "",
              "| map | material / product | missing | of them NEI only | examples |", "|---|---|---|---|---|"]
    for (mname, grp), n in groups.most_common(limit):
        lines.append(f"| {mname} | {grp} | {n} | {group_nei[(mname, grp)]} | " + "<br>".join(examples[(mname, grp)]) + " |")
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
    if out_md:
        Path(out_md).parent.mkdir(parents=True, exist_ok=True)
        Path(out_md).write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
    if out_json:
        Path(out_json).write_text(json.dumps({
            "dump": {k: dump.get(k) for k in ("gt_version", "git_commit", "git_describe", "created")},
            "sources": dump.get("sources"), "per_source": per_src,
            "maps": per_map, "scale": {m: dict(c) for m, c in ratios.items()},
            "gaps": [{"map": m, "group": grp, "missing": n, "nei_only": group_nei[(m, grp)], "examples": examples[(m, grp)]}
                     for (m, grp), n in groups.most_common()],
            "missing": {m: [describe(mapped, r) for r, mapped in rows] for m, rows in missing.items()},
            "differs": {m: [{"recipe": n, "diff": d} for n, d in rows] for m, rows in differs.items()},
            "variants": {m: [{"gt": a, "gregtorio": n, "recipe": b} for a, n, b in rows] for m, rows in variants.items()},
            "blockers": [{"id": b, "recipes": n, "name": dump["items"].get(b, {}).get("name"),
                          "maps": dict(blocker_maps[b])} for b, n in blockers.most_common()],
        }, indent=1), encoding="utf-8", newline="\n")
    return per_map, tot, groups


#: issue #689: GT's numbers for Gregtorio's matched recipes (`numbers`, prototypes/data/gtnh-numbers.lua, applied by
#: prototypes/168-fork-gtnh-numbers.lua): times, item amounts, chances and tiers, but
#:   * not the crafting table's recipes: GT's tools are left out of them, so recipes with and without a tool merge (#688);
#:   * not 157's recycling (recycling-*): its amounts and times are GT's formulas on Gregtorio's own recipes (the
#:     maintainer's decision on #190);
#:   * (issue #671) fluid amounts too: a tenth of GT's litres, Gregtorio's rule;
#:   * a tier only downward: a higher tier needs a later machine, which moves the recipe's unlock (#724);
#:   * not the blast furnace's tier, which is its coil heat in Gregtorio (#620);
#:   * not the fusion reactor (its times and inputs are the plasma balance of #32), no time of a hand recipe.
NUMBERS_SKIP_MAPS = {"crafting"}
NO_TIER_FAMILIES = {"electric-blast-furnace"}
#: (the fusion reactor's times are the plasma balance of #32; a recipe of crafting-or-assembling is a hand recipe too,
#: GT's assembler time would be the hand's)
NO_TIME_FAMILIES = {"crafting-or-assembling"}
NUMBERS_SKIP_FAMILIES = {"fusion-reactor"}
NUMBERS_FILE = ROOT / "prototypes" / "data" / "gtnh-numbers.lua"


def tier_down(c, r, g, equal=False):
    """GT's tier of the recipe when it is below the Gregtorio recipe's (or the same, `equal`) and a Gregtorio machine
    runs that tier's category, else None"""
    cur = cat_tier(c["category"])
    if not cur or not r.get("eut") or c["family"] in NO_TIER_FAMILIES:
        return None
    t = TIERS[gt_tier(r["eut"])]
    cat = t + c["category"][len(cur):]
    below = TIERS.index(t) < TIERS.index(cur) or (equal and t == cur)
    return t if below and cat in g.speed else None


def in_scope(diffs, c, r, g):
    """the differences `numbers` sets right: time, item amounts, chances, fluid amounts (issue #671: a tenth of GT's
    litres) and a tier downward"""
    out = []
    for x in diffs:
        k = diff_kind(x)
        if (k == "time" and c["family"] not in NO_TIME_FAMILIES) or k in ("amount", "chance", "fluid") or (
                k == "tier" and tier_down(c, r, g)):
            out.append(x)
    return out


def gt_numbers(mapped, c, r, g, amounts=True):
    """GT's numbers in Gregtorio's units for the Gregtorio recipe c: t (tier, downward only), e (energy_required: GT
    seconds x the tier's speed, x the batch), i ({item: amount}), o ([item, amount, chance] per chance) and (issue #671)
    fi and fo ({fluid: a tenth of GT's litres}, x the batch)"""
    out = {}
    batch = batch_of(mapped, c)
    if amounts:
        ok = lambda x: abs(x * batch - round(x * batch)) < 1e-9
        if not all(ok(n) for n in mapped["ins"].values()) or not all(
                ok(a) for st in mapped["stacks"].values() for a in by_chance(st).values()):
            batch = 1
    # (the tier also when it is GT's already, so the table stays the same once it is applied)
    t = tier_down(c, r, g, equal=True)
    if t:
        out["t"] = t
    if r.get("duration") and c["family"] not in NO_TIME_FAMILIES:
        speed = 2 ** TIERS.index(t) if t else tier_speed(c, r, g)
        out["e"] = round(r["duration"] / 20 * speed * batch, 6)
    if amounts:
        out["i"] = {n: round(a * batch) for n, a in mapped["ins"].items()
                    if n not in NO_AMOUNT and ("in", n) not in mapped["merged"]}
        order = [x["name"] for x in c["results"] if x["type"] == "item"]
        o = []
        for name in sorted(mapped["stacks"], key=lambda n: order.index(n) if n in order else len(order)):
            if name in NO_AMOUNT or ("out", name) in mapped["merged"]:
                continue
            for ch, a in sorted(by_chance(mapped["stacks"][name]).items(), key=lambda kv: -kv[0]):
                o.append([name, round(a * batch), ch])
        out["o"] = o
        out["fi"] = {n: round(l / FLUID_SCALE * batch, 6) for n, l in mapped["fin"].items()}
        out["fo"] = {n: round(l / FLUID_SCALE * batch, 6) for n, l in mapped["fout"].items()}
    return out


def numbers(state, kept=(), old=()):
    """Issue #689: GT's numbers for every matched Gregtorio recipe whose numbers differ from GT's in scope (see
    NUMBERS_SKIP_MAPS) or that the table `old` already has: ({recipe: gt_numbers}, {recipe: the differences in scope},
    Counter of the differences left out by kind)"""
    # (issue #671: a fluid amount is compared with Gregtorio's rule, a tenth of GT's litres, not the map's usual scale)
    g = state["g"]
    table, diffs, left = {}, {}, Counter()
    for mname, mapped, r, cands in state["pending"]:
        base = mname.split(" [")[0]
        for c in cands:
            name = c["name"]
            if name in table or name in diffs:
                continue
            d = compare(mapped, c, r, g, FLUID_SCALE)
            if base in NUMBERS_SKIP_MAPS or name.startswith("recycling-") or c["family"] in NUMBERS_SKIP_FAMILIES:
                if d:
                    left["crafting table (#688)" if base in NUMBERS_SKIP_MAPS else "recycling (#190)"
                         if name.startswith("recycling-") else "fusion (#32)"] += 1
                continue
            scoped = in_scope(d, c, r, g)
            for x in d:
                if x not in scoped:
                    k = diff_kind(x)
                    left["tier up (#724)" if k == "tier" else "hand recipe time (#688)"] += 1
            if name in kept:
                continue
            if scoped or name in old:
                table[name] = gt_numbers(mapped, c, r, g)
                if scoped:
                    diffs[name] = scoped
    return table, diffs, left


def numbers_lua(table):
    """prototypes/data/gtnh-numbers.lua"""
    num = lambda x: f"{x:.10g}"
    out = ["--- Generated by `tools/devcheck/devcheck.py check --gtnh-numbers` (issue #689) from the GT New Horizons recipe dump",
           "--- (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. GT's numbers of the Gregtorio recipes that",
           "--- have a GT recipe with the same items and fluids in and out: t the tier (only downward), e energy_required (GT's",
           "--- seconds x the tier's speed), i the item ingredients, o the item results { item, amount, chance }, fi and fo",
           "--- the fluid ingredients and results (a tenth of GT's litres, issue #671).",
           "--- prototypes/168-fork-gtnh-numbers.lua applies them; FORK_GTNH_NUMBERS_KEPT there keeps a recipe's own numbers.",
           "return {"]
    for name in sorted(table):
        e = table[name]
        parts = []
        if "t" in e:
            parts.append(f't = "{e["t"]}"')
        if "e" in e:
            parts.append(f"e = {num(e['e'])}")
        if "i" in e:
            parts.append("i = { " + ", ".join(f'["{k}"] = {num(v)}' for k, v in sorted(e["i"].items())) + " }"
                         if e["i"] else "i = {}")
        if "o" in e:
            parts.append("o = { " + ", ".join(f'{{ "{n}", {num(a)}' + (f", {num(c)}" if c < 1 else "") + " }"
                                            for n, a, c in e["o"]) + " }")
        for k in ("fi", "fo"):
            if e.get(k):
                parts.append(f"{k} = {{ " + ", ".join(f'["{n}"] = {num(v)}' for n, v in sorted(e[k].items())) + " }")
        out.append(f'\t["{name}"] = {{ ' + ", ".join(parts) + " },")
    out.append("}")
    return "\n".join(out) + "\n"


def numbers_names(path=NUMBERS_FILE):
    """the recipes of the table so far (empty: no file)"""
    if not Path(path).exists():
        return set()
    return set(re.findall(r'^\t\["([^"]+)"\] = ', Path(path).read_text(encoding="utf-8"), re.M))


#: issue #686: GT's recycling of the material parts, imported from the dump (`recycling_imports`,
#: prototypes/data/gtnh-recycling.lua, made by the section "Issue #686" of prototypes/157-fork-recycling.lua): the GT maps
#: and the kind in the recipe's name recycling-<kind>-<part>
RECYCLING_IMPORT = {"gt.recipe.macerator [recycling]": "macerator", "gt.recipe.arcfurnace [recycling]": "arc-furnace",
                    "gt.recipe.fluidextractor [recycling]": "fluid-extractor",
                    "gt.recipe.alloysmelter [recycling]": "alloy-smelter", "furnace [recycling]": "furnace"}
#: the GT prefixes of the material parts (a part of one material; blocks are #670's, cells GT's containers, gems the ore
#: chain's, dusts are no part)
PART_PREFIX = re.compile(r"^(plate\w*|foil|stick\w*|bolt|screw|round|ring|wireFine|spring\w*|itemCasing|frameGt|gearGt\w*|"
                         r"rotor|wireGt\d+|cableGt\d+|turbineBlade|pipe\w+|nugget)$")
#: a part by its Gregtorio name (GT++'s alloy parts have no GT prefix in the dump)
GREG_PART = re.compile(r"^(?:(?:double|triple|quadruple|quintuple|dense|superdense)-.+-plate|long-.+-rod|fine-.+-wire|"
                       r"small-.+-spring|large-.+-gear|.+-(?:plate|foil|rod|bolt|screw|round|ring|frame|gear|rotor|"
                       r"item-casing|nugget|ingot|spring|wire|cable|fluid-pipe)(?:-\d+x)?)$")
#: parts whose GT item maps onto another Gregtorio item (GT's paper is a plate of Paper and its dust maps onto paper, the
#: wood plate onto the plank and wood dust onto wood, plateAnyRubber onto the rubber sheet with silicone rubber's melt)
RECYCLING_SKIP = {"paper", "plank", "rubber-sheet"}
RECYCLING_FILE = ROOT / "prototypes" / "data" / "gtnh-recycling.lua"
#: GT's furnace recipes have no time: a smelting recipe of Gregtorio takes 10 s
SMELT_TIME = 10
FLUID_SCALE = 10


def category_for(family, tier, g):
    """the category of `family` at GT's tier, else the highest tier below it that a machine runs, else (issue #692: the
    blast furnace starts at MV) the lowest above it; the furnace's smelting has no tier; (category, tier)"""
    if family == "smelting":
        return "smelting", None
    for i in list(range(TIERS.index(tier), -1, -1)) + list(range(TIERS.index(tier) + 1, len(TIERS))):
        cat = f"{TIERS[i]}-{family}-recipes"
        if cat in g.speed:
            return cat, TIERS[i]
    return None, None


def import_entry(kind, mapped, r, g, dump):
    """a Gregtorio recipe in Gregtorio's units from a GT recycling recipe: {kind, item, cat, e, i, f, o, fo, mold}"""
    item = next(iter(mapped["ins"]))
    if kind == "furnace":
        cat, e = "smelting", SMELT_TIME
    else:
        fam = MAPS[[m for m, k in RECYCLING_IMPORT.items() if k == kind][0].split(" [")[0]][0]
        cat, t = category_for(fam, TIERS[gt_tier(r.get("eut") or 1)], g)
        if not cat:
            return None
        e = round(r["duration"] / 20 * 2 ** TIERS.index(t), 6)
    o = []
    for name, st in mapped["stacks"].items():
        for ch, a in sorted(by_chance(st).items(), key=lambda kv: -kv[0]):
            o.append([name, a, ch])
    return {"kind": kind, "item": item, "cat": cat, "e": e,
            "f": {n: l / FLUID_SCALE for n, l in mapped["fin"].items()},
            "o": o, "fo": {n: l / FLUID_SCALE for n, l in mapped["fout"].items()},
            "mold": any(s.get("nc") or not s.get("n", 1) for s in r["in"] if s.get("circuit") is None)}


#: the Gregtorio family of each kind (whose machines run one recipe per input when they are furnaces)
KIND_FAMILY = {"macerator": "macerator", "arc-furnace": "arc-furnace", "fluid-extractor": "fluid-extractor",
               "alloy-smelter": "alloy-smelter", "furnace": "smelting"}


def recycling_imports(dump, g):
    """Issue #686: GT's recycling recipes of the material parts in Gregtorio's units, [entry] sorted by kind and part;
    a part that a Gregtorio recipe of the machine (not this import) takes already is left out, as is a second GT
    recipe of the same part and machine. Also the other items GT recycles (components, casings, machines), which 157
    recycles by its own rule (their composition from Gregtorio's recipes, the decision on #190). Returns (entries,
    items, Counter of the parts left out by kind)"""
    mp = Mapper(dump, g)
    taken = defaultdict(set)
    for r in g.recipes:
        items = [s["name"] for s in r["ingredients"] if s["type"] == "item"]
        if r.get("hidden") or len(items) != 1:
            continue
        kind = next((k for k, f in KIND_FAMILY.items() if f == r["family"]), None)
        if kind and r["name"] == f"recycling-{kind}-{items[0]}":
            continue
        taken[r["family"]].add(items[0])
    out, seen, skipped, others = [], set(), Counter(), set()
    for mname, r in gt_recipes(dump):
        kind = RECYCLING_IMPORT.get(mname)
        if not kind:
            continue
        items = [s for s in r["in"] if not (s.get("nc") or s.get("circuit") is not None or not s.get("n", 1))]
        if len(items) != 1:
            continue
        prefix = dump["items"].get(items[0].get("id"), {}).get("prefix") or ""
        if prefix and not PART_PREFIX.match(prefix):
            continue
        mapped, bad = map_recipe(mp, r)
        if bad or mapped.get("oreblock") or len(mapped["ins"]) != 1 or not (mapped["outs"] or mapped["fout"]):
            continue
        item = next(iter(mapped["ins"]))
        if item in RECYCLING_SKIP:
            continue
        # (GT++'s alloy parts have no GT prefix: a part by its Gregtorio name; the rest is a component)
        if not prefix and not GREG_PART.match(item):
            if kind != "furnace" and item not in taken["macerator"]:
                others.add(item)
            continue
        if (kind, item) in seen:
            continue
        seen.add((kind, item))
        if item in taken[KIND_FAMILY[kind]]:
            skipped[kind] += 1
            continue
        e = import_entry(kind, mapped, r, g, dump)
        if e:
            out.append(e)
    out.sort(key=lambda e: (e["kind"], e["item"]))
    return out, sorted(others), skipped


def recycling_lua(entries, items):
    """prototypes/data/gtnh-recycling.lua"""
    num = lambda x: f"{x:.10g}"
    tab = chr(9)
    lines = ["--- Generated by `tools/devcheck/devcheck.py check --gtnh-recycling` (issue #686) from the GT New Horizons recipe dump",
             "--- (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. `parts`: GT's recycling of the material",
             "--- parts in Gregtorio's units, { kind, part, cat = category, e = energy_required, f = fluid ingredients, o = item",
             "--- results { item, amount, chance }, fo = fluid results, mold = the alloy smelter's mold }, which",
             "--- prototypes/157-fork-recycling.lua makes (recycling-<kind>-<part>); `items`: the other items GT recycles, which 157",
             "--- recycles by its own rule.",
             "return {", tab + "parts = {"]
    for e in entries:
        parts = [f'"{e["kind"]}"', f'"{e["item"]}"', f'cat = "{e["cat"]}"', f"e = {num(e['e'])}"]
        if e["f"]:
            parts.append("f = { " + ", ".join(f'{{ "{n}", {num(a)} }}' for n, a in sorted(e["f"].items())) + " }")
        if e["o"]:
            parts.append("o = { " + ", ".join(f'{{ "{n}", {num(a)}' + (f", {num(c)}" if c < 1 else "") + " }"
                                            for n, a, c in e["o"]) + " }")
        if e["fo"]:
            parts.append("fo = { " + ", ".join(f'{{ "{n}", {num(a)} }}' for n, a in sorted(e["fo"].items())) + " }")
        if e["mold"]:
            parts.append("mold = true")
        lines.append(tab * 2 + "{ " + ", ".join(parts) + " },")
    lines += [tab + "},", tab + "items = {"] + [tab * 2 + f'"{n}",' for n in items] + [tab + "},", "}"]
    return "\n".join(lines) + "\n"


#: issue #687: GT's part routes of its other machines, imported from the dump (`route_imports`,
#: prototypes/data/gtnh-part-routes.lua, made by section 3 of prototypes/158-fork-gt-parts.lua): GT map -> (Gregtorio
#: family, the verb of the recipe's name gt-<verb>-<product>-from-<input>)
ROUTE_IMPORT = {"gt.recipe.cuttingsaw": ("cutting-machine", "cut"), "gt.recipe.metalbender": ("bending-machine", "bend"),
                "gt.recipe.extruder": ("extruder", "extrude"), "gt.recipe.wiremill": ("wiremill", "draw"),
                "gt.recipe.hammer": ("forge-hammer", "hammer"), "gt.recipe.fluidsolidifier": ("fluid-solidifier", "solidify"),
                "gt.recipe.lathe": ("lathe", "turn"),
                # issue #690: the cable map, the assembler's wire insulation
                "gt.recipe.cable": ("assembling-machine", "insulate")}
ROUTES_FILE = ROOT / "prototypes" / "data" / "gtnh-part-routes.lua"


#: issue #691: GT's chemistry and separation recipes, imported like the routes (prototypes/data/gtnh-chemistry.lua,
#: section 3 of prototypes/158-fork-gt-parts.lua): GT map -> (Gregtorio family, verb)
CHEM_IMPORT = {"gt.recipe.distillery": ("distillation", "distill"), "gt.recipe.electrolyzer": ("electrolyzer", "electrolyze"),
               "gt.recipe.multielectro": ("electrolyzer", "electrolyze"), "gt.recipe.autoclave": ("autoclave", "autoclave"),
               "gt.recipe.centrifuge": ("centrifuge", "centrifuge"), "gt.recipe.multicentrifuge": ("centrifuge", "centrifuge"),
               "gt.recipe.chemicalreactor": ("chemical-reactor", "react"),
               "gt.recipe.largechemicalreactor": ("chemical-reactor", "react"), "gt.recipe.mixer": ("mixer", "mix"),
               "gt.recipe.chemicalbath": ("chemical-bath", "bathe")}
CHEMISTRY_FILE = ROOT / "prototypes" / "data" / "gtnh-chemistry.lua"
#: issue #692: GT's metallurgy recipes, imported the same way (prototypes/data/gtnh-metallurgy.lua); the furnace takes
#: only GT's dust smelting (a block or component in the furnace is GT's recycling, #686, #670)
METAL_IMPORT = {"gt.recipe.alloyblastsmelter": ("alloy-blast-smelter", "alloy-blast"),
                "gt.recipe.blastfurnace": ("electric-blast-furnace", "blast"), "gt.recipe.alloysmelter": ("alloy-smelter", "alloy"),
                "furnace": ("smelting", "smelt"), "gt.recipe.arcfurnace": ("arc-furnace", "arc-smelt"),
                "gt.recipe.compressor": ("compressor", "compress")}
METALLURGY_FILE = ROOT / "prototypes" / "data" / "gtnh-metallurgy.lua"
METALLURGY_HEADER = [
    "--- Generated by `tools/devcheck/devcheck.py check --gtnh-metallurgy` (issue #692) from the GT New Horizons recipe",
    "--- dump (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. GT's recipes of the alloy blast smelter,",
    "--- blast furnace, alloy smelter (mold = its mold), furnace, arc furnace and compressor that Gregtorio lacks, in Gregtorio's units:"]
#: the ore chain's forms (155's chain and 146's platinum line decide their recipes)
ORE_FORM = re.compile(r"^(raw|crushed|purified|centrifuged|impure|pure)-")


def route_imports(dump, g, table=None, chemistry=False):
    """Issue #687: every GT recipe of the ROUTE_IMPORT maps (issue #691: `table`) whose items and fluids map onto
    Gregtorio's names and that no Gregtorio recipe of the machine has with the same items and fluids (another cutting
    fluid, another input), in Gregtorio's units; not a recipe that gives its own input back, nor one whose input a
    furnace machine of the family takes already. `chemistry` (#691): a product may be a fluid; no ore chain forms (155,
    146), no GT cells (Gregtorio's cells are fuel cells of other amounts), only categories whose machines have the fluid
    boxes, nothing a furnace machine cannot run. Returns ([entry] sorted by name, Counter of the recipes left out by reason)"""
    table = table or ROUTE_IMPORT
    mp = Mapper(dump, g)
    verbs = tuple(f"gt-{v}-" for _, v in list(ROUTE_IMPORT.values()) + list(CHEM_IMPORT.values())
                  + list(METAL_IMPORT.values()))
    own = {r["name"] for r in g.recipes if r["name"].startswith(verbs)}
    taken = defaultdict(set)
    for r in g.recipes:
        items = [s["name"] for s in r["ingredients"] if s["type"] == "item"]
        if not r.get("hidden") and len(items) == 1 and r["name"] not in own:
            taken[r["family"]].add(items[0])
    out, seen, left = {}, set(), Counter()
    for mname, r in gt_recipes(dump):
        if mname not in table:
            continue
        fam, verb = table[mname]
        mapped, bad = map_recipe(mp, r)
        if bad or mapped.get("oreblock") or not (mapped["outs"] or (chemistry and mapped["fout"])) or not (
                mapped["ins"] or mapped["fin"]):
            continue
        ins = frozenset(list(mapped["ins"]) + list(mapped["fin"]))
        outs = frozenset(list(mapped["outs"]) + list(mapped["fout"]))
        if (fam, ins, outs) in seen:
            continue
        seen.add((fam, ins, outs))
        if ins & outs:
            left["gives its input back"] += 1
            continue
        if any(x["family"] == fam and x["name"] not in own for x in g.by_key.get((ins, outs), [])):
            continue
        first = next(iter(mapped["ins"]), None)
        product = next(iter(mapped["outs"]), None) or next(iter(mapped["fout"]))
        if chemistry:
            if any(ORE_FORM.match(i) for i in mapped["ins"]):
                left["ore chain form (155, 146)"] += 1
                continue
            if any(i.endswith("-cell") for i in list(mapped["ins"]) + list(mapped["outs"])):
                left["a GT cell"] += 1
                continue
            if fam in g.furnace_families and (len(mapped["ins"]) != 1 or len(mapped["fin"]) > 1):
                left["furnace machine: not one item and one fluid input at most"] += 1
                continue
            if fam == "smelting" and not (first or "").endswith("-dust"):
                left["furnace: not a dust (GT's recycling, #686)"] += 1
                continue
        # (crushing a raw ore is 155's ore chain, #202; GT++ hammers its ore block, not the raw ore, #373)
        if first and first.startswith("raw-"):
            left["raw ore (155's ore chain)"] += 1
            continue
        # (a route Gregtorio has with other numbers is #689's; only another cutting fluid is a new recipe)
        same = [x for x in g.by_main.get((fam, first or next(iter(mapped["fin"])), product), []) if x["name"] not in own]
        gfl = set(mapped["fin"])
        if same and (not gfl or any(gfl == {s["name"] for s in x["ingredients"] if s["type"] == "fluid"} for x in same)):
            left["route Gregtorio has (other numbers: #689)"] += 1
            continue
        if first and fam in g.furnace_families and len(mapped["ins"]) == 1 and first in taken[fam]:
            left["input taken (furnace machine)"] += 1
            continue
        cat, t = category_for(fam, TIERS[gt_tier(r.get("eut") or 1)], g)
        if not cat:
            left["no category"] += 1
            continue
        if chemistry:
            fi, fo = g.fluid_cap.get(cat, (0, 0))
            if len(mapped["fin"]) > fi or len(mapped["fout"]) > fo:
                left["more fluids than the machines have"] += 1
                continue
        src = first or next(iter(mapped["fin"]))
        name = f"gt-{verb}-{product}-from-{src}"
        fluid = next((f for f in mapped["fin"] if f != src), None)
        if fluid:
            name += f"-with-{fluid}"
        # (issue #690: GT insulates with a fluid alone or with a fluid and a pulp: the other items in the name)
        others = sorted(i for i in mapped["ins"] if i != src)
        if name in out and others:
            name += "-and-" + "-".join(others)
        # (issue #691: and the other fluids, when the name is taken still)
        more = sorted(f for f in mapped["fin"] if f not in (src, fluid))
        if chemistry and name in out and more:
            name += "-plus-" + "-".join(more)
        # (the distillery's variants of one input differ in their other product)
        products = sorted(x for x in list(mapped["outs"]) + list(mapped["fout"]) if x != product)
        if chemistry and name in out and products:
            name += "-to-" + "-".join(products)
        if name in out:
            left["same name"] += 1
            continue
        o = []
        for n, st in mapped["stacks"].items():
            for ch, a in sorted(by_chance(st).items(), key=lambda kv: -kv[0]):
                o.append([n, a, ch])
        # (issue #692: GT's furnace recipes have no time: Gregtorio's smelting takes 10 s; the alloy smelter's mold
        # stays in its slot, 150)
        secs = r["duration"] / 20 if r.get("duration") else SMELT_TIME
        mold = fam == "alloy-smelter" and any(x.get("nc") or not x.get("n", 1) for x in r["in"] if x.get("circuit") is None)
        out[name] = {"name": name, "cat": cat, "e": round(secs * (2 ** TIERS.index(t) if t else 1), 6), "mold": mold,
                     "i": dict(mapped["ins"]), "f": {n: l / FLUID_SCALE for n, l in mapped["fin"].items()},
                     "o": o, "fo": {n: l / FLUID_SCALE for n, l in mapped["fout"].items()}}
    return [out[n] for n in sorted(out)], left


def routes_lua(entries, chemistry=False, header=None):
    """prototypes/data/gtnh-part-routes.lua (issue #691: prototypes/data/gtnh-chemistry.lua)"""
    num = lambda x: f"{x:.10g}"
    tab = chr(9)
    pairs = lambda d: ", ".join(f'{{ "{n}", {num(a)} }}' for n, a in sorted(d.items()))
    lines = (header or (["--- Generated by `tools/devcheck/devcheck.py check --gtnh-chemistry` (issue #691) from the GT New Horizons recipe",
              "--- dump (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. GT's recipes of the distillery,",
              "--- electrolyzer, autoclave, centrifuge, chemical reactors, mixer and chemical bath that Gregtorio lacks, in Gregtorio's units:"]
             if chemistry else
             ["--- Generated by `tools/devcheck/devcheck.py check --gtnh-routes` (issue #687) from the GT New Horizons recipe dump",
              "--- (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. GT's recipes of the cutting machine,",
              "--- bender, extruder, wiremill, forge hammer, fluid solidifier and lathe that Gregtorio lacks, in Gregtorio's units:"])) + [
             "--- { name, cat = category, e = energy_required, i = item ingredients, f = fluid ingredients, o = item results",
             "--- { item, amount, chance }, fo = fluid results }. Section 3 of prototypes/158-fork-gt-parts.lua makes them.",
             "return {"]
    for e in entries:
        parts = [f'"{e["name"]}"', f'cat = "{e["cat"]}"', f"e = {num(e['e'])}"]
        if e["i"]:
            parts.append("i = { " + pairs(e["i"]) + " }")
        if e["f"]:
            parts.append("f = { " + pairs(e["f"]) + " }")
        parts.append("o = { " + ", ".join(f'{{ "{n}", {num(a)}' + (f", {num(c)}" if c < 1 else "") + " }"
                                        for n, a, c in e["o"]) + " }")
        if e["fo"]:
            parts.append("fo = { " + pairs(e["fo"]) + " }")
        if e.get("mold"):
            parts.append("mold = true")
        lines.append(tab + "{ " + ", ".join(parts) + " },")
    lines.append("}")
    return "\n".join(lines) + "\n"


#: issue #688: GT's crafting tools in a recipe (its ore dictionary craftingTool*) -> Gregtorio's tool charges of #612
#: (148's FORK_TOOLS); GT's other tools (mortar, soft mallet, crowbar, ...) Gregtorio does not have
TOOL_CHARGES = {"craftingToolHardHammer": "hammer-usage", "craftingToolFile": "file-usage", "craftingToolSaw": "saw-usage",
                "craftingToolWrench": "wrench-usage", "craftingToolScrewdriver": "screwdriver-usage",
                "craftingToolWireCutter": "wire-cutter-usage", "craftingToolKnife": "knife-usage"}
CRAFTING_FILE = ROOT / "prototypes" / "data" / "gtnh-part-crafting.lua"
#: the products of the crafting import: material parts, ingots (GT's mixed metal ingot), small and tiny piles of dust
CRAFT_PRODUCT = re.compile(r"^(?:small|tiny)-pile-of-.+-dust$")
#: products left out: 155 moves the lazurite and sodalite dust to Ore Crushing after 158 has run, so the piles would
#: come before their dust
CRAFT_SKIP = {f"{size}-pile-of-{m}-dust" for size in ("small", "tiny") for m in ("lazurite", "sodalite")}


def crafting_imports(dump, g):
    """Issue #688: GT New Horizons' crafting table recipes of the material parts (and of the small and tiny piles of a
    dust) whose items map onto Gregtorio's names, its tools onto #612's charges, that no Gregtorio recipe of the hand or
    the crafting table has with the same items; named <product>-crafting-table (-from-<input> when that name is taken).
    Returns ([entry] sorted by name, Counter of the recipes left out by reason)"""
    mp = Mapper(dump, g)
    hand = {"crafting", "crafting-table", "crafting-or-assembling", "manual-only"}
    own = {r["name"] for r in g.recipes if r["name"].endswith("-crafting-table") or "-crafting-table-from-" in r["name"]}
    taken_names = {r["name"] for r in g.recipes} - own
    out, seen, left = {}, set(), Counter()
    for mname, r in gt_recipes(dump):
        if mname != "crafting" or r.get("tool"):
            continue
        mapped, bad = map_recipe(mp, r)
        if bad or mapped.get("oreblock") or len(mapped["outs"]) != 1 or not mapped["ins"] or mapped["fin"]:
            continue
        product = next(iter(mapped["outs"]))
        if not (GREG_PART.match(product) or CRAFT_PRODUCT.match(product)) or product in mapped["ins"] or product in CRAFT_SKIP:
            continue
        # (crushing a raw ore by hand is 155's ore chain, #202)
        if any(i.startswith("raw-") for i in mapped["ins"]):
            left["raw ore (155's ore chain)"] += 1
            continue
        ins = frozenset(mapped["ins"])
        if (ins, product) in seen:
            continue
        seen.add((ins, product))
        if any(x["family"] in hand and x["name"] not in own for x in g.by_key.get((ins, frozenset([product])), [])):
            continue
        # (a hand route Gregtorio has with other amounts is the same recipe)
        if any(x["family"] in hand and x["name"] not in own and
               {s["name"] for s in x["ingredients"] if s["type"] == "item"} - set(TOOL_CHARGES.values()) == set(ins) - set(TOOL_CHARGES.values())
               for x in g.by_main.get(("crafting-table", next(iter(mapped["ins"])), product), []) +
               g.by_main.get(("crafting-or-assembling", next(iter(mapped["ins"])), product), [])):
            left["hand route Gregtorio has (with or without tools)"] += 1
            continue
        name = f"{product}-crafting-table"
        if name in taken_names or name in out:
            src = next((i for i in mapped["ins"] if i not in TOOL_CHARGES.values()), next(iter(mapped["ins"])))
            name = f"{product}-crafting-table-from-{src}"
        if name in taken_names or name in out:
            left["same name"] += 1
            continue
        out[name] = {"name": name, "p": product, "i": dict(mapped["ins"]), "n": mapped["outs"][product]}
    return [out[n] for n in sorted(out)], left


def crafting_lua(entries):
    """prototypes/data/gtnh-part-crafting.lua"""
    tab = chr(9)
    lines = ["--- Generated by `tools/devcheck/devcheck.py check --gtnh-crafting` (issue #688) from the GT New Horizons recipe dump",
             "--- (tools/gtnh_dump/) through tools/gtnh_map.py; do not edit, run it again. GT's crafting table recipes of the",
             "--- material parts and of the small and tiny piles of dust that Gregtorio lacks, GT's tools as #612's charges:",
             "--- { name, p = the product, i = { { item, amount } }, n = the amount made }. Section 4 of prototypes/158-fork-gt-parts.lua makes them.",
             "return {"]
    for e in entries:
        ins = ", ".join(f'{{ "{k}", {v} }}' for k, v in sorted(e["i"].items()))
        lines.append(tab + f'{{ "{e["name"]}", p = "{e["p"]}", i = {{ {ins} }}, n = {e["n"]} }},')
    lines.append("}")
    return "\n".join(lines) + "\n"


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
