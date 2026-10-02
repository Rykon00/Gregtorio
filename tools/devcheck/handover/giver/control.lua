--- Hand-over prototype (docs/SPLIT.md, issue #83), the giver: stands for gregtorio-continued.
--- Version 1 (the old Gregtorio) builds ME-like state on the new map: entities of a prototype that moves to the
--- taker, an item with tags of a prototype that moves, storage tables with entity references, a table shared by
--- two tables (also across two storage tables), a render object id. Version 2 (the new Gregtorio) has no such code
--- any more: it only hands its storage tables over through the remote interface `zz-handover` (take) and clears
--- them, like the hand-over of gregtorio-continued to me-network. config.lua (written by devcheck.py) can skip one
--- table, to check that the taker notices.
local config = require("config")
local V = tonumber((script.active_mods[script.mod_name] or "1"):match("^(%d+)"))
local TABLES = { "fork_me_net", "fork_ae2", "fork_me_io", "fork_me_terminal" }

local function say(s) log("HANDOVER-ORDER giver " .. s .. " tick=" .. (game and game.tick or "-")) end

if V == 1 then
	script.on_init(function()
		say("on_init v1")
		local surface = game.surfaces[1]
		surface.request_to_generate_chunks({ 0, 0 }, 1)
		surface.force_generate_chunk_requests()
		local force = game.forces.player
		local d1 = surface.create_entity{ name = "zz-handover-drive", position = { 0.5, 0.5 }, force = force }
		local d2 = surface.create_entity{ name = "zz-handover-drive", position = { 3.5, 0.5 }, force = force }
		local chest = surface.create_entity{ name = "iron-chest", position = { 6.5, 0.5 }, force = force }
		--- items with tags of a prototype that moves to the taker: one in a moved entity, one in a vanilla chest
		for _, e in pairs({ d1, chest }) do
			local inv = e.get_inventory(defines.inventory.chest)
			inv.insert{ name = "zz-handover-cell", count = 1 }
			local stack = inv.find_item_stack("zz-handover-cell")
			stack.tags = { fork_me_cell = { items = { ["iron-plate"] = 100, ["copper-plate"] = 7 }, partition = { "iron-plate" } } }
			stack.custom_description = "100 iron, 7 copper"
		end
		local net = { id = 1, members = { [d1.unit_number] = true, [d2.unit_number] = true } }
		storage.fork_me_net = {
			nodes = {
				[d1.unit_number] = { entity = d1, kind = "drive", net = 1, adj = { [d2.unit_number] = true } },
				[d2.unit_number] = { entity = d2, kind = "drive", net = 1, adj = { [d1.unit_number] = true } },
			},
			nets = { [1] = net },
			drives = { [d1.unit_number] = { entity = d1, slots = { [1] = { name = "me-1k-storage-cell",
				items = { ["iron-plate"] = 5000, ["iron-gear-wheel"] = 12 }, fluids = { water = 1234.5 } } },
				leds = { rendering.draw_rectangle{ color = { 0, 1, 0 }, filled = true, surface = surface,
					left_top = { entity = d1, offset = { -0.2, -0.2 } }, right_bottom = { entity = d1, offset = { 0.2, 0.2 } } }.id } } },
			next_net = 2,
		}
		--- the same job table in two places, and a table of fork_me_net referenced from fork_me_io
		local job = { id = 7, item = "iron-gear-wheel", amount = 10, cpu = d2, pool = { ["iron-plate"] = 20 } }
		storage.fork_ae2 = { jobs = { [7] = job }, active = { job }, next_job = 8 }
		storage.fork_me_io = { interfaces = {}, net_ref = net }
		storage.fork_me_terminal = { [1] = { filter = "iron", sort = "amount" } }
	end)
	return
end

--- version 2: no ME code, only the hand-over
script.on_init(function() say("on_init v2") end)
script.on_load(function() say("on_load v2") end)
script.on_configuration_changed(function(d)
	local mine = d.mod_changes[script.mod_name]
	say("on_configuration_changed v2 (" .. (mine and ((mine.old_version or "new") .. " -> " .. (mine.new_version or "removed")) or "unchanged")
		.. "; handed over: " .. tostring(storage.handed_over) .. ")")
end)

remote.add_interface("zz-handover", {
	take = function()
		say("take")
		local out = {}
		for _, k in pairs(TABLES) do
			if k ~= config.skip then out[k] = storage[k] end
			storage[k] = nil
		end
		storage.handed_over = true
		return out
	end,
})
