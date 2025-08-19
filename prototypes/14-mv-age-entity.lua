--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---DIAMOND CHEST
create_item{
	name = "diamond-chest",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	subgroup = "storage",
	place_result = "diamond-chest",
	ingredients = {
		{type = "item", name = "steel-chest", amount = 1},
		{type = "item", name = "diamond-plate", amount = 2},
    }
}
data:extend({
  {
    type = "container",
    name = "diamond-chest",
    icon = "__Gregtorio__/graphics/icons/diamond-chest.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.2, result = "diamond-chest"},
    max_health = 400,
    corpse = "steel-chest-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    inventory_size = 64,
    picture = {
      filename = "__Gregtorio__/graphics/entity/diamond-chest.png",
      priority = "extra-high",
      width = 32,
      height = 32
    }
  }
})



---LARGE STEEL BOILER
create_item{
	name = "large-steel-boiler-controller",
	ingredients = {
		{type = "item", name = "steel-firebox-casing", amount = 1},
		{type = "item", name = "processing-unit", amount = 4},
		{type = "item", name = "copper-cable", amount = 4},
	}
}
create_item{
	name = "large-steel-boiler",
	stack_size = 10,
	place_result = "large-steel-boiler",
	ingredients = {
		{type = "item", name = "large-steel-boiler-controller", amount = 1},
		{type = "item", name = "steel-firebox-casing", amount = 5},
		{type = "item", name = "solid-steel-machine-casing", amount = 23},
		{type = "item", name = "steel-pipe-casing", amount = 2},
		{type = "item", name = "lv-machine-hull", amount = 5}
	}
}    
data:extend({
{
    type = "boiler",
    name = "large-steel-boiler",
    icon = "__Gregtorio__/graphics/icons/large-steel-boiler.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation" },
    minable = {mining_time = 0.3, result = "large-steel-boiler"},
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
    energy_consumption = "10.8MW",
    target_temperature = 165,
	pictures = {
	  north = {
		structure = {
		  layers = {
			{
			  filename = "__Gregtorio__/graphics/entity/large-steel-boiler.png",
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
			  filename = "__Gregtorio__/graphics/entity/large-steel-boiler.png",
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
			  filename = "__Gregtorio__/graphics/entity/large-steel-boiler.png",
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
			  filename = "__Gregtorio__/graphics/entity/large-steel-boiler.png",
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



---MV STEAM TURBINE
create_item{
	name = "mv-steam-turbine",
	ingredients = {
		{type = "item", name = "mv-motor", amount = 2},
		{type = "item", name = "bronze-rotor", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-steam-turbine",
	stack_size = 10
}
data:extend({
  {
    type = "generator",
    name = "mv-steam-turbine",
    icon = "__Gregtorio__/graphics/icons/mv-steam-turbine.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    minable = { mining_time = 0.3, result = "mv-steam-turbine" },
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
    fluid_usage_per_tick = 0.6361,
    effectivity = 0.45,
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
          filename = "__Gregtorio__/graphics/entity/mv-steam-turbine/mv-steam-turbine-working.png",
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
          filename = "__Gregtorio__/graphics/entity/mv-steam-turbine/mv-steam-turbine-working.png",
		  width = 96,
		  height = 96,
          frame_count = 4,
          line_length = 4,
          shift = {0, 0},
        }
      }
    }
  },  
})



---MV GAS TURBINE
create_burner_generator{
	name = "mv-gas-turbine",
	efficiency = 0.90,
	fuel_categories = { "gas-turbine-fuel" },
	max_power = EU32_MV,
}
create_item{
	name = "mv-gas-turbine",
	ingredients = {
		{type = "item", name = "bronze-rotor", amount = 3},
		{type = "item", name = "mv-motor", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "copper-cable", amount = 1},
    },
	place_result = "mv-gas-turbine",
	stack_size = 10
}



---MV COMBUSTION GENERATOR
create_burner_generator{
	name = "mv-combustion-generator",
	efficiency = 0.90,
	fuel_categories = { "combustion-generator-fuel" },
	max_power = EU32_MV,
}
create_item{
	name = "mv-combustion-generator",
	ingredients = {
      {type = "item", name = "mv-piston", amount = 2},
      {type = "item", name = "advanced-circuit", amount = 1},
      {type = "item", name = "mv-motor", amount = 2},
      {type = "item", name = "mv-machine-hull", amount = 1},
      {type = "item", name = "copper-cable", amount = 1},
      {type = "item", name = "large-aluminium-gear", amount = 2},
    },
	place_result = "mv-combustion-generator",
	stack_size = 10
}



---MV SEMIFLUID GENERATOR
create_burner_generator{
	name = "mv-semifluid-generator",
	efficiency = 0.90,
	fuel_categories = { "semifluid-generator-fuel" },
	max_power = EU32_MV,
}
create_item{
	name = "mv-semifluid-generator",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 2},
		{type = "item", name = "mv-motor", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 1},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "copper-cable", amount = 1},
		{type = "item", name = "large-eglin-steel-gear", amount = 2},
    },
	place_result = "mv-semifluid-generator",
	stack_size = 10
}



--- (NAME, ICON_PATH, ENTITY_PATH, CATEGORY, ENERGY, CRAFTSPEED, FRAMES, ANISPEED, LENGTH, WIDTH, FLUID_CONFIG)
--- MV WIREMILL
make_electric_machine("mv-wiremill", "mv-wiremill", "mv-wiremill", { "lv-wiremill-recipes", "mv-wiremill-recipes" }, "fr-wiremill", EU8_MV, 2, 3, 0.5, 3, 3 )
create_item{
	name = "mv-wiremill",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-motor", amount = 4},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-wiremill",
    stack_size = 10
}



--- MV BENDING MACHINE
make_electric_machine("mv-bending-machine", "mv-bending-machine", "mv-bending-machine", { "lv-bending-machine-recipes", "mv-bending-machine-recipes" }, "fr-bending-machine", EU24_MV, 2, 14, 0.5, 3, 3 )
create_item{
	name = "mv-bending-machine",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 2},
		{type = "item", name = "mv-motor", amount = 2},
		{type = "item", name = "copper-cable", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-bending-machine",
	stack_size = 10
}



--- MV EXTRUDER
make_electric_machine("mv-extruder", "mv-extruder", "mv-extruder", { "mv-extruder-recipes" }, "fr-extruder", EU16_MV, 2, 5, 0.5, 3, 3 )
create_item{
	name = "mv-extruder",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 1},
		{type = "item", name = "cupronickel-wire", amount = 16},
		{type = "item", name = "pipe", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "mv-extruder",
	stack_size = 10
}



--- MV ROCK CRUSHER
make_electric_machine("mv-rock-crusher", "mv-rock-crusher", "mv-rock-crusher", { "lv-rock-crusher-recipes", "mv-rock-crusher-recipes" }, "fr-rock-crusher", EU8_MV, 2, 5, 0.5, 3, 3 )
create_item{
	name = "mv-rock-crusher",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-rock-crusher",
    stack_size = 10
}



--- MV LATHE
make_electric_machine("mv-lathe", "mv-lathe", "mv-lathe", { "lv-lathe-recipes", "mv-lathe-recipes" }, "fr-lathe", EU16_MV, 2, 9, 0.5, 3, 3 )
create_item{
	name = "mv-lathe",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
		{type = "item", name = "copper-cable", amount = 3},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-lathe",
    stack_size = 10
}



--- MV MACERATOR
make_electric_machine("mv-macerator", "mv-macerator", "mv-macerator", { "lv-macerator-recipes", "mv-macerator-recipes" }, "fr-macerator", EU2_MV, 2, 6, 0.5, 3, 3 )
create_item{
	name = "mv-macerator",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-motor", amount = 1},
		{type = "item", name = "mv-piston", amount = 1},
		{type = "item", name = "diamond", amount = 1},
		{type = "item", name = "copper-cable", amount = 3},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-macerator",
    stack_size = 10
}



--- MV CENTRIFUGE
make_electric_machine("mv-centrifuge", "mv-centrifuge", "mv-centrifuge", { "lv-centrifuge-recipes", "mv-centrifuge-recipes" }, "fr-centrifuge", EU24_MV, 2, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-centrifuge",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-motor", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 4},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-centrifuge",
    stack_size = 10
}



--- MV AIR COLLECTOR
make_electric_machine("mv-air-collector", "mv-air-collector", "mv-air-collector", { "lv-air-collector-recipes" }, "fr-air-collector", EU8_MV, 2, 1, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-air-collector",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "filter", amount = 1},
		{type = "item", name = "iron-stick", amount = 4},
		{type = "item", name = "advanced-circuit", amount = 1},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-pump", amount = 2},
	},
	place_result = "mv-air-collector",
    stack_size = 10
}



--- MV EXTRACTOR
make_electric_machine("mv-extractor", "mv-extractor", "mv-extractor", { "lv-extractor-recipes", "mv-extractor-recipes" }, "fr-extractor", EU12_MV, 2, 5, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-extractor",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-pump", amount = 1},
		{type = "item", name = "mv-piston", amount = 1},
	},
	place_result = "mv-extractor",
    stack_size = 10
}


