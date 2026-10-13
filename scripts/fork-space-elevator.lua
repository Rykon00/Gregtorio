--------------------------------------------------------------------------------
--- FORK SPACE ELEVATOR MODULES (issues #301, #302): a Space Elevator module works only next to a Space Elevator
--- whose motors are of the module's tier or higher, and an elevator carries as many modules as its motors allow
--- (gtnhintergalactic: TileEntitySpaceElevator.java, ElevatorUtil.java; the mod data `fork-space-elevator` of
--- prototypes/162-fork-space-elevator.lua names the elevators with their motor tier and slots and the modules with the
--- motor tier they need).
--- Next to: the module's box within REACH tiles of the elevator's box. A module goes to the elevator with the most free
--- slots that it may run on, the modules of a surface in the order of their unit numbers, so the same modules work after
--- every change. The others stop (disabled_by_script) with a status that says why.
--- No tick handler: the assignment of a surface is made again when an elevator or a module is built or removed
--- (on_object_destroyed of a registration made at build) and after a mod change. State: storage.fork_space_elevator.
--------------------------------------------------------------------------------

local M = {}
local REACH = 2

local elevators, modules     -- name -> { motor, slots } / { motor }
local function init()
	if elevators then return end
	local d = prototypes.mod_data["fork-space-elevator"]
	d = d and d.data or {}
	elevators, modules = d.elevators or {}, d.modules or {}
end

local function state()
	local st = storage.fork_space_elevator
	if not st then
		st = { reg = {} }
		storage.fork_space_elevator = st
	end
	return st
end

local function names(t)
	local out = {}
	for n in pairs(t) do
		if prototypes.entity[n] then out[#out + 1] = n end
	end
	return out
end

local function near(a, b)
	local ab, bb = a.bounding_box, b.bounding_box
	return ab.left_top.x - REACH < bb.right_bottom.x and bb.left_top.x - REACH < ab.right_bottom.x
		and ab.left_top.y - REACH < bb.right_bottom.y and bb.left_top.y - REACH < ab.right_bottom.y
end

local function stop(module, key)
	module.disabled_by_script = true
	module.custom_status = { diode = defines.entity_status_diode.red, label = { "entity-status." .. key } }
end

--- the assignment of one surface
local function assign(surface)
	if not (surface and surface.valid) then return end
	local enames, mnames = names(elevators), names(modules)
	if #mnames == 0 then return end
	local els = #enames > 0 and surface.find_entities_filtered{ name = enames } or {}
	local free = {}
	for _, e in pairs(els) do free[e.unit_number] = elevators[e.name].slots end
	local mods = surface.find_entities_filtered{ name = mnames }
	table.sort(mods, function(a, b) return a.unit_number < b.unit_number end)
	for _, m in pairs(mods) do
		local need = modules[m.name].motor
		local best, any_near, strong = nil, false, false
		for _, e in pairs(els) do
			if near(m, e) then
				any_near = true
				if elevators[e.name].motor >= need then
					strong = true
					if free[e.unit_number] > 0 and (not best or free[e.unit_number] > free[best.unit_number]) then best = e end
				end
			end
		end
		if best then
			free[best.unit_number] = free[best.unit_number] - 1
			m.disabled_by_script = false
			m.custom_status = nil
		elseif not any_near then
			stop(m, "fork-space-elevator-missing")
		elseif not strong then
			stop(m, "fork-space-elevator-motors")
		else
			stop(m, "fork-space-elevator-full")
		end
	end
end

local function watch(entity)
	local st = state()
	st.reg[script.register_on_object_destroyed(entity)] = entity.surface.index
end

function M.on_built(entity)
	init()
	if not (entity and entity.valid) then return end
	if elevators[entity.name] or modules[entity.name] then
		watch(entity)
		assign(entity.surface)
	end
end

function M.on_object_destroyed(event)
	local st = storage.fork_space_elevator
	local index = st and st.reg[event.registration_number]
	if not index then return end
	st.reg[event.registration_number] = nil
	init()
	assign(game.surfaces[index])
end

--- after a mod change: watch every elevator and module again and assign every surface
function M.on_configuration_changed()
	init()
	local all = names(elevators)
	for _, n in pairs(names(modules)) do all[#all + 1] = n end
	if #all == 0 then return end
	state().reg = {}
	for _, surface in pairs(game.surfaces) do
		for _, e in pairs(surface.find_entities_filtered{ name = all }) do watch(e) end
		assign(surface)
	end
end

return M
