--------------------------------------------------------------------------------
--- FORK EARLY RESEARCH (issue #127)
--- The technologies with automation and logistic (green) science packs and nothing else cost 80 to 200 units upstream, as
--- vanilla's do, but a green pack is not vanilla's inserter and belt (5.5 iron plates). `lv-science-pack` makes two packs
--- from an LV motor, an LV piston, an electronic circuit and two tin cables: per pack 3 steel, 4.5 iron, 19 copper and 8 tin
--- ingots (counted along the cheapest recipes of the crafting menu, `tools/balance_model.py`-style expansion of the dump of
--- `devcheck.py check --balance-out`). A smelting step takes 10 s and a steel ingot 75 s in the primitive blast furnace
--- (15 s in an MV electric blast furnace), so a technology of 80 units needs 240 steel: 5 hours in one primitive blast
--- furnace, 75 minutes in four, and 1520 copper ingots (4.2 hours in one furnace at 10 s). Red packs (one copper plate and a
--- gear) stay cheap, which makes the step from the red to the green technologies a wall.
---
--- The unit counts of these technologies are cut to a quarter (rounded to 5): 80 -> 20, 100 -> 25, 120 -> 30, 140 -> 35,
--- 160 -> 40, 180 -> 45, 200 -> 50. The time of a unit and the packs stay, so the first green technology is 60 steel
--- (19 minutes in four primitive blast furnaces, 75 minutes in one) and the last one 150 steel. Technologies with fewer than 80
--- units (the equipment techs with 50) and every technology with more packs stay as they are (the later tiers are balanced
--- in 138 and, from IV, not at all yet: issue #127 lists what is left). Not an exact model of a factory: untested in the
--- game; the numbers are in the pull request. The cheap research setting (fork-one-pack-research.lua) loads after this file
--- and wins.
--------------------------------------------------------------------------------

local DIVISOR = 4
local MIN_COUNT = 80
local changed = 0

for name, tech in pairs(data.raw.technology) do
	local unit = tech.unit
	if unit and unit.count and unit.count >= MIN_COUNT and unit.ingredients and #unit.ingredients == 2 then
		local green, red = false, false
		for _, i in pairs(unit.ingredients) do
			local n = i[1] or i.name
			if n == "logistic-science-pack" then green = true end
			if n == "automation-science-pack" then red = true end
		end
		if green and red then
			local count = math.max(5, math.floor(unit.count / DIVISOR / 5 + 0.5) * 5)
			log("FORK-EARLY-RESEARCH: " .. name .. " " .. unit.count .. " -> " .. count)
			unit.count = count
			changed = changed + 1
		end
	end
end
log("FORK-EARLY-RESEARCH: " .. changed .. " technologies with green packs cut to a quarter (issue #127)")
