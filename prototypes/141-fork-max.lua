--------------------------------------------------------------------------------
--- FORK MAX (roadmap phase 6b, issue #37)
--- The MAX tier, on top of the UXV tier (134-fork-uxv.lua) and the godforge (140-fork-godforge.lua),
--- after `victory`: MAX science (the packs of the stargate) for every technology.
---   * magmatter, the MAX metal (GT: the godforge's exotic module), its parts and the magmatter cable
---   * the Planck line: Planck board, processing unit, processor, assembly, supercomputer and the mainframe
---     (= the MAX circuit; GTNH's MAX circuit is the Planck-scale circuit of the nanochip assembly complex;
---     GT's own "transcendent" names are taken by the fork's UXV line, the "temporally transcendent" one)
---   * MAX components from the ZPM assembly line, MAX casing and hull
---   * MAX voltage coil, MAX energy hatch and dynamo hatch, a MAX large plasma turbine
---   * MAX machines: the UXV machines one tier up (fork_make_tier_machine), the 23 basic machines and the
---     13 multiblock upgrades
---   * a second MAX science pack recipe from MAX parts and magmatter (the stargate recipe stays)
--- GT has the MAX circuit and the MAX component items, but no recipe for the components, no MAX hatches,
--- no MAX superconductor and no MAX machines except a circuit assembler without recipe. Everything here
--- follows the UMV -> UXV step of 133/134 (GT's ResearchStationAssemblyLine does the same up to UXV).
--------------------------------------------------------------------------------

local F = FORK5B

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end



--------------------------------------------------------------------------------
--- 0) MAX RECIPE CATEGORIES AND SUBGROUPS (05-definitions-module.lua stops at UXV)
--------------------------------------------------------------------------------

for _, rest in pairs({ "wiremill", "bending-machine", "lathe", "alloy-smelter", "polarizer", "autoclave",
	"compressor", "extruder", "fluid-solidifier", "sifter", "macerator", "canning-machine", "electrolyzer",
	"cutting-machine", "laser-engraver", "chemical-reactor", "circuit-assembler", "electric-blast-furnace",
	"distillation", "tall-distillation", "mixer", "implosion-compressor", "chemical-bath", "extractor",
	"assembly-line", "centrifuge", "assembling-machine", "vacuum-freezer", "cracker", "alloy-blast-smelter",
	"microverse-projector", "dehydrator", "extreme-entity-crusher" }) do
	F.category("max-" .. rest .. "-recipes")
end
for _, sg in pairs({
	{ "max-age-production-machine", "i-z-max" },
	{ "subgroup-max-age-multiblocks", "q-max" },
}) do
	if not data.raw["item-subgroup"][sg[1]] then
		data:extend({ { type = "item-subgroup", name = sg[1], group = "production", order = sg[2] } })
	end
end



--------------------------------------------------------------------------------
--- 1) MAGMATTER, THE MAX METAL, AND ITS CABLE
--- The melt comes from the godforge (140-fork-godforge.lua). Parts like the universium ones, made in the
--- UXV machines (a metal's parts come from the tier below, which builds the machines of its own tier).
--- GT's UXV parts already use magmatter (gears, foil, fine wire); its UXV hull takes black plutonium
--- cable. There is no MAX superconductor in GT (the last one is UMV): the MAX hatches take more of the
--- eternity superconductor (UXV) instead.
--------------------------------------------------------------------------------

F.metal("magmatter", "uxv", UXV_SPEED)
F.cable("magmatter")



--------------------------------------------------------------------------------
--- 2) THE PLANCK LINE (the MAX circuit)
--- The temporal line one step up, 10 % slower again: board (temporal board + magmatter foil), processing
--- unit (temporal unit + a gravi star, 4 per craft), processor (takes temporal processors), assembly,
--- supercomputer and the mainframe with the UXV superconductor (eternity).
--------------------------------------------------------------------------------

F.circuit_line{
	prefix = "planck", circuit = "max-circuit", prev = "temporal", metal = "magmatter",
	sc_wire = "eternity-superconductive-wire", unit_source = "temporal-processing-unit",
	board_source = "temporal-printed-circuit-board", assembler_tier = "uxv", speed = 1.2,
}



--------------------------------------------------------------------------------
--- 3) MAX COMPONENTS (zpm-assembly-line-recipes, like the UMV and UXV ones)
--- The UXV recipes with magmatter and magmatter cable; universium plates in the pump, MAX, UXV and UMV
--- circuits in the robot arm. The field generator takes 8 MAX circuits like the UXV one takes 8 UXV
--- circuits (GT's field generators take circuits one tier up; there is none above MAX). The UXV field
--- generator keeps its UXV circuits (GT: 4 MAX circuits), because the stargate needs it before the MAX tier.
--------------------------------------------------------------------------------

F.components{
	tier = "max", metal = "magmatter", cable = "magmatter-cable", circuit = "max-circuit",
	arm_circuits = { { "max-circuit", 2 }, { "uxv-circuit", 4 }, { "umv-circuit", 8 } },
	prev_plate = "universium-plate", field_circuit = { "max-circuit", 8 }, hull_fluid = 172.8,
}



--------------------------------------------------------------------------------
--- 4) MAX VOLTAGE COIL, ENERGY HATCH AND DYNAMO HATCH
--- Coil: a magnetic samarium rod with 16 fine magmatter wires (the UMV and UXV coils have their metal).
--- Energy hatch like the UXV one (134, 137: super coolant), twice the eternity superconductor and the
--- APICs (GT's UXV hatch takes twice the UMV hatch's superconductor). Dynamo hatch: the same recipe, as
--- 136-fork-power.lua does for LuV to UXV.
--------------------------------------------------------------------------------

