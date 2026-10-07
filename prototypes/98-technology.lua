--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UMV 2048	UXV 4096

---TODO: Make a rare earth vein at mm t9 or t10 (cadmium, caesium, lanthanum, cerium)

microverse_resources = {
	  { type = "unlock-recipe", recipe = "microminer-magnetite" },
      { type = "unlock-recipe", recipe = "microminer-coal" },
      { type = "unlock-recipe", recipe = "microminer-salt" },
      { type = "unlock-recipe", recipe = "microminer-cassiterite" },
      { type = "unlock-recipe", recipe = "microminer-copper-tin" },
      { type = "unlock-recipe", recipe = "microminer-redstone" }, 
      { type = "unlock-recipe", recipe = "microminer-basaltic-mineral-sands" },
      { type = "unlock-recipe", recipe = "microminer-apatite" },
      { type = "unlock-recipe", recipe = "microminer-clay" },
	  { type = "unlock-recipe", recipe = "microminer-nickel" },
      { type = "unlock-recipe", recipe = "microminer-tetrahedrite" },
      { type = "unlock-recipe", recipe = "microminer-lapis" },
      { type = "unlock-recipe", recipe = "microminer-galena" },
      { type = "unlock-recipe", recipe = "microminer-diamond" }
}
if YAFC_MODE then microverse_resources = { type = "unlock-recipe", recipe = "crafting-table" } end

data:extend({

---PUNCH TREES
  {
    type = "technology",
    name = "punch-trees",
    icon = "__gregtorio-continued__/graphics/technology/punch-trees.png",
    icon_size = 256,
    effects = 	{
		{ type = "unlock-recipe", recipe = "manual-digsite" },
		{ type = "unlock-recipe", recipe = "manually-digging-gravel" },
		{ type = "unlock-recipe", recipe = "flint-crafting-table" },
		{ type = "unlock-recipe", recipe = "crafting-table" }
	},
    enabled = true,
	research_trigger = {
		type = "craft-item",
		item = "wood",
		count = 10
	  }
  },
  
  

---MAKE CRAFTING TABLES  
  {
    type = "technology",
    name = "automation",
    icon = "__gregtorio-continued__/graphics/technology/make-crafting-tables.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "plank-crafting-table" },
      { type = "unlock-recipe", recipe = "stick-crafting-table" },
      { type = "unlock-recipe", recipe = "wooden-pickaxe" },
      { type = "unlock-recipe", recipe = "chest-crafting-table" }
    },
	prerequisites = { "punch-trees" },
    research_trigger = {
      type = "craft-item",
      item = "crafting-table",
      count = 4
    }
  },



---CRAFT WOODEN TOOLS
  {
    type = "technology",
    name = "craft-wooden-tools",
    icon = "__gregtorio-continued__/graphics/technology/craft-wooden-tools.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "manual-mine" },
      { type = "unlock-recipe", recipe = "stone-pickaxe" },
      { type = "unlock-recipe", recipe = "cobblestone-manual-mine-with-wooden-pickaxe" },
    },
	prerequisites = { "automation" },
    research_trigger = {
      type = "craft-item",
      item = "wooden-pickaxe",
      count = 10
    }
  },
  
  
  
---CRAFT STONE TOOLS
  {
    type = "technology",
    name = "craft-stone-tools",
    icon = "__gregtorio-continued__/graphics/technology/craft-stone-tools.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "furnace-crafting-table" },
      { type = "unlock-recipe", recipe = "mining-iron-vein-with-stone-pickaxe" },	  
      { type = "unlock-recipe", recipe = "raw-iron-smelter" },
      { type = "unlock-recipe", recipe = "charcoal-smelter" },
    },
	prerequisites = { "craft-wooden-tools" },
    research_trigger = {
      type = "craft-item",
      item = "stone-pickaxe",
      count = 10
    }
  },
  
  
  
---SMELT IRON INGOTS
  {
    type = "technology",
    name = "smelt-iron-ingots",
    icon = "__gregtorio-continued__/graphics/technology/smelt-iron-ingots.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "iron-plate-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-rod-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-bolt-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-screw-crafting-table" },
	  { type = "unlock-recipe", recipe = "iron-chest-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-pickaxe-usage" },
      { type = "unlock-recipe", recipe = "cobblestone-manual-mine" },
      { type = "unlock-recipe", recipe = "mining-iron-vein" },
      { type = "unlock-recipe", recipe = "mining-coal-vein" },
      { type = "unlock-recipe", recipe = "raw-coal-smelter" },
      { type = "unlock-recipe", recipe = "iron-shovel-usage" },	  
      { type = "unlock-recipe", recipe = "gravel-with-shovel" }
    },
	prerequisites = { "craft-stone-tools" },
    research_trigger = {
      type = "craft-item",
      item = "iron-ingot",
      count = 10
    }
  },
  
  
  
---CRAFT IRON TOOLS  
  {
    type = "technology",
    name = "craft-iron-tools",
    icon = "__gregtorio-continued__/graphics/technology/craft-iron-tools.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "smooth-stone" },
      { type = "unlock-recipe", recipe = "stone-bricks" },
	  { type = "unlock-recipe", recipe = "mining-chalcopyrite-vein" },
	  { type = "unlock-recipe", recipe = "raw-copper-smelter" },
      { type = "unlock-recipe", recipe = "copper-plate-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-gear-crafting-table" },
      { type = "unlock-recipe", recipe = "iron-axe" },
      { type = "unlock-recipe", recipe = "chop-trees" },
      { type = "unlock-recipe", recipe = "automation-science-pack" }
    },
	prerequisites = { "smelt-iron-ingots" },
    research_trigger = {
      type = "craft-item",
      item = "iron-pickaxe-usage",
      count = 100
    }
  },
  
  
  
---AUTOMATION SCIENCE
  {
    type = "technology",
    name = "craft-automation-science-packs",
    icon = "__base__/graphics/technology/automation-science-pack.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "manual-research-lab" }
    },
	prerequisites = { "craft-iron-tools" },
	research_trigger = {
		type = "craft-item",
		item = "automation-science-pack",
		count = 10
	  }
  },



  ---LOGISTICS
  {
    type = "technology",
    name = "logistics",
    icon = "__base__/graphics/technology/logistics-1.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "transport-belt" },
	  { type = "unlock-recipe", recipe = "underground-belt" },
      { type = "unlock-recipe", recipe = "splitter" },
      { type = "unlock-recipe", recipe = "manual-inserter-crafting-table" },
    },
	prerequisites = { "craft-automation-science-packs" },
	unit =
	  {
		  count = 10,
		  ingredients = {{"automation-science-pack", SP01}},
		  time = 10
	  }
  },
  
  
  
  ---IRON FURNACE
  {
    type = "technology",
    name = "iron-furnace",
    icon = "__gregtorio-continued__/graphics/technology/iron-furnace.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "iron-furnace-crafting-table" }
    },
	prerequisites = { "craft-automation-science-packs" },
	unit =
	  {
		  count = 10,
		  ingredients = {{"automation-science-pack", SP01}},
		  time = 10
	  }
  },
  
  

  ---BASIC BACKPACK
  {
    type = "technology",
    name = "basic-backpack",
    icon = "__gregtorio-continued__/graphics/technology/basic-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "craft-automation-science-packs" },
	unit =
	  {
		  count = 10,
		  ingredients = {{"automation-science-pack", SP01}},
		  time = 10
	  }
  },  
  


-------------------
---  STEAM AGE  ---
-------------------  



---SMALL COAL BOILER
  {
    type = "technology",
    name = "small-coal-boiler",
    icon = "__gregtorio-continued__/graphics/technology/small-coal-boiler.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "empty-bucket" },
      { type = "unlock-recipe", recipe = "bucket-of-water" },
	  { type = "unlock-recipe", recipe = "mining-cassiterite-vein" },
      { type = "unlock-recipe", recipe = "raw-tin-smelter" },
      { type = "unlock-recipe", recipe = "raw-cassiterite-smelter" },
	  { type = "unlock-recipe", recipe = "mortar-and-pestle" },
	  { type = "unlock-recipe", recipe = "copper-ingot-to-copper-dust" },
	  { type = "unlock-recipe", recipe = "tin-ingot-to-tin-dust" },
      { type = "unlock-recipe", recipe = "copper-dust-smelter" },
      { type = "unlock-recipe", recipe = "tin-dust-smelter" },
      { type = "unlock-recipe", recipe = "cassiterite-dust-smelter" },
      { type = "unlock-recipe", recipe = "bronze-dust-crafting-table" },
      { type = "unlock-recipe", recipe = "bronze-dust-smelter" },
      { type = "unlock-recipe", recipe = "bronze-plate-crafting-table" },
      { type = "unlock-recipe", recipe = "pipe-crafting-table" },
      { type = "unlock-recipe", recipe = "pipe-to-ground" },
      { type = "unlock-recipe", recipe = "offshore-pump" },
      { type = "unlock-recipe", recipe = "clay-ball-manual-digsite" },
      { type = "unlock-recipe", recipe = "brick-smelter" },
      { type = "unlock-recipe", recipe = "brick-block-crafting-table" },
      { type = "unlock-recipe", recipe = "small-coal-boiler" }
    },
	prerequisites = { "iron-furnace" },
	unit =
	  {
		  count = 10,
		  ingredients = {{"automation-science-pack", SP01}},
		  time = 10
	  }
  },
  


---STEAM ALLOY SMELTER
  {
    type = "technology",
    name = "steam-alloy-smelter",
    icon = "__gregtorio-continued__/graphics/technology/steam-alloy-smelter.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "steam-alloy-smelter" },
      { type = "unlock-recipe", recipe = "bronze-ingot-alloy-smelter" }
    },
	prerequisites = { "small-coal-boiler" },
	unit =
	{
      count = 10,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },

  
  
---STEAM COMPRESSOR
  {
    type = "technology",
    name = "steam-compressor",
    icon = "__gregtorio-continued__/graphics/technology/steam-compressor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-redstone-vein" },
      { type = "unlock-recipe", recipe = "raw-redstone-smelter" },
      { type = "unlock-recipe", recipe = "raw-ruby-smelter" },
      { type = "unlock-recipe", recipe = "raw-cinnabar-smelter" },
      { type = "unlock-recipe", recipe = "red-alloy-ingot" },
      { type = "unlock-recipe", recipe = "red-alloy-plate-crafting-table" },
      { type = "unlock-recipe", recipe = "piston" },
      { type = "unlock-recipe", recipe = "steam-compressor" },
      { type = "unlock-recipe", recipe = "block-of-iron" }
    },
	prerequisites = { "steam-alloy-smelter" },
	unit =
	{
      count = 20,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },
  
  
  
  ---STEAM FORGE HAMMER
  {
    type = "technology",
    name = "steam-forge-hammer",
    icon = "__gregtorio-continued__/graphics/technology/steam-forge-hammer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "anvil" },
      { type = "unlock-recipe", recipe = "steam-forge-hammer" },
      { type = "unlock-recipe", recipe = "iron-plate-forge-hammer" },
      { type = "unlock-recipe", recipe = "copper-plate-forge-hammer" },
      { type = "unlock-recipe", recipe = "bronze-plate-forge-hammer" },
      { type = "unlock-recipe", recipe = "red-alloy-plate-forge-hammer" }
    },
	prerequisites = { "steam-compressor" },
	unit =
	{
      count = 20,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },
  
  
  
---STEAM MACERATOR
  {
    type = "technology",
    name = "steam-macerator",
    icon = "__gregtorio-continued__/graphics/technology/steam-macerator.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-diamond-vein" },
      { type = "unlock-recipe", recipe = "raw-graphite-smelter" },
      { type = "unlock-recipe", recipe = "raw-diamond-smelter" },
      { type = "unlock-recipe", recipe = "steam-macerator" },
      { type = "unlock-recipe", recipe = "wood-pulp" },
      { type = "unlock-recipe", recipe = "gravel" },
      { type = "unlock-recipe", recipe = "sand" },
      { type = "unlock-recipe", recipe = "flint" },
      { type = "unlock-recipe", recipe = "brick-dust" },
      { type = "unlock-recipe", recipe = "clay-dust" },
      { type = "unlock-recipe", recipe = "copper-dust-macerator" },
      { type = "unlock-recipe", recipe = "tin-dust-macerator" },
    },
	prerequisites = { "steam-compressor" },
	unit =
	{
      count = 20,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },
  
  
  
---COKE OVENS
  {
    type = "technology",
    name = "coke-oven",
    icon = "__gregtorio-continued__/graphics/technology/coke-oven.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "sand-manual-digsite" },
      { type = "unlock-recipe", recipe = "coke-oven-brick" },
      { type = "unlock-recipe", recipe = "coke-oven-block" },
      { type = "unlock-recipe", recipe = "coke-oven" },
      { type = "unlock-recipe", recipe = "coke-coke-oven" }
    },
	prerequisites = { "steam-compressor" },
	unit =
	{
      count = 20,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },



---PRIMITIVE BLAST FURNACES
  {
    type = "technology",
    name = "steel-processing",
    icon = "__gregtorio-continued__/graphics/technology/primitive-blast-furnace.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-basaltic-mineral-sands-vein" },
      { type = "unlock-recipe", recipe = "raw-fullers-earth-smelter" },
      { type = "unlock-recipe", recipe = "raw-gypsum-smelter" },
      { type = "unlock-recipe", recipe = "gypsum" },
      { type = "unlock-recipe", recipe = "mining-lapis-vein" },
      { type = "unlock-recipe", recipe = "raw-lazurite-smelter" },
      { type = "unlock-recipe", recipe = "raw-sodalite-smelter" },
      { type = "unlock-recipe", recipe = "raw-lapis-smelter" },
      { type = "unlock-recipe", recipe = "raw-calcite-smelter" },
      { type = "unlock-recipe", recipe = "calcite" },
      { type = "unlock-recipe", recipe = "compressed-firebrick" },
      { type = "unlock-recipe", recipe = "quartz-sand" },
      { type = "unlock-recipe", recipe = "stone-dust" },
      { type = "unlock-recipe", recipe = "liquid-concrete-bucket" },
      { type = "unlock-recipe", recipe = "fireclay-dust" },
      { type = "unlock-recipe", recipe = "firebrick" },
      { type = "unlock-recipe", recipe = "firebrick-block" },
      { type = "unlock-recipe", recipe = "primitive-blast-furnace" },
      { type = "unlock-recipe", recipe = "steel-ingot-pbf" },
      { type = "unlock-recipe", recipe = "steel-plate-forge-hammer" }
    },
	prerequisites = { "steam-macerator", "steam-forge-hammer", "coke-oven", "iron-furnace" },
	unit =
	{
      count = 30,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },
  
  
  
---STEEL BACKPACK
  {
    type = "technology",
    name = "steel-backpack",
    icon = "__gregtorio-continued__/graphics/technology/steel-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "steel-processing", "basic-backpack" },
	unit =
	{
      count = 30,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },
  


---GLASSMAKING
  {
    type = "technology",
    name = "glassmaking",
    icon = "__gregtorio-continued__/graphics/technology/glassmaking.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "flint-dust" },
      { type = "unlock-recipe", recipe = "glass-dust-crafting-table" },
      { type = "unlock-recipe", recipe = "glass-alloy-smelter" },
      { type = "unlock-recipe", recipe = "mold" }
    },
	prerequisites = { "steel-processing" },
	unit =
	{
      count = 30,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },



---STEAM EXTRACTOR
  {
    type = "technology",
    name = "steam-extractor",
    icon = "__gregtorio-continued__/graphics/technology/steam-extractor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "steam-extractor" },
      { type = "unlock-recipe", recipe = "sticky-resin" }
    },
	prerequisites = { "glassmaking" },
	unit =
	{
      count = 40,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },
  
  

---RUBBER
  {
    type = "technology",
    name = "rubber",
    icon = "__gregtorio-continued__/graphics/technology/rubber.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "raw-rubber-pulp-extractor" },
      { type = "unlock-recipe", recipe = "mining-sphalerite-vein" },
      { type = "unlock-recipe", recipe = "raw-sulfur-smelter" },
      { type = "unlock-recipe", recipe = "sulfur" },
      { type = "unlock-recipe", recipe = "raw-sphalerite-smelter" },
      { type = "unlock-recipe", recipe = "rubber-sheet-alloy-smelter" }
    },
	prerequisites = { "steam-extractor" },
	unit =
	{
      count = 40,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },



---PRIMITIVE ELECTRONICS
  {
    type = "technology",
    name = "primitive-electronics",
    icon = "__gregtorio-continued__/graphics/technology/primitive-electronics.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "paper-crafting-table" },
      { type = "unlock-recipe", recipe = "copper-foil-crafting-table" },
      { type = "unlock-recipe", recipe = "fine-copper-wire-crafting-table" },
      { type = "unlock-recipe", recipe = "coal-dust" },
      { type = "unlock-recipe", recipe = "resistor-crafting-table" },
      { type = "unlock-recipe", recipe = "glass-tube-alloy-smelter" },
      { type = "unlock-recipe", recipe = "copper-wire-crafting-table" },
      { type = "unlock-recipe", recipe = "steel-rod-crafting-table" },
      { type = "unlock-recipe", recipe = "steel-bolt-crafting-table" },
      { type = "unlock-recipe", recipe = "vacuum-tube-crafting-table" },
      { type = "unlock-recipe", recipe = "resin-circuit-board-crafting-table" },
      { type = "unlock-recipe", recipe = "resin-printed-circuit-board-crafting-table" },
      { type = "unlock-recipe", recipe = "red-alloy-wire-crafting-table" },
      { type = "unlock-recipe", recipe = "red-alloy-cable-crafting-table" },
      { type = "unlock-recipe", recipe = "electronic-circuit" },
    },
	prerequisites = { "rubber" },
	unit =
	{
      count = 50,
      ingredients = {{"automation-science-pack", SP01}},
      time = 15
	}
  },
  

  
---STEAM TURBINES
  {
    type = "technology",
    name = "steam-turbine",
    icon = "__gregtorio-continued__/graphics/technology/steam-turbine.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "tin-plate-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-plate-forge-hammer" },
      { type = "unlock-recipe", recipe = "tin-rod-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-ring-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-bolt-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-screw-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-rotor-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-wire-crafting-table" },
      { type = "unlock-recipe", recipe = "tin-cable-crafting-table" },
      { type = "unlock-recipe", recipe = "lv-machine-casing" },
      { type = "unlock-recipe", recipe = "lv-machine-hull-crafting-table" },
      { type = "unlock-recipe", recipe = "magnetic-iron-rod-crafting-table" },
      { type = "unlock-recipe", recipe = "lv-motor" },
      { type = "unlock-recipe", recipe = "lv-steam-turbine" },
      { type = "unlock-recipe", recipe = "small-electric-pole" }
    },
	prerequisites = { "primitive-electronics" },
	unit =
	{
      count = 50,
      ingredients = { {"automation-science-pack", SP01} },
      time = 20
	}
  },
  


------------------------
---  LOW VOLTAGE AGE ---
------------------------

  

---WIREMILL
  {
    type = "technology",
    name = "wiremill",
    icon = "__gregtorio-continued__/graphics/technology/wiremill.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-wiremill" },
      { type = "unlock-recipe", recipe = "copper-wire" },
      { type = "unlock-recipe", recipe = "fine-copper-wire" },
      { type = "unlock-recipe", recipe = "tin-wire" },
      { type = "unlock-recipe", recipe = "red-alloy-wire" }
    },
	prerequisites = { "steam-turbine" },
	unit =
	{
      count = 60,
      ingredients = { {"automation-science-pack", SP01} },
      time = 20
	}
  }, 
  


---BENDING MACHINE
  {
    type = "technology",
    name = "bending-machine",
    icon = "__gregtorio-continued__/graphics/technology/bending-machine.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "steel-gear-crafting-table" },
      { type = "unlock-recipe", recipe = "lv-piston" },
      { type = "unlock-recipe", recipe = "lv-bending-machine" },
      { type = "unlock-recipe", recipe = "iron-plate" },
      { type = "unlock-recipe", recipe = "copper-plate" },
      { type = "unlock-recipe", recipe = "copper-foil" },
      { type = "unlock-recipe", recipe = "steel-plate" },
      { type = "unlock-recipe", recipe = "tin-plate" },
      { type = "unlock-recipe", recipe = "red-alloy-plate" },
      { type = "unlock-recipe", recipe = "bronze-plate" },
      { type = "unlock-recipe", recipe = "lv-compressor" },
    },
	prerequisites = { "steam-turbine" },
	unit =
	{
      count = 60,
      ingredients = { {"automation-science-pack", SP01} },
      time = 20
	}
  },  



---LV SCIENCE PACK
  {
    type = "technology",
    name = "logistic-science-pack",
    icon = "__base__/graphics/technology/logistic-science-pack.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "lab" },
	  { type = "unlock-recipe", recipe = "inserter" },
	  { type = "unlock-recipe", recipe = "long-handed-inserter" },
	  { type = "unlock-recipe", recipe = "lv-science-pack" },
    },
	prerequisites = { "wiremill", "bending-machine" },
	unit =
	{
      count = 60,
      ingredients = { {"automation-science-pack", SP01} },
      time = 20
	}
  },  


  
---POLARIZER
  {
    type = "technology",
    name = "polarizer",
    icon = "__gregtorio-continued__/graphics/technology/polarizer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-polarizer" },
      { type = "unlock-recipe", recipe = "magnetic-iron-rod" }
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
  
  
---LV MIXER
  {
    type = "technology",
    name = "mixer",
    icon = "__gregtorio-continued__/graphics/technology/mixer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-mixer" },
      { type = "unlock-recipe", recipe = "bronze-dust" },
      { type = "unlock-recipe", recipe = "glass-dust" }
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
  
  
---LV EXTRACTOR
  {
    type = "technology",
    name = "extractor",
    icon = "__gregtorio-continued__/graphics/technology/extractor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "rubber-ring-crafting-table" },
      { type = "unlock-recipe", recipe = "lv-pump" },
      { type = "unlock-recipe", recipe = "lv-extractor" }
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },  



