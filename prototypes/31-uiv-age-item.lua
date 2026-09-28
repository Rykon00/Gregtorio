--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

local ICON_PATH = "__Gregtorio__/graphics/icons/"



-------------------------
---   RAW TESSERACT   ---
-------------------------

create_item{
	name = "raw-tesseract",
	category = "uiv-dtpf-recipes",
	energy_required = UIV_SPEED * 40,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-rod", amount = 8 },
		{ type = "item", name = "octiron-rod", amount = 8 },
		{ type = "item", name = "tairitsu-rod", amount = 8 },
		{ type = "item", name = "sunnarium-rod", amount = 8 },
		{ type = "item", name = "abyssal-alloy-plate", amount = 24 },
		{ type = "item", name = "botmium-screw", amount = 16 },
		{ type = "item", name = "zpm-circuit", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 100 },
    },
	results = {
		{ type = "item", name = "raw-tesseract", amount = 4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 50 },
	},
	main_product = "raw-tesseract"
}
create_recipe{
	recipe_name = "raw-tesseract-second",
	category = "umv-dtpf-recipes",
	energy_required = UMV_SPEED * 40,
	ingredients = {
		{ type = "item", name = "cosmic-neutronium-rod", amount = 12 },
		{ type = "item", name = "tairitsu-rod", amount = 12 },
		{ type = "item", name = "transcendent-metal-rod", amount = 8 },
		{ type = "item", name = "botmium-plate", amount = 24 },
		{ type = "item", name = "arcanite-screw", amount = 16 },
		{ type = "item", name = "ender-quantum-component", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 100 },
    },
	results = {
		{ type = "item", name = "raw-tesseract", amount = 8 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	main_product = "raw-tesseract"
}
create_recipe{
	recipe_name = "raw-tesseract-third",
	category = "uxv-dtpf-recipes",
	energy_required = UXV_SPEED * 40,
	ingredients = {
		{ type = "item", name = "transcendent-metal-rod", amount = 32 },
		{ type = "item", name = "black-titanium-plate", amount = 24 },
		{ type = "item", name = "zeron-100-screw", amount = 16 },
		{ type = "item", name = "quantum-anomaly", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 100 },
    },
	results = {
		{ type = "item", name = "raw-tesseract", amount = 16 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	main_product = "raw-tesseract"
}










------------------------------
---   TRANSCENDENT METAL   ---
------------------------------

---TRANSCENDENT METAL DUST
create_item{
	name = "transcendent-metal-dust",
	category = "uiv-macerator-recipes",
	energy_required = UIV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "raw-tesseract", amount = 1 },
	},
	results = {
		{ type = "item", name = "transcendent-metal-dust", amount = 8 },
	}
}



---HOT TRANSCENDENT METAL INGOT
create_item{
	name = "hot-transcendent-metal-ingot",
	category = "uiv-electric-blast-furnace-recipes",
	energy_required = UIV_SPEED * 180,
	ingredients = {
		{ type = "item", name = "transcendent-metal-dust", amount = 1 },
		{ type = "fluid", name = "molten-tungsten", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "hot-transcendent-metal-ingot", amount = 1 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 7.2 },
	},
	main_product = "hot-transcendent-metal-ingot"
}



---TRANSCENDENT METAL INGOT
create_item{
	name = "transcendent-metal-ingot",
	category = "uiv-vacuum-freezer-recipes",
	energy_required = UIV_SPEED,
	ingredients = {
		{ type = "item", name = "hot-transcendent-metal-ingot", amount = 1 },
		{ type = "fluid", name = "molten-titansteel", amount = 14.4 },
		{ type = "fluid", name = "super-coolant", amount = 100 },
	}
}



---TRANSCENDENT METAL BLOCK
create_recipe{
	recipe_name = "transcendent-metal-block-dtpf",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 22.5,
	ingredients = {
		{ type = "item", name = "raw-tesseract", amount = 32 },
		{ type = "item", name = "cosmic-neutronium-block", amount = 40 },
		{ type = "fluid", name = "molten-titansteel", amount = 5184 },
		{ type = "fluid", name = "molten-tungsten", amount = 5184 },
		{ type = "fluid", name = "molten-ledox", amount = 2592 },
		{ type = "fluid", name = "molten-callisto-ice", amount = 2592 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 754.8 },
		{ type = "fluid", name = "super-coolant", amount = 100 },
	},
	results = {
		{ type = "item", name = "transcendent-metal-block", amount = 40 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2592 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1509.6 },
	},
	main_product = "transcendent-metal-block"
}






---------------------------------
---   PROTO-HALKONITE STEEL   ---
---------------------------------

---PROTO-HALKONITE STEEL BASE
create_recipe{
	name = "molten-proto-halkonite-steel-base",
	category = "uev-alloy-blast-furnace-recipes",
	energy_required = UEV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "transcendent-metal-dust", amount = 2 },
		{ type = "item", name = "tairitsu-dust", amount = 2 },
		{ type = "item", name = "tartarite-dust", amount = 2 },
		{ type = "item", name = "titansteel-dust", amount = 1 },
		{ type = "item", name = "infinity-dust", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 115.2 },
	}
}
create_item{
	name = "fine-proto-halkonite-steel-wire-infinity",
	category = "uev-chemical-bath-recipes",
	energy_required = UEV_SPEED * 8,
	ingredients = {
		{ type = "item", name = "fine-infinity-wire", amount = 8 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "fine-proto-halkonite-steel-wire", amount = 8 },
	}
}
create_item{
	name = "fine-proto-halkonite-steel-wire-creon",
	category = "uiv-chemical-bath-recipes",
	energy_required = UEV_SPEED * 2,
	ingredients = {
		{ type = "item", name = "fine-creon-wire", amount = 8 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "fine-proto-halkonite-steel-wire", amount = 8 },
	}
}
create_item{
	name = "fine-proto-halkonite-steel-wire-mellion",
	category = "uiv-chemical-bath-recipes",
	energy_required = UIV_SPEED * 2,
	ingredients = {
		{ type = "item", name = "fine-mellion-wire", amount = 8 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 7.2 },
	},
	results = {
		{ type = "item", name = "fine-proto-halkonite-steel-wire", amount = 8 },
	}
}










