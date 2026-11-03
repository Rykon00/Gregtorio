--------------------------------------------------------------------------------
--- FORK SOLAR BOILERS (issue #446): GT New Horizons' Simple and Advanced Solar Boiler make steam while the sun shines
--- (MTEBoilerSolar: daytime and the sky). Their entities (prototypes/101-fork-machines.lua, section 2m; the mod data
--- `fork-solar-boilers` names them) run one recipe without power; every CHECK_TICKS this script stops them at night
--- (disabled_by_script, status "No sunlight") and lets them run by day: the light of their surface, 1 - darkness, at
--- least DAYLIGHT. State: storage.fork_solar_boilers.boilers (unit number -> entity), filled when one is built and after a
--- mod change; an entity that is gone drops out on its next check.
--------------------------------------------------------------------------------

local M = {}
local batch = require("scripts.fork-batch")
local CHECK_TICKS = 120
--- issue #642: the boilers are checked in shares every STEP_TICKS, each one once per CHECK_TICKS (scripts/fork-batch.lua;
--- the boilers live in storage.fork_solar_boilers.boilers since then)
local STEP_TICKS = 24
local DAYLIGHT = 0.5

local names
local function boiler_names()
	if not names then
		local d = prototypes.mod_data["fork-solar-boilers"]
		names = {}
		for _, n in pairs(d and d.data.names or {}) do
			if prototypes.entity[n] then names[n] = true end
		end
	end
	return names
end

local function state()
	local st = storage.fork_solar_boilers
	if not (st and st.boilers) then
		--- (a save from before #642 kept unit number -> entity right in storage.fork_solar_boilers)
		st = { boilers = st or {} }
		storage.fork_solar_boilers = st
	end
	return st
end

local function update(entity)
	local day = 1 - entity.surface.darkness >= DAYLIGHT
	entity.disabled_by_script = not day
	entity.custom_status = not day and { diode = defines.entity_status_diode.yellow,
		label = { "entity-status.fork-no-sunlight" } } or nil
end

--- issue #613: the steam water pumps (prototypes/101-fork-machines.lua, section 2m') pump water by the surface's
--- moisture at their spot, read once when built: the recipe of the nearest quarter (at least 25 %), locked
local pumps
local function water_pumps()
	if not pumps then
		local d = prototypes.mod_data["fork-steam-water-pumps"]
		pumps = { names = {}, recipes = d and d.data.recipes or {} }
		for _, n in pairs(d and d.data.names or {}) do pumps.names[n] = true end
	end
	return pumps
end
local function set_water_recipe(entity)
	local moisture = 0
	local ok, props = pcall(entity.surface.calculate_tile_properties, { "moisture" }, { entity.position })
	if ok and props and props.moisture then moisture = props.moisture[1] or 0 end
	local q = math.max(25, math.min(100, math.floor(moisture * 4 + 0.5) * 25))
	--- (the mod data's number keys arrive as strings at runtime: "25", ...)
	entity.set_recipe(water_pumps().recipes[tostring(q)] or water_pumps().recipes[q])
	entity.recipe_locked = true
end

function M.on_built(entity)
	if not (entity and entity.valid) then return end
	if boiler_names()[entity.name] then
		state().boilers[entity.unit_number] = entity
		update(entity)
	elseif water_pumps().names[entity.name] and not entity.get_recipe() then
		set_water_recipe(entity)
	end
end

function M.on_configuration_changed()
	local list = {}
	for n in pairs(boiler_names()) do list[#list + 1] = n end
	storage.fork_solar_boilers = { boilers = {} }
	if #list == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
	end
end

script.on_nth_tick(STEP_TICKS, function()
	if not storage.fork_solar_boilers then return end
	local st = state()
	batch.visit(st, "boilers", CHECK_TICKS, STEP_TICKS, function(k, e)
		if e.valid then update(e) else st.boilers[k] = nil end
	end)
end)

return M
