--------------------------------------------------------------------------------
--- FORK: GT OVERCLOCKING (issue #616; startup setting gregtorio-continued-gt-overclocking, default off)
--- Gregtorio overclocks every machine perfectly: each tier doubles a machine's speed and its power
--- (05-definitions-module.lua), so a craft costs the same energy in every tier's machine. GT New Horizons doubles the speed
--- for four times the EU/t (gregtech/api/util/OverclockCalculator.java:33-35: the duration divided by 2, the EU/t
--- multiplied by 4 per overclock; perfect overclocks only in special cases). Gregtorio's recipes already cost their own
--- tier's energy (their time is GT's seconds x the recipe tier's speed), so a machine whose power grows 4 times per tier
--- instead of 2 gives GT's energy per craft: a recipe of tier R in a machine of tier T costs 2^(T - R) times its base,
--- one doubling per overclock. With the setting on, every electric assembling machine and furnace with a crafting
--- speed of 2 or more (the tier's speed: MV 2, HV 4, ... MAX 8192) draws its power times 2^floor(log2(speed)), so its
--- power quadruples per tier. Steam and burner machines, generators and the other entity types stay; so do the
--- generators' outputs, which are sized for the perfect overclock (the setting makes every machine from MV up dearer:
--- an HV machine 4 times, an IV machine 16 times, a UV machine 128 times). Required from data-final-fixes.lua after every
--- file that makes or changes a machine. FORK_GT_OVERCLOCKING.changed (machine -> factor) is devcheck's section
--- OVERCLOCK.
--------------------------------------------------------------------------------

FORK_GT_OVERCLOCKING = { on = settings.startup["gregtorio-continued-gt-overclocking"].value, changed = {} }

local UNITS = { W = 1, kW = 1e3, MW = 1e6, GW = 1e9, TW = 1e12, PW = 1e15 }

--- "1.28MW" -> 1.28e6 (W); nil for anything else
local function watts(power)
	local n, unit = tostring(power):match("^([%d%.]+)%s*(%a+)$")
	return n and UNITS[unit] and tonumber(n) * UNITS[unit]
end

if FORK_GT_OVERCLOCKING.on then
	for _, t in pairs({ "assembling-machine", "furnace" }) do
		for name, e in pairs(data.raw[t] or {}) do
			local speed = e.crafting_speed or 1
			local w = watts(e.energy_usage)
			if e.energy_source and e.energy_source.type == "electric" and speed >= 2 and w then
				local factor = 2 ^ math.floor(math.log(speed, 2) + 1e-9)
				e.energy_usage = string.format("%.6gkW", w * factor / 1e3)
				FORK_GT_OVERCLOCKING.changed[name] = factor
			end
		end
	end
end
