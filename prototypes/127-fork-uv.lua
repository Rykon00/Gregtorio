--------------------------------------------------------------------------------
--- FORK UV (roadmap phase 3)
--- Makes the UV tier playable on top of the finished ZPM tier (126-fork-zpm.lua):
---   * UV materials: naquadah alloy wire/foil/cable, naquadria, americium and neutronium (both
---     from the fusion reactor like in GT5-Unofficial), gravistar
---   * superconductors: ITBTC + enderium (LuV, for the UV circuit), palladium-naqindium (ZPM),
---     naquamiridium (UV)
---   * the UV circuit (crystal processor mainframe) and the ZPM assembly line
---   * UV components from the ZPM assembly line, UV casing and hull
---   * fusion reactor MK2 with its plasmas (mk2-fusion-reactor-recipes)
---   * UV science pack (agricultural-science-pack), UV voltage coil, trinium coil, UV energy hatch
---   * UV machines: the ZPM machines one tier up (fork_make_tier_machine)
---   * the UV technologies, and the Phase 2 workarounds that are no longer needed
--- 25-uv-age-item.lua is not loaded by data.lua (it is not valid Lua and mostly holds later
--- tiers), so the UV parts of it are rebuilt here after the GT5-Unofficial recipes.
--- Everything else in it (research station, draconic fusion, nano forge, bio processors)
--- waits for later phases.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-UV: missing recipe: " .. name)
	return false
end

local function set_ingredient(recipe_name, from, to)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UV: missing recipe: " .. recipe_name) return end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.name == from then i.name = to end
		end
	end
end

--- Replace one ingredient (name and amount) of a recipe
local function replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UV: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

local function set_category(recipe_name, category)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-UV: missing recipe: " .. recipe_name) return end
	r.category = category
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

--- Copy of an existing machine as a multiblock with its own name, categories and sprites
---   def = { name, source, size = {w, h}, categories, speed, energy }
local function clone_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-UV: missing source machine " .. def.source) return end
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

--- (a fresh table per recipe: create_ingot puts it into the ingredient lists as it is)
local function argon() return { type = "fluid", name = "argon", amount = 5 } end



--------------------------------------------------------------------------------
--- 1) UV MATERIALS
--------------------------------------------------------------------------------

--- Naquadah alloy: wire and foil, and the UV cable (GT: hull, motor, pump, robot arm ...).
--- The draft in 25-uv-age-item.lua made 4 cables per craft; like the ZPM cable it is 1 here.
create_metal_parts{ material = "naquadah-alloy", speed = NAQUADAH_ALLOY_SPEED, make_wire = true, make_foil = true }
create_item{
	name = "naquadah-alloy-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
	},
}

--- Naquadah plate (UV pump) and naquadria plate and foil (UV emitter and sensor)
create_metal_parts{ material = "naquadah", speed = NAQUADAH_SPEED, make_plate = true }
create_metal_parts{ material = "naquadria", speed = NAQUADRIA_SPEED, make_plate = true, make_foil = true }

--- Molten metals of the fusion reactor. Colors and icons like the ones of 125-fork-luv-endgame.lua.
for _, f in pairs({
	{ "molten-naquadah", "dark-blue-spackled-fluid", { 0.20, 0.25, 0.45 } },
	{ "molten-naquadria", "spackled-purple-fluid", { 0.50, 0.25, 0.65 } },
	{ "molten-neutronium", "nearly-white-fluid", { 0.85, 0.90, 0.95 } },
	{ "molten-americium", "spackled-silvery-gold-fluid", { 0.85, 0.75, 0.55 } },
	{ "molten-lutetium", "silver-blue-spackled-fluid", { 0.70, 0.78, 0.88 } },
	{ "molten-chrome", "spackled-light-blue-fluid", { 0.60, 0.75, 0.85 } },
	{ "molten-beryllium", "spackled-medium-gray-fluid", { 0.55, 0.60, 0.55 } },
	{ "molten-titanium", "titanium", { 0.70, 0.72, 0.78 } },
	{ "molten-silver", "nearly-white-fluid", { 0.90, 0.90, 0.95 } },
	{ "molten-cobalt", "spackled-blue-fluid", { 0.25, 0.35, 0.75 } },
	{ "molten-silicon", "medium-gray-fluid", { 0.45, 0.45, 0.50 } },
	{ "molten-tritanium", "spackled-orange-fluid", { 0.85, 0.60, 0.30 } },
	{ "sulfur-plasma", "spackled-yellow-fluid", { 0.95, 0.90, 0.30 } },
	{ "nitrogen-plasma", "nitrogen", { 0.55, 0.65, 0.95 } },
	{ "zinc-plasma", "spackled-light-blue-fluid", { 0.60, 0.80, 0.95 } },
	{ "niobium-plasma", "spackled-mint-green-fluid", { 0.55, 0.85, 0.75 } },
	{ "tin-plasma", "pale-green-fluid", { 0.75, 0.90, 0.75 } },
	{ "titanium-plasma", "titanium", { 0.70, 0.75, 0.95 } },
	{ "oxygen-plasma", "oxygen", { 0.55, 0.75, 1.00 } },
	{ "krypton-plasma", "krypton", { 0.80, 0.85, 0.60 } },
}) do
	fork_fluid(f[1], f[2], f[3])
