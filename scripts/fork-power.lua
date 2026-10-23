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
--- ticks of its output and at most fluid_usage_per_tick units per tick (1, the UEV to UXV plasma
--- turbines 2 to 9): steam at most 10 units (1 MJ), in a UXV turbine 90 units (9 MJ), a naquadah
--- fuel in a UV plasma turbine at most 54.6 MJ, a plasma in a UXV reactor at most 10 units. A generator that ran dry is stopped before the next fluid arrives, so
--- the window needs the segment emptied and refilled between two checks.
--- Work per step: at most CHECKS_PER_STEP generators (round robin); up to that many generators
--- each one is checked every step.
---
--- Cooled fluid (issue #28). GT's large plasma turbine returns one unit of the cooled fluid per unit
--- of plasma (helium plasma -> helium). A Factorio generator has one fluid box and no output, so this
--- script works it out from the energy: a generator with effectivity 1 burns exactly energy / fuel
--- value of its fluid. Every tick the energy each running turbine generated (energy_generated_last_tick,
--- which is 0 while it idles or runs dry) is added up; every INTERVAL ticks the sum is turned into
--- plasma burnt and owed as cooled fluid, and the owed fluid is pushed into turbine output hatches
--- standing next to the turbine. A plasma change between two steps (the turbine ran dry and got another
--- fluid without being seen empty) credits the old plasma with at most the amount it had at the start
--- of the step and the rest of the step's energy to the new fluid. What does not fit (hatches full or
--- holding another fluid) stays owed for the next step, without a limit; without any hatch next to the
--- turbine the cooled fluid is lost (GT voids it as well). Turbines stopped by a script (the fuel check
--- below) are not counted: a stopped generator keeps its last energy_generated_last_tick.
--- Issue #97: the steam turbines of 145 use the same machinery. The mod data gives a ratio per burnt
--- fluid (distilled water: 0.0625 per unit of steam; default 1) and the effectivity of a turbine (the
--- steam turbines burn energy / (fuel value x effectivity); default 1).
--- Accuracy: exact up to float rounding of the fluid amounts (devcheck: about 1e-6 relative); only a
--- plasma change within one step can shift at most that step's burn between the two plasmas.
--- Work per tick: one read per running turbine; the fluid is read once per step.
---
--- Supercapacitor loss (issue #97). GT's lapotronic supercapacitor loses 1 % of its capacity per day. The
--- accumulators listed in the mod data `capacitors` (name -> loss in W) lose loss x INTERVAL / 60 J every
--- INTERVAL ticks, down to 0. Work per step: one read and one write per supercapacitor; nothing per tick.
---
--- Upgrade (issue #124). The game does not carry an accumulator's energy over to the entity that replaces it (fast replace,
--- the upgrade planner), so every step also notes name and energy of each supercapacitor at its spot (`at`); a supercapacitor
--- built where another tier stood at most one step ago gets that energy, capped at its own capacity (a downgrade loses what
--- does not fit, as a full accumulator does). The note is up to one step old: the energy of that step, at most 13.6 MJ of the 25
--- GJ of a ZPM one, is lost. One that was mined and replaced later starts empty.
---
--- LFTR dynamos (issue #386). GT++'s Liquid Fluoride Thorium Reactor takes no power and gives power while a run is on
--- (MTENuclearReactor.java); Factorio's crafting machines cannot give power, so each reactor (mod data `lftr`: entity ->
--- recipe -> watts) gets a hidden electric energy interface (`lftr_dynamo`) at its place, made when it is built (or found
--- again after a configuration change) and removed with it. Every INTERVAL ticks the interface produces the watts of the
--- reactor's recipe while the reactor's status is "working", else nothing; what the network does not take is lost, as
--- GT voids it. Work per step: one status read per reactor, a write only when the power changes.
---
--- State (lazy, `storage.fork_power`): `turbines` by unit number with the plasma seen at the last step
--- (`fluid`, `amount` in the turbine and its segment), `on` (counted this step), the `energy` summed
--- since the last step and the cooled fluid still `owed` (by fluid name); `generators` by unit number
--- with the reason this script stopped them (nil while running); `cursor` of the round robin; `capacitors` by unit
--- number (the entity). Rebuilt
--- from the map on configuration changes.
local M = {}

local INTERVAL = 10
local CHECKS_PER_STEP = 200
local MIN_INSERT = 1e-6                 -- insert_fluid refuses tiny amounts; less stays owed
local NO_FUEL = ""                      -- `stopped` reason of an empty generator (else the fluid name)
local STATUS_KEYS = { ["entity-status.fork-wrong-fuel"] = true, ["entity-status.fork-no-fuel"] = true }

local function mod_data()
	local md = prototypes.mod_data["fork-power"]
	return md and md.data or { turbines = {}, cooled = {}, hatch = "turbine-output-hatch", fuels = {} }
end

local turbine_names, cooled_of, ratio_of, effectivity_of, hatch_name, fuels_of, loss_of, lftr_power, dynamo_name
local function init()
	if turbine_names then return end
	local d = mod_data()
	lftr_power, dynamo_name = {}, d.lftr_dynamo
	for name, recipes in pairs(d.lftr or {}) do
		if prototypes.entity[name] then lftr_power[name] = recipes end
	end
	turbine_names, cooled_of, hatch_name, fuels_of = {}, d.cooled or {}, d.hatch, {}
	ratio_of, effectivity_of, loss_of = d.ratio or {}, d.effectivity or {}, {}
	for name, w in pairs(d.capacitors or {}) do
		if prototypes.entity[name] then loss_of[name] = w end
	end
	for _, n in pairs(d.turbines or {}) do turbine_names[n] = true end
	for gen, list in pairs(d.fuels or {}) do
		if prototypes.entity[gen] then
			fuels_of[gen] = {}
			for _, f in pairs(list) do fuels_of[gen][f] = true end
		end
	end
end

--- the place of a supercapacitor: surface and centre
local function spot(entity)
	local p = entity.position
	return entity.surface.index .. ":" .. p.x .. ":" .. p.y
end

local function state()
	local st = storage.fork_power
	if not st then
		st = { turbines = {} }
		storage.fork_power = st
	end
	st.generators = st.generators or {}         -- saves from before the fuel check
	st.capacitors = st.capacitors or {}         -- saves from before issue #97
	st.lftrs = st.lftrs or {}                   -- issue #386
	return st
end

--------------------------------------------------------------------------------
--- Fuel check
--------------------------------------------------------------------------------

--- The fluid in the generator (its own part of the fluid box, else its pipeline segment) and, with
--- `amount`, how much of it the generator and its segment hold
local function fluid_of(entity, amount)
	local f = entity.get_fluid(1)
	--- (issue #535: LuaFluidBox is gone since Factorio 2.1; a segment holds one fluid, and its amount is the whole segment's,
	--- the generator's part with it, where 2.0's segment contents were the rest besides get_fluid_count)
	local seg = (amount or not f) and entity.has_fluid_segment(1) and entity.get_fluid_segment_fluid(1)
	if f then
		return f.name, amount and (seg and seg.name == f.name and seg.amount or f.amount)
	end
	if seg and seg.amount > 0 then return seg.name, seg.amount end
	return nil, 0
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

--- Saves from before issue #28 kept one number (`debt`) owed for the last plasma
local function upgrade_turbine(t)
	if t.energy then return end
	t.energy, t.owed = 0, {}
	local out = t.fluid and cooled_of[t.fluid]
	if out and (t.debt or 0) > 0 then t.owed[out] = t.debt end
	t.debt = nil
end

local function register_turbine(st, entity)
	local t = st.turbines[entity.unit_number]
	if not t then
		t = { entity = entity, energy = 0, owed = {} }
		st.turbines[entity.unit_number] = t
	end
	upgrade_turbine(t)
	local fluid, amount = fluid_of(entity, true)
	t.fluid, t.amount = fluid or t.fluid, amount
	t.on = t.fluid ~= nil and not entity.disabled_by_script
end

--------------------------------------------------------------------------------
--- LFTR dynamos
--------------------------------------------------------------------------------

local function register_lftr(st, entity)
	local l = st.lftrs[entity.unit_number]
	if l and l.dynamo and l.dynamo.valid then return end
	local surface, position = entity.surface, entity.position
	local dynamo = surface.find_entities_filtered{ name = dynamo_name, position = position, limit = 1 }[1]
		or surface.create_entity{ name = dynamo_name, position = position, force = entity.force }
	if dynamo then dynamo.power_production = 0 end
	st.lftrs[entity.unit_number] = { entity = entity, dynamo = dynamo, power = 0 }
end

local function lftr_step(st)
	for id, l in pairs(st.lftrs) do
		local e, d = l.entity, l.dynamo
		if not (e and e.valid) then
			if d and d.valid then d.destroy() end
			st.lftrs[id] = nil
		elseif not (d and d.valid) then
			l.dynamo = nil
			register_lftr(st, e)
		else
			local power = 0
			if e.status == defines.entity_status.working then
				local recipe = e.get_recipe()
				local watts = recipe and lftr_power[e.name] and lftr_power[e.name][recipe.name]
				if watts then power = watts / 60 end
			end
			if l.power ~= power then
				d.power_production = power
				l.power = power
			end
		end
	end
end

function M.on_built(entity)
	init()
	if not (entity and entity.valid) then return end
	if lftr_power[entity.name] then register_lftr(state(), entity) end
	if turbine_names[entity.name] then register_turbine(state(), entity) end
	if fuels_of[entity.name] then register_generator(state(), entity) end
	if loss_of[entity.name] then
		local st = state()
		st.capacitors[entity.unit_number] = entity
		--- a supercapacitor of another tier that stood here a moment ago: its energy goes on
		local at = st.at and st.at[spot(entity)]
		if at and at.name ~= entity.name and game.tick - at.tick <= INTERVAL then
			entity.energy = math.min(at.energy, entity.electric_buffer_size)
		end
		if st.at then st.at[spot(entity)] = nil end
	end
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
	for n, _ in pairs(loss_of) do
		if not seen[n] then names[#names + 1] = n; seen[n] = true end
	end
	for n, _ in pairs(lftr_power) do
		if not seen[n] then names[#names + 1] = n; seen[n] = true end
	end
	local st = state()
	--- LFTR dynamos: drop the gone reactors' and any interface without its reactor
	for id, l in pairs(st.lftrs) do
		if not (l.entity and l.entity.valid and lftr_power[l.entity.name]) then
			if l.dynamo and l.dynamo.valid then l.dynamo.destroy() end
			st.lftrs[id] = nil
		end
	end
	if dynamo_name and prototypes.entity[dynamo_name] then
		for _, surface in pairs(game.surfaces) do
			for _, d in pairs(surface.find_entities_filtered{ name = dynamo_name }) do
				local owner = surface.find_entities_filtered{ type = "assembling-machine", position = d.position, limit = 1 }[1]
				if not (owner and lftr_power[owner.name]) then d.destroy() end
			end
		end
	end
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
	st.capacitors = {}
	if #names == 0 then return end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = names }) do
			if turbine_names[e.name] then register_turbine(st, e) end
			if fuels_of[e.name] then register_generator(st, e) end
			if loss_of[e.name] then st.capacitors[e.unit_number] = e end
			if lftr_power[e.name] then register_lftr(st, e) end
		end
	end
end

--------------------------------------------------------------------------------
--- Supercapacitor loss
--------------------------------------------------------------------------------

local function capacitor_step(st)
	st.at = st.at or {}                         -- saves from before issue #124
	local now = game.tick
	for key, at in pairs(st.at) do
		if now - at.tick > 2 * INTERVAL then st.at[key] = nil end
	end
	for id, e in pairs(st.capacitors) do
		if e.valid then
			local loss = loss_of[e.name]
			if loss then
				local energy = e.energy - loss * INTERVAL / 60
				e.energy = energy > 0 and energy or 0
				st.at[spot(e)] = { name = e.name, energy = e.energy, tick = now }
			end
		else
			st.capacitors[id] = nil
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

--- Owe the cooled fluid for `energy` J burnt on `fluid`, at most `max` units of plasma; returns the
--- energy left over
local function credit(t, fluid, energy, max)
	local proto = fluid and prototypes.fluid[fluid]
	local fuel = proto and proto.fuel_value
	if not (fuel and fuel > 0) then return energy end   -- not a fuel: it burnt none of it
	fuel = fuel * (effectivity_of[t.entity.name] or 1)  -- the energy one unit gives in this turbine
	local burnt = energy / fuel
	if max and burnt > max then burnt = max end
	local out = cooled_of[fluid]
	if out and burnt > 0 then t.owed[out] = (t.owed[out] or 0) + burnt * (ratio_of[fluid] or 1) end
	return energy - burnt * fuel
end

--- Every INTERVAL ticks: turn the energy of the step into cooled fluid, push it into the hatches and
--- look at the fluid for the next step
local function step(st)
	for id, t in pairs(st.turbines) do
		local e = t.entity
		if not (e and e.valid) then
			st.turbines[id] = nil
		else
			upgrade_turbine(t)
			local fluid, amount = fluid_of(e, true)
			if t.energy > 0 then
				if fluid and t.fluid and fluid ~= t.fluid then
					--- another fluid since the last step: the old plasma burnt at most what was there
					credit(t, fluid, credit(t, t.fluid, t.energy, t.amount or 0))
				else
					credit(t, fluid or t.fluid, t.energy)
				end
				t.energy = 0
			end
			if fluid then t.fluid = fluid end
			t.amount = amount
			t.on = t.fluid ~= nil and not e.disabled_by_script
			if next(t.owed) then
				local hatches = hatches_of(e)
				if #hatches == 0 then
					t.owed = {}                      -- no hatch: lost, as in GT
				else
					for out, n in pairs(t.owed) do
						for _, h in pairs(hatches) do
							if n < MIN_INSERT then break end
							n = n - h.insert_fluid{ name = out, amount = n }
						end
						t.owed[out] = n > 0 and n or nil
					end
				end
			end
		end
	end
end

script.on_event(defines.events.on_tick, function(event)
	local st = storage.fork_power
	--- every tick: the energy of the running turbines (0 while idle or dry)
	if st then
		for _, t in pairs(st.turbines) do
			if t.on then
				local e = t.entity
				if e.valid then t.energy = t.energy + e.energy_generated_last_tick end
			end
		end
	end
	if event.tick % INTERVAL ~= 0 then return end
	--- saves from before the fuel check (no configuration change when only the files changed):
	--- look for the generators once
	if not (st and st.generators) then
		M.on_configuration_changed()
		st = storage.fork_power
	end
	init()
	check_step(st)
	step(st)
	if st.lftrs then lftr_step(st) end
	if st.capacitors then capacitor_step(st) end
end)

--- For tests: the cooled fluid still owed by a turbine (of one fluid, or all of them), and the energy
--- counted since the last step
remote.add_interface("gregtorio-power", {
	debt = function(entity, fluid)
		local t = storage.fork_power and storage.fork_power.turbines[entity.unit_number]
		if not t then return 0 end
		if fluid then return t.owed[fluid] or 0 end
		local n = 0
		for _, v in pairs(t.owed) do n = n + v end
		return n
	end,
	energy = function(entity)
		local t = storage.fork_power and storage.fork_power.turbines[entity.unit_number]
		return t and t.energy or 0
	end,
})

return M
