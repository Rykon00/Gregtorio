--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UXV 2048	OPV 4096
---			1		2		3		4		5		6		7		8		9		10			11			12
--[[

A COMPREHENSIVE LIST OF EVERYTHING MICROMINERS PROVIDE:

STEEL PLATED MICROMINER
TIER ONE (THE OVERWORLD) [BEGINNING OF MV]:
IRON, VANADIUM MAGNETITE, GOLD, COAL, SALT, ROCK SALT, LEPIDOLITE, COPPER, TIN, REALGAR, REDSTONE, RUBY, CINNIBAR, FULLERS EARTH, GYPSUM, APATITE
TRICALCIUM PHOSPHATE, PYROCHLORE, CLAY, NICKEL, PENTLANDITE, COBALT, TETRAHEDRITE, STIBNITE, LAPIS, LAZURITE, SODALITE, CALCITE, GALENA, SILVER
LEAD, CRYOLITE, BAUXITE, ALUMINIUM, DIAMOND, GROSSULAR, SPESSARTINE, PYROLUSITE, TANTALITE
ENDER PEARLS, ZOMBIE HEADS
NETHER DATA, THE END DATA, LUNAR NAVIGATION DATA



STAINLESS STEEL PLATED MICROMINER
TIER TWO (THE NETHER) [BEGINNING OF HV]:
SULFUR, SPHALERITE, NETHER QUARTZ, QUARTZITE, CERTUS QUARTZ, BERYLLIUM, EMERALD, BARITE, ILMENITE, BASTNASITE, MONAZITE, MOLYBDENITE, NEODYMIUM
BLAZE RODS, WITHER SKULLS
WITHER REALM DATA



TITANIUM PLATED MICROMINER
TIER THREE (MOON / THE END) [BEGINNING OF EV]:
TUNGSTATE, SCHEELITE, BORNITE, SHELDONITE, PLATINUM, PALLADIUM, PITCHBLENDE, URANIUM
DEUTERIUM FROM MOON DUST
DILITHIUM ORE
DRAGON DEN DATA, INNER PLANETS NAVIGATION DATA 



TUNGSTEN CARBIDE PLATED MICROMINER
TIER FOUR (MARS / VENUS / MERCURY / DRAGON DEN) [BEGINNING OF IV]:
RUTHENIUM, IRIDIUM, RADON SALT, DESH ORES
DRAGON SCALES, DRAGON EGGS, DRAGON BREATH
MARS DRILLING RIG: CHLOROBENZENE
VENUS DRILLING RIG: SULFURIC ACID
MERCURY DRILLING RIG: MOLTEN IRON



REINFORCED IRIDIUM PLATED MICROMINER
TIER FIVE (JUPITER / WITHER REALM) [BEGINNING OF LUV]:
INFUSED GOLD, CALLISTO ICE / LEDOX, ARSENIC/BISMUTH, ORIHARUKAN, OSMIUM ORES
DEEP DARK DATA, OUTER PLANETS NAVIGATION DATA 
JUPITER PLANETARY GAS SYPHON: HYDROGEN
JUPITER PLANETARY GAS SYPHON: NITROGEN
JUPITER PLANETARY GAS SYPHON: OXYGEN
JUPITER PLANETARY GAS SYPHON: HELIUM
GANYMEDE DRILLING RIG: CARBON MONOXIDE
EUROPA DRILLING RIG: MOLTEN LEDOX
IO DRILLING RIG: MOLTEN LEAD
CALLISTO DRILLING RIG: CALLISTO ICE WATER



ENDERIUM PLATED MICROMINER
TIER SIX (SATURN / DEEP DARK) [BEGINNING OF ZPM]:
DEEP IRON (TRINIUM), PLUTONIUM
GUARDIAN SCALES
LAIR OF THE WARDEN DATA
SATURN PLANETARY GAS SYPHON: DEUTERIUM
SATURN PLANETARY GAS SYPHON: HELIUM-3
SATURN PLANETARY GAS SYPHON: TRITIUM
SATURN PLANETARY GAS SYPHON: NEON
TITAN DRILLING RIG: ETHANE
RHEA DRILLING RIG: METHANE
DIONE DRILLING RIG: ETHYLENE
ENCELADUS DRILLING RIG: ARGON



CRYSTAL MATRIX PLATED MICROMINER
TIER SEVEN (URANUS / NEPTUNE / LAIR OF THE WARDEN) [BEGINNING OF UV]:
BEDROCKIUM ORE, BLACK PLUTONIUM ORE, NEUTRONIUM ORE, DULYSITE ORE (DURANIUM)
SKULK CATALYST, WARDEN TENDRILS, WARDEN HEART
KUPIER BELT NAVIGATION DATA
URANUS PLANETARY GAS SYPHON: AMMONIA
URANUS PLANETARY GAS SYPHON: KRYPTON
NEPTUNE PLANETARY GAS SYPHON: XENON
NEPTUNE PLANETARY GAS SYPHON: FLUORINE
MIRANDA DRILLING RIG: MOLTEN GOLD
OBERON DRILLING RIG: MOLTEN COPPER
TRITON DRILLING RIG: MOLTEN TIN
PROTEUS DRILLING RIG: MOLTEN SILVER



COSMIC NEUTRONIUM PLATED MICROMINER
TIER EIGHT (KUPIER BELT) [BEGINNING OF UHV]:
INFINITY CATALYST ORE
HADAL SHARDS
ANCIENT DEBRIS
SHATTERED STAR DATA, UNIVERSE CREATION DATA
PLUTO DRILLING RIG: HYDROFLUORIC ACID
ERIS DRILLING RIG: RADON
HAUMEA DRILLING RIG: UNKNOWN LIQUID
MAKEMAKE DRILLING RIG: MOLTEN BORON



INFINITY PLATED MICROMINER
TIER NINE [BEGINNING OF UEV]:
DRACONIUM
SHATTERED UNIVERSE DATA



TRANSCENDENT METAL? PLATED MICROMINER
TIER TEN [BEGINNING OF UIV]:
QUASI-STABLE NEUTRON STAR, ALIEN SCRAP
CORRUPTED UNIVERSE DATA



SPACETIME? PLATED MICROMINER
TIER ELEVEN [BEGINNING OF UMV]:
HEART OF A UNIVERSE



UNIVERSIUM? PLATED MICROMINER
TIER TWELVE [BEGINNING OF UXV]:
INFINITY SCIENCE



UNTIERED ATM:
MYSTERIOUS CRYSTAL DUST


--]]





