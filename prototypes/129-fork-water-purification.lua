--------------------------------------------------------------------------------
--- FORK WATER PURIFICATION (roadmap phase 5a, side quest)
--- The water line of GT (purified water grades 1-8) is a draft in 21-luv-age-item.lua that is
--- commented out (eight plant units with linkage blocks, recipes without wrappers). Phase 5a
--- needs it only as far as the doped wafers and the power ICs: grades 1 to 6.
---   * one water purification plant (5x5) instead of one multiblock per grade; the grades are its
---     recipes: water -> 1 (carbon filter) -> 2 (ozone) -> 3 (polyaluminium chloride)
---     -> 4 (acid/base) -> 5 (helium plasma) -> 6 (krypton plasma as the UV light); 90 % yield per grade like GT
---   * europium and americium doped boules and wafers (the boules had no recipe; they cut the wafers
---     with grade 4 and 6 water, the drafts in 11-lv-age-item.lua)
---   * NPIC, PPIC and QPIC wafers and chips. They replace the UHPIC workarounds of phases 2 to 4:
---     the ZPM, UV and UHV energy hatches, the MK2 and MK3 fusion controllers
--- Grades 7 (degasifier) and 8 (quark extraction) and the FPIC/APIC chips stay open: nothing in
--- UEV/UIV needs them.
--- Deviations from GT: no linkage blocks and no separate units, no plant casings (chemically inert,
--- filter and PTFE pipe casings instead), the flocculation waste, the lenses and the catalyst
--- items are left out, super coolant is not needed (helium plasma alone heats grade 5).
--- Wafers give 1 wafer per engraving (GT: 1 to 4), chips 2 per wafer like the UHPIC.
--------------------------------------------------------------------------------

local SPRITE_PATH = "__Gregtorio__/graphics/entity/fork/"
local FORK_ICON_PATH = "__Gregtorio__/graphics/icons/fork/"
local FLUID_ICON_PATH = "__Gregtorio__/graphics/fluids/"

local function replace_ingredient(recipe_name, from, to, amount)
	local r = data.raw.recipe[recipe_name]
	if not r then log("FORK-WATER: missing recipe: " .. recipe_name) return end
	for _, i in pairs(r.ingredients or {}) do
		if i.name == from then i.name = to; i.amount = amount end
	end
end

local function category(name)
	if not data.raw["recipe-category"][name] then recipe_category_and_subgroup(name) end
end

local function fork_fluid(name, icon, color)
	if data.raw.fluid[name] then return end
	local c = { r = color[1], g = color[2], b = color[3] }
	data:extend({ {
		type = "fluid",
		name = name,
		default_temperature = 25,
		max_temperature = 100,
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

--- Copy of an existing machine with its own categories and generated sprites (tools/gen_sprites.py)
local function make_multiblock(def)
	local src = data.raw["assembling-machine"][def.source]
	if not src then log("FORK-WATER: missing source machine " .. def.source) return end
	local m = table.deepcopy(src)
	m.name = def.name
	m.icons = nil
	m.icon = FORK_ICON_PATH .. def.name .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = def.name }
	m.crafting_categories = def.categories
	m.crafting_speed = def.speed
	m.energy_usage = def.energy
	m.fast_replaceable_group = "fr-" .. def.name
	m.next_upgrade = nil
	local w = src.selection_box[2][1] - src.selection_box[1][1]
	local h = src.selection_box[2][2] - src.selection_box[1][2]
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-idle.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-working.png",
			width = w * 32, height = h * 32, frame_count = 1, shift = { 0, 0 } } } },
	}
	data:extend({ m })
end



--------------------------------------------------------------------------------
--- 1) ACTIVATED CARBON FILTER (grade 1)
--- GT: carbon + phosphoric acid -> pre-activated carbon -> blast furnace -> chemical bath
--- (phosphoric acid comes back) -> 64 dust + 16 zinc foils per mesh filter. The filter
--- stays in the clarifier and wears out; here 16 dust + 8 foils, and 9 of 10 crafts return it.
--------------------------------------------------------------------------------