end

--- Metals that fusion needs as a melt and nothing made yet (like molten neodymium in phase 1)
local function extract(fluid_name, input_item, recipe_name)
	recipe_name = recipe_name or fluid_name
	if data.raw.recipe[recipe_name] then return end
	create_recipe{
		name = recipe_name,
		category = "iv-extractor-recipes",
		energy_required = 1.2 * IV_SPEED,
		ingredients = { { type = "item", name = input_item, amount = 1 } },
		results = { { type = "fluid", name = fluid_name, amount = 14.4 } },
	}
end
extract("molten-naquadah", "naquadah-ingot")
extract("molten-naquadria", "naquadria-ingot")
extract("molten-aluminium", "aluminium-ingot")
--- (the foundry recipe of molten copper needs copper ore, which does not exist)
extract("molten-copper", "copper-ingot", "molten-copper-extraction")
extract("molten-beryllium", "beryllium-ingot")
extract("molten-titanium", "titanium-ingot")
extract("molten-silver", "silver-ingot")
extract("molten-silicon", "silicon-ingot")
extract("molten-chrome", "chromium-ingot")
extract("molten-cobalt", "cobalt-dust")
extract("molten-lutetium", "lutetium-dust")

--- Lutetium: GT gets it from depleted thorium fuel rods, which needs a nuclear reactor that
--- Gregtorio does not have yet. It is a rare earth, so it comes out of the rare earth line
--- (like zirconium in 100-fork-fixes.lua), needed for americium.
create_recipe{
	name = "rare-earth-1-lutetium-electrolysis",
	category = "ev-electrolyzer-recipes",
	energy_required = 12 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "rare-earth-1-dust", amount = 4 },
	},
	results = {
		{ type = "item", name = "lutetium-dust", amount = 1 },
		{ type = "item", name = "yttrium-dust", amount = 1, probability = 0.25 },
	},
	main_product = "lutetium-dust",
}

--- Palladium ingot: nothing upstream makes it (only the dust), but the multilayered circuit board
--- of the lapotronic energy orb cluster needs palladium foil. Like the dust smelters of create_ore.
create_recipe{
	recipe_name = "palladium-dust-smelter",
	category = "smelting",
	subgroup = "subgroup-smelting",
	order = "e",
	energy_required = 10,
	ingredients = { { type = "item", name = "palladium-dust", amount = 1 } },
	results = { { type = "item", name = "palladium-ingot", amount = 1 } },
}

--- Americium and neutronium are made in the fusion reactor (GT: FT2 and FT3). Both come out as a
--- melt, like the endgame metals of the drafts: ingot, plates, rods ... solidify from it.
create_endgame_parts{
	name = "americium",
	tier = "zpm",
	speed = ZPM_SPEED,
	skip_block = true,
	skip_rod = true,
	skip_long_rod = true,
	skip_frame = true,
	skip_wire = true,
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
	name = "neutronium",
	tier = "zpm",
	speed = ZPM_SPEED,
	skip_block = true,
	skip_wire = true,
	skip_fine_wire = true,
	skip_foil = true,
	skip_bolt = true,
	skip_large_gear = true,
	skip_dense_plate = true,
	skip_superdense_plate = true,
}
--- Issue #31: 4 ingots of melt like the large tritanium gear (the generic large gear is 40 ingots,
--- which made the UV piston cost as much as the UHV one)
create_item{
	name = "large-neutronium-gear",
	category = "zpm-fluid-solidifier-recipes",
	energy_required = ZPM_SPEED * 6.4,
	ingredients = {
		{ type = "fluid", name = "molten-neutronium", amount = 57.6 },
	},
}

