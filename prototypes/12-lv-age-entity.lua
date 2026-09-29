--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---LARGE BRONZE BOILER
create_item{
	name = "large-bronze-boiler-controller",
	ingredients = {
		{type = "item", name = "bronze-firebox-casing", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 4},
		{type = "item", name = "tin-cable", amount = 4},
	}
}
create_item{
	name = "large-bronze-boiler",
    place_result = "large-bronze-boiler",
    stack_size = 10,
	subgroup = "energy",
	ingredients = {
		{type = "item", name = "large-bronze-boiler-controller", amount = 1},
		{type = "item", name = "bronze-firebox-casing", amount = 5},
		{type = "item", name = "steam-machine-casing", amount = 23},
		{type = "item", name = "bronze-pipe-casing", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 5},
	}
}
data:extend({
  {
    type = "boiler",
    name = "large-bronze-boiler",
    icon = "__gregtorio-continued__/graphics/icons/large-bronze-boiler.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation" },
    minable = {mining_time = 0.3, result = "large-bronze-boiler"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 90 }
    },
	selection_box = { { -1.5, -2.0 }, {  1.5,  2.0 } },
	collision_box = { { -1.3, -1.8 }, {  1.3,  1.8 } },
	fast_replaceable_group = "fr-boiler",
    fluid_box = {
		volume = 200,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
		pipe_connections = {
		  { flow_direction = "input-output", direction = defines.direction.west, position = {-1, 0.5} },
		  { flow_direction = "input-output", direction = defines.direction.east, position = {1, 0.5} }
	  },
      production_type = "input",
      filter = "water"
    },
    output_fluid_box = {
		volume = 200,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
      pipe_connections = {
        { flow_direction = "output", position = {0, -1.5}, direction = defines.direction.north}
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
    energy_consumption = "4.8MW",
    target_temperature = 165,
	pictures = {
	  north = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/large-bronze-boiler.png",
			  width = 96,
			  height = 128,
			}
		  }
		}
	  },
	  east = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/large-bronze-boiler.png",
			  width = 96,
			  height = 128,
			}
		  }
		}
	  },
	  south = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/large-bronze-boiler.png",
			  width = 96,
			  height = 128,
			}
		  }
		}
	  },
	  west = {
		structure = {
		  layers = {
			{
			  filename = "__gregtorio-continued__/graphics/entity/large-bronze-boiler.png",
			  width = 96,
			  height = 128,
			}
		  }
		}
	  }
	},
    fire_glow_flicker_enabled = true,
	burning_cooldown = 20,
    mode = "output-to-separate-pipe"
  }
})



---LV STEAM TURBINE
create_item{
	name = "lv-steam-turbine",
    place_result = "lv-steam-turbine",
    stack_size = 10,
	subgroup = "energy",
	ingredients = {
		{type = "item", name = "lv-motor", amount = 2},
		{type = "item", name = "tin-rotor", amount = 2},
		{type = "item", name = "pipe", amount = 2},
		{type = "item", name = "tin-cable", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 1},
		{type = "item", name = "lv-machine-hull", amount = 1},
	}
}  
data:extend({  
  {
    type = "generator",
    name = "lv-steam-turbine",
    icon = "__gregtorio-continued__/graphics/icons/lv-steam-turbine.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = { mining_time = 0.3, result = "lv-steam-turbine" },
    max_health = 300,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 },
      { type = "impact", percent = 30 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
	fast_replaceable_group = "fr-steam-turbine",
    fluid_usage_per_tick = 0.2244,
    effectivity = 0.475,
    burns_fluid = true,
    maximum_temperature = 165,
	fluid_box = {
	  filter = "steam",
	  base_area = -1,
	  height = 2,
	  volume = 10,
		pipe_covers = pipecoverspictures(),
	    pipe_picture = assembler2pipepictures(),
	  production_type = "input-output",
	  pipe_connections = {
		{ position = {0, -1}, flow_direction = "input-output", direction = defines.direction.north },
		{ position = {0, 1}, flow_direction = "input-output", direction = defines.direction.south }
	  }
	},
    energy_source = {
      type = "electric",
      usage_priority = "secondary-output"
    },
    horizontal_animation = {
      layers = {
        {
          filename = "__gregtorio-continued__/graphics/entity/lv-steam-turbine/lv-steam-turbine-working.png",
		  width = 96,
		  height = 96,
          frame_count = 4,
          line_length = 4,
          shift = {0, 0},
        }
      }
    },
    vertical_animation = {
      layers = {
        {
          filename = "__gregtorio-continued__/graphics/entity/lv-steam-turbine/lv-steam-turbine-working.png",
		  width = 96,
		  height = 96,
          frame_count = 4,
          line_length = 4,
          shift = {0, 0},
        }
      }
    }
  }
})
  


