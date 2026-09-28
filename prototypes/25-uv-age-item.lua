--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--------------------------
---   UV COMPONENTS   ---
--------------------------

---NAQUADAH ALLOY CABLE
create_item{
	name = "naquadah-alloy-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-wire", amount = 4 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 2 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "naquadah-alloy-cable", amount = 4 },
	}
}



---UV MOTOR
create_item{
	name = "uv-motor",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "long-magnetic-samarium-rod", amount = 2 },
		{ type = "item", name = "long-neutronium-rod", amount = 4 },
		{ type = "item", name = "neutronium-ring", amount = 4 },
		{ type = "item", name = "neutronium-round", amount = 16 },
		{ type = "item", name = "fine-americium-wire", amount = 384 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV PISTON
create_item{
	name = "uv-piston",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uv-motor", amount = 1 },
		{ type = "item", name = "neutronium-plate", amount = 6 },
		{ type = "item", name = "neutronium-ring", amount = 4 },
		{ type = "item", name = "neutronium-round", amount = 32 },
		{ type = "item", name = "neutronium-rod", amount = 4 },
		{ type = "item", name = "large-neutronium-gear", amount = 1 },
		{ type = "item", name = "neutronium-gear", amount = 2 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 16 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV PUMP
create_item{
	name = "uv-pump",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uv-motor", amount = 1 },
		{ type = "item", name = "naquadah-plate", amount = 12 },
		{ type = "item", name = "neutronium-plate", amount = 2 },
		{ type = "item", name = "neutronium-screw", amount = 8 },
		{ type = "item", name = "silicone-rubber-ring", amount = 16 },
		{ type = "item", name = "neutronium-rotor", amount = 2 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV CONVEYOR MODULE
create_item{
	name = "uv-conveyor-module",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uv-motor", amount = 2 },
		{ type = "item", name = "neutronium-plate", amount = 2 },
		{ type = "item", name = "neutronium-ring", amount = 4 },
		{ type = "item", name = "neutronium-round", amount = 32 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 40 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV ROBOT ARM
create_item{
	name = "uv-robot-arm",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uv-motor", amount = 2 },
		{ type = "item", name = "uv-piston", amount = 1 },
		{ type = "item", name = "long-neutronium-rod", amount = 4 },
		{ type = "item", name = "large-neutronium-gear", amount = 1 },
		{ type = "item", name = "neutronium-gear", amount = 3 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "luv-circuit", amount = 8 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 24 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV SENSOR
create_item{
	name = "uv-sensor",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "neutronium-frame", amount = 1 },
		{ type = "item", name = "uv-motor", amount = 1 },
		{ type = "item", name = "neutronium-plate", amount = 8 },
		{ type = "item", name = "gravi-star", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "naquadria-foil", amount = 192 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 28 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV EMITTER
create_item{
	name = "uv-emitter",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "neutronium-frame", amount = 1 },
		{ type = "item", name = "uv-motor", amount = 1 },
		{ type = "item", name = "neutronium-rod", amount = 16 },
		{ type = "item", name = "gravi-star", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "naquadria-foil", amount = 192 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 28 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
		{ type = "fluid", name = "lubricant", amount = 200 },
	}
}



---UV FIELD GENERATOR
create_item{
	name = "uv-field-generator",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 50,
	ingredients = {
		{ type = "item", name = "neutronium-frame", amount = 1 },
		{ type = "item", name = "uv-emitter", amount = 4 },
		{ type = "item", name = "neutronium-plate", amount = 6 },
		{ type = "item", name = "gravi-star", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "fine-americium-wire", amount = 512 },
		{ type = "item", name = "naquadah-alloy-cable", amount = 32 },
		{ type = "fluid", name = "molten-naquadria", amount = 129.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 129.6 },
	}
}


---UV MACHINE CASING
create_item{
	name = "uv-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "osmium-plate", amount = 8 },
    }
}



---UV MACHINE HULL
create_item{
	name = "uv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uv-machine-casing", amount = 1 },
		{ type = "item", name = "osmium-plate", amount = 1 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
		{ type = "item", name = "naquadah-alloy-wire", amount = 8 },
    }
}



---ULTIMATE VOLTAGE COIL
create_item{
	name = "ultimate-voltage-coil",
	category = "uv-assembling-machine-recipes",
	energy_required = 10 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-fluxed-electrum-wire", amount = 16 },
    }
}



---UV ENERGY HATCH
create_item{
	name = "uv-energy-hatch",
	category = "uv-assembly-line-recipes",
	energy_required = 50 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-superconductor-wire", amount = 4 },
		{ type = "item", name = "piko-power-ic", amount = 2 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "360k-super-coolant-cell", amount = 4 },
		{ type = "item", name = "uv-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 800 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
    }
}



---UV DYNAMO HATCH
create_item{
	name = "uv-dynamo-hatch",
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



---FLUXED ELECTRUM COIL BLOCK (UHV)
create_item{
	name = "fluxed-electrum-coil-block",
	category = "uv-assembling-machine-recipes",
	energy_required = 55 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "fluxed-electrum-wire", amount = 16 },
		{ type = "item", name = "americium-foil", amount = 8 },
		{ type = "fluid", name = "molten-trinium", amount = 14.4 }
	}
} 



--------------------------
---   BIO PROCESSORS   ---
--------------------------   
   
---BIO PROCESSOR
create_item{
	name = "bio-processor",
	category = "uv-circuit-assembly-line-recipes",
	energy_required = 180 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "bio-processing-unit-wrap", amount = 1 },
		{ type = "item", name = "raw-advanced-crystal-chip-wrap", amount = 1 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "advanced-smd-capacitor-wrap", amount = 12 },
		{ type = "item", name = "advanced-smd-transistor-wrap", amount = 12 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "bio-processor", amount = 16 },
	},
}
create_recipe{
	recipe_name = "bio-processor-optical",
	category = "uhv-circuit-assembly-line-recipes",
	energy_required = 22.2 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "bio-processing-unit-wrap", amount = 1 },
		{ type = "item", name = "raw-advanced-crystal-chip-wrap", amount = 1 },
		{ type = "item", name = "nano-cpu-chip-wrap", amount = 2 },
		{ type = "item", name = "optical-smd-capacitor-wrap", amount = 3 },
		{ type = "item", name = "optical-smd-transistor-wrap", amount = 3 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 7.2 }
	},
	results = {
		{ type = "item", name = "bio-processor", amount = 16 },
	},
}
create_recipe{
	recipe_name = "bio-processor-living",
	category = "uev-circuit-assembly-line-recipes",
	energy_required = 45 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "ultra-bio-mutated-circuit-board-wrap", amount = 1 },
		{ type = "item", name = "living-bio-chip-wrap", amount = 1 },
		{ type = "item", name = "niobium-titanium-wire-4x", amount = 16 },
		{ type = "item", name = "chromatic-glass-bolt", amount = 64 },
		{ type = "fluid", name = "mutated-living-solder", amount = 14.4 }
	},
	results = {
		{ type = "item", name = "bio-processor", amount = 16 },
	},
}







