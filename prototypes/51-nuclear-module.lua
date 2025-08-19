--- LV 1	MV 2	HV 4	EV 8	IV 16	LUV 32	ZPM 64	UV 128	UHV 256	UEV	512	UIV 1024	UXV 2048	OPV 4096


data:extend({     
 
 
   
   ---THORIUM FUEL ROD
 	{
		type = "item",
		name = "thorium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/thorium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		fuel_category = "nuclear-fuel-rod",
		fuel_value = "1.5MJ",
		burnt_result = "depleted-thorium-fuel-rod",
		spoil_ticks = 648000, -- 180 minutes
		spoil_result = "depleted-thorium-fuel-rod"
	},    
   	{
		type = "recipe",
		name = "thorium-fuel-rod",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = 24,
		ingredients = {
			{ type = "item", name = "empty-fuel-rod", amount = 1 },
			{ type = "item", name = "thorium-dust", amount = 10 },
		},
		results = {
			{ type = "item", name = "thorium-fuel-rod", amount = 1 },
		}
   },
   
   
   
   ---DEPLETED THORIUM FUEL ROD
 	{
		type = "item",
		name = "depleted-thorium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/depleted-thorium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		spoil_ticks = 540000, -- 150 minutes
    spoil_result = "unstable-protactinium"
	},



   ---DEPLETED THORIUM FUEL ROD CENRIFUGING 
   	{
		type = "recipe",
		name = "depleted-thorium-fuel-rod-centrifuging",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 240,
		ingredients = {
			{ type = "item", name = "depleted-thorium-fuel-rod", amount = 1 },
		},
		results = {
			{ type = "item", name = "uranium", amount = 1 },
			{ type = "item", name = "unstable-protactinium", amount = 1 },
			{ type = "item", name = "unstable-neptunium", amount = 3 },
		},
		main_product = "uranium"
   },    
   
   
   
 ---PROTACTINIUM   
	{
	  type = "item",
	  name = "unstable-protactinium",
	  icon = "__Gregtorio__/graphics/icons/unstable-protactinium.png",
	  icon_size = 32,
	  subgroup = "intermediate-product",
	  order = "g[neptunium]-a[base]",
	  stack_size = 64,
	  spoil_ticks = 600, -- 10 seconds
	  spoil_result = "enriched-uranium"
	},
	{
		type = "item",
		name = "stabilized-protactinium",
		icon = "__Gregtorio__/graphics/icons/stabilized-protactinium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[neptunium]-a[base]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-protactinium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "item", name = "unstable-protactinium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-protactinium", amount = 1 },
		}
   },


   
---NEPTUNIUM   
	{
		type = "item",
		name = "unstable-neptunium",
		icon = "__Gregtorio__/graphics/icons/unstable-neptunium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[neptunium]-a[base]",
		stack_size = 64,
		spoil_ticks = 1800, -- 30 seconds
    spoil_result = "plutonium"
	},
	{
		type = "item",
		name = "stabilized-neptunium",
		icon = "__Gregtorio__/graphics/icons/stabilized-neptunium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[neptunium]-a[base]",
		stack_size = 64
	}, 
   	{
		type = "recipe",
		name = "stabilized-neptunium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 60,
		ingredients = {
			{ type = "item", name = "unstable-neptunium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-neptunium", amount = 1 },
		}
   }, 


---DEPLETED URANIUM FUEL ROD
 	{
		type = "item",
		name = "depleted-uranium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/depleted-uranium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		spoil_ticks = 1080000, -- 300 minutes
    spoil_result = "unstable-neptunium"
	},    
	


   ---DEPLETED URANIUM FUEL ROD CENRIFUGING 
   	{
		type = "recipe",
		name = "depleted-uranium-fuel-rod-centrifuging",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 480,
		ingredients = {
			{ type = "item", name = "depleted-uranium-fuel-rod", amount = 1 },
		},
		results = {
			{ type = "item", name = "unstable-neptunium", amount = 3 },
			{ type = "item", name = "plutonium", amount = 1 },
			{ type = "item", name = "americium", amount = 1 },
		},
		main_product = "unstable-neptunium"
   },
   
   
   
---PLUTONIUM  
	{
		type = "item",
		name = "plutonium",
		icon = "__Gregtorio__/graphics/icons/plutonium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[neptunium]-a[base]",
		stack_size = 64,
	},
	{
		type = "item",
		name = "enriched-plutonium",
		icon = "__Gregtorio__/graphics/icons/enriched-plutonium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[neptunium]-a[base]",
		stack_size = 64,
	},
	
	
	
  ---PLUTONIUM ENRICHMENT
   	{
		type = "recipe",
		name = "plutonium-enrichment",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 800,
		ingredients = {
			{ type = "item", name = "plutonium", amount = 4 },
		},
		results = {
			{ type = "item", name = "enriched-plutonium", amount = 1 },
		}
   },
   
   
   
   ---PLUTONIUM FUEL ROD
 	{
		type = "item",
		name = "plutonium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/plutonium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		fuel_category = "nuclear-fuel-rod",
		fuel_value = "6MJ",
		burnt_result = "depleted-plutonium-fuel-rod",
		spoil_ticks = 864000, -- 240 minutes
    spoil_result = "depleted-plutonium-fuel-rod"
	},    
   	{
		type = "recipe",
		name = "plutonium-fuel-rod",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = 96,
		ingredients = {
			{ type = "item", name = "empty-fuel-rod", amount = 1 },
			{ type = "item", name = "plutonium", amount = 7 },
			{ type = "item", name = "enriched-plutonium", amount = 3 },
		},
		results = {
			{ type = "item", name = "plutonium-fuel-rod", amount = 1 },
		}
   },   
   
   
   
   ---DEPLETED PLUTONIUM FUEL ROD
 	{
		type = "item",
		name = "depleted-plutonium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/depleted-plutonium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		spoil_ticks = 756000, -- 210 minutes
    spoil_result = "unstable-curium"
	},    



   ---DEPLETED PLUTONIUM FUEL ROD CENRIFUGING 
   	{
		type = "recipe",
		name = "depleted-plutonium-fuel-rod-centrifuging",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 960,
		ingredients = {
			{ type = "item", name = "depleted-plutonium-fuel-rod", amount = 1 },
		},
		results = {
			{ type = "item", name = "plutonium", amount = 1 },
			{ type = "item", name = "americium", amount = 2 },
			{ type = "item", name = "enriched-americium", amount = 1 },
			{ type = "item", name = "unstable-curium", amount = 1 },
		},
		main_product = "americium"
   },
   
   
   
---CURIUM   
	{
		type = "item",
		name = "unstable-curium",
		icon = "__Gregtorio__/graphics/icons/unstable-curium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[curium]-a[base]",
		stack_size = 64,
		spoil_ticks = 72000, -- 20 minutes
    spoil_result = "plutonium"
	},
	{
		type = "item",
		name = "stabilized-curium",
		icon = "__Gregtorio__/graphics/icons/stabilized-curium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "g[curium]-a[base]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-curium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 240,
		ingredients = {
			{ type = "item", name = "unstable-curium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-curium", amount = 1 },
		}
   },
   
   
 
  ---AMERICIUM ENRICHMENT
 	{
		type = "item",
		name = "americium",
		icon = "__Gregtorio__/graphics/icons/americium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
	},    
 	{
		type = "item",
		name = "enriched-americium",
		icon = "__Gregtorio__/graphics/icons/enriched-americium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
	},   
   	{
		type = "recipe",
		name = "americium-enrichment",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 1600,
		ingredients = {
			{ type = "item", name = "americium", amount = 4 },
		},
		results = {
			{ type = "item", name = "enriched-americium", amount = 1 },
		}
   },
  
   
   
   ---AMERICIUM FUEL ROD
 	{
		type = "item",
		name = "americium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/americium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		fuel_category = "nuclear-fuel-rod",
		fuel_value = "12MJ",
		burnt_result = "depleted-americium-fuel-rod",
		stack_size = 64,
		spoil_ticks = 432000, -- 120 minutes
		spoil_result = "depleted-americium-fuel-rod"
	},    
   	{
		type = "recipe",
		name = "americium-fuel-rod",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = 192,
		ingredients = {
			{ type = "item", name = "empty-fuel-rod", amount = 1 },
			{ type = "item", name = "americium", amount = 7 },
			{ type = "item", name = "enriched-americium", amount = 3 },
		},
		results = {
			{ type = "item", name = "americium-fuel-rod", amount = 1 },
		}
   },
   
   
   
    ---DEPLETED AMERICIUM FUEL ROD
 	{
		type = "item",
		name = "depleted-americium-fuel-rod",
		icon = "__Gregtorio__/graphics/icons/depleted-americium-fuel-rod.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "a[manual-labor]",
		stack_size = 64,
		spoil_ticks = 324000, -- 90 minutes
		spoil_result = "unstable-curium"
	},    
   


   ---DEPLETED AMERICIUM FUEL ROD CENRIFUGING 
   	{
		type = "recipe",
		name = "depleted-americium-fuel-rod-centrifuging",
		category = "lv-centrifuge-recipes",
		enabled = false,
		energy_required = 1920,
		ingredients = {
			{ type = "item", name = "depleted-americium-fuel-rod", amount = 1 },
		},
		results = {
			{ type = "item", name = "unstable-curium", amount = 4 },
			{ type = "item", name = "unstable-berkelium", amount = 1 },
		},
		main_product = "unstable-berkelium"
   }, 
    
  
  
-- UNSTABLE BERKELIUM
	{
		type = "item",
		name = "unstable-berkelium",
		icon = "__Gregtorio__/graphics/icons/unstable-berkelium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-berkelium]",
		stack_size = 64,
		spoil_ticks = 72000, -- 20 minutes
    spoil_result = "unstable-californium"
	},
	{
		type = "item",
		name = "stabilized-berkelium",
		icon = "__Gregtorio__/graphics/icons/stabilized-berkelium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-berkelium]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-berkelium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 480,
		ingredients = {
			{ type = "item", name = "unstable-berkelium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-berkelium", amount = 1 },
		}
   },



-- UNSTABLE CALIFORNIUM
	{
		type = "item",
		name = "unstable-californium",
		icon = "__Gregtorio__/graphics/icons/unstable-californium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-californium]",
		stack_size = 64,
		spoil_ticks = 36000, -- 10 minutes
		spoil_result = "unstable-californium-decay-intermediates"
	},
	{
		type = "item",
		name = "stabilized-californium",
		icon = "__Gregtorio__/graphics/icons/stabilized-californium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-californium]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-californium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 960,
		ingredients = {
			{ type = "item", name = "unstable-californium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-californium", amount = 1 },
		}
   },



-- UNSTABLE CALIFORNIUM DECAY INTERMEDIATES
	{
		type = "item",
		name = "unstable-californium-decay-intermediates",
		icon = "__Gregtorio__/graphics/icons/unstable-californium-decay-intermediates.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-californium-decay-intermediates]",
		stack_size = 64,
		spoil_ticks = 108000, -- 30 minutes
		spoil_result = "unstable-actinium"
	},

	
	
---	UNSTABLE ACTINIUM	
	{
		type = "item",
		name = "unstable-actinium",
		icon = "__Gregtorio__/graphics/icons/unstable-actinium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-actinium]",
		stack_size = 64,
		spoil_ticks = 3600, -- 1 minutes
		spoil_result = "unstable-francium"
	},
   	{
		type = "item",
		name = "stabilized-actinium",
		icon = "__Gregtorio__/graphics/icons/stabilized-actinium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-actinium]",
		stack_size = 64,
	},
	{
		type = "recipe",
		name = "stabilized-actinium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 1920,
		ingredients = {
			{ type = "item", name = "unstable-actinium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-actinium", amount = 1 },
		}
   },



--- UNSTABLE FRANCIUM
	{
		type = "item",
		name = "unstable-francium",
		icon = "__Gregtorio__/graphics/icons/unstable-francium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-francium]",
		stack_size = 64,
		spoil_ticks = 600, -- 10 seconds
		spoil_result = "unstable-radium"
	},
	{
		type = "item",
		name = "stabilized-francium",
		icon = "__Gregtorio__/graphics/icons/stabilized-francium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-francium]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-francium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 480,
		ingredients = {
			{ type = "item", name = "unstable-francium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-francium", amount = 1 },
		}
   },	
	
	
	
--- UNSTABLE RADIUM	
	{
		type = "item",
		name = "unstable-radium",
		icon = "__Gregtorio__/graphics/icons/unstable-radium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-radium]",
		stack_size = 64,
		spoil_ticks = 3600, -- 1 minutes
		spoil_result = "unstable-radon"
	},
	{
		type = "item",
		name = "stabilized-radium",
		icon = "__Gregtorio__/graphics/icons/stabilized-radium.png",
		icon_size = 32,
		subgroup = "intermediate-product",
		order = "z[unstable-radium]",
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "stabilized-radium",
		category = "lv-chemical-bath-recipes",
		enabled = false,
		energy_required = 240,
		ingredients = {
			{ type = "item", name = "unstable-radium", amount = 1 },
			{ type = "fluid", name = "imaginary-time", amount = 100 },
		},
		results = {
			{ type = "item", name = "stabilized-radium", amount = 1 },
		}
   },

})
