--------------------------
---   UIV COMPONENTS   ---
--------------------------

---NETHER STAR ROD
create_item{
	name = "nether-star-rod",
	category = "lv-lathe-recipes",
	energy_required = NETHER_STAR_SPEED * 2,
	ingredients = {
		{ type = "item", name = "nether-star", amount = 1 },
	},
	results = {
		{ type = "item", name = "nether-star-rod", amount = 2 },
	}
}



---NETHER STAR WIRE
create_item{
	name = "nether-star-wire",
	category = "lv-wiremill-recipes",
	energy_required = NETHER_STAR_SPEED * 1.5,
	ingredients = {
		{ type = "item", name = "nether-star-rod", amount = 1 },
	},
	results = {
		{ type = "item", name = "nether-star-wire", amount = 1 },
	}
}



---NETHER STAR CABLE
create_item{
	name = "nether-star-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "nether-star-wire", amount = 4 },
		{ type = "item", name = "polydimetylsiloxane", amount = 1 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 4 },
		{ type = "fluid", name = "silicone-rubber", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "nether-star-cable", amount = 4 },
	}
}
create_item{
	name = "nether-star-cable",
	category = "lv-assembling-machine-recipes",
	energy_required = 20,
	ingredients = {
		{ type = "item", name = "nether-star-wire-16x", amount = 4 },
		{ type = "item", name = "polydimetylsiloxane", amount = 5 },
		{ type = "item", name = "thin-polyphenylene-sulfide-sheet", amount = 20 },
		{ type = "fluid", name = "silicone-rubber", amount = 72 },
	},
	results = {
		{ type = "item", name = "nether-star-cable-16x", amount = 4 },
	}
}



---UIV MOTOR
create_item{
	name = "uiv-motor",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "long-attuned-tengam-rod", amount = 16 },
		{ type = "item", name = "long-transcendent-metal-rod", amount = 16 },
		{ type = "item", name = "transcendent-metal-ring", amount = 8 },
		{ type = "item", name = "transcendent-metal-round", amount = 32 },
		{ type = "item", name = "fine-proto-halkonite-steel-wire", amount = 512 },
		{ type = "item", name = "nether-star-cable", amount = 8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-motor-coal-infinity",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "nether-star-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 30259.2 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 44236.8 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14899.2 },
		{ type = "fluid", name = "molten-purified-tengam", amount = 11059.2 },
		{ type = "fluid", name = "molten-infinity", amount = 44236.8 },
	},
	results = {
		{ type = "item", name = "uiv-motor", amount = 64 },
	}
}
create_recipe{
	name = "uiv-motor-coal-creon-mellion",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "nether-star-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 30259.2 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 22118.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14899.2 },
		{ type = "fluid", name = "molten-purified-tengam", amount = 11059.2 },
		{ type = "fluid", name = "molten-creon", amount = 22118.4 },
		{ type = "fluid", name = "molten-mellion", amount = 22118.4 },
	},
	results = {
		{ type = "item", name = "uiv-motor", amount = 64 },
	}
}



---UIV PISTON
create_item{
	name = "uiv-piston",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "item", name = "transcendent-metal-plate", amount = 6 },
		{ type = "item", name = "transcendent-metal-ring", amount = 8 },
		{ type = "item", name = "transcendent-metal-round", amount = 64 },
		{ type = "item", name = "transcendent-metal-rod", amount = 8 },
		{ type = "item", name = "large-transcendent-metal-gear", amount = 2 },
		{ type = "item", name = "transcendent-metal-gear", amount = 4 },
		{ type = "item", name = "nether-star-cable", amount = 16 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-piston-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 48 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 32 },
		{ type = "item", name = "nether-star-cable-16x", amount = 48 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 17356.8 },
	},
	results = {
		{ type = "item", name = "uiv-piston", amount = 64 },
	}
}



