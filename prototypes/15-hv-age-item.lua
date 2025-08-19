--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

-------------------------------
---   BAUXITE SLURRY CHAIN  ---
------------------------------- 

create_item {
	name = "quicklime",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "calcite", amount = 5 },
	},
	results = {
		{ type = "item", name = "quicklime", amount = 2 },
		{ type = "fluid", name = "carbon-dioxide", amount = 100 },
	},
	main_product = "quicklime"
} 
create_recipe {
	recipe_name = "bauxite-slurry",
	category = "mv-mixer-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "quicklime", amount = 4 },
		{ type = "item", name = "sodium-hydroxide", amount = 9 },
		{ type = "item", name = "crushed-bauxite", amount = 32 },
		{ type = "fluid", name = "water", amount = 500 },
	},
	results = {
		{ type = "fluid", name = "bauxite-slurry", amount = 800 },
	}
}
create_recipe {
	recipe_name = "heated-bauxite-slurry",
	category = "hv-cracker-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "bauxite-slurry", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "heated-bauxite-slurry", amount = 200 },
	}
}
create_item{
	name = "sodium-aluminate",
	recipe_name = "sodium-aluminate-from-lazurite",
	category = "hv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "lazurite-dust", amount = 16 },
		{ type = "item", name = "sodium-hydroxide", amount = 48 },
		{ type = "fluid", name = "water", amount = 400 },
	},
	results = {
		{ type = "item", name = "sodium-aluminate", amount = 64 },
	}
}
create_recipe{
	recipe_name = "sodium-aluminate-from-sodalite",
	category = "hv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "sodalite-dust", amount = 16 },
		{ type = "item", name = "sodium-hydroxide", amount = 48 },
		{ type = "fluid", name = "water", amount = 400 },
	},
	results = {
		{ type = "item", name = "sodium-aluminate", amount = 64 },
	}
}
create_item{
	name = "aluminium-hydroxide",
	category = "mv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "item", name = "sodium-aluminate", amount = 4 },
			{ type = "fluid", name = "water", amount = 200 },
		},
	results = {
			{ type = "item", name = "aluminium-hydroxide", amount = 4 },
			{ type = "item", name = "sodium-hydroxide", amount = 3 },
		},
	main_product = "aluminium-hydroxide"
}
create_recipe{
	recipe_name = "carbon-dioxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "carbon-dioxide", amount = 300 },
	}
}
create_item { skip_recipe = true,
	name = "bauxite-slag",
	subgroup = "subgroup-hv-chemical-reactor-recipes"
}
create_item { skip_recipe = true,
	name = "sodium-carbonate",
	subgroup = "subgroup-hv-chemical-reactor-recipes"
}
create_recipe{
	recipe_name = "heated-bauxite-slurry-reaction",
	category = "hv-chemical-reactor-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "aluminium-hydroxide", amount = 1 },
		{ type = "fluid", name = "heated-bauxite-slurry", amount = 800 },
		{ type = "fluid", name = "carbon-dioxide", amount = 500 },
	},
	results = {
		{ type = "item", name = "alumina", amount = 80 },
		{ type = "item", name = "sodium-carbonate", amount = 9 },
		{ type = "item", name = "calcite", amount = 10 },
		{ type = "item", name = "bauxite-slag", amount = 16 },
		{ type = "fluid", name = "sluice-juice", amount = 500 },
	},
	main_product = "bauxite-slag"
}
create_recipe{
	recipe_name = "centrifuge-bauxite-slag",
	category = "mv-centrifuge-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "bauxite-slag", amount = 1 },
	},
	results = {
		{ type = "item", name = "rutile-dust", amount = 1 },
		{ type = "item", name = "silicon-dioxide", amount = 1, probability = 0.9 },
		{ type = "item", name = "iron-dust", amount = 1, probability = 0.8 },
		{ type = "item", name = "gallium", amount = 1, probability = 0.3 },
		{ type = "item", name = "quicklime", amount = 1, probability = 0.2 },
	},
	main_product = "rutile-dust"
}
create_recipe{
	recipe_name = "centrifuge-sluice-juice",
	category = "mv-centrifuge-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "sluice-juice", amount = 100 },
	},
	results = {
		{ type = "item", name = "stone-dust", amount = 1 },
		{ type = "item", name = "iron-dust", amount = 1, probability = 0.4 },
		{ type = "item", name = "copper-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "tin-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "nickel-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "antimony", amount = 1, probability = 0.2 },
		{ type = "fluid", name = "water", amount = 50 },
	},
	main_product = "stone-dust"
}
create_recipe{
	recipe_name = "sodium-carbonate-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 9.6,
	ingredients = {
		{ type = "item", name = "sodium-carbonate", amount = 6 },
	},
	results = {
		{ type = "item", name = "sodium", amount = 2 },
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 300 },
	},
	main_product = "sodium"
}
   



------------------------
---   HV COMPONENTS  ---
------------------------ 



---GOLD CABLE
create_item{
	name = "gold-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "gold-wire", amount = 1 },
		{ type = "fluid", name = "liquid-rubber", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "gold-cable", amount = 1 },
	},
}
create_recipe{
	name = "gold-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "gold-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "gold-cable", amount = 4 },
	},
}
create_item{
	name = "gold-cable-16x",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "gold-wire-16x", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 36 },
	}
}
	
	