---STAINLESS STEEL HEAVY PLATING
create_item{
	name = "stainless-steel-heavy-plating",
	category = "lv-bending-machine-recipes",
	energy_required = 16,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "stainless-steel-plate", amount = 4},
    }
}
  
  
  
---ELECTRUM MICROMINER ENGINE FRAME
create_item{
	name = "electrum-microminer-engine-frame",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
      {type = "item", name = "electrum-plate", amount = 4},
      {type = "item", name = "electrum-rod", amount = 4}
    }
}



---BLOCK OF REDSTONE
create_item{
	name = "block-of-redstone",
	category = "lv-compressor-recipes",
	energy_required = 15,
	ingredients = {
      {type = "item", name = "redstone-dust", amount = 9}
    }
}



---ELECTRUM MICROMINER ENGINE CORE
create_item{
	name = "electrum-microminer-engine-core",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
      {type = "item", name = "electrum-microminer-engine-frame", amount = 1},
      {type = "item", name = "block-of-redstone", amount = 2}
    }
}  
  

  
---STAINLESS STEEL PLATED MICRO MINER
create_item{
	name = "stainless-steel-plated-microminer",
	category = "advanced-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t2",
	ingredients = {
      {type = "item", name = "basic-guidance-system", amount = 1},
      {type = "item", name = "basic-mining-laser", amount = 2},
      {type = "item", name = "stainless-steel-heavy-plating", amount = 6},
      {type = "item", name = "lv-field-generator", amount = 2},
      {type = "item", name = "electrum-microminer-engine-core", amount = 1},
      {type = "item", name = "steel-chest", amount = 1},
      {type = "item", name = "mv-combustion-generator", amount = 1},
      {type = "item", name = "energetic-thruster", amount = 3}
    }
}
  
  
  
