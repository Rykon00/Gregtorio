--------------------------------------------------------------------------------
--- FORK UIV (roadmap phase 5a)
--- Makes the UIV tier playable on top of the finished UEV tier (131-fork-uev.lua):
---   * transcendent metal (the UIV metal, from the fusion reactor MK4), nether star cable and the
---     chromnorox superconductor
---   * the optical line: optical board, optical processing unit, optical processor, assembly,
---     supercomputer and the mainframe (= the UIV circuit)
---   * UIV components from the ZPM assembly line, UIV casing and hull
---   * UIV science pack (promethium-science-pack), UIV voltage coil, infinity coil, UIV energy hatch
---   * UIV machines: the UEV machines one tier up (fork_make_tier_machine)
---   * the UIV technologies, and the phase 5a workaround that is not needed any more (UEV field
---     generator)
--- 31-uiv-age-item.lua is not loaded by data.lua (it is not valid Lua and mostly holds the raw
--- tesseract chain, the dimensionally transcendent plasma forge and the godforge), so the UIV parts
--- of it are rebuilt here after the GT5-Unofficial recipes.
--- Fusion reactor MK5 (advanced fusion coil II, energy module, rhugnor) is built in 133-fork-umv.lua.
--------------------------------------------------------------------------------

local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-UIV: missing recipe: " .. name)
	return false
end

--- Replace one ingredient (name and amount) of a recipe
local function replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UIV: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

local function category(name)
	if not data.raw["recipe-category"][name] then recipe_category_and_subgroup(name) end
end

--- Fluid like the ones in 06-fluids-module.lua (whose helper is local), colors given directly
local function fork_fluid(name, icon, color)
	if data.raw.fluid[name] then return end
	local c = { r = color[1], g = color[2], b = color[3] }
	data:extend({ {
		type = "fluid",
		name = name,
		default_temperature = 1000,
		max_temperature = 1000,
		heat_capacity = "0.1kJ",
		base_color = c,
		flow_color = c,
		icon = FLUID_ICON_PATH .. icon .. ".png",
		icon_size = 32,
		order = "a[fluid]-z[" .. name .. "]",
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		auto_barrel = false,
	} })
end

local function join(a, b)
	for _, x in pairs(b) do a[#a + 1] = x end
	return a
end

--- (a fresh table per recipe: create_ingot puts it into the ingredient lists as it is)
local function argon() return { type = "fluid", name = "argon", amount = 5 } end



--------------------------------------------------------------------------------
--- 1) TRANSCENDENT METAL, THE UIV METAL
--- GT makes it from raw tesseracts in the dimensionally transcendent plasma forge, a multiblock
--- with catalyst, residue and plasma loops that is not part of this phase. It is a MK4 product
--- here: infinity melt and krypton plasma (which the MK2 makes and nothing used). The MK4 does not
--- need it, so there is no bootstrap recipe. Parts like the UEV ones (large gear = 4 ingots).
--------------------------------------------------------------------------------

fork_fluid("molten-transcendent-metal", "spackled-medium-blue-fluid", { 0.35, 0.55, 0.95 })

create_recipe{
	name = "molten-transcendent-metal",
	category = "mk4-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-infinity", amount = 14.4 },
		{ type = "fluid", name = "krypton-plasma", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-transcendent-metal", amount = 14.4 } },
}

create_endgame_parts{
	name = "transcendent-metal",
	tier = "uev",
	speed = UEV_SPEED,
	skip_block = true,
	skip_wire = true,
	skip_large_gear = true,
	skip_bolt = true,
	skip_dense_plate = true,
	skip_superdense_plate = true,
}
create_item{
	name = "large-transcendent-metal-gear",
	category = "uev-fluid-solidifier-recipes",
	energy_required = UEV_SPEED * 6.4,
	ingredients = {
		{ type = "fluid", name = "molten-transcendent-metal", amount = 57.6 },
	},
}

