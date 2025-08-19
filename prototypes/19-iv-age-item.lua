--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---------------------
---    TUNGSTEN   ---
---------------------

---SODIUM TUNGSTATE
create_recipe{
	recipe_name = "sodium-tungstate",
	recipe_name = "tungstate-dust-autoclaving",
	category = "ev-autoclave-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "tungstate-dust", amount = 7 },
		{ type = "item", name = "sodium", amount = 2 },
		{ type = "fluid", name = "water", amount = 400 }
	},
	results = {
		{ type = "fluid", name = "sodium-tungstate", amount = 100 },
		{ type = "item", name = "lithium", amount = 2 }
	},
	main_product = "sodium-tungstate"
}
create_recipe{
	recipe_name = "scheelite-dust",
	category = "hv-chemical-reactor-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "calcium-chloride", amount = 3 },
		{ type = "fluid", name = "sodium-tungstate", amount = 100 },
	},
	results = {
		{ type = "item", name = "scheelite-dust", amount = 6 },
		{ type = "item", name = "salt", amount = 4 },
	},
	main_product = "scheelite-dust"
}	
	
	
	
---SCHEELITE PROCESSING
create_item{
	name = "tungstic-acid",
	category = "ev-chemical-reactor-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "scheelite-dust", amount = 6 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 200 }
	},
	results = {
		{ type = "item", name = "tungstic-acid", amount = 7 },
		{ type = "item", name = "calcium-chloride", amount = 3 }
	},
	main_product = "tungstic-acid"
}
	


---TUNGSTEN TRIOXIDE 
create_item{
	name = "tungsten-trioxide",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "tungstic-acid", amount = 7 }
	},
	results = {
		{ type = "item", name = "tungsten-trioxide", amount = 4 }
	}
}



---TUNGSTEN DUST
create_item{
	name = "tungsten-dust",
	category = "ev-chemical-reactor-recipes",
	energy_required = 84,
	ingredients = {
		{ type = "item", name = "tungsten-trioxide", amount = 4 },
		{ type = "fluid", name = "hydrogen", amount = 600 }
	},
	results = {
		{ type = "item", name = "tungsten-dust", amount = 1 },
		{ type = "fluid", name = "water", amount = 300 }
	},
	main_product = "tungsten-dust"
}	

---CALCIUM CHLORIDE ELECTROLYSIS
create_item{
	name = "calcium-chloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "calcium", amount = 1 },
		{ type = "fluid", name = "chlorine", amount = 200 }
	},
	results = {
		{ type = "item", name = "calcium-chloride", amount = 3 }
	}
}
create_recipe{
	recipe_name = "calcium-chloride-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 6,
	ingredients = {
		{ type = "item", name = "calcium-chloride", amount = 3 }
	},
	results = {
		{ type = "item", name = "calcium", amount = 1 },
		{ type = "fluid", name = "chlorine", amount = 200 }
	},
	main_product = "calcium"
}



---NITRATION MIXTURE
create_recipe{
	recipe_name = "nitration-mixture",
	category = "lv-mixer-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "nitric-acid", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 }
	},
	results = {
		{ type = "fluid", name = "nitration-mixture", amount = 100 }
	}
}



---SALTPETER
create_item{
	name = "saltpeter",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "nitric-acid", amount = 100 },
		{ type = "item", name = "potassium", amount = 1 },
	},
	results = {
		{ type = "item", name = "saltpeter", amount = 5 },
		{ type = "fluid", name = "hydrogen", amount = 100 },
	},
	main_product = "saltpeter"
}
	


---ADVANCED GLUE
create_recipe{
	recipe_name = "advanced-glue",
	category = "lv-mixer-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "acetone", amount = 300 },
		{ type = "fluid", name = "polyvinyl-acetate", amount = 200 }
	},
	results = {
		{ type = "fluid", name = "advanced-glue", amount = 500 }
	}
}
	
	

---GRAPHENE DUST
create_item{
	name = "graphene",
	recipe_name = "graphene-pd",
	category = "ev-chemical-reactor-recipes",
	energy_required = EV_SPEED * 160,
	ingredients = {
			{ type = "item", name = "graphite", amount = 64 },
			{ type = "item", name = "phosphorus-doped-wafer", amount = 32 },
			{ type = "fluid", name = "advanced-glue", amount = 50 }
		},
	results = {
			{ type = "item", name = "graphene", amount = 64 },
		}
}
create_recipe{
	recipe_name = "graphene-nd",
	category = "iv-chemical-reactor-recipes",
	energy_required = IV_SPEED * 40,
	ingredients = {
			{ type = "item", name = "graphite", amount = 64 },
			{ type = "item", name = "naquadah-doped-wafer", amount = 8 },
			{ type = "fluid", name = "advanced-glue", amount = 25 }
		},
	results = {
			{ type = "item", name = "graphene", amount = 64 },
		}
}
create_recipe{
	recipe_name = "graphene-ed",
	category = "luv-chemical-reactor-recipes",
	energy_required = LUV_SPEED * 20,
	ingredients = {
			{ type = "item", name = "graphite", amount = 64 },
			{ type = "item", name = "europium-doped-wafer", amount = 2 },
			{ type = "fluid", name = "super-glue", amount = 50 }
		},
	results = {
			{ type = "item", name = "graphene", amount = 64 },
		}
}
create_recipe{
	recipe_name = "graphene-ad",
	category = "zpm-chemical-reactor-recipes",
	energy_required = 4 * ZPM_SPEED,
	ingredients = {
			{ type = "item", name = "graphite", amount = 64 },
			{ type = "item", name = "americium-doped-wafer", amount = 1 },
			{ type = "fluid", name = "super-glue", amount = 25 }
		},
	results = {
			{ type = "item", name = "graphene", amount = 64 },
		}
}
	
	
	
---GRAPHENE WIRE
create_item{
	name = "graphene-wire",
	category = "lv-wiremill-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "graphene", amount = 1 },
	}
}
	


---TUNGSTEN CABLE
create_item{
	name = "tungsten-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "tungsten-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "tungsten-cable", amount = 4 }
	}
}
	
	
	
---IV MOTOR
create_item{
	name = "iv-motor",
	ingredients = {
		{ type = "item", name = "tungstensteel-rod", amount = 2 },
		{ type = "item", name = "magnetic-neodymium-rod", amount = 1 },
		{ type = "item", name = "graphene-wire", amount = 16 },
		{ type = "item", name = "tungsten-cable", amount = 4 }
	}
}
   
   
   
---IV PISTON
create_item{
	name = "iv-piston",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 3 },
		{ type = "item", name = "tungstensteel-rod", amount = 2 },
		{ type = "item", name = "tungstensteel-gear", amount = 1 },
		{ type = "item", name = "iv-motor", amount = 1 },
		{ type = "item", name = "tungsten-cable", amount = 2 }
	}
}
   


---IV PUMP
create_item{
	name = "iv-pump",
	ingredients = {
		{ type = "item", name = "iv-motor", amount = 1 },
		{ type = "item", name = "tungstensteel-rotor", amount = 1 },
		{ type = "item", name = "tungstensteel-plate", amount = 3 },
		{ type = "item", name = "tungstensteel-screw", amount = 1 },
		{ type = "item", name = "silicone-rubber-ring", amount = 2 },
		{ type = "item", name = "tungsten-cable", amount = 1 }
	}
}
   
   
   
---IV CONVEYOR MODULE
create_item{
	name = "iv-conveyor-module",
	ingredients = {
		{ type = "item", name = "iv-motor", amount = 2 },
		{ type = "item", name = "tungsten-cable", amount = 1 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 6 },
	}
}



---IV ROBOT ARM
create_item{
	name = "iv-robot-arm",
	ingredients = {
		{ type = "item", name = "iv-motor", amount = 2 },
		{ type = "item", name = "tungstensteel-rod", amount = 2 },
		{ type = "item", name = "iv-piston", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 1 },
		{ type = "item", name = "tungsten-cable", amount = 3 }
	}
}



---INDOVANADIUM [SUPERCONDUCTOR BASE IV]
create_item{
	name = "indovanadium-superconductive-wire",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "indovanadium-wire", amount = 12 },
		{ type = "item", name = "iv-pump", amount = 1 },
		{ type = "fluid", name = "molten-niobium-titanium", amount = 57.6 },
		{ type = "fluid", name = "cryogenic-helium", amount = 800 },
	},
	results = {
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 12 },
	}
}
   
   
   
---GRATE MACHINE CASING
create_item{
	name = "grate-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "iron-stick", amount = 6 },
		{ type = "item", name = "steel-frame", amount = 1 },
		{ type = "item", name = "steel-rotor", amount = 1 },
		{ type = "item", name = "mv-motor", amount = 1 },
	}
}




---INDALLOY 140
create_recipe{
	name = "molten-indalloy-140",
	category = "iv-alloy-blast-smelter-recipes",
	energy_required = 40 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "bismuth", amount = 47 },
		{ type = "item", name = "lead-dust", amount = 25 },
		{ type = "item", name = "tin-dust", amount = 13 },
		{ type = "item", name = "cadmium", amount = 10 },
		{ type = "item", name = "indium", amount = 5 },
	},
	results = {
		{ type = "fluid", name = "molten-indalloy-140", amount = 1440 }
	}
}



---QUANTUM STAR
create_item{
	name = "quantum-star",
	category = "hv-chemical-bath-recipes",
	energy_required = 96 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "nether-star", amount = 1 },
		{ type = "fluid", name = "radon", amount = 125 }
	}
}



---IV SENSOR
create_item{
	name = "iv-sensor",
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "iridium-rod", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 1 },
		{ type = "item", name = "quantum-star", amount = 1 },
	}
}
   
   
   
---IV EMITTER
create_item{
	name = "iv-emitter",
	ingredients = {
		{ type = "item", name = "tungsten-cable", amount = 2 },
		{ type = "item", name = "iridium-rod", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "quantum-star", amount = 1 },
	}
}  
   
   
   
create_item{
	name = "iv-field-generator",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 16 },
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "quantum-star", amount = 1 }
	}
}   
   
   
   
---HPIC WAFER
create_item{
	name = "hpic-wafer",
	category = "iv-chemical-reactor-recipes",
	energy_required = 960,
	ingredients = {
		{ type = "item", name = "mpic-wafer", amount = 1 },
		{ type = "item", name = "indium-gallium-phosphide", amount = 2 },
		{ type = "fluid", name = "molten-vanadium-gallium", amount = 28 }
	}
}
   
   
   
---HIGH POWERED INTEGRATED CIRCUIT
create_item{
	name = "high-powered-integrated-circuit",
	category = "iv-cutting-machine-recipes",
	energy_required = 45 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hpic-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "high-powered-integrated-circuit", amount = 2 }
	}
}
   
   
   
---PLATINUM CABLE
create_item{
	name = "platinum-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "platinum-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "platinum-cable", amount = 4 }
	}
}



---YTTRIUM OXIDE
create_item{
	name = "yttrium-oxide",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 204.8,
	ingredients = {
		{ type = "item", name = "yttrium-dust", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 300 },
	},
	results = {
		{ type = "item", name = "yttrium-oxide", amount = 5 }
	}
}



---THORIANITE
create_item{
	name = "thorianite",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 5 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "thorium-dust", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 200 },
	},
	results = {
		{ type = "item", name = "thorianite", amount = 3 }
	}
} 



---THORIUM YTTRIUM GLASS BLOCK 
create_item{
	name = "thorium-yttrium-glass-block",
	category = "iv-electric-blast-furnace-recipes",
	energy_required = 80 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "thorianite", amount = 1 },
		{ type = "item", name = "yttrium-oxide", amount = 1 },
		{ type = "fluid", name = "molten-glass", amount = 28.8 },
	},
	results = {
		{ type = "item", name = "thorium-yttrium-glass-block", amount = 2 }
	}
}   
   
   
   
---IV MACHINE CASING
create_item{
	name = "iv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 8 },
	},
}


   
---IV MACHINE HULL
create_item{
	name = "iv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "iv-machine-casing", amount = 8 },
		{ type = "item", name = "platinum-cable", amount = 2 },
		{ type = "fluid", name = "ptfe", amount = 28.8 }
	}
} 
   
   
   
---INSANE VOLTAGE COIL
create_item{
	name = "insane-voltage-coil",
	category = "lv-assembling-machine-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "magnetic-neodymium-rod", amount = 1 },
		{ type = "item", name = "fine-iridium-wire", amount = 16 },
	},
}
   
   
   
   ---IV ENERGY HATCH
create_item{
	name = "iv-energy-hatch",
	category = "lv-assembling-machine-recipes",
	energy_required = 160,
	ingredients = {
			{ type = "item", name = "iv-machine-hull", amount = 1 },
			{ type = "item", name = "tungsten-cable", amount = 2 },
			{ type = "item", name = "insane-voltage-coil", amount = 1 },
			{ type = "item", name = "high-powered-integrated-circuit", amount = 2 },
			{ type = "fluid", name = "sodium-potassium", amount = 300 },
		}
}
   
   
   
---IV DYNAMO HATCH
create_item{
	name = "iv-dynamo-hatch",
	category = "lv-assembling-machine-recipes",
	energy_required = 160,
	ingredients = {
			{ type = "item", name = "iv-machine-hull", amount = 1 },
			{ type = "item", name = "tungsten-spring", amount = 2 },
			{ type = "item", name = "insane-voltage-coil", amount = 1 },
			{ type = "item", name = "high-powered-integrated-circuit", amount = 2 },
			{ type = "fluid", name = "sodium-potassium", amount = 300 },
		}
}



-------------------
---PLATINUM LINE---
-------------------

