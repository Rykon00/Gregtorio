--------------------------------------------------------------------------------
--- FORK ELECTRIC MINE (issue #335): GT New Horizons' Ore Drilling Plant I to IV (GT5-Unofficial
--- MTEOreDrillingPlant1-4, MTEOreDrillingPlantBase.java) as the powered alternative to the Manual Mine.
---
--- The plant (decisions of #335, following GTNH as closely as Gregtorio's vein recipes allow):
---   * one machine per Mk, `ore-drilling-plant-mk1` to `-mk4`, at GTNH's minimum energy hatch: MV, HV, EV, IV;
---   * GTNH mines one ore block per operation and drinks 2000 L Drilling Fluid for it (tryConsumeDrillingFluid); here an
---     operation is one vein recipe of the Manual Mine with the same results, 200 Drilling Fluid (Gregtorio's tenth of
---     GT's litres) instead of the pickaxe and the manual labor; issue #341: like the Miners below it lowers mining pipes
---     (MTEDrillerBase tryLowerPipeState), so a vein takes a Mining Pipe too (issue #346: consumed; issue #393: one,
---     see the Miners);
---   * the Mk changes the speed and the energy only, never the yield of an operation (GTNH's Mk gives radius and fortune
---     on small ores, which the vein recipes do not model): GT's operation takes base / 2^tier ticks at the energy tier
---     (calculateMaxProgressTime; base 960, 800, 640, 480), so 240 ticks (12 s) for the Mk I at MV, 100 for the Mk II at HV,
---     40 for the Mk III at EV, 15 for the Mk IV at IV; one recipe of 12 s x MV speed and the crafting speed of the Mk;
---   * GT's energy 3 x 4^tier EU/t (setElectricityStats) is 0.375 A of the tier, Gregtorio's class EU12 (12 EU/t of LV,
---     doubled per tier like the other machines);
---   * the recipe of the plant is GTNH's controller recipe (NewHorizonsCoreMod AssemblerRecipes.java: the hull or the plant
---     of the Mk before, 4 frames, 4 circuits, 4 motors, 4 pumps, 4 conveyor modules, 4 gears, soldering alloy 72 L
---     doubled per Mk) with the parts of the plant's own tier; GTNH builds the Mk I from EV parts up to the Mk IV from ZPM
---     parts, #335 starts it at MV, so frames and gears are those of GTNH's Oil Drilling Rig of the same tier (Gregtorio's
---     Drilling Rig controllers: steel and vanadium steel, stainless and blue steel, titanium, tungstensteel); one item,
---     like the Void Miners (160), the multiblock's frames and casings left out.
--- Placing it onto a Manual Mine: the plant has the Manual Mine's footprint (5x5, collision box +-2.3) and fast replace
--- group, and the Manual Mine's next upgrade is the Mk I (then Mk II to IV), so a Manual Mine with its inserters, belts and
--- poles is replaced in place by fast replace or the upgrade planner. Its Drilling Fluid input has a pipe connection in
--- the middle of each side, for whichever side is free. The engine resets the recipe (the electric recipes are other
--- prototypes); issue #342: scripts/fork-electric-mine.lua gives the new machine the same vein's recipe of its category.
---
--- The electric recipes: one per recipe of the Manual Mine (07 and 160), `mining-<vein>` -> `drilling-<vein>`, except the
--- allow-list FORK_ELECTRIC_MINE_EXCLUDED below (mobs, plain blocks and the dig site's ground work, each with its reason);
--- devcheck fails for a Manual Mine or Dig Site recipe that has neither a twin nor an entry, and for a stale entry.
---
--- Drilling Fluid: GTNH's mixer recipe (GT5-Unofficial MixerRecipes.java:640-648: 5 water cells, 1 stone dust, 20 L
--- lubricant -> 5000 L, 3.2 s at LV/2) in Gregtorio's tenth: 500 water, 1 stone dust, 2 lubricant -> 500, LV mixer.
--- Rule #252: it comes with the Mk I's technology, which has the Mixer as a prerequisite.
---
--- Unlocks: the technology of the Mk I unlocks the plant, the fluid and the twins of the veins that come before it
--- (its prerequisite closure: the Overworld veins, the Nether's molybdenum, the Twilight Forest and the manganese vein;
--- the Nether, NAND Chips and Manganese Processing are prerequisites of it, see below); the twin of a later vein comes
--- with the vein's technology, which gets the Mk I's technology as a prerequisite (142's FORK_UNLOCK_TREE: Reach the
--- Moon, the reach technologies after it inherit it; the End has no twin).
---
--- The Miners (issue #337, the maintainer's decision): GT's Basic, Good and Advanced Miner (MTEMiner.java,
--- `basicmachine.miner.tier.01-03`), here LV, MV and HV Miner (CLAUDE.md: no Basic/Good/Advanced prefixes), on the same
--- footprint and in the same upgrade chain: Manual Mine -> LV -> MV -> HV Miner -> Ore Drilling Plant Mk I -> ... -> IV.
---   * they mine the same veins (their own twins `miner-<vein>`, category `miner-recipes`, the same exclusions: GT's Miner
---     mines ore blocks only, GTUtility.isOre);
---   * a vein takes 24 s in the LV Miner (the maintainer's choice: half the Mk I's speed), GT halves it per tier
---     (SPEED 160, 80, 40 ticks): 12 s and 6 s, the tier speeds 1, 2, 4;
---   * GT's energy 8, 32, 128 EU/t is a quarter amp of the tier, class EU8;
---   * mining pipes (DrillingLogicDelegate: one pipe per block of depth): a vein recipe takes 1 mining pipe. GTNH keeps
---     them in the ground and pulls them up at the end; a recipe cannot keep a stock, and giving them back every vein
---     needed an inserter loop, so (issue #346, the maintainer's decision) they are consumed. A GT ore vein is 9 layers
---     high (WorldgenGTOreLayer layers -1 to 7), but the vein recipes do not model its layers: the one pipe stands for the
---     drill string of a vein (issue #393, the maintainer's decision; 9 consumed pipes made the pipe line the main load
---     of an electric mine);
---   * the Mining Pipe: GT's wiremill recipe (WiremillRecipes.java: 1 tiny steel pipe -> 1 mining pipe, 10 s, LV/2);
---     Gregtorio has no tiny pipes, a steel rod holds the same half ingot of steel;
---   * machine recipes as GT's (MTERecipeLoader.java: LV "EEE/WMW/CSC" 3 motors, 2 tin cables, the hull, 2 circuits, a
---     sensor; MV "PEP" 2 pistons and a motor, 2 double copper cables; HV "RPR" 2 robot arms and a piston, 2 quadruple
---     gold cables; Gregtorio has single cables only: 4 copper, 8 gold);
---   * the LV Miner's technology unlocks it, the pipe and the twins of the veins before it; a later vein's twin comes
---     with its vein's technology (142 calls FORK_ELECTRIC_MINE.unlock_miner_twins after its moves, so the beryllium vein
---     counts with Laser Engraver); every later vein's technology follows Phosphorus Processing, which gets the LV
---     Miner's technology as a prerequisite (142's FORK_UNLOCK_TREE). The MV Miner comes with Advanced MV Machines
---     (its MV sensor), the HV Miner with HV Machines.
--- Loads after 160 (the dimension veins) and before 142 (the unlock table) and 155 (the ore chains: unlock_after).
--------------------------------------------------------------------------------

