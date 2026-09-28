--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---------------------------
---   CHROMATIC GLASS   ---
---------------------------

create_endgame_parts{
	name = "chromatic-glass",
	tier = "uhv",
	speed = UHV_SPEED
	skip_ingot = true,
	skip_block = true,
	skip_long_rod = true,
	skip_rod = true,
	skip_frame = true,
	skip_wire = true,
	skip_large_gear = true,
	skip_gear = true,
	skip_ring = true,
	skip_round = true,
	skip_rotor = true,
	skip_superdense_plate = true
}



create_item{
	recipe_name = "chromatic-glass",
	category = "uhv-laser-engraver-recipes",
	energy_required = UHV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "glass-dust", amount = 64 },
	},
	results = {
		{ type = "item", name = "chromatic-glass-dust", amount = 1 },
	},
}
create_item{
	recipe_name = "chromatic-glass-ingot",
	category = "multismelter-recipes",
	energy_required = 10,
	ingredients = {
		{ type = "item", name = "chromatic-glass-dust", amount = 64 },
	},
	results = {
		{ type = "item", name = "chromatic-glass-ingot", amount = 64 },
	},
}
create_recipe{
	recipe_name = "chromatic-glass-crude",
	category = "adc-dtpf-recipes",
	energy_required = UMV_SPEED * 150,
	ingredients = {
		{ type = "fluid", name = "molten-glass", amount = 3686.4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 15604 },
	},
	results = {
		{ type = "fluid", name = "molten-chromatic-glass", amount = 3686.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1950.5 },
	},
}
create_recipe{
	recipe_name = "chromatic-glass-prosaic",
	category = "ic-dtpf-recipes",
	energy_required = UMV_SPEED * 75,
	ingredients = {
		{ type = "fluid", name = "molten-glass", amount = 7372.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 6105.9 },
	},
	results = {
		{ type = "fluid", name = "molten-chromatic-glass", amount = 7372.8 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1526.4 },
	},
}
create_recipe{
	recipe_name = "chromatic-glass-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = UMV_SPEED * 37.5,
	ingredients = {
		{ type = "fluid", name = "molten-glass", amount = 14745.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 2635 },
	},
	results = {
		{ type = "fluid", name = "molten-chromatic-glass", amount = 14745.6 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1317.5 },
	},
}
create_recipe{
	recipe_name = "chromatic-glass-stellar",
	category = "ec-dtpf-recipes",
	energy_required = UMV_SPEED * 18.75,
	ingredients = {
		{ type = "fluid", name = "molten-glass", amount = 29491.2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 1111.6 },
	},
	results = {
		{ type = "fluid", name = "molten-chromatic-glass", amount = 29491.2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1111.6 },
	},
}







--------------------------
---   UEV COMPONENTS   ---
--------------------------