---SILVER CABLE
create_item{
	name = "silver-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "silver-wire", amount = 1 },
		{ type = "fluid", name = "liquid-rubber", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "silver-cable", amount = 1 },
	}
}
create_recipe{
	name = "silver-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "silver-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "silver-cable", amount = 4 },
	},
}
create_item{
	name = "silver-cable-16x",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "silver-wire-16x", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 36 },
	}
}


	
---HV MOTOR
create_item{
	name = "hv-motor",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "stainless-steel-rod", amount = 2 },
		{ type = "item", name = "magnetic-steel-rod", amount = 1 },
		{ type = "item", name = "electrum-wire", amount = 8 },
		{ type = "item", name = "silver-cable", amount = 4 }
	}
}
create_recipe{
	recipe_name = "hv-motor-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "silver-cable-16x", amount = 12 },
		{ type = "item", name = "long-stainless-steel-rod", amount = 48 },
		{ type = "item", name = "long-magnetic-steel-rod", amount = 24 },
		{ type = "item", name = "electrum-wire-16x", amount = 48 },
	},
	results = {
		{ type = "item", name = "hv-motor", amount = 64 },
	},
}  


   
---HV PISTON
create_item{
	name = "hv-piston",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 3 },
		{ type = "item", name = "stainless-steel-rod", amount = 2 },
		{ type = "item", name = "stainless-steel-gear", amount = 1 },
		{ type = "item", name = "hv-motor", amount = 1 },
		{ type = "item", name = "gold-cable", amount = 2 },
	}
} 
create_recipe{
	recipe_name = "hv-piston-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "gold-cable-16x", amount = 6 },
		{ type = "item", name = "large-stainless-steel-gear", amount = 12 },
		{ type = "item", name = "hv-motor", amount = 48 },
		{ type = "item", name = "long-stainless-steel-rod", amount = 48 },
		{ type = "item", name = "dense-stainless-steel-plate", amount = 16 },
	},
	results = {
		{ type = "item", name = "hv-piston", amount = 64 },
	},
}



---HV PUMP
create_item{
	name = "hv-pump",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "hv-motor", amount = 1 },
		{ type = "item", name = "steel-rotor", amount = 1 },
		{ type = "item", name = "stainless-steel-plate", amount = 3 },
		{ type = "item", name = "steel-screw", amount = 1 },
		{ type = "item", name = "rubber-ring", amount = 2 },
		{ type = "item", name = "gold-cable", amount = 1 }
	},
}
create_recipe{
	recipe_name = "hv-pump-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "gold-cable-16x", amount = 3 },
		{ type = "item", name = "hv-motor", amount = 96 },
		{ type = "item", name = "dense-stainless-steel-plate", amount = 16 },
		{ type = "item", name = "steel-rotor", amount = 48 },
		{ type = "item", name = "steel-screw", amount = 48 },
		{ type = "fluid", name = "silicone-rubber", amount = 345.6 },
	},
	results = {
		{ type = "item", name = "hv-pump", amount = 64 },
	},
}  
   
 
 
---HV CONVEYOR MODULE
create_item{
	name = "hv-conveyor-module",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "hv-motor", amount = 2 },
		{ type = "item", name = "gold-cable", amount = 1 },
		{ type = "item", name = "rubber-sheet", amount = 6 },
	}
}
create_recipe{
	recipe_name = "hv-conveyor-module-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "gold-cable-16x", amount = 3 },
		{ type = "item", name = "hv-motor", amount = 96 },
		{ type = "fluid", name = "silicone-rubber", amount = 4147.2 },
	},
	results = {
		{ type = "item", name = "hv-conveyor-module", amount = 64 },
	},
}



---HV CIRCUIT WRAP
create_item{
	name = "hv-circuit-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "processing-unit", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}



---HV ROBOT ARM
create_item{
	name = "hv-robot-arm",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "hv-motor", amount = 2 },
		{ type = "item", name = "stainless-steel-rod", amount = 2 },
		{ type = "item", name = "hv-piston", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
		{ type = "item", name = "gold-cable", amount = 3 },
	},
}
create_recipe{
	recipe_name = "hv-robot-arm-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "gold-cable-16x", amount = 9 },
		{ type = "item", name = "hv-motor", amount = 96 },
		{ type = "item", name = "hv-piston", amount = 48 },
		{ type = "item", name = "long-stainless-steel-rod", amount = 48 },
		{ type = "item", name = "hv-circuit-wrap", amount = 3 },
	},
	results = {
		{ type = "item", name = "hv-robot-arm", amount = 64 },
	},
}



   
 ---EYE OF ENDER
create_item{
	name = "eye-of-ender",
	category = "mv-chemical-bath-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "ender-pearl", amount = 1 },
		{ type = "fluid", name = "liquid-blaze", amount = 14.4 }
	}
}



---HV SENSOR
create_item{
	name = "hv-sensor",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 4 },
		{ type = "item", name = "chromium-rod", amount = 1 },
		{ type = "item", name = "eye-of-ender", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
	}
}   
create_recipe{
	recipe_name = "hv-sensor-coal",
	category = "uv-coal-recipes",
	energy_required = 48 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "dense-stainless-steel-plate", amount = 21 },
		{ type = "item", name = "hv-circuit-wrap", amount = 3 },
		{ type = "item", name = "eye-of-ender", amount = 48 },
		{ type = "item", name = "long-chromium-rod", amount = 24 },
	},
	results = {
		{ type = "item", name = "hv-sensor", amount = 64 },
	},
} 


  
---HV EMITTER
create_item{
	name = "hv-emitter",
	category = "lv-assembling-machine-recipes",
	energy_required = HV_SPEED,
	ingredients = {
		{ type = "item", name = "chromium-rod", amount = 4 },
		{ type = "item", name = "eye-of-ender", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "gold-cable", amount = 2 }
	}
}   
create_recipe{
	recipe_name = "hv-emitter-coal",
	category = "uv-coal-recipes",
	energy_required = 48 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "gold-cable-16x", amount = 6 },
		{ type = "item", name = "hv-circuit-wrap", amount = 6 },
		{ type = "item", name = "eye-of-ender", amount = 48 },
		{ type = "item", name = "long-chromium-rod", amount = 96 },
	},
	results = {
		{ type = "item", name = "hv-emitter", amount = 64 },
	},
} 

  
  
