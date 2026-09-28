--------------------------------------------------------------------------------
--- FORK UMV (roadmap phase 5b)
--- Makes the UMV tier playable on top of the finished UIV tier (132-fork-uiv.lua):
---   * fusion reactor MK5 (UIV hatches) with the advanced fusion coil II, the fusion machine casing
---     MK4, rhugnor and flerovium; the MK5 makes spacetime (the UMV metal) and universium (the UXV
---     metal)
---   * spacetime parts, spacetime cable and the hypocosmium superconductor
---   * the exotic line: exotic board, exotic processing unit, exotic processor, assembly,
---     supercomputer and the mainframe (= the UMV circuit)
---   * UMV components from the ZPM assembly line, UMV casing and hull
---   * UMV science pack, UMV voltage coil, spacetime coil, UMV energy hatch
---   * UMV machines: the UIV machines one tier up (fork_make_tier_machine)
---   * the UMV technologies, and the phase 5a workaround that is not needed any more (UIV field
---     generator)
--- 80-umv-age-item.lua is not loaded by data.lua (it is not valid Lua and holds the space-time
--- chain, the dimensionally transcendent plasma forge and coal recipes of GTNH), so the parts of
--- it that phase 5b needs are rebuilt here.
---
--- This file also defines the helpers shared with 134-fork-uxv.lua and 135-fork-endgame.lua
--- (global table FORK5B): a UXV part is a UMV part with the next metal.
--------------------------------------------------------------------------------

local FLUID_ICON_PATH = "__Gregtorio__/graphics/fluids/"
local SPRITE_PATH = "__Gregtorio__/graphics/entity/fork/"

FORK5B = {}
local F = FORK5B

function F.recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-5B: missing recipe: " .. name)
	return false
end

--- Replace one ingredient (name and amount) of a recipe
function F.replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-5B: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

--- Overwrite fields of a draft recipe (category, energy_required, ingredients, results)
function F.redo(recipe_name, fields)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-5B: missing recipe: " .. recipe_name) return end
	for k, v in pairs(fields) do r[k] = v end
end

function F.category(name)
	if not data.raw["recipe-category"][name] then recipe_category_and_subgroup(name) end
end

--- Fluid like the ones in 06-fluids-module.lua (whose helper is local), colors given directly
function F.fluid(name, icon, color)
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

function F.join(a, b)
	for _, x in pairs(b) do a[#a + 1] = x end
	return a
end

--- (a fresh table per recipe: create_ingot puts it into the ingredient lists as it is)
function F.argon() return { type = "fluid", name = "argon", amount = 5 } end

--- Copy of an existing machine as a multiblock with its own name, categories and sprites
---   def = { name, source, size = {w, h}, categories, speed, energy, icon, subgroup }
function F.clone_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-5B: missing source machine " .. def.source) return end
	local m = table.deepcopy(src)
	m.name = def.name
	m.icons = nil
	m.icon = def.icon
	m.icon_size = 32
	m.minable = { mining_time = 1, result = def.name }
	m.crafting_categories = def.categories
	m.crafting_speed = def.speed
	m.energy_usage = def.energy
	m.fast_replaceable_group = def.fast_replaceable_group or ("fr-" .. def.name)
	m.next_upgrade = nil
	local w, h = def.size[1], def.size[2]
	m.collision_box = { { -w / 2 + 0.2, -h / 2 + 0.2 }, { w / 2 - 0.2, h / 2 - 0.2 } }
	m.selection_box = { { -w / 2, -h / 2 }, { w / 2, h / 2 } }
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-idle.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-working.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ m })

	local item = data.raw.item[def.name]
	item.place_result = def.name
	item.subgroup = def.subgroup
	item.stack_size = 10
end

