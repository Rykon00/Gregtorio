--------------------------------------------------------------------------------
--- MOLDS STAY IN THE MACHINE
--- Upstream recipes list the mold as ingredient AND result, so every craft pushes the
--- mold into the output slot. Here the mold becomes a module (category "mold") that sits
--- permanently in the machine's module slot, like a real mold:
---   * recipes that return their mold lose it from ingredients and results
---   * machines whose recipe used up a mold (fluid solidifiers, extruders) no longer do;
---     instead every recipe they can craft needs the mold in their mold slot
---   * the names of all recipes that need a mold are passed to the runtime script through
---     the mod-data "fork-mold-recipes" (log: FORK-MOLD)
---   * every machine that can craft such a recipe gets one module slot for molds only
---   * scripts/fork-molds.lua stops those machines with the status "Missing mold" while
---     a mold recipe is set and no mold is inserted
--- Blueprints keep the mold as a module request, so construction robots deliver it.
--------------------------------------------------------------------------------

local MOLDS = { "mold" }

data:extend({ { type = "module-category", name = "mold" } })

local is_mold = {}
for _, name in pairs(MOLDS) do
	local item = data.raw.item[name]
	if item then
		data.raw.item[name] = nil
		item.type = "module"
		item.category = "mold"
		item.tier = 1
		item.effect = {}
		item.localised_description = { "item-description.fork-mold" }
		data:extend({ item })
		is_mold[name] = true
	elseif data.raw.module[name] then
		is_mold[name] = true
	end
end

--- Recipes: remove a mold that is both consumed and returned
local mold_recipes, mold_categories = {}, {}
local function count(list, name)
	local n = 0
	for _, i in pairs(list or {}) do
		if i.name == name and i.type ~= "fluid" then n = n + (i.amount or 0) end
	end
	return n
end
local function without(list, name)
	local out = {}
	for _, i in pairs(list or {}) do
		if not (i.name == name and i.type ~= "fluid") then out[#out + 1] = i end
	end
	return out
end
for rname, r in pairs(data.raw.recipe) do
	for mold, _ in pairs(is_mold) do
		local used = count(r.ingredients, mold)
		if used > 0 and used == count(r.results, mold) then
			r.ingredients = without(r.ingredients, mold)
			r.results = without(r.results, mold)
			if r.main_product == mold then r.main_product = nil end
			r.localised_description = { "recipe-description.fork-needs-mold", { "item-name." .. mold } }
			mold_recipes[rname] = mold
			mold_categories[r.category or "crafting"] = true
		end
	end
end

--- Machines that were built WITH a mold (fluid solidifiers, extruders): the mold is no
--- longer used up by the machine recipe; instead every recipe these machines can craft
--- needs the mold in their mold slot.
local function placed_machine(item_name)
	for t, _ in pairs(defines.prototypes.item) do
		local it = data.raw[t] and data.raw[t][item_name]
		if it and it.place_result then
			for _, et in pairs({ "assembling-machine", "furnace" }) do
				local e = data.raw[et] and data.raw[et][it.place_result]
				if e then return e end
			end
		end
	end
	return nil
end
local machine_mold_categories = {}
for rname, r in pairs(data.raw.recipe) do
	for mold, _ in pairs(is_mold) do
		if count(r.ingredients, mold) > 0 and count(r.results, mold) == 0 then
			local machine
			for _, res in pairs(r.results or {}) do machine = machine or placed_machine(res.name) end
			if machine then
				r.ingredients = without(r.ingredients, mold)
				for _, c in pairs(machine.crafting_categories or {}) do machine_mold_categories[c] = mold end
				log("FORK-MOLD: " .. rname .. " no longer uses up a " .. mold .. ", " .. machine.name .. " gets a mold slot")
			end
		end
	end
end
for rname, r in pairs(data.raw.recipe) do
	local mold = machine_mold_categories[r.category or "crafting"]
	if mold and not mold_recipes[rname] then
		r.localised_description = { "recipe-description.fork-needs-mold", { "item-name." .. mold } }
		mold_recipes[rname] = mold
		mold_categories[r.category or "crafting"] = true
	end
end
for c, _ in pairs(machine_mold_categories) do log("FORK-MOLD: every recipe of " .. c .. " needs a mold") end

data:extend({ { type = "mod-data", name = "fork-mold-recipes", data = mold_recipes } })

--- Machines: one mold slot for everything that can craft a mold recipe
local MODULE_TYPES = { "assembling-machine", "furnace", "rocket-silo", "lab", "mining-drill", "beacon" }
for _, t in pairs({ "assembling-machine", "furnace" }) do
	for _, e in pairs(data.raw[t] or {}) do
		local needs = false
		for _, c in pairs(e.crafting_categories or {}) do
			if mold_categories[c] then needs = true end
		end
		if needs then
			if (e.module_slots or 0) == 0 then
				e.module_slots = 1
				e.allowed_module_categories = { "mold" }
				--- the engine rejects module slots without any allowed effect; molds have no
				--- effect, and beacons must not start boosting these machines
				if not e.allowed_effects or #e.allowed_effects == 0 then
					e.allowed_effects = { "consumption" }
					e.effect_receiver = e.effect_receiver or {}
					e.effect_receiver.uses_beacon_effects = false
				end
			elseif e.allowed_module_categories then
				table.insert(e.allowed_module_categories, "mold")
			else
				local all = {}
				for name, _ in pairs(data.raw["module-category"]) do all[#all + 1] = name end
				e.allowed_module_categories = all
			end
			log("FORK-MOLD: mold slot: " .. e.name)
		end
	end
end

--- Everything else that takes modules must not accept molds (nil means "all categories")
local other_categories = {}
for name, _ in pairs(data.raw["module-category"]) do
	if name ~= "mold" then other_categories[#other_categories + 1] = name end
end
for _, t in pairs(MODULE_TYPES) do
	for _, e in pairs(data.raw[t] or {}) do
		if not e.allowed_module_categories and ((e.module_slots or 0) > 0 or t == "beacon") then
			e.allowed_module_categories = table.deepcopy(other_categories)
		end
	end
end
