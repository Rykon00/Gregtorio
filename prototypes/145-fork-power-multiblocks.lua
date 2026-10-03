--------------------------------------------------------------------------------
--- FORK POWER MULTIBLOCKS (issue #97)
--- The steam, nuclear and storage multiblocks whose items upstream has without an entity:
---   * the large steam turbine (EV) and the high pressure steam turbine (IV): generators of 136 that
---     burn steam and superheated steam; the distilled water and the steam they give back go into
---     turbine output hatches next to them (scripts/fork-power.lua)
---   * the fluid nuclear reactor (IV): fuel rods heat coolant into hot coolant, no power of its own
---   * the large heat exchanger (IV): hot coolant and distilled water into coolant and steam or superheated
---     steam
--- Units and the GT numbers: docs/ROADMAP.md, "Steam, nuclear and storage multiblocks (issue #97)".
--- Steam is on the scale of the LV steam turbine (one unit = 100 L of GT steam, 100 kJ); GT's 2 L steam
--- = 1 EU is the effectivity 0.5 x rotor efficiency, superheated steam (GT: 1 L = 1 EU) has twice the
--- fuel value. Loads after 136 (generator, mod data) and 138, before 142 (the unlock table names the
--- technologies made here) and 196 (the Fluids tab sorts the new fluids).
--------------------------------------------------------------------------------

local F = FORK5B
local P = FORK_POWER
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"
local POWER = data.raw["mod-data"]["fork-power"].data



--------------------------------------------------------------------------------
--- 1) FLUIDS
--------------------------------------------------------------------------------

--- GT's IC2 superheated steam: twice the fuel value of steam (1 EU per L instead of 0.5), on steam's
--- scale and temperature (its row in the Fluids tab: 196, next to steam)
do
	local steam = data.raw.fluid["steam"]
	local sh = table.deepcopy(steam)
	sh.name = "superheated-steam"
	sh.icon = FLUID_ICON_PATH .. "nearly-white-fluid.png"
	sh.icon_size = 32
	sh.icons = nil
	sh.fuel_value = "200kJ"
	sh.base_color = { r = 0.95, g = 0.85, b = 0.80 }
	sh.flow_color = { r = 1.00, g = 0.90, b = 0.85 }
	sh.auto_barrel = false
	data:extend({ sh })
end



--------------------------------------------------------------------------------
--- 2) STEAM TURBINES
--- GT: the large turbines with the rotor in the controller; here the rotor of the recipe (or, for the
--- high pressure turbine, whose upstream recipe has none, the titanium one of its casings) is fixed:
---   large magnalium rotor: efficiency 125 %, optimal flow 900 L/t steam -> 562.5 EU/t = 11.25 MW
---   large titanium rotor:  efficiency 135 %, optimal flow 1050 L/t superheated -> 1417.5 EU/t = 28.35 MW
--- (GT5-Unofficial TurbineStatCalculator.java). At 100 L per unit: 180 steam/s and 210 superheated
--- steam/s. The large steam turbine returns 1 L distilled water per 160 L steam (GT's STEAM_PER_WATER;
--- 0.0625 units per unit of steam), the high pressure one 1 L steam per L superheated steam.
---   def = { name, power, fuel, fuel value (J), efficiency, back, ratio, tier of the dynamo hatch }
--------------------------------------------------------------------------------

local TURBINES = {
	{ "large-steam-turbine",         "11.25MW", "steam",             100e3, 1.25, "distilled-water", 0.0625, "ev" },
	{ "high-pressure-steam-turbine", "28.35MW", "superheated-steam", 200e3, 1.35, "steam",           1,      "iv" },
}

for _, t in pairs(TURBINES) do
	local name = t[1]
	local item = data.raw.item[name]
	item.place_result = name
	item.subgroup = "subgroup-" .. t[8] .. "-age-multiblocks"
	item.stack_size = 10
	P.make_generator{
		name = name, size = 3, power = t[2], volume = 1000, min_fuel = t[4], effectivity = 0.5 * t[5],
		icon = item.icon, fast_replaceable_group = name,
	}
	data.raw.generator[name].icon_size = item.icon_size or 32
	table.insert(POWER.turbines, name)
	POWER.fuels[name] = { t[3] }
	POWER.cooled[t[3]] = t[6]
	POWER.ratio[t[3]] = t[7]
	POWER.effectivity[name] = 0.5 * t[5]
end



--------------------------------------------------------------------------------
--- 3) COOLANT (GT: IC2 coolant and hot coolant)
--- GT's mixer: 1 lapis dust + 1000 L distilled water -> 1000 L coolant, 12.8 s (MixerRecipes.java); at
--- Gregtorio's tenth: 100 distilled water. One unit of hot coolant is 10 L: 2 MJ (GT: 1 L -> 400 L steam = 200 EU).
--------------------------------------------------------------------------------

F.fluid("coolant", "spackled-light-blue-fluid", { 0.25, 0.60, 0.85 })
F.fluid("hot-coolant", "medium-red-fluid", { 0.85, 0.30, 0.20 })
create_recipe{
	name = "coolant",
	category = "lv-mixer-recipes",
	energy_required = 12.8,
	ingredients = {
		{ type = "item", name = "lapis-dust", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 100 },
	},
	results = { { type = "fluid", name = "coolant", amount = 100 } },
}



