--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---------------------
---    TITANIUM   ---
---------------------
   
---TITANIUM TETRACHLORIDE
create_recipe{
	recipe_name = "titanium-tetrachloride",
	category = "hv-chemical-reactor-recipes",
	energy_required = HV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 2 },
		{ type = "item", name = "rutile-dust", amount = 1 },
		{ type = "fluid", name = "chlorine", amount = 400 }
	},
	results = {
		{ type = "fluid", name = "titanium-tetrachloride", amount = 100 },
		{ type = "fluid", name = "carbon-monoxide", amount = 200 }
	},
	main_product = "titanium-tetrachloride"
}


   
---HOT TITANIUM INGOT
create_item{
	name = "hot-titanium-ingot",
	recipe_name = "hot-titanium-ingot-from-tetrachloride",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "magnesium", amount = 2 },
		{ type = "fluid", name = "titanium-tetrachloride", amount = 100 }
	},
	results = {
		{ type = "item", name = "hot-titanium-ingot", amount = 1 },
		{ type = "item", name = "magnesium-chloride", amount = 6 }
	},
	main_product = "hot-titanium-ingot"
}
   
   

---MAGNESIUM CHLORIDE   
create_item{
	name = "magnesium-chloride",
	recipe_name = "magnesium-chloride-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "magnesium-chloride", amount = 3 }
	},
	results = {
		{ type = "item", name = "magnesium", amount = 1 },
		{ type = "fluid", name = "chlorine", amount = 200 }
	},
	main_product = "magnesium"
}



---ALUMINIUM CABLE
create_item{
	name = "aluminium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "aluminium-wire", amount = 1 },
		{ type = "fluid", name = "liquid-rubber", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "aluminium-cable", amount = 1 }
	}
}
create_recipe{
	name = "aluminium-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "aluminium-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "aluminium-cable", amount = 4 },
	},
}   
create_item{
	name = "aluminium-cable-16x",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "aluminium-wire-16x", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 36 },
	}
}
   


--------------------------
---    EV COMPONENTS   ---
--------------------------
   
---MAGNETIC NEODYMIUM ROD   
create_item{
	name = "magnetic-neodymium-rod",
	category = "hv-polarizer-recipes",
	energy_required = 14.4,
	ingredients = {
		{ type = "item", name = "neodymium-rod", amount = 1 }
	}
}
create_item{
	name = "long-magnetic-neodymium-rod",
	category = "hv-polarizer-recipes",
	energy_required = 28.8,
	ingredients = {
		{ type = "item", name = "long-neodymium-rod", amount = 1 }
	}
}
   
	
	
---EV MOTOR
create_item{
	name = "ev-motor",
	ingredients = {
		{ type = "item", name = "titanium-rod", amount = 2 },
		{ type = "item", name = "magnetic-neodymium-rod", amount = 1 },
		{ type = "item", name = "kanthal-wire", amount = 8 },
		{ type = "item", name = "aluminium-cable", amount = 4 }
	}
}
create_recipe{
	recipe_name = "ev-motor-coal",
	category = "uv-coal-recipes",
	energy_required = EV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 12 },
		{ type = "item", name = "kanthal-wire-16x", amount = 48 },
		{ type = "item", name = "long-magnetic-neodymium-rod", amount = 24 },
		{ type = "item", name = "long-titanium-rod", amount = 48 },
		{ type = "item", name = "hv-circuit-wrap", amount = 3 },
	},
	results = {
		{ type = "item", name = "ev-motor", amount = 64 },
	},
}


   
---EV PISTON
create_item{
	name = "ev-piston",
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 3 },
		{ type = "item", name = "titanium-rod", amount = 2 },
		{ type = "item", name = "titanium-gear", amount = 1 },
		{ type = "item", name = "ev-motor", amount = 1 },
		{ type = "item", name = "aluminium-cable", amount = 2 }
	}
}
create_recipe{
	recipe_name = "ev-piston-coal",
	category = "uv-coal-recipes",
	energy_required = EV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 6 },
		{ type = "item", name = "dense-titanium-plate", amount = 16 },
		{ type = "item", name = "large-titanium-gear", amount = 12 },
		{ type = "item", name = "long-titanium-rod", amount = 48 },
		{ type = "item", name = "hv-motor", amount = 48 },
	},
	results = {
		{ type = "item", name = "ev-piston", amount = 64 },
	},
}
   


---EV PUMP
create_item{
	name = "ev-pump",
	ingredients = {
		{ type = "item", name = "ev-motor", amount = 1 },
		{ type = "item", name = "stainless-steel-rotor", amount = 1 },
		{ type = "item", name = "titanium-plate", amount = 3 },
		{ type = "item", name = "stainless-steel-screw", amount = 1 },
		{ type = "item", name = "rubber-ring", amount = 2 },
		{ type = "item", name = "aluminium-cable", amount = 1 }
	}
}
create_recipe{
	recipe_name = "ev-pump-coal",
	category = "uv-coal-recipes",
	energy_required = EV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 3 },
		{ type = "item", name = "ev-motor", amount = 96 },
		{ type = "item", name = "dense-titanium-plate", amount = 16 },
		{ type = "item", name = "stainless-steel-rotor", amount = 48 },
		{ type = "item", name = "stainless-steel-screw", amount = 48 },
		{ type = "fluid", name = "silicone-rubber", amount = 345.6 },
	},
	results = {
		{ type = "item", name = "ev-pump", amount = 64 },
	},
}  
   
   
   
---EV CONVEYOR MODULE
create_item{
	name = "ev-conveyor-module",
	ingredients = {
		{ type = "item", name = "ev-motor", amount = 2 },
		{ type = "item", name = "aluminium-cable", amount = 1 },
		{ type = "item", name = "rubber-sheet", amount = 6 },
	}
}
create_recipe{
	recipe_name = "ev-conveyor-module-coal",
	category = "uv-coal-recipes",
	energy_required = EV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 3 },
		{ type = "item", name = "hv-motor", amount = 96 },
		{ type = "fluid", name = "silicone-rubber", amount = 4147.2 },
	},
	results = {
		{ type = "item", name = "ev-conveyor-module", amount = 64 },
	},
}



---EV CIRCUIT WRAP
create_item{
	name = "ev-circuit-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "ev-circuit", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}



---EV ROBOT ARM
create_item{
	name = "ev-robot-arm",
	ingredients = {
		{ type = "item", name = "ev-motor", amount = 2 },
		{ type = "item", name = "titanium-rod", amount = 2 },
		{ type = "item", name = "ev-piston", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 1 },
		{ type = "item", name = "aluminium-cable", amount = 3 }
	}
}   
create_recipe{
	recipe_name = "ev-robot-arm-coal",
	category = "uv-coal-recipes",
	energy_required = HV_SPEED * 48,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 9 },
		{ type = "item", name = "ev-motor", amount = 96 },
		{ type = "item", name = "ev-piston", amount = 48 },
		{ type = "item", name = "long-titanium-rod", amount = 48 },
		{ type = "item", name = "ev-circuit-wrap", amount = 3 },
	},
	results = {
		{ type = "item", name = "ev-robot-arm", amount = 64 },
	},
}



---EV SENSOR
create_item{
	name = "ev-sensor",
	ingredients = {
		{ type = "item", name = "quantum-eye", amount = 1 },
		{ type = "item", name = "platinum-rod", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "aluminium-cable", amount = 2 }
	}
}
create_recipe{
	recipe_name = "ev-sensor-coal",
	category = "uv-coal-recipes",
	energy_required = 48 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "dense-titanium-plate", amount = 21 },
		{ type = "item", name = "ev-circuit-wrap", amount = 3 },
		{ type = "item", name = "quantum-eye", amount = 48 },
		{ type = "item", name = "long-platinum-rod", amount = 24 },
	},
	results = {
		{ type = "item", name = "ev-sensor", amount = 64 },
	},
} 



