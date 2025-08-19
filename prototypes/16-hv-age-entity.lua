--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---HV STEAM TURBINE
create_item{
	name = "hv-steam-turbine",
	ingredients = {
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "steel-rotor", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
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
    effectivity = 0.425,
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
          filename = "__Gregtorio__/graphics/entity/hv-steam-turbine/hv-steam-turbine-working.png",
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
          filename = "__Gregtorio__/graphics/entity/hv-steam-turbine/hv-steam-turbine-working.png",
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



---HV GAS TURBINE
create_burner_generator{
	name = "hv-gas-turbine",
	efficiency = 0.85,
	fuel_categories = { "gas-turbine-fuel" },
	max_power = EU32_HV,
}
create_item{
	name = "hv-gas-turbine",
	ingredients = {
		{type = "item", name = "steel-rotor", amount = 3},
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "gold-cable", amount = 1},
    },
	place_result = "hv-gas-turbine",
	stack_size = 10
}



---HV COMBUSTION GENERATOR
create_burner_generator{
	name = "hv-combustion-generator",
	efficiency = 0.85,
	fuel_categories = { "combustion-generator-fuel" },
	max_power = EU32_HV,
}
create_item{
	name = "hv-combustion-generator",
	ingredients = {
      {type = "item", name = "hv-piston", amount = 2},
      {type = "item", name = "processing-unit", amount = 1},
      {type = "item", name = "hv-motor", amount = 2},
      {type = "item", name = "hv-machine-hull", amount = 1},
      {type = "item", name = "gold-cable", amount = 1},
      {type = "item", name = "large-stainless-steel-gear", amount = 2},
    },
	place_result = "hv-combustion-generator",
	stack_size = 10
}



---HV SEMIFLUID GENERATOR
create_burner_generator{
	name = "hv-semifluid-generator",
	efficiency = 0.85,
	fuel_categories = { "semifluid-generator-fuel" },
	max_power = EU32_HV,
}
create_item{
	name = "hv-semifluid-generator",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 2},
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "processing-unit", amount = 1},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "gold-cable", amount = 1},
		{type = "item", name = "large-chromium-gear", amount = 2},
    },
	place_result = "hv-semifluid-generator",
	stack_size = 10
}



--- HV WIREMILL
make_electric_machine("hv-wiremill", "hv-wiremill", "mv-wiremill", { "lv-wiremill-recipes", "mv-wiremill-recipes", "hv-wiremill-recipes" }, "fr-wiremill", EU8_HV, 4, 3, 0.5, 3, 3 )
create_item{
	name = "hv-wiremill",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-motor", amount = 4},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-wiremill",
    stack_size = 10
}



--- HV BENDING MACHINE
make_electric_machine("hv-bending-machine", "hv-bending-machine", "mv-bending-machine", { "lv-bending-machine-recipes", "mv-bending-machine-recipes", "hv-bending-machine-recipes" }, "fr-bending-machine", 
	EU24_HV, 4, 14, 0.5, 3, 3 )
create_item{
	name = "hv-bending-machine",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 2},
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "gold-cable", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-bending-machine",
	stack_size = 10
}



--- HV EXTRUDER
make_electric_machine("hv-extruder", "hv-extruder", "mv-extruder", { "mv-extruder-recipes", "hv-extruder-recipes" }, "fr-extruder", EU16_HV, 4, 5, 0.5, 3, 3 )
create_item{
	name = "hv-extruder",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 1},
		{type = "item", name = "kanthal-wire", amount = 16},
		{type = "item", name = "stainless-steel-plate", amount = 3},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "hv-extruder",
	stack_size = 10
}



--- HV ROCK CRUSHER
make_electric_machine("hv-rock-crusher", "hv-rock-crusher", "mv-rock-crusher", { "lv-rock-crusher-recipes", "mv-rock-crusher-recipes", "hv-rock-crusher-recipes" }, "fr-rock-crusher", EU8_HV, 4, 5, 0.5, 3, 3 )
create_item{
	name = "hv-rock-crusher",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "tempered-glass", amount = 3},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-rock-crusher",
    stack_size = 10
}



