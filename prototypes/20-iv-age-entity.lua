--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096


  
---HIGH PRESSURE STEAM TURBINE
create_item{
	name = "high-pressure-steam-turbine-controller",
	ingredients = {
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "large-titanium-gear", amount = 4 },
		{ type = "item", name = "titanium-plate", amount = 12 },
	}
}
create_item{
	name = "high-pressure-steam-turbine",
	ingredients = {
		{ type = "item", name = "high-pressure-steam-turbine-controller", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
		{ type = "item", name = "iv-dynamo-hatch", amount = 1 },
		{ type = "item", name = "titanium-turbine-casing", amount = 27 },
	}
}



--------------------------------- 
---INDUSTRIAL MACERATION STACK---
---------------------------------

create_item{
	name = "industrial-maceration-stack-controller",
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 1 },
		{ type = "item", name = "ev-macerator", amount = 4 },
	}
}
create_item{
	name = "iv-industrial-maceration-stack",
	icon = ICON_PATH .. "industrial-maceration-stack.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-maceration-stack",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-maceration-stack-controller", amount = 1 },
		{ type = "item", name = "stable-titanium-machine-casing", amount = 38 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 8 },
	}
}



-----------------------------
---INDUSTRIAL WIRE FACTORY---
-----------------------------

create_item{
	name = "industrial-wire-factory-controller",
	ingredients = {
		{ type = "item", name = "iv-machine-casing", amount = 2 },
		{ type = "item", name = "blue-steel-plate", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "ev-wiremill", amount = 1 },
	}
}
create_item{
	name = "wire-factory-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "blue-steel-plate", amount = 4 },
		{ type = "item", name = "blue-steel-rod", amount = 4 },
		{ type = "item", name = "blue-steel-frame", amount = 1 },
	}
}
create_item{
	name = "iv-industrial-wire-factory",
	icon = ICON_PATH .. "industrial-wire-factory.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-wire-factory",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "iv-industrial-wire-factory", amount = 1 },
		{ type = "item", name = "wire-factory-casing", amount = 36 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}



-------------------------------
---INDUSTRIAL MATERIAL PRESS---
-------------------------------

create_item{
	name = "industrial-material-press-controller",
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 4 },
		{ type = "item", name = "ev-machine-casing", amount = 2 },
		{ type = "item", name = "ev-bending-machine", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
	}
}
create_item{
	name = "material-press-machine-casing",
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 4 },
		{ type = "item", name = "tantalloy-60-rod", amount = 2 },
		{ type = "item", name = "long-tumbaga-rod", amount = 2 },
		{ type = "item", name = "tumbaga-frame", amount = 1 },
	}
}
create_item{
	name = "iv-industrial-material-press",
	icon = ICON_PATH .. "industrial-material-press.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-material-press",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-material-press-controller", amount = 1 },
		{ type = "item", name = "material-press-machine-casing", amount = 20},
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}
create_item{
	name = "tumbaga-dust",
	category = "lv-mixer-recipes",
	energy_required = 12.9,
	ingredients = {
		{ type = "item", name = "gold-dust", amount = 7 },
		{ type = "item", name = "copper-dust", amount = 3 },
	},
	results = {
		{ type = "item", name = "tumbaga-dust", amount = 10 },
	}
}
create_item{
	name = "tumbaga-ingot",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "tumbaga-dust", amount = 64 },
    },
	results = {
		{type = "item", name = "tumbaga-ingot", amount = 64 }
    }
}

   
   