--[[

   --- REACTOR FUEL PROCESSING PLANT
	{
		type = "item",
		name = "reactor-fuel-processing-plant-controller",
		icon = "__Gregtorio__/graphics/icons/reactor-fuel-processing-plant-controller.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "reactor-fuel-processing-plant-controller",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = IV_SPEED * 4,
		ingredients = {
			{ type = "item", name = "tungstensteel-plate", amount = 18 },
			{ type = "item", name = "iv-circuit", amount = 2 },
			{ type = "item", name = "gregtech-computer-cube", amount = 1 },
			{ type = "item", name = "large-stellite-gear", amount = 2 },
			{ type = "item", name = "iv-machine-hull", amount = 1 },
		},
		results = {
			{ type = "item", name = "reactor-fuel-processing-plant-controller", amount = 1 },
		}
   },
	{
		type = "item",
		name = "reactor-fuel-processing-plant",
		icon = "__Gregtorio__/graphics/icons/reactor-fuel-processing-plant.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "reactor-fuel-processing-plant",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = IV_SPEED * 4,
		ingredients = {
			{ type = "item", name = "reactor-fuel-processing-plant-controller", amount = 1 },
			{ type = "item", name = "hastelloy-x-structural-block", amount = 11 },
			{ type = "item", name = "hastelloy-n-sealant-block", amount = 17 },
			{ type = "item", name = "incoloy-ds-fluid-containment-block", amount = 5 },
			{ type = "item", name = "zeron-100-reactor-shielding", amount = 4 },
			{ type = "item", name = "lv-machine-hull", amount = 5 },
			{ type = "item", name = "iv-energy-hatch", amount = 1 },
		},
		results = {
			{ type = "item", name = "reactor-fuel-processing-plant", amount = 1 },
		}
   },
	{
		type = "item",
		name = "hastelloy-n-sealant-block",
		icon = "__Gregtorio__/graphics/icons/hastelloy-n-sealant-block.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "hastelloy-n-sealant-block",
		category = "ev-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "hastelloy-n-plate", amount = 4 },
			{ type = "item", name = "incoloy-ma956-plate", amount = 4 },
			{ type = "item", name = "hastelloy-c276-frame", amount = 1 },
		},
		results = {
			{ type = "item", name = "hastelloy-n-sealant-block", amount = 1 },
		}
   },
	{
		type = "item",
		name = "hastelloy-n-sealant-block",
		icon = "__Gregtorio__/graphics/icons/hastelloy-n-sealant-block.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "incoloy-ds-fluid-containment-block",
		category = "ev-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "incoloy-ds-plate", amount = 4 },
			{ type = "item", name = "large-incoloy-ds-gear", amount = 2 },
			{ type = "item", name = "staballoy-plate", amount = 12 },
			{ type = "item", name = "super-tank-v", amount = 1 },
		},
		results = {
			{ type = "item", name = "incoloy-ds-fluid-containment-block", amount = 1 },
		}
   },
	{
		type = "item",
		name = "super-tank-v",
		icon = "__Gregtorio__/graphics/icons/super-tank-v.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "super-tank-v",
		category = "ev-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "iv-tier-circuit", amount = 4 },
			{ type = "item", name = "titanium-plate", amount = 2 },
			{ type = "item", name = "hv-field-generator", amount = 1 },
			{ type = "item", name = "hermetic-casing-v", amount = 1 },
			{ type = "item", name = "ev-pump", amount = 1 },
		},
		results = {
			{ type = "item", name = "super-tank-v", amount = 1 },
		}
   },
	{
		type = "item",
		name = "hermetic-casing-v",
		icon = "__Gregtorio__/graphics/icons/hermetic-casing-v.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "hermetic-casing-v",
		category = "ev-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "tungstensteel-plate", amount = 8 },
			{ type = "item", name = "titanium-plate", amount = 6 },
		},
		results = {
			{ type = "item", name = "hermetic-casing-v", amount = 1 },
		}
   },
   
  
   
