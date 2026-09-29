--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--------------------------
---   ZPM COMPONENTS   ---
--------------------------

---VANADIUM GALLIUM CABLE
create_item{
	name = "vanadium-gallium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "vanadium-gallium-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 2 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "vanadium-gallium-cable", amount = 4 },
	}
} 



---ZPM MOTOR
create_item{
	name = "zpm-motor",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 2 },
		{ type = "item", name = "long-naquadah-alloy-rod", amount = 4 },
		{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
		{ type = "item", name = "naquadah-alloy-round", amount = 16 },
		{ type = "item", name = "fine-europium-wire", amount = 256 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM PISTON
create_item{
	name = "zpm-piston",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "zpm-motor", amount = 1 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 6 },
		{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
		{ type = "item", name = "naquadah-alloy-round", amount = 32 },
		{ type = "item", name = "naquadah-alloy-rod", amount = 4 },
		{ type = "item", name = "large-naquadah-alloy-gear", amount = 1 },
		{ type = "item", name = "naquadah-alloy-gear", amount = 2 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM PUMP
create_item{
	name = "zpm-pump",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "zpm-motor", amount = 1 },
		{ type = "item", name = "enderium-plate", amount = 6 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 2 },
		{ type = "item", name = "naquadah-alloy-screw", amount = 8 },
		{ type = "item", name = "silicone-rubber-ring", amount = 16 },
		{ type = "item", name = "naquadah-alloy-rotor", amount = 2 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM CONVEYOR MODULE
create_item{
	name = "zpm-conveyor-module",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "zpm-motor", amount = 2 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 2 },
		{ type = "item", name = "naquadah-alloy-ring", amount = 4 },
		{ type = "item", name = "naquadah-alloy-round", amount = 32 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 20 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM ROBOT ARM
create_item{
	name = "zpm-robot-arm",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "zpm-motor", amount = 2 },
		{ type = "item", name = "zpm-piston", amount = 1 },
		{ type = "item", name = "long-naquadah-alloy-rod", amount = 4 },
		{ type = "item", name = "large-naquadah-alloy-gear", amount = 1 },
		{ type = "item", name = "naquadah-alloy-gear", amount = 3 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 8 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 24 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM SENSOR
create_item{
	name = "zpm-sensor",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
		{ type = "item", name = "zpm-motor", amount = 1 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 8 },
		{ type = "item", name = "quantum-star", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "trinium-foil", amount = 192 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 28 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM EMITTER
create_item{
	name = "zpm-emitter",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
		{ type = "item", name = "zpm-motor", amount = 1 },
		{ type = "item", name = "naquadah-alloy-rod", amount = 16 },
		{ type = "item", name = "quantum-star", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "trinium-foil", amount = 192 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 28 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
		{ type = "fluid", name = "lubricant", amount = 75 },
	}
}



---ZPM FIELD GENERATOR
create_item{
	name = "zpm-field-generator",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
		{ type = "item", name = "zpm-emitter", amount = 4 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 6 },
		{ type = "item", name = "quantum-star", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "fine-europium-wire", amount = 256 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 32 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 },
	}
}


---ZPM MACHINE CASING
create_item{
	name = "zpm-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "osmium-plate", amount = 8 },
    }
}



---ZPM MACHINE HULL
create_item{
	name = "zpm-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uv-machine-casing", amount = 1 },
		{ type = "item", name = "osmium-plate", amount = 1 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
		{ type = "item", name = "naquadah-alloy-wire", amount = 8 },
    }
}



---ZERO POINT MODULE VOLTAGE COIL
create_item{
	name = "zero-point-module-voltage-coil",
	category = "uv-assembling-machine-recipes",
	energy_required = 10 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-fluxed-electrum-wire", amount = 16 },
    }
}



---ZPM ENERGY HATCH
create_item{
	name = "zpm-energy-hatch",
	category = "uv-assembly-line-recipes",
	energy_required = 50 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "zpm-machine-hull", amount = 1 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 4 },
		{ type = "item", name = "uhpic-chip", amount = 2 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "item", name = "zero-point-module-voltage-coil", amount = 2 },
		{ type = "fluid", name = "sodium-potassium", amount = 800 },
		{ type = "fluid", name = "soldering-alloy", amount = 144 },
    }
}



---ZPM DYNAMO HATCH
create_item{
	name = "zpm-dynamo-hatch",
	category = "uv-assembly-line-recipes",
	energy_required = 50 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-superconductor-spring", amount = 4 },
		{ type = "item", name = "piko-power-ic", amount = 2 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "360k-super-coolant-cell", amount = 4 },
		{ type = "item", name = "uv-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 800 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
    }
}



---TRINIUM COIL BLOCK (UV)
create_item{
	name = "trinium-coil-block",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "trinium-wire", amount = 16 },
		{ type = "item", name = "enriched-naquadah-foil", amount = 8 },
		{ type = "fluid", name = "molten-naqu adah", amount = 14.4 }
	}
}  





--------------------------
---   CRYSTAL MATRIX   ---
--------------------------

---CRYSTAL MATRIX INGOT
create_item{
	name = "crystal-matrix-ingot",
	category = "hv-assembling-machine-recipes",
	energy_required = 60 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "diamond-lattice", amount = 4 },
		{ type = "item", name = "nether-star", amount = 2 },
    }
}
create_item{
	name = "diamond-lattice",
	ingredients = {
		{ type = "item", name = "diamond-plate", amount = 4 },
		{ type = "item", name = "diamond-screw", amount = 4 },
		{ type = "item", name = "stainless-steel-bars", amount = 1 },
    }
}		
create_item{
	name = "stainless-steel-bars",
	category = "mv-assembling-machine-recipes",
	energy_required = 20 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "stainless-steel-rod", amount = 3 },
    },
	results = {
		{ type = "item", name = "stainless-steel-bars", amount = 4 }
	}
}	
create_item{
	name = "crystal-matrix-heavy-plating",
	category = "zpm-compressor-recipes",
	energy_required = 20 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "crystal-matrix-ingot", amount = 4 },
    }
}



