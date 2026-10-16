--------------------------------------------------------------------------------
--- FORK DIMENSION MINES (issue #154's decision, part 1: issue #283): the materials of the microverse get a source of
--- their own, a mine per GT New Horizons dimension, gated by a technology that stands for reaching it at the voltage of
--- GTNH's rocket tier (gtneioreplugin DimensionHelper.java: the Nether and the End are T0). Issue #287 removed the
--- microverse. Veins from GT5-Unofficial af993ca6a9 OreMixes.java.
---
--- Overworld (MV, with Eyes of Ender, the first consumer): ender pearls are a mob drop of Endermen in GTNH; Gregtorio
---   has no mobs before the EV entity crusher, so a manual hunting recipe like the manual mines gives them, and the
---   crusher crushes Endermen like the other mobs (the maintainer's decision). Zombie heads (EnderIO's powered spawner,
---   soul binder and Z-logic controller, Ender IO) the same way (issue #287: the tier one microminer gave them; the
---   crusher's zombies come after the powered spawner they need).
--- The Nether (MV, technology Reach the Nether, before Eyes of Ender, which takes blaze rods):
---   * blaze rods: a mob drop (hunting, like the Endermen);
---   * the Molybdenum vein (Nether, End, Twilight Forest: wulfenite, molybdenite, molybdenum, powellite): molybdenite,
---     the one of them the mod has;
---   * soul sand (a Nether block): the dig site;
---   * nether air: GT++'s air intake hatch gives it in the Nether (MTEHatchAirIntake.java 41-53); here the HV compressor
---     (issue #314: not the LV one of the air collection), unlocked with the nether air distillation (End Steel).
--- The End (HV, technology Reach the End, after Eyes of Ender; before Radon, the first consumer of ender air):
---   * end stone (an End block) as compressed end stone;
---   * ender air in the HV compressor (issue #314: the EV one would lock the EV pack's radon); its liquefaction and
---     distillation move from EV Machines to Radon, so radon (the
---     quantum eye of the EV pack) comes from the End at HV (the maintainer's decision; GT's chemistry route, 8 plutonium
---     ingots, tiny uranium and air, is left out: the mod has neither plutonium ingots nor tiny uranium piles).
--- GTNH's End asteroids (naquadah, platinum, tungstate veins) come with the T3 dimensions (issue #285).
--- Issues #284 and #285 add the Moon and Mars, the asteroid belt, Jupiter's moons and Venus, issue #332 the Twilight
--- Forest's mines (with NAND Chips, no technology of their own) (sections below).
--- Loads before 142 (data.lua, issue #287): the unlock table of 142 and the ore chains of 155 (which unlock a chain step
--- after the technology of its raw ore) see the mines. The rules that move unlocks and add prerequisites for them are in
--- 161-fork-dimension-unlocks.lua, after 159.
--------------------------------------------------------------------------------

local F = FORK5B
local NETHER, END = "reach-the-nether", "reach-the-end"

local function manual(name, category, ingredients, results)
	create_recipe{
		name = name,
		category = category,
		energy_required = 10,
		subgroup = "subgroup-mining",
		ingredients = ingredients,
		results = results,
		main_product = results[1].name,
	}
	return name
end
local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end
local PICKAXE, LABOR = item("iron-pickaxe-usage", 1), function(n) return item("manual-labor", n) end

--- the unlocks of an existing technology
local function unlock_in(tech, names)
	local t = data.raw.technology[tech]
	for _, n in pairs(names) do
		data.raw.recipe[n].enabled = false
		t.effects[#t.effects + 1] = { type = "unlock-recipe", recipe = n }
	end
end

--------------------------------------------------------------------------------
--- OVERWORLD: Endermen
--------------------------------------------------------------------------------

local enderman = manual("hunting-endermen", "manual-mine-recipes", { LABOR(24) }, { item("ender-pearl", 4) })
local zombie = manual("hunting-zombies", "manual-mine-recipes", { LABOR(24) }, { item("zombie-head", 1) })
create_recipe{
	name = "crushing-endermen",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 8,
	subgroup = "subgroup-ev-extreme-entity-crusher-recipes",
	ingredients = {},
	results = { item("ender-pearl", 1) },
	main_product = "ender-pearl",
}

--------------------------------------------------------------------------------
--- THE NETHER
--------------------------------------------------------------------------------

local nether = {
	manual("hunting-blazes", "manual-mine-recipes", { LABOR(24) }, { item("blaze-rod", 4) }),
	manual("mining-molybdenum-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-molybdenite", 32) }),
	manual("digging-soul-sand", "manual-digsite-recipes", { item("iron-shovel-usage", 1), LABOR(2) },
		{ item("soul-sand", 64) }),
}
create_recipe{
	name = "nether-air-intake",
	category = "hv-compressor-recipes",   -- issue #314: an HV compressor (the maintainer's decision; EV would lock radon)
	energy_required = 10,
	subgroup = "subgroup-hv-compressor-recipes",
	ingredients = {},
	results = { fluid("nether-air", 1000) },
	main_product = "nether-air",
}

--------------------------------------------------------------------------------
--- THE END
--------------------------------------------------------------------------------

local the_end = {
	manual("mining-end-stone", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("compressed-end-stone", 4) }),
}
create_recipe{
	name = "ender-air-intake",
	category = "hv-compressor-recipes",   -- issue #314: an HV compressor (the maintainer's decision; EV would lock radon)
	energy_required = 10,
	subgroup = "subgroup-hv-compressor-recipes",
	ingredients = {},
	results = { fluid("ender-air", 1000) },
	main_product = "ender-air",
}

--------------------------------------------------------------------------------
--- TECHNOLOGIES
--------------------------------------------------------------------------------

F.tech{ name = NETHER, prerequisites = { "mv-machines", "extruder" }, packs = 3, count = 40, time = 30, recipes = nether }
F.tech{ name = END, prerequisites = { "eyes-of-ender", "hv-energy-hatches" }, packs = 4, count = 40, time = 30,
	recipes = the_end }
--- Endermen with the first use of their pearls; blaze rods come before it (161)
unlock_in("eyes-of-ender", { enderman })
unlock_in("extreme-entity-crushers", { "crushing-endermen" })
--- zombies with the first use of their heads (Ender IO's powered spawner)
unlock_in("ender-io", { zombie })
--- the nether air with its first consumer
unlock_in("end-steel", { "nether-air-intake" })



--------------------------------------------------------------------------------
--- THE TWILIGHT FOREST (issue #332, the maintainer's decision): GTNH's T0 dimension (DimensionHelper.java:99), two
--- recipes of the Manual Mine unlocked with NAND Chips, the first technology that needs them (the maintainer's choice: no
--- technology of their own). Its ores the mod lacked are topaz and amber, the two materials of GT's orange lens
--- (craftingLensOrange: the lens of every transparent dyeOrange material), which the simple SoC wafers need:
---   * the Aqua Ignis, Terra Aer and Perditio Ordo veins (OreMixes.java:534-570, Twilight Forest and Neper): Thaumcraft's
---     infused shards (primary, secondary; left out, the mod has no Thaumcraft), amber (in between), cinnabar
---     (sporadic); the three differ only by their shards: one mine, amber 32 as the first ore the mod has (as bornite
---     of Ross128), cinnabar 8;
---   * the small ores (SmallOres.java:214, 256, two of each per chunk): topaz (Twilight Forest and Horus) and amber,
---     8 of each, a quarter of a vein's first ore; the Twilight Forest's other small ores and veins hold ores the mod
---     mines elsewhere, so they get no mine (as #284/#285);
---   * issue #364: the Sapphire vein (OreMixes.java:375-386, Twilight Forest and Horus): almandine (primary) and pyrope
---     (secondary), which the mod has as dusts but not as ores (left out, as above), sapphire (in between) and green
---     sapphire (sporadic): sapphire 32 as the first ore the mod has, green sapphire 8; and the sapphire and green sapphire
---     small ores (SmallOres.java, Twilight Forest and Horus), 8 of each in the small ores' mine.
--- The raw ores are GT's (create_ore, 07): amber with GT's ore multiplier 2, all NO_SMELTING (no furnace recipe);
--- 155 gives them GTNH's ore chain, gem grades and the amber lens (issue #364: sapphire and green sapphire their chain,
--- grades and juice).
--------------------------------------------------------------------------------

create_ore("raw-topaz", nil, "crushed-topaz", "topaz-dust", nil, "crushed-topaz", nil, nil, 1, false, false)
create_ore("raw-amber", nil, "crushed-amber", "amber-dust", nil, "crushed-amber", nil, nil, 2, false, false)
create_ore("raw-sapphire", nil, "crushed-sapphire", "sapphire-dust", nil, "crushed-sapphire", nil, nil, 1, false, false)
create_ore("raw-green-sapphire", nil, "crushed-green-sapphire", "green-sapphire-dust", nil, "crushed-green-sapphire", nil,
	nil, 1, false, false)
unlock_in("nand-chips", {
	manual("mining-amber-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-amber", 32), item("raw-cinnabar", 8) }),
	manual("mining-twilight-forest-small-ores", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-topaz", 8), item("raw-amber", 8), item("raw-sapphire", 8),
			item("raw-green-sapphire", 8) }),
	manual("mining-sapphire-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },   -- issue #364
		{ item("raw-sapphire", 32), item("raw-green-sapphire", 8) }),
	"crushed-topaz", "crushed-amber", "crushed-sapphire", "crushed-green-sapphire",
})



--------------------------------------------------------------------------------
--- THE MOON AND MARS (issue #284): GTNH's T1 and T2 dimensions (rocket tiers of DimensionHelper.java), here HV and EV.
--- A mine per vein that holds a material the microverse gave, its GT ores in the mod's raw items (primary 32, the
--- others less, like the Overworld mines); GT's ores the mod lacks are left out:
---   Moon: TitaniumChrome (ilmenite, chromite; uvarovite, perlite left out), Bauxite (bauxite, ilmenite, aluminium),
---         Monazite (Moon, Deimos: bastnasite, monazite, neodymium)
---   Mars: Tungstate (Mars, Deimos: scheelite, tungstate; lithium left out), Pitchblende (Mars, Phobos: pitchblende,
---         uraninite), Uranium (Deimos, Phobos: uraninite)
--------------------------------------------------------------------------------

local MOON, MARS = "reach-the-moon", "reach-mars"
local moon = {
	manual("mining-titanium-chrome-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-ilmenite", 32), item("raw-chromite", 24) }),
	manual("mining-bauxite-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-bauxite", 32), item("raw-ilmenite", 16), item("raw-aluminium", 8) }),
	manual("mining-monazite-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-bastnasite", 32), item("raw-monazite", 16), item("raw-neodymium", 8) }),
}
local mars = {
	manual("mining-tungstate-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-scheelite", 32), item("raw-tungstate", 16) }),
	manual("mining-pitchblende-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-pitchblende", 32), item("raw-uraninite", 16) }),
	manual("mining-uranium-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-uraninite", 32) }),
}
F.tech{ name = MOON, prerequisites = { END, "implosion-compressor" }, packs = 4, count = 40, time = 30, recipes = moon }
F.tech{ name = MARS, prerequisites = { MOON, "ev-components" }, packs = 5, count = 30, time = 45, recipes = mars }
--- moon turf (issue #287: it came from the tier four microminer mission): a dig site like the Nether's soul sand; the
--- macerator and centrifuge steps are upstream's (its 52-microverse-module.lua), the metal mixture's centrifuge takes
--- the mixture (upstream: moon dust, a slip)
create_item{ skip_recipe = true, name = "compressed-moon-turf", subgroup = "subgroup-mining" }
create_item{ skip_recipe = true, name = "extraterrestrial-metal-mixture", subgroup = "subgroup-hv-centrifuge-recipes" }
create_item{ skip_recipe = true, name = "mysterious-crystal-dust", subgroup = "subgroup-hv-centrifuge-recipes" }
create_item{
	name = "moon-dust",
	category = "hv-macerator-recipes",
	energy_required = HV_SPEED * 4,
	ingredients = { item("compressed-moon-turf", 1) },
	results = { item("moon-dust", 9) },
}
create_recipe{
	recipe_name = "moon-dust-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 5,
	ingredients = { item("moon-dust", 1) },
	results = {
		{ type = "item", name = "stone-dust", amount = 1, probability = 0.25 },
		{ type = "item", name = "bauxite-dust", amount = 1, probability = 0.23 },
		{ type = "item", name = "silicon-dioxide", amount = 1, probability = 0.2 },
		{ type = "item", name = "quicklime", amount = 1, probability = 0.14 },
		{ type = "item", name = "molybdenum-dust", amount = 1, probability = 0.1 },
		{ type = "item", name = "extraterrestrial-metal-mixture", amount = 1, probability = 0.08 },
		fluid("deuterium", 10),
	},
	main_product = "deuterium",
}
create_recipe{
	recipe_name = "extraterrestrial-metal-mixture-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 50,
	ingredients = { item("extraterrestrial-metal-mixture", 1) },
	results = {
		{ type = "item", name = "ilmenite-dust", amount = 1, probability = 0.6 },
		{ type = "item", name = "chromium-dust", amount = 1, probability = 0.4 },
		{ type = "item", name = "pyrolusite-dust", amount = 1, probability = 0.35 },
		{ type = "item", name = "molybdenum-dust", amount = 1, probability = 0.22 },
		{ type = "item", name = "tungstate-dust", amount = 1, probability = 0.17 },
		{ type = "item", name = "mysterious-crystal-dust", amount = 1, probability = 0.1 },
	},
	main_product = "mysterious-crystal-dust",
}
unlock_in(MOON, { manual("digging-moon-turf", "manual-digsite-recipes", { item("iron-shovel-usage", 1), LABOR(2) },
	{ item("compressed-moon-turf", 7) }), "moon-dust", "moon-dust-centrifuging", "extraterrestrial-metal-mixture-centrifuging" })



--------------------------------------------------------------------------------
--- T3 AND T4 (issue #285): the asteroid belt and Jupiter's moons (GTNH's T3, here IV) and Venus (T4, here LuV).
--- GTNH's End asteroids (T0 there) hold the same naquadah, platinum and tungstate veins; they come here with the
--- asteroids. T5 (Titan, Enceladus, Oberon, Miranda) holds nothing the mod still needs from the microverse.
---   Asteroids: Platinum (cooperite = sheldonite, palladium, platinum; iridium left out), Naquadah (naquadah; enriched
---              naquadah left out)
---   Callisto:  CallistoIce (callisto ice; topaz, blue topaz, alduorite left out)
---   Europa:    Ledox (ledox; opal, orichalcum, rubracium left out)
---   Venus:     Quantium (quantium; amethyst, rutile, ardite left out)
--- Callisto ice and quantium come as dust, as the microminer gave them.
--------------------------------------------------------------------------------

local ASTEROIDS, JOVIAN, VENUS = "reach-the-asteroid-belt", "reach-the-jovian-moons", "reach-venus"
local asteroids = {
	manual("mining-platinum-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-sheldonite", 32), item("raw-palladium", 24), item("raw-platinum", 16) }),
	manual("mining-naquadah-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-naquadah", 32) }),
}
local jovian = {
	manual("mining-callisto-ice-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("callisto-ice-dust", 32) }),
	manual("mining-ledox-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("raw-ledox", 32) }),
}
local venus = {
	manual("mining-quantium-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) }, { item("quantium-dust", 32) }),
}
F.tech{ name = ASTEROIDS, prerequisites = { MARS, "iv-machines" }, packs = 6, count = 50, time = 60, recipes = asteroids }
F.tech{ name = JOVIAN, prerequisites = { ASTEROIDS }, packs = 6, count = 50, time = 60, recipes = jovian }
F.tech{ name = VENUS, prerequisites = { JOVIAN, "luv-machines" }, packs = 7, count = 50, time = 60, recipes = venus }



--------------------------------------------------------------------------------
--- ROSS128 (issue #293): bartworks' Ross128b, GTNH's T3 (DimensionHelper.java:118; Ross128ba, T5 at :130, holds the
--- same vein), here IV like the asteroid belt. Bornite's only source in GTNH:
---   CopperSulfits (OreMixes.java:1417-1426, Ross128ba :1516-1526): djurleite (primary), bornite (secondary),
---              wittichenite (in between), tetrahedrite (sporadic); djurleite and wittichenite left out
--- Ross128b's other veins hold no ore the mod lacks a source for (thorianite, carbon, bismuth, tungstate, turmaline,
--- roquesite, forsterite, hedenbergite, red zircon: their ores the mod has are uraninite, lepidolite, graphite, diamond,
--- coal, stibnite and scheelite, mined elsewhere), so they get no mine, as in #284/#285.
--------------------------------------------------------------------------------

local ROSS = "reach-ross128"
F.tech{ name = ROSS, prerequisites = { MARS, "iv-machines" }, packs = 6, count = 50, time = 60, recipes = {
	manual("mining-copper-sulfide-vein", "manual-mine-recipes", { PICKAXE, LABOR(24) },
		{ item("raw-bornite", 32), item("raw-tetrahedrite", 8) }),
} }



--------------------------------------------------------------------------------
--- THE VOID MINERS (issue #286, the decision of #154: the late ores come from GTNH's late ore machines; the
--- maintainer chose the Void Miner only, with its full ore pools). bartworks' Void Miner I, II and III
--- (bwcrossmod/galacticgreg/MTEVoidMinerBase.java, MTEVoidMiners.java, VoidMinerUtility.java):
---   * it mines the ore pool of the dimension it stands in: the GT veins of the dimension (primary and secondary at the
---     vein's weight, in-between and sporadic at an eighth) and its small ores (their amount), one ore per 10 ticks
---     times the tier (I 2, II 4, III 6 ores per second); a noble gas multiplies it (neon x4, krypton x8, xenon x16;
---     oganesson x64 is not in the mod), 2 L per second;
---   * Gregtorio has no dimensions, so a recipe per dimension stands for the dimension, and the tier decides which:
---     Void Miner I Pluto (GTNH's T7: black plutonium, neutronium, adamantium), II Barnard F (T8: bedrockium), III Horus
---     and Anubis (T9: cosmic neutronium, infinity catalyst); a higher tier also mines the lower dimensions, at its speed;
---   * a recipe is 10 s of mining (20 ores at tier I), the pool as outputs at GT's weights (expected amounts); ores the
---     mod lacks are left out, not replaced (VOID_POOLS, from GT5-Unofficial af993ca6a9 OreMixes.java and SmallOres.java).
--- The controllers are GT's assembly line recipes (bartworks AssemblyLine.java 27-44, TecTechResearchLoader.java 34-67)
--- with stand-ins for parts the mod lacks: the IV drilling rig for GT's Ore Drilling Plant IV, iridium frames for the
--- netherite frames, xenon for the oganesson of Void Miner III. 3x3 copies of the chemical reactor with a gas input, as
--- the other GT multiblocks of these files (159); sprites from GT's mining casings and the ore drill front.
--------------------------------------------------------------------------------

local VOID_POOLS = {
	["pluto"] = {
		{ "raw-ilmenite", 0.06721 }, { "raw-bauxite", 0.05072 }, { "raw-graphite", 0.05072 }, { "raw-naquadah", 0.04628 },
		{ "raw-thorium", 0.04042 }, { "raw-beryllium", 0.03804 }, { "raw-black-plutonium", 0.02916 },
		{ "raw-gold", 0.01775 }, { "raw-chromite", 0.01522 }, { "raw-vanadium-magnetite", 0.01268 },
		{ "raw-scheelite", 0.01268 }, { "raw-silver", 0.01268 }, { "raw-nickel", 0.0122 }, { "raw-neutronium", 0.01141 },
		{ "raw-silicon", 0.01014 }, { "raw-lead", 0.01014 }, { "raw-aluminium", 0.00634 }, { "raw-adamantium", 0.00634 },
		{ "raw-platinum", 0.00634 }, { "raw-tungstate", 0.00586 }, { "quantium-dust", 0.0038 },
		{ "raw-molybdenite", 0.00317 }, { "raw-diamond", 0.00317 }, { "raw-coal", 0.00317 }, { "raw-borax", 0.00317 },
		{ "raw-ledox", 0.00254 }, { "raw-emerald", 0.00238 }, { "raw-sheldonite", 0.00079 }, { "raw-palladium", 0.00079 },
	},
	["barnard-f"] = {
		{ "raw-redstone", 0.0641 }, { "raw-iron", 0.05128 }, { "raw-pitchblende", 0.04274 }, { "raw-graphite", 0.04274 },
		{ "raw-naquadah", 0.039 }, { "raw-thorium", 0.03405 }, { "raw-bastnasite", 0.03205 }, { "raw-beryllium", 0.03205 },
		{ "raw-realgar", 0.01976 }, { "raw-gold", 0.01896 }, { "raw-vanadium-magnetite", 0.01068 },
		{ "raw-grossular", 0.01068 }, { "raw-spessartine", 0.01068 }, { "raw-neutronium", 0.00962 },
		{ "raw-silicon", 0.00855 }, { "raw-copper", 0.00534 }, { "raw-uraninite", 0.00534 }, { "raw-adamantium", 0.00534 },
		{ "raw-nickel", 0.00427 }, { "raw-ruby", 0.00401 }, { "raw-cinnabar", 0.00401 },
		{ "raw-black-plutonium", 0.00321 }, { "raw-bedrockium", 0.00321 }, { "raw-diamond", 0.00267 },
		{ "raw-coal", 0.00267 }, { "raw-monazite", 0.002 }, { "raw-neodymium", 0.002 }, { "raw-emerald", 0.002 },
		{ "raw-pyrolusite", 0.00134 }, { "raw-tantalite", 0.00134 },
	},
	["horus"] = {
		{ "raw-certus-quartz", 0.10275 }, { "raw-black-plutonium", 0.03052 }, { "quantium-dust", 0.02186 },
		{ "raw-ledox", 0.02186 }, { "raw-barite", 0.01457 }, { "raw-neutronium", 0.01093 },
		{ "raw-cosmic-neutronium", 0.01093 }, { "raw-sulfur", 0.01002 }, { "raw-borax", 0.00364 },
		{ "raw-realgar", 0.00364 }, { "raw-emerald", 0.00146 }, { "raw-ruby", 0.00146 }, { "raw-bedrockium", 0.00137 },
	},
	["anubis"] = {
		{ "raw-sulfur", 0.17238 }, { "callisto-ice-dust", 0.03448 }, { "raw-galena", 0.03448 }, { "raw-silver", 0.03448 },
		{ "raw-neutronium", 0.01293 }, { "raw-adamantium", 0.01293 }, { "raw-sphalerite", 0.01077 },
		{ "raw-fullers-earth", 0.00862 }, { "raw-gypsum", 0.00862 }, { "raw-infinity-catalyst", 0.00679 },
		{ "raw-pentlandite", 0.00431 }, { "raw-lead", 0.00431 }, { "raw-cryolite", 0.00431 }, { "raw-scheelite", 0.00323 },
		{ "raw-tungstate", 0.00323 }, { "raw-cassiterite", 0.00215 }, { "raw-bedrockium", 0.00162 },
		{ "raw-bauxite", 0.00086 },
	},
}

local VM_PICKS = 20                -- ores per recipe at tier I (2 per second, 10 s)
local VM_GAS = { { nil, 1 }, { "neon", 4 }, { "krypton", 8 }, { "xenon", 16 } }
local VM_DIMS = { { "pluto", 1 }, { "barnard-f", 2 }, { "horus", 3 }, { "anubis", 3 } }
local VM_TECHS = { "void-miner-i", "void-miner-ii", "void-miner-iii" }

--- an output of the expected amount `e`
local function expected(name, e)
	if e < 1 then return { type = "item", name = name, amount = 1, probability = e } end
	local n = math.floor(e)
	local r = { type = "item", name = name, amount = n }
	if e - n > 0.001 then r.extra_count_fraction = e - n end
	return r
end

local vm_recipes = { {}, {}, {} }
for tier = 1, 3 do F.category("void-miner-" .. tier .. "-recipes") end
for _, d in pairs(VM_DIMS) do
	for _, g in pairs(VM_GAS) do
		local name = "void-mining-" .. d[1] .. (g[1] and ("-" .. g[1]) or "")
		local results = {}
		for _, o in pairs(VOID_POOLS[d[1]]) do results[#results + 1] = expected(o[1], VM_PICKS * g[2] * o[2]) end
		create_recipe{
			name = name,
			category = "void-miner-" .. d[2] .. "-recipes",
			energy_required = 10,
			subgroup = "subgroup-void-miner-" .. d[2] .. "-recipes",
			ingredients = g[1] and { fluid(g[1], 2) } or {},
			results = results,
			main_product = results[1].name,
			icon = "__gregtorio-continued__/graphics/icons/fork/void-miner-" .. ({ "i", "ii", "iii" })[d[2]] .. ".png",
		}
		local list = vm_recipes[d[2]]
		list[#list + 1] = name
	end
end

--- the machines
local function void_miner(tier, energy, recipe)
	local name = "void-miner-" .. ({ "i", "ii", "iii" })[tier]
	local m = table.deepcopy(data.raw["assembling-machine"]["hv-chemical-reactor"])
	m.name = name
	m.icons = nil
	m.icon = "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = name }
	local cats = {}
	for t = 1, tier do cats[#cats + 1] = "void-miner-" .. t .. "-recipes" end
	m.crafting_categories = cats
	m.crafting_speed = tier
	m.energy_usage = energy
	m.fast_replaceable_group = "fr-void-miner"
	m.next_upgrade = nil
	m.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fluid_boxes = { {
		production_type = "input", volume = 1000, pipe_covers = pipecoverspictures(), pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
	} }
	m.fluid_boxes_off_when_no_fluid_recipe = true
	m.graphics_set = {
		idle_animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-idle.png",
			width = 96, height = 96, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-working.png",
			width = 96, height = 96, frame_count = 1, shift = { 0, 0 } } } },
	}
	m.localised_description = { "entity-description." .. name }
	data:extend({ m })
	create_item{
		name = name,
		icon = m.icon,
		place_result = name,
		subgroup = ({ "subgroup-luv-age-multiblocks", "subgroup-zpm-age-multiblocks", "subgroup-uv-age-multiblocks" })[tier],
		stack_size = 10,
		category = recipe[1],
		energy_required = recipe[2],
		ingredients = recipe[3],
	}
	return name
end
local function parts(list)
	local out = {}
	for i = 1, #list, 2 do
		local n = list[i]
		out[#out + 1] = { type = data.raw.fluid[n] and "fluid" or "item", name = n, amount = list[i + 1] }
	end
	return out
end
local vm1 = void_miner(1, EU16_LuV, { "luv-assembly-line-recipes", 120 * LUV_SPEED, parts{
	"iv-drilling-rig", 1, "iridium-frame", 4, "europium-plate", 3, "luv-motor", 9, "luv-sensor", 9,
	"luv-field-generator", 9, "europium-screw", 36, "molten-indalloy-140", 144, "neon", 2000 } })
local vm2 = void_miner(2, EU16_ZPM, { "zpm-assembly-line-recipes", 120 * ZPM_SPEED, parts{
	vm1, 1, "black-plutonium-frame", 9, "black-plutonium-plate", 3, "zpm-motor", 9, "zpm-sensor", 9,
	"zpm-field-generator", 9, "black-plutonium-screw", 36, "molten-indalloy-140", 144, "krypton", 2000 } })
--- (the UV recipes of the assembly line run in the ZPM one, 127: there is no UV assembly line; issue #287 found the
--- category without a machine once the microminer missions no longer gave the Void Miner III's ores)
local vm3 = void_miner(3, EU16_UV, { "zpm-assembly-line-recipes", 120 * UV_SPEED, parts{
	vm2, 1, "neutronium-frame", 9, "neutronium-plate", 3, "uv-motor", 9, "uv-sensor", 9,
	"uv-field-generator", 9, "neutronium-screw", 36, "molten-indalloy-140", 144, "xenon", 2000 } })

F.tech{ name = VM_TECHS[1], prerequisites = { VENUS, "assembly-line", "luv-components" }, packs = 7, count = 50,
	time = 60, recipes = F.join({ vm1 }, vm_recipes[1]) }
F.tech{ name = VM_TECHS[2], prerequisites = { VM_TECHS[1], "zpm-assembly-line", "zpm-components",
	"crystal-processor-mainframes" }, packs = 8, count = 50, time = 60, recipes = F.join({ vm2 }, vm_recipes[2]) }
F.tech{ name = VM_TECHS[3], prerequisites = { VM_TECHS[2], "uv-components" }, packs = 9, count = 50, time = 60,
	recipes = F.join({ vm3 }, vm_recipes[3]) }