---LFTR FUEL 1
   	{
		type = "recipe",
		name = "lftr-fuel-1",
		category = "nuclear-fuel-processing-recipes",
		enabled = false,
		energy_required = 1800 * EV_SPEED,
		ingredients = {
			{ type = "fluid", name = "lithium-fluoride", amount = 55 },
			{ type = "fluid", name = "beryllium-fluoride", amount = 15 },
			{ type = "fluid", name = "zirconium-tetrafluoride", amount = 15 },
			{ type = "fluid", name = "molten-uranium-235", amount = 24 },
		},
		results = {
			{ type = "fluid", name = "lftr-fuel-1", amount = 100 },
		}
   },



---MAKING LITHIUM FLUORIDE   
   	{
		type = "recipe",
		name = "industrial-strength-hydrofluoric-acid",
		category = "mv-distillation-recipes",
		enabled = false,
		energy_required = 45 * MV_SPEED,
		ingredients = {
			{ type = "fluid", name = "sulfuric-apatite-mix", amount = 520 },
		},
		results = {
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 40 },
			{ type = "fluid", name = "sulfurous-acid", amount = 380 },
			{ type = "fluid", name = "industrial-strength-hydrogen-chloride", amount = 100 },
		},
		main_product = "industrial-strength-hydrogen-chloride"
   },
   	{
		type = "recipe",
		name = "industrial-strength-hydrofluoric-acid-duplication",
		category = "hv-chemical-plant-recipes",
		enabled = false,
		energy_required = 30 * HV_SPEED,
		ingredients = {
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 200 },
			{ type = "fluid", name = "hydrofluoric-acid", amount = 500 },
		},
		results = {
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 450 },
		},
		main_product = "industrial-strength-hydrofluoric-acid"
   },
   	{
		type = "recipe",
		name = "lithium-carbonate",
		category = "ev-dehydrator-recipes",
		enabled = false,
		energy_required = 75 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "lepidolite", amount = 20 },
			{ type = "fluid", name = "sulfuric-acid", amount = 1000 },
		},
		results = {
			{ type = "item", name = "lithium-carbonate", amount = 3 },
			{ type = "item", name = "potassium", amount = 1 },
			{ type = "item", name = "aluminium-dust", amount = 4 },
			{ type = "fluid", name = "oxygen", amount = 1000 },
			{ type = "fluid", name = "fluorine", amount = 200 },
			{ type = "fluid", name = "sulfuric-lithium-mix", amount = 1000 },
		},
		main_product = "lithium-carbonate"
   },
	{
		type = "item",
		name = "lithium-7",
		icon = "__Gregtorio__/graphics/icons/lithium-7.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "sulfuric-lithium-mix-dehydration",
		category = "lv-dehydrator-recipes",
		enabled = false,
		energy_required = 30,
		ingredients = {
			{ type = "fluid", name = "sulfuric-lithium-mix", amount = 144 },
		},
		results = {
			{ type = "item", name = "sulfur", amount = 3 },
			{ type = "item", name = "copper", amount = 1 },
			{ type = "item", name = "sodium", amount = 1 },
			{ type = "item", name = "carbon", amount = 1 },
			{ type = "item", name = "lithium-7", amount = 4 },
		}
   },
   	{
		type = "recipe",
		name = "sulfuric-lithium-mix-dehydration",
		category = "lv-dehydrator-recipes",
		enabled = false,
		energy_required = 30,
		ingredients = {
			{ type = "fluid", name = "sulfuric-lithium-mix", amount = 144 },
		},
		results = {
			{ type = "item", name = "sulfur", amount = 3 },
			{ type = "item", name = "copper", amount = 1 },
			{ type = "item", name = "sodium", amount = 1 },
			{ type = "item", name = "carbon", amount = 1 },
			{ type = "item", name = "lithium-7", amount = 4 },
		}
   },
   	{
		type = "recipe",
		name = "lithium-fluoride",
		category = "hv-chemical-bath-recipes",
		enabled = false,
		energy_required = 9 * HV_SPEED,
		ingredients = {
			{ type = "item", name = "lithium-carbonate", amount = 3 },
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 50 },
		},
		results = {
			{ type = "fluid", name = "lithium-fluoride", amount = 14.4 },
		}
   },


