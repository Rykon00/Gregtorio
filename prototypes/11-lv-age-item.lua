--- FLUID / POWER LOGIC:
--- 100 Factorio Fluid = 1 Bucket in Minecraft (Arbitrary). Basically divide mB by 10.
--- 1 EU/t = 1kW (Arbitrary). Basically multiply EU/t by 20 to get kW. To find MJ from EU value of fuel, divide by 20,000.
--- Using Monifactory values here...
--- 1 Small Coal Boiler should produce 1.2 Steam per second.
--- 1 Large Bronze Boiler should produce 160 Steam per second.
--- 1 Steam Alloy Smelter should consume 3.2 Steam per second.
--- 1 Steam Compressor should consume 0.4 Steam per second.
--- 1 LV Steam Turbine should produce 32kW per tick, or 640kW per second.
--- LV Steam Turbine is effectiveness is 0.85
--- So 1 LV Steam Turbine should consume 15.094 Steam per second, or 0.2516 Steam per tick
--- One Large Bronze Boiler powers 10.6 LV Steam Turbines


--- INERT GAS REQUIREMENETS (Nitrogen 100, Helium 50, Argon 50, Neon 10, Radon 10, Krypton 10, Xenon 10, Oganesson 10)
--- MV:  Nitrogen
--- HV:  Nitrogen
--- EV:  Helium
--- IV:  Argon
--- LUV: Neon
--- ZPM: Radon
--- UV:  Krypton
--- UHV: Xenon
--- UEV: Xenon
--- UIV: Oganesson
--- UMV: Oganesson
--- UXV: Oganesson


---TABLE OF CONTENTS [GENERALIZED]
--- Anything new ingredients required for an item comes above it
--- COMPONENTS (Motor, Piston, Pump, Conveyor Belt, Robot Arm, Sensor, Emitter, Field Generator)
--- CASINGS (Machine Casing, Machine Hull, Energy Hatch, Dynamo, EBF Coil)
--- Items required for the usual singleblocks
--- New Circuits



--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

------------------------
---   LV COMPONENTS  ---
------------------------  

---MAGNETIC IRON ROD
create_item{
	name = "magnetic-iron-rod",
	category = "lv-polarizer-recipes",
	energy_required = 3.2,
	ingredients = {
		{ type = "item", name = "iron-stick", amount = 1 },
	}
}
create_recipe{
	recipe_name = "magnetic-iron-rod-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "iron-stick", amount = 1 },
		{ type = "item", name = "redstone-dust", amount = 4 },
	},
	results = {
		{ type = "item", name = "magnetic-iron-rod", amount = 1 },
	}
}
create_item{
	name = "long-magnetic-iron-rod",
	category = "lv-polarizer-recipes",
	energy_required = 6.4,
	ingredients = {
		{ type = "item", name = "long-iron-rod", amount = 1 },
	}
}


 
---TIN PLATE
create_recipe{
	recipe_name = "tin-plate-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
			{ type = "item", name = "tin-ingot", amount = 2 },
		},
	results = {
		{ type = "item", name = "tin-plate", amount = 1 },
	}
}
create_recipe{
	recipe_name = "tin-plate-forge-hammer",
	category = "lv-forge-hammer-recipes",
	energy_required = TIN_SPEED,
	ingredients = {
		{ type = "item", name = "tin-ingot", amount = 3 },
	},
	results = {
		{ type = "item", name = "tin-plate", amount = 2 },
	}
}
   
   
   
---TIN WIRE
create_recipe{
	recipe_name = "tin-wire-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-plate", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-wire", amount = 1 },
	}
}



---LIQUID RUBBER   
create_recipe{
	recipe_name = "liquid-rubber",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "raw-rubber-pulp", amount = 9 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "liquid-rubber", amount = 129.6 },
	}
}   
   
   
	
---TIN CABLE
create_item{
	name = "tin-cable",
	energy_required = 5,
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "tin-wire", amount = 1 },
		{ type = "fluid", name = "liquid-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "tin-cable", amount = 1 },
	}
}
create_recipe{
	recipe_name = "tin-cable-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-wire", amount = 1 },
		{ type = "item", name = "rubber-sheet", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-cable", amount = 1 },
	}
}
create_recipe{
	name = "tin-cable-silicone",
	category = "lv-assembling-machine-recipes",
	subgroup = "subgroup-circuit-parts-assembler",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "tin-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "tin-cable", amount = 4 },
	},
}
create_item{
	name = "tin-cable-16x",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "tin-wire-16x", amount = 1 },
		{ type = "fluid", name = "silicone-rubber", amount = 36 },
	}
}



---LV MOTOR
create_item{
	name = "lv-motor",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "iron-stick", amount = 2 },
		{ type = "item", name = "magnetic-iron-rod", amount = 1 },
		{ type = "item", name = "copper-wire", amount = 4 },
		{ type = "item", name = "tin-cable", amount = 2 },
	}
}
create_recipe{
	recipe_name = "lv-motor-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 6 },
		{ type = "item", name = "long-iron-rod", amount = 48 },
		{ type = "item", name = "long-magnetic-iron-rod", amount = 24 },
		{ type = "item", name = "copper-wire-16x", amount = 12 },
	},
	results = {
		{ type = "item", name = "lv-motor", amount = 64 },
	},
}
   


---STEEL GEAR
create_recipe{
	recipe_name = "steel-gear-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 1 },
		{ type = "item", name = "steel-rod", amount = 2 },
	},
	results = {
		{ type = "item", name = "steel-gear", amount = 1 },
	}
}



---LV PISTON
create_item{
	name = "lv-piston",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 3 },
		{ type = "item", name = "steel-rod", amount = 2 },
		{ type = "item", name = "steel-gear", amount = 1 },
		{ type = "item", name = "lv-motor", amount = 1 },
		{ type = "item", name = "tin-cable", amount = 2 },
	}
}
create_recipe{
	recipe_name = "lv-piston-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 6 },
		{ type = "item", name = "large-steel-gear", amount = 12 },
		{ type = "item", name = "lv-motor", amount = 48 },
		{ type = "item", name = "long-steel-rod", amount = 48 },
		{ type = "item", name = "dense-steel-plate", amount = 16 },
	},
	results = {
		{ type = "item", name = "lv-piston", amount = 64 },
	},
}     
   
   
   
---TIN ROD
create_recipe{
	recipe_name = "tin-rod-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-rod", amount = 1 },
	}
}
   
   
   
---TIN BOLT
 create_recipe{
	recipe_name = "tin-bolt-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-bolt", amount = 2 },
	}
}  
   
   
   
---TIN SCREW
create_recipe{
	recipe_name = "tin-screw-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-bolt", amount = 2 },
	},
	results = {
		{ type = "item", name = "tin-screw", amount = 1 },
	}
}
   
   
   
---TIN RING
create_recipe{
	recipe_name = "tin-ring-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-ring", amount = 1 },
	}
}

   
   
---TIN ROTOR
create_recipe{
	recipe_name = "tin-rotor-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "tin-plate", amount = 4 },
		{ type = "item", name = "tin-ring", amount = 1 },
		{ type = "item", name = "tin-screw", amount = 1 },
	},
	results = {
		{ type = "item", name = "tin-rotor", amount = 1 },
	}
}
   


---RUBBER RING
create_item{
	name = "rubber-ring",
	category = "lv-fluid-solidifier-recipes",
	ingredients = {
		{ type = "fluid", name = "liquid-rubber", amount = 3.6 },
	}
}
create_recipe{
	recipe_name = "rubber-ring-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "rubber-sheet", amount = 1 },
	},
	results = {
		{ type = "item", name = "rubber-ring", amount = 1 },
	}
}
   
   