--- NETHER DATA
create_item{
	name = "nether-data",
	category = "mv-microverse-projector-recipes",
	energy_required = MV_SPEED * 100,
	icon_size = 64,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "steel-plated-microminer", amount = 1},
		{type = "item", name = "overworld-data", amount = 1},
		{type = "item", name = "me-4k-storage-component", amount = 16},
		{type = "item", name = "basic-storage-housing", amount = 16},
		{type = "fluid", name = "benzene", amount = 400}
    },
	results = {
		{type = "item", name = "nether-data", amount = 16}
    }
}
  
  
  
---TIER TWO MISSION
create_item{
	name = "tier-two-microminer-output",
	category = "hv-microverse-projector-recipes",
	energy_required = HV_SPEED * 120,
	subgroup = "subgroup-microminer-t2",	
	ingredients = {
--      {type = "item", name = "stainless-steel-plated-microminer", amount = 1},
      {type = "item", name = "nether-data", amount = 1},
      {type = "fluid", name = "diesel", amount = 600},
    },
	results = {
      {type = "item", name = "tier-two-microminer-output", amount = 64 }
    }
}



---TIER TWO MICROMINER OUTPUTS (NON ORE)
create_item{
	name = "blaze-rod",
	recipe_name = "microminer-blaze-rods",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
      {type = "item", name = "tier-two-microminer-output", amount = 1 }
    },
	results = {
      {type = "item", name = "blaze-rod", amount = 16 }
    }
}
create_item{
	name = "wither-skull",
	recipe_name = "microminer-wither-skulls",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
		{type = "item", name = "tier-two-microminer-output", amount = 1 }
    },
	results = {
		{type = "item", name = "wither-skull", amount = 16 }
    }
}
create_item{
	name = "soul-sand",
	recipe_name = "microminer-soul-sand",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
		{type = "item", name = "tier-two-microminer-output", amount = 1 }
    },
	results = {
		{type = "item", name = "soul-sand", amount = 128 }
    }
}
create_item{
	name = "radon-salt",
	recipe_name = "microminer-radon-salt",
	category = "lv-assembling-machine-recipes",
	energy_required = 4,
	subgroup = "subgroup-microminer-t2",
	ingredients = {
		{type = "item", name = "tier-two-microminer-output", amount = 2 }
    },
	results = {
		{type = "item", name = "radon-salt", amount = 32 }
    }
}



---TITANIUM PLATED MICROMINER
create_item{
	name = "titanium-plated-microminer",
	category = "elite-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t3",
	ingredients = {
      {type = "item", name = "basic-guidance-system", amount = 2},
      {type = "item", name = "reinforced-mining-laser", amount = 2},
      {type = "item", name = "titanium-heavy-plating", amount = 15},
      {type = "item", name = "mv-field-generator", amount = 2},
      {type = "item", name = "electrum-microminer-engine-core", amount = 2},
      {type = "item", name = "diamond-chest", amount = 3},
      {type = "item", name = "hv-combustion-generator", amount = 1},
      {type = "item", name = "pulsating-thruster", amount = 3}
    }
}
  
  
  
---TITANIUM HEAVY PLATING
create_item{
	name = "titanium-heavy-plating",
	category = "lv-implosion-compressor-recipes",
	ingredients = {
		{type = "item", name = "titanium-plate", amount = 4},
		{type = "item", name = "explosives", amount = 1},
    }
}



