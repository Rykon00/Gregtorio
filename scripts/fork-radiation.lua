--------------------------------------------------------------------------------
--- FORK RADIATION (issue #621; prototypes/172-fork-radiation.lua, startup setting gregtorio-continued-radiation)
--- Every 60 ticks each player's character takes, for each radioactive item it carries (main inventory, trash, cursor),
--- GT's level x (the items / 64, at least 1) poison damage, unless its armor is one of the mod data's (the Hazmat Suit,
--- the late armors). Nothing runs with the setting off.
--------------------------------------------------------------------------------

local M = {}

local data_cache
local function md()
	if not data_cache then
		local d = prototypes.mod_data["fork-radiation"]
		data_cache = d and d.data or false
		if data_cache then
			data_cache.protect = {}
			for _, a in pairs(data_cache.armors) do data_cache.protect[a] = true end
		end
	end
	return data_cache
end

--- the damage `character` takes in one check (0: protected or nothing radioactive)
function M.dose(character)
	local d = md()
	if not (d and character and character.valid) then return 0 end
	local armor = character.get_inventory(defines.inventory.character_armor)
	local worn = armor and armor[1] and armor[1].valid_for_read and armor[1].name
	if worn and d.protect[worn] then return 0 end
	local counts = {}
	for _, id in pairs({ defines.inventory.character_main, defines.inventory.character_trash }) do
		local inv = character.get_inventory(id)
		if inv then
			for _, c in pairs(inv.get_contents()) do
				if d.items[c.name] then counts[c.name] = (counts[c.name] or 0) + c.count end
			end
		end
	end
	local cursor = character.player and character.player.cursor_stack
	if cursor and cursor.valid_for_read and d.items[cursor.name] then
		counts[cursor.name] = (counts[cursor.name] or 0) + cursor.count
	end
	local dose = 0
	for name, n in pairs(counts) do dose = dose + d.items[name] * math.max(n / 64, 1) end
	return dose
end

--- one check of `character`: the damage it took
function M.check(character)
	local dose = M.dose(character)
	if dose > 0 then character.damage(dose, "neutral", "poison") end
	return dose
end

script.on_nth_tick(60, function()
	if not md() then return end
	for _, player in pairs(game.connected_players) do
		if player.character and player.character.valid then M.check(player.character) end
	end
end)

--- for devcheck's runtime test: one check of a character
remote.add_interface("fork-radiation", { check = function(character) return M.check(character) end })

return M