-------------------------------
---LARGE ELECTRIC COMPRESSOR---
-------------------------------
create_item{
	name = "large-electric-compressor-controller",
	ingredients = {
		{ type = "item", name = "ev-piston", amount = 2 },
		{ type = "item", name = "incoloy-903-plate", amount = 4 },
		{ type = "item", name = "ev-compressor", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 2 },
	}
}
create_item{
	name = "electric-compressor-casing",
	ingredients = {
		{ type = "item", name = "incoloy-903-plate", amount = 4 },
		{ type = "item", name = "steel-plate", amount = 2 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	}
}
create_item{
	name = "compression-pipe-casing",
	ingredients = {
		{ type = "item", name = "incoloy-903-plate", amount = 8 },
		{ type = "item", name = "large-titanium-gear", amount = 1 },
	}
}
create_item{
	name = "iv-large-electric-compressor",
	icon = ICON_PATH .. "large-electric-compressor.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-large-electric-compressor",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-electric-compressor-controller", amount = 1 },
		{ type = "item", name = "electric-compressor-casing", amount = 103 },
		{ type = "item", name = "compression-pipe-casing", amount = 60 },
		{ type = "item", name = "reinforced-glass", amount = 6 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}


  
-----------------------------
---MAGNETIC FLUX EXHIBITER---
-----------------------------
create_item{
	name = "magnetic-flux-exhibiter-controller",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "ev-polarizer", amount = 1 },
		{ type = "item", name = "iv-conveyor-module", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 2 }
	}
}
create_item{
	name = "magtech-casing",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "steel-plate", amount = 2 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	}
}
create_item{
	name = "electromagnet-housing",
	ingredients = {
		{ type = "item", name = "tungstensteel-rod", amount = 4 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "pvc-sheet", amount = 4 },
	}
}
create_item{
	name = "iron-electromagnet",
	energy_required = IV_SPEED * 30,
	category = "iv-assembling-machine-recipes",
	ingredients = {
		{ type = "item", name = "magnetic-iron-rod", amount = 8 },
		{ type = "item", name = "insane-voltage-coil", amount = 8 },
		{ type = "item", name = "pvc-sheet", amount = 4 },
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 32 },
		{ type = "fluid", name = "molten-stainless-steel", amount = 115.2 },
	}
}
create_item{
	name = "magnetic-neodymium-frame",
	category = "lv-assembling-machine-recipes",
	energy_required = 3.2,
	ingredients = {
		{ type = "item", name = "magnetic-neodymium-rod", amount = 4 },
	}
}
create_item{
	name = "iv-magnetic-flux-exhibiter",
	icon = ICON_PATH .. "magnetic-flux-exhibiter.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-magnetic-flux-exhibiter",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "magnetic-flux-exhibiter-controller", amount = 1 },
		{ type = "item", name = "magtech-casing", amount = 73 },
		{ type = "item", name = "magnetic-neodymium-frame", amount = 37 },
		{ type = "item", name = "reinforced-glass", amount = 12 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 3 },
		{ type = "item", name = "electromagnet-housing", amount = 1 },
		{ type = "item", name = "iron-electromagnet", amount = 1 },
	}
} 
    

  
------------------------------
---      FLUID SHAPER      ---
------------------------------
create_item{
	name = "fluid-shaper-controller",
	ingredients = {
		{ type = "item", name = "inconel-792-plate", amount = 4 },
		{ type = "item", name = "iv-pump", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "ev-fluid-solidifier", amount = 1 },
	}
}
create_item{
	name = "solidifier-casing",
	ingredients = {
		{ type = "item", name = "inconel-792-plate", amount = 4 },
		{ type = "item", name = "talonite-plate", amount = 2 },
		{ type = "item", name = "watertight-steel-frame", amount = 1 },
	}
}
create_item{
	name = "solidifier-radiator",
	ingredients = {
		{ type = "item", name = "grisium-plate", amount = 7 },
		{ type = "item", name = "solidifier-casing", amount = 1 },
		{ type = "item", name = "iv-pump", amount = 1 },
	}
}
create_item{
	name = "solidifier-hatch",
	category = "iv-assembling-machine-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "iv-machine-casing", amount = 1 },
		{ type = "item", name = "iv-sensor", amount = 1 },
		{ type = "item", name = "iv-pump", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 4 },
		{ type = "item", name = "wooden-chest", amount = 1 },
		{ type = "fluid", name = "molten-inconel-625", amount = 28.8 },
	}
}
create_item{
	name = "iv-fluid-shaper",
	subgroup = "subgroup-iv-age-multiblocks",
	icon = ICON_PATH .. "fluid-shaper.png",
--	place_result = "iv-fluid-shaper",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "fluid-shaper-controller", amount = 1 },
		{ type = "item", name = "solidifier-casing", amount = 115 },
		{ type = "item", name = "solidifier-radiator", amount = 13 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 4 },
		{ type = "item", name = "heat-proof-casing", amount = 4 },
		{ type = "item", name = "thorium-yttrium-glass-block", amount = 14 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
		{ type = "item", name = "solidifier-hatch", amount = 1 },
	}
} 



