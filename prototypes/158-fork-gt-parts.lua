--------------------------------------------------------------------------------
--- FORK GT PARTS (issues #222, #223 B5 and #227)
--- Issue #227 (the maintainer's decision after #222): every metal gets the parts GT New Horizons generates for its
--- material, not only those a recipe uses. The forms per material come from tools/gen_gt_parts.py
--- (prototypes/gt-parts-data.lua: GT's MaterialsInit.java and OrePrefixes conditions, the frame boxes of
--- LoaderMetaPipeEntities.java, the storage blocks of LoaderGTBlockFluid.java; GT++'s MaterialGenerator.java for its
--- alloys). This file makes the forms Gregtorio lacks, each with the main machine recipe of its source, in Gregtorio's
--- units (time = GT ticks / 20 x the speed of the machine tier; a tenth of GT's litres), plus 143's casts:
--- GT (OP/Processing*.java, GTRecipeRegistrator.java; EU/t through calculateRecipeEU: the material's processing
--- voltage where GT sets one, else the recipe's own; extruder x15, or x60 from 2800 K blast furnace temperature):
---   plate         bender, 1 ingot, mass ticks, 24          double/triple/quadruple/quintuple plate  bender, 2-5 ingots,
---   dense plate   bender, 9 ingots, 9 x mass, 96             n x mass, 96
---   superdense    compressor, 64 plates, 32 x mass, 96       foil          bender, 1 ingot -> 4, 2 x mass, 24
---   rod           lathe, 1 ingot -> rod + 2 small piles, 5 x mass, 16
---   long rod      forge hammer, 2 rods, mass, 16             bolt          cutter, rod + water -> 4, 4 x mass, 4
---   screw         lathe, bolt, mass / 8, 4                   round         lathe, nugget, mass / 4, 8
---   ring          extruder, 1 ingot -> 4, 2 x mass, 6 x 15   fine wire     wiremill, 1 ingot -> 4, 100 ticks, 4
---   small spring  bender, rod -> 2, 5 s, 8                   spring        bender, long rod, 10 s, 16
---   item casing   alloy smelter, 2 ingots + mold -> 3, 6.4 s, 15   frame  assembler, 4 rods, 3.2 s, 7
---   block         compressor, 9 ingots, 15 s, 2              gear          extruder, 1 ingot, mass, 8 x 15
---   large gear    extruder, 4 ingots, 5 x mass, 8 x 15       rotor         assembler, 4 plates + ring + 1.6 soldering
---                                                                          alloy, mass, 24
--- GT++ (xmod/gregtech/loaders/RecipeGen*.java; V: the voltage of the alloy's melting point, MaterialUtils):
---   plate bender 1 ingot, mass; double plate bender 2 ingots, 2 x mass, at least MV; dense plate bender 9 ingots,
---   2 x mass, at least MV; rod lathe 1 ingot -> rod + 2 small piles, mass / 8; long rod forge hammer 2 rods, mass, LV;
---   bolt cutter rod -> 4, 2 x mass; screw lathe bolt, mass / 8, LV; ring extruder 1 ingot -> 4, 2 x mass; large gear
---   extruder 4 ingots, 5 x mass; rotor extruder 5 ingots, 5 x mass; block compressor 9 ingots, 15 s; frame assembler
---   4 rods, 3 s; nugget alloy smelter ingot + mold -> 9, 2 x mass.
--- Not made: GT's tool heads and turbine blades (the TOOL bit: GT's tools and per-material turbine rotors, which
--- Gregtorio does not have) and GT's cells. Machines above UXV take the UXV category; the forge hammer has the LV one.
--- Issue #223, B5: GT's nugget recipes (ProcessingNugget.java) for every metal with a nugget: ingot -> 9 nuggets in the
--- alloy smelter with the mold (5 s), 9 nuggets -> ingot where missing (10 s), nugget -> a tiny pile of the dust in the
--- macerator (registerReverseMacerating: mass / 9 ticks, at least 16); 9 tiny and 4 small piles make the dust at the
--- crafting table (GT's packager is not in Gregtorio). GT's crafting recipe with the saw is not made (no GT tools).
--- Unlocks: unlock_after of 155 (the first technology after the machine and the inputs). Loads after 155 and before
--- 150, 196, 197, 198, 199 and 200.
--------------------------------------------------------------------------------

local OC = FORK_ORE_CHAIN
local DATA = require("prototypes.gt-parts-data")
local P = "__gregtorio-continued__/graphics/icons/"

local TIERS = { "lv", "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
local TIER_INDEX = {}
for i, t in pairs(TIERS) do TIER_INDEX[t] = i end
local SPEED = { lv = LV_SPEED, mv = MV_SPEED, hv = HV_SPEED, ev = EV_SPEED, iv = IV_SPEED, luv = LUV_SPEED,
	zpm = ZPM_SPEED, uv = UV_SPEED, uhv = UHV_SPEED, uev = UEV_SPEED, uiv = UIV_SPEED, umv = UMV_SPEED,
	uxv = UXV_SPEED, max = MAX_SPEED }
--- GT's voltage of each tier (V[LV] = 32 ...): a recipe of up to V runs in that tier
local VOLT = { 32, 128, 512, 2048, 8192, 32768, 131072, 524288, 2097152, 8388608, 33554432, 134217728, 536870912 }
local function tier_of(eu)
	for i, v in pairs(VOLT) do
		if eu <= v then return TIERS[i] end
	end
	return "max"
end
--- the highest tier of a machine's categories in Gregtorio (the others: UXV)
local TOP = { ["forge-hammer"] = "lv" }

local function item(name, amount, probability)
	return { type = "item", name = name, amount = amount or 1, probability = probability }
end
local function fluid(name, amount)
	return { type = "fluid", name = name, amount = amount }
end
local function add_item(name, sub, order)
	if data.raw.item[name] then return false end
	data:extend({ { type = "item", name = name, icon = P .. name .. ".png", icon_size = 32, subgroup = sub, order = order,
		stack_size = 64 } })
	return true
end
local function sub_of(name, default)
	local it = data.raw.item[name]
	return it and it.subgroup or default
end

--- the technologies that give an item: 155's (item_techs), else every recipe that makes it now (an item 155 does not
--- know, as an ingot cast in a later file); nil: there from the start
local techs_made = {}   -- recipes of this file -> their technology (155 knows them as well)
local tech_effects
local function item_techs(name)
	local t = OC.item_techs(name)
	if t == nil or #t > 0 then return t end
	if not tech_effects then
		tech_effects = {}
		for tn, tech in pairs(data.raw.technology) do
			for _, e in pairs(tech.effects or {}) do
				if e.type == "unlock-recipe" then
					tech_effects[e.recipe] = tech_effects[e.recipe] or {}
					table.insert(tech_effects[e.recipe], tn)
				end
			end
		end
	end
	local out = {}
	for rname, r in pairs(data.raw.recipe) do
		if not r.hidden and not rname:match("recycling") then
			for _, res in pairs(r.results or {}) do
				if res.name == name then
					if r.enabled ~= false then return nil end
					for _, tn in pairs(tech_effects[rname] or techs_made[rname] or {}) do out[#out + 1] = tn end
				end
			end
		end
	end
	return out
end
local ancestor_memo = {}
local function ancestors(t)
	if ancestor_memo[t] then return ancestor_memo[t] end
	local seen, list = {}, {}
	local function walk(n)
		local tech = data.raw.technology[n]
		for _, pre in pairs(tech and tech.prerequisites or {}) do
			if not seen[pre] then
				seen[pre] = true
				list[#list + 1] = pre
				walk(pre)
			end
		end
	end
	walk(t)
	ancestor_memo[t] = list
	return list
end

local made = 0
--- (recipes: every recipe of this file; 199's auto-unlock does not count them as producers, like 143's casts: a form
--- of a material made from another form of it would stand in for the recipe that really makes it)
FORK_GT_PARTS = { recipes = {} }
--- a recipe of a machine at a tier (GT ticks or seconds); unlocked after its machine and every item it takes (the mold
--- aside); without a machine: the crafting table
local function recipe(def)
	local name = def.name
	if data.raw.recipe[name] then name = name .. "-gt" end
	if data.raw.recipe[name] then error("158-fork-gt-parts: recipe " .. name .. " exists already") end
	local category, time = "crafting", def.seconds or 0.5
	if def.machine then
		local t = def.tier or "lv"
		local top = TOP[def.machine] or "uxv"
		if TIER_INDEX[t] > TIER_INDEX[top] then t = top end
		category = t .. "-" .. def.machine .. "-recipes"
		time = (def.seconds or math.max(1, def.ticks) / 20) * SPEED[t]
	end
	data:extend({ {
		type = "recipe", name = name, category = category, enabled = false, energy_required = time,
		ingredients = def.ingredients, results = def.results, main_product = def.results[1].name,
		--- the machine's row, as create_recipe (a recipe without one would follow its item into the Material parts tab)
		subgroup = def.subgroup or (category ~= "crafting" and ("subgroup-" .. category) or nil),
	} })
	OC.made(name)
	FORK_GT_PARTS.recipes[name] = true
	local groups = { category ~= "crafting" and OC.machine_techs(category) or nil }
	for _, i in pairs(def.ingredients) do
		if i.type == "item" and i.name ~= "mold" then groups[#groups + 1] = item_techs(i.name) end
	end
	if not OC.unlock_after(name, groups) then
		--- the machine and the input on branches without a common later technology: the latest of them
		local best, best_n
		for _, g in pairs(groups) do
			for _, t in pairs(g or {}) do
				local n = #ancestors(t)
				if not best or n > best_n then best, best_n = t, n end
			end
		end
		if best then
			fork_add_unlock(best, name)
			techs_made[name] = { best }
		end
	end
	made = made + 1
	return name
end

--- the platinum group: GTNH turns their dusts from ore and part processing into the platinum line's powders and residues
--- (issue #199); no piles of their dust here (they would make the dust outside the platinum line)
local PGM = { platinum = true, palladium = true, iridium = true, osmium = true, rhodium = true, ruthenium = true }
--- the small and tiny piles of a material's dust (nil: Gregtorio has no dust of it, or a platinum group metal)
local function piles(d, m)
	if not d.dust or PGM[m] then return nil end
	local base = d.dust:match("^(.*)%-dust$") or d.dust
	return "small-pile-of-" .. base .. "-dust", "tiny-pile-of-" .. base .. "-dust"
end

--------------------------------------------------------------------------------
--- 1) THE NUGGETS (issue #223 B5 for every metal; the new nuggets of #227 first, the round takes one)
--------------------------------------------------------------------------------
--- the GT mass of metals with a nugget and no entry in the data
local FALLBACK_MASS = { iron = 56, gold = 196, copper = 63, tin = 118, lead = 207, silver = 107, nickel = 58,
	beryllium = 9, thorium = 230, ledox = 98, realgar = 53, neodymium = 144, naquadah = 330, antimony = 121,
	molybdenum = 95 }
local new_parts, nuggets = 0, 0
local metals = {}
for m in pairs(DATA) do metals[#metals + 1] = m end
for m in pairs(FALLBACK_MASS) do
	if not DATA[m] then metals[#metals + 1] = m end
end
table.sort(metals)
for _, m in pairs(metals) do
	local d = DATA[m] or { source = "gt", mass = FALLBACK_MASS[m], dust = (m == "antimony") and "antimony" or (m .. "-dust") }
	if d.dust and not data.raw.item[d.dust] then d.dust = nil end
	local ingot, nugget = m .. "-ingot", m .. "-nugget"
	for _, f in pairs(d.forms or {}) do
		if f == "nugget" and data.raw.item[ingot] and add_item(nugget, sub_of(ingot, "subgroup-smelting"), "z-" .. m .. "-a") then
			new_parts = new_parts + 1
		end
	end
	if data.raw.item[nugget] and data.raw.item[ingot] then
		local gtpp = d.source == "gtpp"
		if not data.raw.recipe[m .. "-nugget-from-ingot"] then
			recipe{ name = m .. "-nugget-from-ingot", machine = "alloy-smelter", tier = d.tier, seconds = not gtpp and 5 or nil,
				ticks = 2 * d.mass, subgroup = "subgroup-lv-alloy-smelter-recipes",
				ingredients = { item(ingot), item("mold") }, results = { item(nugget, 9), item("mold") } }
		end
		if not data.raw.recipe[m .. "-ingot-from-nuggets"] then
			recipe{ name = m .. "-ingot-from-nuggets", machine = "alloy-smelter", tier = d.tier, seconds = not gtpp and 10 or nil,
				ticks = 2 * d.mass, subgroup = "subgroup-lv-alloy-smelter-recipes",
				ingredients = { item(nugget, 9), item("mold") }, results = { item(ingot), item("mold") } }
		end
		local _, tiny = piles(d, m)
		if tiny and not data.raw.recipe[m .. "-nugget-maceration"] then
			add_item(tiny, sub_of(d.dust, "subgroup-macerator-dust"), "z-" .. tiny)
			recipe{ name = m .. "-nugget-maceration", machine = "macerator", ticks = math.max(16, math.floor(d.mass / 9)),
				ingredients = { item(nugget) }, results = { item(tiny) } }
			if not data.raw.recipe[d.dust .. "-from-tiny-piles"] then
				recipe{ name = d.dust .. "-from-tiny-piles", ingredients = { item(tiny, 9) }, results = { item(d.dust) } }
			end
		end
		nuggets = nuggets + 1
	end
end

--------------------------------------------------------------------------------
--- 2) THE PARTS (issues #222 and #227), each part before the parts made from it
--------------------------------------------------------------------------------
local ORDER = { plate = "c", ["double-plate"] = "d1", ["triple-plate"] = "d2", ["quadruple-plate"] = "d3",
	["quintuple-plate"] = "d4", ["dense-plate"] = "e", ["superdense-plate"] = "f", foil = "g", rod = "h",
	["long-rod"] = "i", round = "j", bolt = "k", screw = "l", ring = "m", gear = "n", ["large-gear"] = "o",
	["item-casing"] = "p", ["small-spring"] = "q", spring = "r", ["fine-wire"] = "s", frame = "t", block = "u", rotor = "v" }
local MULTI = { ["double-plate"] = 2, ["triple-plate"] = 3, ["quadruple-plate"] = 4, ["quintuple-plate"] = 5 }
local NAME = { plate = "%s-plate", ["double-plate"] = "double-%s-plate", ["triple-plate"] = "triple-%s-plate",
	["quadruple-plate"] = "quadruple-%s-plate", ["quintuple-plate"] = "quintuple-%s-plate",
	["dense-plate"] = "dense-%s-plate", ["superdense-plate"] = "superdense-%s-plate", foil = "%s-foil", rod = "%s-rod",
	["long-rod"] = "long-%s-rod", bolt = "%s-bolt", screw = "%s-screw", round = "%s-round", ring = "%s-ring",
	["fine-wire"] = "fine-%s-wire", ["small-spring"] = "small-%s-spring", spring = "%s-spring",
	["item-casing"] = "%s-item-casing", frame = "%s-frame", block = "block-of-%s", gear = "%s-gear",
	["large-gear"] = "large-%s-gear", rotor = "%s-rotor" }
--- vanilla items that are a form of a material (200's SPECIAL)
local ALIAS = { ["iron-rod"] = "iron-stick", ["iron-gear"] = "iron-gear-wheel" }

for _, m in pairs(metals) do
	local d = DATA[m]
	if d and data.raw.item[m .. "-ingot"] then
		local wanted = {}
		for _, f in pairs(d.forms) do wanted[f] = true end
		local ingot = m .. "-ingot"
		local sub = sub_of(ingot, "subgroup-smelting")
		local gtpp = d.source == "gtpp"
		local M = d.mass
		local small = piles(d, m)
		--- GT: the material's processing voltage, else the recipe's own; GT++: the alloy's voltage (at least "low")
		local function tier(eu, low)
			if gtpp then
				local t = d.tier
				if low and TIER_INDEX[low] > TIER_INDEX[t] then t = low end
				return t
			end
			return d.tier or tier_of(eu)
		end
		local vm = (d.temp or 0) >= 2800 and 60 or 15
		--- the item of a form (a vanilla item where it is one)
		local function form(f)
			local name = string.format(NAME[f], m)
			return ALIAS[name] or name
		end
		local function part(f)
			local name = form(f)
			if not wanted[f] or data.raw.item[name] then return nil end
			add_item(name, sub, "z-" .. m .. "-" .. ORDER[f])
			new_parts = new_parts + 1
			return name
		end
		local n = part("plate")
		if n then recipe{ name = n, machine = "bending-machine", tier = tier(24), ticks = M,
			ingredients = { item(ingot) }, results = { item(n) } } end
		for _, f in pairs({ "double-plate", "triple-plate", "quadruple-plate", "quintuple-plate" }) do
			n = part(f)
			if n then recipe{ name = n, machine = "bending-machine", tier = tier(96, "mv"), ticks = M * MULTI[f],
				ingredients = { item(ingot, MULTI[f]) }, results = { item(n) } } end
		end
		n = part("dense-plate")
		if n then recipe{ name = n, machine = "bending-machine", tier = tier(96, "mv"), ticks = gtpp and 2 * M or 9 * M,
			ingredients = { item(ingot, 9) }, results = { item(n) } } end
		n = part("superdense-plate")
		if n then recipe{ name = n, machine = "compressor", tier = tier(96), ticks = 32 * M,
			ingredients = { item(form("plate"), 64) }, results = { item(n) } } end
		n = part("foil")
		if n then recipe{ name = n, machine = "bending-machine", tier = tier(24), ticks = 2 * M,
			ingredients = { item(ingot) }, results = { item(n, 4) } } end
		n = part("rod")
		if n then
			local results = { item(n) }
			if small then
				add_item(small, sub_of(d.dust, "subgroup-macerator-dust"), "z-" .. small)
				results[2] = item(small, 2)
			end
			recipe{ name = n, machine = "lathe", tier = tier(16), ticks = gtpp and math.max(1, math.floor(M / 8)) or 5 * M,
				ingredients = { item(ingot) }, results = results }
			if small and not data.raw.recipe[d.dust .. "-from-small-piles"] then
				recipe{ name = d.dust .. "-from-small-piles", ingredients = { item(small, 4) }, results = { item(d.dust) } }
			end
		end
		n = part("long-rod")
		if n then recipe{ name = n, machine = "forge-hammer", tier = gtpp and "lv" or tier(16), ticks = M,
			ingredients = { item(form("rod"), 2) }, results = { item(n) } } end
		n = part("bolt")
		if n then
			if gtpp then
				recipe{ name = n, machine = "cutting-machine", tier = tier(4), ticks = 2 * M,
					ingredients = { item(form("rod")) }, results = { item(n, 4) } }
			else
				recipe{ name = n, machine = "cutting-machine", tier = tier(4), ticks = 4 * M,
					ingredients = { item(form("rod")), fluid("water", 0.4) }, results = { item(n, 4) } }
			end
		end
		n = part("screw")
		if n then recipe{ name = n, machine = "lathe", tier = gtpp and "lv" or tier(4), ticks = math.max(1, math.floor(M / 8)),
			ingredients = { item(form("bolt")) }, results = { item(n) } } end
		n = part("round")
		if n then recipe{ name = n, machine = "lathe", tier = "lv", ticks = math.max(1, math.floor(M / 4)),
			ingredients = { item(m .. "-nugget") }, results = { item(n) } } end
		n = part("ring")
		if n then recipe{ name = n, machine = "extruder", tier = tier(6 * vm), ticks = 2 * M,
			ingredients = { item(ingot) }, results = { item(n, 4) } } end
		n = part("fine-wire")
		if n then recipe{ name = n, machine = "wiremill", tier = "lv", ticks = 100,
			ingredients = { item(ingot) }, results = { item(n, 4) } } end
		n = part("small-spring")
		if n then recipe{ name = n, machine = "bending-machine", tier = tier(8), seconds = 5,
			ingredients = { item(form("rod")) }, results = { item(n, 2) } } end
		n = part("spring")
		if n then recipe{ name = n, machine = "bending-machine", tier = tier(16), seconds = 10,
			ingredients = { item(form("long-rod")) }, results = { item(n) } } end
		n = part("item-casing")
		if n then recipe{ name = n, machine = "alloy-smelter", tier = tier(15), seconds = 6.4,
			subgroup = "subgroup-lv-alloy-smelter-recipes",
			ingredients = { item(ingot, 2), item("mold") }, results = { item(n, 3), item("mold") } } end
		n = part("frame")
		if n then recipe{ name = n, machine = "assembling-machine", tier = tier(7), seconds = gtpp and 3 or 3.2,
			ingredients = { item(form("rod"), 4) }, results = { item(n) } } end
		n = part("block")
		if n then recipe{ name = n, machine = "compressor", tier = tier(2), seconds = 15,
			ingredients = { item(ingot, 9) }, results = { item(n) } } end
		n = part("gear")
		if n then recipe{ name = n, machine = "extruder", tier = tier(8 * vm), ticks = M,
			ingredients = { item(ingot) }, results = { item(n) } } end
		n = part("large-gear")
		if n then recipe{ name = n, machine = "extruder", tier = tier(8 * vm), ticks = 5 * M,
			ingredients = { item(ingot, 4) }, results = { item(n) } } end
		n = part("rotor")
		if n then
			if gtpp then
				recipe{ name = n, machine = "extruder", tier = tier(0), ticks = 5 * M,
					ingredients = { item(ingot, 5) }, results = { item(n) } }
			else
				recipe{ name = n, machine = "assembling-machine", tier = tier(24), ticks = M,
					ingredients = { item(form("plate"), 4), item(form("ring")), fluid("soldering-alloy", 1.6) },
					results = { item(n) } }
			end
		end
	end
end

FORK_CASTING.run()
log("FORK-GT-PARTS: " .. new_parts .. " new parts and nuggets (issues #222, #227), GT's nugget recipes of " .. nuggets
	.. " metals (issue #223), " .. made .. " recipes; casting: " .. FORK_CASTING.casts .. " casts")