---DRACONIUM CABLE
create_item{
	name = "draconium-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 5,
	ingredients = {
		{ type = "item", name = "draconium-wire", amount = 4 },
		{ type = "item", name = "polydimethylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "draconium-cable", amount = 4 },
	}
}



---UEV MOTOR
create_item{
	name = "uev-motor",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "long-attuned-tengam-rod", amount = 8 },
		{ type = "item", name = "long-infinity-rod", amount = 16 },
		{ type = "item", name = "infinity-ring", amount = 8 },
		{ type = "item", name = "infinity-round", amount = 32 },
		{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 512 },
		{ type = "item", name = "draconium-cable", amount = 8 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV PISTON
create_item{
	name = "uev-piston",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uev-motor", amount = 1 },
		{ type = "item", name = "infinity-plate", amount = 6 },
		{ type = "item", name = "infinity-ring", amount = 8 },
		{ type = "item", name = "infinity-round", amount = 64 },
		{ type = "item", name = "infinity-rod", amount = 8 },
		{ type = "item", name = "large-infinity-gear", amount = 2 },
		{ type = "item", name = "infinity-gear", amount = 4 },
		{ type = "item", name = "draconium-cable", amount = 16 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV PUMP
create_item{
	name = "uev-pump",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uev-motor", amount = 1 },
		{ type = "item", name = "nether-star-plate", amount = 12 },
		{ type = "item", name = "infinity-plate", amount = 4 },
		{ type = "item", name = "infinity-screw", amount = 16 },
		{ type = "item", name = "silicone-rubber-ring", amount = 64 },
		{ type = "item", name = "infinity-rotor", amount = 4 },
		{ type = "item", name = "draconium-cable", amount = 8 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV CONVEYOR MODULE
create_item{
	name = "uev-conveyor-module",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uev-motor", amount = 2 },
		{ type = "item", name = "infinity-plate", amount = 2 },
		{ type = "item", name = "infinity-ring", amount = 8 },
		{ type = "item", name = "infinity-round", amount = 64 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
		{ type = "item", name = "bedrockium-cable", amount = 8 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV ROBOT ARM
create_item{
	name = "uev-robot-arm",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uev-motor", amount = 2 },
		{ type = "item", name = "uev-piston", amount = 1 },
		{ type = "item", name = "long-infinity-rod", amount = 8 },
		{ type = "item", name = "large-infinity-gear", amount = 2 },
		{ type = "item", name = "infinity-gear", amount = 6 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 4 },
		{ type = "item", name = "uv-circuit", amount = 8 },
		{ type = "item", name = "draconium-cable", amount = 24 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV SENSOR
create_item{
	name = "uev-sensor",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "infinity-frame", amount = 1 },
		{ type = "item", name = "uev-motor", amount = 1 },
		{ type = "item", name = "infinity-plate", amount = 8 },
		{ type = "item", name = "gravi-star", amount = 16 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "infinity-catalyst-foil", amount = 256 },
		{ type = "item", name = "draconium-cable", amount = 28 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV EMITTER
create_item{
	name = "uev-emitter",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "infinity-frame", amount = 1 },
		{ type = "item", name = "uev-motor", amount = 1 },
		{ type = "item", name = "infinity-rod", amount = 16 },
		{ type = "item", name = "gravi-star", amount = 16 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "infinity-catalyst-foil", amount = 256 },
		{ type = "item", name = "draconium-cable", amount = 28 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
		{ type = "fluid", name = "lubricant", amount = 400 },
	}
}



---UEV FIELD GENERATOR
create_item{
	name = "uev-field-generator",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "infinity-frame", amount = 1 },
		{ type = "item", name = "uev-emitter", amount = 4 },
		{ type = "item", name = "cosmic-neutronium-plate", amount = 6 },
		{ type = "item", name = "gravi-star", amount = 8 },
		{ type = "item", name = "optical-mainframe", amount = 4 },
		{ type = "item", name = "fine-cosmic-neutronium-wire", amount = 512 },
		{ type = "item", name = "draconium-cable", amount = 32 },
		{ type = "fluid", name = "molten-quantium", amount = 259.2 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 259.2 },
	}
}



---UEV MACHINE CASING
create_item{
	name = "uev-machine-casing",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "bedrockium-plate", amount = 8 },
    }
}



---UEV MACHINE HULL
create_item{
	name = "uhv-machine-hull",
	category = "lv-assembling-machine-recipes",
	energy_required = 2.5,
	ingredients = {
		{ type = "item", name = "uev-machine-casing", amount = 1 },
		{ type = "item", name = "draconium-cable", amount = 16 },
		{ type = "fluid", name = "polybenzimidazole", amount = 57.6 },
    }
}



---UEV ENERGY HATCH
create_item{
	name = "uev-energy-hatch",
	category = "uev-assembly-line-recipes",
	energy_required = 50 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 8 },
		{ type = "item", name = "quantum-power-ic", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 4 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 3 },
		{ type = "item", name = "uev-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 3200 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "uu-matter", amount = 800 },
    }
}



---UEV DYNAMO HATCH
create_item{
	name = "uev-dynamo-hatch",
	category = "uev-assembly-line-recipes",
	energy_required = 50 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "uhv-machine-hull", amount = 1 },
		{ type = "item", name = "dracofinium-spring", amount = 8 },
		{ type = "item", name = "quantum-power-ic", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 4 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 3 },
		{ type = "item", name = "uev-pump", amount = 1 },
		{ type = "fluid", name = "lapis-coolant", amount = 3200 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 288 },
		{ type = "fluid", name = "uu-matter", amount = 800 },
    }
}



--INFINITY COIL BLOCK (UIV)
create_item{
	name = "infinity-coil-block",
	category = "uev-assembly-line-recipes",
	energy_required = 60 * UEV_SPEED,
	ingredients = {
		{ type = "item", name = "infinity-wire", amount = 16 },
		{ type = "item", name = "infinity-screw", amount = 8 },
		{ type = "item", name = "cosmic-neutronium-foil", amount = 8 },
		{ type = "item", name = "uvh-circuit", amount = 1 },
		{ type = "fluid", name = "molten-awakened-draconium", amount = 57.6 }
	}
} 











-------------------------------------
---   QUANTUM FORCE TRANSFORMER   ---
-------------------------------------

create_item{
	name = "quantum-force-transformer-controller",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 1200,
	ingredients = {
		{ type = "item", name = "molecular-transformer-controller", amount = 1 },
		{ type = "item", name = "uev-circuit", amount = 8 },
		{ type = "item", name = "uev-pump", amount = 4 },
		{ type = "item", name = "uev-field-generator", amount = 4 },
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "fluid", name = "mutated-living-solder", amount = 144 },
		{ type = "fluid", name = "molten-pikyonium-64b", amount = 460.8 },
	}
}



create_item{
	name = "uev-quantum-force-transformer",
	ingredients = {
		{ type = "item", name = "quantum-force-transformer-controller", amount = 1 },
		{ type = "item", name = "quantum-force-transformer-coil-casing", amount = 177 },
		{ type = "item", name = "force-field-glass", amount = 224 },
		{ type = "item", name = "neutron-pulse-manipulator", amount = 236 },
		{ type = "item", name = "bulk-production-frame", amount = 145 },
		{ type = "item", name = "neutron-shielding-core", amount = 142 },
		{ type = "item", name = "uv-machine-hull", amount = 7 },
		{ type = "item", name = "uev-energy-hatch", amount = 7 },
	}
}



create_item{
	name = "quantum-force-transformer-coil-casing",
	category = "uiv-assembling-machine-recipes",
	energy_required = LUV_SPEED * 90,
	ingredients = {
		{ type = "item", name = "infinity-coil-block", amount = 1 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 4 },
		{ type = "item", name = "laurenium-plate", amount = 4 },
		{ type = "item", name = "molecular-coil", amount = 1 },
		{ type = "fluid", name = "molten-quantum", amount = 57.6 },
	}
}



create_item{
	name = "force-field-glass",
	category = "uiv-assembling-machine-recipes",
	energy_required = UEV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "quantum-glass", amount = 1 },
		{ type = "item", name = "zpm-field-generator", amount = 1 },
		{ type = "item", name = "long-celestial-tungsten-rod", amount = 6 },
		{ type = "item", name = "chromatic-glass-plate", amount = 6 },
		{ type = "fluid", name = "molten-quantum", amount = 86.4 },
	}
}



create_item{
	name = "neutron-pulse-manipulator",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "force-field-glass", amount = 1 },
		{ type = "item", name = "carbon-nanites", amount = 4 },
		{ type = "item", name = "uv-emitter", amount = 4 },
		{ type = "item", name = "uhv-superconductor-wire-16x", amount = 8 },
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "item", name = "advanced-radiation-proof-plate", amount = 2 },
		{ type = "fluid", name = "molten-quantum", amount = 86.4 },
	}
}



create_item{
	name = "neutron-shielding-core",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "quantum-frame", amount = 1 },
		{ type = "item", name = "dense-precious-metals-plate", amount = 4 },
		{ type = "item", name = "superdense-neutronium-plate", amount = 2 },
		{ type = "item", name = "uv-field-generator", amount = 1 },
		{ type = "item", name = "chromatic-glass-screw", amount = 16 },
		{ type = "fluid", name = "molten-quantum", amount = 86.4 },
	}
}





