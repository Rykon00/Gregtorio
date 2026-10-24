--- Issue #563 (devcheck.py switch, part of `all`): a map is made in one ore mode (the startup setting
--- gregtorio-continued-ore-mode) and loaded in the other; scripts/fork-ore-veins.lua migrates it in on_configuration_changed.
--- Map veins -> classic: Nauvis' map settings lose the veins, its vein ore stays, a Manual Mine drill on a patch keeps
--- mining, a Manual Mine item places the Dimension Mine (called Manual Mine), new chunks get no vein ore, the vein recipes
--- are shown. Classic -> map veins: Nauvis gets the veins in its map settings and its generated chunks, a Dimension Mine on
--- Nauvis' iron vein recipe becomes the Manual Mine drill with its manual labor as fuel, one on the Nether's tetrahedrite
--- vein loses the recipe, the vein recipes are hidden. DEVCHECK-SWITCH-SETUP and DEVCHECK-SWITCH in the log.

local MODE = "gregtorio-continued-ore-mode"
local AREA = { { -128, -128 }, { 128, 128 } }
local D, D2, CHEST = { 200.5, 200.5 }, { 220.5, 200.5 }, { 240.5, 200.5 }
local FAR = { 1500, 1500 }
local WAIT = 300

local function mode() return settings.startup[MODE].value end
local function vein_ores()
	local names = {}
	for name, p in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "resource" } }) do
		if p.resource_category == "gt-ore" then names[#names + 1] = name end
	end
	return names
end
local function clear(s, at, r)
	for _, e in pairs(s.find_entities_filtered{ area = { { at[1] - r, at[2] - r }, { at[1] + r, at[2] + r } } }) do
		if e.valid and e.type ~= "character" then e.destroy() end
	end
end
local function mine(s, at, recipe)
	clear(s, at, 6)
	local m = s.create_entity{ name = "dimension-mine", position = at, force = "player", raise_built = true }
	game.forces.player.recipes[recipe].enabled = true
	m.set_recipe(recipe)
	local input = m.get_inventory(defines.inventory.crafter_input)
	for _, i in pairs(prototypes.recipe[recipe].ingredients) do input.insert{ name = i.name, count = 2 * i.amount } end
	return m
end

script.on_init(function()
	local s = game.surfaces.nauvis
	s.request_to_generate_chunks({ 0, 0 }, 5)
	s.request_to_generate_chunks(D, 2)
	s.force_generate_chunk_requests()
	local st = { from = mode() }
	storage.switch = st
	local ok, err = pcall(function()
		st.ore = s.count_entities_filtered{ area = AREA, type = "resource", name = vein_ores() }
		if st.from == "map-veins" then
			clear(s, D, 8)
			for dx = -2, 2 do
				for dy = -2, 2 do s.create_entity{ name = "gt-ore-magnetite", position = { D[1] + dx, D[2] + dy }, amount = 1000 } end
			end
			local drill = s.create_entity{ name = "manual-mine", position = D, force = "player", raise_built = true }
			assert(drill.get_fuel_inventory().insert{ name = "manual-labor", count = 50 } == 50, "the drill took no manual labor")
			st.out = s.create_entity{ name = "iron-chest", position = { D[1], D[2] - 3 }, force = "player" }
			st.drill = drill
			clear(s, CHEST, 1)
			st.chest = s.create_entity{ name = "iron-chest", position = CHEST, force = "player" }
			st.chest.insert{ name = "manual-mine", count = 5 }
		else
			st.iron = mine(s, D, "mining-iron-vein")
			st.tetra = mine(s, D2, "mining-tetrahedrite-vein")
		end
	end)
	if not ok then st.error = tostring(err) end
	log("DEVCHECK-SWITCH-SETUP " .. (ok and "ok" or "failed: " .. tostring(err)) .. " (" .. st.from .. ", " .. tostring(st.ore)
		.. " vein ore tiles around the origin)")
end)

script.on_configuration_changed(function()
	local st = storage.switch
	if st and not st.at then st.at = game.tick + WAIT end
end)

script.on_event(defines.events.on_tick, function(event)
	local st = storage.switch
	if not (st and st.at) or st.done or event.tick < st.at then return end
	st.done = true
	local s = game.surfaces.nauvis
	local to, problems, parts = mode(), {}, {}
	local function expect(c, what) if not c then problems[#problems + 1] = what end end
	expect(to ~= st.from, "the map was loaded in its own mode " .. to)
	expect(not st.error, "the set-up failed: " .. tostring(st.error))
	local mgs = s.map_gen_settings
	local veins_named = (mgs.property_expression_names or {}).gt_vein_id ~= nil
	local ore = s.count_entities_filtered{ area = AREA, type = "resource", name = vein_ores() }
	s.request_to_generate_chunks(FAR, 2)
	s.force_generate_chunk_requests()
	local far = s.count_entities_filtered{ area = { { FAR[1] - 64, FAR[2] - 64 }, { FAR[1] + 64, FAR[2] + 64 } }, type = "resource",
		name = vein_ores() }
	local iron = prototypes.recipe["mining-iron-vein"]
	if to == "vein-recipes" then
		expect(not veins_named and not (mgs.autoplace_controls or {})["gt-ore-veins"], "Nauvis' map settings still name the veins")
		expect(ore == st.ore and ore > 0, ore .. " vein ore tiles around the origin, " .. st.ore .. " before")
		expect(far == 0, far .. " vein ore tiles in new chunks")
		local mined = st.out and st.out.valid and st.out.get_item_count("raw-magnetite") or 0
		expect(st.drill and st.drill.valid and mined > 0, "the Manual Mine drill mined " .. mined .. " raw magnetite after the switch")
		local item = prototypes.item["manual-mine"]
		expect(item.place_result and item.place_result.name == "dimension-mine", "the Manual Mine item places "
			.. tostring(item.place_result and item.place_result.name))
		expect(st.chest.valid and st.chest.get_item_count("manual-mine") == 5, "the chest lost its Manual Mine items")
		expect(iron and not iron.hidden, "mining-iron-vein is hidden in classic mode")
		parts[#parts + 1] = string.format("%d vein ore tiles kept, %d in new chunks, the drill mined %d", ore, far, mined)
	else
		expect(veins_named, "Nauvis' map settings name no veins")
		expect(ore > 0, "no vein ore around the origin after the switch")
		expect(far > 0, "no vein ore in new chunks")
		local drill = s.find_entity("manual-mine", D)
		expect(drill and drill.type == "mining-drill", "the Dimension Mine on mining-iron-vein is no Manual Mine drill")
		expect(drill and drill.get_fuel_inventory().get_item_count("manual-labor") > 0, "the drill got no manual labor")
		local t = st.tetra
		expect(t and t.valid and t.get_recipe() == nil, "the Dimension Mine on mining-tetrahedrite-vein has "
			.. tostring(t and t.valid and t.get_recipe() and t.get_recipe().name))
		expect(iron and iron.hidden, "mining-iron-vein is shown in map-vein mode")
		parts[#parts + 1] = string.format("%d vein ore tiles around the origin, %d in new chunks, the iron mine a drill, "
			.. "the tetrahedrite mine without a recipe", ore, far)
	end
	for _, p in pairs(problems) do log("DEVCHECK-SWITCH-FAIL " .. p) end
	log("DEVCHECK-SWITCH " .. (#problems == 0 and "ok" or "failed") .. " (" .. st.from .. " -> " .. to .. ": "
		.. table.concat(parts, "; ") .. ")")
end)
