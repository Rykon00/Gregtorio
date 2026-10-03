--------------------------------------------------------------------------------
--- FORK PLATINUM LINE (issue #96): GregTech New Horizons' platinum group line (bartworks) instead of the GregTech
--- CEu line upstream took (19-iv-age-item.lua) and the direct platinum and palladium dust recipes.
--- Sources (GT5-Unofficial): bartworks/system/material/gtenhancement/PlatinumSludgeRecipes.java (PSR below), the
--- materials in bartworks/system/material/WerkstoffLoader.java, the output redirection in PlatinumSludgeOutputs.java,
--- the sludge in gregtech/loaders/postload/recipes/ChemicalRecipes.java:104-122 and CentrifugeRecipes.java:86-98.
---   1) reagents: aqua regia, ammonium chloride (a fluid in GT), formic acid at GT's ratios
---   2) the sludge sources and the platinum concentrate from ores
---   3) platinum: concentrate, platinum salt, refined salt, reprecipitated platinum -> platinum dust
---   4) palladium: palladium enriched ammonia, palladium salt, reprecipitated palladium -> palladium dust
---   5) bartworks' rule: whatever gave platinum or palladium dust gives the metallic powder instead (x2); the shortcuts
---      go, the quantum force transformer recipes (139) stay
---   6) the GTCEu platinum and palladium intermediates are deleted (FORK-REMOVED); old saves map them to their GTNH
---      counterparts (migrations/)
---   7) the residue branches: rhodium, ruthenium, osmium and iridium from the platinum residue and the residues of the
---      sludge centrifuge, as bartworks has them; their GTCEu intermediates are deleted the same way
--- The six technologies keep their names; their recipes: the block "issue #96" of UNLOCKS in 142.
--- Amounts: fluids at a tenth of GT's litres, items as in GT, GT's voltage as the recipe tier (time: GT's seconds
--- times the tier's speed). Where GT has a small and a bulk variant of a recipe (tiny dust outputs), the bulk one is
--- taken, or the tiny dust is a 1/9 chance. Loaded after 147 (the GT routes) and before 142.
--------------------------------------------------------------------------------

local F = FORK5B
local TINY = 1 / 9

local gone_recipe = {}
local function remove(kind, name)
	if data.raw[kind][name] then
		data.raw[kind][name] = nil
		log("FORK-REMOVED: " .. kind .. " " .. name)
	end
	if kind == "recipe" then gone_recipe[name] = true end
end
local function remove_fluid(name)
	remove("fluid", name)
	remove("recipe", "void-" .. name)
end
local function item(name, amount, probability)
	return { type = "item", name = name, amount = amount, probability = probability }
end
local function fluid(name, amount)
	return { type = "fluid", name = name, amount = amount }
end
local function recipe(name, category, time, ingredients, results, main)
	if data.raw.recipe[name] then data.raw.recipe[name] = nil end   -- redefined: same name, so machines keep it
	create_recipe{ name = name, category = category, energy_required = time, ingredients = ingredients,
		results = results, main_product = main or results[1].name }
end
local function new_item(name, category)
	create_item{ skip_recipe = true, name = name, subgroup = "subgroup-" .. category }
end
--- an existing ingredient or result renamed in a recipe (the bridge)
local function swap(recipe_name, from, to, kind, amount)
	local r = data.raw.recipe[recipe_name]
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r and r[key] or {}) do
			if i.name == from then
				i.name, i.type = to, kind or i.type
				if amount then i.amount = amount end
			end
		end
	end
end



--------------------------------------------------------------------------------
--- 6) THE GTCEu PLATINUM AND PALLADIUM INTERMEDIATES (first, so the names are free)
--------------------------------------------------------------------------------