-----------------------------
---   COSMIC NEUTRONIUM   ---
-----------------------------

create_endgame_parts{
	name = "cosmic-neutronium",
	tier = "zpm",
	speed = ZPM_SPEED,
}



create_item{
	name = "pile-of-cosmic-neutrons",
	category = "ev-centrifuge-recipes",
	energy_required = EV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "black-plutonium-dust", amount = 1 },
    },
	results = {
		{ type = "item", name = "pile-of-cosmic-neutrons", amount = 1, probability = 0.8 },
	}
}
create_item{
	name = "cosmic-neutronium-nugget",
	category = "lv-implosion-compressor-recipes",
	ingredients = {
		{ type = "item", name = "pile-of-cosmic-neutrons", amount = 9 },
		{ type = "item", name = "explosives", amount = 1 },
    }
}
create_recipe{
	recipe_name = "cosmic-neutronium-nugget-eic",
	category = "uev-electric-implosion-compressor-recipes",
	energy_required = UEV_SPEED * 0.05,
	ingredients = {
		{ type = "item", name = "pile-of-cosmic-neutrons", amount = 9 },
    },
	results = {
		{ type = "item", name = "cosmic-neutronium-nugget", amount = 1 },
	},
}
create_item{
	name = "cosmic-neutronium-ingot",
	category = "lv-implosion-compressor-recipes",
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-nugget", amount = 9 },
		{ type = "item", name = "explosives", amount = 1 },
    }
}
create_recipe{
	recipe_name = "cosmic-neutronium-ingot-eic",
	category = "uev-electric-implosion-compressor-recipes",
	energy_required = UEV_SPEED * 0.05,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-nugget", amount = 9 },
    },
	results = {
		{ type = "item", name = "cosmic-neutronium-ingot", amount = 1 },
	},
}
create_recipe{
	recipe_name = "solidifying-cosmic-neutronium-ingot",
	category = "zpm-fluid-solidifier-recipes",
	energy_required = ZPM_SPEED * 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 14.4 },
    },
	results = {
		{ type = "item", name = "cosmic-neutronium-ingot", amount = 1 },
	},
}
create_recipe{
	recipe_name = "molten-cosmic-neutronium-crude",
	category = "adc-dtpf-recipes",
	energy_required = UEV_SPEED * 85.7,
	ingredients = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 1471.9 },
		{ type = "fluid", name = "molten-copper", amount = 7372.8 },
    },
	results = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 7372.8 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 183.9 },
	},
	main_product = "molten-cosmic-neutronium"
}
create_recipe{
	recipe_name = "molten-cosmic-neutronium-prosaic",
	category = "ic-dtpf-recipes",
	energy_required = UIV_SPEED * 42.85,
	ingredients = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 575.9 },
		{ type = "fluid", name = "molten-copper", amount = 14745.6 },
    },
	results = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 14745.6 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 143.9 },
	},
	main_product = "molten-cosmic-neutronium"
}
create_recipe{
	recipe_name = "molten-cosmic-neutronium-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = UIV_SPEED * 21.4,
	ingredients = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 248.5 },
		{ type = "fluid", name = "molten-copper", amount = 29491.2 },
    },
	results = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 29491.2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 124.2 },
	},
	main_product = "molten-cosmic-neutronium"
}
create_recipe{
	recipe_name = "molten-cosmic-neutronium-exotic",
	category = "ec-dtpf-recipes",
	energy_required = UMV_SPEED * 10.7,
	ingredients = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 104.8 },
		{ type = "fluid", name = "molten-copper", amount = 58982.4 },
    },
	results = {
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 58982.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 104.8 },
	},
	main_product = "molten-cosmic-neutronium"
}