---QFT GLUE
create_recipe{
	recipe_name = "glue-qft-t1",
	category = "t1-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 32 },
		{ type = "item", name = "bismuth", amount = 32 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 1000 },
		{ type = "fluid", name = "hydrogen", amount = 1000 },
		{ type = "fluid", name = "neptunium-plasma", amount = 0.4 },
    },
	results = {
		{ type = "item", name = "hyper-stable-self-healing-adhesive", amount = 1, probability = 0.6 },
		{ type = "fluid", name = "super-glue", amount = 3200, probability = 0.1 },
		{ type = "fluid", name = "advanced-glue", amount = 1600, probability = 0.1 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 921.6, probability = 0.1 },
		{ type = "fluid", name = "molten-soldering-alloy", amount = 921.6, probability = 0.1 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
	},
	main_product = "hyper-stable-self-healing-adhesive"
}
create_recipe{
	recipe_name = "glue-qft-t2",
	category = "t2-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 32 },
		{ type = "item", name = "bismuth", amount = 32 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 1000 },
		{ type = "fluid", name = "hydrogen", amount = 1000 },
		{ type = "fluid", name = "neptunium-plasma", amount = 0.8 },
    },
	results = {
		{ type = "item", name = "hyper-stable-self-healing-adhesive", amount = 1, probability = 0.8 },
		{ type = "fluid", name = "super-glue", amount = 3200, probability = 0.05 },
		{ type = "fluid", name = "advanced-glue", amount = 1600, probability = 0.05 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 921.6, probability = 0.05 },
		{ type = "fluid", name = "molten-soldering-alloy", amount = 921.6, probability = 0.05 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
	},
	main_product = "hyper-stable-self-healing-adhesive"
}
create_recipe{
	recipe_name = "hyper-stable-self-healing-adhesive",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 64 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 1000 },
		{ type = "fluid", name = "hydrogen", amount = 1000 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "hyper-stable-self-healing-adhesive", amount = 1 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
	},
	main_product = "hyper-stable-self-healing-adhesive"
}
create_recipe{
	recipe_name = "glue-qft-t3",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 64 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
		{ type = "fluid", name = "oxygen", amount = 1000 },
		{ type = "fluid", name = "hydrogen", amount = 1000 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "hyper-stable-self-healing-adhesive", amount = 0.6 },
		{ type = "fluid", name = "super-glue", amount = 3200, probability = 0.6 },
		{ type = "fluid", name = "molten-indalloy-140", amount = 921.6, probability = 0.6 },
		{ type = "fluid", name = "advanced-glue", amount = 1600, probability = 0.6 },
		{ type = "fluid", name = "molten-soldering-alloy", amount = 921.6, probability = 0.6 },
		{ type = "item", name = "adhesion-promoter-catalyst", amount = 1 },
	},
	main_product = "hyper-stable-self-healing-adhesive"
}




---QFT MONAZITE
create_recipe{
	recipe_name = "monazite-qtf-t2",
	category = "t2-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "monazite-dust", amount = 32 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 0.8 },
    },
	results = {
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 1, probability = 0.583 },
		{ type = "item", name = "cerium-dust", amount = 64, probability = 0.083 },
		{ type = "item", name = "gadolinium-dust", amount = 64, probability = 0.083 },
		{ type = "item", name = "samarium-dust", amount = 64, probability = 0.083 },
		{ type = "item", name = "hafnia-dust", amount = 64, probability = 0.083 },
		{ type = "item", name = "zirconium-dust", amount = 64, probability = 0.083 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "superconductor-rare-earth-composite"
}
create_recipe{
	recipe_name = "monazite-qtf-t3",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "monazite-dust", amount = 32 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 1, probability = 0.79 },
		{ type = "item", name = "cerium-dust", amount = 64, probability = 0.042 },
		{ type = "item", name = "gadolinium-dust", amount = 64, probability = 0.042 },
		{ type = "item", name = "samarium-dust", amount = 64, probability = 0.042 },
		{ type = "item", name = "hafnia-dust", amount = 64, probability = 0.042 },
		{ type = "item", name = "zirconium-dust", amount = 64, probability = 0.042 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "superconductor-rare-earth-composite"
}
create_recipe{
	recipe_name = "superconductor-rare-earth-composite",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "monazite-dust", amount = 32 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 1 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "superconductor-rare-earth-composite"
}
create_recipe{
	recipe_name = "monazite-qtf-t4",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "monazite-dust", amount = 32 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 1, probability = 0.583 },
		{ type = "item", name = "zirconium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "cerium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "gadolinium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "samarium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "hafnia-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "superconductor-rare-earth-composite"
}



---QFT PLASTIC
create_recipe{
	recipe_name = "plastics-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = ZPM_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 64 },
		{ type = "fluid", name = "oxygen", amount = 1600 },
		{ type = "fluid", name = "hydrogen", amount = 1600 },
		{ type = "fluid", name = "chlorine", amount = 1600 },
		{ type = "fluid", name = "fluorine", amount = 1600 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "plastic-polymer-catalyst", amount = 1 },
    },
	results = {
		{ type = "fluid", name = "epoxid", amount = 921.6, probability = 0.583 },
		{ type = "fluid", name = "polybenzimidazole", amount = 1843.2, probability = 0.583 },
		{ type = "fluid", name = "ptfe", amount = 1843.2, probability = 0.583 },
		{ type = "fluid", name = "polyvinyl-chloride", amount = 1843.2, probability = 0.583 },
		{ type = "fluid", name = "polyethylene", amount = 3686.4, probability = 0.583 },
		{ type = "item", name = "plastic-polymer-catalyst", amount = 1 },
	},
	main_product = "epoxid"
}



