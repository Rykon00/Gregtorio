--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

--536870912 : maximum UXV voltage
--2147483648 : maximum MAX voltage

---------------------------
---   UXV COMPONENETS   ---
---------------------------

---UXV MOTOR
create_item{
	name = "uxv-motor",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "energized-tesseract", amount = 1 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 6 },
		{ type = "item", name = "mhdc-star-matter-round", amount = 32 },
		{ type = "item", name = "mhdc-star-matter-ring", amount = 8 },
		{ type = "item", name = "long-mhdc-star-matter-rod", amount = 16 },
		{ type = "item", name = "large-mhdc-star-matter-gear", amount = 8 },
		{ type = "item", name = "fine-mhdc-star-matter-wire", amount = 128 },
		{ type = "item", name = "fine-umv-superconductor-base-wire", amount = 128 },
		{ type = "item", name = "fine-universium-wire", amount = 128 },
		{ type = "item", name = "fine-magmatter-wire", amount = 128 },
		{ type = "item", name = "spacetime-wire", amount = 16 },
		{ type = "item", name = "neutronium-nanites", amount = 4 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 800 },
	}
}
create_recipe{
	recipe_name = "uxv-motor-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "energized-tesseract", amount = 48 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 114 },
		{ type = "item", name = "spacetime-wire-16x", amount = 48 },
		{ type = "item", name = "gold-nanites", amount = 12 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 28723.2 },
		{ type = "fluid", name = "molten-spacetime", amount = 2764.8 },
		{ type = "fluid", name = "molten-universium", amount = 13824 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 38400 },
		{ type = "fluid", name = "molten-superconductor-base-umv", amount = 11059.2 },
		{ type = "fluid", name = "molten-magmatter", amount = 11059.2 },
		{ type = "fluid", name = "molten-eternity", amount = 25958.4 },
	},
	results = {
		{ type = "item", name = "uxv-motor", amount = 64 },
	},
}



---UXV PISTON
create_item{
	name = "uxv-piston",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 1 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 6 },
		{ type = "item", name = "mhdc-star-matter-ring", amount = 8 },
		{ type = "item", name = "mhdc-star-matter-round", amount = 64 },
		{ type = "item", name = "mhdc-star-matter-rod", amount = 8 },
		{ type = "item", name = "large-mhdc-star-matter-gear", amount = 8 },
		{ type = "item", name = "large-magmatter-gear", amount = 8 },
		{ type = "item", name = "mhdc-star-matter-gear", amount = 16 },
		{ type = "item", name = "magmatter-gear", amount = 16 },
		{ type = "item", name = "spacetime-wire", amount = 32 },
		{ type = "item", name = "neutronium-nanites", amount = 4 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 800 },
	}
}
create_recipe{
	recipe_name = "uxv-piston-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 48 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 84 },
		{ type = "item", name = "gold-nanites", amount = 12 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 24268.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 13824 },
		{ type = "fluid", name = "molten-universium", amount = 2764.8 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 38400 },
		{ type = "fluid", name = "molten-magmatter", amount = 8294.4 },
		{ type = "fluid", name = "molten-eternity", amount = 21504 },
	},
	results = {
		{ type = "item", name = "uxv-piston", amount = 64 },
	},
}



---UXV PUMP
create_item{
	name = "uxv-pump",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 1 },
		{ type = "item", name = "spacetime-plate", amount = 12 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 4 },
		{ type = "item", name = "mhdc-star-matter-screw", amount = 16 },
		{ type = "item", name = "kevlar-ring", amount = 64 },
		{ type = "item", name = "radox-polymer-ring", amount = 64 },
		{ type = "item", name = "mhdc-star-matter-rotor", amount = 4 },
		{ type = "item", name = "magmatter-rotor", amount = 4 },
		{ type = "item", name = "spacetime-wire", amount = 16 },
		{ type = "item", name = "neutronium-nanites", amount = 4 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 800 },
	}
}
create_recipe{
	recipe_name = "uxv-pump-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 48 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 42 },
		{ type = "item", name = "spacetime-wire-16x", amount = 48 },
		{ type = "item", name = "gold-nanites", amount = 12 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 18508.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 11059.2 },
		{ type = "fluid", name = "molten-universium", amount = 2764.8 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 38400 },
		{ type = "fluid", name = "molten-magmatter", amount = 11750.4 },
		{ type = "fluid", name = "molten-radox-polymer", amount = 11059.2 },
		{ type = "fluid", name = "molten-kevlar", amount = 11059.2 },
		{ type = "fluid", name = "molten-eternity", amount = 15744 },
	},
	results = {
		{ type = "item", name = "uxv-pump", amount = 64 },
	},
}



---UXV CONVEYOR MODULE
create_item{
	name = "uxv-conveyor-module",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 2 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 2 },
		{ type = "item", name = "mhdc-star-matter-ring", amount = 8 },
		{ type = "item", name = "mhdc-star-matter-round", amount = 64 },
		{ type = "item", name = "kevlar-plate", amount = 80 },
		{ type = "item", name = "radox-polymer-plate", amount = 80 },
		{ type = "item", name = "spacetime-wire", amount = 16 },
		{ type = "item", name = "neutronium-nanites", amount = 4 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 800 },
	}
}
create_recipe{
	recipe_name = "uxv-conveyor-module-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 96 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 36 },
		{ type = "item", name = "spacetime-wire-16x", amount = 48 },
		{ type = "item", name = "gold-nanites", amount = 12 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 10444.8 },
		{ type = "fluid", name = "molten-spacetime", amount = 2764.8 },
		{ type = "fluid", name = "molten-universium", amount = 2764.8 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 38400 },
		{ type = "fluid", name = "molten-radox-polymer", amount = 55209.6 },
		{ type = "fluid", name = "molten-kevlar", amount = 55209.6 },
		{ type = "fluid", name = "molten-eternity", amount = 7680 },
	},
	results = {
		{ type = "item", name = "uxv-conveyor-module", amount = 64 },
	},
}



---UXV ROBOT ARM
create_item{
	name = "uxv-robot-arm",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 2 },
		{ type = "item", name = "uxv-piston", amount = 1 },
		{ type = "item", name = "long-mhdc-star-matter-rod", amount = 8 },
		{ type = "item", name = "large-mhdc-star-matter-gear", amount = 2 },
		{ type = "item", name = "large-magmatter-gear", amount = 2 },
		{ type = "item", name = "mhdc-star-matter-gear", amount = 6 },
		{ type = "item", name = "magmatter-gear", amount = 6 },
		{ type = "item", name = "quantum-circuit", amount = 2 },
		{ type = "item", name = "pico-circuit", amount = 4 },
		{ type = "item", name = "optical-mainframe", amount = 8 },
		{ type = "item", name = "spacetime-wire", amount = 48 },
		{ type = "item", name = "neutronium-nanites", amount = 8 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 800 },
	}
}
create_recipe{
	recipe_name = "uxv-robot-arm-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 96 },
		{ type = "item", name = "uxv-piston", amount = 48 },
		{ type = "item", name = "quantum-circuit-wrap", amount = 6 },
		{ type = "item", name = "pico-circuit-wrap", amount = 12 },
		{ type = "item", name = "uiv-circuit-wrap", amount = 24 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 54 },
		{ type = "item", name = "gold-nanites", amount = 24 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 17971.2 },
		{ type = "fluid", name = "molten-spacetime", amount = 19353.6 },
		{ type = "fluid", name = "molten-universium", amount = 2764.8 },
		{ type = "fluid", name = "dimensionally-shifted-superfluid", amount = 38400 },
		{ type = "fluid", name = "molten-magmatter", amount = 9676.8 },
		{ type = "fluid", name = "molten-eternity", amount = 15206.4 },
	},
	results = {
		{ type = "item", name = "uxv-robot-arm", amount = 64 },
	},
}



