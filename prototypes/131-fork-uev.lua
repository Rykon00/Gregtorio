--------------------------------------------------------------------------------
--- FORK UEV (roadmap phase 5a)
--- Makes the UEV tier playable on top of the finished UHV tier (128-fork-uhv.lua):
---   * cosmic neutronium, draconium and infinity (the UEV metals) from the fusion reactors, and
---     the dracofinium superconductor
---   * the bio line: bio cells, bioware circuit board, bio processing unit, bio processor,
---     assembly, supercomputer and the mainframe (= the UEV circuit)
---   * UEV components from the ZPM assembly line, UEV casing and hull
---   * fusion reactor MK4 (UEV hatches) with its casing MK3, the fast melts and the MK4 techs
---   * UEV science pack (cryogenic-science-pack), UEV voltage coil, awakened draconium coil,
---     UEV energy hatch
---   * UEV machines: the UHV machines one tier up (fork_make_tier_machine)
---   * the UEV technologies, and the phase 4 workaround that is not needed any more (UHV field
---     generator)
--- 29-uev-age-item.lua is not loaded by data.lua (it is not valid Lua and mostly holds the
--- quantum force transformer and the dimensional plasma forge), so the UEV parts of it are
--- rebuilt here after the GT5-Unofficial recipes.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-UEV: missing recipe: " .. name)
	return false
end

local function set_ingredient(recipe_name, from, to)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UEV: missing recipe: " .. recipe_name) return end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.name == from then i.name = to end
		end
	end
end

--- Replace one ingredient (name and amount) of a recipe
local function replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UEV: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

--- Overwrite fields of a draft recipe (category, energy_required, ingredients, results)
local function redo(recipe_name, fields)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UEV: missing recipe: " .. recipe_name) return end
	for k, v in pairs(fields) do r[k] = v end
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

--- Copy of an existing machine as a multiblock with its own name, categories and sprites
---   def = { name, source, size = {w, h}, categories, speed, energy, icon, subgroup }
local function clone_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-UEV: missing source machine " .. def.source) return end
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
--- 1) THE UEV METALS: COSMIC NEUTRONIUM, DRACONIUM AND INFINITY
--- GT gets them from ores (space mining, Draconic Evolution, the infinity catalyst chain), none of
--- which exists here. They are made in the fusion reactors like tritanium and neutronium:
---   draconium              americium + iron plasma (MK3: uses the iron plasma of phase 4)
---   cosmic neutronium      neutronium + tritanium
---   infinity               cosmic neutronium + draconium
--- The UEV energy hatches (and with them the MK4) need all three, so the MK3 makes them with slow,
--- wasteful bootstrap recipes (2 melt for 1, four times slower than the MK4) and the MK4 makes
--- cosmic neutronium and infinity efficiently. Draconium needs nothing but the iron plasma.
--- GT's UEV parts are infinity with draconium cable and cosmic neutronium fine wire (this is
--- what the drafts and the GT assembly line recipes use); the UHV parts stay tritanium.
--------------------------------------------------------------------------------

category("mk4-fusion-reactor-recipes")

for _, f in pairs({
	{ "molten-cosmic-neutronium", "dark-gray-spackled-fluid", { 0.30, 0.22, 0.42 } },
	{ "molten-draconium", "medium-red-fluid", { 0.80, 0.25, 0.25 } },
	{ "molten-infinity", "light-orange-fluid", { 0.95, 0.82, 0.48 } },
}) do
	fork_fluid(f[1], f[2], f[3])
end

