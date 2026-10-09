--------------------------------------------------------------------------------
--- FORK MATERIAL PARTS (issue #118): one rule for the item lists
--- An item has no row of its own: `create_item` gives it the subgroup of the machine category that makes it
--- (`subgroup-<category>`), and inside a subgroup the order is the order of definition. Upstream defined the parts of its
--- materials form by form, the fork files material by material, so the lists (the signal and filter choosers, the item list
--- of Factoriopedia) showed both patterns: rows of blocks, gears, rotors ... mixing all materials, and the neutronium
--- parts in a row of their own.
---
--- Rule A (maintainer's decision): BY FORM. The material parts are in the item group "Material parts" (tab, after the
--- Microminer tab), one row (subgroup) per form, the materials by tier inside it. Rows wrap after ten. That is
--- GregTech's order too: its material item is one item whose damage value is `prefix index x 1000 + material id`
--- (GT5-Unofficial MetaGeneratedItem01.java:3957, the prefix list in its constructor), so NEI and the creative tab list every
--- ingot, then every plate ... The forms follow GT's prefix order (ingot, hot ingot, nugget, plates up to dense, foil, rod,
--- round, bolt, screw, ring), then block, the gears, rotor, wires and cables.
---
--- Items only: the recipes keep the subgroup of their machine, so the machine tabs do not change.
---
--- A part is an item named after a form of a material (FORMS; the vanilla names iron-stick and iron-gear-wheel are listed in
--- SPECIAL) where the form is an ingot or a plate, or the material has at least two forms (a lone `red-wire` or
--- `blaze-rod` is no part of a material).
--- The tier of a material (issue #145: the order inside a row) is the tier of the TECHNOLOGY that unlocks its ingot, the
--- earliest one (the tier of a technology: its highest science pack, see PACK_TIER); a recipe enabled from the start counts as
--- steam. A material without an ingot item takes the earliest technology of any of its parts. The solidifier tier of 143 is
--- not used: it says which solidifier can cast a material, not when the player meets it (europium is cast in an LV
--- solidifier and unlocked by a LuV technology). A material with nothing to go by goes last, or has a place in FIXED_TIER;
--- the others are a devcheck warning (FORK_MATERIAL_PARTS.unranked).
--- Dusts, frames, turbine blades and superconductive wires keep their machine rows. Loaded after 199, so the unlocks it
--- adds and the recipes it removes are in.
--------------------------------------------------------------------------------

local P = "__gregtorio-continued__/"

--- rows of the group, top to bottom: form, then how to find it in an item name
local FORMS = {
	{ "ingot", "", "-ingot" },
	{ "hot-ingot", "hot-", "-ingot" },
	{ "nugget", "", "-nugget" },
	{ "plate", "", "-plate" },
	{ "double-plate", "double-", "-plate" },   -- issue #222
	{ "triple-plate", "triple-", "-plate" },   -- issue #227
	{ "quadruple-plate", "quadruple-", "-plate" },
	{ "quintuple-plate", "quintuple-", "-plate" },
	{ "dense-plate", "dense-", "-plate" },
	{ "superdense-plate", "superdense-", "-plate" },
	{ "foil", "", "-foil" },
	{ "block", "block-of-", "" },
	{ "rod", "", "-rod" },
	{ "long-rod", "long-", "-rod" },
	{ "round", "", "-round" },
	{ "bolt", "", "-bolt" },
	{ "screw", "", "-screw" },
	{ "ring", "", "-ring" },
	{ "gear", "", "-gear" },
	{ "large-gear", "large-", "-gear" },
	{ "rotor", "", "-rotor" },
	{ "item-casing", "", "-item-casing" },   -- issue #222
	{ "small-spring", "small-", "-spring" },
	{ "spring", "", "-spring" },
	{ "wire", "", "-wire" },
	{ "fine-wire", "fine-", "-wire" },
	{ "cable", "", "-cable" },
}
--- the most specific pattern first (hot-iron-ingot before iron-ingot, long-steel-rod before steel-rod)
local MATCH = { "hot-ingot", "superdense-plate", "dense-plate", "double-plate", "triple-plate", "quadruple-plate",
	"quintuple-plate", "long-rod", "large-gear", "fine-wire",
	"small-spring", "item-casing", "ingot", "nugget", "plate", "foil", "block", "rod", "round", "bolt", "screw", "ring", "gear",
	"rotor", "spring", "wire", "cable" }
local SPECIAL = { ["iron-stick"] = { "iron", "rod" }, ["iron-gear-wheel"] = { "iron", "gear" } }
local TIERS = { lv = 1, mv = 2, hv = 3, ev = 4, iv = 5, luv = 6, zpm = 7, uv = 8, uhv = 9, uev = 10, uiv = 11, umv = 12,
	uxv = 13, max = 14 }
local NO_TIER = 99

local rank, pattern = {}, {}
for i, f in pairs(FORMS) do rank[f[1]] = i; pattern[f[1]] = f end

local function parse(name)
	if SPECIAL[name] then return SPECIAL[name][1], SPECIAL[name][2] end
	for _, form in pairs(MATCH) do
		local pre, suf = pattern[form][2], pattern[form][3]
		if #name > #pre + #suf and name:sub(1, #pre) == pre and (suf == "" or name:sub(-#suf) == suf) then
			return name:sub(#pre + 1, #name - #suf), form
		end
	end
end

local function item_types()
	local t = {}
	for type_, _ in pairs(defines.prototypes.item) do t[#t + 1] = type_ end
	return t
end

--- every candidate: material -> form -> the item prototype
local parts = {}
for _, type_ in pairs(item_types()) do
	for name, item in pairs(data.raw[type_] or {}) do
		local m, form = parse(name)
		if m then
			parts[m] = parts[m] or {}
			parts[m][form] = item
		end
	end
end

--- The tier of a technology: its highest science pack (one pack more for every tier: automation = steam, logistic = LV,
--- military = MV, chemical = HV, production = EV, utility = IV, space = LuV, metallurgic = ZPM, agricultural = UV,
--- electromagnetic = UHV, cryogenic = UEV, promethium = UIV, umv, uxv, max); a technology without science packs (a trigger)
--- takes its prerequisites' tier. Technologies that are disabled or hidden do not count.
local PACK_TIER = { automation = 0, logistic = 1, military = 2, chemical = 3, production = 4, utility = 5, space = 6,
	metallurgic = 7, agricultural = 8, electromagnetic = 9, cryogenic = 10, promethium = 11, umv = 12, uxv = 13, max = 14 }
local tech_memo = {}
local function tech_tier(name, seen)
	if tech_memo[name] ~= nil then return tech_memo[name] end
	local tech = data.raw.technology[name]
	local t = 0
	if tech and tech.unit and tech.unit.ingredients and #tech.unit.ingredients > 0 then
		for _, i in pairs(tech.unit.ingredients) do
			local pack = (i[1] or i.name or ""):gsub("%-science%-pack$", "")
			if (PACK_TIER[pack] or 0) > t then t = PACK_TIER[pack] end
		end
	elseif tech then
		seen = seen or {}
		if not seen[name] then
			seen[name] = true
			for _, pre in pairs(tech.prerequisites or {}) do
				local pt = tech_tier(pre, seen)
				if pt > t then t = pt end
			end
		end
	end
	tech_memo[name] = t
	return t
end

--- the earliest technology that unlocks each recipe; a recipe enabled from the start counts as steam (0)
local unlock_tier = {}
for name, tech in pairs(data.raw.technology) do
	if tech.enabled ~= false and not tech.hidden then
		local t = tech_tier(name)
		for _, e in pairs(tech.effects or {}) do
			if e.type == "unlock-recipe" and (unlock_tier[e.recipe] == nil or t < unlock_tier[e.recipe]) then
				unlock_tier[e.recipe] = t
			end
		end
	end
end
--- the earliest tier of a recipe that makes an item (recycling recipes left out)
local made_at = {}
for name, r in pairs(data.raw.recipe) do
	if r.category ~= "recycling" and not name:find("%-recycling$") and r.results then
		local t = unlock_tier[name]
		if r.enabled ~= false then t = 0 end
		if t ~= nil then
			for _, res in pairs(r.results) do
				if res.type ~= "fluid" and (made_at[res.name] == nil or t < made_at[res.name]) then made_at[res.name] = t end
			end
		end
	end
end

--- Materials whose parts no technology unlocks and no recipe enabled at the start makes: a fixed tier with the reason
local FIXED_TIER = {}

FORK_MATERIAL_PARTS = { parts = 0, materials = 0, unranked = {} }

--- subgroups and the group
data:extend({ {
	type = "item-group", name = "material-parts", order = "o", icon_size = 128,
	icon = P .. "graphics/item-groups/material-parts-tab.png",
} })
for i, f in pairs(FORMS) do
	data:extend({ {
		type = "item-subgroup", name = "gregtorio-parts-" .. f[1], group = "material-parts", order = string.format("a[%02d]", i),
	} })
end

for m, forms in pairs(parts) do
	local count = 0
	for _ in pairs(forms) do count = count + 1 end
	--- the ingot's technology; a material without an ingot: the earliest of its parts
	local tier = forms.ingot and made_at[forms.ingot.name] or nil
	if tier == nil then
		for _, item in pairs(forms) do
			local t = made_at[item.name]
			if t ~= nil and (tier == nil or t < tier) then tier = t end
		end
	end
	tier = tier or FIXED_TIER[m] or NO_TIER
	local is_material = count >= 2 or forms.ingot or forms.plate
	if is_material then
		FORK_MATERIAL_PARTS.materials = FORK_MATERIAL_PARTS.materials + 1
		if tier == NO_TIER then FORK_MATERIAL_PARTS.unranked[#FORK_MATERIAL_PARTS.unranked + 1] = m end
		for form, item in pairs(forms) do
			item.subgroup = "gregtorio-parts-" .. form
			item.order = string.format("%02d[%s]", tier, m)
			FORK_MATERIAL_PARTS.parts = FORK_MATERIAL_PARTS.parts + 1
		end
	end
end
table.sort(FORK_MATERIAL_PARTS.unranked)
log("FORK-MATERIAL-PARTS: " .. FORK_MATERIAL_PARTS.parts .. " parts of " .. FORK_MATERIAL_PARTS.materials
	.. " materials in " .. #FORMS .. " rows by form; materials without a tier: " .. #FORK_MATERIAL_PARTS.unranked)
