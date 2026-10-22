--- Issue #497 (plan #494): the map veins of prototypes/165-fork-ore-veins.lua get a chart tag with GT's name ("Magnetite
--- Vein"), like GTNH's vein waypoints, when the chunk that holds the vein's centre is charted. The cells overlapping the
--- chunk and their vein are read from the map's noise (calculate_tile_properties of gt_cell_x/y/size at the chunk's
--- corners, gt_vein_id/cx/cy at the cell centre); only planets of the mod data `fork-ore-veins` have veins. A cell is
--- tagged once per force (`storage.fork_ore_veins.tagged`), so a radar that charts the chunk again adds no second tag
--- and a tag the player deleted stays deleted. Event driven, no tick handler; the state is lazy.
--- remote.call("fork-ore-veins", "tag_chunk", force, surface, chunk_position) tags one chunk the same way (devcheck's
--- runtime test: headless runs raise no on_chunk_charted).
local M = {}

local function vein_data()
	local md = prototypes.mod_data["fork-ore-veins"]
	return md and md.data
end

local function tagged(force, surface)
	storage.fork_ore_veins = storage.fork_ore_veins or { tagged = {} }
	local t = storage.fork_ore_veins.tagged
	t[force.index] = t[force.index] or {}
	t[force.index][surface.index] = t[force.index][surface.index] or {}
	return t[force.index][surface.index]
end

--- tag the vein whose centre is in this area (a chunk) for the force
local function tag(force, surface, a)
	local d = vein_data()
	if not (d and surface and surface.planet and d.planets[surface.planet.name]) then return end
	local corners = { a.left_top, { x = a.right_bottom.x - 1, y = a.left_top.y }, { x = a.left_top.x, y = a.right_bottom.y - 1 },
		{ x = a.right_bottom.x - 1, y = a.right_bottom.y - 1 } }
	local cells = surface.calculate_tile_properties({ "gt_cell_x", "gt_cell_y", "gt_cell_size" }, corners)
	local size = cells.gt_cell_size[1]
	local seen, centres, names = {}, {}, {}
	for i = 1, #corners do
		local k = cells.gt_cell_x[i] .. "," .. cells.gt_cell_y[i]
		if not seen[k] then
			seen[k] = true
			names[#names + 1] = k
			centres[#centres + 1] = { x = (cells.gt_cell_x[i] + 0.5) * size, y = (cells.gt_cell_y[i] + 0.5) * size }
		end
	end
	local veins = surface.calculate_tile_properties({ "gt_vein_id", "gt_vein_cx", "gt_vein_cy" }, centres)
	local done = tagged(force, surface)
	for i, k in ipairs(names) do
		local id, cx, cy = veins.gt_vein_id[i], veins.gt_vein_cx[i], veins.gt_vein_cy[i]
		local label = id > 0 and d.veins[tostring(math.floor(id + 0.5))]
		if label and not done[k] and cx >= a.left_top.x and cx < a.right_bottom.x and cy >= a.left_top.y
			and cy < a.right_bottom.y then
			done[k] = true
			force.add_chart_tag(surface, { position = { cx, cy }, text = label.text,
				icon = { type = "item", name = label.icon } })
		end
	end
end

function M.on_chunk_charted(event)
	tag(event.force, game.surfaces[event.surface_index], event.area)
end

remote.add_interface("fork-ore-veins", {
	tag_chunk = function(force, surface, chunk)
		local x, y = chunk.x * 32, chunk.y * 32
		tag(game.forces[force] or force, game.surfaces[surface] or surface,
			{ left_top = { x = x, y = y }, right_bottom = { x = x + 32, y = y + 32 } })
	end,
})

return M
