--------------------------------------------------------------------------------
--- FORK FIXES
--- Closes progression gaps in upstream 0.1.9 without restructuring the upstream
--- files. Loaded at the end of data.lua (after 98-technology).
--------------------------------------------------------------------------------

local function recipe_exists(name)
	if data.raw.recipe[name] then return true end
	log("FORK-FIX: missing recipe: " .. name)
	return false
end

--- Additionally unlock a recipe with a technology
function fork_add_unlock(tech_name, recipe_name)
	local tech = data.raw.technology[tech_name]
	if not tech then log("FORK-FIX: missing tech: " .. tech_name) return end
	if not recipe_exists(recipe_name) then return end
	tech.effects = tech.effects or {}
	for _, e in pairs(tech.effects) do
		if e.type == "unlock-recipe" and e.recipe == recipe_name then return end
	end
	table.insert(tech.effects, { type = "unlock-recipe", recipe = recipe_name })
	data.raw.recipe[recipe_name].enabled = false
end

--- Unlock a recipe with every tech that unlocks a recipe consuming `product`.
--- This makes the intermediate available no later than when it is first needed.
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
	if not found then log("FORK-FIX: no tech consumes " .. product) end
end

--- Add a crafting category to a machine
function fork_add_category(entity_type, entity_name, category)
	local e = data.raw[entity_type] and data.raw[entity_type][entity_name]
	if not e then log("FORK-FIX: missing entity: " .. entity_name) return end
	for _, c in pairs(e.crafting_categories) do if c == category then return end end
	table.insert(e.crafting_categories, category)
end



--------------------------------------------------------------------------------
--- MISSING UNLOCKS (recipe exists but no tech ever unlocks it)
--------------------------------------------------------------------------------

local missing_unlocks = {
	-- recipe                            -- product that is needed later
	{ "annealed-copper-wire",            "annealed-copper-wire" },           -- Microprocessor Mainframe, EV Polarizer
	{ "epoxy-sheet",                     "epoxy-sheet" },                    -- nanoprocessors
	{ "chloroplatinic-acid",             "chloroplatinic-acid" },            -- platinum line
	{ "large-chromium-gear",             "large-chromium-gear" },            -- HV Semifluid Generator
	{ "large-steel-boiler-controller",   "large-steel-boiler-controller" },  -- Large Steel Boiler
	{ "long-aluminium-rod",              "long-aluminium-rod" },             -- Aluminium Spring
	{ "stable-titanium-machine-casing",  "stable-titanium-machine-casing" }, -- EV Drilling Rig, Maceration Stack
	{ "titanium-dust",                   "titanium-dust" },                  -- titanium, staballoy, niobium-titanium
	{ "titanium-gear-box-casing",        "titanium-gear-box-casing" },       -- Heat Vent Block (Alloy Blast Smelter)
	{ "centrifuging-crushed-thorium",    "uranium-238-dust" },               -- staballoy, fuel rods
	{ "vibrant-alloy-wire",              "vibrant-alloy-wire" },             -- Octadic Capacitor (Ender IO)
	{ "dinitrogen-tetroxide",            "dinitrogen-tetroxide" },           -- rocket fuel -> tier 3 microminer -> tungsten
}
for _, m in pairs(missing_unlocks) do
	fork_unlock_with_consumers(m[1], m[2])
end



--------------------------------------------------------------------------------
--- MISSING RECIPES
--------------------------------------------------------------------------------

--- ZIRCONIUM: needed for zirconium carbide (Alloy Blast Smelter) but had no source.
--- By-product of the rare earth line (Rare Earth I).
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

--- CRYOGENIC HELIUM: needed to cool HSS-G/HSS-E/HSS-S and niobium-titanium, had no recipe.
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
--- MACHINES WITHOUT A MATCHING CATEGORY
--------------------------------------------------------------------------------

--- No distillation tower could make osmium tetroxide (ev-distillation)
fork_add_category("assembling-machine", "ev-short-distillation-tower", "ev-distillation-recipes")
fork_add_category("assembling-machine", "ev-tall-distillation-tower", "ev-distillation-recipes")



--------------------------------------------------------------------------------
--- IV SCIENCE: the recipe existed but was never unlocked (progression ended at EV)
--------------------------------------------------------------------------------

fork_add_unlock("utility-science-pack", "iv-science-pack")



--------------------------------------------------------------------------------
--- CHICKEN-AND-EGG PROBLEMS
--------------------------------------------------------------------------------

--- Iridium required the IV chemical reactor, but every IV machine needs iridium (IV emitter).
--- In GregTech iridium comes from the platinum line at EV -> EV category.
if data.raw.recipe["iridium-dust"] then
	data.raw.recipe["iridium-dust"].category = "ev-chemical-reactor-recipes"
end

--- The High Powered IC is needed for the IV energy hatch but required the IV chemical reactor,
--- which itself needs IV energy hatches -> EV category.
if data.raw.recipe["hpic-wafer"] then
	data.raw.recipe["hpic-wafer"].category = "ev-chemical-reactor-recipes"
end



--------------------------------------------------------------------------------
--- MULTIBLOCKS WITHOUT A TECH
--------------------------------------------------------------------------------

--- The "industrial-wire-factory" tech only unlocked the material press, not the wire factory
fork_add_unlock("industrial-wire-factory", "industrial-wire-factory-controller")
fork_add_unlock("industrial-wire-factory", "wire-factory-casing")
fork_add_unlock("industrial-wire-factory", "iv-industrial-wire-factory")

--- TurboCan Pro had no tech at all
fork_add_unlock("iv-machines", "turbocan-pro-controller")
fork_add_unlock("iv-machines", "iv-turbocan-pro")
