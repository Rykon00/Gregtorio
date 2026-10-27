# Audit: GTNH basic machines Gregtorio lacks (issue #155)

State of 2026-10-06. GTNH is GT5-Unofficial fa916718 (paths relative to its `src/main/java`; `LMTE` =
`gregtech/loaders/preload/LoaderMetaTileEntities.java`, `PR` = `gregtech/loaders/postload/recipes/`, `OP` =
`gregtech/loaders/oreprocessing/`). Gregtorio is main ac1a021, read from `devcheck.py check --balance-out`. Audit only:
no game change. The verdicts are proposals until the maintainer accepts them (#155).

Update of 2026-10-11 (issue #250): every verdict is decided. The table keeps the state of 2026-10-06 in the column "In
Gregtorio today"; the verdict column says how each one ended (see also the list at the end).

Verdicts: **add** (the machine, its tiers, the recipes that move to it and the new ones), **leave** (Gregtorio's
adaptation, with the reason), **n/a** (a Minecraft utility or a machine without a Factorio counterpart).

| GTNH machine (name, tiers) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Arc Furnace ("Basic Arc Furnace", LV to UMV, LMTE:7293) | `arcFurnaceRecipes`: PR/ArcFurnaceRecipes.java (52, scrapping of casings and pipelines) and the generated recycling of every material part (`GTRecipeRegistrator.java:384-390`, with oxygen, argon or nitrogen plasma variants, `GTRecipeConstants.java:332-380`) | annealed copper (copper + oxygen, `MaterialsInit.java:524, 2294`), magnetic metals back to their metal, recycling parts into ingots | no machine; annealed copper ingot from the MV electric blast furnace and the MV fluid solidifier; no part recycling | **add** (annealed copper moves to it from the EBF; the recycling family is optional and large): done, #171; the recycling came with #190 |
| Plasma Arc Furnace (LV to UMV, LMTE:7632-7639) | none of its own: `@Deprecated`, it runs `arcFurnaceRecipes` | as the arc furnace | none | **leave** (deprecated in GT; the arc furnace covers it) |
| Forming Press ("Basic Forming Press", LV to UMV, LMTE:5229) | PR/FormingPressRecipes.java (30: AE2 printed processors, BuildCraft chipsets, coins, food, sawblades, casings), tool heads (OP/ProcessingToolHead.java:1185) | AE2's printed processors (me-network's processors), tool heads | none; IV has the Industrial Material Press, which runs the bending machine recipes (101) | **add, after a check of me-network's processor recipes** (the printed circuits are AE2's; whether they go through a press in Gregtorio is a question for the compat file): done, #173 |
| Forge Hammer ("Basic Forge Hammer", LV to UMV, LMTE:5388) | PR/ForgeHammerRecipes.java (19: stone to cobble to gravel to sand, glass to dust); generated: 3 ingots -> 2 plates (OP/ProcessingIngot.java:110-116), gems, ore -> crushed, crushed/purified/centrifuged -> dust | plates in the steam age, gravel and sand, ore crushing without a macerator | only the Steam Forge Hammer: `lv-forge-hammer-recipes`, 6 ingot -> plate recipes; no electric hammer, no sand/gravel or ore recipes | **add** (the electric tiers for the existing category; GT's 3 -> 2 plate ratio and the stone, ore and gem families as new recipes): done, #170; ore and gem crushing with the ore chain (#188, #202) |
| Sifting Machine ("Basic Sifting Machine", LV to UMV, LMTE:6841) | PR/SifterRecipes.java (3); generated: purified crushed gem ores -> exquisite/flawless/gem/... chances (OP/ProcessingCrushedOre.java:80-122) | gems from gem ores | `lv-sifter-recipes` (5: coal, diamond, and three steps of the bartworks platinum line, which GTNH runs in the sifter too), only in the HV multiblock Large Sifter | **add** (the basic machine LV up for the category; the gem ore recipes belong to the ore chain decision below): done, #175; gem sifting with the ore chain (#188) |
| Electromagnetic Separator ("Basic Electromagnetic Separator", LV to UMV, LMTE:4629) | PR/ElectromagneticSeparatorRecipes.java (2); generated: pure dusts of `ELECTROMAGNETIC_SEPERATION_*` materials -> dust + gold, iron or neodymium (OP/ProcessingDust.java:406-447) | magnetic byproducts of the ore chain (neodymium early) | none (`electromagnetics` is Space Age's electromagnetic plant; the IV Magnetic Flux Exhibitor runs the polarizer) | **ore chain decision**: GTNH's chain (#176), the separator came with #187 |
| Thermal Centrifuge ("Basic Thermal Centrifuge", LV to UMV, LMTE:7000) | PR/ThermalCentrifugeRecipes.java (4); generated: purified -> centrifuged + byproduct (OP/ProcessingCrushedOre.java:61-79), crushed / impure dust (OP/ProcessingDirty.java:110-126) | the third ore step and its byproducts | none: Gregtorio's ore chain has raw ore, crushed ore and dust only | **ore chain decision**: GTNH's chain (#176), the thermal centrifuge came with #185 |
| Brewery ("Basic Brewery", LV to UMV, LMTE:1908-1939) | PR/BreweryRecipes.java (56: lubricant from talc/soapstone/redstone + creosote, potions, biomass from fertilizer + water) | lubricant early, biomass | none; biomass from the pyrolyse oven, lubricant from the LV chemical reactor | **leave for now** (potions n/a; lubricant and biomass have Gregtorio sources; revisit with #165, the plants). Revisited in #360 (2026-10-15): **add**, done: the Brewery LV to MAX with GT's lubricant (talc, soapstone or redstone with creosote, seed oil or crude oil) and biomass (bio chaff) recipes |
| Fermenter ("Basic Fermenter", LV to UMV, LMTE:2747) | PR/FermenterRecipes.java (36: biomass -> fermented biomass, potion ferments) | fermented biomass for ethanol and methanol lines | none; no fermented biomass, ethanol from biomass in the distillery | **leave for now** (same as the brewery: the bio line has its own shape; revisit with #165). Revisited in #360: **add**, done: the Fermenter LV to MAX, fermented biomass and its distillery and tower recipes |
| Fluid Heater ("Basic Fluid Heater", LV to UMV, LMTE:3221) | PR/FluidHeaterRecipes.java (9: water -> steam, acetone -> ethenone, calcium acetate -> acetone, sodium -> liquid sodium, sterilised media) and the bauxite chain | single heating steps of chemical lines | none; Gregtorio merges GT's heater step into the next recipe (as 142's glue line does) | **leave** (Gregtorio's documented adaptation: no fluid heater; a heater step is merged into the next step) |
| Fluid Canner ("Basic Fluid Canner", LV to UMV, LMTE:2902-2905) | `cannerRecipes`: PR/FluidCannerRecipes.java (10: batteries filled with redstone, mercury, sulfuric acid), every fluid container fill (GTPostLoad.java:111-141) and PR/CannerRecipes.java. **The Canning Machine runs the same map**: "Basic Canning Machine" (LMTE:7792-7803) has `setRecipes(cannerRecipes)` and `setFluidSlots(true, true)`; the two maps were merged in GT5-Unofficial's RecipeMap refactor (#2345) | fluid cells, batteries | the Canning Machine (`lv-canning-machine-recipes`) runs the fluid cell fills, the battery fill, the fuel rods and (#452) the water bucket, as GTNH's Canning Machine does | **leave** (corrected 2026-10-06, #169 closed: in GTNH the Canning Machine fills fluid cells itself; the Fluid Canner is a second machine on the same recipe map, so nothing runs in the wrong machine) |
| Fluid Extractor | `fluidExtractionRecipes` | melts | part of the Extractor | **#152** (pull request #167) |
| Electric Furnace ("Basic Electric Furnace", LV to UMV, LMTE:4319) | `furnaceRecipes` (vanilla smelting) | smelting with power | `smelting` (89 recipes) in the stone, iron and steel furnaces (burner), and the Multi Smelter | **add, small** (an electric tier of the smelting category; the Multi Smelter is the multiblock of GT's): done, #174 |
| Electric Oven (LV to IV, LMTE:6207), Microwave (LV to UMV, LMTE:6060) | `furnaceRecipes` / `microwaveRecipes` | Minecraft food | none | **n/a** |
| Packager and Unpackager (LV to UV, LMTE:1766, 1134) | PR/PackagerRecipes.java (5) and generated dust/wire packing | tiny and small dusts, scrapboxes | none: Gregtorio has no tiny or small dusts | **leave** (nothing to pack). Since #223 and #227 Gregtorio has tiny and small piles of dust; 9 tiny or 4 small piles make a dust at the crafting table, so the verdict stands |
| Scanner (LV to UMV, LMTE:1734) | fake map; logic in ScannerHandlerLoader.java:43-87 (data sticks, assembly line research, prospecting) | the research of the assembly line recipes | none: research is Factorio's technology tree | **leave** |
| Mass Fabricator (LV to IV), Replicator (LV to UMV), Amplifabricator (LV to UMV) | `massFabFakeRecipes`, `replicatorRecipes`, `amplifierRecipes` (PR/MatterAmplifierRecipes.java) | UU-matter | none at the audit: UU matter was not built (#36, docs/ROADMAP.md); since #355 step 4 the LuV mass fabricator (`luv-mass-fabricator`, `164-fork-chemistry.lua` section 30) makes UU matter for the beamline | **leave** for the other tiers, the replicator and the amplifabricator (the LuV one is built) |
| Recycler (LV to UMV, LMTE:6694) | `recyclerRecipes`: any item -> scrap at 12.5 % | scrap for the amplifabricator | Factorio's recycler (`recycler`, `scrap-recycling`, Space Age) | **leave** (no UU matter, so no use for scrap) |
| Printer (LV to UV, LMTE:6580) | PR/PrinterRecipes.java (5, squid ink: punch cards, pages, books) | Minecraft items | none | **n/a** |
| Miner ("Basic Miner" LV, "Good Miner" MV, "Advanced Miner" HV; `MTEMiner`, LMTE `MINER_LV` to `MINER_HV`) | no recipe map: mines the ore blocks around it with mining pipes | early automatic ore mining | **exists** (#337): `lv-miner`, `mv-miner`, `hv-miner` in `prototypes/163-fork-electric-mine.lua`, a twin `miner-<vein>` of every Manual Mine vein recipe that uses up 1 mining pipe (#393) | **done** |
| Pump, Monster Repellator, World Accelerator, Electric Jukebox | no recipe map (own behaviour, LMTE:1945-2175) | Minecraft utilities | Factorio's offshore pumps | **n/a** |
| Battery Buffer ("%s Battery Buffer", 1, 4, 9, 16 slots, ULV to MAX; `MTEBasicBatteryBuffer`) | none (it charges and discharges batteries) | energy storage before the supercapacitor | none before the IV Lapotronic Supercapacitor | **done** LV to HV (#444, 145 section 8: accumulators of a fixed size with the tier's lithium batteries in the recipe, the maintainer's decision; GT's Small/Medium/Large Cadmium, Lithium and Sodium Batteries and hulls) |
| Steam age ("Steam Furnace", the "High Pressure Steam ..." machines, "Large Coal Boiler", "Reinforced Lava Boiler", "Simple" and "Advanced Solar Boiler"; `MTESteamFurnaceBronze/Steel`, `MTEBasicMachineSteel`, `MTEBoilerSteel/Lava/Solar`) | furnace recipes; the bronze machines' maps | the second steam tier, smelting with steam, more steam | the bronze machines and the Small Coal Boiler only | **done** (#446, 101 section 2m; the solar boilers stop at night, `scripts/fork-steam-boilers.lua`; GT's calcification left out) |
| Combustion Generator ("Basic Combustion Generator", LV, 95 %; LMTE `registerCombustionGenerators`) | burns combustion fuels | early power from fuels | MV to HV only (`mv-combustion-generator` in `14-mv-age-entity.lua`) | **done** (#449): `lv-combustion-generator` (101, 95 %), with Fermentation and its Bio Diesel Cell; upgrade to MV |
| Extruder ("Basic Extruder", LV; LMTE `EXTRUDER_LV`) | `extruderRecipes` (OP/ProcessingShaping.java: 8 x 15 = 120 EU/t for a metal, so MV; LV only for `NO_SMASHING` materials and the aluminium rod) | plates, rods, gears from ingots | MV and up (`mv-extruder-recipes`) | **done** (#449): `lv-extruder` (101) on the upstream category `lv-extruder-recipes`, which the MV and higher extruders run too; its one recipe is GT's aluminium rod (2 per ingot), with Aluminium |
| Precision Laser Engraver ("Basic Precision Laser Engraver", LV; LMTE `LASER_ENGRAVER_LV`) | `laserEngraverRecipes`: chipped -> flawed gems (LV, OP/ProcessingGem.java:313-318), ULPIC wafers (LV, PR/LaserEngraverRecipes.java:362-367), the rest MV and up | wafers, gem grades | MV and up (`mv-laser-engraver-recipes`) | **done** (#449): `lv-laser-engraver` (101) on `lv-laser-engraver-recipes` (the chipped gem step, the ULPIC wafer), which the MV and higher engravers run too; with Circuit Assembler |

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

Decided (2026-10-06, #176): GTNH's full chain, planned in `docs/ORE-CHAIN.md` and built in #185 to #188
(`prototypes/155-fork-ore-chain.lua`): purified, centrifuged, impure and pure forms, the thermal centrifuge, chemical bath
washing, the electromagnetic separator and gem sifting. The paragraph "Gregtorio: ..." above is the state before.

## Machines the first audit missed (issue #367)

State of 2026-10-15: GT5-Unofficial 638b3f37ca, Gregtorio 0.5.4. GT++'s and bartworks' single-block machines and
generators that had no row. Gregtorio's fluids are a tenth of GT's litres and 1 EU = 1 kJ (`docs/ROADMAP.md`).

| GTNH machine (name, tiers) | GT recipe or fuel map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Bio Lab ("Basic Bio Lab", bartworks, `bartworks/common/tileentities/tiered/MTEBioLab.java`) | `bw.recipe.biolab`: 8 culture incubations, each with water and with distilled water (`bartworks/common/loaders/BioRecipeLoader.java:46-123`), plus DNA extraction, plasmid synthesis and transformation from the cultures (`MTEBioLab.java`) | the cultures in petri dishes that the Bacterial Vat needs as its "special" item (wine yeast, anaerobic oil bacteria, ...) | the Bacterial Vat runs its four recipes on fluids alone (growth medium -> bacterial sludge -> enriched sludge -> mutagen), "No petri dishes" (`125-fork-luv-endgame.lua:365-370`); GTNH's stem cells come from a chemical reactor recipe (`gregtech/loaders/postload/recipes/ChemicalRecipes.java:145-152`), not from the Bio Lab, and Gregtorio's stand-in for its GalaxySpace crystal is documented at `128-fork-uhv.lua:222-225` | **leave** (it only breeds the cultures of a vat mechanic Gregtorio left out; nothing Gregtorio makes depends on a culture) |
| Basic, Turbo and Vulcan Geothermal Engine (GT++, EV, IV, LuV; `gtPlusPlus/xmod/gregtech/common/tileentities/generators/MTEGeothermalGenerator.java`, `.../registration/gregtech/GregtechGeothermalThermalGenerator.java`) | `hotFuels`: lava 32 EU/L, pahoehoe lava 24, pyrotheum and cryotheum dust 62 (`gtPlusPlus/core/recipe/RecipesGregTech.java:1538-1577`); efficiency 100 - 7 x tier (72 % at EV) | power from lava | lava is endless from the drilling rigs (the MV rig: 50 lava/s for 640 kW, 12.8 kJ per unit); no pahoehoe lava, pyrotheum or cryotheum. GT's value is 320 kJ per Gregtorio unit, so one EV engine would make about 11.5 MW from one MV rig's 640 kW | **leave** (power from almost nothing, the reason of the Thermal Boiler, Deep Earth Heating Pump and heat exchanger rows: `docs/ROADMAP.md`, "No lava recipe") |
| Radioisotope Thermoelectric Generator (GT++, HV; `gtPlusPlus/xmod/gregtech/common/tileentities/generators/MTERTGenerator.java`) | `rtgFuels`: 5 pellets (Pu-238, Sr-90, Po-210, Am-241, IC2's RTG pellet), duration in Minecraft days (`gtPlusPlus/xmod/gregtech/common/items/MetaGeneratedGregtechItems.java:344-380`) | slow, long-lasting power | no pellets and no Pu-238, Sr-90 or Po-210; GT++ makes the pellets only in the COMET Cyclotron (`gtPlusPlus/core/recipe/RecipesGregTech.java:1770-1815`), which is n/a in `docs/MULTIBLOCK-AUDIT.md` (deprecated in GTNH, no controller recipe) | **n/a** (its fuel has no source in GTNH outside the deprecated cyclotron) |
| Cold Trap I/II and Reactor Processing Unit I/II (GT++, IV and ZPM; `gtPlusPlus/xmod/gregtech/registration/gregtech/GregtechLFTR.java`) | `coldTrapRecipes`, `reactorProcessingUnitRecipes` (`gtPlusPlus/xmod/gregtech/loaders/recipe/RecipeLoaderNuclearFuelProcessing.java`); the Nuclear Salt Processing Plant's map is generated from them (`gtPlusPlus/GTplusplus.java:160-162`) | the burnt salt of the LFTR back to fluorides, uranium hexafluoride, U-233 and phosphorus | Cold Trap I and Reactor Processing Unit I with GT++'s recipes (issue #386 step 3, 164 section 15) | **built** (I); the II tiers are left: their Pikyonium needs ytterbium, issue #406 |
| Simple Washer I to VIII (GT++, ULV up; `gtPlusPlus/xmod/gregtech/registration/gregtech/GregtechSimpleWasher.java`) | `simpleWasherRecipes`: crushed ore -> purified crushed ore, impure and pure dust -> dust, 100 L water, 5 ticks, no byproduct (`GregtechSimpleWasher.java:100-196`); the Ore Washing Plant runs the map too | a cheap washer without byproducts | the ore washer (crushed -> purified with GTNH's byproduct, `155-fork-ore-chain.lua`), the centrifuge and the furnaces for impure and pure dust | **leave** (a byproduct-free shortcut of steps Gregtorio's ore chain already has; devcheck's ore chain check forbids washer shortcuts) |

## Issues opened for "add" verdicts

All closed; the verdicts are decided:

- ~~#169 Fluid Canner~~: closed as not planned, the verdict was wrong (see its row)
- #170 electric Forge Hammer, LV to MAX: done
- #171 Arc Furnace, LV to MAX (annealed copper, recycling): done
- #173 Forming Press: done
- #174 Electric Furnace: done
- #175 Sifting Machine from LV: done
- #176 the ore chain: GTNH's full chain, built in #185 to #188 (`docs/ORE-CHAIN.md`)
- #367 (the machines the first audit missed): no "add" verdict, so no new issue

The multiblocks are audited in `docs/MULTIBLOCK-AUDIT.md` (#246, #257).
