# Ore processing as GT New Horizons has it (issue #176): the plan

Decision of the maintainer (2026-10-06, #176): **GTNH's full ore chain**, built as a project of its own in phases, the plan
first. This file is the plan; the phases are the issues #185 (O1), #186 (O2), #187 (O3) and #188 (O4). No game change comes with this file.
Sources: GT5-Unofficial fa916718 (`src/main/java`, `OP/` = `gregtech/loaders/oreprocessing/`); Gregtorio main 8b112a6
(`devcheck.py check --balance-out`). The appendices hold GTNH's numbers with file and line.

## Today and the goal

**Gregtorio today** (`create_ore` in `prototypes/03-helper-functions-module.lua`, called 73 times in
`prototypes/07-ore-processing-module.lua`, 69 ores with a crushed form):

| step | machine | recipe |
|---|---|---|
| raw ore -> 2 x multiplier crushed | macerator | 20 s |
| crushed + 10 water -> dust | ore washer | 1 s, recipe named after the dust |
| crushed -> dust + byproduct 10 % | centrifuge | 4 s, `centrifuging-<crushed>` |

One byproduct per ore, only in the centrifuge. 12 other recipes take crushed ores directly (platinum and indium lines, ruby
juice, bauxite slurry, the two sifter recipes, ilmenite processing): they stay as they are.

**GTNH** (appendix A): every ore has a list of byproducts; each step takes a fixed entry of it (washer and impure dust:
the 1st, thermal centrifuge and pure dust: the 2nd, macerating centrifuged ore: the 3rd; a short list repeats its last
entry, an empty one the ore itself):

```
raw ore --macerator--> 2 crushed (+ byproduct 10 %)
crushed --ore washer (water)--> purified crushed + byproduct[0] 11.11 %
        --chemical bath (mercury / sodium persulfate, tagged ores)--> purified crushed + byproduct 70 % (99 %)
        --thermal centrifuge--> centrifuged crushed + byproduct[1] 11.11 %
        --macerator--> impure dust (+ byproduct[0] 10 %)
purified --thermal centrifuge--> centrifuged crushed + byproduct[1] 11.11 %
         --macerator--> pure dust (+ byproduct[1] 10 %)
         --sifter (gem ores)--> gems by grade
centrifuged --macerator--> dust (+ byproduct[2] 10 %)
impure / pure dust --centrifuge--> dust + byproduct 11.11 %
pure dust --electromagnetic separator (tagged ores)--> dust + gold / iron / neodymium
```

So a player can stop at any step: crushed -> impure dust -> dust is the short way (one byproduct), the full way gives
three byproducts.

## Rules for every phase

- **GTNH's numbers with Gregtorio's conventions:** time = GT seconds x the machine tier's speed (LV 1), fluids a tenth
  of GT's litres. The washer's 1000 L water become 100 water and 25 s (today 10 water and 1 s): ore processing gets
  slower. That is GTNH's pace; the phase issue names it in the changelog.
- **Names:** the new forms are `purified-<ore>`, `centrifuged-<ore>`, `impure-<ore>-dust`, `pure-<ore>-dust` (the crushed
  item keeps its name `crushed-<ore>`); locale "Purified Crushed Iron Ore", "Centrifuged Crushed Iron Ore", "Impure
  Iron Dust", "Pure Iron Dust" as GTNH's.
- **Saves:** recipe names that a machine of an old save may hold are kept or mapped by a JSON migration (the ore washer
  recipe `iron-dust` becomes the washer recipe of the purified form; `centrifuging-crushed-iron` the centrifuge recipe of
  the impure dust). Crushed ore in chests stays crushed ore.
- **Data in one place:** a Lua table per ore (byproducts in GTNH's order, washing tags, electromagnetic tag, gem flag)
  generated from appendix B, read by the generator of the recipes; a devcheck rule checks that every ore has its full
  chain and that every byproduct is an item.
- **Byproducts Gregtorio lacks** (appendix B against the items of main): andradite, red and yellow garnet, lignite,
  magnetite, malachite, netherrack dust, pyrite, quartzite. Per item: add it (with a use or a void recipe), or take the
  next entry of the list; decided in phase 1. Name mismatches only: uranium (`uranium-238-dust`), uranium 235
  (`uranium-235-dust`), enriched naquadah (`enriched-naquadah-dust`).
- **Not taken over:** the dense, nether and end ore doubling (Gregtorio has one ore per material). (GTNH's naquadah earth
  outputs were left out here at first and are taken over since #205: Gregtorio's naquadah oxide mixtures are goodgenerator's
  earths.)

## Phases

Phase O1 as built (#185): 65 ores (platinum and palladium keep the platinum line's washing, firestone has no ore source); stone dust is left out (Gregtorio's ores have no host rock); tin's empty third byproduct slot is bismuth, its only source; of the nine missing byproducts eight are new dusts, malachite was not made (GTNH's byproduct of calcite only, which had no crushed form then; since #203 it is, see below); quartzite's use (centrifuge into silicon dioxide) is Gregtorio's, GT has none.

Phase O2 as built (#186): 18 chemical bath recipes (8 mercury, 10 sodium persulfate), the tags checked on the ore and then its byproducts in order as in ProcessingDirty.java; stone dust left out as in O1; platinum, palladium (skipped in O1) and bornite (a bartworks material, only its own tags) have none. The chemical bath (Chemical Reactor) and mercury (Ore Centrifuging) are on parallel branches: a recipe goes to the first technology after the bath, the fluid's source and the ore's washer recipe, else to the technology with the fewest ancestors that has all three before it (Primitive Electronic Circuit Assemblies for the early mercury washing).

Phase O3 as built (#187): the Electromagnetic Separator LV to MAX (GT's machine recipe, EU 24; LV with Ore Washing) on the pure dusts of the nine tagged ores, with GT's small dust (40 %) and nugget (20 %) as new items (decision on #187): small piles of gold, iron and neodymium dust (4 -> a dust at the crafting table, GT's shapeless recipe; GT's packager is not in Gregtorio) and their nuggets (9 -> an ingot in the alloy smelter with the mold, GT ProcessingNugget.java:47-55). Sprites: the polarizer's frame with GT's separator front.

Phase O4 as built (#188): new grade items for every sifted gem and new gems for the five ores whose gem was the dust (decision on #188; `<ore>-gem`, since an item `monazite` is referenced by a draft of the monazite line). Sifter on the purified ore with GT's tables (diamond's existing recipe now sifts purified ore as in GT). Grade uses as GT's: forge hammer one grade down (x2), implosion compressor three into one grade up with an explosive (GT: 8 TNT; the tiny dark ash is left out), macerator back into dust (chipped and flawed as a 25 % and 50 % chance of a dust: no small dusts of the gems), lathe exquisite -> 3 lenses + a dust where Gregtorio has the lens (ruby, diamond). Not made: GT's laser engraver steps (they need a lens of the gem's colour), the autoclave's molten Void variant. Autoclave: impure and pure dust of the seven crystallisable ores -> gem with water (20; 90 / 95 %, 100 s) or distilled water (10; 95 / 100 %, 75 s); Gregtorio's autoclave starts at MV. Forge hammer crushing for every ore of O1 in 0.5 s: raw -> crushed (GT's ore multiplier, half of the macerator's), crushed -> impure, purified -> pure, centrifuged -> dust; the steam forge hammer runs them too. Firestone stays out (no ore source).

Raw ore crushing as in GTNH (#202; `ProcessingRawOre.java`, bornite: bartworks `RawOreLoader.java`): every raw ore with a macerator recipe to a crushed ore (68 of the 69; firestone, which has no ore source, is left out in `FORK_ORE_HAMMER_SKIP`) has a forge hammer recipe with GT's ore multiplier: the crushed ore, or GT's gem for the twelve gem ores (`FORK_ORE_HAMMER_GEM`: coal, ruby, emerald, diamond, lapis, lazurite, sodalite, apatite, certus and nether quartz, monazite, tricalcium phosphate). The macerator gives 2 x the multiplier and the first of GT's byproducts at 5 % x GT's byproduct multiplier, a gem where GT gives one and Gregtorio has it (lignite, quartzite and the garnets: their dust; naquadah: enriched naquadah dust, GT's goodgenerator turns it into enriched naquadah earth), the platinum group dusts as the platinum line's powders; GT's stone dust is left out as in O1. The ore multipliers of `create_ore` are GT's (monazite 8, cryolite 4, scheelite and tungstate 2, bastnasite, lepidolite, naquadah, grossular and spessartine 1). Cassiterite has its own crushed ore and chain (GT's Cassiterite: byproduct tin, mass 50, smelts into tin, electrolysis 3 dust -> tin dust + 200 oxygen in 6.6 s); the recipe `crushed-tin` (Raw Cassiterite) is mapped onto `crushed-cassiterite` by `migrations/2026-10-07-issue-202-cassiterite.json`, Raw Tin's macerator recipe is `macerating-raw-tin`. `create_ore` fails on a recipe name it defines twice. devcheck: `check_ore_hammer`, the runtime crush test.

GTNH items and recipes completed (#205): the byproduct gems Gregtorio had as dust (Lignite Coal, Quartzite, Red and Yellow Garnet) with GT's grades, small piles, the red and yellow garnet lens and the engraver steps of their colour (tricalcium phosphate with the yellow garnet lens); the raw ore macerator gives them as GT's byproduct gem. GT's dust -> gem routes (`ProcessingDust.java`): autoclave for the crystallisable gems (upstream's MV autoclave recipes become GT's distilled water one), implosion of 4 dusts into 3 gems for ruby, emerald, the garnets and monazite; upstream's autoclave recipes of ruby, emerald and diamond have no GT counterpart and stay. GT's ore form smelting (`ProcessingOreSmelting.java`): crushed, purified and centrifuged ore -> 10 nuggets (an ore that smelts into itself) or 1 ingot of the direct smelting metal, dust, impure and pure dust -> 1 ingot; new nuggets of nine metals and the realgar, thorium, antimony and molybdenum ingots. Naquadah: goodgenerator's conversion of the ore's dusts into its earths, 2 per dust (`NaquadahRecipeOutputs.convert`), and the naquadah line's numbers and missing recipes as goodgenerator's (`prototypes/125-fork-luv-endgame.lua`).

Gypsum, sulfur and calcite as built (#203): GTNH's crushed ore (`addOreItems()` in `loadGypsum()`, `loadSulfur()`, `loadCalcite()`) and the whole O1 chain for the three ores whose raw ore upstream's macerator turned straight into dust: Crushed Gypsum, Sulfur and Calcite (`create_ore` in 07; the macerator recipes keep their names `gypsum`, `sulfur` and `calcite`, so a macerator of an old save keeps its recipe and makes the crushed ore, no JSON migration), purified and centrifuged ore, impure and pure dust, the forge hammer steps and the raw ore forge hammer recipe (`check_ore_hammer` covers them without an allow-list entry). Byproducts as GTNH's: sulfur -> sulfur; calcite -> andradite, malachite; gypsum -> none (itself). GT masses for the centrifuge: gypsum 18, sulfur 32, calcite 20. Malachite dust is new (GT's Malachite, Cu2CO3(OH)2): the MV electrolyzer splits 10 into 2 copper dust, carbon, 200 hydrogen and 500 oxygen in 10 s (GT gives the oxygen in cells), and it smelts into copper (`setDirectSmelting(Copper)`). No smelting of the ore forms (sulfur is NO_SMELTING, gypsum and calcite have no ingot); no chemical bath, separator or sifter step (none of the three is tagged, none has a gem). Their recipes replace none, so they are unlocked after their machine and their input (`o1_late`, `unlock_after`) instead of with the technologies of the recipes they replace.

O4 follow-up as built (#193): the LV Autoclave (GT's Basic Autoclave and its machine recipe; with Extractor, the LV pump's technology; sprite: the MV autoclave in the LV casing colours); the laser engraver grade steps with a lens of the gem's colour that stays (red: ruby lens; green: the new emerald lens, emerald and monazite; white: the new diamond lens, diamond and nether quartz; certus quartz, apatite, lazurite, tricalcium phosphate, sodalite and lapis have colours whose GT lenses come from materials Gregtorio lacks, so no engraver steps; Gregtorio's engraver starts at MV, the LV step runs there); GT's dark ash (2 tiny piles per implosion, 9 -> a dust at the crafting table, as GT's packager is not in Gregtorio; the dust -> carbon in the electrolyzer); small piles of the gems' dust from chipped (1) and flawed (2) gems. The molten Void variant of the autoclave is not made: 137 removed void metal on purpose.

Platinum group byproducts (#199): GTNH converts every ore processing output of platinum, palladium, iridium and osmium (bartworks `PlatinumSludgeOutputs.convert`, called from ProcessingDirty, ProcessingCrushedOre, ProcessingPure and ProcessingDust) into two of the platinum line's metallic powder or leach residue. The ore chain does the same in its `recipe` helper: platinum dust -> 2 metallic platinum powder, palladium dust -> 2 metallic palladium powder, iridium dust -> 2 iridium metal residue (nickel's and sheldonite's byproducts and nickel's mercury washing).

| phase | content | new items and machines | depends on |
|---|---|---|---|
| O1 (#185, **done**: `prototypes/155-fork-ore-chain.lua`) | the core chain: purified, centrifuged, impure and pure forms, ore washer to purified, thermal centrifuge, macerator steps, centrifuge of impure and pure dust; the byproduct table; the missing byproducts; saves | 4 forms x 69 ores (about 276 items with GT icons in the material colour, `tools/gen_gt_icons.py`), the **Thermal Centrifuge** LV to MAX (GTNH's recipe, sprites as #171 to #175), the Material Parts rows (200) | - |
| O2 (#186, **done**: `prototypes/155-fork-ore-chain.lua`) | chemical bath washing for the tagged ores (mercury: gold, platinum, cooperite, and silver at 99 %; sodium persulfate: cobalt, copper, nickel, zinc, cobaltite, tetrahedrite, as the ore itself or one of its byproducts) | recipes only (the chemical bath, mercury and sodium persulfate exist) | O1 |
| O3 (#187, **done**: `prototypes/155-fork-ore-chain.lua`) | the **Electromagnetic Separator** LV to MAX on pure dusts of the tagged ores (gold: vanadium magnetite; iron: tin, ilmenite, nickel, pentlandite, chromite, bornite; neodymium: bastnasite, monazite). GTNH gives a small dust and a nugget; Gregtorio has neither: their worth as a dust chance (40 % x 1/4 + 20 % x 1/9 = 12.2 %) | the machine | O1 |
| O4 (#188, **done**: `prototypes/155-fork-ore-chain.lua`) | the **sifter** on purified gem ores (ruby, diamond, emerald with GTNH's precious table; nether quartz, certus quartz, apatite, tricalcium phosphate, lazurite, sodalite, lapis, monazite, firestone with the default one; coal, salt and rock salt are skipped as in GTNH) and the autoclave on impure and pure dusts of the crystallisable ores; the forge hammer's crushing steps (ore -> crushed, crushed forms -> dust, #170) | gem grades Gregtorio lacks (only diamond has them today) | O1 |

Each phase: `devcheck.py all`, `migrate --from-ref <last release>` with a save that runs the old recipes, the unlock diff
of two balance dumps (the new recipes are producers of 199's auto-unlock), a contact sheet of the new icons, the changelog
and a block in a `[Task-Ingame]` issue.

## GTNH differences after #205 (#207): what was done and what stays

The differences #205 left, each checked against GT5-Unofficial 03f4d0608f (goodgenerator and bartworks inside it). Rule of
the maintainer: as GTNH has it where Gregtorio has the items and mechanics; a point that needs a system Gregtorio lacks
stays, without a stand-in; upstream recipes without a GTNH counterpart stay until the maintainer decides (#223).

| point | GTNH | Gregtorio | why |
|---|---|---|---|
| 1. P-507 | 2 sodium, 2-ethyl-1-hexanol, phosphoric acid, ethanol (`NaquadahRecipeLoader.java:163-184`); 2-ethyl-1-hexanol from hydrogen and seed oil, seed oil from wheat, melon and pumpkin seeds (`FluidExtractorRecipes.java:450-464`) | **stays**: upstream's recipe (ethanol + phosphoric acid, IV) | Gregtorio has no seeds and no seed oil; no stand-in |
| 2. Quantum force transformer naquadah recipes | naquadah, enriched naquadah and naquadria earth -> inert naquadah dusts at UEV, UIV and UMV with GT's naquadah catalysts and focus tiers; the neutron activator turns 96 inert dusts with nickel, titanium or americium plasma, inside a window of neutron kinetic energy, into the melt (`NaquadahRecipeLoader.java:51-137`) | **stays**: Gregtorio's own phase 6a recipes (`139-fork-endgame-multiblocks.lua`, devcheck's REQUIRED_RECIPES) | they do not fit the QFT as built: it has no catalysts and no focus tiers and runs at UMV only; Gregtorio has no nickel and no americium plasma, its neutron activator has no neutron kinetic energy, and the naquadria recipe gives naquadria supersolid, which Gregtorio lacks |
| 3. Naquadah nugget | 2 naquadah earth -> 1 naquadah nugget in the blast furnace with a gas (IV, 5000 K, 2 min, 1000 L; `NaquadahRecipeLoader.java:512-520`) | **done** (`125-fork-luv-endgame.lua`): `naquadah-nugget` with nitrogen and the six other blast furnace gases (147's time and gas factors), the new naquadah nugget (9 -> an ingot in the alloy smelter, cast by 143), with Naquadah Processing | |
| 3. Goo and mass items | naquadah, enriched naquadah and naquadria goo from CropsNH's crop leaves in the chemical reactor (`NaquadahRecipePatches.java`), solidified into masses, macerated into earths | **stays**: not made | Gregtorio has no crops (CropsNH); no stand-in |
| 4. Upstream extras | none | **removed in #223** (maintainer's decision): the autoclave recipes ruby, emerald and diamond from dust; the electrolyzer recipes of enriched naquadah and naquadria dust from their sulphates (GT's ingot -> dust maceration instead); the cryogenic helium of the naquadah, enriched naquadah and naquadria vacuum freezer steps (GTNH cools all three without coolant at IV: goodgenerator for naquadah, NewHorizonsCoreMod `VacuumFreezerRecipes.java:134-142` for the other two; #207 had missed them) | |
| 5. Smelting in the multi smelter | GT's multi smelter runs every furnace recipe | **done** (155): every furnace recipe of the ore chain (O1's impure and pure dusts, #205's ore forms, malachite) has a multi smelter recipe, 64 -> 64 x the output in the furnace recipe's time, named `<input>-multismelter` like create_ore's | |
| 5. Crushed platinum and palladium, bornite | platinum: 10 nuggets, which `PlatinumSludgeOutputs.convertSmelting` turns into 20 tiny piles of platinum metallic powder; palladium: none (blast furnace, 1828 K); bornite: none (a bartworks material without an ingot, `CrushedLoader.java`) | **done**: crushed platinum -> 20 new tiny piles of metallic platinum powder (9 make the powder at the crafting table: GT's packager is not in Gregtorio); palladium and bornite: nothing, as in GTNH | |
| 5. Vanadium magnetite dust -> iron | none | **removed in #223**, the dust and the raw ore smelting (below) | |
| 6. New ingots: melts | a molten fluid for every material with metal items (SMELTING_TO_FLUID) | **done**: molten realgar, thorium, antimony, molybdenum; the fluid extractor melts the ingot, the solidifier casts the ingot and the nugget; 143 runs again after 155 (`FORK_CASTING.run`) and also casts the nuggets of #187 and #205 | |
| 6. New ingots: other parts | plates, foil, rods, bolts, screws, rings, springs, fine wire (realgar also gears and rotor) | **made in #222** (`158-fork-gt-parts.lua`, below) | |
| 7. Garnet decomposition | red garnet -> 3 pyrope, 5 almandine, 8 spessartine; yellow garnet -> 5 andradite, 8 grossular, 3 uvarovite (`addCentrifugeRecipe`) | **done** (155): pyrope, almandine and uvarovite dust; uvarovite's electrolysis (20 -> 3 calcium, 2 chrome, 3 silicon, 1200 oxygen, MV, 24 s); GT's use of the six garnet minerals in `BauxiteRefineChain.java` (dust + 1 nitric acid -> 1 sluice juice and six dusts by chance, MV, 2.25 s), the only GT use of pyrope and almandine | |

## GT's parts and the GTNH alignment of #222 and #223

Decisions of the maintainer (2026-10-09): #222 "all of them", #223 "as GTNH has it", the raw ore smelting completely.

- **Parts (#222, `prototypes/158-fork-gt-parts.lua`):** every item GT generates for realgar, thorium, antimony and
  molybdenum (`addMetalItems`, realgar `addGearItems`; `OrePrefixes.java` conditions, frame boxes for every metal,
  storage blocks of `LoaderGTBlockFluid.java`: not realgar): plate, double, dense and superdense plate, foil, rod, long
  rod, bolt, screw, round, ring, fine wire, small spring, spring, item casing, frame, block, realgar's gear, large gear
  and rotor, the nuggets of antimony and molybdenum and the small piles of their dust. Each with GT's main machine
  recipe (the file's header lists them) and 143's casts (the item casing cast is new in 143). Not made: the tool heads
  and turbine blades of GT's TOOL bit and GT's cells. The Material parts tab (200) has rows for double plates, item
  casings, small springs and springs.
- **Every metal (#227, decision after #222):** the rule "a part only where a recipe uses it" is gone. `tools/gen_gt_parts.py`
  reads GT's sources and writes `prototypes/gt-parts-data.lua` (per material: GT or GT++ source, GT mass, dust,
  processing or melting point voltage, blast furnace temperature, the forms GT generates); 158 makes the forms
  Gregtorio lacked: 1824 items for 117 metals (93 GT materials, 24 GT++ alloys with GT++'s forms and RecipeGen
  numbers), 2101 recipes, 982 more casts. GT's processing voltage (`setProcessingMaterialTierEU`) sets the tier of all
  of a material's recipes, else each recipe's own EU/t; GT++ alloys take the voltage of their melting point. Tiny and
  small piles of the platinum group are not made (their dust comes only from the platinum line, #199). 199's
  auto-unlock does not count 158's recipes as producers (`FORK_GT_PARTS.recipes`, like 143's casts). Without a GT or
  GT++ source (no parts): bartworks' and goodgenerator's Werkstoffe ruridit, rhodium-plated palladium and Incoloy-903
  and GT++'s element rhugnor (#228), and Gregtorio's own crystaltine, indovanadium, microversium, mixed metal, iridium
  alloy, RTM alloy and wrapped plutonium.
- **Nuggets (#223 B5):** GT's ingot -> 9 nuggets (alloy smelter with the mold) and nugget -> tiny pile of the dust
  (macerator) for 15 metals, with 9 tiny piles -> the dust at the crafting table.
- **Raw ore smelting (#223 B1, `ProcessingRawOre.java:118-198`):** the ingot of the direct smelting metal (if it needs
  no blast furnace), else the gem of the material, one per ore, never a dust; platinum as 2 metallic powder. 26 raw
  ores lost their furnace and multi smelter recipes, 15 smelt into GT's item and count, raw platinum and sheldonite
  got one. Kept against GT's rule: raw redstone, gypsum and calcite -> their dust: Gregtorio needs them before its first
  macerator (red alloy for the steam machines' pistons; firebricks and concrete of the Bricked Blast Furnace); without
  them devcheck finds no way to the logistic science pack. Raw ruby, emerald and diamond smelting into the gem is GT's
  (#223 had listed it wrongly). GT's blast furnace recipe of BLASTFURNACE_CALCITE_TRIPLE ores: raw iron + calcite or
  quicklime -> 3 iron ingots and dark ashes.
- **Bricked blast furnace (#223 B2, `ProcessingOreSmelting.java:84-99`, `RecipeMaps.java:902-990`):** 2 dusts of an
  ore that smelts into another metal -> 3 ingots with 2 coal, coal dust or charcoal (2 min, dark ashes at 2/9) or 1
  coke (80 s, GT's new Ashes at 1/9): cassiterite, galena, pentlandite, sphalerite, malachite, tetrahedrite (GT's
  special recipe with 9 antimony nuggets). Molybdenite and sheldonite have GT's DONT_ADD_DEFAULT_BBF_RECIPE.
- **Malachite (#223 B3):** GT's blast furnace recipe 2 dust + carbon -> 3 copper ingots, ashes, carbon dioxide. GT's
  ash centrifuge needs potash and banded iron, which Gregtorio lacks: the ashes have no use yet (#225).
- **Upstream extras (#223 A):** removed as listed in the table above; diamond dust gets GT's implosion (4 dusts, 32
  TNT -> 3 diamonds and 16 tiny piles of dark ash).
- **Electrolyzer tiers (#223 B4):** andradite and pyrite decompose at MV, as GT's 30 EU/t per output puts them.

## Appendix A: GTNH's numbers per step

### Byproduct index rule (`GTUtility.selectItemInList`, gregtech/api/util/GTUtility.java:2298)
`selectItemInList(i, self, mOreByProducts)`: empty list -> the material itself; i beyond the list -> the LAST entry (clamped); else entry i.

| index | used by |
|---|---|
| first entry (first hit of the loop) | ore / raw ore macerator byproduct (OP/ProcessingOre.java:129-143, OP/ProcessingRawOre.java:103-117), output as gem if the byproduct has a gem, else dust |
| 0 | crushed -> impure dust macerator (OP/ProcessingDirty.java:63), ore washer, both water variants (OP/ProcessingDirty.java:81, 101), impure dust centrifuge (OP/ProcessingDust.java:402-405) |
| 1 | thermal centrifuge of crushed (OP/ProcessingDirty.java:120) and of purified crushed (OP/ProcessingCrushedOre.java:74), purified -> pure dust macerator (OP/ProcessingPure.java:182), pure dust centrifuge (OP/ProcessingDust.java:402-405) |
| 2 | centrifuged crushed -> dust macerator (OP/ProcessingCrushedOre.java:54), refined dust centrifuge (OP/ProcessingDust.java:402-405) |
| self + all entries | chemical bath candidates (OP/ProcessingDirty.java:131-135), see below |

So: washer = byproduct 1st entry, thermal centrifuge = 2nd entry, macerating centrifuged crushed = 3rd entry; lists shorter than 3 repeat their last entry.

### Ore / raw ore -> crushed
| step | numbers | source |
|---|---|---|
| ore, macerator | 1 ore -> 2 x (mOreMultiplier x m) crushed (100%), primary byproduct 1 x (gem or dust) at 10% x m x mByProductMultiplier, stone dust of the ore's stone type 50%; 20 s, 2 EU/t. m = 2 for dense / nether / end ores if the matching config flag is on, else 1 | OP/ProcessingOre.java:56-69, 117-118, 236-265 |
| ore, forge hammer | 1 ore -> mOreMultiplier x m crushed (or gem if no crushed); 10 ticks, 16 EU/t | OP/ProcessingOre.java:227-234 |
| raw ore, macerator | 1 raw ore -> 2 x mOreMultiplier crushed, primary byproduct at 5% x mByProductMultiplier, dust of the prefix's secondary material 50%; 20 s, 2 EU/t | OP/ProcessingRawOre.java:214-242 |
| raw ore, forge hammer / hand hammer | 1 raw -> mOreMultiplier crushed; 10 ticks, 16 EU/t; also a shapeless craft with the hard hammer | OP/ProcessingRawOre.java:201-212 |
| fallback | no `crushed` item -> impure dust is used in its place | OP/ProcessingOre.java:121-127 |
| PULVERIZING_CINNABAR | ore-mac byproduct replaced by a Cinnabar crystal (Redstone) | OP/ProcessingOre.java:239-241 |
| defaults | mOreMultiplier = mByProductMultiplier = mSmeltingMultiplier = 1 (gregtech/api/enums/Materials.java:1200-1202); byproduct mult overrides in Materials.java:1514-1529 (Apatite 2, Lapis / Sodalite / Lazurite 4, Monazite 2, Cryolite 4, Coal 2) | |

### Crushed (also clump, shard, dirtyGravel) - OP/ProcessingDirty.java
| machine | numbers | line |
|---|---|---|
| forge hammer | crushed -> 1 impure dust; 10 ticks, 16 EU/t | 43-49 |
| macerator | crushed -> 1 impure dust (100%) + 1 dust of byproduct[0] at 10%; 20 s, 2 EU/t | 51-68 |
| ore washer, water | crushed + 1000 L water -> 1 purified crushed (100%) + 1 full **dust** (not tiny) of byproduct[0] at 11.11% + 1 stone dust (100%); 25 s, 16 EU/t | 70-88 |
| ore washer, distilled water | crushed + 200 L distilled water -> same outputs and chances; 15 s, 16 EU/t | 90-108 |
| thermal centrifuge | crushed -> 1 centrifuged crushed (100%) + 1 dust of byproduct[1] at 11.11% + 1 stone dust (100%); 25 s, 48 EU/t | 110-126 |
| chemical bath, mercury | first of [self, byproducts...] tagged `WASHING_MERCURY`: crushed + 1000 L mercury -> purified crushed 100% + 1 dust of that tagged material 70% + stone dust 40%; 40 s, 8 EU/t | 143-159 |
| chemical bath, mercury 99% | same, first tagged `WASHING_MERCURY_99_PERCENT` (Silver): byproduct at 99% | 160-176 |
| chemical bath, sodium persulfate | first tagged `WASHING_SODIUMPERSULFATE`: crushed + 100 L sodium persulfate -> purified 100% + 1 dust 70% + stone dust 40%; 40 s, 8 EU/t | 177-193 |

Bath rule: the subtag is checked on the ore itself AND on each byproduct (OP/ProcessingDirty.java:131-135); the bath's byproduct is the tagged material's dust. At most one mercury and one persulfate recipe per ore (`didMercury` / `didPersulfate`). No "doubling": it is a full dust at 70% (99%) versus the washer's 11.11%.
Tagged GT materials (MaterialsInit.java): WASHING_MERCURY = Gold (L753), Osmium (L1340), Platinum (L1425), Cooperite (L6218); WASHING_MERCURY_99_PERCENT = Silver (L1633); WASHING_SODIUMPERSULFATE = Cobalt (L496), Copper (L528), Nickel (L1237), Zinc (L2009), Cobaltite (L6195), Tetrahedrite (L9461).

### Purified crushed - OP/ProcessingPure.java, OP/ProcessingCrushedOre.java
| machine | numbers | line |
|---|---|---|
| forge hammer | purified -> 1 pure dust; 10 ticks, 16 EU/t | Pure 163-168 |
| macerator | purified -> 1 pure dust (100%) + 1 dust of byproduct[1] at 10%; 20 s, 2 EU/t | Pure 170-187 |
| thermal centrifuge | purified -> 1 centrifuged crushed (100%) + 1 dust of byproduct[1] at 11.11% (no stone dust); 25 s, 48 EU/t | CrushedOre 61-79 |
| sifter (only if the material has a gem) | purified -> exquisite / flawless / gem / flawed / chipped / dust. Default: 1% / 4% / 15% / 20% / 40% / 50%. "Precious" list (Tanzanite, Sapphire, Olivine, GreenSapphire, Opal, Amethyst, Emerald, Ruby, Amber, Diamond, FoolsRuby, BlueTopaz, GarnetRed, Topaz, Jasper, GarnetYellow): 3% / 12% / 45% / 14% / 28% / 35%; 40 s, 16 EU/t. Skipped: Salt, RockSalt, Spodumene (bartworks Werkstoff loader does them), Coal | CrushedOre 81-123 |

### Centrifuged crushed - OP/ProcessingCrushedOre.java
| machine | numbers | line |
|---|---|---|
| forge hammer | -> 1 dust; 10 ticks, 16 EU/t | 37-44 |
| macerator | -> 1 dust (100%) + 1 dust of byproduct[2] at 10%; 20 s, 2 EU/t | 46-59 |

### Impure / pure dust - OP/ProcessingDust.java:397-571
| machine | numbers | line |
|---|---|---|
| centrifuge (normal case: byproduct has a tiny dust) | 1 impure/pure dust -> 1 dust (100%) + 1 **full dust** of the byproduct (impure: [0], pure: [1]) at 11.11%; duration = mass x 8 ticks, 5 EU/t | 555-569 (pick 402-405) |
| centrifuge fallbacks | no tiny but small dust: 2 in -> 2 dust + 1 small dust, mass x 16 ticks; only dust/gem: 9 in -> 9 dust + 1 dust, mass x 72 ticks; only a cell: fluid/10; nothing: 1 -> 1 dust, mass ticks | 480-553 |
| electromagnetic separator (pure dust only) | tag GOLD / IRON / NEODYMIUM: 1 pure dust -> 1 dust (100%) + 1 small dust of Gold/Iron/Neodymium 40% + 1 nugget of it 20%; 20 s, 24 EU/t | 406-449 |
| autoclave (CRYSTALLISABLE and has a gem) | impure/pure dust -> 1 gem: 200 L water 90% / 95% (100 s); 100 L distilled water 95% / 100% (75 s); 36 L molten Void (quarter ingot) 100% (60 s); 24 EU/t. Plain dust: 70% / 90% / 100% | 450-479 (dust 269-298) |
| crystal / crystalline (OP/ProcessingCrystallized.java) | hammer -> 1 dust (10 ticks, 16 EU/t); macerator -> 1 dust (20 s, 2 EU/t), no byproduct | 229-241 |

### Output converters
All outputs go through `convert` / `convertOre`: goodgenerator/util/NaquadahRecipeOutputs.java:38-66 swaps Naquadah / NaquadahEnriched / Naquadria dusts for "naquadah earth" dusts; gtnhlanth/util/LanthanidesRecipeOutputs.java:43-85 swaps Cerium / Samarium dusts. So the Naquadah ore line in GTNH yields naquadah-earth dusts.


## Appendix B: GTNH data per Gregtorio ore

Material lines = `gregtech/loaders/materials/MaterialsInit.java` (`loadX()` start; byproduct and tag lines in parentheses). Byproducts are `addOreByproduct(() -> Materials.X)` in order. The idx columns apply the rule above (clamping, self fallback). Gem column: `addGemItems` or a vanilla gem item. EM sep: tag on the ore itself.
Bornite is not a GT Materials entry (bartworks Werkstoff). Sheldonite = Cooperite. Every other requested ore exists in GT5-Unofficial `Materials` with `addOreItems`. Salt and RockSalt also have bartworks Werkstoffs (bartworks/system/material/WerkstoffLoader.java:406, 430) that add gems and sifter recipes.

| Gregtorio | GT material (load line) | byproducts in order (line) | idx0: ore-mac primary, washer, crushed->impure mac, impure centrifuge | idx1: thermal centrifuge, purified->pure mac, pure centrifuge | idx2: centrifuged->dust mac | Hg bath byproduct | Na2S2O8 bath byproduct | EM separator | gem / sifter | autoclave (CRYSTALLISABLE) | ore mult / byproduct mult | notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| iron | Iron (L865) | Nickel (887), Tin (888) | Nickel | Tin | Tin | - | Nickel dust 70% (tag on Nickel, L1237) | - | no | no | 1 / 1 | BLASTFURNACE_CALCITE_TRIPLE (L889) |
| vanadium-magnetite | VanadiumMagnetite (L11695) | Magnetite (11710), Vanadium (11711) | Magnetite | Vanadium | Vanadium | - | - | Gold (L11712) | no | no | 1 / 1 | - |
| gold | Gold (L725) | Copper (748), Nickel (749) | Copper | Nickel | Nickel | Gold dust 70% (tag on Gold, L753) | Copper dust 70% (tag on Copper, L528) | - | no | no | 1 / 1 | - |
| gypsum | Gypsum (L10583) | (none -> every slot = self) | Gypsum | Gypsum | Gypsum | - | - | - | no | no | 1 / 1 | - |
| fullers-earth | FullersEarth (L10401) | Aluminiumoxide (10416), SiliconDioxide (10417), Magnesium (10418) | Aluminiumoxide | SiliconDioxide | Magnesium | - | - | - | no | no | 1 / 1 | - |
| copper | Copper (L500) | Cobalt (521), Gold (522), Nickel (523) | Cobalt | Gold | Nickel | Gold dust 70% (tag on Gold, L753) | Copper dust 70% (tag on Copper, L528) | - | no | no | 1 / 1 | - |
| tin | Tin (L1797) | Iron (1814), Zinc (1815) | Iron | Zinc | Zinc | - | Zinc dust 70% (tag on Zinc, L2009) | Iron (L1816) | no | no | 1 / 1 | - |
| cassiterite | Cassiterite (L5979) | Tin (5992) | Tin | Tin | Tin | - | - | - | no | no | 2 / 1 | direct smelting -> Tin |
| realgar | Realgar (L11218) | (none -> every slot = self) | Realgar | Realgar | Realgar | - | - | - | no | no | 1 / 1 | - |
| galena | Galena (L6441) | Sulfur (6453), Silver (6454), Lead (6455) | Sulfur | Silver | Lead | Silver dust 99% (tag on Silver, L1633) | - | - | no | no | 1 / 1 | direct smelting -> Lead |
| lead | Lead (L919) | Silver (937), Sulfur (938) | Silver | Sulfur | Sulfur | Silver dust 99% (tag on Silver, L1633) | - | - | no | no | 1 / 1 | - |
| silver | Silver (L1610) | Lead (1628), Sulfur (1629) | Lead | Sulfur | Sulfur | Silver dust 99% (tag on Silver, L1633) | - | - | no | no | 1 / 1 | - |
| cryolite | Cryolite (L10235) | Aluminiumoxide (10250), Sodium (10251) | Aluminiumoxide | Sodium | Sodium | - | - | - | no | no | 4 / 4 | - |
| tetrahedrite | Tetrahedrite (L9441) | Antimony (9456), Zinc (9457) | Antimony | Zinc | Zinc | - | Tetrahedrite dust 70% (tag on Tetrahedrite, L9461) | - | no | no | 1 / 1 | direct smelting -> Copper; INDUCTIONSMELTING_LOW_OUTPUT (L9460) |
| stibnite | Stibnite (L9384) | Antimony (9396) | Antimony | Antimony | Antimony | - | - | - | no | no | 1 / 1 | direct smelting -> Antimony |
| sulfur | Sulfur (L1674) | Sulfur (1687) | Sulfur | Sulfur | Sulfur | - | - | - | no | no | 1 / 1 | NO_SMELTING (L1690) |
| sphalerite | Sphalerite (L9311) | GarnetYellow (9321), Cadmium (9322), Gallium (9323), Zinc (9324) | GarnetYellow | Cadmium | Gallium | - | Zinc dust 70% (tag on Zinc, L2009) | - | no | no | 1 / 1 | direct smelting -> Zinc; INDUCTIONSMELTING_LOW_OUTPUT (L9326) |
| bauxite | Bauxite (L9986) | Grossular (10000), Rutile (10001), Gallium (10002) | Grossular | Rutile | Gallium | - | - | - | no | no | 1 / 1 | - |
| aluminium | Aluminium (L159) | Bauxite (179) | Bauxite | Bauxite | Bauxite | - | - | - | no | no | 1 / 1 | - |
| ilmenite | Ilmenite (L6585) | Iron (6598), Rutile (6599) | Iron | Rutile | Rutile | - | - | Iron (L6600) | no | no | 1 / 1 | - |
| redstone | Redstone (L11266) | Cinnabar (11284), RareEarth (11285), Glowstone (11286) | Cinnabar | RareEarth | Glowstone | - | - | - | no | no | 5 / 1 | PULVERIZING_CINNABAR (L11288); ore-mac primary byproduct replaced by Cinnabar crystal |
| ruby | Ruby (L7327) | Chrome (7343), GarnetRed (7344) | Chrome | GarnetRed | GarnetRed | - | - | - | gem, sifter precious table | no | 1 / 1 | NO_SMELTING (L7347) |
| cinnabar | Cinnabar (L6118) | Redstone (6130), Sulfur (6131), Glowstone (6132) | Redstone | Sulfur | Glowstone | - | - | - | no | no | 1 / 1 | direct smelting -> Mercury; INDUCTIONSMELTING_LOW_OUTPUT (L6134); SMELTING_TO_GEM (L6135) |
| coal | Coal (L6139) | Lignite (6155), Thorium (6156) | Lignite | Thorium | Thorium | - | - | - | gem, but excluded from sifter | no | 2 / 2 | NO_SMELTING (L6160); gem = minecraft:coal; ore-mac primary byproduct = Lignite gem |
| graphite | Graphite (L3508) | Carbon (3522) | Carbon | Carbon | Carbon | - | - | - | no | no | 1 / 1 | NO_SMELTING (L3525) |
| diamond | Diamond (L6280) | Graphite (6301) | Graphite | Graphite | Graphite | - | - | - | gem, sifter precious table | no | 1 / 1 | NO_SMELTING (L6305) |
| salt | Salt (L7367) | RockSalt (7379), Borax (7380) | RockSalt | Borax | Borax | - | - | - | no | no | 2 / 1 | sifter skipped: "handled by Werkstoff loader" (ProcessingCrushedOre.java:86-89) |
| rock-salt | RockSalt (L7246) | Salt (7259), Borax (7260) | Salt | Borax | Borax | - | - | - | no | no | 2 / 1 | sifter skipped: "handled by Werkstoff loader" (ProcessingCrushedOre.java:86-89) |
| lepidolite | Lepidolite (L10744) | Lithium (10758), Caesium (10759) | Lithium | Caesium | Caesium | - | - | - | no | no | 1 / 1 | - |
| nether-quartz | NetherQuartz (L4072) | Netherrack (4087) | Netherrack | Netherrack | Netherrack | - | - | - | gem, sifter default table | yes (L4089) | 2 / 1 | NO_SMELTING (L4091) |
| barite | Barite (L9951) | (none -> every slot = self) | Barite | Barite | Barite | - | - | - | no | no | 1 / 1 | - |
| certus-quartz | CertusQuartz (L3005) | Quartzite (3020), Barite (3021) | Quartzite | Barite | Barite | - | - | - | gem, sifter default table | yes (L3023) | 2 / 1 | NO_SMELTING (L3025) |
| apatite | Apatite (L9924) | TricalciumPhosphate (9940), Phosphate (9941), Pyrochlore (9942) | TricalciumPhosphate | Phosphate | Pyrochlore | - | - | - | gem, sifter default table | yes (L9944) | 4 / 2 | NO_SMELTING (L9946) |
| tricalcium-phosphate | TricalciumPhosphate (L11602) | Apatite (11617), Phosphate (11618), Pyrochlore (11619) | Apatite | Phosphate | Pyrochlore | - | - | - | gem, sifter default table | no | 3 / 1 | NO_SMELTING (L11624) |
| pyrochlore | Pyrochlore (L7177) | Apatite (7190), Calcite (7191), Niobium (7192) | Apatite | Calcite | Niobium | - | - | - | no | no | 1 / 1 | - |
| calcite | Calcite (L5941) | Andradite (5954), Malachite (5955) | Andradite | Malachite | Malachite | - | - | - | no | no | 1 / 1 | - |
| nickel | Nickel (L1212) | Cobalt (1230), Platinum (1231), Iron (1232) | Cobalt | Platinum | Iron | Platinum dust 70% (tag on Platinum, L1425) | Nickel dust 70% (tag on Nickel, L1237) | Iron (L1233) | no | no | 1 / 1 | - |
| pentlandite | Pentlandite (L11090) | Iron (11102), Sulfur (11103), Cobalt (11104) | Iron | Sulfur | Cobalt | - | Cobalt dust 70% (tag on Cobalt, L496) | Iron (L11106) | no | no | 1 / 1 | direct smelting -> Nickel; INDUCTIONSMELTING_LOW_OUTPUT (L11107) |
| cobaltite | Cobaltite (L6180) | Cobalt (6193) | Cobalt | Cobalt | Cobalt | - | Cobaltite dust 70% (tag on Cobaltite, L6195) | - | no | no | 1 / 1 | direct smelting -> Cobalt |
| lazurite | Lazurite (L6648) | Sodalite (6664), Lapis (6665) | Sodalite | Lapis | Lapis | - | - | - | gem, sifter default table | yes (L6667) | 6 / 4 | NO_SMELTING (L6669) |
| sodalite | Sodalite (L7502) | Lazurite (7518), Lapis (7519) | Lazurite | Lapis | Lapis | - | - | - | gem, sifter default table | yes (L7521) | 6 / 4 | NO_SMELTING (L7523) |
| lapis | Lapis (L10714) | Lazurite (10731), Sodalite (10732), Pyrite (10733) | Lazurite | Sodalite | Pyrite | - | - | - | gem, sifter default table | yes (L10735) | 6 / 4 | NO_SMELTING (L10737) |
| beryllium | Beryllium (L276) | Emerald (292) | Emerald | Emerald | Emerald | - | - | - | no | no | 1 / 1 | - |
| emerald | Emerald (L6348) | Beryllium (6369), Aluminiumoxide (6370) | Beryllium | Aluminiumoxide | Aluminiumoxide | - | - | - | gem, sifter precious table | no | 1 / 1 | NO_SMELTING (L6373) |
| thorium | Thorium (L1755) | Uranium (1771), Lead (1772) | Uranium | Lead | Lead | - | - | - | no | no | 1 / 1 | - |
| bastnasite | Bastnasite (L9966) | Neodymium (9980), RareEarth (9981) | Neodymium | RareEarth | RareEarth | - | - | Neodymium (L9982) | no | no | 1 / 1 | - |
| monazite | Monazite (L10931) | Thorium (10950), Neodymium (10951), RareEarth (10952) | Thorium | Neodymium | RareEarth | - | - | Neodymium (L10955) | gem, sifter default table | yes (L10954) | 8 / 2 | NO_SMELTING (L10957) |
| molybdenite | Molybdenite (L6816) | Molybdenum (6829) | Molybdenum | Molybdenum | Molybdenum | - | - | - | no | no | 1 / 1 | direct smelting -> Molybdenum |
| neodymium | Neodymium (L1157) | Monazite (1175), RareEarth (1176) | Monazite | RareEarth | RareEarth | - | - | - | no | no | 1 / 1 | - |
| grossular | Grossular (L6523) | GarnetYellow (6536), Calcium (6537) | GarnetYellow | Calcium | Calcium | - | - | - | no | no | 1 / 1 | - |
| spessartine | Spessartine (L9293) | GarnetRed (9306), Manganese (9307) | GarnetRed | Manganese | Manganese | - | - | - | no | no | 1 / 1 | - |
| pyrolusite | Pyrolusite (L7196) | Manganese (7208), Tantalite (7209), Niobium (7210) | Manganese | Tantalite | Niobium | - | - | - | no | no | 1 / 1 | - |
| tantalite | Tantalite (L11536) | Manganese (11549), Niobium (11550), Tantalum (11551) | Manganese | Niobium | Tantalum | - | - | - | no | no | 1 / 1 | - |
| bornite | not in GT Materials; bartworks Werkstoff `Bornite` (bartworks/system/material/WerkstoffLoader.java:335) | Copper, Iron, Sulfur (WerkstoffLoader.java:342) | Copper | Iron | Sulfur | - (bartworks checks only the Werkstoff's own tags, CrushedLoader.java:239) | - | Iron (auto, contains Iron: WerkstoffLoader.java:1833) | no | no | 1 / 1 | processed by bartworks CrushedLoader, not GT ProcessingDirty; Werkstoff byproduct list padded with self up to 3 (Werkstoff.java:371) |
| sheldonite | Cooperite (L6199) | Palladium (6213), Nickel (6214), Iridium (6215) | Palladium | Nickel | Iridium | Cooperite dust 70% (tag on Cooperite, L6218) | Nickel dust 70% (tag on Nickel, L1237) | - | no | no | 1 / 1 | direct smelting -> Platinum; local name "Sheldonite" |
| platinum | Platinum (L1404) | Nickel (1421), Iridium (1422) | Nickel | Iridium | Iridium | Platinum dust 70% (tag on Platinum, L1425) | Nickel dust 70% (tag on Nickel, L1237) | - | no | no | 1 / 1 | - |
| palladium | Palladium (L1365) | (none -> every slot = self) | Palladium | Palladium | Palladium | - | - | - | no | no | 1 / 1 | - |
| scheelite | Scheelite (L7432) | Manganese (7447), Molybdenum (7448), Calcium (7449) | Manganese | Molybdenum | Calcium | - | - | - | no | no | 2 / 1 | - |
| tungstate | Tungstate (L9511) | Manganese (9527), Silver (9528), Lithium (9529) | Manganese | Silver | Lithium | Silver dust 99% (tag on Silver, L1633) | - | - | no | no | 2 / 1 | - |
| pitchblende | Pitchblende (L11126) | Thorium (11139), Uranium (11140), Lead (11141) | Thorium | Uranium | Lead | - | - | - | no | no | 1 / 1 | - |
| uraninite | Uraninite (L9558) | Uranium (9570), Thorium (9571), Uranium235 (9572) | Uranium | Thorium | Uranium235 | - | - | - | no | no | 1 / 1 | - |
| chromite | Chromite (L6075) | Iron (6091), Magnesium (6092) | Iron | Magnesium | Magnesium | - | - | Iron (L6094) | no | no | 1 / 1 | direct smelting -> Chrome |
| ledox | Ledox (L13074) | (none -> every slot = self) | Ledox | Ledox | Ledox | - | - | - | no | no | 1 / 1 | - |
| naquadah | Naquadah (L1128) | NaquadahEnriched (1151) | NaquadahEnriched | NaquadahEnriched | NaquadahEnriched | - | - | - | no | no | 1 / 1 | - |
| firestone | Firestone (L3360) | (none -> every slot = self) | Firestone | Firestone | Firestone | - | - | - | gem, sifter default table | yes (L3376) | 1 / 1 | NO_SMELTING (L3379) |
| infused-gold | InfusedGold (L3719) | Gold (3732) | Gold | Gold | Gold | Gold dust 70% (tag on Gold, L753) | - | - | no | no | 1 / 1 | - |
| neutronium | Neutronium (L1182) | Neutronium (1204) | Neutronium | Neutronium | Neutronium | - | - | - | no | no | 1 / 1 | - |
| adamantium | Adamantium (L2773) | (none -> every slot = self) | Adamantium | Adamantium | Adamantium | - | - | - | no | no | 1 / 1 | - |
| black-plutonium | BlackPlutonium (L13009) | (none -> every slot = self) | BlackPlutonium | BlackPlutonium | BlackPlutonium | - | - | - | no | no | 1 / 1 | - |
| borax | Borax (L10138) | (none -> every slot = self) | Borax | Borax | Borax | - | - | - | no | no | 1 / 1 | - |
| bedrockium | Bedrockium (L13365) | (none -> every slot = self) | Bedrockium | Bedrockium | Bedrockium | - | - | - | no | no | 1 / 1 | - |
| infinity-catalyst | InfinityCatalyst (L13469) | (none -> every slot = self) | InfinityCatalyst | InfinityCatalyst | InfinityCatalyst | - | - | - | no | no | 1 / 1 | - |
| cosmic-neutronium | CosmicNeutronium (L13390) | (none -> every slot = self) | CosmicNeutronium | CosmicNeutronium | CosmicNeutronium | - | - | - | no | no | 1 / 1 | - |