local F = FORK5B
local P1, P2, P3, P4 = "ore-drilling-plant-mk1", "ore-drilling-plant-mk2", "ore-drilling-plant-mk3", "ore-drilling-plant-mk4"
local CATEGORY = "electric-mine-recipes"
local FLUID, FLUID_PER_OP = "drilling-fluid", 200

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end

--- the Manual Mine and Dig Site recipes that get no electric twin: recipe -> reason (devcheck reads it; GT's Miner mines
--- ore blocks only as well, MTEMiner.java)
FORK_ELECTRIC_MINE_EXCLUDED = {
	["hunting-blazes"] = "a mob drop (blaze rods), no ore: the Ore Drilling Plant mines ore blocks only (GTUtility.isOre)",
	["hunting-endermen"] = "a mob drop (ender pearls), no ore: the Ore Drilling Plant mines ore blocks only",
	["hunting-zombies"] = "a mob drop (zombie heads), no ore: the Ore Drilling Plant mines ore blocks only",
	["cobblestone-manual-mine"] = "stone, no ore: the Ore Drilling Plant mines ore blocks only",
	["cobblestone-manual-mine-with-wooden-pickaxe"] = "stone, no ore: the Ore Drilling Plant mines ore blocks only",
	["mining-end-stone"] = "end stone is a plain block of the End, no ore: the Ore Drilling Plant mines ore blocks only",
	["mining-glowstone-vein"] = "glowstone is vanilla's Nether block, no GT ore (07: no raw item, no ore chain): the Ore " ..
		"Drilling Plant mines ore blocks only",
	["manually-digging-gravel"] = "ground work at the Dig Site (gravel by hand), no ore",
	["gravel-with-shovel"] = "ground work at the Dig Site (gravel with the shovel), no ore",
	["sand-manual-digsite"] = "ground work at the Dig Site (sand), no ore",
	["clay-ball-manual-digsite"] = "ground work at the Dig Site (clay), no ore",
	["digging-soul-sand"] = "ground work at the Dig Site (the Nether's soul sand), no ore",
	["digging-moon-turf"] = "ground work at the Dig Site (the Moon's turf), no ore",
	["digging-obsidian"] = "ground work at the Dig Site (issue #501: obsidian of the lava pools, for the Nether Portal), no ore",
}

