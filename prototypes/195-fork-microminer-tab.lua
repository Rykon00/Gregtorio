--------------------------------------------------------------------------------
--- FORK MICROMINER TAB (issue #120)
--- The missions run in the Microverse Projector (MV to MAX), but neither the machine nor the missions were where one looks
--- for them: the projectors sat in the assembling machine tab (and a search for "microm" cannot find "Microverse
--- Projector"), the tier four mission was alone in a tab of the processing machine recipes, the EV ender tank was in the
--- tier two row, the lunar navigation data (needed for tier four only) in the tier one row, the tier one microminer in the
--- processing machine tab.
---
--- Now the Microminer tab starts with a row of the projectors (and their controller), then one row per tier (the tier
--- of the upstream list in 52-microverse-module.lua: one MV, two HV, three EV, four IV, the projector that runs the
--- mission), each starting with its microminer, the data item the mission needs, the mission and the ender tank of the
--- tier's projector; the rest of a row (plating, engine parts, the ore recipes of the assembling machine) follows. Items and
--- recipes get the same row and order, so the crafting menu, the item list and a projector's recipe window agree.
--- GregTech New Horizons has no microminers of this kind (they are Gregtorio's own); the tiers are upstream's.
--- Empty rows of tiers nothing uses (t5 to t12 of 04-item-groups-module.lua) are deleted. Loaded after every file that
--- makes microminer items and recipes.
--------------------------------------------------------------------------------

--- name (item and recipe) = { tier row, rank in the row }
local ROWS = {
	["steel-plated-microminer"] = { 1, "0a" },
	["overworld-data"] = { 1, "0b" },
	["tier-one-microminer-output"] = { 1, "0c" },
	["stainless-steel-plated-microminer"] = { 2, "0a" },
	["nether-data"] = { 2, "0b" },
	["tier-two-microminer-output"] = { 2, "0c" },
	["nether-air-ender-tank"] = { 2, "0d" },
	["titanium-plated-microminer"] = { 3, "0a" },
	["the-end-data"] = { 3, "0b" },
	["tier-three-microminer-output"] = { 3, "0c" },
	["ender-air-ender-tank"] = { 3, "0d" },
	["tungsten-carbide-plated-microminer"] = { 4, "0a" },
	["lunar-navigation-data"] = { 4, "0b" },
	["tier-four-microminer-output"] = { 4, "0c" },
}

local function item_of(n)
	for t, _ in pairs(defines.prototypes.item) do
		if data.raw[t] and data.raw[t][n] then return data.raw[t][n] end
	end
end

for name, row in pairs(ROWS) do
	local subgroup, order = "subgroup-microminer-t" .. row[1], string.format("%s[%s]", row[2], name)
	for _, p in pairs({ item_of(name), data.raw.recipe[name] }) do
		p.subgroup, p.order = subgroup, order
	end
end

--- the row of the projectors, first in the tab (order "0" sorts before the tier rows "a" ...), the controller first
data:extend({ {
	type = "item-subgroup", name = "subgroup-microverse-projectors", group = "microminer-tab", order = "0",
} })
local TIERS = { "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }
local projectors = { "microverse-projector-controller" }
for _, t in pairs(TIERS) do projectors[#projectors + 1] = t .. "-microverse-projector" end
for i, name in pairs(projectors) do
	for _, p in pairs({ item_of(name), data.raw.recipe[name] }) do
		if p then p.subgroup, p.order = "subgroup-microverse-projectors", string.format("a[%02d]-[%s]", i, name) end
	end
end

--- rows nothing uses (any item or recipe of any mod in them keeps its row)
local used = {}
for t, _ in pairs(defines.prototypes.item) do
	for _, it in pairs(data.raw[t] or {}) do if it.subgroup then used[it.subgroup] = true end end
end
for _, r in pairs(data.raw.recipe) do if r.subgroup then used[r.subgroup] = true end end
local deleted = 0
for tier = 5, 12 do
	local name = "subgroup-microminer-t" .. tier
	if data.raw["item-subgroup"][name] and not used[name] then
		data.raw["item-subgroup"][name] = nil
		deleted = deleted + 1
	end
end
log("FORK-MICROMINER-TAB: " .. #projectors .. " projector row entries, " .. deleted .. " empty rows deleted (issue #120)")