---LV PUMP
create_item{
	name = "lv-pump",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "lv-motor", amount = 1 },
		{ type = "item", name = "tin-rotor", amount = 1 },
		{ type = "item", name = "pipe", amount = 1 },
		{ type = "item", name = "tin-screw", amount = 1 },
		{ type = "item", name = "rubber-ring", amount = 2 },
		{ type = "item", name = "tin-cable", amount = 1 },
	}
}
create_recipe{
	recipe_name = "lv-pump-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 3 },
		{ type = "item", name = "pipe", amount = 48 },
		{ type = "item", name = "lv-motor", amount = 96 },
		{ type = "item", name = "tin-rotor", amount = 48 },
		{ type = "item", name = "tin-screw", amount = 48 },
		{ type = "fluid", name = "silicone-rubber", amount = 345.6 },
	},
	results = {
		{ type = "item", name = "lv-pump", amount = 64 },
	},
}


  
---LV CONVEYOR MODULE
create_item{
	name = "lv-conveyor-module",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "lv-motor", amount = 2 },
		{ type = "item", name = "tin-cable", amount = 1 },
		{ type = "item", name = "rubber-sheet", amount = 6 },
	},
}
create_recipe{
	recipe_name = "lv-conveyor-module-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 3 },
		{ type = "item", name = "lv-motor", amount = 96 },
		{ type = "fluid", name = "silicone-rubber", amount = 4147.2 },
	},
	results = {
		{ type = "item", name = "lv-conveyor-module", amount = 64 },
	},
}



---LV CIRCUIT WRAP  
create_item{
	name = "lv-circuit-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "electronic-circuit", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}


  
---LV ROBOT ARM
create_item{
	name = "lv-robot-arm",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "lv-motor", amount = 2 },
		{ type = "item", name = "steel-rod", amount = 2 },
		{ type = "item", name = "lv-piston", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 1 },
		{ type = "item", name = "tin-cable", amount = 3 },
	},
}
create_recipe{
	recipe_name = "lv-robot-arm-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 9 },
		{ type = "item", name = "lv-motor", amount = 96 },
		{ type = "item", name = "lv-piston", amount = 48 },
		{ type = "item", name = "long-steel-rod", amount = 48 },
		{ type = "item", name = "lv-circuit-wrap", amount = 3 },
	},
	results = {
		{ type = "item", name = "lv-robot-arm", amount = 64 },
	},
}



---BRASS DUST
create_recipe{
	recipe_name = "zinc-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = ZINC_SPEED,
	ingredients = {
		{type = "item", name = "zinc-ingot", amount = 1 },
    },
	results = {
		{type = "item", name = "zinc-dust", amount = 1 },
    }
}
create_item{
	name = "brass-dust",
	category = "lv-mixer-recipes",
	energy_required = 2,
	ingredients = {
		{type = "item", name = "copper-dust", amount = 3 },
		{type = "item", name = "zinc-dust", amount = 1 },
    },
	results = {
		{type = "item", name = "brass-dust", amount = 4 },
    }
} 
   

   
---BRASS INGOT
create_item{
	name = "brass-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 10,
	ingredients = {
      {type = "item", name = "copper-ingot", amount = 3 },
      {type = "item", name = "zinc-ingot", amount = 1 },
    },
	results = {
		{type = "item", name = "brass-ingot", amount = 4 },
    }
}
create_recipe{
	recipe_name = "brass-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
      {type = "item", name = "brass-dust", amount = 1 },
    },
	results = {
		{type = "item", name = "brass-ingot", amount = 1 },
    }
}
create_recipe{
	recipe_name = "brass-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
      {type = "item", name = "brass-dust", amount = 64 },
    },
	results = {
      {type = "item", name = "brass-ingot", amount = 64 },
    }
}
  

   
---LV SENSOR
create_item{
	name = "lv-sensor",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "brass-rod", amount = 1 },
		{ type = "item", name = "certus-quartz", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 1 },
	}
}
create_recipe{
	recipe_name = "lv-sensor-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "dense-steel-plate", amount = 21 },
		{ type = "item", name = "lv-circuit-wrap", amount = 3 },
		{ type = "item", name = "long-brass-rod", amount = 96 },
		{ type = "item", name = "certus-quartz", amount = 48 },
	},
	results = {
		{ type = "item", name = "lv-sensor", amount = 64 },
	},
}   
   
   
   
---LV EMITTER
create_item{
	name = "lv-emitter",
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "tin-cable", amount = 2 },
		{ type = "item", name = "brass-rod", amount = 4 },
		{ type = "item", name = "certus-quartz", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 2 },
	}
}
create_recipe{
	recipe_name = "lv-emitter-coal",
	category = "uv-coal-recipes",
	energy_required = 48,
	ingredients = {
		{ type = "item", name = "tin-cable-16x", amount = 6 },
		{ type = "item", name = "dense-steel-plate", amount = 24 },
		{ type = "item", name = "long-brass-rod", amount = 24 },
		{ type = "item", name = "lv-circuit-wrap", amount = 3 },
		{ type = "item", name = "certus-quartz", amount = 48 },
	},
	results = {
		{ type = "item", name = "lv-emitter", amount = 64 },
	},
}  



---GLOWSTONE DUST
create_item{
	name = "glowstone-dust",
	category = "lv-mixer-recipes",
	energy_required = 4,
	ingredients = {
		{type = "item", name = "gold-dust", amount = 1},
		{type = "item", name = "tricalcium-phosphate", amount = 1}
    },
	results = {
		{type = "item", name = "glowstone-dust", amount = 2}
    }
}



---ENERGETIC ALLOY INGOT
create_item{
	name = "energetic-alloy-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 20,
	ingredients = {
		{type = "item", name = "gold-ingot", amount = 1},
		{type = "item", name = "redstone-dust", amount = 1},
		{type = "item", name = "glowstone-dust", amount = 1},
    }
}
create_item{
	name = "energetic-alloy-wire-16x",
	ingredients = {
		{ type = "item", name = "energetic-alloy-wire", amount = 16 },
	},
}
  
  
  
---LV FIELD GENERATOR
create_item{
	name = "lv-field-generator",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	subgroup="subgroup-lv-components",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 2 },
		{ type = "item", name = "electronic-circuit", amount = 2 },
		{ type = "item", name = "energetic-alloy-wire", amount = 16 },
		{ type = "item", name = "diamond", amount = 1 },
	}
} 
create_recipe{
	recipe_name = "lv-field-generator-coal",
	category = "uv-coal-recipes",
	energy_required = 1440,
	ingredients = {
		{ type = "item", name = "energetic-alloy-wire-16x", amount = 48 },
		{ type = "item", name = "dense-steel-plate", amount = 12 },
		{ type = "item", name = "lv-circuit-wrap", amount = 6 },
		{ type = "item", name = "diamond", amount = 48 },
	},
	results = {
		{ type = "item", name = "lv-field-generator", amount = 64 },
	},
} 



---LV MACHINE CASING
create_item{
	name = "lv-machine-casing",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 8 },
	}
}



---LV MACHINE HULL
create_item{
	name = "lv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "tin-cable", amount = 2 },
		{ type = "item", name = "lv-machine-casing", amount = 1 },
		{ type = "fluid", name = "polyethylene", amount = 28.8 },
	}
}
create_recipe{
	recipe_name = "lv-machine-hull-crafting-table",
	category = "crafting-or-assembling-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "iron-plate", amount = 2 },
		{ type = "item", name = "steel-plate", amount = 1 },
		{ type = "item", name = "tin-cable", amount = 2 },
		{ type = "item", name = "lv-machine-casing", amount = 1 },
	},
	results = {
		{ type = "item", name = "lv-machine-hull", amount = 1 },
	}
}  

   

