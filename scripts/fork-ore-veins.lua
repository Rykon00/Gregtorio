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
---   2. every generated chunk gets the veins' ores (regenerate_entity, also under buildings, like vanilla ore; issue #534:
---      every one without an ore of the veins);
---   3. a dimension mine that runs a hidden vein recipe (the Overworld's: 163 hides them, the drills mine those ores) is
---      replaced by its mining drill at its place (mod data fork-electric-mine: drills); the inserters, belts and poles
---      stay, the Manual Mine gets the old one's manual labor as fuel, a plant its Drilling Fluid, other items go to the
---      ground; a drill without ore in its area is named in a message with its position;
---   4. the veins whose centre a force has charted get their tag.
--- Issue #505 (V9): the vein recipes of Nauvis, the Nether and the Twilight Forest are gone; an old save's dimension mine on
--- one of them runs a placeholder of its planet (migrations/2026-10-22-issue-505-vein-recipes.json, mod data
--- fork-electric-mine: removed). On that planet's surface it is replaced as in 3.; elsewhere (a mine on Nauvis that ran a
--- Nether vein) it loses the recipe, its items go to the ground and a message names it. The migration of #505 runs this
--- again for saves that had the one of #500 (steps 1, 2 and 4 only touch a surface without the veins).
--- Issue #527: an old Manual Mine's recipe that moved to the Dig Site (#499, #526) or that needs another surface (the
--- glowstone vein, #501) is a placeholder too (migrations/2026-10-23-issue-527-moved-mine-recipes.json, mod data
--- fork-electric-mine: moved): on its planet the mine gets the recipe back, elsewhere it loses it with a message.
--- Issue #529 (migrations/2026-10-23-issue-529-vein-controls.lua): 1. also gives the surface the veins' own controls and
--- the planet's gt_size_max; the size slider of gt-ore-veins scaled every vein before and sets the share of cells with a
--- vein now, so a save whose old size is not 1 gets it on every vein's control and 1 on the grid's: its cells and veins
--- stay as they were.
--- Issue #534 (migrations/2026-10-23-issue-534-vein-ores.lua): 2. and 4. take every generated chunk without an ore of the
--- veins, not only a surface whose map settings lacked the veins: a save can have them (from a map settings editor) while
--- its chunks have no ore. A chunk of an empty cell gets none; one whose ore was mined out completely gets it again.
--- Issue #540 (migrations/2026-10-23-issue-540-foreign-map-gen.lua): a map made with Space Age keeps one table of every
--- planet's sliders on its Nauvis surface; since #529 (the planets deleted, the controls their terrain reads kept hidden)
--- and Factorio 2.1 these place Gleba's plants and the other planets' tiles in Nauvis' new chunks. 1. leaves the surface
--- only its planet's controls (the save's values of these), no default for the others, the planet's autoplace settings and
--- its expression names (and the ones the map generator's presets and climate sliders write: a player's island map stays
--- one), and notes a surface whose settings were not its planet's in storage.fork_ore_veins.foreign, for clean_chunks.
local function same(a, b)
	if type(a) ~= "table" or type(b) ~= "table" then return a == b end
	for k, v in pairs(a) do if not same(v, b[k]) then return false end end
	for k in pairs(b) do if a[k] == nil then return false end end
	return true
end

local function gt_ore(name)
	local p = prototypes.entity[name]
	return p and p.type == "resource" and p.resource_category == "gt-ore"
end