---SOLIDIFIED ARGON
create_item{
	name = "solidified-argon",
	category = "lv-fluid-solidifier-recipes",
	energy_required = 4,
	ingredients = {
		{type = "fluid", name = "argon", amount = 100},
    }
}
  
  
  
---REINFORCED MINING LASER
create_item{
	name = "reinforced-mining-laser",
	category = "advanced-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t3",
	ingredients = {
		{type = "item", name = "ruby-lens", amount = 2},
		{type = "item", name = "tempered-glass", amount = 9},
		{type = "item", name = "block-of-redstone", amount = 2},
		{type = "item", name = "solidified-argon", amount = 4},
		{type = "item", name = "processing-unit", amount = 1},
		{type = "item", name = "hv-emitter", amount = 2},
		{type = "item", name = "titanium-plate", amount = 2},
    },
	results = {
		{type = "item", name = "reinforced-mining-laser", amount = 1}
    }
}
  


---ENERGETIC THRUSTER
create_item{
	name = "energetic-thruster",
	category = "basic-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t2",
	ingredients = {
		{type = "item", name = "energetic-alloy-plate", amount = 5},
		{type = "item", name = "ender-pearl", amount = 1},
		{type = "item", name = "red-alloy-plate", amount = 3}
    },
	results = {
		{type = "item", name = "energetic-thruster", amount = 1}
    }
}
  
  
  
---PULSATING IRON INGOT
create_item{
	name = "pulsating-iron-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 10,
	ingredients = {
		{type = "item", name = "iron-ingot", amount = 1},
		{type = "item", name = "ender-pearl", amount = 1}
    }
}


  
---PULSATING THRUSTER
create_item{
	name = "pulsating-thruster",
	category = "basic-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t3",
	ingredients = {
		{type = "item", name = "pulsating-iron-plate", amount = 5},
		{type = "item", name = "vibrant-crystal", amount = 1},
		{type = "item", name = "red-alloy-plate", amount = 3}
    },
	results = {
		{type = "item", name = "pulsating-thruster", amount = 1}
    }
}
  
  
  
---VIBRANT ALLOY INGOT
create_item{
	name = "vibrant-alloy-ingot",
	category = "lv-alloy-smelter-recipes",
	energy_required = 40,
	ingredients = {
		{type = "item", name = "energetic-alloy-ingot", amount = 1},
		{type = "item", name = "ender-pearl", amount = 1},
    }
}



---VIBRANT THRUSTER
create_item{
	name = "vibrant-thruster",
	category = "basic-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t4",
	ingredients = {
		{type = "item", name = "vibrant-alloy-plate", amount = 5},
		{type = "item", name = "nether-star", amount = 1},
		{type = "item", name = "red-alloy-plate", amount = 3}
    },
	results = {
		{type = "item", name = "vibrant-thruster", amount = 1}
    }
} 



---THE END DATA
create_item{
	name = "the-end-data",
	category = "mv-microverse-projector-recipes",
	energy_required = MV_SPEED * 100,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
      {type = "item", name = "steel-plated-microminer", amount = 1},
      {type = "item", name = "overworld-data", amount = 1},
      {type = "item", name = "me-16k-storage-component", amount = 16},
      {type = "item", name = "basic-storage-housing", amount = 16},
	  {type = "fluid", name = "benzene", amount = 400}
    },
	results = {
      {type = "item", name = "the-end-data", amount = 16}
    }
}
  


---TIER THREE MISSION
create_item{
	name = "tier-three-microminer-output",
	category = "ev-microverse-projector-recipes",
	energy_required = EV_SPEED * 150,
	subgroup = "subgroup-microminer-t3",
	ingredients = {
--      {type = "item", name = "titanium-plated-microminer", amount = 1 },
      {type = "item", name = "the-end-data", amount = 1 },
      {type = "fluid", name = "rocket-fuel", amount = 800 }
    },
	results = {
      {type = "item", name = "tier-three-microminer-output", amount = 64 }
    }
}