---RADON 
create_recipe{
	recipe_name = "radon-salt-electrolysis",
	category = "hv-electrolyzer-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "radon-salt", amount = 1 }
	},
	results = {
		{ type = "fluid", name = "radon", amount = 100 },
		{ type = "item", name = "rock-salt", amount = 1 },
	},
	main_product = "radon"
}
   


---QUANTUM EYE
create_item{
	name = "quantum-eye",
	category = "hv-chemical-bath-recipes",
	energy_required = 96,
	ingredients = {
		{ type = "item", name = "eye-of-ender", amount = 1 },
		{ type = "fluid", name = "radon", amount = 25 },
	}
}
   


---HV FIELD GENERATOR
create_item{
	name = "hv-field-generator",
	category = "hv-assembling-machine-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 2 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "vibrant-alloy-wire", amount = 16 },
		{ type = "item", name = "quantum-eye", amount = 1 }
	}
}
create_recipe{
	recipe_name = "hv-field-generator-coal",
	category = "uv-coal-recipes",
	energy_required = 1440 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "vibrant-alloy-wire-16x", amount = 48 },
		{ type = "item", name = "dense-stainless-steel-plate", amount = 12 },
		{ type = "item", name = "hv-circuit-wrap", amount = 6 },
		{ type = "item", name = "quantum-eye", amount = 48 },
	},
	results = {
		{ type = "item", name = "hv-field-generator", amount = 64 },
	},
} 
   


---HV MACHINE CASING
create_item{
	name = "hv-machine-casing",
	ingredients = {
		{ type = "item", name = "stainless-steel-plate", amount = 8 },
	}
}


   
---HV MACHINE HULL
create_item{
	name = "hv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "hv-machine-casing", amount = 1 },
		{ type = "item", name = "gold-cable", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 }
	}
}



---MOLTEN KANTHAL
create_recipe{
	name = "molten-kanthal-extractor",
	category = "lv-extractor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "kanthal-ingot", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-kanthal", amount = 14.4 },
	}
}
---NICHROME COIL BLOCK
create_item{
	name = "nichrome-coil-block",
	category = "hv-assembling-machine-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "nichrome-wire", amount = 16 },
		{ type = "item", name = "stainless-steel-foil", amount = 8 },
		{ type = "fluid", name = "molten-kanthal", amount = 14.4 },
	}
}



---DIAMOND GRINDING HEAD
create_item{
	name = "diamond-grinding-head",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 8 },
		{ type = "item", name = "diamond-dust", amount = 4 },
		{ type = "item", name = "diamond", amount = 1 },
	}
}



---CLEAN STAINLESS STEEL CASING
create_item{
	name = "clean-stainless-steel-casing",
	ingredients = {
		{type = "item", name = "stainless-steel-plate", amount = 6},
		{type = "item", name = "stainless-steel-frame", amount = 1}
    }
}
   
   
   
 ---HIGH VOLTAGE COIL
create_item{
	name = "high-voltage-coil",
	category = "hv-assembling-machine-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "magnetic-steel-rod", amount = 1 },
		{ type = "item", name = "fine-black-steel-wire", amount = 16 }
	}
}



---LPIC WAFER
create_item{
	name = "lpic-wafer",
	recipe_name = "lpic-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 40 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 }
	},
	results = {
		{ type = "item", name = "lpic-wafer", amount = 1 }
	}
}
create_recipe{
	recipe_name = "lpic-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 }
	},
	results = {
		{ type = "item", name = "lpic-wafer", amount = 4 }
	}
}

   
   
---LPIC CHIP
create_item{
	name = "low-powered-integrated-circuit",
	category = "hv-cutting-machine-recipes",
	energy_required = 180,
	ingredients = {
		{ type = "item", name = "lpic-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "low-powered-integrated-circuit", amount = 4 }
	}
}  
   
   
   
---HV ENERGY HATCH
create_item{
	name = "hv-energy-hatch",
	category = "hv-assembling-machine-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "gold-cable", amount = 2 },
		{ type = "item", name = "high-voltage-coil", amount = 1 },
		{ type = "item", name = "low-powered-integrated-circuit", amount = 2 },
		{ type = "fluid", name = "sodium-potassium", amount = 100 }
	},
}  
   
   

---BATTERY ALLOY INGOT
create_item{
	name = "battery-alloy-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 12.5,
	ingredients = {
		{ type = "item", name = "lead-ingot", amount = 4 },
		{ type = "item", name = "antimony", amount = 1 },
	},
	results = {
		{ type = "item", name = "battery-alloy-ingot", amount = 5 },
	}
}



---BATTERY HULL
create_item{
	name = "battery-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "battery-alloy-plate", amount = 5 },
		{ type = "item", name = "copper-cable", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 43.2 },
	}
}