--- UIV cable (GT: nether star cable). A nether star makes 4 rods, a rod 2 wires, 4 wires 4 cables
--- like the other cables: one UIV motor needs 1 nether star.
create_item{
	name = "nether-star-rod",
	category = "lv-lathe-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "nether-star", amount = 1 },
	},
	results = { { type = "item", name = "nether-star-rod", amount = 4 } },
}
create_item{
	name = "nether-star-wire",
	category = "lv-wiremill-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "nether-star-rod", amount = 1 },
	},
	results = { { type = "item", name = "nether-star-wire", amount = 2 } },
}
create_item{
	name = "nether-star-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "nether-star-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "nether-star-cable", amount = 4 },
	},
}

--- UIV superconductor. The draft in 31-uiv-age-item.lua names it chromnorox; GT has no such thing. Equal
--- parts of transcendent metal, infinity and draconium. Cooled like the UEV one (UIV pump, melt,
--- cryogenic helium).
create_ingot("chromnorox", "uev", 10 * UEV_SPEED, {
		{ type = "item", name = "transcendent-metal-ingot", amount = 3 },
		{ type = "item", name = "infinity-ingot", amount = 3 },
		{ type = "item", name = "draconium-ingot", amount = 3 },
	},
	9, "uev", UEV_SPEED * 99, argon(),
	"uev", UEV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "chromnorox", speed = 10, make_wire = true }
create_item{
	name = "chromnorox-superconductive-wire",
	category = "uev-assembling-machine-recipes",
	energy_required = UEV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "chromnorox-wire", amount = 24 },
		{ type = "item", name = "uiv-pump", amount = 1 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1400 },
	},
	results = {
		{ type = "item", name = "chromnorox-superconductive-wire", amount = 24 },
	},
}



--------------------------------------------------------------------------------
--- 2) THE OPTICAL LINE (GT: the optical mainframe is the UIV circuit)
--- Same shape as the wetware and bio lines (circuit assembly line, 16 circuits per craft, 2 of the
--- previous stage per circuit): optical fiber -> optical board + optical processing unit -> optical
--- processor (takes bio processors) -> assembly -> supercomputer -> mainframe.
--- Changes against GT: the optical fiber is a borosilicate glass part (GT: lumiium and chromatic glass),
--- no optical SMDs (the processor keeps advanced ones; assembly, supercomputer and mainframe take
--- complex SMDs like GT), the mainframe uses the UEV superconductor.
--------------------------------------------------------------------------------

create_item{
	name = "optical-fiber",
	category = "zpm-fluid-solidifier-recipes",
	energy_required = 5 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-borosilicate-glass", amount = 144 },
	},
	results = { { type = "item", name = "optical-fiber", amount = 16 } },
}
create_item{
	name = "optical-printed-circuit-board",
	category = "uev-assembling-machine-recipes",
	energy_required = 5 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "bioware-printed-circuit-board", amount = 1 },
		{ type = "item", name = "optical-fiber", amount = 8 },
		{ type = "item", name = "transcendent-metal-foil", amount = 2 },
	},
}
create_item{
	name = "optical-processing-unit",
	category = "uev-assembling-machine-recipes",
	energy_required = 5 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "bio-processing-unit", amount = 1 },
		{ type = "item", name = "optical-fiber", amount = 16 },
		{ type = "item", name = "fine-transcendent-metal-wire", amount = 4 },
	},
}

category("luv-circuit-assembly-line-recipes")