--- MV ELECTROLYZER
make_electric_machine("mv-electrolyzer", "mv-electrolyzer", "mv-electrolyzer", { "lv-electrolyzer-recipes", "mv-electrolyzer-recipes" }, "fr-electrolyzer", EU30_MV, 2, 2, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-electrolyzer",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "silver-wire", amount = 4},
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "copper-cable", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-electrolyzer",
    stack_size = 10
}




--- MV ASSEMBLING MACHINE
make_electric_machine("mv-assembling-machine", "mv-assembling-machine", "mv-assembling-machine", { "lv-assembling-machine-recipes", "crafting-or-assembling-recipes", "mv-assembling-machine-recipes" }, "fr-assembling-machine", EU12_MV, 2, 19, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "mv-assembling-machine",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-robot-arm", amount = 2},
		{type = "item", name = "mv-conveyor-module", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-assembling-machine",
    stack_size = 10
}



--- MV CHEMICAL REACTOR
make_electric_machine("mv-chemical-reactor", "mv-chemical-reactor", "mv-chemical-reactor", { "lv-chemical-reactor-recipes", "mv-chemical-reactor-recipes" }, "fr-chemical-reactor", EU16_MV, 2, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-chemical-reactor",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "bronze-rotor", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
	},
	place_result = "mv-chemical-reactor",
    stack_size = 10
}