--- Gravistar (GT: autoclave, quantum star + molten neutronium) for the UV emitter and sensor
create_item{
	name = "gravi-star",
	category = "iv-autoclave-recipes",
	energy_required = 24 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "quantum-star", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 28.8 },
	},
}

--- Superdense europium plate (fusion reactor MK2 controller): 64 plates
create_item{
	name = "superdense-europium-plate",
	category = "zpm-compressor-recipes",
	energy_required = ZPM_SPEED * 20,
	ingredients = {
		{ type = "item", name = "europium-plate", amount = 64 },
	},
}



--------------------------------------------------------------------------------
--- 2) SUPERCONDUCTORS
--- GT: a base alloy (blast furnace) is drawn to wire and cooled with a pump and pipes of the
--- tier's metal, like the IV superconductor in 19-iv-age-item.lua: one pump per batch of wire.
---   LuV  ITBTC + enderium        (draft in 21-luv-age-item.lua, for the UV circuit)
---   ZPM  palladium-naqindium     (GT: naquadah 4, indium 2, palladium 6, osmium 1)
---   UV   naquamiridium           (GT: naquadria 4, osmiridium 3, europium 1, samarium 1)
--- The ZPM base is blasted in the LuV blast furnace: the ZPM blast furnace needs the ZPM energy
--- hatch, which needs the ZPM superconductor.
--------------------------------------------------------------------------------

--- ITBTC alloy and enderium: their upstream definitions in 08-material-processing-module.lua are
--- commented out. Enderium without thaumium and ender pearl dust: 4 dusts make 4 ingots, and it
--- is solidified in a vacuum freezer (a fluid solidifier has no output for the helium).
create_ingot("itbtc-alloy", "luv", 10 * LUV_SPEED, {
		{ type = "item", name = "indium", amount = 4 },
		{ type = "item", name = "tin-dust", amount = 2 },
		{ type = "item", name = "barium", amount = 2 },
		{ type = "item", name = "titanium-dust", amount = 1 },
		{ type = "item", name = "copper-dust", amount = 7 },
		{ type = "fluid", name = "oxygen", amount = 1400 },
	},
	30, "iv", IV_SPEED * 63, argon(),
	"luv", LUV_SPEED * 20, false, true, false, nil, true, false)
create_ingot("enderium", nil, nil, {
		{ type = "item", name = "tin-dust", amount = 2 },
		{ type = "item", name = "platinum-dust", amount = 1 },
		{ type = "item", name = "silver-dust", amount = 1 },
	},
	4, "ev", nil, argon(),
	"ev", EV_SPEED * 1.2, true, false, true, EV_SPEED * 80, true, false)
create_metal_parts{ material = "enderium", speed = ENDERIUM_SPEED, make_plate = true }
--- Draft typo: the wire mill category
set_category("itbtc-alloy-wire", "lv-wiremill-recipes")

--- ZPM superconductor
create_ingot("palladium-naqindium", "luv", 10 * LUV_SPEED, {
		{ type = "item", name = "naquadah-dust", amount = 4 },
		{ type = "item", name = "indium", amount = 2 },
		{ type = "item", name = "palladium-dust", amount = 6 },
		{ type = "item", name = "osmium-dust", amount = 1 },
	},
	13, "luv", LUV_SPEED * 81, argon(),
	"luv", LUV_SPEED * 24, false, true, false, nil, true, false)
create_metal_parts{ material = "palladium-naqindium", speed = 10, make_wire = true }
create_item{
	name = "palladium-naqindium-superconductive-wire",
	category = "luv-assembling-machine-recipes",
	energy_required = LUV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "palladium-naqindium-wire", amount = 18 },
		{ type = "item", name = "zpm-pump", amount = 1 },
		{ type = "fluid", name = "molten-naquadah", amount = 86.4 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1000 },
	},
	results = {
		{ type = "item", name = "palladium-naqindium-superconductive-wire", amount = 18 },
	},
}

--- UV superconductor
create_ingot("naquamiridium", "zpm", 10 * ZPM_SPEED, {
		{ type = "item", name = "naquadria-dust", amount = 4 },
		{ type = "item", name = "osmiridium-dust", amount = 3 },
		{ type = "item", name = "europium-ingot", amount = 1 },
		{ type = "item", name = "samarium-dust", amount = 1 },
	},
	9, "zpm", ZPM_SPEED * 99, argon(),
	"zpm", ZPM_SPEED * 30, false, true, false, nil, true, false)