create_item{ skip_recipe = true,
	name = "optical-processor",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "optical-processor-assembly",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "optical-processor-supercomputer",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "uiv-circuit",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_recipe{
	recipe_name = "optical-processor",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 110,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "optical-printed-circuit-board", amount = 16 },
		{ type = "item", name = "optical-processing-unit", amount = 16 },
		{ type = "item", name = "bio-processor", amount = 8 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 8 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
	},
	results = { { type = "item", name = "optical-processor", amount = 16 } },
}
create_recipe{
	recipe_name = "optical-processor-assembly",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 220,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "optical-printed-circuit-board", amount = 16 },
		{ type = "item", name = "optical-processor", amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 24 },
		{ type = "item", name = "complex-smd-diode", amount = 2 },
		{ type = "item", name = "complex-smd-resistor", amount = 2 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	},
	results = { { type = "item", name = "optical-processor-assembly", amount = 16 } },
}
create_recipe{
	recipe_name = "optical-processor-supercomputer",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 440,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "optical-printed-circuit-board", amount = 16 },
		{ type = "item", name = "optical-processor-assembly", amount = 32 },
		{ type = "item", name = "complex-smd-inductor", amount = 2 },
		{ type = "item", name = "nor-memory-chip-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 24 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 8 },
		{ type = "item", name = "transcendent-metal-plate", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	},
	results = { { type = "item", name = "optical-processor-supercomputer", amount = 16 } },
}
create_recipe{
	recipe_name = "optical-processor-mainframe",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 880,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "transcendent-metal-frame", amount = 16 },
		{ type = "item", name = "optical-processor-supercomputer", amount = 32 },
		{ type = "item", name = "complex-smd-inductor", amount = 32 },
		{ type = "item", name = "complex-smd-capacitor", amount = 64 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "transcendent-metal-plate", amount = 8 },
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
		{ type = "fluid", name = "radon", amount = 250 },
	},
	results = { { type = "item", name = "uiv-circuit", amount = 16 } },
}



--------------------------------------------------------------------------------
--- 3) UIV COMPONENTS (zpm-assembly-line-recipes, like the UEV ones)
--- GT5-Unofficial assembly line recipes; 1 GT ingot of fluid = 14.4, 2000 L lubricant = 200.
--- Changes against GT:
---   * transcendent metal instead of the raw tesseract chain, magnetic samarium rods instead of
---     attuned tengam rods, fine cosmic neutronium wire instead of fine proto-halkonite steel wire,
---     infinity plates instead of nether star plates (the pump)
---   * fine wire and foil counts cut like the UEV ones: motor 64 fine wires, emitter and sensor 32
---     foils, field generator 64 fine wires
---   * field generator: UIV circuits instead of UMV circuits (none before phase 5b)
--- The line runs at twice the LuV speed, so a component takes a minute.
--------------------------------------------------------------------------------

local UIV_AL = "zpm-assembly-line-recipes"
local UIV_AL_TIME = 30 * ZPM_SPEED

local function uiv_component(name, ingredients)
	create_item{
		name = name,
		category = UIV_AL,
		energy_required = UIV_AL_TIME,
		ingredients = ingredients,
	}
end

