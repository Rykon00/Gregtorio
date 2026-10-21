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

--- Issue #294: GTNH's housing (ASM:4569-4577: a glass pane, a certus quartz plate, an aluminium plate, 2 stainless steel
--- plates, 5 s at LV / 2); Gregtorio has no glass pane, its glass takes the place. Upstream kept steel (4 plates, 4
--- screws, a glass) for its microverse data items, which needed the housing with Overworld Data, before aluminium and
--- stainless steel; issue #287 removed them, so the housing comes with its first consumer now, the cells of the ME
--- Network technology (below). The certus quartz plate is GT's bender recipe of a gem (OP/ProcessingGem.java:117-125:
--- 1 gem -> 1 plate, mass x 2 ticks; certus quartz has no material list, so Technetium's mass 98 -> 9.8 s, 24 EU/t),
--- as the nether quartz plate below
upstream_item{
	name = "basic-storage-housing",
	category = "lv-assembling-machine-recipes",
	energy_required = 5 * LV_SPEED,
	ingredients = I{ "glass", 1, "certus-quartz-plate", 1, "aluminium-plate", 1, "stainless-steel-plate", 2 },
}
create_item{
	name = "certus-quartz-plate",
	category = "lv-bending-machine-recipes",
	energy_required = 9.8 * LV_SPEED,
	ingredients = { { type = "item", name = "certus-quartz", amount = 1 } },
}
--- Issue #459: GTNH's Advanced Storage Housing (SAE2:254-261: a glass pane, a certus quartz plate, 3 chrome plates, 2
--- certus quartz screws; 5 s at LV / 2) of the 256k to 16384k cells (SAE2:276-303); the glass for the pane, as above. AE2's
--- texture is not drawn: me-network's housing icon with the chromium plate as a badge
create_item{
	name = "advanced-storage-housing",
	category = "lv-assembling-machine-recipes",
	energy_required = 5 * LV_SPEED,
	ingredients = I{ "glass", 1, "certus-quartz-plate", 1, "chromium-plate", 3, "certus-quartz-screw", 2 },
}
do
	local housing, item = data.raw.item["basic-storage-housing"], data.raw.item["advanced-storage-housing"]
	local base = housing.icons and housing.icons[1] or { icon = housing.icon, icon_size = housing.icon_size }
	item.icon, item.icon_size = nil, nil
	item.icons = { { icon = base.icon, icon_size = base.icon_size },
		{ icon = "__gregtorio-continued__/graphics/icons/chromium-plate.png", icon_size = 32, scale = 0.5,
			shift = { 8, 8 } } }
	item.subgroup, item.order = housing.subgroup, (housing.order or "") .. "-advanced"
end
do
	local t = data.raw.technology["overworld-data"]
	local keep = {}
	for _, e in pairs(t.effects) do
		if not (e.type == "unlock-recipe" and e.recipe == "basic-storage-housing") then keep[#keep + 1] = e end
	end
	t.effects = keep
end

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
	def.energy_required = 10 * ({ lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED, iv = IV_SPEED, luv = LUV_SPEED,
		uv = UV_SPEED })[def.tier]
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
--- issue #454 (me-network 0.5.5, its issue #414): AE2-Unofficial's components above 256k, GTNH's recipes (SAE2:336-362,
--- circuit assembler, 72 soldering alloy, 10 s): 1024k from 4 IV and 16 EV circuits, an engineering processor and a
--- multifiberglass elite board (IV); 4096k 4 LuV, 16 IV, an advanced engineering processor and a wetware board (LuV);
--- 16384k 4 UV, 16 LuV, an advanced engineering processor and a bio board (UV). The boards are Gregtorio's multilayered
--- fiber-reinforced, wetware and bioware printed boards. Issue #485: the processors are GTNH's (below); GTNH's 256k and
--- 1024k components take the Item Processor Tier III, Gregtorio's 1024k one does, its 256k one keeps the engineering
--- processor (the tier III circuit's energy crystal needs energium, which comes with the ZPM assembly line here, after
--- the 256k cells). me-network before 0.5.5 has none
---
--- Issue #485: GTNH's Item Processor Tier III and IV (NewHorizonsCoreMod scripts/ScriptCoreMod.java:850-860: an
--- engineering processor and the Item Circuit Tier III or IV in the IV or LuV assembler, 5 s), their circuits (:1120-1131:
--- the engraved energy chip or the Engraved Quantum Chip and BuildCraft's emerald chipset in the forming press, 15 s at
--- EV / 2 and IV / 2), the Engraved Quantum Chip (:951-968: an exquisite yellow garnet engraved with the yellow garnet
--- lens, LuV, 60 s) and BuildCraft's emerald chipset (ScriptBuildCraft.java:536-541: an emerald plate and a redstone
--- chipset in the forming press, HV, 10 s). The redstone chipset is BuildCraft's laser Assembly Table recipe (1 redstone
--- dust), which GTNH keeps; Gregtorio has no laser table: the LV assembler, 5 s (a named stand-in). The forming press has
--- one category here: each recipe takes its tier's time (as orundum, 164)
create_item{ name = "redstone-chipset", category = "lv-assembling-machine-recipes", energy_required = 5 * LV_SPEED,
	ingredients = I{ "redstone-dust", 1 } }
