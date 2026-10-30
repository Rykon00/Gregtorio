# Notes for AI agents

- **Language:** everything that ends up on GitHub is English (code, comments, log messages,
  locale, commits, PRs, issues, docs). Chat with the maintainer may be in German.
- Read `CONTRIBUTING.md` and the layout table in `README.md` first.
- Upstream content lives in `prototypes/0*-*.lua` … `98-technology.lua`; keep changes there minimal. Fork logic lives in
  `prototypes/1xx-fork-*.lua`, loaded at the end of `data.lua` in this order:
  - 100 fixes (issue #547: the allow-list `FORK_TRIGGER_ONLY_ITEMS`; devcheck fails for an item whose only use is a
    technology's craft-item trigger: no recipe or research unit takes it, it places, fuels or plants nothing; issue #555: the torch
    `gt-torch`, a lamp with a void energy source, always on, walkable, from the recipes `torch` (coal) and
    `torch-from-charcoal` of the technology Torches (vanilla's `lamp`); vanilla's electric lamp keeps its name Lamp with
    the LV assembler recipe `small-lamp-lv-assembler` (Automation 2), placed lamps of old saves become torches
    (`migrations/2026-10-24-issue-555-torch.json`); graphics from `tools/gen_icons.py --drawn`)
  - 101 machines (issue #446: the steam age of GTNH, the high pressure machines, the steam furnace, the lava and solar
    boilers; issue #447: the steam macerator's copies of the LV macerator recipes without byproducts,
    `fork_steam_categories()` at the end of data-final-fixes.lua; issue #571: its `steam_ore_unlocks()` unlocks the copies of
    the ore forms with the later of Steam Macerator and the first technology that makes their input (only into the
    prerequisites of the original's technology, only when something takes each product there) and moves the furnace
    recipes of their products with them; Steam Macerator needs Steam Forge Hammer (142); devcheck fails for a later copy
    unless it is in `FORK_STEAM_LATE` (empty: issue #573 made Reach the Nether need Steam Macerator); issue #586: `nugget_ingot_unlocks()` right after it unlocks every `<metal>-ingot-from-nuggets` with the first technology that has its nugget (an ore form's furnace recipe) and its ingot mold (Steel Processing), only into the prerequisites of where it was (GTNH: the steam alloy smelter with the steel ingot mold is the only way, the table recipe is removed); devcheck fails for a technology whose ore form smelting gives a nugget without a nugget -> ingot recipe there or before unless `<technology>:<nugget>` is in `FORK_NUGGETS_BEFORE_INGOTS` with its reason, and for a nugget -> ingot recipe later than its nugget and mold; issue #449: the LV combustion generator, extruder and laser
    engraver, the LV categories run by every MV machine through `fork_lv_machine_categories()` in 199; issue #560, section
    2n: every machine whose categories are all of the ore line (macerator, ore washer, thermal centrifuge, centrifuge, the
    steam macerators' copies) becomes a `furnace` that picks its recipe from its input, by `fork_furnace_machines()` at the
    end of data-final-fixes.lua after `fork_steam_categories()`, so every file before it sees assembling machines; a
    furnace takes one input fluid box at most (the inputs are merged) and an item of an item and fluid recipe only with
    the fluid in it; devcheck fails for two recipes with the same inputs in a furnace machine's categories unless the
    group is in the allow-list `FORK_FURNACE_SAME_INPUTS` with the recipe that wins, and for a recipe there a furnace
    cannot run; old saves: the engine deletes a machine whose type changed, so the JSON migration makes them hidden
    `legacy-<name>` assemblers and `scripts/fork-ore-furnaces.lua` rebuilds them)
  - 102 resources
  - 103 QoL techs (re-gates the vanilla inserter, belt and worker robot techs of issue #29 onto Gregtorio techs, GT
    recipes for bulk/stack inserters and express/turbo belts)
  - 110 LuV
  - 120 the ME network on Gregtorio's tiers (issue #83: the ME network is the mod **me-network**,
    https://github.com/Rykon00/me-network, a dependency; `prototypes/120-fork-me-network-compat.lua` gives its items
    Gregtorio's GT recipes and its nine technologies Gregtorio's tiers through me-network's data-stage API `ME_NETWORK`,
    and builds the molecular assembler from the HV assembler; the ME items of the upstream file 13 are me-network's,
    their recipes are in the compat file; plan and record: `docs/SPLIT.md`; issue #214: every recipe of
    `ME_NETWORK.recipes` gets a GT recipe there, as in GTNH's AE2 where it has one, registered in `FORK_ME_RECIPES`, and
    devcheck fails for one that keeps me-network's standalone recipe unless it is in the allow-list
    `FORK_ME_RECIPES_STANDALONE` with its reason; issue #580: every item rename of a JSON migration is told to the network
    with `ME_NETWORK.replace_item`, from `prototypes/data/item-renames.lua`, which `devcheck.py check --item-renames`
    writes from `migrations/*.json`: after a new item rename in a JSON migration run it, `check` fails until the table
    matches)
  - 125 LuV endgame (naquadah: upstream's goodgenerator line with GTNH's numbers and missing recipes, issue #205;
    bacterial vat, crystal processors, fusion MK1)
  - 126 ZPM
  - 127 UV (UV circuit, ZPM assembly line, UV components, fusion MK2)
  - 128 UHV (wetware line, tritanium, UHV components, fusion MK3)
  - 129 water purification (grades 1-8, NPIC/PPIC/QPIC/FPIC/APIC chips, complex SMDs (Gregtorio's stand-in for GT's
    optical SMDs, #259); the FPIC/APIC users in 131-134
    list its techs as prerequisites)
  - 131 UEV (bio line, UEV components, fusion MK4)
  - 132 UIV (optical line, UIV components)
  - 133 UMV (fusion MK5, spacetime, exotic line, UMV components; also the shared helpers, global table `FORK5B`)
  - 134 UXV (universium, temporal line, UXV components)
  - 135 endgame (stargate, MAX science pack; researching `victory` wins the game via `scripts/fork-victory.lua`)
  - 136 power (plasma fuel values, plasma balance of issue #32, issue #375: GTNH's fusion transmutations (section 1c) and its other plasmas (section 1d; issue #397: lead plasma), large plasma turbines with turbine output hatches,
    naquadah fuel line, large naquadah reactors, dynamo hatches LuV to UXV; runtime in `scripts/fork-power.lua`: fuel
    check, turbine output hatch with a ratio per fluid and the generator's effectivity from the mod data, used by 145's
    steam turbines, and the passive loss of 145's supercapacitors, mod data `capacitors`, and the carry-over of their
    energy when another tier replaces them, issue #124)
  - 137 endgame materials (issues #39 and #36: deletes the drafts removed for good, `FORK-REMOVED` in the log; the
    lapotronic energy orb cluster and high density plutonium drafts; super coolant, the 1080k super coolant cell, fluxed
    electrum, bedrockium and quantium with the stand-ins they replace; must load after 136, whose plutonium fuel and
    dynamo hatches it changes)
  - 139 endgame multiblocks (phase 6a, issue #37: the dimensionally transcendent plasma forge with its catalysts and
    metal recipes, the quantum force transformer and its recipes, issue #249 its rare earth recipes; loads after 137
    and **before** 138, which sets the
    unit counts of its technologies; phase 6b hooks are marked `6b hook`)
  - 140 godforge (phase 6b: the godforge, raw star matter, magmatter, the stellar catalyst of the plasma forge, the
    infinite `godforge-upgrades`; issue #249: quark gluon plasma and GT's rhugnor MK5 recipe; issue #355: the godforge between
    the UIV and UMV energy hatches with GT's recipes (issue #624: at UIV science, the DTPF at UEV, the space elevator at UV with
    the new technology Cosmic Neutronium), the plasma module technology with celestial tungsten)
  - 141 MAX tier (phase 6b: magmatter parts, the Planck line and MAX circuit, MAX components, hatches, machines and
    turbine; needs 140's magmatter and adds its turbine to 136's mod data; issue #249: the MAX recipes of the plasma
    forge and the QFT with substitutes); 140 and 141 load after 139 and **before** 138
  - 138 research balance (issue #30: explicit unit counts of the technologies from UV to `victory`; loads after every
    file that defines technologies up to 141; issue #605: the table also names the UV+ technologies of 145 to 166, and
    `FORK_RESEARCH_BALANCE.apply()` runs once more at the end of data-final-fixes.lua; devcheck fails for a researchable
    technology of 9 or more packs whose count lies outside the band of its pack count (from 50, or the table's lowest at
    that pack count, to the table's highest) unless it is in `FORK_RESEARCH_OUTLIERS`: a new UV+ technology gets its
    scaled count in the table; balance passes use `tools/balance_model.py` on `devcheck.py check --balance-out`)
  - 147 GT routes (issue #98: the PECA board deleted, sodium persulfate, black plutonium and cosmic neutronium through
    the blast furnace and vacuum freezer, the high octane line, GT's deuterium and PPIC wafer; loads after 138 and
    **before** 142, whose block `UNLOCKS_98` unlocks its recipes, and 143, which casts the black plutonium ingot)
  - 146 platinum line (issue #96: GTNH's bartworks line instead of upstream's GTCEu line of 19, platinum, palladium and
    the rhodium, ruthenium, osmium and iridium branches, the direct platinum and palladium dust recipes turned into
    metallic powder; loads after 147 and before 142, block `UNLOCKS_96`; old saves map the removed intermediates with
    the JSON migrations of `migrations/`)
  - 160 dimension mines (issue #283, decision of #154: Reach the Nether/End technologies, hunting blazes, Endermen
    and (issue #287) zombies, molybdenum vein, soul sand, end stone, nether/ender air intakes; radon from ender air at
    HV; issue #284: Reach the Moon / Reach Mars with their veins and the moon turf dig site; issue #285: Reach the
    Asteroid Belt, the Jovian Moons and Venus; issue #286: Void Miners I-III, `VOID_POOLS` from GT's veins and small
    ores (tools: none, generated once from OreMixes/SmallOres); issue #293: Reach Ross128 with the copper sulfide vein
    (bornite); issue #332: the Twilight Forest's Manual Mine recipes, unlocked with NAND Chips (no technology of
    their own): the amber vein and the topaz and amber small ores, the raw ores of GT's orange lens (155 makes the amber lens), and
    (issue #364) the sapphire vein and the sapphire small ore (sapphire, green sapphire; 155 their chain and juice; issue
    #370: the sapphire vein with the Laser Engraver, the first consumer of GTNH's sapphire and green sapphire lens;
    issue #373: its almandine and pyrope ores, GT's byproducts basalt, black granite and rubidium, chalcopyrite's
    bricked blast furnace recipes with ferrosilite);
    issue #363: GTNH's Overworld veins (new Manual Mine recipes, or GT's missing ores joining upstream's vein of the same
    name) with 30 raw ores, 155's `NEW_ORES` gives them GTNH's chain, decomposition and smelting; part 2: the Twilight
    Forest's olivine vein, the Nether's saltpeter vein, garnierite, wulfenite and powellite in upstream's veins, the
    Twilight Forest's small ores (16 more ores; the olivine, tanzanite and amethyst lenses); issue #365: Mars's desh vein; issue #373:
    every vein of Ross128b (Reach Ross128) and Ross128ba (Reach Ross128ba, ZPM) with bartworks' ores (155's `NEW_ORES`);
    the Toxic Everglades' veins GTPP0-19 (Reach the Toxic Everglades, LuV) with GT++'s ores, whose dehydrator
    decompositions 161 unlocks through `FORK_ORE_CHAIN.unlock_after_159` (159 makes the dehydrators after 155); Neper's
    pool for the Void Miner III (dilithium, mysterious crystal, vinteum); issue #636: Phobos's and Deimos's mines (draconium,
    oriharukon, heavy pentele) with Reach Mars, a Void Miner pool for every other void-minable dimension of T3 to T9 (Seth's raw
    tengam and tartarite, Maahes's naquadria), the Deep Dark's Void Miner III recipe with every raw ore in 161; issue #563: the veins of Nauvis, the Nether and
    the Twilight Forest that #505 deleted here are 166's generated classic recipes, not 160's; loads after 146 and
    **before** 142 (issue #287: the unlock table of 142 and the ore chains of 155 see the mines; the rules are in 161))
  - 162 space elevator (issue #301, part 1 of #292's decision: gtnhintergalactic's Space Elevator in GTNH's full scope:
    controller, casings, nanotube spool, cable, motors Mk-I to Mk-V; one 11 x 11 entity per motor tier
    (`space-elevator-mk1` to `-mk5`), the mod data `fork-space-elevator` with each tier's motor tier and module slots for
    the modules of #302 and #303; issue #302: the Mining Modules Mk-I to Mk-III, the mining drones LV to UXV, their drill
    heads and a recipe per asteroid and drone tier (`ASTEROIDS` from gtnhintergalactic's SpaceMiningRecipes, the ores the
    mod has, expected amounts of one operation; helium plasma only); `scripts/fork-space-elevator.lua` runs a module only
    next to an elevator with motors of its tier and a free slot (event-driven, `on_object_destroyed`, no tick handler,
    `storage.fork_space_elevator`); issue #318: GTNH's distillation of the pump modules' heavy and light oil (tall
    distillation, distillery, lubricant), with the pump module's technology; issue #485: the Assembler Module Mk-I and
    GTNH's Singularity ME Storage Cell in it (its Eternal Singularity in the UMV compressor, a named stand-in for the
    black hole compressor); loads after 160 and **before** 142)
  - 163 electric mine (issue #335: GTNH's Ore Drilling Plants Mk I to IV (`ore-drilling-plant-mk1` to `-mk4`, MV to IV,
    the Mk changes speed and energy only) on the Manual Mine's footprint and fast replace group, the Manual Mine's
    `next_upgrade` is the Mk I; one electric twin `drilling-<vein>` of every `mining-<vein>` recipe of the Manual Mine
    (category `electric-mine-recipes`, the same results, Drilling Fluid and (issues #341, #346, #393) 1 mining pipe, consumed,
    instead of the pickaxe and manual labor); GTNH's
    Drilling Fluid from the mixer with the Mk I's technology; the twins of veins before the Mk I come with its technology,
    the later ones with their vein's technology; devcheck fails for a Manual Mine or Dig Site recipe without a twin unless
    it is in the allow-list `FORK_ELECTRIC_MINE_EXCLUDED` with its reason; issue #337: GT's Miners LV to HV (`lv-miner` to
    `hv-miner`, upgrade chain Manual Mine -> LV -> MV -> HV Miner -> Mk I) with their twins `miner-<vein>` that use up 1
    mining pipe, technology `lv-miner` (its later twins are unlocked by
    `FORK_ELECTRIC_MINE.unlock_miner_twins()`, which 142 calls after its moves); issue #342: the mod data `fork-electric-mine`
    (recipe -> vein, vein -> recipe per category) for `scripts/fork-electric-mine.lua`; issue #499 (plan #494, the
    maintainer's option A): the recipe machines are the **dimension mines** (`dimension-mine`, `lv-dimension-miner` to
    `hv-dimension-miner`, `dimension-drilling-plant-mk1` to `-mk4`) for the vein recipes of the other dimensions, and
    their old names are `mining-drill`s of the map veins (resource category `gt-ore`: Manual Mine burning manual labor,
    7x7; Miners GT's radius 8/16/24 with 9 mining pipes in their recipe; Ore Drilling Plants radius 40/48/64/96, 80 % and
    60 % drain from the Mk III) at today's rates; a vein recipe whose results are all Overworld map ores is hidden with
    its twins (kept for old saves until V9); hunting, cobblestone and end stone are Dig Site recipes (issue #547: the stone
    pickaxe's cobblestone `cobblestone-manual-mine-with-stone-pickaxe`, Craft Stone Tools); a drill's fluid box
    only works while its ore needs a fluid, so the plants' Drilling Fluid goes into a hidden storage tank
    `ore-drilling-plant-fluid-input` on their tiles, which `scripts/fork-ore-drills.lua` builds and drains per ore;
    `migrations/2026-10-22-issue-499-dimension-mines.json` renames placed mines of old saves to their dimension mine;
    issue #563: `FORK_ELECTRIC_MINE.make_twins(name)` makes the two twins (also of 166's classic recipes); in classic mode
    (`FORK_CLASSIC_ORES`) the mining drills are hidden, without a recipe, unlock or next upgrade, their items place the
    dimension mine of their tier, the dimension mines and their technologies take the names and texts of 0.5.5 (Manual
    Mine, LV-HV Miner, Ore Drilling Plant Mk I-IV, `classic-*` locale keys), and 142 leaves `unlock_dimension_mines` to
    166; loads after 162 and **before** 142)
  - 142 recipe unlocks (issue #91: every Gregtorio recipe gets a technology from its explicit table `UNLOCKS`, the
    producers GT has and Gregtorio lacked and the component assembly line; a recipe that must stay
    locked goes into the allow-list `FORK_RECIPES_LOCKED` with its reason, devcheck fails otherwise; issue #237: a
    recipe a technology unlocks must be makeable with the technologies of that science (the highest pack in
    `SCIENCE_ORDER` of devcheck.py), devcheck names the cause and fails unless it is in the allow-list
    `FORK_UNLOCK_GAPS` (`<technology>:<cause>`); a technology's science is the highest of its own and its prerequisites'
    packs (#239); issue #252, the maintainer's rule: every item and fluid is unlocked at the technology where it can
    first be consumed, never later, so devcheck's tree check fails for an ingredient (or the machine of a recipe's
    category) that neither the recipe's technology nor one in its prerequisite closure makes (nor the start), unless
    `<technology>:<item>` is in the allow-list `FORK_UNLOCK_TREE_GAPS` with its reason; fix a finding by moving the
    producer up to its first consumer when the producer's own inputs are there (`move_unlock`), by making the producer's
    technology a prerequisite when it is on another branch of no higher science (`FORK_UNLOCK_TREE.prerequisites`,
    applied in 142 for 155/158's `unlock_after` and again in data-final-fixes.lua after the vanilla prerequisites), and
    only when the producer's own chain is late (platinum, a tier's energy hatch, the advanced SMDs) by moving the
    consumer to the producer's technology; `FORK_UNLOCK_TREE.keep` pins recipes of 155/158 that would otherwise land on
    a technology of higher science; `KEEP` pins what the auto-unlock of 199 placed before, so new unlocks do not move
    it; issue #556, the other half of the rule: a machine comes with its first recipe, so devcheck fails for a
    technology that unlocks a machine before any recipe the machine runs is enabled or unlocked by it or its prerequisites,
    unless `<technology>:<machine>` is in the allow-list `FORK_MACHINES_BEFORE_RECIPES` with its reason (a machine
    technology right before its recipes' one, the tier copies of the LV brewery, fermenter and rock crusher); 163's
    `FORK_ELECTRIC_MINE.unlock_dimension_mines()`, which 142 calls after its moves, unlocks each dimension mine with the
    first technology of a recipe it runs or its own technology, whichever is later)
  - 143 casting (issue #91: solidifier casts of every form and extractor melts of every ingot from its table `MATERIALS`
    (tier, technology, the colour of a new melt); 199's auto-unlock ignores these recipes (`FORK_CASTING.recipes`), else
    an ingot would count as its own producer; must load before 150, whose molds it needs, and before 196, 198 and 199;
    `FORK_CASTING.run` runs once more at the end of 155 for the ingots and nuggets 155 makes, issue #207)
  - 145 power multiblocks (issue #97: the large steam turbine and the high pressure steam turbine as generators of 136
    with superheated steam, the fluid nuclear reactor (burner recipe machine for the fuel rods) and the large heat
    exchanger with coolant and hot coolant, the lapotronic supercapacitor as an accumulator per capacitor tier (IV, LuV
    and ZPM upgrades); issues #254 to #256: the large titanium boiler (a `boiler` in `output-to-separate-pipe` mode,
    water to superheated steam), the large combustion engine and the large gas turbine (EV burner generators on the fuel
    cells); issue #295: GT++'s EV, IV and LuV rocket engines on the H8N4C2O4 rocket fuel cell (fuel category
    `rocket-engine-fuel`; the fuel's GTNH recipe and the Chemical Plant's move to Rocket Fuel are in 159); issue #444: GTNH's LV to HV
    batteries and the battery buffers (accumulators of a fixed size, the batteries in the recipe; technology Large Batteries); issue #637: the EV and IV gas turbines and semifluid generators (section 9) and GT++'s advanced boilers (section 9b); issue #614: the EV and IV buffers (section 8b) with GTNH's tier batteries, the lapotron crystal (its chain moved from the ZPM Assembly Line to Lapotron Crystals, EV) and the lapotronic energy orb (moved to Lapotronic Energy Orb, IV); their technologies are named in 142's `UNLOCKS`, so it loads after 138 and **before** 142, and
    before 196 for its fluids; it takes 136's generator from the global `FORK_POWER` and adds to its mod data
    `fork-power`)
  - 144 dead fluids (issue #91: GT's uses and producers of fluids nothing made or used; the blast furnace gas variants
    of `EBF_GASES` are in `FORK_GAS_VARIANTS`, which 199's auto-unlock ignores like the casts)
  - 148 GTNH table items (issue #126: GTNH's machine recipes for the anvil, the firebrick block and paper, which the
    crafting table made; the reachable hand-only vanilla recipes (firearm magazine, light armor, rail ramp and support,
    wood processing) moved into `crafting-or-assembling-recipes`; the allow-list `FORK_RECIPES_TABLE_ONLY` of recipes of
    items that only the crafting table, the ME Molecular Assembler or the hand make, each with its reason; devcheck
    fails for a reachable item whose every recipe is such a recipe and not in it; GT's crafting tools of issue #612:
    `<tool>-usage` charges (hammer, file, saw, screwdriver, wire cutter, wrench, knife) from iron, bronze or steel, one
    recipe per material, and the charges added to the `crafting-table-recipes` of the parts by GT's shapes (`FORK_TOOLS`
    maps a tool to its item); loads after 144 and before 150)
  - 149 early research (issues #127 and #146: the unit counts of the technologies with red and green packs only, 80 and
    more, divided by 6, those of MV to IV by 10, 13, 19 and 16; data-final-fixes.lua calls
    `FORK_EARLY_RESEARCH.rescale()` for the technologies whose units it sets later; the cheap research setting wins)
  - 151 fluid extractor (issue #152: GTNH's Fluid Extractor `<tier>-fluid-extractor` LV to MAX, copies of the Extractor
    of their tier with its recipe and technology; every extractor recipe with a fluid result moves to
    `<tier>-fluid-extractor-recipes`, the Extractor keeps the item recipes, the Large Fluid Extractor runs the fluid
    ones; a technology that unlocks an LV melt without leading to the LV fluid extractor gets its technology as a
    prerequisite; devcheck fails for a fluid result in an extractor category or an item-only recipe in a fluid extractor
    category; loads after 149 and before 150)
  - 153 compressor air (issue #153: GTNH has no air collector; the recipe `air-collection` (name kept) is a compressor
    recipe, every electric compressor has the old air collector's two output ports, the air collectors LV to MAX are
    gone and old saves map them onto the compressor of their tier with
    `migrations/2026-10-06-issue-153-air-collector.json`; loads
    after 142 and 149 and before 150)
  - 154 greenhouse (issue #165: `lv-greenhouse` (name kept) is GTNH's Extreme Industrial Greenhouse, the only
    greenhouse; the MV to MAX greenhouses are gone and old saves map them onto it with
    `migrations/2026-10-06-issue-165-greenhouse.json`; loads after 153 and before 150)
  - 155 ore chain (issues #185 to #188, plan `docs/ORE-CHAIN.md`: O2 adds the chemical bath washing with mercury and
    sodium persulfate, checked against `ORE_BATHS` in devcheck; O3 the electromagnetic separator recipes (machine in
    101) with small dusts and nuggets, O4 gem sifting with the grade items and their uses, the autoclave and forge
    hammer crushing, checked against `ORE_SEPARATOR` and `ORE_GEMS`; #193 the laser engraver grade steps
    (`ORE_GEM_LENS`), dark ash, small gem piles, the LV autoclave (machine in 101); the unlocks of O3 and O4 come from
    `unlock_after` (first technology after the machine and the input); #202 and #205: GTNH's raw ore crushing (hammer
    gems, macerator byproducts, GT's ore multipliers), the byproduct gems with their grades, GT's dust -> gem routes,
    the furnace recipes of the ore forms with new nuggets and ingots, goodgenerator's earths (2 naquadah oxide mixtures
    per naquadah dust); GTNH's purified, centrifuged, impure and pure forms from the table `ORE_CHAIN` of GTNH's
    byproducts per ore, the thermal centrifuge recipes (machine in 101), the shortcut recipes removed and mapped by JSON
    migration; #203: gypsum, sulfur and calcite with GTNH's crushed ore and chain (malachite); #207: a multi smelter
    recipe for every furnace recipe of the chain, GT's garnet minerals (pyrope, almandine, uvarovite), crushed platinum
    smelting, the melts of #205's ingots; devcheck fails for a gap in an ore's chain or a washer shortcut; issue #325: every
    laser engraver recipe takes GTNH's lens (150 turns it into the lens slot), devcheck fails for one without a lens unless
    it is in the allow-list `FORK_ENGRAVER_NO_LENS` with its reason; issue #388: a technology that still names a recipe
    155 removes for good fails devcheck (`FORK-STALE-UNLOCK`; the washer and centrifuge shortcuts the chain replaces stay
    in 98 and 142 as the anchors 155 takes the chain's technologies from), the raw ores without a furnace recipe say so
    in their description; issue #427: GTNH's cauldron (machine in 101, with Rubber) washes every ore's impure and pure dust
    into its dust (`cauldron-impure-<ore>-dust`, `cauldron-pure-<ore>-dust`, with the technology of the dust recipe it
    takes), checked by devcheck's ore chain rule; GT's crushed -> purified cauldron recipe is left out on purpose; loads
    after 154 and before 150)
  - 158 GT parts (issues #222, #223, #227 and #228: GT's parts of every metal from `prototypes/gt-parts-data.lua`
    (regenerate it with `tools/gen_gt_parts.py` after a `devcheck.py check` when a metal is added; sources: GT
    materials, GT++ alloys and elements, bartworks and goodgenerator Werkstoffe with their own recipe numbers) and GT's
    nugget recipes, unlocked with 155's `unlock_after` through `FORK_ORE_CHAIN`; loads after 155 and before 150; issue
    #467: its sections 1 and 2 are `FORK_GT_PARTS.run()`, run again at the end of 164 (section 38) for the metals whose
    ingot comes later; #223
    also aligned 155's raw ore smelting with GT's rule, keeping raw redstone, gypsum and calcite -> dust for the early
    game; issue #687: section 3 of the run, GT's recipes of the cutting machine (water, distilled water, lubricant,
    dimensionally shifted superfluid), bender, extruder, wiremill, forge hammer, fluid solidifier and lathe that Gregtorio
    lacks, `gt-<verb>-<product>-from-<input>` from `prototypes/data/gtnh-part-routes.lua`, which `devcheck.py check
    --gtnh-routes` writes from the dump through `tools/gtnh_map.py` (`route_imports`); `check` fails when it is out of
    date; a route Gregtorio has with other numbers is #689's table's, not a second recipe; issue #690: the cable map's
    insulation, `gt-insulate-<cable>-from-<wire>-with-<fluid>(-and-<pulp>)`; issue #688: section 4, GT's
    crafting table recipes of the parts and dust piles that Gregtorio lacks, GT's tools as #612's charges, from
    `prototypes/data/gtnh-part-crafting.lua` (`devcheck.py check --gtnh-crafting`, `crafting_imports`); a recipe of
    sections 3 and 4 is made only with a technology after its inputs, and `FORK_GT_PARTS.drop_locked_routes()` in
    data-final-fixes.lua drops one that only a disabled vanilla technology unlocked; issue #691: section 3 takes GT's
    chemistry and separation recipes too (distillery, electrolyzer, autoclave, centrifuge, chemical reactors, mixer,
    chemical bath; `prototypes/data/gtnh-chemistry.lua`, `devcheck.py check --gtnh-chemistry`, `route_imports` with
    `CHEM_IMPORT`: no ore chain forms, no GT cells, only categories with the machines' fluid boxes), turns a platinum
    group dust into the platinum line's powder as 157, and `drop_locked_routes()` also drops an imported recipe whose
    input nothing makes at its technology or before once 161 has moved the dimensions' chains)
  - 159 lanthanides (issue #262: gtnhlanth's monazite rare earth line with the Digester and the Dissolution Tank, from
    crushed monazite to samarium and gadolinium dust; the samarium dust placeholder of 19 is removed, the sifting
    machines get a fluid input and output, technology `monazite-rare-earth-processing` before LuV Components; issue
    #269: the bastnasite line to neodymium and lanthanum and the cerium line, technologies
    `bastnasite-rare-earth-processing` and `cerium-processing`; issue #272: europium, zirconium, lanthanum
    hexaboride and the samaric branch with GT++'s ExxonMobil Chemical Plant and the MV/HV Dehydrators, technologies
    `europium-processing`, `zirconium-processing`, `lanthanum-hexaboride`, `samaric-rare-earth-processing`; issue
    #274: hafnium from GT++'s ilmenite sifter, the EV-ZPM Chemical Dehydrators with their coils (technologies
    `<tier>-chemical-dehydrator`), lanthanum hexaboride's gem forms, chloromethane, gangue and the roasting's fluorine;
    loads after 158 and before 156)
  - 164 chemistry (the GTNH gap research after 0.5.4, issues #355 to #367, and later sections: #436 dragonblood and
    hypogen in 35, #355 step 5's Nano Forge in 36 and YPIC in 37, #467's second run of 158 in 38, #487's Singularity crafting storage and void cells in 39, #489's Draconic Evolution Fusion Crafter and cores in 40 and its Chaotic Core and Reactor Stabilizer in 41; GTNH's chemical lines Gregtorio lacked, GT's
    numbers, fluids a tenth of GT's litres, GT++'s catalysts left out; issue #362: GT++'s Rp-1 Rocket Fuel, Dense
    Hydrazine Fuel Mixture and CN3H7O3 Rocket Fuel with their cells for 145's rocket engines, the coal tar line and the
    anthraquinone process to hydrogen peroxide and hydrazine, the ExxonMobil Chemical Plant's extra fluid boxes; issue #360:
    the recipes of 101's Brewery and Fermenter (technology Fermentation), fermented biomass, seed oil from the
    greenhouse's wheat seeds, bio diesel, glycerol and its epichlorohydrin; issue #358: the bisphenol A route to epoxy,
    polystyrene, styrene-butadiene rubber (with its cable recipes) and polycaprolactam; issue #361: the drilling rigs'
    Overworld fluids of GTNH (light, raw and heavy oil, natural gas), raw oil's distillation, natural gas, LPG and the MTBE
    route; issue #366: trichlorosilane, GTNH's second route to poly-si; issue #357: GoodGenerator's liquid fuels (ether,
    ethanol gasoline, cyclopentadiene and naquadah gas cells, the ferrocene line to Jet Fuel No.3 and Jet Fuel A, the
    combustion promoter), the Universal Chemical Fuel Engine and the thorium based liquid fuel; issue #355: the ASoC wafer
    and chip with their circuit variants, the energy module's ASoC wafers; issue #359: GT's dual and quad fuel rods and
    the MOX rods; issue #378: the Kevlar line's side chemicals (section 10, technology Kevlar) and the Kevlar line (section 11;
    the UXV pump, conveyor and hull take Kevlar, 143's casting runs once more for the Kevlar ring) and radox polymer
    (section 12, technology Radox Polymer, stand-ins named there and in ROADMAP); issue #386: the naquadah fuel rods
    (section 13, technology Naquadah Fuel Rods), the isotopes, the LFTR fuels, Hastelloy-N and the Reactor Fuel
    Processing Plant (section 14, technology Liquid Fluoride Thorium Reactor), the LFTR, the Reactor Processing Unit I,
    the Cold Trap I and the Sparge Tower (section 15; the LFTR's power comes from scripts/fork-power.lua) and the LFTR
    loop (section 16); issue #406: the Nuclear Salt Processing Plant (section 17); issue #355: the Precise Assembler and the HiCs (section 18), the quantum anomaly and chromatic glass (section 19), the plasma forge's residue and Dimensionally Shifted Superfluid with the oganessons (section 20); issue #406: the Cold Trap II and RPU II with Pikyonium 64B (section 21); issue #356: the Mehen Belt's draconium (section 22), the depleted thorium fuel and praseodymium (section 23), the netherite chain's materials (section 24), GT++'s Algae Farm and Industrial Dehydrator (section 25), the netherite chain to the prismatic naquadah sheet (section 26), the Naquadah Fuel Refinery with MK III and MK IV (section 27), MK V and MK VI with coils T3 and T4 (section 28); issue #355 step 2: creon and mellion with fiery steel, fermium plasma and MK V's alternative (section 29); issue #355 step 4: the beamline with mu-metal, the Source Chamber, the Beam Crafter and UU matter (section 30), the Large Hadron Collider with its particles (section 31), the gravitational lens (section 32), the ZPIC with a second UMV hatch recipe (section 33); issue #627: gelid cryotheum and the mutated living solder, which replaces indalloy 140 in GTNH's places (`MUTATED_SOLDER_RECIPES`, section 46, inserted before 38 like 42-45); issue #630: GT++'s milling and flotation (section 47: IsaMill, Flotation Cell, the milled ores and froths of `FORK_MILLING.ores`, the netherrack froth's Poor Nether Waste, pine oil and xanthates, nefarious oil; technologies Milling and Flotation and Froth Processing); issue #617: GT's netherite chain from ancient debris (160's Nether Manual Mine) to the Naquarite foil, its users where the tier fits, the forming press and arc furnace fluid ports (section 48, technology Netherite); issue #634: the MV to EV superconductors, their solenoids and the Large Fluid Extractor's solenoid builds (section 49); loads after 159 and
    loop (section 16); issue #406: the Nuclear Salt Processing Plant (section 17); issue #355: the Precise Assembler and the HiCs (section 18), the quantum anomaly and chromatic glass (section 19), the plasma forge's residue and Dimensionally Shifted Superfluid with the oganessons (section 20); issue #406: the Cold Trap II and RPU II with Pikyonium 64B (section 21); issue #356: the Mehen Belt's draconium (section 22), the depleted thorium fuel and praseodymium (section 23), the netherite chain's materials (section 24), GT++'s Algae Farm and Industrial Dehydrator (section 25), the netherite chain to the prismatic naquadah sheet (section 26), the Naquadah Fuel Refinery with MK III and MK IV (section 27), MK V and MK VI with coils T3 and T4 (section 28); issue #355 step 2: creon and mellion with fiery steel, fermium plasma and MK V's alternative (section 29); issue #355 step 4: the beamline with mu-metal, the Source Chamber, the Beam Crafter and UU matter (section 30), the Large Hadron Collider with its particles (section 31), the gravitational lens (section 32), the ZPIC with a second UMV hatch recipe (section 33); issue #627: gelid cryotheum and the mutated living solder, which replaces indalloy 140 in GTNH's places (`MUTATED_SOLDER_RECIPES`, section 46, inserted before 38 like 42-45); issue #630: GT++'s milling and flotation (section 47: IsaMill, Flotation Cell, the milled ores and froths of `FORK_MILLING.ores`, the netherrack froth's Poor Nether Waste, pine oil and xanthates, nefarious oil; technologies Milling and Flotation and Froth Processing); issue #617: GT's netherite chain from ancient debris (160's Nether Manual Mine) to the Naquarite foil, its users where the tier fits, the forming press and arc furnace fluid ports (section 48, technology Netherite); issue #623: the Dyson Swarm (section 50: modules, casings, the ground unit; its power and hourly loss in scripts/fork-power.lua, mod data `dyson`); loads after 159 and
    loop (section 16); issue #406: the Nuclear Salt Processing Plant (section 17); issue #355: the Precise Assembler and the HiCs (section 18), the quantum anomaly and chromatic glass (section 19), the plasma forge's residue and Dimensionally Shifted Superfluid with the oganessons (section 20); issue #406: the Cold Trap II and RPU II with Pikyonium 64B (section 21); issue #356: the Mehen Belt's draconium (section 22), the depleted thorium fuel and praseodymium (section 23), the netherite chain's materials (section 24), GT++'s Algae Farm and Industrial Dehydrator (section 25), the netherite chain to the prismatic naquadah sheet (section 26), the Naquadah Fuel Refinery with MK III and MK IV (section 27), MK V and MK VI with coils T3 and T4 (section 28); issue #355 step 2: creon and mellion with fiery steel, fermium plasma and MK V's alternative (section 29); issue #355 step 4: the beamline with mu-metal, the Source Chamber, the Beam Crafter and UU matter (section 30), the Large Hadron Collider with its particles (section 31), the gravitational lens (section 32), the ZPIC with a second UMV hatch recipe (section 33); issue #627: gelid cryotheum and the mutated living solder, which replaces indalloy 140 in GTNH's places (`MUTATED_SOLDER_RECIPES`, section 46, inserted before 38 like 42-45); issue #630: GT++'s milling and flotation (section 47: IsaMill, Flotation Cell, the milled ores and froths of `FORK_MILLING.ores`, the netherrack froth's Poor Nether Waste, pine oil and xanthates, nefarious oil; technologies Milling and Flotation and Froth Processing); issue #617: GT's netherite chain from ancient debris (160's Nether Manual Mine) to the Naquarite foil, its users where the tier fits, the forming press and arc furnace fluid ports (section 48, technology Netherite); issue #628: GTNH's wetware, bio and optical boards (section 51: the chemical reactor routes, the PCB Factory at T1); issue #629: GT++'s cinobite A243 and octiron for the fusion reactor Mk-IV's coil, casing and controller (section 52; arcanite and titansteel with thaumium for Thaumcraft's crystal powders); issue #629 part 2: GT's attuned tengam (from Seth's raw tengam) for the UEV-UMV motors and voltage coils and proto-halkonite steel for the UIV motor, field generator and the space elevator's Mk-IV motor (section 53); issue #631 part 1: gtnhlanth's iodine (seaweed from the greenhouse, the Everglades' lautarite and perroudite) and GT's hafnium iodide route (section 54); issue #631 part 2: gtnhlanth's samarium ore concentrate chain (section 55); issue #631 part 3: gtnhlanth's rare earth ion extraction with 14 nano resins (section 56; the Deep-Dark-only ores' chains unlock in 161); issue #632: bromine, radium and curium (section 57); issue #633: kubatech's HTGR with its TRISO fuels and promethium (section 58); issue #712: NewHorizonsCoreMod's circuit boards from the coated to the multilayered printed board (section 58: GTNH's recipes and fluid twins, the gold foil with the good board at MV); issue #690: GT's insulation pulps, the PVC pulp from its sheets, the piles of PVC and PDMS pulp with the packager's split (section 59, before 38; 158's routes take GT's cable map); loads after 159 and
    before 161)
  - 161 dimension unlocks (issue #287: the unlock rules of 160, `ore_dimension` moves or gates the ore chains of the
    dimensions' ores, the ender air with Radon, black plutonium with the Void Miner II, the bornite chain with
    Reach Ross128 (issue #293); issue #563: the same in both ore modes, the chains of the map veins' ores come from 155's
    `vein_techs` and 166's classic recipes follow them; loads after 159 and before 156)
  - 165 ore veins (plan #494: GTNH's veins as mixed ore patches on the map, the Nether, Twilight Forest and End as
    surfaces; issue #496: `FORK_ORE_MIXES`, GT's 122 ore mixes from `prototypes/data/ore-mixes.lua`, which
    `tools/gen_ore_mixes.py` writes from GT5-Unofficial's `OreMixes.java` (do not edit it), the T0 dimensions that are
    Gregtorio's surfaces (`FORK_ORE_MIX_SURFACES`, the surface property gt-dimension); devcheck fails for an ore of a vein
    on a surface without a raw ore and its chain unless the material, the vein (`mix:<name>`) or the dimension
    (`dimension:<DimNames>`) is in the allow-list `FORK_ORE_MIX_SKIPPED`, or the material in `FORK_ORE_MIX_NO_CHAIN`
    (GT processes it another way: oil sands), each with its reason; issue #497: the map veins of Nauvis by noise autoplace
    as #495's spike decided (named noise expressions `gt_*`: a grid of cells `gt_cell_size`, `voronoi_cell_id` per cell
    and per tile, GT's nine layers as bands, `gt_vein_key` = 8 x vein id + layer, one resource `gt-ore-<material>` per ore,
    category `gt-ore`, whose probability sums its keys, so a tile holds one ore at most; each planet sets `gt_vein_id` to
    its own `gt-vein-id-<DimNames>` through `property_expression_names`; `FORK_ORE_VEINS.planets` lists the planets with
    veins; the autoplace control `gt-ore-veins` (issue #529: the grid: frequency the cell size, size the share of cells
    with a vein, richness every vein's ore; plus one control `gt-vein-<mix name>` per placed vein on the planets that place
    it, named in `[autoplace-control-names]` with the primary ore's icon, ordered by surface and GT's weight: frequency x
    its weight in the pick `gt_vein_pick_<DimNames>` (off = weight 0, the other veins fill its cells), size magnifies it
    (`gt_vein_scale`; the cells keep room for the planet's largest, `gt-size-max-<DimNames>`), richness its ore; a start
    vein ignores frequency, one that is off leaves its cell to the pick; old saves get the controls from
    `migrations/2026-10-23-issue-529-vein-controls.lua`, an old grid size moves onto every vein; devcheck's names check
    covers autoplace controls); the start veins in the four cells around the origin; mod data
    `fork-ore-veins` for the chart tags of `scripts/fork-ore-veins.lua` and devcheck's map vein test; issue #508:
    `data-final-fixes.lua` deletes every resource autoplace control no planet and no prototype uses, and its preset
    entries, so the map generator lists only what makes ore; issue #500: the Lua migration
    `migrations/2026-10-22-issue-500-map-veins.lua` (a Lua migration runs once per save also when the version stays, as
    in the maintainer's linked clone) calls `scripts/fork-ore-veins.lua`'s remote `migrate`: the planet's map settings,
    `regenerate_entity` of the generated chunks (issue #534: of every generated chunk without a vein ore, once per load,
    `storage.fork_ore_veins.ores_tick`; `migrations/2026-10-23-issue-534-vein-ores.lua`; issue #540: a map made with Space
    Age kept every planet's controls on Nauvis, so the surface keeps only its planet's controls, autoplace settings and
    expression names (and the presets' and climate sliders' names), `storage.fork_ore_veins.foreign` notes a surface that had
    others, and the remote `clean_chunks` of `migrations/2026-10-23-issue-540-foreign-map-gen.lua` deletes its chunks
    without a building of a player's force or a placed tile and removes Space Age's trees, plants, rocks, cliffs and
    decoratives from the kept ones, their tiles stay; devcheck's DEVCHECK-MIGRATE-MAPGEN), the dimension mines on hidden (Overworld) vein recipes replaced by their
    drill, the charted veins tagged, names of missing noise expressions dropped from the map settings (each one is a
    warning whenever `calculate_tile_properties` compiles the noise program; the tags read each cell once,
    `storage.fork_ore_veins.cells`); issue #501: the Nether is a surface: the surface property `gt-dimension` (1
    Overworld, 2 Nether, 3 Twilight Forest, 4 End), the hidden planet `gt-nether` (Vulcanus' terrain without its
    resources: volcanic rock for netherrack, lava lakes, no water; issue #529 deletes Vulcanus in data-final-fixes.lua
    and keeps the controls its terrain reads, hidden), its 11 veins; 163's `FORK_ORE_VEINS.planets` and
    `.techs` (planet -> its reach technology) also hide the vein recipes of the Nether's ores; devcheck counts a resource
    that only a reached planet places (checkmod `P` rows) as obtainable with that technology only (pseudo recipes
    `planet-mining:<resource>`), so #252's tree rule sees the Nether; issue #502: the Twilight Forest, the hidden planet
    `gt-twilight` (Nauvis' terrain as a dense forest, no biters, no vanilla resources), its 15 veins; 163's
    `FORK_ORE_VEINS.dropped` (the Thaumcraft veins) keeps their ores out of the hide rule; #252's tree rule takes no
    alternative that needs a missing ore whose nearest producer is `planet-mining` (issue #517: no alternative that needs
    any item the recipe misses); issue #503: The End, the hidden planet
    `gt-end` (own tiles `gt-end-stone` and `gt-end-void`, a copy of out-of-map, placed by `gt_end_land`: the main island
    and the outer islands; its `gt_vein_id` is cut by `gt_end_land`), its 7 veins; issue #505: the vein recipes of Nauvis,
    the Nether and the Twilight Forest are deleted, old saves map them onto 163's placeholders `removed-vein-<planet>-<kind>`
    (JSON) that `scripts/fork-ore-veins.lua` turns into drills or clears (issue #563: that JSON migration is gone, the
    engine applied it in classic mode too; the script decides by the ore mode); issue #563: in classic mode the planets
    get no vein resources, controls or `gt_*` expressions (the prototypes stay for saves that switch), the mod data
    `fork-ore-veins` names the `mode`, and `FORK_ORE_VEINS.placed` (each placed vein once, with its surfaces),
    `FORK_ORE_VEINS.ore_of` and `FORK_ORE_VEINS.fill` are 166's input; issue #574: every vein control's description
    (generated: its ores with icons and layers, GT's weight, density and size, its share of the cells per surface;
    `[fork-vein]` locale keys), in map-vein mode a raw ore's "Found in" line, the planet icons of gt-nether, gt-twilight and
    gt-end (`tools/gen_icons.py --drawn`); `FORK_ORE_VEINS.table` is devcheck's section VEINTABLE, `check --vein-table`
    writes the vein table of `docs/ORE-VEINS.md` and `check` fails when it differs; the names check fails for a vein control
    without its description; `docs/ORE-VEINS.md`; loads after 161)
  - 166 classic veins (issue #563, the maintainer's addendum of 2026-10-24: the vein recipes of the classic ore mode,
    generated from 165's placed veins, never copied from git: one Manual Mine recipe `mining-<GT's mix name in kebab
    case>-vein` per vein with 163's twins, 64 ores per operation shared out by the expected ore tiles of GT's layers as 165
    places the vein, 8 or 24 manual labor; a name that is a recipe already keeps that recipe (CopperTin); the stone
    pickaxe's `mining-iron-vein-with-stone-pickaxe` with Craft Stone Tools; 0.5.5's seven other names (`LEGACY`) as hidden
    recipes for old saves (mod data `fork-electric-mine`: `classic`, `legacy`); the prototypes exist in both modes and are
    hidden in map-vein mode (`FORK_CLASSIC_VEINS.hidden`, which 199's auto-unlock skips); in classic mode a vein of the
    Overworld comes with every first technology that unlocks a recipe taking one of its raw ores (no start recipe; a
    technology without the iron pickaxe gives way to the pickaxe's), one of the other surfaces with their reach
    technology, the twins with the first plant's and the LV Miner's technology unless every vein technology is later, then
    163's `unlock_dimension_mines()`; devcheck fails for a placed vein of `FORK_ORE_MIXES` without its recipe and twins or
    with other ores (section CLASSICVEINS); `docs/ORE-VEINS.md`; loads after 165)
  - 167 tips (issue #625: the Tips and tricks category `gregtorio`, a title tip and one tip per tier from steam to MAX
    with the tier's goals after GTNH's quest lines, unlocked by the technology of the tier's science pack; the texts in
    `locale/en/fork.cfg` link the technologies with rich text tags; `FORK_TIPS.describe_machines()` in data-final-fixes gives
    every tiered machine `<tier>-<kind>` the description of its kind (locale [fork-machine]) unless it has its own
    `entity-description`; devcheck fails for a shown machine without a description (`MACHINE_TYPES`); loads after 166)
  - 156 circuit icons (issue #164: the circuit variant recipes up to UV keep the shared tier item and show GT's texture
    of their GTNH item as recipe icon; devcheck fails for a tier circuit recipe without its own icon; issue #450: the ULV
    tier item `ulv-circuit`, which the vacuum tube and NAND chip recipes give and every former user of the two takes, and
    the nanoprocessor in the HV circuit assembler with its parts at HV)
  - 157 recycling (issue #190: GTNH's material recycling into dusts, ingots and melts for the items of crafting table
    recipes and the hulls, recipes `recycling-<machine>-<item>` in `FORK_RECYCLING.recipes`, unlocked late by
    `FORK_RECYCLING.unlock()` in data-final-fixes.lua because that file replaces and disables vanilla technologies;
    devcheck checks the recipe shape and the blacklist; issue #670: every material block (`block-of-<material>` or
    `<material>-block` whose recipe takes 9 of one item; melt from its solidifier recipe, mass and voltage from
    `gt-parts-data.lua`) gets GT's recycling with 9 units and ProcessingBlock.java's recipes, `cut-<block>` (cutting
    machine -> 9 plates, water, below IV; GT++ without fluid) and `hammer-<block>` (forge hammer -> 9 gems), the latter
    two in `FORK_RECYCLING.blocks`, which 199's auto-unlock ignores; devcheck fails for a reachable material block that no
    recipe takes unless it is in the allow-list `FORK_BLOCKS_DEAD_END` with its reason (section `BLOCKDEADOK`); issue #686:
    GT's recycling of every material part (macerator, arc furnace, fluid extractor, alloy smelter with the mold, furnace)
    from `prototypes/data/gtnh-recycling.lua`, which `devcheck.py check --gtnh-recycling` writes from the dump of
    `tools/gtnh_dump/` through `tools/gtnh_map.py` (`recycling_imports`: GT's numbers in Gregtorio's units, a part that its
    machine takes already left out); `check` fails when the table is out of date)
  - 168 GTNH numbers (issue #689: GT New Horizons' tier, time, item amounts and chances for every recipe that has a GT
    recipe with the same items and fluids in and out, from `prototypes/data/gtnh-numbers.lua`, which `devcheck.py check
    --gtnh-numbers` writes from the dump of `tools/gtnh_dump/` through `tools/gtnh_map.py` (`numbers`; run it after a new
    dump, a new recipe or a changed one, `check` says when the table is out of date); a tier only downward (a higher one
    needs a later machine and moves the unlock, #724), not the blast furnace's tier (its coil heat, #620), no fluid
    amounts and no item amounts of a recipe whose fluids differ (#671), not the crafting table (GT's tools merge recipes,
    #688), not 157's recycling (GT's formulas on Gregtorio's recipes, #190), not the fusion reactor (#32), no time of a
    hand recipe; devcheck fails for a matched recipe whose numbers in that scope differ from GT's unless it is in the
    allow-list `FORK_GTNH_NUMBERS_KEPT` with its reason (section `GTNHKEPT`), and for one a later file changes again;
    loads after 157 and before 150)
  - 150 molds (mold slot instead of mold ingredient; issue #316: the laser engravers' lens slot the same way, every
    `<material>-lens` item a module of the category `lens`; must load after every file that creates machines)
  - 190 manual-labor burner usage (fist icon in the fuel slot)
  - 191 burner fire (issue #137: the fire animations of the stone and iron furnace and the small coal boiler, drawn only
    while they work; `tools/gen_fire_sprites.py`)
  - 196 subgroups (the Fluids tab: every Gregtorio fluid gets a row of the item group `fluids` by its explicit table or
    a name pattern; a new fluid goes into one, the fallback row `gregtorio-fluids-unsorted` is a devcheck warning; issue
    #119: Gregtorio icons for molten iron, molten copper and steam, the twelve unused vanilla fluids hidden
    (`FORK_FLUIDS_HIDDEN`); a fluid that keeps another mod's icon on purpose goes into `FORK_FLUID_ICONS_KEPT`, devcheck
    warns otherwise; issue #315: the tier rows of the production tab in tier order, each tier's multiblocks after its
    machines, and a machine recipe in the tier row of its product; loads after every file that creates fluids)
  - 197 fluid steps (issue #117: every fluid amount of a recipe that is not a multiple of the engine's step 2^-24 is set
    on the grid, takes up, gives up and nine steps more, so n melted ingots cover every cast they are worth; loads after
    every file that makes or changes a recipe; devcheck fails for an amount off the grid)
  - 198 crafting menu (shows machine recipes, which upstream `create_recipe` hides; a recipe that must stay hidden goes
    into its allow-list `FORK_CRAFTING_MENU_HIDDEN`, devcheck fails otherwise; startup setting in `settings.lua`)
  - 199 finalize
  - 200 material parts (issues #118 and #145: the item group "Material parts", one row per form, the materials inside a
    row by the tier of the technology that unlocks their ingot (its highest science pack), else of any part; items only,
    the recipes keep their machine rows; devcheck warns for a material with no tier; loads after 199 so the final
    unlocks count).
  The phase plan is in `docs/ROADMAP.md`. Runtime fork code lives in `scripts/` and is required from `control.lua`
  (`fork-molds.lua`, `fork-victory.lua`, `fork-power.lua`, `fork-space-elevator.lua` (#302), `fork-electric-mine.lua` (#342: a Miner or Ore Drilling Plant that replaces a mine
  keeps its vein, from 163's mod data `fork-electric-mine`; event driven, `storage.fork_electric_mine`), `fork-portals.lua` (#501: the Nether Portal sends whoever steps onto it to the Nether and back at 1:8, makes the Nether's surface at the first use and the exit portal; #502: the Twilight Portal the same at 1:1 to the Twilight Forest, whose daytime it freezes at dusk; #503: the End Portal to The End's main island (exit portal at the origin) and back to the portal one came through (`storage.fork_portals.came_from`), night frozen; `on_player_changed_position`, remote `fork-portals.travel`, `storage.fork_portals`), `fork-ender.lua` (#504: Ender Chests (linked-container, link_id = the three-colour code) and Ender Tanks (levelled per force and code every 20 ticks) share their contents across surfaces; the code panel is a relative GUI beside the window; `storage.fork_ender`, remote `fork-ender`), `fork-ore-veins.lua` (#497: a chart tag with the vein's name when the chunk of a map vein's centre is charted, `storage.fork_ore_veins`, event driven), `fork-steam-boilers.lua` (#446: the solar boilers of 101 stop at night; every 120 ticks, `storage.fork_solar_boilers`), `fork-ore-furnaces.lua` (#560: the remote `migrate` that rebuilds the ore machines of old saves as furnaces; no events, no state), and `fork-me-handover.lua`: the one-time hand-over of the ME
  state of saves from before issue #83 to me-network through the remote interface `gregtorio-me-handover`, which
  me-network calls in its `on_init`; keep its table list and fingerprint function equal to me-network's
  `scripts/fork-me-handover.lua`). Everything else of the ME network (runtime, graphics, locale, its tests,
  `docs/AE2.md`, `docs/ME-REWORK.md`) is in the me-network repository; an ME change goes there, Gregtorio only changes
  the compat file when a recipe or a tier changes. Tick intervals in use: `on_nth_tick` 5 (molds), 12 (#499: the Ore Drilling Plants' Drilling Fluid, `fork-ore-drills.lua`, `storage.fork_ore_drills`), 24 (solar boilers), 20 (#504: the Ender Tanks); issue #642: the molds, the plants and the solar boilers are checked in shares through `scripts/fork-batch.lua` (each entity once per 30, 60 and 120 ticks, a cursor beside its table in storage), so a megabase pays about the same every few ticks instead of one spike per period (3000 mold machines: 11 ms spikes -> 4 ms, 15 % more script time on average); a new periodic check over many entities does the same, and reads mod data once (its `data` builds the table on every read); `on_tick`
  (fork-power: turbine energy every tick, fuel check, output hatches and the supercapacitor loss every 10th tick);
  registrations for the same interval (or a second `on_tick`) overwrite each other, so a new periodic task picks a free
  interval. The scripts keep their state lazy (`storage.fork_molds`, `storage.fork_power`).
- `data-final-fixes.lua` disables vanilla techs (`disable_tech`: hidden, no effects); issue #640: a vanilla technology
  behind a disabled one is disabled too (`FORK-UNRESEARCHABLE` in the log), so no technology stands in the tree that can
  never be researched. The main menu simulations that call
  `research_all_technologies()` get the bonuses of those techs from `prototypes/fork-menu-simulations.lua` (PR #65: the
  laser defense simulation's character died without them and its script stopped the menu); after changing the disabled
  techs or the character, run `python tools/devcheck/devcheck.py menusim --sim all --compare`. Issue #588: Gregtorio's
  own main menu scenes are the first section of that file (`gregtorio_steam_age`, save `menu-simulations/gregtech-steam-age.zip`,
  built by achilles155; issue #595, the maintainer's decision: the menu shows only
  Gregtorio's own scenes, every other one is removed once one of Gregtorio's is in the list, and `menusim` fails when
  another is left; it replaced #591's five copies per scene next to Factorio's). A scene's save is changed
  only by `devcheck.py menusim --sim <name> --rebuild` (the headless game with today's mods runs `tools/menusim/resave.lua`:
  chunks cut to the factory plus `--margin` chunks (issue #599: 1, a large screen sees past the factory), the builder's
  blueprint library (the largest part of a map made in the editor), its player (the menu draws a player's GUI over the
  scene) and the replay removed; `--save-from <ref> --made-with <gregtorio ref>:<me-network ref>` starts from the builder's save and compares
  the entity counts with its own versions), never by hand; it writes `tools/menusim/<name>.json`, whose entity counts
  `menusim` (`--sim own` is part of `all`) checks after every load, with the machines in the camera's view. When a
  change of the game makes the load of a scene lose entities or its machines stop, fix the scene's `init`/`update` or
  rebuild its save. The section "VANILLA ITEM
  REMOVAL" deletes vanilla prototypes for good; issue #317's `VANILLA_RECIPES_REMOVED` there holds the vanilla and Space
  Age recipes that no technology unlocks, of items Gregtorio makes its own way. They are deleted with the technology effects
  and tips-and-tricks triggers that name them (a tip's trigger naming a missing recipe fails the load), and logged as `FORK-REMOVED`;
  issue #318 added the vanilla oil recipes. devcheck fails for a new recipe of that class that is neither there nor in the
  allow-list `FORK_VANILLA_RECIPES_KEPT` with its reason. Issue #323 added every other vanilla recipe without a
  technology (`VANILLA_RECIPES_UNUSED`, by group); the nested tips-and-tricks triggers lose the branches that need a
  deleted recipe (`FORK-TIP` in the log), and machines lose a deleted fixed recipe (captive biter spawner, rocket silo).
  Issue #529 (its section "SPACE AGE PLANETS AND SPACE PLATFORMS" after #323's):
  the Space Age planets and space locations (`REMOVED_LOCATIONS`), their space connections, the planet discovery and space
  platform technologies (`REMOVED_TECHS`, the maintainer's decision: Gregtorio has no space platforms) and the platform
  starter pack are deleted with every reference a load fails on (achievements, ambient sounds, tips and the tips that
  depend on them, main menu simulations on a deleted planet, Factoriopedia simulations, import locations, prerequisites);
  165 copies Vulcanus' terrain for the Nether before. #508's control rule (after the map presets) deletes every autoplace
  control no planet lists, unless a noise expression or an autoplace reads its sliders (`control:<name>:size`): such a
  control stays with `hidden = true`, because a surface keeps its map generation in the save and the load compiles its
  noise (the Nether's copy of Vulcanus' lava reads the coal, tungsten and geyser controls; without them the load fails
  with "Unknown variable"; a noise expression cannot stand in, prototype names take no colon). The engine deletes a
  surface of a deleted planet when an old save loads (`devcheck.py migrate`: DEVCHECK-MIGRATE-PLANETS).
- Factorio 2.1 (issue #535): the mod is for 2.1 (`factorio_version`, devcheck's `FACTORIO_VERSION`). `prototypes/fork-factorio-21.lua`
  (required at the top of `data.lua`) has the helpers of what changed: a recipe has `categories` (a list) instead of
  `category`, read and set with `fork_category(r)`, `fork_set_category(r, c)`, `fork_has_category(r, c)` and
  `fork_category_in(r, set)` (never `r.category`: vanilla recipes have several categories since 2.1); a product has
  `independent_probability` instead of `probability`, an item `fuel_categories` instead of `fuel_category` (`create_item`
  still takes `fuel_category` and `category` as its arguments), a generator `pictures` (`fork_generator_pictures`), a pipe
  connection `hide_connection_info`; `assembler2pipepictures()` and `assembler3pipepictures()` are kept as functions over
  the base mod's module. Factorio refuses some removed keys and ignores the others, so `devcheck.py check` fails for every
  removed key a prototype still has (`checkmod/removed-keys.lua`, `tools/devcheck/removed_keys.py`; other mods' leftovers
  in `REMOVED_KEYS_OTHER_MODS`). A 2.0 version (up to 0.5.6) makes its `migrate` save in an unpacked Factorio 2.0:
  `migrate --from-ref v0.5.6 --old-me-network v0.5.5 --old-factorio DIR --old-mods DIR` (its dependency zips).
- Names (issue #230): the engine names a recipe after its product only when the recipe has the product's name; every
  other recipe shows `recipe-name.<recipe>`, a main product does not change that. `prototypes/fork-locale.lua` (required
  first from `data.lua`, `FORK_LOCALE.name_recipes()` at the end of `data-final-fixes.lua`) gives every Gregtorio recipe
  without a name of its own its product's name as the fallback; a recipe with several results and no main product needs a
  `main_product` or a `[recipe-name]` entry, a new subgroup an `[item-subgroup-name]` entry. `devcheck.py check` fails for
  every shown prototype of this mod without a name (runtime names of `checkmod/control.lua`, keys of every loaded
  `locale/en`), except the allow-list `FORK_LOCALE_MISSING`; `--locale-out` writes the missing keys for `tools/gen_locale.py`.
- Spoiling (issue #602): GT New Horizons has no spoiling; `data-final-fixes.lua` takes Space Age's spoiling off the Space
  Age items Gregtorio makes (the UV science pack is the agricultural science pack), and `devcheck.py check` fails for an
  item that spoils and that a reachable recipe makes, unless it is in the allow-list `FORK_SPOILING_KEPT` with its reason.
- Space Age's recycling (issue #670): Factorio 2.1's built-in mod `recycler` generates a hidden recycling recipe of every
  recipe and item (data-updates) for its Recycler, which Gregtorio cannot build; `data-final-fixes.lua` adds every recipe
  of a category only the recycler runs to `VANILLA_RECIPES_REMOVED` (`FORK-REMOVED`, technology effects and tips with
  them) and deletes the recycler's item and entity (`FORK-RECYCLER` in the log). Nothing else in 2.1 reads those
  recipes (the item tooltips and Factoriopedia show them through `factoriopedia_recycling_recipe_categories`).
  `devcheck.py check` fails for a recipe of the recycler's categories that is left.
- Cheap research: the startup setting `gregtorio-continued-one-pack-research` (default off) makes every technology with
  science packs cost one research unit with one pack of each kind (`prototypes/fork-one-pack-research.lua`, required last
  in `data-final-fixes.lua`, after everything that sets unit counts). `devcheck.py all` loads the mod a second time with
  it on; `devcheck.py check --set <setting>=true|false` forces any bool startup setting for a run (issue #563: any other
  value a string setting's, also for `runtime` and for `migrate`'s load of the working copy).
- Ore mode (issue #563): the startup setting `gregtorio-continued-ore-mode` (default `map-veins`; `vein-recipes` is the
  classic ore system of 0.5.5, `FORK_CLASSIC_ORES` in the data stage, defined at the top of `data.lua`) is chosen per
  game. `devcheck.py all` loads the mod a second time in classic mode (`check` and `runtime` with
  `--set gregtorio-continued-ore-mode=vein-recipes`) and then runs `switch`, a map made in one mode and loaded in the
  other, both ways (`tools/devcheck/switchmod`); every check passes in both modes, the map vein test of `runtime` checks
  in classic mode that no planet has vein ore. `scripts/fork-ore-veins.lua` notes a save's mode in
  `storage.fork_ore_veins.mode` (`on_init`, its remote `migrate`, `migrations/2026-10-24-issue-563-ore-mode.lua`) and
  migrates it in `on_configuration_changed` when the setting changed; a save of 0.5.6 or later has had its mines turned
  into drills, which classic mode keeps (`docs/ORE-VEINS.md`, "Old saves and switching"); issue #569: a save that
  researched a technology before its reach technology became its prerequisite gets the reach technology researched
  (`migrations/2026-10-24-issue-569-reach-techs.lua`; `migrate` checks it, `TT_REACH` of `migratemod/`). The last release with the
  classic system is v0.5.5 (Factorio 2.0): `migrate --from-ref v0.5.5 --old-me-network v0.5.4 --old-factorio DIR
  --old-mods DIR` with and without `--set gregtorio-continued-ore-mode=vein-recipes`.
- Steam per second (issue #564): `prototypes/fork-steam-rates.lua` (required from `data-final-fixes.lua` after everything
  that makes or changes the machines) computes, from the prototypes, the steam per second of every boiler (also the
  fixed-recipe lava and solar boilers of 101) and of every machine whose fluid energy source burns steam, and appends it
  to the description of the entity and of its items (not for a `boiler`: the game shows its output itself) (`[fork-steam]` locale keys; a steam age machine also names its Small Coal Boilers);
  `FORK_STEAM_RATES` is devcheck's section STEAMRATES, which checks the Small Coal Boiler (1.2), the Large Bronze Boiler
  (160) and the Steam Alloy Smelter (3.2).
- Boiler output (issue #593): the startup setting `gregtorio-continued-boiler-output` (a double from the list 1, 1.5, 2,
  3, 4, 6, 8, 16; default 1, GTNH) makes every steam boiler bigger, not more efficient: `prototypes/fork-boiler-output.lua`
  (required from `data-final-fixes.lua` before `fork-steam-rates.lua`) multiplies a burner or fluid `boiler`'s
  `energy_consumption` and the fixed recipes of the lava and solar boilers (steam and fluid ingredients, on 197's grid
  with `FORK_FLUID_STEPS.round_up`); heat exchangers stay (section BOILEROUTPUT). devcheck's expected boiler rates and
  watts follow the setting; `devcheck.py all` loads `check` and `runtime` once more with `--set
  gregtorio-continued-boiler-output=4` (`--set` takes numbers for double and int settings); the runtime's coal boiler and
  solar boiler tests measure steam per second against the setting. At 16 every fluid box carries the flow (probed).
- GT overclocking (issue #616): the startup setting `gregtorio-continued-gt-overclocking` (default off) makes every
  electric assembling machine and furnace with a crafting speed of 2 or more draw its power times 2^floor(log2(speed)),
  so the power quadruples per tier (GT's overclock: a recipe costs twice its energy per tier above its own) instead of
  doubling (`prototypes/fork-gt-overclocking.lua`, required from `data-final-fixes.lua` after the machines; section
  OVERCLOCK). `devcheck.py all` loads `check` and `runtime` once more with it on.
- Generators (`generator` prototypes that burn fluids by fuel value, 136) are demand driven; an
  input-output fluid box keeps part of its fluid in the pipeline segment (`get_fluid_count` reports
  only the entity's part; since Factorio 2.1 `get_fluid_segment_fluid` is the whole segment with that part, where 2.0's
  `fluidbox.get_fluid_segment_contents` was the rest), so tests count the segment (`fluid_total` of the runtime tests).
- `199-fork-finalize.lua` hides draft recipes with missing parts (`FORK-DRAFT` in the log) and
  auto-unlocks intermediates (`FORK-AUTOUNLOCK`). Check the log after changes.
- New machines one tier up: `fork_make_tier_machine(base, from_tier, to_tier, frames, tech)`.
  Their sprites/icons come from `tools/gen_sprites.py --gt <GT5-Unofficial checkout>`;
  missing item icons from `tools/gen_icons.py` (a placeholder; the real icon from GT textures with
  `tools/gen_gt_icons.py` after adding the item to `tools/gt-icon-items.txt`; `tools/gen_icons.py --drawn` writes the graphics
  drawn as code where GT has no texture, issue #431: the cauldron), technology icons from
  `tools/gen_tech_icons.py` (`tools/tech-icons.tsv`; issue #639: devcheck fails for a shown prototype with the NYI
  placeholder icon unless it is in `FORK_NYI_ICONS` of 199), missing names from `tools/gen_locale.py`.
  Check graphics changes with the contact sheets of `tools/gen_review_sheet.py`.
- **Machine names are GTNH's** (issue #156): a new machine, multiblock or controller takes the name GT New Horizons
  gives it, from the `en_US.lang` files of GT5-Unofficial (`src/main/resources/assets/*/lang/en_US.lang`, or the name
  in `gregtech/loaders/preload/LoaderMetaTileEntities.java`), not GregTech CEu's and not the one `tools/gen_locale.py`
  derives from the ID: overwrite the generated entry. Gregtorio's tier prefix stays ("LV Ore Washing Plant",
  "Industrial Mixing Machine (IV)"); GTNH's "Basic / Advanced / Elite" prefixes are not used. Prototype names keep
  the old IDs (`<tier>-ore-washer`, `godforge`): saves find them by name, so a rename changes the locale only.
- **Test every change** with the headless harness: `python tools/devcheck/devcheck.py setup` once
  (needs network access to factorio.com and FACTORIO_USERNAME/FACTORIO_TOKEN for the dependency
  mods; me-network is taken from a checkout next to this one, `../me-network`, or `ME_NETWORK_DIR`, else its portal zip;
  its texture mod is an empty stand-in that devcheck makes, never the graphics, issue #231),
  then `python tools/devcheck/devcheck.py all`. It must end with `RESULT: OK`. For changes
  that could affect existing saves also run `migrate --from-ref 0e935ba` (upstream 0.1.9) or `--from-ref <previous release tag>`
  (`--from-ref v0.5.0` needs `--old-me-network v0.1.0`: the old save is made with the me-network of its time, with a later
  one the helper mod's `on_init` fails and devcheck stops with `the map was not saved`; a save from before me-network 0.5.0
  is first loaded once with Gregtorio v0.5.2 and me-network v0.5.0, because me-network 0.5.1 refuses it, issue #209). See
  `tools/devcheck/README.md`. Runtime maps use a fixed seed and a cleared test area, so a red run is
  reproducible (`--seed <printed seed>`) and never bad luck; `--seed random` checks other terrain.
- Every referenced `__gregtorio-continued__/...` file must exist (headless Factorio does not check
  graphics, the real game crashes on missing files).
- The mod is `gregtorio-continued` (Gregtorio Continued) since 0.3.0, in the repo and on the mod
  portal; paths are `__gregtorio-continued__/...`. Do not rename it again (script state is kept per
  mod name). Portal zip: `tools/build.py --portal`.
- **Changelog:** every change to the game adds its player-facing lines to the topmost section of
  `changelog.txt` (the next version, no `Date:` line yet). Do not change `version` in `info.json`
  and do not add a `Date:`; that is the release pull request into `upstream/release`.
- The maintainer's local clone is linked into the Factorio mods folder (`tools/dev_link.py`),
  so pulling into it makes changes live after a Factorio restart. me-network must be in the mods folder too (its own
  `tools/dev_link.py`); Gregtorio does not load without it.
- ME tests: me-network's `tools/devcheck/devcheck.py all --with-gregtorio <this checkout>` runs the ME runtime tests on
  Gregtorio's recipes and machines; run it when the compat file changes. `devcheck.py migrate` here checks the
  hand-over of old saves (fingerprints, totals and settings of an ME network of the old save).
- **Issues and the board:** every open issue of this repository and of its sister repository is on the project board
  "Gregtorio Continued Backlog" (https://github.com/users/Rykon00/projects/1). The board only follows the issue state: a
  closed issue moves to Done and is archived a day later; nothing else moves a card. So the pull request that finishes an
  issue has `Closes #N` in its **description** (a number in the title or "Refs" does not close it); with several pull
  requests for one issue the last one closes it and the others say `Refs #N`. Work that is left over goes into a new
  issue, named in the pull request, so the old one can close. When you start on an issue, set its status on the board to
  "In Progress" if `gh project` works for you (`gh project item-list 1 --owner Rykon00`, then `gh project item-edit`; the
  token needs the scope `project`); if it does not, say so in your report and go on. An issue the maintainer has to do or
  test in the game himself is titled `[Task-Ingame]`, not `[Task]`.
- **Close what is handled:** an issue is closed as soon as it is handled, never left for later, because an open issue
  is a card in Todo that says work is waiting. Whoever handles it closes it, with a comment that names the pull request
  or the reason:
  - work done by a pull request into `main`: `Closes #N` in its description (the rule above);
  - a **release**: the release pull request goes into `upstream/release`, where a closing keyword in the description
    closes nothing. Put `Closes #N` for the release issue into the **message of the release commit** (it reaches `main`
    through the workflow's fast-forward), and after the release check that the issue is closed; close it by hand if
    not;
  - a `[Task-Ingame]` issue: when the maintainer says he tested it (in the chat or in the issue), close it; what he
    found goes into new issues first;
  - an issue that was superseded, became pointless or turned out wrong: close it as "not planned" with the reason and
    the issue that replaces it.
  Before you report, list the open issues (`gh issue list`) and close or name every one your work touched.
- **Local sessions on the maintainer's Windows machine:** `C:\00_Repositories\Gregtorio` is linked into the Factorio mods
  folder, so never switch branches or edit files there. Work in **one** worktree next to it
  (`git worktree add ..\Gregtorio-<topic> -b <branch> origin/main`). Do not add more worktrees to compare versions: use
  `git show <ref>:<path>`, `git diff <ref>` or `devcheck.py ... --from-ref <ref>`; a second checkout that cannot be
  avoided is yours to remove as well. A `.devcheck` may hold junctions (to the Steam install's `data` folder, to the
  mod checkouts): `git worktree remove`, `rm -r` and PowerShell's `Remove-Item -Recurse` follow junctions on Windows
  and empty what they point to. So when your pull request is open, clean up in this order and say so in your report:
  remove every junction under `.devcheck` with `cmd /c rmdir <junction>`, then run `git worktree remove <path>` from
  the linked clone. The branch stays on GitHub; follow-up work makes a new worktree from it.
