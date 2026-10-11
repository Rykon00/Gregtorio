--------------------------------------------------------------------------------
--- FORK LANTHANIDES (issues #262 and #269, from the audit of #257): GT New Horizons' monazite rare earth line (gtnhlanth,
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
--- chloromethane). Section 5 adds the bastnasite line and the cerium line, which takes the cerium dioxide (issue #269).
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

--------------------------------------------------------------------------------
--- 5) BASTNASITE AND CERIUM (issue #269, after #262): gtnhlanth's bastnasite line (RecipeLoader.java from line 1550),
--- which gives neodymium and lanthanum, and its cerium line (lines 1181-1226, 1429-1453). The chemicals they need come
--- with them: hexafluorosilicic acid (bartworks' mica line, ArtificialMicaLine.java), sodium fluorosilicate (line 1107),
--- vanadium pentoxide (GoodGenerator, goodgenerator/loader/RecipeLoader.java) and oxalic acid (line 1179).
---
---   digester: 2 crushed bastnasite + 70 nitric acid -> 40 muddy bastnasite rare earth solution, silicon dioxide (EV, 20 s)
---   cracker: 100 muddy + 100 steam -> 200 steam-cracked bastnasite mud (HV, 30 s)
---   mixer: 100 steam-cracked mud + 32 sodium fluorosilicate -> 132 conditioned bastnasite mud (MV, 40 s)
---   dissolution tank: 100 conditioned + 1000 water + saltpeter -> 1100 diluted bastnasite mud (EV, 50 s)
---   sifter: 100 diluted mud -> 40 filtered bastnasite mud, silicon dioxide 90 %, rutile 75 %, ilmenite 5 % (HV, 20 s)
---   blast furnace: 100 filtered mud -> bastnasite rare earth oxides (HV, 25 s)
---   chemical bath: oxides + 50 hydrochloric acid -> acid-leached oxides (LV, 10 s)
---   blast furnace: leached oxides + 100 oxygen -> roasted rare earth oxides (MV, 30 s)
---   mixer: roasted + 20 water -> wet rare earth oxides (LV, 5 s)
---   chemical reactor: wet + 400 fluorine -> cerium-oxidised rare earth oxides, 400 hydrofluoric acid (HV, 15 s)
---   centrifuge: cerium-oxidised -> bastnasite rarer earth oxides, cerium dioxide 90 % (HV, 30 s)
---   mixer: rarer earth oxides + 40 nitric acid -> 100 nitrogenated bastnasite rarer earth oxides (HV, 15 s)
---   chemical reactor: 100 nitrogenated + 100 acetone -> 100 bastnasite rarer earth oxide suspension (HV, 35 s)
---   centrifuge: 100 suspension -> neodymium rare earth concentrate 80 %, 45 acetone (HV, 45 s; GT gives 75 diluted
---     acetone, which its fluid heater turns into acetone at 30 of 50; Gregtorio has no fluid heater, so the centrifuge
---     gives the acetone)
---   chemical reactor: 2 neodymium rare earth concentrate + 200 hydrochloric acid -> lanthanum chloride, neodymium oxide
---     (HV, 45 s)
---   electrolyzer (bartworks' generated recipes, Werkstoff electrolysis): 4 lanthanum chloride -> lanthanum dust + 300
---     chlorine (MV, 1.5 s); 5 neodymium oxide -> 2 neodymium dust + 300 oxygen (MV, 1.65 s)
--- Cerium:
---   chemical reactor: 15 cerium-rich mixture + 75 hydrochloric acid -> cerium chloride, monazite dust, 75 water (HV,
---     25 s); 3 cerium dioxide + 300 ammonium chloride + 100 hydrogen -> 4 cerium chloride, 300 ammonia, 200 steam (HV,
---     15 s); 8 cerium chloride + 300 oxalic acid -> 5 cerium oxalate, 600 hydrochloric acid (HV, 15 s)
---   blast furnace: 5 cerium oxalate + 3 carbon -> 5 cerium(III) oxide, 900 carbon monoxide (HV, 10 s)
---   electrolyzer: 5 cerium(III) oxide -> 2 cerium dust + 300 oxygen (MV, 1.6 s)
---   oxalic acid (large chemical reactor, GT's x9 recipes, its x1 take a tiny pile of the catalyst): vanadium pentoxide +
---     900 methanol + 900 carbon monoxide + 2700 oxygen -> 900 oxalic acid, 900 water; or vanadium pentoxide + 900
---     ethanol + 4500 oxygen -> 900 oxalic acid, 1800 water (HV, 202.5 s)
---   blast furnace: 2 vanadium dust + 500 oxygen -> 7 vanadium pentoxide (MV, 10 s)
---   chemical reactor: silicon dust + 600 hydrofluoric acid -> 100 hexafluorosilicic acid, 400 hydrogen (MV, 20 s); 4
---     salt + 100 hexafluorosilicic acid -> 100 sodium fluorosilicate, 200 hydrochloric acid (HV, 30 s)
--- Left out: the samaric branch of the bastnasite line (samaric rare earth concentrate, 50 % in GT's suspension
--- centrifuge, and its steps to samaric residue need GT++'s ammonium nitrate dust from the chemical plant and the
--- dehydrator, and give holmium, terbium nitrate and calcium fluoride), GT's byproducts without a Gregtorio material
--- (gangue from the dissolution tank, red zircon 10 % from the sifter) and the 1.3 fluorine of the roasting.
--------------------------------------------------------------------------------

local BASTNASITE, CERIUM = "bastnasite-rare-earth-processing", "cerium-processing"
for _, name in pairs({
	"bastnasite-rare-earth-oxides", "acid-leached-bastnasite-rare-earth-oxides", "roasted-rare-earth-oxides",
	"wet-rare-earth-oxides", "cerium-oxidised-rare-earth-oxides", "bastnasite-rarer-earth-oxides",
	"neodymium-rare-earth-concentrate", "lanthanum-chloride", "neodymium-oxide", "lanthanum-dust",
	"cerium-chloride", "cerium-oxalate", "cerium-iii-oxide", "cerium-dust", "vanadium-pentoxide",
}) do
	create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes" }
end
F.fluid("muddy-bastnasite-rare-earth-solution", "brown-fluid", { 0.80, 0.52, 0.25 })
F.fluid("steam-cracked-bastnasite-mud", "brown-fluid", { 0.80, 0.52, 0.25 })
F.fluid("conditioned-bastnasite-mud", "brown-fluid", { 0.80, 0.52, 0.25 })
F.fluid("diluted-bastnasite-mud", "brown-fluid", { 0.80, 0.52, 0.25 })
F.fluid("filtered-bastnasite-mud", "brown-fluid", { 0.80, 0.52, 0.25 })
F.fluid("nitrogenated-bastnasite-rarer-earth-oxides", "rust-brown-fluid", { 0.63, 0.35, 0.24 })
F.fluid("bastnasite-rarer-earth-oxide-suspension", "rust-brown-fluid", { 0.67, 0.35, 0.24 })
F.fluid("hexafluorosilicic-acid", "deep-blue-fluid", { 0.17, 0.44, 0.71 })
F.fluid("sodium-fluorosilicate", "light-orange-fluid", { 0.80, 0.52, 0.25 })
F.fluid("oxalic-acid", "pale-green-fluid", { 0.47, 0.85, 0.33 })

RECIPES = {}
step("hexafluorosilicic-acid", "mv-chemical-reactor-recipes", 20, MV_SPEED,
	{ { "raw-silicon", 1 }, { "hydrofluoric-acid", 600 } }, { { "hexafluorosilicic-acid", 100 }, { "hydrogen", 400 } })
step("sodium-fluorosilicate", CR, 30, HV_SPEED, { { "salt", 4 }, { "hexafluorosilicic-acid", 100 } },
	{ { "sodium-fluorosilicate", 100 }, { "hydrochloric-acid", 200 } })
step("muddy-bastnasite-rare-earth-solution", "digester-recipes", 20, EV_SPEED,
	{ { "crushed-bastnasite", 2 }, { "nitric-acid", 70 } },
	{ { "muddy-bastnasite-rare-earth-solution", 40 }, { "silicon-dioxide", 1 } })
step("steam-cracked-bastnasite-mud", "hv-cracker-recipes", 30, HV_SPEED,
	{ { "muddy-bastnasite-rare-earth-solution", 100 }, { "steam", 100 } }, { { "steam-cracked-bastnasite-mud", 200 } })
step("conditioned-bastnasite-mud", "mv-mixer-recipes", 40, MV_SPEED,
	{ { "steam-cracked-bastnasite-mud", 100 }, { "sodium-fluorosilicate", 32 } }, { { "conditioned-bastnasite-mud", 132 } })
step("diluted-bastnasite-mud", "dissolution-tank-recipes", 50, EV_SPEED,
	{ { "saltpeter", 1 }, { "water", 1000 }, { "conditioned-bastnasite-mud", 100 } }, { { "diluted-bastnasite-mud", 1100 } })
step("filtered-bastnasite-mud", SIFT, 20, HV_SPEED, { { "diluted-bastnasite-mud", 100 } },
	{ { "filtered-bastnasite-mud", 40 }, { "silicon-dioxide", 1, 0.9 }, { "rutile-dust", 1, 0.75 },
	  { "ilmenite-dust", 1, 0.05 } })
step("bastnasite-rare-earth-oxides", "hv-electric-blast-furnace-recipes", 25, HV_SPEED, { { "filtered-bastnasite-mud", 100 } },
	{ { "bastnasite-rare-earth-oxides", 1 } })
step("acid-leached-bastnasite-rare-earth-oxides", "lv-chemical-bath-recipes", 10, LV_SPEED,
	{ { "bastnasite-rare-earth-oxides", 1 }, { "hydrochloric-acid", 50 } }, { { "acid-leached-bastnasite-rare-earth-oxides", 1 } })
step("roasted-rare-earth-oxides", "mv-electric-blast-furnace-recipes", 30, MV_SPEED,
	{ { "acid-leached-bastnasite-rare-earth-oxides", 1 }, { "oxygen", 100 } }, { { "roasted-rare-earth-oxides", 1 } })
step("wet-rare-earth-oxides", "lv-mixer-recipes", 5, LV_SPEED, { { "roasted-rare-earth-oxides", 1 }, { "water", 20 } },
	{ { "wet-rare-earth-oxides", 1 } })
step("cerium-oxidised-rare-earth-oxides", CR, 15, HV_SPEED, { { "wet-rare-earth-oxides", 1 }, { "fluorine", 400 } },
	{ { "cerium-oxidised-rare-earth-oxides", 1 }, { "hydrofluoric-acid", 400 } })
step("bastnasite-rarer-earth-oxides", "hv-centrifuge-recipes", 30, HV_SPEED, { { "cerium-oxidised-rare-earth-oxides", 1 } },
	{ { "bastnasite-rarer-earth-oxides", 1 }, { "cerium-dioxide", 1, 0.9 } })
step("nitrogenated-bastnasite-rarer-earth-oxides", MIX, 15, HV_SPEED,
	{ { "bastnasite-rarer-earth-oxides", 1 }, { "nitric-acid", 40 } }, { { "nitrogenated-bastnasite-rarer-earth-oxides", 100 } })
step("bastnasite-rarer-earth-oxide-suspension", CR, 35, HV_SPEED,
	{ { "nitrogenated-bastnasite-rarer-earth-oxides", 100 }, { "acetone", 100 } },
	{ { "bastnasite-rarer-earth-oxide-suspension", 100 } })
step("neodymium-rare-earth-concentrate", "hv-centrifuge-recipes", 45, HV_SPEED,
	{ { "bastnasite-rarer-earth-oxide-suspension", 100 } },
	{ { "neodymium-rare-earth-concentrate", 1, 0.8 }, { "acetone", 45 } })
step("neodymium-rare-earth-concentrate-reaction", CR, 45, HV_SPEED,
	{ { "neodymium-rare-earth-concentrate", 2 }, { "hydrochloric-acid", 200 } },
	{ { "lanthanum-chloride", 1 }, { "neodymium-oxide", 1 } })
step("lanthanum-chloride-electrolysis", "mv-electrolyzer-recipes", 1.5, MV_SPEED, { { "lanthanum-chloride", 4 } },
	{ { "lanthanum-dust", 1 }, { "chlorine", 300 } })
step("neodymium-oxide-electrolysis", "mv-electrolyzer-recipes", 1.65, MV_SPEED, { { "neodymium-oxide", 5 } },
	{ { "neodymium-dust", 2 }, { "oxygen", 300 } })
F.tech{
	name = BASTNASITE, prerequisites = { TECH }, packs = 6, count = 800, time = 45,
	recipes = RECIPES,
}

RECIPES = {}
step("vanadium-pentoxide", "mv-electric-blast-furnace-recipes", 10, MV_SPEED, { { "vanadium-dust", 2 }, { "oxygen", 500 } },
	{ { "vanadium-pentoxide", 7 } })
step("oxalic-acid", CR, 202.5, HV_SPEED,
	{ { "vanadium-pentoxide", 1 }, { "methanol", 900 }, { "carbon-monoxide", 900 }, { "oxygen", 2700 } },
	{ { "oxalic-acid", 900 }, { "water", 900 } })
step("oxalic-acid-from-ethanol", CR, 202.5, HV_SPEED, { { "vanadium-pentoxide", 1 }, { "ethanol", 900 }, { "oxygen", 4500 } },
	{ { "oxalic-acid", 900 }, { "water", 1800 } })
step("cerium-chloride", CR, 25, HV_SPEED, { { "cerium-rich-mixture", 15 }, { "hydrochloric-acid", 75 } },
	{ { "cerium-chloride", 1 }, { "monazite-dust", 1 }, { "water", 75 } })
step("cerium-chloride-from-cerium-dioxide", CR, 15, HV_SPEED,
	{ { "cerium-dioxide", 3 }, { "ammonium-chloride", 300 }, { "hydrogen", 100 } },
	{ { "cerium-chloride", 4 }, { "ammonia", 300 }, { "steam", 200 } })
step("cerium-oxalate", CR, 15, HV_SPEED, { { "cerium-chloride", 8 }, { "oxalic-acid", 300 } },
	{ { "cerium-oxalate", 5 }, { "hydrochloric-acid", 600 } })
step("cerium-iii-oxide", "hv-electric-blast-furnace-recipes", 10, HV_SPEED, { { "cerium-oxalate", 5 }, { "carbon", 3 } },
	{ { "cerium-iii-oxide", 5 }, { "carbon-monoxide", 900 } })
step("cerium-iii-oxide-electrolysis", "mv-electrolyzer-recipes", 1.6, MV_SPEED, { { "cerium-iii-oxide", 5 } },
	{ { "cerium-dust", 2 }, { "oxygen", 300 } })
F.tech{
	name = CERIUM, prerequisites = { TECH }, packs = 6, count = 600, time = 45,
	recipes = RECIPES,
}