---PLATINUM GROUP SLUDGE  
create_recipe{
	recipe_name = "platinum-group-sludge-pentlandite",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "crushed-pentlandite", amount = 1 },
		{ type = "fluid", name = "nitric-acid", amount = 10 },
	},
	results = {
		{ type = "item", name = "platinum-group-sludge", amount = 2 },
		{ type = "fluid", name = "sulfuric-nickel-solution", amount = 100 },
	},
	main_product = "platinum-group-sludge"
}
create_recipe{
	recipe_name = "platinum-group-sludge-bornite",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "crushed-bornite", amount = 1 },
		{ type = "fluid", name = "nitric-acid", amount = 10 },
	},
	results = {
		{ type = "item", name = "platinum-group-sludge", amount = 2 },
		{ type = "fluid", name = "sulfuric-copper-solution", amount = 100 },
	},
	main_product = "platinum-group-sludge"
}
create_recipe{
	recipe_name = "platinum-group-sludge-tetrahedrite",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "crushed-tetrahedrite", amount = 1 },
		{ type = "fluid", name = "nitric-acid", amount = 10 },
	},
	results = {
		{ type = "item", name = "platinum-group-sludge", amount = 2 },
		{ type = "fluid", name = "sulfuric-copper-solution", amount = 100 },
	},
	main_product = "platinum-group-sludge"
}
create_recipe{
	recipe_name = "platinum-group-sludge-sheldonite",
	category = "lv-chemical-reactor-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "crushed-sheldonite", amount = 1 },
		{ type = "fluid", name = "nitric-acid", amount = 10 },
	},
	results = {
		{ type = "item", name = "platinum-group-sludge", amount = 4 },
		{ type = "fluid", name = "sulfuric-nickel-solution", amount = 100 },
	},
	main_product = "platinum-group-sludge"
}
create_recipe{
	recipe_name = "sulfuric-nickel-solution-electrolysis",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-nickel-solution", amount = 100 },
	},
	results = {
		{ type = "item", name = "nickel-dust", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	main_product = "nickel-dust"
}
create_recipe{
	recipe_name = "sulfuric-copper-solution-electrolysis",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{ type = "fluid", name = "sulfuric-copper-solution", amount = 100 },
	},
	results = {
		{ type = "item", name = "copper-dust", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	main_product = "copper-dust"
}



---AQUA REGIA
create_recipe{
	recipe_name = "aqua-regia",
	category = "lv-mixer-recipes",
	energy_required = 1.5,
	ingredients = {
		{ type = "fluid", name = "nitric-acid", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "aqua-regia", amount = 300 },
	}
}



---PLATINUM GROUP SLUDGE PROCESSING
create_item{
	name = "platinum-group-residue",
	recipe_name = "platinum-group-sludge-processing",
	category = "lv-chemical-bath-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "platinum-group-sludge", amount = 2 },
		{ type = "fluid", name = "aqua-regia", amount = 200 },
	},
	results = {
		{ type = "item", name = "platinum-group-residue", amount = 1 },
		{ type = "item", name = "platinum-sludge-residue", amount = 1 },
		{ type = "fluid", name = "platinum-palladium-leachate", amount = 100 },
	},
	main_product = "platinum-palladium-leachate"
}



---PLATINUM SLUDGE RESIDUE PROCESSING   
create_item{
	name = "platinum-sludge-residue",
	recipe_name = "platinum-sludge-residue-processing",
	category = "lv-centrifuge-recipes",
	energy_required = 46.9,
	ingredients = {
		{ type = "item", name = "platinum-sludge-residue", amount = 5 },
	},
	results = {
		{ type = "item", name = "copper-dust", amount = 2 },		
		{ type = "item", name = "raw-silicon", amount = 2 },
		{ type = "item", name = "gold-dust", amount = 1, probability = 0.1 },
	},
	main_product = "copper-dust"
}



---PLATINUM PALLADIUM LEACHATE PROCESSING   
create_item{
	name = "ammonium-chloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "fluid", name = "ammonia", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	},
	results = {
		{ type = "item", name = "ammonium-chloride", amount = 2 },
	}
}
create_item{ skip_recipe = true,
	name = "ammonia-hexachloroplatinate",
	subgroup = "subgroup-lv-chemical-reactor-recipes",
}
create_item{
	name = "crude-platinum-residue",
	recipe_name = "platinum-palladium-leachate-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "ammonium-chloride", amount = 8 },
		{ type = "fluid", name = "platinum-palladium-leachate", amount = 100 },
	},
	results = {
		{ type = "item", name = "ammonia-hexachloroplatinate", amount = 9 },
		{ type = "item", name = "crude-platinum-residue", amount = 1 },		
		{ type = "fluid", name = "palladium-rich-ammonia", amount = 100 },
	},
	main_product = "ammonia-hexachloroplatinate"
}
   
   
   
---CRUDE PLATINUM RESIDUE PROCESSING
create_item{
	name = "metallic-platinum-powder",
	category = "lv-sifter-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "crude-platinum-residue", amount = 1 },
	},
	results = {
		{ type = "item", name = "metallic-platinum-powder", amount = 1, probability = 0.95 },		
	}
}
create_recipe{
	recipe_name = "metallic-platinum-powder-processing",
	category = "lv-chemical-bath-recipes",
	energy_required = 12.5,
	ingredients = {
			{ type = "item", name = "metallic-platinum-powder", amount = 2 },
			{ type = "fluid", name = "aqua-regia", amount = 200 },

		},
	results = {
			{ type = "item", name = "platinum-group-residue", amount = 1 },
			{ type = "fluid", name = "platinum-palladium-leachate", amount = 100 },			
		},
	main_product = "platinum-group-residue"
}


   
---AMMONIA HEXACHLOROPLATINATE PROCESSING
create_recipe{
	recipe_name = "chloroplatinic-acid",
	category = "lv-electrolyzer-recipes",
	energy_required = 1.5,
	ingredients = {
		{ type = "item", name = "ammonia-hexachloroplatinate", amount = 9 },
	},
	results = {
		{ type = "fluid", name = "chloroplatinic-acid", amount = 100 },		
		{ type = "fluid", name = "ammonia", amount = 200 },
	},
	main_product = "chloroplatinic-acid"
}
create_item{
	name = "raw-platinum-powder",
	category = "lv-distillation-recipes",
	energy_required = 6,
	ingredients = {
		{ type = "fluid", name = "chloroplatinic-acid", amount = 100 },
	},
	results = {
		{ type = "item", name = "raw-platinum-powder", amount = 3 },		
		{ type = "fluid", name = "hydrochloric-acid", amount = 400 },
	},
	main_product = "raw-platinum-powder"
}
create_recipe{
	recipe_name = "platinum-dust",
	category = "lv-autoclave-recipes",
	energy_required = 1.5,
	ingredients = {
		{ type = "item", name = "raw-platinum-powder", amount = 3 },	
		{ type = "item", name = "calcium", amount = 1 },	
		{ type = "fluid", name = "steam", amount = 384 },	
	},
	results = {
		{ type = "item", name = "platinum-dust", amount = 1 },		
		{ type = "item", name = "calcium-chloride", amount = 3 },
		{ type = "fluid", name = "water", amount = 2.4 },	
	},
	main_product = "platinum-dust"
}



---PALLADIUM RICH AMMONIA PROCESSING
create_item{
	name = "crude-palladium-residue",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 6.25,
	ingredients = {
		{ type = "fluid", name = "palladium-rich-ammonia", amount = 50 },
	}
}
create_item{
	name = "metallic-palladium-powder",
	category = "lv-sifter-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "crude-palladium-residue", amount = 1 },
	},
	results = {
		{ type = "item", name = "metallic-palladium-powder", amount = 1, probability = 0.95 },		
	}
}
create_item{
	name = "raw-palladium-powder",
	recipe_name = "palladium-rich-ammonia-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12.5,
	ingredients = {
		{ type = "item", name = "metallic-palladium-powder", amount = 2 },	
		{ type = "fluid", name = "palladium-rich-ammonia", amount = 100 },
	},
	results = {
		{ type = "item", name = "raw-palladium-powder", amount = 1 },
		{ type = "item", name = "crude-palladium-residue", amount = 3 },		
		{ type = "fluid", name = "ammonia", amount = 200 },
	},
	main_product = "raw-palladium-powder"
}
create_recipe{
	recipe_name = "raw-palladium-powder-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
			{ type = "item", name = "raw-palladium-powder", amount = 3 },	
			{ type = "fluid", name = "formic-acid", amount = 100 },
		},
	results = {
			{ type = "item", name = "palladium-dust", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 400 },		
			{ type = "fluid", name = "carbon-dioxide", amount = 100 },
		},
	main_product = "palladium-dust"
}   



------------------------
---RHODIUM PROCESSING---
------------------------

---PLATINUM GROUP RESIDUE PROCESSING
create_item{
	name = "potassium-pyrosulfate",
	category = "lv-chemical-bath-recipes",
	energy_required = 3,
	ingredients = {
			{ type = "item", name = "rock-salt", amount = 2 },
			{ type = "fluid", name = "sulfuric-acid", amount = 100 },
		},
	results = {
			{ type = "item", name = "potassium-pyrosulfate", amount = 11 },
		}
}
create_item{ skip_recipe = true,
	name = "potassium-sulfate",
	subgroup = "subgroup-mv-electric-blast-furnace-recipes"
}
create_item{
	name = "iridium-group-sludge",
	recipe_name = "platinum-group-residue-processing",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 20,
	ingredients = {
			{ type = "item", name = "platinum-group-residue", amount = 1 },
			{ type = "item", name = "potassium-pyrosulfate", amount = 11 },
		},
	results = {
			{ type = "item", name = "rhodium-sulfate", amount = 1 },
			{ type = "item", name = "potassium-sulfate", amount = 7 },
			{ type = "item", name = "iridium-group-sludge", amount = 1 },
		},
	main_product = "rhodium-sulfate"
}
create_recipe{
	recipe_name = "sulfur-dioxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
			{ type = "fluid", name = "oxygen", amount = 200 },
			{ type = "item", name = "sulfur", amount = 1 },
		},
	results = {
			{ type = "fluid", name = "sulfur-dioxide", amount = 100 },
		}
}
create_recipe{
	recipe_name = "sulfur-trioxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
			{ type = "fluid", name = "oxygen", amount = 100 },
			{ type = "fluid", name = "sulfur-dioxide", amount = 100 },
		},
	results = {
			{ type = "fluid", name = "sulfur-trioxide", amount = 100 },
		}
}
create_recipe{
	recipe_name = "potassium-sulfate-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
			{ type = "item", name = "potassium-sulfate", amount = 7 },
			{ type = "fluid", name = "sulfur-trioxide", amount = 100 },
		},
	results = {
			{ type = "item", name = "potassium-pyrosulfate", amount = 11 },
		}
}
create_item{
	name = "rhodium-sulfate",
	recipe_name = "rhodium-sulfate-processing",
	category = "lv-chemical-bath-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "rhodium-sulfate", amount = 6 },
			{ type = "fluid", name = "water", amount = 200 },
		},
	results = {
			{ type = "item", name = "iridium-group-sludge", amount = 1 },
			{ type = "fluid", name = "rhodium-sulfate-solution", amount = 200 },
		},
	main_product = "rhodium-sulfate-solution"
}
create_item{
	name = "crude-rhodium-residue",
	recipe_name = "rhodium-sulfate-solution-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "zinc-dust", amount = 3 },
			{ type = "fluid", name = "rhodium-sulfate-solution", amount = 100 },
		},
	results = {
			{ type = "item", name = "zinc-sulfate", amount = 18 },
			{ type = "item", name = "crude-rhodium-residue", amount = 1 },
		},
	main_product = "crude-rhodium-residue"
}
create_item{
	name = "zinc-sulfate",
	recipe_name = "zinc-sulfate-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 16,
	ingredients = {
			{ type = "item", name = "zinc-sulfate", amount = 6 },
		},
	results = {
			{ type = "item", name = "zinc-dust", amount = 1 },
			{ type = "item", name = "sulfur", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 400 },
		},
	main_product = "zinc-dust"
}
create_item{
	name = "rhodium-salt",
	recipe_name = "crude-rhodium-residue-processing",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 30,
	ingredients = {
			{ type = "item", name = "crude-rhodium-residue", amount = 1 },
			{ type = "item", name = "salt", amount = 4 },
			{ type = "fluid", name = "chlorine", amount = 400 },
		},
	results = {
			{ type = "item", name = "rhodium-salt", amount = 1 },
			{ type = "fluid", name = "steam", amount = 960 },
		},
	main_product = "rhodium-salt"
}
create_item{
	name = "sodium-nitrate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 1,
	ingredients = {
			{ type = "item", name = "sodium", amount = 1 },
			{ type = "fluid", name = "nitric-acid", amount = 100 },
		},
	results = {
			{ type = "item", name = "sodium-nitrate", amount = 5 },
			{ type = "fluid", name = "hydrogen", amount = 100 },
		},
	main_product = "sodium-nitrate"
}
create_item{
	name = "rhodium-nitrate",
	recipe_name = "rhodium-salt-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "rhodium-salt", amount = 1 },
			{ type = "item", name = "sodium-nitrate", amount = 30 },
		},
	results = {
			{ type = "item", name = "rhodium-nitrate", amount = 26 },
			{ type = "item", name = "salt", amount = 16 },
		},
	main_product = "rhodium-nitrate"
}
create_item{
	name = "rhodium-dust",
	recipe_name = "rhodium-nitrate-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "rhodium-nitrate", amount = 13 },
			{ type = "item", name = "potassium", amount = 3 },
		},
	results = {
			{ type = "item", name = "rhodium-dust", amount = 1 },
			{ type = "item", name = "saltpeter", amount = 15 },
		},
	main_product = "rhodium-dust"
}
   
   
   
