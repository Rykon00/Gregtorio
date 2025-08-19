--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---------------------------------
---VANILLA ITEM RECIPE REMOVAL---
---------------------------------

data.raw["recipe"]["stone-furnace"] = nil
data.raw["recipe"]["iron-gear-wheel"] = nil
data.raw["recipe"]["iron-stick"] = nil
data.raw["recipe"]["steel-chest"] = nil
data.raw["recipe"]["stone-brick"] = nil
data.raw["recipe"]["wooden-chest"] = nil

data.raw["recipe"]["automation-science-pack"] = nil
data.raw["recipe"]["logistic-science-pack"] = nil
data.raw["recipe"]["military-science-pack"] = nil
data.raw["recipe"]["production-science-pack"] = nil
data.raw["recipe"]["utility-science-pack"] = nil



--------------------------------
---VANILLA ITEM FIELD CHANGES---
--------------------------------

---FURNACE
data.raw["furnace"]["stone-furnace"].energy_usage = "50kW"

---IRON CHEST
data.raw["container"]["iron-chest"].picture = {
  filename = "__Gregtorio__/graphics/entity/iron-chest.png",
  priority = "extra-high",
  width = 32,
  height = 32
}

---STEAM
data.raw["fluid"]["steam"].fuel_value = "100kJ"

---STEEL CHEST, RENAMED TO GOLD CHEST
data.raw["container"]["steel-chest"].picture = {
  filename = "__Gregtorio__/graphics/entity/gold-chest.png",
  priority = "extra-high",
  width = 32,
  height = 32
}

---STONE BRICK, RENAMED TO STONE BRICKS
data.raw["item"]["stone-brick"].icon = "__Gregtorio__/graphics/icons/stone-bricks.png"
data.raw["item"]["stone-brick"].icon_size = 32
data.raw["item"]["stone-brick"].icon_mipmaps = 1

---WATER
data.raw["fluid"]["water"].icon = "__Gregtorio__/graphics/fluids/water.png"
data.raw["fluid"]["water"].icon_size = 32


---WOODEN CHEST, RENAMED TO CHEST
data.raw["container"]["wooden-chest"].picture = {
  filename = "__Gregtorio__/graphics/entity/chest.png",
  priority = "extra-high",
  width = 32,
  height = 32
}

-----------------------------------
---VANILLA ITEM RECIPE OVERRIDES---
-----------------------------------

data:extend({

---BURNER INSERTER, RENAMED MANUAL INSERTER
  {
    type = "item",
    name = "burner-inserter",
    icon = "__base__/graphics/icons/burner-inserter.png",
    icon_size = 64,
    subgroup = "inserter",
    order = "a[burner-inserter]-b[crafting-table]",
    place_result = "burner-inserter",
    stack_size = 64
  },
  {
    type = "recipe",
    name = "manual-inserter-crafting-table",
    category = "crafting-table-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 5},
      {type = "item", name = "wooden-chest", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 1}
    },
    results = {
      {type = "item", name = "burner-inserter", amount = 2}
    }
  },
  {
    type = "recipe",
    name = "burner-inserter",
    category = "lv-assembling-machine-recipes",
    enabled = false,
    energy_required = 1,
    hide_from_player_crafting = true,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 5},
      {type = "item", name = "wooden-chest", amount = 1}
    },
    results = {
      {type = "item", name = "burner-inserter", amount = 2}
    }
  },



---COAL
  {
	  type = "item",
	  name = "coal",
      icon = "__Gregtorio__/graphics/icons/coal.png",
      icon_size = 32,
	  fuel_value = "4MJ",
	  fuel_category = "chemical",
	  fuel_emissions_multiplier = 1,
	  subgroup = "raw-resource",
	  order = "b[coal]",
	  stack_size = 64
  }, 
  
  
  
---INSERTER  
  {
    type = "item",
    name = "inserter",
    icon = "__base__/graphics/icons/inserter.png",
    icon_size = 64,
    subgroup = "inserter",
    order = "b[inserter]",
    place_result = "inserter",
    stack_size = 64
  },
  {
    type = "recipe",
    name = "inserter",
    category = "crafting-or-assembling-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "burner-inserter", amount = 1},
      {type = "item", name = "lv-motor", amount = 1},
      {type = "item", name = "iron-stick", amount = 1}
    },
    results = {
      {type = "item", name = "inserter", amount = 1}
    }
  },
  
  
  
---FAST INSERTER  
  {
    type = "item",
    name = "fast-inserter",
    icon = "__base__/graphics/icons/fast-inserter.png",
    icon_size = 64,
    subgroup = "inserter",
    order = "c[fast-inserter]",
    place_result = "fast-inserter",
    stack_size = 64
  },
  {
    type = "recipe",
    name = "fast-inserter",
    category = "crafting-or-assembling-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "inserter", amount = 1},
      {type = "item", name = "lv-robot-arm", amount = 1}
    },
    results = {
      {type = "item", name = "fast-inserter", amount = 1}
    }
  },



---STEEL CHEST, RENAMED GOLD CHEST
	{
	  type = "item",
	  name = "steel-chest",
      icon = "__Gregtorio__/graphics/icons/gold-chest.png",
      icon_size = 32,
	  subgroup = "storage",
	  order = "a[items]-c[steel-chest]",
	  place_result = "steel-chest",
	  stack_size = 64
	},
	{
		type = "recipe",
		name = "gold-chest",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = 1,
		ingredients = {
		  {type = "item", name = "gold-plate", amount = 6},
		  {type = "item", name = "iron-chest", amount = 1}
		},
		results = {
		  {type = "item", name = "steel-chest", amount = 1}
		}
   },  