for _, r in pairs({
	"platinum-group-sludge-bornite", "platinum-group-sludge-tetrahedrite", "platinum-group-sludge-sheldonite",
	"platinum-group-sludge-processing", "platinum-sludge-residue-processing", "platinum-palladium-leachate-processing",
	"metallic-platinum-powder", "metallic-platinum-powder-processing", "chloroplatinic-acid", "raw-platinum-powder",
	"platinum-dust", "crude-palladium-residue", "metallic-palladium-powder", "palladium-rich-ammonia-processing",
	"raw-palladium-powder-processing", "ammonium-chloride",
	--- shortcuts: the washer recipe of crushed palladium (renamed below), the ore smelted into its dust
	"palladium-dust", "raw-sheldonite-smelter", "raw-sheldonite-multismelter",
}) do remove("recipe", r) end
for _, i in pairs({ "ammonia-hexachloroplatinate", "crude-platinum-residue", "raw-platinum-powder",
	"crude-palladium-residue", "raw-palladium-powder", "platinum-sludge-residue", "ammonium-chloride",
	"platinum-group-residue" }) do
	remove("item", i)
end
for _, f in pairs({ "platinum-palladium-leachate", "chloroplatinic-acid", "palladium-rich-ammonia" }) do remove_fluid(f) end



--------------------------------------------------------------------------------
--- 1) REAGENTS
--------------------------------------------------------------------------------

--- aqua regia: 3000 L HCl + 1000 L nitric acid -> 4000 L, LV, 1.5 s (PSR:173-205)
recipe("aqua-regia", "lv-mixer-recipes", 1.5, { fluid("hydrochloric-acid", 300), fluid("nitric-acid", 100) },
	{ fluid("aqua-regia", 400) })
--- ammonium chloride, a fluid: 1000 L ammonia + 1000 L HCl -> 1000 L, LV, 0.75 s (PSR:209-216)
F.fluid("ammonium-chloride", "nearly-white-fluid", { 1.00, 1.00, 1.00 })
recipe("ammonium-chloride", "lv-chemical-reactor-recipes", 0.75, { fluid("ammonia", 100), fluid("hydrochloric-acid", 100) },
	{ fluid("ammonium-chloride", 100) })
--- formic acid: 2000 L sodium formate + 1000 L sulfuric acid -> 2000 L + 7 sodium sulfate, LV, 0.75 s (PSR:155-161);
--- sodium formate (17-ev-age-item.lua) is GT's already (PSR:147-152)
recipe("formic-acid", "lv-chemical-reactor-recipes", 0.75, { fluid("sodium-formate", 200), fluid("sulfuric-acid", 100) },
	{ fluid("formic-acid", 200), item("sodium-sulfate", 7) })