---BATTERY
create_item{
	recipe_name = "filling-assorted-batteries",
	name = "battery",
	category = "lv-canning-machine-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "battery-hull", amount = 3 },
		{ type = "item", name = "sodium", amount = 8 },
		{ type = "item", name = "lithium", amount = 8 },
		{ type = "item", name = "cadmium", amount = 8 },
	},
	results = {
		{ type = "item", name = "battery", amount = 3 },
	}
}


   
---PLASCRETE
create_item{
	name = "plascrete",
	category = "mv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "steel-frame", amount = 1 },
		{ type = "item", name = "polyethylene-sheet", amount = 6 },
		{ type = "fluid", name = "liquid-concrete", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "plascrete", amount = 2 },
	}
}
   
   
   
---FILTER CASING
create_item{
	name = "filter-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "iron-stick", amount = 3 },
		{ type = "item", name = "filter", amount = 3 },
		{ type = "item", name = "steel-rotor", amount = 1 },
		{ type = "item", name = "hv-motor", amount = 1 },
		{ type = "item", name = "steel-frame", amount = 1 },
	},
}     
  


---BLOCK OF EMERALD
create_item{
	name = "block-of-emerald",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "emerald", amount = 9}
    }
}
create_item{
	name = "emerald-plate",
	category = "lv-cutting-machine-recipes",
	energy_required = 9,
	ingredients = {
      {type = "item", name = "block-of-emerald", amount = 1},
      {type = "fluid", name = "lubricant", amount = 2},
    },
	results = {
		{ type = "item", name = "emerald-plate", amount = 9 }
	}
}
 
   
   
---CRYOGENIC AIR DISTILLATION
create_recipe{
	recipe_name = "liquid-air",
	category = "hv-vacuum-freezer-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "air", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "liquid-air", amount = 400 },
	}
}
create_recipe{
	recipe_name = "cryogenic-air-distillation",
	category = "lv-tall-distillation-recipes",
	energy_required = 400,
	ingredients = {
		{ type = "fluid", name = "liquid-air", amount = 5000 },
	},
	results = {
		{ type = "fluid", name = "nitrogen", amount = 3800 },
		{ type = "fluid", name = "oxygen", amount = 1050 },
		{ type = "fluid", name = "argon", amount = 100 },
		{ type = "fluid", name = "carbon-dioxide", amount = 50 },
	},
	main_product = "argon"
}    
   
--[[   
   
 ---CLEANROOM TILES
create_item{
	name = "cleanroom-tile",
	category = "lv-assembling-machine-recipes",
	energy_required = 16,
	ingredients = {
			{ type = "item", name = "filter", amount = 1 },
			{ type = "item", name = "stainless-steel-rotor", amount = 1 },
			{ type = "item", name = "hv-motor", amount = 2 },
			{ type = "item", name = "processing-unit", amount = 1 },
			{ type = "item", name = "hv-machine-hull", amount = 6 },
			{ type = "item", name = "filter-casing", amount = 8 },
			{ type = "item", name = "plascrete", amount = 75 },
		},
	results = {
			{ type = "item", name = "cleanroom-tile", amount = 64 },
		}
}

]]--

---CARBON MONOXIDE
create_recipe{
	recipe_name = "carbon-monoxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "carbon-monoxide", amount = 100 },
	}
}
   
   
   
---METHANOL
create_recipe{
	recipe_name = "methanol-from-co",
	category = "mv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "hydrogen", amount = 400 },
		{ type = "fluid", name = "carbon-monoxide", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "methanol", amount = 100 },
	}
}
create_recipe{
	recipe_name = "methanol-from-co2",
	category = "mv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "hydrogen", amount = 600 },
		{ type = "fluid", name = "carbon-dioxide", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "methanol", amount = 100 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "methanol"
}   
   
   
   
---HYPOCHLOROUS ACID
create_recipe{
	recipe_name = "hypochlorous-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "fluid", name = "mercury", amount = 100 },
		{ type = "fluid", name = "water", amount = 1000 },
		{ type = "fluid", name = "chlorine", amount = 1000 },
	},
	results = {
		{ type = "fluid", name = "hypochlorous-acid", amount = 1000 },
	}
}



---DIMETHYLHYDRAZINE
create_recipe{
	recipe_name = "dimethylhydrazine",
	category = "hv-chemical-reactor-recipes",
	energy_required = 208,
	ingredients = {
		{ type = "fluid", name = "methanol", amount = 200 },
		{ type = "fluid", name = "ammonia", amount = 200 },
		{ type = "fluid", name = "hypochlorous-acid", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "dimethylhydrazine", amount = 100 },
		{ type = "fluid", name = "diluted-hydrochloric-acid", amount = 200 },
	},
	main_product = "dimethylhydrazine"
}
   
   
   
---HYDROCHLORIC ACID CONCENTRATION
create_recipe{
	recipe_name = "hydrochloric-acid-concentration",
	category = "lv-distillation-recipes",
	energy_required = 24,
	ingredients = {
		{ type = "fluid", name = "diluted-hydrochloric-acid", amount = 80 },
	},
	results = {
		{ type = "fluid", name = "hydrochloric-acid", amount = 40 },
	}
}



---DINITROGEN TETROXIDE
create_recipe{
	recipe_name = "dinitrogen-tetroxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 24,
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 700 },
		{ type = "fluid", name = "ammonia", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "dinitrogen-tetroxide", amount = 100 },
		{ type = "fluid", name = "water", amount = 300 },
	},
	main_product = "dinitrogen-tetroxide"
}



---ROCKET FUEL
create_recipe{
	recipe_name = "rocket-fuel",
	category = "lv-mixer-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "fluid", name = "dimethylhydrazine", amount = 100 },
		{ type = "fluid", name = "dinitrogen-tetroxide", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "rocket-fuel", amount = 600 },
	}
}      
   
   
   
