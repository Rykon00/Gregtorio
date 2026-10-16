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