---RUTHENIUM PROCESSING

create_item{
	name = "soda-ash",
	category = "lv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
			{ type = "item", name = "sodium-hydroxide", amount = 6 },
			{ type = "fluid", name = "carbon-dioxide", amount = 100 },
		},
	results = {
			{ type = "item", name = "soda-ash", amount = 6 },
			{ type = "fluid", name = "water", amount = 100 },

		},
	main_product = "soda-ash"
}
create_item{ skip_recipe = true,
	name = "rarest-metal-mixture",
	subgroup = "subgroup-mv-electric-blast-furnace-recipes"
}
create_item{
	name = "sodium-ruthenate",
	recipe_name = "iridium-group-sludge-processing",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 20,
	ingredients = {
			{ type = "item", name = "iridium-group-sludge", amount = 1 },
			{ type = "item", name = "soda-ash", amount = 2 },
		},
	results = {
			{ type = "item", name = "sodium-ruthenate", amount = 1 },
			{ type = "item", name = "rarest-metal-mixture", amount = 1 },
		},
	main_product = "sodium-ruthenate"
}  
create_item{
	name = "ruthenium-tetroxide",
	category = "hv-chemical-reactor-recipes",
	energy_required = 315,
	ingredients = {
			{ type = "item", name = "sodium-ruthenate", amount = 6 },
			{ type = "fluid", name = "chlorine", amount = 200 },
			{ type = "fluid", name = "water", amount = 200 },
		},
	results = {
			{ type = "item", name = "ruthenium-tetroxide", amount = 5 },
			{ type = "fluid", name = "salt-water", amount = 200 },

		},
	main_product = "ruthenium-tetroxide"
}
create_item{
	name = "ruthenium-dust",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "ruthenium-tetroxide", amount = 5 },
			{ type = "fluid", name = "hydrogen", amount = 800 },
		},
	results = {
			{ type = "item", name = "ruthenium-dust", amount = 1 },
			{ type = "fluid", name = "water", amount = 400 },
		},
	main_product = "ruthenium-dust"
}   
   
   
   
----IRIDUM PROCESSING
create_item{
	name = "iridium-metal-residue",
	category = "lv-chemical-bath-recipes",
	energy_required = 5,
	ingredients = {
			{ type = "item", name = "rarest-metal-mixture", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
		},
	results = {
			{ type = "item", name = "iridium-metal-residue", amount = 1 },
			{ type = "fluid", name = "acidic-osmium-solution", amount = 100 },
		},
	main_product = "iridium-metal-residue"
}
create_recipe{
	recipe_name = "hydrogen-peroxide",
	category = "hv-chemical-reactor-recipes",
	energy_required = 66,
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 600 },
		{ type = "fluid", name = "hydrogen", amount = 600 },
	},
	results = {
		{ type = "fluid", name = "hydrogen-peroxide", amount = 300 },
	}
}
create_item{
	name = "sodium-peroxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 6 },
		{ type = "fluid", name = "hydrogen-peroxide", amount = 700 },
	},
	results = {
		{ type = "item", name = "sodium-peroxide", amount = 4 },
		{ type = "fluid", name = "water", amount = 800 },
		{ type = "fluid", name = "oxygen", amount = 600 },
	},
	main_product = "sodium-peroxide"
}
create_item{
	name = "iridium-dioxide-residue",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 20,
	ingredients = {
			{ type = "item", name = "sodium-peroxide", amount = 4 },
			{ type = "item", name = "iridium-metal-residue", amount = 1 },
		},
	results = {
			{ type = "item", name = "iridium-dioxide-residue", amount = 3 },
			{ type = "item", name = "sodium", amount = 2 },

		},
	main_product = "iridium-dioxide-residue"
}
create_recipe{
	recipe_name = "acidic-iridium-dioxide-solution",
	category = "lv-mixer-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "iridium-dioxide-residue", amount = 3 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 400 },
		},
	results = {
			{ type = "fluid", name = "acidic-iridium-dioxide-solution", amount = 400 },
		}
}    
create_item{
	name = "ammonia-hexachloroiridiate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 60,
	ingredients = {
			{ type = "item", name = "ammonium-chloride", amount = 4 },
			{ type = "fluid", name = "acidic-iridium-dioxide-solution", amount = 1600 },
		},
	results = {
			{ type = "item", name = "ammonia-hexachloroiridiate", amount = 8 },
			{ type = "fluid", name = "water", amount = 800 },
			{ type = "item", name = "platinum-group-residue", amount = 1 },

		},
	main_product = "ammonia-hexachloroiridiate"
}
create_item{
	name = "iridium-dust",
	category = "iv-chemical-reactor-recipes",
	energy_required = 118.4,
	ingredients = {
			{ type = "item", name = "ammonia-hexachloroiridiate", amount = 8 },
			{ type = "fluid", name = "hydrogen", amount = 1200 },
		},
	results = {
			{ type = "item", name = "iridium-dust", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 1800 },
			{ type = "fluid", name = "ammonia", amount = 200 },
		},
	main_product = "iridium-dust"
}  



---OSMIUM PROCESSING
create_item{
	name = "osmium-tetroxide",
	category = "ev-distillation-recipes",
	energy_required = 120,
	ingredients = {
			{ type = "fluid", name = "acidic-osmium-solution", amount = 200 },
		},
	results = {
			{ type = "item", name = "osmium-tetroxide", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
		},
	main_product = "osmium-tetroxide"
} 
create_item{
	name = "osmium-dust",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
			{ type = "item", name = "osmium-tetroxide", amount = 5 },
			{ type = "fluid", name = "hydrogen", amount = 800 },
		},
	results = {
			{ type = "item", name = "osmium-dust", amount = 1 },
			{ type = "fluid", name = "water", amount = 400 },
		},
	main_product = "osmium-dust"
}  
   


--- CHLOROBENZENE
create_recipe{
	recipe_name = "chlorobenzene",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
			{ type = "fluid", name = "chlorine", amount = 200 },
			{ type = "fluid", name = "benzene", amount = 100 },
		},
	results = {
			{ type = "fluid", name = "chlorobenzene", amount = 100 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
		},
	main_product = "chlorobenzene"
}



--- NITROCHLOROBENZENE
create_recipe{
	recipe_name = "nitrochlorobenzene",
	category = "hv-chemical-reactor-recipes",
	energy_required = 20,
	ingredients = {
			{ type = "fluid", name = "chlorobenzene", amount = 100 },
			{ type = "fluid", name = "nitration-mixture", amount = 200 },
		},
	results = {
			{ type = "fluid", name = "nitrochlorobenzene", amount = 100 },
			{ type = "fluid", name = "diluted-sulfuric-acid", amount = 100 },
		},
	main_product = "nitrochlorobenzene"
}
   


--- DICHLOROBENZIDINE
create_recipe{
	recipe_name = "dichlorobenzidine",
	category = "ev-chemical-reactor-recipes",
	energy_required = 720,
	ingredients = {
			{ type = "item", name = "copper-dust", amount = 1 },
			{ type = "fluid", name = "nitrochlorobenzene", amount = 1800 },
			{ type = "fluid", name = "hydrogen", amount = 1800 },
		},
	results = {
			{ type = "fluid", name = "dichlorobenzidine", amount = 900 },
		}
}
   
   
   
--- DIOMINOBENZIDINE
create_recipe{
	recipe_name = "diaminobenzidine",
	category = "iv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "dichlorobenzidine", amount = 100 },
			{ type = "fluid", name = "ammonia", amount = 200 },
		},
	results = {
			{ type = "fluid", name = "diaminobenzidine", amount = 100 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
		},
	main_product = "diaminobenzidine"
}


--- SAMARIUM DUST - PLACEHOLDER RECIPE
create_item{
	name = "samarium-dust",
	category = "mv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
			{ type = "item", name = "stone", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 300 },
		},
	results = {
			{ type = "item", name = "samarium-dust", amount = 1 },
		}
}



--- SAMARIUM INGOT - PLACEHOLDER RECIPE
create_item{
	name = "samarium-ingot",
	category = "mv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
			{ type = "item", name = "samarium-dust", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 300 },
		},
	results = {
			{ type = "item", name = "samarium-ingot", amount = 1 },
		}
}



--- CHROMIUM TRIOXIDE
create_item{
	name = "chromium-trioxide",
	category = "mv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
			{ type = "item", name = "chromium-dust", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 300 },
		},
	results = {
			{ type = "item", name = "chromium-trioxide", amount = 4 },
		}
}
   


--- POTASSIUM DICHROMATE
create_item{
	name = "potassium-dichromate",
	category = "hv-chemical-reactor-recipes",
	energy_required = 20,
	ingredients = {
			{ type = "item", name = "saltpeter", amount = 10 },
			{ type = "item", name = "chromium-trioxide", amount = 8 },
		},
	results = {
			{ type = "item", name = "potassium-dichromate", amount = 11 },
			{ type = "fluid", name = "nitrogen-dioxide", amount = 200 },
		},
	main_product = "potassium-dichromate"
}
   


--- CHARCOAL BYPRODUCTS DISTILLATION
create_recipe{
	recipe_name = "charcoal-byproducts-distillation",
	category = "hv-tall-distillation-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "charcoal-byproducts", amount = 1000 },
		},
	results = {
			{ type = "fluid", name = "dimethylbenzene", amount = 100 },
			{ type = "fluid", name = "wood-tar", amount = 250 },
			{ type = "fluid", name = "wood-vinegar", amount = 400 },
			{ type = "fluid", name = "wood-gas", amount = 250 },
			{ type = "item", name = "carbon", amount = 1, probability = 0.25 },
		},
	main_product = "dimethylbenzene"
}
   


--- WOOD TAR DISTILLATION
create_recipe{
	recipe_name = "wood-tar-distillation",
	category = "hv-tall-distillation-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "wood-tar", amount = 1000 },
		},
	results = {
			{ type = "fluid", name = "dimethylbenzene", amount = 200 },
			{ type = "fluid", name = "toluene", amount = 75 },
			{ type = "fluid", name = "creosote", amount = 300 },
			{ type = "fluid", name = "phenol", amount = 75 },
			{ type = "fluid", name = "benzene", amount = 350 },
		},
	main_product = "dimethylbenzene"
}
   


--- WOOD VINEGAR DISTILLATION
create_recipe{
	recipe_name = "wood-vinegar-distillation",
	category = "hv-tall-distillation-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "wood-vinegar", amount = 1000 },
		},
	results = {
			{ type = "fluid", name = "methanol", amount = 300 },
			{ type = "fluid", name = "acetone", amount = 50 },
			{ type = "fluid", name = "methyl-acetate", amount = 10 },
			{ type = "fluid", name = "acetic-acid", amount = 100 },
			{ type = "fluid", name = "water", amount = 500 },
			{ type = "fluid", name = "ethanol", amount = 10 },
		},
	main_product = "methanol"
}
   


--- WOOD GAS DISTILLATION
create_recipe{
	recipe_name = "wood-gas-distillation",
	category = "hv-tall-distillation-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "wood-gas", amount = 1000 },
		},
	results = {
			{ type = "fluid", name = "methane", amount = 130 },
			{ type = "fluid", name = "carbon-monoxide", amount = 240 },
			{ type = "fluid", name = "hydrogen", amount = 120 },
			{ type = "fluid", name = "carbon-dioxide", amount = 390 },
			{ type = "fluid", name = "ethylene", amount = 120 },
		},
	main_product = "carbon-dioxide"
}
   


--- PHTHALIC ACID
create_recipe{
	recipe_name = "phthalic-acid",
	category = "ev-chemical-reactor-recipes",
	energy_required = 360,
	ingredients = {
			{ type = "item", name = "potassium-dichromate", amount = 1 },
			{ type = "fluid", name = "dimethylbenzene", amount = 900 },
			{ type = "fluid", name = "oxygen", amount = 1800 },
		},
	results = {
			{ type = "fluid", name = "phthalic-acid", amount = 900 },
			{ type = "fluid", name = "water", amount = 1800 },
		},
	main_product = "phthalic-acid"
}
   


--- DIPHENYL ISOPHTHALATE
create_recipe{
	recipe_name = "diphenyl-isophthalate",
	category = "iv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "phenol", amount = 200 },
			{ type = "fluid", name = "sulfuric-acid", amount = 100 },
			{ type = "fluid", name = "phthalic-acid", amount = 100 },
		},
	results = {
			{ type = "fluid", name = "diphenyl-isophthalate", amount = 100 },
			{ type = "fluid", name = "diluted-sulfuric-acid", amount = 100 },
		},
	main_product = "diphenyl-isophthalate"
}
   


--- POLYBENZIMIDAZOLE
create_recipe{
	recipe_name = "polybenzimidazole",
	category = "iv-chemical-reactor-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "fluid", name = "diaminobenzidine", amount = 100 },
			{ type = "fluid", name = "diphenyl-isophthalate", amount = 100 },
		},
	results = {
			{ type = "fluid", name = "phenol", amount = 100 },
			{ type = "fluid", name = "polybenzimidazole", amount = 100.8 },
		},
	main_product = "polybenzimidazole"
}
   
   
   
---POLYBENZIMIDAZOLE SHEET
create_item{
	name = "polybenzimidazole-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "fluid", name = "polybenzimidazole", amount = 14.4 },
	}
}
   
   
   
---THIN POLYBENZIMIDAZOLE SHEET
create_item{
	name = "thin-polybenzimidazole-sheet",
	category = "lv-bending-machine-recipes",
	energy_required = 0.4,
	ingredients = {
		{ type = "item", name = "polybenzimidazole-sheet", amount = 1 },
	},
	results = {
		{ type = "item", name = "thin-polybenzimidazole-sheet", amount = 4 }
	}
}
   
   
   
