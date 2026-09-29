--------------------------------------------------------------------------------
--- FORK ZPM (roadmap phase 2)
--- Makes the ZPM tier playable on top of the finished LuV tier (125-fork-luv-endgame.lua):
---   * ZPM materials: naquadah alloy parts, europium plate and fine wire, trinium foil,
---     osmiridium rod, naquadah wire and cable, osmium foil and the naquadah coil
---   * ZPM components (motor, pump, piston, conveyor, robot arm, emitter, sensor, field
---     generator), casing and hull, following the GT5-Unofficial assembly line recipes
---   * the ZPM science pack (metallurgic-science-pack)
---   * ZPM voltage coil and energy hatch
---   * ZPM machines: the LuV machines one tier up (fork_make_tier_machine)
---   * the ZPM technologies
--- The drafts in 23-zpm-age-item.lua are not loaded by data.lua (the file is not valid Lua
--- and mostly holds later tiers), so the ZPM parts of it are rebuilt here. Everything else
--- in it (crystal matrix, energy module, wetware, fusion MK2, neutronium, draconic fusion)
--- waits for later phases.
--------------------------------------------------------------------------------

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-ZPM: missing recipe: " .. name)
	return false
end



--------------------------------------------------------------------------------
--- 1) ZPM MATERIALS
--------------------------------------------------------------------------------

--- Naquadah alloy: the ZPM main material (GT: motor, piston, pump, conveyor, robot arm, frames)
create_metal_parts{
	material = "naquadah-alloy",
	speed = NAQUADAH_ALLOY_SPEED,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_large_gear = true,
	make_round = true,
	make_nugget = true,
	make_ring = true,
	make_bolt = true,
	make_screw = true,
	make_rotor = true,
	make_frame = true,
}

--- Europium plate (science pack) and fine wire (motor, field generator, ZPM voltage coil)
create_metal_parts{ material = "europium", speed = EUROPIUM_SPEED, make_plate = true, make_fine_wire = true }

--- Trinium foil (emitter, sensor) and osmiridium rod (emitter)
create_metal_parts{ material = "trinium", speed = TRINIUM_SPEED, make_foil = true }
create_metal_parts{ material = "osmiridium", speed = OSMIRIDIUM_SPEED, make_rod = true }

--- Naquadah cable: the ZPM cable in GT (hull, machines); the wire recipe exists upstream
create_item{
	name = "naquadah-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "naquadah-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
}

--- Naquadah coil (ZPM heating coil, after HSS-G). 110-fork-luv.lua removed the draft recipe
--- because osmium could not be made at LuV; the osmium ingot recipes exist upstream.
create_item{
	name = "naquadah-coil-block",
	category = "luv-assembling-machine-recipes",
	energy_required = 40 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-wire", amount = 16 },
		{ type = "item", name = "osmium-foil", amount = 8 },
		{ type = "fluid", name = "molten-hsss", amount = 14.4 },
	},
}



--------------------------------------------------------------------------------
--- 2) ZPM COMPONENTS
--- GT5-Unofficial assembly line recipes (30 s at LuV). Amounts as in the LuV components:
--- 1 GT ingot of fluid = 14.4, 250 L lubricant = 25, a 4x cable = 4 cables.
--- Changes against GT:
---   * pump: the enderium pipe becomes osmiridium plates (no enderium line in Gregtorio)
---   * field generator: UV circuits do not exist yet (phase 3) -> twice the ZPM circuits
--------------------------------------------------------------------------------

local ZPM_AL = "luv-assembly-line-recipes"
local ZPM_AL_TIME = 30 * LUV_SPEED

local function component(name, ingredients)
	create_item{
		name = name,
		category = ZPM_AL,
		energy_required = ZPM_AL_TIME,
		subgroup = "subgroup-luv-assembly-line-recipes",
		ingredients = ingredients,
	}
end