---QFT PLATINUM METALLIC POWDER
create_recipe{
	recipe_name = "platinum-metallic-powder-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "platinum-metallic-powder", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "platinum-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "rhodium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "ruthenium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "palladium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "iridium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "osmium-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "platinum-dust"
}



---QFT PALLADIUM METALLIC POWDER
create_recipe{
	recipe_name = "palladium-metallic-powder-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "palladium-metallic-powder", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "palladium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "rhodium-plated-palladium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "platinum-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "palladium-dust"
}



---QFT IRIDIUM METAL RESIDUE
create_recipe{
	recipe_name = "iridium-metal-residue-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "iridium-metal-residue", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "iridium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "osmium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "osmiridium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "iridium-dust"
}



---QFT RAREST METAL RESIDUE
create_recipe{
	recipe_name = "rarest-metal-residue-dust-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "rarest-metal-residue-dust", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "osmium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "iridium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "osmiridium-dust", amount = 64, probability = 0.666 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "osmium-dust"
}



---QFT CRUDE RHODIUM METAL DUST
create_recipe{
	recipe_name = "crude-rhodium-metal-dust-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "crude-rhodium-metal-dust", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "rhodium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "rhodium-plated-palladium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "palladium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "platinum-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "rhodium-dust"
}



---QFT LEECH RESIDUE DUST
create_recipe{
	recipe_name = "leech-residue-dust-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "leech-residue-dust", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "ruthenium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "rhodium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "iridium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "osmium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "platinum-group-catalyst", amount = 1 },
	},
	main_product = "ruthenium-dust"
}



---QFT RADIOACTIVES
create_recipe{
	recipe_name = "radioactives-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "thorium-dust", amount = 32 },
		{ type = "item", name = "uranium-238-dust", amount = 32 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
		{ type = "item", name = "radioactivity-catalyst", amount = 1 },
    },
	results = {
		{ type = "item", name = "thorium-232-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "uranium-233-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "uranium-235-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "plutonium-238-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "plutonium-239-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "plutonium-241-dust", amount = 64, probability = 0.583 },
		{ type = "item", name = "radioactivity-catalyst", amount = 1 },
	},
	main_product = "thorium-232-dust"
}



---QFT TITA TUNGSTEN INDIUM
create_recipe{
	recipe_name = "tita-tungsten-indium-1-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "lead-dust", amount = 16 },
		{ type = "item", name = "bauxite-dust", amount = 32 },
		{ type = "item", name = "tungstate-dust", amount = 16 },
		{ type = "item", name = "tita-tungsten-indium-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "titanium-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "tungstensteel-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "tungsten-carbide-dust", amount = 64, probability = 0.625 },
		{ type = "item", name = "indium", amount = 64, probability = 0.625 },
		{ type = "item", name = "tita-tungsten-indium-catalyst", amount = 1 },
	},
	main_product = "titanium-dust"
}
create_recipe{
	recipe_name = "tita-tungsten-indium-2-qft",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "rutile-dust", amount = 32 },
		{ type = "item", name = "scheelite-dust", amount = 16 },
		{ type = "item", name = "ilmenite-dust", amount = 16 },
		{ type = "item", name = "tita-tungsten-indium-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "titanium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "tungstensteel-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "tantalum-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "niobium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "indium", amount = 64, probability = 0.6 },
		{ type = "item", name = "tita-tungsten-indium-catalyst", amount = 1 },
	},
	main_product = "indium"
}



---QFT BASTNASITE
create_recipe{
	recipe_name = "bastnasite-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "bastnasite-dust", amount = 32 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "samarium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "holmium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "gadolinium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "cerium-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "lanthanum-dust", amount = 64, probability = 0.6 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "samarium-dust"
}



---QFT CERIUM
create_recipe{
	recipe_name = "cerium-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UHV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "cerium-rich-mixture", amount = 16 },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "samarium-dust", amount = 64, probability = 0.6  },
		{ type = "item", name = "cerium-dust", amount = 64, probability = 0.6  },
		{ type = "item", name = "holmium-dust", amount = 64, probability = 0.6  },
		{ type = "item", name = "gadolinium-dust", amount = 64, probability = 0.6  },
		{ type = "item", name = "lanthanum-dust", amount = 64, probability = 0.6  },
		{ type = "item", name = "rare-earth-group-catalyst", amount = 1 },
	},
	main_product = "cerium-dust"
}



---QFT NAQUADAH OXIDE
create_recipe{
	recipe_name = "naquadah-oxide-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UEV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "naquadah-oxide-mixture", amount = 32 },
		{ type = "item", name = "sodium", amount = 64 },
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "hydrogen", amount = 6400 },
		{ type = "fluid", name = "fluorine", amount = 6400 },
		{ type = "fluid", name = "oxygen", amount = 10 },
		{ type = "item", name = "simple-naquadah-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "inert-naquadah-dust", amount = 1 },
		{ type = "item", name = "titanium-dust", amount = 64, probability = 0.5 },
		{ type = "item", name = "adamantium-dust", amount = 64, probability = 0.5 },
		{ type = "item", name = "gallium-dust", amount = 64, probability = 0.5 },
		{ type = "item", name = "simple-naquadah-catalyst", amount = 1 },
	},
	main_product = "inert-naquadah-dust"
}



---QFT ENRICHED NAQUADAH OXIDE
create_recipe{
	recipe_name = "enriched-naquadah-oxide-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "enriched-naquadah-oxide-mixture", amount = 32 },
		{ type = "item", name = "zinc-dust", amount = 64 },
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "sulfuric-acid", amount = 1600 },
		{ type = "fluid", name = "oxygen", amount = 10 },
		{ type = "item", name = "simple-naquadah-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "inert-enriched-naquadah-dust", amount = 1 },
		{ type = "item", name = "trinium-dust", amount = 64, probability = 0.5 },
		{ type = "fluid", name = "waste-liquid", amount = 3200, probability = 0.5 },
		{ type = "item", name = "simple-naquadah-catalyst", amount = 1 },
	},
	main_product = "inert-naquadah-dust"
}