---TIER THREE OUTPUTS (NON ORE)
create_item{
	name = "compressed-end-stone",
	recipe_name = "microminer-end-stone",
	category = "lv-assembling-machine-recipes",
	energy_required = 8,
	subgroup = "subgroup-microminer-t3",
	ingredients = {
      {type = "item", name = "tier-three-microminer-output", amount = 1}
    },
	results = {
      {type = "item", name = "compressed-end-stone", amount = 64 },
    }
}




---ADVANCED EXTENDED CRAFTING COMPONENT
create_item{
	name = "advanced-extended-crafting-component",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "electrum-plate", amount = 1 },
		{ type = "item", name = "glowstone-dust", amount = 1 },
		{ type = "item", name = "luminessence", amount = 1 }
	},
}



---ADVANCED EXTENDED CRAFTING CATALYST
create_item{
	name = "advanced-extended-crafting-catalyst",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "advanced-extended-crafting-component", amount = 4 }
	},
} 



---ADVANCED EXTENDED CRAFTING TABLE
create_item{
	name = "advanced-extended-crafting-table",
	category = "basic-extended-crafting-recipes",
	stack_size = 10,
	place_result = "advanced-extended-crafting-table",
	ingredients = {
		{ type = "item", name = "advanced-extended-crafting-component", amount = 2 },
		{ type = "item", name = "advanced-extended-crafting-catalyst", amount = 1 },
		{ type = "item", name = "electrum-plate", amount = 4 },
		{ type = "item", name = "basic-extended-crafting-table", amount = 2 }
	}
}



---ELITE EXTENDED CRAFTING COMPONENT
create_item{
	name = "elite-extended-crafting-component",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "aluminium-plate", amount = 1 },
		{ type = "item", name = "diamond", amount = 1 },
		{ type = "item", name = "luminessence", amount = 1 }
	}
}
   
   
   
---ELITE EXTENDED CRAFTING CATALYST
create_item{
	name = "elite-extended-crafting-catalyst",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "elite-extended-crafting-component", amount = 4 }
	}
}   



---ELITE EXTENDED CRAFTING TABLE
create_item{
	name = "elite-extended-crafting-table",
	category = "advanced-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "block-of-aluminium", amount = 5 },
		{ type = "item", name = "elite-extended-crafting-catalyst", amount = 4 },
		{ type = "item", name = "elite-extended-crafting-component", amount = 4 },
		{ type = "item", name = "black-steel-plate", amount = 8 },
		{ type = "item", name = "advanced-extended-crafting-table", amount = 4 }
	},
	stack_size = 10,
	place_result = "elite-extended-crafting-table"
}



---CRYSTALTINE INGOT
create_item{
	name = "crystaltine-ingot",
	category = "elite-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "diamond", amount = 8 },
		{ type = "item", name = "lapis-lazuli", amount = 10 },
		{ type = "item", name = "gold-ingot", amount = 4 },
		{ type = "item", name = "iron-ingot", amount = 4 },
		{ type = "item", name = "nether-star", amount = 2 },
	}
}
   
   
   
---CRYSTALTINE EXTENDED CRAFTING COMPONENT
create_item{
	name = "crystaltine-extended-crafting-component",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "crystaltine-ingot", amount = 1 },
		{ type = "item", name = "hssg-plate", amount = 1 },
		{ type = "item", name = "luminessence", amount = 1 }
	}
}



---CRYSTALTINE EXTENDED CRAFTING CATALYST
create_item{
	name = "crystaltine-extended-crafting-catalyst",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "crystaltine-extended-crafting-component", amount = 4 }
	}
}  
   
   
   
---ULTIMATE EXTENDED CRAFTING COMPONENT
create_item{
	name = "ultimate-extended-crafting-component",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "black-steel-plate", amount = 1 },
		{ type = "item", name = "ultimate-extended-crafting-component", amount = 4 }
	}
}

   
   
