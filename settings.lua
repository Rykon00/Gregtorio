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
	}
})
