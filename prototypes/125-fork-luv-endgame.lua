--------------------------------------------------------------------------------
--- FORK LuV ENDGAME (roadmap phase 1)
--- Finishes the LuV tier on top of 110-fork-luv.lua. Everything here is researched with
--- LuV science (space science pack) and leads to the ZPM science pack:
---   * naquadah ore line (ore from the end microminer, neutron activator, naquadah, trinium,
---     naquadah alloy, osmiridium)
---   * bacterial vat and mutagen
---   * circuit assembly line and crystal processors
---   * fusion reactor MK1 with its first plasmas (helium, boron, calcium, neon) and europium
--- Based on the drafts in 21-luv-age-item.lua and 19-iv-age-item.lua; this file only adds
--- what was missing (items, fluids, machines, technologies) and fixes draft typos.
--- Everything that still needs later tiers (crystal mainframe, fusion MK2+, force plasma)
--- stays a draft and is hidden by the draft guard in 199-fork-finalize.lua.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local FORK_ICON_PATH = "__gregtorio-continued__/graphics/icons/fork/"
local FLUID_ICON_PATH = "__gregtorio-continued__/graphics/fluids/"

local function set_ingredient(recipe_name, from, to)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-LUV2: missing recipe: " .. recipe_name) return end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.name == from then i.name = to end
		end
	end
end

local function set_category(recipe_name, category)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-LUV2: missing recipe: " .. recipe_name) return end
	r.category = category
end

--- Fluid like the ones in 06-fluids-module.lua (whose helper is local), colors given directly
local function fork_fluid(name, icon, color)
	local c = { r = color[1], g = color[2], b = color[3] }
	data:extend({ {
		type = "fluid",
		name = name,
		default_temperature = 1000,
		max_temperature = 1000,
		heat_capacity = "0.1kJ",
		base_color = c,
		flow_color = c,
		icon = FLUID_ICON_PATH .. icon .. ".png",
		icon_size = 32,
		order = "a[fluid]-z[" .. name .. "]",
		pressure_to_speed_ratio = 0.4,
		flow_to_energy_ratio = 0.59,
		auto_barrel = false,
	} })
end

local function category(name)
	if not data.raw["recipe-category"][name] then recipe_category_and_subgroup(name) end
end



--------------------------------------------------------------------------------
--- MULTIBLOCKS
--- Copies of an existing machine with their own size, fluid ports and generated sprites
--- (tools/gen_sprites.py, MULTIBLOCKS). The items already exist upstream except the
--- neutron activator.
--------------------------------------------------------------------------------

---   def = { name, source, size = {w, h} (nil = size of the source), ports (nil = ports of the source),
---           categories, speed, energy, subgroup }
local function make_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-LUV2: missing source machine " .. def.source) return end
	local item = data.raw.item[def.name]
	local m = table.deepcopy(src)
	m.name = def.name
	m.icons = nil
	m.icon = item and item.icon or (FORK_ICON_PATH .. def.name .. ".png")
	m.icon_size = 32
	m.minable = { mining_time = 1, result = def.name }
	m.crafting_categories = def.categories
	m.crafting_speed = def.speed
	m.energy_usage = def.energy
	m.fast_replaceable_group = "fr-" .. def.name
	m.next_upgrade = nil
	local w = src.selection_box[2][1] - src.selection_box[1][1]
	local h = src.selection_box[2][2] - src.selection_box[1][2]
	if def.size then
		w, h = def.size[1], def.size[2]
		m.collision_box = { { -w / 2 + 0.2, -h / 2 + 0.2 }, { w / 2 - 0.2, h / 2 - 0.2 } }
		m.selection_box = { { -w / 2, -h / 2 }, { w / 2, h / 2 } }
	end
	if def.ports then
		m.fluid_boxes = def.ports
		for _, fb in pairs(m.fluid_boxes) do
			fb.pipe_covers = pipecoverspictures()
			fb.pipe_picture = assembler2pipepictures()
		end
		m.fluid_boxes_off_when_no_fluid_recipe = true
	end
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-idle.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-working.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ m })

	if not item then
		item = { type = "item", name = def.name, icon = m.icon, icon_size = 32 }
		data:extend({ item })
	end
	item.place_result = def.name
	item.subgroup = def.subgroup or "subgroup-luv-age-multiblocks"
	item.stack_size = 10