--------------------------------
---INDUSTRIAL CUTTING FACTORY---
--------------------------------
create_item{
	name = "industrial-cutting-factory-controller",
	ingredients = {
		{ type = "item", name = "maraging-steel-300-plate", amount = 4 },
		{ type = "item", name = "fine-platinum-wire", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "ev-cutting-machine", amount = 1 },
	}
}
create_item{
	name = "cutting-factory-frame",
	ingredients = {
		{ type = "item", name = "maraging-steel-300-plate", amount = 4 },
		{ type = "item", name = "stellite-plate", amount = 2},
		{ type = "item", name = "talonite-frame", amount = 1 },
	},
	results = {
		{ type = "item", name = "cutting-factory-frame", amount = 2 },
	}
}
create_item{
	name = "iv-industrial-cutting-factory",
	icon = ICON_PATH .. "industrial-cutting-factory.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-cutting-factory",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-cutting-factory-controller", amount = 1 },
		{ type = "item", name = "cutting-factory-frame", amount = 35 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
	}
}



--------------------------------
---    CHEMICAL BATH PLANT   ---
--------------------------------
create_item{
	name = "chemical-bath-plant-controller",
	ingredients = {
		{ type = "item", name = "grisium-plate", amount = 4 },
		{ type = "item", name = "talonite-plate", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 1 },
		{ type = "item", name = "ev-ore-washer", amount = 1 },
		{ type = "item", name = "ev-chemical-bath", amount = 1 },
	}
}
create_item{
	name = "bath-plant-casing",
	ingredients = {
		{ type = "item", name = "grisium-plate", amount = 4 },
		{ type = "item", name = "talonite-plate", amount = 2 },
		{ type = "item", name = "grisium-frame", amount = 1 },
	}
}
create_item{
	name = "iv-chemical-bath-plant",
	icon = ICON_PATH .. "chemical-bath-plant.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-chemical-bath-plant",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "chemical-bath-plant-controller", amount = 1 },
		{ type = "item", name = "bath-plant-casing", amount = 67 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}



--------------------------------
---  INDUSTRIAL ELECTROLYZER ---
--------------------------------
create_item{
	name = "industrial-electrolyzer-controller",
	ingredients = {
		{ type = "item", name = "stellite-plate", amount = 4 },
		{ type = "item", name = "ev-electrolyzer", amount = 1 },
		{ type = "item", name = "stellite-rotor", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 1 },
		{ type = "item", name = "iv-machine-casing", amount = 2 },
	}
}
create_item{
	name = "electrolyzer-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "potin-plate", amount = 4 },
		{ type = "item", name = "long-potin-rod", amount = 3 },
		{ type = "item", name = "long-chromium-rod", amount = 1 },
		{ type = "item", name = "potin-frame", amount = 1 },
	}
}
create_item{
	name = "potin-dust",
	category = "lv-mixer-recipes",
	energy_required = 13.3,
	ingredients = {
		{ type = "item", name = "lead-dust", amount = 2 },
		{ type = "item", name = "bronze-dust", amount = 2 },
		{ type = "item", name = "tin-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "potin-dust", amount = 5 },
	}
}
create_item{
	name = "potin-ingot",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "potin-dust", amount = 64 },
    },
	results = {
		{type = "item", name = "potin-ingot", amount = 64 }
    }
}  
create_item{
	name = "iv-industrial-electrolyzer",
	icon = ICON_PATH .. "industrial-electrolyzer.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "industrial-electrolyzer",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-electrolyzer-controller", amount = 1 },
		{ type = "item", name = "electrolyzer-casing", amount = 18 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}

  
  