---ULTIMATE EXTENDED CRAFTING CATALYST
create_item{
	name = "ultimate-extended-crafting-catalyst",
	category = "basic-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "ultimate-extended-crafting-component", amount = 1 },
		{ type = "item", name = "basic-extended-crafting-catalyst", amount = 1 },
		{ type = "item", name = "advanced-extended-crafting-catalyst", amount = 1 },
		{ type = "item", name = "elite-extended-crafting-catalyst", amount = 1 },
		{ type = "item", name = "crystaltine-extended-crafting-catalyst", amount = 1 }
	}
}  



---ULTIMATE EXTENDED CRAFTING TABLE
create_item{
	name = "ultimate-extended-crafting-table",
	category = "elite-extended-crafting-recipes",
	ingredients = {
		{ type = "item", name = "block-of-emerald", amount = 5 },
		{ type = "item", name = "ultimate-extended-crafting-catalyst", amount = 4 },
		{ type = "item", name = "ultimate-extended-crafting-component", amount = 12 },
		{ type = "item", name = "black-steel-plate", amount = 16 },
		{ type = "item", name = "crystaltine-extended-crafting-component", amount = 4 },
		{ type = "item", name = "crystaltine-extended-crafting-catalyst", amount = 4 },
		{ type = "item", name = "elite-extended-crafting-table", amount = 4 }
	}
} 




--- EXTENDED CRAFTING TABLES
data:extend({
  {
    type = "assembling-machine",
    name = "advanced-extended-crafting-table",
    icon = "__gregtorio-continued__/graphics/icons/advanced-extended-crafting-table.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "advanced-extended-crafting-table"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "fr-extended-crafting-table",
    crafting_categories = { "advanced-extended-crafting-recipes" },
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__gregtorio-continued__/graphics/entity/advanced-extended-crafting-table.png",
            width = 180,
            height = 180,
            frame_count = 1,
            line_length = 1,
            shift = {0, 0},
            scale = 0.5
          }
        }
      }
    }
  },
  {
    type = "assembling-machine",
    name = "elite-extended-crafting-table",
    icon = "__gregtorio-continued__/graphics/icons/elite-extended-crafting-table.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "elite-extended-crafting-table"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "fr-extended-crafting-table",
    crafting_categories = { "elite-extended-crafting-recipes" },
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__gregtorio-continued__/graphics/entity/elite-extended-crafting-table.png",
            width = 180,
            height = 180,
            frame_count = 1,
            line_length = 1,
            shift = {0, 0},
            scale = 0.5
          }
        }
      }
    }
  },
  {
    type = "assembling-machine",
    name = "ultimate-extended-crafting-table",
    icon = "__gregtorio-continued__/graphics/icons/ultimate-extended-crafting-table.png",
    icon_size = 32,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "ultimate-extended-crafting-table"},
    max_health = 200,
    corpse = "small-remnants",
    dying_explosion = "medium-explosion",
    resistances = {
      { type = "fire", percent = 70 }
    },
    collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fast_replaceable_group = "fr-extended-crafting-table",
    crafting_categories = { "ultimate-extended-crafting-recipes" },
    crafting_speed = 1,
    energy_source = { type = "void" },
    energy_usage = "1W",
    emissions_per_minute = { pollution = 0 },
    allowed_effects = {},
    graphics_set = {
      animation = {
        layers = {
          {
            filename = "__gregtorio-continued__/graphics/entity/ultimate-extended-crafting-table.png",
            width = 180,
            height = 180,
            frame_count = 1,
            line_length = 1,
            shift = {0, 0},
            scale = 0.5
          }
        }
      }
    }
  }
})