create_item{ name = "emerald-chipset", category = "lv-forming-press-recipes", energy_required = 10 * HV_SPEED,
	ingredients = I{ "emerald-plate", 1, "redstone-chipset", 1 } }
create_item{ name = "engraved-quantum-chip", category = "luv-laser-engraver-recipes", energy_required = 60 * LUV_SPEED,
	ingredients = I{ "exquisite-yellow-garnet", 1, "yellow-garnet-lens", 1 },
	results = I{ "engraved-quantum-chip", 1, "yellow-garnet-lens", 1 }, main_product = "engraved-quantum-chip" }
create_item{ name = "item-circuit-tier-iii", category = "lv-forming-press-recipes", energy_required = 15 * EV_SPEED,
	ingredients = I{ "engraved-energy-chip", 1, "emerald-chipset", 1 } }
create_item{ name = "item-circuit-tier-iv", category = "lv-forming-press-recipes", energy_required = 15 * IV_SPEED,
	ingredients = I{ "engraved-quantum-chip", 1, "emerald-chipset", 1 } }
create_item{ name = "item-processor-tier-iii", category = "iv-assembling-machine-recipes", energy_required = 5 * IV_SPEED,
	ingredients = I{ "engineering-processor", 1, "item-circuit-tier-iii", 1 } }
create_item{ name = "item-processor-tier-iv", category = "luv-assembling-machine-recipes", energy_required = 5 * LUV_SPEED,
	ingredients = I{ "engineering-processor", 1, "item-circuit-tier-iv", 1 } }
local HAS_BIG_CELLS = data.raw.item["me-1024k-storage-component"] ~= nil
local BIG_CELLS = HAS_BIG_CELLS and {
	{ size = "1024k", tier = "iv", board = "multilayered-fiber-reinforced-printed-circuit-board", circuits = { "iv-circuit", "ev-circuit" },
	  pump = "iv-pump", processor = "item-processor-tier-iii" },
	{ size = "4096k", tier = "luv", board = "wetware-printed-circuit-board", circuits = { "luv-circuit", "iv-circuit" },
	  pump = "luv-pump", processor = "item-processor-tier-iv" },
	{ size = "16384k", tier = "uv", board = "bioware-printed-circuit-board", circuits = { "uv-circuit", "luv-circuit" },
	  pump = "uv-pump", processor = "item-processor-tier-iv" },
} or {}
for _, c in ipairs(BIG_CELLS) do
	upstream_item(component{
		name = "me-" .. c.size .. "-storage-component",
		tier = c.tier,
		ingredients = I{ c.board, 1, c.circuits[2], 16, c.circuits[1], 4, c.processor, 1 },
	})
end
--- issue #216: upstream unlocks the 4k and the 16k component with logistic-system (and with the data technologies of
--- the microverse, removed in issue #287). The technology that unlocks them has the technologies of their ingredients
--- before it: logistic-system gets nand-chips (the 4k one's NAND chips), an earlier technology of the same science
for tech, pre in pairs({ ["logistic-system"] = "nand-chips" }) do
	local t = data.raw.technology[tech]
	local has = false
	for _, x in pairs(t and t.prerequisites or {}) do if x == pre then has = true end end
	if t and not has then
		t.prerequisites = t.prerequisites or {}
		table.insert(t.prerequisites, pre)
	end
end

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
			--- issue #459: GTNH's advanced storage housing from 256k on (SAE2:276-303)
			{ type = "item", name = tier == "256k" and "advanced-storage-housing" or "basic-storage-housing", amount = 1 },
		},
	}
	data.raw.recipe[cell].auto_recycle = false         -- a recycler would void the contents
end
--- issue #454: the cells above 256k as the 256k one, in the assembler of their component's tier (GTNH, SAE2:290-310: an
--- advanced storage housing and the component; issue #459 added the housing)
for i, c in ipairs(BIG_CELLS) do
	local cell = "me-" .. c.size .. "-storage-cell"
	recipe_of{
		name = cell,
		category = c.tier .. "-assembling-machine-recipes",
		subgroup = "fork-me-cells",
		order = string.format("%02d", 5 + i),
		energy_required = 5,
		ingredients = I{ "me-" .. c.size .. "-storage-component", 1, "advanced-storage-housing", 1 },
	}
	data.raw.recipe[cell].auto_recycle = false
