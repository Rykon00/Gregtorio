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
--- I item type place_result uses | F fluid | T tech prereqs unlocks science trigger enabled
---   (uses, issue #547: what an item does besides being an ingredient: fuel, tile, equipment, plant)
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
	D("R", n, table.concat(r.categories or { "crafting" }, ","), tostring(r.enabled ~= false), names(r.ingredients), names(r.results),
		tostring(r.hidden == true), tostring(r.hide_from_player_crafting == true), sg, g, r.icon or "")
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
	for n, it in pairs(data.raw[t] or {}) do
		local uses = {}
		if it.fuel_value and not tostring(it.fuel_value):match("^0*%.?0*%a*$") then uses[#uses + 1] = "fuel" end
		if it.place_as_tile then uses[#uses + 1] = "tile" end
		if it.place_as_equipment_result then uses[#uses + 1] = "equipment" end
		if it.plant_result then uses[#uses + 1] = "plant" end
		D("I", n, t, it.place_result or "", table.concat(uses, ","))
	end
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
--- P resource planet technology (issue #501): the resources a planet's map generation places and the technology that
--- reaches the planet (FORK_ORE_VEINS of 163; "" for Nauvis and any planet without one: from the start)
for pname, planet in pairs(data.raw.planet or {}) do
	local mgs = planet.map_gen_settings
	local ent = mgs and mgs.autoplace_settings and mgs.autoplace_settings.entity
	local tech = ""
	for dim, p in pairs(FORK_ORE_VEINS and FORK_ORE_VEINS.planets or {}) do
		if p == pname then tech = (FORK_ORE_VEINS.techs or {})[dim] or "" end
	end
	for name in pairs(ent and ent.settings or {}) do
		if data.raw.resource[name] then D("P", name, pname, tech) end
	end
end
for n, e in pairs(data.raw["offshore-pump"] or {}) do D("O", n, e.fluid or "") end
--- B item burnt_result fuel_categories | U entity fuel_categories (burners: a fuel's burnt result comes out of them)
for t, _ in pairs(defines.prototypes.item) do
	for n, it in pairs(data.raw[t] or {}) do
		if it.burnt_result and it.fuel_categories then D("B", n, it.burnt_result, table.concat(it.fuel_categories, ",")) end
	end
end
for t, _ in pairs(defines.prototypes.entity) do
	for n, e in pairs(data.raw[t] or {}) do
		for _, src in pairs({ e.energy_source, e.burner }) do
			if type(src) == "table" and src.type == "burner" and (src.burnt_inventory_size or 0) > 0 then
				D("U", n, table.concat(src.fuel_categories or { "chemical" }, ","))
			end
		end
	end
end
--- K recipe item: the mold or lens a recipe needs in the machine's module slot, not as an ingredient
--- (prototypes/150-fork-molds.lua, issue #316; absent in older versions)
local md = data.raw["mod-data"] and data.raw["mod-data"]["fork-mold-recipes"]
for n, item in pairs(md and md.data or {}) do D("K", n, item) end
section("DUMP", dump)

--- Issue #91: the Gregtorio recipes that stay locked on purpose (FORK_RECIPES_LOCKED in
--- prototypes/142-fork-recipe-unlocks.lua; absent in older versions)
local lk = {}
for name, reason in pairs(FORK_RECIPES_LOCKED or {}) do lk[#lk + 1] = name .. "\t" .. reason end
section("LOCKEDOK", lk)

--- Issue #237: the causes of recipes unlocked before their technology's science can make them, kept on purpose
--- (FORK_UNLOCK_GAPS in prototypes/142-fork-recipe-unlocks.lua, "<technology>:<cause>" -> reason; absent in older versions)
local ug = {}
for key, reason in pairs(FORK_UNLOCK_GAPS or {}) do ug[#ug + 1] = key .. "\t" .. reason end
section("UNLOCKGAPOK", ug)

--- Issue #252: items a technology's recipes take that its prerequisites do not make yet, kept on purpose
--- (FORK_UNLOCK_TREE_GAPS in prototypes/142-fork-recipe-unlocks.lua, "<technology>:<item>" -> reason; absent in older versions)
local ut = {}
for key, reason in pairs(FORK_UNLOCK_TREE_GAPS or {}) do ut[#ut + 1] = key .. "\t" .. reason end
section("UNLOCKTREEOK", ut)

--- Issue #556: machines a technology unlocks before any recipe they can run, kept on purpose
--- (FORK_MACHINES_BEFORE_RECIPES in prototypes/142-fork-recipe-unlocks.lua, "<technology>:<machine>" -> reason; absent in
--- older versions)
local me = {}
for key, reason in pairs(FORK_MACHINES_BEFORE_RECIPES or {}) do me[#me + 1] = key .. "\t" .. reason end
section("MACHINEEARLYOK", me)

--- Issue #560: recipes with the same inputs in a furnace machine's categories, kept on purpose (FORK_FURNACE_SAME_INPUTS in
--- prototypes/101-fork-machines.lua, "<recipe>+<recipe>" -> { wins = <recipe>, reason = ... }; absent in older versions)
local fs = {}
for key, v in pairs(FORK_FURNACE_SAME_INPUTS or {}) do fs[#fs + 1] = key .. "\t" .. tostring(v.wins) .. "\t" .. tostring(v.reason) end
section("FURNACESAMEOK", fs)

--- Issue #571: steam macerator copies that come with a technology of a higher science than Steam Macerator although their
--- input is there at its science, kept on purpose (FORK_STEAM_LATE in prototypes/101-fork-machines.lua, recipe -> reason;
--- absent in older versions)
local sl = {}
for name, reason in pairs(FORK_STEAM_LATE or {}) do sl[#sl + 1] = name .. "\t" .. reason end
section("STEAMLATEOK", sl)

--- Issue #586: technologies that make a nugget by an ore form's furnace recipe before any nugget -> ingot recipe, kept on
--- purpose (FORK_NUGGETS_BEFORE_INGOTS in prototypes/101-fork-machines.lua, "<technology>:<nugget>" -> reason; absent in
--- older versions)
local ni = {}
for key, reason in pairs(FORK_NUGGETS_BEFORE_INGOTS or {}) do ni[#ni + 1] = key .. "\t" .. reason end
section("NUGGETINGOTOK", ni)

--- Issue #564: steam per second of the boilers and steam machines (FORK_STEAM_RATES of prototypes/fork-steam-rates.lua);
--- one row per entity: name, kind (boiler, solar, uses), fluid, rate, Small Coal Boilers or "", then whether the line is in
--- the entity's description and in its items' ("entity", "items": the ones that lack it), then a boiler's watts (issue
--- #593, "" for the others) (absent in older versions)
local sr = {}
local function has_line(p) return p and serpent.line(p.localised_description or ""):find("fork%-steam%.") ~= nil end
for name, s in pairs(FORK_STEAM_RATES or {}) do
	local e = s.type and data.raw[s.type] and data.raw[s.type][name]
	local lacking = {}
	for _, kind in pairs({ "item", "item-with-entity-data" }) do
		for iname, it in pairs(data.raw[kind] or {}) do
			if it.place_result == name and s.line ~= false and not has_line(it) then lacking[#lacking + 1] = iname end
		end
	end
	sr[#sr + 1] = table.concat({ name, s.kind, s.fluid, tostring(s.rate), s.boilers and tostring(s.boilers) or "",
		(s.line == false and "game") or (has_line(e) and "entity") or "-", table.concat(lacking, ","),
		s.watts and tostring(s.watts) or "" }, "\t")
end
section("STEAMRATES", sr)

--- Issue #593: the boiler output setting (FORK_BOILER_OUTPUT of prototypes/fork-boiler-output.lua): a row with the factor,
--- then one per entity: name, "changed" or "left", its kind or the reason (absent in older versions)
local bo = {}
if FORK_BOILER_OUTPUT then
	bo[1] = "factor\t" .. tostring(FORK_BOILER_OUTPUT.factor)
	for name, what in pairs(FORK_BOILER_OUTPUT.changed) do bo[#bo + 1] = name .. "\tchanged\t" .. what end
	for name, why in pairs(FORK_BOILER_OUTPUT.left_out) do bo[#bo + 1] = name .. "\tleft\t" .. why end
end
section("BOILEROUTPUT", bo)

--- Issue #126: the recipes of items only the crafting table, the ME Molecular Assembler or the hand can make, on purpose
--- (FORK_RECIPES_TABLE_ONLY in prototypes/148-fork-gtnh-table-items.lua; absent in older versions)
local tk = {}
for name, reason in pairs(FORK_RECIPES_TABLE_ONLY or {}) do tk[#tk + 1] = name .. "\t" .. reason end
section("TABLEONLYOK", tk)

--- Issue #547: the items whose only use is a technology's craft-item trigger, on purpose (FORK_TRIGGER_ONLY_ITEMS in
--- prototypes/100-fork-fixes.lua; absent in older versions)
local to = {}
for name, reason in pairs(FORK_TRIGGER_ONLY_ITEMS or {}) do to[#to + 1] = name .. "\t" .. reason end
section("TRIGGERONLYOK", to)

--- Issue #639: the icon files of Gregtorio's own graphics on technologies, items, fluids and recipes (class, name, files),
--- for devcheck's rule against the NYI placeholder; and the ones that keep it on purpose (FORK_NYI_ICONS of
--- prototypes/199-fork-finalize.lua, absent in older versions)
local ic, nk = {}, {}
local function icon_files(p)
	local files = {}
	if p.icon then files[#files + 1] = p.icon end
	for _, layer in pairs(p.icons or {}) do files[#files + 1] = layer.icon end
	local own = {}
	for _, f in pairs(files) do if f:find("__gregtorio-continued__/", 1, true) == 1 then own[#own + 1] = f end end
	return own
end
local function icon_rows(class, list)
	for name, p in pairs(list or {}) do
		local own = icon_files(p)
		if #own > 0 then ic[#ic + 1] = class .. "\t" .. name .. "\t" .. table.concat(own, ",") end
	end
end
icon_rows("technology", data.raw.technology)
icon_rows("fluid", data.raw.fluid)
icon_rows("recipe", data.raw.recipe)
for t, _ in pairs(defines.prototypes.item) do icon_rows("item", data.raw[t]) end
for name, reason in pairs(FORK_NYI_ICONS or {}) do nk[#nk + 1] = name .. "\t" .. reason end
section("ICONS", ic)
section("NYIOK", nk)

--- Issue #318: the vanilla recipes without a technology, of items Gregtorio makes, that stay on purpose
--- (FORK_VANILLA_RECIPES_KEPT in data-final-fixes.lua; absent in older versions)
local vk = {}
for name, reason in pairs(FORK_VANILLA_RECIPES_KEPT or {}) do vk[#vk + 1] = name .. "\t" .. reason end
section("VANILLAKEPT", vk)

--- Issue #325: the laser engraver recipes that keep no lens on purpose (FORK_ENGRAVER_NO_LENS in
--- prototypes/155-fork-ore-chain.lua; absent in older versions)
local nl = {}
for name, reason in pairs(FORK_ENGRAVER_NO_LENS or {}) do nl[#nl + 1] = name .. "\t" .. reason end
section("ENGRAVERNOLENS", nl)

--- Issue #335: the Manual Mine and Dig Site recipes, their electric twins (FORK_ELECTRIC_MINE.twins in
--- prototypes/163-fork-electric-mine.lua; issue #337: FORK_ELECTRIC_MINE.miner_twins of the miners) and the ones without
--- a twin on purpose (FORK_ELECTRIC_MINE_EXCLUDED); one row per name: name, "manual" or "-", the twin or "-", the
--- allow-list reason, the miners' twin or "-" (absent in older versions)
local em, em_seen = {}, {}
local function em_row(name)
	if em_seen[name] then return end
	em_seen[name] = true
	local fem = FORK_ELECTRIC_MINE or {}
	local r, twin, miner = data.raw.recipe[name], (fem.twins or {})[name], (fem.miner_twins or {})[name]
	local cat = r and r.categories and r.categories[1]
	local manual = cat == "manual-mine-recipes" or cat == "manual-digsite-recipes"
	em[#em + 1] = table.concat({ name, manual and "manual" or "-", (twin and data.raw.recipe[twin]) and twin or "-",
		(FORK_ELECTRIC_MINE_EXCLUDED or {})[name] or "", (miner and data.raw.recipe[miner]) and miner or "-" }, "\t")
end
for name, r in pairs(data.raw.recipe) do
	local cat = r.categories and r.categories[1]
	if cat == "manual-mine-recipes" or cat == "manual-digsite-recipes" then em_row(name) end
end
for name in pairs(FORK_ELECTRIC_MINE_EXCLUDED or {}) do em_row(name) end
section("ELECTRICMINE", em)

--- Issue #563: every vein the map places (GT's mixes of FORK_ORE_MIXES on a planet of FORK_ORE_VEINS, not skipped),
--- read here from the data, not from 166's list, with its classic recipe and twins (prototypes/166-fork-classic-veins.lua)
--- and the ores the vein holds; one row per mix: name, recipe, twin, miner ("-": none), the vein's ores, the recipe's
--- results (absent in older versions)
local cv = {}
if FORK_ORE_MIXES and FORK_CLASSIC_VEINS then
	local by_mix = {}
	for _, v in pairs(FORK_CLASSIC_VEINS.veins) do by_mix[v.mix] = v end
	for _, m in ipairs(FORK_ORE_MIXES.mixes) do
		local placed = false
		for _, d in pairs(m.dimensions) do if FORK_ORE_VEINS.planets[d] then placed = true end end
		if placed and not (FORK_ORE_MIX_SKIPPED or {})["mix:" .. m.name] then
			local v = by_mix[m.name] or {}
			local function have(n) return (n and data.raw.recipe[n]) and n or "-" end
			local ores, seen = {}, {}
			for _, role in pairs({ "primary", "secondary", "between", "sporadic" }) do
				local x = FORK_ORE_VEINS.ore_of(m, role)
				if x and not seen[x] then seen[x] = true; ores[#ores + 1] = "raw-" .. x end
			end
			local res = {}
			local r = v.recipe and data.raw.recipe[v.recipe]
			for _, x in pairs(r and r.results or {}) do res[#res + 1] = x.name end
			cv[#cv + 1] = table.concat({ m.name, have(v.recipe), have(v.twin), have(v.miner), table.concat(ores, ","),
				table.concat(res, ","), v.kept and "kept" or "" }, "\t")
		end
	end
end
section("CLASSICVEINS", cv)

--- Issue #574: the placed veins for the vein table of docs/ORE-VEINS.md (FORK_ORE_VEINS.table of 165); one row per vein:
--- mix, label, planets, primary, secondary, between, sporadic ("" left out), weight, density, size (absent in older
--- versions)
local vt = {}
for _, v in ipairs(FORK_ORE_VEINS and FORK_ORE_VEINS.table or {}) do
	vt[#vt + 1] = table.concat({ v.mix, v.label, table.concat(v.planets, ","), v.primary, v.secondary, v.between,
		v.sporadic, tostring(v.weight), tostring(v.density), tostring(v.size) }, "\t")
end
section("VEINTABLE", vt)

--- Issue #214: the recipes of me-network (ME_NETWORK.recipes) and which of them prototypes/120-fork-me-network-compat.lua
--- gives a Gregtorio recipe (FORK_ME_RECIPES) or keeps standalone on purpose (FORK_ME_RECIPES_STANDALONE); one row per
--- name: name, "me" (a recipe of me-network) or "-", "gregtorio" or "-", the allow-list reason (absent in older versions)
local mr, mr_seen = {}, {}
local function me_row(name)
	if mr_seen[name] then return end
	mr_seen[name] = true
	local listed = false
	for _, n in pairs(ME_NETWORK and ME_NETWORK.recipes or {}) do if n == name then listed = true end end
	mr[#mr + 1] = table.concat({ name, listed and "me" or "-", (FORK_ME_RECIPES or {})[name] and "gregtorio" or "-",
		(FORK_ME_RECIPES_STANDALONE or {})[name] or "" }, "\t")
end
for _, name in pairs(ME_NETWORK and ME_NETWORK.recipes or {}) do me_row(name) end
for name in pairs(FORK_ME_RECIPES_STANDALONE or {}) do me_row(name) end
section("MERECIPES", mr)

--- Issue #519: the ME items (ME_NETWORK.items and Gregtorio's own FORK_ME_TAB_ITEMS) with their subgroup and its item
--- group, the allow-list FORK_ME_TAB_OUTSIDE, and the Gregtorio recipes of ME items (FORK_ME_RECIPES) that sit in a row
--- of the tab, with the row of their item; rows "group" name, "item" name subgroup group, "allow" name reason, "recipe"
--- name subgroup item-subgroup (absent in older versions)
local function any_item(name)
	for t in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][name] then return data.raw[t][name] end
	end
end
local function group_of(subgroup)
	local sg = subgroup and data.raw["item-subgroup"][subgroup]
	return sg and sg.group or "-"
end
local mt = { "group\t" .. (ME_NETWORK and ME_NETWORK.GROUP or "-") }
for _, list in pairs({ ME_NETWORK and ME_NETWORK.items or {}, FORK_ME_TAB_ITEMS or {} }) do
	for _, name in pairs(list) do
		local item = any_item(name)
		if item then mt[#mt + 1] = table.concat({ "item", name, item.subgroup or "-", group_of(item.subgroup) }, "\t") end
	end
end
for name, reason in pairs(FORK_ME_TAB_OUTSIDE or {}) do mt[#mt + 1] = "allow\t" .. name .. "\t" .. reason end
for name in pairs(FORK_ME_RECIPES or {}) do
	local r = data.raw.recipe[name]
	if r and ME_NETWORK and group_of(r.subgroup) == ME_NETWORK.GROUP then
		local item = any_item(r.main_product or (r.results and r.results[1] and r.results[1].name) or name)
		mt[#mt + 1] = table.concat({ "recipe", name, r.subgroup, item and item.subgroup or "-" }, "\t")
	end
end
section("METAB", mt)

--- Issue #496: GT's ore mixes (FORK_ORE_MIXES of prototypes/165-fork-ore-veins.lua) with Gregtorio's surfaces, the ores
--- left out (FORK_ORE_MIX_SKIPPED) and those without an ore chain (FORK_ORE_MIX_NO_CHAIN); rows "surface" dimension,
--- "mix" name dimensions, "ore" mix role material raw-item-or-"-", "skip" key reason, "nochain" material reason
--- (absent in older versions)
local om = {}
for d in pairs(FORK_ORE_MIX_SURFACES or {}) do om[#om + 1] = "surface\t" .. d end
for _, mix in pairs(FORK_ORE_MIXES and FORK_ORE_MIXES.mixes or {}) do
	om[#om + 1] = "mix\t" .. mix.name .. "\t" .. table.concat(mix.dimensions, ",")
	for _, role in pairs({ "primary", "secondary", "between", "sporadic" }) do
		local raw = "raw-" .. mix[role]
		om[#om + 1] = table.concat({ "ore", mix.name, role, mix[role], data.raw.item[raw] and raw or "-" }, "\t")
	end
end
for key, reason in pairs(FORK_ORE_MIX_SKIPPED or {}) do om[#om + 1] = "skip\t" .. key .. "\t" .. reason end
for key, reason in pairs(FORK_ORE_MIX_NO_CHAIN or {}) do om[#om + 1] = "nochain\t" .. key .. "\t" .. reason end
section("OREMIXES", om)

--- Issue #202: the raw ores without a forge hammer recipe on purpose (FORK_ORE_HAMMER_SKIP in
--- prototypes/155-fork-ore-chain.lua; absent in older versions)
local hk = {}
for name, reason in pairs(FORK_ORE_HAMMER_SKIP or {}) do hk[#hk + 1] = name .. "\t" .. reason end
section("HAMMERSKIPOK", hk)
--- the raw ores whose forge hammer recipe gives GT's gem instead of the crushed ore (FORK_ORE_HAMMER_GEM)
local hg = {}
for name, gem in pairs(FORK_ORE_HAMMER_GEM or {}) do hg[#hg + 1] = name .. "\t" .. gem end
section("HAMMERGEM", hg)

--- Issue #118 (prototypes/200-fork-material-parts.lua): the material parts in rows by form; the materials without a tier
--- (absent in older versions)
local mp = {}
if FORK_MATERIAL_PARTS then
	mp[#mp + 1] = "count\t" .. FORK_MATERIAL_PARTS.parts .. "\t" .. FORK_MATERIAL_PARTS.materials
	for _, m in pairs(FORK_MATERIAL_PARTS.unranked) do mp[#mp + 1] = "unranked\t" .. m end
end
section("MATERIALPARTS", mp)

--- Issue #190 (prototypes/157-fork-recycling.lua): the recycling blacklist with its reasons (absent in older versions)
local rb = {}
for item, why in pairs(FORK_RECYCLING_BLACKLIST or {}) do
	rb[#rb + 1] = item .. "\t" .. tostring(why or "") .. "\t" .. tostring(data.raw.item[item] ~= nil or data.raw.tool[item] ~= nil)
end
section("RECYCLEBLACK", rb)

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

--- Issue #230: the prototypes that stay without a name on purpose (FORK_LOCALE_MISSING in prototypes/fork-locale.lua,
--- "<class>:<name>" -> reason; absent in older versions). The names themselves are checked on the runtime prototypes
--- (section NAMES of control.lua): only the engine knows the name it resolves and the mod that created a prototype.
local lo = {}
for key, reason in pairs(FORK_LOCALE_MISSING or {}) do lo[#lo + 1] = key .. "\t" .. reason end
section("LOCALEOK", lo)

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
			amount_min = x.amount_min, amount_max = x.amount_max, probability = x.independent_probability,
			shared_probability = x.shared_probability,
			catalyst = x.ignored_by_productivity,
		}
	end
	return t
end
for n, r in pairs(data.raw.recipe) do
	bal[#bal + 1] = helpers.table_to_json({
		-- (issue #535: `category` is the first of Factorio 2.1's `categories`, the one of a Gregtorio recipe, as 2.0's files
		-- have it; `categories` all of them)
		kind = "recipe", name = n, category = (r.categories or { "crafting" })[1], categories = r.categories or { "crafting" },
		time = r.energy_required or 0.5,
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

--- Issue #535 (the port to Factorio 2.1): every key a prototype still carries that Factorio removed (removed-keys.lua,
--- written by tools/devcheck/removed_keys.py from the API of both versions, as me-network's devcheck does). Factorio 2.1
--- refuses a few of them with an error (a recipe's `category`, a product's `probability`, an item's `fuel_category`, a
--- fluid box's temperatures) and ignores the others (a generator's `horizontal_animation`, a crafting machine's
--- `forced_symmetry`, a fluid box's `hide_connection_info`, ...), which fail silently. One row per key:
--- <data.raw type>/<name><path>, the key.
local K = require("removed-keys")
local found = {}
local function walk(v, node, path, seen)
	local spec = K.nodes[node]
	if type(v) ~= "table" or not spec then return end
	if spec.tag and type(v.type) == "string" and v.type ~= spec.tag then return end    -- (another option of a union)
	seen[v] = seen[v] or {}
	if seen[v][node] then return end
	seen[v][node] = true
	for i, x in ipairs(v) do walk(x, node, path .. "[" .. i .. "]", seen) end
	for k, x in pairs(v) do
		if type(k) == "string" then
			if spec.removed[k] then found[#found + 1] = path .. "\t" .. k end
			for _, n in ipairs(spec.fields[k] or {}) do walk(x, n, path .. "." .. k, seen) end
		end
	end
end
for t, list in pairs(data.raw) do
	local node = K.prototypes[t]
	if node then
		for n, p in pairs(list) do walk(p, node, t .. "/" .. n, {}) end
	end
end
table.sort(found)
section("REMOVEDKEYS", found)
