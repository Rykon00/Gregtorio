--------------------------------------------------------------------------------
--- FORK BLAST FURNACE HEAT (issue #620; prototypes/fork-ebf-heat.lua)
--- Every electric blast furnace (mod data `fork-ebf-heat`) is checked every CHECK_TICKS (in shares, scripts/fork-batch.lua):
--- its heat (the coil in its coil slot, else the coil it is built with, plus 100 K per tier above MV) against its recipe's.
--- Too little: it stops (scripts/fork-stop.lua, status "Heat too low"). Heat to spare: a hidden beacon in its middle holds
--- the bonus module of GT's discount (5 % less power per 900 K) and perfect overclocks (one per 1800 K, at most its tiers
--- above the recipe's); no bonus, no beacon.
--- State: storage.fork_ebf_heat.machines (unit number -> { entity, beacon, bonus }).
--------------------------------------------------------------------------------

local M = {}
local batch = require("scripts.fork-batch")
local fork_stop = require("scripts.fork-stop")
local CHECK_TICKS = 60
local STEP_TICKS = 10

local data_cache
local function md()
	if not data_cache then
		local d = prototypes.mod_data["fork-ebf-heat"]
		data_cache = d and d.data or { machines = {}, coils = {}, recipes = {}, recipe_tier = {} }
	end
	return data_cache
end

local function state()
	storage.fork_ebf_heat = storage.fork_ebf_heat or { machines = {} }
	return storage.fork_ebf_heat
end

--- the furnace's heat (K)
function M.heat(entity)
	local d = md()
	local m = d.machines[entity.name]
	if not m then return 0 end
	local coil = m.coil
	local inv = entity.get_module_inventory()
	if inv then
		for i = 1, #inv do
			local s = inv[i]
			if s.valid_for_read and d.coils[s.name] then
				coil = d.coils[s.name]
				break
			end
		end
	end
	return coil + d.heat_per_tier * (m.tier - 2)
end

local function set_bonus(rec, name)
	if rec.bonus == name and (not name or (rec.beacon and rec.beacon.valid)) then return end
	if not name then
		if rec.beacon and rec.beacon.valid then rec.beacon.destroy() end
		rec.beacon, rec.bonus = nil, nil
		return
	end
	local e = rec.entity
	if not (rec.beacon and rec.beacon.valid) then
		rec.beacon = e.surface.create_entity{ name = md().beacon, position = e.position, force = e.force }
	end
	local inv = rec.beacon and rec.beacon.get_module_inventory()
	if not inv then return end
	inv.clear()
	inv.insert{ name = name, count = 1 }
	rec.bonus = name
end

local function update(rec)
	local e, d = rec.entity, md()
	local recipe = e.get_recipe()
	local need = recipe and d.recipes[recipe.name]
	if not need then
		fork_stop.set(e, "ebf-heat", nil)
		set_bonus(rec, nil)
		return
	end
	local have = M.heat(e)
	if have < need then
		fork_stop.set(e, "ebf-heat", { diode = defines.entity_status_diode.red,
			label = { "entity-status.fork-ebf-heat-low", tostring(have), tostring(need) } })
		set_bonus(rec, nil)
		return
	end
	fork_stop.set(e, "ebf-heat", nil)
	local surplus = have - need
	local n = math.min(math.floor(surplus / d.discount), d.max_n)
	local oc = d.machines[e.name].tier - (d.recipe_tier[recipe.name] or d.machines[e.name].tier)
	local k = math.max(math.min(math.floor(surplus / d.overclock), oc, d.max_k), 0)
	set_bonus(rec, (k > 0 or n > 0) and ("fork-ebf-heat-bonus-" .. k .. "-" .. n) or nil)
end

function M.on_built(entity)
	if not (entity and entity.valid and entity.unit_number and md().machines[entity.name]) then return end
	local st = state()
	if not st.machines[entity.unit_number] then
		st.machines[entity.unit_number] = { entity = entity }
		update(st.machines[entity.unit_number])
	end
end

function M.on_configuration_changed()
	data_cache = nil
	local list = {}
	for n in pairs(md().machines) do if prototypes.entity[n] then list[#list + 1] = n end end
	if #list == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = list }) do M.on_built(e) end
	end
end

script.on_nth_tick(STEP_TICKS, function()
	if not storage.fork_ebf_heat then return end
	local st = state()
	batch.visit(st, "machines", CHECK_TICKS, STEP_TICKS, function(k, rec)
		if rec.entity.valid then
			update(rec)
		else
			if rec.beacon and rec.beacon.valid then rec.beacon.destroy() end
			st.machines[k] = nil
			fork_stop.forget(k)
		end
	end)
end)

--- for devcheck's runtime test: a furnace's heat, its bonus module and its stop
remote.add_interface("fork-ebf-heat", {
	state = function(entity)
		local rec = entity and entity.valid and storage.fork_ebf_heat and storage.fork_ebf_heat.machines[entity.unit_number]
		if not rec then return nil end
		update(rec)
		return { heat = M.heat(entity), bonus = rec.bonus, stopped = fork_stop.stopped(entity, "ebf-heat") }
	end,
})

return M