---IRON CHEST
  {
    type = "item",
    name = "iron-chest",
    icon = "__Gregtorio__/graphics/icons/iron-chest.png",
    icon_size = 32,
    subgroup = "storage",
    order = "a[items]-b[iron-chest]",
    place_result = "iron-chest",
    stack_size = 64
  },
  {
    type = "recipe",
    name = "iron-chest-crafting-table",
    category = "crafting-table-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 8},
      {type = "item", name = "iron-screw", amount = 2},
      {type = "item", name = "wooden-chest", amount = 1}
    },
    results = {
      {type = "item", name = "iron-chest", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "iron-chest",
    category = "lv-assembling-machine-recipes",
    enabled = false,
    energy_required = 1,
    hide_from_player_crafting = true,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 6},
      {type = "item", name = "wooden-chest", amount = 1}
    },
    results = {
      {type = "item", name = "iron-chest", amount = 1}
    }
  },
 
  
  
---IRON STICK, RENAMED IRON ROD
	{
	  type = "item",
	  name = "iron-stick",
      icon = "__Gregtorio__/graphics/icons/iron-rod.png",
      icon_size = 32,
	  subgroup = "subgroup-early-game-machine-replacements",
	  order = "a[iron-stick]",
	  stack_size = 64
	},
  {
    type = "recipe",
    name = "iron-rod-crafting-table",
    category = "crafting-table-recipes",
    enabled = false,
    energy_required = 1,
    subgroup = "subgroup-early-game-machine-replacements",
    order = "a[iron]",
    ingredients = {
      {type = "item", name = "iron-ingot", amount = 1}
    },
    results = {
      {type = "item", name = "iron-stick", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "iron-stick",
    category = "lv-lathe-recipes",
    enabled = false,
    energy_required = IRON_SPEED * 2,
	hide_from_player_crafting = true,
    subgroup = "subgroup-lv-lathe-recipes",
    order = "a[iron]",	
    ingredients = {
      {type = "item", name = "iron-ingot", amount = 1}
    },
    results = {
      {type = "item", name = "iron-stick", amount = 2}
    }
  },


  
---IRON GEAR WHEEL, RENAMED IRON GEAR
  {
	  type = "item",
	  name = "iron-gear-wheel",
      icon = "__Gregtorio__/graphics/icons/iron-gear.png",
	  icon_size = 32,
	  stack_size = 64
  },
  {
    type = "recipe",
    name = "iron-gear-crafting-table",
    category = "crafting-table-recipes",
    enabled = false,
    energy_required = 1,
	subgroup = "subgroup-early-game-machine-replacements",
	order = "a[iron]",
    ingredients = {
      {type = "item", name = "iron-plate", amount = 1},
      {type = "item", name = "iron-stick", amount = 2}
    },
    results = {
      {type = "item", name = "iron-gear-wheel", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "iron-gear",
    category = "mv-extruder-recipes",
    enabled = false,
	subgroup = "subgroup-mv-extruder-recipes",
    energy_required = IRON_SPEED * 2,
	subgroup = "subgroup-mv-extruder-recipes",
    ingredients = {
      {type = "item", name = "iron-ingot", amount = 1}
    },
    results = {
      {type = "item", name = "iron-gear-wheel", amount = 1}
    }
  },
  


---PIPE
   {
	  type = "item",
	  name = "pipe",
	  icon = "__base__/graphics/icons/pipe.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  subgroup = "energy-pipe-distribution",
	  order = "a[pipe]-a[pipe]",
	  place_result = "pipe",
	  stack_size = 64
  },
  {
    type = "recipe",
    name = "pipe-crafting-table",
    category = "crafting-or-assembling-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "bronze-plate", amount = 1}
    },
    results = {
      {type = "item", name = "pipe", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "pipe",
    category = "mv-extruder-recipes",
    enabled = false,
    energy_required = 1.2,
    hide_from_player_crafting = true,
    ingredients = {
      {type = "item", name = "bronze-ingot", amount = 1}
    },
    results = {
      {type = "item", name = "pipe", amount = 1}
    }
  },
  
  
  
---PIPE TO GROUND  
  {
	  type = "item",
	  name = "pipe-to-ground",
	  icon = "__base__/graphics/icons/pipe-to-ground.png",
	  icon_size = 64,
	  icon_mipmaps = 4,
	  subgroup = "energy-pipe-distribution",
	  order = "a[pipe]-b[pipe-to-ground]",
	  place_result = "pipe-to-ground",
	  stack_size = 64
  },
  {
    type = "recipe",
    name = "pipe-to-ground",
    category = "crafting-or-assembling-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "bronze-plate", amount = 2},
      {type = "item", name = "pipe", amount = 10}
    },
    results = {
      {type = "item", name = "pipe-to-ground", amount = 2}
    }
  },
  

  
---STONE BRICK, RENAMED STONE BRICKS
   {
    type = "recipe",
    name = "stone-bricks",
    category = "crafting-or-assembling-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "stone", amount = 4}
    },
    results = {
      {type = "item", name = "stone-brick", amount = 4}
    }
  },   



---STONE, RENAMED COBBLESTONE
	{
	  type = "item",
	  name = "stone",
	  icon = "__Gregtorio__/graphics/icons/cobblestone.png",
	  icon_size = 32,
	  subgroup = "subgroup-cobblestone-related",
	  order = "a[cobblestone]",
	  stack_size = 64
	},
  
  

--- WOOD, RENAMED OAK LOG
	{
	  type = "item",
	  name = "wood",
	  icon = "__Gregtorio__/graphics/icons/oak-log.png",
	  icon_size = 32,
	  subgroup = "subgroup-wood-related",
	  order = "a[oak-log]",
	  fuel_value = "0.5MJ",
	  fuel_category = "chemical",
	  fuel_emissions_multiplier = 1,
	  stack_size = 64
	},

  

---WOODEN CHEST, RENAMED CHEST
	{
	  type = "item",
	  name = "wooden-chest",
	  icon = "__Gregtorio__/graphics/icons/chest.png",
	  icon_size = 32,
	  subgroup = "storage",
	  order = "a",
	  place_result = "wooden-chest",
	  stack_size = 64
	},
  {
    type = "recipe",
    name = "chest-crafting-table",
    category = "crafting-table-recipes",
    enabled = false,
    energy_required = 1,
    ingredients = {
      {type = "item", name = "wood", amount = 4},
      {type = "item", name = "plank", amount = 4},
      {type = "item", name = "flint", amount = 1}
    },
    results = {
      {type = "item", name = "wooden-chest", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "chest",
    category = "lv-assembling-machine-recipes",
    enabled = false,
    energy_required = 1,
    hide_from_player_crafting = true,
    ingredients = {
      {type = "item", name = "plank", amount = 8}
    },
    results = {
      {type = "item", name = "wooden-chest", amount = 1}
    }
  },	



---MANUAL LABOR
	{
	  type = "item",
	  name = "manual-labor",
	  icon = "__Gregtorio__/graphics/icons/manual-labor.png",
	  icon_size = 32,
	  stack_size = 200,
	  fuel_value = "1MJ",
	  fuel_category = "manual-labor",
	  subgroup = "subgroup-manual-labor",
	},
  {
    type = "recipe",
	name = "manual-labor",
	category = "manual-only-recipes",
	subgroup = "subgroup-manual-labor",
    energy_required = 1,
    ingredients = { },
    results = {
      {type = "item", name = "manual-labor", amount = 1}
    }
  },
  
  
  
---PUNCH TREES  
  {
    type = "recipe",
	name = "punch-trees",
	category = "manual-only-recipes",
	subgroup = "subgroup-wood-related",
    energy_required = 1,
	ingredients = {
		{type = "item", name = "manual-labor", amount = 1}
    },
	results = {
		{type = "item", name = "wood", amount = 1}
    }
  }
})



----------------
--- NEW ITEMS---
----------------


   
---FLINT  
create_item{
	name = "flint",
	category = "lv-macerator-recipes",
	ingredients = {
      {type = "item", name = "gravel", amount = 1}
    }
}
create_recipe{
	recipe_name = "flint-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-cobblestone-related",
	ingredients = {
		{type = "item", name = "gravel", amount = 3 }
    },
	results = {
		{type = "item", name = "flint", amount = 1 }
    }
} 
  
  
  
---GRAVEL  
create_item{
	name = "gravel",
	category = "lv-macerator-recipes",
	energy_required = 0.5,
	subgroup = "subgroup-cobblestone-related",
	ingredients = {
		{type = "item", name = "stone", amount = 1}
	}
}
create_recipe{
	recipe_name = "manually-digging-gravel",
	category = "manual-digsite-recipes",
	energy_required = 10,
	subgroup = "subgroup-mining-poor",
	ingredients = {
			{type = "item", name = "manual-labor", amount = 8}
		},
	results = {
		  {type = "item", name = "gravel", amount = 32},
		  {type = "item", name = "flint", amount = 3}
		},
	main_product = "gravel"
}
create_recipe{
	recipe_name = "gravel-with-shovel",
	category = "manual-digsite-recipes",
	energy_required = 10,
	subgroup = "subgroup-digging",
	ingredients = {
		  {type = "item", name = "iron-shovel-usage", amount = 1},
		  {type = "item", name = "manual-labor", amount = 2}
		},
	results = {
		  {type = "item", name = "gravel", amount = 64},
		  {type = "item", name = "flint", amount = 10}
		},
	main_product = "gravel"
}

  
  
---PLANK   
create_item{
	name = "plank",
	category = "lv-cutting-machine-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "wood", amount = 1},
    },
	results = {
		{type = "item", name = "plank", amount = 6},
		{type = "item", name = "wood-pulp", amount = 2},
    },
	main_product = "plank"
}
data.raw["item"]["plank"].fuel_value = "0.5MJ"
data.raw["item"]["plank"].fuel_category = "chemical"
create_recipe{
	recipe_name = "plank-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "wood", amount = 1},
    },
	results = {
      {type = "item", name = "plank", amount = 2},
    }
}
  
  
  
---STICK  
create_item{
	name = "stick",
	category = "lv-lathe-recipes",
	energy_required = 0.5,
	ingredients = {
      {type = "item", name = "plank", amount = 1}
    },
	results = {
      {type = "item", name = "stick", amount = 2}
    }
}
data.raw["item"]["stick"].fuel_value = "0.5MJ"
data.raw["item"]["stick"].fuel_category = "chemical"
create_recipe{
	recipe_name = "stick-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "plank", amount = 2}
    },
	results = {
      {type = "item", name = "stick", amount = 2}
    }
}



