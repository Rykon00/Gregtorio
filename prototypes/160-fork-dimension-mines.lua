--------------------------------------------------------------------------------
--- FORK DIMENSION MINES (issue #154's decision, part 1: issue #283): the materials of the microverse get a source of
--- their own, a mine per GT New Horizons dimension, gated by a technology that stands for reaching it at the voltage of
--- GTNH's rocket tier (gtneioreplugin DimensionHelper.java: the Nether and the End are T0). The microminer missions
--- keep working until the microverse goes (issue #287). Veins from GT5-Unofficial af993ca6a9 OreMixes.java.
---
--- Overworld (MV, with Eyes of Ender, the first consumer): ender pearls are a mob drop of Endermen in GTNH; Gregtorio
---   has no mobs before the EV entity crusher, so a manual hunting recipe like the manual mines gives them, and the
---   crusher crushes Endermen like the other mobs (the maintainer's decision).
--- The Nether (MV, technology Reach the Nether, before Eyes of Ender, which takes blaze rods):
---   * blaze rods: a mob drop (hunting, like the Endermen);
---   * the Molybdenum vein (Nether, End, Twilight Forest: wulfenite, molybdenite, molybdenum, powellite): molybdenite,
---     the one of them the mod has;
---   * soul sand (a Nether block): the dig site;
---   * nether air: GT++'s air intake hatch gives it in the Nether (MTEHatchAirIntake.java 41-53); here the compressor
---     next to the air collection, unlocked with the nether air distillation (End Steel).
--- The End (HV, technology Reach the End, after Eyes of Ender; before Radon, the first consumer of ender air):
---   * end stone (an End block) as compressed end stone;
---   * ender air in the compressor; its liquefaction and distillation move from EV Machines to Radon, so radon (the
---     quantum eye of the EV pack) comes from the End at HV (the maintainer's decision; GT's chemistry route, 8 plutonium
---     ingots, tiny uranium and air, is left out: the mod has neither plutonium ingots nor tiny uranium piles).
--- GTNH's End asteroids (naquadah, platinum, tungstate veins) come with the T3 dimensions (issue #285).
--- Loads after 159 and before 156 (data.lua).
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

--- the unlocks of an existing technology, and a prerequisite
local function unlock_in(tech, names)
	local t = data.raw.technology[tech]
	for _, n in pairs(names) do
		data.raw.recipe[n].enabled = false
		t.effects[#t.effects + 1] = { type = "unlock-recipe", recipe = n }
	end
end
local function require_tech(tech, prerequisite)
	local t = data.raw.technology[tech]
	t.prerequisites = t.prerequisites or {}
	t.prerequisites[#t.prerequisites + 1] = prerequisite
end
--- move recipes from whatever technology unlocks them to `tech`
local function move_unlocks(names, tech)
	local set = {}
	for _, n in pairs(names) do set[n] = true end
	for _, t in pairs(data.raw.technology) do
		if t.effects then
			local keep = {}
			for _, e in pairs(t.effects) do
				if not (e.type == "unlock-recipe" and set[e.recipe]) then keep[#keep + 1] = e end
			end
			t.effects = keep
		end
	end
	unlock_in(tech, names)
end

--------------------------------------------------------------------------------
--- OVERWORLD: Endermen
--------------------------------------------------------------------------------

local enderman = manual("hunting-endermen", "manual-mine-recipes", { LABOR(24) }, { item("ender-pearl", 4) })
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
	category = "lv-compressor-recipes",
	energy_required = 10,
	subgroup = "subgroup-lv-compressor-recipes",
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
	category = "lv-compressor-recipes",
	energy_required = 10,
	subgroup = "subgroup-lv-compressor-recipes",
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
--- Endermen with the first use of their pearls; blaze rods come before it
unlock_in("eyes-of-ender", { enderman })
require_tech("eyes-of-ender", NETHER)
unlock_in("extreme-entity-crushers", { "crushing-endermen" })
--- the airs with their first consumers
unlock_in("end-steel", { "nether-air-intake" })
require_tech("end-steel", NETHER)
require_tech("end-steel", END)
move_unlocks({ "ender-air-intake", "liquid-ender-air", "ender-air-distillation" }, "radon")
require_tech("radon", END)
require_tech("radon", "oil-processing")   -- the tall distillation tower of the ender air
--- the other first consumers of the Nether's materials
require_tech("ender-io", NETHER)
require_tech("tungstate-processing", NETHER)
--- the molybdenite chain (the ore chain of 155, the parts of 158) came with the microminer that gave the ore; now it
--- comes with the mine
do
	local moved = {}
	for _, e in pairs(data.raw.technology["tier-two-microminers"].effects or {}) do
		if e.type == "unlock-recipe" and e.recipe:find("molybden", 1, true) then moved[#moved + 1] = e.recipe end
	end
	move_unlocks(moved, NETHER)
end