--- the autoplace settings without the vein ores (which #500 adds to an old save: no sign of a foreign map)
local function without_veins(settings)
	local out = {}
	for kind, s in pairs(settings or {}) do
		out[kind] = { treat_missing_as_default = s.treat_missing_as_default, settings = {} }
		for name, v in pairs(s.settings or {}) do
			if not (kind == "entity" and gt_ore(name)) then out[kind].settings[name] = v end
		end
	end
	return out
end

--- the expression names the map generator writes for a planet's own options: its presets' (lakes, island) and the
--- climate sliders (control:moisture:*, control:aux:*)
local function own_expression_names()
	local keep = {}
	for _, preset in pairs(prototypes.map_gen_preset) do
		local ok, basic = pcall(function() return preset.basic_settings end)
		for k in pairs(ok and basic and basic.property_expression_names or {}) do keep[k] = true end
	end
	return keep
end

local function migrate_surface(surface, planet)
	local profiler = helpers.create_profiler()
	--- 1. the map generation settings of the planet (a map made with the veins has them: its ores stay as they are)
	local proto = prototypes.space_location[planet].map_gen_settings
	local mgs = surface.map_gen_settings
	local fresh = not (mgs.property_expression_names or {}).gt_vein_id
	local names = {}
	mgs.autoplace_controls = mgs.autoplace_controls or {}
	local grid = mgs.autoplace_controls["gt-ore-veins"]
	local old_size = grid and tonumber(grid.size)
	local added = 0
	--- issue #540: the controls, autoplace settings and expression names of other planets
	local foreign = {}
	for control in pairs(mgs.autoplace_controls) do
		if not (proto.autoplace_controls or {})[control] then
			mgs.autoplace_controls[control] = nil
			foreign[#foreign + 1] = control
		end
	end
	if mgs.default_enable_all_autoplace_controls ~= false then
		mgs.default_enable_all_autoplace_controls = false
		foreign[#foreign + 1] = "default_enable_all_autoplace_controls"
	end
	if not same(without_veins(mgs.autoplace_settings), without_veins(proto.autoplace_settings)) then
		foreign[#foreign + 1] = "autoplace_settings"
	end
	mgs.autoplace_settings = proto.autoplace_settings
	local own, stale = own_expression_names(), 0
	for k in pairs(mgs.property_expression_names or {}) do
		if (proto.property_expression_names or {})[k] == nil and not own[k] and not k:match("^control:") then
			mgs.property_expression_names[k] = nil
			--- (a vein name of an older version is no sign of a foreign map)
			if k:match("^gt_") then stale = stale + 1 else foreign[#foreign + 1] = "property_expression_names." .. k end
		end
	end
	for control, v in pairs(proto.autoplace_controls or {}) do
		if prototypes.autoplace_control[control] and not mgs.autoplace_controls[control] then
			if old_size and old_size ~= 1 and control:match("^gt%-vein%-") then
				v = { frequency = 1, size = old_size, richness = 1 }
			end
			mgs.autoplace_controls[control] = v
			added = added + 1
		end
	end
	local resized = old_size and old_size ~= 1 and added > 0
	if resized then grid.size = 1 end
	for name in pairs(proto.autoplace_settings.entity.settings) do
		if gt_ore(name) then names[#names + 1] = name end
	end
	mgs.property_expression_names = mgs.property_expression_names or {}
	for k, v in pairs(proto.property_expression_names or {}) do
		if k:match("^gt_") then
			if mgs.property_expression_names[k] ~= v then added = added + 1 end
			mgs.property_expression_names[k] = v
		end
	end
	--- names of noise expressions that no longer exist (a mod of the map's start removed since): the game ignores them,
	--- but warns about each one whenever it compiles the surface's noise program, i.e. on every calculate_tile_properties
	local dropped = stale
	for k, v in pairs(mgs.property_expression_names) do
		if type(v) == "string" and not tonumber(v) and not prototypes.named_noise_expression[v] then
			mgs.property_expression_names[k] = nil
			dropped = dropped + 1
		end
	end
	local st = storage.fork_ore_veins
	if #foreign > 0 then
		st.foreign = st.foreign or {}
		st.foreign[surface.index] = true
		log("FORK-ORE-VEINS: " .. surface.name .. ": map settings of other planets removed: " .. table.concat(foreign, ", "))
	end
	--- 2. the ores of the generated chunks that have none (once per load: every migration file of a load calls this in the
	--- same tick, storage.fork_ore_veins.ores_tick)
	local chunks = {}
	st.ores_tick = st.ores_tick or {}
	local again = st.ores_tick[surface.index] == game.tick
	st.ores_tick[surface.index] = game.tick
	if not again then
		for c in surface.get_chunks() do
			if surface.is_chunk_generated(c) and #names > 0 and surface.count_entities_filtered{ type = "resource", name = names,
				area = { { c.x * 32, c.y * 32 }, { c.x * 32 + 32, c.y * 32 + 32 } }, limit = 1 } == 0 then
				chunks[#chunks + 1] = { x = c.x, y = c.y }
			end
		end
	end
	if fresh or dropped > 0 or added > 0 or #foreign > 0 then surface.map_gen_settings = mgs end
	if #chunks > 0 then surface.regenerate_entity(names, chunks) end
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
		if #recipe.prototype.products == 0 then return false end
		for _, pr in pairs(recipe.prototype.products) do if not here[pr.name] then return false end end
		return true
	end
	local removed = em and em.data.removed or {}
	local moved = em and em.data.moved or {}
	local replaced, bare, cleared, restored = 0, {}, {}, 0
	for _, old in pairs(#list > 0 and surface.find_entities_filtered{ name = list } or {}) do
		local recipe = old.get_recipe()
		local gone = recipe and removed[recipe.name]
		local mv = recipe and moved[recipe.name]
		if mv and mv.planet == planet then
			--- issue #527: the recipe works here (the glowstone vein in the Nether)
			old.set_recipe(mv.recipe)
			restored = restored + 1
		elseif mv then
			for _, c in pairs(old.set_recipe(nil) or {}) do
				surface.spill_item_stack{ position = old.position, stack = c, force = old.force, allow_belts = false }
			end
			cleared[#cleared + 1] = { old, mv.planet, mv.recipe }
			log(string.format("FORK-ORE-VEINS: %s at %.1f,%.1f (%s) has no recipe now", old.name, old.position.x, old.position.y,
				mv.recipe))
		elseif gone and gone ~= planet then
			--- issue #505: a vein of another planet: the mine stays without a recipe
			for _, c in pairs(old.set_recipe(nil) or {}) do
				surface.spill_item_stack{ position = old.position, stack = c, force = old.force, allow_belts = false }
			end
			cleared[#cleared + 1] = { old, gone }
			log(string.format("FORK-ORE-VEINS: %s at %.1f,%.1f (%s) has no recipe now", old.name, old.position.x, old.position.y,
				recipe.name))
		elseif recipe and (gone or (recipe.prototype.hidden and ores_here(recipe))) then
			local pos, dir, force, quality, drill = old.position, old.direction, old.force, old.quality, drills[old.name]
			local items = {}
			for _, inv in pairs({ defines.inventory.crafter_input, defines.inventory.crafter_output }) do
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
	for _, c in pairs(cleared) do
		local e = c[1]
		local at = string.format("[gps=%d,%d,%s]", math.floor(e.position.x), math.floor(e.position.y), surface.name)
		if c[3] and c[2] then
			e.force.print({ "fork-message.mine-recipe-elsewhere", e.localised_name, at, prototypes.recipe[c[3]].localised_name,
				{ "space-location-name." .. c[2] } })
		elseif c[3] then
			e.force.print({ "fork-message.mine-recipe-dig-site", e.localised_name, at, prototypes.recipe[c[3]].localised_name })
		else
			e.force.print({ "fork-message.mine-vein-gone", e.localised_name, at, { "space-location-name." .. c[2] } })
		end
	end
	--- 4. the charted veins
	local charted, tags = 0, 0
	for _, force in pairs(#chunks > 0 and game.forces or {}) do
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
	log({ "", string.format("FORK-ORE-VEINS: %s: %d chunks regenerated with %d ores, %d mines replaced by drills (%d without ore), "
		.. "%d without their recipe, %d with their recipe back, %d veins tagged in %d charted chunks, %d names of missing noise "
		.. "expressions dropped from the map settings, %d controls and expression names added%s; ", surface.name,
		#chunks, #names, replaced, #bare, #cleared, restored, tags, charted, dropped, added,
		resized and (" (the old size " .. old_size .. " on every vein)") or ""), profiler })
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

--- Issue #540: the chunks of a surface whose map settings were another planet's (storage.fork_ore_veins.foreign, noted by
--- migrate_surface) hold what those settings placed. A chunk without an entity of a player's force and without a
--- tile a player placed is deleted, so the game generates it anew with the right settings (also one that was generated but
--- never charted); a kept chunk loses the trees, plants, rocks and cliffs of Space Age and its decoratives that the planet
--- does not place itself; its tiles stay.
local function clean_surface(surface, planet)
	local profiler = helpers.create_profiler()
	local forces = {}
	for _, f in pairs(game.forces) do
		if f.name ~= "enemy" and f.name ~= "neutral" then forces[#forces + 1] = f end
	end
	local placed = {}
	for name, t in pairs(prototypes.tile) do
		if t.items_to_place_this and #t.items_to_place_this > 0 then placed[#placed + 1] = name end
	end
	local own = prototypes.space_location[planet].map_gen_settings.autoplace_settings or {}
	local own_entities = own.entity and own.entity.settings or {}
	local own_decoratives = own.decorative and own.decorative.settings or {}
	local function space_age(kind, name)
		local h = prototypes.get_history(kind, name)
		return h ~= nil and h.created == "space-age"
	end
	local entities, decoratives = {}, {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = { "tree", "plant", "simple-entity", "cliff" } } }) do
		if not own_entities[name] and space_age(p.type, name) then entities[#entities + 1] = name end
	end
	for name in pairs(prototypes.decorative) do
		if not own_decoratives[name] and space_age("optimized-decorative", name) then decoratives[#decoratives + 1] = name end
	end
	local gone, kept, total = {}, {}, 0
	--- (every chunk the surface has: one around the generated area is generated in part and holds decoratives that spill
	--- over from its neighbours)
	for c in surface.get_chunks() do
		total = total + 1
		if surface.count_entities_filtered{ area = c.area, force = forces, limit = 1 } == 0
			and (#placed == 0 or surface.count_tiles_filtered{ area = c.area, name = placed, limit = 1 } == 0) then
			gone[#gone + 1] = { x = c.x, y = c.y }
		else
			kept[#kept + 1] = c.area
		end
	end
	local removed, decorations = 0, 0
	for _, area in pairs(kept) do
		if #entities > 0 then
			for _, e in pairs(surface.find_entities_filtered{ area = area, name = entities }) do
				if e.valid then
					e.destroy()
					removed = removed + 1
				end
			end
		end
		if #decoratives > 0 then
			local n = #surface.find_decoratives_filtered{ area = area, name = decoratives }
			if n > 0 then
				surface.destroy_decoratives{ area = area, name = decoratives }
				decorations = decorations + n
			end
		end
	end
	for _, c in pairs(gone) do surface.delete_chunk(c) end
	profiler.stop()
	log({ "", string.format("FORK-ORE-VEINS: %s: %d of %d chunks deleted (no building: generated anew with the "
		.. "planet's settings), %d kept: %d trees, plants, rocks and cliffs and %d decoratives of other planets removed, "
		.. "their tiles kept; ", surface.name, #gone, total, #kept, removed, decorations), profiler })
end

function M.clean_chunks()
	local d = vein_data()
	local st = storage.fork_ore_veins
	if not (d and st and st.foreign) then return end
	for planet in pairs(d.planets) do
		local p = game.planets[planet]
		if p and p.surface and st.foreign[p.surface.index] then clean_surface(p.surface, planet) end
	end
	st.foreign = nil
end

remote.add_interface("fork-ore-veins", {
	migrate = M.migrate,
	clean_chunks = M.clean_chunks,
	tag_chunk = function(force, surface, chunk)
		local x, y = chunk.x * 32, chunk.y * 32
		return tag(game.forces[force] or force, game.surfaces[surface] or surface,
			{ { left_top = { x = x, y = y }, right_bottom = { x = x + 32, y = y + 32 } } })
	end,
})

return M
