--------------------------------------------------------------------------------
--- FORK RECIPE UNLOCKS (issue #91, part 1)
--- Upstream creates machine recipes disabled and leaves the unlock to a technology; 199-fork-finalize.lua only
--- pulls in what an unlocked recipe needs (FORK-AUTOUNLOCK). Everything else stayed locked for good: 331 Gregtorio
--- recipes (devcheck `check --balance-out` on main at 13a9245), 224 of them the only source of their product.
--- Here every one of them gets a technology, explicitly (no rule that guesses), the one of its tier where a player
--- looks for it: the technology of its material or its machine, the line it belongs to. devcheck fails on a
--- Gregtorio recipe that no researchable technology unlocks, unless it is in FORK_RECIPES_LOCKED below.
---
---   1) producers GregTech has and Gregtorio lacked, so that the unlocked recipes can be made: signalum ingot,
---      naquadah doped boule, charcoal byproducts, super glue (GT++'s glue line, condensed), the ender tanks of
---      the nether and ender air, the component assembly line, microminer missions for the ores of GT's space veins
---   2) two technologies: tier four microminers (the lunar mission) and super glue
---   3) the unlock table
---   4) the recipes that stay locked, with the reason
--- Amounts: fluids at Gregtorio's scale, a tenth of GregTech's (144 per ingot in GT, 14.4 here), items and times
--- as in GregTech. Loaded after 138 (no unit counts from UV up are set for the new technologies, both are IV) and
--- before 150 (molds) and 199 (the auto-unlock sees these recipes as unlocked and leaves them alone).
--------------------------------------------------------------------------------

local F = FORK5B
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"
local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"

--- the graphics of a machine from tools/gen_sprites.py: <name>-idle.png and <name>-working.png (a vertical strip of
--- `frames` frames, each `ticks` ticks long)
local function fork_sprites(name, w, h, frames, ticks)
	local function layer(file, n, repeats)
		return { layers = { { filename = SPRITE_PATH .. name .. file, width = w * 32, height = h * 32, frame_count = n,
			repeat_count = repeats, line_length = 1, animation_speed = 1 / ticks, shift = { 0, 0 } } } }
	end
	--- the idle animation needs the frame count of the working one
	return { idle_animation = layer("-idle.png", 1, frames > 1 and frames or nil), animation = layer("-working.png", frames) }
end



--------------------------------------------------------------------------------
--- 1) PRODUCERS
--------------------------------------------------------------------------------

--- Signalum (upstream: the ingot without a recipe, its plate, rod and the signalum microminer engine). GTNH makes it
--- in EnderIO's alloy smelter (config/enderio/AlloySmelterRecipes_Core.xml): 3 copper, 1 silver and 10 redstone ->
--- 4 ingots for 32000 RF; energetic alloy there costs 10000 RF and takes 20 s in Gregtorio's LV alloy smelter.
create_recipe{
	name = "signalum-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 64,
	ingredients = {
		{ type = "item", name = "copper-ingot", amount = 3 },
		{ type = "item", name = "silver-ingot", amount = 1 },
		{ type = "item", name = "redstone-dust", amount = 10 },
	},
	results = { { type = "item", name = "signalum-ingot", amount = 4 } },
}

--- Naquadah doped boule (upstream: the item without a recipe, its wafer and the -nd wafer variants). GT: EBF, EV,
--- 4484 K, 16 silicon blocks, a gallium arsenide crystal and a naquadah ingot, 12.5 minutes: half the europium boule
--- of GT. Gregtorio's europium boule (129-fork-water-purification.lua) takes 64 poly-si dust, 8 europium ingots,
--- 2 small piles of gallium arsenide and 800 nitrogen; this one takes half its europium in naquadah.
create_recipe{
	name = "naquadah-doped-monocrystaline-silicon-boule",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = 50 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 64 },
		{ type = "item", name = "naquadah-ingot", amount = 4 },
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 2 },
		{ type = "fluid", name = "nitrogen", amount = 800 },
	},
	results = { { type = "item", name = "naquadah-doped-monocrystaline-silicon-boule", amount = 1 } },
}

--- Charcoal byproducts (upstream: its distillation, nothing made it). GT's pyrolyse oven (PyrolyseRecipes.java,
--- circuit 4): 16 logs and 1000 nitrogen -> 20 charcoal and 4000 charcoal byproducts in 16 s. At the scale of
--- Gregtorio's wood tar recipe (16 wood, 100 nitrogen -> 20 charcoal, 150 wood tar; GT: 1500) that is 400. The
--- distillation (19-iv-age-item.lua) keeps GT's 1000 per run, as upstream has it.
create_recipe{
	name = "charcoal-byproducts",
	category = "pyrolyse-oven-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "wood", amount = 16 },
		{ type = "fluid", name = "nitrogen", amount = 100 },
	},
	results = {
		{ type = "item", name = "charcoal", amount = 20 },
		{ type = "fluid", name = "charcoal-byproducts", amount = 400 },
	},
	main_product = "charcoal-byproducts",
}