--- Fluids of every UIV component: transcendent metal and indalloy 140, lubricant
local function uiv_fluids(lubricant)
	local out = {
		{ type = "fluid", name = "molten-transcendent-metal", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
	}
	if lubricant then out[#out + 1] = { type = "fluid", name = "lubricant", amount = 400 } end
	return out
end

uiv_component("uiv-motor", join({
	{ type = "item", name = "long-magnetic-samarium-rod", amount = 4 },
	{ type = "item", name = "long-transcendent-metal-rod", amount = 8 },
	{ type = "item", name = "transcendent-metal-ring", amount = 8 },
	{ type = "item", name = "transcendent-metal-round", amount = 32 },
	{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 64 },
	{ type = "item", name = "nether-star-cable", amount = 8 },
}, uiv_fluids(true)))
uiv_component("uiv-pump", join({
	{ type = "item", name = "uiv-motor", amount = 1 },
	{ type = "item", name = "infinity-plate", amount = 12 },
	{ type = "item", name = "transcendent-metal-plate", amount = 4 },
	{ type = "item", name = "transcendent-metal-screw", amount = 16 },
	{ type = "item", name = "silicone-rubber-ring", amount = 64 },
	{ type = "item", name = "transcendent-metal-rotor", amount = 4 },
	{ type = "item", name = "nether-star-cable", amount = 8 },
}, uiv_fluids(true)))
uiv_component("uiv-conveyor-module", join({
	{ type = "item", name = "uiv-motor", amount = 2 },
	{ type = "item", name = "transcendent-metal-plate", amount = 2 },
	{ type = "item", name = "transcendent-metal-ring", amount = 8 },
	{ type = "item", name = "transcendent-metal-round", amount = 64 },
	{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
	{ type = "item", name = "nether-star-cable", amount = 8 },
}, uiv_fluids(true)))
uiv_component("uiv-piston", join({
	{ type = "item", name = "uiv-motor", amount = 1 },
	{ type = "item", name = "transcendent-metal-plate", amount = 6 },
	{ type = "item", name = "transcendent-metal-ring", amount = 8 },
	{ type = "item", name = "transcendent-metal-round", amount = 64 },
	{ type = "item", name = "transcendent-metal-rod", amount = 8 },
	{ type = "item", name = "large-transcendent-metal-gear", amount = 2 },
	{ type = "item", name = "transcendent-metal-gear", amount = 4 },
	{ type = "item", name = "nether-star-cable", amount = 16 },
}, uiv_fluids(true)))
uiv_component("uiv-robot-arm", join({
	{ type = "item", name = "uiv-motor", amount = 2 },
	{ type = "item", name = "uiv-piston", amount = 1 },
	{ type = "item", name = "long-transcendent-metal-rod", amount = 8 },
	{ type = "item", name = "large-transcendent-metal-gear", amount = 2 },
	{ type = "item", name = "transcendent-metal-gear", amount = 6 },
	{ type = "item", name = "uiv-circuit", amount = 2 },
	{ type = "item", name = "uev-circuit", amount = 4 },
	{ type = "item", name = "uhv-circuit", amount = 8 },
	{ type = "item", name = "nether-star-cable", amount = 24 },
}, uiv_fluids(true)))
uiv_component("uiv-emitter", join({
	{ type = "item", name = "transcendent-metal-frame", amount = 1 },
	{ type = "item", name = "uiv-motor", amount = 1 },
	{ type = "item", name = "transcendent-metal-rod", amount = 16 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uiv-circuit", amount = 4 },
	{ type = "item", name = "transcendent-metal-foil", amount = 32 },
	{ type = "item", name = "nether-star-cable", amount = 28 },
}, uiv_fluids(true)))
uiv_component("uiv-sensor", join({
	{ type = "item", name = "transcendent-metal-frame", amount = 1 },
	{ type = "item", name = "uiv-motor", amount = 1 },
	{ type = "item", name = "transcendent-metal-plate", amount = 8 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uiv-circuit", amount = 4 },
	{ type = "item", name = "transcendent-metal-foil", amount = 32 },
	{ type = "item", name = "nether-star-cable", amount = 28 },
}, uiv_fluids(true)))
uiv_component("uiv-field-generator", join({
	{ type = "item", name = "transcendent-metal-frame", amount = 1 },
	{ type = "item", name = "uiv-emitter", amount = 4 },
	{ type = "item", name = "transcendent-metal-plate", amount = 6 },
	{ type = "item", name = "gravi-star", amount = 4 },
	{ type = "item", name = "uiv-circuit", amount = 8 },
	{ type = "item", name = "fine-transcendent-metal-wire", amount = 64 },
	{ type = "item", name = "nether-star-cable", amount = 32 },
}, uiv_fluids(false)))

--- Casing and hull: transcendent metal plates and nether star cable
create_item{
	name = "uiv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "transcendent-metal-plate", amount = 8 },
	},
}
create_item{
	name = "uiv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uiv-machine-casing", amount = 1 },
		{ type = "item", name = "nether-star-cable", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 86.4 },
	},
}



--------------------------------------------------------------------------------
--- 4) UIV VOLTAGE COIL, INFINITY COIL AND UIV ENERGY HATCH
--- GT: the UIV coil is a magnetic samarium rod with 16 fine transcendent metal wires. The UIV blast
--- furnace coil is the infinity coil of the draft in 29-uev-age-item.lua (infinity wire, screws,
--- cosmic neutronium foil, a UEV circuit; draconium melt instead of awakened draconium).
--- Energy hatch as in 131-fork-uev.lua: cryogenic helium instead of super coolant, APICs (GT), no UU
--- matter.
--------------------------------------------------------------------------------

create_item{
	name = "insanely-ultimate-voltage-coil",
	category = "uiv-assembling-machine-recipes",
	energy_required = 10 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-transcendent-metal-wire", amount = 16 },
	},
}
create_item{
	name = "infinity-coil-block",
	category = "uev-assembling-machine-recipes",
	energy_required = 60 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "infinity-wire", amount = 16 },
		{ type = "item", name = "infinity-screw", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-foil", amount = 8 },
		{ type = "item", name = "uev-circuit", amount = 1 },
		{ type = "fluid", name = "molten-draconium", amount = 57.6 },
	},
}
create_item{
	name = "uiv-energy-hatch",
	category = UIV_AL,
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "uiv-machine-hull", amount = 1 },
		{ type = "item", name = "chromnorox-superconductive-wire", amount = 4 },
		{ type = "item", name = "atto-power-ic", amount = 4 },
		{ type = "item", name = "uiv-circuit", amount = 2 },
		{ type = "item", name = "insanely-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "uiv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
	},
}