----------------------------------
---   COMPONENT ASSEMBLY LINE   ---
-----------------------------------

create_item{
	name = "component-assembly-line-controller",
	category = "uhv-assembling-line-recipes",
	energy_required = 30 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "assembly-line-controller", amount = 16 },
		{ type = "item", name = "assembler-machine-casing", amount = 16 },
		{ type = "item", name = "assembly-line-casing", amount = 32 },
		{ type = "item", name = "uv-robot-arm", amount = 16 },
		{ type = "item", name = "uv-conveyor-module", amount = 32 },
		{ type = "item", name = "zpm-motor", amount = 32 },
		{ type = "item", name = "pbi-sheet", amount = 48 },
		{ type = "item", name = "superdense-iridium-plate", amount = 4 },
		{ type = "item", name = "fluid-shaper-controller", amount = 16 },
		{ type = "item", name = "uv-circuit", amount = 16 },
		{ type = "item", name = "zpm-circuit", amount = 20 },
		{ type = "item", name = "luv-circuit", amount = 24 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 172.8 },
		{ type = "fluid", name = "molten-naquadria", amount = 230.4 },
		{ type = "fluid", name = "lubricant", amount = 500 },
	}
}  
create_item{
	name = "advanced-iridium-plated-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "iridium-plate", amount = 6 },
		{ type = "item", name = "iridium-frame", amount = 1 },
	},
	results = (
		{ type = "item", name = "advanced-iridium-plated-machine-casing", amount = 2 },
	}
} 
create_item{
	name = "uv-component-assembly-line",
	stack_size = 10,
--	place_result = "uv-component-assembly-line",
	ingredients = { 
		{ type = "item", name = "component-assembly-line-controller", amount = 1 },
		{ type = "item", name = "advanced-filter-casing", amount = 124 },
		{ type = "item", name = "advanced-iridium-plated-machine-casing", amount = 644 },
		{ type = "item", name = "osmium-reinforced-borosilicate-glass", amount = 288 },
		{ type = "item", name = "assembler-machine-casing", amount = 30 },
		{ type = "item", name = "uv-assembly-line-casing", amount = 43 },
		{ type = "item", name = "pbi-pipe-casing", amount = 126 },
		{ type = "item", name = "assembly-line-casing", amount = 55 },
		{ type = "item", name = "tungstensteel-frame", amount = 4 },
		{ type = "item", name = "uv-machine-hull", amount = 4 }, 
		{ type = "item", name = "uv-energy-hatch", amount = 1 },
	}
}