--- MK3: draconium and the bootstrap recipes
create_recipe{
	name = "molten-draconium",
	category = "mk3-fusion-reactor-recipes",
	energy_required = 6 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-americium", amount = 14.4 },
		{ type = "fluid", name = "iron-plasma", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-draconium", amount = 14.4 } },
}
create_recipe{
	name = "molten-cosmic-neutronium-bootstrap",
	category = "mk3-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-neutronium", amount = 28.8 },
		{ type = "fluid", name = "molten-tritanium", amount = 28.8 },
	},
	results = { { type = "fluid", name = "molten-cosmic-neutronium", amount = 14.4 } },
	main_product = "molten-cosmic-neutronium",
}
create_recipe{
	name = "molten-infinity-bootstrap",
	category = "mk3-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 28.8 },
		{ type = "fluid", name = "molten-draconium", amount = 28.8 },
	},
	results = { { type = "fluid", name = "molten-infinity", amount = 14.4 } },
	main_product = "molten-infinity",
}
--- MK4: the efficient ones
create_recipe{
	name = "molten-cosmic-neutronium",
	category = "mk4-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-neutronium", amount = 14.4 },
		{ type = "fluid", name = "molten-tritanium", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-cosmic-neutronium", amount = 14.4 } },
}
create_recipe{
	name = "molten-infinity",
	category = "mk4-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 14.4 },
		{ type = "fluid", name = "molten-draconium", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-infinity", amount = 14.4 } },
}

--- Parts. Cosmic neutronium: plate, fine wire and foil. Draconium: wire (and the cable below).
--- Infinity: everything the UEV components and the coil use; the large gear is 4 ingots like
--- the tritanium one.
create_endgame_parts{
	name = "cosmic-neutronium",
	tier = "uhv",
	speed = UHV_SPEED,
	skip_block = true,
	skip_long_rod = true,
	skip_rod = true,
	skip_frame = true,
	skip_wire = true,
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
create_endgame_parts{
	name = "draconium",
	tier = "uhv",
	speed = UHV_SPEED,
	skip_block = true,
	skip_plate = true,
	skip_long_rod = true,
	skip_rod = true,
	skip_frame = true,
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
create_endgame_parts{
	name = "infinity",
	tier = "uhv",
	speed = UHV_SPEED,
	skip_block = true,
	skip_fine_wire = true,
	skip_large_gear = true,
	skip_bolt = true,
	skip_dense_plate = true,
	skip_superdense_plate = true,
}
create_item{
	name = "large-infinity-gear",
	category = "uhv-fluid-solidifier-recipes",
	energy_required = UHV_SPEED * 6.4,
	ingredients = {
		{ type = "fluid", name = "molten-infinity", amount = 57.6 },
	},
}

--- UEV cable (GT: draconium cable, 1 wire + rubber per cable like the tritanium one)
create_item{
	name = "draconium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "draconium-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "draconium-cable", amount = 4 },
	},
}

--- UEV superconductor. GT does not have dracofinium; the draft in 29-uev-age-item.lua names it. Equal
--- parts of draconium, infinity and cosmic neutronium (the UHV one is tritanium, americium and
--- neutronium). Cooled like the UHV one: UEV pump, melt, cryogenic helium.
create_ingot("dracofinium", "uhv", 10 * UHV_SPEED, {
		{ type = "item", name = "draconium-ingot", amount = 3 },
		{ type = "item", name = "infinity-ingot", amount = 3 },
		{ type = "item", name = "cosmic-neutronium-ingot", amount = 3 },
	},
	9, "uhv", UHV_SPEED * 99, argon(),
	"uhv", UHV_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "dracofinium", speed = 10, make_wire = true }
create_item{
	name = "dracofinium-superconductive-wire",
	category = "uhv-assembling-machine-recipes",
	energy_required = UHV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "dracofinium-wire", amount = 24 },
		{ type = "item", name = "uev-pump", amount = 1 },
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1400 },
	},
	results = {
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 24 },
	},
}



--------------------------------------------------------------------------------
--- 2) THE BIO LINE (GT: ZPM .. UEV, the mainframe is the UEV circuit)
--- Same shape as the wetware line of 128-fork-uhv.lua (circuit assembly line, 16 circuits per craft,
--- 2 of the previous stage per circuit): stem cells -> bio cells -> bioware board + bio processing
--- unit -> bio processor (takes wetware processors) -> assembly -> supercomputer -> mainframe.
--- Changes against GT: bio cells are made from stem cells, mutagen and growth medium (GT: cosmic
--- neutronium dust), no PCB factory (the boards come from the wetware board), the mainframe uses the
--- UHV superconductor. Supercomputer and mainframe take complex SMDs like GT (129-fork-water-purification.lua).
--------------------------------------------------------------------------------

