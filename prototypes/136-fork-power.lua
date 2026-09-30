--------------------------------------------------------------------------------
--- FORK ENDGAME POWER
--- Power generation from LuV up the GTNH way, on top of the fusion reactors of 125 to 133:
---   * every plasma a fusion reactor makes gets a fuel value (GT5-Unofficial values, 1 EU = 1 kJ
---     like the rest of Gregtorio: 32 EU/t of LV = 640 kW)
---   * large plasma turbines (LuV to UXV; GT: the large plasma turbine, capped by its dynamo
---     hatch): burn only plasmas, return the cooled fluid (helium plasma -> helium) into a turbine
---     output hatch next to them (runtime, scripts/fork-power.lua)
---   * the naquadah fuel line of GoodGenerator (acid naquadah emulsion -> emulsion -> solution ->
---     light and heavy naquadah fuel and naquadah gas -> naquadah based fuel MK1 to MK3) and the
---     liquid nuclear fuels (uranium, plutonium; "excited" in the fusion reactor)
---   * large naquadah reactors (UV to UXV; GT: the large naquadah reactor) that burn them
---   * dynamo hatches LuV to UXV: copies of the energy hatch of the tier, the part every large
---     generator needs
--- The generators are `generator` prototypes that burn the fluid's fuel value (like the steam
--- turbines): one machine per tier and fuel family (a runtime check stops it on any other fluid,
--- steam included), the tier caps the output at four amps
--- (4 x EU32 of the tier). Balance and deviations from GT: docs/ROADMAP.md, "Endgame power".
--- Loaded after 135-fork-endgame.lua and before 150-fork-molds.lua.
--------------------------------------------------------------------------------

local F = FORK5B
local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local FORK_ICON_PATH = "__gregtorio-continued__/graphics/icons/fork/"
local LOG = "FORK-POWER: "

local function ensure_subgroup(name, like)
	if data.raw["item-subgroup"][name] then return end
	local src = data.raw["item-subgroup"][like]
	data:extend({ { type = "item-subgroup", name = name, group = src and src.group or "processing-machine-recipes",
		order = src and (src.order .. "z") or "zz" } })
end
ensure_subgroup("subgroup-umv-age-multiblocks", "subgroup-uiv-age-multiblocks")

--- 1 EU = 1 kJ: 81 920 EU per unit -> "81.92MJ"
local function eu(value)
	if value >= 1e6 then return string.format("%.5gGJ", value / 1e6) end
	return string.format("%.5gMJ", value / 1e3)
end



--------------------------------------------------------------------------------
--- 1) PLASMA FUEL VALUES
--- GT5-Unofficial ProcessingCell.java (plasma cells, FUEL_TYPE 4): EU per mB. Neon and krypton
--- are not in GT's list and take its default (1024 x mass). The cooled fluid is what GT's large
--- plasma turbine returns ("plasma.helium" -> "helium", else "molten.<name>") where the fluid
--- exists here; zinc and niobium have no molten fluid, boron, calcium and sulfur none at all.
--------------------------------------------------------------------------------

local PLASMAS = {
	--  plasma              EU per unit  cooled fluid
	{ "helium-plasma",     81920,   "helium" },
	{ "boron-plasma",     112640,   nil },
	{ "calcium-plasma",   188416,   nil },
	{ "neon-plasma",       20480,   "neon" },
	{ "sulfur-plasma",    170393,   nil },
	{ "nitrogen-plasma",  129024,   "nitrogen" },
	{ "zinc-plasma",      226304,   nil },
	{ "niobium-plasma",   269516,   nil },
	{ "tin-plasma",       150000,   "molten-tin" },
	{ "titanium-plasma",  196608,   "molten-titanium" },
	{ "oxygen-plasma",    131072,   "oxygen" },
	{ "krypton-plasma",    86016,   "krypton" },
	{ "iron-plasma",      206438,   "molten-iron" },
}
local cooled = {}
for _, p in pairs(PLASMAS) do
	local fluid = data.raw.fluid[p[1]]
	if fluid then
		fluid.fuel_value = eu(p[2])
		if p[3] and data.raw.fluid[p[3]] then cooled[p[1]] = p[3] end
	else
		log(LOG .. "missing plasma: " .. p[1])
	end
end