--- manual recipe -> electric recipe of the plants and of the miners (devcheck reads both)
FORK_ELECTRIC_MINE = { twins = {}, miner_twins = {} }
--- (issue #393: one pipe per vein, the drill string of the vein; GTNH's 9 layers are not modelled, see the header)
local MINER_CATEGORY, PIPE, PIPES_PER_VEIN = "miner-recipes", "mining-pipe", 1
local MINER_TECH = "lv-miner"

--------------------------------------------------------------------------------
--- DRILLING FLUID
--------------------------------------------------------------------------------

F.fluid(FLUID, "drilling-fluid", { 1.00, 0.93, 0.69 })   -- GT's texture (tools/gen_gt_icons.py --fluid) and its colour
create_recipe{
	name = FLUID,
	category = "lv-mixer-recipes",
	energy_required = 3.2 * LV_SPEED,
	ingredients = { fluid("water", 500), item("stone-dust", 1), fluid("lubricant", 2) },
	results = { fluid(FLUID, 500) },
	main_product = FLUID,
}

--------------------------------------------------------------------------------
--- THE PLANTS
--------------------------------------------------------------------------------

F.category(CATEGORY)
--- issue #499 (plan #494, the maintainer's option A): the recipe machines of the veins become the dimension mines, which
--- keep the vein recipes of the other dimensions; their old names go to the mining drills of the map veins (below)
local DIMENSION = { ["manual-mine"] = "dimension-mine", ["lv-miner"] = "lv-dimension-miner",
	["mv-miner"] = "mv-dimension-miner", ["hv-miner"] = "hv-dimension-miner", [P1] = "dimension-drilling-plant-mk1",
	[P2] = "dimension-drilling-plant-mk2", [P3] = "dimension-drilling-plant-mk3", [P4] = "dimension-drilling-plant-mk4" }
FORK_ELECTRIC_MINE.dimension = DIMENSION
local manual_mine = table.deepcopy(data.raw["assembling-machine"]["manual-mine"])
data.raw["assembling-machine"]["manual-mine"] = nil
manual_mine.name = DIMENSION["manual-mine"]
manual_mine.minable = { mining_time = 0.2, result = manual_mine.name }
manual_mine.fast_replaceable_group = "dimension-mine"
manual_mine.next_upgrade = DIMENSION["lv-miner"]   -- issue #337: the miners, then the plants
manual_mine.localised_description = { "entity-description." .. manual_mine.name }
data:extend({ manual_mine })
create_item{ name = manual_mine.name, icon = manual_mine.icon, icon_size = 64, place_result = manual_mine.name,
	subgroup = "stone-age-production-machine", stack_size = 10,
	ingredients = table.deepcopy(data.raw.recipe["manual-mine"].ingredients) }   -- (unlocked as the Manual Mine was, below)

--- a pipe connection for the Drilling Fluid in the middle of each side
local function fluid_input()
	local connections = {}
	for _, c in pairs({ { 0, -2, defines.direction.north }, { 2, 0, defines.direction.east },
		{ 0, 2, defines.direction.south }, { -2, 0, defines.direction.west } }) do
		connections[#connections + 1] = { flow_direction = "input", direction = c[3], position = { c[1], c[2] } }
	end
	return { {
		production_type = "input", volume = 1000, pipe_connections = connections,
		pipe_covers = pipecoverspictures(), pipe_picture = assembler2pipepictures(),
	} }
end

--- name, base ticks of GT's operation, tier, its speed, energy, next upgrade, subgroup and the recipe:
--- { category, first ingredient (hull or the plant before), frame, circuit, motor, pump, conveyor, gear, solder }
local PLANTS = {
	{ P1, 960, 2, MV_SPEED, EU12_MV, P2, "subgroup-mv-age-multiblocks", { "mv-assembling-machine-recipes", MV_SPEED,
		"mv-machine-hull", "steel-frame", "advanced-circuit", "mv-motor", "mv-pump", "mv-conveyor-module",
		"large-vanadium-steel-gear", 7.2 } },
	{ P2, 800, 3, HV_SPEED, EU12_HV, P3, "subgroup-hv-age-multiblocks", { "hv-assembling-machine-recipes", HV_SPEED,
		P1, "stainless-steel-frame", "processing-unit", "hv-motor", "hv-pump", "hv-conveyor-module",
		"large-blue-steel-gear", 14.4 } },
	{ P3, 640, 4, EV_SPEED, EU12_EV, P4, "subgroup-ev-age-multiblocks", { "ev-assembling-machine-recipes", EV_SPEED,
		P2, "titanium-frame", "ev-circuit", "ev-motor", "ev-pump", "ev-conveyor-module", "large-titanium-gear", 28.8 } },
	{ P4, 480, 5, IV_SPEED, EU12_IV, nil, "subgroup-iv-age-multiblocks", { "iv-assembling-machine-recipes", IV_SPEED,
		P3, "tungstensteel-frame", "iv-circuit", "iv-motor", "iv-pump", "iv-conveyor-module", "large-tungstensteel-gear",
		57.6 } },
}
--- one operation: GT's ticks of the Mk I at MV, as a recipe of the MV tier (time x MV speed at crafting speed MV)
local MK1_TICKS = 960 / 2 ^ 2
local OP_TIME = MK1_TICKS / 20 * MV_SPEED

--- issue #499: the plant's recipe makes its mining drill (THE MINING DRILLS below) and, by the same recipe with the
--- dimension mine before it, its dimension mine
local function plant_recipe(r, first)
	return { item(first, 1), item(r[4], 4), item(r[5], 4), item(r[6], 4), item(r[7], 4), item(r[8], 4), item(r[9], 4),
		fluid("soldering-alloy", r[10]) }
end
for _, p in ipairs(PLANTS) do
	local drill, base, tier, energy, upgrade, subgroup, r = p[1], p[2], p[3], p[5], p[6], p[7], p[8]
	local name = DIMENSION[drill]
	local m = table.deepcopy(manual_mine)
	m.name = name
	m.icon = "__gregtorio-continued__/graphics/icons/fork/" .. drill .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = name }
	m.max_health = 400
	m.crafting_categories = { CATEGORY }
	--- GT's operation takes base / 2^tier ticks: the speed that makes the recipe of the Mk I's operation take that long
	m.crafting_speed = OP_TIME / (base / 2 ^ tier / 20)
	m.energy_source = { type = "electric", usage_priority = "secondary-input", emissions_per_minute = { pollution = 1 },
		drain = "0W" }
	m.energy_usage = energy
	m.fast_replaceable_group = "dimension-mine"
	m.next_upgrade = upgrade and DIMENSION[upgrade]
	m.fluid_boxes = fluid_input()
	m.graphics_set = {
		idle_animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. drill .. "-idle.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. drill .. "-working.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
	}
	m.working_sound = {
		sound = { filename = "__base__/sound/assembling-machine-t1-1.ogg", volume = 0.5 },
		idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.3 },
		apparent_volume = 1.5,
	}
	m.circuit_wire_connection_points = circuit_connector_definitions["assembling-machine"].points
	m.circuit_connector_sprites = circuit_connector_definitions["assembling-machine"].sprites
	m.circuit_wire_max_distance = default_circuit_wire_max_distance
	m.localised_description = { "entity-description." .. name }
	data:extend({ m })
	for _, x in pairs({ { name, DIMENSION[r[3]] or r[3] }, { drill, r[3] } }) do
		create_item{
			name = x[1],
			icon = m.icon,
			place_result = x[1],
			subgroup = subgroup,
			stack_size = 10,
			category = r[1],
			energy_required = 20 * r[2],
			ingredients = plant_recipe(r, x[2]),
		}
	end
