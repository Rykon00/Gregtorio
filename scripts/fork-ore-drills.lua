--------------------------------------------------------------------------------
--- FORK ORE DRILLS (issue #499, plan #494): GT New Horizons' Ore Drilling Plants drink Drilling Fluid for every ore they
--- mine (MTEOreDrillingPlantBase tryConsumeDrillingFluid). The plants of prototypes/163-fork-electric-mine.lua are mining
--- drills of the map veins; a drill's own fluid box works only while its ore needs a fluid, so the fluid goes into a
--- hidden tank on the plant's tiles (mod data `fork-ore-drills`: tank), which this script builds with the plant and
--- removes with it (on_object_destroyed). Every CHECK_TICKS it takes the fluid of the ores a working plant mined since
--- the last check (a mining drill counts no products: its rate, mining speed / the ores' mining time, over the interval;
--- per_ore, ore_time). A plant whose fluid does not cover them owes the rest and stops (disabled_by_script, status "No
--- Drilling Fluid") until its fluid pays the debt and a check's worth of ore.
--- State: storage.fork_ore_drills = { plants = unit number -> { entity, tank, debt }, reg = registration -> unit
--- number }, filled when one is built and after a mod change; a plant that is gone drops out with its tank.
--------------------------------------------------------------------------------

local M = {}
local batch = require("scripts.fork-batch")
local CHECK_TICKS = 60
--- issue #642: the plants are checked in shares every STEP_TICKS, each one once per CHECK_TICKS (scripts/fork-batch.lua);
--- a check charges the ticks since the plant's last one (rec.tick). Free intervals: the molds take 2, the solar boilers 8,
--- the Ender Tanks 20, fork-power on_tick
local STEP_TICKS = 4

local config
local function drill_data()
	if not config then
		local d = prototypes.mod_data["fork-ore-drills"]
		config = d and d.data or { plants = {}, per_ore = 0 }
	end
	return config
end

local function state()
	storage.fork_ore_drills = storage.fork_ore_drills or { plants = {}, reg = {} }
	return storage.fork_ore_drills
end

function M.on_built(entity)
	local d = drill_data()
	if not (entity and entity.valid and d.plants[entity.name]) then return end
	local tank = entity.surface.find_entity(d.tank, entity.position)
		or entity.surface.create_entity{ name = d.tank, position = entity.position, force = entity.force }
	local st = state()
	st.plants[entity.unit_number] = { entity = entity, tank = tank, debt = 0 }
	st.reg[script.register_on_object_destroyed(entity)] = entity.unit_number
end

function M.on_object_destroyed(event)
	local st = storage.fork_ore_drills
	local unit = st and st.reg[event.registration_number]
	if not unit then return end
	st.reg[event.registration_number] = nil
	local rec = st.plants[unit]
	st.plants[unit] = nil
	if rec and rec.tank and rec.tank.valid then rec.tank.destroy() end
end

function M.on_configuration_changed()
	local d, list = drill_data(), {}
	for n in pairs(d.plants) do if prototypes.entity[n] then list[#list + 1] = n end end
	storage.fork_ore_drills = { plants = {}, reg = {} }
	if not prototypes.entity[d.tank] then return end
	for _, surface in pairs(game.surfaces) do
		if #list > 0 then
			for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
		end
		--- a tank without its plant (the plant removed while the mod was off)
		for _, t in pairs(surface.find_entities_filtered{ name = d.tank }) do
			local plant = false
			for _, e in pairs(surface.find_entities_filtered{ position = t.position, name = list }) do plant = true end
			if not plant then t.destroy() end
		end
	end
end

local function check(rec)
	local e, t, d = rec.entity, rec.tank, drill_data()
	if not (t and t.valid) then
		t = e.surface.create_entity{ name = d.tank, position = e.position, force = e.force }
		rec.tank = t
	end
	local ticks = rec.tick and math.max(game.tick - rec.tick, 0) or CHECK_TICKS
	rec.tick = game.tick
	local per_check = e.prototype.mining_speed / d.ore_time * CHECK_TICKS / 60 * d.per_ore
	if e.status == defines.entity_status.working then rec.debt = rec.debt + per_check * ticks / CHECK_TICKS end
	local have = t.get_fluid_count(d.fluid)
	--- a running plant pays what it owes; a stopped one starts again once it can pay that and the next check's ore
	local need = rec.debt + (e.disabled_by_script and per_check or 0)
	if have >= need and need > 0 then
		t.extract_fluid{ name = d.fluid, amount = rec.debt }
		rec.debt = 0
	elseif rec.debt > 0 and have > 0 then
		rec.debt = rec.debt - t.extract_fluid{ name = d.fluid, amount = math.min(have, rec.debt) }
	end
	local stop = rec.debt > 1e-9
	e.disabled_by_script = stop
	e.custom_status = stop and { diode = defines.entity_status_diode.red,
		label = { "entity-status.fork-no-drilling-fluid" } } or nil
end

script.on_nth_tick(STEP_TICKS, function()
	local st = storage.fork_ore_drills
	if not st then return end
	batch.visit(st, "plants", CHECK_TICKS, STEP_TICKS, function(k, rec)
		if rec.entity.valid then check(rec) else st.plants[k] = nil end
	end)
end)

return M