---ENERGY MODULE
create_item{
	name = "energy-module",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 100,
	ingredients = {
		{ type = "item", name = "europium-plate", amount = 16 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 8 },
		{ type = "item", name = "zpm-field-generator", amount = 2 },
		{ type = "item", name = "asoc-wafer", amount = 128 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "naquadah-cable", amount = 32 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "lapis-coolant", amount = 1600 },
	}
}
create_recipe{
	recipe_name = "energy-module-space-assembler",
	category = "uv-space-assembler-mk1-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "wetware-printed-circuit-board", amount = 1 },
		{ type = "item", name = "bedrockium-foil", amount = 64 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "engraved-lapotron-chip", amount = 128 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 64 },
		{ type = "item", name = "optical-smd-diode", amount = 8 },
		{ type = "item", name = "optical-smd-capacitor", amount = 8 },
		{ type = "item", name = "optical-smd-resistor", amount = 8 },
		{ type = "item", name = "optical-smd-transistor", amount = 8 },
		{ type = "item", name = "fine-hypogen-wire", amount = 48 },
		{ type = "fluid", name = "mutated-living-solder", amount = 72 },
	},
	results = {
		{ type = "item", name = "energy-module", amount = 1 },
	}
}



-----------------------------------------
---   BLACK PLUTONIUM AND BEDROCKIUM  ---
-----------------------------------------

create_recipe{
    name = "microminer-black-plutonium",
    category = "lv-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 2,
    subgroup = "subgroup-microminer-t7"
	ingredients = {
      {type = "item", name = "tier-seven-microminer-output", amount = 1 }
    },
    results = {
      {type = "item", name = "raw-black-plutonium", amount = 32 },
      {type = "item", name = "raw-desh", amount = 16 },
      {type = "item", name = "raw-neutronium", amount = 8 },
      {type = "item", name = "raw-borax", amount = 8 },
    },
	main_product = "raw-black-plutonium"
}
create_recipe{
    name = "microminer-bedrockium",
    category = "lv-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 2,
    subgroup = "subgroup-microminer-t7"
	ingredients = {
      {type = "item", name = "tier-seven-microminer-output", amount = 2 }
    },
    results = {
      {type = "item", name = "raw-bedrockium", amount = 32 },
      {type = "item", name = "raw-neutronium", amount = 16 },
      {type = "item", name = "raw-black-plutonium", amount = 8 },
      {type = "item", name = "raw-borax", amount = 8 },
    },
	main_product = "raw-bedrockium"
}




---MOLTEN TRINIUM
create_recipe{
	recipe_name = "molten-trinium",
	category = "mv-extractor-recipes",
	energy_required = 1.2 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "trinium-ingot", amount = 1 }
	},
	results = {
		{ type = "fluid", name = "molten-trinium", amount = 14.4 }
	}
}




---------------------------------------------
---   HOT ISOSTATIC PRESSURIZATION UNIT   ---
---------------------------------------------
   
