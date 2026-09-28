--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--------------------
---   ALUMINIUM  ---
--------------------  

---MICROMINER BAUXITE 
create_recipe{
    name = "microminer-bauxite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = {
      {type = "item", name = "tier-one-microminer-output", amount = 3}
    },
    results = {
      {type = "item", name = "raw-bauxite", amount = 48 },
      {type = "item", name = "raw-aluminium", amount = 16 },
    },
	main_product = "raw-bauxite"
}



---ELECTROLYZE BRICK DUST  
create_recipe{
	recipe_name = "brick-dust-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 54.6,
	ingredients = {
      {type = "item", name = "brick-dust", amount = 17}
    },
	results = {
      {type = "item", name = "alumina", amount = 5 },
      {type = "item", name = "silicon-dioxide", amount = 12 },
    },
	main_product = "alumina"
}


  
---ELECTROLYZE CLAY DUST  
create_recipe{
	recipe_name = "clay-dust-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 18.2,
	ingredients = {
      {type = "item", name = "clay-dust", amount = 16},
    },
	results = {
      {type = "item", name = "sodium", amount = 2},
      {type = "item", name = "lithium", amount = 1},
      {type = "item", name = "alumina", amount = 5},
      {type = "item", name = "silicon-dioxide", amount = 6},
      {type = "fluid", name = "water", amount = 200},
    },
	main_product = "alumina"
}



---ELECTROLYZE BAUXITE DUST  
create_recipe{
	recipe_name = "bauxite-dust-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 35.1 * MV_SPEED,
	ingredients = {
      {type = "item", name = "bauxite-dust", amount = 39 },
    },
	results = {
      {type = "item", name = "rutile-dust", amount = 2 },
      {type = "item", name = "aluminium-dust", amount = 7 },
      {type = "item", name = "alumina", amount = 20 },
      {type = "fluid", name = "hydrogen", amount = 1000},
    },
	main_product = "alumina"
}



---ALUMINA
create_item{
	name = "alumina",
	category = "mv-chemical-reactor-recipes",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "aluminium-dust", amount = 4 },
		{ type = "item", name = "silicon-dioxide", amount = 9 },
	},
	results = {
		{ type = "item", name = "alumina", amount = 10 },
		{ type = "item", name = "raw-silicon", amount = 3 },
	},
	main_product = "alumina"
}
   
  
  
---ALUMINIUM INGOT
create_item{
	name = "aluminium-ingot",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "alumina", amount = 10 },
		{ type = "item", name = "cryolite", amount = 5 },
	},
	results = {
		{ type = "item", name = "aluminium-ingot", amount = 4 },
	}
}
create_recipe{
	recipe_name = "aluminium-ingot-carbon",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 120,
	ingredients = {
		{ type = "item", name = "alumina", amount = 10 },
		{ type = "item", name = "carbon", amount = 3 }
	},
	results = {
		{ type = "item", name = "aluminium-ingot", amount = 4 },
		{ type = "fluid", name = "carbon-dioxide", amount = 300 },
	},
	main_product = "aluminium-ingot"
}
   
   








------------------------
---   MV COMPONENTS  ---
------------------------   
   
---MAGNETIC STEEL ROD   
create_item{
	name = "magnetic-steel-rod",
	category = "lv-polarizer-recipes",
	energy_required = 3.2,
	ingredients = {
		{ type = "item", name = "steel-rod", amount = 1 },
	}
}
create_item{
	name = "long-magnetic-steel-rod",
	category = "lv-polarizer-recipes",
	energy_required = 6.4,
	ingredients = {
		{ type = "item", name = "long-steel-rod", amount = 1 },
	}
}



---COPPER CABLE
create_item{
	name = "copper-cable",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "copper-wire", amount = 1 },
		{ type = "fluid", name = "liquid-rubber", amount = 14.4 },
	}
}
create_recipe{
	name = "copper-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "copper-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "copper-cable", amount = 4 },
	},
}
create_item{
	name = "copper-cable-16x",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "copper-wire", amount = 16 },
		{ type = "fluid", name = "silicone-rubber", amount = 36 },
	}
}


	
---MV MOTOR
create_item{
	name = "mv-motor",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "aluminium-rod", amount = 2 },
		{ type = "item", name = "magnetic-steel-rod", amount = 1 },
		{ type = "item", name = "cupronickel-wire", amount = 8 },
		{ type = "item", name = "copper-cable", amount = 2 },
	}
}
create_recipe{
	recipe_name = "mv-motor-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 6 },
		{ type = "item", name = "long-aluminium-rod", amount = 48 },
		{ type = "item", name = "long-magnetic-steel-rod", amount = 24 },
		{ type = "item", name = "cupronickel-wire-16x", amount = 24 },
	},
	results = {
		{ type = "item", name = "mv-motor", amount = 64 },
	},
}   
   
   
   
---ALUMINIUM GEAR
create_recipe{
	recipe_name = "aluminium-gear-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "aluminium-plate", amount = 1 },
		{ type = "item", name = "aluminium-rod", amount = 2 },
	},
	results = {
		{ type = "item", name = "aluminium-gear", amount = 1 },
	}
}     
   
   
   
---MV PISTON
create_item{
	name = "mv-piston",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "aluminium-plate", amount = 3 },
		{ type = "item", name = "aluminium-rod", amount = 2 },
		{ type = "item", name = "aluminium-gear", amount = 1 },
		{ type = "item", name = "mv-motor", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 2 },
	}
} 
create_recipe{
	recipe_name = "mv-piston-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 6 },
		{ type = "item", name = "large-aluminium-gear", amount = 12 },
		{ type = "item", name = "mv-motor", amount = 48 },
		{ type = "item", name = "long-aluminium-rod", amount = 48 },
		{ type = "item", name = "dense-aluminium-plate", amount = 16 },
	},
	results = {
		{ type = "item", name = "mv-piston", amount = 64 },
	},
}


   
---BRONZE RING
create_recipe{
	recipe_name = "bronze-ring-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "bronze-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "bronze-ring", amount = 1 },
	}
}

   
   
---BRONZE ROTOR
create_recipe{
	recipe_name = "bronze-rotor-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "bronze-plate", amount = 4 },
		{ type = "item", name = "bronze-ring", amount = 1 },
		{ type = "item", name = "bronze-screw", amount = 1 },
	},
	results = {
		{ type = "item", name = "bronze-rotor", amount = 1 },
	}
}
   


---MV PUMP
create_item{
	name = "mv-pump",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "mv-motor", amount = 1 },
		{ type = "item", name = "bronze-rotor", amount = 1 },
		{ type = "item", name = "steel-plate", amount = 3 },
		{ type = "item", name = "bronze-screw", amount = 1 },
		{ type = "item", name = "rubber-ring", amount = 2 },
		{ type = "item", name = "copper-cable", amount = 1 },
	}
}
create_recipe{
	recipe_name = "mv-pump-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 3 },
		{ type = "item", name = "mv-motor", amount = 96 },
		{ type = "item", name = "dense-steel-plate", amount = 16 },
		{ type = "item", name = "bronze-rotor", amount = 48 },
		{ type = "item", name = "bronze-screw", amount = 48 },
		{ type = "fluid", name = "silicone-rubber", amount = 345.6 },
	},
	results = {
		{ type = "item", name = "mv-pump", amount = 64 },
	},
}
  
   
   
---MV CONVEYOR MODULE
create_item{
	name = "mv-conveyor-module",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "mv-motor", amount = 2 },
		{ type = "item", name = "copper-cable", amount = 1 },
		{ type = "item", name = "rubber-sheet", amount = 6 },
	}
}
create_recipe{
	recipe_name = "mv-conveyor-module-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 3 },
		{ type = "item", name = "mv-motor", amount = 96 },
		{ type = "fluid", name = "silicone-rubber", amount = 4147.2 },
	},
	results = {
		{ type = "item", name = "mv-conveyor-module", amount = 64 },
	},
}