---LOW VOLTAGE COIL
create_item{
	name = "low-voltage-coil",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "magnetic-iron-rod", amount = 1 },
		{ type = "item", name = "fine-steel-wire", amount = 16 },
	}
}
   
   
   
---LV ENERGY HATCH
create_item{
	name = "lv-energy-hatch",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "lv-machine-hull", amount = 1 },
		{ type = "item", name = "tin-cable", amount = 2 },
		{ type = "item", name = "low-voltage-coil", amount = 1 },
	}
}  
  
  
  
---CUPRONICKEL INGOT
create_item{
	name = "cupronickel-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 5,
	ingredients = {
      {type = "item", name = "copper-ingot", amount = 1},
      {type = "item", name = "nickel-ingot", amount = 1},
    },
	results = {
      {type = "item", name = "cupronickel-ingot", amount = 2},
    }
}
   
   
   
---MOLTEN TIN
create_recipe{
	recipe_name = "molten-tin",
	category = "lv-extractor-recipes",
	energy_required = 1.2,
	ingredients = {
		{ type = "item", name = "tin-ingot", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-tin", amount = 14.4 },
	}
}   


   
---CUPRONICKEL COIL BLOCK
create_item{
	name = "cupronickel-coil-block",
	category = "lv-assembling-machine-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "cupronickel-wire", amount = 16 },
		{ type = "item", name = "bronze-foil", amount = 8 },
		{ type = "fluid", name = "molten-tin", amount = 14.4 },
	}
}   
   
   
   
---COBALT BRASS
create_recipe{
	recipe_name = "lapis-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = 1.4,
	ingredients = {
		{type = "item", name = "lapis-lazuli", amount = 1},
    },
	results = {
		{type = "item", name = "lapis-dust", amount = 1}
    }
}
create_recipe{
	recipe_name = "diamond-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = 2.8,
	ingredients = {
		{type = "item", name = "diamond", amount = 1},
    },
	results = {
		{type = "item", name = "diamond-dust", amount = 1}
    }
}
create_item{
	name = "cobalt-brass-dust",
	category = "lv-mixer-recipes",
	energy_required = 45,
	ingredients = {
		{ type = "item", name = "brass-dust", amount = 7 },
		{ type = "item", name = "aluminium-dust", amount = 1 },
		{ type = "item", name = "cobalt-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "cobalt-brass-dust", amount = 9 },
	}
}
create_item{
	name = "cobalt-brass-ingot",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "cobalt-brass-dust", amount = 1 },
	}
}
create_recipe{
	recipe_name = "cobalt-brass-ingot-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
			{ type = "item", name = "cobalt-brass-dust", amount = 64 },
		},
	results = {
			{ type = "item", name = "cobalt-brass-ingot", amount = 64 },
		}
}
create_recipe{
	recipe_name = "large-cobalt-brass-gear-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "cobalt-brass-plate", amount = 4 },
		{ type = "item", name = "cobalt-brass-rod", amount = 4 },
	},
	results = {
		{ type = "item", name = "large-cobalt-brass-gear", amount = 1 }
	}
}
create_item{
	name = "diamond-sawblade",
	ingredients = {
		{ type = "item", name = "large-cobalt-brass-gear", amount = 1 },
		{ type = "item", name = "diamond-dust", amount = 1 },
	}
}



---SILICON CHAIN
create_item{
	name = "silicon-dioxide",
	category = "lv-centrifuge-recipes",
	energy_required = 1.5,
	ingredients = {
		{ type = "item", name = "flint-dust", amount = 1 },
	}
}
create_item{
	name = "raw-silicon",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "silicon-dioxide", amount = 3 },
		{ type = "item", name = "magnesium", amount = 2 },
	},
	results = {
		{ type = "item", name = "raw-silicon", amount = 1 },
		{ type = "item", name = "magnesia", amount = 4 },
	},
	main_product = "raw-silicon"
}
create_item{
	name = "magnesia",
	recipe_name = "magnesia-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "magnesia", amount = 2 }
	},
	results = {
		{ type = "item", name = "magnesium", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	main_product = "magnesium"
} 
create_recipe{
	recipe_name = "silicon-tetrachloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "item", name = "raw-silicon", amount = 1 },
		{ type = "fluid", name = "chlorine", amount = 400 },
	},
	results = {
		{ type = "fluid", name = "silicon-tetrachloride", amount = 100 },
	}
}
create_item{
	name = "poly-si-dust",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "sodium", amount = 4 },
		{ type = "fluid", name = "silicon-tetrachloride", amount = 100 },
	},
	results = {
		{ type = "item", name = "poly-si-dust", amount = 1 },
		{ type = "item", name = "salt", amount = 8 },
	},
	main_product = "poly-si-dust"
}



---MONOCRYSTALINE SILICON BOULE
create_item{
	name = "small-pile-of-gallium-arsenide",
	category = "lv-mixer-recipes",
	energy_required = 4,
	ingredients = {
		{ type = "item", name = "gallium", amount = 1 },
		{ type = "item", name = "arsenic", amount = 1 },
	},
	results = {
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 8 },
	}
}   
create_item{
	name = "monocrystaline-silicon-boule",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 225 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 32 },
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 1 },
		{ type = "fluid", name = "nitrogen", amount = 1000 },
	}
}



---PRELOADING ALL BOULES
create_item{ skip_recipe = true,
	name = "phosphorus-doped-monocrystaline-silicon-boule",
	subgroup = "subgroup-hv-electric-blast-furnace-recipes"
}
create_item{ skip_recipe = true,
	name = "naquadah-doped-monocrystaline-silicon-boule",
	subgroup = "subgroup-ev-electric-blast-furnace-recipes"
}
create_item{ skip_recipe = true,
	name = "europium-doped-monocrystaline-silicon-boule",
	subgroup = "subgroup-iv-electric-blast-furnace-recipes"
}
create_item{ skip_recipe = true,
	name = "americium-doped-monocrystaline-silicon-boule",
	subgroup = "subgroup-luv-electric-blast-furnace-recipes"
}
   


---PRELOADING ALL WAFERS
create_item{ 
	name = "silicon-wafer",
	category = "lv-cutting-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "monocrystaline-silicon-boule", amount = 1 },
	},
	results = {
		{ type = "item", name = "silicon-wafer", amount = 16 },
		{ type = "item", name = "poly-si-dust", amount = 4 },
	},
	main_product = "silicon-wafer"
}
create_item{ 
	name = "phosphorus-doped-wafer",
	category = "mv-cutting-machine-recipes",
	energy_required = 40 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-monocrystaline-silicon-boule", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 7.5 },
	},
	results = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 32 },
		{ type = "item", name = "poly-si-dust", amount = 8 },
	},
	main_product = "phosphorus-doped-wafer"
}
create_item{ 
	name = "naquadah-doped-wafer",
	category = "hv-cutting-machine-recipes",
	energy_required = 80 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-monocrystaline-silicon-boule", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 },
	},
	results = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 64 },
		{ type = "item", name = "poly-si-dust", amount = 16 },
	},
	main_product = "naquadah-doped-wafer"
}
create_item{ 
	name = "europium-doped-wafer",
	category = "ev-cutting-machine-recipes",
	energy_required = 60 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "europium-doped-monocrystaline-silicon-boule", amount = 1 },
		{ type = "fluid", name = "grade-4-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "europium-doped-wafer", amount = 96 },
		{ type = "item", name = "poly-si-dust", amount = 32 },
	},
	main_product = "europium-doped-wafer"
}
create_item{ 
	name = "americium-doped-wafer",
	category = "iv-cutting-machine-recipes",
	energy_required = 80 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "americium-doped-monocrystaline-silicon-boule", amount = 1 },
		{ type = "fluid", name = "grade-6-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "americium-doped-wafer", amount = 128 },
		{ type = "item", name = "poly-si-dust", amount = 64 },
	},
	main_product = "americium-doped-wafer"
}  