---------------------------
---   RESEARCH STATION  ---
---------------------------

create_item{
    name = "research-station-controller",
    category = "zpm-assembly-line-recipes",	
    energy_required = ZPM_SPEED * 600,
	ingredients = {
		{ type = "item", name = "network-switch-with-qos", amount = 1 },
		{ type = "item", name = "zpm-sensor", amount = 8 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "zpm-field-generator", amount = 1 },
		{ type = "item", name = "zpm-motor", amount = 2 },
		{ type = "item", name = "naquadah-cable", amount = 8 },
		{ type = "item", name = "fine-naquadah-wire", amount = 32 },
		{ type = "item", name = "optical-fiber-cable", amount = 16 },
		{ type = "fluid", name = "uu-matter", amount = 100 },
		{ type = "fluid", name = "molten-iridium", amount = 129.6 },
		{ type = "fluid", name = "molten-osmium", amount = 129.6 },
		{ type = "fluid", name = "lapis-coolant", amount = 200 },
    } 
}
create_item{
    name = "uv-research-station",
	ingredients = {
		{ type = "item", name = "research-station-controller", amount = 1 },
		{ type = "item", name = "computer-casing", amount = 58 },
		{ type = "item", name = "advanced-computer-casing", amount = 23 },
		{ type = "item", name = "computer-heat-vent", amount = 14 },
		{ type = "item", name = "optical-reception-connector", amount = 1 },
		{ type = "item", name = "object-holder", amount = 1 },
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-energy-hatch", amount = 1 },
    } 
}
create_item{
    name = "computer-casing",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 10,
	ingredients = {
		{ type = "item", name = "high-power-casing", amount = 1 },
		{ type = "item", name = "stainless-steel", amount = 8 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "item", name = "niobium-titanium-wire", amount = 2 },
		{ type = "fluid", name = "molten-aluminium", amount = 129.6 },
    } 
} 
create_item{
    name = "advanced-computer-casing",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 10,
	ingredients = {
		{ type = "item", name = "computer-casing", amount = 1 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "item", name = "fine-cobalt-wire", amount = 64 },
		{ type = "item", name = "fine-electrum-wire", amount = 64 },
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 8 },
		{ type = "fluid", name = "molten-iridium", amount = 129.6 },
    } 
} 
create_item{
    name = "computer-heat-vent",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 10,
	ingredients = {
		{ type = "item", name = "stainless-steel-frame", amount = 1 },
		{ type = "item", name = "stainless-steel-rotor", amount = 2 },
		{ type = "item", name = "stainless-steel-plate", amount = 12 },
		{ type = "item", name = "copper-plate", amount = 16 },
		{ type = "item", name = "iv-motor", amount = 2 },
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 1 },
		{ type = "fluid", name = "molten-soldering-alloy", amount = 129.6 },
    } 
}
create_item{
    name = "optical-reception-connector",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 10,
	ingredients = {
		{ type = "item", name = "computer-casing", amount = 1 },
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 1 },
		{ type = "item", name = "optical-fiber-cable", amount = 2 },
		{ type = "fluid", name = "molten-iridium", amount = 129.6 },
    } 
} 
create_item{
    name = "object-holder",
    category = "zpm-assembling-machine-recipes",	
    energy_required = ZPM_SPEED * 10,
	ingredients = {
		{ type = "item", name = "computer-casing", amount = 1 },
		{ type = "item", name = "luv-machine-hull", amount = 1 },
		{ type = "item", name = "luv-circuit", amount = 1 },
		{ type = "item", name = "optical-fiber-cable", amount = 2 },
		{ type = "fluid", name = "molten-iridium", amount = 129.6 },
    } 
} 








-------------------------------------------------
---   DRACONIUM TIER DRACONIC FUSION CRAFTER  ---
-------------------------------------------------