--------------------------------------------------------------------------------
--- 2) SLUDGE AND CONCENTRATE FROM ORES
--- GT: crushed purified pentlandite + 1000 L sulfuric acid -> a tiny pile of platinum group sludge + 2000 L nickel
--- sulfate, LV, 2.5 s (ChemicalRecipes.java:104-112; Gregtorio: crushed ore, its sulfuric nickel solution with the
--- electrolysis of 19); chalcopyrite (:114-122, blue vitriol: Gregtorio's sulfuric copper solution) has no ore here, only
--- its dust (from rare earth), which takes the place of the crushed ore in its two recipes. The sludge in the centrifuge, 3 -> silicon dioxide 3,
--- gold 3, metallic platinum powder 6, metallic palladium powder 2 (95 %), iridium metal residue 2 (90 %), rarest metal
--- residue 2 (85 %), LV, 135 s (CentrifugeRecipes.java:86-98; Gregtorio's names: iridium metal residue, rarest metal
--- mixture). The ores with platinum group metals go straight into the concentrate: crushed purified ore + 300 L aqua
--- regia -> 300 L platinum concentrate, LV, 12.5 s (PSR:266-297: cooperite = sheldonite, tetrahedrite, chalcopyrite,
--- pentlandite; PSR:237-265: bornite and the other Werkstoff ores with sulfur and copper or nickel).
--------------------------------------------------------------------------------

recipe("platinum-group-sludge-pentlandite", "lv-chemical-reactor-recipes", 2.5,
	{ item("crushed-pentlandite", 1), fluid("sulfuric-acid", 100) },
	{ item("platinum-group-sludge", 1, TINY), fluid("sulfuric-nickel-solution", 200) })
recipe("platinum-group-sludge-chalcopyrite", "lv-chemical-reactor-recipes", 2.5,
	{ item("chalcopyrite-dust", 1), fluid("sulfuric-acid", 100) },
	{ item("platinum-group-sludge", 1, TINY), fluid("sulfuric-copper-solution", 200) })
recipe("platinum-group-sludge-centrifuging", "lv-centrifuge-recipes", 135, { item("platinum-group-sludge", 3) }, {
	item("metallic-platinum-powder", 6), item("silicon-dioxide", 3), item("gold-dust", 3),
	item("metallic-palladium-powder", 2, 0.95), item("iridium-metal-residue", 2, 0.9), item("rarest-metal-mixture", 2, 0.85),
})
F.fluid("platinum-concentrate", "spackled-yellow-fluid", { 1.00, 1.00, 0.78 })
FORK_PLATINUM_LINE = { feeds = {} }
for _, ore in pairs({ "pentlandite", "bornite", "tetrahedrite", "sheldonite", "chalcopyrite" }) do
	local name = "platinum-concentrate-from-" .. ore
	local input = ore == "chalcopyrite" and "chalcopyrite-dust" or ("crushed-" .. ore)
	recipe(name, "lv-chemical-reactor-recipes", 12.5, { item(input, 1), fluid("aqua-regia", 30) },
		{ fluid("platinum-concentrate", 30) })
	FORK_PLATINUM_LINE.feeds[#FORK_PLATINUM_LINE.feeds + 1] = name
end



--------------------------------------------------------------------------------
--- 3) PLATINUM (PSR:299-393)
---   metallic powder + 2000 L aqua regia -> 2000 L concentrate + a tiny pile of platinum residue, LV, 12.5 s (:309-317)
---   36000 L concentrate + 3600 L ammonium chloride -> platinum salt 16, reprecipitated platinum 4, 3600 L palladium
---     enriched ammonia, 9000 L nitrogen dioxide, 27000 L HCl, large chemical reactor, HV, 35 s (:350-360)
---   sifter: platinum salt -> refined platinum salt (9 slots, 95 % in all), LV, 30 s (:361-376)
---   blast furnace: refined platinum salt -> metallic powder + 87 L chlorine, MV, 10 s, 900 K (:377-385)
---   4 reprecipitated platinum + calcium -> 2 platinum dust + 3 calcium chloride, LV, 1.5 s (:387-392)
--- GT's blast furnace recipe of 3 metallic powder -> 2 platinum nuggets (:301-308) is left out: Gregtorio has no
--- platinum nuggets.
--------------------------------------------------------------------------------

new_item("platinum-salt", "hv-chemical-reactor-recipes")
new_item("refined-platinum-salt", "lv-sifter-recipes")
new_item("reprecipitated-platinum", "hv-chemical-reactor-recipes")
new_item("platinum-residue", "lv-chemical-reactor-recipes")
recipe("platinum-concentrate", "lv-chemical-reactor-recipes", 12.5,
	{ item("metallic-platinum-powder", 1), fluid("aqua-regia", 200) },
	{ fluid("platinum-concentrate", 200), item("platinum-residue", 1, TINY) })
recipe("platinum-salt", "hv-chemical-reactor-recipes", 35 * HV_SPEED,
	{ fluid("platinum-concentrate", 3600), fluid("ammonium-chloride", 360) }, {
	item("platinum-salt", 16), item("reprecipitated-platinum", 4), fluid("palladium-enriched-ammonia", 360),
	fluid("nitrogen-dioxide", 900), fluid("hydrochloric-acid", 2700),
})
recipe("refined-platinum-salt", "lv-sifter-recipes", 30, { item("platinum-salt", 1) },
	{ item("refined-platinum-salt", 1, 0.95) })
recipe("metallic-platinum-powder-from-refined-salt", "mv-electric-blast-furnace-recipes", 10 * MV_SPEED,
	{ item("refined-platinum-salt", 1) }, { item("metallic-platinum-powder", 1), fluid("chlorine", 8.7) })
recipe("reprecipitated-platinum-processing", "lv-chemical-reactor-recipes", 1.5,
	{ item("reprecipitated-platinum", 4), item("calcium", 1) }, { item("platinum-dust", 2), item("calcium-chloride", 3) })



--------------------------------------------------------------------------------
--- 4) PALLADIUM (PSR:395-463)
---   metallic palladium powder + 1000 L ammonia -> 1000 L palladium enriched ammonia, LV, 12.5 s (:397-404)
---   9 metallic palladium powder + 9000 L palladium enriched ammonia -> 16 palladium salt + 2 reprecipitated
---     palladium, LV, 112.5 s (:413-420)
---   1000 L palladium enriched ammonia -> palladium salt, LV, 12.5 s (:421-427)
---   sifter: palladium salt -> metallic palladium powder (95 %), LV, 30 s (:428-443)
---   4 reprecipitated palladium + 4000 L formic acid -> 2 palladium dust + 4000 L ammonia, 1000 L ethylene, 1000 L
---     water, LV, 12.5 s (:452-462)
--------------------------------------------------------------------------------