create_item{
	name = "bio-cells",
	category = "iv-chemical-reactor-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "stem-cells", amount = 8 },
		{ type = "fluid", name = "mutagen", amount = 250 },
		{ type = "fluid", name = "growth-medium", amount = 500 },
	},
	results = {
		{ type = "item", name = "bio-cells", amount = 16 },
		{ type = "fluid", name = "bacterial-sludge", amount = 500 },
	},
	main_product = "bio-cells",
}
create_item{
	name = "bioware-printed-circuit-board",
	category = "uv-assembling-machine-recipes",
	energy_required = 5 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "wetware-printed-circuit-board", amount = 1 },
		{ type = "item", name = "bio-cells", amount = 2 },
		{ type = "fluid", name = "growth-medium", amount = 50 },
	},
}
create_item{
	name = "bio-processing-unit",
	category = "uv-assembling-machine-recipes",
	energy_required = 5 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "qubit-cpu-chip", amount = 1 },
		{ type = "item", name = "bio-cells", amount = 4 },
		{ type = "fluid", name = "growth-medium", amount = 100 },
	},
}

category("luv-circuit-assembly-line-recipes")

create_item{ skip_recipe = true,
	name = "bio-processor",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "bio-processor-assembly",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "bio-processor-supercomputer",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_item{ skip_recipe = true,
	name = "uev-circuit",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}
create_recipe{
	recipe_name = "bio-processor",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 100,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "bioware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "bio-processing-unit", amount = 16 },
		{ type = "item", name = "wetware-processor", amount = 8 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 8 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
	},
	results = { { type = "item", name = "bio-processor", amount = 16 } },
}
create_recipe{
	recipe_name = "bio-processor-assembly",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 200,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "bioware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "bio-processor", amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 24 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "advanced-smd-resistor", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	},
	results = { { type = "item", name = "bio-processor-assembly", amount = 16 } },
}
create_recipe{
	recipe_name = "bio-processor-supercomputer",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 400,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "bioware-printed-circuit-board", amount = 16 },
		{ type = "item", name = "bio-processor-assembly", amount = 32 },
		{ type = "item", name = "complex-smd-inductor", amount = 2 },
		{ type = "item", name = "nor-memory-chip-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 24 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	},
	results = { { type = "item", name = "bio-processor-supercomputer", amount = 16 } },
}
create_recipe{
	recipe_name = "bio-processor-mainframe",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 800,
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "infinity-frame", amount = 16 },
		{ type = "item", name = "bio-processor-supercomputer", amount = 32 },
		{ type = "item", name = "complex-smd-inductor", amount = 32 },
		{ type = "item", name = "complex-smd-capacitor", amount = 64 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 8 },
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
		{ type = "fluid", name = "radon", amount = 250 },
	},
	results = { { type = "item", name = "uev-circuit", amount = 16 } },
}



