--- the prototypes that move from the giver (version 1) to the taker: a drive-like container and a cell (item with tags)
local drive = table.deepcopy(data.raw.container["iron-chest"])
drive.name = "zz-handover-drive"
drive.minable.result = "iron-chest"
data:extend({
	drive,
	{ type = "item-with-tags", name = "zz-handover-cell", icon = "__base__/graphics/icons/iron-chest.png", stack_size = 1 },
})