end

--------------------------------------------------------------------------------
--- THE MINERS (issue #337)
--------------------------------------------------------------------------------

F.category(MINER_CATEGORY)
create_item{
	name = PIPE,
	category = "lv-wiremill-recipes",
	energy_required = 10 * LV_SPEED,
	ingredients = { item("steel-rod", 1) },
}
--- tier, speed, energy, next upgrade, the machine recipe
local MINERS = {
	{ "lv", LV_SPEED, EU8_LV, "mv-miner", { item("lv-motor", 3), item("tin-cable", 2), item("lv-machine-hull", 1),
		item("electronic-circuit", 2), item("lv-sensor", 1) } },
	{ "mv", MV_SPEED, EU8_MV, "hv-miner", { item("mv-piston", 2), item("mv-motor", 1), item("copper-cable", 4),
		item("mv-machine-hull", 1), item("advanced-circuit", 2), item("mv-sensor", 1) } },
	{ "hv", HV_SPEED, EU8_HV, P1, { item("hv-robot-arm", 2), item("hv-piston", 1), item("gold-cable", 8),
		item("hv-machine-hull", 1), item("processing-unit", 2), item("hv-sensor", 1) } },
}
--- one vein: 24 s in the LV Miner (the maintainer's choice), as a recipe of the LV tier
local MINER_TIME = 24 * LV_SPEED

--- issue #499: the miners' mining pipes go into their recipe (GTNH pulls them back up; reverses #346 and #393)
local MINER_PIPES = 9
for _, p in ipairs(MINERS) do
	local tier, speed, energy, upgrade, ingredients = p[1], p[2], p[3], p[4], p[5]
	local drill = tier .. "-miner"
	local name = DIMENSION[drill]
	local m = table.deepcopy(manual_mine)
	m.name = name
	m.icon = "__gregtorio-continued__/graphics/icons/fork/" .. drill .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 0.5, result = name }
	m.max_health = 300
	m.crafting_categories = { MINER_CATEGORY }
	m.crafting_speed = speed
	m.energy_source = { type = "electric", usage_priority = "secondary-input", emissions_per_minute = { pollution = 1 },
		drain = "0W" }
	m.energy_usage = energy
	m.fast_replaceable_group = "dimension-mine"
	m.next_upgrade = DIMENSION[upgrade]
	m.graphics_set = {
		idle_animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. drill .. "-idle.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. drill .. "-working.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
	}
	m.working_sound = {
		sound = { filename = "__base__/sound/assembling-machine-t1-1.ogg", volume = 0.5 },
		idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.3 },
		apparent_volume = 1.5,
	}
	m.circuit_wire_connection_points = circuit_connector_definitions["assembling-machine"].points
	m.circuit_connector_sprites = circuit_connector_definitions["assembling-machine"].sprites
	m.circuit_wire_max_distance = default_circuit_wire_max_distance
	m.localised_description = { "entity-description." .. name }
	data:extend({ m })
	local with_pipes = table.deepcopy(ingredients)
	with_pipes[#with_pipes + 1] = item(PIPE, MINER_PIPES)
	for _, x in pairs({ { name, ingredients }, { drill, with_pipes } }) do
		create_item{
			name = x[1],
			icon = m.icon,
			place_result = x[1],
			subgroup = tier .. "-age-production-machine",
			stack_size = 10,
			ingredients = x[2],
		}
	end
end

--------------------------------------------------------------------------------
--- THE ELECTRIC RECIPES
--------------------------------------------------------------------------------

--- issue #499: the hunting, cobblestone and end stone recipes move from the Manual Mine to the Dig Site (#494: the Manual
--- Mine is a mining drill of the map veins now)
for name, r in pairs(data.raw.recipe) do
	if r.category == "manual-mine-recipes" and (name:match("^hunting%-") or name:match("^cobblestone%-manual%-mine")
		or name == "mining-end-stone") then
		r.category = "manual-digsite-recipes"
	end
