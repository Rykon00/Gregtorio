--------------------------------------------------------------------------------
--- FORK CLASSIC VEINS (issue #563, the maintainer's addendum of 2026-10-24): the vein recipes of the classic ore mode
--- (startup setting gregtorio-continued-ore-mode = vein-recipes), generated from the veins the map places (165's
--- FORK_ORE_VEINS.placed, GT's ore mixes of prototypes/data/ore-mixes.lua), so a new vein, ore or unlock reaches both
--- modes by itself. The prototypes exist in both modes (an old save keeps its mines' recipes on load: the engine drops
--- a recipe that is gone before any script runs); in map-vein mode they are hidden, disabled and never unlocked.
---   * one Manual Mine recipe per placed vein, `mining-<GT's mix name in kebab case>-vein` (GT's Iron -> mining-iron-vein,
---     LigniteCoal -> mining-lignite-coal-vein), also for a vein on several surfaces; a name that is a recipe already
---     (CopperTin: upstream's Copper Tin Vein, the realgar source of both modes) keeps that recipe; 163 makes the twins
---     (`drilling-<vein>`, `miner-<vein>`);
---   * results by one rule: ORES per operation, split by the expected ore tiles of each of GT's layers in the vein as
---     165 places it (size 1, the mean radius 8 + size / 2, GT's density falling by chunks from the centre, the nine bands
---     and gt_role_raw: a band's first ore, its second, the sporadic ore in 1/7 of the rest; averaged over four directions
---     of the bands); a layer whose ore is left out goes to the neighbouring layer's ore (165's ore_of); every ore at
---     least 1; 10 s, an iron pickaxe use and manual labor (LABOR_OW on the Overworld, LABOR_DIM elsewhere: 160's numbers
---     since #363);
---   * the stone pickaxe's iron vein `mining-iron-vein-with-stone-pickaxe` (GT's Iron, half the ores, three times the
---     labor, as in 0.5.5) with Craft Stone Tools, next to #547's cobblestone; no twins;
---   * unlocks by one rule (classic mode only): a vein of the Overworld comes with every first technology (no other of
---     them before it) that unlocks a recipe taking one of its raw ores, as the ore chains of map-vein mode decide them
---     (155's vein_techs is the same in both modes; a recipe there from the start does not count, the classic game starts
---     without ore); a technology without the iron pickaxe is replaced by the pickaxe's when that one comes after it. A
---     vein of the other surfaces comes with its surfaces' reach technology (163's FORK_ORE_VEINS.techs). The twins come
---     with the first plant's and the LV Miner's technology, or with the vein's when every one of them comes after it;
---     the dimension mines with their first recipe (163, #556);
---   * old saves: the names of 0.5.5's vein recipes that are not a generated name (LEGACY) stay hidden recipes with the
---     generated one's results; scripts/fork-ore-veins.lua gives a mine on one the generated recipe in classic mode and
---     converts it as the other vein recipes in map-vein mode (mod data fork-electric-mine: classic, legacy).
--- devcheck fails for a placed vein without its recipe and twins (section CLASSICVEINS). Loads after 165.
--------------------------------------------------------------------------------

local ORES = 64            -- ores per operation (the iron vein's of 0.5.5; its recipes gave 64 to 80)
local TIME = 10
local LABOR_OW, LABOR_DIM = 8, 24
local ROLES = { "primary", "secondary", "between", "sporadic" }

local function item(name, amount) return { type = "item", name = name, amount = amount } end

--- GT's mix name in kebab case: LigniteCoal -> lignite-coal, TFGalena -> tf-galena
local function kebab(s)
	s = s:gsub("(%u+)(%u%l)", "%1-%2"):gsub("(%l)(%u)", "%1-%2")
	return (s:lower())
end

--- the expected ore tiles of the four layers (primary, secondary, between, sporadic) of a vein as 165 places it
local function layer_tiles(m)
	local r = 8 + 0.5 * m.size
	local R = math.ceil(r)
	local tiles = { 0, 0, 0, 0 }
	for _, a in ipairs({ 0, 0.25, 0.5, 0.75 }) do
		local ca, sa = math.sin(a * math.pi + math.pi / 2), math.sin(a * math.pi)
		for dy = -R, R do
			for dx = -R, R do
				local d = math.sqrt(dx * dx + dy * dy)
				if d < r then
					local band = math.min(math.max(math.floor((dx * ca + dy * sa + r) / (2 * r) * 9), 0), 8) + 1
					local dens = math.max(1, math.floor(m.density / math.floor(math.sqrt(2 + (d / 16) ^ 2))))
					local px = 1 / math.max(1, math.floor((r + math.abs(dx)) / dens))
					local py = 1 / math.max(1, math.floor((r + math.abs(dy)) / dens))
					local p = math.min(1, FORK_ORE_VEINS.fill * (1 - (1 - px) * (1 - py)))
					local first = band <= 3 and 2 or band <= 5 and 3 or 1
					local second = band == 4 and 2 or (band == 6 or band == 7) and 3 or 0
					tiles[first] = tiles[first] + p
					if second > 0 then
						tiles[second] = tiles[second] + (1 - p) * p
						tiles[4] = tiles[4] + (1 - p) * (1 - p) * p / 7
					else
						tiles[4] = tiles[4] + (1 - p) * p / 7
					end
				end
			end
		end
	end
	return tiles
end

--- `total` ores of a vein split by its layers' tiles (largest remainder, every ore at least 1), most first
local function vein_results(m, total)
	local tiles, by_ore, order = layer_tiles(m), {}, {}
	for i, role in ipairs(ROLES) do
		local x = FORK_ORE_VEINS.ore_of(m, role)
		if x and tiles[i] > 0 then
			if not by_ore[x] then by_ore[x] = 0; order[#order + 1] = x end
			by_ore[x] = by_ore[x] + tiles[i]
		end
	end
	local sum = 0
	for _, x in ipairs(order) do sum = sum + by_ore[x] end
	local out, left = {}, total
	for _, x in ipairs(order) do
		local exact = total * by_ore[x] / sum
		local n = math.max(1, math.floor(exact))
		out[#out + 1] = { ore = x, amount = n, rest = exact - math.floor(exact) }
		left = left - n
	end
	table.sort(out, function(a, b) return a.rest > b.rest or (a.rest == b.rest and a.ore < b.ore) end)
	local i = 1
	while left ~= 0 and #out > 0 do
		local o = out[(i - 1) % #out + 1]
		if left > 0 then o.amount, left = o.amount + 1, left - 1
		elseif o.amount > 1 then o.amount, left = o.amount - 1, left + 1 end
		i = i + 1
	end
	table.sort(out, function(a, b) return a.amount > b.amount or (a.amount == b.amount and a.ore < b.ore) end)
	local results = {}
	for _, o in ipairs(out) do results[#results + 1] = item("raw-" .. o.ore, o.amount) end
	return results
end

--- 0.5.5's vein recipes whose name is not a generated one -> GT's mix (old saves; their twins follow)
local LEGACY = {
	["mining-chalcopyrite-vein"] = "Copper",
	["mining-salt-vein"] = "Salts",
	["mining-basaltic-mineral-sands-vein"] = "MineralSand",
	["mining-lignite-vein"] = "LigniteCoal",
	["mining-sphalerite-vein"] = "Sulfur",
	["mining-galena-vein"] = "TFGalena",
	["mining-saltpeter-electrotine-vein"] = "SaltPeterElectrotine",
}
local STONE_PICKAXE = "mining-iron-vein-with-stone-pickaxe"

FORK_CLASSIC_VEINS = { veins = {}, recipes = {}, legacy = {}, hidden = {} }   -- (hidden: never unlocked, 199)
local em_data = data.raw["mod-data"]["fork-electric-mine"].data
em_data.classic, em_data.legacy = {}, {}

local function hide(name)
	local r = data.raw.recipe[name]
	r.hidden, r.enabled = true, false
	FORK_CLASSIC_VEINS.hidden[name] = true
end

--------------------------------------------------------------------------------
--- THE RECIPES (both modes)
--------------------------------------------------------------------------------

local by_mix = {}
for _, v in ipairs(FORK_ORE_VEINS.placed) do
	local m = v.mix
	local name = "mining-" .. kebab(m.name) .. "-vein"
	local ow = v.dimensions[1] == "OW"
	local planets = {}
	for _, d in ipairs(v.dimensions) do planets[#planets + 1] = FORK_ORE_VEINS.planets[d] end
	local entry = { mix = m.name, label = m.label, recipe = name, dimensions = v.dimensions, planets = planets }
	FORK_CLASSIC_VEINS.veins[#FORK_CLASSIC_VEINS.veins + 1] = entry
	if data.raw.recipe[name] then
		--- (CopperTin: upstream's recipe of the same name stays, with its twins; classic mode moves its unlocks too)
		entry.kept = true
		entry.twin, entry.miner = FORK_ELECTRIC_MINE.twins[name], FORK_ELECTRIC_MINE.miner_twins[name]
		log("FORK-CLASSIC-VEINS: " .. name .. " is a recipe already, kept")
	else
		local results = vein_results(m, ORES)
		create_recipe{
			name = name,
			category = "manual-mine-recipes",
			energy_required = TIME,
			subgroup = "subgroup-mining",
			order = string.format("g[gt-vein]-%d-%04d", FORK_ORE_MIX_SURFACES[v.dimensions[1]], 9999 - m.weight),
			ingredients = { item("iron-pickaxe-usage", 1), item("manual-labor", ow and LABOR_OW or LABOR_DIM) },
			results = results,
			main_product = results[1].name,
		}
		data.raw.recipe[name].localised_name = { "recipe-name.gt-vein-mining", m.label }
		local twin, miner = FORK_ELECTRIC_MINE.make_twins(name)
		data.raw.recipe[twin].localised_name = { "recipe-name.gt-vein-drilling", m.label }
		data.raw.recipe[miner].localised_name = { "recipe-name.gt-vein-miner", m.label }
		entry.twin, entry.miner = twin, miner
		for _, n in pairs({ name, twin, miner }) do
			FORK_CLASSIC_VEINS.recipes[n] = entry
			em_data.classic[n] = { planets = planets, label = m.label }
		end
		local cats = { ["manual-mine-recipes"] = name, ["electric-mine-recipes"] = twin, ["miner-recipes"] = miner }
		em_data.veins[name], em_data.veins[twin], em_data.veins[miner] = name, name, name
		em_data.recipes[name] = cats
	end
	by_mix[m.name] = entry
end

--- the stone pickaxe's iron vein
do
	local iron = by_mix["Iron"]
	local m
	for _, v in ipairs(FORK_ORE_VEINS.placed) do if v.mix.name == "Iron" then m = v.mix end end
	local results = vein_results(m, ORES / 2)
	create_recipe{
		name = STONE_PICKAXE,
		category = "manual-mine-recipes",
		energy_required = TIME,
		subgroup = "subgroup-mining-poor",
		ingredients = { item("stone-pickaxe", 1), item("manual-labor", 3 * LABOR_OW) },
		results = results,
		main_product = results[1].name,
	}
	data.raw.recipe[STONE_PICKAXE].localised_name = { "recipe-name.gt-vein-stone-pickaxe", m.label }
	FORK_ELECTRIC_MINE_EXCLUDED[STONE_PICKAXE] = "issue #563: the stone pickaxe variant of the iron vein; its twins are "
		.. iron.twin .. " and " .. iron.miner
	FORK_CLASSIC_VEINS.recipes[STONE_PICKAXE] = iron
	em_data.classic[STONE_PICKAXE] = { planets = iron.planets, label = m.label }
end

--- old saves: the names of 0.5.5 that are no generated name, with the generated recipe's results
for old, mix in pairs(LEGACY) do
	local new = by_mix[mix]
	if not (new and new.twin) then error("166-fork-classic-veins: no generated recipe for the old " .. old .. " (" .. mix .. ")") end
	local pairs_ = { { old, new.recipe }, { (old:gsub("^mining%-", "drilling-")), new.twin },
		{ (old:gsub("^mining%-", "miner-")), new.miner } }
	for _, p in ipairs(pairs_) do
		local r = table.deepcopy(data.raw.recipe[p[2]])
		r.name, r.hidden, r.enabled, r.order = p[1], true, false, nil
		data:extend({ r })
		FORK_CLASSIC_VEINS.hidden[p[1]] = true
		FORK_CLASSIC_VEINS.legacy[p[1]] = p[2]
		em_data.legacy[p[1]] = p[2]
	end
	FORK_ELECTRIC_MINE.twins[old] = pairs_[2][1]
	FORK_ELECTRIC_MINE.miner_twins[old] = pairs_[3][1]
end

--------------------------------------------------------------------------------
--- THE UNLOCKS (classic mode); in map-vein mode every generated recipe is hidden
--------------------------------------------------------------------------------

if not FORK_CLASSIC_ORES then
	for n in pairs(FORK_CLASSIC_VEINS.recipes) do hide(n) end
	return
end

local unlocked_by = {}   -- recipe -> technologies
for tname, t in pairs(data.raw.technology) do
	for _, e in pairs(t.effects or {}) do
		if e.type == "unlock-recipe" then
			unlocked_by[e.recipe] = unlocked_by[e.recipe] or {}
			unlocked_by[e.recipe][tname] = true
		end
	end
end
local memo = {}
local function before(t)   -- t and its prerequisites, recursively
	if not memo[t] then
		local s = { [t] = true }
		memo[t] = s
		for _, p in pairs(data.raw.technology[t].prerequisites or {}) do
			if data.raw.technology[p] then for x in pairs(before(p)) do s[x] = true end end
		end
	end
	return memo[t]
end
--- the technologies of a set that have no other of the set before them
local function first(set)
	local out = {}
	for t in pairs(set) do
		local later = false
		for u in pairs(set) do if u ~= t and before(t)[u] then later = true end end
		if not later then out[#out + 1] = t end
	end
	table.sort(out)
	return out
end
--- item -> the technologies that unlock a recipe taking it (not the vein recipes, not the start)
local takers = {}
for rname, r in pairs(data.raw.recipe) do
	if not r.hidden and not FORK_CLASSIC_VEINS.recipes[rname] and unlocked_by[rname] then
		for _, i in pairs(r.ingredients or {}) do
			takers[i.name] = takers[i.name] or {}
			for t in pairs(unlocked_by[rname]) do takers[i.name][t] = true end
		end
	end
end
--- the iron pickaxe's first technologies
local pickaxe = {}
for _, t in ipairs(first(unlocked_by["iron-pickaxe-usage"] or {})) do pickaxe[#pickaxe + 1] = t end
local function with_pickaxe(t)
	if #pickaxe == 0 then return t end
	for _, p in ipairs(pickaxe) do if before(t)[p] then return t end end
	for _, p in ipairs(pickaxe) do if before(p)[t] then return p end end
	error("166-fork-classic-veins: " .. t .. " has no iron pickaxe and comes not before its technology (issue #563): decide by hand")
end

local function unlock(name, techs)
	for _, t in ipairs(techs) do fork_add_unlock(t, name) end
end
--- (a kept recipe's own unlocks give way to the rule)
local function drop_unlocks(name)
	for _, t in pairs(data.raw.technology) do
		local keep = {}
		for _, e in pairs(t.effects or {}) do
			if not (e.type == "unlock-recipe" and e.recipe == name) then keep[#keep + 1] = e end
		end
		if t.effects and #keep < #t.effects then t.effects = keep end
	end
end
--- the twin with its machine's technology, or with the vein's when every one of them comes after that one
local function unlock_twin(twin, machine_tech, vein_techs)
	local after = true
	for _, t in ipairs(vein_techs) do if not before(t)[machine_tech] then after = false end end
	unlock(twin, after and vein_techs or { machine_tech })
end

for _, v in ipairs(FORK_CLASSIC_VEINS.veins) do
	if v.kept then
		for _, n in pairs({ v.recipe, v.twin, v.miner }) do drop_unlocks(n) end
	end
	do
		local set = {}
		if v.dimensions[1] == "OW" then
			for _, res in pairs(data.raw.recipe[v.recipe].results) do
				for t in pairs(takers[res.name] or {}) do set[t] = true end
			end
		else
			for _, d in ipairs(v.dimensions) do set[FORK_ORE_VEINS.techs[d]] = true end
		end
		local moved = {}
		for _, t in ipairs(first(set)) do moved[with_pickaxe(t)] = true end
		local techs = first(moved)
		if #techs == 0 then error("166-fork-classic-veins: no technology takes the ores of " .. v.recipe) end
		v.techs = techs
		unlock(v.recipe, techs)
		unlock_twin(v.twin, FORK_ELECTRIC_MINE.plant_tech, techs)
		unlock_twin(v.miner, FORK_ELECTRIC_MINE.miner_tech, techs)
		log("FORK-CLASSIC-VEINS: " .. v.recipe .. " with " .. table.concat(techs, ", "))
	end
end
fork_add_unlock("craft-stone-tools", STONE_PICKAXE)
--- the dimension mines with their first recipe (163, issue #556; 142 left them to this file in classic mode)
FORK_ELECTRIC_MINE.unlock_dimension_mines()