---UIV PUMP
create_item{
	name = "uiv-pump",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "item", name = "awakened-draconium-plate", amount = 12 },
		{ type = "item", name = "transcendent-metal-plate", amount = 4 },
		{ type = "item", name = "transcendent-metal-screw", amount = 16 },
		{ type = "item", name = "silicone-rubber-ring", amount = 64 },
		{ type = "item", name = "transcendent-metal-rotor", amount = 4 },
		{ type = "item", name = "nether-star-cable", amount = 8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-pump-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 48 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 21 },
		{ type = "item", name = "nether-star-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 12979.2 },
		{ type = "fluid", name = "molten-awakened-draconium", amount = 8294.4 },
		{ type = "fluid", name = "molten-silicone-rubber", amount = 11059.2 },
	},
	results = {
		{ type = "item", name = "uiv-pump", amount = 64 },
	}
}



---UIV CONVEYOR MODULE
create_item{
	name = "uiv-conveyor-module",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 2 },
		{ type = "item", name = "transcendent-metal-plate", amount = 2 },
		{ type = "item", name = "transcendent-metal-ring", amount = 8 },
		{ type = "item", name = "transcendent-metal-round", amount = 64 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
		{ type = "item", name = "nether-star-cable", amount = 8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-conveyor-module-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 96 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 10 },
		{ type = "item", name = "nether-star-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 6297.6 },
		{ type = "fluid", name = "molten-silicone-rubber", amount = 55209.6 },
	},
	results = {
		{ type = "item", name = "uiv-conveyor-module", amount = 64 },
	}
}



---UIV ROBOT ARM
create_item{
	name = "uiv-robot-arm",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 2 },
		{ type = "item", name = "uiv-piston", amount = 1 },
		{ type = "item", name = "long-transcendent-metal-rod", amount = 8 },
		{ type = "item", name = "large-transcendent-metal-gear", amount = 2 },
		{ type = "item", name = "transcendent-metal-gear", amount = 6 },
		{ type = "item", name = "optical-mainframe", amount = 2 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "uhv-circuit", amount = 8 },
		{ type = "item", name = "nether-star-cable", amount = 24 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-robot-arm-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 96 },
		{ type = "item", name = "uiv-piston", amount = 48 },
		{ type = "item", name = "optical-mainframe-wrap", amount = 6 },
		{ type = "item", name = "uev-circuit-wrap", amount = 12 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 24 },
		{ type = "item", name = "nether-star-cable-16x", amount = 72 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 15206.4 },
	},
	results = {
		{ type = "item", name = "uiv-robot-arm", amount = 64 },
	}
}



---UIV SENSOR
create_item{
	name = "uiv-sensor",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "transcendent-metal-frame", amount = 1 },
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "item", name = "transcendent-metal-plate", amount = 8 },
		{ type = "item", name = "gravi-star", amount = 32 },
		{ type = "item", name = "optical-mainframe", amount = 4 },
		{ type = "item", name = "arceus-alloy-2b-foil", amount = 64 },
		{ type = "item", name = "lafium-compound-foil", amount = 64 },
		{ type = "item", name = "cinobite-a243-foil", amount = 64 },
		{ type = "item", name = "pikyonium-64b-foil", amount = 64 },
		{ type = "item", name = "nether-star-cable", amount = 28 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-sensor-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 48 },
		{ type = "item", name = "optical-mainframe-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 96 },
		{ type = "item", name = "transcendent-metal-frame", amount = 48 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 42 },
		{ type = "item", name = "nether-star-cable-16x", amount = 84 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "molten-cenobite-a243", amount = 11059.2 },
		{ type = "fluid", name = "molten-pikyonium-64b", amount = 11059.2 },
		{ type = "fluid", name = "molten-lafium-compound", amount = 11059.2 },
		{ type = "fluid", name = "molten-arceus-alloy-2b", amount = 11059.2 },
	},
	results = {
		{ type = "item", name = "uiv-sensor", amount = 64 },
	}
}