create_item{
    name = "draconium-dust",
    category = "uv-macerator-recipes",	
    energy_required = UV_SPEED * 10,
	ingredients = {
      {type = "item", name = "dragon-scale", amount = 1 },
    } 
}
create_item{
    name = "draconium-tier-draconic-evolution-fusion-crafter",
    subgroup = "draconium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "ichorium-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "fusion-machine-casing-mk2", amount = 32 },
      {type = "item", name = "draconium-fusion-casing", amount = 32 },
    },
	results = {
      {type = "item", name = "draconium-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "fusion-machine-casing", amount = 32 },
      {type = "item", name = "ichorium-fusion-casing", amount = 32 },
    },
	main_product = "draconium-tier-draconic-evolution-fusion-crafter"
}
create_item{
    name = "wyvern-core",
    category = "draconium-tier-fusion-recipes",	
    energy_required = UHV_SPEED * 40,
	ingredients = {
      {type = "item", name = "draconium-plate", amount = 8 },
      {type = "item", name = "neutronium-plate", amount = 4 },
      {type = "item", name = "draconic-core", amount = 4 },
      {type = "item", name = "quantum-star", amount = 1 },
      {type = "fluid", name = "molten-neutronium", amount = 144 },
    }
}
create_item{
    name = "wyvern-energy-core",
    category = "draconium-tier-fusion-recipes",	
    energy_required = UV_SPEED * 50,
	ingredients = {
      {type = "item", name = "draconium-plate", amount = 8 },
      {type = "item", name = "neutronium-plate", amount = 4 },
      {type = "item", name = "sunnarium-alloy", amount = 4 },
      {type = "item", name = "draconic-core", amount = 1 },
    }
}
create_item{
    name = "wyvern-fusion-casing",
    category = "uhv-assembling-machine-recipes",	
    energy_required = UHV_SPEED * 600,
    subgroup = "draconium-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "draconium-fusion-casing", amount = 1 },
      {type = "item", name = "dense-cosmic-neutronium-plate", amount = 6 },
      {type = "item", name = "wyvern-core", amount = 2 },
      {type = "fluid", name = "molten-void-metal", amount = 460.8 },
    }
}



---WYVERN TIER
create_item{
    name = "wyvern-tier-draconic-evolution-fusion-crafter",
    subgroup = "subgroup-wyvern-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "draconium-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "wyvern-fusion-casing", amount = 32 },
    },
	results = {
      {type = "item", name = "wyvern-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "draconium-fusion-casing", amount = 32 },
    },
	main_product = "wyvern-tier-draconic-evolution-fusion-crafter"
}
create_item{
    name = "draconium-energy-core",
    category = "wyvern-tier-fusion-recipes",	
    energy_required = UHV_SPEED * 100,
	ingredients = {
      {type = "item", name = "awakened-draconium-plate", amount = 8 },
      {type = "item", name = "wyvern-energy-core", amount = 4 },
      {type = "item", name = "enriched-sunnarium-alloy", amount = 4 },
      {type = "item", name = "wyvern-core", amount = 1 },
    }
}
create_item{
    name = "awakened-core",
    category = "wyvern-tier-fusion-recipes",	
    energy_required = UEV_SPEED * 80,
	ingredients = {
      {type = "item", name = "awakened-draconium-plate", amount = 12 },
      {type = "item", name = "draconium-plate", amount = 4 },
      {type = "item", name = "wyvern-core", amount = 4 },
      {type = "item", name = "ender-quantum-component", amount = 1 },
      {type = "fluid", name = "molten-infinity", amount = 144 },
    }
}
create_item{
    name = "awakened-draconium-fusion-casing",
    category = "uev-assembling-machine-recipes",	
    energy_required = UEV_SPEED * 600,
    subgroup = "subgroup-wyvern-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "wyvern-fusion-casing", amount = 1 },
      {type = "item", name = "dense-awakened-draconium-plate", amount = 6 },
      {type = "item", name = "awakened-core", amount = 3 },
      {type = "fluid", name = "molten-void-metal", amount = 921.6 },
    }
}



---AWAKENED TIER
create_item{
    name = "awakened-tier-draconic-evolution-fusion-crafter",
    subgroup = "subgroup-awakened-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "wyvern-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "awakened-draconium-fusion-casing", amount = 32 },
    },
	results = {
      {type = "item", name = "awakened-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "wyvern-fusion-casing", amount = 32 },
    },
	main_product = "awakened-tier-draconic-evolution-fusion-crafter"
}
create_item{
    name = "chaotic-core",
    category = "awakened-tier-fusion-recipes",	
    energy_required = UIV_SPEED * 160,	
	ingredients = {
      {type = "item", name = "awakened-draconium-plate", amount = 16 },
      {type = "item", name = "black-plutonium-plate", amount = 4 },
      {type = "item", name = "awakened-core", amount = 4 },
      {type = "item", name = "large-chaos-fragment", amount = 2 },
      {type = "fluid", name = "molten-spacetime", amount = 144 },
    }
}
create_item{
    name = "chaotic-fusion-casing",
    category = "uiv-assembling-machine-recipes",	
    energy_required = UIV_SPEED * 600,
    subgroup = "subgroup-awakened-tier-fusion-recipes"
	ingredients = {
      {type = "item", name = "awakened-draconium-fusion-casing", amount = 1 },
      {type = "item", name = "dense-infinity-plate", amount = 6 },
      {type = "item", name = "chaotic-core", amount = 4 },
      {type = "fluid", name = "molten-void-metal", amount = 1843.2 },
    }
}



