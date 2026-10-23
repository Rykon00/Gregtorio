--------------------------------------------------------------------------------
--- FORK PORTALS (issue #501, plan #494 V5; issue #502, V6): the portals of prototypes/160-fork-dimension-mines.lua send
--- whoever steps onto them to the other side, as GTNH's: the Nether Portal from Nauvis to the Nether (planet gt-nether)
--- and back, the Nether at 1:8 (x / 8, y / 8 there, x 8 back); the Twilight Portal from Nauvis to the Twilight Forest
--- (planet gt-twilight) and back, at 1:1; issue #503 (V7): the End Portal from Nauvis to the main island of The End
--- (planet gt-end; the exit portal at the origin, as Minecraft's fixed arrival) and back to the portal the traveller came
--- through (storage.fork_portals.came_from; without one, the End Portal nearest to Nauvis' spawn or a new one there).
--- A portal works on Nauvis and on its own side only (GTNH's
--- AllowPortalsInOtherDimensions=false). The other side's surface is made at the first use. On the other side the
--- nearest portal of the same kind within its search radius (the Nether's 16 and Nauvis' 128 tiles, Minecraft's rule;
--- 128 for the Twilight Forest) is the way out; without one a portal is built on free ground near the converted
--- position. The traveller arrives just south of it, and a cooldown keeps them from going straight back. A character
--- takes its inventory along (teleport).
--- The Twilight Forest has permanent dusk, The End permanent night: their surface's daytime is frozen when it is made.
--- Event driven (on_player_changed_position), no tick handler; storage.fork_portals.cooldown per player, came_from per
--- player (or per character without one: "c" .. unit number).
--- remote.call("fork-portals", "travel", entity, portal) sends a character (devcheck's runtime test: headless runs
--- have no players) and returns the portal it arrived at.
--------------------------------------------------------------------------------

local M = {}
local HOME, COOLDOWN = "nauvis", 120
--- portal -> the planet on its other side, the scale (or a fixed arrival), the search radius there and at home, a
--- frozen daytime there
local LINKS = {
	["nether-portal"] = { planet = "gt-nether", scale = 8, there = 16, home = 128 },
	["twilight-portal"] = { planet = "gt-twilight", scale = 1, there = 128, home = 128, daytime = 0.35 },
	["end-portal"] = { planet = "gt-end", arrive = { x = 0, y = 0 }, there = 64, home = 64, daytime = 0.42 },
}
local NAMES = {}
for name in pairs(LINKS) do NAMES[#NAMES + 1] = name end

local function state()
	storage.fork_portals = storage.fork_portals or { cooldown = {} }
	storage.fork_portals.came_from = storage.fork_portals.came_from or {}
	return storage.fork_portals
end

--- the surface on the other side, the position there and the search radius there; for the End's way back also the
--- portal the traveller came through (key)
local function other_side(portal, key)
	local link = LINKS[portal.name]
	local surface, position = portal.surface, portal.position
	if link.arrive and surface.name == link.planet then
		local from = state().came_from[key]
		if from and from.valid then return from.surface, from.position, 1, from end
		local home = game.surfaces[HOME]
		return home, portal.force.get_spawn_position(home), link.home
	end
	if surface.name == HOME then
		local planet = game.planets[link.planet]
		if not planet then return end
		local there = planet.surface
		if not there then
			there = planet.create_surface()
			if link.daytime then
				there.daytime = link.daytime
				there.freeze_daytime = true
			end
		end
		if link.arrive then return there, link.arrive, link.there end
		return there, { x = position.x / link.scale, y = position.y / link.scale }, link.there
	elseif surface.name == link.planet then
		return game.surfaces[HOME], { x = position.x * link.scale, y = position.y * link.scale }, link.home
	end
end

--- the portal on the other side: the nearest one of the kind within r, else a new one on free ground
local function exit_portal(name, surface, pos, r, force)
	surface.request_to_generate_chunks(pos, math.ceil(r / 32))
	surface.force_generate_chunk_requests()
	local best, dist
	for _, p in pairs(surface.find_entities_filtered{ name = name, position = pos, radius = r }) do
		local d = (p.position.x - pos.x) ^ 2 + (p.position.y - pos.y) ^ 2
		if not dist or d < dist then best, dist = p, d end
	end
	if best then return best end
	--- free ground for the portal and the one who arrives (the Nether's lava is not walkable)
	local at = surface.find_non_colliding_position("character", pos, 64, 1) or pos
	local even = prototypes.entity[name].tile_width % 2 == 0
	at = even and { x = math.floor(at.x + 0.5), y = math.floor(at.y + 0.5) }
		or { x = math.floor(at.x) + 0.5, y = math.floor(at.y) + 0.5 }
	return surface.create_entity{ name = name, position = at, force = force, raise_built = true }
end

--- send the entity (a character, or a player's) through the portal; returns the exit portal
local function travel(entity, portal, player)
	local link = LINKS[portal.name]
	if not link then return end
	local key = player and player.index or ("c" .. entity.unit_number)
	local surface, pos, r, known = other_side(portal, key)
	if not surface then return end
	local out = known or exit_portal(portal.name, surface, pos, r, portal.force)
	if not out then return end
	if link.arrive and portal.surface.name == HOME then state().came_from[key] = portal end
	local south = prototypes.entity[out.name].tile_height / 2 + 1
	local land = surface.find_non_colliding_position("character", { out.position.x, out.position.y + south }, 16, 0.5)
		or { out.position.x, out.position.y + south }
	if player then player.teleport(land, surface) else entity.teleport(land, surface) end
	return out
end

function M.on_player_changed_position(event)
	local player = game.get_player(event.player_index)
	if not (player and player.character and player.surface) then return end
	local st = state()
	if (st.cooldown[player.index] or 0) > game.tick then return end
	local p = player.position
	local portal = player.surface.find_entities_filtered{ name = NAMES,
		area = { { p.x - 0.1, p.y - 0.1 }, { p.x + 0.1, p.y + 0.1 } }, limit = 1 }[1]
	if not portal then return end
	st.cooldown[player.index] = game.tick + COOLDOWN
	travel(player.character, portal, player)
end

remote.add_interface("fork-portals", {
	travel = function(entity, portal) return travel(entity, portal) end,
})

return M