--------------------------------------------------------------------------------
--- 3) UEV COMPONENTS (zpm-assembly-line-recipes, like the UHV ones)
--- GT5-Unofficial assembly line recipes; 1 GT ingot of fluid = 14.4, 2000 L lubricant = 200.
--- Changes against GT:
---   * attuned tengam rods -> magnetic samarium rods (no tengam), bedrockium / nether star plates
---     -> cosmic neutronium plates, quantium -> cosmic neutronium melt, infinity catalyst foil ->
---     infinity foil (137-fork-endgame-materials.lua puts quantium melt in, issue #36)
---   * fine wire and foil counts cut (GT: 512 fine cosmic neutronium wires, 256 foils): motor 64
---     fine wires, emitter and sensor 32 foils, field generator 64 fine wires
---   * field generator: UEV circuits instead of UIV circuits (none before the UIV part of this
---     phase; 132-fork-uiv.lua switches it to UIV circuits like GT)
--- The line runs at twice the LuV speed, so a component takes a minute.
--------------------------------------------------------------------------------

local UEV_AL = "zpm-assembly-line-recipes"
local UEV_AL_TIME = 30 * ZPM_SPEED

local function uev_component(name, ingredients)
	create_item{
		name = name,
		category = UEV_AL,
		energy_required = UEV_AL_TIME,
		ingredients = ingredients,
	}
end

--- Fluids of every UEV component: cosmic neutronium and indalloy 140, lubricant
local function uev_fluids(lubricant)
	local out = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
	}
	if lubricant then out[#out + 1] = { type = "fluid", name = "lubricant", amount = 400 } end
	return out
end

uev_component("uev-motor", join({
	{ type = "item", name = "long-magnetic-samarium-rod", amount = 4 },
	{ type = "item", name = "long-infinity-rod", amount = 8 },
	{ type = "item", name = "infinity-ring", amount = 8 },
	{ type = "item", name = "infinity-round", amount = 32 },
	{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 64 },
	{ type = "item", name = "draconium-cable", amount = 8 },
}, uev_fluids(true)))
uev_component("uev-pump", join({
	{ type = "item", name = "uev-motor", amount = 1 },
	{ type = "item", name = "cosmic-neutronium-plate", amount = 12 },
	{ type = "item", name = "infinity-plate", amount = 4 },
	{ type = "item", name = "infinity-screw", amount = 16 },
	{ type = "item", name = "silicone-rubber-ring", amount = 64 },
	{ type = "item", name = "infinity-rotor", amount = 4 },
	{ type = "item", name = "draconium-cable", amount = 8 },
}, uev_fluids(true)))
uev_component("uev-conveyor-module", join({
	{ type = "item", name = "uev-motor", amount = 2 },
	{ type = "item", name = "infinity-plate", amount = 2 },
	{ type = "item", name = "infinity-ring", amount = 8 },
	{ type = "item", name = "infinity-round", amount = 64 },
	{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
	{ type = "item", name = "draconium-cable", amount = 8 },
}, uev_fluids(true)))
uev_component("uev-piston", join({
	{ type = "item", name = "uev-motor", amount = 1 },
	{ type = "item", name = "infinity-plate", amount = 6 },
	{ type = "item", name = "infinity-ring", amount = 8 },
	{ type = "item", name = "infinity-round", amount = 64 },
	{ type = "item", name = "infinity-rod", amount = 8 },
	{ type = "item", name = "large-infinity-gear", amount = 2 },
	{ type = "item", name = "infinity-gear", amount = 4 },
	{ type = "item", name = "draconium-cable", amount = 16 },
}, uev_fluids(true)))
uev_component("uev-robot-arm", join({
	{ type = "item", name = "uev-motor", amount = 2 },
	{ type = "item", name = "uev-piston", amount = 1 },
	{ type = "item", name = "long-infinity-rod", amount = 8 },
	{ type = "item", name = "large-infinity-gear", amount = 2 },
	{ type = "item", name = "infinity-gear", amount = 6 },
	{ type = "item", name = "uev-circuit", amount = 2 },
	{ type = "item", name = "uhv-circuit", amount = 4 },
	{ type = "item", name = "uv-circuit", amount = 8 },
	{ type = "item", name = "draconium-cable", amount = 24 },
}, uev_fluids(true)))
uev_component("uev-emitter", join({
	{ type = "item", name = "infinity-frame", amount = 1 },
	{ type = "item", name = "uev-motor", amount = 1 },
	{ type = "item", name = "infinity-rod", amount = 16 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uev-circuit", amount = 4 },
	{ type = "item", name = "infinity-foil", amount = 32 },
	{ type = "item", name = "draconium-cable", amount = 28 },
}, uev_fluids(true)))
uev_component("uev-sensor", join({
	{ type = "item", name = "infinity-frame", amount = 1 },
	{ type = "item", name = "uev-motor", amount = 1 },
	{ type = "item", name = "infinity-plate", amount = 8 },
	{ type = "item", name = "gravi-star", amount = 8 },
	{ type = "item", name = "uev-circuit", amount = 4 },
	{ type = "item", name = "infinity-foil", amount = 32 },
	{ type = "item", name = "draconium-cable", amount = 28 },
}, uev_fluids(true)))
uev_component("uev-field-generator", join({
	{ type = "item", name = "infinity-frame", amount = 1 },
	{ type = "item", name = "uev-emitter", amount = 4 },
	{ type = "item", name = "cosmic-neutronium-plate", amount = 6 },
	{ type = "item", name = "gravi-star", amount = 4 },
	{ type = "item", name = "uev-circuit", amount = 8 },
	{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 64 },
	{ type = "item", name = "draconium-cable", amount = 32 },
}, uev_fluids(false)))

--- Casing and hull: cosmic neutronium plates (draft: bedrockium; bedrockium plates since issue #36,
--- 137-fork-endgame-materials.lua) and draconium cable
create_item{
	name = "uev-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-plate", amount = 8 },
	},
}
create_item{
	name = "uev-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uev-machine-casing", amount = 1 },
		{ type = "item", name = "draconium-cable", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 },
	},
}



