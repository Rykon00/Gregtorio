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
		--- (issue #625: with its description, which a machine must have)
		row("entity", p, shown, helpers.table_to_json({ d = p.localised_description }))
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
	--- issue #529: the map generator's controls
	for _, p in pairs(prototypes.autoplace_control) do
		--- (issue #574: with its description, which a vein's control must have)
		row("autoplace-control", p, not get(p, "hidden") and "in the map generator" or nil,
			helpers.table_to_json({ d = p.localised_description }))
	end
	for _, g in pairs(prototypes.item_group) do
		local shown
		for _, sg in pairs(g.subgroups) do if in_subgroup[sg.name] then shown = "has a shown prototype" end end
		row("item-group", g, shown)
	end
	--- issue #769: a fuel category is named in the tooltips and Factoriopedia of its fuels and burners ("Consumes ...")
	for _, p in pairs(prototypes.fuel_category) do
		row("fuel-category", p, not get(p, "hidden") and "named by its fuels and burners" or nil)
	end
	log("DEVCHECK-NAMES-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-NAMES-END")
end

--- Issue #336: the player-built entities of this mod (flag player-creation) that give an item when mined, with the items
--- they give and the items that place them; devcheck.py fails for one that no item it gives can place again (issue #563:
--- not a hidden one, the mining drills of the classic ore mode, whose items place the dimension mines)
--- type, name, mined items, items that place it
local function placeable_rows()
	local rows = {}
	for _, p in pairs(prototypes.entity) do
		local h = prototypes.get_history(p.type, p.name) or {}
		local mp = p.mineable_properties
		if h.created == "gregtorio-continued" and p.flags and p.flags["player-creation"] and mp and mp.minable and not p.hidden then
			local mined, placers = {}, {}
			for _, x in pairs(mp.products or {}) do if x.type == "item" then mined[#mined + 1] = x.name end end
			for _, it in pairs(p.items_to_place_this or {}) do placers[#placers + 1] = it.name end
			if #mined > 0 then
				rows[#rows + 1] = table.concat({ p.type, p.name, table.concat(mined, ","), table.concat(placers, ",") }, "\t")
			end
		end
	end
	log("DEVCHECK-PLACEABLE-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-PLACEABLE-END")
end

--- Issue #764: the items with more than one hand recipe (a category of the character) that the crafting menu may chain as an
--- intermediate (allow_as_intermediate): it takes one of them, so a GT tool charge (`*-usage`) must have only its iron
--- recipe there, or the menu picks the steel tool and crafts nothing without steel
--- item, the recipes
local function intermediate_rows()
	local hand = prototypes.entity["character"].crafting_categories or {}
	local by_item = {}
	for name, r in pairs(prototypes.recipe) do
		local by_hand = false
		for k, v in pairs(r.categories or {}) do
			local c = type(k) == "string" and k or (type(v) == "string" and v or v.name)
			if hand[c] then by_hand = true end
		end
		local mp = r.main_product
		if by_hand and r.allow_as_intermediate and mp and mp.type == "item" then
			by_item[mp.name] = by_item[mp.name] or {}
			table.insert(by_item[mp.name], name)
		end
	end
	local rows = {}
	for item, list in pairs(by_item) do
		if #list > 1 then table.sort(list); rows[#rows + 1] = item .. "\t" .. table.concat(list, ",") end
	end
	log("DEVCHECK-INTERMEDIATE-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-INTERMEDIATE-END")
end

--- Issue #809: every pipe connection of an entity this mod creates or changes must sit on the edge of its collision box
--- and face out of it (its neighbour position outside the box), in each of the four directions the entity can face (the
--- runtime prototype's `positions`: north, east, south, west); the drilling rigs' outputs lay inside the machine, so no
--- pipe could connect. Underground and linked connections do not count. devcheck.py fails for every entity of a row
--- unless it is in the allow-list FORK_PIPE_CONNECTIONS_INSIDE of prototypes/199-fork-finalize.lua with its reason.
--- type, name, created by, the bad connections ("box <i> connection <j> facing <dir>: (x, y) -> (x, y) <why>", "; ")
local DIR_VEC = { [0] = { 0, -1 }, [4] = { 1, 0 }, [8] = { 0, 1 }, [12] = { -1, 0 } }
local FACING = { [0] = "north", [1] = "east", [2] = "south", [3] = "west" }
local function pipe_rows()
	local rows, checked = {}, 0
	local function inside(b, x, y)
		return b[1] < x and x < b[3] and b[2] < y and y < b[4]
	end
	for name, p in pairs(prototypes.entity) do
		local h = prototypes.get_history(p.type, name) or {}
		local ours = h.created == "gregtorio-continued"
		for _, m in pairs(h.changed or {}) do if m == "gregtorio-continued" then ours = true end end
		local boxes = ours and get(p, "fluidbox_prototypes") or {}
		local cb = p.collision_box
		if #boxes > 0 and cb then
			checked = checked + 1
			local bad = {}
			for i, fb in pairs(boxes) do
				for j, c in pairs(fb.pipe_connections or {}) do
					if c.connection_type == "normal" then
						for k = 0, 3 do
							--- the box and the connection's direction when the entity faces k (90 degrees clockwise each)
							local x1, y1, x2, y2 = cb.left_top.x, cb.left_top.y, cb.right_bottom.x, cb.right_bottom.y
							for _ = 1, k do x1, y1, x2, y2 = -y2, x1, -y1, x2 end
							local b = { math.min(x1, x2), math.min(y1, y2), math.max(x1, x2), math.max(y1, y2) }
							local pos = c.positions[k + 1]
							local d = DIR_VEC[(c.direction + 4 * k) % 16]
							if pos and d then
								local tx, ty = pos.x + d[1], pos.y + d[2]
								local why = not inside(b, pos.x, pos.y) and "outside the collision box"
									or inside(b, tx, ty) and "faces into the machine" or nil
								if why then
									bad[#bad + 1] = string.format("box %d connection %d facing %s: (%g, %g) -> (%g, %g) %s",
										i, j, FACING[k], pos.x, pos.y, tx, ty, why)
								end
							end
						end
					end
				end
			end
			if #bad > 0 then
				rows[#rows + 1] = table.concat({ p.type, name, h.created or "", table.concat(bad, "; ") }, "\t")
			end
		end
	end
	rows[#rows + 1] = "#checked\t" .. checked
	log("DEVCHECK-PIPECONN-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-PIPECONN-END")
end

script.on_init(function()
	owners()
	names_rows()
	placeable_rows()
	intermediate_rows()
	pipe_rows()
end)