--- MV CUTTING MACHINE
make_electric_machine("mv-cutting-machine", "mv-cutting-machine", "mv-cutting-machine", { "lv-cutting-machine-recipes", "mv-cutting-machine-recipes" }, "fr-cutting-machine", EU16_MV, 2, 14, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "mv-cutting-machine",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "mv-conveyor-module", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
		{type = "item", name = "diamond-sawblade", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
	},
	place_result = "mv-cutting-machine",
    stack_size = 10
}



--- MV CANNING MACHINE
make_electric_machine("mv-canning-machine", "mv-canning-machine", "mv-canning-machine", { "lv-canning-machine-recipes", "mv-canning-machine-recipes" }, "fr-canning-machine", EU2_MV, 2, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-canning-machine",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "mv-pump", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
	},
	place_result = "mv-canning-machine",
    stack_size = 10
}



--- MV MIXER
make_electric_machine("mv-mixer", "mv-mixer", "mv-mixer", { "lv-mixer-recipes", "mv-mixer-recipes" }, "fr-mixer", EU24_MV, 2, 6, 0.5, 3, 3,{
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-mixer",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 4},
		{type = "item", name = "bronze-rotor", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
	},
	place_result = "mv-mixer",
    stack_size = 10
}



--- MV DISTILLERY
make_electric_machine("mv-distillery", "mv-distillery", "mv-distillery", { "lv-distillation-recipes", "mv-distillation-recipes" }, "fr-distillery", EU8_MV, 2, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-distillery",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-pump", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
	},
	place_result = "mv-distillery",
    stack_size = 10
}



--- MV ORE WASHER
make_electric_machine("mv-ore-washer", "mv-ore-washer", "mv-ore-washer", { "lv-ore-washer-recipes" }, "fr-ore-washer", EU8_MV, 2, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "mv-ore-washer",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "bronze-rotor", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-motor", amount = 1},
	},
	place_result = "mv-ore-washer",
    stack_size = 10
}