--------------------------------------------------------------------------------
--- 4) FUSION REACTOR MK4
--- Controller, reactor and casing MK3 are the drafts in 21-luv-age-item.lua. The MK4 is the UEV
--- tier (16 UEV energy hatches, 32 UEV hulls), UEV circuits in the controller. Drafts fixed here:
---   * the reactor needs its controller (the draft called it "computer")
---   * casing MK3: category typo `uvh-...`; UU matter, cinobite, octiron and astral titanium ->
---     tritanium and cosmic neutronium melt, one UHV motor per casing (the draft: 2 motors and a
---     piston, 79 casings would have been 240 motors)
---   * the controller uses dracofinium wire (draft: triamerotronium) and FPIC wafers (GT)
---   * the reactor takes 16 advanced fusion coils (draft: 32; the MK3 takes 8): each needs a UHV
---     emitter and sensor
---   * superdense neutronium plate: 64 plates in the UHV compressor
--- The two MK4 melts of the drafts, molten rhugnor (infinity + molten quantum) and molten
--- flerovium (plutonium-241 + calcium plasma), need materials no line makes; they stay drafts.
--------------------------------------------------------------------------------

create_item{
	name = "superdense-neutronium-plate",
	category = "uhv-compressor-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "neutronium-plate", amount = 64 },
	},
}

redo("fusion-machine-casing-mk3", {
	category = "uhv-assembling-machine-recipes",
	energy_required = 15 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-machine-casing-mk2", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 16 },
		{ type = "item", name = "iv-circuit", amount = 8 },
		{ type = "item", name = "tritanium-plate", amount = 8 },
		{ type = "item", name = "neutronium-plate", amount = 8 },
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "fluid", name = "molten-tritanium", amount = 57.6 },
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 57.6 },
	},
})

redo("fusion-reactor-mk4-controller", {
	category = "zpm-assembly-line-recipes",
	energy_required = 60 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "advanced-fusion-coil", amount = 1 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "superdense-neutronium-plate", amount = 1 },
		{ type = "item", name = "uhv-field-generator", amount = 2 },
		{ type = "item", name = "fpic-wafer", amount = 48 },
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 64 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 115.2 },
	},
})

redo("fusion-reactor-mk4", {
	category = "uhv-assembling-machine-recipes",
	energy_required = 300 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-reactor-mk4-controller", amount = 1 },
		{ type = "item", name = "advanced-fusion-coil", amount = 16 },
		{ type = "item", name = "fusion-machine-casing-mk3", amount = 79 },
		{ type = "item", name = "uev-energy-hatch", amount = 16 },
		{ type = "item", name = "uev-machine-hull", amount = 32 },
	},
})

