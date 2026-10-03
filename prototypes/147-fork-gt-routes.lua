--------------------------------------------------------------------------------
--- FORK GT ROUTES (issue #98): the leftovers of the recipe audit (#91), as GregTech New Horizons has them
---   1) the PECA board deleted (GT has no polyethylcyanoacrylate; its plastic boards stop at polybenzimidazole, 8
---      boards), the printed board at GT's 40 s and GT's second printed board with sodium persulfate
---   2) black plutonium and cosmic neutronium dust (microminer missions) through GT's blast furnace and vacuum
---      freezer; the black plutonium melt and casts are made by 143 (MATERIALS), the cosmic neutronium ingot exists
---   3) the high octane gasoline line (hydrocracked light fuel, octane, nitrous oxide, anti-knock agent) with its cell
---   4) GT's deuterium from hydrogen instead of upstream's water recipe; exhausted water, butyraldehyde and imaginary
---      time deleted (FORK-REMOVED in the log); molten sunnarium gets GT's PPIC wafer
--- Amounts: fluids at a tenth of GT's litres (14.4 per ingot), items as in GT, time: GT's seconds times the speed of
--- the recipe's tier (a machine of a tier crafts at its tier's speed). Source of every recipe: next to it.
--- Loaded after 138 and before 142, whose UNLOCKS table (block "issue #98") unlocks the recipes made here, and
--- before 143 (MATERIALS needs the black plutonium ingot).
--------------------------------------------------------------------------------

local F = FORK5B

local function remove(kind, name)
	if data.raw[kind][name] then
		data.raw[kind][name] = nil
		log("FORK-REMOVED: " .. kind .. " " .. name)
	end
end
local function remove_fluid(name)
	remove("fluid", name)
	remove("recipe", "void-" .. name)   -- data.lua makes a voiding recipe for every fluid
end



--------------------------------------------------------------------------------
--- 1) PLASTIC CIRCUIT BOARDS (NH gthandler/recipes/ChemicalReactorRecipes.java:84-127)
--- The plastic boards: polyethylene 1, PVC 2, PTFE 4, polybenzimidazole 8 (:85-111), all as GT has them in
--- 13-mv-age-item.lua. The upstream PECA board (16 boards, its sheet commented out) has no GT counterpart.
--------------------------------------------------------------------------------

remove("recipe", "plastic-circuit-board-peca")