create_metal_parts{ material = "naquamiridium", speed = 10, make_wire = true }
create_item{
	name = "naquamiridium-superconductive-wire",
	category = "zpm-assembling-machine-recipes",
	energy_required = ZPM_SPEED * 32,
	ingredients = {
		{ type = "item", name = "naquamiridium-wire", amount = 21 },
		{ type = "item", name = "uv-pump", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 100.8 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1200 },
	},
	results = {
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 21 },
	},
}



--------------------------------------------------------------------------------
--- 3) UV CIRCUIT: crystal processor mainframe (GT: crystal line IV .. UV; the wetware mainframe
--- is the UHV circuit, so wetware belongs to phase 4). The recipe is the draft in
--- 21-luv-age-item.lua; its superconductor is the ITBTC wire above.
--------------------------------------------------------------------------------

create_item{ skip_recipe = true,
	name = "uv-circuit",
	subgroup = "subgroup-luv-circuit-assembly-line-recipes",
}



--------------------------------------------------------------------------------
--- 4) ZPM ASSEMBLY LINE: the LuV assembly line one tier up. Runs at twice its speed and does
--- the zpm-assembly-line-recipes (the UV components) on top of the older ones.
--------------------------------------------------------------------------------

do
	local ZPM_AL = "zpm-assembly-line"
	category("zpm-assembly-line-recipes")
	local m = table.deepcopy(data.raw["assembling-machine"]["luv-assembly-line"])
	m.name = ZPM_AL
	m.crafting_categories = { "iv-assembly-line-recipes", "luv-assembly-line-recipes", "zpm-assembly-line-recipes" }
	m.crafting_speed = LUV_SPEED
	m.energy_usage = EU16_LuV
	m.minable = { mining_time = 1, result = ZPM_AL }
	m.icon = ICON_PATH .. ZPM_AL .. ".png"
	m.next_upgrade = nil
	local w, h = 9, 3
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. ZPM_AL .. "-idle.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. ZPM_AL .. "-working.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ m })
	create_item{
		name = ZPM_AL,
		category = "zpm-assembling-machine-recipes",
		energy_required = 120 * ZPM_SPEED,
		subgroup = "subgroup-zpm-age-multiblocks",
		stack_size = 10,
		place_result = ZPM_AL,
		ingredients = {
			{ type = "item", name = "luv-assembly-line", amount = 1 },
			{ type = "item", name = "zpm-energy-hatch", amount = 2 },
			{ type = "item", name = "zpm-robot-arm", amount = 4 },
			{ type = "item", name = "zpm-conveyor-module", amount = 2 },
			{ type = "item", name = "zpm-circuit", amount = 4 },
			{ type = "item", name = "zpm-machine-hull", amount = 1 },
		},
		results = {
			{ type = "item", name = ZPM_AL, amount = 1 },
			{ type = "item", name = "iv-energy-hatch", amount = 2 },
		},
		main_product = ZPM_AL,
	}
end



--------------------------------------------------------------------------------
--- 5) UV COMPONENTS (zpm-assembly-line-recipes)
--- GT5-Unofficial assembly line recipes (30 s at ZPM). Amounts as in the ZPM components:
--- 1 GT ingot of fluid = 14.4, 2000 L lubricant = 200, a 4x cable = 4 cables.
--- The line runs at twice the LuV speed, so a component takes a minute.
--- Changes against GT:
---   * pump: naquadah plates instead of the large naquadah pipe
---   * field generator: UHV circuits do not exist yet (phase 4) -> twice the UV circuits
--------------------------------------------------------------------------------

local UV_AL = "zpm-assembly-line-recipes"
local UV_AL_TIME = 30 * ZPM_SPEED

local function uv_component(name, ingredients)
	create_item{
		name = name,
		category = UV_AL,
		energy_required = UV_AL_TIME,
		ingredients = ingredients,
	}
end

