--------------------------------------------------------------------------------
--- FORK RECIPE UNLOCKS (issue #91, part 1)
--- Upstream creates machine recipes disabled and leaves the unlock to a technology; 199-fork-finalize.lua only
--- pulls in what an unlocked recipe needs (FORK-AUTOUNLOCK). Everything else stayed locked for good: 331 Gregtorio
--- recipes (devcheck `check --balance-out` on main at 13a9245), 224 of them the only source of their product.
--- Here every one of them gets a technology, explicitly (no rule that guesses), the one of its tier where a player
--- looks for it: the technology of its material or its machine, the line it belongs to. devcheck fails on a
--- Gregtorio recipe that no researchable technology unlocks, unless it is in FORK_RECIPES_LOCKED below.
---
---   1) producers GregTech has and Gregtorio lacked, so that the unlocked recipes can be made: naquadah doped boule,
---      charcoal byproducts, super glue (GT++'s glue line, condensed), the component assembly line (issue #287 removed
---      the signalum ingot, the ender tanks and the microminer missions with the microverse)
---   2) a technology: super glue
---   3) the unlock table
---   4) the recipes that stay locked, with the reason
--- Amounts: fluids at Gregtorio's scale, a tenth of GregTech's (144 per ingot in GT, 14.4 here), items and times
--- as in GregTech. Loaded after 138 (no unit counts from UV up are set for the new technology, it is IV) and
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