---MV CIRCUIT WRAP
create_item{
	name = "mv-circuit-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "advanced-circuit", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}



---MV ROBOT ARM
create_item{
	name = "mv-robot-arm",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "mv-motor", amount = 2 },
		{ type = "item", name = "aluminium-rod", amount = 2 },
		{ type = "item", name = "mv-piston", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 3 },
	}
}
create_recipe{
	recipe_name = "mv-robot-arm-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 9 },
		{ type = "item", name = "mv-motor", amount = 96 },
		{ type = "item", name = "mv-piston", amount = 48 },
		{ type = "item", name = "long-aluminium-rod", amount = 48 },
		{ type = "item", name = "mv-circuit-wrap", amount = 3 },
	},
	results = {
		{ type = "item", name = "mv-robot-arm", amount = 64 },
	},
}



---MV FIELD GENERATOR
create_item{
	name = "mv-field-generator",
	category = "mv-assembling-machine-recipes",
	subgroup = "subgroup-mv-components",
	energy_required = MV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "aluminium-plate", amount = 2 },
		{ type = "item", name = "advanced-circuit", amount = 2 },
		{ type = "item", name = "pulsating-iron-wire", amount = 16 },
		{ type = "item", name = "eye-of-ender", amount = 1 },
	}
}
create_recipe{
	recipe_name = "mv-field-generator-coal",
	category = "uv-coal-recipes",
	energy_required = MV_SPEED * 1440,
	ingredients = {
		{ type = "item", name = "pulsating-iron-wire-16x", amount = 48 },
		{ type = "item", name = "dense-aluminium-plate", amount = 12 },
		{ type = "item", name = "mv-circuit-wrap", amount = 6 },
		{ type = "item", name = "eye-of-ender", amount = 48 },
	},
	results = {
		{ type = "item", name = "mv-field-generator", amount = 64 },
	},
}



---MOLTEN CUPRONICKEL
create_recipe{
	recipe_name = "molten-cupronickel",
	category = "lv-extractor-recipes",
	energy_required = 3.15,
	ingredients = {
		{ type = "item", name = "cupronickel-ingot", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-cupronickel", amount = 14.4 },
	}
}
  
  
  
---KANTHAL COIL BLOCK (HV)
create_item{
	name = "kanthal-coil-block",
	category = "mv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "kanthal-wire", amount = 16 },
		{ type = "item", name = "aluminium-foil", amount = 8 },
		{ type = "fluid", name = "molten-cupronickel", amount = 14.4 },
	}
}
   
   
   
---MV EMITTER
create_item{
	name = "mv-emitter",
	ingredients = {
		{ type = "item", name = "electrum-rod", amount = 4 },
		{ type = "item", name = "emerald", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 2 },
		{ type = "item", name = "copper-cable", amount = 2 }
	}
}
create_recipe{
	recipe_name = "mv-emitter-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "copper-cable-16x", amount = 6 },
		{ type = "item", name = "mv-circuit-wrap", amount = 6 },
		{ type = "item", name = "emerald", amount = 48 },
		{ type = "item", name = "long-electrum-rod", amount = 96 },
	},
	results = {
		{ type = "item", name = "mv-emitter", amount = 64 },
	},
}    
   
   
   
---MV SENSOR
create_item{
	name = "mv-sensor",
	ingredients = {
		{ type = "item", name = "electrum-rod", amount = 1 },
		{ type = "item", name = "aluminium-plate", amount = 4 },
		{ type = "item", name = "emerald", amount = 1 },
		{ type = "item", name = "advanced-circuit", amount = 1 },
	}
}   
create_recipe{
	recipe_name = "mv-sensor-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "dense-aluminium-plate", amount = 21 },
		{ type = "item", name = "mv-circuit-wrap", amount = 3 },
		{ type = "item", name = "emerald", amount = 48 },
		{ type = "item", name = "long-electrum-rod", amount = 24 },
	},
	results = {
		{ type = "item", name = "mv-sensor", amount = 64 },
	},
} 



---MV MACHINE CASING
create_item{
	name = "mv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "aluminium-plate", amount = 8 },
	}
} 
 


---MV MACHINE HULL
create_item{
	name = "mv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "mv-machine-casing", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 },
	}
} 
create_recipe{
	recipe_name = "mv-machine-hull-crafting-table",
	ingredients = {
		{ type = "item", name = "mv-machine-casing", amount = 1 },
		{ type = "item", name = "aluminium-plate", amount = 1 },
		{ type = "item", name = "iron-plate", amount = 2 },
		{ type = "item", name = "copper-cable", amount = 2 },
	},
	results = {
		{ type = "item", name = "mv-machine-hull", amount = 1 },
	}
} 
   
   
   
---MEDIUM VOLTAGE COIL
create_item{
	name = "medium-voltage-coil",
	category = "mv-assembling-machine-recipes",
	energy_required = 10 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-steel-rod", amount = 1 },
		{ type = "item", name = "fine-aluminium-wire", amount = 16 },
	}
}



---ULPIC WAFER
create_item{
	name = "ulpic-wafer",
	recipe_name = "ulpic-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 90,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "ulpic-wafer", amount = 2 },
	}
} 
create_recipe{
	recipe_name = "ulpic-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 100,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 }
	},
	results = {
		{ type = "item", name = "ulpic-wafer", amount = 8 }
	}
}
   
   
   
---ULPIC CHIP
create_item{
	name = "ultra-low-powered-integrated-circuit",
	category = "mv-cutting-machine-recipes",
	energy_required = 90,
	ingredients = {
		{ type = "item", name = "ulpic-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "ultra-low-powered-integrated-circuit", amount = 6 },
	}
}



---SODIUM POTASSIUM 
create_recipe{
	recipe_name = "sodium-potassium",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "sodium", amount = 1 },
		{ type = "item", name = "potassium", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "sodium-potassium", amount = 100 },
	}
}
   
   
   
---MV ENERGY HATCH
create_item{
	name = "mv-energy-hatch",
	category = "mv-assembling-machine-recipes",
	energy_required = 10 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "mv-machine-hull", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 2 },
		{ type = "item", name = "medium-voltage-coil", amount = 1 },
		{ type = "item", name = "ultra-low-powered-integrated-circuit", amount = 1 },
		{ type = "fluid", name = "sodium-potassium", amount = 100 },
	}
}



---------------------
---   RUBY JUICE  ---
---------------------  
 
create_recipe{
	recipe_name = "ruby-juice",
	category = "mv-mixer-recipes",
	energy_required = 36,
	ingredients = {
		{ type = "item", name = "crushed-ruby", amount = 9 },
		{ type = "item", name = "sodium-hydroxide", amount = 1 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 900 },
	},
	results = {
		{ type = "fluid", name = "ruby-juice", amount = 900 },
	}
}
create_recipe{
	recipe_name = "ruby-juice-centrifuging",
	category = "mv-centrifuge-recipes",
	energy_required = 4.5,
	ingredients = {
		{ type = "fluid", name = "ruby-juice", amount = 100 },
	},
	results = {
		{ type = "item", name = "aluminium-hydroxide", amount = 2 },
		{ type = "item", name = "chromium-dust", amount = 1, probability = 0.5 },
		{ type = "item", name = "iron-dust", amount = 1, probability = 0.03 },
		{ type = "item", name = "vanadium-dust", amount = 1, probability = 0.02 },
		{ type = "item", name = "magnesium", amount = 1, probability = 0.02 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	},
	main_product = "chromium-dust"
}    
create_recipe{
	recipe_name = "aluminium-hydroxide-blasting",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "aluminium-hydroxide", amount = 8 },
	},
	results = {
		{ type = "item", name = "alumina", amount = 5 },
	}
}


   
---------------------
---      PVC      ---
--------------------- 

