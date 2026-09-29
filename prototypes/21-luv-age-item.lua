--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--------------------------
---   LUV COMPONENTS   ---
--------------------------

---MAGNETIC SAMARIUM ROD
create_item{
	name = "magnetic-samarium-rod",
	category = "iv-polarizer-recipes",
	energy_required = 3.2 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "samarium-rod", amount = 1 }
	}
}



---MAGNETIC LONG SAMARIUM ROD
create_item{
	name = "long-magnetic-samarium-rod",
	category = "iv-polarizer-recipes",
	energy_required = 6.4 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "long-samarium-rod", amount = 1 }
	}
}



---YTTRIUM BARIUM CUPRATE CABLE
create_item{
	name = "yttrium-barium-cuprate-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "yttrium-barium-cuprate-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 4 },
	}
}



---LUV MOTOR
create_item{
	name = "luv-motor",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "long-hsss-rod", amount = 2 },
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-ruridit-wire", amount = 128 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	}
}   
   
   
   
---LUV PISTON
create_item{
	name = "luv-piston",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 1 },
		{ type = "item", name = "hsss-plate", amount = 6 },
		{ type = "item", name = "hsss-ring", amount = 4 },
		{ type = "item", name = "hsss-round", amount = 32 },
		{ type = "item", name = "hsss-rod", amount = 4 },
		{ type = "item", name = "large-hsss-gear", amount = 1 },
		{ type = "item", name = "hsss-gear", amount = 2 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	}
} 



---LUV PUMP
create_item{
	name = "luv-pump",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 1 },
		{ type = "item", name = "niobium-titanium-plate", amount = 2 },
		{ type = "item", name = "hsss-plate", amount = 6 },
		{ type = "item", name = "hsss-screw", amount = 8 },
		{ type = "item", name = "silicone-rubber-ring", amount = 4 },
		{ type = "item", name = "hsss-rotor", amount = 2 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	}
} 
   
   
   
---LUV CONVEYOR MODULE
create_item{
	name = "luv-conveyor-module",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 2 },
		{ type = "item", name = "hsss-plate", amount = 2 },
		{ type = "item", name = "hsss-ring", amount = 4 },
		{ type = "item", name = "hsss-round", amount = 32 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 10 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	}
}



---LUV ROBOT ARM
create_item{
	name = "luv-robot-arm",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 2 },
		{ type = "item", name = "luv-piston", amount = 1 },
		{ type = "item", name = "hsss-gear", amount = 3 },
		{ type = "item", name = "large-hsss-gear", amount = 1 },
		{ type = "item", name = "long-hsss-rod", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 4 },
		{ type = "item", name = "ev-circuit", amount = 8 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	}
}



---LUV SENSOR
create_item{
	name = "luv-sensor",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hsss-frame", amount = 1 },
		{ type = "item", name = "luv-motor", amount = 1 },
		{ type = "item", name = "ruridit-plate", amount = 8 },
		{ type = "item", name = "quantum-star", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "gallium-foil", amount = 192 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 7 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	}
}   



---LUV EMITTER
create_item{
	name = "luv-emitter",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hsss-frame", amount = 1 },
		{ type = "item", name = "luv-motor", amount = 1 },
		{ type = "item", name = "ruridit-rod", amount = 8 },
		{ type = "item", name = "quantum-star", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "gallium-foil", amount = 192 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 7 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	}
}



---LUV FIELD GENERATOR
create_item{
	name = "luv-field-generator",
	category = "iv-assembly-line-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "hsss-frame", amount = 1 },
		{ type = "item", name = "hsss-plate", amount = 6 },
		{ type = "item", name = "luv-emitter", amount = 4 },
		{ type = "item", name = "ruridit-rod", amount = 8 },
		{ type = "item", name = "quantum-star", amount = 2 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "fine-ruridit-wire", amount = 192 },
		{ type = "item", name = "yttrium-barium-cuprate-cable", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 57.6 },
	}
}

   

---LUV MACHINE CASING
create_item{
	name = "luv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "rhodium-plated-palladium-plate", amount = 8 }
	}
}


   
---LUV MACHINE HULL
create_item{
	name = "luv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "luv-machine-casing", amount = 1 },
		{ type = "item", name = "rhodium-plated-palladium-plate", amount = 1 },
		{ type = "item", name = "vanadium-gallium-cable", amount = 2 },
		{ type = "fluid", name = "ptfe", amount = 28.8 }
	}
}

   
   
---LUDICROUS VOLTAGE COIL
create_item{
	name = "ludicrous-voltage-coil",
	category = "luv-assembling-machine-recipes",
	energy_required = 10 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-ruridit-wire", amount = 16 }
	}
}




create_item{
	name = "uhpic-wafer",
	category = "luv-assembling-machine-recipes",
	energy_required = 60 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "indium-gallium-phosphate", amount = 8 },
		{ type = "item", name = "hpic-wafer", amount = 1 },
		{ type = "fluid", name = "molten-naquadah", amount = 57.6 },
	}
}



create_item{
	name = "ultra-high-powered-integrated-circuit",
	category = "luv-assembling-machine-recipes",
	energy_required = 45 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "uhpic-wafer", amount = 1 },
		{ type = "fluid", name = "lubricant", amount = 25 }
	},
	results = {
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 2 }
	}
}



---LUV ENERGY HATCH
create_item{
	name = "luv-energy-hatch",
	category = "luv-assembly-line-recipes",
	energy_required = 20 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 2 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "luv-pump", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "180k-super-coolant-cell", amount = 2 },
		{ type = "fluid", name = "super-coolant", amount = 200 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 72 },
	}
}      



---NAQUADAH COIL BLOCK (ZPM)
create_item{
	name = "naquadah-coil-block",
	category = "luv-assembling-machine-recipes",
	energy_required = 40 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadah-wire", amount = 16 },
		{ type = "item", name = "osmium-foil", amount = 8 },
		{ type = "fluid", name = "molten-hsss", amount = 14.4 }
	}
}

 






--------------------------
---    BACTERIAL VAT   ---
--------------------------
   
create_item{
	name = "bacterial-vat-controller",
	ingredients = {
		{ type = "item", name = "titanium-reinforced-borosilicate-glass-block", amount = 4 },
		{ type = "item", name = "silver-wire", amount = 16 },
		{ type = "item", name = "ev-circuit", amount = 2 },
		{ type = "item", name = "hv-machine-hull", amount = 1 },
	}
} 
create_item{
	name = "bacterial-vat",
	ingredients = {
		{ type = "item", name = "bacterial-vat-controller", amount = 1 },
		{ type = "item", name = "clean-stainless-steel-machine-casing", amount = 46 },
		{ type = "item", name = "iv-machine-hull", amount = 2 },
		{ type = "item", name = "iv-energy-hatch", amount = 1 },
		{ type = "item", name = "borosilicate-glass-block", amount = 32 },
	}
}   





--------------------------
---    ASSEMBLY LINE   ---
--------------------------
   
create_item{
	name = "assembly-line-controller",
	ingredients = {
		{ type = "item", name = "assembler-machine-casing", amount = 4 },
		{ type = "item", name = "iv-robot-arm", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 2 },
		{ type = "item", name = "iv-machine-hull", amount = 1 },
	}
} 
create_item{
	name = "luv-assembly-line",
	ingredients = {
		{ type = "item", name = "assembly-line-controller", amount = 1 },
		{ type = "item", name = "assembly-line-casing", amount = 11 },
		{ type = "item", name = "iv-energy-hatch", amount = 2 },
		{ type = "item", name = "assembler-machine-casing", amount = 11 },
		{ type = "item", name = "reinforced-glass", amount = 22 },
		{ type = "item", name = "ulv-machine-hull", amount = 10 },
		{ type = "item", name = "lv-machine-hull", amount = 6 },
		{ type = "item", name = "data-access-hatch", amount = 1 },
		{ type = "item", name = "grate-machine-casing", amount = 20 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 25 },
	}
}   
   
   
   
---DATA STICK
create_item{
	name = "data-stick",
	category = "mv-circuit-assembler-recipes",
	energy_required = 40,
	ingredients = {
		{ type = "item", name = "plastic-printed-circuit-board", amount = 1 },
		{ type = "item", name = "cpu-chip", amount = 2 },
		{ type = "item", name = "nand-memory-chip", amount = 32 },
		{ type = "item", name = "ram-chip", amount = 4 },
		{ type = "item", name = "fine-red-alloy-wire", amount = 16 },
		{ type = "item", name = "polyethylene-sheet", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
	}
}


   
---DATA ACCESS HATCH
create_item{
	name = "data-access-hatch",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "ev-machine-hull", amount = 1 },
		{ type = "item", name = "data-stick", amount = 4 },
		{ type = "item", name = "iv-circuit", amount = 4 },
	}
}



---ASSEMBLY LINE CASING
create_item{
	name = "assembly-line-casing",
	ingredients = {
		{ type = "item", name = "steel-plate", amount = 4 },
		{ type = "item", name = "iv-robot-arm", amount = 2 },
		{ type = "item", name = "tungstensteel-frame", amount = 1 },
	}
}



---ASSEMBLER MACHINE CASING
create_item{
	name = "assembler-machine-casing",
	ingredients = {
		{ type = "item", name = "zpm-circuit", amount = 6 },
		{ type = "item", name = "luv-circuit", amount = 1 },
		{ type = "item", name = "iv-motor", amount = 1 },
		{ type = "item", name = "tungstensteel-frame", amount = 1 },
	}
}










