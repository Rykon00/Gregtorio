
-----------------------
--- CREATING INGOTS ---
-----------------------

--- MATERIAL, DUST TIER, DUST SPEED, DUST INGREDIENTS, DUST COUNT, EBF TIER, EBF SPEED, INERT GAS, FREEZER TIER, FREEZER SPEED, CRYO HELIUM, MAKE EBF, MAKE ABS, ABS SPEED, MAKE FREEZER, MAKE FLUID SOLIDIFY
	
---NICKEL ZINC FERRITE INGOT (Dust, EBF, ABS and Fluid Solidifier)
create_ingot("nickel-zinc-ferrite", "mv", MV_SPEED * 10, {
		{ type = "item", name = "iron-dust", amount = 4 },
		{ type = "item", name = "nickel-dust", amount = 1 },
		{ type = "item", name = "zinc-dust", amount = 1 }
    },
	6, "mv", MV_SPEED * 20, {type = "fluid", name = "oxygen", amount = 200},
	"lv", 0.8, false, true, true, nil, false, true )


---MICROVERSIUM INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("microversium", "lv", LV_SPEED * 30, {
	  {type = "item", name = "steel-dust", amount = 2},
      {type = "item", name = "glowstone-dust", amount = 1},
      {type = "item", name = "redstone-dust", amount = 1},	
      {type = "fluid", name = "deuterium", amount = 100}
    },
	5, "mv", MV_SPEED * 30, nil,
	"mv", MV_SPEED * 6.5, false, true, true, nil, true, false )
	
	
---BLACK STEEL INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("black-steel", "lv", LV_SPEED * 25, {
			{ type = "item", name = "steel-dust", amount = 3 },
			{ type = "item", name = "black-bronze-dust", amount = 1 },
			{ type = "item", name = "nickel-dust", amount = 1 }
    },
	5, "mv", MV_SPEED * 50, {type = "fluid", name = "oxygen", amount = 100},
	"mv", MV_SPEED * 9.6, false, true, false, nil, true, false )	
	

---VANADIUM STEEL INGOT (Dust, EBF, ABS and Fluid Solidifier)
create_ingot("vanadium-steel", "lv", LV_SPEED * 5, {
		{ type = "item", name = "steel-dust", amount = 7 },
		{ type = "item", name = "vanadium-dust", amount = 1 },
		{ type = "item", name = "chromium-dust", amount = 1 }
    },
	9, "mv", MV_SPEED * 53.5, {type = "fluid", name = "nitrogen", amount = 100},
	"mv", MV_SPEED * 1.2, false, true, true, nil, false, true )


---CHROMIUM INGOT (EBF only)
create_ingot("chromium", nil, nil, nil, nil,
	"mv", 59.2 * MV_SPEED, {type = "fluid", name = "nitrogen", amount = 100},
	nil, nil, false, true, false, nil, false, false )	
	

---BLUE STEEL INGOT (Dust, EBF and Freezer)
create_ingot("blue-steel", "lv", LV_SPEED * 40, {
			{ type = "item", name = "black-steel-dust", amount = 4 },
			{ type = "item", name = "steel-dust", amount = 2 },
			{ type = "item", name = "brass-dust", amount = 1 },
			{ type = "item", name = "rose-gold-dust", amount = 1 },
    },
	8, "mv", MV_SPEED * 60, {type = "fluid", name = "oxygen", amount = 100},
	"mv", MV_SPEED * 10.35, false, true, false, nil, false, false )

		
---TANTALUM INGOT (EBF only)
create_ingot("tantalum", nil, nil, nil, nil,
	"mv", MV_SPEED * 60, {type = "fluid", name = "nitrogen", amount = 100},
	"hv", HV_SPEED * 13, false, true, false, nil, true, false )	
	
	
---KANTHAL INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("kanthal", "mv", MV_SPEED * 15, {
		{ type = "item", name = "iron-dust", amount = 1 },
		{ type = "item", name = "aluminium-dust", amount = 1 },
		{ type = "item", name = "chromium-dust", amount = 1 }
    },
	3, "mv", MV_SPEED * 60.3, {type = "fluid", name = "nitrogen", amount = 100},
	"lv", 1.6, false, true, true, nil, false, true )	
	

---STAINLESS STEEL INGOT (Dust, EBF, ABS and Fluid Solidifier)
create_ingot("stainless-steel", "mv", MV_SPEED * 45, {
		{ type = "item", name = "iron-dust", amount = 6 },
		{ type = "item", name = "manganese-dust", amount = 1 },
		{ type = "item", name = "nickel-dust", amount = 1 },
		{ type = "item", name = "chromium-dust", amount = 1 }
    },
	9, "mv", MV_SPEED * 73.7, {type = "fluid", name = "oxygen", amount = 100},
	"lv", 1.6, false, true, true, nil, false, true )	
	
	
---NEODYMIUM INGOT (EBF and Freezer)
create_ingot("neodymium", nil, nil, nil, nil,
	"hv", HV_SPEED * 62.5, {type = "fluid", name = "helium", amount = 10},
	nil, nil, false, true, false, nil, false, false )
	
	
--- TITANIUM INGOT (nonstandard recipe)
	
	
---TUNGSTENSTEEL INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("tungstensteel", "ev", EV_SPEED * 10, {
			{ type = "item", name = "tungsten-dust", amount = 1 },
			{ type = "item", name = "steel-dust", amount = 1 },
    },
	2, "ev", EV_SPEED * 33.5, {type = "fluid", name = "helium", amount = 10},
	"hv", HV_SPEED * 17.85, false, true, true, nil, true, false )	
	
	