---UXV SENSOR
create_item{
	name = "uxv-sensor",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-frame", amount = 1 },
		{ type = "item", name = "uxv-motor", amount = 1 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 8 },
		{ type = "item", name = "nuclear-star", amount = 16 },
		{ type = "item", name = "quantum-circuit", amount = 4 },
		{ type = "item", name = "mhdc-star-matter-foil", amount = 64 },
		{ type = "item", name = "spacetime-foil", amount = 64 },
		{ type = "item", name = "universium-foil", amount = 64 },
		{ type = "item", name = "magmatter-foil", amount = 64 },
		{ type = "item", name = "spacetime-wire", amount = 56 },
		{ type = "item", name = "neutronium-nanites", amount = 8 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1440 },
	}
}
create_recipe{
	recipe_name = "uxv-sensor-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 48 },
		{ type = "item", name = "nuclear-star", amount = 768 },
		{ type = "item", name = "quantum-circuit-wrap", amount = 12 },
		{ type = "item", name = "mhdc-star-matter-frame", amount = 48 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 48 },
		{ type = "item", name = "gold-nanites", amount = 24 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 19353.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 33177.6 },
		{ type = "fluid", name = "molten-universium", amount = 13824 },
		{ type = "fluid", name = "mutated-living-solder", amount = 69120 },
		{ type = "fluid", name = "molten-magmatter", amount = 11059.2 },
		{ type = "fluid", name = "molten-eternity", amount = 16588.8 },
	},
	results = {
		{ type = "item", name = "uxv-sensor", amount = 64 },
	},
}



---UXV EMITTER
create_item{
	name = "uxv-emitter",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-frame", amount = 1 },
		{ type = "item", name = "uxv-motor", amount = 1 },
		{ type = "item", name = "mhdc-star-matter-rod", amount = 16 },
		{ type = "item", name = "nuclear-star", amount = 16 },
		{ type = "item", name = "quantum-circuit", amount = 4 },
		{ type = "item", name = "mhdc-star-matter-foil", amount = 64 },
		{ type = "item", name = "spacetime-foil", amount = 64 },
		{ type = "item", name = "universium-foil", amount = 64 },
		{ type = "item", name = "magmatter-foil", amount = 64 },
		{ type = "item", name = "spacetime-wire", amount = 56 },
		{ type = "item", name = "neutronium-nanites", amount = 8 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1440 },
	}
}
create_recipe{
	recipe_name = "uxv-emitter-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "uxv-motor", amount = 48 },
		{ type = "item", name = "nuclear-star", amount = 768 },
		{ type = "item", name = "quantum-circuit-wrap", amount = 12 },
		{ type = "item", name = "mhdc-star-matter-frame", amount = 48 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 48 },
		{ type = "item", name = "gold-nanites", amount = 24 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 19353.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 33177.6 },
		{ type = "fluid", name = "molten-universium", amount = 13824 },
		{ type = "fluid", name = "mutated-living-solder", amount = 69120 },
		{ type = "fluid", name = "molten-magmatter", amount = 11059.2 },
		{ type = "fluid", name = "molten-eternity", amount = 16588.8 },
	},
	results = {
		{ type = "item", name = "uxv-emitter", amount = 64 },
	},
}



---UXV FIELD GENERATOR
create_item{
	name = "uxv-field-generator",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-frame", amount = 1 },
		{ type = "item", name = "mhdc-star-matter-plate", amount = 6 },
		{ type = "item", name = "nuclear-star", amount = 64 },
		{ type = "item", name = "uxv-emitter", amount = 4 },
		{ type = "item", name = "quantum-circuit", amount = 8 },
		{ type = "item", name = "fine-umv-superconductor-base-wire", amount = 128 },
		{ type = "item", name = "fine-mhdc-star-matter-wire", amount = 128 },
		{ type = "item", name = "fine-universium-wire", amount = 128 },
		{ type = "item", name = "fine-magmatter-wire", amount = 128 },
		{ type = "item", name = "spacetime-wire", amount = 64 },
		{ type = "item", name = "neutronium-nanites", amount = 12 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1440 },
	}
}
create_recipe{
	recipe_name = "uxv-field-generator-coal",
	category = "uxv-coal-recipes",
	energy_required = UMV_SPEED * 2400,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-frame", amount = 48 },
		{ type = "item", name = "nuclear-star", amount = 3072 },
		{ type = "item", name = "uhv-circuit-wrap", amount = 66 },
		{ type = "item", name = "uxv-emitter", amount = 192 },
		{ type = "item", name = "quantum-circuit-wrap", amount = 24 },
		{ type = "item", name = "gold-nanites", amount = 36 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 17971.2 },
		{ type = "fluid", name = "molten-spacetime", amount = 24883.2 },
		{ type = "fluid", name = "molten-universium", amount = 13824 },
		{ type = "fluid", name = "mutated-living-solder", amount = 69120 },
		{ type = "fluid", name = "molten-superconductor-base-umv", amount = 11059.2 },
		{ type = "fluid", name = "molten-magmatter", amount = 11059.2 },
		{ type = "fluid", name = "molten-eternity", amount = 152064 },
	},
	results = {
		{ type = "item", name = "uxv-field-generator", amount = 64 },
	},
}







create_item{
	name = "component-assembly-line-casing-uxv",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-frame", amount = 1 },
		{ type = "item", name = "dense-mhdc-star-matter-plate", amount = 3 },
		{ type = "item", name = "dense-magmatter-plate", amount = 3 },
		{ type = "item", name = "uxv-robot-arm", amount = 8 },
		{ type = "item", name = "uxv-piston", amount = 10 },
		{ type = "item", name = "uxv-motor", amount = 16 },
		{ type = "item", name = "large-mhdc-star-matter-gear", amount = 2 },
		{ type = "item", name = "large-magmatter-gear", amount = 2 },
		{ type = "item", name = "mhdc-star-matter-gear", amount = 8 },
		{ type = "item", name = "magmatter-gear", amount = 8 },
		{ type = "item", name = "spacetime-wire", amount = 32 },
		{ type = "item", name = "quantum-circuit", amount = 8 },
		{ type = "item", name = "pico-circuit", amount = 16 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 57.6 },
		{ type = "fluid", name = "molten-universium", amount = 57.6 },
		{ type = "fluid", name = "mutated-living-solder", amount = 1440 },
	}
}



---------------------
---   MAGMATTER   ---
---------------------

create_endgame_parts{
	name = "magmatter",
	tier = "umv",
	speed = UMV_SPEED
}



---MOLTEN MAGMATTER (needs plasma quantities researched)
create_recipe{
	name = "molten-magmatter",
	category = "heliofusion-exoticizer-recipes",
	energy_required = 140,
	ingredients = {
		{ type = "fluid", name = "rhugnor-plasma", amount = 1296 },
		{ type = "fluid", name = "hypogen-plasma", amount = 1296 },
		{ type = "fluid", name = "bedrockium-plasma", amount = 1296 },
		{ type = "fluid", name = "dragonblood-plasma", amount = 1296 },
		{ type = "fluid", name = "flerovium-plasma", amount = 1296 },
		{ type = "fluid", name = "chromatic-glass-plasma", amount = 1296 },
		{ type = "fluid", name = "ichorium-plasma", amount = 1296 },
		{ type = "fluid", name = "celestial-tungsten-plasma", amount = 1296 },
		{ type = "fluid", name = "infinity-plasma", amount = 1296 },
		{ type = "fluid", name = "tritanium-plasma", amount = 1296 },
		{ type = "fluid", name = "cosmic-neutronium-plasma", amount = 1296 },
		{ type = "fluid", name = "neutronium-plasma", amount = 1296 },
		{ type = "fluid", name = "draconium-plasma", amount = 1296 },
		{ type = "fluid", name = "awakened-draconium-plasma", amount = 1296 },
	},
	results = {
		{ type = "fluid", name = "molten-magmatter", amount = 806.4 },
	},
	main_product = "molten-magmatter"
}










----------------------------
---   MHDC STAR MATTER   ---
----------------------------

create_recipe{
	name = "molten-mhdc-star-matter-first",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = 4 * UXV_SPEED,
	ingredients = {
		{ type = "item", name = "white-dwarf-nanites", amount = 1 },
		{ type = "item", name = "black-dwarf-nanites", amount = 1 },
		{ type = "item", name = "universium-nanites", amount = 1 },
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 921.6 },
	},
	results = {
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 230.4 },
	}
}
create_recipe{
	name = "molten-mhdc-star-matter-second",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = 16 * UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-nanites", amount = 1 },
		{ type = "item", name = "universium-nanites", amount = 1 },
		{ type = "fluid", name = "condensed-raw-stellar-plasma-mixture", amount = 1843.2 },
	},
	results = {
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 460.8 },
	}
}



create_item{
	name = "mhdc-star-matter-plate",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-plate", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	}
}



create_item{
	name = "long-mhdc-star-matter-rod",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "long-eternity-rod", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	}
}



create_item{
	name = "mhdc-star-matter-rod",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-rod", amount = 2 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-rod", amount = 2 },
	}
}