--- MV LASER ENGRAVER
make_electric_machine("mv-laser-engraver", "mv-laser-engraver", "mv-laser-engraver", { "mv-laser-engraver-recipes" }, "fr-laser-engraver", EU30_MV, 2, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "mv-laser-engraver",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 3},
		{type = "item", name = "mv-emitter", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-laser-engraver",
    stack_size = 10
}



--- MV FLUID SOLIDIFIER
make_electric_machine("mv-fluid-solidifier", "mv-fluid-solidifier", "mv-fluid-solidifier", { "lv-fluid-solidifier-recipes" }, "fr-fluid-solidifier", EU8_MV, 2, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "mv-fluid-solidifier",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-pump", amount = 2},
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "wooden-chest", amount = 1},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "mv-fluid-solidifier",
    stack_size = 10
}



--- MV CHEMICAL BATH
make_electric_machine("mv-chemical-bath", "mv-chemical-bath", "lv-chemical-bath", { "lv-chemical-bath-recipes", "mv-chemical-bath-recipes" }, "fr-chemical-bath", EU12_MV, 2, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "mv-chemical-bath",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-pump", amount = 1},
		{type = "item", name = "glass", amount = 2},
		{type = "item", name = "mv-conveyor-module", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "copper-cable", amount = 1},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-chemical-bath",
    stack_size = 10
}



--- MV POLARIZER
make_electric_machine("mv-polarizer", "mv-polarizer", "mv-polarizer", { "lv-polarizer-recipes", "mv-polarizer-recipes" }, "fr-polarizer", EU30_MV, 2, 1, 0.5, 3, 3 )
create_item{
	name = "mv-polarizer",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "steel-rod", amount = 2},
		{type = "item", name = "copper-wire", amount = 8},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-polarizer",
    stack_size = 10
}



--- MV CIRCUIT ASSEMBLER
make_electric_machine("mv-circuit-assembler", "mv-circuit-assembler", "mv-circuit-assembler", { "lv-circuit-assembler-recipes", "mv-circuit-assembler-recipes" }, "fr-circuit-assembler", EU24_MV, 2, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "mv-circuit-assembler",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-robot-arm", amount = 1},
		{type = "item", name = "mv-emitter", amount = 1},
		{type = "item", name = "mv-conveyor-module", amount = 2},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-circuit-assembler",
    stack_size = 10
}



--- MV AUTOCLAVE
make_electric_machine("mv-autoclave", "mv-autoclave", "mv-autoclave", { "lv-autoclave-recipes", "mv-autoclave-recipes" }, "fr-autoclave", EU24_MV, 2, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-autoclave",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "item", name = "aluminium-plate", amount = 4},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
		{type = "item", name = "mv-pump", amount = 1},
	},
	place_result = "mv-autoclave",
    stack_size = 10
}



--- MV ALLOY SMELTER
make_electric_machine("mv-alloy-smelter", "mv-alloy-smelter", "mv-alloy-smelter", { "lv-alloy-smelter-recipes", "mv-alloy-smelter-recipes" }, "fr-alloy-smelter", EU24_MV, 2, 1, 0.5, 3, 3 )
create_item{
	name = "mv-alloy-smelter",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "cupronickel-wire", amount = 16},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-alloy-smelter",
    stack_size = 10
}



--- MV COMPRESSOR
make_electric_machine("mv-compressor", "mv-compressor", "mv-compressor", { "lv-compressor-recipes", "mv-compressor-recipes" }, "fr-compressor", EU2_MV, 2, 9, 0.5, 3, 3 )
create_item{
	name = "mv-compressor",
	subgroup = "mv-age-production-machine",
	ingredients = {
		{type = "item", name = "mv-piston", amount = 2},
		{type = "item", name = "copper-cable", amount = 4},
		{type = "item", name = "advanced-circuit", amount = 2},
		{type = "item", name = "mv-machine-hull", amount = 1},
	},
	place_result = "mv-compressor",
    stack_size = 10
}