---LV GAS TURBINE
create_burner_generator{
	name = "lv-gas-turbine",
	efficiency = 0.95,
	fuel_categories = { "gas-turbine-fuel" },
	max_power = EU32_LV,
	animation_speed = 0.1
}
create_item{
	name = "lv-gas-turbine",
    place_result = "lv-gas-turbine",
    stack_size = 10,
	ingredients = {
		{type = "item", name = "tin-rotor", amount = 3},
		{type = "item", name = "lv-motor", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "tin-cable", amount = 1},
	}
}



---LV SEMIFLUID GENERATOR
create_burner_generator{
	name = "lv-semifluid-generator",
	efficiency = 0.95,
	fuel_categories = { "semifluid-generator-fuel" },
	max_power = EU32_LV,
}
create_item{
	name = "lv-semifluid-generator",
    place_result = "lv-semifluid-generator",
    stack_size = 10,
	ingredients = {
		{type = "item", name = "lv-piston", amount = 2},
		{type = "item", name = "lv-motor", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 1},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "tin-cable", amount = 1},
		{type = "item", name = "large-steel-gear", amount = 2},
	}
}



---TRASH CAN   
create_item{
	name = "trash-can",
    place_result = "trash-can",
    stack_size = 10,
	ingredients = {
      {type = "item", name = "iron-plate", amount = 3},
      {type = "item", name = "wooden-chest", amount = 1},
      {type = "item", name = "iron-ingot", amount = 5},
	}
}
data:extend({
    {
        type = "infinity-container",
        gui_mode = "none",
        name = "trash-can",
        icon = "__gregtorio-continued__/graphics/entity/trash-can.png",
        icon_size = 32, icon_mipmaps = 4,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.1, result = "trash-can"},
        max_health = 100,
        fast_replaceable_group = "container",
        corpse = "wooden-chest-remnants",
        dying_explosion = "wooden-chest-explosion",
        collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        inventory_size = 16,
		erase_contents_when_entity_is_destroyed = true,
		remove_unfiltered_items = true,
        open_sound = { filename = "__base__/sound/wooden-chest-open.ogg", volume = 0.6 },
        close_sound = { filename = "__base__/sound/wooden-chest-close.ogg", volume = 0.6 },
		allowed_effects = {},
		picture = {
		    layers = {
				{
				  filename = "__gregtorio-continued__/graphics/entity/trash-can.png",
				  priority = "extra-high",
				  width = 32,
				  height = 32,
				},
		    },
		},
		erase_contents_when_mined = true,
}}) 



---FLUID TRASH CAN   
create_item{
	name = "fluid-trash-can",
    place_result = "fluid-trash-can",
    stack_size = 10,
	ingredients = {
      {type = "item", name = "trash-can", amount = 1},
      {type = "item", name = "empty-bucket", amount = 1},
	}
}
data:extend({
  {
    type = "furnace",
    name = "fluid-trash-can",
    icon = "__gregtorio-continued__/graphics/icons/fluid-trash-can.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "fluid-trash-can"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    crafting_categories = {"fluid-voiding-recipes"},
    crafting_speed = 1,
    source_inventory_size = 1,
    result_inventory_size = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
	graphics_set = {
	  animation = {
		layers = {
		  {
			filename = "__gregtorio-continued__/graphics/entity/fluid-trash-can.png",
			width = 32,
			height = 32,
			frame_count = 1,
			line_length = 1,
		  }
		}
	  }
	},
	fluid_boxes = {{
      production_type = "input",
      volume = 1000,
      pipe_connections = {
        { flow_direction = "input", direction = defines.direction.north, position = { 0, -0.25 } }
      },
      pipe_covers = pipecoverspictures(),
      pipe_picture = assembler2pipepictures()
    }}
}}) 



--- LV WIREMILL
make_electric_machine("lv-wiremill", "lv-wiremill", "lv-wiremill", { "lv-wiremill-recipes" }, "fr-wiremill", EU8_LV, 1, 3, 0.5, 3, 3 )
create_item{
	name = "lv-wiremill",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-motor", amount = 4},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-wiremill",
    stack_size = 10
}



