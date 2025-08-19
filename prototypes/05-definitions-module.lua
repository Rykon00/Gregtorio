
---POWER COSTS DEFINITIONS: WATTAGE MULTIPLIED BY TIER [PERFECT OVERCLOCKS FOR EVERYTHING VERSION]
  EU2_LV   = "40kW"
  EU2_MV   = "80kW"
  EU2_HV   = "160kW"
  EU2_EV   = "320kW"
  EU2_IV   = "640kW"
  EU2_LuV  = "1.28MW"
  EU2_ZPM  = "2.56MW"
  EU2_UV   = "5.12MW"
  EU2_UHV  = "10.24MW"
  EU2_UEV  = "20.48MW"
  EU2_UIV  = "40.96MW"
  EU2_UXV  = "81.92MW"

  EU8_LV = "160kW"
  EU8_MV = "320kW"
  EU8_HV = "640kW"
  EU8_EV = "1.28MW"
  EU8_IV = "2.56MW"
  EU8_LuV = "5.12MW"
  EU8_ZPM = "10.24MW"
  EU8_UV = "20.48MW"
  EU8_UHV = "40.96MW"
  EU8_UEV = "81.92MW"
  EU8_UIV = "163.84MW"
  EU8_UXV = "327.68MW"

  EU12_LV = "240kW"
  EU12_MV = "480kW"
  EU12_HV = "960kW"
  EU12_EV = "1.92MW"
  EU12_IV = "3.84MW"
  EU12_LuV = "7.68MW"
  EU12_ZPM = "15.36MW"
  EU12_UV = "30.72MW"
  EU12_UHV = "61.44MW"
  EU12_UEV = "122.88MW"
  EU12_UIV = "245.76MW"
  EU12_UXV = "491.52MW"

  EU16_LV = "320kW"
  EU16_MV = "640kW"
  EU16_HV = "1.28MW"
  EU16_EV = "2.56MW"
  EU16_IV = "5.12MW"
  EU16_LuV = "10.24MW"
  EU16_ZPM = "20.48MW"
  EU16_UV = "40.96MW"
  EU16_UHV = "81.92MW"
  EU16_UEV = "163.84MW"
  EU16_UIV = "327.68MW"
  EU16_UXV = "655.36MW"

  EU24_LV = "480kW"
  EU24_MV = "960kW"
  EU24_HV = "1.92MW"
  EU24_EV = "3.84MW"
  EU24_IV = "7.68MW"
  EU24_LuV = "15.36MW"
  EU24_ZPM = "30.72MW"
  EU24_UV = "61.44MW"
  EU24_UHV = "122.88MW"
  EU24_UEV = "245.76MW"
  EU24_UIV = "491.52MW"
  EU24_UXV = "983.04MW"

  EU30_LV = "600kW"
  EU30_MV = "1.20MW"
  EU30_HV = "2.40MW"
  EU30_EV = "4.80MW"
  EU30_IV = "9.60MW"
  EU30_LuV = "19.20MW"
  EU30_ZPM = "38.40MW"
  EU30_UV = "76.80MW"
  EU30_UHV = "153.60MW"
  EU30_UEV = "307.20MW"
  EU30_UIV = "614.40MW"
  EU30_UXV = "1.23GW"

  EU32_LV = "640kW"
  EU32_MV = "1.28MW"
  EU32_HV = "2.56MW"
  EU32_EV = "5.12MW"
  EU32_IV = "10.24MW"
  EU32_LuV = "20.48MW"
  EU32_ZPM = "40.96MW"
  EU32_UV = "81.92MW"
  EU32_UHV = "163.84MW"
  EU32_UEV = "327.68MW"
  EU32_UIV = "655.36MW"
  EU32_UXV = "1.31GW"



---FUEL CATEGORY DEFINITIONS
data:extend({
  {
    type = "fuel-category",
    name = "manual-labor"
  },
  {
    type = "fuel-category",
    name = "gas-turbine-fuel"
  },
  {
    type = "fuel-category",
    name = "combustion-generator-fuel"
  },
  {
    type = "fuel-category",
    name = "semifluid-generator-fuel"
  },
  {
    type = "fuel-category",
    name = "nuclear-fuel-rod"
  },  

})



---RECIPE CATEGORY DEFINITIONS
data:extend({

---STONE AGE CRAFTING
  { type = "recipe-category", name = "manual-only-recipes" },
  { type = "recipe-category", name = "crafting-table-recipes" },
  { type = "recipe-category", name = "crafting-or-assembling-recipes" },
  { type = "recipe-category", name = "manual-mine-recipes" },
  { type = "recipe-category", name = "manual-digsite-recipes" },
})