create_item{
	name = "mhdc-star-matter-frame",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 2,
	ingredients = {
		{ type = "item", name = "eternity-frame", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	}
}



create_item{
	name = "fine-mhdc-star-matter-wire",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "fine-eternity-wire", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "fine-mhdc-star-matter-wire", amount = 8 },
	}
}



create_item{
	name = "mhdc-star-matter-foil",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 2,
	ingredients = {
		{ type = "item", name = "eternity-foil", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-foil", amount = 8 },
	}
}



create_item{
	name = "large-mhdc-star-matter-gear",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 4,
	ingredients = {
		{ type = "item", name = "large-eternity-gear", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 2 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 57.6 },
	}
}



create_item{
	name = "mhdc-star-matter-gear",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-gear", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	}
}



create_item{
	name = "mhdc-star-matter-ring",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-ring", amount = 4 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-ring", amount = 4 },
	}
}



create_item{
	name = "mhdc-star-matter-round",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 0.85,
	ingredients = {
		{ type = "item", name = "eternity-round", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-round", amount = 8 },
	}
}



create_item{
	name = "mhdc-star-matter-screw",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 0.85,
	ingredients = {
		{ type = "item", name = "eternity-screw", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-screw", amount = 8 },
	}
}



create_item{
	name = "mhdc-star-matter-bolt",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED,
	ingredients = {
		{ type = "item", name = "eternity-bolt", amount = 8 },
		{ type = "item", name = "uhv-circuit", amount = 1 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 1 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	},
	results = {
		{ type = "item", name = "mhdc-star-matter-bolt", amount = 8 },
	}
}


create_item{
	name = "mhdc-star-matter-rotor",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 4.25,
	ingredients = {
		{ type = "item", name = "eternity-rotor", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 2 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 2 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 14.4 },
	}
}



create_item{
	name = "dense-mhdc-star-matter-plate",
	category = "uxv-electric-implosion-compressor-recipes",
	energy_required = UXV_SPEED * 9,
	ingredients = {
		{ type = "item", name = "dense-eternity-plate", amount = 1 },
		{ type = "item", name = "uhv-circuit", amount = 3 },
		{ type = "item", name = "solar-light-splitter", amount = 1 },
		{ type = "item", name = "hologram-projector-t2", amount = 3 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 129.6 },
	}
}



create_item{
	name = "superdense-mhdc-star-matter-plate",
	category = "uxv-stabalized-black-hole-recipes",
	energy_required = UXV_SPEED * 4500,
	ingredients = {
		{ type = "item", name = "mhdc-star-matter-plate", amount = 64 },
	}
}



create_item{
	name = "hologram-projector-t2",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 10,
	ingredients = {
		{ type = "item", name = "epoxy-printed-circuit-board", amount = 2 },
		{ type = "item", name = "microchip-t3", amount = 2 },
		{ type = "item", name = "polyethylene-sheet", amount = 2 },
		{ type = "item", name = "oc-cable", amount = 2 },
		{ type = "item", name = "obsidian-plate", amount = 4 },
		{ type = "item", name = "ruby-lens", amount = 3 },
		{ type = "fluid", name = "polyethylene", amount = 7.2 },
	}
}



create_item{
	name = "microchip-t3",
	category = "hv-circuit-assembler-recipes",
	energy_required = HV_SPEED * 7.5,
	ingredients = {
		{ type = "item", name = "fiber-reinforced-printed-circuit-board", amount = 1 },
		{ type = "item", name = "ev-circuit", amount = 1 },
		{ type = "item", name = "advanced-smd", amount = 4 },
		{ type = "item", name = "electrum-foil", amount = 16 },
		{ type = "fluid", name = "soldering-alloy", amount = 7.2 },
	}
}



create_item{
	name = "oc-cable",
	category = "hv-circuit-assembler-recipes",
	energy_required = HV_SPEED * 7.5,
	ingredients = {
		{ type = "item", name = "gold-cable", amount = 9 },
		{ type = "item", name = "emerald-dust", amount = 1 },
	},
	results = {
		{ type = "item", name = "oc-cable", amount = 9 },
	}
}



create_item{
	name = "solar-light-splitter",
	ingredients = {
		{ type = "item", name = "spectral-component", amount = 9 },
	}
}



create_item{
	name = "spectral-component",
	category = "iv-laser-engraver-recipes",
	energy_required = IV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "irradiant-glass-pane", amount = 1 },
	}
}



create_item{
	name = "irradiant-glass-pane",
	ingredients = {
		{ type = "item", name = "irradiant-uranium", amount = 4 },
		{ type = "item", name = "reinforced-glass", amount = 4 },
		{ type = "item", name = "glowstone-block", amount = 1 },
	}
}



create_item{
	name = "irradiant-uranium",
	category = "ev-alloy-smelter-recipes",
	energy_required = EV_SPEED * 50,
	ingredients = {
		{ type = "item", name = "uranium-ingot", amount = 1 },
		{ type = "item", name = "sunnarium", amount = 1 },
	}
}










--------------------------
---      ETERNITY      ---
--------------------------

create_endgame_parts{
	name = "eternity",
	tier = "umv",
	speed = UMV_SPEED
}









--------------------
---   QUANTUM    ---
--------------------

create_recipe{
	recipe_name = "molten-quantum-exotic",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 27,
	ingredients = {
		{ type = "item", name = "energy-core-uhv", amount = 1 },
		{ type = "item", name = "block-of-quantium", amount = 2 },
		{ type = "item", name = "quantum-anomaly", amount = 2 },
		{ type = "fluid", name = "molten-black-titanium", amount = 3225.6 },
		{ type = "fluid", name = "molten-americium", amount = 460.8 },
		{ type = "fluid", name = "molten-hypogen", amount = 460.8 },
		{ type = "fluid", name = "molten-bismuth", amount = 460.8 },
		{ type = "fluid", name = "titanium-plasma", amount = 518.4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 227.4 },
    },
	results = {
		{ type = "item", name = "energy-core-uhv", amount = 1 },
		{ type = "item", name = "block-of-astral-titanium", amount = 2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 227.4 },
		{ type = "fluid", name = "molten-quantum", amount = 4608 },
	},
	main_product = "molten-quantum"
}
create_recipe{
	recipe_name = "molten-quantum-stellar",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 27,
	ingredients = {
		{ type = "item", name = "energy-core-uhv", amount = 1 },
		{ type = "item", name = "block-of-quantium", amount = 4 },
		{ type = "item", name = "quantum-anomaly", amount = 3 },
		{ type = "fluid", name = "molten-black-titanium", amount = 6451.2 },
		{ type = "fluid", name = "molten-americium", amount = 921.6 },
		{ type = "fluid", name = "molten-hypogen", amount = 921.6 },
		{ type = "fluid", name = "molten-bismuth", amount = 921.6 },
		{ type = "fluid", name = "titanium-plasma", amount = 1036.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 102.3 },
    },
	results = {
		{ type = "item", name = "energy-core-uhv", amount = 1 },
		{ type = "item", name = "block-of-astral-titanium", amount = 4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 204.6 },
		{ type = "fluid", name = "molten-quantum", amount = 9216 },
	},
	main_product = "molten-quantum"
}









---------------------------
---   SUPERCONDUCTORS   ---
---------------------------

---CADMOXIUM [SUPERCONDUCTOR BASE MV]
create_item{
	name = "cadmoxium-superconductive-wire",
	category = "mv-assembling-machine-recipes",
	energy_required = MV_SPEED * 16,
	ingredients = {
		{ type = "item", name = "cadmoxium-wire", amount = 3 },
		{ type = "item", name = "mv-pump", amount = 1 },
		{ type = "fluid", name = "molten-stainless-steel", amount = 14.4 },
		{ type = "fluid", name = "cryogenic-helium", amount = 200 },
	},
	results = {
		{ type = "item", name = "cadmoxium-superconductive-wire", amount = 3 },
	}
}



---CUPROBARITE [SUPERCONDUCTOR BASE HV]
create_item{
	name = "cuprobarite-superconductive-wire",
	category = "hv-assembling-machine-recipes",
	energy_required = HV_SPEED * 16,
	ingredients = {
		{ type = "item", name = "cuprobarite-wire", amount = 6 },
		{ type = "item", name = "hv-pump", amount = 1 },
		{ type = "fluid", name = "molten-titanium", amount = 28.8 },
		{ type = "fluid", name = "cryogenic-helium", amount = 400 },
	},
	results = {
		{ type = "item", name = "cuprobarite-superconductive-wire", amount = 6 },
	}
}



---URANIUM TRIPLATINUM [SUPERCONDUCTOR BASE EV]
create_item{
	name = "uranium-triplatinide-superconductive-wire",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 16,
	ingredients = {
		{ type = "item", name = "uranium-triplatinide-wire", amount = 9 },
		{ type = "item", name = "ev-pump", amount = 1 },
		{ type = "fluid", name = "molten-tungstensteel", amount = 43.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 600 },
	},
	results = {
		{ type = "item", name = "uranium-triplatinide-superconductive-wire", amount = 9 },
	}
}



---BARIUM TITANATE CUPOXIDE [SUPERCONDUCTOR BASE LUV]
create_recipe{
	recipe_name = "molten-barium-titanate-cuproxide-crude",
	category = "adc-dtpf-recipes",
	energy_required = 31.5 * UIV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-indium", amount = 15724.8 },
		{ type = "fluid", name = "molten-tin", amount = 7862.4 },
		{ type = "fluid", name = "molten-barium", amount = 7862.4 },
		{ type = "fluid", name = "molten-titanium", amount = 3931.2 },
		{ type = "fluid", name = "molten-copper", amount = 27518.4 },
		{ type = "fluid", name = "oxygen-plasma", amount = 11930.1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 3793.5 },
	},
	results = {
		{ type = "fluid", name = "molten-barium-titanate-cuproxide", amount = 117936 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 116.1 },
	}
}
create_item{
	name = "barium-titanate-cuproxide-superconductive-wire",
	category = "luv-assembling-machine-recipes",
	energy_required = LUV_SPEED * 32,
	ingredients = {
		{ type = "item", name = "barium-titanate-cuproxide-wire", amount = 15 },
		{ type = "item", name = "luv-pump", amount = 1 },
		{ type = "fluid", name = "molten-enderium", amount = 72 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1200 },
	},
	results = {
		{ type = "item", name = "barium-titanate-cuproxide-superconductive-wire", amount = 15 },
	}
}



