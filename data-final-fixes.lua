
table.insert(data.raw["character"]["character"].crafting_categories, "manual-only-recipes")
table.insert(data.raw["character"]["character"].crafting_categories, "crafting-table-recipes")
table.insert(data.raw["character"]["character"].crafting_categories, "crafting-or-assembling-recipes")

table.insert(data.raw.lab.lab.inputs, "umv-science-pack")
table.insert(data.raw.lab.lab.inputs, "uxv-science-pack")
table.insert(data.raw.lab.lab.inputs, "max-science-pack")

--------------------------
---VANILLA ITEM REMOVAL---
--------------------------

---BURNER MINING DRILL
data.raw["recipe"]["burner-mining-drill-recycling"] = nil
data.raw["mining-drill"]["burner-mining-drill"] = nil
data.raw["recipe"]["burner-mining-drill"] = nil
data.raw["item"]["burner-mining-drill"] = nil

---ELECTRIC FURNACE FURNACE
data.raw["recipe"]["electric-furnace-recycling"] = nil
data.raw["furnace"]["electric-furnace"] = nil
data.raw["recipe"]["electric-furnace"] = nil
data.raw["item"]["electric-furnace"] = nil

---VANILLA RECIPES OF GREGTORIO'S ITEMS (issue #317)
--- Vanilla and Space Age recipes that no technology unlocks, of items Gregtorio makes with recipes of its own. They
--- still showed in Factoriopedia (the vanilla battery as the first recipe of the battery) and counted as producers for
--- every tool that reads the recipes. None of their machines (chemical plant, foundry, biochamber, cryogenic plant,
--- electromagnetic plant) has a technology in Gregtorio. Deleted with the technology effects and tips that name them
--- (FORK-REMOVED in the log); the items stay, and so do their recycling recipes.
--- Issue #318 (maintainer's decision): the vanilla oil recipes too, though petroleum gas and solid fuel have no Gregtorio
--- producer; heavy and light oil have GTNH's uses instead (162).
local VANILLA_RECIPES_REMOVED = {
	-- the item's own recipe, replaced by Gregtorio's
	["battery"] = "GTNH fills a battery hull in the canning machine (filling-assorted-batteries)",
	["small-lamp"] = "Gregtorio's LV assembler recipe small-lamp-lv-assembler (issue #555; the recipe torch makes the torch)",
	["chemical-science-pack"] = "Gregtorio's recipe hv-science-pack",
	["space-science-pack"] = "Gregtorio's recipe luv-science-pack",
	["metallurgic-science-pack"] = "Gregtorio's recipe zpm-science-pack",
	["agricultural-science-pack"] = "Gregtorio's recipe uv-science-pack",
	["electromagnetic-science-pack"] = "Gregtorio's recipe uhv-science-pack",
	["cryogenic-science-pack"] = "Gregtorio's recipe uev-science-pack",
	["promethium-science-pack"] = "Gregtorio's recipe uiv-science-pack",
	["lithium"] = "Aquilo; Gregtorio's lithium dust comes from lepidolite and the other ores",
	["lithium-plate"] = "Aquilo; Gregtorio casts the plate from molten lithium (solidify-lithium-plate)",
	["tungsten-plate"] = "Vulcanus foundry; Gregtorio casts the plate from molten tungsten (solidify-tungsten-plate)",
	-- (the recipes molten-iron and molten-copper of Factorio 2.0, renamed by 2.1: issue #535)
	["iron-ore-melting"] = "Vulcanus foundry; Gregtorio melts iron in the fluid extractor",
	["copper-ore-melting"] = "Vulcanus foundry; Gregtorio melts copper in the fluid extractor",
	["carbon"] = "Space Age chemical plant; Gregtorio's carbon dust comes from electrolysis and the centrifuge",
	-- alternative recipes of items Gregtorio makes
	["molten-iron-from-lava"] = "Vulcanus foundry, from lava",
	["molten-copper-from-lava"] = "Vulcanus foundry, from lava",
	["casting-iron"] = "Vulcanus foundry; iron plates from Gregtorio's recipes",
	["casting-copper"] = "Vulcanus foundry; copper plates from Gregtorio's recipes",
	["casting-steel"] = "Vulcanus foundry; steel plates from Gregtorio's recipes",
	["casting-iron-gear-wheel"] = "Vulcanus foundry; gears from Gregtorio's recipes",
	["casting-iron-stick"] = "Vulcanus foundry; iron rods from Gregtorio's recipes",
	["casting-pipe"] = "Vulcanus foundry; pipes from Gregtorio's recipes",
	["casting-pipe-to-ground"] = "Vulcanus foundry; Gregtorio's recipe pipe-to-ground",
	["casting-copper-cable"] = "Vulcanus foundry; copper cables from Gregtorio's recipes",
	["concrete-from-molten-iron"] = "Vulcanus foundry; Gregtorio's recipe concrete",
	["coal-synthesis"] = "Space Age chemical plant; Gregtorio's coal comes from raw coal",
	["acid-neutralisation"] = "Vulcanus chemical plant; steam from Gregtorio's boilers and recipes",
	["steam-condensation"] = "Space Age chemical plant; water from Gregtorio's recipes",
	["ice-melting"] = "Space Age chemical plant; ice has no producer in Gregtorio",
	["ammonia-rocket-fuel"] = "Aquilo; Gregtorio's recipe rocket-fuel",
	["rocket-fuel-from-jelly"] = "Gleba biochamber; Gregtorio's recipe rocket-fuel",
	["biolubricant"] = "Gleba biochamber; Gregtorio's recipe lubricant",
	["biosulfur"] = "Gleba biochamber; sulfur from Gregtorio's recipes",
	["burnt-spoilage"] = "Gleba biochamber; carbon from Gregtorio's recipes",
	-- issue #318: the oil refinery's and the chemical plant's oil recipes and the oil barrels (no barrel has a recipe)
	["basic-oil-processing"] = "oil refinery; Gregtorio distils crude oil in the distillation towers (oil-distillation)",
	["advanced-oil-processing"] = "oil refinery; oil-distillation",
	["coal-liquefaction"] = "oil refinery",
	["simple-coal-liquefaction"] = "Vulcanus oil refinery",
	["heavy-oil-cracking"] = "chemical plant; heavy oil goes into the distillation tower (162)",
	["light-oil-cracking"] = "chemical plant; light oil goes into the distillation tower (162)",
	["solid-fuel-from-heavy-oil"] = "chemical plant",
	["solid-fuel-from-light-oil"] = "chemical plant",
	["solid-fuel-from-petroleum-gas"] = "chemical plant",
	["solid-fuel-from-ammonia"] = "Aquilo chemical plant",
	["heavy-oil-barrel"] = "filling a barrel, which no recipe makes",
	["light-oil-barrel"] = "filling a barrel, which no recipe makes",
	["petroleum-gas-barrel"] = "filling a barrel, which no recipe makes",
	["empty-heavy-oil-barrel"] = "emptying a barrel, which no recipe fills",
	["empty-light-oil-barrel"] = "emptying a barrel, which no recipe fills",
	["empty-petroleum-gas-barrel"] = "emptying a barrel, which no recipe fills",
}
--- Issue #323 (maintainer's decision): the other vanilla and Space Age recipes that no technology unlocks, whose products
--- Gregtorio does not make (they were in Factoriopedia, and nobody could make them), deleted the same way, by the groups of
--- #323. The items and entities stay.
local VANILLA_RECIPES_UNUSED = {
	{ "Space Age planets and space platforms: Gregtorio has neither", {
		"advanced-carbonic-asteroid-crushing", "advanced-metallic-asteroid-crushing",
		"advanced-oxide-asteroid-crushing", "advanced-thruster-fuel", "advanced-thruster-oxidizer",
		"agricultural-tower", "ammoniacal-solution-separation", "artificial-jellynut-soil", "artificial-yumako-soil",
		"asteroid-collector", "biochamber", "bioflux", "bioplastic", "biter-egg", "captive-biter-spawner",
		"carbon-fiber", "carbonic-asteroid-crushing", "carbonic-asteroid-reprocessing", "cargo-bay",
		"cargo-landing-pad", "casting-low-density-structure", "copper-bacteria", "copper-bacteria-cultivation",
		"landing-pad-unloading-bay",       -- (Factorio 2.1, issue #535)
		"crusher", "electrolyte", "fish-breeding", "fluoroketone", "fluoroketone-cooling", "foundation",
		"heating-tower", "holmium-plate", "holmium-solution", "ice-platform", "iron-bacteria",
		"iron-bacteria-cultivation", "jellynut-processing", "lightning-collector", "lightning-rod",
		"metallic-asteroid-crushing", "metallic-asteroid-reprocessing", "nutrients-from-bioflux",
		"nutrients-from-biter-egg", "nutrients-from-fish", "nutrients-from-spoilage", "nutrients-from-yumako-mash",
		"overgrowth-jellynut-soil", "overgrowth-yumako-soil", "oxide-asteroid-crushing", "oxide-asteroid-reprocessing",
		"pentapod-egg", "rocket-part", "rocket-silo", "space-platform-foundation", "space-platform-starter-pack",
		"supercapacitor", "superconductor", "thruster", "thruster-fuel", "thruster-oxidizer", "tungsten-carbide",
		"yumako-processing"
	} },
	{ "military and equipment: their technologies are disabled", {
		"artillery-shell", "artillery-turret", "artillery-wagon", "atomic-bomb", "cannon-shell", "capture-robot-rocket",
		"cluster-grenade", "combat-shotgun", "defender-capsule", "destroyer-capsule", "discharge-defense-equipment",
		"distractor-capsule", "explosive-cannon-shell", "explosive-rocket", "explosive-uranium-cannon-shell",
		"flamethrower", "flamethrower-ammo", "flamethrower-turret", "gate", "grenade", "gun-turret", "heavy-armor",
		"land-mine", "laser-turret", "personal-laser-defense-equipment", "piercing-rounds-magazine",
		"piercing-shotgun-shell", "poison-capsule", "railgun", "railgun-ammo", "railgun-turret", "rocket",
		"rocket-launcher", "rocket-turret", "shotgun", "shotgun-shell", "slowdown-capsule", "solar-panel-equipment",
		"stone-wall", "submachine-gun", "tank", "tesla-ammo", "tesla-turret", "teslagun", "toolbelt-equipment",
		"uranium-cannon-shell", "uranium-rounds-magazine"
	} },
	{ "vanilla machines, power, logistics and modules: Gregtorio builds its GT machines instead", {
		"accumulator", "assembling-machine-1", "assembling-machine-2", "assembling-machine-3", "beacon",
		"big-mining-drill", "biolab", "boiler", "centrifuge", "chemical-plant", "construction-robot", "cryogenic-plant",
		"efficiency-module", "efficiency-module-2", "efficiency-module-3", "electric-mining-drill",
		"electromagnetic-plant", "foundry", "heat-pipe", "logistic-robot", "nuclear-reactor", "oil-refinery",
		"productivity-module", "productivity-module-2", "productivity-module-3", "programmable-speaker", "pumpjack",
		"quality-module", "quality-module-2", "quality-module-3", "recycler", "roboport", "solar-panel", "speed-module",
		"speed-module-2", "speed-module-3", "steam-engine", "steam-turbine", "steel-furnace"
	} },
	{ "vanilla intermediates, uranium processing and barrels: nothing Gregtorio unlocks uses them", {
		"barrel", "electric-engine-unit", "empty-fluoroketone-cold-barrel", "empty-fluoroketone-hot-barrel",
		"empty-water-barrel", "engine-unit", "fluoroketone-cold-barrel", "fluoroketone-hot-barrel",
		"flying-robot-frame", "kovarex-enrichment-process", "low-density-structure", "nuclear-fuel",
		"nuclear-fuel-reprocessing", "plastic-bar", "uranium-fuel-cell", "uranium-processing", "water-barrel"
	} },
}
for _, group in pairs(VANILLA_RECIPES_UNUSED) do
	for _, name in pairs(group[2]) do VANILLA_RECIPES_REMOVED[name] = group[1] end
end
--- Issue #670: Space Age's recycling. Factorio 2.1's built-in mod recycler (a dependency of space-age and quality) makes a
--- hidden recycling recipe of every recipe and item in its data-updates and unlocks them with hidden effects of its
--- technology Recycling. Gregtorio has no recycler (its recipe is in the vanilla machines above, the technology is
--- disabled below and Fulgora is gone since #529), yet every item's tooltip and Factoriopedia showed the recycling result
--- (utility-constants' factoriopedia_recycling_recipe_categories). GT New Horizons recycles in the macerator, the arc
--- furnace and the fluid extractor (157). Every recipe of a category of the recycler is deleted with the vanilla recipes
--- (their technology effects and tips go too) unless another machine runs that category; then the recycler itself. Nothing
--- else of Factorio 2.1 reads them (quality, spoiling and the upgrade planner do not; the recycler's furnace and its
--- technology are their only users). devcheck fails for a recipe of the recycler's categories that is left.
do
	local recycler = data.raw.furnace["recycler"]
	local only_recycler = {}
	for _, c in pairs(recycler and recycler.crafting_categories or { "recycling" }) do only_recycler[c] = true end
	only_recycler["recycling-or-hand-crafting"] = true   -- Space Age 2.0's scrap recycling (2.1: recycling, hand-crafting)
	for _, t in pairs({ "assembling-machine", "furnace", "character" }) do
		for name, e in pairs(data.raw[t] or {}) do
			if name ~= "recycler" then
				for _, c in pairs(e.crafting_categories or {}) do only_recycler[c] = nil end
			end
		end
	end
	local n = 0
	for name, r in pairs(data.raw.recipe) do
		for _, c in pairs(r.categories or { r.category }) do
			if only_recycler[c] then
				VANILLA_RECIPES_REMOVED[name] = "Space Age's recycling: Gregtorio has no recycler (issue #670)"
				n = n + 1
				break
			end
		end
	end
	data.raw.item["recycler"] = nil
	data.raw.furnace["recycler"] = nil
	log("FORK-RECYCLER: " .. n .. " recipes of the recycler's categories and the recycler removed (issue #670)")
end
--- Issue #318: devcheck fails for a recipe of this class (a vanilla recipe without a technology, every product of which
--- Gregtorio makes another way, not hidden) that is neither deleted here nor kept in this allow-list with its reason
FORK_VANILLA_RECIPES_KEPT = {}
for name, _ in pairs(VANILLA_RECIPES_REMOVED) do
	if data.raw.recipe[name] then
		data.raw.recipe[name] = nil
		log("FORK-REMOVED: recipe " .. name)
	end
end
for _, tech in pairs(data.raw.technology) do
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do
			if not (e.recipe and VANILLA_RECIPES_REMOVED[e.recipe]) then keep[#keep + 1] = e end
		end
		tech.effects = keep
	end
end
--- a tip's trigger that names a deleted recipe can never fire (no technology unlocked it): an "or" drops that branch, an
--- "and" or a "sequence" with it can never fire as a whole (issue #323: the triggers are nested)
local function prune_trigger(trigger)
	if trigger.recipe and VANILLA_RECIPES_REMOVED[trigger.recipe] then return nil end
	if trigger.triggers then
		local keep = {}
		for _, t in pairs(trigger.triggers) do
			local p = prune_trigger(t)
			if p then keep[#keep + 1] = p elseif trigger.type ~= "or" then return nil end
		end
		if #keep == 0 then return nil end
		trigger.triggers = keep
	end
	return trigger
end
for name, tip in pairs(data.raw["tips-and-tricks-item"] or {}) do
	for _, key in pairs({ "trigger", "skip_trigger" }) do
		if tip[key] then
			tip[key] = prune_trigger(tip[key])
			if not tip[key] then
				--- a tip without its trigger stays locked, as before (its trigger could never fire)
				if key == "trigger" then tip.starting_status = "locked" end
				log("FORK-TIP: the " .. key .. " of " .. name .. " could never fire (it needs a deleted recipe)")
			end
		end
	end
end
--- issue #323: machines whose fixed recipe is gone (the captive biter spawner's biter egg, the rocket silo's rocket part);
--- nothing in Gregtorio builds them
for _, t in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
	for _, e in pairs(data.raw[t] or {}) do
		if e.fixed_recipe and VANILLA_RECIPES_REMOVED[e.fixed_recipe] then e.fixed_recipe = nil end
	end
end

--- Issue #602: GT New Horizons has no spoiling. The Space Age items Gregtorio makes keep Space Age's spoiling unless it is
--- taken off here: the UV science pack is Space Age's agricultural science pack (127), which turned into spoilage after an
--- hour in chests, on belts and in labs, and me-network does not store items that spoil. devcheck fails for an item that
--- spoils and that a reachable recipe makes, unless it is in the allow-list FORK_SPOILING_KEPT with its reason.
FORK_SPOILING_KEPT = {}
for _, name in pairs({ "agricultural-science-pack" }) do
	for t, _ in pairs(defines.prototypes.item) do
		local it = data.raw[t] and data.raw[t][name]
		if it then
			it.spoil_ticks, it.spoil_result, it.spoil_to_trigger_result, it.spoil_level = nil, nil, nil, nil
		end
	end
end

---SPACE AGE PLANETS AND SPACE PLATFORMS (issue #529)
--- The maintainer's request: the Space Age planets are not part of Gregtorio's game. Its surfaces are Nauvis and the
--- hidden planets of 165 (gt-nether, gt-twilight, gt-end), which copied what they take (Vulcanus' map generation for the
--- Nether) before this file runs; the tiles, decoratives, noise expressions and the control vulcanus_volcanism stay.
--- Deleted for good (FORK-REMOVED in the log): the planets and space locations below, every space connection that
--- touches one, the technologies that only lead to them or to a space platform, and the platform starter pack (the
--- maintainer's decision on #529: Gregtorio has no space platforms, #323 already deleted their recipes; the rocket silo no
--- longer launches to one, the platform prototypes the engine and Space Age's other prototypes name stay, like #323's
--- items); with them every reference a load would fail on: the achievements, tips and ambient sounds of a deleted
--- location (a tip that depends on a deleted tip goes too), the main menu simulations on a deleted planet, a Factoriopedia
--- simulation there (the entity keeps its page), an item's import location (Nauvis instead), a deleted technology as a
--- prerequisite. #508's rule below then deletes the autoplace controls only the planets used. space-age stays a
--- dependency: Gregtorio uses its prototypes (surface properties and conditions, quality, tiles, noise, items).
local REMOVED_LOCATIONS = {
	["vulcanus"] = "planet", ["gleba"] = "planet", ["fulgora"] = "planet", ["aquilo"] = "planet",
	["solar-system-edge"] = "space-location", ["shattered-planet"] = "space-location",
}
local REMOVED_TECHS = {
	"planet-discovery-vulcanus", "planet-discovery-gleba", "planet-discovery-fulgora", "planet-discovery-aquilo",
	"space-platform", "space-platform-thruster", "rocket-silo",
	-- (issue #535: Factorio 2.1's technologies of the solar system edge, a location deleted above, and of the landing pad's
	-- unloading bay, a part of the space platforms' cargo)
	"stellar-discovery-solar-system-edge", "landing-pad-unloading-bay",
}
local removed = {}   -- every deleted name a reference may hold: locations, connections, technologies
for name, t in pairs(REMOVED_LOCATIONS) do
	if data.raw[t] and data.raw[t][name] then
		data.raw[t][name] = nil
		removed[name] = true
		log("FORK-REMOVED: " .. t .. " " .. name)
	end
end
for name, c in pairs(data.raw["space-connection"] or {}) do
	if removed[c.from] or removed[c.to] then
		data.raw["space-connection"][name] = nil
		removed[name] = true
		log("FORK-REMOVED: space-connection " .. name)
	end
end
for _, name in pairs(REMOVED_TECHS) do
	local tech = data.raw.technology[name]
	if tech and not (tech.icon and tech.icon:sub(1, 24) == "__gregtorio-continued__/") then
		data.raw.technology[name] = nil
		removed[name] = true
		log("FORK-REMOVED: technology " .. name)
	end
end
for _, tech in pairs(data.raw.technology) do
	if tech.prerequisites then
		local keep = {}
		for _, p in pairs(tech.prerequisites) do if not removed[p] then keep[#keep + 1] = p end end
		tech.prerequisites = keep
	end
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do if not removed[e.space_location] then keep[#keep + 1] = e end end
		tech.effects = keep
	end
end
--- the platform starter pack (no recipe since #323) and its recycling recipe; the rocket silo's rocket stays on Nauvis
if data.raw["space-platform-starter-pack"] then
	for name in pairs(data.raw["space-platform-starter-pack"]) do
		data.raw["space-platform-starter-pack"][name] = nil
		log("FORK-REMOVED: space-platform-starter-pack " .. name)
		if data.raw.recipe[name .. "-recycling"] then
			data.raw.recipe[name .. "-recycling"] = nil
			log("FORK-REMOVED: recipe " .. name .. "-recycling")
		end
	end
end
for _, silo in pairs(data.raw["rocket-silo"] or {}) do silo.launch_to_space_platforms = false end
--- true when a trigger (nested) names a deleted location, connection or technology
local REFERENCE_KEYS = { surface = true, planet = true, technology = true, space_location = true, space_connection = true }
local function names_removed(v)
	if type(v) ~= "table" then return false end
	for k, x in pairs(v) do
		if (REFERENCE_KEYS[k] and removed[x]) or names_removed(x) then return true end
	end
	return false
end
for t, list in pairs(data.raw) do
	if t:find("achievement", 1, true) then
		for name, a in pairs(list) do
			if removed[a.surface] or removed[a.tracked_connection] or removed[a.technology] then
				list[name] = nil
				log("FORK-REMOVED: " .. t .. " " .. name)
			end
		end
	end
end
--- (issue #535: since Factorio 2.1 a sound names its planets in a list, and the ones it skips in another: a sound whose every
--- planet is deleted goes, the others lose the deleted ones)
local function kept_planets(list)
	local out = {}
	for _, p in pairs(list or {}) do if not removed[p] then out[#out + 1] = p end end
	return out
end
for name, s in pairs(data.raw["ambient-sound"] or {}) do
	if s.planets and #s.planets > 0 and #kept_planets(s.planets) == 0 then
		data.raw["ambient-sound"][name] = nil
		log("FORK-REMOVED: ambient-sound " .. name)
	else
		if s.planets then s.planets = kept_planets(s.planets) end
		if s.exclude_planets then s.exclude_planets = kept_planets(s.exclude_planets) end
	end
end
for _, list in pairs(data.raw) do
	for _, proto in pairs(list) do
		if type(proto) == "table" then
			if removed[proto.default_import_location] then proto.default_import_location = nil end
			if type(proto.factoriopedia_simulation) == "table" and removed[proto.factoriopedia_simulation.planet] then
				proto.factoriopedia_simulation = nil
			end
		end
	end
end
--- tips: those about a deleted location or technology and the space platform tips, then every tip that depends on one
do
	local tips = data.raw["tips-and-tricks-item"] or {}
	local gone = {}
	for name, tip in pairs(tips) do
		if tip.category == "space-platform" or names_removed(tip.trigger) or names_removed(tip.skip_trigger)
			or (tip.simulation and removed[tip.simulation.planet]) then
			gone[name] = true
		end
	end
	local more = true
	while more do
		more = false
		for name, tip in pairs(tips) do
			for _, dep in pairs(tip.dependencies or {}) do
				if gone[dep] and not gone[name] then gone[name] = true; more = true end
			end
		end
	end
	for name in pairs(gone) do
		tips[name] = nil
		log("FORK-REMOVED: tips-and-tricks-item " .. name)
	end
	if data.raw["tips-and-tricks-item-category"] then data.raw["tips-and-tricks-item-category"]["space-platform"] = nil end
end
--- the main menu simulations that play on a deleted planet (their save holds its surface)
do
	local sims = data.raw["utility-constants"].default.main_menu_simulations or {}
	for name, sim in pairs(sims) do
		local planet = type(sim.init) == "string" and sim.init:match('game%.surfaces%["([^"]+)"%]')
		if planet and removed[planet] then
			sims[name] = nil
			log("FORK-REMOVED: main menu simulation " .. name)
		end
	end
end




data.raw["map-gen-presets"].default["gregtorio"] = {
	order = "a",
	basic_settings = {
		peaceful_mode = true,
		autoplace_controls = {
			--- issue #497: GTNH's map veins (prototypes/165-fork-ore-veins.lua) at the defaults of #495 (issue #508: the
			--- vanilla resources' controls are gone, below; issue #563: none in classic mode, whose planets have no veins)
			["gt-ore-veins"] = (not FORK_CLASSIC_ORES) and { frequency = 1, size = 1, richness = 1 } or nil,
		}
	}
}

--- issue #508: the resource controls that nothing generates with any more (102 took the vanilla resources off every
--- planet) are deleted with their entries in the map presets, so the map generator lists only what makes ore; issue
--- #529: every control no planet lists any more (the deleted Space Age planets' resources, terrain, cliffs and enemies)
--- goes the same way, and the prototypes that only those planets placed with it (Gleba's plants and spawners) lose
--- their autoplace. A control whose sliders a noise expression or an autoplace still reads (var('control:<name>:size'):
--- Vulcanus' lava keeps clear of its coal, tungsten and geyser regions) stays, hidden from the map generator: a surface
--- keeps its map generation in the save and the load compiles its noise, so the Nether's copy of Vulcanus' terrain and a
--- surface of a deleted planet in an old save fail to load ("Unknown variable") without it
do
	local used, read = {}, {}
	for _, planet in pairs(data.raw.planet or {}) do
		for name in pairs((planet.map_gen_settings or {}).autoplace_controls or {}) do used[name] = true end
	end
	local function scan(v)
		if type(v) == "string" then
			for name in v:gmatch("control:([%w_%-]+):") do read[name] = true end
		elseif type(v) == "table" then
			for _, x in pairs(v) do scan(x) end
		end
	end
	scan(data.raw["noise-expression"] or {})
	scan(data.raw["noise-function"] or {})
	for _, list in pairs(data.raw) do
		for _, proto in pairs(list) do
			if type(proto) == "table" and type(proto.autoplace) == "table" then scan(proto.autoplace) end
		end
	end
	for name, control in pairs(data.raw["autoplace-control"]) do
		if not used[name] then
			for _, preset in pairs(data.raw["map-gen-presets"].default) do
				local settings = type(preset) == "table" and preset.basic_settings
				if settings and settings.autoplace_controls then settings.autoplace_controls[name] = nil end
			end
			if read[name] then
				control.hidden = true
				log("FORK-HIDDEN: autoplace-control " .. name .. " (its sliders are read by noise)")
			else
				data.raw["autoplace-control"][name] = nil
				log("FORK-REMOVED: autoplace-control " .. name)
			end
		end
	end
	for _, list in pairs(data.raw) do
		for _, proto in pairs(list) do
			if type(proto) == "table" and type(proto.autoplace) == "table" and proto.autoplace.control
				and not data.raw["autoplace-control"][proto.autoplace.control] then
				proto.autoplace = nil
			end
		end
	end
end


-- Disable spawners
for _, name in pairs({"biter-spawner", "spitter-spawner"}) do
  if data.raw["unit-spawner"][name] then
    data.raw["unit-spawner"][name].autoplace = nil
  end
end

-- Disable units
for _, unit in pairs(data.raw["unit"]) do
  unit.autoplace = nil
end

-- Disable worms
for _, name in pairs({"small-worm-turret", "medium-worm-turret", "big-worm-turret"}) do
  if data.raw["turret"][name] then
    data.raw["turret"][name].autoplace = nil
  end
end



---MAKING INSERTERS NOT REQUIRE POWER
--- Fork: the Manual Inserter runs on manual labor instead of for free (vanilla burner
--- inserter energy, about 10 swings per manual labor; no free initial fuel)
data.raw["inserter"]["burner-inserter"].energy_source = {
	type = "burner",
	fuel_categories = { "manual-labor" },
	burner_usage = data.raw["burner-usage"]["manual-labor"] and "manual-labor" or nil,
	effectivity = 1,
	fuel_inventory_size = 1,
	light_flicker = { color = { 0, 0, 0 } },
}
--data.raw["inserter"]["inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["long-handed-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["fast-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["bulk-inserter"].energy_source = {type = "void"}
--data.raw["inserter"]["stack-inserter"].energy_source = {type = "void"}
---MAKING YELLOW UNDERGROUND RUN 7 DISTANCE
data.raw["underground-belt"]["underground-belt"].max_distance = 7



---DISABLE TRIGGERED TECHS
--- Fork: don't disable Gregtorio's own techs that share a name with a vanilla tech (e.g. "tungsten-carbide")
local function is_gregtorio_tech(t)
  return t.icon and t.icon:sub(1, 24) == "__gregtorio-continued__/"
end
local function disable_trigger_tech(name)
  if data.raw.technology[name] and not is_gregtorio_tech(data.raw.technology[name]) then
    data.raw.technology[name].enabled = false
    data.raw.technology[name].hidden = true
	data.raw.technology[name].research_trigger = nil
	data.raw.technology[name].unit = {count = 10, ingredients = {{"automation-science-pack", 1}}, time = 10 }
  end
end
disable_trigger_tech("steam-power")
disable_trigger_tech("electronics")
disable_trigger_tech("cryogenic-plant")
disable_trigger_tech("yumako")
disable_trigger_tech("tungsten-steel")
disable_trigger_tech("tungsten-carbide")
disable_trigger_tech("recycling")
disable_trigger_tech("jellynut")
disable_trigger_tech("holmium-processing")
disable_trigger_tech("heating-tower")
disable_trigger_tech("foundry")
disable_trigger_tech("electromagnetic-plant")
disable_trigger_tech("calcite-processing")
disable_trigger_tech("bioflux")
disable_trigger_tech("bioflux-processing")
disable_trigger_tech("biochamber")
disable_trigger_tech("bacteria-cultivation")
disable_trigger_tech("artificial-soil")
disable_trigger_tech("agriculture")
disable_trigger_tech("biter-egg-handling")



---DISABLE TECHS
-- the effects of the disabled techs, for the main menu simulations (prototypes/fork-menu-simulations.lua)
FORK_DISABLED_TECH_EFFECTS = {}
local function disable_tech(name)
  if data.raw.technology[name] and not is_gregtorio_tech(data.raw.technology[name]) then
    for _, effect in pairs(data.raw.technology[name].effects or {}) do
      table.insert(FORK_DISABLED_TECH_EFFECTS, effect)
    end
    data.raw.technology[name].enabled = false
    data.raw.technology[name].hidden = true
    data.raw.technology[name].effects = {}
  end
end
disable_tech("automation-science-pack")
disable_tech("electric-mining-drill")
disable_tech("big-mining-drill")
disable_tech("heavy-armor")
disable_tech("advanced-material-processing")
disable_tech("advanced-material-processing-2")
disable_tech("low-density-structure")
disable_tech("engine")
disable_tech("sulfur-processing")
disable_tech("advanced-circuit")
disable_tech("plastics")
disable_tech("mining-productivity-1")
disable_tech("mining-productivity-2")
disable_tech("mining-productivity-3")
disable_tech("quality-module")
disable_tech("quality-module-2")
disable_tech("quality-module-3")
disable_tech("electric-engine")
disable_tech("lubricant")
disable_tech("advanced-oil-processing")
disable_tech("robotics")
disable_tech("laser")
disable_tech("uranium-mining")
disable_tech("processing-unit")
disable_tech("nuclear-fuel-reprocessing")
disable_tech("kovarex-enrichment-process")
disable_tech("asteroid-reprocessing")
disable_tech("coal-liquefaction")
disable_tech("epic-quality")
disable_tech("advanced-asteroid-processing")
disable_tech("overgrowth-soil")
disable_tech("biolab")
disable_tech("lightning-collector")
disable_tech("rail-support-foundations")
disable_tech("lithium-processing")
disable_tech("quantum-processor")
disable_tech("foundation")
disable_tech("legendary-quality")
disable_tech("captive-biter-spawner")
disable_tech("steel-plate-productivity")
disable_tech("low-density-structure-productivity")
disable_tech("plastic-bar-productivity")
disable_tech("rocket-fuel-productivity")
disable_tech("asteroid-productivity")
disable_tech("railgun-damage-1")
disable_tech("railgun-shooting-speed-1")
disable_tech("scrap-recycling-productivity")
disable_tech("processing-unit-productivity")
disable_tech("rocket-part-productivity")
disable_tech("railgun")
disable_tech("captivity")
disable_tech("fish-breeding")
disable_tech("carbon-fiber")
disable_tech("solar-energy")
disable_tech("toolbelt")
disable_tech("toolbelt-equipment")
disable_tech("modules")
disable_tech("speed-module")
disable_tech("speed-module-2")
disable_tech("speed-module-3")
disable_tech("productivity-module")
disable_tech("productivity-module-2")
disable_tech("productivity-module-3")
disable_tech("efficiency-module")
disable_tech("efficiency-module-2")
disable_tech("efficiency-module-3")
disable_tech("electric-energy-accumulators")
disable_tech("solar-panel-equipment")
disable_tech("effect-transmission")
disable_tech("automation-3")



---GUN TURRET
data.raw.technology["gun-turret"].prerequisites = { "military" }



---MILITARY
data.raw.technology["military"].prerequisites = { "craft-automation-science-packs" }



---STONE WALL
data.raw.technology["stone-wall"].prerequisites = { "military" }



---REPAIR PACK
data.raw.technology["repair-pack"].prerequisites = { "craft-automation-science-packs" }



---LANDFILL
data.raw.technology["landfill"].unit = {count = 80, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 20 }
data.raw.technology["landfill"].prerequisites = { "rock-crusher" }



---LAMP
--- (issue #555: the torch from coal and from charcoal, 100)
data.raw.technology["lamp"].effects = { { type = "unlock-recipe", recipe = "torch" },
	{ type = "unlock-recipe", recipe = "torch-from-charcoal" } }
data.raw.technology["lamp"].unit = {count = 5, ingredients = {{"automation-science-pack", SP01 }}, time = 5 }
data.raw.technology["lamp"].icon = "__gregtorio-continued__/graphics/technology/torches.png"
data.raw.technology["lamp"].prerequisites = { "craft-automation-science-packs" }



---RADAR
data.raw.technology["radar"].effects = {
      { type = "unlock-recipe", recipe = "lv-sensor" },
	  { type = "unlock-recipe", recipe = "radar" },
  }
data.raw.technology["radar"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }
data.raw.technology["radar"].prerequisites = { "automation-2" }



---FLUID HANDLING
data.raw.technology["fluid-handling"].effects = {
      { type = "unlock-recipe", recipe = "configurable-valve" },
	  { type = "unlock-recipe", recipe = "storage-tank" },
	  { type = "unlock-recipe", recipe = "pump" },
  }
data.raw.technology["fluid-handling"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }
data.raw.technology["fluid-handling"].prerequisites = { "automation-2" }



---CIRCUIT NETWORK
data.raw.technology["circuit-network"].prerequisites = { "circuit-assembler" }
data.raw.technology["circuit-network"].unit = {count = 160, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }



---FLUID WAGON
data.raw.technology["fluid-wagon"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 } }, time = 30 }



---AUTOMATED RAIL TRANSPORTATION
data.raw.technology["automated-rail-transportation"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 } }, time = 30 }



---LAB RESEARCH SPEED 1
data.raw.technology["research-speed-1"].prerequisites = { "logistic-science-pack" }
data.raw.technology["research-speed-1"].unit = {count = 100, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 20 }



---LAB RESEARCH SPEED 2
data.raw.technology["research-speed-2"].prerequisites = { "research-speed-1", "military-science-pack" }
data.raw.technology["research-speed-2"].unit = {count = 200, ingredients = { {"automation-science-pack", SP03 }, {"logistic-science-pack", SP02 }, {"military-science-pack", SP01 }}, time = 30 }



---LAB RESEARCH SPEED 3
data.raw.technology["research-speed-3"].prerequisites = { "research-speed-2", "chemical-science-pack" }
data.raw.technology["research-speed-3"].unit = {count = 400, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 }}, time = 30 }




---MILITARY 2
data.raw.technology["military-2"].prerequisites = { "military", "logistic-science-pack" }



---WEAPON SHOOTING SPEED 2
data.raw.technology["weapon-shooting-speed-2"].prerequisites = { "military-2", "weapon-shooting-speed-1" }



---PHYSICAL PROJECTILE DAMAGE 2
data.raw.technology["physical-projectile-damage-2"].prerequisites = { "military-2", "physical-projectile-damage-1" }



---DEFENDER
data.raw.technology["defender"].prerequisites = { "military-2" }


---STRONGER EXPLOSIVES 2
data.raw.technology["stronger-explosives-2"].prerequisites = { "stronger-explosives-1" }



---WEAPON SHOOTING SPEED 3
data.raw.technology["weapon-shooting-speed-3"].prerequisites = { "weapon-shooting-speed-2" }



---PHYSICAL PROJECTILE DAMAGE 3
data.raw.technology["physical-projectile-damage-3"].prerequisites = { "physical-projectile-damage-2" }



---AUTOMOBILISM
data.raw.technology["automobilism"].prerequisites = { "automation-2" }
data.raw.technology["automobilism"].unit = {count = 160, ingredients = { {"automation-science-pack", SP02 }, {"logistic-science-pack", SP01 } }, time = 30 }


---ADVANCED COMBINATORS
data.raw.technology["advanced-combinators"].unit = {count = 400, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 } }, time = 30 }


---CLIFF EXPLOSIVES
data.raw.technology["cliff-explosives"].prerequisites = { "implosion-compressor" }
data.raw.technology["cliff-explosives"].unit = {count = 540, ingredients = { {"automation-science-pack", SP04 }, {"logistic-science-pack", SP03 }, {"military-science-pack", SP02 }, {"chemical-science-pack", SP01 } }, time = 30 }


---RESEARCH PRODUCTIVITY
data.raw.technology["research-productivity"].prerequisites = { "cryogenic-science-pack" }
data.raw.technology["research-productivity"].unit = {count_formula = "2000*2^(L-1)", ingredients = { {"automation-science-pack", SP11}, {"logistic-science-pack", SP10}, {"military-science-pack", SP09},
		{"chemical-science-pack", SP08}, {"production-science-pack", SP07}, {"utility-science-pack", SP06}, {"space-science-pack", SP05}, {"metallurgic-science-pack", SP04}, {"agricultural-science-pack", SP03},
		{"electromagnetic-science-pack", SP02}, {"cryogenic-science-pack", SP01} }, time = 720 }


------------------------------------------------
--- OPTIONAL DISABLING OF ALL MILITARY TECHS ---
------------------------------------------------
---[not actually optional for now]

disable_tech("gun-turret")
disable_tech("stone-wall")
disable_tech("gate")
disable_tech("military")
disable_tech("military-2")
disable_tech("military-3")
disable_tech("military-4")
disable_tech("defender")
disable_tech("physical-projectile-damage-1")
disable_tech("physical-projectile-damage-2")
disable_tech("physical-projectile-damage-3")
disable_tech("physical-projectile-damage-4")
disable_tech("physical-projectile-damage-5")
disable_tech("physical-projectile-damage-6")
disable_tech("physical-projectile-damage-7")
disable_tech("weapon-shooting-speed-1")
disable_tech("weapon-shooting-speed-2")
disable_tech("weapon-shooting-speed-3")
disable_tech("weapon-shooting-speed-4")
disable_tech("weapon-shooting-speed-5")
disable_tech("weapon-shooting-speed-6")
disable_tech("weapon-shooting-speed-7")
disable_tech("flammables")
disable_tech("flamethrower")
disable_tech("refined-flammables-1")
disable_tech("refined-flammables-2")
disable_tech("refined-flammables-3")
disable_tech("refined-flammables-4")
disable_tech("refined-flammables-5")
disable_tech("refined-flammables-6")
disable_tech("refined-flammables-7")
disable_tech("stronger-explosives-1")
disable_tech("stronger-explosives-2")
disable_tech("stronger-explosives-3")
disable_tech("stronger-explosives-4")
disable_tech("stronger-explosives-5")
disable_tech("stronger-explosives-6")
disable_tech("stronger-explosives-7")
disable_tech("rocketry")
disable_tech("rocket-turret")
disable_tech("atomic-bomb")
disable_tech("uranium-ammo")
disable_tech("health")
disable_tech("artillery")
disable_tech("artillery-shell-damage-1")
disable_tech("artillery-shell-range-1")
disable_tech("artillery-shell-speed-1")
disable_tech("distractor")
disable_tech("destroyer")
disable_tech("follower-robot-count-1")
disable_tech("follower-robot-count-2")
disable_tech("follower-robot-count-3")
disable_tech("follower-robot-count-4")
disable_tech("follower-robot-count-5")
disable_tech("electric-weapons-damage-1")
disable_tech("electric-weapons-damage-2")
disable_tech("electric-weapons-damage-3")
disable_tech("electric-weapons-damage-4")
disable_tech("land-mine")
disable_tech("laser-turret")
disable_tech("laser-shooting-speed-1")
disable_tech("laser-shooting-speed-2")
disable_tech("laser-shooting-speed-3")
disable_tech("laser-shooting-speed-4")
disable_tech("laser-shooting-speed-5")
disable_tech("laser-shooting-speed-6")
disable_tech("laser-shooting-speed-7")
disable_tech("laser-weapons-damage-1")
disable_tech("laser-weapons-damage-2")
disable_tech("laser-weapons-damage-3")
disable_tech("laser-weapons-damage-4")
disable_tech("laser-weapons-damage-5")
disable_tech("laser-weapons-damage-6")
disable_tech("laser-weapons-damage-7")
disable_tech("personal-laser-defense-equipment")
disable_tech("discharge-defense-equipment")
disable_tech("explosive-rocketry")
disable_tech("tank")
disable_tech("tesla-weapons")
--- Fork: the technologies whose units were set above are divided like the others (prototypes/149-fork-early-research.lua,
--- issue #146)
FORK_EARLY_RESEARCH.rescale()
--- Fork: the research counts from UV up once more, for the technologies of the files after 138
--- (prototypes/138-fork-research-balance.lua, issue #605)
FORK_RESEARCH_BALANCE.apply(true)
--- Fork: the prerequisites of issue #252 (prototypes/142-fork-recipe-unlocks.lua), after the vanilla ones are set above
FORK_UNLOCK_TREE.apply(true)
--- Fork: the recycling recipes get their technologies now that the vanilla ones are set and disabled
--- (prototypes/157-fork-recycling.lua, issue #190)
FORK_RECYCLING.unlock()
--- Fork (issue #640): a vanilla technology behind a disabled one can never be researched (the armor and equipment
--- technologies, explosives, the fusion reactor, the spidertron), so it is disabled too instead of standing in the tree
--- for good; repeated until no such technology is left. Their effects go to the main menu simulations like the others
do
	local changed = true
	while changed do
		changed = false
		for name, tech in pairs(data.raw.technology) do
			if tech.enabled ~= false and not tech.hidden and not is_gregtorio_tech(tech) then
				for _, pre in pairs(tech.prerequisites or {}) do
					local p = data.raw.technology[pre]
					if not p or p.hidden then
						log("FORK-UNRESEARCHABLE: " .. name .. " (behind " .. pre .. ") disabled")
						disable_tech(name)
						changed = true
						break
					end
				end
			end
		end
	end
end
--- Fork: the steam macerator runs copies of the LV macerator recipes without their byproducts, as GT's bronze machines
--- (prototypes/101-fork-machines.lua, issue #447); after every unlock above; the copies of the ore forms come in the steam
--- age, with the smelting of what they make (issue #571)
fork_steam_categories()
--- Fork: the ore machines are furnaces that pick their recipe from the input (prototypes/101-fork-machines.lua, issue
--- #560); after the steam macerators' categories above
fork_furnace_machines()
--- Fork: every Gregtorio recipe named after its product unless it has its own name (prototypes/fork-locale.lua, issue #230)
FORK_LOCALE.name_recipes()
--- Fork: every tiered machine says what it does (prototypes/167-fork-tips.lua, issue #625); after every machine
FORK_TIPS.describe_machines()
require("prototypes.fork-menu-simulations")
--- Fork: cheap research (startup setting, default off); after every change to the technologies above
require("prototypes.fork-one-pack-research")
--- Fork: the boiler output setting (issue #593): every steam boiler makes its steam and burns its fuel that many times
--- faster; after every file that makes or changes a boiler and before the steam per second of the descriptions below
require("prototypes.fork-boiler-output")
--- Fork: GT New Horizons' overclocking (issue #616, startup setting, default off): the machines' power grows 4 times per
--- tier; after every file that makes or changes a machine
require("prototypes.fork-gt-overclocking")
--- Fork: steam per second in the descriptions of the boilers and the steam machines (issue #564), after every file that
--- makes or changes them
require("prototypes.fork-steam-rates")
--- Fork: Factorio 2.1 (issue #535): the recycler mod's technology `recycling` unlocks every recycling recipe with a hidden
--- effect; the ones of recipes deleted above (the burner mining drill's, the electric furnace's, ...) go too (a technology
--- that names a missing recipe fails the load). A shown effect of a missing recipe stays an error.
for tname, tech in pairs(data.raw.technology) do
	local kept, dropped = {}, false
	for _, e in pairs(tech.effects or {}) do
		if e.type == "unlock-recipe" and e.hidden and not data.raw.recipe[e.recipe] then
			dropped = true
			log("FORK-REMOVED: hidden unlock of " .. e.recipe .. " in technology " .. tname)
		else
			kept[#kept + 1] = e
		end
	end
	if dropped then tech.effects = kept end
end