---EXTRA CRAFTING GROUPS
recipe_category_and_subgroup( "coke-oven-recipes" )
recipe_category_and_subgroup( "pbf-recipes" ) 
recipe_category_and_subgroup( "fluid-voiding-recipes" ) 


  
---SINGLE TIER PROCESSING MACHINE CRAFTING
recipe_category_and_subgroup( "lv-forge-hammer-recipes" )
recipe_category_and_subgroup( "lv-air-collector-recipes" )   
recipe_category_and_subgroup( "lv-ore-washer-recipes" )
recipe_category_and_subgroup( "greenhouse-recipes" )
recipe_category_and_subgroup( "pyrolyse-oven-recipes" )
recipe_category_and_subgroup( "multismelter-recipes" )			
recipe_category_and_subgroup( "drilling-rig-recipes" )



---TIERED PROCESSING MACHINE CRAFTING
recipe_category_and_subgroup( "lv-wiremill-recipes" )
recipe_category_and_subgroup( "mv-wiremill-recipes" )
recipe_category_and_subgroup( "hv-wiremill-recipes" )
recipe_category_and_subgroup( "ev-wiremill-recipes" )
recipe_category_and_subgroup( "iv-wiremill-recipes" )
recipe_category_and_subgroup( "luv-wiremill-recipes" )
recipe_category_and_subgroup( "zpm-wiremill-recipes" )
recipe_category_and_subgroup( "uv-wiremill-recipes" )
recipe_category_and_subgroup( "uhv-wiremill-recipes" )
recipe_category_and_subgroup( "uev-wiremill-recipes" )
recipe_category_and_subgroup( "uiv-wiremill-recipes" )
recipe_category_and_subgroup( "umv-wiremill-recipes" )
recipe_category_and_subgroup( "uxv-wiremill-recipes" )
  
  

recipe_category_and_subgroup( "lv-bending-machine-recipes" )
recipe_category_and_subgroup( "mv-bending-machine-recipes" )
recipe_category_and_subgroup( "hv-bending-machine-recipes" )
recipe_category_and_subgroup( "ev-bending-machine-recipes" )
recipe_category_and_subgroup( "iv-bending-machine-recipes" )
recipe_category_and_subgroup( "luv-bending-machine-recipes" )
recipe_category_and_subgroup( "zpm-bending-machine-recipes" )
recipe_category_and_subgroup( "uv-bending-machine-recipes" )
recipe_category_and_subgroup( "uhv-bending-machine-recipes" )
recipe_category_and_subgroup( "uev-bending-machine-recipes" )
recipe_category_and_subgroup( "uiv-bending-machine-recipes" )
recipe_category_and_subgroup( "umv-bending-machine-recipes" )
recipe_category_and_subgroup( "uxv-bending-machine-recipes" )



recipe_category_and_subgroup( "lv-lathe-recipes" )
recipe_category_and_subgroup( "mv-lathe-recipes" )
recipe_category_and_subgroup( "hv-lathe-recipes" )
recipe_category_and_subgroup( "ev-lathe-recipes" )
recipe_category_and_subgroup( "iv-lathe-recipes" )
recipe_category_and_subgroup( "luv-lathe-recipes" )
recipe_category_and_subgroup( "zpm-lathe-recipes" )
recipe_category_and_subgroup( "uv-lathe-recipes" )
recipe_category_and_subgroup( "uhv-lathe-recipes" )
recipe_category_and_subgroup( "uev-lathe-recipes" )
recipe_category_and_subgroup( "uiv-lathe-recipes" )
recipe_category_and_subgroup( "umv-lathe-recipes" )
recipe_category_and_subgroup( "uxv-lathe-recipes" )