---INTEGRATED LOGIC CIRCUIT WAFER
create_item{
	name = "ilc-wafer",
	recipe_name = "ilc-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 60 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 },
	}
}
create_recipe{
	recipe_name = "ilc-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 45 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "phosphorus-doped-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "ilc-wafer", amount = 4 },
	}
}
create_recipe{
	recipe_name = "ilc-wafer-nd",
	category = "ev-laser-engraver-recipes",
	energy_required = 15 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-doped-wafer", amount = 1 },
		{ type = "fluid", name = "grade-2-water", amount = 10 },
	},
	results = {
		{ type = "item", name = "ilc-wafer", amount = 8 },
	}
}
   
   
   
---ILC CHIP
create_item{
	name = "ilc-chip",
	category = "lv-cutting-machine-recipes",
	energy_required = 45 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "ilc-wafer", amount = 1 },
	},
	results = {
		{ type = "item", name = "ilc-chip", amount = 8 },
	}
}
     
   
   
---PHENOLIC CIRCUIT BOARD
create_item{
	name = "phenolic-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "resin-circuit-board", amount = 1 },
		{ type = "fluid", name = "phenol", amount = 10 },
	}
}



---PHENOLIC PRINTED CIRCUIT BOARD
create_item{
	name = "phenolic-printed-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "phenolic-circuit-board", amount = 1 },
		{ type = "item", name = "silver-foil", amount = 4 },
		{ type = "fluid", name = "iron-iii-chloride", amount = 10 },
	}
}
create_recipe{
	recipe_name = "phenolic-printed-circuit-board-advanced",
	category = "lv-chemical-reactor-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "wood-pulp", amount = 8 },
		{ type = "item", name = "silver-foil", amount = 16 },
		{ type = "fluid", name = "advanced-glue", amount = 40 },
	},
	results = {
		{ type = "item", name = "phenolic-printed-circuit-board", amount = 8 },
	},
}
 
   

---MOLTEN GLASS   
create_recipe{
	recipe_name = "molten-glass",
	category = "lv-extractor-recipes",
	ingredients = {
		{ type = "item", name = "glass-dust", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "molten-glass", amount = 14.4 },
	}
}
  


---DIODE
create_item{
	name = "diode",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 },
		{ type = "item", name = "fine-annealed-copper-wire", amount = 4 },
		{ type = "fluid", name = "polyethylene", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "diode", amount = 4 },
	}
}
create_recipe{
	recipe_name = "primitive-diode",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "small-pile-of-gallium-arsenide", amount = 1 },
		{ type = "item", name = "fine-copper-wire", amount = 4 },
		{ type = "fluid", name = "molten-glass", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "diode", amount = 1 },
	}
} 	


  
---GOOD ELECTRONIC CIRCUIT
create_item{
	name = "advanced-circuit",
	category = "crafting-table-recipes",
	icon = ICON_PATH .. "mv-circuit.png",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 3 },
		{ type = "item", name = "diode", amount = 2 },
		{ type = "item", name = "phenolic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "copper-wire", amount = 2 },
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 1 },
	}
}
create_recipe{
	recipe_name = "good-electronic-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "electronic-circuit", amount = 2 },
		{ type = "item", name = "diode", amount = 2 },
		{ type = "item", name = "phenolic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "copper-wire", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 1 },
	}
}
  
  
  
---HYDROCHLORIC ACID 
create_recipe{
	recipe_name = "hydrochloric-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{ type = "fluid", name = "chlorine", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "hydrochloric-acid", amount = 100 },
	}
}



---IRON 3 CHLORIDE 
create_recipe{
	recipe_name = "iron-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = IRON_SPEED,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 1},
    },
	results = {
		{type = "item", name = "iron-dust", amount = 1}
    }
}
create_recipe{
	recipe_name = "iron-iii-chloride",
	category = "lv-chemical-reactor-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "fluid", name = "hydrochloric-acid", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "iron-iii-chloride", amount = 100 },
		{ type = "fluid", name = "hydrogen", amount = 300 },
	},
	main_product = "iron-iii-chloride"
}   

     
   
---ANNEALED COPPER INGOT
create_item{
	name = "annealed-copper-ingot",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 3.15,
	ingredients = {
		{ type = "item", name = "copper-ingot", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 6.3 },
	},
	results = {
		{ type = "item", name = "annealed-copper-ingot", amount = 1 },
	}
}
   

  
--- BASIC ELECTRONIC CIRCUIT  
create_recipe{
	recipe_name = "basic-electronic-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "resin-printed-circuit-board", amount = 1 },
		{ type = "item", name = "resistor", amount = 2 },
		{ type = "item", name = "red-alloy-wire", amount = 2 },
		{ type = "item", name = "vacuum-tube", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
    },
	results = {
		{ type = "item", name = "electronic-circuit", amount = 1 },
    }
}  
  
  
  
---INVAR INGOT
create_item{
	name = "invar-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 8,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 2},
		{type = "item", name = "nickel-ingot", amount = 1},
    },
	results = {
		{type = "item", name = "invar-ingot", amount = 3},
    }
}
create_item{
	name = "invar-dust",
	category = "lv-mixer-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "iron-dust", amount = 2 },
		{ type = "item", name = "nickel-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "invar-dust", amount = 3 },
	}
}
create_recipe{
	recipe_name = "invar-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
      {type = "item", name = "invar-dust", amount = 1 },
    },
	results = {
		{type = "item", name = "invar-ingot", amount = 1 },
    }
}
create_recipe{
	recipe_name = "invar-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
      {type = "item", name = "invar-dust", amount = 64 },
    },
	results = {
      {type = "item", name = "invar-ingot", amount = 64 },
    }
}


  
---HEAT PROOF CASING
create_item{
	name = "heat-proof-casing",
	ingredients = {
		{type = "item", name = "invar-plate", amount = 6},
		{type = "item", name = "invar-frame", amount = 1},
    }
}

  

---ELECTROLYZE WATER
create_recipe{
	recipe_name = "water-electrolysis",
	category = "lv-electrolyzer-recipes",
	energy_required = 75,
	ingredients = {
		{type = "fluid", name = "water", amount = 100}
    },
	results = {
		{type = "fluid", name = "hydrogen", amount = 200},
		{type = "fluid", name = "oxygen", amount = 100},
    },
	main_product = "hydrogen"
}

  
  
---BIOMASS
create_item{
	name = "wheat",
	recipe_name = "growing-wheat",
	category = "greenhouse-recipes",
	energy_required = 30,
	ingredients = {
		{type = "fluid", name = "water", amount = 2400},
    },
	results = {
		{type = "item", name = "wheat", amount = 64},
    }
}
create_item{
	name = "plant-ball",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
		{type = "item", name = "wheat", amount = 8}
    }
}
create_item{
	name = "plant-mass",
	category = "lv-macerator-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "plant-ball", amount = 2}
    },
	results = {
		{type = "item", name = "plant-mass", amount = 2},
		{type = "item", name = "plant-mass", amount = 1, probability = 0.75 },
    },
	main_product = "plant-mass"
}
create_item{
	name = "bio-chaff",
	category = "lv-centrifuge-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "plant-mass", amount = 1}
    },
	results = {
		{type = "item", name = "bio-chaff", amount = 1}
    }
}
create_recipe{
	recipe_name = "biomass",
	category = "pyrolyse-oven-recipes",
	energy_required = 45,
	ingredients = {
		{type = "item", name = "bio-chaff", amount = 4},
		{type = "fluid", name = "water", amount = 400},
    },
	results = {
		{type = "fluid", name = "biomass", amount = 500},
    }
}  
  
  
  
