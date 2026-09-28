--------------------------------------------------------------------------------
--- FORK AUTO-UNLOCK
--- Viele Vorprodukt-Rezepte (Legierungen, Metallteile, Zwischenprodukte) werden in
--- Upstream nie von einer Technologie freigeschaltet. Dadurch sind Rezepte sichtbar,
--- deren Zutaten man nicht herstellen kann.
---
--- Regel: Schaltet eine Tech ein Rezept frei, dessen Zutat X von KEINEM freigeschalteten
--- Rezept hergestellt wird, dann schaltet dieselbe Tech auch die (nie freigeschalteten)
--- Gregtorio-Rezepte für X frei, rekursiv. Jede Ergänzung wird ins Log geschrieben
--- ("FORK-AUTOUNLOCK").
--------------------------------------------------------------------------------

local function is_gregtorio_category(c)
	return c and (c:sub(-8) == "-recipes" or c == "smelting") and c ~= "fluid-voiding-recipes"
end

local function results_of(r)
	local out = {}
	for _, res in pairs(r.results or {}) do if res.name then out[#out + 1] = res.name end end
	return out
end

--------------------------------------------------------------------------------
--- DRAFT-GUARD
--- Die höheren Tiers (LuV+) enthalten viele Entwurfs-Rezepte, die Items/Fluids/Kategorien
--- referenzieren, die es (noch) nicht gibt. Solche Rezepte würden das Laden abbrechen.
--- Sie werden hier entfernt und ins Log geschrieben ("FORK-DRAFT"). Sobald die fehlenden
--- Teile existieren, sind die Rezepte automatisch wieder aktiv.
--------------------------------------------------------------------------------

local function item_exists(n)
	for t, _ in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][n] then return true end
	end
	return false
end

local function recipe_problem(r)
	if not data.raw["recipe-category"][r.category or "crafting"] then return "Kategorie " .. tostring(r.category) end
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if i.type == "fluid" then
				if not data.raw.fluid[i.name] then return "Fluid " .. tostring(i.name) end
			elseif not item_exists(i.name) then
				return "Item " .. tostring(i.name)
			end
		end
	end
	if r.main_product and r.main_product ~= "" then
		local ok = false
		for _, i in pairs(r.results or {}) do if i.name == r.main_product then ok = true end end
		if not ok then return "main_product " .. r.main_product end
	end
	return nil
end

local removed = {}
local changed = true
while changed do
	changed = false
	for name, r in pairs(data.raw.recipe) do
		local problem = recipe_problem(r)
		if problem then
			log("FORK-DRAFT: Rezept " .. name .. " deaktiviert (fehlt: " .. problem .. ")")
			data.raw.recipe[name] = nil
			removed[name] = true
			changed = true
		end
	end