---------------------------------
---   CIRCUIT ASSEMBLY LINE   ---
---------------------------------
   
create_item{
	name = "circuit-assembly-line-controller",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 1200,
	ingredients = {
		{ type = "item", name = "luv-motor", amount = 4 },
		{ type = "item", name = "luv-conveyor-module", amount = 2 },
		{ type = "item", name = "luv-emitter", amount = 2 },
		{ type = "item", name = "luv-sensor", amount = 1 },
		{ type = "item", name = "luv-robot-arm", amount = 5 },
		{ type = "item", name = "luv-field-generator", amount = 1 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "niobium-titanium-cable", amount = 2 },
		{ type = "item", name = "rhodium-plated-palladium-plate", amount = 1 },
		{ type = "item", name = "luv-machine-hull", amount = 1 },
	}
} 
create_item{
	name = "luv-circuit-assembly-line",
	ingredients = {
		{ type = "item", name = "circuit-assembly-line-controller", amount = 1 },
		{ type = "item", name = "grate-machine-casing", amount = 19 },
		{ type = "item", name = "assembly-line-casing", amount = 7 },
		{ type = "item", name = "reinforced-glass", amount = 14 },
		{ type = "item", name = "solid-steel-machine-casing", amount = 13 },
		{ type = "item", name = "luv-energy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 2 },
		{ type = "item", name = "ulv-machine-hull", amount = 9 },
	}
}    
   
   
   
   
   
   
   
   
   
   
------------------------------
---   CRYSTAL PROCESSORS   ---
------------------------------
   
---MULTILAYERED FIBER REINFORCED CIRCUIT BOARD
create_item{
	name = "multilayered-fiber-reinforced-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 100,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-circuit-board", amount = 2 },
		{ type = "item", name = "palladium-foil", amount = 8 },
		{ type = "fluid", name = "sulfuric-acid", amount = 50 }
	}
}


   
---MULTILAYERED FIBER REINFORCED PRINTED CIRCUIT BOARD
create_item{
	name = "multilayered-fiber-reinforced-printed-circuit-board",
	category = "lv-chemical-reactor-recipes",
	energy_required = 150,
	ingredients = {
		{ type = "item", name = "multilayered-fiber-reinforced-circuit-board", amount = 1 },
		{ type = "item", name = "platinum-foil", amount = 8 },
		{ type = "fluid", name = "iron-iii-chloride", amount = 200 }
	}
}



---RAW CRYSTAL CHIP (FIRST)
create_item{
	name = "raw-crystal-chip",
	category = "luv-autoclave-recipes",
	energy_required = 1000 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "emerald-plate", amount = 1 },
		{ type = "fluid", name = "mutagen", amount = 1000 },
	}
}



---RAW CRYSTAL CHIP PART
create_item{
	name = "raw-crystal-chip-part",
	category = "hv-maceration-recipes",
	energy_required = 10 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "raw-crystal-chip", amount = 1 },
	},
	results = {
		{ type = "item", name = "raw-crystal-chip-part", amount = 9 }
	}
}



---RAW CRYSTAL CHIP
create_recipe{
	recipe_name = "raw-crystal-chip-loop",
	category = "hv-autoclave-recipes",
	energy_required = 600 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "raw-crystal-chip-part", amount = 1 },
		{ type = "item", name = "emerald-plate", amount = 1 },
		{ type = "fluid", name = "mutagen", amount = 25 },
	},
	results = {
		{ type = "item", name = "raw-crystal-chip", amount = 1, probability = 0.8 }
	}
}



---ENGRAVED CRYSTAL CHIP
create_item{
	name = "engraved-crystal-chip",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "raw-crystal-chip", amount = 1 },
		{ type = "item", name = "emerald-plate", amount = 1 },
		{ type = "fluid", name = "radon", amount = 10 },
	}
}



---CRYSTAL CPU
create_item{
	name = "crystal-cpu",
	category = "luv-laser-engraver-recipes",
	energy_required = 30 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "engraved-crystal-chip", amount = 1 },
	}
} 
   
   
   
---WRAPS
create_item{
	name = "nano-cpu-chip-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "nano-cpu-chip", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "ram-chip-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "ram-chip", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "nor-memory-chip-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "nor-memory-chip", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "nand-memory-chip-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "nand-memory-chip", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "advanced-smd-capacitor-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "advanced-smd-capacitor", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "advanced-smd-transistor-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "advanced-smd-transistor", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}
create_item{
	name = "advanced-smd-inductor-wrap",
	category = "lv-assembling-machine-recipes",
	energy_required = 30,
	ingredients = {
		{ type = "item", name = "advanced-smd-inductor", amount = 16 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 }
	}
}



---CRYSTAL PROCESSOR 
create_recipe{
	recipe_name = "crystal-processor",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 16 },
		{ type = "item", name = "crystal-cpu", amount = 16 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 6 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 6 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 8 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "iv-circuit", amount = 16 }
	}
} 



---CRYSTAL PROCESSOR ASSEMBLY
create_recipe{
	recipe_name = "crystal-processor-assembly",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 120,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 16 },
		{ type = "item", name = "iv-circuit", amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 24 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 6 },
		{ type = "item", name = "advanced-smd-inductor", amount = 8 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "luv-circuit", amount = 16 }
	}
} 



---CRYSTAL PROCESSOR SUPERCOMPUTER 
create_recipe{
	recipe_name = "crystal-processor-supercomputer",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 240,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 16 },
		{ type = "item", name = "luv-circuit", amount = 32 },
		{ type = "item", name = "ram-chip-wrap", amount = 4 },
		{ type = "item", name = "nor-memory-chip-wrap", amount = 32 },
		{ type = "item", name = "nand-memory-chip-wrap", amount = 64 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 32 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "zpm-circuit", amount = 16 }
	}
}



---CRYSTAL PROCESSOR MAINFRAME
create_item{
	name = "itbtc-alloy-wire",
	category = "lv-wiremill",
	energy_required = 4.5,
	ingredients = {
		{ type = "item", name = "itbtc-alloy-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "itbtc-alloy-wire", amount = 2 }
	}
} 
create_item{
	name = "luv-superconductor-wire-16x",
	category = "luv-assembling-machine-recipes",
	energy_required = 40 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "itbtc-alloy-wire", amount = 16 },
		{ type = "item", name = "enderium-plate", amount = 10 },
		{ type = "item", name = "luv-pump", amount = 1 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1200 },
	}
}
create_recipe{
	recipe_name = "crystal-processor-mainframe",
	category = "luv-circuit-assembly-line-recipes",
	energy_required = LUV_SPEED * 480,
	ingredients = {
		{ type = "item", name = "hsss-frame", amount = 16 },
		{ type = "item", name = "zpm-circuit", amount = 32 },
		{ type = "item", name = "advanced-smd-inductor-wrap", amount = 8 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 16 },
		{ type = "item", name = "ram-chip-wrap", amount = 32 },
		{ type = "item", name = "luv-superconductor-wire-16x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 28.8 }
	},
	results = {
		{ type = "item", name = "uv-circuit", amount = 16 }
	}
}



---LAPOTRONIC ENERGY ORB CLUSTER (LUV BATTERY)
create_item{
	name = "lapotronic-energy-orb-cluster",
	category = "iv-circuit-assembler-recipes",
	energy_required = IV_SPEED * 51.2,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "high-powered-integrated-circuit", amount = 4 },
		{ type = "item", name = "lapotronic-energy-orb", amount = 8 },
		{ type = "item", name = "qubit-processing-unit", amount = 4 },
		{ type = "item", name = "fine-niobium-titanium-wire", amount = 16 },
		{ type = "item", name = "naquadah-alloy-plate", amount = 16 },
		{ type = "item", name = "naquadah-cable", amount = 32 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
	}
}
create_recipe{
	recipe_name = "lapotronic-energy-orb-cluster-assline",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "multilayered-fiber-reinforced-circuit-board", amount = 1 },
		{ type = "item", name = "naquadah-alloy-foil", amount = 64 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "engraved-lapotron-chip", amount = 72 },
		{ type = "item", name = "high-powered-integrated-circuit", amount = 64 },
		{ type = "item", name = "advanced-smd-diode", amount = 8 },
		{ type = "item", name = "advanced-smd-capacitor", amount = 8 },
		{ type = "item", name = "advanced-smd-resistor", amount = 8 },
		{ type = "item", name = "advanced-smd-transistor", amount = 8 },
		{ type = "item", name = "fine-platinum-wire", amount = 64 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 72 },
	},
	results = {
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 1 },
	}
}



-------------------------------
---   FUSION REACTOR MK 1   ---
-------------------------------

---SUPERCONDUCTING COIL BLOCK
create_item{
	name = "superconducting-coil-block",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 128 },
		{ type = "item", name = "niobium-titanium-foil", amount = 64 },
		{ type = "fluid", name = "molten-trinium", amount = 144 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}
create_recipe{
	recipe_name = "superconducting-coil-block-zpm",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "palladium-naqindium-superconductive-wire", amount = 64 },
		{ type = "item", name = "niobium-titanium-foil", amount = 32 },
		{ type = "fluid", name = "molten-trinium", amount = 57.6 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}
create_recipe{
	recipe_name = "superconducting-coil-block-uv",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 32 },
		{ type = "item", name = "niobium-titanium-foil", amount = 16 },
		{ type = "fluid", name = "molten-trinium", amount = 28.8 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
} 
create_recipe{
	recipe_name = "superconducting-coil-block-uhv",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 16 },
		{ type = "item", name = "niobium-titanium-foil", amount = 8 },
		{ type = "fluid", name = "molten-trinium", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}
