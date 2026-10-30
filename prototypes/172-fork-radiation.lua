--------------------------------------------------------------------------------
--- FORK: RADIATION (issue #621, the maintainer's decisions of 2026-10-27 and 2026-10-30; startup setting
--- gregtorio-continued-radiation, default off)
--- GT New Horizons hurts a player who carries an item of a radioactive material (GTUtility.java:2084, GTProxy.java:1312)
--- unless a full hazmat suit is worn (HazardProtection.java). Here, with the setting on, scripts/fork-radiation.lua
--- damages a character every 60 ticks for each radioactive item it carries: GT's level x (the items / 64, at least 1)
--- poison damage, unless its armor protects.
---   * The radioactive items and their level: prototypes/data/radioactive.lua (`devcheck.py check --radioactive`: GT's,
---     bartworks' and GT++'s radioactive materials, tools/gt_radioactivity.py, on Gregtorio's items; and the fuel rods).
---   * The Hazmat Suit: GT's (IC2's) four hazmat pieces as one armor. IC2's recipes of the pieces are not in GT's dump:
---     the suit takes their rubber (24 rubber sheets) with 4 polyethylene sheets and a glass for the visor, by hand or
---     in an LV assembler, after the technology that has them. Gregtorio's late armors (power armor and up) protect
---     too.
--- The mod data `fork-radiation` (data-final-fixes, prototypes/fork-radiation.lua) names the items and the armors.
--------------------------------------------------------------------------------

FORK_RADIATION = { on = settings.startup["gregtorio-continued-radiation"].value,
	armors = { "hazmat-suit", "power-armor", "power-armor-mk2", "mech-armor" } }
if not FORK_RADIATION.on then return end

local OC = FORK_ORE_CHAIN

data:extend({ {
	type = "armor", name = "hazmat-suit", icon = "__gregtorio-continued__/graphics/icons/hazmat-suit.png", icon_size = 32,
	subgroup = "subgroup-tool-recipes", order = "t[radiation]-hazmat-suit", stack_size = 1, infinite = true,
} })

--- the technologies of every recipe that makes an item (as 170); nil: from the start
local function item_techs(name)
	local effects = {}
	for tn, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" then effects[e.recipe] = effects[e.recipe] or {}; table.insert(effects[e.recipe], tn) end
		end
	end
	local out = {}
	for rname, r in pairs(data.raw.recipe) do
		if not r.hidden and not rname:match("recycling") then
			for _, res in pairs(r.results or {}) do
				if res.name == name then
					if r.enabled ~= false then return nil end
					for _, tn in pairs(effects[rname] or {}) do out[#out + 1] = tn end
				end
			end
		end
	end
	return out
end
local INGREDIENTS = { { "rubber-sheet", 24 }, { "polyethylene-sheet", 4 }, { "glass", 1 } }
local ing = {}
for _, i in pairs(INGREDIENTS) do ing[#ing + 1] = { type = "item", name = i[1], amount = i[2] } end
create_recipe{ recipe_name = "hazmat-suit", category = "crafting-or-assembling-recipes", energy_required = 30,
	ingredients = ing, results = { { type = "item", name = "hazmat-suit", amount = 1 } }, main_product = "hazmat-suit" }
local groups = {}
for _, i in pairs(INGREDIENTS) do groups[#groups + 1] = item_techs(i[1]) end
if not OC.unlock_after("hazmat-suit", groups) then log("FORK-RADIATION: no technology for hazmat-suit") end
