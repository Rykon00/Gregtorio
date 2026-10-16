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
		fuel_category = category,
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
--- mixer recipe of the Werkstoff: 11 thorium, 1 thorium 232, 1 uranium 235 and 3 carbon into 16, 2.35 s, LV; the mod
--- has no thorium isotopes, so 12 thorium dust), 64 of it with 4 tungstensteel foils into a wrapped thorium ingot (HV
--- assembler, 15 s), the implosion compressor (GT's 4 TNT: one explosive) into a high density thorium nugget and 8 tiny
--- tungstensteel dusts, 9 nuggets into high density thorium (MV compressor, 10 s), with 4 lithium, 2 draconium and 1000
--- mercury into 4000 thorium based liquid fuel (HV mixer, 150 s), excited with 250 helium plasma per 1000 (IV mixer, 6 s;
--- GT fills a cell). Fluids a tenth of GT's litres; the mod has no draconium dust (its ingot). GT burns the excited fuel
--- in the large naquadah reactor at 2200 EU/t for 500 ticks per L (GGConfigLoader.java:15-17), as 136 burns the uranium
--- and plutonium fuels; as there, no depleted fuel (its centrifuge gives GT's praseodymium, which waits for #356).
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
		{ type = "item", name = "thorium-dust", amount = 12 },
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
--- solidifier); the UMV and UXV hatches keep their APIC stand-ins of 133 and 134.
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
--- centrifuge of 8 depleted rods (the isotopes plutonium 238 and 241, uranium 232 and 233, thorium 232, krypton) is left
--- out: nothing in the mod takes the isotopes before the LFTR (issue #359's later steps). They come with Nuclear Fuel Rods,
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
	for _, r in pairs(results) do res[#res + 1] = { type = "item", name = r[1], amount = r[2], probability = r[3] } end
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