create_recipe{
	recipe_name = "vinyl-chloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "chlorine", amount = 200 },
		{ type = "fluid", name = "ethylene", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "vinyl-chloride", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	},
	main_product = "vinyl-chloride"
}
create_recipe{
	recipe_name = "polyvinyl-chloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "vinyl-chloride", amount = 14.4 },
		{ type = "fluid", name = "oxygen", amount = 1000 }
	},
	results = {
		{ type = "fluid", name = "polyvinyl-chloride", amount = 21.6 }
	}
}
create_item{
	name = "pvc-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 0.5,
	ingredients = {
		{ type = "fluid", name = "polyvinyl-chloride", amount = 14.4 }
	},
}  
create_item{
	name = "thin-pvc-sheet",
	category = "lv-bending-machine-recipes",
	energy_required = 0.5,
	ingredients = {
		{ type = "item", name = "pvc-sheet", amount = 1 }
	},
	results = {
		{ type = "item", name = "thin-pvc-sheet", amount = 4 }
	}
}




---------------------------
---   MICROPROCESSORS   ---
--------------------------- 

---PLASTIC CIRCUIT BOARD
create_item{
	name = "plastic-circuit-board",
	recipe_name = "plastic-circuit-board-pe",
	category = "lv-chemical-reactor-recipes",
	energy_required = 25,
	ingredients = {
		{ type = "item", name = "polyethylene-sheet", amount = 1 },
		{ type = "item", name = "copper-foil", amount = 4 },
		{ type = "fluid", name = "sulfuric-acid", amount = 25 },
	},
}
create_recipe{
	recipe_name = "plastic-circuit-board-pvc",
	category = "lv-chemical-reactor-recipes",
	energy_required = 25,
	ingredients = {
			{ type = "item", name = "pvc-sheet", amount = 1 },
			{ type = "item", name = "copper-foil", amount = 4 },
			{ type = "fluid", name = "sulfuric-acid", amount = 25},
		},
	results = {
			{ type = "item", name = "plastic-circuit-board", amount = 2 },
		}
}

create_recipe{
	recipe_name = "plastic-circuit-board-ptfe",
	category = "lv-chemical-reactor-recipes",
	energy_required = 25,
	ingredients = {
			{ type = "item", name = "ptfe-sheet", amount = 1 },
			{ type = "item", name = "copper-foil", amount = 4 },
			{ type = "fluid", name = "sulfuric-acid", amount = 25},
		},
	results = {
			{ type = "item", name = "plastic-circuit-board", amount = 4 },
		}
}

create_recipe{
	recipe_name = "plastic-circuit-board-pbi",
	category = "lv-chemical-reactor-recipes",
	energy_required = 25,
	ingredients = {
			{ type = "item", name = "polybenzimidazole-sheet", amount = 1 },
			{ type = "item", name = "copper-foil", amount = 4 },
			{ type = "fluid", name = "sulfuric-acid", amount = 25},
		},
	results = {
			{ type = "item", name = "plastic-circuit-board", amount = 8 },
		}
}
create_recipe{
	recipe_name = "plastic-circuit-board-peca",
	category = "lv-chemical-reactor-recipes",
	energy_required = 25,
	ingredients = {
--			{ type = "item", name = "polyethylcyanoacrylate-sheet", amount = 1 },
			{ type = "item", name = "copper-foil", amount = 4 },
			{ type = "fluid", name = "sulfuric-acid", amount = 25},
		},
	results = {
			{ type = "item", name = "plastic-circuit-board", amount = 16 },
		}
}    



---PLASTIC PRINTED CIRCUIT BOARD
create_item{
	name = "plastic-printed-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "plastic-circuit-board", amount = 1 },
		{ type = "item", name = "copper-foil", amount = 6 },
		{ type = "fluid", name = "iron-iii-chloride", amount = 25 },
	}
}



---LUBRICANT
create_recipe{
	recipe_name = "lubricant",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "redstone-dust", amount = 1 },
		{ type = "fluid", name = "crude-oil", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "lubricant", amount = 100 },
	}
}
   
   
   
---CPU WAFER
create_item{
	name = "cpu-wafer",
	recipe_name = "cpu-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 60 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 },
	}
}
create_recipe{
	recipe_name = "cpu-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 45 * HV_SPEED,
	ingredients = {
			{ type = "item", name = "phosphorus-doped-wafer", amount = 1 },
		},
	results = {
			{ type = "item", name = "cpu-wafer", amount = 4 },
		}
}
create_recipe{
	recipe_name = "cpu-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "cpu-wafer", amount = 8 },
	}
}
create_recipe{
	recipe_name = "cpu-wafer-ed",
	category = "iv-laser-engraver-recipes",
	energy_required = 15 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "europium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-3-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "cpu-wafer", amount = 16 },
	}
}
create_recipe{
	recipe_name = "cpu-wafer-ad",
	category = "iv-laser-engraver-recipes",
	energy_required = 7.5 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "americium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-5-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "cpu-wafer", amount = 32 },
	}
}
   
   
   
---CPU CHIP
create_item{
	name = "cpu-chip",
	category = "mv-cutting-machine-recipes",
	energy_required = 90,
	ingredients = {
		{ type = "item", name = "cpu-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 8.4 },
	},
	results = {
		{ type = "item", name = "cpu-chip", amount = 8 },
	}
}
   
   
   
---THIN POLYETHYLENE SHEET
create_item{
	name = "thin-polyethylene-sheet",
	category = "lv-bending-machine-recipes",
	energy_required = 0.2,
	ingredients = {
		{ type = "item", name = "polyethylene-sheet", amount = 1 },
	},
	results = {
		{ type = "item", name = "thin-polyethylene-sheet", amount = 4 },
	}
}
   
   
   
---CAPACITOR
create_item{
	name = "capacitor",
	category = "mv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 32,
	ingredients = {
		{ type = "item", name = "aluminium-foil", amount = 2 },
		{ type = "item", name = "thin-polyethylene-sheet", amount = 1 },
		{ type = "fluid", name = "polyethylene", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "capacitor", amount = 8 },
	}
}


   
---MICROCHIP
create_recipe{
	recipe_name = "microchip",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "cpu-chip", amount = 1 },
		{ type = "item", name = "resistor", amount = 2 },
		{ type = "item", name = "capacitor", amount = 2 },
		{ type = "item", name = "transistor", amount = 2 },
		{ type = "item", name = "fine-copper-wire", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "electronic-circuit", amount = 3 },
	}
}
create_recipe{
	recipe_name = "microchip-smd",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "cpu-chip", amount = 1 },
		{ type = "item", name = "smd-resistor", amount = 2 },
		{ type = "item", name = "smd-capacitor", amount = 2 },
		{ type = "item", name = "smd-transistor", amount = 2 },
		{ type = "item", name = "fine-copper-wire", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "electronic-circuit", amount = 3 },
	}
}



---MICROPROCESSOR
create_recipe{
	recipe_name = "microprocessor",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "cpu-chip", amount = 1 },
		{ type = "item", name = "resistor", amount = 4 },
		{ type = "item", name = "capacitor", amount = 4 },
		{ type = "item", name = "transistor", amount = 4 },
		{ type = "item", name = "fine-red-alloy-wire", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 2 },
	}
}
create_recipe{
	recipe_name = "microprocessor-smd",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "cpu-chip", amount = 1 },
		{ type = "item", name = "smd-resistor", amount = 4 },
		{ type = "item", name = "smd-capacitor", amount = 4 },
		{ type = "item", name = "smd-transistor", amount = 4 },
		{ type = "item", name = "fine-red-alloy-wire", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 2 },
	}
}
   
   
   
