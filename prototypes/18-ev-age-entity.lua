--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096


---NUCLEAR REACTOR
create_burner_generator{
	name = "basic-nuclear-reactor",
	efficiency = 1,
	frame_count = 1,
	usage_priority = "primary-output",
	fuel_categories = { "nuclear-fuel-rod" },
	max_power = "10.5MW",
}



--- (NAME, ICON_PATH, ENTITY_PATH, CATEGORY, ENERGY, CRAFTSPEED, FRAMES, ANISPEED, LENGTH, WIDTH, FLUID_CONFIG)
--- EV WIREMILL
make_electric_machine("ev-wiremill", "ev-wiremill", "mv-wiremill", { "lv-wiremill-recipes", "mv-wiremill-recipes", "hv-wiremill-recipes", "ev-wiremill-recipes" }, "fr-wiremill", EU8_EV, 8, 3, 0.5, 3, 3 )
create_item{
	name = "ev-wiremill",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-motor", amount = 4},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-wiremill",
    stack_size = 10
}



--- EV BENDING MACHINE
make_electric_machine("ev-bending-machine", "ev-bending-machine", "mv-bending-machine", { "lv-bending-machine-recipes", "mv-bending-machine-recipes", "hv-bending-machine-recipes", "ev-bending-machine-recipes" },
	"fr-bending-machine", EU24_EV, 8, 14, 0.5, 3, 3 )
create_item{
	name = "ev-bending-machine",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 2},
		{type = "item", name = "ev-motor", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-bending-machine",
	stack_size = 10
}



--- EV EXTRUDER
make_electric_machine("ev-extruder", "ev-extruder", "mv-extruder", { "mv-extruder-recipes", "hv-extruder-recipes", "ev-extruder-recipes" }, "fr-extruder", EU16_EV, 8, 5, 0.5, 3, 3 )
create_item{
	name = "ev-extruder",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 1},
		{type = "item", name = "nichrome-wire", amount = 16},
		{type = "item", name = "titanium-plate", amount = 3},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "ev-extruder",
	stack_size = 10
}



--- EV ROCK CRUSHER
make_electric_machine("ev-rock-crusher", "ev-rock-crusher", "mv-rock-crusher", { "lv-rock-crusher-recipes", "mv-rock-crusher-recipes", "hv-rock-crusher-recipes", "ev-rock-crusher-recipes" },
	"fr-rock-crusher", EU8_EV, 8, 5, 0.5, 3, 3 )
create_item{
	name = "ev-rock-crusher",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 1},
		{type = "item", name = "ev-motor", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "reinforced-glass", amount = 3},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-rock-crusher",
    stack_size = 10
}



--- EV LATHE
make_electric_machine("ev-lathe", "ev-lathe", "mv-lathe", { "lv-lathe-recipes", "mv-lathe-recipes", "hv-lathe-recipes", "ev-lathe-recipes"}, "fr-lathe", EU16_EV, 8, 9, 0.5, 3, 3 )
create_item{
	name = "ev-lathe",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 1},
		{type = "item", name = "ev-motor", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 3},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-lathe",
    stack_size = 10
}



--- EV MACERATOR
make_electric_machine("ev-macerator", "ev-macerator", "mv-macerator", { "lv-macerator-recipes", "mv-macerator-recipes", "mv-macerator-recipes" }, "fr-macerator", EU2_EV, 8, 6, 0.5, 3, 3 )
create_item{
	name = "ev-macerator",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-motor", amount = 1},
		{type = "item", name = "ev-piston", amount = 1},
		{type = "item", name = "diamond-grinding-head", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 3},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-macerator",
    stack_size = 10
}



--- EV CENTRIFUGE
make_electric_machine("ev-centrifuge", "ev-centrifuge", "mv-centrifuge", { "lv-centrifuge-recipes", "mv-centrifuge-recipes", "hv-centrifuge-recipes", "ev-centrifuge-recipes" }, "fr-centrifuge", EU24_EV, 8, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-centrifuge",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-motor", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 4},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-centrifuge",
    stack_size = 10
}



