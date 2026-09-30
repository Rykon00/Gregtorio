--------------------------------------------------------------------------------
--- FORK QOL TECHS (issue #29)
--- 23 vanilla quality-of-life technologies were enabled but could never be
--- researched: their vanilla prerequisites (advanced-circuit, carbon-fiber,
--- lubricant, robotics) are disabled by data-final-fixes.lua. They are gated onto
--- Gregtorio techs here, with Gregtorio science packs of their tier, and the
--- vanilla recipes they unlock get GT-style recipes.
---
--- Tiers (science pack tech of the tier in brackets):
---   LV logistic, MV military, HV chemical, EV production, IV utility,
---   LuV space, ZPM metallurgic
--- Belts follow the mod's own belts: transport belt LV, fast MV (with an LV
--- conveyor module), so express HV (MV module) and turbo EV (HV module).
--- Robots: construction-robotics and logistic-robotics (MV) make the t1 robots,
--- so the worker robot techs start at MV. Nothing is hidden.
---
--- Loaded right after 102 (needs only upstream items and techs of 98).
--------------------------------------------------------------------------------

local PACKS = { "automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack",
	"production-science-pack", "utility-science-pack", "space-science-pack", "metallurgic-science-pack" }
local AMOUNTS = { SP01, SP02, SP03, SP04, SP05, SP06, SP07, SP08 }

--- The first n packs; the highest pack costs SP01, the one below SP02, ... (like the tier techs of 98)
local function sci(n)
	local out = {}
	for i = 1, n do
		out[#out + 1] = { PACKS[i], AMOUNTS[n - i + 1] }
	end
	return out
end

--- tier: number of packs (3 MV, 4 HV, 5 EV, 6 IV, 7 LuV, 8 ZPM)
local TIME = { [3] = 30, [4] = 30, [5] = 45, [6] = 60, [7] = 90, [8] = 120 }

local function regate(name, prerequisites, packs, count)
	local t = data.raw.technology[name]
	if not t then log("FORK-QOL: missing tech " .. name) return end
	t.prerequisites = prerequisites
	t.research_trigger = nil
	local unit = { ingredients = sci(packs), time = TIME[packs] }
	if type(count) == "string" then unit.count_formula = count else unit.count = count end
	t.unit = unit
end

--- Replace a vanilla recipe (keeps name, subgroup, order and icon): handcraftable and in
--- assembling machines like the other belts and inserters of the mod, no surface conditions
--- (the turbo belts were Vulcanus only), no lubricant/carbon fiber/jelly/tungsten
local function gt_recipe(name, ingredients, amount)
	local r = data.raw.recipe[name]
	if not r then log("FORK-QOL: missing recipe " .. name) return end
	r.category = "crafting-or-assembling-recipes"
	r.surface_conditions = nil
	r.energy_required = 1
	r.ingredients = ingredients
	r.results = { { type = "item", name = name, amount = amount or 1 } }
	r.hide_from_player_crafting = false
	r.enabled = false
end

local function item(name, amount) return { type = "item", name = name, amount = amount } end



--------------------------------------------------------------------------------
--- RECIPES
--------------------------------------------------------------------------------

gt_recipe("bulk-inserter", { item("fast-inserter", 1), item("mv-robot-arm", 1), item("advanced-circuit", 2), item("aluminium-plate", 2) })
gt_recipe("stack-inserter", { item("bulk-inserter", 1), item("hv-robot-arm", 1), item("processing-unit", 2), item("stainless-steel-plate", 2) })

gt_recipe("express-transport-belt", { item("fast-transport-belt", 4), item("mv-conveyor-module", 1) }, 4)
gt_recipe("express-underground-belt", { item("fast-underground-belt", 2), item("mv-conveyor-module", 1) }, 2)
gt_recipe("express-splitter", { item("fast-splitter", 1), item("mv-piston", 2) })

gt_recipe("turbo-transport-belt", { item("express-transport-belt", 4), item("hv-conveyor-module", 1) }, 4)
gt_recipe("turbo-underground-belt", { item("express-underground-belt", 2), item("hv-conveyor-module", 1) }, 2)
gt_recipe("turbo-splitter", { item("express-splitter", 1), item("hv-piston", 2) })



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--------------------------------------------------------------------------------

--- Inserters: bulk inserter MV, stack inserter HV; capacity bonuses MV to IV (level 1 only
--- raises the bulk inserter capacity, so it needs the bulk inserter like in vanilla)
regate("bulk-inserter", { "fast-inserter", "logistics-2", "mv-components" }, 3, 300)
regate("inserter-capacity-bonus-1", { "bulk-inserter" }, 3, 300)
regate("inserter-capacity-bonus-2", { "inserter-capacity-bonus-1" }, 3, 360)
regate("inserter-capacity-bonus-3", { "inserter-capacity-bonus-2", "chemical-science-pack" }, 4, 450)
regate("inserter-capacity-bonus-4", { "inserter-capacity-bonus-3" }, 4, 550)
regate("inserter-capacity-bonus-5", { "inserter-capacity-bonus-4", "production-science-pack" }, 5, 600)
regate("inserter-capacity-bonus-6", { "inserter-capacity-bonus-5" }, 5, 600)
regate("inserter-capacity-bonus-7", { "inserter-capacity-bonus-6", "utility-science-pack" }, 6, 800)
regate("stack-inserter", { "bulk-inserter", "hv-components" }, 4, 500)

--- Belts: express HV, turbo EV; the belt stack size bonuses only help stack inserters
regate("logistics-3", { "logistics-2", "hv-components" }, 4, 450)
regate("turbo-transport-belt", { "logistics-3", "ev-components" }, 5, 600)
regate("transport-belt-capacity-1", { "stack-inserter", "production-science-pack" }, 5, 600)
regate("transport-belt-capacity-2", { "transport-belt-capacity-1", "utility-science-pack" }, 6, 800)

--- Worker robots: speed MV to ZPM (level 7 stays infinite), cargo size MV to EV
regate("worker-robots-speed-1", { "construction-robotics", "logistic-robotics" }, 3, 340)
regate("worker-robots-speed-2", { "worker-robots-speed-1", "chemical-science-pack" }, 4, 450)
regate("worker-robots-speed-3", { "worker-robots-speed-2" }, 4, 550)
regate("worker-robots-speed-4", { "worker-robots-speed-3", "production-science-pack" }, 5, 600)
regate("worker-robots-speed-5", { "worker-robots-speed-4", "utility-science-pack" }, 6, 800)
regate("worker-robots-speed-6", { "worker-robots-speed-5", "space-science-pack" }, 7, 1000)
regate("worker-robots-speed-7", { "worker-robots-speed-6", "metallurgic-science-pack" }, 8, "2^(L-6)*1000")
regate("worker-robots-storage-1", { "logistic-robotics" }, 3, 340)
regate("worker-robots-storage-2", { "worker-robots-storage-1", "chemical-science-pack" }, 4, 500)
regate("worker-robots-storage-3", { "worker-robots-storage-2", "production-science-pack" }, 5, 600)
