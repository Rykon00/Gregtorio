# Audit: GTNH multiblocks Gregtorio lacks (issue #246)

State of 2026-10-11:
- GTNH is GT5-Unofficial af993ca6a9. Paths are relative to its `src/main/java`; `LMTE` =
  `gregtech/loaders/preload/LoaderMetaTileEntities.java`, `MRL` = `gregtech/loaders/load/MTERecipeLoader.java`, `PR` =
  `gregtech/loaders/postload/recipes/`. The GTNH core mod is NewHorizonsCoreMod (`core:` + its path).
- Gregtorio is main da645bc, read from the prototypes and from `devcheck.py check --balance-out`; the crafting machines are
  taken from that dump, not from controller names.
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
  and ores come from vein recipes and microminers.

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
| Ore Drilling Plant I to IV (MV to IV; `.../multi/MTEOreDrillingPlant1-4.java`, LMTE:552-563) | no map: mines the ore blocks below (`MTEOreDrillingPlantBase.java:845`) with drilling fluid | automatic ore mining, about 3x crushed ore | no ore blocks: vein recipes in the manual mine (`07-ore-processing-module.lua`, `10-steam-age-entity.lua:221`) and the microminers | **leave** (nothing in the world to drill) |
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
| Decay Warehouse (`.../multi/MTEDecayWarehouse.java`, LMTE:696) | `isotopeDecay` (`gtPlusPlus/core/handler/Recipes/DecayableRecipe.java`) | speeds up GT++ isotope decay | no decaying isotopes (only in the unloaded `51-nuclear-module.lua`) | **n/a** |

## GTNH multiblocks the issue's list missed

A compare of all `MTEMultiBlockBase` subclasses of GT5-Unofficial and the `gt.blockmachines.multimachine.*` names with
Gregtorio's machines found more multiblocks without a counterpart. They are not audited here (follow-up #257).
First sorting, by name and recipe map only:

- **Own recipes or a role in a line:**
  - gregtech: Electric Implosion Compressor (`MTEElectricImplosionCompressor`), Nano Forge (`MTENanoForge`), Froth
    Flotation Cell (`MTEFrothFlotationCell`), Integrated Ore Factory, Molecular Transformer, the advanced compressors
    (Hot Isostatic Pressurization Unit, Neutronium Compressor, Pseudostable Black Hole Containment Field), Transcendent
    Plasma Mixer (left out on purpose: `139-fork-endgame-multiblocks.lua:13-15`).
  - GT++: ExxonMobil Chemical Plant, COMET Cyclotron, IsaMill, Sparge Tower, Nuclear Salt Processing Plant, Reactor Fuel
    Processing Plant and LFTR (only in the unloaded `51-nuclear-module.lua`), Utupu-Tanuri, Mega Alloy Blast Smelter.
  - Other mods: the gtnhlanth lanthanide and photolithography machines (Digester, Dissolution Tank, Source Chamber, LINAC,
    Synchrotron, Target Chamber; the first two are item stubs without an entity or recipe in `19-iv-age-item.lua`),
    tectech's Bose-Einstein condensate machines, the Eye of Harmony (left out on purpose: `140-fork-godforge.lua`),
    goodgenerator's Precise Auto-Assembler, Naquadah Fuel Refinery and the antimatter machines, and kubatech's Draconic
    Evolution Fusion Crafter.
- **Generators:** Thermal Boiler, Universal Chemical Fuel Engine, Large Supercritical Steam Turbine, GT++ Large Rocket
  Engine, Large Semifluid Burner and Solar Tower, bartworks' Thorium High Temperature Reactor and Deep Earth Heating Pump,
  kubatech's HTGR, kekztech's solid-oxide fuel cells, goodgenerator's Compact Fusion Computers, the Dyson Swarm.
- **Parallel versions of machines Gregtorio has:** Density^2, Industrial Autoclave, Industrial Bending Machine, Industrial
  Forming Press, Industrial Sledgehammer, Large Thermal Refinery, Ore Washing Plant, Industrial Coke Oven, Boldarnator,
  Volcanus, Dangote Distillus, Whakawhiti Wera XL, the bartworks Mega Blast Furnace and Mega Vacuum Freezer, kubatech's
  Industrial Arc Furnace, the Advanced Assembly Line, the steam multiblocks (grinder, squasher, presser, hearth, fuser,
  separator, blender, purifier).
- **Utilities and Minecraft machines** (n/a at first sight):
  - storage and logistics: Large Molecular Assembler, Large Scale Auto-Assembler, Elemental Duplicator, Matter
    Fabrication CPU, Power Station Control Node, the Space Elevator and its modules, Planetary Gas Siphon, Windmill;
  - farming: Algae Farm, Drone Centre, Industrial Fishing Pond, Tree Growth Simulator, Mega Apiary;
  - TecTech computation and power: Research Station, Quantum Computer, Data Bank, network switches, Tesla Tower,
    Active Transformer;
  - other: TFFT, YOTTank, L.E.S.U., Amazon Warehousing Depot, Large Essentia Smeltery.

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

## Issues opened for "add" verdicts

Each verdict is a proposal until the maintainer accepts it.

- #254 Large Titanium Boiler (EV): a fuel-fired source of superheated steam for the High Pressure Steam Turbine.
- #255 Large Combustion Engine (EV): the liquid fuel line above HV.
- #256 Large Gas Turbine (EV): the gas fuel line above HV.

Follow-ups of this audit:
- #257: the multiblocks the list missed;
- #258: the HV steam turbine;
- #259: the complex SMDs;
- #260: the cleanroom leftovers and plascrete.
