
data:extend({
  {
    type = "technology",
    name = "yafc-mode",
    icon = "__gregtorio-continued__/graphics/technology/punch-trees.png",
    icon_size = 256,
    effects = 	{
		{ type = "unlock-recipe", recipe = "manual-labor-automation" },
		{ type = "unlock-recipe", recipe = "yafc-magnetite" },
		{ type = "unlock-recipe", recipe = "yafc-vanadium-magnetite" },
		{ type = "unlock-recipe", recipe = "yafc-gold" },
		{ type = "unlock-recipe", recipe = "yafc-coal" },
		{ type = "unlock-recipe", recipe = "yafc-salt" },
		{ type = "unlock-recipe", recipe = "yafc-rock-salt" },
		{ type = "unlock-recipe", recipe = "yafc-lepidolite" },
		{ type = "unlock-recipe", recipe = "yafc-tin" },
		{ type = "unlock-recipe", recipe = "yafc-cassiterite" },
		{ type = "unlock-recipe", recipe = "yafc-realgar" },
		{ type = "unlock-recipe", recipe = "yafc-redstone" },
		{ type = "unlock-recipe", recipe = "yafc-ruby" },
		{ type = "unlock-recipe", recipe = "yafc-cinnabar" },
		{ type = "unlock-recipe", recipe = "yafc-fullers-earth" },
		{ type = "unlock-recipe", recipe = "yafc-gypsum" },
		{ type = "unlock-recipe", recipe = "yafc-apatite" },
		{ type = "unlock-recipe", recipe = "yafc-tricalcium-phosphate" },
		{ type = "unlock-recipe", recipe = "yafc-tetrahedrite" },
		{ type = "unlock-recipe", recipe = "yafc-copper" },
		{ type = "unlock-recipe", recipe = "yafc-stibnite" },
		{ type = "unlock-recipe", recipe = "yafc-pyrochlore" },
		{ type = "unlock-recipe", recipe = "yafc-nickel" },
		{ type = "unlock-recipe", recipe = "yafc-pentlandite" },
		{ type = "unlock-recipe", recipe = "yafc-tantalite" },
		{ type = "unlock-recipe", recipe = "yafc-pyrolusite" },
		{ type = "unlock-recipe", recipe = "yafc-cobaltite" },
		{ type = "unlock-recipe", recipe = "yafc-clay" },
		{ type = "unlock-recipe", recipe = "yafc-lazurite" },
		{ type = "unlock-recipe", recipe = "yafc-sodalite" },
		{ type = "unlock-recipe", recipe = "yafc-lapis" },
		{ type = "unlock-recipe", recipe = "yafc-calcite" },
		{ type = "unlock-recipe", recipe = "yafc-grossular" },
		{ type = "unlock-recipe", recipe = "yafc-spessartine" },
		{ type = "unlock-recipe", recipe = "yafc-diamond" },
		{ type = "unlock-recipe", recipe = "yafc-graphite" },
		{ type = "unlock-recipe", recipe = "yafc-galena" },
		{ type = "unlock-recipe", recipe = "yafc-lead" },
		{ type = "unlock-recipe", recipe = "yafc-silver" },
		{ type = "unlock-recipe", recipe = "yafc-cryolite" },
		{ type = "unlock-recipe", recipe = "yafc-sulfur" },
		{ type = "unlock-recipe", recipe = "yafc-sphalerite" },
		{ type = "unlock-recipe", recipe = "yafc-nether-quartz" },
		{ type = "unlock-recipe", recipe = "yafc-certus-quartz" },
		{ type = "unlock-recipe", recipe = "yafc-barite" },
		{ type = "unlock-recipe", recipe = "yafc-beryllium" },
		{ type = "unlock-recipe", recipe = "yafc-emerald" },
		{ type = "unlock-recipe", recipe = "yafc-bauxite" },
		{ type = "unlock-recipe", recipe = "yafc-aluminium" },
		{ type = "unlock-recipe", recipe = "yafc-ilmenite" },
		{ type = "unlock-recipe", recipe = "yafc-uranium" },
		{ type = "unlock-recipe", recipe = "yafc-pitchblende" },
		{ type = "unlock-recipe", recipe = "yafc-sheldonite" },
		{ type = "unlock-recipe", recipe = "yafc-platinum" },
		{ type = "unlock-recipe", recipe = "yafc-palladium" },
		{ type = "unlock-recipe", recipe = "yafc-bornite" },
		{ type = "unlock-recipe", recipe = "yafc-scheelite" },
		{ type = "unlock-recipe", recipe = "yafc-tungstate" },
		{ type = "unlock-recipe", recipe = "yafc-neodymium" },
		{ type = "unlock-recipe", recipe = "yafc-monazite" },
		{ type = "unlock-recipe", recipe = "yafc-bastnasite" },
	},
    enabled = true,
	prerequisites = { "craft-automation-science-packs" },
	unit =
	  {
		  count = 10,
		  ingredients = {{"automation-science-pack", SP01}},
		  time = 10
	  }
  }
  })