end
for _, tech in pairs(data.raw.technology) do
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do
			if not (e.type == "unlock-recipe" and (removed[e.recipe] or not data.raw.recipe[e.recipe])) then
				keep[#keep + 1] = e
			end
		end
		tech.effects = keep
	end
	if tech.prerequisites then
		local keep = {}
		for _, p in pairs(tech.prerequisites) do
			if data.raw.technology[p] then keep[#keep + 1] = p else log("FORK-DRAFT: Tech " .. tech.name .. " Voraussetzung fehlt: " .. p) end
		end
		tech.prerequisites = keep
	end
end
--- fehlende Subgroups anlegen statt abzustürzen
local function ensure_subgroup(sg)
	if sg and not data.raw["item-subgroup"][sg] then
		data:extend({ { type = "item-subgroup", name = sg, group = "processing-machine-recipes", order = "zz" } })
		log("FORK-DRAFT: Subgroup angelegt: " .. sg)
	end
end
for _, r in pairs(data.raw.recipe) do ensure_subgroup(r.subgroup) end
for t, _ in pairs(defines.prototypes.item) do
	for _, it in pairs(data.raw[t] or {}) do
		ensure_subgroup(it.subgroup)
		if it.place_result then
			local found = false
			for et, _ in pairs(defines.prototypes.entity) do
				if data.raw[et] and data.raw[et][it.place_result] then found = true end
			end
			if not found then
				log("FORK-DRAFT: Item " .. it.name .. " place_result fehlt: " .. it.place_result)
				it.place_result = nil
			end
		end
	end
end



--- Kategorien, für die es überhaupt eine Maschine gibt
local craftable_category = {}
for _, t in pairs({ "assembling-machine", "furnace", "character" }) do
	for _, e in pairs(data.raw[t] or {}) do
		for _, c in pairs(e.crafting_categories or {}) do craftable_category[c] = true end
	end
end

--- Wer stellt was her (ohne Recycling/Voiding/Schrott)
local producers = {}
for name, r in pairs(data.raw.recipe) do
	if not name:match("%-recycling$") and not name:match("^void%-") and not name:match("scrap")
		and is_gregtorio_category(r.category) and craftable_category[r.category] then
		for _, p in pairs(results_of(r)) do
			producers[p] = producers[p] or {}
			table.insert(producers[p], name)
		end
	end
end

--- Welche Rezepte sind überhaupt erreichbar (enabled oder von irgendeiner Tech)
local unlocked_anywhere = {}
for name, r in pairs(data.raw.recipe) do
	if r.enabled ~= false then unlocked_anywhere[name] = true end
end
for _, tech in pairs(data.raw.technology) do
	for _, e in pairs(tech.effects or {}) do
		if e.type == "unlock-recipe" then unlocked_anywhere[e.recipe] = true end
	end
end

local function has_available_producer(item)
	for _, p in pairs(producers[item] or {}) do
		if unlocked_anywhere[p] then return true end
	end
	return false
end

local added = 0
local function pull(tech, recipe_name, depth)
	if depth > 12 then return end
	local r = data.raw.recipe[recipe_name]
	if not r then return end
	for _, ing in pairs(r.ingredients or {}) do
		if ing.name and not has_available_producer(ing.name) then
			--- gibt es ein Rezept, das genauso heißt wie das Produkt, ist das der "normale" Weg
			local candidates = producers[ing.name] or {}
			for _, p in pairs(candidates) do
				if p == ing.name then candidates = { p } break end
			end
			--- Rezepte ignorieren, deren Zutaten niemand herstellen kann
			local usable = {}
			for _, p in pairs(candidates) do
				local ok = true
				for _, i2 in pairs(data.raw.recipe[p].ingredients or {}) do
					if i2.name and not producers[i2.name] and not data.raw.fluid[i2.name] then ok = false end
					if i2.type == "fluid" and not producers[i2.name] and i2.name ~= "water" and i2.name ~= "steam" then ok = false end
				end
				if ok then usable[#usable + 1] = p end
			end
			--- bevorzugt Rezepte, deren Zutaten schon herstellbar sind
			local ready = {}
			for _, p in pairs(usable) do
				local ok = true
				for _, i2 in pairs(data.raw.recipe[p].ingredients or {}) do
					if not has_available_producer(i2.name) and i2.name ~= "water" and i2.name ~= "steam" then ok = false end
				end
				if ok then ready[#ready + 1] = p end
			end
			candidates = (#ready > 0) and ready or usable
			for _, p in pairs(candidates) do
				if not unlocked_anywhere[p] then
					table.insert(tech.effects, { type = "unlock-recipe", recipe = p })
					data.raw.recipe[p].enabled = false
					unlocked_anywhere[p] = true
					added = added + 1
					log("FORK-AUTOUNLOCK: " .. tech.name .. " -> " .. p .. " (für " .. ing.name .. ")")
					pull(tech, p, depth + 1)
				end
			end
		end
	end
end

--- Techs in Forschungsreihenfolge abarbeiten, damit Vorprodukte bei der frühesten Tech landen
local order, visited = {}, {}
local function visit(name)
	if visited[name] then return end
	visited[name] = true
	local t = data.raw.technology[name]
	if not t then return end
	for _, p in pairs(t.prerequisites or {}) do visit(p) end
	table.insert(order, t)
end
local names = {}
for name, _ in pairs(data.raw.technology) do names[#names + 1] = name end
table.sort(names)
for _, n in pairs(names) do visit(n) end

for _, tech in ipairs(order) do
	local effects = {}
	for _, e in pairs(tech.effects or {}) do effects[#effects + 1] = e end
	for _, e in pairs(effects) do
		if e.type == "unlock-recipe" then pull(tech, e.recipe, 0) end
	end
end

log("FORK-AUTOUNLOCK: " .. added .. " Rezepte zusätzlich freigeschaltet")
