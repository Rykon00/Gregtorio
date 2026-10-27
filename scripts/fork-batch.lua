--------------------------------------------------------------------------------
--- FORK BATCH (issue #642): a periodic check spread over the ticks. A handler that runs every `step` ticks visits about
--- size * step / period entries of a table, from where the last call stopped, so every entry comes up once per `period`
--- ticks and a megabase's thousands of machines cost the same per tick instead of one spike per period. The cursor (the
--- next key to visit) lives in storage beside the table; a visit may remove its own entry.
--------------------------------------------------------------------------------

local M = {}

--- holder[key]: the table of entries; holder[key .. "_cursor"]: the next entry to visit (nil: a new round). visit(k, v)
--- is called for each entry of this call's share; a round ends with the table's last entry, the next call starts the
--- next round.
function M.visit(holder, key, period, step, visit)
	local t = holder[key]
	local cursor_key = key .. "_cursor"
	local n = t and table_size(t) or 0
	if n == 0 then
		holder[cursor_key] = nil
		return
	end
	local k = holder[cursor_key]
	--- (an entry removed outside a visit, or a table replaced since: a new round)
	if k == nil or t[k] == nil then k = next(t) end
	for _ = 1, math.ceil(n * step / period) do
		if k == nil then break end
		local after = next(t, k)
		visit(k, t[k])
		k = after
	end
	holder[cursor_key] = k
end

return M
