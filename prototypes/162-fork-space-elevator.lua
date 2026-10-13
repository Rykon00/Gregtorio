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
data:extend({ { type = "mod-data", name = "fork-space-elevator", data = { elevators = view } } })

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