---WOODEN PICKAXE   
create_item{
	name = "wooden-pickaxe",
	subgroup = "subgroup-tool-recipes",
	ingredients = {
		{type = "item", name = "plank", amount = 3},
		{type = "item", name = "stick", amount = 2}
    }
}



---COBBLESTONE   
create_recipe{
	recipe_name = "cobblestone-manual-mine-with-wooden-pickaxe",
	category = "manual-mine-recipes",
	energy_required = 10,
    subgroup = "subgroup-mining-poor",
	ingredients = {
      {type = "item", name = "wooden-pickaxe", amount = 1},
      {type = "item", name = "manual-labor", amount = 8}
    },
	results = {
      {type = "item", name = "stone", amount = 64}
    }
}
create_recipe{
	recipe_name = "cobblestone-manual-mine",
	category = "manual-mine-recipes",
	energy_required = 10,
    subgroup = "subgroup-mining",
	ingredients = {
      {type = "item", name = "iron-pickaxe-usage", amount = 1},
      {type = "item", name = "manual-labor", amount = 2}
    },
	results = {
      {type = "item", name = "stone", amount = 64}
    }
}



---STONE PICKAXE   
create_item{
	name = "stone-pickaxe",
	subgroup = "subgroup-tool-recipes",
	ingredients = {
      {type = "item", name = "stone", amount = 3},
      {type = "item", name = "stick", amount = 2}
    }
}
  
  
  
---MINING IRON VEIN WITH STONE PICKAXE
create_recipe{
	recipe_name = "mining-iron-vein-with-stone-pickaxe",
	category = "manual-mine-recipes",
	energy_required = 10,
    subgroup = "subgroup-mining-poor",
	ingredients = {
      {type = "item", name = "stone-pickaxe", amount = 1},
      {type = "item", name = "manual-labor", amount = 12},
    },
	results = {
      {type = "item", name = "raw-iron", amount = 32},
    }
}


  
---IRON PLATE
create_recipe{
	recipe_name = "iron-plate-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "iron-ingot", amount = 2}
    },
	results = {
		{type = "item", name = "iron-plate", amount = 1}
    }
}  
create_recipe{
	recipe_name = "iron-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = IRON_SPEED,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 3}
    },
	results = {
		{type = "item", name = "iron-plate", amount = 2}
    }
}