--- EV AIR COLLECTOR
make_electric_machine("ev-air-collector", "ev-air-collector", "mv-air-collector", { "lv-air-collector-recipes" }, "fr-air-collector", EU8_EV, 8, 1, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-air-collector",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "filter", amount = 1},
		{type = "item", name = "iron-stick", amount = 4},
		{type = "item", name = "ev-circuit", amount = 1},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-pump", amount = 2},
	},
	place_result = "ev-air-collector",
    stack_size = 10
}



--- EV EXTRACTOR
make_electric_machine("ev-extractor", "ev-extractor", "mv-extractor", { "lv-extractor-recipes", "mv-extractor-recipes", "hv-extractor-recipes", "ev-extractor-recipes" }, "fr-extractor", EU12_EV, 8, 5, 0.5, 3, 3, {
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-extractor",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-pump", amount = 1},
		{type = "item", name = "ev-piston", amount = 1},
	},
	place_result = "ev-extractor",
    stack_size = 10
}


--- EV ELECTROLYZER
make_electric_machine("ev-electrolyzer", "ev-electrolyzer", "mv-electrolyzer", { "lv-electrolyzer-recipes", "mv-electrolyzer-recipes", "hv-electrolyzer-recipes", "ev-electrolyzer-recipes" },
	"fr-electrolyzer", EU30_EV, 8, 2, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-electrolyzer",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "platinum-wire", amount = 4},
		{type = "item", name = "reinforced-glass", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-electrolyzer",
    stack_size = 10
}



--- EV ASSEMBLING MACHINE
make_electric_machine("ev-assembling-machine", "ev-assembling-machine", "mv-assembling-machine", { "crafting-or-assembling-recipes", "lv-assembling-machine-recipes", "mv-assembling-machine-recipes",
	"hv-assembling-machine-recipes", "ev-assembling-machine-recipes" }, "fr-assembling-machine", EU12_EV, 8, 19, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "ev-assembling-machine",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-robot-arm", amount = 2},
		{type = "item", name = "ev-conveyor-module", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-assembling-machine",
    stack_size = 10
}



--- EV CUTTING MACHINE
make_electric_machine("ev-cutting-machine", "ev-cutting-machine", "mv-cutting-machine", { "lv-cutting-machine-recipes", "mv-cutting-machine-recipes", "hv-cutting-machine-recipes", "ev-cutting-machine-recipes" },
	"fr-cutting-machine", EU16_EV, 8, 14, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "ev-cutting-machine",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 1},
		{type = "item", name = "ev-conveyor-module", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-motor", amount = 1},
		{type = "item", name = "diamond-sawblade", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 2},
	},
	place_result = "ev-cutting-machine",
    stack_size = 10
}



--- EV CANNING MACHINE
make_electric_machine("ev-canning-machine", "ev-canning-machine", "mv-canning-machine", { "lv-canning-machine-recipes", "mv-canning-machine-recipes", "hv-canning-machine-recipes", "ev-canning-machine-recipes" }, 
	"fr-canning-machine", EU2_EV, 8, 4, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-canning-machine",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 3},
		{type = "item", name = "ev-pump", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 2},
	},
	place_result = "ev-canning-machine",
    stack_size = 10
}



--- EV MIXER
make_electric_machine("ev-mixer", "ev-mixer", "mv-mixer", { "lv-mixer-recipes", "mv-mixer-recipes", "hv-mixer-recipes", "ev-mixer-recipes" }, "fr-mixer", EU24_EV, 8, 6, 0.5, 3, 3,{
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-mixer",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 4},
		{type = "item", name = "stainless-steel-rotor", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-motor", amount = 1},
	},
	place_result = "ev-mixer",
    stack_size = 10
}



--- EV ORE WASHER
make_electric_machine("ev-ore-washer", "ev-ore-washer", "mv-ore-washer", { "lv-ore-washer-recipes" }, "fr-ore-washer", EU8_EV, 8, 6, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)
})
create_item{
	name = "ev-ore-washer",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 1},
		{type = "item", name = "stainless-steel-rotor", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-motor", amount = 1},
	},
	place_result = "ev-ore-washer",
    stack_size = 10
}