--------------------------------------------------------------------------------
--- 1b) PLASMA BALANCE (issue #32)
--- Energy per recipe second is the same in every machine tier here (speed and power double
--- together), so the input chain of a plasma costs the same energy at any tier; GT's
--- overclocking doubles the energy per craft with every tier instead. With the upstream times
--- and yields one MK1 on D + He-3 made 5.12 GW (125x its draw, 30x over the full chain), more
--- than one of every IV to UV machine draws together. The cheap plasmas are brought to 11x to
--- 17x over the full chain and about 1 GW of plasma per MK1, 2 GW per MK2 and 4 GW per MK3:
---   * helium-3 costs as much energy as deuterium (1.92 MJ per unit instead of 0.19): 50 per
---     compressed end stone in 200 s (GT: 7.5 per endstone dust, 3.4 MJ, through helium)
---   * the helium, nitrogen, niobium and tin plasma recipes take longer
---   * sulfur and iron plasma take half an ingot of each metal instead of a nugget
--- The fuel values stay GT's. Numbers and the full-chain analysis: docs/ROADMAP.md, "Balance".
---   recipe = { energy_required, { [ingredient or result] = new amount } }
--------------------------------------------------------------------------------

local PLASMA_BALANCE = {
	["end-stone-centrifuging"] = { 50 * HV_SPEED, { ["helium-3"] = 50 } },
	["helium-plasma-first"]    = { 10 * LUV_SPEED, {} },
	["helium-plasma-second"]   = { 10 * LUV_SPEED, {} },
	["nitrogen-plasma"]        = { 8 * ZPM_SPEED, {} },
	["niobium-plasma"]         = { 20 * ZPM_SPEED, {} },
	["tin-plasma"]             = { 24 * ZPM_SPEED, {} },
	["sulfur-plasma"]          = { 16 * ZPM_SPEED, { ["molten-lithium"] = 72, ["molten-aluminium"] = 72 } },
	["iron-plasma"]            = { 8 * UV_SPEED, { ["molten-silicon"] = 72, ["molten-magnesium"] = 72 } },
}
for name, b in pairs(PLASMA_BALANCE) do
	local r = data.raw.recipe[name]
	if r then
		r.energy_required = b[1]
		for _, list in pairs({ r.ingredients or {}, r.results or {} }) do
			for _, x in pairs(list) do
				if b[2][x.name] then x.amount = b[2][x.name] end
			end
		end
	else
		log(LOG .. "missing plasma recipe: " .. name)
	end
end



--------------------------------------------------------------------------------
--- 2) GENERATORS
--- A `generator` that burns fluids by fuel value (like the LV steam turbine), no filter, pass
--- through north/south. max_power_output caps the tier; scale_fluid_usage makes the fluid usage
--- follow the fuel value. A fluid without fuel value blocks instead of being destroyed; a fuel
--- the generator does not accept (steam, the other generator's fuels) stops it through
--- scripts/fork-power.lua (the accepted fuels are in the mod data, section 7).
--- fluid_usage_per_tick is the most a generator burns per tick, so it also caps the output at
--- 60 x fuel value per second (one unit of helium plasma per tick: 4.92 GW, of neon plasma:
--- 1.23 GW). It is set so that the weakest accepted fuel still reaches the cap (issue #34): 1 up
--- to the UHV turbine and for every naquadah reactor, 2 to 9 units for the UEV to UXV turbines.
---   def = { name, size, power, volume, icon, min_fuel (J per unit of the weakest accepted fuel) }
--------------------------------------------------------------------------------

--- "81.92MW" -> 81.92e6
local function watts(power)
	return tonumber(power:match("^[%d.]+")) * ({ kW = 1e3, MW = 1e6, GW = 1e9 })[power:match("%a+$")]
end

local function make_generator(def)
	local w = def.size
	local half = w / 2
	local function anim()
		return { layers = { {
			filename = SPRITE_PATH .. def.name .. "-working.png",
			width = w * 32, height = w * 32, frame_count = 1, shift = { 0, 0 },
		} } }
	end
	data:extend({ {
		type = "generator",
		name = def.name,
		icon = def.icon,
		icon_size = 32,
		flags = { "placeable-neutral", "player-creation" },
		minable = { mining_time = 1, result = def.name },
		max_health = 600,
		corpse = "big-remnants",
		dying_explosion = "big-explosion",
		resistances = { { type = "fire", percent = 70 }, { type = "impact", percent = 30 } },
		collision_box = { { -half + 0.2, -half + 0.2 }, { half - 0.2, half - 0.2 } },
		selection_box = { { -half, -half }, { half, half } },
		fast_replaceable_group = def.fast_replaceable_group,
		max_power_output = def.power,
		fluid_usage_per_tick = math.max(1, math.ceil(watts(def.power) / 60 / def.min_fuel)),
		effectivity = 1,
		burns_fluid = true,
		scale_fluid_usage = true,
		destroy_non_fuel_fluid = false,
		maximum_temperature = 1000,
		fluid_box = {
			volume = def.volume,
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures(),
			production_type = "input-output",
			pipe_connections = {
				{ position = { 0, -half + 0.5 }, flow_direction = "input-output", direction = defines.direction.north },
				{ position = { 0, half - 0.5 }, flow_direction = "input-output", direction = defines.direction.south },
			},
		},
		energy_source = { type = "electric", usage_priority = "secondary-output" },
		horizontal_animation = anim(),
		vertical_animation = anim(),
		localised_description = { "entity-description." .. def.name },
	} })
end

--- Four amps of the tier (4 x EU32): the generator of a tier supplies a few machines of it
local CAP = {
	luv = "81.92MW", zpm = "163.84MW", uv = "327.68MW", uhv = "655.36MW",
	uev = "1310.72MW", uiv = "2621.44MW", umv = "5242.88MW", uxv = "10485.76MW",
}
local TIER_ABOVE = { luv = "zpm", zpm = "uv", uv = "uhv", uhv = "uev", uev = "uiv", uiv = "umv", umv = "uxv" }
local TIER_BELOW = {}
for k, v in pairs(TIER_ABOVE) do TIER_BELOW[v] = k end
local function AL(tier) return tier .. "-assembling-machine-recipes" end
local SPEED = { luv = LUV_SPEED, zpm = ZPM_SPEED, uv = UV_SPEED, uhv = UHV_SPEED, uev = UEV_SPEED,
	uiv = UIV_SPEED, umv = UMV_SPEED, uxv = UXV_SPEED }



--------------------------------------------------------------------------------
--- 3) DYNAMO HATCHES LuV .. UXV
--- Upstream's EV and IV dynamo hatches are the energy hatch recipes with the same parts; the
--- fork's ones are the same: a copy of the tier's energy hatch recipe (same category and time).
--------------------------------------------------------------------------------

for _, tier in pairs({ "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv" }) do
	local src_item = data.raw.item[tier .. "-energy-hatch"]
	local src_recipe = data.raw.recipe[tier .. "-energy-hatch"]
	local name = tier .. "-dynamo-hatch"
	if src_item and src_recipe then
		local item = table.deepcopy(src_item)
		item.name = name
		item.icon = ICON_PATH .. name .. ".png"
		item.icons = nil
		item.order = (item.order or "") .. "-dynamo"
		local recipe = table.deepcopy(src_recipe)
		recipe.name = name
		recipe.results = { { type = "item", name = name, amount = 1 } }
		recipe.main_product = name
		recipe.enabled = false
		recipe.icon = nil
		recipe.icons = nil
		data:extend({ item, recipe })
	else
		log(LOG .. "no energy hatch to copy for " .. name)
	end
end



--------------------------------------------------------------------------------
--- 4) LARGE PLASMA TURBINES (LuV .. UXV)
--- GT: tungstensteel turbine casings and frames, a turbine rotor, the dynamo hatch caps the
--- output. Here one 3x3 generator per tier; ZPM to UXV are upgrades of the tier below (the
--- replaced dynamo hatch comes back, like the multiblock upgrades of the tiers). Issue #34 added
--- UHV to UXV: each MKn fusion reactor feeds 12.5 turbines of its own machine tier on helium
--- plasma (MK1 LuV, MK2 ZPM, MK3 UV, MK4 UEV, MK5 UIV). GT++'s XL plasma turbine (16 turbines in
--- one, any dynamo hatches) is not followed: the tier of the dynamo hatch caps every generator
--- here, see docs/ROADMAP.md, "Endgame power".
--------------------------------------------------------------------------------

