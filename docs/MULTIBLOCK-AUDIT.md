# Audit: GTNH multiblocks Gregtorio lacks (issue #246)

State of 2026-10-11:
- GTNH is GT5-Unofficial af993ca6a9. Paths are relative to its `src/main/java`; `LMTE` =
  `gregtech/loaders/preload/LoaderMetaTileEntities.java`, `MRL` = `gregtech/loaders/load/MTERecipeLoader.java`, `PR` =
  `gregtech/loaders/postload/recipes/`. The GTNH core mod is NewHorizonsCoreMod (`core:` + its path).
- Gregtorio is main da645bc, read from the prototypes and from `devcheck.py check --balance-out`; the crafting machines are
  taken from that dump, not from controller names.
- Update of 2026-10-15 (#367, GT5-Unofficial 638b3f37ca, Gregtorio 0.5.4): the Large Rocket Engine row (built in #304),
  the Cold Trap and Reactor Processing Unit named in the LFTR row, the Industrial Coke Oven's own recipes.
- This is the companion of `docs/MACHINE-AUDIT.md` (#155, the basic machines). Audit only: no game change. The verdicts are
  proposals until the maintainer accepts them.

Verdicts:
- **add**: it closes a visible gap of a Gregtorio line.
- **leave**: Gregtorio's adaptation or another machine covers it; the reason is given.
- **n/a**: a Minecraft utility, or a machine without a Factorio counterpart.

Many GTNH multiblocks are a parallel ("mega", "industrial") version of a machine whose recipe map they share. In Factorio
throughput comes from building more machines, so such a multiblock only gets **add** when it brings recipes of its own or
fills a gap.

## The issue's list, checked

Two premises of the issue did not hold:
- **Water purification:** Gregtorio has no clarifier, flocculation or ozonation controllers. They exist only in the
  commented-out draft of `21-luv-age-item.lua` (lines 1184-1869). The live game has one `water-purification-plant` with a
  recipe per grade (`129-fork-water-purification.lua`).
- **Mining:** Gregtorio has no Factorio ore patches. `102-fork-resources.lua` disables every resource, crude oil included,
  and ores come from vein recipes, the dimension mines and the Void Miners (the microminers went in #287).

### Power

| GTNH multiblock (name, tier, class) | GT recipe or fuel map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Large Titanium Boiler (EV controller recipe, MRL:3436-3440; `.../multi/MTELargeBoilerTitanium.java`, LMTE:921; legacy class LMTE:451) | `largeBoilerFakeFuels` (display only): solid fuels at furnace value / 80, liquid fuels via the diesel, gas and dense fuel maps (`MTELargeBoilerBase.java:331-336`, `LargeBoilerFuelBackend.java`) | coal, wood or fuel to **superheated steam** (`SUPERHEATED = true`, 4800 EU/t, `MTELargeBoilerTitanium.java:10-12`, `MTELargeBoilerBase.java:408-411`) | nothing. The large bronze and steel boilers make steam. Superheated steam comes only from the IV Large Heat Exchanger on hot coolant (`145-fork-power-multiblocks.lua:192`), which comes with Fluid Nuclear Reactor. That technology needs High Pressure Steam Turbine, so the turbine that burns only superheated steam has no fuel when it is researched | **add** (a fuel-fired source of superheated steam at EV) |
| Large Tungstensteel Boiler (`.../multi/MTELargeBoilerTungstenSteel.java`, LMTE:924; controller MRL:3441-3445) | as the titanium boiler | superheated steam at 19,200 EU/t | nothing | **leave** (the titanium boiler at four times the rate, no new fuel or fluid; a fast-replace upgrade if the titanium boiler is added) |
| Large Combustion Engine (EV hull, IV circuits, MRL:3774; `.../multi/MTELargeCombustionEngine.java`, LMTE:1068) | `dieselFuels` (`MTELargeCombustionEngine.java:190`), from the materials' fuel values (`gregtech/loaders/oreprocessing/ProcessingCell.java:52-61`) | 2048 EU/t from diesel, cetane-boosted diesel, gasoline and high octane gasoline (`:118, 202`), 3x output with oxygen, lubricant upkeep | the MV and HV combustion generators (`14-mv-age-entity.lua:266`, `16-hv-age-entity.lua:108`), burner generators on fuel cells (fuel values in `147-fork-gt-routes.lua:243`); nothing at EV | **add** (the liquid fuel line stops at HV, its best fuels have no EV engine) |
| Extreme Combustion Engine (IV; `.../multi/MTEExtremeCombustionEngine.java`, LMTE:1073) | `extremeDieselFuels` (fuels of 1500 EU/L and more) | 10,900 EU/t from high octane gasoline and goodgenerator's ironed fuels | nothing; high octane gasoline burns in the MV and HV combustion generators | **leave** (IV power has the HP steam turbine and the nuclear chain; a fast-replace upgrade of the Large Combustion Engine later if wanted) |
| Large Neutralization Engine (EV/IV, MRL:3859-3863; `.../multi/MTELargeNeutralizationEngine.java`, LMTE:718) | bartworks `acidGenFuels` (`bartworks/system/material/processingLoaders/AdditionalRecipes.java:250-289`) | burns acids, boosted by alkali dusts, explodes on residue | nothing; no acid generator at any tier | **leave** (a new fuel category and mechanic without a single-block line in Gregtorio; a side path, not a gap) |
| Large Gas Turbine (EV hull, EV circuits, MRL:3598-3604; `.../multi/turbines/MTELargeTurbineGas.java`, LMTE:945) | `gasTurbineFuels` (`MTELargeTurbineGas.java:110`): benzene, methane, refinery gas, LPG and the GoodGenerator and GT++ gases | rotor-dependent output, above 100 % with good rotors | `lv-`, `mv-` and `hv-gas-turbine` (`12-lv-age-entity.lua:210`, `14-mv-age-entity.lua:244`, `16-hv-age-entity.lua:86`), burner generators on gas cells; nothing at EV | **add** (the gas line stops at HV; a fixed-rotor EV turbine as 145 builds the large steam turbines) |
| XL Turbo Steam, HP Steam, SC Steam, Gas and Plasma Turbine (`.../multi/xlturbines/MTEXLTurbine*.java`, LMTE:986-1000; GT++ legacy classes) | the gas and plasma fuel maps; steam, HP and SC steam fixed | 16 large turbines in one (`MTEXLTurbineBase.java:746-747`) | the large steam, HP steam and plasma turbines (145, 136); no supercritical steam | **leave** (more turbines do the same in Factorio; `docs/ROADMAP.md` already decides against the XL plasma turbine) |

### Circuits and electronics

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Cleanroom (`.../multi/MTECleanroom.java`, LMTE:589) | no map: recipes carry a cleanroom flag (`gregtech/api/util/GTRecipeBuilder.java:751`), about 100 circuit assembler, laser engraver and chemical recipes | a room of plascrete and filter casings around the machines | nothing live: the `cleanroom-tile` item and the `cleanroom` technology are commented out (`15-hv-age-item.lua:834-855`, `98-technology.lua:2842-2865`) | **leave** (a sealed room is a Minecraft structure and makes nothing; follow-up for the leftovers below) |
| PCB Factory with Bio Chamber and Cooling Tower (UV; `.../multi/pcb/MTEPCBFactory.java`, LMTE:596-601) | `pcbFactoryRecipes`, `gregtech/loaders/postload/chains/PCBFactoryRecipes.java` | circuit boards in bulk, plastic to optical; the boards up to bioware also come from GT's chemical reactor (`core:gthandler/recipes/ChemicalReactorRecipes.java`), the optical board only from here | every board exists: plastic to multilayer fiber in `lv-chemical-reactor-recipes` (GT's reactor route), wetware, bioware and optical boards as assembling machine recipes (`128-fork-uhv.lua:248`, `131-fork-uev.lua:334`, `132-fork-uiv.lua:194`) | **leave** (a throughput machine; its one exclusive board has a Gregtorio recipe) |
| Nanochip Assembly Complex and its eleven modules (UHV and up; `.../multi/nanochip/MTENanochipAssemblyComplex.java`, LMTE:740-828) | eleven `nanochip*` maps, all filled by `core:scripts/ScriptNanochipRecipes.java` | circuits from "circuit components"; only here: the Piko (UMV), Quantum (UXV) and Planck (MAX) circuits | the UMV, UXV and MAX circuits have Gregtorio lines (exotic `133-fork-umv.lua`, temporal `134-fork-uxv.lua`, Planck `141-fork-max.lua`) | **leave** (its products have working lines; the module logistics would be a whole new system) |
| Electric Air Filter T1 to T3 (LV, HV, IV; `.../multi/MTEAirFilter1-3.java`, LMTE:9312-9318) | no map: removes chunk pollution | GT's pollution | nothing | **leave** (Factorio's pollution is absorbed by the terrain and the evolution of the enemies; a sink would be a gameplay decision of its own) |
| Solar Factory (HV/EV; `.../multi/MTESolarFactory.java`, LMTE:572) | `solarFactoryRecipes`, `core:gthandler/recipes/SolarFactoryRecipes.java` | GT's solar panel covers and irradiant plates | none: solar power is disabled (`data-final-fixes.lua:196, 210`), the solar items exist only in unloaded drafts | **n/a** (machine covers of Minecraft; no circuit depends on them) |

### Chemistry and materials

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Mega Chemical Reactor (LuV; `.../multi/MTEMegaChemicalReactor.java`, LMTE:965) | `multiblockChemicalReactorRecipes` (PR/ChemicalRecipes.java), 256 parallels | the Large Chemical Reactor in bulk | `large-chemical-reactor` HV to MAX | **leave** (parallel version) |
| Mega Distillation Tower (LuV; `.../multi/MTEMegaDistillationTower.java`, LMTE:1102) | `distillationTowerRecipes` and `distilleryRecipes` (PR/DistilleryRecipes.java) | the tower and the distillery in bulk | tall and short distillation towers HV to MAX, the distillery | **leave** (parallel version) |
| Mega Oil Cracker (LuV; `.../multi/MTEMegaOilCracker.java`, LMTE:1106) | `crackingRecipes` | the cracker in bulk | `cracker` HV to MAX | **leave** (parallel version) |
| Mass Solidifier (`.../multi/MTEMassSolidifier.java`, LMTE:623) and Exo-Foundry (`.../multi/foundry/MTEExoFoundry.java`, LMTE:626) | `fluidSolidifierRecipes` (PR/FluidSolidifierRecipes.java); the Exo-Foundry's modules only for overclocking | the fluid solidifier in bulk | `fluid-solidifier` LV to MAX and the IV Fluid Shaper | **leave** (parallel versions) |
| L.A.T.E.X. (`.../multi/MTELatex.java`, LMTE:724) | `cableRecipes` (`gregtech/loaders/oreprocessing/ProcessingWire.java:267`); GT puts the same coatings into the assembler (`:302`) | cable coating | cables in the assembler (`11-lv-age-item.lua:135`) | **leave** (GT's assembler route, the same content) |
| Big Barrel Brewery (`.../multi/MTEIndustrialBrewery.java`, LMTE:675) | `brewingRecipes` (PR/BreweryRecipes.java) | potions; lubricant and biomass | no brewery; lubricant in the LV chemical reactor, biomass from the pyrolyse oven | **n/a** (potions; the useful outputs have Gregtorio routes, as for the basic Brewery in `docs/MACHINE-AUDIT.md`) |
| Industrial 3D Copying Machine (EV; `.../multi/MTEIndustrialChisel.java`, LMTE:855) | `industrialChiselRecipes` from the Chisel mod | decorative block variants | nothing | **n/a** |
| Endothermic Fridge (ZPM; `.../multi/MTEEndothermicFridge.java`, LMTE:1092) and Cryogenic Freezer (IV, GT++; `.../multi/MTECryogenicFreezer.java`, LMTE:869) | `vacuumFreezerRecipes` | the vacuum freezer in bulk (the Fridge is the Mega Vacuum Freezer, the Cryogenic Freezer GT++'s Industrial Vacuum Freezer) | `vacuum-freezer` MV to MAX | **leave** (parallel versions) |
| Exothermic Hearth (ZPM; `.../multi/MTEExothermicHearth.java`, LMTE:1096) | `blastFurnaceRecipes` | the Mega EBF | `electric-blast-furnace` MV to MAX | **leave** (parallel version; Gregtorio's DTPF does not need it) |
| Entropic Processor (`.../multi/MTEEntropicProcessor.java`, LMTE:693) | `entropicProcessing`, filled outside GT5-Unofficial | Thaumcraft alchemy | nothing | **n/a** |
| Dissection Apparatus (`.../multi/MTEIndustrialExtractor.java`, LMTE:646) | `extractorRecipes` | the extractor in bulk | `extractor` LV to MAX (3 item recipes since #152) | **leave** (parallel version) |

### Mining, charcoal and water purification

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Ore Drilling Plant I to IV (MV to IV; `.../multi/MTEOreDrillingPlant1-4.java`, LMTE:552-563) | no map: mines the ore blocks below (`MTEOreDrillingPlantBase.java:845`) with drilling fluid | automatic ore mining, about 3x crushed ore | **exists** (#335): `ore-drilling-plant-mk1` to `-mk4` (MV to IV, `prototypes/163-fork-electric-mine.lua`) on the Manual Mine's footprint, an electric twin `drilling-<vein>` of every vein recipe with Drilling Fluid and 1 mining pipe (#393); Gregtorio still has no ore blocks (the microverse is gone, #287) | **done** (vein recipes instead of ore blocks; ore patches on the map are question #451) |
| Fluid Drilling Rig I to IV and the Infinite Fluid Drilling Rig (MV to IV, UHV; `.../multi/MTEOilDrill1-4.java`, `MTEOilDrillInfinite.java`, LMTE:524-540, 1045-1049) | no map: pumps the chunk's fluid vein (`gregtech/common/UndergroundOil.java`) | oil, gas and salt water fields that run out | **exists**: the drilling rigs MV to MAX (`14-mv-age-entity.lua:1010`, upgrades in `101-fork-machines.lua`), 3 recipes without input that never run out (`13-mv-age-item.lua:1283-1309`) | **leave** (Gregtorio's rig; every tier is already infinite) |
| Concrete Backfiller (MV, EV; `.../multi/MTEConcreteBackfiller1-2.java`, LMTE:542-551) | no map | fills the shafts of the ore drills | nothing | **n/a** |
| Charcoal Pile Igniter (`.../multi/MTECharcoalPit.java`, LMTE:517-521) | no map: turns a pile of placed logs into charcoal | bulk charcoal before power | charcoal in the furnace and multi smelter (`09-steam-age-item.lua:907-927`) and the pyrolyse oven | **n/a** (a structure of placed blocks; the furnace and pyrolyse recipes cover charcoal) |
| Water Purification Plant and its eight units (LuV to UEV; `.../multi/purification/`, LMTE:363-434) | eight `purification*` maps, `gregtech/loaders/postload/chains/PurifiedWaterRecipes.java:52-354` | grade 1 to 8 water, one unit per grade | one `water-purification-plant`, a recipe per grade (`129-fork-water-purification.lua:186-271`) | **leave** (`docs/ROADMAP.md`: "One plant, one recipe per grade, no linkage blocks") |

### Endgame and special

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Large Hadron Collider (UV; `.../multi/beamcrafting/MTELargeHadronCollider.java`, LMTE:700) | `largeHadronColliderRecipes` (PR/beamcrafter/LargeHadronColliderRecipes.java) | particles for the Beam Crafter | nothing | **leave** (it only feeds the Beam Crafter, see there) |
| Beam Crafter (`.../multi/beamcrafting/MTEBeamCrafter.java`, LMTE:706) | `beamcrafterRecipes` (PR/beamcrafter/BeamCrafterRecipes.java) | the quark creation catalysts of grade 8 water, containment units, cosmic solder | the quark creation catalyst is a ZPM assembly line stand-in (`129-fork-water-purification.lua:273-305`); no containment units, no cosmic solder | **leave** (the one product the progression needs has a stand-in; particles would need the whole beamline) |
| Beam Mirror, Splitter, Stabilizer (`.../multi/beamcrafting/`, LMTE:709-714) | none | beam routing | nothing | **n/a** |
| Spinmatron-2737 (`.../multi/MTESpinmatron.java`, LMTE:678) | `centrifugeNonCellRecipes` | a late parallel centrifuge | the centrifuges and the Industrial Centrifuge | **leave** (parallel version) |
| Miniature Wormhole Generator (`.../multi/MTEWormholeGenerator.java`, LMTE:631) | none | moves EU between two linked generators | Factorio's electric network | **n/a** |
| Decay Warehouse (`.../multi/MTEDecayWarehouse.java`, LMTE:696) | `isotopeDecay` (`gtPlusPlus/core/handler/Recipes/DecayableRecipe.java`) | speeds up GT++ isotope decay | no decaying isotopes (they were only in the never loaded `51-nuclear-module.lua`, removed in issue #279) | **n/a** |

## GTNH multiblocks the issue's list missed (issue #257)

A comparison with Gregtorio's machines found about 70 more GTNH multiblocks without a counterpart. It took all
`MTEMultiBlockBase` subclasses of GT5-Unofficial and the `gt.blockmachines.multimachine.*` names. #257 audits them
here, against Gregtorio main 2299e45.

Result: **one add**, the lanthanide chain (#262). Every other multiblock is one of these:
- a parallel version of a machine Gregtorio has;
- a side chain whose metals Gregtorio already makes;
- a generator for a fuel Gregtorio does not have;
- a utility.

### Own recipes: gregtech

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Electric Implosion Compressor (UV; `.../multi/MTEElectricImplosionCompressor.java`, LMTE:1063) | bartworks `electricImplosionCompressorRecipes` (`bartworks/common/loaders/ElectricImplosionCompressorRecipes.java:37-167`, about 31 recipes) | only here: MHDCSM and its parts (UXV/MAX), amalgatite, ancient debris; high-density plutonium also from goodgenerator's compressor | `high-density-plutonium` from 9 nuggets in the compressor (GT's goodgenerator route, `21-luv-age-item.lua:2389`); the EIC draft recipe was removed (`docs/ROADMAP.md`, decision (b)); no MHDCSM | **leave** (its exclusive products are MAX tier or other mods' items) |
| Nano Forge (ZPM; `.../multi/MTENanoForge.java`, LMTE:604) | `nanoForgeRecipes` (`gregtech/loaders/postload/chains/NaniteChain.java:79-275`, 12) | nanites for the BEC, phonon crystal, nano-resins, photonic wafers | no nanite and no live consumer (draft only in the unloaded `25-uv-age-item.lua`) | **built** since issue #355 step 5 (164 section 36): tiers 1 and 2 (carbon and neutronium nanite), neutronium and glowstone nanites for the Photonically Enhanced Wafer; issue #487 (section 39): the transcendent metal nanites and tier 3; tier 3's own nanites and tier 4 left out (no consumer) |
| Froth Flotation Cell (LuV; `.../multi/MTEFrothFlotationCell.java`, LMTE:953) | `flotationCellRecipes` (`gtPlusPlus/core/item/chemistry/RecipeLoaderMilling.java:235-401`, 12) | froths of milled ores, turned into bonus dusts (In, Cd, Co, Te, Pt, rare earths) in the vacuum furnace | no milled ores, xanthate or pine oil; those metals have Gregtorio lines (lutetium is a stand-in kept on purpose, `docs/ROADMAP.md`) | **leave** (a GT++ yield side chain with IsaMill and Utupu-Tanuri, below) |
| Integrated Ore Factory (UV; `.../multi/MTEIntegratedOreFactory.java`, LMTE:1055) | none of its own: the macerator, washer, thermal centrifuge, centrifuge, sifter, hammer and bath maps in one go | all ore steps in one machine | the same steps in Gregtorio's single machines (`155-fork-ore-chain.lua`) | **leave** (parallel version) |
| Molecular Transformer (LuV; `.../multi/MTEIndustrialMolecularTransformer.java`, LMTE:1006) | `molecularTransformerRecipes` (`gtPlusPlus/xmod/gregtech/loaders/recipe/RecipeLoaderMolecularTransformer.java:25-143`, 18) | dust swaps (tin to silver, gold to platinum, carbon to graphene); sunnarium and cheese from other mods | every target has an ore or chemistry route; sunnarium from MK1 fusion | **leave** (nothing Gregtorio needs is made only there) |
| Hot Isostatic Pressurization Unit (ZPM; `.../multi/compressor/MTEHIPCompressor.java`, LMTE:659) and Pseudostable Black Hole Containment Field (UIV; `MTEBlackHoleCompressor.java`, LMTE:669) | `compressorRecipes` with a compression tier (`gregtech/loaders/oreprocessing/ProcessingPlate.java:377-391`) | every superdense plate; the black hole also pseudo stars and protohalkonite | 96 superdense plates in the tiered compressors (77 of them MV), consumed only by ZPM and later recipes | **leave** (all consumers are ZPM+; see "Found along the way"); issue #355: the gravitational lens, GT's black hole recipe, runs in the UMV compressor, which got a fluid input |
| Neutronium Compressor (UHV; `.../multi/compressor/MTENeutroniumCompressor.java`, LMTE:664) | `neutroniumCompressorRecipes` (core `gthandler/recipes/NeutroniumCompressorRecipes.java`, 78) | Avaritia singularities, the infinity catalyst | none of these items | **n/a** (other mods' items) |
| Transcendent Plasma Mixer (UIV; `.../multi/MTETranscendentPlasmaMixer.java`, LMTE:501) | `transcendentPlasmaMixerRecipes` (`gregtech/loaders/postload/recipes/TranscendentPlasmaMixerRecipes.java:35-195`, 9) | the DTPF catalysts | left out on purpose: the plasma forge makes its catalysts (`139-fork-endgame-multiblocks.lua:14-17`) | **leave** (decided) |

### Own recipes: GT++

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| ExxonMobil Chemical Plant (MV; `gtPlusPlus/.../multi/production/chemplant/MTEChemicalPlant.java`) | `chemicalPlantRecipes` (91 sites: agrichem, generic chemistry, rocket fuels, glue line) | catalyst chemistry, GT++ rocket fuels, the cyanoacrylate glue line, mutated living solder | none of its products; the glue line runs in chemical reactors without catalysts (`142-fork-recipe-unlocks.lua:93-165`), living solder is replaced by indalloy 140. Gregtorio's `chemical-plant` is Space Age's machine | **leave** (no Gregtorio line needs its products) |
| COMET Cyclotron (`.../multi/production/MTECyclotron.java`) | `cyclotronRecipes` (`gtPlusPlus/core/recipe/RecipesGregTech.java:1754-2068`) | RTG pellets, particles; deprecated in GTNH, no controller recipe | no RTG or particle content | **n/a** |
| IsaMill (LuV; `.../multi/processing/MTEIsaMill.java`) and Utupu-Tanuri (UHV; `.../multi/processing/MTEIndustrialDehydrator.java`) | `millingRecipes` (`gtPlusPlus/core/item/base/ore/BaseItemMilledOre.java:49-118`); `vacuumFurnaceRecipes` and the dehydrator map | milled ores for the flotation cell; froth to dusts; the dehydrator in bulk | none (see the Froth Flotation Cell) | **leave** (the same side chain) |
| Reactor Fuel Processing Plant (IV; `.../multi/production/MTERefinery.java`), Thorium Reactor LFTR (IV; `MTENuclearReactor.java`), Sparge Tower (LuV; `MTESpargeTower.java`), Nuclear Salt Processing Plant (`MTENuclearSaltProcessingPlant.java`) | `fissionFuelProcessingRecipes` (5), `liquidFluorineThoriumReactorRecipes` (3), `spargeTowerRecipes` (3), `nuclearSaltProcessingPlantRecipes` (8) | the GT++ fluoride salt reactor loop; the salt plant's map is generated from the two single-block machines of the loop, the Cold Trap I/II and the Reactor Processing Unit I/II (`gtPlusPlus/GTplusplus.java:160-162`, recipes in `gtPlusPlus/xmod/gregtech/loaders/recipe/RecipeLoaderNuclearFuelProcessing.java`; rows in `docs/MACHINE-AUDIT.md`, #367) | the Reactor Fuel Processing Plant with GT++'s three fuels (issue #386 step 2), the LFTR, the Sparge Tower, the Cold Trap I and the Reactor Processing Unit I (step 3; 164 sections 14 and 15) | **built** (the maintainer's decision on #386 replaced the "leave" of this package): the Nuclear Salt Processing Plant too (issue #406, 164 section 17: both maps, 4 parallels at 2.5 times GT's speed); the Cold Trap II and RPU II with Pikyonium 64B since ytterbium came (#355), 164 section 21, issue #406 |
| Mega Alloy Blast Smelter (UHV; `.../multi/production/mega/MTEMegaAlloyBlastSmelter.java`) | `alloyBlastSmelterRecipes` | the ABS in bulk | the Alloy Blast Smelter EV to MAX | **leave** (parallel version) |

### Own recipes: other mods

| GTNH multiblock (name, tier, class) | GT recipe map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Digester (IV) and Dissolution Tank (EV) (gtnhlanth: `gtnhlanth/common/tileentity/MTEDigester.java`, `MTEDissolutionTank.java`) | `digesterRecipes` (34), `dissolutionTankRecipes` (7), `gtnhlanth/loader/RecipeLoader.java` `loadLanthanideRecipes()` | the monazite, bastnasite and samarium rare earth chains; samaric residue to samarium and gadolinium | `samarium-dust` is a placeholder from stone and oxygen (`19-iv-age-item.lua:1363-1377`); `cerium-rich-mixture` has makers but no consumer; the two machines and draft recipes are inside the comment block of `19-iv-age-item.lua` (2846-4213) | **add** (#262: samarium from ore, a use for the cerium mixture; without the 30 UV nano-resin recipes) |
| Source Chamber, LINAC, Synchrotron, Target Chamber (ZPM, gtnhlanth) | `sourceChamberRecipes`, `targetChamberRecipes` (`gtnhlanth/common/tileentity/recipe/beamline/BeamlineRecipeLoader.java`) | wafer engraving with masks | every wafer also has a laser engraver or chemical reactor route in GT; Gregtorio's NPIC to APIC wafers come from laser engravers | **leave** (an optional route with a particle mechanic) |
| Bose-Einstein condensate machines (UMV, tectech `tectech/thing/metaTileEntity/multi/bec/`) | `condensateGeneratorRecipes`, `condensateAssemblingRecipes` (`gregtech/loaders/postload/recipes/BECRecipes.java`) | the godforge and Eye of Harmony casings | Gregtorio's godforge makes its casings in the UXV assembler and the ZPM assembly line (`140-fork-godforge.lua`) | **leave** (every product it needs has a stand-in) |
| Precise Auto-Assembler MT-3662 (IV, goodgenerator `MTEPreciseAssembler.java`) | `preciseAssemblerRecipes` (goodgenerator `RecipeLoader.java`, `RecipeLoader2.java`, core) | compact fusion coils, computation stations, the Neutron Activator controller | none of those; the neutron activator comes from the IV assembler (`125-fork-luv-endgame.lua:147-162`) | **leave** |
| Naquadah Fuel Refinery (UHV; `gregtech/.../multi/MTENaquadahFuelRefinery.java`, LMTE:873) | `naquadahFuelRefineFactoryRecipes` (goodgenerator `FuelRecipeLoader.java:56-194`, 9) | naquadah fuel MK3 to MK6 | MK3 from the UEV mixer, a documented stand-in (`136-fork-power.lua:407, 520-535`); no MK4 to MK6 | **leave**; built since issue #356 (164 sections 27 and 28: the refinery with coils T1 to T4, MK III to MK VI; GT's creon/mellion alternative since #355 (section 29), its hypogen and one-step MK IV since #436 (section 35)) |
| Antimatter Forge and Antimatter Generator (UMV, goodgenerator) | no map | antimatter and its power | no antimatter | **n/a** |
| Draconic Evolution Fusion Crafter (UEV, kubatech `MTEDEFusionCrafter.java`) | `fusionCraftingRecipes` (`kubatech/loaders/DEFCRecipes.java`) | Draconic Evolution cores | only in unloaded drafts | **built** since issue #489 (164 sections 40 and 41): tiers 1 to 4 (Bloody Ichorium, Draconium, Wyvern, Awakened Draconium casings; tier 4 with MK II fusion machine casings), the draconic, wyvern, awakened and chaotic cores, the energy cores and the schematics; one machine per casing tier. Tier 5 (Chaotic casings) left out: no recipe of its tier |
| Eye of Harmony (UMV, tectech `MTEEyeOfHarmony.java`) | `eyeOfHarmonyRecipes` | ores per dimension, raw star matter, universium | left out on purpose (`140-fork-godforge.lua`); question #249 | **n/a** (decided; #249 open) |

### Generators

Gregtorio has no fuel value for lava; `rocket-fuel` has one since #295 (its cell, burnt by GT++'s single-block rocket
engines and, since #304, the Large Rocket Engine). It also has no supercritical steam, solar salt or TRISO pebbles; the
combustion promoter came with issue #357. The single-block generators of the same fuels (geothermal, RTG) are in
`docs/MACHINE-AUDIT.md` (#367).

| GTNH multiblock (name, tier, class) | GT fuel map and loader | What GTNH uses it for | In Gregtorio today | Verdict |
|---|---|---|---|---|
| Thermal Boiler (IV; `.../multi/MTEThermalBoiler.java`, LMTE:1011) | `thermalBoilerRecipes` (`gtPlusPlus/core/recipe/RecipesGregTech.java:1484-1537`) | lava to steam, hot coolant or solar salt to superheated steam | lava is endless from the drilling rig. The rig spends 12.8 kJ per unit, and GT's boiler would give 8 kJ back. Hot coolant already goes to the Large Heat Exchanger | **leave** (a net loss; the coolant role is taken) |
| Universal Chemical Fuel Engine (LuV; `.../multi/MTEUniversalChemicalFuelEngine.java`, LMTE:1035) | diesel, gas and rocket fuel maps | any fuel, up to 150 % with a promoter | the combustion and gas lines up to HV; EV is #255/#256 | **built** (issue #357, 164: the "leave, a later upgrade of #255/#256" verdict changed once goodgenerator's fuels came; combustion and gas cells at 150 %, one LuV amp, the promoter and rocket fuels left out) |
| Large Supercritical Steam Turbine (IV; `.../multi/turbines/MTELargeTurbineSCSteam.java`, LMTE:938) | supercritical steam from goodgenerator's Extreme Heat Exchanger | a third steam stage | the steam line ends at the HP steam turbine | **leave** (a new fluid and exchanger) |
| Large Rocket Engine (LuV, GT++ `MTELargeRocketEngine.java`) | `rocketFuels` (`gtPlusPlus/core/item/chemistry/RecipeLoaderRocketFuels.java:179-184`) | rocket fuel power | #295: `rocket-fuel` is GT++'s H8N4C2O4 rocket fuel with GTNH's recipe in the Chemical Plant; its cell (1678.4 MJ) burns in GT++'s EV, IV and LuV Rocket Engines; #304 (0.5.4): `large-rocket-engine` (`145-fork-power-multiblocks.lua:627`), a burner generator on the rocket fuel cells with a fixed 2 A of IV, without the air intakes, carbon dioxide and liquid hydrogen boost | **add**: done, #304 (the maintainer's decision: build it simplified) |
| Large Semifluid Burner (EV, GT++ `MTELargeSemifluidGenerator.java`) | `semiFluidFuels` | creosote and heavy oils at 2048 EU/t | LV to HV semifluid generators; heavy fuel also goes into diesel for #255 | **leave** |
| Solar Tower (EV, GT++ `MTESolarTower.java`) | solar salt heating | hot salt for steam | solar power is disabled (`data-final-fixes.lua:196, 210`) | **leave** (a design decision, not a gap) |
| Thorium High Temperature Reactor (bartworks `MTEThoriumHighTempReactor.java`), HTGR (kubatech `MTEHighTempGasCooledReactor.java`) | no map: TRISO pebbles heat coolant | hot coolant; the HTGR also gives lutetium | the thorium fuel rod in the fluid nuclear reactor heats coolant; lutetium has its stand-in | **leave** |
| Deep Earth Heating Pump (IV, bartworks `MTEDeepEarthHeatingPump.java`) | no map | superheated steam for 480 EU/t | the heat exchanger and #254 | **leave** (power from almost nothing breaks the fuel balance) |
| Solid-Oxide Fuel Cell Mk I/II (HV/LuV, kekztech `MTESOFuelCellMK1/2.java`) | `gasTurbineFuels` + oxygen | gas power with steam on the side | gas turbines LV to HV, EV in #256 | **leave** |
| Compact Fusion Computer MK-I to MK-V (goodgenerator `MTELargeFusionComputer1-5.java`) | GT's `fusionRecipes`, 64 parallels | the fusion reactor in bulk | fusion MK1 to MK5 | **leave** (parallel version, not a generator) |
| Dyson Swarm (UIV, gtnhintergalactic `TileEntityDysonSwarm.java`) | no map | power from space modules | no dimensions or space elevator | **n/a** |

### Parallel versions

Each runs the recipe map of a machine Gregtorio has: **leave**.

| Multiblock (class) | Map | Gregtorio machine |
|---|---|---|
| Density^2 (`.../multi/MTEAdvImplosionCompressor.java`) | implosion | implosion compressor HV to MAX |
| Industrial Autoclave (`MTEMultiAutoclave.java`) | autoclave | autoclave LV to MAX |
| Industrial Bending Machine, Industrial Forming Press, Industrial Sledgehammer (`MTEIndustrialBendingMachine`, `MTEIndustrialFormingPress`, `MTEIndustrialForgeHammer`) | bender, forming press, hammer | bending machine (and the IV Industrial Material Press), forming press, forge hammer |
| Large Thermal Refinery, Ore Washing Plant (`MTEIndustrialThermalCentrifuge`, `MTEOreWashingPlant`) | thermal centrifuge, ore washer | thermal centrifuge, ore washer LV to MAX |
| Industrial Coke Oven (`MTEIndustrialCokeOven`) | pyrolyse oven, plus its own coal gas, selenium and wood pellet recipes | pyrolyse oven, coke oven (the chains of its own recipes are not in Gregtorio; see the row below) |
| Boldarnator (`MTEIndustrialRockBreaker`) | its own map, a copy of the rock breaker's | rock crusher |
| Volcanus, Dangote Distillus, Whakawhiti Wera XL (GT++ `MTEAdvEBF`, `MTEAdvDistillationTower`, `MTEAdvHeatExchanger`); bartworks Mega Blast Furnace and Mega Vacuum Freezer | EBF, distillation, heat exchanger, vacuum freezer | EBF, distillation towers, Large Heat Exchanger, vacuum freezer |
| Industrial Arc Furnace (kubatech) | arc furnace, EBF, furnace | arc furnace, EBF, furnaces |
| Advanced Assembly Line (ggfab `MTEAdvAssLine`) | assembly line | assembly line |
| Large Scale Auto-Assembler (GT++ `MTEAutoCrafter`), Windmill (bartworks), Amazon Warehousing Depot (`MTEIndustrialPackager`) | assembler, macerator, packager | assembling machine, macerator; no packager (`docs/MACHINE-AUDIT.md`: nothing to pack) |
| the steam multiblocks: Steam Grinder, Squasher, Presser, Fuser, Hearth, Separator, Blender, Purifier, Water Pump (`.../multi/steam/`) | macerator, compressor, hammer, alloy smelter, furnace, centrifuge, mixer, washer | the steam machines and furnaces; centrifuge, mixer and ore washer start at LV in Gregtorio (a design choice) |

### The Industrial Coke Oven's own recipes (issue #367)

Most of `industrialCokeOvenRecipes` is shared with the pyrolyse oven (`addTo(pyrolyseRecipes, industrialCokeOvenRecipes)`
in `gregtech/loaders/postload/recipes/CokeAndPyrolyseOven.java`, `PyrolyseRecipes.java` and GT++'s
`gtPlusPlus/core/item/chemistry/RecipeLoaderCoalTar.java`). Only three recipe families are its own:

| Recipe (loader) | What it makes | In Gregtorio today | Verdict |
|---|---|---|---|
| 12 coal + 6 coke + 2000 L steam -> 14 coke + 5040 L coal gas (`CokeAndPyrolyseOven.java:62-71`) | GT++'s coal gas, a gas turbine fuel and the start of GT++'s coal tar chemistry | no coal gas and no coal tar line (the coal tar recipes of `21-luv-age-item.lua:1275-1291` belong to the never loaded draft) | **leave** (a fuel without a consumer chain; Gregtorio's gas turbines have methane, refinery gas and the rest) |
| selenium dioxide + steam -> selenium dioxide fluid; + hot water -> selenious acid (`gtPlusPlus/core/recipe/RecipesSeleniumProcessing.java:31-46`) | GT++'s selenium | no selenium (one of the elements of #365) | **leave** (follows #365: built only with a consumer) |
| 2 wood pellets -> 3 charcoal (`gtPlusPlus/plugin/agrichem/BioRecipes.java:268-274`) | charcoal from GT++ agrichemistry's pellets | no agrichemistry (see the Algae Farm below); charcoal comes from the furnace and the pyrolyse oven | **n/a** |

### Utilities

| Multiblock | Verdict and reason |
|---|---|
| Large Molecular Assembler | leave: me-network's ME Molecular Assembler |
| Elemental Duplicator, Matter Fabrication CPU | leave: the UU matter decision of `docs/MACHINE-AUDIT.md` |
| Power Station Control Node, L.E.S.U. | leave: the Lapotronic Supercapacitor (145) |
| Tree Growth Simulator | leave: the Extreme Industrial Greenhouse grows the trees (154) |
| Algae Farm | n/a: its algae feed GT++ agrichemistry and the netherite chain, neither in Gregtorio |
| Space Elevator and modules, Planetary Gas Siphon | built since #301-#303 (162: the elevator, the mining and pump modules, the siphon); #485: the Assembler Module Mk-I for the Singularity ME Storage Cell |
| Drone Centre, Industrial Fishing Pond, Mega Apiary, Large Essentia Smeltery | n/a: Minecraft and other mods' content |
| Research Station, Quantum Computer, Data Bank, network switches | n/a: research is the technology tree, the assembly line needs no data |
| Tesla Tower, Active Transformer | n/a: Factorio's poles; no voltages |
| TFFT, YOTTank | n/a: Factorio's tanks and the ME fluid cells |

## Found along the way

- **The HV steam turbine is the MV one.** The item `hv-steam-turbine` places `mv-steam-turbine`
  (`16-hv-age-entity.lua:13`), and that file defines a second generator named `mv-steam-turbine` (`:19`, effectivity
  0.425). This overrides the MV turbine of `14-mv-age-entity.lua:177` (0.45), so there is no HV steam turbine.
- **GT has no "complex SMDs".** Neither GT5-Unofficial nor the core mod has them; the SMD tiers are SMD, advanced
  (ASMD) and optical (XSMD, `gregtech/api/enums/ItemList.java`). Gregtorio's `complex-smd-*` items are its own. The
  comments and docs that call them GT's are wrong: `129-fork-water-purification.lua:15-17` and section 5,
  `131-fork-uev.lua:315`, and `docs/ROADMAP.md` (the water purification row and the UHV/UEV notes).
- **Cleanroom leftovers.** The `cleanroom-tile` and the `cleanroom` technology are commented out, but their locale
  entries and graphics stay. `plascrete` is unlocked (Polyethylene) and has no consumer left except its recycling.
- **Superdense plates before their time** (#257): GT makes them only in the ZPM Hot Isostatic Pressurization Unit or the
  UIV black hole compressor. Gregtorio makes 77 of its 96 in the MV compressor. Every consumer is ZPM or later (the fusion
  controllers, the plasma forge, the godforge, the stargate parts), so nothing changes in play. If GT's gate is wanted,
  raise the compressor category of those recipes; no multiblock is needed.
- **`rocket-fuel` had no burner** (#257): it was only used by the microverse missions, without a fuel value. #295 made it
  GT++'s H8N4C2O4 rocket fuel (GTNH's recipe) with a fuel cell for GT++'s single-block rocket engines; the Large Rocket
  Engine came with #304 (0.5.4).
- **`docs/MACHINE-AUDIT.md` is partly out of date** (#257): its thermal centrifuge, sifting and electromagnetic separator
  rows still say "none". The ore chain of #185 to #188 added those machines. This belongs to the docs drift of #250.

## Issues opened for "add" verdicts

Each verdict is a proposal until the maintainer accepts it.

- #254 Large Titanium Boiler (EV): a fuel-fired source of superheated steam for the High Pressure Steam Turbine. Done.
- #255 Large Combustion Engine (EV): the liquid fuel line above HV. Done.
- #256 Large Gas Turbine (EV): the gas fuel line above HV. Done.
- #262 Digester and Dissolution Tank (EV, IV): the lanthanide chain, samarium from ore instead of the stone placeholder (#257). Done: the monazite line (159); bastnasite, the cerium line and GTNH's samarium chain were left out by decision. #269 added the bastnasite line (without its samaric branch) and the cerium line, and removed the commented-out draft of 19. #272 added europium, zirconium, lanthanum hexaboride and the samaric branch (with GT++'s ExxonMobil Chemical Plant); #274 hafnium from GT++'s ilmenite sifter, the EV-ZPM dehydrators and the small leftovers.

Follow-ups of this audit:
- #257: the multiblocks the list missed (audited above);
- #258: the HV steam turbine;
- #259: the complex SMDs (done: the comments and docs call them Gregtorio's stand-in for GT's optical SMDs);
- #260: the cleanroom leftovers and plascrete (done: both removed).
