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
		if r[3] then x.probability = r[3] end
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
		if r.category == "lv-assembling-machine-recipes" and out:match("%-cable$") and #r.results == 1 then
			local ing, found = table.deepcopy(r.ingredients), false
			for _, i in pairs(ing) do
				if i.name == "liquid-rubber" then i.name, i.amount, found = SBR, i.amount * 0.75, true
				elseif i.name == "silicone-rubber" then i.name, i.amount, found = SBR, i.amount * 1.5, true end
			end
			if found then
				local base = techs_of(name)[1]
				local tech = base == nil and SBR or after_both(SBR, base)
				if tech then
					create_recipe{ name = name .. "-sbr", category = r.category, energy_required = r.energy_required,
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