---MV GREENHOUSE
make_electric_machine("mv-greenhouse", "greenhouse", "greenhouse", { "greenhouse-recipes" }, "fr-greenhouse", EU16_MV, 2, 1, 0.5, 5, 5, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "mv-greenhouse",
	icon = ICON_PATH .. "greenhouse.png",
	ingredients = {
		{ type = "item", name = "lv-greenhouse", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 1 },
	},
	results = {
		{ type = "item", name = "mv-greenhouse", amount = 1 },
		{ type = "item", name = "lv-energy-hatch", amount = 1 },
	},
	main_product = "mv-greenhouse",
	place_result = "mv-greenhouse",
    stack_size = 10
}



---MV PYROLYSE OVEN
make_electric_machine("mv-pyrolyse-oven", "mv-pyrolyse-oven", "mv-pyrolyse-oven", { "pyrolyse-oven-recipes" }, "fr-pyrolyse-oven", EU16_MV, 2, 1, 0.5, 4, 3, {
	fluid_port(-0.5, -1, "input",  defines.direction.north),
	fluid_port(-0.5,  1, "output", defines.direction.south),
	fluid_port( 1.5, -1, "input",  defines.direction.east),
	fluid_port( 1.5,  1, "input",  defines.direction.east),
	fluid_port(-1.5, -1, "output", defines.direction.west),
	fluid_port(-1.5,  1, "output", defines.direction.west)
})
create_item{
	name = "pyrolyse-oven-controller",
	ingredients = {
		{ type = "item", name = "lv-pump", amount = 1 },
		{ type = "item", name = "lv-piston", amount = 2 },
		{ type = "item", name = "electronic-circuit", amount = 3 },
		{ type = "item", name = "ulv-machine-hull", amount = 1 },
		{ type = "item", name = "cupronickel-wire", amount = 8 },
	}
}
create_item{
	name = "mv-pyrolyse-oven",
	ingredients = {
		{ type = "item", name = "pyrolyse-oven-controller", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
		{ type = "item", name = "lv-energy-hatch", amount = 2 },
		{ type = "item", name = "cupronickel-coil-block", amount = 16 },
		{ type = "item", name = "ulv-machine-casing", amount = 9 }
	},
	place_result = "mv-pyrolyse-oven",
    stack_size = 10
}



--- MV ELECTRIC BLAST FURNACE
make_electric_machine("mv-electric-blast-furnace", "mv-electric-blast-furnace", "mv-electric-blast-furnace", { "mv-electric-blast-furnace-recipes" }, "fr-electric-blast-furnace", EU30_MV, 2, 1, 0.5, 3, 4, {
    fluid_port(-1, -1.5, "input",  defines.direction.north),
    fluid_port( 1, -1.5, "input",  defines.direction.north),
    fluid_port(-1,  1.5, "output", defines.direction.south),
    fluid_port( 1,  1.5, "output", defines.direction.south),
    fluid_port( 1, -0.5, "input",  defines.direction.east),
    fluid_port(-1, -0.5, "output", defines.direction.west)
})
create_item{
	name = "electric-blast-furnace-controller",
	ingredients = {
		{type = "item", name = "iron-furnace", amount = 3},
		{type = "item", name = "electronic-circuit", amount = 3},
		{type = "item", name = "tin-cable", amount = 2},
		{type = "item", name = "heat-proof-casing", amount = 1},
	}
}
create_item{
	name = "mv-electric-blast-furnace",
	ingredients = {
		{type = "item", name = "electric-blast-furnace-controller", amount = 1},
		{type = "item", name = "lv-machine-hull", amount = 5},
		{type = "item", name = "lv-energy-hatch", amount = 2},
		{type = "item", name = "cupronickel-coil-block", amount = 16},
		{type = "item", name = "heat-proof-casing", amount = 10}
	},
	place_result = "mv-electric-blast-furnace",
    stack_size = 10
}



---MV MULTISMELTER
make_electric_machine("mv-multismelter", "mv-multismelter", "mv-multismelter", { "multismelter-recipes" }, "fr-multismelter", EU30_MV, 2, 1, 0.5, 3, 3 )
create_item{
	name = "multismelter-controller",
	ingredients = {
		{type = "item", name = "iron-furnace", amount = 3},
		{type = "item", name = "processing-unit", amount = 3},
		{type = "item", name = "copper-cable", amount = 2},
		{type = "item", name = "heat-proof-casing", amount = 1},
    }
}
create_item{
	name = "mv-multismelter",
	ingredients = {
		{type = "item", name = "multismelter-controller", amount = 1},
		{type = "item", name = "heat-proof-casing", amount = 11},
		{type = "item", name = "lv-machine-hull", amount = 4},
		{type = "item", name = "lv-energy-hatch", amount = 2},
		{type = "item", name = "cupronickel-coil-block", amount = 8},
    },
	place_result = "mv-multismelter",
    stack_size = 10
}

   
   
 ---MV VACUUM FREEZER
make_electric_machine("mv-vacuum-freezer", "vacuum-freezer", "vacuum-freezer", { "mv-vacuum-freezer-recipes" }, "fr-vacuum-freezer", EU30_MV, 2, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "vacuum-freezer-controller",
	ingredients = {
		{type = "item", name = "hv-pump", amount = 3},
		{type = "item", name = "ev-circuit", amount = 3},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "frost-proof-casing", amount = 1},
    }
}