---UIV EMITTER
create_item{
	name = "uiv-emitter",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "transcendent-metal-frame", amount = 1 },
		{ type = "item", name = "uiv-motor", amount = 1 },
		{ type = "item", name = "transcendent-metal-rod", amount = 16 },
		{ type = "item", name = "gravi-star", amount = 32 },
		{ type = "item", name = "optical-mainframe", amount = 4 },
		{ type = "item", name = "arceus-alloy-2b-foil", amount = 64 },
		{ type = "item", name = "lafium-compoun-foil", amount = 64 },
		{ type = "item", name = "cinobite-a243-foil", amount = 64 },
		{ type = "item", name = "pikyonium-64b-foil", amount = 64 },
		{ type = "item", name = "nether-star-cable", amount = 28 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	name = "uiv-emitter-coal",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uiv-motor", amount = 48 },
		{ type = "item", name = "optical-mainframe-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 96 },
		{ type = "item", name = "transcendent-metal-frame", amount = 48 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 42 },
		{ type = "item", name = "nether-star-cable-16x", amount = 84 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "molten-cenobite-a243", amount = 11059.2 },
		{ type = "fluid", name = "molten-pikyonium-64b", amount = 11059.2 },
		{ type = "fluid", name = "molten-lafium-compound", amount = 11059.2 },
		{ type = "fluid", name = "molten-arceus-alloy-2b", amount = 11059.2 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 5529.6 },
	},
	results = {
		{ type = "item", name = "uiv-emitter", amount = 64 },
	}
}



---UIV FIELD GENERATOR
create_item{
	name = "uiv-field-generator",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "transcendent-metal-frame", amount = 1 },
		{ type = "item", name = "uiv-emitter", amount = 4 },
		{ type = "item", name = "transcendent-metal-plate", amount = 6 },
		{ type = "item", name = "gravi-star", amount = 16 },
		{ type = "item", name = "pico-circuit", amount = 4 },
		{ type = "item", name = "fine-proto-halkonite-steel-wire", amount = 512 },
		{ type = "item", name = "nether-star-cable", amount = 32 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
	}
}
create_recipe{
	name = "uiv-field-generator-coal-infinity",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "nether-star-cable-16x", amount = 96 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 32 },
		{ type = "item", name = "transcendent-metal-frame", amount = 48 },
		{ type = "item", name = "uiv-emitter", amount = 192 },
		{ type = "item", name = "umv-circuit-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 48 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 30259.2 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 44236.8 },
		{ type = "fluid", name = "molten-infinity", amount = 44236.8 },
	},
	results = {
		{ type = "item", name = "uiv-field-generator", amount = 64 },
	}
}
create_recipe{
	name = "uiv-field-generator-coal-creon-mellion",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "nether-star-cable-16x", amount = 96 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 32 },
		{ type = "item", name = "transcendent-metal-frame", amount = 48 },
		{ type = "item", name = "uiv-emitter", amount = 192 },
		{ type = "item", name = "umv-circuit-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 48 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 30259.2 },
		{ type = "fluid", name = "molten-proto-halkonite-steel-base", amount = 22118.4 },
		{ type = "fluid", name = "molten-creon", amount = 22118.4 },
		{ type = "fluid", name = "molten-mellion", amount = 22118.4 },
	},
	results = {
		{ type = "item", name = "uiv-field-generator", amount = 64 },
	}
}



---UIV ENERGY HATCH
create_item{
	name = "uiv-energy-hatch",
	ingredients = {
		{ type = "item", name = "uiv-machine-hull", amount = 1 },
		{ type = "item", name = "uiv-superconductor-wire", amount = 8 },
		{ type = "item", name = "quantum-power-ic", amount = 8 },
		{ type = "item", name = "optical-mainframe", amount = 2 },
		{ type = "item", name = "highly-ultimate-voltage-coil", amount = 8 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 6 },
		{ type = "item", name = "uiv-pump", amount = 1 },
	}
}



---UIV LASER TARGET HATCH 16384A
create_item{
	name = "uiv-laser-target-hatch-16384a",
	ingredients = {
		{ type = "item", name = "uiv-machine-hull", amount = 1 },
		{ type = "item", name = "diamond-lens", amount = 8 },
		{ type = "item", name = "uiv-sensor", amount = 8 },
		{ type = "item", name = "uiv-pump", amount = 8 },
		{ type = "item", name = "nether-star-wire", amount = 32 },
	}
}



--HYPOGEN COIL BLOCK (UMV)
create_item{
	name = "hypogen-coil-block",
	category = "uiv-assembly-line-recipes",
	energy_required = 60 * UIV_SPEED,
	ingredients = {
		{ type = "item", name = "hypogen-wire", amount = 16 },
		{ type = "item", name = "hypogen-screw", amount = 8 },
		{ type = "item", name = "infinity-catalyst-foil", amount = 8 },
		{ type = "item", name = "uvh-circuit", amount = 1 },
		{ type = "fluid", name = "molten-infinity", amount = 57.6 }
	}
} 










-------------------------------------
---   TRANSCENDENT PLASMA MIXER   ---	Uses 1A of MAX (42,949,672,960 EU/sec)
-------------------------------------

