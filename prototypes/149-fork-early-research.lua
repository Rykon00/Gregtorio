--------------------------------------------------------------------------------
--- FORK EARLY RESEARCH (issues #127 and #146)
--- The technologies with automation and logistic (green) science packs and nothing else cost 80 to 200 units upstream, as
--- vanilla's do, but a green pack is not vanilla's inserter and belt (5.5 iron plates). `lv-science-pack` makes two packs
--- from an LV motor, an LV piston, an electronic circuit and two tin cables: per pack 3 steel, 4.5 iron, 19 copper and 8 tin
--- ingots (counted along the cheapest recipes of the crafting menu, `tools/balance_model.py`-style expansion of the dump of
--- `devcheck.py check --balance-out`). A smelting step takes 10 s and a steel ingot 75 s in the primitive blast furnace
--- (15 s in an MV electric blast furnace), so a technology of 80 units needs 240 steel: 5 hours in one primitive blast
--- furnace, 75 minutes in four, and 1520 copper ingots (4.2 hours in one furnace at 10 s). Red packs (one copper plate and a
--- gear) stay cheap, which makes the step from the red to the green technologies a wall.
---
--- LV: the unit counts of these technologies are divided by 6 (rounded to 5; #127 took a quarter, #146 a sixth after the
--- report of a player: "DIVISOR = 6 is fine", LV to MV with seven primitive blast furnaces): 80 -> 15, 100 -> 15,
--- 120 -> 20, 140 -> 25, 160 -> 25, 180 -> 30, 200 -> 35. The first green technology is 45 steel. Technologies with fewer
--- than 80 units (the equipment techs with 50) stay as they are.
---
--- MV to IV (issue #146): the same player saw the next tier jump from 15-35 units to 180. These technologies (the highest
--- pack military, chemical, production or utility) are divided so a technology costs about as long in the factory of its
--- tier as an LV technology in the LV factory, the factory doubling with every tier (138's rule for UV and up). The cost of
--- a unit is the machine-seconds of its packs along the recipes a player has at that tier (tools/balance_model.py with the
--- recipes of the tier's technologies only, the base chemicals on GT's standard routes); the medians: an LV technology
--- (after the division) 8.8 machine-hours, MV 172, HV 461, EV 1340, IV 2264 against 17.5, 35, 70 and 140. So MV / 10,
--- HV / 13, EV / 19, IV / 16 (the IV pack is cheaper per unit with IV machines than the EV pack with EV ones): the median
--- counts become 30 (MV), 30 (HV), 30 (EV) and 50 (IV), rounded to 5, at least 5. The time of a unit and the packs stay.
--- LuV and ZPM are not touched; UV and up are balanced in 138. Not an exact model of a factory: untested in the game.
--- data-final-fixes.lua sets the units of some vanilla technologies after this file: FORK_EARLY_RESEARCH.rescale() divides
--- them there (issue #146; #127 missed them: circuit-network kept 160). The cheap research setting
--- (fork-one-pack-research.lua) loads after that and wins.
--------------------------------------------------------------------------------

local DIVISOR = 6                 -- LV: red and green packs only, 80 units or more
local MIN_COUNT = 80
--- the highest pack of a technology -> its divisor (MV to IV)
local TIER_DIVISOR = {
	["military-science-pack"] = 10,     -- MV
	["chemical-science-pack"] = 13,     -- HV
	["production-science-pack"] = 19,   -- EV
	["utility-science-pack"] = 16,      -- IV
}
local PACK_RANK = { ["automation-science-pack"] = 0, ["logistic-science-pack"] = 1, ["military-science-pack"] = 2,
	["chemical-science-pack"] = 3, ["production-science-pack"] = 4, ["utility-science-pack"] = 5 }
local RANK_PACK = {}
for p, r in pairs(PACK_RANK) do RANK_PACK[r] = p end

local function rounded(count, divisor)
	return math.max(5, math.floor(count / divisor / 5 + 0.5) * 5)
end

--- the unit tables this file has seen: data-final-fixes.lua gives some vanilla technologies a new unit table afterwards
--- (circuit-network, fluid-wagon, cliff-explosives ...); FORK_EARLY_RESEARCH.rescale() divides those there too
FORK_EARLY_RESEARCH = { seen = {} }

--- divides the unit count of one technology; returns "lv", "higher" or nil
local function scale(name, tech)
	local unit = tech.unit
	FORK_EARLY_RESEARCH.seen[name] = unit
	if not (unit and unit.count and unit.ingredients) then return nil end
	--- the highest pack (nil: a pack above IV, which this file leaves alone)
	local rank = -1
	for _, i in pairs(unit.ingredients) do
		local r = PACK_RANK[i[1] or i.name]
		if r == nil then rank = nil break end
		if r > rank then rank = r end
	end
	local divisor
	if rank == 1 and #unit.ingredients == 2 and unit.count >= MIN_COUNT then
		divisor = DIVISOR
	elseif rank and rank >= 2 then
		divisor = TIER_DIVISOR[RANK_PACK[rank]]
	else
		return nil
	end
	local count = rounded(unit.count, divisor)
	log("FORK-EARLY-RESEARCH: " .. name .. " " .. unit.count .. " -> " .. count)
	unit.count = count
	return rank == 1 and "lv" or "higher"
end

local function run(only_replaced)
	local n = { lv = 0, higher = 0 }
	for name, tech in pairs(data.raw.technology) do
		if not only_replaced or (FORK_EARLY_RESEARCH.seen[name] ~= tech.unit) then
			local k = scale(name, tech)
			if k then n[k] = n[k] + 1 end
		end
	end
	return n
end

function FORK_EARLY_RESEARCH.rescale()
	local n = run(true)
	log("FORK-EARLY-RESEARCH: " .. (n.lv + n.higher) .. " technologies whose unit table was replaced later divided too")
end

local n = run(false)
log("FORK-EARLY-RESEARCH: " .. n.lv .. " LV technologies divided by " .. DIVISOR .. ", " .. n.higher
	.. " MV to IV technologies by their tier's divisor (issues #127, #146)")