---BIOMASS TO ETHANOL
create_recipe{
	recipe_name = "biomass-to-ethanol",
	category = "lv-distillation-recipes",
	energy_required = 6.4,
	ingredients = {
		{type = "fluid", name = "biomass", amount = 100}
    },
	results = {
		{type = "fluid", name = "ethanol", amount = 60},
    }
}



---ETHANOL TO ETHYLENE
create_recipe{
	recipe_name = "ethanol-to-ethylene",
	category = "lv-chemical-reactor-recipes",
	energy_required = 120,
	ingredients = {
		{type = "fluid", name = "ethanol", amount = 100},
		{type = "fluid", name = "sulfuric-acid", amount = 100},
    },
	results = {
		{type = "fluid", name = "ethylene", amount = 100},
		{type = "fluid", name = "diluted-sulfuric-acid", amount = 100},
    },
	main_product = "ethylene"
}



---SODIUM HYDROXIDE
create_item{
	name = "sodium-hydroxide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "sodium", amount = 1 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = {
		{ type = "item", name = "sodium-hydroxide", amount = 3 },
		{ type = "fluid", name = "hydrogen", amount = 100 },
	},
	main_product = "sodium-hydroxide"
}



---HYDROGEN SULFIDE
create_recipe{
	recipe_name = "hydrogen-sulfide",
	category = "lv-chemical-reactor-recipes",
	energy_required = 3,
	ingredients = {
		{type = "item", name = "sulfur", amount = 1},
		{type = "fluid", name = "hydrogen", amount = 200},
    },
	results = {
		{type = "fluid", name = "hydrogen-sulfide", amount = 100},
    }
}

  
  
---SULFURIC ACID
create_recipe{
	recipe_name = "sulfuric-acid",
	category = "lv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
		{type = "fluid", name = "hydrogen-sulfide", amount = 100},
		{type = "fluid", name = "oxygen", amount = 400},
    },
	results = {
		{type = "fluid", name = "sulfuric-acid", amount = 100},
    }
}
  
  
  
---SULFURIC ACID CONCENTRATION
create_recipe{
	recipe_name = "sulfuric-acid-concentration",
	category = "lv-distillation-recipes",
	energy_required = 12,
	ingredients = {
		{type = "fluid", name = "diluted-sulfuric-acid", amount = 60},
    },
	results = {
		{type = "fluid", name = "sulfuric-acid", amount = 40},
    }
}



---ETHYLENE TO POLYETHYLENE
create_recipe{
	recipe_name = "ethylene-to-polyethylene",
	category = "lv-chemical-reactor-recipes",
	energy_required = 8,
	ingredients = {
		{type = "fluid", name = "ethylene", amount = 14.4 },
		{type = "fluid", name = "oxygen", amount = 100 },
    },
	results = {
		{type = "fluid", name = "polyethylene", amount = 21.6 },
    }
}  
  


---SILICON INGOT
create_item{
	name = "silicon-ingot",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 127.2,
	ingredients = {
		{ type = "item", name = "poly-si-dust", amount = 1 }
	}
}
   
   
   
---TRANSISTOR
create_item{
	name = "transistor",
	category = "lv-assembling-machine-recipes",
	energy_required = 16,
	subgroup = "subgroup-circuit-parts-assembler",
	ingredients = {
		{ type = "item", name = "fine-tin-wire", amount = 6 },
		{ type = "item", name = "silicon-plate", amount = 1 },
		{ type = "fluid", name = "polyethylene", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "transistor", amount = 8 },
	}
}
   
   
   
---RAM WAFER
create_item{
	name = "ram-wafer",
	recipe_name = "ram-wafer-sw",
	category = "mv-laser-engraver-recipes",
	energy_required = 90,
	ingredients = {
		{ type = "item", name = "silicon-wafer", amount = 1 }
	}
}
create_recipe{
	recipe_name = "ram-wafer-pd",
	category = "hv-laser-engraver-recipes",
	energy_required = 100,
	ingredients = {
			{ type = "item", name = "phosphorus-doped-wafer", amount = 1 }
		},
	results = {
			{ type = "item", name = "ram-wafer", amount = 4 }
		}
}
create_recipe{
	recipe_name = "ram-wafer-qd",
	category = "ev-laser-engraver-recipes",
	energy_required = 80,
	ingredients = {
			{ type = "item", name = "naquadah-doped-wafer", amount = 1 }
		},
	results = {
			{ type = "item", name = "ram-wafer", amount = 8 }
		}
}
   
   
   
---RAM CHIP
create_item{
	name = "ram-chip",
	category = "lv-cutting-machine-recipes",
	energy_required = 90,
	ingredients = {
		{ type = "item", name = "ram-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 6.7 },
	},
	results = {
		{ type = "item", name = "ram-chip", amount = 32 },
	}
}

   

---SOLDERING ALLOY
create_recipe{
	recipe_name = "lead-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = LEAD_SPEED,
	ingredients = {
		{type = "item", name = "lead-ingot", amount = 1},
    },
	results = {
		{type = "item", name = "lead-dust", amount = 1}
    }
}
create_item{
	name = "soldering-alloy-dust",
	category = "lv-mixer-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "tin-dust", amount = 6 },
		{ type = "item", name = "lead-dust", amount = 3 },
		{ type = "item", name = "antimony", amount = 1 },
	},
	results = {
		{ type = "item", name = "soldering-alloy-dust", amount = 10 },
	}
}
create_recipe{
	recipe_name = "soldering-alloy",
	category = "lv-extractor-recipes",
	energy_required = 7.25,
	ingredients = {
		{ type = "item", name = "soldering-alloy-dust", amount = 1 },
	},
	results = {
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
	}
}  


   
---INTEGRATED CIRCUIT
create_recipe{
	recipe_name = "basic-integrated-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "resin-printed-circuit-board", amount = 1 },
		{ type = "item", name = "ilc-chip", amount = 1 },
		{ type = "item", name = "resistor", amount = 2 },
		{ type = "item", name = "diode", amount = 2 },
		{ type = "item", name = "fine-copper-wire", amount = 2 },
		{ type = "item", name = "tin-bolt", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "electronic-circuit", amount = 2 }
	}
}


   
---GOOD INTEGRATED CIRCUIT
create_recipe{
	recipe_name = "good-integrated-circuit",
	category = "lv-circuit-assembler-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "phenolic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "electronic-circuit", amount = 2 },
		{ type = "item", name = "resistor", amount = 2 },
		{ type = "item", name = "diode", amount = 2 },
		{ type = "item", name = "fine-gold-wire", amount = 4 },
		{ type = "item", name = "silver-bolt", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "advanced-circuit", amount = 2 },
	}
} 