---IRON AXE
create_item{
	name = "iron-axe",
	subgroup = "subgroup-tool-recipes",	
	ingredients = {
      {type = "item", name = "iron-plate", amount = 2},
      {type = "item", name = "iron-ingot", amount = 1},
      {type = "item", name = "stick", amount = 2},
    }
}



---CHOP TREES   
create_recipe{
	recipe_name = "chop-trees",
	category = "manual-only-recipes",
	subgroup = "subgroup-wood-related",
	ingredients = {
		{type = "item", name = "manual-labor", amount = 6},
		{type = "item", name = "iron-axe", amount = 1}
    },
	results = {
		{type = "item", name = "wood", amount = 128}
    }
}   

  
  
---IRON SHOVEL USAGE
create_item{
	name = "iron-shovel-usage",
	subgroup = "subgroup-tool-recipes",
	ingredients = {
      {type = "item", name = "iron-plate", amount = 1},
      {type = "item", name = "stick", amount = 2}
    },
	results = {
      {type = "item", name = "iron-shovel-usage", amount = 26}
    }
}
  
  
  
---IRON PICKAXE USAGE
create_item{
	name = "iron-pickaxe-usage",
	subgroup = "subgroup-tool-recipes",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 1},
		{type = "item", name = "iron-ingot", amount = 2},
		{type = "item", name = "stick", amount = 2}
    },
	results = {
		{type = "item", name = "iron-pickaxe-usage", amount = 26}
    }
}
  
  
  
---SAND 
create_item{
	name = "sand",
	category = "lv-macerator-recipes",
	energy_required = 0.5,
	ingredients = {
	  {type = "item", name = "gravel", amount = 1}
	}
}
create_recipe{
	recipe_name = "sand-manual-digsite",
	category = "manual-digsite-recipes",
	energy_required = 10,
	subgroup = "subgroup-digging",
	ingredients = {
		{type = "item", name = "iron-shovel-usage", amount = 1},
		{type = "item", name = "manual-labor", amount = 2}
    },
	results = {
		{type = "item", name = "sand", amount = 64}
    }
} 
  
  
  
---CLAY BALL 
create_item{
	name = "clay-ball",
	recipe_name = "clay-ball-manual-digsite",
	category = "manual-digsite-recipes",
	energy_required = 10,
    subgroup = "subgroup-digging",
	ingredients = {
		{type = "item", name = "iron-shovel-usage", amount = 1},
		{type = "item", name = "manual-labor", amount = 3}
    },
	results = {
		{type = "item", name = "clay-ball", amount = 64}
    }
}
  
  
  
 ---BRICK  
create_item{
	name = "brick",
	recipe_name = "brick-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "clay-ball", amount = 1},
    },
	results = {
		{type = "item", name = "brick", amount = 1},
    }
}
create_recipe{
	recipe_name = "brick-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "clay-ball", amount = 64}
    },
	results = {
		{type = "item", name = "brick", amount = 64}
    }
}
  
  
  
 ---CHARCOAL  
create_item{
	name = "charcoal",
	recipe_name = "charcoal-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "wood", amount = 1}
    },
	results = {
		{type = "item", name = "charcoal", amount = 1}
    }
}
create_recipe{
	recipe_name = "charcoal-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "wood", amount = 64}
    },
	results = {
		{type = "item", name = "charcoal", amount = 64}
    }
}
data.raw["item"]["charcoal"].fuel_value = "4MJ"
data.raw["item"]["charcoal"].fuel_category = "chemical"


---TORCH 
create_recipe{
	recipe_name = "torch",
	subgroup = "circuit-network",
	place_result = "small-lamp",
	ingredients = {
		{type = "item", name = "stick", amount = 1},
		{type = "item", name = "coal", amount = 1}
    },
	results = {
		{type = "item", name = "small-lamp", amount = 4}
    }
}
	
	
  
---COPPER PLATE
create_item{
	name = "copper-plate",
	recipe_name = "copper-plate-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 2}
    }
}
create_recipe{
	recipe_name = "copper-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = COPPER_SPEED,
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 3}
    },
	results = {
		{type = "item", name = "copper-plate", amount = 2}
    }
}



---SMOOTH STONE
create_item{
	name = "smooth-stone",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "stone", amount = 1}
    },
	results = {
		{type = "item", name = "smooth-stone", amount = 1}
    }
}
create_recipe{
	recipe_name = "smooth-stone-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "stone", amount = 64}
    },
	results = {
		{type = "item", name = "smooth-stone", amount = 64}
    }
}



 ---MORTAR AND PESTLE
create_item{
	name = "mortar-and-pestle",
	category = "manual-only-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "smooth-stone", amount = 5},
		{type = "item", name = "flint", amount = 2}
    },
}
  
  
  
---BRONZE DUST
create_recipe{
	recipe_name = "copper-ingot-to-copper-dust",
	category = "manual-only-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 32},
		{type = "item", name = "mortar-and-pestle", amount = 1}
    },
	results = {
		{type = "item", name = "copper-dust", amount = 32}
    }
}
create_recipe{
	recipe_name = "copper-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = COPPER_SPEED,
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 1},
    },
	results = {
		{type = "item", name = "copper-dust", amount = 1}
    }
}
create_recipe{
	recipe_name = "tin-ingot-to-tin-dust",
	category = "manual-only-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "tin-ingot", amount = 32},
		{type = "item", name = "mortar-and-pestle", amount = 1}
    },
	results = {
		{type = "item", name = "tin-dust", amount = 32}
    }
}
create_recipe{
	recipe_name = "tin-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = TIN_SPEED,
	ingredients = {
		{type = "item", name = "tin-ingot", amount = 1},
    },
	results = {
		{type = "item", name = "tin-dust", amount = 1}
    }
}
create_recipe{
	recipe_name = "bronze-dust-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-dust", amount = 3},
		{type = "item", name = "tin-dust", amount = 1}
    },
	results = {
		{type = "item", name = "bronze-dust", amount = 3}
    }
}
create_item{
	name = "bronze-dust",
	category = "lv-mixer-recipes",
	energy_required = 2,
	ingredients = {
		{type = "item", name = "copper-dust", amount = 3},
		{type = "item", name = "tin-dust", amount = 1}
    },
	results = {
		{type = "item", name = "bronze-dust", amount = 4}
    }
}
  
  
  
