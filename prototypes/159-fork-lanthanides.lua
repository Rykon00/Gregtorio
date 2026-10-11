--------------------------------------------------------------------------------
--- FORK LANTHANIDES (issue #262, from the audit of #257): GT New Horizons' monazite rare earth line (gtnhlanth,
--- GT5-Unofficial af993ca6a9 `gtnhlanth/loader/RecipeLoader.java`, loadLanthanideRecipes from line 1238), so samarium
--- and gadolinium come from ore. Until now samarium dust was a placeholder (stone and oxygen in the MV chemical
--- reactor, 19-iv-age-item.lua), which goes; the cerium-rich mixture of the bastnasite and lanthanite electrolysis gets
--- its GT use (the second nitric leaching mixer).
---
--- The machines are gtnhlanth's: the Digester (IV controller, GT's recipe at line 3259: IV hull, IV motors and pumps,
--- LuV circuits, PTFE; the EV super tanks are storage tanks, the desh rotors tungstensteel rotors, Gregtorio has no
--- desh) and the Dissolution Tank (EV controller, line 3274). The sifting machines get a fluid input and output, as GT's
--- sifter has (101), for the sifter steps of the line.
---
--- The line (GT's numbers; fluids a tenth of GT's litres, times GT's seconds x the speed of the recipe's tier):
---   digester: 2 crushed monazite + 70 nitric acid -> 40 muddy monazite rare earth solution, silicon dioxide (EV, 20 s)
---   dissolution tank: 100 muddy + 1000 water + saltpeter -> 1100 diluted mud, thorianite, monazite dust 22 % (HV, 45 s)
---   sifter: 100 diluted mud -> monazite sulfate 90 %, silicon dioxide 75 %, rutile 20 %, ilmenite 20 % (HV, 20 s)
---   mixer: monazite sulfate + 600 water -> 700 diluted monazite sulfate (HV, 24 s)
---   chemical reactor: 900 diluted sulfate + 180 ammonium nitrate solution -> 3 acidic monazite powder (HV, 216 s; GT's
---     x9 recipe, its x1 makes 3 tiny piles)
---   sifter: acidic powder -> monazite rare earth filtrate 90 %, thorium-phosphate cake 70 % (HV, 30 s); the cake goes
---     through the MV blast furnace (15 s) and the thermal centrifuge (HV, 10 s) into thorium and phosphate
---   chemical bath: filtrate + 32 ammonium nitrate solution -> neutralized filtrate (HV, 6 s)
---   sifter: neutralized filtrate -> hydroxide concentrate 90 %, uranium filtrate 50 % and 40 % (HV, 40 s); the uranium
---     filtrate through the chemical bath with 10 hydrofluoric acid (MV, 18 s) and the sifter (LV, 50 s) into uranium
---   blast furnace: hydroxide concentrate -> dried concentrate (MV, 15 s)
---   chemical reactor: dried concentrate + 50 nitric acid -> 100 nitrogenated concentrate (HV, 25 s)
---   mixer: 100 nitrogenated + 100 water -> 100 nitric-leached mixture (MV, 10 s), or + 3 cerium-rich mixture -> 200 (MV,
---     11 s)
---   sifter: 100 nitric-leached mixture -> 100 nitric monazite leached concentrate, cerium dioxide 11.11 % (HV, 20 s)
---   vacuum freezer: 100 leached concentrate -> cooled concentrate (HV, 5 s)
---   electromagnetic separator: cooled concentrate -> monazite rarer earth sediment 90 % (EV, 30 s)
---   blast furnace: sediment + 100 chlorine -> heterogenous halogenic mixture (HV, 25 s)
---   mixer: halogenic mixture + salt + 100 acetone -> saturated monazite rare earth (HV, 10 s)
---   centrifuge: 4 saturated -> 3 samaric residue (EV, 157.5 s)
---   sifter: 3 samaric residue -> 2 samarium dust, gadolinium dust (EV, 6.65 s)
---   ammonium nitrate solution: 100 nitric acid + 100 ammonia -> 100 (chemical reactor, HV, 1.5 s)
--- Left out: GT's byproducts that Gregtorio has no material for (hafnia-zirconia blend, red zircon, europium(III) oxide,
--- chloromethane); cerium dioxide stays a product without the cerium line (GT's oxalate route), as decided for #262.
--- Loads after 158 and before 156 (data.lua).
--------------------------------------------------------------------------------

local F = FORK5B
local SPRITE_PATH = "__gregtorio-continued__/graphics/entity/fork/"
local N, S = defines.direction.north, defines.direction.south
local TECH = "monazite-rare-earth-processing"
local RECIPES = {}

--- a recipe of the line: category, GT seconds x the tier speed, ingredients, results (amount or { amount, probability })
local function step(name, category, seconds, speed, ingredients, results, main)
	local ing, res = {}, {}
	for _, i in pairs(ingredients) do
		ing[#ing + 1] = { type = data.raw.fluid[i[1]] and "fluid" or "item", name = i[1], amount = i[2] }
	end
	for _, r in pairs(results) do
		local x = { type = data.raw.fluid[r[1]] and "fluid" or "item", name = r[1], amount = r[2] }
		if r[3] then x.probability = r[3] end
		res[#res + 1] = x
	end
	create_recipe{
		name = name,
		category = category,
		energy_required = seconds * speed,
		ingredients = ing,
		results = res,
		main_product = main or results[1][1],
	}
	RECIPES[#RECIPES + 1] = name
end

--------------------------------------------------------------------------------
--- 1) MATERIALS (GT's names; icons from tools/gen_gt_icons.py, the Werkstoff colours of WerkstoffMaterialPool.java)
--------------------------------------------------------------------------------

local ITEMS = {
	"monazite-sulfate", "acidic-monazite-powder", "monazite-rare-earth-filtrate", "thorium-phosphate-cake",
	"thorium-phosphate-concentrate", "neutralized-monazite-rare-earth-filtrate", "monazite-rare-earth-hydroxide-concentrate",
	"uranium-filtrate", "neutralized-uranium-filtrate", "dried-monazite-rare-earth-concentrate", "cerium-dioxide",
	"cooled-monazite-rare-earth-concentrate", "monazite-rarer-earth-sediment",
	"heterogenous-halogenic-monazite-rare-earth-mixture", "saturated-monazite-rare-earth", "samaric-residue",
	"gadolinium-dust",
}
for _, name in pairs(ITEMS) do
	create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes" }
end
--- (the colours of GT's fluids, 0..1)
F.fluid("muddy-monazite-rare-earth-solution", "brown-fluid", { 0.44, 0.31, 0.22 })
F.fluid("diluted-monazite-rare-earth-mud", "brown-fluid", { 0.63, 0.47, 0.35 })
F.fluid("diluted-monazite-sulfate", "light-pink-fluid", { 0.93, 0.79, 0.69 })
F.fluid("ammonium-nitrate-solution", "nearly-white-fluid", { 1.00, 1.00, 1.00 })
F.fluid("nitrogenated-monazite-rare-earth-concentrate", "light-orange-fluid", { 0.98, 0.87, 0.68 })
F.fluid("nitric-leached-monazite-mixture", "deep-pink-fluid", { 0.49, 0.20, 0.54 })
F.fluid("nitric-monazite-leached-concentrate", "dark-muted-yellow-fluid", { 0.96, 0.79, 0.09 })

--------------------------------------------------------------------------------
--- 2) MACHINES: the Digester and the Dissolution Tank (3x3 copies of the chemical reactor with their own ports and
--- sprites, tools/gen_sprites.py); the sifting machines get a fluid input (north) and output (south)
--------------------------------------------------------------------------------

local function port(kind, direction, position, volume)
	return {
		production_type = kind, volume = volume or 1000, pipe_covers = pipecoverspictures(),
		pipe_picture = assembler2pipepictures(),
		pipe_connections = { { flow_direction = kind, direction = direction, position = position } },
	}
end
local function machine(def)
	local m = table.deepcopy(data.raw["assembling-machine"][def.source])
	m.name = def.name
	m.icons = nil
	m.icon = "__gregtorio-continued__/graphics/icons/fork/" .. def.name .. ".png"
	m.icon_size = 32
	m.minable = { mining_time = 1, result = def.name }
	m.crafting_categories = { def.category }
	m.crafting_speed = def.speed
	m.energy_usage = def.energy
	m.fast_replaceable_group = "fr-" .. def.name
	m.next_upgrade = nil
	m.collision_box = { { -1.3, -1.3 }, { 1.3, 1.3 } }
	m.selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }
	m.fluid_boxes = def.ports
	m.fluid_boxes_off_when_no_fluid_recipe = false
	m.graphics_set = {
		idle_animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-idle.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
		animation = { layers = { { filename = SPRITE_PATH .. def.name .. "-working.png", width = 96, height = 96,
			frame_count = 1, shift = { 0, 0 } } } },
	}
	m.localised_description = { "entity-description." .. def.name }
	data:extend({ m })
	create_item{
		name = def.name,
		icon = m.icon,
		place_result = def.name,
		subgroup = def.subgroup,
		stack_size = 10,
		category = def.recipe[1],
		energy_required = def.recipe[2],
		ingredients = def.recipe[3],
	}
	RECIPES[#RECIPES + 1] = def.name
end
machine{
	name = "digester", source = "hv-chemical-reactor", category = "digester-recipes", speed = IV_SPEED,
	energy = EU16_IV, subgroup = "subgroup-iv-age-multiblocks",
	ports = { port("input", N, { 0, -1 }), port("output", S, { 0, 1 }) },
	recipe = { "iv-assembling-machine-recipes", 30 * IV_SPEED, {
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "storage-tank", amount = 2 },
		{ type = "item", name = "iv-motor", amount = 4 },
		{ type = "item", name = "iv-pump", amount = 4 },
		{ type = "item", name = "tungstensteel-rotor", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "fluid", name = "ptfe", amount = 144 },
	} },
}
machine{
	name = "dissolution-tank", source = "hv-chemical-reactor", category = "dissolution-tank-recipes", speed = EV_SPEED,
	energy = EU16_EV, subgroup = "subgroup-ev-age-multiblocks",
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { 0, 1 }, 2000) },
	recipe = { "ev-assembling-machine-recipes", 20 * EV_SPEED, {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "storage-tank", amount = 2 },
		{ type = "item", name = "ev-motor", amount = 4 },
		{ type = "item", name = "ev-pump", amount = 2 },
		{ type = "item", name = "vibrant-alloy-rotor", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "fluid", name = "ptfe", amount = 72 },
	} },
}
--- GT's sifter has a fluid input and output; Gregtorio's sifting machines (LV to MAX) get them for the line's sifter steps
for name, m in pairs(data.raw["assembling-machine"]) do
	if name:match("%-sifting%-machine$") then
		m.fluid_boxes = { port("input", N, { 0, -1 }), port("output", S, { 0, 1 }) }
		m.fluid_boxes_off_when_no_fluid_recipe = true
	end
