--------------------------------------------------------------------------------
--- FORK SOLAR BOILERS (issue #446): GT New Horizons' Simple and Advanced Solar Boiler make steam while the sun shines
--- (MTEBoilerSolar: daytime and the sky). Their entities (prototypes/101-fork-machines.lua, section 2m; the mod data
--- `fork-solar-boilers` names them) run one recipe without power; every CHECK_TICKS this script stops them at night
--- (disabled_by_script, status "No sunlight") and lets them run by day: the light of their surface, 1 - darkness, at
--- least DAYLIGHT. State: storage.fork_solar_boilers (unit number -> entity), filled when one is built and after a mod
--- change; an entity that is gone drops out on the next check.
--------------------------------------------------------------------------------

local M = {}
local CHECK_TICKS = 120   -- (free: the molds take 30, fork-power on_tick)
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
	storage.fork_solar_boilers = storage.fork_solar_boilers or {}
	return storage.fork_solar_boilers
end

local function update(entity)
	local day = 1 - entity.surface.darkness >= DAYLIGHT
	entity.disabled_by_script = not day
	entity.custom_status = not day and { diode = defines.entity_status_diode.yellow,
		label = { "entity-status.fork-no-sunlight" } } or nil
end

function M.on_built(entity)
	if entity and entity.valid and boiler_names()[entity.name] then
		state()[entity.unit_number] = entity
		update(entity)
	end
end

function M.on_configuration_changed()
	local list = {}
	for n in pairs(boiler_names()) do list[#list + 1] = n end
	storage.fork_solar_boilers = {}
	if #list == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
	end
end

script.on_nth_tick(CHECK_TICKS, function()
	local st = storage.fork_solar_boilers
	if not st then return end
	for k, e in pairs(st) do
		if e.valid then update(e) else st[k] = nil end
	end
end)

return M