create_item{
	name = "hot-isostatic-pressurization-unit-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = 120 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "large-electric-compressor-controller", amount = 4 },
		{ type = "item", name = "heating-duct", amount = 4 },
		{ type = "item", name = "coolant-duct", amount = 4 },
		{ type = "item", name = "block-of-naquadria", amount = 4 },
		{ type = "item", name = "zpm-piston", amount = 16 },
		{ type = "item", name = "zpm-robot-arm", amount = 4 },
		{ type = "item", name = "zpm-pump", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "fluid", name = "molten-incoloy-903", amount = 3686.4 }
		{ type = "fluid", name = "molten-enriched-naquadah", amount = 921.6 }
		{ type = "fluid", name = "liquid-air", amount = 1600 }
		{ type = "fluid", name = "lubricant", amount = 1600 }
	}
}







   
----------------------------
---   WETWARE CIRCUITS   ---
----------------------------   
   
---WETWARE PROCESSOR (incomplete, just started)
create_item{
	name = "wetware-processor",
	category = "uv-circuit-assembly-line-recipes",
	energy_required = 50 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "neuro-processing-unit", amount = 1 },
		{ type = "item", name = "crystal-cpu", amount = 1 },
		{ type = "item", name = "nano-cpu-chip", amount = 1 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 6 },
		{ type = "item", name = "advanced-smd-transistor", amount = 6 },
		{ type = "item", name = "fine-ytb-wire", amount = 8 },
		{ type = "fluid", name = "soldering-alloy", amount = 7 }
	}
}  




---WETWARE PROCESSOR ASSEMBLY
	{
		type = "recipe",
		name = "wetware-processor-assembly",
		category = "lv-circuit-assembler-recipes",
		enabled = false,
		energy_required = 1280,
		ingredients = {
			{ type = "item", name = "wetware-printed-circuit-board", amount = 1 },
			{ type = "item", name = "luv-circuit", amount = 2 },
			{ type = "item", name = "advanced-smd-inductor", amount = 4 },
			{ type = "item", name = "advanced-smd-capacitor", amount = 8 },
			{ type = "item", name = "ram-chip", amount = 24 },
			{ type = "item", name = "fine-ytb-wire", amount = 16 },
			{ type = "fluid", name = "soldering-alloy", amount = 14 }
		},
		results = {
			{ type = "item", name = "zpm-circuit", amount = 2 }
		}
   },


