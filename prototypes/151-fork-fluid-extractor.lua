--------------------------------------------------------------------------------
--- FORK FLUID EXTRACTOR (issue #152)
--- GT New Horizons has two machines where upstream had one: the Extractor (items into items) and the Fluid Extractor
--- (items into a fluid). Upstream's Extractor ran both, and almost all of its recipes were melts. Here:
---   * <tier>-fluid-extractor, LV to MAX, a copy of the Extractor of its tier: same size, ports, speed and power, the
---     categories <tier>-fluid-extractor-recipes of its tier and below, the Extractor's recipe (GTNH builds both from
---     the same parts: hull, pump, piston, 2 glass, 2 circuits, 2 cables, MTERecipeLoader registerExtractor and
---     registerFluidExtractor), unlocked by the technology that unlocks the Extractor of its tier; the same fast replace
---     group as the Extractor, so a Fluid Extractor can be placed over an Extractor;
---   * every recipe of an extractor category with a fluid result moves to the fluid extractor category of its tier
---     (143's melts and the upstream fluid recipes); the Extractor and the Steam Extractor keep the item recipes;
---   * the Large Fluid Extractor (iv-large-extractor) runs the fluid extractor categories LV to IV, as GTNH's does.
--- Sprites: tools/gen_sprites.py (FRONT_OVERLAY, fluid_extractor_lv_ev). Old saves: an Extractor whose recipe moved
--- loads without a recipe (the game drops a recipe its machine cannot run before any script runs); see the changelog.
--- Loads after every file that makes extractor recipes or extractors (143, 144, 146, 147, 148, 141) and before 150,
--- 196, 197, 198 and 199.
--------------------------------------------------------------------------------

local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
local TIER_INDEX = {}
for i, t in ipairs(TIERS) do TIER_INDEX[t] = i end

--- the categories, one per tier the Extractor has, each with its crafting menu row right after the Extractor's
for _, t in ipairs(TIERS) do
	local old = t .. "-extractor-recipes"
	if data.raw["recipe-category"][old] then
		local name = t .. "-fluid-extractor-recipes"
		local sg = data.raw["item-subgroup"]["subgroup-" .. old]
		data:extend({
			{ type = "recipe-category", name = name },
			{ type = "item-subgroup", name = "subgroup-" .. name, group = sg and sg.group or "processing-machine-recipes",
				order = (sg and sg.order or "") .. "-fluid" },
		})
	end
end

--- the recipes with a fluid result
FORK_FLUID_EXTRACTOR = { moved = {} }
for name, r in pairs(data.raw.recipe) do
	local t = r.category and r.category:match("^(%a+)%-extractor%-recipes$")
	if t and TIER_INDEX[t] then
		local fluid = false
		for _, res in pairs(r.results or {}) do
			if res.type == "fluid" then fluid = true end
		end
		if fluid then
			r.category = t .. "-fluid-extractor-recipes"
			if r.subgroup == "subgroup-" .. t .. "-extractor-recipes" then r.subgroup = "subgroup-" .. r.category end
			FORK_FLUID_EXTRACTOR.moved[name] = true
		end
	end
end

local function fluid_categories(max_tier)
	local out = {}
	for i = 1, TIER_INDEX[max_tier] do
		local c = TIERS[i] .. "-fluid-extractor-recipes"
		if data.raw["recipe-category"][c] then out[#out + 1] = c end
	end
	return out
end

local function rename(s)
	return (s:gsub("extractor", "fluid-extractor"))
end

--- every filename of a graphics set: the Extractor's sprite -> the Fluid Extractor's
local function fluid_files(t)
	if type(t) ~= "table" then return end
	if type(t.filename) == "string" then t.filename = rename(t.filename) end
	for _, v in pairs(t) do fluid_files(v) end
end

--- the technologies that unlock a recipe
local function unlocked_by(recipe)
	local out = {}
	for name, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and e.recipe == recipe then out[#out + 1] = name end
		end
	end
	table.sort(out)
	return out
end

for _, t in ipairs(TIERS) do
	local src = t .. "-extractor"
	local new = t .. "-fluid-extractor"
	local e = data.raw["assembling-machine"][src]
	local item, recipe = data.raw.item[src], data.raw.recipe[src]
	if e and item and recipe then
		local m = table.deepcopy(e)
		m.name = new
		m.minable = { mining_time = e.minable and e.minable.mining_time or 0.5, result = new }
		m.crafting_categories = fluid_categories(t)
		m.icon = rename(e.icon)
		m.placeable_by = nil
		m.next_upgrade = nil
		fluid_files(m.graphics_set)

		local i = table.deepcopy(item)
		i.name = new
		i.icon = rename(item.icon)
		i.place_result = new
		i.order = (item.order or "") .. "-fluid"

		local r = table.deepcopy(recipe)
		r.name = new
		r.enabled = false
		for _, res in pairs(r.results or {}) do
			if res.name == src then res.name = new end
		end
		if r.main_product then r.main_product = new end
		r.icon = r.icon and rename(r.icon) or nil
		data:extend({ m, i, r })

		local techs = unlocked_by(src)
		for _, tech in pairs(techs) do fork_add_unlock(tech, new) end
		if #techs == 0 then log("FORK-FLUID-EXTRACTOR: no technology unlocks " .. src) end
	else
		log("FORK-FLUID-EXTRACTOR: no extractor of tier " .. t)
	end
end

--- the upgrade planner: a Fluid Extractor upgrades to the next tier's Fluid Extractor, as the Extractor does
for _, t in ipairs(TIERS) do
	local e = data.raw["assembling-machine"][t .. "-extractor"]
	local f = data.raw["assembling-machine"][t .. "-fluid-extractor"]
	if e and f and e.next_upgrade and data.raw["assembling-machine"][rename(e.next_upgrade)] then
		f.next_upgrade = rename(e.next_upgrade)
	end
end

--- The Steam Extractor ran the LV fluid recipes before, so a technology could unlock a melt without leading to an
--- electric extractor. Such a technology gets the LV Fluid Extractor's technology as a prerequisite (concrete, galena,
--- invar and gas-turbine: their melts and wood tar; the parts of the machine, the LV pump, come with that technology).
do
	local machine_techs = unlocked_by("lv-fluid-extractor")
	local function closure(name, seen)
		seen = seen or {}
		if seen[name] then return seen end
		seen[name] = true
		local tech = data.raw.technology[name]
		for _, p in pairs(tech and tech.prerequisites or {}) do closure(p, seen) end
		return seen
	end
	local recipe_of, techs = {}, {}
	for name, _ in pairs(FORK_FLUID_EXTRACTOR.moved) do
		if data.raw.recipe[name].category == "lv-fluid-extractor-recipes" then
			for _, tname in pairs(unlocked_by(name)) do
				if not recipe_of[tname] then techs[#techs + 1] = tname end
				if not recipe_of[tname] or name < recipe_of[tname] then recipe_of[tname] = name end
			end
		end
	end
	--- ancestors first (fewer prerequisites), so a technology whose ancestor gets the prerequisite needs none
	local size = {}
	for _, tname in pairs(techs) do
		local n = 0
		for _ in pairs(closure(tname)) do n = n + 1 end
		size[tname] = n
	end
	table.sort(techs, function(a, b) if size[a] ~= size[b] then return size[a] < size[b] end return a < b end)
	local m = machine_techs[1]
	for _, tname in ipairs(techs) do
		local cl, reaches = closure(tname), false
		for _, mt in pairs(machine_techs) do if cl[mt] then reaches = true end end
		if not reaches and m and not closure(m)[tname] then
			local tech = data.raw.technology[tname]
			tech.prerequisites = tech.prerequisites or {}
			table.insert(tech.prerequisites, m)
			log("FORK-FLUID-EXTRACTOR: " .. tname .. " gets the prerequisite " .. m .. " (" .. recipe_of[tname] .. ")")
		end
	end
end

--- GTNH's Large Fluid Extractor runs only the fluid extractor recipes
local large = data.raw["assembling-machine"]["iv-large-extractor"]
if large then large.crafting_categories = fluid_categories("iv") end