---PALLADIUM NAQINDIUM [SUPERCONDUCTOR BASE ZPM]
create_item{
	name = "palladium-naqindium-superconductive-wire",
	category = "zpm-assembling-machine-recipes",
	energy_required = ZPM_SPEED * 64,
	ingredients = {
		{ type = "item", name = "palladium-naqindium-wire", amount = 18 },
		{ type = "item", name = "zpm-pump", amount = 1 },
		{ type = "fluid", name = "molten-naquadah", amount = 86.4 },
		{ type = "fluid", name = "cryogenic-helium", amount = 1600 },
	},
	results = {
		{ type = "item", name = "palladium-naqindium-superconductive-wire", amount = 18 },
	}
}



---NAQUAMIRIDIUM [SUPERCONDUCTOR BASE UV]
create_recipe{
	recipe_name = "molten-naquamiridium-crude",
	category = "adc-dtpf-recipes",
	energy_required = 31.5 * UIV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-indium", amount = 15724.8 },
		{ type = "fluid", name = "molten-tin", amount = 7862.4 },
		{ type = "fluid", name = "molten-barium", amount = 7862.4 },
		{ type = "fluid", name = "molten-titanium", amount = 3931.2 },
		{ type = "fluid", name = "molten-copper", amount = 27518.4 },
		{ type = "fluid", name = "oxygen-plasma", amount = 11930.1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 3793.5 },
	},
	results = {
		{ type = "fluid", name = "molten-naquamiridium", amount = 117936 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 116.1 },
	}
}
create_recipe{
	recipe_name = "molten-naquamiridium-prosaic",
	category = "ic-dtpf-recipes",
	energy_required = 15.75 * UIV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-indium", amount = x },
		{ type = "fluid", name = "molten-tin", amount = x },
		{ type = "fluid", name = "molten-barium", amount = x },
		{ type = "fluid", name = "molten-titanium", amount = x },
		{ type = "fluid", name = "molten-copper", amount = x },
		{ type = "fluid", name = "oxygen-plasma", amount = x },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = x },
	},
	results = {
		{ type = "fluid", name = "molten-naquamiridium", amount = x },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = x },
	}
}
create_recipe{
	name = "molten-naquamiridium-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = 7.85 * UMV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-indium", amount = x },
		{ type = "fluid", name = "molten-tin", amount = x },
		{ type = "fluid", name = "molten-barium", amount = x },
		{ type = "fluid", name = "molten-titanium", amount = x },
		{ type = "fluid", name = "molten-copper", amount = x },
		{ type = "fluid", name = "oxygen-plasma", amount = x },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = x },
	},
	results = {
		{ type = "fluid", name = "molten-naquamiridium", amount = x },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = x },
	}
}
create_recipe{
	name = "molten-naquamiridium-exotic",
	category = "ec-dtpf-recipes",
	energy_required = 3.9 * UMV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-indium", amount = x },
		{ type = "fluid", name = "molten-tin", amount = x },
		{ type = "fluid", name = "molten-barium", amount = x },
		{ type = "fluid", name = "molten-titanium", amount = x },
		{ type = "fluid", name = "molten-copper", amount = x },
		{ type = "fluid", name = "oxygen-plasma", amount = x },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = x },
	},
	results = {
		{ type = "fluid", name = "molten-naquamiridium", amount = x },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = x },
	}
}
create_item{
	name = "naquamiridium-ingot",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-naquamiridium", amount = 14.4 },
	}
}
create_item{
	name = "naquamiridium-wire",
	category = "lv-wiremill-recipes",
	energy_required = 5.5,
	ingredients = {
		{ type = "item", name = "naquamiridium-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "naquamiridium-wire", amount = 2 },
	}
}
create_item{
	name = "naquamiridium-superconductive-wire",
	category = "uv-assembling-machine-recipes",
	energy_required = UV_SPEED * 64,
	ingredients = {
		{ type = "item", name = "naquamiridium-wire", amount = 21 },
		{ type = "item", name = "uv-pump", amount = 1 },
		{ type = "fluid", name = "neutronium", amount = 100.8 },
		{ type = "fluid", name = "cryogenic-helium", amount = 2000 },
	},
	results = {
		{ type = "item", name = "naquamiridium-superconductive-wire", amount = 21 },
	}
}



---TRIAMEROTRONIUM [SUPERCONDUCTOR BASE UHV]
create_item{
	name = "triamerotronium-superconductive-wire",
	category = "uhv-assembling-machine-recipes",
	energy_required = UHV_SPEED * 128,
	ingredients = {
		{ type = "item", name = "triamerotronium-wire", amount = 24 },
		{ type = "item", name = "uhv-pump", amount = 1 },
		{ type = "fluid", name = "molten-bedrockium", amount = 115.2 },
		{ type = "fluid", name = "cryogenic-helium", amount = 2400 },
	},
	results = {
		{ type = "item", name = "triamerotronium-superconductive-wire", amount = 24 },
	}
}



---DRACOFINIUM [SUPERCONDUCTOR BASE UEV]
create_recipe{
	recipe_name = "molten-dracofinium-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = 94.75 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-advanced-nitinol", amount = 604.8 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 604.8 },
		{ type = "fluid", name = "molten-awakened-draconium", amount = 3024 },
		{ type = "fluid", name = "molten-infinity", amount = 3024 },
		{ type = "fluid", name = "iron-plasma", amount = 604.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 3793.5 },
	},
	results = {
		{ type = "fluid", name = "molten-dracofinium", amount = 7257.6 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1896.7 },
	}
}
create_recipe{
	name = "molten-dracofinium-exotic",
	category = "ec-dtpf-recipes",
	energy_required = 47.35 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-advanced-nitinol", amount = 1209.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 1209.6 },
		{ type = "fluid", name = "molten-awakened-draconium", amount = 6048 },
		{ type = "fluid", name = "molten-infinity", amount = 6048 },
		{ type = "fluid", name = "iron-plasma", amount = 1209.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 1713.9 },
	},
	results = {
		{ type = "fluid", name = "molten-dracofinium", amount = 14515.2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1713.9 },
	}
}
create_recipe{
	name = "molten-dracofinium-stellar",
	category = "ec-dtpf-recipes",
	energy_required = 23.65 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-advanced-nitinol", amount = 2419.2 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 2419.2 },
		{ type = "fluid", name = "molten-awakened-draconium", amount = 12096 },
		{ type = "fluid", name = "molten-infinity", amount = 12096 },
		{ type = "fluid", name = "iron-plasma", amount = 2419.2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 1497 },
	},
	results = {
		{ type = "fluid", name = "molten-dracofinium", amount = 29030.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 1497 },
	}
}
create_item{
	name = "dracofinium-ingot",
	category = "uv-fluid-solidifier-recipes",
	energy_required = UV_SPEED * 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-dracofinium", amount = 14.4 },
	}
}
create_item{
	name = "dracofinium-wire",
	category = "uv-wiremill-recipes",
	energy_required = UV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "dracofinium-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "dracofinium-wire", amount = 2 },
	}
}
create_item{
	name = "dracofinium-superconductive-wire",
	category = "uev-assembling-machine-recipes",
	energy_required = UEV_SPEED * 160,
	ingredients = {
		{ type = "item", name = "dracofinium-wire", amount = 27 },
		{ type = "item", name = "uev-pump", amount = 1 },
		{ type = "fluid", name = "molten-infinity", amount = 129.6 },
		{ type = "fluid", name = "cryogenic-helium", amount = 2800 },
	},
	results = {
		{ type = "item", name = "dracofinium-superconductive-wire", amount = 27 },
	}
}