--- Component assembly line (GoodGenerator's CoAL, ComponentAssemblyLineMiscRecipes.java). Upstream has its drafts
--- in 25-uv-age-item.lua (a controller and a structure of 1300 casings, never loaded, removed in issue #249) and 32 recipes in
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




--------------------------------------------------------------------------------
--- 2) TECHNOLOGIES
--------------------------------------------------------------------------------

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
---   * nether air (liquefaction, distillation): end-steel
---   * the ore lines of the exotic ores: with their first consumers (bedrockium for UV, quantium for UHV); chromite
---     with the titanium technology
---   * ore lines whose product main makes later by another route go to that route's technology, so nothing comes
---     earlier than before: bastnasite (neodymium) to neodymium, molybdenite (molybdenum) to tungstate-processing,
---     carbon fibres from PTFE, the carbon mesh and plate to nanoprocessors
---   * the depleted fuel rods: nuclear-fuel-rods
--------------------------------------------------------------------------------

local UNLOCKS = {
	["steam-compressor"] = { -- steam
		"block-of-bronze", "block-of-copper", "block-of-red-alloy", "block-of-redstone", "block-of-tin", "brick-block",
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
	["black-steel"] = { -- MV (issue #287: was basic-extended-crafting)
		"block-of-black-steel",
	},
	["aluminium"] = { -- MV
		"aluminium-wire-16x", "bauxite-dust-electrolysis", "dense-aluminium-plate",
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
		"ether",
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
		"cobalt-brass-ingot-multismelter", "pentlandite-dust-multismelter", "raw-cassiterite-multismelter",
		"raw-sodalite-multismelter",
	},
	["stainless-steel"] = { -- MV
		"dense-stainless-steel-plate", "long-stainless-steel-rod",
	},
	["eyes-of-ender"] = { -- MV
		"block-of-pulsating-iron", "ender-pearl-block", "pulsating-iron-wire-16x",
	},
	["neodymium"] = { -- HV
		"bastnasite-dust", "bastnasite-dust-electrolysis", "centrifuging-crushed-bastnasite", "crushed-bastnasite",
		"long-magnetic-neodymium-rod", "long-neodymium-rod",
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
		"block-of-nickel-zinc-ferrite",
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
	["reach-the-moon"] = { -- HV (issue #287: the monazite of the Moon's mine, 160; was tier-two-microminers)
		"centrifuging-crushed-monazite", "monazite-dust", "monazite-dust-extraction", "raw-monazite-multismelter",
		"raw-monazite-smelter",
	},
	["reach-ross128"] = { -- IV (issue #293: the bornite of Ross128's mine, 160; was tier-three-microminers)
		"crushed-bornite",
	},
	["titanium"] = { -- EV
		"block-of-titanium", "centrifuging-crushed-chromite", "chromium-dust", "crushed-chromite", "ilmenite-processing",
		"ilmenite-slag-processing", "long-titanium-rod", "sulfuric-iron-solution-electrolysis", "titanium-pipe-casing",
	},
	["end-steel"] = { -- EV
		"block-of-dark-steel", "block-of-electrical-steel", "end-steel-wire-16x", "ender-air-distillation",
		"endstone-dust-centrifuging", "liquid-ender-air", "liquid-nether-air", "nether-air-distillation",
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
		"block-of-soularium", "block-of-vibrant-alloy", "hv-field-generator", "vibrant-alloy-plate",
		"vibrant-alloy-wire-16x",
	},
	["platinum-ore-processing"] = { -- EV
		"centrifuging-crushed-palladium", "centrifuging-crushed-platinum", "centrifuging-crushed-sheldonite",
		"crushed-palladium", "crushed-platinum", "sheldonite-dust", "sheldonite-dust-electrolysis",
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
		"large-titanium-boiler", "titanium-firebox-casing",   -- issue #254: superheated steam from fuel
		"high-pressure-steam-turbine", "high-pressure-steam-turbine-controller", "titanium-turbine-casing",
	},
	["large-combustion-engine"] = { -- EV (issue #255; the gear box casing also comes with alloy-blast-smelter)
		"large-combustion-engine", "engine-intake-casing", "titanium-gear-box-casing",
	},
	["large-gas-turbine"] = { -- EV (issue #256)
		"large-gas-turbine", "stainless-steel-turbine-casing",
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
		"crushed-borax", "crushed-neutronium", "neutronium-dust",
	},
	["quantium"] = { -- UHV
		"centrifuging-crushed-cosmic-neutronium", "centrifuging-crushed-infinity-catalyst", "cosmic-neutronium-dust",
		"crushed-cosmic-neutronium", "crushed-infinity-catalyst", "infinity-catalyst-dust",
	},
}
--- Issue #98 (prototypes/147-fork-gt-routes.lua): the second printed board with sodium persulfate where the printed
--- board is (microprocessors), black plutonium and cosmic neutronium in the blast furnace with their dusts (the
--- technologies of bedrockium and quantium), the high octane line on its own technology, GT's PPIC wafer with the
--- other one
local UNLOCKS_98 = {
	["microprocessors"] = { -- MV
		"plastic-printed-circuit-board-sodium-persulfate", "sodium-persulfate", "sodium-bisulfate",
		"sodium-bisulfate-from-sodium-hydroxide",
	},
	["high-octane-gasoline"] = { -- EV
		"hydrocracked-light-fuel", "distilling-hydrocracked-light-fuel", "nitrous-oxide", "anti-knock-agent",
		"high-octane-gasoline", "high-octane-gasoline-cell",
	},
	["pico-quantum-power-ics"] = { -- ZPM
		"ppic-wafer-sunnarium",
	},
	["bedrockium"] = F.join({ "black-plutonium-ingot" }, FORK_GT_ROUTES.black_plutonium), -- UV
	["quantium"] = F.join({ "cosmic-neutronium-ingot-from-hot-ingot" }, FORK_GT_ROUTES.cosmic_neutronium), -- UHV
}
--- Issue #96 (prototypes/146-fork-platinum-line.lua): GTNH's platinum line on the six technologies of the upstream
--- line (their names kept): the ore washer and the sludge on platinum ore processing, aqua regia, the sludge centrifuge
--- and the concentrate on platinum line initialization, the salts and reprecipitated platinum on platinum, the
--- palladium steps on palladium, and each residue branch on the technology of its metal (the recipes it keeps by name
--- stay on it from 98-technology.lua)
local UNLOCKS_96 = {
	["platinum-ore-processing"] = { -- EV
		"crushed-platinum-washing", "crushed-palladium-washing", "platinum-group-sludge-chalcopyrite",
	},
	["platinum-line-initialization"] = F.join({ -- EV
		"platinum-group-sludge-centrifuging", "platinum-concentrate",
	}, FORK_PLATINUM_LINE.feeds),
	["platinum"] = { -- EV
		"platinum-salt", "refined-platinum-salt", "metallic-platinum-powder-from-refined-salt",
		"reprecipitated-platinum-processing", "block-of-platinum", "long-platinum-rod", "platinum-foil",
	},
	["palladium"] = { -- EV
		"palladium-enriched-ammonia", "palladium-salt", "palladium-salt-from-ammonia", "metallic-palladium-powder-from-salt",
		"reprecipitated-palladium-processing",
	},
	["rhodium"] = { -- EV
		"potassium-disulfate", "molten-potassium-disulfate", "sulfuric-acid-from-sulfur-trioxide", "solidify-potassium",
		"rhodium-salt-solution",
		"rhodium-nitrate", "sodium-nitrate-from-sodium-hydroxide", "rhodium-filter-cake", "rhodium-filter-cake-solution",
		"reprecipitated-rhodium", "reprecipitated-rhodium-processing",
	},
	["ruthenium"] = { -- EV
		"ruthenium-tetroxide-solution", "ruthenium-tetroxide-solution-distillation",
	},
	["iridium"] = { -- EV
		"iridium-dioxide", "acidic-iridium-solution", "iridium-chloride", "sludge-dust-residue-centrifuging",
		"metallic-sludge-dust-residue-centrifuging",
	},
	["osmium"] = { -- EV
		"osmium-solution",
	},
}
--- Issue #205 (prototypes/125-fork-luv-endgame.lua): GT's recipes of the naquadah line that upstream lacked, on the
--- technology of their input: gallium from the line's gallium hydroxide, zinc from the zinc sulfate of the enriched
--- naquadah ingot, the naquadria oxide mixture branch with the naquadria ingot
local UNLOCKS_205 = {
	["naquadah-processing"] = { "gallium-from-gallium-hydroxide", -- LuV
		--- issue #207: goodgenerator's naquadah nugget (125) and its ingot
		"naquadah-nugget", "naquadah-nugget-helium", "naquadah-nugget-argon", "naquadah-nugget-radon", "naquadah-nugget-neon",
		"naquadah-nugget-krypton", "naquadah-nugget-xenon", "naquadah-ingot-from-nuggets" },
	["enriched-naquadah"] = { "zinc-from-zinc-sulfate" }, -- LuV
	["uv-materials"] = { -- UV
		"naquadria-dust-macerator",   -- issue #223: GT's naquadria dust from the ingot (125)
		"naquadah-dust-centrifuging", "enriched-naquadah-dust-centrifuging", "naquadria-oxide-mixture-centrifuging",
		"naquadria-rich-solution-from-phosphate", "indium-from-indium-phosphate", "indium-gallium-phosphide-from-indium-phosphate",
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
	-- issue #443: the LV sensor with the Circuit Assembler, the first LV technology with all its parts (brass rod, certus
	-- quartz), so the LV Miner needs no Military Science Pack technology
	["circuit-assembler"] = { "lv-sensor" },
	["end-steel"] = { "endstone-dust" },
	["rhodium"] = { "sulfur-dioxide", "sulfur-trioxide" },
	-- issue #188: the forge hammer crushes raw sheldonite too, so the auto-unlock no longer places the macerator recipe
	["platinum-ore-processing"] = { "crushed-sheldonite" },
	-- issue #262: the dissolution tank of the monazite line makes thorianite too, so the auto-unlock no longer places the
	-- blast furnace recipe of the thorium-yttrium glass
	["fluid-shaper"] = { "thorianite" },
}
--- issue #237: the EV Alloy Blast Smelter needs a heat vent block, which takes a staballoy frame; the frame came only with
--- industrial-extrusion-machine (IV), the staballoy rods it is made from are there at EV, so the Alloy Blast Smelter
--- technology could not build its own machine; the Zyngen controller needs a large tantalum carbide gear, but molten
--- tantalum carbide (Alloy Blast Smelter) and its ingot cast came only with max-machines
local UNLOCKS_237 = {
	["alloy-blast-smelter"] = { "staballoy-frame" },
	["zyngen"] = { "molten-tantalum-carbide", "solidify-tantalum-carbide-ingot" },
}
for _, list in pairs({ UNLOCKS, KEEP, UNLOCKS_98, UNLOCKS_96, UNLOCKS_205, UNLOCKS_237 }) do
	for tech, recipes in pairs(list) do
		for _, r in pairs(recipes) do
			if data.raw.recipe[r] then fork_add_unlock(tech, r) else log("FORK-UNLOCK: missing recipe: " .. r) end
		end
	end
end

--- issue #239: the gaps the check of #237 found, as the maintainer decided them (2026-10-11)
local function move_unlock(recipe, from, to)
	local t = data.raw.technology[from]
	local keep, found = {}, false
	for _, e in pairs(t and t.effects or {}) do
		if e.type == "unlock-recipe" and e.recipe == recipe then found = true else keep[#keep + 1] = e end
	end
	if not found then error("142-fork-recipe-unlocks: " .. from .. " does not unlock " .. recipe) end
	t.effects = keep
	fork_add_unlock(to, recipe)
end
local function add_prerequisite(tech, pre)
	local t = data.raw.technology[tech]
	for _, p in pairs(t.prerequisites or {}) do if p == pre then return end end
	t.prerequisites = t.prerequisites or {}
	table.insert(t.prerequisites, pre)
end
--- the logistic chests are HV assembler recipes: they come with HV Machines (Logistic System and the ME network stay MV)
for _, r in pairs({ "requester-chest", "active-provider-chest", "passive-provider-chest", "storage-chest", "buffer-chest" }) do
	move_unlock(r, "logistic-system", "hv-machines")
end
--- the advanced SMDs are IV/LuV parts, as in GTNH: their materials' technologies and the IV Large Chemical Reactor first
--- (issue #252: not Qubit CPUs, whose quantum processors take advanced SMDs; the SMD diode's indium gallium phosphide
--- comes with IV Energy Hatches, see below)
for _, pre in pairs({ "graphene", "vanadium-gallium", "luv-components", "iv-machines" }) do
	add_prerequisite("advanced-smds", pre)
end
--- the osmium solution of the platinum line needs the IV Tall Distillation Tower (issue #252: it comes with IV Energy
--- Hatches, a prerequisite of Osmium in FORK_UNLOCK_TREE); HSS-S takes osmium dust, so it follows Osmium
add_prerequisite("osmium", "iv-machines")
add_prerequisite("hsss", "osmium")
--- the Fluid Nuclear Reactor's iridium neutron reflector takes LuV parts
add_prerequisite("fluid-nuclear-reactor", "fusion-reactor-mk1")
add_prerequisite("fluid-nuclear-reactor", "naquadah-processing")
--- issue #251: the inductor (Microprocessors) takes the nickel zinc ferrite ring; the ferrite chain comes where it is first
--- used (GTNH: the ferrite ingot in the MV blast furnace, its ring in the LV and MV inductor); the SMD inductor stays with
--- SMD Components
for _, r in pairs({ "nickel-zinc-ferrite-dust", "nickel-zinc-ferrite-ingot", "nickel-zinc-ferrite-ring" }) do
	move_unlock(r, "smd-components", "microprocessors")
end
--- issue #295: Tantalloy-60 (the gear of the EV Rocket Engine, 145) comes with Rocket Engines, its first consumer now (its
--- tantalum and tungsten dusts and the alloy blast smelter are EV); the Industrial Wire Factory follows it
move_unlock("molten-tantalloy-60", "industrial-wire-factory", "rocket-engines")
add_prerequisite("industrial-wire-factory", "rocket-engines")
--- the SMD diode takes fine platinum wire: with the platinum smelting, Platinum (the SMD variant of the microprocessor
--- supercomputer waits for it; its plain recipe stays with Microprocessors)
for _, r in pairs({ "platinum-dust-smelter", "platinum-dust-multismelter", "fine-platinum-wire", "smd-diode" }) do
	move_unlock(r, "smd-components", "platinum")
end

--- issue #252, the maintainer's rule: every item and fluid is unlocked at the technology where it can first be consumed,
--- never later (devcheck's tree check: the technology or one of its prerequisites makes it). A producer whose own inputs
--- are there moves up to its first consumer; a producer in another branch of no higher science becomes a prerequisite
--- (FORK_UNLOCK_TREE.prerequisites); only where the producer's own chain is late (platinum, the energy hatches of a tier, the
--- advanced SMDs) the consumer goes to the producer's technology.
--- the producers that move up: recipe, from, to (the comment: what takes it there)
for _, m in pairs({
	-- issue #320: the mold (4 steel plates) comes with the steel, where its first users are (the steel nuggets and
	-- casings); the steam technologies before it have no steel, so the mold recipes of 158 wait for it (unlock_after counts
	-- the mold) and the glass of the alloy smelter stays with Glassmaking, the forge hammer's glass dust with it (below)
	{ "mold", "glassmaking", "steel-processing" },
	{ "lv-centrifuge", "ore-centrifuging", "ore-washing" },                    -- the garnet decompositions (#207)
	{ "molten-tin", "electric-blast-furnace", "concrete" },                    -- the tin and red alloy casts
	{ "molten-red-alloy", "improved-electronic-parts", "concrete" },
	{ "mv-emitter", "advanced-mv-machines", "laser-engraver" },                -- MV Laser Engraver (ILC, RAM, NAND wafers)
	{ "electrum-rod", "advanced-mv-machines", "laser-engraver" },
	{ "electrum-ingot", "advanced-integrated-circuits", "laser-engraver" },
	{ "crushed-beryllium", "advanced-mv-machines", "laser-engraver" },
	{ "chromium-ingot", "advanced-hv-machines", "hv-components" },              -- chromium rod of the HV sensor
	{ "chromium-rod", "advanced-hv-machines", "hv-components" },
	{ "hv-emitter", "advanced-hv-machines", "hv-machines" },                    -- HV Laser Engraver
	{ "clean-stainless-steel-casing", "bauxite-slurry-process", "hv-energy-hatches" },   -- HV Drilling Rig
	{ "molten-naquadah", "zpm-superconductors", "naquadah-processing" },        -- naquadah casts
	{ "silicon-ingot", "advanced-integrated-circuits", "overworld-data" },      -- printed silicon of the AE2 processors
	{ "silicon-plate", "advanced-integrated-circuits", "overworld-data" },
	{ "poly-si-dust", "mcsb", "overworld-data" },
	{ "silicon-tetrachloride", "mcsb", "overworld-data" },
	{ "platinum-wire", "nuclear-power", "platinum" },                           -- EV Electrolyzer
	{ "indium-gallium-phosphide", "qubit-cpus", "iv-energy-hatches" },          -- HPIC wafer, advanced SMD diode
	{ "robust-tungstensteel-machine-casing", "large-extractor", "space-science-pack" },   -- LuV science pack
	-- issue #517: the hot iridium ingot of the IV sensor's and emitter's iridium rods (GT's 4500 K, the RTM alloy coils)
	{ "iv-electric-blast-furnace", "iv-machines", "iv-components" },
}) do
	move_unlock(m[1], m[2], m[3])
end
--- the consumers whose producer's chain is late go to the producer's technology: recipe, from, to (the comment: the late
--- producer)
for _, m in pairs({
	{ "glass-dust-forge-hammer", "steam-forge-hammer", "glassmaking" },         -- glass (the alloy smelter's, with the mold)
	{ "long-aluminium-rod", "aluminium", "extruder" },                          -- MV extruder (MV hull, MV piston)
	{ "aluminium-spring", "aluminium", "extruder" },                            -- its long aluminium rod
	{ "liquid-ender-air", "end-steel", "ev-machines" },                         -- (the EV compressor's ender air)
	{ "ender-air-distillation", "end-steel", "ev-machines" },
	{ "ev-field-generator", "ev-components", "extreme-entity-crushers" },       -- nether star (the wither)
	{ "ev-circuit-assembler", "ev-machines", "advanced-ev-machines" },          -- EV emitter (platinum rod)
	{ "ev-laser-engraver", "ev-machines", "advanced-ev-machines" },
	{ "ev-electrolyzer", "ev-machines", "platinum" },                           -- platinum wire
	{ "quantum-processor-mainframe", "luv-components", "advanced-smds" },       -- advanced SMD capacitor and inductor
	{ "nor-memory-wafer-nd", "naquadah-processing", "water-purification" },     -- grade 5 water
	{ "microprocessor-supercomputer-smd", "smd-components", "platinum" },       -- SMD diode (platinum, #239)
	{ "ilmenite-processing", "titanium", "ev-machines" },                       -- EV chemical bath
}) do
	move_unlock(m[1], m[2], m[3])
end
--- the multiblocks of IV and LuV Machines take the energy hatch of their tier (insane voltage coil, HPIC; UHPIC)
for _, r in pairs({ "iv-alloy-blast-smelter", "iv-cracker", "iv-implosion-compressor", "iv-large-chemical-reactor",
	"iv-short-distillation-tower", "iv-tall-distillation-tower", "iv-turbocan-pro", "iv-vacuum-freezer" }) do
	move_unlock(r, "iv-machines", "iv-energy-hatches")
end
for _, r in pairs({ "luv-alloy-blast-smelter", "luv-cracker", "luv-implosion-compressor", "luv-large-chemical-reactor",
	"luv-short-distillation-tower", "luv-tall-distillation-tower", "luv-vacuum-freezer" }) do
	move_unlock(r, "luv-machines", "luv-energy-hatches")
end
--- issue #556: a machine comes with its first recipe: the HV Cracker (and its controller, which only the cracker takes)
--- with Oil Processing, since 161 sends the heated bauxite slurry of Bauxite Slurry Process to Reach the Moon
for _, r in pairs({ "cracker-controller", "hv-cracker" }) do
	move_unlock(r, "bauxite-slurry-process", "oil-processing")
end
--- the producer's technology as a prerequisite, where the producer is in another branch of no higher science (the
--- technology: its new prerequisites; the comment: what the technology's recipes take from them, "machine" for the machine
--- of a recipe category). Applied here, so the unlocks of 155 and 158 (unlock_after) see them, and once more by
--- data-final-fixes.lua after it sets the vanilla technologies' prerequisites.
FORK_UNLOCK_TREE = { prerequisites = {
	["advanced-ev-machines"] = { "platinum" },   -- platinum-ingot
	["advanced-integrated-circuits"] = { "nand-chips", "oil-gathering" },   -- fine-tin-wire; lubricant
	["alloy-blast-smelter"] = { "nuclear-power" },   -- platinum-cable
	["aluminium"] = { "cutting-machine" },   -- machine lv-cutting-machine
	["assembly-line"] = { "industrial-precision-lathe" },   -- grate-machine-casing
	["black-steel"] = { "electric-blast-furnace", "galena", "rare-earth-processing" },   -- machine mv-electric-blast-furnace; silver-ingot; nether-quartz
	["bio-processors"] = { "qubit-cpus" },   -- qubit-cpu-chip
	["cetane-boosted-diesel"] = { "implosion-compressor" },   -- nitric-acid
	["dimensionally-shifted-superfluid"] = { "radox-polymer" },   -- super-heavy-radox (issue #517)
	["concrete"] = { "automation-2", "extractor" },   -- machine lv-assembling-machine; lv-pump (the LV Fluid Extractor, issue #556)
	["crystal-processors"] = { "advanced-smds" },   -- advanced-smd-capacitor
	["elevated-rail"] = { "railway" },   -- rail
	-- issue #556 (the maintainer's decision): the EV to ZPM Dehydrators run the LV to HV dehydrator recipes only (their own
	-- categories are empty, as in GT++), the first of which come with Hydrazine Rocket Fuels (EV)
	["ev-chemical-dehydrator"] = { "hydrazine-rocket-fuels" },   -- a recipe for the machine
	["iv-chemical-dehydrator"] = { "hydrazine-rocket-fuels" },
	["luv-chemical-dehydrator"] = { "hydrazine-rocket-fuels" },
	["zpm-chemical-dehydrator"] = { "hydrazine-rocket-fuels" },
	["ev-energy-hatches"] = { "platinum" },   -- fine-platinum-wire
	["ev-machines"] = { "nichrome-coils" },   -- nichrome-wire
	["extreme-entity-crushers"] = { "ev-energy-hatches" },   -- ev-energy-hatch
	["fusion-reactor-mk1"] = { "advanced-smds" },   -- zpm-circuit
	["fusion-plasmas-mk2"] = { "nuclear-fuel-rods" },   -- plutonium-239-dust (issue #375: the naquadah transmutation)
	["fusion-plasmas-mk5"] = { "reach-the-everglades" },   -- tellurium-dust (issue #397: lead plasma)
	["fusion-reactor-mk2"] = { "zpm-assembly-line" },   -- machine zpm-assembly-line
	["galena"] = { "concrete" },   -- machine lv-fluid-solidifier
	["gas-turbine"] = { "semifluid-generator", "sulfuric-acid" },   -- machine lv-canning-machine; machine lv-distillation
	["graphene"] = { "ev-energy-hatches" },   -- machine ev-chemical-reactor
	["high-octane-gasoline"] = { "ev-energy-hatches" },   -- machine ev-chemical-reactor
	["hv-energy-hatches"] = { "vacuum-freezers" },   -- mv-vacuum-freezer
	["hv-machines"] = { "me-network" },   -- me-drive
	["hyper-intensity-laser-engraver"] = { "fluid-shaper" },   -- thorium-yttrium-glass-block
	["industrial-centrifuge"] = { "industrial-extrusion-machine", "large-sifter" },   -- inconel-reinforced-casing; tumbaga-rod
	["industrial-wire-factory"] = { "large-sifter", "large-steam-turbine" },   -- long-tumbaga-rod; blue-steel-frame
	["iridium"] = { "ev-energy-hatches" },   -- machine ev-chemical-reactor
	["iv-components"] = { "extreme-entity-crushers", "nuclear-power", "tungstensteel", "iridium", "rtm-alloy-coils" },   -- nether-star; platinum-cable; tungstensteel-rod; iridium-dust, rtm-alloy-coil-block of the IV EBF (issue #517)
	["iv-energy-hatches"] = { "large-steel-boiler", "vanadium-gallium" },   -- steel-pipe-casing; molten-vanadium-gallium
	["iv-machines"] = { "nanoprocessors", "rtm-alloy-coils" },   -- luv-circuit; rtm-alloy-coil-block
	["kanthal-coils"] = { "multismelter" },   -- mv-multismelter
	["large-extractor"] = { "fluid-shaper", "space-science-pack" },   -- thorium-yttrium-glass-block; indovanadium-superconductive-wire
	["logistic-science-pack"] = { "logistics" },   -- transport-belt
	["luv-components"] = { "niobium-titanium" },   -- niobium-titanium-wire
	["luv-machines"] = { "alloy-blast-smelting-older-materials", "tungsten-carbide" },   -- molten-rtm-alloy; tungsten-carbide-ingot
	["magnetic-flux-exhibiter"] = { "space-science-pack" },   -- indovanadium-superconductive-wire
	["max-machines"] = { "hyper-intensity-laser-engraver" },   -- nitinol-60-rod
	["microprocessors"] = { "kanthal-coils" },   -- aluminium-foil
	["military-science-pack"] = { "circuit-assembler" },   -- lv-emitter
	["nanoprocessors"] = { "ev-energy-hatches" },   -- machine ev-chemical-reactor
	["naquadah-fuels"] = { "uv-materials" },   -- neutronium-ingot
	["neodymium"] = { "hv-machines" },   -- machine hv-polarizer
	["niobium-and-tantalum-extraction"] = { "ptfe" },   -- hydrofluoric-acid
	["niobium-titanium"] = { "titanium" },   -- titanium-ingot
	["nuclear-fuel-rods"] = { "uranium-processing" },   -- uraninite-dust
	["ore-centrifuging"] = { "concrete" },   -- machine lv-fluid-solidifier
	["ore-crushing"] = { "electrolyzer" },   -- raw-vanadium-magnetite
	["ore-washing"] = { "automation-2" },   -- lv-conveyor-module
	["osmium"] = { "iv-energy-hatches" },   -- machine iv-tall-distillation
	["phosphorus-processing"] = { "sulfuric-acid", "lv-miner" },   -- sulfuric-acid; machine lv-miner (issue #337: the twins of
	-- every later vein, whose technologies all follow Phosphorus Processing)
	["plasma-turbine"] = { "industrial-mixer" },   -- titanium-turbine-casing
	["polybenzimidazole"] = { "alloy-blast-smelter" },   -- machine hv-alloy-blast-smelter
	["precise-electronic-unit-mk3"] = { "bio-processors" },   -- bio-processing-unit, qubit-cpu-chip (Qubit CPUs before it; issue #517)
	["production-science-pack"] = { "radon" },   -- quantum-eye
	["qubit-cpus"] = { "iv-energy-hatches" },   -- indium-gallium-phosphide
	["radar"] = { "circuit-assembler" },   -- brass-rod
	["reach-the-moon"] = { "ore-drilling-plant-mk1", "bauxite-slurry-process" },   -- machine ore-drilling-plant-mk1 (issue #335: the Moon's twins); bauxite-slurry (issue #556: before through Oil Processing, whose HV Cracker needed it)
	["rare-earth-processing"] = { "ore-washing" },   -- rare-earth
	["rhodium-plated-palladium"] = { "iv-machines" },   -- machine iv-fluid-extractor
	["rocket-fuel"] = { "implosion-compressor" },   -- ammonia
	["rtm-alloy-coils"] = { "ruthenium", "tungsten" },   -- ruthenium-dust; tungsten-dust
	["ruthenium"] = { "epoxy-processing" },   -- salt-water
	["semifluid-generator"] = { "lathe" },   -- bronze-rod
	["smd-components"] = { "polyvinyl-chloride" },   -- thin-pvc-sheet
	["staballoy"] = { "titanium" },   -- titanium-ingot
	["super-glue"] = { "iv-energy-hatches" },   -- machine iv-chemical-reactor
	["tungstate-processing"] = { "ev-machines" },   -- machine ev-autoclave
	["tungsten"] = { "ev-energy-hatches" },   -- machine ev-chemical-reactor
	["utility-science-pack"] = { "ev-machines" },   -- machine ev-assembling-machine
	["zpm-assembly-line"] = { "me-storage-256k" },   -- fiber-reinforced-circuit-board
} }
--- recipes of 155 and 158 (unlock_after: the first technology after the machine and the inputs) that the moves above
--- would send to a technology of a higher science than before: they stay where they were (the recipe: its technology)
FORK_UNLOCK_TREE.keep = {
	["nickel-zinc-ferrite-gear"] = "smd-components",          -- the MV extruder and the ferrite (Microprocessors)
	["large-nickel-zinc-ferrite-gear"] = "smd-components",
	["purified-copper-mercury"] = "primitive-electronic-circuit-assemblies",   -- mercury and the chemical bath
	["purified-gold-mercury"] = "primitive-electronic-circuit-assemblies",
	-- issue #335: Reach the Moon's new prerequisite (the Ore Drilling Plant Mk I) gives it more ancestors at 155's time,
	-- so the hammering of the Moon's crushed ores would go to Titanium (EV); the Moon's hammer makes them
	["hammering-crushed-chromite"] = "reach-the-moon",
	["hammering-crushed-ilmenite"] = "reach-the-moon",
}
function FORK_UNLOCK_TREE.apply(final)
	for tech, pres in pairs(FORK_UNLOCK_TREE.prerequisites) do
		for _, p in pairs(pres) do
			if data.raw.technology[tech] and data.raw.technology[p] then
				add_prerequisite(tech, p)
			elseif final then
				error("142-fork-recipe-unlocks: no technology " .. tech .. " or " .. p)
			end
		end
	end
	if not final then return end
	for recipe, tech in pairs(FORK_UNLOCK_TREE.keep) do
		for _, t in pairs(data.raw.technology) do
			local keep = {}
			for _, e in pairs(t.effects or {}) do
				if not (e.type == "unlock-recipe" and e.recipe == recipe) then keep[#keep + 1] = e end
			end
			if t.effects and #keep < #t.effects then t.effects = keep end
		end
		if not data.raw.recipe[recipe] then error("142-fork-recipe-unlocks: no recipe " .. recipe) end
		fork_add_unlock(tech, recipe)
	end
end
FORK_UNLOCK_TREE.apply()
--- issue #337 (163): the miners' twins of the veins, after the moves above and the prerequisites (a vein before the LV
--- Miner comes with it, a later one with its own technology)
FORK_ELECTRIC_MINE.unlock_miner_twins()
--- issue #556 (163): each dimension mine with the first technology of a recipe it runs, or its own when that is later
FORK_ELECTRIC_MINE.unlock_dimension_mines()



--------------------------------------------------------------------------------
--- 4) RECIPES THAT STAY LOCKED (devcheck's allow-list, read from the dump of checkmod)
--------------------------------------------------------------------------------

--- issue #237: recipes a technology unlocks before the technologies of its science can make them, kept on purpose:
--- "<technology>:<cause>" -> reason (the cause as `devcheck.py check` names it: the first missing item, or the recipe
--- whose machine is missing); devcheck fails for any other such recipe and for an entry that matches nothing
FORK_UNLOCK_GAPS = {
	["uv-components:uhv-circuit"] = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note): craftable once that circuit is",
	["uhv-components:uev-circuit"] = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note): craftable once that circuit is",
	["uev-components:uiv-circuit"] = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note): craftable once that circuit is",
	["uiv-components:umv-circuit"] = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note): craftable once that circuit is",
	["umv-components:uxv-circuit"] = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note): craftable once that circuit is",
	-- issue #447: the steam macerator runs copies without byproducts (101); with red science the steam copies make the crushed
	-- calcite and the impure calcite dust, the LV recipes with their andradite byproduct wait for the LV macerator
	["steel-processing:calcite"] = "issue #447: the LV recipe (andradite byproduct) waits for the LV macerator; the steam macerator's copy makes the crushed calcite",
	["steel-processing:impure-calcite-dust"] = "issue #447: the LV recipe (andradite byproduct) waits for the LV macerator; the steam macerator's copy makes the impure calcite dust",
}

--- issue #252: items a technology's recipes take that neither it nor its prerequisites make, kept on purpose:
--- "<technology>:<item>" -> reason (for a machine: its item); devcheck fails for any other such item and for an entry
--- that matches nothing
local FIELD_GENERATOR = "GT's field generator takes the next tier's circuit; kept with the components on purpose (128, phase 3 note; #237): craftable once that circuit is"
FORK_UNLOCK_TREE_GAPS = {
	["luv-components:zpm-circuit"] = FIELD_GENERATOR,
	["uv-components:uhv-circuit"] = FIELD_GENERATOR,
	["uhv-components:uev-circuit"] = FIELD_GENERATOR,
	["uev-components:uiv-circuit"] = FIELD_GENERATOR,
	["uiv-components:umv-circuit"] = FIELD_GENERATOR,
	["umv-components:uxv-circuit"] = FIELD_GENERATOR,
}

--- issue #556: machines a technology unlocks before any recipe they can run, kept on purpose: "<technology>:<machine>" ->
--- reason; devcheck fails for any other such machine and for an entry that matches nothing
local NEXT_TECH = "the machine's own technology; its first recipes come with the technology right after it, "
FORK_MACHINES_BEFORE_RECIPES = {
	["assembly-line:luv-assembly-line"] = NEXT_TECH .. "LuV Components (GT: the assembly line makes the LuV parts)",
	["fusion-reactor-mk1:fusion-reactor-mk1"] = NEXT_TECH .. "Fusion Plasmas Mk1",
	["godforge:godforge"] = NEXT_TECH .. "the godforge's plasma module",
	["nano-forge:nano-forge"] = NEXT_TECH .. "Nano Forge Tier 2 (neutronium nanites)",
	["space-elevator-assembler-module-mk1:space-elevator-assembler-module-mk1"] = NEXT_TECH .. "ME Storage Singularity",
	["mv-machines:mv-rock-crusher"] = "a tier machine comes with its tier's Machines technology like the others of the tier; "
		.. "it runs the LV Rock Crusher's recipe, which comes with Rock Crusher (LV)",
}
for _, t in pairs({ "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }) do
	for _, m in pairs({ "brewery", "fermenter" }) do
		FORK_MACHINES_BEFORE_RECIPES[t .. "-machines:" .. t .. "-" .. m] = "a tier machine comes with its tier's Machines "
			.. "technology like the others of the tier; it runs the LV " .. m .. "'s recipes, which come with Fermentation (LV, 164)"
	end
end

FORK_RECIPES_LOCKED = {
	["calcium"] = "upstream placeholder without ingredients (an item from nothing); calcium comes from fluorspar",
	["cerium-rich-mixture"] = "upstream placeholder without ingredients; the mixture comes from bastnasite",
	["phosphorus"] = "upstream placeholder without ingredients; phosphorus comes from the phosphorus line",
	--- issue #215 (the maintainer's decision): armour equipment that needs an armour with an equipment grid and a power
	--- source in it, which Gregtorio does not have (the vanilla armour and equipment technologies are disabled)
	["me-wireless-module"] = "armour equipment; Gregtorio has no armour with an equipment grid (the Wireless ME Terminal item does the same)",
}