end



--------------------------------------------------------------------------------
--- 1) NAQUADAH ORE LINE
--- Upstream (19-iv-age-item.lua) already has the GoodGenerator naquadah line, but:
---   * no ore source, no neutron activator, no P-507 or ether to start the loops
---   * two recipes share a name ("naquadah-rich-solution"), so the neutron activator step
---     that makes naquadah-rich-solution was overwritten -> re-added under its own name
--------------------------------------------------------------------------------

--- The end (tier three microminer) has a naquadah vein (see 52-microverse-module.lua)
create_recipe{
	name = "microminer-naquadah",
	category = "lv-assembling-machine-recipes",
	energy_required = 8,
	subgroup = "subgroup-microminer-t3",
	ingredients = {
		{ type = "item", name = "tier-three-microminer-output", amount = 1 },
	},
	results = {
		{ type = "item", name = "raw-naquadah", amount = 24 },
		{ type = "item", name = "compressed-end-stone", amount = 8 },
	},
	main_product = "raw-naquadah",
}

--- Neutron activator (GoodGenerator): the machine for the naquadah line
category("neutron-activator-recipes")
make_multiblock{
	name = "neutron-activator", source = "iv-chemical-bath",
	categories = { "neutron-activator-recipes" },
	speed = 1, energy = EU16_IV,
}
create_recipe{
	name = "neutron-activator",
	category = "iv-assembling-machine-recipes",
	energy_required = 60 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 4 },
		{ type = "item", name = "iv-pump", amount = 2 },
		{ type = "item", name = "thick-neutron-reflector", amount = 4 },
		{ type = "item", name = "lead-plate", amount = 32 },
	},
	results = { { type = "item", name = "neutron-activator", amount = 1 } },
}

--- The overwritten neutron activator step (naquadah adamantium solution -> naquadah rich solution)
create_recipe{
	name = "naquadah-adamantium-solution-activation",
	category = "neutron-activator-recipes",
	energy_required = 5,
	subgroup = "subgroup-neutron-activator-recipes",
	ingredients = {
		{ type = "fluid", name = "naquadah-adamantium-solution", amount = 300 },
	},
	results = {
		{ type = "item", name = "adamantine-dust", amount = 4 },
		{ type = "item", name = "naquadah-oxide-mixture", amount = 2 },
		{ type = "item", name = "concentrated-enriched-naquadah-sludge", amount = 1 },
		{ type = "fluid", name = "naquadah-rich-solution", amount = 200 },
	},
	main_product = "naquadah-rich-solution",
}

--- P-507 (extractant) is recycled by the line but had no recipe to start with
create_recipe{
	name = "p507",
	category = "iv-chemical-reactor-recipes",
	energy_required = 50,
	ingredients = {
		{ type = "fluid", name = "ethanol", amount = 1000 },
		{ type = "fluid", name = "phosphoric-acid", amount = 500 },
	},
	results = {
		{ type = "fluid", name = "p507", amount = 500 },
		{ type = "fluid", name = "water", amount = 500 },
	},
	main_product = "p507",
}

--- Ether for the antimony pentachloride step, also recycled
create_recipe{
	name = "diethyl-ether",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "fluid", name = "ethanol", amount = 1000 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "ether", amount = 500 },
		{ type = "fluid", name = "diluted-sulfuric-acid", amount = 100 },
	},
	main_product = "ether",
}

--- Trinium, naquadah alloy and osmiridium (their upstream definitions are commented out)
create_ingot("naquadah-alloy", nil, nil, {
		{ type = "item", name = "naquadah-dust", amount = 2 },
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "item", name = "trinium-dust", amount = 1 },
	},
	4, "luv", nil, { type = "fluid", name = "argon", amount = 5 },
	"iv", 58.65 * IV_SPEED, true, false, true, LUV_SPEED * 100.5, true, true)
create_metal_parts{ material = "naquadah-alloy", speed = NAQUADAH_ALLOY_SPEED or 20, make_plate = true, make_dense_plate = true }
create_metal_parts{ material = "trinium", speed = TRINIUM_SPEED or 20, make_plate = true }