F.fluid("palladium-enriched-ammonia", "ammonia", { 0.69, 0.69, 0.69 })
new_item("palladium-salt", "lv-chemical-reactor-recipes")
new_item("reprecipitated-palladium", "lv-chemical-reactor-recipes")
recipe("palladium-enriched-ammonia", "lv-chemical-reactor-recipes", 12.5,
	{ item("metallic-palladium-powder", 1), fluid("ammonia", 100) }, { fluid("palladium-enriched-ammonia", 100) })
recipe("palladium-salt", "lv-chemical-reactor-recipes", 112.5,
	{ item("metallic-palladium-powder", 9), fluid("palladium-enriched-ammonia", 900) },
	{ item("palladium-salt", 16), item("reprecipitated-palladium", 2) })
recipe("palladium-salt-from-ammonia", "lv-chemical-reactor-recipes", 12.5, { fluid("palladium-enriched-ammonia", 100) },
	{ item("palladium-salt", 1) })
recipe("metallic-palladium-powder-from-salt", "lv-sifter-recipes", 30, { item("palladium-salt", 1) },
	{ item("metallic-palladium-powder", 1, 0.95) })
recipe("reprecipitated-palladium-processing", "lv-chemical-reactor-recipes", 12.5,
	{ item("reprecipitated-palladium", 4), fluid("formic-acid", 400) },
	{ item("palladium-dust", 2), fluid("ammonia", 400), fluid("ethylene", 100), fluid("water", 100) }, "palladium-dust")



--------------------------------------------------------------------------------
--- 5) THE DIRECT ROUTES (PlatinumSludgeOutputs.java:60-87: platinum or palladium dust of ore processing -> twice as
--- much metallic powder). Kept by name where the recipe stays, so the machines keep it.
--------------------------------------------------------------------------------

--- crushed platinum and palladium (create_ore in 07): washer (the platinum one was overwritten by the GTCEu autoclave
--- recipe of the same name, the palladium one was called palladium-dust) and centrifuge
recipe("crushed-platinum-washing", "lv-ore-washer-recipes", 1, { item("crushed-platinum", 1), fluid("water", 10) },
	{ item("metallic-platinum-powder", 2) })
recipe("crushed-palladium-washing", "lv-ore-washer-recipes", 1, { item("crushed-palladium", 1), fluid("water", 10) },
	{ item("metallic-palladium-powder", 2) })
swap("centrifuging-crushed-platinum", "platinum-dust", "metallic-platinum-powder", nil, 2)
data.raw.recipe["centrifuging-crushed-platinum"].main_product = "metallic-platinum-powder"
swap("centrifuging-crushed-palladium", "palladium-dust", "metallic-palladium-powder", nil, 2)
data.raw.recipe["centrifuging-crushed-palladium"].main_product = "metallic-palladium-powder"
--- the nickel byproduct (10 %) and the end stone dust (0.7 %)
swap("centrifuging-crushed-nickel", "platinum-dust", "metallic-platinum-powder", nil, 2)
swap("endstone-dust-centrifuging", "platinum-dust", "metallic-platinum-powder", nil, 2)
--- sheldonite (GT's cooperite: Pt 3, Ni, S, Pd) dust in the electrolyzer: its platinum and palladium as powder
swap("sheldonite-dust-electrolysis", "platinum-dust", "metallic-platinum-powder", nil, 6)
swap("sheldonite-dust-electrolysis", "palladium-dust", "metallic-palladium-powder", nil, 2)
data.raw.recipe["sheldonite-dust-electrolysis"].main_product = "metallic-platinum-powder"



--------------------------------------------------------------------------------
--- 7) THE RESIDUE BRANCHES (PSR:465-690): rhodium, ruthenium, osmium and iridium as bartworks has them, instead of
--- the GTCEu branches of 19. Items GTNH has under another name keep their name (the quantum force transformer of 139
--- takes them) and get GT's name in the locale: iridium group sludge = leach residue, rarest metal mixture = rarest
--- metal residue, crude rhodium residue = crude rhodium metal; iridium metal residue, sodium ruthenate, ruthenium
--- tetroxide, rhodium salt, rhodium nitrate, sodium nitrate, zinc sulfate and the acidic osmium and rhodium sulfate
--- solutions are GT's names already. GT's blast furnace heat (600 K, 775 K) is below every coil.
--------------------------------------------------------------------------------