create_item{
	name = "tungstensteel-turbine-casing",
	icon = FORK_ICON_PATH .. "tungstensteel-turbine-casing.png",
	category = AL("iv"),
	energy_required = 5 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 6 },
		{ type = "item", name = "titanium-turbine-casing", amount = 1 },
	},
}
create_item{
	name = "tungstensteel-turbine-blade",
	category = AL("iv"),
	energy_required = 5 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 2 },
		{ type = "item", name = "tungstensteel-screw", amount = 1 },
	},
}
create_item{
	name = "tungstensteel-turbine-rotor",
	category = AL("iv"),
	energy_required = 10 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tungstensteel-turbine-blade", amount = 8 },
		{ type = "item", name = "long-tungstensteel-rod", amount = 1 },
	},
}
create_item{
	name = "large-plasma-turbine-controller",
	category = AL("luv"),
	energy_required = 60 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "large-naquadah-alloy-gear", amount = 4 },
		{ type = "item", name = "tungstensteel-plate", amount = 12 },
	},
}
create_item{
	name = "luv-large-plasma-turbine",
	icon = FORK_ICON_PATH .. "luv-large-plasma-turbine.png",
	category = AL("luv"),
	energy_required = 120 * LUV_SPEED,
	subgroup = "subgroup-luv-age-multiblocks",
	place_result = "luv-large-plasma-turbine",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-plasma-turbine-controller", amount = 1 },
		{ type = "item", name = "luv-dynamo-hatch", amount = 1 },
		{ type = "item", name = "tungstensteel-turbine-casing", amount = 28 },
		{ type = "item", name = "tungstensteel-frame", amount = 14 },
		{ type = "item", name = "tungstensteel-turbine-rotor", amount = 1 },
	},
}
--- The turbine output hatch: a 1x1 tank next to a plasma turbine that receives the cooled
--- fluid (scripts/fork-power.lua, exact since issue #28); what does not fit waits in the
--- turbine, without a hatch the cooled fluid is lost, as in GT
local HATCH = "turbine-output-hatch"
create_item{
	name = HATCH,
	icon = FORK_ICON_PATH .. HATCH .. ".png",
	category = AL("luv"),
	energy_required = 10 * LUV_SPEED,
	subgroup = "subgroup-luv-age-multiblocks",
	place_result = HATCH,
	stack_size = 50,
	ingredients = {
		{ type = "item", name = "tungstensteel-turbine-casing", amount = 1 },
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "pipe", amount = 2 },
	},
}
data:extend({ {
	type = "storage-tank",
	name = HATCH,
	icon = FORK_ICON_PATH .. HATCH .. ".png",
	icon_size = 32,
	flags = { "placeable-neutral", "player-creation" },
	minable = { mining_time = 0.3, result = HATCH },
	max_health = 400,
	corpse = "small-remnants",
	collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
	selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
	fluid_box = {
		volume = 4000,
		pipe_covers = pipecoverspictures(),
		hide_connection_info = true,                  -- four connections on one tile, like a pipe
		pipe_connections = {
			{ direction = defines.direction.north, position = { 0, 0 } },
			{ direction = defines.direction.east, position = { 0, 0 } },
			{ direction = defines.direction.south, position = { 0, 0 } },
			{ direction = defines.direction.west, position = { 0, 0 } },
		},
	},
	window_bounding_box = { { -0.25, -0.25 }, { 0.25, 0.25 } },
	flow_length_in_ticks = 360,
	pictures = {
		picture = { filename = SPRITE_PATH .. HATCH .. ".png", priority = "extra-high", width = 32, height = 32 },
	},
	two_direction_only = false,
	circuit_wire_max_distance = 0,
	localised_description = { "entity-description." .. HATCH },
} })