--- LV BENDING MACHINE
make_electric_machine("lv-bending-machine", "lv-bending-machine", "lv-bending-machine", { "lv-bending-machine-recipes" }, "fr-bending-machine", EU24_LV, 1, 14, 0.5, 3, 3 )
create_item{
	name = "lv-bending-machine",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-piston", amount = 2},
		{type = "item", name = "lv-motor", amount = 2},
		{type = "item", name = "tin-cable", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-bending-machine",
	stack_size = 10
}



--- LV ROCK CRUSHER
make_electric_machine("lv-rock-crusher", "lv-rock-crusher", "lv-rock-crusher", { "lv-rock-crusher-recipes" }, "fr-rock-crusher", EU8_LV, 1, 5, 0.5, 3, 3 )
create_item{
	name = "lv-rock-crusher",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-piston", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-rock-crusher",
    stack_size = 10
}


--- LV LATHE
make_electric_machine("lv-lathe", "lv-lathe", "lv-lathe", { "lv-lathe-recipes" }, "fr-lathe", EU16_LV, 1, 9, 0.5, 3, 3 )
create_item{
	name = "lv-lathe",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-piston", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "tin-cable", amount = 3},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-lathe",
    stack_size = 10
}


--- LV MACERATOR
make_electric_machine("lv-macerator", "lv-macerator", "lv-macerator", { "lv-macerator-recipes" }, "fr-macerator", EU2_LV, 1, 6, 0.5, 3, 3 )
create_item{
	name = "lv-macerator",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "lv-piston", amount = 1},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "tin-cable", amount = 3},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-macerator",
    stack_size = 10
}


--- LV CENTRIFUGE
make_electric_machine("lv-centrifuge", "lv-centrifuge", "lv-centrifuge", { "lv-centrifuge-recipes" }, "fr-centrifuge", EU24_LV, 1, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-centrifuge",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-motor", amount = 2},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 4},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-centrifuge",
    stack_size = 10
}


--- LV AIR COLLECTOR
make_electric_machine("lv-air-collector", "lv-air-collector", "lv-air-collector", { "lv-air-collector-recipes" }, "fr-air-collector", EU8_LV, 1, 1, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-air-collector",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "filter", amount = 1},
		{type = "item", name = "lv-pump", amount = 2},
		{type = "item", name = "iron-stick", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-air-collector",
    stack_size = 10
}



--- LV EXTRACTOR
make_electric_machine("lv-extractor", "lv-extractor", "lv-extractor", { "lv-extractor-recipes", "lv-extractor-recipes" }, "fr-extractor", EU12_LV, 1, 5, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-extractor",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "lv-piston", amount = 1},
	},
	place_result = "lv-extractor",
    stack_size = 10
}



--- LV ELECTROLYZER
make_electric_machine("lv-electrolyzer", "lv-electrolyzer", "lv-electrolyzer", { "lv-electrolyzer-recipes" }, "fr-electrolyzer", EU30_LV, 1, 2, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-electrolyzer",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "gold-wire", amount = 4},
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "tin-cable", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-electrolyzer",
    stack_size = 10
}



--- LV ASSEMBLING MACHINE
make_electric_machine("lv-assembling-machine", "lv-assembling-machine", "lv-assembling-machine", { "lv-assembling-machine-recipes", "crafting-or-assembling-recipes" }, "fr-assembling-machine", EU12_LV, 1, 19, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "lv-assembling-machine",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-robot-arm", amount = 2},
		{type = "item", name = "lv-conveyor-module", amount = 2},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-assembling-machine",
    stack_size = 10
}


--- LV CHEMICAL REACTOR
make_electric_machine("lv-chemical-reactor", "lv-chemical-reactor", "lv-chemical-reactor", { "lv-chemical-reactor-recipes" }, "fr-chemical-reactor", EU16_LV, 1, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-chemical-reactor",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "tin-rotor", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
	},
	place_result = "lv-chemical-reactor",
    stack_size = 10
}



--- LV CUTTING MACHINE
make_electric_machine("lv-cutting-machine", "lv-cutting-machine", "lv-cutting-machine", { "lv-cutting-machine-recipes" }, "fr-cutting-machine", EU16_LV, 1, 14, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "lv-cutting-machine",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "lv-conveyor-module", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "diamond-sawblade", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
	},
	place_result = "lv-cutting-machine",
    stack_size = 10
}


--- LV CANNING MACHINE
make_electric_machine("lv-canning-machine", "lv-canning-machine", "lv-canning-machine", { "lv-canning-machine-recipes" }, "fr-canning-machine", EU2_LV, 1, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-canning-machine",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
	},
	place_result = "lv-canning-machine",
    stack_size = 10
}


--- LV MIXER
make_electric_machine("lv-mixer", "lv-mixer", "lv-mixer", { "lv-mixer-recipes" }, "fr-mixer", EU24_LV, 1, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-mixer",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 4},
		{type = "item", name = "tin-rotor", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
	},
	place_result = "lv-mixer",
    stack_size = 10
}