--- HV LATHE
make_electric_machine("hv-lathe", "hv-lathe", "mv-lathe", { "lv-lathe-recipes", "mv-lathe-recipes", "hv-lathe-recipes" }, "fr-lathe", EU16_HV, 4, 9, 0.5, 3, 3 )
create_item{
	name = "hv-lathe",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
		{type = "item", name = "gold-cable", amount = 3},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-lathe",
    stack_size = 10
}



--- HV MACERATOR
make_electric_machine("hv-macerator", "hv-macerator", "mv-macerator", { "lv-macerator-recipes", "mv-macerator-recipes", "mv-macerator-recipes" }, "fr-macerator", EU2_HV, 4, 6, 0.5, 3, 3 )
create_item{
	name = "hv-macerator",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-motor", amount = 1},
		{type = "item", name = "hv-piston", amount = 1},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "gold-cable", amount = 3},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-macerator",
    stack_size = 10
}



--- HV CENTRIFUGE
make_electric_machine("hv-centrifuge", "hv-centrifuge", "mv-centrifuge", { "lv-centrifuge-recipes", "mv-centrifuge-recipes", "hv-centrifuge-recipes" }, "fr-centrifuge", EU24_HV, 4, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-centrifuge",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 4},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-centrifuge",
    stack_size = 10
}



--- HV AIR COLLECTOR
make_electric_machine("hv-air-collector", "hv-air-collector", "mv-air-collector", { "lv-air-collector-recipes" }, "fr-air-collector", EU8_HV, 4, 1, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-air-collector",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "filter", amount = 1},
		{type = "item", name = "iron-stick", amount = 4},
		{type = "item", name = "processing-unit", amount = 1},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-pump", amount = 2},
	},
	place_result = "hv-air-collector",
    stack_size = 10
}



--- HV EXTRACTOR
make_electric_machine("hv-extractor", "hv-extractor", "mv-extractor", { "lv-extractor-recipes", "mv-extractor-recipes", "hv-extractor-recipes" }, "fr-extractor", EU12_HV, 4, 5, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-extractor",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "tempered-glass", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-pump", amount = 1},
		{type = "item", name = "hv-piston", amount = 1},
	},
	place_result = "hv-extractor",
    stack_size = 10
}


