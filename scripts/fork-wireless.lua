--------------------------------------------------------------------------------
--- FORK WIRELESS ENERGY (issue #622; prototypes/173-fork-wireless.lua)
--- Every 60 ticks each Wireless Dynamo Hatch's buffer (what it drew from its network) goes into its force's account,
--- then each Wireless Energy Hatch's buffer is filled from the account, so power moves between surfaces.
--- State: storage.fork_wireless = { accounts = { force index -> joules }, hatches = { unit number -> { entity, dynamo } } }.
--------------------------------------------------------------------------------

local M = {}

local data_cache
local function md()
	if not data_cache then
		local d = prototypes.mod_data["fork-wireless"]
		data_cache = { dynamo = {}, energy = {}, names = {} }
		if d then
			for _, n in pairs(d.data.dynamo) do data_cache.dynamo[n] = true; data_cache.names[#data_cache.names + 1] = n end
			for _, n in pairs(d.data.energy) do data_cache.energy[n] = true; data_cache.names[#data_cache.names + 1] = n end
		end
	end
	return data_cache
end

local function state()
	storage.fork_wireless = storage.fork_wireless or { accounts = {}, hatches = {} }
	return storage.fork_wireless
end

function M.on_built(entity)
	if not (entity and entity.valid and entity.unit_number) then return end
	local d = md()
	if not (d.dynamo[entity.name] or d.energy[entity.name]) then return end
	state().hatches[entity.unit_number] = { entity = entity, dynamo = d.dynamo[entity.name] or false }
end

function M.on_configuration_changed()
	data_cache = nil
	local list = {}
	for _, n in pairs(md().names) do if prototypes.entity[n] then list[#list + 1] = n end end
	if #list == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
	end
end

--- one transfer: the dynamo hatches first, then the energy hatches (by unit number, so the oldest are served first)
function M.transfer()
	local st = storage.fork_wireless
	if not st then return end
	local fill = {}
	for k, h in pairs(st.hatches) do
		local e = h.entity
		if not e.valid then
			st.hatches[k] = nil
		elseif h.dynamo then
			local f = e.force.index
			st.accounts[f] = (st.accounts[f] or 0) + e.energy
			e.energy = 0
		else
			fill[#fill + 1] = k
		end
	end
	table.sort(fill)
	for _, k in pairs(fill) do
		local e = st.hatches[k].entity
		local f = e.force.index
		local have = st.accounts[f] or 0
		if have > 0 then
			local take = math.min(have, e.electric_buffer_size - e.energy)
			if take > 0 then
				e.energy = e.energy + take
				st.accounts[f] = have - take
			end
		end
	end
end

script.on_nth_tick(60, M.transfer)

--- the account of a force (joules); for devcheck's runtime test and the console
remote.add_interface("fork-wireless", {
	account = function(force)
		local f = game.forces[force]
		return f and storage.fork_wireless and storage.fork_wireless.accounts[f.index] or 0
	end,
})

return M
