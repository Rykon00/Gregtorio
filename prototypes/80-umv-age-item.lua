--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---------------------
---   SPACETIME   ---
---------------------

create_endgame_parts{
	name = "spacetime",
	tier = "uev",
	speed = UEV_SPEED,
	skip_block = true,
}



create_recipe{
	recipe_name = "molten-spacetime-hc",
	category = "hc-dtpf-recipes",
	energy_required = UXV_SPEED * 1490,
	ingredients = {
		{ type = "item", name = "energized-tesseract", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1000 },
		{ type = "fluid", name = "molten-infinity", amount = 230.4 },
		{ type = "fluid", name = "molten-hypogen", amount = 115.2 },
    },
	results = {
		{ type = "fluid", name = "molten-spacetime", amount = 14.4 },
	}
}
create_recipe{
	recipe_name = "molten-spacetime-ec",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 1490,
	ingredients = {
		{ type = "item", name = "energized-tesseract", amount = 1 },
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 500 },
		{ type = "fluid", name = "molten-infinity", amount = 115.2 },
    },
	results = {
		{ type = "item", name = "hypervisor-matrix", amount = 1 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
	},
	main_product = "molten-spacetime"
}










---------------------------
---   UMV COMPONENETS   ---
---------------------------

---UMV MOTOR
create_item{
	name = "umv-motor",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "long-attuned-tengam-rod", amount = 32 },
		{ type = "item", name = "long-spacetime-rod", amount = 16 },
		{ type = "item", name = "spacetime-ring", amount = 8 },
		{ type = "item", name = "spacetime-round", amount = 32 },
		{ type = "item", name = "fine-spacetime-wire", amount = 512 },
		{ type = "item", name = "quantium-cable-4x", amount = 2 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-motor-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "quantium-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-hypogen", amount = 47001.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 14899.2 },
		{ type = "fluid", name = "molten-purified-tengam", amount = 22118.4 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
	},
	results = {
		{ type = "item", name = "umv-motor", amount = 64 },
	},
}



---UMV PISTON
create_item{
	name = "umv-piston",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 1 },
		{ type = "item", name = "spacetime-plate", amount = 6 },
		{ type = "item", name = "spacetime-ring", amount = 8 },
		{ type = "item", name = "spacetime-round", amount = 64 },
		{ type = "item", name = "spacetime-rod", amount = 8 },
		{ type = "item", name = "large-spacetime-gear", amount = 2 },
		{ type = "item", name = "spacetime-gear", amount = 4 },
		{ type = "item", name = "quantium-cable-4x", amount = 4 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-piston-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 48 },
		{ type = "item", name = "dense-spacetime-plate", amount = 32 },
		{ type = "item", name = "quantium-cable-16x", amount = 48 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 17356.8 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
	},
	results = {
		{ type = "item", name = "umv-piston", amount = 64 },
	},
}



---UMV PUMP
create_item{
	name = "umv-pump",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 1 },
		{ type = "item", name = "infinity-plate", amount = 12 },
		{ type = "item", name = "spacetime-plate", amount = 4 },
		{ type = "item", name = "spacetime-screw", amount = 16 },
		{ type = "item", name = "silicone-rubber-ring", amount = 64 },
		{ type = "item", name = "spacetime-rotor", amount = 4 },
		{ type = "item", name = "quantium-cable-4x", amount = 2 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-pump-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 48 },
		{ type = "item", name = "dense-spacetime-plate", amount = 21 },
		{ type = "item", name = "quantium-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 12979.2 },
		{ type = "fluid", name = "silicone-rubber", amount = 11059.2 },
		{ type = "fluid", name = "molten-infinity", amount = 8294.4 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
	},
	results = {
		{ type = "item", name = "umv-pump", amount = 64 },
	},
}