create_item{
	name = "mv-vacuum-freezer",
	icon = ICON_PATH .. "vacuum-freezer.png",
	ingredients = {
		{type = "item", name = "vacuum-freezer-controller", amount = 1},
		{type = "item", name = "frost-proof-casing", amount = 19},
		{type = "item", name = "lv-machine-hull", amount = 5},
		{type = "item", name = "mv-energy-hatch", amount = 1}
    },
	place_result = "mv-vacuum-freezer",
    stack_size = 10
}



---MV MICROVERSE PROJECTOR
make_electric_machine("mv-microverse-projector", "small-microverse-projector", "small-microverse-projector", { "mv-microverse-projector-recipes" }, "fr-small-microverse-projector", EU30_MV, 2, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "microverse-projector-controller",
	ingredients = {
      {type = "item", name = "advanced-circuit", amount = 4},
      {type = "item", name = "tempered-glass", amount = 1},
      {type = "item", name = "microversium-casing", amount = 4},
    }
}
create_item{
	name = "mv-microverse-projector",
	icon = ICON_PATH .. "small-microverse-projector.png",
	ingredients = {
      {type = "item", name = "microverse-projector-controller", amount = 1},
      {type = "item", name = "microversium-casing", amount = 14},
      {type = "item", name = "tempered-glass", amount = 4},
      {type = "item", name = "block-of-diamond", amount = 1},
      {type = "item", name = "lv-machine-hull", amount = 5},
      {type = "item", name = "lv-energy-hatch", amount = 2},
    },
	place_result = "mv-microverse-projector",
    stack_size = 10
}