create_recipe{
	recipe_name = "superconducting-coil-block-uev",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 8 },
		{ type = "item", name = "niobium-titanium-foil", amount = 4 },
		{ type = "fluid", name = "molten-trinium", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}
create_recipe{
	recipe_name = "superconducting-coil-block-uiv",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "chromnorox-superconductive-wire", amount = 4 },
		{ type = "item", name = "niobium-titanium-foil", amount = 2 },
		{ type = "fluid", name = "molten-trinium", amount = 3.6 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}
create_recipe{
	recipe_name = "superconducting-coil-block-umv",
	category = "luv-assembling-machine-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "hypocosmium-superconductive-wire", amount = 2 },
		{ type = "item", name = "niobium-titanium-foil", amount = 1 },
		{ type = "fluid", name = "molten-trinium", amount = 1.8 }
	},
	results = {
		{ type = "item", name = "superconducting-coil-block", amount = 1 }
	}
}

   
   
---FUSION REACTOR MK1 CONTROLLER
create_item{
	name = "fusion-reactor-mk1-controller",
	category = "luv-assembly-line-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "dense-naquadah-alloy-plate", amount = 4 },
		{ type = "item", name = "dense-osmiridium-plate", amount = 4 },
		{ type = "item", name = "osmiridium-plate", amount = 2 },
		{ type = "item", name = "luv-field-generator", amount = 2 },
		{ type = "item", name = "uhpic-wafer", amount = 32 },
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 32 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-vanadium-gallium", amount = 115.2 }
	}
}
create_item{
	name = "fusion-coil-block",
	ingredients = {
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "mv-field-generator", amount = 2 },
		{ type = "item", name = "iridium-neutron-reflector", amount = 2 },
		{ type = "item", name = "superconducting-coil-block", amount = 1 },
	}
}



---FUSION REACTOR MK1
create_item{
	name = "fusion-reactor-mk1",
	ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk1", amount = 1 },
			{ type = "item", name = "superconducting-coil-block", amount = 32 },
			{ type = "item", name = "luv-machine-casing", amount = 79 },
			{ type = "item", name = "luv-energy-hatch", amount = 16 },
			{ type = "item", name = "luv-machine-hull", amount = 32 }
	}
} 



---FUSION REACTOR MK2 CONTROLLER
create_item{
	name = "fusion-reactor-mk2-controller",
	category = "luv-assembly-line-recipes",
	energy_required = 50 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "superdense-europium-plate", amount = 1 },
		{ type = "item", name = "zpm-field-generator", amount = 2 },
		{ type = "item", name = "ppic-wafer", amount = 48 },
		{ type = "item", name = "palladium-naqindium-superconductive-wire", amount = 64 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-niobium-titanium", amount = 115.2 }
	}
}



---FUSION REACTOR MK2
create_item{
	name = "fusion-reactor-mk2",
	ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk2", amount = 1 },
			{ type = "item", name = "fusion-coil-block", amount = 32 },
			{ type = "item", name = "fusion-machine-casing", amount = 79 },
			{ type = "item", name = "zpm-energy-hatch", amount = 16 },
			{ type = "item", name = "zpm-machine-hull", amount = 32 }
	}
} 
create_item{
	name = "fusion-machine-casing",
	category = "iv-assembling-machine-recipes",
	energy_required = 5 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "luv-machine-casing", amount = 1 },
		{ type = "item", name = "hsss-plate", amount = 4 },
		{ type = "fluid", name = "molten-hssg", amount = 14.4 }
	}
}



---FUSION REACTOR MK3 CONTROLLER
create_item{
	name = "fusion-reactor-mk3-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = 50 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "superdense-americium-plate", amount = 1 },
		{ type = "item", name = "uv-field-generator", amount = 2 },
		{ type = "item", name = "qpic-wafer", amount = 64 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 128 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-fluxed-electrum", amount = 115.2 }
	}
}



---FUSION REACTOR MK3
create_item{
	name = "fusion-reactor-mk3",
	ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk3", amount = 1 },
			{ type = "item", name = "fusion-coil-block", amount = 32 },
			{ type = "item", name = "fusion-machine-casing-mk2", amount = 79 },
			{ type = "item", name = "uv-energy-hatch", amount = 16 },
			{ type = "item", name = "uv-machine-hull", amount = 32 }
	}
} 
create_item{
	name = "fusion-machine-casing-mk2",
	category = "luv-assembling-machine-recipes",
	energy_required = 10 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-machine-casing", amount = 1 },
		{ type = "item", name = "americium-plate", amount = 4 },
		{ type = "fluid", name = "molten-naquadah-alloy", amount = 28.8 }
	}
}
 


---FUSION REACTOR MK4 CONTROLLER
create_item{
	name = "fusion-reactor-mk4-controller",
	category = "uhv-assembly-line-recipes",
	energy_required = 300 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "advanced-fusion-coil", amount = 1 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "superdense-neutronium-plate", amount = 1 },
		{ type = "item", name = "uhv-field-generator", amount = 2 },
		{ type = "item", name = "qpic-wafer", amount = 64 },
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 128 },
		{ type = "fluid", name = "uu-matter", amount = 5000 },
		{ type = "fluid", name = "molten-cinobite-a243", amount = 921.6 },
		{ type = "fluid", name = "molten-octiron", amount = 921.6 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 921.6 }
	}
}
create_item{
	name = "advanced-fusion-coil",
	category = "uhv-assembling-machine-recipes",
	energy_required = 60 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "lapotronic-energy-orb-cluster", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 16 },
		{ type = "item", name = "uv-circuit", amount = 8 },
		{ type = "item", name = "neutronium-plate", amount = 8 },
		{ type = "item", name = "fusion-coil-block", amount = 1 },
		{ type = "item", name = "uhv-emitter", amount = 1 },
		{ type = "item", name = "uhv-sensor", amount = 1 },
		{ type = "fluid", name = "uu-matter", amount = 800 },
		{ type = "fluid", name = "molten-cinobite-a243", amount = 230.4 },
		{ type = "fluid", name = "molten-octiron", amount = 230.4 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 230.4 }
	}
}



---FUSION REACTOR MK4
create_item{
	name = "fusion-reactor-mk4",
	ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk4", amount = 1 },
			{ type = "item", name = "advanced-fusion-coil", amount = 32 },
			{ type = "item", name = "fusion-machine-casing-mk3", amount = 79 },
			{ type = "item", name = "uhv-energy-hatch", amount = 16 },
			{ type = "item", name = "uhv-machine-hull", amount = 32 }
	}
}
create_item{
	name = "fusion-machine-casing-mk3",
	category = "uvh-assembling-machine-recipes",
	energy_required = 15 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-machine-casing-mk2", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 16 },
		{ type = "item", name = "iv-circuit", amount = 8 },
		{ type = "item", name = "block-of-tungsten-carbide", amount = 8 },
		{ type = "item", name = "neutronium-plate", amount = 8 },
		{ type = "item", name = "uhv-motor", amount = 2 },
		{ type = "item", name = "uhv-piston", amount = 1 },
		{ type = "fluid", name = "uu-matter", amount = 100 },
		{ type = "fluid", name = "molten-cinobite-a243", amount = 57.6 },
		{ type = "fluid", name = "molten-octiron", amount = 57.6 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 57.6 }
	}
}

 

---FUSION REACTOR MK5 CONTROLLER
create_item{
	name = "fusion-reactor-mk5-controller",
	category = "uev-assembly-line-recipes",
	energy_required = 300 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "advanced-fusion-coil-ii", amount = 1 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "dense-metastable-oganesson-plate", amount = 1 },
		{ type = "item", name = "uev-field-generator", amount = 2 },
		{ type = "item", name = "pico-wafer", amount = 64 },
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 128 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 921.6 },
		{ type = "fluid", name = "molten-curium", amount = 921.6 },
		{ type = "fluid", name = "molten-abyssal-alloy", amount = 921.6 },
		{ type = "fluid", name = "molten-dragonblood", amount = 921.6 }
	}
}
create_item{
	name = "advanced-fusion-coil-ii",
	category = "uev-assembling-machine-recipes",
	energy_required = 60 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "energy-module", amount = 1 },
		{ type = "item", name = "zpm-circuit", amount = 16 },
		{ type = "item", name = "uhv-circuit", amount = 8 },
		{ type = "item", name = "rhugnor-plate", amount = 8 },
		{ type = "item", name = "advanced-compact-fusion-coil", amount = 1 },
		{ type = "item", name = "uev-emitter", amount = 1 },
		{ type = "item", name = "uev-sensor", amount = 1 },
		{ type = "fluid", name = "molten-neptunium", amount = 230.4 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 230.4 },
		{ type = "fluid", name = "molten-abyssal-alloy", amount = 230.4 },
		{ type = "fluid", name = "molten-dragonblood", amount = 230.4 }
	}
}



