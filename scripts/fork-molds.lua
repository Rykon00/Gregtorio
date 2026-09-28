--------------------------------------------------------------------------------
--- FORK MOLDS (runtime, see prototypes/150-fork-molds.lua)
--- Machines with a mold slot are tracked in storage.fork_molds.machines. Every CHECK_TICKS
--- each of them is checked: if its recipe needs a mold that is not in the mold slot, the
--- machine is stopped (disabled_by_script) with the status "Missing mold"; as soon as the
--- mold is there (or the recipe changes) it runs again. Only machines stopped by this
--- script are switched back on.
--------------------------------------------------------------------------------

local M = {}

local CHECK_TICKS = 30

local function mold_recipes()
	local md = prototypes.mod_data["fork-mold-recipes"]
	return md and md.data or {}
end

local function has_mold_slot(proto)
	local c = proto.allowed_module_categories
	return c ~= nil and c["mold"] == true and (proto.module_inventory_size or 0) > 0
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

local function set_stopped(st, entity, stop)
	local id = entity.unit_number
	if stop and not st.stopped[id] then
		entity.disabled_by_script = true
		entity.custom_status = {
			diode = defines.entity_status_diode.red,
			label = { "entity-status.fork-missing-mold" },
		}
		st.stopped[id] = true
	elseif not stop and st.stopped[id] then
		entity.disabled_by_script = false
		entity.custom_status = nil
		st.stopped[id] = nil
	end
end

local function check(st, entity, recipes)
	local recipe = entity.get_recipe()
	local mold = recipe and recipes[recipe.name]
	local stop = false
	if mold then
		local inv = entity.get_module_inventory()
		stop = not (inv and inv.get_item_count(mold) > 0)
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
--- Every such machine with a mold recipe gets a mold into its slot once.
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

script.on_nth_tick(CHECK_TICKS, function()
	local st = storage.fork_molds
	if not st or next(st.machines) == nil then return end
	local recipes = mold_recipes()
	for id, e in pairs(st.machines) do
		if e.valid then
			check(st, e, recipes)
		else
			st.machines[id] = nil
			st.stopped[id] = nil
		end
	end
end)

return M