---ADVANCED SMD INDUCTOR
create_item{
	name = "advanced-smd-inductor",
	category = "ev-assembling-machine-recipes",
	energy_required = 8 * EV_SPEED,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "samarium-ring", amount = 1 },
		{ type = "item", name = "fine-hsse-wire", amount = 32 },
		{ type = "item", name = "tungstensteel-bolt", amount = 4 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 }
	},
	results = {
		{ type = "item", name = "advanced-smd-inductor", amount = 64 }
	}
}



---ADVANCED SMD CAPACITOR
create_item{
	name = "advanced-smd-capacitor",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 15,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "thin-polybenzimidazole-sheet", amount = 4 },
		{ type = "item", name = "hsss-foil", amount = 2 },
		{ type = "item", name = "tungstensteel-bolt", amount = 4 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 }
	},
	results = {
		{ type = "item", name = "advanced-smd-capacitor", amount = 64 }
	}
}   
   
   
   
---ADVANCED SMD TRANSISTOR
create_item{
	name = "advanced-smd-transistor",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 15,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "vanadium-gallium-foil", amount = 2 },
		{ type = "item", name = "fine-hssg-wire", amount = 16 },
		{ type = "item", name = "tungstensteel-bolt", amount = 4 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 }
	},
	results = {
		{ type = "item", name = "advanced-smd-transistor", amount = 64 }
	}
}



---ADVANCED SMD RESISTOR
create_item{
	name = "advanced-smd-resistor",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 15,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "graphene", amount = 2 },
		{ type = "item", name = "fine-platinum-wire", amount = 16 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 },
	},
	results = {
		{ type = "item", name = "advanced-smd-resistor", amount = 64 }
	}
}



---ADVANCED SMD DIODE
create_item{
	name = "advanced-smd-diode",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "indium-gallium-phosphide", amount = 1 },
		{ type = "item", name = "fine-niobium-titanium-wire", amount = 16 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 },
	},
	results = {
		{ type = "item", name = "advanced-smd-diode", amount = 64 }
	}
}  
      
   
   
---FIBER REINFORCED EPOXY SHEET
create_item{
	name = "fiber-reinforced-epoxy-sheet",
	category = "lv-chemical-bath-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "raw-carbon-fibers", amount = 1 },
		{ type = "fluid", name = "epoxy", amount = 14.4 },
	}
}


   
---FIBER REINFORCED CIRCUIT BOARD
create_item{
	name = "fiber-reinforced-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-epoxy-sheet", amount = 1 },
		{ type = "item", name = "annealed-copper-foil", amount = 8 },
		{ type = "fluid", name = "sulfuric-acid", amount = 25 }
	}
}
   
   
   
---FIBER REINFORCED PRINTED CIRCUIT BOARD
create_item{
	name = "fiber-reinforced-printed-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-circuit-board", amount = 1 },
		{ type = "item", name = "energetic-alloy-foil", amount = 12 },
		{ type = "fluid", name = "iron-iii-chloride", amount = 100 },
	}
}



---INDIUM PRODUCTION
create_recipe{
	recipe_name = "indium-concentrate",
	category = "hv-chemical-reactor-recipes",
	energy_required = 3 * HV_SPEED,
	ingredients = {
			{ type = "item", name = "crushed-galena", amount = 3 },
			{ type = "item", name = "crushed-sphalerite", amount = 1 },
			{ type = "fluid", name = "sulfuric-acid", amount = 400 }
		},
	results = {
			{ type = "fluid", name = "indium-concentrate", amount = 800 }
		}
}
create_item{
	name = "indium",
	recipe_name = "indium-separation",
	category = "hv-chemical-reactor-recipes",
	energy_required = 22.5 * HV_SPEED,
	ingredients = {
			{ type = "item", name = "aluminium-dust", amount = 36 },
			{ type = "fluid", name = "indium-concentrate", amount = 7200 }
		},
	results = {
			{ type = "item", name = "indium", amount = 1 },
			{ type = "fluid", name = "lead-zinc-solution", amount = 7200 },
		},
	main_product = "indium"
}
create_recipe{
	recipe_name = "lead-zinc-solution-centrifuging",
	category = "lv-centrifuge-recipes",
	energy_required = 36,
	ingredients = {
			{ type = "fluid", name = "lead-zinc-solution", amount = 100 }
		},
	results = {
			{ type = "item", name = "lead-dust", amount = 1 },
			{ type = "item", name = "silver-dust", amount = 1 },
			{ type = "item", name = "zinc-dust", amount = 1 },
			{ type = "item", name = "sulfur", amount = 3 },
			{ type = "fluid", name = "water", amount = 100 }
		},
	main_product = "lead-dust"
}   
   


 ---INDIUM GALLIUM PHOSPHIDE
create_item{
	name = "indium-gallium-phosphide",
	category = "lv-mixer-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "indium", amount = 1 },
		{ type = "item", name = "gallium", amount = 1 },
		{ type = "item", name = "phosphorus", amount = 1 }
	}
}
   
   
   
 ---QUBIT CPU WAFER
create_item{
	name = "qubit-cpu-wafer",
	category = "ev-chemical-reactor-recipes",
	energy_required = 480,
	ingredients = {
		{ type = "item", name = "nano-cpu-wafer", amount = 1 },
		{ type = "item", name = "indium-gallium-phosphide", amount = 2 },
		{ type = "fluid", name = "radon", amount = 5 },
	}
}
   
   
   
---QUBIT CPU CHIP
create_item{
	name = "qubit-cpu-chip",
	category = "ev-cutting-machine-recipes",
	energy_required = 360,
	ingredients = {
		{ type = "item", name = "qubit-cpu-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "qubit-cpu-chip", amount = 4 }
	}
}


   
---QUANTUM PROCESSOR 
create_recipe{
	recipe_name = "quantum-processor",
	category = "iv-circuit-assembler-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "qubit-cpu-chip", amount = 1 },
		{ type = "item", name = "nano-cpu-chip", amount = 1 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 3 },
		{ type = "item", name = "advanced-smd-transistor", amount = 3 },
		{ type = "item", name = "fine-platinum-wire", amount = 12 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "ev-circuit", amount = 1 }
	}
}



---QUANTUM PROCESSOR ASSEMBLY
create_recipe{
	recipe_name = "quantum-processor-assembly",
	category = "iv-circuit-assembler-recipes",
	energy_required = 10 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "advanced-smd-inductor", amount = 3 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 4 },
		{ type = "item", name = "ram-chip", amount = 4 },
		{ type = "item", name = "fine-platinum-wire", amount = 24 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "iv-circuit", amount = 1 }
	}
}   
	
	
	
---QUANTUM PROCESSOR SUPERCOMPUTER 
create_recipe{
	recipe_name = "quantum-processor-supercomputer",
	category = "iv-circuit-assembler-recipes",
	energy_required = 10 * IV_SPEED,
	ingredients = {
			{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
			{ type = "item", name = "iv-circuit", amount = 2 },
			{ type = "item", name = "advanced-smd-diode", amount = 2 },
			{ type = "item", name = "nor-memory-chip", amount = 4 },
			{ type = "item", name = "ram-chip", amount = 16 },
			{ type = "item", name = "fine-platinum-wire", amount = 48 },
			{ type = "fluid", name = "soldering-alloy", amount = 14.4 }
		},
	results = {
			{ type = "item", name = "luv-circuit", amount = 1 }
		}
}



---QUANTUM PROCESSOR MAINFRAME 
create_item{ skip_recipe = true,
	name = "zpm-circuit",
	subgroup = "subgroup-iv-circuit-assembler-recipes",
}
create_recipe{
	recipe_name = "quantum-processor-mainframe",
	category = "iv-circuit-assembler-recipes",
	energy_required = 40 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "aluminium-frame", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "advanced-smd-inductor", amount = 6 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 12 },
		{ type = "item", name = "ram-chip", amount = 24 },
		{ type = "item", name = "annealed-copper-wire", amount = 48 },
		{ type = "fluid", name = "soldering-alloy", amount = 28 }
	},
	results = {
		{ type = "item", name = "zpm-circuit", amount = 1 }
	}
}  



---HSSG DUST
create_item{
	name = "hssg-dust",
	category = "ev-mixer-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
			{ type = "item", name = "tungstensteel-dust", amount = 5 },
			{ type = "item", name = "chromium-dust", amount = 1 },
			{ type = "item", name = "molybdenum-dust", amount = 2 },
			{ type = "item", name = "vanadium-dust", amount = 1 },
		},
	results = {
			{ type = "item", name = "hssg-dust", amount = 9 }
		}
} 



   
---HSSG COIL (LuV)
create_item{
	name = "hssg-coil-block",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "hssg-wire", amount = 16 },
		{ type = "item", name = "tungsten-carbide-foil", amount = 8 },
		{ type = "fluid", name = "molten-rtm-alloy", amount = 14.4 }
	}
}
   
   
   
---TITANIUM TURBINE CASING
create_item{
	name = "titanium-turbine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 6 },
		{ type = "item", name = "steel-turbine-casing", amount = 1 },
	}
}
 
   
   
---IRIDIUM ALLOY INGOT
create_item{
	name = "iridium-alloy-ingot",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "iridium-plate", amount = 4 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "exquisite-diamond", amount = 1 },
	}
}
 
   
   
---IRIDIUM REINFORCED PLATE
create_item{
	name = "iridium-reinforced-plate",
	category = "lv-implosion-compressor-recipes",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "iridium-alloy-ingot", amount = 1 },
		{ type = "item", name = "explosives", amount = 1 },
	}
}


   
---NEUTRON REFLECTOR
create_item{
	name = "neutron-reflector",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 45,
	ingredients = {
		{ type = "item", name = "graphite", amount = 8 },
		{ type = "item", name = "tin-plate", amount = 4 },
		{ type = "item", name = "beryllium-plate", amount = 4 },
		{ type = "item", name = "silicon-plate", amount = 2 },
	}
}
   
   
   
---THICK NEUTRON REFLECTOR
create_item{
	name = "thick-neutron-reflector",
	category = "ev-assembling-machine-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "beryllium-plate", amount = 4 },
		{ type = "item", name = "neutron-reflector", amount = 4 },
	}
}
   
   
   
---IRIDIUM NEUTRON REFLECTOR
create_item{
	name = "iridium-neutron-reflector",
	category = "iv-assembling-machine-recipes",
	energy_required = 45,
	ingredients = {
		{ type = "item", name = "iridium-reinforced-plate", amount = 2 },
		{ type = "item", name = "thick-neutron-reflector", amount = 6 },
	}
}
   
 
   
---NAND MEMORY WAFER
create_item{
	name = "nand-memory-wafer",
	recipe_name = "nand-memory-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 45 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 },
	}
}
create_recipe{
	recipe_name = "nand-memory-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "distilled-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nand-memory-wafer", amount = 4 },
	}
}
create_recipe{
	recipe_name = "nand-memory-wafer-ed",
	category = "iv-laser-engraver-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "europium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-3-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nand-memory-wafer", amount = 8 },
	}
}
create_recipe{
	recipe_name = "nand-memory-wafer-ad",
	category = "luv-laser-engraver-recipes",
	energy_required = 30 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "americium-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-5-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "nand-memory-wafer", amount = 16 },
	}
}
   
   
   
---NAND MEMORY CHIP
create_item{
	name = "nand-memory-chip",
	category = "hv-cutting-machine-recipes",
	energy_required = HV_SPEED * 45,
	ingredients = {
		{ type = "item", name = "nand-memory-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 13.5 },
	},
	results = {
		{ type = "item", name = "nand-memory-chip", amount = 32 },
	}
}
   
   
   
---VINYL ACETATE
create_recipe{
	recipe_name = "vinyl-acetate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 9,
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 100 },
		{ type = "fluid", name = "acetic-acid", amount = 100 },
		{ type = "fluid", name = "ethylene", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "vinyl-acetate", amount = 100 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	main_product = "vinyl-acetate"
}

   
   
---POLYVINYL ACETATE
create_recipe{
	recipe_name = "polyvinyl-acetate",
	category = "lv-chemical-reactor-recipes",
	energy_required = 56,
	ingredients = {
		{ type = "fluid", name = "oxygen", amount = 700 },
		{ type = "fluid", name = "vinyl-acetate", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "polyvinyl-acetate", amount = 150 },
	}
}



---POLYPHENYLENE SULFIDE
create_item{
	name = "sodium-sulfide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "sodium", amount = 2 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	results = {
		{ type = "item", name = "sodium-sulfide", amount = 3 },
	}
}
create_recipe{
	recipe_name = "dichlorobenzene",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "fluid", name = "chlorine", amount = 400 },
		{ type = "fluid", name = "benzene", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "dichlorobenzene", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
	},
	main_product = "dichlorobenzene"
}
create_recipe{
	recipe_name = "polyphenylene-sulfide",
	category = "hv-chemical-reactor-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "sodium-sulfide", amount = 3 },
		{ type = "fluid", name = "dichlorobenzene", amount = 100 },
		{ type = "fluid", name = "oxygen", amount = 800 },
	},
	results = {
		{ type = "fluid", name = "polyphenylene-sulfide", amount = 150 },
		{ type = "item", name = "salt", amount = 4 },
	},
	main_product = "polyphenylene-sulfide"
}
create_item{
	name = "polyphenylene-sulfide-sheet",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "fluid", name = "polyphenylene-sulfide", amount = 14.4 },
	}
}
create_item{
	name = "thin-polyphenylene-sulfide-sheet",
	category = "lv-bending-machine-recipes",
	energy_required = 0.45,
	ingredients = {
		{ type = "item", name = "polyphenylene-sulfide-sheet", amount = 1 },
	},
	results = {
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
	}
}