--- Upgrades: the previous turbine, the dynamo hatch and a hull of the tier
local function upgrade(base, tier, kind, hulls)
	local below = TIER_BELOW[tier]
	local name = tier .. "-" .. kind
	local prev = below .. "-" .. kind
	create_item{
		name = name,
		icon = FORK_ICON_PATH .. name .. ".png",
		category = AL(tier),
		energy_required = 60 * SPEED[tier],
		subgroup = "subgroup-" .. tier .. "-age-multiblocks",
		place_result = name,
		stack_size = 10,
		ingredients = {
			{ type = "item", name = prev, amount = 1 },
			{ type = "item", name = tier .. "-dynamo-hatch", amount = 1 },
			{ type = "item", name = tier .. "-machine-hull", amount = hulls },
		},
		results = {
			{ type = "item", name = name, amount = 1 },
			{ type = "item", name = below .. "-dynamo-hatch", amount = 1 },
			{ type = "item", name = below .. "-machine-hull", amount = hulls },
		},
		main_product = name,
	}
end
local TURBINE_TIERS = { "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv" }
for i = 2, #TURBINE_TIERS do
	upgrade("luv", TURBINE_TIERS[i], "large-plasma-turbine", 1)
end

local min_plasma = math.huge
for _, p in pairs(PLASMAS) do
	if data.raw.fluid[p[1]] then min_plasma = math.min(min_plasma, p[2] * 1e3) end