---EV EMITTER
create_item{
	name = "ev-emitter",
	ingredients = {
		{ type = "item", name = "quantum-eye", amount = 1 },
		{ type = "item", name = "platinum-rod", amount = 1 },
		{ type = "item", name = "titanium-plate", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 1 },
	}
}
create_recipe{
	recipe_name = "ev-emitter-coal",
	category = "uv-coal-recipes",
	energy_required = 48 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "aluminium-cable-16x", amount = 6 },
		{ type = "item", name = "ev-circuit-wrap", amount = 6 },
		{ type = "item", name = "quantum-eye", amount = 48 },
		{ type = "item", name = "long-platinum-rod", amount = 96 },
	},
	results = {
		{ type = "item", name = "hv-emitter", amount = 64 },
	},
} 
   
  
  
---EV FIELD GENERATOR
create_item{
	name = "ev-field-generator",
	category = "ev-assembling-machine-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "end-steel-wire", amount = 16 },
		{ type = "item", name = "nether-star", amount = 1 }
	}
}
create_recipe{
	recipe_name = "ev-field-generator-coal",
	category = "uv-coal-recipes",
	energy_required = 1440 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "end-steel-wire-16x", amount = 48 },
		{ type = "item", name = "dense-titanium-plate", amount = 12 },
		{ type = "item", name = "ev-circuit-wrap", amount = 6 },
		{ type = "item", name = "nether-star", amount = 48 },
	},
	results = {
		{ type = "item", name = "ev-field-generator", amount = 64 },
	},
}



---EV MACHINE CASING
create_item{
	name = "ev-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 8 },
	}
}


   
---EV MACHINE HULL
create_item{
	name = "ev-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "ev-machine-casing", amount = 1 },
		{ type = "item", name = "aluminium-cable", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 }
	}
}
   
   
   
---EXTREME VOLTAGE COIL
create_item{
	name = "extreme-voltage-coil",
	category = "ev-assembling-machine-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "magnetic-neodymium-rod", amount = 1 },
		{ type = "item", name = "fine-platinum-wire", amount = 16 }
	}
}
   


---MPIC WAFER
create_item{
	name = "mpic-wafer",
	recipe_name = "mpic-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 60 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "mpic-wafer", amount = 1 },
	}
}
create_recipe{
	recipe_name = "mpic-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 45 * EV_SPEED,
	ingredients = {
			{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
			{ type = "fluid", name = "distilled-water", amount = 10 },
		},
	results = {
			{ type = "item", name = "mpic-wafer", amount = 4 },
		}
}
   
   
   
---MPIC CHIP
create_item{
	name = "medium-powered-integrated-circuit",
	category = "ev-cutting-machine-recipes",
	energy_required = 360,
	ingredients = {
		{ type = "item", name = "mpic-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 4 }
	}
}
   
   
   
---EV ENERGY HATCH
create_item{
	name = "ev-energy-hatch",
	category = "ev-assembling-machine-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "aluminium-cable", amount = 2 },
		{ type = "item", name = "extreme-voltage-coil", amount = 1 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 2 },
		{ type = "fluid", name = "sodium-potassium", amount = 200 }
	}
}
   
   
   
---EV DYNAMO HATCH
create_item{
	name = "ev-dynamo-hatch",
	category = "ev-assembling-machine-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "aluminium-spring", amount = 2 },
		{ type = "item", name = "extreme-voltage-coil", amount = 1 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 2 },
		{ type = "fluid", name = "sodium-potassium", amount = 200 }
	}
}
  

  
---RTM ALLOY COIL BLOCK (IV)
create_item{
	name = "rtm-alloy-coil-block",
	category = "ev-assembling-machine-recipes",
	energy_required = 200,
	ingredients = {
		{ type = "item", name = "rtm-alloy-wire", amount = 16 },
		{ type = "item", name = "vanadium-steel-foil", amount = 8 },
		{ type = "fluid", name = "molten-nichrome", amount = 14.4 }
	}
}
   
   
   
---ACETONE
create_recipe{
	recipe_name = "acetone",
	category = "hv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "fluid", name = "acetic-acid", amount = 300 }
	},
	results = {
		{ type = "fluid", name = "acetone", amount = 200 },
		{ type = "fluid", name = "oxygen", amount = 100 }
	},
	main_product = "acetone"
}


   
---EPICHLOROHYDRON
create_recipe{
	recipe_name = "epichlorohydrin",
	category = "lv-chemical-reactor-recipes",
	energy_required = 24,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "chlorine", amount = 400 },
		{ type = "fluid", name = "propene", amount = 100 },
		{ type = "fluid", name = "water", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "epichlorohydrin", amount = 100 },
		{ type = "fluid", name = "salt-water", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 200 }
	},
	main_product = "epichlorohydrin"
}
   
   
   
---EPOXY
create_recipe{
	recipe_name = "epoxy",
	category = "lv-chemical-reactor-recipes",
	energy_required = 24,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "epichlorohydrin", amount = 100 },
		{ type = "fluid", name = "acetone", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
		{ type = "fluid", name = "phenol", amount = 200 }
	},
	results = {
		{ type = "fluid", name = "epoxy", amount = 100 },
		{ type = "fluid", name = "salt-water", amount = 100 },
		{ type = "fluid", name = "diluted-hydrochloric-acid", amount = 100 }
	},
	main_product = "epoxy"
}
   
   
   
---SALT WATER ELECTROLYSIS
create_recipe{
	recipe_name = "salt-water-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 36,
	ingredients = {
		{ type = "fluid", name = "salt-water", amount = 100 },
	},
	results = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "chlorine", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 100 },
	},
	main_product = "sodium-hydroxide"
}


   
---EPOXY SHEET
create_item{
	name = "epoxy-sheet",
	category = "lv-fluid-solidifier-recipes",
	ingredients = {
		{ type = "fluid", name = "epoxy", amount = 14 }
	},
}


   
---EPOXY CIRCUIT BOARD
create_item{
	name = "epoxy-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "epoxy-sheet", amount = 1 },
		{ type = "item", name = "gold-foil", amount = 8 },
		{ type = "fluid", name = "sulfuric-acid", amount = 50 }
	}
}
   
   
   
---EPOXY PRINTED CIRCUIT BOARD
create_item{
	name = "epoxy-printed-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 45,
	ingredients = {
		{ type = "item", name = "epoxy-circuit-board", amount = 1 },
		{ type = "item", name = "electrum-foil", amount = 8 },
		{ type = "fluid", name = "iron-iii-chloride", amount = 50 }
	}
}
   


---NIOBIUM PENTOXIDE
create_item{
	name = "niobium-pentoxide",
	recipe_name = "pyrochlore-fluorination",
	category = "hv-chemical-bath-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "pyrochlore", amount = 11 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 400 }
	},
	results = {
		{ type = "item", name = "niobium-pentoxide", amount = 7 },
		{ type = "item", name = "tantalum-pentoxide", amount = 1 },
		{ type = "item", name = "fluorite", amount = 6 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "niobium-pentoxide"
}
create_recipe{
	recipe_name = "niobium-pentoxide-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "niobium-pentoxide", amount = 7 }
	},
	results = {
		{ type = "item", name = "niobium-dust", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 500 }
	},
	main_product = "niobium-dust"
}
   
   
   
---TANTALUM PENTOXIDE
create_item{
	name = "tantalum-pentoxide",
	recipe_name = "tantalite-fluorination",
	category = "hv-chemical-bath-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "tantalite-dust", amount = 9 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 200 }
	},
	results = {
		{ type = "item", name = "niobium-pentoxide", amount = 1 },
		{ type = "item", name = "tantalum-pentoxide", amount = 7 },
		{ type = "item", name = "manganese-difluoride", amount = 2 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "tantalum-pentoxide"
}
create_recipe{
	recipe_name = "tantalum-pentoxide-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "tantalum-pentoxide", amount = 7 }
	},
	results = {
		{ type = "item", name = "tantalum-dust", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 500 }
	},
	main_product = "tantalum-dust"
}
   
   
   
