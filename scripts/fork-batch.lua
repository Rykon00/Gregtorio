--------------------------------------------------------------------------------
--- FORK BATCH (issue #642): a periodic check spread over the ticks. A handler that runs every `step` ticks visits about
--- size * step / period entries of a table, from where the last call stopped, so every entry comes up once per `period`
--- ticks and a megabase's thousands of machines cost the same per tick instead of one spike per period. The cursor (the
--- next key to visit) and the share of a call, counted once per round, live in storage beside the table; a visit may
--- remove its own entry.
--------------------------------------------------------------------------------

local M = {}

--- holder[key]: the table of entries; holder[key .. "_cursor"]: the next entry to visit (nil: a new round);
--- holder[key .. "_share"]: the entries per call of this round. visit(k, v) is called for each entry of this call's
--- share; a round ends with the table's last entry, the next call starts the next round.
function M.visit(holder, key, period, step, visit)
	local t = holder[key]
	local cursor_key, share_key = key .. "_cursor", key .. "_share"
	if not t or next(t) == nil then
		holder[cursor_key], holder[share_key] = nil, nil
		return
	end
	local k = holder[cursor_key]
	--- a new round (or an entry removed outside a visit, or a table replaced since)
	if k == nil or t[k] == nil or not holder[share_key] then
		k = next(t)
		holder[share_key] = math.ceil(table_size(t) * step / period)
	end
	for _ = 1, holder[share_key] do
		if k == nil then break end
		local after = next(t, k)
		visit(k, t[k])
		k = after
	end
	holder[cursor_key] = k
end

return M
