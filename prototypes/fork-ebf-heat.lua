--------------------------------------------------------------------------------
--- FORK: BLAST FURNACE HEAT (issue #620, the maintainer's decision of 2026-10-27: "as GT does")
--- GT's blast furnace has a heat: its coils' (HeatingCoilLevel.java: 901 + 900 per coil tier) plus 100 K per voltage tier
--- above MV (MTEElectricBlastFurnace.java:227-228); a recipe needs its heat (the recipe's special value) and runs only at
--- that heat or more (:204); every 900 K above it costs 5 % less power, every 1800 K above it makes one overclock perfect
--- (OverclockCalculator.java:84-86, 359-360, 429).
---   * The heating coils (the coil blocks of Gregtorio's blast furnace items) are modules of the category `heating-coil`
---     with GT's heat; Gregtorio's tritanium coil (its UHV blast furnace's) stands in for GT's electrum flux coil and its
---     spacetime coil (UMV) for GT's hypogen coil, which Gregtorio lacks.
---   * Every electric blast furnace gets a coil slot. Its heat is the coil in the slot's, or (an empty slot) the coil
---     its item is built with (16 of them, GT's coil ring), plus 100 K per tier above MV.
---   * A recipe's heat: GT's (prototypes/data/gtnh-ebf-heat.lua, `devcheck.py check --gtnh-heat`) for the recipes that
---     have a GT recipe, at most the heat a blast furnace reaches where the recipe is unlocked (its `cap`; issue #742
---     moves those unlocks to GT's heat); the others need the heat of their tier's coil.
---   * scripts/fork-ebf-heat.lua stops a furnace whose heat is too low ("Heat too low") and gives one with heat to spare
---     GT's bonus through a hidden beacon in its middle: a module of +(2^k - 1) speed and 2^k x 0.95^n - 1 power for n
---     times 900 K and k times 1800 K (k at most the furnace's tiers above the recipe's: GT's overclocks), so a craft
---     takes 0.95^n of its energy and k overclocks are perfect.
--- Required from data-final-fixes.lua before fork-maintenance.lua (which appends its category to the coil slot).
--- FORK_EBF_HEAT is devcheck's section EBFHEAT; the mod data `fork-ebf-heat` is the script's.
--------------------------------------------------------------------------------

local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
local TIER = {}
for i, t in pairs(TIERS) do TIER[t] = i end
--- GT's heat of each coil (HeatingCoilLevel.java)
local COILS = {
	["cupronickel-coil-block"] = 1801, ["kanthal-coil-block"] = 2701, ["nichrome-coil-block"] = 3601,
	["rtm-alloy-coil-block"] = 4501,          -- GT's TPV alloy coil, EV
	["hssg-coil-block"] = 5401, ["naquadah-coil-block"] = 7201, ["trinium-coil-block"] = 9001,
	["tritanium-coil-block"] = 9901,          -- for GT's electrum flux coil, UEV
	["awakened-draconium-coil-block"] = 10801, ["infinity-coil-block"] = 11701,
	["spacetime-coil-block"] = 12601,         -- for GT's hypogen coil, UXV
	["eternal-coil-block"] = 13501,
}
local HEAT_PER_TIER, DISCOUNT_K, OVERCLOCK_K = 100, 900, 1800
local MAX_K, MAX_N = 6, 13       -- (13501 - 1801) / 1800 and / 900: the most bonus any recipe can get
local ICON = "__gregtorio-continued__/graphics/icons/"

FORK_EBF_HEAT = { coils = {}, machines = {}, recipes = {}, from_gt = {} }
--- recipes whose heat no blast furnace has where they are unlocked, with the reason (devcheck: section EBFHEATLATE)
FORK_EBF_HEAT_LATE = {}

data:extend({ { type = "module-category", name = "heating-coil" }, { type = "module-category", name = "fork-ebf-heat-bonus" } })

--- the coils as modules (an item of another type with the same name: the recipes and the items in a save stay)
for name, heat in pairs(COILS) do
	local it = data.raw.item[name]
	if it then
		data.raw.item[name] = nil
		it.type, it.category, it.tier, it.effect = "module", "heating-coil", 1, {}
		it.localised_description = { "item-description.fork-heating-coil", tostring(heat) }
		data:extend({ it })
		FORK_EBF_HEAT.coils[name] = heat
	end
end

--- the blast furnaces, their tier and their coil
local function coil_of(entity)
	for _, it in pairs(data.raw.item) do
		if it.place_result == entity then
			for _, r in pairs(data.raw.recipe) do
				for _, res in pairs(r.results or {}) do
					if res.name == it.name then
						local best
						for _, ing in pairs(r.ingredients or {}) do
							local h = FORK_EBF_HEAT.coils[ing.name]
							if h and (not best or h > best) then best = h end
						end
						if best then return best end
					end
				end
			end
		end
	end
end
for name, e in pairs(data.raw["assembling-machine"]) do
	local tier = name:match("^(%a+)%-electric%-blast%-furnace$")
	local coil = TIER[tier or ""] and coil_of(name)
	if coil then
		FORK_EBF_HEAT.machines[name] = { tier = TIER[tier], coil = coil }
		local had = e.module_slots or 0
		e.module_slots = had + 1
		e.allowed_module_categories = e.allowed_module_categories or (had == 0 and {} or nil)
		if e.allowed_module_categories then
			table.insert(e.allowed_module_categories, "heating-coil")
			--- (a beacon's module acts only on a machine that allows its category; the bonus modules are hidden, no
			--- player has one to put into the slot)
			table.insert(e.allowed_module_categories, "fork-ebf-heat-bonus")
		end
		--- (the engine rejects module slots without an allowed effect; coils have none, the hidden beacon's bonus is
		--- speed and power)
		e.allowed_effects = { "consumption", "speed" }
		e.effect_receiver = e.effect_receiver or {}
		e.effect_receiver.uses_beacon_effects = true
	elseif tier then
		log("FORK-EBF-HEAT: no coil in the item of " .. name)
	end
end

--- the recipes' heat: GT's, else the coil of the recipe's tier
local gt_data = require("prototypes.data.gtnh-ebf-heat")
local gt = {}
for name, heat in pairs(gt_data.heat or {}) do gt[name] = math.min(heat, (gt_data.cap or {})[name] or heat) end
local tier_coil = {}
for _, m in pairs(FORK_EBF_HEAT.machines) do tier_coil[m.tier] = m.coil end
local recipe_tier = {}
for name, r in pairs(data.raw.recipe) do
	local tier = fork_category(r):match("^(%a+)%-electric%-blast%-furnace%-recipes$")
	if TIER[tier or ""] then
		recipe_tier[name] = TIER[tier]
		local heat = gt[name]
		if not heat then
			for t = TIER[tier], 1, -1 do
				if tier_coil[t] then heat = tier_coil[t] break end
			end
		end
		FORK_EBF_HEAT.recipes[name] = heat or tier_coil[2]
		FORK_EBF_HEAT.from_gt[name] = gt[name] ~= nil
	end
end

--- the hidden beacon and its bonus modules
local bonus_icon = { { icon = ICON .. "eternal-coil-block.png", icon_size = 32 } }
for k = 0, MAX_K do
	for n = 0, MAX_N do
		if k > 0 or n > 0 then
			data:extend({ {
				type = "module", name = "fork-ebf-heat-bonus-" .. k .. "-" .. n, icons = bonus_icon, hidden = true,
				hidden_in_factoriopedia = true, subgroup = "subgroup-tool-recipes", order = "z", stack_size = 1,
				category = "fork-ebf-heat-bonus", tier = 1,
				effect = { speed = 2 ^ k - 1, consumption = math.max(2 ^ k * 0.95 ^ n - 1, -0.8) },
			} })
		end
	end
end
data:extend({ {
	type = "beacon", name = "fork-ebf-heat-beacon", icons = bonus_icon, hidden = true, hidden_in_factoriopedia = true,
	flags = { "not-on-map", "placeable-off-grid", "not-blueprintable", "not-deconstructable", "no-copy-paste",
		"not-flammable", "not-repairable" },
	selectable_in_game = false, collision_box = { { -0.1, -0.1 }, { 0.1, 0.1 } }, collision_mask = { layers = {} },
	max_health = 1, energy_source = { type = "void" }, energy_usage = "1W", supply_area_distance = 0,
	distribution_effectivity = 1, distribution_effectivity_bonus_per_quality_level = 0, profile = { 1 },
	beacon_counter = "same_type", module_slots = 1, allowed_effects = { "consumption", "speed" },
	allowed_module_categories = { "fork-ebf-heat-bonus" },
} })

data:extend({ { type = "mod-data", name = "fork-ebf-heat", data = {
	machines = FORK_EBF_HEAT.machines, coils = FORK_EBF_HEAT.coils, recipes = FORK_EBF_HEAT.recipes, recipe_tier = recipe_tier,
	beacon = "fork-ebf-heat-beacon", heat_per_tier = HEAT_PER_TIER, discount = DISCOUNT_K, overclock = OVERCLOCK_K,
	max_k = MAX_K, max_n = MAX_N,
} } })