--------------------------------
---       LARGE SIFTER       ---
--------------------------------
create_item{
	name = "large-sifter-controller",
	ingredients = {
		{ type = "item", name = "eglin-steel-plate", amount = 4 },
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "gold-cable", amount = 10 },
		{ type = "item", name = "processing-unit", amount = 4 },
		{ type = "item", name = "hv-piston", amount = 2 },
		{ type = "item", name = "item-filter", amount = 2 },
	}
}
create_item{
	name = "item-filter",
	category = "lv-assembling-machine-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "zinc-foil", amount = 16 },
		{ type = "item", name = "fine-steel-wire", amount = 64 },
	}
}
create_item{
	name = "industrial-sieve-casing",
	ingredients = {
		{ type = "item", name = "eglin-steel-plate", amount = 8 },
		{ type = "item", name = "tumbaga-frame", amount = 1 },
	}
}
create_item{
	name = "large-sieve-grate",
	ingredients = {
		{ type = "item", name = "eglin-steel-frame", amount = 4 },
		{ type = "item", name = "fine-steel-wire", amount = 5 },
	}
}
create_item{
	name = "eglin-steel-dust",
	category = "lv-mixer-recipes",
	energy_required = 6.5,
	ingredients = {
		{ type = "item", name = "iron-dust", amount = 4 },
		{ type = "item", name = "kanthal-dust", amount = 1 },
		{ type = "item", name = "invar-dust", amount = 5 },
		{ type = "item", name = "phosphorus", amount = 1 },
		{ type = "item", name = "raw-silicon", amount = 4 },
		{ type = "item", name = "carbon", amount = 1 },
	},
	results = {
		{type = "item", name = "eglin-steel-dust", amount = 16 }
    }
}
create_item{
	name = "eglin-steel-ingot",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "eglin-steel-dust", amount = 64 },
    },
	results = {
		{type = "item", name = "eglin-steel-ingot", amount = 64 }
    }
} 
create_item{
	name = "hv-large-sifter",
	icon = ICON_PATH .. "large-sifter.png",
	subgroup = "subgroup-hv-age-multiblocks",
--	place_result = "hv-large-sifter",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-sifter-controller", amount = 1 },
		{ type = "item", name = "industrial-sieve-casing", amount = 49 },
		{ type = "item", name = "large-sieve-grate", amount = 18 },
		{ type = "item", name = "hv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}
 
  
  
--------------------------------
---INDUSTRIAL PRECISION LATHE---
--------------------------------
create_item{
	name = "industrial-precision-lathe-controller",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "ev-lathe", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "ev-motor", amount = 2 },
	}
}
create_item{
	name = "platinum-item-pipe-casing",
	ingredients = {
		{ type = "item", name = "platinum-plate", amount = 16 },
		{ type = "item", name = "platinum-frame", amount = 1 },
	}
}
create_item{
	name = "iv-industrial-precision-lathe",
	icon = ICON_PATH .. "industrial-electrolyzer.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "industrial-electrolyzer",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-precision-lathe-controller", amount = 1 },
		{ type = "item", name = "grate-machine-casing", amount = 9 },
		{ type = "item", name = "reinforced-glass", amount = 32 },
		{ type = "item", name = "platinum-item-pipe-casing", amount = 4 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 54 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}  
  
 