create_item{
	name = "transcendent-plasma-mixer-controller",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "uev-laser-target-hatch", amount = 4 },
		{ type = "item", name = "optical-mainframe", amount = 32 },
		{ type = "item", name = "uev-pump", amount = 16 },
		{ type = "item", name = "proto-halkonite-steel-plate", amount = 64 },
		{ type = "item", name = "large-proto-halkonite-steel-gear", amount = 16 },
		{ type = "item", name = "proto-halkonite-steel-gear", amount = 64 },
		{ type = "item", name = "proto-halkonite-steel-screw", amount = 64 },
		{ type = "item", name = "energized-tesseract", amount = 32 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 204800 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 204800 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 204800 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 204800 },
	}
}
create_item{
	name = "transcendent-plasma-mixer",
	ingredients = {
		{ type = "item", name = "transcendent-plasma-mixer-controller", amount = 1 },
		{ type = "item", name = "dimensionally-transcendent-casing", amount = 48 },
		{ type = "item", name = "dimensional-bridge", amount = 16 },
		{ type = "item", name = "dimensional-injection-casing", amount = 33 },
		{ type = "item", name = "uv-machine-hull", amount = 4 },
	}
}
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-crude-catalyst-tpm",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 0.34,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 100 },
	}
}
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-prosaic-catalyst-tpm",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 1.56,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
		{ type = "fluid", name = "radon-plasma", amount = 100 },
		{ type = "fluid", name = "nickel-plasma", amount = 100 },
		{ type = "fluid", name = "boron-plasma", amount = 100 },
		{ type = "fluid", name = "sulfur-plasma", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 100 },
	}
}
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-resplendent-catalyst-tpm",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 6.25,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
		{ type = "fluid", name = "radon-plasma", amount = 100 },
		{ type = "fluid", name = "nickel-plasma", amount = 100 },
		{ type = "fluid", name = "boron-plasma", amount = 100 },
		{ type = "fluid", name = "sulfur-plasma", amount = 100 },
		{ type = "fluid", name = "nitrogen-plasma", amount = 100 },
		{ type = "fluid", name = "silver-plasma", amount = 100 },
		{ type = "fluid", name = "zinc-plasma", amount = 100 },
		{ type = "fluid", name = "titanium-plasma", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 100 },
	}
}
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-exotic-catalyst-tpm",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 25,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
		{ type = "fluid", name = "radon-plasma", amount = 100 },
		{ type = "fluid", name = "nickel-plasma", amount = 100 },
		{ type = "fluid", name = "boron-plasma", amount = 100 },
		{ type = "fluid", name = "sulfur-plasma", amount = 100 },
		{ type = "fluid", name = "nitrogen-plasma", amount = 100 },
		{ type = "fluid", name = "silver-plasma", amount = 100 },
		{ type = "fluid", name = "zinc-plasma", amount = 100 },
		{ type = "fluid", name = "titanium-plasma", amount = 100 },
		{ type = "fluid", name = "americium-plasma", amount = 100 },
		{ type = "fluid", name = "bismuth-plasma", amount = 100 },
		{ type = "fluid", name = "oxygen-plasma", amount = 100 },
		{ type = "fluid", name = "tin-plasma", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 100 },
	}
}
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-stellar-catalyst-tpm",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 100,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
		{ type = "fluid", name = "radon-plasma", amount = 100 },
		{ type = "fluid", name = "nickel-plasma", amount = 100 },
		{ type = "fluid", name = "boron-plasma", amount = 100 },
		{ type = "fluid", name = "sulfur-plasma", amount = 100 },
		{ type = "fluid", name = "nitrogen-plasma", amount = 100 },
		{ type = "fluid", name = "silver-plasma", amount = 100 },
		{ type = "fluid", name = "zinc-plasma", amount = 100 },
		{ type = "fluid", name = "titanium-plasma", amount = 100 },
		{ type = "fluid", name = "americium-plasma", amount = 100 },
		{ type = "fluid", name = "bismuth-plasma", amount = 100 },
		{ type = "fluid", name = "oxygen-plasma", amount = 100 },
		{ type = "fluid", name = "tin-plasma", amount = 100 },
		{ type = "fluid", name = "lead-plasma", amount = 100 },
		{ type = "fluid", name = "thorium-plasma", amount = 100 },
		{ type = "fluid", name = "naquadria-plasma", amount = 100 },
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 25 },
	},
	results = {
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 100 },
	}
}
create_recipe{
	recipe_name = "creon-plasma",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 2.94,
	ingredients = {
		{ type = "fluid", name = "fermium-plasma", amount = 100 },
		{ type = "fluid", name = "thorium-plasma", amount = 100 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "creon-plasma", amount = 500 },
	}
}
create_recipe{
	recipe_name = "liquid-primordial-matter",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 46.76,
	ingredients = {
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 100 },
		{ type = "fluid", name = "molten-spacetime", amount = 100 },
		{ type = "fluid", name = "spatially-enlarged-fluid", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "liquid-primordial-matter", amount = 100 },
	}
}
create_recipe{
	recipe_name = "stargate-crystal-slurry",
	category = "tpm-recipes",
	energy_required = MAX_SPEED * 2338.2,
	ingredients = {
		{ type = "fluid", name = "infinity-plasma", amount = 100 },
		{ type = "fluid", name = "neutronium-plasma", amount = 100 },
		{ type = "fluid", name = "flerovium-plasma", amount = 100 },
		{ type = "fluid", name = "chromatic-glass-plasma", amount = 100 },
		{ type = "fluid", name = "hypogen-plasma", amount = 100 },
		{ type = "fluid", name = "ichorium-plasma", amount = 100 },
		{ type = "fluid", name = "six-phased-copper-plasma", amount = 100 },
		{ type = "fluid", name = "awakened-draconium-plasma", amount = 100 },
		{ type = "fluid", name = "dragonblood-plasma", amount = 100 },
		{ type = "fluid", name = "rhugnor-plasma", amount = 100 },
		{ type = "fluid", name = "draconium-plasma", amount = 100 },
		{ type = "fluid", name = "creon-plasma", amount = 100 },
		{ type = "fluid", name = "tritanium-plasma", amount = 100 },
		{ type = "fluid", name = "cosmic-neutronium-plasma", amount = 100 },
		{ type = "fluid", name = "bedrockium-plasma", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-crude-catalyst", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-prosaic-catalyst", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-residue-catalyst", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-exotic-catalyst", amount = 100 },
		{ type = "fluid", name = "dimensionally-transcendent-stellar-catalyst", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "stargate-crystal-slurry", amount = 100 },
	}
}










