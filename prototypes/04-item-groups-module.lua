data.raw["item-group"]["production"].order = "b"
data.raw["item-group"]["combat"].order = "z"

data:extend({

--- LOGISTICS TAB (ORDER: A)  
  
--- PRODUCTION TAB (ORDER: B)
{
  type = "item-subgroup",
  name = "stone-age-production-machine",
  group = "production",
  order = "a"
},
{
  type = "item-subgroup",
  name = "steam-age-production-machine",
  group = "production",
  order = "b"
},
{
  type = "item-subgroup",
  name = "lv-age-production-machine",
  group = "production",
  order = "c"
},
{
  type = "item-subgroup",
  name = "mv-age-production-machine",
  group = "production",
  order = "d"
},
{
  type = "item-subgroup",
  name = "subgroup-mv-age-multiblocks",
  group = "production",
  order = "e"
},
{
  type = "item-subgroup",
  name = "hv-age-production-machine",
  group = "production",
  order = "f"
},
{
  type = "item-subgroup",
  name = "subgroup-hv-age-multiblocks",
  group = "production",
  order = "g"
},
{
  type = "item-subgroup",
  name = "ev-age-production-machine",
  group = "production",
  order = "h"
},
{
  type = "item-subgroup",
  name = "subgroup-ev-age-multiblocks",
  group = "production",
  order = "i"
},
{
  type = "item-subgroup",
  name = "subgroup-iv-age-multiblocks",
  group = "production",
  order = "j"
},
{
  type = "item-subgroup",
  name = "subgroup-luv-age-multiblocks",
  group = "production",
  order = "k"
},
{
  type = "item-subgroup",
  name = "subgroup-zpm-age-multiblocks",
  group = "production",
  order = "l"
},
{
  type = "item-subgroup",
  name = "subgroup-uv-age-multiblocks",
  group = "production",
  order = "m"
},
{
  type = "item-subgroup",
  name = "subgroup-uhv-age-multiblocks",
  group = "production",
  order = "n"
},
{
  type = "item-subgroup",
  name = "subgroup-uev-age-multiblocks",
  group = "production",
  order = "o"
},
{
  type = "item-subgroup",
  name = "subgroup-uiv-age-multiblocks",
  group = "production",
  order = "p"
},
{
  type = "item-subgroup",
  name = "subgroup-uxv-age-multiblocks",
  group = "production",
  order = "q"
},
{
  type = "item-subgroup",
  name = "subgroup-enderio",
  group = "production",
  order = "r"
},



--- HANDCRAFTING TAB (ORDER: C)
  {
    type = "item-group",
    name = "handcrafting-tab",
    order = "c",
    icon = "__gregtorio-continued__/graphics/item-groups/handcrafting-tab.png",
    icon_size = 128
  },
  {
    type = "item-subgroup",
    name = "subgroup-manual-labor",
    group = "handcrafting-tab",
    order = "a"
  },
  {
    type = "item-subgroup",
    name = "subgroup-wood-related",
    group = "handcrafting-tab",
    order = "b"
  },
  {
    type = "item-subgroup",
    name = "subgroup-cobblestone-related",
    group = "handcrafting-tab",
    order = "c"
  },
  {
    type = "item-subgroup",
    name = "subgroup-tool-recipes",
    group = "handcrafting-tab",
    order = "d"
  },
  {
    type = "item-subgroup",
    name = "subgroup-early-game-machine-replacements",
    group = "handcrafting-tab",
    order = "e"
  },



--- MINING TAB  (ORDER: M)
  {
    type = "item-group",
    name = "mining-tab",
    order = "m",
    icon = "__gregtorio-continued__/graphics/item-groups/mining-tab.png",
    icon_size = 128
  },
  {
    type = "item-subgroup",
    name = "subgroup-mining-poor",
    group = "mining-tab",
    order = "d"
  },
  {
    type = "item-subgroup",
    name = "subgroup-digging",
    group = "mining-tab",
    order = "e"
  },
  {
    type = "item-subgroup",
    name = "subgroup-mining",
    group = "mining-tab",
    order = "f"
  },
  
  
  
--- MICROMINER TAB (ORDER: N)
  {
    type = "item-group",
    name = "microminer-tab",
    order = "n",
    icon = "__gregtorio-continued__/graphics/item-groups/microminer-tab.png",
    icon_size = 128
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t1",
    group = "microminer-tab",
    order = "a"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t2",
    group = "microminer-tab",
    order = "b"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t3",
    group = "microminer-tab",
    order = "c"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t4",
    group = "microminer-tab",
    order = "d"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t5",
    group = "microminer-tab",
    order = "e"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t6",
    group = "microminer-tab",
    order = "f"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t7",
    group = "microminer-tab",
    order = "g"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t8",
    group = "microminer-tab",
    order = "h"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t9",
    group = "microminer-tab",
    order = "i"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t10",
    group = "microminer-tab",
    order = "j"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t11",
    group = "microminer-tab",
    order = "k"
  },
  {
    type = "item-subgroup",
    name = "subgroup-microminer-t12",
    group = "microminer-tab",
    order = "l"
  },
  {
    type = "item-subgroup",
    name = "subgroup-basic-extended-crafting",
    group = "microminer-tab",
    order = "w"
  },
  {
    type = "item-subgroup",
    name = "subgroup-advanced-extended-crafting",
    group = "microminer-tab",
    order = "x"
  },
  {
    type = "item-subgroup",
    name = "subgroup-elite-extended-crafting",
    group = "microminer-tab",
    order = "y"
  },
  {
    type = "item-subgroup",
    name = "subgroup-ultimate-extended-crafting",
    group = "microminer-tab",
    order = "z"
  },  
  
  

---ASSEMBLING MACHINE RECIPES TAB (ORDER: X)
  {
    type = "item-group",
    name = "assembling-machine-tab",
    order = "x",
    icon = "__gregtorio-continued__/graphics/item-groups/assembling-machine-tab.png",
    icon_size = 128
  },
  {
    type = "item-subgroup",
    name = "subgroup-science-packs",
    group = "assembling-machine-tab",
    order = "a"
  },
  {
    type = "item-subgroup",
    name = "subgroup-crafting-or-assembling-recipes",
    group = "assembling-machine-tab",
    order = "b"
  },
  {
    type = "item-subgroup",
    name = "subgroup-assembling-machine",
    group = "assembling-machine-tab",
    order = "c"
  },
  {
    type = "item-subgroup",
    name = "subgroup-lv-components",
    group = "assembling-machine-tab",
    order = "d"
  },  
  {
    type = "item-subgroup",
    name = "subgroup-mv-components",
    group = "assembling-machine-tab",
    order = "e"
  },
  {
    type = "item-subgroup",
    name = "subgroup-hv-components",
    group = "assembling-machine-tab",
    order = "f"
  },

---PROCESSING MACHINE RECIPES TAB  (ORDER: Y)
  {
    type = "item-group",
    name = "processing-machine-recipes",
    order = "y",
    icon = "__gregtorio-continued__/graphics/item-groups/processing-machines-tab.png",
    icon_size = 128
  },
  {
    type = "item-subgroup",
    name = "subgroup-smelting",
    group = "processing-machine-recipes",
    order = "aaaa"
  },
  {
    type = "item-subgroup",
    name = "subgroup-circuit-parts-assembler",
    group = "processing-machine-recipes",
    order = "aaab"
  },
  {
    type = "item-subgroup",
    name = "subgroup-macerator-dust",
    group = "processing-machine-recipes",
    order = "aaac"
  }, 
  {
    type = "item-subgroup",
    name = "subgroup-macerator-crushed",
    group = "processing-machine-recipes",
    order = "aaad"
  },   
  
---The rest of the individual subgroups are generated by the function 'recipe_category_and_subgroup'

   
--- COMBAT TAB (ORDER: Z)  
  
})
