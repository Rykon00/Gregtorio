--------------------------------------------------------------------------------
--- FORK UXV (roadmap phase 5b)
--- Makes the UXV tier playable on top of the finished UMV tier (133-fork-umv.lua):
---   * universium parts (the UXV metal, from the fusion reactor MK5), universium cable and the
---     eternity superconductor
---   * the temporal line: temporal board, temporal processing unit, temporal processor, assembly,
---     supercomputer and the mainframe (= the UXV circuit)
---   * UXV components from the ZPM assembly line, UXV casing and hull
---   * UXV science pack, UXV voltage coil, eternal coil, UXV energy hatch
---   * UXV machines: the UMV machines one tier up (fork_make_tier_machine)
---   * the UXV technologies, and the workaround of 133-fork-umv.lua that is not needed any more
---     (UMV field generator)
--- 90-uxv-age-item.lua is not loaded by data.lua (it is not valid Lua and holds the GTNH
--- endgame chains: magmatter, dark matter, shirabon, mellion, the stargate parts), so the parts of
--- it that phase 5b needs are rebuilt here and in 135-fork-endgame.lua.
--- The shared helpers (F.components, F.circuit_line, ...) are defined in 133-fork-umv.lua.
--------------------------------------------------------------------------------

local F = FORK5B



--------------------------------------------------------------------------------
--- 1) UNIVERSIUM, THE UXV METAL, ITS CABLE AND THE ETERNITY SUPERCONDUCTOR
--- The melt comes from the MK5 (133-fork-umv.lua: spacetime + flerovium). Parts like the spacetime
--- ones. The superconductor is invented on the pattern of hypocosmium: equal parts universium,
--- spacetime and hypocosmium (the draft has an "eternal coil" for the UXV coil; the name eternity
--- is the one of the example in 03-helper-functions-module.lua). Cooled like the UMV one (UXV pump,
--- melt, cryogenic helium).
--------------------------------------------------------------------------------

F.metal("universium", "umv", UMV_SPEED)
F.cable("universium")

create_ingot("eternity", "umv", 10 * UMV_SPEED, {
		{ type = "item", name = "universium-ingot", amount = 3 },
		{ type = "item", name = "spacetime-ingot", amount = 3 },
		{ type = "item", name = "hypocosmium-ingot", amount = 3 },
	},
	9, "umv", UMV_SPEED * 99, F.argon(),
	"umv", UMV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "eternity", speed = 10, make_wire = true }
create_item{
	name = "eternity-superconductive-wire",
	category = "umv-assembling-machine-recipes",
	energy_required = UMV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "eternity-wire", amount = 24 },
		{ type = "item", name = "uxv-pump", amount = 1 },
		{ type = "fluid", name = "molten-universium", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1400 },
	},
	results = {
		{ type = "item", name = "eternity-superconductive-wire", amount = 24 },
	},
}
create_recipe{
	recipe_name = "superconducting-coil-block-uxv",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-superconductive-wire", amount = 1 },
		{ type = "item", name = "niobium-titanium-foil", amount = 1 },
		{ type = "fluid", name = "molten-trinium", amount = 0.9 },
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 },
	},
}



--------------------------------------------------------------------------------
--- 2) THE TEMPORAL LINE (GT: the temporally transcendent mainframe is the UXV circuit)
--- The exotic line one step up, 10 % slower: temporal board (exotic board + universium foil), temporal
--- processing unit (exotic unit + a gravi star, 4 per craft), temporal processor (takes exotic
--- processors), assembly, supercomputer and the mainframe with the UMV superconductor.
--------------------------------------------------------------------------------

F.circuit_line{
	prefix = "temporal", circuit = "uxv-circuit", prev = "exotic", metal = "universium",
	sc_wire = "hypocosmium-superconductive-wire", unit_source = "exotic-processing-unit",
	board_source = "exotic-printed-circuit-board", assembler_tier = "umv", speed = 1.1,
}



--------------------------------------------------------------------------------
--- 3) UXV COMPONENTS (zpm-assembly-line-recipes, like the UMV ones)
--- The UMV recipes with universium and universium cable; spacetime plates in the pump, UXV, UMV and UIV
--- circuits in the robot arm.
---   * field generator: 8 UXV circuits (GT: MAX circuits, not built)
--------------------------------------------------------------------------------

F.components{
	tier = "uxv", metal = "universium", cable = "universium-cable", circuit = "uxv-circuit",
	arm_circuits = { { "uxv-circuit", 2 }, { "umv-circuit", 4 }, { "uiv-circuit", 8 } },
	prev_plate = "spacetime-plate", field_circuit = { "uxv-circuit", 8 }, hull_fluid = 144,
}



--------------------------------------------------------------------------------
--- 4) UXV VOLTAGE COIL, ETERNAL COIL AND UXV ENERGY HATCH
--- GT: the UXV coil is a magnetic samarium rod with 16 fine universium wires. The UXV blast furnace
--- coil is the eternal coil of the draft in 90-uxv-age-item.lua (an optical mainframe, spacetime wire,
--- screws and foil, an eternal singularity, a melt); here it is universium wire and screws, spacetime
--- foil, a UMV circuit and a spacetime melt. Energy hatch as in 133-fork-umv.lua, with twice the
--- QPICs.
--------------------------------------------------------------------------------