---FLUORITE   
create_item{
	name = "fluorite",
	recipe_name = "fluorite-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "fluorite", amount = 3 }
		},
	results = {
		{ type = "item", name = "calcium", amount = 1 },
		{ type = "fluid", name = "fluorine", amount = 200 }
	},
	main_product = "fluorine"
}
   


---MANGANESE DIFLUORIDE   
create_item{
	name = "manganese-difluoride",
	recipe_name = "manganese-difluoride-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "manganese-difluoride", amount = 3 }
	},
	results = {
		{ type = "item", name = "manganese-dust", amount = 1 },
		{ type = "fluid", name = "fluorine", amount = 200 }
	},
	main_product = "fluorine"
} 
   
   
   
---SMD RESISTOR   
create_item{
	name = "smd-resistor",
	category = "mv-assembling-machine-recipes",
	energy_required = 32,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "item", name = "fine-tantalum-wire", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 28 }
	},
	results = {
		{ type = "item", name = "smd-resistor", amount = 32 }
	}
}
   
   
   
---SMD CAPACITOR
create_item{
	name = "smd-capacitor",
	category = "mv-assembling-machine-recipes",
	energy_required = 24,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "tantalum-foil", amount = 1 },
		{ type = "item", name = "thin-pvc-sheet", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 7 }
	},
	results = {
		{ type = "item", name = "smd-capacitor", amount = 24 }
	}
}
   
   
   
---SMD TRANSISTOR
create_item{
	name = "smd-transistor",
	category = "mv-assembling-machine-recipes",
	energy_required = 32,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "gallium-foil", amount = 1 },
		{ type = "item", name = "fine-tantalum-wire", amount = 2 },
		{ type = "fluid", name = "polyethylene", amount = 14 }
	},
	results = {
		{ type = "item", name = "smd-transistor", amount = 32 }
	}
}



---SMD INDUCTOR
create_item{
	name = "smd-inductor",
	category = "mv-assembling-machine-recipes",
	energy_required = 32,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "nickel-zinc-ferrite-ring", amount = 1 },
		{ type = "item", name = "fine-tantalum-wire", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 14 }
	},
	results = {
		{ type = "item", name = "smd-inductor", amount = 32 }
	}
}
   
   
   
---SMD DIODE
create_item{
	name = "smd-diode",
	category = "mv-assembling-machine-recipes",
	energy_required = 40,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 4 },
		{ type = "item", name = "fine-platinum-wire", amount = 8 },
		{ type = "fluid", name = "polyethylene", amount = 28 }
	},
	results = {
		{ type = "item", name = "smd-diode", amount = 32 }
	}
}  
   
   
   
--- MOLTEN GLOWSTONE
create_recipe{
	recipe_name = "molten-glowstone",
	category = "lv-extractor-recipes",
	energy_required = 5.65,
	ingredients = {
		{ type = "item", name = "glowstone-dust", amount = 1 }
	},
	results = {
		{ type = "fluid", name = "molten-glowstone", amount = 14.4 }
	}
}
   
   
   
---NANO CPU WAFER
create_item{
	name = "nano-cpu-wafer",
	category = "ev-chemical-reactor-recipes",
	energy_required = 480,
	ingredients = {
		{ type = "item", name = "cpu-wafer", amount = 1 },
		{ type = "item", name = "raw-carbon-fibers", amount = 16 },
		{ type = "fluid", name = "molten-glowstone", amount = 57.6 },
	},
}
   
   
   
---NANO CPU CHIP
create_item{
	name = "nano-cpu-chip",
	category = "hv-cutting-machine-recipes",
	energy_required = 270,
	ingredients = {
		{ type = "item", name = "nano-cpu-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "nano-cpu-chip", amount = 8 }
	}
}
   
   
   
   ---RAW CARBON FIBERS
create_item{
	name = "raw-carbon-fibers",
	recipe_name = "raw-carbon-fibers-epoxy",
	category = "hv-autoclave-recipes",
	energy_required = 7.4,
	ingredients = {
		{ type = "item", name = "carbon", amount = 4 },
		{ type = "fluid", name = "epoxy", amount = 0.9 }
		},
	results = {
		{ type = "item", name = "raw-carbon-fibers", amount = 4 }
	}
}
create_recipe{
	recipe_name = "raw-carbon-fibers-pbi",
	category = "ev-autoclave-recipes",
	energy_required = 14.8,
	ingredients = {
		{ type = "item", name = "carbon", amount = 4 },
		{ type = "fluid", name = "polybenzimidazole", amount = 0.9 }
	},
	results = {
		{ type = "item", name = "raw-carbon-fibers", amount = 16 }
	}
}
   
   
   
---NANOPROCESSOR   
create_recipe{
	recipe_name = "nanoprocessor",
	category = "ev-circuit-assembler-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "epoxy-printed-circuit-board", amount = 1 },
		{ type = "item", name = "nano-cpu-chip", amount = 1 },
		{ type = "item", name = "smd-resistor", amount = 8 },
		{ type = "item", name = "smd-capacitor", amount = 8 },
		{ type = "item", name = "smd-transistor", amount = 8 },
		{ type = "item", name = "fine-electrum-wire", amount = 8 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "processing-unit", amount = 2 }
	}
}



---NANOPROCESSOR ASSEMBLY 
create_recipe{
	recipe_name = "nanoprocessor-assembly",
	category = "ev-circuit-assembler-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "epoxy-printed-circuit-board", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "smd-inductor", amount = 4 },
		{ type = "item", name = "smd-capacitor", amount = 8 },
		{ type = "item", name = "ram-chip", amount = 8 },
		{ type = "item", name = "fine-electrum-wire", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "ev-circuit", amount = 2 }
	}
}



---NANOPROCESSOR SUPERCOMPUTER 
create_recipe{
	recipe_name = "nanoprocessor-supercomputer",
	category = "ev-circuit-assembler-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "epoxy-printed-circuit-board", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "smd-diode", amount = 8 },
		{ type = "item", name = "nor-memory-chip", amount = 4 },
		{ type = "item", name = "ram-chip", amount = 16 },
		{ type = "item", name = "fine-electrum-wire", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "iv-circuit", amount = 1 }
	}
}


   
---POLYDIMETHYLSILOXANE (PDMS)
create_item{
	name = "polydimethylsiloxane",
	category = "mv-chemical-reactor-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "raw-silicon", amount = 1 },
		{ type = "fluid", name = "water", amount = 100 },
		{ type = "fluid", name = "chlorine", amount = 400 },
		{ type = "fluid", name = "methane", amount = 200 },
	},
	results = {
		{ type = "item", name = "polydimethylsiloxane", amount = 3 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
		{ type = "fluid", name = "diluted-hydrochloric-acid", amount = 200 },
	},
	main_product = "polydimethylsiloxane"
}
create_recipe{
	recipe_name = "silicone-rubber",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "polydimethylsiloxane", amount = 9 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "silicone-rubber", amount = 129.6 }
	}
}
create_item{
	name = "silicone-rubber-ring",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "silicone-rubber", amount = 3.6 },
	}
}
create_item{
	name = "silicone-rubber-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 1.6,
	ingredients = {
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	}
} 
   
   
   
---REINFORCED GLASS 
create_item{
	name = "reinforced-glass",
	category = "multismelter-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "glass-dust", amount = 30 },
		{ type = "item", name = "advanced-alloy", amount = 10 },
	},
	results = {
		{ type = "item", name = "reinforced-glass", amount = 40 },
	}
}

    
	
---TITANIUM DUST
create_item{
	name = "titanium-dust",
	category = "lv-macerator-recipes",
	energy_required = TITANIUM_SPEED,
	ingredients = {
		{ type = "item", name = "titanium-ingot", amount = 1 }
	}
}
   
   
   
---PD MCSB 
create_item{
	name = "phosphorus-doped-monocrystaline-silicon-boule",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 2400,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 64 },
		{ type = "item", name = "phosphorus", amount = 8 },
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 2 },
		{ type = "fluid", name = "nitrogen", amount = 800 }
	},
}
  