---MAKING BERYLLIUM FLUORIDE   
   	{
		type = "recipe",
		name = "ammonia-bifluoride",
		category = "mv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ type = "fluid", name = "ammonia", amount = 100 },
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "ammonia-bifluoride", amount = 57.6 },
		}
   },
   	{
		type = "recipe",
		name = "beryllium-hydroxide",
		category = "lv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 12,
		ingredients = {
			{ type = "fluid", name = "hydrogen", amount = 200 },
			{ type = "fluid", name = "oxygen", amount = 200 },
			{ type = "item", name = "beryllium", amount = 1 },
		},
		results = {
			{ type = "fluid", name = "beryllium-hydroxide", amount = 43.2 },
		}
   },
   	{
		type = "recipe",
		name = "ammonium-tetrafluoroberyllate",
		category = "mv-chemical-reactor-recipes",
		enabled = false,
		energy_required = 300 * MV_SPEED,
		ingredients = {
			{ type = "fluid", name = "beryllium-hydroxide", amount = 43.2 },
			{ type = "fluid", name = "ammonia-bifluoride", amount = 115.2 },
		},
		results = {
			{ type = "fluid", name = "ammonium-tetrafluoroberyllate", amount = 100 },
			{ type = "fluid", name = "water", amount = 200 },
		}
   },
   	{
		type = "recipe",
		name = "beryllium-fluoride",
		category = "mv-dehydration-recipes",
		enabled = false,
		energy_required = 300 * MV_SPEED,
		ingredients = {
			{ type = "fluid", name = "ammonium-tetrafluoroberyllate", amount = 100 },
		},
		results = {
			{ type = "fluid", name = "beryllium-fluoride", amount = 43.2 },
			{ type = "fluid", name = "ammonia", amount = 200 },
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 100 },
		}
   },