--- LV DISTILLERY
make_electric_machine("lv-distillery", "lv-distillery", "lv-distillery", { "lv-distillation-recipes" }, "fr-distillery", EU8_LV, 1, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "lv-distillery",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
	},
	place_result = "lv-distillery",
    stack_size = 10
}


--- LV ORE WASHER
make_electric_machine("lv-ore-washer", "lv-ore-washer", "lv-ore-washer", { "lv-ore-washer-recipes" }, "fr-ore-washer", EU8_LV, 1, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "lv-ore-washer",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "tin-rotor", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
	},
	place_result = "lv-ore-washer",
    stack_size = 10
}



--- LV FLUID SOLIDIFIER
make_electric_machine("lv-fluid-solidifier", "lv-fluid-solidifier", "lv-fluid-solidifier", { "lv-fluid-solidifier-recipes" }, "fr-fluid-solidifier", EU8_LV, 1, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "lv-fluid-solidifier",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-pump", amount = 2},
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "wooden-chest", amount = 1},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "lv-fluid-solidifier",
    stack_size = 10
}



--- LV CHEMICAL BATH
make_electric_machine("lv-chemical-bath", "lv-chemical-bath", "lv-chemical-bath", { "lv-chemical-bath-recipes" }, "fr-chemical-bath", EU12_LV, 1, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "lv-chemical-bath",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "lv-conveyor-module", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "tin-cable", amount = 1},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-chemical-bath",
    stack_size = 10
}



--- LV POLARIZER
make_electric_machine("lv-polarizer", "lv-polarizer", "lv-polarizer", { "lv-polarizer-recipes" }, "fr-polarizer", EU30_LV, 1, 1, 0.5, 3, 3 )
create_item{
	name = "lv-polarizer",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "iron-stick", amount = 2},
		{type = "item", name = "tin-wire", amount = 8},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-polarizer",
    stack_size = 10
}



--- LV CIRCUIT ASSEMBLER
make_electric_machine("lv-circuit-assembler", "lv-circuit-assembler", "lv-circuit-assembler", { "lv-circuit-assembler-recipes" }, "fr-circuit-assembler", EU24_LV, 1, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "lv-circuit-assembler",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-robot-arm", amount = 1},
		{type = "item", name = "lv-emitter", amount = 1},
		{type = "item", name = "lv-conveyor-module", amount = 2},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-circuit-assembler",
    stack_size = 10
}



--- LV ALLOY SMELTER
make_electric_machine("lv-alloy-smelter", "lv-alloy-smelter", "lv-alloy-smelter", { "lv-alloy-smelter-recipes" }, "fr-alloy-smelter", EU24_LV, 1, 1, 0.5, 3, 3 )
create_item{
	name = "lv-alloy-smelter",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "copper-wire", amount = 16},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-alloy-smelter",
    stack_size = 10
}



--- LV COMPRESSOR
make_electric_machine("lv-compressor", "lv-compressor", "lv-compressor", { "lv-compressor-recipes" }, "fr-compressor", EU2_LV, 1, 9, 0.5, 3, 3 )
create_item{
	name = "lv-compressor",
	subgroup = "lv-age-production-machine",
	ingredients = {
		{type = "item", name = "lv-piston", amount = 2},
		{type = "item", name = "tin-cable", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 1},
	},
	place_result = "lv-compressor",
    stack_size = 10
}



---LV GREENHOUSE
make_electric_machine("lv-greenhouse", "greenhouse", "greenhouse", { "greenhouse-recipes" }, "fr-greenhouse", EU16_LV, 1, 1, 0.5, 5, 5, {
    fluid_port(-1, -2, "input", defines.direction.north),
    fluid_port( 1, -2, "input", defines.direction.north)  
})
create_item{
	name = "greenhouse-controller",
	ingredients = {
		{ type = "item", name = "tempered-glass", amount = 2 },
		{ type = "item", name = "advanced-circuit", amount = 2 },
		{ type = "item", name = "tin-cable", amount = 3 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 1 },
		{ type = "item", name = "lv-pump", amount = 1 },
	}
}
create_item{
	name = "lv-greenhouse",
	icon = ICON_PATH .. "greenhouse.png",
	ingredients = {
		{ type = "item", name = "greenhouse-controller", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
		{ type = "item", name = "lv-energy-hatch", amount = 1 },
		{ type = "item", name = "tempered-glass", amount = 69 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 35 },
	},
	place_result = "lv-greenhouse",
    stack_size = 10
}