---MV PUMPJACK
make_electric_machine("mv-drilling-rig", "mv-drilling-rig", "mv-drilling-rig", { "drilling-rig-recipes" }, "fr-drilling-rig", EU16_MV, 2, 1, 0.5, 3, 6.25, { 
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "mv-drilling-rig-controller",
	category = "mv-assembling-machine-recipes",
	energy_required = MV_SPEED * 20,
	ingredients = {
      {type = "item", name = "mv-machine-hull", amount = 1},
      {type = "item", name = "steel-frame", amount = 4},
      {type = "item", name = "advanced-circuit", amount = 4},
      {type = "item", name = "mv-motor", amount = 4},
      {type = "item", name = "mv-pump", amount = 4},
      {type = "item", name = "large-vanadium-steel-gear", amount = 4},
      {type = "fluid", name = "soldering-alloy", amount = 14.4},
    }
}
create_item{
	name = "mv-drilling-rig",
	ingredients = {
      {type = "item", name = "mv-drilling-rig-controller", amount = 1},
      {type = "item", name = "steel-frame", amount = 15},
      {type = "item", name = "lv-machine-hull", amount = 3},
      {type = "item", name = "mv-energy-hatch", amount = 1},
      {type = "item", name = "solid-steel-machine-casing", amount = 7}
    },
	place_result = "mv-drilling-rig",
    stack_size = 10
}



---BASIC EXTENDED CRAFTING TABLE
create_item{
	name = "basic-extended-crafting-table",
	stack_size = 10,
	place_result = "basic-extended-crafting-table",
	ingredients = {
		{ type = "item", name = "basic-extended-crafting-component", amount = 3 },
		{ type = "item", name = "basic-extended-crafting-catalyst", amount = 1 },
		{ type = "item", name = "crafting-table", amount = 1 }
	}
}
data:extend({
  {
    type = "assembling-machine",
    name = "basic-extended-crafting-table",
    icon = "__Gregtorio__/graphics/icons/basic-extended-crafting-table.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "basic-extended-crafting-table"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "fr-extended-crafting-table",
    crafting_categories = { "basic-extended-crafting-recipes" },
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__Gregtorio__/graphics/entity/basic-extended-crafting-table.png",
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



---T1 CONSTRUCTION ROBOT
local t1_construction_robot = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
t1_construction_robot.name = "t1-construction-robot"
t1_construction_robot.icon_size = 32
t1_construction_robot.icon = "__Gregtorio__/graphics/icons/t1-construction-robot.png"
t1_construction_robot.max_health = 60
t1_construction_robot.max_energy = "1.5MJ"
t1_construction_robot.speed = 0.08
t1_construction_robot.energy_per_move = "4kJ"
t1_construction_robot.energy_per_tick = "0.04kJ"
t1_construction_robot.max_payload_size = 1
t1_construction_robot.minable = { mining_time = 0.1, result = "t1-construction-robot" }
data:extend({t1_construction_robot})
create_item{
	name = "t1-construction-robot",
	ingredients = {
		{type = "item", name = "basic-guidance-system", amount = 1},
		{type = "item", name = "battery", amount = 3},
		{type = "item", name = "lv-robot-arm", amount = 2},
		{type = "item", name = "conductive-iron-thruster", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 4},
    }
}



---T1 LOGISTIC ROBOT
local t1_logistic_robot = table.deepcopy(data.raw["logistic-robot"]["logistic-robot"])
t1_logistic_robot.name = "t1-logistic-robot"
t1_logistic_robot.icon = "__Gregtorio__/graphics/icons/t1-logistic-robot.png"
t1_logistic_robot.max_health = 60
t1_logistic_robot.icon_size = 32
t1_logistic_robot.max_energy = "1.5MJ"
t1_logistic_robot.speed = 0.08
t1_logistic_robot.energy_per_move = "4kJ"
t1_logistic_robot.energy_per_tick = "0.04kJ"
t1_logistic_robot.max_payload_size = 1
t1_logistic_robot.minable = { mining_time = 0.1, result = "t1-logistic-robot" }
data:extend({t1_logistic_robot})
create_item{
	name = "t1-logistic-robot",
	ingredients = {
		{type = "item", name = "basic-guidance-system", amount = 1},
		{type = "item", name = "battery", amount = 3},
		{type = "item", name = "me-1k-storage-component", amount = 1},
		{type = "item", name = "conductive-iron-thruster", amount = 1},
		{type = "item", name = "advanced-circuit", amount = 4},
    }
}


---T1 ROBOPORT
local base = data.raw.roboport and data.raw.roboport.roboport
assert(base, "Base roboport prototype not found (data.raw.roboport.roboport)")
local roboport_mk1 = table.deepcopy(base)
roboport_mk1.name = "roboport-mk1"
roboport_mk1.minable = {mining_time = 0.1, result = "roboport-mk1"}
roboport_mk1.energy_source = roboport_mk1.energy_source or {
  type = "electric",
  usage_priority = "secondary-input"
}
roboport_mk1.charging_energy    = "350kW"
roboport_mk1.recharge_minimum   = "60MJ"
roboport_mk1.energy_source.buffer_capacity = "300MJ"
roboport_mk1.energy_source.input_flow_limit = "5MW"
roboport_mk1.energy_usage 			 = "0W"
roboport_mk1.logistics_radius         = 30
roboport_mk1.construction_radius      = 40
roboport_mk1.charge_approach_distance = 3
roboport_mk1.robot_slots_count        = 4
roboport_mk1.material_slots_count     = 4
data:extend({ roboport_mk1 })