--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--- CRAFTING TABLE
create_item{
	name = "crafting-table",
    subgroup = "stone-age-production-machine",
    place_result = "crafting-table",
	ingredients = {
		{type = "item", name = "flint", amount = 2 },
		{type = "item", name = "wood", amount = 2 },
    }
}
data:extend({
  {
    type = "assembling-machine",
    name = "crafting-table",
    icon = "__gregtorio-continued__/graphics/icons/crafting-table.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "crafting-table"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "fr-assembling-machine",
    crafting_categories = { "crafting-or-assembling-recipes", "crafting-table-recipes" },
    crafting_speed = 1,
    energy_usage = "25kW",
    energy_source = {
      type = "burner",
      fuel_categories = { "manual-labor" },
      effectivity = 1.0,
      fuel_inventory_size = 1,
      emissions_per_minute = { pollution = 0 }
    },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__gregtorio-continued__/graphics/entity/crafting-table.png",
            width = 180,
            height = 180,
            frame_count = 1,
            line_length = 1,
            shift = {0, 0},
            scale = 0.5
          }
        }
      }
    }
  }
})










---FURANCE
create_item{
	name = "stone-furnace",
	recipe_name = "stone-furnace",
	icon = ICON_PATH .. "furnace.png",
    subgroup = "smelting-machine",
    place_result = "stone-furnace",
	ingredients = {
		{type = "item", name = "stone", amount = 8 },
    }
}
create_recipe{
	recipe_name = "furnace-crafting-table",
    category = "crafting-table-recipes",
    subgroup = "smelting-machine",
	ingredients = {
		{type = "item", name = "flint", amount = 3 },
		{type = "item", name = "stone", amount = 6 },
    },
    results = {
		{type = "item", name = "stone-furnace", amount = 1 }
    }
}
data:extend({
	{
    type = "furnace",
    name = "stone-furnace",
    icon = "__gregtorio-continued__/graphics/icons/furnace.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "stone-furnace"},
    max_health = 200,
    corpse = "small-remnants",
	collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    fast_replaceable_group = "fr-furnace",
    crafting_categories = {"smelting"},
    result_inventory_size = 1,
    energy_usage = "50kW",
    crafting_speed = 1,
    source_inventory_size = 1,
    fast_replaceable_group = "furnace",
    energy_source = {
      type = "burner",
	  fuel_categories = { "chemical" },
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = { pollution = 2 },
    },
    graphics_set = {
	  animation = {
		layers = {
		  {
			filename = "__gregtorio-continued__/graphics/entity/furnace.png",
			width = 128,
			height = 128,
			frame_count = 1,
			line_length = 1,
			shift = {0, 0},
			scale = 0.5
		  }
		}
	  }
	}
  }
})










---IRON FURNACE
create_item{
	name = "iron-furnace",
    subgroup = "smelting-machine",
	category = "lv-assembling-machine-recipes",
    place_result = "iron-furnace",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 5},
		{type = "item", name = "stone-furnace", amount = 1},
    }
}
create_recipe{
	recipe_name = "iron-furnace-crafting-table",
    category = "crafting-table-recipes",
    subgroup = "smelting-machine",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 7},
		{type = "item", name = "stone-furnace", amount = 1},
    },
    results = {
		{type = "item", name = "iron-furnace", amount = 1 }
    }
}
data:extend({
  {
    type = "furnace",
    name = "iron-furnace",
    icon = "__gregtorio-continued__/graphics/icons/iron-furnace.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "iron-furnace"},
    max_health = 200,
    corpse = "small-remnants",
	collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    fast_replaceable_group = "fr-furnace",
    crafting_categories = {"smelting"},
    result_inventory_size = 1,
    energy_usage = "100kW",
    crafting_speed = 2,
    source_inventory_size = 1,
    fast_replaceable_group = "furnace",
    energy_source = {
      type = "burner",
	  fuel_categories = { "chemical" },
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = { pollution = 2 },
    },
    graphics_set = {
	  animation = {
		layers = {
		  {
			filename = "__gregtorio-continued__/graphics/entity/iron-furnace.png",
			width = 128,
			height = 128,
			frame_count = 1,
			line_length = 1,
			shift = {0, 0},
			scale = 0.5
		  }
		}
	  }
	}
  }
})