---CARBON DIOXIDE
create_recipe{
	recipe_name = "carbon-dioxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "carbon-dioxide", amount = 100 },
	}
}
   
   

---ACETIC ACID
create_recipe{
	recipe_name = "acetic-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 200 },
		{ type = "fluid", name = "ethylene", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "acetic-acid", amount = 100 },
	}
}
   
   

---METHYL ACETATE
create_recipe{
	recipe_name = "methyl-acetate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "acetic-acid", amount = 100 },
		{ type = "fluid", name = "methanol", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "methyl-acetate", amount = 100 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "methyl-acetate"
}
   
   
   
---AMMONIA
create_recipe{
	recipe_name = "ammonia",
	category = "lv-chemical-reactor-recipes",
	energy_required = HV_SPEED * 16,
	ingredients = {
		{ type = "fluid", name = "nitrogen", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "ammonia", amount = 100 }
	}
}

	


---NITRIC ACID
create_recipe{
	recipe_name = "nitric-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "ammonia", amount = 100 },
		{ type = "fluid", name = "oxygen", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "nitric-acid", amount = 100 },
		{ type = "fluid", name = "steam", amount = 100 },
	},
	main_product = "nitric-acid"
}
	
   

---TETRANITROMETHANE
create_recipe{
	recipe_name = "tetranitromethane",
	category = "mv-chemical-reactor-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "fluid", name = "methyl-acetate", amount = 200 },
		{ type = "fluid", name = "nitric-acid", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "tetranitromethane", amount = 100 },
		{ type = "fluid", name = "water", amount = 800 },
		{ type = "item", name = "carbon", amount = 5 },
	},
	main_product = "tetranitromethane"
}
   
   

---CETANE BOOSTED DIESEL
create_recipe{
	recipe_name = "cetane-boosted-diesel",
	category = "hv-mixer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "diesel", amount = 100 },
		{ type = "fluid", name = "tetranitromethane", amount = 2 },
	},
	results = {
		{ type = "fluid", name = "cetane-boosted-diesel", amount = 100 },
	}
}  
   


---BLAZE ROD EXTRACTOR
create_recipe{
	recipe_name = "liquid-blaze",
	category = "lv-extractor-recipes",
	energy_required = 4.4,
	ingredients = {
		{ type = "item", name = "blaze-rod", amount = 1 }
	},
	results = {
		{ type = "fluid", name = "liquid-blaze", amount = 57.6 }
	}
} 
   
   
  
---FROST PROOF CASING
create_item{
	name = "frost-proof-casing",
	ingredients = {
		{type = "item", name = "aluminium-plate", amount = 6},
		{type = "item", name = "aluminium-frame", amount = 1}
    }
}



---PTFE
create_recipe{
	recipe_name = "hydrofluoric-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "fluid", name = "hydrogen", amount = 100 },
		{ type = "fluid", name = "fluorine", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "hydrofluoric-acid", amount = 100 },
	}
}
create_recipe{
	recipe_name = "chloroform",
	category = "lv-chemical-reactor-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "chlorine", amount = 600 },
		{ type = "fluid", name = "methane", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "chloroform", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 300 },
	},
	main_product = "chloroform"
}
create_recipe{
	recipe_name = "tetrafluoroethylene-basic",
	category = "hv-chemical-reactor-recipes",
	energy_required = 96,
	ingredients = {
		{ type = "fluid", name = "chloroform", amount = 200 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "tetrafluoroethylene", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 600 },
	},
	main_product = "tetrafluoroethylene"
}
create_recipe{
	recipe_name = "tetrafluoroethylene-advanced",
	category = "iv-chemical-reactor-recipes",
	energy_required = 432,
	ingredients = {
		{ type = "fluid", name = "chlorine", amount = 1200 },
		{ type = "fluid", name = "methane", amount = 200 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "tetrafluoroethylene", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 1200 },
	},
	main_product = "tetrafluoroethylene"
}
create_recipe{
	recipe_name = "ptfe",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "tetrafluoroethylene", amount = 14.4 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "ptfe", amount = 21.6 },
	}
}
   
   
   
---PTFE SHEET
create_item{
	name = "ptfe-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "fluid", name = "ptfe", amount = 14.4 }
	},
}
   
   
   
---CHEMICALLY INERT CASING
create_item{
	name = "chemically-inert-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "solid-steel-machine-casing", amount = 1 },
		{ type = "fluid", name = "ptfe", amount = 21.6 }
	}
}   
  
  
  
 ---PTFE PIPE CASING
create_item{
	name = "ptfe-pipe-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
      {type = "item", name = "ptfe-sheet", amount = 18},
    }
} 

    
   
---OIL DISTILLATION   
create_recipe{
	recipe_name = "oil-distillation",
	category = "mv-tall-distillation-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "fluid", name = "crude-oil", amount = 50 },
	},
	results = {
		{ type = "fluid", name = "sulfuric-gas", amount = 60 },
		{ type = "fluid", name = "sulfuric-heavy-fuel", amount = 15 },
		{ type = "fluid", name = "sulfuric-light-fuel", amount = 50 },
		{ type = "fluid", name = "sulfuric-naphtha", amount = 20 },
	},
	main_product = "sulfuric-light-fuel"
}



---DESULFURIZING REFINERY GAS   
create_recipe{
	recipe_name = "refinery-gas-desulfurization",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-gas", amount = 1600 },
		{ type = "fluid", name = "hydrogen", amount = 200 }
	},
	results = {
		{ type = "fluid", name = "hydrogen-sulfide", amount = 100 },
		{ type = "fluid", name = "refinery-gas", amount = 1600 }
	},
	main_product = "refinery-gas"
}