---ELECTRUM INGOT
create_recipe{
	recipe_name = "gold-dust-macerator",
	category = "smelting",
	energy_required = GOLD_SPEED,
	ingredients = {
		{type = "item", name = "gold-ingot", amount = 1 },
    },
	results = {
		{ type = "item", name = "gold-dust", amount = 1 },
	}
}
create_recipe{
	recipe_name = "silver-dust-macerator",
	category = "smelting",
	energy_required = SILVER_SPEED,
	ingredients = {
		{type = "item", name = "silver-ingot", amount = 1 },
    },
	results = {
		{ type = "item", name = "silver-dust", amount = 1 },
	}
}
create_item{
	name = "electrum-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 5,
	ingredients = {
      {type = "item", name = "gold-ingot", amount = 1},
      {type = "item", name = "silver-ingot", amount = 1},
    },
	results = {
      {type = "item", name = "electrum-ingot", amount = 2},
    }
}
create_recipe{
	recipe_name = "electrum-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "electrum-dust", amount = 1 },
    },
	results = {
		{ type = "item", name = "electrum-ingot", amount = 1 },
	}
}
create_recipe{
	recipe_name = "electrum-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "electrum-dust", amount = 64 },
    },
	results = {
		{ type = "item", name = "electrum-ingot", amount = 64 },
	}
}
create_item{
	name = "electrum-dust",
	category = "lv-mixer-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "gold-dust", amount = 1 },
		{type = "item", name = "silver-dust", amount = 1 },
    },
	results = {
		{ type = "item", name = "electrum-dust", amount = 2 },
	}
}
create_recipe{
	recipe_name = "electrum-dust-macerator",
	category = "lv-macerator-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "electrum-ingot", amount = 1 },
    },
	results = {
		{ type = "item", name = "electrum-dust", amount = 1 },
	}
}

   
---ADVANCED INTEGRATED CIRCUIT
create_item{
	name = "processing-unit",
	category = "lv-circuit-assembler-recipes",
	icon = ICON_PATH .. "hv-circuit.png",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "advanced-circuit", amount = 2 },
		{ type = "item", name = "ilc-chip", amount = 2 },
		{ type = "item", name = "ram-chip", amount = 2 },
		{ type = "item", name = "transistor", amount = 4 },
		{ type = "item", name = "fine-electrum-wire", amount = 8 },
		{ type = "item", name = "annealed-copper-bolt", amount = 8 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "processing-unit", amount = 1 }
	}
}



---ROCK CRUSHER RECIPES
create_recipe{
	recipe_name = "rock-crusher-cobblestone",
	category = "lv-rock-crusher-recipes",
	energy_required = 0.8,
	ingredients = {},
	results = {
		{ type = "item", name = "stone", amount = 1 }
	}
}
   
   
   
---SOLID STEEL MACHINE CASING
create_item{
	name = "solid-steel-machine-casing",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 6 },
		{ type = "item", name = "steel-frame", amount = 1 },
	}
}
   
   
   
---TEMPERED GLASS
create_item{
	name = "tempered-glass",
	category = "mv-electric-blast-furnace-recipes",
	energy_required = 3,
	ingredients = {
		{type = "item", name = "glass", amount = 1},
		{type = "fluid", name = "oxygen", amount = 10},
    }
}
  


---GREENHOUSE
create_recipe{
	recipe_name = "growing-trees",
	category = "greenhouse-recipes",
	energy_required = 30,
	ingredients = {
		{type = "fluid", name = "water", amount = 2400},
    },
	results = {
		{type = "item", name = "wood", amount = 64},
    }
}
  
  

---LARGE STEEL GEAR
create_recipe{
	recipe_name = "large-steel-gear-crafting-table",
	category = "crafting-table-recipes",
	subgroup = "subgroup-early-game-machine-replacements",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 4},
		{type = "item", name = "steel-rod", amount = 4},
    },
	results = {
		{type = "item", name = "large-steel-gear", amount = 1},
    }
}
  
  
  
---CONFIGURABLE VALVE  
create_recipe{
	recipe_name = "configurable-valve",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{type = "item", name = "pipe", amount = 1},
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "steel-plate", amount = 1},
    }
}  
  
  
  
---LANDFILL
create_recipe{
	recipe_name = "landfill",
	subgroup = "terrain",
	ingredients = {
		{type = "item", name = "stone", amount = 10},
    }
}  
  
  
  
---STORAGE TANK 
create_recipe{
	recipe_name = "storage-tank",
	energy_required = 3,
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "pipe", amount = 4},
		{type = "item", name = "steel-plate", amount = 10},
		{type = "item", name = "iron-plate", amount = 20},
    }
}



---PUMP
create_recipe{
	recipe_name = "pump",
	subgroup = "energy-pipe-distribution",
	ingredients = {
		{type = "item", name = "pipe", amount = 1},
		{type = "item", name = "lv-pump", amount = 1},
		{type = "item", name = "lv-motor", amount = 1},
		{type = "item", name = "steel-plate", amount = 1},
    }
} 



---LOGISTIC SCIENCE PACK
create_recipe{
	recipe_name = "lv-science-pack",
	order = "b",
	subgroup = "subgroup-science-packs",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "transport-belt", amount = 1 },
		{ type = "item", name = "inserter", amount = 1 },
	},
	results = {
		{type = "item", name = "logistic-science-pack", amount = 1},
    }
}
     
   
   
---LAB
create_recipe{
	recipe_name = "lab",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "transport-belt", amount = 4 },
		{ type = "item", name = "electronic-circuit", amount = 4 },
		{ type = "item", name = "iron-gear-wheel", amount = 10 },
	}
}
   


---RADAR
create_recipe{
	recipe_name = "radar",
	energy_required = 2,
	ingredients = {
		{ type = "item", name = "iron-plate", amount = 10 },
		{ type = "item", name = "iron-gear-wheel", amount = 5 },
		{ type = "item", name = "lv-sensor", amount = 1 },
	}
}
   
   
   
---MV SCIENCE PACK
create_recipe{
	recipe_name = "mv-science-pack",
	category = "lv-assembling-machine-recipes",
	energy_required = 40,
	order = "c",
	subgroup = "subgroup-science-packs",
	ingredients = {
		{ type = "item", name = "lv-piston", amount = 1 },
		{ type = "item", name = "lv-pump", amount = 1 },
		{ type = "item", name = "lv-conveyor-module", amount = 1 },
		{ type = "item", name = "lv-robot-arm", amount = 1 },
		{ type = "item", name = "lv-sensor", amount = 1},
		{ type = "item", name = "lv-emitter", amount = 1},
	},
	results = {
		{ type = "item", name = "military-science-pack", amount = 4 },
	}
}    
   
   
   
 ---FILTER
create_item{
	name = "filter",
	category = "lv-assembling-machine-recipes",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 1 },
		{ type = "item", name = "zinc-foil", amount = 8 },
	}
}



---BLACK BRONZE DUST
create_item{
	name = "black-bronze-dust",
	category = "lv-mixer-recipes",
	energy_required = 25,
	ingredients = {
		{type = "item", name = "copper-dust", amount = 3 },
		{type = "item", name = "electrum-dust", amount = 2 },
    },
	results = {
		{ type = "item", name = "black-bronze-dust", amount = 5 },
	}
} 



---ROSE GOLD DUST
create_item{
	name = "rose-gold-dust",
	category = "lv-mixer-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "copper-dust", amount = 1 },
		{type = "item", name = "gold-dust", amount = 4 },
    },
	results = {
		{ type = "item", name = "rose-gold-dust", amount = 5 },
	}
} 



---STERLING SILVER DUST
create_item{
	name = "sterling-silver-dust",
	category = "mv-mixer-recipes",
	energy_required = 25 * MV_SPEED,
	ingredients = {
		{type = "item", name = "copper-dust", amount = 1 },
		{type = "item", name = "silver-dust", amount = 4 },
    },
	results = {
		{ type = "item", name = "sterling-silver-dust", amount = 5 },
	}
}



---BISMUTH BRONZE DUST
create_item{
	name = "bismuth-bronze-dust",
	category = "lv-mixer-recipes",
	energy_required = 25,
	ingredients = {
		{type = "item", name = "brass-dust", amount = 4 },
		{type = "item", name = "bismuth", amount = 1 },
    },
	results = {
		{ type = "item", name = "bismuth-bronze-dust", amount = 5 },
	}
}