---UMV CONVEYOR MODULE
create_item{
	name = "umv-conveyor-module",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 2 },
		{ type = "item", name = "spacetime-plate", amount = 2 },
		{ type = "item", name = "spacetime-ring", amount = 8 },
		{ type = "item", name = "spacetime-round", amount = 64 },
		{ type = "item", name = "silicone-rubber-sheet", amount = 80 },
		{ type = "item", name = "quantium-cable-4x", amount = 2 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-conveyor-module-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 96 },
		{ type = "item", name = "dense-spacetime-plate", amount = 10 },
		{ type = "item", name = "quantium-cable-16x", amount = 24 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 6297.6 },
		{ type = "fluid", name = "silicone-rubber", amount = 55209.6 },
		{ type = "fluid", name = "molten-infinity", amount = 8294.4 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
	},
	results = {
		{ type = "item", name = "umv-conveyor-module", amount = 64 },
	},
}



---UMV ROBOT ARM
create_item{
	name = "umv-robot-arm",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 2 },
		{ type = "item", name = "umv-piston", amount = 1 },
		{ type = "item", name = "long-spacetime-rod", amount = 8 },
		{ type = "item", name = "large-spacetime-gear", amount = 2 },
		{ type = "item", name = "large-magmatter-gear", amount = 2 },
		{ type = "item", name = "spacetime-gear", amount = 6 },
		{ type = "item", name = "pico-circuit", amount = 2 },
		{ type = "item", name = "optical-mainframe", amount = 4 },
		{ type = "item", name = "uev-circuit", amount = 8 },
		{ type = "item", name = "quantium-cable-4x", amount = 6 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-robot-arm-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "umv-motor", amount = 96 },
		{ type = "item", name = "umv-piston", amount = 48 },
		{ type = "item", name = "pico-circuit-wrap", amount = 6 },
		{ type = "item", name = "optical-mainframe-wrap", amount = 12 },
		{ type = "item", name = "uiv-circuit-wrap", amount = 24 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 15206.4 },
		{ type = "fluid", name = "molten-quantium", amount = 8294.4 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 19200 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
	},
	results = {
		{ type = "item", name = "umv-robot-arm", amount = 64 },
	},
}



---UMV SENSOR
create_item{
	name = "umv-sensor",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 1 },
		{ type = "item", name = "umv-motor", amount = 1 },
		{ type = "item", name = "spacetime-plate", amount = 8 },
		{ type = "item", name = "gravi-star", amount = 64 },
		{ type = "item", name = "pico-circuit", amount = 4 },
		{ type = "item", name = "celestial-tungsten-foil", amount = 64 },
		{ type = "item", name = "quantum-foil", amount = 64 },
		{ type = "item", name = "astral-titanium-foil", amount = 64 },
		{ type = "item", name = "titansteel-foil", amount = 64 },
		{ type = "item", name = "quantium-cable-4x", amount = 7 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-sensor-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 48 },
		{ type = "item", name = "dense-spacetime-plate", amount = 42 },
		{ type = "item", name = "umv-motor", amount = 48 },
		{ type = "item", name = "pico-circuit-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 192 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 13824 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "molten-quantium", amount = 9676.8 },
		{ type = "fluid", name = "molten-quantum", amount = 11059.2 },
		{ type = "fluid", name = "molten-titansteel", amount = 11059.2 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 11059.2 },
	},
	results = {
		{ type = "item", name = "umv-sensor", amount = 64 },
	},
}



---UMV EMITTER
create_item{
	name = "umv-emitter",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 1 },
		{ type = "item", name = "umv-motor", amount = 1 },
		{ type = "item", name = "spacetime-rod", amount = 16 },
		{ type = "item", name = "gravi-star", amount = 64 },
		{ type = "item", name = "pico-circuit", amount = 4 },
		{ type = "item", name = "celestial-tungsten-foil", amount = 64 },
		{ type = "item", name = "quantum-foil", amount = 64 },
		{ type = "item", name = "astral-titanium-foil", amount = 64 },
		{ type = "item", name = "titansteel-foil", amount = 64 },
		{ type = "item", name = "quantium-cable-4x", amount = 7 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-emitter-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 48 },
		{ type = "item", name = "umv-motor", amount = 48 },
		{ type = "item", name = "pico-circuit-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 192 },
		{ type = "fluid", name = "molten-hypogen", amount = 2764.8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 13824 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "molten-quantium", amount = 9676.8 },
		{ type = "fluid", name = "molten-quantum", amount = 11059.2 },
		{ type = "fluid", name = "molten-titansteel", amount = 11059.2 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 11059.2 },
		{ type = "fluid", name = "molten-spacetime", amount = 5529.6 },
	},
	results = {
		{ type = "item", name = "umv-emitter", amount = 64 },
	},
}



