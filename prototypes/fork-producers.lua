--------------------------------------------------------------------------------
--- Load time: indexes of the recipes by the names of their results and of the technologies by the recipes they
--- unlock, for the helpers that look for "every recipe that makes an item now" and "the technologies that unlock it"
--- (155, 158's and 164's item_techs, 169 to 174). Each of them went through every recipe of the game (40 000) and every
--- technology's effects for every ingredient it looked at, which made the data stage take minutes.
---
--- FORK_PRODUCERS.recipes(name): the names of the recipes with a result called `name`, in the order
--- pairs(data.raw.recipe) visits them (Factorio's pairs visits the keys in insertion order; a key that is removed and
--- set again comes last). The caller checks each recipe's results itself, as before; a recipe that is gone is left out.
--- FORK_PRODUCERS.unlocked_by(recipe): the technologies that unlock a recipe, in the order of pairs(data.raw.technology),
--- a technology once per effect that unlocks it.
---
--- The answers are those of a full scan at the time of the call. Outside a scope (FORK_PRODUCERS.begin() ...
--- FORK_PRODUCERS.finish()) every call scans again, as the old helpers did. Inside one, the first call scans and later
--- calls only follow the changes a loop of unlocks makes: new and removed recipes and technologies (next() from the last
--- key) and technologies whose effects table or its length changed (fork_add_unlock inserts, the moves assign a new
--- table). A loop in a scope must not edit the results of an existing recipe or an effect in place (a new recipe, a new
--- effect and fork_add_unlock are fine). FORK_PRODUCERS_VERIFY = true (a global set before this file, e.g. by a helper
--- mod of devcheck) compares every call with a full scan and fails on a difference.
--------------------------------------------------------------------------------

FORK_PRODUCERS = { verify = FORK_PRODUCERS_VERIFY == true, lookups = 0, scans = 0 }

local EMPTY = {}
local depth = 0                     -- the scope depth
local fresh_r, fresh_t = false, false   -- whether the recipe and technology index were built in this scope

--- recipes: position -> name (false: the key moved on), name -> position, name -> the indexed prototype, result name ->
--- ascending positions, the last indexed key
local seq, pos, obj, by, last
--- technologies: the same, with the effects table and its length as read, the recipes a technology unlocks and recipe ->
--- { position = number of effects }
local tseq, tpos, tobj, teff, tlen, trec, byrec, tlast