---------------------------
---   LARGE EXTRACTOR   ---
---------------------------
create_item{
	name = "large-extractor-controller",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "ev-extractor", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "iv-pump", amount = 1 },
		{ type = "item", name = "iv-conveyor-module", amount = 1 },
	}
}
create_item{
	name = "robust-tungstensteel-machine-casing",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 6 },
		{ type = "item", name = "tungstensteel-frame", amount = 1 },
	}
}
create_item{
	name = "iv-solenoid-superconductor-coil",
	energy_required = 10 * IV_SPEED,
	tier = "iv",
	ingredients = {
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 16 },
		{ type = "item", name = "tungsten-cable", amount = 4 },
		{ type = "item", name = "tungstensteel-plate", amount = 3 },
		{ type = "item", name = "long-chromium-rod", amount = 8 },
		{ type = "item", name = "hssg-plate", amount = 4 },
--		{ type = "item", name = "540k-sp-coolant-cell", amount = 1 },
		{ type = "item", name = "iv-pump", amount = 1 },
		{ type = "fluid", name = "soldering-alloy", amount = 28.8 },
	}
}
create_item{
	name = "iv-large-extractor",
	icon = ICON_PATH .. "large-extractor.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-large-extractor",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "large-extractor-controller", amount = 1 },
		{ type = "item", name = "robust-tungstensteel-machine-casing", amount = 52 },
		{ type = "item", name = "thorium-yttrium-glass-block", amount = 36 },
		{ type = "item", name = "rtm-alloy-coil-block", amount = 24 },
		{ type = "item", name = "iv-solenoid-superconductor-coil", amount = 7 },
		{ type = "item", name = "black-steel-frame", amount = 24 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}
  
  
  
------------------------------------
---HYPER INTENSITY LASER ENGRAVER---
------------------------------------
create_item{
	name = "hyper-intensity-laser-engraver-controller",
	ingredients = {
		{ type = "item", name = "nitinol-60-plate", amount = 4 },
		{ type = "item", name = "ev-laser-engraver", amount = 1 },
		{ type = "item", name = "iv-emitter", amount = 3 },
		{ type = "item", name = "luv-circuit", amount = 1 },
	}
}
create_item{
	name = "laser-containment-casing",
	ingredients = {
		{ type = "item", name = "stellite-plate", amount = 6 },
		{ type = "item", name = "nitinol-60-frame", amount = 1 },
	}
}
create_item{
	name = "iv-laser-source-hatch",
	category = "iv-assembling-machine-recipes",
	energy_required = 10 * IV_SPEED,
	ingredients = {
--		{ type = "item", name = "low-power-laser-pipe", amount = 16 },
--		{ type = "item", name = "cubic-zirconia-lens", amount = 1 },
		{ type = "item", name = "tungsten-cable", amount = 32 },
		{ type = "item", name = "iv-dynamo-hatch", amount = 2 },
		{ type = "item", name = "iv-emitter", amount = 2 },
	}
}
create_item{
	name = "laser-resistant-plate",
	energy_required = 15 * IV_SPEED,
	tier = "iv",
	ingredients = {
		{ type = "item", name = "reinforced-stone", amount = 1 },
		{ type = "fluid", name = "molten-hastelloy-x", amount = 115.2 },
	}
}
create_item{
	name = "iv-hyper-intensity-laser-engraver",
	icon = ICON_PATH .. "hyper-intensity-laser-engraver.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-hyper-intensity-laser-engraver",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "hyper-intensity-laser-engraver-controller", amount = 1 },
		{ type = "item", name = "laser-containment-casing", amount = 55 },
		{ type = "item", name = "iv-laser-source-hatch", amount = 1 },
		{ type = "item", name = "thorium-yttrium-glass-block", amount = 3 },
		{ type = "item", name = "tungstensteel-frame", amount = 9 },
		{ type = "item", name = "laser-resistant-plate", amount = 1 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}   
  
  
  