create_recipe{
    name = "yafc-magnetite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-iron", amount = 64 },
    },
	main_product = "raw-iron"
}
create_recipe{
    name = "yafc-vanadium-magnetite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-vanadium-magnetite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-gold",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-gold", amount = 64 },
    }
}
create_recipe{
    name = "yafc-coal",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-coal", amount = 64 },
    }
}
create_recipe{
    name = "yafc-salt",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-salt", amount = 64 },
    },
	main_product = "raw-salt"
}
create_recipe{
    name = "yafc-rock-salt",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-rock-salt", amount = 64 },
    }
}
create_recipe{
    name = "yafc-lepidolite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-lepidolite", amount = 64 },
    }
}   
create_recipe{
    name = "yafc-tin",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
		{ type = "item", name = "raw-tin", amount = 64 },
    }
}
create_recipe{
    name = "yafc-cassiterite",
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
	ingredients = { },
    results = {
		{ type = "item", name = "raw-cassiterite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-realgar",
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
	ingredients = { },
    results = {
      {type = "item", name = "raw-realgar", amount = 64 },
    }
}
create_recipe{
    name = "yafc-redstone",
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
	ingredients = { },
    results = {
      {type = "item", name = "raw-redstone", amount = 64 },
    },
	main_product = "raw-redstone"
}
create_recipe{
    name = "yafc-ruby",
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},	
	ingredients = { },
    results = {
      {type = "item", name = "raw-ruby", amount = 64 },
    }
}
create_recipe{
    name = "yafc-cinnabar",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-cinnabar", amount = 64 },
    }
}
create_recipe{
    name = "yafc-fullers-earth",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-fullers-earth", amount = 16 },
    }
}
create_recipe{
    name = "yafc-gypsum",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-gypsum", amount = 64 },
    }
}
create_recipe{
    name = "yafc-apatite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-apatite", amount = 64 },
    },
	main_product = "raw-apatite"
}
create_recipe{
    name = "yafc-tricalcium-phosphate",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-tricalcium-phosphate", amount = 64 },
    }
}
create_recipe{
    name = "yafc-pyrochlore",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-pyrochlore", amount = 64 },
    }
}
create_recipe{
    name = "yafc-clay",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "clay-ball", amount = 64 },
    },
	main_product = "clay-ball"
}
create_recipe{
    name = "yafc-nickel",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-nickel", amount = 64 },
    },
	main_product = "raw-nickel"
}
create_recipe{
    name = "yafc-pentlandite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-pentlandite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-cobaltite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-cobaltite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-tetrahedrite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-tetrahedrite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-copper",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-copper", amount = 64 },
    }
}
create_recipe{
    name = "yafc-stibnite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-stibnite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-lazurite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-lazurite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-sodalite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-sodalite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-lapis",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-lapis", amount = 64 },
    }
}
create_recipe{
    name = "yafc-calcite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-calcite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-galena",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-galena", amount = 64 },
    }
}
create_recipe{
    name = "yafc-lead",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-lead", amount = 64 },
    }
}
create_recipe{
    name = "yafc-silver",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-silver", amount = 64 },
    }
}
create_recipe{
    name = "yafc-cryolite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-cryolite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-graphite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-graphite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-diamond",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-diamond", amount = 64 },
    }
} 
 
create_recipe{
    name = "yafc-grossular",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-grossular", amount = 64 },
    }
}
create_recipe{
    name = "yafc-spessartine",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-spessartine", amount = 64 },
    }
}
create_recipe{
    name = "yafc-pyrolusite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-pyrolusite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-tantalite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 2,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-one-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-tantalite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-sulfur",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-sulfur", amount = 64 },
    }
}
create_recipe{
    name = "yafc-sphalerite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-sphalerite", amount = 64 },
    },
	main_product = "raw-sphalerite"
}
create_recipe{
    name = "yafc-nether-quartz",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-nether-quartz", amount = 64 },
    },
	main_product = "raw-nether-quartz"
}
create_recipe{
    name = "yafc-beryllium",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-beryllium", amount = 64 },
    }
}
create_recipe{
    name = "yafc-emerald",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-emerald", amount = 64 }
    },
	main_product = "raw-emerald"
}
create_recipe{
    name = "yafc-certus-quartz",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-certus-quartz", amount = 64 },
    },
	main_product = "raw-certus-quartz"
}
create_recipe{
    name = "yafc-barite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-barite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-bauxite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-bauxite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-aluminium",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-aluminium", amount = 64 },
    }
}
create_recipe{
    name = "yafc-ilmenite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-ilmenite", amount = 64 },
    },
	main_product = "raw-ilmenite"
}
create_recipe{
    name = "yafc-bastnasite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-bastnasite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-monazite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-monazite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-molybdenite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-molybdenite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-neodymium",
    category = "lv-assembling-machine-recipes",	
    energy_required = 4,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-two-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-neodymium", amount = 64 },
    }
}
create_recipe{
    name = "yafc-tungstate",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-tungstate", amount = 64 },
    }
}
create_recipe{
    name = "yafc-scheelite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-scheelite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-bornite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-bornite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-sheldonite",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-sheldonite", amount = 64 },
    }
}
create_recipe{
    name = "yafc-platinum",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-platinum", amount = 64 },
    }
}
create_recipe{
    name = "yafc-palladium",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-palladium", amount = 64 },
    }
}
create_recipe{
    name = "yafc-pitchblende",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-pitchblende", amount = 64 },
    }
}
create_recipe{
    name = "yafc-uranium",
    category = "lv-assembling-machine-recipes",	
    energy_required = 8,
    subgroup = "subgroup-microminer-t1",	
	ingredients = { {type = "item", name = "tier-three-microminer-output", amount = 1}},
    results = {
      {type = "item", name = "raw-uraninite", amount = 64 },
    },
	main_product = "raw-uraninite"
}