---MAKING ZIRCONIUM TETRAFLUORIDE 
	{
		type = "item",
		name = "zirconium-pellet",
		icon = "__Gregtorio__/graphics/icons/zirconium-pellet.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "sulfuric-lithium-mix-dehydration",
		category = "lv-autoclave-recipes",
		enabled = false,
		energy_required = 15,
		ingredients = {
			{ type = "item", name = "zirconium-dust", amount = 1 },
			{ type = "fluid", name = "chlorine", amount = 400 },
		},
		results = {
			{ type = "item", name = "zirconium-pellet", amount = 1 },
		}
   },
	{
		type = "item",
		name = "zirconium-pellet-dust",
		icon = "__Gregtorio__/graphics/icons/zirconium-pellet-dust.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "zirconium-pellet-dust",
		category = "lv-macerator-recipes",
		enabled = false,
		energy_required = 20,
		ingredients = {
			{ type = "item", name = "zirconium-pellet", amount = 1 },
		},
		results = {
			{ type = "item", name = "zirconium-pellet-dust", amount = 5 },
		}
   },
	{
		type = "item",
		name = "cooked-zirconium-pellet-dust",
		icon = "__Gregtorio__/graphics/icons/cooked-zirconium-pellet-dust.png",
		icon_size = 32,
		stack_size = 64,
	},
   	{
		type = "recipe",
		name = "cooked-zirconium-pellet-dust",
		category = "hv-ebf-recipes",
		enabled = false,
		energy_required = HV_SPEED * 60,
		ingredients = {
			{ type = "item", name = "zirconium-pellet-dust", amount = 1 },
		},
		results = {
			{ type = "item", name = "cooked-zirconium-pellet-dust", amount = 1 },
		}
   },
   	{
		type = "recipe",
		name = "zirconium-tetrafluoride",
		category = "hv-dehydration-recipes",
		enabled = false,
		energy_required = HV_SPEED * 15,
		ingredients = {
			{ type = "item", name = "zirconium-pellet-dust", amount = 1 },
			{ type = "fluid", name = "industrial-strength-hydrofluoric-acid", amount = 40 },
		},
		results = {
			{ type = "fluid", name = "zirconium-tetrafluoride", amount = 14.4 },
			{ type = "fluid", name = "hydrochloric-acid", amount = 80 },
		},
		main_product = "zirconium-tetrafluoride"
   },
   
   
   