create_item{
	name = "pre-activated-carbon",
	category = "luv-chemical-reactor-recipes",
	energy_required = 5 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "phosphoric-acid", amount = 100 },
	},
}
create_item{
	name = "dirty-activated-carbon",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = 10 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "pre-activated-carbon", amount = 1 },
	},
}
create_item{
	name = "activated-carbon",
	category = "iv-chemical-bath-recipes",
	energy_required = 2 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "dirty-activated-carbon", amount = 1 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = {
		{ type = "item", name = "activated-carbon", amount = 1 },
		{ type = "fluid", name = "phosphoric-acid", amount = 100 },
	},
	main_product = "activated-carbon",
}
create_item{
	name = "activated-carbon-mesh-filter",
	category = "iv-assembling-machine-recipes",
	energy_required = 10 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "activated-carbon", amount = 16 },
		{ type = "item", name = "zinc-foil", amount = 8 },
	},
}



--------------------------------------------------------------------------------
--- 2) CHEMICALS OF THE GRADES
---   ozone (grade 2): GT engraves it from air with a lens; oxygen in a chemical reactor here
---   polyaluminium chloride (grade 3): 2 Al(OH)3 + 3 HCl as in GT
--------------------------------------------------------------------------------

fork_fluid("ozone", "spackled-light-blue-fluid", { 0.55, 0.75, 0.95 })
fork_fluid("polyaluminium-chloride", "pale-green-fluid", { 0.75, 0.85, 0.70 })

create_recipe{
	recipe_name = "ozone",
	category = "luv-chemical-reactor-recipes",
	energy_required = 2 * LUV_SPEED,
	subgroup = "subgroup-luv-chemical-reactor-recipes",
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "ozone", amount = 100 },
	},
}
create_recipe{
	recipe_name = "polyaluminium-chloride",
	category = "ev-chemical-reactor-recipes",
	energy_required = 4 * EV_SPEED,
	subgroup = "subgroup-ev-chemical-reactor-recipes",
	ingredients = {
		{ type = "item", name = "aluminium-hydroxide", amount = 8 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "polyaluminium-chloride", amount = 100 },
		{ type = "fluid", name = "water", amount = 300 },
	},
	main_product = "polyaluminium-chloride",
}



--------------------------------------------------------------------------------
--- 3) THE PLANT AND THE GRADES
--- Grade n water is what the previous grade turns into (900 of 1000 mB); the additive of each
--- grade is small. The plant has two fluid inputs and one output.
--------------------------------------------------------------------------------

category("water-purification-recipes")

make_multiblock{
	name = "water-purification-plant", source = "hv-large-chemical-reactor",
	categories = { "water-purification-recipes" },
	speed = 1, energy = EU16_LuV,
}
create_item{
	name = "water-purification-plant",
	icon = FORK_ICON_PATH .. "water-purification-plant.png",
	category = "luv-assembling-machine-recipes",
	subgroup = "subgroup-luv-age-multiblocks",
	energy_required = 60 * LUV_SPEED,
	stack_size = 10,
	place_result = "water-purification-plant",
	ingredients = {
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "chemically-inert-casing", amount = 16 },
		{ type = "item", name = "filter-casing", amount = 16 },
		{ type = "item", name = "ptfe-pipe-casing", amount = 8 },
		{ type = "item", name = "luv-pump", amount = 4 },
		{ type = "item", name = "luv-motor", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 4 },
	},
}