end
for _, tier in pairs(TURBINE_TIERS) do
	make_generator{
		name = tier .. "-large-plasma-turbine", size = 3, power = CAP[tier], volume = 1000, min_fuel = min_plasma,
		icon = FORK_ICON_PATH .. tier .. "-large-plasma-turbine.png",
		fast_replaceable_group = "fr-large-plasma-turbine",
	}
end



--------------------------------------------------------------------------------
--- 5) NAQUADAH FUEL LINE (GoodGenerator)
--- The drafts in 21-luv-age-item.lua with their missing fluids and items fixed:
---   enriched naquadah dust + HF -> acid naquadah emulsion (+ radioactive sludge)
---   -> naquadah emulsion (quicklime) -> naquadah solution (centrifuge)
---   -> light and heavy naquadah fuel, naquadah gas, water (distillation tower)
---   light + heavy -> naquadah based fuel MK1 (fusion MK2), MK2 (UHV mixer), MK3 (UEV mixer)
--- Shortened against GT: no naquadah asphalt and no cracking of the fuels, no antimony
--- trioxide, no tiberium, no high density uranium (uranium dust instead; high density plutonium
--- replaces the plutonium dust in 137-fork-endgame-materials.lua),
--- no naquadah fuel refinery. The liquid nuclear fuels of GoodGenerator (uranium, plutonium) are
--- mixed from dust and "excited" in the fusion reactor MK2 (the drafts).
--- Fuel values: GoodGenerator GGConfigLoader (basic output x burning time per mB, 1 EU = 1 kJ).
--------------------------------------------------------------------------------

for _, f in pairs({
	{ "acid-naquadah-emulsion", "medium-green-fluid", { 0.35, 0.60, 0.25 } },
	{ "naquadah-emulsion", "forest-green-fluid", { 0.20, 0.50, 0.25 } },
	{ "naquadah-solution", "spackled-forest-green-fluid", { 0.15, 0.45, 0.30 } },
	{ "light-naquadah-fuel", "pale-green-fluid", { 0.60, 0.85, 0.50 } },
	{ "heavy-naquadah-fuel", "rich-green-fluid", { 0.15, 0.55, 0.20 } },
	{ "naquadah-gas", "spackled-mint-green-fluid", { 0.55, 0.90, 0.70 } },
	{ "naquadah-based-fuel-mk1", "spackled-forest-green-fluid", { 0.30, 0.70, 0.30 } },
	{ "naquadah-based-fuel-mk2", "spackled-forest-green-fluid", { 0.25, 0.75, 0.45 } },
	{ "naquadah-based-fuel-mk3", "spackled-forest-green-fluid", { 0.20, 0.80, 0.60 } },
	{ "uranium-based-liquid-fuel", "spackled-yellow-fluid", { 0.75, 0.80, 0.30 } },
	{ "excited-uranium-based-liquid-fuel", "spackled-yellow-fluid", { 0.90, 0.95, 0.30 } },
	{ "plutonium-based-liquid-fuel", "spackled-orange-fluid", { 0.85, 0.55, 0.25 } },
	{ "excited-plutonium-based-liquid-fuel", "spackled-orange-fluid", { 1.00, 0.60, 0.20 } },
}) do
	F.fluid(f[1], f[2], f[3])
end
--- GoodGenerator: basic output (EU/t) x burning time (ticks) per mB
local FUELS = {
	{ "excited-uranium-based-liquid-fuel", 12960 * 100 },
	{ "excited-plutonium-based-liquid-fuel", 32400 * 150 },
	{ "naquadah-based-fuel-mk1", 975000 * 60 },
	{ "naquadah-based-fuel-mk2", 2300000 * 70 },
	{ "naquadah-based-fuel-mk3", 9511000 * 80 },
}
for _, f in pairs(FUELS) do data.raw.fluid[f[1]].fuel_value = eu(f[2]) end