----------------------------------------------------
---   PSUDOSTABLE BLACK HOLE CONTAINMENT FIELD   ---
----------------------------------------------------

create_item{
	name = "psudostable-black-hole-containment-field-controller",
	category = "uiv-assembly-line-recipes",
	energy_required = UMV_SPEED * 120,
	ingredients = {
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 29491.2 },
	}
}










--------------------
---   GODFORGE   ---
--------------------

create_item{
	name = "forge-of-the-gods-controller",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 4 },
		{ type = "item", name = "extremely-ultimate-battery", amount = 2 },
		{ type = "item", name = "dimensional-bridge", amount = 64 },
		{ type = "item", name = "eternal-singularity", amount = 32 },
		{ type = "item", name = "dense-mellion-plate", amount = 16 },
		{ type = "item", name = "dense-six-phased-copper-plate", amount = 16 },
		{ type = "item", name = "dense-creon-plate", amount = 16 },
		{ type = "item", name = "dense-metastable-oganesson-plate", amount = 16 },
		{ type = "item", name = "graviton", amount = 64 },
		{ type = "item", name = "chromnorox-superconductive-wire-16x", amount = 16 },
		{ type = "item", name = "uiv-sensor", amount = 32 },
		{ type = "item", name = "optical-mainframe", amount = 64 },
		{ type = "item", name = "uiv-laser-target-hatch-1048576a", amount = 1 },
		{ type = "item", name = "uiv-energy-distributer", amount = 1 },
		{ type = "fluid", name = "mutated-living-solder", amount = 29491.2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 819200 },
		{ type = "fluid", name = "thorium-plasma", amount = 3686.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 29491.2 },
	}
}
create_item{
	name = "t1-godforge",
	ingredients = {
		{ type = "item", name = "transcendentally-amplified-magnetic-confinement-casing", amount = 3947 },
		{ type = "item", name = "remote-graviton-flow-modulator", amount = 345 },
		{ type = "item", name = "singularity-reinforced-stellar-shielding-casing", amount = 2818 },
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 130 },
		{ type = "item", name = "celestial-matter-guidance-casing", amount = 272 },
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 36 },
		{ type = "item", name = "spatially-transcendent-gravitational-lens-block", amount = 9 },
		{ type = "item", name = "uv-machine-hull", amount = 3 },
	},
	results = {
		{ type = "item", name = "t1-godforge", amount = 1 },
	}
}
create_item{
	name = "transcendentally-amplified-magnetic-confinement-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "transcendent-metal-frame", amount = 8 },
		{ type = "item", name = "block-of-magneto-resonatic", amount = 16 },
		{ type = "item", name = "dense-attuned-tengam-plate", amount = 32 },
		{ type = "item", name = "creon-plate", amount = 16 },
		{ type = "item", name = "hypogen-screw", amount = 8 },
		{ type = "item", name = "six-phased-copper-screw", amount = 8 },
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 1 },
		{ type = "item", name = "uiv-emitter", amount = 2 },
		{ type = "item", name = "tengam-electromagnet", amount = 1 },
		{ type = "fluid", name = "mutated-living-solder", amount = 230.4 },
		{ type = "fluid", name = "plutonium-241-plasma", amount = 230.4 },
	},
	results = {
		{ type = "item", name = "transcendentally-amplified-magnetic-confinement-casing", amount = 8 },
	}
}
create_item{
	name = "remote-graviton-flow-modulator",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "transcendentally-amplified-magnetic-confinement-casing", amount = 2 },
		{ type = "item", name = "ultimate-field-restriction-coil", amount = 1 },
		{ type = "item", name = "creon-plate", amount = 16 },
		{ type = "item", name = "small-mellion-gear", amount = 8 },
		{ type = "item", name = "graviton-anomaly", amount = 2 },
		{ type = "item", name = "quantum-anomaly", amount = 4 },
		{ type = "item", name = "uiv-emitter", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 16 },
		{ type = "item", name = "silver-nanites", amount = 2 },
		{ type = "fluid", name = "mutated-living-solder", amount = 460.8 },
		{ type = "fluid", name = "molten-chromnorox", amount = 460.8 },
		{ type = "fluid", name = "molten-infinity", amount = 460.8 },
	},
	results = {
		{ type = "item", name = "remote-graviton-flow-modulator", amount = 2 },
	}
}
create_item{
	name = "singularity-reinforced-stellar-shielding-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 30,
	ingredients = {
		{ type = "item", name = "six-phased-copper-frame", amount = 4 },
		{ type = "item", name = "superdense-infinity-plate", amount = 2 },
		{ type = "item", name = "quantum-plate", amount = 16 },
		{ type = "item", name = "infinity-catalyst-frame", amount = 4 },
		{ type = "item", name = "superdense-black-plutonium-plate", amount = 2 },
		{ type = "item", name = "sphagettic-singularity", amount = 1 },
		{ type = "item", name = "long-chromnorox-rod", amount = 8 },
		{ type = "item", name = "creon-plate", amount = 16 },
		{ type = "item", name = "mellion-plate", amount = 16 },
		{ type = "item", name = "long-dracofinium-rod", amount = 8 },
		{ type = "item", name = "cryptic-singularity", amount = 1 },
		{ type = "item", name = "superdense-transcendent-metal-plate", amount = 2 },
		{ type = "item", name = "superdense-cosmic-neutronium-plate", amount = 2 },
		{ type = "item", name = "titansteel-frame", amount = 4 },
		{ type = "item", name = "abyssal-alloy-frame", amount = 4 },
		{ type = "item", name = "proto-halkonite-steel-plate", amount = 16 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1843.2 },
		{ type = "fluid", name = "molten-bedrockium", amount = 235929.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 29491.2 },
		{ type = "fluid", name = "molten-neutronium", amount = 29491.2 },
	},
	results = {
		{ type = "item", name = "singularity-reinforced-stellar-shielding-casing", amount = 4 },
	}
}
create_item{
	name = "boundless-gravitationally-severed-structure-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "mellion-frame", amount = 16 },
		{ type = "item", name = "six-phased-copper-frame", amount = 16 },
		{ type = "item", name = "transcendent-metal-frame", amount = 8 },
		{ type = "item", name = "astral-titanium-frame", amount = 8 },
		{ type = "item", name = "creon-plate", amount = 6 },
		{ type = "item", name = "graviton", amount = 8 },
		{ type = "item", name = "uev-field-generator", amount = 2 },
		{ type = "item", name = "artificial-gravity-generator", amount = 4 },
		{ type = "fluid", name = "mutated-living-solder", amount = 240.3 },
		{ type = "fluid", name = "lead-plasma", amount = 28.8 },
	},
	results = {
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 1 },
	}
}
create_item{
	name = "celestial-matter-guidance-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 1 },
		{ type = "item", name = "ultimate-battery", amount = 1 },
		{ type = "item", name = "cosmic-fabric-manipulator", amount = 1 },
		{ type = "item", name = "uev-field-generator", amount = 2 },
		{ type = "item", name = "uiv-emitter", amount = 3 },
		{ type = "item", name = "creon-plate", amount = 6 },
		{ type = "item", name = "large-creon-gear", amount = 8 },
		{ type = "item", name = "mellion-gear", amount = 8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 240.3 },
		{ type = "fluid", name = "thorium-plasma", amount = 28.8 },
	},
	results = {
		{ type = "item", name = "celestial-matter-guidance-casing", amount = 1 },
	}
}
create_item{
	name = "stellar-energy-syphon-casing",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 1 },
		{ type = "item", name = "hypogen-coil-block", amount = 128 },
		{ type = "item", name = "chromnorox-superconductive-wire-16x", amount = 16 },
		{ type = "item", name = "1g-neutronium-heat-capacitor", amount = 2 },
		{ type = "item", name = "1080k-super-coolant-cell", amount = 2 },
		{ type = "item", name = "uiv-laser-target-hatch-1048576a", amount = 1 },
		{ type = "item", name = "ultimate-pocket-sun", amount = 64 },
		{ type = "item", name = "dense-creon-plate", amount = 6 },
		{ type = "item", name = "hypogen-plate", amount = 6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 230.4 },
		{ type = "fluid", name = "molten-chromnorox", amount = 460.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 12800 },
	},
	results = {
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 1 },
	}
}
create_item{
	name = "spacially-transcendent-gravitational-lens-block",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "quantum-glass", amount = 8 },
		{ type = "item", name = "transcendentally-reinforced-borosilicate-glass-block", amount = 8 },
		{ type = "item", name = "force-field-glass", amount = 8 },
		{ type = "item", name = "graviton", amount = 32 },
		{ type = "item", name = "radox-polymer-lens", amount = 16 },
		{ type = "item", name = "chromatic-glass-lens", amount = 16 },
		{ type = "item", name = "quite-certain-crystal-lens", amount = 16 },
		{ type = "item", name = "magneto-resonatic-lens", amount = 16 },
		{ type = "item", name = "dense-chromatic-glass-plate", amount = 36 },
		{ type = "item", name = "long-creon-rod", amount = 6 },
		{ type = "item", name = "long-mellion-rod", amount = 6 },
		{ type = "item", name = "long-six-phased-copper-rod", amount = 6 },
		{ type = "fluid", name = "molten-rhugnor", amount = 230.4 },
		{ type = "fluid", name = "molten-creon", amount = 230.4 },
		{ type = "fluid", name = "molten-advanced-nitinol", amount = 14745.6 },
	},
	results = {
		{ type = "item", name = "spacially-transcendent-gravitational-lens-block", amount = 1 },
	}
}