create_item{
	name = "extended-mega-ultimate-voltage-coil",
	category = "uxv-assembling-machine-recipes",
	energy_required = 10 * UXV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-universium-wire", amount = 16 },
	},
}
create_item{
	name = "eternal-coil-block",
	category = "umv-assembling-machine-recipes",
	energy_required = 60 * UMV_SPEED,
	ingredients = {
		{ type = "item", name = "universium-wire", amount = 16 },
		{ type = "item", name = "universium-screw", amount = 8 },
		{ type = "item", name = "spacetime-foil", amount = 8 },
		{ type = "item", name = "umv-circuit", amount = 1 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
	},
}
create_item{
	name = "uxv-energy-hatch",
	category = "zpm-assembly-line-recipes",
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "uxv-machine-hull", amount = 1 },
		{ type = "item", name = "eternity-superconductive-wire", amount = 4 },
		{ type = "item", name = "quantum-power-ic", amount = 32 },
		{ type = "item", name = "uxv-circuit", amount = 2 },
		{ type = "item", name = "extended-mega-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "uxv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
	},
}



--------------------------------------------------------------------------------
--- 5) UXV SCIENCE PACK, like the UMV pack in 133-fork-umv.lua: the tier's motor and circuits, its
--- main metal, the coils of the tier below, the field generator of the tier below and a melt ->
--- 10 packs. It replaces the upstream stone recipe (removed in 132-fork-uiv.lua) and is made in the
--- UMV assembler (the UXV machines need the pack).
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "uxv-science-pack",
	category = "umv-assembling-machine-recipes",
	energy_required = UMV_SPEED * 60,
	order = "n",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 1 },
		{ type = "item", name = "uxv-circuit", amount = 2 },
		{ type = "item", name = "universium-plate", amount = 4 },
		{ type = "item", name = "spacetime-coil-block", amount = 4 },
		{ type = "item", name = "umv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-universium", amount = 144 },
	},
	results = {
		{ type = "item", name = "uxv-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 6) UXV MACHINES (copies of the UMV machines, recipe one tier up; 101-fork-machines.lua)
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["uxv-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "uxv-age-production-machine", group = "production", order = "i-z-uxv" } })
end

UXV_BASIC_MACHINES = UMV_BASIC_MACHINES
UXV_UPGRADE_MACHINES = UMV_UPGRADE_MACHINES

local uxv_machine_recipes, uxv_multiblock_recipes = {}, {}
for _, base in pairs(UXV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "umv", "uxv", 6, nil)
	uxv_machine_recipes[#uxv_machine_recipes + 1] = "uxv-" .. base
end
for _, base in pairs(UXV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "umv", "uxv", nil, nil)
	uxv_multiblock_recipes[#uxv_multiblock_recipes + 1] = "uxv-" .. base
end



--------------------------------------------------------------------------------
--- 7) WORKAROUNDS OF PHASE 5b THAT ARE NOT NEEDED ANY MORE
---   * UMV field generator: 4 UXV circuits like GT (it used 8 UMV circuits). The recipe stays
---     unlocked by umv-components, so saves that had it keep it (it is craftable once the UXV
---     circuit is; only the UXV science pack needs it).
--------------------------------------------------------------------------------

F.replace_ingredient("umv-field-generator", "umv-circuit", "uxv-circuit", 4)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- UMV science (lead to the UXV science pack): universium, the temporal line, the UXV circuit and
--- the UXV components.
--- UXV science: machines, energy hatch, multiblocks.
--------------------------------------------------------------------------------

--- UMV science
do
	F.tech{
		name = "uxv-materials", prerequisites = { "umv-multiblocks" }, packs = 13, count = 2500,
		recipes = F.join({ "universium-cable" }, F.metal_parts("universium", F.ALL_PARTS)),
	}
	F.tech{
		name = "temporal-processors", prerequisites = { "uxv-materials", "exotic-processor-mainframes" }, packs = 13, count = 3000,
		recipes = { "temporal-printed-circuit-board", "temporal-processing-unit", "temporal-processor",
			"temporal-processor-assembly", "temporal-processor-supercomputer" },
	}
	F.tech{
		name = "temporal-processor-mainframes", prerequisites = { "temporal-processors" }, packs = 13, count = 3000,
		recipes = { "temporal-processor-mainframe" },
	}
	F.tech{
		name = "uxv-components", prerequisites = { "temporal-processor-mainframes" }, packs = 13, count = 3500,
		recipes = {
			"uxv-motor", "uxv-pump", "uxv-conveyor-module", "uxv-piston", "uxv-robot-arm", "uxv-emitter", "uxv-sensor",
			"uxv-field-generator", "uxv-machine-casing", "uxv-machine-hull",
		},
	}
end

--- The UXV science tech (upstream, researched with UMV science) unlocks the pack (the upstream
--- effect stays; the recipe is defined above)
table.insert(data.raw.technology["uxv-science-pack"].prerequisites, "uxv-components")

--- UXV science. Machines first: the UXV voltage coil needs the UXV assembler.
F.tech{
	name = "uxv-machines", prerequisites = { "uxv-science-pack" }, packs = 14, count = 3000,
	recipes = uxv_machine_recipes,
}
F.tech{
	name = "uxv-energy-hatches", prerequisites = { "uxv-machines" }, packs = 14, count = 3000,
	recipes = {
		"hot-eternity-ingot", "eternity-ingot", "eternity-dust", "eternity-wire",
		"eternity-superconductive-wire", "superconducting-coil-block-uxv", "eternal-coil-block",
		"extended-mega-ultimate-voltage-coil", "uxv-energy-hatch",
	},
}
F.tech{
	name = "uxv-multiblocks", prerequisites = { "uxv-energy-hatches" }, packs = 14, count = 3000,
	recipes = uxv_multiblock_recipes,
}