--- Technologies: the science packs of a tier are the first n of the list (SP amounts count
--- down from the tier's own pack: 1 unit takes SP01 of the last one)
function F.sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack",
		"cryogenic-science-pack", "promethium-science-pack", "umv-science-pack", "uxv-science-pack",
		"max-science-pack" }
	local amounts = { SP15, SP14, SP13, SP12, SP11, SP10, SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
	local out = {}
	for i = 1, n do
		out[#out + 1] = { packs[i], amounts[#amounts - n + i] }
	end
	return out
end

function F.tech(def)
	local effects = {}
	for _, r in pairs(def.recipes) do
		if F.recipe_exists(r) then
			effects[#effects + 1] = { type = "unlock-recipe", recipe = r }
			data.raw.recipe[r].enabled = false
		end
	end
	data:extend({ {
		type = "technology",
		name = def.name,
		icon = "__Gregtorio__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = def.prerequisites,
		unit = { count = def.count, ingredients = F.sci(def.packs), time = def.time or 60 },
	} })
end

--- "%-plate" with name "spacetime" -> "spacetime-plate"
function F.metal_parts(name, parts)
	local out = {}
	for _, p in pairs(parts) do out[#out + 1] = p:gsub("%%", name) end
	return out
end

--- Every part of a metal that the components use, except the wire (some metals only make fine wire)
F.ALL_PARTS = { "%-ingot", "%-plate", "%-rod", "long-%-rod", "%-frame", "%-gear", "large-%-gear",
	"%-ring", "%-round", "%-screw", "%-rotor", "%-wire", "fine-%-wire", "%-foil" }

--- Metal of a tier: melt in the fusion reactor, parts in the solidifiers of the tier below the
--- tier's own (the tier's machines need the metal). The large gear is 4 ingots like the other
--- endgame metals; blocks, bolts and dense plates are not needed.
function F.metal(name, tier, speed)
	create_endgame_parts{
		name = name,
		tier = tier,
		speed = speed,
		skip_block = true,
		skip_large_gear = true,
		skip_bolt = true,
		skip_dense_plate = true,
		skip_superdense_plate = true,
	}
	create_item{
		name = "large-" .. name .. "-gear",
		category = tier .. "-fluid-solidifier-recipes",
		energy_required = speed * 6.4,
		ingredients = {
			{ type = "fluid", name = "molten-" .. name, amount = 57.6 },
		},
	}
end

--- Cable like the draconium one: 1 wire = 1 cable, rubber and a sheet
function F.cable(metal)
	create_item{
		name = metal .. "-cable",
		category = "lv-assembling-machine-recipes",
		energy_required = 5,
		ingredients = {
			{ type = "item", name = metal .. "-wire", amount = 4 },
			{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
			{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
		},
		results = {
			{ type = "item", name = metal .. "-cable", amount = 4 },
		},
	}
end

--- A circuit line like the optical one of 132-fork-uiv.lua (circuit assembly line, 16 circuits per
--- craft, 2 of the previous stage per circuit):
---   p = { prefix = "exotic", circuit = "umv-circuit", prev = "optical", metal = "spacetime",
---         sc_wire = "chromnorox-superconductive-wire", unit_source = "optical-processing-unit",
---         board_source = "optical-printed-circuit-board", assembler_tier = "uiv", speed = 1.0 }
--- The processor takes the processors of the previous line, the board and the unit the ones of the
--- previous line too. The processing unit needs a gravi star and comes 4 per craft.
function F.circuit_line(p)
	local pre = p.prefix
	local board, unit = pre .. "-printed-circuit-board", pre .. "-processing-unit"
	local proc = pre .. "-processor"
	local prev = p.prev .. "-processor"
	local cat = p.assembler_tier .. "-assembling-machine-recipes"
	local unit_speed = p.assembler_tier == "uiv" and UIV_SPEED or UMV_SPEED

	create_item{
		name = board,
		category = cat,
		energy_required = 5 * unit_speed,
		ingredients = {
			{ type = "item", name = p.board_source, amount = 1 },
			{ type = "item", name = p.metal .. "-foil", amount = 2 },
			{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
		},
	}
	create_item{
		name = unit,
		category = cat,
		energy_required = 5 * unit_speed,
		ingredients = {
			{ type = "item", name = p.unit_source, amount = 1 },
			{ type = "item", name = "gravi-star", amount = 1 },
			{ type = "item", name = "fine-" .. p.metal .. "-wire", amount = 4 },
		},
		results = { { type = "item", name = unit, amount = 4 } },
	}

	F.category("luv-circuit-assembly-line-recipes")
	for _, n in pairs({ proc, proc .. "-assembly", proc .. "-supercomputer", p.circuit }) do
		create_item{ skip_recipe = true, name = n, subgroup = "subgroup-luv-circuit-assembly-line-recipes" }
	end
	local function line(name, time, ingredients, amount)
		create_recipe{
			recipe_name = name,
			category = "luv-circuit-assembly-line-recipes",
			energy_required = LUV_SPEED * time,
			subgroup = "subgroup-luv-circuit-assembly-line-recipes",
			ingredients = ingredients,
			results = { { type = "item", name = name == proc .. "-mainframe" and p.circuit or name, amount = 16 } },
		}
	end
	local base = p.speed
	line(proc, 120 * base, {
		{ type = "item", name = board, amount = 16 },
		{ type = "item", name = unit, amount = 16 },
		{ type = "item", name = prev, amount = 8 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 8 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
	})
	line(proc .. "-assembly", 240 * base, {
		{ type = "item", name = board, amount = 16 },
		{ type = "item", name = proc, amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 24 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "advanced-smd-resistor", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	})
	line(proc .. "-supercomputer", 480 * base, {
		{ type = "item", name = board, amount = 16 },
		{ type = "item", name = proc .. "-assembly", amount = 32 },
		{ type = "item", name = "advanced-smd-inductor", amount = 8 },
		{ type = "item", name = "nor-memory-chip-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 24 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 8 },
		{ type = "item", name = p.metal .. "-plate", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	})
	line(proc .. "-mainframe", 960 * base, {
		{ type = "item", name = p.metal .. "-frame", amount = 16 },
		{ type = "item", name = proc .. "-supercomputer", amount = 32 },
		{ type = "item", name = "advanced-smd-inductor-wrap", amount = 8 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = p.metal .. "-plate", amount = 8 },
		{ type = "item", name = p.sc_wire, amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
		{ type = "fluid", name = "radon", amount = 250 },
	})
end

--- The eight components of a tier from the ZPM assembly line (a minute each), casing and hull.
---   p = { tier = "umv", metal = "spacetime", cable = "spacetime-cable", circuit = "umv-circuit",
---         arm_circuits = { {name, amount}, ... }, prev_plate = "transcendent-metal-plate",
---         field_circuit = { name, amount }, hull_fluid = 115.2 }
function F.components(p)
	local t, m = p.tier, p.metal
	local AL, AL_TIME = "zpm-assembly-line-recipes", 30 * ZPM_SPEED

	local function component(name, ingredients)
		create_item{ name = t .. "-" .. name, category = AL, energy_required = AL_TIME, ingredients = ingredients }
	end
	--- Fluids of every component: the metal and indalloy 140, lubricant
	local function fluids(lubricant)
		local out = {
			{ type = "fluid", name = "molten-" .. m, amount = 259.2 },
			{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		}
		if lubricant then out[#out + 1] = { type = "fluid", name = "lubricant", amount = 400 } end
		return out
	end
	local function item(name, amount) return { type = "item", name = name, amount = amount } end
	local motor = t .. "-motor"

	component("motor", F.join({
		item("long-magnetic-samarium-rod", 4),
		item("long-" .. m .. "-rod", 8),
		item(m .. "-ring", 8),
		item(m .. "-round", 32),
		item("fine-" .. m .. "-wire", 64),
		item(p.cable, 8),
	}, fluids(true)))
	component("pump", F.join({
		item(motor, 1),
		item(p.prev_plate, 12),
		item(m .. "-plate", 4),
		item(m .. "-screw", 16),
		item("silicone-rubber-ring", 64),
		item(m .. "-rotor", 4),
		item(p.cable, 8),
	}, fluids(true)))
	component("conveyor-module", F.join({
		item(motor, 2),
		item(m .. "-plate", 2),
		item(m .. "-ring", 8),
		item(m .. "-round", 64),
		item("silicone-rubber-sheet", 80),
		item(p.cable, 8),
	}, fluids(true)))
	component("piston", F.join({
		item(motor, 1),
		item(m .. "-plate", 6),
		item(m .. "-ring", 8),
		item(m .. "-round", 64),
		item(m .. "-rod", 8),
		item("large-" .. m .. "-gear", 2),
		item(m .. "-gear", 4),
		item(p.cable, 16),
	}, fluids(true)))
	local arm = F.join({
		item(motor, 2),
		item(t .. "-piston", 1),
		item("long-" .. m .. "-rod", 8),
		item("large-" .. m .. "-gear", 2),
		item(m .. "-gear", 6),
	}, {})
	for _, c in pairs(p.arm_circuits) do arm[#arm + 1] = item(c[1], c[2]) end
	arm[#arm + 1] = item(p.cable, 24)
	component("robot-arm", F.join(arm, fluids(true)))
	component("emitter", F.join({
		item(m .. "-frame", 1),
		item(motor, 1),
		item(m .. "-rod", 16),
		item("gravi-star", 8),
		item(p.circuit, 4),
		item(m .. "-foil", 32),
		item(p.cable, 28),
	}, fluids(true)))
	component("sensor", F.join({
		item(m .. "-frame", 1),
		item(motor, 1),
		item(m .. "-plate", 8),
		item("gravi-star", 8),
		item(p.circuit, 4),
		item(m .. "-foil", 32),
		item(p.cable, 28),
	}, fluids(true)))
	component("field-generator", F.join({
		item(m .. "-frame", 1),
		item(t .. "-emitter", 4),
		item(m .. "-plate", 6),
		item("gravi-star", 4),
		item(p.field_circuit[1], p.field_circuit[2]),
		item("fine-" .. m .. "-wire", 64),
		item(p.cable, 32),
	}, fluids(false)))

	create_item{
		name = t .. "-machine-casing",
		category = "lv-assembling-machine-recipes",
		energy_required = 2.5,
		ingredients = {
			item(m .. "-plate", 8),
		},
	}
	create_item{
		name = t .. "-machine-hull",
		category = "lv-assembling-machine-recipes",
		energy_required = 2.5,
		ingredients = {
			item(t .. "-machine-casing", 1),
			item(p.cable, 8),
			{ type = "fluid", name = "polybenzimidazole", amount = p.hull_fluid },
		},
	}
end



--------------------------------------------------------------------------------
--- 1) FUSION REACTOR MK5
--- Controller, reactor and casing MK4 are the drafts in 21-luv-age-item.lua. The MK5 is the UIV tier
--- (16 UIV energy hatches, 32 UIV hulls; the draft asked for UEV hatches, which the MK4 uses now).
--- Drafts fixed here:
---   * molten rhugnor: infinity + molten transcendent metal (the draft: molten quantum, which no
---     line makes); molten flerovium: americium + calcium plasma (the draft: plutonium-241);
---     both are MK4 recipes, so nothing the MK5 makes is needed to build it
---   * energy module: the ZPM assembly line recipe of 23-zpm-age-item.lua (not loaded), with UHPIC
---     wafers instead of the ASOC wafers (not built)
---   * advanced fusion coil II: UEV emitter and sensor (a UIV field generator or emitter would need
---     UMV circuits, which need spacetime, which the MK5 makes), the compact fusion coil of the
---     draft is the advanced fusion coil, rhugnor plates
---   * casing MK4: naquadah alloy plates instead of blocks, rhugnor plates instead of chromatic
---     glass, one UIV motor (the draft: 2 UEV motors and a piston), rhugnor and flerovium melts
---   * controller: UEV field generators like the draft, UIV circuits, QPIC wafers (PICO wafers are not
---     built) and the chromnorox superconductor
---   * the reactor takes 16 coils II (the draft: 32) like the MK4 takes 16 coils
--- The MK5 makes spacetime and universium. Neither is needed to build it.
--------------------------------------------------------------------------------

F.category("mk5-fusion-reactor-recipes")

F.fluid("molten-rhugnor", "deep-pink-fluid", { 0.85, 0.25, 0.55 })
F.fluid("molten-flerovium", "spackled-mint-green-fluid", { 0.45, 0.90, 0.75 })
F.fluid("molten-spacetime", "spackled-purple-fluid", { 0.45, 0.25, 0.75 })
F.fluid("molten-universium", "nearly-white-fluid", { 0.92, 0.92, 0.98 })

--- MK4: rhugnor and flerovium
F.redo("molten-rhugnor", {
	ingredients = {
		{ type = "fluid", name = "molten-infinity", amount = 14.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14.4 },
	},
})
F.redo("molten-flerovium", {
	ingredients = {
		{ type = "fluid", name = "molten-americium", amount = 14.4 },
		{ type = "fluid", name = "calcium-plasma", amount = 14.4 },
	},
})

--- Only the plate is needed (coil II, casing MK4); flerovium is used as a melt
create_endgame_parts{
	name = "rhugnor",
	tier = "uev",
	speed = UEV_SPEED,
	skip_block = true,
	skip_long_rod = true,
	skip_rod = true,
	skip_frame = true,
	skip_wire = true,
	skip_fine_wire = true,
	skip_foil = true,
	skip_large_gear = true,
	skip_gear = true,
	skip_ring = true,
	skip_round = true,
	skip_bolt = true,
	skip_screw = true,
	skip_rotor = true,
	skip_dense_plate = true,
	skip_superdense_plate = true,
}

create_item{
	name = "energy-module",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 100,
	ingredients = {
		{ type = "item", name = "europium-plate", amount = 16 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 8 },
		{ type = "item", name = "zpm-field-generator", amount = 2 },
		{ type = "item", name = "uhpic-wafer", amount = 64 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "naquadah-cable", amount = 32 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "lapis-coolant", amount = 1600 },
	},
}

F.redo("advanced-fusion-coil-ii", {
	category = "uiv-assembling-machine-recipes",
	energy_required = 60 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "energy-module", amount = 1 },
		{ type = "item", name = "advanced-fusion-coil", amount = 1 },
		{ type = "item", name = "uev-emitter", amount = 1 },
		{ type = "item", name = "uev-sensor", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 8 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "rhugnor-plate", amount = 8 },
		{ type = "fluid", name = "molten-rhugnor", amount = 230.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 230.4 },
	},
})

F.redo("fusion-machine-casing-mk4", {
	category = "uiv-assembling-machine-recipes",
	energy_required = 15 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-machine-casing-mk3", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 16 },
		{ type = "item", name = "luv-circuit", amount = 8 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 8 },
		{ type = "item", name = "rhugnor-plate", amount = 8 },
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "fluid", name = "molten-rhugnor", amount = 115.2 },
		{ type = "fluid", name = "molten-flerovium", amount = 115.2 },
	},
})

F.redo("fusion-reactor-mk5-controller", {
	category = "zpm-assembly-line-recipes",
	energy_required = 120 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "advanced-fusion-coil-ii", amount = 1 },
		{ type = "item", name = "uiv-circuit", amount = 4 },
		{ type = "item", name = "superdense-neutronium-plate", amount = 2 },
		{ type = "item", name = "uev-field-generator", amount = 2 },
		{ type = "item", name = "qpic-wafer", amount = 64 },
		{ type = "item", name = "chromnorox-superconductive-wire", amount = 64 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 115.2 },
		{ type = "fluid", name = "molten-rhugnor", amount = 115.2 },
	},
})

F.redo("fusion-reactor-mk5", {
	category = "uiv-assembling-machine-recipes",
	energy_required = 300 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-reactor-mk5-controller", amount = 1 },
		{ type = "item", name = "advanced-fusion-coil-ii", amount = 16 },
		{ type = "item", name = "fusion-machine-casing-mk4", amount = 79 },
		{ type = "item", name = "uiv-energy-hatch", amount = 16 },
		{ type = "item", name = "uiv-machine-hull", amount = 32 },
	},
})

--- Fusion reactor: 9x9, two fluid inputs (north) and one output (south) like the MK1 to MK4
F.clone_multiblock{
	name = "fusion-reactor-mk5", source = "fusion-reactor-mk1", size = { 9, 9 },
	categories = { "mk1-fusion-reactor-recipes", "mk2-fusion-reactor-recipes", "mk3-fusion-reactor-recipes",
		"mk4-fusion-reactor-recipes", "mk5-fusion-reactor-recipes", "luv-fusion-reactor-recipes",
		"zpm-fusion-reactor-recipes", "uv-fusion-reactor-recipes", "uhv-fusion-reactor-recipes",
		"uev-fusion-reactor-recipes", "uiv-fusion-reactor-recipes" },
	speed = UIV_SPEED, energy = "655.36MW",
	icon = data.raw.item["fusion-reactor-mk5"].icon,
	subgroup = "subgroup-uiv-age-multiblocks",
}

--- Spacetime (UMV) and universium (UXV). GT makes them in the dimensionally transcendent plasma
--- forge from tesseracts; here they are MK5 products: transcendent metal and rhugnor make
--- spacetime, spacetime and flerovium make universium. 1.5 s per ingot in one MK5.
create_recipe{
	name = "molten-spacetime",
	category = "mk5-fusion-reactor-recipes",
	energy_required = 24 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14.4 },
		{ type = "fluid", name = "molten-rhugnor", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-spacetime", amount = 14.4 } },
}
create_recipe{
	name = "molten-universium",
	category = "mk5-fusion-reactor-recipes",
	energy_required = 24 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-spacetime", amount = 14.4 },
		{ type = "fluid", name = "molten-flerovium", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-universium", amount = 14.4 } },
}



--------------------------------------------------------------------------------
--- 2) SPACETIME, THE UMV METAL, ITS CABLE AND THE HYPOCOSMIUM SUPERCONDUCTOR
--- Parts as the transcendent metal ones (large gear = 4 ingots). GT's UMV cable is quantium, which
--- is not built: the cable is spacetime (wire + rubber + sheet, like the other cables).
--- The superconductor is the name of the draft (hypocosmium); the recipe is invented on the pattern
--- of chromnorox: equal parts spacetime, infinity and rhugnor. Cooled like the UIV one (UMV pump,
--- melt, cryogenic helium).
--------------------------------------------------------------------------------

F.metal("spacetime", "uiv", UIV_SPEED)
F.cable("spacetime")

create_ingot("hypocosmium", "uiv", 10 * UIV_SPEED, {
		{ type = "item", name = "spacetime-ingot", amount = 3 },
		{ type = "item", name = "infinity-ingot", amount = 3 },
		{ type = "item", name = "rhugnor-ingot", amount = 3 },
	},
	9, "uiv", UIV_SPEED * 99, F.argon(),
	"uiv", UIV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "hypocosmium", speed = 10, make_wire = true }
create_item{
	name = "hypocosmium-superconductive-wire",
	category = "uiv-assembling-machine-recipes",
	energy_required = UIV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "hypocosmium-wire", amount = 24 },
		{ type = "item", name = "umv-pump", amount = 1 },
		{ type = "fluid", name = "molten-spacetime", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1400 },
	},
	results = {
		{ type = "item", name = "hypocosmium-superconductive-wire", amount = 24 },
	},
}



--------------------------------------------------------------------------------
--- 3) THE EXOTIC LINE (GT: the exotic mainframe is the UMV circuit)
--- The optical line one step up: exotic board (optical board + spacetime foil), exotic processing
--- unit (optical unit + a gravi star, 4 per craft), exotic processor (takes optical processors),
--- assembly, supercomputer and the mainframe with the UIV superconductor.
--- Changes against GT: no exotic chips and optical SMDs (advanced SMDs again), wafers and
--- power ICs are not part of the line.
--------------------------------------------------------------------------------

F.circuit_line{
	prefix = "exotic", circuit = "umv-circuit", prev = "optical", metal = "spacetime",
	sc_wire = "chromnorox-superconductive-wire", unit_source = "optical-processing-unit",
	board_source = "optical-printed-circuit-board", assembler_tier = "uiv", speed = 1.0,
}



--------------------------------------------------------------------------------
--- 4) UMV COMPONENTS (zpm-assembly-line-recipes, like the UIV ones)
--- The UIV recipes with spacetime instead of transcendent metal and spacetime cable instead of nether
--- star cable (see F.components); transcendent metal plates in the pump, UMV, UIV and UEV circuits in
--- the robot arm.
---   * field generator: UMV circuits for now, 134-fork-uxv.lua switches it to UXV circuits like GT
--------------------------------------------------------------------------------

F.components{
	tier = "umv", metal = "spacetime", cable = "spacetime-cable", circuit = "umv-circuit",
	arm_circuits = { { "umv-circuit", 2 }, { "uiv-circuit", 4 }, { "uev-circuit", 8 } },
	prev_plate = "transcendent-metal-plate", field_circuit = { "umv-circuit", 8 }, hull_fluid = 115.2,
}



--------------------------------------------------------------------------------
--- 5) UMV VOLTAGE COIL, SPACETIME COIL AND UMV ENERGY HATCH
--- GT: the UMV coil is a magnetic samarium rod with 16 fine spacetime wires. The UMV blast furnace
--- coil is built like the infinity coil (spacetime wire and screws, transcendent metal foil, a UIV
--- circuit and a melt). Energy hatch as in 132-fork-uiv.lua: cryogenic helium, QPICs (twice as many as
--- in the UIV hatch: they stand in for the missing chip tier), no UU matter.
--------------------------------------------------------------------------------

create_item{
	name = "mega-ultimate-voltage-coil",
	category = "umv-assembling-machine-recipes",
	energy_required = 10 * UMV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-spacetime-wire", amount = 16 },
	},
}
create_item{
	name = "spacetime-coil-block",
	category = "uiv-assembling-machine-recipes",
	energy_required = 60 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "spacetime-wire", amount = 16 },
		{ type = "item", name = "spacetime-screw", amount = 8 },
		{ type = "item", name = "transcendent-metal-foil", amount = 8 },
		{ type = "item", name = "uiv-circuit", amount = 1 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 57.6 },
	},
}
create_item{
	name = "umv-energy-hatch",
	category = "zpm-assembly-line-recipes",
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "umv-machine-hull", amount = 1 },
		{ type = "item", name = "hypocosmium-superconductive-wire", amount = 4 },
		{ type = "item", name = "quantum-power-ic", amount = 16 },
		{ type = "item", name = "umv-circuit", amount = 2 },
		{ type = "item", name = "mega-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "umv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
	},
}