---CHROMNOROX [SUPERCONDUCTOR BASE UIV]
create_recipe{
	recipe_name = "molten-chromnorox-resplendent",
	category = "hc-dtpf-recipes",
	energy_required = 94.75 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-radox-polymer", amount = 576 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 1440 },
		{ type = "fluid", name = "molten-rhugnor", amount = 864 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 720 },
		{ type = "fluid", name = "bismuth-plasma", amount = 144 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 7777.7 },
	},
	results = {
		{ type = "fluid", name = "molten-chromnorox", amount = 3600 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 3888.8 },
	}
}
create_recipe{
	name = "molten-chromnorox-exotic",
	category = "ec-dtpf-recipes",
	energy_required = 47.35 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-radox-polymer", amount = 1152 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 2880 },
		{ type = "fluid", name = "molten-rhugnor", amount = 1728 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 1440 },
		{ type = "fluid", name = "bismuth-plasma", amount = 288 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 3463.6 },
	},
	results = {
		{ type = "fluid", name = "molten-chromnorox", amount = 7200 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 3463.6 },
	}
}
create_recipe{
	name = "molten-chromnorox-stellar",
	category = "ec-dtpf-recipes",
	energy_required = 23.65 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-radox-polymer", amount = 2304 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 5760 },
		{ type = "fluid", name = "molten-rhugnor", amount = 3456 },
		{ type = "fluid", name = "molten-chromatic-glass", amount = 2880 },
		{ type = "fluid", name = "bismuth-plasma", amount = 576 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 1501 },
	},
	results = {
		{ type = "fluid", name = "molten-chromnorox", amount = 14400 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 3002 },
	}
}
create_item{
	name = "chromnorox-ingot",
	category = "uhv-fluid-solidifier-recipes",
	energy_required = UHV_SPEED * 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-chromnorox", amount = 14.4 },
	}
}
create_item{
	name = "chromnorox-wire",
	category = "uhv-wiremill-recipes",
	energy_required = UHV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "chromnorox-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "chromnorox-wire", amount = 2 },
	}
}
create_item{
	name = "chromnorox-superconductive-wire",
	category = "uiv-assembling-machine-recipes",
	energy_required = UIV_SPEED * 160,
	ingredients = {
		{ type = "item", name = "chromnorox-wire", amount = 30 },
		{ type = "item", name = "uiv-pump", amount = 1 },
		{ type = "fluid", name = "molten-transcendent-metal", amount = 144 },
		{ type = "fluid", name = "cryogenic-helium", amount = 3400 },
	},
	results = {
		{ type = "item", name = "chromnorox-superconductive-wire", amount = 30 },
	}
}



--- HYPOCOSMIUM [SUPERCONDUCTOR BASE UMV]
create_recipe{
	recipe_name = "molten-hypocosmium-exotic",
	category = "ec-dtpf-recipes",
	energy_required = 94.75 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-spacetime", amount = 777.6 },
		{ type = "fluid", name = "molten-orundum", amount = 388.8 },
		{ type = "fluid", name = "molten-hypogen", amount = 1425.6 },
		{ type = "fluid", name = "molten-titansteel", amount = 648 },
		{ type = "fluid", name = "molten-dragonblood", amount = 159.2 },
		{ type = "fluid", name = "oxygen-plasma", amount = 129.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 7712.7 },
	},
	results = {
		{ type = "fluid", name = "molten-hypocosmium", amount = 3499.2 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 7712.7 },
	}
}
create_recipe{
	name = "molten-hypocosmium-stellar",
	category = "ec-dtpf-recipes",
	energy_required = 47.35 * UXV_SPEED,
	ingredients = {
		{ type = "fluid", name = "molten-spacetime", amount = 1555.2 },
		{ type = "fluid", name = "molten-orundum", amount = 777.6 },
		{ type = "fluid", name = "molten-hypogen", amount = 2851.2 },
		{ type = "fluid", name = "molten-titansteel", amount = 1296 },
		{ type = "fluid", name = "molten-dragonblood", amount = 518.4 },
		{ type = "fluid", name = "oxygen-plasma", amount = 259.2 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 3409.3 },
	},
	results = {
		{ type = "fluid", name = "molten-hypocosmium", amount = 6998.4 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 6818.6 },
	}
}
create_item{
	name = "hypocosmium-ingot",
	category = "uev-fluid-solidifier-recipes",
	energy_required = UEV_SPEED * 1.6,
	ingredients = {
		{ type = "fluid", name = "molten-hypocosmium", amount = 14.4 },
	}
}
create_item{
	name = "hypocosmium-wire",
	category = "uev-wiremill-recipes",
	energy_required = UEV_SPEED * 5,
	ingredients = {
		{ type = "item", name = "hypocosmium-ingot", amount = 1 },
	},
	results = {
		{ type = "item", name = "hypocosmium-wire", amount = 2 },
	}
}
create_item{
	name = "hypocosmium-superconductive-wire",
	category = "umv-assembling-machine-recipes",
	energy_required = UMV_SPEED * 160,
	ingredients = {
		{ type = "item", name = "hypocosmium-wire", amount = 33 },
		{ type = "item", name = "umv-pump", amount = 1 },
		{ type = "fluid", name = "molten-spacetime", amount = 165.6 },
	},
	results = {
		{ type = "item", name = "hypocosmium-superconductive-wire", amount = 33 },
	}
}



































---CENTRAL GRAVITATION FLOW MODULATOR (+theres another inefficient recipe)
create_item{
	name = "central-gravitation-flow-modulator",
	category = "godforge-recipes",
	energy_required = 1,
	ingredients = {
		{ type = "item", name = "white-dwarf-matter-frame", amount = 64 },
		{ type = "item", name = "black-dwarf-matter-frame", amount = 64 },
		{ type = "item", name = "eternity-frame", amount = 16 },
		{ type = "item", name = "universium-frame", amount = 2 },
		{ type = "item", name = "infinite-spacetime-energy-boundary-casing", amount = 64 },
		{ type = "item", name = "exotic-stabilisation-field-generator", amount = 16 },
		{ type = "item", name = "mega-ultimate-battery", amount = 6 },
		{ type = "item", name = "umv-field-generator", amount = 64 },
	}
}




---ASTRAL ARRAY FABRICATOR
create_item{
	name = "astral-array-fabricator",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "white-dwarf-matter-frame", amount = 8 },
		{ type = "item", name = "black-dwarf-matter-frame", amount = 8 },
		{ type = "item", name = "energized-tesseract", amount = 32 },
		{ type = "item", name = "eternity-nanites", amount = 16 },
		{ type = "item", name = "gallifreyan-spacetime-compression-field-generator", amount = 138 },
		{ type = "item", name = "gallifreyan-time-dialation-field-generator", amount = 168 },
		{ type = "item", name = "infinite-spacetime-energy-boundary-casing", amount = 32 },
		{ type = "item", name = "reinforced-spacial-structure-casing", amount = 64 },
		{ type = "item", name = "reinforced-temporal-structure-casing", amount = 64 },
		{ type = "item", name = "umv-field-generator", amount = 16 },
		{ type = "item", name = "mega-ultimate-battery", amount = 6 },
		{ type = "item", name = "umv-field-generator", amount = 64 },
		{ type = "item", name = "umv-superconductor-wire-16x", amount = 64 },
		{ type = "fluid", name = "spacially-enlarged-fluid", amount = 209715.2 },
		{ type = "fluid", name = "molten-eternity", amount = 104857.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 52428.8 },
	}
}



