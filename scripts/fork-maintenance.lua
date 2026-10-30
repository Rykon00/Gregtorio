--------------------------------------------------------------------------------
--- FORK MAINTENANCE (issue #618; prototypes/fork-maintenance.lua, startup setting gregtorio-continued-maintenance)
--- Every crafting multiblock (mod data `fork-maintenance`) has a maintenance slot. Each one keeps `left`, the running time
--- (ticks) until its next kit: a new machine starts with one kit's time (GT: a new multiblock is fully maintained).
--- Every CHECK_TICKS (in shares, scripts/fork-batch.lua) a machine that is working loses CHECK_TICKS; at 0 it takes one
--- kit (a Maintenance Kit or Duct Tape) out of its slot for another kit's time, or stops (disabled_by_script, status
--- "Needs maintenance") until a kit is in the slot (scripts/fork-stop.lua: it runs again once no other script stops it).
--- State: storage.fork_maintenance.machines (unit number -> { entity, left }). Nothing runs with the setting off.
--------------------------------------------------------------------------------

local M = {}
local batch = require("scripts.fork-batch")
local stop = require("scripts.fork-stop")
local CHECK_TICKS = 300
local STEP_TICKS = 30

local data_cache
local function md()
	if not data_cache then
		local d = prototypes.mod_data["fork-maintenance"]
		data_cache = { machines = {}, kits = {}, kit_ticks = 0 }
		if d then
			for _, n in pairs(d.data.machines) do data_cache.machines[n] = true end
			data_cache.kits = d.data.kits
			data_cache.kit_ticks = d.data.kit_ticks
		end
	end
	return data_cache
end
local function on() return settings.startup["gregtorio-continued-maintenance"].value end

local function state()
	storage.fork_maintenance = storage.fork_maintenance or { machines = {} }
	return storage.fork_maintenance
end

local STATUS = { diode = defines.entity_status_diode.red, label = { "entity-status.fork-needs-maintenance" } }

--- a kit out of the slot: true when one was there
local function take_kit(entity)
	local inv = entity.get_module_inventory()
	if not inv then return false end
	for _, kit in pairs(md().kits) do
		if inv.get_item_count(kit) > 0 then
			inv.remove{ name = kit, count = 1 }
			return true
		end
	end
	return false
end

local function update(rec, elapsed)
	local e = rec.entity
	if rec.stopped then
		if take_kit(e) then
			rec.left, rec.stopped = md().kit_ticks, nil
			stop.set(e, "maintenance", nil)
		end
		return
	end
	if e.status == defines.entity_status.working then rec.left = rec.left - elapsed end
	if rec.left <= 0 then
		if take_kit(e) then
			rec.left = rec.left + md().kit_ticks
		else
			rec.stopped = true
			stop.set(e, "maintenance", STATUS)
		end
	end
end

function M.on_built(entity)
	if not (on() and entity and entity.valid and md().machines[entity.name]) then return end
	local st = state()
	if not st.machines[entity.unit_number] then
		st.machines[entity.unit_number] = { entity = entity, left = md().kit_ticks }
	end
end

function M.on_configuration_changed()
	if not on() then
		storage.fork_maintenance = nil
		return
	end
	local list = {}
	for n in pairs(md().machines) do if prototypes.entity[n] then list[#list + 1] = n end end
	if #list == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
	end
end

--- for devcheck's runtime test: a machine's state, and its time left set
function M.remote_state(entity)
	local rec = entity and entity.valid and storage.fork_maintenance and storage.fork_maintenance.machines[entity.unit_number]
	return rec and { left = rec.left, stopped = rec.stopped or false } or nil
end
function M.remote_set_left(entity, ticks)
	local rec = entity and entity.valid and storage.fork_maintenance and storage.fork_maintenance.machines[entity.unit_number]
	if rec then rec.left = ticks end
	return rec ~= nil
end

script.on_nth_tick(STEP_TICKS, function()
	if not storage.fork_maintenance then return end
	local st = state()
	batch.visit(st, "machines", CHECK_TICKS, STEP_TICKS, function(k, rec)
		if rec.entity.valid then update(rec, CHECK_TICKS) else st.machines[k] = nil; stop.forget(k) end
	end)
end)

remote.add_interface("fork-maintenance", { state = M.remote_state, set_left = M.remote_set_left })

return M
