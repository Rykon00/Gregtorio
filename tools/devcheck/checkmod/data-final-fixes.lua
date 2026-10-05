--- Dumps the final prototype state into the log for tools/devcheck/devcheck.py.
--- Every section is framed by DEVCHECK-<NAME>-BEGIN / -END lines, one tab-separated row per line.
local function section(name, rows)
	log("DEVCHECK-" .. name .. "-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-" .. name .. "-END")
end
local function names(list)
	local t = {}
	for _, x in pairs(list or {}) do
		if type(x) == "table" then t[#t + 1] = (x.type or "item") .. ":" .. (x.name or x[1]) else t[#t + 1] = tostring(x) end
	end
	return table.concat(t, ",")
end

--- R recipe category enabled ingredients results hidden hide_from_player_crafting subgroup group
--- C crafter type categories fluid_in fluid_out
--- I item type place_result | F fluid | T tech prereqs unlocks science trigger enabled
--- M resource result results category | O offshore-pump fluid
local dump = {}
local function D(...) dump[#dump + 1] = table.concat({ ... }, "\t") end
--- subgroup and tab of a recipe as the crafting menu shows it (without subgroup: the main product's)
local function product_proto(n)
	if data.raw.fluid[n] then return data.raw.fluid[n] end
	for t, _ in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][n] then return data.raw[t][n] end
	end
end
local function recipe_subgroup(r)
	if r.subgroup then return r.subgroup end
	local main = r.main_product
	if (not main or main == "") and r.results and #r.results == 1 then main = r.results[1].name end
	local p = main and main ~= "" and product_proto(main)
	if not p then return "other" end
	return p.subgroup or (p.type == "fluid" and "fluid" or "other")
end
for n, r in pairs(data.raw.recipe) do
	local sg = recipe_subgroup(r)
	local g = data.raw["item-subgroup"][sg] and data.raw["item-subgroup"][sg].group or "other"
	D("R", n, r.category or "crafting", tostring(r.enabled ~= false), names(r.ingredients), names(r.results),
		tostring(r.hidden == true), tostring(r.hide_from_player_crafting == true), sg, g)
end
for _, t in pairs({ "assembling-machine", "furnace", "rocket-silo", "character" }) do
	for n, e in pairs(data.raw[t] or {}) do
		local fi, fo = 0, 0
		for _, fb in pairs(e.fluid_boxes or {}) do
			if fb.production_type == "input" or fb.production_type == "input-output" then fi = fi + 1 end
			if fb.production_type == "output" then fo = fo + 1 end
		end
		D("C", n, t, table.concat(e.crafting_categories or {}, ","), fi, fo)
	end
end
for t, _ in pairs(defines.prototypes.item) do
	for n, it in pairs(data.raw[t] or {}) do D("I", n, t, it.place_result or "") end
end
for n, _ in pairs(data.raw.fluid) do D("F", n) end
for n, tech in pairs(data.raw.technology) do
	local eff, ing = {}, {}
	for _, e in pairs(tech.effects or {}) do if e.type == "unlock-recipe" then eff[#eff + 1] = e.recipe end end
	if tech.unit then for _, i in pairs(tech.unit.ingredients or {}) do ing[#ing + 1] = i[1] or i.name end end
	local trig = tech.research_trigger and serpent.line(tech.research_trigger) or ""
	D("T", n, table.concat(tech.prerequisites or {}, ","), table.concat(eff, ","), table.concat(ing, ","), trig,
		tostring(tech.enabled ~= false and not tech.hidden))
end
for n, e in pairs(data.raw.resource) do
	local m = e.minable or {}
	D("M", n, m.result or "", names(m.results), e.category or "basic-solid")
end
for n, e in pairs(data.raw["offshore-pump"] or {}) do D("O", n, e.fluid or "") end
--- B item burnt_result fuel_category | U entity fuel_categories (burners: a fuel's burnt result comes out of them)
for t, _ in pairs(defines.prototypes.item) do
	for n, it in pairs(data.raw[t] or {}) do
		if it.burnt_result and it.fuel_category then D("B", n, it.burnt_result, it.fuel_category) end
	end
end
for t, _ in pairs(defines.prototypes.entity) do
	for n, e in pairs(data.raw[t] or {}) do
		for _, src in pairs({ e.energy_source, e.burner }) do
			if type(src) == "table" and src.type == "burner" and (src.burnt_inventory_size or 0) > 0 then
				D("U", n, table.concat(src.fuel_categories or { src.fuel_category or "chemical" }, ","))
			end
		end
	end
end
section("DUMP", dump)

--- Issue #91: the Gregtorio recipes that stay locked on purpose (FORK_RECIPES_LOCKED in
--- prototypes/142-fork-recipe-unlocks.lua; absent in older versions)
local lk = {}
for name, reason in pairs(FORK_RECIPES_LOCKED or {}) do lk[#lk + 1] = name .. "\t" .. reason end
section("LOCKEDOK", lk)

--- Issue #126: the recipes of items only the crafting table, the ME Molecular Assembler or the hand can make, on purpose
--- (FORK_RECIPES_TABLE_ONLY in prototypes/148-fork-gtnh-table-items.lua; absent in older versions)
local tk = {}
for name, reason in pairs(FORK_RECIPES_TABLE_ONLY or {}) do tk[#tk + 1] = name .. "\t" .. reason end
section("TABLEONLYOK", tk)

--- Issue #118 (prototypes/194-fork-material-parts.lua): the material parts in rows by form; the materials without a tier
--- (absent in older versions)
local mp = {}
if FORK_MATERIAL_PARTS then
	mp[#mp + 1] = "count\t" .. FORK_MATERIAL_PARTS.parts .. "\t" .. FORK_MATERIAL_PARTS.materials
	for _, m in pairs(FORK_MATERIAL_PARTS.unranked) do mp[#mp + 1] = "unranked\t" .. m end
end
section("MATERIALPARTS", mp)

--- Every __gregtorio-continued__/ file referenced anywhere, with its owner prototype
local paths, seen = {}, {}
local function scan(t, owner, depth)
	if depth > 12 then return end
	for _, v in pairs(t) do
		if type(v) == "string" and v:sub(1, 24) == "__gregtorio-continued__/" then
			local k = v .. "\t" .. owner
			if not seen[k] then seen[k] = true; paths[#paths + 1] = k end
		elseif type(v) == "table" then
			scan(v, owner, depth + 1)
		end
	end
end
for t, ps in pairs(data.raw) do for n, p in pairs(ps) do scan(p, t .. ":" .. n, 0) end end
section("PATHS", paths)

--- Sprite layers of crafting machines (to check sheet sizes against the image files)
local sprites = {}
local function layers_of(anim)
	if not anim then return {} end
	return anim.layers or { anim }
end
for n, e in pairs(data.raw["assembling-machine"]) do
	local gs = e.graphics_set or {}
	for _, key in pairs({ "animation", "idle_animation" }) do
		for _, l in pairs(layers_of(gs[key])) do
			if l.filename then
				sprites[#sprites + 1] = table.concat({ n, key, l.filename, l.width or 0, l.height or 0,
					l.frame_count or 1, l.line_length or 0, l.x or 0, l.y or 0 }, "\t")
			end
		end
	end
end
section("SPRITES", sprites)

--- Prototypes with a Gregtorio icon, for locale checks (tools/gen_locale.py input format)
local loc = {}
local function greg(p) return type(p.icon) == "string" and p.icon:sub(1, 24) == "__gregtorio-continued__/" end
for t, _ in pairs(defines.prototypes.item) do
	for n, p in pairs(data.raw[t] or {}) do if greg(p) then loc[#loc + 1] = "item-name\t" .. n end end
end
for n, p in pairs(data.raw.fluid) do if greg(p) then loc[#loc + 1] = "fluid-name\t" .. n end end
for n, p in pairs(data.raw.technology) do
	if greg(p) and p.enabled ~= false then loc[#loc + 1] = "technology-name\t" .. n end
end
for t, _ in pairs(defines.prototypes.entity) do
	for n, p in pairs(data.raw[t] or {}) do if greg(p) and p.minable then loc[#loc + 1] = "entity-name\t" .. n end end
end
section("LOCALE", loc)

--- Technology icons
local ti = {}
for n, t in pairs(data.raw.technology) do
	if t.enabled ~= false and not t.hidden then ti[#ti + 1] = n .. "\t" .. tostring(t.icon) end
end
section("TECHICONS", ti)

--- Crafting menu (issue #49): the startup setting and the allow-list of recipes that stay hidden
--- (FORK_CRAFTING_MENU_HIDDEN in prototypes/198-fork-crafting-menu.lua; absent in older versions)
local cm = {}
local s = settings.startup["gregtorio-continued-show-machine-recipes"]
cm[#cm + 1] = "setting\t" .. (s and tostring(s.value) or "absent")
for kind, list in pairs(FORK_CRAFTING_MENU_HIDDEN or {}) do
	for name, reason in pairs(list) do cm[#cm + 1] = kind .. "\t" .. name .. "\t" .. reason end
end
section("CRAFTMENU", cm)

--- Fluids tab: name, subgroup (Factorio's default "other" when there is none), its group and order, hidden,
--- parameter, order, icon, icon_size (prototypes/196-fork-subgroups.lua; `devcheck.py check --fluids-out`)
local fl = {}
for n, f in pairs(data.raw.fluid) do
	local sg = f.subgroup or "other"
	local sgp = data.raw["item-subgroup"][sg] or {}
	local icon = f.icon or (f.icons and f.icons[1] and f.icons[1].icon) or ""
	local size = f.icon_size or (f.icons and f.icons[1] and f.icons[1].icon_size) or 64
	fl[#fl + 1] = table.concat({ n, sg, sgp.group or "other", sgp.order or "", tostring(f.hidden == true),
		tostring(f.parameter == true), f.order or "", icon, size }, "\t")
end
section("FLUIDS", fl)

--- fluids that keep an icon of another mod on purpose (FORK_FLUID_ICONS_KEPT in prototypes/196-fork-subgroups.lua, issue #119;
--- absent in older versions)
local fk = {}
for name, reason in pairs(FORK_FLUID_ICONS_KEPT or {}) do fk[#fk + 1] = name .. "\t" .. reason end
section("FLUIDICONSOK", fk)

--- Fluid amounts off the grid of 2^-24 (issue #117, prototypes/197-fork-fluid-steps.lua): recipe, kind, fluid, amount.
--- The game cuts every amount off at the step below, so a recipe that is not on the grid gives and takes less than it says.
local off = {}
for n, r in pairs(data.raw.recipe) do
	for _, key in pairs({ "ingredients", "results" }) do
		for _, x in pairs(r[key] or {}) do
			if x.type == "fluid" then
				for _, f in pairs({ "amount", "amount_min", "amount_max" }) do
					local a = x[f]
					if a and a * 2 ^ 24 ~= math.floor(a * 2 ^ 24) then
						off[#off + 1] = table.concat({ n, key, x.name, string.format("%.12g", a) }, "\t")
					end
				end
			end
		end
	end
end
section("FLUIDSTEPS", off)

--- Balance data (`devcheck.py check --balance-out`): recipes with amounts and times, machine speeds,
--- technology unit counts. One JSON object per line.
local bal = {}
local function stacks(list)
	local t = {}
	for _, x in pairs(list or {}) do
		t[#t + 1] = {
			name = x.name or x[1], type = x.type or "item", amount = x.amount or x[2],
			amount_min = x.amount_min, amount_max = x.amount_max, probability = x.probability,
			catalyst = x.ignored_by_productivity,
		}
	end
	return t
end
for n, r in pairs(data.raw.recipe) do
	bal[#bal + 1] = helpers.table_to_json({
		kind = "recipe", name = n, category = r.category or "crafting", time = r.energy_required or 0.5,
		enabled = r.enabled ~= false, hidden = r.hidden == true,
		ingredients = stacks(r.ingredients), results = stacks(r.results),
	})
end
for _, t in pairs({ "assembling-machine", "furnace", "rocket-silo" }) do
	for n, e in pairs(data.raw[t] or {}) do
		bal[#bal + 1] = helpers.table_to_json({
			kind = "crafter", name = n, speed = e.crafting_speed, categories = e.crafting_categories,
			energy = e.energy_usage,
		})
	end
end
for n, tech in pairs(data.raw.technology) do
	local u = tech.unit
	bal[#bal + 1] = helpers.table_to_json({
		kind = "tech", name = n, enabled = tech.enabled ~= false and not tech.hidden,
		prerequisites = tech.prerequisites or {},
		unlocks = (function() local e = {} for _, x in pairs(tech.effects or {}) do
			if x.type == "unlock-recipe" then e[#e + 1] = x.recipe end end return e end)(),
		count = u and u.count, count_formula = u and u.count_formula, time = u and u.time,
		ingredients = u and stacks(u.ingredients) or {}, max_level = tech.max_level,
	})
end
section("BALANCE", bal)

--- Startup settings of the mod (name, value), so a check knows what it is looking at (`devcheck.py check --set`)
local st = {}
for name, v in pairs(settings.startup) do
	if name:find("^gregtorio%-continued%-") then st[#st + 1] = name .. "\t" .. tostring(v.value) end
end
section("SETTINGS", st)