---FUSION REACTOR MK5
create_item{
	name = "fusion-reactor-mk5",
	ingredients = {
			{ type = "item", name = "fusion-reactor-computer-mk5", amount = 1 },
			{ type = "item", name = "advanced-fusion-coil-ii", amount = 32 },
			{ type = "item", name = "fusion-machine-casing-mk4", amount = 79 },
			{ type = "item", name = "uev-energy-hatch", amount = 16 },
			{ type = "item", name = "uev-machine-hull", amount = 32 }
	}
}
create_item{
	name = "fusion-machine-casing-mk4",
	category = "uev-assembling-machine-recipes",
	energy_required = 15 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "fusion-machine-casing-mk3", amount = 1 },
		{ type = "item", name = "iv-circuit", amount = 16 },
		{ type = "item", name = "luv-circuit", amount = 8 },
		{ type = "item", name = "block-of-naquadah-alloy", amount = 8 },
		{ type = "item", name = "chromatic-glass-plate", amount = 8 },
		{ type = "item", name = "uev-motor", amount = 2 },
		{ type = "item", name = "uev-piston", amount = 1 },
		{ type = "fluid", name = "molten-fermium", amount = 115.2 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 115.2 },
		{ type = "fluid", name = "molten-abyssal-alloy", amount = 115.2 },
		{ type = "fluid", name = "molten-dragonblood", amount = 115.2 }
	}
}
















   
   
   
   
--[==[ FORK: the water line (purified water grades) is an unfinished draft (recipes without a wrapper,
--- items used as fluids etc.) and only relevant from UV on in GT -> disabled until it is finished.
------------------
--- WATER LINE ---
------------------
   
   
   ---WATER PURIFICATION PLANT
create_item{
	name = "water-purification-plant",
	ingredients = {
		{ type = "item", name = "water-purification-plant-controller", amount = 1 },
		{ type = "item", name = "tungsten-frame", amount = 30 },
		{ type = "item", name = "sterile-water-plant-casing", amount = 72 },
		{ type = "item", name = "reinforced-sterile-water-plant-casing", amount = 77 },
		{ type = "item", name = "superplasticizer-treated-high-strength-concrete", amount = 56 },
		{ type = "item", name = "tinted-industrial-glass", amount = 6 },
		{ type = "item", name = "luv-eneregy-hatch", amount = 1 },
		{ type = "item", name = "lv-machine-hull", amount = 1 },
	},
	results = {
		{ type = "item", name = "water-purification-plant-linkage", amount = 16 }
	}
}
create_item{
	name = "water-purification-plant-controller",
	category = "luv-assembly-line-recipes",
	energy_required = LUV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "tungsten-frame", amount = 4 },
		{ type = "item", name = "sterile-water-plant-casing", amount = 8 },
		{ type = "item", name = "reinforced-sterile-water-plant-casing", amount = 8 },
		{ type = "item", name = "luv-motor", amount = 2 },
		{ type = "item", name = "luv-robot-arm", amount = 1 },
		{ type = "item", name = "luv-pump", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 2 },
		{ type = "item", name = "niobium-titanium-cable", amount = 64 },
		{ type = "fluid", name = "lubricant", amount = 1600 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
	}
}
create_item{
	name = "sterile-water-plant-casing",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "tungstensteel-frame", amount = 1 },
		{ type = "item", name = "ledox-plate", amount = 1 },
		{ type = "item", name = "iv-motor", amount = 2 },
		{ type = "item", name = "thin-pvc-sheet", amount = 4 },
		{ type = "fluid", name = "molten-ledox", amount = 57.6 },
	}
}
create_item{
	name = "sterile-water-plant-casing",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "tungstensteel-frame", amount = 1 },
		{ type = "item", name = "ledox-plate", amount = 1 },
		{ type = "item", name = "iv-motor", amount = 2 },
		{ type = "item", name = "thin-pvc-sheet", amount = 4 },
		{ type = "fluid", name = "molten-ledox", amount = 57.6 },
	}
}  
create_item{
	name = "reinforced-sterile-water-plant-casing",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "sterile-water-plant-casing", amount = 1 },
		{ type = "item", name = "ruridit-bolt", amount = 16 },
		{ type = "fluid", name = "liquid-concrete", amount = 115.2 },
	}
}
create_item{
	name = "superplasticizer-treated-high-strength-concrete",
	category = "iv-assembling-machine-recipes",
	energy_required = IV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "reinforced-stone", amount = 1 },
		{ type = "fluid", name = "naphthalene", amount = 100 },
	}
} 




---NAPHTHALENE
create_recipe{
	recipe_name = "coal-tar",
	category = "mv-pyrolyse-oven-recipes",
	enabled = false,
	energy_required = 32 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "coal", amount = 12 },
	},
	results = {
		{ type = "fluid", name = "coal-tar", amount = 220 },
	}
} 
create_recipe{
	recipe_name = "coal-tar",
	category = "hv-tall-distillation-recipes",
	energy_required = 15 * HV_SPEED,
	ingredients = {
		{ type = "fluid", name = "coal-tar", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "ethylbenzene", amount = 20 },
		{ type = "fluid", name = "anthracene", amount = 5 },
		{ type = "fluid", name = "kerosene", amount = 60 },
		{ type = "fluid", name = "coal-tar-oil", amount = 60 },
		{ type = "fluid", name = "naphtha", amount = 15 },
	},
	main_product = "coal-tar-oil"
} 
create_recipe{
	recipe_name = "sulfuric-coal-tar-oil",
	category = "lv-chemical-reactor-recipes",
	energy_required = 16,
	ingredients = {
		{ type = "fluid", name = "coal-tar-oil", amount = 800 },
		{ type = "fluid", name = "sulfuric-acid", amount = 800 },
	},
	results = {
		{ type = "fluid", name = "sulfuric-coal-tar-oil", amount = 1600 },
	}
} 

	{
		type = "recipe",
		name = "sulfuric-coal-tar-oil-distillation",
		category = "lv-distillation-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "fluid", name = "sulfuric-coal-tar-oil", amount = 200 },
		},
		results = {
			{ type = "fluid", name = "naphthalene", amount = 200 },
		}
   },



	{
		type = "item",
		name = "tinted-industrial-glass",
		icon = "__gregtorio-continued__/graphics/icons/tinted-industrial-glass.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "tinted-industrial-glass",
		category = "assembling-machine-recipes",
		enabled = false,
		energy_required = 10,
		ingredients = {
			{ type = "item", name = "steel-frame", amount = 1 },
			{ type = "item", name = "glass", amount = 4 },
		},
		results = {
			{ type = "item", name = "tinted-industrial-glass", amount = 1 }
		}
   },    
   
   
   
   ---CLARIFIER PURIFICATION UNIT
	{
		type = "item",
		name = "clarifier-purification-unit",
		icon = "__gregtorio-continued__/graphics/icons/clarifier-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "clarifier-purification-unit",
		category = "luv-assembling-machine-recipes",
		enabled = false,
		energy_required = 128,
		ingredients = {
			{ type = "item", name = "water-purification-plant-linkage", amount = 1 },
			{ type = "item", name = "clarifier-purification-unit-controller", amount = 1 },
			{ type = "item", name = "reinforced-sterile-water-plant-casing", amount = 127 },
			{ type = "item", name = "iridium-frame", amount = 24 },
			{ type = "item", name = "filter-casing", amount = 21 },
			{ type = "item", name = "ptfe-pipe-casing", amount = 3 },
			{ type = "item", name = "lv-machine-hull", amount = 4 },
		},
		results = {
			{ type = "item", name = "clarifier-purification-unit", amount = 1 }
		}
   },    
	{
		type = "item",
		name = "clarifier-purification-unit-controller",
		icon = "__gregtorio-continued__/graphics/icons/clarifier-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "clarifier-purification-unit-controller",
		category = "luv-assembly-line-recipes",
		enabled = false,
		energy_required = 1920,
		ingredients = {
			{ type = "item", name = "activated-carbon-mesh-filter", amount = 16 },
			{ type = "item", name = "reinforced-sterile-water-plant-casing", amount = 8 },
			{ type = "item", name = "filter-casing", amount = 8 },
			{ type = "item", name = "luv-energy-hatch", amount = 1 },
			{ type = "item", name = "luv-motor", amount = 4 },
			{ type = "item", name = "luv-pump", amount = 4 },
			{ type = "item", name = "luv-circuit", amount = 4 },
			{ type = "item", name = "zpm-circuit", amount = 2 },
			{ type = "item", name = "tungstensteel-plate", amount = 48 },
			{ type = "fluid", name = "lubricant", amount = 1600 },
			{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
			{ type = "fluid", name = "molten-osmium", amount = 115.2 },
		},
		results = {
			{ type = "item", name = "clarifier-purification-unit-controller", amount = 1 }
		}
   },  



---ACTIVATED CARBON MESH FILTER   
	{
		type = "item",
		name = "activated-carbon-mesh-filter",
		icon = "__gregtorio-continued__/graphics/icons/activated-carbon-mesh-filter.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "activated-carbon-mesh-filter",
		category = "iv-assembling-machine-recipes",
		enabled = false,
		energy_required = 160,
		ingredients = {
			{ type = "item", name = "activated-carbon", amount = 64 },
			{ type = "item", name = "zinc-foil", amount = 16 },
		},
		results = {
			{ type = "item", name = "activated-carbon-mesh-filter", amount = 1 }
		}
   }, 



---ACTIVATED CARBON 
	{
		type = "item",
		name = "pre-activated-carbon",
		icon = "__gregtorio-continued__/graphics/icons/pre-activated-carbon.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "pre-activated-carbon",
		category = "luv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 160,
		ingredients = {
			{ type = "item", name = "carbon", amount = 1 },
			{ type = "fluid", name = "phosphoric-acid", amount = 100 },
		},
		results = {
			{ type = "item", name = "pre-activated-carbon", amount = 1 }
		}
   },   
	{
		type = "item",
		name = "dirty-activated-carbon",
		icon = "__gregtorio-continued__/graphics/icons/dirty-activated-carbon.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "dirty-activated-carbon",
		category = "ev-blast-furnace-recipes",
		enabled = false,
		energy_required = 80,
		ingredients = {
			{ type = "item", name = "pre-activated-carbon", amount = 1 },
		},
		results = {
			{ type = "item", name = "dirty-activated-carbon", amount = 1 }
		}
   },   
	{
		type = "item",
		name = "activated-carbon",
		icon = "__gregtorio-continued__/graphics/icons/activated-carbon.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "activated-carbon",
		category = "iv-blast-furnace-recipes",
		enabled = false,
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "dirty-activated-carbon", amount = 1 },
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = {
			{ type = "item", name = "activated-carbon", amount = 1 },
			{ type = "fluid", name = "phosphoric-acid", amount = 100 },
		},
		main_product = "activated-carbon"
   },