---BRONZE INGOT
create_item{
	name = "bronze-ingot",
	recipe_name = "bronze-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "bronze-dust", amount = 1}
    }
}
create_recipe{
	recipe_name = "bronze-ingot-alloy-smelter",
	category = "lv-alloy-smelter-recipes",
	energy_required = 8,
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 3},
		{type = "item", name = "tin-ingot", amount = 1}
    },
	results = {
		{type = "item", name = "bronze-ingot", amount = 4}
    }
}
create_recipe{
	recipe_name = "bronze-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "bronze-dust", amount = 64},
    },
	results = {
		{type = "item", name = "bronze-ingot", amount = 64}
    }
}
  


---OFFSHORE PUMP  
create_recipe{
	recipe_name = "offshore-pump",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{type = "item", name = "iron-gear-wheel", amount = 2},
		{type = "item", name = "pipe", amount = 3}
    }
}



---LONG HANDED INSERTER  
create_recipe{
	recipe_name = "long-handed-inserter",
    subgroup = "inserter",
	ingredients = {
		{type = "item", name = "iron-gear-wheel", amount = 1},
		{type = "item", name = "inserter", amount = 1},
		{type = "item", name = "iron-plate", amount = 1}
    }
}
  
  
  
---EMPTY BUCKET
create_item{
	name = "empty-bucket",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 3}
    }
}

  
  
---BRONZE PLATE
create_recipe{
	recipe_name = "bronze-plate-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "bronze-ingot", amount = 2}
    },
	results = {
		{type = "item", name = "bronze-plate", amount = 1}
    }
}
create_recipe{
	recipe_name = "bronze-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = BRONZE_SPEED,
	ingredients = {
		{type = "item", name = "bronze-ingot", amount = 3}
    },
	results = {
		{type = "item", name = "bronze-plate", amount = 2}
    }
}
  
  
  
---BRICK BLOCK
create_item{
	name = "brick-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{type = "item", name = "brick", amount = 4}
    }
}
create_recipe{
	recipe_name = "brick-block-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "brick", amount = 8},
		{type = "item", name = "bucket-of-water", amount = 1}
    },
	results = {
		{type = "item", name = "brick-block", amount = 2},
		{type = "item", name = "empty-bucket", amount = 1}
    },
	main_product = "brick-block"
}  
 
 
  
---BUCKET OF WATER
create_item{
	name = "bucket-of-water",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "empty-bucket", amount = 1},
		{type = "item", name = "manual-labor", amount = 1}
    }
}



---RED ALLOY INGOT 
create_item{
	name = "red-alloy-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 2.5,
	ingredients = {
		{type = "item", name = "copper-ingot", amount = 1},
		{type = "item", name = "redstone-dust", amount = 4}
    }
}
  

  
---RED ALLOY PLATE
create_recipe{
	recipe_name = "red-alloy-plate-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "red-alloy-ingot", amount = 2}
    },
	results = {
		{type = "item", name = "red-alloy-plate", amount = 1}
    }
}
create_recipe{
	recipe_name = "red-alloy-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = RED_ALLOY_SPEED,
	ingredients = {
		{type = "item", name = "red-alloy-ingot", amount = 3}
    },
	results = {
		{type = "item", name = "red-alloy-plate", amount = 2}
    }
}

   
  
---PISTON
create_item{
	name = "piston",
	ingredients = {
		{type = "item", name = "plank", amount = 3},
		{type = "item", name = "iron-gear-wheel", amount = 2},
		{type = "item", name = "stone", amount = 4},
		{type = "item", name = "red-alloy-plate", amount = 1},
    }
}

  
---IRON BOLT 
create_recipe{
	recipe_name = "iron-bolt-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "iron-stick", amount = 1}
    },
	results = {
		{type = "item", name = "iron-bolt", amount = 2}
    }
}
create_item{
	name = "iron-bolt",
	category = "lv-cutting-machine-recipes",
	energy_required = IRON_SPEED * 2,
	ingredients = {
		{type = "item", name = "iron-stick", amount = 1},
    },
	results = {
		{type = "item", name = "iron-bolt", amount = 4}
    }
}  
  
  
  
---IRON SCREW
create_recipe{
	recipe_name = "iron-screw-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "iron-bolt", amount = 2}
    },
	results = {
		{type = "item", name = "iron-screw", amount = 1}
    }
}


  
---ANVIL
create_item{
	name = "anvil",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "block-of-iron", amount = 5},
		{type = "item", name = "iron-plate", amount = 2},
		{type = "item", name = "iron-screw", amount = 2}
    }
}
  
  
  
---WOOD PULP 
create_item{
	name = "wood-pulp",
	category = "lv-macerator-recipes",
	energy_required = 7.5,
	ingredients = {
		{type = "item", name = "wood", amount = 1}
    },
	results = {
		{type = "item", name = "wood-pulp", amount = 6},
		{type = "item", name = "wood-pulp", amount = 1, probability = 0.8},
    },
	main_product = "wood-pulp"
}
data.raw["item"]["wood-pulp"].fuel_value = "1MJ"
data.raw["item"]["wood-pulp"].fuel_category = "chemical" 
  
  
  
---BRICK DUST
create_item{
	name = "brick-dust",
	category = "lv-macerator-recipes",
	energy_required = 0.75,
	ingredients = {
		{type = "item", name = "brick", amount = 1}
    }
}
  
  
  