end

--------------------------------------------------------------------------------
--- 3) THE LINE
--------------------------------------------------------------------------------

local SIFT, CR, MIX, BATH = "lv-sifter-recipes", "hv-chemical-reactor-recipes", "hv-mixer-recipes", "hv-chemical-bath-recipes"
step("ammonium-nitrate-solution", CR, 1.5, HV_SPEED, { { "nitric-acid", 100 }, { "ammonia", 100 } },
	{ { "ammonium-nitrate-solution", 100 } })
step("muddy-monazite-rare-earth-solution", "digester-recipes", 20, EV_SPEED,
	{ { "crushed-monazite", 2 }, { "nitric-acid", 70 } },
	{ { "muddy-monazite-rare-earth-solution", 40 }, { "silicon-dioxide", 1 } })
step("diluted-monazite-rare-earth-mud", "dissolution-tank-recipes", 45, HV_SPEED,
	{ { "saltpeter", 1 }, { "water", 1000 }, { "muddy-monazite-rare-earth-solution", 100 } },
	{ { "diluted-monazite-rare-earth-mud", 1100 }, { "thorianite", 1 }, { "monazite-dust", 1, 2 / 9 } })
step("monazite-sulfate", SIFT, 20, HV_SPEED, { { "diluted-monazite-rare-earth-mud", 100 } },
	{ { "monazite-sulfate", 1, 0.9 }, { "silicon-dioxide", 1, 0.75 }, { "rutile-dust", 1, 0.2 },
	  { "ilmenite-dust", 1, 0.2 } })