---NIOBIUM TITANIUM CABLE
create_item{
	name = "niobium-titanium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "niobium-titanium-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 7.2 },
		},
	results = {
		{ type = "item", name = "niobium-titanium-cable", amount = 1 },
	}
}



---LAPOTRONIC SUPERCAPACITOR
create_item{
	name = "lapotronic-supercapacitor-controller",
	ingredients = {
		{ type = "item", name = "lapotron-crystal", amount = 4 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "lapotronic-supercapacitor-casing", amount = 1 },
	}
}
create_item{
	name = "lapotronic-supercapacitor",
	ingredients = {
		{ type = "item", name = "lapotronic-supercapacitor-controller", amount = 1 },
		{ type = "item", name = "lapotronic-capacitor-iv", amount = 27 },
		{ type = "item", name = "lapotronic-supercapacitor-casing", amount = 46 },
		{ type = "item", name = "borosilicate-glass-block", amount = 73 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "iv-dynamo-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 1 },
	},
	stack_size = 10,
--	place_result = "lapotronic-super-capacitor"
}
create_item{
	name = "lapotronic-supercapacitor-casing",
	ingredients = {
		{ type = "item", name = "tantalum-plate", amount = 4 },
		{ type = "item", name = "long-tungstensteel-rod", amount = 2 },
		{ type = "item", name = "tungstensteel-frame", amount = 2 },
		{ type = "item", name = "lapis-lazuli-block", amount = 1 },
	}
}
create_item{
	name = "lapotronic-capacitor-iv",
	ingredients = {
		{ type = "item", name = "lapotronic-energy-orb", amount = 1 },
		{ type = "item", name = "lapis-screw", amount = 4 },
		{ type = "item", name = "lapis-plate", amount = 4 },
	}
}



-------------------------
---NAQUADAH PROCESSING---
-------------------------

---FLUOROANTIMONIC ACID
create_recipe{
	recipe_name = "ether",
	category = "mv-chemical-reactor-recipes",
	energy_required = 51,
	ingredients = {
		{ type = "fluid", name = "ethanol", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "ether", amount = 50 },
		{ type = "fluid", name = "diluted-sulfuric-acid", amount = 150 },
	},
	main_product = "ether"
}
create_recipe{
	recipe_name = "antimony-trichloride-solution",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "antimony", amount = 1 },
		{ type = "fluid", name = "ether", amount = 100 },
		{ type = "fluid", name = "chlorine", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "antimony-trichloride-solution", amount = 100 },
	}
}
create_recipe{
	recipe_name = "antimony-pentachloride-solution",
	category = "hv-chemical-reactor-recipes",
	energy_required = 36,
	ingredients = {
		{ type = "fluid", name = "antimony-trichloride-solution", amount = 100 },
		{ type = "fluid", name = "chlorine", amount = 200 },
		},
	results = {
		{ type = "fluid", name = "antimony-pentachloride-solution", amount = 100 },
	}
}
create_recipe{
	recipe_name = "antimony-pentachloride",
	category = "mv-distillation-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "fluid", name = "antimony-pentachloride-solution", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "antimony-pentachloride", amount = 100 },
		{ type = "fluid", name = "ether", amount = 100 },
	},
	main_product = "antimony-pentachloride"
}
create_recipe{
	recipe_name = "antimony-pentafluoride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 21,
	ingredients = {
		{ type = "fluid", name = "antimony-pentachloride", amount = 100 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 500 },
	},
	results = {
		{ type = "fluid", name = "antimony-pentafluoride", amount = 100 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 500 },
	},
	main_product = "antimony-pentafluoride"
}
create_recipe{
	recipe_name = "fluoroantimonic-acid",
	category = "ev-chemical-reactor-recipes",
	energy_required = 336,
	ingredients = {
		{ type = "fluid", name = "antimony-pentafluoride", amount = 100 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "fluoroantimonic-acid", amount = 100 },
	}
}    



---LOW QUALITY NAQUADAH EMULSION
create_item{
	name = "titanium-trifluoride",
	recipe_name = "low-quality-naquadah-emulsion",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "naquadah-oxide-mixture", amount = 1 },
		{ type = "fluid", name = "fluoroantimonic-acid", amount = 150 },
	},
	results = {
		{ type = "item", name = "titanium-trifluoride", amount = 2 },
		{ type = "fluid", name = "low-quality-naquadah-emulsion", amount = 100 },
	},
	main_product = "low-quality-naquadah-emulsion"
} 
create_recipe{
	recipe_name = "titanium-trifluoride-processing",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "titanium-trifluoride", amount = 4 },
		{ type = "fluid", name = "hydrogen", amount = 300 },
	},
	results = {
		{ type = "item", name = "hot-titanium-ingot", amount = 1 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 300 },
	},
	main_product = "hot-titanium-ingot"
}
create_item{
	name = "gallium-hydroxide",
	recipe_name = "low-quality-naquadah-solution",
	category = "ev-centrifuge-recipes",
	energy_required = 400,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 27 },
		{ type = "fluid", name = "low-quality-naquadah-emulsion", amount = 1000 },
	},
	results = {
		{ type = "item", name = "gallium-hydroxide", amount = 110, probability = 0.625 },
		{ type = "item", name = "antimony", amount = 15 },
		{ type = "fluid", name = "low-quality-naquadah-solution", amount = 900 },
	},
	main_product = "low-quality-naquadah-solution"
}
create_recipe{
	recipe_name = "naquadah-adamantium-solution",
	category = "ev-chemical-reactor-recipes",
	energy_required = 1600,
	ingredients = {
		{ type = "fluid", name = "p507", amount = 400 },
		{ type = "fluid", name = "low-quality-naquadah-solution", amount = 3600 },
	},
	results = {
		{ type = "fluid", name = "naquadah-adamantium-solution", amount = 3000 },
		{ type = "fluid", name = "fluorine-rich-waste-liquid", amount = 1000 },
	},
	main_product = "naquadah-adamantium-solution"
}
create_item{
	name = "fluorspar",
	recipe_name = "fluorine-rich-waste-liquid-processing",
	category = "mv-chemical-reactor-recipes",
	energy_required = 100,
	ingredients = {
		{ type = "item", name = "quicklime", amount = 40 },
		{ type = "fluid", name = "fluorine-rich-waste-liquid", amount = 150 },
	},
	results = {
		{ type = "item", name = "fluorspar", amount = 60 },
		{ type = "fluid", name = "waste-liquid", amount = 100 },
	},
	main_product = "fluorspar"
}
create_recipe{
	recipe_name = "waste-liquid-processing",
	category = "hv-tall-distillation-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "fluid", name = "waste-liquid", amount = 1000 },
	},
	results = {
		{ type = "item", name = "chromium-dust", amount = 3 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 500 },
		{ type = "fluid", name = "salt-water", amount = 300 },
		{ type = "fluid", name = "phenol", amount = 200 },
	},
	main_product = "chromium-dust"
}
create_recipe{
	recipe_name = "fluorspar-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 1.9,
	ingredients = {
		{ type = "item", name = "fluorspar", amount = 3 },
	},
	results = {
		{ type = "item", name = "calcium", amount = 1 },
		{ type = "fluid", name = "fluorine", amount = 200 },
	},
	main_product = "fluorine"
}
create_item{ skip_recipe = true,
	name = "adamantine-dust",
	subgroup = "subgroup-neutron-activator-recipes"
}
create_item{
	name = "concentrated-enriched-naquadah-sludge",
	recipe_name = "naquadah-rich-solution",
	category = "neutron-activator-recipes",
	energy_required = 5,
	ingredients = {
			{ type = "fluid", name = "naquadah-adamantium-solution", amount = 300 },
		},
	results = {
			{ type = "item", name = "adamantine-dust", amount = 4 },
			{ type = "item", name = "naquadah-oxide-mixture", amount = 2 },
			{ type = "item", name = "concentrated-enriched-naquadah-sludge", amount = 1 },
			{ type = "fluid", name = "naquadah-rich-solution", amount = 200 },
		},
	main_product = "naquadah-rich-solution"
}
create_item{
	name = "naquadahine-dust",
	recipe_name = "naquadah-rich-solution",
	category = "mv-autoclave-recipes",
	energy_required = 100,
	ingredients = {
			{ type = "item", name = "sodium-hydroxide", amount = 27 },
			{ type = "fluid", name = "naquadah-rich-solution", amount = 500 },
		},
	results = {
			{ type = "item", name = "naquadahine-dust", amount = 30 },
			{ type = "fluid", name = "p507", amount = 100 },
		},
	main_product = "naquadahine-dust"
}
create_item{
	name = "hot-naquadah-ingot",
	category = "iv-electric-blast-furnace-recipes",
	energy_required = 32,
	ingredients = {
		{ type = "item", name = "naquadahine-dust", amount = 3 },
		{ type = "item", name = "carbon", amount = 1 },
	},
	results = {
		{ type = "item", name = "hot-naquadah-ingot", amount = 30 },
		{ type = "fluid", name = "carbon-dioxide", amount = 100 },
	},
	main_product = "hot-naquadah-ingot"
}
create_item{
	name = "naquadah-ingot",
	category = "ev-vacuum-freezer-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "hot-naquadah-ingot", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 50 }
	},
	results = {
		{ type = "item", name = "naquadah-ingot", amount = 1 },
		{ type = "fluid", name = "helium", amount = 25 }
	},
	main_product = "naquadah-ingot"
}
create_item{
	name = "naquadah-dust",
	category = "ev-chemical-reactor-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "naquadahine-dust", amount = 3 },
		{ type = "item", name = "sodium", amount = 4 },
	},
	results = {
		{ type = "item", name = "naquadah-dust", amount = 1 },
		{ type = "item", name = "sodium-oxide", amount = 6 },
	},
	main_product = "naquadah-dust"
}
create_item{
	name = "sodium-oxide",
	recipe_name = "sodium-oxide-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "sodium-oxide", amount = 3 },
		},
	results = {
		{ type = "item", name = "sodium", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	main_product = "sodium"
}    
create_item{ skip_recipe = true,
	name = "low-quality-naquadria-sulphate",
	subgroup = "subgroup-neutron-activator-recipes"
}
create_item{
	name = "enriched-naquadah-sulphate",
	category = "neutron-activator-recipes",
	energy_required = 6,
	ingredients = {
		{ type = "item", name = "concentrated-enriched-naquadah-sludge", amount = 16 },
	},
	results = {
		{ type = "item", name = "enriched-naquadah-sulphate", amount = 165 },
		{ type = "item", name = "sodium-sulfate", amount = 140 },
		{ type = "item", name = "low-quality-naquadria-sulphate", amount = 2 },
	},
	main_product = "enriched-naquadah-sulphate"
}
create_item{
	name = "sodium-sulfate",
	recipe_name = "sodium-sulfate-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 2.3,
	ingredients = {
		{ type = "item", name = "sodium-sulfate", amount = 7 },
	},
	results = {
		{ type = "item", name = "sulfur", amount = 1 },
		{ type = "item", name = "sodium", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 400 },
	},
	main_product = "sodium"
}
create_item{
	name = "hot-enriched-naquadah-ingot",
	category = "iv-electric-blast-furnace-recipes",
	energy_required = 80,
	ingredients = {
		{ type = "item", name = "enriched-naquadah-sulphate", amount = 11 },
		{ type = "item", name = "zinc-dust", amount = 2 },
	},
	results = {
		{ type = "item", name = "hot-enriched-naquadah-ingot", amount = 1 },
		{ type = "item", name = "zinc-sulfate", amount = 12 },
	},
	main_product = "hot-enriched-naquadah-ingot"
}
create_item{
	name = "enriched-naquadah-ingot",
	category = "ev-vacuum-freezer-recipes",
	energy_required = 60,
	ingredients = {
		{ type = "item", name = "hot-enriched-naquadah-ingot", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 50 }
	},
	results = {
		{ type = "item", name = "enriched-naquadah-ingot", amount = 1 },
		{ type = "fluid", name = "helium", amount = 25 }
	},
	main_product = "enriched-naquadah-ingot"
}
create_item{
	name = "enriched-naquadah-dust",
	category = "mv-electrolyzer-recipes",
	energy_required = 4.6,
	ingredients = {
		{ type = "item", name = "enriched-naquadah-sulphate", amount = 11 },
	},
	results = {
		{ type = "item", name = "enriched-naquadah-dust", amount = 1 },
		{ type = "item", name = "sulfur", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 800 },
	},
	main_product = "enriched-naquadah-dust"
}



--- NAQUADRIAH PROCESSING   
create_recipe{
	recipe_name = "low-quality-naquadria-sulphate-solution",
	category = "ev-chemical-reactor-recipes",
	energy_required = 200,
	ingredients = {
		{ type = "item", name = "low-quality-naquadria-sulphate", amount = 3 },
		{ type = "fluid", name = "p507", amount = 50 },
		{ type = "fluid", name = "water", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "low-quality-naquadria-sulphate-solution", amount = 350 },
	}
}
create_item{
	name = "enriched-naquadah-oxide-mixture",
	recipe_name = "low-quality-naquadria-sulphate-distillation",
	category = "iv-tall-distillation-recipes",
	energy_required = 400,
	ingredients = {
			{ type = "fluid", name = "low-quality-naquadria-sulphate-solution", amount = 700 },
		},
	results = {
			{ type = "fluid", name = "diluted-sulfuric-acid", amount = 1200 },
			{ type = "fluid", name = "p507", amount = 100 },
			{ type = "fluid", name = "naquadria-rich-solution", amount = 540 },
			{ type = "item", name = "enriched-naquadah-oxide-mixture", amount = 1 },
		},
	main_product = "naquadria-rich-solution"
}
create_item{
	name = "naquadria-sulphate",
	category = "neutron-activator-recipes",
	energy_required = 5,
	ingredients = {
			{ type = "fluid", name = "naquadria-rich-solution", amount = 900 },
		},
	results = {
			{ type = "item", name = "naquadria-sulphate", amount = 44 },
			{ type = "item", name = "low-quality-naquadria-sulphate", amount = 6 },
		},
	main_product = "naquadria-sulphate"
}
create_item{
	name = "naquadria-dust",
	category = "mv-electrolyzer-recipes",
	energy_required = 4.6,
	ingredients = {
		{ type = "item", name = "naquadria-sulphate", amount = 11 },
	},
	results = {
		{ type = "item", name = "naquadria-dust", amount = 1 },
		{ type = "item", name = "sulfur", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 800 },
	},
	main_product = "naquadria-dust"
}
create_item{
	name = "hot-naquadria-ingot",
	category = "zpm-electric-blast-furnace-recipes",
	energy_required = 320,
	ingredients = {
		{ type = "item", name = "naquadria-sulphate", amount = 11 },
		{ type = "item", name = "magnesium", amount = 2 },
	},
	results = {
		{ type = "item", name = "hot-naquadria-ingot", amount = 1 },
		{ type = "item", name = "magnesium-sulphate", amount = 12 },
	},
	main_product = "hot-naquadria-ingot"
}
create_item{
	name = "magnesium-sulphate",
	recipe_name = "magnesium-sulphate-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "magnesium-sulphate", amount = 6 },
		},
	results = {
		{ type = "item", name = "magnesium", amount = 1 },
		{ type = "item", name = "sulfur", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 400 },
	},
	main_product = "magnesium"
}
create_item{
	name = "naquadria-ingot",
	category = "luv-vacuum-freezer-recipes",
	energy_required = 320,
	ingredients = {
		{ type = "item", name = "hot-naquadria-ingot", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 50 }
	},
	results = {
		{ type = "item", name = "naquadria-ingot", amount = 1 },
		{ type = "fluid", name = "helium", amount = 25 }
	},
	main_product = "naquadria-ingot"
}



