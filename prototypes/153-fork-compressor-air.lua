--------------------------------------------------------------------------------
--- FORK COMPRESSOR AIR (issue #153)
--- Upstream's Air Collector (LV to MAX) is GregTech CEu's Gas Collector; GT New Horizons has none. Its compressor
--- fills an empty cell with air (gregtech/loaders/postload/recipes/CompressorRecipes.java, Cell_Empty -> Cell_Air, 15 s at
--- 2 EU/t). Gregtorio moves fluids in pipes, so here the compressor gives the air itself:
---   * the recipe `air-collection` (its name kept: saves, pattern providers and the migration find it) is a recipe of
---     the compressor, with today's numbers (nothing -> 1000 air in 10 s at LV speed), unlocked as before (Basic Air
---     Centrifuging);
---   * every electric compressor gets the Air Collector's two output ports (south, left and right), shown only with a
---     fluid recipe, so pipes laid to an Air Collector fit the compressor that replaces it;
---   * the Air Collectors are gone: the LV to EV ones (upstream) with their items, recipes and category here, the IV to
---     MAX ones are no longer made (101's IV_BASIC_MACHINES). (The ender tanks of 142 were copies of the HV and EV Air
---     Collector; issue #287 removed them with the microverse.)
--- Old saves: migrations/2026-10-06-issue-153-air-collector.json turns every Air Collector (entity and item) into the
--- compressor of its tier; its recipe air-collection stays valid there, so it goes on making air.
--- Loads after 142 and before 150, 196, 198 and 199.
--------------------------------------------------------------------------------

local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
local AM = data.raw["assembling-machine"]

--- the ports of the Air Collector, before it goes
local ports = AM["lv-air-collector"] and table.deepcopy(AM["lv-air-collector"].fluid_boxes)

--- the air recipe in the compressor
local air = data.raw.recipe["air-collection"]
if air then
	fork_set_category(air, "lv-compressor-recipes")
	air.subgroup = "subgroup-lv-compressor-recipes"
end

--- every electric compressor (the tiers and the Large Electric Compressor) gets the output ports
if ports then
	local names = {}
	for _, t in ipairs(TIERS) do names[#names + 1] = t .. "-compressor" end
	names[#names + 1] = "iv-large-electric-compressor"
	for _, name in ipairs(names) do
		local m = AM[name]
		if m and not m.fluid_boxes then
			m.fluid_boxes = table.deepcopy(ports)
			m.fluid_boxes_off_when_no_fluid_recipe = true
		elseif m then
			log("FORK-COMPRESSOR-AIR: " .. name .. " has fluid boxes already, left as it is")
		end
	end
else
	log("FORK-COMPRESSOR-AIR: no lv-air-collector to take the ports from")
end

--- the Air Collectors with their items, recipes, category and unlocks
local gone = {}
for _, t in ipairs(TIERS) do
	local name = t .. "-air-collector"
	for _, kind in pairs({ "assembling-machine", "item", "recipe" }) do
		if data.raw[kind][name] then
			data.raw[kind][name] = nil
			log("FORK-REMOVED: " .. kind .. " " .. name)
			gone[name] = true
		end
	end
end
for _, tech in pairs(data.raw.technology) do
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do
			if not (e.type == "unlock-recipe" and gone[e.recipe]) then keep[#keep + 1] = e end
		end
		tech.effects = keep
	end
end
for _, r in pairs(data.raw.recipe) do
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if gone[i.name] then log("FORK-COMPRESSOR-AIR: " .. r.name .. " still names " .. i.name) end
		end
	end
end
data.raw["recipe-category"]["lv-air-collector-recipes"] = nil
data.raw["item-subgroup"]["subgroup-lv-air-collector-recipes"] = nil