---DESULFURIZING NAPHTHA
create_recipe{
	recipe_name = "naphtha-desulfurization",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-naphtha", amount = 1200 },
		{ type = "fluid", name = "hydrogen", amount = 200 }
	},
	results = {
		{ type = "fluid", name = "hydrogen-sulfide", amount = 100 },
		{ type = "fluid", name = "naphtha", amount = 1200 }
	},
	main_product = "naphtha"
}   



---STEAM CRACKED GAS   
create_recipe{
	recipe_name = "steam-cracked-gas",
	category = "hv-cracker-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "fluid", name = "refinery-gas", amount = 100 },
		{ type = "fluid", name = "steam", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "steam-cracked-gas", amount = 100 }
	}
}
   
   
   
---STEAM CRACKED HEAVY FUEL   
create_recipe{
	recipe_name = "steam-cracked-heavy-fuel",
	category = "hv-cracker-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "fluid", name = "heavy-fuel", amount = 100 },
		{ type = "fluid", name = "steam", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "steam-cracked-heavy-fuel", amount = 100 }
	}
}
   
   
   
---STEAM CRACKED LIGHT FUEL   
create_recipe{
	recipe_name = "steam-cracked-light-fuel",
	category = "hv-cracker-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "fluid", name = "light-fuel", amount = 100 },
		{ type = "fluid", name = "steam", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "steam-cracked-light-fuel", amount = 100 }
	}
}


   
---STEAM CRACKED NAPHTHA 
create_recipe{
	recipe_name = "steam-cracked-naphtha",
	category = "hv-cracker-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "fluid", name = "naphtha", amount = 100 },
		{ type = "fluid", name = "steam", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "steam-cracked-naphtha", amount = 100 }
	}
}
 
   

---DISTILLING STEAM CRACKED HEAVY FUEL   
create_recipe{
	recipe_name = "distilling-steam-cracked-heavy-fuel",
	category = "mv-tall-distillation-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "steam-cracked-heavy-fuel", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "ethylene", amount = 15 },
		{ type = "fluid", name = "methane", amount = 15 },
		{ type = "fluid", name = "propane", amount = 1 },
		{ type = "fluid", name = "propene", amount = 10 },
		{ type = "fluid", name = "ethane", amount = 1.5 },
		{ type = "fluid", name = "benzene", amount = 40 },
		{ type = "fluid", name = "butene", amount = 8 },
		{ type = "fluid", name = "butadiene", amount = 5 },
		{ type = "fluid", name = "light-fuel", amount = 10 },
		{ type = "fluid", name = "naphtha", amount = 12.5 },
		{ type = "fluid", name = "toluene", amount = 8 },
		{ type = "item", name = "carbon", amount = 1 , probability = 0.33}
	},
	main_product = "benzene"
}

   
   
---DISTILLING STEAM CRACKED LIGHT FUEL   
create_recipe{
	recipe_name = "distilling-steam-cracked-light-fuel",
	category = "mv-tall-distillation-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "steam-cracked-light-fuel", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "ethylene", amount = 25 },
		{ type = "fluid", name = "methane", amount = 25 },
		{ type = "fluid", name = "propane", amount = 5 },
		{ type = "fluid", name = "propene", amount = 25 },
		{ type = "fluid", name = "ethane", amount = 5 },
		{ type = "fluid", name = "benzene", amount = 15 },
		{ type = "fluid", name = "butene", amount = 6.5 },
		{ type = "fluid", name = "butadiene", amount = 5 },
		{ type = "fluid", name = "heavy-fuel", amount = 5 },
		{ type = "fluid", name = "naphtha", amount = 10 },
		{ type = "fluid", name = "toluene", amount = 3 },
		{ type = "item", name = "carbon", amount = 1 , probability = 0.33}
	},
	main_product = "propene"
}



---DISTILLING STEAM CRACKED NAPHTHA 
create_recipe{
	recipe_name = "distilling-steam-cracked-naphtha",
	category = "mv-tall-distillation-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "steam-cracked-naphtha", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "ethylene", amount = 50 },
		{ type = "fluid", name = "methane", amount = 50 },
		{ type = "fluid", name = "propane", amount = 1.5 },
		{ type = "fluid", name = "propene", amount = 30 },
		{ type = "fluid", name = "ethane", amount = 6.5 },
		{ type = "fluid", name = "benzene", amount = 10 },
		{ type = "fluid", name = "butene", amount = 5 },
		{ type = "fluid", name = "butadiene", amount = 5 },
		{ type = "fluid", name = "heavy-fuel", amount = 2.5 },
		{ type = "fluid", name = "naphtha", amount = 5 },
		{ type = "fluid", name = "toluene", amount = 2 },
		{ type = "item", name = "carbon", amount = 1 , probability = 0.33}
	},
	main_product = "ethylene"
}



---DISTILLING STEAM CRACKED GAS 
create_recipe{
	recipe_name = "distilling-steam-cracked-gas",
	category = "mv-tall-distillation-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "steam-cracked-gas", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "ethylene", amount = 9.2 },
		{ type = "fluid", name = "methane", amount = 101.8 },
		{ type = "fluid", name = "helium", amount = 2 },
		{ type = "fluid", name = "propene", amount = 0.8 },
		{ type = "fluid", name = "ethane", amount = 4.5 },
		{ type = "item", name = "carbon", amount = 1 , probability = 0.11}
	},
	main_product = "methane"
}



---TOLUENE FROM WOOD TAR
create_recipe{
	recipe_name = "toluene-from-wood-tar",
	category = "mv-tall-distillation-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "wood-tar", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "toluene", amount = 10 }
	},
}
   
   
   