---SEMIFLUID GENERATOR
  {
    type = "technology",
    name = "semifluid-generator",
    icon = "__gregtorio-continued__/graphics/technology/gas-turbine.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "lv-canning-machine" },   
      { type = "unlock-recipe", recipe = "empty-large-steel-fluid-cell" },
      { type = "unlock-recipe", recipe = "bronze-ring-crafting-table" },
      { type = "unlock-recipe", recipe = "creosote-cell" },
      { type = "unlock-recipe", recipe = "large-steel-gear-crafting-table" },	  
      { type = "unlock-recipe", recipe = "lv-semifluid-generator" },    
    },
	prerequisites = { "extractor" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },   
  
  
  
---LV ROCK CRUSHER
  {
    type = "technology",
    name = "rock-crusher",
    icon = "__gregtorio-continued__/graphics/technology/rock-crusher.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-rock-crusher" },
      { type = "unlock-recipe", recipe = "rock-crusher-cobblestone" }
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
  
  
---LV LATHE
  {
    type = "technology",
    name = "lathe",
    icon = "__gregtorio-continued__/graphics/technology/lathe.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-lathe" },
      { type = "unlock-recipe", recipe = "tin-rod" },
      { type = "unlock-recipe", recipe = "iron-stick" },
      { type = "unlock-recipe", recipe = "bronze-rod" },
      { type = "unlock-recipe", recipe = "steel-rod" },
      { type = "unlock-recipe", recipe = "tin-screw" },
      { type = "unlock-recipe", recipe = "iron-screw" },
      { type = "unlock-recipe", recipe = "stick" }
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },



---LV ELECTROLYZER
  {
    type = "technology",
    name = "electrolyzer",
    icon = "__gregtorio-continued__/graphics/technology/electrolyzer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-magnetite-vein" },
      { type = "unlock-recipe", recipe = "raw-vanadium-magnetite-smelter" },
      { type = "unlock-recipe", recipe = "raw-gold-smelter" },
      { type = "unlock-recipe", recipe = "gold-wire" },
      { type = "unlock-recipe", recipe = "lv-electrolyzer" },
      { type = "unlock-recipe", recipe = "water-electrolysis" },
    },
	prerequisites = { "logistic-science-pack" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
  
  
---LV ASSEMBLING MACHINE
  {
    type = "technology",
    name = "automation-2",
    icon = "__gregtorio-continued__/graphics/technology/assembling-machine.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-conveyor-module" },
      { type = "unlock-recipe", recipe = "lv-robot-arm" },
      { type = "unlock-recipe", recipe = "lv-assembling-machine" },
      { type = "unlock-recipe", recipe = "chest" },
      { type = "unlock-recipe", recipe = "iron-chest" },
      { type = "unlock-recipe", recipe = "stone-furnace" },
      { type = "unlock-recipe", recipe = "iron-furnace" },
      { type = "unlock-recipe", recipe = "burner-inserter" },
    },
	prerequisites = { "extractor" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },


  


---CIRCUIT NETWORK
  {
    type = "technology",
    name = "circuit-network",
    icon = "__base__/graphics/technology/circuit-network.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "arithmetic-combinator" },
      { type = "unlock-recipe", recipe = "decider-combinator" },
      { type = "unlock-recipe", recipe = "constant-combinator" },
      { type = "unlock-recipe", recipe = "display-panel" },
      { type = "unlock-recipe", recipe = "power-switch" },
    },
	prerequisites = { "automation-2" },
	unit =
	{
      count = 80,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  


---ORE CRUSHING
  {
    type = "technology",
    name = "ore-crushing",
    icon = "__gregtorio-continued__/graphics/technology/ore-crushing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-macerator" },
      { type = "unlock-recipe", recipe = "crushed-iron" },
      { type = "unlock-recipe", recipe = "crushed-vanadium-magnetite" },
      { type = "unlock-recipe", recipe = "crushed-gold" },
      { type = "unlock-recipe", recipe = "crushed-fullers-earth" },
      { type = "unlock-recipe", recipe = "crushed-copper" },
      { type = "unlock-recipe", recipe = "crushed-cassiterite" },
      { type = "unlock-recipe", recipe = "macerating-raw-tin" },
      { type = "unlock-recipe", recipe = "crushed-sphalerite" },
      { type = "unlock-recipe", recipe = "crushed-redstone" },
      { type = "unlock-recipe", recipe = "crushed-ruby" },
      { type = "unlock-recipe", recipe = "crushed-cinnabar" },
      { type = "unlock-recipe", recipe = "crushed-coal" },
      { type = "unlock-recipe", recipe = "crushed-graphite" },
      { type = "unlock-recipe", recipe = "crushed-diamond" },
      { type = "unlock-recipe", recipe = "crushed-lazurite" },
      { type = "unlock-recipe", recipe = "crushed-sodalite" },
      { type = "unlock-recipe", recipe = "crushed-lapis" },
    },
	prerequisites = { "wiremill", "bending-machine" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
   
  
---ORE WASHING
  {
    type = "technology",
    name = "ore-washing",
    icon = "__gregtorio-continued__/graphics/technology/ore-washing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-ore-washer" },
      { type = "unlock-recipe", recipe = "iron-dust" },
      { type = "unlock-recipe", recipe = "iron-dust-smelter" },
      { type = "unlock-recipe", recipe = "vanadium-magnetite-dust" },
      { type = "unlock-recipe", recipe = "vanadium-magnetite-dust-smelter" },
      { type = "unlock-recipe", recipe = "gold-dust" },
      { type = "unlock-recipe", recipe = "gold-dust-smelter" },
      { type = "unlock-recipe", recipe = "fullers-earth" },
      { type = "unlock-recipe", recipe = "copper-dust" },
      { type = "unlock-recipe", recipe = "tin-dust" },
      { type = "unlock-recipe", recipe = "cassiterite-dust" },
      { type = "unlock-recipe", recipe = "sphalerite-dust" },
      { type = "unlock-recipe", recipe = "zinc-dust-smelter" },
      { type = "unlock-recipe", recipe = "redstone-dust" },
      { type = "unlock-recipe", recipe = "ruby-dust" },
      { type = "unlock-recipe", recipe = "cinnabar-dust" },
      { type = "unlock-recipe", recipe = "coal-dust" },
      { type = "unlock-recipe", recipe = "graphite" },
      { type = "unlock-recipe", recipe = "diamond-dust" },
      { type = "unlock-recipe", recipe = "lazurite-dust" },
      { type = "unlock-recipe", recipe = "sodalite-dust" },
      { type = "unlock-recipe", recipe = "lapis-dust" },
    },
	prerequisites = { "ore-crushing" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },


  
---ORE CENTRIFUGING
  {
    type = "technology",
    name = "ore-centrifuging",
    icon = "__gregtorio-continued__/graphics/technology/ore-centrifuging.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-centrifuge" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-iron" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-vanadium-magnetite" },
      { type = "unlock-recipe", recipe = "centrifuge-vanadium-magnetite-dust" },   
      { type = "unlock-recipe", recipe = "centrifuging-crushed-gold" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-fullers-earth" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-copper" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-tin" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-cassiterite" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-sphalerite" },
      { type = "unlock-recipe", recipe = "sphalerite-dust-smelter" },
      { type = "unlock-recipe", recipe = "sphalerite-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-redstone" },
      { type = "unlock-recipe", recipe = "centrifuge-redstone" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-ruby" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-cinnabar" },
      { type = "unlock-recipe", recipe = "cinnabar-centrifuging" }, 
      { type = "unlock-recipe", recipe = "centrifuging-crushed-coal" },
      { type = "unlock-recipe", recipe = "centrifuge-coal-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-graphite" },
      { type = "unlock-recipe", recipe = "graphite-electrolysis" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-diamond" },
      { type = "unlock-recipe", recipe = "diamond-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-lazurite" },
      { type = "unlock-recipe", recipe = "lazurite-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-sodalite" },
      { type = "unlock-recipe", recipe = "sodalite-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-lapis" },
      { type = "unlock-recipe", recipe = "lapis-dust-electrolysis" },
    },
	prerequisites = { "ore-washing", "electrolyzer" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },    
    

  
---TRASH CANS
  {
    type = "technology",
    name = "trash-cans",
    icon = "__gregtorio-continued__/graphics/technology/trash-cans.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "trash-can" },
      { type = "unlock-recipe", recipe = "fluid-trash-can" },
    },
	prerequisites = { "coke-oven" },
	unit =
	{
      count = 30,
      ingredients = { {"automation-science-pack", SP01} },
      time = 10
	}
  },  



  ---FAST INSERTER
  {
    type = "technology",
    name = "fast-inserter",
    icon = "__base__/graphics/technology/fast-inserter.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "fast-inserter" },
    },
	prerequisites = { "automation-2" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },



  ---ELECTRIC ENERGY DISTRIBUTION
  {
    type = "technology",
    name = "electric-energy-distribution-1",
    icon = "__base__/graphics/technology/electric-energy-distribution-1.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "medium-electric-pole" },
      { type = "unlock-recipe", recipe = "big-electric-pole" },
    },
	prerequisites = { "automation-2" },
	unit =
	{
      count = 100,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  


---LARGE BRONZE BOILER
  {
    type = "technology",
    name = "large-bronze-boiler",
    icon = "__gregtorio-continued__/graphics/technology/large-bronze-boiler.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "bronze-frame" },
      { type = "unlock-recipe", recipe = "steam-machine-casing" },
      { type = "unlock-recipe", recipe = "bronze-pipe-casing" },
      { type = "unlock-recipe", recipe = "bronze-firebox-casing" },
      { type = "unlock-recipe", recipe = "large-bronze-boiler-controller" },
      { type = "unlock-recipe", recipe = "large-bronze-boiler" }
    },
	prerequisites = { "automation-2", "lathe" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  }, 



---GALENA
  {
    type = "technology",
    name = "galena",
    icon = "__gregtorio-continued__/graphics/technology/galena-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-galena-vein" },
      { type = "unlock-recipe", recipe = "raw-galena-smelter" },
      { type = "unlock-recipe", recipe = "crushed-galena" },
      { type = "unlock-recipe", recipe = "galena-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-galena" },
      { type = "unlock-recipe", recipe = "galena-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-lead-smelter" },
      { type = "unlock-recipe", recipe = "crushed-lead" },
      { type = "unlock-recipe", recipe = "lead-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-lead" },
      { type = "unlock-recipe", recipe = "lead-dust-smelter" },
      { type = "unlock-recipe", recipe = "raw-silver-smelter" },
      { type = "unlock-recipe", recipe = "crushed-silver" },
      { type = "unlock-recipe", recipe = "silver-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-silver" },
      { type = "unlock-recipe", recipe = "silver-dust-smelter" },
      { type = "unlock-recipe", recipe = "raw-cryolite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-cryolite" },
      { type = "unlock-recipe", recipe = "cryolite" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-cryolite" },
    },
	prerequisites = { "electrolyzer" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },

  
  
---SOLDERING ALLOY
  {
    type = "technology",
    name = "soldering-alloy",
    icon = "__gregtorio-continued__/graphics/technology/soldering-alloy.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-tetrahedrite-vein" },
      { type = "unlock-recipe", recipe = "raw-tetrahedrite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-tetrahedrite" },
      { type = "unlock-recipe", recipe = "tetrahedrite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-tetrahedrite" },
      { type = "unlock-recipe", recipe = "tetrahedrite-dust-smelter" },
      { type = "unlock-recipe", recipe = "tetrahedrite-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-stibnite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-stibnite" },
      { type = "unlock-recipe", recipe = "antimony" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-stibnite" },
      { type = "unlock-recipe", recipe = "lead-dust-macerator" },
      { type = "unlock-recipe", recipe = "soldering-alloy-dust" },
      { type = "unlock-recipe", recipe = "soldering-alloy" },
    },
	prerequisites = { "mixer", "electrolyzer", "ore-centrifuging", "galena" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  }, 
  
  
  
  ---IMPROVED ELECTRONIC PARTS
  {
    type = "technology",
    name = "improved-electronic-parts",
    icon = "__gregtorio-continued__/graphics/technology/primitive-electronics.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "resin-circuit-board" },
      { type = "unlock-recipe", recipe = "resin-printed-circuit-board" },
      { type = "unlock-recipe", recipe = "centrifuging-sticky-resin" },
      { type = "unlock-recipe", recipe = "resistor" },
      { type = "unlock-recipe", recipe = "molten-red-alloy" },
      { type = "unlock-recipe", recipe = "vacuum-tube" }
    },
	prerequisites = { "ore-centrifuging", "automation-2" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 20
	}
  },
  
  
  
---PYROLYSE OVEN
  {
    type = "technology",
    name = "pyrolyse-oven",
    icon = "__gregtorio-continued__/graphics/technology/pyrolyse-oven.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "ulv-machine-casing" },
      { type = "unlock-recipe", recipe = "ulv-machine-hull" },
      { type = "unlock-recipe", recipe = "pyrolyse-oven-controller" },
      { type = "unlock-recipe", recipe = "mv-pyrolyse-oven" },
      { type = "unlock-recipe", recipe = "phenol-from-coal" },
      { type = "unlock-recipe", recipe = "phenol-from-coal-dust" }
    },
	prerequisites = { "electric-blast-furnace" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  


---BASIC AIR CENTRIFUGING
  {
    type = "technology",
    name = "basic-air-centrifuging",
    icon = "__gregtorio-continued__/graphics/technology/basic-air-centrifuging.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "zinc-foil" },
      { type = "unlock-recipe", recipe = "filter" },
      { type = "unlock-recipe", recipe = "lv-air-collector" },
      { type = "unlock-recipe", recipe = "air-collection" },
      { type = "unlock-recipe", recipe = "basic-air-centrifuging" }
    },
	prerequisites = { "invar" },
	unit =
	{
      count = 140,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---LV CHEMICAL REACTOR
  {
    type = "technology",
    name = "chemical-reactor",
    icon = "__gregtorio-continued__/graphics/technology/chemical-reactor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-chemical-reactor" },
      { type = "unlock-recipe", recipe = "liquid-rubber" },
      { type = "unlock-recipe", recipe = "tin-cable" },
      { type = "unlock-recipe", recipe = "red-alloy-cable" },
      { type = "unlock-recipe", recipe = "lv-chemical-bath" }
    },
	prerequisites = { "automation-2" },
	unit =
	{
      count = 140,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  

  
---HYDROCHLORIC ACID
  {
    type = "technology",
    name = "hydrochloric-acid",
    icon = "__gregtorio-continued__/graphics/technology/hydrochloric-acid.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-salt-vein" },
      { type = "unlock-recipe", recipe = "raw-salt-smelter" },
      { type = "unlock-recipe", recipe = "crushed-salt" },
      { type = "unlock-recipe", recipe = "salt" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-salt" },
      { type = "unlock-recipe", recipe = "salt-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-rock-salt-smelter" },
      { type = "unlock-recipe", recipe = "crushed-rock-salt" },
      { type = "unlock-recipe", recipe = "rock-salt" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-rock-salt" },
      { type = "unlock-recipe", recipe = "rock-salt-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-lepidolite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-lepidolite" },
      { type = "unlock-recipe", recipe = "lepidolite" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-lepidolite" },
      { type = "unlock-recipe", recipe = "hydrochloric-acid" },
    },
	prerequisites = { "chemical-reactor", "electrolyzer" },
	unit =
	{
      count = 140,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },



 ---PRIMITIVE ELECTRONIC CIRCUIT ASSEMBLIES
  {
    type = "technology",
    name = "primitive-electronic-circuit-assemblies",
    icon = "__gregtorio-continued__/graphics/technology/primitive-electronic-circuit-assemblies.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-copper-tin-vein" },
      { type = "unlock-recipe", recipe = "raw-realgar-smelter" },
      { type = "unlock-recipe", recipe = "crushed-realgar" },
      { type = "unlock-recipe", recipe = "realgar-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-realgar" },
      { type = "unlock-recipe", recipe = "centrifuge-realgar-dust" },
      { type = "unlock-recipe", recipe = "small-pile-of-gallium-arsenide" },
	  { type = "unlock-recipe", recipe = "molten-glass" },
      { type = "unlock-recipe", recipe = "glass-tube" },
	  { type = "unlock-recipe", recipe = "primitive-diode" },
      { type = "unlock-recipe", recipe = "phenolic-circuit-board" },
      { type = "unlock-recipe", recipe = "silver-foil" },
      { type = "unlock-recipe", recipe = "iron-dust-macerator" },
      { type = "unlock-recipe", recipe = "iron-iii-chloride" },
      { type = "unlock-recipe", recipe = "phenolic-printed-circuit-board" },
      { type = "unlock-recipe", recipe = "advanced-circuit" },
    },
	prerequisites = { "improved-electronic-parts", "pyrolyse-oven", "hydrochloric-acid", "galena" },
	unit =
	{
      count = 120,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },



---CIRCUIT ASSEMBLER
  {
    type = "technology",
    name = "circuit-assembler",
    icon = "__gregtorio-continued__/graphics/technology/circuit-assembler.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "mining-nether-quartz-vein" },
	  { type = "unlock-recipe", recipe = "raw-nether-quartz-smelter" },
	  { type = "unlock-recipe", recipe = "crushed-nether-quartz" },
	  { type = "unlock-recipe", recipe = "nether-quartz-dust" },
	  { type = "unlock-recipe", recipe = "centrifuging-crushed-nether-quartz" },
      { type = "unlock-recipe", recipe = "raw-certus-quartz-smelter" },
      { type = "unlock-recipe", recipe = "crushed-certus-quartz" },
      { type = "unlock-recipe", recipe = "certus-quartz-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-certus-quartz" },
      { type = "unlock-recipe", recipe = "raw-barite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-barite" },
      { type = "unlock-recipe", recipe = "barite" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-barite" },
      { type = "unlock-recipe", recipe = "zinc-dust-macerator" },
      { type = "unlock-recipe", recipe = "brass-dust" },
      { type = "unlock-recipe", recipe = "brass-dust-smelter" },
      { type = "unlock-recipe", recipe = "brass-ingot" },
      { type = "unlock-recipe", recipe = "brass-rod" },
      { type = "unlock-recipe", recipe = "lv-emitter" },
      { type = "unlock-recipe", recipe = "lv-circuit-assembler" },
	  { type = "unlock-recipe", recipe = "basic-electronic-circuit" },
	  { type = "unlock-recipe", recipe = "good-electronic-circuit" }
    },
	prerequisites = { "soldering-alloy", "primitive-electronic-circuit-assemblies" },
	unit =
	{
      count = 140,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  


---CONCRETE
  {
    type = "technology",
    name = "concrete",
    icon = "__base__/graphics/technology/concrete.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "liquid-concrete" },
      { type = "unlock-recipe", recipe = "lv-fluid-solidifier" },
      { type = "unlock-recipe", recipe = "glass-fluid-solidifier" },
      { type = "unlock-recipe", recipe = "rubber-sheet" },
      { type = "unlock-recipe", recipe = "rubber-ring" },
      { type = "unlock-recipe", recipe = "concrete" },
	  { type = "unlock-recipe", recipe = "hazard-concrete" },
	  { type = "unlock-recipe", recipe = "refined-concrete" },
	  { type = "unlock-recipe", recipe = "refined-hazard-concrete" },
    },
	prerequisites = { "mixer" },
	unit =
	{
      count = 140,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---INVAR
  {
    type = "technology",
    name = "invar",
    icon = "__gregtorio-continued__/graphics/technology/invar-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-alloy-smelter" },
      { type = "unlock-recipe", recipe = "mining-nickel-vein" },
      { type = "unlock-recipe", recipe = "raw-nickel-smelter" },
      { type = "unlock-recipe", recipe = "crushed-nickel" },
      { type = "unlock-recipe", recipe = "nickel-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-nickel" },
      { type = "unlock-recipe", recipe = "nickel-dust-smelter" },
      { type = "unlock-recipe", recipe = "raw-pentlandite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-pentlandite" },
      { type = "unlock-recipe", recipe = "pentlandite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-pentlandite" },
      { type = "unlock-recipe", recipe = "pentlandite-dust-smelter" },
      { type = "unlock-recipe", recipe = "pentlandite-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-cobaltite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-cobaltite" },
      { type = "unlock-recipe", recipe = "cobalt-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-cobaltite" },
      { type = "unlock-recipe", recipe = "invar-ingot" },
      { type = "unlock-recipe", recipe = "invar-plate" },
      { type = "unlock-recipe", recipe = "invar-rod" },
      { type = "unlock-recipe", recipe = "invar-frame" },
      { type = "unlock-recipe", recipe = "invar-dust" },
      { type = "unlock-recipe", recipe = "invar-dust-smelter" },
      { type = "unlock-recipe", recipe = "invar-dust-multismelter" },
    },
	prerequisites = { "lathe", "ore-centrifuging" },
	unit =
	{
      count = 160,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  }, 
  


---COBALT BRASS
  {
    type = "technology",
    name = "cobalt-brass",
    icon = "__gregtorio-continued__/graphics/technology/cobalt-brass.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lapis-dust-macerator" },
      { type = "unlock-recipe", recipe = "cobalt-brass-dust" },
      { type = "unlock-recipe", recipe = "cobalt-brass-ingot" },
      { type = "unlock-recipe", recipe = "cobalt-brass-plate" },
      { type = "unlock-recipe", recipe = "cobalt-brass-rod" },
      { type = "unlock-recipe", recipe = "large-cobalt-brass-gear-crafting-table" },
	  { type = "unlock-recipe", recipe = "diamond-dust-macerator" },
      { type = "unlock-recipe", recipe = "diamond-sawblade" }
    },
	prerequisites = { "mixer", "electrolyzer", "invar" },
	unit =
	{
      count = 160,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },


  
---LV CUTTING MACHINE
  {
    type = "technology",
    name = "cutting-machine",
    icon = "__gregtorio-continued__/graphics/technology/cutting-machine.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-cutting-machine" },
      { type = "unlock-recipe", recipe = "iron-bolt" },
      { type = "unlock-recipe", recipe = "tin-bolt" },
      { type = "unlock-recipe", recipe = "steel-bolt" },
      { type = "unlock-recipe", recipe = "plank" },
    },
	prerequisites = { "cobalt-brass" },
	unit =
	{
      count = 160,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---ELECTRIC BLAST FURNACE
  {
    type = "technology",
    name = "electric-blast-furnace",
    icon = "__gregtorio-continued__/graphics/technology/electric-blast-furnace.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "cupronickel-ingot" },
      { type = "unlock-recipe", recipe = "cupronickel-wire" },
      { type = "unlock-recipe", recipe = "bronze-foil" },
      { type = "unlock-recipe", recipe = "molten-tin" },
      { type = "unlock-recipe", recipe = "cupronickel-coil-block" },
      { type = "unlock-recipe", recipe = "heat-proof-casing" },
      { type = "unlock-recipe", recipe = "fine-steel-wire" },
      { type = "unlock-recipe", recipe = "low-voltage-coil" },
      { type = "unlock-recipe", recipe = "lv-energy-hatch" },
      { type = "unlock-recipe", recipe = "electric-blast-furnace-controller" },
      { type = "unlock-recipe", recipe = "mv-electric-blast-furnace" },
      { type = "unlock-recipe", recipe = "steel-ingot" },
      { type = "unlock-recipe", recipe = "glass" },
    },
	prerequisites = { "invar" },
	unit =
	{
      count = 160,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },  


  
 ---GREENHOUSE
  {
    type = "technology",
    name = "greenhouse",
    icon = "__gregtorio-continued__/graphics/technology/greenhouse.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "steel-frame" },    
      { type = "unlock-recipe", recipe = "solid-steel-machine-casing" },    	
      { type = "unlock-recipe", recipe = "tempered-glass" },   
      { type = "unlock-recipe", recipe = "greenhouse-controller" },    
      { type = "unlock-recipe", recipe = "lv-greenhouse" },    
      { type = "unlock-recipe", recipe = "growing-trees" }    
    },
	prerequisites = { "electric-blast-furnace", "primitive-electronic-circuit-assemblies" },
	unit =
	{
      count = 160,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },   
  
  
  
---GAS TURBINE
  {
    type = "technology",
    name = "gas-turbine",
    icon = "__gregtorio-continued__/graphics/technology/gas-turbine.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "wood-tar-pyrolyse" },   
      { type = "unlock-recipe", recipe = "wood-tar-extractor" },   
      { type = "unlock-recipe", recipe = "benzene-from-wood-tar" },   
      { type = "unlock-recipe", recipe = "benzene-cell" },   
      { type = "unlock-recipe", recipe = "lv-gas-turbine" },    
    },
	prerequisites = { "pyrolyse-oven", "basic-air-centrifuging" },
	unit =
	{
      count = 180,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  }, 
  
  
  
---SULFURIC ACID
  {
    type = "technology",
    name = "sulfuric-acid",
    icon = "__gregtorio-continued__/graphics/technology/sulfuric-acid.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "lv-distillery" },
      { type = "unlock-recipe", recipe = "sodium-hydroxide" },
      { type = "unlock-recipe", recipe = "hydrogen-sulfide" },
      { type = "unlock-recipe", recipe = "sulfuric-acid" },
      { type = "unlock-recipe", recipe = "sulfuric-acid-concentration" },
    },
	prerequisites = { "hydrochloric-acid" },
	unit =
	{
      count = 180,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
 



---RARE EARTH PROCESSING
  {
    type = "technology",
    name = "rare-earth-processing",
    icon = "__gregtorio-continued__/graphics/technology/rare-earth-processing.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "crushed-rare-earth-1" },   
      { type = "unlock-recipe", recipe = "rare-earth-1-dust" },   
      { type = "unlock-recipe", recipe = "rare-earth-1-processing" },   
      { type = "unlock-recipe", recipe = "greenockite-electrolysis" },    
      { type = "unlock-recipe", recipe = "lanthanite-electrolysis" },    
      { type = "unlock-recipe", recipe = "agardite-electrolysis" },    
      { type = "unlock-recipe", recipe = "yttrialite-electrolysis" },    
      { type = "unlock-recipe", recipe = "chalcopyrite-electrolysis" },
    },
	prerequisites = { "sulfuric-acid" },
	unit =
	{
      count = 180,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  }, 
  
 

---PHOSPHORUS PROCESSING
  {
    type = "technology",
    name = "phosphorus-processing",
    icon = "__gregtorio-continued__/graphics/technology/phosphorus-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-apatite-vein" },
      { type = "unlock-recipe", recipe = "raw-apatite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-apatite" },
      { type = "unlock-recipe", recipe = "apatite" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-apatite" },
      { type = "unlock-recipe", recipe = "raw-apatite-smelter" },
      { type = "unlock-recipe", recipe = "crushed-tricalcium-phosphate" },
      { type = "unlock-recipe", recipe = "tricalcium-phosphate" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-tricalcium-phosphate" },
      { type = "unlock-recipe", recipe = "centrifuging-tricalcium-phosphate" },
      { type = "unlock-recipe", recipe = "raw-tricalcium-phosphate-smelter" },
      { type = "unlock-recipe", recipe = "crushed-pyrochlore" },
      { type = "unlock-recipe", recipe = "pyrochlore" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-pyrochlore" },
      { type = "unlock-recipe", recipe = "raw-pyrochlore-smelter" },
      { type = "unlock-recipe", recipe = "phosphoric-acid-from-apatite" },
      { type = "unlock-recipe", recipe = "phosphate-electrolysis" },
      { type = "unlock-recipe", recipe = "phosphorus-pentoxide" },	  
      { type = "unlock-recipe", recipe = "phosphoric-acid-from-phosphorus-pentoxide" },	  
    },
	prerequisites = { "ore-centrifuging" },
	unit =
	{
      count = 180,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01}  },
      time = 30
	}
  },



---BASIC EXTENDED CRAFTING
  {
    type = "technology",
    name = "basic-extended-crafting",
    icon = "__gregtorio-continued__/graphics/technology/basic-extended-crafting.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "brick-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "luminessence" },
      { type = "unlock-recipe", recipe = "distilled-water" },
      { type = "unlock-recipe", recipe = "lapis-coolant" },
      { type = "unlock-recipe", recipe = "steel-dust" },
      { type = "unlock-recipe", recipe = "gold-dust-macerator" },
      { type = "unlock-recipe", recipe = "silver-dust-macerator" },
      { type = "unlock-recipe", recipe = "electrum-dust" },
      { type = "unlock-recipe", recipe = "black-bronze-dust" },
      { type = "unlock-recipe", recipe = "black-steel-dust" },
      { type = "unlock-recipe", recipe = "hot-black-steel-ingot" },
      { type = "unlock-recipe", recipe = "black-steel-ingot-chemical-bath" },
      { type = "unlock-recipe", recipe = "black-steel-plate" },
      { type = "unlock-recipe", recipe = "basic-extended-crafting-component" },
      { type = "unlock-recipe", recipe = "basic-extended-crafting-catalyst" },
      { type = "unlock-recipe", recipe = "basic-extended-crafting-table" },
    },
	prerequisites = { "phosphorus-processing"},
	unit =
	{
      count = 180,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01}  },
      time = 30
	}
  },
  