---CLAY DUST
create_item{
	name = "clay-dust",
	category = "lv-macerator-recipes",
	energy_required = 0.75,
	ingredients = {
		{type = "item", name = "clay-ball", amount = 1}
    }
}



---COKE OVEN BRICK
create_item{
	name = "coke-oven-brick",
	category = "lv-alloy-smelter-recipes",
	energy_required = 7.5,
	ingredients = {
		{type = "item", name = "clay-ball", amount = 1},
		{type = "item", name = "sand", amount = 1}
    },
	results = {
		{type = "item", name = "coke-oven-brick", amount = 2}
    }
}

  
  
---COKE OVEN BLOCK
create_item{
	name = "coke-oven-block",
	ingredients = {
		{type = "item", name = "coke-oven-brick", amount = 4}
    }
}
  
  
  
---COKE
create_item{
	name = "coke",
	recipe_name = "coke-coke-oven",
	category = "coke-oven-recipes",
	energy_required = 45,
	ingredients = {
		{type = "item", name = "coal", amount = 1}
    },
	results = {
		{type = "item", name = "coke", amount = 1},
		{type = "fluid", name = "creosote", amount = 50 },
    }
}
data.raw["item"]["coke"].fuel_value = "8MJ"
data.raw["item"]["coke"].fuel_category = "chemical" 
create_recipe{
	recipe_name = "phenol-from-coal",
	category = "pyrolyse-oven-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "item", name = "coal", amount = 16 },
		{ type = "fluid", name = "steam", amount = 400 }
	},
	results = {
		{ type = "item", name = "coke", amount = 20 },
		{ type = "fluid", name = "phenol", amount = 100 }
	},
	main_product = "phenol"
}
create_recipe{
	recipe_name = "phenol-from-coal-dust",
	category = "pyrolyse-oven-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "item", name = "coal-dust", amount = 16 },
		{ type = "fluid", name = "steam", amount = 400 }
	},
	results = {
		{ type = "item", name = "coke", amount = 20 },
		{ type = "fluid", name = "phenol", amount = 100 }
	},
	main_product = "phenol"
}  
  

  
---FIRECLAY DUST
create_item{
	name = "fireclay-dust",
    subgroup = "subgroup-early-game-machine-replacements",	
	ingredients = {
		{type = "item", name = "clay-dust", amount = 1},
		{type = "item", name = "brick-dust", amount = 1},
    },
	results = {
		{type = "item", name = "fireclay-dust", amount = 2},
    }
} 
  
  
  
---COMPRESSED FIREBRICK
create_item{
	name = "compressed-firebrick",
	category = "lv-compressor-recipes",
	energy_required = 4,
	ingredients = {
		{type = "item", name = "fireclay-dust", amount = 1}
    }
}



---LIQUID CONCRETE BUCKET
create_item{
	name = "liquid-concrete-bucket",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "calcite", amount = 2},
		{type = "item", name = "bucket-of-water", amount = 1},
		{type = "item", name = "stone-dust", amount = 1},
		{type = "item", name = "clay-dust", amount = 1},
		{type = "item", name = "quartz-sand", amount = 1}
    }
}
  
  
  
---FIREBRICK
create_item{
	name = "firebrick",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "compressed-firebrick", amount = 1}
    }
}
create_recipe{
	recipe_name = "firebrick-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "compressed-firebrick", amount = 64}
    },
	results = {
		{type = "item", name = "firebrick", amount = 64}
    }
}
  
  
  
---STONE DUST
create_item{
	name = "stone-dust",
	category = "lv-macerator-recipes",
	ingredients = {
		{type = "item", name = "stone", amount = 1}
    }
}


  
---FIREBRICK BLOCK
create_item{
	name = "firebrick-block",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "firebrick", amount = 6},
		{type = "item", name = "liquid-concrete-bucket", amount = 1},
		{type = "item", name = "gypsum", amount = 2}
    },
	results = {
		{type = "item", name = "firebrick-block", amount = 1},
		{type = "item", name = "empty-bucket", amount = 1}
    },
	main_product = "firebrick-block"
}  
  
  
  
---STEEL INGOT
create_item{
	name = "steel-ingot",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 30,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 1},
		{type = "fluid", name = "oxygen", amount = 100},
    }
}
create_recipe{
	recipe_name = "steel-ingot-pbf",
	category = "pbf-recipes",
	energy_required = 75,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 1},
		{type = "item", name = "coke", amount = 1},
    },
	results = {
		{type = "item", name = "steel-ingot", amount = 1},
    }
}
create_item{
	name = "steel-dust",
	category = "lv-macerator-recipes",
	energy_required = STEEL_SPEED,
	ingredients = {
		{type = "item", name = "steel-ingot", amount = 1}
    }
}



---STEEL PLATE
create_recipe{
	recipe_name = "steel-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = STEEL_SPEED,
	ingredients = {
		{type = "item", name = "steel-ingot", amount = 3},
    },
	results = {
		{type = "item", name = "steel-plate", amount = 2},
    }
}
   
   
   
---MOLD
create_item{
	name = "mold",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4}
    }
}



---QUARTZ SAND
create_item{
	name = "quartz-sand",
	category = "lv-macerator-recipes",
	energy_required = 1.5,
	ingredients = {
		{type = "item", name = "sand", amount = 1}
    }
}
  
  
  
---FLINT DUST
create_item{
	name = "flint-dust",
	category = "lv-macerator-recipes",
	ingredients = {
		{type = "item", name = "flint", amount = 1}
    }
}   
  
  
  
---GLASS DUST
create_recipe{
	recipe_name = "glass-dust-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "quartz-sand", amount = 8},
		{type = "item", name = "flint-dust", amount = 1}
    },
	results = {
		{type = "item", name = "glass-dust", amount = 8}
    }
}
create_item{
	name = "glass-dust",
	category = "lv-mixer-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "quartz-sand", amount = 16},
		{type = "item", name = "flint-dust", amount = 1}
    },
	results = {
		{type = "item", name = "glass-dust", amount = 16}
    }
}



