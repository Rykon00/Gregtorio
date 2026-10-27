--------------------------------------------------------------------------------
--- FORK MOLDS (runtime, see prototypes/150-fork-molds.lua)
--- Machines with a mold slot are tracked in storage.fork_molds.machines. Every CHECK_TICKS
--- each of them is checked (issue #642: in shares, scripts/fork-batch.lua): if its recipe needs a mold that is not in the mold slot, the
--- machine is stopped (disabled_by_script) with the status "Missing mold"; as soon as the
--- mold is there (or the recipe changes) it runs again. Only machines stopped by this
--- script are switched back on.
--- Issue #316: the laser engravers' lens slot works the same way, with the status "Missing <lens>".
--------------------------------------------------------------------------------

local M = {}
local batch = require("scripts.fork-batch")

local CHECK_TICKS = 30
--- issue #642: the machines are checked in shares every STEP_TICKS, each one once per CHECK_TICKS (scripts/fork-batch.lua)
local STEP_TICKS = 5

--- (issue #642: read once per session; the mod data's `data` builds the whole table on every read)
local recipes_cache
local function mold_recipes()
	if not recipes_cache then
		local md = prototypes.mod_data["fork-mold-recipes"]
		recipes_cache = md and md.data or {}
	end
	return recipes_cache
end

--- the module categories of 150's items that stay in the machine
local TOOL_CATEGORIES = { "mold", "lens" }

local function has_mold_slot(proto)
	local c = proto.allowed_module_categories
	if c == nil or (proto.module_inventory_size or 0) == 0 then return false end
	for _, category in pairs(TOOL_CATEGORIES) do
		if c[category] then return true end
	end
	return false
end

local function missing_label(item)
	local p = prototypes.item[item]
	if p and p.type == "module" and p.category == "lens" then
		return { "entity-status.fork-missing-lens", p.localised_name }
	end
	return { "entity-status.fork-missing-mold" }
end

--- names of all machines that currently have a mold slot
local function mold_machine_names()
	local names = {}
	for name, proto in pairs(prototypes.get_entity_filtered{
		{ filter = "type", type = "assembling-machine" }, { filter = "type", type = "furnace" } }) do
		if has_mold_slot(proto) then names[#names + 1] = name end
	end
	return names
end

--- storage.fork_molds.known: machine names that already had their mold slot when this
--- save was created or last updated (see on_configuration_changed)
local function state()
	if not storage.fork_molds then
		local known = {}
		for _, n in pairs(mold_machine_names()) do known[n] = true end
		storage.fork_molds = { machines = {}, stopped = {}, known = known }
	end
	return storage.fork_molds
end

--- stop: the missing mold or lens, or nil; st.stopped[id] keeps the item the status names (true in older saves)
local function set_stopped(st, entity, stop)
	local id = entity.unit_number
	if stop and st.stopped[id] ~= stop then
		entity.disabled_by_script = true
		entity.custom_status = {
			diode = defines.entity_status_diode.red,
			label = missing_label(stop),
		}
		st.stopped[id] = stop
	elseif not stop and st.stopped[id] then
		entity.disabled_by_script = false
		entity.custom_status = nil
		st.stopped[id] = nil
	end
end

local function check(st, entity, recipes)
	local recipe = entity.get_recipe()
	local mold = recipe and recipes[recipe.name]
	local stop = nil
	if mold then
		local inv = entity.get_module_inventory()
		if not (inv and inv.get_item_count(mold) > 0) then stop = mold end
	end
	set_stopped(st, entity, stop)
end

function M.on_built(entity)
	if not (entity and entity.valid and entity.unit_number) then return end
	if entity.type ~= "assembling-machine" and entity.type ~= "furnace" then return end
	if not has_mold_slot(entity.prototype) then return end
	state().machines[entity.unit_number] = entity
end

--- Saves from before a machine had its mold slot: the mold was either built into the
--- machine or lay in its input/output (Factorio deletes it there when the recipe changes).
--- Every such machine with a mold recipe gets a mold into its slot once. Issue #316: the same for the laser engravers
--- of saves from before their lens slot, whose lens lay in the input or output; they get the lens of their recipe.
local function give_back_mold(entity, recipes)
	local recipe = entity.get_recipe()
	local mold = recipe and recipes[recipe.name]
	local inv = entity.get_module_inventory()
	if mold and inv and inv.get_item_count(mold) == 0 then
		inv.insert{ name = mold, count = 1 }
	end
end

function M.on_configuration_changed()
	local old_save = storage.fork_molds == nil
	local st = state()
	st.known = st.known or {}
	local names = mold_machine_names()
	local recipes = mold_recipes()
	st.machines = {}
	if #names == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = names }) do
			st.machines[e.unit_number] = e
			if old_save or not st.known[e.name] then give_back_mold(e, recipes) end
		end
	end
	st.known = {}
	for _, n in pairs(names) do st.known[n] = true end
end

script.on_nth_tick(STEP_TICKS, function()
	local st = storage.fork_molds
	if not st or next(st.machines) == nil then return end
	local recipes = mold_recipes()
	batch.visit(st, "machines", CHECK_TICKS, STEP_TICKS, function(id, e)
		if e.valid then
			check(st, e, recipes)
		else
			st.machines[id] = nil
			st.stopped[id] = nil
		end
	end)
end)

return M