---GELLED TOLUENE
create_item{
	name = "gelled-toluene",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "toluene", amount = 10 }
	},
}
   
   
   
---TNT
create_item{
	name = "explosives",
	category = "mv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "gelled-toluene", amount = 4 },
		{ type = "fluid", name = "nitration-mixture", amount = 20 }
	},
	results = {
		{ type = "item", name = "explosives", amount = 1},
		{ type = "fluid", name = "diluted-sulfuric-acid", amount = 15 },
	},
	main_product = "explosives"
}



---CLIFF EXPLOSIVES
create_recipe{
	name = "cliff-explosives",
	ingredients = {
		{ type = "item", name = "explosives", amount = 4 },
		{ type = "item", name = "steel-plate", amount = 4 },
	},
	results = {
		{ type = "item", name = "cliff-explosives", amount = 1},
	}
}



---HV COMBUSTION GENERATOR
create_item{
	name = "hv-combustion-generator",
	stack_size = 10,
--	place_result = "hv-combustion-generator",
	ingredients = {
		{type = "item", name = "hv-piston", amount = 2},
		{type = "item", name = "processing-unit", amount = 1},
		{type = "item", name = "hv-motor", amount = 2},
		{type = "item", name = "hv-machine-hull", amount = 1},
		{type = "item", name = "large-stainless-steel-gear", amount = 2},
    }
} 



---STEEL PIPE CASING
create_item{
	name = "steel-pipe-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 16 },
		{ type = "item", name = "steel-frame", amount = 1 },
	}
} 
   
   
   
---MAGNALIUM INGOT
create_item{
	name = "magnalium-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 7.5,
	ingredients = {
		{ type = "item", name = "magnesium", amount = 1 },
		{ type = "item", name = "aluminium-dust", amount = 2 },
	},
	results = {
		{ type = "item", name = "magnalium-ingot", amount = 3 },
	}
}
   
   
   
---CARBON PLATE
create_item{
	name = "carbon-plate",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "raw-carbon-mesh", amount = 1 },
	}
}
create_item{
	name = "raw-carbon-mesh",
	category = "lv-assembling-machine-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "item", name = "raw-carbon-fibers", amount = 2 },
	}
}
create_item{
	name = "raw-carbon-fibers",
	category = "ev-autoclave-recipes",
	energy_required = 1.85 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "carbon", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 0.9 },
	},
	results = {
		{ type = "item", name = "raw-carbon-fibers", amount = 16 },
	}
}
create_recipe{
	name = "raw-carbon-fibers-ptfe",
	category = "mv-autoclave-recipes",
	energy_required = 1.85 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "carbon", amount = 4 },
		{ type = "fluid", name = "ptfe", amount = 1.8 },
	},
	results = {
		{ type = "item", name = "raw-carbon-fibers", amount = 2 },
	}
}
   
   
   
---ENDER TANK
create_item{
	name = "ender-pearl-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "ender-pearl", amount = 9 },
	}
}
create_item{
	name = "ender-tank",
	category = "hv-assembling-machine-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "blaze-rod", amount = 8 },
		{ type = "item", name = "obsidian", amount = 3 },
		{ type = "item", name = "storage-tank", amount = 1 },
		{ type = "item", name = "ender-pearl-block", amount = 1 },
	},
}



---NETHER AIR ENDER TANK
create_item{
	name = "nether-air-ender-tank",
	category = "hv-microverse-projector-recipes",
	energy_required = HV_SPEED * 120,
	subgroup = "subgroup-microminer-t2",
--	place_result = "nether-air-ender-tank",
	stack_size = 10,
	ingredients = {
      {type = "item", name = "stainless-steel-plated-microminer", amount = 1},
      {type = "item", name = "nether-data", amount = 1},
      {type = "item", name = "hv-air-collector", amount = 1},
      {type = "item", name = "ender-tank", amount = 2},
      {type = "fluid", name = "diesel", amount = 600},

    }
}
create_recipe{
	recipe_name = "nether-air-collection",
	category = "nether-air-ender-tank-recipes",
	subgroup = "subgroup-microminer-t2",
	energy_required = 10,
	ingredients = { },
	results = {
		{ type = "fluid", name = "nether-air", amount = 1000 },
	}
}



---LIQUID NETHER AIR
create_recipe{
	recipe_name = "liquid-nether-air",
	category = "hv-vacuum-freezer-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "nether-air", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "liquid-nether-air", amount = 400 },
	}
}



---NETHER AIR DISTILLATION
create_recipe{
	recipe_name = "nether-air-distillation",
	category = "lv-tall-distillation-recipes",
	energy_required = HV_SPEED * 200,
	ingredients = {
		{ type = "fluid", name = "liquid-nether-air", amount = 10000 },
	},
	results = {
		{ type = "fluid", name = "carbon-monoxide", amount = 7000 },
		{ type = "fluid", name = "sulfur-trioxide", amount = 1000 },
		{ type = "fluid", name = "hydrogen-sulfide", amount = 700 },
		{ type = "fluid", name = "sulfur-dioxide", amount = 700 },
		{ type = "fluid", name = "neon", amount = 500 },
		{ type = "fluid", name = "helium-3", amount = 100 },
		{ type = "item", name = "gold-dust", amount = 1 },
	},
	main_product = "carbon-monoxide"
}



