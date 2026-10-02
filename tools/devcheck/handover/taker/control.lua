--- Hand-over prototype (docs/SPLIT.md, issue #83), the taker: stands for me-network. In on_init (the mod is new in
--- the save) it pulls the giver's tables through the remote interface `zz-handover`, keeps them in its own storage
--- and checks what came over (HANDOVER-CHECK lines, HANDOVER-RESULT ok/failed). It logs the order of the lifecycle
--- events (HANDOVER-ORDER), and tries the render object of the giver.
local TABLES = { "fork_me_net", "fork_ae2", "fork_me_io", "fork_me_terminal" }

local function say(s) log("HANDOVER-ORDER taker " .. s .. " tick=" .. (game and game.tick or "-")) end

local function check()
	local bad = {}
	local function expect(ok, what) if not ok then bad[#bad + 1] = what end end
	local s = storage
	for _, k in pairs(TABLES) do expect(s[k] ~= nil, "table " .. k .. " handed over") end
	if #bad > 0 then return bad end
	--- entity references: valid, the same entity (unit number), of the prototype that now belongs to the taker
	local n = 0
	for unit, node in pairs(s.fork_me_net.nodes) do
		n = n + 1
		expect(node.entity and node.entity.valid and node.entity.unit_number == unit, "node " .. unit .. " entity valid")
		expect(node.entity.prototype.name == "zz-handover-drive", "node " .. unit .. " prototype")
	end
	expect(n == 2, "two nodes")
	--- the shared tables are still shared (a copy would split them)
	expect(rawequal(s.fork_ae2.jobs[7], s.fork_ae2.active[1]), "job shared by jobs and active")
	expect(rawequal(s.fork_me_io.net_ref, s.fork_me_net.nets[1]), "network shared by fork_me_io and fork_me_net")
	expect(s.fork_ae2.jobs[7].cpu and s.fork_ae2.jobs[7].cpu.valid, "job cpu entity valid")
	--- numbers keep their exact values (fluid amounts are fractional)
	local d = s.fork_me_net.drives
	local drive
	for _, x in pairs(d) do drive = x end
	expect(drive and drive.slots[1].items["iron-plate"] == 5000 and drive.slots[1].fluids.water == 1234.5, "cell contents")
	--- items with tags of a moved item prototype, in a moved entity and in a vanilla chest
	for _, e in pairs({ drive.entity, game.surfaces[1].find_entity("iron-chest", { 6.5, 0.5 }) }) do
		local stack = e and e.get_inventory(defines.inventory.chest).find_item_stack("zz-handover-cell")
		local t = stack and stack.tags.fork_me_cell
		expect(t and t.items["iron-plate"] == 100 and t.items["copper-plate"] == 7 and t.partition[1] == "iron-plate"
			and stack.custom_description == "100 iron, 7 copper", "item with tags in " .. (e and e.name or "?"))
	end
	--- the giver's render object: can the taker see and destroy it?
	local id = drive.leds[1]
	local obj = rendering.get_object_by_id(id)
	log("HANDOVER-CHECK render object of the giver: " .. (obj and obj.valid and "visible" or "not visible"))
	if obj and obj.valid then
		local ok, err = pcall(function() obj.destroy() end)
		log("HANDOVER-CHECK destroy the giver's render object: " .. (ok and "ok" or ("refused: " .. tostring(err))))
	end
	return bad
end

script.on_init(function()
	say("on_init")
	if remote.interfaces["zz-handover"] then
		local t = remote.call("zz-handover", "take")
		for k, v in pairs(t) do storage[k] = v end
		local bad = check()
		for _, b in pairs(bad) do log("HANDOVER-CHECK failed: " .. b) end
		log("HANDOVER-RESULT " .. (#bad == 0 and "ok" or "failed"))
	else
		log("HANDOVER-RESULT nothing to take")
	end
end)
script.on_load(function() say("on_load") end)
script.on_configuration_changed(function(d)
	local mine = d.mod_changes[script.mod_name]
	say("on_configuration_changed (" .. (mine and ((mine.old_version or "new") .. " -> " .. (mine.new_version or "removed")) or "unchanged")
		.. "; state there: " .. tostring(storage.fork_me_net ~= nil) .. ")")
end)