---STABALLOY INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("staballoy", "hv", HV_SPEED * 14.3, {
			{ type = "item", name = "uranium-238-dust", amount = 9 },
			{ type = "item", name = "titanium-dust", amount = 1 },
    },
	10, "hv", HV_SPEED * 37.5, {type = "fluid", name = "helium", amount = 10},
	"hv", HV_SPEED * 21.45, false, true, true, nil, true, false )	
	
	
---NICHROME INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("nichrome", "hv", HV_SPEED * 25, {
		{ type = "item", name = "nickel-dust", amount = 4 },
		{ type = "item", name = "chromium-dust", amount = 1 }
    },
	5, "hv", HV_SPEED * 87.1, {type = "fluid", name = "nitrogen", amount = 100},
	"hv", HV_SPEED * 8.4, false, true, true, nil, true, false )	
	
	
---RTM ALLOY INGOT (Dust, EBF and Freezer, ABS and Freezer)
create_ingot("rtm-alloy", "ev", EV_SPEED * 15, {
			{ type = "item", name = "ruthenium-dust", amount = 4 },
			{ type = "item", name = "tungsten-dust", amount = 2 },
			{ type = "item", name = "molybdenum-dust", amount = 1 },
    },
	7, "ev", EV_SPEED * 46.9, {type = "fluid", name = "oxygen", amount = 100},
	"hv", HV_SPEED * 12.5, false, true, true, nil, true, false )
	
	
---TITANIUM INGOT (EBF and Freezer)
create_ingot("titanium", nil, nil, nil, nil,
	"hv", HV_SPEED * 62.5, {type = "fluid", name = "helium", amount = 10},
	"hv", HV_SPEED * 15, false, true, false, nil, true, false )
		
	
---TUNGSTEN INGOT (EBF and Freezer)
create_ingot("tungsten", nil, nil, nil, nil,
	"ev", EV_SPEED * 60.3, {type = "fluid", name = "helium", amount = 10},
	"hv", HV_SPEED * 15, false, true, false, nil, true, false )			

	
---IRIDIUM INGOT (EBF and Freezer)
create_ingot("iridium", nil, nil, nil, nil,
	"iv", IV_SPEED * 36.85, {type = "fluid", name = "argon", amount = 5},
	"ev", EV_SPEED * 12.5, false, true, false, nil, true, false )	

	