end

--- issue #527: an old save's Manual Mine on such a recipe (or on the glowstone vein, which needs the Nether since #501)
--- would lose it silently: the engine drops a recipe of another category or surface on load, before any Lua migration.
--- migrations/2026-10-23-issue-527-moved-mine-recipes.json maps the recipe onto a placeholder `moved-<recipe>` of the
--- Manual Mine's category (hidden, never unlocked, the recipe's inputs, nothing out; no Dig Site of 0.5.5 ran these
--- recipes), and scripts/fork-ore-veins.lua clears it with a message, or gives the recipe back on its planet (mod data
--- fork-electric-mine: moved, placeholder -> { recipe, planet }).
FORK_ELECTRIC_MINE.moved = {}
function FORK_ELECTRIC_MINE.moved_placeholder(name, planet)
	local r = data.raw.recipe[name]
	local p = "moved-" .. name
	data:extend({ {
		type = "recipe", name = p, category = "manual-mine-recipes", enabled = false, hidden = true, energy_required = 1,
		icon = "__gregtorio-continued__/graphics/icons/manual-mine.png", icon_size = 64,
		localised_name = { "recipe-name.moved-mine-recipe" },
		ingredients = table.deepcopy(r.ingredients), results = {},
	} })
	FORK_ELECTRIC_MINE.moved[p] = { recipe = name, planet = planet }
	FORK_ELECTRIC_MINE_EXCLUDED[p] = "issue #527: the placeholder of an old save's moved Manual Mine recipe, no vein"
end
for _, n in pairs({ "hunting-blazes", "hunting-endermen", "hunting-zombies", "cobblestone-manual-mine",
	"cobblestone-manual-mine-with-wooden-pickaxe", "mining-end-stone" }) do
	FORK_ELECTRIC_MINE.moved_placeholder(n)
end
FORK_ELECTRIC_MINE.moved_placeholder("mining-glowstone-vein", "gt-nether")

