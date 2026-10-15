--------------------------------------------------------------------------------
--- FORK SPACE ELEVATOR (issue #301, part 1 of the maintainer's decision on #292: the Space Elevator in GTNH's full
--- scope). gtnhintergalactic in GT5-Unofficial af993ca6a9:
---   * the parts (recipe/MachineRecipes.java): the controller (L69-88, a research assembly line recipe at UHV), the
---     nanotube spool (L90-102) and the cable (L104-111), the base casing, support and internal structure (L113-162),
---     the motors Mk-I to Mk-V (L164-262);
---   * the machine (tile/multi/elevator/TileEntitySpaceElevator.java, ElevatorUtil.java): a structure of 35 x 35 blocks
---     around the cable; the tier of its motors decides how many modules it carries (6, 12, 15, 18, 24) and which tier
---     they may be; with Mk-III motors and up an extended ring of internal structure and concrete. On its own it does
---     nothing: it hosts the modules (#302, #303) and hands them its energy.
--- Here the Space Elevator is one 11 x 11 entity per motor tier (`space-elevator-mk1` to `-mk5`, fast-replaceable,
--- each made from the one before and the motors of its tier), which the modules of #302 and #303 look for; the mod data
--- `fork-space-elevator` holds each tier's motor tier and module slots for them. Its item takes an eighth of GT's
--- structure (each casing recipe gives 8): 773 base casings (with the hatch and module bases) -> 97, 620 support
--- structures -> 78, 360 internal structures -> 45, 88 motors -> 11, 56 neutronium frames -> 7, 800 concrete -> 100,
--- the cable; the extension (204 internal structures, 452 concrete) comes with the Mk-III motors (26 and 57).
--- Differences from GT, the closest analogue where the mod lacks the part:
---   * UU matter (every assembly line recipe here) is left out, as #36 decided for every UU matter recipe;
---   * the assembly line recipes above ZPM run in the ZPM assembly line (127: there is no UV assembly line), like the
---     Void Miner III of 160; research (GT's research station) is the technology;
---   * the internal structure's High Power Casing (TecTech) -> the UV machine casing; its molten concrete -> 10 concrete;
---     the controller's heavy duty plate tier 7 (NewHorizonsCoreMod) -> dense neutronium plates, its PPIC chips -> PPIC
---     wafers (Gregtorio's chips); OpenBlocks' elevator (the research item and an ingredient) has no counterpart;
---   * the nanotube spool's 4 x 64 16x graphene wires -> 256 graphene wires (the mod has no 16x wire); its cleanroom is
---     not built;
---   * mutated living solder (motors Mk-III to Mk-V) -> molten indalloy 140, as everywhere in the mod; dimensionally
---     shifted superfluid -> super coolant; the Mk-IV motor's proto-halkonite plate -> osmiridium, the plate of the
---     other motors.
--- Loads after 160 (data.lua) and before 142, whose tree check sees the technologies.
--------------------------------------------------------------------------------

local F = FORK5B
local FORK_ICON = "__gregtorio-continued__/graphics/icons/fork/"
local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end
local AL = "zpm-assembly-line-recipes"
local INDALLOY = fluid("molten-indalloy-140", 5760)   -- GT: 40 ingots
local SUBGROUP = "subgroup-uhv-age-multiblocks"

local function part(name, category, seconds, ingredients, amount, subgroup)
	create_item{
		name = name,
		icon = FORK_ICON .. name .. ".png",
		category = category,
		energy_required = seconds,
		subgroup = subgroup,
		ingredients = ingredients,
		results = { item(name, amount or 1) },
	}
	return name
end

--------------------------------------------------------------------------------
--- PARTS
--------------------------------------------------------------------------------

local parts = {
	part("space-elevator-base-casing", AL, 60 * UV_SPEED, {
		item("neutronium-frame", 8), item("palladium-screw", 32), item("osmiridium-plate", 64), item("uhv-circuit", 4),
		item("uv-piston", 2), item("cosmic-neutronium-ring", 8), INDALLOY, fluid("molten-iridium", 1152),
	}, 8),
	part("space-elevator-support-structure", AL, 60 * UV_SPEED, {
		item("neutronium-frame", 8), item("naquadria-bolt", 16), item("long-neutronium-rod", 8),
		item("double-osmiridium-plate", 8), INDALLOY, fluid("molten-iridium", 1440),
	}, 8),
	part("space-elevator-internal-structure", AL, 60 * UV_SPEED, {
		item("uv-machine-casing", 8), item("palladium-bolt", 16), item("double-neutronium-plate", 8), item("concrete", 10),
		INDALLOY,
	}, 8),
	part("nanotube-spool", "zpm-assembling-machine-recipes", 60 * ZPM_SPEED, {
		item("graphene-wire", 256), fluid("advanced-glue", 720),
	}),
	part("space-elevator-cable", "uhv-assembling-machine-recipes", 120 * UHV_SPEED, {
		item("nanotube-spool", 64), item("uhv-circuit", 4), fluid("super-glue", 8000),
	}),
	part("space-elevator-controller", AL, 300 * UHV_SPEED, {
		item("neutronium-frame", 64), item("uv-field-generator", 16), item("uhv-circuit", 16),
		item("dense-neutronium-plate", 32), item("ppic-wafer", 64), item("cosmic-neutronium-screw", 64),
		item("uv-motor", 32), item("space-elevator-base-casing", 8), INDALLOY, fluid("lubricant", 32000),
		fluid("molten-neutronium", 1440),
	}),
}

--- the motors: tier, GT's motor, ring and rod metal, circuit, screw metal, the speed of GT's recipe tier
local MOTORS = {
	{ "uv-motor", "neutronium", "uv-circuit", "cosmic-neutronium", UV_SPEED },
	{ "uhv-motor", "cosmic-neutronium", "uhv-circuit", "infinity", UHV_SPEED },
	{ "uev-motor", "infinity", "uev-circuit", "transcendent-metal", UEV_SPEED },
	{ "uiv-motor", "transcendent-metal", "uiv-circuit", "spacetime", UIV_SPEED },
	{ "umv-motor", "spacetime", "umv-circuit", "universium", UIV_SPEED },
}
local motors = {}
for t, m in ipairs(MOTORS) do
	local fluids = t <= 2
		and { INDALLOY, fluid("molten-naquadria", 1440), fluid("lubricant", 16000) }
		or { fluid("molten-indalloy-140", 2880), fluid("molten-naquadria", 1440), fluid("super-coolant", 24000) }
	local ingredients = { item("space-elevator-base-casing", 1), item(m[1], 4), item(m[2] .. "-ring", 8),
		item(m[2] .. "-rod", 4), item(m[3], 1), item(m[4] .. "-screw", 16), item("osmiridium-plate", 16) }
	for _, f in pairs(fluids) do ingredients[#ingredients + 1] = f end
	motors[t] = part("space-elevator-motor-mk" .. t, AL, 60 * m[5], ingredients)
end

--------------------------------------------------------------------------------
--- THE SPACE ELEVATOR (one entity per motor tier)
--------------------------------------------------------------------------------

local SLOTS = { 6, 12, 15, 18, 24 }   -- ElevatorUtil.AVAILABLE_MODULE_SLOTS
local elevators = {}
local view = {}
for t = 1, 5 do
	local name = "space-elevator-mk" .. t
	local ingredients
	if t == 1 then
		ingredients = { item("space-elevator-controller", 1), item("space-elevator-base-casing", 97),
			item("space-elevator-support-structure", 78), item("space-elevator-internal-structure", 45),
			item("neutronium-frame", 7), item("concrete", 100), item("space-elevator-cable", 1), item(motors[1], 11) }
	else
		ingredients = { item(elevators[t - 1], 1), item(motors[t], 11) }
		if t == 3 then   -- the extension (STRUCTURE_PIECE_EXTENDED) comes with the Mk-III motors
			ingredients[#ingredients + 1] = item("space-elevator-internal-structure", 26)
			ingredients[#ingredients + 1] = item("concrete", 57)
		end
	end
	create_item{
		name = name,
		icon = FORK_ICON .. name .. ".png",
		category = "uhv-assembling-machine-recipes",
		energy_required = 300 * UHV_SPEED,
		subgroup = SUBGROUP,
		stack_size = 1,
		place_result = name,
		ingredients = ingredients,
	}
	local picture = { filename = SPRITE_PATH .. name .. "-idle.png", width = 352, height = 352, shift = { 0, 0 } }
	data:extend({ {
		type = "simple-entity-with-force",
		name = name,
		icon = FORK_ICON .. name .. ".png",
		icon_size = 32,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 5, result = name },
		max_health = 20000,
		collision_box = { { -5.3, -5.3 }, { 5.3, 5.3 } },
		selection_box = { { -5.5, -5.5 }, { 5.5, 5.5 } },
		fast_replaceable_group = "fr-space-elevator",
		picture = picture,
		render_layer = "object",
		localised_description = { "entity-description.space-elevator", tostring(t), tostring(SLOTS[t]) },
	} })
	view[name] = { motor = t, slots = SLOTS[t] }
	elevators[t] = name
end
local MODDATA = { elevators = view, modules = {} }   -- (the modules of the mining section below and of #303)
data:extend({ { type = "mod-data", name = "fork-space-elevator", data = MODDATA } })

--------------------------------------------------------------------------------
--- TECHNOLOGIES (GT researches the controller from OpenBlocks' elevator and each motor from the one before)
--------------------------------------------------------------------------------

--- GT's parts are a tier later here (cosmic neutronium comes with Quantium at UEV, infinity with the UEV materials,
--- transcendent metal UIV, spacetime UMV, universium UXV): each technology follows the materials it takes (#252's rule,
--- the consumer moves to its producer's technology when the producer's chain is late)
F.tech{ name = "space-elevator", prerequisites = { "uhv-components", "wetware-processor-mainframes", "uhv-machines",
	"quantium", "super-glue" }, packs = 10, count = 50, time = 60, recipes = F.join(parts, { motors[1], elevators[1] }) }
local PACKS = { 10, 10, 11, 12, 13 }
local AFTER = { nil, "uev-materials", "uiv-materials", "umv-materials", "uxv-materials" }
for t = 2, 5 do
	F.tech{ name = "space-elevator-motor-mk" .. t,
		prerequisites = { t == 2 and "space-elevator" or ("space-elevator-motor-mk" .. (t - 1)), AFTER[t] },
		packs = PACKS[t], count = 50, time = 60, recipes = { motors[t], elevators[t] } }
end



--------------------------------------------------------------------------------
--- MINING MODULES (issue #302, part 2 of #292's decision: the whole drone chain). gtnhintergalactic again:
---   * Space Elevator Mining Module Mk-I to Mk-III (recipe/MachineRecipes.java:417-466; UHV, UEV, UIV; Mk-I researched
---     from the Void Miner III): up to 2, 4 or 8 operations in parallel (TileEntityModuleMiner.java, 959-1035), each
---     module needs the elevator's motors of its own tier;
---   * the mining drones LV to UXV (MachineRecipes.java:468-713), kept in the module, never used up;
---   * an operation (TileEntityModuleMiner.java): one asteroid of recipe/SpaceMiningRecipes.java, chosen at random by
---     weight among those the drone tier, the module tier and voltage and the distance setting allow; it uses 4 drill
---     heads and 4 rods of the drone tier's material and a plasma; it makes minSize to maxSize picks (each one further
---     with the plasma's bonus chance), every pick a stack of 64 of one of the asteroid's ores by weight; a drone tier k
---     steps above the asteroid's lowest adds 2^k - 1 picks and divides the time by sqrt(k + 1), its power times it.
--- Here a recipe per asteroid and drone tier (the player picks the asteroid, as the Void Miners' dimensions): one
--- operation of one parallel, the drone as a catalyst (in and out), the drill heads, rods and plasma used up, the ores as
--- expected amounts (Factorio holds a result above the stack size in the output; the machine waits until it is taken).
--- The module's speed is its parallels; a recipe whose power is above the Mk-I's voltage (UHV) needs the Mk-II or Mk-III
--- (GT's voltage filter). The runtime (scripts/fork-space-elevator.lua) runs a module only next to a Space Elevator whose
--- motors are of its tier or higher, as many modules as the elevator has slots.
--- Differences from GT, the closest analogue where the mod lacks the thing:
---   * plasma: helium only (GT's bismuth, radon, technetium and plutonium-241 plasmas are not in the mod): 825 L, bonus
---     chance 0.46 % (TileEntityModuleMiner: (tier / 6)^3), time x 1;
---   * ores the mod lacks are left out, not replaced (the Void Miners' rule): 28 of GT's 43 asteroids keep at least one;
---     the expected amounts are GT's (64 x picks x weight / total weight), so a missing ore lowers the yield;
---   * the distance setting, computation and the Asteroid Outpost space project are left out (the player chooses);
---   * drill heads: GT's crafting recipe (ProcessingToolHead.java:503-506: 4 plates of the material, 4 steel plates);
---   * the drones' Galacticraft and NewHorizonsCoreMod parts: heavy plating tier 1 to 9 -> dense plates of steel,
---     titanium, tungstensteel, iridium, osmiridium, naquadah alloy, neutronium (as the controller of #301), cosmic
---     neutronium, infinity; rocket engines -> motors of the drone's tier; drilling fluid -> lubricant; mutated living
---     solder -> indalloy 140; hypogen and celestial tungsten -> spacetime and infinity; the Mk-III's UU matter left out;
---     a 4x superconductor wire -> 4 wires; GT's Ore Drilling Plant IV -> the IV drilling rig (as the Void Miner I).
--------------------------------------------------------------------------------

local TIERS = { "LV", "MV", "HV", "EV", "IV", "LuV", "ZPM", "UV", "UHV", "UEV", "UIV", "UMV", "UXV" }
local TIER_OF = {}
for i, t in ipairs(TIERS) do TIER_OF[t] = i end
local function lower(t) return t:lower() end

--- the drill heads (the consumables' and the drones' materials)
local DRILL_METALS = { "steel", "titanium", "tungstensteel", "iridium", "trinium", "naquadah", "naquadah-alloy",
	"naquadria", "neutronium", "cosmic-neutronium", "infinity", "transcendent-metal", "spacetime", "eternity" }
for _, m in ipairs(DRILL_METALS) do
	create_item{   -- (icon from tools/gen_gt_icons.py, GT's toolHeadDrill of the material)
		name = m .. "-drill-head",
		category = "crafting-or-assembling-recipes",
		energy_required = 5,
		ingredients = m == "steel" and { item("steel-plate", 8) } or { item(m .. "-plate", 4), item("steel-plate", 4) },
	}
end
--- drone tier -> the material of the drill heads and rods an operation uses (TileEntityModuleMiner's DroneMaterial)
local CONSUMABLE = { "steel", "steel", "titanium", "titanium", "tungstensteel", "tungstensteel", "naquadah", "naquadah",
	"naquadah-alloy", "neutronium", "cosmic-neutronium", "infinity", "transcendent-metal" }

--- the drones: drill head metal, plating (count), rocket engines (here motors), circuit, fluids
local PLATING = { "steel", "steel", "titanium", "tungstensteel", "iridium", "osmiridium", "naquadah-alloy", "neutronium",
	"cosmic-neutronium", "infinity", "infinity", "infinity", "infinity" }
local DRONES = {
	{ "titanium", 16, 2, "processing-unit", { fluid("soldering-alloy", 720) } },   -- (Gregtorio's HV circuit)
	{ "tungstensteel", 32, 4, "ev-circuit", { fluid("soldering-alloy", 1440) } },
	{ "iridium", 32, 4, "iv-circuit", { fluid("soldering-alloy", 1440) } },
	{ "trinium", 32, 4, "luv-circuit",
		{ fluid("molten-indalloy-140", 720), fluid("molten-iridium", 720), fluid("lubricant", 16000) } },
	{ "naquadah-alloy", 32, 4, "zpm-circuit",
		{ fluid("molten-indalloy-140", 1440), fluid("molten-iridium", 1440), fluid("lubricant", 32000) } },
	{ "naquadria", 32, 4, "zpm-circuit",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-osmiridium", 1440), fluid("lubricant", 64000) } },
	{ "neutronium", 32, 4, "uv-circuit",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-osmiridium", 1440), fluid("lubricant", 128000) } },
	{ "cosmic-neutronium", 32, 4, "uhv-circuit",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-naquadria", 1440), fluid("lubricant", 256000) } },
	{ "infinity", 32, 4, "uev-circuit",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-neutronium", 1440), fluid("lubricant", 512000) } },
	{ "cosmic-neutronium", 32, 8, "uiv-circuit",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-quantium", 1440), fluid("lubricant", 512000) } },
	{ "cosmic-neutronium", 64, 16, "umv-circuit",
		{ fluid("molten-indalloy-140", 5760), fluid("molten-quantium", 2880), fluid("lubricant", 512000) } },
	{ "spacetime", 128, 32, "uxv-circuit",
		{ fluid("molten-spacetime", 576), fluid("molten-infinity", 576), fluid("lubricant", 512000) } },
	{ "eternity", 256, 64, "max-circuit",
		{ fluid("molten-spacetime", 576), fluid("molten-universium", 576), fluid("lubricant", 512000) } },
}
local SPEED = { LV_SPEED, MV_SPEED, HV_SPEED, EV_SPEED, IV_SPEED, LUV_SPEED, ZPM_SPEED, UV_SPEED, UHV_SPEED, UEV_SPEED,
	UIV_SPEED, UIV_SPEED, UIV_SPEED }
local drones = {}
for i, d in ipairs(DRONES) do
	local t = lower(TIERS[i])
	local category = i <= 3 and (t .. "-assembling-machine-recipes")
		or (i <= 5 and "iv-assembly-line-recipes" or (i == 6 and "luv-assembly-line-recipes" or AL))
	local ingredients = { item(d[1] .. "-drill-head", 8), item(t .. "-robot-arm", 8), item(t .. "-field-generator", 2),
		item(d[4], 4), item("dense-" .. PLATING[i] .. "-plate", d[2]), item(t .. "-motor", d[3]), item(t .. "-sensor", 8) }
	for _, f in pairs(d[5]) do ingredients[#ingredients + 1] = f end
	drones[i] = part("mining-drone-" .. t, category, 60 * SPEED[i], ingredients)
end

--- the modules: speed = parallels, energy at the module's voltage, its recipe (the module before it or the drilling rig)
local MODULES = {
	{ "space-elevator-mining-module-mk1", 2, EU16_UHV, "iv-drilling-rig", "uv", "naquamiridium", "neutronium",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-naquadria", 1440), fluid("lubricant", 8000) }, UHV_SPEED },
	{ "space-elevator-mining-module-mk2", 4, EU16_UEV, "space-elevator-mining-module-mk1", "uhv", "triamerotronium",
		"cosmic-neutronium",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-naquadria", 2880), fluid("lubricant", 16000) }, UEV_SPEED },
	{ "space-elevator-mining-module-mk3", 8, EU16_UIV, "space-elevator-mining-module-mk2", "uev", "dracofinium", "infinity",
		{ fluid("molten-indalloy-140", 2880), fluid("molten-transcendent-metal", 1440) }, UIV_SPEED },
}
local modules = {}
for k, m in ipairs(MODULES) do
	F.category("space-mining-" .. k .. "-recipes")
	local name = m[1]
	local e = table.deepcopy(data.raw["assembling-machine"]["hv-chemical-reactor"])
	e.name = name
	e.icons = nil
	e.icon = FORK_ICON .. name .. ".png"
	e.icon_size = 32
	e.minable = { mining_time = 1, result = name }
	local cats = {}
	for c = 1, k do cats[#cats + 1] = "space-mining-" .. c .. "-recipes" end
	e.crafting_categories = cats
	e.crafting_speed = m[2]
	e.energy_usage = m[3]
	e.fast_replaceable_group = "fr-space-elevator-mining-module"
	e.next_upgrade = nil
	e.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	e.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	e.fluid_boxes = { {
		production_type = "input", volume = 1000, pipe_covers = pipecoverspictures(), pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = "input", direction = defines.direction.north, position = { 0, -1 } } },
	} }
	e.fluid_boxes_off_when_no_fluid_recipe = true
	e.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. name .. "-idle.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. name .. "-working.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
	}
	e.localised_description = { "entity-description.space-elevator-mining-module", tostring(m[2]), tostring(k) }
	data:extend({ e })
	local t = m[5]
	local ingredients = { item(m[4], 1), item(t .. "-robot-arm", 8), item(t .. "-field-generator", 4),
		item(t .. "-circuit", 16), item(t .. "-sensor", 16), item(m[6] .. "-superconductive-wire", 128),
		item(m[7] .. "-frame", 16) }
	for _, f in pairs(m[8]) do ingredients[#ingredients + 1] = f end
	create_item{
		name = name, icon = e.icon, place_result = name, subgroup = SUBGROUP, stack_size = 10,
		category = AL, energy_required = 120 * m[9], ingredients = ingredients,
	}
	data.raw["mod-data"]["fork-space-elevator"].data.modules[name] = { motor = k }
	modules[k] = name
end

--- the asteroids (SpaceMiningRecipes.java, its material asteroids; the GT line): name, display name, module tier, lowest and
--- highest drone tier, min and max picks, ticks, EU/t, total weight, { ore, weight } of the ores the mod has
local ASTEROIDS = {
	{ "coalAsteroid", "Coal Asteroid", 1, "LV", "ZPM", 30, 120, 200, 1920, 10000, -- L76
		{ { "raw-coal", 7000 }, { "raw-graphite", 2000 } } },
	{ "saltAsteroid", "Salt Asteroid", 1, "LV", "IV", 30, 120, 200, 1920, 10000, -- L95
		{ { "raw-salt", 4000 }, { "raw-rock-salt", 2000 } } },
	{ "ironAsteroid", "Iron Asteroid", 1, "LV", "ZPM", 30, 150, 200, 1920, 9000, -- L114
		{ { "raw-iron", 4000 }, { "raw-gold", 2000 } } },
	{ "copperAsteroid", "Copper Asteroid", 1, "LV", "LuV", 30, 150, 200, 1920, 10000, -- L135
		{ { "raw-copper", 5000 } } },
	{ "tinAsteroid", "Tin Asteroid", 1, "LV", "IV", 50, 200, 50, 7680, 10000, -- L155
		{ { "raw-cassiterite", 2000 }, { "raw-tin", 6000 } } },
	{ "aluminiumAsteroid", "Aluminium Asteroid", 1, "MV", "EV", 10, 20, 50, 7680, 10000, -- L175
		{ { "raw-aluminium", 5000 }, { "raw-bauxite", 3500 } } },
	{ "nickelAsteroid", "Nickel Asteroid", 1, "LV", "IV", 20, 40, 50, 7680, 10000, -- L195
		{ { "raw-nickel", 4000 }, { "raw-pentlandite", 3000 } } },
	{ "chromeAsteroid", "Chrome Asteroid", 1, "MV", "LuV", 16, 32, 50, 30720, 10000, -- L215
		{ { "raw-ruby", 3000 }, { "raw-chromite", 2000 } } },
	{ "platlineOreAsteroid", "Platinum Line Ore Asteroid", 1, "HV", "ZPM", 20, 40, 50, 30720, 10000, -- L235
		{ { "raw-platinum", 6000 }, { "raw-palladium", 2000 } } },
	{ "gemAsteroid", "Gem Asteroid", 1, "LV", "LuV", 30, 160, 100, 30720, 10750, -- L255
		{ { "raw-ruby", 1500 }, { "raw-emerald", 1500 }, { "raw-diamond", 750 }, { "raw-bauxite", 500 } } },
	{ "indiumAsteroid", "Indium Asteroid", 2, "IV", "UEV", 30, 120, 500, 30720, 10000, -- L277
		{ { "raw-sphalerite", 2000 } } },
	{ "niobiumAsteroid", "Niobium Asteroid", 1, "IV", "UHV", 30, 120, 500, 30720, 10000, -- L338
		{ { "quantium-dust", 2000 } } },
	{ "quartzAsteroid", "Quartz Asteroid", 1, "MV", "ZPM", 20, 80, 500, 7680, 10000, -- L358
		{ { "raw-certus-quartz", 2250 }, { "raw-nether-quartz", 2250 } } },
	{ "lutetiumAsteroid", "Lutetium Asteroid", 1, "IV", "UHV", 20, 80, 500, 30720, 10000, -- L378
		{ { "raw-redstone", 5500 } } },
	{ "siliconAsteroid", "Silicon Asteroid", 2, "HV", "LuV", 20, 80, 500, 30720, 9000, -- L399
		{ { "raw-silicon", 4500 } } },
	{ "phosphateAsteroid", "Phosphate Asteroid", 1, "IV", "UIV", 20, 150, 500, 30720, 13000, -- L419
		{ { "raw-tricalcium-phosphate", 2500 }, { "raw-sulfur", 3000 }, { "raw-apatite", 3000 } } },
	{ "spaceOreAsteroid", "Space Ore Asteroid", 1, "LuV", "UV", 20, 50, 500, 30720, 29000, -- L439
		{ { "raw-black-plutonium", 1000 }, { "callisto-ice-dust", 2000 }, { "raw-ledox", 2000 } } },
	{ "leadAsteroid", "Lead Asteroid", 1, "LV", "UV", 30, 100, 500, 1920, 10000, -- L461
		{ { "raw-lead", 3000 }, { "raw-lepidolite", 2000 } } },
	{ "adamantiumAsteroid", "Adamantium Asteroid", 1, "EV", "ZPM", 30, 120, 500, 1920, 10000, -- L481
		{ { "raw-adamantium", 2500 } } },
	{ "tungstenTitaniumAsteroid", "Tungsten Titanium Asteroid", 1, "LV", "LuV", 30, 70, 500, 30720, 10000, -- L502
		{ { "raw-neodymium", 2000 }, { "raw-tungstate", 500 } } },
	{ "blueAsteroid", "Blue Asteroid", 1, "HV", "UV", 10, 50, 500, 7680, 10000, -- L523
		{ { "raw-lapis", 6000 }, { "raw-calcite", 2000 }, { "raw-lazurite", 1000 }, { "raw-sodalite", 1000 } } },
	{ "aluminiumLanthlineAsteroid", "Aluminium Lanthanide Asteroid", 1, "MV", "ZPM", 10, 80, 500, 7680, 10000, -- L543
		{ { "raw-aluminium", 3500 }, { "raw-bauxite", 1500 }, { "raw-monazite", 2500 }, { "raw-bastnasite", 2500 } } },
	{ "NetherOreAsteroid", "Nether Ore Asteroid", 1, "EV", "ZPM", 30, 110, 1000, 7680, 10000, -- L646
		{ { "raw-nether-quartz", 3000 }, { "raw-sulfur", 3000 }, { "raw-certus-quartz", 2000 }, { "raw-firestone", 500 } } },
	{ "europiumAsteroid", "Europium Asteroid", 2, "ZPM", "UXV", 40, 120, 1000, 122880, 10000, -- L667
		{ { "raw-ledox", 4000 }, { "callisto-ice-dust", 4000 }, { "raw-borax", 1500 } } },
	{ "cosmicAsteroid", "Cosmic Asteroid", 2, "ZPM", "UXV", 10, 70, 500, 491520, 10000, -- L687
		{ { "raw-cosmic-neutronium", 2500 }, { "raw-neutronium", 2500 }, { "raw-black-plutonium", 2500 }, { "raw-bedrockium", 2500 } } },
	{ "infinityCatalystAsteroid", "Infinity Catalyst Asteroid", 2, "UV", "UXV", 30, 120, 1000, 491520, 10000, -- L708
		{ { "raw-infinity-catalyst", 5000 }, { "raw-cosmic-neutronium", 3000 }, { "raw-neutronium", 2000 } } },
	{ "platlinePureAsteroid", "Platinum Line Pure Asteroid", 2, "ZPM", "UEV", 10, 30, 500, 122880, 10000, -- L835
		{ { "raw-platinum", 3800 }, { "raw-palladium", 2000 } } },
	{ "lanthanumAsteroid", "Lanthanum Asteroid", 2, "IV", "UIV", 30, 120, 500, 30720, 10000, -- L876
		{ { "raw-silver", 3500 } } },
}
local VOLTAGE = { 524288, 2097152, 8388608 }   -- GTValues.V[8..10] of the modules
local BONUS = 0.0046                            -- helium plasma (tier 1): (1 / 6)^3
local by_module = { {}, {}, {} }
for _, a in ipairs(ASTEROIDS) do
	local lo, hi = TIER_OF[a[4]], TIER_OF[a[5]]
	for tier = lo, hi do
		local k = tier - lo
		local smin, smax = a[6] + 2 ^ k - 1, a[7] + 2 ^ k - 1
		local ticks = math.ceil(a[8] / math.sqrt(k + 1))
		local eu = math.ceil(a[9] * math.sqrt(k + 1))
		local mod = a[3]
		while mod <= 3 and eu > VOLTAGE[mod] do mod = mod + 1 end
		if mod <= 3 then
			local picks = smin + (smax - smin) * BONUS
			local t = lower(TIERS[tier])
			local results = { item(drones[tier], 1) }
			for _, o in ipairs(a[11]) do
				local e = 64 * picks * o[2] / a[10]
				local n = math.floor(e)
				local r = { type = "item", name = o[1], amount = n }
				if e - n > 0.001 then r.extra_count_fraction = e - n end
				results[#results + 1] = r
			end
			local name = "space-mining-" .. a[1]:gsub("(%u)", function(c) return "-" .. c:lower() end):gsub("^%-", "") .. "-" .. t
			create_recipe{
				name = name,
				category = "space-mining-" .. mod .. "-recipes",
				energy_required = ticks / 20,
				subgroup = "subgroup-space-mining-" .. mod .. "-recipes",
				ingredients = { item(drones[tier], 1), item(CONSUMABLE[tier] .. "-drill-head", 4),
					item(CONSUMABLE[tier] .. "-rod", 4), fluid("helium-plasma", 825) },
				results = results,
				icon = FORK_ICON .. drones[tier] .. ".png",
			}
			local r = data.raw.recipe[name]
			r.main_product = nil
			r.allow_productivity = false
			r.localised_name = { "recipe-name.fork-space-mining", a[2], TIERS[tier] }
			by_module[mod][#by_module[mod] + 1] = { name, tier }
		end
	end
end

--- Technologies: a chain by GT's tiers (module Mk-I UHV, Mk-II UEV, Mk-III UIV with the UIV drone, then the UMV and UXV
--- drones); a mining recipe comes with the later of its module's and its drone's technology
local MTECH = { "space-elevator-mining-module-mk1", "space-elevator-mining-module-mk2", "space-elevator-mining-module-mk3",
	"space-elevator-mining-drones-umv", "space-elevator-mining-drones-uxv" }
local DRONE_TECH = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 4, 5 }   -- drone tier -> index in MTECH
local unlocks = { {}, {}, {}, {}, {} }
for _, m in ipairs(DRILL_METALS) do
	local first = 5
	for tier, c in ipairs(CONSUMABLE) do if c == m then first = math.min(first, DRONE_TECH[tier]) end end
	for tier, d in ipairs(DRONES) do if d[1] == m then first = math.min(first, DRONE_TECH[tier]) end end
	table.insert(unlocks[first], m .. "-drill-head")
end
for tier, name in ipairs(drones) do table.insert(unlocks[DRONE_TECH[tier]], name) end
for k = 1, 3 do table.insert(unlocks[k], modules[k]) end
for mod = 1, 3 do
	for _, r in ipairs(by_module[mod]) do table.insert(unlocks[math.max(mod, DRONE_TECH[r[2]])], r[1]) end
end
--- (GT's drones take the circuit of the next tier, and Gregtorio's materials come a tier later: the processor mainframes,
--- the UEV materials and the UXV energy hatches' eternity, #252's rule)
local MPRE = { { "space-elevator", "void-miner-iii", "uev-materials", "optical-processor-mainframes" }, { "uev-components" },
	{ "uiv-components", "exotic-processor-mainframes" }, { "umv-components", "temporal-processor-mainframes" },
	{ "uxv-components", "planck-processor-mainframes", "uxv-energy-hatches" } }
local MPACKS = { 10, 10, 11, 12, 13 }
for i, name in ipairs(MTECH) do
	local pre = {}
	if i > 1 then pre[1] = MTECH[i - 1] end
	for _, p in ipairs(MPRE[i]) do pre[#pre + 1] = p end
	F.tech{ name = name, prerequisites = pre, packs = MPACKS[i], count = 50, time = 60, recipes = unlocks[i] }
end


--------------------------------------------------------------------------------
--- PUMP MODULES AND THE PLANETARY GAS SIPHON (issue #303, part 3 of #292's decision). gtnhintergalactic again:
---   * the Planetary Gas Siphon (tile/multi/MTEPlanetaryGasSiphon.java, recipe/GasSiphonRecipes.java:119-144; controller
---     recipe recipe/MachineRecipes.java:61-67): on a space station around Jupiter, Saturn, Uranus or Neptune, the depth (1
---     to 4) picks the gas; an operation takes 20 ticks (less with better coils) and gives the table's amount;
---   * the Pump Modules Mk-I to Mk-III (MachineRecipes.java:264-352, tile/multi/elevatormodules/TileEntityModulePump.java,
---     recipe/SpacePumpingRecipes.java:28-86): no inputs; per recipe slot a planet type and gas type give a fluid, each
---     parallel the table's amount every 20 ticks at UHV's power; Mk-I 4 parallels in 1 slot (motors Mk-II), Mk-II 4 in 4
---     slots (motors Mk-III), Mk-III 64 in 4 slots (motors Mk-IV); module voltage UHV, UEV, UXV.
---   * left out: the Assembler and Research Modules (their recipe maps are empty in GTNH: no recipe adds to them) and the
---     Space Project Manager (the space projects are left out, as in #302).
--- The maintainer's decision on #303: GTNH's amounts scaled down by a fixed factor, so one module matches a reasonable
--- number of pipes. Here each machine's largest regular result becomes about 1 800 L/s: the pump modules' amounts / 1000
--- (lava 1 800 000 -> 1 800 per parallel; distilled water, GTNH's outlier, 17 920), the siphon's / 10 (hydrogen 18 000 ->
--- 1 800). A recipe per fluid (the player picks it, as the Void Miners' dimensions and the mining modules' asteroids); the
--- module's speed is its parallels times its slots (4, 16, 256: GT's slots on one fluid), its power its voltage. The siphon
--- stands for the orbit (Gregtorio has no space stations): a recipe per planet and depth, one operation a second (GT's base
--- time, without the coil bonus), at the IV power of its controller.
--- Fluids the mod lacks are left out, not replaced: GT's ender goo, extra heavy oil, natural gas, medium oil, liquid oxygen
--- and Galacticraft's unknown water. The closest analogue where the mod lacks a part: the Infinite Fluid Drilling Rig ->
--- the IV drilling rig (the mod's fluid drilling rigs); the Ender Fluid Link Cover -> an eye of ender; the medium tungstensteel pipe -> 3 tungstensteel
--- plates (GT's pipe recipe); mutated living solder -> molten indalloy 140; metastable oganesson screws -> spacetime screws,
--- proto-halkonite -> osmiridium (as the motors of #301), black and white dwarf matter -> universium (the materials come a
--- tier later here).
--------------------------------------------------------------------------------

local PUMP_SCALE, SIPHON_SCALE = 1000, 10

F.category("planetary-gas-siphon-recipes")
F.category("space-pump-recipes")
--- a 3 x 3 machine with one fluid output on its south side
local function fluid_machine(name, base, categories, speed, energy, volume)
	local e = table.deepcopy(data.raw["assembling-machine"][base])
	e.name = name
	e.icons = nil
	e.icon = FORK_ICON .. name .. ".png"
	e.icon_size = 32
	e.minable = { mining_time = 1, result = name }
	e.crafting_categories = categories
	e.crafting_speed = speed
	e.energy_usage = energy
	e.next_upgrade = nil
	e.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	e.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	e.fluid_boxes = { {
		production_type = "output", volume = volume, pipe_covers = pipecoverspictures(), pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = "output", direction = defines.direction.south, position = { 0, 1 } } },
	} }
	e.fluid_boxes_off_when_no_fluid_recipe = false
	e.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. name .. "-idle.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. name .. "-working.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ e })
	return e
end

--- the siphon
local siphon = fluid_machine("planetary-gas-siphon", "hv-chemical-reactor", { "planetary-gas-siphon-recipes" }, 1, EU16_IV,
	2000)
siphon.fast_replaceable_group = nil
siphon.localised_description = { "entity-description.planetary-gas-siphon", tostring(SIPHON_SCALE) }
create_item{
	name = "planetary-gas-siphon", icon = siphon.icon, place_result = "planetary-gas-siphon", subgroup = SUBGROUP,
	stack_size = 10, category = "crafting-or-assembling-recipes", energy_required = 10,
	ingredients = { item("iv-motor", 2), item("iv-pump", 1), item("iv-circuit", 2), item("tungstensteel-plate", 6),
		item("iv-machine-hull", 2) },
}
--- planet, display name, { depth -> fluid, amount } (GasSiphonRecipes.java; Saturn's liquid oxygen, which the mod lacks, left out)
local PLANETS = {
	{ "jupiter", "Jupiter", { { "hydrogen", 15000 }, { "helium", 500 }, { "nitrogen", 300 }, { "oxygen", 200 } } },
	{ "saturn", "Saturn", { { "hydrogen", 18000 }, { "helium", 800 }, { "oxygen", 500 }, { "liquid-oxygen", 150 } } },
	{ "uranus", "Uranus", { { "deuterium", 5000 }, { "neon", 450 }, { "argon", 250 }, { "krypton", 100 } } },
	{ "neptune", "Neptune", { { "tritium", 3000 }, { "helium-3", 500 }, { "ammonia", 400 }, { "xenon", 350 } } },
}
local siphon_recipes = { "planetary-gas-siphon" }
for _, pl in ipairs(PLANETS) do
	for depth, f in ipairs(pl[3]) do
		if data.raw.fluid[f[1]] then
			local name = "gas-siphon-" .. pl[1] .. "-" .. depth
			create_recipe{
				name = name,
				category = "planetary-gas-siphon-recipes",
				energy_required = 1,
				subgroup = "subgroup-planetary-gas-siphon-recipes",
				ingredients = {},
				results = { fluid(f[1], f[2] / SIPHON_SCALE) },
				icon = FORK_ICON .. "planetary-gas-siphon.png",
			}
			local r = data.raw.recipe[name]
			r.main_product = nil
			r.allow_productivity = false
			r.localised_name = { "recipe-name.fork-gas-siphon", pl[2], tostring(depth),
				data.raw.fluid[f[1]].localised_name or { "fluid-name." .. f[1] } }
			siphon_recipes[#siphon_recipes + 1] = name
		end
	end
end

--- the pump modules: name, speed (parallels x slots), power, motor tier, recipe speed, ingredients
local PUMPS = {
	{ "space-elevator-pump-module-mk1", 4, EU16_UHV, 2, UEV_SPEED, {
		item("iv-drilling-rig", 1), item("planetary-gas-siphon", 1), item("eye-of-ender", 2),
		item("infinity-frame", 4), item("uev-circuit", 4), item("uev-pump", 2), item("infinity-gear", 4),
		item("cosmic-neutronium-screw", 32), fluid("molten-indalloy-140", 1296), fluid("molten-infinity", 576) } },
	{ "space-elevator-pump-module-mk2", 16, EU16_UEV, 3, UIV_SPEED, {
		item("iv-drilling-rig", 4), item("planetary-gas-siphon", 4), item("eye-of-ender", 8),
		item("spacetime-frame", 4), item("uiv-circuit", 16), item("uiv-pump", 8), item("spacetime-gear", 4),
		item("spacetime-screw", 64), fluid("molten-indalloy-140", 4608), fluid("molten-osmiridium", 2304) } },
	{ "space-elevator-pump-module-mk3", 256, EU16_UXV, 4, UMV_SPEED, {
		item("iv-drilling-rig", 16), item("planetary-gas-siphon", 16), item("eye-of-ender", 32),
		item("universium-frame", 4), item("umv-circuit", 16), item("umv-pump", 8), item("universium-gear", 4),
		item("universium-screw", 64), fluid("molten-indalloy-140", 9216), fluid("molten-eternity", 2304) } },
}
local pumps = {}
for k, m in ipairs(PUMPS) do
	local name = m[1]
	local e = fluid_machine(name, "hv-chemical-reactor", { "space-pump-recipes" }, m[2], m[3], 20000)
	e.fast_replaceable_group = "fr-space-elevator-pump-module"
	e.localised_description = { "entity-description.space-elevator-pump-module", tostring(m[2]), tostring(m[4]),
		tostring(PUMP_SCALE) }
	create_item{
		name = name, icon = e.icon, place_result = name, subgroup = SUBGROUP, stack_size = 10,
		category = AL, energy_required = 120 * m[5], ingredients = m[6],
	}
	MODDATA.modules[name] = { motor = m[4] }
	pumps[k] = name
end

--- the pumping recipes (SpacePumpingRecipes.java): planet type, gas type, fluid, GT's amount (fluids the mod lacks left out)
local PUMPED = {
	{ 2, 1, "chlorobenzene", 896000 }, { 3, 3, "lava", 1800000 }, { 4, 1, "sulfuric-acid", 784000 },
	{ 4, 2, "molten-iron", 896000 }, { 4, 3, "crude-oil", 1400000 }, { 4, 4, "heavy-oil", 1792000 },
	{ 4, 5, "molten-lead", 896000 }, { 4, 7, "light-oil", 780000 }, { 4, 8, "carbon-dioxide", 1680000 },
	{ 5, 1, "carbon-monoxide", 4480000 }, { 5, 2, "helium-3", 2800000 }, { 5, 3, "salt-water", 2800000 },
	{ 5, 4, "helium", 1400000 }, { 5, 6, "neon", 32000 }, { 5, 7, "argon", 32000 }, { 5, 8, "krypton", 8000 },
	{ 5, 9, "methane", 1792000 }, { 5, 10, "hydrogen-sulfide", 392000 }, { 5, 11, "ethane", 1194000 },
	{ 6, 1, "deuterium", 1568000 }, { 6, 2, "tritium", 240000 }, { 6, 3, "ammonia", 240000 }, { 6, 4, "xenon", 16000 },
	{ 6, 5, "ethylene", 1792000 }, { 7, 1, "hydrofluoric-acid", 672000 }, { 7, 2, "fluorine", 1792000 },
	{ 7, 3, "nitrogen", 1792000 }, { 7, 4, "oxygen", 1792000 }, { 8, 1, "hydrogen", 1568000 }, { 8, 2, "liquid-air", 875000 },
	{ 8, 3, "molten-copper", 672000 }, { 8, 5, "distilled-water", 17920000 }, { 8, 6, "radon", 64000 },
	{ 8, 7, "molten-tin", 672000 },
}
local pump_recipes = {}
for _, pr in ipairs(PUMPED) do
	if data.raw.fluid[pr[3]] then
		local name = "space-pump-" .. pr[3]
		create_recipe{
			name = name,
			category = "space-pump-recipes",
			energy_required = 1,
			subgroup = "subgroup-space-pump-recipes",
			ingredients = {},
			results = { fluid(pr[3], pr[4] / PUMP_SCALE) },
			icon = FORK_ICON .. pumps[1] .. ".png",
		}
		local r = data.raw.recipe[name]
		r.main_product = nil
		r.allow_productivity = false
		r.localised_name = { "recipe-name.fork-space-pump", data.raw.fluid[pr[3]].localised_name or { "fluid-name." .. pr[3] },
			tostring(pr[1]), tostring(pr[2]) }
		pump_recipes[#pump_recipes + 1] = name
	end
end

--- Issue #318 (maintainer's decision): GTNH's uses of the pumped heavy and light oil (gregtech DistilleryRecipes.java), which
--- nothing used before. As GT distils its four oils alike, they are distilled like Gregtorio's crude oil
--- (`oil-distillation`, `oil-distillation-light`, `oil-distillation-heavy`: half of GT's 100 L universal distillation, the
--- time in GT's ratio to crude oil): the tall distillation tower into sulfuric heavy fuel, light fuel, naphtha and gas
--- (GT per 100: heavy oil 100, 45, 15, 60 in 40 ticks; light oil 7, 13, 20, 160 in 10 ticks; crude 30, 100, 40, 120 in 30;
--- GT's naphthenic acid of the tower is left out, the mod has none), the distillery into one of the fuels, and the distillery
--- into lubricant (GT: 12 L of heavy oil into 9, of light oil into 3, 16 ticks). They come with the pump module, the only
--- producer of these oils (#252's rule); issue #361: the drilling rigs pump them too (164), so 164 moves them to crude
--- oil's technologies (Oil Processing, Diesel).
local CRUDE_TIME = 20   -- oil-distillation (crude oil, GT's 30 ticks)
local OILS = {
	--  fluid        GT ticks  heavy fuel  light fuel  naphtha  gas   lubricant per 40
	{ "heavy-oil", 40,       50,         22.5,       7.5,     30,   30 },
	{ "light-oil", 10,       3.5,        6.5,        10,      80,   10 },
}
local oil_recipes = {}
for _, o in ipairs(OILS) do
	local time = CRUDE_TIME * o[2] / 30
	local function add(name, category, seconds, ingredients, results, main)
		create_recipe{ name = name, category = category, energy_required = seconds, ingredients = ingredients,
			results = results, main_product = main }
		oil_recipes[#oil_recipes + 1] = name
	end
	add(o[1] .. "-distillation", "mv-tall-distillation-recipes", time, { fluid(o[1], 50) }, {
		fluid("sulfuric-gas", o[6]), fluid("sulfuric-heavy-fuel", o[3]), fluid("sulfuric-light-fuel", o[4]),
		fluid("sulfuric-naphtha", o[5]) }, o[1] == "heavy-oil" and "sulfuric-heavy-fuel" or "sulfuric-gas")
	add(o[1] .. "-distillation-light", "mv-distillation-recipes", time, { fluid(o[1], 50) },
		{ fluid("sulfuric-light-fuel", o[4]) })
	add(o[1] .. "-distillation-heavy", "mv-distillation-recipes", time, { fluid(o[1], 50) },
		{ fluid("sulfuric-heavy-fuel", o[3]) })
	add(o[1] .. "-lubricant", "mv-distillation-recipes", 16 / 20 * 40 / 12, { fluid(o[1], 40) },
		{ fluid("lubricant", o[7]) })
end

--- Technologies: the siphon with the Jovian moons (GT: a space station around the gas giants); the pump modules after the
--- elevator motors their modules need and the materials they take (#252's rule)
F.tech{ name = "planetary-gas-siphon", prerequisites = { "reach-the-jovian-moons" }, packs = 7, count = 50, time = 60,
	recipes = siphon_recipes }
local PPRE = { { "space-elevator-motor-mk2", "planetary-gas-siphon", "uev-components" },
	{ "space-elevator-motor-mk3", "uiv-components", "exotic-processor-mainframes" },
	{ "space-elevator-motor-mk4", "umv-components", "temporal-processor-mainframes", "uxv-materials",
		"uxv-energy-hatches" } }   -- (molten eternity, as the UXV drone of #302)
local PPACKS = { 10, 11, 13 }
for k, name in ipairs(pumps) do
	local pre = {}
	if k > 1 then pre[1] = pumps[k - 1] end
	for _, x in ipairs(PPRE[k]) do pre[#pre + 1] = x end
	F.tech{ name = name, prerequisites = pre, packs = PPACKS[k], count = 50, time = 60,
		recipes = k == 1 and F.join(F.join({ name }, pump_recipes), oil_recipes) or { name } }
end
