--------------------------------------------------------------------------------
--- FORK POWER MULTIBLOCKS (issue #97)
--- The steam, nuclear and storage multiblocks whose items upstream has without an entity:
---   * the large steam turbine (EV) and the high pressure steam turbine (IV): generators of 136 that
---     burn steam and superheated steam; the distilled water and the steam they give back go into
---     turbine output hatches next to them (scripts/fork-power.lua)
---   * the fluid nuclear reactor (IV): fuel rods heat coolant into hot coolant, no power of its own
---   * the large heat exchanger (IV): hot coolant and distilled water into coolant and steam or superheated
---     steam
---   * the lapotronic supercapacitor (IV, LuV and ZPM capacitor blocks): an accumulator per capacitor tier with
---     GT's passive loss (scripts/fork-power.lua)
---   * issues #254 to #256 (docs/MULTIBLOCK-AUDIT.md): the large titanium boiler (superheated steam from fuel), the large
---     combustion engine and the large gas turbine (the fuel cell lines above HV), section 6
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
--- 5) LAPOTRONIC SUPERCAPACITOR
--- GT (kekztech): a multiblock of capacitor blocks, its capacity their sum (IV 6e8, LuV 6e9, ZPM 6e10 EU per
--- block), charged by energy hatches and discharged by dynamo hatches (2 A each), losing 1 % of the capacity per
--- day. Here one 5x5 accumulator per capacitor tier with the upstream recipe's 27 blocks and one energy and dynamo
--- hatch; LuV and ZPM are upgrades of the tier below (the replaced blocks and hatches come back). A battery is
--- measured in how long it carries its hatches, and the hatches carry Gregtorio's tier amps (IV: 10.24 MW against
--- GT's 8192 EU/t), so a block holds GT's EU x (Gregtorio amp / GT amp of its tier): IV / 16, LuV / 32, ZPM / 64.
--- I/O: two amps of the hatch tier. The loss is taken by scripts/fork-power.lua every 10 ticks (mod data
--- `capacitors`: the loss in W). GT's UV block needs an energy cluster, which Gregtorio does not have; UHV and up
--- hold GT's Long.MAX.
---   def = { tier, capacitor item, capacity per block (J), amp of the tier (W) }
--------------------------------------------------------------------------------

local LSC = "lapotronic-supercapacitor"
local LSC_BLOCKS = 27
local LSC_TIERS = {
	{ "iv", "lapotronic-capacitor-iv", 6e8 / 16 * 1e3, 10.24e6 },
	{ "luv", "lapotronic-capacitor-luv", 6e9 / 32 * 1e3, 20.48e6 },
	{ "zpm", "lapotronic-capacitor-zpm", 6e10 / 64 * 1e3, 40.96e6 },
}
POWER.capacitors = POWER.capacitors or {}

--- GT's capacitor blocks of LuV and ZPM (kekztech Assembler.java): the orb cluster with 4 osmiridium frames and
--- 24 screws (Gregtorio has osmiridium plates and rods), the energy module with 4 naquadah alloy frames and 24 screws
for _, c in pairs({
	{ "luv", "iv-assembling-machine-recipes", 40 * IV_SPEED, {
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 1 },
		{ type = "item", name = "osmiridium-plate", amount = 4 },
		{ type = "item", name = "osmiridium-rod", amount = 4 },
	} },
	{ "zpm", "luv-assembling-machine-recipes", 80 * LUV_SPEED, {
		{ type = "item", name = "energy-module", amount = 1 },
		{ type = "item", name = "naquadah-alloy-frame", amount = 4 },
		{ type = "item", name = "naquadah-alloy-screw", amount = 24 },
	} },
}) do
	create_item{
		name = "lapotronic-capacitor-" .. c[1],
		icon = "__gregtorio-continued__/graphics/icons/fork/lapotronic-capacitor-" .. c[1] .. ".png",
		category = c[2],
		energy_required = c[3],
		subgroup = data.raw.item["lapotronic-capacitor-iv"].subgroup,
		ingredients = c[4],
	}