---GRADE ONE WATER 
	{
		type = "recipe",
		name = "filtered-water-grade-1",
		category = "clarifier-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "fluid", name = "water", amount = 100 },
			{ type = "item", name = "activated-carbon-mesh-filter", amount = 1 },
		},
		results = {
			{ type = "fluid", name = "filtered-water-grade-1", amount = 90, probability = 0.7 },
			{ type = "item", name = "activated-carbon-mesh-filter", amount = 1, probability = 0.8 },
			{ type = "item", name = "stick", amount = 1, probability = 0.10 },
			{ type = "item", name = "stone-dust", amount = 1, probability = 0.05 },
			{ type = "item", name = "gold-dust", amount = 1, probability = 0.01 },
		},
		main_product = "filtered-water-grade-1"
   },   



   ---OZONATION PURIFICATION UNIT
	{
		type = "item",
		name = "ozonation-purification-unit",
		icon = "__gregtorio-continued__/graphics/icons/ozonation-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "ozonation-purification-unit",
		category = "luv-assembling-machine-recipes",
		enabled = false,
		energy_required = 128,
		ingredients = {
			{ type = "item", name = "water-purification-plant-linkage", amount = 1 },
			{ type = "item", name = "ozonation-purification-unit-controller", amount = 1 },
			{ type = "item", name = "inert-filtration-casing", amount = 99 },
			{ type = "item", name = "tungstensteel-frame", amount = 6 },
			{ type = "item", name = "tinted-industrial-glass", amount = 9 },
			{ type = "item", name = "reactive-gas-containment-casing", amount = 28 },
			{ type = "item", name = "ptfe-pipe-casing", amount = 3 },
			{ type = "item", name = "lv-machine-hull", amount = 3 },
		},
		results = {
			{ type = "item", name = "ozonation-purification-unit", amount = 1 }
		}
   },    
	{
		type = "item",
		name = "ozonation-purification-unit-controller",
		icon = "__gregtorio-continued__/graphics/icons/ozonation-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "ozonation-purification-unit-controller",
		category = "luv-assembly-line-recipes",
		enabled = false,
		energy_required = 1920,
		ingredients = {
			{ type = "item", name = "tungstensteel-frame", amount = 8 },
			{ type = "item", name = "inert-filtration-casing", amount = 8 },
			{ type = "item", name = "filter-casing", amount = 8 },
			{ type = "item", name = "luv-energy-hatch", amount = 1 },
			{ type = "item", name = "hastelloy-c276-plate", amount = 8 },
			{ type = "item", name = "hastelloy-c276-rotor", amount = 4 },
			{ type = "item", name = "hastelloy-x-plate", amount = 8 },
			{ type = "item", name = "hastelloy-x-rotor", amount = 4 },
			{ type = "item", name = "luv-motor", amount = 4 },
			{ type = "item", name = "luv-pump", amount = 4 },
			{ type = "item", name = "luv-circuit", amount = 8 },
			{ type = "item", name = "zpm-circuit", amount = 4 },
			{ type = "item", name = "tungstensteel-plate", amount = 48 },
			{ type = "fluid", name = "lubricant", amount = 1600 },
			{ type = "fluid", name = "molten-indalloy-140", amount = 115.2 },
			{ type = "fluid", name = "molten-hastelloy-c276", amount = 115.2 },
			{ type = "fluid", name = "molten-hastelloy-x", amount = 115.2 },
		},
		results = {
			{ type = "item", name = "ozonation-purification-unit-controller", amount = 1 }
		}
   },    
	{
		type = "item",
		name = "inert-filtration-casing",
		icon = "__gregtorio-continued__/graphics/icons/inert-filtration-casing.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "inert-filtration-casing",
		category = "iv-assembly-line-recipes",
		enabled = false,
		energy_required = 160,
		ingredients = {
			{ type = "item", name = "hastelloy-c276-frame", amount = 1 },
			{ type = "item", name = "hastelloy-x-plate", amount = 6 },
			{ type = "item", name = "hastelloy-c276-rotor", amount = 2 },
			{ type = "item", name = "large-hastelloy-c276-gear", amount = 2 },
			{ type = "item", name = "iv-pump", amount = 1 },
			{ type = "fluid", name = "ptfe", amount = 57.6 },
		},
		results = {
			{ type = "item", name = "inert-filtration-casing", amount = 1 }
		}
   },   
	{
		type = "item",
		name = "reactive-gas-containment-casing",
		icon = "__gregtorio-continued__/graphics/icons/reactive-gas-containment-casing.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "reactive-gas-containment-casing",
		category = "iv-assembly-line-recipes",
		enabled = false,
		energy_required = 160,
		ingredients = {
			{ type = "item", name = "hastelloy-w-frame", amount = 1 },
			{ type = "item", name = "hastelloy-w-plate", amount = 6 },
			{ type = "item", name = "hastelloy-w-rotor", amount = 1 },
			{ type = "fluid", name = "ptfe", amount = 57.6 },
		},
		results = {
			{ type = "item", name = "reactive-gas-containment-casing", amount = 1 }
		}
   }, 
   
   
   
---OZONE   
	{
		type = "recipe",
		name = "ozone",
		category = "luv-laser-engraver-recipes",
		enabled = false,
		energy_required = 32,
		ingredients = {
			{ type = "fluid", name = "air", amount = 1000 },
		},
		results = {
			{ type = "fluid", name = "ozone", amount = 200 }
		}
   },    



---GRADE TWO WATER   
	{
		type = "recipe",
		name = "ozonated-water-grade-2",
		category = "ozonation-purification-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "fluid", name = "filtered-water-grade-1", amount = 100 },
			{ type = "fluid", name = "ozone", amount = 102400 },
		},
		results = {
			{ type = "fluid", name = "ozonated-water-grade-2", amount = 90, probability = 0.8 },
			{ type = "item", name = "iron-dust", amount = 1, probability = 0.05 },
			{ type = "item", name = "manganese-dust", amount = 1, probability = 0.05 },
			{ type = "item", name = "sulfur", amount = 1, probability = 0.05 },
		},
		main_product = "ozonated-water-grade-2"
   }, 
   
   
   
   ---FLOCCULATION PURIFICATION UNIT
	{
		type = "item",
		name = "flocculation-purification-unit",
		icon = "__gregtorio-continued__/graphics/icons/flocculation-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "flocculation-purification-unit",
		category = "zpm-assembling-machine-recipes",
		enabled = false,
		energy_required = 256,
		ingredients = {
			{ type = "item", name = "water-purification-plant-linkage", amount = 1 },
			{ type = "item", name = "flocculation-purification-unit-controller", amount = 1 },
			{ type = "item", name = "slick-sterile-flocculation-casing", amount = 61 },
			{ type = "item", name = "sterile-water-plant-casing", amount = 30 },
			{ type = "item", name = "reinforced-sterile-water-plant-casing", amount = 16 },
			{ type = "item", name = "adamantium-frame", amount = 12 },
			{ type = "item", name = "tinted-industrial-glass", amount = 6 },
			{ type = "item", name = "filter-casing", amount = 3 },
			{ type = "item", name = "lv-machine-hull", amount = 4 },
		},
		results = {
			{ type = "item", name = "flocculation-purification-unit", amount = 1 }
		}
   },    
   
   
   
---FLOCCULATION PURIFICATION UNIT CONTROLLER
	{
		type = "item",
		name = "flocculation-purification-unit-controller",
		icon = "__gregtorio-continued__/graphics/icons/flocculation-purification-unit.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "flocculation-purification-unit-controller",
		category = "zpm-assembly-line-recipes",
		enabled = false,
		energy_required = 3840,
		ingredients = {
			{ type = "item", name = "adamantium-frame", amount = 8 },
			{ type = "item", name = "slick-sterile-flocculation-casing", amount = 8 },
			{ type = "item", name = "filter-casing", amount = 8 },
			{ type = "item", name = "luv-energy-hatch", amount = 1 },
			{ type = "item", name = "trinium-plate", amount = 8 },
			{ type = "item", name = "trinium-rotor", amount = 4 },
			{ type = "item", name = "naquadah-alloy-plate", amount = 8 },
			{ type = "item", name = "naquadah-alloy-rotor", amount = 4 },
			{ type = "item", name = "zpm-motor", amount = 4 },
			{ type = "item", name = "zpm-pump", amount = 4 },
			{ type = "item", name = "zpm-circuit", amount = 8 },
			{ type = "item", name = "uv-circuit", amount = 4 },
			{ type = "item", name = "naquadah-plate", amount = 96 },
			{ type = "fluid", name = "lubricant", amount = 3200 },
			{ type = "fluid", name = "molten-indalloy-140", amount = 230.4 },
			{ type = "fluid", name = "molten-iridium", amount = 230.4 },
			{ type = "fluid", name = "molten-naquadah-alloy", amount = 230.4 },
		},
		results = {
			{ type = "item", name = "flocculation-purification-unit-controller", amount = 1 }
		}
   },
   
   
   
	{
		type = "item",
		name = "slick-sterile-flocculation-casing",
		icon = "__gregtorio-continued__/graphics/icons/slick-sterile-flocculation-casing.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "slick-sterile-flocculation-casing",
		category = "luv-assembly-line-recipes",
		enabled = false,
		energy_required = 320,
		ingredients = {
			{ type = "item", name = "stainless-steel-frame", amount = 1 },
			{ type = "item", name = "stainless-steel-plate", amount = 12 },
			{ type = "item", name = "tungstensteel-plate", amount = 12 },
			{ type = "item", name = "iv-pump", amount = 1 },
			{ type = "fluid", name = "ptfe", amount = 57.6 },
		},
		results = {
			{ type = "item", name = "slick-sterile-flocculation-casing", amount = 1 }
		}
   },