create_item{
	name = "hot-osmiridium-ingot",
	category = "luv-electric-blast-furnace-recipes",
	energy_required = 75 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "osmiridium-dust", amount = 1 },
		{ type = "fluid", name = "argon", amount = 5 },
	},
}
create_item{
	name = "osmiridium-ingot",
	category = "iv-vacuum-freezer-recipes",
	energy_required = 20 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hot-osmiridium-ingot", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 50 },
	},
	results = {
		{ type = "item", name = "osmiridium-ingot", amount = 1 },
		{ type = "fluid", name = "helium", amount = 25 },
	},
	main_product = "osmiridium-ingot",
}
create_metal_parts{ material = "osmiridium", speed = OSMIRIDIUM_SPEED or 20, make_plate = true, make_dense_plate = true }



--------------------------------------------------------------------------------
--- 2) BACTERIAL VAT AND MUTAGEN
--- GTNH (bartworks) breeds cultures in petri dishes and boosts the vat with radiation.
--- Here: growth medium -> bacterial sludge (vat) -> enriched sludge (vat + uranium)
--- -> mutagen (distillation). No petri dishes.
--------------------------------------------------------------------------------

category("bacterial-vat-recipes")
fork_fluid("growth-medium", "spackled-mint-green-fluid", { 0.55, 0.80, 0.55 })
fork_fluid("bacterial-sludge", "olive-fluid", { 0.40, 0.45, 0.10 })
fork_fluid("enriched-bacterial-sludge", "rich-green-fluid", { 0.20, 0.65, 0.20 })
fork_fluid("mutagen", "deep-pink-fluid", { 0.78, 0.12, 0.78 })

--- Missing casing names in the draft
set_ingredient("bacterial-vat", "clean-stainless-steel-machine-casing", "clean-stainless-steel-casing")
create_item{
	name = "titanium-reinforced-borosilicate-glass-block",
	icon = FORK_ICON_PATH .. "titanium-reinforced-borosilicate-glass-block.png",
	category = "ev-assembling-machine-recipes",
	energy_required = 10 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "borosilicate-glass-block", amount = 1 },
		{ type = "item", name = "titanium-plate", amount = 4 },
	},
}
--- The draft had no category/energy
do
	local r = data.raw.recipe["bacterial-vat"]
	if r then r.category = "iv-assembling-machine-recipes"; r.energy_required = 120 * IV_SPEED end
	r = data.raw.recipe["bacterial-vat-controller"]
	if r then r.category = "ev-assembling-machine-recipes"; r.energy_required = 60 * EV_SPEED end
end

make_multiblock{
	name = "bacterial-vat", source = "hv-large-chemical-reactor",
	categories = { "bacterial-vat-recipes" },
	speed = 1, energy = EU16_IV,
}

create_recipe{
	name = "growth-medium",
	category = "iv-mixer-recipes",
	energy_required = 20 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tricalcium-phosphate", amount = 4 },
		{ type = "fluid", name = "biomass", amount = 500 },
		{ type = "fluid", name = "distilled-water", amount = 500 },
	},
	results = { { type = "fluid", name = "growth-medium", amount = 1000 } },
}
create_recipe{
	name = "bacterial-sludge",
	category = "bacterial-vat-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "fluid", name = "growth-medium", amount = 1000 },
		{ type = "fluid", name = "distilled-water", amount = 1000 },
	},
	results = { { type = "fluid", name = "bacterial-sludge", amount = 1000 } },
}
create_recipe{
	name = "enriched-bacterial-sludge",
	category = "bacterial-vat-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "uranium-238-dust", amount = 1 },
		{ type = "fluid", name = "bacterial-sludge", amount = 1000 },
	},
	results = { { type = "fluid", name = "enriched-bacterial-sludge", amount = 500 } },
}
create_recipe{
	name = "mutagen",
	category = "iv-distillation-recipes",
	energy_required = 20 * IV_SPEED,
	ingredients = {
		{ type = "fluid", name = "enriched-bacterial-sludge", amount = 1000 },
	},
	results = {
		{ type = "fluid", name = "mutagen", amount = 250 },
		{ type = "fluid", name = "distilled-water", amount = 500 },
	},
	main_product = "mutagen",
}



