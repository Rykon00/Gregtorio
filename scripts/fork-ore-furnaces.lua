--- Issue #560: the ore machines are furnaces since this version (prototypes/101-fork-machines.lua, section 2n). The engine
--- deletes a placed machine whose prototype changed its type, so the JSON migration 2026-10-24-issue-560-ore-furnaces.json
--- turns the machines of an old save into the hidden assembling machines `legacy-<name>`, and the Lua migration of the same
--- name calls the remote `fork-ore-furnaces.migrate`, which builds the furnace `<name>` in each one's place: the same
--- direction, mirroring, force, quality, health and last user, its input, output and fluids, the circuit wires and the
--- settings the furnace knows. The ingredients of a craft in progress go back into the input (a furnace picks its recipe
--- from there); what does not fit goes into the output, the rest onto the ground. Ghosts of the old machines become
--- ghosts of the furnaces. Runs once per save; no state, no events.
local M = {}

local CRAFTER = { defines.inventory.crafter_input, defines.inventory.crafter_output }
--- control behaviour settings of an assembling machine that a furnace has too (pcall: a key the furnace lacks is skipped)
local BEHAVIOUR = { "circuit_enable_disable", "circuit_condition", "connect_to_logistic_network", "logistic_condition",
	"circuit_read_contents", "include_in_crafting", "include_fuel", "circuit_read_recipe_finished",
	"circuit_recipe_finished_signal", "circuit_read_working", "circuit_working_signal" }

--- the production type of fluid storage `i` (Factorio 2.1 has no LuaEntity::fluidbox; a crafting machine's box that its
--- recipe made of several prototypes gives their list)
local function box_kind(e, i)
	local ok, p = pcall(e.get_fluid_box_prototype, i)
	if not ok or not p then return nil end
	if type(p) == "table" and p[1] then p = p[1] end
	return p.production_type
end

local function legacy_names()
	local md = prototypes.mod_data["fork-ore-furnaces"]
	return md and md.data.legacy or {}
end