--------------------------------------------------------------------------------
--- 5) UIV SCIENCE PACK (promethium-science-pack), like the UEV pack in 131-fork-uev.lua:
--- the tier's motor and circuits, its main metal, the coils of the tier below, the field
--- generator of the tier below and a melt -> 10 packs
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "uiv-science-pack",
	category = "uev-assembling-machine-recipes",
	energy_required = UEV_SPEED * 60,
	order = "l",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "item", name = "uiv-circuit", amount = 2 },
		{ type = "item", name = "transcendent-metal-plate", amount = 4 },
		{ type = "item", name = "awakened-draconium-coil-block", amount = 4 },
		{ type = "item", name = "uev-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 144 },
	},
	results = {
		{ type = "item", name = "promethium-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 6) UIV MACHINES (copies of the UEV machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the UIV energy hatch.
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["uiv-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "uiv-age-production-machine", group = "production", order = "i-z-uiv" } })
end

UIV_BASIC_MACHINES = UEV_BASIC_MACHINES
UIV_UPGRADE_MACHINES = UEV_UPGRADE_MACHINES

local uiv_machine_recipes, uiv_multiblock_recipes = {}, {}
for _, base in pairs(UIV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "uev", "uiv", 6, nil)
	uiv_machine_recipes[#uiv_machine_recipes + 1] = "uiv-" .. base
end
for _, base in pairs(UIV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "uev", "uiv", nil, nil)
	uiv_multiblock_recipes[#uiv_multiblock_recipes + 1] = "uiv-" .. base
end



--------------------------------------------------------------------------------
--- 7) PHASE 5a WORKAROUNDS THAT ARE NOT NEEDED ANY MORE
---   * UEV field generator: 4 UIV circuits like GT (it used 8 UEV circuits). The recipe stays
---     unlocked by uev-components, so saves that had it keep it (it is craftable once the UIV
---     circuit is; nothing before the UIV science pack needs it).
--------------------------------------------------------------------------------

replace_ingredient("uev-field-generator", "uev-circuit", "uiv-circuit", 4)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- UEV science (lead to the UIV science pack): transcendent metal, the optical line, the UIV circuit
--- and the UIV components.
--- UIV science: machines, energy hatch, multiblocks.
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack",
		"cryogenic-science-pack", "promethium-science-pack" }
	local amounts = { SP12, SP11, SP10, SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
	local out = {}
	for i = 1, n do
		out[#out + 1] = { packs[i], amounts[#amounts - n + i] }
	end
	return out
end

local function tech(def)
	local effects = {}
	for _, r in pairs(def.recipes) do
		if recipe_exists(r) then
			effects[#effects + 1] = { type = "unlock-recipe", recipe = r }
			data.raw.recipe[r].enabled = false
		end
	end
	data:extend({ {
		type = "technology",
		name = def.name,
		icon = "__gregtorio-continued__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = def.prerequisites,
		unit = { count = def.count, ingredients = sci(def.packs), time = def.time or 60 },
	} })
end

local function metal_parts(name, parts)
	local out = {}
	for _, p in pairs(parts) do out[#out + 1] = p:gsub("%%", name) end
	return out
end

--- UEV science
do
	tech{
		name = "uiv-materials", prerequisites = { "uev-multiblocks", "fusion-plasmas-mk4" }, packs = 11, count = 3000,
		recipes = join({ "molten-transcendent-metal", "nether-star-rod", "nether-star-wire", "nether-star-cable" },
			metal_parts("transcendent-metal", { "%-ingot", "%-plate", "%-rod", "long-%-rod", "%-frame", "%-gear",
				"large-%-gear", "%-ring", "%-round", "%-screw", "%-rotor", "fine-%-wire", "%-foil" })),
	}
	tech{
		name = "optical-processors", prerequisites = { "uiv-materials", "bio-processor-mainframes" }, packs = 11, count = 3500,
		recipes = { "optical-fiber", "optical-printed-circuit-board", "optical-processing-unit", "optical-processor",
			"optical-processor-assembly", "optical-processor-supercomputer" },
	}
	tech{
		name = "optical-processor-mainframes", prerequisites = { "optical-processors" }, packs = 11, count = 4000,
		recipes = { "optical-processor-mainframe" },
	}
	tech{
		name = "uiv-components", prerequisites = { "optical-processor-mainframes" }, packs = 11, count = 4500,
		recipes = {
			"uiv-motor", "uiv-pump", "uiv-conveyor-module", "uiv-piston", "uiv-robot-arm", "uiv-emitter", "uiv-sensor",
			"uiv-field-generator", "uiv-machine-casing", "uiv-machine-hull",
		},
	}
end

--- The UIV science tech (upstream, researched with UEV science) unlocks the pack
fork_add_unlock("promethium-science-pack", "uiv-science-pack")
table.insert(data.raw.technology["promethium-science-pack"].prerequisites, "uiv-components")

--- UIV science. Machines first: the UIV voltage coil needs the UIV assembler.
tech{
	name = "uiv-machines", prerequisites = { "promethium-science-pack" }, packs = 12, count = 3000,
	recipes = uiv_machine_recipes,
}
tech{
	name = "uiv-energy-hatches", prerequisites = { "uiv-machines", "atto-power-ics" }, packs = 12, count = 3500,
	recipes = {
		"hot-chromnorox-ingot", "chromnorox-ingot", "chromnorox-dust", "chromnorox-wire",
		"chromnorox-superconductive-wire", "superconducting-coil-block-uiv", "infinity-coil-block",
		"insanely-ultimate-voltage-coil", "uiv-energy-hatch",
	},
}
tech{
	name = "uiv-multiblocks", prerequisites = { "uiv-energy-hatches" }, packs = 12, count = 3500,
	recipes = uiv_multiblock_recipes,
}



--------------------------------------------------------------------------------
--- 8) UMV AND UXV SCIENCE PACK PLACEHOLDERS
--- Upstream has recipes that make the UMV and UXV science packs from a stone (11-lv-age-item.lua and
--- the UXV assembler category). They were unreachable while the UIV pack had no recipe; with it the
--- whole endgame would be researchable for free, so they are removed. 133-fork-umv.lua and
--- 134-fork-uxv.lua (phase 5b) define the real recipes.
--------------------------------------------------------------------------------

data.raw.recipe["umv-science-pack"] = nil
data.raw.recipe["uxv-science-pack"] = nil
