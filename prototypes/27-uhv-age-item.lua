--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--------------------------
---   UHV COMPONENTS   ---
--------------------------

---BEDROCKIUM CABLE
create_item{
	name = "bedrockium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "bedrockium-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "bedrockium-cable", amount = 4 },
	}
}



---UHV MOTOR
create_item{
	name = "uhv-motor",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "long-magnetic-samarium-rod", amount = 4 },
		{ type = "item", name = "long-cosmic-neutronium-rod", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-ring", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-round", amount = 32 },
		{ type = "item", name = "fine-neutronium-wire", amount = 512 },
		{ type = "item", name = "bedrockium-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV PISTON
create_item{
	name = "uhv-piston",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 6 },
		{ type = "item", name = "cosmic-neutronium-ring", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-round", amount = 64 },
		{ type = "item", name = "cosmic-neutronium-rod", amount = 8 },
		{ type = "item", name = "large-cosmic-neutronium-gear", amount = 2 },
		{ type = "item", name = "cosmic-neutronium-gear", amount = 4 },
		{ type = "item", name = "bedrockium-cable", amount = 16 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV PUMP
create_item{
	name = "uhv-pump",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "item", name = "neutronium-plate", amount = 12 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 4 },
		{ type = "item", name = "cosmic-neutronium-screw", amount = 16 },
		{ type = "item", name = "silicone-rubber-ring", amount = 64 },
		{ type = "item", name = "cosmic-neutronium-rotor", amount = 4 },
		{ type = "item", name = "bedrockium-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV CONVEYOR MODULE
create_item{
	name = "uhv-conveyor-module",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uhv-motor", amount = 2 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 2 },
		{ type = "item", name = "cosmic-neutronium-ring", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-round", amount = 64 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
		{ type = "item", name = "bedrockium-cable", amount = 8 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV ROBOT ARM
create_item{
	name = "uhv-robot-arm",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uhv-motor", amount = 2 },
		{ type = "item", name = "uhv-piston", amount = 1 },
		{ type = "item", name = "long-cosmic-neutronium-rod", amount = 8 },
		{ type = "item", name = "large-cosmic-neutronium-gear", amount = 2 },
		{ type = "item", name = "cosmic-neutronium-gear", amount = 6 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "uv-circuit", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 8 },
		{ type = "item", name = "bedrockium-cable", amount = 24 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV SENSOR
create_item{
	name = "uhv-sensor",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-frame", amount = 1 },
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 8 },
		{ type = "item", name = "gravi-star", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "fluxed-electrum-foil", amount = 256 },
		{ type = "item", name = "bedrockium-cable", amount = 28 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV EMITTER
create_item{
	name = "uhv-emitter",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-frame", amount = 1 },
		{ type = "item", name = "uhv-motor", amount = 1 },
		{ type = "item", name = "cosmic-neutronium-rod", amount = 16 },
		{ type = "item", name = "gravi-star", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "fluxed-electrum-foil", amount = 256 },
		{ type = "item", name = "bedrockium-cable", amount = 28 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UHV FIELD GENERATOR
create_item{
	name = "uhv-field-generator",
	category = "uv-assembly-line-recipes",
	energy_required = UV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-frame", amount = 1 },
		{ type = "item", name = "uhv-emitter", amount = 4 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 6 },
		{ type = "item", name = "gravi-star", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "fine-neutronium-wire", amount = 512 },
		{ type = "item", name = "bedrockium-cable", amount = 32 },
		{ type = "fluid", name = "molten-naquadria", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
	}
}


---UHV MACHINE CASING
create_item{
	name = "uhv-machine-casing",
	ingredients = {
		{ type = "item", name = "neutronium-plate", amount = 8 },
    }
}



---UHV MACHINE HULL
create_item{
	name = "uhv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uhv-machine-casing", amount = 1 },
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 8 },
		{ type = "fluid", name = "polybenzimidazole", amount = 28.8 },
    }
}



---HIGHLY ULTIMATE VOLTAGE COIL
create_item{
	name = "highly-ultimate-voltage-coil",
	category = "uhv-assembling-machine-recipes",
	energy_required = 10 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "magnetic-samarium-rod", amount = 1 },
		{ type = "item", name = "fine-tritanium-wire", amount = 16 },
    }
}



---UHV ENERGY HATCH
create_item{
	name = "uhv-energy-hatch",
	category = "uhv-assembly-line-recipes",
	energy_required = 50 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "uhv-superconductor-wire", amount = 8 },
		{ type = "item", name = "quantum-power-ic", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "360k-super-coolant-cell", amount = 8 },
		{ type = "item", name = "uhv-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 1600 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
    }
}



---UHV DYNAMO HATCH
create_item{
	name = "uhv-dynamo-hatch",
	category = "uhv-assembly-line-recipes",
	energy_required = 50 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "uhv-superconductor-spring", amount = 8 },
		{ type = "item", name = "quantum-power-ic", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 2 },
		{ type = "item", name = "360k-super-coolant-cell", amount = 8 },
		{ type = "item", name = "uhv-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 1600 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 576 },
    }
}



---AWAKENED DRACONIUM COIL BLOCK (UEV)
create_item{
	name = "awakened-draconium-coil-block",
	category = "uhv-assembling-machine-recipes",
	energy_required = 60 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "awakened-draconium-wire", amount = 16 },
		{ type = "item", name = "ichorium-foil", amount = 8 },
		{ type = "fluid", name = "molten-fluxed-electrum", amount = 14.4 }
	}
}










-------------------------
---   ATTUNED TENGAM  ---
-------------------------

create_recipe{
    name = "microminer-tengam",
    category = "lv-assembling-machine-recipes",	
    energy_required = UHV_SPEED * 2,
    subgroup = "subgroup-microminer-t9"
	ingredients = {
      {type = "item", name = "tier-nine-microminer-output", amount = 1 }
    },
    results = {
      {type = "item", name = "raw-tengam", amount = 32 },
      {type = "item", name = "raw-electrotine", amount = 16 },
      {type = "item", name = "raw-samarium", amount = 16 },
    },
	main_product = "raw-tengam"
}









----------------------------------
---   INTEGRATED ORE FACTORY   ---
----------------------------------

create_item{
	name = "integrated-ore-factory-controller",
	category = "uv-assembling-line-recipes",
	energy_required = 60 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "uhv-motor", amount = 32	 },
		{ type = "item", name = "uhv-piston", amount = 8 },
		{ type = "item", name = "uhv-pump", amount = 16 },
		{ type = "item", name = "uhv-conveyor-module", amount = 8 },
		{ type = "item", name = "uhv-robot-arm", amount = 8 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "duranium-wire", amount = 128 },
		{ type = "item", name = "pbi-sheet", amount = 192 },
		{ type = "item", name = "tungsten-grinding-head", amount = 64 },
		{ type = "item", name = "stainless-steel-plate", amount = 64 },
		{ type = "item", name = "chromium-rotor", amount = 16 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "molten-naquadria", amount = 144, }
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
	name = "uhv-integrated-ore-factory",
	stack_size = 10,
--	place_result = "uhv-integrated-ore-factory",
	ingredients = {
		{ type = "item", name = "integrated-ore-factory-controller", amount = 1 },
		{ type = "item", name = "clean-stainless-steel-casing", amount = 101 },
		{ type = "item", name = "advanced-iridium-plated-machine-casing", amount = 125 },
		{ type = "item", name = "tungstensteel-pipe-casing", amount = 30 },
		{ type = "item", name = "reinforced-glass", amount = 48 },
		{ type = "item", name = "tungstensteel-frame", amount = 16 },
		{ type = "item", name = "steel-gear-box-casing", amount = 16 },
		{ type = "item", name = "uv-machine-hull", amount = 5 },
		{ type = "item", name = "uhv-energy-hatch", amount = 1 },
	}
} 









---------------------------------
---   NEUTRONIUM COMPRESSOR   ---
---------------------------------

create_item{
	name = "neutronium-compressor-controller",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-block", amount = 12 },
		{ type = "item", name = "crystal-matrix-ingot", amount = 20 },
		{ type = "item", name = "cosmic-neutronium-heavy-plating", amount = 4 },
		{ type = "item", name = "superdense-bedrockium-plate", amount = 2 },
		{ type = "item", name = "superdense-black-plutonium-plate", amount = 2 },
		{ type = "item", name = "uv-motor", amount = 8 },
		{ type = "item", name = "uv-piston", amount = 10 },
		{ type = "item", name = "uv-conveyor-module", amount = 8 },
		{ type = "item", name = "neutronium-plate", amount = 4 },
		{ type = "item", name = "uvh-circuit", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "fluxed-electrum-cable", amount = 4 },
    }
}
create_item{
	name = "uhv-neutronium-compressor",
	ingredients = {
		{ type = "item", name = "neutronium-compressor-controller", amount = 1 },
		{ type = "item", name = "neutronium-casing", amount = 242 },
		{ type = "item", name = "naquadah-alloy-frame", amount = 108 },
		{ type = "item", name = "neutronium-stabilization-casing", amount = 67 },
		{ type = "item", name = "active-neutronium-casing", amount = 63 },
		{ type = "item", name = "reinforced-glass", amount = 25 },
		{ type = "item", name = "uv-machine-hull", amount = 3 },
		{ type = "item", name = "uhv-energy-hatch", amount = 1 },
    }
}
create_item{
	name = "neutronium-casing",
	category = "uv-chemical-bath-recipes",
	energy_required = UV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "europium-reinforced-radiation-proof-machine-casing", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 115.2 },
    }
}
create_item{
	name = "active-neutronium-casing",
	category = "uv-polarizer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "neutronium-casing", amount = 1 },
    }
}
create_item{
	name = "neutronium-stabalization-casing",
	category = "uv-assembling-machine-recipes",
	energy_required = UV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "uhv-machine-casing", amount = 1 },
		{ type = "item", name = "zpm-field-generator", amount = 1 },
		{ type = "item", name = "naquadah-alloy-frame", amount = 4 },
		{ type = "item", name = "naquadah-alloy-screw", amount = 24 },
    },
	results = {
		{ type = "item", name = "neutronium-stabalization-casing", amount = 4 },
	}
}










