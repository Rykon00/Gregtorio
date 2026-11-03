--------------------------------------------------------------------------------
--- FORK: RADIATION, the mod data (issue #621; prototypes/172-fork-radiation.lua): the radioactive items of
--- prototypes/data/radioactive.lua that exist after every file, and the armors that protect. Required from
--- data-final-fixes.lua. Nothing with the setting off.
--------------------------------------------------------------------------------

if not (FORK_RADIATION and FORK_RADIATION.on) then return end

local items = {}
for name, level in pairs(require("prototypes.data.radioactive")) do
	for _, t in pairs({ "item", "module", "tool", "ammo", "capsule", "item-with-entity-data" }) do
		if data.raw[t] and data.raw[t][name] then items[name] = level break end
	end
end
local armors = {}
for _, name in pairs(FORK_RADIATION.armors) do
	if data.raw.armor[name] then armors[#armors + 1] = name end
end
FORK_RADIATION.items, FORK_RADIATION.protect = items, armors
data:extend({ { type = "mod-data", name = "fork-radiation", data = { items = items, armors = armors, check_ticks = 60 } } })
