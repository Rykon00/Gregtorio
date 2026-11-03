--------------------------------------------------------------------------------
--- FORK: MAINTENANCE (issue #618, the maintainer's decisions of 2026-10-27 and 2026-10-30; startup setting
--- gregtorio-continued-maintenance, default off)
--- GT's multiblocks get maintenance problems while they run (MTEMultiBlockBase.java:1522-1525) that their maintenance hatch
--- or GT's duct tape fixes. Here, with the setting on, every crafting multiblock (an assembling machine or furnace whose
--- item is in a `*multiblocks` subgroup; generators have no module slots in Factorio) gets one more module slot of the
--- category `maintenance`, and scripts/fork-maintenance.lua uses up one kit from it per 2 hours the machine runs (a new
--- machine starts with one kit's time); without a kit it stops with the status "Needs maintenance".
---   * Maintenance Kit: the crafting table recipe of #612's tool charges as GT's six maintenance tools: wrench,
---     screwdriver and hammer charges; GT's soft mallet, soldering iron and crowbar have no #612 tool, so a rubber sheet,
---     soldering alloy dust and an iron stick stand in.
---   * GT's Duct Tape (BrainTech Aerospace Advanced Reinforced Duct Tape FAL-84, the dump's assembler recipes) does the
---     same: 2 from a polybenzimidazole sheet, raw carbon mesh and 20 advanced glue (LV), 16 with 10 super glue (LV),
---     1 from 3 rubber sheets, 2 SBR sheets or 1 silicone rubber sheet with raw carbon mesh and GT's refined glue (MV, HV,
---     EV; Gregtorio's glue stands in for refined glue).
--- The slots: prototypes/fork-maintenance.lua (data-final-fixes.lua). Loaded after 170, before 157 (recycling), 168 and the
--- crafting menu.
--------------------------------------------------------------------------------

FORK_MAINTENANCE = { on = settings.startup["gregtorio-continued-maintenance"].value, machines = {},
	kits = { "maintenance-kit", "duct-tape" } }
if not FORK_MAINTENANCE.on then return end

local OC = FORK_ORE_CHAIN
local ICON = "__gregtorio-continued__/graphics/icons/"

--- (the module category itself: prototypes/fork-maintenance.lua, after 150 gave the machines that take every module
--- every category by name)
for _, name in pairs(FORK_MAINTENANCE.kits) do
	data:extend({ {
		type = "module", name = name, icon = ICON .. name .. ".png", icon_size = 32, subgroup = "subgroup-tool-recipes",
		order = "t[maintenance]-" .. name, stack_size = 64, category = "maintenance", tier = 1, effect = {},
	} })
end

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
--- `late`: { technology, prerequisite } when no technology comes after every input (the SBR sheet's technology is a leaf
--- of the tree): unlocked there, with the input's technology made its prerequisite
local function recipe(name, category, seconds, ingredients, result, amount, late)
	local ing = {}
	for _, i in pairs(ingredients) do
		ing[#ing + 1] = { type = data.raw.fluid[i[1]] and "fluid" or "item", name = i[1], amount = i[2] }
	end
	create_recipe{ recipe_name = name, category = category, energy_required = seconds, ingredients = ing,
		results = { { type = "item", name = result, amount = amount } }, main_product = result }
	local groups = {}
	for _, i in pairs(ingredients) do groups[#groups + 1] = item_techs(i[1]) end
	if late then
		fork_add_unlock(late[1], name)
		table.insert(data.raw.technology[late[1]].prerequisites, late[2])
	elseif not OC.unlock_after(name, groups) then
		log("FORK-MAINTENANCE: no technology for " .. name)
	end
end
recipe("maintenance-kit", "crafting-or-assembling-recipes", 2, { { "wrench-usage", 1 }, { "screwdriver-usage", 1 },
	{ "hammer-usage", 1 }, { "rubber-sheet", 1 }, { "soldering-alloy-dust", 1 }, { "iron-stick", 1 } }, "maintenance-kit", 1)
recipe("duct-tape-from-advanced-glue", "lv-assembling-machine-recipes", 6 * LV_SPEED,
	{ { "polybenzimidazole-sheet", 1 }, { "raw-carbon-mesh", 1 }, { "advanced-glue", 20 } }, "duct-tape", 2)
recipe("duct-tape-from-super-glue", "lv-assembling-machine-recipes", 6 * LV_SPEED,
	{ { "polybenzimidazole-sheet", 1 }, { "raw-carbon-mesh", 1 }, { "super-glue", 10 } }, "duct-tape", 16)
recipe("duct-tape-from-rubber", "mv-assembling-machine-recipes", 5 * MV_SPEED,
	{ { "rubber-sheet", 3 }, { "raw-carbon-mesh", 3 }, { "glue", 30 } }, "duct-tape", 1)
recipe("duct-tape-from-styrene-butadiene-rubber", "hv-assembling-machine-recipes", 5 * HV_SPEED,
	{ { "styrene-butadiene-rubber-sheet", 2 }, { "raw-carbon-mesh", 2 }, { "glue", 20 } }, "duct-tape", 1,
	{ "nanoprocessors", "styrene-butadiene-rubber" })
recipe("duct-tape-from-silicone-rubber", "ev-assembling-machine-recipes", 5 * EV_SPEED,
	{ { "silicone-rubber-sheet", 1 }, { "raw-carbon-mesh", 1 }, { "glue", 10 } }, "duct-tape", 1)

