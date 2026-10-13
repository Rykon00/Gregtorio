--------------------------------------------------------------------------------
--- MOLDS AND LENSES STAY IN THE MACHINE
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
--- Issue #316: the lenses of the laser engraver work the same way (category "lens"). GT does not use up the lens
--- (OP/ProcessingGem.java:310-318 sets its stack size to 0, GT's mark for an input that stays); the gem steps of 155
--- and 159 listed it as ingredient and result, so it went to the output after every craft. Every recipe of a laser
--- engraver category that takes and returns a lens needs it in the machine's lens slot ("Missing <lens>"), and every
--- laser engraver gets that slot. The lenses' own recycling recipes (lens -> lens) keep theirs.
--- The mod-data "fork-mold-recipes" maps every such recipe to its mold or lens.
--- Blueprints keep the mold or lens as a module request, so construction robots deliver it.
--------------------------------------------------------------------------------

--- category -> the items that stay in the machine, the recipe categories they count in (nil: all), the description
--- keys of the item and of the recipes that need it
local TOOLS = {
	mold = { items = { "mold" }, description = "fork-mold", needs = "fork-needs-mold" },
	lens = { items = {}, categories = "%-laser%-engraver%-recipes$", description = "fork-lens", needs = "fork-needs-lens" },
}
--- GT's lens prefix: every item named <material>-lens
for name, _ in pairs(data.raw.item) do
	if name:match("%-lens$") then table.insert(TOOLS.lens.items, name) end
end
table.sort(TOOLS.lens.items)

local tool_of = {}   -- item -> module category
for category, tool in pairs(TOOLS) do
	data:extend({ { type = "module-category", name = category } })
	for _, name in pairs(tool.items) do
		local item = data.raw.item[name]
		if item then
			data.raw.item[name] = nil
			item.type = "module"
			item.category = category
			item.tier = 1
			item.effect = {}
			item.localised_description = { "item-description." .. tool.description }
			data:extend({ item })
			tool_of[name] = category
		elseif data.raw.module[name] then
			tool_of[name] = category
		end
	end
end
local function counts_in(category, recipe_category)
	local pattern = TOOLS[category].categories
	return pattern == nil or recipe_category:match(pattern) ~= nil
end
local function needs_text(item)
	return { "recipe-description." .. TOOLS[tool_of[item]].needs, { "item-name." .. item } }
end

--- Recipes: remove a mold or lens that is both consumed and returned
local mold_recipes, mold_categories = {}, {}   -- recipe -> item; recipe category -> module category
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
	local rcat = r.category or "crafting"
	for mold, category in pairs(tool_of) do
		local used = count(r.ingredients, mold)
		if used > 0 and used == count(r.results, mold) and counts_in(category, rcat) then
			r.ingredients = without(r.ingredients, mold)
			r.results = without(r.results, mold)
			if r.main_product == mold then r.main_product = nil end
			r.localised_description = needs_text(mold)
			mold_recipes[rname] = mold
			mold_categories[rcat] = category
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
	for mold, _ in pairs(tool_of) do
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
		r.localised_description = needs_text(mold)
		mold_recipes[rname] = mold
		mold_categories[r.category or "crafting"] = tool_of[mold]
	end
end
for c, _ in pairs(machine_mold_categories) do log("FORK-MOLD: every recipe of " .. c .. " needs a mold") end
local lenses = 0
for _, item in pairs(mold_recipes) do
	if tool_of[item] == "lens" then lenses = lenses + 1 end
end
log("FORK-MOLD: " .. lenses .. " laser engraver recipes need a lens in the lens slot")

data:extend({ { type = "mod-data", name = "fork-mold-recipes", data = mold_recipes } })

--- Machines: one mold or lens slot for everything that can craft such a recipe
local MODULE_TYPES = { "assembling-machine", "furnace", "rocket-silo", "lab", "mining-drill", "beacon" }
for _, t in pairs({ "assembling-machine", "furnace" }) do
	for _, e in pairs(data.raw[t] or {}) do
		local needs = {}
		for _, c in pairs(e.crafting_categories or {}) do
			if mold_categories[c] then needs[mold_categories[c]] = true end
		end
		local list = {}
		for category, _ in pairs(needs) do list[#list + 1] = category end
		table.sort(list)
		if #list > 0 then
			if (e.module_slots or 0) == 0 then
				e.module_slots = 1
				e.allowed_module_categories = list
				--- the engine rejects module slots without any allowed effect; molds have no
				--- effect, and beacons must not start boosting these machines
				if not e.allowed_effects or #e.allowed_effects == 0 then
					e.allowed_effects = { "consumption" }
					e.effect_receiver = e.effect_receiver or {}
					e.effect_receiver.uses_beacon_effects = false
				end
			elseif e.allowed_module_categories then
				for _, category in pairs(list) do table.insert(e.allowed_module_categories, category) end
			else
				--- nil means every category: the other modules and only this machine's mold or lens
				local all = table.deepcopy(list)
				for name, _ in pairs(data.raw["module-category"]) do
					if not TOOLS[name] then all[#all + 1] = name end
				end
				e.allowed_module_categories = all
			end
			log("FORK-MOLD: " .. table.concat(list, " and ") .. " slot: " .. e.name)
		end
	end
end

--- Everything else that takes modules must not accept molds or lenses (nil means "all categories")
local other_categories = {}
for name, _ in pairs(data.raw["module-category"]) do
	if not TOOLS[name] then other_categories[#other_categories + 1] = name end
end
for _, t in pairs(MODULE_TYPES) do
	for _, e in pairs(data.raw[t] or {}) do
		if not e.allowed_module_categories and ((e.module_slots or 0) > 0 or t == "beacon") then
			e.allowed_module_categories = table.deepcopy(other_categories)
		end
	end
end