---MOLTEN URANIUM 235
   	{
		type = "recipe",
		name = "molten-uranium-235",
		category = "mv-extractor-recipes",
		enabled = false,
		energy_required = MV_SPEED * 1.2,
		ingredients = {
			{ type = "item", name = "uranium-235-dust", amount = 1 },
		},
		results = {
			{ type = "fluid", name = "molten-uranium-235", amount = 14.4 },
		},
		main_product = "molten-uranium-235"
   },   



---MAKING LFTB
   	{
		type = "recipe",
		name = "lithium-tetrafluoroberyllate",
		category = "mv-blast-furnace-recipes",
		enabled = false,
		energy_required = EV_SPEED * 140,
		ingredients = {
			{ type = "fluid", name = "lithium-fluoride", amount = 57.6 },
			{ type = "fluid", name = "beryllium-fluoride", amount = 43.2 },
		},
		results = {
			{ type = "fluid", name = "lithium-tetrafluoroberyllate", amount = 100.8 },
		}
   },



---MAKING LFTB
   	{
		type = "recipe",
		name = "lithium-tetrafluoroberyllate",
		category = "ev-ebf-recipes",
		enabled = false,
		energy_required = EV_SPEED * 140,
		ingredients = {
			{ type = "fluid", name = "lithium-fluoride", amount = 57.6 },
			{ type = "fluid", name = "beryllium-fluoride", amount = 43.2 },
		},
		results = {
			{ type = "fluid", name = "lithium-tetrafluoroberyllate", amount = 100.8 },
		}
   },