--------------------------------------------------------------------------------
--- 3) CIRCUIT ASSEMBLY LINE AND CRYSTAL PROCESSORS
--------------------------------------------------------------------------------

category("luv-circuit-assembly-line-recipes")

--- The circuit assembly line also does every circuit assembler recipe up to LuV, twice as fast
do
	local cats = { "luv-circuit-assembly-line-recipes" }
	for _, t in pairs({ "lv", "mv", "hv", "ev", "iv", "luv" }) do
		local c = t .. "-circuit-assembler-recipes"
		if data.raw["recipe-category"][c] then cats[#cats + 1] = c end
	end
	make_multiblock{
		name = "luv-circuit-assembly-line", source = "luv-assembly-line",
		categories = cats,
		speed = 2 * LUV_SPEED, energy = EU16_LuV,
	}
end
--- The draft recipes of the controller and the machine
set_ingredient("circuit-assembly-line-controller", "zpm-circuit", "luv-circuit")
do
	local c = data.raw.recipe["circuit-assembly-line-controller"]
	if c then c.energy_required = 120 * LUV_SPEED end
	local r = data.raw.recipe["luv-circuit-assembly-line"]
	if r then r.category = "luv-assembling-machine-recipes"; r.energy_required = 120 * LUV_SPEED end
end

--- Draft typo: "hv-maceration-recipes" -> the macerator category
set_category("raw-crystal-chip-part", "hv-macerator-recipes")

--- 4x niobium-titanium wire (crystal processors)
create_item{
	name = "niobium-titanium-wire-4x",
	category = "lv-wiremill-recipes",
	energy_required = 5,
	ingredients = { { type = "item", name = "niobium-titanium-ingot", amount = 2 } },
}



--------------------------------------------------------------------------------
--- 4) FUSION REACTOR MK1 AND THE FIRST PLASMAS
--------------------------------------------------------------------------------

category("mk1-fusion-reactor-recipes")
for _, f in pairs({
	{ "molten-trinium", "spackled-gray-fluid", { 0.55, 0.55, 0.60 } },
	{ "molten-neodymium", "spackled-gray-fluid", { 0.40, 0.40, 0.40 } },
	{ "molten-europium", "light-pink-fluid", { 0.78, 0.53, 0.53 } },
	{ "molten-gallium", "silver-blue-spackled-fluid", { 0.70, 0.75, 0.85 } },
	{ "molten-lithium", "nearly-white-fluid", { 0.90, 0.90, 0.90 } },
	{ "molten-magnesium", "light-pink-fluid", { 0.90, 0.70, 0.70 } },
	{ "molten-duranium", "spackled-yellow-fluid", { 0.95, 0.95, 0.40 } },
	{ "molten-sunnarium", "spackled-orange-fluid", { 1.00, 0.80, 0.20 } },
	{ "helium-plasma", "cryogenic-helium", { 0.94, 0.94, 0.60 } },
	{ "boron-plasma", "olive-fluid", { 0.60, 0.60, 0.30 } },
	{ "calcium-plasma", "light-orange-fluid", { 0.83, 0.56, 0.23 } },
	{ "neon-plasma", "neon", { 1.00, 0.40, 0.30 } },
}) do
	if not data.raw.fluid[f[1]] then fork_fluid(f[1], f[2], f[3]) end
end

create_metal_parts{ material = "niobium-titanium", speed = NIOBIUM_TITANIUM_SPEED or 10, make_foil = true }

--- The draft used a superconductor wire that does not exist -> YBCO (the LuV superconductor)
set_ingredient("fusion-reactor-mk1-controller", "barium-titanate-cuproxide-superconductive-wire", "yttrium-barium-cuprate-cable")
--- The MK1 reactor needs its controller (the draft called it "computer")
set_ingredient("fusion-reactor-mk1", "fusion-reactor-computer-mk1", "fusion-reactor-mk1-controller")
do
	local r = data.raw.recipe["fusion-reactor-mk1"]
	if r then r.category = "luv-assembling-machine-recipes"; r.energy_required = 300 * LUV_SPEED end
	r = data.raw.recipe["fusion-coil-block"]
	if r then r.category = "luv-assembling-machine-recipes"; r.energy_required = 50 * LUV_SPEED end
