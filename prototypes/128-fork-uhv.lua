--------------------------------------------------------------------------------
--- FORK UHV (roadmap phase 4)
--- Makes the UHV tier playable on top of the finished UV tier (127-fork-uv.lua):
---   * tritanium (the UHV metal, from the fusion reactor MK2) and the triamerotronium
---     superconductor
---   * the wetware line: stem cells, wetware circuit board, neuro processing unit, wetware
---     processor, assembly, supercomputer and the mainframe (= the UHV circuit)
---   * UHV components from the ZPM assembly line, UHV casing and hull
---   * fusion reactor MK3 with advanced fusion coils, iron plasma and the fast neutronium recipe
---   * UHV science pack (electromagnetic-science-pack), UHV voltage coil, tritanium coil,
---     UHV energy hatch
---   * UHV machines: the UV machines one tier up (fork_make_tier_machine)
---   * the UHV technologies, and the Phase 3 workarounds that are no longer needed
--- 27-uhv-age-item.lua is not loaded by data.lua (it is not valid Lua and mostly holds later
--- tiers), so the UHV parts of it are rebuilt here after the GT5-Unofficial recipes.
--- Everything else in it (bedrockium, singularities, neutronium compressor, ore factory)
--- waits for later phases.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-UHV: missing recipe: " .. name)
	return false
end

local function set_ingredient(recipe_name, from, to)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UHV: missing recipe: " .. recipe_name) return end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.name == from then i.name = to end
		end
	end
end

--- Replace one ingredient (name and amount) of a recipe
local function replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UHV: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

--- Overwrite fields of a draft recipe (category, energy_required, ingredients, results)
local function redo(recipe_name, fields)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UHV: missing recipe: " .. recipe_name) return end
	for k, v in pairs(fields) do r[k] = v end
end

local function category(name)
	if not data.raw["recipe-category"][name] then recipe_category_and_subgroup(name) end
end

--- Recipes that an earlier tech unlocked although they belong somewhere else
local function move_unlock(from_tech, recipe)
	local t = data.raw.technology[from_tech]
	if not t then return end
	local keep = {}
	for _, e in pairs(t.effects or {}) do
		if not (e.type == "unlock-recipe" and e.recipe == recipe) then keep[#keep + 1] = e end
	end
	t.effects = keep
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

--- Copy of an existing machine as a multiblock with its own name, categories and sprites
---   def = { name, source, size = {w, h}, categories, speed, energy, icon, subgroup }
local function clone_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-UHV: missing source machine " .. def.source) return end
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

local function join(a, b)
	for _, x in pairs(b) do a[#a + 1] = x end
	return a
end

--- (a fresh table per recipe: create_ingot puts it into the ingredient lists as it is)
local function argon() return { type = "fluid", name = "argon", amount = 5 } end



--------------------------------------------------------------------------------
--- 1) TRITANIUM, THE UHV METAL
--- GT: cosmic neutronium (motor, piston, ...) and bedrockium (cable). Neither can be made
--- here (no cosmic neutronium line, no bedrockium microminer), so the UHV parts are made of
--- tritanium: the fusion reactor MK2 already makes its melt, and GT uses it for the UHV coil
--- wire and the wetware mainframe frame too.
--- Every part comes out of the melt like the UV metals in 127-fork-uv.lua. The large gear is
--- 4 ingots (the generic 576 mB would be 40 ingots).
--------------------------------------------------------------------------------

create_endgame_parts{
	name = "tritanium",
	tier = "uv",
	speed = UV_SPEED,
	skip_block = true,
	skip_bolt = true,
	skip_large_gear = true,
	skip_dense_plate = true,
	skip_superdense_plate = true,
}
create_item{
	name = "large-tritanium-gear",
	category = "uv-fluid-solidifier-recipes",
	energy_required = UV_SPEED * 6.4,
	ingredients = {
		{ type = "fluid", name = "molten-tritanium", amount = 57.6 },
	},
}

--- The draft made 16 mB of tritanium per craft in 16 s (1 mB/s): a single UHV motor would have
--- taken 9 minutes of a MK2 reactor. Now 1 ingot of melt per 3 s, 3 titanium + 2 duranium (the ratio
--- of the draft; americium takes 5 s).
redo("molten-tritanium", {
	energy_required = 3 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-titanium", amount = 43.2 },
		{ type = "fluid", name = "molten-duranium", amount = 28.8 },
	},
	results = { { type = "fluid", name = "molten-tritanium", amount = 14.4 } },
})