---ARTIFICIAL UNIVERSE ME STORAGE CELL
create_item{
	name = "artificial-universe-me-storage-cell",
	category = "space-assembler-mk3-recipes",
	energy_required = UXV_SPEED * 60,
	ingredients = {
		{ type = "item", name = "digital-singularity-me-storage-cell", amount = 1 },
		{ type = "item", name = "dense-transcendent-metal-plate", amount = 64 },
		{ type = "item", name = "uxv-field-generator", amount = 1 },
		{ type = "item", name = "mega-ultimate-battery", amount = 8 },
		{ type = "item", name = "gallifreyan-spacetime-compression-field-generator", amount = 4 },
		{ type = "item", name = "magmatter-nanites", amount = 4 },
		{ type = "item", name = "eternity-nanites", amount = 4 },
		{ type = "fluid", name = "molten-eternity", amount = 3686.4 },
	}
}




---SPACE ASSEMBLER MK3
create_item{
	name = "space-assembler-mk3",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 120,
	ingredients = {
		{ type = "item", name = "space-elevator-base-casing", amount = 1 },
--		UMV ASSEMBLER
--		UMV CIRCUIT ASSEMBLER
		{ type = "item", name = "large-mhdc-star-matter-gear", amount = 8 },
		{ type = "item", name = "large-magmatter-gear", amount = 8 },
		{ type = "item", name = "mhdc-star-matter-gear", amount = 16 },
		{ type = "item", name = "magmatter-gear", amount = 16 },
		{ type = "item", name = "uxv-robot-arm", amount = 8 },
		{ type = "item", name = "uxv-conveyor-module", amount = 16 },
		{ type = "item", name = "hi-computation-station-mkv-final-type", amount = 32 },
		{ type = "item", name = "quantum-circuit", amount = 16 },
		{ type = "item", name = "universium-frame", amount = 8 },
		{ type = "item", name = "universium-screw", amount = 32 },	
		{ type = "fluid", name = "mutated-living-solder", amount = 518.4 },
		{ type = "fluid", name = "molten-black-dwarf-matter", amount = 129.6 },
		{ type = "fluid", name = "molten-white-dwarf-matter", amount = 129.6 },
		{ type = "fluid", name = "molten-spacetime", amount = 129.6 },
	}
}



---COMPACT FUSION COIL MK2 FINALTYPE
create_item{
	name = "compact-fusion-coil-mk2-finaltype",
	category = "uhv-precise-assembler-recipes",
	energy_required = UHV_SPEED * 100,
	ingredients = {
		{ type = "item", name = "advanced-fusion-coil-ii", amount = 3 },
		{ type = "item", name = "uev-circuit", amount = 3 },
		{ type = "item", name = "hi-computation-station-mkv-final-type", amount = 4 },
		{ type = "item", name = "iv-energy-core", amount = 1 },
		{ type = "fluid", name = "molten-black-titanium", amount = 115.2 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 57.6 },
	}
}



---RIDICULOUSLY LARGE CAPACITOR
create_item{
	name = "ridiculously-large-capacitor",
	category = "ultimate-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "uxv-emitter", amount = 2 },
		{ type = "item", name = "stargate-radiation-containment-plate", amount = 12 },
		{ type = "item", name = "uxv-field-generator", amount = 4 },
		{ type = "item", name = "mega-ultimate-battery", amount = 3 },
		{ type = "item", name = "chaotic-capacitor-bank", amount = 6 },
		{ type = "item", name = "stellar-energy-siphon-casing", amount = 4 },
	}
}



---GIGACHAD TOKEN
create_item{
	name = "gigachad-token",
	category = "ec-dtpf-recipes",
	energy_required = UXV_SPEED * 172800,
	ingredients = {
		{ type = "item", name = "uev-field-generator", amount = 64 },
		{ type = "item", name = "uiv-field-generator", amount = 64 },
		{ type = "item", name = "umv-field-generator", amount = 64 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 10000000 },
		{ type = "fluid", name = "molten-spacetime", amount = 16588.8 },
	}
}




---EXCITED DIMENSIONALLY TRANSCENDANT EXOTIC CATALYST
create_recipe{
	recipe_name = "excited-dimensionally-transcendent-exotic-catalyst",
	category = "uxv-transcendent-plasma-mixer-recipes",
	energy_required = UXV_SPEED * 5,
	ingredients = {
		{ type = "fluid", name = "helium-plasma", amount = 100 },
		{ type = "fluid", name = "iron-plasma", amount = 100 },
		{ type = "fluid", name = "calcium-plasma", amount = 100 },
		{ type = "fluid", name = "niobium-plasma", amount = 100 },
		{ type = "fluid", name = "radon-plasma", amount = 100 },
		{ type = "fluid", name = "nickel-plasma", amount = 100 },
		{ type = "fluid", name = "boron-plasma", amount = 100 },
		{ type = "fluid", name = "silver-plasma", amount = 100 },
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


---CREON PLASMA
create_recipe{
	recipe_name = "creon-plasma",
	category = "transcendent-plasma-mixer-recipes",
	energy_required = UXV_SPEED * 5,
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



---MELLION DUST
create_item{
	name = "mellion-dust",
	category = "umv-mixer-recipes",
	energy_required = UMV_SPEED * 15,
	ingredients = {
		{ type = "item", name = "rubidium-dust", amount = 11 },
		{ type = "item", name = "tritanium-dust", amount = 11 },
		{ type = "item", name = "fiery-steel-dust", amount = 11 },
		{ type = "item", name = "firestone-dust", amount = 13 },
		{ type = "item", name = "atomic-separation-catalyst-dust", amount = 13 },
		{ type = "item", name = "orundum-dust", amount = 8 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 500 },
    },
	results = {
		{ type = "item", name = "mellion-dust", amount = 63 },
	}
}



---MOLTON MELLION
create_recipe{
	recipe_name = "molten-mellion",
	category = "helioflux-melting-core",
	energy_required = UXV_SPEED * 21.4,
	ingredients = {
		{ type = "item", name = "mellion-dust", amount = 1 },
		{ type = "fluid", name = "oganesson", amount = 10 },
    },
	results = {
		{ type = "fluid", name = "molten-mellion", amount = 14.4 },
	}
}



---MOLTON MELLION
create_recipe{
	recipe_name = "molten-mellion",
	category = "helioflux-melting-core",
	energy_required = UXV_SPEED * 21.4,
	ingredients = {
		{ type = "item", name = "mellion-dust", amount = 1 },
		{ type = "fluid", name = "oganesson", amount = 10 },
    },
	results = {
		{ type = "fluid", name = "molten-mellion", amount = 14.4 },
	}
}



---------------------
---   BATTERIES   ---
---------------------

---MEGA ULTIMATE BATTERY
create_item{
	name = "mega-ultimate-battery",
	category = "umv-assembly-line-recipes",
	energy_required = UMV_SPEED * 350,
	ingredients = {
		{ type = "item", name = "dragonblood-plate", amount = 128 },
		{ type = "item", name = "quantum-circuit", amount = 4 },
		{ type = "item", name = "insanely-ultimate-battery", amount = 8 },
		{ type = "item", name = "umv-field-generator", amount = 4 },
		{ type = "item", name = "qpic-wafer", amount = 128 },
		{ type = "item", name = "pico-wafer", amount = 64 },
		{ type = "item", name = "optical-smd-diode", amount = 64 },
		{ type = "item", name = "optical-smd-inductor", amount = 64 },
		{ type = "item", name = "hypocosmium-superconductive-wire-16x", amount = 64 },
		{ type = "fluid", name = "mutated-living-solder", amount = 3686.4 },
		{ type = "fluid", name = "astral-titanium", amount = 3686.4 },
		{ type = "fluid", name = "celestial-tungsten", amount = 3686.4 },
		{ type = "fluid", name = "super-coolant", amount = 25600 },
	}
}



---INSANELY ULTIMATE BATTERY
create_item{
	name = "insanely-ultimate-battery",
	category = "uev-assembly-line-recipes",
	energy_required = UIV_SPEED * 300,
	ingredients = {
		{ type = "item", name = "hypogen-plate", amount = 128 },
		{ type = "item", name = "pico-circuit", amount = 4 },
		{ type = "item", name = "extremely-ultimate-battery", amount = 8 },
		{ type = "item", name = "uiv-field-generator", amount = 4 },
		{ type = "item", name = "qpic-wafer", amount = 128 },
		{ type = "item", name = "raw-pico-wafer", amount = 64 },
		{ type = "item", name = "optical-smd-diode", amount = 64 },
		{ type = "item", name = "optical-smd-inductor", amount = 32 },
		{ type = "item", name = "hypocosmium-superconductive-wire-16x", amount = 32 },
		{ type = "fluid", name = "mutated-living-solder", amount = 921.6 },
		{ type = "fluid", name = "molten-quantium", amount = 1843.2 },
		{ type = "fluid", name = "molten-naquadria", amount = 1843.2 },
		{ type = "fluid", name = "lapis-coolant", amount = 6400 },
    }
}



---EXTREMELY ULTIMATE BATTERY
create_item{
	name = "extremely-ultimate-battery",
	category = "uev-assembly-line-recipes",
	energy_required = UEV_SPEED * 250,
	ingredients = {
		{ type = "item", name = "infinity-catalyst-plate", amount = 128 },
		{ type = "item", name = "optical-mainframe", amount = 4 },
		{ type = "item", name = "really-ultimate-battery", amount = 8 },
		{ type = "item", name = "uev-field-generator", amount = 4 },
		{ type = "item", name = "ppic-wafer", amount = 128 },
		{ type = "item", name = "asoc-wafer", amount = 64 },
		{ type = "item", name = "optical-smd-diode", amount = 64 },
		{ type = "item", name = "dracofinium-superconductive-wire-16x", amount = 16 },
		{ type = "fluid", name = "mutated-living-solder", amount = 921.6 },
		{ type = "fluid", name = "molten-quantium", amount = 1843.2 },
		{ type = "fluid", name = "molten-naquadria", amount = 1843.2 },
		{ type = "fluid", name = "lapis-coolant", amount = 6400 },
    }
}




--------------------------
---   EYE OF HARMONY   ---
--------------------------

create_item{
	name = "eye-of-harmony-controller",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 24000,
	ingredients = {
		{ type = "item", name = "space-elevator-controller", amount = 16 },
		{ type = "item", name = "godforge-controller", amount = 4 },
		{ type = "item", name = "dtpf-controller", amount = 4 },
		{ type = "item", name = "infinite-spacetime-energy-boundary-casing", amount = 1 },
		{ type = "item", name = "crude-time-dialation-field-generator", amount = 1 },
		{ type = "item", name = "crude-spacetime-compression-field-generator", amount = 1 },
		{ type = "item", name = "crude-stabilisation-field-generator", amount = 1 },
		{ type = "item", name = "quantum-computer-controller", amount = 64 },
		{ type = "item", name = "ultimate-time-anomaly", amount = 64 },
		{ type = "item", name = "quantum-chest-v", amount = 64 },
--		{ type = "item", name = "void-miner-iii", amount = 64 },
--		{ type = "item", name = "infinite-drilling-rig", amount = 64 },
		{ type = "item", name = "umv-superconductor-wire-16x", amount = 64 },
		{ type = "fluid", name = "tachyon-rich-temporal-fluid", amount = 14400 },
		{ type = "fluid", name = "spacially-enlarged-fluid", amount = 14400 },
		{ type = "fluid", name = "molten-metastable-oganesson", amount = 14745.6 },
		{ type = "fluid", name = "molten-shirabon", amount = 14745.6 },
	}
}









--------------------
---   STARGATE   ---
--------------------

create_item{
	name = "stargate",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
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



---STARGATE RING BLOCK
create_item{
	name = "stargate-ring-block",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 18 },
		{ type = "item", name = "dark-matter", amount = 9 },
		{ type = "item", name = "stargate-frame-part", amount = 21 },
		{ type = "item", name = "stargate-chevron", amount = 3 },
		{ type = "item", name = "stargate-radiation-containment-plate", amount = 11 },
		{ type = "item", name = "uxv-field-generator", amount = 9 },
    }
}



---STARGATE CHEVRON BLOCK
create_item{
	name = "stargate-chevron-block",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 16 },
		{ type = "item", name = "dark-matter", amount = 11 },
		{ type = "item", name = "central-gravitation-flow-modulator", amount = 4 },
		{ type = "item", name = "stargate-chevron-upgrade", amount = 4 },
		{ type = "item", name = "uxv-field-generator", amount = 4 },
		{ type = "item", name = "stargate-ring-block", amount = 1 },
    }
}