---RED STEEL DUST
create_item{
	name = "red-steel-dust",
	category = "lv-mixer-recipes",
	energy_required = 40,
	ingredients = {
		{type = "item", name = "sterling-silver-dust", amount = 1 },
		{type = "item", name = "black-steel-dust", amount = 4 },
		{type = "item", name = "steel-dust", amount = 2 },
		{type = "item", name = "bismuth-bronze-dust", amount = 1 },
    },
	results = {
		{ type = "item", name = "red-steel-dust", amount = 8 },
	}
}   



---LIQUID CONCRETE   
create_recipe{
	recipe_name = "liquid-concrete",
	category = "lv-mixer-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "gypsum", amount = 1 },
		{ type = "item", name = "calcite", amount = 1 },
		{ type = "item", name = "stone-dust", amount = 2 },
		{ type = "fluid", name = "water", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "liquid-concrete", amount = 115.2 },
	}
}
   
   
   
---CONCRETE   
create_recipe{
	recipe_name = "concrete",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "fluid", name = "liquid-concrete", amount = 14.4 }
	}
}


---HAZARD CONCRETE   
create_recipe{
	recipe_name = "hazard-concrete",
	ingredients = {
		{ type = "item", name = "concrete", amount = 10 },
	},
	results = {
		{ type = "item", name = "hazard-concrete", amount = 10 },
	}
}



---REFINED CONCRETE   
create_recipe{
	recipe_name = "refined-concrete",
	category = "lv-assembling-machine-recipes",
	energy_required = 15,
	ingredients = {
		{ type = "item", name = "concrete", amount = 20 },
		{ type = "item", name = "iron-stick", amount = 8 },
		{ type = "item", name = "steel-plate", amount = 1 },
		{ type = "fluid", name = "water", amount = 100 },
		},
	results = {
		{ type = "item", name = "refined-concrete", amount = 10 },
	}
}



---REFINED HAZARD CONCRETE   
create_recipe{
	recipe_name = "refined-hazard-concrete",
	ingredients = {
		{ type = "item", name = "refined-concrete", amount = 10 },
	},
	results = {
		{ type = "item", name = "refined-hazard-concrete", amount = 10 },
	}
}   



---CINNABAR CENTRIFUGING
create_recipe{
	recipe_name = "cinnabar-centrifuging",
	category = "lv-centrifuge-recipes",
	energy_required = 18,
	ingredients = {
		{ type = "item", name = "cinnabar-dust", amount = 2 },
	},
	results = {
		{ type = "fluid", name = "mercury", amount = 100 },
		{ type = "item", name = "sulfur", amount = 1 },
	},
	main_product = "mercury"
}
 
  
  
---AIR COLLECTION
create_recipe{
	recipe_name = "air-collection",
	category = "lv-air-collector-recipes",
	energy_required = 10,
	ingredients = { },
	results = {
		{ type = "fluid", name = "air", amount = 1000 },
	}
}


   
---BASIC AIR CENTRIFUGING
create_recipe{
	recipe_name = "basic-air-centrifuging",
	category = "lv-centrifuge-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "fluid", name = "air", amount = 1000 },
	},
	results = {
		{ type = "fluid", name = "nitrogen", amount = 390 },
		{ type = "fluid", name = "oxygen", amount = 100 },
	},
	main_product = "nitrogen"
}
   
   
   
--- WOOD TAR
create_recipe{
	recipe_name = "wood-tar-pyrolyse",
	category = "pyrolyse-oven-recipes",
	energy_required = 16,
	ingredients = {
		{type = "item", name = "wood", amount = 16},
		{type = "fluid", name = "nitrogen", amount = 100}
    },
	results = {
		{type = "item", name = "charcoal", amount = 20},
		{type = "fluid", name = "wood-tar", amount = 150},
    },
	main_product = "wood-tar"
}
create_recipe{
	recipe_name = "wood-tar-extractor",
	category = "lv-extractor-recipes",
	energy_required = 1,
	ingredients = {
		{type = "item", name = "charcoal", amount = 1},
    },
	results = {
		{type = "fluid", name = "wood-tar", amount = 10},
    }
}



--- BENZENE
create_recipe{
	recipe_name = "benzene-from-wood-tar",
	category = "lv-distillation-recipes",
	energy_required = 4,
	ingredients = {
		{type = "fluid", name = "wood-tar", amount = 100},
    },
	results = {
		{type = "fluid", name = "benzene", amount = 50},
    }
}



---POLYETHYLENE SHEET
create_item{
	name = "polyethylene-sheet",
	category = "lv-fluid-solidifier-recipes",
	ingredients = {
		{ type = "fluid", name = "polyethylene", amount = 14.4 }
	}
}  
  
  
  
---RUBY LENS
create_item{
	name = "ruby-lens",
	category = "lv-lathe-recipes",
	energy_required = 120,
	ingredients = {
		{type = "item", name = "ruby", amount = 1}
    }
}


  
---STEAM MACHINE CASING
create_item{
	name = "steam-machine-casing",
	ingredients = {
		{type = "item", name = "brick-block", amount = 1},
		{type = "item", name = "bronze-plate", amount = 6},
	}
}
  


---BRONZE PIPE CASING
create_item{
	name = "bronze-pipe-casing",
	ingredients = {
		{type = "item", name = "bronze-frame", amount = 1},
		{type = "item", name = "pipe", amount = 4},
		{type = "item", name = "bronze-plate", amount = 4},
	}
}
  
  
  
---BRONZE FIREBOX CASING
create_item{
	name = "bronze-firebox-casing",
	ingredients = {
		{type = "item", name = "bronze-frame", amount = 1},
		{type = "item", name = "bronze-rod", amount = 4},
		{type = "item", name = "bronze-plate", amount = 4},
	}
}

  
  
---CAR
create_recipe{
	recipe_name = "car",
	energy_required = 2,
	subgroup = "transport",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 20},
		{type = "item", name = "steel-plate", amount = 5},
		{type = "item", name = "lv-motor", amount = 8},
	}
}

  
  
---ARITHMATIC COMBINATOR
create_recipe{
	recipe_name = "arithmetic-combinator",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "fine-copper-wire", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
}

  
  
---CONSTANT COMBINATOR
create_recipe{
	recipe_name = "constant-combinator",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "fine-copper-wire", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
}

  
  
---DECIDER COMBINATOR
create_recipe{
	recipe_name = "decider-combinator",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "fine-copper-wire", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
}

  
  
---DISPLAY PANEL
create_recipe{
	recipe_name = "display-panel",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "glass", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
} 

  
  
---POWER SWITCH
create_recipe{
	recipe_name = "power-switch",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "fine-copper-wire", amount = 8},
		{type = "item", name = "electronic-circuit", amount = 2},
	}
}

  
  
---SELECTOR COMBINATOR
create_recipe{
	recipe_name = "selector-combinator",
	subgroup = "circuit-network",
	ingredients = {
		{type = "item", name = "decider-combinator", amount = 5},
		{type = "item", name = "advanced-circuit", amount = 2},
	}
} 

  
  
---REPAIR PACK
create_recipe{
	recipe_name = "repair-pack",
	subgroup = "capsule",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 2},
		{type = "item", name = "copper-plate", amount = 2},
		{type = "item", name = "iron-gear-wheel", amount = 1}
	}
} 
  


---WOODEN TIE
create_item{
	name = "wooden-tie",
	category = "lv-chemical-bath-recipes",
	subgroup = "transport",
	order = "a[train-system]-e[rail]",
	energy_required = 3.3,
	ingredients = {
		{type = "item", name = "plank", amount = 1},
		{type = "fluid", name = "creosote", amount = 10},
	}
}
  
  
  