---NOR MEMORY WAFER   
create_item{
	name = "nor-memory-wafer",
	recipe_name = "nor-memory-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 45 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 }
	}
}
create_recipe{
	recipe_name = "nor-memory-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nor-memory-wafer", amount = 4 }
	}
}
create_recipe{
	recipe_name = "nor-memory-wafer-nd",
	category = "iv-laser-engraver-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-3-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nor-memory-wafer", amount = 8 }
	}
}
create_recipe{
	recipe_name = "nor-memory-wafer-nd",
	category = "iv-laser-engraver-recipes",
	energy_required = 30 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-5-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nor-memory-wafer", amount = 16 }
	}
}
   
   
   
---NOR MEMORY CHIP   
create_item{
	name = "nor-memory-chip",
	category = "hv-cutting-machine-recipes",
	energy_required = 180,
	ingredients = {
		{ type = "item", name = "nor-memory-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 14 },
	},
	results = {
		{ type = "item", name = "nor-memory-chip", amount = 16 }
	}
} 
   
   
   
---NANOPROCESSOR MAINFRAME 
create_item{ skip_recipe = true,
	name = "luv-circuit",
	subgroup = "subgroup-ev-circuit-assembler-recipes",
} 
create_recipe{
	recipe_name = "nanoprocessor-mainframe",
	category = "ev-circuit-assembler-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "aluminium-frame", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "smd-inductor", amount = 16 },
		{ type = "item", name = "smd-capacitor", amount = 32 },
		{ type = "item", name = "ram-chip", amount = 16 },
		{ type = "item", name = "annealed-copper-wire", amount = 32 },
		{ type = "fluid", name = "soldering-alloy", amount = 28.8 }
	},
	results = {
		{ type = "item", name = "luv-circuit", amount = 1 }
	}
} 



---ZIRCONIUM CARBIDE DUST
create_item{ skip_recipe = true,
	name = "zirconium-dust",
	subgroup = "subgroup-lv-electrolyzer-recipes",
} 
create_item{
	name = "zirconium-carbide-dust",
	category = "lv-mixer-recipes",
	energy_required = 5.1,
	ingredients = {
		{type = "item", name = "zirconium-dust", amount = 1},
		{type = "item", name = "carbon", amount = 1},
    },
	results = {
		{type = "item", name = "zirconium-carbide-dust", amount = 2}
    }
}
  
  
  
---ZIRCONIUM CARBIDE INGOT
create_item{
	name = "zirconium-carbide-ingot",
	recipe_name = "zirconium-carbide-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "zirconium-carbide-dust", amount = 1}
    },
	results = {
		{type = "item", name = "zirconium-carbide-ingot", amount = 1}
    }
}
create_recipe{
	recipe_name = "zirconium-carbide-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "zirconium-carbide-dust", amount = 64}
    },
	results = {
		{type = "item", name = "zirconium-carbide-ingot", amount = 64}
    }
}

  
   
---ALLOY BLAST SMELTER
create_item{
	name = "alloy-blast-smelter-controller",
	ingredients = {
		{ type = "item", name = "zirconium-carbide-plate", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "ev-alloy-smelter", amount = 1 },
		{ type = "item", name = "platinum-cable", amount = 8 },
	},
}
create_item{
	name = "ev-alloy-blast-smelter",
	subgroup = "subgroup-ev-age-multiblocks",
	stack_size = 10,
	icon = ICON_PATH .. "alloy-blast-smelter.png",
--	place_result = "ev-alloy-blast-smelter"
	ingredients = {
		{ type = "item", name = "alloy-blast-smelter-controller", amount = 1 },
		{ type = "item", name = "ev-energy-hatch", amount = 1 },
		{ type = "item", name = "ev-machine-hull", amount = 5 },
		{ type = "item", name = "nichrome-coil-block", amount = 24 },
		{ type = "item", name = "heat-vent-block", amount = 12 },
		{ type = "item", name = "high-temperature-smelting-casing", amount = 34 },
	}
} 



---HEAT VENT BLOCK
create_item{
	name = "heat-vent-block",
	ingredients = {
		{ type = "item", name = "staballoy-plate", amount = 6 },
		{ type = "item", name = "titanium-gear-box-casing", amount = 1 },
		{ type = "item", name = "staballoy-frame", amount = 2 },
	}
}



---TITANIUM GEAR BOX CASING
create_item{
	name = "titanium-gear-box-casing",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "large-titanium-gear", amount = 2 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	}
}



---HIGH TEMPERATURE SMELTING CASING
create_item{
	name = "high-temperature-smelting-casing",
	ingredients = {
		{ type = "item", name = "zirconium-carbide-frame", amount = 1 },
		{ type = "item", name = "zirconium-carbide-plate", amount = 6 },
	}
}



---SOC WAFER
create_item{
	name = "soc-wafer",
	recipe_name = "soc-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 45 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "soc-wafer", amount = 1 }
	}
}
create_recipe{
	recipe_name = "soc-wafer-ed",
	category = "iv-laser-engraver-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "europium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-3-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "soc-wafer", amount = 4 }
	}
}
create_recipe{
	recipe_name = "soc-wafer-ad",
	category = "luv-laser-engraver-recipes",
	energy_required = 15 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "americium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-5-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "soc-wafer", amount = 8 }
	}
}
   
   
   
---SYSTEM ON CHIP
create_item{
	name = "system-on-chip",
	category = "hv-cutting-machine-recipes",
	energy_required = 180,
	ingredients = {
		{ type = "item", name = "soc-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 },
	},
	results = {
		{ type = "item", name = "system-on-chip", amount = 6 }
	}
}



---CHEAPER LV CIRCUITS
create_recipe{
	recipe_name = "microchip-cheap",
	category = "ev-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "system-on-chip", amount = 1 },
		{ type = "item", name = "fine-copper-wire", amount = 2 },
		{ type = "item", name = "tin-bolt", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "electronic-circuit", amount = 6 }
	}
}



---CHEAPER MV CIRCUITS
create_recipe{
	recipe_name = "microprocessor-cheap",
	category = "iv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "system-on-chip", amount = 1 },
		{ type = "item", name = "annealed-copper-bolt", amount = 4 },
		{ type = "item", name = "fine-red-alloy-wire", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 4 }
	}
}
   


---MOLYBDENUM PRODUCTION
create_item{
	name = "molybdenum-trioxide",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "molybdenite-dust", amount = 3 },
		{ type = "fluid", name = "oxygen", amount = 700 },
	},
	results = {
		{ type = "item", name = "molybdenum-trioxide", amount = 4 },
		{ type = "fluid", name = "sulfur-dioxide", amount = 200 }
	},
	main_product = "molybdenum-trioxide"
}
create_item{
	name = "molybdenum-dust",
	category = "hv-chemical-reactor-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "molybdenum-trioxide", amount = 4 },
		{ type = "fluid", name = "hydrogen", amount = 600 },
	},
	results = {
		{ type = "item", name = "molybdenum-dust", amount = 1 },
		{ type = "fluid", name = "water", amount = 200 }
	},
	main_product = "molybdenum-dust"
}


   
---ILMENITE PROCESSING
create_item{
	name = "ilmenite-slag",
	recipe_name = "ilmenite-processing",
	category = "ev-chemical-bath-recipes",
	energy_required = 168,
	ingredients = {
		{ type = "item", name = "crushed-ilmenite", amount = 1 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
		},
	results = {
		{ type = "item", name = "rutile-dust", amount = 2 },
		{ type = "item", name = "ilmenite-slag", amount = 1, probability = 0.6 },
		{ type = "fluid", name = "sulfuric-iron-solution", amount = 200 }
	},
	main_product = "rutile-dust"
}
create_recipe{
	recipe_name = "ilmenite-slag-processing",
	category = "mv-centrifuge-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "ilmenite-slag", amount = 1 },
	},
	results = {
		{ type = "item", name = "iron-dust", amount = 1, probability = 0.6 },
		{ type = "item", name = "magnesium", amount = 1, probability = 0.6 },
		{ type = "item", name = "manganese-dust", amount = 1, probability = 0.5 },
		{ type = "item", name = "tantalum-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "niobium-dust", amount = 1, probability = 0.05 },
	},
	main_product = "tantalum-dust"
}
create_recipe{
	recipe_name = "sulfuric-iron-solution-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "fluid", name = "sulfuric-iron-solution", amount = 100 }
	},
	results = {
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 }
	},
	main_product = "iron-dust"
}
   
   
   
