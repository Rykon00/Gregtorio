--- Issue #613: the offshore pump takes LV power now (prototypes/101-fork-machines.lua, section 2m'). The placed offshore
--- pumps of an older save keep pumping as before: each becomes a `legacy-offshore-pump` (the old prototype, no power);
--- mined, it gives the offshore pump item, which then needs power. The game runs this once per save.
for _, surface in pairs(game.surfaces) do
	for _, e in pairs(surface.find_entities_filtered{ name = "offshore-pump" }) do
		if e.valid then
			surface.create_entity{ name = "legacy-offshore-pump", position = e.position, direction = e.direction,
				force = e.force, fast_replace = true, spill = false, create_build_effect_smoke = false }
		end
	end
end