---GRADE THREE WATER   
	{
		type = "recipe",
		name = "flocculated-water-grade-3",
		category = "flocculation-purification-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "fluid", name = "ozonated-water-grade-2", amount = 100 },
			{ type = "fluid", name = "polyaluminium-chloride", amount = 90000 },
		},
		results = {
			{ type = "fluid", name = "flocculated-water-grade-3", amount = 90, probability = 0.6 },
			{ type = "fluid", name = "flocculated-waste-liquid", amount = 90000 },
			{ type = "item", name = "clay", amount = 1, probability = 0.1 },
			{ type = "item", name = "quartz-sand", amount = 1, probability = 0.05 },
		}
   },
	{
		type = "recipe",
		name = "polyaluminium-chloride",
		category = "ev-chemical-reactor-recipes",
		enabled = false,
		energy_required = 32,
		ingredients = {
			{ type = "item", name = "aluminium-hydroxide", amount = 8 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 300 },
		},
		results = {
			{ type = "fluid", name = "polyaluminium-chloride", amount = 100 },
			{ type = "fluid", name = "water", amount = 300 },
		}
   },   
	{
		type = "recipe",
		name = "flocculated-waste-liquid-processing",
		category = "ev-tall-distillation-recipes",
		enabled = false,
		energy_required = 8,
		ingredients = {
			{ type = "item", name = "flocculated-waste-liquid", amount = 1000 },
		},
		results = {
			{ type = "fluid", name = "aluminium-dust", amount = 20 },
			{ type = "fluid", name = "oxygen", amount = 3000 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 3000 },
		}
   }, 









]==]
----------------------
--- FUSION RECIPES ---
----------------------  

---HELIUM PLASMA
create_recipe{
    name = "helium-plasma-first",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = EV_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "deuterium", amount = 125 },
      {type = "fluid", name = "helium-3", amount = 125 },
    },
    results = {
      {type = "fluid", name = "helium-plasma", amount = 125 },
    }
}
create_recipe{
    name = "helium-plasma-second",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = IV_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "deuterium", amount = 125 },
      {type = "fluid", name = "tritium", amount = 125 },
    },
    results = {
      {type = "fluid", name = "helium-plasma", amount = 125 },
    }
}



---SUNNARIUM
create_recipe{
    name = "molten-sunnarium",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = IV_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "molten-glowstone", amount = 16 },
      {type = "fluid", name = "helium-plasma", amount = 4 },
    },
    results = {
      {type = "fluid", name = "molten-sunnarium", amount = 16 },
    }
}



---EUROPIUM
create_recipe{
    recipe_name = "molten-europium",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "molten-neodymium", amount = 16 },
      {type = "fluid", name = "hydrogen", amount = 48 },
    },
    results = {
      {type = "fluid", name = "molten-europium", amount = 16 },
    }
}
create_item{
    name = "europium-ingot",
    category = "lv-fluid-solidifier-recipes",	
    energy_required = 1.6,
	ingredients = {
      {type = "fluid", name = "molten-europium", amount = 14.4 },
    }
}



---DURANIUM
create_recipe{
    recipe_name = "molten-gallium",
    category = "lv-extractor-recipes",	
    energy_required = 1.2,
	ingredients = {
      {type = "item", name = "gallium", amount = 1 },
    },
    results = {
      {type = "fluid", name = "molten-gallium", amount = 14.4 },
    }
}
create_recipe{
    recipe_name = "molten-duranium",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 32,
	ingredients = {
      {type = "fluid", name = "molten-gallium", amount = 16 },
      {type = "fluid", name = "radon", amount = 125 },
    },
    results = {
      {type = "fluid", name = "molten-duranium", amount = 16 },
    }
}



---BORON PLASMA
create_recipe{
    recipe_name = "molten-lithium",
    category = "lv-extractor-recipes",	
    energy_required = 1.2,
	ingredients = {
      {type = "item", name = "lithium", amount = 1 },
    },
    results = {
      {type = "fluid", name = "molten-lithium", amount = 14.4 },
    }
}
create_recipe{
    recipe_name = "boron-plasma",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 12,
	ingredients = {
      {type = "fluid", name = "helium-plasma", amount = 14.4 },
      {type = "fluid", name = "molten-lithium", amount = 14.4 },
    },
    results = {
      {type = "fluid", name = "boron-plasma", amount = 14.4 },
    }
}



---CALCIUM PLASMA
create_recipe{
    recipe_name = "molten-magnesium",
    category = "mv-extractor-recipes",	
    energy_required = MV_SPEED * 1.2,
	ingredients = {
      {type = "item", name = "magnesium", amount = 1 },
    },
    results = {
      {type = "fluid", name = "molten-magnesium", amount = 14.4 },
    }
}
create_recipe{
    recipe_name = "calcium-plasma",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = IV_SPEED * 64,
    subgroup = "subgroup-plasma-t1",
	ingredients = {
      {type = "fluid", name = "molten-magnesium", amount = 128 },
      {type = "fluid", name = "oxygen", amount = 128 },
    },
    results = {
      {type = "fluid", name = "calcium-plasma", amount = 16 },
    }
}



---NEON PLASMA
create_recipe{
    recipe_name = "neon-plasma",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 32,
	ingredients = {
      {type = "fluid", name = "boron-plasma", amount = 144 },
      {type = "fluid", name = "calcium-plasma", amount = 16 },
    },
    results = {
      {type = "fluid", name = "neon-plasma", amount = 1000 },
    }
}



---FORCE PLASMA
create_recipe{
    recipe_name = "force-plasma",
    category = "mk1-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "neon-plasma", amount = 144 },
      {type = "fluid", name = "molten-arcanite", amount = 2 },
    },
    results = {
      {type = "fluid", name = "force-plasma", amount = 1000 },
    }
}



---URANIUM BASED LIQUID FUEL
create_recipe{
    recipe_name = "excited-uranium-based-liquid-fuel",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = IV_SPEED * 20,
	ingredients = {
      {type = "fluid", name = "uranium-based-liquid-fuel", amount = 10 },
      {type = "fluid", name = "hydrogen", amount = 100 },
    },
    results = {
      {type = "fluid", name = "excited-uranium-based-liquid-fuel", amount = 10 },
    }
}



---SULFUR PLASMA
create_recipe{
    recipe_name = "sulfur-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "molten-lithium", amount = 16 },
      {type = "fluid", name = "molten-aluminium", amount = 16 },
    },
    results = {
      {type = "fluid", name = "sulfur-plasma", amount = 144 },
    }
}



---PLUTONIUM BASED LIQUID FUEL
create_recipe{
    recipe_name = "excited-plutonium-based-liquid-fuel",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 10,
	ingredients = {
      {type = "fluid", name = "plutonium-based-liquid-fuel", amount = 20 },
      {type = "fluid", name = "molten-lutetium", amount = 16 },
    },
    results = {
      {type = "fluid", name = "excited-plutonium-based-liquid-fuel", amount = 20 },
    }
}



---NITROGEN PLASMA
create_recipe{
    recipe_name = "nitrogen-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "molten-beryllium", amount = 16 },
      {type = "fluid", name = "deuterium", amount = 375 },
    },
    results = {
      {type = "fluid", name = "nitrogen-plasma", amount = 125 },
    }
}



---TRITANIUM
create_recipe{
    recipe_name = "molten-tritanium",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 32,
	ingredients = {
      {type = "fluid", name = "molten-titanium", amount = 48 },
      {type = "fluid", name = "molten-duranium", amount = 32 },
    },
    results = {
      {type = "fluid", name = "molten-tritanium", amount = 16 },
    }
}



---NAQUADAH BASED FUEL MK1
create_recipe{
    recipe_name = "naquadah-based-fuel-mk1",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = LUV_SPEED * 25,
	ingredients = {
      {type = "fluid", name = "light-naquadah-fuel", amount = 78 },
      {type = "fluid", name = "heavy-naquadah-fuel", amount = 36 },
    },
    results = {
      {type = "fluid", name = "naquadah-based-fuel-mk1", amount = 10 },
    }
}



---ZINC PLASMA
create_recipe{
    recipe_name = "zinc-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "molten-copper", amount = 72 },
      {type = "fluid", name = "tritium", amount = 250 },
    },
    results = {
      {type = "fluid", name = "zinc-plasma", amount = 72 },
    }
}



