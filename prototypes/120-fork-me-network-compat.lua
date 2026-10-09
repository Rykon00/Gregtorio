--------------------------------------------------------------------------------
--- FORK: ME NETWORK ON GREGTORIO'S TIERS (issue #83, docs/SPLIT.md)
---
--- The ME network (issues #68, #38, #80) is the mod me-network since issue #83: its entities, items, technologies,
--- runtime and graphics live there, with vanilla recipes and vanilla science. This file puts it back on Gregtorio's
--- tiers through me-network's data-stage API (ME_NETWORK, its docs/API.md), so a Gregtorio game is what it was:
---   * the GT recipes of every ME item (the create_item calls of 13-mv-age-item.lua and of the old 120-122, recipe
---     only: the items are me-network's), the subgroups of the storage components and the housing;
---   * the standalone 1k component recipe removed (Gregtorio has the -lv and -nand recipes of upstream);
---   * the ME technologies with Gregtorio's prerequisites, science and unlocks;
---   * the Molecular Assembler built from the HV assembling machine (the LV to EV assembling categories, 6x speed).
--- Issue #214: the recipes follow GregTech New Horizons' AE2 (NewHorizonsCoreMod scripts/ScriptAppliedEnergistics2.java,
--- "SAE2" below, and gthandler/recipes/AssemblerRecipes.java, "ASM"; AE2-Unofficial's GTNHRecipes for its own cards)
--- where GTNH has the item, with Gregtorio's stand-in where it lacks the GT or AE2 part. The ME network starts two tiers
--- earlier here than in GTNH (HV instead of EV), so the blocks of the first technologies keep aluminium where GTNH takes
--- titanium; the machine category of a recipe stays what it was.
--- The one-time hand-over of the ME state of older saves is scripts/fork-me-handover.lua.
--------------------------------------------------------------------------------

local ME = ME_NETWORK

--- Issue #214: every recipe of me-network (ME_NETWORK.recipes) gets its Gregtorio recipe in this file. FORK_ME_RECIPES
--- holds the names this file gives a recipe (recipe_of and the crafting blocks fill it); a recipe that keeps me-network's
--- standalone ingredients on purpose goes into the allow-list FORK_ME_RECIPES_STANDALONE with its reason. devcheck fails
--- for a recipe of ME_NETWORK.recipes in neither (a new me-network item without a GT recipe) and for a stale entry.
FORK_ME_RECIPES = {}
FORK_ME_RECIPES_STANDALONE = {
}

--- the recipe Gregtorio's create_item made for an item (03-helper-functions-module.lua), without touching the item
local function recipe_of(def)
	FORK_ME_RECIPES[def.recipe_name or def.name] = true
	local category = def.category or "crafting-or-assembling-recipes"
	create_recipe{
		recipe_name = def.recipe_name or def.name,
		category = category,
		subgroup = def.subgroup or ("subgroup-" .. category),
		order = def.order or ("a[" .. category .. "]-[" .. def.name .. "]"),
		energy_required = def.energy_required or 1,
		ingredients = def.ingredients,
		results = def.results or { { type = "item", name = def.name, amount = 1 } },
		main_product = def.main_product or def.name,
	}
end

--- the items of the upstream file 13: their recipe, and the subgroup and order create_item gave the item
local function upstream_item(def)
	recipe_of(def)
	local category = def.category or "crafting-or-assembling-recipes"
	local item = data.raw.item[def.name]
	item.subgroup = def.subgroup or ("subgroup-" .. category)
	item.order = def.order or ("a[" .. category .. "]-[" .. def.name .. "]")
end

--- what the old 120 did to the upstream items afterwards
local function move_to(subgroup, item_name, order)
	local item = data.raw.item[item_name]
	if item then item.subgroup = subgroup; item.order = order end
	local recipe = data.raw.recipe[item_name]
	if recipe then recipe.subgroup = subgroup; recipe.order = order end
end

--- item ingredients from a flat list: name, amount, name, amount ...
local function I(list)
	local t = {}
	for i = 1, #list, 2 do t[#t + 1] = { type = "item", name = list[i], amount = list[i + 1] } end
	return t
end



--------------------------------------------------------------------------------
--- UPSTREAM ITEMS (from 13-mv-age-item.lua; issue #214: GTNH's recipes)
--------------------------------------------------------------------------------

ME.remove_recipe("me-1k-storage-component")

--- GTNH's housing (ASM:4569-4577: a glass pane, a certus quartz plate, an aluminium plate, 2 stainless steel plates) is
--- not used: upstream's microverse data items (Overworld Data and the others, 16 housings in a microverse module) need
--- the housing with Overworld Data, before aluminium and stainless steel. Upstream's recipe
upstream_item{
	name = "basic-storage-housing",
	category = "lv-assembling-machine-recipes",
	ingredients = I{ "steel-plate", 4, "steel-screw", 4, "glass", 1 },
}

--- GTNH (SAE2:2225-2230): 3 quartz fiber, 2 fluix dust -> 3, MV, 5 s
upstream_item{
	name = "fluix-cable",
	category = "mv-assembling-machine-recipes",
	energy_required = 5 * MV_SPEED,
	ingredients = I{ "quartz-fiber", 3, "fluix-dust", 2 },
	results = { { type = "item", name = "fluix-cable", amount = 3 } },
}

--- GTNH (ASM:4754-4763): 4 titanium plates, 2 fluix cables, a formation and an annihilation core, the EV machine
--- casing; here aluminium and the MV casing (the network's tier)
upstream_item{
	name = "me-interface",
	ingredients = I{ "mv-machine-casing", 1, "aluminium-plate", 4, "fluix-cable", 2, "formation-core", 1,
		"annihilation-core", 1 },
}

--- GTNH (SAE2:730-740, ASM:4744-4753): 4 titanium plates, an engineering processor, 2 fluix cables, the ME Chest, an
--- HV circuit; here aluminium. GTNH keeps the ME Chest in it (AE2's modern drive has none: me-network issue #231)
upstream_item{
	name = "me-drive",
	ingredients = I{ "aluminium-plate", 4, "engineering-processor", 1, "fluix-cable", 2, "me-chest", 1,
		"processing-unit", 1 },
}

--- issue #213: GTNH (SAE2:719-729, ASM:4734-4742): 4 stainless steel plates, 2 fluix cables, 2 MV circuits and a
--- silver chest (Iron Chests; Gregtorio's nearest is the steel chest, which is made like the gold chest). GTNH's chest
--- has no terminal in it: the two MV circuits pay for the screen of its own
upstream_item{
	name = "me-chest",
	ingredients = I{ "stainless-steel-plate", 4, "fluix-cable", 2, "advanced-circuit", 2, "steel-chest", 1 },
}

--- GTNH (SAE2:686-696, ASM:4632-4640): 4 titanium plates, 2 HV circuits, 2 engineering processors, a fluix block;
--- here aluminium
upstream_item{
	name = "me-controller",
	ingredients = I{ "aluminium-plate", 4, "processing-unit", 2, "engineering-processor", 2, "fluix-block", 1 },
}

--- GTNH (SAE2:2257-2266): 4 nether quartz rods, a quartzite screw, an illuminated panel, an MV circuit, a certus quartz
--- plate (Gregtorio has no quartzite screw, no illuminated panel and no certus plate: the certus quartz screw, the
--- computer monitor of the ME Terminal and the gem)
upstream_item{
	name = "me-terminal",
	ingredients = I{ "nether-quartz-rod", 4, "certus-quartz-screw", 1, "computer-monitor", 1, "advanced-circuit", 1,
		"certus-quartz", 1 },
}

--- GTNH's storage components (circuit assembler, 72 soldering alloy, 10 s; CAR = CircuitAssemblerRecipes.java): 1k from
--- 2 ULV circuits, 2 charged certus quartz dust (certus quartz dust here: the 1k component comes with Overworld Data,
--- before the charged certus of Applied Energistics Crystals), a logic processor and a basic board (CAR:844-853, LV);
--- 4k from 4 LV and 16 ULV circuits (Gregtorio's NAND chips), a logic processor and a coated board (LV); 16k from 4 MV
--- and 16 LV circuits, an engineering processor and a phenolic board (MV); 64k 4 HV, 16 MV, an engineering processor
--- and an epoxy board (HV); 256k 4 EV, 16 HV, an engineering processor and a fiberglass board (EV, SAE2:327-335). The
--- boards are Gregtorio's printed boards (resin, phenolic, phenolic, epoxy, fiber-reinforced).
local function component(def)
	def.energy_required = 10 * ({ lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED })[def.tier]
	def.category = def.tier .. "-circuit-assembler-recipes"
	def.ingredients[#def.ingredients + 1] = { type = "fluid", name = "soldering-alloy", amount = 7.2 }
	def.results = { { type = "item", name = def.result or def.name, amount = 1 } }
	return def
end
upstream_item(component{
	name = "me-1k-storage-component",
	recipe_name = "me-1k-storage-component-lv",
	tier = "lv",
	ingredients = I{ "resin-printed-circuit-board", 1, "certus-quartz-dust", 2, "electronic-circuit", 2,
		"logic-processor", 1 },
})
--- Gregtorio's own 1k recipe with GTNH's ULV circuits (NAND chips)
create_recipe(component{
	recipe_name = "me-1k-storage-component-nand",
	result = "me-1k-storage-component",
	tier = "lv",
	ingredients = I{ "resin-printed-circuit-board", 1, "certus-quartz-dust", 2, "nand-chip", 2,
		"logic-processor", 1 },
})
upstream_item(component{
	name = "me-4k-storage-component",
	tier = "lv",
	ingredients = I{ "phenolic-printed-circuit-board", 1, "nand-chip", 16, "electronic-circuit", 4, "logic-processor", 1 },
})
upstream_item(component{
	name = "me-16k-storage-component",
	tier = "mv",
	ingredients = I{ "phenolic-printed-circuit-board", 1, "electronic-circuit", 16, "advanced-circuit", 4,
		"engineering-processor", 1 },
})
upstream_item(component{
	name = "me-64k-storage-component",
	tier = "hv",
	ingredients = I{ "epoxy-printed-circuit-board", 1, "advanced-circuit", 16, "processing-unit", 4,
		"engineering-processor", 1 },
})
upstream_item(component{
	name = "me-256k-storage-component",
	tier = "ev",
	ingredients = I{ "fiber-reinforced-printed-circuit-board", 1, "processing-unit", 16, "ev-circuit", 4,
		"engineering-processor", 1 },
})

move_to("fork-me-network", "fluix-cable", "a0")
move_to("fork-me-network", "me-controller", "a")
move_to("fork-me-network", "me-interface", "b")
move_to("fork-me-network", "me-terminal", "c")
move_to("fork-me-network", "me-chest", "d")
move_to("fork-me-drives", "me-drive", "a")



--------------------------------------------------------------------------------
--- THE RECIPES OF THE OLD 120 (cells, buses, underground cable, storage bus)
--------------------------------------------------------------------------------

local CELL_CATEGORY = { ["1k"] = "lv", ["4k"] = "lv", ["16k"] = "mv", ["64k"] = "hv", ["256k"] = "ev" }
for i, tier in ipairs({ "1k", "4k", "16k", "64k", "256k" }) do
	local cell = "me-" .. tier .. "-storage-cell"
	recipe_of{
		name = cell,
		category = CELL_CATEGORY[tier] .. "-assembling-machine-recipes",
		subgroup = "fork-me-cells",
		order = string.format("%02d", i),
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "me-" .. tier .. "-storage-component", amount = 1 },
			{ type = "item", name = "basic-storage-housing", amount = 1 },
		},
	}
	data.raw.recipe[cell].auto_recycle = false         -- a recycler would void the contents
end

--- GTNH (SAE2:2239-2256): a titanium plate, 2 certus quartz screws, an annihilation (import) or formation core (export),
--- 2 nether quartz plates, an LV piston, MV, 10 s; here an aluminium plate
for _, bus in pairs({
	{ name = "me-import-bus", core = "annihilation-core", order = "b2" },
	{ name = "me-export-bus", core = "formation-core", order = "b3" },
}) do
	recipe_of{
		name = bus.name,
		category = "mv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = bus.order,
		energy_required = 10 * MV_SPEED,
		ingredients = I{ "aluminium-plate", 1, "certus-quartz-screw", 2, bus.core, 1, "nether-quartz-plate", 2,
			"lv-piston", 1 },
	}
end

--- (not in AE2 or GTNH: Gregtorio's own)
recipe_of{
	name = "me-underground-cable",
	category = "mv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "a1",
	energy_required = 5 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "fluix-cable", amount = 8 },
		{ type = "item", name = "aluminium-plate", amount = 2 },
	},
	results = { { type = "item", name = "me-underground-cable", amount = 2 } },
}

recipe_of{
	name = "me-storage-bus",
	category = "mv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "b4",
	energy_required = 10 * MV_SPEED,
	--- GTNH (SAE2:2231-2238): a chest, 2 certus quartz screws, an ME Interface, 2 nether quartz plates, an LV piston,
	--- MV, 10 s
	ingredients = I{ "wooden-chest", 1, "certus-quartz-screw", 2, "me-interface", 1, "nether-quartz-plate", 2,
		"lv-piston", 1 },
}



--------------------------------------------------------------------------------
--- THE RECIPES OF THE OLD 121 (autocrafting) AND THE MOLECULAR ASSEMBLER
--------------------------------------------------------------------------------

--- AE2-Unofficial has no pattern provider (GTNH's ME Interface holds the patterns): Gregtorio's recipe, an ME Interface
--- with the HV parts of an assembler's control
recipe_of{
	name = "me-pattern-provider",
	category = "hv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "e",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "me-interface", amount = 1 },
		{ type = "item", name = "engineering-processor", amount = 2 },
		{ type = "item", name = "fluix-cable", amount = 4 },
		{ type = "item", name = "hv-emitter", amount = 1 },
	},
}

--- issue #80: a cheap blank pattern (LV assembler); issue #214: GTNH's (SAE2:1272-1282): 2 quartz glass, 3 glowstone
--- plates, a certus quartz, 3 aluminium plates (Gregtorio has no quartz glass and no glowstone plate: glass and
--- glowstone dust)
recipe_of{
	name = "me-blank-pattern",
	category = "lv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "e1",
	energy_required = 5 * LV_SPEED,
	ingredients = I{ "glass", 2, "glowstone-dust", 3, "certus-quartz", 1, "aluminium-plate", 3 },
}

--- issue #159 (me-network 0.5.0, its issue #130): the ME Pattern Terminal, GTNH's recipe (NewHorizonsCoreMod
--- scripts/ScriptAppliedEnergistics2.java, "ME Pattern Terminal"): an ME Terminal, 2 certus quartz screws, a blank
--- pattern, 2 nether quartz plates and an engineering processor in the MV assembler, 10 s. Gregtorio had no nether
--- quartz plate: GT's bender recipe of a gem (OP/ProcessingGem.java:117-125: 1 gem -> 1 plate, mass x 2 ticks, nether
--- quartz 98 -> 9.8 s, 24 EU/t)
create_item{
	name = "nether-quartz-plate",
	category = "lv-bending-machine-recipes",
	energy_required = 9.8 * LV_SPEED,
	ingredients = { { type = "item", name = "nether-quartz", amount = 1 } },
}
recipe_of{
	name = "me-pattern-terminal",
	category = "mv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "e0",
	energy_required = 10 * MV_SPEED,
	ingredients = I{ "me-terminal", 1, "certus-quartz-screw", 2, "me-blank-pattern", 1, "nether-quartz-plate", 2,
		"engineering-processor", 1 },
}

--- GTNH (ASM:4800-4809): the EV assembler, 4 titanium plates, a formation and an annihilation core, 288 molten glass
--- (2 glass here: the HV assembler has no fluid input), HV, 5 s
recipe_of{
	name = "me-molecular-assembler",
	category = "hv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "f",
	energy_required = 5 * HV_SPEED,
	ingredients = I{ "ev-assembling-machine", 1, "titanium-plate", 4, "formation-core", 1, "annihilation-core", 1,
		"glass", 2 },
}

--- GTNH's Level Maintainer is AE2 Fluid Crafting's (SFC:574-585: 4 niobium-titanium plates, 2 Crafting Cards, an
--- annihilation core, an ME Interface, a fluid diamond core); me-network has no Crafting Card and the cards come one tier
--- later here: Gregtorio's recipe, an ME Interface with an EV sensor
recipe_of{
	name = "me-level-maintainer",
	category = "ev-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "g4",
	energy_required = 10 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "me-interface", amount = 1 },
		{ type = "item", name = "ev-sensor", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "fluix-cable", amount = 4 },
	},
}

--- (not in AE2 or GTNH: Gregtorio's own)
recipe_of{
	name = "me-circuit-interface",
	category = "hv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "g5",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "me-interface", amount = 1 },
		{ type = "item", name = "constant-combinator", amount = 1 },
		{ type = "item", name = "ev-sensor", amount = 1 },
		{ type = "item", name = "engineering-processor", amount = 2 },
		{ type = "item", name = "fluix-cable", amount = 4 },
	},
}

--- item recipes only (no fluid boxes), crafts like an EV assembler
ME.make_molecular_assembler{
	base = "hv-assembling-machine",
	crafting_categories = {
		"crafting-or-assembling-recipes", "crafting-table-recipes",
		"lv-assembling-machine-recipes", "mv-assembling-machine-recipes",
		"hv-assembling-machine-recipes", "ev-assembling-machine-recipes",
	},
	crafting_speed = 6,
	energy_usage = EU12_HV,
}



--------------------------------------------------------------------------------
--- THE CRAFTING BLOCKS OF THE MULTIBLOCK CRAFTING CPUS (me-network 0.3.0, its issue #6; Gregtorio issue #111)
--- GregTech New Horizons' AE2 recipes (NewHorizonsCoreMod, scripts/ScriptAppliedEnergistics2.java): the crafting unit
--- from titanium, the logic, calculation and engineering processor and two LV circuits (GTNH makes it at the crafting
--- table; here the HV assembler of its crafting storages), a crafting storage from a crafting unit and the storage
--- component of its size (HV assembler, 20 s; 256k: EV), the co-processing unit from a crafting unit and two
--- engineering processors (HV, 5 s), the monitor from a crafting unit and an ME Storage Monitor (MV, 20 s; Gregtorio
--- has no storage monitor, its nearest part is the computer monitor of the ME Terminal). The three single-entity CPUs
--- are legacy blocks without a recipe since me-network 0.3.0. Guarded by the item: me-network 0.2.0 has no crafting
--- blocks (the release of issue #101 raises the dependency, and the guard can go then).
--------------------------------------------------------------------------------

local HAS_CRAFTING_BLOCKS = data.raw.item["me-crafting-unit"] ~= nil
if HAS_CRAFTING_BLOCKS then
	--- with me-network's subgroup and order of the item (fork-me-crafting-cpu, h0 to h7)
	local function block(name, category, energy_required, ingredients)
		local item = data.raw.item[name]
		FORK_ME_RECIPES[name] = true
		ME.replace_recipe{
			name = name,
			category = category,
			enabled = false,
			energy_required = energy_required,
			ingredients = ingredients,
			results = { { type = "item", name = name, amount = 1 } },
			hide_from_player_crafting = true,
			subgroup = item.subgroup,
			order = item.order,
		}
	end

	block("me-crafting-unit", "hv-assembling-machine-recipes", 10 * HV_SPEED, I{ "titanium-plate", 4,
		"logic-processor", 1, "calculation-processor", 1, "engineering-processor", 1, "electronic-circuit", 2 })
	for _, size in ipairs({ "1k", "4k", "16k", "64k" }) do
		block("me-" .. size .. "-crafting-storage", "hv-assembling-machine-recipes", 20 * HV_SPEED,
			I{ "me-crafting-unit", 1, "me-" .. size .. "-storage-component", 1 })
	end
	block("me-256k-crafting-storage", "ev-assembling-machine-recipes", 20 * EV_SPEED,
		I{ "me-crafting-unit", 1, "me-256k-storage-component", 1 })
	block("me-crafting-co-processing-unit", "hv-assembling-machine-recipes", 5 * HV_SPEED,
		I{ "me-crafting-unit", 1, "engineering-processor", 2 })
	block("me-crafting-monitor", "mv-assembling-machine-recipes", 20 * MV_SPEED,
		I{ "me-crafting-unit", 1, "computer-monitor", 1 })
end



--------------------------------------------------------------------------------
--- THE RECIPES OF THE OLD 122 (fluids). Since me-network 0.2.0 (its issue #3) the ME Interface and the ME Import,
--- Export and Storage Bus handle fluids themselves; the ME Fluid Interface and the fluid buses have no recipe any more.
--------------------------------------------------------------------------------

local FLUID_CELLS = {
	{ tier = "1k",   pump = "lv-pump", cell_cat = "lv-assembling-machine-recipes" },
	{ tier = "4k",   pump = "lv-pump", cell_cat = "lv-assembling-machine-recipes" },
	{ tier = "16k",  pump = "mv-pump", cell_cat = "mv-assembling-machine-recipes" },
	{ tier = "64k",  pump = "hv-pump", cell_cat = "hv-assembling-machine-recipes" },
	{ tier = "256k", pump = "ev-pump", cell_cat = "ev-assembling-machine-recipes" },
}
for i, c in ipairs(FLUID_CELLS) do
	local cell = "me-" .. c.tier .. "-fluid-storage-cell"
	recipe_of{
		name = cell,
		category = c.cell_cat,
		subgroup = "fork-me-fluid-cells",
		order = string.format("%02d", i),
		energy_required = 5,
		ingredients = {
			{ type = "item", name = "me-" .. c.tier .. "-storage-component", amount = 1 },
			{ type = "item", name = "basic-storage-housing", amount = 1 },
			{ type = "item", name = c.pump, amount = 1 },
		},
	}
	data.raw.recipe[cell].auto_recycle = false         -- a recycler would void the fluid
end




--------------------------------------------------------------------------------
--- THE UPGRADE CARDS AND THE ME CELL WORKBENCH (me-network 0.3.0, its issue #17; Gregtorio issue #95)
--- GregTech New Horizons' AE2 recipes (NewHorizonsCoreMod, scripts/ScriptAppliedEnergistics2.java). Gregtorio's
--- upstream advanced-card (13-mv-age-item.lua) is GTNH's Advanced Card already (2 platinum, 3 titanium, 1 red alloy,
--- 1 calculation processor). Issue #121: there is one family of cards, all of them me-network's: me-advanced-card gets
--- that recipe (on me-upgrade-cards with the cards made from it), and Gregtorio's own advanced-card is deleted (saves:
--- `migrations/`). Issue #195: me-network 0.5.0 made the Acceleration Card a real card (its issue #110, a module of the
--- ME Molecular Assembler): me-acceleration-card gets GTNH's recipe (shapeless: advanced card, engineering and logic
--- processor, fluix crystal; the recipe of Gregtorio's own card), and Gregtorio's acceleration-card is deleted (saves:
--- `migrations/2026-10-07-issue-195-acceleration-card.json`). Guarded by the item: with me-network 0.2.0 there are no
--- cards (the dependency is >= 0.5.0 since issue #195, and the guard can go).
--------------------------------------------------------------------------------

local HAS_CARDS = data.raw.item["me-basic-card"] ~= nil
if HAS_CARDS then
	--- (a card of a later me-network than the one loaded is skipped)
	local function card(name, order, ingredients)
		if not data.raw.item[name] and not data.raw.module[name] then return end
		recipe_of{ name = name, subgroup = "fork-me-cards", order = order, ingredients = ingredients }
	end

	--- GTNH: 2 platinum, 3 titanium, 1 red alloy, 1 calculation processor (one card, as GTNH's recipe)
	card("me-advanced-card", "b", I{ "platinum-plate", 2, "titanium-plate", 3, "red-alloy-plate", 1, "calculation-processor", 1 })
	--- Gregtorio's own Advanced Card and Acceleration Card are gone (issues #121, #195)
	data.raw.item["advanced-card"] = nil
	data.raw.recipe["advanced-card"] = nil
	data.raw.item["acceleration-card"] = nil
	data.raw.recipe["acceleration-card"] = nil
	--- GTNH: advanced card, engineering processor, logic processor, fluix crystal
	card("me-acceleration-card", "h",
		I{ "me-advanced-card", 1, "engineering-processor", 1, "logic-processor", 1, "fluix-crystal", 1 })

	--- GTNH: gold, aluminium, red alloy, calculation processor (the Advanced Card's pattern with gold and aluminium)
	card("me-basic-card", "a", I{ "gold-plate", 2, "aluminium-plate", 3, "red-alloy-plate", 1, "calculation-processor", 1 })
	--- GTNH: basic card, two 1k storage components, charged certus quartz
	card("me-capacity-card", "c",
		I{ "me-basic-card", 1, "me-1k-storage-component", 2, "charged-certus-quartz", 1 })
	--- GTNH: basic card, two calculation processors, an ME Void Storage Cell (a cell without a storage component;
	--- me-network has none, so its shell, the storage housing)
	card("me-overflow-destruction-card", "d",
		I{ "me-basic-card", 1, "calculation-processor", 2, "basic-storage-housing", 1 })
	--- GTNH: advanced card, engineering, logic and calculation processor
	card("me-fuzzy-card", "e",
		I{ "me-advanced-card", 1, "engineering-processor", 1, "logic-processor", 1, "calculation-processor", 1 })
	--- GTNH: advanced card, two IC2 redstone inverter upgrades (decider combinators here), calculation processor
	card("me-inverter-card", "f", I{ "me-advanced-card", 1, "decider-combinator", 2, "calculation-processor", 1 })
	--- GTNH: advanced card, engineering and logic processor, an EV item distributor (the turbo splitter here)
	card("me-equal-distribution-card", "g",
		I{ "me-advanced-card", 1, "engineering-processor", 1, "logic-processor", 1, "turbo-splitter", 1 })
	--- issue #211 (me-network 0.5.3): GTNH's Pattern Capacity Card (AE2-Unofficial GTNHRecipes materials/cards.recipe,
	--- ASM:4866-4875): advanced card, two 16k storage components, an ME Interface
	card("me-pattern-capacity-card", "e2",
		I{ "me-advanced-card", 1, "me-16k-storage-component", 2, "me-interface", 1 })
	--- issue #211: the ME Interface Capacity Card has no GTNH counterpart (GTNH's interface takes patterns, not more
	--- config rows). By its nearest relative, the Pattern Capacity Card (more slots for the same block), one storage
	--- tier lower: a config row asks for less than a pattern does
	card("me-interface-capacity-card", "e3",
		I{ "me-advanced-card", 1, "me-4k-storage-component", 2, "me-interface", 1 })
	--- issue #211: GTNH's Sticky Card (SAE2:1290-1296): basic card, two 1k storage components, a slimeball (Gregtorio
	--- has no slimeball: sticky resin, GT's other sticky ball)
	card("me-sticky-card", "e4", I{ "me-basic-card", 1, "me-1k-storage-component", 2, "sticky-resin", 1 })

	--- GTNH: computer screen cover, two titanium screws (stainless steel here: Gregtorio has no titanium screw),
	--- crafting table, two titanium plates, calculation processor
	recipe_of{
		name = "me-cell-workbench",
		subgroup = "fork-me-cards",
		order = "z",
		ingredients = I{ "computer-monitor", 1, "stainless-steel-screw", 2, "crafting-table", 1, "titanium-plate", 2,
			"calculation-processor", 1 },
	}
end



--------------------------------------------------------------------------------
--- THE WIRELESS TERMINAL (me-network 0.5.3, its issues #153, #205 to #211; Gregtorio issue #212)
--- GTNH's AE2 recipes. Gregtorio has no Wireless Receiver: its stand-in is the HV sensor (GT's sensor is an ender eye on
--- an HV circuit and plates, as the receiver is an ender eye rod on an HV circuit and certus plates); no titanium screw:
--- stainless steel, as for the Cell Workbench; no AE2 energy cell and no GT battery above the battery: 4 batteries for
--- the Dense Energy Cell, as in me-network's own recipe. Guarded by the technology (me-network before 0.5.3 has none).
--------------------------------------------------------------------------------

local HAS_WIRELESS = data.raw.technology["me-wireless"] ~= nil
if HAS_WIRELESS then
	--- with me-network's subgroup and order of the item (fork-me-wireless, a to e)
	local function wireless(name, category, energy_required, ingredients)
		local item = data.raw.item[name] or data.raw["item-with-tags"][name]
		recipe_of{ name = name, category = category, energy_required = energy_required, subgroup = item.subgroup,
			order = item.order, ingredients = ingredients }
	end

	--- GTNH (ASM:4890-4901): a calculation processor, a Wireless Receiver, a fluix cable, 2 titanium screws, HV, 3 s
	wireless("me-wireless-access-point", "hv-assembling-machine-recipes", 3 * HV_SPEED,
		I{ "calculation-processor", 1, "hv-sensor", 1, "fluix-cable", 1, "stainless-steel-screw", 2 })
	--- GTNH (SAE2:1339-1350, crafting table): fluix dust, a certus quartz, an ender pearl plate, 2 titanium plates, an
	--- aluminium plate (Gregtorio has no ender pearl plate: the pearl)
	wireless("me-wireless-booster", nil, nil,
		I{ "fluix-dust", 1, "certus-quartz", 1, "ender-pearl", 1, "titanium-plate", 2, "aluminium-plate", 1 })
	--- GTNH (SAE2:1239-1249, crafting table): 2 Wireless Receivers, an ME Terminal, 4 nether quartz plates, an
	--- engineering processor, a Dense Energy Cell
	wireless("me-wireless-terminal", nil, nil, I{ "hv-sensor", 2, "me-terminal", 1, "nether-quartz-plate", 4,
		"engineering-processor", 1, "battery", 4 })
	--- GTNH (SAE2:774-784, crafting table): 4 titanium plates, 2 fluix crystals, 2 copper cables, the EV electrolyzer
	wireless("me-charger", nil, nil,
		I{ "titanium-plate", 4, "fluix-crystal", 2, "copper-cable", 2, "ev-electrolyzer", 1 })
	--- The ME Wireless Terminal Module has no GTNH counterpart (GTNH has no armour module of the terminal). By its
	--- nearest relative, the Wireless Terminal it is made from: that terminal, a second Dense Energy Cell (the grid's
	--- buffer) and 2 engineering processors (me-network's own recipe: the terminal, 10 batteries, 2 processing units)
	wireless("me-wireless-module", nil, nil, I{ "me-wireless-terminal", 1, "battery", 4, "engineering-processor", 2 })
end



--------------------------------------------------------------------------------
--- TECHNOLOGIES (Gregtorio's tiers and science packs)
--------------------------------------------------------------------------------

local PACKS = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
	"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack" }
--- the first n packs; the amounts of the old 120 and 122 (SP06 down) or of the old 121 (SP07 down)
local function sci(n, amounts)
	local out = {}
	for i = 1, n do
		out[#out + 1] = { PACKS[i], amounts[#amounts - n + i] }
	end
	return out
end
local SIX = { SP06, SP05, SP04, SP03, SP02, SP01 }
local SEVEN = { SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
local function tech(name, prerequisites, packs, count, recipes, amounts)
	ME.set_technology(name, { prerequisites = prerequisites, recipes = recipes,
		unit = { count = count, ingredients = sci(packs, amounts or SIX), time = 30 } })
end

--- MV: basic cells, terminal, buses (cable, controller and interface come with Applied Energistics Components); issue
--- #213: the ME Chest (a block of its own since me-network 0.5.3) and the ME Drive made from it come with the terminal
--- (logistic-system unlocked them before; the chest needs stainless steel); the nether quartz plate of the buses (GTNH's
--- recipe, issue #214)
tech("me-network", { "logistic-system", "stainless-steel" }, 3, 400, {
	"me-terminal", "computer-monitor", "certus-quartz-bolt", "certus-quartz-screw", "me-chest", "me-drive",
	"me-1k-storage-cell", "me-4k-storage-cell", "me-16k-storage-cell", "nether-quartz-plate", "me-import-bus",
	"me-export-bus", "me-underground-cable", "me-storage-bus",
})
--- EV: 64k (the component needs epoxy boards)
tech("me-storage-64k", { "me-network", "nanoprocessors", "advanced-hv-machines" }, 5, 800,
	{ "me-64k-storage-component", "me-64k-storage-cell" })
--- IV: 256k and the cards (platinum), fiber-reinforced boards for the component
tech("me-storage-256k", { "me-storage-64k", "industrial-precision-lathe", "ev-machines" }, 6, 1000, {
	"me-256k-storage-component", "annealed-copper-foil",
	"fiber-reinforced-epoxy-sheet", "fiber-reinforced-circuit-board", "fiber-reinforced-printed-circuit-board",
	"me-256k-storage-cell",
})

--- the crafting blocks a technology unlocks (none with me-network 0.2.0)
local function with_blocks(recipes, blocks)
	if HAS_CRAFTING_BLOCKS then
		for _, name in ipairs(blocks) do recipes[#recipes + 1] = name end
	end
	return recipes
end

--- EV: autocrafting and the first crafting CPU (a crafting unit, 1k and 4k crafting storage, the monitor)
tech("me-autocrafting", { "me-storage-64k" }, 5, 600, with_blocks(
	{ "me-pattern-provider", "me-pattern-terminal", "me-blank-pattern", "me-molecular-assembler" },
	{ "me-crafting-unit", "me-1k-crafting-storage", "me-4k-crafting-storage", "me-crafting-monitor" }), SEVEN)
--- issue #38: level maintainer and circuit interface (EV); issue #111: the 16k and 64k crafting storage and the
--- co-processing unit at IV, the 256k crafting storage at LuV
tech("me-automation", { "me-autocrafting", "circuit-network" }, 5, 800,
	{ "me-level-maintainer", "me-circuit-interface" }, SEVEN)
tech("me-co-processing", { "me-autocrafting", "me-storage-256k", "iv-components" }, 6, 1200, with_blocks({},
	{ "me-16k-crafting-storage", "me-64k-crafting-storage", "me-crafting-co-processing-unit" }), SEVEN)
tech("me-quantum-crafting", { "me-co-processing", "luv-machines" }, 7, 1500,
	with_blocks({}, { "me-256k-crafting-storage" }), SEVEN)

--- EV: fluid cells up to 64k; IV: 256k fluid cells (the ME Interface and the buses move fluids from the start since
--- me-network 0.2.0: the network stores them once fluid cells exist, or in a tank behind a storage bus)
tech("me-fluid-storage", { "me-autocrafting" }, 5, 600, {
	"me-1k-fluid-storage-cell", "me-4k-fluid-storage-cell", "me-16k-fluid-storage-cell", "me-64k-fluid-storage-cell",
})
tech("me-fluid-storage-256k", { "me-fluid-storage", "me-storage-256k" }, 6, 800, { "me-256k-fluid-storage-cell" })

--- IV: the Advanced Card (platinum) and the cards and the workbench; the Inverter Card needs decider combinators, the
--- Equal Distribution Card a turbo splitter; the Acceleration Card is made from the Advanced Card; issue #211: the
--- Pattern Capacity, Interface Capacity and Sticky Card (me-network 0.5.3; skipped when the loaded one lacks them)
if HAS_CARDS then
	tech("me-upgrade-cards", { "me-storage-256k", "circuit-network", "turbo-transport-belt" }, 6, 1000, {
		"me-basic-card", "me-advanced-card", "me-acceleration-card", "me-capacity-card", "me-overflow-destruction-card",
		"me-fuzzy-card", "me-pattern-capacity-card", "me-interface-capacity-card", "me-sticky-card", "me-inverter-card",
		"me-equal-distribution-card", "me-cell-workbench",
	})
end

--- issue #212: IV, after the cards (the Wireless Booster goes into the access point's card slots), which come after the
--- battery, the EV electrolyzer of the charger and the ender pearl of the booster (me-network: after me-upgrade-cards and
--- battery, 500 units of 3 packs)
if HAS_WIRELESS then
	tech("me-wireless", { "me-upgrade-cards" }, 6, 1200, {
		"me-wireless-access-point", "me-wireless-booster", "me-wireless-terminal", "me-charger", "me-wireless-module",
	})
end