end

for i, t in ipairs(LSC_TIERS) do
	local tier = t[1]
	local name = i == 1 and LSC or tier .. "-" .. LSC
	local capacity = LSC_BLOCKS * t[3]
	if i == 1 then
		local item = data.raw.item[LSC]
		item.place_result = LSC
		item.subgroup = "subgroup-iv-age-multiblocks"
	else
		local below = LSC_TIERS[i - 1]
		local prev = i == 2 and LSC or below[1] .. "-" .. LSC
		create_item{
			name = name,
			icon = "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png",
			category = tier .. "-assembling-machine-recipes",
			energy_required = 60 * (tier == "luv" and LUV_SPEED or ZPM_SPEED),
			subgroup = "subgroup-iv-age-multiblocks",
			place_result = name,
			stack_size = 10,
			ingredients = {
				{ type = "item", name = prev, amount = 1 },
				{ type = "item", name = t[2], amount = LSC_BLOCKS },
				{ type = "item", name = tier .. "-energy-hatch", amount = 1 },
				{ type = "item", name = tier .. "-dynamo-hatch", amount = 1 },
			},
			results = {
				{ type = "item", name = name, amount = 1 },
				{ type = "item", name = below[2], amount = LSC_BLOCKS },
				{ type = "item", name = below[1] .. "-energy-hatch", amount = 1 },
				{ type = "item", name = below[1] .. "-dynamo-hatch", amount = 1 },
			},
			main_product = name,
		}
	end
	local item = data.raw.item[name]
	local flow = string.format("%.6gMW", 2 * t[4] / 1e6)
	data:extend({ {
		type = "accumulator",
		name = name,
		icon = item.icon,
		icon_size = item.icon_size or 32,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 1, result = name },
		max_health = 1000,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fast_replaceable_group = LSC,
		energy_source = {
			type = "electric",
			buffer_capacity = string.format("%.6gGJ", capacity / 1e9),
			usage_priority = "tertiary",
			input_flow_limit = flow,
			output_flow_limit = flow,
		},
		chargable_graphics = {
			picture = { layers = { { filename = SPRITE_PATH .. name .. ".png", width = 160, height = 160 } } },
		},
		circuit_wire_max_distance = 9,
		default_output_signal = { type = "virtual", name = "signal-A" },
		localised_description = { "entity-description." .. name },
	} })
	--- GT: 1 % of the capacity per day (capacity / (100 x 86400 x 20) EU/t)
	POWER.capacitors[name] = capacity / 100 / 86400
end