---CHATOIC TIER
create_item{
    name = "chaotic-tier-draconic-evolution-fusion-crafter",
    subgroup = "subgroup-draconic-fusion"
	ingredients = {
      {type = "item", name = "awakened-draconium-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "chaotic-fusion-casing", amount = 32 },
    },
	results = {
      {type = "item", name = "chaotic-tier-draconic-evolution-fusion-crafter", amount = 1 },
      {type = "item", name = "awakened-draconium-fusion-casing", amount = 32 },
    },
	main_product = "chaotic-tier-draconic-evolution-fusion-crafter"
}









----------------------
---   NANO FORGE   ---
----------------------

create_item{
	name = "nano-forge-controller",
	category = "zpm-assembly-line-recipes",
	energy_required = ZPM_SPEED * 300,
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 16 },
		{ type = "item", name = "carbon-nanites", amount = 16 },
		{ type = "item", name = "zpm-field-generator", amount = 16 },
		{ type = "item", name = "zpm-conveyor-module", amount = 16 },
		{ type = "item", name = "zpm-motor", amount = 32 },
		{ type = "item", name = "luv-circuit", amount = 16 },
		{ type = "item", name = "naquadah-wire-8x", amount = 32 },
		{ type = "item", name = "superdense-naquadah-alloy-plate", amount = 4 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 460.8 },
		{ type = "fluid", name = "molten-hsss", amount = 460.8 },
		{ type = "fluid", name = "molten-osmiridium", amount = 230.4 },
	}
}



create_item{
	name = "nano-forge",
	ingredients = {
		{ type = "item", name = "radiant-naquadah-alloy-casing", amount = 522 },
		{ type = "item", name = "stellar-alloy-frame", amount = 170 },
		{ type = "item", name = "uv-machine-hull", amount = 4 },
		{ type = "item", name = "uv-energy-hatch", amount = 1 },
		{ type = "item", name = "superdense-naquadah-alloy-plate", amount = 4 },
		{ type = "item", name = "carbon-nanites", amount = 1 },
	}
}



create_item{
	name = "radiant-naquadah-alloy-casing",
	category = "uv-assembling-machine-recipes",
	energy_required = UV_SPEED * 0.5,
	ingredients = {
		{ type = "item", name = "naquadah-alloy-plate", amount = 8 },
		{ type = "item", name = "naquadah-alloy-frame", amount = 1 },
	}
}



create_item{
	name = "carbon-nanites",
	category = "t1-nanoforge-recipes",
	energy_required = UIV_SPEED * 500,
	ingredients = {
		{ type = "item", name = "rebolted-carbon-casing", amount = 8 },
		{ type = "item", name = "system-on-chip", amount = 64 },
		{ type = "fluid", name = "uu-matter", amount = 20000 },
	},
	results = {
      {type = "item", name = "carbon-nanites", amount = 64 },
    },
}



create_item{
	name = "silver-nanites",
	category = "t2-nanoforge-recipes",
	energy_required = UIV_SPEED * 750,
	ingredients = {
		{ type = "item", name = "block-of-silver", amount = 8 },
		{ type = "item", name = "system-on-chip", amount = 16 },
		{ type = "fluid", name = "uu-matter", amount = 20000 },
	}
}



create_item{
	name = "glowstone-nanites",
	category = "t2-nanoforge-recipes",
	energy_required = UMV_SPEED * 200,
	ingredients = {
		{ type = "item", name = "double-compressed-glowstone", amount = 8 },
		{ type = "item", name = "advanced-system-on-chip", amount = 64 },
		{ type = "fluid", name = "uu-matter", amount = 5000 },
	},
	results = {
      {type = "item", name = "glowstone-nanites", amount = 64 },
    },
}