---SODIUM FORMATE
create_recipe{
	recipe_name = "sodium-formate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 0.75,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "carbon-monoxide", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "sodium-formate", amount = 100 },
	}
}


   
---FORMIC ACID
create_recipe{
	recipe_name = "formic-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 0.75,
	ingredients = {
		{ type = "fluid", name = "sodium-formate", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "formic-acid", amount = 100 },
		{ type = "item", name = "sodium-sulfate", amount = 7 }
	},
	main_product = "formic-acid"
}

   
   
---CRUSHED RARE EARTH 1
create_item{
	name = "crushed-rare-earth-1",
	category = "lv-chemical-bath-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "rare-earth", amount = 3 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	results = {
		{ type = "item", name = "crushed-rare-earth-1", amount = 9 },
	}
}



---RARE EARTH 1
create_item{
	name = "rare-earth-1-dust",
	category = "lv-centrifuge-recipes",
	energy_required = 11.6,
	ingredients = {
		{ type = "item", name = "crushed-rare-earth-1", amount = 1 },
	},
	results = {
		{ type = "item", name = "rare-earth-1-dust", amount = 1 },
		{ type = "item", name = "yttrium-dust", amount = 1, probability = 0.11 },
	}
}



---RARE EARTH 1 PROCESSING
create_item{
	name = "yttrium-dust",
	recipe_name = "rare-earth-1-processing",
	category = "lv-centrifuge-recipes",
	energy_required = 5.8,
	ingredients = {
		{ type = "item", name = "rare-earth-1-dust", amount = 9 },
	},
	results = {
		{ type = "item", name = "greenockite-dust", amount = 1 },
		{ type = "item", name = "lanthanite-dust", amount = 1 },
		{ type = "item", name = "agardite-dust", amount = 1 },
		{ type = "item", name = "yttrialite-dust", amount = 1 },
		{ type = "item", name = "nether-quartz-dust", amount = 1 },
		{ type = "item", name = "galena-dust", amount = 1 },
		{ type = "item", name = "chalcopyrite-dust", amount = 1 },
		{ type = "item", name = "cryolite", amount = 1 },
		{ type = "item", name = "yttrium-dust", amount = 1 },
	}
}



---GREENHOCKITE ELECTROLYSIS
create_item{
	name = "greenockite-dust",
	recipe_name = "greenockite-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 10.8,
	ingredients = {
		{ type = "item", name = "greenockite-dust", amount = 2 },
	},
	results = {
		{ type = "item", name = "cadmium", amount = 1 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	main_product = "cadmium",
}



---LANTHANITE ELECTROLYSIS
create_item{
	name = "lanthanite-dust",
	recipe_name = "lanthanite-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 6.3,
	ingredients = {
		{ type = "item", name = "lanthanite-dust", amount = 11 },
	},
	results = {
		{ type = "item", name = "cerium-rich-mixture", amount = 2 },
		{ type = "item", name = "calcium", amount = 3 },
		{ type = "fluid", name = "oxygen", amount = 400 },
		{ type = "fluid", name = "hydrogen", amount = 200 },
	},
	main_product = "cerium-rich-mixture",
}



---AGARDITE ELECTROLYSIS
create_item{
	name = "agardite-dust",
	recipe_name = "agardite-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 10.8,
	ingredients = {
		{ type = "item", name = "agardite-dust", amount = 45 },
	},
	results = {
		{ type = "item", name = "cadmium", amount = 1 },
		{ type = "item", name = "calcium", amount = 1 },
		{ type = "item", name = "copper-dust", amount = 7 },
		{ type = "item", name = "arsenic", amount = 4 },
		{ type = "fluid", name = "oxygen", amount = 2100 },
		{ type = "fluid", name = "hydrogen", amount = 1100 },
	},
	main_product = "cadmium",
}



---YTTRIALITE ELECTROLYSIS
create_item{
	name = "yttrialite-dust",
	recipe_name = "yttrialite-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 13.5,
	ingredients = {
		{ type = "item", name = "yttrialite-dust", amount = 13 },
	},
	results = {
		{ type = "item", name = "yttrium-dust", amount = 2 },
		{ type = "item", name = "thorium-dust", amount = 2 },
		{ type = "item", name = "raw-silicon", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 700 },
	},
	main_product = "yttrium-dust",
}



---CHALCOPYRITE ELECTROLYSIS
create_item{
	name = "chalcopyrite-dust",
	recipe_name = "chalcopyrite-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 16.8,
	ingredients = {
		{ type = "item", name = "chalcopyrite-dust", amount = 4 },
	},
	results = {
		{ type = "item", name = "copper-dust", amount = 1 },
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "item", name = "sulfur", amount = 2 },
	},
	main_product = "copper-dust",
}

   
   
---ENDSTONE DUST
create_item{
	name = "endstone-dust",
	category = "hv-macerator-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "compressed-end-stone", amount = 1 },
	},
	results = {
		{ type = "item", name = "endstone-dust", amount = 9 },
	}
}
create_recipe{
	recipe_name = "endstone-dust-centrifuging",
	category = "lv-centrifuge-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "item", name = "endstone-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "sand", amount = 1, probability = 0.9 },
		{ type = "item", name = "tungstate-dust", amount = 1, probability = 0.032 },
		{ type = "item", name = "platinum-dust", amount = 1, probability = 0.007 },
		{ type = "fluid", name = "helium", amount = 12 },
	},
	main_product = "helium"
}   



---STABLE TITANIUM MACHINE CASING
create_item{
	name = "stable-titanium-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 6 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	}
}



---TITANIUM PIPE CASING
create_item{
	name = "titanium-pipe-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 16 },
		{ type = "item", name = "titanium-frame", amount = 1 },
	}
}  


   
---LARGE HEAT EXCHANGER
create_item{
	name = "large-heat-exchanger-controller",
	ingredients = {
		{ type = "item", name = "ev-pump", amount = 4 },
		{ type = "item", name = "titanium-plate", amount = 12 },
		{ type = "item", name = "titanium-pipe-casing", amount = 1 },
	}
}
create_item{
	name = "large-heat-exchanger",
	stack_size = 10,
--	place_result = "large-heat-exchanger",
	ingredients = {
			{ type = "item", name = "large-heat-exchanger-controller", amount = 1 },
			{ type = "item", name = "titanium-pipe-casing", amount = 2 },
			{ type = "item", name = "lv-machine-hull", amount = 7 },
			{ type = "item", name = "stable-titanium-machine-casing", amount = 26 },
		},
	results = {
			{ type = "item", name = "large-heat-exchanger", amount = 1 },
		}
}
   
  
   
---BOROSILICATE GLASS DUST
create_item{
	name = "borosilicate-glass-dust",
	category = "lv-mixer-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "glass-dust", amount = 7 },
		{ type = "item", name = "boron", amount = 1 },
	},
	results = {
		{ type = "item", name = "borosilicate-glass-dust", amount = 8 }
	}
}  



