--------------------------------------------------------------------------------
--- FORK TABLE ITEMS (issue #126)
--- Gregtorio follows GregTech New Horizons: an item that only the crafting table (or the hand) can make is only
--- acceptable where GTNH makes it that way. A crafting table recipe in Gregtorio is automated by the ME Molecular
--- Assembler only, so for each such item the question is what GTNH does (sources next to each recipe; NHC =
--- NewHorizonsCoreMod 2.9.x, GT = GT5-Unofficial):
---
---   anvil                  crafting table (NHC ScriptMinecraft.java:962, the recipe Gregtorio has) AND machines: the
---                          fluid solidifier with the anvil mold, 4464 L molten iron, 128 ticks, 16 EU/t (GT
---                          FluidSolidifierRecipes.java:146), and the alloy smelter with the mold, 31 iron ingots, 512
---                          ticks, 60 EU/t (GT ProcessingShaping.java:440; iron: 4 x 15 EU/t). -> both machine recipes here
---   firebrick-block        GT's Casing_Firebricks: crafting table "BCB/BWB/BCB" with 6 firebricks, 2 gypsum, a
---                          concrete bucket (NHC GT_CraftingRecipeLoader.java:1214, the recipe Gregtorio has) AND the
---                          LV assembler: 24 firebricks, 8 gypsum dust, 4608 L concrete -> 4 casings, 10 s, 32 EU/t
---                          (NHC AssemblerRecipes.java:949). -> the assembler recipe here
---   paper                  GT removes the crafting recipe (GT CraftingRecipeLoader.java:1854) and makes paper in the
---                          chemical bath: wood dust (or paper dust, sugar cane) and 100 L water, 10 s, 4 EU/t (GT
---                          ChemicalBathRecipes.java:80); Gregtorio's wood pulp is GT's wood dust, it has no sugar cane
---                          or paper dust. The crafting table recipe stays as the early game stand-in (before the
---                          chemical bath). -> the chemical bath recipe here (the distilled water variant of GT is the
---                          same recipe with another fluid: not made)
---   bucket-of-water        GT/GTNH: filled in the world or in the fluid canner (every FluidContainerRegistry container,
---                          GT GTPostLoad.java:111: empty bucket + 1000 L, 16 ticks, 1 EU/t). Gregtorio's Canning Machine
---                          runs GT's canner map (docs/MACHINE-AUDIT.md: it fills the fluid cells), and the offshore pump
---                          gives water from the first technology on (issue #452). Filling it by hand (manual labor) stays
---                          the stand-in for filling it in the world. -> the canning machine recipe here
---   liquid-concrete-bucket GTNH: crafting table only, calcite, stone, clay, quartz sand dust, water bucket and empty
---                          bucket (NHC GT_CraftingRecipeLoader.java:1226); the fluid itself has its mixer recipe
---                          (liquid concrete). Stays crafting table only.
---
--- Amounts at a tenth of GT's litres, time x the recipe tier's speed (LV 1, MV 2).
---
--- FORK_RECIPES_TABLE_ONLY: the recipes of items that nothing but the crafting table, the ME Molecular Assembler or the hand
--- can make, each with its reason; devcheck fails for a reachable item whose every recipe is such a recipe and not in
--- this list, and for an entry that is not (or no longer) one. Loaded after 144 (the unlock technologies exist), before
--- 150 (the mold recipe of the alloy smelter).
--------------------------------------------------------------------------------

--- anvil: the fluid solidifier (the mold of the solidifier is the machine's mold slot, 150)
create_recipe{
	recipe_name = "anvil-fluid-solidifier",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 6.4 * LV_SPEED,
	ingredients = { { type = "fluid", name = "molten-iron", amount = 446.4 } },
	results = { { type = "item", name = "anvil", amount = 1 } },
	main_product = "anvil",
}
fork_add_unlock("concrete", "anvil-fluid-solidifier")

--- anvil: the alloy smelter with the mold (GT: 60 EU/t, so an MV machine)
create_recipe{
	recipe_name = "anvil-alloy-smelter",
	category = "mv-alloy-smelter-recipes",
	energy_required = 25.6 * MV_SPEED,
	ingredients = { { type = "item", name = "iron-ingot", amount = 31 }, { type = "item", name = "mold", amount = 1 } },
	results = { { type = "item", name = "anvil", amount = 1 }, { type = "item", name = "mold", amount = 1 } },
	main_product = "anvil",
}
fork_add_unlock("mv-machines", "anvil-alloy-smelter")

--- firebrick block: the LV assembler (GT: 24 firebricks, 8 gypsum dust, 4608 L concrete -> 4 casings)
create_recipe{
	recipe_name = "firebrick-block-assembling-machine",
	category = "lv-assembling-machine-recipes",
	energy_required = 10 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "firebrick", amount = 24 },
		{ type = "item", name = "gypsum", amount = 8 },
		{ type = "fluid", name = "liquid-concrete", amount = 460.8 },
	},
	results = { { type = "item", name = "firebrick-block", amount = 4 } },
	main_product = "firebrick-block",
}
fork_add_unlock("concrete", "firebrick-block-assembling-machine")

--- paper: the LV chemical bath (GT: wood dust and 100 L water, 10 s)
create_recipe{
	recipe_name = "paper-chemical-bath",
	category = "lv-chemical-bath-recipes",
	energy_required = 10 * LV_SPEED,
	ingredients = { { type = "item", name = "wood-pulp", amount = 1 }, { type = "fluid", name = "water", amount = 10 } },
	results = { { type = "item", name = "paper", amount = 1 } },
	main_product = "paper",
}
fork_add_unlock("chemical-reactor", "paper-chemical-bath")

--- bucket of water: the LV canning machine (GT: an empty bucket and 1000 L water, 16 ticks, 1 EU/t), with the canner
create_recipe{
	recipe_name = "bucket-of-water-canning-machine",
	category = "lv-canning-machine-recipes",
	energy_required = 0.8 * LV_SPEED,
	ingredients = { { type = "item", name = "empty-bucket", amount = 1 }, { type = "fluid", name = "water", amount = 100 } },
	results = { { type = "item", name = "bucket-of-water", amount = 1 } },
	main_product = "bucket-of-water",
}
fork_add_unlock("semifluid-generator", "bucket-of-water-canning-machine")

--- Issue #126, part B (maintainer's decision): the vanilla recipes that only the character could make and that a player can
--- reach (firearm magazine, light armor, the elevated rail's ramp and support, Space Age's tree seed (wood processing before Factorio 2.1)) become recipes
--- of the category `crafting-or-assembling-recipes`: the crafting table, the ME Molecular Assembler, every assembling machine
--- and the hand make them, as they do for 769 other recipes. GTNH has none of these items (no armor, magazines or elevated
--- rails of Factorio's), so there is no GTNH recipe to follow; this is the option "also craftable in the assembling machines"
--- of the issue, the one that automates them without inventing a tier or a recipe. The other 17 vanilla recipes of the issue's
--- 21 (equipment, modular, power and mech armor, spidertron) are behind technologies nobody can research and stay as they
--- are; devcheck fails for one of them once it becomes reachable.
for _, name in pairs({ "firearm-magazine", "light-armor", "rail-ramp", "rail-support", "tree-seed" }) do
	local r = data.raw.recipe[name]
	if r then
		fork_set_category(r, "crafting-or-assembling-recipes")
		r.hide_from_player_crafting = nil
	end
end

FORK_RECIPES_TABLE_ONLY = {
	["liquid-concrete-bucket"] = "GTNH: crafting table only (NHC GT_CraftingRecipeLoader.java:1226)",
	["mortar-and-pestle"] = "GTNH: the mortar is a tool made at the crafting table, no machine recipe (GT ProcessingIngot.java:101 uses it as a crafting tool)",
	-- (issue #223: dark ash dust has machine recipes since GT's raw iron blast furnace recipe, no entry needed)
	["ferrosilite-dust-from-small-piles"] = "GTNH: 4 small piles make a dust at the crafting table or in the packager (GT ProcessingDust.java:572-578); Gregtorio has no packager, and ferrosilite comes only as small piles of chalcopyrite's bricked blast furnace recipes (issue #373)",
}



--------------------------------------------------------------------------------
--- Issue #612 (the maintainer's decision of 2026-10-28): GT's crafting tools. GT New Horizons makes the early material
--- parts by hand with tools that wear out; the crafting table recipes of the parts take them as GT's shapes do
--- (gregtech/loaders/oreprocessing: ProcessingPlate.java:146-150 and 128-131 the hammer for plates and foil,
--- ProcessingStick.java:131-134 the file for rods, ProcessingBolt.java:37-40 the saw for bolts, ProcessingScrew.java:38-41
--- the file for screws, ProcessingShaping.java:326-331 hammer and file for rings, ProcessingWire.java:96-102 and
--- ProcessingFineWire.java:24-29 the wire cutter for wires, ProcessingGear.java:95-101 hammer and wire cutter for small
--- gears and :60-66 the wrench for gears, ProcessingRotor.java:38-46 hammer, file and screwdriver for rotors,
--- CraftingRecipeLoader.java:716-719 the knife for the rubber ring); the machines keep making them without tools.
--- A tool is GT's recipe (ProcessingToolHead.java:1103-1122 hammer, :535-548 file, :567-577 saw, ProcessingToolOther.java:
--- 48-80 wrench, screwdriver, wire cutter, knife; the wooden stick as GT's handle rod) and gives as many charges
--- (`<tool>-usage`, as the iron pickaxe's) as GT's tool has uses: 100 x the material's tool durability (MaterialsInit.java:
--- iron 256, bronze 192, steel 512; wrought iron has no parts here) / the damage of a crafting use (hammer, file,
--- screwdriver and wire cutter 400, saw 200, wrench 800, knife 100). Each material's tools come with the technology of
--- its first crafting table part, a tool needing a later part (bronze and steel screws) with that part's technology.
--------------------------------------------------------------------------------
do
	local DURABILITY = { iron = 256, bronze = 192, steel = 512 }
	local function rod(m) return m == "iron" and "iron-stick" or m .. "-rod" end
	local TOOLS = {
		--  tool           damage  parts of the material (ingot, plate, rod, screw)        other tools used up
		{ "hammer",        400, function(m) return { { m .. "-ingot", 6 }, { "stick", 1 } } end, {} },
		{ "file",          400, function(m) return { { m .. "-plate", 2 }, { "stick", 1 } } end, {} },
		{ "saw",           200, function(m) return { { m .. "-plate", 2 }, { "stick", 1 } } end, { "file", "hammer" } },
		{ "screwdriver",   400, function(m) return { { rod(m), 2 }, { "stick", 1 } } end, { "file", "hammer" } },
		{ "wire-cutter",   400, function(m) return { { m .. "-plate", 3 }, { rod(m), 2 }, { m .. "-screw", 1 } } end,
			{ "file", "hammer", "screwdriver" } },
		{ "wrench",        800, function(m) return { { m .. "-ingot", 6 } } end, { "hammer" } },
		{ "knife",         100, function(m) return { { m .. "-plate", 1 }, { rod(m), 1 } } end, { "file", "hammer" } },
	}
	--- the technologies that unlock each recipe, and the recipes that make each item
	local unlocked_by, made_by = {}, {}
	for name, t in pairs(data.raw.technology) do
		for _, e in pairs(t.effects or {}) do
			if e.type == "unlock-recipe" then unlocked_by[e.recipe] = unlocked_by[e.recipe] or name end
		end
	end
	for name, r in pairs(data.raw.recipe) do
		for _, res in pairs(r.results or {}) do
			made_by[res.name] = made_by[res.name] or {}
			table.insert(made_by[res.name], name)
		end
	end
	--- a material's tools: the technology of its plate's (else its rod's) crafting table recipe
	local TECH = {}
	for m in pairs(DURABILITY) do
		TECH[m] = unlocked_by[m .. "-plate-crafting-table"] or unlocked_by[m .. "-rod-crafting-table"]
	end
	--- a screw that comes later than the material's plates (bronze in MV, steel in HV): the screw's technology
	local function screw_tech(m)
		for _, r in pairs(made_by[m .. "-screw"] or {}) do
			if unlocked_by[r] then return unlocked_by[r] end
		end
	end
	FORK_TOOLS = {}
	for _, tool in ipairs(TOOLS) do
		local usage = tool[1] .. "-usage"
		FORK_TOOLS[tool[1]] = usage
		for _, m in ipairs({ "iron", "bronze", "steel" }) do
			local ingredients = {}
			for _, i in pairs(tool[3](m)) do ingredients[#ingredients + 1] = { type = "item", name = i[1], amount = i[2] } end
			for _, other in pairs(tool[4]) do ingredients[#ingredients + 1] = { type = "item", name = other .. "-usage", amount = 1 } end
			local recipe = usage .. "-" .. m
			local def = {
				name = data.raw.item[usage] and recipe or usage,
				recipe_name = recipe,
				subgroup = "subgroup-tool-recipes",
				order = "t[gt-tool]-" .. tool[1],
				stack_size = 100,
				ingredients = ingredients,
				results = { { type = "item", name = usage, amount = math.floor(100 * DURABILITY[m] / tool[2]) } },
				main_product = usage,
			}
			if data.raw.item[usage] then create_recipe(def) else create_item(def) end
			local tech = TECH[m]
			if tool[1] == "wire-cutter" and m ~= "iron" then tech = screw_tech(m) or tech end
			fork_add_unlock(tech, recipe)
		end
	end
	--- the crafting table recipes of the parts and the tools they use up
	local USES = {
		hammer = { "iron-plate-crafting-table", "copper-plate-crafting-table", "bronze-plate-crafting-table",
			"red-alloy-plate-crafting-table", "tin-plate-crafting-table", "copper-foil-crafting-table" },
		file = { "iron-rod-crafting-table", "steel-rod-crafting-table", "tin-rod-crafting-table", "iron-screw-crafting-table",
			"tin-screw-crafting-table" },
		saw = { "iron-bolt-crafting-table", "steel-bolt-crafting-table", "tin-bolt-crafting-table" },
		["wire-cutter"] = { "copper-wire-crafting-table", "red-alloy-wire-crafting-table", "tin-wire-crafting-table",
			"fine-copper-wire-crafting-table" },
		knife = { "rubber-ring-crafting-table" },
		wrench = { "large-steel-gear-crafting-table", "large-cobalt-brass-gear-crafting-table" },
	}
	for _, r in pairs({ "tin-ring-crafting-table", "bronze-ring-crafting-table" }) do
		table.insert(USES.hammer, r); table.insert(USES.file, r)
	end
	for _, r in pairs({ "iron-gear-crafting-table", "steel-gear-crafting-table", "aluminium-gear-crafting-table" }) do
		table.insert(USES.hammer, r); table.insert(USES["wire-cutter"], r)
	end
	for _, r in pairs({ "tin-rotor-crafting-table", "bronze-rotor-crafting-table" }) do
		table.insert(USES.hammer, r); table.insert(USES.file, r)
		USES.screwdriver = USES.screwdriver or {}
		table.insert(USES.screwdriver, r)
	end
	for tool, recipes in pairs(USES) do
		for _, name in pairs(recipes) do
			local r = data.raw.recipe[name]
			if r then
				table.insert(r.ingredients, { type = "item", name = tool .. "-usage", amount = 1 })
			else
				log("FORK-TOOLS: no recipe " .. name)
			end
		end
	end
end
