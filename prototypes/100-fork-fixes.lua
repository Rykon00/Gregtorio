--------------------------------------------------------------------------------
--- FORK FIXES
--- Schließt Lücken in der Progression von Upstream 0.1.9, ohne die Upstream-
--- Dateien stark umzubauen. Wird am Ende von data.lua geladen (nach 98-technology).
--------------------------------------------------------------------------------

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-FIX: Rezept fehlt: " .. name)
	return false
end

--- Rezept zusätzlich von einer Technologie freischalten lassen
function fork_add_unlock(tech_name, recipe_name)
	local tech = data.raw.technology[tech_name]
	if not tech then log("FORK-FIX: Tech fehlt: " .. tech_name) return end
	if not recipe_exists(recipe_name) then return end
	tech.effects = tech.effects or {}
	for _, e in pairs(tech.effects) do
		if e.type == "unlock-recipe" and e.recipe == recipe_name then return end
	end
	table.insert(tech.effects, { type = "unlock-recipe", recipe = recipe_name })
	data.raw.recipe[recipe_name].enabled = false
end

--- Rezept von jeder Tech freischalten lassen, die ein Rezept freischaltet, das `product` verbraucht.
--- So ist das Vorprodukt spätestens dann verfügbar, wenn es zum ersten Mal gebraucht wird.
function fork_unlock_with_consumers(recipe_name, product)
	if not recipe_exists(recipe_name) then return end
	local consumers = {}
	for name, r in pairs(data.raw.recipe) do
		for _, ing in pairs(r.ingredients or {}) do
			if ing.name == product then consumers[name] = true end
		end
	end
	local found = false
	for tname, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and consumers[e.recipe] then
				fork_add_unlock(tname, recipe_name)
				found = true
				break
			end
		end
	end
	if not found then log("FORK-FIX: keine Tech verbraucht " .. product) end
end

--- Crafting-Kategorie zu einer Maschine hinzufügen
function fork_add_category(entity_type, entity_name, category)
	local e = data.raw[entity_type] and data.raw[entity_type][entity_name]
	if not e then log("FORK-FIX: Entity fehlt: " .. entity_name) return end
	for _, c in pairs(e.crafting_categories) do if c == category then return end end
	table.insert(e.crafting_categories, category)
end



--------------------------------------------------------------------------------
--- FEHLENDE FREISCHALTUNGEN (Rezept existiert, wird aber nie von einer Tech freigeschaltet)
--------------------------------------------------------------------------------

local missing_unlocks = {
	-- Rezept                            -- Produkt, das später gebraucht wird
	{ "annealed-copper-wire",            "annealed-copper-wire" },           -- Microprocessor Mainframe, EV Polarizer
	{ "epoxy-sheet",                     "epoxy-sheet" },                    -- Nanoprozessoren
	{ "chloroplatinic-acid",             "chloroplatinic-acid" },            -- Platin-Linie
	{ "large-chromium-gear",             "large-chromium-gear" },            -- HV Semifluid Generator
	{ "large-steel-boiler-controller",   "large-steel-boiler-controller" },  -- Large Steel Boiler
	{ "long-aluminium-rod",              "long-aluminium-rod" },             -- Aluminium Spring
	{ "stable-titanium-machine-casing",  "stable-titanium-machine-casing" }, -- EV Drilling Rig, Maceration Stack
	{ "titanium-dust",                   "titanium-dust" },                  -- Titan, Staballoy, Niob-Titan
	{ "titanium-gear-box-casing",        "titanium-gear-box-casing" },       -- Heat Vent Block (Alloy Blast Smelter)
	{ "centrifuging-crushed-thorium",    "uranium-238-dust" },               -- Staballoy, Brennstäbe
	{ "vibrant-alloy-wire",              "vibrant-alloy-wire" },             -- Octadic Capacitor (Ender IO)
	{ "dinitrogen-tetroxide",            "dinitrogen-tetroxide" },           -- Rocket Fuel -> Tier-3-Microminer -> Wolfram
}
for _, m in pairs(missing_unlocks) do
	fork_unlock_with_consumers(m[1], m[2])