--- The drafts: the emulsion has no antimony trioxide (no such item), the sludge centrifuging
--- no calcium and tiberium dust (no such items), the fuel MK1 takes GT's amounts (the draft had
--- a tenth), the plutonium fuel takes plutonium dust instead of high density plutonium (the
--- chain is made real in 137-fork-endgame-materials.lua, which switches the fuel to it) and
--- neutronium ingots instead of dust (no dust here), and makes GT's 1000 units
do
	local r = data.raw.recipe["naquadah-emulsion"]
	if r then
		r.results = {
			{ type = "item", name = "fluorspar", amount = 4 },
			{ type = "fluid", name = "naquadah-emulsion", amount = 100 },
		}
	end
	r = data.raw.recipe["radioactive-sludge-centrifuging"]
	if r then
		r.results = {
			{ type = "item", name = "enriched-naquadah-dust", amount = 1, probability = 0.8 },
			{ type = "item", name = "uranium-238-dust", amount = 1, probability = 0.25 },
			{ type = "item", name = "plutonium-239-dust", amount = 1, probability = 0.2 },
			{ type = "fluid", name = "radon", amount = 2 },
		}
	end
	F.redo("naquadah-based-fuel-mk1", {
		ingredients = {
			{ type = "fluid", name = "light-naquadah-fuel", amount = 780 },
			{ type = "fluid", name = "heavy-naquadah-fuel", amount = 360 },
		},
		results = { { type = "fluid", name = "naquadah-based-fuel-mk1", amount = 100 } },
	})
	F.redo("plutonium-based-liquid-fuel", {
		ingredients = {
			{ type = "item", name = "plutonium-239-dust", amount = 64 },
			{ type = "item", name = "neutronium-ingot", amount = 2 },
			{ type = "item", name = "caesium-dust", amount = 16 },
			{ type = "item", name = "naquadah-dust", amount = 2 },
		},
		results = { { type = "fluid", name = "plutonium-based-liquid-fuel", amount = 1000 } },
	})
end

--- The distillation step of the draft was overwritten by two later drafts of the same name
create_recipe{
	name = "naquadah-solution-distillation",
	category = "ev-tall-distillation-recipes",
	energy_required = 10 * EV_SPEED,
	ingredients = { { type = "fluid", name = "naquadah-solution", amount = 20 } },
	results = {
		{ type = "fluid", name = "light-naquadah-fuel", amount = 10 },
		{ type = "fluid", name = "heavy-naquadah-fuel", amount = 5 },
		{ type = "fluid", name = "naquadah-gas", amount = 60 },
		{ type = "fluid", name = "water", amount = 10 },
	},
	main_product = "light-naquadah-fuel",
}
--- GT: uranium fuel = high density uranium (a stack of uranium), potassium, quantium, radon
create_recipe{
	name = "uranium-based-liquid-fuel",
	category = "luv-mixer-recipes",
	energy_required = 10 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "uranium-238-dust", amount = 64 },
		{ type = "item", name = "potassium", amount = 8 },
		{ type = "item", name = "naquadah-dust", amount = 4 },
		{ type = "fluid", name = "radon", amount = 1000 },
	},
	results = { { type = "fluid", name = "uranium-based-liquid-fuel", amount = 1000 } },
}
--- GT: MK1 + naquadah gas + nether star dust + fluxed electrum dust (naquadria here; fluxed
--- electrum since issue #36, 137-fork-endgame-materials.lua)
create_recipe{
	name = "naquadah-based-fuel-mk2",
	category = "uhv-mixer-recipes",
	energy_required = 25 * UHV_SPEED,
	ingredients = {
		{ type = "fluid", name = "naquadah-based-fuel-mk1", amount = 100 },
		{ type = "fluid", name = "naquadah-gas", amount = 1500 },
		{ type = "item", name = "nether-star", amount = 1 },
		{ type = "item", name = "naquadria-dust", amount = 16 },
	},
	results = { { type = "fluid", name = "naquadah-based-fuel-mk2", amount = 100 } },
}
--- GT: naquadah fuel refinery with extremely unstable naquadah, tiberium, high density
--- uranium/plutonium and both fuels; here MK2, the heavy fuel (the mixer has two fluid inputs),
--- uranium, plutonium and naquadria
create_recipe{
	name = "naquadah-based-fuel-mk3",
	category = "uev-mixer-recipes",
	energy_required = 20 * UEV_SPEED,
	ingredients = {
		{ type = "fluid", name = "naquadah-based-fuel-mk2", amount = 100 },
		{ type = "fluid", name = "heavy-naquadah-fuel", amount = 800 },
		{ type = "item", name = "uranium-238-dust", amount = 32 },
		{ type = "item", name = "plutonium-239-dust", amount = 16 },
		{ type = "item", name = "naquadria-dust", amount = 8 },
	},
	results = { { type = "fluid", name = "naquadah-based-fuel-mk3", amount = 100 } },
}



--------------------------------------------------------------------------------
--- 6) LARGE NAQUADAH REACTORS (UV .. UXV)
--- GT: one UV-tier multiblock (ZPM field generators and pumps, UV circuits) whose output the
--- dynamo hatch caps. Here a 5x5 generator per tier, UHV to UXV as upgrades of the UV one.
--- No depleted fuel and no coolant bonus (GT: super coolant, cryotheum).
--------------------------------------------------------------------------------