---GLASS
create_recipe{
	recipe_name = "glass-alloy-smelter",
	category = "lv-alloy-smelter-recipes",
	energy_required = 6,
	ingredients = {
		{type = "item", name = "glass-dust", amount = 1},
		{type = "item", name = "mold", amount = 1},
    },
	results = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "mold", amount = 1},
    },
	main_product = "glass"
}
create_item{
	name = "glass",
	category = "mv-electric-blast-furnace-recipes",
	ingredients = {
		{type = "item", name = "sand", amount = 1},
		{type = "fluid", name = "oxygen", amount = 2},
    },
	results = {
		{type = "item", name = "glass", amount = 2},
    }
}
create_recipe{
	recipe_name = "glass-fluid-solidifier",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 0.6,
	ingredients = {
		{type = "fluid", name = "molten-glass", amount = 14.4},
    },
	results = {
		{type = "item", name = "glass", amount = 1},
    }
}



---STICKY RESIN
create_item{
	name = "sticky-resin",
	category = "lv-extractor-recipes",
	energy_required = 8,
	ingredients = {
		{type = "item", name = "wood", amount = 1}
    },
	results = {
		{type = "item", name = "sticky-resin", amount = 2}
    }
}
  


---RAW RUBBER PULP
create_item{
	name = "raw-rubber-pulp",
	recipe_name = "raw-rubber-pulp-extractor",
	category = "lv-extractor-recipes",
	energy_required = 7.5,
	ingredients = {
		{type = "item", name = "sticky-resin", amount = 1}
    },
	results = {
		{type = "item", name = "raw-rubber-pulp", amount = 3}
    }
}
create_recipe{
	recipe_name = "centrifuging-sticky-resin",
	category = "lv-centrifuge-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "sticky-resin", amount = 1}
    },
	results = {
		{type = "item", name = "raw-rubber-pulp", amount = 3},
		{type = "fluid", name = "glue", amount = 10},
		{type = "item", name = "plant-ball", amount = 1, probability = 0.1}
    },
	main_product = "glue"
}
  


---RUBBER SHEET
create_recipe{
	recipe_name = "rubber-sheet-alloy-smelter",
	category = "lv-alloy-smelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "raw-rubber-pulp", amount = 3},
		{type = "item", name = "sulfur", amount = 1}
    },
	results = {
		{type = "item", name = "rubber-sheet", amount = 1}
    }
}
create_item{
	name = "rubber-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 2,
	ingredients = {
		{type = "fluid", name = "liquid-rubber", amount = 14.4}
    }
}



---COAL DUST
create_recipe{
	recipe_name = "coal-dust",
	category = "lv-macerator-recipes",
	energy_required = 0.6,
	ingredients = {
		{type = "item", name = "coal", amount = 1}
    }
}



---PAPER
create_item{
	name = "paper",
	recipe_name = "paper-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "wood-pulp", amount = 8},
		{type = "item", name = "bucket-of-water", amount = 1}
    },
	results = {
		{type = "item", name = "paper", amount = 4},
		{type = "item", name = "empty-bucket", amount = 1}
    },
	main_product = "paper"
}
  


---COPPER WIRE
create_recipe{
	recipe_name = "copper-wire-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-plate", amount = 1}
    },
	results = {
		{type = "item", name = "copper-wire", amount = 1}
    }
}



---COPPER FOIL
create_recipe{
	recipe_name = "copper-foil-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-plate", amount = 1}
    },
	results = {
		{type = "item", name = "copper-foil", amount = 2}
    }
}
  
  
  
---FINE COPPER WIRE
create_recipe{
	recipe_name = "fine-copper-wire-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "copper-foil", amount = 1}
    },
	results = {
		{type = "item", name = "fine-copper-wire", amount = 1}
    }
}

	
  
---RED ALLOY WIRE	
create_recipe{
	recipe_name = "red-alloy-wire-crafting-table",
	category = "crafting-table-recipes",
    subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "red-alloy-plate", amount = 1}
	},
	results = {
		{type = "item", name = "red-alloy-wire", amount = 1}
    }
}


  
---RESISTOR
create_item{
	name = "resistor",
	category = "lv-assembling-machine-recipes",
	energy_required = 8,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
      {type = "item", name = "carbon", amount = 1},
      {type = "item", name = "fine-copper-wire", amount = 4},
      {type = "fluid", name = "glue", amount = 10}
    },
	results = {
      {type = "item", name = "resistor", amount = 4}
    }
}  
create_recipe{
	recipe_name = "resistor-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "paper", amount = 2},
      {type = "item", name = "sticky-resin", amount = 2},
      {type = "item", name = "fine-copper-wire", amount = 2},
      {type = "item", name = "coal-dust", amount = 1}
    },
	results = {
      {type = "item", name = "resistor", amount = 2}
    }
}  



---STEEL ROD
create_recipe{
	recipe_name = "steel-rod-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "steel-ingot", amount = 1}
    },
	results = {
      {type = "item", name = "steel-rod", amount = 1}
    }
}



---STEEL BOLT
create_recipe{
	recipe_name = "steel-bolt-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "steel-rod", amount = 1}
    },
	results = {
      {type = "item", name = "steel-bolt", amount = 2}
    }
}



---GLASS TUBE
create_item{
	name = "glass-tube",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 10,
	ingredients = {
      {type = "fluid", name = "molten-glass", amount = 14.4}
    },
	results = {
      {type = "item", name = "glass-tube", amount = 10}
    }
}
create_recipe{
	recipe_name = "glass-tube-alloy-smelter",
	category = "lv-alloy-smelter-recipes",
	energy_required = 8,
	ingredients = {
      {type = "item", name = "glass-dust", amount = 1},
      {type = "item", name = "mold", amount = 1}
    },
	results = {
      {type = "item", name = "glass-tube", amount = 1},
      {type = "item", name = "mold", amount = 1}
    },
	main_product = "glass-tube"
}

  
  