---MV SCIENCE PACK
  {
    type = "technology",
    name = "military-science-pack",
    icon = "__base__/graphics/technology/military-science-pack.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mv-science-pack" },
    },
	prerequisites = { "electric-blast-furnace" },
	unit =
	{
      count = 200,
      ingredients = { {"automation-science-pack", SP02}, {"logistic-science-pack", SP01} },
      time = 30
	}
  },
  


--------------------------
--- MEDIUM VOLTAGE AGE ---
--------------------------

---LOGISTICS 2
  {
    type = "technology",
    name = "logistics-2",
    icon = "__base__/graphics/technology/logistics-2.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "fast-transport-belt" },
      { type = "unlock-recipe", recipe = "fast-underground-belt" },
      { type = "unlock-recipe", recipe = "fast-splitter" },
    },
	prerequisites = { "military-science-pack", "logistics" },
	unit =
	{
      count = 200,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  



---RAILWAY
  {
    type = "technology",
    name = "railway",
    icon = "__base__/graphics/technology/railway.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "wooden-tie" },
      { type = "unlock-recipe", recipe = "wooden-railbed" },
      { type = "unlock-recipe", recipe = "standard-rail" },
      { type = "unlock-recipe", recipe = "rail" },
      { type = "unlock-recipe", recipe = "locomotive" },
      { type = "unlock-recipe", recipe = "cargo-wagon" },
    },
	prerequisites = { "logistics-2" },
	unit =
	{
      count = 200,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  

---MICROVERSIUM
  {
    type = "technology",
    name = "microversium",
    icon = "__gregtorio-continued__/graphics/technology/microversium.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "glowstone-dust" },
      { type = "unlock-recipe", recipe = "deuterium" },
      { type = "unlock-recipe", recipe = "microversium-dust" },
      { type = "unlock-recipe", recipe = "hot-microversium-ingot" },
      { type = "unlock-recipe", recipe = "microversium-ingot-chemical-bath" },
      { type = "unlock-recipe", recipe = "microversium-plate" },
      { type = "unlock-recipe", recipe = "microversium-casing" },
      { type = "unlock-recipe", recipe = "block-of-diamond" },
      { type = "unlock-recipe", recipe = "microverse-projector-controller" },
      { type = "unlock-recipe", recipe = "mv-microverse-projector" },
    },
	prerequisites = { "military-science-pack", "greenhouse" },
	unit =
	{
      count = 220,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
 ---OVERWORLD DATA
  {
    type = "technology",
    name = "overworld-data",
    icon = "__gregtorio-continued__/graphics/technology/overworld-data.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "gold-plate" },  
      { type = "unlock-recipe", recipe = "gold-chest" },
      { type = "unlock-recipe", recipe = "inscriber-logic-press" },
      { type = "unlock-recipe", recipe = "inscriber-silicon-press" },
      { type = "unlock-recipe", recipe = "printed-logic-circuit" },
      { type = "unlock-recipe", recipe = "printed-silicon" },
      { type = "unlock-recipe", recipe = "logic-processor" },
      { type = "unlock-recipe", recipe = "me-1k-storage-component-lv" },
      { type = "unlock-recipe", recipe = "steel-screw" },
      { type = "unlock-recipe", recipe = "basic-storage-housing" },
      { type = "unlock-recipe", recipe = "overworld-data" },
    },
	prerequisites = { "circuit-assembler" },
	unit =
	{
      count = 240,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },


  
---INTO THE MICROVERSE
  {
    type = "technology",
    name = "into-the-microverse",
    icon = "__gregtorio-continued__/graphics/technology/into-the-microverse.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "conductive-iron-ingot" },
      { type = "unlock-recipe", recipe = "conductive-iron-plate" },
      { type = "unlock-recipe", recipe = "conductive-iron-thruster" },
      { type = "unlock-recipe", recipe = "steel-heavy-plating" },
      { type = "unlock-recipe", recipe = "basic-guidance-system" },
      { type = "unlock-recipe", recipe = "ruby-lens" },
      { type = "unlock-recipe", recipe = "basic-mining-laser" },
      { type = "unlock-recipe", recipe = "steel-plated-microminer" },
      { type = "unlock-recipe", recipe = "tier-one-microminer-output" }
    },
	prerequisites = { "microversium", "basic-extended-crafting", "gas-turbine", "radar", "overworld-data" },
	unit =
	{
      count = 240,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---MICROVERSE RESOURCES
  {
    type = "technology",
    name = "microverse-resources",
    icon = "__gregtorio-continued__/graphics/technology/microverse-resources.png",
    icon_size = 256,
    effects = microverse_resources,
	prerequisites = { "into-the-microverse" },
	unit =
	{
      count = 240,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  


  
---ALUMINIUM PROCESSING
  {
    type = "technology",
    name = "aluminium",
    icon = "__gregtorio-continued__/graphics/technology/aluminium-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "microminer-bauxite" },
      { type = "unlock-recipe", recipe = "crushed-bauxite" },
      { type = "unlock-recipe", recipe = "bauxite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-bauxite" },
      { type = "unlock-recipe", recipe = "crushed-aluminium" },
      { type = "unlock-recipe", recipe = "aluminium-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-aluminium" },
      { type = "unlock-recipe", recipe = "aluminium-ingot" },
      { type = "unlock-recipe", recipe = "aluminium-plate" },
      { type = "unlock-recipe", recipe = "block-of-aluminium" },
      { type = "unlock-recipe", recipe = "aluminium-rod" },
      { type = "unlock-recipe", recipe = "aluminium-bolt" },
      { type = "unlock-recipe", recipe = "aluminium-screw" },
      { type = "unlock-recipe", recipe = "aluminium-frame" },
      { type = "unlock-recipe", recipe = "aluminium-wire" },
      { type = "unlock-recipe", recipe = "fine-aluminium-wire" },
      { type = "unlock-recipe", recipe = "aluminium-spring" },
    },
	prerequisites = { "microverse-resources" },
	unit =
	{
      count = 240,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  }, 



  ---ALUMINIUM BACKPACK
  {
    type = "technology",
    name = "aluminium-backpack",
    icon = "__gregtorio-continued__/graphics/technology/aluminium-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "steel-backpack", "aluminium" },
	unit =
	{
      count = 260,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },    
  
  
  
---MV COMPONENTS
  {
    type = "technology",
    name = "mv-components",
    icon = "__gregtorio-continued__/graphics/technology/mv-components.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "silver-wire" },
      { type = "unlock-recipe", recipe = "magnetic-steel-rod" },
      { type = "unlock-recipe", recipe = "copper-cable" },
      { type = "unlock-recipe", recipe = "mv-motor" },
      { type = "unlock-recipe", recipe = "aluminium-gear-crafting-table" },
      { type = "unlock-recipe", recipe = "mv-piston" },
      { type = "unlock-recipe", recipe = "bronze-bolt" },
      { type = "unlock-recipe", recipe = "bronze-screw" },
      { type = "unlock-recipe", recipe = "bronze-rotor-crafting-table" },
	  { type = "unlock-recipe", recipe = "mv-pump" },
	  { type = "unlock-recipe", recipe = "mv-conveyor-module" },
	  { type = "unlock-recipe", recipe = "mv-robot-arm" },
	  { type = "unlock-recipe", recipe = "mv-machine-casing" },
	  { type = "unlock-recipe", recipe = "mv-machine-hull-crafting-table" },
    },
	prerequisites = { "polarizer", "aluminium", "circuit-assembler" },
	unit =
	{
      count = 260,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---MV MACHINES
  {
    type = "technology",
    name = "mv-machines",
    icon = "__gregtorio-continued__/graphics/technology/mv-machines.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mv-steam-turbine" },
      { type = "unlock-recipe", recipe = "mv-wiremill" },
      { type = "unlock-recipe", recipe = "mv-bending-machine" },
      { type = "unlock-recipe", recipe = "mv-alloy-smelter" },
      { type = "unlock-recipe", recipe = "mv-polarizer" },
      { type = "unlock-recipe", recipe = "mv-rock-crusher" },
      { type = "unlock-recipe", recipe = "mv-ore-washer" },
      { type = "unlock-recipe", recipe = "mv-centrifuge" },
      { type = "unlock-recipe", recipe = "mv-mixer" },
      { type = "unlock-recipe", recipe = "mv-extractor" },
      { type = "unlock-recipe", recipe = "mv-assembling-machine" },
      { type = "unlock-recipe", recipe = "mv-lathe" },
      { type = "unlock-recipe", recipe = "mv-distillery" },
      { type = "unlock-recipe", recipe = "mv-electrolyzer" },
      { type = "unlock-recipe", recipe = "mv-macerator" },
      { type = "unlock-recipe", recipe = "mv-chemical-reactor" },
      { type = "unlock-recipe", recipe = "mv-chemical-bath" },
      { type = "unlock-recipe", recipe = "mv-cutting-machine" },
      { type = "unlock-recipe", recipe = "mv-air-collector" },
      { type = "unlock-recipe", recipe = "mv-fluid-solidifier" },
      { type = "unlock-recipe", recipe = "mv-compressor" },
      { type = "unlock-recipe", recipe = "mv-canning-machine" },
      { type = "unlock-recipe", recipe = "mv-gas-turbine" },
    },
	prerequisites = { "mv-components" },
	unit =
	{
      count = 260,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  


---MONOCRYSTALINE SILICON BOULES
  {
    type = "technology",
    name = "mcsb",
    icon = "__gregtorio-continued__/graphics/technology/mcsb.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "silicon-dioxide" },
      { type = "unlock-recipe", recipe = "fullers-earth-electrolysis" },
      { type = "unlock-recipe", recipe = "raw-silicon" },
      { type = "unlock-recipe", recipe = "magnesia-electrolysis" },
      { type = "unlock-recipe", recipe = "silicon-tetrachloride" },
      { type = "unlock-recipe", recipe = "poly-si-dust" },
      { type = "unlock-recipe", recipe = "monocrystaline-silicon-boule" },
      { type = "unlock-recipe", recipe = "silicon-wafer" }
    },
	prerequisites = { "rock-crusher", "mv-machines", "cutting-machine" },
	unit =
	{
      count = 260,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },

  
  
---LASER ENGRAVER
  {
    type = "technology",
    name = "laser-engraver",
    icon = "__gregtorio-continued__/graphics/technology/laser-engraver.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mv-laser-engraver" },
      { type = "unlock-recipe", recipe = "ilc-wafer-sw" },
      { type = "unlock-recipe", recipe = "ilc-chip" }
    },
	prerequisites = { "mcsb" },
	unit =
	{
      count = 280,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---NAND CHIPS
  {
    type = "technology",
    name = "nand-chips",
    icon = "__gregtorio-continued__/graphics/technology/nand-chips.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "simple-soc-wafer-sw" },
      { type = "unlock-recipe", recipe = "simple-system-on-chip" },
      { type = "unlock-recipe", recipe = "red-alloy-rod" },
      { type = "unlock-recipe", recipe = "red-alloy-bolt" },
	  { type = "unlock-recipe", recipe = "fine-tin-wire" },
      { type = "unlock-recipe", recipe = "nand-chip-array" },
      { type = "unlock-recipe", recipe = "nand-chip" },
      { type = "unlock-recipe", recipe = "me-1k-storage-component-nand" },
    },
	prerequisites = { "laser-engraver" },
	unit =
	{
      count = 280,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },


  
---POLYETHYLENE
  {
    type = "technology",
    name = "polyethylene",
    icon = "__gregtorio-continued__/graphics/technology/polyethylene.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "growing-wheat" },
      { type = "unlock-recipe", recipe = "plant-ball" },
      { type = "unlock-recipe", recipe = "plant-mass" },
      { type = "unlock-recipe", recipe = "bio-chaff" },
      { type = "unlock-recipe", recipe = "biomass" },
      { type = "unlock-recipe", recipe = "biomass-to-ethanol" },
      { type = "unlock-recipe", recipe = "ethanol-to-ethylene" },
      { type = "unlock-recipe", recipe = "ethylene-to-polyethylene" },
	  { type = "unlock-recipe", recipe = "polyethylene-sheet" },
      { type = "unlock-recipe", recipe = "lv-machine-hull" },
      { type = "unlock-recipe", recipe = "mv-machine-hull" },
    },
	prerequisites = { "mv-machines" },
	unit =
	{
      count = 280,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  


---MV ENERGY HATCHES
  {
    type = "technology",
    name = "mv-energy-hatches",
    icon = "__gregtorio-continued__/graphics/technology/mv-energy-hatches.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "medium-voltage-coil" },
      { type = "unlock-recipe", recipe = "ulpic-wafer-sw" },
      { type = "unlock-recipe", recipe = "ultra-low-powered-integrated-circuit" },
      { type = "unlock-recipe", recipe = "sodium-potassium" },
      { type = "unlock-recipe", recipe = "mv-energy-hatch" },
      { type = "unlock-recipe", recipe = "mv-greenhouse" },
      { type = "unlock-recipe", recipe = "hv-microverse-projector" },
    },
	prerequisites = { "laser-engraver" },
	unit =
	{
      count = 280,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


---INTEGRATED CIRCUITS
  {
    type = "technology",
    name = "integrated-circuits",
    icon = "__gregtorio-continued__/graphics/technology/integrated-circuits.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "annealed-copper-ingot" },
      { type = "unlock-recipe", recipe = "fine-annealed-copper-wire" },
	  { type = "unlock-recipe", recipe = "diode" },
      { type = "unlock-recipe", recipe = "basic-integrated-circuit" },
      { type = "unlock-recipe", recipe = "silver-rod" },
      { type = "unlock-recipe", recipe = "silver-bolt" },
	  { type = "unlock-recipe", recipe = "fine-gold-wire" },	  
	  { type = "unlock-recipe", recipe = "good-integrated-circuit" },
    },
	prerequisites = { "laser-engraver", "polyethylene" },
	unit =
	{
      count = 300,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  


---ADVANCED INTEGRATED CIRCUITS
  {
    type = "technology",
    name = "advanced-integrated-circuits",
    icon = "__gregtorio-continued__/graphics/technology/advanced-integrated-circuits.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "electrum-dust-smelter" },
      { type = "unlock-recipe", recipe = "electrum-ingot" },
      { type = "unlock-recipe", recipe = "electrum-dust-macerator" },
	  { type = "unlock-recipe", recipe = "fine-electrum-wire" },
      { type = "unlock-recipe", recipe = "ram-wafer-sw" },
      { type = "unlock-recipe", recipe = "ram-chip" },
	  { type = "unlock-recipe", recipe = "annealed-copper-rod" },
	  { type = "unlock-recipe", recipe = "annealed-copper-bolt" },
	  { type = "unlock-recipe", recipe = "silicon-ingot" },
	  { type = "unlock-recipe", recipe = "silicon-plate" },
	  { type = "unlock-recipe", recipe = "transistor" },
	  { type = "unlock-recipe", recipe = "processing-unit" }
    },
	prerequisites = { "integrated-circuits" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  



---LARGE STEEL BOILER
  {
    type = "technology",
    name = "large-steel-boiler",
    icon = "__gregtorio-continued__/graphics/technology/large-steel-boiler.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "steel-pipe-casing" },
      { type = "unlock-recipe", recipe = "steel-firebox-casing" },
      { type = "unlock-recipe", recipe = "large-steel-boiler" }
    },
	prerequisites = { "advanced-integrated-circuits", "large-bronze-boiler" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---MULTISMELTER
  {
    type = "technology",
    name = "multismelter",
    icon = "__gregtorio-continued__/graphics/technology/multismelter.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "multismelter-controller" },
      { type = "unlock-recipe", recipe = "mv-multismelter" },
      { type = "unlock-recipe", recipe = "brick-multismelter" },
      { type = "unlock-recipe", recipe = "smooth-stone-multismelter" },
      { type = "unlock-recipe", recipe = "raw-coal-multismelter" },
      { type = "unlock-recipe", recipe = "firebrick-multismelter" },
      { type = "unlock-recipe", recipe = "raw-iron-multismelter" },
      { type = "unlock-recipe", recipe = "iron-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-vanadium-magnetite-multismelter" },
      { type = "unlock-recipe", recipe = "vanadium-magnetite-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-gold-multismelter" },
      { type = "unlock-recipe", recipe = "gold-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-gypsum-multismelter" },
      { type = "unlock-recipe", recipe = "raw-fullers-earth-multismelter" },
      { type = "unlock-recipe", recipe = "raw-copper-multismelter" },
      { type = "unlock-recipe", recipe = "copper-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-tin-multismelter" },
      { type = "unlock-recipe", recipe = "tin-dust-multismelter" },
      { type = "unlock-recipe", recipe = "cassiterite-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-realgar-multismelter" },
      { type = "unlock-recipe", recipe = "raw-galena-multismelter" },
      { type = "unlock-recipe", recipe = "raw-lead-multismelter" },
      { type = "unlock-recipe", recipe = "lead-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-silver-multismelter" },
      { type = "unlock-recipe", recipe = "silver-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-cryolite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-tetrahedrite-multismelter" },
      { type = "unlock-recipe", recipe = "tetrahedrite-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-stibnite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-sphalerite-multismelter" },
      { type = "unlock-recipe", recipe = "sphalerite-dust-multismelter" },
      { type = "unlock-recipe", recipe = "zinc-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-sulfur-multismelter" },
      { type = "unlock-recipe", recipe = "raw-redstone-multismelter" },
      { type = "unlock-recipe", recipe = "raw-ruby-multismelter" },
      { type = "unlock-recipe", recipe = "raw-cinnabar-multismelter" },
      { type = "unlock-recipe", recipe = "raw-graphite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-diamond-multismelter" },
      { type = "unlock-recipe", recipe = "raw-salt-multismelter" },
      { type = "unlock-recipe", recipe = "raw-rock-salt-multismelter" },
      { type = "unlock-recipe", recipe = "raw-lepidolite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-nether-quartz-multismelter" },
      { type = "unlock-recipe", recipe = "raw-calcite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-nickel-multismelter" },
      { type = "unlock-recipe", recipe = "nickel-dust-multismelter" },
      { type = "unlock-recipe", recipe = "raw-pentlandite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-cobaltite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-lazurite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-lapis-multismelter" },
      { type = "unlock-recipe", recipe = "bronze-dust-multismelter" },
      { type = "unlock-recipe", recipe = "brass-dust-multismelter" },
      { type = "unlock-recipe", recipe = "charcoal-multismelter" },
      { type = "unlock-recipe", recipe = "raw-apatite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-tricalcium-phosphate-multismelter" },
      { type = "unlock-recipe", recipe = "raw-pyrochlore-multismelter" },
      { type = "unlock-recipe", recipe = "raw-bauxite-multismelter" },
      { type = "unlock-recipe", recipe = "invar-dust-multismelter" },
      { type = "unlock-recipe", recipe = "electrum-dust-multismelter" },
    },
	prerequisites = { "advanced-integrated-circuits" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  



---MV TIER ELECTROLYSIS
  {
    type = "technology",
    name = "mv-tier-electrolysis",
    icon = "__gregtorio-continued__/graphics/technology/mv-tier-electrolysis.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "ruby-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "clay-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "galena-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "tetrahedrite-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "borax-electrolysis" },
      { type = "unlock-recipe", recipe = "lepidolite-electrolysis" },
      { type = "unlock-recipe", recipe = "barite-electrolysis" },
      { type = "unlock-recipe", recipe = "calcite-electrolysis" },
      { type = "unlock-recipe", recipe = "alumina" },
    },
	prerequisites = { "mv-machines" },
	unit =
	{
      count = 300,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },


  
---EXTRUDER
  {
    type = "technology",
    name = "extruder",
    icon = "__gregtorio-continued__/graphics/technology/extruder.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mv-extruder" },
      { type = "unlock-recipe", recipe = "pipe" },
      { type = "unlock-recipe", recipe = "tin-ring" },
      { type = "unlock-recipe", recipe = "tin-rotor" },
      { type = "unlock-recipe", recipe = "bronze-ring" },
      { type = "unlock-recipe", recipe = "bronze-rotor" },
      { type = "unlock-recipe", recipe = "steel-rotor" }, 
      { type = "unlock-recipe", recipe = "iron-gear" },
      { type = "unlock-recipe", recipe = "steel-gear" },
      { type = "unlock-recipe", recipe = "large-steel-gear" },
      { type = "unlock-recipe", recipe = "large-cobalt-brass-gear" },
      { type = "unlock-recipe", recipe = "aluminium-gear" },
      { type = "unlock-recipe", recipe = "large-aluminium-gear" },
      { type = "unlock-recipe", recipe = "invar-dust" },
      { type = "unlock-recipe", recipe = "eglin-steel-dust" },
      { type = "unlock-recipe", recipe = "eglin-steel-ingot" },
      { type = "unlock-recipe", recipe = "large-eglin-steel-gear" },
      { type = "unlock-recipe", recipe = "mv-semifluid-generator" },
    },
	prerequisites = { "mv-components" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---DRILLING RIG
  {
    type = "technology",
    name = "oil-gathering",
    icon = "__gregtorio-continued__/graphics/technology/drilling-rig.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "centrifuge-vanadium-magnetite-dust" },   
      { type = "unlock-recipe", recipe = "vanadium-steel-dust" },   
      { type = "unlock-recipe", recipe = "vanadium-steel-ingot" },   
      { type = "unlock-recipe", recipe = "large-vanadium-steel-gear" },   
      { type = "unlock-recipe", recipe = "mv-drilling-rig-controller" },   
      { type = "unlock-recipe", recipe = "mv-drilling-rig" },   
      { type = "unlock-recipe", recipe = "water-drilling-rig" },   
      { type = "unlock-recipe", recipe = "crude-oil-drilling-rig" },   
      { type = "unlock-recipe", recipe = "lava-drilling-rig" },
      { type = "unlock-recipe", recipe = "lubricant" },
    },
	prerequisites = { "greenhouse", "mv-energy-hatches", "fluid-handling" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---DIESEL
  {
    type = "technology",
    name = "diesel",
    icon = "__gregtorio-continued__/graphics/technology/diesel.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "mv-combustion-generator" },
      { type = "unlock-recipe", recipe = "oil-distillation-light" },  
      { type = "unlock-recipe", recipe = "oil-distillation-heavy" },  
      { type = "unlock-recipe", recipe = "heavy-fuel-desulfurization" },  
      { type = "unlock-recipe", recipe = "light-fuel-desulfurization" },
      { type = "unlock-recipe", recipe = "diesel" },
      { type = "unlock-recipe", recipe = "light-fuel-cell" },
      { type = "unlock-recipe", recipe = "heavy-fuel-cell" },
      { type = "unlock-recipe", recipe = "diesel-cell" },
      { type = "unlock-recipe", recipe = "hydrogen-sulfide-electrolysis" },
    },
	prerequisites = { "oil-gathering", "extruder" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---RUBY JUICE
  {
    type = "technology",
    name = "ruby-juice",
    icon = "__gregtorio-continued__/graphics/technology/ruby-juice.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "sodium-hydroxide" },     
      { type = "unlock-recipe", recipe = "ruby-juice" },     
      { type = "unlock-recipe", recipe = "ruby-juice-centrifuging" },     
      { type = "unlock-recipe", recipe = "aluminium-hydroxide-blasting" },     
    },
	prerequisites = { "mv-machines" },
	unit =
	{
      count = 320,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---KANTHAL
  {
    type = "technology",
    name = "kanthal",
    icon = "__gregtorio-continued__/graphics/technology/kanthal-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "kanthal-dust" },
      { type = "unlock-recipe", recipe = "kanthal-ingot" },
      { type = "unlock-recipe", recipe = "kanthal-wire" },
    },
	prerequisites = { "ruby-juice", "mv-tier-electrolysis" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


---KANTHAL COILS
  {
    type = "technology",
    name = "kanthal-coils",
    icon = "__gregtorio-continued__/graphics/technology/kanthal-coils.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "aluminium-foil" },
      { type = "unlock-recipe", recipe = "molten-cupronickel" },
      { type = "unlock-recipe", recipe = "kanthal-coil-block" },
      { type = "unlock-recipe", recipe = "hv-electric-blast-furnace" },
      { type = "unlock-recipe", recipe = "hv-pyrolyse-oven" },
      { type = "unlock-recipe", recipe = "hv-multismelter" },
      { type = "unlock-recipe", recipe = "aluminium-ingot-carbon" },
    },
	prerequisites = { "kanthal", "mv-energy-hatches" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


---ADVANCED EXTENDED CRAFTING
  {
    type = "technology",
    name = "advanced-extended-crafting",
    icon = "__gregtorio-continued__/graphics/technology/advanced-extended-crafting.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "electrum-plate" }, 
      { type = "unlock-recipe", recipe = "advanced-extended-crafting-component" },
      { type = "unlock-recipe", recipe = "advanced-extended-crafting-catalyst" },
      { type = "unlock-recipe", recipe = "advanced-extended-crafting-table" }
    },
	prerequisites = { "basic-extended-crafting", "advanced-integrated-circuits" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
 
 

---ADVANCED MV MACHINES
  {
    type = "technology",
    name = "advanced-mv-machines",
    icon = "__gregtorio-continued__/graphics/technology/advanced-mv-machines.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-beryllium-vein" },  
      { type = "unlock-recipe", recipe = "raw-beryllium-smelter" },  
      { type = "unlock-recipe", recipe = "raw-beryllium-multismelter" },  
      { type = "unlock-recipe", recipe = "crushed-beryllium" },  
      { type = "unlock-recipe", recipe = "beryllium-dust" },  
      { type = "unlock-recipe", recipe = "centrifuging-crushed-beryllium" },  
      { type = "unlock-recipe", recipe = "beryllium-dust-smelter" },  
      { type = "unlock-recipe", recipe = "beryllium-dust-multismelter" },  
      { type = "unlock-recipe", recipe = "raw-emerald-smelter" },  
      { type = "unlock-recipe", recipe = "raw-emerald-multismelter" }, 
      { type = "unlock-recipe", recipe = "crushed-emerald" },  
      { type = "unlock-recipe", recipe = "emerald-dust" },  
      { type = "unlock-recipe", recipe = "centrifuging-crushed-emerald" },  	    
      { type = "unlock-recipe", recipe = "emerald-dust-electrolysis" },  	  
      { type = "unlock-recipe", recipe = "electrum-rod" },  
      { type = "unlock-recipe", recipe = "mv-emitter" },  
      { type = "unlock-recipe", recipe = "mv-sensor" },  
      { type = "unlock-recipe", recipe = "mv-laser-engraver" },  
      { type = "unlock-recipe", recipe = "mv-circuit-assembler"},  
    },
	prerequisites = { "mv-machines", "advanced-integrated-circuits" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },


  
---AUTOCLAVE
  {
    type = "technology",
    name = "autoclave",
    icon = "__gregtorio-continued__/graphics/technology/autoclave.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mv-autoclave" },
      { type = "unlock-recipe", recipe = "lapis-autoclave" },
      { type = "unlock-recipe", recipe = "nether-quartz-autoclave" },
      { type = "unlock-recipe", recipe = "certus-quartz-autoclave" },
      { type = "unlock-recipe", recipe = "ruby-autoclave" },
      { type = "unlock-recipe", recipe = "diamond-autoclave" },
      { type = "unlock-recipe", recipe = "emerald-autoclave" },  	
    },
	prerequisites = { "advanced-mv-machines" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },



---APPLIED ENERGISTICS CRYSTALS
  {
    type = "technology",
    name = "applied-energistics-crystals",
    icon = "__gregtorio-continued__/graphics/technology/fluix-block.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "charged-certus-quartz-dust" },  
      { type = "unlock-recipe", recipe = "charged-certus-quartz" },  
      { type = "unlock-recipe", recipe = "fluix-crystal" },  
      { type = "unlock-recipe", recipe = "fluix-dust" },  
      { type = "unlock-recipe", recipe = "certus-seed" },  
      { type = "unlock-recipe", recipe = "fluix-seed" },  
      { type = "unlock-recipe", recipe = "pure-certus-crystal" },  
      { type = "unlock-recipe", recipe = "pure-fluix-crystal" },  
      { type = "unlock-recipe", recipe = "inscriber-calculation-press" },  
      { type = "unlock-recipe", recipe = "inscriber-engineering-press" },  
      { type = "unlock-recipe", recipe = "printed-calculation-circuit" }, 
      { type = "unlock-recipe", recipe = "diamond-plate" },	 	  
      { type = "unlock-recipe", recipe = "printed-engineering-circuit" },  
      { type = "unlock-recipe", recipe = "calculation-processor" },  
      { type = "unlock-recipe", recipe = "engineering-processor" },  
      { type = "unlock-recipe", recipe = "fluix-block" },  
    },
	prerequisites = { "autoclave" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---APPLIED ENERGISTICS COMPONENTS
  {
    type = "technology",
    name = "applied-energistics-components",
    icon = "__gregtorio-continued__/graphics/technology/ae2.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "nether-quartz-rod" },  
      { type = "unlock-recipe", recipe = "certus-quartz-rod" },  
      { type = "unlock-recipe", recipe = "charged-certus-quartz-rod" },  
      { type = "unlock-recipe", recipe = "annihilation-core" },  
      { type = "unlock-recipe", recipe = "formation-core" },  
      { type = "unlock-recipe", recipe = "quartz-fiber" },  
      { type = "unlock-recipe", recipe = "fluix-cable" },  
      { type = "unlock-recipe", recipe = "me-interface" },   
      { type = "unlock-recipe", recipe = "me-controller" }, 
    },
	prerequisites = { "applied-energistics-crystals", "advanced-integrated-circuits" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  
  
---CONSTRUCTION BOTS
  {
    type = "technology",
    name = "construction-robotics",
    icon = "__base__/graphics/technology/construction-robotics.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "t1-construction-robot" },  
    },
	prerequisites = { "integrated-circuits", "battery" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---LOGISTIC BOTS
  {
    type = "technology",
    name = "logistic-robotics",
    icon = "__base__/graphics/technology/logistic-robotics.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "t1-logistic-robot" },  
    },
	prerequisites = { "integrated-circuits", "battery" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  
  
  
---LOGISTIC SYSTEM
  {
    type = "technology",
    name = "logistic-system",
    icon = "__base__/graphics/technology/logistic-system.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "diamond-chest" },  
      { type = "unlock-recipe", recipe = "requester-chest" },  
      { type = "unlock-recipe", recipe = "active-provider-chest" },  
      { type = "unlock-recipe", recipe = "passive-provider-chest" },   
      { type = "unlock-recipe", recipe = "me-4k-storage-component" },  
      { type = "unlock-recipe", recipe = "me-16k-storage-component" },
      { type = "unlock-recipe", recipe = "storage-chest" }, 	  
      { type = "unlock-recipe", recipe = "buffer-chest" }, 	  
      { type = "unlock-recipe", recipe = "roboport-frame-casing-mk1" },  
      { type = "unlock-recipe", recipe = "roboport-mk1" },  
    },
	prerequisites = { "logistic-robotics", "construction-robotics", "applied-energistics-components" },
	unit =
	{
      count = 340,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  }, 
    

   
 ---MANGANESE PROCESSING
  {
    type = "technology",
    name = "manganese-processing",
    icon = "__gregtorio-continued__/graphics/technology/manganese-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "mining-manganese-vein" }, 
      { type = "unlock-recipe", recipe = "crushed-grossular" },
      { type = "unlock-recipe", recipe = "grossular-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-grossular" },
      { type = "unlock-recipe", recipe = "raw-grossular-smelter" },
      { type = "unlock-recipe", recipe = "raw-grossular-multismelter" },	  
      { type = "unlock-recipe", recipe = "grossular-dust-electrolysis" },	
      { type = "unlock-recipe", recipe = "crushed-spessartine" },
      { type = "unlock-recipe", recipe = "spessartine-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-spessartine" },
      { type = "unlock-recipe", recipe = "raw-spessartine-smelter" },
      { type = "unlock-recipe", recipe = "raw-spessartine-multismelter" },
      { type = "unlock-recipe", recipe = "spessartine-dust-electrolysis" },
      { type = "unlock-recipe", recipe = "crushed-pyrolusite" },
      { type = "unlock-recipe", recipe = "pyrolusite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-pyrolusite" },
      { type = "unlock-recipe", recipe = "raw-pyrolusite-smelter" },
      { type = "unlock-recipe", recipe = "raw-pyrolusite-multismelter" },	  
      { type = "unlock-recipe", recipe = "pyrolusite-dust-electrolysis" },		  
      { type = "unlock-recipe", recipe = "crushed-tantalite" },
      { type = "unlock-recipe", recipe = "tantalite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-tantalite" },
      { type = "unlock-recipe", recipe = "raw-tantalite-smelter" },
      { type = "unlock-recipe", recipe = "raw-tantalite-multismelter" },
      { type = "unlock-recipe", recipe = "raw-certus-quartz-multismelter" },
    },
	prerequisites = { "microverse-resources" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },


  
 ---STAINLESS STEEL
  {
    type = "technology",
    name = "stainless-steel",
    icon = "__gregtorio-continued__/graphics/technology/stainless-steel-processing.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "stainless-steel-dust" },
      { type = "unlock-recipe", recipe = "stainless-steel-ingot" },
      { type = "unlock-recipe", recipe = "stainless-steel-plate" },
      { type = "unlock-recipe", recipe = "stainless-steel-rod" },
      { type = "unlock-recipe", recipe = "stainless-steel-gear" },
      { type = "unlock-recipe", recipe = "stainless-steel-bolt" },
      { type = "unlock-recipe", recipe = "stainless-steel-screw" },
      { type = "unlock-recipe", recipe = "stainless-steel-rotor" },
      { type = "unlock-recipe", recipe = "stainless-steel-frame" },
      { type = "unlock-recipe", recipe = "large-stainless-steel-gear" },
    },
	prerequisites = { "kanthal-coils", "mv-machines", "extruder", "manganese-processing" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


  ---STAINLESS STEEL BACKPACK
  {
    type = "technology",
    name = "stainless-steel-backpack",
    icon = "__gregtorio-continued__/graphics/technology/stainless-steel-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "aluminium-backpack", "stainless-steel" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  
--[[

---CLEANROOM
  {
    type = "technology",
    name = "cleanroom",
    icon = "__gregtorio-continued__/graphics/technology/cleanroom.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "steel-frame" },  
      { type = "unlock-recipe", recipe = "plascrete" },   
      { type = "unlock-recipe", recipe = "filter-casing" },  
      { type = "unlock-recipe", recipe = "cleanroom-tile" }  
    },
	prerequisites = { "concrete", "stainless-steel" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  

--]]

---ENERGETIC ALLOY
  {
    type = "technology",
    name = "energetic-alloy",
    icon = "__gregtorio-continued__/graphics/technology/energetic-alloy-processing.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "energetic-alloy-ingot" },
      { type = "unlock-recipe", recipe = "energetic-alloy-plate" },
      { type = "unlock-recipe", recipe = "energetic-alloy-wire" },
      { type = "unlock-recipe", recipe = "energetic-alloy-rod" },
      { type = "unlock-recipe", recipe = "energetic-alloy-bolt" },
      { type = "unlock-recipe", recipe = "energetic-alloy-foil" },
    },
	prerequisites = { "mv-machines" },
	unit =
	{
      count = 360,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  

  
  
---MICROPROCESSORS
  {
    type = "technology",
    name = "microprocessors",
    icon = "__gregtorio-continued__/graphics/technology/microprocessors.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "plastic-circuit-board-pe" },
      { type = "unlock-recipe", recipe = "plastic-printed-circuit-board" },
      { type = "unlock-recipe", recipe = "cpu-wafer-sw" },
      { type = "unlock-recipe", recipe = "cpu-chip" },
      { type = "unlock-recipe", recipe = "thin-polyethylene-sheet" },  
      { type = "unlock-recipe", recipe = "fine-red-alloy-wire" },
      { type = "unlock-recipe", recipe = "capacitor" },
      { type = "unlock-recipe", recipe = "microchip" }, 
      { type = "unlock-recipe", recipe = "microprocessor" },   
      { type = "unlock-recipe", recipe = "inductor" },  
      { type = "unlock-recipe", recipe = "microprocessor-assembly" },  
      { type = "unlock-recipe", recipe = "microprocessor-supercomputer" } 
    },
	prerequisites = { "advanced-mv-machines", "energetic-alloy" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  

---PVC
  {
    type = "technology",
    name = "polyvinyl-chloride",
    icon = "__gregtorio-continued__/graphics/technology/pvc-sheet.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "vinyl-chloride" },  
      { type = "unlock-recipe", recipe = "polyvinyl-chloride" },  
      { type = "unlock-recipe", recipe = "pvc-sheet" },  
      { type = "unlock-recipe", recipe = "thin-pvc-sheet" },  
      { type = "unlock-recipe", recipe = "plastic-circuit-board-pvc" }
    },
	prerequisites = { "microprocessors" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


---NETHER DATA
  {
    type = "technology",
    name = "nether-data",
    icon = "__gregtorio-continued__/graphics/technology/nether-data.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "me-4k-storage-component" },  
      { type = "unlock-recipe", recipe = "nether-data" }
    },
	prerequisites = { "nand-chips" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---TIER TWO MICROMINERS
  {
    type = "technology",
    name = "tier-two-microminers",
    icon = "__gregtorio-continued__/graphics/technology/stainless-steel-plated-microminer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "microminer-ender-pearls" },
      { type = "unlock-recipe", recipe = "stainless-steel-heavy-plating" },
      { type = "unlock-recipe", recipe = "lv-field-generator" },
      { type = "unlock-recipe", recipe = "block-of-redstone" },
      { type = "unlock-recipe", recipe = "electrum-microminer-engine-frame" },
      { type = "unlock-recipe", recipe = "electrum-microminer-engine-core" },
      { type = "unlock-recipe", recipe = "energetic-thruster" },
      { type = "unlock-recipe", recipe = "stainless-steel-plated-microminer" },
      { type = "unlock-recipe", recipe = "tier-two-microminer-output" },
      { type = "unlock-recipe", recipe = "microminer-sphalerite" },
      { type = "unlock-recipe", recipe = "microminer-certus-quartz" },
      { type = "unlock-recipe", recipe = "microminer-beryllium" },
      { type = "unlock-recipe", recipe = "microminer-manganese" },
      { type = "unlock-recipe", recipe = "microminer-monazite" },
    },
	prerequisites = { "advanced-extended-crafting", "energetic-alloy", "stainless-steel", "nether-data", "diesel" },
	unit =
	{
      count = 380,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },  
  


---BATTERY
  {
    type = "technology",
    name = "battery",
    icon = "__base__/graphics/technology/battery.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "crushed-monazite" },
      { type = "unlock-recipe", recipe = "crushed-aluminium" },
      { type = "unlock-recipe", recipe = "aluminium-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-aluminium" },
      { type = "unlock-recipe", recipe = "battery-alloy-ingot" },
      { type = "unlock-recipe", recipe = "battery-alloy-ingot" },
      { type = "unlock-recipe", recipe = "battery-alloy-plate" },
      { type = "unlock-recipe", recipe = "battery-hull" },
      { type = "unlock-recipe", recipe = "filling-assorted-batteries" },
    },
	prerequisites = { "rare-earth-processing", "mv-components" },
	unit =
	{
      count = 300,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },




---EYES OF ENDER
  {
    type = "technology",
    name = "eyes-of-ender",
    icon = "__gregtorio-continued__/graphics/technology/eyes-of-ender.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "microminer-blaze-rods" },
      { type = "unlock-recipe", recipe = "liquid-blaze" },
      { type = "unlock-recipe", recipe = "eye-of-ender" },
      { type = "unlock-recipe", recipe = "pulsating-iron-ingot" },
      { type = "unlock-recipe", recipe = "pulsating-iron-wire" },
      { type = "unlock-recipe", recipe = "mv-field-generator" },
    },
	prerequisites = { "tier-two-microminers" },
	unit =
	{
      count = 400,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  

  
---HV SCIENCE PACK
  {
    type = "technology",
    name = "chemical-science-pack",
    icon = "__base__/graphics/technology/chemical-science-pack.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "aluminium-frame" }, 
      { type = "unlock-recipe", recipe = "frost-proof-casing" }, 
      { type = "unlock-recipe", recipe = "hv-science-pack" },
    },
	prerequisites = { "tier-two-microminers", "battery", "eyes-of-ender" },
	unit =
	{
      count = 400,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 30
	}
  },
  


---HV COMPONENTS
  {
    type = "technology",
    name = "hv-components",
    icon = "__gregtorio-continued__/graphics/technology/hv-components.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "silver-cable" },
      { type = "unlock-recipe", recipe = "gold-cable" },
      { type = "unlock-recipe", recipe = "electrum-wire" },
      { type = "unlock-recipe", recipe = "hv-motor" },
      { type = "unlock-recipe", recipe = "hv-piston" },
	  { type = "unlock-recipe", recipe = "hv-pump" },
	  { type = "unlock-recipe", recipe = "hv-conveyor-module" },
	  { type = "unlock-recipe", recipe = "hv-robot-arm" },
	  { type = "unlock-recipe", recipe = "hv-machine-casing" },
	  { type = "unlock-recipe", recipe = "hv-machine-hull" },
    },
	prerequisites = { "chemical-science-pack" },
	unit =
	{
      count = 400,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },



---NEODYMIUM
  {
    type = "technology",
    name = "neodymium",
    icon = "__gregtorio-continued__/graphics/technology/neodymium.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "crushed-neodymium" },
      { type = "unlock-recipe", recipe = "neodymium-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-neodymium" },
      { type = "unlock-recipe", recipe = "neodymium-ingot" },
    },
	prerequisites = { "tier-two-microminers" },
	unit =
	{
      count = 400,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },


---VACUUM FREEZERS
  {
    type = "technology",
    name = "vacuum-freezers",
    icon = "__gregtorio-continued__/graphics/technology/vacuum-freezers.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "vacuum-freezer-controller" },
      { type = "unlock-recipe", recipe = "mv-vacuum-freezer" },
      { type = "unlock-recipe", recipe = "microversium-ingot" },
      { type = "unlock-recipe", recipe = "black-steel-ingot" },
    },
	prerequisites = { "microprocessors", "hv-components" },
	unit =
	{
      count = 420,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },



---HV MACHINES
  {
    type = "technology",
    name = "hv-machines",
    icon = "__gregtorio-continued__/graphics/technology/hv-machines.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "hv-steam-turbine" },
      { type = "unlock-recipe", recipe = "hv-gas-turbine" },
      { type = "unlock-recipe", recipe = "hv-combustion-generator" },
      { type = "unlock-recipe", recipe = "hv-semifluid-generator" },
      { type = "unlock-recipe", recipe = "hv-wiremill" },
      { type = "unlock-recipe", recipe = "hv-bending-machine" },
      { type = "unlock-recipe", recipe = "hv-alloy-smelter" },
      { type = "unlock-recipe", recipe = "hv-polarizer" },
      { type = "unlock-recipe", recipe = "hv-rock-crusher" },
      { type = "unlock-recipe", recipe = "hv-ore-washer" },
      { type = "unlock-recipe", recipe = "hv-centrifuge" },
      { type = "unlock-recipe", recipe = "hv-mixer" },
      { type = "unlock-recipe", recipe = "hv-extractor" },
      { type = "unlock-recipe", recipe = "hv-assembling-machine" },
      { type = "unlock-recipe", recipe = "hv-lathe" },
      { type = "unlock-recipe", recipe = "hv-electrolyzer" },
      { type = "unlock-recipe", recipe = "diamond-grinding-head" },
      { type = "unlock-recipe", recipe = "hv-macerator" },
      { type = "unlock-recipe", recipe = "hv-chemical-reactor" },
      { type = "unlock-recipe", recipe = "hv-chemical-bath" },
      { type = "unlock-recipe", recipe = "hv-cutting-machine" },
      { type = "unlock-recipe", recipe = "hv-air-collector" },
      { type = "unlock-recipe", recipe = "hv-fluid-solidifier" },
      { type = "unlock-recipe", recipe = "hv-laser-engraver" },
      { type = "unlock-recipe", recipe = "hv-extruder" },
      { type = "unlock-recipe", recipe = "hv-autoclave" },
      { type = "unlock-recipe", recipe = "hv-compressor" },
      { type = "unlock-recipe", recipe = "hv-canning-machine" },
    },
	prerequisites = { "hv-components", "autoclave"},
	unit =
	{
      count = 420,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  }, 
  
  
  
---NIOBIUM AND TANTALUM EXTRACTION
  {
    type = "technology",
    name = "niobium-and-tantalum-extraction",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "pyrochlore-fluorination" },
      { type = "unlock-recipe", recipe = "tantalite-fluorination" },
      { type = "unlock-recipe", recipe = "niobium-pentoxide-electrolysis" },
      { type = "unlock-recipe", recipe = "tantalum-pentoxide-electrolysis" },
      { type = "unlock-recipe", recipe = "fluorite-electrolysis" },
      { type = "unlock-recipe", recipe = "manganese-difluoride-electrolysis" },
      { type = "unlock-recipe", recipe = "hot-tantalum-ingot" },
      { type = "unlock-recipe", recipe = "tantalum-ingot" },
    },
	prerequisites = { "hv-machines" },
	unit =
	{
      count = 440,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  

 
---CETANE BOOSTED DIESEL
  {
    type = "technology",
    name = "cetane-boosted-diesel",
    icon = "__gregtorio-continued__/graphics/technology/cetane-boosted-diesel.png",
    icon_size = 256,
    effects = {
       { type = "unlock-recipe", recipe = "carbon-monoxide" }, 
       { type = "unlock-recipe", recipe = "methanol-from-co" }, 
       { type = "unlock-recipe", recipe = "methanol-from-co2" }, 
       { type = "unlock-recipe", recipe = "acetic-acid" },
       { type = "unlock-recipe", recipe = "methyl-acetate" },
       { type = "unlock-recipe", recipe = "tetranitromethane" },
       { type = "unlock-recipe", recipe = "cetane-boosted-diesel" },
       { type = "unlock-recipe", recipe = "cetane-boosted-diesel-cell" },
    },
	prerequisites = { "hv-machines" },
	unit =
	{
      count = 440,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },   
  
  
  
---SMD COMPONENTS
  {
    type = "technology",
    name = "smd-components",
    icon = "__gregtorio-continued__/graphics/technology/smd-components.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "fine-tantalum-wire" },
      { type = "unlock-recipe", recipe = "smd-resistor" },
      { type = "unlock-recipe", recipe = "gallium-smelter" },
      { type = "unlock-recipe", recipe = "gallium-multismelter" },
      { type = "unlock-recipe", recipe = "gallium-foil" },
      { type = "unlock-recipe", recipe = "smd-transistor" },
      { type = "unlock-recipe", recipe = "platinum-dust-smelter" },
      { type = "unlock-recipe", recipe = "platinum-dust-multismelter" },
      { type = "unlock-recipe", recipe = "fine-platinum-wire" },
      { type = "unlock-recipe", recipe = "smd-diode" },
      { type = "unlock-recipe", recipe = "nickel-zinc-ferrite-dust" },
      { type = "unlock-recipe", recipe = "nickel-zinc-ferrite-ingot" },
      { type = "unlock-recipe", recipe = "nickel-zinc-ferrite-ring" },
      { type = "unlock-recipe", recipe = "smd-inductor" },
      { type = "unlock-recipe", recipe = "tantalum-foil" },
      { type = "unlock-recipe", recipe = "smd-capacitor" },
      { type = "unlock-recipe", recipe = "microchip-smd" }, 
      { type = "unlock-recipe", recipe = "microprocessor-smd" },   
      { type = "unlock-recipe", recipe = "microprocessor-assembly-smd" },  
      { type = "unlock-recipe", recipe = "microprocessor-supercomputer-smd" } 
    },
	prerequisites = { "niobium-and-tantalum-extraction" },
	unit =
	{
      count = 460,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---HV ENERGY HATCHES
  {
    type = "technology",
    name = "hv-energy-hatches",
    icon = "__gregtorio-continued__/graphics/technology/hv-energy-hatches.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "fine-black-steel-wire" },
      { type = "unlock-recipe", recipe = "high-voltage-coil" },
      { type = "unlock-recipe", recipe = "lpic-wafer-sw" },
      { type = "unlock-recipe", recipe = "low-powered-integrated-circuit" },
      { type = "unlock-recipe", recipe = "hv-energy-hatch" },
      { type = "unlock-recipe", recipe = "hv-greenhouse" },
      { type = "unlock-recipe", recipe = "hv-drilling-rig-controller" },
      { type = "unlock-recipe", recipe = "hv-drilling-rig" },
      { type = "unlock-recipe", recipe = "hv-vacuum-freezer" },
      { type = "unlock-recipe", recipe = "ev-microverse-projector" },
    },
	prerequisites = { "hv-machines" },
	unit =
	{
      count = 460,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  }, 



---LARGE SIFTER
  {
    type = "technology",
    name = "large-sifter",
    icon = "__gregtorio-continued__/graphics/technology/large-sifter.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "tumbaga-dust" },          
      { type = "unlock-recipe", recipe = "tumbaga-ingot" },          
      { type = "unlock-recipe", recipe = "tumbaga-rod" },          
      { type = "unlock-recipe", recipe = "long-tumbaga-rod" },          
      { type = "unlock-recipe", recipe = "tumbaga-frame" },
      { type = "unlock-recipe", recipe = "item-filter" },
      { type = "unlock-recipe", recipe = "eglin-steel-plate" },
      { type = "unlock-recipe", recipe = "eglin-steel-rod" },
      { type = "unlock-recipe", recipe = "eglin-steel-frame" },
      { type = "unlock-recipe", recipe = "industrial-sieve-casing" },
      { type = "unlock-recipe", recipe = "large-sieve-grate" },
      { type = "unlock-recipe", recipe = "large-sifter-controller" },  
      { type = "unlock-recipe", recipe = "hv-large-sifter" },  
    },
	prerequisites = { "hv-energy-hatches", "extruder" },
	unit =
	{
      count = 480,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },  


 
---BAUXITE SLURRY PROCESS
  {
    type = "technology",
    name = "bauxite-slurry-process",
    icon = "__gregtorio-continued__/graphics/technology/bauxite-slurry-process.png",
    icon_size = 256,
    effects = {
       { type = "unlock-recipe", recipe = "quicklime" },
       { type = "unlock-recipe", recipe = "sodium-hydroxide" },
       { type = "unlock-recipe", recipe = "bauxite-slurry" },
       { type = "unlock-recipe", recipe = "clean-stainless-steel-casing" },
       { type = "unlock-recipe", recipe = "cracker-controller" },  
       { type = "unlock-recipe", recipe = "hv-cracker" },  
       { type = "unlock-recipe", recipe = "heated-bauxite-slurry" },
       { type = "unlock-recipe", recipe = "carbon-dioxide" },
       { type = "unlock-recipe", recipe = "sodium-aluminate-from-lazurite" },
       { type = "unlock-recipe", recipe = "sodium-aluminate-from-sodalite" },
       { type = "unlock-recipe", recipe = "aluminium-hydroxide" },
       { type = "unlock-recipe", recipe = "heated-bauxite-slurry-reaction" },
       { type = "unlock-recipe", recipe = "centrifuge-bauxite-slag" },
       { type = "unlock-recipe", recipe = "centrifuge-sluice-juice" },
       { type = "unlock-recipe", recipe = "sodium-carbonate-electrolysis" },
    },
	prerequisites = { "hv-energy-hatches", "ruby-juice" },
	unit =
	{
      count = 480,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  }, 
  
  

---ADVANCED HV MACHINES
  {
    type = "technology",
    name = "advanced-hv-machines",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "chromium-ingot" },
      { type = "unlock-recipe", recipe = "chromium-rod" },
      { type = "unlock-recipe", recipe = "hv-emitter" },
      { type = "unlock-recipe", recipe = "hv-laser-engraver" },  
      { type = "unlock-recipe", recipe = "hv-circuit-assembler"},  
      { type = "unlock-recipe", recipe = "hv-autoclave"},  
    },
	prerequisites = { "bauxite-slurry-process", "microprocessors" },
	unit =
	{
      count = 500,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },



---MAINFRAMES
  {
    type = "technology",
    name = "mainframes",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "microprocessor-mainframe" }, 
	},
	prerequisites = { "advanced-hv-machines", "smd-components" },
	unit =
	{
      count = 500,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },



---NICHROME COILS
  {
    type = "technology",
    name = "nichrome-coils",
    icon = "__gregtorio-continued__/graphics/technology/nichrome-coils.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "nichrome-dust" },
      { type = "unlock-recipe", recipe = "hot-nichrome-ingot" },
      { type = "unlock-recipe", recipe = "nichrome-ingot" },
      { type = "unlock-recipe", recipe = "nichrome-wire" },
      { type = "unlock-recipe", recipe = "stainless-steel-foil" },
      { type = "unlock-recipe", recipe = "molten-kanthal-extractor" },
      { type = "unlock-recipe", recipe = "nichrome-coil-block" },
      { type = "unlock-recipe", recipe = "ev-electric-blast-furnace" },
      { type = "unlock-recipe", recipe = "ev-pyrolyse-oven" },
      { type = "unlock-recipe", recipe = "ev-multismelter" }
    },
	prerequisites = { "hv-energy-hatches", "vacuum-freezers" },
	unit =
	{
      count = 520,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---DISTILLATION TOWERS
  {
    type = "technology",
    name = "oil-processing",
    icon = "__gregtorio-continued__/graphics/technology/distillation-towers.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "distillation-tower-controller" },  
      { type = "unlock-recipe", recipe = "hv-short-distillation-tower" },  
      { type = "unlock-recipe", recipe = "hv-tall-distillation-tower" },  
      { type = "unlock-recipe", recipe = "oil-distillation" },  
      { type = "unlock-recipe", recipe = "refinery-gas-desulfurization" },  
      { type = "unlock-recipe", recipe = "naphtha-desulfurization" },  
      { type = "unlock-recipe", recipe = "steam-cracked-gas" },  
      { type = "unlock-recipe", recipe = "steam-cracked-heavy-fuel" },  
      { type = "unlock-recipe", recipe = "steam-cracked-light-fuel" },  
      { type = "unlock-recipe", recipe = "steam-cracked-naphtha" },  
      { type = "unlock-recipe", recipe = "distilling-steam-cracked-gas" },  
      { type = "unlock-recipe", recipe = "distilling-steam-cracked-heavy-fuel" },  
      { type = "unlock-recipe", recipe = "distilling-steam-cracked-light-fuel" },  
      { type = "unlock-recipe", recipe = "distilling-steam-cracked-naphtha" },  
    },
	prerequisites = { "hv-energy-hatches", "microprocessors", "oil-gathering" },
	unit =
	{
      count = 520,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },


  

---MORE GAS TURBINE FUELS
  {
    type = "technology",
    name = "more-gas-turbine-fuels",
    icon = "__gregtorio-continued__/graphics/technology/more-gas-turbine-fuels.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "naphtha-cell" },
      { type = "unlock-recipe", recipe = "refinery-gas-cell" },
      { type = "unlock-recipe", recipe = "propane-cell" },
      { type = "unlock-recipe", recipe = "propene-cell" },
      { type = "unlock-recipe", recipe = "butadiene-cell" },
      { type = "unlock-recipe", recipe = "butene-cell" },
      { type = "unlock-recipe", recipe = "ethylene-cell" },
      { type = "unlock-recipe", recipe = "methane-cell" },
      { type = "unlock-recipe", recipe = "ethane-cell" },
      { type = "unlock-recipe", recipe = "toluene-cell" },
    },
	prerequisites = { "oil-processing" },
	unit =
	{
      count = 540,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---IMPLOSION COMPRESSOR
  {
    type = "technology",
    name = "implosion-compressor",
    icon = "__gregtorio-continued__/graphics/technology/implosion-compressor.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "reinforced-stone" },  
      { type = "unlock-recipe", recipe = "implosion-compressor-controller" },  
      { type = "unlock-recipe", recipe = "hv-implosion-compressor" },
      { type = "unlock-recipe", recipe = "gelled-toluene" },
      { type = "unlock-recipe", recipe = "ammonia" },
      { type = "unlock-recipe", recipe = "nitric-acid" },
      { type = "unlock-recipe", recipe = "nitration-mixture" },
      { type = "unlock-recipe", recipe = "explosives" },
    },
	prerequisites = { "oil-processing" },
	unit =
	{
      count = 540,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---PTFE
  {
    type = "technology",
    name = "ptfe",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "cryolite-electrolysis" },
      { type = "unlock-recipe", recipe = "hydrofluoric-acid" },
      { type = "unlock-recipe", recipe = "chloroform" },
      { type = "unlock-recipe", recipe = "tetrafluoroethylene-basic" },
      { type = "unlock-recipe", recipe = "ptfe" },
      { type = "unlock-recipe", recipe = "ptfe-sheet" },
      { type = "unlock-recipe", recipe = "plastic-circuit-board-ptfe" }
    },
	prerequisites = { "oil-processing" },
	unit =
	{
      count = 540,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---RADON
  {
    type = "technology",
    name = "radon",
    icon = "__gregtorio-continued__/graphics/technology/radon.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "microminer-radon-salt" }, 
      { type = "unlock-recipe", recipe = "radon-salt-electrolysis" },
      { type = "unlock-recipe", recipe = "quantum-eye" },
    },
	prerequisites = { "tier-two-microminers", "advanced-hv-machines" },
	unit =
	{
      count = 540,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---LARGE CHEMICAL REACTOR
  {
    type = "technology",
    name = "large-chemical-reactor",
    icon = "__gregtorio-continued__/graphics/technology/large-chemical-reactor.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "chemically-inert-casing" }, 
      { type = "unlock-recipe", recipe = "large-chemical-reactor-controller" },
      { type = "unlock-recipe", recipe = "ptfe-pipe-casing" },
      { type = "unlock-recipe", recipe = "hv-large-chemical-reactor" },
    },
	prerequisites = { "ptfe" },
	unit =
	{
      count = 560,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  

---ADVANCED GLUE
  {
    type = "technology",
    name = "advanced-glue",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "vinyl-acetate" }, 
      { type = "unlock-recipe", recipe = "polyvinyl-acetate" }, 
      { type = "unlock-recipe", recipe = "acetone" },
      { type = "unlock-recipe", recipe = "advanced-glue" }, 
      { type = "unlock-recipe", recipe = "resin-printed-circuit-board-advanced" },
      { type = "unlock-recipe", recipe = "phenolic-printed-circuit-board-advanced" },
    },
	prerequisites = { "polyvinyl-chloride", "large-chemical-reactor" },
	unit =
	{
      count = 560,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  }, 
  
  
  
---ROCKET FUEL
  {
    type = "technology",
    name = "rocket-fuel",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "hypochlorous-acid" }, 
      { type = "unlock-recipe", recipe = "dimethylhydrazine" }, 
      { type = "unlock-recipe", recipe = "rocket-fuel" }
    },
	prerequisites = { "large-chemical-reactor" },
	unit =
	{
      count = 560,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },  
  
  

---PHOSPHORUS DOPED MONOCRYSTALINE SILICON BOULES
  {
    type = "technology",
    name = "phosphorus-doped-monocrystaline-silicon-boules",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {  
      { type = "unlock-recipe", recipe = "phosphorus-doped-monocrystaline-silicon-boule" },  
      { type = "unlock-recipe", recipe = "phosphorus-doped-wafer" },
      { type = "unlock-recipe", recipe = "simple-soc-wafer-pd" },
      { type = "unlock-recipe", recipe = "ilc-wafer-pd" },
      { type = "unlock-recipe", recipe = "ram-wafer-pd" },
      { type = "unlock-recipe", recipe = "ulpic-wafer-pd" },
      { type = "unlock-recipe", recipe = "cpu-wafer-pd" },
      { type = "unlock-recipe", recipe = "lpic-wafer-pd" }
    },
	prerequisites = { "nichrome-coils" },
	unit =
	{
      count = 580,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  
  
---CRYOGENIC AIR DISTILLATION
  {
    type = "technology",
    name = "cryogenic-air-distillation",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {  
      { type = "unlock-recipe", recipe = "liquid-air" },  
      { type = "unlock-recipe", recipe = "cryogenic-air-distillation" }
    },
	prerequisites = { "oil-processing", "vacuum-freezers" },
	unit =
	{
      count = 580,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },  
 
 
  
---EPOXY PROCESSING
  {
    type = "technology",
    name = "epoxy-processing",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {  
      { type = "unlock-recipe", recipe = "epichlorohydrin" },  
      { type = "unlock-recipe", recipe = "salt-water-electrolysis" },  
      { type = "unlock-recipe", recipe = "epoxy" } 
    },
	prerequisites = { "large-chemical-reactor", "oil-processing" },
	unit =
	{
      count = 580,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  

---THE END DATA
  {
    type = "technology",
    name = "the-end-data",
    icon = "__gregtorio-continued__/graphics/technology/the-end-data.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "me-16k-storage-component" }, 
	  { type = "unlock-recipe", recipe = "the-end-data" }, 
	},
	prerequisites = { "mainframes" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  


---ELITE EXTENDED CRAFTING
  {
    type = "technology",
    name = "elite-extended-crafting",
    icon = "__gregtorio-continued__/graphics/technology/elite-extended-crafting.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "block-of-aluminium" }, 
      { type = "unlock-recipe", recipe = "elite-extended-crafting-component" },
      { type = "unlock-recipe", recipe = "elite-extended-crafting-catalyst" },
      { type = "unlock-recipe", recipe = "elite-extended-crafting-table" }
    },
	prerequisites = { "advanced-extended-crafting"},
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  },
  
  

---TIER THREE MICROMINERS
  {
    type = "technology",
    name = "tier-three-microminers",
    icon = "__gregtorio-continued__/graphics/technology/titanium-plated-microminer.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "solidified-argon" },
      { type = "unlock-recipe", recipe = "reinforced-mining-laser" },
      { type = "unlock-recipe", recipe = "titanium-heavy-plating" },
      { type = "unlock-recipe", recipe = "vibrant-alloy-ingot" },
      { type = "unlock-recipe", recipe = "molten-vibrant-alloy" },
      { type = "unlock-recipe", recipe = "vibrant-crystal" },
      { type = "unlock-recipe", recipe = "pulsating-iron-plate" },
      { type = "unlock-recipe", recipe = "pulsating-thruster" },
      { type = "unlock-recipe", recipe = "titanium-plated-microminer" },
      { type = "unlock-recipe", recipe = "tier-three-microminer-output" },
    },
	prerequisites = { "rocket-fuel", "cryogenic-air-distillation", "the-end-data", "implosion-compressor", "elite-extended-crafting" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 30
	}
  }, 
  
  
  
---EV SCIENCE PACK
  {
    type = "technology",
    name = "production-science-pack",
    icon = "__base__/graphics/technology/production-science-pack.png",
    icon_size = 256,
    effects = { 
		{ type = "unlock-recipe", recipe = "ev-science-pack" },  
    },
	prerequisites = { "tier-three-microminers" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP04}, {"logistic-science-pack", SP03}, {"military-science-pack", SP02}, {"chemical-science-pack", SP01} },
      time = 45
	}
  },
  
  

---TITANIUM
  {
    type = "technology",
    name = "titanium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "microminer-ilmenite" },
      { type = "unlock-recipe", recipe = "crushed-ilmenite" },
      { type = "unlock-recipe", recipe = "ilmenite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-ilmenite" },
      { type = "unlock-recipe", recipe = "ilmenite-to-rutile-ebf" },
      { type = "unlock-recipe", recipe = "titanium-tetrachloride" },
      { type = "unlock-recipe", recipe = "hot-titanium-ingot-from-tetrachloride" },
      { type = "unlock-recipe", recipe = "hot-titanium-ingot" },
      { type = "unlock-recipe", recipe = "magnesium-chloride-electrolysis" },
      { type = "unlock-recipe", recipe = "titanium-ingot" },
      { type = "unlock-recipe", recipe = "titanium-plate" },
      { type = "unlock-recipe", recipe = "titanium-rod" },
      { type = "unlock-recipe", recipe = "titanium-bolt" },
      { type = "unlock-recipe", recipe = "titanium-gear" },
      { type = "unlock-recipe", recipe = "titanium-frame" },
      { type = "unlock-recipe", recipe = "large-titanium-gear" },
      { type = "unlock-recipe", recipe = "titanium-rotor" },
    },
	prerequisites = { "large-chemical-reactor", "vacuum-freezers", "tier-two-microminers", "bauxite-slurry-process" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  


  ---TITANIUM BACKPACK
  {
    type = "technology",
    name = "titanium-backpack",
    icon = "__gregtorio-continued__/graphics/technology/titanium-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "stainless-steel-backpack", "titanium" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	} 
  },
 
 

---REINFORCED GLASS
  {
    type = "technology",
    name = "reinforced-glass",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "mixed-metal-ingot" }, 
	  { type = "unlock-recipe", recipe = "advanced-alloy" }, 
      { type = "unlock-recipe", recipe = "reinforced-glass" },              
    },
	prerequisites = { "production-science-pack" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },


  
---END STEEL
  {
    type = "technology",
    name = "end-steel",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "obsidian" },              
      { type = "unlock-recipe", recipe = "dark-steel-ingot" },
      { type = "unlock-recipe", recipe = "electrical-steel-ingot" },
	  { type = "unlock-recipe", recipe = "end-steel-ingot" },
	  { type = "unlock-recipe", recipe = "end-steel-wire" },
    },
	prerequisites = { "tier-three-microminers" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },


  
---EV COMPONENTS
  {
    type = "technology",
    name = "ev-components",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "aluminium-wire" },
      { type = "unlock-recipe", recipe = "aluminium-cable" },
      { type = "unlock-recipe", recipe = "neodymium-rod" },
      { type = "unlock-recipe", recipe = "magnetic-neodymium-rod" },
      { type = "unlock-recipe", recipe = "ev-motor" },
      { type = "unlock-recipe", recipe = "ev-piston" },
	  { type = "unlock-recipe", recipe = "ev-pump" },
	  { type = "unlock-recipe", recipe = "ev-conveyor-module" },
	  { type = "unlock-recipe", recipe = "ev-robot-arm" },
	  { type = "unlock-recipe", recipe = "ev-field-generator" },
	  { type = "unlock-recipe", recipe = "ev-machine-casing" },
	  { type = "unlock-recipe", recipe = "ev-machine-hull" },
    },
	prerequisites = { "titanium", "neodymium", "end-steel" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  
  
  
---EV MACHINES
  {
    type = "technology",
    name = "ev-machines",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "ev-wiremill" },
      { type = "unlock-recipe", recipe = "ev-bending-machine" },
      { type = "unlock-recipe", recipe = "ev-alloy-smelter" },
      { type = "unlock-recipe", recipe = "ev-polarizer" },
      { type = "unlock-recipe", recipe = "ev-rock-crusher" },
      { type = "unlock-recipe", recipe = "ev-ore-washer" },
      { type = "unlock-recipe", recipe = "ev-centrifuge" },
      { type = "unlock-recipe", recipe = "ev-mixer" },
      { type = "unlock-recipe", recipe = "ev-extractor" },
      { type = "unlock-recipe", recipe = "ev-assembling-machine" },
      { type = "unlock-recipe", recipe = "ev-lathe" },
      { type = "unlock-recipe", recipe = "ev-electrolyzer" },
      { type = "unlock-recipe", recipe = "ev-extruder" },
      { type = "unlock-recipe", recipe = "ev-macerator" },
      { type = "unlock-recipe", recipe = "ev-chemical-bath" },
      { type = "unlock-recipe", recipe = "ev-cutting-machine" },
      { type = "unlock-recipe", recipe = "ev-extruder" },
      { type = "unlock-recipe", recipe = "ev-air-collector" },
      { type = "unlock-recipe", recipe = "ev-fluid-solidifier" },
      { type = "unlock-recipe", recipe = "ev-laser-engraver" },
      { type = "unlock-recipe", recipe = "ev-autoclave" },
      { type = "unlock-recipe", recipe = "ev-compressor" },
      { type = "unlock-recipe", recipe = "ev-canning-machine" },
      { type = "unlock-recipe", recipe = "ev-circuit-assembler" },
    },
	prerequisites = { "ev-components", "reinforced-glass" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },    



---EV ENERGY HATCHES
  {
    type = "technology",
    name = "ev-energy-hatches",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "mpic-wafer-pd" },       
      { type = "unlock-recipe", recipe = "medium-powered-integrated-circuit" },    
      { type = "unlock-recipe", recipe = "extreme-voltage-coil" },       
      { type = "unlock-recipe", recipe = "ev-energy-hatch" },
      { type = "unlock-recipe", recipe = "ev-greenhouse" },
      { type = "unlock-recipe", recipe = "ev-drilling-rig-controller" },
      { type = "unlock-recipe", recipe = "ev-drilling-rig" },
      { type = "unlock-recipe", recipe = "ev-vacuum-freezer" },
      { type = "unlock-recipe", recipe = "ev-implosion-compressor" },	  
      { type = "unlock-recipe", recipe = "ev-large-chemical-reactor" },	  
      { type = "unlock-recipe", recipe = "ev-cracker" },
      { type = "unlock-recipe", recipe = "ev-short-distillation-tower" },
      { type = "unlock-recipe", recipe = "ev-tall-distillation-tower" },
    },
	prerequisites = { "phosphorus-doped-monocrystaline-silicon-boules", "ev-machines" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



---RTM ALLOY COILS
  {
    type = "technology",
    name = "rtm-alloy-coils",
    icon = "__gregtorio-continued__/graphics/technology/rtm-alloy-coils.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "rtm-alloy-dust" },
      { type = "unlock-recipe", recipe = "hot-rtm-alloy-ingot" },
      { type = "unlock-recipe", recipe = "rtm-alloy-ingot" },
      { type = "unlock-recipe", recipe = "rtm-alloy-wire" },
      { type = "unlock-recipe", recipe = "vanadium-steel-foil" },
      { type = "unlock-recipe", recipe = "rtm-alloy-coil-block" },
--      { type = "unlock-recipe", recipe = "iv-electric-blast-furnace" },
--      { type = "unlock-recipe", recipe = "iv-pyrolyse-oven" },
--      { type = "unlock-recipe", recipe = "iv-multismelter" }
    },
	prerequisites = { "ev-energy-hatches" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
 


---ADVANCED EV MACHINES
  {
    type = "technology",
    name = "advanced-ev-machines",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "platinum-rod" },
	  { type = "unlock-recipe", recipe = "ev-sensor" },
	  { type = "unlock-recipe", recipe = "ev-emitter" },
    },
	prerequisites = { "mainframes", "ev-machines", "radon" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },   



---NANOPROCESSORS
  {
    type = "technology",
    name = "nanoprocessors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "gold-foil" },  
      { type = "unlock-recipe", recipe = "electrum-foil" },  
      { type = "unlock-recipe", recipe = "epoxy-circuit-board" },  
      { type = "unlock-recipe", recipe = "epoxy-printed-circuit-board" },  
      { type = "unlock-recipe", recipe = "molten-glowstone" },  
      { type = "unlock-recipe", recipe = "raw-carbon-fibers-epoxy" },  
      { type = "unlock-recipe", recipe = "nano-cpu-wafer" },  
      { type = "unlock-recipe", recipe = "nano-cpu-chip" },  
      { type = "unlock-recipe", recipe = "nanoprocessor" },  
      { type = "unlock-recipe", recipe = "nanoprocessor-assembly" },  
      { type = "unlock-recipe", recipe = "nor-memory-wafer-pd" },  
      { type = "unlock-recipe", recipe = "nor-memory-chip" },  
      { type = "unlock-recipe", recipe = "nanoprocessor-supercomputer" },  
      { type = "unlock-recipe", recipe = "nanoprocessor-mainframe" },   
    },
	prerequisites = { "epoxy-processing", "phosphorus-doped-monocrystaline-silicon-boules", "advanced-ev-machines" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



---ENDER IO
  {
    type = "technology",
    name = "ender-io",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {          
      { type = "unlock-recipe", recipe = "dark-steel-plate" },	
      { type = "unlock-recipe", recipe = "electrical-steel-ingot" },              
      { type = "unlock-recipe", recipe = "electrical-steel-plate" },              
      { type = "unlock-recipe", recipe = "microminer-soul-sand" },
      { type = "unlock-recipe", recipe = "soularium-ingot" },
      { type = "unlock-recipe", recipe = "soularium-plate" },              
      { type = "unlock-recipe", recipe = "enderio-capacitor" },              
      { type = "unlock-recipe", recipe = "double-layer-capacitor" },              
      { type = "unlock-recipe", recipe = "octadic-capacitor" },              
      { type = "unlock-recipe", recipe = "machine-chassis" },              
      { type = "unlock-recipe", recipe = "microminer-zombie-heads" },  
      { type = "unlock-recipe", recipe = "slice-n-splice" },
      { type = "unlock-recipe", recipe = "z-logic-controller" },
      { type = "unlock-recipe", recipe = "microminer-wither-skulls" },  
      { type = "unlock-recipe", recipe = "soul-binder" },
      { type = "unlock-recipe", recipe = "soul-vial" },              
      { type = "unlock-recipe", recipe = "fused-quartz" },
      { type = "unlock-recipe", recipe = "soularium-nugget" },
      { type = "unlock-recipe", recipe = "soularium-round" },
      { type = "unlock-recipe", recipe = "soul-vial" },
      { type = "unlock-recipe", recipe = "zombie-soul-vial-manual" },              
      { type = "unlock-recipe", recipe = "frank-n-zombie" },              
      { type = "unlock-recipe", recipe = "enderman-soul-vial-manual" },              
      { type = "unlock-recipe", recipe = "ender-crystal" },  
      { type = "unlock-recipe", recipe = "powered-spawner" },              
      { type = "unlock-recipe", recipe = "filled-soul-vial-zombie" },     
      { type = "unlock-recipe", recipe = "filled-soul-vial-enderman" }, 

 },
	prerequisites = { "ev-machines", "large-chemical-reactor" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },




---EXTREME ENTITY CRUSHERS
  {
    type = "technology",
    name = "extreme-entity-crushers",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "borosilicate-glass-dust" },              
      { type = "unlock-recipe", recipe = "molten-borosilicate-glass" },              
      { type = "unlock-recipe", recipe = "borosilicate-glass-block" },              
      { type = "unlock-recipe", recipe = "diamond-rod" },              
      { type = "unlock-recipe", recipe = "diamond-bolt" },              
      { type = "unlock-recipe", recipe = "diamond-screw" },              
      { type = "unlock-recipe", recipe = "diamond-spike" },              
      { type = "unlock-recipe", recipe = "extreme-entity-crusher-controller" },              
      { type = "unlock-recipe", recipe = "ev-extreme-entity-crusher" },              
      { type = "unlock-recipe", recipe = "crushing-zombies" },              
      { type = "unlock-recipe", recipe = "crushing-blazes" },              
      { type = "unlock-recipe", recipe = "crushing-wither-skeletons" },              
      { type = "unlock-recipe", recipe = "crushing-the-wither" },              
    },
	prerequisites = { "ender-io" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



---URANIUM PROCESSING
  {
    type = "technology",
    name = "uranium-processing",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "microminer-uranium" },              
      { type = "unlock-recipe", recipe = "raw-pitchblende-smelter" },
      { type = "unlock-recipe", recipe = "raw-pitchblende-multismelter" },
      { type = "unlock-recipe", recipe = "crushed-pitchblende" },
      { type = "unlock-recipe", recipe = "pitchblende-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-pitchblende" },
      { type = "unlock-recipe", recipe = "centrifuging-pitchblende" },
      { type = "unlock-recipe", recipe = "raw-uraninite-smelter" },
      { type = "unlock-recipe", recipe = "raw-uraninite-multismelter" },
      { type = "unlock-recipe", recipe = "crushed-uraninite" },
      { type = "unlock-recipe", recipe = "uraninite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-uraninite" },
     
    },
	prerequisites = { "tier-three-microminers" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  



---SILICONE RUBBER
  {
    type = "technology",
    name = "silicone-rubber",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "polydimethylsiloxane" },              
      { type = "unlock-recipe", recipe = "silicone-rubber" },              
      { type = "unlock-recipe", recipe = "silicone-rubber-sheet" },              
      { type = "unlock-recipe", recipe = "silicone-rubber-ring" },              
      { type = "unlock-recipe", recipe = "red-alloy-cable-silicone" },              
      { type = "unlock-recipe", recipe = "tin-cable-silicone" },              
      { type = "unlock-recipe", recipe = "copper-cable-silicone" },              
      { type = "unlock-recipe", recipe = "gold-cable-silicone" },              
      { type = "unlock-recipe", recipe = "silver-cable-silicone" },              
      { type = "unlock-recipe", recipe = "aluminium-cable-silicone" },              
    },
	prerequisites = { "ev-machines", "large-chemical-reactor" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
 
 

---POLYPHENYLENE SULFIDE
  {
    type = "technology",
    name = "polyphenylene-sulfide",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "dichlorobenzene" }, 
	  { type = "unlock-recipe", recipe = "sodium-sulfide" }, 
	  { type = "unlock-recipe", recipe = "polyphenylene-sulfide" }, 
	  { type = "unlock-recipe", recipe = "polyphenylene-sulfide-sheet" }, 
	  { type = "unlock-recipe", recipe = "thin-polyphenylene-sulfide-sheet" }, 
	},
	prerequisites = { "silicone-rubber" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  
  
  
  
  ---PLATINUM ORE PROCESSING
  {
    type = "technology",
    name = "platinum-ore-processing",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "platinum-group-sludge-pentlandite" },          
      { type = "unlock-recipe", recipe = "platinum-group-sludge-bornite" },          
      { type = "unlock-recipe", recipe = "platinum-group-sludge-tetrahedrite" },                
      { type = "unlock-recipe", recipe = "platinum-group-sludge-sheldonite" },          
      { type = "unlock-recipe", recipe = "sulfuric-nickel-solution-electrolysis" },          
      { type = "unlock-recipe", recipe = "sulfuric-copper-solution-electrolysis" },                   
    },
	prerequisites = { "ev-machines" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  
  
  
  ---PLATINUM LINE INITIALIZATION
  {
    type = "technology",
    name = "platinum-line-initialization",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {        
      { type = "unlock-recipe", recipe = "aqua-regia" },          
      { type = "unlock-recipe", recipe = "platinum-group-sludge-processing" },          
      { type = "unlock-recipe", recipe = "platinum-sludge-residue-processing" },          
    },
	prerequisites = { "platinum-ore-processing" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  
  

  ---PLATINUM
  {
    type = "technology",
    name = "platinum",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "ammonium-chloride" },          
      { type = "unlock-recipe", recipe = "platinum-palladium-leachate-processing" },          
      { type = "unlock-recipe", recipe = "metallic-platinum-powder" },          
      { type = "unlock-recipe", recipe = "metallic-platinum-powder-processing" },          
      { type = "unlock-recipe", recipe = "raw-platinum-powder" },          
      { type = "unlock-recipe", recipe = "platinum-dust" },          
         
    },
	prerequisites = { "platinum-line-initialization" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  
  
  
  
---NUCLEAR REACTOR
  {
    type = "technology",
    name = "nuclear-power",
    icon = "__gregtorio-continued__/graphics/technology/nuclear-reactor.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "heat-vent" }, 
	  { type = "unlock-recipe", recipe = "advanced-heat-vent" }, 
	  { type = "unlock-recipe", recipe = "overclocked-heat-vent" }, 
	  { type = "unlock-recipe", recipe = "component-heat-vent" }, 
	  { type = "unlock-recipe", recipe = "silver-plate" }, 
	  { type = "unlock-recipe", recipe = "heat-exchanger" }, 
	  { type = "unlock-recipe", recipe = "dense-tin-plate" }, 
	  { type = "unlock-recipe", recipe = "component-heat-exchanger" }, 
	  { type = "unlock-recipe", recipe = "lead-plate" }, 
	  { type = "unlock-recipe", recipe = "advanced-machine-casing" }, 
	  { type = "unlock-recipe", recipe = "dense-lead-plate" }, 
	  { type = "unlock-recipe", recipe = "dense-titanium-plate" }, 
	  { type = "unlock-recipe", recipe = "reactor-chamber" }, 
	  { type = "unlock-recipe", recipe = "nuclear-reactor-primary-chamber" }, 
	  { type = "unlock-recipe", recipe = "platinum-wire" }, 
	  { type = "unlock-recipe", recipe = "platinum-cable" }, 
	  { type = "unlock-recipe", recipe = "basic-nuclear-reactor" }, 
	},
	prerequisites = { "platinum", "polyphenylene-sulfide" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  }, 



---NUCLEAR FUEL RODS
  {
    type = "technology",
    name = "nuclear-fuel-rods",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "raw-thorium-smelter" },
      { type = "unlock-recipe", recipe = "raw-thorium-multismelter" },
      { type = "unlock-recipe", recipe = "crushed-thorium" },
      { type = "unlock-recipe", recipe = "thorium-dust" },
      { type = "unlock-recipe", recipe = "empty-fuel-rod" },                  
      { type = "unlock-recipe", recipe = "thorium-fuel-rod" },                  
      { type = "unlock-recipe", recipe = "uranium-hexafluoride" },                  
      { type = "unlock-recipe", recipe = "uranium-enrichment" },                  
      { type = "unlock-recipe", recipe = "enriched-uranium-hexafluoride-electrolysis" },                  
      { type = "unlock-recipe", recipe = "depleted-uranium-hexafluoride-electrolysis" },                  
      { type = "unlock-recipe", recipe = "uranium-fuel-rod" },                  
    },
	prerequisites = { "nuclear-power" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
    
  
  
  ---PALLADIUM
  {
    type = "technology",
    name = "palladium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {         
      { type = "unlock-recipe", recipe = "sodium-formate" },          
      { type = "unlock-recipe", recipe = "formic-acid" },          
      { type = "unlock-recipe", recipe = "crude-palladium-residue" },          
      { type = "unlock-recipe", recipe = "platinum-palladium-leachate-processing" },          
      { type = "unlock-recipe", recipe = "metallic-palladium-powder" },          
      { type = "unlock-recipe", recipe = "palladium-rich-ammonia-processing" },          
      { type = "unlock-recipe", recipe = "raw-palladium-powder-processing" },                   
         
    },
	prerequisites = { "platinum" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



  ---RHODIUM
  {
    type = "technology",
    name = "rhodium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "potassium-pyrosulfate" },          
      { type = "unlock-recipe", recipe = "platinum-group-residue-processing" },          
      { type = "unlock-recipe", recipe = "potassium-sulfate-processing" },   
      { type = "unlock-recipe", recipe = "rhodium-sulfate-processing" },          
      { type = "unlock-recipe", recipe = "platinum-palladium-leachate-processing" },          
      { type = "unlock-recipe", recipe = "rhodium-sulfate-solution-processing" },          
      { type = "unlock-recipe", recipe = "zinc-sulfate-electrolysis" },          
      { type = "unlock-recipe", recipe = "crude-rhodium-residue-processing" },                   
      { type = "unlock-recipe", recipe = "sodium-nitrate" },                   
      { type = "unlock-recipe", recipe = "rhodium-salt-processing" },                   
      { type = "unlock-recipe", recipe = "rhodium-nitrate-processing" },  
    }, 
	prerequisites = { "platinum-line-initialization" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



  ---RUTHENIUM
  {
    type = "technology",
    name = "ruthenium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "soda-ash" },
      { type = "unlock-recipe", recipe = "iridium-group-sludge-processing" },
      { type = "unlock-recipe", recipe = "ruthenium-tetroxide" },
      { type = "unlock-recipe", recipe = "ruthenium-dust" },
    },
	prerequisites = { "rhodium" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  
 


  ---IRIDIUM
  {
    type = "technology",
    name = "iridium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "iridium-metal-residue" },
      { type = "unlock-recipe", recipe = "hydrogen-peroxide" },
      { type = "unlock-recipe", recipe = "sodium-peroxide" },
      { type = "unlock-recipe", recipe = "iridium-dioxide-residue" },
      { type = "unlock-recipe", recipe = "acidic-iridium-dioxide-solution" },
      { type = "unlock-recipe", recipe = "ammonia-hexachloroiridiate" },
      { type = "unlock-recipe", recipe = "iridium-dust" },
    },
	prerequisites = { "ruthenium" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



  ---OSMIUM
  {
    type = "technology",
    name = "osmium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "osmium-tetroxide" },
      { type = "unlock-recipe", recipe = "osmium-dust" },
    },
	prerequisites = { "iridium" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },   
  
  
  
---TUNGSTATE PROCESSING
  {
    type = "technology",
    name = "tungstate-processing",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "microminer-tungstate" },
      { type = "unlock-recipe", recipe = "raw-tungstate-smelter" },
      { type = "unlock-recipe", recipe = "raw-tungstate-multismelter" },
      { type = "unlock-recipe", recipe = "crushed-tungstate" },
      { type = "unlock-recipe", recipe = "tungstate-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-tungstate" },
      { type = "unlock-recipe", recipe = "raw-scheelite-smelter" },
      { type = "unlock-recipe", recipe = "raw-scheelite-multismelter" },
      { type = "unlock-recipe", recipe = "crushed-scheelite" },
      { type = "unlock-recipe", recipe = "scheelite-dust" },
      { type = "unlock-recipe", recipe = "centrifuging-crushed-scheelite" },
      { type = "unlock-recipe", recipe = "tungstate-dust-autoclaving" },      
      { type = "unlock-recipe", recipe = "scheelite-dust" },      
      { type = "unlock-recipe", recipe = "calcium-chloride" },      
      { type = "unlock-recipe", recipe = "calcium-chloride-electrolysis" },      
    },
	prerequisites = { "tier-three-microminers" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },


  
---TUNGSTEN
  {
    type = "technology",
    name = "tungsten",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "tungstic-acid" },         
      { type = "unlock-recipe", recipe = "tungsten-trioxide" },         
      { type = "unlock-recipe", recipe = "tungsten-dust" },         
      { type = "unlock-recipe", recipe = "hot-tungsten-ingot" },         
      { type = "unlock-recipe", recipe = "tungsten-ingot" },         
      { type = "unlock-recipe", recipe = "tungsten-wire" },         
      { type = "unlock-recipe", recipe = "long-tungsten-rod" },         
      { type = "unlock-recipe", recipe = "tungsten-spring" },         
    },
	prerequisites = { "tungstate-processing" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  

  
---TUNGSTENSTEEL
  {
    type = "technology",
    name = "tungstensteel",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "tungstensteel-dust" },      
      { type = "unlock-recipe", recipe = "hot-tungstensteel-ingot" },      
      { type = "unlock-recipe", recipe = "tungstensteel-ingot" },      
      { type = "unlock-recipe", recipe = "molten-tungstensteel" },      
      { type = "unlock-recipe", recipe = "solidify-tungstensteel-ingot" },      
      { type = "unlock-recipe", recipe = "tungstensteel-plate" },      
      { type = "unlock-recipe", recipe = "tungstensteel-rod" },      
      { type = "unlock-recipe", recipe = "tungstensteel-gear" },      
      { type = "unlock-recipe", recipe = "tungstensteel-bolt" },      
      { type = "unlock-recipe", recipe = "tungstensteel-screw" },      
      { type = "unlock-recipe", recipe = "tungstensteel-rotor" },      
      { type = "unlock-recipe", recipe = "tungstensteel-frame" },      
    },
	prerequisites = { "tungsten" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  


  ---TUNGSTENSTEEL BACKPACK
  {
    type = "technology",
    name = "tungstensteel-backpack",
    icon = "__gregtorio-continued__/graphics/technology/tungstensteel-backpack.png",
    icon_size = 256,
    effects = {
		{ type = "character-inventory-slots-bonus", modifier = 20 },
    },
	prerequisites = { "titanium-backpack", "tungstensteel" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
},  
  
  
  
---TUNGSTEN CARBIDE
  {
    type = "technology",
    name = "tungsten-carbide",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {          
      { type = "unlock-recipe", recipe = "molten-tungsten-carbide" },          
      { type = "unlock-recipe", recipe = "solidify-tungsten-carbide-ingot" },          
      { type = "unlock-recipe", recipe = "tungsten-carbide-plate" },          
      { type = "unlock-recipe", recipe = "tungsten-carbide-rod" },          
      { type = "unlock-recipe", recipe = "tungsten-carbide-frame" },          
    },
	prerequisites = { "tungsten" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
   


  ---STABALLOY
  {
    type = "technology",
    name = "staballoy",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "staballoy-dust" },
      { type = "unlock-recipe", recipe = "hot-staballoy-ingot" },
      { type = "unlock-recipe", recipe = "staballoy-ingot" },
      { type = "unlock-recipe", recipe = "staballoy-plate" },
    },
	prerequisites = { "uranium-processing" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  
   


  ---ZIRCONIUM CARBIDE
  {
    type = "technology",
    name = "zirconium-carbide",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust" },
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust-smelter" },
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust-multismelter" },
      { type = "unlock-recipe", recipe = "zirconium-carbide-plate" },
      { type = "unlock-recipe", recipe = "zirconium-carbide-rod" },
      { type = "unlock-recipe", recipe = "zirconium-carbide-frame" },
    },
	prerequisites = { "uranium-processing" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  }, 
  
  
  
---ALLOY BLAST SMELTER
  {
    type = "technology",
    name = "alloy-blast-smelter",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust" },               
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust-smelter" },               
      { type = "unlock-recipe", recipe = "zirconium-carbide-dust-multismelter" },               
      { type = "unlock-recipe", recipe = "zirconium-carbide-plate" },               
      { type = "unlock-recipe", recipe = "high-temperature-smelting-casing" },               
      { type = "unlock-recipe", recipe = "heat-vent-block" },               
      { type = "unlock-recipe", recipe = "alloy-blast-smelter-controller" },               
      { type = "unlock-recipe", recipe = "ev-alloy-blast-smelter" },               
    },
	prerequisites = { "tungstensteel", "zirconium-carbide", "staballoy" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  
  
  
---ALLOY BLAST SMELTING OLDER MATERIALS
  {
    type = "technology",
    name = "alloy-blast-smelting-older-materials",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-nickel-zinc-ferrite" },
      { type = "unlock-recipe", recipe = "solidify-nickel-zinc-ferrite-ingot" },
      { type = "unlock-recipe", recipe = "molten-microversium" },
      { type = "unlock-recipe", recipe = "solidify-microversium-ingot" },
      { type = "unlock-recipe", recipe = "molten-vanadium-steel" },
      { type = "unlock-recipe", recipe = "solidify-vanadium-steel-ingot" },
      { type = "unlock-recipe", recipe = "molten-kanthal" },
      { type = "unlock-recipe", recipe = "solidify-kanthal-ingot" },
      { type = "unlock-recipe", recipe = "molten-stainless-steel" },
      { type = "unlock-recipe", recipe = "solidify-stainless-steel-ingot" },
      { type = "unlock-recipe", recipe = "molten-tungstensteel" },
      { type = "unlock-recipe", recipe = "solidify-tungstensteel-ingot" },
      { type = "unlock-recipe", recipe = "molten-staballoy" },
      { type = "unlock-recipe", recipe = "solidify-staballoy-ingot" },
      { type = "unlock-recipe", recipe = "molten-nichrome" },
      { type = "unlock-recipe", recipe = "solidify-nichrome-ingot" },
      { type = "unlock-recipe", recipe = "molten-rtm-alloy" },
      { type = "unlock-recipe", recipe = "solidify-rtm-alloy-ingot" },
    },
	prerequisites = { "alloy-blast-smelter" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  
  
  
---POLYBENZIMIDAZOLE
  {
    type = "technology",
    name = "polybenzimidazole",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-niobium-titanium" },        
    },
	prerequisites = { "ev-machines" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },  



---NIOBIUM TITANIUM
  {
    type = "technology",
    name = "niobium-titanium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-niobium-titanium" },          
      { type = "unlock-recipe", recipe = "solidify-niobium-titanium-ingot" },          
      { type = "unlock-recipe", recipe = "niobium-titanium-wire" },                  
    },
	prerequisites = { "niobium-and-tantalum-extraction" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },   
  


---HSS-G
  {
    type = "technology",
    name = "hssg",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {    
      { type = "unlock-recipe", recipe = "molten-hssg" },    
      { type = "unlock-recipe", recipe = "solidify-hssg-ingot" },    
      { type = "unlock-recipe", recipe = "hssg-plate" },    
      { type = "unlock-recipe", recipe = "hssg-frame" },    
      { type = "unlock-recipe", recipe = "fine-hssg-wire" },    
    },
	prerequisites = { "tungstensteel" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },
  
  
  
---HSS-E
  {
    type = "technology",
    name = "hsse",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "hssg-dust" }, 
      { type = "unlock-recipe", recipe = "molten-hsse" },    
      { type = "unlock-recipe", recipe = "solidify-hsse-ingot" },    
      { type = "unlock-recipe", recipe = "hsse-ring" },    
    },
	prerequisites = { "hssg" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



---HSS-S
  {
    type = "technology",
    name = "hsss",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-hsss" },    
      { type = "unlock-recipe", recipe = "solidify-hsss-ingot" },       
      { type = "unlock-recipe", recipe = "hsss-foil" },       
    },
	prerequisites = { "hsse" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },    
  


---ADVANCED SMDS
  {
    type = "technology",
    name = "advanced-smds",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "advanced-smd-resistor" },  
      { type = "unlock-recipe", recipe = "advanced-smd-transistor" },  
      { type = "unlock-recipe", recipe = "advanced-smd-capacitor" },  
      { type = "unlock-recipe", recipe = "advanced-smd-inductor" },  
      { type = "unlock-recipe", recipe = "advanced-smd-diode" },  
    },
	prerequisites = { "polybenzimidazole", "hsss", "niobium-titanium" },
	unit =
	{
      count = 600,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 45
	}
  },



---IV SCIENCE PACK
  {
    type = "technology",
    name = "utility-science-pack",
    icon = "__base__/graphics/technology/utility-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "production-science-pack" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 60
	}
  },



---GRAPHENE
  {
    type = "technology",
    name = "graphene",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "graphene-pd" },
      { type = "unlock-recipe", recipe = "graphene-wire" },
    },
	prerequisites = { "advanced-glue", "phosphorus-doped-monocrystaline-silicon-boules" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  
  
---IV COMPONENTS
  {
    type = "technology",
    name = "iv-components",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "tungsten-cable" },
      { type = "unlock-recipe", recipe = "iv-motor" },
      { type = "unlock-recipe", recipe = "iv-piston" },
	  { type = "unlock-recipe", recipe = "iv-pump" },
	  { type = "unlock-recipe", recipe = "iv-conveyor-module" },
	  { type = "unlock-recipe", recipe = "iv-robot-arm" },
	  { type = "unlock-recipe", recipe = "iridium-rod" },
	  { type = "unlock-recipe", recipe = "quantum-star" },
	  { type = "unlock-recipe", recipe = "iv-sensor" },
	  { type = "unlock-recipe", recipe = "iv-emitter" },
	  { type = "unlock-recipe", recipe = "iv-machine-casing" },
	  { type = "unlock-recipe", recipe = "iv-machine-hull" },
    },
	prerequisites = { "graphene" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  


---IV MACHINES
  {
    type = "technology",
    name = "iv-machines",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
 
    },
	prerequisites = { "iv-components" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },  

  

---INDIUM
  {
    type = "technology",
    name = "indium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "indium-concentrate" },  
      { type = "unlock-recipe", recipe = "indium-separation" },  
      { type = "unlock-recipe", recipe = "lead-zinc-solution-centrifuging" },  
    },
	prerequisites = { "iv-machines" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },



---IV ENERGY HATCHES
  {
    type = "technology",
    name = "iv-energy-hatches",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "hpic-wafer" },       
      { type = "unlock-recipe", recipe = "high-powered-integrated-circuit" },       
      { type = "unlock-recipe", recipe = "fine-iridium-wire" },       
      { type = "unlock-recipe", recipe = "insane-voltage-coil" },       
      { type = "unlock-recipe", recipe = "iv-energy-hatch" },       
      { type = "unlock-recipe", recipe = "iv-dynamo-hatch" },       
    },
	prerequisites = { "tungstensteel", "indium", "iridium" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },  
  
  

---INDUSTRIAL MACERATION STACK
  {
    type = "technology",
    name = "industrial-maceration-stack",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "industrial-maceration-stack-controller" },          
      { type = "unlock-recipe", recipe = "iv-industrial-maceration-stack" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },  
  
  

---INDUSTRIAL WIRE FACTORY
  {
    type = "technology",
    name = "industrial-wire-factory",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "industrial-wire-factory-controller" },          
      { type = "unlock-recipe", recipe = "wire-factory-casing" },          
      { type = "unlock-recipe", recipe = "iv-industrial-wire-factory" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL MIXER
  {
    type = "technology",
    name = "industrial-mixer",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "zirconium-carbide-rod" },          
      { type = "unlock-recipe", recipe = "zirconium-carbide-frame" },          
      { type = "unlock-recipe", recipe = "industrial-mixer-controller" },          
      { type = "unlock-recipe", recipe = "multi-use-casing" },          
      { type = "unlock-recipe", recipe = "iv-industrial-mixer" },       
    },
	prerequisites = { "staballoy", "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL CENTRIFUGE
  {
    type = "technology",
    name = "industrial-centrifuge",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-maraging-steel-250" },
      { type = "unlock-recipe", recipe = "solidify-maraging-steel-250-ingot" },
      { type = "unlock-recipe", recipe = "maraging-steel-250-plate" },
      { type = "unlock-recipe", recipe = "molten-inconel-792" },
      { type = "unlock-recipe", recipe = "solidify-inconel-792-ingot" },
      { type = "unlock-recipe", recipe = "inconel-792-plate" },
      { type = "unlock-recipe", recipe = "industrial-centrifuge-controller" },          
      { type = "unlock-recipe", recipe = "centrifuge-casing" },          
      { type = "unlock-recipe", recipe = "iv-industrial-centrifuge" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---HYPER INTENSITY LASER ENGRAVER
  {
    type = "technology",
    name = "hyper-intensity-laser-engraver",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-hastelloy-x" },          
      { type = "unlock-recipe", recipe = "molten-nitinol-60" },          
      { type = "unlock-recipe", recipe = "solidify-nitinol-60-ingot" },          
      { type = "unlock-recipe", recipe = "nitinol-60-plate" },          
      { type = "unlock-recipe", recipe = "nitinol-60-rod" },          
      { type = "unlock-recipe", recipe = "nitinol-60-frame" },          
      { type = "unlock-recipe", recipe = "hyper-intensity-laser-engraver-controller" },          
      { type = "unlock-recipe", recipe = "laser-containment-casing" },          
      { type = "unlock-recipe", recipe = "iv-laser-source-hatch" },          
      { type = "unlock-recipe", recipe = "laser-resistant-plate" },          
      { type = "unlock-recipe", recipe = "iv-hyper-intensity-laser-engraver" },       
    },
	prerequisites = { "industrial-electrolyzer" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },  
  
  

---INDUSTRIAL EXTRUSION MACHINE
  {
    type = "technology",
    name = "industrial-extrusion-machine",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {      
      { type = "unlock-recipe", recipe = "molten-inconel-690" },          
      { type = "unlock-recipe", recipe = "solidify-inconel-690-ingot" },          
      { type = "unlock-recipe", recipe = "inconel-690-plate" },          
      { type = "unlock-recipe", recipe = "staballoy-rod" },          
      { type = "unlock-recipe", recipe = "staballoy-frame" },          
      { type = "unlock-recipe", recipe = "industrial-extrusion-machine-controller" },          
      { type = "unlock-recipe", recipe = "inconel-reinforced-casing" },          
      { type = "unlock-recipe", recipe = "iv-industrial-extrusion-machine" },       
    },
	prerequisites = { "staballoy", "industrial-cutting-factory" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---ZYNGEN
  {
    type = "technology",
    name = "zyngen",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {       
      { type = "unlock-recipe", recipe = "molten-incoloy-ds" },          
      { type = "unlock-recipe", recipe = "solidify-incoloy-ds-ingot" },          
      { type = "unlock-recipe", recipe = "incoloy-ds-plate" },      
      { type = "unlock-recipe", recipe = "large-incoloy-ds-gear" },      
      { type = "unlock-recipe", recipe = "zyngen-controller" },          
      { type = "unlock-recipe", recipe = "integral-encasement-v" },          
      { type = "unlock-recipe", recipe = "iv-zyngen" },       
    },
	prerequisites = { "industrial-extrusion-machine", "industrial-centrifuge" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL MATERIAL PRESS
  {
    type = "technology",
    name = "industrial-wire-factory",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {      
      { type = "unlock-recipe", recipe = "molten-tantalloy-60" },          
      { type = "unlock-recipe", recipe = "solidify-tantalloy-60-ingot" },          
      { type = "unlock-recipe", recipe = "tantalloy-60-rod" },          
      { type = "unlock-recipe", recipe = "industrial-material-press-controller" },          
      { type = "unlock-recipe", recipe = "material-press-machine-casing" },          
      { type = "unlock-recipe", recipe = "iv-industrial-material-press" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---LARGE ELECTRIC COMPRESSOR
  {
    type = "technology",
    name = "large-electric-compressor",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "solidify-incoloy-903-ingot" },          
      { type = "unlock-recipe", recipe = "incoloy-903-plate" },          
      { type = "unlock-recipe", recipe = "large-electric-compressor-controller" },          
      { type = "unlock-recipe", recipe = "electric-compressor-casing" },          
      { type = "unlock-recipe", recipe = "compression-pipe-casing" },          
      { type = "unlock-recipe", recipe = "iv-large-electric-compressor" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---MAGNETIC FLUX EXHIBITER
  {
    type = "technology",
    name = "magnetic-flux-exhibiter",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "magnetic-flux-exhibiter-controller" },
      { type = "unlock-recipe", recipe = "magtech-casing" },
      { type = "unlock-recipe", recipe = "magnetic-neodymium-frame" },
      { type = "unlock-recipe", recipe = "electromagnet-housing" },          
      { type = "unlock-recipe", recipe = "iron-electromagnet" },          
      { type = "unlock-recipe", recipe = "iv-magnetic-flux-exhibiter" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL ELECTROLYZER
  {
    type = "technology",
    name = "industrial-electrolyzer",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "potin-dust" },
      { type = "unlock-recipe", recipe = "potin-ingot" },
      { type = "unlock-recipe", recipe = "potin-rod" },
      { type = "unlock-recipe", recipe = "long-potin-rod" },
      { type = "unlock-recipe", recipe = "long-chromium-rod" },
      { type = "unlock-recipe", recipe = "potin-frame" },
      { type = "unlock-recipe", recipe = "molten-stellite" },
      { type = "unlock-recipe", recipe = "solidify-stellite-ingot" },
      { type = "unlock-recipe", recipe = "stellite-plate" },
      { type = "unlock-recipe", recipe = "stellite-rotor" },
      { type = "unlock-recipe", recipe = "industrial-electrolyzer-controller" },
      { type = "unlock-recipe", recipe = "electrolyzer-casing" },       
      { type = "unlock-recipe", recipe = "iv-industrial-electrolyzer" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL PRECISION LATHE
  {
    type = "technology",
    name = "industrial-precision-lathe",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "platinum-plate" },
      { type = "unlock-recipe", recipe = "platinum-frame" },
      { type = "unlock-recipe", recipe = "platinum-item-pipe-casing" },
      { type = "unlock-recipe", recipe = "grate-machine-casing" },
      { type = "unlock-recipe", recipe = "industrial-precision-lathe-controller" },
      { type = "unlock-recipe", recipe = "iv-industrial-precision-lathe" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---LARGE EXTRACTOR
  {
    type = "technology",
    name = "large-extractor",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "black-steel-rod" },
      { type = "unlock-recipe", recipe = "black-steel-frame" },
      { type = "unlock-recipe", recipe = "iv-solenoid-superconductor-coil" },
      { type = "unlock-recipe", recipe = "large-extractor-controller" },
      { type = "unlock-recipe", recipe = "robust-tungstensteel-machine-casing" },       
      { type = "unlock-recipe", recipe = "iv-large-extractor" },       
    },
	prerequisites = { "iv-energy-hatches" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---INDUSTRIAL CUTTING FACTORY
  {
    type = "technology",
    name = "industrial-cutting-factory",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "molten-maraging-steel-300" },
      { type = "unlock-recipe", recipe = "solidify-maraging-steel-300-ingot" },
      { type = "unlock-recipe", recipe = "maraging-steel-300-plate" },
      { type = "unlock-recipe", recipe = "molten-talonite" },
      { type = "unlock-recipe", recipe = "solidify-talonite-ingot" },
      { type = "unlock-recipe", recipe = "talonite-rod" },
      { type = "unlock-recipe", recipe = "talonite-frame" },
      { type = "unlock-recipe", recipe = "industrial-cutting-factory-controller" },
      { type = "unlock-recipe", recipe = "cutting-factory-frame" },       
      { type = "unlock-recipe", recipe = "iv-industrial-cutting-factory" },       
    },
	prerequisites = { "industrial-electrolyzer" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---CHEMICAL BATH PLANT
  {
    type = "technology",
    name = "chemical-bath-plant",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "talonite-plate" },
      { type = "unlock-recipe", recipe = "molten-grisium" },
      { type = "unlock-recipe", recipe = "solidify-grisium-ingot" },
      { type = "unlock-recipe", recipe = "grisium-plate" },
      { type = "unlock-recipe", recipe = "grisium-rod" },
      { type = "unlock-recipe", recipe = "grisium-frame" },
      { type = "unlock-recipe", recipe = "chemical-bath-plant-controller" },
      { type = "unlock-recipe", recipe = "bath-plant-casing" },       
      { type = "unlock-recipe", recipe = "iv-chemical-bath-plant" },       
    },
	prerequisites = { "industrial-cutting-factory" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },
  
  

---FLUID SHAPER
  {
    type = "technology",
    name = "fluid-shaper",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {   
      { type = "unlock-recipe", recipe = "molten-inconel-625" },
      { type = "unlock-recipe", recipe = "molten-watertight-steel" },
      { type = "unlock-recipe", recipe = "solidify-watertight-steel-ingot" },
      { type = "unlock-recipe", recipe = "watertight-steel-rod" },
      { type = "unlock-recipe", recipe = "watertight-steel-frame" },
      { type = "unlock-recipe", recipe = "fluid-shaper-controller" },
      { type = "unlock-recipe", recipe = "solidifier-casing" },
      { type = "unlock-recipe", recipe = "solidifier-radiator" },
      { type = "unlock-recipe", recipe = "solidifier-hatch" },          
      { type = "unlock-recipe", recipe = "iv-fluid-shaper" },       
    },
	prerequisites = { "chemical-bath-plant", "industrial-centrifuge" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },    



---QUBIT CPUS
  {
    type = "technology",
    name = "qubit-cpus",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "indium-gallium-phosphide" },  
      { type = "unlock-recipe", recipe = "qubit-cpu-wafer" },  
      { type = "unlock-recipe", recipe = "qubit-cpu-chip" },  
    },
	prerequisites = { "indium" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },



---RURIDIT
  {
    type = "technology",
    name = "ruridit",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-ruridit" },   
      { type = "unlock-recipe", recipe = "solidify-ruridit-ingot" },   
      { type = "unlock-recipe", recipe = "fine-ruridit-wire" },   
    },
	prerequisites = { "indium" },
	unit =
	{
      count = 800,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02}, {"utility-science-pack", SP01} },
      time = 60
	}
  },  
  
  --[[




---YTTRIUM BARIUM CUPRATE
  {
    type = "technology",
    name = "yttrium-barium-cuprate",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "yttrium-barium-cuprate-dust" },  
      { type = "unlock-recipe", recipe = "hot-yttrium-barium-cuprate-ingot" },  
      { type = "unlock-recipe", recipe = "yttrium-barium-cuprate-ingot" },  
      { type = "unlock-recipe", recipe = "yttrium-barium-cuprate-wire" },  
      { type = "unlock-recipe", recipe = "yttrium-barium-cuprate-cable" },  
    },
	prerequisites = { "indium" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },
  


---VANADIUM GALLIUM
  {
    type = "technology",
    name = "vanadium-gallium",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "molten-vanadium-gallium" },          
      { type = "unlock-recipe", recipe = "solidify-vanadium-gallium-ingot" },          
      { type = "unlock-recipe", recipe = "vanadium-gallium-wire" },          
      { type = "unlock-recipe", recipe = "vanadium-gallium-cable" },          
      { type = "unlock-recipe", recipe = "vanadium-gallium-foil" },          
    },
	prerequisites = { "alloy-blast-smelter" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },  



---LUV COMPONENTS
  {
    type = "technology",
    name = "luv-components",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
      { type = "unlock-recipe", recipe = "molten-indalloy-140" },
      { type = "unlock-recipe", recipe = "niobium-titanium-cable" },
     { type = "unlock-recipe", recipe = "luv-motor" },
      { type = "unlock-recipe", recipe = "luv-piston" },
	  { type = "unlock-recipe", recipe = "luv-pump" },
	  { type = "unlock-recipe", recipe = "luv-conveyor-module" },
	  { type = "unlock-recipe", recipe = "luv-robot-arm" },
	  { type = "unlock-recipe", recipe = "luv-sensor" },
	  { type = "unlock-recipe", recipe = "luv-emitter" },
	  { type = "unlock-recipe", recipe = "luv-machine-casing" },
	  { type = "unlock-recipe", recipe = "luv-machine-hull" },
    },
	prerequisites = { "yttrium-barium-cuprate", "ruridit", "hsss" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP05}, {"logistic-science-pack", SP04}, {"military-science-pack", SP03}, {"chemical-science-pack", SP02}, {"production-science-pack", SP01} },
      time = 10
	}
  },
  


---QUBIT CPUS
  {
    type = "technology",
    name = "qubit-cpus",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "indium-gallium-phosphide" },  
      { type = "unlock-recipe", recipe = "qubit-cpu-wafer" },  
      { type = "unlock-recipe", recipe = "qubit-cpu-chip" },  
    },
	prerequisites = { "indium-production" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },
  
]]--
  
---LUV SCIENCE PACK
  {
    type = "technology",
    name = "space-science-pack",
    icon = "__base__/graphics/technology/space-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "utility-science-pack" },
	unit =
	{
      count = 1000,
      ingredients = { {"automation-science-pack", SP06}, {"logistic-science-pack", SP05}, {"military-science-pack", SP04}, {"chemical-science-pack", SP03}, {"production-science-pack", SP02},
		{"utility-science-pack", SP01} },
      time = 90
	}
  },
 

---ZPM SCIENCE PACK
  {
    type = "technology",
    name = "metallurgic-science-pack",
    icon = "__space-age__/graphics/technology/metallurgic-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "space-science-pack" },
	unit =
	{
      count = 1200,
      ingredients = { {"automation-science-pack", SP07}, {"logistic-science-pack", SP06}, {"military-science-pack", SP05}, {"chemical-science-pack", SP04}, {"production-science-pack", SP03},
		{"utility-science-pack", SP02}, {"space-science-pack", SP01} },
      time = 120
	}
  },
  
  
  
---UV SCIENCE PACK
  {
    type = "technology",
    name = "agricultural-science-pack",
    icon = "__space-age__/graphics/technology/agricultural-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "metallurgic-science-pack" },
	unit =
	{
      count = 1400,
      ingredients = { {"automation-science-pack", SP08}, {"logistic-science-pack", SP07}, {"military-science-pack", SP06}, {"chemical-science-pack", SP05}, {"production-science-pack", SP04},
		{"utility-science-pack", SP03}, {"space-science-pack", SP02}, {"metallurgic-science-pack", SP01} },
      time = 240
	}
  },
  


---UHV SCIENCE PACK
  {
    type = "technology",
    name = "electromagnetic-science-pack",
    icon = "__space-age__/graphics/technology/electromagnetic-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "agricultural-science-pack" },
	unit =
	{
      count = 1600,
      ingredients = { {"automation-science-pack", SP09}, {"logistic-science-pack", SP08}, {"military-science-pack", SP07}, {"chemical-science-pack", SP06}, {"production-science-pack", SP05},
		{"utility-science-pack", SP04}, {"space-science-pack", SP03}, {"metallurgic-science-pack", SP02}, {"agricultural-science-pack", SP01} },
      time = 360
	}
  },
  


---UEV SCIENCE PACK
  {
    type = "technology",
    name = "cryogenic-science-pack",
    icon = "__space-age__/graphics/technology/cryogenic-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "electromagnetic-science-pack" },
	unit =
	{
      count = 1800,
      ingredients = { {"automation-science-pack", SP10}, {"logistic-science-pack", SP09}, {"military-science-pack", SP08}, {"chemical-science-pack", SP07}, {"production-science-pack", SP06},
		{"utility-science-pack", SP05}, {"space-science-pack", SP04}, {"metallurgic-science-pack", SP03}, {"agricultural-science-pack", SP02}, {"electromagnetic-science-pack", SP01} },
      time = 540
	}
  },



---UIV SCIENCE PACK
  {
    type = "technology",
    name = "promethium-science-pack",
    icon = "__space-age__/graphics/technology/promethium-science-pack.png",
    icon_size = 256,
    effects = {  
    },
	prerequisites = { "cryogenic-science-pack" },
	unit =
	{
      count = 2000,
      ingredients = { {"automation-science-pack", SP11}, {"logistic-science-pack", SP10}, {"military-science-pack", SP09}, {"chemical-science-pack", SP08}, {"production-science-pack", SP07},
		{"utility-science-pack", SP06}, {"space-science-pack", SP05}, {"metallurgic-science-pack", SP04}, {"agricultural-science-pack", SP03}, {"electromagnetic-science-pack", SP02},
		{"cryogenic-science-pack", SP01} },
      time = 720
	}
  },
  
  

---UMV SCIENCE PACK
  {
    type = "technology",
    name = "umv-science-pack",
    icon = "__gregtorio-continued__/graphics/technology/umv-science-pack.png",
    icon_size = 256,
    effects = {  
		{ type = "unlock-recipe", recipe = "umv-science-pack" },    
    },
	prerequisites = { "promethium-science-pack" },
	unit =
	{
      count = 2300,
      ingredients = { {"automation-science-pack", SP12}, {"logistic-science-pack", SP11}, {"military-science-pack", SP10}, {"chemical-science-pack", SP09}, {"production-science-pack", SP08},
		{"utility-science-pack", SP07}, {"space-science-pack", SP06}, {"metallurgic-science-pack", SP05}, {"agricultural-science-pack", SP04}, {"electromagnetic-science-pack", SP03},
		{"cryogenic-science-pack", SP02}, {"promethium-science-pack", SP01} },
      time = 880
	}
  },
  
  

---UXV SCIENCE PACK
  {
    type = "technology",
    name = "uxv-science-pack",
    icon = "__gregtorio-continued__/graphics/technology/uxv-science-pack.png",
    icon_size = 256,
    effects = {  
		{ type = "unlock-recipe", recipe = "uxv-science-pack" },    
    },
	prerequisites = { "umv-science-pack" },
	unit =
	{
      count = 2600,
      ingredients = { {"automation-science-pack", SP13}, {"logistic-science-pack", SP12}, {"military-science-pack", SP11}, {"chemical-science-pack", SP10}, {"production-science-pack", SP09},
		{"utility-science-pack", SP08}, {"space-science-pack", SP07}, {"metallurgic-science-pack", SP06}, {"agricultural-science-pack", SP05}, {"electromagnetic-science-pack", SP04},
		{"cryogenic-science-pack", SP03}, {"promethium-science-pack", SP02}, {"umv-science-pack", SP01} },
      time = 1040
	}
  },
  
  
--[[
---UXV COMPONENTS
  {
    type = "technology",
    name = "uxv-components",
    icon = "__gregtorio-continued__/graphics/technology/uxv-components.png",
    icon_size = 256,
    effects = {  
		{ type = "unlock-recipe", recipe = "uxv-motor" },    
		{ type = "unlock-recipe", recipe = "uxv-piston" },    
		{ type = "unlock-recipe", recipe = "uxv-pump" },    
		{ type = "unlock-recipe", recipe = "uxv-conveyor-module" },    
		{ type = "unlock-recipe", recipe = "uxv-robot-arm" },    
		{ type = "unlock-recipe", recipe = "uxv-sensor" },    
		{ type = "unlock-recipe", recipe = "uxv-emitter" },    
		{ type = "unlock-recipe", recipe = "uxv-field-generator" },    
    },
	prerequisites = { "uxv-science-pack" },
	unit =
	{
      count = 2600,
      ingredients = { {"automation-science-pack", SP14}, {"logistic-science-pack", SP13}, {"military-science-pack", SP12}, {"chemical-science-pack", SP11}, {"production-science-pack", SP10},
		{"utility-science-pack", SP09}, {"space-science-pack", SP08}, {"metallurgic-science-pack", SP07}, {"agricultural-science-pack", SP06}, {"electromagnetic-science-pack", SP05},
		{"cryogenic-science-pack", SP04}, {"promethium-science-pack", SP03}, {"umv-science-pack", SP02}, {"uxv-science-pack", SP01} },
      time = 960
	}
  },
  ]]--
  
  
---STARGATE
  {
    type = "technology",
    name = "stargate",
    icon = "__gregtorio-continued__/graphics/technology/stargate.png",
    icon_size = 256,
    effects = {  
		{ type = "unlock-recipe", recipe = "stargate-ring-block" },    
		{ type = "unlock-recipe", recipe = "stargate-chevron-block" },    
		{ type = "unlock-recipe", recipe = "stargate-base" },    
		{ type = "unlock-recipe", recipe = "stargate-power-unit" },    
		{ type = "unlock-recipe", recipe = "stargate-controller" },    
		{ type = "unlock-recipe", recipe = "stargate-chevron-upgrade" },    
		{ type = "unlock-recipe", recipe = "stargate-iris-upgrade" },    
		{ type = "unlock-recipe", recipe = "stargate" },  
		{ type = "unlock-recipe", recipe = "max-science-pack" },		
    },
	prerequisites = { "uxv-science-pack" },
	unit =
	{
      count = 3000,
      ingredients = { {"automation-science-pack", SP14}, {"logistic-science-pack", SP13}, {"military-science-pack", SP12}, {"chemical-science-pack", SP11}, {"production-science-pack", SP10},
		{"utility-science-pack", SP09}, {"space-science-pack", SP08}, {"metallurgic-science-pack", SP07}, {"agricultural-science-pack", SP06}, {"electromagnetic-science-pack", SP05},
		{"cryogenic-science-pack", SP04}, {"promethium-science-pack", SP03}, {"umv-science-pack", SP02}, {"uxv-science-pack", SP01} },
      time = 1200
	}
  },  


---VICTORY
	{
		type = "technology",
		name = "victory",
		icon = "__gregtorio-continued__/graphics/technology/max-science-pack.png",
		icon_size = 256,
		effects = {},
		prerequisites = { "stargate" },
		unit =
		{
			count_formula = "1000 * 2^(L-1)",
			ingredients = { {"automation-science-pack", SP15}, {"logistic-science-pack", SP14}, {"military-science-pack", SP13}, {"chemical-science-pack", SP12}, {"production-science-pack", SP11},
				{"utility-science-pack", SP10}, {"space-science-pack", SP09}, {"metallurgic-science-pack", SP08}, {"agricultural-science-pack", SP07}, {"electromagnetic-science-pack", SP06},
				{"cryogenic-science-pack", SP05}, {"promethium-science-pack", SP04}, {"umv-science-pack", SP03}, {"uxv-science-pack", SP02}, {"max-science-pack", SP01} },
			time = 1200
		},
		max_level = "infinite",
		upgrade = true,
		order = "z-a"
	}
--[[

---QUANTUM PROCESSORS
  {
    type = "technology",
    name = "quantum-processors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "annealed-copper-foil" },  
      { type = "unlock-recipe", recipe = "fiber-reinforced-epoxy-sheet" },  
      { type = "unlock-recipe", recipe = "fiber-reinforced-circuit-board" },  
      { type = "unlock-recipe", recipe = "fiber-reinforced-printed-circuit-board" },   
      { type = "unlock-recipe", recipe = "quantum-processor" },  
      { type = "unlock-recipe", recipe = "quantum-processor-assembly" },  
      { type = "unlock-recipe", recipe = "quantum-processor-supercomputer" },  
    },
	prerequisites = { "qubit-cpus", "advanced-smds", "nanoprocessors" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },
  
  

---QUANTUM PROCESSOR MAINFRAMES
  {
    type = "technology",
    name = "quantum-processor-mainframes",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "hssg-frame" },  
      { type = "unlock-recipe", recipe = "quantum-processor-mainframe" },   
    },
	prerequisites = { "nanoprocessors" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },  
  


---CRYSTAL PROCESSORS
  {
    type = "technology",
    name = "crystal-processors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "crystal-processor" },  
      { type = "unlock-recipe", recipe = "crystal-processor-assembly" },  
      { type = "unlock-recipe", recipe = "crystal-processor-supercomputer" },  
      { type = "unlock-recipe", recipe = "crystal-processor-mainframe" },   
    },
	prerequisites = { "quantum-processors" },
	unit =
	{
      count = 10,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },



---WETWARE PROCESSORS
  {
    type = "technology",
    name = "wetware-processors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "wetware-processor" },  
      { type = "unlock-recipe", recipe = "wetware-processor-assembly" },  
      { type = "unlock-recipe", recipe = "wetware-processor-supercomputer" },  
      { type = "unlock-recipe", recipe = "wetware-processor-mainframe" },   
    },
	prerequisites = { "crystal-processors" },
	unit =
	{
      count = 10,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },



---MATTER PROCESSORS
  {
    type = "technology",
    name = "matter-processors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "matter-processor" },  
      { type = "unlock-recipe", recipe = "matter-processor-assembly" },  
      { type = "unlock-recipe", recipe = "matter-processor-supercomputer" },  
      { type = "unlock-recipe", recipe = "matter-processor-mainframe" },   
    },
	prerequisites = { "wetware-processors" },
	unit =
	{
      count = 10,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },



---DIMENSIONAL PROCESSORS
  {
    type = "technology",
    name = "dimensional-processors",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = { 
      { type = "unlock-recipe", recipe = "dimensional-processor" },  
      { type = "unlock-recipe", recipe = "dimensional-processor-assembly" },  
      { type = "unlock-recipe", recipe = "dimensional-processor-supercomputer" },  
      { type = "unlock-recipe", recipe = "dimensional-processor-mainframe" },   
    },
	prerequisites = { "matter-processors" },
	unit =
	{
      count = 10,
      ingredients = {{"automation-science-pack", SP01}},
      time = 10
	}
  },   
 
  
--[[  
  
---THORIUM FUEL CYCLE
  {
    type = "technology",
    name = "thorium-fuel-cycle",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "empty-fuel-rod" }, 
	  { type = "unlock-recipe", recipe = "thorium-fuel-rod" }, 
	  { type = "unlock-recipe", recipe = "depleted-thorium-fuel-rod-centrifuging" }, 
	},
	prerequisites = { "nuclear-reactor" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },   
  
  
  
---URANIUM FUEL CYCLE
  {
    type = "technology",
    name = "uranium-fuel-cycle",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "uranium-hexafluoride" }, 
	  { type = "unlock-recipe", recipe = "uranium-enrichment" }, 
	  { type = "unlock-recipe", recipe = "depleted-uranium-hexafluoride-electrolysis" }, 
	  { type = "unlock-recipe", recipe = "enriched-uranium-hexafluoride-electrolysis" }, 
	  { type = "unlock-recipe", recipe = "uranium-fuel-rod" }, 
	  { type = "unlock-recipe", recipe = "depleted-uranium-fuel-rod-centrifuging" }, 
	},
	prerequisites = { "thorium-fuel-cycle" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },  
  
  
  
---PLUTONIUM FUEL CYCLE
  {
    type = "technology",
    name = "plutonium-fuel-cycle",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "plutonium-enrichment" }, 
	  { type = "unlock-recipe", recipe = "plutonium-fuel-rod" }, 
	  { type = "unlock-recipe", recipe = "depleted-plutonium-fuel-rod-centrifuging" }, 
	},
	prerequisites = { "uranium-fuel-cycle" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },
  
  
  
---AMERICIUM FUEL CYCLE
  {
    type = "technology",
    name = "americium-fuel-cycle",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "americium-enrichment" }, 
	  { type = "unlock-recipe", recipe = "americium-fuel-rod" }, 
	  { type = "unlock-recipe", recipe = "depleted-americium-fuel-rod-centrifuging" }, 
	},
	prerequisites = { "plutonium-fuel-cycle" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },
  
  
  
  
---IMAGINARY TIME STABILIZATION
  {
    type = "technology",
    name = "imaginary-time-stabilization",
    icon = "__gregtorio-continued__/graphics/technology/nyi.png",
    icon_size = 256,
    effects = {
	  { type = "unlock-recipe", recipe = "stabilized-protactinium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-neptunium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-curium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-berkelium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-californium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-actinium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-francium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-radium" }, 
	  { type = "unlock-recipe", recipe = "stabilized-radon" }, 
	},
	prerequisites = { "americium-fuel-cycle" },
	unit =
	{
      count = 10,
      ingredients = { {"automation-science-pack", SP03}, {"logistic-science-pack", SP02}, {"military-science-pack", SP01} },
      time = 10
	}
  },

]]--
  
  
})