--- Fluids of every UV component: naquadria and indalloy 140 (times the amount), lubricant
local function uv_fluids(indalloy, lubricant)
	local out = {
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = indalloy },
	}
	if lubricant then out[#out + 1] = { type = "fluid", name = "lubricant", amount = 200 } end
	return out
end
local function join(a, b)
	for _, x in pairs(b) do a[#a + 1] = x end
	return a
end

--- Issue #31: 64 fine americium wires (GT: 384, 48 americium ingots) and 8 long neutronium rods
--- (GT: 4), like the cut UHV to UXV motors (48 to 64 fine wires, 8 long rods)
uv_component("uv-motor", join({
	{ type = "item", name = "long-magnetic-samarium-rod", amount = 2 },
	{ type = "item", name = "long-neutronium-rod", amount = 8 },
	{ type = "item", name = "neutronium-ring", amount = 4 },
	{ type = "item", name = "neutronium-round", amount = 16 },
	{ type = "item", name = "fine-americium-wire", amount = 64 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
}, uv_fluids(129.6, true)))
uv_component("uv-pump", join({
	{ type = "item", name = "uv-motor", amount = 1 },
	{ type = "item", name = "naquadah-plate", amount = 12 },
	{ type = "item", name = "neutronium-plate", amount = 2 },
	{ type = "item", name = "neutronium-screw", amount = 8 },
	{ type = "item", name = "silicone-rubber-ring", amount = 16 },
	{ type = "item", name = "neutronium-rotor", amount = 2 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
}, uv_fluids(129.6, true)))
uv_component("uv-conveyor-module", join({
	{ type = "item", name = "uv-motor", amount = 2 },
	{ type = "item", name = "neutronium-plate", amount = 2 },
	{ type = "item", name = "neutronium-ring", amount = 4 },
	{ type = "item", name = "neutronium-round", amount = 32 },
	{ type = "item", name = "silicone-rubber-sheet", amount = 40 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
}, uv_fluids(129.6, true)))
uv_component("uv-piston", join({
	{ type = "item", name = "uv-motor", amount = 1 },
	{ type = "item", name = "neutronium-plate", amount = 6 },
	{ type = "item", name = "neutronium-ring", amount = 4 },
	{ type = "item", name = "neutronium-round", amount = 32 },
	{ type = "item", name = "neutronium-rod", amount = 4 },
	{ type = "item", name = "large-neutronium-gear", amount = 1 },
	{ type = "item", name = "neutronium-gear", amount = 2 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 16 },
}, uv_fluids(129.6, true)))
uv_component("uv-robot-arm", join({
	{ type = "item", name = "long-neutronium-rod", amount = 4 },
	{ type = "item", name = "large-neutronium-gear", amount = 1 },
	{ type = "item", name = "neutronium-gear", amount = 3 },
	{ type = "item", name = "uv-motor", amount = 2 },
	{ type = "item", name = "uv-piston", amount = 1 },
	{ type = "item", name = "uv-circuit", amount = 2 },
	{ type = "item", name = "zpm-circuit", amount = 4 },
	{ type = "item", name = "luv-circuit", amount = 8 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 24 },
}, uv_fluids(230.4, true)))
uv_component("uv-emitter", join({
	{ type = "item", name = "neutronium-frame", amount = 1 },
	{ type = "item", name = "uv-motor", amount = 1 },
	{ type = "item", name = "neutronium-rod", amount = 8 },
	{ type = "item", name = "gravi-star", amount = 4 },
	{ type = "item", name = "uv-circuit", amount = 4 },
	{ type = "item", name = "naquadria-foil", amount = 192 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 28 },
}, uv_fluids(230.4, false)))
uv_component("uv-sensor", join({
	{ type = "item", name = "neutronium-frame", amount = 1 },
	{ type = "item", name = "uv-motor", amount = 1 },
	{ type = "item", name = "neutronium-plate", amount = 8 },
	{ type = "item", name = "gravi-star", amount = 4 },
	{ type = "item", name = "uv-circuit", amount = 4 },
	{ type = "item", name = "naquadria-foil", amount = 192 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 28 },
}, uv_fluids(230.4, false)))
uv_component("uv-field-generator", join({
	{ type = "item", name = "neutronium-frame", amount = 1 },
	{ type = "item", name = "neutronium-plate", amount = 6 },
	{ type = "item", name = "gravi-star", amount = 2 },
	{ type = "item", name = "uv-emitter", amount = 4 },
	{ type = "item", name = "uv-circuit", amount = 8 },
	{ type = "item", name = "fine-americium-wire", amount = 384 },
	{ type = "item", name = "naquadah-alloy-cable", amount = 32 },
}, uv_fluids(230.4, false)))

--- Casing and hull like GT: osmium plates and naquadah alloy cable
create_item{
	name = "uv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "osmium-plate", amount = 8 },
	},
}
create_item{
	name = "uv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uv-machine-casing", amount = 1 },
		{ type = "item", name = "osmium-plate", amount = 1 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 2 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
	},
}



--------------------------------------------------------------------------------
--- 6) FUSION REACTOR MK2
--- The controller and the reactor are the drafts in 21-luv-age-item.lua. In GT the MK2 reactor
--- is the ZPM tier (16 ZPM energy hatches) and needs UV circuits. Drafts fixed here:
---   * the reactor needs its controller (the draft called it "computer")
---   * PPIC wafers need the doped wafers of the water purification line (not built yet) ->
---     UHPIC wafers like in the MK1 controller
--- The plasmas are the mk2-fusion-reactor-recipes drafts; the ones whose inputs exist now are
--- activated (missing melts and fluids are made above). Force plasma (arcanite), the liquid fuels
--- and the naquadah fuel need lines that do not exist and stay drafts.
--------------------------------------------------------------------------------

category("mk2-fusion-reactor-recipes")

do
	local r = data.raw.recipe["fusion-reactor-mk2-controller"]
	if r then
		r.category = "zpm-assembly-line-recipes"
		r.energy_required = 50 * ZPM_SPEED
		replace_ingredient(r.name, "ppic-wafer", "uhpic-wafer", 48)
	end
	set_ingredient("fusion-reactor-mk2", "fusion-reactor-computer-mk2", "fusion-reactor-mk2-controller")
	r = data.raw.recipe["fusion-reactor-mk2"]
	if r then r.category = "zpm-assembling-machine-recipes"; r.energy_required = 300 * ZPM_SPEED end
end

--- Fusion reactor: 9x9, two fluid inputs (north) and one output (south) like the MK1
clone_multiblock{
	name = "fusion-reactor-mk2", source = "fusion-reactor-mk1", size = { 9, 9 },
	categories = { "mk1-fusion-reactor-recipes", "mk2-fusion-reactor-recipes",
		"luv-fusion-reactor-recipes", "zpm-fusion-reactor-recipes" },
	speed = ZPM_SPEED, energy = "81.92MW",
	icon = data.raw.item["fusion-reactor-mk2"].icon,
	subgroup = "subgroup-zpm-age-multiblocks",
}

--- Americium (GT FT2: lutetium + chrome; the draft used the mB of GT, here 1 ingot each)
do
	local r = data.raw.recipe["molten-americium"]
	if r then
		r.energy_required = 5 * ZPM_SPEED
		r.ingredients = {
			{ type = "fluid", name = "molten-lutetium", amount = 14.4 },
			{ type = "fluid", name = "molten-chrome", amount = 14.4 },
		}
		r.results = { { type = "fluid", name = "molten-americium", amount = 14.4 } }
	end
end

--- Neutronium (GT FT3: americium + naquadria). The MK3 reactor needs UHV circuits (phase 4),
--- so it is made in the MK2 reactor for now and can move to the MK3 later.
create_recipe{
	name = "molten-neutronium",
	category = "mk2-fusion-reactor-recipes",
	energy_required = 12 * ZPM_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-americium", amount = 14.4 },
		{ type = "fluid", name = "molten-naquadria", amount = 14.4 },
	},
	results = { { type = "fluid", name = "molten-neutronium", amount = 14.4 } },
}



--------------------------------------------------------------------------------
--- 7) UV VOLTAGE COIL, TRINIUM COIL AND UV ENERGY HATCH
--- GT: the UV coil is a magnetic samarium rod with 16 fine fluxed electrum wires; fluxed
--- electrum did not exist in Gregtorio, so it is americium (the UV metal) here
--- (137-fork-endgame-materials.lua switches it to fluxed electrum, issue #36).
--- Energy hatch like the ZPM one in 126-fork-zpm.lua: cryogenic helium instead of coolant cells,
--- UHPICs instead of the PPIC chip (needs the water purification line).
--- Trinium coil: the UV blast furnace coil (draft in 23-zpm-age-item.lua).
--------------------------------------------------------------------------------

create_item{
	name = "ultimate-voltage-coil",
	category = "uv-assembling-machine-recipes",
	energy_required = 10 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-americium-wire", amount = 16 },
	},
}
create_metal_parts{ material = "trinium", speed = TRINIUM_SPEED, make_wire = true }
create_item{
	name = "trinium-coil-block",
	category = "zpm-assembling-machine-recipes",
	energy_required = 50 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "trinium-wire", amount = 16 },
		{ type = "item", name = "enriched-naquadah-foil", amount = 8 },
		{ type = "fluid", name = "molten-naquadah", amount = 14.4 },
	},
}
create_item{
	name = "uv-energy-hatch",
	category = UV_AL,
	energy_required = 40 * ZPM_SPEED,
	subgroup = "subgroup-zpm-assembly-line-recipes",
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 4 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "uv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 800 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
	},
}