step("diluted-monazite-sulfate", MIX, 24, HV_SPEED, { { "monazite-sulfate", 1 }, { "water", 600 } },
	{ { "diluted-monazite-sulfate", 700 } })
step("acidic-monazite-powder", CR, 216, HV_SPEED,
	{ { "diluted-monazite-sulfate", 900 }, { "ammonium-nitrate-solution", 180 } }, { { "acidic-monazite-powder", 3 } })
step("monazite-rare-earth-filtrate", SIFT, 30, HV_SPEED, { { "acidic-monazite-powder", 1 } },
	{ { "monazite-rare-earth-filtrate", 1, 0.9 }, { "thorium-phosphate-cake", 1, 0.7 } })
step("thorium-phosphate-concentrate", "mv-electric-blast-furnace-recipes", 15, MV_SPEED,
	{ { "thorium-phosphate-cake", 1 } }, { { "thorium-phosphate-concentrate", 1 } })
step("thorium-phosphate-concentrate-centrifuging", "lv-thermal-centrifuge-recipes", 10, HV_SPEED,
	{ { "thorium-phosphate-concentrate", 1 } }, { { "thorium-dust", 1 }, { "phosphate", 1 } })
step("neutralized-monazite-rare-earth-filtrate", BATH, 6, HV_SPEED,
	{ { "monazite-rare-earth-filtrate", 1 }, { "ammonium-nitrate-solution", 32 } },
	{ { "neutralized-monazite-rare-earth-filtrate", 1 } })