create_item{
	name = "naquadah-reactor-casing",
	icon = FORK_ICON_PATH .. "naquadah-reactor-casing.png",
	category = AL("luv"),
	energy_required = 10 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-plate", amount = 4 },
		{ type = "item", name = "lead-plate", amount = 4 },
		{ type = "item", name = "thick-neutron-reflector", amount = 1 },
		{ type = "item", name = "europium-plate", amount = 1 },
	},
}
create_item{
	name = "large-naquadah-reactor-controller",
	category = AL("uv"),
	energy_required = 60 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "zpm-field-generator", amount = 2 },
		{ type = "item", name = "zpm-pump", amount = 4 },
		{ type = "item", name = "naquadah-plate", amount = 8 },
		{ type = "item", name = "osmium-plate", amount = 8 },
		{ type = "fluid", name = "molten-trinium", amount = 57.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
	},
}
create_item{
	name = "uv-large-naquadah-reactor",
	icon = FORK_ICON_PATH .. "uv-large-naquadah-reactor.png",
	category = AL("uv"),
	energy_required = 120 * UV_SPEED,
	subgroup = "subgroup-uv-age-multiblocks",
	place_result = "uv-large-naquadah-reactor",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-naquadah-reactor-controller", amount = 1 },
		{ type = "item", name = "uv-dynamo-hatch", amount = 1 },
		{ type = "item", name = "naquadah-reactor-casing", amount = 48 },
		{ type = "item", name = "uv-machine-hull", amount = 4 },
	},
}
for _, tier in pairs({ "uhv", "uev", "uiv", "umv", "uxv" }) do
	upgrade("uv", tier, "large-naquadah-reactor", 4)
end
local min_fuel = math.huge
for _, f in pairs(FUELS) do min_fuel = math.min(min_fuel, f[2] * 1e3) end
for _, tier in pairs({ "uv", "uhv", "uev", "uiv", "umv", "uxv" }) do
	make_generator{
		name = tier .. "-large-naquadah-reactor", size = 5, power = CAP[tier], volume = 1000, min_fuel = min_fuel,
		icon = FORK_ICON_PATH .. tier .. "-large-naquadah-reactor.png",
		fast_replaceable_group = "fr-large-naquadah-reactor",
	}
end



--------------------------------------------------------------------------------
--- 7) MOD DATA for scripts/fork-power.lua (the turbines, the cooled fluids, the hatch, and the
--- fuels each generator accepts: the engine burns any fluid with a fuel value, steam included,
--- and a fluid box filter takes only one fluid, so the script stops a generator on a wrong fuel)
--------------------------------------------------------------------------------