local function add(name, r)
	if pos[name] then seq[pos[name]] = false end
	local p = #seq + 1
	seq[p], pos[name], obj[name] = name, p, r
	for _, res in pairs(r.results or EMPTY) do
		local n = res.name
		if n ~= nil then
			local l = by[n]
			if not l then
				l = {}
				by[n] = l
			end
			if l[#l] ~= p then l[#l + 1] = p end
		end
	end
end

local function tech_drop(tname)
	local p = tpos[tname]
	for _, rname in pairs(trec[tname] or EMPTY) do
		local m = byrec[rname]
		m[p] = m[p] - 1
		if m[p] == 0 then m[p] = nil end
	end
	trec[tname] = nil
end
local function tech_read(tname, t)
	local p, list, effects = tpos[tname], {}, t.effects or EMPTY
	for _, e in pairs(effects) do
		if e.type == "unlock-recipe" then
			local m = byrec[e.recipe]
			if not m then
				m = {}
				byrec[e.recipe] = m
			end
			m[p] = (m[p] or 0) + 1
			list[#list + 1] = e.recipe
		end
	end
	trec[tname], teff[tname], tlen[tname] = list, effects, #effects
end
local function tech_add(tname, t)
	if tpos[tname] then
		tech_drop(tname)
		tseq[tpos[tname]] = false
	end
	local p = #tseq + 1
	tseq[p], tpos[tname], tobj[tname] = tname, p, t
	tech_read(tname, t)
end

--- recipes that data:extend set while a scope is open: one that replaced a recipe of the same name keeps that position,
--- so next() does not see it (the wrapper below notes the names)
local touched = {}
local extend = data.extend
data.extend = function(self, list, ...)
	if depth > 0 and type(list) == "table" then
		for _, p in pairs(list) do
			if type(p) == "table" and p.type == "recipe" and p.name ~= nil then touched[#touched + 1] = p.name end
		end
	end
	return extend(self, list, ...)
end
--- (a position into an ascending list)
local function insert_sorted(l, p)
	local i = #l
	while i > 0 and l[i] > p do i = i - 1 end
	if l[i] ~= p then table.insert(l, i + 1, p) end
end

--- full scans
local function rebuild_recipes()
	FORK_PRODUCERS.scans = FORK_PRODUCERS.scans + 1
	seq, pos, obj, by, last, touched = {}, {}, {}, {}, nil, {}
	for name, r in pairs(data.raw.recipe) do
		add(name, r)
		last = name
	end
end
local function rebuild_techs()
	FORK_PRODUCERS.scans = FORK_PRODUCERS.scans + 1
	tseq, tpos, tobj, teff, tlen, trec, byrec, tlast = {}, {}, {}, {}, {}, {}, {}, nil
	for tname, t in pairs(data.raw.technology) do
		tech_add(tname, t)
		tlast = tname
	end
end

--- the changes since the last call, inside a scope
local function sync_recipes()
	local recipes = data.raw.recipe
	if last ~= nil and recipes[last] ~= obj[last] then
		--- the last key was removed or replaced (a route of 158 that found no technology): go on from the latest key
		--- before it that is still there; what comes after it in pairs order is indexed again, in that order
		local p = pos[last]
		while p > 0 and not (seq[p] and recipes[seq[p]] == obj[seq[p]]) do p = p - 1 end
		if p == 0 then return rebuild_recipes() end
		last = seq[p]
	end
	local k, r = next(recipes, last)
	while k ~= nil do
		add(k, r)
		last = k
		k, r = next(recipes, k)
	end
	--- (a recipe that replaced one of the same name: its results at the old position)
	for _, name in ipairs(touched) do
		local rr, p = recipes[name], pos[name]
		if rr and p and obj[name] ~= rr then
			obj[name] = rr
			for _, res in pairs(rr.results or EMPTY) do
				if res.name ~= nil then
					by[res.name] = by[res.name] or {}
					insert_sorted(by[res.name], p)
				end
			end
		end
	end
	touched = {}
end
local function sync_techs()
	local techs = data.raw.technology
	if tlast ~= nil and techs[tlast] ~= tobj[tlast] then
		local p = tpos[tlast]
		while p > 0 and not (tseq[p] and techs[tseq[p]] == tobj[tseq[p]]) do p = p - 1 end
		if p == 0 then return rebuild_techs() end
		tlast = tseq[p]
	end
	local tk, t = next(techs, tlast)
	while tk ~= nil do
		tech_add(tk, t)
		tlast = tk
		tk, t = next(techs, tk)
	end
	--- (the technologies before: a removed one drops out, one replaced in place keeps its position, changed effects
	--- are read again)
	for p = 1, #tseq do
		local tname = tseq[p]
		if tname then
			local tt = techs[tname]
			if tt ~= tobj[tname] then
				tech_drop(tname)
				if tt then
					tobj[tname] = tt
					tech_read(tname, tt)
				else
					tseq[p] = false
				end
			else
				local effects = tt.effects or EMPTY
				if effects ~= teff[tname] or #effects ~= tlen[tname] then
					tech_drop(tname)
					tech_read(tname, tt)
				end
			end
		end
	end
end

--- a scope of many lookups (nested scopes are one)
function FORK_PRODUCERS.begin()
	if depth == 0 then fresh_r, fresh_t = false, false end
	depth = depth + 1
end
function FORK_PRODUCERS.finish()
	depth = depth - 1
	if depth < 0 then error("FORK-PRODUCERS: finish() without begin()") end
	if depth == 0 then fresh_r, fresh_t = false, false end
end

local function makes(r, name)
	for _, res in pairs(r.results or EMPTY) do
		if res.name == name then return true end
	end
	return false
end

--- the recipes that make `name` (see above), in pairs order
function FORK_PRODUCERS.recipes(name)
	FORK_PRODUCERS.lookups = FORK_PRODUCERS.lookups + 1
	if depth == 0 or not fresh_r then
		rebuild_recipes()
		fresh_r = depth > 0
	else
		sync_recipes()
	end
	local out, recipes = {}, data.raw.recipe
	for _, p in ipairs(by[name] or EMPTY) do
		local k = seq[p]
		if k and recipes[k] then out[#out + 1] = k end
	end
	if FORK_PRODUCERS.verify then
		local full, got = {}, {}
		for rname, r in pairs(recipes) do
			if makes(r, name) then full[#full + 1] = rname end
		end
		for _, rname in ipairs(out) do
			if makes(recipes[rname], name) then got[#got + 1] = rname end
		end
		if table.concat(full, ",") ~= table.concat(got, ",") then
			error("FORK-PRODUCERS: the recipes of " .. name .. " differ from a full scan: " .. serpent.line(got) .. " vs "
				.. serpent.line(full))
		end
	end
	return out
end

--- the technologies that unlock `recipe` (see above), in pairs order, once per effect
function FORK_PRODUCERS.unlocked_by(recipe)
	FORK_PRODUCERS.lookups = FORK_PRODUCERS.lookups + 1
	if depth == 0 or not fresh_t then
		rebuild_techs()
		fresh_t = depth > 0
	else
		sync_techs()
	end
	local m, ps = byrec[recipe] or EMPTY, {}
	for p in pairs(m) do ps[#ps + 1] = p end
	table.sort(ps)
	local out = {}
	for _, p in ipairs(ps) do
		for _ = 1, m[p] do out[#out + 1] = tseq[p] end
	end
	if FORK_PRODUCERS.verify then
		local full = {}
		for tname, t in pairs(data.raw.technology) do
			for _, e in pairs(t.effects or EMPTY) do
				if e.type == "unlock-recipe" and e.recipe == recipe then full[#full + 1] = tname end
			end
		end
		if table.concat(full, ",") ~= table.concat(out, ",") then
			error("FORK-PRODUCERS: the technologies of " .. recipe .. " differ from a full scan: " .. serpent.line(out)
				.. " vs " .. serpent.line(full))
		end
	end
	return out
end

function FORK_PRODUCERS.log(when)
	log("FORK-PRODUCERS (" .. when .. "): " .. FORK_PRODUCERS.lookups .. " lookups, " .. FORK_PRODUCERS.scans
		.. " full scans" .. (FORK_PRODUCERS.verify and ", every lookup verified" or ""))
	if depth ~= 0 then error("FORK-PRODUCERS: a scope is still open (" .. depth .. ")") end
end
