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

--- the veins of a surface's cells, read from the noise once per cell (issue #500: every calculate_tile_properties call
--- compiles the surface's noise program, which costs, so one call takes all the cells of a batch of chunks):
--- storage.fork_ore_veins.cells[surface index] = { size = cell size, [cell] = { id, cx, cy } or false (no vein) }
local function cells_of(surface)
	local st = storage.fork_ore_veins
	st.cells = st.cells or {}
	local c = st.cells[surface.index]
	if not c then
		c = { size = surface.calculate_tile_properties({ "gt_cell_size" }, { { 0, 0 } }).gt_cell_size[1] }
		st.cells[surface.index] = c
	end
	return c
end

--- tag, for the force, the veins whose centre lies in one of these areas (chunks); returns the number of tags
local function tag(force, surface, areas)
	local d = vein_data()
	if not (d and surface and surface.planet and d.planets[surface.planet.name]) then return 0 end
	storage.fork_ore_veins = storage.fork_ore_veins or { tagged = {} }
	local cells = cells_of(surface)
	local size = cells.size
	--- the cells the areas overlap, and those whose vein is not known yet
	local overlap, ask, keys = {}, {}, {}
	for i, a in ipairs(areas) do
		overlap[i] = {}
		for cy = math.floor(a.left_top.y / size), math.floor((a.right_bottom.y - 1) / size) do
			for cx = math.floor(a.left_top.x / size), math.floor((a.right_bottom.x - 1) / size) do
				local k = cx .. "," .. cy
				overlap[i][#overlap[i] + 1] = k
				if cells[k] == nil and not keys[k] then
					keys[k] = true
					ask[#ask + 1] = { k = k, x = (cx + 0.5) * size, y = (cy + 0.5) * size }
				end
			end
		end
	end
	if #ask > 0 then
		local v = surface.calculate_tile_properties({ "gt_vein_id", "gt_vein_cx", "gt_vein_cy" }, ask)
		for i, c in ipairs(ask) do
			local id = math.floor(v.gt_vein_id[i] + 0.5)
			cells[c.k] = id > 0 and { id, v.gt_vein_cx[i], v.gt_vein_cy[i] } or false
		end
	end
	local done, n = tagged(force, surface), 0
	for i, a in ipairs(areas) do
		for _, k in ipairs(overlap[i]) do
			local c = cells[k]
			local label = c and d.veins[tostring(c[1])]
			if label and not done[k] and c[2] >= a.left_top.x and c[2] < a.right_bottom.x and c[3] >= a.left_top.y
				and c[3] < a.right_bottom.y then
				done[k] = true
				n = n + 1
				force.add_chart_tag(surface, { position = { c[2], c[3] }, text = label.text,
					icon = { type = "item", name = label.icon } })
			end
		end
	end
	return n
end

function M.on_chunk_charted(event)
	tag(event.force, game.surfaces[event.surface_index], { event.area })
end

--- Issue #500 (V4 of plan #494): an existing save gets the map veins once, from the Lua migration
--- migrations/2026-10-22-issue-500-map-veins.lua (remote "migrate"; the game runs a migration once per save, whatever
--- the version, and never for a map made with it):
---   1. the surface's map generation settings take its planet's control, resources and vein expressions (new chunks);
---   2. every generated chunk gets the veins' ores (regenerate_entity, also under buildings, like vanilla ore);
---   3. a dimension mine that runs a hidden vein recipe (the Overworld's: 163 hides them, the drills mine those ores) is
---      replaced by its mining drill at its place (mod data fork-electric-mine: drills); the inserters, belts and poles
---      stay, the Manual Mine gets the old one's manual labor as fuel, a plant its Drilling Fluid, other items go to the
---      ground; a drill without ore in its area is named in a message with its position;
---   4. the veins whose centre a force has charted get their tag.
local function migrate_surface(surface, planet)
	local profiler = helpers.create_profiler()
	--- 1. the map generation settings of the planet (a map made with the veins has them: its ores stay as they are)
	local proto = prototypes.space_location[planet].map_gen_settings
	local mgs = surface.map_gen_settings
	local fresh = not (mgs.property_expression_names or {}).gt_vein_id
	local names = {}
	mgs.autoplace_controls = mgs.autoplace_controls or {}
	for control, v in pairs(proto.autoplace_controls or {}) do
		if prototypes.autoplace_control[control] and not mgs.autoplace_controls[control] then
			mgs.autoplace_controls[control] = v
		end
	end
	mgs.autoplace_settings = mgs.autoplace_settings or {}
	mgs.autoplace_settings.entity = mgs.autoplace_settings.entity or { settings = {} }
	mgs.autoplace_settings.entity.settings = mgs.autoplace_settings.entity.settings or {}
	for name, v in pairs(proto.autoplace_settings.entity.settings) do
		local p = prototypes.entity[name]
		if p and p.type == "resource" and p.resource_category == "gt-ore" then
			mgs.autoplace_settings.entity.settings[name] = v
			names[#names + 1] = name
		end
	end
	mgs.property_expression_names = mgs.property_expression_names or {}
	for k, v in pairs(proto.property_expression_names or {}) do
		if k:match("^gt_") then mgs.property_expression_names[k] = v end
	end
	--- names of noise expressions that no longer exist (a mod of the map's start removed since): the game ignores them,
	--- but warns about each one whenever it compiles the surface's noise program, i.e. on every calculate_tile_properties
	local dropped = 0
	for k, v in pairs(mgs.property_expression_names) do
		if type(v) == "string" and not tonumber(v) and not prototypes.named_noise_expression[v] then
			mgs.property_expression_names[k] = nil
			dropped = dropped + 1
		end
	end
	--- 2. the ores of the generated chunks
	local chunks = {}
	for c in surface.get_chunks() do
		if surface.is_chunk_generated(c) then chunks[#chunks + 1] = { x = c.x, y = c.y } end
	end
	if fresh or dropped > 0 then surface.map_gen_settings = mgs end
	if fresh and #names > 0 and #chunks > 0 then surface.regenerate_entity(names, chunks) end
	--- 3. the dimension mines on the Overworld's veins
	local em = prototypes.mod_data["fork-electric-mine"]
	local drills = em and em.data.drills or {}
	local list = {}
	for dim in pairs(drills) do if prototypes.entity[dim] then list[#list + 1] = dim end end
	--- (issue #501: only a mine whose every result is an ore of this planet's veins: one on the Nether's ores stays a
	--- dimension mine on Nauvis, its drill would find none of them)
	local here = {}
	for _, name in pairs(names) do
		for _, pr in pairs(prototypes.entity[name].mineable_properties.products or {}) do here[pr.name] = true end
	end
	local function ores_here(recipe)
		for _, pr in pairs(recipe.prototype.products) do if not here[pr.name] then return false end end
		return true
	end
	local replaced, bare = 0, {}
	for _, old in pairs(#list > 0 and surface.find_entities_filtered{ name = list } or {}) do
		local recipe = old.get_recipe()
		if recipe and recipe.prototype.hidden and ores_here(recipe) then
			local pos, dir, force, quality, drill = old.position, old.direction, old.force, old.quality, drills[old.name]
			local items = {}
			for _, inv in pairs({ defines.inventory.assembling_machine_input, defines.inventory.assembling_machine_output }) do
				local i = old.get_inventory(inv)
				for _, c in pairs(i and i.get_contents() or {}) do items[#items + 1] = c end
			end
			local fluid = old.get_fluid_count("drilling-fluid")
			local old_name, recipe_name = old.name, recipe.name
			old.destroy{ raise_destroy = true }
			local new = surface.create_entity{ name = drill, position = pos, direction = dir, force = force, quality = quality,
				raise_built = true }
			if new then
				replaced = replaced + 1
				local fuel = new.get_fuel_inventory()
				local tank = fluid > 0 and surface.find_entity("ore-drilling-plant-fluid-input", pos)
				if tank then tank.insert_fluid{ name = "drilling-fluid", amount = fluid } end
				for _, c in pairs(items) do
					local left = c.count
					if fuel and c.name == "manual-labor" then left = left - fuel.insert{ name = c.name, count = left } end
					if left > 0 then
						surface.spill_item_stack{ position = pos, stack = { name = c.name, count = left, quality = c.quality },
							force = force, allow_belts = false }
					end
				end
				log(string.format("FORK-ORE-VEINS: %s at %.1f,%.1f (%s) replaced by the %s", old_name, pos.x, pos.y, recipe_name, drill))
				local r = new.prototype.mining_drill_radius
				if surface.count_entities_filtered{ type = "resource", area = { { pos.x - r, pos.y - r }, { pos.x + r, pos.y + r } },
					limit = 1 } == 0 then
					bare[#bare + 1] = new
				end
			end
		end
	end
	for _, e in pairs(bare) do
		e.force.print({ "fork-message.drill-without-ore", e.localised_name,
			string.format("[gps=%d,%d,%s]", math.floor(e.position.x), math.floor(e.position.y), surface.name) })
	end
	--- 4. the charted veins
	local charted, tags = 0, 0
	for _, force in pairs(fresh and game.forces or {}) do
		local areas = {}
		for _, c in pairs(chunks) do
			if force.is_chunk_charted(surface, c) then
				areas[#areas + 1] = { left_top = { x = c.x * 32, y = c.y * 32 }, right_bottom = { x = c.x * 32 + 32, y = c.y * 32 + 32 } }
			end
		end
		charted = charted + #areas
		if #areas > 0 then tags = tags + tag(force, surface, areas) end
	end
	profiler.stop()
	log({ "", "FORK-ORE-VEINS: ", surface.name, ": ", fresh and #chunks or 0, " chunks regenerated with ", #names, " ores, ", replaced,
		" mines replaced by drills (", #bare, " without ore), ", tags, " veins tagged in ", charted, " charted chunks, ",
		dropped, " names of missing noise expressions dropped from the map settings; ", profiler })
end

function M.migrate()
	local d = vein_data()
	if not d then return end
	storage.fork_ore_veins = storage.fork_ore_veins or { tagged = {} }
	for planet in pairs(d.planets) do
		local p = game.planets[planet]
		if p and p.surface then migrate_surface(p.surface, planet) end
	end
end

remote.add_interface("fork-ore-veins", {
	migrate = M.migrate,
	tag_chunk = function(force, surface, chunk)
		local x, y = chunk.x * 32, chunk.y * 32
		return tag(game.forces[force] or force, game.surfaces[surface] or surface,
			{ { left_top = { x = x, y = y }, right_bottom = { x = x + 32, y = y + 32 } } })
	end,
})

return M