--- EV LASER ENGRAVER
make_electric_machine("ev-laser-engraver", "ev-laser-engraver", "mv-laser-engraver", { "mv-laser-engraver-recipes", "hv-laser-engraver-recipes", "ev-laser-engraver-recipes" }, "fr-laser-engraver", EU30_EV, 8, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "ev-laser-engraver",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 2},
		{type = "item", name = "ev-circuit", amount = 3},
		{type = "item", name = "ev-emitter", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-laser-engraver",
    stack_size = 10
}



--- EV FLUID SOLIDIFIER
make_electric_machine("ev-fluid-solidifier", "ev-fluid-solidifier", "mv-fluid-solidifier", { "lv-fluid-solidifier-recipes" }, "fr-fluid-solidifier", EU8_EV, 8, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north) 
})
create_item{
	name = "ev-fluid-solidifier",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-pump", amount = 2},
		{type = "item", name = "reinforced-glass", amount = 1},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "wooden-chest", amount = 1},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "mold", amount = 1},
	},
	place_result = "ev-fluid-solidifier",
    stack_size = 10
}



--- EV CHEMICAL BATH
make_electric_machine("ev-chemical-bath", "ev-chemical-bath", "lv-chemical-bath", { "lv-chemical-bath-recipes", "mv-chemical-bath-recipes", "hv-chemical-bath-recipes", "ev-chemical-bath-recipes" }, 
	"fr-chemical-bath", EU12_EV, 8, 3, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "ev-chemical-bath",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-pump", amount = 1},
		{type = "item", name = "reinforced-glass", amount = 2},
		{type = "item", name = "ev-conveyor-module", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 1},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-chemical-bath",
    stack_size = 10
}



--- EV POLARIZER
make_electric_machine("ev-polarizer", "ev-polarizer", "mv-polarizer", { "lv-polarizer-recipes", "mv-polarizer-recipes", "hv-polarizer-recipes", "ev-polarizer-recipes" }, "fr-polarizer", EU30_EV, 8, 1, 0.5, 3, 3 )
create_item{
	name = "ev-polarizer",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "neodymium-rod", amount = 2},
		{type = "item", name = "annealed-copper-wire", amount = 32},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-polarizer",
    stack_size = 10
}



--- EV CIRCUIT ASSEMBLER
make_electric_machine("ev-circuit-assembler", "ev-circuit-assembler", "mv-circuit-assembler", { "lv-circuit-assembler-recipes", "mv-circuit-assembler-recipes",
	"hv-circuit-assembler-recipes", "ev-circuit-assembler-recipes" }, "fr-circuit-assembler", EU24_EV, 8, 16, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "ev-circuit-assembler",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-robot-arm", amount = 1},
		{type = "item", name = "ev-emitter", amount = 1},
		{type = "item", name = "ev-conveyor-module", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "iv-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-circuit-assembler",
    stack_size = 10
}



--- EV AUTOCLAVE
make_electric_machine("ev-autoclave", "ev-autoclave", "mv-autoclave", { "lv-autoclave-recipes", "mv-autoclave-recipes", "hv-autoclave-recipes", "ev-autoclave-recipes" }, "fr-autoclave", EU24_EV, 8, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-autoclave",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "reinforced-glass", amount = 1},
		{type = "item", name = "titanium-plate", amount = 4},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
		{type = "item", name = "ev-pump", amount = 1},
	},
	place_result = "ev-autoclave",
    stack_size = 10
}



--- EV ALLOY SMELTER
make_electric_machine("ev-alloy-smelter", "ev-alloy-smelter", "mv-alloy-smelter", { "lv-alloy-smelter-recipes", "mv-alloy-smelter-recipes", "hv-alloy-smelter-recipes", "ev-alloy-smelter-recipes" }, "fr-alloy-smelter",
	EU24_EV, 8, 1, 0.5, 3, 3 )