--------------------------------------------------------------------------------
--- 8) UV SCIENCE PACK (agricultural-science-pack), like the ZPM pack in 126-fork-zpm.lua:
--- the tier's motor and circuits, its main metal, the coils of the tier below, the field
--- generator of the tier below and a melt -> 10 packs
--------------------------------------------------------------------------------

create_recipe{
	recipe_name = "uv-science-pack",
	category = "zpm-assembling-machine-recipes",
	energy_required = ZPM_SPEED * 60,
	order = "i",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "uv-motor", amount = 1 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "neutronium-plate", amount = 4 },
		{ type = "item", name = "naquadah-coil-block", amount = 4 },
		{ type = "item", name = "zpm-field-generator", amount = 1 },
		{ type = "fluid", name = "molten-naquadria", amount = 144 },
	},
	results = {
		{ type = "item", name = "agricultural-science-pack", amount = 10 },
	},
}



--------------------------------------------------------------------------------
--- 9) UV MACHINES (copies of the ZPM machines, recipe one tier up; 101-fork-machines.lua)
--- Basic machines get generated sprites (tools/gen_sprites.py), multiblock upgrades keep
--- the graphics of the LuV version and need the UV energy hatch.
--------------------------------------------------------------------------------

if not data.raw["item-subgroup"]["uv-age-production-machine"] then
	data:extend({ { type = "item-subgroup", name = "uv-age-production-machine", group = "production", order = "i-z-uv" } })
