--- Issue #588: brings a main menu scene's save up to date and shrinks it in the headless game.
--- `devcheck.py menusim --sim <name> --rebuild` loads the scene's save in a headless server with today's mods (their
--- migrations and on_configuration_changed bring it up to date), sends this file as one Lua command over RCON and saves
--- the map when the server quits. devcheck.py puts `local MARGIN = <n>` in front of this file.
---  * It keeps the chunks that hold a building of the player force (the camera's view and the factory that feeds it:
---    steam, ore and fuel come from outside the view) plus MARGIN chunks around them and deletes every other chunk.
---  * It deletes the blueprint library of every player in the save (all are offline on the server): a map made in the
---    editor keeps its builder's library in the save, the largest part of it.
---  * It removes the players of the save (issue #599: the menu drew the builder's quickbar and shortcut bar over the
---    scene; Factorio's own menu saves have no player).
---  * It switches the replay off (devcheck.py then drops the replay's start state, level-init.dat and
---    script-init.dat, from the zip: the engine keeps them in every save).
--- Prints, for devcheck.py, the counts by name of the player force's entities (not the characters: a player's
--- character is on the map only while the player is connected) and the chunks before and kept.
local surface = game.surfaces.nauvis

local counts = {}
local keep = {}
for _, e in pairs(surface.find_entities_filtered({ force = "player" })) do
	if e.type ~= "character" then counts[e.name] = (counts[e.name] or 0) + 1 end
	local b = e.bounding_box
	for cx = math.floor(b.left_top.x / 32) - MARGIN, math.floor((b.right_bottom.x - 0.01) / 32) + MARGIN do
		for cy = math.floor(b.left_top.y / 32) - MARGIN, math.floor((b.right_bottom.y - 0.01) / 32) + MARGIN do
			keep[cx .. "," .. cy] = true
		end
	end
end
local chunks, kept = 0, 0
for c in surface.get_chunks() do
	chunks = chunks + 1
	if keep[c.x .. "," .. c.y] then
		kept = kept + 1
	else
		surface.delete_chunk({ c.x, c.y })
	end
end
local libraries, players = 0, #game.players
for _, p in pairs(game.players) do
	libraries = libraries + #p.blueprints
	game.delete_blueprint_library(p)
end
-- issue #599: the menu draws the GUI of a player in the save (quickbar, shortcut bar) over the scene
game.remove_offline_players()
game.disable_replay()
rcon.print(helpers.table_to_json({ entities = counts, chunks = chunks, kept = kept, blueprint_records = libraries,
	players = players }))