---INDUCTORS
create_item{
	name = "inductor",
	category = "mv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 32,
	ingredients = {
		{ type = "item", name = "nickel-zinc-ferrite-ring", amount = 1 },
		{ type = "item", name = "fine-annealed-copper-wire", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 3.6 },
	},
	results = {
		{ type = "item", name = "inductor", amount = 8 },
	}
}
   
   
   
---MICROPROCESSOR ASSEMBLY
create_recipe{
	recipe_name = "microprocessor-assembly",
	category = "mv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
			{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 2 },
			{ type = "item", name = "inductor", amount = 4 },
			{ type = "item", name = "capacitor", amount = 8 },
			{ type = "item", name = "ram-chip", amount = 4 },
			{ type = "item", name = "fine-red-alloy-wire", amount = 8 },
			{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
		},
	results = {
			{ type = "item", name = "processing-unit", amount = 2 }
		}
}
create_recipe{
	recipe_name = "microprocessor-assembly-smd",
	category = "mv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
			{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
			{ type = "item", name = "advanced-circuit", amount = 2 },
			{ type = "item", name = "smd-inductor", amount = 4 },
			{ type = "item", name = "smd-capacitor", amount = 8 },
			{ type = "item", name = "ram-chip", amount = 4 },
			{ type = "item", name = "fine-red-alloy-wire", amount = 8 },
			{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
		},
	results = {
			{ type = "item", name = "processing-unit", amount = 2 }
		}
}


---MICROPROCESSOR SUPERCOMPUTER
create_item{ skip_recipe = true,
	name = "ev-circuit",
	category = "mv-circuit-assembler-recipes"
}
create_recipe{
	recipe_name = "microprocessor-supercomputer",
	category = "mv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "diode", amount = 4 },
		{ type = "item", name = "ram-chip", amount = 4 },
		{ type = "item", name = "fine-electrum-wire", amount = 16 },
		{ type = "item", name = "energetic-alloy-bolt", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "ev-circuit", amount = 1 }
	}
}
create_recipe{
	recipe_name = "microprocessor-supercomputer-smd",
	category = "mv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "smd-diode", amount = 4 },
		{ type = "item", name = "ram-chip", amount = 4 },
		{ type = "item", name = "fine-electrum-wire", amount = 16 },
		{ type = "item", name = "energetic-alloy-bolt", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "ev-circuit", amount = 1 }
	}
}
   
   
   
---MICROPROCESSOR MAINFRAME
create_item{ skip_recipe = true,
	name = "iv-circuit",
	category = "mv-circuit-assembler-recipes"
}
create_recipe{
	recipe_name = "microprocessor-mainframe",
	category = "hv-circuit-assembler-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "aluminium-frame", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "smd-inductor", amount = 8 },
		{ type = "item", name = "ram-chip", amount = 16 },
		{ type = "item", name = "annealed-copper-wire", amount = 16 },
		{ type = "item", name = "smd-capacitor", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 28.8 }
	},
	results = {
		{ type = "item", name = "iv-circuit", amount = 1 }
	}
} 
   
   
   
---LARGE STEEL BOILER
create_item{
	name = "steel-firebox-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "steel-rod", amount = 4 },
		{ type = "item", name = "steel-frame", amount = 1 },
	}
}
   


---------------------
---   AUTOCLAVE   ---
--------------------- 
  
---LAPIS AUTOCLAVE 
create_recipe{
	recipe_name = "lapis-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "lapis-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "lapis-lazuli", amount = 1},
    }
}  
   

  
---NETHER QUARTZ AUTOCLAVE 
create_recipe{
	recipe_name = "nether-quartz-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "nether-quartz-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "nether-quartz", amount = 1},
    }
}
     

  
---CERTUS QUARTZ AUTOCLAVE 
create_recipe{
	recipe_name = "certus-quartz-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "certus-quartz-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "certus-quartz", amount = 1}
    }
} 
     

  
---DIAMOND AUTOCLAVE 
create_recipe{
	recipe_name = "diamond-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "diamond-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "diamond", amount = 1}
    }
} 
     

  
---EMERALD AUTOCLAVE 
create_recipe{
	recipe_name = "emerald-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "emerald-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "emerald", amount = 1}
    }
} 
     

  
---RUBY AUTOCLAVE 
create_recipe{
	recipe_name = "ruby-autoclave",
	category = "mv-autoclave-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "ruby-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 5},
    },
	results = {
		{type = "item", name = "ruby", amount = 1}
    }
} 



------------------------
---   DRILLING RIG   ---
------------------------ 

--- WATER
create_recipe{
	recipe_name = "water-drilling-rig",
	category = "drilling-rig-recipes",
	energy_required = 4,
	ingredients = { },
	results = {
		{type = "fluid", name = "water", amount = 1000}
    }
}
  
  
  
--- CRUDE OIL
create_recipe{
	recipe_name = "crude-oil-drilling-rig",
	category = "drilling-rig-recipes",
	energy_required = 4,
	ingredients = { },
	results = {
		{type = "fluid", name = "crude-oil", amount = 100}
    }
}  
  
  
  
--- LAVA
create_recipe{
	recipe_name = "lava-drilling-rig",
	category = "drilling-rig-recipes",
	energy_required = 4,
	ingredients = { },
	results = {
		{type = "fluid", name = "lava", amount = 100 }
    }
}  



----------------------------------
---   BASIC OIL DISTILLATION   ---
----------------------------------

create_recipe{
	recipe_name = "oil-distillation-light",
	category = "mv-distillation-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "fluid", name = "crude-oil", amount = 50 },
	},
	results = {
		{ type = "fluid", name = "sulfuric-light-fuel", amount = 50 },
	}
}
create_recipe{
	recipe_name = "oil-distillation-heavy",
	category = "mv-distillation-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "fluid", name = "crude-oil", amount = 50 },
	},
	results = {
		{ type = "fluid", name = "sulfuric-heavy-fuel", amount = 15 },
	}
}
 


---DESULFURIZING  
create_recipe{
	recipe_name = "light-fuel-desulfurization",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-light-fuel", amount = 1200 },
		{ type = "fluid", name = "hydrogen", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "hydrogen-sulfide", amount = 100 },
		{ type = "fluid", name = "light-fuel", amount = 1200 },
	},
	main_product = "light-fuel"
}
create_recipe{
	recipe_name = "heavy-fuel-desulfurization",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-heavy-fuel", amount = 800 },
		{ type = "fluid", name = "hydrogen", amount = 200 }
	},
	results = {
		{ type = "fluid", name = "hydrogen-sulfide", amount = 100 },
		{ type = "fluid", name = "heavy-fuel", amount = 800 }
	},
	main_product = "heavy-fuel"
}
   
   
   
---HYDROGEN SULFIDE ELECTROLYSIS  
create_recipe{
	recipe_name = "hydrogen-sulfide-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 1.8,
	ingredients = {
		{ type = "fluid", name = "hydrogen-sulfide", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "hydrogen", amount = 200 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	main_product = "hydrogen"
}
   
   
   
---DIESEL 
create_recipe{
	recipe_name = "diesel",
	category = "mv-mixer-recipes",
	energy_required = 1.6,
	ingredients = {
		{ type = "fluid", name = "heavy-fuel", amount = 100 },
		{ type = "fluid", name = "light-fuel", amount = 500 }
	},
	results = {
		{ type = "fluid", name = "diesel", amount = 600 },
	}
}

   

---HV SCIENCE PACK   
create_recipe{
	recipe_name = "hv-science-pack",
	category = "mv-assembling-machine-recipes",
	energy_required = MV_SPEED * 60,
	order = "d",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "cupronickel-coil-block", amount = 4 },
		{ type = "item", name = "heat-proof-casing", amount = 4 },
		{ type = "item", name = "frost-proof-casing", amount = 4 },
		{ type = "item", name = "battery", amount = 4 },
		{ type = "item", name = "mv-field-generator", amount = 1 },
	},
	results = {
		{ type = "item", name = "chemical-science-pack", amount = 10 }
	}
}