--- printed board: 1 board + 6 copper foil + 250 L iron(III) chloride, LV, 40 s (:113-119)
data.raw.recipe["plastic-printed-circuit-board"].energy_required = 40
--- and with 500 L sodium persulfate (:121-127)
create_recipe{
	name = "plastic-printed-circuit-board-sodium-persulfate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "plastic-circuit-board", amount = 1 },
		{ type = "item", name = "copper-foil", amount = 6 },
		{ type = "fluid", name = "sodium-persulfate", amount = 50 },
	},
	results = { { type = "item", name = "plastic-printed-circuit-board", amount = 1 } },
	main_product = "plastic-printed-circuit-board",
}
--- sodium persulfate: electrolysis of sodium bisulfate, 14 dust -> 1000 L + 2000 L hydrogen, LV, 30 s
--- (GT ElectrolyzerRecipes.java:797-805); sodium bisulfate: 2 salt + 1000 L sulfuric acid -> 7 + 1000 L HCl, or
--- 3 sodium hydroxide + 1000 L sulfuric acid -> 7 + 1000 L water, LV, 3 s (GT ChemicalRecipes.java:3380-3400)
F.fluid("sodium-persulfate", "nearly-white-fluid", { 0.85, 0.90, 0.95 })
create_item{ skip_recipe = true, name = "sodium-bisulfate", subgroup = "subgroup-lv-chemical-reactor-recipes" }
create_recipe{
	name = "sodium-persulfate",
	category = "lv-electrolyzer-recipes",
	energy_required = 30,
	ingredients = { { type = "item", name = "sodium-bisulfate", amount = 14 } },
	results = {
		{ type = "fluid", name = "sodium-persulfate", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 200 },
	},
	main_product = "sodium-persulfate",
}
create_recipe{
	name = "sodium-bisulfate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "salt", amount = 2 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	results = {
		{ type = "item", name = "sodium-bisulfate", amount = 7 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	},
	main_product = "sodium-bisulfate",
}
create_recipe{
	name = "sodium-bisulfate-from-sodium-hydroxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	results = {
		{ type = "item", name = "sodium-bisulfate", amount = 7 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "sodium-bisulfate",
}



--------------------------------------------------------------------------------
--- 2) BLACK PLUTONIUM AND COSMIC NEUTRONIUM: BLAST FURNACE AND VACUUM FREEZER
--- NH BlastFurnaceRecipes.java: black plutonium :377-380 (ZPM, 9000 K, 300 s, 1000 L gas, also without gas at
--- 1.25 times the time), cosmic neutronium :703-706 (ZPM, 9900 K, 570 s, gas only). GT makes one recipe per blast
--- furnace gas (GTRecipeConstants.java:670-721, BlastFurnaceGasStat.java:13-21: time and gas factor per gas).
--- NH VacuumFreezerRecipes.java: hot black plutonium ingot :164-166 (ZPM, 14.7 s), hot cosmic neutronium ingot
--- :35-38 (ZPM, 55 s), no coolant. GT's other uses: black plutonium's compressed plates go into the heavy duty alloy
--- ingot T8 (NH AssemblingLineRecipes.java:128-137), which Gregtorio does not have; cosmic neutronium dust goes into
--- the UHV superconductor base (NH MixerRecipes.java:510-518) with draconium, tritanium and americium dust, which
--- Gregtorio does not have either (its UHV base, triamerotronium, is mixed from ingots).
--------------------------------------------------------------------------------

