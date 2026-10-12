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
--- the monazite, neodymium and bastnasite chains (155, 158) came with the microminer that gave the ores; now with the
--- mine
do
	local moved = {}
	for _, e in pairs(data.raw.technology["tier-two-microminers"].effects or {}) do
		local r = e.type == "unlock-recipe" and e.recipe
		if r and not r:find("microminer", 1, true) and (r:find("monazite", 1, true) or r:find("neodymium", 1, true)
			or r:find("bastnasite", 1, true)) then
			moved[#moved + 1] = r
		end
	end
	move_unlocks(moved, MOON)
end
--- The ore chains of these ores (155: crushed, purified, centrifuged, impure and pure dust, their hammer, sifter and
--- separator steps; the lines that take them) were unlocked where the microminer made the raw ore, partly at MV. Now
--- the raw ore comes with the dimension: a chain step unlocked at a lower science tier than the dimension, or by one of
--- its prerequisites (a prerequisite there would close a loop), moves to it; any other technology that takes the ore
--- gets the dimension as a prerequisite (#252's tree rule). The gem grades of monazite (155) count as its forms.
local function packs(tech) return #(data.raw.technology[tech].unit.ingredients or {}) end
local function ancestors(tech, seen)
	seen = seen or {}
	for _, p in pairs(data.raw.technology[tech].prerequisites or {}) do
		if not seen[p] then seen[p] = true; ancestors(p, seen) end
	end
	return seen
end
local function ore_dimension(reach, ores)
	local forms = {}
	for _, x in pairs(ores) do
		for _, f in pairs({ "raw-%s", "crushed-%s", "purified-%s", "centrifuged-%s", "impure-%s-dust", "pure-%s-dust",
			"chipped-%s", "flawed-%s", "%s-gem", "flawless-%s", "exquisite-%s" }) do
			forms[f:format(x)] = true
		end
	end
	local takes = {}
	for name, r in pairs(data.raw.recipe) do
		if not name:find("microminer", 1, true) and not name:find("recycling", 1, true) then
			for _, i in pairs(r.ingredients or {}) do
				if forms[i.name] then takes[name] = true end
			end
		end
	end
	local move, needs = {}, {}
	local before = ancestors(reach)
	for tname, t in pairs(data.raw.technology) do
		if tname ~= reach then
			for _, e in pairs(t.effects or {}) do
				if e.type == "unlock-recipe" and takes[e.recipe] then
					if packs(tname) < packs(reach) or before[tname] then move[#move + 1] = e.recipe else needs[tname] = true end
				end
			end
		end
	end
	move_unlocks(move, reach)
	for tname in pairs(needs) do require_tech(tname, reach) end
end
ore_dimension(MOON, { "ilmenite", "chromite", "bauxite", "aluminium", "bastnasite", "monazite", "neodymium" })
ore_dimension(MARS, { "scheelite", "tungstate", "pitchblende", "uraninite" })
--- bauxite dust's electrolysis was aluminium's MV route; aluminium has its others (fuller's earth, lazurite, cryolite)
move_unlocks({ "bauxite-dust-electrolysis" }, MOON)
--- the implosion of monazite dust into gems belongs to the gem grades of the monazite from the Moon
move_unlocks({ "implosion-monazite-dust-to-gem" }, MOON)
--- the Bayer steps of bauxite slurry (Bauxite Slurry Process, an HV technology that Reach the End needs); the process's
--- lazurite and sodalite route stays there
move_unlocks({ "heated-bauxite-slurry", "heated-bauxite-slurry-reaction", "centrifuge-bauxite-slag" }, MOON)
--- End Steel melts neodymium ingots (in a blast furnace with neon, krypton, xenon): the dust comes from the Moon's ore
require_tech("end-steel", "neodymium")