--- HV ELECTROLYZER
make_electric_machine("hv-electrolyzer", "hv-electrolyzer", "mv-electrolyzer", { "lv-electrolyzer-recipes", "mv-electrolyzer-recipes", "hv-electrolyzer-recipes" }, "fr-electrolyzer", EU30_HV, 4, 2, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-electrolyzer",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "electrum-wire", amount = 4},
		{type = "item", name = "tempered-glass", amount = 1},
		{type = "item", name = "gold-cable", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-electrolyzer",
    stack_size = 10
}



--- HV ASSEMBLING MACHINE
make_electric_machine("hv-assembling-machine", "hv-assembling-machine", "mv-assembling-machine", { "crafting-or-assembling-recipes", "lv-assembling-machine-recipes", "mv-assembling-machine-recipes",
	"hv-assembling-machine-recipes" }, "fr-assembling-machine", EU12_HV, 4, 19, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "hv-assembling-machine",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-robot-arm", amount = 2},
		{type = "item", name = "hv-conveyor-module", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-assembling-machine",
    stack_size = 10
}



--- HV CHEMICAL REACTOR
make_electric_machine("hv-chemical-reactor", "hv-chemical-reactor", "mv-chemical-reactor", { "lv-chemical-reactor-recipes", "mv-chemical-reactor-recipes", "hv-chemical-reactor-recipes" },
	"fr-chemical-reactor", EU16_HV, 4, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-chemical-reactor",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "polyethylene-sheet", amount = 6},
		{type = "item", name = "steel-rotor", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
	},
	place_result = "hv-chemical-reactor",
    stack_size = 10
}



--- HV CUTTING MACHINE
make_electric_machine("hv-cutting-machine", "hv-cutting-machine", "mv-cutting-machine", { "lv-cutting-machine-recipes", "mv-cutting-machine-recipes", "hv-cutting-machine-recipes" },
	"fr-cutting-machine", EU16_HV, 4, 14, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "hv-cutting-machine",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "tempered-glass", amount = 1},
		{type = "item", name = "hv-conveyor-module", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
		{type = "item", name = "diamond-sawblade", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
	},
	place_result = "hv-cutting-machine",
    stack_size = 10
}



--- HV CANNING MACHINE
make_electric_machine("hv-canning-machine", "hv-canning-machine", "mv-canning-machine", { "lv-canning-machine-recipes", "mv-canning-machine-recipes", "hv-canning-machine-recipes" }, "fr-canning-machine", EU2_HV, 4, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-canning-machine",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "glass", amount = 3},
		{type = "item", name = "hv-pump", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
	},
	place_result = "hv-canning-machine",
    stack_size = 10
}



--- HV MIXER
make_electric_machine("hv-mixer", "hv-mixer", "mv-mixer", { "lv-mixer-recipes", "mv-mixer-recipes", "hv-mixer-recipes" }, "fr-mixer", EU24_HV, 4, 6, 0.5, 3, 3,{
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-mixer",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "tempered-glass", amount = 4},
		{type = "item", name = "steel-rotor", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
	},
	place_result = "hv-mixer",
    stack_size = 10
}



--- HV ORE WASHER
make_electric_machine("hv-ore-washer", "hv-ore-washer", "mv-ore-washer", { "lv-ore-washer-recipes" }, "fr-ore-washer", EU8_HV, 4, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "hv-ore-washer",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "tempered-glass", amount = 1},
		{type = "item", name = "steel-rotor", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
	},
	place_result = "hv-ore-washer",
    stack_size = 10
}



--- HV LASER ENGRAVER
make_electric_machine("hv-laser-engraver", "hv-laser-engraver", "mv-laser-engraver", { "mv-laser-engraver-recipes", "hv-laser-engraver-recipes" }, "fr-laser-engraver", EU30_HV, 4, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "hv-laser-engraver",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 2},
		{type = "item", name = "processing-unit", amount = 3},
		{type = "item", name = "hv-emitter", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-laser-engraver",
    stack_size = 10
}



--- HV FLUID SOLIDIFIER
make_electric_machine("hv-fluid-solidifier", "hv-fluid-solidifier", "mv-fluid-solidifier", { "lv-fluid-solidifier-recipes" }, "fr-fluid-solidifier", EU8_HV, 4, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "hv-fluid-solidifier",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-pump", amount = 2},
		{type = "item", name = "tempered-glass", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "wooden-chest", amount = 1},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "hv-fluid-solidifier",
    stack_size = 10
}



--- HV CHEMICAL BATH
make_electric_machine("hv-chemical-bath", "hv-chemical-bath", "lv-chemical-bath", { "lv-chemical-bath-recipes", "mv-chemical-bath-recipes", "hv-chemical-bath-recipes" }, "fr-chemical-bath", EU12_HV, 4, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "hv-chemical-bath",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-pump", amount = 1},
		{type = "item", name = "tempered-glass", amount = 2},
		{type = "item", name = "hv-conveyor-module", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "gold-cable", amount = 1},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-chemical-bath",
    stack_size = 10
}



--- HV POLARIZER
make_electric_machine("hv-polarizer", "hv-polarizer", "mv-polarizer", { "lv-polarizer-recipes", "mv-polarizer-recipes", "hv-polarizer-recipes" }, "fr-polarizer", EU30_HV, 4, 1, 0.5, 3, 3 )
create_item{
	name = "hv-polarizer",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "steel-rod", amount = 2},
		{type = "item", name = "silver-wire", amount = 16},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-polarizer",
    stack_size = 10
}



--- HV CIRCUIT ASSEMBLER
make_electric_machine("hv-circuit-assembler", "hv-circuit-assembler", "mv-circuit-assembler", { "lv-circuit-assembler-recipes", "mv-circuit-assembler-recipes",
	"hv-circuit-assembler-recipes" }, "fr-circuit-assembler", EU24_HV, 4, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "hv-circuit-assembler",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-robot-arm", amount = 1},
		{type = "item", name = "hv-emitter", amount = 1},
		{type = "item", name = "hv-conveyor-module", amount = 2},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-circuit-assembler",
    stack_size = 10
}



--- HV AUTOCLAVE
make_electric_machine("hv-autoclave", "hv-autoclave", "mv-autoclave", { "lv-autoclave-recipes", "mv-autoclave-recipes", "hv-autoclave-recipes" }, "fr-autoclave", EU24_HV, 4, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-autoclave",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "tempered-glass", amount = 1},
		{type = "item", name = "stainless-steel-plate", amount = 4},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "hv-pump", amount = 1},
	},
	place_result = "hv-autoclave",
    stack_size = 10
}