------------------------------------
--- INDUSTRIAL EXTRUSION MACHINE ---
------------------------------------
create_item{
	name = "industrial-extrusion-machine-controller",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "inconel-690-plate", amount = 4 },
		{ type = "item", name = "ev-extruder", amount = 1 },
		{ type = "item", name = "iv-piston", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 2 },
	}
}
create_item{
	name = "inconel-reinforced-casing",
	ingredients = {
		{ type = "item", name = "inconel-690-plate", amount = 4 },
		{ type = "item", name = "talonite-plate", amount = 2 },
		{ type = "item", name = "staballoy-frame", amount = 1 },
	}
}
create_item{
	name = "iv-industrial-extrusion-machine",
	icon = ICON_PATH .. "industrial-extrusion-machine.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-extrusion-machine",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-extrusion-machine-controller", amount = 1 },
		{ type = "item", name = "inconel-reinforced-casing", amount = 36 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}      
  
  
  
------------------------------------
---    INDUSTRIAL CENTRIFUGE     ---
------------------------------------
create_item{
	name = "industrial-centrifuge-controller",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "inconel-792-plate", amount = 2 },
		{ type = "item", name = "maraging-steel-250-plate", amount = 2 },
		{ type = "item", name = "stainless-steel-plate", amount = 12 },
		{ type = "item", name = "ev-centrifuge", amount = 1 },
		{ type = "item", name = "ev-machine-casing", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
	}
}
create_item{
	name = "centrifuge-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "inconel-792-plate", amount = 2 },
		{ type = "item", name = "maraging-steel-250-plate", amount = 4 },
		{ type = "item", name = "tumbaga-rod", amount = 3 },
	}
}
create_item{
	name = "iv-industrial-centrifuge",
	icon = ICON_PATH .. "industrial-centrifuge.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-centrifuge",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-centrifuge-controller", amount = 1 },
		{ type = "item", name = "inconel-reinforced-casing", amount = 18 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}


  
------------------------------------
---       INDUSTRIAL MIXER       ---
------------------------------------
create_item{
	name = "industrial-mixer-controller",
	ingredients = {
		{ type = "item", name = "staballoy-plate", amount = 4 },
		{ type = "item", name = "zirconium-carbide-plate", amount = 2 },
		{ type = "item", name = "ev-mixer", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 2 },
	}
}
create_item{
	name = "multi-use-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "staballoy-plate", amount = 4 },
		{ type = "item", name = "stainless-steel-plate", amount = 2 },
		{ type = "item", name = "zirconium-carbide-frame", amount = 1 },
	}
}
create_item{
	name = "iv-industrial-mixer",
	icon = ICON_PATH .. "industrial-mixer.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-industrial-mixer",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "industrial-mixer-controller", amount = 1 },
		{ type = "item", name = "multi-use-casing", amount = 26 },
		{ type = "item", name = "titanium-turbine-casing", amount = 2 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
	}
}


  
--------------------------------
---       TURBOCAN PRO       ---
--------------------------------
create_item{
	name = "turbocan-pro-controller",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 24 },
		{ type = "item", name = "ev-canning-machine", amount = 2 },
		{ type = "item", name = "hv-pump", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
	}
}
create_item{
	name = "iv-turbocan-pro",
	icon = ICON_PATH .. "turbocan-pro.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-turbocan-pro",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "turbocan-pro-controller", amount = 1 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 91 },
		{ type = "item", name = "steel-pipe-casing", amount = 24 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 5 },
	}
}


  
--------------------------
---       ZYNGEN       ---
--------------------------
create_item{
	name = "zyngen-controller",
	category = "ev-assembling-machine-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "ev-alloy-smelter", amount = 1 },
		{ type = "item", name = "large-tantalum-carbide-gear", amount = 16 },
		{ type = "item", name = "titanium-bolt", amount = 64 },
		{ type = "item", name = "incoloy-ds-plate", amount = 16 },
		{ type = "fluid", name = "molten-inconel-792", amount = 115.2 },
	}
}
create_item{
	name = "integral-encasement-v",
	category = "ev-assembling-machine-recipes",
	energy_required = 20 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "ev-machine-casing", amount = 1 },
		{ type = "item", name = "incoloy-ds-plate", amount = 8 },
		{ type = "item", name = "large-incoloy-ds-gear", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "platinum-cable", amount = 8 },
		{ type = "fluid", name = "molten-inconel-792", amount = 144 },
	}
}
create_item{
	name = "iv-zyngen",
	icon = ICON_PATH .. "industrial-mixer.png",
	subgroup = "subgroup-iv-age-multiblocks",
--	place_result = "iv-zyngen",
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "zyngen-controller", amount = 1 },
		{ type = "item", name = "inconel-reinforced-casing", amount = 12 },
		{ type = "item", name = "rtm-alloy-coil-block", amount = 16 },
		{ type = "item", name = "integral-encasement-v", amount = 8 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
	}
}
--[[
  
------------------------------------
---  LARGE SCALE AUTO ASSEMBLER  ---
------------------------------------
create_item{
	name = "large-scale-auto-assembler-controller",
	category = "iv-assembling-machine-recipes",
	energy_required = 300 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hastelloy-x-structural-block", amount = 4 },
		{ type = "item", name = "control-circuit", amount = 1 },
		{ type = "item", name = "platinum-cable", amount = 128 },
		{ type = "item", name = "gregtech-computer-cube", amount = 1 },
		{ type = "item", name = "iv-transmission-component", amount = 1 },
		{ type = "fluid", name = "molten-pikyonium-64b", amount = 115.2 },
	}
}
create_item{
	name = "hastelloy-x-structural-block",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "ev-machine-casing", amount = 1 },
		{ type = "item", name = "steel-plate", amount = 2 },
		{ type = "item", name = "large-hastelloy-x-gear", amount = 1 },
		{ type = "item", name = "hastelloy-c276-frame", amount = 1 },
		{ type = "item", name = "inconel-792-ring", amount = 2 },
	},
	results = {
		{ type = "item", name = "hastelloy-x-structural-block", amount = 2 },
	}
}
create_item{
	name = "control-circuit",
	tier = "hv",
	energy_required = 240 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "hv-field-generator", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 1 },
	}
}
create_item{
	name = "bulk-production-frame",
	category = "iv-assembling-machine-recipes",
	energy_required = 120 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "multi-use-casing", amount = 1 },
		{ type = "item", name = "iridium-reinforced-block", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 16 },
		{ type = "item", name = "inconel-625-screw", amount = 32 },
		{ type = "item", name = "energy-crystal-bolt", amount = 16 },
		{ type = "item", name = "zeron-100-plate", amount = 8 },
		{ type = "fluid", name = "molten-trinium-naquadah-carbonate", amount = 57.6 },
	}
}
create_item{
	name = "iv-transmission-component",
	category = "iv-assembling-machine-recipes",
	energy_required = 5 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "iv-emitter", amount = 2 },
		{ type = "item", name = "iv-sensor", amount = 2 },
	}
}
create_item{
	name = "gregtech-computer-cube",
	category = "iv-assembling-machine-recipes",
	energy_required = 180 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "data-orb", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "computer-monitor", amount = 4 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "fluid", name = "molten-tantalum", amount = 230.4 },
	}
}   
   
  
  