step("monazite-rare-earth-hydroxide-concentrate", SIFT, 40, HV_SPEED, { { "neutralized-monazite-rare-earth-filtrate", 1 } },
	{ { "monazite-rare-earth-hydroxide-concentrate", 1, 0.9 }, { "uranium-filtrate", 1, 0.5 },
	  { "uranium-filtrate", 1, 0.4 } })
step("neutralized-uranium-filtrate", "mv-chemical-bath-recipes", 18, MV_SPEED,
	{ { "uranium-filtrate", 1 }, { "hydrofluoric-acid", 10 } }, { { "neutralized-uranium-filtrate", 1 } })
step("neutralized-uranium-filtrate-sifting", SIFT, 50, LV_SPEED, { { "neutralized-uranium-filtrate", 1 } },
	{ { "uranium-238-dust", 1, 0.45 }, { "uranium-238-dust", 1, 0.4 }, { "uranium-238-dust", 1, 0.3 },
	  { "uranium-235-dust", 1, 0.3 }, { "uranium-235-dust", 1, 0.2 } })
step("dried-monazite-rare-earth-concentrate", "mv-electric-blast-furnace-recipes", 15, MV_SPEED,
	{ { "monazite-rare-earth-hydroxide-concentrate", 1 } }, { { "dried-monazite-rare-earth-concentrate", 1 } })
step("nitrogenated-monazite-rare-earth-concentrate", CR, 25, HV_SPEED,
	{ { "dried-monazite-rare-earth-concentrate", 1 }, { "nitric-acid", 50 } },
	{ { "nitrogenated-monazite-rare-earth-concentrate", 100 } })
step("nitric-leached-monazite-mixture", "mv-mixer-recipes", 10, MV_SPEED,
	{ { "nitrogenated-monazite-rare-earth-concentrate", 100 }, { "water", 100 } },
	{ { "nitric-leached-monazite-mixture", 100 } })
step("nitric-leached-monazite-mixture-cerium", "mv-mixer-recipes", 11, MV_SPEED,
	{ { "nitrogenated-monazite-rare-earth-concentrate", 100 }, { "cerium-rich-mixture", 3 } },
	{ { "nitric-leached-monazite-mixture", 200 } })
step("nitric-monazite-leached-concentrate", SIFT, 20, HV_SPEED, { { "nitric-leached-monazite-mixture", 100 } },
	{ { "nitric-monazite-leached-concentrate", 100 }, { "cerium-dioxide", 1, 1 / 9 } })
step("cooled-monazite-rare-earth-concentrate", "hv-vacuum-freezer-recipes", 5, HV_SPEED,
	{ { "nitric-monazite-leached-concentrate", 100 } }, { { "cooled-monazite-rare-earth-concentrate", 1 } })
step("monazite-rarer-earth-sediment", "lv-electromagnetic-separator-recipes", 30, EV_SPEED,
	{ { "cooled-monazite-rare-earth-concentrate", 1 } }, { { "monazite-rarer-earth-sediment", 1, 0.9 } })
step("heterogenous-halogenic-monazite-rare-earth-mixture", "hv-electric-blast-furnace-recipes", 25, HV_SPEED,
	{ { "monazite-rarer-earth-sediment", 1 }, { "chlorine", 100 } },
	{ { "heterogenous-halogenic-monazite-rare-earth-mixture", 1 } })
step("saturated-monazite-rare-earth", MIX, 10, HV_SPEED,
	{ { "heterogenous-halogenic-monazite-rare-earth-mixture", 1 }, { "salt", 1 }, { "acetone", 100 } },
	{ { "saturated-monazite-rare-earth", 1 } })
step("samaric-residue", "ev-centrifuge-recipes", 157.5, EV_SPEED, { { "saturated-monazite-rare-earth", 4 } },
	{ { "samaric-residue", 3 } })
step("samaric-residue-sifting", SIFT, 6.65, EV_SPEED, { { "samaric-residue", 3 } },
	{ { "samarium-dust", 2 }, { "gadolinium-dust", 1 } })

--- the placeholder (stone and oxygen) goes: samarium comes from the line
if data.raw.recipe["samarium-dust"] then
	data.raw.recipe["samarium-dust"] = nil
	for _, t in pairs(data.raw.technology) do
		local keep = {}
		for _, e in pairs(t.effects or {}) do
			if not (e.type == "unlock-recipe" and e.recipe == "samarium-dust") then keep[#keep + 1] = e end
		end
		t.effects = keep
	end
end

--------------------------------------------------------------------------------
--- 4) TECHNOLOGY (IV): the line comes before LuV Components, whose motors and rings take samarium
--------------------------------------------------------------------------------

F.tech{
	name = TECH, prerequisites = { "iv-components", "iv-machines", "nanoprocessors", "ptfe", "tungstensteel" }, packs = 6, count = 800, time = 45,
	recipes = RECIPES,
}
table.insert(data.raw.technology["luv-components"].prerequisites, TECH)