--- UHV cable. GT's cable is 1 wire + rubber per cable; the UV cable recipe of phase 3 made 1 cable
--- from 4 wires, which was already too expensive for the UV motor, so this one follows GT again.
create_item{
	name = "tritanium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "tritanium-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "tritanium-cable", amount = 4 },
	},
}

--- UHV superconductor. GT (Superconductor Base UHV): draconium 6, cosmic neutronium 7, tritanium 5,
--- americium 6. Neither draconium nor cosmic neutronium exists here: equal parts of tritanium,
--- americium and neutronium instead. Cooled like the UV one (pump of the tier, melt, cryogenic helium).
create_ingot("triamerotronium", "uv", 10 * UV_SPEED, {
		{ type = "item", name = "tritanium-ingot", amount = 3 },
		{ type = "item", name = "americium-ingot", amount = 3 },
		{ type = "item", name = "neutronium-ingot", amount = 3 },
	},
	9, "uv", UV_SPEED * 99, argon(),
	"uv", UV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "triamerotronium", speed = 10, make_wire = true }
create_item{
	name = "triamerotronium-superconductive-wire",
	category = "uv-assembling-machine-recipes",
	energy_required = UV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "triamerotronium-wire", amount = 24 },
		{ type = "item", name = "uhv-pump", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1400 },
	},
	results = {
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 24 },
	},
}



--------------------------------------------------------------------------------
--- 2) THE WETWARE LINE (GT: LuV .. UHV, the mainframe is the UHV circuit)
--- Bacterial vat and mutagen come from phase 1. GT breeds stem cells from an unknown crystal
--- (GalaxySpace, not here): the raw crystal chip parts of the crystal line stand in for it. Bio
--- cells (UV, cosmic neutronium dust) are left out. The chain has the shape of the crystal one
--- (circuit assembly line, 16 circuits per craft, 2 of the previous stage per circuit):
---   stem cells -> wetware circuit board + neuro processing unit
---   -> wetware processor (uses the crystal CPU) -> assembly -> supercomputer -> mainframe
--- Changes against GT: no ytterbium wire (niobium-titanium instead), the mainframe uses the UV
--- superconductor. The mainframe takes complex SMDs like GT (issue #35, 129-fork-water-purification.lua).
--------------------------------------------------------------------------------

create_item{
	name = "stem-cells",
	category = "iv-chemical-reactor-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "raw-crystal-chip-part", amount = 2 },
		{ type = "item", name = "osmiridium-dust", amount = 2 },
		{ type = "fluid", name = "growth-medium", amount = 1000 },
	},
	results = {
		{ type = "item", name = "stem-cells", amount = 64 },
		{ type = "fluid", name = "bacterial-sludge", amount = 1000 },
	},
	main_product = "stem-cells",
}

create_item{
	name = "wetware-printed-circuit-board",
	category = "luv-assembling-machine-recipes",
	energy_required = 5 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "stem-cells", amount = 2 },
		{ type = "fluid", name = "growth-medium", amount = 50 },
	},
}
create_item{
	name = "neuro-processing-unit",
	category = "luv-assembling-machine-recipes",
	energy_required = 5 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "nano-cpu-chip", amount = 1 },
		{ type = "item", name = "stem-cells", amount = 4 },
		{ type = "fluid", name = "growth-medium", amount = 100 },
	},
}

category("luv-circuit-assembly-line-recipes")

