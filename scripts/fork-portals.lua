--------------------------------------------------------------------------------
--- FORK PORTALS (issue #501, plan #494 V5): the Nether Portal of prototypes/160-fork-dimension-mines.lua sends whoever
--- steps onto it to the other side, as GTNH's: from Nauvis to the Nether (planet gt-nether, its surface made at the
--- first use) and back, the Nether at 1:8 (x / 8, y / 8 there, x 8 back). On the other side the nearest portal within
--- SEARCH tiles (16 in the Nether, 128 on Nauvis, Minecraft's rule) is the way out; without one a portal is built on
--- free ground near the converted position. The traveller arrives just south of it, and a cooldown keeps them from
--- going straight back. A character takes its inventory along (teleport).
--- Event driven (on_player_changed_position), no tick handler; storage.fork_portals.cooldown per player.
--- remote.call("fork-portals", "travel", entity, portal) sends a character (devcheck's runtime test: headless runs
--- have no players) and returns the portal it arrived at.
--------------------------------------------------------------------------------

local M = {}
local PORTAL, NETHER, HOME = "nether-portal", "gt-nether", "nauvis"
local SCALE, COOLDOWN = 8, 120
local SEARCH = { [NETHER] = 16, [HOME] = 128 }

local function state()
	storage.fork_portals = storage.fork_portals or { cooldown = {} }
	return storage.fork_portals
end

--- the surface on the other side, and the position there
local function other_side(surface, position)
	if surface.name == HOME then
		local planet = game.planets[NETHER]
		local nether = planet and (planet.surface or planet.create_surface())
		return nether, { x = position.x / SCALE, y = position.y / SCALE }
	elseif surface.name == NETHER then
		return game.surfaces[HOME], { x = position.x * SCALE, y = position.y * SCALE }
	end
end

--- the portal on the other side: the nearest one within SEARCH, else a new one on free ground
local function exit_portal(surface, pos, force)
	local r = SEARCH[surface.name]
	surface.request_to_generate_chunks(pos, math.ceil(r / 32))
	surface.force_generate_chunk_requests()
	local best, dist
	for _, p in pairs(surface.find_entities_filtered{ name = PORTAL, position = pos, radius = r }) do
		local d = (p.position.x - pos.x) ^ 2 + (p.position.y - pos.y) ^ 2
		if not dist or d < dist then best, dist = p, d end
	end
	if best then return best end
	--- free ground for the portal and the one who arrives (the Nether's lava is not walkable)
	local at = surface.find_non_colliding_position("character", pos, 64, 1) or pos
	at = { x = math.floor(at.x) + 0.5, y = math.floor(at.y) + 0.5 }
	return surface.create_entity{ name = PORTAL, position = at, force = force, raise_built = true }
end

--- send the entity (a character, or a player's) through the portal; returns the exit portal
local function travel(entity, portal, player)
	local surface, pos = other_side(portal.surface, portal.position)
	if not surface then return end
	local out = exit_portal(surface, pos, portal.force)
	if not out then return end
	local land = surface.find_non_colliding_position("character", { out.position.x, out.position.y + 2.5 }, 16, 0.5)
		or { out.position.x, out.position.y + 2.5 }
	if player then player.teleport(land, surface) else entity.teleport(land, surface) end
	return out
end

function M.on_player_changed_position(event)
	local player = game.get_player(event.player_index)
	if not (player and player.character and player.surface) then return end
	local st = state()
	if (st.cooldown[player.index] or 0) > game.tick then return end
	local p = player.position
	local portal = player.surface.find_entities_filtered{ name = PORTAL, area = { { p.x - 0.1, p.y - 0.1 }, { p.x + 0.1, p.y + 0.1 } },
		limit = 1 }[1]
	if not portal then return end
	st.cooldown[player.index] = game.tick + COOLDOWN
	travel(player.character, portal, player)
end

remote.add_interface("fork-portals", {
	travel = function(entity, portal) return travel(entity, portal) end,
})

return M