create_item{
	name = "neutronium-nanites",
	category = "t1-nanoforge-recipes",
	energy_required = UMV_SPEED * 100,
	ingredients = {
		{ type = "item", name = "block-of-neutronium", amount = 8 },
		{ type = "item", name = "advanced-system-on-chip", amount = 96 },
		{ type = "fluid", name = "uu-matter", amount = 20000 },
	}
}



create_item{
	name = "gold-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UMV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "block-of-gold", amount = 8 },
		{ type = "item", name = "system-on-chip", amount = 16 },
		{ type = "fluid", name = "uu-matter", amount = 30000 },
	}
}



create_item{
	name = "transcendent-metal-nanites",
	category = "t2-nanoforge-recipes",
	energy_required = UXV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "block-of-transcendent-metal", amount = 8 },
		{ type = "item", name = "advanced-system-on-chip", amount = 192 },
		{ type = "fluid", name = "uu-matter", amount = 200000 },
	}
}



create_item{
	name = "six-phased-copper-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UXV_SPEED * 100,
	ingredients = {
		{ type = "item", name = "block-of-six-phased-copper", amount = 8 },
		{ type = "item", name = "advanced-system-on-chip", amount = 192 },
		{ type = "fluid", name = "uu-matter", amount = 50000 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 5000 },
	},
	results = {
      {type = "item", name = "six-phased-copper-nanites", amount = 8 },
    },
}



create_item{
	name = "white-dwarf-matter-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UMV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "block-of-white-dwarf-matter", amount = 8 },
		{ type = "item", name = "pico-wafer", amount = 32 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 32 },
		{ type = "fluid", name = "uu-matter", amount = 50000 },
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 50000 },
		{ type = "fluid", name = "spatially-enlarged-fluid", amount = 72000 },
	},
	results = {
      {type = "item", name = "white-dwarf-matter-nanites", amount = 4 },
    },
}



create_item{
	name = "black-dwarf-matter-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UXV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "block-of-black-dwarf-matter", amount = 8 },
		{ type = "item", name = "pico-wafer", amount = 32 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 32 },
		{ type = "fluid", name = "uu-matter", amount = 50000 },
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 50000 },
		{ type = "fluid", name = "tachyon-rich-temporal-fluid", amount = 72000 },
	},
	results = {
      {type = "item", name = "black-dwarf-matter-nanites", amount = 4 },
    },
}



create_item{
	name = "universium-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UXV_SPEED * 750,
	ingredients = {
		{ type = "item", name = "block-of-universium", amount = 8 },
		{ type = "item", name = "optically-perfected-cpu", amount = 16 },
		{ type = "item", name = "optically-perfected-memory", amount = 16 },
		{ type = "fluid", name = "molten-spacetime", amount = 14.4 },
		{ type = "fluid", name = "molten-infinity", amount = 57.6 },
		{ type = "fluid", name = "liquid-primordial-matter", amount = 6400 },
	},
	results = {
      {type = "item", name = "universium-nanites", amount = 2 },
    },
}



create_item{
	name = "eternity-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UXV_SPEED * 750,
	ingredients = {
		{ type = "item", name = "block-of-eternity", amount = 8 },
		{ type = "item", name = "transcendent-metal-nanites", amount = 1 },
		{ type = "item", name = "pico-wafer", amount = 32 },
		{ type = "item", name = "timepiece", amount = 4 },
		{ type = "fluid", name = "spacially-enlarged-fluid", amount = 115.2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 5000 },
		{ type = "fluid", name = "liquid-primordial-matter", amount = 6400 },
	},
	results = {
      {type = "item", name = "eternity-nanites", amount = 4 },
    },
}



create_item{
	name = "magmatter-nanites",
	category = "t3-nanoforge-recipes",
	energy_required = UXV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 8 },
		{ type = "item", name = "universium-nanites", amount = 1 },
		{ type = "item", name = "pico-wafer", amount = 64 },
		{ type = "item", name = "quantum-circuit", amount = 1 },
		{ type = "fluid", name = "degenerate-quork-gluon-plasma", amount = 10000 },
		{ type = "fluid", name = "lossless-phonon-transfer-medium", amount = 6400 },
		{ type = "fluid", name = "liquid-primordial-matter", amount = 12800 },
	},
	results = {
      {type = "item", name = "magmatter-nanites", amount = 1 },
    },
}