create_recipe{
	recipe_name = "wetware-processor",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 90,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "wetware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "neuro-processing-unit", amount = 16 },
		{ type = "item", name = "crystal-cpu", amount = 16 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 6 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 6 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
	},
	results = { { type = "item", name = "wetware-processor", amount = 16 } },
}
create_item{ skip_recipe = true,
	name = "wetware-processor",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "wetware-processor-assembly",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "wetware-processor-supercomputer",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "uhv-circuit",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_recipe{
	recipe_name = "wetware-processor-assembly",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 180,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "wetware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "wetware-processor", amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 24 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 8 },
		{ type = "item", name = "advanced-smd-inductor", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	},
	results = { { type = "item", name = "wetware-processor-assembly", amount = 16 } },
}
create_recipe{
	recipe_name = "wetware-processor-supercomputer",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 360,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "wetware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "wetware-processor-assembly", amount = 32 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "nor-memory-chip-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 24 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 8 },
		{ type = "item", name = "europium-plate", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	},
	results = { { type = "item", name = "wetware-processor-supercomputer", amount = 16 } },
}
create_recipe{
	recipe_name = "wetware-processor-mainframe",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 720,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "tritanium-frame", amount = 16 },
		{ type = "item", name = "wetware-processor-supercomputer", amount = 32 },
		{ type = "item", name = "complex-smd-inductor", amount = 32 },
		{ type = "item", name = "complex-smd-capacitor", amount = 64 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "europium-plate", amount = 8 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
		{ type = "fluid", name = "radon", amount = 250 },
	},
	results = { { type = "item", name = "uhv-circuit", amount = 16 } },
}



--------------------------------------------------------------------------------
--- 3) UHV COMPONENTS (zpm-assembly-line-recipes, like the UV ones)
--- GT5-Unofficial assembly line recipes; 1 GT ingot of fluid = 14.4, 2000 L lubricant = 200.
--- Changes against GT:
---   * cosmic neutronium -> tritanium, bedrockium cable -> tritanium cable (see above; since issue #36
---     137-fork-endgame-materials.lua puts the bedrockium cable and the fluxed electrum foils in)
---   * fine wire and foil counts cut to a tenth or a quarter (GT: 512 fine neutronium wires,
---     256 fluxed electrum foils): motor 48 fine wires, emitter and sensor 32 foils, field generator
---     64 fine wires. Fluxed electrum does not exist here.
---   * field generator: UHV circuits instead of UEV circuits (none before phase 5)
--- The line runs at twice the LuV speed, so a component takes a minute.
--------------------------------------------------------------------------------

local UHV_AL = "zpm-assembly-line-recipes"
local UHV_AL_TIME = 30 * ZPM_SPEED

local function uhv_component(name, ingredients)
	create_item{
		name = name,
		category = UHV_AL,
		energy_required = UHV_AL_TIME,
		ingredients = ingredients,
	}
end