---STAR FUEL
create_item{
	name = "star-fuel",
	category = "uiv-mixer-recipes",
	energy_required = UIV_SPEED * 3,
	ingredients = {
		{ type = "item", name = "block-of-neutronium", amount = 64 },
		{ type = "item", name = "block-of-cosmic-neutronium", amount = 64 },
		{ type = "item", name = "diamond-singularity", amount = 1 },
		{ type = "fluid", name = "naquadah-based-liquid-fuel-mkv", amount = 100 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 12800 },
    }
}



---HELIOFLARE POWER FORGE
create_item{
	name = "helioflare-power-forge-controller",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "singularity-reinforced-stellar-shielding-casing", amount = 4 },
		{ type = "item", name = "mega-blast-furnace", amount = 64 },
		{ type = "item", name = "multismelter-controller", amount = 64 },
		{ type = "item", name = "extremely-ultimate-battery", amount = 1 },
		{ type = "item", name = "chromnorox-superconductive-wire-16x", amount = 16 },
		{ type = "item", name = "uiv-robot-arm", amount = 16 },
		{ type = "item", name = "uiv-conveyor-module", amount = 32 },
		{ type = "item", name = "dense-six-phased-copper-plate", amount = 16 },
		{ type = "item", name = "dense-creon-plate", amount = 16 },
		{ type = "item", name = "dense-mellion-plate", amount = 16 },
		{ type = "fluid", name = "mutated-living-solder", amount = 14745.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 204800 },
		{ type = "fluid", name = "lead-plasma", amount = 3686.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14745.6 },
	}
}
create_item{
	name = "helioflare-power-forge",
	ingredients = {
		{ type = "item", name = "helioflare-power-forge-controller", amount = 1 },
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 20 },
		{ type = "item", name = "transcendentally-amplified-magnetic-confinement-casing", amount = 21 },
		{ type = "item", name = "singularity-reinforced-stellar-shielding-casing", amount = 16 },
		{ type = "item", name = "hypogen-coil-block", amount = 5 },
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 1 },
		{ type = "item", name = "celestial-matter-guidance-casing", amount = 5 },
	}
}



