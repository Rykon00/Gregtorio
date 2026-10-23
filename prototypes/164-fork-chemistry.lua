--------------------------------------------------------------------------------
--- FORK CHEMISTRY: GT New Horizons' chemical lines Gregtorio lacked (the gap research after 0.5.4, issues #355 to #367;
--- GT5-Unofficial 638b3f37ca). Paths are relative to its src/main/java.
---
--- Rule of the file (as 159): GT's recipes and machines, fluids a tenth of GT's litres, items as GT's, times GT's
--- seconds x the speed of the recipe's tier (GT's EU/t decides the tier). GT++'s catalysts (orange metal catalyst, ...)
--- are left out, as Gregtorio's glue line (142) and the chemical plant recipes of 159 leave them out.
--- Loads after 159 (the ExxonMobil Chemical Plant and the dehydrators) and before 161 (data.lua).
--------------------------------------------------------------------------------

local F = FORK5B
local N, S = defines.direction.north, defines.direction.south

--- a recipe: category, GT seconds x the tier speed, ingredients, results (amount or { amount, probability })
local function step(list, name, category, seconds, speed, ingredients, results, main)
	local ing, res = {}, {}
	for _, i in pairs(ingredients) do
		ing[#ing + 1] = { type = data.raw.fluid[i[1]] and "fluid" or "item", name = i[1], amount = i[2] }
	end
	for _, r in pairs(results) do
		local x = { type = data.raw.fluid[r[1]] and "fluid" or "item", name = r[1], amount = r[2] }
		if r[3] then x.independent_probability = r[3] end
		res[#res + 1] = x
	end
	create_recipe{
		name = name,
		category = category,
		energy_required = seconds * speed,
		ingredients = ing,
		results = res,
		main_product = main or results[1][1],
	}
	list[#list + 1] = name
end

--- a fuel cell of 145's rocket engines: 800 L of the fuel, GT's value x 800 x 500 J (as the H8N4C2O4 cell of #295)
local function rocket_cell(fluid, eu_per_litre)
	create_item{
		name = fluid .. "-cell",
		category = "lv-canning-machine-recipes",
		energy_required = 4,
		fuel_category = "rocket-engine-fuel",
		fuel_value = string.format("%.1fMJ", eu_per_litre * 800 * 500 / 1e6),
		burnt_result = "empty-large-steel-fluid-cell",
		subgroup = data.raw.item["rocket-fuel-cell"].subgroup,
		ingredients = {
			{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
			{ type = "fluid", name = fluid, amount = 800 },
		},
	}
	return fluid .. "-cell"
end

--- move a recipe's unlock to another technology (#252: a producer goes up to its first consumer)
local function move_unlock(recipe, to)
	for _, t in pairs(data.raw.technology) do
		local keep = {}
		for _, e in pairs(t.effects or {}) do
			if not (e.type == "unlock-recipe" and e.recipe == recipe) then keep[#keep + 1] = e end
		end
		t.effects = keep
	end
	local effects = data.raw.technology[to].effects
	effects[#effects + 1] = { type = "unlock-recipe", recipe = recipe }
end

--------------------------------------------------------------------------------
--- 1) GT++'s ROCKET FUELS (issue #362): the three variants next to #295's H8N4C2O4 Rocket Fuel, from
--- gtPlusPlus/core/item/chemistry/RecipeLoaderRocketFuels.java (fuel values :179-183, EU per L: Rp-1 Rocket Fuel 512,
--- Dense Hydrazine Fuel Mixture 1024, CN3H7O3 Rocket Fuel 2048, H8N4C2O4 4196). Each gets a cell for the rocket engines
--- of 145 (fuel category rocket-engine-fuel). GTNH's chain behind them:
---   distillery: 25 diesel -> 15 kerosene (MV, 0.8 s); 2 kerosene -> 1.5 RP-1 (MV, 0.8 s)               (:52-67)
---   vacuum freezer: 100 oxygen -> 100 liquid oxygen (HV, 60 s; GT's oxygen cell,
---     gregtech/loaders/postload/recipes/VacuumFreezerRecipes.java:214-219)
---   chemical plant: 200 liquid oxygen + 50 RP-1 -> 150 Rp-1 Rocket Fuel (HV, 15 s)                      (:189-196)
---   hydrogen peroxide, GT++'s anthraquinone process (gtPlusPlus/core/item/chemistry/RecipeLoaderGenericChem.java
---   :403-485) with the coal tar of GT++ (gtPlusPlus/core/item/chemistry/RecipeLoaderCoalTar.java):
---     pyrolyse oven: 12 coal -> 220 coal tar, 2 small piles of dark ash (MV, 36 s); 32 charcoal -> 80 (MV, 18 s);
---       8 coke -> 340, 3 small piles of ash (HV, 18 s); Gregtorio has no small piles of ash: a dust at the chance of
---       the piles
---     distillation tower: 100 coal tar -> 60 coal tar oil, 15 naphtha, 20 ethylbenzene, 5 anthracene, 60 kerosene
---       (HV, 15 s)
---     chemical reactor: 800 coal tar oil + 800 sulfuric acid -> 1600 sulfuric coal tar oil (LV, 16 s); distillery:
---       2 sulfuric coal tar oil -> 2 naphthalene (LV, 1 s); chemical reactor: 5 lithium + 200 naphthalene -> 250
---       phthalic acid (LV, 16 s; GT++'s route, Gregtorio's own phthalic acid needs potassium dichromate at LuV)
---     dehydrator: 100 phthalic acid -> 15 phthalic anhydride (MV, 60 s); the MV Dehydrator comes with it (#252)
---     chemical reactor: 200 ethylene + 200 benzene -> 200 ethylbenzene (LV, 15 s)
---     chemical plant: 15 phthalic anhydride + 100 ethylbenzene -> 100 2-ethylanthraquinone (MV, 15 s); + 200 hydrogen
---       -> 100 2-ethylanthrahydroquinone (MV, 40 s); 500 of it + 2000 air (HV, 30 s) or 1000 oxygen (HV, 5 s) + 5
---       anthracene -> 500 2-ethylanthraquinone + 500 hydrogen peroxide
---   chemical plant: 100 hydrogen peroxide + 200 ammonia -> 100 hydrazine (MV, 30 s); carbon + 200 hydrogen + 100
---     hydrazine -> 100 monomethylhydrazine (HV, 48 s)                                                       (:81-104)
---   chemical plant: 400 hydrazine + 600 methanol -> 1000 Dense Hydrazine Fuel Mixture (HV, 30 s); 200
---     monomethylhydrazine + 100 nitric acid -> 200 CN3H7O3 Rocket Fuel (HV, 45 s)                         (:198-216)
--- The hydrogen peroxide recipes take three fluids and give two: the chemical plant of 159 gets a third input and two
--- more outputs (appended, so the boxes of its old recipes stay where they were).
--------------------------------------------------------------------------------

local ROCKET_RP1, ROCKET_HYDRAZINE = "rp-1-rocket-fuel", "hydrazine-rocket-fuels"
local CP = "chemical-plant-recipes"

--- (GT++'s colours, GTPPFluids.java:300-405, 0..1)
F.fluid("kerosene", "purple-fluid", { 0.59, 0.16, 0.59 })
F.fluid("rp-1", "medium-red-fluid", { 0.82, 0.20, 0.20 })
F.fluid("liquid-oxygen", "spackled-light-blue-fluid", { 0.38, 0.60, 0.95 })
F.fluid("rp-1-rocket-fuel", "medium-red-fluid", { 0.98, 0.20, 0.20 })
F.fluid("coal-tar", "black-fluid", { 0.20, 0.20, 0.20 })
F.fluid("coal-tar-oil", "olive-fluid", { 0.39, 0.39, 0.16 })
F.fluid("sulfuric-coal-tar-oil", "dark-muted-yellow-fluid", { 0.47, 0.47, 0.12 })
F.fluid("naphthalene", "nearly-white-fluid", { 0.82, 0.82, 0.78 })
F.fluid("ethylbenzene", "light-orange-fluid", { 0.94, 0.75, 0.55 })
F.fluid("anthracene", "pale-green-fluid", { 0.63, 0.78, 0.43 })
F.fluid("2-ethylanthraquinone", "dark-muted-yellow-fluid", { 0.89, 0.86, 0.49 })
F.fluid("2-ethylanthrahydroquinone", "pale-green-fluid", { 0.81, 0.88, 0.51 })
F.fluid("hydrogen-peroxide", "nearly-white-fluid", { 0.82, 1.00, 1.00 })
F.fluid("hydrazine", "nearly-white-fluid", { 0.98, 0.98, 0.98 })
F.fluid("monomethylhydrazine", "medium-gray-fluid", { 0.49, 0.49, 0.49 })
F.fluid("dense-hydrazine-fuel-mixture", "deep-pink-fluid", { 0.69, 0.31, 0.47 })
F.fluid("cn3h7o3-rocket-fuel", "purple-fluid", { 0.49, 0.29, 0.71 })
create_item{ skip_recipe = true, name = "phthalic-anhydride", subgroup = "subgroup-" .. CP }

--- the chemical plant's extra boxes (a third input north, two outputs south; 159 has inputs at (-1, -1) and (1, -1) and
--- the output at (0, 1))
do
	local plant = data.raw["assembling-machine"]["exxonmobil-chemical-plant"]
	local function port(kind, direction, position)
		return {
			production_type = kind, volume = 1000, pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures(),
			pipe_connections = { { flow_direction = kind, direction = direction, position = position } },
		}
	end
	plant.fluid_boxes[#plant.fluid_boxes + 1] = port("input", N, { 0, -1 })
	plant.fluid_boxes[#plant.fluid_boxes + 1] = port("output", S, { -1, 1 })
	plant.fluid_boxes[#plant.fluid_boxes + 1] = port("output", S, { 1, 1 })
end

local RECIPES = {}
step(RECIPES, "kerosene", "mv-distillation-recipes", 0.8, MV_SPEED, { { "diesel", 25 } }, { { "kerosene", 15 } })
step(RECIPES, "rp-1", "mv-distillation-recipes", 0.8, MV_SPEED, { { "kerosene", 2 } }, { { "rp-1", 1.5 } })
step(RECIPES, "liquid-oxygen", "hv-vacuum-freezer-recipes", 60, HV_SPEED, { { "oxygen", 100 } }, { { "liquid-oxygen", 100 } })
step(RECIPES, "rp-1-rocket-fuel", CP, 15, HV_SPEED, { { "liquid-oxygen", 200 }, { "rp-1", 50 } },
	{ { "rp-1-rocket-fuel", 150 } })
RECIPES[#RECIPES + 1] = rocket_cell("rp-1-rocket-fuel", 512)
F.tech{
	name = ROCKET_RP1, prerequisites = { "rocket-engines", "hv-energy-hatches" }, packs = 5, count = 400, time = 45,
	recipes = RECIPES,
}

RECIPES = {}
step(RECIPES, "coal-tar-from-coal", "pyrolyse-oven-recipes", 36, MV_SPEED, { { "coal", 12 } },
	{ { "coal-tar", 220 }, { "dark-ash-dust", 1, 0.5 } })
step(RECIPES, "coal-tar-from-charcoal", "pyrolyse-oven-recipes", 18, MV_SPEED, { { "charcoal", 32 } }, { { "coal-tar", 80 } })
step(RECIPES, "coal-tar-from-coke", "pyrolyse-oven-recipes", 18, HV_SPEED, { { "coke", 8 } },
	{ { "coal-tar", 340 }, { "ash-dust", 1, 0.75 } })
step(RECIPES, "coal-tar-distillation", "hv-tall-distillation-recipes", 15, HV_SPEED, { { "coal-tar", 100 } },
	{ { "coal-tar-oil", 60 }, { "naphtha", 15 }, { "ethylbenzene", 20 }, { "anthracene", 5 }, { "kerosene", 60 } },
	"coal-tar-oil")
step(RECIPES, "sulfuric-coal-tar-oil", "lv-chemical-reactor-recipes", 16, LV_SPEED,
	{ { "coal-tar-oil", 800 }, { "sulfuric-acid", 800 } }, { { "sulfuric-coal-tar-oil", 1600 } })
step(RECIPES, "naphthalene", "lv-distillation-recipes", 1, LV_SPEED, { { "sulfuric-coal-tar-oil", 2 } },
	{ { "naphthalene", 2 } })
step(RECIPES, "phthalic-acid-from-naphthalene", "lv-chemical-reactor-recipes", 16, LV_SPEED,
	{ { "lithium", 5 }, { "naphthalene", 200 } }, { { "phthalic-acid", 250 } })
step(RECIPES, "phthalic-anhydride", "mv-dehydrator-recipes", 60, MV_SPEED, { { "phthalic-acid", 100 } },
	{ { "phthalic-anhydride", 15 } })
step(RECIPES, "ethylbenzene", "lv-chemical-reactor-recipes", 15, LV_SPEED, { { "ethylene", 200 }, { "benzene", 200 } },
	{ { "ethylbenzene", 200 } })
step(RECIPES, "2-ethylanthraquinone", CP, 15, MV_SPEED, { { "phthalic-anhydride", 15 }, { "ethylbenzene", 100 } },
	{ { "2-ethylanthraquinone", 100 } })
step(RECIPES, "2-ethylanthrahydroquinone", CP, 40, MV_SPEED, { { "2-ethylanthraquinone", 100 }, { "hydrogen", 200 } },
	{ { "2-ethylanthrahydroquinone", 100 } })
step(RECIPES, "hydrogen-peroxide-from-air", CP, 30, HV_SPEED,
	{ { "air", 2000 }, { "2-ethylanthrahydroquinone", 500 }, { "anthracene", 5 } },
	{ { "hydrogen-peroxide", 500 }, { "2-ethylanthraquinone", 500 } })
step(RECIPES, "hydrogen-peroxide", CP, 5, HV_SPEED,
	{ { "oxygen", 1000 }, { "2-ethylanthrahydroquinone", 500 }, { "anthracene", 5 } },
	{ { "hydrogen-peroxide", 500 }, { "2-ethylanthraquinone", 500 } })
step(RECIPES, "hydrazine", CP, 30, MV_SPEED, { { "hydrogen-peroxide", 100 }, { "ammonia", 200 } }, { { "hydrazine", 100 } })
step(RECIPES, "monomethylhydrazine", CP, 48, HV_SPEED, { { "carbon", 1 }, { "hydrogen", 200 }, { "hydrazine", 100 } },
	{ { "monomethylhydrazine", 100 } })
step(RECIPES, "dense-hydrazine-fuel-mixture", CP, 30, HV_SPEED, { { "hydrazine", 400 }, { "methanol", 600 } },
	{ { "dense-hydrazine-fuel-mixture", 1000 } })
step(RECIPES, "cn3h7o3-rocket-fuel", CP, 45, HV_SPEED, { { "monomethylhydrazine", 200 }, { "nitric-acid", 100 } },
	{ { "cn3h7o3-rocket-fuel", 200 } })
RECIPES[#RECIPES + 1] = rocket_cell("dense-hydrazine-fuel-mixture", 1024)
RECIPES[#RECIPES + 1] = rocket_cell("cn3h7o3-rocket-fuel", 2048)
F.tech{
	name = ROCKET_HYDRAZINE, prerequisites = { "rocket-engines", "pyrolyse-oven", "mv-tier-electrolysis" }, packs = 5,
	count = 600, time = 45, recipes = RECIPES,
}
move_unlock("mv-dehydrator", ROCKET_HYDRAZINE)

--------------------------------------------------------------------------------
--- 2) BIO FUELS, THE BREWERY AND THE FERMENTER (issue #360; the machines are 101's, LV to EV, IV to MAX through
--- IV_BASIC_MACHINES). GTNH's recipes, GT's numbers (fluids a tenth of GT's litres):
---   brewery (gregtech/loaders/postload/recipes/BreweryRecipes.java:29-90): a talc, soapstone or redstone dust and 75
---     creosote, seed oil or crude oil -> 75 lubricant (6.4 s, 4 EU/t); GT's light, medium and heavy oil variants are left
---     out (the pump modules' oils of 162 come at IV and have their own lubricant, #318; medium oil is #361's);
---     (:458-476) 1 bio chaff + 100 water -> 100 biomass (8.5 s), or + 50 distilled water (0.5 s); GT's potions are n/a
---   fermenter (FermenterRecipes.java:20-33): 10 biomass -> 10 fermented biomass (7.5 s, 2 EU/t)
---   distillery (DistilleryRecipes.java:175-245, ULV, 75 s): 100 fermented biomass -> 2.5 acetic acid, 37.5 water, 15
---     ethanol, 15 methanol, 10 ammonia, 40 carbon dioxide or 60 methane; distillation tower (:588-604, MV, 3.75 s): all
---     seven at once (GT's CropsNH fertilizer and IC2's biogas are left out)
---   the Extreme Industrial Greenhouse's wheat gives its seeds too (64, a seed per wheat; GTNH's crops drop at least one
---     seed past the replanted one), the fluid extractor 1 seed oil from a seed (FluidExtractorRecipes.java:449-452,
---     1.6 s)
---   chemical reactor (ChemicalRecipes.java:3474-3500, GT's x9 recipe: GT's x1 takes a tiny pile of sodium hydroxide,
---     which Gregtorio lacks): a sodium hydroxide dust + 540 seed oil + 90 methanol or ethanol -> 540 bio diesel + 90
---     glycerol (270 s, LV); glycerol + hydrochloric acid -> epichlorohydrin + 2 water (ChemicalRecipes.java:1866-1893,
---     24 s, LV), GTNH's second route next to Gregtorio's from propene
---   bio diesel burns at 320 EU/L (MaterialsInit.java loadBioDiesel), a cell of 800 at 500 J per EU as Gregtorio's diesel
---     cell (128 MJ) in the combustion generators, glycerol at 164 EU/L in the semi-fluid generators (65.6 MJ); GT's large chemical reactor turns 1000 of it and 40 tetranitromethane
---     into 900 cetane-boosted diesel (GT's nitro fuel, ChemicalRecipes.java:5738-5744, HV, 6 s)
--------------------------------------------------------------------------------

local FERMENTATION = "fermentation"
F.fluid("seed-oil", "medium-green-fluid", { 0.77, 1.00, 0.00 })
F.fluid("bio-diesel", "orange-fluid", { 1.00, 0.50, 0.00 })
F.fluid("glycerol", "pale-green-fluid", { 0.53, 0.87, 0.53 })
F.fluid("fermented-biomass", "olive-fluid", { 0.27, 0.33, 0.00 })
create_item{ skip_recipe = true, name = "wheat-seeds", subgroup = data.raw.item["wheat"].subgroup }
do
	local r = data.raw.recipe["growing-wheat"]
	if not (r.icon or r.icons or r.main_product) then r.main_product = "wheat" end
	r.results[#r.results + 1] = { type = "item", name = "wheat-seeds", amount = 64 }
end

RECIPES = { "lv-brewery", "lv-fermenter" }
for _, dust in pairs({ "talc-dust", "soapstone-dust", "redstone-dust" }) do
	for _, oil in pairs({ "creosote", "seed-oil", "crude-oil" }) do
		step(RECIPES, "lubricant-from-" .. oil .. "-and-" .. dust, "lv-brewery-recipes", 6.4, LV_SPEED,
			{ { dust, 1 }, { oil, 75 } }, { { "lubricant", 75 } })
	end
end
step(RECIPES, "biomass-from-bio-chaff", "lv-brewery-recipes", 8.5, LV_SPEED, { { "bio-chaff", 1 }, { "water", 100 } },
	{ { "biomass", 100 } })
step(RECIPES, "biomass-from-bio-chaff-distilled-water", "lv-brewery-recipes", 0.5, LV_SPEED,
	{ { "bio-chaff", 1 }, { "distilled-water", 50 } }, { { "biomass", 100 } })
step(RECIPES, "fermented-biomass", "lv-fermenter-recipes", 7.5, LV_SPEED, { { "biomass", 10 } }, { { "fermented-biomass", 10 } })
for _, o in pairs({ { "acetic-acid", 2.5 }, { "water", 37.5 }, { "ethanol", 15 }, { "methanol", 15 }, { "ammonia", 10 },
	{ "carbon-dioxide", 40 }, { "methane", 60 } }) do
	step(RECIPES, o[1] .. "-from-fermented-biomass", "lv-distillation-recipes", 75, LV_SPEED, { { "fermented-biomass", 100 } },
		{ o })
end
step(RECIPES, "fermented-biomass-distillation", "mv-tall-distillation-recipes", 3.75, MV_SPEED,
	{ { "fermented-biomass", 100 } }, { { "acetic-acid", 2.5 }, { "water", 37.5 }, { "ethanol", 15 }, { "methanol", 15 },
		{ "ammonia", 10 }, { "carbon-dioxide", 40 }, { "methane", 60 } }, "ethanol")
step(RECIPES, "seed-oil", "lv-fluid-extractor-recipes", 1.6, LV_SPEED, { { "wheat-seeds", 1 } }, { { "seed-oil", 1 } })
for _, alc in pairs({ "methanol", "ethanol" }) do
	step(RECIPES, "bio-diesel-with-" .. alc, "lv-chemical-reactor-recipes", 270, LV_SPEED,
		{ { "sodium-hydroxide", 1 }, { "seed-oil", 540 }, { alc, 90 } }, { { "bio-diesel", 540 }, { "glycerol", 90 } })
end
step(RECIPES, "epichlorohydrin-from-glycerol", "lv-chemical-reactor-recipes", 24, LV_SPEED,
	{ { "glycerol", 100 }, { "hydrochloric-acid", 100 } }, { { "epichlorohydrin", 100 }, { "water", 200 } })
create_item{
	name = "bio-diesel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "128MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	subgroup = data.raw.item["diesel-cell"].subgroup,
	ingredients = {
		{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
		{ type = "fluid", name = "bio-diesel", amount = 800 },
	},
}
RECIPES[#RECIPES + 1] = "bio-diesel-cell"
--- issue #449: the LV Combustion Generator (101) comes with the first combustion fuel of LV
RECIPES[#RECIPES + 1] = "lv-combustion-generator"
--- glycerol is GT's semi-fluid fuel (164 EU per L): a cell for the semi-fluid generators like the creosote cell (65.6 MJ)
create_item{
	name = "glycerol-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "semifluid-generator-fuel",
	fuel_value = "65.6MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	subgroup = data.raw.item["creosote-cell"].subgroup,
	ingredients = {
		{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
		{ type = "fluid", name = "glycerol", amount = 800 },
	},
}
RECIPES[#RECIPES + 1] = "glycerol-cell"
F.tech{
	name = FERMENTATION, prerequisites = { "polyethylene", "hydrochloric-acid", "extractor" }, packs = 2, count = 60,
	time = 30, recipes = RECIPES,
}
--- the nitro fuel with GT's other cetane-boosted diesel (its technology gets Fermentation as a prerequisite)
RECIPES = {}
step(RECIPES, "cetane-boosted-diesel-from-bio-diesel", "hv-chemical-reactor-recipes", 6, HV_SPEED,
	{ { "bio-diesel", 1000 }, { "tetranitromethane", 40 } }, { { "cetane-boosted-diesel", 900 } })
for _, r in pairs(RECIPES) do fork_add_unlock("cetane-boosted-diesel", r) end
table.insert(data.raw.technology["cetane-boosted-diesel"].prerequisites, FERMENTATION)

--------------------------------------------------------------------------------
--- 3) THE POLYMER LADDER (issue #358): GTNH's polymers Gregtorio lacked and the epoxy route through bisphenol A
--- (gregtech/loaders/postload/recipes/ChemicalRecipes.java; fluids a tenth of GT's litres, a polymer's 144 L ingot is 14.4):
---   epoxy: benzene + propene + 12.5 phosphoric acid -> cumene (:4308-4314, 12 s, LV); cumene + 200 oxygen -> phenol and
---     acetone (:1954-1995, 8 s); acetone + 200 phenol + hydrochloric acid -> bisphenol A + water (:4316-4342, 8 s); bisphenol
---     A + 200 epichlorohydrin + 6 sodium hydroxide -> epoxy + 200 salt water (:1996-2003, 10 s). Upstream's one-step epoxy
---     recipe (17) is GT's large chemical reactor recipe (:5327-5337) in the small reactor and stays.
---   polystyrene: benzene + ethylene -> styrene + 200 hydrogen (:3300-3316, 6 s, LV); GT's default polymerization
---     (:3940-3990, :4017): 14.4 styrene + 100 air -> 14.4 polystyrene, or + 100 oxygen -> 21.6 (8 s), as Gregtorio's
---     polyethylene; its sheet in the fluid solidifier like the polyethylene sheet. GT's only uses (the Bio Lab's petri
---     dish, the QFT's plastics recipe) are not in Gregtorio.
---   styrene-butadiene rubber: 35 styrene + 100 butadiene + 500 air -> 9 raw SBR dust, or + 500 oxygen -> 13 (:4479-4524,
---     8 s, MV); 9 raw SBR + sulfur -> 129.6 SBR (:3321-3326, 30 s, LV); its sheet; GT's cable insulation
---     (gregtech/loaders/oreprocessing/ProcessingWire.java:265-310): SBR takes the place of rubber at three quarters of its
---     amount and of silicone rubber at one and a half times, in every cable recipe of the assembler that takes them
--------------------------------------------------------------------------------

local POLYSTYRENE, SBR = "polystyrene", "styrene-butadiene-rubber"
F.fluid("cumene", "rust-brown-fluid", { 0.33, 0.13, 0.00 })
F.fluid("bisphenol-a", "dark-muted-yellow-fluid", { 0.83, 0.67, 0.00 })
F.fluid("styrene", "nearly-white-fluid", { 0.82, 0.78, 0.75 })
F.fluid("polystyrene", "medium-gray-fluid", { 0.75, 0.71, 0.67 })
F.fluid("styrene-butadiene-rubber", "black-fluid", { 0.13, 0.10, 0.09 })
for _, name in pairs({ "polystyrene-sheet", "raw-styrene-butadiene-rubber-dust", "styrene-butadiene-rubber-sheet" }) do
	create_item{ skip_recipe = true, name = name, subgroup = data.raw.item["polyethylene-sheet"].subgroup }
end

--- the technologies of a recipe and a test whether one technology lies on the path to another
local function techs_of(recipe)
	local out = {}
	for name, t in pairs(data.raw.technology) do
		for _, e in pairs(t.effects or {}) do
			if e.type == "unlock-recipe" and e.recipe == recipe then out[#out + 1] = name end
		end
	end
	return out
end
local function leads_to(from, to)
	local seen, stack = {}, { to }
	while #stack > 0 do
		local n = table.remove(stack)
		if n == from then return true end
		if not seen[n] then
			seen[n] = true
			for _, p in pairs((data.raw.technology[n] or {}).prerequisites or {}) do stack[#stack + 1] = p end
		end
	end
	return false
end
--- the first technology after both (the one of them that leads to the other, else the technology with the fewest
--- ancestors that has both before it)
local function after_both(a, b)
	if leads_to(a, b) then return b end
	if leads_to(b, a) then return a end
	local best, best_n
	for name, t in pairs(data.raw.technology) do
		if not t.hidden and t.enabled ~= false and leads_to(a, name) and leads_to(b, name) then
			local n, seen, stack = 0, {}, { name }
			while #stack > 0 do
				local x = table.remove(stack)
				if not seen[x] then
					seen[x] = true
					n = n + 1
					for _, p in pairs((data.raw.technology[x] or {}).prerequisites or {}) do stack[#stack + 1] = p end
				end
			end
			if not best or n < best_n or (n == best_n and name < best) then best, best_n = name, n end
		end
	end
	return best
end

RECIPES = {}
step(RECIPES, "cumene", "lv-chemical-reactor-recipes", 12, LV_SPEED,
	{ { "benzene", 100 }, { "propene", 100 }, { "phosphoric-acid", 12.5 } }, { { "cumene", 100 } })
step(RECIPES, "phenol-and-acetone-from-cumene", "lv-chemical-reactor-recipes", 8, LV_SPEED,
	{ { "cumene", 100 }, { "oxygen", 200 } }, { { "phenol", 100 }, { "acetone", 100 } }, "phenol")
step(RECIPES, "bisphenol-a", "lv-chemical-reactor-recipes", 8, LV_SPEED,
	{ { "acetone", 100 }, { "phenol", 200 }, { "hydrochloric-acid", 100 } }, { { "bisphenol-a", 100 }, { "water", 100 } })
step(RECIPES, "epoxy-from-bisphenol-a", "lv-chemical-reactor-recipes", 10, LV_SPEED,
	{ { "sodium-hydroxide", 6 }, { "bisphenol-a", 100 }, { "epichlorohydrin", 200 } },
	{ { "epoxy", 100 }, { "salt-water", 200 } })
F.tech{
	name = "bisphenol-a", prerequisites = { "epoxy-processing", "phosphorus-processing" }, packs = 3, count = 60, time = 30,
	recipes = RECIPES,
}

RECIPES = {}
step(RECIPES, "styrene", "lv-chemical-reactor-recipes", 6, LV_SPEED, { { "benzene", 100 }, { "ethylene", 100 } },
	{ { "styrene", 100 }, { "hydrogen", 200 } })
step(RECIPES, "polystyrene-from-air", "lv-chemical-reactor-recipes", 8, LV_SPEED, { { "styrene", 14.4 }, { "air", 100 } },
	{ { "polystyrene", 14.4 } })
step(RECIPES, "polystyrene", "lv-chemical-reactor-recipes", 8, LV_SPEED, { { "styrene", 14.4 }, { "oxygen", 100 } },
	{ { "polystyrene", 21.6 } })
step(RECIPES, "polystyrene-sheet", "lv-fluid-solidifier-recipes", 1, LV_SPEED, { { "polystyrene", 14.4 } },
	{ { "polystyrene-sheet", 1 } })
F.tech{
	name = POLYSTYRENE, prerequisites = { "polyethylene", "gas-turbine" }, packs = 2, count = 60, time = 30, recipes = RECIPES,
}

RECIPES = {}
step(RECIPES, "raw-styrene-butadiene-rubber-from-air", "mv-chemical-reactor-recipes", 8, MV_SPEED,
	{ { "styrene", 35 }, { "butadiene", 100 }, { "air", 500 } }, { { "raw-styrene-butadiene-rubber-dust", 9 } })
step(RECIPES, "raw-styrene-butadiene-rubber", "mv-chemical-reactor-recipes", 8, MV_SPEED,
	{ { "styrene", 35 }, { "butadiene", 100 }, { "oxygen", 500 } }, { { "raw-styrene-butadiene-rubber-dust", 13 } })
step(RECIPES, "styrene-butadiene-rubber", "lv-chemical-reactor-recipes", 30, LV_SPEED,
	{ { "raw-styrene-butadiene-rubber-dust", 9 }, { "sulfur", 1 } }, { { "styrene-butadiene-rubber", 129.6 } })
step(RECIPES, "styrene-butadiene-rubber-sheet", "lv-fluid-solidifier-recipes", 1, LV_SPEED,
	{ { "styrene-butadiene-rubber", 14.4 } }, { { "styrene-butadiene-rubber-sheet", 1 } })
F.tech{
	name = SBR, prerequisites = { POLYSTYRENE, "oil-processing" }, packs = 4, count = 80, time = 30,
	recipes = RECIPES,
}
--- polycaprolactam (nylon): GT makes it straight from saltpeter and naphtha (ChemicalRecipes.java:304-311: a saltpeter
--- dust + 576 L naphtha -> 1296 L and a tiny pile of potassium, 32 s, LV; here the potassium dust at a ninth); its sheet.
--- GT's uses (vanilla string, goodgenerator's fluid storage cores) are not in Gregtorio.
F.fluid("polycaprolactam", "nearly-white-fluid", { 0.20, 0.20, 0.20 })
create_item{ skip_recipe = true, name = "polycaprolactam-sheet", subgroup = data.raw.item["polyethylene-sheet"].subgroup }
RECIPES = {}
step(RECIPES, "polycaprolactam", "lv-chemical-reactor-recipes", 32, LV_SPEED, { { "saltpeter", 1 }, { "naphtha", 57.6 } },
	{ { "polycaprolactam", 129.6 }, { "potassium", 1, 1 / 9 } })
step(RECIPES, "polycaprolactam-sheet", "lv-fluid-solidifier-recipes", 1, LV_SPEED, { { "polycaprolactam", 14.4 } },
	{ { "polycaprolactam-sheet", 1 } })
F.tech{
	name = "polycaprolactam", prerequisites = { POLYSTYRENE, "implosion-compressor" }, packs = 3, count = 60, time = 30,
	recipes = RECIPES,
}
--- the cable recipes: a twin with SBR for every cable recipe of the assembler that takes liquid or silicone rubber; it comes
--- with the first technology after both the base recipe's and SBR's
do
	local made, skipped = 0, 0
	local names = {}
	for name in pairs(data.raw.recipe) do names[#names + 1] = name end
	table.sort(names)
	for _, name in pairs(names) do
		local r = data.raw.recipe[name]
		local out = r.results and r.results[1] and r.results[1].name or ""
		if fork_has_category(r, "lv-assembling-machine-recipes") and out:match("%-cable$") and #r.results == 1 then
			local ing, found = table.deepcopy(r.ingredients), false
			for _, i in pairs(ing) do
				if i.name == "liquid-rubber" then i.name, i.amount, found = SBR, i.amount * 0.75, true
				elseif i.name == "silicone-rubber" then i.name, i.amount, found = SBR, i.amount * 1.5, true end
			end
			if found then
				local base = techs_of(name)[1]
				local tech = base == nil and SBR or after_both(SBR, base)
				if tech then
					create_recipe{ name = name .. "-sbr", category = fork_category(r), energy_required = r.energy_required,
						ingredients = ing, results = table.deepcopy(r.results), main_product = out }
					fork_add_unlock(tech, name .. "-sbr")
					data.raw.recipe[name .. "-sbr"].enabled = false
					made = made + 1
				else
					skipped = skipped + 1
					log("FORK-CHEMISTRY: no technology after " .. SBR .. " and " .. tostring(base) .. " for " .. name .. "-sbr")
				end
			end
		end
	end
	log("FORK-CHEMISTRY: " .. made .. " cable recipes with styrene-butadiene rubber, " .. skipped
		.. " skipped (no technology after both)")
end

--------------------------------------------------------------------------------
--- 4) OIL VARIETY (issue #361). The decision: GTNH's Overworld pool of underground fluids
--- (gregtech/api/objects/GTUODimensionList.java:128-166: natural gas, light oil, raw oil, heavy oil and oil, each at a
--- 20 % chance, up to 350, 350, 625, 625 and 625 buckets) as recipes of the drilling rigs next to the crude oil one
--- (100 crude oil in 4 s for GT's 625; the others at their share of it), instead of a fluid vein per rig: Gregtorio's rigs
--- have no veins, the player picks the fluid.
---   raw oil (GT's OilMedium) is distilled like 162's heavy and light oil (#318: half of GT's 100 L universal distillation,
---     DistilleryRecipes.java:666-672: 10 heavy fuel, 50 light fuel, 150 naphtha, 60 gas in 20 ticks; lubricant 12 -> 6)
---   light and heavy oil come at MV now: their distillation and lubricant recipes move from the pump module (#318) to the
---     technologies of crude oil's (Oil Processing, Diesel)
---   natural gas: GT's hydrodesulfurization into refinery gas (ChemicalRecipes.java:205-213: 2000 natural gas + 250
---     hydrogen -> 2000 refinery gas + 125 hydrogen sulfide, 1 s, LV), a gas turbine fuel (20 EU/L, MaterialsInit.java)
---   LPG from propane (CentrifugeRecipes.java:706-710: 320 -> 290, 1 s, LV), a gas turbine fuel (320 EU/L)
---   GT's MTBE route to the anti-knock agent: methanol + butene -> MTBE reaction mixture (ChemicalRecipes.java:5815-5822,
---     MixerRecipes.java:1393-1398: 1 s, HV), its distillation into 400 anti-knock, 500 methanol, 400 butene per 900
---     (DistilleryRecipes.java:567-575, 2 s, MV); GT's butane variant waits for butane, which the mod lacks
--- GT's MTBE and "regular/premium gasoline" of the issue are GT's MTBE mixtures and its gasoline and high octane gasoline,
--- which Gregtorio has (147); extra heavy oil is no Overworld fluid.
--------------------------------------------------------------------------------

F.fluid("medium-oil", "black-fluid", { 0.00, 1.00, 0.00 })
F.fluid("natural-gas", "spackled-light-blue-fluid", { 0.00, 1.00, 1.00 })
F.fluid("lpg", "light-orange-fluid", { 1.00, 1.00, 0.00 })
F.fluid("mtbe-reaction-mixture", "nearly-white-fluid", { 1.00, 1.00, 1.00 })

RECIPES = {}
for _, r in pairs({ { "light-oil", 56 }, { "medium-oil", 100 }, { "heavy-oil", 100 }, { "natural-gas", 56 } }) do
	step(RECIPES, r[1] .. "-drilling-rig", "drilling-rig-recipes", 4, 1, {}, { { r[1], r[2] } })
end
for _, r in pairs(RECIPES) do fork_add_unlock("oil-gathering", r) end
local CRUDE_TIME = 20   -- 162's oil-distillation (GT's 30 ticks)
RECIPES = {}
step(RECIPES, "medium-oil-distillation", "mv-tall-distillation-recipes", CRUDE_TIME * 20 / 30, 1, { { "medium-oil", 50 } },
	{ { "sulfuric-gas", 30 }, { "sulfuric-heavy-fuel", 5 }, { "sulfuric-light-fuel", 25 }, { "sulfuric-naphtha", 75 } },
	"sulfuric-naphtha")
step(RECIPES, "natural-gas-desulfurization", "lv-chemical-reactor-recipes", 1, LV_SPEED,
	{ { "natural-gas", 200 }, { "hydrogen", 25 } }, { { "refinery-gas", 200 }, { "hydrogen-sulfide", 12.5 } })
for _, r in pairs(RECIPES) do fork_add_unlock("oil-processing", r) end
RECIPES = {}
step(RECIPES, "medium-oil-distillation-light", "mv-distillation-recipes", CRUDE_TIME * 20 / 30, 1, { { "medium-oil", 50 } },
	{ { "sulfuric-light-fuel", 25 } })
step(RECIPES, "medium-oil-distillation-heavy", "mv-distillation-recipes", CRUDE_TIME * 20 / 30, 1, { { "medium-oil", 50 } },
	{ { "sulfuric-heavy-fuel", 5 } })
step(RECIPES, "medium-oil-lubricant", "mv-distillation-recipes", 16 / 20 * 40 / 12, 1, { { "medium-oil", 40 } },
	{ { "lubricant", 20 } })
for _, r in pairs(RECIPES) do fork_add_unlock("diesel", r) end
--- light and heavy oil (162, #318) with crude oil's technologies
for _, o in pairs({ "light-oil", "heavy-oil" }) do
	move_unlock(o .. "-distillation", "oil-processing")
	for _, suffix in pairs({ "-distillation-light", "-distillation-heavy", "-lubricant" }) do move_unlock(o .. suffix, "diesel") end
end
--- the gas fuels' cells (GT EU/L x 800 x 500 J, as 15's propane cell)
local function gas_cell(fluid, eu)
	create_item{
		name = fluid .. "-cell",
		category = "lv-canning-machine-recipes",
		energy_required = 4,
		fuel_category = "gas-turbine-fuel",
		fuel_value = string.format("%.1fMJ", eu * 800 * 500 / 1e6),
		burnt_result = "empty-large-steel-fluid-cell",
		subgroup = data.raw.item["propane-cell"].subgroup,
		ingredients = {
			{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
			{ type = "fluid", name = fluid, amount = 800 },
		},
	}
	return fluid .. "-cell"
end
fork_add_unlock("oil-gathering", gas_cell("natural-gas", 20))
RECIPES = {}
step(RECIPES, "lpg", "lv-centrifuge-recipes", 1, LV_SPEED, { { "propane", 32 } }, { { "lpg", 29 } })
RECIPES[#RECIPES + 1] = gas_cell("lpg", 320)
for _, r in pairs(RECIPES) do fork_add_unlock("more-gas-turbine-fuels", r) end
RECIPES = {}
step(RECIPES, "mtbe-reaction-mixture", "hv-mixer-recipes", 1, HV_SPEED, { { "methanol", 100 }, { "butene", 100 } },
	{ { "mtbe-reaction-mixture", 100 } })
step(RECIPES, "mtbe-reaction-mixture-distillation", "mv-tall-distillation-recipes", 2, MV_SPEED,
	{ { "mtbe-reaction-mixture", 90 } }, { { "anti-knock-agent", 40 }, { "methanol", 50 }, { "butene", 40 } },
	"anti-knock-agent")
for _, r in pairs(RECIPES) do fork_add_unlock("high-octane-gasoline", r) end

--------------------------------------------------------------------------------
--- 5) SIDE-CHAIN CHEMISTRY (issue #366: each piece with the line that needs it). Of the issue's list, Gregtorio has a
--- consumer for trichlorosilane only: GTNH's second route to the solar grade silicon of the boules (poly-si dust;
--- gregtech/loaders/postload/recipes/ChemicalRecipes.java:4248-4254: silicon + 3000 L hydrochloric acid -> trichlorosilane +
--- 2 hydrogen, 15 s, LV; :713-729: trichlorosilane + 2000 L hydrogen -> poly-si + 3000 L hydrochloric acid, 15 s, LV).
--- GT's silane recipe (:735-742) is left out (no consumer). The others belong to lines Gregtorio does not have: acetylene,
--- acetaldehyde, ethylene oxide and glycol, the methylamines, nickel tetracarbonyl and aniline to the Kevlar chain
--- (question #378), nitrobenzene and aniline to GT's netherite chain, chlorosulfonic acid and the phosphorus chlorides to
--- GT's toxic slurry chain (chains/AcidRecipes.java) and bartworks' acid generator (#367: leave).
--------------------------------------------------------------------------------

F.fluid("trichlorosilane", "nearly-white-fluid", { 0.95, 0.95, 0.95 })
RECIPES = {}
step(RECIPES, "trichlorosilane", "lv-chemical-reactor-recipes", 15, LV_SPEED,
	{ { "raw-silicon", 1 }, { "hydrochloric-acid", 300 } }, { { "trichlorosilane", 100 }, { "hydrogen", 200 } })
step(RECIPES, "poly-si-dust-from-trichlorosilane", "lv-chemical-reactor-recipes", 15, LV_SPEED,
	{ { "trichlorosilane", 100 }, { "hydrogen", 200 } }, { { "poly-si-dust", 1 }, { "hydrochloric-acid", 300 } })
for _, r in pairs(RECIPES) do
	for _, t in pairs(techs_of("poly-si-dust")) do fork_add_unlock(t, r) end
end

--------------------------------------------------------------------------------
--- 6) GOODGENERATOR'S LIQUID FUELS (issue #357, part 1; goodgenerator/loader/RecipeLoader.java and RecipeLoader2.java,
--- fuel values RecipeLoader.java:505-534, 620-623: diesel fuels burn in the combustion generators, gas fuels in the gas
--- turbines; cells of 800 at 500 J per EU as Gregtorio's other cells):
---   ether (Gregtorio's, 537 EU/L, both kinds: a combustion cell), ethanol gasoline (9 raw gasoline + 1 ethanol -> 10,
---     RecipeLoader.java:496-501, 0.75 s, MV; 1100 EU/L), cyclopentadiene (coal tar oil 20 -> 6 or wood tar 100 -> 4 in the
---     distillery, RecipeLoader2.java:794-809, 1 s, MV; 70 EU/L gas), naquadah gas (Gregtorio's, 1024 EU/L gas)
---   the jet fuels on ferrocene (RecipeLoader2.java:811-901): iron II chloride from iron III chloride and hydrogen (4 s,
---     MV); diethylamine from ammonia and 2 ethanol (10 s, MV); the impure ferrocene mixture from cyclopentadiene, iron II
---     chloride, diethylamine and ice (2 min, MV, GT's large chemical reactor); with ether in the mixer the ferrocene
---     solution and the ferrocene waste (40 s); the waste distilled back into water, diethylamine and hydrochloric acid,
---     the solution into ether and ferrocene (the distillation tower; GT's times); Jet Fuel No.3 (GT's ironed kerosene,
---     1824 EU/L) from ferrocene, sodium hydroxide, kerosene, naphtha and diethylamine (2 min, EV); Jet Fuel A (GT's ironed
---     fuel, 2248 EU/L) from ferrocene, the combustion promoter, naphtha, light fuel, LPG and tetranitromethane (2 min, IV)
---   the combustion promoter (RecipeLoader.java:907-943): saltpeter or sodium nitrate with liquid oxygen (-> 50) or
---     hydrogen peroxide (-> 200) and nitrogen dioxide (10 s, MV)
---   ice for the ferrocene mixture: GT's vacuum freezer recipe of water (VacuumFreezerRecipes.java:207-212, 2.5 s, MV) into
---     the base game's ice
--- GT's large chemical reactor recipes run in Gregtorio's chemical reactors of their tier.
--------------------------------------------------------------------------------

for _, f in pairs({ { "ethanol-gasoline", "orange-fluid", { 1.00, 0.55, 0.20 } },
	{ "cyclopentadiene", "nearly-white-fluid", { 1.00, 0.97, 0.86 } },
	{ "iron-ii-chloride", "pale-green-fluid", { 0.68, 0.95, 0.68 } },
	{ "diethylamine", "light-pink-fluid", { 0.93, 0.80, 0.80 } },
	{ "impure-ferrocene-mixture", "rust-brown-fluid", { 0.48, 0.28, 0.08 } },
	{ "ferrocene-solution", "orange-fluid", { 0.88, 0.47, 0.20 } },
	{ "ferrocene-waste", "olive-fluid", { 0.40, 0.33, 0.13 } },
	{ "jet-fuel-no-3", "spackled-yellow-fluid", { 0.84, 0.68, 0.30 } },
	{ "jet-fuel-a", "light-orange-fluid", { 0.95, 0.69, 0.36 } },
	{ "combustion-promoter", "deep-pink-fluid", { 0.60, 0.20, 0.40 } } }) do
	F.fluid(f[1], f[2], f[3])
end
create_item{ skip_recipe = true, name = "ferrocene-dust", subgroup = data.raw.item["phthalic-anhydride"].subgroup }
local function fuel_cell(fluid, eu, category, like)
	create_item{
		name = fluid .. "-cell",
		category = "lv-canning-machine-recipes",
		energy_required = 4,
		fuel_category = category,          -- (create_item's argument: the item gets fuel_categories, issue #535)
		fuel_value = string.format("%.1fMJ", eu * 800 * 500 / 1e6),
		burnt_result = "empty-large-steel-fluid-cell",
		subgroup = data.raw.item[like].subgroup,
		ingredients = {
			{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
			{ type = "fluid", name = fluid, amount = 800 },
		},
	}
	return fluid .. "-cell"
end
local COMB, GAS = "combustion-generator-fuel", "gas-turbine-fuel"
--- the simple fuels with the technologies of their fluids
fork_add_unlock("polyethylene", fuel_cell("ether", 537, COMB, "diesel-cell"))
fork_add_unlock("uhv-naquadah-reactor", fuel_cell("naquadah-gas", 1024, GAS, "propane-cell"))
RECIPES = {}
step(RECIPES, "ethanol-gasoline", "mv-chemical-reactor-recipes", 0.75, MV_SPEED, { { "raw-gasoline", 90 }, { "ethanol", 10 } },
	{ { "ethanol-gasoline", 100 } })
RECIPES[#RECIPES + 1] = fuel_cell("ethanol-gasoline", 1100, COMB, "diesel-cell")
for _, r in pairs(RECIPES) do fork_add_unlock("cetane-boosted-diesel", r) end
RECIPES = {}
step(RECIPES, "cyclopentadiene-from-coal-tar-oil", "mv-distillation-recipes", 1, MV_SPEED, { { "coal-tar-oil", 2 } },
	{ { "cyclopentadiene", 0.6 } })
step(RECIPES, "cyclopentadiene-from-wood-tar", "mv-distillation-recipes", 1, MV_SPEED, { { "wood-tar", 10 } },
	{ { "cyclopentadiene", 0.4 } })
RECIPES[#RECIPES + 1] = fuel_cell("cyclopentadiene", 70, GAS, "propane-cell")
step(RECIPES, "ice-from-water", "mv-vacuum-freezer-recipes", 2.5, MV_SPEED, { { "water", 100 } }, { { "ice", 1 } })
step(RECIPES, "iron-ii-chloride", "mv-chemical-reactor-recipes", 4, MV_SPEED,
	{ { "iron-iii-chloride", 100 }, { "hydrogen", 100 } }, { { "iron-ii-chloride", 100 }, { "hydrochloric-acid", 100 } })
step(RECIPES, "diethylamine", "mv-chemical-reactor-recipes", 10, MV_SPEED, { { "ammonia", 100 }, { "ethanol", 200 } },
	{ { "diethylamine", 100 }, { "water", 200 } })
step(RECIPES, "impure-ferrocene-mixture", "mv-chemical-reactor-recipes", 120, MV_SPEED,
	{ { "ice", 4 }, { "cyclopentadiene", 200 }, { "iron-ii-chloride", 100 }, { "diethylamine", 800 } },
	{ { "impure-ferrocene-mixture", 1500 } })
step(RECIPES, "ferrocene-solution", "mv-mixer-recipes", 40, MV_SPEED,
	{ { "ether", 100 }, { "impure-ferrocene-mixture", 750 } }, { { "ferrocene-solution", 100 }, { "ferrocene-waste", 500 } })
step(RECIPES, "ferrocene-waste-distillation", "mv-tall-distillation-recipes", 30, MV_SPEED, { { "ferrocene-waste", 100 } },
	{ { "water", 40 }, { "diethylamine", 80 }, { "hydrochloric-acid", 20 } }, "diethylamine")
step(RECIPES, "ferrocene-solution-distillation", "mv-tall-distillation-recipes", 40, MV_SPEED,
	{ { "ferrocene-solution", 200 } }, { { "ether", 200 }, { "ferrocene-dust", 1 } }, "ferrocene-dust")
step(RECIPES, "combustion-promoter", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "saltpeter", 2 }, { "liquid-oxygen", 100 }, { "nitrogen-dioxide", 100 } }, { { "combustion-promoter", 50 } })
step(RECIPES, "combustion-promoter-from-sodium-nitrate", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "sodium-nitrate", 2 }, { "liquid-oxygen", 100 }, { "nitrogen-dioxide", 100 } }, { { "combustion-promoter", 50 } })
step(RECIPES, "combustion-promoter-from-hydrogen-peroxide", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "saltpeter", 2 }, { "hydrogen-peroxide", 100 }, { "nitrogen-dioxide", 100 } }, { { "combustion-promoter", 200 } })
step(RECIPES, "jet-fuel-no-3", "ev-chemical-reactor-recipes", 120, EV_SPEED,
	{ { "ferrocene-dust", 4 }, { "sodium-hydroxide", 8 }, { "kerosene", 4000 }, { "naphtha", 300 }, { "diethylamine", 100 } },
	{ { "jet-fuel-no-3", 4400 } })
RECIPES[#RECIPES + 1] = fuel_cell("jet-fuel-no-3", 1824, COMB, "diesel-cell")
F.tech{
	name = "jet-fuel", prerequisites = { "hydrazine-rocket-fuels", "cetane-boosted-diesel", "more-gas-turbine-fuels" },
	packs = 5, count = 400, time = 45, recipes = RECIPES,
}
RECIPES = {}
step(RECIPES, "jet-fuel-a", "iv-chemical-reactor-recipes", 120, IV_SPEED,
	{ { "ferrocene-dust", 4 }, { "combustion-promoter", 400 }, { "naphtha", 4000 }, { "light-fuel", 300 }, { "lpg", 100 },
		{ "tetranitromethane", 200 } }, { { "jet-fuel-a", 5000 } })
RECIPES[#RECIPES + 1] = fuel_cell("jet-fuel-a", 2248, COMB, "diesel-cell")
--- (Jet Fuel A has five fluids: the IV large chemical reactor, with IV Energy Hatches)
F.tech{
	name = "jet-fuel-a", prerequisites = { "jet-fuel", "iv-energy-hatches" }, packs = 6, count = 600, time = 45,
	recipes = RECIPES,
}

--------------------------------------------------------------------------------
--- 7) THE UNIVERSAL CHEMICAL FUEL ENGINE AND THE THORIUM BASED LIQUID FUEL (issue #357, part 2)
--- GT's Universal Chemical Fuel Engine (LuV; gregtech/common/tileentities/machines/multi/
--- MTEUniversalChemicalFuelEngine.java) burns everything in its hatches each second, from the diesel, gas or rocket fuel
--- maps, at an efficiency of exp(-c x fuel / promoter) x 150 % (c 0.04 for diesel and gas, 0.005 for rocket fuel; no
--- promoter, no power), rocket fuel at 3 times its value. Here a burner generator on the combustion and gas turbine fuel
--- cells at GT's ceiling of 150 %, one LuV amp (the one dynamo hatch of its structure). Left out, as the large combustion
--- engine of #255 and the large rocket engine of #304 leave their extras out: the combustion promoter (a burner takes one
--- fuel; the promoter is made, 6 above, and goes into Jet Fuel A) and the rocket fuels (a burner has one efficiency, and
--- the Large Rocket Engine of 145 burns them at 3 times their value already).
--- Its item is the controller with the structure's casings (checkCasingMin 100 Stable Titanium Machine Casings; the shape's
--- 39 Chemically Inert Casings, 20 Engine Intake Casings, 12 Titanium Pipe Casings, 10 Titanium Firebox Casings and 72 PTFE
--- frames, the frames as their 144 PTFE sheets: the mod has no PTFE frame), a LuV dynamo hatch and 3 hulls for the input,
--- maintenance and muffler hatches (as #255). The controller is goodgenerator's crafting recipe (RecipeLoader.java:947-955):
--- 2 dense titanium plates, a ZPM circuit, a large combustion engine, an extreme combustion engine, a LuV hull, 2 naquadah
--- cables and an osmium gear. The mod has no Extreme Combustion Engine (the multiblock audit: leave): a second large
--- combustion engine stands in for it.
--------------------------------------------------------------------------------

local FORK_ICON = "__gregtorio-continued__/graphics/icons/fork/"
local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
create_item{
	name = "universal-chemical-fuel-engine",
	icon = FORK_ICON .. "universal-chemical-fuel-engine.png",
	place_result = "universal-chemical-fuel-engine",
	subgroup = "subgroup-luv-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "dense-titanium-plate", amount = 2 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "item", name = "large-combustion-engine", amount = 2 },
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "naquadah-cable", amount = 2 },
		{ type = "item", name = "osmium-gear", amount = 1 },
		{ type = "item", name = "stable-titanium-machine-casing", amount = 100 },
		{ type = "item", name = "chemically-inert-casing", amount = 39 },
		{ type = "item", name = "engine-intake-casing", amount = 20 },
		{ type = "item", name = "titanium-pipe-casing", amount = 12 },
		{ type = "item", name = "titanium-firebox-casing", amount = 10 },
		{ type = "item", name = "ptfe-sheet", amount = 144 },
		{ type = "item", name = "luv-dynamo-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 3 },
	},
}
create_burner_generator{
	name = "universal-chemical-fuel-engine",
	icon = FORK_ICON .. "universal-chemical-fuel-engine.png",
	efficiency = 1.5,
	fuel_categories = { COMB, GAS },
	max_power = EU32_LuV,   -- (one LuV amp)
	working_animation = SPRITE_PATH .. "universal-chemical-fuel-engine-working.png",
	idle_animation = SPRITE_PATH .. "universal-chemical-fuel-engine-idle.png",
	frame_count = 1,
}
data.raw["burner-generator"]["universal-chemical-fuel-engine"].localised_description =
	{ "entity-description.universal-chemical-fuel-engine" }
F.tech{
	name = "universal-chemical-fuel-engine",
	prerequisites = { "large-combustion-engine", "large-gas-turbine", "zpm-energy-hatches", "zpm-materials", "plasma-turbine",
		"high-pressure-steam-turbine", "large-chemical-reactor", "jet-fuel" },
	packs = 8, count = 2000, time = 60, recipes = { "universal-chemical-fuel-engine" },
}

--- GoodGenerator's thorium based liquid fuel (RecipeLoader.java:188-234): the uranium carbide-thorium mixture (bartworks'
--- mixer recipe of the Werkstoff: 11 thorium, 1 thorium 232, 1 uranium 235 and 3 carbon into 16, 2.35 s, LV; thorium
--- 232 since issue #386, section 14), 64 of it with 4 tungstensteel foils into a wrapped thorium ingot (HV
--- assembler, 15 s), the implosion compressor (GT's 4 TNT: one explosive) into a high density thorium nugget and 8 tiny
--- tungstensteel dusts, 9 nuggets into high density thorium (MV compressor, 10 s), with 4 lithium, 2 draconium and 1000
--- mercury into 4000 thorium based liquid fuel (HV mixer, 150 s), excited with 250 helium plasma per 1000 (IV mixer, 6 s;
--- GT fills a cell). Fluids a tenth of GT's litres; the mod has no draconium dust (its ingot). GT burns the excited fuel
--- in the large naquadah reactor at 2200 EU/t for 500 ticks per L (GGConfigLoader.java:15-17), as 136 burns the uranium
--- and plutonium fuels; as there, the reactor gives no depleted fuel (the neutron activator does, section 23, #356).
--- Gregtorio's draconium comes with UEV Materials (the MK3 fusion reactor), so the fuel comes that late.
for _, f in pairs({ { "thorium-based-liquid-fuel", "spackled-purple-fluid", { 0.31, 0.20, 0.40 } },
	{ "excited-thorium-based-liquid-fuel", "spackled-purple-fluid", { 0.45, 0.30, 0.60 } } }) do
	F.fluid(f[1], f[2], f[3])
end
data.raw.fluid["excited-thorium-based-liquid-fuel"].fuel_value = "1.1GJ"   -- (2200 x 500 EU, 1 EU = 1 kJ as in 136)
do
	local fuels = data.raw["mod-data"]["fork-power"].data.fuels
	for name, list in pairs(fuels) do
		if name:find("large%-naquadah%-reactor$") then
			local found = false
			for _, x in pairs(list) do found = found or x == "excited-thorium-based-liquid-fuel" end
			if not found then list[#list + 1] = "excited-thorium-based-liquid-fuel" end
		end
	end
end
create_item{
	name = "uranium-carbide-thorium-mixture",
	category = "lv-mixer-recipes",
	energy_required = 2.35,
	ingredients = {
		{ type = "item", name = "thorium-dust", amount = 11 },
		{ type = "item", name = "thorium-232-dust", amount = 1 },
		{ type = "item", name = "uranium-235-dust", amount = 1 },
		{ type = "item", name = "carbon", amount = 3 },
	},
	results = { { type = "item", name = "uranium-carbide-thorium-mixture", amount = 16 } },
}
create_item{
	name = "wrapped-thorium-ingot",
	category = "hv-assembling-machine-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "uranium-carbide-thorium-mixture", amount = 64 },
		{ type = "item", name = "tungstensteel-foil", amount = 4 },
	},
}
create_item{
	name = "high-density-thorium-nugget",
	category = "lv-implosion-compressor-recipes",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "wrapped-thorium-ingot", amount = 1 },
		{ type = "item", name = "explosives", amount = 1 },
	},
	results = {
		{ type = "item", name = "high-density-thorium-nugget", amount = 1 },
		{ type = "item", name = "tiny-pile-of-tungstensteel-dust", amount = 8 },
	},
	main_product = "high-density-thorium-nugget",
}
create_item{
	name = "high-density-thorium",
	category = "mv-compressor-recipes",
	energy_required = 10 * MV_SPEED,
	ingredients = { { type = "item", name = "high-density-thorium-nugget", amount = 9 } },
}
RECIPES = { "uranium-carbide-thorium-mixture", "wrapped-thorium-ingot", "high-density-thorium-nugget",
	"high-density-thorium" }
for _, i in pairs(RECIPES) do data.raw.item[i].subgroup = data.raw.item["high-density-plutonium"].subgroup end
step(RECIPES, "thorium-based-liquid-fuel", "hv-mixer-recipes", 150, HV_SPEED,
	{ { "high-density-thorium", 1 }, { "lithium", 4 }, { "draconium-ingot", 2 }, { "mercury", 100 } },
	{ { "thorium-based-liquid-fuel", 400 } })
step(RECIPES, "excited-thorium-based-liquid-fuel", "iv-mixer-recipes", 6, IV_SPEED,
	{ { "thorium-based-liquid-fuel", 100 }, { "helium-plasma", 25 } }, { { "excited-thorium-based-liquid-fuel", 100 } })
F.tech{
	name = "thorium-based-liquid-fuel", prerequisites = { "uev-materials", "naquadah-fuels" }, packs = 10, count = 2500,
	time = 60, recipes = RECIPES,
}

--------------------------------------------------------------------------------
--- 8) THE ASOC WAFER AND CHIP (issue #355, part 1; GT's Circuit_Wafer_SoC2 and Circuit_Chip_SoC2)
--- GT engraves the ASoC wafer with a green lens (LaserEngraverRecipes.java:375-394): GT's Wafer3 (Gregtorio's naquadah
--- doped wafer) into 1 (90 s, EV), Wafer4 (europium) into 2 (75 s, IV), Wafer5 (americium) into 4 (60 s, LuV); here
--- the emerald lens in the engraver's lens slot (#325). The cutter makes 6 ASoCs of a wafer (NewHorizonsCoreMod
--- CuttingMachineRecipes.java:56-58, 45 s, EV; with 25 lubricant as Gregtorio's other chips). GT New Horizons uses them in
--- the energy module (AssemblyLineRecipes.java:788-789: 2 x 64 ASoC wafers; 133 had 64 UHPIC wafers for them) and in the
--- ASoC variants of the nanoprocessor and the quantum processor (NewHorizonsCoreMod CircuitAssemblerRecipes.java:571-591:
--- 6 boards, 6 ASoCs, 48 fine wires and 48 bolts with 2 ingots of Indalloy 140 into one circuit, 10 s, IV and LuV; the
--- mod's circuit assembler ends at IV, so both run there). GT's ZPIC and YPIC wafers need what the mod lacks (issue #355:
--- the beamcrafter, creon, mellion and gravitons; the Bose-Einstein condensate wafer and quark gluon plasma in the MAX
--- solidifier); the UMV and UXV hatches keep their APIC stand-ins of 133 and 134 (the ZPIC came later, section 33:
--- GTNH's ZPIC recipe of the UMV hatches is a second recipe).
--------------------------------------------------------------------------------

create_item{ skip_recipe = true, name = "asoc-wafer", subgroup = data.raw.item["soc-wafer"].subgroup }
create_item{ skip_recipe = true, name = "advanced-system-on-chip", subgroup = data.raw.item["system-on-chip"].subgroup }
local LENS = { type = "item", name = "emerald-lens", amount = 1 }
local function engrave(name, wafer, out, seconds, tier, speed)
	create_recipe{
		name = name,
		category = tier .. "-laser-engraver-recipes",
		energy_required = seconds * speed,
		ingredients = { { type = "item", name = wafer, amount = 1 }, LENS },
		results = { { type = "item", name = "asoc-wafer", amount = out }, LENS },
		main_product = "asoc-wafer",
	}
	return name
end
local ASOC_ND = engrave("asoc-wafer-nd", "naquadah-doped-wafer", 1, 90, "ev", EV_SPEED)
local ASOC_ED = engrave("asoc-wafer-ed", "europium-doped-wafer", 2, 75, "iv", IV_SPEED)
local ASOC_AD = engrave("asoc-wafer-ad", "americium-doped-wafer", 4, 60, "luv", LUV_SPEED)
RECIPES = {}
step(RECIPES, "advanced-system-on-chip", "ev-cutting-machine-recipes", 45, EV_SPEED, { { "asoc-wafer", 1 }, { "lubricant", 25 } },
	{ { "advanced-system-on-chip", 6 } })
step(RECIPES, "nanoprocessor-asoc", "iv-circuit-assembler-recipes", 10, IV_SPEED,
	{ { "epoxy-printed-circuit-board", 6 }, { "advanced-system-on-chip", 6 }, { "fine-electrum-wire", 48 },
		{ "platinum-bolt", 48 }, { "molten-indalloy-140", 28.8 } }, { { "processing-unit", 1 } })
local NANO_ASOC = table.remove(RECIPES)
step(RECIPES, "quantum-processor-asoc", "iv-circuit-assembler-recipes", 10, IV_SPEED,
	{ { "fiber-reinforced-printed-circuit-board", 6 }, { "advanced-system-on-chip", 6 }, { "fine-platinum-wire", 64 },
		{ "niobium-titanium-bolt", 48 }, { "molten-indalloy-140", 28.8 } }, { { "ev-circuit", 1 } })
local QUANTUM_ASOC = table.remove(RECIPES)
--- unlocked where they are first used (#252): the first wafer, the cutter and the nanoprocessor variant after the
--- nanoprocessor and Indalloy 140, the quantum variant after the quantum processor too, the europium and americium wafers
--- with their SoC wafers' technologies; the energy module's technology comes later
--- (the technologies by name: 142 hands out the circuit recipes after this file)
local T_NANO = after_both(after_both("nanoprocessors", "luv-components"), "naquadah-processing")   -- (Indalloy 140; the wafer)
for _, r in pairs({ ASOC_ND, RECIPES[1], NANO_ASOC }) do fork_add_unlock(T_NANO, r) end
fork_add_unlock(after_both(T_NANO, "qubit-cpus"), QUANTUM_ASOC)
fork_add_unlock(after_both(T_NANO, "nano-power-ics"), ASOC_ED)
fork_add_unlock(after_both(T_NANO, "pico-quantum-power-ics"), ASOC_AD)
--- the variants show their GTNH item's texture (156, issue #164)
for _, r in pairs({ NANO_ASOC, QUANTUM_ASOC }) do
	local x = data.raw.recipe[r]
	x.icon, x.icon_size, x.icons = "__gregtorio-continued__/graphics/icons/circuit-recipe-" .. r .. ".png", 32, nil
end
for _, i in pairs(data.raw.recipe["energy-module"].ingredients) do
	if i.name == "uhpic-wafer" then i.name, i.amount = "asoc-wafer", 128 end
end

--------------------------------------------------------------------------------
--- 9) DUAL AND QUAD FUEL RODS AND MOX (issue #359, part 1; gregtech/loaders/load/FissionFuelLoader.java, the rods'
--- values gregtech/loaders/preload/LoaderGTBlockFluid.java:265-380)
--- An IC2 rod of n cells gives energy x n x (1 + n / 2) pulses per tick over its lifetime (ItemRadioactiveCellIC.java:
--- 42-66): a dual rod 4 times and a quad rod 12 times a single rod of its fuel. Gregtorio's reactors burn rods as fuel,
--- so the dual and quad rods hold 4 and 12 times the single rod's value (uranium 6000 MJ, thorium 5000 MJ, the mod's).
--- GT's MOX rod gives the uranium rod's energy per pulse for half its lifetime (10 000 against 20 000): 3000 MJ. IC2
--- raises MOX with the reactor's heat (up to 2.5 times); the mod's reactors have no hull heat, so the cold value.
--- Recipes: GT's: 2 rods and 4 steel rods into a dual rod (LV assembler, 10 s), 4 rods and 6 long steel rods (15 s) or 2
--- duals and 4 steel rods (10 s) into a quad rod; IC2's MOX fuel from 6 uranium 238, 3 plutonium and 1000 coolant (HV
--- assembler, 20 s), canned into an empty fuel rod (1.5 s). The depleted rods go into GT's thermal centrifuge (25 s, LV):
--- the dual and quad rods give 2 and 4 times the single rod's outputs and 3 and 6 iron dust; IC2's small piles are a ninth
--- of a dust, as the mod's single rods have them (a small plutonium pile: 11 % of a plutonium 239 dust). GT's IV
--- centrifuge of 8 depleted rods (the isotopes plutonium 238 and 241, uranium 232 and 233, thorium 232, krypton) came
--- with the LFTR (issue #386, section 14). They come with Nuclear Fuel Rods,
--- and the coolant with them (MOX takes it).
--------------------------------------------------------------------------------

local ROD_GROUP = data.raw.item["uranium-fuel-rod"].subgroup
local function rod(name, fuel, depleted, ingredients, category, seconds)
	create_item{
		name = name,
		category = category,
		energy_required = seconds,
		ingredients = ingredients,
		results = { { type = "item", name = name, amount = 1 } },
		fuel_category = "nuclear-fuel-rod",
		fuel_value = fuel .. "MJ",
		burnt_result = depleted,
		subgroup = ROD_GROUP,
	}
	create_item{ skip_recipe = true, name = depleted, subgroup = ROD_GROUP }
	return name
end
local function centrifuge(depleted, results)
	local name = depleted .. "-thermal-centrifuging"
	local res = {}
	for _, r in pairs(results) do res[#res + 1] = { type = "item", name = r[1], amount = r[2], independent_probability = r[3] } end
	create_recipe{
		name = name,
		category = "lv-thermal-centrifuge-recipes",
		energy_required = 25,
		ingredients = { { type = "item", name = depleted, amount = 1 } },
		results = res,
		main_product = res[1].name,
	}
	return name
end
local function ladder(single, value, list)
	local dual, quad = "dual-" .. single, "quad-" .. single
	list[#list + 1] = rod(dual, 4 * value, "depleted-" .. dual,
		{ { type = "item", name = single, amount = 2 }, { type = "item", name = "steel-rod", amount = 4 } },
		"lv-assembling-machine-recipes", 10)
	list[#list + 1] = rod(quad, 12 * value, "depleted-" .. quad,
		{ { type = "item", name = single, amount = 4 }, { type = "item", name = "long-steel-rod", amount = 6 } },
		"lv-assembling-machine-recipes", 15)
	create_recipe{
		name = quad .. "-from-dual",
		category = "lv-assembling-machine-recipes",
		energy_required = 10,
		ingredients = { { type = "item", name = dual, amount = 2 }, { type = "item", name = "steel-rod", amount = 4 } },
		results = { { type = "item", name = quad, amount = 1 } },
	}
	list[#list + 1] = quad .. "-from-dual"
	return dual, quad
end

RECIPES = {}
local UD, UQ = ladder("uranium-fuel-rod", 6000, RECIPES)
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. UD,
	{ { "uranium-238-dust", 8 }, { "iron-dust", 3 }, { "plutonium-239-dust", 1, 0.22 } })
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. UQ,
	{ { "uranium-238-dust", 16 }, { "iron-dust", 6 }, { "plutonium-239-dust", 1, 0.44 } })
local TD, TQ = ladder("thorium-fuel-rod", 5000, RECIPES)
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. TD, { { "thorium-dust", 2 }, { "iron-dust", 3 }, { "lutetium-dust", 1 } })
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. TQ, { { "thorium-dust", 4 }, { "iron-dust", 6 }, { "lutetium-dust", 2 } })
create_item{
	name = "mox-fuel",
	category = "hv-assembling-machine-recipes",
	energy_required = 20 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "uranium-238-dust", amount = 6 },
		{ type = "item", name = "plutonium-239-dust", amount = 3 },
		{ type = "fluid", name = "coolant", amount = 100 },
	},
	subgroup = ROD_GROUP,
}
RECIPES[#RECIPES + 1] = "mox-fuel"
RECIPES[#RECIPES + 1] = rod("mox-fuel-rod", 3000, "depleted-mox-fuel-rod",
	{ { type = "item", name = "empty-fuel-rod", amount = 1 }, { type = "item", name = "mox-fuel", amount = 1 } },
	"lv-canning-machine-recipes", 1.5)
local MD, MQ = ladder("mox-fuel-rod", 3000, RECIPES)
RECIPES[#RECIPES + 1] = centrifuge("depleted-mox-fuel-rod",
	{ { "plutonium-239-dust", 3 }, { "iron-dust", 1 }, { "plutonium-239-dust", 1, 0.11 } })
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. MD,
	{ { "plutonium-239-dust", 6 }, { "iron-dust", 3 }, { "plutonium-239-dust", 1, 0.22 } })
RECIPES[#RECIPES + 1] = centrifuge("depleted-" .. MQ,
	{ { "plutonium-239-dust", 12 }, { "iron-dust", 6 }, { "plutonium-239-dust", 1, 0.44 } })
RECIPES[#RECIPES + 1] = "coolant"
for _, r in pairs(RECIPES) do fork_add_unlock("nuclear-fuel-rods", r) end



--------------------------------------------------------------------------------
--- 10) THE SIDE CHEMICALS OF THE KEVLAR LINE (issue #378 (a), the maintainer's decision: Kevlar and radox as GTNH has
--- them, the side chemicals of #366 first). GT's recipes (gregtech/loaders/postload/recipes/ChemicalRecipes.java unless
--- named; GT++'s chemical plant routes left out, as in section 1), consumed catalyst dusts as GT has them:
---   calcium carbide: EBF, 2 quicklime + 3 carbon -> 3 + 1000 CO (HV, 30 s; BlastFurnaceRecipes.java:508-515)
---   acetylene: 3 calcium carbide + 2000 water -> 1000 + 5 calcium hydroxide (HV, 15 s; :3823-3831)
---   acetaldehyde: 2000 ethylene + 1000 oxygen -> 1000 (MV, 10 s; :860-868)
---   ethylene oxide: silver dust + alumina + 1000 ethylene + 1000 oxygen -> 1000 (HV, 2.5 s; :4821-4830)
---   ethylene glycol: 1000 ethylene oxide + 1000 water -> 1000 (HV, 10 s; :838-846)
---   methylamine: alumina + silicon dioxide + 1000 methanol + 1000 ammonia -> 1000 + 1000 water (UV, 75 s; :4867-4876;
---     GT's EV route also makes dimethyl- and trimethylamine, which nothing takes: left out)
---   nickel tetracarbonyl: nickel dust + 4000 carbon monoxide -> 1000 (EV, 20 s; :819-826)
---   nitrobenzene: 5000 benzene + 3000 sulfuric acid + 5000 nitric acid + 10000 distilled water -> 5000 + 3000 diluted
---     sulfuric acid (IV, 6 s; :5863-5875)
---   aniline: palladium dust + 9000 nitrobenzene + 54000 hydrogen -> 9000 + 18000 water (EV, 45 s; :5850-5859)
--- Their only consumers are the Kevlar line's (section 11), so they come with its technology, Kevlar (UV: its liquid
--- crystal Kevlar and polyurethane resin need the UV large chemical reactor).
--------------------------------------------------------------------------------

local KEVLAR = "kevlar"
--- (GT's colours, MaterialsInit.java, 0..1)
F.fluid("acetylene", "nearly-white-fluid", { 0.55, 0.43, 0.35 })
F.fluid("acetaldehyde", "nearly-white-fluid", { 0.85, 0.75, 0.66 })
F.fluid("ethylene-oxide", "nearly-white-fluid", { 0.63, 0.78, 0.98 })
F.fluid("ethylene-glycol", "nearly-white-fluid", { 0.38, 0.32, 0.97 })
F.fluid("methylamine", "nearly-white-fluid", { 0.67, 0.43, 0.53 })
F.fluid("nickel-tetracarbonyl", "pale-green-fluid", { 0.84, 0.92, 0.48 })
F.fluid("nitrobenzene", "pale-green-fluid", { 0.49, 0.77, 0.36 })
F.fluid("aniline", "pale-green-fluid", { 0.79, 0.92, 0.29 })
for _, n in pairs({ "calcium-carbide-dust", "calcium-hydroxide-dust" }) do
	create_item{ skip_recipe = true, name = n, subgroup = "subgroup-macerator-dust" }
end

RECIPES = {}
step(RECIPES, "calcium-carbide-dust", "hv-electric-blast-furnace-recipes", 30, HV_SPEED,
	{ { "quicklime", 2 }, { "carbon", 3 } }, { { "calcium-carbide-dust", 3 }, { "carbon-monoxide", 100 } })
step(RECIPES, "acetylene", "hv-chemical-reactor-recipes", 15, HV_SPEED,
	{ { "calcium-carbide-dust", 3 }, { "water", 200 } }, { { "acetylene", 100 }, { "calcium-hydroxide-dust", 5 } })
step(RECIPES, "acetaldehyde", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "ethylene", 200 }, { "oxygen", 100 } }, { { "acetaldehyde", 100 } })
step(RECIPES, "ethylene-oxide", "hv-chemical-reactor-recipes", 2.5, HV_SPEED,
	{ { "silver-dust", 1 }, { "alumina", 1 }, { "ethylene", 100 }, { "oxygen", 100 } }, { { "ethylene-oxide", 100 } })
step(RECIPES, "ethylene-glycol", "hv-chemical-reactor-recipes", 10, HV_SPEED,
	{ { "ethylene-oxide", 100 }, { "water", 100 } }, { { "ethylene-glycol", 100 } })
step(RECIPES, "methylamine", "uv-chemical-reactor-recipes", 75, UV_SPEED,
	{ { "alumina", 1 }, { "silicon-dioxide", 1 }, { "methanol", 100 }, { "ammonia", 100 } },
	{ { "methylamine", 100 }, { "water", 100 } })
step(RECIPES, "nickel-tetracarbonyl", "ev-chemical-reactor-recipes", 20, EV_SPEED,
	{ { "nickel-dust", 1 }, { "carbon-monoxide", 400 } }, { { "nickel-tetracarbonyl", 100 } })
step(RECIPES, "nitrobenzene", "iv-chemical-reactor-recipes", 6, IV_SPEED,
	{ { "benzene", 500 }, { "sulfuric-acid", 300 }, { "nitric-acid", 500 }, { "distilled-water", 1000 } },
	{ { "nitrobenzene", 500 }, { "diluted-sulfuric-acid", 300 } })
step(RECIPES, "aniline", "ev-chemical-reactor-recipes", 45, EV_SPEED,
	{ { "palladium-dust", 1 }, { "nitrobenzene", 900 }, { "hydrogen", 5400 } }, { { "aniline", 900 }, { "water", 1800 } })
F.tech{
	--- (#252: palladium (aniline's catalyst); formaldehyde (Super Glue), boric acid and phosgene (Lanthanum
	--- Hexaboride), the HV Dehydrator (Samaric Rare Earth Processing) for section 11)
	name = KEVLAR, prerequisites = { "uv-multiblocks", "palladium", "super-glue", "lanthanum-hexaboride",
		"samaric-rare-earth-processing" }, packs = 9, count = 1500, time = 60,
	recipes = RECIPES,
}




--------------------------------------------------------------------------------
--- 11) KEVLAR (issue #378 (b)): GTNH's UV line to the Kevlar plate, GT's recipes (ChemicalRecipes.java unless named;
--- fluids a tenth of GT's litres, consumed catalyst dusts as GT has them; GT's x9 large chemical reactor recipes where
--- the single one needs a tiny pile, which the mod does not have):
---   p-xylene (1,4-dimethylbenzene): 1000 benzene + 2000 methane -> 1000 + 4000 hydrogen (MV, 200 s; :4986-4992)
---   naphthenic acid: GT's circuit 9 distillation of the oils (DistilleryRecipes.java:513-562), at the mod's oil scale (a
---     twentieth) and oil time (section 4)
---   cobalt(II) nitrate, hydroxide and naphthenate (:1043-1050, :3835-3842, :1022-1029); terephthalic acid from p-xylene
---     and 41 cobalt naphthenate (HV, 7.5 s; :967-976); dimethyl terephthalate (EV, 12.5 s; :4952-4963)
---   sulfur dichloride (LV, 40 s; :942-949), thionyl chloride (HV, 7.5 s; :953-963), terephthaloyl chloride: 18000
---     thionyl chloride + 5000 dimethyl terephthalate + 6000 CO2 -> 112 + 22000 diluted HCl + 18000 SO2 (EV, 20 s;
---     :4936-4948)
---   cupric oxide, bismuth(III) oxide (:898-905, :920-927), 2-butyne-1,4-diol (EV, 20 s; :6009-6021), nickel aluminide
---     (blast furnace, HV, 45 s; BlastFurnaceRecipes.java:519-525), Raney nickel (EV, 60 s; :872-883), 1,4-butanediol
---     (UV, 15 s; :6041-6050), gamma-butyrolactone (EV, 5 s; :5989-5996), N-methyl-2-pyrrolidone (IV, 30 s; :931-940)
---   acetic anhydride: 2000 acetic acid -> 1000 (HV dehydrator, 30 s; gtPlusPlus RecipesGregTech.java:1224-1231; its
---     water left out: the dehydrator has one fluid output), 4-nitroaniline (EV, 15 s; :5950-5959), p-phenylenediamine
---     (UV, 20 s; :5974-5985)
---   diaminodiphenylmethane mixture (EV, 60 s; :5837-5846), its MDI mixture with phosgene (EV, 30 s; :5879-5887), MDI
---     from the distillation tower (EV, 125 s; DistilleryRecipes.java:423-430)
---   pentaerythritol (HV, 30 s; :3808-3819), dimethyldichlorosilane (MV, 12 s; :2248-2255), silicon oil (EV, 0.75 s;
---     :4843-4852), propionic acid with nickel tetracarbonyl (EV, 10 s; :5924-5934)
---   butanol: rhodium chloride (blast furnace, HV, 30 s; BlastFurnaceRecipes.java:626-634), phosphorus trichloride (MV,
---     10 s; :1071-1078), triphenylphosphine (EV, 20 s; :5087-5094), sodium hydride (MV, 10 s; :1091-1098), trimethyl
---     borate (EV, 30 s; :6094-6104), sodium borohydride (EV, 30 s; :5098-5106) with GT's sodium methoxide back to NaOH
---     and methanol (HV, 10 s; :1102-1110), organorhodium catalyst (UV, 40 s; :6118-6134), butyraldehyde and
---     isobutyraldehyde (LV, 100 s, x9; :4807-4817), butanol (HV, 4 s, x9; :5889-5896)
---   polyurethane catalyst A (GT's "Kevlar catalyst"; EV, 30 s; :5898-5908), polyurethane resin (UV, 10 s; :4878-4888)
---   liquid crystal Kevlar (UV, 30 s; :6052-6064), Kevlar fiber (EV fluid solidifier, 40 s; FluidSolidifierRecipes.java:
---     282-288), woven Kevlar (EV assembler, 15 s; AssemblerRecipes.java:3077-3083), the Kevlar plate (LV chemical bath,
---     60 s; ChemicalBathRecipes.java:329-335)
--- Stand-in: GT's spinneret (the solidifier's tool for the fibers) is the solidifier's generic mold (150).
--- Molten Kevlar (GT: the extractor melts a plate into 144 L) casts the Kevlar ring (143). GTNH's users the mod has: the
--- UXV pump takes 64 Kevlar rings instead of the silicone rubber rings, the UXV conveyor 80 Kevlar plates instead of the
--- silicone rubber sheets (tectech ResearchStationAssemblyLine.java:2004-2048), the UXV hull molten Kevlar (GT's 576 L,
--- here a tenth) instead of polybenzimidazole (NH AssemblerRecipes.java:846-852).
--------------------------------------------------------------------------------

F.fluid("1-4-dimethylbenzene", "nearly-white-fluid", { 0.84, 0.81, 0.69 })
F.fluid("naphthenic-acid", "black-fluid", { 0.25, 0.20, 0.10 })
F.fluid("terephthalic-acid", "nearly-white-fluid", { 1.00, 1.00, 1.00 })
F.fluid("dimethyl-terephthalate", "nearly-white-fluid", { 0.95, 0.95, 0.95 })
F.fluid("sulfur-dichloride", "medium-red-fluid", { 0.78, 0.00, 0.00 })
F.fluid("thionyl-chloride", "nearly-white-fluid", { 0.98, 0.98, 0.98 })
F.fluid("1-4-butanediol", "nearly-white-fluid", { 0.85, 0.85, 0.85 })
F.fluid("gamma-butyrolactone", "pale-green-fluid", { 1.00, 1.00, 0.59 })
F.fluid("n-methyl-2-pyrrolidone", "nearly-white-fluid", { 0.92, 0.92, 0.92 })
F.fluid("acetic-anhydride", "nearly-white-fluid", { 0.90, 0.90, 0.85 })
F.fluid("4-nitroaniline", "light-orange-fluid", { 0.87, 0.67, 0.09 })
F.fluid("diaminodiphenylmethane-mixture", "dark-muted-yellow-fluid", { 1.00, 0.95, 0.48 })
F.fluid("diphenylmethane-diisocyanate-mixture", "dark-muted-yellow-fluid", { 1.00, 0.90, 0.20 })
F.fluid("dimethyldichlorosilane", "purple-fluid", { 0.27, 0.09, 0.31 })
F.fluid("silicon-oil", "nearly-white-fluid", { 0.95, 0.95, 0.95 })
F.fluid("propionic-acid", "nearly-white-fluid", { 0.73, 0.61, 0.43 })
F.fluid("phosphorus-trichloride", "nearly-white-fluid", { 0.98, 0.98, 0.98 })
F.fluid("trimethyl-borate", "nearly-white-fluid", { 0.96, 0.96, 0.96 })
F.fluid("butyraldehyde", "nearly-white-fluid", { 0.96, 0.96, 0.96 })
F.fluid("isobutyraldehyde", "nearly-white-fluid", { 0.94, 0.94, 0.94 })
F.fluid("butanol", "nearly-white-fluid", { 0.77, 0.67, 0.46 })
F.fluid("polyurethane-resin", "dark-muted-yellow-fluid", { 0.90, 0.90, 0.47 })
F.fluid("liquid-crystal-kevlar", "dark-muted-yellow-fluid", { 0.94, 0.94, 0.47 })
F.fluid("molten-kevlar", "molten-kevlar", { 0.94, 0.94, 0.47 })   -- (143 casts it: its MATERIALS)
for _, n in pairs({ "cobalt-ii-nitrate-dust", "cobalt-ii-hydroxide-dust", "cobalt-ii-naphthenate-dust",
	"terephthaloyl-chloride-dust", "cupric-oxide-dust", "bismuth-iii-oxide-dust", "2-butyne-1-4-diol-dust",
	"nickel-aluminide-ingot", "raney-nickel-dust", "p-phenylenediamine-dust", "diphenylmethane-diisocyanate-dust",
	"pentaerythritol-dust", "rhodium-chloride-dust", "triphenylphosphine-dust", "sodium-hydride-dust",
	"sodium-borohydride-dust", "sodium-methoxide-dust", "organorhodium-catalyst-dust", "polyurethane-catalyst-a-dust",
	"kevlar-fiber", "woven-kevlar", "kevlar-plate", "kevlar-ring" }) do
	create_item{ skip_recipe = true, name = n, subgroup = "subgroup-macerator-dust" }
end

RECIPES = {}
--- terephthaloyl chloride
step(RECIPES, "1-4-dimethylbenzene", "mv-chemical-reactor-recipes", 200, MV_SPEED, { { "benzene", 100 }, { "methane", 200 } },
	{ { "1-4-dimethylbenzene", 100 }, { "hydrogen", 400 } })
for _, o in pairs({
	{ "light-oil", 21, 3.5, 6.5, 10, 0.75, 80 }, { "medium-oil", 32, 5, 25, 75, 1.25, 30 },
	{ "crude-oil", 64, 15, 50, 20, 2.5, 60 }, { "heavy-oil", 100, 50, 22.5, 7.5, 2.5, 30 },
}) do
	step(RECIPES, o[1] .. "-distillation-naphthenic-acid", "hv-tall-distillation-recipes", CRUDE_TIME * o[2] / 30, 1,
		{ { o[1], 50 } }, { { "sulfuric-heavy-fuel", o[3] }, { "sulfuric-light-fuel", o[4] }, { "sulfuric-naphtha", o[5] },
			{ "naphthenic-acid", o[6] }, { "sulfuric-gas", o[7] } }, "naphthenic-acid")
end
step(RECIPES, "cobalt-ii-nitrate-dust", "mv-chemical-reactor-recipes", 5, MV_SPEED,
	{ { "cobalt-dust", 1 }, { "nitric-acid", 200 } }, { { "cobalt-ii-nitrate-dust", 9 }, { "hydrogen", 200 } })
step(RECIPES, "cobalt-ii-hydroxide-dust", "mv-chemical-reactor-recipes", 5, MV_SPEED,
	{ { "cobalt-ii-nitrate-dust", 9 }, { "sodium-hydroxide", 6 } }, { { "cobalt-ii-hydroxide-dust", 5 }, { "sodium-nitrate", 10 } })
step(RECIPES, "cobalt-ii-naphthenate-dust", "hv-chemical-reactor-recipes", 10, HV_SPEED,
	{ { "cobalt-ii-hydroxide-dust", 5 }, { "naphthenic-acid", 100 } }, { { "cobalt-ii-naphthenate-dust", 41 } })
step(RECIPES, "terephthalic-acid", "hv-chemical-reactor-recipes", 7.5, HV_SPEED,
	{ { "1-4-dimethylbenzene", 100 }, { "cobalt-ii-naphthenate-dust", 41 }, { "oxygen", 600 } },
	{ { "terephthalic-acid", 100 }, { "water", 200 } })
step(RECIPES, "dimethyl-terephthalate", "ev-chemical-reactor-recipes", 12.5, EV_SPEED,
	{ { "terephthalic-acid", 100 }, { "methanol", 200 }, { "sulfuric-acid", 200 } },
	{ { "dimethyl-terephthalate", 100 }, { "diluted-sulfuric-acid", 200 } })
step(RECIPES, "sulfur-dichloride", "lv-chemical-reactor-recipes", 40, LV_SPEED, { { "sulfur", 8 }, { "chlorine", 1600 } },
	{ { "sulfur-dichloride", 800 } })
step(RECIPES, "thionyl-chloride", "hv-chemical-reactor-recipes", 7.5, HV_SPEED,
	{ { "sulfur-trioxide", 100 }, { "sulfur-dichloride", 100 } }, { { "thionyl-chloride", 100 }, { "sulfur-dioxide", 100 } })
step(RECIPES, "terephthaloyl-chloride-dust", "ev-chemical-reactor-recipes", 20, EV_SPEED,
	{ { "thionyl-chloride", 1800 }, { "dimethyl-terephthalate", 500 }, { "carbon-dioxide", 600 } },
	{ { "terephthaloyl-chloride-dust", 112 }, { "diluted-hydrochloric-acid", 2200 }, { "sulfur-dioxide", 1800 } })
--- N-methyl-2-pyrrolidone
step(RECIPES, "cupric-oxide-dust", "lv-chemical-reactor-recipes", 5, LV_SPEED, { { "copper-dust", 1 }, { "oxygen", 100 } },
	{ { "cupric-oxide-dust", 2 } })
step(RECIPES, "bismuth-iii-oxide-dust", "mv-chemical-reactor-recipes", 10, MV_SPEED, { { "bismuth", 4 }, { "oxygen", 600 } },
	{ { "bismuth-iii-oxide-dust", 10 } })
step(RECIPES, "2-butyne-1-4-diol-dust", "ev-chemical-reactor-recipes", 20, EV_SPEED,
	{ { "cupric-oxide-dust", 1 }, { "bismuth-iii-oxide-dust", 1 }, { "silicon-dioxide", 1 }, { "acetylene", 100 },
		{ "formaldehyde", 200 } }, { { "2-butyne-1-4-diol-dust", 12 } })
step(RECIPES, "nickel-aluminide-ingot", "hv-electric-blast-furnace-recipes", 45, HV_SPEED,
	{ { "nickel-dust", 1 }, { "aluminium-dust", 3 } }, { { "nickel-aluminide-ingot", 4 } })
step(RECIPES, "raney-nickel-dust", "ev-chemical-reactor-recipes", 60, EV_SPEED,
	{ { "nickel-aluminide-ingot", 4 }, { "sodium-hydroxide", 6 }, { "water", 200 } },
	{ { "raney-nickel-dust", 2 }, { "sodium-aluminate", 8 }, { "hydrogen", 600 } })
step(RECIPES, "1-4-butanediol", "uv-chemical-reactor-recipes", 15, UV_SPEED,
	{ { "2-butyne-1-4-diol-dust", 12 }, { "raney-nickel-dust", 1 }, { "hydrogen", 400 } }, { { "1-4-butanediol", 100 } })
step(RECIPES, "gamma-butyrolactone", "ev-chemical-reactor-recipes", 5, EV_SPEED,
	{ { "copper-dust", 1 }, { "1-4-butanediol", 100 } }, { { "gamma-butyrolactone", 100 }, { "hydrogen", 400 } })
step(RECIPES, "n-methyl-2-pyrrolidone", "iv-chemical-reactor-recipes", 30, IV_SPEED,
	{ { "methylamine", 100 }, { "gamma-butyrolactone", 100 } }, { { "n-methyl-2-pyrrolidone", 100 }, { "water", 100 } })
--- p-phenylenediamine
step(RECIPES, "acetic-anhydride", "hv-dehydrator-recipes", 30, HV_SPEED, { { "acetic-acid", 200 } },
	{ { "acetic-anhydride", 100 } })
step(RECIPES, "4-nitroaniline", "ev-chemical-reactor-recipes", 15, EV_SPEED,
	{ { "aniline", 100 }, { "acetic-anhydride", 10 }, { "nitration-mixture", 200 } },
	{ { "4-nitroaniline", 100 }, { "diluted-sulfuric-acid", 100 } })
step(RECIPES, "p-phenylenediamine-dust", "uv-chemical-reactor-recipes", 20, UV_SPEED,
	{ { "palladium-dust", 1 }, { "nitrogen-dioxide", 10 }, { "hydrogen", 600 }, { "4-nitroaniline", 100 } },
	{ { "p-phenylenediamine-dust", 16 }, { "water", 200 } })
--- MDI
step(RECIPES, "diaminodiphenylmethane-mixture", "ev-chemical-reactor-recipes", 60, EV_SPEED,
	{ { "formaldehyde", 100 }, { "aniline", 200 }, { "hydrochloric-acid", 100 } }, { { "diaminodiphenylmethane-mixture", 100 } })
step(RECIPES, "diphenylmethane-diisocyanate-mixture", "ev-chemical-reactor-recipes", 30, EV_SPEED,
	{ { "diaminodiphenylmethane-mixture", 100 }, { "phosgene", 200 } }, { { "diphenylmethane-diisocyanate-mixture", 100 } })
step(RECIPES, "diphenylmethane-diisocyanate-dust", "ev-tall-distillation-recipes", 125, EV_SPEED,
	{ { "diphenylmethane-diisocyanate-mixture", 100 } },
	{ { "diphenylmethane-diisocyanate-dust", 29 }, { "hydrochloric-acid", 500 } })
--- the resin's other inputs
step(RECIPES, "pentaerythritol-dust", "hv-chemical-reactor-recipes", 30, HV_SPEED,
	{ { "sodium-hydroxide", 1 }, { "formaldehyde", 400 }, { "acetaldehyde", 100 } },
	{ { "pentaerythritol-dust", 21 }, { "carbon-monoxide", 100 } })
step(RECIPES, "dimethyldichlorosilane", "mv-chemical-reactor-recipes", 12, MV_SPEED,
	{ { "raw-silicon", 1 }, { "chloromethane", 200 } }, { { "dimethyldichlorosilane", 100 } })
step(RECIPES, "silicon-oil", "ev-chemical-reactor-recipes", 0.75, EV_SPEED,
	{ { "ethylene-oxide", 100 }, { "dimethyldichlorosilane", 400 }, { "water", 500 } }, { { "silicon-oil", 500 } })
step(RECIPES, "propionic-acid", "ev-chemical-reactor-recipes", 10, EV_SPEED,
	{ { "ethylene", 100 }, { "carbon-monoxide", 100 }, { "nickel-tetracarbonyl", 10 }, { "water", 100 } },
	{ { "propionic-acid", 100 } })
step(RECIPES, "rhodium-chloride-dust", "hv-electric-blast-furnace-recipes", 30, HV_SPEED,
	{ { "rhodium-dust", 1 }, { "chlorine", 300 } }, { { "rhodium-chloride-dust", 4 } })
step(RECIPES, "phosphorus-trichloride", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "phosphorus", 1 }, { "chlorine", 300 } }, { { "phosphorus-trichloride", 100 } })
step(RECIPES, "triphenylphosphine-dust", "ev-chemical-reactor-recipes", 20, EV_SPEED,
	{ { "sodium", 6 }, { "phosphorus-trichloride", 100 }, { "chlorobenzene", 300 } },
	{ { "triphenylphosphine-dust", 34 }, { "salt", 12 } })
step(RECIPES, "sodium-hydride-dust", "mv-chemical-reactor-recipes", 10, MV_SPEED, { { "sodium", 1 }, { "hydrogen", 100 } },
	{ { "sodium-hydride-dust", 2 } })
step(RECIPES, "trimethyl-borate", "ev-chemical-reactor-recipes", 30, EV_SPEED,
	{ { "methanol", 300 }, { "boric-acid", 100 }, { "sulfuric-acid", 600 } },
	{ { "diluted-sulfuric-acid", 600 }, { "trimethyl-borate", 100 } }, "trimethyl-borate")
step(RECIPES, "sodium-borohydride-dust", "ev-chemical-reactor-recipes", 30, EV_SPEED,
	{ { "sodium-hydride-dust", 8 }, { "trimethyl-borate", 100 } },
	{ { "sodium-borohydride-dust", 6 }, { "sodium-methoxide-dust", 18 } })
step(RECIPES, "sodium-methoxide-hydrolysis", "hv-chemical-reactor-recipes", 10, HV_SPEED,
	{ { "sodium-methoxide-dust", 6 }, { "water", 100 } }, { { "sodium-hydroxide", 3 }, { "methanol", 100 } })
step(RECIPES, "organorhodium-catalyst-dust", "uv-chemical-reactor-recipes", 40, UV_SPEED,
	{ { "rhodium-chloride-dust", 4 }, { "triphenylphosphine-dust", 102 }, { "sodium-borohydride-dust", 18 },
		{ "carbon-monoxide", 100 } },
	{ { "organorhodium-catalyst-dust", 106 }, { "salt", 6 }, { "boron", 3 }, { "hydrogen", 1100 } })
step(RECIPES, "butyraldehyde", "lv-chemical-reactor-recipes", 100, LV_SPEED,
	{ { "organorhodium-catalyst-dust", 1 }, { "hydrogen", 3600 }, { "propene", 1800 }, { "carbon-monoxide", 1800 } },
	{ { "butyraldehyde", 900 }, { "isobutyraldehyde", 900 } })
step(RECIPES, "butanol", "hv-chemical-reactor-recipes", 4, HV_SPEED,
	{ { "palladium-dust", 1 }, { "butyraldehyde", 900 }, { "hydrogen", 1800 } }, { { "butanol", 900 } })
step(RECIPES, "polyurethane-catalyst-a-dust", "ev-chemical-reactor-recipes", 30, EV_SPEED,
	{ { "tin-dust", 1 }, { "butanol", 200 }, { "propionic-acid", 100 }, { "iron-iii-chloride", 10 } },
	{ { "polyurethane-catalyst-a-dust", 1 } })
step(RECIPES, "polyurethane-resin", "uv-chemical-reactor-recipes", 10, UV_SPEED,
	{ { "polyurethane-catalyst-a-dust", 1 }, { "pentaerythritol-dust", 1 }, { "diphenylmethane-diisocyanate-dust", 5 },
		{ "ethylene-glycol", 400 }, { "silicon-oil", 100 } }, { { "polyurethane-resin", 100 } })
--- Kevlar
step(RECIPES, "liquid-crystal-kevlar", "uv-chemical-reactor-recipes", 30, UV_SPEED,
	{ { "calcium-chloride", 1 }, { "p-phenylenediamine-dust", 9 }, { "terephthaloyl-chloride-dust", 9 },
		{ "n-methyl-2-pyrrolidone", 100 } }, { { "liquid-crystal-kevlar", 900 }, { "diluted-hydrochloric-acid", 200 } })
step(RECIPES, "kevlar-fiber", "ev-fluid-solidifier-recipes", 40, EV_SPEED, { { "liquid-crystal-kevlar", 14.4 } },
	{ { "kevlar-fiber", 8 } })
step(RECIPES, "woven-kevlar", "ev-assembling-machine-recipes", 15, EV_SPEED, { { "kevlar-fiber", 8 } }, { { "woven-kevlar", 1 } })
step(RECIPES, "kevlar-plate", "lv-chemical-bath-recipes", 60, LV_SPEED, { { "woven-kevlar", 1 }, { "polyurethane-resin", 100 } },
	{ { "kevlar-plate", 1 } })
step(RECIPES, "melt-kevlar-plate", "ev-fluid-extractor-recipes", 1.2, EV_SPEED, { { "kevlar-plate", 1 } },
	{ { "molten-kevlar", 14.4 } })
for _, r in pairs(RECIPES) do fork_add_unlock(KEVLAR, r) end
--- GTNH's Kevlar users the mod has
local function swap(recipe, old, new, amount)
	local r = data.raw.recipe[recipe]
	for _, i in pairs(r.ingredients) do
		if i.name == old then
			i.name, i.type, i.amount = new, data.raw.fluid[new] and "fluid" or "item", amount or i.amount
			return
		end
	end
	error("issue #378: " .. recipe .. " has no " .. old)
end
swap("uxv-pump", "silicone-rubber-ring", "kevlar-ring")
swap("uxv-conveyor-module", "silicone-rubber-sheet", "kevlar-plate")
swap("uxv-machine-hull", "polybenzimidazole", "molten-kevlar", 57.6)
--- the ring is cast from the melt (143 ran before this file: its run again makes only what is new) and UXV Components
--- needs the Kevlar technology (#252)
FORK_CASTING.run()
table.insert(data.raw.technology["uxv-components"].prerequisites, KEVLAR)




--------------------------------------------------------------------------------
--- 12) RADOX POLYMER (issue #378 (c), the maintainer's decision: GTNH's chain with named stand-ins for what the mod
--- lacks). GTNH (NewHorizonsCoreMod bartworksHandler/BacteriaRegistry.java:98-178, gthandler/recipes/
--- CrackingRecipes.java:13-19), fluids a tenth of GT's litres:
---   antimony trioxide: 2 antimony + 3000 oxygen -> 5 (LV, 1 s; GT ChemicalRecipes.java:3706-3713)
---   xenoxene: bacterial vat, 16 antimony trioxide + 16 osmium dust + 20 oil -> 20 xenoxene (UEV, 180 s; :174-178)
---   raw radox: pyrolyse oven, 64 Barnarda C logs + 1000 xenoxene -> 1000 + 8 ash (UV, 180 s; :124-127)
---   its distillation tower: 5000 -> 600 heavy oil, 300 oil, 1000 creosote, 1400 water, 50 fermented bacterial sludge,
---     50 fermented biomass, 100 super heavy radox, 150 heavy radox, 50 diluted xenoxene, 300 light radox, 500 super
---     light radox, 5 ash (UHV, 40 s; :129-142)
---   cracking with 1 L silver plasma each (UV, 25 s): 100 super light -> 100 cracked radox, 100 light -> 50 super light,
---     100 heavy -> 20 light (:144-146, CrackingRecipes.java:13-19); cracked radox's distillation: 1000 -> 100 radox gas
---     + 200 light radox + an ash (UV, 30 s; :148-150); diluted xenoxene's: 1000 -> 250 xenoxene + 300 light radox +
---     an ash (UV, 30 s; :100-102); super heavy radox in the centrifuge: 1000 -> 2000 heavy (UV, 50 min; :111-113)
---   radox polymer: large chemical reactor, 2160 radox gas + 7500 oxygen plasma + 100 titanium plasma -> 720 molten
---     (5 ingots; UV, 30 s; :165-168)
--- STAND-INS (also in docs/ROADMAP.md):
---   * the Xenoxsis culture (GTNH: a petri dish from the bio lab or the beamcrafter; the mod has neither) is the mod's
---     mutagen (125's vat line), 100 per run, used up where GT keeps its dish;
---   * xenoxene in the bacterial vat: the vat's glass tier and radiation are not modelled; its output multiplier is taken
---     at its maximum (bartworks MTEBioVat.java:238-251, 318-336: oil and xenoxene x 1001 with a half full output
---     hatch), so a run turns 2002 oil (GT's Oil: the mod's crude oil) into 2002 xenoxene;
---   * GalaxySpace's Barnarda C logs (64 per pyrolysis; Barnarda C is GTNH's T8 world, the mod has no mine of it) are
---     the mod's wood;
---   * GT's fermented bacterial sludge of the distillation is left out (the mod has none) and GT's low gravity autoclave
---     recipes (enriched naquadah and naquadria from radox) are not made (no low gravity in the mod).
--- The melt casts the radox polymer plate and ring (143). GTNH's users the mod has: the UXV pump (64 radox rings next to
--- the Kevlar rings) and the UXV conveyor (80 radox plates next to the Kevlar plates).
--------------------------------------------------------------------------------

local RADOX = "radox-polymer"
--- (GT's colours, MaterialsInit.java)
for _, f in pairs({
	{ "xenoxene", "black-fluid", { 0.52, 0.51, 0.50 } },
	{ "diluted-xenoxene", "black-fluid", { 0.81, 0.78, 0.77 } },
	{ "raw-radox", "purple-fluid", { 0.31, 0.12, 0.31 } },
	{ "super-heavy-radox", "purple-fluid", { 0.39, 0.00, 0.39 } },
	{ "heavy-radox", "purple-fluid", { 0.45, 0.00, 0.45 } },
	{ "light-radox", "purple-fluid", { 0.55, 0.00, 0.55 } },
	{ "super-light-radox", "purple-fluid", { 0.61, 0.00, 0.61 } },
	{ "cracked-radox", "purple-fluid", { 0.71, 0.51, 0.71 } },
	{ "radox-gas", "purple-fluid", { 1.00, 0.51, 1.00 } },
	{ "molten-radox-polymer", "molten-radox-polymer", { 0.52, 0.00, 0.50 } },   -- (143 casts it: its MATERIALS)
}) do
	F.fluid(f[1], f[2], f[3])
end
for _, n in pairs({ "antimony-trioxide-dust", "radox-polymer-plate", "radox-polymer-ring" }) do
	create_item{ skip_recipe = true, name = n, subgroup = "subgroup-macerator-dust" }
end

RECIPES = {}
step(RECIPES, "antimony-trioxide-dust", "lv-chemical-reactor-recipes", 1, LV_SPEED, { { "antimony", 2 }, { "oxygen", 300 } },
	{ { "antimony-trioxide-dust", 5 } })
step(RECIPES, "xenoxene", "bacterial-vat-recipes", 180, 1,
	{ { "antimony-trioxide-dust", 16 }, { "osmium-dust", 16 }, { "crude-oil", 2002 }, { "mutagen", 100 } },
	{ { "xenoxene", 2002 } })
step(RECIPES, "raw-radox", "pyrolyse-oven-recipes", 180, UV_SPEED, { { "wood", 64 }, { "xenoxene", 100 } },
	{ { "raw-radox", 100 }, { "ash-dust", 8 } })
step(RECIPES, "raw-radox-distillation", "uhv-tall-distillation-recipes", 40, UHV_SPEED, { { "raw-radox", 500 } },
	{ { "heavy-oil", 60 }, { "crude-oil", 30 }, { "creosote", 100 }, { "water", 140 }, { "fermented-biomass", 5 },
		{ "super-heavy-radox", 10 }, { "heavy-radox", 15 }, { "diluted-xenoxene", 5 }, { "light-radox", 30 },
		{ "super-light-radox", 50 }, { "ash-dust", 1, 0.5 } }, "super-light-radox")
step(RECIPES, "super-light-radox-cracking", "uv-cracker-recipes", 25, UV_SPEED,
	{ { "super-light-radox", 10 }, { "silver-plasma", 0.1 } }, { { "cracked-radox", 10 } })
step(RECIPES, "light-radox-cracking", "uv-cracker-recipes", 25, UV_SPEED,
	{ { "light-radox", 10 }, { "silver-plasma", 0.1 } }, { { "super-light-radox", 5 } })
step(RECIPES, "heavy-radox-cracking", "uv-cracker-recipes", 25, UV_SPEED,
	{ { "heavy-radox", 10 }, { "silver-plasma", 0.1 } }, { { "light-radox", 2 } })
step(RECIPES, "cracked-radox-distillation", "uv-tall-distillation-recipes", 30, UV_SPEED, { { "cracked-radox", 100 } },
	{ { "radox-gas", 10 }, { "light-radox", 20 }, { "ash-dust", 1, 0.1 } })
step(RECIPES, "diluted-xenoxene-distillation", "uv-tall-distillation-recipes", 30, UV_SPEED, { { "diluted-xenoxene", 100 } },
	{ { "xenoxene", 25 }, { "light-radox", 30 }, { "ash-dust", 1, 0.1 } })
step(RECIPES, "super-heavy-radox-centrifuging", "uv-centrifuge-recipes", 3000, UV_SPEED, { { "super-heavy-radox", 100 } },
	{ { "heavy-radox", 200 } })
step(RECIPES, "molten-radox-polymer", "uv-chemical-reactor-recipes", 30, UV_SPEED,
	{ { "radox-gas", 216 }, { "oxygen-plasma", 750 }, { "titanium-plasma", 10 } }, { { "molten-radox-polymer", 72 } })
F.tech{
	--- (UEV: the vat's xenoxene; the UHV distillation tower, the fusion plasmas of MK3 (silver, #375), the vat)
	name = RADOX, prerequisites = { "uev-machines", "uhv-multiblocks", "fusion-plasmas-mk3", "bacterial-vat" }, packs = 11,
	count = 1500, time = 60, recipes = RECIPES,
}
--- GTNH's radox users the mod has: the UXV pump and conveyor take it next to the Kevlar (section 11)
for _, u in pairs({ { "uxv-pump", "radox-polymer-ring", 64 }, { "uxv-conveyor-module", "radox-polymer-plate", 80 } }) do
	table.insert(data.raw.recipe[u[1]].ingredients, { type = "item", name = u[2], amount = u[3] })
end
FORK_CASTING.materials["radox-polymer"] = { "uev", RADOX }
FORK_CASTING.run()
table.insert(data.raw.technology["uxv-components"].prerequisites, RADOX)



--------------------------------------------------------------------------------
--- 13) NAQUADAH FUEL RODS (issue #386 (1); gregtech/loaders/load/FissionFuelLoader.java:740-839, values
--- gregtech/loaders/preload/LoaderGTBlockFluid.java:595-630). GT's naquadah rod is a Large Tungstensteel Fluid Cell
--- (4 double tungstensteel plates and 4 platinum rings, HV assembler, 10 s; AssemblerRecipes.java:113-122) canned with
--- 3 enriched naquadah dust (LV, 1.5 s); 2 rods and 4 tungstensteel rods make a dual rod (HV, 5 s), 4 rods and 6 long
--- tungstensteel rods (7.5 s) or 2 duals and 4 tungstensteel rods (5 s) a quad rod. The depleted rods go into GT's EV
--- centrifuge (25 s, 50 s, 100 s): naquadah, naquadria, enriched naquadah, the cell's tungstensteel and platinum (in
--- GTNH bartworks turns a platinum dust output into two platinum metallic powder, PlatinumSludgeOutputs.java:53, as
--- #199 does).
--- Value (as section 9: the rod's energy over its life against the uranium rod's): GT's naquadah rod gives 4 per pulse
--- for 100 000 reactor seconds, the uranium rod 2 for 20 000: 10 times, 60 000 MJ; dual and quad 4 and 12 times that.
--- GT's quad rod heats less (heat 1 against 4); the mod's reactors have no hull heat, so only the energy counts.
--- GT's fifth rod, The Core (issue #402), at the end of the section.
--------------------------------------------------------------------------------

local NAQ_RODS = "naquadah-fuel-rods"
RECIPES = {}
create_item{
	name = "empty-large-tungstensteel-fluid-cell",
	category = "hv-assembling-machine-recipes",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "double-tungstensteel-plate", amount = 4 },
		{ type = "item", name = "platinum-ring", amount = 4 },
	},
	subgroup = ROD_GROUP,
}
RECIPES[#RECIPES + 1] = "empty-large-tungstensteel-fluid-cell"
RECIPES[#RECIPES + 1] = rod("naquadah-fuel-rod", 60000, "depleted-naquadah-fuel-rod", {
	{ type = "item", name = "empty-large-tungstensteel-fluid-cell", amount = 1 },
	{ type = "item", name = "enriched-naquadah-dust", amount = 3 },
}, "lv-canning-machine-recipes", 1.5)
local ND = rod("dual-naquadah-fuel-rod", 240000, "depleted-dual-naquadah-fuel-rod",
	{ { type = "item", name = "naquadah-fuel-rod", amount = 2 }, { type = "item", name = "tungstensteel-rod", amount = 4 } },
	"hv-assembling-machine-recipes", 5 * HV_SPEED)
local NQ = rod("quad-naquadah-fuel-rod", 720000, "depleted-quad-naquadah-fuel-rod",
	{ { type = "item", name = "naquadah-fuel-rod", amount = 4 }, { type = "item", name = "long-tungstensteel-rod", amount = 6 } },
	"hv-assembling-machine-recipes", 7.5 * HV_SPEED)
RECIPES[#RECIPES + 1] = ND
RECIPES[#RECIPES + 1] = NQ
create_recipe{
	name = NQ .. "-from-dual",
	category = "hv-assembling-machine-recipes",
	energy_required = 5 * HV_SPEED,
	ingredients = { { type = "item", name = ND, amount = 2 }, { type = "item", name = "tungstensteel-rod", amount = 4 } },
	results = { { type = "item", name = NQ, amount = 1 } },
}
RECIPES[#RECIPES + 1] = NQ .. "-from-dual"
--- the depleted rods: x 1, 2, 4 of the single rod's dusts (GT: 18 and 38 tungstensteel, the cells and the rods' steel)
for _, d in pairs({ { "depleted-naquadah-fuel-rod", 1, 8, 25 }, { "depleted-" .. ND, 2, 18, 50 },
		{ "depleted-" .. NQ, 4, 38, 100 } }) do
	local n = d[2]
	step(RECIPES, d[1] .. "-centrifuging", "ev-centrifuge-recipes", d[4], EV_SPEED, { { d[1], 1 } }, {
		{ "naquadah-dust", n }, { "naquadah-dust", n, 0.5 },
		n == 1 and { "small-pile-of-naquadria-dust", 2, 0.5 } or { "naquadria-dust", n / 2, 0.5 },
		{ "tiny-pile-of-enriched-naquadah-dust", 2 * n, 0.25 }, { "tungstensteel-dust", d[3] }, { "metallic-platinum-powder", 2 * n } })
end
F.tech{
	--- (LuV: enriched naquadah; the rods burn in the reactors of Nuclear Fuel Rods)
	name = NAQ_RODS, prerequisites = { "enriched-naquadah", "nuclear-fuel-rods" }, packs = 7, count = 1500, time = 60,
	recipes = RECIPES,
}
--- GT's fifth rod, The Core (issue #402): 32 rods, 3 x 64 long tungstensteel rods and 2 x 64 tiberium dust in the LuV
--- assembler (5 s; FissionFuelLoader.java:775-786). Value: 32 cells, 8 per pulse for 100 000 reactor seconds, 17 pulses
--- per cell (LoaderGTBlockFluid.java:631-642): 10 880 times a uranium rod. The depleted Core gives 8 depleted quad rods,
--- 2 x 64 zirconium dust at 50 % and 144 tungstensteel dust in the IV centrifuge (100 s; :827-839).
--- Its technology comes after Naquadah Fuel Rods and Reach Ross128ba, whose veins (#392) give bartworks' tiberium (#252;
--- Reach Ross128ba has higher science, as a prerequisite of Naquadah Fuel Rods it would hold the other rods back to ZPM).
RECIPES = {}
RECIPES[#RECIPES + 1] = rod("the-core", 65280000, "depleted-the-core", {
	{ type = "item", name = "naquadah-fuel-rod", amount = 32 },
	{ type = "item", name = "long-tungstensteel-rod", amount = 192 },
	{ type = "item", name = "tiberium-dust", amount = 128 },
}, "luv-assembling-machine-recipes", 5 * LUV_SPEED)
step(RECIPES, "depleted-the-core-centrifuging", "iv-centrifuge-recipes", 100, IV_SPEED, { { "depleted-the-core", 1 } }, {
	{ "depleted-" .. NQ, 8 }, { "zirconium-dust", 64, 0.5 }, { "zirconium-dust", 64, 0.5 }, { "tungstensteel-dust", 144 } })
F.tech{
	--- (ZPM: Reach Ross128ba)
	name = "the-core", prerequisites = { NAQ_RODS, "reach-ross128ba" }, packs = 8, count = 2000, time = 60,
	recipes = RECIPES,
}




--------------------------------------------------------------------------------
--- 14) THE ISOTOPES AND THE LFTR FUELS (issue #386 (2); the plan on #386: GT++'s fuels are made only in the Reactor
--- Fuel Processing Plant, so the plant comes with them). Fluids a tenth of GT's litres, GT's seconds x the tier speed.
--- The isotopes: GT's IV centrifuge of 8 depleted rods (or 4 dual, 2 quad; gregtech/loaders/load/FissionFuelLoader.java:
--- 134-175, 245-286, 354-395): 8 empty fuel rods back, the fuel's dust, thorium 232, uranium 232 and 233, plutonium 238
--- and 241, polonium, thallium and krypton (GT's chances; small and tiny piles make the dust at the crafting table, GT's
--- packager is not in the mod). GT's "uranium" dust is the mod's uranium 238, GT's "plutonium" its plutonium 239.
--- GT++'s fluoride chemistry (gtPlusPlus/xmod/gregtech/loaders/recipe/RecipeLoaderNuclear.java, N below):
---   lithium 7: laser engraver, 3 lithium + a white lens (the mod's: diamond) -> 1, EV, 120 s (RecipesLaserEngraver.java:
---     40-47); lithium hydroxide: 16 lithium 7 + 8000 oxygen + 8000 water -> 6912 L, LV, 300 s (N 125-132), its dust in the
---     dehydrator (144 L, MV, 1 s; N 272-277); lithium fluoride: 3 lithium hydroxide + 500 industrial strength HF -> 2 + 1000
---     water, LV, 120 s (N 116-123)
---   beryllium fluoride: beryllium hydroxide from 1 beryllium + 1000 oxygen + 1000 hydrogen -> 432 L (LV, 8 s; N 136-143),
---     its dust (GT++'s generated dehydrator recipe, 144 L, 16 EU/t, 1.5 s; MaterialGenerator.java:181-191), ammonium
---     bifluoride from 2000 GT hydrofluoric acid + 1000 ammonia -> 576 L (LV, 40 s; N 157-165), ammonium
---     tetrafluoroberyllate from 3 beryllium hydroxide + 1152 L of it -> 1000 + 2000 water (MV, 300 s; N 314-322; or the
---     MV dehydrator in 6 s, N 305-312, its water left out: one fluid output), beryllium fluoride from 1000 of it -> 3 +
---     2000 ammonia + 1000 industrial strength HF (MV, 300 s; N 341-350)
---   zirconium tetrafluoride: the zirconium pellet (autoclave, 1 zirconium + 4000 chlorine, LV, 15 s; N 67-75), 5
---     zirconium tetrachloride from it (macerator, 20 s; N 527-534; the mod's zirconium tetrachloride of 159 is the same
---     chemical and serves as GT++'s), cooked in the blast furnace (HV, 60 s; N 89-95), with 800 GT hydrofluoric acid (HV,
---     30 s) or 400 industrial strength HF (15 s) into 1 + 800 hydrochloric acid in the HV dehydrator (N 281-300)
---   thorium tetrafluoride (GoodGenerator, goodgenerator/loader/RecipeLoader.java:308-349): thorium nitrate (1 thorium +
---     100 HF + 8000 nitric acid -> 1000 + 4000 NO2, MV, 2 s), thorium hydroxide (12 sodium hydroxide + 1000 -> 9 + 20
---     sodium nitrate, MV, 10 s), 9 of it + 4000 HF -> 1000 L (LV, 20 s)
---   uranium tetrafluoride: mixer, 4 uranium 233 + 1 uranium 235 + 10 000 industrial strength HF -> 3600 L (HV, 150 s;
---     N 541-547)
---   industrial strength hydrofluoric acid (GT++'s, twice as strong as GT's; RecipesGregTech.java:279-288): the chemical
---     plant, 2000 of it + 5000 GT hydrofluoric acid -> 4500 (HV, 30 s); the first comes from beryllium fluoride above
---   the melts: lithium, beryllium and zirconium fluoride from the dust (fluid extractor, 144 L, HV 5 s, HV 5 s, EV 10 s;
---     N 399-413, 438-443), uranium 235 as GT's other melts (1.2 s, 136's transmutation melts)
---   LFTR Fuel 1 to 3 in the Reactor Fuel Processing Plant (RecipeLoaderNuclearFuelProcessing.java:34-65): 550 lithium
---     fluoride + 150 beryllium fluoride + 60 zirconium tetrafluoride + 240 uranium 235 (EV, 30 min); 600 + 250 + 80
---     zirconium tetrafluoride + 70 uranium tetrafluoride (IV, 40 min); 580 + 270 + 80 thorium tetrafluoride + 70 uranium
---     tetrafluoride (IV, 50 min); 1000 each
--- Left out: GT++'s routes through lithium carbonate (the sulfuric lithium mix of lepidolite, the chemical bath; the mod
--- has no lithium carbonate) and the beryllium fluoride dehydrator (two fluid outputs). GT's plutonium 241 melts for
--- americium plasma (136 section 1d), so the MOX isotopes come with Fusion Plasmas MK3, where plutonium 241 is first used
--- (#252); the others with the LFTR's technology, which (3) gives the reactor.
--------------------------------------------------------------------------------

local LFTR = "liquid-fluoride-thorium-reactor"
local DUSTS = data.raw.item["uranium-235-dust"].subgroup
local function dust(name)
	if not data.raw.item[name] then create_item{ skip_recipe = true, name = name, subgroup = DUSTS } end
end
--- a small (4 make a dust) or tiny (9) pile and its crafting table recipe; `only` when nothing else makes the dust
local function pile(d, kind, only)
	dust(d)
	local p = kind .. "-pile-of-" .. d
	if not data.raw.item[p] then create_item{ skip_recipe = true, name = p, subgroup = data.raw.item[d].subgroup } end
	local r = d .. "-from-" .. kind .. "-piles"
	if not data.raw.recipe[r] then
		create_recipe{
			name = r, category = "crafting", energy_required = 0.5, subgroup = DUSTS,
			ingredients = { { type = "item", name = p, amount = kind == "small" and 4 or 9 } },
			results = { { type = "item", name = d, amount = 1 } },
		}
	end
	if only then
		FORK_RECIPES_TABLE_ONLY[r] = "GTNH: the dust comes only from the piles of GT's IV centrifuge of depleted rods "
			.. "(FissionFuelLoader.java), and the piles make the dust in GT's packager, which the mod does not have"
	end
	return p, r
end

RECIPES = {}
local MK3 = {}
for _, d in pairs({ { "thorium-232-dust" }, { "polonium-dust", "small" }, { "thallium-dust", "tiny" },
		{ "uranium-232-dust", "small" }, { "uranium-233-dust", "small" }, { "plutonium-238-dust", "tiny" },
		{ "plutonium-241-dust", "tiny" } }) do
	dust(d[1])
	if d[2] then
		local _, r = pile(d[1], d[2], true)
		local list = d[1]:find("^plutonium") and MK3 or RECIPES
		list[#list + 1] = r
	end
end
for _, d in pairs({ { "lutetium-dust", "small" }, { "uranium-235-dust", "small" } }) do
	local _, r = pile(d[1], d[2])
	RECIPES[#RECIPES + 1] = r
end
RECIPES[#RECIPES + 1] = select(2, pile("plutonium-239-dust", "tiny"))   -- (the uranium isotopes give it too)
local ISOTOPES = {
	--  fuel        GT s  outputs after the empty rods and the fuel's 2 dusts                                     krypton
	{ "thorium",   125, "thorium-dust", { { "thorium-232-dust", 1, 0.5 }, { "small-pile-of-lutetium-dust", 1, 0.5 },
		{ "small-pile-of-polonium-dust", 1, 0.5 }, { "tiny-pile-of-thallium-dust", 1, 0.25 } }, 3, RECIPES },
	{ "uranium",   250, "uranium-238-dust", { { "small-pile-of-uranium-232-dust", 1, 0.1 },
		{ "small-pile-of-uranium-233-dust", 1, 0.1 }, { "small-pile-of-uranium-235-dust", 1, 0.1 },
		{ "tiny-pile-of-plutonium-239-dust", 1, 0.05 } }, 6, RECIPES },
	{ "mox",       375, "plutonium-239-dust", { { "tiny-pile-of-plutonium-241-dust", 1, 0.05 },
		{ "tiny-pile-of-plutonium-239-dust", 1, 0.05 }, { "tiny-pile-of-plutonium-238-dust", 1, 0.05 },
		{ "tiny-pile-of-plutonium-239-dust", 1, 0.05 } }, 9, MK3 },
}
for _, f in pairs(ISOTOPES) do
	for _, v in pairs({ { "", 8 }, { "dual-", 4 }, { "quad-", 2 } }) do
		local depleted = "depleted-" .. v[1] .. f[1] .. "-fuel-rod"
		local results = { { "empty-fuel-rod", 8 }, { f[3], 2 } }
		for _, o in pairs(f[4]) do results[#results + 1] = o end
		results[#results + 1] = { "krypton", f[5] }
		step(f[6], depleted .. "-isotope-centrifuging", "iv-centrifuge-recipes", f[2], IV_SPEED, { { depleted, v[2] } }, results,
			"empty-fuel-rod")
	end
end
--- plutonium 241's melt for americium plasma (136; as 136's transmutation melts)
create_recipe{
	name = "melt-plutonium-241-dust", category = "iv-fluid-extractor-recipes", energy_required = 1.2 * IV_SPEED,
	ingredients = { { type = "item", name = "plutonium-241-dust", amount = 1 } },
	results = { { type = "fluid", name = "molten-plutonium-241", amount = 14.4 } }, main_product = "molten-plutonium-241",
}
MK3[#MK3 + 1] = "melt-plutonium-241-dust"
for _, r in pairs(MK3) do fork_add_unlock("fusion-plasmas-mk3", r) end

--- the fluorides
for _, f in pairs({
	{ "industrial-strength-hydrofluoric-acid", "rich-green-fluid", { 0.00, 0.53, 0.00 } },
	{ "lithium-hydroxide", "nearly-white-fluid", { 0.85, 0.85, 0.85 } },
	{ "beryllium-hydroxide", "pale-green-fluid", { 0.38, 0.53, 0.38 } },
	{ "ammonium-bifluoride", "deep-blue-fluid", { 0.00, 0.60, 0.85 } },
	{ "ammonium-tetrafluoroberyllate", "deep-blue-fluid", { 0.15, 0.55, 0.65 } },
	{ "thorium-nitrate", "nearly-white-fluid", { 0.75, 0.75, 0.75 } },
	{ "thorium-tetrafluoride", "forest-green-fluid", { 0.20, 0.60, 0.20 } },
	{ "uranium-tetrafluoride", "forest-green-fluid", { 0.16, 0.73, 0.16 } },
	{ "lithium-fluoride", "nearly-white-fluid", { 0.94, 0.94, 0.94 } },
	{ "beryllium-fluoride", "pale-green-fluid", { 0.47, 0.78, 0.47 } },
	{ "zirconium-tetrafluoride", "nearly-white-fluid", { 0.67, 0.67, 0.67 } },
	{ "molten-uranium-235", "molten-uranium-235", { 0.27, 0.86, 0.27 } },
	{ "lftr-fuel-1", "spackled-forest-green-fluid", { 0.24, 0.65, 0.24 } },
	{ "lftr-fuel-2", "spackled-forest-green-fluid", { 0.24, 0.55, 0.40 } },
	{ "lftr-fuel-3", "spackled-forest-green-fluid", { 0.40, 0.55, 0.24 } },
}) do
	F.fluid(f[1], f[2], f[3])
end
for _, n in pairs({ "lithium-7-dust", "lithium-hydroxide-dust", "lithium-fluoride-dust", "beryllium-hydroxide-dust",
		"beryllium-fluoride-dust", "zirconium-pellet", "cooked-zirconium-tetrachloride-dust", "zirconium-tetrafluoride-dust",
		"thorium-hydroxide-dust" }) do
	dust(n)
end
local ISHF = "industrial-strength-hydrofluoric-acid"
step(RECIPES, "lithium-7-dust", "ev-laser-engraver-recipes", 120, EV_SPEED, { { "lithium", 3 }, { "diamond-lens", 1 } },
	{ { "lithium-7-dust", 1 }, { "diamond-lens", 1 } }, "lithium-7-dust")
step(RECIPES, "lithium-hydroxide", "lv-chemical-reactor-recipes", 300, LV_SPEED,
	{ { "lithium-7-dust", 16 }, { "oxygen", 800 }, { "water", 800 } }, { { "lithium-hydroxide", 691.2 } })
step(RECIPES, "lithium-hydroxide-dust", "mv-dehydrator-recipes", 1, MV_SPEED, { { "lithium-hydroxide", 14.4 } },
	{ { "lithium-hydroxide-dust", 1 } })
step(RECIPES, "lithium-fluoride-dust", "lv-chemical-reactor-recipes", 120, LV_SPEED,
	{ { "lithium-hydroxide-dust", 3 }, { ISHF, 50 } }, { { "lithium-fluoride-dust", 2 }, { "water", 100 } })
step(RECIPES, "beryllium-hydroxide", "lv-chemical-reactor-recipes", 8, LV_SPEED,
	{ { "beryllium-dust", 1 }, { "oxygen", 100 }, { "hydrogen", 100 } }, { { "beryllium-hydroxide", 43.2 } })
step(RECIPES, "beryllium-hydroxide-dust", "lv-dehydrator-recipes", 1.5, LV_SPEED, { { "beryllium-hydroxide", 14.4 } },
	{ { "beryllium-hydroxide-dust", 1 } })
step(RECIPES, "ammonium-bifluoride", "lv-chemical-reactor-recipes", 40, LV_SPEED,
	{ { "hydrofluoric-acid", 200 }, { "ammonia", 100 } }, { { "ammonium-bifluoride", 57.6 } })
step(RECIPES, "ammonium-tetrafluoroberyllate", "mv-chemical-reactor-recipes", 300, MV_SPEED,
	{ { "beryllium-hydroxide-dust", 3 }, { "ammonium-bifluoride", 115.2 } },
	{ { "ammonium-tetrafluoroberyllate", 100 }, { "water", 200 } })
step(RECIPES, "ammonium-tetrafluoroberyllate-dehydration", "mv-dehydrator-recipes", 6, MV_SPEED,
	{ { "beryllium-hydroxide-dust", 3 }, { "ammonium-bifluoride", 115.2 } }, { { "ammonium-tetrafluoroberyllate", 100 } })
step(RECIPES, "beryllium-fluoride-dust", "mv-chemical-reactor-recipes", 300, MV_SPEED,
	{ { "ammonium-tetrafluoroberyllate", 100 } },
	{ { "beryllium-fluoride-dust", 3 }, { "ammonia", 200 }, { ISHF, 100 } })
step(RECIPES, ISHF, "chemical-plant-recipes", 30, HV_SPEED, { { ISHF, 200 }, { "hydrofluoric-acid", 500 } },
	{ { ISHF, 450 } })
step(RECIPES, "zirconium-pellet", "lv-autoclave-recipes", 15, LV_SPEED, { { "zirconium-dust", 1 }, { "chlorine", 400 } },
	{ { "zirconium-pellet", 1 } })
step(RECIPES, "zirconium-pellet-maceration", "lv-macerator-recipes", 20, LV_SPEED, { { "zirconium-pellet", 1 } },
	{ { "zirconium-tetrachloride", 5 } })
step(RECIPES, "cooked-zirconium-tetrachloride-dust", "hv-electric-blast-furnace-recipes", 60, HV_SPEED,
	{ { "zirconium-tetrachloride", 1 } }, { { "cooked-zirconium-tetrachloride-dust", 1 } })
step(RECIPES, "zirconium-tetrafluoride-dust", "hv-dehydrator-recipes", 30, HV_SPEED,
	{ { "cooked-zirconium-tetrachloride-dust", 1 }, { "hydrofluoric-acid", 80 } },
	{ { "zirconium-tetrafluoride-dust", 1 }, { "hydrochloric-acid", 80 } })
step(RECIPES, "zirconium-tetrafluoride-dust-ishf", "hv-dehydrator-recipes", 15, HV_SPEED,
	{ { "cooked-zirconium-tetrachloride-dust", 1 }, { ISHF, 40 } },
	{ { "zirconium-tetrafluoride-dust", 1 }, { "hydrochloric-acid", 80 } })
step(RECIPES, "thorium-nitrate", "mv-chemical-reactor-recipes", 2, MV_SPEED,
	{ { "thorium-dust", 1 }, { "hydrofluoric-acid", 10 }, { "nitric-acid", 800 } },
	{ { "thorium-nitrate", 100 }, { "nitrogen-dioxide", 400 } })
step(RECIPES, "thorium-hydroxide-dust", "mv-chemical-reactor-recipes", 10, MV_SPEED,
	{ { "sodium-hydroxide", 12 }, { "thorium-nitrate", 100 } },
	{ { "thorium-hydroxide-dust", 9 }, { "sodium-nitrate", 20 } })
step(RECIPES, "thorium-tetrafluoride", "lv-chemical-reactor-recipes", 20, LV_SPEED,
	{ { "thorium-hydroxide-dust", 9 }, { "hydrofluoric-acid", 400 } }, { { "thorium-tetrafluoride", 100 } })
step(RECIPES, "uranium-tetrafluoride", "hv-mixer-recipes", 150, HV_SPEED,
	{ { "uranium-233-dust", 4 }, { "uranium-235-dust", 1 }, { ISHF, 1000 } }, { { "uranium-tetrafluoride", 360 } })
for _, m in pairs({ { "lithium-fluoride", "hv", 5, HV_SPEED }, { "beryllium-fluoride", "hv", 5, HV_SPEED },
		{ "zirconium-tetrafluoride", "ev", 10, EV_SPEED } }) do
	step(RECIPES, "melt-" .. m[1] .. "-dust", m[2] .. "-fluid-extractor-recipes", m[3], m[4], { { m[1] .. "-dust", 1 } },
		{ { m[1], 14.4 } })
end
step(RECIPES, "melt-uranium-235-dust", "iv-fluid-extractor-recipes", 1.2, IV_SPEED, { { "uranium-235-dust", 1 } },
	{ { "molten-uranium-235", 14.4 } })
--- GT++'s chemical plant recipe of thorium 232 (RecipesGregTech.java:215-225; EV, 100 s): from plain thorium
step(RECIPES, "thorium-232-dust", "chemical-plant-recipes", 100, EV_SPEED,
	{ { "thorium-dust", 4 }, { "distilled-water", 200 }, { "boric-acid", 50 } },
	{ { "thorianite", 3 }, { "thorium-232-dust", 1 } }, "thorium-232-dust")
--- GT++'s Reactor Fuel Processing Plant (IV; gtPlusPlus/xmod/gregtech/common/tileentities/machines/multi/production/
--- MTERefinery.java; machine type "Fuel Refinery, RFPP"): GT++'s fluid-only map of the LFTR fuels, up to 6 fluids in and
--- 1 out, normal overclocks. Here a 3x3 machine with four fluid inputs and one output at IV speed, as 159's chemical plant.
--- Its item is the controller with the structure's casings (MTERefinery.java:140-194: 17 Hastelloy-N Sealant Blocks, at
--- least 7 Hastelloy-X Structural Blocks, 5 Incoloy-DS Fluid Containment Blocks, 4 Reactor Shield Casings), an IV
--- energy hatch and hulls for the maintenance, muffler (IV), 4 input and 1 output hatches (as #255). The controller is
--- GT++'s crafting recipe (RecipesMachinesCustom.java:531-537): 2 EV circuits, 2 dense tungstensteel plates, the
--- Gregtech Computer Cube, 2 Stellite gears and an IV hull (the soldering iron is a tool).
--------------------------------------------------------------------------------
local RFPP = "reactor-fuel-processing-plant"
local function port(kind, direction, position, volume)
	return {
		production_type = kind, volume = volume or 1000, pipe_covers = pipecoverspictures(),
		pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = kind, direction = direction, position = position } },
	}
end
local W, E = defines.direction.west, defines.direction.east
F.category("reactor-fuel-processing-recipes")
do
	local m = table.deepcopy(data.raw["assembling-machine"]["hv-chemical-reactor"])
	m.name = RFPP
	m.icons = nil
	m.icon = FORK_ICON .. RFPP .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = RFPP }
	m.crafting_categories = { "reactor-fuel-processing-recipes" }
	m.crafting_speed = IV_SPEED
	m.energy_usage = EU16_IV
	m.fast_replaceable_group = "fr-" .. RFPP
	m.next_upgrade = nil
	m.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fluid_boxes = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("input", W, { -1, 0 }),
		port("input", E, { 1, 0 }), port("output", S, { 0, 1 }, 2000) }
	m.fluid_boxes_off_when_no_fluid_recipe = false
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. RFPP .. "-idle.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. RFPP .. "-working.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
	}
	m.localised_description = { "entity-description." .. RFPP }
	data:extend({ m })
end
--- GT++'s three LFTR fuels (RecipeLoaderNuclearFuelProcessing.java:34-65)
step(RECIPES, "lftr-fuel-1", "reactor-fuel-processing-recipes", 1800, EV_SPEED,
	{ { "lithium-fluoride", 55 }, { "beryllium-fluoride", 15 }, { "zirconium-tetrafluoride", 6 },
		{ "molten-uranium-235", 24 } }, { { "lftr-fuel-1", 100 } })
step(RECIPES, "lftr-fuel-2", "reactor-fuel-processing-recipes", 2400, IV_SPEED,
	{ { "lithium-fluoride", 60 }, { "beryllium-fluoride", 25 }, { "zirconium-tetrafluoride", 8 },
		{ "uranium-tetrafluoride", 7 } }, { { "lftr-fuel-2", 100 } })
step(RECIPES, "lftr-fuel-3", "reactor-fuel-processing-recipes", 3000, IV_SPEED,
	{ { "lithium-fluoride", 58 }, { "beryllium-fluoride", 27 }, { "thorium-tetrafluoride", 8 },
		{ "uranium-tetrafluoride", 7 } }, { { "lftr-fuel-3", 100 } })

--- Hastelloy-N (GT++'s alloy, gtPlusPlus/core/material/MaterialsAlloy.java:329-342; the parts of the plant and the LFTR):
--- the alloy blast smelter melts 2 yttrium, 4 molybdenum, 2 chrome, 2 titanium and 15 nickel dust into 3600 L (EV, 40 s;
--- xmod/gregtech/loaders/RecipeGenBlastSmelter.java:117-183; GT++ has no mixer recipe for 5 components), cast by 143;
--- the plate also from the bender (1 ingot, EV, 1.5 s; RecipeGenPlates.java:68-77).
F.fluid("molten-hastelloy-n", "molten-hastelloy-n", { 0.59, 0.59, 0.67 })
for _, n in pairs({ "hastelloy-n-ingot", "hastelloy-n-plate" }) do
	create_item{ skip_recipe = true, name = n, subgroup = data.raw.item["hastelloy-x-plate"].subgroup }
end
step(RECIPES, "molten-hastelloy-n", "ev-alloy-blast-smelter-recipes", 40, EV_SPEED,
	{ { "yttrium-dust", 2 }, { "molybdenum-dust", 4 }, { "chromium-dust", 2 }, { "titanium-dust", 2 }, { "nickel-dust", 15 } },
	{ { "molten-hastelloy-n", 360 } })
step(RECIPES, "hastelloy-n-plate", "ev-bending-machine-recipes", 1.5, EV_SPEED, { { "hastelloy-n-ingot", 1 } },
	{ { "hastelloy-n-plate", 1 } })

--- The plant's parts (GT's crafting table recipes are the mod's crafting-or-assembling recipes):
---   Gregtech Computer Cube: 4 data orbs, 4 computer monitor covers, an IV hull, 2 ZPM circuits, 2304 L molten tantalum
---     (IV assembler, 180 s; gtPlusPlus/core/recipe/RecipesMachines.java:35-46); the Data Orb is NewHorizonsCoreMod's
---     circuit assembler recipe (gthandler/recipes/CircuitAssemblerRecipes.java:389-398: an advanced circuit board, the
---     mod's epoxy board, 2 nanoprocessors, the mod's HV circuit, 4 RAM, 32 NOR, 64 NAND chips, 32 fine platinum wire,
---     144 L solder; EV, 20 s); GT's Computer Monitor Cover is the mod's computer monitor
---   Hastelloy-N Sealant Block: 4 Incoloy MA956 and 4 Hastelloy-N plates, a Hastelloy C-276 frame (HV assembler, 5 s;
---     RecipesMachinesCustom.java:547-562)
---   Hastelloy-X Structural Block: 2 Inconel-792 rings, a Hastelloy-X gear, 2 steel plates, a C-276 frame, an EV
---     machine casing (crafting table; :564-569)
---   Incoloy-DS Fluid Containment Block: 4 Incoloy-DS plates, 2 huge Staballoy fluid pipes, 2 Incoloy-DS gears, a Super
---     Tank IV (crafting table; :539-545). The huge pipe is GT++'s (GregtechConduits.java:699-707: extruder, 12 Staballoy
---     ingots, HV, 4 s); the Super Tank IV NewHorizonsCoreMod's (gthandler/recipes/AssemblerRecipes.java:2381-2390: 4 IV
---     circuits, 2 niobium-titanium plates, an EV pump, an HV field generator, a Hermetic Casing V; 5 s, LV) with the
---     Hermetic Casing V (:884-889: a large titanium fluid pipe and 8 tungstensteel plates, 5 s, LV) and GT's large
---     titanium pipe (ProcessingShaping.java:114-121: extruder, 6 titanium ingots, MV, 2.4 s). The mod has no fluid pipe
---     items of its own; these are the only ones, as parts.
---   Reactor Shield Casing: 4 double Hastelloy C-276 plates, 2 Talonite gears, an LV field generator (HV assembler, 5 s;
---     :496-511)
for _, n in pairs({ "data-orb", "gregtech-computer-cube", "hastelloy-n-sealant-block", "hastelloy-x-structural-block",
		"incoloy-ds-fluid-containment-block", "huge-staballoy-fluid-pipe", "large-titanium-fluid-pipe", "hermetic-casing-v",
		"super-tank-iv", "reactor-shield-casing" }) do
	create_item{ skip_recipe = true, name = n, subgroup = "subgroup-iv-age-multiblocks" }
end
step(RECIPES, "data-orb", "ev-circuit-assembler-recipes", 20, EV_SPEED,
	{ { "epoxy-printed-circuit-board", 1 }, { "processing-unit", 2 }, { "ram-chip", 4 }, { "nor-memory-chip", 32 },
		{ "nand-memory-chip", 64 }, { "fine-platinum-wire", 32 }, { "soldering-alloy", 14.4 } }, { { "data-orb", 1 } })
step(RECIPES, "gregtech-computer-cube", "iv-assembling-machine-recipes", 180, IV_SPEED,
	{ { "data-orb", 4 }, { "computer-monitor", 4 }, { "iv-machine-hull", 1 }, { "zpm-circuit", 2 },
		{ "molten-tantalum", 230.4 } }, { { "gregtech-computer-cube", 1 } })
step(RECIPES, "hastelloy-n-sealant-block", "hv-assembling-machine-recipes", 5, HV_SPEED,
	{ { "incoloy-ma956-plate", 4 }, { "hastelloy-n-plate", 4 }, { "hastelloy-c276-frame", 1 } },
	{ { "hastelloy-n-sealant-block", 1 } })
step(RECIPES, "hastelloy-x-structural-block", "crafting-or-assembling-recipes", 1, 1,
	{ { "inconel-792-ring", 2 }, { "large-hastelloy-x-gear", 1 }, { "steel-plate", 2 }, { "hastelloy-c276-frame", 1 },
		{ "ev-machine-casing", 1 } }, { { "hastelloy-x-structural-block", 1 } })
step(RECIPES, "huge-staballoy-fluid-pipe", "hv-extruder-recipes", 4, HV_SPEED, { { "staballoy-ingot", 12 } },
	{ { "huge-staballoy-fluid-pipe", 1 } })
step(RECIPES, "large-titanium-fluid-pipe", "mv-extruder-recipes", 2.4, MV_SPEED, { { "titanium-ingot", 6 } },
	{ { "large-titanium-fluid-pipe", 1 } })
step(RECIPES, "hermetic-casing-v", "lv-assembling-machine-recipes", 5, LV_SPEED,
	{ { "large-titanium-fluid-pipe", 1 }, { "tungstensteel-plate", 8 } }, { { "hermetic-casing-v", 1 } })
step(RECIPES, "super-tank-iv", "lv-assembling-machine-recipes", 5, LV_SPEED,
	{ { "iv-circuit", 4 }, { "niobium-titanium-plate", 2 }, { "ev-pump", 1 }, { "hv-field-generator", 1 },
		{ "hermetic-casing-v", 1 } }, { { "super-tank-iv", 1 } })
step(RECIPES, "incoloy-ds-fluid-containment-block", "crafting-or-assembling-recipes", 1, 1,
	{ { "incoloy-ds-plate", 4 }, { "huge-staballoy-fluid-pipe", 2 }, { "large-incoloy-ds-gear", 2 }, { "super-tank-iv", 1 } },
	{ { "incoloy-ds-fluid-containment-block", 1 } })
step(RECIPES, "reactor-shield-casing", "hv-assembling-machine-recipes", 5, HV_SPEED,
	{ { "double-hastelloy-c276-plate", 4 }, { "large-talonite-gear", 2 }, { "lv-field-generator", 1 } },
	{ { "reactor-shield-casing", 1 } })
create_item{
	name = RFPP,
	icon = FORK_ICON .. RFPP .. ".png",
	place_result = RFPP,
	subgroup = "subgroup-iv-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "dense-tungstensteel-plate", amount = 2 },
		{ type = "item", name = "gregtech-computer-cube", amount = 1 },
		{ type = "item", name = "large-stellite-gear", amount = 2 },
		{ type = "item", name = "iv-machine-hull", amount = 2 },   -- (the controller's and the muffler hatch's, IV)
		{ type = "item", name = "hastelloy-n-sealant-block", amount = 17 },
		{ type = "item", name = "hastelloy-x-structural-block", amount = 7 },
		{ type = "item", name = "incoloy-ds-fluid-containment-block", amount = 5 },
		{ type = "item", name = "reactor-shield-casing", amount = 4 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },   -- (maintenance, 4 input and 1 output hatches)
	},
}
RECIPES[#RECIPES + 1] = RFPP
F.tech{
	--- (IV: GT's IV centrifuge and the plant; the chemical plant, the dehydrators, the EV laser engraver, boric acid;
	--- the plant's Incoloy-DS and Hastelloy-X parts and the computer cube's ZPM circuits)
	name = LFTR, prerequisites = { "iv-machines", "nuclear-fuel-rods", "rocket-fuel", "hydrazine-rocket-fuels",
		"samaric-rare-earth-processing", "advanced-ev-machines", "lanthanum-hexaboride", "zyngen",
		"hyper-intensity-laser-engraver", "advanced-smds" },
	packs = 6, count = 1000, time = 60, recipes = RECIPES,
}
--- Hastelloy-N's casts (143: ingot and plate from the melt, the melt from the ingot)
FORK_CASTING.materials["hastelloy-n"] = { "ev", LFTR }
FORK_CASTING.run()
--- GoodGenerator's uranium carbide-thorium mixture (section 7) takes thorium 232
table.insert(data.raw.technology["thorium-based-liquid-fuel"].prerequisites, LFTR)




--------------------------------------------------------------------------------
--- 15) THE LFTR, ITS SALT PROCESSING AND THE SPARGE TOWER (issue #386 (3)). GT5-Unofficial 638b3f37ca, gtPlusPlus/xmod/
--- gregtech/loaders/recipe/RecipeLoaderLFTR.java (L), RecipeLoaderNuclearFuelProcessing.java (P), RecipeLoaderNuclear.java
--- (N), core/recipe/RecipesMachinesCustom.java (C); fluids a tenth of GT's litres, GT's seconds x the tier speed. GT's
--- cells are fluids here, so a recipe that takes and returns the same fluid in cells takes the difference.
--- The Liquid Fluoride Thorium Reactor (IV; xmod/gregtech/common/tileentities/machines/multi/production/
--- MTENuclearReactor.java): a run of 100 s burns 100 L fuel and 200 L lithium tetrafluoroberyllate (LFTB) into the
--- depleted salts and uranium hexafluoride (L 70-106), no power in, GT's EU/t out (4 dynamos x 8192, 32 768 and 131 072:
--- 32 768, 131 072 and 524 288 EU/t, 65.5 M, 262 M and 1049 M EU a run), and while it runs 1 to 10 L molten uranium 233
--- at 1 in 300 ticks (about 36.7 L a run; :516-529). Here a 3x3 machine that needs no power: GT's energy at 1 EU = 1 kJ
--- (as 136's fuels) at four amps of the fuel's tier, IV, LuV and ZPM (40.96, 81.92 and 163.84 MW), so a run takes 1600,
--- 3200 and 6400 s; the power comes from a hidden electric energy interface under it while it works (scripts/
--- fork-power.lua, the mod data `lftr`); its uranium 233 is a fixed 3.67 a run. Not modelled: GT's warm-up of 250 s
--- (efficiency) and its explosion. Its item: the controller (C 487-494: 2 LFTR Control Circuits, a 12x naquadah cable,
--- here 3 naquadah cables by wire count, 2 double Hastelloy-N plates, the computer cube, 2 thorium 232 plates, an IV
--- hull) and the structure (:204-248): 83 Hastelloy-N Reactor Casings, 48 Reactor Shield Casings, 4 dynamo hatches (IV),
--- hulls for 4 mufflers, 1 input and 4 output hatches (IV) and the maintenance hatch.
--- The parts: LFTR Control Circuit (HV assembler, LuV circuit + HV field generator, 240 s; C 521-529), Hastelloy-N
--- Reactor Casing (crafting table: 4 double Hastelloy-N plates, 4 heat-capacity reactor platings, a C-276 frame; C 513-519)
--- with NewHorizonsCoreMod's reactor platings (gthandler/recipes/AssemblerRecipes.java:1269-1283), thorium 232 ingot
--- (bartworks: blast furnace, 120 EU/t, 280.75 s) and plate (bender, LV, 11.6 s), Hastelloy-N's double plate (bender,
--- EV, 3 s) and ring (extruder, 4 from an ingot, EV, 3 s), its screws cast by 143.
--- LFTB (N 79-87, 392-397): blast furnace 4 lithium fluoride + 3 beryllium fluoride -> 7 (EV, 140 s), its melt (HV, 5 s).
--- The Reactor Processing Unit I and the Cold Trap I (IV single blocks, GregtechLFTR.java:30-80; 3x3 here) with GT++'s
--- recipes (P 70-205): the T and TB salts with fluorine into lithium (and beryllium) fluoride, protactinium and
--- fluorinated UF6, the U salt into phosphorous UF6 and the impure molten salt base; the cold trap takes sodium fluoride
--- and turns the UF6 salts into uranium hexafluoride (the mod's, the same chemical as GT++'s), fluorine, uranium 233
--- and phosphorus. Sodium fluoride (N 183-221): 3 sodium hydroxide + 1000 HF (or 500 industrial strength HF) -> 2 + 1000
--- water (LV, 60 s); its melt in the fluid extractor (GT: the fluid heater, which the mod does not have; HV, 30 s).
--- RPU I (C 588-594): 2 HV field generators, an IV robot arm, 2 Inconel-625 plates, 2 double Hastelloy-N plates and GT's
--- IV chemical reactor, which the mod lacks as a single block: its own parts instead (MTERecipeLoader.java:441-447: a
--- tungstensteel rotor, 2 platinum cables, an IV motor, 2 IV circuits, an IV hull; its 2 huge polyethylene pipes as 12
--- polyethylene sheets, as the mod's HV chemical reactor takes sheets for GT's pipe). Cold Trap I (C 572-578): 4
--- Inconel-625 plates, a double Hastelloy-X plate, an IV machine casing, 2 IV robot arms, a frost proof casing.
--- Uranium 233's melt solidifies into its dust (GT++: the ingot, which the mod does not have; as 136 does for uranium).
--- The Sparge Tower (LuV; processing/MTESpargeTower.java): helium through the U salt, fluorine through the T and TB salts
--- (L 110-153, IV, 25 s); GT gives each of the five gases a random 1 to 200 (10, 20) L and the rest of the sparge gas
--- back: here their mean (100.5, 5.5, 10.5 L). Its controller is GT++'s assembly line recipe (C 901-924; GT's research
--- item, Research on Gas Sparging, is left out: the mod's assembly lines take no research) with GT's IV distillery as the
--- mod's (the IV short distillation tower), on 4 Sparge Tower Exterior Casings (C 927-940) and GT++'s Integral
--- Encasement IV (RecipesMachinesTiered.java:534-546) and V (the mod's). HS188-A (MaterialsAlloy.java:548-563): the alloy
--- blast smelter, 10 cobalt, 10 hafnium, 8 talonite, 5 rhenium, 5 niobium carbide, 4 Hastelloy-X, 4 tungstensteel, 4
--- zirconium carbide dust -> 7200 L (IV, 300 s); talonite dust from GT++'s mixer (4 cobalt, 3 chrome, 2 phosphorus, 1
--- molybdenum; LV, 2.6 s), niobium carbide from niobium and carbon (HV, 2.2 s), Hastelloy-X dust from the ingot
--- (macerator), rhenium as GT++ roasts it from purified scheelite or molybdenite in the alloy blast smelter
--- (RecipesGregTech.java:1019-1040: 1.8 and 3.6 molten rhenium; IV), cast into an ingot and macerated.
--- Technologies: the reactor with Liquid Fluoride Thorium Reactor (its fuels', #252); Nuclear Salt Processing (IV) has
--- the RPU, the cold trap and what only they take; Sparge Tower (LuV) the tower and HS188-A.
--------------------------------------------------------------------------------

local REACTOR = "liquid-fluoride-thorium-reactor"
local SALTS, SPARGE = "nuclear-salt-processing", "sparge-tower"
RECIPES = {}
local SALT_RECIPES, SPARGE_RECIPES = {}, {}
for _, f in pairs({
	{ "lithium-tetrafluoroberyllate", "nearly-white-fluid", { 0.85, 0.95, 0.85 } },
	{ "uranium-depleted-molten-salt", "spackled-forest-green-fluid", { 0.30, 0.60, 0.30 } },
	{ "thorium-depleted-molten-salt", "dark-gray-spackled-fluid", { 0.30, 0.35, 0.30 } },
	{ "thorium-beryllium-depleted-molten-salt", "dark-gray-spackled-fluid", { 0.35, 0.45, 0.35 } },
	{ "helium-sparged-u-salt", "spackled-forest-green-fluid", { 0.40, 0.70, 0.40 } },
	{ "fluorine-sparged-t-salt", "dark-gray-spackled-fluid", { 0.40, 0.45, 0.40 } },
	{ "fluorine-sparged-tb-salt", "dark-gray-spackled-fluid", { 0.45, 0.55, 0.45 } },
	{ "fluorinated-uranium-hexafluoride", "forest-green-fluid", { 0.25, 0.75, 0.25 } },
	{ "phosphorous-uranium-hexafluoride", "forest-green-fluid", { 0.45, 0.70, 0.25 } },
	{ "impure-molten-salt-base", "medium-gray-fluid", { 0.55, 0.60, 0.55 } },
	{ "sodium-fluoride", "nearly-white-fluid", { 0.90, 0.90, 0.95 } },
	{ "neptunium-hexafluoride", "forest-green-fluid", { 0.40, 0.60, 0.20 } },
	{ "technetium-hexafluoride", "medium-gray-fluid", { 0.55, 0.55, 0.55 } },
	{ "selenium-hexafluoride", "light-orange-fluid", { 0.85, 0.60, 0.30 } },
	{ "molten-uranium-233", "molten-uranium-233", { 0.29, 0.86, 0.33 } },
	{ "molten-hs188-a", "molten-hs188-a", { 0.60, 0.55, 0.70 } },
	{ "molten-rhenium", "molten-rhenium", { 0.70, 0.70, 0.75 } },
}) do
	F.fluid(f[1], f[2], f[3])
end
for _, n in pairs({ "lithium-tetrafluoroberyllate-dust", "sodium-fluoride-dust", "protactinium-dust", "talonite-dust",
		"niobium-carbide-dust", "hastelloy-x-dust", "rhenium-dust" }) do
	dust(n)
end
local PARTS = data.raw.item["hastelloy-x-plate"].subgroup
for _, n in pairs({ "double-hastelloy-n-plate", "hastelloy-n-ring", "hastelloy-n-screw", "thorium-232-ingot",
		"thorium-232-plate", "rhenium-ingot", "hs188-a-ingot", "hs188-a-plate", "large-hs188-a-gear" }) do
	create_item{ skip_recipe = true, name = n, subgroup = PARTS }
end
for _, n in pairs({ "reactor-plating", "heat-capacity-reactor-plating", "hastelloy-n-reactor-casing", "lftr-control-circuit",
		"integral-encasement-iv", "sparge-tower-exterior-casing" }) do
	create_item{ skip_recipe = true, name = n, subgroup = "subgroup-iv-age-multiblocks" }
end

--- the reactor's parts and coolant
step(RECIPES, "double-hastelloy-n-plate", "ev-bending-machine-recipes", 3, EV_SPEED, { { "hastelloy-n-ingot", 2 } },
	{ { "double-hastelloy-n-plate", 1 } })
step(RECIPES, "hastelloy-n-ring", "ev-extruder-recipes", 3, EV_SPEED, { { "hastelloy-n-ingot", 1 } },
	{ { "hastelloy-n-ring", 4 } })
step(RECIPES, "thorium-232-ingot", "mv-electric-blast-furnace-recipes", 280.75, MV_SPEED, { { "thorium-232-dust", 1 } },
	{ { "thorium-232-ingot", 1 } })
step(RECIPES, "thorium-232-plate", "lv-bending-machine-recipes", 11.6, LV_SPEED, { { "thorium-232-ingot", 1 } },
	{ { "thorium-232-plate", 1 } })
step(RECIPES, "reactor-plating", "mv-assembling-machine-recipes", 20, MV_SPEED,
	{ { "dense-lead-plate", 1 }, { "advanced-alloy", 4 } }, { { "reactor-plating", 1 } })
step(RECIPES, "heat-capacity-reactor-plating", "hv-assembling-machine-recipes", 30, HV_SPEED,
	{ { "dense-copper-plate", 2 }, { "copper-plate", 1 }, { "silver-plate", 1 }, { "reactor-plating", 1 } },
	{ { "heat-capacity-reactor-plating", 1 } })
step(RECIPES, "hastelloy-n-reactor-casing", "crafting-or-assembling-recipes", 1, 1,
	{ { "double-hastelloy-n-plate", 4 }, { "heat-capacity-reactor-plating", 4 }, { "hastelloy-c276-frame", 1 } },
	{ { "hastelloy-n-reactor-casing", 1 } })
step(RECIPES, "lftr-control-circuit", "hv-assembling-machine-recipes", 240, HV_SPEED,
	{ { "luv-circuit", 1 }, { "hv-field-generator", 1 } }, { { "lftr-control-circuit", 1 } })
step(RECIPES, "lithium-tetrafluoroberyllate-dust", "ev-electric-blast-furnace-recipes", 140, EV_SPEED,
	{ { "lithium-fluoride-dust", 4 }, { "beryllium-fluoride-dust", 3 } }, { { "lithium-tetrafluoroberyllate-dust", 7 } })
step(RECIPES, "melt-lithium-tetrafluoroberyllate-dust", "hv-fluid-extractor-recipes", 5, HV_SPEED,
	{ { "lithium-tetrafluoroberyllate-dust", 1 } }, { { "lithium-tetrafluoroberyllate", 14.4 } })
step(RECIPES, "solidify-uranium-233-dust", "iv-fluid-solidifier-recipes", 1.6, IV_SPEED, { { "molten-uranium-233", 14.4 } },
	{ { "uranium-233-dust", 1 } })

--- the reactor
local function machine(def)
	local m = table.deepcopy(data.raw["assembling-machine"]["hv-chemical-reactor"])
	m.name = def.name
	m.icons = nil
	m.icon = FORK_ICON .. def.name .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = def.name }
	m.crafting_categories = { def.category }
	m.crafting_speed = def.speed
	m.energy_usage = def.energy or EU16_IV
	if def.energy_source then m.energy_source = def.energy_source end
	m.fast_replaceable_group = "fr-" .. def.name
	m.next_upgrade = nil
	m.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fluid_boxes = def.ports
	m.fluid_boxes_off_when_no_fluid_recipe = false
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-idle.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-working.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
	}
	m.localised_description = { "entity-description." .. def.name }
	F.category(def.category)
	data:extend({ m })
	create_item{
		name = def.name,
		icon = m.icon,
		place_result = def.name,
		subgroup = def.subgroup or "subgroup-iv-age-multiblocks",
		stack_size = 10,
		category = def.recipe[1],
		energy_required = def.recipe[2],
		ingredients = def.recipe[3],
	}
	def.list[#def.list + 1] = def.name
end
machine{
	name = REACTOR, category = "lftr-recipes", speed = 1, energy_source = { type = "void" }, energy = "1W",
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }, 2000), port("output", S, { -1, 1 }),
		port("output", S, { 0, 1 }, 2000), port("output", S, { 1, 1 }), port("output", E, { 1, 0 }) },
	list = RECIPES,
	recipe = { "crafting-or-assembling-recipes", 1, {
		{ type = "item", name = "lftr-control-circuit", amount = 2 },
		{ type = "item", name = "naquadah-cable", amount = 3 },
		{ type = "item", name = "double-hastelloy-n-plate", amount = 2 },
		{ type = "item", name = "gregtech-computer-cube", amount = 1 },
		{ type = "item", name = "thorium-232-plate", amount = 2 },
		{ type = "item", name = "iv-machine-hull", amount = 10 },   -- (the controller's, 4 mufflers, 1 input, 4 outputs)
		{ type = "item", name = "hastelloy-n-reactor-casing", amount = 83 },
		{ type = "item", name = "reactor-shield-casing", amount = 48 },
		{ type = "item", name = "iv-dynamo-hatch", amount = 4 },
		{ type = "item", name = "lv-machine-hull", amount = 1 },   -- (maintenance)
	} },
}
--- fuel, GT's EU per run (1 EU = 1 kJ), the tier's four amps, the depleted salt
local LFTR_POWER = {}
for _, f in pairs({ { 1, 65536000, EU32_IV, "thorium-depleted-molten-salt", 2.5, 5, 0.6 },
		{ 2, 262144000, EU32_LuV, "thorium-beryllium-depleted-molten-salt", 5, 10, 1.5 },
		{ 3, 1048576000, EU32_ZPM, "thorium-beryllium-depleted-molten-salt", 10, 20, 3 } }) do
	local watts = 4 * tonumber(f[3]:match("^[%d.]+")) * ({ kW = 1e3, MW = 1e6 })[f[3]:match("%a+$")]
	local name = "lftr-fuel-" .. f[1] .. "-burning"
	step(RECIPES, name, "lftr-recipes", f[2] * 1e3 / watts, 1,
		{ { "lftr-fuel-" .. f[1], 10 }, { "lithium-tetrafluoroberyllate", 20 } },
		{ { "uranium-depleted-molten-salt", f[5] }, { f[4], f[6] }, { "uranium-hexafluoride", f[7] },
			{ "molten-uranium-233", 3.67 } }, f[4])
	LFTR_POWER[name] = watts
end
do
	local md = data.raw["mod-data"]["fork-power"].data
	md.lftr = { [REACTOR] = LFTR_POWER }
	md.lftr_dynamo = "lftr-dynamo"
end
data:extend({ {
	type = "electric-energy-interface",
	name = "lftr-dynamo",
	icon = FORK_ICON .. REACTOR .. ".png",
	icon_size = 32,
	flags = { "not-on-map", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-flammable",
		"no-copy-paste", "not-selectable-in-game", "not-upgradable", "hide-alt-info" },
	hidden = true,
	selectable_in_game = false,
	collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
	collision_mask = { layers = {} },
	energy_source = { type = "electric", usage_priority = "secondary-output", buffer_capacity = "3MJ",
		output_flow_limit = "200MW", input_flow_limit = "0W" },
	energy_production = "0W",
	gui_mode = "none",
	localised_name = { "entity-name." .. REACTOR },
} })

--- the salt processing
local IV_CF = data.raw["assembling-machine"]["iv-centrifuge"]
local IV_POWER = IV_CF and IV_CF.energy_usage or EU16_IV
local IV_SUB = data.raw.item["iv-centrifuge"] and data.raw.item["iv-centrifuge"].subgroup
machine{
	name = "reactor-processing-unit-i", category = "reactor-processing-unit-recipes", speed = IV_SPEED,
	energy = IV_POWER, subgroup = IV_SUB,
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { -1, 1 }),
		port("output", S, { 0, 1 }), port("output", S, { 1, 1 }) },
	list = SALT_RECIPES,
	recipe = { "crafting-or-assembling-recipes", 1, {
		{ type = "item", name = "hv-field-generator", amount = 2 },
		{ type = "item", name = "iv-robot-arm", amount = 1 },
		{ type = "item", name = "inconel-625-plate", amount = 2 },
		{ type = "item", name = "double-hastelloy-n-plate", amount = 3 },   -- (GT's pattern FRP/DCD/PDF: 3; #406)
		{ type = "item", name = "tungstensteel-rotor", amount = 1 },   -- GT's IV chemical reactor ...
		{ type = "item", name = "platinum-cable", amount = 2 },
		{ type = "item", name = "iv-motor", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "polyethylene-sheet", amount = 12 },   -- ... its 2 huge polyethylene pipes
	} },
}
machine{
	name = "cold-trap-i", category = "cold-trap-recipes", speed = IV_SPEED, energy = IV_POWER,
	subgroup = IV_SUB,
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { -1, 1 }),
		port("output", S, { 1, 1 }) },
	list = SALT_RECIPES,
	recipe = { "crafting-or-assembling-recipes", 1, {
		{ type = "item", name = "inconel-625-plate", amount = 4 },
		{ type = "item", name = "double-hastelloy-x-plate", amount = 1 },
		{ type = "item", name = "iv-machine-casing", amount = 1 },
		{ type = "item", name = "iv-robot-arm", amount = 2 },
		{ type = "item", name = "frost-proof-casing", amount = 1 },
	} },
}
local PA = "protactinium-dust"
step(SALT_RECIPES, "thorium-depleted-molten-salt-processing", "reactor-processing-unit-recipes", 600, IV_SPEED,
	{ { "fluorine", 600 }, { "thorium-depleted-molten-salt", 1000 } },
	{ { "lithium-fluoride", 100 }, { "fluorinated-uranium-hexafluoride", 150 }, { PA, 1, 0.05 }, { PA, 1, 0.05 },
		{ PA, 1, 0.05 }, { PA, 1, 0.025 }, { PA, 1, 0.025 }, { PA, 1, 0.025 } }, "fluorinated-uranium-hexafluoride")
step(SALT_RECIPES, "thorium-beryllium-depleted-molten-salt-processing", "reactor-processing-unit-recipes", 600, IV_SPEED,
	{ { "fluorine", 600 }, { "thorium-beryllium-depleted-molten-salt", 1000 } },
	{ { "lithium-fluoride", 100 }, { "beryllium-fluoride", 100 }, { "fluorinated-uranium-hexafluoride", 300 },
		{ PA, 1, 0.1 }, { PA, 1, 0.1 }, { PA, 1, 0.1 }, { PA, 1, 0.05 }, { PA, 1, 0.05 }, { PA, 1, 0.05 } },
	"fluorinated-uranium-hexafluoride")
step(SALT_RECIPES, "uranium-depleted-molten-salt-processing", "reactor-processing-unit-recipes", 7200, HV_SPEED,
	{ { "fluorine", 100 }, { "uranium-depleted-molten-salt", 100 } },
	{ { "phosphorous-uranium-hexafluoride", 100 }, { "impure-molten-salt-base", 100 } })
step(SALT_RECIPES, "fluorinated-uranium-hexafluoride-cold-trapping", "cold-trap-recipes", 600, HV_SPEED,
	{ { "sodium-fluoride", 200 }, { "fluorinated-uranium-hexafluoride", 300 } },
	{ { "fluorine", 200 }, { "uranium-hexafluoride", 200 }, { "uranium-233-dust", 1, 0.3 }, { "uranium-233-dust", 1, 0.2 },
		{ "uranium-233-dust", 1, 0.1 } }, "uranium-hexafluoride")
local P6 = {}
for i = 1, 6 do P6[i] = { "phosphorus", 1, 0.5 } end
step(SALT_RECIPES, "phosphorous-uranium-hexafluoride-cold-trapping", "cold-trap-recipes", 600, EV_SPEED,
	{ { "sodium-fluoride", 100 }, { "phosphorous-uranium-hexafluoride", 200 } },
	{ { "fluorine", 100 }, { "uranium-hexafluoride", 200 }, table.unpack(P6) }, "uranium-hexafluoride")
step(SALT_RECIPES, "sodium-fluoride-dust", "lv-chemical-reactor-recipes", 60, LV_SPEED,
	{ { "sodium-hydroxide", 3 }, { "hydrofluoric-acid", 100 } }, { { "sodium-fluoride-dust", 2 }, { "water", 100 } })
step(SALT_RECIPES, "sodium-fluoride-dust-ishf", "lv-chemical-reactor-recipes", 60, LV_SPEED,
	{ { "sodium-hydroxide", 3 }, { ISHF, 50 } }, { { "sodium-fluoride-dust", 2 }, { "water", 100 } })
step(SALT_RECIPES, "melt-sodium-fluoride-dust", "hv-fluid-extractor-recipes", 30, HV_SPEED, { { "sodium-fluoride-dust", 1 } },
	{ { "sodium-fluoride", 14.4 } })

--- the Sparge Tower and HS188-A
step(SPARGE_RECIPES, "rhenium-from-scheelite", "iv-alloy-blast-smelter-recipes", 75, IV_SPEED,
	{ { "purified-scheelite", 1 }, { "carbon", 4 }, { "sulfuric-acid", 125 } }, { { "molten-rhenium", 1.8 } })
step(SPARGE_RECIPES, "rhenium-from-molybdenite", "iv-alloy-blast-smelter-recipes", 37.5, IV_SPEED,
	{ { "purified-molybdenite", 1 }, { "carbon", 8 }, { "sulfuric-acid", 187.5 } }, { { "molten-rhenium", 3.6 } })
step(SPARGE_RECIPES, "rhenium-dust", "lv-macerator-recipes", 9.3, LV_SPEED, { { "rhenium-ingot", 1 } },
	{ { "rhenium-dust", 1 } })
step(SPARGE_RECIPES, "hastelloy-x-dust", "lv-macerator-recipes", 1.3, LV_SPEED, { { "hastelloy-x-ingot", 1 } },
	{ { "hastelloy-x-dust", 1 } })
step(SPARGE_RECIPES, "talonite-dust", "lv-mixer-recipes", 2.6, LV_SPEED,
	{ { "cobalt-dust", 4 }, { "chromium-dust", 3 }, { "phosphorus", 2 }, { "molybdenum-dust", 1 } }, { { "talonite-dust", 10 } })
step(SPARGE_RECIPES, "niobium-carbide-dust", "hv-mixer-recipes", 2.2, HV_SPEED, { { "niobium-dust", 1 }, { "carbon", 1 } },
	{ { "niobium-carbide-dust", 2 } })
step(SPARGE_RECIPES, "molten-hs188-a", "iv-alloy-blast-smelter-recipes", 300, IV_SPEED,
	{ { "cobalt-dust", 10 }, { "hafnium-dust", 10 }, { "talonite-dust", 8 }, { "rhenium-dust", 5 },
		{ "niobium-carbide-dust", 5 }, { "hastelloy-x-dust", 4 }, { "tungstensteel-dust", 4 },
		{ "zirconium-carbide-dust", 4 } }, { { "molten-hs188-a", 720 } })
step(SPARGE_RECIPES, "hs188-a-plate", "iv-bending-machine-recipes", 1.95, IV_SPEED, { { "hs188-a-ingot", 1 } },
	{ { "hs188-a-plate", 1 } })
step(SPARGE_RECIPES, "integral-encasement-iv", "hv-assembling-machine-recipes", 20, HV_SPEED,
	{ { "hv-machine-casing", 1 }, { "tantalum-carbide-plate", 8 }, { "large-tantalum-carbide-gear", 2 }, { "gold-cable", 8 },
		{ "processing-unit", 2 }, { "molten-tantalum-carbide", 115.2 } }, { { "integral-encasement-iv", 1 } })
step(SPARGE_RECIPES, "sparge-tower-exterior-casing", "iv-assembling-machine-recipes", 120, IV_SPEED,
	{ { "integral-encasement-iv", 1 }, { "hs188-a-plate", 2 }, { "hastelloy-n-ring", 4 }, { "double-tungstensteel-plate", 4 },
		{ "hastelloy-n-screw", 4 }, { "molten-stainless-steel", 115.2 } }, { { "sparge-tower-exterior-casing", 1 } })
local SPARGE_IN = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }) }
local SPARGE_OUT = {}
for _, p in pairs({ { S, { -1, 1 } }, { S, { 0, 1 } }, { S, { 1, 1 } }, { W, { -1, 0 } }, { E, { 1, 0 } } }) do
	SPARGE_OUT[#SPARGE_OUT + 1] = port("output", p[1], p[2])
end
SPARGE_OUT[#SPARGE_OUT + 1] = port("output", N, { 0, -1 })
SPARGE_OUT[#SPARGE_OUT + 1] = port("output", E, { 1, -1 })
local sparge_ports = { SPARGE_IN[1], SPARGE_IN[2] }
for _, p in pairs(SPARGE_OUT) do sparge_ports[#sparge_ports + 1] = p end
machine{
	name = SPARGE, category = "sparge-tower-recipes", speed = IV_SPEED, energy = EU16_LuV,
	subgroup = "subgroup-luv-age-multiblocks", ports = sparge_ports, list = SPARGE_RECIPES,
	recipe = { "luv-assembly-line-recipes", 60 * LUV_SPEED, {
		{ type = "item", name = "sparge-tower-exterior-casing", amount = 4 },
		{ type = "item", name = "integral-encasement-v", amount = 4 },
		{ type = "item", name = "iv-short-distillation-tower", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 8 },
		{ type = "item", name = "large-hs188-a-gear", amount = 8 },
		{ type = "item", name = "hs188-a-plate", amount = 32 },
		{ type = "item", name = "double-hastelloy-n-plate", amount = 16 },
		{ type = "item", name = "hastelloy-n-screw", amount = 64 },
		{ type = "item", name = "fine-yttrium-barium-cuprate-wire", amount = 128 },
		{ type = "item", name = "platinum-foil", amount = 64 },
		{ type = "fluid", name = "molten-incoloy-ds", amount = 230.4 },
		{ type = "fluid", name = "molten-tantalum-carbide", amount = 460.8 },
		{ type = "fluid", name = "molten-titanium", amount = 460.8 },
	} },
}
--- GT's random byproducts at their mean
step(SPARGE_RECIPES, "uranium-depleted-molten-salt-sparging", "sparge-tower-recipes", 25, IV_SPEED,
	{ { "helium", 100 }, { "uranium-depleted-molten-salt", 5 } },
	{ { "helium-sparged-u-salt", 5 }, { "helium", 49.75 }, { "xenon", 10.05 }, { "neon", 10.05 }, { "argon", 10.05 },
		{ "krypton", 10.05 }, { "radon", 10.05 } }, "helium-sparged-u-salt")
for _, s in pairs({ { "thorium-depleted-molten-salt", "fluorine-sparged-t-salt", 0.55 },
		{ "thorium-beryllium-depleted-molten-salt", "fluorine-sparged-tb-salt", 1.05 } }) do
	step(SPARGE_RECIPES, s[1] .. "-sparging", "sparge-tower-recipes", 25, IV_SPEED, { { "fluorine", 10 }, { s[1], 5 } },
		{ { s[2], 5 }, { "fluorine", 10 - 5 * s[3] }, { "lithium-fluoride", s[3] }, { "neptunium-hexafluoride", s[3] },
			{ "technetium-hexafluoride", s[3] }, { "selenium-hexafluoride", s[3] }, { "thorium-tetrafluoride", s[3] } }, s[2])
end
--- the sparged salts in the RPU (P 108-185)
step(SPARGE_RECIPES, "fluorine-sparged-t-salt-processing", "reactor-processing-unit-recipes", 300, IV_SPEED,
	{ { "fluorine", 600 }, { "fluorine-sparged-t-salt", 1000 } },
	{ { "lithium-fluoride", 200 }, { "fluorinated-uranium-hexafluoride", 300 }, { PA, 1, 0.1 }, { PA, 1, 0.1 },
		{ PA, 1, 0.1 }, { PA, 1, 0.1 }, { PA, 1, 0.1 }, { PA, 1, 0.1 } }, "fluorinated-uranium-hexafluoride")
step(SPARGE_RECIPES, "fluorine-sparged-tb-salt-processing", "reactor-processing-unit-recipes", 300, IV_SPEED,
	{ { "fluorine", 600 }, { "fluorine-sparged-tb-salt", 1000 } },
	{ { "lithium-fluoride", 200 }, { "beryllium-fluoride", 200 }, { "fluorinated-uranium-hexafluoride", 600 },
		{ PA, 1, 0.2 }, { PA, 1, 0.2 }, { PA, 1, 0.2 }, { PA, 1, 0.2 }, { PA, 1, 0.2 }, { PA, 1, 0.2 } },
	"fluorinated-uranium-hexafluoride")
step(SPARGE_RECIPES, "helium-sparged-u-salt-processing", "reactor-processing-unit-recipes", 3600, HV_SPEED,
	{ { "fluorine", 300 }, { "helium-sparged-u-salt", 100 } },
	{ { "phosphorous-uranium-hexafluoride", 200 }, { "impure-molten-salt-base", 200 } })

--- the reactor with its fuels: the mod's naquadah cable (GT's 12x naquadah cable of the controller) comes with ZPM
--- Materials, so the reactor and its fuels (#252) do (LuV science; GT: IV); the salt processing; the tower
for _, r in pairs(RECIPES) do fork_add_unlock(LFTR, r) end
do
	local t = data.raw.technology[LFTR]
	t.prerequisites[#t.prerequisites + 1] = "zpm-materials"
	t.unit.ingredients = F.sci(7)
end
F.tech{
	--- (the reactor's salts)
	name = SALTS, prerequisites = { LFTR }, packs = 7, count = 1000, time = 60, recipes = SALT_RECIPES,
}
F.tech{
	--- (LuV: GT++'s controller; the assembly line, the IV short distillation tower, YBCO, Incoloy-DS)
	name = SPARGE, prerequisites = { SALTS, "luv-machines" }, packs = 7, count = 1500, time = 60,
	recipes = SPARGE_RECIPES,
}
FORK_CASTING.materials["hs188-a"] = { "iv", SPARGE }
FORK_CASTING.materials["rhenium"] = { "iv", SPARGE }
FORK_CASTING.run()
FORK_RECIPES_TABLE_ONLY["uranium-233-dust-from-small-piles"] = nil



--------------------------------------------------------------------------------
--- 16) THE LFTR LOOP IN THE REACTOR FUEL PROCESSING PLANT (issue #386 (4); gtPlusPlus/xmod/gregtech/loaders/recipe/
--- RecipeLoaderNuclearFuelProcessing.java:207-256): the RPU's impure molten salt base distils into the stable molten salt
--- base (LiFBeF2; distillation tower, IV, 7.5 min, 1000 -> 250); with the cold trap's uranium hexafluoride and hydrogen it
--- becomes GT++'s LFTR Fuel Base (the blast furnace at 5400 K: a cell of each, 2000 hydrogen -> 3000 + 2 cells of
--- hydrofluoric acid; or the chemical plant: 1000 + 1000 + 2000 -> 3000 + 2000 industrial strength HF; IV, 150 s), and
--- the plant mixes 900 of it with 100 zirconium or thorium tetrafluoride into LFTR Fuel 2 or 3 (IV, 12 and 15 min),
--- GT++'s cheaper routes to the fuels of section 14. With Nuclear Salt Processing, where the salts are processed.
--------------------------------------------------------------------------------

F.fluid("stable-molten-salt-base", "nearly-white-fluid", { 0.75, 0.85, 0.75 })
F.fluid("lftr-fuel-base", "spackled-forest-green-fluid", { 0.35, 0.60, 0.35 })
RECIPES = {}
step(RECIPES, "impure-molten-salt-base-distillation", "iv-tall-distillation-recipes", 450, IV_SPEED,
	{ { "impure-molten-salt-base", 100 } }, { { "stable-molten-salt-base", 25 } })
step(RECIPES, "lftr-fuel-base", "iv-electric-blast-furnace-recipes", 150, IV_SPEED,
	{ { "uranium-hexafluoride", 100 }, { "stable-molten-salt-base", 100 }, { "hydrogen", 200 } },
	{ { "lftr-fuel-base", 300 }, { "hydrofluoric-acid", 200 } })
step(RECIPES, "lftr-fuel-base-chemical-plant", "chemical-plant-recipes", 150, IV_SPEED,
	{ { "uranium-hexafluoride", 100 }, { "stable-molten-salt-base", 100 }, { "hydrogen", 200 } },
	{ { "lftr-fuel-base", 300 }, { ISHF, 200 } })
step(RECIPES, "lftr-fuel-2-from-fuel-base", "reactor-fuel-processing-recipes", 720, IV_SPEED,
	{ { "zirconium-tetrafluoride", 10 }, { "lftr-fuel-base", 90 } }, { { "lftr-fuel-2", 100 } })
step(RECIPES, "lftr-fuel-3-from-fuel-base", "reactor-fuel-processing-recipes", 900, IV_SPEED,
	{ { "thorium-tetrafluoride", 10 }, { "lftr-fuel-base", 90 } }, { { "lftr-fuel-3", 100 } })
for _, r in pairs(RECIPES) do fork_add_unlock(SALTS, r) end



--------------------------------------------------------------------------------
--- 17) THE NUCLEAR SALT PROCESSING PLANT (issue #406; gtPlusPlus/xmod/gregtech/common/tileentities/machines/multi/
--- processing/MTENuclearSaltProcessingPlant.java): GT++'s multiblock of the Reactor Processing Unit and the Cold Trap. Its
--- map is theirs with the cells as fluids (gtPlusPlus/GTplusplus.java:159-162), which the recipes of section 15 already
--- are, so it runs the categories of both. GT: 2 parallels per voltage tier, 2.5 times as fast, the EU of each parallel;
--- its structure takes exactly 2 energy hatches, so at IV (4 amps) it runs 4 of GT's IV recipes at once: here 4 x 2.5 = 10
--- times the speed of the IV single blocks at 4 times their power (GT's HV recipes could run 10 parallels; the mod gives
--- a machine one speed). A 3x3 machine with the fluid ports of the RPU. Its item: GT++'s controller (RecipesMachinesCustom
--- .java:604-610: 4 osmiridium plates, the Reactor Processing Unit I, 2 Ruridit plates, a ZPM circuit, the Cold Trap I) and
--- the structure (:136-178): 58 IV machine casings, 32 Thermally Insulated Casings (GT++'s assembler recipe, :274-285: a
--- Maraging Steel 250 frame, 4 black steel plates, 8 Maraging Steel 250 screws, 576 L molten tantalum carbide; HV, 30 s),
--- 2 IV energy hatches and hulls for the 2 mufflers, the maintenance, input and output hatches. With Nuclear Salt
--- Processing.
--------------------------------------------------------------------------------

local NSPP = "nuclear-salt-processing-plant"
--- "5.12MW" -> 5.12e6
local function watts_of(power)
	return tonumber(power:match("^[%d.]+")) * ({ W = 1, kW = 1e3, MW = 1e6, GW = 1e9 })[power:match("%a+$")]
end
RECIPES = {}
create_item{ skip_recipe = true, name = "thermally-insulated-casing", subgroup = "subgroup-iv-age-multiblocks" }
step(RECIPES, "thermally-insulated-casing", "hv-assembling-machine-recipes", 30, HV_SPEED,
	{ { "maraging-steel-250-frame", 1 }, { "black-steel-plate", 4 }, { "maraging-steel-250-screw", 8 },
		{ "molten-tantalum-carbide", 57.6 } }, { { "thermally-insulated-casing", 1 } })
machine{
	name = NSPP, category = "reactor-processing-unit-recipes", speed = IV_SPEED * 2.5 * 4,
	energy = string.format("%.6gMW", 4 * watts_of(IV_POWER) / 1e6), subgroup = "subgroup-iv-age-multiblocks",
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { -1, 1 }),
		port("output", S, { 0, 1 }), port("output", S, { 1, 1 }) },
	list = RECIPES,
	recipe = { "crafting-or-assembling-recipes", 1, {
		{ type = "item", name = "osmiridium-plate", amount = 4 },
		{ type = "item", name = "reactor-processing-unit-i", amount = 1 },
		{ type = "item", name = "ruridit-plate", amount = 2 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "item", name = "cold-trap-i", amount = 1 },
		{ type = "item", name = "iv-machine-casing", amount = 58 },
		{ type = "item", name = "thermally-insulated-casing", amount = 32 },
		{ type = "item", name = "iv-energy-hatch", amount = 2 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },   -- (2 mufflers, maintenance, input and output hatch)
	} },
}
data.raw["assembling-machine"][NSPP].crafting_categories = { "reactor-processing-unit-recipes", "cold-trap-recipes" }
for _, r in pairs(RECIPES) do fork_add_unlock(SALTS, r) end




--------------------------------------------------------------------------------
--- 18) THE PRECISE ASSEMBLER AND THE HI-COMPUTATION STATIONS (issue #355, the godforge route: the quantum anomaly
--- through the HiC chain). GoodGenerator (GT5-Unofficial 638b3f37ca, goodgenerator/loader/RecipeLoader.java (R1),
--- RecipeLoader2.java (R2), items/GGMaterial.java) and NewHorizonsCoreMod (scripts/ScriptCoreMod.java), fluids a tenth
--- of GT's litres, GT's seconds x the tier speed of GT's EU/t.
--- The Precise Assembler (R2:1027-1041; goodgenerator/blocks/tileEntity/MTEPreciseAssembler.java): 9x5x5 with 42 to 81
--- Precise Electronic Unit Casings of one tier, 42 glass, 21 machine casings (they cap the voltage), 12 tungstensteel
--- frames; a recipe of casing tier N needs Mk N casings (:197-204). Here three machines, Mk-I to Mk-III (3x3): each one
--- the controller with 42 casings of its tier (Mk-II and Mk-III built from the one below, GT's casing swap), the glass,
--- 21 machine casings of its voltage (LuV, ZPM, UHV: GT's HiC Mk-V is UHV) and hatches as hulls; precise mode only (GT's
--- assembler mode, more parallels for plain assembler recipes, is left out).
--- The HiCs (R1:1066-1094, R2:1043-1170) with GT's alternatives: where GT takes an IC2 vent or rotors, both recipes
--- where the mod has the part (the Reactor Heat Vent and the Tin Alloy rotor it lacks). The casings (R2:1188-1230).
--- GT's 4x and 8x cables are 4 and 8 of the mod's cables (its convention, 126-fork-zpm.lua).
--- The alloys (GGMaterial, R2:103-130, 963-970, 1462-1498; bartworks' generated mixer, vacuum freezer and parts):
--- Signalium and Lumiium from their own mixer recipes, Hikarium, MAR-M200, MAR-Ce-M200 (from MAR-M200 ingots, cerium and
--- lithium chloride in the blast furnace), Tanmolyium Beta-C, Adamantium Alloy, Artherium-Sn, Dalisenite; the hot ingots
--- with GT's gas variants (BlastFurnaceGasStat.java:14-21: nitrogen x1, helium x0.9, argon 850 L x0.8, radon 700 L
--- x0.7, neon 550 L x0.6, krypton 400 L x0.5, xenon 250 L x0.4; oganesson left out), 143 casts the parts.
--- The leaves: tin alloy, red alloy, annealed copper and niobium-titanium dust (macerated ingots), molten redstone,
--- GoodGenerator's High Energy Mixture and Lumiinessence, lithium chloride (bath of purified lepidolite), the cerium
--- ingot (GT's blast furnace, 1068 K), sunnarium dust (the mod's molten sunnarium cast into an ingot and macerated:
--- GT's route without IC2's glowstone rods), orundum (forming press, tiberium plate and 8 silicon plates; the mod's
--- forming press has only the LV tier, GT's IV time), ardite (the sporadic ore of GT's Quantium mix, OreMixes.java:
--- 729-738: 8 with the quantium vein), manyullyn (cobalt and ardite), the energy crystal (autoclave of energium).
--- The chips: NewHorizonsCoreMod's engraved gold, diamond crystal, energy and manyullyn crystal chips, GT's Crystal SoC
--- and Raw Advanced Crystal Chip (LaserEngraverRecipes.java:110-116, 354-360; GT's blue lens is the sapphire lens).
--- Technologies by the casing tier: Precise Assembler (the Mk-I casing; after the ZPM assembly line, whose fiber-reinforced
--- board and palladium melt the HiC Mk-I and the controller take, as #252 asks), Precise Electronic Unit Mk-II (ZPM),
--- Mk-III (UHV).
--------------------------------------------------------------------------------

local PA1, PA2, PA3 = "precise-assembler", "precise-electronic-unit-mk2", "precise-electronic-unit-mk3"
local R1, R2, R3 = {}, {}, {}
local GAS = { { nil, "nitrogen", 100, 1 }, { "helium", "helium", 100, 0.9 }, { "argon", "argon", 85, 0.8 },
	{ "radon", "radon", 70, 0.7 }, { "neon", "neon", 55, 0.6 }, { "krypton", "krypton", 40, 0.5 },
	{ "xenon", "xenon", 25, 0.4 } }
--- the hot ingot from the dust in the blast furnace with GT's gas variants (GG's reAddBlastRecipe, no gas-free one)
local function blast(list, m, cat, seconds, speed)
	for _, g in pairs(GAS) do
		local name = "hot-" .. m .. "-ingot" .. (g[1] and ("-" .. g[1]) or "")
		step(list, name, cat, seconds * g[4], speed, { { m .. "-dust", 1 }, { g[2], g[3] } }, { { "hot-" .. m .. "-ingot", 1 } },
			"hot-" .. m .. "-ingot")
	end
end
local SUB_DUST, SUB_PART = "subgroup-macerator-dust", data.raw.item["hastelloy-x-plate"].subgroup
local function items(sub, names)
	for _, n in pairs(names) do
		if not data.raw.item[n] then create_item{ skip_recipe = true, name = n, subgroup = sub } end
	end
end

--- the leaves
items(SUB_DUST, { "tin-alloy-dust", "red-alloy-dust", "annealed-copper-dust", "niobium-titanium-dust",
	"high-energy-mixture", "lumiinessence-dust", "lithium-chloride-dust", "sunnarium-dust", "orundum-dust",
	"ardite-dust", "manyullyn-dust" })
items(SUB_PART, { "cerium-ingot", "sunnarium-ingot", "tiberium-plate", "orundum-plate", "hot-manyullyn-ingot",
	"manyullyn-ingot", "manyullyn-plate" })
F.fluid("molten-redstone", "molten-redstone", { 0.78, 0.00, 0.00 })
F.fluid("molten-lithium-chloride", "molten-lithium-chloride", { 0.72, 0.89, 0.81 })
step(R1, "tin-alloy-dust", "lv-mixer-recipes", 5, LV_SPEED, { { "iron-dust", 1 }, { "tin-dust", 1 } }, { { "tin-alloy-dust", 2 } })
step(R1, "red-alloy-dust", "lv-macerator-recipes", 20.15, LV_SPEED, { { "red-alloy-ingot", 1 } }, { { "red-alloy-dust", 1 } })
step(R1, "annealed-copper-dust", "lv-macerator-recipes", 3.15, LV_SPEED, { { "annealed-copper-ingot", 1 } },
	{ { "annealed-copper-dust", 1 } })
step(R3, "niobium-titanium-dust", "lv-macerator-recipes", 3.55, LV_SPEED, { { "niobium-titanium-ingot", 1 } },
	{ { "niobium-titanium-dust", 1 } })
step(R1, "molten-redstone", "lv-fluid-extractor-recipes", 1.2, LV_SPEED, { { "redstone-dust", 1 } }, { { "molten-redstone", 14.4 } })
step(R1, "high-energy-mixture", "mv-mixer-recipes", 12, MV_SPEED,
	{ { "glowstone-dust", 4 }, { "redstone-dust", 2 }, { "aluminium-dust", 1 } }, { { "high-energy-mixture", 4 } })
step(R1, "lumiinessence-dust", "hv-fluid-solidifier-recipes", 30, HV_SPEED,
	{ { "high-energy-mixture", 2 }, { "phosphoric-acid", 400 } }, { { "lumiinessence-dust", 1 } })
step(R1, "lithium-chloride-dust", "mv-chemical-bath-recipes", 7, MV_SPEED,
	{ { "purified-lepidolite", 1 }, { "hydrochloric-acid", 100 } },
	{ { "rock-salt", 1, 0.8 }, { "lithium-chloride-dust", 3, 0.8 }, { "cryolite", 4, 0.8 } }, "lithium-chloride-dust")
step(R1, "molten-lithium-chloride", "lv-fluid-extractor-recipes", 15, LV_SPEED, { { "lithium-chloride-dust", 1 } },
	{ { "molten-lithium-chloride", 14.4 } })
step(R1, "cerium-ingot", "mv-electric-blast-furnace-recipes", 160.2, MV_SPEED, { { "cerium-dust", 1 } }, { { "cerium-ingot", 1 } })
step(R1, "sunnarium-ingot", "lv-fluid-solidifier-recipes", 1.6, LV_SPEED, { { "molten-sunnarium", 14.4 } },
	{ { "sunnarium-ingot", 1 } })
step(R1, "sunnarium-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "sunnarium-ingot", 1 } }, { { "sunnarium-dust", 1 } })
step(R2, "tiberium-plate", "lv-bending-machine-recipes", 9.8, LV_SPEED, { { "tiberium-gem", 1 } }, { { "tiberium-plate", 1 } })
step(R2, "orundum-plate", "lv-forming-press-recipes", 20, IV_SPEED, { { "tiberium-plate", 1 }, { "silicon-plate", 8 } },
	{ { "orundum-plate", 1 } })
step(R2, "orundum-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "orundum-plate", 1 } }, { { "orundum-dust", 1 } })
step(R3, "manyullyn-dust", "lv-mixer-recipes", 20, LV_SPEED, { { "cobalt-dust", 1 }, { "ardite-dust", 1 } },
	{ { "manyullyn-dust", 2 } })
step(R3, "hot-manyullyn-ingot", "hv-electric-blast-furnace-recipes", 75, HV_SPEED, { { "manyullyn-dust", 1 }, { "hydrogen", 100 } },
	{ { "hot-manyullyn-ingot", 1 } })
step(R3, "hot-manyullyn-ingot-without-gas", "hv-electric-blast-furnace-recipes", 120, HV_SPEED, { { "manyullyn-dust", 1 } },
	{ { "hot-manyullyn-ingot", 1 } })
step(R3, "manyullyn-ingot", "mv-vacuum-freezer-recipes", 11.7, MV_SPEED, { { "hot-manyullyn-ingot", 1 } },
	{ { "manyullyn-ingot", 1 } })
step(R3, "manyullyn-plate", "lv-bending-machine-recipes", 3.9, LV_SPEED, { { "manyullyn-ingot", 1 } }, { { "manyullyn-plate", 1 } })

--- the alloys: dust, hot ingot (gas variants), ingot (vacuum freezer); 143 casts the parts from the melt
local ALLOYS = {
	--  material            list  EBF category, s, speed                    freezer category, s, speed     colour
	{ "signalium",          R1, "luv-electric-blast-furnace-recipes", 80, LUV_SPEED, "mv-vacuum-freezer-recipes", 23.4, MV_SPEED, { 212, 64, 0 } },
	{ "lumiium",            R1, "luv-electric-blast-furnace-recipes", 80, LUV_SPEED, "mv-vacuum-freezer-recipes", 10.2, MV_SPEED, { 232, 242, 36 } },
	{ "hikarium",           R1, "luv-electric-blast-furnace-recipes", 60, LUV_SPEED, "mv-vacuum-freezer-recipes", 12.3, MV_SPEED, { 255, 214, 251 } },
	{ "mar-m200-steel",     R1, "iv-electric-blast-furnace-recipes", 10, IV_SPEED, "ev-vacuum-freezer-recipes", 12.3, EV_SPEED, { 81, 81, 81 } },
	{ "tanmolyium-beta-c",  R1, "iv-electric-blast-furnace-recipes", 20, IV_SPEED, "mv-vacuum-freezer-recipes", 9.3, MV_SPEED, { 199, 47, 204 } },
	{ "adamantium-alloy",   R2, "ev-electric-blast-furnace-recipes", 125, EV_SPEED, "zpm-vacuum-freezer-recipes", 23.4, ZPM_SPEED, { 160, 160, 160 } },
	{ "artherium-sn",       R2, "zpm-electric-blast-furnace-recipes", 25, ZPM_SPEED, "mv-vacuum-freezer-recipes", 21.6, MV_SPEED, { 96, 54, 247 } },
	{ "dalisenite",         R3, "uv-electric-blast-furnace-recipes", 40, UV_SPEED, "mv-vacuum-freezer-recipes", 16, MV_SPEED, { 176, 184, 18 } },
}
--- the melts first (step() types an ingredient by data.raw.fluid when it is called); 143 casts with them at the end
--- (the near-black MAR-M200 steels lifted as gen_gt_icons.py lifts their melt icons)
local MELT_RGB = { ["mar-m200-steel"] = { 159, 159, 159 } }
for _, a in pairs(ALLOYS) do
	local c = MELT_RGB[a[1]] or a[9]
	F.fluid("molten-" .. a[1], "molten-" .. a[1], { c[1] / 255, c[2] / 255, c[3] / 255 })
end
F.fluid("molten-mar-ce-m200-steel", "molten-mar-ce-m200-steel", { 146 / 255, 125 / 255, 125 / 255 })
F.fluid("molten-energetic-alloy", "molten-energetic-alloy", { 1, 152 / 255, 0 })
for _, a in pairs(ALLOYS) do
	local m = a[1]
	items(SUB_DUST, { m .. "-dust" })
	items(SUB_PART, { "hot-" .. m .. "-ingot", m .. "-ingot" })
	blast(a[2], m, a[3], a[4], a[5])
	step(a[2], m .. "-ingot", a[6], a[7], a[8], { { "hot-" .. m .. "-ingot", 1 } }, { { m .. "-ingot", 1 } })
end
--- the dusts (Signalium and Lumiium: GG's own mixer recipes; the others bartworks' generated ones)
step(R1, "signalium-dust", "mv-mixer-recipes", 12, MV_SPEED,
	{ { "annealed-copper-dust", 4 }, { "ardite-dust", 2 }, { "red-alloy-dust", 2 }, { "molten-redstone", 28.8 } },
	{ { "signalium-dust", 1 } })
step(R1, "lumiium-dust", "mv-mixer-recipes", 12, MV_SPEED,
	{ { "tin-alloy-dust", 4 }, { "sterling-silver-dust", 2 }, { "lumiinessence-dust", 2 }, { "molten-glowstone", 28.8 } },
	{ { "lumiium-dust", 1 } })
step(R1, "hikarium-dust", "lv-mixer-recipes", 1.35, LV_SPEED,
	{ { "lumiium-dust", 18 }, { "silver-dust", 8 }, { "sunnarium-dust", 4 } }, { { "hikarium-dust", 30 } })
step(R1, "mar-m200-steel-dust", "ev-mixer-recipes", 0.55, EV_SPEED,
	{ { "niobium-dust", 2 }, { "chromium-dust", 9 }, { "aluminium-dust", 5 }, { "titanium-dust", 2 }, { "cobalt-dust", 10 },
		{ "tungsten-dust", 13 }, { "nickel-dust", 18 } }, { { "mar-m200-steel-dust", 59 } })
step(R1, "tanmolyium-beta-c-dust", "lv-mixer-recipes", 0.6, LV_SPEED,
	{ { "titanium-dust", 5 }, { "molybdenum-dust", 5 }, { "vanadium-dust", 2 }, { "chromium-dust", 3 }, { "aluminium-dust", 1 } },
	{ { "tanmolyium-beta-c-dust", 16 } })
step(R2, "adamantium-alloy-dust", "zpm-mixer-recipes", 2.6, ZPM_SPEED,
	{ { "adamantium-dust", 5 }, { "naquadah-dust", 2 }, { "lanthanum-dust", 3 } }, { { "adamantium-alloy-dust", 10 } })
step(R2, "artherium-sn-dust", "lv-mixer-recipes", 1.2, LV_SPEED,
	{ { "adamantium-alloy-dust", 12 }, { "orundum-dust", 9 }, { "tin-dust", 8 }, { "arsenic", 7 }, { "caesium-dust", 4 },
		{ "osmiridium-dust", 3 } }, { { "artherium-sn-dust", 43 } })
step(R3, "dalisenite-dust", "lv-mixer-recipes", 0.85, LV_SPEED,
	{ { "tanmolyium-beta-c-dust", 14 }, { "tungsten-dust", 10 }, { "niobium-titanium-dust", 9 },
		{ "rhodium-plated-palladium-dust", 8 }, { "quantium-dust", 7 }, { "erbium-dust", 3 } }, { { "dalisenite-dust", 51 } })
step(R2, "adamantium-alloy-dust-maceration", "lv-macerator-recipes", 7.8, LV_SPEED, { { "adamantium-alloy-ingot", 1 } },
	{ { "adamantium-alloy-dust", 1 } })
step(R1, "lumiium-dust-maceration", "lv-macerator-recipes", 3.4, LV_SPEED, { { "lumiium-ingot", 1 } }, { { "lumiium-dust", 1 } })
step(R1, "tanmolyium-beta-c-dust-maceration", "lv-macerator-recipes", 3.1, LV_SPEED, { { "tanmolyium-beta-c-ingot", 1 } },
	{ { "tanmolyium-beta-c-dust", 1 } })
--- MAR-Ce-M200 (no dust: GG's blast furnace recipe from MAR-M200 ingots)
items(SUB_PART, { "hot-mar-ce-m200-steel-ingot", "mar-ce-m200-steel-ingot" })
step(R1, "hot-mar-ce-m200-steel-ingot", "zpm-electric-blast-furnace-recipes", 285, ZPM_SPEED,
	{ { "mar-m200-steel-ingot", 18 }, { "cerium-ingot", 1 }, { "molten-lithium-chloride", 14.4 } },
	{ { "hot-mar-ce-m200-steel-ingot", 19 } })
step(R1, "mar-ce-m200-steel-ingot", "iv-vacuum-freezer-recipes", 58.8, IV_SPEED, { { "hot-mar-ce-m200-steel-ingot", 1 } },
	{ { "mar-ce-m200-steel-ingot", 1 } })
--- the parts (cast by 143 where it has the form; double plates in the bender, bartworks: 2 ingots, 2 m ticks)
items(SUB_PART, { "signalium-bolt", "lumiium-bolt", "large-hikarium-gear", "mar-m200-steel-plate",
	"double-mar-m200-steel-plate", "double-mar-ce-m200-steel-plate", "mar-ce-m200-steel-bolt", "tanmolyium-beta-c-bolt",
	"tanmolyium-beta-c-gear", "artherium-sn-gear", "dalisenite-gear", "lumiium-wire", "lumiium-cable", "titanium-wire",
	"titanium-cable", "fluxed-electrum-cable" })
step(R1, "double-mar-m200-steel-plate", "ev-bending-machine-recipes", 8.2, EV_SPEED, { { "mar-m200-steel-ingot", 2 } },
	{ { "double-mar-m200-steel-plate", 1 } })
step(R1, "double-mar-ce-m200-steel-plate", "iv-bending-machine-recipes", 39.2, IV_SPEED, { { "mar-ce-m200-steel-ingot", 2 } },
	{ { "double-mar-ce-m200-steel-plate", 1 } })
--- wires and cables (GT's wiremill: 1 ingot -> 2 wires; the mod's cables: rubber for titanium, GT's rubber branch;
--- PPS sheets and silicone rubber for Lumiium and fluxed electrum, as its bedrockium cable)
step(R1, "lumiium-wire", "lv-wiremill-recipes", 5, LV_SPEED, { { "lumiium-ingot", 1 } }, { { "lumiium-wire", 2 } })
step(R1, "lumiium-cable", "lv-assembling-machine-recipes", 5, LV_SPEED,
	{ { "lumiium-wire", 4 }, { "thin-polyphenylene-sulfide-sheet", 1 }, { "silicone-rubber", 7.2 } }, { { "lumiium-cable", 4 } })
step(R1, "titanium-wire", "lv-wiremill-recipes", 5, LV_SPEED, { { "titanium-ingot", 1 } }, { { "titanium-wire", 2 } })
step(R1, "titanium-cable", "lv-assembling-machine-recipes", 5, LV_SPEED, { { "titanium-wire", 1 }, { "liquid-rubber", 14.4 } },
	{ { "titanium-cable", 1 } })
step(R2, "fluxed-electrum-cable", "lv-assembling-machine-recipes", 5, LV_SPEED,
	{ { "fluxed-electrum-wire", 4 }, { "thin-polyphenylene-sulfide-sheet", 1 }, { "silicone-rubber", 7.2 } },
	{ { "fluxed-electrum-cable", 4 } })

--- the chips
items(SUB_PART, { "engraved-gold-chip", "engraved-diamond-crystal-chip", "energy-crystal", "engraved-energy-chip",
	"manyullyn-crystal", "engraved-manyullyn-crystal-chip", "crystal-soc", "raw-advanced-crystal-chip" })
local function engrave(list, name, cat, seconds, speed, ings, lens, n)
	ings[#ings + 1] = { lens, 1 }
	step(list, name, cat, seconds, speed, ings, { { name, n or 1 }, { lens, 1 } }, name)
end
engrave(R1, "engraved-gold-chip", "mv-laser-engraver-recipes", 5, MV_SPEED, { { "gold-plate", 1 } }, "diamond-lens")
engrave(R1, "engraved-diamond-crystal-chip", "ev-laser-engraver-recipes", 20, EV_SPEED, { { "diamond-plate", 4 } }, "diamond-lens")
step(R3, "energy-crystal", "hv-autoclave-recipes", 30, HV_SPEED, { { "energium-dust", 9 }, { "molten-energetic-alloy", 28.8 } },
	{ { "energy-crystal", 1 } })
engrave(R3, "engraved-energy-chip", "iv-laser-engraver-recipes", 30, IV_SPEED, { { "energy-crystal", 1 } }, "ruby-lens")
--- issue #485: the Item Circuit Tier III of the 1024k ME component (120) takes the engraved energy chip, before the HiC
if data.raw.technology["me-storage-1024k"] then
	for _, r in pairs({ "energy-crystal", "engraved-energy-chip" }) do fork_add_unlock("me-storage-1024k", r) end
end
engrave(R3, "manyullyn-crystal", "ev-laser-engraver-recipes", 60, EV_SPEED, { { "manyullyn-plate", 4 } }, "tanzanite-lens")
engrave(R3, "engraved-manyullyn-crystal-chip", "iv-laser-engraver-recipes", 45, IV_SPEED, { { "manyullyn-crystal", 1 } },
	"tanzanite-lens")
engrave(R2, "crystal-soc", "luv-laser-engraver-recipes", 30, LUV_SPEED, { { "crystal-cpu", 1 } }, "sapphire-lens")
engrave(R2, "raw-advanced-crystal-chip", "zpm-laser-engraver-recipes", 60, ZPM_SPEED, { { "crystal-soc", 1 } }, "emerald-lens")

--- the HiCs, the casings, the controller
local HIC = {}
for i = 1, 5 do HIC[i] = "hi-computation-station-mk" .. i end
items(SUB_PART, HIC)
items("subgroup-luv-age-multiblocks", { "precise-assembler-controller", "precise-electronic-unit-casing-mk1",
	"precise-electronic-unit-casing-mk2", "precise-electronic-unit-casing-mk3" })
for _, c in pairs({ "precise-assembler-mk1-recipes", "precise-assembler-mk2-recipes", "precise-assembler-mk3-recipes" }) do
	F.category(c)
end
for _, v in pairs({ { "heat-vent", 1, "" } }) do
	step(R1, HIC[1] .. v[3], "iv-assembling-machine-recipes", 60, IV_SPEED,
		{ { "multilayered-fiber-reinforced-printed-circuit-board", 1 }, { "engraved-gold-chip", 16 },
			{ "advanced-system-on-chip", 8 }, { "nor-memory-chip", 32 }, { "signalium-bolt", 32 }, { "aluminium-wire", 8 },
			{ v[1], v[2] }, { "soldering-alloy", 28.8 } }, { { HIC[1], 1 } }, HIC[1])
end
--- (GT: the Reactor Heat Vent or 2 aluminium rotors; the mod has no Reactor Heat Vent)
step(R1, HIC[2], "precise-assembler-mk1-recipes", 5, LUV_SPEED,
	{ { HIC[1], 2 }, { "engraved-diamond-crystal-chip", 8 }, { "nand-memory-chip", 16 }, { "aluminium-rotor", 2 },
		{ "polyethylene", 28.8 }, { "molten-signalium", 14.4 }, { "molten-lumiium", 7.2 }, { "molten-enderium", 7.2 } },
	{ { HIC[2], 1 } })
for _, v in pairs({ { 3, "precise-assembler-mk2-recipes", ZPM_SPEED, R2, "advanced-heat-vent", "stainless-steel-rotor",
		{ { HIC[2], 2 }, { "engraved-lapotron-chip", 8 }, { "raw-advanced-crystal-chip", 1 } },
		{ { "molten-adamantium-alloy", 57.6 }, { "molten-signalium", 28.8 }, { "molten-lumiium", 14.4 }, { "molten-tungsten-carbide", 7.2 } } },
	{ 4, "precise-assembler-mk3-recipes", UV_SPEED, R3, "overclocked-heat-vent", "energetic-alloy-rotor",
		{ { HIC[3], 2 }, { "engraved-energy-chip", 8 }, { "qubit-cpu-chip", 16 } },
		{ { "molten-mar-m200-steel", 115.2 }, { "molten-signalium", 57.6 }, { "molten-lumiium", 28.8 }, { "molten-artherium-sn", 14.4 } } },
	{ 5, "precise-assembler-mk3-recipes", UHV_SPEED, R3, "component-heat-vent", "tungsten-carbide-rotor",
		{ { HIC[4], 2 }, { "engraved-manyullyn-crystal-chip", 8 }, { "bio-processing-unit", 1 } },
		{ { "molten-tanmolyium-beta-c", 172.8 }, { "molten-signalium", 115.2 }, { "molten-lumiium", 57.6 }, { "molten-dalisenite", 28.8 } } } }) do
	for _, alt in pairs({ { v[5], 1, "" }, { v[6], 2, "-from-rotors" } }) do
		local ings = {}
		for _, i in pairs(v[7]) do ings[#ings + 1] = i end
		ings[#ings + 1] = { alt[1], alt[2] }
		for _, f in pairs(v[8]) do ings[#ings + 1] = f end
		step(v[4], HIC[v[1]] .. alt[3], v[2], 5, v[3], ings, { { HIC[v[1]], 1 } }, HIC[v[1]])
	end
end
step(R1, "precise-electronic-unit-casing-mk1", "luv-assembling-machine-recipes", 40, LUV_SPEED,
	{ { "zpm-machine-casing", 3 }, { "iv-robot-arm", 2 }, { "lumiium-cable", 8 }, { "double-mar-ce-m200-steel-plate", 2 },
		{ HIC[1], 1 }, { "signalium-bolt", 32 }, { "tanmolyium-beta-c-gear", 8 }, { "molten-black-steel", 57.6 } },
	{ { "precise-electronic-unit-casing-mk1", 2 } })
step(R2, "precise-electronic-unit-casing-mk2", "zpm-assembling-machine-recipes", 240, ZPM_SPEED,
	{ { "uv-machine-casing", 3 }, { "luv-robot-arm", 2 }, { "fluxed-electrum-cable", 16 }, { HIC[2], 1 },
		{ "precise-electronic-unit-casing-mk1", 1 }, { "mar-ce-m200-steel-bolt", 32 }, { "artherium-sn-gear", 8 },
		{ "molten-adamantium-alloy", 115.2 } }, { { "precise-electronic-unit-casing-mk2", 4 } })
step(R3, "precise-electronic-unit-casing-mk3", "uv-assembling-machine-recipes", 240, UV_SPEED,
	{ { "uhv-machine-casing", 3 }, { "zpm-field-generator", 2 }, { "bedrockium-cable", 16 }, { HIC[3], 1 },
		{ "precise-electronic-unit-casing-mk2", 1 }, { "tanmolyium-beta-c-bolt", 32 }, { "dalisenite-gear", 8 },
		{ "molten-artherium-sn", 115.2 } }, { { "precise-electronic-unit-casing-mk3", 4 } })
step(R1, "precise-assembler-controller", "iv-assembling-machine-recipes", 90, IV_SPEED,
	{ { "iv-robot-arm", 4 }, { HIC[1], 4 }, { "data-orb", 3 }, { "titanium-cable", 32 }, { "large-hikarium-gear", 4 },
		{ "double-mar-m200-steel-plate", 2 }, { "iridium-reinforced-plate", 2 }, { "lumiium-bolt", 48 },
		{ "molten-palladium", 115.2 } }, { { "precise-assembler-controller", 1 } })
--- the machines (3x3; precise mode, GT's voltage of the machine casings)
local PA_PORTS = { port("input", N, { -1, -1 }), port("input", N, { 0, -1 }), port("input", N, { 1, -1 }),
	port("input", W, { -1, 0 }) }
for i, def in pairs({
	{ LUV_SPEED, EU16_LuV, R1, { { "precise-assembler-controller", 1 }, { "precise-electronic-unit-casing-mk1", 42 },
		{ "titanium-reinforced-borosilicate-glass-block", 42 }, { "luv-machine-casing", 21 }, { "tungstensteel-frame", 12 },
		{ "luv-energy-hatch", 1 }, { "lv-machine-hull", 4 } } },
	{ ZPM_SPEED, EU16_ZPM, R2, { { "precise-assembler-mk1", 1 }, { "precise-electronic-unit-casing-mk2", 42 },
		{ "zpm-machine-casing", 21 }, { "zpm-energy-hatch", 1 } } },
	{ UHV_SPEED, EU16_UHV, R3, { { "precise-assembler-mk2", 1 }, { "precise-electronic-unit-casing-mk3", 42 },
		{ "uhv-machine-casing", 21 }, { "uhv-energy-hatch", 1 } } } }) do
	local ings = {}
	for _, x in pairs(def[4]) do ings[#ings + 1] = { type = "item", name = x[1], amount = x[2] } end
	machine{
		name = "precise-assembler-mk" .. i, category = "precise-assembler-mk" .. i .. "-recipes", speed = def[1],
		energy = def[2], subgroup = "subgroup-luv-age-multiblocks", ports = PA_PORTS, list = def[3],
		recipe = { "crafting-or-assembling-recipes", 1, ings },
	}
	local cats = {}
	for j = 1, i do cats[#cats + 1] = "precise-assembler-mk" .. j .. "-recipes" end
	data.raw["assembling-machine"]["precise-assembler-mk" .. i].crafting_categories = cats
	if i > 1 then data.raw["assembling-machine"]["precise-assembler-mk" .. (i - 1)].next_upgrade = nil end
end

--- the quantium vein's sporadic ardite (GT's Quantium mix; the vein gives its quantium as dust, ardite the same), in
--- the Manual Mine and its two electric twins of 163
for _, n in pairs({ "mining-quantium-vein", "drilling-quantium-vein", "miner-quantium-vein" }) do
	local r = data.raw.recipe[n]
	if r then
		r.results[#r.results + 1] = { type = "item", name = "ardite-dust", amount = 8 }
		r.main_product = r.main_product or "quantium-dust"
	end
end

F.tech{
	name = PA1, prerequisites = { "reach-venus", "cerium-processing", "liquid-fluoride-thorium-reactor", "zpm-assembly-line",
		"zpm-multiblocks" }, packs = 8, count = 1500, time = 60, recipes = R1,
}
F.tech{
	name = PA2, prerequisites = { PA1, "fluxed-electrum", "reach-ross128ba", "uv-components" }, packs = 8, count = 2000,
	time = 60, recipes = R2,
}
F.tech{
	name = PA3, prerequisites = { PA2, "reach-the-everglades", "uhv-energy-hatches" }, packs = 10, count = 2500, time = 60,
	recipes = R3,
}
for _, a in pairs(ALLOYS) do
	FORK_CASTING.materials[a[1]] = { ({ [R1] = "luv", [R2] = "zpm", [R3] = "uv" })[a[2]], ({ [R1] = PA1, [R2] = PA2, [R3] = PA3 })[a[2]] }
end
FORK_CASTING.materials["mar-ce-m200-steel"] = { "luv", PA1 }
FORK_CASTING.materials["energetic-alloy"] = FORK_CASTING.materials["energetic-alloy"] or { "hv", PA3 }
FORK_CASTING.run()



--------------------------------------------------------------------------------
--- 19) THE QUANTUM ANOMALY AND CHROMATIC GLASS (issue #355, the godforge route)
--- GT's deterministic quantum anomaly (gregtech/loaders/postload/recipes/PlasmaForgeRecipes.java:128-140, "bypass for
--- UEV+"): the plasma forge at 10 800 K takes an Unknown Particle with a Chromatic Lens and a Hi-Computation Station
--- Mk-V (both stay: they come back) and 92 L of the excited resplendent catalyst with an ingot of molten duranium,
--- 60 s at UEV, with 46 L of residue (GT's DTR, section 20). The Unknown
--- Particle (GT++'s particle item, an item here too) is the 1 % output of GT's grade 8
--- water unit (gregtech/loaders/postload/chains/PurifiedWaterRecipes.java:342-353). The Chromatic Lens
--- (NewHorizonsCoreMod LatheRecipes.java:19-20): a Chromatic Glass plate in the UHV lathe, 60 s. GT++'s Chromatic
--- Glass comes from the plasma forge (NewHorizonsCoreMod DTPFRecipes.java:344-401 with its DTPFCalculator: 256
--- parallels of a 1 966 080 EU/t, 300 s recipe; tier 1 crude, tier 3 resplendent, the mod has no prosaic and exotic
--- catalyst), 143 casts it into plates. GT++'s other anomaly engravings (chromatic glass dust, astral titanium,
--- advanced nitinol) are left out: no consumer, no such materials. Everything here is unlocked with the godforge, the
--- anomaly's first consumer (its Graviton Flow Modulators, 140).
--------------------------------------------------------------------------------
do
	local GF, DTPF_CAT = "godforge", "dimensionally-transcendent-plasma-forge-recipes"
	local CRUDE = "excited-dimensionally-transcendent-crude-catalyst"
	local RESPLENDENT = "excited-dimensionally-transcendent-resplendent-catalyst"
	local AQ = {}
	F.fluid("molten-chromatic-glass", "molten-chromatic-glass", { 0.94, 0, 0 })   -- (GT++'s molten texture)
	items(SUB_PART, { "unknown-particle", "chromatic-glass-plate", "chromatic-lens" })
	--- (GT: tier 1 156 040 L crude catalyst and 36 864 L molten glass, 150 s at 50 331 648 EU/t, UMV; tier 3 26 350 L
	--- resplendent catalyst and 147 456 L glass, 37.5 s at 201 326 592 EU/t, UXV; their residue in section 20)
	step(AQ, "molten-chromatic-glass", DTPF_CAT, 150, UMV_SPEED, { { CRUDE, 15604 }, { "molten-glass", 3686.4 } },
		{ { "molten-chromatic-glass", 3686.4 } })
	step(AQ, "molten-chromatic-glass-resplendent", DTPF_CAT, 37.5, UXV_SPEED,
		{ { RESPLENDENT, 2635 }, { "molten-glass", 14745.6 } }, { { "molten-chromatic-glass", 14745.6 } },
		"molten-chromatic-glass")
	step(AQ, "chromatic-lens", "uhv-lathe-recipes", 60, UHV_SPEED, { { "chromatic-glass-plate", 1 } },
		{ { "chromatic-lens", 1 } })
	step(AQ, "quantum-anomaly", DTPF_CAT, 60, UEV_SPEED,
		{ { "unknown-particle", 1 }, { "chromatic-lens", 1 }, { HIC[5], 1 }, { RESPLENDENT, 9.2 }, { "molten-duranium", 14.4 } },
		{ { "quantum-anomaly", 1 }, { "chromatic-lens", 1 }, { HIC[5], 1 } })
	local g8 = data.raw.recipe["grade-8-water"]
	g8.results[#g8.results + 1] = { type = "item", name = "unknown-particle", amount = 1, independent_probability = 0.01 }
	for _, r in pairs(AQ) do fork_add_unlock(GF, r) end
	FORK_CASTING.materials["chromatic-glass"] = { "uev", GF }
	FORK_CASTING.run()
end




--------------------------------------------------------------------------------
--- 20) THE PLASMA FORGE'S RESIDUE AND DIMENSIONALLY SHIFTED SUPERFLUID (issue #355, the shared foundation of the ZPIC
--- and YPIC rungs). GT5-Unofficial 638b3f37ca and NewHorizonsCoreMod; fluids a tenth of GT's litres, plasmas and the
--- water grades GT's litres, GT's seconds x the tier speed of GT's EU/t.
--- * Dimensionally Transcendent Residue (GT's DTR): the plasma forge's byproduct. Where GT has a plasma forge recipe of
---   the same product and catalyst tier, the mod's recipe gives GT's residue per litre of product (NewHorizonsCoreMod
---   DTPFRecipes.java with its DTPFCalculator: residue = catalyst x 2^tier / 8; the crude and resplendent neutronium and
---   cosmic neutronium, the resplendent and stellar infinity, the stellar transcendent metal, the MAX recipes of 141,
---   the quantum anomaly and chromatic glass of section 19). The mod's other forge recipes have no GT counterpart and
---   no residue. Nothing in the mod takes it yet (GT: mellion, creon, the godforge's fuel); every fluid has its voiding
---   recipe.
--- * Stable Baryonic Matter: grade 8 water's byproduct (gregtech/loaders/postload/chains/PurifiedWaterRecipes.java:
---   339-354): 500 L per 1000 L of grade 7 water, net of GT's realignment of the quark catalysts.
--- * The oganessons (bartworks/system/material/processingLoaders/AdditionalRecipes.java:392-408, goodgenerator/loader/
---   RecipeLoader2.java:1500-1508): californium (MK3: plutonium and beryllium), oganesson (MK3: californium and molten
---   calcium), metastable oganesson (MK4: molten enriched naquadah alloy and oganesson; GT's route A, the MK5 route B
---   takes copper plasma, which only the godforge makes). Their fusion recipes like 136's transmutations: a tenth of
---   GT's litres, GT's time at the reactor's tier speed. Bartworks' calcium (WerkstoffLoader.java:695-711: the blast
---   furnace with gas, 1115 K, MV, no gas-free recipe) gives the melt; GoodGenerator's enriched naquadah alloy
---   (GGMaterial.java:1500-1523: 8 enriched naquadah, 5 tritanium, 3 californium, 2 black plutonium; the blast furnace
---   with gas, 120 s at UEV, 11 000 K, RecipeLoader2.java:118) with bartworks' mixer (mass / 4 ticks at its ZPM
---   processing tier) and vacuum freezer (mass x 3 ticks) rules; its mass, 289, derived from its contents (Werkstoff.java
---   350-362; black plutonium without an element counts as technetium, 98).
--- * The prosaic catalyst (GT's ExcitedDTPC: the crude catalyst's plasmas with radon, nickel, boron and sulfur;
---   TranscendentPlasmaMixerRecipes.java:40-54): the crude catalyst with those four plasmas, as 139 makes the
---   resplendent one, in GT's mixer time.
--- * Dimensionally Shifted Superfluid (gregtech/loaders/postload/recipes/PlasmaForgeRecipes.java:43-112): GT's tiers 2
---   (prosaic, UIV), 3 (resplendent, UMV) and 5 (stellar, UXV; with the stellar catalyst after the stargate). GT's tier 4
---   takes the exotic catalyst, which the mod lacks.
--- * Left for later: fermium plasma (no consumer before GT's creon), the godforge burning residue as fuel.
--- Unlocked with the technology Dimensionally Shifted Superfluid, the first consumer of the chain.
--------------------------------------------------------------------------------
do
	local DSS = "dimensionally-shifted-superfluid"
	local DTR = "dimensionally-transcendent-residue"
	local DTPF_CAT = "dimensionally-transcendent-plasma-forge-recipes"
	local CRUDE = "excited-dimensionally-transcendent-crude-catalyst"
	local PROSAIC = "excited-dimensionally-transcendent-prosaic-catalyst"
	local RESPLENDENT = "excited-dimensionally-transcendent-resplendent-catalyst"
	local STELLAR = "excited-dimensionally-transcendent-stellar-catalyst"
	local L = {}
	F.fluid(DTR, DTR, { 0.31, 0.31, 0.39 })   -- (the colours of GT's textures, gen_gt_icons.py)
	F.fluid("stable-baryonic-matter", "stable-baryonic-matter", { 0, 0.04, 0.61 })   -- (lifted)
	F.fluid(DSS, DSS, { 0.33, 0.04, 0.48 })
	F.fluid(PROSAIC, PROSAIC, { 0.83, 0.49, 0.49 })
	F.fluid("molten-calcium", "molten-calcium", { 1, 0.96, 0.96 })
	F.fluid("molten-californium", "molten-californium", { 0.67, 0.67, 0.67 })
	F.fluid("oganesson", "oganesson", { 0.11, 0.33, 0.73 })   -- (lifted)
	F.fluid("molten-enriched-naquadah-alloy", "molten-enriched-naquadah-alloy", { 0.20, 0.06, 0.59 })   -- (lifted)
	F.fluid("molten-metastable-oganesson", "molten-metastable-oganesson", { 0.11, 0.33, 0.73 })   -- (lifted)

	--- the residue of the existing plasma forge recipes (GT's DTR per litre of the product, a tenth)
	for name, amount in pairs({
		["molten-neutronium-dtpf-crude"] = 7.3, ["molten-neutronium-dtpf-resplendent"] = 2.46,
		["molten-cosmic-neutronium-dtpf-crude"] = 3.59, ["molten-cosmic-neutronium-dtpf-resplendent"] = 1.21,
		["molten-infinity-dtpf-resplendent"] = 920.8, ["molten-infinity-dtpf-stellar"] = 355.4,
		["molten-transcendent-metal-dtpf-stellar"] = 157.3,
		["timepiece"] = 20000, ["time-to-space-conversion"] = 200, ["space-to-time-conversion"] = 200,
		["chipped-amalgatite"] = 14400,
		["quantum-anomaly"] = 4.6, ["molten-chromatic-glass"] = 1950.5, ["molten-chromatic-glass-resplendent"] = 1317.5,
	}) do
		local r = data.raw.recipe[name]
		if r then r.results[#r.results + 1] = { type = "fluid", name = DTR, amount = amount } end
	end

	--- grade 8 water's stable baryonic matter
	local g8 = data.raw.recipe["grade-8-water"]
	g8.results[#g8.results + 1] = { type = "fluid", name = "stable-baryonic-matter", amount = 50 }

	--- calcium (the mod's calcium is GT's calcium dust)
	items(SUB_PART, { "calcium-ingot" })
	for _, g in pairs(GAS) do
		step(L, "calcium-ingot" .. (g[1] and ("-" .. g[1]) or ""), "mv-electric-blast-furnace-recipes", 55.75 * g[4], MV_SPEED,
			{ { "calcium", 1 }, { g[2], g[3] } }, { { "calcium-ingot", 1 } }, "calcium-ingot")
	end
	--- californium, oganesson
	items(SUB_PART, { "californium-ingot" })
	items(SUB_DUST, { "californium-dust", "tritanium-dust" })
	step(L, "molten-californium", "mk3-fusion-reactor-recipes", 12, UV_SPEED,
		{ { "molten-plutonium", 4.8 }, { "molten-beryllium", 4.8 } }, { { "molten-californium", 4.8 } })
	step(L, "californium-dust", "lv-macerator-recipes", 12.55, LV_SPEED, { { "californium-ingot", 1 } },
		{ { "californium-dust", 1 } })
	step(L, "tritanium-dust", "lv-macerator-recipes", 16.15, LV_SPEED, { { "tritanium-ingot", 1 } },
		{ { "tritanium-dust", 1 } })
	step(L, "oganesson", "mk3-fusion-reactor-recipes", 24, UV_SPEED,
		{ { "molten-californium", 3.2 }, { "molten-calcium", 72 } }, { { "oganesson", 72 } })
	--- enriched naquadah alloy, metastable oganesson
	local ENA = "enriched-naquadah-alloy"
	items(SUB_DUST, { ENA .. "-dust" })
	items(SUB_PART, { "hot-" .. ENA .. "-ingot", ENA .. "-ingot" })
	step(L, ENA .. "-dust", "zpm-mixer-recipes", 3.6, ZPM_SPEED,
		{ { "enriched-naquadah-dust", 8 }, { "tritanium-dust", 5 }, { "californium-dust", 3 }, { "black-plutonium-dust", 2 } },
		{ { ENA .. "-dust", 18 } })
	blast(L, ENA, "uev-electric-blast-furnace-recipes", 120, UEV_SPEED)
	step(L, ENA .. "-ingot", "zpm-vacuum-freezer-recipes", 43.35, ZPM_SPEED, { { "hot-" .. ENA .. "-ingot", 1 } },
		{ { ENA .. "-ingot", 1 } })
	step(L, "molten-metastable-oganesson", "mk4-fusion-reactor-recipes", 30, UEV_SPEED,
		{ { "molten-" .. ENA, 14.4 }, { "oganesson", 25 } }, { { "molten-metastable-oganesson", 3.6 } })
	--- the prosaic catalyst
	step(L, PROSAIC, DTPF_CAT, 5, UMV_SPEED,
		{ { CRUDE, 100 }, { "radon-plasma", 100 }, { "nickel-plasma", 100 }, { "boron-plasma", 100 }, { "sulfur-plasma", 100 } },
		{ { PROSAIC, 100 } })
	--- the superfluid
	local function superfluid(list, name, seconds, speed, sbm, mog, g8w, ct, radox, catalyst, out, residue)
		step(list, name, DTPF_CAT, seconds, speed,
			{ { "stable-baryonic-matter", sbm }, { "molten-metastable-oganesson", mog }, { "grade-8-water", g8w },
				{ "celestial-tungsten-plasma", ct }, radox, catalyst }, { { DSS, out }, { DTR, residue } }, DSS)
	end
	superfluid(L, DSS, 30, UIV_SPEED, 25, 14.4, 400, 3456, { "super-heavy-radox", 200 }, { PROSAIC, 100 }, 750, 25)
	superfluid(L, DSS .. "-resplendent", 30, UMV_SPEED, 100, 14.4, 1600, 3456, { "super-heavy-radox", 200 },
		{ RESPLENDENT, 200 }, 3000, 100)
	local STELLAR_DSS = {}
	superfluid(STELLAR_DSS, DSS .. "-stellar", 7.5, UXV_SPEED, 800, 57.6, 12800, 13824, { "heavy-radox", 3200 },
		{ STELLAR, 200 }, 36000, 400)

	F.tech{
		name = DSS, prerequisites = { "godforge-plasma-module" }, packs = 13, count = 95, time = 60, recipes = L,   -- (as 138's UMV techs)
	}
	for _, r in pairs(STELLAR_DSS) do fork_add_unlock("dtpf-stellar-catalyst", r) end
	table.insert(data.raw.technology["dtpf-stellar-catalyst"].prerequisites, DSS)
	for m, t in pairs({ calcium = "mv", californium = "uv", [ENA] = "uev" }) do FORK_CASTING.materials[m] = { t, DSS } end
	FORK_CASTING.run()
end



--------------------------------------------------------------------------------
--- 21) THE COLD TRAP II AND THE REACTOR PROCESSING UNIT II (issue #406): GT++'s ZPM tiers of the two single blocks
--- (gtPlusPlus/xmod/gregtech/registration/gregtech/GregtechLFTR.java:30-80), the same recipes at the ZPM speed. Their
--- controllers (gtPlusPlus/core/recipe/RecipesMachinesCustom.java:580-586, 596-602): the IV block with Pikyonium 64B
--- plates, double HS188-A plates and ZPM robot arms, with a frost proof casing (Cold Trap II) or two IV field generators
--- (RPU II). Pikyonium 64B (core/material/MaterialsAlloy.java:700-717): GT++'s alloy blast smelter
--- (xmod/gregtech/loaders/RecipeGenBlastSmelter.java:117-183) melts its eight dusts in their smallest ratio (8
--- Inconel-792, 5 Eglin steel, 4 enriched naquadah, 3 cerium, 2 antimony, 2 platinum, 1 ytterbium, 4 tungstensteel) into
--- 29 x 144 L at its tier (6850 C: tier 7, ZPM, 420 s); 143 casts ingots and plates. Inconel-792 dust from the ingot
--- (macerator, GT++'s rule RecipeGenRecycling.java:126: its mass in ticks, 58), the double HS188-A plate from two ingots
--- (bender, as the double Hastelloy-N plate). Each II block is the upgrade of its I block.
--------------------------------------------------------------------------------
do
	local II = {}
	local PIKY = "pikyonium-64b"
	F.fluid("molten-" .. PIKY, "molten-" .. PIKY, { 52 / 255, 103 / 255, 186 / 255 })
	dust("inconel-792-dust")
	for _, n in pairs({ PIKY .. "-ingot", PIKY .. "-plate", "double-hs188-a-plate" }) do
		create_item{ skip_recipe = true, name = n, subgroup = PARTS }
	end
	step(II, "inconel-792-dust", "lv-macerator-recipes", 2.9, LV_SPEED, { { "inconel-792-ingot", 1 } },
		{ { "inconel-792-dust", 1 } })
	step(II, "molten-" .. PIKY, "zpm-alloy-blast-smelter-recipes", 420, ZPM_SPEED,
		{ { "inconel-792-dust", 8 }, { "eglin-steel-dust", 5 }, { "enriched-naquadah-dust", 4 }, { "cerium-dust", 3 },
			{ "antimony", 2 }, { "platinum-dust", 2 }, { "ytterbium-dust", 1 }, { "tungstensteel-dust", 4 } },
		{ { "molten-" .. PIKY, 417.6 } })
	step(II, "double-hs188-a-plate", "iv-bending-machine-recipes", 3.9, IV_SPEED, { { "hs188-a-ingot", 2 } },
		{ { "double-hs188-a-plate", 1 } })
	local ZPM_CF = data.raw["assembling-machine"]["zpm-centrifuge"]
	local ZPM_POWER = ZPM_CF and ZPM_CF.energy_usage or EU16_ZPM
	local ZPM_SUB = data.raw.item["zpm-centrifuge"] and data.raw.item["zpm-centrifuge"].subgroup
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	machine{
		name = "reactor-processing-unit-ii", category = "reactor-processing-unit-recipes", speed = ZPM_SPEED,
		energy = ZPM_POWER, subgroup = ZPM_SUB,
		ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { -1, 1 }),
			port("output", S, { 0, 1 }), port("output", S, { 1, 1 }) },
		list = II,
		recipe = { "crafting-or-assembling-recipes", 1, { item("iv-field-generator", 2), item("zpm-robot-arm", 1),
			item(PIKY .. "-plate", 2), item("double-hs188-a-plate", 3), item("reactor-processing-unit-i", 1) } },
	}
	machine{
		name = "cold-trap-ii", category = "cold-trap-recipes", speed = ZPM_SPEED, energy = ZPM_POWER, subgroup = ZPM_SUB,
		ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { -1, 1 }),
			port("output", S, { 1, 1 }) },
		list = II,
		recipe = { "crafting-or-assembling-recipes", 1, { item(PIKY .. "-plate", 4), item("double-hs188-a-plate", 1),
			item("cold-trap-i", 1), item("zpm-robot-arm", 2), item("frost-proof-casing", 1) } },
	}
	--- the II block as the upgrade of the I block (fast replace, the upgrade planner)
	for _, n in pairs({ "reactor-processing-unit", "cold-trap" }) do
		local one, two = data.raw["assembling-machine"][n .. "-i"], data.raw["assembling-machine"][n .. "-ii"]
		two.fast_replaceable_group = one.fast_replaceable_group
		one.next_upgrade = two.name
	end
	F.tech{
		name = "nuclear-salt-processing-ii", prerequisites = { SPARGE, "zpm-machines" }, packs = 8, count = 1500, time = 60, recipes = II,
	}
	FORK_CASTING.materials[PIKY] = { "zpm", "nuclear-salt-processing-ii" }
	FORK_CASTING.run()
end



--------------------------------------------------------------------------------
--- 22) THE MEHEN BELT'S DRACONIUM (issue #356, the maintainer's decision on #417): the draconium ore of the Void Miner III
--- (160) gives GT New Horizons' draconium: the blast furnace with gas (NewHorizonsCoreMod BlastFurnaceRecipes.java:
--- 199-202: 7200 K, 200 s at LuV) and the vacuum freezer (VacuumFreezerRecipes.java:118-120: 14.7 s at IV), beside the
--- mod's fusion recipe of 131. Awakened draconium's ingot comes with its first consumer, the Naquadah Fuel Refinery.
--------------------------------------------------------------------------------
do
	local L = {}
	items(SUB_PART, { "hot-draconium-ingot" })
	blast(L, "draconium", "luv-electric-blast-furnace-recipes", 200, LUV_SPEED)
	step(L, "draconium-ingot-from-hot-ingot", "iv-vacuum-freezer-recipes", 14.7, IV_SPEED, { { "hot-draconium-ingot", 1 } },
		{ { "draconium-ingot", 1 } })
	for _, r in pairs(L) do fork_add_unlock("void-miner-iii", r) end
end



--------------------------------------------------------------------------------
--- 23) THE DEPLETED THORIUM BASED LIQUID FUEL AND PRASEODYMIUM (issue #356): GoodGenerator's neutron activator depletes
--- the excited fuel (NeutronActivatorLoader.java:26-32: 200 L, 500 s, no power; GT's other source, the large naquadah
--- reactor burning it 1:1, is left out as for the uranium and plutonium fuels of 136), its centrifuge (RecipeLoader.java:
--- 1529-1542: 1000 L into 64 + 16 (80 %) thorium 232, 64 + 32 (80 %) praseodymium, 2 boron (30 %), 4 indium (50 %),
--- 75 s at EV) gives GT's praseodymium, the mod's only source of it (fuel MK IV, #356). Fluids a tenth, the items GT's.
--------------------------------------------------------------------------------
do
	local L = {}
	local DEPLETED = "depleted-thorium-based-liquid-fuel"
	F.fluid(DEPLETED, "spackled-purple-fluid", { 0.25, 0.18, 0.30 })
	dust("praseodymium-dust")
	step(L, DEPLETED, "neutron-activator-recipes", 500, 1, { { "excited-thorium-based-liquid-fuel", 20 } },
		{ { DEPLETED, 20 } })
	step(L, DEPLETED .. "-centrifuging", "ev-centrifuge-recipes", 75, EV_SPEED, { { DEPLETED, 100 } },
		{ { "thorium-232-dust", 64 }, { "thorium-232-dust", 16, 0.8 }, { "praseodymium-dust", 64 },
			{ "praseodymium-dust", 32, 0.8 }, { "boron", 2, 0.3 }, { "indium", 4, 0.5 } }, "praseodymium-dust")
	for _, r in pairs(L) do fork_add_unlock("thorium-based-liquid-fuel", r) end
end




--------------------------------------------------------------------------------
--- 24) THE NETHERITE CHAIN'S MATERIALS (issue #356, the maintainer's decision on #421: GT's netherite chain for the
--- Radiation Proof Prismatic Naquadah Composite Sheet of the Naquadah Fuel Refinery). GT5-Unofficial 638b3f37ca and
--- NewHorizonsCoreMod; fluids a tenth of GT's litres, GT's seconds x the tier speed of GT's EU/t.
--- * Liquid nitrogen: GT's vacuum freezer (VacuumFreezerRecipes.java:221-226, 60 s, HV), as the mod's liquid oxygen.
--- * Cubic zirconia (bartworks AdditionalRecipes.java:372-380): 10 zirconium dust with oxygen and yttrium oxide (not
---   used up) in the blast furnace into 40 flawed gems (48 min, HV), each macerated into 2 small piles (GT: a flawed gem
---   is half a dust); YSZ ceramic dust (kekztech Mixer.java:23-30: 1 yttrium oxide, 5 cubic zirconia, 20 s, MV).
--- * Strontium: GT++'s fluorcaphite decomposition gives strontium oxide again (155), GT++'s alloy blast smelter reduces
---   it with aluminium (RecipesGregTech.java:1066-1076: 8 + 8 into oxygen, molten aluminium and molten strontium, 2 min,
---   EV); 143 casts the ingot, the macerator makes the dust (its mass in ticks, 87). The chain gives the strontium back.
--- * Bismuth telluride (bartworks DustLoader.java:249-273: 2 bismuth, 3 tellurium, 8.05 s, MV), magnetic steel dust (GT's
---   polarizer, ProcessingTransforming.java:116-132: 6.4 s, LV); tellurium from the Everglades ores of 155 (#356).
--- * Magneto Resonatic (bartworks WerkstoffLoader.java:625-639): the mixer (3 prasiolite, 4 bismuth telluride, 1 cubic
---   zirconia, 1 magnetic steel into 9, 1.1 s, LV), the gem only from the autoclave (krypton, 25 s, IV; AdditionalRecipes
---   .java:427-442, no implosion: NO_BLAST), the laser engraver's pink lens (the amethyst lens, 155) from 3 gems to a
---   flawless (60 s, HV) and 3 flawless to an exquisite gem (2 min, EV; GemLoader.java:204-240), the lathe into the lens
---   and 2 dust (2 min, LV; GemLoader.java:194-201). GT's chipped gems from neon are left out (no consumer).
--- * Crystalline alloy (Ender IO's; NewHorizonsCoreMod): the pulsating crystal (ScriptEnderIO.java:1321-1326: a diamond
---   and 8 pulsating iron nuggets, 30 s, MV), its powder (1724-1726: macerator, 5 s, MV), the dust (MixerRecipes.java:
---   941-947: powder, gold and emerald dust into 3, 5 s), the blast furnace with gas (BlastFurnaceRecipes.java:98-101:
---   4500 K, 60 s, EV), the vacuum freezer (VacuumFreezerRecipes.java:69-72: 28.6 s, EV); 143 melts it.
--- Unlocked with the technology Prismatic Naquadah, the chain's first consumer.
--------------------------------------------------------------------------------
do
	local PN = "prismatic-naquadah"
	local L = {}
	F.fluid("liquid-nitrogen", "liquid-nitrogen", { 0.66, 0.82, 0.96 })
	F.fluid("molten-strontium", "molten-strontium", { 0.78, 0.78, 0.78 })
	F.fluid("molten-crystalline-alloy", "molten-crystalline-alloy", { 0.29, 0.86, 0.86 })
	items(SUB_DUST, { "ysz-ceramic-dust", "strontium-dust", "bismuth-telluride-dust", "magnetic-steel-dust",
		"magneto-resonatic-dust", "pulsating-crystal-powder", "crystalline-alloy-dust" })
	items(SUB_PART, { "flawed-cubic-zirconia", "strontium-ingot", "magneto-resonatic-gem", "flawless-magneto-resonatic",
		"exquisite-magneto-resonatic", "magneto-resonatic-lens", "pulsating-crystal", "hot-crystalline-alloy-ingot",
		"crystalline-alloy-ingot" })
	step(L, "liquid-nitrogen", "hv-vacuum-freezer-recipes", 60, HV_SPEED, { { "nitrogen", 100 } }, { { "liquid-nitrogen", 100 } })
	--- cubic zirconia, YSZ
	step(L, "flawed-cubic-zirconia", "hv-electric-blast-furnace-recipes", 2880, HV_SPEED,
		{ { "zirconium-dust", 10 }, { "yttrium-oxide", 1 }, { "oxygen", 2000 } },
		{ { "flawed-cubic-zirconia", 40 }, { "yttrium-oxide", 1 } }, "flawed-cubic-zirconia")
	local p, r = pile("cubic-zirconia-dust", "small")
	FORK_RECIPES_TABLE_ONLY[r] = "GTNH: cubic zirconia comes only as flawed gems (bartworks' blast furnace), which "
		.. "macerate into small piles; GT makes the dust from them in the packager, which the mod does not have"
	L[#L + 1] = r
	step(L, "flawed-cubic-zirconia-maceration", "lv-macerator-recipes", 1.4, LV_SPEED, { { "flawed-cubic-zirconia", 1 } },
		{ { p, 2 } })
	step(L, "ysz-ceramic-dust", "mv-mixer-recipes", 20, MV_SPEED, { { "yttrium-oxide", 1 }, { "cubic-zirconia-dust", 5 } },
		{ { "ysz-ceramic-dust", 6 } })
	--- strontium
	step(L, "molten-strontium", "ev-alloy-blast-smelter-recipes", 120, EV_SPEED,
		{ { "strontium-oxide-dust", 8 }, { "aluminium-dust", 8 } },
		{ { "molten-strontium", 115.2 }, { "oxygen", 800 }, { "molten-aluminium", 115.2 } })
	step(L, "strontium-dust", "lv-macerator-recipes", 4.35, LV_SPEED, { { "strontium-ingot", 1 } }, { { "strontium-dust", 1 } })
	--- the Magneto Resonatic lens
	step(L, "bismuth-telluride-dust", "mv-chemical-reactor-recipes", 8.05, MV_SPEED, { { "bismuth", 2 }, { "tellurium-dust", 3 } },
		{ { "bismuth-telluride-dust", 5 } })
	step(L, "magnetic-steel-dust", "lv-polarizer-recipes", 6.4, LV_SPEED, { { "steel-dust", 1 } }, { { "magnetic-steel-dust", 1 } })
	step(L, "magneto-resonatic-dust", "lv-mixer-recipes", 1.1, LV_SPEED,
		{ { "prasiolite-dust", 3 }, { "bismuth-telluride-dust", 4 }, { "cubic-zirconia-dust", 1 }, { "magnetic-steel-dust", 1 } },
		{ { "magneto-resonatic-dust", 9 } })
	step(L, "magneto-resonatic-gem", "iv-autoclave-recipes", 25, IV_SPEED, { { "magneto-resonatic-dust", 1 }, { "krypton", 100 } },
		{ { "magneto-resonatic-gem", 1 } })
	step(L, "flawless-magneto-resonatic", "hv-laser-engraver-recipes", 60, HV_SPEED,
		{ { "magneto-resonatic-gem", 3 }, { "amethyst-lens", 1 } }, { { "flawless-magneto-resonatic", 1 }, { "amethyst-lens", 1 } },
		"flawless-magneto-resonatic")
	step(L, "exquisite-magneto-resonatic", "ev-laser-engraver-recipes", 120, EV_SPEED,
		{ { "flawless-magneto-resonatic", 3 }, { "amethyst-lens", 1 } },
		{ { "exquisite-magneto-resonatic", 1 }, { "amethyst-lens", 1 } }, "exquisite-magneto-resonatic")
	step(L, "magneto-resonatic-lens", "lv-lathe-recipes", 120, LV_SPEED, { { "exquisite-magneto-resonatic", 1 } },
		{ { "magneto-resonatic-lens", 1 }, { "magneto-resonatic-dust", 2 } })
	--- crystalline alloy
	step(L, "pulsating-crystal", "mv-assembling-machine-recipes", 30, MV_SPEED,
		{ { "diamond", 1 }, { "pulsating-iron-nugget", 8 } }, { { "pulsating-crystal", 1 } })
	step(L, "pulsating-crystal-powder", "mv-macerator-recipes", 5, MV_SPEED, { { "pulsating-crystal", 1 } },
		{ { "pulsating-crystal-powder", 1 } })
	step(L, "crystalline-alloy-dust", "lv-mixer-recipes", 5, LV_SPEED,
		{ { "pulsating-crystal-powder", 1 }, { "gold-dust", 1 }, { "emerald-dust", 1 } }, { { "crystalline-alloy-dust", 3 } })
	blast(L, "crystalline-alloy", "ev-electric-blast-furnace-recipes", 60, EV_SPEED)
	step(L, "crystalline-alloy-ingot", "ev-vacuum-freezer-recipes", 28.6, EV_SPEED, { { "hot-crystalline-alloy-ingot", 1 } },
		{ { "crystalline-alloy-ingot", 1 } })

	F.tech{ name = PN, prerequisites = { "reach-the-everglades", "industrial-mixer", "zpm-multiblocks" }, packs = 9,
		count = 1500, time = 60, recipes = L }
	--- (the cubic zirconia recipe gives its yttrium oxide back, so 199 would count it as a producer and drop the pull of
	--- yttrium oxide into its first consumer, the fluid shaper: keep that unlock)
	fork_add_unlock("fluid-shaper", "yttrium-oxide")
	FORK_CASTING.materials["strontium"] = { "lv", PN }
	FORK_CASTING.materials["crystalline-alloy"] = { "ev", PN }
	FORK_CASTING.run()
end




--------------------------------------------------------------------------------
--- 25) GT++'S ALGAE FARM AND INDUSTRIAL DEHYDRATOR (issue #356, the netherite chain, part 2): the red algae biomass of
--- the chain's prismarine and the vacuum furnace of its prismatic gas. GT5-Unofficial 638b3f37ca.
--- * The Algae Farm (gregtech/common/tileentities/machines/multi/MTEAlgaePond.java, recipes gtPlusPlus/xmod/gregtech/
---   loaders/recipe/RecipeLoaderAlgaePond.java): recipes without inputs, the tier of its energy hatch picks the recipe
---   (and needs glass of that tier), compost lifts it one tier for 2^(tier-1) of it (MTEAlgaePond.java:327-370), no
---   overclock. Red algae starts at tier 5: here an IV farm (GT's IV glass is bartworks' tungstensteel reinforced
---   borosilicate glass, FluidSolidifier.java: borosilicate glass and 8 ingots of molten tungstensteel, 40 s, EV), its
---   tier-5 recipe (50 s: 4 red algae at 90 %) and with 16 compost the tier-6 one (25.6 s: 3 and 12 at 90 %). GT's other
---   algae (algae, green, brown and golden-brown biomass) are left out: nothing in the mod takes them but compost. Compost
---   from red algae (gtPlusPlus/plugin/agrichem/BioRecipes.java:172-178: 1 into 2, macerator, 20 s).
---   Its item: GT++'s controller (core/recipe/RecipesMachinesCustom.java:368-383: 4 Integral Encasements I, 12 aluminium
---   rods, 32 wood plates, 16 steel bolts, 32 redstone, 8 ingots of molten potin; MV, 60 s) with the structure (25 algae
---   casings, 64 glass, 6 stainless steel frames, 5 filter casings), the energy hatch and hulls for the maintenance hatch
---   and the output bus. Integral Encasement I (RecipesMachinesTiered.java:488-502): GT's ULV casing, 8 potin plates, 2
---   potin gears (GT++'s gear is the mod's large gear), 4 2x tin cables (8 cables), 2 ULV circuits (vacuum tubes), 2
---   ingots of molten steel; LV, 20 s. The algae casing (gregtech/loaders/load/MTERecipeLoader.java:1638-1648): a rose
---   gold frame, 4 rose gold plates, 2 stainless steel plates; LV, 2.5 s. Rose gold: the mod's dust (its mixer), GT's
---   blast furnace (1600 K: mass / 40 x 1600 ticks, MV,
---   ProcessingDust.java:100-118) and 158's part rules (plate: bender, mass; rod: lathe, 5 x mass, 2 small piles; frame:
---   assembler, 4 rods, 3.2 s); the wood plate (CompressorRecipes.java:159-165: 8 wood dust, the mod's wood pulp; 15 s).
--- * The Industrial Dehydrator, Utupu-Tanuri (xmod/gregtech/common/tileentities/machines/multi/processing/
---   MTEIndustrialDehydrator.java): two modes, the vacuum furnace and the multiblock chemical dehydrator, 4 parallels at
---   2.2 times the speed and half the EU, its coils' heat for the recipes' (the prismatic gas: 7200 K, the naquadah coil).
---   Here a ZPM machine (its 24 coils naquadah coils) at ZPM speed x 2.2 x 4 parallels, twice a ZPM machine's power.
---   Its item: GT++'s controller (core/recipe/RecipesMachinesMulti.java:932-946: a vacuum casing, 4 16x YBCO wires (64
---   wires), 4 EV robot arms, 8 Zeron-100 plates, 8 LuV circuits, 20 ingots of molten Zeron-100; LuV, 12 min), 12 vacuum
---   casings (:919-930: a multi-use casing, a nichrome coil, 2 HV pistons, 4 Zeron-100 plates, 2 Zeron-100 gears; LuV,
---   60 s), the coils, the energy hatch and hulls for the muffler, the maintenance hatch and the buses and hatches.
---   Left out: the vacuum casing's 8 ingots of GT++'s Energy Crystal alloy, made of Thaumcraft's aspects (Aer, Terra,
---   Ignis, Aqua; MaterialsAlloy.java), which the mod does not have.
--- Unlocked with Prismatic Naquadah, the chain's technology.
--------------------------------------------------------------------------------
do
	local PN = "prismatic-naquadah"
	local L = {}
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	F.category("algae-farm-recipes")
	F.category("vacuum-furnace-recipes")
	F.category("industrial-dehydrator-recipes")
	items(SUB_PART, { "red-algae-biomass", "compost", "rose-gold-ingot", "rose-gold-plate", "rose-gold-rod",
		"rose-gold-frame", "wood-plate", "integral-encasement-i", "algae-farm-casing",
		"tungstensteel-reinforced-borosilicate-glass-block", "algae-farm-controller", "vacuum-furnace-casing",
		"industrial-dehydrator-controller" })
	--- rose gold
	local small, small_r = pile("rose-gold-dust", "small")
	L[#L + 1] = small_r
	--- (the piles only give the lathe's dust back: 157 must not count them as a second recipe of rose gold dust, whose
	--- material it would then lose in the recycling of everything made with the dust; 157 skips 143's recipes)
	FORK_CASTING.recipes[small_r] = true
	step(L, "rose-gold-ingot", "mv-electric-blast-furnace-recipes", 320, MV_SPEED, { { "rose-gold-dust", 1 } },
		{ { "rose-gold-ingot", 1 } })
	step(L, "rose-gold-plate", "lv-bending-machine-recipes", 8.45, LV_SPEED, { { "rose-gold-ingot", 1 } },
		{ { "rose-gold-plate", 1 } })
	step(L, "rose-gold-rod", "lv-lathe-recipes", 42.25, LV_SPEED, { { "rose-gold-ingot", 1 } },
		{ { "rose-gold-rod", 1 }, { small, 2 } })
	step(L, "rose-gold-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "rose-gold-rod", 4 } },
		{ { "rose-gold-frame", 1 } })
	--- the algae farm's parts
	step(L, "wood-plate", "lv-compressor-recipes", 15, LV_SPEED, { { "wood-pulp", 8 } }, { { "wood-plate", 1 } })
	step(L, "integral-encasement-i", "lv-assembling-machine-recipes", 20, LV_SPEED,
		{ { "ulv-machine-casing", 1 }, { "potin-plate", 8 }, { "large-potin-gear", 2 }, { "tin-cable", 8 }, { "vacuum-tube", 2 },
			{ "molten-steel", 28.8 } }, { { "integral-encasement-i", 1 } })
	step(L, "algae-farm-casing", "lv-assembling-machine-recipes", 2.5, LV_SPEED,
		{ { "rose-gold-frame", 1 }, { "rose-gold-plate", 4 }, { "stainless-steel-plate", 2 } }, { { "algae-farm-casing", 1 } })
	step(L, "tungstensteel-reinforced-borosilicate-glass-block", "ev-fluid-solidifier-recipes", 40, EV_SPEED,
		{ { "borosilicate-glass-block", 1 }, { "molten-tungstensteel", 115.2 } },
		{ { "tungstensteel-reinforced-borosilicate-glass-block", 1 } })
	step(L, "algae-farm-controller", "mv-assembling-machine-recipes", 60, MV_SPEED,
		{ { "integral-encasement-i", 4 }, { "aluminium-rod", 12 }, { "wood-plate", 32 }, { "steel-bolt", 16 },
			{ "redstone-dust", 32 }, { "molten-potin", 115.2 } }, { { "algae-farm-controller", 1 } })
	local IV_CF = data.raw["assembling-machine"]["iv-centrifuge"]
	machine{
		name = "algae-farm", category = "algae-farm-recipes", speed = IV_SPEED, energy = IV_CF and IV_CF.energy_usage or EU16_IV,
		subgroup = "subgroup-iv-age-multiblocks", ports = {}, list = L,
		recipe = { "crafting-or-assembling-recipes", 1, { item("algae-farm-controller", 1), item("algae-farm-casing", 25),
			item("tungstensteel-reinforced-borosilicate-glass-block", 64), item("stainless-steel-frame", 6),
			item("filter-casing", 5), item("iv-energy-hatch", 1), item("lv-machine-hull", 2) } },
	}
	step(L, "red-algae-biomass", "algae-farm-recipes", 50, IV_SPEED, {}, { { "red-algae-biomass", 4, 0.9 } })
	step(L, "red-algae-biomass-with-compost", "algae-farm-recipes", 25.6, IV_SPEED, { { "compost", 16 } },
		{ { "red-algae-biomass", 3 }, { "red-algae-biomass", 12, 0.9 } }, "red-algae-biomass")
	step(L, "compost", "lv-macerator-recipes", 20, LV_SPEED, { { "red-algae-biomass", 1 } }, { { "compost", 2 } })
	--- the industrial dehydrator
	step(L, "vacuum-furnace-casing", "luv-assembling-machine-recipes", 60, LUV_SPEED,
		{ { "multi-use-casing", 1 }, { "nichrome-coil-block", 1 }, { "hv-piston", 2 }, { "zeron-100-plate", 4 },
			{ "large-zeron-100-gear", 2 } }, { { "vacuum-furnace-casing", 1 } })
	step(L, "industrial-dehydrator-controller", "luv-assembling-machine-recipes", 720, LUV_SPEED,
		{ { "vacuum-furnace-casing", 1 }, { "yttrium-barium-cuprate-wire", 64 }, { "ev-robot-arm", 4 }, { "zeron-100-plate", 8 },
			{ "luv-circuit", 8 }, { "molten-zeron-100", 288 } }, { { "industrial-dehydrator-controller", 1 } })
	local ZPM_CF = data.raw["assembling-machine"]["zpm-centrifuge"]
	local ZPM_POWER = ZPM_CF and ZPM_CF.energy_usage or EU16_ZPM
	machine{
		name = "industrial-dehydrator", category = "vacuum-furnace-recipes", speed = ZPM_SPEED * 2.2 * 4,
		energy = (tonumber(ZPM_POWER:match("^[%d.]+")) * 2) .. ZPM_POWER:match("%a+$"),
		subgroup = "subgroup-zpm-age-multiblocks",
		ports = { port("input", N, { -1, -1 }), port("input", N, { 0, -1 }), port("input", N, { 1, -1 }),
			port("output", S, { -1, 1 }), port("output", S, { 0, 1 }), port("output", S, { 1, 1 }) },
		list = L,
		recipe = { "crafting-or-assembling-recipes", 1, { item("industrial-dehydrator-controller", 1),
			item("vacuum-furnace-casing", 12), item("naquadah-coil-block", 24), item("zpm-energy-hatch", 1),
			item("lv-machine-hull", 4) } },
	}
	data.raw["assembling-machine"]["industrial-dehydrator"].crafting_categories =
		{ "vacuum-furnace-recipes", "industrial-dehydrator-recipes" }
	for _, r in pairs(L) do fork_add_unlock(PN, r) end
end




--------------------------------------------------------------------------------
--- 26) THE NETHERITE CHAIN TO THE RADIATION PROOF PRISMATIC NAQUADAH COMPOSITE SHEET (issue #356, part 3): GT's
--- gregtech/loaders/postload/chains/NetheriteRecipes.java:66-224 (GT5-Unofficial 638b3f37ca), fluids a tenth of GT's
--- litres (plasmas and the water grades GT's), GT's seconds x the tier speed of GT's EU/t:
--- * prismarine shards (autoclave: 32 red algae, 32 certus quartz dust, 8000 L grade 1 water into 8; 15 s, LuV);
--- * the prismarine solution (dissolution tank: 24 shards with industrial strength hydrofluoric acid and hydrogen
---   peroxide, 4000 L each, into 8000 L and 4 certus quartz dust; the loop: 6 shards with 6000 L of the contaminated
---   hydrogen peroxide and 2000 L hydrogen peroxide, 1 nether quartz dust; 20 s, IV);
--- * the extraction (chemical bath: 1000 L solution with 2000 L nitrobenzene, 15 s, EV; the loop with 3000 L of the
---   contaminated nitrobenzene, 30 s, IV) into 1000 L contaminated hydrogen peroxide and 2000 L prismarine-rich
---   nitrobenzene solution (the baths' second ports: 101);
--- * strontium hydroxide (1 strontium, 1000 L oxygen and hydrogen into 3; 10 s, MV) and the precipitation (chemical
---   plant: 42 of it with 16 000 L rich solution into 8 prismarine precipitate, 12 000 L contaminated nitrobenzene and
---   4000 L nitrobenzene; 40 s, LuV);
--- * the prismatic crystal (laser engraver: a precipitate, the Magneto Resonatic lens, 72 L molten crystalline alloy; the
---   crystal and 288 L molten strontium back; 10 s, LuV; the engravers' fluid outputs: 101);
--- * prismatic gas (the vacuum furnace, 7200 K: a crystal and 100 L boron plasma into 1000 L; 80 s, LuV), prismatic acid
---   (vacuum freezer: 4000 L gas, 12 000 L liquid nitrogen into 16 000 L; 25 s, ZPM);
--- * molten prismatic naquadah (alloy blast smelter: 32 enriched naquadah dust, 8000 L acid into 2304 L; 20 s, LuV), the
---   composite slurry (mixer: 4 YSZ, 32 mica dust, 576 L into 2000 L; 5 s, IV) and the sheet (the multiblock chemical
---   dehydrator: 16 tungsten carbide foils, 16 lead foils, 8000 L slurry into 16; 16 s, ZPM).
--- Left out: GT's prismatic bee comb (no bees in the mod), the raw fluorophlogopite slurry (no fluorophlogopite), the
--- Naquarite foil (netherite). Unlocked with Prismatic Naquadah.
--------------------------------------------------------------------------------
do
	local PN = "prismatic-naquadah"
	local L = {}
	local SOL, CH2O2 = "prismarine-solution", "prismarine-contaminated-hydrogen-peroxide"
	local RICH, CNB = "prismarine-rich-nitrobenzene-solution", "prismarine-contaminated-nitrobenzene-solution"
	F.fluid(SOL, SOL, { 0x55 / 255, 0x9a / 255, 0x8a / 255 })
	F.fluid(CH2O2, CH2O2, { 0x44 / 255, 0x5f / 255, 0x59 / 255 })
	F.fluid(RICH, RICH, { 0x5d / 255, 0x76 / 255, 0x3f / 255 })
	F.fluid(CNB, CNB, { 0x2f / 255, 0x33 / 255, 0x1e / 255 })
	F.fluid("prismatic-gas", "prismatic-gas", { 0x76 / 255, 0xba / 255, 0xbd / 255 })
	F.fluid("prismatic-acid", "prismatic-acid", { 1, 1, 1 })
	F.fluid("molten-prismatic-naquadah", "molten-prismatic-naquadah", { 0.57, 0.57, 0.57 })   -- (lifted, as its icon)
	F.fluid("prismatic-naquadah-composite-slurry", "prismatic-naquadah-composite-slurry", { 0x4b / 255, 0x4b / 255, 0x4b / 255 })
	items(SUB_DUST, { "strontium-hydroxide-dust" })
	items(SUB_PART, { "prismarine-shard", "prismarine-precipitate", "prismatic-crystal",
		"radiation-proof-prismatic-naquadah-composite-sheet" })
	step(L, "prismarine-shard", "luv-autoclave-recipes", 15, LUV_SPEED,
		{ { "red-algae-biomass", 32 }, { "certus-quartz-dust", 32 }, { "grade-1-water", 8000 } }, { { "prismarine-shard", 8 } })
	step(L, SOL, "dissolution-tank-recipes", 20, IV_SPEED,
		{ { "prismarine-shard", 24 }, { "industrial-strength-hydrofluoric-acid", 400 }, { "hydrogen-peroxide", 400 } },
		{ { SOL, 800 }, { "certus-quartz-dust", 4 } })
	step(L, SOL .. "-looped", "dissolution-tank-recipes", 20, IV_SPEED,
		{ { "prismarine-shard", 6 }, { CH2O2, 600 }, { "hydrogen-peroxide", 200 } }, { { SOL, 800 }, { "nether-quartz-dust", 1 } }, SOL)
	step(L, RICH, "ev-chemical-bath-recipes", 15, EV_SPEED, { { SOL, 100 }, { "nitrobenzene", 200 } },
		{ { RICH, 200 }, { CH2O2, 100 } })
	step(L, RICH .. "-looped", "iv-chemical-bath-recipes", 30, IV_SPEED, { { SOL, 100 }, { CNB, 300 } },
		{ { RICH, 200 }, { CH2O2, 100 } }, RICH)
	step(L, "strontium-hydroxide-dust", "mv-chemical-reactor-recipes", 10, MV_SPEED,
		{ { "strontium-dust", 1 }, { "oxygen", 100 }, { "hydrogen", 100 } }, { { "strontium-hydroxide-dust", 3 } })
	step(L, "prismarine-precipitate", "chemical-plant-recipes", 40, LUV_SPEED, { { "strontium-hydroxide-dust", 42 }, { RICH, 1600 } },
		{ { "prismarine-precipitate", 8 }, { CNB, 1200 }, { "nitrobenzene", 400 } })
	step(L, "prismatic-crystal", "luv-laser-engraver-recipes", 10, LUV_SPEED,
		{ { "prismarine-precipitate", 1 }, { "magneto-resonatic-lens", 1 }, { "molten-crystalline-alloy", 7.2 } },
		{ { "prismatic-crystal", 1 }, { "magneto-resonatic-lens", 1 }, { "molten-strontium", 28.8 } }, "prismatic-crystal")
	step(L, "prismatic-gas", "vacuum-furnace-recipes", 80, LUV_SPEED, { { "prismatic-crystal", 1 }, { "boron-plasma", 100 } },
		{ { "prismatic-gas", 100 } })
	step(L, "prismatic-acid", "zpm-vacuum-freezer-recipes", 25, ZPM_SPEED, { { "prismatic-gas", 400 }, { "liquid-nitrogen", 1200 } },
		{ { "prismatic-acid", 1600 } })
	step(L, "molten-prismatic-naquadah", "luv-alloy-blast-smelter-recipes", 20, LUV_SPEED,
		{ { "enriched-naquadah-dust", 32 }, { "prismatic-acid", 800 } }, { { "molten-prismatic-naquadah", 230.4 } })
	step(L, "prismatic-naquadah-composite-slurry", "iv-mixer-recipes", 5, IV_SPEED,
		{ { "ysz-ceramic-dust", 4 }, { "mica-dust", 32 }, { "molten-prismatic-naquadah", 57.6 } },
		{ { "prismatic-naquadah-composite-slurry", 200 } })
	step(L, "radiation-proof-prismatic-naquadah-composite-sheet", "industrial-dehydrator-recipes", 16, ZPM_SPEED,
		{ { "tungsten-carbide-foil", 16 }, { "lead-foil", 16 }, { "prismatic-naquadah-composite-slurry", 800 } },
		{ { "radiation-proof-prismatic-naquadah-composite-sheet", 16 } })
	for _, r in pairs(L) do fork_add_unlock(PN, r) end
end




--------------------------------------------------------------------------------
--- 27) THE NAQUADAH FUEL REFINERY WITH NAQUADAH FUEL MK III AND MK IV (issue #356, the maintainer's decisions on #417
--- and #421). GT5-Unofficial 638b3f37ca (GoodGenerator: goodgenerator/loader/RecipeLoader.java (RL), FuelRecipeLoader.java
--- (FL); GT's refinery gregtech/common/tileentities/machines/multi/MTENaquadahFuelRefinery.java) and NewHorizonsCoreMod;
--- melts a tenth of GT's litres, GT's seconds x the tier speed of GT's EU/t.
--- * The refinery: 27x27x5 in GT, 470-483 Naquadah Fuel Refinery Casings, 192 Field Restriction Glass, 124 Europium
---   Reinforced Radiation Proof Machine Casings, 72 Field Restriction Coils, 64 Radiation Proof Steel Frame Boxes. The
---   coil tier gates the recipe (MK III: T1, MK IV: T2), gives 4 parallels per tier and a perfect overclock per tier above
---   the recipe's. Here two machines as the mod builds tiered casings (the precise assembler): the refinery with T1 coils
---   (UHV, 4 parallels: MK III) and the one with T2 coils (UMV, 8 parallels: MK III and MK IV), each at its tier's speed
---   times its parallels and that many amps of its tier; the second is the first with 72 T2 coils and a UMV hatch.
---   Their items: GT's controller (RL:658-684, the assembly line) with the structure (483 casings), the energy hatch and
---   hulls for the input bus, input hatch and output hatch.
--- * The parts with GT's recipes: the casing (RL:704-722; thulium frame, 6 advanced radiation protection plates, ...),
---   the advanced radiation protection plate (RL:686-702) and the radiation protection plate (RL:67-77), the field
---   restriction glass (RL:813-824: a borosilicate glass frame, 6 reinforced glass plates, 32 naquadah alloy rings, 4 HV
---   field generators, 2 ingots of molten naquadria; ZPM, 15 s), the Europium reinforced casing and its radiation proof
---   machine casing (bartworks Assembler.java:106-126), the radiation proof steel frame box (RL:129-138: 8 long prismatic
---   naquadah rods, 4 HSS-E frames), the coils T1 and T2 (RL:724-766), the controller's huge mysterious crystal pipes
---   (GT's extruder, 12 ingots; the ingot from NewHorizonsCoreMod's blast furnace with gas, 7200 K, ZPM, 320 s, and
---   vacuum freezer, IV, 14.7 s), thulium screws and frame (GT's blast furnace at 1818 K: mass / 40 x 1818 ticks, MV;
---   vacuum freezer mass x 3 ticks, MV; 158's part rules), awakened draconium (NHC's blast furnace with gas, 9900 K, ZPM,
---   250 s; vacuum freezer, LuV, 14.7 s), extremely unstable naquadah (RL:647-656: 32 naquadria dust and fluoroantimonic
---   acid in the IV blast furnace into 17 and acid naquadah emulsion; RecipeLoader2.java:104: the hot ingot, ZPM, 400 s;
---   RL:1430-1435: the vacuum freezer, LuV, 20 s), GT's medium pipes (extruder, 3 ingots), tiny naquadah pipes (extruder,
---   1 ingot into 2), fine manyullyn wire (wiremill), the reinforced glass melt (GT's fluid extractor, EV, 5 s) cast into
---   plates and the borosilicate glass cast into rods (143). GT's 2x and 4x superconductor wires are 2 and 4 wires.
--- * High density uranium (RL:141-166): the graphite-uranium mixture (bartworks' mixer: 3 graphite, 1 uranium into 4),
---   4 of it with 2 tungsten carbide foils wrapped (HV, 70 s), 4 wraps in the implosion compressor (GT's 8 TNT: 2
---   explosives) into a nugget and 8 tiny tungsten carbide piles, 9 nuggets compressed (HV, 30 s); nether star dust (GT's
---   macerator, its mass in ticks).
--- * MK III (FL:57-71: 4 extremely unstable naquadah, 27 tiberium dust, 2 high density uranium, 1 high density plutonium,
---   800 L heavy and 1000 L light naquadah fuel into 100 L; 5 s, UHV) replaces 136's stand-in in the UEV mixer; MK IV
---   (FL:89-103: 27 extremely unstable naquadah, 64 nether star dust, 64 awakened draconium dust, 32 orundum dust, 2000 L
---   MK III and 9216 L molten praseodymium into 250 L; 8 s, 46 000 000 EU/t: UMV). The fuels keep GT's litres as 136's MK1
---   and MK2 (their fuel value is GT's EU per litre), the melts are a tenth (their material cost stays GT's). MK IV burns at
---   GT's 88 540 000 EU/t x 100 ticks per litre in the large naquadah reactors. GT's alternative recipes: chromatic glass
---   dust left out; hypogen and the one-step MK IV in section 35 (#436); MK V and VI in section 29 (#356).
--------------------------------------------------------------------------------
do
	local T1, T2 = "naquadah-fuel-refinery", "naquadah-based-fuel-mk4"
	local R1, R2 = {}, {}
	local NFR = "naquadah-fuel-refinery"
	local EUN = "extremely-unstable-naquadah"
	local MK3, MK4 = "naquadah-based-fuel-mk3", "naquadah-based-fuel-mk4"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	F.category(NFR .. "-recipes")
	F.category(NFR .. "-t2-recipes")
	F.fluid("molten-" .. EUN, "molten-" .. EUN, { 21 / 255, 136 / 255, 18 / 255 })
	F.fluid("molten-awakened-draconium", "molten-awakened-draconium", { 244 / 255, 78 / 255, 0 })
	F.fluid("molten-praseodymium", "molten-praseodymium", { 117 / 255, 214 / 255, 129 / 255 })
	F.fluid("molten-reinforced-glass", "molten-reinforced-glass", { 192 / 255, 245 / 255, 254 / 255 })
	F.fluid(MK4, "spackled-forest-green-fluid", { 0.15, 0.85, 0.65 })   -- (as 136's MK1 to MK3)
	data.raw.fluid[MK4].fuel_value = "8854GJ"   -- (88 540 000 EU/t x 100 ticks, 1 EU = 1 kJ as in 136)
	do
		local fuels = data.raw["mod-data"]["fork-power"].data.fuels
		for name, list in pairs(fuels) do
			if name:find("large%-naquadah%-reactor$") then
				local found = false
				for _, x in pairs(list) do found = found or x == MK4 end   -- (the reactors share one list)
				if not found then list[#list + 1] = MK4 end
			end
		end
	end
	items(SUB_DUST, { EUN .. "-dust", "graphite-uranium-mixture", "nether-star-dust" })
	items(SUB_PART, { "hot-" .. EUN .. "-ingot", EUN .. "-ingot", "wrapped-uranium-ingot", "high-density-uranium-nugget",
		"high-density-uranium", "hot-mysterious-crystal-ingot", "mysterious-crystal-ingot",
		"huge-mysterious-crystal-fluid-pipe", "hot-awakened-draconium-ingot", "awakened-draconium-ingot",
		"hot-thulium-ingot", "thulium-ingot", "thulium-rod", "thulium-bolt", "thulium-screw", "thulium-frame",
		"fine-manyullyn-wire", "tiny-naquadah-fluid-pipe", "medium-black-plutonium-item-pipe", "medium-neutronium-fluid-pipe",
		"borosilicate-glass-rod", "borosilicate-glass-frame", "reinforced-glass-plate", "long-prismatic-naquadah-rod" })
	items("subgroup-uhv-age-multiblocks", { "radiation-protection-plate", "advanced-radiation-protection-plate",
		"naquadah-fuel-refinery-casing", "field-restriction-glass", "radiation-proof-machine-casing",
		"europium-reinforced-radiation-proof-machine-casing", "radiation-proof-steel-frame-box", "field-restriction-coil",
		"advanced-field-restriction-coil", "naquadah-fuel-refinery-controller" })
	local tiny_wc, tiny_wc_r = pile("tungsten-carbide-dust", "tiny")
	local thulium_small, thulium_small_r = pile("thulium-dust", "small")
	FORK_CASTING.recipes[tiny_wc_r] = true
	FORK_CASTING.recipes[thulium_small_r] = true
	R1[#R1 + 1] = tiny_wc_r
	R1[#R1 + 1] = thulium_small_r

	--- extremely unstable naquadah
	step(R1, EUN .. "-dust", "iv-electric-blast-furnace-recipes", 180, IV_SPEED,
		{ { "naquadria-dust", 32 }, { "fluoroantimonic-acid", 400 } }, { { EUN .. "-dust", 17 }, { "acid-naquadah-emulsion", 800 } })
	step(R1, "hot-" .. EUN .. "-ingot", "zpm-electric-blast-furnace-recipes", 400, ZPM_SPEED, { { EUN .. "-dust", 1 } },
		{ { "hot-" .. EUN .. "-ingot", 1 } })
	step(R1, EUN .. "-ingot", "luv-vacuum-freezer-recipes", 20, LUV_SPEED, { { "hot-" .. EUN .. "-ingot", 1 } }, { { EUN .. "-ingot", 1 } })
	--- high density uranium, nether star dust
	step(R1, "graphite-uranium-mixture", "lv-mixer-recipes", 1.7, LV_SPEED, { { "graphite", 3 }, { "uranium-238-dust", 1 } },
		{ { "graphite-uranium-mixture", 4 } })
	step(R1, "wrapped-uranium-ingot", "hv-assembling-machine-recipes", 70, HV_SPEED,
		{ { "graphite-uranium-mixture", 4 }, { "tungsten-carbide-foil", 2 } }, { { "wrapped-uranium-ingot", 1 } })
	step(R1, "high-density-uranium-nugget", "lv-implosion-compressor-recipes", 1, LV_SPEED,
		{ { "wrapped-uranium-ingot", 4 }, { "explosives", 2 } }, { { "high-density-uranium-nugget", 1 }, { tiny_wc, 8 } })
	step(R1, "high-density-uranium", "hv-compressor-recipes", 30, HV_SPEED, { { "high-density-uranium-nugget", 9 } },
		{ { "high-density-uranium", 1 } })
	step(R2, "nether-star-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "nether-star", 1 } }, { { "nether-star-dust", 1 } })
	--- mysterious crystal, awakened draconium, thulium
	blast(R1, "mysterious-crystal", "zpm-electric-blast-furnace-recipes", 320, ZPM_SPEED)
	step(R1, "mysterious-crystal-ingot", "iv-vacuum-freezer-recipes", 14.7, IV_SPEED, { { "hot-mysterious-crystal-ingot", 1 } },
		{ { "mysterious-crystal-ingot", 1 } })
	step(R1, "huge-mysterious-crystal-fluid-pipe", "hv-extruder-recipes", 4.8, HV_SPEED, { { "mysterious-crystal-ingot", 12 } },
		{ { "huge-mysterious-crystal-fluid-pipe", 1 } })
	blast(R1, "awakened-draconium", "zpm-electric-blast-furnace-recipes", 250, ZPM_SPEED)
	step(R1, "awakened-draconium-ingot", "luv-vacuum-freezer-recipes", 14.7, LUV_SPEED,
		{ { "hot-awakened-draconium-ingot", 1 } }, { { "awakened-draconium-ingot", 1 } })
	step(R1, "hot-thulium-ingot", "mv-electric-blast-furnace-recipes", 363.6, MV_SPEED, { { "thulium-dust", 1 } },
		{ { "hot-thulium-ingot", 1 } })
	step(R1, "thulium-ingot", "mv-vacuum-freezer-recipes", 25.2, MV_SPEED, { { "hot-thulium-ingot", 1 } }, { { "thulium-ingot", 1 } })
	step(R1, "thulium-rod", "lv-lathe-recipes", 42, LV_SPEED, { { "thulium-ingot", 1 } }, { { "thulium-rod", 1 }, { thulium_small, 2 } })
	step(R1, "thulium-bolt", "lv-cutting-machine-recipes", 33.6, LV_SPEED, { { "thulium-rod", 1 }, { "water", 0.4 } },
		{ { "thulium-bolt", 4 } })
	step(R1, "thulium-screw", "lv-lathe-recipes", 1.05, LV_SPEED, { { "thulium-bolt", 1 } }, { { "thulium-screw", 1 } })
	step(R1, "thulium-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "thulium-rod", 4 } }, { { "thulium-frame", 1 } })
	--- small parts
	step(R1, "fine-manyullyn-wire", "lv-wiremill-recipes", 5, LV_SPEED, { { "manyullyn-ingot", 1 } }, { { "fine-manyullyn-wire", 4 } })
	step(R1, "tiny-naquadah-fluid-pipe", "hv-extruder-recipes", 0.2, HV_SPEED, { { "naquadah-ingot", 1 } },
		{ { "tiny-naquadah-fluid-pipe", 2 } })
	step(R1, "medium-black-plutonium-item-pipe", "hv-extruder-recipes", 1.2, HV_SPEED, { { "black-plutonium-ingot", 3 } },
		{ { "medium-black-plutonium-item-pipe", 1 } })
	step(R2, "medium-neutronium-fluid-pipe", "hv-extruder-recipes", 1.2, HV_SPEED, { { "neutronium-ingot", 3 } },
		{ { "medium-neutronium-fluid-pipe", 1 } })
	step(R1, "borosilicate-glass-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "borosilicate-glass-rod", 4 } },
		{ { "borosilicate-glass-frame", 1 } })
	step(R1, "melt-reinforced-glass", "ev-fluid-extractor-recipes", 5, EV_SPEED, { { "reinforced-glass", 1 } },
		{ { "molten-reinforced-glass", 14.4 } })
	--- the structure
	step(R1, "radiation-protection-plate", "ev-assembling-machine-recipes", 20, EV_SPEED,
		{ { "dense-iridium-plate", 8 }, { "naquadah-alloy-plate", 8 }, { "molten-lead", 115.2 } }, { { "radiation-protection-plate", 1 } })
	step(R1, "advanced-radiation-protection-plate", "zpm-assembly-line-recipes", 50, ZPM_SPEED,
		{ { "radiation-protection-plate", 2 }, { "fluxed-electrum-plate", 4 }, { "trinium-plate", 4 }, { "naquadah-alloy-plate", 4 },
			{ "osmiridium-plate", 4 }, { "vibrant-alloy-plate", 4 }, { "radiation-proof-prismatic-naquadah-composite-sheet", 4 },
			{ "molten-indalloy-140", 115.2 } }, { { "advanced-radiation-protection-plate", 1 } })
	step(R1, "naquadah-fuel-refinery-casing", "zpm-assembly-line-recipes", 25, ZPM_SPEED,
		{ { "thulium-frame", 1 }, { "advanced-radiation-protection-plate", 6 }, { "iv-field-generator", 2 },
			{ "tiny-naquadah-fluid-pipe", 16 }, { "fine-naquadah-alloy-wire", 64 }, { "fine-manyullyn-wire", 64 }, { "orundum-plate", 4 },
			{ "molten-tungstensteel", 115.2 }, { "molten-indalloy-140", 230.4 } }, { { "naquadah-fuel-refinery-casing", 1 } })
	step(R1, "field-restriction-glass", "zpm-assembling-machine-recipes", 15, ZPM_SPEED,
		{ { "borosilicate-glass-frame", 1 }, { "reinforced-glass-plate", 6 }, { "naquadah-alloy-ring", 32 }, { "hv-field-generator", 4 },
			{ "molten-naquadria", 28.8 } }, { { "field-restriction-glass", 1 } })
	step(R1, "radiation-proof-machine-casing", "iv-assembling-machine-recipes", 2, IV_SPEED,
		{ { "dense-lead-plate", 6 }, { "tungstensteel-frame", 1 }, { "liquid-concrete", 129.6 } }, { { "radiation-proof-machine-casing", 1 } })
	step(R1, "europium-reinforced-radiation-proof-machine-casing", "luv-assembling-machine-recipes", 10, LUV_SPEED,
		{ { "radiation-proof-machine-casing", 1 }, { "radiation-proof-prismatic-naquadah-composite-sheet", 4 }, { "europium-foil", 6 },
			{ "europium-screw", 24 }, { "molten-lead", 86.4 } }, { { "europium-reinforced-radiation-proof-machine-casing", 1 } })
	step(R1, "radiation-proof-steel-frame-box", "ev-assembling-machine-recipes", 16, EV_SPEED,
		{ { "long-prismatic-naquadah-rod", 8 }, { "hsse-frame", 4 } }, { { "radiation-proof-steel-frame-box", 1 } })
	step(R1, "field-restriction-coil", "zpm-assembly-line-recipes", 60, ZPM_SPEED,
		{ { "osmium-frame", 1 }, { "uv-field-generator", 2 }, { "uv-pump", 8 }, { "palladium-naqindium-superconductive-wire", 128 },
			{ "dense-americium-plate", 8 }, { "medium-black-plutonium-item-pipe", 16 }, { "ppic-wafer", 32 }, { "uhv-circuit", 1 },
			{ "krypton", 100 }, { "molten-fluxed-electrum", 921.6 }, { "lubricant", 12800 } }, { { "field-restriction-coil", 1 } })
	step(R2, "advanced-field-restriction-coil", "zpm-assembly-line-recipes", 60, ZPM_SPEED,
		{ { "cosmic-neutronium-frame", 1 }, { "uhv-field-generator", 2 }, { "uhv-pump", 8 },
			{ "naquamiridium-superconductive-wire", 256 }, { "dense-infinity-plate", 8 }, { "medium-neutronium-fluid-pipe", 16 },
			{ "qpic-wafer", 32 }, { "uev-circuit", 1 }, { "radon-plasma", 1000 }, { "molten-awakened-draconium", 921.6 },
			{ "lubricant", 12800 } }, { { "advanced-field-restriction-coil", 1 } })
	step(R1, "naquadah-fuel-refinery-controller", "zpm-assembly-line-recipes", 60, ZPM_SPEED,
		{ { "osmiridium-frame", 8 }, { "advanced-radiation-protection-plate", 64 }, { "uv-field-generator", 8 }, { "uhv-pump", 2 },
			{ "uev-circuit", 4 }, { "huge-mysterious-crystal-fluid-pipe", 8 }, { "npic-wafer", 16 },
			{ "highly-ultimate-voltage-coil", 64 }, { "yellow-garnet-lens", 16 }, { "thulium-screw", 64 }, { "molten-quantium", 921.6 },
			{ "molten-awakened-draconium", 460.8 }, { "molten-" .. EUN, 144 }, { "molten-indalloy-140", 1440 } },
		{ { "naquadah-fuel-refinery-controller", 1 } })
	--- the machines
	local function power(tier, n)
		local cf = data.raw["assembling-machine"][tier .. "-centrifuge"]
		local p = cf and cf.energy_usage or EU16_UHV
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	local ports = { port("input", N, { -1, -1 }), port("input", N, { 0, -1 }), port("input", N, { 1, -1 }),
		port("input", W, { -1, 0 }), port("output", S, { 0, 1 }) }
	machine{
		name = NFR, category = NFR .. "-recipes", speed = UHV_SPEED * 4, energy = power("uhv", 4),
		subgroup = "subgroup-uhv-age-multiblocks", ports = ports, list = R1,
		recipe = { "crafting-or-assembling-recipes", 1, { item("naquadah-fuel-refinery-controller", 1),
			item("naquadah-fuel-refinery-casing", 483), item("field-restriction-glass", 192),
			item("europium-reinforced-radiation-proof-machine-casing", 124), item("field-restriction-coil", 72),
			item("radiation-proof-steel-frame-box", 64), item("uhv-energy-hatch", 1), item("lv-machine-hull", 3) } },
	}
	machine{
		name = NFR .. "-t2", category = NFR .. "-t2-recipes", speed = UMV_SPEED * 8, energy = power("umv", 8),
		subgroup = "subgroup-uhv-age-multiblocks", ports = ports, list = R2,
		recipe = { "crafting-or-assembling-recipes", 1, { item(NFR, 1), item("advanced-field-restriction-coil", 72),
			item("umv-energy-hatch", 1) } },
	}
	data.raw["assembling-machine"][NFR .. "-t2"].crafting_categories = { NFR .. "-recipes", NFR .. "-t2-recipes" }
	--- (not recycled: the structure's sum passes Factorio's 65 535 per result; GT recycles the controller alone, which
	--- keeps its recycling)
	FORK_RECYCLING_BLACKLIST = FORK_RECYCLING_BLACKLIST or {}
	for _, n in pairs({ NFR, NFR .. "-t2" }) do
		FORK_RECYCLING_BLACKLIST[n] = "the refinery's structure: its sum passes 65535 per result; GT recycles the controller"
	end
	--- the fuels
	local mk3 = data.raw.recipe[MK3]
	fork_set_category(mk3, NFR .. "-recipes")
	mk3.energy_required = 5 * UHV_SPEED
	mk3.ingredients = { item(EUN .. "-dust", 4), item("tiberium-dust", 27), item("high-density-uranium", 2),
		item("high-density-plutonium", 1), { type = "fluid", name = "heavy-naquadah-fuel", amount = 800 },
		{ type = "fluid", name = "light-naquadah-fuel", amount = 1000 } }
	mk3.results = { { type = "fluid", name = MK3, amount = 100 } }
	mk3.subgroup = "subgroup-" .. NFR .. "-recipes"
	step(R2, "melt-praseodymium-dust", "iv-fluid-extractor-recipes", 1.2, IV_SPEED, { { "praseodymium-dust", 1 } },
		{ { "molten-praseodymium", 14.4 } })
	step(R2, MK4, NFR .. "-t2-recipes", 8, UMV_SPEED,
		{ { EUN .. "-dust", 27 }, { "nether-star-dust", 64 }, { "awakened-draconium-dust", 64 }, { "orundum-dust", 32 }, { MK3, 2000 },
			{ "molten-praseodymium", 921.6 } }, { { MK4, 250 } })

	F.tech{ name = T1, prerequisites = { "prismatic-naquadah", "quantium", "naquadah-fuels", "precise-electronic-unit-mk3",
		"bio-processor-mainframes" }, packs = 10, count = 1500,
		time = 60, recipes = R1 }
	move_unlock(MK3, T1)
	F.tech{ name = T2, prerequisites = { T1, "thorium-based-liquid-fuel", "umv-energy-hatches" }, packs = 13, count = 95, time = 60, recipes = R2 }   -- (as 138's UMV techs)
	for m, def in pairs({ [EUN] = { "luv", T1 }, ["awakened-draconium"] = { "zpm", T1 },
		["borosilicate-glass"] = { "lv", T1 }, ["reinforced-glass"] = { "ev", T1 }, ["prismatic-naquadah"] = { "zpm", T1 } }) do
		FORK_CASTING.materials[m] = def
	end
	FORK_CASTING.run()
end





--------------------------------------------------------------------------------
--- 28) NAQUADAH FUEL MK V AND MK VI, THE REFINERY'S COILS T3 AND T4 (issue #356, after section 27). GT5-Unofficial
--- 638b3f37ca, GoodGenerator's FuelRecipeLoader.java (FL), RecipeLoader.java (RL) and RecipeLoader2.java (RL2), GT++'s
--- RecipesGregTech.java (RGT); the rules of section 27 (GT's seconds x the tier speed of GT's EU/t, the fuels in GT's
--- litres, the other fluids a tenth).
--- * MK V (FL:139-149: 8 infinity dust, 32 atomic separation catalyst dust, 2000 L MK IV, 250 L heavy radox into 500 L;
---   10 s, 100 000 000 EU/t: UMV; coil T2, so the T2 refinery). Infinity dust from the ingot (GT's macerator, its mass in
---   ticks). GoodGenerator's atomic separation catalyst (RL:396-442): the raw catalyst in the mixer from 32 blaze powder,
---   4 draconium or quantium dust, 4 ardite or manyullyn dust and 2 ingots of molten naquadah into 63 (HV, 15 s; GT's
---   firestone variants are left out: the mod has no firestone source), its hot ingot in the blast furnace (2 orundum
---   plates, 4 raw catalyst, 1 ingot of molten plutonium; HV, 180 s), the vacuum freezer (LuV, 10 s), the dust (GT's
---   macerator, the Werkstoff's mass 259 in ticks, as orundum). Blaze powder from the blaze rod (GT's macerator: 3 and 1
---   more at 50 %, 20 s).
--- * MK VI (FL:167-179: 64 astral titanium dust, 32 tritanium dust, 2000 L MK V, 360 L molten shirabon into 750 L; 12 s,
---   320 000 000 EU/t: UXV; coil T3). Astral titanium dust (RGT:820-828: 8 titanium dust engraved with the quantum
---   anomaly as the lens, UHV, 120 s), shirabon (RL2:1527-1538: the plasma forge with the Hi-Computation Station Mk-V
---   kept, 1152 L molten metastable oganesson, 2304 L molten precious metals alloy, 288 L molten spacetime and 5000 L
---   residue into 144 L; 1 500 000 000 EU/t, above UXV: MAX, 10 s), GoodGenerator's precious metals alloy (the mixer:
---   ruthenium, rhodium, palladium, platinum, osmium and iridium dust into 6, UHV, 1.2 s; RL2:117 the blast furnace with
---   gas, UEV, 120 s; the vacuum freezer, UHV, 22.05 s; the melt, UHV).
--- * MK VI from celestial tungsten (FL:181-194: 64 celestial tungsten dust, 48 tritanium dust, 2000 L MK V, 360 L molten
---   shirabon, 60 L raw star matter into 1250 L; 3 s, UXV; coil T4).
--- * MK III from chromatic glass (FL:73-87: 8 extremely unstable naquadah dust, 9 chromatic glass dust, 2 high density
---   uranium, 1 high density plutonium, 800 L heavy and 1000 L light naquadah fuel into 200 L; 5 s, 2 100 000 EU/t: UEV;
---   coil T1). Chromatic glass dust (RGT:839-846: 64 glass dust engraved with the quantum anomaly, UHV, 300 s).
--- * The coils (RL:768-811): Ultimate Field Restriction Coil (an infinity frame, 2 UEV field generators, 8 UEV pumps, 64
---   8x UHV superconductor wires, 8 dense transcendent metal plates, 16 medium infinity pipes, 32 FPIC wafers, a UIV
---   circuit, 1000 L oganesson, 9216 L molten neutronium, 64 000 L superfluid) and Temporal Field Restriction Coil (a
---   spacetime frame, 2 UIV field generators, 8 UIV pumps, 2 x 64 4x UEV superconductor wires, 8 dense spacetime plates,
---   16 medium spacetime pipes, 64 PPIC wafers, a UXV circuit, 1000 L molten metastable oganesson, 9216 L molten
---   transcendent metal, 64 000 L superfluid); in the ZPM assembly line in 60 s as T1 and T2; GT's medium pipes from the
---   extruder (3 ingots, 1.2 s at the material's tier: infinity UV, spacetime UEV). The refinery with T3 and T4 coils:
---   UXV, 12 and 16 parallels, each the one before with 72 coils and a UXV energy hatch.
--- * MK V and MK VI burn in the large naquadah reactors at GT's 399 576 000 EU/t x 160 ticks and 2 077 795 200 EU/t x
---   240 ticks per litre (GGConfigLoader.java:15-17). Their depleted fuels are left out, as section 27's.
--- * GT's MK IV from hypogen and the one-step MK IV: section 35 (issue #436, the Ender Dragon's dragonblood). MK V from
---   creon and mellion: section 29 (issue #355).
--------------------------------------------------------------------------------
do
	local NFR = "naquadah-fuel-refinery"
	local T5, T6, T7 = "naquadah-based-fuel-mk5", "naquadah-based-fuel-mk6", "temporal-field-restriction-coils"
	local R5, R6, R7 = {}, {}, {}
	local MK3, MK4, MK5, MK6 = "naquadah-based-fuel-mk3", "naquadah-based-fuel-mk4", T5, T6
	local ASC, PMA = "atomic-separation-catalyst", "precious-metals-alloy"
	local EUN = "extremely-unstable-naquadah"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	F.category(NFR .. "-t3-recipes")
	F.category(NFR .. "-t4-recipes")
	F.fluid(MK5, "spackled-blue-fluid", { 0.15, 0.55, 0.90 })   -- (as 136's MK1 to MK3)
	F.fluid(MK6, "spackled-purple-fluid", { 0.70, 0.25, 0.85 })
	data.raw.fluid[MK5].fuel_value = "63932.16GJ"     -- (399 576 000 EU/t x 160 ticks, 1 EU = 1 kJ as in 136)
	data.raw.fluid[MK6].fuel_value = "498670.848GJ"   -- (2 077 795 200 EU/t x 240 ticks)
	for name, list in pairs(data.raw["mod-data"]["fork-power"].data.fuels) do
		if name:find("large%-naquadah%-reactor$") then
			for _, f in pairs({ MK5, MK6 }) do
				local found = false
				for _, x in pairs(list) do found = found or x == f end   -- (the reactors share one list)
				if not found then list[#list + 1] = f end
			end
		end
	end
	F.fluid("molten-shirabon", "molten-shirabon", { 0xe0 / 255, 0x15 / 255, 0x6d / 255 })
	F.fluid("molten-" .. PMA, "molten-" .. PMA, { 0x9d / 255, 0x90 / 255, 0xc6 / 255 })
	items(SUB_DUST, { "infinity-dust", "blaze-powder", ASC .. "-dust", "astral-titanium-dust", "chromatic-glass-dust",
		PMA .. "-dust" })
	items(SUB_PART, { "raw-" .. ASC, "hot-" .. ASC .. "-ingot", ASC .. "-ingot", "hot-" .. PMA .. "-ingot", PMA .. "-ingot",
		"medium-infinity-fluid-pipe", "medium-spacetime-fluid-pipe" })
	items("subgroup-uhv-age-multiblocks", { "ultimate-field-restriction-coil", "temporal-field-restriction-coil" })

	--- MK V: infinity dust, blaze powder, the atomic separation catalyst
	step(R5, "infinity-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "infinity-ingot", 1 } }, { { "infinity-dust", 1 } })
	step(R5, "blaze-powder", "lv-macerator-recipes", 20, LV_SPEED, { { "blaze-rod", 1 } },
		{ { "blaze-powder", 3 }, { "blaze-powder", 1, 0.5 } })
	for _, a in pairs({ "draconium", "quantium" }) do
		for _, b in pairs({ "ardite", "manyullyn" }) do
			step(R5, "raw-" .. ASC .. "-" .. a .. "-" .. b, "hv-mixer-recipes", 15, HV_SPEED,
				{ { "blaze-powder", 32 }, { a .. "-dust", 4 }, { b .. "-dust", 4 }, { "molten-naquadah", 28.8 } }, { { "raw-" .. ASC, 63 } })
		end
	end
	step(R5, "hot-" .. ASC .. "-ingot", "hv-electric-blast-furnace-recipes", 180, HV_SPEED,
		{ { "orundum-plate", 2 }, { "raw-" .. ASC, 4 }, { "molten-plutonium", 14.4 } }, { { "hot-" .. ASC .. "-ingot", 1 } })
	step(R5, ASC .. "-ingot", "luv-vacuum-freezer-recipes", 10, LUV_SPEED, { { "hot-" .. ASC .. "-ingot", 1 } }, { { ASC .. "-ingot", 1 } })
	step(R5, ASC .. "-dust", "lv-macerator-recipes", 12.95, LV_SPEED, { { ASC .. "-ingot", 1 } }, { { ASC .. "-dust", 1 } })
	step(R5, MK5, NFR .. "-t2-recipes", 10, UMV_SPEED,
		{ { "infinity-dust", 8 }, { ASC .. "-dust", 32 }, { MK4, 2000 }, { "heavy-radox", 25 } }, { { MK5, 500 } })

	--- MK VI: astral titanium, the precious metals alloy, shirabon; the T3 coil and refinery
	step(R6, "astral-titanium-dust", "uhv-laser-engraver-recipes", 120, UHV_SPEED,
		{ { "titanium-dust", 8 }, { "quantum-anomaly", 1 } }, { { "astral-titanium-dust", 1 }, { "quantum-anomaly", 1 } })
	step(R6, PMA .. "-dust", "uhv-mixer-recipes", 1.2, UHV_SPEED,
		{ { "ruthenium-dust", 1 }, { "rhodium-dust", 1 }, { "palladium-dust", 1 }, { "platinum-dust", 1 }, { "osmium-dust", 1 },
			{ "iridium-dust", 1 } }, { { PMA .. "-dust", 6 } })
	blast(R6, PMA, "uev-electric-blast-furnace-recipes", 120, UEV_SPEED)
	step(R6, PMA .. "-ingot", "uhv-vacuum-freezer-recipes", 22.05, UHV_SPEED, { { "hot-" .. PMA .. "-ingot", 1 } }, { { PMA .. "-ingot", 1 } })
	step(R6, "molten-shirabon", "dimensionally-transcendent-plasma-forge-recipes", 10, MAX_SPEED,
		{ { "hi-computation-station-mk5", 1 }, { "molten-metastable-oganesson", 115.2 }, { "molten-" .. PMA, 230.4 },
			{ "molten-spacetime", 28.8 }, { "dimensionally-transcendent-residue", 500 } },
		{ { "molten-shirabon", 14.4 }, { "hi-computation-station-mk5", 1 } })
	step(R6, "medium-infinity-fluid-pipe", "uv-extruder-recipes", 1.2, UV_SPEED, { { "infinity-ingot", 3 } },
		{ { "medium-infinity-fluid-pipe", 1 } })
	step(R6, "ultimate-field-restriction-coil", "zpm-assembly-line-recipes", 60, ZPM_SPEED,
		{ { "infinity-frame", 1 }, { "uev-field-generator", 2 }, { "uev-pump", 8 }, { "triamerotronium-superconductive-wire", 512 },
			{ "dense-transcendent-metal-plate", 8 }, { "medium-infinity-fluid-pipe", 16 }, { "fpic-wafer", 32 }, { "uiv-circuit", 1 },
			{ "oganesson", 100 }, { "molten-neutronium", 921.6 }, { "dimensionally-shifted-superfluid", 6400 } },
		{ { "ultimate-field-restriction-coil", 1 } })
	step(R6, MK6, NFR .. "-t3-recipes", 12, UXV_SPEED,
		{ { "astral-titanium-dust", 64 }, { "tritanium-dust", 32 }, { MK5, 2000 }, { "molten-shirabon", 36 } }, { { MK6, 750 } })
	--- MK III from chromatic glass (the anomaly comes with the godforge, which MK VI needs as well)
	step(R6, "chromatic-glass-dust", "uhv-laser-engraver-recipes", 300, UHV_SPEED,
		{ { "glass-dust", 64 }, { "quantum-anomaly", 1 } }, { { "chromatic-glass-dust", 1 }, { "quantum-anomaly", 1 } })
	step(R6, MK3 .. "-chromatic-glass", NFR .. "-recipes", 5, UEV_SPEED,
		{ { EUN .. "-dust", 8 }, { "chromatic-glass-dust", 9 }, { "high-density-uranium", 2 }, { "high-density-plutonium", 1 },
			{ "heavy-naquadah-fuel", 800 }, { "light-naquadah-fuel", 1000 } }, { { MK3, 200 } })

	--- MK VI from celestial tungsten: the T4 coil and refinery
	step(R7, "medium-spacetime-fluid-pipe", "uev-extruder-recipes", 1.2, UEV_SPEED, { { "spacetime-ingot", 3 } },
		{ { "medium-spacetime-fluid-pipe", 1 } })
	step(R7, "temporal-field-restriction-coil", "zpm-assembly-line-recipes", 60, ZPM_SPEED,
		{ { "spacetime-frame", 1 }, { "uiv-field-generator", 2 }, { "uiv-pump", 8 }, { "dracofinium-superconductive-wire", 512 },
			{ "dense-spacetime-plate", 8 }, { "medium-spacetime-fluid-pipe", 16 }, { "ppic-wafer", 64 }, { "uxv-circuit", 1 },
			{ "molten-metastable-oganesson", 100 }, { "molten-transcendent-metal", 921.6 }, { "dimensionally-shifted-superfluid", 6400 } },
		{ { "temporal-field-restriction-coil", 1 } })
	step(R7, MK6 .. "-celestial-tungsten", NFR .. "-t4-recipes", 3, UXV_SPEED,
		{ { "celestial-tungsten-dust", 64 }, { "tritanium-dust", 48 }, { MK5, 2000 }, { "molten-shirabon", 36 },
			{ "raw-star-matter", 6 } }, { { MK6, 1250 } })

	--- the machines (section 27's)
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	local ports = { port("input", N, { -1, -1 }), port("input", N, { 0, -1 }), port("input", N, { 1, -1 }),
		port("input", W, { -1, 0 }), port("output", S, { 0, 1 }) }
	machine{
		name = NFR .. "-t3", category = NFR .. "-t3-recipes", speed = UXV_SPEED * 12, energy = power("uxv", 12),
		subgroup = "subgroup-uhv-age-multiblocks", ports = ports, list = R6,
		recipe = { "crafting-or-assembling-recipes", 1, { item(NFR .. "-t2", 1), item("ultimate-field-restriction-coil", 72),
			item("uxv-energy-hatch", 1) } },
	}
	machine{
		name = NFR .. "-t4", category = NFR .. "-t4-recipes", speed = UXV_SPEED * 16, energy = power("uxv", 16),
		subgroup = "subgroup-uhv-age-multiblocks", ports = ports, list = R7,
		recipe = { "crafting-or-assembling-recipes", 1, { item(NFR .. "-t3", 1), item("temporal-field-restriction-coil", 72),
			item("uxv-energy-hatch", 1) } },
	}
	data.raw["assembling-machine"][NFR .. "-t3"].crafting_categories = { NFR .. "-recipes", NFR .. "-t2-recipes",
		NFR .. "-t3-recipes" }
	data.raw["assembling-machine"][NFR .. "-t4"].crafting_categories = { NFR .. "-recipes", NFR .. "-t2-recipes",
		NFR .. "-t3-recipes", NFR .. "-t4-recipes" }
	for _, n in pairs({ NFR .. "-t3", NFR .. "-t4" }) do
		FORK_RECYCLING_BLACKLIST[n] = "the refinery's structure: its sum passes 65535 per result; GT recycles the controller"
	end

	F.tech{ name = T5, prerequisites = { "naquadah-based-fuel-mk4", "radox-polymer" }, packs = 13, count = 95, time = 60,
		recipes = R5 }   -- (as section 27's MK IV)
	F.tech{ name = T6, prerequisites = { T5, "dimensionally-shifted-superfluid", "uxv-energy-hatches" }, packs = 14,
		count = 50, time = 60, recipes = R6 }   -- (as 138's UXV techs)
	F.tech{ name = T7, prerequisites = { T6, "godforge-plasma-module" }, packs = 14, count = 50, time = 60, recipes = R7 }
	FORK_CASTING.materials[PMA] = { "uhv", T6 }
	FORK_CASTING.run()
end





--------------------------------------------------------------------------------
--- 29) CREON AND MELLION (issue #355, step 2; the maintainer's decisions of 2026-10-18: fiery tears from hunting, creon
--- plasma in the plasma forge, naquadah fuel MK V's alternative as the first consumer). GT5-Unofficial 638b3f37ca and
--- NewHorizonsCoreMod c729b6f; fluids a tenth of GT's litres as the plasma forge's other mixer recipes (139, section 20).
--- * Fiery steel: GT's only dust recipe is the chemical bath of iron dust with 250 L fiery blood
---   (ProcessingTransforming.java:51-65, ULV, 5 s); the canner empties a Twilight Forest Fiery Tears vial into 250 L
---   (FluidCannerRecipes.java:70-76; GT's empty bottle is left out: the mod has none); NewHorizonsCoreMod assembles the
---   vial from a ghast tear and the Ur-Ghast trophy, which it keeps (ScriptTwilightForest.java:320-325, HV, 75 s). The
---   ghast tears and the trophy are hunted, as 160's blazes: a Nether hunt (4 tears) and the Twilight Forest's Ur-Ghast
---   (its trophy). GT's other vial (fiery blood: Thaumcraft's salis mundis and the Hydra trophy) is left out.
--- * Fermium plasma: GT++'s fusion, 100 L americium plasma + 100 L boron plasma -> 100 L (RecipeLoaderChemicalSkips.java:
---   417-423, UHV, 30 s, 1G EU to start: the MK4 as 164's other 1G recipes; plasmas in GT litres as 136's).
--- * Creon plasma: the Transcendent Plasma Mixer (TranscendentPlasmaMixerRecipes.java:141-152: 1000 L each of fermium,
---   thorium, celestial tungsten and calcium plasma and the residue -> 5000 L, UMV, 5 s) runs in the plasma forge, as the
---   catalysts of 139 and 164 (the mixer itself needs GT parts the mod lacks).
--- * Mellion dust (MixerRecipes.java:1756-1769: 11 tritanium, 8 orundum, 11 rubidium, 7 fiery steel, 13 firestone and 13
---   atomic separation catalyst dust, 5000 L residue -> 63; UMV, 15 s); the harmonic compound (BlastFurnaceRecipes.java:
---   662-670: 1 mellion dust, 144 L creon plasma -> 2; UMV, 30 s, 14 000 K); the vacuum freezer (VacuumFreezerRecipes.java:
---   363-370: 2 harmonic compound, 144 L molten catalyst -> a mellion ingot and 144 L molten creon; UIV, 1 s); molten
---   mellion from the ingot (GT's fluid extractor, 143's casting at UEV, mellion's processing tier); molten catalyst from
---   its ingot (bartworks, IV).
--- * The first consumer (#252): naquadah fuel MK V's alternative (FuelRecipeLoader.java:151-165: 16 transcendent metal
---   dust, 48 catalyst dust, 2000 L MK IV, 250 L heavy radox, 288 L molten mellion and creon -> 750 L; 2.5 s, 300M EU/t:
---   UXV; coil T3), transcendent metal dust from the ingot (GT's macerator, its mass in ticks). GT's firestone variants
---   of the raw catalyst (RecipeLoader.java:396-417: 4 firestone dust for 32 blaze powder) now that firestone has a source
---   (#435).
--- * The godforge's parts keep leaving creon and mellion out (140): their celestial tungsten plasma comes from the
---   godforge itself.
--------------------------------------------------------------------------------
do
	local T = "creon-and-mellion"
	local R = {}
	local NFR = "naquadah-fuel-refinery"
	local ASC = "atomic-separation-catalyst"
	local MK4, MK5 = "naquadah-based-fuel-mk4", "naquadah-based-fuel-mk5"
	F.fluid("fiery-blood", "fiery-blood", { 0.65, 0.12, 0.05 })   -- (GT's fluid.fieryblood)
	F.fluid("fermium-plasma", "spackled-copper-fluid", { 0.90, 0.45, 0.85 })
	F.fluid("creon-plasma", "spackled-purple-fluid", { 0x46 / 255, 0, 0x46 / 255 })
	F.fluid("molten-creon", "molten-creon", { 0.60, 0, 0.60 })   -- (GT's colour, lifted as its icon)
	F.fluid("molten-mellion", "molten-mellion", { 0.58, 0.05, 0.05 })
	F.fluid("molten-" .. ASC, "molten-" .. ASC, { 0xe8 / 255, 0x5e / 255, 0x0c / 255 })
	items("subgroup-mining", { "ghast-tear", "ur-ghast-trophy" })
	items(SUB_DUST, { "fiery-steel-dust", "transcendent-metal-dust", "mellion-dust" })
	items(SUB_PART, { "fiery-tears", "harmonic-compound", "mellion-ingot" })

	--- the hunts (160's; issue #526: Dig Site recipes, as the other hunts since #499)
	for _, h in pairs({ { "hunting-ghasts", "ghast-tear", 4 }, { "hunting-the-ur-ghast", "ur-ghast-trophy", 1 } }) do
		create_recipe{
			name = h[1], category = "manual-digsite-recipes", energy_required = 10, subgroup = "subgroup-mining",
			ingredients = { { type = "item", name = "manual-labor", amount = 24 } },
			results = { { type = "item", name = h[2], amount = h[3] } }, main_product = h[2],
		}
		R[#R + 1] = h[1]
		FORK_ELECTRIC_MINE_EXCLUDED[h[1]] = "a mob drop (" .. h[2] .. "), no ore: the Ore Drilling Plant mines ore blocks only"
		FORK_ELECTRIC_MINE.moved_placeholder(h[1])   -- issue #527: a Dimension Mine of a save made before #526
	end
	--- fiery steel
	step(R, "fiery-tears", "hv-assembling-machine-recipes", 75, HV_SPEED, { { "ghast-tear", 1 }, { "ur-ghast-trophy", 1 } },
		{ { "fiery-tears", 1 }, { "ur-ghast-trophy", 1 } })
	step(R, "fiery-blood", "lv-canning-machine-recipes", 0.2, LV_SPEED, { { "fiery-tears", 1 } }, { { "fiery-blood", 25 } })
	step(R, "fiery-steel-dust", "lv-chemical-bath-recipes", 5, LV_SPEED, { { "iron-dust", 1 }, { "fiery-blood", 25 } },
		{ { "fiery-steel-dust", 1 } })
	--- the atomic separation catalyst's firestone variants (section 28's recipes with 4 firestone dust)
	for _, a in pairs({ "draconium", "quantium" }) do
		for _, b in pairs({ "ardite", "manyullyn" }) do
			step(R, "raw-" .. ASC .. "-firestone-" .. a .. "-" .. b, "hv-mixer-recipes", 15, HV_SPEED,
				{ { "firestone-dust", 4 }, { a .. "-dust", 4 }, { b .. "-dust", 4 }, { "molten-naquadah", 28.8 } }, { { "raw-" .. ASC, 63 } })
		end
	end
	--- creon plasma and mellion
	step(R, "fermium-plasma", "mk4-fusion-reactor-recipes", 30, UHV_SPEED,
		{ { "americium-plasma", 100 }, { "boron-plasma", 100 } }, { { "fermium-plasma", 100 } })
	step(R, "creon-plasma", "dimensionally-transcendent-plasma-forge-recipes", 5, UMV_SPEED,
		{ { "fermium-plasma", 100 }, { "thorium-plasma", 100 }, { "celestial-tungsten-plasma", 100 }, { "calcium-plasma", 100 },
			{ "dimensionally-transcendent-residue", 100 } }, { { "creon-plasma", 500 } })
	step(R, "mellion-dust", "umv-mixer-recipes", 15, UMV_SPEED,
		{ { "tritanium-dust", 11 }, { "orundum-dust", 8 }, { "rubidium-dust", 11 }, { "fiery-steel-dust", 7 }, { "firestone-dust", 13 },
			{ ASC .. "-dust", 13 }, { "dimensionally-transcendent-residue", 500 } }, { { "mellion-dust", 63 } })
	step(R, "harmonic-compound", "umv-electric-blast-furnace-recipes", 30, UMV_SPEED,
		{ { "mellion-dust", 1 }, { "creon-plasma", 14.4 } }, { { "harmonic-compound", 2 } })
	step(R, "mellion-ingot", "uiv-vacuum-freezer-recipes", 1, UIV_SPEED,
		{ { "harmonic-compound", 2 }, { "molten-" .. ASC, 14.4 } }, { { "mellion-ingot", 1 }, { "molten-creon", 14.4 } })
	--- the first consumer: MK V from creon and mellion
	step(R, "transcendent-metal-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "transcendent-metal-ingot", 1 } },
		{ { "transcendent-metal-dust", 1 } })
	step(R, MK5 .. "-creon-mellion", NFR .. "-t3-recipes", 2.5, UXV_SPEED,
		{ { "transcendent-metal-dust", 16 }, { ASC .. "-dust", 48 }, { MK4, 2000 }, { "heavy-radox", 25 }, { "molten-mellion", 28.8 },
			{ "molten-creon", 28.8 } }, { { MK5, 750 } })

	F.tech{ name = T, prerequisites = { "naquadah-based-fuel-mk6", "godforge-plasma-module", "space-elevator-mining-module-mk1" },
		packs = 14, count = 50, time = 60, recipes = R }   -- (as 138's UXV techs)
	FORK_CASTING.materials["mellion"] = { "uev", T }
	FORK_CASTING.materials[ASC] = { "iv", T }
	FORK_CASTING.run()
end





--------------------------------------------------------------------------------
--- 30) THE BEAMLINE: MU-METAL, THE SOURCE CHAMBER, THE BEAM CRAFTER, UU MATTER (issue #355, step 4 part 1; the
--- maintainer's decisions of 2026-10-18). GT5-Unofficial 1c385e739b: gtnhlanth (gtnhlanth/loader/RecipeLoader.java (RL),
--- gtnhlanth/common/tileentity/recipe/beamline/BeamlineRecipeLoader.java (BRL)), GT's Beam Crafter
--- (gregtech/loaders/postload/recipes/beamcrafter/BeamCrafterRecipes.java (BCR), tectech/loader/recipe/AssemblyLine.java
--- (TAL)), NewHorizonsCoreMod; fluids a tenth of GT's litres, GT's seconds x the tier speed of GT's EU/t.
--- * Particles are fluids, one unit per particle (the maintainer's decision): GT's beam moves `rate` particles once a
---   second, so a Source Chamber recipe of 1 s gives `rate` units. Energy and focus of a beam are not modelled; the
---   recipes keep GT's times and the particle fluids limit them.
--- * Mu-metal (gtnhlanth's Werkstoff, WerkstoffMaterialPool.java:1804-1840): permalloy from 4 nickel, 1 iron and 1
---   molybdenum dust (bartworks' mixer: its mass 64 / 3 components in ticks, LV), mu-metal in the blast furnace (9
---   permalloy, 1 copper, 1 chrome dust -> 11 ingots, EV, 20 s, 4500 K; RL:231-242), its parts by bartworks' rules at
---   its processing tier EV and mass 180 (plate, dense plate of 9 ingots, fine wire: 8 per ingot).
--- * The parts (RL:158-535): Shielded Accelerator Casing, Electrode Casing (bartworks' Rebolted Silver Casing,
---   CasingLoader.java), Capillary Exchange (with the core mod's Mica Insulator Sheet: mica based pulp in the mixer, the
---   sheet in the forming press, the insulator sheet in the alloy smelter; MixerRecipes.java:550-553,
---   FormingPressRecipes.java:44-48, AlloySmelterRecipes.java:31-36; GT's tiny tungstensteel pipe from the extruder),
---   Mu-Metal Lattice, Shielded Accelerator Glass, Beam Pipe, the LuV Beam Input and Output Hatches (their 8 1x LuV
---   superconductor wires: GT's 16x bundle split into 16 on the crafting table).
--- * The Source Chamber (BRL:67-159): a tungsten rod gives 20 electrons, a long lanthanum hexaboride rod 60, 1000 L
---   hydrogen 40 protons, each in 1 s (IV, IV, ZPM). Controller RL:158-172; structure MTESourceChamber.java:145-154 (56
---   shielded accelerator casings, 52 glass, 16 electrode casings, a beam output hatch, the energy hatch and hulls for
---   the maintenance, input and output hatches and buses).
--- * The Target Chamber is only the Beam Crafter controller's ingredient (RL:191-206); GT's Synchrotron and LINAC are
---   not built. GT's Large Molecular Assembler (AssemblerRecipes.java:3214-3227) is an ingredient too.
--- * The Beam Crafter (TAL:173-186: the Target Chamber, 4 ZPM field generators, 32 shielded accelerator casings, 2 Large
---   Molecular Assemblers, 8000 L UU matter; UV, 60 s; structure MTEBeamCrafter.java:309-328: 224 casings, 26 glass, 16
---   grate casings, 2 beam input hatches). It runs at UV speed (one UV energy hatch); its first recipe is GT's unknown
---   particle (BCR:47-62: 2000 L hydrogen, 120 protons, 720 electrons -> 20.85 %, LuV, 1 s), which the quantum anomaly
---   takes.
--- * UU matter: GT's Elite Mass Fabricator (LuV; NHC GT_Loader_Machines.java:121-125) makes 1 L per 3200 ticks at 256
---   EU/t (MTEMassfabricator.java:63-65, HV), 10 L (1 unit) per 1600 s here. GT's UU amplifier is left out: the mod has
---   no IC2 scrap. The UMV hatches keep leaving their UU matter out (ROADMAP).
--------------------------------------------------------------------------------
do
	local T = "beamline"
	local R = {}
	local MU = "mu-metal"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	F.fluid("uu-matter", "spackled-purple-fluid", { 0.55, 0.15, 0.55 })   -- (IC2's texture is not in the checkouts)
	F.fluid("electron", "electron", { 0.35, 0.65, 1.00 })   -- (gtnhlanth's particle icons)
	F.fluid("proton", "proton", { 1.00, 0.35, 0.30 })
	items(SUB_DUST, { "permalloy-dust", "mica-based-pulp" })
	items(SUB_PART, { MU .. "-ingot", MU .. "-plate", "dense-" .. MU .. "-plate", "fine-" .. MU .. "-wire",
		"tiny-tungstensteel-fluid-pipe", "mica-based-sheet", "mica-insulator-sheet", "mu-metal-lattice", "capillary-exchange",
		"luv-superconductor-wire" })
	items("subgroup-uhv-age-multiblocks", { "rebolted-silver-casing", "shielded-accelerator-casing", "electrode-casing",
		"shielded-accelerator-glass", "beam-pipe", "beam-input-hatch", "beam-output-hatch", "source-chamber-controller",
		"target-chamber-controller", "large-molecular-assembler", "beam-crafter-controller" })

	--- mu-metal
	step(R, "permalloy-dust", "lv-mixer-recipes", 1.05, LV_SPEED, { { "nickel-dust", 4 }, { "iron-dust", 1 }, { "molybdenum-dust", 1 } },
		{ { "permalloy-dust", 6 } })
	step(R, MU .. "-ingot", "ev-electric-blast-furnace-recipes", 20, EV_SPEED,
		{ { "permalloy-dust", 9 }, { "copper-dust", 1 }, { "chromium-dust", 1 } }, { { MU .. "-ingot", 11 } })
	step(R, MU .. "-plate", "ev-bending-machine-recipes", 9, EV_SPEED, { { MU .. "-ingot", 1 } }, { { MU .. "-plate", 1 } })
	step(R, "dense-" .. MU .. "-plate", "ev-bending-machine-recipes", 81, EV_SPEED, { { MU .. "-ingot", 9 } },
		{ { "dense-" .. MU .. "-plate", 1 } })
	step(R, "fine-" .. MU .. "-wire", "ev-wiremill-recipes", 9, EV_SPEED, { { MU .. "-ingot", 1 } }, { { "fine-" .. MU .. "-wire", 8 } })
	--- small parts
	step(R, "tiny-tungstensteel-fluid-pipe", "hv-extruder-recipes", 0.2, HV_SPEED, { { "tungstensteel-ingot", 1 } },
		{ { "tiny-tungstensteel-fluid-pipe", 2 } })
	step(R, "mica-based-pulp", "lv-mixer-recipes", 20, LV_SPEED, { { "mica-dust", 3 }, { "sticky-resin", 1 } }, { { "mica-based-pulp", 4 } })
	step(R, "mica-based-sheet", "lv-forming-press-recipes", 20, LV_SPEED, { { "mica-based-pulp", 4 }, { "asbestos-dust", 1 } },
		{ { "mica-based-sheet", 4 } })
	step(R, "mica-insulator-sheet", "lv-alloy-smelter-recipes", 20, LV_SPEED, { { "mica-based-sheet", 4 }, { "silicon-dioxide", 1 } },
		{ { "mica-insulator-sheet", 4 } })
	step(R, "luv-superconductor-wire", "crafting-or-assembling-recipes", 0.5, 1, { { "luv-superconductor-wire-16x", 1 } },
		{ { "luv-superconductor-wire", 16 } })
	--- the casings and parts
	step(R, "rebolted-silver-casing", "lv-assembling-machine-recipes", 10, LV_SPEED,
		{ { "double-silver-plate", 6 }, { "silver-screw", 2 }, { "silver-gear", 1 } }, { { "rebolted-silver-casing", 1 } })
	step(R, "shielded-accelerator-casing", "iv-assembling-machine-recipes", 40, IV_SPEED,
		{ { "radiation-proof-machine-casing", 1 }, { "dense-" .. MU .. "-plate", 6 }, { "soldering-alloy", 14.4 } },
		{ { "shielded-accelerator-casing", 1 } })
	step(R, "electrode-casing", "iv-assembling-machine-recipes", 40, IV_SPEED,
		{ { "rebolted-silver-casing", 1 }, { "silver-wire", 24 }, { "dense-gold-plate", 6 }, { "soldering-alloy", 28.8 } },
		{ { "electrode-casing", 1 } })
	step(R, "capillary-exchange", "iv-assembling-machine-recipes", 20, IV_SPEED,
		{ { "tiny-tungstensteel-fluid-pipe", 8 }, { "double-copper-plate", 2 }, { "titanium-plate", 6 }, { "mica-insulator-sheet", 4 },
			{ "luv-pump", 1 }, { "silver-dust", 2 }, { "silicone-rubber", 28.8 } }, { { "capillary-exchange", 1 } })
	step(R, "mu-metal-lattice", "ev-assembling-machine-recipes", 15, EV_SPEED,
		{ { "fine-" .. MU .. "-wire", 12 }, { "tungstensteel-rod", 4 }, { "soldering-alloy", 14.4 } }, { { "mu-metal-lattice", 1 } })
	step(R, "shielded-accelerator-glass", "iv-fluid-solidifier-recipes", 25, IV_SPEED,
		{ { "mu-metal-lattice", 4 }, { "molten-borosilicate-glass", 14.4 } }, { { "shielded-accelerator-glass", 1 } })
	step(R, "beam-pipe", "luv-assembling-machine-recipes", 20, LUV_SPEED,
		{ { MU .. "-plate", 4 }, { "long-tungsten-carbide-rod", 4 }, { "tungsten-carbide-rod", 8 }, { "osmiridium-foil", 4 },
			{ "soldering-alloy", 14.4 } }, { { "beam-pipe", 1 } })
	step(R, "beam-input-hatch", "luv-assembly-line-recipes", 120, LUV_SPEED,
		{ { "luv-machine-hull", 1 }, { "luv-circuit", 2 }, { "capillary-exchange", 2 }, { "luv-pump", 1 }, { "beam-pipe", 1 },
			{ MU .. "-plate", 4 }, { "soldering-alloy", 921.6 }, { "argon", 100 }, { "helium", 200 } }, { { "beam-input-hatch", 1 } })
	step(R, "beam-output-hatch", "luv-assembly-line-recipes", 240, LUV_SPEED,
		{ { "luv-machine-hull", 1 }, { "luv-circuit", 6 }, { "capillary-exchange", 4 }, { "luv-pump", 2 }, { "luv-motor", 4 },
			{ "luv-superconductor-wire", 8 }, { "beam-pipe", 1 }, { MU .. "-plate", 8 }, { "soldering-alloy", 921.6 }, { "argon", 100 },
			{ "helium", 600 } }, { { "beam-output-hatch", 1 } })
	--- the controllers
	step(R, "source-chamber-controller", "zpm-assembling-machine-recipes", 30, ZPM_SPEED,
		{ { "luv-machine-hull", 1 }, { "dense-" .. MU .. "-plate", 8 }, { "zpm-circuit", 4 }, { "luv-conveyor-module", 4 },
			{ "beam-pipe", 2 }, { "vanadium-gallium-cable", 8 }, { "soldering-alloy", 28.8 } }, { { "source-chamber-controller", 1 } })
	step(R, "target-chamber-controller", "zpm-assembling-machine-recipes", 30, ZPM_SPEED,
		{ { "luv-machine-hull", 1 }, { "dense-" .. MU .. "-plate", 8 }, { "dense-lead-plate", 4 }, { "zpm-circuit", 4 },
			{ "uv-circuit", 2 }, { "beam-pipe", 2 }, { "vanadium-gallium-cable", 2 }, { "soldering-alloy", 28.8 } },
		{ { "target-chamber-controller", 1 } })
	step(R, "large-molecular-assembler", "iv-assembling-machine-recipes", 60, IV_SPEED,
		{ { "me-interface", 8 }, { "me-molecular-assembler", 8 }, { "iv-emitter", 4 }, { "robust-tungstensteel-machine-casing", 1 },
			{ "polyethylene", 129.6 } }, { { "large-molecular-assembler", 1 } })
	step(R, "beam-crafter-controller", "zpm-assembly-line-recipes", 60, UV_SPEED,
		{ { "target-chamber-controller", 1 }, { "zpm-field-generator", 4 }, { "shielded-accelerator-casing", 32 },
			{ "large-molecular-assembler", 2 }, { "uu-matter", 800 } }, { { "beam-crafter-controller", 1 } })

	--- the machines
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	machine{
		name = "luv-mass-fabricator", category = "mass-fabricator-recipes", speed = LUV_SPEED, energy = power("luv", 1),
		subgroup = "subgroup-luv-age-multiblocks", ports = { port("output", S, { 0, 1 }) }, list = R,
		recipe = { "crafting-or-assembling-recipes", 1, { item("luv-machine-hull", 1), item("luv-field-generator", 2),
			item("luv-circuit", 4), item("vanadium-gallium-cable", 8) } },
	}
	machine{
		name = "source-chamber", category = "source-chamber-recipes", speed = ZPM_SPEED, energy = power("zpm", 1),
		subgroup = "subgroup-uhv-age-multiblocks", ports = { port("input", N, { 0, -1 }), port("output", S, { 0, 1 }) }, list = R,
		recipe = { "crafting-or-assembling-recipes", 1, { item("source-chamber-controller", 1),
			item("shielded-accelerator-casing", 56), item("shielded-accelerator-glass", 52), item("electrode-casing", 16),
			item("beam-output-hatch", 1), item("zpm-energy-hatch", 1), item("lv-machine-hull", 4) } },
	}
	machine{
		name = "beam-crafter", category = "beam-crafter-recipes", speed = UV_SPEED, energy = power("uv", 1),
		subgroup = "subgroup-uhv-age-multiblocks",
		ports = { port("input", N, { -1, -1 }), port("input", N, { 0, -1 }), port("input", N, { 1, -1 }), port("input", W, { -1, 0 }),
			port("output", S, { 0, 1 }) },
		list = R,
		recipe = { "crafting-or-assembling-recipes", 1, { item("beam-crafter-controller", 1), item("shielded-accelerator-casing", 224),
			item("borosilicate-glass-block", 26), item("grate-machine-casing", 16), item("beam-input-hatch", 2), item("uv-energy-hatch", 1),
			item("lv-machine-hull", 3) } },
	}

	--- UU matter, the particles, the unknown particle
	step(R, "uu-matter", "mass-fabricator-recipes", 1600, HV_SPEED, {}, { { "uu-matter", 1 } })
	step(R, "electron-from-tungsten-rod", "source-chamber-recipes", 1, IV_SPEED, { { "tungsten-rod", 1 } }, { { "electron", 20 } })
	step(R, "electron-from-lanthanum-hexaboride-rod", "source-chamber-recipes", 1, IV_SPEED,
		{ { "long-lanthanum-hexaboride-rod", 1 } }, { { "electron", 60 } })
	step(R, "proton", "source-chamber-recipes", 1, ZPM_SPEED, { { "hydrogen", 100 } }, { { "proton", 40 } })
	step(R, "unknown-particle-beam-crafter", "beam-crafter-recipes", 1, LUV_SPEED,
		{ { "hydrogen", 200 }, { "proton", 120 }, { "electron", 720 } }, { { "unknown-particle", 1, 0.2085 } })

	F.tech{ name = T, prerequisites = { "naquadah-fuel-refinery", "me-autocrafting" }, packs = 10, count = 1500, time = 60,
		recipes = R }   -- (as section 27's refinery: the radiation proof casing comes there)
end





--------------------------------------------------------------------------------
--- 31) THE LARGE HADRON COLLIDER AND ITS PARTICLES (issue #355, step 4 part 2; the maintainer's decisions of
--- 2026-10-18). GT5-Unofficial 1c385e739b: the LHC (gregtech/common/tileentities/machines/multi/beamcrafting/
--- MTELargeHadronCollider.java, LHCModule.java), its casings (gregtech/loaders/postload/recipes/beamcrafter/
--- BeamCrafterRecipes.java (BCR)), its controller (tectech/loader/recipe/ResearchStationAssemblyLine.java (RSAL));
--- NewHorizonsCoreMod (NHC) for the solenoids, the collider casing, neonite and the electromagnet; GoodGenerator for the
--- compact fusion coils (RecipeLoader2.java:1261-1285) and the quartz crystal resonator (RecipeLoader.java:845-1036).
--- * One machine, upgraded module by module (as the refinery's coils): the LHC with the EM module (taus and omegas from
---   protons), + the Weak module (upsilons), + the LHCb module (gravitons). GT's main ring accelerates the beam
---   (1048.6 x (cycles + 1)^2 keV per second) and each module's 2 output hatches roll a particle per second, weighted by
---   GT's LHC weights among the particles below the collision energy. The recipes are GT's operating points as
---   expected amounts: EM on 1 GeV protons (no acceleration): 40 protons a second, 2.8 taus and 1.68 omegas (3.5 % and
---   2.1 %), UIV; Weak on electrons accelerated to 4.73 GeV and more (24 cycles): 40 particles a second, 1.13 % upsilons,
---   2.83 % taus, 1.70 % omegas, 6.55G EU/t: MAX; LHCb on the Source Chamber's 1 MeV electrons: 20 electrons, 40
---   gravitons a second (100 %), UIV. The other particles are voided (GT's hatch filters). GT's Strong module is not
---   needed. The LHC has one UIV energy hatch (GT: exactly one energy hatch).
--- * The structure is scaled as the plasma forge's and the godforge's (GT's counts / 44, rounded up): the main ring 129
---   collider casings (GT 5664), 2 neonite, 1 glass, 1 shielded accelerator casing, the beam input hatch; each module 12
---   collider casings, 4 of its own casings (GT 144-160), 3 glass, 1 neonite and GT's 2 advanced beam output hatches.
--- * GT's UV, UHV and UIV Solenoid Superconductor Coils (BlockCyclotronCoils.java, the IV one is 20's; NHC
---   AssemblingLineRecipes.java:1523-1590) with GT's large fluid cells (AssemblerRecipes.java:154-192), medium pipes and the long
---   metastable oganesson rod; the CMS, ATLAS and LHCb casings in the Beam Crafter (BCR:98-160: 6000 electrons, 1800
---   taus, 750 upsilons + 750 omegas); niobium (GT's blast furnace at 2750 K, MV), the Niobium Cavity Casing (gtnhlanth
---   RecipeLoader.java:351-360) and the Collider Casing (NHC AssemblerRecipes.java:9800-9808); neonite (NHC 7012-7015);
---   the Advanced Beam Output Hatch (RSAL:2209-2220); the Samarium Electromagnet (NHC AssemblingLineRecipes.java:
---   1103-1117); GT++'s Advanced Nitinol (RecipesGregTech.java:830-836: two nitinol-60 blocks engraved with the quantum
---   anomaly; its melt 1296 L per block, RecipeGenRecycling.java:162-190) for the ATLAS casings; GT++'s Quantum is
---   transcendent metal (as 140) for the LHCb casings.
--- * The controller (RSAL:2192-2207): 64 Compact Fusion Coils, 32 Advanced Compact Fusion Coils (the precise assembler;
---   the quartz crystal resonator with GT's quartz wafer, special ceramics and micro heater), 64 UHV circuits, 64 UV
---   field generators, the electromagnet, 8 CMS casings and the neutronium melts.
--- * Left out, named: the collider casing's Naquarite Universal Insulator Foil (netherite and Thaumcraft's infused gold,
---   as 26), the controller's 8 Research Stations (the mod has no TecTech computation) and 8 UV Neutron Accelerators
---   (their inverter's plastic case takes cyan dye, which the mod has none of).
--------------------------------------------------------------------------------
do
	local T = "large-hadron-collider"
	local R = {}
	local LHC = "large-hadron-collider"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	for _, p in pairs({ { "tau", { 0.85, 0.75, 0.30 } }, { "omega", { 0.55, 0.85, 0.40 } }, { "upsilon", { 0.75, 0.40, 0.90 } },
		{ "graviton", { 0.30, 0.30, 0.45 } } }) do
		F.fluid(p[1], p[1], p[2])   -- (gtnhlanth's particle icons)
	end
	F.fluid("molten-advanced-nitinol", "molten-advanced-nitinol", { 0.39, 0.39, 0.86 })
	items(SUB_DUST, { "aluminium-nitride-dust", "special-ceramics-dust" })
	items(SUB_PART, { "medium-naquadah-fluid-pipe", "medium-awakened-draconium-fluid-pipe", "long-metastable-oganesson-rod",
		"magnetic-samarium-ring", "empty-large-chrome-fluid-cell", "empty-large-iridium-fluid-cell", "empty-large-neutronium-fluid-cell",
		"hot-niobium-ingot", "niobium-ingot", "niobium-plate", "niobium-rod", "niobium-frame", "block-of-advanced-nitinol",
		"block-of-quartzite", "quartzite-plate", "quartz-wafer", "special-ceramics-plate", "ultra-low-voltage-coil",
		"manganese-ingot", "manganese-foil", "tantalum-capacitor", "micro-heater", "quartz-crystal-resonator" })
	items("subgroup-uhv-age-multiblocks", { "uv-solenoid-superconductor-coil", "uhv-solenoid-superconductor-coil",
		"uiv-solenoid-superconductor-coil", "cms-casing", "atlas-casing", "lhcb-casing", "niobium-cavity-casing",
		"collider-casing", "neonite", "advanced-beam-output-hatch", "samarium-electromagnet", "compact-fusion-coil",
		"advanced-compact-fusion-coil", "large-hadron-collider-controller" })
	local niobium_small, niobium_small_r = pile("niobium-dust", "small")
	FORK_CASTING.recipes[niobium_small_r] = true
	R[#R + 1] = niobium_small_r

	--- the solenoids and their parts
	step(R, "medium-naquadah-fluid-pipe", "hv-extruder-recipes", 1.2, HV_SPEED, { { "naquadah-ingot", 3 } },
		{ { "medium-naquadah-fluid-pipe", 1 } })
	step(R, "medium-awakened-draconium-fluid-pipe", "hv-extruder-recipes", 1.2, HV_SPEED, { { "awakened-draconium-ingot", 3 } },
		{ { "medium-awakened-draconium-fluid-pipe", 1 } })
	step(R, "empty-large-chrome-fluid-cell", "ev-assembling-machine-recipes", 10, EV_SPEED,
		{ { "double-rhodium-plated-palladium-plate", 4 }, { "palladium-ring", 4 } }, { { "empty-large-chrome-fluid-cell", 1 } })
	step(R, "empty-large-iridium-fluid-cell", "ev-assembling-machine-recipes", 10, EV_SPEED,
		{ { "double-iridium-plate", 4 }, { "naquadah-ring", 4 } }, { { "empty-large-iridium-fluid-cell", 1 } })
	step(R, "empty-large-neutronium-fluid-cell", "iv-assembling-machine-recipes", 10, IV_SPEED,
		{ { "double-neutronium-plate", 4 }, { "draconium-ring", 4 } }, { { "empty-large-neutronium-fluid-cell", 1 } })
	step(R, "long-metastable-oganesson-rod", "uev-fluid-solidifier-recipes", 15, UEV_SPEED, { { "molten-metastable-oganesson", 14.4 } },
		{ { "long-metastable-oganesson-rod", 1 } })
	step(R, "magnetic-samarium-ring", "iv-polarizer-recipes", 1.6, IV_SPEED, { { "samarium-ring", 1 } }, { { "magnetic-samarium-ring", 1 } })
	step(R, "uv-solenoid-superconductor-coil", "zpm-assembly-line-recipes", 20, UV_SPEED,
		{ { "naquamiridium-superconductive-wire", 32 }, { "fluxed-electrum-cable", 8 }, { "medium-naquadah-fluid-pipe", 1 },
			{ "long-naquadria-rod", 8 }, { "double-neutronium-plate", 2 }, { "empty-large-chrome-fluid-cell", 1 }, { "uv-pump", 1 },
			{ "super-coolant", 1600 }, { "molten-indalloy-140", 230.4 } }, { { "uv-solenoid-superconductor-coil", 1 } })
	step(R, "uhv-solenoid-superconductor-coil", "zpm-assembly-line-recipes", 20, UHV_SPEED,
		{ { "triamerotronium-superconductive-wire", 32 }, { "bedrockium-cable", 8 }, { "medium-neutronium-fluid-pipe", 1 },
			{ "long-naquadria-rod", 8 }, { "double-cosmic-neutronium-plate", 2 }, { "empty-large-iridium-fluid-cell", 1 }, { "uhv-pump", 1 },
			{ "super-coolant", 6400 }, { "molten-indalloy-140", 921.6 } }, { { "uhv-solenoid-superconductor-coil", 1 } })
	step(R, "uiv-solenoid-superconductor-coil", "zpm-assembly-line-recipes", 20, UIV_SPEED,
		{ { "chromnorox-superconductive-wire", 32 }, { "nether-star-cable", 8 }, { "medium-awakened-draconium-fluid-pipe", 1 },
			{ "long-metastable-oganesson-rod", 8 }, { "double-transcendent-metal-plate", 2 }, { "empty-large-neutronium-fluid-cell", 1 },
			{ "uiv-pump", 1 }, { "super-coolant", 102400 }, { "molten-indalloy-140", 460.8 } }, { { "uiv-solenoid-superconductor-coil", 1 } })
	--- advanced nitinol (the ATLAS casings' melt)
	step(R, "block-of-advanced-nitinol", "uv-laser-engraver-recipes", 60, UV_SPEED, { { "block-of-nitinol-60", 2 }, { "quantum-anomaly", 1 } },
		{ { "block-of-advanced-nitinol", 1 }, { "quantum-anomaly", 1 } })
	step(R, "melt-block-of-advanced-nitinol", "uv-fluid-extractor-recipes", 10.8, UV_SPEED, { { "block-of-advanced-nitinol", 1 } },
		{ { "molten-advanced-nitinol", 129.6 } })
	--- the module casings (Beam Crafter)
	step(R, "cms-casing", "beam-crafter-recipes", 1, UV_SPEED,
		{ { "uv-solenoid-superconductor-coil", 4 }, { "zpm-field-generator", 4 }, { "americium-plasma", 921.6 }, { "electron", 6000 } },
		{ { "cms-casing", 4 } })
	step(R, "atlas-casing", "beam-crafter-recipes", 1, UHV_SPEED,
		{ { "uhv-solenoid-superconductor-coil", 4 }, { "uv-field-generator", 4 }, { "molten-advanced-nitinol", 921.6 }, { "tau", 1800 } },
		{ { "atlas-casing", 4 } })
	step(R, "lhcb-casing", "beam-crafter-recipes", 1, UIV_SPEED,
		{ { "uiv-solenoid-superconductor-coil", 4 }, { "uev-field-generator", 4 }, { "molten-transcendent-metal", 921.6 },
			{ "upsilon", 750 }, { "omega", 750 } }, { { "lhcb-casing", 4 } })
	--- niobium, the collider casing, neonite, the hatch, the electromagnet
	step(R, "hot-niobium-ingot", "mv-electric-blast-furnace-recipes", 275, MV_SPEED, { { "niobium-dust", 1 } }, { { "hot-niobium-ingot", 1 } })
	step(R, "niobium-ingot", "mv-vacuum-freezer-recipes", 14.1, MV_SPEED, { { "hot-niobium-ingot", 1 } }, { { "niobium-ingot", 1 } })
	step(R, "niobium-plate", "lv-bending-machine-recipes", 4.7, LV_SPEED, { { "niobium-ingot", 1 } }, { { "niobium-plate", 1 } })
	step(R, "niobium-rod", "lv-lathe-recipes", 23.5, LV_SPEED, { { "niobium-ingot", 1 } }, { { "niobium-rod", 1 }, { niobium_small, 2 } })
	step(R, "niobium-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "niobium-rod", 4 } }, { { "niobium-frame", 1 } })
	step(R, "niobium-cavity-casing", "iv-assembling-machine-recipes", 12, IV_SPEED,
		{ { "niobium-frame", 1 }, { "niobium-plate", 6 }, { "helium", 200 } }, { { "niobium-cavity-casing", 1 } })
	step(R, "collider-casing", "zpm-assembling-machine-recipes", 30, ZPM_SPEED,
		{ { "shielded-accelerator-casing", 32 }, { "niobium-cavity-casing", 32 }, { "niobium-titanium-cable", 256 }, { "uv-sensor", 1 },
			{ "molten-pikyonium-64b", 921.6 } }, { { "collider-casing", 32 } })
	step(R, "neonite", "lv-assembling-machine-recipes", 5, LV_SPEED, { { "emerald", 8 }, { "glowstone-dust", 1 } }, { { "neonite", 8 } })
	step(R, "advanced-beam-output-hatch", "zpm-assembly-line-recipes", 60, UV_SPEED,
		{ { "beam-output-hatch", 1 }, { "uv-sensor", 4 }, { "uv-emitter", 4 }, { "activated-carbon-mesh-filter", 32 }, { "uu-matter", 100 } },
		{ { "advanced-beam-output-hatch", 1 } })
	step(R, "samarium-electromagnet", "zpm-assembly-line-recipes", 60, UV_SPEED,
		{ { "double-neutronium-plate", 32 }, { "magnetic-samarium-ring", 32 }, { "ultimate-voltage-coil", 32 },
			{ "naquamiridium-superconductive-wire", 256 }, { "uv-field-generator", 2 }, { "super-coolant", 3200 }, { "molten-cobalt", 691.2 },
			{ "molten-fluxed-electrum", 230.4 } }, { { "samarium-electromagnet", 1 } })
	--- the compact fusion coils and the quartz crystal resonator
	step(R, "block-of-quartzite", "lv-compressor-recipes", 15, LV_SPEED, { { "quartzite-gem", 9 } }, { { "block-of-quartzite", 1 } })
	step(R, "quartzite-plate", "lv-cutting-machine-recipes", 49, LV_SPEED, { { "block-of-quartzite", 1 }, { "lubricant", 2.2 } },
		{ { "quartzite-plate", 9 } })
	step(R, "quartz-wafer", "lv-autoclave-recipes", 75, LV_SPEED, { { "quartzite-plate", 1 }, { "sodium", 4 }, { "distilled-water", 100 } },
		{ { "quartz-wafer", 1 } })
	step(R, "aluminium-nitride-dust", "ev-electric-blast-furnace-recipes", 10, EV_SPEED,
		{ { "sapphire-dust", 5 }, { "coal-dust", 3 }, { "liquid-nitrogen", 200 } }, { { "aluminium-nitride-dust", 2 }, { "carbon-monoxide", 300 } })
	step(R, "special-ceramics-dust", "ev-mixer-recipes", 5, EV_SPEED,
		{ { "aluminium-nitride-dust", 4 }, { "yttrium-oxide", 5 }, { "advanced-glue", 100 } }, { { "special-ceramics-dust", 9 } })
	step(R, "special-ceramics-plate", "hv-extruder-recipes", 20, HV_SPEED, { { "special-ceramics-dust", 2 } }, { { "special-ceramics-plate", 1 } })
	step(R, "ultra-low-voltage-coil", "lv-assembling-machine-recipes", 10, LV_SPEED, { { "magnetic-iron-rod", 1 }, { "fine-lead-wire", 16 } },
		{ { "ultra-low-voltage-coil", 1 } })
	step(R, "manganese-dust-smelter", "smelting", 10, LV_SPEED, { { "manganese-dust", 1 } }, { { "manganese-ingot", 1 } })
	step(R, "manganese-foil", "lv-bending-machine-recipes", 5.5, LV_SPEED, { { "manganese-ingot", 1 } }, { { "manganese-foil", 4 } })
	step(R, "tantalum-capacitor", "lv-assembling-machine-recipes", 5, LV_SPEED,
		{ { "tantalum-dust", 1 }, { "manganese-foil", 1 }, { "polyethylene", 14.4 } }, { { "tantalum-capacitor", 8 } })
	step(R, "micro-heater", "precise-assembler-mk1-recipes", 2, MV_SPEED,
		{ { "resin-circuit-board", 1 }, { "ultra-low-powered-integrated-circuit", 1 }, { "ultra-low-voltage-coil", 2 },
			{ "tantalum-capacitor", 1 }, { "molten-red-alloy", 14.4 }, { "molten-aluminium", 14.4 } }, { { "micro-heater", 1 } })
	step(R, "quartz-crystal-resonator", "precise-assembler-mk1-recipes", 2, MV_SPEED,
		{ { "quartz-wafer", 1 }, { "special-ceramics-plate", 2 }, { "micro-heater", 1 }, { "ilc-chip", 4 }, { "molten-energetic-alloy", 7.2 },
			{ "molten-silver", 1.8 } }, { { "quartz-crystal-resonator", 1 } })
	step(R, "compact-fusion-coil", "precise-assembler-mk2-recipes", 40, LUV_SPEED,
		{ { "fusion-coil-block", 3 }, { "quartz-crystal-resonator", 2 }, { "hi-computation-station-mk3", 1 }, { "molten-artherium-sn", 57.6 },
			{ "molten-tanmolyium-beta-c", 14.4 } }, { { "compact-fusion-coil", 1 } })
	step(R, "advanced-compact-fusion-coil", "precise-assembler-mk3-recipes", 40, ZPM_SPEED,
		{ { "fusion-coil-block", 3 }, { "radiation-protection-plate", 2 }, { "quantum-star", 4 }, { "hi-computation-station-mk4", 1 },
			{ "molten-dalisenite", 57.6 }, { "molten-hikarium", 14.4 } }, { { "advanced-compact-fusion-coil", 1 } })
	--- the controller
	step(R, "large-hadron-collider-controller", "zpm-assembly-line-recipes", 300, UHV_SPEED,
		{ { "compact-fusion-coil", 64 }, { "advanced-compact-fusion-coil", 32 }, { "uhv-circuit", 64 }, { "uv-field-generator", 64 },
			{ "samarium-electromagnet", 1 }, { "cms-casing", 8 }, { "molten-neutronium", 66355.2 }, { "molten-cosmic-neutronium", 66355.2 } },
		{ { "large-hadron-collider-controller", 1 } })

	--- the machine and its modules
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	local ports = { port("input", N, { 0, -1 }), port("output", S, { -1, 1 }), port("output", S, { 0, 1 }), port("output", S, { 1, 1 }) }
	local function module(casing)
		return { item("collider-casing", 12), item(casing, 4), item("shielded-accelerator-glass", 3), item("neonite", 1),
			item("advanced-beam-output-hatch", 2) }
	end
	local base = { item("large-hadron-collider-controller", 1), item("collider-casing", 129), item("neonite", 2),
		item("shielded-accelerator-glass", 1), item("shielded-accelerator-casing", 1), item("beam-input-hatch", 1),
		item("uiv-energy-hatch", 1), item("lv-machine-hull", 1) }
	for _, i in pairs(module("cms-casing")) do   -- (the EM module joins the main ring's casings)
		local found = false
		for _, j in pairs(base) do
			if j.name == i.name then j.amount, found = j.amount + i.amount, true end
		end
		if not found then base[#base + 1] = i end
	end
	local stages = {
		{ LHC, "lhc-em-recipes", base },
		{ LHC .. "-weak", "lhc-weak-recipes", F.join({ item(LHC, 1) }, module("atlas-casing")) },
		{ LHC .. "-lhcb", "lhc-lhcb-recipes", F.join({ item(LHC .. "-weak", 1) }, module("lhcb-casing")) },
	}
	local cats = {}
	for _, s in pairs(stages) do
		machine{
			name = s[1], category = s[2], speed = UIV_SPEED, energy = power("uiv", 1), subgroup = "subgroup-uhv-age-multiblocks",
			ports = ports, list = R, recipe = { "crafting-or-assembling-recipes", 1, s[3] },
		}
		cats[#cats + 1] = s[2]
		data.raw["assembling-machine"][s[1]].crafting_categories = table.deepcopy(cats)
		FORK_RECYCLING_BLACKLIST[s[1]] = "the LHC's structure: GT recycles the controller"
	end
	--- the particles: GT's operating points (see above), expected amounts
	step(R, "lhc-em-tau-and-omega", "lhc-em-recipes", 10, UIV_SPEED, { { "proton", 400 } }, { { "tau", 28 }, { "omega", 16.8 } })
	step(R, "lhc-weak-upsilon", "lhc-weak-recipes", 100, MAX_SPEED, { { "electron", 2000 } },
		{ { "upsilon", 45.2 }, { "tau", 113.2 }, { "omega", 68 } })
	step(R, "lhc-lhcb-graviton", "lhc-lhcb-recipes", 1, UIV_SPEED, { { "electron", 20 } }, { { "graviton", 40 } })

	F.tech{ name = T, prerequisites = { "beamline", "godforge", "naquadah-based-fuel-mk4", "dimensionally-shifted-superfluid",
		"nuclear-salt-processing-ii" }, packs = 13, count = 95, time = 60, recipes = R }   -- (as 138's UMV techs; the tree check's prerequisites)
end





--------------------------------------------------------------------------------
--- 32) THE GRAVITATIONAL LENS (issue #355, step 3 with step 4's gravitons; the maintainer's decisions of 2026-10-18).
--- GT5-Unofficial 1c385e739b and NewHorizonsCoreMod (NHC).
--- * The Stable Boson Containment Unit (BeamCrafterRecipes.java:342-356: the empty unit, 100 L krypton, 20 + 20
---   gravitons; UHV, 2 s) and its empty unit (NHC AssemblerRecipes.java:9845-9850: a niobium cavity casing, 4 dense lead
---   plates, 10 L ethyl cyanoacrylate (super glue) -> 64; LuV, 30 s).
--- * The Spatially Transcendent Gravitational Lens Block (godforge glass; the research station assembly line,
---   ResearchStationAssemblyLine.java:2503-2524, UIV, 10 s): 8 Quantum Glass, 8 transcendent metal reinforced
---   borosilicate glass, 4 Stable Boson Containment Units, 6 each of the radox polymer, chromatic, mysterious crystal and
---   magneto resonatic lenses, 36 dense chromatic glass plates, 6 long creon and mellion rods, 2304 L molten rhugnor and
---   creon, 147 456 L molten Advanced Nitinol (31's). Its parts with GT's recipes: Quantum Glass, the Molecular Casing and
---   the High Power Casing (tectech Assembler.java:48-129; fine cobalt wire from a cast cobalt ingot), the TM-reinforced
---   glass (bartworks FluidSolidifier.java:85-91), the Radox Polymer Lens (NHC LatheRecipes.java:22-24), the Mysterious
---   Crystal Lens (NHC ChemicalBathRecipes.java:120-122, with UU matter; its gem grades NHC LaserEngraverRecipes.java:
---   43-83), GT++'s dense chromatic glass plate (RecipeGenPlates.java:155-163), the long creon and mellion rods (143's
---   casts, UEV). The BEC route (BECRecipes.java:200-217) needs the same parts and is not built.
--- * The Gravitational Lens (NHC CompressorRecipes.java:179-182: the glass and 5760 L molten Space, UMV, 2 min) runs in
---   the UMV compressor: GT's Pseudostable Black Hole Containment Field is not built (MULTIBLOCK-AUDIT, the
---   maintainer's decision); the UMV, UXV and MAX compressors get a fluid input for it. Molten Space is the mod's spatially enlarged fluid (the godforge's exotic module, the
---   plasma forge's MAX recipes).
--- * The first consumer: GT's second APIC recipe (NHC LaserEngraverRecipes.java:297-303: an APIC wafer engraved with the
---   gravitational lens and 15 L superfluid -> 2 chips; UIV, 5 s), next to the mod's own APIC recipe (129).
--- * Left out, named: the glass's 8 Force Field Glass (GT++: netherite and molten celestial tungsten rods). Its 6 long
---   Six-Phased Copper rods come with section 35 (#436).
--------------------------------------------------------------------------------
do
	local T = "gravitational-lens"
	local R = {}
	items(SUB_PART, { "stable-empty-containment-unit", "stable-boson-containment-unit", "cobalt-ingot", "fine-cobalt-wire",
		"mysterious-crystal-plate", "mysterious-crystal-gem", "flawless-mysterious-crystal", "exquisite-mysterious-crystal",
		"radox-polymer-lens", "mysterious-crystal-lens", "dense-chromatic-glass-plate", "long-creon-rod", "long-mellion-rod",
		"gravitational-lens" })
	items("subgroup-uhv-age-multiblocks", { "high-power-casing", "molecular-casing", "quantum-glass",
		"transcendent-metal-reinforced-borosilicate-glass-block", "spatially-transcendent-gravitational-lens-block" })

	--- the boson containment units
	step(R, "stable-empty-containment-unit", "luv-assembling-machine-recipes", 30, LUV_SPEED,
		{ { "niobium-cavity-casing", 1 }, { "dense-lead-plate", 4 }, { "super-glue", 1 } }, { { "stable-empty-containment-unit", 64 } })
	step(R, "stable-boson-containment-unit", "beam-crafter-recipes", 2, UHV_SPEED,
		{ { "stable-empty-containment-unit", 1 }, { "krypton", 10 }, { "graviton", 40 } }, { { "stable-boson-containment-unit", 1 } })
	--- quantum glass
	step(R, "fine-cobalt-wire", "lv-wiremill-recipes", 5, LV_SPEED, { { "cobalt-ingot", 1 } }, { { "fine-cobalt-wire", 4 } })
	step(R, "high-power-casing", "luv-assembling-machine-recipes", 5, LUV_SPEED,
		{ { "iridium-frame", 1 }, { "double-iridium-plate", 6 }, { "luv-circuit", 1 }, { "fine-cobalt-wire", 16 }, { "fine-copper-wire", 16 },
			{ "niobium-titanium-wire", 4 }, { "molten-tungstensteel", 57.6 } }, { { "high-power-casing", 1 } })
	step(R, "molecular-casing", "uv-assembling-machine-recipes", 40, UV_SPEED,
		{ { "high-power-casing", 1 }, { "dense-osmiridium-plate", 6 }, { "trinium-foil", 12 }, { "tungstensteel-screw", 24 },
			{ "tungstensteel-ring", 24 }, { "iv-field-generator", 1 }, { "molten-osmium", 129.6 } }, { { "molecular-casing", 1 } })
	step(R, "quantum-glass", "uv-assembling-machine-recipes", 10, UV_SPEED,
		{ { "molecular-casing", 1 }, { "reinforced-glass", 1 }, { "molten-trinium", 57.6 } }, { { "quantum-glass", 1 } })
	step(R, "transcendent-metal-reinforced-borosilicate-glass-block", "uev-fluid-solidifier-recipes", 40, UEV_SPEED,
		{ { "borosilicate-glass-block", 1 }, { "molten-transcendent-metal", 115.2 } },
		{ { "transcendent-metal-reinforced-borosilicate-glass-block", 1 } })
	--- the lenses and plates
	step(R, "radox-polymer-lens", "uev-lathe-recipes", 90, UEV_SPEED, { { "radox-polymer-plate", 1 } }, { { "radox-polymer-lens", 1 } })
	step(R, "mysterious-crystal-plate", "lv-bending-machine-recipes", 4.9, LV_SPEED, { { "mysterious-crystal-ingot", 1 } },
		{ { "mysterious-crystal-plate", 1 } })
	step(R, "mysterious-crystal-gem", "hv-laser-engraver-recipes", 60, HV_SPEED, { { "mysterious-crystal-plate", 9 }, { "ender-pearl-lens", 1 } },
		{ { "mysterious-crystal-gem", 1 }, { "ender-pearl-lens", 1 } })
	step(R, "flawless-mysterious-crystal", "zpm-laser-engraver-recipes", 30, ZPM_SPEED,
		{ { "mysterious-crystal-gem", 3 }, { "ender-pearl-lens", 1 } }, { { "flawless-mysterious-crystal", 1 }, { "ender-pearl-lens", 1 } })
	step(R, "exquisite-mysterious-crystal", "luv-laser-engraver-recipes", 30, LUV_SPEED,
		{ { "flawless-mysterious-crystal", 3 }, { "ender-pearl-lens", 1 } }, { { "exquisite-mysterious-crystal", 1 }, { "ender-pearl-lens", 1 } })
	step(R, "mysterious-crystal-lens", "uv-chemical-bath-recipes", 30, UV_SPEED,
		{ { "exquisite-mysterious-crystal", 1 }, { "uu-matter", 14.4 } }, { { "mysterious-crystal-lens", 1 } })
	step(R, "dense-chromatic-glass-plate", "uhv-bending-machine-recipes", 9.1, UHV_SPEED, { { "chromatic-glass-plate", 9 } },
		{ { "dense-chromatic-glass-plate", 1 } })
	--- the glass and the lens
	step(R, "spatially-transcendent-gravitational-lens-block", "zpm-assembly-line-recipes", 10, UIV_SPEED,
		{ { "quantum-glass", 8 }, { "transcendent-metal-reinforced-borosilicate-glass-block", 8 }, { "stable-boson-containment-unit", 4 },
			{ "radox-polymer-lens", 6 }, { "chromatic-lens", 6 }, { "mysterious-crystal-lens", 6 }, { "magneto-resonatic-lens", 6 },
			{ "dense-chromatic-glass-plate", 36 }, { "long-creon-rod", 6 }, { "long-mellion-rod", 6 }, { "molten-rhugnor", 230.4 },
			{ "molten-creon", 230.4 }, { "molten-advanced-nitinol", 14745.6 } }, { { "spatially-transcendent-gravitational-lens-block", 1 } })
	step(R, "gravitational-lens", "umv-compressor-recipes", 120, UMV_SPEED,
		{ { "spatially-transcendent-gravitational-lens-block", 1 }, { "spatially-enlarged-fluid", 576 } }, { { "gravitational-lens", 1 } })
	--- the UMV compressor (and the UXV and MAX ones, which run its recipes) gets a fluid input on the north side for the
	--- lens's Space, as GT's compressors of the higher compression tiers take fluids (shown only with a fluid recipe)
	for _, t in pairs({ "umv", "uxv", "max" }) do
		local m = data.raw["assembling-machine"][t .. "-compressor"]
		m.fluid_boxes = m.fluid_boxes or {}
		table.insert(m.fluid_boxes, port("input", N, { 0, -1 }))
	end
	--- the first consumer: GT's APIC chip with the lens
	step(R, "atto-power-ic-gravitational-lens", "uiv-laser-engraver-recipes", 5, UIV_SPEED,
		{ { "apic-wafer", 1 }, { "gravitational-lens", 1 }, { "dimensionally-shifted-superfluid", 1.5 } },
		{ { "atto-power-ic", 2 }, { "gravitational-lens", 1 } }, "atto-power-ic")

	F.tech{ name = T, prerequisites = { "large-hadron-collider", "creon-and-mellion", "godforge-exotic-module" }, packs = 15,
		count = 55, time = 60, recipes = R }   -- (as 138's godforge modules: MAX science for the Space)
	FORK_CASTING.materials["cobalt"] = { "iv", T }
	FORK_CASTING.materials["creon"] = { "uev", T }
	FORK_CASTING.run()
end





--------------------------------------------------------------------------------
--- 33) THE ZEPTO POWER IC (issue #355, step 4 part 3; the maintainer's decisions of 2026-10-18). NewHorizonsCoreMod
--- (NHC) and GT5-Unofficial 1c385e739b.
--- * The ZPIC wafer in the Beam Crafter (NHC BeamcraftingRecipes.java:27-36: an APIC wafer, spacetime dust, 576 L each
---   of molten creon and mellion, 20 + 20 gravitons; UIV, 2 s); spacetime dust from the ingot (GT's macerator, its mass
---   in ticks). The chip in the laser engraver with the gravitational lens (NHC LaserEngraverRecipes.java:305-310: the
---   wafer and 20 L superfluid -> 2; UMV, 5 s).
--- * GTNH's UMV energy and dynamo hatches with ZPIC (tectech ResearchStationAssemblyLine.java:256-276, 375-395: the UMV
---   hull, 2 4x UMV superconductor wires (dynamo: 8 springs), 2 ZPIC, 2 UMV circuits, 2 UMV coils, 6 space coolant
---   cells, the UMV pump, 32 000 L super coolant, 40 ingots of mutated living solder; UMV, 50 s; its UU matter is left
---   out as in the hatches of 133) as additional recipes. The hatches keep their APIC recipe (133, 136): the ZPIC needs
---   creon and mellion, whose chain runs after the UMV hatches (naquadah fuel MK IV to VI, the UMV blast furnace), so
---   GTNH's recipe alone would be a cycle.
--------------------------------------------------------------------------------
do
	local T = "zepto-power-ics"
	local R = {}
	items(SUB_DUST, { "spacetime-dust" })
	items(SUB_PART, { "zpic-wafer", "zepto-power-ic" })
	step(R, "spacetime-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "spacetime-ingot", 1 } }, { { "spacetime-dust", 1 } })
	step(R, "zpic-wafer", "beam-crafter-recipes", 2, UIV_SPEED,
		{ { "apic-wafer", 1 }, { "spacetime-dust", 1 }, { "molten-creon", 57.6 }, { "molten-mellion", 57.6 }, { "graviton", 40 } },
		{ { "zpic-wafer", 1 } })
	step(R, "zepto-power-ic", "umv-laser-engraver-recipes", 5, UMV_SPEED,
		{ { "zpic-wafer", 1 }, { "gravitational-lens", 1 }, { "dimensionally-shifted-superfluid", 2 } },
		{ { "zepto-power-ic", 2 }, { "gravitational-lens", 1 } }, "zepto-power-ic")
	for _, h in pairs({ { "umv-energy-hatch", { "hypocosmium-superconductive-wire", 8 } }, { "umv-dynamo-hatch", { "hypocosmium-spring", 8 } } }) do
		step(R, h[1] .. "-zpic", "zpm-assembly-line-recipes", 50, UMV_SPEED,
			{ { "umv-machine-hull", 1 }, h[2], { "zepto-power-ic", 2 }, { "umv-circuit", 2 }, { "mega-ultimate-voltage-coil", 2 },
				{ "1080k-super-coolant-cell", 6 }, { "umv-pump", 1 }, { "super-coolant", 3200 }, { "molten-indalloy-140", 576 } },
			{ { h[1], 1 } })
	end
	F.tech{ name = T, prerequisites = { "gravitational-lens", "umv-energy-hatches", "umv-plasma-turbine" }, packs = 15, count = 55,
		time = 60, recipes = R }   -- (as section 32)
end



--------------------------------------------------------------------------------
--- 34) CHARCOAL FROM THE COKE OVEN (issue #448). GT's coke oven turns a log into a charcoal and 250 L creosote in 90 s
---   (CokeOvenRecipes.java:73-78; coal into coke and 500 L in 90 s, :15-20). Gregtorio's coke recipe (09) takes half
---   GT's time, so the log does too; a tenth of the litres. With Coke Oven, which unlocks the coke recipe.
--------------------------------------------------------------------------------
do
	local R = {}
	step(R, "charcoal-coke-oven", "coke-oven-recipes", 45, 1, { { "wood", 1 } }, { { "charcoal", 1 }, { "creosote", 25 } },
		"charcoal")
	for _, r in pairs(R) do fork_add_unlock("coke-oven", r) end
end


--------------------------------------------------------------------------------
--- 35) DRAGONBLOOD, HYPOGEN AND SIX-PHASED COPPER (issue #436, the maintainer's decision of 2026-10-20: a dragonblood
---   source through the Extreme Entity Crusher).
--- * Dragonblood (GT++'s DRAGON_METAL, "Dragonblood") drops from the Ender Dragon: 25 to 50 stacks of 1 to 10 nuggets
---   (gtPlusPlus EnderDragonDeathHandler.java:51-58), 206 on average. The crusher fights it as the mod's Wither (17): its
---   summoning, 4 End Crystals (Minecraft: 7 glass, an eye of ender and a ghast tear each; the mod's ghast tear comes with
---   Creon and Mellion, much later, and is left out), 120 s. The nugget melts into 1.6 (a tenth of GT's 16 L).
--- * Hypogen (gtPlusPlus RecipesGregTech.java:303-312): 144 L molten dragonblood and 288 L molten rhugnor -> 36 L in the
---   fusion reactor, UHV, 409.6 s, 1.2G EU to start: the MK4 reactor here (fermium's).
--- * GoodGenerator's MK IV from hypogen (FuelRecipeLoader.java:106-119: 27 extremely unstable naquadah, 64 bedrockium,
---   64 awakened draconium, 64 orundum dust, 2000 L MK III, 240 L hypogen -> 500 L; 8 s, coil T2) and the one-step MK IV
---   (:121-137: 54 extremely unstable naquadah, 32 orundum, 10 high density uranium, 5 high density plutonium, 4000 L
---   heavy and 5000 L light naquadah fuel, 120 L hypogen, 45 ingots of molten chromatic glass -> 250 L; 2 ticks, coil
---   T4), the naquadah fuels in GT's litres as in sections 27 and 28, the melts a tenth.
--- * Six-Phased Copper (GT's PlasmaForgeRecipes.java:143-157: 8 Avaritia copper singularities, 72 ingots of molten
---   celestial tungsten, 288 of astral titanium, 36 of hypogen, 576 of chromatic glass, 18 of rhugnor, 72 of mellion -> 72
---   ingots; UMV, 60 s, 12 600 K) in the plasma forge; the mod has no singularity (as the void cells of #354: left out). The
---   melts of celestial tungsten and astral titanium from their dust (GT++'s fluid extractor, UIV), the long rods cast
---   (143). The first consumer: the 6 long Six-Phased Copper rods of the Spatially Transcendent Gravitational Lens Block
---   (section 32 left them out), so Gravitational Lens follows Six-Phased Copper.
--- Technologies: Hypogen (the dragon, the melt, the fusion, MK IV from hypogen) after the refinery's T2 coils, Fusion Coil II
---   (rhugnor), the MK4 fusion reactor, Reach the End and the crusher; the one-step MK IV with Temporal Field Restriction
---   Coils (T4), which follows Hypogen; Six-Phased Copper after Hypogen, MK VI (astral titanium), the plasma module
---   (celestial tungsten), Creon and Mellion and the Godforge (chromatic glass).
--------------------------------------------------------------------------------
do
	local NFR = "naquadah-fuel-refinery"
	local MK3, MK4 = "naquadah-based-fuel-mk3", "naquadah-based-fuel-mk4"
	local EUN = "extremely-unstable-naquadah"
	local T_HYP, T_SPC = "hypogen", "six-phased-copper"
	local RH, RS, R1 = {}, {}, {}
	items(SUB_PART, { "dragonblood-nugget", "long-six-phased-copper-rod" })
	FORK_RECYCLING_BLACKLIST["dragonblood-nugget"] = "the Ender Dragon's drop: GT recycles it into its material, which the mod has as a melt only"
	F.fluid("molten-dragonblood", "molten-dragonblood", { 220 / 255, 40 / 255, 20 / 255 })
	F.fluid("molten-hypogen", "molten-hypogen", { 181 / 255, 102 / 255, 61 / 255 })
	F.fluid("molten-celestial-tungsten", "molten-celestial-tungsten", { 133 / 255, 133 / 255, 133 / 255 })
	F.fluid("molten-astral-titanium", "molten-astral-titanium", { 220 / 255, 160 / 255, 240 / 255 })
	F.fluid("molten-six-phased-copper", "molten-six-phased-copper", { 1, 120 / 255, 20 / 255 })
	--- dragonblood and hypogen
	step(RH, "crushing-the-ender-dragon", "ev-extreme-entity-crusher-recipes", 120, 1,
		{ { "glass", 28 }, { "eye-of-ender", 4 } }, { { "dragonblood-nugget", 206 } })
	--- no recycler recipe either (Task-Ingame #477): Space Age's recycler would reverse the fight into glass and eyes, and
	--- would make its own self-recycling recipe without the item's flag
	data.raw.recipe["crushing-the-ender-dragon"].auto_recycle = false
	data.raw.item["dragonblood-nugget"].auto_recycle = false
	step(RH, "melt-dragonblood-nugget", "uhv-fluid-extractor-recipes", 0.2, UHV_SPEED, { { "dragonblood-nugget", 1 } },
		{ { "molten-dragonblood", 1.6 } })
	step(RH, "molten-hypogen", "mk4-fusion-reactor-recipes", 409.6, UHV_SPEED,
		{ { "molten-dragonblood", 14.4 }, { "molten-rhugnor", 28.8 } }, { { "molten-hypogen", 3.6 } })
	step(RH, MK4 .. "-hypogen", NFR .. "-t2-recipes", 8, UMV_SPEED,
		{ { EUN .. "-dust", 27 }, { "bedrockium-dust", 64 }, { "awakened-draconium-dust", 64 }, { "orundum-dust", 64 }, { MK3, 2000 },
			{ "molten-hypogen", 24 } }, { { MK4, 500 } })
	step(R1, MK4 .. "-one-step", NFR .. "-t4-recipes", 0.1, UXV_SPEED,
		{ { EUN .. "-dust", 54 }, { "orundum-dust", 32 }, { "high-density-uranium", 10 }, { "high-density-plutonium", 5 },
			{ "heavy-naquadah-fuel", 4000 }, { "light-naquadah-fuel", 5000 }, { "molten-hypogen", 12 }, { "molten-chromatic-glass", 648 } },
		{ { MK4, 250 } })
	F.tech{ name = T_HYP, prerequisites = { "naquadah-based-fuel-mk4", "fusion-coil-ii", "fusion-reactor-mk4", "reach-the-end",
		"extreme-entity-crushers" }, packs = 13, count = 95, time = 60, recipes = RH }   -- (as the MK IV technology)
	for _, r in pairs(R1) do fork_add_unlock("temporal-field-restriction-coils", r) end
	table.insert(data.raw.technology["temporal-field-restriction-coils"].prerequisites, T_HYP)
	--- six-phased copper
	step(RS, "melt-celestial-tungsten-dust", "uiv-fluid-extractor-recipes", 1.2, UIV_SPEED, { { "celestial-tungsten-dust", 1 } },
		{ { "molten-celestial-tungsten", 14.4 } })
	step(RS, "melt-astral-titanium-dust", "uiv-fluid-extractor-recipes", 1.2, UIV_SPEED, { { "astral-titanium-dust", 1 } },
		{ { "molten-astral-titanium", 14.4 } })
	step(RS, "molten-six-phased-copper", "dimensionally-transcendent-plasma-forge-recipes", 60, UMV_SPEED,
		{ { "molten-celestial-tungsten", 1036.8 }, { "molten-astral-titanium", 4147.2 }, { "molten-hypogen", 518.4 },
			{ "molten-chromatic-glass", 8294.4 }, { "molten-rhugnor", 259.2 }, { "molten-mellion", 1036.8 } },
		{ { "molten-six-phased-copper", 1036.8 } })
	F.tech{ name = T_SPC, prerequisites = { T_HYP, "naquadah-based-fuel-mk6", "godforge-plasma-module", "creon-and-mellion",
		"godforge" }, packs = 14, count = 60, time = 60, recipes = RS }
	FORK_CASTING.materials["six-phased-copper"] = { "umv", T_SPC }
	FORK_CASTING.run()
	--- the first consumer: the lens block of section 32
	local lens = data.raw.recipe["spatially-transcendent-gravitational-lens-block"]
	lens.ingredients[#lens.ingredients + 1] = { type = "item", name = "long-six-phased-copper-rod", amount = 6 }
	table.insert(data.raw.technology["gravitational-lens"].prerequisites, T_SPC)
end


--------------------------------------------------------------------------------
--- 36) THE NANO FORGE AND ITS NANITES (issue #355, step 5 part 1; the maintainer's decision of 2026-10-20: YPIC as GT
--- New Horizons has it, no stand-ins, in two pull requests). GT5-Unofficial ce1c416a64 and NewHorizonsCoreMod (NHC).
--- * Melodic Alloy and Stellar Alloy (GT's materials, MaterialsInit.java:12479-12559): Melodic Alloy dust from end steel,
---   ender eye and oriharukon dust (NHC MixerRecipes.java:370-376; ULV, 5 s); oriharukon from Horus (160, the Void Miner
---   III). Stellar Alloy dust from Melodic Alloy, nether star and naquadah dust (:378-384), the blast furnace (NHC
---   BlastFurnaceRecipes.java:116-120: LuV, 200 s, 7200 K, with GT's gas variants) and the vacuum freezer
---   (VacuumFreezerRecipes.java:40-42: IV, 50 s); its rods cast (143), its frame from 4 rods (GT's assembler,
---   LoaderMetaPipeEntities.java:45-63). The end steel dust is the macerated ingot (4.9 s, the mass rule's 98 ticks of
---   155 for materials whose mass the mod does not compute); the ender eye dust is 155's (the ender eye lens).
--- * The Radiant Naquadah Alloy Casing (GT AssemblerRecipes.java:3066-3075: a prismatic naquadah frame, 12 naquadah
---   alloy plates, 4 prismatic naquadah screws, 9 ingots of indalloy 140 -> 4; UV, 10 ticks); prismatic naquadah's rods
---   and screws cast (143), its frame from 4 rods.
--- * The Nano Forge (GT NaniteChain.java:38-133, MTENanoForge.java): Carbon Nanites from the assembly line (:61-76: 16 UV
---   circuits and robot arms, 32 Stemcells, 32 naquadah alloy rings, 16 rods, 64 carbon dust, 10 000 L UU matter, 32
---   ingots of indalloy 140 -> 2; UV, 50 s), the controller (:38-59: 16 UV hulls, 16 carbon nanites, 16 ZPM field
---   generators, 16 UV conveyors, 32 UV motors, 16 LuV circuits, 32 8x naquadah wires (256 wires), 4 superdense naquadah
---   alloy plates, 32 ingots each of indalloy 140 and HSS-S, 16 of osmiridium; ZPM, 5 min). The machine is the controller
---   with its structure (the main piece: 468 Radiant Naquadah Alloy Casings, 170 Stellar Alloy frames and 59 casings or
---   hatches: 54 casings, a UMV energy hatch, the input hatch and bus, the output bus and the maintenance hatch as LV
---   hulls) and a carbon nanite in its slot: tier 1. Tier 2 (MTENanoForge.java:278-294, 619-633) adds 148 Radiant
---   casings and 16 Assembly Line Casings, and a neutronium nanite instead of the carbon one.
--- * Neutronium Nanites (:108-120: the Chromatic Lens, 8 neutronium blocks, 96 ASoC, 200 000 L UU matter -> 1; tier 1,
---   UMV, 100 s) and Glowstone Nanites (:122-133: the Radox Polymer Lens, 8 Double Compressed Glowstone, 64 ASoC, 50 000 L
---   UU matter -> 64; tier 2, UMV, 200 s); GT++'s compressed glowstone (RecipesGeneral.java:280-302: 9 glowstone blocks,
---   9 of those; 15 s at 2 EU/t) and the glowstone block (GT CompressorRecipes.java:270-275: 4 dust, 15 s). The nanites
---   GT makes in the Nano Forge (carbon nanites from bartworks' casings) are left out; the assembly line's are the
---   bootstrap. Glowstone nanites go into GT's Photonically Enhanced Wafer (section 37).
--- * Fluids a tenth of GT's litres, GT's seconds x the tier speed. Technologies: Nano Forge (the alloys, the casing, the
---   carbon nanites, the controller, the machine) after the Void Miner III (oriharukon), Prismatic Naquadah and the Naquadah
---   Fuel Refinery (the prismatic naquadah melt), the beamline (UU matter) and the UMV energy hatches; Nano Forge Tier 2 (the
---   neutronium and glowstone nanites, compressed glowstone) after it, the Godforge (the Chromatic Lens) and the
---   Gravitational Lens (the Radox Polymer Lens).
--------------------------------------------------------------------------------
do
	local T1, T2 = "nano-forge", "nano-forge-t2"
	local NF, NF2 = "nano-forge", "nano-forge-t2"
	local R1, R2 = {}, {}
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	items(SUB_DUST, { "end-steel-dust", "melodic-alloy-dust", "stellar-alloy-dust" })
	items(SUB_PART, { "hot-stellar-alloy-ingot", "stellar-alloy-ingot", "stellar-alloy-rod", "stellar-alloy-frame",
		"prismatic-naquadah-rod", "prismatic-naquadah-screw", "prismatic-naquadah-frame", "carbon-nanites", "neutronium-nanites",
		"glowstone-nanites", "glowstone-block", "compressed-glowstone", "double-compressed-glowstone", "nano-forge-controller" })
	items("subgroup-uhv-age-multiblocks", { "radiant-naquadah-alloy-casing" })

	--- the alloys
	step(R1, "end-steel-dust", "lv-macerator-recipes", 4.9, LV_SPEED, { { "end-steel-ingot", 1 } }, { { "end-steel-dust", 1 } })
	step(R1, "melodic-alloy-dust", "lv-mixer-recipes", 5, LV_SPEED,
		{ { "end-steel-dust", 1 }, { "ender-eye-dust", 1 }, { "oriharukon-dust", 1 } }, { { "melodic-alloy-dust", 3 } })
	step(R1, "stellar-alloy-dust", "lv-mixer-recipes", 5, LV_SPEED,
		{ { "melodic-alloy-dust", 1 }, { "nether-star-dust", 1 }, { "naquadah-dust", 1 } }, { { "stellar-alloy-dust", 3 } })
	blast(R1, "stellar-alloy", "luv-electric-blast-furnace-recipes", 200, LUV_SPEED)
	step(R1, "stellar-alloy-ingot", "iv-vacuum-freezer-recipes", 50, IV_SPEED, { { "hot-stellar-alloy-ingot", 1 } },
		{ { "stellar-alloy-ingot", 1 } })
	step(R1, "stellar-alloy-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "stellar-alloy-rod", 4 } },
		{ { "stellar-alloy-frame", 1 } })
	--- the casing
	step(R1, "prismatic-naquadah-frame", "lv-assembling-machine-recipes", 3.2, LV_SPEED, { { "prismatic-naquadah-rod", 4 } },
		{ { "prismatic-naquadah-frame", 1 } })
	step(R1, "radiant-naquadah-alloy-casing", "uv-assembling-machine-recipes", 0.5, UV_SPEED,
		{ { "prismatic-naquadah-frame", 1 }, { "naquadah-alloy-plate", 12 }, { "prismatic-naquadah-screw", 4 },
			{ "molten-indalloy-140", 129.6 } }, { { "radiant-naquadah-alloy-casing", 4 } })
	--- the carbon nanites and the controller
	step(R1, "carbon-nanites", "zpm-assembly-line-recipes", 50, UV_SPEED,
		{ { "uv-circuit", 16 }, { "uv-robot-arm", 16 }, { "stem-cells", 32 }, { "naquadah-alloy-ring", 32 }, { "naquadah-alloy-rod", 16 },
			{ "carbon", 64 }, { "uu-matter", 1000 }, { "molten-indalloy-140", 460.8 } }, { { "carbon-nanites", 2 } })
	step(R1, "nano-forge-controller", "zpm-assembly-line-recipes", 300, ZPM_SPEED,
		{ { "uv-machine-hull", 16 }, { "carbon-nanites", 16 }, { "zpm-field-generator", 16 }, { "uv-conveyor-module", 16 },
			{ "uv-motor", 32 }, { "luv-circuit", 16 }, { "naquadah-wire", 256 }, { "superdense-naquadah-alloy-plate", 4 },
			{ "molten-indalloy-140", 460.8 }, { "molten-hsss", 460.8 }, { "molten-osmiridium", 230.4 } },
		{ { "nano-forge-controller", 1 } })
	--- the machines
	machine{
		name = NF, category = "nano-forge-recipes", speed = UMV_SPEED, energy = power("umv", 1),
		subgroup = "subgroup-uhv-age-multiblocks", ports = { port("input", N, { 0, -1 }) }, list = R1,
		recipe = { "crafting-or-assembling-recipes", 1, { item("nano-forge-controller", 1), item("carbon-nanites", 1),
			item("radiant-naquadah-alloy-casing", 522), item("stellar-alloy-frame", 170), item("umv-energy-hatch", 1),
			item("lv-machine-hull", 4) } },
	}
	machine{
		name = NF2, category = "nano-forge-t2-recipes", speed = UMV_SPEED, energy = power("umv", 1),
		subgroup = "subgroup-uhv-age-multiblocks", ports = { port("input", N, { 0, -1 }) }, list = R2,
		recipe = { "crafting-or-assembling-recipes", 1, { item(NF, 1), item("neutronium-nanites", 1),
			item("radiant-naquadah-alloy-casing", 148), item("assembly-line-casing", 16) } },
	}
	data.raw["assembling-machine"][NF2].crafting_categories = { "nano-forge-recipes", "nano-forge-t2-recipes" }
	--- the nanites
	step(R2, "neutronium-nanites", "nano-forge-recipes", 100, UMV_SPEED,
		{ { "chromatic-lens", 1 }, { "block-of-neutronium", 8 }, { "advanced-system-on-chip", 96 }, { "uu-matter", 20000 } },
		{ { "neutronium-nanites", 1 }, { "chromatic-lens", 1 } }, "neutronium-nanites")
	step(R2, "glowstone-block", "lv-compressor-recipes", 15, LV_SPEED, { { "glowstone-dust", 4 } }, { { "glowstone-block", 1 } })
	step(R2, "compressed-glowstone", "lv-compressor-recipes", 15, LV_SPEED, { { "glowstone-block", 9 } },
		{ { "compressed-glowstone", 1 } })
	step(R2, "double-compressed-glowstone", "lv-compressor-recipes", 15, LV_SPEED, { { "compressed-glowstone", 9 } },
		{ { "double-compressed-glowstone", 1 } })
	step(R2, "glowstone-nanites", "nano-forge-t2-recipes", 200, UMV_SPEED,
		{ { "radox-polymer-lens", 1 }, { "double-compressed-glowstone", 8 }, { "advanced-system-on-chip", 64 }, { "uu-matter", 5000 } },
		{ { "glowstone-nanites", 64 }, { "radox-polymer-lens", 1 } }, "glowstone-nanites")

	F.tech{ name = T1, prerequisites = { "void-miner-iii", "end-steel", "prismatic-naquadah", "naquadah-based-fuel-mk4", "beamline",
		"umv-energy-hatches" }, packs = 13, count = 95, time = 60, recipes = R1 }   -- (as the UMV technologies of 138)
	F.tech{ name = T2, prerequisites = { T1, "godforge", "gravitational-lens" }, packs = 15, count = 55, time = 60, recipes = R2 }
	FORK_CASTING.materials["stellar-alloy"] = { "luv", T1, color = { 211, 255, 255 } }
	FORK_CASTING.materials["prismatic-naquadah"] = { "zpm", T1 }   -- (its rods and screws; the melt stays with the refinery)
	FORK_CASTING.run()
end


--------------------------------------------------------------------------------
--- 37) THE YOCTO POWER IC (issue #355, step 5 part 2; the maintainer's decisions of 2026-10-20). NewHorizonsCoreMod
--- (NHC: com/dreammaster/gthandler/recipes) and GT5-Unofficial ce1c416a64.
--- * The Optically Enriched Crystalline Boule (NHC LaserEngraverRecipes.java:167-174: an americium boule engraved with
---   the Magneto Resonatic, Fayalite and Quite Certain (mysterious) Crystal lenses and 16 000 L UU matter; UEV, 30 s;
---   the fayalite lens from its plate, 155), cut into Photonically Prepared Wafers (CuttingMachineRecipes.java:203-214:
---   16 with 1000 L grade 7 water in 50 s, 24 with grade 8 in 25 s; UEV). The engraver holds three lenses at once, so
---   they stay ingredients and results (150 slots a recipe's only lens).
--- * The Photonically Enhanced Wafer (LaserEngraverRecipes.java:176-188: the wafer, a Glowstone Nanite (section 36), the
---   Solar Light Splitter (kept, in the lens slot), 1000 L tin plasma, 4000 L oganesson -> the wafer and 1000 L molten
---   tin; UEV, 10 s). The splitter (AssemblerRecipes.java:1124-1133: 3 red, green and blue components; HV, 5 s), the
---   components (ScriptSuperSolarPanels.java:89-172: an Irradiant Glass Pane engraved with a lens; IV, 50 s; the lenses
---   the mod has: emerald, green sapphire, olivine; sapphire; ruby, red garnet), the pane (AssemblerRecipes.java:1107-
---   1114: 4 Irradiant Uranium, 4 reinforced glass, a glowstone plate -> 4; HV, 5 s), Irradiant Uranium (:1116-1122: a
---   uranium ingot and a Sunnarium; EV, 30 s), Sunnarium (CompressorRecipes.java:234-242: a sunnarium dust, 15 s) and the
---   glowstone plate (GT CuttingRecipes.java:204-209: a glowstone block with 1 L lubricant -> 4; 5 s at 16 EU/t). GT's
---   uranium ingot is uranium 238's, solidified from its melt (136's molten uranium; GT's ingot mold: 144 L, 1.6 s; EV). SuperSolarPanels' names are not in the checkouts; the
---   components take their colour's name.
--- * The Infinite Wafer (BlastFurnaceRecipes.java:780-786: the wafer, 4 eternity dust, 4 shirabon dust, 576 L infinity
---   plasma; UXV, 30 s, 22 000 K: the UXV blast furnace). Shirabon (the maintainer's decision): its ingot cast from the
---   melt (143, UMV), the dust macerated (6.4 s: its mass 128 in ticks). Infinity plasma in the godforge's plasma module
---   (tectech Godforge.java:300-336: 144 L molten infinity -> 144 L; 30 s, UXV), as 140's celestial tungsten plasma.
--- * The YPIC wafer (FluidSolidifierRecipes.java:431-435: the Infinite Wafer and 1500 L quark gluon plasma; MAX, 5 s)
---   and the chip (LaserEngraverRecipes.java:314-320: the wafer engraved with the gravitational lens and 25 L superfluid
---   -> 2; UXV, 5 s).
--- * GTNH's UXV energy and dynamo hatches with YPIC (tectech ResearchStationAssemblyLine.java:277-297, 396-415: the UXV
---   hull, 4 8x UMV superconductor wires (dynamo: 16 springs), 2 YPIC, 2 UXV circuits, 2 UXV coils, 8 space coolant
---   cells, the UXV pump, 64 000 L super coolant, 80 ingots of mutated living solder; UXV, 50 s; its UU matter left out
---   as for the ZPIC hatches) as additional recipes. The hatches keep their APIC recipe (134, 136): the Infinite Wafer's
---   eternity dust comes with the UXV energy hatches, so GTNH's recipe alone would be a cycle (as section 33).
--- Fluids a tenth of GT's litres (plasmas GT's), GT's seconds x the tier speed. Everything is unlocked where it is first
--- consumed, by the technology Yocto Power ICs.
--------------------------------------------------------------------------------
do
	local T = "yocto-power-ics"
	local R = {}
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	items(SUB_DUST, { "shirabon-dust" })
	items(SUB_PART, { "shirabon-ingot", "uranium-238-ingot", "sunnarium", "irradiant-uranium", "glowstone-plate",
		"irradiant-glass-pane", "red-component", "green-component", "blue-component", "solar-light-splitter",
		"optically-enriched-crystalline-boule", "photonically-prepared-wafer", "photonically-enhanced-wafer", "infinite-wafer",
		"ypic-wafer", "yocto-power-ic" })
	F.fluid("infinity-plasma", "infinity-plasma", { 1, 1, 1 })
	--- the Solar Light Splitter
	step(R, "sunnarium", "lv-compressor-recipes", 15, LV_SPEED, { { "sunnarium-dust", 1 } }, { { "sunnarium", 1 } })
	step(R, "uranium-238-ingot", "ev-fluid-solidifier-recipes", 1.6, EV_SPEED, { { "molten-uranium", 14.4 } },
		{ { "uranium-238-ingot", 1 } })
	step(R, "irradiant-uranium", "ev-assembling-machine-recipes", 30, EV_SPEED,
		{ { "uranium-238-ingot", 1 }, { "sunnarium", 1 } }, { { "irradiant-uranium", 1 } })
	step(R, "glowstone-plate", "lv-cutting-machine-recipes", 5, LV_SPEED, { { "glowstone-block", 1 }, { "lubricant", 1 } },
		{ { "glowstone-plate", 4 } })
	step(R, "irradiant-glass-pane", "hv-assembling-machine-recipes", 5, HV_SPEED,
		{ { "irradiant-uranium", 4 }, { "reinforced-glass", 4 }, { "glowstone-plate", 1 } }, { { "irradiant-glass-pane", 4 } })
	for colour, lenses in pairs({ red = { "ruby", "red-garnet" }, green = { "emerald", "green-sapphire", "olivine" },
		blue = { "sapphire" } }) do
		for _, l in pairs(lenses) do
			step(R, colour .. "-component-" .. l, "iv-laser-engraver-recipes", 50, IV_SPEED,
				{ { "irradiant-glass-pane", 1 }, { l .. "-lens", 1 } }, { { colour .. "-component", 1 }, { l .. "-lens", 1 } },
				colour .. "-component")
		end
	end
	step(R, "solar-light-splitter", "hv-assembling-machine-recipes", 5, HV_SPEED,
		{ { "red-component", 3 }, { "green-component", 3 }, { "blue-component", 3 } }, { { "solar-light-splitter", 1 } })
	--- the wafers
	step(R, "optically-enriched-crystalline-boule", "uev-laser-engraver-recipes", 30, UEV_SPEED,
		{ { "americium-doped-monocrystaline-silicon-boule", 1 }, { "magneto-resonatic-lens", 1 }, { "fayalite-lens", 1 },
			{ "mysterious-crystal-lens", 1 }, { "uu-matter", 1600 } },
		{ { "optically-enriched-crystalline-boule", 1 }, { "magneto-resonatic-lens", 1 }, { "fayalite-lens", 1 },
			{ "mysterious-crystal-lens", 1 } }, "optically-enriched-crystalline-boule")
	step(R, "photonically-prepared-wafer", "uev-cutting-machine-recipes", 50, UEV_SPEED,
		{ { "optically-enriched-crystalline-boule", 1 }, { "grade-7-water", 100 } }, { { "photonically-prepared-wafer", 16 } })
	step(R, "photonically-prepared-wafer-grade-8", "uev-cutting-machine-recipes", 25, UEV_SPEED,
		{ { "optically-enriched-crystalline-boule", 1 }, { "grade-8-water", 100 } }, { { "photonically-prepared-wafer", 24 } })
	step(R, "photonically-enhanced-wafer", "uev-laser-engraver-recipes", 10, UEV_SPEED,
		{ { "photonically-prepared-wafer", 1 }, { "glowstone-nanites", 1 }, { "solar-light-splitter", 1 }, { "tin-plasma", 1000 },
			{ "oganesson", 400 } },
		{ { "photonically-enhanced-wafer", 1 }, { "solar-light-splitter", 1 }, { "molten-tin", 100 } }, "photonically-enhanced-wafer")
	step(R, "shirabon-dust", "lv-macerator-recipes", 6.4, LV_SPEED, { { "shirabon-ingot", 1 } }, { { "shirabon-dust", 1 } })
	create_recipe{
		name = "infinity-plasma",
		category = "godforge-recipes",
		energy_required = 30 * UXV_SPEED,
		subgroup = "subgroup-godforge-recipes",
		ingredients = { { type = "fluid", name = "molten-infinity", amount = 14.4 },
			{ type = "fluid", name = "raw-star-matter", amount = 30 * UXV_SPEED / UMV_SPEED * 0.25 } },
		results = { { type = "fluid", name = "infinity-plasma", amount = 144 } },
		main_product = "infinity-plasma",
	}
	data.raw.recipe["infinity-plasma"].allow_productivity = true
	R[#R + 1] = "infinity-plasma"
	step(R, "infinite-wafer", "uxv-electric-blast-furnace-recipes", 30, UXV_SPEED,
		{ { "photonically-enhanced-wafer", 1 }, { "eternity-dust", 4 }, { "shirabon-dust", 4 }, { "infinity-plasma", 576 } },
		{ { "infinite-wafer", 1 } })
	step(R, "ypic-wafer", "max-fluid-solidifier-recipes", 5, MAX_SPEED, { { "infinite-wafer", 1 }, { "quark-gluon-plasma", 150 } },
		{ { "ypic-wafer", 1 } })
	step(R, "yocto-power-ic", "uxv-laser-engraver-recipes", 5, UXV_SPEED,
		{ { "ypic-wafer", 1 }, { "gravitational-lens", 1 }, { "dimensionally-shifted-superfluid", 2.5 } },
		{ { "yocto-power-ic", 2 }, { "gravitational-lens", 1 } }, "yocto-power-ic")
	--- the hatches
	for _, h in pairs({ { "uxv-energy-hatch", { "hypocosmium-superconductive-wire", 32 } }, { "uxv-dynamo-hatch", { "hypocosmium-spring", 16 } } }) do
		step(R, h[1] .. "-ypic", "zpm-assembly-line-recipes", 50, UXV_SPEED,
			{ { "uxv-machine-hull", 1 }, h[2], { "yocto-power-ic", 2 }, { "uxv-circuit", 2 }, { "extended-mega-ultimate-voltage-coil", 2 },
				{ "1080k-super-coolant-cell", 8 }, { "uxv-pump", 1 }, { "super-coolant", 6400 }, { "molten-indalloy-140", 1152 } },
			{ { h[1], 1 } })
	end
	F.tech{ name = T, prerequisites = { "nano-forge-t2", "zepto-power-ics", "uxv-energy-hatches", "uxv-naquadah-reactor",
		"naquadah-based-fuel-mk6", "max-machines" }, packs = 15, count = 55, time = 60, recipes = R }   -- (as section 33)
	FORK_CASTING.materials["shirabon"] = { "umv", T }
	FORK_CASTING.run()
	--- (the three lenses stay ingredients and results, see 150)
	FORK_ENGRAVER_NO_LENS["optically-enriched-crystalline-boule"] = "GT holds three lenses at once (NHC LaserEngraverRecipes.java:"
		.. "167-174); they stay ingredients and results, as the lens slot of 150 takes one"
end



--------------------------------------------------------------------------------
--- 39) THE SINGULARITY CRAFTING STORAGE AND THE VOID CELLS (issue #487; the maintainer's decisions of 2026-10-21). GT5-
---   Unofficial ce1c416a64 and NewHorizonsCoreMod (NHC: gthandler/recipes and scripts).
--- * Transcendent Metal Nanites (GT NaniteChain.java:145-157: the Energised Tesseract (kept), 8 transcendent metal
---   blocks, 192 ASoC, 2 000 000 L UU matter -> 1; Nano Forge tier 2, 1G EU/t: MAX, 750 s), the Energised Tesseract
---   (goodgenerator NeutronActivatorLoader.java:50-58: a Raw Tesseract and 64 L naquadah fuel MK V; 16 400 s; GT's NKE
---   window is not modelled, as the activator's other recipes; the depleted fuel is left out, as section 27's), the Raw
---   Tesseract (NHC DTPFRecipes.java:429-438, the only variant whose parts the mod has: 32 transcendent metal rods, 24 Black
---   Titanium plates, 16 Zeron-100 screws, a Quantum Anomaly (GT++'s Laser_Lens_Special, used up), 1000 L excited stellar
---   catalyst -> 16 and 2000 L residue; UXV, 20 s) and GT++'s Black Titanium (MaterialsAlloy.java:804-821, made only in the
---   alloy blast smelter, RecipeGenBlastSmelter: 55 titanium, 12 lanthanum, 8 tungsten, 6 cobalt, 4 manganese, 4
---   phosphorus, 4 palladium, 2 niobium dust and 5000 L argon -> 14 400 L; UV, 480 s), its plate cast (143).
---   Nano Forge tier 3 (MTENanoForge.java:295-325, 630-634): tier 2 with the transcendent nanite in its slot, 228 more
---   Radiant casings, 16 Assembly Line Casings and 84 Stellar Alloy frames. Its own nanites (gold, Six-Phased Copper, the
---   dwarf matters, universium, eternity) have no consumer in the mod and are left out.
--- * The Creative Energy Cell (NHC ScriptAppliedEnergistics2.java:664-684, Avaritia's extreme table: 32 infinity ingots,
---   36 Dense Energy Cells, 12 Item Processors Tier IV, a cosmic neutronium block): the UEV assembler (the mod has no
---   extreme table, as 120's crafting storages). AE2's Energy Cell (NHC AssemblerRecipes.java:4668-4677: 4 certus quartz
---   plates, a fluix dust, 2 HV circuits, a fluix block, an 8x aluminium cable; HV, 5 s) and Dense Energy Cell (:4679-4686:
---   5 energy cells, 2 LuV circuits, an engineering processor, GT's EV 4x4 battery buffer; HV, 5 s) are crafting items
---   here (the maintainer's decision; me-network has no energy cells): the HV battery buffer of 16 batteries for GT's EV
---   one (the mod's battery buffers end at HV, #444), 8 aluminium cables for the 8x one.
--- * The Singularity crafting storage (SAE2:618-649) takes 4 Creative Energy Cells and 4 Transcendent Metal Nanites now (for
---   120's 4 transcendent metal blocks); its 8 Draconic Reactor Stabilizers come in section 41 (#489).
--- * AE2's Singularity (SAE2:903-906: 512 000 cobblestone in the neutronium compressor, IV, 3 s): the mod's stone is
---   Minecraft's cobblestone (the maintainer's decision); a recipe takes at most 65 535 of an item, so 64 000 stone make a
---   Compressed Cobblestone and 8 of them the Singularity, in the IV compressor (named stand-ins for the one step). The void
---   cells take it as GTNH's (AssemblerRecipes.java:4687-4695; the fluid one AE2FC's, ScriptAE2FC.java:769-778: 2
---   tungstensteel plates and a stainless steel plate instead of 3 tungsten plates).
--- Technologies: Transcendent Metal Nanites (the chain and Nano Forge tier 3) after Nano Forge Tier 2, the stellar
--- catalyst, MK V and the neutron activator; ME Crafting Storage Singularity after it (the energy cells, the creative cell);
--- the Singularity with the void cells (ME Upgrade Cards).
--------------------------------------------------------------------------------
do
	local T_NAN = "transcendent-metal-nanites"
	local CRAFT, CARDS = "me-crafting-storage-singularity", "me-upgrade-cards"
	local RN, RC, RV = {}, {}, {}
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	items(SUB_PART, { "black-titanium-plate", "raw-tesseract", "energised-tesseract", "transcendent-metal-nanites",
		"energy-cell", "dense-energy-cell", "compressed-stone", "singularity" })
	F.fluid("molten-black-titanium", "molten-black-titanium", { 137 / 255, 137 / 255, 154 / 255 })
	--- icons without a texture of their own (AE2's are not used): me-network's creative energy cell picture (its ME charger)
	--- in a blue and a deep blue, the eternal singularity's in grey
	local creative = data.raw.item["me-creative-energy-cell"]
	local charger = creative and creative.icons and creative.icons[1]
	for name, tint in pairs({ ["energy-cell"] = { 0.55, 0.85, 1, 1 }, ["dense-energy-cell"] = { 0.3, 0.5, 1, 1 } }) do
		if charger then
			data.raw.item[name].icon, data.raw.item[name].icon_size = nil, nil
			data.raw.item[name].icons = { { icon = charger.icon, icon_size = charger.icon_size, tint = tint } }
		end
	end
	data.raw.item["singularity"].icon, data.raw.item["singularity"].icon_size = nil, nil
	data.raw.item["singularity"].icons = { { icon = "__gregtorio-continued__/graphics/icons/eternal-singularity.png", icon_size = 32,
		tint = { 0.6, 0.6, 0.65, 1 } } }

	--- the nanites
	step(RN, "molten-black-titanium", "uv-alloy-blast-smelter-recipes", 480, UV_SPEED,
		{ { "titanium-dust", 55 }, { "lanthanum-dust", 12 }, { "tungsten-dust", 8 }, { "cobalt-dust", 6 }, { "manganese-dust", 4 },
			{ "phosphorus", 4 }, { "palladium-dust", 4 }, { "niobium-dust", 2 }, { "argon", 500 } }, { { "molten-black-titanium", 1440 } })
	step(RN, "raw-tesseract", "dimensionally-transcendent-plasma-forge-recipes", 20, UXV_SPEED,
		{ { "transcendent-metal-rod", 32 }, { "black-titanium-plate", 24 }, { "zeron-100-screw", 16 }, { "quantum-anomaly", 1 },
			{ "excited-dimensionally-transcendent-stellar-catalyst", 100 } },
		{ { "raw-tesseract", 16 }, { "dimensionally-transcendent-residue", 200 } }, "raw-tesseract")
	step(RN, "energised-tesseract", "neutron-activator-recipes", 16400, 1,
		{ { "raw-tesseract", 1 }, { "naquadah-based-fuel-mk5", 64 } }, { { "energised-tesseract", 1 } })
	step(RN, "transcendent-metal-nanites", "nano-forge-t2-recipes", 750, MAX_SPEED,
		{ { "energised-tesseract", 1 }, { "block-of-transcendent-metal", 8 }, { "advanced-system-on-chip", 192 },
			{ "uu-matter", 200000 } }, { { "transcendent-metal-nanites", 1 }, { "energised-tesseract", 1 } }, "transcendent-metal-nanites")
	machine{
		name = "nano-forge-t3", category = "nano-forge-t3-recipes", speed = UMV_SPEED, energy = power("umv", 1),
		subgroup = "subgroup-uhv-age-multiblocks", ports = { port("input", N, { 0, -1 }) }, list = RN,
		recipe = { "crafting-or-assembling-recipes", 1, { item("nano-forge-t2", 1), item("transcendent-metal-nanites", 1),
			item("radiant-naquadah-alloy-casing", 228), item("assembly-line-casing", 16), item("stellar-alloy-frame", 84) } },
	}
	data.raw["assembling-machine"]["nano-forge-t3"].crafting_categories = { "nano-forge-recipes", "nano-forge-t2-recipes",
		"nano-forge-t3-recipes" }
	F.tech{ name = T_NAN, prerequisites = { "nano-forge-t2", "dtpf-stellar-catalyst", "naquadah-based-fuel-mk5" }, packs = 15,
		count = 55, time = 60, recipes = RN }   -- (as section 33)
	FORK_CASTING.materials["black-titanium"] = { "uv", T_NAN }
	FORK_CASTING.run()

	--- the creative energy cell and the crafting storage
	step(RC, "energy-cell", "hv-assembling-machine-recipes", 5, HV_SPEED,
		{ { "certus-quartz-plate", 4 }, { "fluix-dust", 1 }, { "processing-unit", 2 }, { "fluix-block", 1 }, { "aluminium-cable", 8 } },
		{ { "energy-cell", 1 } })
	step(RC, "dense-energy-cell", "hv-assembling-machine-recipes", 5, HV_SPEED,
		{ { "energy-cell", 5 }, { "luv-circuit", 2 }, { "engineering-processor", 1 }, { "hv-battery-buffer-16", 1 } },
		{ { "dense-energy-cell", 1 } })
	if data.raw.item["me-creative-energy-cell"] then
		step(RC, "me-creative-energy-cell", "uev-assembling-machine-recipes", 20, UEV_SPEED,
			{ { "infinity-ingot", 32 }, { "dense-energy-cell", 36 }, { "item-processor-tier-iv", 12 }, { "block-of-cosmic-neutronium", 1 } },
			{ { "me-creative-energy-cell", 1 } })
	end
	local storage = data.raw.recipe["me-singularity-crafting-storage"]
	if storage and data.raw.technology[CRAFT] then
		local ing = {}
		for _, i in pairs(storage.ingredients) do
			if i.name ~= "block-of-transcendent-metal" then ing[#ing + 1] = i end
		end
		ing[#ing + 1] = item("transcendent-metal-nanites", 4)
		if data.raw.item["me-creative-energy-cell"] then ing[#ing + 1] = item("me-creative-energy-cell", 4) end
		storage.ingredients = ing
		local t = data.raw.technology[CRAFT]
		table.insert(t.prerequisites, T_NAN)
		table.insert(t.prerequisites, "large-batteries")   -- (the dense energy cell's battery buffer)
		t.unit.ingredients = table.deepcopy(data.raw.technology[T_NAN].unit.ingredients)
		t.unit.count = 55
		for _, r in pairs(RC) do fork_add_unlock(CRAFT, r) end
	end

	--- the singularity and the void cells
	step(RV, "compressed-stone", "iv-compressor-recipes", 3, IV_SPEED, { { "stone", 64000 } }, { { "compressed-stone", 1 } })
	step(RV, "singularity", "iv-compressor-recipes", 3, IV_SPEED, { { "compressed-stone", 8 } }, { { "singularity", 1 } })
	local void, fvoid = data.raw.recipe["me-void-storage-cell"], data.raw.recipe["me-void-fluid-storage-cell"]
	if void and data.raw.technology[CARDS] then
		table.insert(void.ingredients, item("singularity", 1))
		if fvoid then
			fvoid.ingredients = { item("certus-quartz-screw", 2), item("certus-quartz-plate", 1), item("tungstensteel-plate", 2),
				item("stainless-steel-plate", 1), item("singularity", 1) }
		end
		for _, r in pairs(RV) do fork_add_unlock(CARDS, r) end
	end
end



--------------------------------------------------------------------------------
--- 40) DRACONIC EVOLUTION'S CORES IN THE FUSION CRAFTER (issue #489 part 1; the maintainer's decisions of 2026-10-22).
---   GT5-Unofficial ce1c416a64 (kubatech, tectech) and NewHorizonsCoreMod (NHC); the names are Draconic Evolution's (GTNH's
---   fork 9f42531, en_US.lang: meta 0 of its energy core is the Wyvern, meta 1 the Draconic Energy Core).
--- * The Draconic Evolution Fusion Crafter (kubatech MTEDEFusionCrafter.java:82-139): the controller (tectech
---   ResearchStationAssemblyLine.java:951-970, UEV, 75 s), 43 Naquadah Alloy Fusion Casings (the 49 places of the top and
---   bottom layers less the controller and 5 hatches), 32 fusion machine casings, 8 fusion coils and 32 Fusion Casings of
---   its tier. One machine per casing tier (the maintainer's decision, as the refinery's coil tiers): tier 2 to 4 are the
---   one before with 32 casings of the tier (tier 4 with MK II fusion casings, :139) and the tier's energy hatch; a tier
---   runs its recipes and those below at its tier's speed (GT's perfect overclock per tier above is not modelled).
--- * The casings (kubatech DEFCRecipes.java:66-125, assembler, 30 s): the base from 6 naquadah alloy frames and 6 dense
---   plates, tier 1 from GTNH's Blood-Soaked Ichorium Block and 6 dense osmiridium plates, each next one from the one before
---   and 6 dense plates of draconium, cosmic neutronium, awakened draconium, with a draconic, 2 wyvern, 3 awakened cores.
--- * The cores (DEFCRecipes.java:169-273, the schematic kept): the Draconic Core (4 osmiridium plates, an ichorium plate, a
---   Quantum Eye, 1440 L sunnarium; UV, 20 s, tier 1), the Wyvern Core (8 draconium and 4 neutronium plates, 4 draconic
---   cores, a Quantum Star, 1440 L neutronium; UHV, 40 s, tier 2), the Awakened Core (12 awakened draconium and 4
---   draconium plates, 4 wyvern cores, a manyullyn crystal (kubatech's recipe without SuperSolarPanels; GTNH's Ender
---   Quantum Component needs a dense infinity catalyst plate the mod lacks), 1440 L infinity; UEV, 80 s, tier 3), the
---   Wyvern and Draconic Energy Cores (8 draconium plates, 4 stellar alloy plates, 4 Sunnarium Alloy, a draconic core; UV,
---   50 s, tier 2 / 8 awakened draconium plates, 4 energy cores, 4 Enriched Sunnarium Alloy, a wyvern core; UHV, 100 s,
---   tier 3). The Chaotic Core follows in part 2.
--- * The schematics (tectech ResearchStationAssemblyLine.java:972-1015, the research assembly line, 3 min): Draconic (a
---   draconic core, a dense draconium plate, an ichorium plate, a UHV circuit, 14 400 L sunnarium, 28 800 L void; UHV),
---   Wyvern (4 draconic cores, dense draconium and neutronium plates, a UEV circuit, 14 400 L neutronium, 57 600 L void;
---   UEV), Awakened (4 wyvern cores, dense awakened draconium and infinity plates, a UIV circuit, 14 400 L infinity, 115 200
---   L void; UIV). The first Draconic Core Schematic and core come from the Draconic Core Ruin (162), as in GTNH.
--- * The sunnarium alloys (NHC AlloySmelterRecipes.java:231-248, ScriptAdvancedSolarPanel.java:136-141): Sunnarium Alloy
---   (4 sunnarium plates, 8 iridium reinforced plates; LuV, 7.5 s), Enriched Sunnarium (a sunnarium and 8 irradiant
---   uranium; IV assembler, 60 s), Enriched Sunnarium Alloy (the alloy and 8 enriched sunnarium; ZPM, 10 s), Enriched
---   Naquadria Sunnarium Alloy (the enriched alloy and a dense naquadria plate; UV, 12.5 s).
--- * Named stand-ins for Thaumcraft's, Blood Magic's and Botania's items (the maintainer's decision): molten neutronium for
---   molten void metal, the orundum plate for the ichorium plate (9 for the Blood-Soaked Ichorium Block), the dense awakened
---   draconium plate for the dense Gaia Spirit plate, the Quantum Star for the Primordial Pearl, 8 UHV sensors and 8 UHV
---   emitters for Blood Magic's 8 + 8 parts, the superdense neutronium plate for the superdense void plate.
--- Fluids a tenth of GT's litres, GT's seconds x the tier speed. Technologies by casing tier: Draconic Evolution Fusion
--- Crafter (tier 1, the draconic core and schematic) after the Mining Module Mk-III (the ruin), Wyvern Cores, Awakened Cores;
--- Draconic Energy Cores (the sunnarium alloys and the energy cores) at MAX, as section 37's sunnarium and irradiant uranium.
--------------------------------------------------------------------------------
do
	local DEFC = "draconic-evolution-fusion-crafter"
	local T = { "draconic-evolution-fusion-crafter", "wyvern-cores", "awakened-cores", "draconic-energy-cores" }
	local R = { {}, {}, {}, {} }
	local AL = "zpm-assembly-line-recipes"
	local VOID = "molten-neutronium"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	items(SUB_PART, { "draconic-core", "wyvern-core", "awakened-core", "wyvern-energy-core", "draconic-energy-core",
		"draconic-core-schematic", "wyvern-core-schematic", "awakened-core-schematic", "sunnarium-alloy", "enriched-sunnarium",
		"enriched-sunnarium-alloy", "enriched-naquadria-sunnarium-alloy", "draconic-evolution-fusion-crafter-controller" })
	items("subgroup-uhv-age-multiblocks", { "naquadah-alloy-fusion-casing", "bloody-ichorium-fusion-casing",
		"draconium-fusion-casing", "wyvern-fusion-casing" })

	--- the sunnarium alloys
	step(R[4], "sunnarium-alloy", "luv-alloy-smelter-recipes", 7.5, LUV_SPEED,
		{ { "sunnarium-plate", 4 }, { "iridium-reinforced-plate", 8 } }, { { "sunnarium-alloy", 1 } })
	step(R[4], "enriched-sunnarium", "iv-assembling-machine-recipes", 60, IV_SPEED,
		{ { "sunnarium", 1 }, { "irradiant-uranium", 8 } }, { { "enriched-sunnarium", 1 } })
	step(R[4], "enriched-sunnarium-alloy", "zpm-alloy-smelter-recipes", 10, ZPM_SPEED,
		{ { "sunnarium-alloy", 1 }, { "enriched-sunnarium", 8 } }, { { "enriched-sunnarium-alloy", 1 } })
	step(R[4], "enriched-naquadria-sunnarium-alloy", "uv-alloy-smelter-recipes", 12.5, UV_SPEED,
		{ { "enriched-sunnarium-alloy", 1 }, { "dense-naquadria-plate", 1 } }, { { "enriched-naquadria-sunnarium-alloy", 1 } })

	--- the casings and the controller
	step(R[1], "naquadah-alloy-fusion-casing", "uv-assembling-machine-recipes", 30, UV_SPEED,
		{ { "naquadah-alloy-frame", 6 }, { "dense-naquadah-alloy-plate", 6 }, { VOID, 115.2 } }, { { "naquadah-alloy-fusion-casing", 1 } })
	step(R[1], "bloody-ichorium-fusion-casing", "uv-assembling-machine-recipes", 30, UV_SPEED,
		{ { "orundum-plate", 9 }, { "dense-osmiridium-plate", 6 }, { VOID, 115.2 } }, { { "bloody-ichorium-fusion-casing", 1 } })
	step(R[2], "draconium-fusion-casing", "uv-assembling-machine-recipes", 30, UV_SPEED,
		{ { "bloody-ichorium-fusion-casing", 1 }, { "dense-draconium-plate", 6 }, { "draconic-core", 1 }, { VOID, 230.4 } },
		{ { "draconium-fusion-casing", 1 } })
	step(R[3], "wyvern-fusion-casing", "uhv-assembling-machine-recipes", 30, UHV_SPEED,
		{ { "draconium-fusion-casing", 1 }, { "dense-cosmic-neutronium-plate", 6 }, { "wyvern-core", 2 }, { VOID, 460.8 } },
		{ { "wyvern-fusion-casing", 1 } })
	step(R[1], "draconic-evolution-fusion-crafter-controller", AL, 75, UEV_SPEED,
		{ { "uhv-assembling-machine", 1 }, { "bloody-ichorium-fusion-casing", 1 }, { "dense-awakened-draconium-plate", 1 },
			{ "awakened-draconium-coil-block", 8 }, { "uhv-motor", 8 }, { "uhv-robot-arm", 4 }, { "uhv-circuit", 4 },
			{ "gravi-star", 4 }, { "quantum-star", 1 }, { "uhv-sensor", 8 }, { "uhv-emitter", 8 }, { "superdense-neutronium-plate", 1 },
			{ "molten-indalloy-140", 288 }, { VOID, 288 }, { "molten-awakened-draconium", 144 } },
		{ { "draconic-evolution-fusion-crafter-controller", 1 } })

	--- the machines: tier 1, then each the one before with its casings and energy hatch
	local PORTS = { port("input", N, { 0, -1 }) }
	local TIERS = { { "uv", UV_SPEED }, { "uhv", UHV_SPEED }, { "uev", UEV_SPEED } }
	local CASING = { "bloody-ichorium-fusion-casing", "draconium-fusion-casing", "wyvern-fusion-casing" }
	local cats = {}
	for k = 1, 3 do
		local name = DEFC .. "-t" .. k
		cats[#cats + 1] = DEFC .. "-t" .. k .. "-recipes"
		local recipe = k == 1 and { item(DEFC .. "-controller", 1), item("naquadah-alloy-fusion-casing", 43),
			item("fusion-machine-casing", 32), item("fusion-coil-block", 8), item(CASING[1], 32), item("uv-energy-hatch", 1),
			item("lv-machine-hull", 4) }
			or { item(DEFC .. "-t" .. (k - 1), 1), item(CASING[k], 32), item(TIERS[k][1] .. "-energy-hatch", 1) }
		machine{
			name = name, category = cats[#cats], speed = TIERS[k][2], energy = power(TIERS[k][1], 1),
			subgroup = "subgroup-uhv-age-multiblocks", ports = PORTS, list = R[k],
			recipe = { "crafting-or-assembling-recipes", 1, recipe },
		}
		data.raw["assembling-machine"][name].crafting_categories = table.deepcopy(cats)
		FORK_RECYCLING_BLACKLIST[name] = "the crafter's structure; GT recycles the controller"
	end
	local C1, C2, C3 = DEFC .. "-t1-recipes", DEFC .. "-t2-recipes", DEFC .. "-t3-recipes"

	--- the cores and the schematics (kept)
	local function core(list, name, cat, seconds, speed, schematic, ingredients)
		ingredients[#ingredients + 1] = { schematic, 1 }
		step(list, name, cat, seconds, speed, ingredients, { { name, 1 }, { schematic, 1 } }, name)
	end
	core(R[1], "draconic-core", C1, 20, UV_SPEED, "draconic-core-schematic",
		{ { "osmiridium-plate", 4 }, { "orundum-plate", 1 }, { "quantum-eye", 1 }, { "molten-sunnarium", 144 } })
	core(R[2], "wyvern-core", C2, 40, UHV_SPEED, "wyvern-core-schematic",
		{ { "draconium-plate", 8 }, { "neutronium-plate", 4 }, { "draconic-core", 4 }, { "quantum-star", 1 }, { "molten-neutronium", 144 } })
	core(R[3], "awakened-core", C3, 80, UEV_SPEED, "awakened-core-schematic",
		{ { "awakened-draconium-plate", 12 }, { "draconium-plate", 4 }, { "wyvern-core", 4 }, { "manyullyn-crystal", 1 },
			{ "molten-infinity", 144 } })
	core(R[4], "wyvern-energy-core", C2, 50, UV_SPEED, "wyvern-core-schematic",
		{ { "draconium-plate", 8 }, { "stellar-alloy-plate", 4 }, { "sunnarium-alloy", 4 }, { "draconic-core", 1 } })
	core(R[4], "draconic-energy-core", C3, 100, UHV_SPEED, "awakened-core-schematic",
		{ { "awakened-draconium-plate", 8 }, { "wyvern-energy-core", 4 }, { "enriched-sunnarium-alloy", 4 }, { "wyvern-core", 1 } })
	step(R[1], "draconic-core-schematic", AL, 180, UHV_SPEED,
		{ { "draconic-core", 1 }, { "dense-draconium-plate", 1 }, { "orundum-plate", 1 }, { "uhv-circuit", 1 },
			{ "molten-sunnarium", 1440 }, { VOID, 2880 } }, { { "draconic-core-schematic", 1 } })
	step(R[2], "wyvern-core-schematic", AL, 180, UEV_SPEED,
		{ { "draconic-core", 4 }, { "dense-draconium-plate", 1 }, { "neutronium-plate", 1 }, { "uev-circuit", 1 },
			{ VOID, 1440 + 5760 } }, { { "wyvern-core-schematic", 1 } })
	step(R[3], "awakened-core-schematic", AL, 180, UIV_SPEED,
		{ { "wyvern-core", 4 }, { "dense-awakened-draconium-plate", 1 }, { "infinity-plate", 1 }, { "uiv-circuit", 1 },
			{ "molten-infinity", 1440 }, { VOID, 11520 } }, { { "awakened-core-schematic", 1 } })

	F.tech{ name = T[1], prerequisites = { "space-elevator-mining-module-mk3", "uv-machines", "naquadah-fuel-refinery",
		"precise-electronic-unit-mk2" }, packs = 11, count = 50, time = 60, recipes = R[1] }   -- (as the mining module Mk-III)
	F.tech{ name = T[2], prerequisites = { T[1] }, packs = 11, count = 50, time = 60, recipes = R[2] }
	F.tech{ name = T[3], prerequisites = { T[2], "precise-electronic-unit-mk3" }, packs = 11, count = 50, time = 60, recipes = R[3] }
	F.tech{ name = T[4], prerequisites = { T[3], "nano-forge", "yocto-power-ics" }, packs = 15, count = 55, time = 60,
		recipes = R[4] }   -- (the sunnarium and the irradiant uranium of section 37)
end


--------------------------------------------------------------------------------
--- 41) THE CHAOTIC CORE AND THE DRACONIC REACTOR STABILIZER (issue #489 part 2; the maintainer's decisions of 2026-10-22).
---   GT5-Unofficial ce1c416a64 (kubatech, tectech), NewHorizonsCoreMod (NHC: ScriptDraconicEvolution, ScriptEnderIO) and
---   Draconic Evolution (GTNH's fork 9f42531).
--- * Chaos Shards: the Chaos Guardian in the Extreme Entity Crusher (the maintainer's decision, as the Ender Dragon of
---   section 35). In Draconic Evolution the guardian lives on its Chaos Island and is not summoned (no ingredient here);
---   once it is dead, its Chaos Crystal can be broken and drops 5 shards (ChaosCrystal.java:77). It has 2000 health
---   (EntityChaosGuardian.java:117), ten times the dragon's: 1200 s for the dragon's 120 s. NHC's forge hammer steps
---   (ScriptDraconicEvolution.java: HV; a shard -> 9 large, 5 s; a large -> 9 small, 2.5 s; a small -> 9 tiny chaos
---   fragments, 1.25 s).
--- * The Chaotic Core (kubatech DEFCRecipes.java:230-243: 16 awakened draconium and 4 black plutonium plates, 4 awakened
---   cores, 2 large chaos fragments, 1440 L spacetime; UIV, 160 s, tier 4) and its schematic (tectech
---   ResearchStationAssemblyLine.java:1020-1035: 8 awakened cores, 4 dense awakened draconium plates, a spacetime plate, a
---   UMV circuit, 14 400 L spacetime, 230 400 L void; UMV, 3 min); the Awakened Draconium Fusion Casing
---   (DEFCRecipes.java:106-115: a Wyvern Fusion Casing, 6 dense awakened draconium plates, 3 awakened cores, 9216 L void;
---   UEV) and the crafter's tier 4 (the tier 3 one, 32 of these casings, 32 MK II fusion machine casings
---   (MTEDEFusionCrafter.java:139) and a UIV energy hatch). The Chaotic Fusion Casing (tier 5) has no recipe of tier 5 to
---   run and is left out.
--- * The Reactor Stabilizer and its parts (ScriptDraconicEvolution.java:691-818, Avaritia's extreme table: the assembler of
---   the tier of their cores, 20 s, as 120's crafting storages): Wyvern and Draconic Flux Capacitors (:175-196, :369-390),
---   the Reactor Stabilizer Inner and Outer Rotor, Rotor Assembly, Focus Ring and Frame; EnderIO's Vibrant Capacitor Bank
---   (ScriptEnderIO.java:389-399: 4 octadic capacitors, an HV circuit, 2 vibrant crystals, a machine chassis, an EV battery;
---   the HV assembler, 5 s, as section 39's energy cells), the Nether Star Lens (155's route for lenses, plate_lens: the
---   dust in the LV compressor, the plate in the MV lathe; here, because the nether star dust comes after 155).
--- * Named stand-ins: the mod's UHV superconductive wire (triamerotronium) for GT's UHV superconductor, 2 for a 2x and 4 for
---   a 4x wire; the dense draconium plate for Draconic Evolution's Charged Draconium Block (charged in the world, without a
---   recipe); the large lithium battery for GT's EV battery hull; molten neutronium for molten void metal (section 40).
--- * The Singularity crafting storage (SAE2:618-649) takes its 8 Reactor Stabilizers now.
--- Technologies: Chaotic Cores (the crusher, the fragments, the casing and tier 4, the core and its schematic) after Awakened
--- Cores; Draconic Reactor Stabilizer (the capacitors, the parts, the stabilizer) at MAX after it, Draconic Energy Cores and
--- Large Batteries (the battery of the capacitor bank);
--- ME Crafting Storage Singularity after it.
--------------------------------------------------------------------------------
do
	local DEFC = "draconic-evolution-fusion-crafter"
	local T_CHAOS, T_STAB, CRAFT = "chaotic-cores", "draconic-reactor-stabilizer", "me-crafting-storage-singularity"
	local RK, RS = {}, {}
	local VOID = "molten-neutronium"
	local SC = "triamerotronium-superconductive-wire"
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	local function power(tier, n)
		local p = data.raw["assembling-machine"][tier .. "-centrifuge"].energy_usage
		return (tonumber(p:match("^[%d.]+")) * n) .. p:match("%a+$")
	end
	items(SUB_PART, { "chaos-shard", "large-chaos-fragment", "small-chaos-fragment", "tiny-chaos-fragment", "chaotic-core",
		"chaotic-core-schematic", "wyvern-flux-capacitor", "draconic-flux-capacitor", "vibrant-capacitor-bank",
		"reactor-stabilizer-inner-rotor", "reactor-stabilizer-outer-rotor", "reactor-stabilizer-rotor-assembly",
		"reactor-stabilizer-focus-ring", "reactor-stabilizer-frame", "draconic-reactor-stabilizer" })
	items("subgroup-uhv-age-multiblocks", { "awakened-draconium-fusion-casing" })

	--- the chaos shards and fragments
	step(RK, "crushing-the-chaos-guardian", "ev-extreme-entity-crusher-recipes", 1200, 1, {}, { { "chaos-shard", 5 } })
	data.raw.recipe["crushing-the-chaos-guardian"].auto_recycle = false   -- (as the dragon's, Task-Ingame #477)
	data.raw.item["chaos-shard"].auto_recycle = false
	FORK_RECYCLING_BLACKLIST["chaos-shard"] = "the Chaos Guardian's drop: GT does not recycle it"
	step(RK, "large-chaos-fragment", "lv-forge-hammer-recipes", 5, HV_SPEED, { { "chaos-shard", 1 } }, { { "large-chaos-fragment", 9 } })
	step(RK, "small-chaos-fragment", "lv-forge-hammer-recipes", 2.5, HV_SPEED, { { "large-chaos-fragment", 1 } },
		{ { "small-chaos-fragment", 9 } })
	step(RK, "tiny-chaos-fragment", "lv-forge-hammer-recipes", 1.25, HV_SPEED, { { "small-chaos-fragment", 1 } },
		{ { "tiny-chaos-fragment", 9 } })

	--- the casing, tier 4, the chaotic core and its schematic
	step(RK, "awakened-draconium-fusion-casing", "uev-assembling-machine-recipes", 30, UEV_SPEED,
		{ { "wyvern-fusion-casing", 1 }, { "dense-awakened-draconium-plate", 6 }, { "awakened-core", 3 }, { VOID, 921.6 } },
		{ { "awakened-draconium-fusion-casing", 1 } })
	local cats = table.deepcopy(data.raw["assembling-machine"][DEFC .. "-t3"].crafting_categories)
	cats[#cats + 1] = DEFC .. "-t4-recipes"
	machine{
		name = DEFC .. "-t4", category = DEFC .. "-t4-recipes", speed = UIV_SPEED, energy = power("uiv", 1),
		subgroup = "subgroup-uhv-age-multiblocks", ports = { port("input", N, { 0, -1 }) }, list = RK,
		recipe = { "crafting-or-assembling-recipes", 1, { item(DEFC .. "-t3", 1), item("awakened-draconium-fusion-casing", 32),
			item("fusion-machine-casing-mk2", 32), item("uiv-energy-hatch", 1) } },
	}
	data.raw["assembling-machine"][DEFC .. "-t4"].crafting_categories = cats
	FORK_RECYCLING_BLACKLIST[DEFC .. "-t4"] = "the crafter's structure; GT recycles the controller"
	step(RK, "chaotic-core", DEFC .. "-t4-recipes", 160, UIV_SPEED,
		{ { "awakened-draconium-plate", 16 }, { "black-plutonium-plate", 4 }, { "awakened-core", 4 }, { "large-chaos-fragment", 2 },
			{ "chaotic-core-schematic", 1 }, { "molten-spacetime", 144 } }, { { "chaotic-core", 1 }, { "chaotic-core-schematic", 1 } },
		"chaotic-core")
	step(RK, "chaotic-core-schematic", "zpm-assembly-line-recipes", 180, UMV_SPEED,
		{ { "awakened-core", 8 }, { "dense-awakened-draconium-plate", 4 }, { "spacetime-plate", 1 }, { "umv-circuit", 1 },
			{ "molten-spacetime", 1440 }, { VOID, 23040 } }, { { "chaotic-core-schematic", 1 } })

	--- the flux capacitors
	step(RS, "vibrant-capacitor-bank", "hv-assembling-machine-recipes", 5, HV_SPEED,
		{ { "octadic-capacitor", 4 }, { "processing-unit", 1 }, { "vibrant-crystal", 2 }, { "machine-chassis", 1 },
			{ "large-lithium-battery", 1 } }, { { "vibrant-capacitor-bank", 1 } })
	step(RS, "wyvern-flux-capacitor", "uhv-assembling-machine-recipes", 20, UHV_SPEED,
		{ { "draconium-plate", 12 }, { SC, 16 }, { "wyvern-energy-core", 4 }, { "vibrant-capacitor-bank", 4 }, { "wyvern-core", 1 } },
		{ { "wyvern-flux-capacitor", 1 } })
	step(RS, "draconic-flux-capacitor", "uev-assembling-machine-recipes", 20, UEV_SPEED,
		{ { "awakened-draconium-plate", 12 }, { SC, 32 }, { "awakened-core", 1 }, { "enriched-naquadria-sunnarium-alloy", 4 },
			{ "draconic-energy-core", 3 }, { "wyvern-flux-capacitor", 1 } }, { { "draconic-flux-capacitor", 1 } })

	--- the stabilizer's parts and the stabilizer
	items(data.raw.item["ruby-lens"].subgroup, { "nether-star-plate", "nether-star-lens" })
	step(RS, "nether-star-plate", "lv-compressor-recipes", 15, LV_SPEED, { { "nether-star-dust", 1 } }, { { "nether-star-plate", 1 } })
	local lens = { { "nether-star-lens", 1 } }
	if data.raw.item["small-pile-of-nether-star-dust"] then lens[2] = { "small-pile-of-nether-star-dust", 1 } end
	step(RS, "nether-star-lens", "mv-lathe-recipes", 60, MV_SPEED, { { "nether-star-plate", 1 } }, lens, "nether-star-lens")
	step(RS, "reactor-stabilizer-outer-rotor", "uv-assembling-machine-recipes", 20, UV_SPEED,
		{ { "draconium-plate", 4 }, { "engraved-diamond-crystal-chip", 15 }, { "draconic-core", 2 } },
		{ { "reactor-stabilizer-outer-rotor", 1 } })
	step(RS, "reactor-stabilizer-inner-rotor", "uhv-assembling-machine-recipes", 20, UHV_SPEED,
		{ { "awakened-draconium-plate", 4 }, { "engraved-energy-chip", 15 }, { "wyvern-core", 2 } },
		{ { "reactor-stabilizer-inner-rotor", 1 } })
	step(RS, "reactor-stabilizer-rotor-assembly", "uhv-assembling-machine-recipes", 20, UHV_SPEED,
		{ { "long-draconium-rod", 6 }, { "reactor-stabilizer-outer-rotor", 10 }, { "reactor-stabilizer-inner-rotor", 10 },
			{ "dense-draconium-plate", 1 }, { "fusion-coil-block", 4 }, { "wyvern-core", 1 }, { "draconium-plate", 1 } },
		{ { "reactor-stabilizer-rotor-assembly", 1 } })
	step(RS, "reactor-stabilizer-focus-ring", "uhv-assembling-machine-recipes", 20, UHV_SPEED,
		{ { "rose-gold-rod", 20 }, { "reactor-stabilizer-outer-rotor", 4 }, { "wyvern-core", 4 },
			{ "reactor-stabilizer-inner-rotor", 4 }, { "nether-star-lens", 4 }, { "diamond-lens", 1 } },
		{ { "reactor-stabilizer-focus-ring", 1 } })
	step(RS, "reactor-stabilizer-frame", "uev-assembling-machine-recipes", 20, UEV_SPEED,
		{ { "black-plutonium-plate", 52 }, { "awakened-draconium-plate", 8 }, { "awakened-core", 1 } },
		{ { "reactor-stabilizer-frame", 1 } })
	step(RS, "draconic-reactor-stabilizer", "uiv-assembling-machine-recipes", 20, UIV_SPEED,
		{ { "black-plutonium-plate", 4 }, { "awakened-draconium-plate", 17 }, { "engraved-manyullyn-crystal-chip", 4 },
			{ "draconic-flux-capacitor", 4 }, { "reactor-stabilizer-frame", 1 }, { "chaotic-core", 2 },
			{ "reactor-stabilizer-focus-ring", 1 }, { "block-of-cosmic-neutronium", 1 }, { "reactor-stabilizer-rotor-assembly", 1 } },
		{ { "draconic-reactor-stabilizer", 1 } })

	F.tech{ name = T_CHAOS, prerequisites = { "awakened-cores" }, packs = 13, count = 95, time = 60, recipes = RK }
	F.tech{ name = T_STAB, prerequisites = { T_CHAOS, "draconic-energy-cores", "large-batteries" }, packs = 15, count = 55, time = 60,
		recipes = RS }   -- (as section 39)
	local storage = data.raw.recipe["me-singularity-crafting-storage"]
	if storage and data.raw.technology[CRAFT] then
		table.insert(storage.ingredients, item("draconic-reactor-stabilizer", 8))
		table.insert(data.raw.technology[CRAFT].prerequisites, T_STAB)
	end
end


--------------------------------------------------------------------------------
--- 38) GT'S PARTS OF THE METALS OF THIS FILE (issue #467). 158 makes GT New Horizons' parts of every metal of
---   prototypes/gt-parts-data.lua (issue #227) whose ingot exists; most metals of this file come after 158, so its
---   FORK_GT_PARTS.run() runs once more here (it skips what exists), then 143's casts for the new forms.
--------------------------------------------------------------------------------
FORK_GT_PARTS.run()
FORK_CASTING.run()
FORK_GT_PARTS.log("164")