--- HV ALLOY SMELTER
make_electric_machine("hv-alloy-smelter", "hv-alloy-smelter", "mv-alloy-smelter", { "lv-alloy-smelter-recipes", "mv-alloy-smelter-recipes", "hv-alloy-smelter-recipes" }, "fr-alloy-smelter", EU24_HV, 4, 1, 0.5, 3, 3 )
create_item{
	name = "hv-alloy-smelter",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "kanthal-wire", amount = 16},
		{type = "item", name = "gold-cable", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-alloy-smelter",
    stack_size = 10
}



--- HV COMPRESSOR
make_electric_machine("hv-compressor", "hv-compressor", "mv-compressor", { "lv-compressor-recipes", "mv-compressor-recipes", "hv-compressor-recipes" }, "fr-compressor", EU2_HV, 4, 9, 0.5, 3, 3 )
create_item{
	name = "hv-compressor",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 2},
		{type = "item", name = "gold-cable", amount = 4},
		{type = "item", name = "processing-unit", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
	},
	place_result = "hv-compressor",
    stack_size = 10
}



---HV GREENHOUSE
make_electric_machine("hv-greenhouse", "greenhouse", "greenhouse", { "greenhouse-recipes" }, "fr-greenhouse", EU16_HV, 4, 1, 0.5, 5, 5, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "hv-greenhouse",
	icon = ICON_PATH .. "greenhouse.png",
	ingredients = {
		{ type = "item", name = "mv-greenhouse", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	results = {
		{ type = "item", name = "hv-greenhouse", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 1 },
	},
	main_product = "hv-greenhouse",
	place_result = "hv-greenhouse",
    stack_size = 10
}



---HV PYROLYSE OVEN
make_electric_machine("hv-pyrolyse-oven", "mv-pyrolyse-oven", "mv-pyrolyse-oven", { "pyrolyse-oven-recipes" }, "fr-pyrolyse-oven", EU16_HV, 4, 1, 0.5, 4, 3, {
	fluid_port(-0.5, -1, "input",  defines.direction.north),
	fluid_port(-0.5,  1, "output", defines.direction.south),
	fluid_port( 1.5, -1, "input",  defines.direction.east),
	fluid_port( 1.5,  1, "input",  defines.direction.east),
	fluid_port(-1.5, -1, "output", defines.direction.west),
	fluid_port(-1.5,  1, "output", defines.direction.west)
})
create_item{
	name = "hv-pyrolyse-oven",
	ingredients = {
		{ type = "item", name = "mv-pyrolyse-oven", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 2 },
		{ type = "item", name = "kanthal-coil-block", amount = 16 }
	},
	results = {
		{ type = "item", name = "hv-pyrolyse-oven", amount = 1 },
		{ type = "item", name = "lv-energy-hatch", amount = 2 },
		{ type = "item", name = "cupronickel-coil-block", amount = 16 },
	},
	main_product = "hv-pyrolyse-oven",
	place_result = "hv-pyrolyse-oven",
    stack_size = 10
}



--- HV ELECTRIC BLAST FURNACE
make_electric_machine("hv-electric-blast-furnace", "mv-electric-blast-furnace", "mv-electric-blast-furnace", { "mv-electric-blast-furnace-recipes", "hv-electric-blast-furnace-recipes" },
	"fr-electric-blast-furnace", EU30_HV, 4, 1, 0.5, 3, 4, {
    fluid_port(-1, -1.5, "input",  defines.direction.north),
    fluid_port( 1, -1.5, "input",  defines.direction.north),
    fluid_port(-1,  1.5, "output", defines.direction.south),
    fluid_port( 1,  1.5, "output", defines.direction.south),
    fluid_port( 1, -0.5, "input",  defines.direction.east),
    fluid_port(-1, -0.5, "output", defines.direction.west)
})
create_item{
	name = "hv-electric-blast-furnace",
	ingredients = {
		{ type = "item", name = "mv-electric-blast-furnace", amount = 1},
		{ type = "item", name = "mv-energy-hatch", amount = 2},
		{ type = "item", name = "kanthal-coil-block", amount = 16}
	},
	results = {
		{ type = "item", name = "hv-electric-blast-furnace", amount = 1 },
		{ type = "item", name = "lv-energy-hatch", amount = 2 },
		{ type = "item", name = "cupronickel-coil-block", amount = 16 },
	},
	main_product = "hv-electric-blast-furnace",
	place_result = "hv-electric-blast-furnace",
    stack_size = 10
}



---HV MULTISMELTER
make_electric_machine("hv-multismelter", "mv-multismelter", "mv-multismelter", { "multismelter-recipes" }, "fr-multismelter", EU30_HV, 4, 1, 0.5, 3, 3 )
create_item{
	name = "hv-multismelter",
	ingredients = {
      { type = "item", name = "mv-multismelter", amount = 1},
      { type = "item", name = "mv-energy-hatch", amount = 2},
      { type = "item", name = "kanthal-coil-block", amount = 8},
    },
	results = {
		{ type = "item", name = "hv-multismelter", amount = 1 },
		{ type = "item", name = "lv-energy-hatch", amount = 2 },
		{ type = "item", name = "cupronickel-coil-block", amount = 8 },
	},
	main_product = "hv-multismelter",
	place_result = "hv-multismelter",
    stack_size = 10
}

   
   
---HV VACUUM FREEZER
make_electric_machine("hv-vacuum-freezer", "vacuum-freezer", "vacuum-freezer", { "mv-vacuum-freezer-recipes", "hv-vacuum-freezer-recipes" }, "fr-vacuum-freezer", EU30_HV, 4, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-vacuum-freezer",
	icon = ICON_PATH .. "vacuum-freezer.png",
	ingredients = {
		{type = "item", name = "mv-vacuum-freezer", amount = 1},
		{type = "item", name = "hv-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "hv-vacuum-freezer", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 1 },
	},
	main_product = "hv-vacuum-freezer",
	place_result = "hv-vacuum-freezer",
    stack_size = 10
}



---HV MICROVERSE PROJECTOR
make_electric_machine("hv-microverse-projector", "small-microverse-projector", "small-microverse-projector", { "mv-microverse-projector-recipes", "hv-microverse-projector-recipes" },
	"fr-small-microverse-projector", EU30_HV, 4, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "hv-microverse-projector",
	icon = ICON_PATH .. "small-microverse-projector.png",
	ingredients = {
      {type = "item", name = "mv-microverse-projector", amount = 1},
      {type = "item", name = "mv-energy-hatch", amount = 2},
    },
	results = {
		{ type = "item", name = "hv-microverse-projector", amount = 1 },
		{ type = "item", name = "lv-energy-hatch", amount = 2 },
	},
	main_product = "hv-microverse-projector",
	place_result = "hv-microverse-projector",
    stack_size = 10
}



---HV PUMPJACK
make_electric_machine("hv-drilling-rig", "mv-drilling-rig", "mv-drilling-rig", { "drilling-rig-recipes" }, "fr-drilling-rig", EU16_HV, 4, 1, 0.5, 3, 6.25, { 
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "hv-drilling-rig-controller",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 20,
	ingredients = {
		{type = "item", name = "mv-drilling-rig-controller", amount = 1},
		{type = "item", name = "stainless-steel-frame", amount = 8},
		{type = "item", name = "processing-unit", amount = 4},
		{type = "item", name = "hv-motor", amount = 4},
		{type = "item", name = "hv-pump", amount = 4},
		{type = "item", name = "large-blue-steel-gear", amount = 8},
		{type = "fluid", name = "soldering-alloy", amount = 28.8},
    }
}
create_item{
	name = "hv-drilling-rig",
	icon = ICON_PATH .. "mv-drilling-rig.png",
	ingredients = {
		{type = "item", name = "hv-drilling-rig-controller", amount = 1},
		{type = "item", name = "stainless-steel-frame", amount = 15},
		{type = "item", name = "hv-energy-hatch", amount = 1},
        {type = "item", name = "lv-machine-hull", amount = 3},
		{type = "item", name = "clean-stainless-steel-casing", amount = 7}
    },
	results = {
		{type = "item", name = "hv-drilling-rig", amount = 1}
    },
	place_result = "hv-drilling-rig",
    stack_size = 10
}



---HV CRACKER
make_electric_machine("hv-cracker", "cracker", "cracker", { "hv-cracker-recipes" }, "fr-cracker", EU30_HV, 4, 1, 0.5, 5, 3, {
    fluid_port(-1, -1, "input",  defines.direction.north),
	fluid_port( 2, -1, "input",  defines.direction.east),
    fluid_port( 1, -1, "input",  defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
	fluid_port(-2, -1, "output", defines.direction.west),
    fluid_port( 1,  1, "output", defines.direction.south),
	fluid_port( 2,  1, "input",  defines.direction.east),
	fluid_port(-2,  1, "output", defines.direction.west)
})
create_item{
	name = "cracker-controller",
	ingredients = {
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "hv-pump", amount = 2 },
		{ type = "item", name = "cupronickel-coil-block", amount = 4 },
	}
}
create_item{
	name = "hv-cracker",
	icon = ICON_PATH .. "cracker.png",
	ingredients = {
		{ type = "item", name = "cracker-controller", amount = 1 },
		{ type = "item", name = "cupronickel-coil-block", amount = 16 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 18 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
	},
	place_result = "hv-cracker",
    stack_size = 10
}



---HV IMPLOSION COMPRESSOR
make_electric_machine("hv-implosion-compressor", "implosion-compressor", "implosion-compressor", { "lv-implosion-compressor-recipes", "mv-implosion-compressor-recipes", "hv-implosion-compressor-recipes" },
	"fr-implosion-compressor", EU30_HV, 4, 1, 0.5, 3, 3 )
create_item{
	name = "implosion-compressor-controller",
	ingredients = {
		{ type = "item", name = "solid-steel-machine-casing", amount = 1 },
		{ type = "item", name = "reinforced-stone", amount = 3 },
		{ type = "item", name = "processing-unit", amount = 3 },
		{ type = "item", name = "gold-cable", amount = 2 },
	}
}
create_item{
	name = "hv-implosion-compressor",
	icon = ICON_PATH .. "implosion-compressor.png",
	ingredients = {
		{ type = "item", name = "implosion-compressor-controller", amount = 1 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 20 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	},
	results = {
		{ type = "item", name = "hv-implosion-compressor", amount = 1 },
	},
	place_result = "hv-implosion-compressor",
    stack_size = 10
}



---HV LARGE CHEMICAL REACTOR
make_electric_machine("hv-large-chemical-reactor", "large-chemical-reactor", "large-chemical-reactor", { "lv-chemical-reactor-recipes", "mv-chemical-reactor-recipes", "hv-chemical-reactor-recipes" },
	"fr-large-chemical-reactor", EU16_HV, 4, 1, 0.5, 5, 5, {
    fluid_port(-1, -2, "input", defines.direction.north),
    fluid_port( 1, -2, "input", defines.direction.north),
    fluid_port(-1,  2, "output", defines.direction.south),
    fluid_port( 1,  2, "output", defines.direction.south),
    fluid_port( 2, -1, "input", defines.direction.east),
    fluid_port( 2,  1, "input", defines.direction.east),
    fluid_port(-2, -1, "output", defines.direction.west),
    fluid_port(-2,  1, "output", defines.direction.west)
})
create_item{
	name = "large-chemical-reactor-controller",
	ingredients = {
		{type = "item", name = "stainless-steel-rotor", amount = 1},
		{type = "item", name = "hv-motor", amount = 1},
		{type = "item", name = "processing-unit", amount = 4},
		{type = "item", name = "ptfe-sheet", amount = 12},
		{type = "item", name = "hv-machine-hull", amount = 1},
    }
}
create_item{
	name = "hv-large-chemical-reactor",
	stack_size = 10,
	icon = ICON_PATH .. "large-chemical-reactor.png",
	place_result = "hv-large-chemical-reactor",
	subgroup = "subgroup-hv-age-multiblocks",
	ingredients = {
		{type = "item", name = "large-chemical-reactor-controller", amount = 1},
		{type = "item", name = "ptfe-sheet", amount = 12},
		{type = "item", name = "ptfe-pipe-casing", amount = 1},
		{type = "item", name = "cupronickel-coil-block", amount = 1},
		{type = "item", name = "chemically-inert-casing", amount = 18},
		{type = "item", name = "lv-machine-hull", amount = 5},
		{type = "item", name = "hv-energy-hatch", amount = 1},
    },
	place_result = "hv-large-chemical-reactor",
    stack_size = 10
}



---HV SHORT DISTILLATION TOWER
make_electric_machine("hv-short-distillation-tower", "short-distillation-tower", "short-distillation-tower", { "lv-distillation-recipes", "mv-distillation-recipes", "hv-distillation-recipes" },
	"fr-large-chemical-reactor", EU24_HV, 4, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "distillation-tower-controller",
	ingredients = {
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "stainless-steel-plate", amount = 12 },
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "item", name = "hv-pump", amount = 2 },
	}
}
create_item{
	name = "hv-short-distillation-tower",
	stack_size = 10,
	place_result = "hv-short-distillation-tower",
	icon = ICON_PATH .. "short-distillation-tower.png",
	subgroup = "subgroup-hv-age-multiblocks",	
	ingredients = {
		{ type = "item", name = "distillation-tower-controller", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 19 }
	}
}



---HV TALL DISTILLATION TOWER
make_electric_machine("hv-tall-distillation-tower", "tall-distillation-tower", "tall-distillation-tower", { "lv-tall-distillation-recipes", "mv-tall-distillation-recipes", "hv-tall-distillation-recipes" },
	"fr-large-chemical-reactor", EU24_HV, 4, 1, 0.5, 3, 13, {
    fluid_port(-1, -2, "output", defines.direction.west),
    fluid_port(-1, -4, "output", defines.direction.west),
    fluid_port(-1, -6, "output", defines.direction.west),
    fluid_port(-1,  0, "output", defines.direction.west),
    fluid_port(-1,  2, "output", defines.direction.west),
    fluid_port(-1,  4, "output", defines.direction.west),
    fluid_port(-1,  6, "input", defines.direction.west),

    fluid_port( 1, -2, "output", defines.direction.east),
    fluid_port( 1, -4, "output", defines.direction.east),
    fluid_port( 1, -6, "output", defines.direction.east),
    fluid_port( 1,  0, "output", defines.direction.east),
    fluid_port( 1,  2, "output", defines.direction.east),
    fluid_port( 1,  4, "output", defines.direction.east),
    fluid_port( 1,  6, "input", defines.direction.east),
})
create_item{
	name = "hv-tall-distillation-tower",
	stack_size = 10,
	icon = ICON_PATH .. "tall-distillation-tower.png",
	place_result = "hv-tall-distillation-tower",
	subgroup = "subgroup-hv-age-multiblocks",
	ingredients = {
		{ type = "item", name = "hv-short-distillation-tower", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 8 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 64 }
	}
}    

