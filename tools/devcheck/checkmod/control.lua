--- The mod that created each recipe and the mods that changed it (runtime only: the data stage does not know it),
--- for the check that every Gregtorio recipe is unlocked by a researchable technology (issue #91).
--- `--create` runs on_init once.
local function owners()
	local rows = {}
	for name, _ in pairs(prototypes.recipe) do
		local h = prototypes.get_history("recipe", name)
		rows[#rows + 1] = name .. "\t" .. (h and h.created or "") .. "\t" .. table.concat(h and h.changed or {}, ",")
	end
	log("DEVCHECK-OWNERS-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-OWNERS-END")
end

--- Issue #230: the name the game shows for every prototype a player can see, as the engine resolves it from the final
--- prototypes (`localised_name` of the runtime prototype: the explicit one, else the engine's default key; a recipe
--- whose name differs from its product's gets `recipe-name.<recipe>` even with a main product, an item that places an
--- entity gets the entity's name). devcheck.py looks the keys up in the locale files.
--- class, type, name, created by, changed by, shown (why), subgroup, localised name (JSON), what the recipe makes
local function get(p, key)
	local ok, v = pcall(function() return p[key] end)
	if ok then return v end
end
local function names_rows()
	local rows, used, in_subgroup = {}, {}, {}
	local function shown_in(sg)
		if sg then in_subgroup[sg.name] = true end
	end
	for _, r in pairs(prototypes.recipe) do
		if not r.hidden and not get(r, "parameter") then
			for _, list in pairs({ r.ingredients, r.products }) do
				for _, x in pairs(list) do used[x.type .. ":" .. x.name] = true end
			end
		end
	end
	local function row(class, p, shown, extra)
		local ptype = (class == "item-group" or class == "item-subgroup") and class or p.type
		local h = prototypes.get_history(ptype, p.name) or {}
		local sg = get(p, "subgroup")
		rows[#rows + 1] = table.concat({ class, ptype, p.name, h.created or "", table.concat(h.changed or {}, ","),
			shown or "", sg and sg.name or "", helpers.table_to_json({ n = p.localised_name }), extra or "" }, "\t")
		if shown and class ~= "item-subgroup" and class ~= "item-group" then shown_in(sg) end
	end
	local function base_shown(p)
		if get(p, "parameter") then return nil end
		if not get(p, "hidden") then return "shown" end
	end
	for _, p in pairs(prototypes.item) do
		row("item", p, base_shown(p) or (not get(p, "parameter") and used["item:" .. p.name] and "in a recipe") or nil)
	end
	for _, p in pairs(prototypes.fluid) do
		row("fluid", p, base_shown(p) or (not get(p, "parameter") and used["fluid:" .. p.name] and "in a recipe") or nil)
	end
	for _, p in pairs(prototypes.recipe) do
		local mp = p.main_product
		row("recipe", p, base_shown(p), (mp and (mp.type .. ":" .. mp.name) or "-") .. " " .. #p.products)
	end
	for _, p in pairs(prototypes.technology) do
		row("technology", p, p.enabled and not p.hidden and "shown" or nil)
	end
	for _, p in pairs(prototypes.entity) do
		local placed = #(p.items_to_place_this or {}) > 0
		local minable = p.mineable_properties and p.mineable_properties.minable
		local shown = base_shown(p) and (placed and "placed by an item" or minable and "minable"
			or p.type == "resource" and "resource") or nil
		row("entity", p, shown)
	end
	for _, p in pairs(prototypes.equipment) do
		row("equipment", p, base_shown(p))
	end
	for _, p in pairs(prototypes.tile) do
		row("tile", p, base_shown(p) and #(get(p, "items_to_place_this") or {}) > 0 and "placed by an item" or nil)
	end
	for _, g in pairs(prototypes.item_subgroup) do
		row("item-subgroup", g, in_subgroup[g.name] and "has a shown prototype" or nil)
	end
	for _, g in pairs(prototypes.item_group) do
		local shown
		for _, sg in pairs(g.subgroups) do if in_subgroup[sg.name] then shown = "has a shown prototype" end end
		row("item-group", g, shown)
	end
	log("DEVCHECK-NAMES-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-NAMES-END")
end

script.on_init(function()
	owners()
	names_rows()
end)
