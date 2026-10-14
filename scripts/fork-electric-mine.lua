--- Issue #342: a mine that replaces another keeps its vein. Manual Mine, Miners and Ore Drilling Plants share a fast
--- replace group and an upgrade chain (prototypes/163-fork-electric-mine.lua), but each has its own recipe category, so the
--- engine resets the recipe on a replace. The vein of the old machine is noted before the replace and set on the new one
--- as the recipe of the new machine's category (mod data `fork-electric-mine`: recipe -> vein, vein -> recipe per
--- category):
---   * a player's fast replace: on_pre_build, before the build, at the build position;
---   * the upgrade planner (robots, a blueprint over mines): on_marked_for_upgrade, with the target, kept until the target
---     is built there or the upgrade is cancelled;
---   * any mining that removes the old machine (a replace may raise it): on_pre_player_mined_item, on_robot_pre_mined;
---   * other scripts: remote.call("fork-electric-mine", "note_replace", entity) before they replace a mine.
--- The new machine takes the note of its position only in the same tick or when it is the marked target, and only if it
--- has no recipe yet (a blueprint's recipe wins) and its force has the recipe; a note is removed when it is used. A vein
--- without a twin (FORK_ELECTRIC_MINE_EXCLUDED: hunting, the dig site) leaves the new machine without a recipe.
--- Event driven, no tick handler; the notes are lazy state (`storage.fork_electric_mine`).
local M = {}

local function mine_data()
	local md = prototypes.mod_data["fork-electric-mine"]
	return md and md.data
end

local function notes()
	storage.fork_electric_mine = storage.fork_electric_mine or { notes = {} }
	return storage.fork_electric_mine.notes
end

local function key(entity)
	local p = entity.position
	return entity.surface.index .. ":" .. p.x .. ":" .. p.y
end

--- note the vein of a mine about to be replaced (target: the machine it is marked to become, if any)
local function note(entity, target)
	local d = mine_data()
	if not (d and entity and entity.valid and d.machines[entity.name]) then return end
	local list, k = notes(), key(entity)
	local recipe = entity.get_recipe()
	local vein = recipe and d.veins[recipe.name]
	if not vein then
		list[k] = nil
		return
	end
	local old = list[k]
	list[k] = { vein = vein, tick = game.tick, target = target or (old and old.target) }
end

function M.on_pre_build(event)
	local player = game.get_player(event.player_index)
	if not player then return end
	for _, e in pairs(player.surface.find_entities_filtered{ position = event.position, radius = 0.5,
		type = "assembling-machine" }) do
		note(e)
	end
end

function M.on_marked_for_upgrade(event)
	note(event.entity, event.target and event.target.name)
end

function M.on_cancelled_upgrade(event)
	local e = event.entity
	if e and e.valid and storage.fork_electric_mine then notes()[key(e)] = nil end
end

function M.on_pre_mined(event)
	note(event.entity)
end

function M.on_built(entity)
	local d = mine_data()
	if not (d and storage.fork_electric_mine and entity.valid and d.machines[entity.name]) then return end
	local list, k = notes(), key(entity)
	local n = list[k]
	if not n then return end
	if n.tick ~= game.tick and n.target ~= entity.name then return end
	list[k] = nil
	if entity.get_recipe() then return end
	local by_category = d.recipes[n.vein] or {}
	for category in pairs(entity.prototype.crafting_categories) do
		local recipe = by_category[category]
		local r = recipe and entity.force.recipes[recipe]
		if r and r.enabled then
			entity.set_recipe(recipe)
			return
		end
	end
end

remote.add_interface("fork-electric-mine", {
	--- call before replacing a Manual Mine, Miner or Ore Drilling Plant by script in the same tick
	note_replace = function(entity) note(entity) end,
})

return M