end

UV_BASIC_MACHINES = ZPM_BASIC_MACHINES
UV_UPGRADE_MACHINES = ZPM_UPGRADE_MACHINES

local uv_machine_recipes, uv_multiblock_recipes = {}, {}
for _, base in pairs(UV_BASIC_MACHINES) do
	fork_make_tier_machine(base, "zpm", "uv", 6, nil)
	uv_machine_recipes[#uv_machine_recipes + 1] = "uv-" .. base
end
for _, base in pairs(UV_UPGRADE_MACHINES) do
	fork_make_tier_machine(base, "zpm", "uv", nil, nil)
	uv_multiblock_recipes[#uv_multiblock_recipes + 1] = "uv-" .. base
end



--------------------------------------------------------------------------------
--- 10) PHASE 2 WORKAROUNDS THAT ARE NOT NEEDED ANY MORE
---   * ZPM field generator: 4 UV circuits like GT (it used 8 ZPM circuits)
---   * ZPM energy hatch: the ZPM superconductor instead of the naquadah cable
---   * ZPM pump: enderium plates (GT: enderium pipe) instead of osmiridium plates. The enderium
---     recipes move to zpm-materials, which comes before the pump.
--- (the UHPICs stay: NPICs need the doped wafers of the water purification line)
--------------------------------------------------------------------------------

replace_ingredient("zpm-field-generator", "zpm-circuit", "uv-circuit", 4)
replace_ingredient("zpm-energy-hatch", "naquadah-cable", "palladium-naqindium-superconductive-wire", 4)
replace_ingredient("zpm-pump", "osmiridium-plate", "enderium-plate", 4)
for _, r in pairs({ "molten-enderium", "solidify-enderium-ingot", "enderium-plate" }) do
	fork_add_unlock("zpm-materials", r)
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- LuV science: the ZPM superconductor (the ZPM energy hatch needs it).
--- ZPM science: the UV circuit, the ZPM assembly line, fusion MK2, UV materials and components
--- (they lead to the UV science pack).
--- UV science: machines, energy hatch, multiblocks.
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack", "agricultural-science-pack" }
	local amounts = { SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
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

local function neutronium_parts()
	return { "neutronium-ingot", "neutronium-plate", "neutronium-rod", "long-neutronium-rod", "neutronium-frame",
		"neutronium-gear", "large-neutronium-gear", "neutronium-ring", "neutronium-round", "neutronium-screw",
		"neutronium-rotor" }
end

--- LuV science
tech{
	name = "zpm-superconductors", prerequisites = { "zpm-components" }, packs = 7, count = 2500,
	recipes = {
		"molten-naquadah", "palladium-naqindium-dust", "hot-palladium-naqindium-ingot", "palladium-naqindium-ingot",
		"palladium-naqindium-wire", "palladium-naqindium-superconductive-wire", "superconducting-coil-block-zpm",
	},
}
--- The ZPM energy hatch needs the ZPM superconductor now
table.insert(data.raw.technology["zpm-energy-hatches"].prerequisites, "zpm-superconductors")

--- ZPM science
--- The ZPM field generator needs UV circuits now
move_unlock("zpm-components", "zpm-field-generator")
tech{
	name = "crystal-processor-mainframes", prerequisites = { "zpm-machines", "crystal-processors" }, packs = 8, count = 2500,
	recipes = {
		"itbtc-alloy-dust", "hot-itbtc-alloy-ingot", "itbtc-alloy-ingot", "itbtc-alloy-wire",
		"luv-superconductor-wire-16x", "crystal-processor-mainframe", "zpm-field-generator",
	},
}
tech{
	name = "zpm-assembly-line", prerequisites = { "zpm-energy-hatches" }, packs = 8, count = 2500,
	--- the lapotronic energy orb cluster (draft in 21-luv-age-item.lua) is the first use of the line
	recipes = { "zpm-assembly-line", "naquadah-alloy-foil", "palladium-dust-smelter", "palladium-foil",
		"multilayered-fiber-reinforced-circuit-board", "energium-dust", "lapotron-dust", "raw-lapotron-crystal",
		"lapotron-crystal", "engraved-lapotron-chip", "lapotronic-energy-orb-cluster-assline" },
}
tech{
	name = "fusion-reactor-mk2", prerequisites = { "zpm-energy-hatches", "crystal-processor-mainframes" }, packs = 8, count = 3000,
	recipes = { "superdense-europium-plate", "fusion-machine-casing", "fusion-reactor-mk2-controller", "fusion-reactor-mk2" },
}
tech{
	name = "fusion-plasmas-mk2", prerequisites = { "fusion-reactor-mk2" }, packs = 8, count = 3000,
	recipes = {
		"molten-aluminium", "molten-copper-extraction", "molten-beryllium", "molten-titanium", "molten-silver",
		"molten-silicon", "molten-chrome",
		"molten-cobalt", "molten-lutetium", "rare-earth-1-lutetium-electrolysis", "molten-americium",
		"sulfur-plasma", "nitrogen-plasma", "zinc-plasma", "niobium-plasma", "tin-plasma", "molten-tritanium",
		"titanium-plasma", "oxygen-plasma", "krypton-plasma",
	},
}
do
	--- naquadria comes out of the ZPM blast furnace (zpm-multiblocks)
	local recipes = { "hot-naquadria-ingot", "naquadria-ingot", "molten-naquadria", "naquadria-plate", "naquadria-foil",
		"naquadah-plate", "naquadah-alloy-wire", "naquadah-alloy-cable", "molten-neutronium",
		"americium-ingot", "americium-plate", "fine-americium-wire", "gravi-star" }
	for _, r in pairs(neutronium_parts()) do recipes[#recipes + 1] = r end
	tech{
		name = "uv-materials", prerequisites = { "fusion-plasmas-mk2", "zpm-multiblocks" }, packs = 8, count = 3500,
		recipes = recipes,
	}
end
tech{
	name = "uv-components", prerequisites = { "uv-materials", "zpm-assembly-line" }, packs = 8, count = 4000,
	recipes = {
		"uv-motor", "uv-pump", "uv-conveyor-module", "uv-piston", "uv-robot-arm", "uv-emitter", "uv-sensor",
		"uv-field-generator", "osmium-plate", "uv-machine-casing", "uv-machine-hull",
	},
}

--- The UV science tech (upstream, researched with ZPM science) unlocks the pack
fork_add_unlock("agricultural-science-pack", "uv-science-pack")
table.insert(data.raw.technology["agricultural-science-pack"].prerequisites, "uv-components")

--- UV science. Machines first: the UV voltage coil needs the UV assembler.
tech{
	name = "uv-machines", prerequisites = { "agricultural-science-pack" }, packs = 9, count = 1500,
	recipes = uv_machine_recipes,
}
tech{
	name = "uv-energy-hatches", prerequisites = { "uv-machines" }, packs = 9, count = 2000,
	recipes = {
		"hot-naquamiridium-ingot", "naquamiridium-ingot", "naquamiridium-dust", "naquamiridium-wire",
		"naquamiridium-superconductive-wire", "superconducting-coil-block-uv", "enriched-naquadah-foil",
		"trinium-wire", "trinium-coil-block", "ultimate-voltage-coil", "uv-energy-hatch",
	},
}
tech{
	name = "uv-multiblocks", prerequisites = { "uv-energy-hatches" }, packs = 9, count = 2000,
	recipes = uv_multiblock_recipes,
}

--- UHV science needs the finished UV tier
table.insert(data.raw.technology["electromagnetic-science-pack"].prerequisites, "uv-multiblocks")