-------------------------
---   SINGULARITIES   ---
-------------------------

create_item{
	name = "iron-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-iron", amount = 7296 },
    }
}
create_item{
	name = "gold-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-gold", amount = 1215 },
    }
}
create_item{
	name = "lapis-lazuli-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "lapis-lazuli", amount = 9 },
    }
}
create_item{
	name = "lapis-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "lapis-lazuli-block", amount = 1215 },
    }
}
create_item{
	name = "redstone-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-redstone", amount = 7296 },
    }
}
create_item{
	name = "block-of-quartz",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "nether-quartz", amount = 4 },
    }
}
create_item{
	name = "nether-quartz-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-quartz", amount = 1215 },
    }
}
create_item{
	name = "copper-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-copper", amount = 3648 },
    }
}
create_item{
	name = "tin-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-tin", amount = 3648 },
    }
}
create_item{
	name = "leaden-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-lead", amount = 3648 },
    }
}
create_item{
	name = "silver-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-silver", amount = 7296 },
    }
}
create_item{
	name = "nickel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-nickel", amount = 3648 },
    }
}
create_item{
	name = "enderium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-enderium", amount = 608 },
    }
}
create_item{
	name = "coal-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "coal", amount = 9 },
    }
}
create_item{
	name = "coal-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-coal", amount = 3648 },
    }
}
create_item{
	name = "emerald-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-emerald", amount = 729 },
    }
}
create_item{
	name = "diamond-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-diamond", amount = 729 },
    }
}
create_item{
	name = "aluminium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-aluminium", amount = 1824 },
    }
}
create_item{
	name = "brass-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-brass", amount = 1824 },
    }
}
create_item{
	name = "bronze-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-bronze", amount = 1824 },
    }
}
create_item{
	name = "charcoal-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "charcoal", amount = 9 },
    }
}
create_item{
	name = "charcoal-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-charcoal", amount = 7296 },
    }
}
create_item{
	name = "electrum-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-electrum", amount = 912 },
    }
}
create_item{
	name = "invar-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-invar", amount = 1824 },
    }
}
create_item{
	name = "osmium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-osmium", amount = 406 },
    }
}
create_item{
	name = "block-of-olivine",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "olivine", amount = 9 },
    }
}
create_item{
	name = "olivine-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-olivine", amount = 608 },
    }
}
create_item{
	name = "block-of-ruby",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "ruby", amount = 9 },
    }
}
create_item{
	name = "ruby-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-ruby", amount = 608 },
    }
}
create_item{
	name = "block-of-magnesium",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "magnesium", amount = 9 },
    }
}
create_item{
	name = "magnesium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-magnesium", amount = 3648 },
    }
}
create_item{
	name = "block-of-sapphire",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "sapphire", amount = 9 },
    }
}
create_item{
	name = "sapphire-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-sapphire", amount = 608 },
    }
}
create_item{
	name = "steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-steel", amount = 912 },
    }
}
create_item{
	name = "titanium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-titanium", amount = 2024 },
    }
}
create_item{
	name = "tungsten-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-tungsten", amount = 244 },
    }
}
create_item{
	name = "block-of-uranium",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "uranium-ingot", amount = 9 },
    }
}
create_item{
	name = "uranium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-uranium", amount = 507 },
    }
}
create_item{
	name = "block-of-zinc",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "zinc-ingot", amount = 9 },
    }
}
create_item{
	name = "zinc-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-zinc", amount = 3648 },
    }
}
create_item{
	name = "block-of-tricalcium-phosphate",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "tricalcium-phosphate", amount = 9 },
    }
}
create_item{
	name = "tricalcium-phosphate-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-tricalcium-phosphate", amount = 365 },
    }
}
create_item{
	name = "palladium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-palladium", amount = 136 },
    }
}
create_item{
	name = "damascus-steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-damascus-steel", amount = 153 },
    }
}
create_item{
	name = "black-steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-black-steel", amount = 304 },
    }
}
create_item{
	name = "fluxed-electrum-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-fluxed-electrum", amount = 16 },
    }
}
create_item{
	name = "block-of-quicksilver",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "quicksilver", amount = 9 },
    }
}
create_item{
	name = "quicksilver-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-quicksilver", amount = 1824 },
    }
}
create_item{
	name = "shadow-steel-steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-shadow-steel", amount = 406 },
    }
}
create_item{
	name = "iridium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-iridium", amount = 62 },
    }
}
create_item{
	name = "nether-star-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "nether-star", amount = 9 },
    }
}
create_item{
	name = "nether-star-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-nether-star", amount = 512 },
    }
}
create_item{
	name = "platinum-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-platinum", amount = 406 },
    }
}
create_item{
	name = "naquadria-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-naquadria", amount = 66 },
    }
}
create_item{
	name = "plutonium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-plutonium-239", amount = 244 },
    }
}
create_item{
	name = "meteoric-iron-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-meteoric-iron", amount = 912 },
    }
}
create_item{
	name = "desh-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-desh", amount = 203 },
    }
}
create_item{
	name = "europium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-europium", amount = 62 },
    }
}
create_item{
	name = "draconium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-draconium", amount = 1296 },
    }
}
create_item{
	name = "awakened-draconium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-awakened-draconium", amount = 760 },
    }
}
create_item{
	name = "conductive-iron-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-conductive-iron", amount = 912 },
    }
}
create_item{
	name = "electrical-steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-electrical-steel", amount = 912 },
    }
}
create_item{
	name = "energetic-alloy-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-energetic-alloy", amount = 191 },
    }
}
create_item{
	name = "dark-steel-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-dark-steel", amount = 912 },
    }
}
create_item{
	name = "pulsating-iron-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-pulsating-iron", amount = 912 },
    }
}
create_item{
	name = "red-alloy-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-red-alloy", amount = 912 },
    }
}
create_item{
	name = "soularium-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-soularium", amount = 456 },
    }
}
create_item{
	name = "vibrant-alloy-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-vibrant-alloy", amount = 145 },
    }
}
create_item{
	name = "unstable-ingot-block",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "unstable-ingot", amount = 9 },
    }
}
create_item{
	name = "unstable-ingot-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-unstable-ingot", amount = 66 },
    }
}
create_item{
	name = "electrotine-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-electrotine", amount = 1215 },
    }
}
create_item{
	name = "aluminium-brass-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-aluminium-brass", amount = 1824 },
    }
}
create_item{
	name = "alumite-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-alumite", amount = 229 },
    }
}
create_item{
	name = "ardite-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-ardite", amount = 304 },
    }
}
create_item{
	name = "cobalt-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-cobalt", amount = 1824 },
    }
}
create_item{
	name = "ender-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-enderpearl", amount = 608 },
    }
}
create_item{
	name = "manyullyn-singularity",
	category = "hv-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
      {type = "item", name = "block-of-manyullyn", amount = 308 },
    }
}
create_item{
	name = "meteoric-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "vibrant-alloy-singularity", amount = 1 },
      {type = "item", name = "unstable-ingot-singularity", amount = 1 },
      {type = "item", name = "electrotine-singularity", amount = 1 },
      {type = "item", name = "aluminium-brass-singularity", amount = 1 },
      {type = "item", name = "alumite-singularity", amount = 1 },
      {type = "item", name = "ardite-singularity", amount = 1 },
      {type = "item", name = "cobalt-singularity", amount = 1 },
      {type = "item", name = "ender-singularity", amount = 1 },
      {type = "item", name = "manyullyn-singularity", amount = 1 },
    }
}
create_item{
	name = "historic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "draconium-singularity", amount = 1 },
      {type = "item", name = "awakened-draconium-singularity", amount = 1 },
      {type = "item", name = "conductive-iron-singularity", amount = 1 },
      {type = "item", name = "electrical-steel-singularity", amount = 1 },
      {type = "item", name = "energetic-alloy-singularity", amount = 1 },
      {type = "item", name = "dark-steel-singularity", amount = 1 },
      {type = "item", name = "pulsating-iron-singularity", amount = 1 },
      {type = "item", name = "red-alloy-singularity", amount = 1 },
      {type = "item", name = "soularium-singularity", amount = 1 },
    }
}
create_item{
	name = "cryptic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "shadow-steel-singularity", amount = 1 },
      {type = "item", name = "iridium-singularity", amount = 1 },
      {type = "item", name = "nether-star-singularity", amount = 1 },
      {type = "item", name = "platinum-singularity", amount = 1 },
      {type = "item", name = "naquadria-singularity", amount = 1 },
      {type = "item", name = "damascus-steel-singularity", amount = 1 },
      {type = "item", name = "meteoric-iron-singularity", amount = 1 },
      {type = "item", name = "desh-singularity", amount = 1 },
      {type = "item", name = "europium-singularity", amount = 1 },
    }
}
create_item{
	name = "pneumatic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "tungsten-singularity", amount = 1 },
      {type = "item", name = "uranium-singularity", amount = 1 },
      {type = "item", name = "zinc-singularity", amount = 1 },
      {type = "item", name = "tricalcium-phosphate-singularity", amount = 1 },
      {type = "item", name = "palladium-singularity", amount = 1 },
      {type = "item", name = "damascus-steel-singularity", amount = 1 },
      {type = "item", name = "black-steel-singularity", amount = 1 },
      {type = "item", name = "fluxed-electrum-singularity", amount = 1 },
      {type = "item", name = "quicksilver-singularity", amount = 1 },
    }
}
create_item{
	name = "sphaghettic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "electrum-singularity", amount = 1 },
      {type = "item", name = "invar-singularity", amount = 1 },
      {type = "item", name = "magnesium-singularity", amount = 1 },
      {type = "item", name = "osmium-singularity", amount = 1 },
      {type = "item", name = "peridot-singularity", amount = 1 },
      {type = "item", name = "ruby-singularity", amount = 1 },
      {type = "item", name = "sapphire-singularity", amount = 1 },
      {type = "item", name = "steel-singularity", amount = 1 },
      {type = "item", name = "titanium-singularity", amount = 1 },
    }
}
create_item{
	name = "psychotic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "nickel-singularity", amount = 1 },
      {type = "item", name = "enderium-singularity", amount = 1 },
      {type = "item", name = "coal-singularity", amount = 1 },
      {type = "item", name = "diamond-singularity", amount = 1 },
      {type = "item", name = "emerald-singularity", amount = 1 },
      {type = "item", name = "charcoal-singularity", amount = 1 },
      {type = "item", name = "aluminium-singularity", amount = 1 },
      {type = "item", name = "brass-singularity", amount = 1 },
      {type = "item", name = "bronze-singularity", amount = 1 },
    }
}
create_item{
	name = "nitronic-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-bedrockium", amount = 4 },
      {type = "item", name = "lapis-singularity", amount = 1 },
      {type = "item", name = "golden-singularity", amount = 1 },
      {type = "item", name = "silver-singularity", amount = 1 },
      {type = "item", name = "iron-singularity", amount = 1 },
      {type = "item", name = "redstone-singularity", amount = 1 },
      {type = "item", name = "tin-singularity", amount = 1 },
      {type = "item", name = "leaden-singularity", amount = 1 },
      {type = "item", name = "copper-singularity", amount = 1 },
      {type = "item", name = "nether-quartz-singularity", amount = 1 },
    }
}
create_item{
	name = "eternal-singularity",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
      {type = "item", name = "block-of-black-plutonium", amount = 12 },
      {type = "item", name = "block-of-cosmic-neutronium", amount = 10 },
      {type = "item", name = "nitronic-singularity", amount = 1 },
      {type = "item", name = "psychotic-singularity", amount = 1 },
      {type = "item", name = "sphaghettic-singularity", amount = 1 },
      {type = "item", name = "pneumatic-singularity", amount = 1 },
      {type = "item", name = "cryptic-singularity", amount = 1 },
      {type = "item", name = "historic-singularity", amount = 1 },
      {type = "item", name = "meteoric-singularity", amount = 1 },
    }
}