--- TRINIUM PROCESSING
create_item{
	name = "trinium-sulphate",
	recipe_name = "low-quality-naquadria-sulphate",
	category = "ev-chemical-reactor-recipes",
	energy_required = 160,
	ingredients = {
		{ type = "item", name = "enriched-naquadah-oxide-mixture", amount = 4 },
		{ type = "fluid", name = "p507", amount = 100 },
		{ type = "fluid", name = "sulfuric-acid", amount = 1800 },
	},
	results = {
		{ type = "item", name = "naquadah-oxide-mixture", amount = 1 },
		{ type = "item", name = "trinium-sulphate", amount = 1 },
		{ type = "fluid", name = "enriched-naquadah-rich-solution", amount = 400 },
		{ type = "fluid", name = "waste-liquid", amount = 100 },
	},
	main_product = "enriched-naquadah-rich-solution"
}
create_item{
	name = "trinium-dust",
	category = "hv-chemical-reactor-recipes",
	energy_required = 24,
	ingredients = {
		{ type = "item", name = "trinium-sulphate", amount = 6 },
		{ type = "fluid", name = "hydrogen", amount = 200 },
	},
	results = {
		{ type = "item", name = "trinium-dust", amount = 1 },
		{ type = "fluid", name = "sulfuric-acid", amount = 100 },
	},
	main_product = "trinium-dust"
}
create_item{
	name = "concentrated-enriched-naquadah-sludge",
	category = "hv-autoclave-recipes",
	energy_required = 50,
	ingredients = {
		{ type = "item", name = "sodium-hydroxide", amount = 6 },
		{ type = "fluid", name = "enriched-naquadah-rich-solution", amount = 250 },
	},
	results = {
		{ type = "item", name = "concentrated-enriched-naquadah-sludge", amount = 2 },
		{ type = "fluid", name = "p507", amount = 62.5 },
	},
	main_product = "concentrated-enriched-naquadah-sludge"
}



---HOT TRINIUM INGOT
create_item{
	name = "hot-trinium-ingot",
	category = "luv-electric-blast-furnace-recipes",
	energy_required = 1072,
	ingredients = {
		{ type = "item", name = "trinium-dust", amount = 1 },
		{ type = "fluid", name = "argon", amount = 5 }
	}
}
create_item{
	name = "trinium-ingot",
	category = "iv-vacuum-freezer-recipes",
	energy_required = 240,
	ingredients = {
		{ type = "item", name = "hot-trinium-ingot", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 50 }
	},
	results = {
		{ type = "item", name = "trinium-ingot", amount = 1 },
		{ type = "fluid", name = "helium", amount = 25 }
	},
	main_product = "trinium-ingot"
}



---OSMIRIDIUM DUST
create_item{
	name = "osmiridium-dust",
	category = "luv-mixer-recipes",
	energy_required = 480,
	ingredients = {
		{ type = "item", name = "osmium-dust", amount = 1 },
		{ type = "item", name = "iridium-dust", amount = 3 },
	},
	results = {
		{ type = "item", name = "osmiridium-dust", amount = 4 }
	}
}


   
---ADAMANTIUM DUST   
create_item{
	name = "adamantium-dust",
	category = "mv-electrolyzer-recipes",
	energy_required = 5.5,
	ingredients = {
		{ type = "item", name = "adamantine-dust", amount = 5 },
	},
	results = {
		{ type = "item", name = "adamantium-dust", amount = 2 },
		{ type = "fluid", name = "oxygen", amount = 300 }
	},
	main_product = "adamantium-dust"
}   



---LAPOTRONIC ENERGY ORB (IV BATTERY)
create_item{
	name = "lapotronic-energy-orb",
	category = "ev-circuit-assembler-recipes",
	energy_required = EV_SPEED * 25.6,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 4 },
		{ type = "item", name = "engraved-lapotron-chip", amount = 24 },
		{ type = "item", name = "nano-cpu-chip", amount = 2 },
		{ type = "item", name = "fine-platinum-wire", amount = 16 },
		{ type = "item", name = "platinum-plate", amount = 8 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
	}
}
create_item{
	name = "engraved-lapotron-chip",
	category = "hv-laser-engraver-recipes",
	energy_required = HV_SPEED * 45,
	ingredients = {
		{ type = "item", name = "lapotron-crystal", amount = 1 },
	},
	results = {
		{ type = "item", name = "engraved-lapotron-chip", amount = 3 },
	}
}   
   
   
--[[ 
   
-------------------------
---   DRAGON SLAYING  ---
-------------------------

create_recipe{
    recipe_name = "microminer-dragon-silver",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "block-of-silver", amount = 64 },
    }
}
create_recipe{
    recipe_name = "microminer-dragon-gold",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "block-of-gold", amount = 64 },
    }
}
create_recipe{
    recipe_name = "microminer-dragon-ruby",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "block-of-ruby", amount = 64 },
    }
}
create_recipe{
    recipe_name = "microminer-dragon-diamond",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "block-of-diamond", amount = 64 },
    }
}
create_item{
	name = "dragon-scale",
    recipe_name = "microminer-dragon-scales",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "dragon-scale", amount = 16 },
    }
}
create_item{
	name = "dragon-heart",
    recipe_name = "microminer-dragon-heart",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "dragon-heart", amount = 1 },
    }
}
create_item{
	name = "dragon-breath",
    recipe_name = "microminer-dragon-breath",
    category = "lv-assembling-machine-recipes",	
    energy_required = IV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "dragon-lair-loot", amount = 1 }
    },
    results = {
		{type = "item", name = "dragon-breath", amount = 64 },
    }
}

    
  
---DIGESTER
create_item{
	name = "iv-digester",
	ingredients = {
		{ type = "item", name = "digester-controller", amount = 1 },
		{ type = "item", name = "robust-tungstensteel-casing", amount = 52 },
		{ type = "item", name = "heat-proof-casing", amount = 16 },
		{ type = "item", name = "cupronickel-coil-block", amount = 16 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 9 },
		{ type = "item", name = "ev-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
    }
}
create_item{
	name = "digester-controller",
	ingredients = {
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "super-tank-iv", amount = 2 },
		{ type = "item", name = "iv-motor", amount = 4 },
		{ type = "item", name = "iv-pump", amount = 4 },
		{ type = "item", name = "titanium-rotor", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "fluid", name = "ptfe", amount = 144 },
    }
}  
 



---DISSOLUTION TANK
create_item{
	name = "iv-dissolution-tank",
	ingredients = {
		{ type = "item", name = "dissolution-tank-controller", amount = 1 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 42 },
		{ type = "item", name = "tinted-industrial-glass", amount = 24 },
		{ type = "item", name = "heat-proof-casing", amount = 9 },
		{ type = "item", name = "lv-machine-casing", amount = 5 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
    }
}
create_item{
	name = "dissolution-tank-controller",
	ingredients = {
		{ type = "item", name = "iv-machine-hull", amount = 1 },
		{ type = "item", name = "super-tank-iii", amount = 2 },
		{ type = "item", name = "ev-motor", amount = 4 },
		{ type = "item", name = "ev-pump", amount = 2 },
		{ type = "item", name = "vibrant-alloy-rotor", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "fluid", name = "ptfe", amount = 72 },
    }
}
   
  
  
--- MONAZITE LINE
create_recipe{
	recipe_name = "muddy-monazite-rare-earth-solution",
	category = "digester-recipes",
	energy_required = 20 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "crushed-monazite", amount = 2 },
		{ type = "fluid", name = "nitric-acid", amount = 70 },
    },
	results = {
		{ type = "item", name = "silicon-dioxide", amount = 1 },
		{ type = "fluid", name = "muddy-monazite-rare-earth-solution", amount = 40 },
	},
	main_product = "muddy-monazite-rare-earth-solution"
}
create_recipe{
	recipe_name = "muddy-bastnasite-rare-earth-solution",
	category = "digester-recipes",
	energy_required = 20 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "crushed-bastnasite", amount = 2 },
		{ type = "fluid", name = "nitric-acid", amount = 70 },
    },
	results = {
		{ type = "item", name = "silicon-dioxide", amount = 1 },
		{ type = "fluid", name = "muddy-bastnasite-rare-earth-solution", amount = 40 },
	},
	main_product = "muddy-bastnasite-rare-earth-solution"
}
create_recipe{
	recipe_name = "steam-cracked-bastnasite-mud",
	category = "hv-cracker-recipes",
	energy_required = 12 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "muddy-bastnasite-rare-earth-solution", amount = 40 },
		{ type = "fluid", name = "steam", amount = 40 },
	},
	results = {
		{ type = "fluid", name = "steam-cracked-bastnasite-mud", amount = 80 },
	}
}
create_recipe{
	recipe_name = "conditioned-bastnasite-mud",
	category = "mv-mixer-recipes",
	energy_required = 40 * MV_SPEED,
	ingredients = {
		{ type = "fluid", name = "steam-cracked-bastnasite-mud", amount = 100 },
		{ type = "fluid", name = "sodium-fluorosilicate", amount = 32 },
	},
	results = {
		{ type = "fluid", name = "conditioned-bastnasite-mud", amount = 132 },
	}
}
create_recipe{
	recipe_name = "diluted-monazite-rare-earth-mud",
		category = "dissolution-tank-recipes",
		energy_required = 405 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "saltpeter", amount = 9 },
			{ type = "fluid", name = "muddy-monazite-rare-earth-solution", amount = 900 },
			{ type = "fluid", name = "water", amount = 9000 },
		},
		results = {
			{ type = "item", name = "hafnia-zirconia-blend", amount = 4 },
			{ type = "item", name = "thorianite", amount = 9 },
			{ type = "item", name = "monazite", amount = 2 },
			{ type = "fluid", name = "diluted-monazite-rare-earth-mud", amount = 9900 },
		},
		main_product = "diluted-monazite-rare-earth-mud"
}
create_item{ skip_recipe = true,
	name = "hafnia-zirconia-blend",
	subgroup = "subgroup-monazite-line"
}
create_item{ skip_recipe = true,
	name = "thorianite",
	subgroup = "subgroup-monazite-line"
}
create_recipe{
	recipe_name = "diluted-monazite-rare-earth-mud",
		category = "dissolution-tank-recipes",
		energy_required = 405 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "saltpeter", amount = 9 },
			{ type = "fluid", name = "muddy-monazite-rare-earth-solution", amount = 900 },
			{ type = "fluid", name = "water", amount = 9000 },
		},
		results = {
			{ type = "item", name = "hafnia-zirconia-blend", amount = 4 },
			{ type = "item", name = "thorianite", amount = 9 },
			{ type = "item", name = "monazite", amount = 2 },
			{ type = "fluid", name = "diluted-monazite-rare-earth-mud", amount = 9900 },
		},
		main_product = "diluted-monazite-rare-earth-mud"
}
create_item{ skip_recipe = true,
	name = "gangue",
	subgroup = "subgroup-monazite-line"
}
create_recipe{
	recipe_name = "diluted-bastnasite-mud",
	category = "dissolution-tank-recipes",
	energy_required = 50 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "saltpeter", amount = 1 },
		{ type = "fluid", name = "muddy-monazite-rare-earth-solution", amount = 100 },
		{ type = "fluid", name = "water", amount = 1000 },
	},
	results = {
		{ type = "item", name = "gangue", amount = 9 },
		{ type = "fluid", name = "diluted-bastnasite-mud", amount = 1100 },
	},
	main_product = "diluted-bastnasite-mud"
}


	
---HAFNIUM
create_item{ skip_recipe = true,
	name = "hafnia",
	subgroup = "subgroup-monazite-line"
}
create_item{ skip_recipe = true,
	name = "zirconia",
	subgroup = "subgroup-monazite-line"
}
create_recipe{
	recipe_name = "hafnia-zirconia-blend-centrifuging",
	category = "ev-centrifuge-recipes",
	subgroup = "subgroup-monazite-line"
	enabled = false,
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "hafnia-zirconia-blend", amount = 1 },
	},
	results = {
		{ type = "item", name = "hafnia", amount = 3 },
		{ type = "item", name = "zirconia", amount = 3 },
	},
	main_product = "hafnia"
}
create_recipe{
	recipe_name = "hafnium-tetrachloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15 * LV_SPEED,
	subgroup = "subgroup-monazite-line"
	ingredients = {
		{ type = "item", name = "hafnia", amount = 1 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 400 },
	},
	results = {
		{ type = "item", name = "hafnium-tetrachloride", amount = 5 },
		{ type = "fluid", name = "water", amount = 200 },
	},
	main_product = "hafnium-tetrachloride"
}
create_item{
	name = "hafnium-tetrachloride",
	category = "lv-chemical-reactor-recipes",
	subgroup = "subgroup-monazite-line"
	energy_required = 15 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "hafnia", amount = 1 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 400 },
	},
	results = {
		{ type = "item", name = "hafnium-tetrachloride", amount = 5 },
		{ type = "fluid", name = "water", amount = 200 },
	},
	main_product = "hafnium-tetrachloride"
}
create_recipe{
	recipe_name = "hafnium-tetrachloride-solution",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10 * LV_SPEED,
	subgroup = "subgroup-monazite-line"
	ingredients = {
		{ type = "item", name = "hafnium-tetrachloride", amount = 5 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "hafnium-tetrachloride-solution", amount = 100 },
	}
}
create_item{
	name = "low-purity-hafnium",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "fluid", name = "hafnium-tetrachloride-solution", amount = 100 },
		{ type = "item", name = "magnesium", amount = 2 },
	},
	results = {
		{ type = "item", name = "low-purity-hafnium", amount = 1 },
		{ type = "item", name = "magnesium-chloride", amount = 6 },
	}
}
create_item{
	name = "hafnium-iodine",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "low-purity-hafnium", amount = 1 },
		{ type = "fluid", name = "iodine", amount = 400 },
	},
	results = {
		{ type = "item", name = "hafnium-iodine", amount = 5 },
	}
}
create_item{
	name = "hot-hafnium-ingot",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "hafnium-iodine", amount = 5 },
	},
	results = {
		{ type = "item", name = "hot-hafnium-ingot", amount = 5 },
		{ type = "fluid", name = "iodine", amount = 400 },
	},
	main_product = "hot-hafnium-ingot"
}