---MOLTEN BOROSILICATE GLASS
create_recipe{
	recipe_name = "molten-borosilicate-glass",
	category = "lv-extractor-recipes",
	energy_required = 1.2,
	ingredients = {
		{ type = "item", name = "borosilicate-glass-dust", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-borosilicate-glass", amount = 14.4 }
	}
}	 
	 
	 
	 
---BOROSILICATE GLASS	 
create_item{
	name = "borosilicate-glass-block",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 14.4,
	ingredients = {
		{ type = "fluid", name = "molten-borosilicate-glass", amount = 129.6 },
	}
}  
   
   
   
---LAPIS ROD
create_item{
	name = "lapis-rod",
	category = "lv-lathe-recipes",
	energy_required = 7,
	ingredients = {
		{ type = "item", name = "lapis-lazuli", amount = 1 },
	},
	results = {
		{ type = "item", name = "lapis-rod", amount = 2 },
	}
}


---LAPIS PLATE
create_item{
	name = "lapis-plate",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "lapis-dust", amount = 1 },
	}
}


  
---LAPIS BOLT
create_item{
	name = "lapis-bolt",
	category = "lv-cutting-machine-recipes",
	energy_required = 2.8 * 16,
	ingredients = {
		{ type = "item", name = "lapis-rod", amount = 16 },
		{ type = "fluid", name = "lubricant", amount = 1.6 },
	},
	results = {
		{ type = "item", name = "lapis-bolt", amount = 64 }
	}
}


   
---LAPIS SCREW
create_item{
	name = "lapis-screw",
	category = "lv-lathe-recipes",
	energy_required = 9.6,
	ingredients = {
		{ type = "item", name = "lapis-bolt", amount = 64 },
	},
	results = {
		{ type = "item", name = "lapis-screw", amount = 64 }
	}
}
   
   
   
---DIAMOND ROD
create_item{
	name = "diamond-rod",
	category = "lv-lathe-recipes",
	energy_required = 192,
	ingredients = {
		{ type = "item", name = "diamond", amount = 1 },
	},
	results = {
		{ type = "item", name = "diamond-rod", amount = 2 },
	}
}


   
---DIAMOND BOLT
create_item{
	name = "diamond-bolt",
	category = "lv-cutting-machine-recipes",
	energy_required = 76.8,
	ingredients = {
		{ type = "item", name = "diamond-rod", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 0.4 },
	},
	results = {
		{ type = "item", name = "diamond-bolt", amount = 4 }
	}
}


   
---DIAMOND SCREW
create_item{
	name = "diamond-screw",
	category = "lv-lathe-recipes",
	energy_required = 4.8,
	ingredients = {
		{ type = "item", name = "diamond-bolt", amount = 1 },
	},
	results = {
		{ type = "item", name = "diamond-screw", amount = 1 }
	}
}
   
   
   
---DIAMOND SPIKE
create_item{
	name = "diamond-spike",
	ingredients = {
		{ type = "item", name = "diamond-screw", amount = 3 },
		{ type = "item", name = "diamond-plate", amount = 3 },
		{ type = "item", name = "block-of-diamond", amount = 1 },
	},
}
   
   
   
---EXTREME ENTITY CRUSHER
create_item{
	name = "extreme-entity-crusher-controller",
	ingredients = {
		{ type = "item", name = "ev-robot-arm", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "item", name = "ev-machine-hull", amount = 1 },
	}
}   
create_item{
	name = "ev-extreme-entity-crusher",
	stack_size = 10,
	icon = ICON_PATH .. "extreme-entity-crusher.png",
--	place_result = "ev-extreme-entity-crusher",
	ingredients = {
		{ type = "item", name = "extreme-entity-crusher-controller", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 4 },
		{ type = "item", name = "ev-energy-hatch", amount = 1 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 44 },
		{ type = "item", name = "steel-frame", amount = 20 },
		{ type = "item", name = "borosilicate-glass-block", amount = 60 },
		{ type = "item", name = "diamond-spike", amount = 9 },
		{ type = "item", name = "powered-spawner", amount = 1 },
	}
}



---POWERED SPAWNER
create_item{
	name = "powered-spawner",
	stack_size = 10,
--	place_result = "powered-spawner",
	ingredients = {
		{ type = "item", name = "zombie-head", amount = 1 },
		{ type = "item", name = "dark-steel-plate", amount = 2 },
		{ type = "item", name = "soularium-plate", amount = 2 },
		{ type = "item", name = "machine-chassis", amount = 1 },
		{ type = "item", name = "frank-n-zombie", amount = 1 },
		{ type = "item", name = "ender-crystal", amount = 2 },
		{ type = "item", name = "octadic-capacitor", amount = 1 },
	}
}

   
   
---DARK STEEL INGOT
create_item{
	name = "obsidian",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 51.2,
	ingredients = {
      {type = "fluid", name = "lava", amount = 100},
    }
}
create_item{
	name = "dark-steel-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 30,
	ingredients = {
		{type = "item", name = "steel-ingot", amount = 1},
		{type = "item", name = "obsidian", amount = 1},
		{type = "item", name = "carbon", amount = 1},
    },
	results = {
		{type = "item", name = "dark-steel-ingot", amount = 1}
    }
}
   
   
   
---ELECTRICAL STEEL INGOT
create_item{
	name = "electrical-steel-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "steel-ingot", amount = 1},
		{type = "item", name = "raw-silicon", amount = 1},
		{type = "item", name = "carbon", amount = 1},
    }
}



   
   
   
---END STEEL INGOT
create_item{
	name = "end-steel-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 40,
	ingredients = {
		{type = "item", name = "dark-steel-ingot", amount = 1},
		{type = "item", name = "electrical-steel-ingot", amount = 1},
		{type = "item", name = "endstone-dust", amount = 1},
    }
}



---SOULARIUM INGOT
create_item{
	name = "soularium-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "gold-ingot", amount = 1},
		{type = "item", name = "soul-sand", amount = 1},
    }
}   



---MACHINE CHASSIS
create_item{
	name = "machine-chassis",
	category = "mv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "electrical-steel-plate", amount = 4 },
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "enderio-capacitor", amount = 1 },
	}
}
    
   
   
---ENDERIO CAPACITOR
create_item{
	name = "enderio-capacitor",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "aluminium-bolt", amount = 4 },
		{ type = "item", name = "silver-foil", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 },
	}
}
    
   
   
---DOUBLE LAYER CAPACITOR
create_item{
	name = "double-layer-capacitor",
	category = "mv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "enderio-capacitor", amount = 2 },
		{ type = "item", name = "energetic-alloy-wire", amount = 4 },
		{ type = "item", name = "coal-dust", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 },
	}
}
    
   
   
---OCTADIC CAPACITOR
create_item{
	name = "octadic-capacitor",
	category = "mv-assembling-machine-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "double-layer-capacitor", amount = 2 },
		{ type = "item", name = "vibrant-alloy-wire", amount = 4 },
		{ type = "item", name = "glowstone-dust", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 },
	}
}
   
   
   
---FRANK N ZOMBIE
create_item{
	name = "frank-n-zombie",
	category = "soul-binder-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "z-logic-controller", amount = 1 },
		{ type = "item", name = "filled-soul-vial-zombie", amount = 1 },
--		{ type = "fluid", name = "liquid-xp", amount = 1000 },
	},
	results = {
		{ type = "item", name = "frank-n-zombie", amount = 1 },
		{ type = "item", name = "soul-vial", amount = 1 },
	},
	main_product = "frank-n-zombie"
}  
     
   
   
---ENDER CRYSTAL
create_item{
	name = "ender-crystal",
	category = "soul-binder-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "vibrant-crystal", amount = 1 },
		{ type = "item", name = "filled-soul-vial-enderman", amount = 1 },
--		{ type = "fluid", name = "liquid-xp", amount = 1000 },
	},
	results = {
		{ type = "item", name = "ender-crystal", amount = 1 },
		{ type = "item", name = "soul-vial", amount = 1 },
	},
	main_product = "ender-crystal"
}
      
   
   
---VIBRANT CRYSTAL
create_recipe{
	recipe_name = "molten-vibrant-alloy",
	category = "mv-extractor-recipes",
	energy_required = MV_SPEED * 4.25,
	ingredients = {
		{ type = "item", name = "vibrant-alloy-ingot", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-vibrant-alloy", amount = 14.4 },
	}
}
create_item{
	name = "vibrant-crystal",
	category = "hv-autoclave-recipes",
	energy_required = HV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "emerald", amount = 1 },
		{ type = "fluid", name = "molten-vibrant-alloy", amount = 14.4 },
	}
}
   
   
   