---LUNAR NAVIGATION DATA
create_item{
	name = "lunar-navigation-data",
	category = "mv-microverse-projector-recipes",
	energy_required = MV_SPEED * 100,
	icon_size = 64,
	subgroup = "subgroup-microminer-t1",
	ingredients = {
		{type = "item", name = "steel-plated-microminer", amount = 1 },
		{type = "item", name = "overworld-data", amount = 1},
		{type = "item", name = "me-64k-storage-component", amount = 16},
		{type = "item", name = "basic-storage-housing", amount = 16},
		{type = "fluid", name = "benzene", amount = 400}
    },
	results = {
		{type = "item", name = "lunar-navigation-data", amount = 16}
    }
}

  

---THE END HAS:  GOLD VEIN (160), NICKEL VEIN (40), BERYLLIUM VEIN (30), NAQUADAH VEIN (30), MANGANESE VEIN (20), TUNGSTATE VEIN (10), PLATINUM VEIN (5), MOLYBDENUM VEIN (5)
---THE MOON (T1) HAS:  BAUXITE VEIN (80), MONAZITE VEIN (30), CERTUS QUARTZ VEIN (20), ILMENITE VEIN (16), MOLYBDENUM VEIN (5)
---MARS (T2) HAS: DESH, TUNGSTATE, SULFUR, URANIUM, CERTUS QUARTZ, REDSTONE, ARSENIC/BISMUTH, NICKEL, GOLD, IRON, BERYLLIUM, TETRAHEDRITE, GALENA, SALT, DRACONIUM, ORIHARUKAN, DIAMOND
---T3 DIMS: PLUTONIUM, PALLADIUM, ELECTROTINE, DIAMOND, CALLISTO ICE, LEDOX FROM EUROPA
---CERES, GANYMEDE, CALLISTO, EUROPA
--- T4 DIMS: INFUSED GOLD, MYTRYL (SAMARIUM) (io), IRIDIUM, QUANTIUM (venus), DEEP IRON (mercury)
--- MERCURY, VENUS, IO 
--- T5 DIMS: OSMIUM
--- ENCELADUS, MIRANDA, OBERON, TITAN, ROSS128
--- t6 dims:  neutronium
--- t7 dims: nether star, black plutonium, 

-- t9 dims: bedrockium

--- Endsteel is: dark steel + tungsten + endstone
--- Melodic Alloy is: endsteel + orihalkon + ender eye
--- stellar alloy is: melodic + nether star + naquadah
--- (t5): osmium vein, 






---TUNGSTEN CARBIDE PLATED MICROMINER
create_item{
	name = "tungsten-carbide-plated-microminer",
	category = "elite-extended-crafting-recipes",
	subgroup = "subgroup-microminer-t4",
	ingredients = {
		{type = "item", name = "basic-guidance-system", amount = 1},
		{type = "item", name = "reinforced-mining-laser", amount = 2},
		{type = "item", name = "tungsten-carbide-heavy-plating", amount = 6},
		{type = "item", name = "titanium-heavy-plating", amount = 4},
		{type = "item", name = "hv-field-generator", amount = 2},
		{type = "item", name = "signalum-microminer-engine-core", amount = 2},
		{type = "item", name = "diamond-chest", amount = 2},
		{type = "item", name = "basic-nuclear-reactor", amount = 1},
		{type = "item", name = "vibrant-thruster", amount = 4}
    }
}
  
  
  
---TUNGSTEN CARBIDE HEAVY PLATING
create_item{
	name = "tungsten-carbide-heavy-plating",
	category = "iv-bending-machine-recipes",
	energy_required = IV_SPEED * 4,
	subgroup = "subgroup-microminer-t4",
	ingredients = {
		{type = "item", name = "tungsten-carbide-plate", amount = 4}
    }
}
  
  
  
---SIGNALUM MICROMINER ENGINE CORE
create_item{
	name = "signalum-microminer-engine-core",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED * 50,
	subgroup = "subgroup-microminer-t4",
	ingredients = {
		{type = "item", name = "signalum-microminer-engine-frame", amount = 1},
		{type = "item", name = "block-of-redstone", amount = 9},
    }
}



