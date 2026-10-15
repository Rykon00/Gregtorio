--------------------------------------------------------------------------------
--- FORK LANTHANIDES (issues #262, #269, #272 and #274, from the audit of #257): GT New Horizons' monazite rare earth line (gtnhlanth,
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
--- Section 7 adds GT's chloromethane of the samaric residue centrifuge (issue #274). Section 5 adds the bastnasite line and
--- the cerium line, which takes the cerium dioxide (issue #269); section 6 the byproducts hafnia-zirconia blend, red
--- zircon and europium(III) oxide with their lines (issue #272).
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
--- issue #274: GT's chloromethane of the samaric residue centrifuge (Materials.Chloromethane, a gas)
F.fluid("chloromethane", "deep-pink-fluid", { 0.78, 0.17, 0.63 })

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
	{ { "diluted-monazite-rare-earth-mud", 1100 }, { "hafnia-zirconia-blend", 1, 4 / 9 }, { "thorianite", 1 },
	  { "monazite-dust", 1, 2 / 9 } })
step("monazite-sulfate", SIFT, 20, HV_SPEED, { { "diluted-monazite-rare-earth-mud", 100 } },
	{ { "monazite-sulfate", 1, 0.9 }, { "silicon-dioxide", 1, 0.75 }, { "rutile-dust", 1, 0.2 },
	  { "red-zircon-dust", 1, 0.05 }, { "ilmenite-dust", 1, 0.2 } })
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
	{ { "cooled-monazite-rare-earth-concentrate", 1 } },
	{ { "monazite-rarer-earth-sediment", 1, 0.9 }, { "europium-iii-oxide", 5, 0.05 } })
step("heterogenous-halogenic-monazite-rare-earth-mixture", "hv-electric-blast-furnace-recipes", 25, HV_SPEED,
	{ { "monazite-rarer-earth-sediment", 1 }, { "chlorine", 100 } },
	{ { "heterogenous-halogenic-monazite-rare-earth-mixture", 1 } })
step("saturated-monazite-rare-earth", MIX, 10, HV_SPEED,
	{ { "heterogenous-halogenic-monazite-rare-earth-mixture", 1 }, { "salt", 1 }, { "acetone", 100 } },
	{ { "saturated-monazite-rare-earth", 1 } })
step("samaric-residue", "ev-centrifuge-recipes", 157.5, EV_SPEED, { { "saturated-monazite-rare-earth", 4 } },
	{ { "samaric-residue", 3 }, { "chloromethane", 40 } })
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
--- Section 6 adds the samaric branch and the red zircon of the sifter (issue #272), section 7 the gangue of the
--- dissolution tank and the 1.3 fluorine of the roasting (issue #274).
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
	{ { "saltpeter", 1 }, { "water", 1000 }, { "conditioned-bastnasite-mud", 100 } },
	{ { "diluted-bastnasite-mud", 1100 }, { "gangue-dust", 1 } })
step("filtered-bastnasite-mud", SIFT, 20, HV_SPEED, { { "diluted-bastnasite-mud", 100 } },
	{ { "filtered-bastnasite-mud", 40 }, { "silicon-dioxide", 1, 0.9 }, { "rutile-dust", 1, 0.75 },
	  { "red-zircon-dust", 1, 0.1 }, { "ilmenite-dust", 1, 0.05 } })
step("bastnasite-rare-earth-oxides", "hv-electric-blast-furnace-recipes", 25, HV_SPEED, { { "filtered-bastnasite-mud", 100 } },
	{ { "bastnasite-rare-earth-oxides", 1 } })
step("acid-leached-bastnasite-rare-earth-oxides", "lv-chemical-bath-recipes", 10, LV_SPEED,
	{ { "bastnasite-rare-earth-oxides", 1 }, { "hydrochloric-acid", 50 } }, { { "acid-leached-bastnasite-rare-earth-oxides", 1 } })
step("roasted-rare-earth-oxides", "mv-electric-blast-furnace-recipes", 30, MV_SPEED,
	{ { "acid-leached-bastnasite-rare-earth-oxides", 1 }, { "oxygen", 100 } },
	{ { "roasted-rare-earth-oxides", 1 }, { "fluorine", 1.3 } })
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
	{ { "neodymium-rare-earth-concentrate", 1, 0.8 }, { "samaric-rare-earth-concentrate", 1, 0.5 }, { "acetone", 45 } })
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

--------------------------------------------------------------------------------
--- 6) EUROPIUM, ZIRCONIUM, LANTHANUM HEXABORIDE AND THE SAMARIC BRANCH (issue #272): the byproducts that sections 3 and
--- 5 left out, with GT's lines for them (GT5-Unofficial af993ca6a9; RL = gtnhlanth/loader/RecipeLoader.java)
---
--- Europium (RL 1469-1494): the monazite separator gives 5 europium(III) oxide at 5 %;
---   chemical reactor: 5 europium(III) oxide + europium dust -> 6 europium oxide (LuV, 15 s)
---   electrolyzer: 2 europium oxide -> europium dust + 100 oxygen (ZPM, 15 s)
---   europium ingot <-> dust: GT's generated macerator recipe (LV, 7.55 s) and blast furnace recipe (MV, 164.85 s;
---   ProcessingDust.java: mass / 40 x 1099 K ticks)
--- Zirconium (RL 866-900, 993-1002; bartworks Electrolyzer.java and its generated Zirconium recipes):
---   the monazite dissolution tank gives 4/9 hafnia-zirconia blend (GT's 4 tiny piles), the monazite sifter 5 % and the
---   bastnasite sifter 10 % red zircon dust;
---   centrifuge: hafnia-zirconia blend -> 3 zirconia (EV, 30 s; GT's 3 hafnia are left out, see below)
---   chemical reactor: 3 zirconia + 400 hydrochloric acid -> 5 zirconium tetrachloride, 200 water (LV, 15 s);
---     5 zirconium tetrachloride + 100 water -> 100 zirconium tetrachloride solution (LV, 10 s)
---   blast furnace: 2 magnesium + 100 solution -> hot zirconium ingot, 6 magnesium chloride (EV, 30 s); zirconium dust
---     -> hot zirconium ingot (HV, 213 s); vacuum freezer: hot -> zirconium ingot (MV, 13.65 s); macerator: ingot ->
---     dust (LV, 5 s)
---   electrolyzer: 6 red zircon dust -> zirconium dust, silicon dioxide, 200 oxygen (MV, 12.5 s)
--- Lanthanum hexaboride (RL 1117-1176; phosgene gtnhlanth/loader/BotRecipes.java 158; boric acid GT's
--- ChemicalRecipes.java 6082; electrolysis generated by bartworks):
---   chemical reactor: 200 chlorine + 100 carbon monoxide -> 100 phosgene (HV, 2.5 s); 23 borax + 200 hydrochloric
---     acid -> 4 salt, 400 boric acid, 500 water (HV, 40 s); 200 boric acid -> boron trioxide, 300 water (EV, 15 s);
---     2 boron + 300 oxygen -> boron trioxide (IV, 30 s); boron trioxide + 300 phosgene -> 200 boron trichloride, 300
---     carbon monoxide (HV, 10 s); 8 lanthanum chloride + 300 water -> lanthanum oxide, 600 hydrochloric acid (HV,
---     10 s); lanthanum dust + 300 hydrochloric acid -> 4 lanthanum chloride, 300 hydrogen (HV, 10 s)
---   autoclave: lanthanum oxide + 800 boron trichloride -> flawless lanthanum hexaboride, 100 boric acid (IV, 60 s)
---   electrolyzer: 5 boron trioxide -> 2 boron + 300 oxygen (MV, 0.3 s); 100 boron trichloride -> boron + 300 chlorine
---     (MV, 5.6 s)
--- Samaric branch (RL 1700-1752): the bastnasite suspension centrifuge gives samaric rare earth concentrate at 50 %;
---   chemical reactor: samaric concentrate + 200 hydrofluoric acid -> fluorinated samaric concentrate (HV, 15 s)
---   blast furnace: 8 fluorinated + 4 calcium -> holmium dust, 4 samarium-terbium mixture, 1200 calcium fluoride (EV,
---     61 s)
---   chemical reactor: mixture + 9 ammonium nitrate dust -> nitrogenated samarium-terbium mixture (HV, 30 s); 4
---     nitrogenated + copper dust -> 2 terbium nitrate, 2 samaric residue (EV, 160 s)
---   electrolyzer: 5 terbium nitrate -> terbium dust, 100 nitrogen, 300 oxygen (MV, 0.7 s, bartworks' generated
---     recipe); 300 calcium fluoride -> calcium, 200 fluorine (MV, 2 s, ElectrolyzerRecipes.java 872)
---   ammonium nitrate dust is GT++'s (gtPlusPlus/core/item/chemistry/RecipeLoaderRocketFuels.java 116-137):
---     chemical plant: 400 ammonia + 400 nitric acid -> 518.4 hydrated ammonium nitrate slurry (MV, 60 s)
---     dehydrator: 115.2 slurry -> 8 ammonium nitrate dust, 200 water (HV, 90 s)
--- The two GT++ machines: the ExxonMobil Chemical Plant (a 3x3 copy of the chemical reactor like the digester; GT's
--- controller recipe RecipesMachinesCustom.java 339: MV casings, aluminium gears, annealed copper plates, black steel; the
--- 4 large polyethylene pipes are 24 polyethylene sheets and the 4 black metal frames black steel frames, Gregtorio has
--- neither) and the MV and HV Dehydrators (GregtechDehydrator.java 171-185: hull, robot arm, circuit, fine wire, 2x 4x
--- cables, gears; 3x3 copies of the chemical bath of their tier). Section 7 adds the EV to ZPM Dehydrators and
--- hafnium from GT++'s ilmenite sifter (issue #274); GT's hafnia route needs iodine, which Gregtorio has no source
--- for, and GTNH's samarium chain samarium ore (#154).
--------------------------------------------------------------------------------

local EUROPIUM, ZIRCONIUM, HEXABORIDE, SAMARIC = "europium-processing", "zirconium-processing", "lanthanum-hexaboride",
	"samaric-rare-earth-processing"
for _, name in pairs({
	"europium-iii-oxide", "europium-oxide", "europium-dust",
	"hafnia-zirconia-blend", "zirconia", "zirconium-tetrachloride", "hot-zirconium-ingot", "zirconium-ingot", "red-zircon-dust",
	"lanthanum-oxide", "boron-trioxide", "flawless-lanthanum-hexaboride",
	"samaric-rare-earth-concentrate", "fluorinated-samaric-concentrate", "samarium-terbium-mixture",
	"nitrogenated-samarium-terbium-mixture", "terbium-nitrate", "terbium-dust", "holmium-dust", "ammonium-nitrate-dust",
}) do
	if not data.raw.item[name] then
		create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes" }
	end
end
F.fluid("zirconium-tetrachloride-solution", "nearly-white-fluid", { 0.70, 0.64, 0.59 })
F.fluid("phosgene", "forest-green-fluid", { 0.08, 0.63, 0.10 })
F.fluid("boric-acid", "purple-fluid", { 0.35, 0.12, 0.47 })
F.fluid("boron-trichloride", "purple-fluid", { 0.60, 0.38, 0.82 })
F.fluid("calcium-fluoride", "nearly-white-fluid", { 1.00, 0.98, 0.98 })
F.fluid("hydrated-ammonium-nitrate-slurry", "purple-fluid", { 0.59, 0.29, 0.59 })

--- the GT++ machines (the Chemical Plant like the digester above; the Dehydrators keep their chemical bath's size and power)
for _, t in pairs({ "lv", "mv", "hv" }) do F.category(t .. "-dehydrator-recipes") end
F.category("chemical-plant-recipes")
RECIPES = {}
machine{
	name = "exxonmobil-chemical-plant", source = "hv-chemical-reactor", category = "chemical-plant-recipes", speed = MV_SPEED,
	energy = EU16_MV, subgroup = "subgroup-mv-age-multiblocks",
	ports = { port("input", N, { -1, -1 }), port("input", N, { 1, -1 }), port("output", S, { 0, 1 }) },
	recipe = { "mv-assembling-machine-recipes", 120 * MV_SPEED, {
		{ type = "item", name = "mv-machine-casing", amount = 4 },
		{ type = "item", name = "large-aluminium-gear", amount = 4 },
		{ type = "item", name = "annealed-copper-plate", amount = 16 },
		{ type = "item", name = "polyethylene-sheet", amount = 24 },
		{ type = "item", name = "black-steel-frame", amount = 4 },
		{ type = "fluid", name = "molten-black-steel", amount = 115.2 },
	} },
}
local DEHYDRATORS = {
	{ "mv", "mv-chemical-bath", { "lv-dehydrator-recipes", "mv-dehydrator-recipes" }, MV_SPEED, "mv-age-production-machine", {
		{ type = "item", name = "fine-red-alloy-wire", amount = 2 },
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 8 },
		{ type = "item", name = "mv-machine-hull", amount = 1 },
		{ type = "item", name = "large-steel-gear", amount = 2 },
		{ type = "item", name = "mv-robot-arm", amount = 1 },
	} },
	{ "hv", "hv-chemical-bath", { "lv-dehydrator-recipes", "mv-dehydrator-recipes", "hv-dehydrator-recipes" }, HV_SPEED,
	  "hv-age-production-machine", {
		{ type = "item", name = "fine-electrum-wire", amount = 2 },
		{ type = "item", name = "processing-unit", amount = 1 },
		{ type = "item", name = "silver-cable", amount = 8 },
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "large-potin-gear", amount = 2 },
		{ type = "item", name = "hv-robot-arm", amount = 1 },
	} },
}
for _, d in pairs(DEHYDRATORS) do
	local src = data.raw["assembling-machine"][d[2]]
	machine{
		name = d[1] .. "-dehydrator", source = d[2], category = d[3][1], speed = d[4], energy = src.energy_usage,
		subgroup = d[5], ports = { port("input", N, { 0, -1 }), port("output", S, { 0, 1 }) },
		recipe = { "crafting-or-assembling-recipes", 1, d[6] },
	}
	local m = data.raw["assembling-machine"][d[1] .. "-dehydrator"]
	m.crafting_categories = d[3]
	m.fast_replaceable_group = "fr-dehydrator"
end
data.raw["assembling-machine"]["mv-dehydrator"].next_upgrade = "hv-dehydrator"

--- the samaric branch
step("hydrated-ammonium-nitrate-slurry", "chemical-plant-recipes", 60, MV_SPEED,
	{ { "ammonia", 400 }, { "nitric-acid", 400 } }, { { "hydrated-ammonium-nitrate-slurry", 518.4 } })
step("ammonium-nitrate-dust", "hv-dehydrator-recipes", 90, HV_SPEED, { { "hydrated-ammonium-nitrate-slurry", 115.2 } },
	{ { "ammonium-nitrate-dust", 8 }, { "water", 200 } })
step("fluorinated-samaric-concentrate", CR, 15, HV_SPEED,
	{ { "samaric-rare-earth-concentrate", 1 }, { "hydrofluoric-acid", 200 } }, { { "fluorinated-samaric-concentrate", 1 } })
step("samarium-terbium-mixture", "ev-electric-blast-furnace-recipes", 61, EV_SPEED,
	{ { "fluorinated-samaric-concentrate", 8 }, { "calcium", 4 } },
	{ { "samarium-terbium-mixture", 4 }, { "holmium-dust", 1 }, { "calcium-fluoride", 1200 } })
step("nitrogenated-samarium-terbium-mixture", CR, 30, HV_SPEED,
	{ { "samarium-terbium-mixture", 1 }, { "ammonium-nitrate-dust", 9 } }, { { "nitrogenated-samarium-terbium-mixture", 1 } })
step("terbium-nitrate", "ev-chemical-reactor-recipes", 160, EV_SPEED,
	{ { "nitrogenated-samarium-terbium-mixture", 4 }, { "copper-dust", 1 } },
	{ { "terbium-nitrate", 2 }, { "samaric-residue", 2 } })
step("terbium-nitrate-electrolysis", "mv-electrolyzer-recipes", 0.7, MV_SPEED, { { "terbium-nitrate", 5 } },
	{ { "terbium-dust", 1 }, { "nitrogen", 100 }, { "oxygen", 300 } })
step("calcium-fluoride-electrolysis", "mv-electrolyzer-recipes", 2, MV_SPEED, { { "calcium-fluoride", 300 } },
	{ { "calcium", 1 }, { "fluorine", 200 } })
F.tech{
	-- (large-extractor and industrial-electrolyzer make the black steel frame and the potin gear of the machines, #252)
	name = SAMARIC, prerequisites = { BASTNASITE, "large-extractor", "industrial-electrolyzer", "rocket-fuel" },
	packs = 6, count = 800, time = 45, recipes = RECIPES,
}
--- issue #295: GTNH's rocket fuel (GT++'s H8N4C2O4 Rocket Fuel, RecipeLoaderRocketFuels.java:234-244: 2000 L
--- 1,1-dimethylhydrazine + 2000 L nitrogen tetroxide -> 5000 L, chemical plant, HV, 60 s; GT's casing tier 6 has no
--- counterpart in the one Chemical Plant here) instead of upstream's LV mixer recipe (100 + 100 -> 600, 3 s). The
--- Chemical Plant comes with its first consumer, Rocket Fuel (HV), and with it its black steel frame (#252's rule: the
--- producer moves up to its first consumer; the frame's black steel is MV)
do
	local rf = data.raw.recipe["rocket-fuel"]
	rf.category = "chemical-plant-recipes"
	rf.energy_required = 60 * HV_SPEED
	rf.ingredients = { { type = "fluid", name = "dimethylhydrazine", amount = 2000 },
		{ type = "fluid", name = "dinitrogen-tetroxide", amount = 2000 } }
	rf.results = { { type = "fluid", name = "rocket-fuel", amount = 5000 } }
	rf.subgroup = data.raw.recipe["hydrated-ammonium-nitrate-slurry"].subgroup
	for _, t in pairs(data.raw.technology) do
		local keep = {}
		for _, e in pairs(t.effects or {}) do
			if not (e.type == "unlock-recipe" and (e.recipe == "exxonmobil-chemical-plant" or e.recipe == "black-steel-frame")) then
				keep[#keep + 1] = e
			end
		end
		t.effects = keep
	end
	local rft = data.raw.technology["rocket-fuel"].effects
	rft[#rft + 1] = { type = "unlock-recipe", recipe = "exxonmobil-chemical-plant" }
	rft[#rft + 1] = { type = "unlock-recipe", recipe = "black-steel-frame" }
end

--- europium
RECIPES = {}
step("europium-dust", "lv-macerator-recipes", 7.55, LV_SPEED, { { "europium-ingot", 1 } }, { { "europium-dust", 1 } })
step("europium-ingot-from-dust", "mv-electric-blast-furnace-recipes", 164.85, MV_SPEED, { { "europium-dust", 1 } },
	{ { "europium-ingot", 1 } })
step("europium-oxide", "luv-chemical-reactor-recipes", 15, LUV_SPEED,
	{ { "europium-iii-oxide", 5 }, { "europium-dust", 1 } }, { { "europium-oxide", 6 } })
step("europium-oxide-electrolysis", "zpm-electrolyzer-recipes", 15, ZPM_SPEED, { { "europium-oxide", 2 } },
	{ { "europium-dust", 1 }, { "oxygen", 100 } })
F.tech{
	name = EUROPIUM, prerequisites = { TECH, "zpm-machines" }, packs = 8, count = 1000, time = 45,
	recipes = RECIPES,
}

--- zirconium
RECIPES = {}
step("zirconia", "ev-centrifuge-recipes", 30, EV_SPEED, { { "hafnia-zirconia-blend", 1 } }, { { "zirconia", 3 } })
step("zirconium-tetrachloride", "lv-chemical-reactor-recipes", 15, LV_SPEED,
	{ { "zirconia", 3 }, { "hydrochloric-acid", 400 } }, { { "zirconium-tetrachloride", 5 }, { "water", 200 } })
step("zirconium-tetrachloride-solution", "lv-chemical-reactor-recipes", 10, LV_SPEED,
	{ { "zirconium-tetrachloride", 5 }, { "water", 100 } }, { { "zirconium-tetrachloride-solution", 100 } })
step("hot-zirconium-ingot", "ev-electric-blast-furnace-recipes", 30, EV_SPEED,
	{ { "magnesium", 2 }, { "zirconium-tetrachloride-solution", 100 } },
	{ { "hot-zirconium-ingot", 1 }, { "magnesium-chloride", 6 } })
step("hot-zirconium-ingot-from-dust", "hv-electric-blast-furnace-recipes", 213, HV_SPEED, { { "zirconium-dust", 1 } },
	{ { "hot-zirconium-ingot", 1 } })
step("zirconium-ingot", "mv-vacuum-freezer-recipes", 13.65, MV_SPEED, { { "hot-zirconium-ingot", 1 } },
	{ { "zirconium-ingot", 1 } })
step("zirconium-dust-from-ingot", "lv-macerator-recipes", 5, LV_SPEED, { { "zirconium-ingot", 1 } }, { { "zirconium-dust", 1 } })
step("red-zircon-dust-electrolysis", "mv-electrolyzer-recipes", 12.5, MV_SPEED, { { "red-zircon-dust", 6 } },
	{ { "zirconium-dust", 1 }, { "silicon-dioxide", 1 }, { "oxygen", 200 } })
F.tech{
	name = ZIRCONIUM, prerequisites = { TECH }, packs = 6, count = 600, time = 45,
	recipes = RECIPES,
}

--- lanthanum hexaboride
RECIPES = {}
step("phosgene", CR, 2.5, HV_SPEED, { { "chlorine", 200 }, { "carbon-monoxide", 100 } }, { { "phosgene", 100 } })
step("boric-acid", CR, 40, HV_SPEED, { { "borax", 23 }, { "hydrochloric-acid", 200 } },
	{ { "boric-acid", 400 }, { "salt", 4 }, { "water", 500 } })
step("boron-trioxide", "ev-chemical-reactor-recipes", 15, EV_SPEED, { { "boric-acid", 200 } },
	{ { "boron-trioxide", 1 }, { "water", 300 } })
step("boron-trioxide-from-boron", "iv-chemical-reactor-recipes", 30, IV_SPEED, { { "boron", 2 }, { "oxygen", 300 } },
	{ { "boron-trioxide", 1 } })
step("boron-trichloride", CR, 10, HV_SPEED, { { "boron-trioxide", 1 }, { "phosgene", 300 } },
	{ { "boron-trichloride", 200 }, { "carbon-monoxide", 300 } })
step("lanthanum-oxide", CR, 10, HV_SPEED, { { "lanthanum-chloride", 8 }, { "water", 300 } },
	{ { "lanthanum-oxide", 1 }, { "hydrochloric-acid", 600 } })
step("lanthanum-chloride-from-lanthanum", CR, 10, HV_SPEED, { { "lanthanum-dust", 1 }, { "hydrochloric-acid", 300 } },
	{ { "lanthanum-chloride", 4 }, { "hydrogen", 300 } })
step("flawless-lanthanum-hexaboride", "iv-autoclave-recipes", 60, IV_SPEED,
	{ { "lanthanum-oxide", 1 }, { "boron-trichloride", 800 } },
	{ { "flawless-lanthanum-hexaboride", 1 }, { "boric-acid", 100 } })
step("boron-trioxide-electrolysis", "mv-electrolyzer-recipes", 0.3, MV_SPEED, { { "boron-trioxide", 5 } },
	{ { "boron", 2 }, { "oxygen", 300 } })
step("boron-trichloride-electrolysis", "mv-electrolyzer-recipes", 5.6, MV_SPEED, { { "boron-trichloride", 100 } },
	{ { "boron", 1 }, { "chlorine", 300 } })
F.tech{
	name = HEXABORIDE, prerequisites = { BASTNASITE, "iv-machines" }, packs = 6, count = 800, time = 45,
	recipes = RECIPES,
}

--------------------------------------------------------------------------------
--- 7) HAFNIUM, THE EV TO ZPM DEHYDRATORS, LANTHANUM HEXABORIDE'S FORMS AND SMALL BYPRODUCTS (issue #274)
---
--- Hafnium without iodine: GT++'s sifter of purified ilmenite (gtPlusPlus/xmod/gregtech/loaders/recipe/
--- RecipeLoaderNuclear.java 551-565): iron 50 %, zirconium 2 x 10 %, hafnium 2 x 3 % (HV, 30 s; GT's cast iron dust,
--- 2.78 %, is left out: Gregtorio has no cast iron). Hafnium is bartworks' Werkstoff without a blast furnace: its dust
--- smelts into the ingot in the furnace, the macerator grinds the ingot (5 s). GT's hafnia route (hafnium tetrachloride,
--- low-purity hafnium, hafnium iodide) waits for an iodine source.
---
--- The Chemical Dehydrators I to IV (EV to ZPM, GT++'s GregtechDehydrator.java 68-209): hull, robot arm, circuit, a
--- dehydrator coil, 2x 4x cables (8 cables) and 2 gears of the tier, like the MV and HV ones of section 6. The coil
--- (assembler, 8 s) is 4 coil wires on a medium pipe (GT's bronze, steel, stainless steel and titanium; Gregtorio has no
--- GT pipes: 3 plates, a medium pipe's metal); the coil wire comes from GT++'s laser engraver recipes
--- (RecipesLaserEngraver.java 49-110): a 2x wire (2 wires) of aluminium or nichrome (HV, 10 s), platinum (EV, 20 s;
--- GT's osmium wire is not in Gregtorio), vanadium-gallium or niobium-titanium (IV, 30 s; no YBCO wire) or naquadah (LuV,
--- 40 s), with a lime lens, which stays (Gregtorio has none: the green emerald lens). Substitutes for parts Gregtorio
--- lacks: the LuV Dehydrator's Hastelloy-N gears are Hastelloy-X gears, the ZPM one's osmium cables naquadah cables (the
--- ZPM chemical bath's cable). Each tier has its own technology after the one of its chemical bath.
---
--- Lanthanum hexaboride's forms (bartworks' GemLoader.java and SimpleMetalLoader.java for its Werkstoff, GT's
--- LatheRecipes.java 31), as 155 makes them for the gem ores:
---   forge hammer        exquisite -> 2 flawless -> 2 gems -> 2 flawed -> 2 chipped -> a tiny pile (3.2 s); 2 rods -> a
---                       long rod (10 s)
---   implosion           3 chipped -> flawed, 3 flawed -> gem, 3 gems -> flawless, 3 flawless -> exquisite, with an
---                       explosive for GT's 8 TNT, and 2 tiny piles of dark ash; 4 dusts -> 3 gems with 3 explosives
---                       and 8 tiny piles (1 s)
---   lathe               exquisite -> lens + 2 dusts (2 min); gem -> rod + 2 small piles (50 s); flawless -> long rod +
---                       dust (GT, 100 s)
---   laser engraver      3 chipped -> flawed, 3 flawed -> gem, 3 gems -> flawless, 3 flawless -> exquisite with a red
---                       lens (bartworks' dye of its colour 140, 110, 120 is red: the ruby lens), LV to EV as 155's
--- Small byproducts (sections 3 and 5): GT's 400 L chloromethane of the samaric residue centrifuge (40), the gangue of the
--- bastnasite dissolution tank and the 13 L fluorine of the roasting (1.3).
--------------------------------------------------------------------------------

local function unlock_in(tech, names)
	local t = data.raw.technology[tech]
	for _, n in pairs(names) do
		data.raw.recipe[n].enabled = false
		t.effects[#t.effects + 1] = { type = "unlock-recipe", recipe = n }
	end
end

for _, name in pairs({ "hafnium-dust", "hafnium-ingot", "gangue-dust" }) do
	if not data.raw.item[name] then create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes" } end
end

--- hafnium (and zirconium) from purified ilmenite
RECIPES = {}
step("sifting-purified-ilmenite", SIFT, 30, HV_SPEED, { { "purified-ilmenite", 1 } },
	{ { "iron-dust", 1, 0.5 }, { "zirconium-dust", 1, 0.1 }, { "zirconium-dust", 1, 0.1 }, { "hafnium-dust", 1, 0.03 },
	  { "hafnium-dust", 1, 0.03 } })
step("hafnium-ingot", "smelting", 10, 1, { { "hafnium-dust", 1 } }, { { "hafnium-ingot", 1 } })
step("hafnium-dust-from-ingot", "lv-macerator-recipes", 5, LV_SPEED, { { "hafnium-ingot", 1 } }, { { "hafnium-dust", 1 } })
unlock_in(ZIRCONIUM, RECIPES)

--- the Chemical Dehydrators I to IV
for _, t in pairs({ "ev", "iv", "luv", "zpm" }) do F.category(t .. "-dehydrator-recipes") end
local DEHYDRATOR_TIERS = {
	--  tier   speed       engraver (s)  wires                                          coil pipe (3 plates)  assembler   cable                            gear                       circuit
	{ "ev",  EV_SPEED,  10, HV_SPEED,  { "aluminium-wire", "nichrome-wire" },                 "bronze-plate",           MV_SPEED, "aluminium-cable",               "large-tumbaga-gear",      "ev-circuit", { "large-sifter" } },
	{ "iv",  IV_SPEED,  20, EV_SPEED,  { "platinum-wire" },                                    "steel-plate",            HV_SPEED, "tungsten-cable",                "large-inconel-690-gear",  "iv-circuit", { "industrial-extrusion-machine" } },
	{ "luv", LUV_SPEED, 30, IV_SPEED,  { "vanadium-gallium-wire", "niobium-titanium-wire" },  "stainless-steel-plate",  HV_SPEED, "naquadah-cable",                "large-hastelloy-x-gear",  "luv-circuit", { "hyper-intensity-laser-engraver", "zpm-materials" } },
	{ "zpm", ZPM_SPEED, 40, LUV_SPEED, { "naquadah-wire" },                                    "titanium-plate",         EV_SPEED, "naquadah-cable",                "large-zeron-100-gear",    "zpm-circuit", {} },
}
local ENGRAVER_OF = { [HV_SPEED] = "hv", [EV_SPEED] = "ev", [IV_SPEED] = "iv", [LUV_SPEED] = "luv" }
local TIER_ORDER = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm" }
local previous = "hv-dehydrator"
for i, d in ipairs(DEHYDRATOR_TIERS) do
	local t = d[1]
	local wire, coil = t .. "-dehydrator-coil-wire", t .. "-dehydrator-coil"
	for _, name in pairs({ wire, coil }) do
		create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes",
			icon = "__gregtorio-continued__/graphics/icons/fork/" .. name .. ".png" }
	end
	RECIPES = {}
	for _, w in pairs(d[5]) do
		step(wire .. "-from-" .. w, ENGRAVER_OF[d[4]] .. "-laser-engraver-recipes", d[3], d[4],
			{ { w, 2 }, { "emerald-lens", 1 } }, { { wire, 1 }, { "emerald-lens", 1 } }, wire)
	end
	step(coil, (t == "ev" and "mv" or t == "iv" and "hv" or t == "luv" and "hv" or "ev") .. "-assembling-machine-recipes", 8,
		d[7], { { wire, 4 }, { d[6], 3 } }, { { coil, 1 } })
	local categories = {}
	for k = 1, 3 + i do categories[#categories + 1] = TIER_ORDER[k] .. "-dehydrator-recipes" end
	local src = data.raw["assembling-machine"][t .. "-chemical-bath"]
	machine{
		name = t .. "-dehydrator", source = t .. "-chemical-bath", category = categories[#categories], speed = d[2],
		energy = src.energy_usage, subgroup = data.raw.item[t .. "-chemical-bath"].subgroup,
		ports = { port("input", N, { 0, -1 }), port("output", S, { 0, 1 }) },
		recipe = { "crafting-or-assembling-recipes", 1, {
			{ type = "item", name = coil, amount = 2 },
			{ type = "item", name = d[10], amount = 1 },
			{ type = "item", name = d[8], amount = 8 },
			{ type = "item", name = t .. "-machine-hull", amount = 1 },
			{ type = "item", name = d[9], amount = 2 },
			{ type = "item", name = t .. "-robot-arm", amount = 1 },
		} },
	}
	local m = data.raw["assembling-machine"][t .. "-dehydrator"]
	m.crafting_categories = categories
	m.fast_replaceable_group = "fr-dehydrator"
	data.raw["assembling-machine"][previous].next_upgrade = m.name
	previous = m.name
	--- its own technology after the one of the tier's chemical bath and the ones that make its gears and cables (#252)
	local bath_tech
	for tname, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and e.recipe == t .. "-chemical-bath" then bath_tech = tname end
		end
	end
	local prereqs = { bath_tech }
	for _, p in pairs(d[11]) do prereqs[#prereqs + 1] = p end
	F.tech{
		name = t .. "-chemical-dehydrator", prerequisites = prereqs,
		packs = #data.raw.technology[bath_tech].unit.ingredients, count = 500, time = 45, recipes = RECIPES,
	}
end

--- lanthanum hexaboride's forms
local LAB6 = "lanthanum-hexaboride"
local G = { chipped = "chipped-" .. LAB6, flawed = "flawed-" .. LAB6, gem = LAB6, flawless = "flawless-" .. LAB6,
	exquisite = "exquisite-" .. LAB6 }
local DUST, SMALL, TINY = LAB6 .. "-dust", "small-pile-of-" .. LAB6 .. "-dust", "tiny-pile-of-" .. LAB6 .. "-dust"
local LENS, ROD, LONG = LAB6 .. "-lens", LAB6 .. "-rod", "long-" .. LAB6 .. "-rod"
for _, name in pairs({ G.chipped, G.flawed, G.gem, G.exquisite, DUST, SMALL, TINY, LENS, ROD, LONG }) do
	create_item{ skip_recipe = true, name = name, subgroup = "subgroup-digester-recipes" }
end
RECIPES = {}
local GRADES = { "chipped", "flawed", "gem", "flawless", "exquisite" }
local ENGRAVE = { chipped = { "mv", 30 }, flawed = { "mv", 60 }, gem = { "hv", 240 }, flawless = { "ev", 960 } }
for i, k in ipairs(GRADES) do
	local up, down = GRADES[i + 1], GRADES[i - 1]
	if down then
		step("hammering-" .. G[k], "lv-forge-hammer-recipes", 3.2, LV_SPEED, { { G[k], 1 } }, { { G[down], 2 } })
	end
	if up then
		step("implosion-" .. G[k] .. "-to-" .. up, "lv-implosion-compressor-recipes", 1, LV_SPEED,
			{ { G[k], 3 }, { "explosives", 1 } }, { { G[up], 1 }, { "tiny-pile-of-dark-ash-dust", 2 } })
		step("engraving-" .. G[k] .. "-to-" .. up, ENGRAVE[k][1] .. "-laser-engraver-recipes", ENGRAVE[k][2], 1,
			{ { G[k], 3 }, { "ruby-lens", 1 } }, { { G[up], 1 }, { "ruby-lens", 1 } })
	end
end
step("hammering-" .. G.chipped, "lv-forge-hammer-recipes", 3.2, LV_SPEED, { { G.chipped, 1 } }, { { TINY, 1 } })
step("implosion-" .. DUST .. "-to-gem", "lv-implosion-compressor-recipes", 1, LV_SPEED, { { DUST, 4 }, { "explosives", 3 } },
	{ { G.gem, 3 }, { "tiny-pile-of-dark-ash-dust", 8 } })
step(LENS, "lv-lathe-recipes", 120, LV_SPEED, { { G.exquisite, 1 } }, { { LENS, 1 }, { DUST, 2 } })
step(ROD, "lv-lathe-recipes", 50, LV_SPEED, { { G.gem, 1 } }, { { ROD, 1 }, { SMALL, 2 } })
step(LONG, "lv-forge-hammer-recipes", 10, LV_SPEED, { { ROD, 2 } }, { { LONG, 1 } })
step(LONG .. "-from-flawless", "lv-lathe-recipes", 100, LV_SPEED, { { G.flawless, 1 } }, { { LONG, 1 }, { DUST, 1 } })
step(DUST .. "-from-small-piles", "crafting", 0.5, 1, { { SMALL, 4 } }, { { DUST, 1 } })
step(DUST .. "-from-tiny-piles", "crafting", 0.5, 1, { { TINY, 9 } }, { { DUST, 1 } })
--- (the crafting table's rows: next to the line's items, not a subgroup of their own)
for _, n in pairs({ DUST .. "-from-small-piles", DUST .. "-from-tiny-piles" }) do
	data.raw.recipe[n].subgroup = "subgroup-digester-recipes"
end
unlock_in(HEXABORIDE, RECIPES)
