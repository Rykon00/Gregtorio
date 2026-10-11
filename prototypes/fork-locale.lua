--- Fork: names (issue #230). Required at the top of data.lua (the snapshot of the recipes of the base game and the
--- dependencies) and called at the end of data-final-fixes.lua (FORK_LOCALE.name_recipes).
---
--- The engine names a recipe after its product only when the recipe has the product's name: any other recipe shows
--- `recipe-name.<recipe>`, with a main product or not (checked with the runtime prototypes of Factorio 2.0.77; the
--- prototype documentation of `main_product` says otherwise). GT has thousands of such recipes (`hammering-raw-coal`,
--- `centrifuging-pure-ruby-dust`, the casts, nugget and pile recipes, ...), so every recipe Gregtorio makes gets the
--- name of its main or single product as the fallback after its own `recipe-name` entry: {"?", recipe-name, product}.
--- A recipe with several results and no main product needs a `main_product` or a `recipe-name` entry.
--- `devcheck.py check` fails for every shown prototype of this mod without a name; FORK_LOCALE_MISSING keeps one
--- without a name on purpose ("<class>:<name>" -> reason, class as in the check: item, fluid, recipe, technology,
--- entity, equipment, tile, item-group, item-subgroup).

FORK_LOCALE = { pre = {} }
FORK_LOCALE_MISSING = {}

for name in pairs(data.raw.recipe) do FORK_LOCALE.pre[name] = true end

local function entity(name)
	for t in pairs(defines.prototypes.entity) do
		if data.raw[t] and data.raw[t][name] then return data.raw[t][name] end
	end
end

--- the name the engine shows for an item or fluid: its own localised name, else its key; an item that places an entity
--- or equipment is named after it (the engine does this even when the item has an `item-name` entry)
function FORK_LOCALE.name_of(kind, name)
	local p
	if kind == "fluid" then
		p = data.raw.fluid[name]
	else
		for t in pairs(defines.prototypes.item) do
			if data.raw[t] and data.raw[t][name] then p = data.raw[t][name] break end
		end
	end
	if not p then return { (kind == "fluid" and "fluid-name." or "item-name.") .. name } end
	if p.localised_name then return table.deepcopy(p.localised_name) end
	if kind == "fluid" then return { "fluid-name." .. name } end
	if p.place_result and p.place_result ~= "" then
		local e = entity(p.place_result)
		return e and e.localised_name and table.deepcopy(e.localised_name) or { "entity-name." .. p.place_result }
	end
	local eq = p.place_as_equipment_result
	if eq and eq ~= "" then
		for t in pairs(defines.prototypes.equipment) do
			local e = data.raw[t] and data.raw[t][eq]
			if e then return e.localised_name and table.deepcopy(e.localised_name) or { "equipment-name." .. eq } end
		end
	end
	return { "item-name." .. name }
end

--- every Gregtorio recipe without a localised name whose name differs from its main or single product: its own
--- `recipe-name` entry if there is one, else the product's name
function FORK_LOCALE.name_recipes()
	local n = 0
	for name, r in pairs(data.raw.recipe) do
		if not FORK_LOCALE.pre[name] and not r.localised_name and r.main_product ~= "" then
			local results, product = r.results or {}, nil
			for _, x in pairs(results) do
				if (r.main_product and x.name == r.main_product) or (not r.main_product and #results == 1) then
					product = x
					break
				end
			end
			if product and product.name ~= name then
				r.localised_name = { "?", { "recipe-name." .. name }, FORK_LOCALE.name_of(product.type, product.name) }
				n = n + 1
			end
		end
	end
	log("FORK-LOCALE: " .. n .. " recipes named after their product")
end