---ENDER AIR ENDER TANK
create_item{
	name = "ender-air-ender-tank",
	category = "ev-microverse-projector-recipes",
	energy_required = EV_SPEED * 150,
	subgroup = "subgroup-microminer-t2",
--	place_result = "ender-air-ender-tank",
	stack_size = 10,
	ingredients = {
      {type = "item", name = "titanium-plated-microminer", amount = 1 },
      {type = "item", name = "the-end-data", amount = 1 },
      {type = "item", name = "ev-air-collector", amount = 1},
      {type = "item", name = "ender-tank", amount = 2},
      {type = "fluid", name = "rocket-fuel", amount = 800 },
    }
}
create_recipe{
	recipe_name = "ender-air-collection",
	category = "ender-air-ender-tank-recipes",
	subgroup = "subgroup-microminer-t2",
	energy_required = 10,
	ingredients = { },
	results = {
		{ type = "fluid", name = "ender-air", amount = 1000 },
	}
}



---LIQUID ENDER AIR
create_recipe{
	recipe_name = "liquid-ender-air",
	category = "hv-vacuum-freezer-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "ender-air", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "liquid-ender-air", amount = 400 },
	}
}
   

   
---ENDER AIR DISTILLATION
create_recipe{
	recipe_name = "ender-air-distillation",
	category = "lv-tall-distillation-recipes",
	energy_required = EV_SPEED * 200,
	ingredients = {
		{ type = "fluid", name = "liquid-ender-air", amount = 20000 },
	},
	results = {
		{ type = "fluid", name = "nitrogen-dioxide", amount = 7200 },
		{ type = "fluid", name = "deuterium", amount = 5000 },
		{ type = "fluid", name = "tritium", amount = 5000 },
		{ type = "fluid", name = "helium", amount = 1500 },
		{ type = "fluid", name = "neon", amount = 1000 },
		{ type = "fluid", name = "radon", amount = 100 },
		{ type = "fluid", name = "krypton", amount = 100 },
		{ type = "fluid", name = "xenon", amount = 100 },
		{ type = "item", name = "endstone-dust", amount = 1 },
	},
	main_product = "nitrogen-dioxide"
}



---PROPENE CELL
create_item{
	name = "propene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "76.8MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "propene", amount = 800},
	}
}



---METHANE CELL
create_item{
	name = "methane-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "41.6MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "methane", amount = 800},
	}
}



---REFINERY GAS CELL
create_item{
	name = "refinery-gas-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "64MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "refinery-gas", amount = 800},
	}
}



---ETHANE CELL
create_item{
	name = "ethane-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "67.2MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "ethane", amount = 800},
	}
}



---ETHYLENE CELL
create_item{
	name = "ethylene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "51.2MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "ethylene", amount = 800},
	}
}



---PROPANE CELL
create_item{
	name = "propane-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "92.8MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "propane", amount = 800},
	}
}



---BUTENE CELL
create_item{
	name = "butene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "102.4MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "butene", amount = 800},
	}
}



---BUTADIENE CELL
create_item{
	name = "butadiene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "82.4MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "butadiene", amount = 800},
	}
}



---NAPHTHA CELL
create_item{
	name = "naphtha-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "88MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "naphtha", amount = 800},
	}
}



---TOLUENE CELL
create_item{
	name = "toluene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "131.2MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "toluene", amount = 800},
	}
}



---CETANE BOOSTED DIESEL CELL
create_item{
	name = "cetane-boosted-diesel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "400MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "cetane-boosted-diesel", amount = 800},
	}
}



---PRODUCTION SCIENCE PACK
create_recipe{
	recipe_name = "ev-science-pack",
	category = "hv-assembling-machine-recipes",
	subgroup = "subgroup-science-packs",
	order = "e",
	energy_required = HV_SPEED * 120,
	ingredients = {
		{ type = "item", name = "hv-large-chemical-reactor", amount = 1 },
		{ type = "item", name = "distillation-tower-controller", amount = 1 },
		{ type = "item", name = "quantum-eye", amount = 6 },
		{ type = "item", name = "explosives", amount = 24 },
	},
	results = {
		{ type = "item", name = "production-science-pack", amount = 32 },
	}
}



---SIFTER RECIPES
create_recipe{
	name = "coal-sifter",
	category = "lv-sifter-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "crushed-coal", amount = 1 },
	},
	results = {
		{ type = "item", name = "coal", amount = 3 },
		{ type = "item", name = "coal-dust", probability = 0.5, amount = 1 },
	},
	main_product = "coal"
}
create_item{ skip_recipe = true,
	name = "exquisite-diamond",
	subgroup = "subgroup-lv-sifter-recipes",
}
create_item{ skip_recipe = true,
	name = "flawless-diamond",
	subgroup = "subgroup-lv-sifter-recipes",
}
create_item{ skip_recipe = true,
	name = "flawed-diamond",
	subgroup = "subgroup-lv-sifter-recipes",
}
create_item{ skip_recipe = true,
	name = "chipped-diamond",
	subgroup = "subgroup-lv-sifter-recipes",
}
create_recipe{
	name = "diamond-sifter",
	category = "lv-sifter-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "crushed-diamond", amount = 1 },
	},
	results = {
		{ type = "item", name = "exquisite-diamond", probability = 0.03, amount = 1 },
		{ type = "item", name = "flawless-diamond", probability = 0.12, amount = 1 },	
		{ type = "item", name = "diamond", probability = 0.45, amount = 1 },
		{ type = "item", name = "flawed-diamond", probability = 0.14, amount = 1 },
		{ type = "item", name = "chipped-diamond", probability = 0.28, amount = 1 },
		{ type = "item", name = "diamond-dust", probability = 0.35, amount = 1 },
	},
	main_product = "diamond"
}