----------------------------
---   MV INFRASTRUCTURE  ---
----------------------------

---MEDIUM ELECTRIC POLE
create_recipe{
	recipe_name = "medium-electric-pole",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{ type = "item", name = "copper-wire", amount = 2 },
		{ type = "item", name = "iron-stick", amount = 4 },
		{ type = "item", name = "steel-plate", amount = 2 },
    }
}  


  
---BIG ELECTRIC POLE
create_recipe{
	recipe_name = "big-electric-pole",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{ type = "item", name = "copper-wire", amount = 4 },
		{ type = "item", name = "iron-stick", amount = 8 },
		{ type = "item", name = "steel-plate", amount = 5 },

    }
}  


  
---SUBSTATION
create_recipe{
	recipe_name = "substation",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 20 },
		{ type = "item", name = "fine-annealed-copper-wire", amount = 40 },
		{ type = "item", name = "mv-emitter", amount = 4 },
		{ type = "item", name = "advanced-circuit", amount = 4 },
    }
} 



---FAST TRANSPORT BELT
create_recipe{
	recipe_name = "fast-transport-belt",
	subgroup = "belt",
	ingredients = {
		{ type = "item", name = "transport-belt", amount = 4 },
		{ type = "item", name = "lv-conveyor-module", amount = 1 },
	},
	results = {
		{ type = "item", name = "fast-transport-belt", amount = 4 }
	}
}   



---FAST UNDERGROUND BELT
create_recipe{
	recipe_name = "fast-underground-belt",
	subgroup = "belt",
	ingredients = {
		{ type = "item", name = "underground-belt", amount = 2 },
		{ type = "item", name = "lv-conveyor-module", amount = 1 },
	},
	results = {
		{ type = "item", name = "fast-underground-belt", amount = 2 }
	}
}



---FAST SPLITTER
create_recipe{
	recipe_name = "fast-splitter",
	subgroup = "belt",
	ingredients = {
		{ type = "item", name = "splitter", amount = 1 },
		{ type = "item", name = "lv-piston", amount = 2 },
	}
}

   
   



-----------------------------------
---   BASIC EXTENDED CRAFTING   ---
-----------------------------------

---DISTILLED WATER
create_recipe{
	recipe_name = "distilled-water",
	category = "lv-distillation-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "water", amount = 28.8 },
    },
	results = {
		{ type = "fluid", name = "distilled-water", amount = 26 },
    }
}



---LAPIS COOLANT
create_recipe{
	recipe_name = "lapis-coolant",
	category = "lv-mixer-recipes",
	energy_required = 25.6,
	ingredients = {
		{ type = "item", name = "lapis-dust", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 100 },
    },
	results = {
		{ type = "fluid", name = "lapis-coolant", amount = 100 },
    }
}
  
  
   
---BLACK STEEL INGOT COOLING
create_recipe{
	recipe_name = "black-steel-ingot-chemical-bath",
	category = "lv-chemical-bath-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "hot-black-steel-ingot", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 100 },
	},
	results = {
		{ type = "item", name = "black-steel-ingot", amount = 1 },
	}
} 



---PHOSPHORIC ACID
create_recipe {
	recipe_name = "phosphoric-acid-from-apatite",
	category = "lv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "apatite", amount = 9 },
		{ type = "fluid", name = "water", amount = 1000 },
		{ type = "fluid", name = "sulfuric-acid", amount = 500 },
	},
	results = {
		{ type = "item", name = "gypsum", amount = 40 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
		{ type = "fluid", name = "phosphoric-acid", amount = 300 },
	},
	main_product = "phosphoric-acid"
}
   
   
   
---PHOSPHORUS PENTOXIDE
create_item {
	name = "phosphorus-pentoxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "phosphorus", amount = 4 },
		{ type = "fluid", name = "oxygen", amount = 1000 },
	},
	results = {
		{ type = "item", name = "phosphorus-pentoxide", amount = 14 },
	}
}
	
   
   
---PHOSPHORIC ACID
create_recipe {
	recipe_name = "phosphoric-acid-from-phosphorus-pentoxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "phosphorus-pentoxide", amount = 14 },
		{ type = "fluid", name = "water", amount = 600 },
	},
	results = {
		{ type = "fluid", name = "phosphoric-acid", amount = 400 },
	}
}  



---LUMINESSENCE
create_item{
	name = "luminessence",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "item", name = "redstone-dust", amount = 1 },
		{ type = "item", name = "glowstone-dust", amount = 1 },
		{ type = "item", name = "aluminium-dust", amount = 2 },
		{ type = "fluid", name = "phosphoric-acid", amount = 200 },
	},
	results = {
		{ type = "item", name = "luminessence", amount = 8 }
	}
}







---------------------------
---   MICROVERSE STUFF  ---
---------------------------

---DEUTERIUM
create_recipe{
	recipe_name = "deuterium",
	category = "lv-centrifuge-recipes",
	energy_required = 20,
	ingredients = {	
		{type = "fluid", name = "water", amount = 100}
    },
	results = {
		{type = "fluid", name = "exhausted-water", amount = 95},
		{type = "fluid", name = "deuterium", amount = 5},
    },
	main_product = "deuterium"
}

  
  
---MICROVERSIUM INGOT COOLING
create_recipe{
	recipe_name = "microversium-ingot-chemical-bath",
	category = "lv-chemical-bath-recipes",
	energy_required = 30,
	ingredients = {
      {type = "item", name = "hot-microversium-ingot", amount = 1},
      {type = "fluid", name = "lapis-coolant", amount = 100},
    },
	results = {
		{type = "item", name = "microversium-ingot", amount = 1}
    }
}
   
  
  
---MICROVERSIUM CASING
create_item{
	name = "microversium-casing",
	ingredients = {
      {type = "item", name = "microversium-plate", amount = 8}
    }
}



---BLOCK OF DIAMOND
create_item{
	name = "block-of-diamond",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "diamond", amount = 9}
    }
}



---LAPIS LAZULI BLOCK
create_item{
	name = "lapis-lazuli-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "lapis-lazuli", amount = 9}
    }
}
   
   
   
---BASIC EXTENDED CRAFTING COMPONENT
create_item{
	name = "basic-extended-crafting-component",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "iron-plate", amount = 1 },
		{ type = "item", name = "nether-quartz", amount = 1 },
		{ type = "item", name = "luminessence", amount = 1 }
	}
}
   
   

---BASIC EXTENDED CRAFTING CATALYST
create_item{
	name = "basic-extended-crafting-catalyst",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "basic-extended-crafting-component", amount = 4 }
	},
}    
  


---BASIC GUIDANCE SYSTEM
create_item{
	name = "basic-guidance-system",
    category = "basic-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "steel-plate", amount = 4},
      {type = "item", name = "glass", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 2},
      {type = "item", name = "lv-sensor", amount = 2}
    }
}
  
  
  
