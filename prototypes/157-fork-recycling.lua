--------------------------------------------------------------------------------
--- FORK RECYCLING (issue #190)
--- GT New Horizons has no disassembler (GTModHandler.RecipeBits.DISMANTLEABLE: "Disassembler was removed"): an item is
--- recycled into the MATERIALS it is made of, never into its parts. Every item with material data (ItemData) gets
--- recycling recipes (gregtech/api/util/GTRecipeRegistrator.java registerMaterialRecycling, 184-209):
---   macerator      the main material and its 3 largest byproducts as dusts, max(16, sum of amount x mass) ticks,
---                  4 EU/t (registerReverseMacerating, 459-498); a platinum group dust is two of the platinum line's
---                  powder or residue, as in the ore chain (issue #199)
---   arc furnace    the metals as ingots (a metal's arc smelting material: copper -> annealed copper), the non-metals
---                  dropped, up to 9 outputs, with oxygen as the gas: max(16, sum of amount x mass) ticks and as many
---                  litres of oxygen, LV (registerReverseArcSmelting, 311-408)
---   fluid extractor the main material as its melt (144 L per ingot), the first byproduct as ingots, max(1, 24 x amount)
---                  ticks (registerReverseFluidSmelting, 217-249)
--- Where the data comes from (GTModHandler.java 1098-1160): only a crafting table recipe with the REVERSIBLE bit gives an
--- item data, the sum of its ingredients' data (machines through addMachineCraftingRecipe, motors, casings ...);
--- assembler recipes give none, circuits have none (amount -1). The machine hull is set explicitly as its casing and
--- two cables (MTERecipeLoader.java 2549-2599). Gregtorio's counterpart (maintainer's decision on #190, "the GTNH rule"):
--- the items whose own recipe (the recipe named after the item) is a crafting table recipe (categories crafting,
--- crafting-or-assembling-recipes, crafting-table-recipes), their composition summed recursively through the recipes of
--- their ingredients down to the material parts (ingot, plate, rod ... in ingots: 143's melt per part, GT's for wires and
--- foils), circuits and things without materials counting nothing. Against loops: per material the least any recipe of
--- the item needs (an item with two recipes gives back only what both have), and the material parts themselves (ingots,
--- plates ...) are not recycled here (143 melts and casts them). GT's output is dusts plus small and tiny dusts; here whole
--- dusts and ingots, the rest is lost (decision on #190: never more than the item is worth). No Recycler: GTNH's turns
--- items into scrap, which has no use in Gregtorio (decision on #190).
--- The masses (FORK_RECYCLING_MASS) are GT's Materials.getMass (MaterialsInit.java: the element's protons and neutrons,
--- an alloy's from its composition and density); the GT++ and bartworks alloys (not in MaterialsInit) take GT's own
--- mass of a material without composition, technetium's 98. The mass only sets the time.
--- Recipes are named recycling-<machine>-<item> and listed in FORK_RECYCLING.recipes, which 199's auto-unlock ignores
--- like the casts. Unlocked with the first technology after the machine and the item (after_all as in 155), in
--- FORK_RECYCLING.unlock(), which data-final-fixes.lua calls after it set and disabled the vanilla technologies.
--- Loads after every file that makes recipes (after 156) and before 150, 196, 198 and 199.
--------------------------------------------------------------------------------

FORK_RECYCLING_MASS = {
	["aluminium"] = 26, ["americium"] = 245, ["annealed-copper"] = 63, ["battery-alloy"] = 189, ["bedrockium"] = 20,
	["beryllium"] = 9, ["black-plutonium"] = 98, ["black-steel"] = 64, ["blue-steel"] = 75, ["brass"] = 63,
	["bronze"] = 76, ["chromium"] = 52, ["chromnorox"] = 98, ["cobalt-brass"] = 68, ["conductive-iron"] = 69,
	["copper"] = 63, ["cosmic-neutronium"] = 98, ["cupronickel"] = 60, ["dark-steel"] = 27, ["diamond"] = 768,
	["dracofinium"] = 98, ["draconium"] = 98, ["electrical-steel"] = 36, ["electrum"] = 151, ["emerald"] = 18,
	["end-steel"] = 102, ["enderium"] = 129, ["energetic-alloy"] = 109, ["enriched-naquadah"] = 98, ["eternity"] = 98,
	["europium"] = 151, ["fluxed-electrum"] = 98, ["gallium"] = 70, ["gold"] = 196, ["hsse"] = 81, ["hssg"] = 98,
	["hsss"] = 129, ["hypocosmium"] = 98, ["infinity"] = 98, ["invar"] = 56, ["iridium"] = 192, ["iridium-alloy"] = 192,
	["iron"] = 56, ["kanthal"] = 44, ["lapis"] = 28, ["lead"] = 207, ["ledox"] = 98, ["magmatter"] = 98,
	["magnalium"] = 25, ["naquadah"] = 330, ["naquadah-alloy"] = 98, ["naquadria"] = 98, ["neodymium"] = 144,
	["nether-quartz"] = 98, ["neutronium"] = 100, ["nichrome"] = 56, ["nickel"] = 58, ["nickel-zinc-ferrite"] = 33,
	["niobium-titanium"] = 71, ["osmiridium"] = 191, ["osmium"] = 190, ["palladium"] = 106, ["platinum"] = 195,
	["pulsating-iron"] = 61, ["quantium"] = 98, ["red-alloy"] = 403, ["samarium"] = 150, ["signalum"] = 98,
	["silicon"] = 28, ["silver"] = 107, ["soularium"] = 102, ["spacetime"] = 98, ["stainless-steel"] = 55,
	["steel"] = 56, ["tantalum"] = 180, ["tin"] = 118, ["titanium"] = 48, ["transcendent-metal"] = 98, ["trinium"] = 98,
	["tritanium"] = 323, ["tungsten"] = 183, ["tungsten-carbide"] = 97, ["tungstensteel"] = 119, ["ultimet"] = 61,
	["universium"] = 98, ["vanadium-gallium"] = 55, ["vanadium-steel"] = 55, ["vibrant-alloy"] = 107,
	["yttrium-barium-cuprate"] = 51, ["zinc"] = 65,
}
local DEFAULT_MASS = 98   -- GT: a material without element and composition (technetium)

--- items never recycled, with the reason (devcheck fails for an entry without one or for an item that does not exist)
FORK_RECYCLING_BLACKLIST = {
	["blaze-rod"] = "GT: registerMaterialRecycling skips the blaze rod (GTRecipeRegistrator.java 185)",
	["obsidian"] = "GT: registerMaterialRecycling skips obsidian (GTRecipeRegistrator.java 188)",
}

FORK_RECYCLING = { recipes = {}, pending = {}, items = 0, by_kind = { macerator = 0, ["arc-furnace"] = 0, ["fluid-extractor"] = 0 } }

local P = "__gregtorio-continued__/graphics/icons/"
local CRAFTING = { ["crafting"] = true, ["crafting-or-assembling-recipes"] = true, ["crafting-table-recipes"] = true }

--- the material parts, in ingots (143's melt per part / 14.4; GT's amounts for the forms 143 does not cast)
local FORMS = {
	{ "hot-", "-ingot", 1 }, { "superdense-", "-plate", 64 }, { "dense-", "-plate", 9 }, { "long-", "-rod", 1 },
	{ "large-", "-gear", 4 }, { "fine-", "-wire", 1 / 8 }, { "block-of-", "", 9 }, { "", "-ingot", 1 },
	{ "", "-nugget", 1 / 9 }, { "", "-plate", 1 }, { "", "-foil", 1 / 4 }, { "", "-rod", 1 / 2 }, { "", "-round", 1 / 9 },
	{ "", "-bolt", 1 / 8 }, { "", "-screw", 1 / 8 }, { "", "-ring", 1 / 4 }, { "", "-gear", 1 }, { "", "-rotor", 4.25 },
	{ "", "-wire", 1 / 2 }, { "", "-cable", 1 / 2 }, { "", "-dust", 1 },
}
local SPECIAL = { ["iron-stick"] = { "iron", 1 / 2 }, ["iron-gear-wheel"] = { "iron", 1 } }
--- a metal's arc smelting material (GT Materials.mArcSmeltInto; Gregtorio has no wrought iron, iron stays iron)
local ARC_INTO = { ["copper"] = "annealed-copper" }

local function item_exists(n)
	return data.raw.item[n] ~= nil or data.raw.tool[n] ~= nil
end
--- a material: it has an ingot, or a dust and a plate (gems)
local function is_material(m)
	if m:find("^impure%-") or m:find("^pure%-") or m:find("^small%-pile%-of%-") or m:find("^tiny%-pile%-of%-") then
		return false
	end
	return item_exists(m .. "-ingot") or (item_exists(m .. "-dust") and item_exists(m .. "-plate"))
end
local function parse(name)
	if SPECIAL[name] then return SPECIAL[name][1], SPECIAL[name][2] end
	for _, f in pairs(FORMS) do
		local pre, suf = f[1], f[2]
		if name:sub(1, #pre) == pre and (suf == "" or name:sub(-#suf) == suf) and #name > #pre + #suf then
			local m = name:sub(#pre + 1, #name - #suf)
			if is_material(m) then return m, f[3] end
		end
	end
end
local CIRCUIT = { "circuit", "processor", "mainframe", "computer", "chip", "wafer", "smd", "transistor", "resistor",
	"capacitor", "diode", "inductor" }
local function is_circuit(name)
	for _, w in pairs(CIRCUIT) do
		if name:find(w, 1, true) then return true end
	end
	return false
end

--- the producers of every item (not the casts and melts of 143, not recycling)
local casting = FORK_CASTING and FORK_CASTING.recipes or {}
local producers = {}
for name, r in pairs(data.raw.recipe) do
	if not casting[name] and not name:find("recycling", 1, true) and not name:find("^void%-") and r.results then
		for _, res in pairs(r.results) do
			if res.type ~= "fluid" then
				producers[res.name] = producers[res.name] or {}
				table.insert(producers[res.name], r)
			end
		end
	end
end
local function amount(s)
	local a = s.amount or ((s.amount_min or 0) + (s.amount_max or 0)) / 2
	return a * (s.probability or 1)
end

--- the composition of an item in ingots per material: per material the least any of its recipes needs
local memo = {}
local function comp(name, stack)
	if memo[name] then return memo[name] end
	local m, a = parse(name)
	if m then
		memo[name] = { [m] = a }
		return memo[name]
	end
	if is_circuit(name) or stack[name] then return {} end
	stack[name] = true
	local result
	local hull_tier = name:match("^(%a+)%-machine%-hull$")
	for _, r in pairs(producers[name] or {}) do
		local out = 0
		for _, s in pairs(r.results) do
			if s.name == name then out = out + amount(s) end
		end
		if out > 0 then
			local c = {}
			for _, i in pairs(r.ingredients or {}) do
				--- GT sets the hull as its casing and two cables, its other parts do not count
				local counts = i.type ~= "fluid" and (not hull_tier or i.name:find("%-machine%-casing$") or i.name:find("%-cable$"))
				if counts then
					local n = hull_tier and (i.name:find("%-cable$") and 2 or 1) or i.amount
					for mm, aa in pairs(comp(i.name, stack)) do
						c[mm] = (c[mm] or 0) + aa * n / out
					end
				end
			end
			if result == nil then
				result = c
			else
				for mm, aa in pairs(result) do
					result[mm] = math.min(aa, c[mm] or 0)
				end
			end
		end
	end
	stack[name] = nil
	memo[name] = result or {}
	return memo[name]
end

--- the subgroups of the recipe rows, next to their machine's row
for _, k in pairs({ { "macerator", "lv-macerator-recipes" }, { "arc-furnace", "lv-arc-furnace-recipes" },
	{ "fluid-extractor", "lv-fluid-extractor-recipes" } }) do
	local base = data.raw["item-subgroup"]["subgroup-" .. k[2]]
	data:extend({ { type = "item-subgroup", name = "fork-recycling-" .. k[1], group = base and base.group or "processing-machine-recipes",
		order = (base and base.order or "z") .. "-recycling" } })
end

--- the recipe shows the item it recycles
local function icons_of(item)
	local it = data.raw.item[item] or data.raw.tool[item]
	if it.icons then return table.deepcopy(it.icons) end
	return { { icon = it.icon, icon_size = it.icon_size or 64 } }
end

local function recipe(kind, category, item, time, ingredients, results)
	local name = "recycling-" .. kind .. "-" .. item
	data:extend({ {
		type = "recipe", name = name, category = category, enabled = false, energy_required = time,
		ingredients = ingredients, results = results, subgroup = "fork-recycling-" .. kind,
		icons = icons_of(item),
		localised_name = { "recipe-name.fork-recycling-" .. kind, { "item-name." .. item } },
		hide_from_player_crafting = true, allow_productivity = false, auto_recycle = false,
	} })
	FORK_RECYCLING.recipes[name] = true
	FORK_RECYCLING.by_kind[kind] = FORK_RECYCLING.by_kind[kind] + 1
	table.insert(FORK_RECYCLING.pending, { name, category, item })
end

local function mass(m) return FORK_RECYCLING_MASS[m] or DEFAULT_MASS end
--- issue #199: a dust of the platinum group is two of the platinum line's powder or residue (bartworks'
--- PlatinumSludgeOutputs.convert: Platinum, Palladium, Iridium, Osmium -> PT/PD metallic powder, Ir and Ir/Os leach residue)
local PGM_DUST = { ["platinum"] = "metallic-platinum-powder", ["palladium"] = "metallic-palladium-powder",
	["iridium"] = "iridium-metal-residue", ["osmium"] = "rarest-metal-mixture" }
--- a fluid amount on the engine's grid of 2^-24, rounded down (197's rule)
local function grid(x) return math.floor(x * 16777216) / 16777216 end

--- the items: own recipe a crafting table recipe, not a material part, not a circuit, not blacklisted
local names = {}
for name, r in pairs(data.raw.recipe) do
	--- the machine hulls too: GT sets their data explicitly (an assembler recipe here)
	if (CRAFTING[r.category] or name:match("^%a+%-machine%-hull$")) and not r.hidden and item_exists(name)
		and not parse(name) and not is_circuit(name)
		and not FORK_RECYCLING_BLACKLIST[name] then
		for _, s in pairs(r.results or {}) do
			if s.name == name then names[#names + 1] = name break end
		end
	end
end
table.sort(names)

for _, item in pairs(names) do
	local c = comp(item, {})
	local list = {}
	for m, a in pairs(c) do
		if a >= 1 then list[#list + 1] = { m, a } end
	end
	table.sort(list, function(x, y) return x[2] > y[2] or (x[2] == y[2] and x[1] < y[1]) end)
	if #list > 0 then
		FORK_RECYCLING.items = FORK_RECYCLING.items + 1
		local input = { { type = "item", name = item, amount = 1 } }
		--- macerator: the main material and 3 byproducts as dusts
		local res, ticks = {}, 0
		for i = 1, math.min(4, #list) do
			local m, a = list[i][1], math.floor(list[i][2])
			if PGM_DUST[m] and item_exists(PGM_DUST[m]) then
				res[#res + 1] = { type = "item", name = PGM_DUST[m], amount = 2 * a }
				ticks = ticks + a * mass(m)
			elseif item_exists(m .. "-dust") then
				res[#res + 1] = { type = "item", name = m .. "-dust", amount = a }
				ticks = ticks + a * mass(m)
			end
		end
		if #res > 0 then
			recipe("macerator", "lv-macerator-recipes", item, math.max(16, ticks) / 20 * LV_SPEED, input, res)
		end
		--- arc furnace: the metals as ingots (their arc smelting material), up to 9, oxygen as the gas
		res, ticks = {}, 0
		for i = 1, #list do
			local m, a = list[i][1], math.floor(list[i][2])
			local into = ARC_INTO[m] or m
			if #res < 9 and item_exists(into .. "-ingot") then
				res[#res + 1] = { type = "item", name = into .. "-ingot", amount = a }
				ticks = ticks + a * mass(m)
			end
		end
		if #res > 0 then
			local t = math.max(16, ticks)
			recipe("arc-furnace", "lv-arc-furnace-recipes", item, t / 20 * LV_SPEED,
				{ input[1], { type = "fluid", name = "oxygen", amount = grid(t / 10) } }, res)
		end
		--- fluid extractor: the main material's melt and the first byproduct's ingots
		local main = list[1][1]
		if data.raw.fluid["molten-" .. main] then
			res = { { type = "fluid", name = "molten-" .. main, amount = grid(list[1][2] * 14.4) } }
			if list[2] and item_exists(list[2][1] .. "-ingot") and math.floor(list[2][2]) >= 1 then
				res[2] = { type = "item", name = list[2][1] .. "-ingot", amount = math.floor(list[2][2]) }
			end
			recipe("fluid-extractor", "lv-fluid-extractor-recipes", item, math.max(1, 24 * list[1][2]) / 20 * LV_SPEED, input, res)
		end
	end
end
log("FORK-RECYCLING: " .. FORK_RECYCLING.items .. " items, " .. FORK_RECYCLING.by_kind.macerator .. " macerator, "
	.. FORK_RECYCLING.by_kind["arc-furnace"] .. " arc furnace, " .. FORK_RECYCLING.by_kind["fluid-extractor"]
	.. " fluid extractor recycling recipes")

--- the unlocks, called from data-final-fixes.lua after it set and disabled the vanilla technologies (it replaces the
--- effects of some of them, fluid-handling and the rail technologies, and disables others): the first researchable
--- technology after the machine and the item (the helpers of 155); a recipe no researchable technology can give is removed
function FORK_RECYCLING.unlock()
	local techs_of_recipe = {}
	for tname, tech in pairs(data.raw.technology) do
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and tech.enabled ~= false and not tech.hidden then
				techs_of_recipe[e.recipe] = techs_of_recipe[e.recipe] or {}
				table.insert(techs_of_recipe[e.recipe], tname)
			end
		end
	end
	local function item_techs(name)
		local out = {}
		for _, r in pairs(producers[name] or {}) do
			if r.enabled ~= false and not r.hidden then return nil end
			for _, t in pairs(techs_of_recipe[r.name] or {}) do out[#out + 1] = t end
		end
		return out
	end
	local machine_techs_cache = {}
	local function machine_techs(category)
		if machine_techs_cache[category] ~= nil then return machine_techs_cache[category] or nil end
		local out = {}
		for _, kind in pairs({ "assembling-machine", "furnace" }) do
			for ename, e in pairs(data.raw[kind] or {}) do
				for _, c in pairs(e.crafting_categories or {}) do
					if c == category then
						for iname, it in pairs(data.raw.item) do
							if it.place_result == ename then
								local t = item_techs(iname)
								if t == nil then
									machine_techs_cache[category] = false
									return nil
								end
								for _, x in pairs(t) do out[#out + 1] = x end
							end
						end
					end
				end
			end
		end
		machine_techs_cache[category] = out
		return out
	end
	local ancestors_cache = {}
	local function ancestors(tech)
		if ancestors_cache[tech] then return ancestors_cache[tech] end
		local seen = {}
		local function walk(n)
			local t = data.raw.technology[n]
			for _, pre in pairs(t and t.prerequisites or {}) do
				if not seen[pre] then
					seen[pre] = true
					walk(pre)
				end
			end
		end
		walk(tech)
		ancestors_cache[tech] = seen
		return seen
	end
	local function size(set)
		local n = 0
		for _ in pairs(set) do n = n + 1 end
		return n
	end
	local function covers(c, groups)
		local a = ancestors(c)
		for _, g in pairs(groups) do
			local hit = false
			for _, t in pairs(g) do
				if t == c or a[t] then hit = true break end
			end
			if not hit then return false end
		end
		return true
	end
	local after_cache = {}
	local function after_all(groups)
		local key = {}
		for _, g in pairs(groups) do
			local s = {}
			for _, t in pairs(g) do s[#s + 1] = t end
			table.sort(s)
			key[#key + 1] = table.concat(s, ",")
		end
		table.sort(key)
		key = table.concat(key, "|")
		if after_cache[key] ~= nil then return after_cache[key] or nil end
		local found, found_n
		for _, g in pairs(groups) do
			for _, c in pairs(g) do
				if covers(c, groups) and (not found or size(ancestors(c)) < found_n or (size(ancestors(c)) == found_n and c < found)) then
					found, found_n = c, size(ancestors(c))
				end
			end
		end
		if not found then
			for name, tech in pairs(data.raw.technology) do
				if not tech.hidden and tech.enabled ~= false and covers(name, groups) then
					local n = size(ancestors(name))
					if not found or n < found_n or (n == found_n and name < found) then found, found_n = name, n end
				end
			end
		end
		after_cache[key] = found or false
		return found
	end
	local function unlock_after(name, groups)
		local g = {}
		for _, x in pairs(groups) do
			if x ~= nil and x ~= false then
				if #x == 0 then return false end
				g[#g + 1] = x
			end
		end
		if #g == 0 then
			data.raw.recipe[name].enabled = true
			return true
		end
		local tech = after_all(g)
		if tech then fork_add_unlock(tech, name) end
		return tech ~= nil
	end
	local removed = 0
	for _, p in pairs(FORK_RECYCLING.pending) do
		if not unlock_after(p[1], { machine_techs(p[2]), item_techs(p[3]) }) then
			data.raw.recipe[p[1]] = nil
			FORK_RECYCLING.recipes[p[1]] = nil
			removed = removed + 1
		end
	end
	log("FORK-RECYCLING: " .. removed .. " recycling recipes removed (their item or machine has no researchable technology)")
end
