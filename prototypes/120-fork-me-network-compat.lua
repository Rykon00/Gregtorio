--------------------------------------------------------------------------------
--- FORK: ME NETWORK ON GREGTORIO'S TIERS (issue #83, docs/SPLIT.md)
---
--- The ME network (issues #68, #38, #80) is the mod me-network since issue #83: its entities, items, technologies,
--- runtime and graphics live there, with vanilla recipes and vanilla science. This file puts it back on Gregtorio's
--- tiers through me-network's data-stage API (ME_NETWORK, its docs/API.md), so a Gregtorio game is what it was:
---   * the GT recipes of every ME item (the create_item calls of 13-mv-age-item.lua and of the old 120-122, recipe
---     only: the items are me-network's), the subgroups of the storage components and the housing;
---   * the standalone 1k component recipe removed (Gregtorio has the -lv and -nand recipes of upstream);
---   * the nine ME technologies with Gregtorio's prerequisites, science and unlocks; logistic-system unlocks the
---     ME Chest and the ME Drive;
---   * the Molecular Assembler built from the HV assembling machine (the LV to EV assembling categories, 6x speed).
--- The one-time hand-over of the ME state of older saves is scripts/fork-me-handover.lua.
--------------------------------------------------------------------------------

local ME = ME_NETWORK

--- the recipe Gregtorio's create_item made for an item (03-helper-functions-module.lua), without touching the item
local function recipe_of(def)
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



--------------------------------------------------------------------------------
--- UPSTREAM ITEMS (from 13-mv-age-item.lua, unchanged)
--------------------------------------------------------------------------------

ME.remove_recipe("me-1k-storage-component")

upstream_item{
	name = "basic-storage-housing",
	category = "lv-assembling-machine-recipes",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4},
		{type = "item", name = "steel-screw", amount = 4},
		{type = "item", name = "glass", amount = 1},
    }
}

upstream_item{
	name = "fluix-cable",
	category = "mv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "quartz-fiber", amount = 3},
		{type = "item", name = "fluix-dust", amount = 2},
    },
	results = {
		{type = "item", name = "fluix-cable", amount = 3}
    }
}

upstream_item{
	name = "me-interface",
	ingredients = {
      {type = "item", name = "mv-machine-casing", amount = 1},
      {type = "item", name = "aluminium-plate", amount = 4},
      {type = "item", name = "fluix-cable", amount = 2},
      {type = "item", name = "formation-core", amount = 1},
      {type = "item", name = "annihilation-core", amount = 1},
    }
}

upstream_item{
	name = "me-drive",
	ingredients = {
		{type = "item", name = "aluminium-plate", amount = 4},
		{type = "item", name = "me-chest", amount = 1},
		{type = "item", name = "fluix-cable", amount = 2},
		{type = "item", name = "mv-emitter", amount = 1},
		{type = "item", name = "processing-unit", amount = 1},
    }
}

upstream_item{
	name = "me-chest",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4},
		{type = "item", name = "steel-chest", amount = 1},
		{type = "item", name = "fluix-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
    }
}