---WETWARE PROCESSOR SUPERCOMPUTER 
	{
		type = "recipe",
		name = "wetware-processor-supercomputer",
		category = "assembly-line-recipes",
		enabled = false,
		energy_required = 1280,
		ingredients = {
			{ type = "item", name = "wetware-printed-circuit-board", amount = 1 },
			{ type = "item", name = "zpm-circuit", amount = 2 },
			{ type = "item", name = "advanced-smd-diode", amount = 8 },
			{ type = "item", name = "nor-memory-chip", amount = 16 },
			{ type = "item", name = "ram-chip", amount = 32 },
			{ type = "item", name = "fine-ytb-wire", amount = 24 },
			{ type = "item", name = "thin-pbi-sheet", amount = 32 },
			{ type = "item", name = "europium-plate", amount = 4 },
			{ type = "fluid", name = "soldering-alloy", amount = 115 }
		},
		results = {
			{ type = "item", name = "uv-circuit", amount = 1 }
		}
   },


   ---WETWARE PROCESSOR MAINFRAME 
	{
		type = "recipe",
		name = "wetware-processor-mainframe",
		category = "assembly-line-recipes",
		enabled = false,
		energy_required = 6400,
		ingredients = {
			{ type = "item", name = "tritanium-frame", amount = 2 },
			{ type = "item", name = "uv-circuit", amount = 2 },
			{ type = "item", name = "complex-smd-inductor", amount = 8 },
			{ type = "item", name = "complex-smd-capacitor", amount = 16 },
			{ type = "item", name = "complex-smd-transistor", amount = 8 },
			{ type = "item", name = "complex-smd-resistor", amount = 8 },
			{ type = "item", name = "complex-smd-diode", amount = 8 },
			{ type = "item", name = "thin-pbi-sheet", amount = 64 },
			{ type = "item", name = "ram-chip", amount = 32 },
			{ type = "item", name = "europium-plate", amount = 8 },
			{ type = "item", name = "ented-wire", amount = 32 },
			{ type = "fluid", name = "soldering-alloy", amount = 288 },
			{ type = "fluid", name = "polybenzimidazole", amount = 114 },
		},
		results = {
			{ type = "item", name = "uvh-circuit", amount = 1 }
		}
   },
	


  ---SUPERCONDUCTING COIL BLOCK ZPM
	{
		type = "recipe",
		name = "superconducting-coil-block-zpm",
		category = "assembling-machine-recipes",
		enabled = false,
		energy_required = 320,
		ingredients = {
			{ type = "item", name = "urdq-wire", amount = 32 },
			{ type = "item", name = "niobium-titanium-foil", amount = 16 },
			{ type = "fluid", name = "molten-trinium", amount = 115 }
		},
		results = {
			{ type = "item", name = "superconducting-coil-block", amount = 1 }
		}
   },


   
  ---FUSION COIL BLOCK
	{
		type = "item",
		name = "fusion-coil-block",
		icon = "__gregtorio-continued__/graphics/icons/fusion-coil-block.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "fusion-coil-block",
		category = "assembling-machine-recipes",
		enabled = false,
		energy_required = 320,
		ingredients = {
			{ type = "item", name = "superconducting-coil-block", amount = 1 },
			{ type = "item", name = "iv-field-generator", amount = 2 },
			{ type = "item", name = "iv-pump", amount = 1 },
			{ type = "item", name = "iridium-neutron-reflector", amount = 2 },
			{ type = "item", name = "luv-circuit", amount = 4 },
			{ type = "item", name = "naquadah-plate", amount = 4 },
			{ type = "item", name = "europium-plate", amount = 4 },
			{ type = "fluid", name = "molten-vanadium-gallium", amount = 58 }
		},
		results = {
			{ type = "item", name = "fusion-coil-block", amount = 1 }
		}
   },



  ---FUSION MACHINE CASING MK2
	{
		type = "item",
		name = "fusion-machine-casing-mk2",
		icon = "__gregtorio-continued__/graphics/icons/fusion-machine-casing-mk2.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "fusion-machine-casing-mk2",
		category = "assembling-machine-recipes",
		enabled = false,
		energy_required = 320,
		ingredients = {
			{ type = "item", name = "naquadah-alloy-plate", amount = 8 },
			{ type = "item", name = "fusion-coil-block", amount = 1 },
			{ type = "item", name = "zero-point-module-voltage-coil", amount = 2 },
			{ type = "item", name = "luv-field-generator", amount = 1 },
			{ type = "item", name = "europium-plate", amount = 6 },
			{ type = "fluid", name = "polybenzimidazole", amount = 28 }
		},
		results = {
			{ type = "item", name = "fusion-machine-casing-mk2", amount = 2 }
		}
   },


   
 ---FUSION REACTOR COMPUTER MK2
	{
		type = "item",
		name = "fusion-reactor-computer-mk2",
		icon = "__gregtorio-continued__/graphics/icons/fusion-reactor-computer-mk2.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "fusion-reactor-computer-mk2",
		category = "assembly-line-recipes",
		enabled = false,
		energy_required = 3200,
		ingredients = {
			{ type = "item", name = "fusion-coil-block", amount = 1 },
			{ type = "item", name = "uv-circuit", amount = 4 },
			{ type = "item", name = "naquadria-plate", amount = 2 },
			{ type = "item", name = "europium-plate", amount = 2 },
			{ type = "item", name = "luv-field-generator", amount = 2 },
			{ type = "item", name = "uhpic-chip", amount = 96 },
			{ type = "item", name = "urdq-wire", amount = 32 },
			{ type = "fluid", name = "soldering-alloy", amount = 115 },
			{ type = "fluid", name = "molten-vanadium-gallium", amount = 115 }
		},
		results = {
			{ type = "item", name = "fusion-reactor-computer-mk2", amount = 1 }
		}
   },



 ---FUSION REACTOR MK 2
	{
		type = "item",
		name = "fusion-reactor-mk2",
		icon = "__gregtorio-continued__/graphics/icons/fusion-reactor-mk2.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "fusion-reactor-mk2",
		category = "assembling-machine-recipes",
		enabled = false,
		energy_required = ZPM_SPEED * 4,
		ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk2", amount = 1 },
			{ type = "item", name = "fusion-coil-block", amount = 4 },
			{ type = "item", name = "fusion-machine-casing-mk2", amount = 79 },
			{ type = "item", name = "zpm-energy-hatch", amount = 16 },
			{ type = "item", name = "lv-machine-hull", amount = 32 }
		},
		results = {
			{ type = "item", name = "fusion-reactor-mk2", amount = 1 }
		}
   },









----------------------
---   NEUTRONIUM   ---
----------------------