local function grade_recipe(grade, time, ingredients, results)
	local name = "grade-" .. grade .. "-water"
	results[#results + 1] = { type = "fluid", name = name, amount = 900 }
	create_recipe{
		recipe_name = name,
		category = "water-purification-recipes",
		energy_required = time,
		subgroup = "subgroup-water-purification-recipes",
		ingredients = ingredients,
		results = results,
		main_product = name,
	}
end

grade_recipe(1, 10, {
	{ type = "fluid", name = "water", amount = 1000 },
	{ type = "item", name = "activated-carbon-mesh-filter", amount = 1 },
}, {
	{ type = "item", name = "activated-carbon-mesh-filter", amount = 1, probability = 0.9 },
	{ type = "item", name = "stone-dust", amount = 1, probability = 0.1 },
})
grade_recipe(2, 10, {
	{ type = "fluid", name = "grade-1-water", amount = 1000 },
	{ type = "fluid", name = "ozone", amount = 1000 },
}, {
	{ type = "item", name = "manganese-dust", amount = 1, probability = 0.5 },
	{ type = "item", name = "iron-dust", amount = 1, probability = 0.5 },
})
grade_recipe(3, 15, {
	{ type = "fluid", name = "grade-2-water", amount = 1000 },
	{ type = "fluid", name = "polyaluminium-chloride", amount = 100 },
}, {
	{ type = "item", name = "clay-ball", amount = 1 },
	{ type = "item", name = "quartz-sand", amount = 1, probability = 0.5 },
})
grade_recipe(4, 15, {
	{ type = "fluid", name = "grade-3-water", amount = 1000 },
	{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	{ type = "item", name = "sodium-hydroxide", amount = 4 },
}, {})
grade_recipe(5, 20, {
	{ type = "fluid", name = "grade-4-water", amount = 1000 },
	{ type = "fluid", name = "helium-plasma", amount = 10 },
}, {})
grade_recipe(6, 20, {
	{ type = "fluid", name = "grade-5-water", amount = 1000 },
	{ type = "fluid", name = "krypton-plasma", amount = 10 },
}, {})

--- Upstream's ingredient of the doped wafers is 10 mB of grade 4 / 6 water per cut and 10 per
--- engraving: leave as it is.



--------------------------------------------------------------------------------
--- 4) DOPED BOULES, WAFERS AND POWER ICs
--- Boules: 64 poly-silicon, 8 ingots of the dopant, gallium arsenide and nitrogen like the
--- phosphorus one; 96 (europium) and 128 (americium) wafers per boule.
--- NPIC wafer: europium wafer, PPIC and QPIC wafer: americium wafer, one engraving each; the
--- higher the grade of the water, the better the chip. Chips: 2 per wafer with lubricant, like the
--- UHPIC. The NAND memory wafer variants of the drafts get their europium / americium wafers now
--- and are unlocked with them (the auto-unlock would have put them into the assembly line tech);
--- the other draft variants (CPU, SoC ...) have a producer already and stay unreachable.
--------------------------------------------------------------------------------

create_item{
	name = "europium-doped-monocrystaline-silicon-boule",
	category = "iv-electric-blast-furnace-recipes",
	energy_required = 60 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 64 },
		{ type = "item", name = "europium-ingot", amount = 8 },
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 2 },
		{ type = "fluid", name = "nitrogen", amount = 800 },
	},
}
create_item{
	name = "americium-doped-monocrystaline-silicon-boule",
	category = "luv-electric-blast-furnace-recipes",
	energy_required = 60 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 64 },
		{ type = "item", name = "americium-ingot", amount = 8 },
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 2 },
		{ type = "fluid", name = "nitrogen", amount = 800 },
	},
}

local function pic_wafer(name, category_name, time, wafer, water)
	create_item{
		name = name,
		category = category_name,
		energy_required = time,
		subgroup = "subgroup-luv-circuit-assembly-line-recipes",
		ingredients = {
			{ type = "item", name = wafer, amount = 1 },
			{ type = "fluid", name = water, amount = 10 },
		},
	}
end
pic_wafer("npic-wafer", "luv-laser-engraver-recipes", 5 * LUV_SPEED, "europium-doped-wafer", "grade-4-water")
pic_wafer("ppic-wafer", "zpm-laser-engraver-recipes", 5 * ZPM_SPEED, "americium-doped-wafer", "grade-5-water")
pic_wafer("qpic-wafer", "zpm-laser-engraver-recipes", 8 * ZPM_SPEED, "americium-doped-wafer", "grade-6-water")

local function pic_chip(name, category_name, time, wafer)
	create_item{
		name = name,
		category = category_name,
		energy_required = time,
		subgroup = "subgroup-luv-circuit-assembly-line-recipes",
		ingredients = {
			{ type = "item", name = wafer, amount = 1 },
			{ type = "fluid", name = "lubricant", amount = 25 },
		},
		results = { { type = "item", name = name, amount = 2 } },
	}
end
pic_chip("nano-power-ic", "luv-assembling-machine-recipes", 45 * LUV_SPEED, "npic-wafer")
pic_chip("pico-power-ic", "zpm-assembling-machine-recipes", 45 * ZPM_SPEED, "ppic-wafer")
pic_chip("quantum-power-ic", "zpm-assembling-machine-recipes", 45 * ZPM_SPEED, "qpic-wafer")



--------------------------------------------------------------------------------
--- 5) THE WORKAROUNDS OF PHASES 2 TO 4
---   * ZPM energy hatch: NPICs instead of UHPICs (GT)
---   * UV energy hatch: PPICs (GT)
---   * UHV energy hatch: QPICs (GT)
---   * MK2 controller: NPIC wafers. GT uses PPIC wafers, but they need americium, which only the
---     MK2 reactor makes, so the NPIC wafer is the closest one that does not dead-end.
---   * MK3 controller: QPIC wafers (draft)
--- The wetware mainframe keeps its advanced SMDs: the complex SMDs come from GT's nanochip
--- assembly complex, which is not part of this mod.
--------------------------------------------------------------------------------