--------------------
---   INFINITY   ---
--------------------

create_recipe{
    name = "microminer-infinity-catalyst",
    category = "lv-assembling-machine-recipes",	
    energy_required = UHV_SPEED * 2,
    subgroup = "subgroup-microminer-t8"
	ingredients = {
      {type = "item", name = "tier-eight-microminer-output", amount = 1 }
    },
    results = {
      {type = "item", name = "raw-neutronium", amount = 32 },
      {type = "item", name = "raw-infinity-catalyst", amount = 16 },
      {type = "item", name = "raw-bedrockium", amount = 8 },
      {type = "item", name = "raw-adamantium", amount = 8 },
    },
	main_product = "raw-infinity-catalyst"
}
---INFINITY CATALYST
create_item{
	name = "infinity-catalyst",
	category = "neutronium-compressor-recipes",
	energy_required = HV_SPEED * 3,
	ingredients = {
		{ type = "item", name = "infinity-catalyst-dust", amount = 64 },
    }
}
create_recipe{
	recipe_name = "infinity-catalyst-eic",
	category = "uiv-electric-implosion-compressor-recipes",
	energy_required = UIV_SPEED * 0.05,
	ingredients = {
		{ type = "item", name = "infinity-catalyst-dust", amount = 64 },
    },
	results = {
		{ type = "item", name = "infinity-catalyst", amount = 1 },
	}
}