---QFT NAQUADRIAH OXIDE MIXTURE
create_recipe{
	recipe_name = "naquadriah-oxide-mixture-t3-qtf",
	category = "t3-quantum-force-transformer-recipes",
	energy_required = UMV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "naquadriah-oxide-mixture", amount = 32 },
		{ type = "item", name = "magnesium", amount = 64 },
		{ type = "fluid", name = "phosphoric-acid", amount = 1600 },
		{ type = "fluid", name = "sulfuric-acid", amount = 1600 },
		{ type = "fluid", name = "oxygen", amount = 10 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.2 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.2 },
    },
	results = {
		{ type = "item", name = "black-body-naquadria-supersolid", amount = 1, probability = 0.625 },
		{ type = "item", name = "inert-naquadriah-dust", amount = 1, probability = 0.344 },
		{ type = "item", name = "barium", amount = 64, probability = 0.344 },
		{ type = "item", name = "indium", amount = 64, probability = 0.344 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
	},
	main_product = "black-body-naquadria-supersolid"
}
create_recipe{
	recipe_name = "black-body-naquadria-supersolid",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UMV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "naquadriah-oxide-mixture", amount = 32 },
		{ type = "item", name = "magnesium", amount = 64 },
		{ type = "fluid", name = "phosphoric-acid", amount = 1600 },
		{ type = "fluid", name = "sulfuric-acid", amount = 1600 },
		{ type = "fluid", name = "oxygen", amount = 10 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "black-body-naquadria-supersolid", amount = 1, probability = 0.813 },
		{ type = "item", name = "inert-naquadriah-dust", amount = 1, probability = 0.375 },
		{ type = "item", name = "barium", amount = 64, probability = 0.375 },
		{ type = "item", name = "indium", amount = 64, probability = 0.375 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
	},
	main_product = "black-body-naquadria-supersolid"
}
create_recipe{
	recipe_name = "inert-naquadriah-dust-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UMV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "naquadriah-oxide-mixture", amount = 32 },
		{ type = "item", name = "magnesium", amount = 64 },
		{ type = "fluid", name = "phosphoric-acid", amount = 1600 },
		{ type = "fluid", name = "sulfuric-acid", amount = 1600 },
		{ type = "fluid", name = "oxygen", amount = 10 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "inert-naquadriah-dust", amount = 1, probability = 0.813 },
		{ type = "item", name = "black-body-naquadria-supersolid", amount = 1, probability = 0.375 },
		{ type = "item", name = "barium", amount = 64, probability = 0.375 },
		{ type = "item", name = "indium", amount = 64, probability = 0.375 },
		{ type = "item", name = "advanced-naquadah-catalyst", amount = 1 },
	},
	main_product = "inert-naquadriah-dust"
}