---BASIC MINING LASER
create_item{
	name = "basic-mining-laser",
    category = "basic-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "ruby-lens", amount = 1},
      {type = "item", name = "glass-tube", amount = 1},
      {type = "item", name = "electronic-circuit", amount = 1},
      {type = "item", name = "nether-quartz", amount = 4}
    }
}

  
---CONDUCTIVE IRON INGOT	
create_item{
	name = "conductive-iron-ingot",
    category = "lv-alloy-smelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 1},
		{type = "item", name = "redstone-dust", amount = 1},
	}
}


 
---CONDUCTIVE IRON THRUSTER
create_item{
	name = "conductive-iron-thruster",
    category = "basic-extended-crafting-recipes",
	ingredients = {
		{type = "item", name = "conductive-iron-plate", amount = 5},
		{type = "item", name = "red-alloy-plate", amount = 3},
		{type = "item", name = "ruby", amount = 1}
    }
}



---STEEL HEAVY PLATING
create_item{
	name = "steel-heavy-plating",
	category = "lv-bending-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4}
    }
}
  
  
  
---STEEL PLATED MICRO MINER
create_item{
	name = "steel-plated-microminer",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{type = "item", name = "basic-guidance-system", amount = 1},
		{type = "item", name = "basic-mining-laser", amount = 2},
		{type = "item", name = "steel-heavy-plating", amount = 2},
		{type = "item", name = "iron-chest", amount = 1},
		{type = "item", name = "lv-gas-turbine", amount = 1},
		{type = "item", name = "conductive-iron-thruster", amount = 2}
    }
}
  
  
  
---OVERWORLD DATA
create_item{
	name = "basic-storage-housing",
	category = "lv-assembling-machine-recipes",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4},
		{type = "item", name = "steel-screw", amount = 4},
		{type = "item", name = "glass", amount = 1},
    }
}
create_item{
	name = "overworld-data",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	icon_size = 64,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "me-1k-storage-component", amount = 1},
		{type = "item", name = "basic-storage-housing", amount = 1},
    },
	results = {
		{type = "item", name = "overworld-data", amount = 1}
    }
}
  


---TIER ONE OUTPUT
create_item{
	name = "tier-one-microminer-output",
	category = "mv-microverse-projector-recipes",
	energy_required = MV_SPEED * 100,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "steel-plated-microminer", amount = 1},
		{type = "item", name = "overworld-data", amount = 1},
		{type = "fluid", name = "benzene", amount = 400}
    },
	results = {
		{type = "item", name = "tier-one-microminer-output", amount = 64}
    }
}



create_item{
	name = "ender-pearl",
	recipe_name = "microminer-ender-pearls",
	category = "lv-assembling-machine-recipes",
	energy_required = 2,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
      {type = "item", name = "tier-one-microminer-output", amount = 2 }
    },
	results = {
      {type = "item", name = "ender-pearl", amount = 32 }
    }
}
create_item{
	name = "zombie-head",
	recipe_name = "microminer-zombie-heads",
	category = "lv-assembling-machine-recipes",
	energy_required = 2,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
      {type = "item", name = "tier-one-microminer-output", amount = 1 }
    },
	results = {
      {type = "item", name = "zombie-head", amount = 8 }
    }
}
  
  
  
---DIAMOND PLATE
create_item{
	name = "diamond-plate",
	category = "lv-cutting-machine-recipes",
	energy_required = 384,
	ingredients = {
		{type = "item", name = "block-of-diamond", amount = 1},
		{type = "fluid", name = "lubricant", amount = 18},
    },
	results = {
		{type = "item", name = "diamond-plate", amount = 9}
    }
}



---ROBOPORT FRAME CASING MK1
create_item{
	name = "roboport-frame-casing-mk1",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "solid-steel-machine-casing", amount = 1},
		{type = "item", name = "aluminium-plate", amount = 6},
    },
	results = {
		{type = "item", name = "roboport-frame-casing-mk1", amount = 4}
    }
}



---ROBOPORT																		24 on ground / 24 walls / 8 slant / minus 4 for ports
create_item{
	name = "roboport-mk1",															---      o o
	icon = "__base__/graphics/icons/roboport.png",
	icon_size = 64,
	ingredients = {																---	   o o o o
		{type = "item", name = "roboport-frame-casing-mk1", amount = 52 },    	---  o o o o o o
		{type = "item", name = "me-controller", amount = 1 },					---  o o o o o o
		{type = "item", name = "fluix-cable", amount = 24 },					---  o o o o o o
		{type = "item", name = "lv-machine-hull", amount = 2 },					---    o o o o
		{type = "item", name = "mv-energy-hatch", amount = 2 },					---      o o								
    },
	stack_size = 10,
	place_result = "roboport-mk1"
}










-------------------------------
---   APPLIED ENERGISTICS   ---
-------------------------------

---CHARGED CERTUS QUARTZ DUST
create_item{
	name = "charged-certus-quartz-dust",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{type = "item", name = "certus-quartz-dust", amount = 1},
		{type = "item", name = "redstone-dust", amount = 1},
    }
}



---CHARGED CERTUS QUARTZ
create_item{
	name = "charged-certus-quartz",
	category = "lv-autoclave-recipes",
	energy_required = 75,
	ingredients = {
		{type = "item", name = "charged-certus-quartz-dust", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 10},
    },
	results = {
		{type = "item", name = "charged-certus-quartz", probability = 0.9, amount = 1}
    }
}  
 
 
  
---FLUIX CRYSTAL
create_item{
	name = "fluix-crystal",
	category = "lv-mixer-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "charged-certus-quartz", amount = 1},
		{type = "item", name = "redstone-dust", amount = 1},
		{type = "item", name = "nether-quartz", amount = 1},
		{type = "fluid", name = "water", amount = 50},
    },
	results = {
		{type = "item", name = "fluix-crystal", amount = 2}
    }
}



---FLUIX DUST
create_item{
	name = "fluix-dust",
	category = "lv-macerator-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "fluix-crystal", amount = 1},
    }
}



---CERTUS SEED
create_item{
	name = "certus-seed",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "certus-quartz-dust", amount = 1},
		{type = "item", name = "sand", amount = 1},
    },
	results = {
		{type = "item", name = "certus-seed", amount = 2}
    }
}



---PURE CERTUS CRYSTAL
create_item{
	name = "pure-certus-crystal",
	category = "lv-autoclave-recipes",
	energy_required = 50,
	ingredients = {
		{type = "item", name = "certus-seed", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 10},
    },
	results = {
		{type = "item", name = "pure-certus-crystal", probability = 0.9, amount = 1}
    }
} 



---FLUIX SEED
create_item{
	name = "fluix-seed",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "fluix-dust", amount = 1},
		{type = "item", name = "sand", amount = 1},
    },
	results = {
		{type = "item", name = "fluix-seed", amount = 2}
    }
}



---PURE FLUIX CRYSTAL
create_item{
	name = "pure-fluix-crystal",
	category = "lv-autoclave-recipes",
	energy_required = 50,
	ingredients = {
		{type = "item", name = "fluix-seed", amount = 1},
		{type = "fluid", name = "distilled-water", amount = 10},
    },
	results = {
		{type = "item", name = "pure-fluix-crystal", probability = 0.9, amount = 1}
    }
} 



---INSCRIBER SILICON PRESS
create_item{
	name = "inscriber-silicon-press",
	category = "lv-bending-machine-recipes",
	energy_required = 60,
	ingredients = {
		{type = "item", name = "block-of-iron", amount = 1},
    }
}
  
  
  
---INSCRIBER CALCULATION PRESS
create_item{
	name = "inscriber-calculation-press",
	category = "lv-bending-machine-recipes",
	energy_required = 60,
	ingredients = {
		{type = "item", name = "block-of-iron", amount = 1},
    }
}
  
  
  