create_item{
	name = "maximum-voltage-coil",
	category = "max-assembling-machine-recipes",
	energy_required = 10 * MAX_SPEED,
	ingredients = {
		item("magnetic-samarium-rod", 1),
		item("fine-magmatter-wire", 16),
	},
}
local function hatch(name)
	create_item{
		name = name,
		category = "zpm-assembly-line-recipes",
		energy_required = 40 * ZPM_SPEED,
		subgroup = "subgroup-zpm-assembly-line-recipes",
		ingredients = {
			item("max-machine-hull", 1),
			item("eternity-superconductive-wire", 8),
			item("atto-power-ic", 32),
			item("max-circuit", 2),
			item("maximum-voltage-coil", 2),
			item("max-pump", 1),
			fluid("super-coolant", 1000),
			fluid("molten-indalloy-140", 1152),
		},
	}
end
hatch("max-energy-hatch")
hatch("max-dynamo-hatch")
do
	local src = data.raw.item["uxv-dynamo-hatch"]
	local d = data.raw.item["max-dynamo-hatch"]
	d.order = (data.raw.item["max-energy-hatch"].order or "") .. "-dynamo"
	if src then d.subgroup = src.subgroup end
end



--------------------------------------------------------------------------------
--- 5) MAX SCIENCE PACK FROM MAX PARTS
--- Like the UMV and UXV packs: the tier's motor and circuits, its metal, the coils of the tier below, the
--- field generator of the tier below and a melt, in the assembler of the tier below; 100 packs instead of 10,
--- so a pack costs about as much as one from the stargate (tools/balance_model.py: 0.3 against 0.6 minutes
--- in the MAX and the UXV reference factory). The upstream recipe (1 stargate -> 1000 packs) stays: it is the
--- way into the MAX tier, and victory needs its packs.
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "max-science-pack-from-magmatter",
	category = "uxv-assembling-machine-recipes",
	energy_required = UXV_SPEED * 60,
	order = "o",
	subgroup = "subgroup-science-packs",
	ingredients = {
		item("max-motor", 1),
		item("max-circuit", 2),
		item("magmatter-plate", 4),
		item("eternal-coil-block", 4),
		item("uxv-field-generator", 1),
		fluid("molten-magmatter", 144),
	},
	results = { item("max-science-pack", 100) },
	main_product = "max-science-pack",
}



--------------------------------------------------------------------------------
--- 6) MAX MACHINES (copies of the UXV machines, recipe one tier up; 101-fork-machines.lua)
--------------------------------------------------------------------------------

MAX_BASIC_MACHINES = UXV_BASIC_MACHINES
MAX_UPGRADE_MACHINES = UXV_UPGRADE_MACHINES