--- Fusion reactor: 9x9, two fluid inputs (north) and one output (south) like the MK1, MK2 and MK3
clone_multiblock{
	name = "fusion-reactor-mk4", source = "fusion-reactor-mk1", size = { 9, 9 },
	categories = { "mk1-fusion-reactor-recipes", "mk2-fusion-reactor-recipes", "mk3-fusion-reactor-recipes",
		"mk4-fusion-reactor-recipes", "luv-fusion-reactor-recipes", "zpm-fusion-reactor-recipes",
		"uv-fusion-reactor-recipes", "uhv-fusion-reactor-recipes", "uev-fusion-reactor-recipes" },
	speed = UEV_SPEED, energy = "327.68MW",
	icon = data.raw.item["fusion-reactor-mk4"].icon,
	subgroup = "subgroup-uev-age-multiblocks",
}



--------------------------------------------------------------------------------
--- 5) UEV VOLTAGE COIL, AWAKENED DRACONIUM COIL AND UEV ENERGY HATCH
--- GT: the UEV coil is a magnetic samarium rod with 16 fine cosmic neutronium wires. The UEV blast
--- furnace coil is awakened draconium (GT: draconium melt in a chemical bath); here it is built like
--- the tritanium coil: wire, foil and a melt.
--- Energy hatch as in 128-fork-uhv.lua: cryogenic helium instead of coolant cells, FPICs (GT), no UU
--- matter.
--------------------------------------------------------------------------------

create_item{
	name = "extremely-ultimate-voltage-coil",
	category = "uev-assembling-machine-recipes",
	energy_required = 10 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 16 },
	},
}
create_item{
	name = "awakened-draconium-coil-block",
	category = "uhv-assembling-machine-recipes",
	energy_required = 50 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "draconium-wire", amount = 16 },
		{ type = "item", name = "infinity-foil", amount = 8 },
		{ type = "fluid", name = "molten-draconium", amount = 14.4 },
	},
}
create_item{
	name = "uev-energy-hatch",
	category = UEV_AL,
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "uev-machine-hull", amount = 1 },
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 4 },
		{ type = "item", name = "femto-power-ic", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "extremely-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "uev-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
	},
}