for _, r in pairs({
	"potassium-pyrosulfate", "potassium-sulfate-processing", "rhodium-salt-processing", "rhodium-nitrate-processing",
	"soda-ash", "hydrogen-peroxide", "sodium-peroxide", "iridium-dioxide-residue", "acidic-iridium-dioxide-solution",
	"ammonia-hexachloroiridiate", "osmium-tetroxide",
}) do remove("recipe", r) end
for _, i in pairs({ "potassium-pyrosulfate", "potassium-sulfate", "rhodium-sulfate", "soda-ash", "sodium-peroxide",
	"iridium-dioxide-residue", "ammonia-hexachloroiridiate", "osmium-tetroxide" }) do
	remove("item", i)
end
for _, f in pairs({ "acidic-iridium-dioxide-solution", "hydrogen-peroxide" }) do remove_fluid(f) end

--- potassium disulfate (bartworks: a dust with a melt): K 2 + S 2 + 7000 L oxygen -> 11 (bartworks' chemical synthesis,
--- DustLoader.java:239-258: protons / components = 42 ticks, 90 EU/t); dust -> 144 L melt, 15 s
--- (MoltenCellLoader.java:63-71)
new_item("potassium-disulfate", "lv-chemical-reactor-recipes")
F.fluid("molten-potassium-disulfate", "spackled-orange-fluid", { 0.98, 0.73, 0.40 })
recipe("potassium-disulfate", "lv-chemical-reactor-recipes", 2.1,
	{ item("potassium", 2), item("sulfur", 2), fluid("oxygen", 700) }, { item("potassium-disulfate", 11) })
recipe("molten-potassium-disulfate", "lv-extractor-recipes", 15, { item("potassium-disulfate", 1) },
	{ fluid("molten-potassium-disulfate", 14.4) })
