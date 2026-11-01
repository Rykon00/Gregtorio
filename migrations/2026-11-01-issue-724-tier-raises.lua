--- Issue #724: recipes that GT New Horizons runs in a higher tier moved into that tier's category
--- (prototypes/168-fork-gtnh-numbers.lua, mod data "fork-gtnh-raised"). When an older save loads, the game takes such a
--- recipe out of every machine below that tier before any script runs, and the fluid in the machine is lost; what it made
--- stays in its output. A machine left without a recipe whose output holds a product of a moved recipe its category ran
--- is reported in the chat with its position, so the player can put a machine of the new tier there. The game runs this
--- once per save.
local raised = prototypes.mod_data["fork-gtnh-raised"]
raised = raised and raised.data.recipes or {}
--- product -> the moved recipes that make it
local by_product = {}
for name, m in pairs(raised) do
	local r = prototypes.recipe[name]
	for _, x in pairs(r and r.products or {}) do
		if x.type == "item" then
			by_product[x.name] = by_product[x.name] or {}
			table.insert(by_product[x.name], { name = name, from = m.from, to = m.to })
		end
	end
end
--- the machines that ran a category a recipe moved from, and not the one it moved to
local machines = {}
for ename, e in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "assembling-machine" } }) do
	for _, m in pairs(raised) do
		if e.crafting_categories[m.from] and not e.crafting_categories[m.to] then
			machines[#machines + 1] = ename
			break
		end
	end
end
if #machines == 0 then return end
local found = {}
for _, surface in pairs(game.surfaces) do
	for _, e in pairs(surface.find_entities_filtered{ name = machines }) do
		if e.valid and not e.get_recipe() then
			local out = e.get_output_inventory()
			local hit
			for _, c in pairs(out and out.get_contents() or {}) do
				for _, m in pairs(by_product[c.name] or {}) do
					if e.prototype.crafting_categories[m.from] and not e.prototype.crafting_categories[m.to] then
						hit = m
						break
					end
				end
				if hit then break end
			end
			if hit then
				found[#found + 1] = { entity = e, recipe = hit.name, to = hit.to }
			end
		end
	end
end
if #found == 0 then return end
log("ISSUE-724: " .. #found .. " machines lost a recipe that moved to GT's higher tier")
local lines = { "[Gregtorio] " .. #found .. " machine(s) lost their recipe: GT New Horizons runs it in a higher tier, "
	.. "so it moved to that tier's machines (issue #724). Place a machine of that tier there:" }
for i, f in ipairs(found) do
	if i > 20 then
		lines[#lines + 1] = "... and " .. (#found - 20) .. " more (see the log, ISSUE-724)"
		break
	end
	local p = f.entity.position
	lines[#lines + 1] = string.format("[entity=%s] [recipe=%s] needs %s: [gps=%.1f,%.1f,%s]", f.entity.name, f.recipe,
		f.to:match("^(%a+)%-") and string.upper(f.to:match("^(%a+)%-")) or f.to, p.x, p.y, f.entity.surface.name)
end
for _, f in ipairs(found) do
	local p = f.entity.position
	log(string.format("ISSUE-724: %s at %.1f,%.1f on %s had %s (now %s)", f.entity.name, p.x, p.y, f.entity.surface.name,
		f.recipe, f.to))
end
for _, l in ipairs(lines) do game.print(l) end