--------------------------------------------------------------------------------
--- 6) LARGE TITANIUM BOILER, LARGE COMBUSTION ENGINE, LARGE GAS TURBINE (issues #254 to #256)
--- GT's EV power multiblocks:
---   * large titanium boiler (MTELargeBoilerTitanium: 4800 EU/t of steam equivalent as superheated steam, a third
---     of it, 3200 L/t): water and chemical fuel to 640 superheated steam/s, on the scale of the steam turbines (GT's
---     1050 L/t of the HP turbine are 210/s, 5 L/t = 1/s), so it feeds three high pressure steam turbines as in GT.
---     One unit costs three steam equivalents of fuel: Gregtorio's boilers heat one steam for 30 kJ (165 C), this one
---     heats to 465 C (90 kJ) and burns 57.6 MW. It comes with High Pressure Steam Turbine, which had no fuel before
---     Fluid Nuclear Reactor.
---   * large combustion engine (MTELargeCombustionEngine: 2048 EU/t at 100 %): the combustion generator fuel cells at
---     100 %, up to four EV amps (20.48 MW, the cap of 136's generators); GT's oxygen boost and lubricant upkeep are
---     left out.
---   * large gas turbine (MTELargeTurbineGas, output by its rotor): the gas turbine fuel cells with a fixed large
---     magnalium rotor (125 %, as the large steam turbine), up to four EV amps.
--- The recipes are GT's controllers (MTERecipeLoader.java) with the casings and hatches of the structure, as the
--- upstream large boilers and turbines are made. GT's fluid pipes are Factorio pipes (Gregtorio has none of GT's) and
--- the engine's tungstensteel cable is the aluminium cable of Gregtorio's EV tier.
--------------------------------------------------------------------------------

local FORK_ICON = "__gregtorio-continued__/graphics/icons/fork/"
local EV4 = "20.48MW"   -- four EV amps (4 x EU32_EV)

create_item{
	name = "titanium-firebox-casing",
	icon = FORK_ICON .. "titanium-firebox-casing.png",
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 4 },
		{ type = "item", name = "titanium-rod", amount = 4 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	},
}
create_item{
	name = "large-titanium-boiler",
	icon = FORK_ICON .. "large-titanium-boiler.png",
	place_result = "large-titanium-boiler",
	subgroup = "subgroup-ev-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "titanium-firebox-casing", amount = 6 },   -- the controller's and five of the structure
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "item", name = "gold-cable", amount = 4 },
		{ type = "item", name = "stable-titanium-machine-casing", amount = 23 },
		{ type = "item", name = "titanium-pipe-casing", amount = 2 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
	},
}
do
	local picture = { structure = { layers = { {
		filename = SPRITE_PATH .. "large-titanium-boiler-idle.png", width = 96, height = 96, shift = { 0, 0 },
	} } } }
	data:extend({ {
		type = "boiler",
		name = "large-titanium-boiler",
		mode = "output-to-separate-pipe",   -- water in, superheated steam out (the default heats the water in place)
		icon = FORK_ICON .. "large-titanium-boiler.png",
		icon_size = 32,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 1, result = "large-titanium-boiler" },
		max_health = 600,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		resistances = { { type = "fire", percent = 90 } },
		collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } },
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } },
		fluid_box = {
			volume = 1000,
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures(),
			pipe_connections = {
				{ flow_direction = "input-output", direction = W, position = { -1, 0 } },
				{ flow_direction = "input-output", direction = E, position = { 1, 0 } },
			},
			production_type = "input",
			filter = "water",
		},
		output_fluid_box = {
			volume = 1000,
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures(),
			pipe_connections = { { flow_direction = "output", direction = N, position = { 0, -1 } } },
			production_type = "output",
			filter = "superheated-steam",
		},
		energy_source = {
			type = "burner",
			fuel_categories = { "chemical" },
			effectivity = 1,
			fuel_inventory_size = 2,
			emissions_per_minute = { pollution = 30 },
		},
		energy_consumption = "57.6MW",
		target_temperature = 465,
		burning_cooldown = 20,
		pictures = { north = picture, east = picture, south = picture, west = picture },
		localised_description = { "entity-description.large-titanium-boiler" },
	} })
end

create_item{
	name = "engine-intake-casing",
	icon = FORK_ICON .. "engine-intake-casing.png",
	ingredients = {
		{ type = "item", name = "titanium-rotor", amount = 4 },
		{ type = "item", name = "pipe", amount = 2 },
		{ type = "item", name = "stable-titanium-machine-casing", amount = 1 },
	},
	results = { { type = "item", name = "engine-intake-casing", amount = 4 } },
}
create_item{
	name = "large-combustion-engine",
	icon = FORK_ICON .. "large-combustion-engine.png",
	place_result = "large-combustion-engine",
	subgroup = "subgroup-ev-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "ev-piston", amount = 2 },
		{ type = "item", name = "ev-motor", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 1 },
		{ type = "item", name = "aluminium-cable", amount = 1 },
		{ type = "item", name = "large-titanium-gear", amount = 2 },
		{ type = "item", name = "ev-dynamo-hatch", amount = 1 },
		{ type = "item", name = "stable-titanium-machine-casing", amount = 16 },
		{ type = "item", name = "titanium-gear-box-casing", amount = 2 },
		{ type = "item", name = "engine-intake-casing", amount = 8 },
		{ type = "item", name = "lv-machine-hull", amount = 3 },
	},
}
create_burner_generator{
	name = "large-combustion-engine",
	icon = FORK_ICON .. "large-combustion-engine.png",
	efficiency = 1,
	fuel_categories = { "combustion-generator-fuel" },
	max_power = EV4,
	working_animation = SPRITE_PATH .. "large-combustion-engine-working.png",
	idle_animation = SPRITE_PATH .. "large-combustion-engine-idle.png",
	frame_count = 1,
}