---UMV FIELD GENERATOR
create_item{
	name = "umv-field-generator",
	category = "uiv-assembly-line-recipes",
	energy_required = UIV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 1 },
		{ type = "item", name = "spacetime-plate", amount = 6 },
		{ type = "item", name = "gravi-star", amount = 32 },
		{ type = "item", name = "umv-emitter", amount = 4 },
		{ type = "item", name = "quantum-circuit", amount = 4 },
		{ type = "item", name = "fine-hypogen-wire", amount = 512 },
		{ type = "item", name = "quantium-cable-4x", amount = 8 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_recipe{
	recipe_name = "umv-field-generator-coal",
	category = "uuv-coal-recipes",
	energy_required = UIV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "spacetime-frame", amount = 48 },
		{ type = "item", name = "dense-spacetime-plate", amount = 42 },
		{ type = "item", name = "umv-emitter", amount = 192 },
		{ type = "item", name = "pico-circuit-wrap", amount = 12 },
		{ type = "item", name = "nuclear-star", amount = 96 },
		{ type = "fluid", name = "molten-hypogen", amount = 47001.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2764.8 },
		{ type = "fluid", name = "mutated-living-solder", amount = 12441.6 },
		{ type = "fluid", name = "molten-quantium", amount = 11059.2 },
	},
	results = {
		{ type = "item", name = "umv-field-generator", amount = 64 },
	},
}



---ETERNAL COIL BLOCK (UXV)
create_item{
	name = "eternal-coil-block",
	category = "umv-assembly-line-recipes",
	energy_required = 60 * UMV_SPEED,
	ingredients = {
		{ type = "item", name = "optical-mainframe", amount = 1 },
		{ type = "item", name = "spacetime-wire", amount = 16 },
		{ type = "item", name = "spacetime-screw", amount = 8 },
		{ type = "item", name = "eternal-singularity", amount = 1 },
		{ type = "item", name = "spacetime-foil", amount = 8 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
    }
}





----------------------------
---   ENDGAME CIRCUITS   ---
----------------------------

create_item{
	name = "quantum-circuit",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 1000,
	ingredients = {
		{ type = "item", name = "neutronium-frame", amount = 16 },
		{ type = "item", name = "pico-circuit", amount = 2 },
		{ type = "item", name = "optical-smd-capacitor", amount = 64 },
		{ type = "item", name = "optical-smd-diode", amount = 64 },
		{ type = "item", name = "optical-smd-inductor", amount = 64 },
		{ type = "item", name = "optical-smd-transistor", amount = 64 },
		{ type = "item", name = "optical-smd-resistor", amount = 64 },
		{ type = "item", name = "quantum-power-ic", amount = 64 },
		{ type = "item", name = "shirabon-foil", amount = 64 },
		{ type = "item", name = "indium-bolt", amount = 64 },
		{ type = "item", name = "spacetime-wire", amount = 8 },
		{ type = "fluid", name = "molten-hypogen", amount = 57.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 259.2 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 400 },
	}
}
create_item{
	name = "pico-circuit",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 500,
	ingredients = {
		{ type = "item", name = "optical-circuit-board", amount = 1 },
		{ type = "item", name = "pico-wafer", amount = 4 },
		{ type = "item", name = "optical-smd-capacitor", amount = 48 },
		{ type = "item", name = "optical-smd-diode", amount = 48 },
		{ type = "item", name = "optical-smd-inductor", amount = 48 },
		{ type = "item", name = "optical-smd-transistor", amount = 48 },
		{ type = "item", name = "optical-smd-resistor", amount = 48 },
		{ type = "item", name = "piko-power-ic", amount = 64 },
		{ type = "item", name = "radox-polymer-foil", amount = 16 },
		{ type = "item", name = "transcendent-metal-bolt", amount = 32 },
		{ type = "item", name = "neutronium-bolt", amount = 16 },
		{ type = "item", name = "fine-lanthanum-wire", amount = 64 },
		{ type = "fluid", name = "mutated-living-solder", amount = 374.4 },
		{ type = "fluid", name = "uu-matter", amount = 800 },
		{ type = "fluid", name = "molten-osmium", amount = 115.2 },
	}
}
create_item{
	name = "optical-smd-transistor",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 500,
	ingredients = {
		{ type = "item", name = "black-plutonium-foil", amount = 4 },
		{ type = "item", name = "arceus-alloy-2b-foil", amount = 2 },
		{ type = "item", name = "superconductor-base-zpm-foil", amount = 1 },
		{ type = "item", name = "luv-superconductor-wire", amount = 1 },
		{ type = "fluid", name = "xenoxene", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "optical-smd-transistor", amount = 32 },
	}
}










------------------------------
---   SIX PHASED COPPER    ---
------------------------------

create_recipe{
	recipe_name = "molten-six-phased-copper",
	category = "hc-dtpf-recipes",
	energy_required = UMV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "copper-singularity", amount = 8 },
		{ type = "fluid", name = "molten-mellion", amount = 1036.8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 1036.8 },
		{ type = "fluid", name = "molten-astral-titanium", amount = 4147.2 },
		{ type = "fluid", name = "molten-hypogen", amount = 518.4 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 8294.4 },
		{ type = "fluid", name = "molten-rhugnor", amount = 259.2 },
    },
	results = {
		{ type = "fluid", name = "molten-six-phased-copper", amount = 1036.8 },
	}
}