--ZIRCONIA
create_item{
	name = "zirconia-tetrachloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "zirconia", amount = 1 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 400 },
	},
	results = {
		{ type = "item", name = "zirconium-tetrachloride", amount = 5 },
		{ type = "fluid", name = "water", amount = 200 },
	},
	main_product = "zirconium-tetrachloride"
}
create_recipe{
	recipe_name = "zirconium-tetrachloride-solution",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "zirconium-tetrachloride", amount = 5 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "zirconium-tetrachloride-solution", amount = 100 },
	}
}
create_item{
	name = "hot-zirconium-ingot",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "fluid", name = "zirconium-tetrachloride-solution", amount = 100 },
		{ type = "item", name = "magnesium", amount = 2 },
	},
	results = {
		{ type = "item", name = "hot-zirconium-ingot", amount = 1 },
		{ type = "item", name = "magnesium-chloride", amount = 6 },
	},
	main_product = "hot-zirconium-ingot"
}
create_item{
	name = "zirconium-ingot",
	category = "mv-vacuum-freezer-recipes",
	energy_required = 0.05 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "hot-zirconium-ingot", amount = 1 },
	}
}



---THORIANITE
create_recipe{
	recipe_name = "thorianite-processing",
	category = "lv-chemical-reactor-recipes",
	energy_required = 50 * LV_SPEED,
	ingredients = {
		{ type = "item", name = "thorianite", amount = 9 },
		{ type = "item", name = "aluminium-dust", amount = 4 },
	},
	results = {
		{ type = "item", name = "thorium-dust", amount = 3 },
		{ type = "item", name = "alumina", amount = 10 },
	},
	main_product = "thorium-dust"
}


	
--MONAZITE SULFATE
create_item{ skip_recipe = true,
	name = "monazite-sulfate",
	subgroup = "subgroup-monazite-line"
}
create_item{ skip_recipe = true,
	name = "red-zircon",
	subgroup = "subgroup-monazite-line"
}	
create_recipe{
	recipe_name = "diluted-monazite-rare-earth-mud",
	category = "hv-sifter-recipes",
	energy_required = 20 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "diluted-monazite-rare-earth-mud", amount = 100 },
	},
	results = {
		{ type = "item", name = "monazite-sulfate", amount = 1, probability = 0.9 },
		{ type = "item", name = "silicon-dioxide", amount = 1, probability = 0.75 },
		{ type = "item", name = "rutile-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "ilmenite-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "red-zircon", amount = 1, probability = 0.05 },
	},
	main_product = "monazite-sulfate"
}
create_item {
	name = "zirconium-dust",
	recipe_name = "red-zircon-electrolysis",
	category = "mv-electrolyzer-recipes",
	energy_required = 12.5 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "red-zircon", amount = 6 },
	},
	results = {
		{ type = "item", name = "zirconium-dust", amount = 1 },
		{ type = "item", name = "silicon-dioxide", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 200 },
	},
	main_product = "zirconium-dust"
}
create_recipe{
	recipe_name = "diluted-bastnasite-rare-earth-mud",
	category = "hv-sifter-recipes",
	energy_required = 20 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "diluted-bastnasite-rare-earth-mud", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "filtered-bastnasite-mud", amount = 40 },
		{ type = "item", name = "silicon-dioxide", amount = 1, probability = 0.9 },
		{ type = "item", name = "rutile-dust", amount = 1, probability = 0.75 },
		{ type = "item", name = "ilmenite-dust", amount = 1, probability = 0.05 },
		{ type = "item", name = "red-zircon", amount = 1, probability = 0.1 },
	},
	main_product = "filtered-bastnasite-mud"
}
create_recipe{
	recipe_name = "diluted-monazite-solution",
	category = "hv-mixer-recipes",
	energy_required = 24 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "monazite-sulfate", amount = 1 },
		{ type = "fluid", name = "water", amount = 600 },
	},
	results = {
		{ type = "fluid", name = "diluted-monazite-solution", amount = 700 },
	}
}
create_item{
	name = "acidic-monazite-powder",
	category = "hv-chemical-reactor-recipes",
	enabled = false,
	energy_required = 216 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "diluted-monazite-solution", amount = 900 },
		{ type = "fluid", name = "ammonia-nitrate-solution", amount = 180 },
	},
	results = {
		{ type = "item", name = "acidic-monazite-powder", amount = 3 },
	}
}    

  	{
		type = "recipe",
		name = "monazite-rare-earth-filtrate",
		category = "hv-sifter-recipes",
		enabled = false,
		energy_required = 30 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "acidic-monazite-powder", amount = 1 },
		},
		results = {
			{ type = "item", name = "monazite-rare-earth-filtrate", amount = 1, probability = 0.9 },
			{ type = "item", name = "thorium-phosphate-cake", amount = 1, probability = 0.70 },
		},
		main_product = "monazite-rare-earth-filtrate"
   }, 
    {
		type = "item",
		name = "monazite-rare-earth-filtrate",
		icon = "__Gregtorio__/graphics/icons/monazite-rare-earth-filtrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    }, 
    {
		type = "item",
		name = "thorium-phosphate-cake",
		icon = "__Gregtorio__/graphics/icons/thorium-phosphate-cake.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    }, 	
  	{
		type = "recipe",
		name = "thorium-phosphate-concentrate",
		category = "hv-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 15 * MV_SPEED,
		ingredients = {
			{ type = "item", name = "thorium-phosphate-cake", amount = 1 },
		},
		results = {
			{ type = "item", name = "thorium-phosphate-concentrate", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "thorium-phosphate-concentrate",
		icon = "__Gregtorio__/graphics/icons/thorium-phosphate-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },  
  	{
		type = "recipe",
		name = "thorium-phosphate-concentrate",
		category = "hv-centrifuge-recipes",
		enabled = false,
		energy_required = 10 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "thorium-phosphate-concentrate", amount = 1 },
		},
		results = {
			{ type = "item", name = "thorium-dust", amount = 1 },
			{ type = "item", name = "phosphate", amount = 1 },
		}
   },   
  	{
		type = "recipe",
		name = "neutralized-monazite-rare-earth-filtrate",
		category = "hv-chemical-bath-recipes",
		enabled = false,
		energy_required = 6 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "monazite-rare-earth-filtrate", amount = 1 },
			{ type = "fluid", name = "ammonia-nitrate-solution", amount = 32 },
		},
		results = {
			{ type = "item", name = "neutralized-monazite-rare-earth-filtrate", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "neutralized-monazite-rare-earth-filtrate",
		icon = "__Gregtorio__/graphics/icons/neutralized-monazite-rare-earth-filtrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },   
  	{
		type = "recipe",
		name = "monazite-rare-earth-hydroxide-concentrate",
		category = "hv-sifter-recipes",
		enabled = false,
		energy_required = 40 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "neutralized-monazite-rare-earth-filtrate", amount = 1 },
		},
		results = {
			{ type = "item", name = "monazite-rare-earth-hydroxide-concentrate", amount = 1, probability = 0.9 },
			{ type = "item", name = "uranium-filtrate", amount = 1, probability = 0.5 },
			{ type = "item", name = "uranium-filtrate", amount = 1, probability = 0.4 },
		},
		main_product = "monazite-rare-earth-hydroxide-concentrate"
   },   
    {
		type = "item",
		name = "monazite-rare-earth-hydroxide-concentrate",
		icon = "__Gregtorio__/graphics/icons/monazite-rare-earth-hydroxide-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },  
    {
		type = "item",
		name = "uranium-filtrate",
		icon = "__Gregtorio__/graphics/icons/uranium-filtrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },  	
  	{
		type = "recipe",
		name = "neutralized-monazite-rare-earth-filtrate",
		category = "mv-chemical-bath-recipes",
		enabled = false,
		energy_required = 18 * MV_SPEED,
		ingredients = {
			{ type = "item", name = "uranium-filtrate", amount = 1 },
			{ type = "fluid", name = "hydrofluoric-acid", amount = 10 },
		},
		results = {
			{ type = "item", name = "neutralized-uranium-filtrate", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "neutralized-uranium-filtrate",
		icon = "__Gregtorio__/graphics/icons/neutralized-uranium-filtrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    }, 
  	{
		type = "recipe",
		name = "neutralized-uranium-filtrate-sifting",
		category = "lv-sifter-recipes",
		enabled = false,
		energy_required = 50 * LV_SPEED,
		ingredients = {
			{ type = "item", name = "neutralized-uranium-filtrate-sifting", amount = 1 },
		},
		results = {
			{ type = "item", name = "uranium-dust", amount = 1, probability = 0.45 },
			{ type = "item", name = "uranium-dust", amount = 1, probability = 0.4 },
			{ type = "item", name = "uranium-dust", amount = 1, probability = 0.3 },
			{ type = "item", name = "enriched-uranium-dust", amount = 1, probability = 0.3 },
			{ type = "item", name = "enriched-uranium-dust", amount = 1, probability = 0.25 },
		},
		main_product = "uranium-dust"
   },   
  	{
		type = "recipe",
		name = "dried-monazite-rare-earth-concentrate",
		category = "mv-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 15 * MV_SPEED,
		ingredients = {
			{ type = "item", name = "monazite-rare-earth-hydroxide-concentrate", amount = 1 },
		},
		results = {
			{ type = "item", name = "dried-monazite-rare-earth-concentrate", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "dried-monazite-rare-earth-concentrate",
		icon = "__Gregtorio__/graphics/icons/dried-monazite-rare-earth-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "bastnasite-rare-earth-oxides",
		category = "ev-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 25 * EV_SPEED,
		ingredients = {
			{ type = "fluid", name = "filtered-bastnasite-mud", amount = 100 },
		},
		results = {
			{ type = "item", name = "bastnasite-rare-earth-oxides", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "bastnasite-rare-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/bastnasite-rare-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },	
  	{
		type = "recipe",
		name = "neutralized-monazite-rare-earth-filtrate",
		category = "lv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 10 * LV_SPEED,
		ingredients = {
			{ type = "item", name = "bastnasite-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 50 },
		},
		results = {
			{ type = "item", name = "acid-leached-bastnasite-rare-earth-oxides", amount = 1 },
		}
   },
    {
		type = "item",
		name = "acid-leached-bastnasite-rare-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/acid-leached-bastnasite-rare-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "bastnasite-rare-earth-oxides",
		category = "mv-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 30 * MV_SPEED,
		ingredients = {
			{ type = "item", name = "acid-leached-bastnasite-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 100 },
		},
		results = {
			{ type = "item", name = "roasted-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "fluorine", amount = 1.3 },
		}
   }, 
    {
		type = "item",
		name = "roasted-rare-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/roasted-rare-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "wet-rare-earth-oxides",
		category = "lv-mixer-recipes",
		enabled = false,
		energy_required = 5 * LV_SPEED,
		ingredients = {
			{ type = "item", name = "roasted-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "water", amount = 20 },
		},
		results = {
			{ type = "item", name = "wet-rare-earth-oxides", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "wet-rare-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/wet-rare-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "cerium-oxidised-rare-earth-oxides",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 15 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "roasted-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "fluorine", amount = 400 },
		},
		results = {
			{ type = "item", name = "cerium-oxidised-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "hydrofluoric-acid", amount = 400 },
		}
   }, 
    {
		type = "item",
		name = "cerium-oxidised-rare-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/cerium-oxidised-rare-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "bastnasite-rarer-earth-oxides",
		category = "hv-centrifuge-recipes",
		enabled = false,
		energy_required = 30 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "cerium-oxidised-rare-earth-oxides", amount = 1 },
			{ type = "fluid", name = "fluorine", amount = 400 },
		},
		results = {
			{ type = "item", name = "bastnasite-rarer-earth-oxides", amount = 1 },
			{ type = "item", name = "cerium-dioxide", amount = 1, probability = 0.9 },
		}
   }, 
    {
		type = "item",
		name = "bastnasite-rarer-earth-oxides",
		icon = "__Gregtorio__/graphics/icons/bastnasite-rarer-earth-oxides.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "nitrogenated-bastnasite-rarer-earth-oxides",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 15 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "bastnasite-rarer-earth-oxides", amount = 1 },
			{ type = "fluid", name = "nitric-acid", amount = 40 },
		},
		results = {
			{ type = "fluid", name = "nitrogenated-bastnasite-rarer-earth-oxides", amount = 100 },
		}
   },
  	{
		type = "recipe",
		name = "neutralized-monazite-rare-earth-filtrate",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 25 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "dried-monazite-rare-earth-concentrate", amount = 1 },
			{ type = "fluid", name = "nitric-acid", amount = 50 },
		},
		results = {
			{ type = "fluid", name = "nitrogenated-monazite-rare-earth-concentrate", amount = 100 },
		}
   }, 
  	{
		type = "recipe",
		name = "nitric-leeched-monazite-mixture",
		category = "mv-mixer-recipes",
		enabled = false,
		energy_required = 10 * MV_SPEED,
		ingredients = {
			{ type = "fluid", name = "nitrogenated-monazite-rare-earth-concentrate", amount = 100 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "nitric-leeched-monazite-mixture", amount = 100 },
		}
   },
  	{
		type = "recipe",
		name = "nitric-leeched-monazite-mixture-with-cerium",
		category = "mv-mixer-recipes",
		enabled = false,
		energy_required = 11 * MV_SPEED,
		ingredients = {
			{ type = "fluid", name = "nitrogenated-monazite-rare-earth-concentrate", amount = 100 },
			{ type = "item", name = "cerium-rich-mixture", amount = 3 },
		},
		results = {
			{ type = "fluid", name = "nitric-leeched-monazite-mixture", amount = 200 },
		}
   },
  	{
		type = "recipe",
		name = "nitric-leeched-monazite-mixture",
		category = "hv-sifter-recipes",
		enabled = false,
		energy_required = 20 * HV_SPEED,
		ingredients = {
			{ type = "fluid", name = "nitrogenated-monazite-rare-earth-concentrate", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "nitric-monazite-leeched-concentrate", amount = 100 },
			{ type = "item", name = "cerium-dioxide", amount = 1, probability = 0.11 },
		}
   },
    {
		type = "item",
		name = "cerium-dioxide",
		icon = "__Gregtorio__/graphics/icons/cerium-dioxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },   
  	{
		type = "recipe",
		name = "cooled-monazite-rare-earth-concentrate",
		category = "hv-vacuum-freezer-recipes",
		enabled = false,
		energy_required = 5 * HV_SPEED,
		ingredients = {
			{ type = "fluid", name = "nitric-monazite-leeched-concentrate", amount = 100 },
		},
		results = {
			{ type = "item", name = "cooled-monazite-rare-earth-concentrate", amount = 1 },
		}
   },
    {
		type = "item",
		name = "cooled-monazite-rare-earth-concentrate",
		icon = "__Gregtorio__/graphics/icons/cooled-monazite-rare-earth-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },  
  	{
		type = "recipe",
		name = "cooled-monazite-rare-earth-concentrate",
		category = "ev-electrolyzer-recipes",
		enabled = false,
		energy_required = 30 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "cooled-monazite-rare-earth-concentrate", amount = 1 },
		},
		results = {
			{ type = "item", name = "monazite-rarer-earth-sediment", amount = 1, probability = 0.9 },
			{ type = "item", name = "europium-iii-oxide", amount = 1, probability = 0.05 },
		}
   },
    {
		type = "item",
		name = "europium-iii-oxide",
		icon = "__Gregtorio__/graphics/icons/europium-iii-oxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
    {
		type = "item",
		name = "monazite-rarer-earth-sediment",
		icon = "__Gregtorio__/graphics/icons/monazite-rarer-earth-sediment.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },	
  	{
		type = "recipe",
		name = "dried-monazite-rare-earth-concentrate",
		category = "hv-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 25 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "monazite-rarer-earth-sediment", amount = 1 },
			{ type = "fluid", name = "chlorine", amount = 100 },
		},
		results = {
			{ type = "item", name = "heterogenous-halogenic-monazite-rare-earth-mixture", amount = 1 },
		}
   }, 
    {
		type = "item",
		name = "heterogenous-halogenic-monazite-rare-earth-mixture",
		icon = "__Gregtorio__/graphics/icons/heterogenous-halogenic-monazite-rare-earth-mixture.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },  
   	{
		type = "recipe",
		name = "saturated-monazite-rare-earth",
		category = "hv-mixer-recipes",
		enabled = false,
		energy_required = 10 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "heterogenous-halogenic-monazite-rare-earth-mixture", amount = 1 },
			{ type = "fluid", name = "acetone", amount = 100 },
		},
		results = {
			{ type = "item", name = "saturated-monazite-rare-earth", amount = 1 },
		}
   },
   	{
		type = "recipe",
		name = "bastnasite-rarer-earth-oxide-suspension",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 35 * HV_SPEED,
		ingredients = {
			{ type = "fluid", name = "nitrogenated-bastnasite-rarer-earth-oxides", amount = 100 },
			{ type = "fluid", name = "acetone", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "bastnasite-rarer-earth-oxide-suspension", amount = 100 },
		}
   },
   	{
		type = "recipe",
		name = "bastnasite-rarer-earth-oxide-suspension-centrifuging",
		category = "hv-centrifuge-recipes",
		enabled = false,
		energy_required = 45 * HV_SPEED,
		ingredients = {
			{ type = "fluid", name = "bastnasite-rarer-earth-oxide-suspension", amount = 100 },
		},
		results = {
			{ type = "item", name = "neodymium-rare-earth-concentrate", amount = 1, probability = 0.8 },
			{ type = "item", name = "samaric-rare-earth-concentrate", amount = 1, probability = 0.5 },
			{ type = "fluid", name = "diluted-acetone", amount = 75 },
		}
   },    
    {
		type = "item",
		name = "neodymium-rare-earth-concentrate",
		icon = "__Gregtorio__/graphics/icons/neodymium-rare-earth-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
    {
		type = "item",
		name = "samaric-rare-earth-concentrate",
		icon = "__Gregtorio__/graphics/icons/samaric-rare-earth-concentrate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
   	{
		type = "recipe",
		name = "neodymium-rare-earth-concentrate-reaction",
		category = "ev-chemical-reactor-recipes",
		enabled = false,
		energy_required = 45 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "neodymium-rare-earth-concentrate", amount = 2 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 200 },
		},
		results = {
			{ type = "item", name = "lanthanum-chloride", amount = 1 },
			{ type = "fluid", name = "neodymium-oxide", amount = 75 },
		}
   },    
    {
		type = "item",
		name = "lanthanum-chloride",
		icon = "__Gregtorio__/graphics/icons/lanthanum-chloride.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
    {
		type = "item",
		name = "neodymium-oxide",
		icon = "__Gregtorio__/graphics/icons/neodymium-oxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
   	{
		type = "recipe",
		name = "lanthanum-oxide",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 10 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "lanthanum-chloride", amount = 8 },
			{ type = "fluid", name = "water", amount = 300 },
		},
		results = {
			{ type = "item", name = "lanthanum-oxide", amount = 1 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 600 },
		}
   },    
    {
		type = "item",
		name = "lanthanum-oxide",
		icon = "__Gregtorio__/graphics/icons/lanthanum-oxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
   	{
		type = "recipe",
		name = "flawless-lanthanum-hexaboride",
		category = "iv-autoclave-recipes",
		enabled = false,
		energy_required = 60 * IV_SPEED,
		ingredients = {
			{ type = "item", name = "lanthanum-oxide", amount = 1 },
			{ type = "fluid", name = "boron-trichloride", amount = 800 },
		},
		results = {
			{ type = "item", name = "flawless-lanthanum-hexaboride", amount = 1 },
			{ type = "fluid", name = "boric-acid", amount = 100 },
		}
   },    
    {
		type = "item",
		name = "flawless-lanthanum-hexaboride",
		icon = "__Gregtorio__/graphics/icons/flawless-lanthanum-hexaboride.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
   	{
		type = "recipe",
		name = "saturated-monazite-rare-earth-with-samarium",
		category = "hv-mixer-recipes",
		enabled = false,
		energy_required = 20 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "heterogenous-halogenic-monazite-rare-earth-mixture", amount = 1 },
			{ type = "item", name = "samarium-ore-concentrate", amount = 2 },
			{ type = "fluid", name = "acetone", amount = 100 },
		},
		results = {
			{ type = "item", name = "saturated-monazite-rare-earth", amount = 3 },
		}
   },
    {
		type = "item",
		name = "saturated-monazite-rare-earth",
		icon = "__Gregtorio__/graphics/icons/saturated-monazite-rare-earth.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },   
   	{
		type = "recipe",
		name = "samaric-residue-dust",
		category = "ev-centrifuge-recipes",
		enabled = false,
		energy_required = 157.5 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "saturated-monazite-rare-earth", amount = 4 },
			{ type = "item", name = "samarium-ore-concentrate", amount = 2 },
		},
		results = {
			{ type = "item", name = "samaric-residue-dust", amount = 3 },
			{ type = "fluid", name = "chloromethane", amount = 40 },
		}
   },
    {
		type = "item",
		name = "samaric-residue-dust",
		icon = "__Gregtorio__/graphics/icons/samaric-residue-dust.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },   
   	{
		type = "recipe",
		name = "samaric-residue-dust-sifting",
		category = "ev-sifter-recipes",
		enabled = false,
		energy_required = 6.65 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "samaric-residue-dust", amount = 3 },
		},
		results = {
			{ type = "item", name = "samarium-dust", amount = 3 },
			{ type = "item", name = "gadolinium-dust", amount = 1 },
		}
   },
    {
		type = "item",
		name = "gadolinium-dust",
		icon = "__Gregtorio__/graphics/icons/gadolinium-dust.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },


---EUROPIUM
  	{
		type = "recipe",
		name = "europium-oxide",
		category = "luv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 15 * LUV_SPEED,
		ingredients = {
			{ type = "item", name = "europium-iii-oxide", amount = 5 },
			{ type = "item", name = "europium-dust", amount = 1 },
		},
		results = {
			{ type = "item", name = "europium-oxide", amount = 6 },
		}
   },
    {
		type = "item",
		name = "europium-oxide",
		icon = "__Gregtorio__/graphics/icons/europium-oxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "europium-oxide-electrolysis",
		category = "zpm-electrolyzer-recipes",
		enabled = false,
		energy_required = 15 * ZPM_SPEED,
		ingredients = {
			{ type = "item", name = "europium-oxide", amount = 2 },
		},
		results = {
			{ type = "item", name = "europium-dust", amount = 1 },
			{ type = "fluid", name = "oxygen", amount = 100 },
		}
   },

--CERIUM
  	{
		type = "recipe",
		name = "cerium-chloride",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 15 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "cerium-dioxide", amount = 3 },
			{ type = "fluid", name = "hydrogen", amount = 200 },
			{ type = "fluid", name = "ammonium-chloride", amount = 200 },
		},
		results = {
			{ type = "fluid", name = "cerium-chloride", amount = 100 },
			{ type = "fluid", name = "steam", amount = 200 },
			{ type = "fluid", name = "ammonia", amount = 300 },
		}
   },
    {
		type = "item",
		name = "cerium-chloride",
		icon = "__Gregtorio__/graphics/icons/cerium-chloride.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    }, 
  	{
		type = "recipe",
		name = "cerium-oxalate",
		category = "hv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 15 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "cerium-chloride", amount = 8 },
			{ type = "fluid", name = "oxalate", amount = 300 },
		},
		results = {
			{ type = "fluid", name = "cerium-oxalate", amount = 100 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 600 },
		}
   },
    {
		type = "item",
		name = "cerium-oxalate",
		icon = "__Gregtorio__/graphics/icons/cerium-oxalate.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "cerium-iii-oxide",
		category = "hv-electric-blast-furnace-recipes",
		enabled = false,
		energy_required = 10 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "cerium-oxalate", amount = 5 },
			{ type = "item", name = "carbon", amount = 3 },
		},
		results = {
			{ type = "item", name = "cerium-iii-oxide", amount = 5 },
			{ type = "fluid", name = "carbon-monoxide", amount = 900 },
		}
   },
    {
		type = "item",
		name = "cerium-iii-oxide",
		icon = "__Gregtorio__/graphics/icons/cerium-iii-oxide.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
  	{
		type = "recipe",
		name = "cerium-dust",
		category = "mv-electrolyzer-recipes",
		enabled = false,
		energy_required = 3.5 * MV_SPEED,
		ingredients = {
			{ type = "item", name = "cerium-iii-oxide", amount = 5 },
		},
		results = {
			{ type = "item", name = "cerium-dust", amount = 2 },
			{ type = "fluid", name = "oxygen", amount = 300 },
		}
   },
    {
		type = "item",
		name = "cerium-dust",
		icon = "__Gregtorio__/graphics/icons/cerium-dust.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[wood]-a[plank]",
		stack_size = 64
    },
	
	]]--