---QFT PARTICLES
create_recipe{
	recipe_name = "particles-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UEV_SPEED * 5,
	ingredients = {
		{ type = "fluid", name = "hydrogen", amount = 1000 },
		{ type = "fluid", name = "deuterium", amount = 100 },
		{ type = "item", name = "particle-acceleration-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "graviton", amount = 1, probability = 0.4 },
		{ type = "item", name = "unknown-particle", amount = 1, probability = 0.4 },
		{ type = "item", name = "proton", amount = 1, probability = 0.4 },
		{ type = "item", name = "electron", amount = 1, probability = 0.4 },
		{ type = "fluid", name = "hydrogen-plasma", amount = 100, probability = 0.4 },
		{ type = "item", name = "particle-acceleration-catalyst", amount = 1 },
	},
	main_product = "graviton"
}



---QFT STEMCELLS
create_recipe{
	recipe_name = "stemcells-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UEV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "calcium", amount = 32 },
		{ type = "item", name = "mince-meat", amount = 32 },
		{ type = "item", name = "agar", amount = 32 },
		{ type = "item", name = "raw-intelligence-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "stemcells", amount = 2048, probability = 0.834 },
		{ type = "fluid", name = "raw-growth-catalyst-medium", amount = 102400, probability = 0.388},
		{ type = "fluid", name = "growth-catalyst-medium", amount = 51200, probability = 0.388 },
		{ type = "item", name = "raw-intelligence-catalyst", amount = 1 },
	},
	main_product = "stemcells"
}



---QFT BIOCELLS
create_recipe{
	recipe_name = "biocells-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "stemcells", amount = 16 },
		{ type = "item", name = "infinity-catalyst-dust", amount = 4 },
		{ type = "item", name = "biological-intelligence-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "biocells", amount = 2048, probability = 0.625 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1843.2, probability = 0.344 },
		{ type = "fluid", name = "sterilized-biocatalyst-medium", amount = 25600, probability = 0.344 },
		{ type = "fluid", name = "raw-biocatalyst-medium", amount = 51200, probability = 0.344 },
		{ type = "item", name = "biological-intelligence-catalyst", amount = 1 },
	},
	main_product = "biocells"
}



---QFT MUTATED LIVING SOLDER
create_recipe{
	recipe_name = "mutated-living-solder-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "stemcells", amount = 16 },
		{ type = "item", name = "infinity-catalyst-dust", amount = 4 },
		{ type = "item", name = "biological-intelligence-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "fluid", name = "mutated-living-solder", amount = 1843.2, probability = 0.625 },
		{ type = "item", name = "biocells", amount = 2048, probability = 0.344 },
		{ type = "fluid", name = "sterilized-biocatalyst-medium", amount = 25600, probability = 0.344 },
		{ type = "fluid", name = "raw-biocatalyst-medium", amount = 51200, probability = 0.344 },
		{ type = "item", name = "biological-intelligence-catalyst", amount = 1 },
	},
	main_product = "mutated-living-solder"
}



---QFT TAU CETI E SEAWEED
create_recipe{
	recipe_name = "tau-ceti-e-seaweed-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "seaweed", amount = 64 },
		{ type = "item", name = "mytryl-dust", amount = 16 },
		{ type = "item", name = "algagenic-growth-promoter-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "item", name = "tau-ceti-e-seaweed", amount = 2048, probability = 0.625 },
		{ type = "fluid", name = "tau-ceti-e-seaweed-extract", amount = 16, probability = 0.344 },
		{ type = "fluid", name = "seaweed-broth", amount = 5000, probability = 0.344 },
		{ type = "fluid", name = "iodine", amount = 6400, probability = 0.344 },
		{ type = "item", name = "algagenic-growth-promoter-catalyst", amount = 1 },
	},
	main_product = "tau-ceti-e-seaweed"
}



---QFT PLASTICIZER
create_recipe{
	recipe_name = "ultimate-plasticizer-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "carbon", amount = 64 },
		{ type = "item", name = "osmium-dust", amount = 24 },
		{ type = "fluid", name = "hydrogen", amount = 1600 },
		{ type = "fluid", name = "nitrogen", amount = 1600 },
		{ type = "item", name = "ultimate-plasticizer-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
    },
	results = {
		{ type = "fluid", name = "xenoxene", amount = 1600, probability = 0.438 },
		{ type = "fluid", name = "molten-radox-polymer", amount = 921.6, probability = 0.438 },
		{ type = "fluid", name = "heavy-radox", amount = 1600, probability = 0.438 },
		{ type = "fluid", name = "molten-kevlar", amount = 921.6, probability = 0.438 },
		{ type = "item", name = "ultimate-plasticizer-catalyst", amount = 1 },
	},
	main_product = "xenoxene"
}



---QFT PLASTICIZER
create_recipe{
	recipe_name = "ultimate-plasticizer-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
--		{ type = "item", name = "kevlar-comb", amount = 24 },
		{ type = "item", name = "carbon", amount = 64 },
		{ type = "fluid", name = "hydrogen", amount = 1600 },
		{ type = "fluid", name = "nitrogen", amount = 1600 },
		{ type = "item", name = "ultimate-plasticizer-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },    },
	results = {
		{ type = "fluid", name = "polyurethane-resin", amount = 3200, probability = 0.5 },
		{ type = "fluid", name = "liquid-crystal-kevlar", amount = 460.8, probability = 0.5 },
		{ type = "fluid", name = "molten-kevlar", amount = 921.6, probability = 0.5 },
		{ type = "item", name = "ultimate-plasticizer-catalyst", amount = 1 },
	},
	main_product = "liquid-crystal-kevlar"
}



---QFT QUANTUM PARTICLES
create_recipe{
	recipe_name = "quantum-particles-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UIV_SPEED * 200,
	ingredients = {
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "fluid", name = "hydrogen-plasma", amount = 3000 },
		{ type = "fluid", name = "helium-plasma", amount = 3000 },
		{ type = "fluid", name = "americium-plasma", amount = 3000 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 3000 },
		{ type = "item", name = "synchrotron-capable-catalyst", amount = 1 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
	},
	results = {
		{ type = "item", name = "z-boson", amount = 1, probability = 0.4 },
		{ type = "item", name = "w-boson", amount = 1, probability = 0.4 },
		{ type = "item", name = "lambda", amount = 1, probability = 0.4 },
		{ type = "item", name = "omega", amount = 1, probability = 0.4 },
		{ type = "item", name = "higgs-boson", amount = 1, probability = 0.4 },
		{ type = "item", name = "synchrotron-capable-catalyst", amount = 1 },
	},
	main_product = "higgs-boson"
}



---QFT TEMPORAL HARMONIZER (THE ETERNITY LOOP)
create_recipe{
	recipe_name = "primordial-matter-qtf",
	category = "t4-quantum-force-transformer-recipes",
	energy_required = UMV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "chronic-singularity", amount = 1 },
		{ type = "item", name = "energized-tesseract", amount = 1 },
		{ type = "fluid", name = "liquid-primordial-matter", amount = 115.2 },
		{ type = "item", name = "temporal-harmonizer-catalyst", amount = 1 },
		{ type = "fluid", name = "neptunium-plasma", amount = 1.6 },
		{ type = "fluid", name = "fermium-plasma", amount = 1.6 },
	},
	results = {
		{ type = "fluid", name = "molten-eternity", amount = 921.6, probability = 0.625 },
		{ type = "item", name = "timepiece", amount = 1, probability = 0.344 },
		{ type = "fluid", name = "molten-shirabon", amount = 921.6, probability = 0.344 },
		{ type = "fluid", name = "tachyon-rich-temporal-fluid", amount = 1843.2, probability = 0.344 },
		{ type = "item", name = "temporal-harmonizer-catalyst", amount = 1 },
	},
	main_product = "molten-eternity"
}



---TIMEPIECE (I think better to get through Eternity Loop)
create_item{
	recipe_name = "timepiece",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 80,
	ingredients = {
		{ type = "item", name = "spacetime-bending-core", amount = 1 },
		{ type = "item", name = "dense-deep-dark-plate", amount = 1 },
		{ type = "item", name = "dilithium", amount = 32 },
		{ type = "item", name = "universium-nanites", amount = 1 },
		{ type = "fluid", name = "tachyon-rich-temporal-fluid", amount = 14745.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 10000 },
	},
	results = {
		{ type = "item", name = "spacetime-bending-core", amount = 1 },
		{ type = "item", name = "timepiece", amount = 3 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 20000 },
		{ type = "fluid", name = "spatially-enlarged-fluid", amount = 14745.6 },
	},
	main_product = "timepiece"
}