---INFINITY INGOT
create_item{
	name = "infinity-ingot",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-ingot", amount = 24 },
		{ type = "item", name = "crystal-matrix-ingot", amount = 10 },
		{ type = "item", name = "infinity-catalyst", amount = 11 },
    }
}
create_recipe{
	recipe_name = "solidifying-infinity-ingot",
	category = "uv-fluid-solidifier-recipes",
	energy_required = UV_SPEED * 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-infinity", amount = 14.4 },
    },
	results = {
		{ type = "item", name = "infinity-ingot", amount = 1 },
	}
}
---MOLTEN INFINITY
create_recipe{
	recipe_name = "molten-infinity-adc",
	category = "adc-dtpf-recipes",
	energy_required = UHV_SPEED * 1.95,
	ingredients = {
		{ type = "item", name = "infinity-catalyst", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 92 },
    },
	results = {
		{ type = "fluid", name = "molten-infinity", amount = 14.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 46 },
	},
	main_product = "molten-infinity"
}
create_recipe{
	recipe_name = "molten-infinity-hc",
	category = "hc-dtpf-recipes",
	energy_required = UMV_SPEED * 250,
	ingredients = {
		{ type = "item", name = "infinity-catalyst", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 5893.2 },
    },
	results = {
		{ type = "fluid", name = "molten-infinity", amount = 921.6 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 2946.6 },
	},
	main_product = "molten-infinity"
}
create_recipe{
	recipe_name = "molten-infinity-ec",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 125,
	ingredients = {
		{ type = "item", name = "infinity-catalyst", amount = 2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 2624.3 },
    },
	results = {
		{ type = "fluid", name = "molten-infinity", amount = 1843.2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 2624.3 },
	},
	main_product = "molten-infinity"
}
create_recipe{
	recipe_name = "molten-infinity-stellar",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 62.5,
	ingredients = {
		{ type = "item", name = "infinity-catalyst", amount = 4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 1137.3 },
    },
	results = {
		{ type = "fluid", name = "molten-infinity", amount = 3686.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 2274.6 },
	},
	main_product = "molten-infinity"
}




































   
   
   ---NEUTRONIUM HEAVY PLATING
 	{
		type = "item",
		name = "neutronium-heavy-plating",
		icon = "__Gregtorio__/graphics/icons/neutronium-heavy-plating.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "neutronium-heavy-plating",
		category = "omnic-forge-recipes",
		enabled = false,
		energy_required = 1280,
		ingredients = {
			{ type = "item", name = "neutronium-plate", amount = 4 },
			{ type = "item", name = "mote-of-omnium", amount = 2 },
			{ type = "item", name = "quantum-eye", amount = 16 },
			{ type = "fluid", name = "xenon", amount = 100 },
		},
		results = {
			{ type = "item", name = "neutronium-heavy-plating", amount = 1 }
		}
   },



   ---NEUTRONIUM PLATED MICROMINER
 	{
		type = "item",
		name = "neutronium-plated-microminer",
		icon = "__Gregtorio__/graphics/icons/neutronium-plated-microminer.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64
	},   
	{
		type = "recipe",
		name = "neutronium-plated-microminer",
		category = "ultimate-extended-crafting-recipes",
		enabled = false,
		energy_required = 1,
		ingredients = {
			{ type = "item", name = "neutronium-heavy-plating", amount = 38 },
			{ type = "item", name = "universal-navigator", amount = 2 },
			{ type = "item", name = "universal-warp-controller", amount = 2 },
			{ type = "item", name = "universal-warp-core", amount = 2 },
			{ type = "item", name = "energy-cluster", amount = 1 },
			{ type = "item", name = "quantum-chest-v", amount = 1 },
			{ type = "item", name = "neutronium-solar-panel", amount = 2 },
			{ type = "item", name = "hadal-warp-engine", amount = 6 },
		},
		results = {
			{ type = "item", name = "neutronium-plated-microminer", amount = 1 }
		}
   },
   
  
})