--------------------------------------------------------------------------------
--- 6) UMV SCIENCE PACK, like the UIV pack in 132-fork-uiv.lua: the tier's motor and circuits, its
--- main metal, the coils of the tier below, the field generator of the tier below and a melt ->
--- 10 packs. It is made in the UIV assembler (the UMV machines need the pack).
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "umv-science-pack",
	category = "uiv-assembling-machine-recipes",
	energy_required = UIV_SPEED * 60,
	order = "m",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 1 },
		{ type = "item", name = "umv-circuit", amount = 2 },
		{ type = "item", name = "spacetime-plate", amount = 4 },
		{ type = "item", name = "infinity-coil-block", amount = 4 },
		{ type = "item", name = "uiv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-spacetime", amount = 144 },
	},
	results = {
		{ type = "item", name = "umv-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 7) UMV MACHINES (copies of the UIV machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the UMV energy hatch.
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["umv-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "umv-age-production-machine", group = "production", order = "i-z-umv" } })
end
if not data.raw["item-subgroup"]["subgroup-umv-age-multiblocks"] then
	data:extend({ { type = "item-subgroup", name = "subgroup-umv-age-multiblocks", group = "production", order = "pa" } })
end

UMV_BASIC_MACHINES = UIV_BASIC_MACHINES
UMV_UPGRADE_MACHINES = UIV_UPGRADE_MACHINES

local umv_machine_recipes, umv_multiblock_recipes = {}, {}
for _, base in pairs(UMV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "uiv", "umv", 6, nil)
	umv_machine_recipes[#umv_machine_recipes + 1] = "umv-" .. base
end
for _, base in pairs(UMV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "uiv", "umv", nil, nil)
	umv_multiblock_recipes[#umv_multiblock_recipes + 1] = "umv-" .. base
end



--------------------------------------------------------------------------------
--- 8) PHASE 5a WORKAROUNDS THAT ARE NOT NEEDED ANY MORE
---   * UIV field generator: 4 UMV circuits like GT (it used 8 UIV circuits). The recipe stays
---     unlocked by uiv-components, so saves that had it keep it (it is craftable once the UMV
---     circuit is; only the UMV science pack needs it).
--------------------------------------------------------------------------------

F.replace_ingredient("uiv-field-generator", "uiv-circuit", "umv-circuit", 4)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- UIV science (lead to the UMV science pack): the MK5 with its materials, spacetime, the exotic
--- line, the UMV circuit and the UMV components.
--- UMV science: machines, energy hatch, multiblocks.
--------------------------------------------------------------------------------

--- UIV science
do
	F.tech{
		name = "fusion-coil-ii", prerequisites = { "uiv-energy-hatches", "fusion-plasmas-mk4" }, packs = 12, count = 3500,
		recipes = { "energy-module", "molten-rhugnor", "molten-flerovium", "rhugnor-ingot", "rhugnor-plate",
			"advanced-fusion-coil-ii" },
	}
	F.tech{
		name = "fusion-reactor-mk5", prerequisites = { "fusion-coil-ii", "uiv-multiblocks" }, packs = 12, count = 4500,
		recipes = { "fusion-machine-casing-mk4", "fusion-reactor-mk5-controller", "fusion-reactor-mk5" },
	}
	F.tech{
		name = "fusion-plasmas-mk5", prerequisites = { "fusion-reactor-mk5" }, packs = 12, count = 4500,
		recipes = { "molten-spacetime", "molten-universium" },
	}
	F.tech{
		name = "umv-materials", prerequisites = { "fusion-plasmas-mk5" }, packs = 12, count = 5000,
		recipes = F.join({ "spacetime-cable" }, F.metal_parts("spacetime", F.ALL_PARTS)),
	}
	F.tech{
		name = "exotic-processors", prerequisites = { "umv-materials", "optical-processor-mainframes" }, packs = 12, count = 5500,
		recipes = { "exotic-printed-circuit-board", "exotic-processing-unit", "exotic-processor",
			"exotic-processor-assembly", "exotic-processor-supercomputer" },
	}
	F.tech{
		name = "exotic-processor-mainframes", prerequisites = { "exotic-processors" }, packs = 12, count = 6000,
		recipes = { "exotic-processor-mainframe" },
	}
	F.tech{
		name = "umv-components", prerequisites = { "exotic-processor-mainframes" }, packs = 12, count = 6500,
		recipes = {
			"umv-motor", "umv-pump", "umv-conveyor-module", "umv-piston", "umv-robot-arm", "umv-emitter", "umv-sensor",
			"umv-field-generator", "umv-machine-casing", "umv-machine-hull",
		},
	}
end

--- The UMV science tech (upstream, researched with UIV science) unlocks the pack (the upstream
--- effect stays; the recipe is defined above)
table.insert(data.raw.technology["umv-science-pack"].prerequisites, "umv-components")

--- UMV science. Machines first: the UMV voltage coil needs the UMV assembler.
F.tech{
	name = "umv-machines", prerequisites = { "umv-science-pack" }, packs = 13, count = 4000,
	recipes = umv_machine_recipes,
}
F.tech{
	name = "umv-energy-hatches", prerequisites = { "umv-machines" }, packs = 13, count = 4500,
	recipes = {
		"hot-hypocosmium-ingot", "hypocosmium-ingot", "hypocosmium-dust", "hypocosmium-wire",
		"hypocosmium-superconductive-wire", "superconducting-coil-block-umv", "spacetime-coil-block",
		"mega-ultimate-voltage-coil", "umv-energy-hatch",
	},
}
F.tech{
	name = "umv-multiblocks", prerequisites = { "umv-energy-hatches" }, packs = 13, count = 4500,
	recipes = umv_multiblock_recipes,
}
