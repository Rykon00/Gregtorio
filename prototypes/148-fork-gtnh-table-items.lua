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
---                          GT GTPostLoad.java:111: empty bucket + 1000 L, 16 ticks, 1 EU/t). Gregtorio has no canner and no water in the
---                          world: filling it by hand (manual labor) is the stand-in. Stays crafting table only.
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

--- Issue #126, part B (maintainer's decision): the vanilla recipes that only the character could make and that a player can
--- reach (firearm magazine, light armor, the elevated rail's ramp and support, Space Age's wood processing) become recipes
--- of the category `crafting-or-assembling-recipes`: the crafting table, the ME Molecular Assembler, every assembling machine
--- and the hand make them, as they do for 769 other recipes. GTNH has none of these items (no armor, magazines or elevated
--- rails of Factorio's), so there is no GTNH recipe to follow; this is the option "also craftable in the assembling machines"
--- of the issue, the one that automates them without inventing a tier or a recipe. The other 17 vanilla recipes of the issue's
--- 21 (equipment, modular, power and mech armor, spidertron) are behind technologies nobody can research and stay as they
--- are; devcheck fails for one of them once it becomes reachable.
for _, name in pairs({ "firearm-magazine", "light-armor", "rail-ramp", "rail-support", "wood-processing" }) do
	local r = data.raw.recipe[name]
	if r then
		r.category = "crafting-or-assembling-recipes"
		r.hide_from_player_crafting = nil
	end
end

FORK_RECIPES_TABLE_ONLY = {
	["bucket-of-water"] = "GTNH: filled in the world or in the fluid canner (GT GTPostLoad.java:111); Gregtorio has neither, filling it by hand is the stand-in",
	["liquid-concrete-bucket"] = "GTNH: crafting table only (NHC GT_CraftingRecipeLoader.java:1226)",
	["mortar-and-pestle"] = "GTNH: the mortar is a tool made at the crafting table, no machine recipe (GT ProcessingIngot.java:101 uses it as a crafting tool)",
	-- issue #193 (prototypes/155-fork-ore-chain.lua): the dark ash of the implosion compressor
	["dark-ash-dust-from-tiny-piles"] = "GTNH: 9 tiny piles and the dust schematic in the packager (GT ProcessingDust.java:593-600); Gregtorio has no packager, the crafting table is the stand-in",
}