local max_machine_recipes, max_multiblock_recipes = {}, {}
for _, base in pairs(MAX_BASIC_MACHINES) do
	fork_make_tier_machine(base, "uxv", "max", 6, nil)
	max_machine_recipes[#max_machine_recipes + 1] = "max-" .. base
end
for _, base in pairs(MAX_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "uxv", "max", nil, nil)
	max_multiblock_recipes[#max_multiblock_recipes + 1] = "max-" .. base
end



--------------------------------------------------------------------------------
--- 7) MAX LARGE PLASMA TURBINE (136-fork-power.lua, issue #34)
--- Four MAX amps (20 971.52 MW), an upgrade of the UXV turbine with the MAX dynamo hatch and a MAX hull
--- (the replaced dynamo hatch and hull come back). GT has no MAX generator (its dynamo hatches stop at UXV);
--- here the MAX machines draw twice the UXV ones, and the turbine continues the table of 136: 12.5 of
--- them on helium plasma take the plasma of 8 fusion reactors MK5. The scripts of 136 (fuel check, turbine
--- output hatch) take it from the mod data.
--------------------------------------------------------------------------------

do
	local name = "max-large-plasma-turbine"
	create_item{
		name = name,
		icon = "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png",
		category = "max-assembling-machine-recipes",
		energy_required = 60 * MAX_SPEED,
		subgroup = "subgroup-max-age-multiblocks",
		place_result = name,
		stack_size = 10,
		ingredients = {
			item("uxv-large-plasma-turbine", 1),
			item("max-dynamo-hatch", 1),
			item("max-machine-hull", 1),
		},
		results = {
			item(name, 1),
			item("uxv-dynamo-hatch", 1),
			item("uxv-machine-hull", 1),
		},
		main_product = name,
	}
	local g = table.deepcopy(data.raw.generator["uxv-large-plasma-turbine"])
	g.name = name
	g.icon = data.raw.item[name].icon
	g.minable = { mining_time = 1, result = name }
	g.max_power_output = "20971.52MW"
	g.fluid_usage_per_tick = g.fluid_usage_per_tick * 2
	g.localised_description = { "entity-description." .. name }
	for _, key in pairs({ "horizontal_animation", "vertical_animation" }) do
		g[key].layers[1].filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-working.png"
	end
	data:extend({ g })

	local power = data.raw["mod-data"]["fork-power"].data
	table.insert(power.turbines, name)
	power.fuels[name] = power.fuels["uxv-large-plasma-turbine"]
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES (MAX science; the unit counts are set in 138-fork-research-balance.lua)
--- Materials, circuits and components first (made with UXV machines), then the MAX machines, the hatches
--- (the coil needs the MAX assembler) and the multiblocks, like the UMV and UXV tiers.
--------------------------------------------------------------------------------

F.tech{
	name = "max-materials", prerequisites = { "godforge-exotic-module" }, packs = 15, count = 1,
	recipes = F.join({ "magmatter-cable" }, F.metal_parts("magmatter", F.ALL_PARTS)),
}
F.tech{
	name = "planck-processors", prerequisites = { "max-materials" }, packs = 15, count = 1,
	recipes = { "planck-printed-circuit-board", "planck-processing-unit", "planck-processor",
		"planck-processor-assembly", "planck-processor-supercomputer" },
}
F.tech{
	name = "planck-processor-mainframes", prerequisites = { "planck-processors" }, packs = 15, count = 1,
	recipes = { "planck-processor-mainframe" },
}
F.tech{
	name = "max-components", prerequisites = { "planck-processor-mainframes" }, packs = 15, count = 1,
	recipes = {
		"max-motor", "max-pump", "max-conveyor-module", "max-piston", "max-robot-arm", "max-emitter", "max-sensor",
		"max-field-generator", "max-machine-casing", "max-machine-hull", "max-science-pack-from-magmatter",
	},
}
F.tech{
	name = "max-machines", prerequisites = { "max-components" }, packs = 15, count = 1,
	recipes = max_machine_recipes,
}
F.tech{
	name = "max-energy-hatches", prerequisites = { "max-machines" }, packs = 15, count = 1,
	recipes = { "maximum-voltage-coil", "max-energy-hatch" },
}
F.tech{
	name = "max-multiblocks", prerequisites = { "max-energy-hatches" }, packs = 15, count = 1,
	recipes = max_multiblock_recipes,
}
F.tech{
	name = "max-plasma-turbine", prerequisites = { "max-energy-hatches", "uxv-plasma-turbine" }, packs = 15, count = 1,
	recipes = { "max-dynamo-hatch", "max-large-plasma-turbine" },
}