---CHRONIC SINGULARIY (First recipe is extremely inefficient, only use to get the Eternity loop kickstarted)
create_item{
	name = "chronic-singularity",
	category = "uxv-macerator-recipes",
	energy_required = UXV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "eternal-singularity", amount = 8 },
		{ type = "item", name = "timepiece", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 28.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 10000 },
	},
	results = {
		{ type = "item", name = "chronic-singularity", amount = 1 },
		{ type = "fluid", name = "hydrogen-plasma", amount = 57.6 },
		{ type = "fluid", name = "helium-plasma", amount = 57.6 },
	},
	main_product = "chronic-singularity"
}
create_recipe{
	recipe_name = "chronic-singularity-second",
	category = "uxv-arc-furnace-recipes",
	energy_required = UXV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "eternal-singularity", amount = 1 },
		{ type = "fluid", name = "molten-eternity", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "chronic-singularity", amount = 1 },
		{ type = "fluid", name = "molten-infinity", amount = 57.6 },
	},
	main_product = "chronic-singularity"
}













---------------------------------------------------
---   DIMENSIONALLY TRANSCENDENT PLASMA FORGE   ---
---------------------------------------------------

---DIMENSIONALLY TRANSCENDENT PLASMA FORGE CONTROLLER
create_item{
	name = "dimensionally-transcendent-plasma-forge-controller",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "dimensional-bridge", amount = 4 },
		{ type = "item", name = "mega-blast-furnace-controller", amount = 16 },
		{ type = "item", name = "dracofinium-superconductive-wire-16x", amount = 6 },
		{ type = "item", name = "uev-energy-hatch", amount = 4 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 4 },
		{ type = "item", name = "optical-mainframe", amount = 20 },
		{ type = "item", name = "uev-field-generator", amount = 4 },
		{ type = "item", name = "eternal-singularity", amount = 4 },
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "item", name = "superdense-osmiridium-plate", amount = 4 },
		{ type = "item", name = "uev-pump", amount = 4 },
		{ type = "item", name = "really-ultimate-battery", amount = 1 },
		{ type = "item", name = "teleporter", amount = 1 },
		{ type = "fluid", name = "oganesson", amount = 12800 },
		{ type = "fluid", name = "mutated-living-solder", amount = 7372.8 },
		{ type = "fluid", name = "molten-californium", amount = 3686.4 },
		{ type = "fluid", name = "molten-enriched-naquadah", amount = 3686.4 },
	}
}



---DIMENSIONALLY TRANSCENDENT PLASMA FORGE
create_item{
	name = "uiv-dimensionally-transcendent-plasma-forge",
	ingredients = {
		{ type = "item", name = "dimensionally-transcendent-plasma-forge-controller", amount = 1 },
		{ type = "item", name = "dimensionally-transcendent-casing", amount = 2121 },
		{ type = "item", name = "dimensionally-injection-casing", amount = 1266 },
		{ type = "item", name = "awakened-draconium-coil-block", amount = 2112 },
		{ type = "item", name = "dimensional-bridge", amount = 120 },
		{ type = "item", name = "uiv-laser-target-hatch-16384a", amount = 1 },
		{ type = "item", name = "uv-machine-casing", amount = 6 },
	}
}



---DIMENSIONALLY TRANSCENDENT CASING
create_item{
	name = "dimensionally-transcendent-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "osmiridium-plate", amount = 6 },
		{ type = "item", name = "laurenium-screw", amount = 12 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 1 },
		{ type = "item", name = "uv-microwave-energy-transmitter", amount = 1 },
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 1 },
		{ type = "fluid", name = "oganesson", amount = 50 },
		{ type = "fluid", name = "mutated-living-solder", amount = 28.8 },
		{ type = "fluid", name = "molten-enriched-naquadah", amount = 14.4 },
	}
}



---DIMENSIONAL INJECTION CASING
create_item{
	name = "dimensionally-injection-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 20,
	ingredients = {
		{ type = "item", name = "osmiridium-plate", amount = 4 },
		{ type = "item", name = "ledox-plate", amount = 9 },
		{ type = "item", name = "callisto-ice-plate", amount = 9 },
		{ type = "item", name = "laurenium-screw", amount = 12 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 1 },
		{ type = "item", name = "super-chest-v", amount = 1 },
		{ type = "item", name = "super-tank-v", amount = 1 },
		{ type = "item", name = "uhv-superconductor-wire", amount = 2 },
		{ type = "item", name = "pico-wafer", amount = 1 },
		{ type = "fluid", name = "oganesson", amount = 1000 },
		{ type = "fluid", name = "mutated-living-solder", amount = 57.6 },
		{ type = "fluid", name = "molten-enriched-naquadah", amount = 28.8 },
	}
}



---DIMENSIONAL BRIDGE
create_item{
	name = "dimensional-bridge",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 240,
	ingredients = {
		{ type = "item", name = "dimensionally-transcendent-casing", amount = 1 },
		{ type = "item", name = "uv-microwave-energy-transmitter", amount = 1 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "pico-wafer", amount = 2 },
		{ type = "item", name = "uhv-superconductor-wire", amount = 6 },
		{ type = "item", name = "uhv-field-generator", amount = 1 },
		{ type = "item", name = "iron-singularity", amount = 2 },
		{ type = "fluid", name = "oganesson", amount = 800 },
		{ type = "fluid", name = "mutated-living-solder", amount = 921.6 },
		{ type = "fluid", name = "molten-enriched-naquadah", amount = 129.6 },
	}
}



---MEGA BLAST FURNACE CONTROLLER (NF)
create_item{
	name = "mega-blast-furnace-controller",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 3600,
	ingredients = {
		{ type = "item", name = "electric-blast-furnace-controller", amount = 64 },
		{ type = "fluid", name = "soldering-alloy", amount = 921.6 },
	}
}


---UV MICROWAVE ENERGY TRANSMITTER
create_item{
	name = "uv-microwave-energy-transmitter",
	ingredients = {
		{ type = "item", name = "uv-emitter", amount = 4 },
		{ type = "item", name = "uv-field-generator", amount = 1 },
		{ type = "item", name = "uv-machine-hull", amount = 1 },
		{ type = "item", name = "uv-circuit", amount = 2 },
		{ type = "item", name = "energy-module", amount = 1 },
	}
}