--- every recipe of the Manual Mine (and the Dig Site, whose recipes are all ground work) gets a twin or a reason
local twins = {}
for name, r in pairs(data.raw.recipe) do
	if (r.category == "manual-mine-recipes" or r.category == "manual-digsite-recipes")
		and not FORK_ELECTRIC_MINE_EXCLUDED[name] then
		if not name:match("^mining%-") then
			error("163-fork-electric-mine: " .. name .. " has no twin name (mining-<vein>); add it to FORK_ELECTRIC_MINE_EXCLUDED")
		end
		twins[#twins + 1] = name
	end
end
table.sort(twins)
local twin_of = {}
for _, name in ipairs(twins) do
	local r = data.raw.recipe[name]
	local twin = name:gsub("^mining%-", "drilling-")
	create_recipe{
		name = twin,
		category = CATEGORY,
		energy_required = OP_TIME,
		subgroup = "subgroup-" .. CATEGORY,
		ingredients = { fluid(FLUID, FLUID_PER_OP), item(PIPE, PIPES_PER_VEIN) },   -- issues #341, #346: consumed; #393: one
		results = table.deepcopy(r.results),
		main_product = r.main_product or r.results[1].name,
	}
	FORK_ELECTRIC_MINE.twins[name] = twin
	twin_of[name] = twin
	--- issue #337: the miners' twin, with its mining pipe (consumed, issue #346; one per vein, issue #393)
	local results = table.deepcopy(r.results)
	local miner_twin = name:gsub("^mining%-", "miner-")
	create_recipe{
		name = miner_twin,
		category = MINER_CATEGORY,
		energy_required = MINER_TIME,
		subgroup = "subgroup-" .. MINER_CATEGORY,
		ingredients = { item(PIPE, PIPES_PER_VEIN) },
		results = results,
		main_product = r.main_product or r.results[1].name,
	}
	FORK_ELECTRIC_MINE.miner_twins[name] = miner_twin
end

--- the dimensions (DimNames) that are surfaces with map veins, their planet and the technology that reaches it; 165 makes
--- the planets and their veins (issue #501: the Nether; issue #502: the Twilight Forest; issue #503: The End)
FORK_ORE_VEINS = FORK_ORE_VEINS or {}
FORK_ORE_VEINS.planets = { OW = "nauvis", NETHER = "gt-nether", TWILIGHT_FOREST = "gt-twilight", THE_END = "gt-end" }
FORK_ORE_VEINS.techs = { NETHER = "reach-the-nether", TWILIGHT_FOREST = "reach-the-twilight-forest",
	THE_END = "reach-the-end" }
--- GT's veins the map leaves out (#494 decision 4: Thaumcraft's; 165 lists them in FORK_ORE_MIX_SKIPPED); their
--- ores do not count for the rule below (the amber vein stays a dimension mine's)
FORK_ORE_VEINS.dropped = { AquaIgnis = true, TerraAer = true, PerditioOrdo = true }

--- issue #499: a vein recipe whose every result is an ore of the map veins (prototypes/data/ore-mixes.lua; issue #501: of
--- every surface with map veins) is hidden with its twins: the mining drills mine those ores now. Issue #505 (V9) deleted
--- the ones of Nauvis, the Nether and the Twilight Forest (07, 09, 160); the rule still hides those of later dimensions
--- whose ores the map veins hold (Ross128b's carbon vein, the Everglades' GTPP0), which stay until their surfaces come; the
--- other veins stay the dimension mines' recipes.
do
	local overworld = {}
	for _, m in pairs(require("prototypes.data.ore-mixes").mixes) do
		for _, d in pairs(m.dimensions) do
			if FORK_ORE_VEINS.planets[d] and not FORK_ORE_VEINS.dropped[m.name] then
				for _, role in pairs({ "primary", "secondary", "between", "sporadic" }) do overworld["raw-" .. m[role]] = true end
			end
		end
	end
	FORK_ELECTRIC_MINE.hidden = {}
	for name, r in pairs(data.raw.recipe) do
		if r.category == "manual-mine-recipes" then
			local all = #r.results > 0
			for _, x in pairs(r.results) do if not overworld[x.name] then all = false end end
			if all then
				for _, n in pairs({ name, FORK_ELECTRIC_MINE.twins[name], FORK_ELECTRIC_MINE.miner_twins[name] }) do
					data.raw.recipe[n].hidden = true
					FORK_ELECTRIC_MINE.hidden[n] = true
				end
			end
		end
	end
end

--- issue #505: the deleted vein recipes of old saves (migrations/2026-10-22-issue-505-vein-recipes.json) become one
--- placeholder per planet and machine kind, `removed-vein-<planet>-<mine|miner|drill>` (hidden, never unlocked, nothing
--- out), so that scripts/fork-ore-veins.lua still sees which planet's vein a dimension mine ran: on that planet it
--- becomes its mining drill, elsewhere it loses the recipe (mod data fork-electric-mine: removed, placeholder -> planet).
--- They take the vein recipes' inputs, so that an old mine keeps them for its drill (the manual labor as fuel).
local REMOVED_INPUTS = { mine = { item("iron-pickaxe-usage", 1), item("manual-labor", 1) },
	miner = { item(PIPE, PIPES_PER_VEIN) }, drill = { fluid(FLUID, FLUID_PER_OP), item(PIPE, PIPES_PER_VEIN) } }
local REMOVED = {}
for _, planet in pairs({ "nauvis", "gt-nether", "gt-twilight" }) do
	for kind, cat in pairs({ mine = "manual-mine-recipes", miner = MINER_CATEGORY, drill = CATEGORY }) do
		local name = "removed-vein-" .. planet .. "-" .. kind
		data:extend({ {
			type = "recipe", name = name, category = cat, enabled = false, hidden = true, energy_required = 1,
			icon = "__gregtorio-continued__/graphics/icons/manual-mine.png", icon_size = 64,
			localised_name = { "recipe-name.removed-vein", { "space-location-name." .. planet } },
			ingredients = REMOVED_INPUTS[kind], results = {},
		} })
		REMOVED[name] = planet
		if kind == "mine" then
			FORK_ELECTRIC_MINE_EXCLUDED[name] = "issue #505: the placeholder of an old save's deleted vein recipes, no vein"
		end
	end
end

--- issue #342: a replaced mine keeps its vein (scripts/fork-electric-mine.lua). The mod data names, for every recipe of a
--- vein (the Manual Mine's, the Miners', the plants'), the vein (its Manual Mine recipe) and, per vein, its recipe of each
--- category; `machines` are the mines that keep their vein when one of them replaces another (issue #499: the dimension
--- mines).
do
	local veins, recipes, machines = {}, {}, { [DIMENSION["manual-mine"]] = true }
	for manual, drilling in pairs(FORK_ELECTRIC_MINE.twins) do
		local miner = FORK_ELECTRIC_MINE.miner_twins[manual]
		veins[manual], veins[drilling], veins[miner] = manual, manual, manual
		recipes[manual] = { ["manual-mine-recipes"] = manual, [CATEGORY] = drilling, [MINER_CATEGORY] = miner }
	end
	for _, p in ipairs(MINERS) do machines[DIMENSION[p[1] .. "-miner"]] = true end
	for _, p in ipairs(PLANTS) do machines[DIMENSION[p[1]]] = true end
	--- issue #500: dimension mine -> the mining drill that replaces it in an old save (scripts/fork-ore-veins.lua)
	local drills = {}
	for drill, dim in pairs(DIMENSION) do drills[dim] = drill end
	data:extend({ { type = "mod-data", name = "fork-electric-mine",
		data = { veins = veins, recipes = recipes, machines = machines, drills = drills, removed = REMOVED,
			moved = FORK_ELECTRIC_MINE.moved } } })
end

--------------------------------------------------------------------------------
--- TECHNOLOGIES
--------------------------------------------------------------------------------

--- the technology that unlocks a manual recipe now
local function tech_of(recipe)
	for tname, t in pairs(data.raw.technology) do
		for _, e in pairs(t.effects or {}) do
			if e.type == "unlock-recipe" and e.recipe == recipe then return tname end
		end
	end
end
--- the technologies after the Mk I's: their veins' twins come with them (each has the Mk I's technology in its
--- prerequisite closure, Reach the Moon through 142's FORK_UNLOCK_TREE)
local LATER = {
	["reach-the-moon"] = true, ["reach-mars"] = true, ["reach-the-asteroid-belt"] = true,
	["reach-the-jovian-moons"] = true, ["reach-venus"] = true, ["reach-ross128"] = true,
	["reach-ross128ba"] = true, ["reach-the-everglades"] = true,   -- issue #373
}
local early = {}
for _, name in ipairs(twins) do
	local t = tech_of(name)
	if t and LATER[t] then
		data.raw.recipe[twin_of[name]].enabled = false
		table.insert(data.raw.technology[t].effects, { type = "unlock-recipe", recipe = twin_of[name] })
	else
		early[#early + 1] = twin_of[name]
	end
end

--- the Mk I after the Mixer (its Drilling Fluid), the Drilling Rig (lubricant, vanadium steel gears), MV Machines and
--- the technologies of the veins of its tier that are not before it (the Nether, the Twilight Forest with NAND Chips,
--- the manganese vein), so that no vein is drilled before it is mined by hand
--- (issue #499: each technology unlocks the mining drill and its dimension mine)
F.tech{ name = P1, prerequisites = { "mv-machines", "oil-gathering", "mixer", "reach-the-nether", "nand-chips",
	"manganese-processing" }, packs = 3, count = 40, time = 30, recipes = F.join({ P1, DIMENSION[P1], FLUID }, early) }
--- (the Mk II's large blue steel gears come with HV Energy Hatches)
F.tech{ name = P2, prerequisites = { P1, "hv-machines", "hv-energy-hatches" }, packs = 4, count = 40, time = 30,
	recipes = { P2, DIMENSION[P2] } }
F.tech{ name = P3, prerequisites = { P2, "ev-machines" }, packs = 5, count = 30, time = 45, recipes = { P3, DIMENSION[P3] } }
F.tech{ name = P4, prerequisites = { P3, "iv-machines" }, packs = 6, count = 50, time = 60, recipes = { P4, DIMENSION[P4] } }

--- issue #337: the LV Miner after the Wiremill (its mining pipe) and the LV sensor (issue #443: the Circuit Assembler,
--- which 142 unlocks it with; before, the Military Science Pack technology); the MV Miner with its MV sensor (Advanced MV
--- Machines), the HV Miner with HV Machines
--- (issue #350: 20 units, the middle of the LV technologies' 15 to 40)
F.tech{ name = MINER_TECH, prerequisites = { "wiremill", "circuit-assembler" }, packs = 2, count = 20, time = 30,
	recipes = { MINER_TECH, DIMENSION[MINER_TECH], PIPE } }
for _, x in pairs({ { "advanced-mv-machines", "mv-miner" }, { "hv-machines", "hv-miner" } }) do
	fork_add_unlock(x[1], x[2])
	fork_add_unlock(x[1], DIMENSION[x[2]])
end

--- the miners' twins, called by 142 after it moved the unlocks of the veins: a vein whose technology is the LV Miner's
--- or one of its prerequisites comes with the LV Miner, a later one with its own technology
function FORK_ELECTRIC_MINE.unlock_miner_twins()
	local before = {}
	local function walk(t)
		if before[t] then return end
		before[t] = true
		for _, pre in pairs(data.raw.technology[t].prerequisites or {}) do walk(pre) end
	end
	walk(MINER_TECH)
	for manual, twin in pairs(FORK_ELECTRIC_MINE.miner_twins) do
		local t = tech_of(manual)
		fork_add_unlock(t and not before[t] and t or MINER_TECH, twin)
	end
end



--------------------------------------------------------------------------------
--- THE MINING DRILLS (issue #499, plan #494): the Manual Mine, the LV to HV Miner and the Ore Drilling Plants Mk I to IV
--- mine the map veins (prototypes/165-fork-ore-veins.lua, resource category gt-ore) on the old 5x5 footprint, fast replace
--- group and upgrade chain (Manual Mine -> LV -> MV -> HV Miner -> Mk I -> ... -> Mk IV). Their rate is today's: a vein
--- recipe gave 64 ores (the iron vein's; most give 64 to 80), so the Manual Mine 6.4 ores a second, the Miners 64 in 24,
--- 12, 6 s, the plants 64 in GT's base / 2^tier ticks; the energy is the machines' (the Manual Mine burns manual labor,
--- 1 MJ: 8 of it per 64 ores, the vein recipes' average). The mining areas:
---   * Manual Mine 7 x 7 (#494);
---   * Miners GT's radius per tier (MTEMiner.java RADIUS: 8, 16, 24 blocks);
---   * Ore Drilling Plants a whole vein and more (GT: 3, 4, 6, 9 chunks; a vein here is up to 80 tiles across): radius
---     40, 48, 64, 96; GT's fortune (mTier + 3, small ores only) as a slower drain of the tiles from the Mk III: 80 % and
---     60 % of the ore taken from a tile;
---   * the plants drink Drilling Fluid per ore mined, today's 200 per 64 ores (scripts/fork-ore-drills.lua: out of fluid
---     the plant stops, mod data fork-ore-drills).
--- The Manual Mine is built with the iron pickaxe (#494) and comes with it (Smelt Iron Ingots); the Miners' recipes take
--- their 9 mining pipes (GTNH pulls them back up: #346 and #393 reversed). The dimension mines keep the vein recipes of the
--- other dimensions (above).
--------------------------------------------------------------------------------

local ORE_MINING_TIME = 2   -- 165's gt-ore resources
local ORES_PER_OP = 64
local function speed(ores_per_second) return ores_per_second * ORE_MINING_TIME end

local function drill(name, icon, icon_size, health, energy_source, energy_usage, rate, radius, upgrade, graphics)
	return {
		type = "mining-drill", name = name, icon = icon, icon_size = icon_size,
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 0.5, result = name }, max_health = health,
		corpse = "big-remnants", dying_explosion = "medium-explosion",
		resistances = { { type = "fire", percent = 70 } },
		collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } }, selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		resource_categories = { "gt-ore" },
		mining_speed = speed(rate),
		resource_searching_radius = radius - 0.01,
		vector_to_place_result = { 0, -2.85 },
		energy_source = energy_source,
		energy_usage = energy_usage,
		fast_replaceable_group = "manual-mine",
		next_upgrade = upgrade,
		graphics_set = graphics,
		radius_visualisation_picture = { filename =
			"__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
			width = 10, height = 10 },
		module_slots = 0,
		allowed_effects = {},
		localised_description = { "entity-description." .. name },
	}
end
local function sprites(name)
	return {
		idle_animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-idle.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/fork/" .. name .. "-working.png",
			width = 160, height = 160, frame_count = 1, shift = { 0, 0 } } } },
	}
end
local function electric() return { type = "electric", usage_priority = "secondary-input",
	emissions_per_minute = { pollution = 1 }, drain = "0W" } end

data:extend({ drill("manual-mine", manual_mine.icon, 64, 200,
	{ type = "burner", fuel_categories = { "manual-labor" }, effectivity = 1, fuel_inventory_size = 1,
		emissions_per_minute = { pollution = 0 } },
	"800kW", ORES_PER_OP / 10, 3.5, "lv-miner",
	{ animation = { layers = { { filename = "__gregtorio-continued__/graphics/entity/manual-mine.png", width = 320,
		height = 320, frame_count = 1, shift = { 0, 0 }, scale = 0.5 } } } }) })
for i, p in ipairs(MINERS) do
	local name = p[1] .. "-miner"
	data:extend({ drill(name, "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png", 32, 300, electric(), p[3],
		ORES_PER_OP / MINER_TIME * p[2], ({ 8.5, 16.5, 24.5 })[i], p[4], sprites(name)) })
end
for i, p in ipairs(PLANTS) do
	local d = drill(p[1], "__gregtorio-continued__/graphics/icons/fork/" .. p[1] .. ".png", 32, 400, electric(), p[5],
		ORES_PER_OP / (p[2] / 2 ^ p[3] / 20), ({ 40.5, 48.5, 64.5, 96.5 })[i], p[6], sprites(p[1]))
	d.resource_drain_rate_percent = ({ 100, 100, 80, 60 })[i]
	data:extend({ d })
end
--- a mining drill's fluid box works only while its ore needs a fluid, which the map veins must not (the hand, the Manual
--- Mine and the Miners mine them too): the Drilling Fluid goes into a hidden tank on the plant's tiles, with a pipe
--- connection in the middle of each side, which scripts/fork-ore-drills.lua builds and removes with the plant
local TANK = "ore-drilling-plant-fluid-input"
do
	local empty = { filename = "__core__/graphics/empty.png", size = 1, frame_count = 1 }
	local box = fluid_input()[1]
	box.production_type, box.filter = nil, FLUID
	for _, c in pairs(box.pipe_connections) do c.flow_direction = "input-output" end
	data:extend({ {
		type = "storage-tank", name = TANK, icon = "__gregtorio-continued__/graphics/icons/fork/" .. P1 .. ".png",
		icon_size = 32, hidden = true, selectable_in_game = false, max_health = 1,
		flags = { "not-on-map", "not-blueprintable", "not-deconstructable", "not-flammable", "not-upgradable", "no-copy-paste",
			"hide-alt-info" },
		collision_box = { { -2.3, -2.3 }, { 2.3, 2.3 } }, collision_mask = { layers = {} },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		fluid_box = box, window_bounding_box = { { 0, 0 }, { 0, 0 } }, flow_length_in_ticks = 360,
		pictures = { picture = empty, fluid_background = empty, window_background = empty, flow_sprite = empty,
			gas_flow = empty },
	} })
end
data:extend({ { type = "mod-data", name = "fork-ore-drills", data = {
	plants = { [P1] = true, [P2] = true, [P3] = true, [P4] = true }, tank = TANK, fluid = FLUID,
	per_ore = FLUID_PER_OP / ORES_PER_OP, ore_time = ORE_MINING_TIME } } })

--- the Manual Mine with the iron pickaxe (one craft: 26 uses), with Smelt Iron Ingots instead of Craft Wooden Tools
data.raw.recipe["manual-mine"].ingredients = { item("iron-pickaxe-usage", 26), item("manual-labor", 10) }
for _, e in pairs(data.raw.technology["craft-wooden-tools"].effects) do
	if e.type == "unlock-recipe" and e.recipe == "manual-mine" then e.recipe = DIMENSION["manual-mine"] end
end
fork_add_unlock("smelt-iron-ingots", "manual-mine")
