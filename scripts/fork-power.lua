--- Fork: runtime of the endgame generators (prototypes/136-fork-power.lua).
---
--- Fuel check. A `generator` burns any fluid with a fuel value (steam has one, 100 kJ) and a fluid
--- box filter takes only one fluid, so the large plasma turbines and the large naquadah reactors
--- would run on steam and on each other's fuels. Each generator has a list of accepted fuels (mod
--- data "fork-power", `fuels`). Every INTERVAL ticks the fluid in its fluid box (or its pipeline
--- segment) is checked: a wrong fluid stops the generator (disabled_by_script, status "Wrong fuel:
--- <fluid>") and the fluid stays where it is; an empty generator is stopped as well (status "No
--- fuel"), so a wrong fluid that arrives later is never burnt. As soon as an accepted fuel is in
--- it, it runs again. Only generators stopped by this script are switched back on. New generators
--- are checked when they are built, existing ones after every configuration change (and once in
--- saves from before the fuel check).
--- Window: a running generator whose fuel runs out and is replaced by a wrong fluid within one
--- interval burns that fluid until the next check, then it stays stopped. That is at most INTERVAL
--- ticks of its output and at most one unit per tick (fluid_usage_per_tick = 1): steam at most 10
--- units (1 MJ), a naquadah fuel in a UV plasma turbine at most 54.6 MJ, a plasma in a UXV
--- reactor at most 10 units. A generator that ran dry is stopped before the next fluid arrives, so
--- the window needs the segment emptied and refilled between two checks.
--- Work per step: at most CHECKS_PER_STEP generators (round robin); up to that many generators
--- each one is checked every step.
---
--- Cooled fluid. GT's large plasma turbine returns one unit of the cooled fluid per unit of plasma
--- (helium plasma -> helium). A Factorio generator has one fluid box and no output, so this script
--- credits every turbine with the plasma it burnt (energy generated / fuel value, sampled every
--- 10 ticks) and pushes the cooled fluid into turbine output hatches standing next to it. Without
--- a hatch, or when the hatches are full, the cooled fluid is lost (GT voids it as well); at most
--- 1000 units are kept waiting per turbine.
---
--- State (lazy, `storage.fork_power`): `turbines` by unit number with their last plasma and the
--- amount of cooled fluid still owed; `generators` by unit number with the reason this script
--- stopped them (nil while running); `cursor` of the round robin. Rebuilt from the map on
--- configuration changes.
local M = {}

local INTERVAL = 10
local MAX_DEBT = 1000
local CHECKS_PER_STEP = 200
local NO_FUEL = ""                      -- `stopped` reason of an empty generator (else the fluid name)
local STATUS_KEYS = { ["entity-status.fork-wrong-fuel"] = true, ["entity-status.fork-no-fuel"] = true }

local function mod_data()
	local md = prototypes.mod_data["fork-power"]
	return md and md.data or { turbines = {}, cooled = {}, hatch = "turbine-output-hatch", fuels = {} }
end

local turbine_names, cooled_of, hatch_name, fuels_of
local function init()
	if turbine_names then return end
	local d = mod_data()
	turbine_names, cooled_of, hatch_name, fuels_of = {}, d.cooled or {}, d.hatch, {}
	for _, n in pairs(d.turbines or {}) do turbine_names[n] = true end
	for gen, list in pairs(d.fuels or {}) do
		if prototypes.entity[gen] then
			fuels_of[gen] = {}
			for _, f in pairs(list) do fuels_of[gen][f] = true end
		end
	end
end

local function state()
	local st = storage.fork_power
	if not st then
		st = { turbines = {} }
		storage.fork_power = st
	end
	st.generators = st.generators or {}         -- saves from before the fuel check
	return st
end

--------------------------------------------------------------------------------
--- Fuel check
--------------------------------------------------------------------------------

--- The fluid in the generator: its own part of the fluid box, else its pipeline segment
local function fluid_of(entity)
	local fb = entity.fluidbox
	local f = fb[1]
	if f then return f.name end
	local seg = fb.get_fluid_segment_contents(1)
	if seg then
		for name, amount in pairs(seg) do
			if amount > 0 then return name end
		end
	end
	return nil
end

local function check(g)
	local e = g.entity
	local allowed = fuels_of[e.name]
	if not allowed then return end
	local fluid = fluid_of(e)
	local reason = nil
	if not fluid then
		reason = NO_FUEL
	elseif not allowed[fluid] then
		reason = fluid
	end
	if reason == nil then
		if g.stopped then
			e.disabled_by_script = false
			e.custom_status = nil
			g.stopped = nil
		end
	elseif g.stopped ~= reason then
		if not g.stopped and e.disabled_by_script then return end    -- stopped by someone else
		e.disabled_by_script = true
		if reason == NO_FUEL then
			e.custom_status = { diode = defines.entity_status_diode.yellow, label = { "entity-status.fork-no-fuel" } }
		else
			local proto = prototypes.fluid[reason]
			e.custom_status = {
				diode = defines.entity_status_diode.red,
				label = { "entity-status.fork-wrong-fuel", proto and proto.localised_name or reason },
			}
		end
		g.stopped = reason
	end
end

local function register_generator(st, entity)
	local id = entity.unit_number
	local g = st.generators[id]
	if not g then
		g = { entity = entity }
		--- a copy (clone) or a lost state: our status on a stopped generator marks it as ours
		local cs = entity.custom_status
		if entity.disabled_by_script and cs and type(cs.label) == "table" and STATUS_KEYS[cs.label[1]] then
			g.stopped = "?"
		end
		st.generators[id] = g
	end
	check(g)
end

--- One step of the round robin: up to CHECKS_PER_STEP generators, wrapping around once
local function check_step(st)
	local gens = st.generators
	local key = st.cursor
	if key ~= nil and gens[key] == nil then key = nil end
	for _ = 1, math.min(CHECKS_PER_STEP, table_size(gens)) do
		local id, g = next(gens, key)
		if id == nil then id, g = next(gens, nil) end
		if id == nil then break end
		key = id
		if g.entity.valid then
			check(g)
		else
			gens[id] = nil
		end
	end
	st.cursor = key
end

--------------------------------------------------------------------------------
--- Registration
--------------------------------------------------------------------------------

local function register_turbine(st, entity)
	st.turbines[entity.unit_number] = st.turbines[entity.unit_number] or { entity = entity, debt = 0 }
end

function M.on_built(entity)
	init()
	if not (entity and entity.valid) then return end
	if turbine_names[entity.name] then register_turbine(state(), entity) end
	if fuels_of[entity.name] then register_generator(state(), entity) end
end

--- Existing generators after a mod change (state lost, new generators or new fuel lists): register
--- them all again and check their fuel right away
function M.on_configuration_changed()
	init()
	local names, seen = {}, {}
	for n, _ in pairs(turbine_names) do
		if prototypes.entity[n] and not seen[n] then names[#names + 1] = n; seen[n] = true end
	end
	for n, _ in pairs(fuels_of) do
		if not seen[n] then names[#names + 1] = n; seen[n] = true end
	end
	local st = state()
	for id, t in pairs(st.turbines) do
		if not (t.entity and t.entity.valid) then st.turbines[id] = nil end
	end
	for id, g in pairs(st.generators) do
		if not (g.entity and g.entity.valid) then
			st.generators[id] = nil
		elseif not fuels_of[g.entity.name] then
			--- no fuel list anymore: switch it back on if this script stopped it
			if g.stopped then
				g.entity.disabled_by_script = false
				g.entity.custom_status = nil
			end
			st.generators[id] = nil
		end
	end
	st.cursor = nil
	if #names == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = names }) do
			if turbine_names[e.name] then register_turbine(st, e) end
			if fuels_of[e.name] then register_generator(st, e) end
		end
	end
end

--------------------------------------------------------------------------------
--- Cooled fluid of the plasma turbines
--------------------------------------------------------------------------------

--- Output hatches touching the turbine's footprint
local function hatches_of(entity)
	local box = entity.selection_box
	return entity.surface.find_entities_filtered{
		name = hatch_name,
		area = { { box.left_top.x - 0.5, box.left_top.y - 0.5 }, { box.right_bottom.x + 0.5, box.right_bottom.y + 0.5 } },
	}
end

local function tick(st)
	for id, t in pairs(st.turbines) do
		local e = t.entity
		if not (e and e.valid) then
			st.turbines[id] = nil
		else
			local fb = e.fluidbox[1]
			if fb then t.fluid = fb.name end
			local out = t.fluid and cooled_of[t.fluid]
			if out then
				local generated = e.energy_generated_last_tick
				if generated > 0 then
					local fuel = prototypes.fluid[t.fluid].fuel_value
					if fuel and fuel > 0 then
						t.debt = math.min(MAX_DEBT, (t.debt or 0) + generated * INTERVAL / fuel)
					end
				end
				if (t.debt or 0) >= 0.001 then
					for _, h in pairs(hatches_of(e)) do
						local done = h.insert_fluid{ name = out, amount = t.debt }
						t.debt = t.debt - done
						if t.debt < 0.001 then break end
					end
				end
			end
		end
	end
end

script.on_nth_tick(INTERVAL, function()
	local st = storage.fork_power
	--- saves from before the fuel check (no configuration change when only the files changed):
	--- look for the generators once
	if not (st and st.generators) then
		M.on_configuration_changed()
		st = storage.fork_power
	end
	init()
	check_step(st)
	tick(st)
end)

--- For tests: the cooled fluid still owed by a turbine
remote.add_interface("gregtorio-power", {
	debt = function(entity)
		local t = storage.fork_power and storage.fork_power.turbines[entity.unit_number]
		return t and t.debt or 0
	end,
})

return M