--- Fluids of every UHV component: naquadria and indalloy 140 (times the amount), lubricant
local function uhv_fluids(lubricant)
	local out = {
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
	}
	if lubricant then out[#out + 1] = { type = "fluid", name = "lubricant", amount = 400 } end
	return out
end

uhv_component("uhv-motor", join({
	{ type = "item", name = "long-magnetic-samarium-rod", amount = 4 },
	{ type = "item", name = "long-tritanium-rod", amount = 8 },
	{ type = "item", name = "tritanium-ring", amount = 8 },
	{ type = "item", name = "tritanium-round", amount = 32 },
	{ type = "item", name = "fine-tritanium-wire", amount = 48 },
	{ type = "item", name = "tritanium-cable", amount = 8 },
}, uhv_fluids(true)))
uhv_component("uhv-pump", join({
	{ type = "item", name = "uhv-motor", amount = 1 },
	{ type = "item", name = "neutronium-plate", amount = 12 },
	{ type = "item", name = "tritanium-plate", amount = 4 },
	{ type = "item", name = "tritanium-screw", amount = 16 },
	{ type = "item", name = "silicone-rubber-ring", amount = 64 },
	{ type = "item", name = "tritanium-rotor", amount = 4 },
	{ type = "item", name = "tritanium-cable", amount = 8 },
}, uhv_fluids(true)))
uhv_component("uhv-conveyor-module", join({
	{ type = "item", name = "uhv-motor", amount = 2 },
	{ type = "item", name = "tritanium-plate", amount = 2 },
	{ type = "item", name = "tritanium-ring", amount = 8 },
	{ type = "item", name = "tritanium-round", amount = 64 },
	{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
	{ type = "item", name = "tritanium-cable", amount = 8 },
}, uhv_fluids(true)))
uhv_component("uhv-piston", join({
	{ type = "item", name = "uhv-motor", amount = 1 },
	{ type = "item", name = "tritanium-plate", amount = 6 },
	{ type = "item", name = "tritanium-ring", amount = 8 },
	{ type = "item", name = "tritanium-round", amount = 64 },
	{ type = "item", name = "tritanium-rod", amount = 8 },
	{ type = "item", name = "large-tritanium-gear", amount = 2 },
	{ type = "item", name = "tritanium-gear", amount = 4 },
	{ type = "item", name = "tritanium-cable", amount = 16 },
}, uhv_fluids(true)))
uhv_component("uhv-robot-arm", join({
	{ type = "item", name = "uhv-motor", amount = 2 },
	{ type = "item", name = "uhv-piston", amount = 1 },
	{ type = "item", name = "long-tritanium-rod", amount = 8 },
	{ type = "item", name = "large-tritanium-gear", amount = 2 },
	{ type = "item", name = "tritanium-gear", amount = 6 },
	{ type = "item", name = "uhv-circuit", amount = 2 },
	{ type = "item", name = "uv-circuit", amount = 4 },
	{ type = "item", name = "zpm-circuit", amount = 8 },
	{ type = "item", name = "tritanium-cable", amount = 24 },
}, uhv_fluids(true)))
uhv_component("uhv-emitter", join({
	{ type = "item", name = "tritanium-frame", amount = 1 },
	{ type = "item", name = "uhv-motor", amount = 1 },
	{ type = "item", name = "tritanium-rod", amount = 16 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uhv-circuit", amount = 4 },
	{ type = "item", name = "tritanium-foil", amount = 32 },
	{ type = "item", name = "tritanium-cable", amount = 28 },
}, uhv_fluids(true)))
uhv_component("uhv-sensor", join({
	{ type = "item", name = "tritanium-frame", amount = 1 },
	{ type = "item", name = "uhv-motor", amount = 1 },
	{ type = "item", name = "tritanium-plate", amount = 8 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uhv-circuit", amount = 4 },
	{ type = "item", name = "tritanium-foil", amount = 32 },
	{ type = "item", name = "tritanium-cable", amount = 28 },
}, uhv_fluids(true)))
uhv_component("uhv-field-generator", join({
	{ type = "item", name = "tritanium-frame", amount = 1 },
	{ type = "item", name = "uhv-emitter", amount = 4 },
	{ type = "item", name = "tritanium-plate", amount = 6 },
	{ type = "item", name = "gravi-star", amount = 4 },
	{ type = "item", name = "uhv-circuit", amount = 8 },
	{ type = "item", name = "fine-tritanium-wire", amount = 64 },
	{ type = "item", name = "tritanium-cable", amount = 32 },
}, uhv_fluids(false)))

--- Casing and hull like the drafts: neutronium plates, and the UV superconductor
create_item{
	name = "uhv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "neutronium-plate", amount = 8 },
	},
}
create_item{
	name = "uhv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uhv-machine-casing", amount = 1 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 28.8 },
	},
}



--------------------------------------------------------------------------------
--- 4) FUSION REACTOR MK3
--- Controller, reactor and casing are the drafts in 21-luv-age-item.lua. In GT the MK3 is the
--- UV tier (16 UV energy hatches). Drafts fixed here:
---   * the reactor needs its controller (the draft called it "computer")
---   * QPIC wafers need the water purification line -> UHPIC wafers like the MK1 and MK2
---   * superdense americium plate (skipped when americium was made): 64 plates in the UV compressor
---   * the advanced fusion coil (the draft is the MK4 one with UU matter and UEV circuits): UHV
---     emitter and sensor, tritanium and neutronium melt instead of cinobite, octiron, astral
---     titanium and UU matter. The reactor takes 8 of them (GT: 32): each needs a UHV emitter and sensor (about 110 tritanium
---     ingots), see the PR.
--- GT's neutronium (americium + naquadria) is a MK3 recipe; here MK3 is the efficient one and the
--- MK2 keeps a slow one (see below), otherwise the UV pump needs neutronium and the MK3 needs UV
--- pumps.
--------------------------------------------------------------------------------