------------------------------------
---     INDUSTRIAL AUTOCLAVE     ---
------------------------------------
create_item{
	name = "industrial-autoclave-controller",
	category = "luv-assembling-machine-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "pressure-containment-casing", amount = 4 },
--		{ type = "item", name = "iv-autoclave", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "lafium-compound-plate", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 115.2 },
	}
}
create_item{
	name = "pressure-containment-casing",
	category = "iv-assembling-machine-recipes",
	energy_required = 20 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "ptfe-frame", amount = 1 },
		{ type = "fluid", name = "molten-stainless-steel", amount = 115.2 },
	}
}
create_item{
	name = "osmium-item-pipe-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "osmium-plate", amount = 16 },
		{ type = "item", name = "osmium-frame", amount = 1 },
	}
}
create_item{
	name = "luv-industrial-autoclave",
	ingredients = {
		{ type = "item", name = "industrial-autoclave-controller", amount = 1 },
		{ type = "item", name = "pressure-containment-casing", amount = 137 },
		{ type = "item", name = "rtm-alloy-coil-block", amount = 7 },
		{ type = "item", name = "osmium-pipe-casing", amount = 14 },
		{ type = "item", name = "ptfe-frame", amount = 42 },
		{ type = "item", name = "reinforced-glass", amount = 42 },
		{ type = "item", name = "lv-machine-casing", amount = 6 },
		{ type = "item", name = "luv-energy-hatch", amount = 1 },
	}
}   

  
  