---INSCRIBER LOGIC PRESS
create_item{
	name = "inscriber-logic-press",
	category = "lv-bending-machine-recipes",
	energy_required = 60,
	ingredients = {
		{type = "item", name = "block-of-iron", amount = 1},
    }
}  
  
  
  
---INSCRIBER ENGINEERING PRESS
create_item{
	name = "inscriber-engineering-press",
	category = "lv-bending-machine-recipes",
	energy_required = 60,
	ingredients = {
		{type = "item", name = "block-of-iron", amount = 1},
    }
}
  
  
  
---PRINTED SILICON
create_item{
	name = "printed-silicon",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "silicon-plate", amount = 1},
		{type = "item", name = "inscriber-silicon-press", amount = 1},
    },
	results = {
		{type = "item", name = "printed-silicon", amount = 1},
		{type = "item", name = "inscriber-silicon-press", amount = 1},
    },
	main_product = "printed-silicon"
}



---PRINTED LOGIC CIRCUIT
create_item{
	name = "printed-logic-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "gold-plate", amount = 1},
		{type = "item", name = "inscriber-logic-press", amount = 1},
    },
	results = {
		{type = "item", name = "printed-logic-circuit", amount = 1},
		{type = "item", name = "inscriber-logic-press", amount = 1},
    },
	main_product = "printed-logic-circuit"
}



---LOGIC PROCESSOR
create_item{
	name = "logic-processor",
	category = "lv-circuit-assembler-recipes",
	energy_required = 4,
	ingredients = {
		{type = "item", name = "printed-logic-circuit", amount = 1},
		{type = "item", name = "printed-silicon", amount = 1},
		{type = "fluid", name = "molten-red-alloy", amount = 14.4},
    }
}   



---PRINTED CALCULATION CIRCUIT
create_item{
	name = "printed-calculation-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "pure-certus-crystal", amount = 1},
		{type = "item", name = "inscriber-calculation-press", amount = 1},
    },
	results = {
		{type = "item", name = "printed-calculation-circuit", amount = 1},
		{type = "item", name = "inscriber-calculation-press", amount = 1},
    },
	main_product = "printed-calculation-circuit"
}



---CALCULATION PROCESSOR
create_item{
	name = "calculation-processor",
	category = "lv-circuit-assembler-recipes",
	energy_required = 4,
	ingredients = {
		{type = "item", name = "printed-calculation-circuit", amount = 1},
		{type = "item", name = "printed-silicon", amount = 1},
		{type = "fluid", name = "molten-red-alloy", amount = 14.4},
    }
}



---PRINTED ENGINEERING CIRCUIT
create_item{
	name = "printed-engineering-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "diamond-plate", amount = 1},
		{type = "item", name = "inscriber-engineering-press", amount = 1},
    },
	results = {
		{type = "item", name = "printed-engineering-circuit", amount = 1},
		{type = "item", name = "inscriber-engineering-press", amount = 1},
    },
	main_product = "printed-engineering-circuit"
}



---ENGINEERING PROCESSOR
create_item{
	name = "engineering-processor",
	category = "lv-circuit-assembler-recipes",
	energy_required = 4,
	ingredients = {
		{type = "item", name = "printed-engineering-circuit", amount = 1},
		{type = "item", name = "printed-silicon", amount = 1},
		{type = "fluid", name = "molten-red-alloy", amount = 14.4},
    }
}
  

 
---ANNIHILATION CORE
create_item{
	name = "annihilation-core",
	category = "mv-assembling-machine-recipes",
	energy_required = 5 * HV_SPEED,
	ingredients = {
		{type = "item", name = "nether-quartz-rod", amount = 4},
		{type = "item", name = "fluix-crystal", amount = 1},
		{type = "item", name = "logic-processor", amount = 4},
    },
	results = {
		{type = "item", name = "annihilation-core", amount = 2}
    }
}



---FORMATION CORE
create_item{
	name = "formation-core",
	category = "mv-assembling-machine-recipes",
	energy_required = 5 * HV_SPEED,
	ingredients = {
		{type = "item", name = "certus-quartz-rod", amount = 4},
		{type = "item", name = "fluix-crystal", amount = 1},
		{type = "item", name = "logic-processor", amount = 4},
    },
	results = {
		{type = "item", name = "formation-core", amount = 2}
    }
}
 

---CHARGED CERTUS QUARTZ ROD
create_item{
	name = "charged-certus-quartz-rod",
	category = "lv-lathe-recipes",
	energy_required = 24.5,
	ingredients = {
		{type = "item", name = "charged-certus-quartz", amount = 1},
    },
	results = {
		{type = "item", name = "charged-certus-quartz-rod", amount = 2}
    }
}



---CERTUS QUARTZ ROD
create_item{
	name = "certus-quartz-rod",
	category = "lv-lathe-recipes",
	energy_required = 24.5,
	ingredients = {
		{type = "item", name = "certus-quartz", amount = 1},
    },
	results = {
		{type = "item", name = "certus-quartz-rod", amount = 2}
    }
}



---CERTUS QUARTZ BOLT
create_item{
	name = "certus-quartz-bolt",
	category = "lv-cutting-machine-recipes",
	energy_required = 24.5,
	ingredients = {
		{type = "item", name = "certus-quartz-rod", amount = 1},
    },
	results = {
		{type = "item", name = "certus-quartz-bolt", amount = 4}
    }
}  



---CERTUS QUARTZ SCREW
create_item{
	name = "certus-quartz-screw",
	category = "lv-lathe-recipes",
	energy_required = 1.53,
	ingredients = {
		{type = "item", name = "certus-quartz-bolt", amount = 1},
    },
	results = {
		{type = "item", name = "certus-quartz-screw", amount = 1}
    }
}



---NETHER QUARTZ ROD
create_item{
	name = "nether-quartz-rod",
	category = "lv-lathe-recipes",
	energy_required = 24.5,
	ingredients = {
		{type = "item", name = "nether-quartz", amount = 1},
    },
	results = {
		{type = "item", name = "nether-quartz-rod", amount = 2}
    }
}  



---QUARTZ FIBER
create_item{
	name = "quartz-fiber",
	category = "mv-assembling-machine-recipes",
	energy_required = 8,
	ingredients = {
		{type = "item", name = "charged-certus-quartz-rod", amount = 1},
    }
}
  


---FLUIX CABLE
create_item{
	name = "fluix-cable",
	category = "mv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "quartz-fiber", amount = 3},
		{type = "item", name = "fluix-dust", amount = 2},
    },
	results = {
		{type = "item", name = "fluix-cable", amount = 3}
    }
}
  


---ME INTERFACE
create_item{
	name = "me-interface",
	ingredients = {
      {type = "item", name = "mv-machine-casing", amount = 1},
      {type = "item", name = "aluminium-plate", amount = 4},
      {type = "item", name = "fluix-cable", amount = 2},
      {type = "item", name = "formation-core", amount = 1},
      {type = "item", name = "annihilation-core", amount = 1},
    }
} 
    
	
	
---ADVANCED CARD
create_item{
	name = "advanced-card",
	ingredients = {
      {type = "item", name = "platinum-plate", amount = 2},
      {type = "item", name = "calculation-processor", amount = 1},
      {type = "item", name = "red-alloy-plate", amount = 1},
      {type = "item", name = "titanium-plate", amount = 3},
    }
}    
	
	
	
---ACCELERATION CARD
create_item{
	name = "acceleration-card",
	ingredients = {
      {type = "item", name = "logic-processor", amount = 1},
      {type = "item", name = "engineering-processor", amount = 1},
      {type = "item", name = "fluix-crystal", amount = 1},
      {type = "item", name = "advanced-card", amount = 1},
    }
} 


	
---REQUESTER CHEST
create_recipe{
	name = "requester-chest",
	category = "hv-assembling-machine-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
      {type = "item", name = "diamond-chest", amount = 1},
      {type = "item", name = "me-interface", amount = 1},
    }
} 