create_item{
	name = "ev-alloy-smelter",
	subgroup = "ev-age-production-machine",
	ingredients = {
		{type = "item", name = "nichrome-wire", amount = 16},
		{type = "item", name = "aluminium-cable", amount = 2},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-alloy-smelter",
    stack_size = 10
}



--- EV COMPRESSOR
make_electric_machine("ev-compressor", "ev-compressor", "mv-compressor", { "lv-compressor-recipes", "mv-compressor-recipes", "hv-compressor-recipes", "ev-compressor-recipes" }, "fr-compressor", EU2_EV, 8, 9, 0.5, 3, 3 )
create_item{
	name = "ev-compressor",
	subgroup = "hv-age-production-machine",
	ingredients = {
		{type = "item", name = "ev-piston", amount = 2},
		{type = "item", name = "aluminium-cable", amount = 4},
		{type = "item", name = "ev-circuit", amount = 2},
		{type = "item", name = "ev-machine-hull", amount = 1},
	},
	place_result = "ev-compressor",
    stack_size = 10
}



---EV GREENHOUSE
make_electric_machine("ev-greenhouse", "greenhouse", "greenhouse", { "greenhouse-recipes" }, "fr-greenhouse", EU16_EV, 8, 1, 0.5, 5, 5, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "ev-greenhouse",
	icon = ICON_PATH .. "greenhouse.png",
	ingredients = {
		{ type = "item", name = "hv-greenhouse", amount = 1 },
		{ type = "item", name = "ev-energy-hatch", amount = 1 },
	},
	results = {
		{ type = "item", name = "ev-greenhouse", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	place_result = "ev-greenhouse",
    stack_size = 10
}



---EV PYROLYSE OVEN
make_electric_machine("ev-pyrolyse-oven", "mv-pyrolyse-oven", "mv-pyrolyse-oven", { "pyrolyse-oven-recipes" }, "fr-pyrolyse-oven", EU16_EV, 8, 1, 0.5, 4, 3, {
	fluid_port(-0.5, -1, "input",  defines.direction.north),
	fluid_port(-0.5,  1, "output", defines.direction.south),
	fluid_port( 1.5, -1, "input",  defines.direction.east),
	fluid_port( 1.5,  1, "input",  defines.direction.east),
	fluid_port(-1.5, -1, "output", defines.direction.west),
	fluid_port(-1.5,  1, "output", defines.direction.west)
})
create_item{
	name = "ev-pyrolyse-oven",
	icon = ICON_PATH .. "hv-pyrolyse-oven.png",
	ingredients = {
		{ type = "item", name = "hv-pyrolyse-oven", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 2 },
		{ type = "item", name = "nichrome-coil-block", amount = 16 }
	},
	results = {
		{ type = "item", name = "ev-pyrolyse-oven", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 2 },
		{ type = "item", name = "kanthal-coil-block", amount = 16 }
	},
	main_product = "ev-pyrolyse-oven",
	place_result = "ev-pyrolyse-oven",
    stack_size = 10
}



--- EV ELECTRIC BLAST FURNACE
make_electric_machine("ev-electric-blast-furnace", "mv-electric-blast-furnace", "mv-electric-blast-furnace", { "mv-electric-blast-furnace-recipes", "hv-electric-blast-furnace-recipes", "ev-electric-blast-furnace-recipes" },
	"fr-electric-blast-furnace", EU30_EV, 8, 1, 0.5, 3, 4, {
    fluid_port(-1, -1.5, "input",  defines.direction.north),
    fluid_port( 1, -1.5, "input",  defines.direction.north),
    fluid_port(-1,  1.5, "output", defines.direction.south),
    fluid_port( 1,  1.5, "output", defines.direction.south),
    fluid_port( 1, -0.5, "input",  defines.direction.east),
    fluid_port(-1, -0.5, "output", defines.direction.west)
})
create_item{
	name = "ev-electric-blast-furnace",
	icon = ICON_PATH .. "hv-electric-blast-furnace.png",	
	ingredients = {
		{ type = "item", name = "hv-electric-blast-furnace", amount = 1},
		{ type = "item", name = "hv-energy-hatch", amount = 2},
		{ type = "item", name = "nichrome-coil-block", amount = 16}
	},
	results = {
		{ type = "item", name = "ev-electric-blast-furnace", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 2 },
		{ type = "item", name = "kanthal-coil-block", amount = 16 }
	},
	main_product = "ev-electric-blast-furnace",
	place_result = "ev-electric-blast-furnace",
    stack_size = 10
}



---EV MULTISMELTER
make_electric_machine("ev-multismelter", "mv-multismelter", "mv-multismelter", { "multismelter-recipes" }, "fr-multismelter", EU30_EV, 8, 1, 0.5, 3, 3 )
create_item{
	name = "ev-multismelter",
	icon = ICON_PATH .. "hv-multismelter.png",
	ingredients = {
      { type = "item", name = "hv-multismelter", amount = 1},
      { type = "item", name = "hv-energy-hatch", amount = 2},
      { type = "item", name = "nichrome-coil-block", amount = 8},
    },
	results = {
		{ type = "item", name = "ev-multismelter", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 2 },
		{ type = "item", name = "kanthal-coil-block", amount = 8 }
	},
	main_product = "ev-multismelter",
	place_result = "ev-multismelter",
    stack_size = 10
}

   
   
---EV VACUUM FREEZER
make_electric_machine("ev-vacuum-freezer", "vacuum-freezer", "vacuum-freezer", { "mv-vacuum-freezer-recipes", "hv-vacuum-freezer-recipes", "ev-vacuum-freezer-recipes" }, "fr-vacuum-freezer", EU30_EV, 8, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-vacuum-freezer",
	icon = ICON_PATH .. "vacuum-freezer.png",
	ingredients = {
		{type = "item", name = "hv-vacuum-freezer", amount = 1},
		{type = "item", name = "ev-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "ev-vacuum-freezer", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-vacuum-freezer",
	place_result = "ev-vacuum-freezer",
    stack_size = 10
}



---EV MICROVERSE PROJECTOR
make_electric_machine("ev-microverse-projector", "small-microverse-projector", "small-microverse-projector", { "mv-microverse-projector-recipes", "hv-microverse-projector-recipes", "ev-microverse-projector-recipes" },
	"fr-small-microverse-projector", EU30_EV, 8, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north)  
})
create_item{
	name = "ev-microverse-projector",
	icon = ICON_PATH .. "small-microverse-projector.png",
	ingredients = {
      {type = "item", name = "hv-microverse-projector", amount = 1},
      {type = "item", name = "hv-energy-hatch", amount = 2},
    },
	results = {
		{ type = "item", name = "ev-microverse-projector", amount = 1 },
		{ type = "item", name = "mv-energy-hatch", amount = 2 },
	},
	main_product = "ev-microverse-projector",
	place_result = "ev-microverse-projector",
    stack_size = 10
}



---EV PUMPJACK
make_electric_machine("ev-drilling-rig", "mv-drilling-rig", "mv-drilling-rig", { "drilling-rig-recipes" }, "fr-drilling-rig", EU16_EV, 8, 1, 0.5, 3, 6.25, { 
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-drilling-rig-controller",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 20,
	ingredients = {
		{type = "item", name = "hv-drilling-rig-controller", amount = 1},
		{type = "item", name = "titanium-frame", amount = 12},
		{type = "item", name = "ev-circuit", amount = 4},
		{type = "item", name = "ev-motor", amount = 4},
		{type = "item", name = "ev-pump", amount = 4},
		{type = "item", name = "large-titanium-gear", amount = 12},
		{type = "fluid", name = "soldering-alloy", amount = 57.6 },
    }
}
create_item{
	name = "ev-drilling-rig",
	icon = ICON_PATH .. "mv-drilling-rig.png",
	ingredients = {
		{type = "item", name = "ev-drilling-rig-controller", amount = 1},
		{type = "item", name = "titanium-frame", amount = 15},
		{type = "item", name = "hv-energy-hatch", amount = 1},
        {type = "item", name = "lv-machine-hull", amount = 3},
		{type = "item", name = "stable-titanium-machine-casing", amount = 7}
    },
	results = {
		{type = "item", name = "ev-drilling-rig", amount = 1}
    },
	place_result = "ev-drilling-rig",
    stack_size = 10
}


 
---EV IMPLOSION COMPRESSOR
make_electric_machine("ev-implosion-compressor", "implosion-compressor", "implosion-compressor", { "lv-implosion-compressor-recipes", "mv-implosion-compressor-recipes", "hv-implosion-compressor-recipes" },
	"fr-implosion-compressor", EU30_EV, 8, 1, 0.5, 3, 3 )
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
	name = "ev-implosion-compressor",
	icon = ICON_PATH .. "implosion-compressor.png",
	ingredients = {
		{type = "item", name = "hv-implosion-compressor", amount = 1},
		{type = "item", name = "ev-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "ev-implosion-compressor", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-implosion-compressor",
	place_result = "ev-implosion-compressor",
    stack_size = 10
}



---EV CRACKER
make_electric_machine("ev-cracker", "cracker", "cracker", { "hv-cracker-recipes", "ev-cracker-recipes" }, "fr-cracker", EU30_EV, 8, 1, 0.5, 5, 3, {
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
	name = "ev-cracker",
	icon = ICON_PATH .. "cracker.png",
	ingredients = {
		{ type = "item", name = "hv-cracker", amount = 1 },
		{ type = "item", name = "ev-energy-hatch", amount = 1 },
	},
	results = {
		{ type = "item", name = "ev-cracker", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-cracker",
	place_result = "ev-cracker",
    stack_size = 10
}



---EV LARGE CHEMICAL REACTOR
make_electric_machine("ev-large-chemical-reactor", "large-chemical-reactor", "large-chemical-reactor", { "lv-chemical-reactor-recipes", "mv-chemical-reactor-recipes", "hv-chemical-reactor-recipes", "ev-chemical-reactor-recipes" },
	"fr-large-chemical-reactor", EU16_EV, 8, 1, 0.5, 5, 5, {
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
	name = "ev-large-chemical-reactor",
	stack_size = 10,
	icon = ICON_PATH .. "large-chemical-reactor.png",
	place_result = "ev-large-chemical-reactor",
	subgroup = "subgroup-ev-age-multiblocks",
	ingredients = {
		{type = "item", name = "hv-large-chemical-reactor", amount = 1},
		{type = "item", name = "ev-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "ev-large-chemical-reactor", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-large-chemical-reactor",
	place_result = "ev-large-chemical-reactor",
    stack_size = 10
}


   
---EV SHORT DISTILLATION TOWER
make_electric_machine("ev-short-distillation-tower", "short-distillation-tower", "short-distillation-tower", { "lv-distillation-recipes", "mv-distillation-recipes", "hv-distillation-recipes" },
	"fr-large-chemical-reactor", EU24_EV, 8, 1, 0.5, 3, 3, {
    fluid_port(-1, -1, "input", defines.direction.north),
    fluid_port( 1, -1, "input", defines.direction.north),
    fluid_port(-1,  1, "output", defines.direction.south),
    fluid_port( 1,  1, "output", defines.direction.south)
})
create_item{
	name = "ev-short-distillation-tower",
	stack_size = 10,
	place_result = "ev-short-distillation-tower",
	icon = ICON_PATH .. "short-distillation-tower.png",
	subgroup = "subgroup-ev-age-multiblocks",	
	ingredients = {
		{type = "item", name = "hv-short-distillation-tower", amount = 1},
		{type = "item", name = "ev-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "ev-short-distillation-tower", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-short-distillation-tower",
	place_result = "ev-short-distillation-tower",
    stack_size = 10
}



---EV TALL DISTILLATION TOWER
make_electric_machine("ev-tall-distillation-tower", "tall-distillation-tower", "tall-distillation-tower", { "lv-tall-distillation-recipes", "mv-tall-distillation-recipes", "hv-tall-distillation-recipes",
	"ev-tall-distillation-recipes" }, "fr-large-chemical-reactor", EU24_EV, 8, 1, 0.5, 3, 13, {
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
	name = "ev-tall-distillation-tower",
	stack_size = 10,
	icon = ICON_PATH .. "tall-distillation-tower.png",
	place_result = "ev-tall-distillation-tower",
	subgroup = "subgroup-hv-age-multiblocks",
	ingredients = {
		{type = "item", name = "hv-tall-distillation-tower", amount = 1},
		{type = "item", name = "ev-energy-hatch", amount = 1}
    },
	results = {
		{ type = "item", name = "ev-tall-distillation-tower", amount = 1 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
	},
	main_product = "ev-tall-distillation-tower",
	place_result = "ev-tall-distillation-tower",
    stack_size = 10
}    