end



--------------------------------------------------------------------------------
--- FEHLENDE REZEPTE
--------------------------------------------------------------------------------

--- ZIRCONIUM: wird für Zirconium Carbide (Alloy Blast Smelter) gebraucht, hatte aber keine Quelle.
--- Nebenprodukt der Seltenen-Erden-Linie (Rare Earth I).
create_recipe{
	recipe_name = "rare-earth-1-zirconium-electrolysis",
	category = "lv-electrolyzer-recipes",
	subgroup = "subgroup-lv-electrolyzer-recipes",
	icon = ICON_PATH .. "zirconium-dust.png",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "rare-earth-1-dust", amount = 4 },
	},
	results = {
		{ type = "item", name = "zirconium-dust", amount = 1 },
		{ type = "item", name = "yttrium-dust", amount = 1, probability = 0.25 },
	},
	main_product = "zirconium-dust",
}
fork_unlock_with_consumers("rare-earth-1-zirconium-electrolysis", "zirconium-dust")

--- KRYOGENES HELIUM: wird zum Abkühlen von HSS-G/HSS-E/HSS-S und Niob-Titan gebraucht, hatte kein Rezept.
create_recipe{
	recipe_name = "cryogenic-helium",
	category = "mv-vacuum-freezer-recipes",
	subgroup = "subgroup-mv-vacuum-freezer-recipes",
	icon = "__Gregtorio__/graphics/fluids/cryogenic-helium.png",
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "helium", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "cryogenic-helium", amount = 100 },
	},
}
fork_unlock_with_consumers("cryogenic-helium", "cryogenic-helium")



--------------------------------------------------------------------------------
--- MASCHINEN OHNE PASSENDE KATEGORIE
--------------------------------------------------------------------------------

--- Osmium Tetroxide (ev-distillation) konnte keine Destille herstellen
fork_add_category("assembling-machine", "ev-short-distillation-tower", "ev-distillation-recipes")
fork_add_category("assembling-machine", "ev-tall-distillation-tower", "ev-distillation-recipes")



--------------------------------------------------------------------------------
--- IV-SCIENCE: Rezept existierte, wurde aber nie freigeschaltet (Progression endete bei EV)
--------------------------------------------------------------------------------

fork_add_unlock("utility-science-pack", "iv-science-pack")



--------------------------------------------------------------------------------
--- HENNE-EI-PROBLEME
--------------------------------------------------------------------------------

--- Iridium lief über den IV Chemical Reactor, aber jede IV-Maschine braucht Iridium (IV Emitter).
--- In GregTech kommt Iridium aus der Platin-Linie auf EV -> EV-Kategorie.
if data.raw.recipe["iridium-dust"] then
	data.raw.recipe["iridium-dust"].category = "ev-chemical-reactor-recipes"
end

--- High Powered IC wird für den IV Energy Hatch gebraucht, lief aber über den IV Chemical Reactor,
--- der selbst IV Energy Hatches braucht -> EV-Kategorie.
if data.raw.recipe["hpic-wafer"] then
	data.raw.recipe["hpic-wafer"].category = "ev-chemical-reactor-recipes"
end



--------------------------------------------------------------------------------
--- MULTIBLOCKS OHNE TECH
--------------------------------------------------------------------------------

--- Die Tech "industrial-wire-factory" schaltete nur die Material Press frei, nicht die Wire Factory
fork_add_unlock("industrial-wire-factory", "industrial-wire-factory-controller")
fork_add_unlock("industrial-wire-factory", "wire-factory-casing")
fork_add_unlock("industrial-wire-factory", "iv-industrial-wire-factory")

--- TurboCan Pro hatte gar keine Tech
fork_add_unlock("iv-machines", "turbocan-pro-controller")
fork_add_unlock("iv-machines", "iv-turbocan-pro")