---PASSIVE PROVIDER CHEST
create_recipe{
	name = "passive-provider-chest",
	category = "hv-assembling-machine-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
      {type = "item", name = "diamond-chest", amount = 1},
      {type = "item", name = "me-interface", amount = 1},
    }
}   



---ACTIVE PROVIDER CHEST
create_recipe{
	name = "active-provider-chest",
	category = "hv-assembling-machine-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
      {type = "item", name = "diamond-chest", amount = 1},
      {type = "item", name = "me-interface", amount = 1},
    }
}     

  
  
---ME DRIVE
create_item{
	name = "me-drive",
	ingredients = {
		{type = "item", name = "aluminium-plate", amount = 4},
		{type = "item", name = "me-chest", amount = 1},
		{type = "item", name = "fluix-cable", amount = 2},
		{type = "item", name = "mv-emitter", amount = 1},
		{type = "item", name = "processing-unit", amount = 1},
    }
}
create_item{
	name = "me-chest",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4},
		{type = "item", name = "steel-chest", amount = 1},
		{type = "item", name = "fluix-cable", amount = 2},
		{type = "item", name = "advanced-circuit", amount = 2},
    }
}



---STORAGE CHEST
create_recipe{
	name = "storage-chest",
	category = "hv-assembling-machine-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
      {type = "item", name = "me-drive", amount = 1},
      {type = "item", name = "fluix-cable", amount = 4},
      {type = "item", name = "me-16k-storage-component", amount = 8},
    },
	results = {
		{type = "item", name = "storage-chest", amount = 32}
    }
} 



---BUFFER CHEST
create_recipe{
	name = "buffer-chest",
	ingredients = {
      {type = "item", name = "storage-chest", amount = 1},
    }
} 



---FLUIX BLOCK
create_item{
	name = "fluix-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{type = "item", name = "pure-fluix-crystal", amount = 8},
    },
	results = {
		{type = "item", name = "fluix-block", amount = 1}
    }
} 



---ME CONTROLLER
create_item{
	name = "me-controller",
	ingredients = {
		{type = "item", name = "aluminium-plate", amount = 4},
		{type = "item", name = "fluix-block", amount = 1},
		{type = "item", name = "engineering-processor", amount = 2},
		{type = "item", name = "processing-unit", amount = 2},
    }
} 



---ME TERMINAL
create_item{
	name = "me-terminal",
	ingredients = {
		{type = "item", name = "nether-quartz-rod", amount = 4},
		{type = "item", name = "certus-quartz-screw", amount = 4},
		{type = "item", name = "computer-monitor", amount = 1},
		{type = "item", name = "processing-unit", amount = 2},
    }
} 



---COMPUTER MONITOR
create_item{
	name = "computer-monitor",	
	ingredients = {
		{ type = "item", name = "advanced-circuit", amount = 1 },
		{ type = "item", name = "aluminium-plate", amount = 4 },
		{ type = "item", name = "glass", amount = 4 },
	}
}



---SIMPLE SOC WAFER
create_item{
	name = "simple-soc-wafer",
	recipe_name = "simple-soc-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 15 * MV_SPEED,
	ingredients = {
		{type = "item", name = "silicon-wafer", amount = 1},
    },
	results = {
		{type = "item", name = "simple-soc-wafer", amount = 1},
    }
}  
create_recipe{
	recipe_name = "simple-soc-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "simple-soc-wafer", amount = 4 },
	}
}
create_recipe{
	recipe_name = "simple-soc-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 15 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "simple-soc-wafer", amount = 16 },
	}
}
create_recipe{
	recipe_name = "simple-soc-wafer-ed",
	category = "iv-laser-engraver-recipes",
	energy_required = 15 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "europium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-3-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "simple-soc-wafer", amount = 64 },
	}
}



---SIMPLE SYSTEM ON CHIP
create_item{
	name = "simple-system-on-chip",
	category = "mv-cutting-machine-recipes",
	energy_required = 45 * MV_SPEED,
	ingredients = {
		{type = "item", name = "simple-soc-wafer", amount = 1},
    },
	results = {
		{type = "item", name = "simple-system-on-chip", amount = 6}
    }
}



---NAND CHIP ARRAY
create_item{
	name = "nand-chip-array",
	category = "lv-circuit-assembler-recipes",
	energy_required = 30,
	ingredients = {
		{type = "item", name = "resin-printed-circuit-board", amount = 1},
		{type = "item", name = "red-alloy-bolt", amount = 2},
		{type = "item", name = "simple-system-on-chip", amount = 1},
		{type = "item", name = "fine-tin-wire", amount = 2},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    }
}



---NAND CHIP
create_item{
	name = "nand-chip",
	category = "lv-cutting-machine-recipes",
	energy_required = 20,
	ingredients = {
      {type = "item", name = "nand-chip-array", amount = 1},
    },
	results = {
      {type = "item", name = "nand-chip", amount = 12}
    }
}


---ME 1K STORAGE COMPONENT
create_item{
	name = "me-1k-storage-component",
	recipe_name = "me-1k-storage-component-lv",
	category = "lv-circuit-assembler-recipes",
	energy_required = 5,
	ingredients = {
      {type = "item", name = "resin-printed-circuit-board", amount = 1},
      {type = "item", name = "certus-quartz-dust", amount = 2},
      {type = "item", name = "electronic-circuit", amount = 2},
      {type = "item", name = "logic-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-1k-storage-component", amount = 1}
    }
}
create_recipe{
	recipe_name = "me-1k-storage-component-nand",
	category = "lv-circuit-assembler-recipes",
	energy_required = 5,
	ingredients = {
		{type = "item", name = "resin-printed-circuit-board", amount = 1},
		{type = "item", name = "certus-quartz-dust", amount = 2},
		{type = "item", name = "nand-chip", amount = 2},
		{type = "item", name = "logic-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-1k-storage-component", amount = 1}
    }
}




---ME 4K STORAGE COMPONENT
create_item{
	name = "me-4k-storage-component",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "phenolic-printed-circuit-board", amount = 1},
		{type = "item", name = "nand-chip", amount = 16 },
		{type = "item", name = "electronic-circuit", amount = 4 },
		{type = "item", name = "logic-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    }
}



---ME 16K STORAGE COMPONENT
create_item{
	name = "me-16k-storage-component",
	category = "mv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "plastic-printed-circuit-board", amount = 1},
		{type = "item", name = "electronic-circuit", amount = 16 },
		{type = "item", name = "advanced-circuit", amount = 4 },
		{type = "item", name = "calculation-processor", amount = 1},
		{type = "fluid", name = "soldering-alloy", amount = 7.2},
    }
}



---ME 64K STORAGE COMPONENT
create_item{
	name = "me-64k-storage-component",
	category = "hv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
      {type = "item", name = "epoxy-printed-circuit-board", amount = 1},
      {type = "item", name = "advanced-circuit", amount = 16},
      {type = "item", name = "processing-unit", amount = 4},
      {type = "item", name = "calculation-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-64k-storage-component", amount = 1}
    }
}



---ME 256K STORAGE COMPONENT
create_item{
	name = "me-256k-storage-component",
	category = "ev-circuit-assembler-recipes",
	energy_required = 80,
	ingredients = {
      {type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1},
      {type = "item", name = "processing-unit", amount = 16},
      {type = "item", name = "ev-circuit", amount = 4},
      {type = "item", name = "engineering-processor", amount = 1},
      {type = "fluid", name = "soldering-alloy", amount = 7.2},
    },
	results = {
      {type = "item", name = "me-256k-storage-component", amount = 1}
    }
}