------------------
---  HYPOGEN   ---
------------------

---MOLTEN HYPOGEN
create_recipe{
    recipe_name = "molten-hypogen",
    category = "mk4-fusion-reactor-recipes",	
    energy_required = UHV_SPEED * 409.6,
	ingredients = {
      {type = "fluid", name = "molten-dragonblood", amount = 14.4 },
      {type = "fluid", name = "molten-rhugnor", amount = 28.8 },
    },
    results = {
      {type = "fluid", name = "molten-hypogen", amount = 3.6 },
    }
}
create_recipe{
	recipe_name = "molten-hypogen-prosaic",
	category = "ic-dtpf-recipes",
	energy_required = UXV_SPEED * 75,
	ingredients = {
		{ type = "fluid", name = "molten-hypogen", amount = 14.4 },
		{ type = "fluid", name = "molten-neutronium", amount = 576 },
		{ type = "fluid", name = "molten-quantum", amount = 576 },
		{ type = "fluid", name = "molten-infinity", amount = 144 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 100 },
    },
	results = {
		{ type = "fluid", name = "molten-hypogen", amount = 158.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 25 },
	},
	main_product = "molten-hypogen"
}
create_recipe{
	recipe_name = "molten-hypogen-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = UXV_SPEED * 75,
	ingredients = {
		{ type = "fluid", name = "molten-neutronium", amount = 576 },
		{ type = "fluid", name = "molten-quantum", amount = 576 },
		{ type = "fluid", name = "molten-infinity", amount = 144 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 100 },
    },
	results = {
		{ type = "fluid", name = "molten-hypogen", amount = 288 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 50 },
	},
	main_product = "molten-hypogen"
}
create_recipe{
	recipe_name = "molten-hypogen-exotic",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 75,
	ingredients = {
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 576 },
		{ type = "fluid", name = "molten-quantum", amount = 576 },
		{ type = "fluid", name = "molten-infinity", amount = 144 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 100 },
    },
	results = {
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "molten-hypogen", amount = 576 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	main_product = "molten-hypogen"
}
create_recipe{
	recipe_name = "molten-hypogen-stellar",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 75,
	ingredients = {
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "molten-neutronium", amount = 576 },
		{ type = "fluid", name = "molten-quantum", amount = 576 },
		{ type = "fluid", name = "molten-infinity", amount = 144 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 100 },
    },
	results = {
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "molten-hypogen", amount = 1152 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 200 },
	},
	main_product = "molten-hypogen"
}