--- Super glue, ethyl cyanoacrylate (upstream: the fluid, used by the graphene recipes with europium and americium
--- wafers, nothing made it). GT++'s glue line (RecipeLoaderGlueLine.java) has ten steps in the chemical plant with
--- three catalysts; the same chemistry in four intermediates here, without the catalysts:
---   formaldehyde: methanol + oxygen (GT: MV, 32000 each in 90 s)
---   hydrogen cyanide: methane + ammonia + oxygen -> HCN + water (GT: HV, 10 s)
---   sodium cyanide: sodium hydroxide + HCN (GT: LV chemical reactor, 10 s)
---   chloroacetic acid: acetic acid + chlorine -> chloroacetic acid + HCl; GT chlorinates with acetic anhydride
---     into a mixture, distills it and mixes the di- and trichloroacetic acid back (EV, 150 s per 1000)
---   cyanoacetic acid: sodium carbonate, sodium cyanide, chloroacetic acid and HCl (GT: EV, 20 s)
---   ethyl cyanoacetate: cyanoacetic acid + ethanol (GT: IV, 1000 s)
---   super glue: ethyl cyanoacetate + formaldehyde, polymerised and cracked (GT: IV chemical plant 10 s and HV fluid
---     heater 45 s; GT's 1000 water per 100 polymer is kept)
F.fluid("formaldehyde", "nearly-white-fluid", { 0.85, 0.88, 0.80 })
F.fluid("hydrogen-cyanide", "spackled-light-blue-fluid", { 0.70, 0.85, 0.90 })
F.fluid("chloroacetic-acid", "pale-green-fluid", { 0.75, 0.85, 0.55 })
F.fluid("ethyl-cyanoacetate", "light-pink-fluid", { 0.85, 0.65, 0.65 })
create_item{ skip_recipe = true, name = "sodium-cyanide", subgroup = "subgroup-lv-chemical-reactor-recipes" }
create_item{ skip_recipe = true, name = "cyanoacetic-acid", subgroup = "subgroup-ev-chemical-reactor-recipes" }
local function glue_step(name, category, time, ingredients, results, main)
	create_recipe{ name = name, category = category, energy_required = time, ingredients = ingredients,
		results = results, main_product = main or name }
end
glue_step("formaldehyde", "mv-chemical-reactor-recipes", 2.8, {
	{ type = "fluid", name = "methanol", amount = 100 },
	{ type = "fluid", name = "oxygen", amount = 100 },
}, { { type = "fluid", name = "formaldehyde", amount = 100 } })
glue_step("hydrogen-cyanide", "hv-chemical-reactor-recipes", 10, {
	{ type = "fluid", name = "methane", amount = 200 },
	{ type = "fluid", name = "ammonia", amount = 200 },
	{ type = "fluid", name = "oxygen", amount = 600 },
}, {
	{ type = "fluid", name = "hydrogen-cyanide", amount = 200 },
	{ type = "fluid", name = "water", amount = 600 },
})
glue_step("sodium-cyanide", "lv-chemical-reactor-recipes", 10, {
	{ type = "item", name = "sodium-hydroxide", amount = 3 },
	{ type = "fluid", name = "hydrogen-cyanide", amount = 100 },
}, {
	{ type = "item", name = "sodium-cyanide", amount = 3 },
	{ type = "fluid", name = "water", amount = 100 },
})
glue_step("chloroacetic-acid", "ev-chemical-reactor-recipes", 150, {
	{ type = "fluid", name = "acetic-acid", amount = 100 },
	{ type = "fluid", name = "chlorine", amount = 100 },
}, {
	{ type = "fluid", name = "chloroacetic-acid", amount = 100 },
	{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
})
glue_step("cyanoacetic-acid", "ev-chemical-reactor-recipes", 20, {
	{ type = "item", name = "sodium-carbonate", amount = 6 },
	{ type = "item", name = "sodium-cyanide", amount = 3 },
	{ type = "fluid", name = "chloroacetic-acid", amount = 100 },
	{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
}, {
	{ type = "item", name = "cyanoacetic-acid", amount = 9 },
	{ type = "item", name = "salt", amount = 6 },
	{ type = "fluid", name = "carbon-dioxide", amount = 100 },
	{ type = "fluid", name = "water", amount = 100 },
})
glue_step("ethyl-cyanoacetate", "iv-chemical-reactor-recipes", 1000, {
	{ type = "item", name = "cyanoacetic-acid", amount = 9 },
	{ type = "fluid", name = "ethanol", amount = 100 },
}, { { type = "fluid", name = "ethyl-cyanoacetate", amount = 100 } })
glue_step("super-glue", "iv-chemical-reactor-recipes", 55, {
	{ type = "fluid", name = "ethyl-cyanoacetate", amount = 10 },
	{ type = "fluid", name = "formaldehyde", amount = 10 },
}, {
	{ type = "fluid", name = "super-glue", amount = 10 },
	{ type = "fluid", name = "water", amount = 100 },
})

--- The ender tanks (upstream 15-hv-age-item.lua: the items come from the microverse projector, their entities were
--- commented out, so the nether and ender air collection had no machine). GT collects nether and ender air with the
--- air collector in the Nether and the End; here the tank filled on the other side stands in for it: the HV and the
--- EV air collector with the ender tank's recipes. Graphics (issue #99): the GT hull of the tier around GT's animated
--- ender fluid link, red for nether air (tools/gen_sprites.py, ENDER_TANKS).
local function ender_tank(name, source, category)
	local m = table.deepcopy(data.raw["assembling-machine"][source])
	m.name = name
	m.icon = ICON_PATH .. name .. ".png"
	m.icon_size = 32
	m.icons = nil
	m.graphics_set = fork_sprites(name, 3, 3, 8, 8)
	m.minable = { mining_time = 0.5, result = name }
	m.crafting_categories = { category }
	m.fast_replaceable_group = nil
	m.next_upgrade = nil
	data:extend({ m })
	data.raw.item[name].place_result = name
end
ender_tank("nether-air-ender-tank", "hv-air-collector", "nether-air-ender-tank-recipes")
ender_tank("ender-air-ender-tank", "ev-air-collector", "ender-air-ender-tank-recipes")

--- Component assembly line (GoodGenerator's CoAL, ComponentAssemblyLineMiscRecipes.java). Upstream has its drafts
--- in 25-uv-age-item.lua (a controller and a structure of 1300 casings, not loaded) and 32 recipes in
--- 11/13/15/17-*-age-item.lua that make 64 LV to EV components at once from long rods, 16x wires and cables and
--- circuit wraps (uv-coal-recipes), with no machine. Here: one UV multiblock from the ZPM assembly line, with GT's
--- controller recipe (UHV/2, 30 s in the assembly line; GT's 4 superdense iridium plates, 256 ingots, are 28
--- iridium blocks here, the PBI pipes PBI sheets). GT runs a CoAL recipe at its own voltage (ULV to EV) and overclocks it by the casing
--- tier; here at crafting speed 1, so a recipe takes GT's base time (64 LV motors in 48 s).
--- Graphics (issue #99): GT's iridium casing, GoodGenerator's UV component assembly line casing and the CoAL
--- controller face (tools/gen_sprites.py); the icon from the same textures (tools/gen_gt_icons.py).
do
	local COAL = "component-assembly-line"
	local m = table.deepcopy(data.raw["assembling-machine"]["zpm-assembly-line"])
	m.name = COAL
	m.icon = ICON_PATH .. COAL .. ".png"
	m.icon_size = 32
	m.icons = nil
	m.graphics_set = fork_sprites(COAL, 9, 3, 1, 1)
	m.minable = { mining_time = 1, result = COAL }
	m.crafting_categories = { "uv-coal-recipes" }
	m.crafting_speed = 1
	m.energy_usage = EU16_UV
	m.fast_replaceable_group = nil
	m.next_upgrade = nil
	data:extend({ m })
	create_item{
		name = COAL,
		category = "zpm-assembly-line-recipes",
		energy_required = 30 * LUV_SPEED,
		subgroup = "subgroup-uv-age-multiblocks",
		stack_size = 10,
		place_result = COAL,
		ingredients = {
			{ type = "item", name = "assembly-line-controller", amount = 16 },
			{ type = "item", name = "assembler-machine-casing", amount = 16 },
			{ type = "item", name = "assembly-line-casing", amount = 32 },
			{ type = "item", name = "uv-robot-arm", amount = 16 },
			{ type = "item", name = "uv-conveyor-module", amount = 32 },
			{ type = "item", name = "zpm-motor", amount = 32 },
			{ type = "item", name = "polybenzimidazole-sheet", amount = 48 },
			{ type = "item", name = "block-of-iridium", amount = 28 },
			{ type = "item", name = "zpm-fluid-solidifier", amount = 16 },
			{ type = "item", name = "uv-circuit", amount = 16 },
			{ type = "item", name = "zpm-circuit", amount = 20 },
			{ type = "item", name = "luv-circuit", amount = 24 },
			{ type = "fluid", name = "molten-indalloy-140", amount = 172.8 },
			{ type = "fluid", name = "molten-naquadria", amount = 230.4 },
			{ type = "fluid", name = "lubricant", amount = 500 },
		},
	}
end

--- Microminer missions for the ores of GT's space veins (OreMixes.java). Upstream has the ore lines (crushed ore,
--- washing, centrifuge, smelting; 07-ore-processing-module.lua) and drafts of the missions in the tier seven and
--- eight microminers (23-zpm-age-item.lua, 27-uhv-age-item.lua, not loaded), which do not exist; like the
--- bedrockium and quantium missions of 137-fork-endgame-materials.lua they are missions of the tier three
--- microminer (the end), unlocked with those technologies (UV and UHV). The vein decides the outputs, the drafts the
--- amounts; GT's sporadic titanium and the garnets have no raw ore item here and are left out.
local function mission(name, tier_output, count, subgroup, results, main)
	create_recipe{
		name = name,
		category = "lv-assembling-machine-recipes",
		energy_required = 8,
		subgroup = subgroup,
		ingredients = { { type = "item", name = tier_output, amount = count } },
		results = results,
		main_product = main,
	}
end
--- GT's neutronium vein (Pluto, Makemake, Haumea, the Kuiper belt ...): neutronium, adamantium, naquadah, titanium
mission("microminer-neutronium", "tier-three-microminer-output", 2, "subgroup-microminer-t3", {
	{ type = "item", name = "raw-neutronium", amount = 32 },
	{ type = "item", name = "raw-adamantium", amount = 16 },
	{ type = "item", name = "raw-naquadah", amount = 8 },
}, "raw-neutronium")
--- GT's black plutonium vein (Horus, Barnard C, Centauri Bb, Makemake, Pluto, T Ceti E): black plutonium, red and
--- yellow garnet, borax
mission("microminer-black-plutonium", "tier-three-microminer-output", 2, "subgroup-microminer-t3", {
	{ type = "item", name = "raw-black-plutonium", amount = 32 },
	{ type = "item", name = "raw-borax", amount = 8 },
}, "raw-black-plutonium")
--- GT's infinity catalyst vein (Anubis): neutronium, adamantium, infinity catalyst, bedrockium
mission("microminer-infinity-catalyst", "tier-three-microminer-output", 2, "subgroup-microminer-t3", {
	{ type = "item", name = "raw-infinity-catalyst", amount = 16 },
	{ type = "item", name = "raw-neutronium", amount = 32 },
	{ type = "item", name = "raw-adamantium", amount = 8 },
	{ type = "item", name = "raw-bedrockium", amount = 8 },
}, "raw-infinity-catalyst")
--- GT's cosmic neutronium vein (Horus): neutronium, cosmic neutronium, black plutonium, bedrockium
mission("microminer-cosmic-neutronium", "tier-three-microminer-output", 2, "subgroup-microminer-t3", {
	{ type = "item", name = "raw-cosmic-neutronium", amount = 16 },
	{ type = "item", name = "raw-neutronium", amount = 32 },
	{ type = "item", name = "raw-black-plutonium", amount = 8 },
	{ type = "item", name = "raw-bedrockium", amount = 8 },
}, "raw-cosmic-neutronium")
--- GT's titanium-chrome vein (the Moon, asteroids, Callisto ...): ilmenite, chromite, uvarovite, perlite. A mission of
--- the tier two microminer, like the ilmenite one (07-ore-processing-module.lua), and with its technology
mission("microminer-chromite", "tier-two-microminer-output", 1, "subgroup-microminer-t2", {
	{ type = "item", name = "raw-ilmenite", amount = 24 },
	{ type = "item", name = "raw-chromite", amount = 16 },
}, "raw-chromite")



--------------------------------------------------------------------------------
--- 2) TECHNOLOGIES
--------------------------------------------------------------------------------

--- The tier four microminer (upstream 52-microverse-module.lua: the lunar mission, its engine and plating, the
--- moon turf and moon dust) had no technology; IV like its microverse projector. Recipes: the table below.
F.tech{
	name = "tier-four-microminers",
	prerequisites = { "tier-three-microminers", "iv-machines", "tungsten-carbide", "nuclear-power", "me-storage-64k" },
	packs = 6, count = 800,
	recipes = {},
}
--- GT++'s glue line is IV (6000 EU/t in the chemical plant)
F.tech{
	name = "super-glue",
	prerequisites = { "advanced-glue", "iv-machines" },
	packs = 6, count = 800,
	recipes = {},
}



--------------------------------------------------------------------------------
--- 3) UNLOCKS
--- Technology -> recipes, by tier. Most recipes go to the technology of their material (the blocks, 16x wires,
--- long rods and plates of a metal to the technology that makes its ingot) or of their machine; the rest by line:
---   * the 32 component assembly line recipes, its circuit wraps and the machine: uv-multiblocks
---   * the lunar mission, signalum, moon dust and the crystaltine parts of the extended crafting tables (they need
---     the nether star and HSS-G plates of IV): tier-four-microminers
---   * the naquadah doped boule, its wafer, the -nd wafer variants, graphene from them, the system on chip and the
---     cheap circuits from it: naquadah-processing (where the naquadah ingot comes); the europium (-ed) and
---     americium (-ad) variants already sit with their wafers (nano-power-ics, pico-quantum-power-ics)
---   * GT++ alloys without a technology of their own (Hastelloy C-276 and W, Incoloy 020 and MA956, Ultimet,
---     Zeron-100): melt, ingot and parts with the alloy blast smelter. Like the alloys upstream puts on EV techs,
---     they are made from IV on (the smelter's heat vent needs staballoy parts of IV)
---   * the alloys that have one: with it (Hastelloy X, Inconel 625/690/792, Stellite, Talonite)
---   * the power multiblocks (large heat exchanger, large and high pressure steam turbine, lapotronic
---     supercapacitor): with nuclear power, the magnalium of the industrial mixer (both steam turbines) and the
---     lapotronic energy orbs. Upstream has no entity for them yet (items only).
---   * nether and ender air (the ender tanks, collection, liquefaction, distillation): end-steel
---   * the ore lines of the exotic ores: with the missions (bedrockium for UV, quantium for UHV); chromite with the
---     titanium technology, which has the ilmenite mission (the chromite mission brings ilmenite too)
---   * ore lines whose product main makes later by another route go to that route's technology, so nothing comes
---     earlier than before: bastnasite (neodymium) to neodymium, molybdenite (molybdenum) to tungstate-processing,
---     carbon fibres from PTFE, the carbon mesh and plate to nanoprocessors
---   * the depleted fuel rods: nuclear-fuel-rods
--------------------------------------------------------------------------------

local UNLOCKS = {
	["steam-compressor"] = { -- steam
		"block-of-bronze", "block-of-copper", "block-of-red-alloy", "block-of-tin", "brick-block",
	},
	["steel-processing"] = { -- steam
		"block-of-steel", "lapis-lazuli-block",
	},
	["rubber"] = { -- steam
		"block-of-zinc",
	},
	["bending-machine"] = { -- steam
		"dense-steel-plate",
	},
	["wiremill"] = { -- steam
		"copper-wire-16x", "tin-wire-16x",
	},
	["electrolyzer"] = { -- LV
		"block-of-gold", "gold-wire-16x",
	},
	["lathe"] = { -- LV
		"lapis-rod",
	},
	["ore-washing"] = { -- LV
		"lapis-plate",
	},
	["galena"] = { -- LV
		"block-of-lead", "block-of-silver", "silver-wire-16x",
	},
	["ore-centrifuging"] = { -- LV
		"centrifuge-cinnabar-dust",
	},
	["invar"] = { -- LV
		"block-of-invar",
	},
	["electric-blast-furnace"] = { -- LV
		"cupronickel-wire-16x",
	},
	["circuit-assembler"] = { -- LV
		"block-of-brass",
	},
	["basic-extended-crafting"] = { -- MV
		"block-of-black-steel",
	},
	["aluminium"] = { -- MV
		"aluminium-wire-16x", "bauxite-dust-electrolysis", "dense-aluminium-plate", "raw-aluminium-smelter",
		"raw-bauxite-smelter",
	},
	["extruder"] = { -- MV
		"large-black-steel-gear", "long-brass-rod", "long-iron-rod", "long-magnetic-iron-rod", "long-magnetic-steel-rod",
		"long-steel-rod",
	},
	["mv-machines"] = { -- MV
		"bismuth-bronze-dust", "red-steel-dust", "sterling-silver-dust",
	},
	["energetic-alloy"] = { -- MV
		"block-of-energetic-alloy", "energetic-alloy-wire-16x",
	},
	["polyethylene"] = { -- MV
		"ether", "plascrete",
	},
	["kanthal"] = { -- MV
		"kanthal-wire-16x",
	},
	["advanced-integrated-circuits"] = { -- MV
		"block-of-electrum", "electrum-wire-16x", "long-electrum-rod",
	},
	["advanced-mv-machines"] = { -- MV
		"lapis-bolt", "lapis-screw",
	},
	["multismelter"] = { -- MV
		"cobalt-brass-ingot-multismelter", "pentlandite-dust-multismelter", "raw-aluminium-multismelter",
		"raw-barite-multismelter", "raw-cassiterite-multismelter", "raw-sodalite-multismelter",
	},
	["stainless-steel"] = { -- MV
		"dense-stainless-steel-plate", "long-stainless-steel-rod",
	},
	["tier-two-microminers"] = { -- MV
		"centrifuging-crushed-monazite", "ender-pearl-block", "monazite-dust", "monazite-dust-extraction",
		"raw-monazite-multismelter", "raw-monazite-smelter",
	},
	["eyes-of-ender"] = { -- MV
		"block-of-pulsating-iron", "pulsating-iron-wire-16x",
	},
	["neodymium"] = { -- HV
		"bastnasite-dust", "bastnasite-dust-electrolysis", "centrifuging-crushed-bastnasite", "crushed-bastnasite",
		"long-magnetic-neodymium-rod", "long-neodymium-rod", "raw-bastnasite-multismelter", "raw-bastnasite-smelter",
	},
	["hv-components"] = { -- HV
		"hv-sensor",
	},
	["niobium-and-tantalum-extraction"] = { -- HV
		"tantalum-plate",
	},
	["large-sifter"] = { -- HV
		"coal-sifter", "large-tumbaga-gear",
	},
	["smd-components"] = { -- HV
		"block-of-nickel-zinc-ferrite", "block-of-platinum", "long-platinum-rod", "platinum-foil",
	},
	["oil-processing"] = { -- HV
		"charcoal-byproducts", "charcoal-byproducts-distillation", "toluene-from-wood-tar", "wood-gas-distillation",
		"wood-vinegar-distillation",
	},
	["implosion-compressor"] = { -- HV
		"saltpeter",
	},
	["rocket-fuel"] = { -- HV
		"hydrochloric-acid-concentration",
	},
	["tier-three-microminers"] = { -- HV
		"block-of-vibrant-alloy", "centrifuging-crushed-bornite", "raw-bornite-multismelter", "raw-bornite-smelter",
		"vibrant-alloy-plate", "vibrant-alloy-wire-16x",
	},
	["titanium"] = { -- EV
		"block-of-titanium", "centrifuging-crushed-chromite", "chromium-dust", "crushed-chromite", "ilmenite-processing",
		"ilmenite-slag-processing", "long-titanium-rod", "microminer-chromite", "raw-chromite-multismelter",
		"raw-chromite-smelter", "raw-ilmenite-multismelter", "raw-ilmenite-smelter", "sulfuric-iron-solution-electrolysis",
		"titanium-pipe-casing",
	},
	["end-steel"] = { -- EV
		"block-of-dark-steel", "block-of-electrical-steel", "end-steel-wire-16x", "ender-air-collection",
		"ender-air-distillation", "ender-air-ender-tank", "ender-tank", "endstone-dust-centrifuging", "liquid-ender-air",
		"liquid-nether-air", "nether-air-collection", "nether-air-distillation", "nether-air-ender-tank",
	},
	["tungstate-processing"] = { -- EV
		"centrifuging-crushed-molybdenite", "crushed-molybdenite", "molybdenite-dust", "molybdenum-dust",
		"molybdenum-trioxide", "raw-molybdenite-multismelter", "raw-molybdenite-smelter",
	},
	["tungsten"] = { -- EV
		"block-of-tungsten", "tungsten-frame", "tungsten-rod",
	},
	["alloy-blast-smelter"] = { -- EV
		"hastelloy-c276-frame", "hastelloy-c276-plate", "hastelloy-c276-rod", "hastelloy-c276-rotor", "hastelloy-w-frame",
		"hastelloy-w-plate", "hastelloy-w-rod", "hastelloy-w-rotor", "incoloy-ma956-frame", "incoloy-ma956-plate",
		"incoloy-ma956-rod", "large-hastelloy-c276-gear", "large-ultimet-gear", "molten-hastelloy-c276",
		"molten-hastelloy-w", "molten-incoloy-020", "molten-incoloy-ma956", "molten-ultimet", "molten-zeron-100",
		"solidify-hastelloy-c276-ingot", "solidify-hastelloy-w-ingot", "solidify-incoloy-020-ingot",
		"solidify-incoloy-ma956-ingot", "solidify-ultimet-ingot", "solidify-zeron-100-ingot", "zeron-100-plate",
	},
	["ender-io"] = { -- EV
		"block-of-soularium", "hv-field-generator",
	},
	["platinum-ore-processing"] = { -- EV
		"centrifuging-crushed-palladium", "centrifuging-crushed-platinum", "centrifuging-crushed-sheldonite",
		"crushed-palladium", "crushed-platinum", "palladium-dust", "raw-sheldonite-multismelter", "raw-sheldonite-smelter",
		"sheldonite-dust", "sheldonite-dust-electrolysis",
	},
	["polybenzimidazole"] = { -- EV
		"plastic-circuit-board-pbi", "raw-carbon-fibers", "raw-carbon-fibers-pbi",
	},
	["silicone-rubber"] = { -- EV
		"aluminium-cable-16x", "copper-cable-16x", "gold-cable-16x", "silver-cable-16x", "tin-cable-16x",
	},
	["ev-energy-hatches"] = { -- EV
		"ev-dynamo-hatch",
	},
	["nanoprocessors"] = { -- EV
		"carbon-plate", "raw-carbon-fibers-ptfe", "raw-carbon-mesh",
	},
	["nuclear-power"] = { -- EV
		"reactor-pressure-vessel",
	},
	["large-steam-turbine"] = { -- EV (issue #97; the magnalium parts and casings are also on industrial-mixer)
		"blue-steel-frame", "large-steam-turbine", "large-steam-turbine-controller", "long-magnalium-rod",
		"magnalium-bolt", "magnalium-ingot", "magnalium-plate", "magnalium-rod", "magnalium-screw",
		"magnalium-turbine-blade", "magnalium-turbine-rotor", "steel-turbine-casing", "turbine-output-hatch",
	},
	["nuclear-fuel-rods"] = { -- EV
		"depleted-thorium-fuel-rod-centrifuging", "depleted-uranium-fuel-rod-centrifuging",
	},
	["iv-components"] = { -- IV
		"block-of-iridium", "iridium-frame",
	},
	["iv-machines"] = { -- IV
		"tetrafluoroethylene-advanced",
	},
	["qubit-cpus"] = { -- IV
		"quantum-processor", "quantum-processor-assembly", "quantum-processor-supercomputer",
	},
	["industrial-centrifuge"] = { -- IV
		"inconel-792-ring", "inconel-792-rod",
	},
	["industrial-electrolyzer"] = { -- IV
		"large-stellite-gear", "stellite-frame", "stellite-rod",
	},
	["hyper-intensity-laser-engraver"] = { -- IV
		"hastelloy-x-plate", "hastelloy-x-rotor", "solidify-hastelloy-x-ingot",
	},
	["industrial-cutting-factory"] = { -- IV
		"large-talonite-gear",
	},
	["industrial-mixer"] = { -- IV
		"long-magnalium-rod", "magnalium-bolt", "magnalium-rod", "magnalium-screw",
	},
	["high-pressure-steam-turbine"] = { -- IV (issue #97)
		"high-pressure-steam-turbine", "high-pressure-steam-turbine-controller", "titanium-turbine-casing",
	},
	["fluid-nuclear-reactor"] = { -- IV (issue #97; the heat exchanger moves here from nuclear-power, the reactor from
		-- fusion-reactor-mk1, the iridium neutron reflector is also on fusion-reactor-mk1)
		"coolant", "fluid-nuclear-reactor", "hot-coolant", "iridium-neutron-reflector", "large-heat-exchanger",
		"large-heat-exchanger-controller", "large-heat-exchanger-steam", "large-heat-exchanger-superheated-steam",
	},
	["fluid-shaper"] = { -- IV
		"inconel-625-bolt", "inconel-625-plate", "inconel-625-rod", "inconel-625-screw", "solidify-inconel-625-ingot",
	},
	["industrial-extrusion-machine"] = { -- IV
		"inconel-690-frame", "inconel-690-rod",
	},
	["zyngen"] = { -- IV
		"tantalum-carbide-plate",
	},
	["luv-components"] = { -- IV
		"ruridit-bolt",
	},
	["super-glue"] = { -- IV
		"chloroacetic-acid", "cyanoacetic-acid", "ethyl-cyanoacetate", "formaldehyde", "hydrogen-cyanide",
		"sodium-cyanide", "super-glue",
	},
	["tier-four-microminers"] = { -- IV
		"crystaltine-extended-crafting-catalyst", "crystaltine-extended-crafting-component", "crystaltine-ingot",
		"extraterrestrial-metal-mixture-centrifuging", "lunar-navigation-data", "microminer-compressed-moon-turf",
		"moon-dust", "moon-dust-centrifuging", "signalum-ingot", "signalum-microminer-engine-core",
		"signalum-microminer-engine-frame", "signalum-plate", "signalum-rod", "tier-four-microminer-output",
		"tungsten-carbide-heavy-plating", "tungsten-carbide-plated-microminer", "vibrant-thruster",
	},
	["naquadah-processing"] = { -- LuV
		"cpu-wafer-nd", "fluorspar-electrolysis", "graphene-nd", "ilc-wafer-nd", "microchip-cheap", "microprocessor-cheap",
		"mpic-wafer-nd", "nand-memory-nd", "naquadah-doped-monocrystaline-silicon-boule", "naquadah-doped-wafer",
		"nor-memory-wafer-nd", "ram-wafer-qd", "simple-soc-wafer-nd", "soc-wafer-nd", "system-on-chip",
	},
	["super-coolant"] = { -- LuV
		"ledox-plate", "raw-ledox-multismelter", "raw-ledox-smelter",
	},
	["nano-power-ics"] = { -- LuV
		"cpu-wafer-ed", "graphene-ed", "simple-soc-wafer-ed", "soc-wafer-ed",
	},
	["zpm-energy-hatches"] = { -- ZPM
		"block-of-osmium",
	},
	["zpm-assembly-line"] = { -- ZPM
		"block-of-palladium", "fine-palladium-wire", "multilayered-fiber-reinforced-printed-circuit-board",
	},
	["uv-materials"] = { -- ZPM
		"magnesium-sulphate-electrolysis",
	},
	["pico-quantum-power-ics"] = { -- ZPM
		"cpu-wafer-ad", "graphene-ad", "soc-wafer-ad",
	},
	["lapotronic-energy-orbs"] = { -- ZPM
		"lapotronic-capacitor-iv", "lapotronic-supercapacitor", "lapotronic-supercapacitor-casing",
		"lapotronic-supercapacitor-controller",
	},
	["luv-lapotronic-supercapacitor"] = { -- ZPM (issue #97)
		"lapotronic-capacitor-luv", "luv-lapotronic-supercapacitor",
	},
	["zpm-lapotronic-supercapacitor"] = { -- ZPM (issue #97; the energy module is also on fusion-coil-ii)
		"energy-module", "lapotronic-capacitor-zpm", "zpm-lapotronic-supercapacitor",
	},
	["uv-multiblocks"] = { -- UV
		"component-assembly-line", "ev-circuit-wrap", "ev-conveyor-module-coal", "ev-emitter-coal",
		"ev-field-generator-coal", "ev-motor-coal", "ev-piston-coal", "ev-pump-coal", "ev-robot-arm-coal",
		"ev-sensor-coal", "hv-circuit-wrap", "hv-conveyor-module-coal", "hv-emitter-coal", "hv-field-generator-coal",
		"hv-motor-coal", "hv-piston-coal", "hv-pump-coal", "hv-robot-arm-coal", "hv-sensor-coal", "lv-circuit-wrap",
		"lv-conveyor-module-coal", "lv-emitter-coal", "lv-field-generator-coal", "lv-motor-coal", "lv-piston-coal",
		"lv-pump-coal", "lv-robot-arm-coal", "lv-sensor-coal", "mv-circuit-wrap", "mv-conveyor-module-coal",
		"mv-emitter-coal", "mv-field-generator-coal", "mv-motor-coal", "mv-piston-coal", "mv-pump-coal",
		"mv-robot-arm-coal", "mv-sensor-coal",
	},
	["bedrockium"] = { -- UV
		"black-plutonium-dust", "borax", "centrifuging-crushed-adamantium", "centrifuging-crushed-black-plutonium",
		"centrifuging-crushed-borax", "centrifuging-crushed-neutronium", "crushed-adamantium", "crushed-black-plutonium",
		"crushed-borax", "crushed-neutronium", "microminer-black-plutonium", "microminer-neutronium", "neutronium-dust",
	},
	["quantium"] = { -- UHV
		"centrifuging-crushed-cosmic-neutronium", "centrifuging-crushed-infinity-catalyst", "cosmic-neutronium-dust",
		"crushed-cosmic-neutronium", "crushed-infinity-catalyst", "infinity-catalyst-dust", "microminer-cosmic-neutronium",
		"microminer-infinity-catalyst",
	},
}
--- The auto-unlock of 199 visits the technologies in its own order and pulls the producers of what their recipes
--- need into the first one that needs them. With the recipes above some of its earlier choices would move to
--- another technology or (where an unlocked recipe now makes the item as a byproduct) to none: they stay where
--- they were.
local KEEP = {
	["industrial-mixer"] = { "magnalium-ingot", "magnalium-plate", "steel-turbine-casing", "titanium-turbine-casing",
		"blue-steel-rod", "blue-steel-frame" },
	["plasma-turbine"] = { "long-tungstensteel-rod" },
	["military-science-pack"] = { "lv-sensor" },
	["end-steel"] = { "endstone-dust" },
	["rhodium"] = { "sulfur-dioxide", "sulfur-trioxide" },
}
for _, list in pairs({ UNLOCKS, KEEP }) do
	for tech, recipes in pairs(list) do
		for _, r in pairs(recipes) do
			if data.raw.recipe[r] then fork_add_unlock(tech, r) else log("FORK-UNLOCK: missing recipe: " .. r) end
		end
	end
end



--------------------------------------------------------------------------------
--- 4) RECIPES THAT STAY LOCKED (devcheck's allow-list, read from the dump of checkmod)
--------------------------------------------------------------------------------

FORK_RECIPES_LOCKED = {
	["calcium"] = "upstream placeholder without ingredients (an item from nothing); calcium comes from fluorspar",
	["cerium-rich-mixture"] = "upstream placeholder without ingredients; the mixture comes from bastnasite",
	["phosphorus"] = "upstream placeholder without ingredients; phosphorus comes from the phosphorus line",
	["ultimate-extended-crafting-component"] = "upstream recipe needs four of its own product (copy error); no GT recipe",
	["ultimate-extended-crafting-catalyst"] = "needs the ultimate extended crafting component",
	["ultimate-extended-crafting-table"] = "needs the ultimate component and catalyst; the table has no entity",
	["crushed-firestone"] = "no source of firestone ore: GT has no firestone vein (Railcraft's nether ore)",
	["firestone-dust"] = "needs crushed firestone",
	["centrifuging-crushed-firestone"] = "needs crushed firestone",
	["raw-firestone-ore-smelter"] = "no source of firestone ore",
	["raw-firestone-ore-multismelter"] = "no source of firestone ore",
	["plastic-circuit-board-peca"] = "upstream commented out its polyethylcyanoacrylate sheet (13-mv-age-item.lua): "
		.. "without it 16 boards from copper foil and acid, twice the polyethylene recipe for no plastic",
}