---NIOBIUM PLASMA
create_recipe{
    recipe_name = "niobium-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "molten-cobalt", amount = 144 },
      {type = "fluid", name = "molten-silicon", amount = 144 },
    },
    results = {
      {type = "fluid", name = "niobium-plasma", amount = 144 },
    }
}



---TIN PLASMA
create_recipe{
    recipe_name = "tin-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "molten-silver", amount = 144 },
      {type = "fluid", name = "helium-3", amount = 375 },
    },
    results = {
      {type = "fluid", name = "tin-plasma", amount = 288 },
    }
}



---MOLTEN AMERICIUM
create_recipe{
    recipe_name = "molten-americium",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 48,
	ingredients = {
      {type = "fluid", name = "molten-lutetium", amount = 16 },
      {type = "fluid", name = "molten-chrome", amount = 16 },
    },
    results = {
      {type = "fluid", name = "molten-americium", amount = 16 },
    }
}



---TITANIUM PLASMA
create_recipe{
    recipe_name = "titanium-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 80,
	ingredients = {
      {type = "fluid", name = "molten-aluminium", amount = 144 },
      {type = "fluid", name = "fluorine", amount = 144 },
    },
    results = {
      {type = "fluid", name = "titanium-plasma", amount = 144 },
    }
}



---OXYGEN PLASMA
create_recipe{
    recipe_name = "oxygen-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 120,
	ingredients = {
      {type = "fluid", name = "molten-lithium", amount = 144 },
      {type = "fluid", name = "boron-plasma", amount = 144 },
    },
    results = {
      {type = "fluid", name = "oxygen-plasma", amount = 144 },
    }
}



---KRYTPON PLASMA
create_recipe{
    recipe_name = "krypton-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "niobium-plasma", amount = 144 },
      {type = "fluid", name = "zinc-plasma", amount = 144 },
    },
    results = {
      {type = "fluid", name = "krypton-plasma", amount = 144 },
    }
}



---ASTRAL TITANIUM PLASMA
create_recipe{
    recipe_name = "astral-titanium-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "krypton-plasma", amount = 144 },
      {type = "fluid", name = "force-plasma", amount = 1000 },
    },
    results = {
      {type = "fluid", name = "astral-titanium-plasma", amount = 1000 },
    }
}



---RUNITE PLASMA
create_recipe{
    recipe_name = "runite-plasma",
    category = "mk2-fusion-reactor-recipes",	
    energy_required = ZPM_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "astral-titanium-plasma", amount = 144 },
      {type = "fluid", name = "molten-titansteel", amount = 2 },
    },
    results = {
      {type = "fluid", name = "runite-plasma", amount = 1000 },
    }
}



---IRON PLASMA
create_recipe{
    recipe_name = "iron-plasma",
    category = "mk3-fusion-reactor-recipes",	
    energy_required = IV_SPEED * 16,
	ingredients = {
      {type = "fluid", name = "molten-silicon", amount = 16 },
      {type = "fluid", name = "molten-magnesium", amount = 16 },
    },
    results = {
      {type = "fluid", name = "iron-plasma", amount = 144 },
    }
}









---MOLTEN RHUGNOR
create_recipe{
    recipe_name = "molten-rhugnor",
    category = "mk4-fusion-reactor-recipes",	
    energy_required = UV_SPEED * 25.6,
	ingredients = {
      {type = "fluid", name = "molten-infinity", amount = 14.4 },
      {type = "fluid", name = "molten-quantum", amount = 28.8 },
    },
    results = {
      {type = "fluid", name = "molten-rhugnor", amount = 14.4 },
    }
}



---MOLTEN FLEROVIUM
create_recipe{
    recipe_name = "molten-flerovium",
    category = "mk4-fusion-reactor-recipes",	
    energy_required = UV_SPEED * 8,
	ingredients = {
      {type = "fluid", name = "molten-plutonium-241", amount = 14.4 },
      {type = "fluid", name = "calcium-plasma", amount = 14.4 },
    },
    results = {
      {type = "fluid", name = "molten-flerovium", amount = 14.4 },
    }
}















-------------------------
---   FUEL FLUIDS  ---
-------------------------

---PLUTONIUM BASED LIQUID FUEL
create_item{
    name = "wrapped-plutonium-ingot",
    category = "ev-assembling-machine-recipes",	
    energy_required = EV_SPEED * 90,
	ingredients = {
		{type = "item", name = "plutonium-uranium-oxide-mixture", amount = 8 },
		{type = "item", name = "hsss-foil", amount = 4 },
    }
}
create_item{
    name = "high-density-plutonium-nugget",
    category = "lv-implosion-compressor-recipes",	
	ingredients = {
		{type = "item", name = "wrapped-plutonium-ingot", amount = 2 },
		{type = "item", name = "explosives", amount = 1 }
    },
    results = {
		{type = "item", name = "high-density-plutonium-nugget", amount = 1 },
		{type = "item", name = "hsss-dust", amount = 1, probability = 0.888 },
    },
	main_product = "high-density-plutonium-nugget"
}
create_item{
    name = "high-density-plutonium",
    category = "mv-compressor-recipes",	
    energy_required = MV_SPEED * 60,
	ingredients = {
		{type = "item", name = "high-density-plutonium-nugget", amount = 9 }
    }
}
create_item{
    name = "high-density-plutonium-eic",
    category = "uev-electric-implosion-compressor-recipes",	
    energy_required = UEV_SPEED * 0.05,
	ingredients = {
		{type = "item", name = "high-density-plutonium-nugget", amount = 5 },
		{type = "fluid", name = "molten-neutronium", amount = 7.2 },
    },
    results = {
		{type = "item", name = "high-density-plutonium", amount = 1 },
    },
	main_product = "high-density-plutonium-nugget"
}
create_recipe{
    recipe_name = "plutonium-based-liquid-fuel",
    category = "luv-mixer-recipes",	
    energy_required = LUV_SPEED * 18,
	ingredients = {
      {type = "item", name = "high-density-plutonium", amount = 1 },
      {type = "item", name = "neutronium-dust", amount = 8 },
      {type = "item", name = "caesium-dust", amount = 16 },
      {type = "item", name = "naquadah-dust", amount = 2 },
    },
    results = {
      {type = "fluid", name = "plutonium-based-liquid-fuel", amount = 100 },
    }
}








-------------------------
---   MAGICAL INGOTS  ---
-------------------------

create_recipe{
    recipe_name = "microminer-infused-gold",
    category = "lv-assembling-machine-recipes",	
    energy_required = LUV_SPEED * 2,
    subgroup = "subgroup-microminer-t5",
	ingredients = {
		{type = "item", name = "tier-five-microminer-output", amount = 1 }
    },
    results = {
		{type = "item", name = "raw-gold", amount = 32 },
		{type = "item", name = "raw-infused-gold", amount = 16 },
		{type = "item", name = "raw-platinum", amount = 8 },
		{type = "item", name = "raw-iridium", amount = 8 },
    },
	main_product = "raw-infused-gold"
}
create_item{
    name = "salis-mundis",
    category = "mv-centrifuge-recipes",	
    energy_required = MV_SPEED * 20,
	ingredients = {
		{type = "item", name = "infused-gold-dust", amount = 1 },
		{type = "fluid", name = "mercury", amount = 20 }
    },
    results = {
		{type = "item", name = "gold-dust", amount = 2 },
		{type = "item", name = "salis-mundis", amount = 2 },
    },
	main_product = "salis-mundis"
}
create_item{
    name = "magic-essence",
    category = "mv-autoclave-recipes",	
    energy_required = MV_SPEED * 120,
	ingredients = {
		{type = "item", name = "salis-mundis", amount = 4 },
		{type = "fluid", name = "uu-matter", amount = 10 }
    }
}



---THAUMIUM
create_item{
    name = "thaumium-dust",
    category = "hv-chemical-reactor-recipes",	
    energy_required = HV_SPEED * 20,
	ingredients = {
		{type = "item", name = "infused-gold-dust", amount = 8 },
		{type = "item", name = "iron-dust", amount = 8 },
		{type = "fluid", name = "lapis-coolant", amount = 100 },
    }
}



---VOID METAL
create_item{
    name = "void-metal-dust",
    category = "hv-chemical-reactor-recipes",	
    energy_required = HV_SPEED * 12,
	ingredients = {
		{type = "item", name = "thaumium-dust", amount = 1 },
		{type = "item", name = "magic-essence", amount = 1 },
		{type = "fluid", name = "uu-matter", amount = 10 },
    }
}



---SHADOW METAL
create_item{
    name = "shadow-metal-dust",
    category = "iv-chemical-reactor-recipes",	
    energy_required = IV_SPEED * 12,
	ingredients = {
		{type = "item", name = "void-metal-dust", amount = 1 },
		{type = "item", name = "magic-essence", amount = 2 },
		{type = "fluid", name = "uu-matter", amount = 20 },
    }
}



---ICHORIUM
create_item{
    name = "ichorium-dust",
    category = "luv-chemical-reactor-recipes",	
    energy_required = LUV_SPEED * 90,
	ingredients = {
		{type = "item", name = "shadow-metal-dust", amount = 1 },
		{type = "item", name = "magic-essence", amount = 4 },
		{type = "fluid", name = "uu-matter", amount = 40 }
    }
}





------------------------------------
---   LAPOTRONIC SUPERCAPCITOR   ---
------------------------------------
   