category("mk3-fusion-reactor-recipes")

create_item{
	name = "superdense-americium-plate",
	category = "uv-compressor-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "americium-plate", amount = 64 },
	},
}

redo("advanced-fusion-coil", {
	category = "uhv-assembling-machine-recipes",
	energy_required = 60 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 16 },
		{ type = "item", name = "uv-circuit", amount = 8 },
		{ type = "item", name = "neutronium-plate", amount = 8 },
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "uhv-emitter", amount = 1 },
		{ type = "item", name = "uhv-sensor", amount = 1 },
		{ type = "fluid", name = "molten-tritanium", amount = 230.4 },
		{ type = "fluid", name = "molten-neutronium", amount = 230.4 },
	},
})

redo("fusion-reactor-mk3-controller", {
	category = "zpm-assembly-line-recipes",
	energy_required = 50 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "superdense-americium-plate", amount = 1 },
		{ type = "item", name = "uv-field-generator", amount = 2 },
		{ type = "item", name = "uhpic-wafer", amount = 48 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 64 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-tritanium", amount = 115.2 },
	},
})

do
	redo("fusion-reactor-mk3", {
		category = "uv-assembling-machine-recipes",
		energy_required = 300 * UV_SPEED,
		ingredients = {
			{ type = "item", name = "fusion-reactor-mk3-controller", amount = 1 },
			{ type = "item", name = "advanced-fusion-coil", amount = 8 },
			{ type = "item", name = "fusion-machine-casing-mk2", amount = 79 },
			{ type = "item", name = "uv-energy-hatch", amount = 16 },
			{ type = "item", name = "uv-machine-hull", amount = 32 },
		},
	})
	local r = data.raw.recipe["fusion-machine-casing-mk2"]
	if r then r.category = "uv-assembling-machine-recipes" end
end

--- Fusion reactor: 9x9, two fluid inputs (north) and one output (south) like the MK1 and MK2
clone_multiblock{
	name = "fusion-reactor-mk3", source = "fusion-reactor-mk1", size = { 9, 9 },
	categories = { "mk1-fusion-reactor-recipes", "mk2-fusion-reactor-recipes", "mk3-fusion-reactor-recipes",
		"luv-fusion-reactor-recipes", "zpm-fusion-reactor-recipes", "uv-fusion-reactor-recipes" },
	speed = UV_SPEED, energy = "163.84MW",
	icon = data.raw.item["fusion-reactor-mk3"].icon,
	subgroup = "subgroup-uv-age-multiblocks",
}

--- Neutronium: the MK3 recipe is the one of GT (americium + naquadria, 1:1) and 4 times as fast as
--- the MK2 one was. The MK2 keeps a slow, wasteful bootstrap recipe (2 melt for 1), so the UV
--- components (neutronium plates, rods, ...) that the MK3 itself is built from stay possible.
--- Saves that researched uv-materials get the bootstrap recipe from it, like they had the old one.
redo("molten-neutronium", {
	category = "mk3-fusion-reactor-recipes",
	energy_required = 6 * ZPM_SPEED,
})
create_recipe{
	name = "molten-neutronium-bootstrap",
	category = "mk2-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-americium", amount = 28.8 },
		{ type = "fluid", name = "molten-naquadria", amount = 28.8 },
	},
	results = { { type = "fluid", name = "molten-neutronium", amount = 14.4 } },
	main_product = "molten-neutronium",
}

