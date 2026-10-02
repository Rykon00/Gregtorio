--------------------------------------------------------------------------------
--- FORK: the one-time hand-over of the ME network's state to the mod me-network (issue #83, docs/SPLIT.md)
---
--- Up to 0.4.x the ME network was part of this mod, so a save keeps its script state in this mod's storage
--- (script state is kept per mod). Since issue #83 the network is the mod me-network, which this mod depends on.
--- me-network takes the state once, in its on_init (it is new in such a save; the engine runs a new mod's on_init
--- before the other mods' on_load and on_configuration_changed), through the remote interface
--- "gregtorio-me-handover":
---   pending()  whether this mod still holds ME state
---   take()     the ME tables (one table, so shared tables stay shared), cleared here; this mod's ME windows are
---              closed (GUI elements belong to the mod that made them) and its render objects (only the drive
---              lights) destroyed. Each table comes with a fingerprint; me-network compares it with what it got.
--- Kept for old saves; nothing else of the ME network is left in this mod.
--------------------------------------------------------------------------------

local TABLES = { "fork_me_net", "fork_me_io", "fork_me_sbus", "fork_me_fsbus", "fork_ae2", "fork_me_fluids",
	"fork_me_terminal", "fork_me_gui_bypass", "fork_me_migrate", "fork_me_migrate_fluids" }

--- the same function is in me-network's scripts/fork-me-handover.lua: keep them equal
local function fingerprint(root)
	local ids, n = {}, 0
	local h1, h2, len = 0, 0, 0
	local function feed(s)
		len = len + #s
		for i = 1, #s do
			local b = s:byte(i)
			h1 = (h1 * 31 + b) % 4294967291
			h2 = (h2 * 131 + b) % 2147483629
		end
	end
	local function scalar(v)
		local t = type(v)
		if t == "number" then return "n" .. string.format("%.17g", v) end
		if t == "string" then return "s" .. #v .. ":" .. v end
		if t == "boolean" then return v and "T" or "F" end
		if t == "userdata" then
			local ok, name = pcall(function() return v.object_name end)
			if ok and name == "LuaEntity" then
				if not v.valid then return "E-invalid" end
				return "E" .. (v.unit_number or (v.name .. "@" .. v.position.x .. "," .. v.position.y))
			end
			return "U" .. tostring(ok and name or "?")
		end
		return "?" .. t
	end
	local walk
	walk = function(v)
		if type(v) ~= "table" then feed(scalar(v)) return end
		if ids[v] then feed("R" .. ids[v]) return end
		n = n + 1
		ids[v] = n
		local keys = {}
		for k in pairs(v) do
			keys[#keys + 1] = { k = k, s = type(k) == "table" and "t" or scalar(k) }
		end
		table.sort(keys, function(a, b) return a.s < b.s end)
		feed("{")
		for _, k in pairs(keys) do
			if type(k.k) == "table" then walk(k.k) else feed(k.s) end
			feed("=")
			walk(v[k.k])
			feed(";")
		end
		feed("}")
	end
	if root == nil then return "nil" end
	walk(root)
	return string.format("%d/%d/%d/%d", len, n, h1, h2)
end

local function pending()
	for _, k in pairs(TABLES) do
		if storage[k] ~= nil then return true end
	end
	return false
end

--- the window frames of the ME blocks (since R3) and of the panels before it
local FRAMES = { "fork_me_window", "fork_me_terminal", "fork_me_drive", "fork_me_bus", "fork_ae2_provider",
	"fork_me_maintainer", "fork_me_circuit", "fork_me_fluid_interface" }

local function take()
	local tables, fingerprints = {}, {}
	for _, k in pairs(TABLES) do
		tables[k] = storage[k]
		fingerprints[k] = fingerprint(storage[k])
		log("FORK-ME-HANDOVER: gave " .. k .. " " .. fingerprints[k])
		storage[k] = nil
	end
	for _, player in pairs(game.players) do
		for _, root in pairs({ player.gui.screen, player.gui.relative }) do
			for _, name in pairs(FRAMES) do
				if root[name] then root[name].destroy() end
			end
		end
	end
	rendering.clear(script.mod_name)
	storage.fork_me_handed_over = game.tick
	return { tables = tables, fingerprints = fingerprints,
		from = script.mod_name .. " " .. script.active_mods[script.mod_name] }
end

remote.add_interface("gregtorio-me-handover", { pending = pending, take = take })

local M = {}

--- me-network takes the state in its on_init, before this runs: state still here was not taken (it stays here,
--- nothing is lost), so say so in the log.
function M.on_configuration_changed()
	if pending() then
		log("FORK-ME-HANDOVER: the ME state of this save was not taken by me-network; it stays in gregtorio-continued")
	end
end

return M
