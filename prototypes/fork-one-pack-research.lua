--- Cheap research (startup setting `gregtorio-continued-one-pack-research`, default off): every technology that is
--- researched with science packs costs one research unit of one pack of each kind it needs, instead of its unit count
--- (20 to several thousand) times 1 to 15 packs per kind. The research time of the unit stays. Technologies with a
--- research trigger are not touched. Infinite technologies (`victory`, `godforge-upgrades`) cost one unit on every
--- level.
---
--- Loaded at the end of data-final-fixes.lua, so it also covers the technologies of 138 (research balance), of
--- me-network and of mods that load after Gregtorio's data stage. It changes prototypes only: turning the setting on
--- or off in a running game changes what is still to research, never what is researched.
local setting = settings.startup["gregtorio-continued-one-pack-research"]
if not (setting and setting.value) then return end

local n = 0
for _, tech in pairs(data.raw.technology) do
	local unit = tech.unit
	if unit then
		if unit.count_formula then
			unit.count_formula = "1"
			unit.count = nil
		else
			unit.count = 1
		end
		for _, ing in pairs(unit.ingredients or {}) do
			if ing.amount then ing.amount = 1 else ing[2] = 1 end
		end
		n = n + 1
	end
end
log("FORK-ONE-PACK-RESEARCH: " .. n .. " technologies cost one science pack of each kind")