--- Iron plasma (draft in 21-luv-age-item.lua; neither the fluid nor the category existed)
fork_fluid("iron-plasma", "spackled-orange-fluid", { 0.85, 0.50, 0.40 })
redo("iron-plasma", { category = "mk3-fusion-reactor-recipes" })



--------------------------------------------------------------------------------
--- 5) UHV VOLTAGE COIL, TRITANIUM COIL AND UHV ENERGY HATCH
--- GT: the UHV coil is a magnetic samarium rod with 16 fine tritanium wires (the draft).
--- The UHV blast furnace coil is fluxed electrum in GT; that does not exist here, so it is the
--- tritanium coil (like the trinium coil: wire, foil and a melt).
--- Energy hatch as in 127-fork-uv.lua: cryogenic helium instead of coolant cells, UHPICs instead
--- of the quantum power IC (water purification line), the UHV superconductor.
--------------------------------------------------------------------------------

create_item{
	name = "highly-ultimate-voltage-coil",
	category = "uhv-assembling-machine-recipes",
	energy_required = 10 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-tritanium-wire", amount = 16 },
	},
}
create_item{
	name = "tritanium-coil-block",
	category = "uv-assembling-machine-recipes",
	energy_required = 50 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "tritanium-wire", amount = 16 },
		{ type = "item", name = "tritanium-foil", amount = 8 },
		{ type = "fluid", name = "molten-tritanium", amount = 14.4 },
	},
}
create_item{
	name = "uhv-energy-hatch",
	category = UHV_AL,
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 4 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 4 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "uhv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
	},
}