---ZOMBIE SOUL VIAL
create_item{
	name = "filled-soul-vial-zombie",
	category = "powered-spawner-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "soul-vial", amount = 1 },
	}
}
create_recipe{
	recipe_name = "zombie-soul-vial-manual",
	category = "manual-only-recipes",
	energy_required = 1,
	subgroup = "subgroup-powered-spawner-recipes",
	ingredients = {
		{ type = "item", name = "soul-vial", amount = 1 },
		{ type = "item", name = "manual-labor", amount = 10 },
	},
	results = {
		{ type = "item", name = "filled-soul-vial-zombie", amount = 1 }
	}
}
       
   
   
 ---ENDERMAN SOUL VIAL
create_item{
	name = "filled-soul-vial-enderman",
	category = "powered-spawner-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "soul-vial", amount = 1 },
	}
}
create_recipe{
	recipe_name = "enderman-soul-vial-manual",
	category = "manual-only-recipes",
	subgroup = "subgroup-powered-spawner-recipes",
	ingredients = {
		{ type = "item", name = "soul-vial", amount = 1 },
		{ type = "item", name = "manual-labor", amount = 20 },
	},
	results = {
		{ type = "item", name = "filled-soul-vial-enderman", amount = 1 }
	}
}
   
   
   
---FUSED QUARTZ
create_item{
	name = "fused-quartz",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "nether-quartz-dust", amount = 2 },
		{ type = "item", name = "glass-dust", amount = 1 },
	}
}
 
 
   
---SOUL VIAL
create_item{
	name = "soul-vial",
	category = "mv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "fused-quartz", amount = 3 },
		{ type = "item", name = "soularium-round", amount = 1 },
	},
}  
    
   
   
 ---Z LOGIC CONTROLLER
create_item{
	name = "z-logic-controller",
	category = "slice-n-splice-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "zombie-head", amount = 1 },
		{ type = "item", name = "soularium-plate", amount = 2 },
		{ type = "item", name = "silicon-plate", amount = 2 },
		{ type = "item", name = "red-alloy-plate", amount = 1 },
	}
}
    
   
   
 ---SLICE N SPLICE
create_item{
	name = "slice-n-splice",
	stack_size = 10,
--	place_result = "slice-n-splice",
	ingredients = {
		{ type = "item", name = "soularium-plate", amount = 4 },
		{ type = "item", name = "advanced-circuit", amount = 2 },
		{ type = "item", name = "machine-chassis", amount = 1 },
		{ type = "item", name = "mv-motor", amount = 2 },
		{ type = "item", name = "octadic-capacitor", amount = 1 },
	}
}
    
   
   
 ---SOUL BINDER
create_item{
	name = "soul-binder",
	stack_size = 10,
--	place_result = "soul-binder",
	ingredients = {
		{ type = "item", name = "zombie-head", amount = 1 },
		{ type = "item", name = "soularium-plate", amount = 2 },
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "machine-chassis", amount = 1 },
		{ type = "item", name = "hv-motor", amount = 2 },
		{ type = "item", name = "z-logic-controller", amount = 1 },
		{ type = "item", name = "octadic-capacitor", amount = 1 },
	},
}

 
   
 ---CRUSHING ZOMBIES
create_recipe{
	recipe_name = "crushing-zombies",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 4,
	ingredients = { },
	results = {
		{ type = "item", name = "zombie-head", amount = 1 }
	}
}  



---CRUSHING BLAZES
create_recipe{
	recipe_name = "crushing-blazes",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 8,
	ingredients = { },
	results = {
		{ type = "item", name = "blaze-rod", amount = 1 }
	}
} 
   


---CRUSHING WITHER SKELETONS
create_recipe{
	recipe_name = "crushing-wither-skeletons",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 10,
	ingredients = { },
	results = {
		{ type = "item", name = "wither-skull", amount = 1 }
	}
} 



---CRUSHING THE WITHER
create_item{
	name = "nether-star",
	recipe_name = "crushing-the-wither",
	category = "ev-extreme-entity-crusher-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "wither-skull", amount = 3 },		
		{ type = "item", name = "soul-sand", amount = 4 },		
	},
	results = {
		{ type = "item", name = "nether-star", amount = 1 }
	}
}




---EMPTY FUEL ROD
create_item{
	name = "empty-fuel-rod",
	category = "mv-extruder-recipes",
	energy_required = 6.4,
	ingredients = {
		{ type = "item", name = "iron-ingot", amount = 1 },
	}
}


   
---URANIUM HEXAFLUORIDE
create_recipe{
	recipe_name = "uranium-hexafluoride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "uraninite-dust", amount = 3 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 400 },
		{ type = "fluid", name = "fluorine", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "uranium-hexafluoride", amount = 100 },
		{ type = "fluid", name = "water", amount = 200 },
	},
	main_product = "uranium-hexafluoride"
}

   
   
   
 ---URANIUM ENRICHMENT
create_recipe{
	recipe_name = "uranium-enrichment",
		category = "lv-centrifuge-recipes",
		energy_required = 100,
		ingredients = {
			{ type = "fluid", name = "uranium-hexafluoride", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "enriched-uranium-hexafluoride", amount = 10 },
			{ type = "fluid", name = "depleted-uranium-hexafluoride", amount = 90 },
		},
		main_product = "enriched-uranium-hexafluoride"
}
create_item{
	name = "uranium-235-dust",
	recipe_name = "enriched-uranium-hexafluoride-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "enriched-uranium-hexafluoride", amount = 100 },
	},
	results = {
		{ type = "item", name = "uranium-235-dust", amount = 1 },
		{ type = "fluid", name = "fluorine", amount = 600 },
	},
	main_product = "uranium-235-dust"
}
create_item{
	recipe_name = "depleted-uranium-hexafluoride-electrolysis",
	name = "uranium-238-dust",
	category = "lv-electrolyzer-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "depleted-uranium-hexafluoride", amount = 100 },
	},
	results = {
		{ type = "item", name = "uranium-238-dust", amount = 1 },
		{ type = "fluid", name = "fluorine", amount = 600 },
	},
	main_product = "uranium-238-dust"
}   



---URANIUM FUEL ROD
create_item{
	name = "uranium-fuel-rod",
	category = "lv-canning-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "empty-fuel-rod", amount = 1 },
		{ type = "item", name = "uranium-238-dust", amount = 7 },
		{ type = "item", name = "uranium-235-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "uranium-fuel-rod", amount = 1 },
	},
	fuel_category = "nuclear-fuel-rod",
	fuel_value = "6000MJ",
	burnt_result = "depleted-uranium-fuel-rod",
}
create_item{skip_recipe = true,
	name = "depleted-uranium-fuel-rod",
	subgroup = "subgroup-lv-canning-machine-recipes",
}  
create_item{
	recipe_name = "depleted-uranium-fuel-rod-centrifuging",
	name = "plutonium-239-dust",
	category = "mv-canning-machine-recipes",
	energy_required = 25 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "depleted-uranium-fuel-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "uranium-238-dust", amount = 4 },
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "item", name = "plutonium-239-dust", amount = 1, probability = 0.11 },
	},
} 


 
---THORIUM FUEL ROD
create_item{
	name = "thorium-fuel-rod",
	category = "lv-canning-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "empty-fuel-rod", amount = 1 },
		{ type = "item", name = "thorium-dust", amount = 3 },
	},
	fuel_category = "nuclear-fuel-rod",
	fuel_value = "5000MJ",
	burnt_result = "depleted-thorium-fuel-rod",
}
create_item{skip_recipe = true,
	name = "depleted-thorium-fuel-rod",
	subgroup = "subgroup-lv-canning-machine-recipes",
}
create_item{
	recipe_name = "depleted-thorium-fuel-rod-centrifuging",
	name = "lutetium-dust",
	category = "mv-canning-machine-recipes",
	energy_required = 25 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "depleted-thorium-fuel-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "thorium-dust", amount = 1 },
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "item", name = "lutetium-dust", amount = 1, probability = 0.5 },
	},
} 
   
   
   
   
   
   
   
   
--- ADVANCED ALLOY
create_item{
	name = "mixed-metal-ingot",
	ingredients = {
		{ type = "item", name = "iron-plate", amount = 1 },
		{ type = "item", name = "bronze-plate", amount = 1 },
		{ type = "item", name = "tin-plate", amount = 1 },
    }
} 
create_item{
	name = "advanced-alloy",
	category = "lv-compressor-recipes",
	energy_required = 15,	
	ingredients = {
		{ type = "item", name = "mixed-metal-ingot", amount = 1 },
    }
}