recipe_category_and_subgroup( "lv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "mv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "hv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "ev-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "iv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "luv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "zpm-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "uv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "uhv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "uev-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "uiv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "umv-alloy-smelter-recipes" ) 
recipe_category_and_subgroup( "uxv-alloy-smelter-recipes" ) 



recipe_category_and_subgroup( "lv-polarizer-recipes" )
recipe_category_and_subgroup( "mv-polarizer-recipes" )
recipe_category_and_subgroup( "hv-polarizer-recipes" )
recipe_category_and_subgroup( "ev-polarizer-recipes" )
recipe_category_and_subgroup( "iv-polarizer-recipes" )
recipe_category_and_subgroup( "luv-polarizer-recipes" )
recipe_category_and_subgroup( "zpm-polarizer-recipes" )
recipe_category_and_subgroup( "uv-polarizer-recipes" )
recipe_category_and_subgroup( "uhv-polarizer-recipes" )
recipe_category_and_subgroup( "uev-polarizer-recipes" )
recipe_category_and_subgroup( "uiv-polarizer-recipes" )
recipe_category_and_subgroup( "umv-polarizer-recipes" )
recipe_category_and_subgroup( "uxv-polarizer-recipes" )



recipe_category_and_subgroup( "lv-autoclave-recipes" )
recipe_category_and_subgroup( "mv-autoclave-recipes" )
recipe_category_and_subgroup( "hv-autoclave-recipes" )
recipe_category_and_subgroup( "ev-autoclave-recipes" )
recipe_category_and_subgroup( "iv-autoclave-recipes" )
recipe_category_and_subgroup( "luv-autoclave-recipes" )
recipe_category_and_subgroup( "zpm-autoclave-recipes" )
recipe_category_and_subgroup( "uv-autoclave-recipes" )
recipe_category_and_subgroup( "uhv-autoclave-recipes" )
recipe_category_and_subgroup( "uev-autoclave-recipes" )
recipe_category_and_subgroup( "uiv-autoclave-recipes" )
recipe_category_and_subgroup( "umv-autoclave-recipes" )
recipe_category_and_subgroup( "uxv-autoclave-recipes" )



recipe_category_and_subgroup( "lv-compressor-recipes" )
recipe_category_and_subgroup( "mv-compressor-recipes" )
recipe_category_and_subgroup( "hv-compressor-recipes" )
recipe_category_and_subgroup( "ev-compressor-recipes" )
recipe_category_and_subgroup( "iv-compressor-recipes" )
recipe_category_and_subgroup( "luv-compressor-recipes" )
recipe_category_and_subgroup( "zpm-compressor-recipes" )
recipe_category_and_subgroup( "uv-compressor-recipes" )
recipe_category_and_subgroup( "uhv-compressor-recipes" )
recipe_category_and_subgroup( "uev-compressor-recipes" )
recipe_category_and_subgroup( "uiv-compressor-recipes" )
recipe_category_and_subgroup( "umv-compressor-recipes" )
recipe_category_and_subgroup( "uxv-compressor-recipes" )



recipe_category_and_subgroup( "lv-extruder-recipes" )
recipe_category_and_subgroup( "mv-extruder-recipes" )
recipe_category_and_subgroup( "hv-extruder-recipes" )
recipe_category_and_subgroup( "ev-extruder-recipes" )
recipe_category_and_subgroup( "iv-extruder-recipes" )
recipe_category_and_subgroup( "luv-extruder-recipes" )
recipe_category_and_subgroup( "zpm-extruder-recipes" )
recipe_category_and_subgroup( "uv-extruder-recipes" )
recipe_category_and_subgroup( "uhv-extruder-recipes" )
recipe_category_and_subgroup( "uev-extruder-recipes" )
recipe_category_and_subgroup( "uiv-extruder-recipes" )
recipe_category_and_subgroup( "umv-extruder-recipes" )
recipe_category_and_subgroup( "uxv-extruder-recipes" )
  


recipe_category_and_subgroup( "lv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "mv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "hv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "ev-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "iv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "luv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "zpm-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "uv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "uhv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "uev-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "uiv-fluid-solidifier-recipes" )
recipe_category_and_subgroup( "umv-fluid-solidifier-recipes" )  
recipe_category_and_subgroup( "uxv-fluid-solidifier-recipes" )  
  


recipe_category_and_subgroup( "lv-sifter-recipes" )
recipe_category_and_subgroup( "mv-sifter-recipes" )
recipe_category_and_subgroup( "hv-sifter-recipes" )
recipe_category_and_subgroup( "ev-sifter-recipes" )
recipe_category_and_subgroup( "iv-sifter-recipes" )
recipe_category_and_subgroup( "luv-sifter-recipes" )
recipe_category_and_subgroup( "zpm-sifter-recipes" )
recipe_category_and_subgroup( "uv-sifter-recipes" )
recipe_category_and_subgroup( "uhv-sifter-recipes" )
recipe_category_and_subgroup( "uev-sifter-recipes" )
recipe_category_and_subgroup( "uiv-sifter-recipes" )
recipe_category_and_subgroup( "umv-sifter-recipes" )
recipe_category_and_subgroup( "uxv-sifter-recipes" )



recipe_category_and_subgroup( "lv-macerator-recipes" )
recipe_category_and_subgroup( "mv-macerator-recipes" )
recipe_category_and_subgroup( "hv-macerator-recipes" )
recipe_category_and_subgroup( "ev-macerator-recipes" )
recipe_category_and_subgroup( "iv-macerator-recipes" )
recipe_category_and_subgroup( "luv-macerator-recipes" )
recipe_category_and_subgroup( "zpm-macerator-recipes" )
recipe_category_and_subgroup( "uv-macerator-recipes" )
recipe_category_and_subgroup( "uhv-macerator-recipes" )
recipe_category_and_subgroup( "uev-macerator-recipes" )
recipe_category_and_subgroup( "uiv-macerator-recipes" )
recipe_category_and_subgroup( "umv-macerator-recipes" )
recipe_category_and_subgroup( "uxv-macerator-recipes" )
  


recipe_category_and_subgroup( "lv-canning-machine-recipes" )
recipe_category_and_subgroup( "mv-canning-machine-recipes" )
recipe_category_and_subgroup( "hv-canning-machine-recipes" )
recipe_category_and_subgroup( "ev-canning-machine-recipes" )
recipe_category_and_subgroup( "iv-canning-machine-recipes" )
recipe_category_and_subgroup( "luv-canning-machine-recipes" )
recipe_category_and_subgroup( "zpm-canning-machine-recipes" )
recipe_category_and_subgroup( "uv-canning-machine-recipes" )
recipe_category_and_subgroup( "uhv-canning-machine-recipes" )
recipe_category_and_subgroup( "uev-canning-machine-recipes" )
recipe_category_and_subgroup( "uiv-canning-machine-recipes" )
recipe_category_and_subgroup( "umv-canning-machine-recipes" )
recipe_category_and_subgroup( "uxv-canning-machine-recipes" )
  


recipe_category_and_subgroup( "lv-electrolyzer-recipes" )
recipe_category_and_subgroup( "mv-electrolyzer-recipes" )
recipe_category_and_subgroup( "hv-electrolyzer-recipes" )
recipe_category_and_subgroup( "ev-electrolyzer-recipes" )
recipe_category_and_subgroup( "iv-electrolyzer-recipes" )
recipe_category_and_subgroup( "luv-electrolyzer-recipes" )
recipe_category_and_subgroup( "zpm-electrolyzer-recipes" )
recipe_category_and_subgroup( "uv-electrolyzer-recipes" )
recipe_category_and_subgroup( "uhv-electrolyzer-recipes" )
recipe_category_and_subgroup( "uev-electrolyzer-recipes" )
recipe_category_and_subgroup( "uiv-electrolyzer-recipes" )
recipe_category_and_subgroup( "umv-electrolyzer-recipes" )
recipe_category_and_subgroup( "uxv-electrolyzer-recipes" )



recipe_category_and_subgroup( "lv-cutting-machine-recipes" )
recipe_category_and_subgroup( "mv-cutting-machine-recipes" )
recipe_category_and_subgroup( "hv-cutting-machine-recipes" )
recipe_category_and_subgroup( "ev-cutting-machine-recipes" )
recipe_category_and_subgroup( "iv-cutting-machine-recipes" )
recipe_category_and_subgroup( "luv-cutting-machine-recipes" )
recipe_category_and_subgroup( "zpm-cutting-machine-recipes" )
recipe_category_and_subgroup( "uv-cutting-machine-recipes" )
recipe_category_and_subgroup( "uhv-cutting-machine-recipes" )
recipe_category_and_subgroup( "uev-cutting-machine-recipes" )
recipe_category_and_subgroup( "uiv-cutting-machine-recipes" )
recipe_category_and_subgroup( "umv-cutting-machine-recipes" )
recipe_category_and_subgroup( "uxv-cutting-machine-recipes" )
  
  
  
recipe_category_and_subgroup( "mv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "hv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "ev-laser-engraver-recipes" )  
recipe_category_and_subgroup( "iv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "luv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "zpm-laser-engraver-recipes" )  
recipe_category_and_subgroup( "uv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "uhv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "uev-laser-engraver-recipes" )  
recipe_category_and_subgroup( "uiv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "umv-laser-engraver-recipes" )  
recipe_category_and_subgroup( "uxv-laser-engraver-recipes" )  
  
  
  
recipe_category_and_subgroup( "lv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "mv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "hv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "ev-chemical-reactor-recipes" )
recipe_category_and_subgroup( "iv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "luv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "zpm-chemical-reactor-recipes" )
recipe_category_and_subgroup( "uv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "uhv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "uev-chemical-reactor-recipes" )
recipe_category_and_subgroup( "uiv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "umv-chemical-reactor-recipes" )
recipe_category_and_subgroup( "uxv-chemical-reactor-recipes" )
  
  
  
recipe_category_and_subgroup( "lv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "mv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "hv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "ev-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "iv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "luv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "zpm-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "uv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "uhv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "uev-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "uiv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "umv-circuit-assembler-recipes" ) 
recipe_category_and_subgroup( "uxv-circuit-assembler-recipes" ) 
  
  

recipe_category_and_subgroup( "mv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "hv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "ev-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "iv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "luv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "zpm-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "uv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "uhv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "uev-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "uiv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "umv-electric-blast-furnace-recipes" )
recipe_category_and_subgroup( "uxv-electric-blast-furnace-recipes" )



recipe_category_and_subgroup( "lv-distillation-recipes" )
recipe_category_and_subgroup( "mv-distillation-recipes" )
recipe_category_and_subgroup( "hv-distillation-recipes" )
recipe_category_and_subgroup( "ev-distillation-recipes" )
recipe_category_and_subgroup( "iv-distillation-recipes" )
recipe_category_and_subgroup( "luv-distillation-recipes" )
recipe_category_and_subgroup( "zpm-distillation-recipes" )
recipe_category_and_subgroup( "uv-distillation-recipes" )
recipe_category_and_subgroup( "uhv-distillation-recipes" )
recipe_category_and_subgroup( "uev-distillation-recipes" )
recipe_category_and_subgroup( "uiv-distillation-recipes" )
recipe_category_and_subgroup( "umv-distillation-recipes" )
recipe_category_and_subgroup( "uxv-distillation-recipes" )



recipe_category_and_subgroup( "lv-tall-distillation-recipes" )
recipe_category_and_subgroup( "mv-tall-distillation-recipes" )
recipe_category_and_subgroup( "hv-tall-distillation-recipes" )
recipe_category_and_subgroup( "ev-tall-distillation-recipes" )
recipe_category_and_subgroup( "iv-tall-distillation-recipes" )
recipe_category_and_subgroup( "luv-tall-distillation-recipes" )
recipe_category_and_subgroup( "zpm-tall-distillation-recipes" )
recipe_category_and_subgroup( "uv-tall-distillation-recipes" )
recipe_category_and_subgroup( "uhv-tall-distillation-recipes" )
recipe_category_and_subgroup( "uev-tall-distillation-recipes" )
recipe_category_and_subgroup( "uiv-tall-distillation-recipes" )
recipe_category_and_subgroup( "umv-tall-distillation-recipes" )
recipe_category_and_subgroup( "uxv-tall-distillation-recipes" )


recipe_category_and_subgroup( "lv-mixer-recipes" )
recipe_category_and_subgroup( "mv-mixer-recipes" )
recipe_category_and_subgroup( "hv-mixer-recipes" )
recipe_category_and_subgroup( "ev-mixer-recipes" )
recipe_category_and_subgroup( "iv-mixer-recipes" )
recipe_category_and_subgroup( "luv-mixer-recipes" )
recipe_category_and_subgroup( "zpm-mixer-recipes" )
recipe_category_and_subgroup( "uv-mixer-recipes" )
recipe_category_and_subgroup( "uhv-mixer-recipes" )
recipe_category_and_subgroup( "uev-mixer-recipes" )
recipe_category_and_subgroup( "uiv-mixer-recipes" )
recipe_category_and_subgroup( "umv-mixer-recipes" )
recipe_category_and_subgroup( "uxv-mixer-recipes" )



recipe_category_and_subgroup( "lv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "mv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "hv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "ev-implosion-compressor-recipes" )
recipe_category_and_subgroup( "iv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "luv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "zpm-implosion-compressor-recipes" )
recipe_category_and_subgroup( "uv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "uhv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "uev-implosion-compressor-recipes" )
recipe_category_and_subgroup( "uiv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "umv-implosion-compressor-recipes" )
recipe_category_and_subgroup( "uxv-implosion-compressor-recipes" )



recipe_category_and_subgroup( "lv-chemical-bath-recipes" )
recipe_category_and_subgroup( "mv-chemical-bath-recipes" )
recipe_category_and_subgroup( "hv-chemical-bath-recipes" )
recipe_category_and_subgroup( "ev-chemical-bath-recipes" )
recipe_category_and_subgroup( "iv-chemical-bath-recipes" )
recipe_category_and_subgroup( "luv-chemical-bath-recipes" )
recipe_category_and_subgroup( "zpm-chemical-bath-recipes" )
recipe_category_and_subgroup( "uv-chemical-bath-recipes" )
recipe_category_and_subgroup( "uhv-chemical-bath-recipes" )
recipe_category_and_subgroup( "uev-chemical-bath-recipes" )
recipe_category_and_subgroup( "uiv-chemical-bath-recipes" )
recipe_category_and_subgroup( "umv-chemical-bath-recipes" )
recipe_category_and_subgroup( "uxv-chemical-bath-recipes" )



recipe_category_and_subgroup( "lv-extractor-recipes" )
recipe_category_and_subgroup( "mv-extractor-recipes" )
recipe_category_and_subgroup( "hv-extractor-recipes" )
recipe_category_and_subgroup( "ev-extractor-recipes" )
recipe_category_and_subgroup( "iv-extractor-recipes" )
recipe_category_and_subgroup( "luv-extractor-recipes" )
recipe_category_and_subgroup( "zpm-extractor-recipes" )
recipe_category_and_subgroup( "uv-extractor-recipes" )
recipe_category_and_subgroup( "uhv-extractor-recipes" )
recipe_category_and_subgroup( "uev-extractor-recipes" )
recipe_category_and_subgroup( "uiv-extractor-recipes" )
recipe_category_and_subgroup( "umv-extractor-recipes" )
recipe_category_and_subgroup( "uxv-extractor-recipes" )
  


recipe_category_and_subgroup( "iv-assembly-line-recipes" )
recipe_category_and_subgroup( "luv-assembly-line-recipes" )
recipe_category_and_subgroup( "zpm-assembly-line-recipes" )
recipe_category_and_subgroup( "uv-assembly-line-recipes" )
recipe_category_and_subgroup( "uhv-assembly-line-recipes" )
recipe_category_and_subgroup( "uev-assembly-line-recipes" )
recipe_category_and_subgroup( "uiv-assembly-line-recipes" )
recipe_category_and_subgroup( "umv-assembly-line-recipes" )
recipe_category_and_subgroup( "uxv-assembly-line-recipes" )



recipe_category_and_subgroup( "lv-centrifuge-recipes" )
recipe_category_and_subgroup( "mv-centrifuge-recipes" )
recipe_category_and_subgroup( "hv-centrifuge-recipes" )
recipe_category_and_subgroup( "ev-centrifuge-recipes" )
recipe_category_and_subgroup( "iv-centrifuge-recipes" )
recipe_category_and_subgroup( "luv-centrifuge-recipes" )
recipe_category_and_subgroup( "zpm-centrifuge-recipes" )
recipe_category_and_subgroup( "uv-centrifuge-recipes" )
recipe_category_and_subgroup( "uhv-centrifuge-recipes" )
recipe_category_and_subgroup( "uev-centrifuge-recipes" )
recipe_category_and_subgroup( "uiv-centrifuge-recipes" )
recipe_category_and_subgroup( "umv-centrifuge-recipes" )
recipe_category_and_subgroup( "uxv-centrifuge-recipes" )



recipe_category_and_subgroup( "lv-assembling-machine-recipes" )
recipe_category_and_subgroup( "mv-assembling-machine-recipes" )
recipe_category_and_subgroup( "hv-assembling-machine-recipes" )
recipe_category_and_subgroup( "ev-assembling-machine-recipes" )
recipe_category_and_subgroup( "iv-assembling-machine-recipes" )
recipe_category_and_subgroup( "luv-assembling-machine-recipes" )
recipe_category_and_subgroup( "zpm-assembling-machine-recipes" )
recipe_category_and_subgroup( "uv-assembling-machine-recipes" )
recipe_category_and_subgroup( "uhv-assembling-machine-recipes" )
recipe_category_and_subgroup( "uev-assembling-machine-recipes" )
recipe_category_and_subgroup( "uiv-assembling-machine-recipes" )
recipe_category_and_subgroup( "umv-assembling-machine-recipes" )
recipe_category_and_subgroup( "uxv-assembling-machine-recipes" )
  
  

recipe_category_and_subgroup( "mv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "hv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "ev-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "iv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "luv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "zpm-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "uv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "uhv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "uev-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "uiv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "umv-vacuum-freezer-recipes" )  
recipe_category_and_subgroup( "uxv-vacuum-freezer-recipes" )  
  
  
  
recipe_category_and_subgroup( "hv-cracker-recipes" )  
recipe_category_and_subgroup( "ev-cracker-recipes" )  
recipe_category_and_subgroup( "iv-cracker-recipes" )  
recipe_category_and_subgroup( "luv-cracker-recipes" )  
recipe_category_and_subgroup( "zpm-cracker-recipes" )  
recipe_category_and_subgroup( "uv-cracker-recipes" )  
recipe_category_and_subgroup( "uhv-cracker-recipes" )  
recipe_category_and_subgroup( "uev-cracker-recipes" )  
recipe_category_and_subgroup( "uiv-cracker-recipes" )  
recipe_category_and_subgroup( "umv-cracker-recipes" )  
recipe_category_and_subgroup( "uxv-cracker-recipes" )  



recipe_category_and_subgroup( "lv-rock-crusher-recipes" )
recipe_category_and_subgroup( "mv-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "hv-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "ev-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "iv-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "luv-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "zpm-rock-crusher-recipes" ) 
recipe_category_and_subgroup( "uv-rock-crusher-recipes" ) 
  


recipe_category_and_subgroup( "mv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "hv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "ev-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "iv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "luv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "zpm-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "uv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "uhv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "uev-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "uiv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "umv-alloy-blast-smelter-recipes" )
recipe_category_and_subgroup( "uxv-alloy-blast-smelter-recipes" )



recipe_category_and_subgroup( "mv-microverse-projector-recipes" )
recipe_category_and_subgroup( "hv-microverse-projector-recipes" )
recipe_category_and_subgroup( "ev-microverse-projector-recipes" )
recipe_category_and_subgroup( "iv-microverse-projector-recipes" )
recipe_category_and_subgroup( "luv-microverse-projector-recipes" )
recipe_category_and_subgroup( "zpm-microverse-projector-recipes" )
recipe_category_and_subgroup( "uv-microverse-projector-recipes" )
recipe_category_and_subgroup( "uhv-microverse-projector-recipes" )
recipe_category_and_subgroup( "uev-microverse-projector-recipes" )
recipe_category_and_subgroup( "uiv-microverse-projector-recipes" )
recipe_category_and_subgroup( "umv-microverse-projector-recipes" )
recipe_category_and_subgroup( "uxv-microverse-projector-recipes" )
  
  
  
recipe_category_and_subgroup( "lv-dehydrator-recipes" )  
recipe_category_and_subgroup( "mv-dehydrator-recipes" )  
recipe_category_and_subgroup( "hv-dehydrator-recipes" )  
recipe_category_and_subgroup( "ev-dehydrator-recipes" )  
recipe_category_and_subgroup( "iv-dehydrator-recipes" )  
recipe_category_and_subgroup( "luv-dehydrator-recipes" )  
recipe_category_and_subgroup( "zpm-dehydrator-recipes" )  
recipe_category_and_subgroup( "uv-dehydrator-recipes" )  
recipe_category_and_subgroup( "uhv-dehydrator-recipes" )  
recipe_category_and_subgroup( "uev-dehydrator-recipes" )  
recipe_category_and_subgroup( "uiv-dehydrator-recipes" )  
recipe_category_and_subgroup( "umv-dehydrator-recipes" )  
recipe_category_and_subgroup( "uxv-dehydrator-recipes" )   
  
  
  
recipe_category_and_subgroup( "ev-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "iv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "luv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "zpm-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "uv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "uhv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "uev-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "uiv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "umv-extreme-entity-crusher-recipes" )  
recipe_category_and_subgroup( "uxv-extreme-entity-crusher-recipes" )  
  
  
  
recipe_category_and_subgroup( "luv-fusion-reactor-recipes" )
recipe_category_and_subgroup( "zpm-fusion-reactor-recipes" )
recipe_category_and_subgroup( "uv-fusion-reactor-recipes" )
recipe_category_and_subgroup( "uhv-fusion-reactor-recipes" )
recipe_category_and_subgroup( "uev-fusion-reactor-recipes" )
recipe_category_and_subgroup( "uiv-fusion-reactor-recipes" )
recipe_category_and_subgroup( "umv-fusion-reactor-recipes" )
recipe_category_and_subgroup( "uxv-fusion-reactor-recipes" )



recipe_category_and_subgroup( "uv-coal-recipes" )
recipe_category_and_subgroup( "zpm-coal-recipes" )
recipe_category_and_subgroup( "uv-coal-recipes" )
recipe_category_and_subgroup( "uuv-coal-recipes" )
recipe_category_and_subgroup( "uev-coal-recipes" )
recipe_category_and_subgroup( "uiv-coal-recipes" )
recipe_category_and_subgroup( "uuv-coal-recipes" )
recipe_category_and_subgroup( "uxv-coal-recipes" )
  
  
  
recipe_category_and_subgroup( "basic-extended-crafting-recipes" )
recipe_category_and_subgroup( "advanced-extended-crafting-recipes" )
recipe_category_and_subgroup( "elite-extended-crafting-recipes" )
recipe_category_and_subgroup( "ultimate-extended-crafting-recipes" )



---ENDER TANKS
recipe_category_and_subgroup( "nether-air-ender-tank-recipes" )
recipe_category_and_subgroup( "ender-air-ender-tank-recipes" )



---WERIDO MACHINESnether-air-ender-tank-recipes
recipe_category_and_subgroup( "digester-recipes" )
recipe_category_and_subgroup( "dissolution-tank-recipes" )
recipe_category_and_subgroup( "neutron-activator-recipes" )
recipe_category_and_subgroup( "slice-n-splice-recipes" )
recipe_category_and_subgroup( "powered-spawner-recipes" )
recipe_category_and_subgroup( "soul-binder-recipes" )



---MACHINE SPEED DEFINITIONS
LV_SPEED = 1
MV_SPEED = 2
HV_SPEED = 4
EV_SPEED = 8
IV_SPEED = 16
LUV_SPEED = 32
ZPM_SPEED = 64
UV_SPEED = 128
UHV_SPEED = 256
UEV_SPEED = 512
UIV_SPEED = 1024
UMV_SPEED = 2048
UXV_SPEED = 4096
MAX_SPEED = 8192



---RESEARCH PACK COUNT DEFINITIONS
SP01 = 1
SP02 = 2
SP03 = 3
SP04 = 5
SP05 = 8
SP06 = 12
SP07 = 18
SP08 = 28
SP09 = 42
SP10 = 66
SP11 = 100
SP12 = 162
SP13 = 256
SP14 = 256
SP15 = 256



--- MATERIAL SPEED DEFINITIONS
GRAPHENE_SPEED = 0.4
BERYLLIUM_SPEED = 0.45
CRYSTAL_MATRIX_SPEED = 0.6
EGLIN_STEEL_SPEED = 0.7
MAGNALIUM_SPEED = 1.25
ALUMINIUM_SPEED = 1.3
DARK_STEEL_SPEED = 1.35
SILICON_SPEED = 1.4
WATERTIGHT_STEEL_SPEED = 1.5
ELTZ_SPEED = 1.5
NICKEL_ZINC_FERRITE_SPEED = 1.65
ELECTRICAL_STEEL_SPEED = 1.8
MARAGING_STEEL_300_SPEED = 2.2
KANTHAL_SPEED = 2.2
TITANIUM_SPEED = 2.4
SIAO_SPEED = 2.4
INCOLOY_MA956_SPEED = 2.45
MOLYBDENUM_DISILICIDE_SPEED = 2.5
ZIRCONIUM_CARBIDE_SPEED = 2.55
YTTRIUM_BARIUM_CUPRATE_SPEED = 2.55
CHROMIUM_SPEED = 2.6
STAINLESS_STEEL_SPEED = 2.75
VANADIUM_STEEL_SPEED = 2.75
VANADIUM_GALLIUM_SPEED = 2.75
INCONEL_625_SPEED = 2.8
MARAGING_STEEL_250_SPEED = 2.8
IRON_SPEED = 2.8
STEEL_SPEED = 2.8
INVAR_SPEED = 2.8
NICHROME_SPEED = 2.8
PULSATING_IRON_SPEED = 2.8
INCOLOY_903_SPEED = 2.85
COBALT_BRASS_SPEED = 2.9
CUPRONICKEL_SPEED = 3
HSLA_STEEL_SPEED = 3.05
ULTIMET_SPEED = 3.05
MICROVERSIUM_SPEED = 3.1
COPPER_SPEED = 3.15
ANNEALED_COPPER_SPEED = 3.15
BRASS_SPEED = 3.15
BLACK_STEEL_SPEED = 3.2
ZINC_SPEED = 3.25
CONDUCTIVE_IRON_SPEED = 3.45
GALLIUM_SPEED = 4.9
SUNNARIUM_SPEED = 4.9
FLUXED_ELECTRUM_SPEED = 4.9
NIOBIUM_TITANIUM_SPEED = 3.55
ZERON_100_SPEED = 3.7
BLUE_STEEL_SPEED = 3.75
BRONZE_SPEED = 3.8
RED_ALLOY_SPEED = 4
HSSE_SPEED = 4.05
RTM_ALLOY_SPEED = 4.1
VIBRANT_ALLOY_SPEED = 4.25
STELLAR_ALLOY_SPEED = 4.5
TANTALUM_CARBIDE_SPEED = 4.75
TUNGSTEN_CARBIDE_SPEED = 4.85
ENRICHED_NAQUADAH_SPEED = 4.9
INDOVANADIUM_SPEED = 4.9
AWAKENED_DRACONIUM_SPEED = 4.9
ADAMANTIUM_SPEED = 4.9
NAQUADRIA_SPEED = 4.9
NAQUADAH_ALLOY_SPEED = 4.9
LEDOX_SPEED = 4.9
TRINIUM_SPEED = 4.9
HSSG_SPEED = 4.9
BLACK_PLUTONIUM_SPEED = 4.9
HASTELLOY_X_SPEED = 5
INCOLOY_DS_SPEED = 5
SOULARIUM_SPEED = 5.1
END_STEEL_SPEED = 5.1
TALONITE_SPEED = 5.2
INCONEL_792_SPEED = 5.2
RHODIUM_PLATED_PALLADIUM_SPEED = 4.75
PALLADIUM_SPEED = 5.3
SILVER_SPEED = 5.35
HASTELLOY_W_SPEED = 5.6
TIN_SPEED = 5.9
TUNGSTENSTEEL_SPEED = 5.95
ENDERIUM_SPEED = 6.3
TUMBAGA_SPEED = 6.45
INCONEL_690_SPEED = 6.4
HSSS_SPEED = 6.45
RURIDIT_SPEED = 6.55
POTIN_SPEED = 6.65
STABALLOY_SPEED = 7.15
NEODYMIUM_SPEED = 7.2
ENERGETIC_ALLOY_SPEED = 7.35
SAMARIUM_SPEED = 7.5
ELECTRUM_SPEED = 7.55
EUROPIUM_SPEED = 7.55
SIGNALUM_SPEED = 7.8
HOLMIUM_SPEED = 8.2
LUTETIUM_SPEED = 8.7
TANTALUM_SPEED = 9
TANTALLOY_60_SPEED = 9.05
TUNGSTEN_SPEED = 9.15
STELLITE_SPEED = 9.2
ENRICHED_NAQUADAH_ALLOY_SPEED = 9.3
BATTERY_ALLOY_SPEED = 9.45
OSMIUM_SPEED = 9.5
OSMIRIDIUM_SPEED = 9.55
IRIDIUM_SPEED = 9.6
PLATINUM_SPEED = 9.75
GOLD_SPEED = 9.8
LEAD_SPEED = 10.35
GRISIUM_SPEED = 11.2
PLUTONIUM_SPEED = 12.15
AMERICIUM_SPEED = 12.25
NETHER_STAR_SPEED = 12.25
HASTELLOY_C276_SPEED = 14.4
TRITANIUM_SPEED = 16.15
NAQUADAH_SPEED = 16.5
OMNIUM_SPEED = 18.2
NITINOL_60_SPEED = 19.2
SHIRABON_SPEED = 37.5
NEUTRONIUM_SPEED = 5 * LUV_SPEED
INFINITY_SPEED = 4.9 * UV_SPEED
TRANSCENDENT_METAL_SPEED = 4.9 * UHV_SPEED
MELLION_SPEED = 4.9 * UEV_SPEED
CREON_SPEED = 4.9 * UEV_SPEED
SPACETIME_SPEED = 4.9 * UEV_SPEED
ETERNITY_SPEED = 4.9 * UMV_SPEED
UNIVERSIUM_SPEED = 4.9 * UMV_SPEED
HYPOGEN_SPEED = 24.55 * UIV_SPEED