--------------------------------------------------------------------------------
--- 6) UEV SCIENCE PACK (cryogenic-science-pack), like the UHV pack in 128-fork-uhv.lua:
--- the tier's motor and circuits, its main metal, the coils of the tier below, the field
--- generator of the tier below and a melt -> 10 packs
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "uev-science-pack",
	category = "uhv-assembling-machine-recipes",
	energy_required = UHV_SPEED * 60,
	order = "k",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "uev-motor", amount = 1 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "infinity-plate", amount = 4 },
		{ type = "item", name = "tritanium-coil-block", amount = 4 },
		{ type = "item", name = "uhv-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-infinity", amount = 144 },
	},
	results = {
		{ type = "item", name = "cryogenic-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 7) UEV MACHINES (copies of the UHV machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the UEV energy hatch.
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["uev-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "uev-age-production-machine", group = "production", order = "i-z-uev" } })
end

UEV_BASIC_MACHINES = UHV_BASIC_MACHINES
UEV_UPGRADE_MACHINES = UHV_UPGRADE_MACHINES

local uev_machine_recipes, uev_multiblock_recipes = {}, {}
for _, base in pairs(UEV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "uhv", "uev", 6, nil)
	uev_machine_recipes[#uev_machine_recipes + 1] = "uev-" .. base
end
for _, base in pairs(UEV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "uhv", "uev", nil, nil)
	uev_multiblock_recipes[#uev_multiblock_recipes + 1] = "uev-" .. base
end



--------------------------------------------------------------------------------
--- 8) PHASE 4 WORKAROUNDS THAT ARE NOT NEEDED ANY MORE
---   * UHV field generator: 4 UEV circuits like GT (it used 8 UHV circuits). The recipe stays
---     unlocked by uhv-components, so saves that had it keep it (it is craftable once the UEV
---     circuit is).
--------------------------------------------------------------------------------

replace_ingredient("uhv-field-generator", "uhv-circuit", "uev-circuit", 4)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- UHV science (lead to the UEV science pack): the UEV metals, the bio line, the UEV circuit and the
--- UEV components.
--- UEV science: machines, energy hatch, multiblocks, fusion reactor MK4 with its recipes.
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

--- UHV science
do
	tech{
		name = "uev-materials", prerequisites = { "uhv-multiblocks", "fusion-plasmas-mk3" }, packs = 10, count = 2500,
		recipes = join({
			"molten-draconium", "molten-cosmic-neutronium-bootstrap", "molten-infinity-bootstrap",
			"cosmic-neutronium-ingot", "cosmic-neutronium-plate", "fine-cosmic-neutronium-wire", "cosmic-neutronium-foil",
			"draconium-ingot", "draconium-wire", "draconium-cable",
		}, metal_parts("infinity", { "%-ingot", "%-plate", "%-rod", "long-%-rod", "%-frame", "%-gear", "large-%-gear",
			"%-ring", "%-round", "%-screw", "%-rotor", "%-wire", "%-foil" })),
	}
	tech{
		name = "bio-processors", prerequisites = { "uev-materials", "wetware-processor-mainframes" }, packs = 10, count = 3000,
		recipes = { "bio-cells", "bioware-printed-circuit-board", "bio-processing-unit", "bio-processor",
			"bio-processor-assembly", "bio-processor-supercomputer" },
	}
	tech{
		name = "bio-processor-mainframes", prerequisites = { "bio-processors" }, packs = 10, count = 3500,
		recipes = { "bio-processor-mainframe" },
	}
	tech{
		name = "uev-components", prerequisites = { "bio-processor-mainframes" }, packs = 10, count = 4000,
		recipes = {
			"uev-motor", "uev-pump", "uev-conveyor-module", "uev-piston", "uev-robot-arm", "uev-emitter", "uev-sensor",
			"uev-field-generator", "uev-machine-casing", "uev-machine-hull",
		},
	}
end

--- The UEV science tech (upstream, researched with UHV science) unlocks the pack
fork_add_unlock("cryogenic-science-pack", "uev-science-pack")
table.insert(data.raw.technology["cryogenic-science-pack"].prerequisites, "uev-components")

--- UEV science. Machines first: the UEV voltage coil needs the UEV assembler.
tech{
	name = "uev-machines", prerequisites = { "cryogenic-science-pack" }, packs = 11, count = 2500,
	recipes = uev_machine_recipes,
}
tech{
	name = "uev-energy-hatches", prerequisites = { "uev-machines", "femto-power-ics" }, packs = 11, count = 3000,
	recipes = {
		"hot-dracofinium-ingot", "dracofinium-ingot", "dracofinium-dust", "dracofinium-wire",
		"dracofinium-superconductive-wire", "superconducting-coil-block-uev", "awakened-draconium-coil-block",
		"extremely-ultimate-voltage-coil", "uev-energy-hatch",
	},
}
tech{
	name = "uev-multiblocks", prerequisites = { "uev-energy-hatches" }, packs = 11, count = 3000,
	recipes = uev_multiblock_recipes,
}
tech{
	name = "fusion-reactor-mk4", prerequisites = { "uev-energy-hatches", "femto-power-ics" }, packs = 11, count = 4000,
	recipes = { "superdense-neutronium-plate", "fusion-machine-casing-mk3", "fusion-reactor-mk4-controller",
		"fusion-reactor-mk4" },
}
tech{
	name = "fusion-plasmas-mk4", prerequisites = { "fusion-reactor-mk4" }, packs = 11, count = 4000,
	recipes = { "molten-cosmic-neutronium", "molten-infinity" },
}