--- HEAT VENTS
create_item{
	name = "heat-vent",
	ingredients = {
		{ type = "item", name = "lv-motor", amount = 1 },
		{ type = "item", name = "iron-stick", amount = 4 },
		{ type = "item", name = "aluminium-plate", amount = 4 },
    }
}
create_item{
	name = "component-heat-vent",
	ingredients = {
		{ type = "item", name = "dense-tin-plate", amount = 4 },
		{ type = "item", name = "steel-rod", amount = 4 },
		{ type = "item", name = "heat-vent", amount = 1 },
    }
}
create_item{
	name = "advanced-heat-vent",
	ingredients = {
		{ type = "item", name = "diamond", amount = 1 },
		{ type = "item", name = "stainless-steel-rod", amount = 6 },
		{ type = "item", name = "heat-vent", amount = 2 },
    }
}
create_item{
	name = "overclocked-heat-vent",
	ingredients = {
		{ type = "item", name = "gold-plate", amount = 4 },
		{ type = "item", name = "stainless-steel-screw", amount = 4 },
		{ type = "item", name = "advanced-heat-vent", amount = 1 },
    }
}
   
   
   
---COMPONENT HEAT EXCHANGER
create_item{
	name = "heat-exchanger",
	ingredients = {
		{ type = "item", name = "silver-plate", amount = 4 },
		{ type = "item", name = "aluminium-plate", amount = 3 },
		{ type = "item", name = "copper-plate", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 1 },
    }
}
create_item{
	name = "component-heat-exchanger",
	ingredients = {
		{ type = "item", name = "stainless-steel-screw", amount = 4 },
		{ type = "item", name = "gold-plate", amount = 4 },
		{ type = "item", name = "heat-exchanger", amount = 1 },
    }
}



---NUCLEAR REACTOR
create_item{
	name = "advanced-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 1.25,
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "silicon-plate", amount = 2 },
		{ type = "item", name = "advanced-alloy", amount = 2 },
		{ type = "item", name = "lv-machine-casing", amount = 1 },
    }
}
create_item{
	name = "reactor-chamber",
	category = "hv-assembling-machine-recipes",
	energy_required = 60 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "dense-lead-plate", amount = 4 },
		{ type = "item", name = "dense-titanium-plate", amount = 2 },
		{ type = "item", name = "advanced-alloy", amount = 2 },
		{ type = "item", name = "advanced-machine-casing", amount = 1 },
    }
}
create_item{
	name = "nuclear-reactor-primary-chamber",
	category = "ev-assembling-machine-recipes",
	energy_required = 60 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "dense-lead-plate", amount = 2 },
		{ type = "item", name = "dense-titanium-plate", amount = 2 },
		{ type = "item", name = "reactor-chamber", amount = 3 },
		{ type = "item", name = "platinum-cable", amount = 8 },
    }
}
create_item{
	name = "basic-nuclear-reactor",
	ingredients = {
		{ type = "item", name = "nuclear-reactor-primary-chamber", amount = 1 },
		{ type = "item", name = "reactor-chamber", amount = 6 },
		{ type = "item", name = "overclocked-heat-vent", amount = 12 },
		{ type = "item", name = "component-heat-vent", amount = 8 },
		{ type = "item", name = "component-heat-exchanger", amount = 4 },
    },
	stack_size = 10,
	place_result = "basic-nuclear-reactor"
}


   
---REINFORCED STONE
create_item{
	name = "reinforced-stone",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "steel-frame", amount = 1 },
		{ type = "fluid", name = "liquid-concrete", amount = 14.4 },
	}
}


   
---FLUID NUCLEAR REACTOR
create_item{
	name = "reactor-pressure-vessel",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "reinforced-stone", amount = 1 },
		{ type = "item", name = "lead-plate", amount = 2 },
	}
}
create_item{
	name = "fluid-nuclear-reactor",
	subgroup = "energy",
	stack_size = 10,
--	place_result = "fluid-nuclear-reactor",
	ingredients = {
		{ type = "item", name = "reactor-pressure-vessel", amount = 98 },
		{ type = "item", name = "basic-nuclear-reactor", amount = 1 },
		{ type = "item", name = "iridium-neutron-reflector", amount = 4 },
		{ type = "item", name = "hv-pump", amount = 1 },
		{ type = "item", name = "hv-conveyor-module", amount = 1 },
	},
	results = {
		{ type = "item", name = "fluid-nuclear-reactor", amount = 1 },
	}
}   



---LAPOTRON CRYSTAL (EV BATTERY)
create_item{
	name = "lapotron-crystal",
	category = "ev-assembling-machine-recipes",
	energy_required = 16 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "raw-lapotron-crystal", amount = 1 },
		{ type = "item", name = "processing-unit", amount = 2 },
	}
}
create_item{
	name = "raw-lapotron-crystal",
	category = "hv-autoclave-recipes",
	energy_required = 60 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "lapotron-dust", amount = 30 },
		{ type = "fluid", name = "molten-vibrant-alloy", amount = 28.8 },
	}
}
create_item{
	name = "lapotron-dust",
	category = "hv-mixer-recipes",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "lapis-dust", amount = 2 },
		{ type = "item", name = "energium-dust", amount = 3 },
	}
}
create_item{
	name = "energium-dust",
	category = "mv-mixer-recipes",
	energy_required = 30 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "redstone-dust", amount = 5 },
		{ type = "item", name = "ruby-dust", amount = 4 },
	}
}


   
---LARGE STEAM TURBINE
create_item{
	name = "steel-turbine-casing",
	ingredients = {
		{ type = "item", name = "magnalium-plate", amount = 6 },
		{ type = "item", name = "blue-steel-frame", amount = 1 },
	}
}
create_item{
	name = "magnalium-turbine-blade",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 1,
	ingredients = {
		{ type = "item", name = "magnalium-plate", amount = 10 },
		{ type = "item", name = "magnalium-screw", amount = 2 },
	}
}
create_item{
	name = "magnalium-turbine-rotor",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "magnalium-turbine-blade", amount = 8 },
		{ type = "item", name = "long-magnalium-rod", amount = 1 },
	}
}
create_item{
	name = "large-steam-turbine-controller",
	ingredients = {
		{ type = "item", name = "processing-unit", amount = 2 },
		{ type = "item", name = "large-steel-gear", amount = 4 },
		{ type = "item", name = "hv-machine-hull", amount = 1 },
		{ type = "item", name = "steel-plate", amount = 12 },
	}
}
create_item{
	name = "large-steam-turbine",
	stack_size = 10,
--	place_result = "large-steam-turbine",
	subgroup = "subgroup-ev-age-multiblocks",
	ingredients = {
			{ type = "item", name = "large-steam-turbine-controller", amount = 1 },
			{ type = "item", name = "ev-dynamo-hatch", amount = 1 },
			{ type = "item", name = "lv-machine-hull", amount = 5 },
			{ type = "item", name = "steel-turbine-casing", amount = 28 },
			{ type = "item", name = "magnalium-turbine-rotor", amount = 1 },
		},
	results = {
			{ type = "item", name = "large-steam-turbine", amount = 1 },
		}
}



---IV SCIENCE PACK   
create_recipe{
	recipe_name = "iv-science-pack",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 60,
	order = "f",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "cupronickel-coil-block", amount = 4 },
		{ type = "item", name = "heat-proof-casing", amount = 4 },
		{ type = "item", name = "frost-proof-casing", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "mv-field-generator", amount = 1 },
		{ type = "item", name = "battery", amount = 4 },
	},
	results = {
		{ type = "item", name = "utility-science-pack", amount = 10 }
	}
}