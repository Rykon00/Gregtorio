--- Fork: the cooled fluid of the large plasma turbines (prototypes/136-fork-power.lua).
--- GT's large plasma turbine returns one unit of the cooled fluid per unit of plasma (helium
--- plasma -> helium). A Factorio generator has one fluid box and no output, so this script
--- credits every turbine with the plasma it burnt (energy generated / fuel value, sampled every
--- 10 ticks) and pushes the cooled fluid into turbine output hatches standing next to it. Without
--- a hatch, or when the hatches are full, the cooled fluid is lost (GT voids it as well); at most
--- 1000 units are kept waiting per turbine.
--- State (lazy, `storage.fork_power`): the turbines by unit number with their last plasma and the
--- amount of cooled fluid still owed. Rebuilt from the map on configuration changes.
local M = {}

local INTERVAL = 10
local MAX_DEBT = 1000

local function mod_data()
	local md = prototypes.mod_data["fork-power"]
	return md and md.data or { turbines = {}, cooled = {}, hatch = "turbine-output-hatch" }
end

local turbine_names, cooled_of, hatch_name
local function init()
	if turbine_names then return end
	local d = mod_data()
	turbine_names, cooled_of, hatch_name = {}, d.cooled or {}, d.hatch
	for _, n in pairs(d.turbines or {}) do turbine_names[n] = true end
end

local function state()
	storage.fork_power = storage.fork_power or { turbines = {} }
	return storage.fork_power
end

local function register(entity)
	local st = state()
	st.turbines[entity.unit_number] = st.turbines[entity.unit_number] or { entity = entity, debt = 0 }
end

function M.on_built(entity)
	init()
	if entity and entity.valid and turbine_names[entity.name] then register(entity) end
end

--- Existing turbines after a mod change (state lost or new): register them all again
function M.on_configuration_changed()
	init()
	local names = {}
	for n, _ in pairs(turbine_names) do names[#names + 1] = n end
	if #names == 0 then return end
	local st = state()
	for id, t in pairs(st.turbines) do
		if not (t.entity and t.entity.valid) then st.turbines[id] = nil end
	end
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = names }) do register(e) end
	end
end

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
	if not storage.fork_power then return end
	init()
	tick(storage.fork_power)
end)

--- For tests: the cooled fluid still owed by a turbine
remote.add_interface("gregtorio-power", {
	debt = function(entity)
		local t = storage.fork_power and storage.fork_power.turbines[entity.unit_number]
		return t and t.debt or 0
	end,
})

return M