end

--- Fusion reactor: 9x9, two fluid inputs (north) and one output (south)
make_multiblock{
	name = "fusion-reactor-mk1", source = "luv-assembly-line", size = { 9, 9 },
	ports = {
		fluid_port(-2, -4, "input", defines.direction.north),
		fluid_port( 2, -4, "input", defines.direction.north),
		fluid_port( 0,  4, "output", defines.direction.south),
	},
	categories = { "mk1-fusion-reactor-recipes", "luv-fusion-reactor-recipes" },
	speed = LUV_SPEED, energy = "40.96MW",
}

--- Fusion fuels: tritium from deuterium and helium-3 from end stone (both like GT5); the helium-3
--- yield and time are set in 136-fork-power.lua (plasma balance, issue #32)
create_recipe{
	name = "deuterium-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = 8 * HV_SPEED,
	ingredients = { { type = "fluid", name = "deuterium", amount = 160 } },
	results = { { type = "fluid", name = "tritium", amount = 40 } },
}
create_recipe{
	name = "end-stone-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = 10 * HV_SPEED,
	ingredients = { { type = "item", name = "compressed-end-stone", amount = 1 } },
	results = {
		{ type = "fluid", name = "helium-3", amount = 100 },
		{ type = "item", name = "stone-dust", amount = 4 },
		{ type = "item", name = "tungstate-dust", amount = 1, probability = 0.1 },
	},
	main_product = "helium-3",
}

--- Molten metals for the fusion recipes
create_recipe{
	name = "molten-neodymium",
	category = "iv-extractor-recipes",
	energy_required = 1.2 * IV_SPEED,
	ingredients = { { type = "item", name = "neodymium-ingot", amount = 1 } },
	results = { { type = "fluid", name = "molten-neodymium", amount = 14.4 } },
}
create_recipe{
	name = "molten-trinium",
	category = "iv-extractor-recipes",
	energy_required = 1.2 * IV_SPEED,
	ingredients = { { type = "item", name = "trinium-ingot", amount = 1 } },
	results = { { type = "fluid", name = "molten-trinium", amount = 14.4 } },
}



--------------------------------------------------------------------------------
--- TECHNOLOGIES (LuV science)
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack" }
	local amounts = { SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
	local out = {}
	for i = 1, n do
		out[#out + 1] = { packs[i], amounts[#amounts - n + i] }
	end
	return out
end

local function tech(def)
	local effects = {}
	for _, r in pairs(def.recipes) do
		if data.raw.recipe[r] then
			effects[#effects + 1] = { type = "unlock-recipe", recipe = r }
			data.raw.recipe[r].enabled = false
		else
			log("FORK-LUV2: tech " .. def.name .. ": missing recipe " .. r)
		end
	end
	data:extend({ {
		type = "technology",
		name = def.name,
		icon = "__gregtorio-continued__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = def.prerequisites,
		unit = { count = def.count, ingredients = sci(7), time = def.time or 60 },
	} })
end

--- Recipes that an earlier tech unlocked although they belong here
local function move_unlock(from_tech, recipe)
	local t = data.raw.technology[from_tech]
	if not t then return end
	local keep = {}
	for _, e in pairs(t.effects or {}) do
		if not (e.type == "unlock-recipe" and e.recipe == recipe) then keep[#keep + 1] = e end
	end
	t.effects = keep
end
move_unlock("luv-energy-hatches", "superconducting-coil-block")
--- ZPM circuits (quantum mainframe) were only unlocked by the auto-unlock in 199-fork-finalize.lua,
--- which skips them as soon as any other recipe (the crystal supercomputer) makes them
fork_add_unlock("luv-components", "quantum-processor-mainframe")
--- Same for the end stone microminer (the naquadah microminer also yields end stone)
fork_add_unlock("end-steel", "microminer-end-stone")

tech{
	name = "naquadah-processing", prerequisites = { "luv-machines" }, count = 1500,
	recipes = {
		"microminer-naquadah", "crushed-naquadah", "naquadah-oxide-mixture", "centrifuging-crushed-naquadah",
		"diethyl-ether", "antimony-trichloride-solution", "antimony-pentachloride-solution", "antimony-pentachloride",
		"antimony-pentafluoride", "fluoroantimonic-acid",
		"low-quality-naquadah-emulsion", "titanium-trifluoride-processing", "low-quality-naquadah-solution",
		"p507", "naquadah-adamantium-solution", "fluorine-rich-waste-liquid-processing", "waste-liquid-processing",
		"neutron-activator", "naquadah-adamantium-solution-activation", "adamantium-dust",
		"naquadah-rich-solution", "hot-naquadah-ingot", "naquadah-ingot", "naquadah-dust", "sodium-oxide-electrolysis",
	},
}
tech{
	name = "enriched-naquadah", prerequisites = { "naquadah-processing" }, count = 1500,
	recipes = {
		"concentrated-enriched-naquadah-sludge", "enriched-naquadah-sulphate", "sodium-sulfate-electrolysis",
		"hot-enriched-naquadah-ingot", "enriched-naquadah-ingot", "enriched-naquadah-dust",
		"low-quality-naquadria-sulphate", "trinium-dust", "hot-trinium-ingot", "trinium-ingot", "trinium-plate",
		"low-quality-naquadria-sulphate-solution", "low-quality-naquadria-sulphate-distillation",
		"naquadria-sulphate", "naquadria-dust",
	},
}
tech{
	name = "naquadah-alloy", prerequisites = { "enriched-naquadah" }, count = 2000,
	recipes = {
		"molten-naquadah-alloy", "solidify-naquadah-alloy-ingot", "naquadah-alloy-plate", "dense-naquadah-alloy-plate",
		"osmiridium-dust", "hot-osmiridium-ingot", "osmiridium-ingot", "osmiridium-plate", "dense-osmiridium-plate",
	},
}
tech{
	name = "bacterial-vat", prerequisites = { "luv-machines" }, count = 1500,
	recipes = {
		"titanium-reinforced-borosilicate-glass-block", "bacterial-vat-controller", "bacterial-vat",
		"growth-medium", "bacterial-sludge", "enriched-bacterial-sludge", "mutagen",
	},
}
tech{
	name = "circuit-assembly-line", prerequisites = { "luv-energy-hatches" }, count = 2000,
	recipes = { "circuit-assembly-line-controller", "luv-circuit-assembly-line" },
}
tech{
	name = "crystal-processors", prerequisites = { "bacterial-vat", "circuit-assembly-line" }, count = 2500,
	recipes = {
		"block-of-emerald", "emerald-plate", "raw-crystal-chip", "raw-crystal-chip-part", "raw-crystal-chip-loop",
		"engraved-crystal-chip", "crystal-cpu", "niobium-titanium-wire-4x",
		"nano-cpu-chip-wrap", "ram-chip-wrap", "nor-memory-chip-wrap", "nand-memory-chip-wrap",
		"advanced-smd-capacitor-wrap", "advanced-smd-transistor-wrap", "advanced-smd-inductor-wrap",
		"crystal-processor", "crystal-processor-assembly", "crystal-processor-supercomputer",
	},
}
tech{
	name = "fusion-reactor-mk1", prerequisites = { "naquadah-alloy", "luv-energy-hatches" }, count = 3000,
	recipes = {
		"niobium-titanium-foil", "molten-trinium", "superconducting-coil-block",
		"iridium-neutron-reflector", "fusion-coil-block", "fusion-reactor-mk1-controller", "fusion-reactor-mk1",
	},
}
tech{
	name = "fusion-plasmas-mk1", prerequisites = { "fusion-reactor-mk1" }, count = 3000,
	recipes = {
		"deuterium-centrifuging", "end-stone-centrifuging", "helium-plasma-first", "helium-plasma-second",
		"molten-neodymium", "molten-europium", "europium-ingot",
		"molten-gallium", "molten-duranium", "molten-lithium", "boron-plasma",
		"molten-magnesium", "calcium-plasma", "neon-plasma", "molten-sunnarium",
	},
}

--- ZPM science needs the finished LuV tier
do
	local t = data.raw.technology["metallurgic-science-pack"]
	if t then
		t.prerequisites = t.prerequisites or {}
		for _, p in pairs({ "fusion-plasmas-mk1", "crystal-processors" }) do
			table.insert(t.prerequisites, p)
		end
	end
end