create_item{
	name = "stainless-steel-turbine-casing",
	icon = FORK_ICON .. "stainless-steel-turbine-casing.png",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 6 },
		{ type = "item", name = "steel-turbine-casing", amount = 1 },
	},
}
create_item{
	name = "large-gas-turbine",
	icon = FORK_ICON .. "large-gas-turbine.png",
	place_result = "large-gas-turbine",
	subgroup = "subgroup-ev-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "large-stainless-steel-gear", amount = 4 },
		{ type = "item", name = "pipe", amount = 2 },
		{ type = "item", name = "ev-dynamo-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
		{ type = "item", name = "stainless-steel-turbine-casing", amount = 28 },
		{ type = "item", name = "magnalium-turbine-rotor", amount = 1 },
	},
}
create_burner_generator{
	name = "large-gas-turbine",
	icon = FORK_ICON .. "large-gas-turbine.png",
	efficiency = 1.25,
	fuel_categories = { "gas-turbine-fuel" },
	max_power = EV4,
	working_animation = SPRITE_PATH .. "large-gas-turbine-working.png",
	idle_animation = SPRITE_PATH .. "large-gas-turbine-idle.png",
	frame_count = 1,
}



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
--- issues #255 and #256: the fuel cell lines above HV
F.tech{
	name = "large-combustion-engine", prerequisites = { "ev-energy-hatches", "titanium" }, packs = 5, count = 600,
	time = 45, recipes = {},
}
F.tech{
	name = "large-gas-turbine", prerequisites = { "large-steam-turbine" }, packs = 5, count = 600, time = 45,
	recipes = {},
}
--- GT's reactor is IC2's (EV/IV); its iridium neutron reflectors are IV parts (on fusion-reactor-mk1 so far only
--- because the auto-unlock put them there). The heat exchanger comes with it: without lava it needs hot coolant.
F.tech{
	name = "fluid-nuclear-reactor", prerequisites = { "nuclear-fuel-rods", "high-pressure-steam-turbine", "iv-components" },
	packs = 6, count = 800, recipes = {},
}
--- The IV supercapacitor stays on lapotronic-energy-orbs (ZPM science, where the orbs are); the upgrades follow the
--- hatches of their tier (the LuV dynamo hatch comes with the plasma turbine, the ZPM one with the ZPM plasma
--- turbine); the ZPM one also unlocks the energy module (a ZPM assembly line recipe that only the MK5 fusion coil used,
--- so far on fusion-coil-ii)
F.tech{
	name = "luv-lapotronic-supercapacitor",
	prerequisites = { "lapotronic-energy-orbs", "plasma-turbine", "luv-energy-hatches", "naquadah-alloy", "zpm-materials" },
	packs = 8, count = 2000, recipes = {},
}
F.tech{
	name = "zpm-lapotronic-supercapacitor",
	prerequisites = { "luv-lapotronic-supercapacitor", "zpm-plasma-turbine", "zpm-energy-hatches",
		"crystal-processor-mainframes" },
	packs = 8, count = 2000, recipes = {},
}