create_item{
	name = "lapotronic-supercapacitor-controller",
	ingredients = {
		{ type = "item", name = "lapotron-crystal", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 2 },
		{ type = "item", name = "lapotronic-supercapacitor-casing", amount = 1 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 2 },
	}
}
create_item{
	name = "lapotronic-supercapacitor-casing",
	ingredients = {
		{ type = "item", name = "tantalum-plate", amount = 4 },
		{ type = "item", name = "lapis-lazuli-block", amount = 1 },
		{ type = "item", name = "tungstensteel-frame", amount = 2 },
		{ type = "item", name = "long-tungstensteel-rod", amount = 2 },
	}
}





---1080K SUPER COOLANT CELL
create_item{
	name = "1080k-super-coolant-cell",
	category = "lv-canning-machine-recipes",
	energy_required = 4.8,
	ingredients = {
		{ type = "item", name = "1080k-space-cell", amount = 1 },
		{ type = "fluid", name = "super-coolant", amount = 600 },
	}
}



---1080K SPACE CELL
create_item{
	name = "1080k-space-cell",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "540k-space-cell", amount = 2 },
		{ type = "item", name = "tungstensteel-plate", amount = 6 },
		{ type = "item", name = "dense-fluxed-electrum-plate", amount = 1 },
	}
}



---540K SPACE CELL
create_item{
	name = "540k-space-cell",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "180k-space-cell", amount = 3 },
		{ type = "item", name = "tungstensteel-plate", amount = 6 },
	}
}



---180K SPACE CELL
create_item{
	name = "180k-space-cell",
	category = "mv-assembling-machine-recipes",
	energy_required = MV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "reinforced-glass", amount = 3 },
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
	}
}



---SUPER COOLANT
create_recipe{
	recipe_name = "super-coolant",
	category = "hv-mixer-recipes",
	energy_required = HV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "ledox-dust", amount = 1 },
		{ type = "item", name = "callisto-ice-dust", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 200 },
	},
	results = {
		{ type = "fluid", name = "super-coolant", amount = 200 },
	},
}






--------------------------------------
---   ATOMIC SEPARATION CATALYST   ---
--------------------------------------

create_item{
	name = "raw-atomic-separation-catalyst",
	category = "hv-mixer-recipes",
	energy_required = HV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "blaze-powder", amount = 32 },
		{ type = "item", name = "draconium-dust", amount = 4 },
		{ type = "item", name = "manyullyn-dust", amount = 4 },
		{ type = "fluid", name = "molten-naquadah", amount = 28.8 },
	},
	results = {
		{ type = "item", name = "raw-atomic-separation-catalyst", amount = 63 },
	}
}
create_item{
	name = "orundum-plate",
	category = "iv-bending-machine-recipes",
	energy_required = IV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "tiberium-plate", amount = 1 },
		{ type = "item", name = "raw-silicon-plate", amount = 8 },
	}
}
create_item{
	name = "hot-atomic-separation-catalyst-ingot",
	category = "hv-electric-blast-furnace-recipes",
	energy_required = HV_SPEED * 180,
	ingredients = {
		{ type = "item", name = "orundum-plate", amount = 2 },
		{ type = "item", name = "raw-atomic-separation-catalyst", amount = 4 },
		{ type = "fluid", name = "molten-plutonium-239", amount = 14.4 },
	}
}
create_item{
	name = "atomic-separation-catalyst-ingot",
	category = "luv-vacuum-freezer-recipes",
	energy_required = LUV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "hot-atomic-separation-catalyst-ingot", amount = 1 },
	}
}





------------------------------
---   NAQUADAH FUEL LINE   ---
------------------------------

create_item{
	name = "radioactive-sludge",
	recipe_name = "acid-naquadah-emulsion",
	category = "ev-electric-blast-furnace-recipes",
	energy_required = EV_SPEED * 180,
	ingredients = {
		{ type = "item", name = "enriched-naquadah-dust", amount = 16 },
		{ type = "fluid", name = "hydrofluoric-acid", amount = 300 },
	},
	results = {
		{ type = "fluid", name = "acid-naquadah-emulsion", amount = 200 },
		{ type = "item", name = "radioactive-sludge", amount = 3 },
	},
	main_product = "acid-naquadah-emulsion"
}
create_recipe{
	recipe_name = "radioactive-sludge-centrifuging",
	category = "mv-centrifuge-recipes",
	energy_required = MV_SPEED * 45,
	ingredients = {
		{ type = "item", name = "radioactive-sludge", amount = 4 },
	},
	results = {
		{ type = "item", name = "calcium-dust", amount = 2 },
		{ type = "item", name = "calcium-dust", amount = 1, probability = 0.95 },
		{ type = "item", name = "enriched-naquadah-dust", amount = 1, probability = 0.8 },
		{ type = "item", name = "uranium-238-dust", amount = 1, probability = 0.25 },
		{ type = "item", name = "plutonium-239-dust", amount = 1, probability = 0.2 },
		{ type = "item", name = "tiberium-dust", amount = 1, probability = 0.2 },
		{ type = "fluid", name = "radon", amount = 2 },
	},
	main_product = "radon",
}
create_recipe{
	recipe_name = "naquadah-emulsion",
	category = "lv-chemical-reactor-recipes",
	energy_required = 12,
	ingredients = {
		{ type = "item", name = "quicklime", amount = 8 },
		{ type = "fluid", name = "acid-naquadah-emulsion", amount = 100 },
	},
	results = {
		{ type = "item", name = "antimony-trioxide", amount = 1, probability = 0.25 },
		{ type = "item", name = "fluorspar", amount = 4 },
		{ type = "fluid", name = "naquadah-emulsion", amount = 100 },
	},
	main_product = "naquadah-emulsion",
}
create_recipe{
	recipe_name = "naquadah-solution",
	category = "mv-centrifuge-recipes",
	energy_required = MV_SPEED * 40,
	ingredients = {
		{ type = "fluid", name = "naquadah-emulsion", amount = 100 },
	},
	results = {
		{ type = "item", name = "radioactive-sludge", amount = 5 },
		{ type = "item", name = "radioactive-sludge", amount = 1, probability = 0.46 },
		{ type = "fluid", name = "naquadah-solution", amount = 50 },
	},
	main_product = "naquadah-solution",
}
create_recipe{
	recipe_name = "naquadah-solution-cracking",
	category = "ev-tall-distillation-recipes",
	energy_required = EV_SPEED * 10,
	ingredients = {
		{ type = "fluid", name = "naquadah-solution", amount = 20 },
	},
	results = {
		{ type = "fluid", name = "light-naquadah-fuel", amount = 10 },
		{ type = "fluid", name = "water", amount = 10 },
		{ type = "fluid", name = "naquadah-gas", amount = 60 },
		{ type = "fluid", name = "naquadah-asphalt", amount = 2 },
		{ type = "fluid", name = "heavy-naquadah-fuel", amount = 5 },
	},
	main_product = "naquadah-solution",
}



---NAQUADAH HEAVY FUEL CRACKING
create_recipe{
	recipe_name = "naquadah-heavy-fuel-cracking",
	category = "iv-cracker-recipes",
	energy_required = IV_SPEED * 10,
	ingredients = {
		{ type = "fluid", name = "naquadah-heavy-fuel", amount = 50 },
		{ type = "fluid", name = "molten-atomic-separation-catalyst", amount = 0.3 },
	},
	results = {
		{ type = "fluid", name = "cracked-naquadah-heavy-fuel", amount = 50 },
	}
}
create_recipe{
	recipe_name = "naquadah-solution-cracking",
	category = "ev-tall-distillation-recipes",
	energy_required = EV_SPEED * 12.5,
	ingredients = {
		{ type = "fluid", name = "cracked-naquadah-heavy-fuel", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "radon", amount = 125 },
		{ type = "fluid", name = "molten-uranium-238", amount = 64.8 },
		{ type = "fluid", name = "light-naquadah-fuel", amount = 61.6 },
		{ type = "fluid", name = "naquadah-gas", amount = 54.0 },
		{ type = "fluid", name = "naquadah-asphalt", amount = 19.2 },
		{ type = "fluid", name = "molten-lutetium", amount = 55 },
		{ type = "item", name = "plutonium-239-dust", amount = 1, probability = 0.11 },
	},
	main_product = "molten-lutetium",
}



---NAQUADAH ASPHALT CRACKING
create_recipe{
	recipe_name = "naquadah-asphalt-cracking",
	category = "iv-cracker-recipes",
	energy_required = IV_SPEED * 8,
	ingredients = {
		{ type = "fluid", name = "naquadah-asphalt", amount = 25 },
		{ type = "fluid", name = "molten-atomic-separation-catalyst", amount = 0.3 },
	},
	results = {
		{ type = "fluid", name = "cracked-naquadah-asphalt", amount = 25 },
	}
}
create_recipe{
	recipe_name = "naquadah-solution-cracking",
	category = "ev-tall-distillation-recipes",
	energy_required = EV_SPEED * 20,
	ingredients = {
		{ type = "fluid", name = "cracked-naquadah-heavy-fuel", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "molten-uranium-238", amount = 138.2 },
		{ type = "fluid", name = "molten-plutonium-239", amount = 71.2 },
		{ type = "fluid", name = "light-naquadah-fuel", amount = 75 },
		{ type = "fluid", name = "naquadah-heavy-fuel", amount = 28 },
		{ type = "fluid", name = "molten-thulium", amount = 18.3 },
		{ type = "fluid", name = "molten-thorium", amount = 95 },
		{ type = "item", name = "naquadria-dust", amount = 1, probability = 0.11 },
	},
	main_product = "molten-thulium",
}