---REACTING LFTR FUEL 1			GENERATES 65,536,000 EU total per run: 655,360 EU/sec
   	{
		type = "recipe",
		name = "reacting-lftr-fuel-1",
		category = "lftr-recipes",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "fluid", name = "lftr-fuel-1", amount = 10 },
			{ type = "fluid", name = "lithium-tetrafluoroberyllate", amount = 20 },
		},
		results = {
			{ type = "fluid", name = "uranium-depleted-molten-salt", amount = 2.5 },
			{ type = "fluid", name = "thorium-depleted-molten-salt", amount = 5 },
			{ type = "fluid", name = "uranium-hexafluoride", amount = 0.6 },
		}
   },



---REACTING LFTR FUEL 2			GENERATES 262,144,000 EU total per run: 2,621,440 EU/sec
   	{
		type = "recipe",
		name = "reacting-lftr-fuel-2",
		category = "lftr-recipes",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "fluid", name = "lftr-fuel-2", amount = 10 },
			{ type = "fluid", name = "lithium-tetrafluoroberyllate", amount = 20 },
		},
		results = {
			{ type = "fluid", name = "uranium-depleted-molten-salt", amount = 5 },
			{ type = "fluid", name = "thorium-beryllium-depleted-molten-salt", amount = 10 },
			{ type = "fluid", name = "uranium-hexafluoride", amount = 1.5 },
		}
   },