---HELIOFLUX MELTING CORE
create_item{
	name = "helioflux-melting-core-controller",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "mega-alloy-smelter-controller", amount = 16 },
		{ type = "item", name = "hypogen-coil-block", amount = 64 },
		{ type = "item", name = "harmonic-phonon-transmission-conduit", amount = 32 },
		{ type = "item", name = "eternal-singularity", amount = 16 },
		{ type = "item", name = "ultimate-field-restriction-coil", amount = 48 },
		{ type = "item", name = "uiv-robot-arm", amount = 64 },
		{ type = "item", name = "uiv-field-generator", amount = 64 },
		{ type = "item", name = "dense-six-phased-copper-plate", amount = 16 },
		{ type = "item", name = "dense-creon-plate", amount = 16 },
		{ type = "item", name = "dense-mellion-plate", amount = 16 },
		{ type = "fluid", name = "mutated-living-solder", amount = 14745.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 204800 },
		{ type = "fluid", name = "lead-plasma", amount = 3686.4 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 14745.6 },
	}
}
create_item{
	name = "helioflare-melting-core",
	ingredients = {
		{ type = "item", name = "helioflare-power-forge-controller", amount = 1 },
		{ type = "item", name = "boundless-gravitationally-severed-structure-casing", amount = 20 },
		{ type = "item", name = "transcendentally-amplified-magnetic-confinement-casing", amount = 21 },
		{ type = "item", name = "singularity-reinforced-stellar-shielding-casing", amount = 16 },
		{ type = "item", name = "hypogen-coil-block", amount = 5 },
		{ type = "item", name = "stellar-energy-syphon-casing", amount = 1 },
		{ type = "item", name = "celestial-matter-guidance-casing", amount = 5 },
	}
}