---STARGATE BASE
create_item{
	name = "stargate-base",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "transdimensional-alignment-matrix", amount = 4 },
		{ type = "item", name = "uxv-field-generator", amount = 16 },
		{ type = "item", name = "uxv-emitter", amount = 8 },
		{ type = "item", name = "magmatter-nanites", amount = 4 },
		{ type = "item", name = "central-gravitation-flow-modulator", amount = 8 },
		{ type = "item", name = "superdense-magmatter-plate", amount = 4 },
		{ type = "item", name = "stargate-radiation-containment-plate", amount = 8 },
		{ type = "item", name = "mining-drone-mk13", amount = 2 },
		{ type = "item", name = "mega-ultimate-battery", amount = 4 },
		{ type = "item", name = "astral-array-fabricator", amount = 6 },
		{ type = "item", name = "artificial-universe-me-storage-cell", amount = 2 },
		{ type = "item", name = "eye-of-harmony-controller", amount = 4 },
		{ type = "item", name = "space-assembler-module-mk3", amount = 4 },
		{ type = "item", name = "stargate-core-crystal", amount = 1 },
    }
}



---STARGATE POWER UNIT
create_item{
	name = "stargate-power-unit",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 18 },
		{ type = "item", name = "compact-fusion-coil-mk2-finaltype", amount = 10 },
		{ type = "item", name = "dark-matter", amount = 12 },
		{ type = "item", name = "mega-ultimate-battery", amount = 4 },
		{ type = "item", name = "ridiculously-large-capacitor", amount = 4 },
		{ type = "item", name = "stargate-ring-block", amount = 1 },
		{ type = "item", name = "magmatter-nanites", amount = 6 },
		{ type = "item", name = "gigachad-token", amount = 2 },
    }
}




---STARGATE CONTROLLER
create_item{
	name = "stargate-controller",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 15 },
		{ type = "item", name = "stargate-frame-part", amount = 8 },
		{ type = "item", name = "uxv-sensor", amount = 2 },
		{ type = "item", name = "uxv-emitter", amount = 2 },
		{ type = "item", name = "keyboard", amount = 8 },
		{ type = "item", name = "stargate-controller-crystal", amount = 1 },
		{ type = "item", name = "stargate-radiation-containment-plate", amount = 8 },
		{ type = "item", name = "mega-ultimate-battery", amount = 1 },
		{ type = "item", name = "opencomputers-stargate-interface", amount = 1 },
		{ type = "item", name = "astral-array-fabricator", amount = 6 },
		{ type = "item", name = "artificial-universe-me-storage-cell", amount = 1 },
    }
}



---STARGATE CHEVRON UPGRADE
create_item{
	name = "stargate-chevron-upgrade",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "stargate-frame-part", amount = 13 },
		{ type = "item", name = "uxv-sensor", amount = 2 },
		{ type = "item", name = "uxv-emitter", amount = 2 },
		{ type = "item", name = "uxv-field-generator", amount = 4 },
		{ type = "item", name = "uxv-piston", amount = 6 },
		{ type = "item", name = "stargate-chevron", amount = 4 },
    }
}



---STARGATE IRIS UPGRADE
create_item{
	name = "stargate-iris-upgrade",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "dark-matter", amount = 12 },
		{ type = "item", name = "stargate-iris-blade", amount = 24 },
		{ type = "item", name = "superdense-magmatter-plate", amount = 1 },
		{ type = "item", name = "magmatter-nanites", amount = 12 },
    }
}



---DARK MATTER
create_item{
	name = "dark-matter",
	category = "hc-dtpf-recipes",
	energy_required = UMV_SPEED * 80,
	ingredients = {
		{ type = "item", name = "block-of-transcendent-metal", amount = 16 },
		{ type = "item", name = "star-fuel", amount = 16 },
		{ type = "item", name = "higgs-boson", amount = 1 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 179769.3 },
		{ type = "fluid", name = "molten-cosmic-neutronium", amount = 235929.6 },
		{ type = "fluid", name = "molten-tairitsu", amount = 235929.6 },
		{ type = "fluid", name = "molten-celestial-tungsten", amount = 58982.4 },
	},
	results = {
		{ type = "item", name = "dark-matter", amount = 1 },
		{ type = "item", name = "higgs-boson", amount = 1 },
		{ type = "fluid", name = "dimensionally-transcendent-residue", amount = 179769.3 },
	},
	main_product = "dark-matter"
}