---WOODEN RAILBED
create_item{
	name = "wooden-railbed",
	subgroup = "transport",
	order = "a[train-system]-e[rail]",
	ingredients = {
		{type = "item", name = "wooden-tie", amount = 4},
	}
}

  
  
---STANDARD RAIL
create_item{
	name = "standard-rail",
	category = "lv-bending-machine-recipes",
	energy_required = 0.9,
	subgroup = "transport",
	order = "a[train-system]-e[rail]",
	ingredients = {
		{type = "item", name = "iron-stick", amount = 3},
	},
	results = {
		{type = "item", name = "standard-rail", amount = 4}
    }
}

  
  
---RAIL
create_recipe{
	recipe_name = "rail",
	subgroup = "transport",
	order = "a[train-system]-e[rail]",
	ingredients = {
		{type = "item", name = "wooden-railbed", amount = 1},
		{type = "item", name = "standard-rail", amount = 2},
		{type = "item", name = "iron-screw", amount = 2},
	},
	results = {
		{type = "item", name = "rail", amount = 8}
    }
}



---LOCOMOTIVE
create_recipe{
	recipe_name = "locomotive",
	energy_required = 4,
	subgroup = "transport",
	order = "a[train-system]-a[locomotive]",
	ingredients = {
		{type = "item", name = "small-coal-boiler", amount = 1},
		{type = "item", name = "steel-plate", amount = 30},
		{type = "item", name = "lv-motor", amount = 20},
	}
}



---CARGO WAGON
create_recipe{
	recipe_name = "cargo-wagon",
	ingredients = {
		{type = "item", name = "steel-plate", amount = 20},
		{type = "item", name = "iron-plate", amount = 10},
		{type = "item", name = "iron-gear-wheel", amount = 10},
	}
}



---RAIL SIGNAL
create_recipe{
	recipe_name = "rail-signal",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
}


---RAIL CHAIN SIGNAL
create_recipe{
	recipe_name = "rail-chain-signal",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "electronic-circuit", amount = 1},
	}
}



---TRAIN STOP
create_recipe{
	recipe_name = "train-stop",
	ingredients = {
		{type = "item", name = "iron-plate", amount = 4},
		{type = "item", name = "iron-stick", amount = 4},
		{type = "item", name = "steel-plate", amount = 2},
		{type = "item", name = "electronic-circuit", amount = 2},
	}
} 



---FLUID WAGON
create_recipe{
	recipe_name = "fluid-wagon",
	energy_required = 2,
	ingredients = {
		{type = "item", name = "pipe", amount = 8},
		{type = "item", name = "iron-gear-wheel", amount = 10},
		{type = "item", name = "steel-plate", amount = 16},
		{type = "item", name = "storage-tank", amount = 1},
	}
}



---LARGE STEEL FLUID CELL
create_item{
	name = "empty-large-steel-fluid-cell",
	category = "lv-bending-machine-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "steel-plate", amount = 8},
		{type = "item", name = "bronze-ring", amount = 4},
	}
}



---BENZENE CELL
create_item{
	name = "benzene-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "gas-turbine-fuel",
	fuel_value = "144MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "benzene", amount = 800},
	}
}



---CREOSOTE CELL
create_item{
	name = "creosote-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "semifluid-generator-fuel",
	fuel_value = "19.2MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "creosote", amount = 800},
	}
}



---LIGHT FUEL CELL
create_item{
	name = "light-fuel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "122MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "light-fuel", amount = 800},
	}
}



---HEAVY FUEL CELL
create_item{
	name = "heavy-fuel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "semifluid-generator-fuel",
	fuel_value = "144MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "heavy-fuel", amount = 800},
	}
}



---DIESEL CELL
create_item{
	name = "diesel-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4,
	fuel_category = "combustion-generator-fuel",
	fuel_value = "192MJ",
	burnt_result = "empty-large-steel-fluid-cell",
	ingredients = {
		{type = "item", name = "empty-large-steel-fluid-cell", amount = 1},
		{type = "fluid", name = "diesel", amount = 800},
	}
}



---UMV SCIENCE PACK
create_item{
	name = "umv-science-pack",
	icon_size = 64,
	stack_size = 200,
	ingredients = {
		{ type = "item", name = "stone", amount = 64 }
	},
	subgroup = "science-pack",
	order = "x[umv-science-pack]",
	type = "tool",
	durability = 1,
	durability_description_key = "description.science-pack-remaining-amount"
}



---UXV SCIENCE PACK
create_item{
	name = "uxv-science-pack",
	category = "uxv-assembling-machine-recipes",
	energy_required = 60 * UXV_SPEED,
	icon_size = 64,
	stack_size = 200,
	ingredients = {
		{ type = "item", name = "stone", amount = 128 }
	},
	results = {
		{type = "item", name = "uxv-science-pack", amount = 1 }
    },
	subgroup = "science-pack",
	order = "y[uxv-science-pack]",
	type = "tool",
	durability = 1,
	durability_description_key = "description.science-pack-remaining-amount"
}



---STARGATE
create_item{
	name = "stargate",
	icon_size = 64,
	stack_size = 10,
	ingredients = {
		{ type = "item", name = "stargate-ring-block", amount = 8 },
		{ type = "item", name = "stargate-chevron-block", amount = 7 },
		{ type = "item", name = "stargate-base", amount = 1 },
		{ type = "item", name = "stargate-power-unit", amount = 1 },
		{ type = "item", name = "stargate-controller", amount = 1 },
		{ type = "item", name = "stargate-chevron-upgrade", amount = 1 },
		{ type = "item", name = "stargate-iris-upgrade", amount = 1 },
	}
}
create_item{
	name = "stargate-ring-block",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-ring-block", amount = 1 },
	}
}
create_item{
	name = "stargate-chevron-block",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-chevron-block", amount = 1 },
	}
}
create_item{
	name = "stargate-base",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-base", amount = 1 },
	}
}
create_item{
	name = "stargate-power-unit",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-power-unit", amount = 1 },
	}
}
create_item{
	name = "stargate-controller",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-controller", amount = 1 },
	}
}
create_item{
	name = "stargate-chevron-upgrade",
	icon_size = 64,
	ingredients = {
		{ type = "item", name = "stargate-chevron-upgrade", amount = 1 },
	}
}
create_item{
	name = "stargate-iris-upgrade",
	ingredients = {
		{ type = "item", name = "stargate-iris-upgrade", amount = 1 },
	}
}



---MAX SCIENCE PACK
create_item{
	name = "max-science-pack",
	category = "uxv-assembling-machine-recipes",
	energy_required = 120 * UXV_SPEED,
	icon_size = 64,
	stack_size = 200,
	ingredients = {
		{ type = "item", name = "stargate", amount = 1 },
	},
	results = {
		{type = "item", name = "max-science-pack", amount = 1000 }
    },
	subgroup = "science-pack",
	order = "z[max-science-pack]",
	type = "tool",
	durability = 1,
	durability_description_key = "description.science-pack-remaining-amount"
}




---MANUAL LABOR AUTOMATION
create_recipe{
	name = "manual-labor-automation",
	category = "lv-assembling-machine-recipes",
	energy_required = 60 * UXV_SPEED,
	ingredients = {	},
	results = {
		{type = "item", name = "manual-labor", amount = 1 }
    }
}






---VANADIUM MAGNETITE DUST SMELTING
 create_recipe{
	recipe_name = "vanadium-magnetite-dust-smelter",
	category = "smelting",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "vanadium-magnetite-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "iron-ingot", amount = 1 },
	}
}
 create_recipe{
	recipe_name = "vanadium-magnetite-dust-multismelter",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "vanadium-magnetite-dust", amount = 64 },
	},
	results = {
		{ type = "item", name = "iron-ingot", amount = 64 },
	}
}