--------------------------------------------------------------------------------
--- 4) FLUID NUCLEAR REACTOR AND LARGE HEAT EXCHANGER
--- Recipe machines (3x3). The reactor burns the fuel rods of 17-ev-age-item.lua in a burner slot (depleted rods
--- in the burnt result slot) at the 10.5 MW of the basic nuclear reactor it is built from: the heat of IC2's reactor
--- in fluid mode, whose heat -> hot coolant ratio is not in GT's sources; 21 coolant -> 21 hot coolant in 4 s =
--- 5.25 hot coolant/s at 2 MJ each. The heat exchanger needs no power (as in GT): up to 160 hot coolant/s (GT's
--- 1600 L/s), 1 hot coolant -> 40 steam or 20 superheated steam (GT: 400 L / 200 L), 1 distilled water per 16
--- steam (GT: 1 L per 160 L). GT gives superheated steam only above a flow threshold, which a recipe cannot ask
--- for: the player picks the recipe. No lava recipe: Gregtorio's lava is endless (docs/ROADMAP.md).
--- Fluid boxes: reactor coolant in south, hot coolant out north; exchanger hot coolant in west, distilled water in
--- south, coolant out east, steam out north.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local function sprites(name)
	local function layer(file)
		return { layers = { { filename = SPRITE_PATH .. name .. file, width = 96, height = 96, frame_count = 1,
			shift = { 0, 0 } } } }
	end
	return { idle_animation = layer("-idle.png"), animation = layer("-working.png") }
end
local function port(kind, direction, position, volume)
	return {
		production_type = kind, volume = volume or 1000, pipe_covers = pipecoverspictures(),
		pipe_connections = { { flow_direction = kind, direction = direction, position = position } },
	}
end
local N, E, S, W = defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west

local function machine(def)
	local item = data.raw.item[def.name]
	item.place_result = def.name
	item.subgroup = "subgroup-iv-age-multiblocks"
	item.stack_size = 10
	F.category(def.category)
	data:extend({ {
		type = "assembling-machine",
		name = def.name,
		icon = item.icon,
		icon_size = item.icon_size or 32,
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 1, result = def.name },
		max_health = 600,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		crafting_categories = { def.category },
		crafting_speed = 1,
		energy_source = def.energy_source,
		energy_usage = def.energy_usage,
		fluid_boxes = def.fluid_boxes,
		graphics_set = sprites(def.name),
		localised_description = { "entity-description." .. def.name },
	} })
end

machine{
	name = "fluid-nuclear-reactor",
	category = "fluid-nuclear-reactor-recipes",
	energy_usage = "10.5MW",
	energy_source = {
		type = "burner", fuel_categories = { "nuclear-fuel-rod" }, effectivity = 1,
		fuel_inventory_size = 1, burnt_inventory_size = 1,
	},
	fluid_boxes = { port("input", S, { 0, 1 }), port("output", N, { 0, -1 }) },
}
create_recipe{
	name = "hot-coolant",
	category = "fluid-nuclear-reactor-recipes",
	energy_required = 4,
	ingredients = { { type = "fluid", name = "coolant", amount = 21 } },
	results = { { type = "fluid", name = "hot-coolant", amount = 21 } },
}

machine{
	name = "large-heat-exchanger",
	category = "large-heat-exchanger-recipes",
	energy_usage = "1kW",
	energy_source = { type = "void" },
	fluid_boxes = {
		port("input", W, { -1, 0 }), port("input", S, { 0, 1 }),
		--- the outputs take the recipe's results in this order: steam north, coolant east
		port("output", N, { 0, -1 }, 2000), port("output", E, { 1, 0 }),
	},
}
for _, r in pairs({ { "steam", 40, 640 }, { "superheated-steam", 20, 320 } }) do
	create_recipe{
		name = "large-heat-exchanger-" .. r[1],
		category = "large-heat-exchanger-recipes",
		energy_required = 0.1,
		ingredients = {
			{ type = "fluid", name = "hot-coolant", amount = 16 },
			{ type = "fluid", name = "distilled-water", amount = r[2] },
		},
		results = {
			{ type = "fluid", name = r[1], amount = r[3], temperature = r[1] == "steam" and 165 or nil },
			{ type = "fluid", name = "coolant", amount = 16 },
		},
		main_product = r[1],
	}
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES (the recipes are in the unlock table of 142)
--------------------------------------------------------------------------------

F.tech{
	name = "large-steam-turbine", prerequisites = { "ev-energy-hatches", "titanium" }, packs = 5, count = 600,
	time = 45, recipes = {},
}
F.tech{
	name = "high-pressure-steam-turbine", prerequisites = { "large-steam-turbine", "iv-energy-hatches" }, packs = 6,
	count = 800, recipes = {},
}
--- GT's reactor is IC2's (EV/IV); its iridium neutron reflectors are IV parts (on fusion-reactor-mk1 so far only
--- because the auto-unlock put them there). The heat exchanger comes with it: without lava it needs hot coolant.
F.tech{
	name = "fluid-nuclear-reactor", prerequisites = { "nuclear-fuel-rods", "high-pressure-steam-turbine", "iv-components" },
	packs = 6, count = 800, recipes = {},
}