upstream_item{
	name = "me-controller",
	ingredients = {
		{type = "item", name = "aluminium-plate", amount = 4},
		{type = "item", name = "fluix-block", amount = 1},
		{type = "item", name = "engineering-processor", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
    }
}

upstream_item{
	name = "me-terminal",
	ingredients = {
		{type = "item", name = "nether-quartz-rod", amount = 4},
		{type = "item", name = "certus-quartz-screw", amount = 4},
		{type = "item", name = "computer-monitor", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
    }
}

upstream_item{
	name = "me-1k-storage-component",
	recipe_name = "me-1k-storage-component-lv",
	category = "lv-circuit-assembler-recipes",
	energy_required = 5,
	ingredients = {
      {type = "item", name = "resin-printed-circuit-board", amount = 1},
      {type = "item", name = "certus-quartz-dust", amount = 2},
      {type = "item", name = "electronic-circuit", amount = 2},
      {type = "item", name = "logic-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-1k-storage-component", amount = 1}
    }
}
create_recipe{
	recipe_name = "me-1k-storage-component-nand",
	category = "lv-circuit-assembler-recipes",
	energy_required = 5,
	ingredients = {
		{type = "item", name = "resin-printed-circuit-board", amount = 1},
		{type = "item", name = "certus-quartz-dust", amount = 2},
		{type = "item", name = "nand-chip", amount = 2},
		{type = "item", name = "logic-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-1k-storage-component", amount = 1}
    }
}

upstream_item{
	name = "me-4k-storage-component",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "phenolic-printed-circuit-board", amount = 1},
		{type = "item", name = "nand-chip", amount = 16 },
		{type = "item", name = "electronic-circuit", amount = 4 },
		{type = "item", name = "logic-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    }
}

upstream_item{
	name = "me-16k-storage-component",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "plastic-printed-circuit-board", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 16 },
		{type = "item", name = "advanced-circuit", amount = 4 },
		{type = "item", name = "calculation-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    }
}

upstream_item{
	name = "me-64k-storage-component",
	category = "hv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
      {type = "item", name = "epoxy-printed-circuit-board", amount = 1},
      {type = "item", name = "advanced-circuit", amount = 16},
      {type = "item", name = "processing-unit", amount = 4},
      {type = "item", name = "calculation-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-64k-storage-component", amount = 1}
    }
}

upstream_item{
	name = "me-256k-storage-component",
	category = "ev-circuit-assembler-recipes",
	energy_required = 80,
	ingredients = {
      {type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1},
      {type = "item", name = "processing-unit", amount = 16},
      {type = "item", name = "ev-circuit", amount = 4},
      {type = "item", name = "engineering-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-256k-storage-component", amount = 1}
    }
}

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
		ingredients = {
			{ type = "item", name = bus.core, amount = 1 },
			{ type = "item", name = "mv-piston", amount = 1 },
			{ type = "item", name = "aluminium-plate", amount = 2 },
			{ type = "item", name = "fluix-cable", amount = 2 },
		},
	}
end

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
	ingredients = {
		{ type = "item", name = "me-interface", amount = 1 },
		{ type = "item", name = "mv-piston", amount = 2 },
		{ type = "item", name = "aluminium-plate", amount = 2 },
		{ type = "item", name = "fluix-cable", amount = 2 },
	},
}



--------------------------------------------------------------------------------
--- THE RECIPES OF THE OLD 121 (autocrafting) AND THE MOLECULAR ASSEMBLER
--------------------------------------------------------------------------------

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

--- issue #80: AE2's blank pattern (quartz glass, certus quartz, iron) in Gregtorio's materials, cheap (LV assembler)
recipe_of{
	name = "me-blank-pattern",
	category = "lv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "e1",
	energy_required = 5 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "glass", amount = 2 },
		{ type = "item", name = "certus-quartz", amount = 1 },
		{ type = "item", name = "aluminium-plate", amount = 1 },
		{ type = "item", name = "fluix-cable", amount = 1 },
	},
}

recipe_of{
	name = "me-molecular-assembler",
	category = "hv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "f",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "hv-robot-arm", amount = 2 },
		{ type = "item", name = "hv-emitter", amount = 1 },
		{ type = "item", name = "engineering-processor", amount = 2 },
		{ type = "item", name = "fluix-cable", amount = 4 },
	},
}

recipe_of{
	name = "me-crafting-cpu",
	category = "ev-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "g",
	energy_required = 10 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "me-controller", amount = 1 },
		{ type = "item", name = "me-64k-storage-component", amount = 2 },     -- issue #68: cells carry contents, components do not
		{ type = "item", name = "processing-unit", amount = 4 },
		{ type = "item", name = "fluix-cable", amount = 8 },
	},
}

recipe_of{
	name = "me-co-processing-cpu",
	category = "iv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "g2",
	energy_required = 10 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "me-crafting-cpu", amount = 1 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "me-256k-storage-component", amount = 2 },
		{ type = "item", name = "acceleration-card", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 4 },
		{ type = "item", name = "fluix-cable", amount = 16 },
	},
}

recipe_of{
	name = "me-quantum-crafting-cpu",
	category = "luv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "g3",
	energy_required = 10 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "me-co-processing-cpu", amount = 1 },
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "luv-emitter", amount = 2 },
		{ type = "item", name = "acceleration-card", amount = 8 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "fluix-cable", amount = 32 },
	},
}

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
--- THE RECIPES OF THE OLD 122 (fluids)
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

