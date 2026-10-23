--------------------------------------------------------------------------------
--- FORK ENDER STORAGE (issue #504, plan #494 V8): EnderStorage's Ender Chest and Ender Tank of
--- prototypes/160-fork-dimension-mines.lua. Chests and tanks of a force with the same three-colour code share their
--- contents on every surface. The code is three of the 16 wool colours, left to right, 0 to 4095 (left x 256 + middle
--- x 16 + right); a new chest or tank has white, white, white (0).
---   * the Ender Chest is a linked-container: its link_id is the code, the engine shares the inventory;
---   * the Ender Tanks of a code are levelled every LEVEL_TICKS: the fluid of the group's first tank that holds one is
---     shared evenly by the tanks that hold it or none (at the weighted mean temperature); a tank with another fluid
---     stays out until it is empty.
--- The panel beside the chest's or tank's window (relative GUI) has three drop-downs for the colours; pasting settings
--- between two Ender Chests or two Ender Tanks copies the code. A blueprint (also copy and cut) keeps the code of
--- both as the entity tag fork_ender_code, which a build restores (issue #546: a ghost a player places from a blueprint
--- has lost the chest's link_id; a blueprint without the tag still gives the chest its link_id).
--- State: storage.fork_ender = { tanks = unit number -> { entity, code }, reg = registration -> unit number, open =
--- player index -> the chest or tank whose window is open };
--- remote fork-ender.set_code(entity, code), get_code(entity) and tag_blueprint(blueprint, mapping) (devcheck's runtime
--- test).
--------------------------------------------------------------------------------

local M = {}
local CHEST, TANK = "ender-chest", "ender-tank"
local LEVEL_TICKS = 20   -- (free: the molds take 30, the ore drills 60, the solar boilers 120, fork-power on_tick)
local PANEL = "fork-ender-panel"
local TAG = "fork_ender_code"
local COLOURS = { "white", "orange", "magenta", "light-blue", "yellow", "lime", "pink", "gray", "light-gray", "cyan",
	"purple", "blue", "brown", "green", "red", "black" }

local function state()
	storage.fork_ender = storage.fork_ender or { tanks = {}, reg = {}, open = {} }
	return storage.fork_ender
end

local function digits(code)
	return { math.floor(code / 256) % 16 + 1, math.floor(code / 16) % 16 + 1, code % 16 + 1 }
end

--- `tags`: the blueprint tags of a built ghost (issue #546: the code is in TAG)
function M.on_built(entity, tags)
	if not (entity and entity.valid and (entity.name == CHEST or entity.name == TANK)) then return end
	if entity.name == TANK then
		local st = state()
		if not st.tanks[entity.unit_number] then
			st.tanks[entity.unit_number] = { entity = entity, code = 0 }
			st.reg[script.register_on_object_destroyed(entity)] = entity.unit_number
		end
	end
	local code = type(tags) == "table" and tonumber(tags[TAG])
	if code and code >= 0 and code < 4096 and code % 1 == 0 then M.set_code(entity, code) end
end

function M.on_object_destroyed(event)
	local st = storage.fork_ender
	local unit = st and st.reg[event.registration_number]
	if not unit then return end
	st.reg[event.registration_number] = nil
	st.tanks[unit] = nil
end

function M.get_code(entity)
	if entity.name == CHEST then return entity.link_id % 4096 end
	local t = state().tanks[entity.unit_number]
	return t and t.code or 0
end

function M.set_code(entity, code)
	if entity.name == CHEST then
		entity.link_id = code
	elseif entity.name == TANK then
		M.on_built(entity)
		state().tanks[entity.unit_number].code = code
	end
end

--- the tanks of one code: the first fluid's tanks and the empty ones share it evenly
local function level(group)
	local name, total, heat, members = nil, 0, 0, {}
	for _, e in ipairs(group) do
		local f = e.get_fluid(1)
		if f and not name then name = f.name end
		if not f or f.name == name then
			members[#members + 1] = e
			if f then
				total = total + f.amount
				heat = heat + f.amount * (f.temperature or 0)
			end
		end
	end
	if not name or #members < 2 or total <= 0 then return end
	local each, temp = total / #members, heat / total
	for _, e in ipairs(members) do
		local f = e.get_fluid(1)
		if not f or math.abs(f.amount - each) > 1e-6 then
			e.set_fluid(1, { name = name, amount = each, temperature = temp })
		end
	end
end

script.on_nth_tick(LEVEL_TICKS, function()
	local st = storage.fork_ender
	if not st then return end
	local groups = {}
	for unit, t in pairs(st.tanks) do
		local e = t.entity
		if e.valid then
			local key = e.force.index .. ":" .. t.code
			groups[key] = groups[key] or {}
			table.insert(groups[key], e)
		else
			st.tanks[unit] = nil
		end
	end
	for _, group in pairs(groups) do
		if #group > 1 then level(group) end
	end
end)

--- the panel with the three colours beside the chest's or tank's window
function M.on_gui_opened(event)
	local e = event.entity
	if not (e and e.valid and (e.name == CHEST or e.name == TANK)) then return end
	local player = game.get_player(event.player_index)
	if player.gui.relative[PANEL] then player.gui.relative[PANEL].destroy() end
	local frame = player.gui.relative.add{ type = "frame", name = PANEL, direction = "vertical",
		caption = { "fork-ender.code" }, anchor = { position = defines.relative_gui_position.right,
			gui = e.name == CHEST and defines.relative_gui_type.linked_container_gui
				or defines.relative_gui_type.pipe_gui } }      -- (a storage tank's window since Factorio 2.1, issue #535)
	local items = {}
	for _, c in ipairs(COLOURS) do items[#items + 1] = { "fork-ender.colour-" .. c } end
	local d = digits(M.get_code(e))
	for i = 1, 3 do
		frame.add{ type = "drop-down", name = "fork-ender-colour-" .. i, items = items, selected_index = d[i],
			tags = { unit = e.unit_number } }
	end
	state().open[player.index] = e
end

function M.on_gui_closed(event)
	local player = game.get_player(event.player_index)
	if player and player.gui.relative[PANEL] then player.gui.relative[PANEL].destroy() end
	if storage.fork_ender then storage.fork_ender.open[event.player_index] = nil end
end

function M.on_gui_selection_state_changed(event)
	local el = event.element
	if not (el and el.valid and el.name:match("^fork%-ender%-colour%-%d$")) then return end
	local e = storage.fork_ender and storage.fork_ender.open[event.player_index]
	if not (e and e.valid) then return end
	local p = el.parent
	local c = {}
	for i = 1, 3 do c[i] = p["fork-ender-colour-" .. i].selected_index - 1 end
	M.set_code(e, c[1] * 256 + c[2] * 16 + c[3])
end

function M.on_entity_settings_pasted(event)
	local s, d = event.source, event.destination
	if s.valid and d.valid and s.name == d.name and (s.name == CHEST or s.name == TANK) then
		M.set_code(d, M.get_code(s))
	end
end

--- a blueprint pasted over a built chest or tank (a ghost keeps the tags itself)
function M.on_blueprint_settings_pasted(event)
	local e = event.entity
	if e and e.valid and e.type ~= "entity-ghost" then M.on_built(e, event.tags) end
end

--- the code of every chest and tank as blueprint entity tag; `bp` is the blueprint (item stack or record), `mapping`
--- blueprint entity index -> source entity
function M.tag_blueprint(bp, mapping)
	for index, e in pairs(mapping) do
		if e.valid and (e.name == CHEST or e.name == TANK) then bp.set_blueprint_entity_tag(index, TAG, M.get_code(e)) end
	end
end

local function blueprint_usable(bp)
	if not (bp and bp.valid) then return false end
	if bp.object_name == "LuaRecord" then return true end
	return bp.valid_for_read and bp.is_blueprint
end

--- a new blueprint, or the blueprint of the copy and cut tools (as me-network's fork-me-autocraft.lua finds it)
function M.on_player_setup_blueprint(event)
	local player = game.get_player(event.player_index)
	local bp = event.record or event.stack
	if not blueprint_usable(bp) and player then bp = player.blueprint_to_setup end
	if not blueprint_usable(bp) and player then bp = player.cursor_stack end
	if not blueprint_usable(bp) then return end
	--- the mapping can be stale when another mod changed the blueprint: never break blueprinting
	pcall(function() M.tag_blueprint(bp, event.mapping.get()) end)
end

remote.add_interface("fork-ender", {
	set_code = function(entity, code) M.set_code(entity, code) end,
	get_code = function(entity) return M.get_code(entity) end,
	tag_blueprint = function(bp, mapping) M.tag_blueprint(bp, mapping) end,
})

return M