create_recipe{
    name = "microminer-neutronium",
    category = "lv-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 2,
    subgroup = "subgroup-microminer-t7"
	ingredients = {
      {type = "item", name = "tier-seven-microminer-output", amount = 1 }
    },
    results = {
      {type = "item", name = "raw-neutronium", amount = 32 },
      {type = "item", name = "raw-adamantium", amount = 16 },
      {type = "item", name = "raw-naquadah", amount = 8 },
      {type = "item", name = "raw-titanium", amount = 8 },
    },
	main_product = "raw-neutronium"
}
create_item{
	name = "raw-neutronium-dust",
	category = "zpm-mixer-recipes",
	energy_required = ZPM_SPEED * 11.25,
	ingredients = {
		{ type = "item", name = "neutronium-dust", amount = 1 },
		{ type = "fluid", name = "helium-plasma", amount = 14.4 },
    }
}
create_item{
	name = "hot-neutronium-ingot",
	category = "uv-electric-blast-furnace-recipes",
	energy_required = UV_SPEED * 115,
	ingredients = {
		{ type = "item", name = "raw-neutronium-dust", amount = 1 },
		{ type = "fluid", name = "xenon", amount = 25 },
    }
}
create_item{
	name = "neutronium-ingot",
	category = "iv-vacuum-freezer-recipes",
	energy_required = IV_SPEED * 62.5,
	ingredients = {
		{ type = "item", name = "hot-neutronium-ingot", amount = 1 },
    }
}










------------------------------------------------
---   ICHORIUM TIER DRACONIC FUSION CRAFTER  ---
------------------------------------------------

create_item{
    name = "ichorium-fusion-casing",
    category = "luv-assembling-machine-recipes",	
    energy_required = LUV_SPEED * 60,
    subgroup = "subgroup-ichorium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "ichorium-block", amount = 1 },
      {type = "item", name = "osmiridium-plate", amount = 6 },
      {type = "fluid", name = "molten-void-metal", amount = 115.2 },
    }
}
create_item{
    name = "naquadah-alloy-fusion-casing",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 60,
    subgroup = "subgroup-ichorium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "naquadah-alloy-frame", amount = 6 },
      {type = "item", name = "naquadah-alloy-plate", amount = 6 },
      {type = "fluid", name = "molten-void-metal", amount = 115.2 },
    }
}
create_item{
    name = "draconic-evolution-fusion-crafter-controller",
    category = "zpm-assembly-line-recipes",	
    energy_required = ZPM_SPEED * 600,
    subgroup = "subgroup-ichorium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "fusion-control-computer-mk2", amount = 16 },
      {type = "item", name = "ichorium-fusion-casing", amount = 1 },
      {type = "item", name = "dense-gaia-spirit-plate", amount = 16 },
      {type = "item", name = "trinium-coil-block", amount = 64 },
      {type = "item", name = "zpm-motor", amount = 32 },
      {type = "item", name = "zpm-robot-arm", amount = 16 },
      {type = "item", name = "uv-circuit", amount = 8 },
      {type = "item", name = "gravi-star", amount = 4 },
      {type = "item", name = "primordial-pearl", amount = 1 },
      {type = "item", name = "life-shard", amount = 8 },
      {type = "item", name = "soul-shard", amount = 8 },
      {type = "item", name = "superdense-void-metal-plate", amount = 1 },
      {type = "fluid", name = "molten-indalloy-140", amount = 288 },
      {type = "fluid", name = "molten-void-metal", amount = 288 },
    }
}
create_item{
    name = "ichorium-tier-draconic-evolution-fusion-crafter",
    subgroup = "subgroup-ichorium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "draconic-evolution-fusion-crafter-controller", amount = 1 },
      {type = "item", name = "naquadah-alloy-fusion-casing", amount = 43 },
      {type = "item", name = "fusion-machine-casing", amount = 32 },
      {type = "item", name = "fusion-coil-block", amount = 8 },
      {type = "item", name = "ichorium-fusion-casing", amount = 32 },
      {type = "item", name = "zpm-machine-casing", amount = 4 },
    }
}
create_item{
    name = "draconic-core",
    category = "ichorium-tier-fusion-recipes",	
    energy_required = ZPM_SPEED * 20,
    subgroup = "subgroup-ichorium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "osmiridium-plate", amount = 4 },
      {type = "item", name = "ichorium-plate", amount = 1 },
      {type = "item", name = "quantum-eye", amount = 1 },
      {type = "fluid", name = "molten-sunnarium", amount = 144 },
    }
}
create_item{
    name = "draconium-fusion-casing",
    category = "uv-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 60,
    subgroup = "subgroup-ichorium-tier-fusion"
	ingredients = {
      {type = "item", name = "ichorium-fusion-casing", amount = 1 },
      {type = "item", name = "dense-draconium-plate", amount = 1 },
      {type = "item", name = "draconic-core", amount = 1 },
      {type = "fluid", name = "molten-void-metal", amount = 230.4 },
    }
}