local plasma_fuels, reactor_fuels = {}, {}
for _, p in pairs(PLASMAS) do
	if data.raw.fluid[p[1]] then plasma_fuels[#plasma_fuels + 1] = p[1] end
end
for _, f in pairs(FUELS) do reactor_fuels[#reactor_fuels + 1] = f[1] end
local turbines = {}
for _, tier in pairs(TURBINE_TIERS) do turbines[#turbines + 1] = tier .. "-large-plasma-turbine" end
local fuels = {}
for _, n in pairs(turbines) do fuels[n] = plasma_fuels end
for _, tier in pairs({ "uv", "uhv", "uev", "uiv", "umv", "uxv" }) do
	fuels[tier .. "-large-naquadah-reactor"] = reactor_fuels
end

data:extend({ {
	type = "mod-data",
	name = "fork-power",
	data = {
		turbines = turbines,
		cooled = cooled,
		hatch = HATCH,
		fuels = fuels,
	},
} })



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--------------------------------------------------------------------------------

F.tech{
	name = "plasma-turbine", prerequisites = { "fusion-plasmas-mk1", "luv-energy-hatches" }, packs = 7, count = 2500,
	recipes = {
		"tungstensteel-turbine-casing", "tungstensteel-turbine-blade", "tungstensteel-turbine-rotor",
		"luv-dynamo-hatch", "large-plasma-turbine-controller", "luv-large-plasma-turbine", HATCH,
	},
}
F.tech{
	name = "zpm-plasma-turbine", prerequisites = { "plasma-turbine", "zpm-energy-hatches" }, packs = 8, count = 2500,
	recipes = { "zpm-dynamo-hatch", "zpm-large-plasma-turbine" },
}
F.tech{
	name = "uv-plasma-turbine", prerequisites = { "zpm-plasma-turbine", "uv-energy-hatches" }, packs = 9, count = 2500,
	recipes = { "uv-dynamo-hatch", "uv-large-plasma-turbine" },
}
--- UHV to UXV (issue #34): the dynamo hatch of the tier is also unlocked by the naquadah reactor
--- of the tier, whichever comes first
for i = 4, #TURBINE_TIERS do
	local tier = TURBINE_TIERS[i]
	F.tech{
		name = tier .. "-plasma-turbine",
		prerequisites = { TURBINE_TIERS[i - 1] .. "-plasma-turbine", tier .. "-energy-hatches" },
		packs = i + 6, count = 2500,
		recipes = { tier .. "-dynamo-hatch", tier .. "-large-plasma-turbine" },
	}
end
F.tech{
	name = "naquadah-fuels", prerequisites = { "fusion-plasmas-mk2", "enriched-naquadah" }, packs = 8, count = 3000,
	recipes = {
		"acid-naquadah-emulsion", "radioactive-sludge-centrifuging", "naquadah-emulsion", "naquadah-solution",
		"naquadah-solution-distillation", "naquadah-based-fuel-mk1",
		"uranium-based-liquid-fuel", "excited-uranium-based-liquid-fuel",
		"plutonium-based-liquid-fuel", "excited-plutonium-based-liquid-fuel",
	},
}
F.tech{
	name = "large-naquadah-reactor", prerequisites = { "naquadah-fuels", "uv-plasma-turbine" }, packs = 9, count = 3000,
	recipes = { "naquadah-reactor-casing", "large-naquadah-reactor-controller", "uv-large-naquadah-reactor" },
}
F.tech{
	name = "uhv-naquadah-reactor", prerequisites = { "large-naquadah-reactor", "uhv-energy-hatches" }, packs = 10, count = 3000,
	recipes = { "uhv-dynamo-hatch", "uhv-large-naquadah-reactor", "naquadah-based-fuel-mk2" },
}
F.tech{
	name = "uev-naquadah-reactor", prerequisites = { "uhv-naquadah-reactor", "uev-energy-hatches" }, packs = 11, count = 3000,
	recipes = { "uev-dynamo-hatch", "uev-large-naquadah-reactor", "naquadah-based-fuel-mk3" },
}
F.tech{
	name = "uiv-naquadah-reactor", prerequisites = { "uev-naquadah-reactor", "uiv-energy-hatches" }, packs = 12, count = 3000,
	recipes = { "uiv-dynamo-hatch", "uiv-large-naquadah-reactor" },
}
F.tech{
	name = "umv-naquadah-reactor", prerequisites = { "uiv-naquadah-reactor", "umv-energy-hatches" }, packs = 13, count = 3000,
	recipes = { "umv-dynamo-hatch", "umv-large-naquadah-reactor" },
}
F.tech{
	name = "uxv-naquadah-reactor", prerequisites = { "umv-naquadah-reactor", "uxv-energy-hatches" }, packs = 14, count = 3000,
	recipes = { "uxv-dynamo-hatch", "uxv-large-naquadah-reactor" },
}
