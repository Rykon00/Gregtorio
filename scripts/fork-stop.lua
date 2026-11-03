--------------------------------------------------------------------------------
--- FORK STOP (issue #618): several scripts stop one machine with disabled_by_script (the molds' missing mold, the
--- maintenance, ...). Each one sets or clears its own reason here: the machine runs again only when no reason is left,
--- and shows the status of the reason set last that is still there.
--- State: storage.fork_stops (unit number -> { reasons = { reason -> status }, order = { reason, ... } }).
--------------------------------------------------------------------------------

local M = {}

--- stop `entity` for `reason` with the custom status `status`, or (status nil) take the reason back
function M.set(entity, reason, status)
	local id = entity.unit_number
	storage.fork_stops = storage.fork_stops or {}
	local rec = storage.fork_stops[id]
	if status then
		if not rec then
			rec = { reasons = {}, order = {} }
			storage.fork_stops[id] = rec
		end
		if not rec.reasons[reason] then rec.order[#rec.order + 1] = reason end
		rec.reasons[reason] = status
		entity.disabled_by_script = true
		entity.custom_status = status
		return
	end
	if rec and rec.reasons[reason] then
		rec.reasons[reason] = nil
		for i, r in pairs(rec.order) do
			if r == reason then table.remove(rec.order, i) break end
		end
	end
	local last = rec and rec.order[#rec.order]
	if last then
		entity.custom_status = rec.reasons[last]
	elseif rec or entity.disabled_by_script then
		--- (no write for a machine that runs; one stopped before this file, by a script that uses it now, is released)
		if rec then storage.fork_stops[id] = nil end
		entity.disabled_by_script = false
		entity.custom_status = nil
	end
end

--- whether `reason` (or, without one, any reason of this file) stops the machine
function M.stopped(entity, reason)
	local rec = storage.fork_stops and storage.fork_stops[entity.unit_number]
	if not rec then return false end
	if reason then return rec.reasons[reason] ~= nil end
	return #rec.order > 0
end

--- a removed machine's reasons (from the scripts' clean-up of invalid entities: the unit number is enough)
function M.forget(unit_number)
	if storage.fork_stops then storage.fork_stops[unit_number] = nil end
end

return M