--------------------
---   UHV JUNK   ---
--------------------

---PHOTONIC SOLAR PANEL
create_item{
	name = "photonic-solar-panel",
	category = "uhv-assembling-machine-recipes",
	energy_required = UHV_SPEED * 110,
	ingredients = {
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-solar-panel", amount = 1 },
		{ type = "item", name = "uv-robot-arm", amount = 1 },
		{ type = "item", name = "large-naquadria-battery", amount = 1 },
		{ type = "fluid", name = "soldering-alloy", amount = 115.2 },
	}
}
---LARGE NAQUADRIA BATTERY
create_item{
	name = "large-naquadria-battery",
	category = "iv-canning-machine-recipes",
	energy_required = IV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "empty-large-naquadria-battery", amount = 1 },
		{ type = "item", name = "naquadria-dust", amount = 32 },
	}
}
---EMPTY LARGE NAQUADRIA BATTERY
create_item{
	name = "empty-large-naquadria-battery",
	category = "zpm-assembling-machine-recipes",
	energy_required = ZPM_SPEED * 15,
	ingredients = {
		{ type = "item", name = "americium-plate", amount = 18 },
		{ type = "item", name = "fluxed-electrum-cable", amount = 2 },
		{ type = "fluid", name = "super-glue", amount = 57.6 },
	}
}
---UV SOLAR PANEL
create_item{
	name = "uv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 36 },
		{ type = "item", name = "dense-poly-si-plate", amount = 16 },
		{ type = "item", name = "raw-advanced-crystal-chip", amount = 2 },
		{ type = "item", name = "piko-power-ic", amount = 4 },
		{ type = "item", name = "americium-doped-wafer", amount = 4 },
		{ type = "item", name = "raw-pico-wafer", amount = 2 },
		{ type = "item", name = "pico-wafer", amount = 4 },
		{ type = "item", name = "carbon-plate", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-neutronium-plate", amount = 4 },
		{ type = "item", name = "dense-polybenzimidazole-sheet", amount = 2 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "dense-polybenzimidazole-sheet", amount = 2 },
		{ type = "item", name = "zpm-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-neutronium-plate",
	category = "uhv-assembling-machine-recipes",
	energy_required = 30 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-neutronium-iron-plate", amount = 1 },
		{ type = "item", name = "enriched-naquadria-neutronium-sunnarium-alloy", amount = 1 },
		{ type = "item", name = "mysterious-crystal-plate", amount = 1 },
		{ type = "item", name = "infinity-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 1843.2 },
	}
}
create_item{
	name = "reinforced-neutronium-iron-plate",
	category = "uhv-assembling-machine-recipes",
	energy_required = 5 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "neutronium-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "black-plutonium-plate", amount = 4 },
	}
}
create_item{
	name = "neutronium-iron-plate",
	category = "uhv-bending-machine-recipes",
	energy_required = 30 * UHV_SPEED,
	ingredients = {
		{ type = "item", name = "neutronium-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---ZPM SOLAR PANEL
create_item{
	name = "zpm-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 24 },
		{ type = "item", name = "asoc-wafer", amount = 2 },
		{ type = "item", name = "nano-power-ic", amount = 4 },
		{ type = "item", name = "americium-doped-wafer", amount = 4 },
		{ type = "item", name = "europium-doped-wafer", amount = 4 },
		{ type = "item", name = "qpic-wafer", amount = 2 },
		{ type = "item", name = "carbon-plate", amount = 2 },
		{ type = "item", name = "irradiant-reinforced-naquadria-plate", amount = 4 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 8 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "luv-solar-panel", amount = 1 },
	},
	results = {
		{ type = "item", name = "zpm-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-naquadria-plate",
	category = "uv-assembling-machine-recipes",
	energy_required = 30 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-naquadria-iron-plate", amount = 1 },
		{ type = "item", name = "enriched-naquadria-sunnarium-alloy", amount = 1 },
		{ type = "item", name = "quantium-plate", amount = 1 },
		{ type = "item", name = "osmiridium-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 921.6 },
	}
}
create_item{
	name = "reinforced-naquadria-iron-plate",
	category = "uv-assembling-machine-recipes",
	energy_required = 5 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadria-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "mysterious-crystal-plate", amount = 4 },
	}
}
create_item{
	name = "naquadria-iron-plate",
	category = "uv-bending-machine-recipes",
	energy_required = 30 * UV_SPEED,
	ingredients = {
		{ type = "item", name = "naquadria-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---LUV SOLAR PANEL
create_item{
	name = "luv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "palladium-naqindium-superconductive-wire", amount = 16 },
		{ type = "item", name = "ultra-high-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "nano-power-ic", amount = 4 },
		{ type = "item", name = "naquadah-doped-wafer", amount = 4 },
		{ type = "item", name = "europium-doped-wafer", amount = 4 },
		{ type = "item", name = "solar-light-splitter", amount = 2 },
		{ type = "item", name = "carbon-plate", amount = 2 },
		{ type = "item", name = "irradiant-reinforced-iridium-plate", amount = 2 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 6 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "iv-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-iridium-plate",
	category = "zpm-assembling-machine-recipes",
	energy_required = 30 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-iridium-iron-plate", amount = 1 },
		{ type = "item", name = "enriched-sunnarium-alloy", amount = 1 },
		{ type = "item", name = "osmium-plate", amount = 1 },
		{ type = "item", name = "iridium-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 406.8 },
	}
}
create_item{
	name = "reinforced-iridium-iron-plate",
	category = "zpm-assembling-machine-recipes",
	energy_required = 5 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "iridium-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "diamond-plate", amount = 4 },
	}
}
create_item{
	name = "iridium-iron-plate",
	category = "zpm-bending-machine-recipes",
	energy_required = 30 * ZPM_SPEED,
	ingredients = {
		{ type = "item", name = "iridium-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---IV SOLAR PANEL
create_item{
	name = "iv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 6 },
		{ type = "item", name = "high-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "poly-si-plate", amount = 16 },
		{ type = "item", name = "naquadah-doped-wafer", amount = 4 },
		{ type = "item", name = "phosphorus-doped-wafer", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-chrome-plate", amount = 2 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 4 },
		{ type = "item", name = "zpm-circuit", amount = 4 },
		{ type = "item", name = "hv-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-chrome-plate",
	category = "luv-assembling-machine-recipes",
	energy_required = 30 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-chrome-iron-plate", amount = 1 },
		{ type = "item", name = "sunnarium-alloy", amount = 1 },
		{ type = "item", name = "yttrium-barium-cuprate-plate", amount = 1 },
		{ type = "item", name = "fiery-steel-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 230.4 },
	}
}
create_item{
	name = "reinforced-chrome-iron-plate",
	category = "luv-assembling-machine-recipes",
	energy_required = 5 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "chrome-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "diamond-plate", amount = 4 },
	}
}
create_item{
	name = "chrome-iron-plate",
	category = "luv-bending-machine-recipes",
	energy_required = 30 * LUV_SPEED,
	ingredients = {
		{ type = "item", name = "chromium-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---EV SOLAR PANEL
create_item{
	name = "ev-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "indovanadium-superconductive-wire", amount = 6 },
		{ type = "item", name = "medium-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "poly-si-plate", amount = 12 },
		{ type = "item", name = "naquadah-doped-wafer", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-tungstensteel-plate", amount = 2 },
		{ type = "item", name = "polybenzimidazole-sheet", amount = 2 },
		{ type = "item", name = "luv-circuit", amount = 4 },
		{ type = "item", name = "hv-solar-panel", amount = 1 },
	}
}

create_item{
	name = "irradiant-reinforced-tungstensteel-plate",
	category = "iv-assembling-machine-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-tungstensteel-iron-plate", amount = 1 },
		{ type = "item", name = "sunnarium-plate", amount = 4 },
		{ type = "item", name = "plutonium-239-plate", amount = 1 },
		{ type = "item", name = "knightmetal-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 115.2 },
	}
}
create_item{
	name = "reinforced-tungstensteel-iron-plate",
	category = "iv-assembling-machine-recipes",
	energy_required = 5 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tungstensteel-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "tungstensteel-plate", amount = 4 },
	}
}
create_item{
	name = "tungstensteel-iron-plate",
	category = "iv-bending-machine-recipes",
	energy_required = 30 * IV_SPEED,
	ingredients = {
		{ type = "item", name = "tungstensteel-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---HV SOLAR PANEL
create_item{
	name = "hv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "uranium-triplatinide-superconductive-wire", amount = 4 },
		{ type = "item", name = "low-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "phosphorus-doped-wafer", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-tungsten-plate", amount = 2 },
		{ type = "item", name = "indium-gallium-phosphide-plate", amount = 2 },
		{ type = "item", name = "iv-circuit", amount = 4 },
		{ type = "item", name = "mv-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-tungsten-plate",
	category = "ev-assembling-machine-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-titanium-iron-plate", amount = 1 },
		{ type = "item", name = "enriched-sunnarium", amount = 1 },
		{ type = "item", name = "uranium-238-plate", amount = 1 },
		{ type = "item", name = "steeleaf-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 57.6 },
	}
}
create_item{
	name = "reinforced-tungsten-iron-plate",
	category = "ev-assembling-machine-recipes",
	energy_required = 5 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "tungsten-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "tungsten-plate", amount = 4 },
	}
}
create_item{
	name = "tungsten-iron-plate",
	category = "ev-bending-machine-recipes",
	energy_required = 30 * EV_SPEED,
	ingredients = {
		{ type = "item", name = "tungsten-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---MV SOLAR PANEL
create_item{
	name = "mv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "cuprobarite-superconductive-wire", amount = 4 },
		{ type = "item", name = "ultra-low-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "phosphorus-doped-wafer", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-titanium-plate", amount = 2 },
		{ type = "item", name = "epoxid-sheet", amount = 2 },
		{ type = "item", name = "ev-circuit", amount = 4 },
		{ type = "item", name = "lv-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-titanium-plate",
	category = "hv-assembling-machine-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-titanium-iron-plate", amount = 1 },
		{ type = "item", name = "sunnarium", amount = 1 },
		{ type = "item", name = "meteoric-steel-plate", amount = 1 },
		{ type = "item", name = "lapis-plate", amount = 2 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "fluid", name = "soldering-alloy", amount = 28.8 },
	}
}
create_item{
	name = "reinforced-titanium-iron-plate",
	category = "hv-assembling-machine-recipes",
	energy_required = 5 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "titanium-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "poly-si-plate", amount = 4 },
	}
}
create_item{
	name = "titanium-iron-plate",
	category = "hv-bending-machine-recipes",
	energy_required = 30 * HV_SPEED,
	ingredients = {
		{ type = "item", name = "titanium-plate", amount = 2 },
		{ type = "item", name = "iron-plate", amount = 4 },
	}
}
---LV SOLAR PANEL
create_item{
	name = "lv-solar-panel",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "cadmoxium-wire", amount = 4 },
		{ type = "item", name = "ultra-low-powered-integrated-circuit", amount = 2 },
		{ type = "item", name = "phosphorus-doped-wafer", amount = 4 },
		{ type = "item", name = "irradiant-reinforced-aluminium-plate", amount = 2 },
		{ type = "item", name = "ptfe-sheet", amount = 2 },
		{ type = "item", name = "hv-circuit", amount = 2 },
		{ type = "item", name = "8v-solar-panel", amount = 1 },
	}
}
create_item{
	name = "irradiant-reinforced-aluminium-plate",
	category = "mv-assembling-machine-recipes",
	energy_required = 30 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "reinforced-aluminium-iron-plate", amount = 1 },
		{ type = "item", name = "diamond", amount = 1 },
		{ type = "item", name = "vibrant-crystal", amount = 1 },
		{ type = "item", name = "red-alloy-screw", amount = 4 },
		{ type = "item", name = "red-alloy-plate", amount = 2 },
		{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
	}
}
---8V SOLAR PANEL
create_item{
	name = "8v-solar-panel",
	ingredients = {
		{ type = "item", name = "tin-wire", amount = 2 },
		{ type = "item", name = "silicon-wafer", amount = 1 },
		{ type = "item", name = "reinforced-aluminium-iron-plate", amount = 1 },
		{ type = "item", name = "gallium-arsenide-plate", amount = 1 },
		{ type = "item", name = "mv-circuit", amount = 2 },
		{ type = "item", name = "solar-panel", amount = 2 }
	}
}
create_item{
	name = "reinforced-aluminium-iron-plate",
	category = "mv-assembling-machine-recipes",
	energy_required = 5 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "aluminium-iron-plate", amount = 1 },
		{ type = "item", name = "advanced-alloy", amount = 4 },
		{ type = "item", name = "carbon-plate", amount = 4 },
	}
}
---SOLAR PANEL
create_item{
	name = "solar-panel",
	ingredients = {
		{ type = "item", name = "red-alloy-wire", amount = 2 },
		{ type = "item", name = "silicon-wafer", amount = 2 },
		{ type = "item", name = "aluminium-iron-plate", amount = 1 },
		{ type = "item", name = "reinforced-glass", amount = 1 },
		{ type = "item", name = "carbon-plate", amount = 1 },
		{ type = "item", name = "lv-circuit", amount = 2 }
	}
}
create_item{
	name = "aluminium-iron-plate",
	category = "mv-bending-machine-recipes",
	energy_required = 30 * MV_SPEED,
	ingredients = {
		{ type = "item", name = "iron-plate", amount = 4 },
		{ type = "item", name = "aluminium-plate", amount = 2 },
	}
}