# Audit: GTNH basic machines Gregtorio lacks (issue #155)

State of 2026-10-06. GTNH is GT5-Unofficial fa916718 (paths relative to its `src/main/java`; `LMTE` =
`gregtech/loaders/preload/LoaderMetaTileEntities.java`, `PR` = `gregtech/loaders/postload/recipes/`, `OP` =
`gregtech/loaders/oreprocessing/`). Gregtorio is main ac1a021, read from `devcheck.py check --balance-out`. Audit only:
no game change. The verdicts are proposals until the maintainer accepts them (#155).

Verdicts: **add** (the machine, its tiers, the recipes that move to it and the new ones), **leave** (Gregtorio's
adaptation, with the reason), **n/a** (a Minecraft utility or a machine without a Factorio counterpart).

| GTNH machine (name, tiers) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Arc Furnace ("Basic Arc Furnace", LV to UMV, LMTE:7293) | `arcFurnaceRecipes`: PR/ArcFurnaceRecipes.java (52, scrapping of casings and pipelines) and the generated recycling of every material part (`GTRecipeRegistrator.java:384-390`, with oxygen, argon or nitrogen plasma variants, `GTRecipeConstants.java:332-380`) | annealed copper (copper + oxygen, `MaterialsInit.java:524, 2294`), magnetic metals back to their metal, recycling parts into ingots | no machine; annealed copper ingot from the MV electric blast furnace and the MV fluid solidifier; no part recycling | **add** (annealed copper moves to it from the EBF; the recycling family is optional and large) |
| Plasma Arc Furnace (LV to UMV, LMTE:7632-7639) | none of its own: `@Deprecated`, it runs `arcFurnaceRecipes` | as the arc furnace | none | **leave** (deprecated in GT; the arc furnace covers it) |
| Forming Press ("Basic Forming Press", LV to UMV, LMTE:5229) | PR/FormingPressRecipes.java (30: AE2 printed processors, BuildCraft chipsets, coins, food, sawblades, casings), tool heads (OP/ProcessingToolHead.java:1185) | AE2's printed processors (me-network's processors), tool heads | none; IV has the Industrial Material Press, which runs the bending machine recipes (101) | **add, after a check of me-network's processor recipes** (the printed circuits are AE2's; whether they go through a press in Gregtorio is a question for the compat file) |
| Forge Hammer ("Basic Forge Hammer", LV to UMV, LMTE:5388) | PR/ForgeHammerRecipes.java (19: stone to cobble to gravel to sand, glass to dust); generated: 3 ingots -> 2 plates (OP/ProcessingIngot.java:110-116), gems, ore -> crushed, crushed/purified/centrifuged -> dust | plates in the steam age, gravel and sand, ore crushing without a macerator | only the Steam Forge Hammer: `lv-forge-hammer-recipes`, 6 ingot -> plate recipes; no electric hammer, no sand/gravel or ore recipes | **add** (the electric tiers for the existing category; GT's 3 -> 2 plate ratio and the stone, ore and gem families as new recipes) |
| Sifting Machine ("Basic Sifting Machine", LV to UMV, LMTE:6841) | PR/SifterRecipes.java (3); generated: purified crushed gem ores -> exquisite/flawless/gem/... chances (OP/ProcessingCrushedOre.java:80-122) | gems from gem ores | `lv-sifter-recipes` (5: coal, diamond, and three steps of the bartworks platinum line, which GTNH runs in the sifter too), only in the HV multiblock Large Sifter | **add** (the basic machine LV up for the category; the gem ore recipes belong to the ore chain decision below) |
| Electromagnetic Separator ("Basic Electromagnetic Separator", LV to UMV, LMTE:4629) | PR/ElectromagneticSeparatorRecipes.java (2); generated: pure dusts of `ELECTROMAGNETIC_SEPERATION_*` materials -> dust + gold, iron or neodymium (OP/ProcessingDust.java:406-447) | magnetic byproducts of the ore chain (neodymium early) | none (`electromagnetics` is Space Age's electromagnetic plant; the IV Magnetic Flux Exhibitor runs the polarizer) | **ore chain decision** |
| Thermal Centrifuge ("Basic Thermal Centrifuge", LV to UMV, LMTE:7000) | PR/ThermalCentrifugeRecipes.java (4); generated: purified -> centrifuged + byproduct (OP/ProcessingCrushedOre.java:61-79), crushed / impure dust (OP/ProcessingDirty.java:110-126) | the third ore step and its byproducts | none: Gregtorio's ore chain has raw ore, crushed ore and dust only | **ore chain decision** |
| Brewery ("Basic Brewery", LV to UMV, LMTE:1908-1939) | PR/BreweryRecipes.java (56: lubricant from talc/soapstone/redstone + creosote, potions, biomass from fertilizer + water) | lubricant early, biomass | none; biomass from the pyrolyse oven, lubricant from the LV chemical reactor | **leave for now** (potions n/a; lubricant and biomass have Gregtorio sources; revisit with #165, the plants) |
| Fermenter ("Basic Fermenter", LV to UMV, LMTE:2747) | PR/FermenterRecipes.java (36: biomass -> fermented biomass, potion ferments) | fermented biomass for ethanol and methanol lines | none; no fermented biomass, ethanol from biomass in the distillery | **leave for now** (same as the brewery: the bio line has its own shape; revisit with #165) |
| Fluid Heater ("Basic Fluid Heater", LV to UMV, LMTE:3221) | PR/FluidHeaterRecipes.java (9: water -> steam, acetone -> ethenone, calcium acetate -> acetone, sodium -> liquid sodium, sterilised media) and the bauxite chain | single heating steps of chemical lines | none; Gregtorio merges GT's heater step into the next recipe (as 142's glue line does) | **leave** (Gregtorio's documented adaptation: no fluid heater; a heater step is merged into the next step) |
| Fluid Canner ("Basic Fluid Canner", LV to UMV, map `cannerRecipes` at LMTE:2905) | PR/FluidCannerRecipes.java (10: batteries filled with redstone, mercury, sulfuric acid); generated: every fluid container fill (GTPostLoad.java:111-141) | fluid cells, batteries | the Canning Machine (`lv-canning-machine-recipes`) runs 19 fluid cell fills (benzene, diesel, gasoline, ... cells), the battery fill and the fuel rods | **add** (as #152 did for the extractor: the fluid fills move to a Fluid Canner, the canning machine keeps the item recipes) |
| Fluid Extractor | `fluidExtractionRecipes` | melts | part of the Extractor | **#152** (pull request #167) |
| Electric Furnace ("Basic Electric Furnace", LV to UMV, LMTE:4319) | `furnaceRecipes` (vanilla smelting) | smelting with power | `smelting` (89 recipes) in the stone, iron and steel furnaces (burner), and the Multi Smelter | **add, small** (an electric tier of the smelting category; the Multi Smelter is the multiblock of GT's) |
| Electric Oven (LV to IV, LMTE:6207), Microwave (LV to UMV, LMTE:6060) | `furnaceRecipes` / `microwaveRecipes` | Minecraft food | none | **n/a** |
| Packager and Unpackager (LV to UV, LMTE:1766, 1134) | PR/PackagerRecipes.java (5) and generated dust/wire packing | tiny and small dusts, scrapboxes | none: Gregtorio has no tiny or small dusts | **leave** (nothing to pack) |
| Scanner (LV to UMV, LMTE:1734) | fake map; logic in ScannerHandlerLoader.java:43-87 (data sticks, assembly line research, prospecting) | the research of the assembly line recipes | none: research is Factorio's technology tree | **leave** |
| Mass Fabricator (LV to IV), Replicator (LV to UMV), Amplifabricator (LV to UMV) | `massFabFakeRecipes`, `replicatorRecipes`, `amplifierRecipes` (PR/MatterAmplifierRecipes.java) | UU-matter | none: UU matter is not built (#36, docs/ROADMAP.md) | **leave** (follows the UU matter decision) |
| Recycler (LV to UMV, LMTE:6694) | `recyclerRecipes`: any item -> scrap at 12.5 % | scrap for the amplifabricator | Factorio's recycler (`recycler`, `scrap-recycling`, Space Age) | **leave** (no UU matter, so no use for scrap) |
| Printer (LV to UV, LMTE:6580) | PR/PrinterRecipes.java (5, squid ink: punch cards, pages, books) | Minecraft items | none | **n/a** |
| Miner, Pump, Monster Repellator, World Accelerator, Electric Jukebox | no recipe map (own behaviour, LMTE:1945-2175) | Minecraft utilities | Factorio's mining drills and offshore pumps | **n/a** |

## The ore chain (one decision for the thermal centrifuge, the sifter, the electromagnetic separator and the ore washer's byproducts)

GTNH (registered per ore dictionary prefix by `OP/Processing*.java`):

1. ore or raw ore -> crushed ore (macerator or hammer; OP/ProcessingOre.java:234, 265);
2. crushed ore -> **purified** crushed ore + a byproduct dust (ore washer; OP/ProcessingDirty.java:70-108), or the chemical
   bath with mercury or sodium persulfate for a doubled `WASHING_*` byproduct (OP/ProcessingDirty.java:138-190);
3. crushed or purified -> **centrifuged** ore + byproduct (thermal centrifuge; OP/ProcessingDirty.java:110-126,
   OP/ProcessingCrushedOre.java:61-79);
4. any of them -> **impure / pure dust** or dust (macerator or hammer; OP/ProcessingCrushedOre.java:37-59,
   OP/ProcessingPure.java:36-58);
5. impure and pure dust -> dust + byproduct (centrifuge; OP/ProcessingDust.java:448-569), crystallisable ones through the
   autoclave;
6. purified gem ores -> gems (sifter); pure dusts of magnetic ores -> byproduct (electromagnetic separator).

Gregtorio: raw ore -> crushed ore (macerator) -> dust (the ore washer: crushed + water -> dust, 64 recipes; the
centrifuge: `centrifuging-crushed-*`, with byproducts). No purified, centrifuged, impure or pure forms.

Adding GTNH's steps means about four new item forms for each of the ~69 crushed ores (several hundred items and recipes),
byproduct tables per ore, three new machines (thermal centrifuge, sifting machine, electromagnetic separator, LV up) and a
rework of the ore washer and centrifuge recipes, with old saves full of crushed ore. Proposal: **decide this one
separately** (keep Gregtorio's short chain, or GTNH's full chain as a project of its own); until then the three machines
stay out, except the sifter for the recipes it already has.

## Issues opened for "add" verdicts

- #169 Fluid Canner (the fluid cell fills out of the Canning Machine)
- #170 electric Forge Hammer, LV to MAX
- #171 Arc Furnace, LV to MAX (annealed copper, recycling)

Not opened yet, waiting for the maintainer: the Forming Press (after a look at me-network's processor recipes), the
Electric Furnace, the basic Sifting Machine and the ore chain decision. Each verdict is a proposal until the maintainer
accepts it.