---MOLTEN RED ALLOY
create_recipe{
	recipe_name = "molten-red-alloy",
	category = "lv-extractor-recipes",
	energy_required = 4,
	ingredients = {
      {type = "item", name = "red-alloy-ingot", amount = 1},
    },
	results = {
      {type = "fluid", name = "molten-red-alloy", amount = 14.4 }
    }
}



---VACUUM TUBE
create_recipe{
	recipe_name = "vacuum-tube-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "glass-tube", amount = 1},
      {type = "item", name = "steel-bolt", amount = 2},
      {type = "item", name = "copper-wire", amount = 3}
    },
	results = {
      {type = "item", name = "vacuum-tube", amount = 1}
    }
}
create_item{
	name = "vacuum-tube",
	category = "lv-assembling-machine-recipes",
	energy_required = 2,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
      {type = "item", name = "glass-tube", amount = 1},
      {type = "item", name = "steel-bolt", amount = 1},
      {type = "item", name = "copper-wire", amount = 2},
      {type = "fluid", name = "molten-red-alloy", amount = 1.8}
    },
	results = {
      {type = "item", name = "vacuum-tube", amount = 3}
    }
}



---RESIN CIRCUIT BOARD
create_recipe{
	recipe_name = "resin-circuit-board-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "plank", amount = 3},
      {type = "item", name = "sticky-resin", amount = 6}
    },
	results = {
      {type = "item", name = "resin-circuit-board", amount = 3}
    }
}
create_item{
	name = "resin-circuit-board",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 4,
	ingredients = {
      {type = "item", name = "plank", amount = 1},
      {type = "fluid", name = "glue", amount = 10}
    },
	results = {
      {type = "item", name = "resin-circuit-board", amount = 1}
    }
}
  
  
  
---RESIN PRINTED CIRCUIT BOARD
create_recipe{
	recipe_name = "resin-printed-circuit-board-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "resin-circuit-board", amount = 1},
      {type = "item", name = "fine-copper-wire", amount = 8}
    },
	results = {
      {type = "item", name = "resin-printed-circuit-board", amount = 1}
    }
}
create_item{
	name = "resin-printed-circuit-board",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
      {type = "item", name = "plank", amount = 1},
      {type = "item", name = "copper-foil", amount = 4},
      {type = "fluid", name = "glue", amount = 10}
    }
}
create_recipe{
	name = "resin-printed-circuit-board-advanced",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
      {type = "item", name = "wood-pulp", amount = 8},
      {type = "item", name = "copper-foil", amount = 16},
      {type = "fluid", name = "advanced-glue", amount = 40}
    },
	results = {
      {type = "item", name = "resin-printed-circuit-board", amount = 8}
    }
}
  


---RED ALLOY CABLE
create_recipe{
	recipe_name = "red-alloy-cable-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "red-alloy-wire", amount = 1},
      {type = "item", name = "rubber-sheet", amount = 1}
    },
	results = {
      {type = "item", name = "red-alloy-cable", amount = 1}
    }
}
create_item{
	name = "red-alloy-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
			{ type = "item", name = "red-alloy-wire", amount = 1 },
			{ type = "fluid", name = "liquid-rubber", amount = 14.4 }
		},
	results = {
			{ type = "item", name = "red-alloy-cable", amount = 1 }
		}
}
create_recipe{
	name = "red-alloy-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "red-alloy-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "red-alloy-cable", amount = 4 },
	},
}

  
  
---TRANSPORT BELT
create_recipe{
	recipe_name = "transport-belt",
	subgroup = "belt",
	ingredients = {
      {type = "item", name = "iron-gear-wheel", amount = 1},
      {type = "item", name = "iron-plate", amount = 1}
    },
	results = {
      {type = "item", name = "transport-belt", amount = 2}
    }
}
  
  
  
---UNDERGROUND BELT
create_recipe{
	recipe_name = "underground-belt",
	subgroup = "belt",
	ingredients = {
      {type = "item", name = "transport-belt", amount = 4},
      {type = "item", name = "iron-gear-wheel", amount = 4}
    },
	results = {
      {type = "item", name = "underground-belt", amount = 2}
    }
}


  
---SPLITTER
create_recipe{
	recipe_name = "splitter",
	subgroup = "belt",
	ingredients = {
      {type = "item", name = "transport-belt", amount = 2},
      {type = "item", name = "iron-gear-wheel", amount = 4}
    }
}
  
  
  
---WOODEN ELECTRIC POLE
create_recipe{
	recipe_name = "small-electric-pole",
	subgroup = "energy-pipe-distribution",
	ingredients = {
      {type = "item", name = "plank", amount = 4},
      {type = "item", name = "fine-copper-wire", amount = 2}
    }
} 



---PRIMITIVE ELECTRONIC CIRCUIT
create_item{
	name = "electronic-circuit",
	icon = ICON_PATH .. "lv-circuit.png",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
      {type = "item", name = "resistor", amount = 2},
      {type = "item", name = "steel-plate", amount = 1},
      {type = "item", name = "vacuum-tube", amount = 2},
      {type = "item", name = "resin-printed-circuit-board", amount = 1},
      {type = "item", name = "red-alloy-cable", amount = 3}
    },
	results = {
      {type = "item", name = "electronic-circuit", amount = 1}
    }
}
  


---AUTOMATION SCIENCE PACK
create_recipe{
	recipe_name = "automation-science-pack",
	energy_required = 10,
	order = "a",
	subgroup = "subgroup-science-packs",
	ingredients = {
      {type = "item", name = "copper-plate", amount = 1},
      {type = "item", name = "iron-gear-wheel", amount = 1}
    },
	results = {
      {type = "item", name = "automation-science-pack", amount = 1}
    }
}



---ULV MACHINE CASING
create_item{
	name = "ulv-machine-casing",
	ingredients = {
		{ type = "item", name = "iron-plate", amount = 8 },
	}
}



---ULV MACHINE HULL
create_item{
	name = "ulv-machine-hull",
	ingredients = {
		{ type = "item", name = "ulv-machine-casing", amount = 1 },
		{ type = "item", name = "red-alloy-cable", amount = 2 },
		{ type = "item", name = "plank", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 1 },
	}
}