---STARGATE FRAME PART
create_item{
	name = "stargate-frame-part",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 125000,
	ingredients = {
		{ type = "item", name = "long-infinity-rod", amount = 64 },
		{ type = "item", name = "long-mellion-rod", amount = 64 },
		{ type = "item", name = "long-universium-rod", amount = 64 },
		{ type = "item", name = "long-eternity-rod", amount = 64 },
		{ type = "item", name = "long-creon-rod", amount = 64 },
		{ type = "item", name = "long-spacetime-rod", amount = 64 },
		{ type = "item", name = "long-superconductor-base-umv-rod", amount = 64 },
		{ type = "item", name = "long-shirabon-rod", amount = 64 },
		{ type = "item", name = "long-hypogen-rod", amount = 64 },
		{ type = "item", name = "long-six-phased-copper-rod", amount = 64 },
		{ type = "item", name = "long-mhdc-star-matter-rod", amount = 64 },
		{ type = "item", name = "long-proto-halkonite-steel-rod", amount = 64 },
		{ type = "item", name = "long-white-dwarf-matter-rod", amount = 64 },
		{ type = "item", name = "long-black-dwarf-matter-rod", amount = 64 },
		{ type = "item", name = "long-magmatter-rod", amount = 64 },
		{ type = "item", name = "long-transcendent-metal-rod", amount = 64 },
		{ type = "fluid", name = "degenerate-quark-gluon-plamsa", amount = 102400 },
		{ type = "fluid", name = "lossless-phonon-transfer-medium", amount = 25600 },
		{ type = "fluid", name = "molten-universium", amount = 14745.6 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 51200 },
	}
}



---STARGATE CHEVRON
create_item{
	name = "stargate-chevron",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 125000,
	ingredients = {
		{ type = "item", name = "reinforced-spacial-structure-casing", amount = 64 },
		{ type = "item", name = "reinforced-temporal-structure-casing", amount = 64 },
		{ type = "item", name = "spacially-transcendent-gravitational-lens-block", amount = 64 },
		{ type = "item", name = "block-of-magmatter", amount = 64 },
		{ type = "item", name = "magmatter-frame", amount = 16 },
		{ type = "item", name = "superdense-magmatter-plate", amount = 8 },
		{ type = "item", name = "superdense-mhdc-star-matter-plate", amount = 8 },
		{ type = "item", name = "mhdc-star-matter-frame", amount = 16 },
		{ type = "item", name = "exquisite-ruby", amount = 64 },
		{ type = "item", name = "exquisite-jasper", amount = 64 },
		{ type = "item", name = "exquisite-opal", amount = 64 },
		{ type = "item", name = "exquisite-sapphire", amount = 64 },
		{ type = "item", name = "uxv-motor", amount = 64 },
		{ type = "item", name = "uxv-piston", amount = 64 },
		{ type = "item", name = "uxv-field-generator", amount = 16 },
		{ type = "item", name = "quantum-circuit", amount = 32 },
		{ type = "fluid", name = "degenerate-quark-gluon-plamsa", amount = 102400 },
		{ type = "fluid", name = "lossless-phonon-transfer-medium", amount = 25600 },
		{ type = "fluid", name = "molten-magmatter", amount = 117964.8 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 51200 },
	}
}



---STARGATE RADIATION CONTAINMENT PLATE
create_item{
	name = "stargate-radiation-containment-plate",
	category = "uxv-assembly-line-recipes",
	energy_required = UXV_SPEED * 125000,
	ingredients = {
		{ type = "item", name = "transcendent-amplified-magnetic-confinement-casing", amount = 64 },
		{ type = "item", name = "gallifreyan-stabilisation-field-generator", amount = 64 },
		{ type = "item", name = "harmonic-phonon-transmission-conduit", amount = 32 },
		{ type = "item", name = "block-of-magmatter", amount = 64 },
		{ type = "item", name = "superdense-magmatter-plate", amount = 8 },
		{ type = "item", name = "superdense-universium-plate", amount = 8 },
		{ type = "item", name = "superdense-eternity-plate", amount = 8 },
		{ type = "item", name = "superdense-spacetime-plate", amount = 8 },
		{ type = "item", name = "quantum-circuit", amount = 16 },
		{ type = "item", name = "uxv-sensor", amount = 16 },
		{ type = "item", name = "uxv-emitter", amount = 16 },
		{ type = "item", name = "chronic-singularity", amount = 64 },
		{ type = "item", name = "universium-nanites", amount = 16 },
		{ type = "item", name = "black-dwarf-matter-nanites", amount = 16 },
		{ type = "item", name = "white-dwarf-matter-nanites", amount = 16 },
		{ type = "item", name = "six-phased-copper-nanites", amount = 16 },
		{ type = "fluid", name = "degenerate-quark-gluon-plamsa", amount = 102400 },
		{ type = "fluid", name = "lossless-phonon-transfer-medium", amount = 25600 },
		{ type = "fluid", name = "molten-umv-superconductor-base", amount = 58982.4 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 51200 },
	}
}



---STARGATE CORE CRYSTAL
create_item{
	name = "stargate-core-crystal",
	category = "uxv-electric-blast-furnace-recipes",
	energy_required = UXV_SPEED * 1209600,
	ingredients = {
		{ type = "item", name = "stargate-crystal-dust", amount = 64 },
		{ type = "fluid", name = "stargate-crystal-slurry", amount = 12800000 },
	}
}



---STARGATE CONTROLLER CRYSTAL
create_item{
	name = "stargate-controller-crystal",
	category = "uxv-electric-blast-furnace-recipes",
	energy_required = UXV_SPEED * 1209600,
	ingredients = {
		{ type = "item", name = "stargate-crystal-dust", amount = 64 },
		{ type = "fluid", name = "molten-mhdc-star-matter", amount = 12800000 },
	}
}



---STARGATE INTERFACE
create_item{
	name = "stargate-interface",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "block-of-magmatter", amount = 18 },
		{ type = "item", name = "compact-fusion-coil-mk2-finaltype", amount = 10 },
		{ type = "item", name = "dark-matter", amount = 12 },
		{ type = "item", name = "cloud-computation-client-hatch", amount = 4 },
		{ type = "item", name = "singularity-crafting-storage", amount = 4 },
		{ type = "item", name = "stargate-ring-block", amount = 1 },
		{ type = "item", name = "magmatter-nanites", amount = 6 },
		{ type = "item", name = "gigachad-token", amount = 2 },
    }
}



---STARGATE IRIS BLADE
create_item{
	name = "stargate-iris-blade",
	category = "ultimate-extended-crafting-recipes",
    subgroup = "subgroup-stargate",
	ingredients = {
		{ type = "item", name = "superdense-white-dwarf-matter-plate", amount = 26 },
		{ type = "item", name = "superdense-magmatter-plate", amount = 19 },
		{ type = "item", name = "compact-fusion-coil-mk2-finaltype", amount = 1 },
		{ type = "item", name = "mega-ultimate-battery", amount = 1 },
		{ type = "item", name = "uxv-piston", amount = 4 },
    }
}



---STARGATE CRYSTAL DUST
create_item{
	name = "stargate-crystal-dust",
	category = "uxv-mixer-recipes",
	energy_required = UXV_SPEED * 180,
	ingredients = {
		{ type = "item", name = "hyper-stable-self-healing-adhesive", amount = 64 },
		{ type = "item", name = "superconductor-rare-earth-composite", amount = 64 },
		{ type = "item", name = "black-body-naquadria-supersolid", amount = 64 },
		{ type = "item", name = "timepiece", amount = 64 },
		{ type = "item", name = "z-boson", amount = 64 },
		{ type = "item", name = "eta-mason", amount = 64 },
		{ type = "item", name = "lambda", amount = 64 },
		{ type = "item", name = "omega", amount = 64 },
		{ type = "item", name = "graviton-shard", amount = 64 },
		{ type = "fluid", name = "grade-8-water", amount = 100000000 },
	}
}


---STARGATE CRYSTAL SLURRY
create_recipe{
	recipe_name = "stargate-crystal-slurry",
	category = "uxv-mixer-recipes",
	energy_required = UXV_SPEED * 180,
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
		{ type = "fluid", name = "excited-dimensionally-transcendent-crude-catalyst", amount = 100 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-prosaic-catalyst", amount = 100 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-resplendent-catalyst", amount = 100 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-exotic-catalyst", amount = 100 },
		{ type = "fluid", name = "excited-dimensionally-transcendent-stellar-catalyst", amount = 100 },
	},
	results = {
		{ type = "fluid", name = "stargate-crystal-slurry", amount = 100 },
	}
}