--------------------------------------------------------------------------------
--- 6) UHV SCIENCE PACK (electromagnetic-science-pack), like the UV pack in 127-fork-uv.lua:
--- the tier's motor and circuits, its main metal, the coils of the tier below, the field
--- generator of the tier below and a melt -> 10 packs
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "uhv-science-pack",
	category = "uv-assembling-machine-recipes",
	energy_required = UV_SPEED * 60,
	order = "j",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "tritanium-plate", amount = 4 },
		{ type = "item", name = "trinium-coil-block", amount = 4 },
		{ type = "item", name = "uv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-tritanium", amount = 144 },
	},
	results = {
		{ type = "item", name = "electromagnetic-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 7) UHV MACHINES (copies of the UV machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the UHV energy hatch.
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["uhv-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "uhv-age-production-machine", group = "production", order = "i-z-uhv" } })
end

UHV_BASIC_MACHINES = UV_BASIC_MACHINES
UHV_UPGRADE_MACHINES = UV_UPGRADE_MACHINES

local uhv_machine_recipes, uhv_multiblock_recipes = {}, {}
for _, base in pairs(UHV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "uv", "uhv", 6, nil)
	uhv_machine_recipes[#uhv_machine_recipes + 1] = "uhv-" .. base
end
for _, base in pairs(UHV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "uv", "uhv", nil, nil)
	uhv_multiblock_recipes[#uhv_multiblock_recipes + 1] = "uhv-" .. base
end



--------------------------------------------------------------------------------
--- 8) PHASE 3 WORKAROUNDS THAT ARE NOT NEEDED ANY MORE
---   * UV field generator: 4 UHV circuits like GT (it used 8 UV circuits). The recipe stays
---     unlocked by uv-components, so saves that had it keep it (it is craftable once the UHV
---     circuit is).
--------------------------------------------------------------------------------

replace_ingredient("uv-field-generator", "uv-circuit", "uhv-circuit", 4)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- UV science: tritanium, the wetware line, the UHV circuit and the UHV components (they lead to
--- the UHV science pack).
--- UHV science: machines, energy hatch, multiblocks, fusion reactor MK3 with its recipes.
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack" }
	local amounts = { SP10, SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
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

local function tritanium_parts()
	return { "tritanium-ingot", "tritanium-plate", "tritanium-rod", "long-tritanium-rod", "tritanium-frame",
		"tritanium-gear", "large-tritanium-gear", "tritanium-ring", "tritanium-round", "tritanium-screw",
		"tritanium-rotor", "tritanium-wire", "fine-tritanium-wire", "tritanium-foil", "tritanium-cable" }
end

--- The neutronium the UV parts are made from: slow at first, fast in the MK3 (below)
move_unlock("uv-materials", "molten-neutronium")
fork_add_unlock("uv-materials", "molten-neutronium-bootstrap")

--- UV science
do
	tech{
		name = "uhv-materials", prerequisites = { "uv-multiblocks" }, packs = 9, count = 4000,
		recipes = tritanium_parts(),
	}
	tech{
		name = "wetware-processors", prerequisites = { "uv-multiblocks", "bacterial-vat", "crystal-processors" },
		packs = 9, count = 4000,
		recipes = { "stem-cells", "wetware-printed-circuit-board", "neuro-processing-unit", "wetware-processor",
			"wetware-processor-assembly", "wetware-processor-supercomputer" },
	}
	tech{
		name = "wetware-processor-mainframes", prerequisites = { "wetware-processors", "uhv-materials" },
		packs = 9, count = 4500,
		recipes = { "wetware-processor-mainframe" },
	}
	tech{
		name = "uhv-components", prerequisites = { "wetware-processor-mainframes" }, packs = 9, count = 5000,
		recipes = {
			"uhv-motor", "uhv-pump", "uhv-conveyor-module", "uhv-piston", "uhv-robot-arm", "uhv-emitter", "uhv-sensor",
			"uhv-field-generator", "uhv-machine-casing", "uhv-machine-hull", "superdense-americium-plate",
		},
	}
end

--- The UHV science tech (upstream, researched with UV science) unlocks the pack
fork_add_unlock("electromagnetic-science-pack", "uhv-science-pack")
table.insert(data.raw.technology["electromagnetic-science-pack"].prerequisites, "uhv-components")

--- UHV science. Machines first: the UHV voltage coil needs the UHV assembler.
tech{
	name = "uhv-machines", prerequisites = { "electromagnetic-science-pack" }, packs = 10, count = 2000,
	recipes = uhv_machine_recipes,
}
tech{
	name = "uhv-energy-hatches", prerequisites = { "uhv-machines" }, packs = 10, count = 2500,
	recipes = {
		"hot-triamerotronium-ingot", "triamerotronium-ingot", "triamerotronium-dust", "triamerotronium-wire",
		"triamerotronium-superconductive-wire", "superconducting-coil-block-uhv", "tritanium-coil-block",
		"highly-ultimate-voltage-coil", "uhv-energy-hatch",
	},
}
tech{
	name = "uhv-multiblocks", prerequisites = { "uhv-energy-hatches" }, packs = 10, count = 2500,
	recipes = uhv_multiblock_recipes,
}
tech{
	name = "fusion-reactor-mk3", prerequisites = { "uhv-machines" }, packs = 10, count = 3500,
	recipes = { "fusion-machine-casing-mk2", "advanced-fusion-coil", "fusion-reactor-mk3-controller", "fusion-reactor-mk3" },
}
tech{
	name = "fusion-plasmas-mk3", prerequisites = { "fusion-reactor-mk3" }, packs = 10, count = 3500,
	recipes = { "molten-neutronium", "iron-plasma" },
}

--- UEV science needs the finished UHV tier
do
	local t = data.raw.technology["cryogenic-science-pack"]
	for _, p in pairs({ "uhv-multiblocks", "fusion-plasmas-mk3" }) do
		table.insert(t.prerequisites, p)
	end
end
