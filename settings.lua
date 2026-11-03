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
	},
	--- Fork: the boiler output (issue #593, prototypes/fork-boiler-output.lua): every steam boiler makes this many times its
	--- steam per second and burns its fuel as much faster; 1 is GT New Horizons. A list, so the steps stay round numbers
	{
		type = "double-setting",
		name = "gregtorio-continued-boiler-output",
		setting_type = "startup",
		default_value = 1,
		allowed_values = { 1, 1.5, 2, 3, 4, 6, 8, 16 },
		order = "d"
	},
	--- Fork: GT New Horizons' overclocking (issue #616, prototypes/fork-gt-overclocking.lua): every electric machine's power
	--- grows 4 times per tier instead of 2, so a recipe costs twice the energy per tier above its own; default off
	{
		type = "bool-setting",
		name = "gregtorio-continued-gt-overclocking",
		setting_type = "startup",
		default_value = false,
		order = "e"
	},
	--- Fork: maintenance of the multiblocks (issue #618, prototypes/fork-maintenance.lua): a kit in a slot per 2 hours of
	--- running; default off
	{
		type = "bool-setting",
		name = "gregtorio-continued-maintenance",
		setting_type = "startup",
		default_value = false,
		order = "f"
	},
	--- Fork: GT New Horizons' radiation (issue #621): radioactive items hurt a character without a Hazmat Suit; default off
	{
		type = "bool-setting",
		name = "gregtorio-continued-radiation",
		setting_type = "startup",
		default_value = false,
		order = "g"
	}
})
