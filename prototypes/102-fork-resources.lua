--------------------------------------------------------------------------------
--- FORK RESOURCES
--- Gregtorio does not use the vanilla/Space Age resource patches: all raw materials
--- come from Gregtorio's own mines, dig sites and microminers. Upstream only hides the
--- patches in the "Gregtorio" map preset, so maps made with other presets (and existing
--- saves) still have iron, copper, stone and coal patches that can be mined by hand,
--- which skips a large part of the early game (stone and coal are real Gregtorio items).
---
--- 1) The patches no longer spawn on new maps (autoplace removed).
--- 2) Existing patches are moved to a resource category that neither the character nor
---    any drill can mine. They stay visible but cannot be mined.
---    The console command /gregtorio-remove-vanilla-ores (control.lua) deletes them.
--------------------------------------------------------------------------------

FORK_DISABLED_RESOURCES = {
	-- Nauvis
	"iron-ore", "copper-ore", "stone", "coal", "uranium-ore", "crude-oil",
	-- Space Age planets (only relevant with mods that put them on Nauvis)
	"tungsten-ore", "calcite", "scrap", "sulfuric-acid-geyser", "lithium-brine", "fluorine-vent",
}

data:extend({ { type = "resource-category", name = "gregtorio-disabled" } })

for _, name in pairs(FORK_DISABLED_RESOURCES) do
	local r = data.raw.resource[name]
	if r then
		r.category = "gregtorio-disabled"
		r.autoplace = nil
	end
end

--- Planets reference the resources in their map generation settings; drop those references
for _, planet in pairs(data.raw.planet or {}) do
	local mgs = planet.map_gen_settings
	if mgs then
		for _, name in pairs(FORK_DISABLED_RESOURCES) do
			if mgs.autoplace_controls then mgs.autoplace_controls[name] = nil end
			local ent = mgs.autoplace_settings and mgs.autoplace_settings.entity
			if ent and ent.settings then ent.settings[name] = nil end
		end
	end
end

--- Map generator: no sliders for resources that cannot spawn anyway
for _, name in pairs(FORK_DISABLED_RESOURCES) do
	for _, preset in pairs(data.raw["map-gen-presets"].default) do
		if type(preset) == "table" and preset.basic_settings and preset.basic_settings.autoplace_controls then
			preset.basic_settings.autoplace_controls[name] = nil
		end
	end
end
