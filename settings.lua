data:extend({
	--- Fork: machine recipes in the crafting menu (prototypes/198-fork-crafting-menu.lua, issue #49)
	{
		type = "bool-setting",
		name = "gregtorio-continued-show-machine-recipes",
		setting_type = "startup",
		default_value = true,
		order = "a"
	},
	--- Fork: cheap research (prototypes/fork-one-pack-research.lua): every technology costs one science pack of each kind
	{
		type = "bool-setting",
		name = "gregtorio-continued-one-pack-research",
		setting_type = "startup",
		default_value = false,
		order = "b"
	},
	--- Fork: the ore mode (issue #563): GTNH's ore veins on the map (plan #494) or the classic vein recipes of the mines
	--- (prototypes/166-fork-classic-veins.lua); chosen per game, scripts/fork-ore-veins.lua converts a save that switches
	{
		type = "string-setting",
		name = "gregtorio-continued-ore-mode",
		setting_type = "startup",
		default_value = "map-veins",
		allowed_values = { "map-veins", "vein-recipes" },
		order = "c"
	}
})