--------------------------------------------------------------------------------
--- 7) ROCKET ENGINES (issue #295, the maintainer's decision: rocket fuel as in GTNH). Gregtorio's rocket fuel
--- (dimethylhydrazine and dinitrogen tetroxide) is GT++'s H8N4C2O4 Rocket Fuel; GTNH burns it in GT++'s rocket
--- engines (gtPlusPlus/xmod/gregtech/registration/gregtech/GregtechRocketFuelGenerator.java, GT5-Unofficial
--- af993ca6a9): the Basic, Advanced and Turbo Rocket Engine (EV, IV, LuV; here by their tier, issue #156), single
--- blocks of GT's rocketFuels map (RecipeLoaderRocketFuels.java:179-184: 4196 EU per L) at 80, 70 and 60 %
--- (MTERocketFuelGenerator.java:27-29: 80 - 10 x (tier - 4)), one amp of their tier (MTEBasicGenerator.maxEUOutput).
--- Like the combustion lines a burner generator on a fuel cell of 800 L (Gregtorio's diesel cell: 500 J per GT EU):
--- 4196 x 800 x 500 J = 1678.4 MJ, in a fuel category of its own (GT's rocketFuels map: only rocket engines burn it).
--- Their recipes are GT++'s ("PCP", "EME", "GWG": 2 pistons, a circuit of the next tier, 2 motors, the hull, 2 gears, a
--- double cable): Tantalloy-61, which the mod lacks, becomes Tantalloy-60; a double cable 2 cables. The fuel's recipe
--- is GTNH's in the ExxonMobil Chemical Plant (159). GT++'s Large Rocket Engine: below (issue #304).
--------------------------------------------------------------------------------

data:extend({ { type = "fuel-category", name = "rocket-engine-fuel" } })
create_item{
	name = "rocket-fuel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "rocket-engine-fuel",
	fuel_value = "1678.4MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	subgroup = data.raw.item["diesel-cell"] and data.raw.item["diesel-cell"].subgroup or nil,
	ingredients = {
		{ type = "item", name = "empty-large-steel-fluid-cell", amount = 1 },
		{ type = "fluid", name = "rocket-fuel", amount = 800 },
	},
}
local ROCKET_ENGINES = {
	--  tier   efficiency  power      next circuit   cable             gear (GT++)                    technology
	{ "ev",  0.8, EU32_EV,  "iv-circuit",  "aluminium-cable", "large-tantalloy-60-gear", "rocket-engines" },
	{ "iv",  0.7, EU32_IV,  "luv-circuit", "platinum-cable",  "large-stellite-gear",     "advanced-rocket-engine" },
	{ "luv", 0.6, EU32_LuV, "zpm-circuit", "tungsten-cable",  "large-zeron-100-gear",    "turbo-rocket-engine" },
}
for _, e in pairs(ROCKET_ENGINES) do
	local name = e[1] .. "-rocket-engine"
	create_item{
		name = name,
		icon = FORK_ICON .. name .. ".png",
		place_result = name,
		subgroup = "subgroup-" .. e[1] .. "-age-multiblocks",
		stack_size = 10,
		ingredients = {
			{ type = "item", name = e[1] .. "-machine-hull", amount = 1 },
			{ type = "item", name = e[1] .. "-piston", amount = 2 },
			{ type = "item", name = e[1] .. "-motor", amount = 2 },
			{ type = "item", name = e[4], amount = 1 },
			{ type = "item", name = e[5], amount = 2 },
			{ type = "item", name = e[6], amount = 2 },
		},
	}
	create_burner_generator{
		name = name,
		icon = FORK_ICON .. name .. ".png",
		efficiency = e[2],
		fuel_categories = { "rocket-engine-fuel" },
		max_power = e[3],
		working_animation = SPRITE_PATH .. name .. "-working.png",
		idle_animation = SPRITE_PATH .. name .. "-idle.png",
		frame_count = 1,
	}
end
F.tech{
	name = "rocket-engines", prerequisites = { "rocket-fuel", "ev-components", "alloy-blast-smelter" }, packs = 5,
	count = 600, time = 45, recipes = { "ev-rocket-engine", "rocket-fuel-cell" },
}
F.tech{
	name = "advanced-rocket-engine", prerequisites = { "rocket-engines", "iv-components", "industrial-electrolyzer" },
	packs = 6, count = 800, recipes = { "iv-rocket-engine" },
}
F.tech{
	name = "turbo-rocket-engine", prerequisites = { "advanced-rocket-engine", "luv-components", "luv-machines", "advanced-smds" },
	packs = 7, count = 1000, recipes = { "luv-rocket-engine" },
}
--- issue #304 (the maintainer's decision: build it, simplified): GT++'s Large Rocket Engine, the "Rocketdyne F-1A Engine"
--- (gtPlusPlus/xmod/gregtech/common/tileentities/machines/multi/production/MTELargeRocketEngine.java). GT++ burns 90 %
--- of the rocket fuel in its hatch each second (consumeFuel, :360-375) for an energy of 3 x the fuel's value (setEUProduction,
--- :377-395; the cube roots above 30 000 EU/t are not reached at its output), and gives a fixed 2 amps of IV once its
--- efficiency is up (:330-345): fed just what it burns, 3 x the fuel's value goes into a fixed 2 A of IV. Here a burner
--- generator on rocket fuel cells with that: efficiency 3, 2 amps of IV. Left out, as the large combustion engine of #255
--- leaves its extras out: the 8 air intake hatches and the air they take, the carbon dioxide (consumeCO2, :399), the
--- lubricant (:126) and the liquid hydrogen boost (consumeLOH, :403-407; Gregtorio has no liquid hydrogen).
--- Its item is the controller and the structure's minimum (checkCasingMin 16 Turbodyne Casings, the 8 gear boxes of its
--- shape), 2 IV dynamo hatches for its 2 amps and 3 hulls for the input, maintenance and muffler hatches (as #255).
--- Recipes: GT++'s (GregtechRocketFuelGenerator.java:34-46): the controller from a large combustion engine, 2 IV pistons,
--- 2 EV field generators, a LuV circuit, 2 8x platinum cables (16 cables) and 2 Maraging Steel 350 gears; the Turbodyne
--- Casing from 4 Nitinol 60 gears, 2 medium tungstensteel pipes, a robust tungstensteel casing and a long tungstensteel
--- rod. The mod lacks Maraging Steel 350 (Maraging Steel 300, the closest), gears of both alloys and the pipe: a gear is 4
--- plates and a medium pipe 3 plates (GT's recipes). The gear box (GT++'s Inconel Reinforced Casing) is the mod's.
create_item{
	name = "turbodyne-casing",
	icon = FORK_ICON .. "turbodyne-casing.png",
	category = "crafting-or-assembling-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "nitinol-60-plate", amount = 16 },
		{ type = "item", name = "tungstensteel-plate", amount = 6 },
		{ type = "item", name = "robust-tungstensteel-machine-casing", amount = 1 },
		{ type = "item", name = "long-tungstensteel-rod", amount = 1 },
	},
}
create_item{
	name = "large-rocket-engine",
	icon = FORK_ICON .. "large-rocket-engine.png",
	place_result = "large-rocket-engine",
	subgroup = "subgroup-iv-age-multiblocks",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-combustion-engine", amount = 1 },
		{ type = "item", name = "iv-piston", amount = 2 },
		{ type = "item", name = "ev-field-generator", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 1 },
		{ type = "item", name = "platinum-cable", amount = 16 },
		{ type = "item", name = "maraging-steel-300-plate", amount = 8 },
		{ type = "item", name = "turbodyne-casing", amount = 16 },
		{ type = "item", name = "inconel-reinforced-casing", amount = 8 },
		{ type = "item", name = "iv-dynamo-hatch", amount = 2 },
		{ type = "item", name = "lv-machine-hull", amount = 3 },
	},
}
create_burner_generator{
	name = "large-rocket-engine",
	icon = FORK_ICON .. "large-rocket-engine.png",
	efficiency = 3,
	fuel_categories = { "rocket-engine-fuel" },
	max_power = "20.48MW",   -- (2 x EU32_IV: 2 amps of IV)
	working_animation = SPRITE_PATH .. "large-rocket-engine-working.png",
	idle_animation = SPRITE_PATH .. "large-rocket-engine-idle.png",
	frame_count = 1,
}
data.raw["burner-generator"]["large-rocket-engine"].localised_description = { "entity-description.large-rocket-engine" }
F.tech{
	name = "large-rocket-engine", prerequisites = { "advanced-rocket-engine", "large-combustion-engine", "luv-components",
		"industrial-extrusion-machine", "industrial-cutting-factory", "hyper-intensity-laser-engraver", "space-science-pack" },   -- (#252: its casings' parts)
	packs = 7, count = 1000, recipes = { "large-rocket-engine", "turbodyne-casing" },
}



--------------------------------------------------------------------------------
--- 8) BATTERIES AND BATTERY BUFFERS, LV TO HV (issue #444; the maintainer's decision of 2026-10-20: fixed sizes)
--- GT New Horizons' energy storage before the IV supercapacitor: the battery buffers (MTEBasicBatteryBuffer, 1, 4, 9
--- and 16 battery slots; out 1 amp, in 2 amps per battery) with the LV to HV batteries. Here a buffer is an accumulator
--- of a fixed size: the batteries are part of its recipe (the tier's lithium battery, GT's largest of the tier), its
--- capacity is theirs (MetaGeneratedItem01.java:5212-5224: lithium 100 000, 400 000 and 1 600 000 EU; 1 EU = 1/3 kJ
--- here: 32 EU/t are 640 kW), its flow 1 amp out and 2 in per battery at the tier's voltage. No passive loss (GT's
--- buffer keeps its charge).
--- The batteries with GT's names and recipes: the hulls (AssemblerRecipes.java:2938-2966: LV a tin cable, a battery
--- alloy plate and 144 L polyethylene, 4 s; MV 2 copper cables, 3 plates, 432 L, 16 s; HV 4 gold cables, 9 plates,
--- 1296 L, 64 s; 20 EU/t), filled in the canner with 2, 8 or 32 lithium, cadmium or sodium dust (CannerRecipes.java:
--- 21-112: 5, 20, 80 s, 2 EU/t). Gregtorio's battery hull is GT's MV one (Medium Battery Hull, its recipe now with GT's
--- 3 plates); its mixed `battery` stays as it was. The buffers' recipe (MTERecipeLoader: "WTW", "WMW": 4 wires of the
--- tier's material, x1, x4, x8, x16 for the sizes, a chest and the hull) with the batteries: tin, copper and gold wires
--- (16x wires for x16), the wooden chest.
--- Technologies: the LV and MV ones with Battery (the battery alloy plates; polyethylene comes before it), the HV ones
--- with the new Large Batteries after Battery and HV Components (gold cables, the HV hull).
--------------------------------------------------------------------------------
do
	local EU = 1e3 / 3   -- J per EU
	local BATTERY_TIERS = {
		--   tier  size      hull                   dust  seconds cable           plates poly   hull s  capacity (EU) volts wire
		{ "lv", "small", "small-battery-hull", 2, 5, "tin-cable", 1, 14.4, 4, 100000, 32, "tin-wire" },
		{ "mv", "medium", "battery-hull", 8, 20, "copper-cable", 3, 43.2, 16, 400000, 128, "copper-wire" },
		{ "hv", "large", "large-battery-hull", 32, 80, "gold-cable", 9, 129.6, 64, 1600000, 512, "gold-wire" },
	}
	local TECH_OF = { lv = "battery", mv = "battery", hv = "large-batteries" }
	local hv_recipes = {}
	local function unlock(tier, name)
		if TECH_OF[tier] == "large-batteries" then hv_recipes[#hv_recipes + 1] = name else fork_add_unlock(TECH_OF[tier], name) end
	end
	local sub = data.raw.item["battery-hull"].subgroup
	for i, b in ipairs(BATTERY_TIERS) do
		local tier, size, hull = b[1], b[2], b[3]
		local hull_ingredients = {
			{ type = "item", name = b[6], amount = ({ 1, 2, 4 })[i] },
			{ type = "item", name = "battery-alloy-plate", amount = b[7] },
			{ type = "fluid", name = "polyethylene", amount = b[8] },
		}
		if hull == "battery-hull" then
			data.raw.recipe[hull].ingredients = hull_ingredients   -- (GT's 3 plates instead of upstream's 5)
		else
			create_item{
				name = hull,
				subgroup = sub,
				category = "lv-assembling-machine-recipes",
				energy_required = b[9] * LV_SPEED,
				ingredients = hull_ingredients,
			}
			unlock(tier, hull)
		end
		for j, dust in ipairs({ "cadmium", "lithium", "sodium" }) do
			local name = size .. "-" .. dust .. "-battery"
			create_item{
				name = name,
				subgroup = sub,
				order = "b[" .. i .. "]-" .. j,
				category = "lv-canning-machine-recipes",
				energy_required = b[5] * LV_SPEED,
				ingredients = { { type = "item", name = hull, amount = 1 }, { type = "item", name = dust, amount = b[4] } },
			}
			unlock(tier, name)
		end
		--- the buffers: 1, 4, 9, 16 lithium batteries
		for _, n in ipairs({ 1, 2, 3, 4 }) do
			local slots = n * n
			local name = tier .. "-battery-buffer-" .. slots
			local wire = n == 4 and { b[12] .. "-16x", 4 } or { b[12], 4 * ({ 1, 4, 8 })[n] }
			create_item{
				name = name,
				subgroup = "energy",
				order = "e[battery-buffer]-" .. i .. "-" .. n,
				place_result = name,
				stack_size = 10,
				ingredients = {
					{ type = "item", name = wire[1], amount = wire[2] },
					{ type = "item", name = "wooden-chest", amount = 1 },
					{ type = "item", name = tier .. "-machine-hull", amount = 1 },
					{ type = "item", name = size .. "-lithium-battery", amount = slots },
				},
			}
			local amp = b[11] * 60 * EU   -- one amp of the tier in W
			data:extend({ {
				type = "accumulator",
				name = name,
				icon = "__gregtorio-continued__/graphics/icons/" .. name .. ".png",
				icon_size = 32,
				flags = { "placeable-neutral", "player-creation" },
				minable = { mining_time = 0.5, result = name },
				max_health = 200,
				corpse = "small-remnants",
				collision_box = { { -0.8, -0.8 }, { 0.8, 0.8 } },
				selection_box = { { -1, -1 }, { 1, 1 } },
				fast_replaceable_group = "fr-battery-buffer",
				energy_source = {
					type = "electric",
					buffer_capacity = string.format("%.6fMJ", slots * b[10] * EU / 1e6),
					usage_priority = "tertiary",
					input_flow_limit = string.format("%.6gkW", 2 * slots * amp / 1e3),
					output_flow_limit = string.format("%.6gkW", slots * amp / 1e3),
				},
				chargable_graphics = {
					picture = { layers = { { filename = SPRITE_PATH .. name .. ".png", width = 64, height = 64 } } },
				},
				circuit_wire_max_distance = 9,
				default_output_signal = { type = "virtual", name = "signal-A" },
			} })
			unlock(tier, name)
		end
	end
	F.tech{
		name = "large-batteries", prerequisites = { "battery", "hv-components" }, packs = 4, count = 400,
		recipes = hv_recipes,
	}
end