--- the contents of a machine: item stacks of its input and output, the craft in progress, fluids by production type
local function contents(old)
	local c = { input = {}, output = {}, fluids = { input = {}, output = {}, input_temperature = {}, output_temperature = {} } }
	for i, inv in pairs(CRAFTER) do
		local inventory = old.get_inventory(inv)
		for _, s in pairs(inventory and inventory.get_contents() or {}) do
			table.insert(i == 1 and c.input or c.output, { name = s.name, count = s.count, quality = s.quality })
		end
	end
	local recipe, quality = old.get_recipe()
	if recipe and old.crafting_progress > 0 then
		c.in_progress = recipe.name
		for _, ing in pairs(recipe.ingredients) do
			if ing.type == "item" then
				c.input[#c.input + 1] = { name = ing.name, count = ing.amount, quality = quality and quality.name }
			else
				c.fluids.input[ing.name] = (c.fluids.input[ing.name] or 0) + ing.amount
			end
		end
	end
	for i = 1, old.fluids_count do
		local f = old.get_fluid(i)
		if f then
			local kind = box_kind(old, i) == "output" and "output" or "input"
			local t = c.fluids[kind]
			t[f.name] = (t[f.name] or 0) + f.amount
			c.fluids[kind .. "_temperature"][f.name] = f.temperature
		end
	end
	--- one stack per item and quality (the craft's ingredients join the input's stack)
	local merged, at = {}, {}
	for _, st in pairs(c.input) do
		local k = st.name .. "/" .. tostring(st.quality)
		if at[k] then at[k].count = at[k].count + st.count else at[k] = st; merged[#merged + 1] = st end
	end
	c.input = merged
	return c
end

--- the circuit wires a player made, as (connector id, other entity, its connector id, origin)
local function wires(old)
	local list = {}
	for id, connector in pairs(old.get_wire_connectors(false)) do
		for _, w in pairs(connector.connections) do
			if w.origin == defines.wire_origin.player then
				list[#list + 1] = { id = id, other = w.target.owner, other_id = w.target.wire_connector_id, origin = w.origin }
			end
		end
	end
	return list
end

local function behaviour(old)
	local cb = old.get_control_behavior()
	if not cb then return nil end
	local t = {}
	for _, k in pairs(BEHAVIOUR) do
		local ok, v = pcall(function() return cb[k] end)
		if ok then t[k] = v end
	end
	return t
end

local function fill(new, c, stats)
	local surface, force = new.surface, new.force
	local input, output = new.get_inventory(defines.inventory.crafter_input), new.get_inventory(defines.inventory.crafter_output)
	local function put(stack, first)
		local left = stack.count
		for _, inv in pairs(first and { input, output } or { output }) do
			if left > 0 then left = left - inv.insert{ name = stack.name, count = left, quality = stack.quality } end
			--- (a furnace's input takes no item whose recipe is not researched: an empty slot is set directly)
			for i = 1, #inv do
				if left > 0 and not inv[i].valid_for_read
					and inv[i].set_stack{ name = stack.name, count = math.min(left, prototypes.item[stack.name].stack_size),
						quality = stack.quality } then
					left = left - inv[i].count
				end
			end
		end
		if left > 0 then
			surface.spill_item_stack{ position = new.position, stack = { name = stack.name, count = left, quality = stack.quality },
				force = force, allow_belts = false }
			stats.spilled = stats.spilled + left
		end
	end
	--- the fluids first: a furnace takes the item of an item and fluid recipe only with the fluid in it
	for name, amount in pairs(c.fluids.input) do
		local n = new.insert_fluid{ name = name, amount = amount, temperature = c.fluids.input_temperature[name] }
		stats.fluid_lost = stats.fluid_lost + amount - n
	end
	for name, amount in pairs(c.fluids.output) do
		local done = false
		for i = 1, new.fluids_count do
			local f = new.get_fluid(i)
			if not done and box_kind(new, i) == "output" and (not f or f.name == name) then
				local have = f and f.amount or 0
				local add = math.min(new.get_fluid_capacity(i) - have, amount)
				new.set_fluid(i, { name = name, amount = have + add, temperature = c.fluids.output_temperature[name] })
				stats.fluid_lost = stats.fluid_lost + amount - add
				done = true
			end
		end
		if not done then stats.fluid_lost = stats.fluid_lost + amount end
	end
	for _, s in pairs(c.output) do put(s, false) end
	for _, s in pairs(c.input) do put(s, true) end
end

local function rebuild(old, name, stats)
	local surface = old.surface
	local spec = { name = name, position = old.position, direction = old.direction, force = old.force,
		quality = old.quality.name, raise_built = true }
	local mirroring, health, user = old.mirroring, old.health, old.last_user
	local c, w, cb = contents(old), wires(old), behaviour(old)
	local deconstruct = old.to_be_deconstructed()
	old.destroy{ raise_destroy = true }
	local new = surface.create_entity(spec)
	if not new then
		stats.failed = stats.failed + 1
		log(string.format("FORK-ORE-FURNACES: no %s could be built at %.1f,%.1f", name, spec.position.x, spec.position.y))
		return
	end
	if mirroring then pcall(function() new.mirroring = mirroring end) end
	if health then new.health = health end
	if user then new.last_user = user end
	fill(new, c, stats)
	for _, x in pairs(w) do
		if x.other.valid then
			local a, b = new.get_wire_connector(x.id, true), x.other.get_wire_connector(x.other_id, true)
			if a and b then a.connect_to(b, false, x.origin) end
		end
	end
	if cb then
		local ncb = new.get_or_create_control_behavior()
		for k, v in pairs(cb) do pcall(function() ncb[k] = v end) end
	end
	if deconstruct then new.order_deconstruction(new.force) end
	stats.rebuilt = stats.rebuilt + 1
	if c.in_progress then stats.in_progress = stats.in_progress + 1 end
end

--- builds the furnace of every legacy machine and ghost on every surface; returns the counts
function M.migrate()
	local legacy = legacy_names()
	local names = {}
	for old in pairs(legacy) do
		if prototypes.entity[old] then names[#names + 1] = old end
	end
	local stats = { rebuilt = 0, in_progress = 0, ghosts = 0, failed = 0, spilled = 0, fluid_lost = 0 }
	if #names == 0 then return stats end
	for _, surface in pairs(game.surfaces) do
		for _, old in pairs(surface.find_entities_filtered{ name = names }) do
			rebuild(old, legacy[old.name], stats)
		end
		for _, g in pairs(surface.find_entities_filtered{ ghost_name = names }) do
			local spec = { name = "entity-ghost", inner_name = legacy[g.ghost_name], position = g.position, direction = g.direction,
				force = g.force, quality = g.quality.name }
			g.destroy()
			if surface.create_entity(spec) then stats.ghosts = stats.ghosts + 1 end
		end
	end
	log(string.format("FORK-ORE-FURNACES: %d ore machines of the old save rebuilt as furnaces (%d with a craft in progress, "
		.. "its ingredients back in the input), %d ghosts, %d failed, %d items spilled, %.1f fluid lost (issue #560)",
		stats.rebuilt, stats.in_progress, stats.ghosts, stats.failed, stats.spilled, stats.fluid_lost))
	return stats
end

remote.add_interface("fork-ore-furnaces", { migrate = M.migrate })

return M