---MANUAL MINE
create_item{
	name = "manual-mine",
    subgroup = "stone-age-production-machine",
    place_result = "manual-mine",
	stack_size = 10,
	icon_size = 64,
	ingredients = {
      {type = "item", name = "wooden-pickaxe", amount = 2},
      {type = "item", name = "manual-labor", amount = 10},
    }
}
data:extend({
{
    type = "assembling-machine",
    name = "manual-mine",
    icon = "__gregtorio-continued__/graphics/icons/manual-mine.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "manual-mine"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    crafting_categories = {"manual-mine-recipes"},
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
	graphics_set = {
	  animation = {
		layers = {
		  {
			filename = "__gregtorio-continued__/graphics/entity/manual-mine.png",
			width = 320,
			height = 320,
			frame_count = 1,
			line_length = 1,
			shift = {0, 0},
			scale = 0.5,
		  }
		}
	  }
	}
  }
})



--- MANUAL DIGSITE
create_item{
	name = "manual-digsite",
    subgroup = "stone-age-production-machine",
    place_result = "manual-digsite",
	stack_size = 10,
	icon_size = 64,
	ingredients = {
		{type = "item", name = "manual-labor", amount = 4},
    }
}
data:extend({
  {
    type = "assembling-machine",
    name = "manual-digsite",
    icon = "__gregtorio-continued__/graphics/icons/manual-digsite.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "manual-digsite"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    crafting_categories = {"manual-digsite-recipes"},
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__gregtorio-continued__/graphics/entity/manual-digsite.png",
            width = 320,
            height = 320,
            frame_count = 1,
            line_length = 1,
            shift = {0, 0},
            scale = 0.5
          }
        }
      }
    }
  }
})



---MANUAL RESEARCH LAB
create_item{
	name = "manual-research-lab",
    subgroup = "stone-age-production-machine",
    place_result = "manual-research-lab",
	stack_size = 10,
	icon_size = 64,
	ingredients = {
		{type = "item", name = "plank", amount = 5},
		{type = "item", name = "stick", amount = 3},
		{type = "item", name = "crafting-table", amount = 1}
    }
}
data:extend({
  {
    type = "lab",
    name = "manual-research-lab",
    icon = "__gregtorio-continued__/graphics/icons/manual-research-lab.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.3, result = "manual-research-lab"},
    max_health = 250,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-2.3, -2.3}, {2.3, 2.3}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    energy_usage = "100kW",
    researching_speed = 1,
    inputs = { "automation-science-pack" },
    energy_source = {
      type = "burner",
      fuel_categories = { "manual-labor" },
      fuel_inventory_size = 1,
      effectivity = 1,
      emissions_per_minute = { pollution = 0.1 }
    },
    on_animation = {
      layers = {
        {
          filename = "__gregtorio-continued__/graphics/entity/manual-research-lab.png",
          width = 320,
          height = 320,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          scale = 0.5
        }
      }
    },
    off_animation = {
      layers = {
        {
          filename = "__gregtorio-continued__/graphics/entity/manual-research-lab.png",
          width = 320,
          height = 320,
          frame_count = 1,
          line_length = 1,
          shift = {0, 0},
          scale = 0.5
        }
      }
    }
  }
})



---SMALL COAL BOILER
create_item{
	name = "small-coal-boiler",
    subgroup = "energy",
    place_result = "small-coal-boiler",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "bronze-plate", amount = 5},
		{type = "item", name = "brick-block", amount = 2},
		{type = "item", name = "iron-furnace", amount = 1}
    }
}
data:extend({
  {
    type = "boiler",
    name = "small-coal-boiler",
    icon = "__gregtorio-continued__/graphics/icons/small-coal-boiler.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.3, result = "small-coal-boiler"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 90 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box = {
		volume = 200,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
		pipe_connections = {
		  { flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0} },
		  { flow_direction = "input-output", direction = defines.direction.east, position = {1, 0} }
	  },
      production_type = "input",
      filter = "water"
    },
    output_fluid_box = {
		volume = 200,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
      pipe_connections = {
        { flow_direction = "output", position = {0, -1.0}, direction = defines.direction.north}
      },
      production_type = "output",
      filter = "steam"
    },
    energy_source = {
      type = "burner",
      fuel_categories = { "chemical" },
      effectivity = 1,
      fuel_inventory_size = 1,
      emissions_per_minute = { pollution = 6 }
    },
    energy_consumption = "36kW",
    target_temperature = 165,
	pictures = {
	  north = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/small-coal-boiler/small-coal-boiler.png",
			  width = 96,
			  height = 96,
			  shift = util.by_pixel(0, 0),
			  scale = 1
			}
		  }
		}
	  },
	  east = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/small-coal-boiler/small-coal-boiler.png",
			  width = 96,
			  height = 96,
			  shift = util.by_pixel(0, 0),
			  scale = 1
			}
		  }
		}
	  },
	  south = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/small-coal-boiler/small-coal-boiler.png",
			  width = 96,
			  height = 96,
			  shift = util.by_pixel(0, 0),
			  scale = 1
			}
		  }
		}
	  },
	  west = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/small-coal-boiler/small-coal-boiler.png",
			  width = 96,
			  height = 96,
			  shift = util.by_pixel(0, 0),
			  scale = 1
			}
		  }
		}
	  }
	},
    fire_glow_flicker_enabled = false,
	burning_cooldown = 20,
    mode = "output-to-separate-pipe"
  }
})