---SIGNALUM MICROMINER ENGINE FRAME
create_item{
	name = "signalum-microminer-engine-frame",
	category = "ev-assembling-machine-recipes",
	energy_required = EV_SPEED,
	subgroup = "subgroup-microminer-t4",
	ingredients = {
      {type = "item", name = "signalum-plate", amount = 4},
      {type = "item", name = "signalum-rod", amount = 4},
    }
}



---SIGNALUM INGOT
create_item{ skip_recipe = true,
	name = "signalum-ingot",
	subgroup = "subgroup-lv-alloy-smelter-recipes",
} 



---TIER FOUR MISSION
create_item{
	name = "tier-four-microminer-output",
	category = "iv-microverse-projector-recipes",
	energy_required = IV_SPEED * 180,
	ingredients = {
      {type = "item", name = "tungsten-carbide-plated-microminer", amount = 1 },
      {type = "item", name = "lunar-navigation-data", amount = 1 },
      {type = "fluid", name = "rocket-fuel", amount = 800 }
    }
}



---TIER FOUR OUTPUTS (NON ORE)
create_item{
	name = "compressed-moon-turf",
	recipe_name = "microminer-compressed-moon-turf",
	category = "lv-assembling-machine-recipes",
	energy_required = 8,
	ingredients = {
		{type = "item", name = "tier-four-microminer-output", amount = 1}
    },
	results = {
		{type = "item", name = "compressed-moon-turf", amount = 64 },
    }
}
create_item{
	name = "moon-dust",
	category = "hv-macerator-recipes",
	energy_required = HV_SPEED * 4,
	ingredients = {
		{type = "item", name = "compressed-moon-turf", amount = 1}
    },
	results = {
		{type = "item", name = "moon-dust", amount = 9 },
    }
}
create_item{ skip_recipe = true,
	name = "extraterrestrial-metal-mixture",
	subgroup = "subgroup-hv-centrifuge-recipes",
} 
create_recipe{
	recipe_name = "moon-dust-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 5,
	ingredients = {
		{type = "item", name = "moon-dust", amount = 1}
    },
	results = {
		{type = "item", name = "stone-dust", amount = 1, probability = 0.25 },
		{type = "item", name = "bauxite-dust", amount = 1, probability = 0.23 },
		{type = "item", name = "silicon-dioxide", amount = 1, probability = 0.2 },
		{type = "item", name = "quicklime", amount = 1, probability = 0.14 },
		{type = "item", name = "molybdenum-dust", amount = 1, probability = 0.1 },
		{type = "item", name = "extraterrestrial-metal-mixture", amount = 1, probability = 0.08 },
		{type = "fluid", name = "deuterium", amount = 10 },
    },
	main_product = "deuterium"
}
create_item{ skip_recipe = true,
	name = "mysterious-crystal-dust",
	subgroup = "subgroup-hv-centrifuge-recipes",
}
create_recipe{
	recipe_name = "extraterrestrial-metal-mixture-centrifuging",
	category = "hv-centrifuge-recipes",
	energy_required = HV_SPEED * 50,
	ingredients = {
		{type = "item", name = "moon-dust", amount = 1}
    },
	results = {
		{type = "item", name = "ilmenite-dust", amount = 1, probability = 0.6 },
		{type = "item", name = "chromium-dust", amount = 1, probability = 0.4 },
		{type = "item", name = "pyrolusite-dust", amount = 1, probability = 0.35 },
		{type = "item", name = "molybdenum-dust", amount = 1, probability = 0.22 },
		{type = "item", name = "tungstate-dust", amount = 1, probability = 0.17 },
		{type = "item", name = "mysterious-crystal-dust", amount = 1, probability = 0.1 },
    },
	main_product = "mysterious-crystal-dust"
}