---TRANSDIMENSIONAL ALIGNMENT MATRIX
create_item{
	name = "transdimensional-alignment-matrix",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "infinite-spacetime-energy-boundary-casing", amount = 1 },
		{ type = "item", name = "spacetime-continuum-ripper", amount = 4 },
		{ type = "item", name = "umv-robot-arm", amount = 64 },
		{ type = "item", name = "umv-sensor", amount = 16 },
		{ type = "item", name = "umv-field-generator", amount = 4 },
		{ type = "item", name = "insanely-ultimate-battery", amount = 1 },
		{ type = "item", name = "energized-tesseract", amount = 32 },
		{ type = "item", name = "transcendent-metal-nanites", amount = 16 },
		{ type = "item", name = "dense-flerovium-plate", amount = 64 },
		{ type = "item", name = "dense-metastable-oganesson-plate", amount = 32 },
		{ type = "fluid", name = "spacially-enlarged-fluid", amount = 921.6 },
		{ type = "fluid", name = "lead-plasma", amount = 921.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 14745.6 },
	}
}



---INFINITE SPACETIME ENERGY BOUNDARY CASING
create_item{
	name = "infinite-spacetime-energy-boundary-casing",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 500,
	ingredients = {
		{ type = "item", name = "lapotronic-supercapacitor-controller", amount = 1 },
		{ type = "item", name = "photonic-solar-panel", amount = 1 },
		{ type = "item", name = "ultimate-capacitor-uhv", amount = 1 },
		{ type = "item", name = "hypocosmium-superconductive-wire", amount = 4 },
		{ type = "item", name = "active-transformer-controller", amount = 16 },
		{ type = "item", name = "umv-wireless-energy-hatch", amount = 4 },
		{ type = "item", name = "high-energy-flow-circuit", amount = 64 },
		{ type = "item", name = "metastable-oganesson-plate", amount = 6 },
		{ type = "item", name = "metastable-oganesson-screw", amount = 6 },
		{ type = "item", name = "blue-topaz-plate", amount = 6 },
		{ type = "item", name = "blue-topaz-screw", amount = 6 },
		{ type = "item", name = "callisto-ice-plate", amount = 6 },
		{ type = "item", name = "callisto-ice-screw", amount = 6 },
		{ type = "item", name = "ledox-plate", amount = 6 },
		{ type = "item", name = "ledox-screw", amount = 6 },
		{ type = "fluid", name = "molten-neutronium", amount = 58982.4 },
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 58982.4 },
		{ type = "fluid", name = "molten-spacetime", amount = 1600 },
		{ type = "fluid", name = "mutated-living-solder", amount = 29491.2 },
	}
}









------------------------
---   DTPF RECIPES   ---
------------------------

---QUANTUM ANOMALY
create_recipe{
	recipe_name = "quantum-anomaly-dtpf",
	category = "adc-dtpf-recipes",
	energy_required = UEV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "unknown-particle", amount = 1 },
		{ type = "item", name = "chromatic-glass-lens", amount = 1 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 9.2 },
		{ type = "fluid", name = "molten-duranium", amount = 14.4 },
    },
	results = {
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "item", name = "chromatic-glass-lens", amount = 1 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 4.6 },
	},
	main_product = "quantum-anomaly"
}
create_recipe{
	recipe_name = "quantum-anomaly-duplication",
	category = "ec-dtpf-recipes",
	energy_required = UIV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "item", name = "quite-certain-crystal-lens", amount = 1 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 1 },
		{ type = "item", name = "graviton", amount = 4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 9.2 },
		{ type = "fluid", name = "molten-tritanium", amount = 14.4 },
    },
	results = {
		{ type = "item", name = "quantum-anomaly", amount = 4 },
		{ type = "item", name = "quite-certain-crystal-lens", amount = 1 },
		{ type = "item", name = "hi-computation-station-mk5-finaltype", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 9.2 },
	},
	main_product = "quantum-anomaly"
}



---DIMENSIONALLY SHIFTED SUPERFLUID
create_recipe{
	recipe_name = "dimensionally-shifted-superfluid-prosaic",
	category = "adc-dtpf-recipes",
	energy_required = UIV_SPEED * 30,
	ingredients = {
		{ type = "fluid", name = "stabilised-baryonic-matter", amount = 25 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 14.4 },
		{ type = "fluid", name = "grade-8-water", amount = 40 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 345.6 },
		{ type = "fluid", name = "super-heavy-radox", amount = 200 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 100 },
    },
	results = {
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 750 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 25 },
	},
	main_product = "dimensionally-shifted-superfluid"
}
create_recipe{
	recipe_name = "dimensionally-shifted-superfluid-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = UMV_SPEED * 30,
	ingredients = {
		{ type = "fluid", name = "stabilised-baryonic-matter", amount = 100 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 14.4 },
		{ type = "fluid", name = "grade-8-water", amount = 160 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 345.6 },
		{ type = "fluid", name = "super-heavy-radox", amount = 200 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 200 },
    },
	results = {
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 3000 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	main_product = "dimensionally-shifted-superfluid"
}
create_recipe{
	recipe_name = "dimensionally-shifted-superfluid-exotic",
	category = "ec-dtpf-recipes",
	energy_required = UMV_SPEED * 30,
	ingredients = {
		{ type = "fluid", name = "stabilised-baryonic-matter", amount = 200 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 28.8 },
		{ type = "fluid", name = "grade-8-water", amount = 320 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 691.2 },
		{ type = "fluid", name = "super-heavy-radox", amount = 400 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 200 },
    },
	results = {
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 9000 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 200 },
	},
	main_product = "dimensionally-shifted-superfluid"
}
create_recipe{
	recipe_name = "dimensionally-shifted-superfluid-stellar",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 7.5,
	ingredients = {
		{ type = "fluid", name = "stabilised-baryonic-matter", amount = 800 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 57.6 },
		{ type = "fluid", name = "grade-8-water", amount = 1280 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 1382.5 },
		{ type = "fluid", name = "super-heavy-radox", amount = 3200 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 200 },
    },
	results = {
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 36000 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 400 },
	},
	main_product = "dimensionally-shifted-superfluid"
}