--- sulfur trioxide (19's sulfur dioxide and trioxide stay on rhodium, KEEP of 142) lost its GTCEu use, the potassium
--- sulfate step: GT's SO3 + H2O -> H2SO4, 1000 L each, ULV, 16 s (ChemicalRecipes.java:2995-3005)
recipe("sulfuric-acid-from-sulfur-trioxide", "lv-chemical-reactor-recipes", 16,
	{ fluid("sulfur-trioxide", 100), fluid("water", 100) }, { fluid("sulfuric-acid", 100) })

--- RHODIUM (PSR:584-690)
---   blast furnace: platinum residue + 360 L molten potassium disulfate -> leach residue + 360 L rhodium sulfate (a
---     gas), MV, 10 s (:475-484)
---   36000 L water + 39600 L rhodium sulfate -> 4 leach residue + 7200 L molten potassium + 39600 L rhodium sulfate
---     solution, LV, 60 s (:595-602); GT casts the molten potassium like any metal (MaterialsInit.java:1454-1467,
---     metal items): here into the potassium element item, 144 L each, like an ingot cast of 143
---   zinc + 1000 L solution -> 6 zinc sulfate + crude rhodium metal, LV, 15 s (:603-609); zinc sulfate -> zinc, sulfur,
---     4000 L oxygen in the electrolyzer (bartworks: mass / components = 8 ticks, 90 EU/t)
---   blast furnace: crude rhodium metal + salt + 1000 L chlorine -> 3 rhodium salt, MV, 15 s (:610-617)
---   rhodium salt + 200 L water -> 200 L rhodium salt solution, mixer, LV, 1.5 s (:618-624)
---   5 sodium nitrate + 1000 L rhodium salt solution -> rhodium nitrate + 2 salt, LV, 15 s (:625-632); sodium nitrate:
---     sodium + 1000 L nitric acid -> 5 + 1000 L hydrogen, 0.4 s (:634-641), or 3 sodium hydroxide + 1000 L nitric acid
---     -> 5 + 1000 L water, MV, 1 s (:643-651)
---   sifter: rhodium nitrate -> rhodium filter cake (95 %), LV, 30 s (:653-668)
---   filter cake + 1000 L water -> 1000 L filter cake solution, mixer, LV, 15 s (:669-675)
---   1000 L filter cake solution -> reprecipitated rhodium, LV, 15 s (:676-681)
---   reprecipitated rhodium + 1000 L HCl -> rhodium dust + 1000 L ammonia + 1000 L chlorine, LV, 15 s (:682-689)
F.fluid("rhodium-sulfate", "spackled-orange-fluid", { 0.93, 0.67, 0.33 })
F.fluid("molten-potassium", "silver-blue-spackled-fluid", { 0.60, 0.67, 0.87 })
F.fluid("rhodium-salt-solution", "spackled-medium-blue-fluid", { 0.40, 0.47, 0.53 })
F.fluid("rhodium-filter-cake-solution", "spackled-medium-blue-fluid", { 0.40, 0.47, 0.53 })
new_item("rhodium-filter-cake", "lv-sifter-recipes")
new_item("reprecipitated-rhodium", "lv-chemical-reactor-recipes")
recipe("platinum-group-residue-processing", "mv-electric-blast-furnace-recipes", 10 * MV_SPEED,
	{ item("platinum-residue", 1), fluid("molten-potassium-disulfate", 36) },
	{ item("iridium-group-sludge", 1), fluid("rhodium-sulfate", 36) }, "iridium-group-sludge")
recipe("rhodium-sulfate-processing", "lv-chemical-reactor-recipes", 60,
	{ fluid("water", 3600), fluid("rhodium-sulfate", 3960) },
	{ item("iridium-group-sludge", 4), fluid("molten-potassium", 720), fluid("rhodium-sulfate-solution", 3960) },
	"rhodium-sulfate-solution")
recipe("solidify-potassium", "lv-fluid-solidifier-recipes", 1.6, { fluid("molten-potassium", 14.4) },
	{ item("potassium", 1) })
recipe("rhodium-sulfate-solution-processing", "lv-chemical-reactor-recipes", 15,
	{ item("zinc-dust", 1), fluid("rhodium-sulfate-solution", 100) },
	{ item("crude-rhodium-residue", 1), item("zinc-sulfate", 6) })
recipe("zinc-sulfate-electrolysis", "lv-electrolyzer-recipes", 0.4, { item("zinc-sulfate", 6) },
	{ item("zinc-dust", 1), item("sulfur", 1), fluid("oxygen", 400) })
recipe("crude-rhodium-residue-processing", "mv-electric-blast-furnace-recipes", 15 * MV_SPEED,
	{ item("crude-rhodium-residue", 1), item("salt", 1), fluid("chlorine", 100) }, { item("rhodium-salt", 3) })
recipe("rhodium-salt-solution", "lv-mixer-recipes", 1.5, { item("rhodium-salt", 1), fluid("water", 20) },
	{ fluid("rhodium-salt-solution", 20) })
recipe("rhodium-nitrate", "lv-chemical-reactor-recipes", 15,
	{ item("sodium-nitrate", 5), fluid("rhodium-salt-solution", 100) }, { item("rhodium-nitrate", 1), item("salt", 2) })
recipe("sodium-nitrate", "lv-chemical-reactor-recipes", 0.4, { item("sodium", 1), fluid("nitric-acid", 100) },
	{ item("sodium-nitrate", 5), fluid("hydrogen", 100) })
recipe("sodium-nitrate-from-sodium-hydroxide", "mv-chemical-reactor-recipes", 1 * MV_SPEED,
	{ item("sodium-hydroxide", 3), fluid("nitric-acid", 100) }, { item("sodium-nitrate", 5), fluid("water", 100) })
recipe("rhodium-filter-cake", "lv-sifter-recipes", 30, { item("rhodium-nitrate", 1) },
	{ item("rhodium-filter-cake", 1, 0.95) })
recipe("rhodium-filter-cake-solution", "lv-mixer-recipes", 15, { item("rhodium-filter-cake", 1), fluid("water", 100) },
	{ fluid("rhodium-filter-cake-solution", 100) })
recipe("reprecipitated-rhodium", "lv-chemical-reactor-recipes", 15, { fluid("rhodium-filter-cake-solution", 100) },
	{ item("reprecipitated-rhodium", 1) })
recipe("reprecipitated-rhodium-processing", "lv-chemical-reactor-recipes", 15,
	{ item("reprecipitated-rhodium", 1), fluid("hydrochloric-acid", 100) },
	{ item("rhodium-dust", 1), fluid("ammonia", 100), fluid("chlorine", 100) })

--- RUTHENIUM (PSR:486-522)
---   blast furnace: 10 leach residue + 10 saltpeter + 1000 L salt water -> 3 sodium ruthenate + 6 rarest metal residue
---     + 1000 L steam, MV, 10 s, 775 K (:486-494)
---   6 sodium ruthenate + 3000 L chlorine -> 9000 L ruthenium tetroxide solution, LV, 15 s (:495-501)
---   fluid heater: 1000 L -> 2000 L hot solution, HV, 15 s (:502-507); distillation tower: 9000 L hot solution -> 6
---     salt + 1800 L water + 7200 L ruthenium tetroxide, HV, 75 s (:508-514). Gregtorio has no fluid heater: the heating
---     is part of the distillation (as the glue line of 142 does with GT's fluid heater step), 4500 L solution in
---   fluid solidifier: 1000 L ruthenium tetroxide -> its dust, 165 ticks, 64 EU/t (bartworks CellLoader.java:249-261,
---     mass 165, WerkstoffLoader.java:1060-1073)
---   ruthenium tetroxide + 6000 L HCl -> ruthenium dust + 6000 L chlorine + 2000 L water, LV, 15 s (:515-521)
F.fluid("ruthenium-tetroxide-solution", "medium-gray-fluid", { 0.78, 0.78, 0.78 })
F.fluid("ruthenium-tetroxide", "medium-gray-fluid", { 0.78, 0.78, 0.78 })
recipe("iridium-group-sludge-processing", "mv-electric-blast-furnace-recipes", 10 * MV_SPEED,
	{ item("iridium-group-sludge", 10), item("saltpeter", 10), fluid("salt-water", 100) },
	{ item("sodium-ruthenate", 3), item("rarest-metal-mixture", 6), fluid("steam", 100) }, "sodium-ruthenate")
recipe("ruthenium-tetroxide-solution", "lv-chemical-reactor-recipes", 15,
	{ item("sodium-ruthenate", 6), fluid("chlorine", 300) }, { fluid("ruthenium-tetroxide-solution", 900) })
recipe("ruthenium-tetroxide-solution-distillation", "hv-tall-distillation-recipes", 75 * HV_SPEED,
	{ fluid("ruthenium-tetroxide-solution", 450) },
	{ fluid("ruthenium-tetroxide", 720), item("salt", 6), fluid("water", 180) }, "ruthenium-tetroxide")
recipe("ruthenium-tetroxide", "mv-fluid-solidifier-recipes", 8.25 * MV_SPEED, { fluid("ruthenium-tetroxide", 100) },
	{ item("ruthenium-tetroxide", 1) })
recipe("ruthenium-dust", "lv-chemical-reactor-recipes", 15, { item("ruthenium-tetroxide", 1), fluid("hydrochloric-acid", 600) },
	{ item("ruthenium-dust", 1), fluid("chlorine", 600), fluid("water", 200) })

--- OSMIUM (PSR:524-549)
---   blast furnace: 2 rarest metal residue + 500 L HCl -> iridium metal residue + 1000 L acidic osmium solution, MV,
---     5 s, 775 K (:526-535)
---   distillation tower: 1000 L acidic osmium solution -> 100 L osmium solution + 900 L water, IV, 7.5 s (:536-541)
---   1000 L osmium solution + 6000 L HCl -> osmium dust + 7000 L chlorine + 2000 L water, LV, 15 s (:542-548)
F.fluid("osmium-solution", "spackled-medium-blue-fluid", { 0.52, 0.40, 0.29 })
recipe("iridium-metal-residue", "mv-electric-blast-furnace-recipes", 5 * MV_SPEED,
	{ item("rarest-metal-mixture", 2), fluid("hydrochloric-acid", 50) },
	{ item("iridium-metal-residue", 1), fluid("acidic-osmium-solution", 100) }, "iridium-metal-residue")
recipe("osmium-solution", "iv-tall-distillation-recipes", 7.5 * IV_SPEED, { fluid("acidic-osmium-solution", 100) },
	{ fluid("osmium-solution", 10), fluid("water", 90) })
recipe("osmium-dust", "lv-chemical-reactor-recipes", 15, { fluid("osmium-solution", 100), fluid("hydrochloric-acid", 600) },
	{ item("osmium-dust", 1), fluid("chlorine", 700), fluid("water", 200) })

--- IRIDIUM (PSR:551-582)
---   blast furnace: iridium metal residue -> sludge dust residue + iridium dioxide, MV, 10 s, 775 K (:553-560)
---   iridium dioxide + 1000 L HCl -> 1000 L acidic iridium solution, LV, 15 s (:561-567)
---   1000 L acidic iridium solution + 3000 L ammonium chloride -> iridium chloride + 3000 L ammonia, LV, 15 s
---     (:568-574)
---   iridium chloride + calcium -> metallic sludge dust residue + iridium dust + 3000 L calcium chloride, EV, 15 s
---     (:575-581; Gregtorio's calcium chloride is an item: 3, the amount of its electrolysis)
---   sludge dust residue (SiO2 3, gold 2) and metallic sludge dust residue (nickel, copper) in the centrifuge
---     (bartworks DustLoader.java:221-238: mass / components = 45 and 30 ticks, 10 EU/t)
F.fluid("acidic-iridium-solution", "spackled-medium-blue-fluid", { 0.52, 0.40, 0.29 })
new_item("iridium-dioxide", "mv-electric-blast-furnace-recipes")
new_item("sludge-dust-residue", "mv-electric-blast-furnace-recipes")
new_item("iridium-chloride", "lv-chemical-reactor-recipes")
new_item("metallic-sludge-dust-residue", "ev-chemical-reactor-recipes")
recipe("iridium-dioxide", "mv-electric-blast-furnace-recipes", 10 * MV_SPEED, { item("iridium-metal-residue", 1) },
	{ item("iridium-dioxide", 1), item("sludge-dust-residue", 1) })
recipe("acidic-iridium-solution", "lv-chemical-reactor-recipes", 15,
	{ item("iridium-dioxide", 1), fluid("hydrochloric-acid", 100) }, { fluid("acidic-iridium-solution", 100) })
recipe("iridium-chloride", "lv-chemical-reactor-recipes", 15,
	{ fluid("acidic-iridium-solution", 100), fluid("ammonium-chloride", 300) },
	{ item("iridium-chloride", 1), fluid("ammonia", 300) })
recipe("iridium-dust", "ev-chemical-reactor-recipes", 15 * EV_SPEED, { item("iridium-chloride", 1), item("calcium", 1) },
	{ item("iridium-dust", 1), item("metallic-sludge-dust-residue", 1), item("calcium-chloride", 3) })
recipe("sludge-dust-residue-centrifuging", "lv-centrifuge-recipes", 2.25, { item("sludge-dust-residue", 5) },
	{ item("silicon-dioxide", 3), item("gold-dust", 2) })
recipe("metallic-sludge-dust-residue-centrifuging", "lv-centrifuge-recipes", 1.5,
	{ item("metallic-sludge-dust-residue", 2) }, { item("nickel-dust", 1), item("copper-dust", 1) })

--- technology effects of the deleted recipes
for _, tech in pairs(data.raw.technology) do
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do
			if not (e.type == "unlock-recipe" and gone_recipe[e.recipe] and not data.raw.recipe[e.recipe]) then
				keep[#keep + 1] = e
			end
		end
		tech.effects = keep
	end
end