function make_steam_machine(name, entity_path, category, fast_replace, energy, frames, anispeed )
  local machine = {
    type = "assembling-machine",
    name = name,
    icon = "__gregtorio-continued__/graphics/icons/" .. name .. ".png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = { mining_time = 0.5, result = name },
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	fast_replaceable_group = fast_replace,
    crafting_categories = { category },
    crafting_speed = 0.5,
    energy_usage = energy,
    energy_source = {
      type = "fluid",
      burns_fluid = true,
      scale_fluid_usage = true,
      emissions_per_minute = { pollution = 0.5 },
      fluid_box = {
        filter = "steam",
        production_type = "input",
        volume = 100,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
        pipe_connections = {
          { position = {-1, 0}, direction = defines.direction.west },
          { position = {1, 0}, direction = defines.direction.east }
        }
      }
    },
    allowed_effects = {},
	    graphics_set = {
		idle_animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/" .. entity_path .. "/" .. entity_path .. "-idle.png",
			  width = 96,
			  height = 96,
			  frame_count = 1,
			  repeat_count = frames,
			  shift = {0, 0},
			}
		  }
		},
		animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/" .. entity_path .. "/" .. entity_path .. "-working.png",
			  width = 96,
			  height = 96,
			  frame_count = frames,
			  line_length = 1,
			  animation_speed = anispeed,
			  shift = {0, 0},
			}
		  }
		}
	},
  }

  data:extend({ machine })
end









---STEAM ALLOY SMELTER			CONSUMES 16MB/T
make_steam_machine("steam-alloy-smelter", "steam-alloy-smelter", "lv-alloy-smelter-recipes", "fr-alloy-smelter", "320kW", 1, 1 )
create_item{
	name = "steam-alloy-smelter",
    subgroup = "steam-age-production-machine",
    place_result = "steam-alloy-smelter",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "pipe", amount = 6},
		{type = "item", name = "bronze-plate", amount = 5},
		{type = "item", name = "brick-block", amount = 3},
		{type = "item", name = "stone-furnace", amount = 2}
    }
}



---STEAM COMPRESSOR			CONSUMES 2MB/T
make_steam_machine("steam-compressor", "steam-compressor", "lv-compressor-recipes", "fr-compressor", "40kW", 9, 0.5 )
create_item{
	name = "steam-compressor",
    subgroup = "steam-age-production-machine",
    place_result = "steam-compressor",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "pipe", amount = 6},
		{type = "item", name = "bronze-plate", amount = 8},
		{type = "item", name = "piston", amount = 2}
    }
}

  
  
---STEAM FORGE HAMMER			CONSUMES 16MB/T
make_steam_machine("steam-forge-hammer", "steam-forge-hammer", "lv-forge-hammer-recipes", "fr-forge-hammer", "320kW", 5, 0.5)
create_item{
	name = "steam-forge-hammer",
    subgroup = "steam-age-production-machine",
    place_result = "steam-forge-hammer",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "pipe", amount = 6},
		{type = "item", name = "bronze-plate", amount = 8 },
		{type = "item", name = "piston", amount = 1},
		{type = "item", name = "anvil", amount = 1}
    }
}

  
  