---------------------
---   SHIRABON    ---
---------------------

create_recipe{
	recipe_name = "molten-shirabon",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "hi-computation-station-mkv-finaltype", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 500 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 115.2 },
		{ type = "fluid", name = "molten-spacetime", amount = 28.8 },
		{ type = "fluid", name = "molten-precious-metals-alloy", amount = 230.4 },
    },
	results = {
		{ type = "fluid", name = "molten-shirabon", amount = 14.4 },
	}
}










------------------------------------
---   REALLY ULTIMATE BATTERY    ---
------------------------------------

create_item{
	name = "really-ultimate-battery",
	category = "uhv-assembly-line-recipes",
	energy_required = UHV_SPEED * 200,
	ingredients = {
		{ type = "item", name = "neutronium-plate", amount = 128 },
		{ type = "item", name = "uev-circuit", amount = 4 },
		{ type = "item", name = "ultimate-battery", amount = 8 },
		{ type = "item", name = "uhv-field-generator", amount = 4 },
		{ type = "item", name = "uhpic-wafer", amount = 128 },
		{ type = "item", name = "asoc-wafer", amount = 32 },
		{ type = "item", name = "advanced-smd-diode", amount = 64 },
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 128 },
		{ type = "fluid", name = "mutated-living-solder", amount = 460.8 },
		{ type = "fluid", name = "molten-naquadria", amount = 921.6 },
		{ type = "fluid", name = "lapis-coolant", amount = 3200 },
    }
}





---------------------
---   MELLION    ---
---------------------

create_item{
	name = "mellion-dust",
	category = "umv-mixer-recipes",
	energy_required = UMV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "rubidium-dust", amount = 11 },
		{ type = "item", name = "tritanium-dust", amount = 11 },
		{ type = "item", name = "fiery-steel-dust", amount = 7 },
		{ type = "item", name = "firestone-dust", amount = 13 },
		{ type = "item", name = "atomic-separation-catalyst-dust", amount = 13 },
		{ type = "item", name = "orundum-dust", amount = 8 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 500 },
    },
	results = {
		{ type = "item", name = "mellion-dust", amount = 63 },
	}
}
create_item{
	name = "fiery-steel-dust",
	category = "lv-mixer-recipes",
	energy_required = LV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "steel-dust", amount = 1 },
		{ type = "fluid", name = "fiery-blood", amount = 20 },
    }
}
create_recipe{
	recipe_name = "fiery-blood",
	category = "ev-extractor-recipes",
	energy_required = EV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "salis-mundus", amount = 6 },
    },
	results = {
		{ type = "fluid", name = "fiery-blood", amount = 25 },
	}
}