end
--- issue #454: the Singularity cell, GTNH's Digital Singularity ME Storage Cell (SpaceAssemblerRecipes.java:425-433, the
--- space assembler's module tier 1, UHV, 10 s). The recipe here is the base: issue #485 replaces it in 162 with GTNH's, in the
--- Space Elevator Assembler Module (162 loads after the space elevator it needs)
if data.raw["item-with-tags"]["me-singularity-storage-cell"] then
	recipe_of{
		name = "me-singularity-storage-cell",
		category = "uhv-assembling-machine-recipes",
		subgroup = "fork-me-cells",
		order = "09",
		energy_required = 10 * UHV_SPEED,
		ingredients = I{ "me-16384k-storage-component", 12, "dense-infinity-plate", 4, "infinity-catalyst-dust", 4,
			"dense-cosmic-neutronium-plate", 12 },
	}
	data.raw.recipe["me-singularity-storage-cell"].auto_recycle = false
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

--- issue #297 (me-network 0.5.4, its issue #336): the ME Interface Terminal, GTNH's recipe (NewHorizonsCoreMod
--- scripts/ScriptAppliedEnergistics2.java:2302-2311, "ME Interface Terminal"): an ME Terminal, 2 certus quartz screws,
--- an ME Interface, 2 nether quartz plates and an engineering processor in the MV assembler, 10 s; the Pattern
--- Terminal's recipe with the interface for the blank pattern. me-network before 0.5.4 has no such block
--- me-network 0.5.4 (its issue #353): the ME Storage, Conversion and Throughput Monitor, GTNH's recipes (NewHorizonsCoreMod
--- scripts/ScriptAppliedEnergistics2.java:2359-2367 storage, :2368-2376 throughput, :2312-2320 conversion), MV assembler:
---   storage: an illuminated panel, 2 certus quartz screws, a level emitter, 3 nether quartz plates, 10 s;
---   throughput: a storage monitor, 2 certus quartz screws, a level emitter, 3 nether quartz plates, 10 s;
---   conversion: a storage monitor, 2 certus quartz screws, a formation core, 2 nether quartz plates, an annihilation core, 20 s.
--- Gregtorio has no illuminated panel and no level emitter: the computer monitor (the ME Terminal's screen) and an MV sensor
--- stand in. me-network before 0.5.4 has no monitors.
local MONITORS = data.raw.item["me-storage-monitor"] and {
	{ "me-storage-monitor", 10, I{ "computer-monitor", 1, "certus-quartz-screw", 2, "mv-sensor", 1, "nether-quartz-plate", 3 } },
	{ "me-throughput-monitor", 10, I{ "me-storage-monitor", 1, "certus-quartz-screw", 2, "mv-sensor", 1, "nether-quartz-plate", 3 } },
	{ "me-conversion-monitor", 20, I{ "me-storage-monitor", 1, "certus-quartz-screw", 2, "formation-core", 1,
		"nether-quartz-plate", 2, "annihilation-core", 1 } },
} or {}
for i, m in ipairs(MONITORS) do
	recipe_of{
		name = m[1],
		category = "mv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = "c" .. i,
		energy_required = m[2] * MV_SPEED,
		ingredients = m[3],
	}
end

local HAS_INTERFACE_TERMINAL = data.raw.item["me-interface-terminal"] ~= nil
if HAS_INTERFACE_TERMINAL then
	recipe_of{
		name = "me-interface-terminal",
		category = "mv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = "e0b",
		energy_required = 10 * MV_SPEED,
		ingredients = I{ "me-terminal", 1, "certus-quartz-screw", 2, "me-interface", 1, "nether-quartz-plate", 2,
			"engineering-processor", 1 },
	}
end

--- issue #456 (me-network 0.5.5, its issue #416): the ME Pattern Terminal Ex is AE2-Unofficial's Processing Pattern Terminal,
--- GTNH's recipe (NewHorizonsCoreMod scripts/ScriptAppliedEnergistics2.java:2280-2289): an ME Crafting Terminal, 2 LuV
--- conveyor modules, an advanced engineering processor, 2 LuV electric motors and a LuV robot arm in the MV assembler,
--- 10 s. me-network has no crafting terminal: the ME Pattern Terminal (the block it extends); the advanced engineering
--- processor is the Item Processor Tier IV (issue #485). me-network before 0.5.5 has none
local HAS_PATTERN_TERMINAL_EX = data.raw.item["me-pattern-terminal-ex"] ~= nil
if HAS_PATTERN_TERMINAL_EX then
	recipe_of{
		name = "me-pattern-terminal-ex",
		category = "mv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = "e0a",
		energy_required = 10 * MV_SPEED,
		ingredients = I{ "me-pattern-terminal", 1, "luv-conveyor-module", 2, "item-processor-tier-iv", 1, "luv-motor", 2,
			"luv-robot-arm", 1 },
	}
end

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

--- me-network 0.5.4 (its issue #355): the ME Level Emitter, the ME Toggle Bus and the ME Inverted Toggle Bus, GTNH's recipes
--- (NewHorizonsCoreMod scripts/ScriptAppliedEnergistics2.java): the level emitter from a redstone torch and a calculation
--- processor (:2201-2206; the torch is a decider combinator here, as the inverter card's redstone parts), the toggle bus from a
--- level emitter and 2 fluix cables (:2213-2218), both LV assembler, 10 s; the inverted one from a toggle bus (:2222-2224, 5 s;
--- GTNH also turns it back with circuit 1: left out, a recipe loop, as in me-network). me-network before 0.5.4 has none
local HAS_TOGGLE = data.raw.item["me-toggle-bus"] ~= nil
if HAS_TOGGLE then
	for _, r in ipairs({
		{ "me-level-emitter", "g7", 10, I{ "decider-combinator", 1, "calculation-processor", 1 } },
		{ "me-toggle-bus", "g61", 10, I{ "me-level-emitter", 1, "fluix-cable", 2 } },
		{ "me-inverted-toggle-bus", "g62", 5, I{ "me-toggle-bus", 1 } },
	}) do
		recipe_of{
			name = r[1],
			category = "lv-assembling-machine-recipes",
			subgroup = "fork-me-network",
			order = r[2],
			energy_required = r[3] * LV_SPEED,
			ingredients = r[4],
		}
	end
end
--- issue #457 (me-network 0.5.5, its issue #443): the ME Advanced Level Emitter, GTNH's recipe (NewHorizonsCoreMod
--- scripts/ScriptAppliedEnergistics2.java:2207-2211): an EV circuit and a level emitter in the MV assembler, 15 s.
--- me-network before 0.5.5 has none
local HAS_ADVANCED_EMITTER = data.raw.item["me-advanced-level-emitter"] ~= nil
if HAS_ADVANCED_EMITTER then
	recipe_of{
		name = "me-advanced-level-emitter",
		category = "mv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = "g8",
		energy_required = 15 * MV_SPEED,
		ingredients = I{ "ev-circuit", 1, "me-level-emitter", 1 },
	}
end

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

	--- issue #455 (me-network 0.5.5, its issue #415): the crafting storage above 256k as GTNH's advanced crafting storage
	--- (SAE2:364-378: the component and a crafting unit, EV assembler, 20 s)
	for _, c in ipairs(BIG_CELLS) do
		if data.raw.item["me-" .. c.size .. "-crafting-storage"] then
			block("me-" .. c.size .. "-crafting-storage", "ev-assembling-machine-recipes", 20 * EV_SPEED,
				I{ "me-crafting-unit", 1, "me-" .. c.size .. "-storage-component", 1 })
		end
	end
	--- GTNH's ME Singularity Crafting Storage (SAE2:618-649, Avaritia's extreme crafting table): 4 crafting units, a
	--- Singularity cell, 8 Piko circuits, 12 UIV field generators, 24 dense infinity plates, 4 spacetime frames, 12 spacetime
	--- wires, 4 transcendent metal nanites, 4 creative energy cells and 8 Draconic reactor stabilizers. Gregtorio has no
	--- extreme crafting table, no nanites and neither of the last two: the UIV assembler (the field generators' tier), the
	--- UMV circuit for the Piko circuit, a block of transcendent metal for its nanites; the creative cells and the
	--- stabilizers are left out
	if data.raw.item["me-singularity-crafting-storage"] then
		block("me-singularity-crafting-storage", "uiv-assembling-machine-recipes", 20 * UIV_SPEED,
			I{ "me-crafting-unit", 4, "me-singularity-storage-cell", 1, "umv-circuit", 8, "uiv-field-generator", 12,
				"dense-infinity-plate", 24, "spacetime-frame", 4, "spacetime-wire", 12, "block-of-transcendent-metal", 4 })
	end
	--- GTNH's co-processing units of 4 to 4096 cores (SAE2:212-251): a crafting unit and 2 circuits of the tier above the
	--- assembler's, 5 s: 4x IV circuits (EV), 16x LuV (IV), 64x ZPM (LuV), 256x UV (ZPM), 1024x UHV (UV), 4096x UEV (UHV);
	--- AE2-Unofficial's (and me-network's own) are four of the one below
	for _, a in ipairs({ { "4x", "iv-circuit", "ev", EV_SPEED }, { "16x", "luv-circuit", "iv", IV_SPEED },
			{ "64x", "zpm-circuit", "luv", LUV_SPEED }, { "256x", "uv-circuit", "zpm", ZPM_SPEED },
			{ "1024x", "uhv-circuit", "uv", UV_SPEED }, { "4096x", "uev-circuit", "uhv", UHV_SPEED } }) do
		local name = "me-crafting-accelerator-" .. a[1]
		if data.raw.item[name] then
			block(name, a[3] .. "-assembling-machine-recipes", 5 * a[4], I{ "me-crafting-unit", 1, a[2], 2 })
		end
	end
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
--- issue #454: the fluid cells above 256k with the pump of their tier, as the ones below
for i, c in ipairs(BIG_CELLS) do
	local cell = "me-" .. c.size .. "-fluid-storage-cell"
	recipe_of{
		name = cell,
		category = c.tier .. "-assembling-machine-recipes",
		subgroup = "fork-me-fluid-cells",
		order = string.format("%02d", 5 + i),
		energy_required = 5,
		ingredients = I{ "me-" .. c.size .. "-storage-component", 1, "basic-storage-housing", 1, c.pump, 1 },
	}
	data.raw.recipe[cell].auto_recycle = false
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

--- me-network 0.5.4 (its issue #354): the Void ME Storage Cell, GTNH's recipe (NewHorizonsCoreMod
--- gthandler/recipes/AssemblerRecipes.java:4660-4668, "Void Cell"): 2 certus quartz screws, a certus quartz plate, 3 tungsten
--- plates and a singularity in the HV assembler, 5 s. Gregtorio has no singularity (GTNH compresses 512 000 cobblestone into
--- one in the IV neutronium compressor, SAE2:903-906): it is left out. AE2-Unofficial's void cell takes items and fluids,
--- me-network has one of each: the fluid one gets the same recipe. me-network before 0.5.4 has none.
local HAS_VOID_CELLS = data.raw["item-with-tags"]["me-void-storage-cell"] ~= nil   -- (cells are items with tags)
if HAS_VOID_CELLS then
	for i, name in ipairs({ "me-void-storage-cell", "me-void-fluid-storage-cell" }) do
		if data.raw["item-with-tags"][name] then
			recipe_of{
				name = name,
				category = "hv-assembling-machine-recipes",
				subgroup = i == 1 and "fork-me-cells" or "fork-me-fluid-cells",
				order = "z" .. i,
				energy_required = 5 * HV_SPEED,
				ingredients = I{ "certus-quartz-screw", 2, "certus-quartz-plate", 1, "tungsten-plate", 3 },
			}
		end
	end
end

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
	--- GTNH: basic card, two calculation processors, an ME Void Storage Cell (me-network before 0.5.4 has none: its shell,
	--- the storage housing)
	card("me-overflow-destruction-card", "d",
		I{ "me-basic-card", 1, "calculation-processor", 2, HAS_VOID_CELLS and "me-void-storage-cell" or "basic-storage-housing", 1 })
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
	--- me-network 0.5.4 (its issue #354): the Group Filter Card is AE2-Unofficial's Ore Dictionary Filter Card, GTNH's recipe
	--- (SAE2:1332-1338, shapeless): an advanced card, 2 engineering processors and an IV Type Filter. Gregtorio has no Type
	--- Filter: its parts (GT5-Unofficial MTERecipeLoader.java:4182-4187: the IV hull, an IV conveyor module, a chest, an item
	--- filter, an LV circuit)
	card("me-group-filter-card", "e5", I{ "me-advanced-card", 1, "engineering-processor", 2, "iv-machine-hull", 1,
		"iv-conveyor-module", 1, "wooden-chest", 1, "filter", 1, "electronic-circuit", 1 })
	--- me-network 0.5.4 (its issue #356): the Super Speed and Superluminal Speed Cards with AE2-Unofficial's ingredients, as
	--- me-network has them (an Acceleration Card and a 16k storage component; a Super Speed Card and 4 256k storage components,
	--- for AE2-U's 1024k), made like the other cards. GTNH's (scripts/ScriptAppliedEnergistics2.java:196-202 and :2076-2082:
	--- an advanced card, an engineering processor, a mysterious crystal and an LuV world accelerator; a dilithium gem and a UV
	--- world accelerator) need items Gregtorio does not have: which stand-ins they get is open (the maintainer's decision)
	card("me-super-speed-card", "h2", I{ "me-acceleration-card", 1, "me-16k-storage-component", 1 })
	card("me-superluminal-speed-card", "h3", I{ "me-super-speed-card", 1, "me-256k-storage-component", 4 })
	--- issue #453 (me-network 0.5.5, its issue #411): GTNH's Crafting Card (SAE2:1297-1303, shapeless): a basic card, two 1k
	--- storage components, a crafting table
	card("me-crafting-card", "e6", I{ "me-basic-card", 1, "me-1k-storage-component", 2, "crafting-table", 1 })
	--- issue #458 (me-network 0.5.5, its issue #440): GTNH's View Cell (SAE2:1749-1752, shapeless, AE2-Unofficial's own
	--- recipe too): a storage housing and a certus quartz; GTNH's shaped recipe with plates and screws is left out
	if data.raw["item-with-tags"]["me-view-cell"] then
		recipe_of{ name = "me-view-cell", subgroup = "fork-me-cards", order = "y",
			ingredients = I{ "basic-storage-housing", 1, "certus-quartz", 1 } }
	end

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
--- THE IO PORT, THE QUANTUM BRIDGE AND THE WIRELESS LINK (me-network 0.5.4, its issues #384 to #386; issue #352)
--- GTNH's AE2 recipes (ASM), each guarded by its item (an older me-network has none). Stand-ins as above: the HV sensor
--- for the Wireless Receiver, a battery for AE2's Energy Cell (4 for the Dense one); and for the parts Gregtorio lacks:
--- an ender pearl and a fluix crystal for a Fluix Pearl (AE2 makes it from an ender pearl, fluix dust and fluix
--- crystals), glass for Quartz Glass (AE2's is glass and quartz dust)
--------------------------------------------------------------------------------

--- with me-network's subgroup and order of the item
local function block_recipe(name, category, energy_required, ingredients)
	local item = data.raw.item[name]
	if not item then return end
	recipe_of{ name = name, category = category, energy_required = energy_required, subgroup = item.subgroup,
		order = item.order, ingredients = ingredients }
end

--- GTNH (ASM:4752-4760): 3 titanium plates, 3 fluix cables, a logic processor, 2 ME Drives, HV, 5 s; here aluminium
--- and the drive's category, since it comes with ME Network (MV here)
block_recipe("me-io-port", nil, 5, I{ "aluminium-plate", 3, "fluix-cable", 3, "logic-processor", 1, "me-drive", 2 })
--- GTNH (ASM:4696-4713): the Quantum Ring (an Energy Cell, 4 titanium plates, an engineering processor, 2 logic
--- processors, a fluix cable) and the Quantum Link Chamber (4 titanium plates, 4 Fluix Pearls, a Quartz Glass), HV, 5 s
--- each. me-network's bridge is AE2's 8 rings and a chamber in one 3x3 block: their sum, 9 times the time
block_recipe("me-quantum-bridge", "hv-assembling-machine-recipes", 45 * HV_SPEED,
	I{ "battery", 8, "titanium-plate", 36, "engineering-processor", 8, "logic-processor", 16, "fluix-cable", 8,
		"ender-pearl", 4, "fluix-crystal", 4, "glass", 1 })
--- GTNH (ASM:5036-5044), AE2 Stuff's Wireless Connector: 2 titanium plates, 4 pure fluix crystals, 2 engineering
--- processors, a Wireless Receiver, HV, 5 s
block_recipe("me-wireless-link", "hv-assembling-machine-recipes", 5 * HV_SPEED,
	I{ "titanium-plate", 2, "pure-fluix-crystal", 4, "engineering-processor", 2, "hv-sensor", 1 })



--------------------------------------------------------------------------------
--- TECHNOLOGIES (Gregtorio's tiers and science packs)
--------------------------------------------------------------------------------

local PACKS = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
	"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
	"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack", "cryogenic-science-pack",
	"promethium-science-pack" }
--- (issues #454, #455: ZPM to UIV, the amounts of the tier files 126-132)
local TWELVE = { SP12, SP11, SP10, SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
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
--- recipe, issue #214); issue #294: GTNH's storage housing of the cells and its certus quartz plate (Overworld Data
--- unlocked upstream's)
local me_network = { "me-terminal", "computer-monitor", "certus-quartz-bolt", "certus-quartz-screw", "me-chest", "me-drive",
	"basic-storage-housing", "certus-quartz-plate", "me-1k-storage-cell", "me-4k-storage-cell", "me-16k-storage-cell",
	"nether-quartz-plate", "me-import-bus", "me-export-bus", "me-underground-cable", "me-storage-bus" }
for _, m in ipairs(MONITORS) do me_network[#me_network + 1] = m[1] end      -- (me-network 0.5.4: the monitors)
if data.raw.item["me-io-port"] then me_network[#me_network + 1] = "me-io-port" end   -- (0.5.4, issue #352)
tech("me-network", { "logistic-system", "stainless-steel" }, 3, 400, me_network)
--- EV: 64k (the component needs epoxy boards)
tech("me-storage-64k", { "me-network", "nanoprocessors", "advanced-hv-machines" }, 5, 800,
	{ "me-64k-storage-component", "me-64k-storage-cell" })
--- IV: 256k and the cards (platinum), fiber-reinforced boards for the component
tech("me-storage-256k", { "me-storage-64k", "industrial-precision-lathe", "ev-machines" }, 6, 1000, {
	"me-256k-storage-component", "annealed-copper-foil",
	"fiber-reinforced-epoxy-sheet", "fiber-reinforced-circuit-board", "fiber-reinforced-printed-circuit-board",
	"advanced-storage-housing", "me-256k-storage-cell",
})

--- the crafting blocks a technology unlocks (none with me-network 0.2.0)
local function with_blocks(recipes, blocks)
	if HAS_CRAFTING_BLOCKS then
		for _, name in ipairs(blocks) do recipes[#recipes + 1] = name end
	end
	return recipes
end

--- EV: autocrafting and the first crafting CPU (a crafting unit, 1k and 4k crafting storage, the monitor); issue #297:
--- the ME Interface Terminal (me-network 0.5.4) with the Pattern Terminal, as me-network unlocks it
local autocrafting = { "me-pattern-provider", "me-pattern-terminal", "me-blank-pattern", "me-molecular-assembler" }
if HAS_INTERFACE_TERMINAL then autocrafting[#autocrafting + 1] = "me-interface-terminal" end
tech("me-autocrafting", { "me-storage-64k" }, 5, 600, with_blocks(autocrafting,
	{ "me-crafting-unit", "me-1k-crafting-storage", "me-4k-crafting-storage", "me-crafting-monitor" }), SEVEN)
--- issue #38: level maintainer and circuit interface (EV); the level emitter and the toggle buses (me-network 0.5.4, its
--- issue #355), where me-network puts them; issue #111: the 16k and 64k crafting storage and the co-processing unit at IV,
--- the 256k crafting storage at LuV
local automation = { "me-level-maintainer", "me-circuit-interface" }
if HAS_TOGGLE then
	for _, name in ipairs({ "me-level-emitter", "me-toggle-bus", "me-inverted-toggle-bus" }) do automation[#automation + 1] = name end
end
if HAS_ADVANCED_EMITTER then automation[#automation + 1] = "me-advanced-level-emitter" end   -- (issue #457)
tech("me-automation", { "me-autocrafting", "circuit-network" }, 5, 800, automation, SEVEN)
tech("me-co-processing", { "me-autocrafting", "me-storage-256k", "iv-components" }, 6, 1200, with_blocks({},
	{ "me-16k-crafting-storage", "me-64k-crafting-storage", "me-crafting-co-processing-unit" }), SEVEN)
--- issue #456: the Pattern Terminal Ex with its LuV components (me-network: with the Pattern Terminal); issue #485: its
--- Item Processor Tier IV with the chipsets, the Engraved Quantum Chip and the Item Circuit Tier IV
tech("me-quantum-crafting", { "me-co-processing", "luv-machines" }, 7, 1500,
	with_blocks(HAS_PATTERN_TERMINAL_EX and { "me-pattern-terminal-ex", "redstone-chipset", "emerald-chipset",
		"engraved-quantum-chip", "item-circuit-tier-iv", "item-processor-tier-iv" } or {}, { "me-256k-crafting-storage" }), SEVEN)

--- EV: fluid cells up to 64k; IV: 256k fluid cells (the ME Interface and the buses move fluids from the start since
--- me-network 0.2.0: the network stores them once fluid cells exist, or in a tank behind a storage bus)
tech("me-fluid-storage", { "me-autocrafting" }, 5, 600, {
	"me-1k-fluid-storage-cell", "me-4k-fluid-storage-cell", "me-16k-fluid-storage-cell", "me-64k-fluid-storage-cell",
})
tech("me-fluid-storage-256k", { "me-fluid-storage", "me-storage-256k" }, 6, 800, { "me-256k-fluid-storage-cell" })

--- IV: the Advanced Card (platinum) and the cards and the workbench; the Inverter Card needs decider combinators, the
--- Equal Distribution Card a turbo splitter; the Acceleration Card is made from the Advanced Card; issue #211: the
--- Pattern Capacity, Interface Capacity and Sticky Card (me-network 0.5.3; skipped when the loaded one lacks them); the Group
--- Filter Card and the void cells (me-network 0.5.4): the Overflow Destruction Card is made from the item one
if HAS_CARDS then
	local cards = {
		"me-basic-card", "me-advanced-card", "me-acceleration-card", "me-capacity-card", "me-overflow-destruction-card",
		"me-fuzzy-card", "me-pattern-capacity-card", "me-interface-capacity-card", "me-sticky-card", "me-inverter-card",
		"me-equal-distribution-card", "me-cell-workbench", "me-group-filter-card", "me-void-storage-cell",
		"me-void-fluid-storage-cell", "me-super-speed-card", "me-superluminal-speed-card",
	}
	--- issues #453 and #458: the Crafting Card and the View Cell (me-network 0.5.5)
	for _, name in ipairs({ "me-crafting-card", "me-view-cell" }) do
		if data.raw.recipe[name] then cards[#cards + 1] = name end
	end
	tech("me-upgrade-cards", { "me-storage-256k", "circuit-network", "turbo-transport-belt" }, 6, 1000, cards)
end

--- issue #212: IV, after the cards (the Wireless Booster goes into the access point's card slots), which come after the
--- battery, the EV electrolyzer of the charger and the ender pearl of the booster (me-network: after me-upgrade-cards and
--- battery, 500 units of 3 packs); issue #215: the ME Wireless Terminal Module stays locked (FORK_RECIPES_LOCKED)
if HAS_WIRELESS then
	tech("me-wireless", { "me-upgrade-cards" }, 6, 1200, {
		"me-wireless-access-point", "me-wireless-booster", "me-wireless-terminal", "me-charger",
	})
	--- issue #352: the Wireless Link (me-network 0.5.4) after the wireless terminal, as me-network puts it
	if data.raw.technology["me-wireless-link"] then
		tech("me-wireless-link", { "me-wireless" }, 6, 800, { "me-wireless-link" })
	end
end
--- issue #352: the Quantum Bridge (me-network 0.5.4) after 256k storage, as me-network puts it (its own technology
--- needs utility science, the sixth pack here)
if data.raw.technology["me-quantum-bridge"] then
	tech("me-quantum-bridge", { "me-storage-256k" }, 6, 1500, { "me-quantum-bridge" })
end

--- issues #454 and #455 (me-network 0.5.5, its issues #414 and #415): the cells above 256k, the Singularity cell, their
--- crafting storage and the crafting accelerators, each at the tier of its GT parts (the components' boards: the
--- multilayered fiber-reinforced board with the ZPM assembly line, the wetware board at UV, the bioware board at UHV;
--- the Singularity cell's infinity and cosmic neutronium at UHV, its crafting storage's spacetime and UMV circuits at
--- UIV); the counts from UV on are scaled as in 138 (UV /4.5, UHV /13.9, UIV /25.3)
if HAS_BIG_CELLS then
	local function tech_n(name, prerequisites, packs, count, recipes)
		if not data.raw.technology[name] then return end
		ME.set_technology(name, { prerequisites = prerequisites, recipes = recipes,
			unit = { count = count, ingredients = sci(packs, TWELVE), time = 30 } })
	end
	local STEPS = {
		{ size = "1024k", packs = 8, count = 1500, before = "me-storage-256k", fbefore = "me-fluid-storage-256k",
		  parts = { "zpm-assembly-line" }, fluid_count = 1000, crafting_count = 1500,
		  recipes = { "redstone-chipset", "emerald-chipset", "item-circuit-tier-iii",
			"item-processor-tier-iii" } },   -- (issue #485: the processor's chain, also with ME Quantum Crafting's; the
		  -- energy crystal and the engraved energy chip come from 164)
		{ size = "4096k", packs = 9, count = 450, before = "me-storage-1024k", fbefore = "me-fluid-storage-1024k",
		  parts = { "wetware-processors" }, fluid_count = 300, crafting_count = 450,
		  recipes = { "engraved-quantum-chip", "item-circuit-tier-iv", "item-processor-tier-iv" } },   -- (issue #485)
		{ size = "16384k", packs = 10, count = 225, before = "me-storage-4096k", fbefore = "me-fluid-storage-4096k",
		  parts = { "bio-processors", "uv-machines" }, fluid_count = 150, crafting_count = 225 },
	}
	local crafting_before = "me-quantum-crafting"
	for _, s in ipairs(STEPS) do
		local storage = "me-storage-" .. s.size
		local prerequisites = { s.before }
		for _, p in ipairs(s.parts) do prerequisites[#prerequisites + 1] = p end
		local recipes = { "me-" .. s.size .. "-storage-component", "me-" .. s.size .. "-storage-cell" }
		for _, r in ipairs(s.recipes or {}) do recipes[#recipes + 1] = r end
		tech_n(storage, prerequisites, s.packs, s.count, recipes)
		tech_n("me-fluid-storage-" .. s.size, { s.fbefore, storage }, s.packs, s.fluid_count,
			{ "me-" .. s.size .. "-fluid-storage-cell" })
		tech_n("me-crafting-storage-" .. s.size, { crafting_before, storage }, s.packs, s.crafting_count,
			with_blocks({}, { "me-" .. s.size .. "-crafting-storage" }))
		crafting_before = "me-crafting-storage-" .. s.size
	end
	tech_n("me-storage-singularity", { "me-storage-16384k", "me-quantum-bridge", "quantium", "uev-materials", "uhv-machines" },
		10, 225, { "me-singularity-storage-cell" })
	tech_n("me-crafting-storage-singularity", { "me-crafting-storage-16384k", "me-storage-singularity", "exotic-processor-mainframes",
		"umv-materials", "uiv-components", "uiv-machines" }, 12, 120, with_blocks({}, { "me-singularity-crafting-storage" }))
	--- the accelerators of 4 to 64 cores (IV to ZPM circuits, up to the LuV assembler) and of 256 to 4096 cores (UV to UEV
	--- circuits, up to the UHV assembler)
	tech_n("me-crafting-accelerators", { "me-quantum-crafting", "advanced-smds" }, 7, 1200, with_blocks({},
		{ "me-crafting-accelerator-4x", "me-crafting-accelerator-16x", "me-crafting-accelerator-64x" }))
	tech_n("me-crafting-accelerators-2", { "me-crafting-accelerators", "bio-processor-mainframes", "uhv-machines" }, 10, 250,
		with_blocks({}, { "me-crafting-accelerator-256x", "me-crafting-accelerator-1024x", "me-crafting-accelerator-4096x" }))
end