---REACTING LFTR FUEL 3			GENERATES 1,048,576,000 EU total per run: 10,485,760 EU/sec
   	{
		type = "recipe",
		name = "reacting-lftr-fuel-3",
		category = "lftr-recipes",
		enabled = false,
		energy_required = 100,
		ingredients = {
			{ type = "fluid", name = "lftr-fuel-3", amount = 10 },
			{ type = "fluid", name = "lithium-tetrafluoroberyllate", amount = 20 },
		},
		results = {
			{ type = "fluid", name = "uranium-depleted-molten-salt", amount = 10 },
			{ type = "fluid", name = "thorium-beryllium-depleted-molten-salt", amount = 20 },
			{ type = "fluid", name = "uranium-hexafluoride", amount = 3 },
		}
   },

 
   
   --- THORIUM LFTR REACTOR
	{
		type = "item",
		name = "thorium-lftr-reactor-controller",
		icon = "__Gregtorio__/graphics/icons/thorium-lftr-reactor-controller.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "thorium-lftr-reactor-controller",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = IV_SPEED * 4,
		ingredients = {
			{ type = "item", name = "naquadah-cable", amount = 12 },
			{ type = "item", name = "control-circuit", amount = 2 },
			{ type = "item", name = "gregtech-computer-cube", amount = 1 },
			{ type = "item", name = "hastelloy-n-plate", amount = 4 },
			{ type = "item", name = "thorium-232-plate", amount = 2 },
			{ type = "item", name = "iv-machine-hull", amount = 1 },
		},
		results = {
			{ type = "item", name = "thorium-lftr-reactor-controller", amount = 1 },
		}
   },
	{
		type = "item",
		name = "thorium-lftr-reactor",
		icon = "__Gregtorio__/graphics/icons/thorium-lftr-reactor.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "thorium-lftr-reactor",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = IV_SPEED * 4,
		ingredients = {
			{ type = "item", name = "thorium-lftr-reactor-controller", amount = 1 },
			{ type = "item", name = "hastelloy-n-reactor-casing", amount = 87 },
			{ type = "item", name = "zeron-100-reactor-shielding", amount = 48 },
			{ type = "item", name = "lv-machine-hull", amount = 6 },
			{ type = "item", name = "iv-dynaomo-hatch", amount = 4 },
		},
		results = {
			{ type = "item", name = "thorium-lftr-reactor", amount = 1 },
		}
   },
	{
		type = "item",
		name = "hastelloy-n-reactor-casing",
		icon = "__Gregtorio__/graphics/icons/hastelloy-n-reactor-casing.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "hastelloy-n-reactor-casing",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "hastelloy-n-plate", amount = 8 },
			{ type = "item", name = "hastelloy-c276-frame", amount = 1 },
			{ type = "item", name = "heat-capacity-reactor-plating", amount = 4 },
		},
		results = {
			{ type = "item", name = "hastelloy-n-reactor-casing", amount = 2 },
		}
   },   
 	{
		type = "item",
		name = "heat-capacity-reactor-plating",
		icon = "__Gregtorio__/graphics/icons/heat-capacity-reactor-plating.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "heat-capacity-reactor-plating",
		category = "hv-assembling-machine-recipes",
		enabled = false,
		energy_required = 120,
		ingredients = {
			{ type = "item", name = "copper-plate", amount = 19 },
			{ type = "item", name = "silver-plate", amount = 1 },
			{ type = "item", name = "reactor-plating", amount = 1 },
		},
		results = {
			{ type = "item", name = "heat-capacity-reactor-plating", amount = 1 },
		}
   },
  	{
		type = "item",
		name = "reactor-plating",
		icon = "__Gregtorio__/graphics/icons/reactor-plating.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "reactor-plating",
		category = "mv-assembling-machine-recipes",
		enabled = false,
		energy_required = 40,
		ingredients = {
			{ type = "item", name = "lead-plate", amount = 9 },
			{ type = "item", name = "advanced-alloy", amount = 4 },
		},
		results = {
			{ type = "item", name = "reactor-plating", amount = 1 },
		}
   },   
	{
		type = "item",
		name = "zeron-100-reactor-shielding",
		icon = "__Gregtorio__/graphics/icons/zeron-100-reactor-shielding.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "zeron-100-reactor-shielding",
		category = "lv-assembling-machine-recipes",
		enabled = false,
		energy_required = EV_SPEED,
		ingredients = {
			{ type = "item", name = "zeron-100-plate", amount = 8 },
			{ type = "item", name = "lv-field-generator", amount = 1 },
			{ type = "item", name = "large-talonite-gear", amount = 2 },
		},
		results = {
			{ type = "item", name = "zeron-100-reactor-shielding", amount = 1 },
		}
   },

   	{
		type = "recipe",
		name = "molten-tantalum",
		category = "lv-extractor-recipes",
		enabled = false,
		energy_required = 9,
		ingredients = {
			{ type = "item", name = "tantalum-ingot", amount = 1 },
		},
		results = {
			{ type = "fluid", name = "molten-tantalum", amount = 14.4 },
		}
   },
	{
		type = "item",
		name = "data-orb",
		icon = "__Gregtorio__/graphics/icons/data-orb.png",
		icon_size = 32,
		stack_size = 64,
	}, 
   	{
		type = "recipe",
		name = "data-orb",
		category = "ev-circuit-assembler-recipes",
		enabled = false,
		energy_required = 20 * EV_SPEED,
		ingredients = {
			{ type = "item", name = "epoxy-printed-circuit-board", amount = 1 },
			{ type = "item", name = "processing-unit", amount = 2 },
			{ type = "item", name = "ram-chip", amount = 4 },
			{ type = "item", name = "nor-memory-chip", amount = 32 },
			{ type = "item", name = "nand-memory-chip", amount = 64 },
			{ type = "item", name = "fine-platinum-wire", amount = 32 },
			{ type = "fluid", name = "soldering-alloy", amount = 14.4 },
		},
		results = {
			{ type = "item", name = "data-orb", amount = 1 },
		}
   },



--]]   