---STEAM MACERATOR			CONSUMES 2MB/T
make_steam_machine("steam-macerator", "steam-macerator", "lv-macerator-recipes", "fr-macerator", "40kW", 6, 0.5)
create_item{
	name = "steam-macerator",
    subgroup = "steam-age-production-machine",
    place_result = "steam-macerator",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "pipe", amount = 4},
		{type = "item", name = "bronze-plate", amount = 8 },
		{type = "item", name = "piston", amount = 2},
		{type = "item", name = "diamond", amount = 2}
    }
}



---STEAM EXTRACTOR			CONSUMES 2MB/T
make_steam_machine("steam-extractor", "steam-extractor", "lv-extractor-recipes", "fr-extractor", "40kW", 5, 0.5)
create_item{
	name = "steam-extractor",
    subgroup = "steam-age-production-machine",
    place_result = "steam-extractor",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "bronze-plate", amount = 8 },
		{type = "item", name = "pipe", amount = 6},
		{type = "item", name = "piston", amount = 1},
		{type = "item", name = "glass", amount = 1}
    }
}
 
  
---COKE OVEN
create_item{
	name = "coke-oven",
    subgroup = "steam-age-production-machine",
    place_result = "coke-oven",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "coke-oven-block", amount = 27},
    }
}
data:extend({
  {
    type = "assembling-machine",
    name = "coke-oven",
    icon = "__gregtorio-continued__/graphics/icons/coke-oven.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "coke-oven"},
    max_health = 300,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    crafting_categories = {"coke-oven-recipes"},
    crafting_speed = 1,
    energy_usage = "1kW",
    energy_source = {
      type = "void"
    },
    ingredient_count = 2,
    module_specification = {
      module_slots = 0
    },
    allowed_effects = {},
    graphics_set = {
		idle_animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/coke-oven/coke-oven-idle.png",
			  width = 96,
			  height = 96,
			  frame_count = 1,
			  repeat_count = 2,
			  shift = {0, 0},
			}
		  }
		},
		animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/coke-oven/coke-oven-working.png",
			  width = 96,
			  height = 96,
			  frame_count = 2,
			  line_length = 2,
			  animation_speed = 0.5,
			  shift = {0, 0}
			}
		  }
		}
	},
	fluid_boxes = {
		{
			production_type = "output",
			volume = 1000,
			pipe_connections = {
				{ flow_direction = "output", direction = defines.direction.north, position = { -1, -1 } }
			},
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures()
		},
		{
			production_type = "output",
			volume = 1000,
			pipe_connections = {
				{ flow_direction = "output", direction = defines.direction.north, position = { 1, -1 } }
			},
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures()
		}
	},
    working_sound = {
      sound = { filename = "__base__/sound/furnace.ogg" },
      apparent_volume = 1.5
    }
  }
})
  
  
  
---PRIMITIVE BLAST FURNACE
create_item{
	name = "primitive-blast-furnace",
    subgroup = "steam-age-production-machine",
    place_result = "primitive-blast-furnace",
	stack_size = 10,
	ingredients = {
		{type = "item", name = "firebrick-block", amount = 36},
		{type = "item", name = "iron-furnace", amount = 4},
    }
}
data:extend({
  {
    type = "assembling-machine",
    name = "primitive-blast-furnace",
    icon = "__gregtorio-continued__/graphics/icons/primitive-blast-furnace.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation" },
    minable = {mining_time = 0.2, result = "primitive-blast-furnace"},
    max_health = 300,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-1.3, -1.8}, {1.3, 1.8}},
    selection_box = {{-1.5, -2.0}, {1.5, 2.0}},
    fast_replaceable_group = "fr-electric-blast-furnace",
    crafting_categories = {"pbf-recipes"},
    crafting_speed = 1,
    energy_usage = "1kW",
    energy_source = {
      type = "void"
    },
    ingredient_count = 2,
    module_specification = {
      module_slots = 0
    },
    allowed_effects = {},
    graphics_set = {
		idle_animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/primitive-blast-furnace/pbf-idle.png",
			  width = 96,
			  height = 128,
			  frame_count = 1,
			  repeat_count = 2,
			  shift = {0, 0},
			}
		  }
		},
		animation = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/primitive-blast-furnace/pbf-working.png",
			  width = 96,
			  height = 128,
			  frame_count = 2,
			  line_length = 2,
			  animation_speed = 0.5,
			  shift = {0, 0}
			}
		  }
		}
	},
    working_sound = {
      sound = { filename = "__base__/sound/furnace.ogg" },
      apparent_volume = 1.5
    }
  }
})