local GASES = {   -- gas, time factor, gas factor (BlastFurnaceGasStat.java); oganesson: not in Gregtorio
	{ "nitrogen", 1.0, 1.0 }, { "helium", 0.9, 1.0 }, { "argon", 0.8, 0.85 }, { "radon", 0.7, 0.7 },
	{ "neon", 0.6, 0.55 }, { "krypton", 0.5, 0.4 }, { "xenon", 0.4, 0.25 },
}
--- the recipes of a blast furnace ingot: base (the name of the hot ingot) without gas or, without `no_gas`, with
--- nitrogen; the other gases get "-<gas>"
local function ebf(material, tier, speed, time, no_gas)
	local hot = "hot-" .. material .. "-ingot"
	local dust = { type = "item", name = material .. "-dust", amount = 1 }
	local names = {}
	if not data.raw.item[hot] then
		create_item{ skip_recipe = true, name = hot, subgroup = "subgroup-" .. tier .. "-electric-blast-furnace-recipes" }
	end
	local function recipe(name, seconds, gas)
		create_recipe{
			name = name,
			category = tier .. "-electric-blast-furnace-recipes",
			energy_required = seconds * speed,
			ingredients = gas and { dust, gas } or { dust },
			results = { { type = "item", name = hot, amount = 1 } },
			main_product = hot,
		}
		if gas then
			data.raw.recipe[name].localised_name = { "recipe-name.fork-with-gas", { "item-name." .. hot },
				{ "fluid-name." .. gas.name } }
		end
		names[#names + 1] = name
	end
	if no_gas then recipe(hot, time * 1.25) end
	for _, g in pairs(GASES) do
		local name = (g[1] == "nitrogen" and not no_gas) and hot or (hot .. "-" .. g[1])
		recipe(name, time * g[2], { type = "fluid", name = g[1], amount = 100 * g[3] })
	end
	return names
end
local function freezer(material, recipe_name, tier, speed, time)
	create_recipe{
		name = recipe_name,
		category = tier .. "-vacuum-freezer-recipes",
		energy_required = time * speed,
		ingredients = { { type = "item", name = "hot-" .. material .. "-ingot", amount = 1 } },
		results = { { type = "item", name = material .. "-ingot", amount = 1 } },
		main_product = material .. "-ingot",
	}
end

create_item{ skip_recipe = true, name = "black-plutonium-ingot", subgroup = "subgroup-zpm-vacuum-freezer-recipes" }
FORK_GT_ROUTES = { black_plutonium = ebf("black-plutonium", "zpm", ZPM_SPEED, 300, true) }
freezer("black-plutonium", "black-plutonium-ingot", "zpm", ZPM_SPEED, 14.7)
FORK_GT_ROUTES.cosmic_neutronium = ebf("cosmic-neutronium", "zpm", ZPM_SPEED, 570)
freezer("cosmic-neutronium", "cosmic-neutronium-ingot-from-hot-ingot", "zpm", ZPM_SPEED, 55)



--------------------------------------------------------------------------------
--- 3) HIGH OCTANE GASOLINE (GT ChemicalRecipes.java:5794-5805, large chemical reactor, EV, 2.5 s):
--- 20000 L gasoline + 2000 L octane + 6000 L nitrous oxide + 1000 L toluene + 3000 L anti-knock agent -> 32000 L
---   octane: light fuel hydrocracked with hydrogen (GTProxy.java:1474-1535; lightly: 1000 L + 1600 L hydrogen,
---     cracking unit, HV, 1 s, :1499-1505), distilled (DistilleryRecipes.java:1102-1109, MV, 6 s): naphtha 800,
---     octane 100, butane 150, propane 200, ethane 125, methane 125 per 1000 L (butane: not in Gregtorio, left out)
---   nitrous oxide: 2000 L nitrogen + 1000 L oxygen -> 1000 L (ChemicalRecipes.java:4564-4607, LV, 10 s)
---   anti-knock agent: 1000 L ethanol + 1000 L butene -> 1000 L (ChemicalRecipes.java:4611-4616, HV, 20 s)
--- GT's fuel values (EU per litre, MaterialsInit.java): gasoline 576, high octane gasoline 2500 (both combustion
--- generator). Gregtorio's gasoline cell (144) holds 800 for 230.4 MJ, so the high octane cell: 1000 MJ.
--- The recipe has five fluid inputs, the large chemical reactor four: the EV and higher large chemical reactors get a
--- fifth input in the middle of the north side (GT's multiblock takes as many hatches as it needs).
--------------------------------------------------------------------------------

F.fluid("hydrocracked-light-fuel", "light-fuel", { 0.90, 0.90, 0.30 })
F.fluid("octane", "light-fuel", { 0.95, 0.85, 0.55 })
F.fluid("nitrous-oxide", "spackled-light-blue-fluid", { 0.49, 0.78, 1.00 })
F.fluid("anti-knock-agent", "light-pink-fluid", { 0.95, 0.75, 0.55 })
create_recipe{
	name = "hydrocracked-light-fuel",
	category = "hv-cracker-recipes",
	energy_required = 1 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "light-fuel", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 160 },
	},
	results = { { type = "fluid", name = "hydrocracked-light-fuel", amount = 100 } },
}
create_recipe{
	name = "distilling-hydrocracked-light-fuel",
	category = "mv-tall-distillation-recipes",
	energy_required = 6 * MV_SPEED,
	ingredients = { { type = "fluid", name = "hydrocracked-light-fuel", amount = 100 } },
	results = {
		{ type = "fluid", name = "naphtha", amount = 80 },
		{ type = "fluid", name = "octane", amount = 10 },
		{ type = "fluid", name = "propane", amount = 20 },
		{ type = "fluid", name = "ethane", amount = 12.5 },
		{ type = "fluid", name = "methane", amount = 12.5 },
	},
	main_product = "octane",
}
create_recipe{
	name = "nitrous-oxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "fluid", name = "nitrogen", amount = 200 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	results = { { type = "fluid", name = "nitrous-oxide", amount = 100 } },
}
create_recipe{
	name = "anti-knock-agent",
	category = "hv-chemical-reactor-recipes",
	energy_required = 20 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "ethanol", amount = 100 },
		{ type = "fluid", name = "butene", amount = 100 },
	},
	results = { { type = "fluid", name = "anti-knock-agent", amount = 100 } },
}
create_recipe{
	name = "high-octane-gasoline",
	category = "ev-chemical-reactor-recipes",
	energy_required = 2.5 * EV_SPEED,
	ingredients = {
		{ type = "fluid", name = "gasoline", amount = 2000 },
		{ type = "fluid", name = "octane", amount = 200 },
		{ type = "fluid", name = "nitrous-oxide", amount = 600 },
		{ type = "fluid", name = "toluene", amount = 100 },
		{ type = "fluid", name = "anti-knock-agent", amount = 300 },
	},
	results = { { type = "fluid", name = "high-octane-gasoline", amount = 3200 } },
}
create_item{
	name = "high-octane-gasoline-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "1000MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	subgroup = data.raw.item["diesel-cell"] and data.raw.item["diesel-cell"].subgroup or nil,
	ingredients = {
		{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
		{ type = "fluid", name = "high-octane-gasoline", amount = 800 },
	},
}
for _, tier in pairs({ "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }) do
	local m = data.raw["assembling-machine"][tier .. "-large-chemical-reactor"]
	if m and m.fluid_boxes then
		table.insert(m.fluid_boxes, fluid_port(0, -2, "input", defines.direction.north))
	end
end
--- the line is EV (the reactor recipe); its technology after the gasoline of cetane boosted diesel
F.tech{
	name = "high-octane-gasoline",
	prerequisites = { "cetane-boosted-diesel", "ev-machines" },
	packs = 5, count = 600, time = 45,
	recipes = {},
}



--------------------------------------------------------------------------------
--- 4) THE FLUIDS LEFT OVER
--- Deuterium: GT centrifuges it from hydrogen, 160 L -> 40 L, LV, 8 s (GT CentrifugeRecipes.java:504-509); upstream's
--- recipe of the same name (13-mv-age-item.lua: water -> deuterium and exhausted water, a fluid GT does not have)
--- becomes GT's, so its technology (microversium) and the machines that run it keep it.
--- Butyraldehyde (GT: from propene with an organorhodium catalyst, used only for butanol, ChemicalRecipes.java:
--- 3780-3789, 4795-4817, 5889-5896) and imaginary time (not in GT) had no producer and no use here: deleted.
--- Molten sunnarium (fusion MK1): GT's PPIC wafer, NPIC wafer + 64 indium gallium phosphide + 1440 L molten
--- sunnarium, ZPM chemical reactor, 60 s (NH ChemicalReactorRecipes.java:251-257), next to Gregtorio's laser
--- engraver recipe of 129.
--------------------------------------------------------------------------------

do
	local r = data.raw.recipe["deuterium"]
	r.category = "lv-centrifuge-recipes"
	r.energy_required = 8
	r.ingredients = { { type = "fluid", name = "hydrogen", amount = 16 } }
	r.results = { { type = "fluid", name = "deuterium", amount = 4 } }
	r.main_product = "deuterium"
end
remove_fluid("exhausted-water")
remove_fluid("butyraldehyde")
remove_fluid("imaginary-time")

create_recipe{
	name = "ppic-wafer-sunnarium",
	category = "zpm-chemical-reactor-recipes",
	energy_required = 60 * ZPM_SPEED,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "npic-wafer", amount = 1 },
		{ type = "item", name = "indium-gallium-phosphide", amount = 64 },
		{ type = "fluid", name = "molten-sunnarium", amount = 144 },
	},
	results = { { type = "item", name = "ppic-wafer", amount = 1 } },
	main_product = "ppic-wafer",
}