component("zpm-motor", {
	{ type = "item", name = "magnetic-samarium-rod", amount = 2 },
	{ type = "item", name = "long-naquadah-alloy-rod", amount = 4 },
	{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
	{ type = "item", name = "naquadah-alloy-round", amount = 16 },
	{ type = "item", name = "fine-europium-wire", amount = 192 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	{ type = "fluid", name = "lubricant", amount = 75 },
})
component("zpm-pump", {
	{ type = "item", name = "zpm-motor", amount = 1 },
	{ type = "item", name = "osmiridium-plate", amount = 4 },
	{ type = "item", name = "naquadah-alloy-plate", amount = 2 },
	{ type = "item", name = "naquadah-alloy-screw", amount = 8 },
	{ type = "item", name = "silicone-rubber-ring", amount = 8 },
	{ type = "item", name = "naquadah-alloy-rotor", amount = 2 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	{ type = "fluid", name = "lubricant", amount = 75 },
})
component("zpm-conveyor-module", {
	{ type = "item", name = "zpm-motor", amount = 2 },
	{ type = "item", name = "naquadah-alloy-plate", amount = 2 },
	{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
	{ type = "item", name = "naquadah-alloy-round", amount = 32 },
	{ type = "item", name = "silicone-rubber-sheet", amount = 20 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	{ type = "fluid", name = "lubricant", amount = 75 },
})
component("zpm-piston", {
	{ type = "item", name = "zpm-motor", amount = 1 },
	{ type = "item", name = "naquadah-alloy-plate", amount = 6 },
	{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
	{ type = "item", name = "naquadah-alloy-round", amount = 32 },
	{ type = "item", name = "naquadah-alloy-rod", amount = 4 },
	{ type = "item", name = "large-naquadah-alloy-gear", amount = 1 },
	{ type = "item", name = "naquadah-alloy-gear", amount = 2 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 16 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	{ type = "fluid", name = "lubricant", amount = 75 },
})
component("zpm-robot-arm", {
	{ type = "item", name = "long-naquadah-alloy-rod", amount = 4 },
	{ type = "item", name = "large-naquadah-alloy-gear", amount = 1 },
	{ type = "item", name = "naquadah-alloy-gear", amount = 3 },
	{ type = "item", name = "zpm-motor", amount = 2 },
	{ type = "item", name = "zpm-piston", amount = 1 },
	{ type = "item", name = "zpm-circuit", amount = 2 },
	{ type = "item", name = "luv-circuit", amount = 4 },
	{ type = "item", name = "iv-circuit", amount = 8 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 24 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
	{ type = "fluid", name = "lubricant", amount = 75 },
})
component("zpm-emitter", {
	{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
	{ type = "item", name = "zpm-motor", amount = 1 },
	{ type = "item", name = "osmiridium-rod", amount = 8 },
	{ type = "item", name = "quantum-star", amount = 2 },
	{ type = "item", name = "zpm-circuit", amount = 4 },
	{ type = "item", name = "trinium-foil", amount = 192 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 28 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
})
component("zpm-sensor", {
	{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
	{ type = "item", name = "zpm-motor", amount = 1 },
	{ type = "item", name = "osmiridium-plate", amount = 8 },
	{ type = "item", name = "quantum-star", amount = 2 },
	{ type = "item", name = "zpm-circuit", amount = 4 },
	{ type = "item", name = "trinium-foil", amount = 192 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 28 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
})
component("zpm-field-generator", {
	{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
	{ type = "item", name = "naquadah-alloy-plate", amount = 6 },
	{ type = "item", name = "quantum-star", amount = 2 },
	{ type = "item", name = "zpm-emitter", amount = 4 },
	{ type = "item", name = "zpm-circuit", amount = 8 },
	{ type = "item", name = "fine-europium-wire", amount = 256 },
	{ type = "item", name = "vanadium-gallium-cable", amount = 32 },
	{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
})

--- Casing and hull like GT: iridium plates, naquadah cable, polybenzimidazole
--- (the draft used osmium, which is the UV casing material in GT)
create_item{
	name = "zpm-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "iridium-plate", amount = 8 },
	},
}
create_item{
	name = "zpm-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "zpm-machine-casing", amount = 1 },
		{ type = "item", name = "iridium-plate", amount = 1 },
		{ type = "item", name = "naquadah-cable", amount = 2 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
	},
}



--------------------------------------------------------------------------------
--- 3) ZPM SCIENCE PACK (metallurgic-science-pack), like the LuV pack in 110-fork-luv.lua
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "zpm-science-pack",
	category = "luv-assembling-machine-recipes",
	energy_required = LUV_SPEED * 60,
	order = "h",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "zpm-motor", amount = 1 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "europium-plate", amount = 4 },
		{ type = "item", name = "dense-naquadah-alloy-plate", amount = 2 },
		{ type = "item", name = "hssg-coil-block", amount = 4 },
		{ type = "item", name = "luv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-naquadah-alloy", amount = 144 },
	},
	results = {
		{ type = "item", name = "metallurgic-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 4) ZPM VOLTAGE COIL AND ENERGY HATCH
--- GT: the ZPM coil is a magnetic samarium rod with 16 fine europium wires.
--- Energy hatch like the LuV one in 110-fork-luv.lua: no coolant cells (cryogenic helium
--- instead), UHPICs instead of the NPIC chip (not in Gregtorio), naquadah cable instead of the
--- ZPM superconductor wire (its draft material chain needs later tiers).
--------------------------------------------------------------------------------

create_item{
	name = "zero-point-module-voltage-coil",
	category = "zpm-assembling-machine-recipes",
	energy_required = 10 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-europium-wire", amount = 16 },
	},
}
create_item{
	name = "zpm-energy-hatch",
	category = ZPM_AL,
	energy_required = 30 * LUV_SPEED,
	subgroup = "subgroup-luv-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "zpm-machine-hull", amount = 1 },
		{ type = "item", name = "naquadah-cable", amount = 4 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "zero-point-module-voltage-coil", amount = 2 },
		{ type = "item", name = "zpm-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 400 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 144 },
	},
}



--------------------------------------------------------------------------------
--- 5) ZPM MACHINES (copies of the LuV machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the ZPM energy hatch.
--------------------------------------------------------------------------------

ZPM_BASIC_MACHINES = LUV_BASIC_MACHINES
ZPM_UPGRADE_MACHINES = LUV_UPGRADE_MACHINES

local zpm_machine_recipes, zpm_multiblock_recipes = {}, {}
for _, base in pairs(ZPM_BASIC_MACHINES) do
	fork_make_tier_machine(base, "luv", "zpm", 6, nil)
	zpm_machine_recipes[#zpm_machine_recipes + 1] = "zpm-" .. base
end
for _, base in pairs(ZPM_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "luv", "zpm", nil, nil)
	zpm_multiblock_recipes[#zpm_multiblock_recipes + 1] = "zpm-" .. base
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- LuV science: ZPM materials and components (they lead to the ZPM science pack).
--- ZPM science: machines, energy hatch, multiblocks.
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack" }
	local amounts = { SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
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

--- Intermediates that 199-fork-finalize.lua used to auto-unlock and would lose now:
---   * HSS-G coils: the ZPM multiblock upgrades give the replaced HSS-G coils back, which counts
---     as a producer, so the auto-unlock skips them
---   * the PBI chain: the ZPM hull uses PBI sheets, and the ZPM techs are visited before
---     advanced-smds (via agricultural-science-pack), so the chain would move to zpm-components
for _, r in pairs({ "hssg-wire", "tungsten-carbide-foil", "hssg-coil-block" }) do
	fork_add_unlock("luv-machines", r)
end
for _, r in pairs({ "wood-tar-distillation", "chlorobenzene", "nitrochlorobenzene", "dichlorobenzidine",
	"diaminobenzidine", "phthalic-acid", "diphenyl-isophthalate", "potassium-dichromate", "chromium-trioxide",
	"polybenzimidazole", "polybenzimidazole-sheet" }) do
	fork_add_unlock("advanced-smds", r)
end

--- LuV science
tech{
	name = "zpm-materials", prerequisites = { "naquadah-alloy", "fusion-plasmas-mk1" }, packs = 7, count = 3000,
	recipes = {
		"naquadah-alloy-rod", "long-naquadah-alloy-rod", "naquadah-alloy-nugget", "naquadah-alloy-round",
		"naquadah-alloy-ring", "naquadah-alloy-bolt", "naquadah-alloy-screw", "naquadah-alloy-gear",
		"large-naquadah-alloy-gear", "naquadah-alloy-rotor", "naquadah-alloy-frame",
		"europium-plate", "fine-europium-wire", "trinium-foil", "osmiridium-rod",
		"naquadah-wire", "naquadah-cable",
	},
}
tech{
	name = "zpm-components", prerequisites = { "zpm-materials", "crystal-processors", "luv-energy-hatches" },
	packs = 7, count = 4000,
	recipes = {
		"zpm-motor", "zpm-pump", "zpm-conveyor-module", "zpm-piston", "zpm-robot-arm", "zpm-emitter",
		"zpm-sensor", "zpm-field-generator", "zpm-machine-casing", "zpm-machine-hull",
	},
}

--- The ZPM science tech (upstream, researched with LuV science) unlocks the pack
fork_add_unlock("metallurgic-science-pack", "zpm-science-pack")
table.insert(data.raw.technology["metallurgic-science-pack"].prerequisites, "zpm-components")

--- ZPM science. Machines first: the ZPM voltage coil needs the ZPM assembler.
tech{
	name = "zpm-machines", prerequisites = { "metallurgic-science-pack" }, packs = 8, count = 1500,
	recipes = zpm_machine_recipes,
}
tech{
	name = "zpm-energy-hatches", prerequisites = { "zpm-machines" }, packs = 8, count = 2000,
	recipes = {
		"hot-osmium-ingot", "osmium-ingot", "osmium-foil", "naquadah-coil-block",
		"zero-point-module-voltage-coil", "zpm-energy-hatch",
	},
}
tech{
	name = "zpm-multiblocks", prerequisites = { "zpm-energy-hatches" }, packs = 8, count = 2000,
	recipes = zpm_multiblock_recipes,
}

--- UV science needs the finished ZPM tier
table.insert(data.raw.technology["agricultural-science-pack"].prerequisites, "zpm-multiblocks")
