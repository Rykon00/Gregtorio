--------------------------------------------------------------------------------
--- FORK POWER MULTIBLOCKS (issue #97)
--- The steam, nuclear and storage multiblocks whose items upstream has without an entity:
---   * the large steam turbine (EV) and the high pressure steam turbine (IV): generators of 136 that
---     burn steam and superheated steam; the distilled water and the steam they give back go into
---     turbine output hatches next to them (scripts/fork-power.lua)
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