recipe_of{
	name = "me-fluid-interface",
	category = "hv-assembling-machine-recipes",
	subgroup = "fork-me-network",
	order = "h",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "me-interface", amount = 1 },
		{ type = "item", name = "hv-pump", amount = 1 },
		{ type = "item", name = "pipe", amount = 4 },
		{ type = "item", name = "fluix-cable", amount = 2 },
	},
}

for _, bus in pairs({
	{ name = "me-fluid-import-bus", base = "me-import-bus", order = "h2" },
	{ name = "me-fluid-export-bus", base = "me-export-bus", order = "h3" },
	{ name = "me-fluid-storage-bus", base = "me-storage-bus", order = "h4" },
}) do
	recipe_of{
		name = bus.name,
		category = "hv-assembling-machine-recipes",
		subgroup = "fork-me-network",
		order = bus.order,
		energy_required = 10 * HV_SPEED,
		ingredients = {
			{ type = "item", name = bus.base, amount = 1 },
			{ type = "item", name = "hv-pump", amount = 1 },
			{ type = "item", name = "pipe", amount = 2 },
		},
	}
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

--- the drive chassis (now the ME Drive itself) and the chest it is made from
fork_add_unlock("logistic-system", "me-chest")
fork_add_unlock("logistic-system", "me-drive")

--- MV: basic cells, terminal, buses (cable, controller and interface come with Applied Energistics Components)
tech("me-network", { "logistic-system" }, 3, 400, {
	"me-terminal", "computer-monitor", "certus-quartz-bolt", "certus-quartz-screw",
	"me-1k-storage-cell", "me-4k-storage-cell", "me-16k-storage-cell", "me-import-bus", "me-export-bus",
	"me-underground-cable", "me-storage-bus",
})
--- EV: 64k (the component needs epoxy boards)
tech("me-storage-64k", { "me-network", "nanoprocessors", "advanced-hv-machines" }, 5, 800,
	{ "me-64k-storage-component", "me-64k-storage-cell" })
--- IV: 256k and the cards (platinum), fiber-reinforced boards for the component
tech("me-storage-256k", { "me-storage-64k", "industrial-precision-lathe", "ev-machines" }, 6, 1000, {
	"me-256k-storage-component", "advanced-card", "acceleration-card", "annealed-copper-foil",
	"fiber-reinforced-epoxy-sheet", "fiber-reinforced-circuit-board", "fiber-reinforced-printed-circuit-board",
	"me-256k-storage-cell",
})

--- EV: autocrafting (the CPU needs 64k components)
tech("me-autocrafting", { "me-storage-64k" }, 5, 600,
	{ "me-pattern-provider", "me-blank-pattern", "me-molecular-assembler", "me-crafting-cpu" }, SEVEN)
--- issue #38: level maintainer and circuit interface (EV), bigger CPUs at IV (256k components and acceleration
--- cards, IV components) and LuV (LuV components and hull)
tech("me-automation", { "me-autocrafting", "circuit-network" }, 5, 800,
	{ "me-level-maintainer", "me-circuit-interface" }, SEVEN)
tech("me-co-processing", { "me-autocrafting", "me-storage-256k", "iv-components" }, 6, 1200,
	{ "me-co-processing-cpu" }, SEVEN)
tech("me-quantum-crafting", { "me-co-processing", "luv-machines" }, 7, 1500, { "me-quantum-crafting-cpu" }, SEVEN)

--- EV: fluid cells up to 64k, the fluid interface, the fluid buses (import, export, storage); IV: 256k fluid cells
tech("me-fluid-storage", { "me-autocrafting" }, 5, 600, {
	"me-fluid-interface", "me-fluid-import-bus", "me-fluid-export-bus", "me-fluid-storage-bus",
	"me-1k-fluid-storage-cell", "me-4k-fluid-storage-cell", "me-16k-fluid-storage-cell", "me-64k-fluid-storage-cell",
})
tech("me-fluid-storage-256k", { "me-fluid-storage", "me-storage-256k" }, 6, 800, { "me-256k-fluid-storage-cell" })