replace_ingredient("zpm-energy-hatch", "ultra-high-powered-integrated-circuit", "nano-power-ic", 4)
replace_ingredient("uv-energy-hatch", "ultra-high-powered-integrated-circuit", "pico-power-ic", 4)
replace_ingredient("uhv-energy-hatch", "ultra-high-powered-integrated-circuit", "quantum-power-ic", 4)
replace_ingredient("fusion-reactor-mk2-controller", "uhpic-wafer", "npic-wafer", 48)
replace_ingredient("fusion-reactor-mk3-controller", "uhpic-wafer", "qpic-wafer", 48)



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- water-purification: LuV science, right after the ZPM techs it needs no pack of.
--- nano-power-ics (LuV science): the europium wafer and the NPIC; needed by the ZPM hatch and the
--- MK2 controller.
--- pico-quantum-power-ics (ZPM science): grade 6 water (krypton plasma comes from the MK2 reactor),
--- the americium wafer, PPIC and QPIC; needed by the UV and UHV hatches and the MK3 controller.
--------------------------------------------------------------------------------

local function sci(n)
	local packs = { "automation-science-pack", "logistic-science-pack", "military-science-pack",
		"chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack",
		"metallurgic-science-pack", "agricultural-science-pack", "electromagnetic-science-pack" }
	local amounts = { SP10, SP09, SP08, SP07, SP06, SP05, SP04, SP03, SP02, SP01 }
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
			log("FORK-WATER: missing recipe: " .. r)
		end
	end
	data:extend({ {
		type = "technology",
		name = def.name,
		icon = "__Gregtorio__/graphics/technology/nyi.png",
		icon_size = 256,
		effects = effects,
		prerequisites = def.prerequisites,
		unit = { count = def.count, ingredients = sci(def.packs), time = def.time or 60 },
	} })
end

tech{
	name = "water-purification", prerequisites = { "luv-machines", "fusion-plasmas-mk1" }, packs = 7, count = 1500,
	recipes = {
		"pre-activated-carbon", "dirty-activated-carbon", "activated-carbon", "activated-carbon-mesh-filter",
		"ozone", "polyaluminium-chloride", "water-purification-plant",
		"grade-1-water", "grade-2-water", "grade-3-water", "grade-4-water", "grade-5-water",
	},
}
tech{
	name = "nano-power-ics", prerequisites = { "water-purification" }, packs = 7, count = 1500,
	recipes = { "europium-doped-monocrystaline-silicon-boule", "europium-doped-wafer", "npic-wafer", "nano-power-ic",
		"nand-memory-wafer-ed" },
}
tech{
	name = "pico-quantum-power-ics", prerequisites = { "nano-power-ics", "uv-materials" }, packs = 8, count = 2000,
	recipes = { "grade-6-water", "americium-doped-monocrystaline-silicon-boule", "americium-doped-wafer", "ppic-wafer", "qpic-wafer",
		"pico-power-ic", "quantum-power-ic", "nand-memory-wafer-ad" },
}

--- The auto-unlock used to put the phosphorus NAND wafer into the assembly line tech (nothing else made
--- NAND wafers); the explicit unlocks above would take that away, so it is bound to its tech here
fork_add_unlock("assembly-line", "nand-memory-wafer-pd")

--- Techs that use the chips need the techs that make them
local function add_prerequisite(tech_name, prerequisite)
	local t = data.raw.technology[tech_name]
	if not t then log("FORK-WATER: missing tech: " .. tech_name) return end
	for _, p in pairs(t.prerequisites or {}) do if p == prerequisite then return end end
	t.prerequisites = t.prerequisites or {}
	table.insert(t.prerequisites, prerequisite)
end
add_prerequisite("zpm-energy-hatches", "nano-power-ics")
add_prerequisite("fusion-reactor-mk2", "nano-power-ics")
add_prerequisite("uv-energy-hatches", "pico-quantum-power-ics")
add_prerequisite("uhv-energy-hatches", "pico-quantum-power-ics")
add_prerequisite("fusion-reactor-mk3", "pico-quantum-power-ics")