---VANADIUM GALLIUM INGOT (ABS and Freezer)
create_ingot("vanadium-gallium", nil, nil, {
		{ type = "item", name = "vanadium-dust", amount = 3 },
		{ type = "item", name = "gallium", amount = 1 },
    },
	4, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", MV_SPEED * 8.25, false, false, true, EV_SPEED * 120.6, true, false )
	
	
---INDOVANADIUM INGOT (ABS and Freezer)
create_ingot("indovanadium", nil, nil, {
		{ type = "item", name = "indium", amount = 1 },
		{ type = "item", name = "vanadium-dust", amount = 3 },
    },
	4, "ev", nil, {type = "fluid", name = "helium", amount = 10},
	"hv", HV_SPEED * 12.5, false, false, true, EV_SPEED * 120, true, false )

	
---OSMIUM INGOT (EBF and Freezer)
create_ingot("osmium", nil, nil, nil, nil,
	"luv", LUV_SPEED * 33.5, {type = "fluid", name = "argon", amount = 5},
	"ev", EV_SPEED * 15, false, true, false, nil, true, false )	
	
	
---RURIDIT INGOT (ABS and Freezer)
create_ingot("ruridit", nil, nil, {
		{ type = "item", name = "ruthenium-dust", amount = 2 },
		{ type = "item", name = "iridium-dust", amount = 1 },
    },
	3, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", MV_SPEED * 19.5, false, false, true, EV_SPEED * 120.6, true, false )
	

---MARAGING STEEL 300 (ABS and Fluid Solidifier)
create_ingot("maraging-steel-300", nil, nil, {
		{ type = "item", name = "steel-dust", amount = 16 },
		{ type = "item", name = "titanium-dust", amount = 1 },
		{ type = "item", name = "aluminium-dust", amount = 1 },
		{ type = "item", name = "nickel-dust", amount = 4 },
		{ type = "item", name = "cobalt-dust", amount = 2 },
    },
	24, "mv", nil, nil,
	"mv", MV_SPEED * 1.6, false, false, true, MV_SPEED * 20, false, true )
	

---TALONITE (ABS and Fluid Solidifier)
create_ingot("talonite", nil, nil, {
		{ type = "item", name = "phosphorus", amount = 2 },
		{ type = "item", name = "molybdenum-dust", amount = 1 },
		{ type = "item", name = "chromium-dust", amount = 3 },
		{ type = "item", name = "cobalt-dust", amount = 4 },
    },
	10, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )	

	
---STELLITE (ABS and Fluid Solidifier)
create_ingot("stellite", nil, nil, {

		{ type = "item", name = "titanium-dust", amount = 2 },
		{ type = "item", name = "manganese-dust", amount = 4 },
		{ type = "item", name = "chromium-dust", amount = 7 },
		{ type = "item", name = "cobalt-dust", amount = 7 },
    },
	20, "ev", nil, nil,
	"ev", EV_SPEED * 1.6, false, false, true, EV_SPEED * 40, false, true )

	
---NITINOL-60 (ABS and Fluid Solidifier)
create_ingot("nitinol-60", nil, nil, {

		{ type = "item", name = "titanium-dust", amount = 3 },
		{ type = "item", name = "nickel-dust", amount = 2 },
    },
	5, "iv", nil, nil,
	"iv", IV_SPEED * 1.6, false, false, true, IV_SPEED * 75, false, true )
	
	
---TANTALLOY 60 INGOT (ABS and Fluid Solidifier)
create_ingot("tantalloy-60", nil, nil, {
		{ type = "item", name = "tantalum-dust", amount = 23 },
		{ type = "item", name = "tungsten-dust", amount = 2 },
    },
	25, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )
	

---INCOLOY 625 INGOT (ABS and Fluid Solidifier)
create_ingot("inconel-625", nil, nil, {
		{ type = "item", name = "chromium-dust", amount = 7 },
		{ type = "item", name = "nickel-dust", amount = 3 },
		{ type = "item", name = "invar-dust", amount = 8 },
		{ type = "item", name = "nichrome-dust", amount = 13 },
		{ type = "item", name = "molybdenum-dust", amount = 10 },
    },
	41, "mv", nil, nil,
	"mv", MV_SPEED * 1.6, false, false, true, MV_SPEED * 20, false, true )
	

---INCONEL 690 INGOT (ABS and Fluid Solidifier)
create_ingot("inconel-690", nil, nil, {
		{ type = "item", name = "chromium-dust", amount = 1 },
		{ type = "item", name = "niobium-dust", amount = 2 },
		{ type = "item", name = "nichrome-dust", amount = 3 },
		{ type = "item", name = "molybdenum-dust", amount = 2 },
    },
	8, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )		

---INCONEL 792 INGOT (ABS and Fluid Solidifier)
create_ingot("inconel-792", nil, nil, {
		{ type = "item", name = "niobium-dust", amount = 1 },
		{ type = "item", name = "nickel-dust", amount = 2 },
		{ type = "item", name = "aluminium-dust", amount = 2 },
		{ type = "item", name = "nichrome-dust", amount = 1 },
    },
	8, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )
	
	
---INCOLOY 903 INGOT (ABS and Fluid Solidifier)
create_ingot("incoloy-903", nil, nil, {
		{ type = "item", name = "iron-dust", amount = 12 },
		{ type = "item", name = "nickel-dust", amount = 10 },
		{ type = "item", name = "cobalt-dust", amount = 8 },
		{ type = "item", name = "titanium-dust", amount = 4 },
		{ type = "item", name = "molybdenum-dust", amount = 2 },
		{ type = "item", name = "aluminium-dust", amount = 1 },
    },
	37, "iv", nil, nil,
	"lv", LV_SPEED * 2.85, false, false, true, IV_SPEED * 60, false, true )
	
	
---MARAGING STEEL 250 INGOT (ABS and Fluid Solidifier)
create_ingot("maraging-steel-250", nil, nil, {
		{ type = "item", name = "steel-dust", amount = 16 },
		{ type = "item", name = "molybdenum-dust", amount = 1 },
		{ type = "item", name = "nickel-dust", amount = 4 },
		{ type = "item", name = "titanium-dust", amount = 1 },
		{ type = "item", name = "cobalt-dust", amount = 2 },
    },
	25, "mv", nil, nil,
	"mv", MV_SPEED * 1.6, false, false, true, MV_SPEED * 20, false, true )
	
	
---TANTALUM CARBIDE INGOT (ABS and Fluid Solidifier)
create_ingot("tantalum-carbide", nil, nil, {
		{ type = "item", name = "tantalum-dust", amount = 1 },
		{ type = "item", name = "carbon", amount = 1 }
    },
	2, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )
	
	
---HASTELLOY C267 INGOT (ABS and Fluid Solidifier)
create_ingot("hastelloy-c276", nil, nil, {
		{ type = "item", name = "nickel-dust", amount = 32 },
		{ type = "item", name = "molybdenum-dust", amount = 8 },
		{ type = "item", name = "chromium-dust", amount = 7 },
		{ type = "item", name = "tungsten-dust", amount = 1 },
		{ type = "item", name = "cobalt-dust", amount = 1 },
		{ type = "item", name = "copper-dust", amount = 1 },
    },
	50, "ev", nil, nil,
	"ev", EV_SPEED * 1.6, false, false, true, EV_SPEED * 40, false, true )
	
	
---HASTELLOY X INGOT (ABS and Fluid Solidifier)
create_ingot("hastelloy-x", nil, nil, {
		{ type = "item", name = "nickel-dust", amount = 24 },
		{ type = "item", name = "iron-dust", amount = 9 },
		{ type = "item", name = "molybdenum-dust", amount = 4 },
		{ type = "item", name = "chromium-dust", amount = 11 },
		{ type = "item", name = "raw-silicon", amount = 1 },
		{ type = "item", name = "manganese-dust", amount = 1 },
    },
	50, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )
	
	
---HASTELLOY W INGOT (ABS and Fluid Solidifier)
create_ingot("hastelloy-w", nil, nil, {
		{ type = "item", name = "nickel-dust", amount = 31 },
		{ type = "item", name = "molybdenum-dust", amount = 12 },
		{ type = "item", name = "chromium-dust", amount = 3 },
		{ type = "item", name = "iron-dust", amount = 3 },
		{ type = "item", name = "cobalt-dust", amount = 1 },
    },
	50, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )
	
	
---ULTIMET INGOT (ABS and Freezer)
create_ingot("ultimet", nil, nil, {
		{ type = "item", name = "nickel-dust", amount = 1 },
		{ type = "item", name = "molybdenum-dust", amount = 1 },
		{ type = "item", name = "chromium-dust", amount = 2 },
		{ type = "item", name = "cobalt-dust", amount = 5 },
    },
	9, "hv", nil, nil,
	"mv", MV_SPEED * 9.15, false, false, true, HV_SPEED * 293.95, true, false )	
	
	
---ZERON 100 INGOT
create_ingot("zeron-100", nil, nil, {
		{ type = "item", name = "iron-dust", amount = 10 },
		{ type = "item", name = "nickel-dust", amount = 2 },
		{ type = "item", name = "tungsten-dust", amount = 2 },
		{ type = "item", name = "niobium-dust", amount = 1 },
		{ type = "item", name = "cobalt-dust", amount = 1 },
    },
	16, "ev", nil, {type = "fluid", name = "helium", amount = 10},
	"mv", MV_SPEED * 11.1, false, false, true, EV_SPEED * 402, true, false )		
	
	
---INCOLOY MA956 INGOT
create_ingot("incoloy-ma956", nil, nil, {
		{ type = "item", name = "iron-dust", amount = 16 },
		{ type = "item", name = "chromium-dust", amount = 5 },
		{ type = "item", name = "aluminium-dust", amount = 3 },
		{ type = "item", name = "yttrium-dust", amount = 1 },
    },
	25, "ev", nil, nil,
	"ev", EV_SPEED * 1.6, false, false, true, EV_SPEED * 40, false, true )	
	
	
---WATERTIGHT STEEL INGOT
create_ingot("watertight-steel", nil, nil, {
		{ type = "item", name = "steel-dust", amount = 12 },
		{ type = "item", name = "carbon", amount = 2 },
		{ type = "item", name = "manganese-dust", amount = 1 },
		{ type = "item", name = "raw-silicon", amount = 2 },
		{ type = "item", name = "phosphorus", amount = 1 },
		{ type = "item", name = "aluminium-dust", amount = 1 },
		{ type = "item", name = "sulfur", amount = 1 },
    },
	20, "mv", nil, nil,
	"mv", MV_SPEED * 1.6, false, false, true, MV_SPEED * 20, false, true )
	
	
---INCOLOY 020 INGOT
create_ingot("incoloy-020", nil, nil, {
		{ type = "item", name = "iron-dust", amount = 10 },
		{ type = "item", name = "chromium-dust", amount = 5 },
		{ type = "item", name = "copper-dust", amount = 1 },
		{ type = "item", name = "nickel-dust", amount = 9 },
    },
	25, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )		
	
	
---INCOLOY DS INGOT
create_ingot("incoloy-ds", nil, nil, {
		{ type = "item", name = "iron-dust", amount = 23 },
		{ type = "item", name = "chromium-dust", amount = 9 },
		{ type = "item", name = "cobalt-dust", amount = 9 },
		{ type = "item", name = "nickel-dust", amount = 9 },
    },
	50, "hv", nil, nil,
	"hv", HV_SPEED * 1.6, false, false, true, HV_SPEED * 30, false, true )	


---HSSG INGOT
create_ingot("hssg", nil, nil, {
		{ type = "item", name = "tungstensteel-dust", amount = 5 },
		{ type = "item", name = "chromium-dust", amount = 1 },
		{ type = "item", name = "molybdenum-dust", amount = 2 },
		{ type = "item", name = "vanadium-dust", amount = 1 },
    },
	9, "ev", nil, {type = "fluid", name = "helium", amount = 10},
	"mv", MV_SPEED * 14.7, false, false, true, EV_SPEED * 293.95, true, false )		


---HSSE INGOT
create_ingot("hsse", nil, nil, {
		{ type = "item", name = "hssg-dust", amount = 6 },
		{ type = "item", name = "cobalt-dust", amount = 1 },
		{ type = "item", name = "manganese-dust", amount = 1 },
		{ type = "item", name = "raw-silicon", amount = 1 },
    },
	9, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", MV_SPEED * 12.15, true, false, true, EV_SPEED * 316.55, true, false )


---HSSS INGOT
create_ingot("hsss", nil, nil, {
		{ type = "item", name = "hssg-dust", amount = 6 },
		{ type = "item", name = "iridium-dust", amount = 2 },
		{ type = "item", name = "osmium-dust", amount = 1 },
    },
	9, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", MV_SPEED * 19.35, true, false, true, EV_SPEED * 339.15, true, false )
	
	
---YTTRIUM BARIUM CUPRATE INGOT (Dust, EBF and Freezer)
create_ingot("yttrium-barium-cuprate", "ev", EV_SPEED * 30, {
		{ type = "item", name = "yttrium-dust", amount = 1 },
		{ type = "item", name = "barium", amount = 2 },
		{ type = "item", name = "copper-dust", amount = 3 },
		{ type = "fluid", name = "oxygen", amount = 700 },
    },
	13, "mv", 225 * MV_SPEED, {type = "fluid", name = "argon", amount = 5},
	"ev", EV_SPEED * 7.65, false, true, false, nil, true, false )		


---TUNGSTEN CARBIDE INGOT
create_ingot("tungsten-carbide", nil, nil, {
		{ type = "item", name = "tungsten-dust", amount = 1 },
		{ type = "item", name = "carbon", amount = 1 },
    },
	2, "ev", nil, {type = "fluid", name = "helium", amount = 20},
	"mv", MV_SPEED * 14.55, false, false, true, EV_SPEED * 75.35, true, false )	


---NIOBIUM TITANIUM INGOT
create_ingot("niobium-titanium", nil, nil, {
		{ type = "item", name = "niobium-dust", amount = 1 },
		{ type = "item", name = "titanium-dust", amount = 1 },
    },
	2, "hv", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", MV_SPEED * 10.65, true, false, true, HV_SPEED * 75.35, true, false )	


---GRISIUM INGOT
create_ingot("grisium", nil, nil, {
		{ type = "item", name = "titanium-dust", amount = 9 },
		{ type = "item", name = "carbon", amount = 9 },
		{ type = "item", name = "potassium", amount = 9 },
		{ type = "item", name = "lithium", amount = 9 },
		{ type = "item", name = "sulfur", amount = 9 },
    },
	45, "ev", nil, nil,
	"mv", 1.6, false, false, true, EV_SPEED * 40, false, true )

--[[

---ADAMANTIUM INGOT
create_ingot("adamantium", nil, nil, nil, nil,
	"mv", 720 * MV_SPEED, nil,
	"iv", 14.7, false, true, false, nil, true, false )



---NAQUADAH ALLOY INGOT
create_ingot("naquadah-alloy", nil, nil, {
		{ type = "item", name = "naquadah-dust", amount = 2 },
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "item", name = "trinium-dust", amount = 1 }
    },
	4, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"mv", 58.65, true, false, true, EV_SPEED * 100.5, false, true )


---ITBTC-ALLOY (EBF and Freezer)
create_ingot("itbtc-alloy", "luv", 10 * LUV_SPEED, {
		{ type = "item", name = "indium", amount = 4 },
		{ type = "item", name = "tin-dust", amount = 2 },
		{ type = "item", name = "barium", amount = 2 },
		{ type = "item", name = "titanium-dust", amount = 1 },
		{ type = "item", name = "copper-dust", amount = 7 },
		{ type = "fluid", name = "oxygen", amount = 1400 }
    },
	30, "iv", IV_SPEED * 63, {type = "fluid", name = "argon", amount = 5},
	"luv", LUV_SPEED * 20, false, true, false, nil, true, false )	


---ENDERIUM (ABS and Fluid Solidifier)
create_ingot("enderium", nil, nil, {
		{ type = "item", name = "tin-dust", amount = 2 },
		{ type = "item", name = "platinum-dust", amount = 1 },
		{ type = "item", name = "silver-dust", amount = 1 },
--		{ type = "item", name = "thaumium-dust", amount = 2 },
--		{ type = "item", name = "ender-pearl-dust", amount = 2 },
    },
	8, "ev", nil, {type = "fluid", name = "argon", amount = 5},
	"lv", LV_SPEED * 1.2, true, false, true, EV_SPEED * 80, false, true )	

	
---DRACONIUM INGOT (EBF and Freezer)
create_ingot("draconium", nil, nil, nil, nil,
	"luv", LUV_SPEED * 80, {type = "fluid", name = "krypton", amount = 5},
	"iv", IV_SPEED * 14.7, false, true, false, nil, true, false )	

]]--

--------------------------
--- CREATE METAL PARTS ---
--------------------------

---IRON
create_metal_parts{
	material = "iron",
	speed = IRON_SPEED,
	make_plate = true,
	make_block = true,
	make_long_rod = true,
	make_screw = true
}



---COPPER
create_metal_parts{
	material = "copper",
	speed = COPPER_SPEED,
	make_plate = true,
	make_wire = true,
	make_wire_16x = true,
	make_fine_wire = true,
	make_block = true,
	make_foil = true
}



---TIN
create_metal_parts{
	material = "tin",
	speed = TIN_SPEED,
	make_plate = true,
	make_dense_plate = true,
	make_rod = true,
	make_bolt = true,
	make_screw = true,
	make_rotor = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true,
	make_fine_wire = true,
	make_ring = true
}



---BRONZE
create_metal_parts{
	material = "bronze",
	speed = BRONZE_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_screw = true,
	make_frame = true,
	make_rotor = true,
	make_block = true,
	make_foil = true,
	make_ring = true
}



---RED ALLOY
create_metal_parts{
	material = "red-alloy",
	speed = RED_ALLOY_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_block = true,
	make_wire = true,
	make_fine_wire = true
}



---CONDUCTIVE IRON
create_metal_parts{
	material = "conductive-iron",
	speed = CONDUCTIVE_IRON_SPEED,
	make_plate = true
}



---STEEL
create_metal_parts{
	material = "steel",
	speed = STEEL_SPEED,
	make_plate = true,
	make_dense_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_bolt = true,
	make_screw = true,
	make_frame = true,
	make_block = true,
	make_large_gear = true,
	make_rotor = true,
	make_fine_wire = true
}



---ENERGETIC ALLOY
create_metal_parts{
	material = "energetic-alloy",
	speed = ENERGETIC_ALLOY_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true,
	make_foil = true
}



---GOLD
create_metal_parts{
	material = "gold",
	speed = GOLD_SPEED,
	make_plate = true,
	make_wire = true,
	make_wire_16x = true,
	make_fine_wire = true,
	make_foil = true,
	make_block = true
}



---SILVER
create_metal_parts{
	material = "silver",
	speed = SILVER_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true,
	make_foil = true
}



---ELECTRUM
create_metal_parts{
	material = "electrum",
	speed = ELECTRUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true,
	make_fine_wire = true,
	make_foil = true
}



---CUPRONICKEL
create_metal_parts{
	material = "cupronickel",
	speed = CUPRONICKEL_SPEED,
	make_wire = true,
	make_wire_16x = true
}



---BATTERY ALLOY
create_metal_parts{
	material = "battery-alloy",
	speed = BATTERY_ALLOY_SPEED,
	make_plate = true
}



---ANNEALED COPPER
create_metal_parts{
	material = "annealed-copper",
	speed = ANNEALED_COPPER_SPEED,
	make_rod = true,
	make_bolt = true,
	make_wire = true,
	make_fine_wire = true,
	make_foil = true
}



---ZINC
create_metal_parts{
	material = "zinc",
	speed = ZINC_SPEED,
	make_block = true,
	make_foil = true
}



---INVAR
create_metal_parts{
	material = "invar",
	speed = INVAR_SPEED,
	make_plate = true,
	make_rod = true,
	make_block = true,
	make_frame = true
}



---LEAD
create_metal_parts{
	material = "lead",
	speed = LEAD_SPEED,
	make_block = true,
	make_plate = true,
	make_dense_plate = true
}



---BRASS
create_metal_parts{
	material = "brass",
	speed = BRASS_SPEED,
	make_block = true,
	make_rod = true,
	make_long_rod = true
}



---COBALT BRASS
create_metal_parts{
	material = "cobalt-brass",
	speed = COBALT_BRASS_SPEED,
	make_plate = true,
	make_rod = true,
	make_large_gear = true
}



---ALUMINIUM
create_metal_parts{
	material = "aluminium",
	speed = ALUMINIUM_SPEED,
	make_plate = true,
	make_dense_plate = true,
	make_rod = true,
	make_gear = true,
	make_block = true,
	make_bolt = true,
	make_screw = true,
	make_frame = true,
	make_large_gear = true,
	make_wire = true,
	make_wire_16x = true,
	make_fine_wire = true,
	make_foil = true,
	make_long_rod = true,
	make_spring = true
}



---PULSATING IRON
create_metal_parts{
	material = "pulsating-iron",
	speed = PULSATING_IRON_SPEED,
	make_plate = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true
}



---VIBRANT ALLOY
create_metal_parts{
	material = "vibrant-alloy",
	speed = VIBRANT_ALLOY_SPEED,
	make_plate = true,
	make_block = true,
	make_wire = true,
	make_wire_16x = true
}



---DARK STEEL
create_metal_parts{
	material = "dark-steel",
	speed = DARK_STEEL_SPEED,
	make_block = true,
	make_plate = true
}



---SOULARIUM
create_metal_parts{
	material = "soularium",
	speed = SOULARIUM_SPEED,
	make_plate = true,
	make_nugget = true,
	make_block = true,
	make_round = true
}



---ELECTRICAL STEEL
create_metal_parts{
	material = "electrical-steel",
	speed = ELECTRICAL_STEEL_SPEED,
	make_block = true,
	make_plate = true
}



---VANADIUM STEEL
create_metal_parts{
	material = "vanadium-steel",
	speed = VANADIUM_STEEL_SPEED,
	make_large_gear = true,
	make_foil = true
}



---CHROMIUM
create_metal_parts{
	material = "chromium",
	speed = CHROMIUM_SPEED,
	make_rod = true,
	make_large_gear = true,
	make_long_rod = true
}



---POTIN
create_metal_parts{
	material = "potin",
	speed = POTIN_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_long_rod = true
}



---EGLIN STEEL
create_metal_parts{
	material = "eglin-steel",
	speed = EGLIN_STEEL_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_large_gear = true
}



---BERYLLIUM
create_metal_parts{
	material = "beryllium",
	speed = BERYLLIUM_SPEED,
	make_plate = true
}



---NICKEL ZINC FERRITE
create_metal_parts{
	material = "nickel-zinc-ferrite",
	speed = NICKEL_ZINC_FERRITE_SPEED,
	make_block = true,
	make_ring = true
}



---STAINLESS STEEL
create_metal_parts{
	material = "stainless-steel",
	speed = STAINLESS_STEEL_SPEED,
	make_plate = true,
	make_dense_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_bolt = true,
	make_screw = true,
	make_frame = true,
	make_large_gear = true,
	make_rotor = true,
	make_foil = true
}



---KANTHAL
create_metal_parts{
	material = "kanthal",
	speed = KANTHAL_SPEED,
	make_wire = true,
	make_wire_16x = true
}



---END STEEL
create_metal_parts{
	material = "end-steel",
	speed = END_STEEL_SPEED,
	make_wire = true,
	make_wire_16x = true
}



---MARAGING STEEL 300
create_metal_parts{
	material = "maraging-steel-300",
	speed = MARAGING_STEEL_300_SPEED,
	make_plate = true
}



---INCONEL-625
create_metal_parts{
	material = "inconel-625",
	speed = INCONEL_625_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_screw = true
}



---TALONITE
create_metal_parts{
	material = "talonite",
	speed = TALONITE_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_large_gear = true
}



---STELLITE
create_metal_parts{
	material = "stellite",
	speed = STELLITE_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_large_gear = true,
	make_rotor = true
}



---INCOLOY DS
create_metal_parts{
	material = "incoloy-ds",
	speed = INCOLOY_DS_SPEED,
	make_plate = true,
	make_large_gear = true
}



---GRISIUM
create_metal_parts{
	material = "grisium",
	speed = GRISIUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---NICHROME
create_metal_parts{
	material = "nichrome",
	speed = NICHROME_SPEED,
	make_wire = true
}



---BLACK STEEL
create_metal_parts{
	material = "black-steel",
	speed = BLACK_STEEL_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_block = true,
	make_large_gear = true,
	make_fine_wire = true
}



---NEODYMIUM
create_metal_parts{
	material = "neodymium",
	speed = NEODYMIUM_SPEED,
	make_rod = true,
	make_long_rod = true
}



---PLATINUM
create_metal_parts{
	material = "platinum",
	speed = PLATINUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_frame = true,
	make_block = true,
	make_wire = true,
	make_fine_wire = true,
	make_foil = true
}



---PALLADIUM
create_metal_parts{
	material = "palladium",
	speed = PALLADIUM_SPEED,
	make_block = true,
	make_fine_wire = true,
	make_foil = true
}



---TANTALUM
create_metal_parts{
	material = "tantalum",
	speed = TANTALUM_SPEED,
	make_plate = true,
	make_fine_wire = true,
	make_foil = true
}



---MAGNALIUM
create_metal_parts{
	material = "magnalium",
	speed = MAGNALIUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_screw = true,
	make_long_rod = true
}



---SILICON
create_metal_parts{
	material = "silicon",
	speed = SILICON_SPEED,
	make_plate = true
}



---GALLIUM
create_metal_parts{
	material = "gallium",
	speed = GALLIUM_SPEED,
	make_foil = true
}



---MICROVERSIUM
create_metal_parts{
	material = "microversium",
	speed = MICROVERSIUM_SPEED,
	make_plate = true
}


---SIGNALUM
create_metal_parts{
	material = "signalum",
	speed = SIGNALUM_SPEED,
	make_plate = true,
	make_rod = true
}



---BLUE STEEL
create_metal_parts{
	material = "blue-steel",
	speed = BLUE_STEEL_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_large_gear = true
}



---TUMBAGA
create_metal_parts{
	material = "tumbaga",
	speed = TUMBAGA_SPEED,
	make_rod = true,
	make_frame = true,
	make_long_rod = true,
	make_large_gear = true
}



---INCOLOY_903
create_metal_parts{
	material = "incoloy-903",
	speed = INCOLOY_903_SPEED,
	make_plate = true
}



---TANTALUM CARBIDE
create_metal_parts{
	material = "tantalum-carbide",
	speed = TANTALUM_CARBIDE_SPEED,
	make_plate = true,
	make_large_gear = true
}



---INDOVANADIUM
create_metal_parts{
	material = "indovanadium",
	speed = INDOVANADIUM_SPEED,
	make_wire = true
}



---STABALLOY
create_metal_parts{
	material = "staballoy",
	speed = STABALLOY_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---MARAGING STEEL 250
create_metal_parts{
	material = "maraging-steel-250",
	speed = MARAGING_STEEL_250_SPEED,
	make_plate = true
}


---ZIRCONIUM CARBIDE
create_metal_parts{
	material = "zirconium-carbide",
	speed = ZIRCONIUM_CARBIDE_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---TITANIUM
create_metal_parts{
	material = "titanium",
	speed = TITANIUM_SPEED,
	make_plate = true,
	make_dense_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_bolt = true,
	make_frame = true,
	make_block = true,
	make_large_gear = true,
	make_rotor = true
}



---RTM ALLOY
create_metal_parts{
	material = "rtm-alloy",
	speed = RTM_ALLOY_SPEED,
	make_wire = true
}



---ULTIMET
create_metal_parts{
	material = "ultimet",
	speed = ULTIMET_SPEED,
	make_large_gear = true
}




---INCOLOY MA956
create_metal_parts{
	material = "incoloy-ma956",
	speed = INCOLOY_MA956_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---LEDOX
create_metal_parts{
	material = "ledox",
	speed = LEDOX_SPEED,
	make_plate = true
}



---ZERON-100 STEEL
create_metal_parts{
	material = "zeron-100",
	speed = ZERON_100_SPEED,
	make_plate = true
}



---NITINOL-60
create_metal_parts{
	material = "nitinol-60",
	speed = NITINOL_60_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---INCONEL-690
create_metal_parts{
	material = "inconel-690",
	speed = INCONEL_690_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true
}



---TUNGSTEN
create_metal_parts{
	material = "tungsten",
	speed = TUNGSTEN_SPEED,
	make_rod = true,
	make_frame = true,
	make_block = true,
	make_wire = true,
	make_long_rod = true,
	make_spring = true
} 



---TUNGSTEN CARBIDE
create_metal_parts{
	material = "tungsten-carbide",
	speed = TUNGSTEN_CARBIDE_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_foil = true
}


  
---TUNGSTENSTEEL
create_metal_parts{
	material = "tungstensteel",
	speed = TUNGSTENSTEEL_SPEED,
	make_plate = true,
	make_rod = true,
	make_long_rod = true,
	make_gear = true,
	make_bolt = true,
	make_screw = true,
	make_frame = true,
	make_rotor = true
}



---TANTALLOY 60
create_metal_parts{
	material = "tantalloy-60",
	speed = TANTALLOY_60_SPEED,
	make_rod = true
}



---INCONEL 792
create_metal_parts{
	material = "inconel-792",
	speed = INCONEL_792_SPEED,
	make_plate = true,
	make_rod = true,
	make_ring = true
}



---WATERTIGHT STEEL
create_metal_parts{
	material = "watertight-steel",
	speed = WATERTIGHT_STEEL_SPEED,
	make_rod = true,
	make_frame = true
}


  
---HSSG
create_metal_parts{
	material = "hssg",
	speed = HSSG_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_wire = true,
	make_fine_wire = true
}


  
---HSSE
create_metal_parts{
	material = "hsse",
	speed = HSSE_SPEED,
	make_fine_wire = true,
	make_ring = true
}


  
---HSSS
create_metal_parts{
	material = "hsss",
	speed = HSSS_SPEED,
	make_foil = true
}


  
---VANADIUM GALLIUM
create_metal_parts{
	material = "vanadium-gallium",
	speed = VANADIUM_GALLIUM_SPEED,
	make_wire = true,
	make_foil = true
}



---SAMARIUM
create_metal_parts{
	material = "samarium",
	speed = SAMARIUM_SPEED,
	make_long_rod = true,
	make_ring = true
}



---IRIDIUM
create_metal_parts{
	material = "iridium",
	speed = IRIDIUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_block = true,
	make_fine_wire = true
}



---RURIDIT
create_metal_parts{
	material = "ruridit",
	speed = RURIDIT_SPEED,
	make_rod = true,
	make_bolt = true,
	make_fine_wire = true
}



---NIOBIUM TITANIUM
create_metal_parts{
	material = "niobium-titanium",
	speed = NIOBIUM_TITANIUM_SPEED,
	make_plate = true,
	make_wire = true,
	make_fine_wire = true
}



---YTTRIUM BARIUM CUPRATE
create_metal_parts{
	material = "yttrium-barium-cuprate",
	speed = YTTRIUM_BARIUM_CUPRATE_SPEED,
	make_wire = true
}



---HASTELLOY_C276
create_metal_parts{
	material = "hastelloy-c276",
	speed = HASTELLOY_C276_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_large_gear = true,
	make_rotor = true
}



---HASTELLOY_W
create_metal_parts{
	material = "hastelloy-w",
	speed = HASTELLOY_W_SPEED,
	make_plate = true,
	make_rod = true,
	make_frame = true,
	make_rotor = true
}



---HASTELLOY_X
create_metal_parts{
	material = "hastelloy-x",
	speed = HASTELLOY_X_SPEED,
	make_plate = true,
	make_rotor = true
}



---NAQUADAH
create_metal_parts{
	material = "naquadah",
	speed = NAQUADAH_SPEED,
	make_wire = true
}



---ENRICHED NAQUADAH
create_metal_parts{
	material = "enriched-naquadah",
	speed = ENRICHED_NAQUADAH_SPEED,
	make_foil = true
}



---OSMIUM
create_metal_parts{
	material = "osmium",
	speed = OSMIUM_SPEED,
	make_plate = true,
	make_block = true,
	make_foil = true
}

--[[

---EUROPIUM
create_metal_parts{
	material = "europium",
	speed = EUROPIUM_SPEED,
	make_plate = true,
	make_wire = true,
	make_block = true,
	make_fine_wire = true
}



---RHODIUM PLATED PALLADIUM
create_metal_parts{
	material = "rhodium-plated-palladium",
	speed = RHODIUM_PLATED_PALLADIUM_SPEED,
	make_plate = true
}



---OSMIRIDIUM
create_metal_parts{
	material = "osmiridium",
	speed = OSMIRIDIUM_SPEED,
	make_plate = true,
	make_fine_wire = true
}



---TRINIUM
create_metal_parts{
	material = "trinium",
	speed = TRINIUM_SPEED,
	make_plate = true,
	make_rotor = true,
	make_wire = true
}



---NAQUADAH ALLOY
create_metal_parts{
	material = "naquadah-alloy",
	speed = NAQUADAH_ALLOY_SPEED,
	make_plate = true,
	make_wire = true,
	make_rotor = true
}



---ADAMANTIUM
create_metal_parts{
	material = "adamantium",
	speed = ADAMANTIUM_SPEED,
	make_rod = true,
	make_frame = true
}



---NAQUADRIA
create_metal_parts{
	material = "naquadria",
	speed = NAQUADRIA_SPEED,
	make_block = true,
	make_foil = true
}



---TRITANIUM
create_metal_parts{
	material = "tritanium",
	speed = TRITANIUM_SPEED,
	make_wire = true
}



---NEUTRONIUM
create_metal_parts{
	material = "neutronium",
	speed = NEUTRONIUM_SPEED,
	make_plate = true,
	make_rod = true,
	make_bolt = true,
	make_screw = true,
	make_block = true,
	make_gear = true,
	make_large_gear = true,
	make_rotor = true,
	make_frame = true,
	make_ring = true,
	make_nugget = true,
	make_round = true,
	make_wire = true,
	make_fine_wire = true,
	make_long_rod = true
}



---CRYSTAL MATRIX
create_metal_parts{
	material = "crystal-matrix",
	speed = CRYSTAL_MATRIX_SPEED,
	make_foil = true
}



---HOLMIUM
create_metal_parts{
	material = "holmium",
	speed = HOLMIUM_SPEED,
	make_plate = true,
	make_fine_wire = true,
	make_foil = true
}



---ELTZ
create_metal_parts{
	material = "eltz",
	speed = ELTZ_SPEED,
	make_plate = true,
	make_rod = true,
	make_gear = true,
	make_large_gear = true,
	make_long_rod = true,
	make_nugget = true,
	make_round = true,
	make_ring = true
}



---AWAKENED DRACONIUM
create_metal_parts{
	material = "awakened-draconium",
	speed = AWAKENED_DRACONIUM_SPEED,
	make_plate = true,
	make_block = true,
	make_wire = true
}



---HYPOGEN
create_metal_parts{
	material = "hypogen",
	speed = HYPOGEN_SPEED,
	make_foil = true
}



---INFINITY
create_metal_parts{
	material = "infinity",
	speed = INFINITY_SPEED,
	make_plate = true,
	make_wire = true
}



---SHIRABON
create_metal_parts{
	material = "shirabon",
	speed = SHIRABON_SPEED,
	make_plate = true,
	make_foil = true,
	make_long_rod = true
}

]]--