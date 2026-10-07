# Gregtorio Continued

Continuation of [Gregtorio](https://mods.factorio.com/mod/Gregtorio) by **Damien Reave**, a GregTech-style total overhaul mod for Factorio 2.0. On the mod portal: [Gregtorio Continued](https://mods.factorio.com/mod/gregtorio-continued) (`gregtorio-continued`).

**Discord:** questions, help and release news in the [Gregtorio & ME Network server](https://discord.gg/bfkwAanSD8), shared with the
[ME Network](https://github.com/Rykon00/me-network) mod.

The upstream repository ([Damien-Reave/Gregtorio](https://github.com/Damien-Reave/Gregtorio)) only contains the LICENSE; the code was only published as zip files. This fork therefore starts from the unmodified **0.1.9** release from the mod portal (tag `v0.1.9-upstream`). Every change after that is a regular git commit.

## Layout

The repository root is the mod itself (`info.json`, `data.lua`, `prototypes/`, `graphics/`, `locale/`).

| Path | Contents |
|---|---|
| `prototypes/NN-*.lua` | upstream items, recipes and machines per tier (09 Steam … 31 UIV; `80-umv-age-item.lua` and `90-uxv-age-item.lua` are not loaded), `98-technology.lua` for the tech tree |
| `prototypes/100-fork-fixes.lua` | missing unlocks and recipes, chicken-and-egg fixes |
| `prototypes/101-fork-machines.lua` | tier categories, EV/IV machines and multiblocks, `fork_make_tier_machine`; the Forge Hammer (issue #170), the Arc Furnace with annealed copper (issue #171) the Forming Press with the printed circuits of the ME processors (issue #173) the Electric Furnace for the smelting recipes (issue #174) and the Sifting Machine (issue #175) LV to EV, IV to MAX through `IV_BASIC_MACHINES` |
| `prototypes/102-fork-resources.lua` | disables the vanilla resource patches (no spawning, not minable) |
| `prototypes/103-fork-qol-techs.lua` | issue #29: the vanilla quality-of-life techs (bulk/stack inserter, inserter capacity bonus, express and turbo belts, belt capacity, worker robot speed and cargo size) gated onto Gregtorio techs with Gregtorio science packs, GT recipes for the inserters and belts they unlock |
| `prototypes/110-fork-luv.lua` | LuV: materials, assembly line, LuV machines, science pack, techs |
| `docs/SPLIT.md` | issue #83: moving the ME network into its own mod `me-network` (inventory, coupling, state hand-over, release order, the checks of the split) |
| `prototypes/120-fork-me-network-compat.lua` | the ME network on Gregtorio's tiers (issue #83): the ME network (cables, controller, drives with cells, terminal, interfaces, buses, storage buses, autocrafting, fluids) is the mod [me-network](https://github.com/Rykon00/me-network), a dependency; this file gives its items the GT recipes, its nine technologies Gregtorio's prerequisites and science, and builds the molecular assembler from the HV assembler (me-network's data-stage API `ME_NETWORK`) |
| `prototypes/125-fork-luv-endgame.lua` | LuV endgame: naquadah ore line and neutron activator, bacterial vat and mutagen, circuit assembly line and crystal processors, fusion reactor Mk-I and the first plasmas |
| `prototypes/126-fork-zpm.lua` | ZPM: naquadah alloy parts, europium, ZPM components, casing and hull, ZPM science pack, ZPM energy hatch, ZPM machines and multiblock upgrades, techs |
| `prototypes/127-fork-uv.lua` | UV: naquadria, americium and neutronium (fusion), superconductors, UV circuit (crystal processor mainframe), ZPM assembly line, UV components, casing and hull, fusion reactor Mk-II and its plasmas, UV science pack, UV energy hatch, UV machines and multiblock upgrades, techs |
| `prototypes/128-fork-uhv.lua` | UHV: tritanium and the triamerotronium superconductor, the wetware line (UHV circuit), UHV components, casing and hull, fusion reactor Mk-III with advanced fusion coils, UHV science pack, UHV energy hatch, UHV machines and multiblock upgrades, techs |
| `prototypes/129-fork-water-purification.lua` | water purification plant (grades 1-8, quark creation catalyst), europium/americium doped wafers, NPIC/PPIC/QPIC/FPIC/APIC chips used by the ZPM to UXV energy and dynamo hatches and the MK2 to MK5 controllers, complex SMDs for the wetware to temporal circuit lines |
| `prototypes/131-fork-uev.lua` | UEV: cosmic neutronium, draconium and infinity (fusion), dracofinium superconductor, bio line (UEV circuit), UEV components, casing and hull, fusion reactor Mk-IV, UEV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/132-fork-uiv.lua` | UIV: transcendent metal (MK4), nether star cable, chromnorox superconductor, optical line (UIV circuit), UIV components, casing and hull, UIV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/133-fork-umv.lua` | fusion reactor Mk-V (advanced fusion coil II, casing MK4, rhugnor, flerovium, energy module), spacetime (UMV metal) and universium (UXV metal) from the Mk-V, spacetime cable, hypocosmium superconductor, exotic line (UMV circuit), UMV components, casing and hull, UMV science pack, energy hatch, machines and multiblock upgrades, techs; also the helpers shared with 134 and 135 (global table `FORK5B`) |
| `prototypes/134-fork-uxv.lua` | UXV: universium parts and cable, eternity superconductor, temporal line (UXV circuit), UXV components, casing and hull, UXV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/135-fork-endgame.lua` | endgame: the stargate and its parts from UXV parts, the MAX science pack, the tech `stargate` |
| `prototypes/136-fork-power.lua` | endgame power: fuel values of the plasmas, plasma balance (issue #32: helium-3 yield, fusion recipe times and inputs), large plasma turbines (LuV to UXV) with turbine output hatches for the cooled fluid, the naquadah fuel line (acid emulsion, emulsion, solution, light and heavy naquadah fuel, naquadah based fuel MK1 to MK3, the excited uranium and plutonium fuels), large naquadah reactors (UV to UXV), dynamo hatches LuV to UXV, techs |
| `prototypes/137-fork-endgame-materials.lua` | issues #39 and #36: the drafts removed for good (Thaumcraft, GT++ RuneScape plasmas, atomic separation catalyst and naquadah fuel cracking; deleted, `FORK-REMOVED` in the log), the circuit assembler recipe of the lapotronic energy orb cluster (tech `lapotronic-energy-orbs`), high density plutonium for the plutonium based liquid fuel; issue #36: super coolant (ledox and callisto ice from the end microminer), the space coolant cells, fluxed electrum, bedrockium and quantium with their techs, and the stand-ins they replace (hatches, UV coil, UHV/UEV/UMV components, grade 5 and 7 water, fusion MK3 controller, naquadah fuel MK2) |
| `prototypes/139-fork-endgame-multiblocks.lua` | phase 6a (issue #37): the dimensionally transcendent plasma forge (UMV; crude and resplendent catalyst, neutronium to universium with less input and reactor time than the fusion reactors) and the quantum force transformer (UMV; GT's platinum line and naquadah recipes, one recipe per main output), their parts and techs. Loads before 138, which sets the unit counts of its technologies |
| `prototypes/140-fork-godforge.lua` | phase 6b (issue #37): the Forge of the Gods (UXV, 13x13, after the stargate, MAX science): raw star matter, the plasmas of the stellar catalyst, universium, time and space fluids, magmatter; the stellar catalyst tier of the plasma forge; the infinite `godforge-upgrades` (productivity, the long-term sink after victory) |
| `prototypes/141-fork-max.lua` | phase 6b: the MAX tier: magmatter parts and cable, the Planck line (MAX circuit), MAX components, casing, hull, voltage coil, energy and dynamo hatch, the MAX science pack from MAX parts, the MAX machines (`fork_make_tier_machine`), the MAX large plasma turbine, techs. 140 and 141 load before 138, which sets their unit counts |
| `prototypes/138-fork-research-balance.lua` | issue #30: the unit counts of the technologies from UV to `victory`, scaled so each costs about as long as a ZPM technology in the reference factory of its tier (see "Balance pass: endgame" in `docs/ROADMAP.md`) |
| `prototypes/147-fork-gt-routes.lua` | issue #98: GT's routes for the leftovers of the recipe audit: the PECA board deleted, the printed board with sodium persulfate, black plutonium and cosmic neutronium through the blast furnace (every gas) and vacuum freezer, the high octane gasoline line with its cell (and a fifth fluid input of the EV and higher large chemical reactors), GT's deuterium from hydrogen, GT's PPIC wafer with molten sunnarium; exhausted water, butyraldehyde and imaginary time deleted. Loads before 142 (its `UNLOCKS_98`) and 143 |
| `prototypes/146-fork-platinum-line.lua` | issue #96: GregTech New Horizons' platinum line (bartworks) instead of upstream's GregTech CEu line: GT's sludge sources and sludge centrifuge, platinum concentrate from the ores, platinum salt and reprecipitated platinum, palladium enriched ammonia, palladium salt and reprecipitated palladium; whatever gave platinum or palladium dust gives the metallic powder (x2); the rhodium, ruthenium, osmium and iridium branches of bartworks from the platinum residue and the sludge residues; the GTCEu intermediates deleted (old saves: `migrations/`). Loads before 142 (`UNLOCKS_96`) |
| `prototypes/143-fork-casting.lua` | issue #91: the fluid solidifier casts every form of every material with a melt (GT's amounts per form, the material's tier, the one mold), the fluid extractor melts every ingot, the materials with an ingot get a melt (icon: GT's molten texture in the material colour, `tools/gen_gt_icons.py --molten`); its recipes do not count as producers for the auto-unlock of 199 |
| `prototypes/144-fork-dead-fluids.lua` | issue #91: GregTech's producers and uses of fluids nothing made or used: neon, krypton and xenon as blast furnace gases (variants of every argon, helium or radon recipe at GT's ratios), nitric acid from nitrogen dioxide, raw gasoline, gasoline and the gasoline cell |
| `prototypes/142-fork-recipe-unlocks.lua` | issue #91: every Gregtorio recipe gets a technology (explicit table by tier); the producers GT has and Gregtorio lacked (signalum, naquadah doped boule, charcoal byproducts, GT++'s glue line condensed), the component assembly line, the ender tanks, microminer missions for GT's space veins, two technologies (tier four microminers, super glue) and the allow-list `FORK_RECIPES_LOCKED` of recipes that stay locked |
| `scripts/fork-power.lua` | the cooled fluid of the plasma turbines: the plasma a turbine burns (its energy, summed every tick) goes as the cooled fluid into the turbine output hatches next to it, one unit per unit (issue #97: the steam turbines give back distilled water and steam at their own ratio); the fuel check of the generators; the passive loss of the lapotronic supercapacitors (every 10th tick) |
| `scripts/fork-victory.lua` | researching the first level of the tech `victory` wins the game (the game can be continued) |
| `prototypes/145-fork-power-multiblocks.lua` | issue #97: the large steam turbine (EV) and the high pressure steam turbine (IV) as generators of 136 (GT's rotor efficiencies and flows), superheated steam, the fluid nuclear reactor and the large heat exchanger (IV recipe machines: fuel rods heat coolant, hot coolant makes steam or superheated steam), coolant and hot coolant, the lapotronic supercapacitor (an accumulator per capacitor tier, IV with LuV and ZPM upgrades and their capacitor blocks), their technologies; loads after 138 and before 142 and 196 |
| `prototypes/148-fork-gtnh-table-items.lua` | issue #126: GregTech New Horizons' machine recipes for items the crafting table made (anvil in the fluid solidifier and the alloy smelter, the firebrick block in the LV assembler, paper in the chemical bath; sources in the file), the reachable hand-only vanilla recipes (firearm magazine, light armor, rail ramp and support, wood processing) made assembling machine recipes, and the allow-list `FORK_RECIPES_TABLE_ONLY` of recipes of items that only the crafting table, the ME Molecular Assembler or the hand can make, each with its reason; `devcheck.py check` fails for an item that is not in it |
| `prototypes/149-fork-early-research.lua` | issues #127 and #146: the technologies with only red and green science packs and 80 or more units cost a sixth of the units, the MV, HV, EV and IV technologies a tenth, thirteenth, nineteenth and sixteenth (one costs about as long in the factory of its tier as an LV technology in the LV one), rounded to 5; `FORK_EARLY_RESEARCH.rescale()` in data-final-fixes.lua divides the vanilla technologies whose units are set there; the numbers are in the file header |
| `prototypes/151-fork-fluid-extractor.lua` | issue #152: the Fluid Extractor of GT New Horizons, LV to MAX (a copy of the Extractor of its tier, its recipe and technology; sprites from `tools/gen_sprites.py`), every extractor recipe with a fluid result (the melts, molten tin, soldering alloy, wood tar, ...) in its categories `<tier>-fluid-extractor-recipes`; the Extractor and the Steam Extractor keep the item recipes, the Large Fluid Extractor runs the fluid ones; loads after 149 and before 150 |
| `prototypes/153-fork-compressor-air.lua` | issue #153: air from the compressor as in GT New Horizons (the recipe `air-collection` in the compressor, which gets the air collector's output ports); the air collectors LV to MAX are gone, old saves get compressors in their place (`migrations/2026-10-06-issue-153-air-collector.json`); loads after 142 and before 150 |
| `prototypes/154-fork-greenhouse.lua` | issue #165: one Extreme Industrial Greenhouse (GTNH's name for the LV greenhouse, `lv-greenhouse`) instead of a greenhouse per tier; old saves map the MV to MAX greenhouses onto it (`migrations/2026-10-06-issue-165-greenhouse.json`); loads after 153 and before 150 |
| `prototypes/155-fork-ore-chain.lua` | issues #185 to #188, ore chain phases O1 to O4 (`docs/ORE-CHAIN.md`): the chemical bath washing with mercury and sodium persulfate (O2); the electromagnetic separator recipes with small dusts and nuggets (O3); gem sifting with GT's grades and their uses, the autoclave and forge hammer crushing (O4); the laser engraver grade steps, dark ash and small gem piles (#193); GTNH's purified, centrifuged, impure and pure forms of every ore, the washer, thermal centrifuge, macerator, centrifuge and furnace steps with GTNH's byproducts (table `ORE_CHAIN`), the byproduct dusts Gregtorio lacked; old saves map the shortcut recipes (`migrations/2026-10-06-issue-185-ore-chain.json`); loads after 154 and before 150 |
| `prototypes/156-fork-circuit-icons.lua` | issue #164: the circuit variant recipes up to UV (processor, assembly, supercomputer, mainframe of each line) show GT's texture of their GTNH item as recipe icon (`graphics/icons/circuit-recipe-<recipe>.png`, `tools/gen_gt_icons.py`); they keep making the one item of their tier; loads after 155 |
| `prototypes/157-fork-recycling.lua` | issue #190: GTNH's material recycling: every item whose own recipe is a crafting table recipe (and the machine hulls) gets a macerator (dusts), arc furnace (ingots, oxygen) and fluid extractor (melt) recipe from its composition, summed through its recipes down to the material parts (`FORK_RECYCLING_MASS`: GT's masses for the times; `FORK_RECYCLING_BLACKLIST` with reasons); `FORK_RECYCLING.unlock()` in data-final-fixes.lua gives the technologies after the vanilla ones are set; 199 ignores the recipes like the casts |
| `prototypes/150-fork-molds.lua` | molds stay in the machine: the mold is a module in a mold-only slot of alloy smelters, fluid solidifiers and extruders instead of an ingredient or machine component |
| `scripts/fork-molds.lua` | stops machines with a mold recipe and no mold ("Missing mold"); gives machines their mold once in saves from before they had a mold slot |
| `prototypes/fork-menu-simulations.lua` | main menu simulations (PR #65), loaded from `data-final-fixes.lua`: simulations that call `research_all_technologies()` get the bonuses of the vanilla techs Gregtorio disables (the laser defense simulation's character died without them); check with `devcheck.py menusim --sim all --compare` |
| `prototypes/fork-one-pack-research.lua` | cheap research, loaded last from `data-final-fixes.lua`: with the startup setting `gregtorio-continued-one-pack-research` (default off) every technology with science packs costs one research unit with one pack of each kind |
| `prototypes/190-fork-manual-labor.lua` | "manual labor" burner usage: fist instead of the gas pump in the fuel slot, "No manual labor" status |
| `scripts/fork-me-handover.lua` | issue #83: the one-time hand-over of the ME state of older saves to me-network (remote interface `gregtorio-me-handover`, taken by me-network in its `on_init`; fingerprints of every table) |
| `prototypes/191-fork-burner-fire.lua` | issue #137: fire animations (`tools/gen_fire_sprites.py`) for the stone furnace and the iron furnace (a glow in the lower opening while they smelt) and the small coal boiler (its picture is the one without fire, the fire of its own pixels is drawn while it burns); contact sheet `docs/graphics-review/burner-fire.png` |
| `prototypes/195-fork-microminer-tab.lua` | issue #120: the Microminer tab: a first row of the Microverse Projectors (and their controller), then one row per tier (t1 to t4) with its microminer, the data it needs, its mission and the ender tank of its projector; items and recipes in the same rows and order; the unused rows t5 to t12 deleted; `devcheck.py check` fails for a projector recipe outside the tab |
| `prototypes/196-fork-subgroups.lua` | the Fluids tab: a subgroup of the item group `fluids` for every Gregtorio fluid (17 rows: the vanilla row, water and air, gases, acids, ore solutions, fuels, organic chemistry, polymers, nuclear and naquadah, coolants, purified water, plasmas, molten elements, alloys, superalloys and exotic metals, endgame), by an explicit table and name patterns, fallback row `gregtorio-fluids-unsorted`; the vanilla fluids upstream redefines get their vanilla row back; issue #119: Gregtorio icons for molten iron, molten copper (Space Age's fluids, the same prototypes, in the molten row) and steam, and the twelve vanilla and Space Age fluids nothing uses hidden (`FORK_FLUIDS_HIDDEN`); the iron gear item out of "Unsorted" |
| `prototypes/197-fork-fluid-steps.lua` | issue #117: the engine keeps fluid amounts in steps of 2^-24 and cuts a recipe's amount at the step below (14.4 became 14.399999976, nine melted ingots did not fill a block cast); every fluid amount of a recipe that is off that grid is rounded up (takes) or up and nine steps more (gives); `devcheck.py check` fails for an amount off the grid |
| `prototypes/198-fork-crafting-menu.lua` | machine recipes in the crafting menu (issue #49): shows every recipe whose category has a machine (red background, like vanilla), except the allow-list `FORK_CRAFTING_MENU_HIDDEN` (fluid voiding, replaced vanilla recipes, recipes vanilla hides); startup setting `gregtorio-continued-show-machine-recipes` (`settings.lua`, default on) |
| `prototypes/199-fork-finalize.lua` | draft guard (hides broken draft recipes) and auto-unlock of intermediates |
| `prototypes/200-fork-material-parts.lua` | issue #118: the material parts (ingots, plates, blocks, rods, gears, rotors, wires ... of every material: 20 forms, 633 items) in the item group "Material parts", one row per form in GregTech's prefix order, the materials inside a row by the tier of the technology that unlocks their ingot (issue #145; loaded after 199); items only, the recipes keep the rows of their machines; `devcheck.py check` warns for a material without a tier |
| `locale/en/fork.cfg` | generated names for entries without a translation |
| `.discord/server.yml` | this mod's category on the Discord server (channels, forum tags), applied by `.github/workflows/discord.yml` with the tool of https://github.com/Rykon00/gregtorio-me-network_discord-bot; a pull request that only changes `.discord/` is merged and applied automatically |
| `tools/dev_link.py` | links the repo into the Factorio mods folder (working copy is loaded directly) |
| `tools/devcheck/` | headless test harness: load check, progression/craftability analysis, graphics and runtime checks; `handover` runs the prototype of the ME state hand-over of issue #83 (`docs/SPLIT.md`) |
| `tools/balance_model.py` | full-chain cost model for balance passes: time of a part or a technology in a reference factory per tier, from the balance dump of `devcheck.py check --balance-out`; `--dtpf` compares the plasma forge route with the fusion route |
| `tools/build.py` | builds `dist/gregtorio-continued_<version>.zip`, optionally installs it; `--portal` leaves out the Photoshop sources (mod portal zip) |
| `tools/check_syntax.py` | Lua syntax check (`--loaded` = only files `data.lua` actually loads) |
| `tools/gen_sprites.py` | machine sprites/icons from GT5-Unofficial textures (`--gt <path to checkout>`); the basic machines from IV up as upstream's LV to EV sprites, working strips and icons with the casing in the tier's colour (issue #148; from UHV up with the pattern of the tier's GT hull), tier dynamo hatches on the turbines and reactors, tier energy hatch layers and icons for the IV to UXV upgrade multiblocks |
| `tools/gen_gt_icons.py` | item icons from GT textures for the items in `tools/gt-icon-items.txt` (GT texture of the item, GT material icon sets in GT's colours, or a composition of GT parts); `--gt`, `--core <NewHorizonsCoreMod checkout>` |
| `tools/gen_icons.py` | placeholder icons (recolored neighbor icons) for new items without an icon; replace them with `gen_gt_icons.py` (add the item to `tools/gt-icon-items.txt`) |
| `tools/gen_tech_icons.py` | technology icons instead of the "NYI" placeholder (from the main unlocked item, listed in `tools/tech-icons.tsv`) |
| `tools/gen_review_sheet.py` | before/after contact sheets of changed icons and sprites (`docs/graphics-review/`); `tiers`: the basic machines LV to MAX in a row (issue #148) |
| `tools/gen_fire_sprites.py` | the fire animations of the burner machines of the steam age (issue #137), cut from the machines' own pictures |
| `tools/gen_ui_icons.py` | GUI icons derived from item icons (empty manual-labor slot, red "no manual labor" alert) |
| `tools/gen_locale.py` | adds missing English names to `locale/en/fork.cfg` |

## Status

| Tier | State |
|---|---|
| Steam – EV | playable (upstream), gaps closed |
| IV | playable (fork 0.2.0) |
| LuV | playable (fork 0.2.0); naquadah line, bacterial vat, crystal processors and fusion MK1 finished (see `docs/ROADMAP.md`) |
| ZPM | playable (fork); ZPM components, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| UV | playable (fork); UV circuit, ZPM assembly line, UV components, fusion MK2, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| UHV | playable (fork); wetware line and UHV circuit, UHV components, fusion MK3, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| UEV | playable (fork); water purification, bio line and UEV circuit, UEV components, fusion MK4, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| UIV | playable (fork); optical line and UIV circuit, UIV components, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| Fusion MK5 | playable (fork); makes spacetime and universium, the metals of UMV and UXV |
| UMV | playable (fork); exotic line and UMV circuit, UMV components, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| UXV | playable (fork); temporal line and UXV circuit, UXV components, science pack, energy hatch and machines (see `docs/ROADMAP.md`) |
| Plasma forge, QFT | playable (fork, phase 6a); the dimensionally transcendent plasma forge (UMV) makes the endgame metals more efficiently than the fusion reactors, the quantum force transformer (UMV) runs the platinum and naquadah lines in one step (see `docs/ROADMAP.md`, "Phase 6a: QFT and DTPF") |
| MAX, stargate, victory | playable (fork); the stargate makes 1000 MAX science packs, the first level of `victory` wins the game. Balance of the last tiers is untested in the real game |
| After victory: Forge of the Gods, MAX tier | playable (fork, phase 6b); the Forge of the Gods makes star matter, universium and magmatter, the MAX tier (Planck circuit, components, hatches, machines, turbine) is built from magmatter; the infinite `godforge-upgrades` and further `victory` levels are the long-term goal (see `docs/ROADMAP.md`, "Phase 6b: MAX tier and godforge") |
| Endgame power | playable (fork); plasma turbines LuV to UXV, the naquadah fuel line and large naquadah reactors from UV, dynamo hatches LuV to UXV (see `docs/ROADMAP.md`, "Side quest: endgame power") |
| Drafts | every draft is triaged (`docs/ROADMAP.md`, "Drafts and endgame materials"): made real, replaced or removed for good; the draft guard (`FORK-DRAFT` in the log) may only hide the documented rest list (`DRAFTS_OK` in `tools/devcheck/devcheck.py`) |

## Workflow

```bash
# once: link the working copy into the Factorio mods folder
# (existing gregtorio-continued zips are moved to gregtorio-zips-backup/ next to the mods folder,
#  an old "Gregtorio" link to this repo is removed)
python tools/dev_link.py
# from then on every change/pull is live after restarting Factorio

# alternative without a link: build the zip and copy it into the mods folder
python tools/build.py --install

# release
#   1. bump "version" in info.json
#   2. add a new section at the top of changelog.txt
#   3. commit, tag, push
git tag v0.2.0 && git push --follow-tags
```

Pushing a `v*` tag makes the GitHub Action build the zip and attach it to a GitHub release. The syntax check and the build run on every push and pull request.

## Mod portal

The portal name `Gregtorio` belongs to the original author, Damien Reave, who can no longer
update it. Since 0.3.0 the mod is called **Gregtorio Continued** (`gregtorio-continued`,
https://mods.factorio.com/mod/gregtorio-continued), in the repo as well as on the portal.
`info.json` lists `! Gregtorio`, so the two cannot be enabled together. Since 0.5.0 it depends on
[ME Network](https://mods.factorio.com/mod/me-network) (`me-network`), which the game downloads with it.

Saves from `Gregtorio` load with `gregtorio-continued`: prototype names did not change, so
buildings, items and research stay. What a save keeps per mod name is lost once: the script
state (contents of the old ME Fluid Drives, running autocrafting jobs, open terminal windows); machines
with a mold recipe and an empty mold slot get a mold once.

## Contributing

See `CONTRIBUTING.md`. Everything on GitHub is in English.

## License

GPLv3 like the original by Damien Reave (see `LICENSE`).

Graphics taken from other projects (generated by the `tools/gen_*.py` scripts; `docs/graphics-review/icon-sources.tsv`
names the textures of every generated item icon):

* [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) by GTNewHorizons, LGPL-3.0: machine, casing, hatch,
  component, circuit, material and fluid cell textures. This includes the mods merged into that repository under the
  same license: GT++ (`miscutils`: fusion casings MK-III/MK-IV and coils, controller screens), GoodGenerator (compact
  fusion coils, high density plutonium, wrapped plutonium ingot, radioactive waste), bartworks (borosilicate glass, wrap band).
* [NewHorizonsCoreMod](https://github.com/GTNewHorizons/NewHorizonsCoreMod) by GTNewHorizons, GPL-3.0: stargate chevron,
  frame part and radiation containment plate, the UMV, UXV and MAX (Planck) circuits.

The ME network and its graphics are in the mod [me-network](https://github.com/Rykon00/me-network) since issue #83.