------------------------------------
---    MATTER FABRICATION CPU    ---
------------------------------------
create_item{
	name = "matter-fabrication-cpu-controller",
	ingredients = {
		{ type = "item", name = "advanced-nitinol-plate", amount = 4 },
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
		{ type = "item", name = "uv-circuit", amount = 2 },
	}
}
create_item{
	name = "matter-fabricator-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "inconel-690-frame", amount = 1 },
		{ type = "item", name = "inconel-792-rod", amount = 4 },
		{ type = "item", name = "niobium-carbide-plate", amount = 4 },
	}
}
create_item{
	name = "containment-casing",
	category = "luv-assembly-line-recipes",
	energy_required = 1200 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "iv-field-generator", amount = 32 },
		{ type = "item", name = "ev-motor", amount = 64 },
		{ type = "item", name = "lapotronic-energy-orb", amount = 32 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 384 },
		{ type = "item", name = "platinum-wire", amount = 1024 },
		{ type = "item", name = "naquadria-plate", amount = 64 },
		{ type = "item", name = "gadoinium-dust", amount = 32 },
		{ type = "item", name = "samarium-dust", amount = 16 },
		{ type = "item", name = "large-arcanite-gear", amount = 8 },
		{ type = "item", name = "iv-circuit", amount = 64 },
		{ type = "item", name = "luv-circuit", amount = 32 },
		{ type = "item", name = "zpm-circuit", amount = 16 },
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "item", name = "zpm-coil-wire", amount = 64 },
		{ type = "fluid", name = "molten-nitinol-60", amount = 518.4 },
		{ type = "fluid", name = "molten-energy-crystal", amount = 1036.8 },
		{ type = "fluid", name = "molten-tumbaga", amount = 4147.2 },
		{ type = "fluid", name = "molten-nichrome", amount = 230.4 },
	},
	results = {
		{ type = "item", name = "containment-casing", amount = 32 },
	}
}
create_item{
	name = "matter-generation-coil",
	ingredients = {
		{ type = "item", name = "zeron-100-plate", amount = 4 },
		{ type = "item", name = "pikyonium-64b-plate", amount = 2 },
		{ type = "item", name = "stellite-frame", amount = 2 },
		{ type = "item", name = "uv-machine-casing", amount = 1 },
	}
}
create_item{
	name = "matter-fabrication-cpu",
	ingredients = {
		{ type = "item", name = "matter-fabrication-cpu-controller", amount = 1 },
		{ type = "item", name = "matter-fabrication-casing", amount = 41 },
		{ type = "item", name = "containment-casing", amount = 24 },
		{ type = "item", name = "matter-generation-coil", amount = 9 },
		{ type = "item", name = "lv-machine-casing", amount = 6 },
		{ type = "item", name = "luv-energy-hatch", amount = 1 },
	}
}

]]--