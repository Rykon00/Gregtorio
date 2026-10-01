# Gregtorio Continued

Continuation of [Gregtorio](https://mods.factorio.com/mod/Gregtorio) by **Damien Reave**, a GregTech-style total overhaul mod for Factorio 2.0. On the mod portal: [Gregtorio Continued](https://mods.factorio.com/mod/gregtorio-continued) (`gregtorio-continued`).

The upstream repository ([Damien-Reave/Gregtorio](https://github.com/Damien-Reave/Gregtorio)) only contains the LICENSE; the code was only published as zip files. This fork therefore starts from the unmodified **0.1.9** release from the mod portal (tag `v0.1.9-upstream`). Every change after that is a regular git commit.

## Layout

The repository root is the mod itself (`info.json`, `data.lua`, `prototypes/`, `graphics/`, `locale/`).

| Path | Contents |
|---|---|
| `prototypes/NN-*.lua` | upstream items, recipes and machines per tier (09 Steam … 31 UIV; `80-umv-age-item.lua` and `90-uxv-age-item.lua` are not loaded), `98-technology.lua` for the tech tree |
| `prototypes/100-fork-fixes.lua` | missing unlocks and recipes, chicken-and-egg fixes |
| `prototypes/101-fork-machines.lua` | tier categories, EV/IV machines and multiblocks, `fork_make_tier_machine` |
| `prototypes/102-fork-resources.lua` | disables the vanilla resource patches (no spawning, not minable) |
| `prototypes/103-fork-qol-techs.lua` | issue #29: the vanilla quality-of-life techs (bulk/stack inserter, inserter capacity bonus, express and turbo belts, belt capacity, worker robot speed and cargo size) gated onto Gregtorio techs with Gregtorio science packs, GT recipes for the inserters and belts they unlock |
| `prototypes/110-fork-luv.lua` | LuV: materials, assembly line, LuV machines, science pack, techs |
| `prototypes/120-fork-ae2.lua` | AE2 / ME network (issue #68, design record `docs/ME-REWORK.md`): ME Cable (placed by the fluix cable), ME Controller, ME Drive with 10 cell slots, storage cells (items with tags), ME Interface, ME Import and Export Bus, ME Terminal, techs; the old logistic-network prototypes stay hidden for saves |
| `prototypes/121-fork-ae2-autocrafting.lua` | AE2 autocrafting: ME Pattern Provider, ME Molecular Assembler, ME Crafting CPU, tech `me-autocrafting` (guide: `docs/AE2.md`) |
| `prototypes/122-fork-ae2-fluids.lua` | AE2 fluids (issue #68 R2): fluid storage cells for the ME Drive (items with tags), ME Fluid Interface, ME Fluid Import and Export Bus, techs `me-fluid-storage` and `me-fluid-storage-256k`; the old ME Fluid Drives stay hidden for saves (guide: `docs/AE2.md`) |
| `prototypes/125-fork-luv-endgame.lua` | LuV endgame: naquadah ore line and neutron activator, bacterial vat and mutagen, circuit assembly line and crystal processors, fusion reactor MK1 and the first plasmas |
| `prototypes/126-fork-zpm.lua` | ZPM: naquadah alloy parts, europium, ZPM components, casing and hull, ZPM science pack, ZPM energy hatch, ZPM machines and multiblock upgrades, techs |
| `prototypes/127-fork-uv.lua` | UV: naquadria, americium and neutronium (fusion), superconductors, UV circuit (crystal processor mainframe), ZPM assembly line, UV components, casing and hull, fusion reactor MK2 and its plasmas, UV science pack, UV energy hatch, UV machines and multiblock upgrades, techs |
| `prototypes/128-fork-uhv.lua` | UHV: tritanium and the triamerotronium superconductor, the wetware line (UHV circuit), UHV components, casing and hull, fusion reactor MK3 with advanced fusion coils, UHV science pack, UHV energy hatch, UHV machines and multiblock upgrades, techs |
| `prototypes/129-fork-water-purification.lua` | water purification plant (grades 1-8, quark creation catalyst), europium/americium doped wafers, NPIC/PPIC/QPIC/FPIC/APIC chips used by the ZPM to UXV energy and dynamo hatches and the MK2 to MK5 controllers, complex SMDs for the wetware to temporal circuit lines |
| `prototypes/131-fork-uev.lua` | UEV: cosmic neutronium, draconium and infinity (fusion), dracofinium superconductor, bio line (UEV circuit), UEV components, casing and hull, fusion reactor MK4, UEV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/132-fork-uiv.lua` | UIV: transcendent metal (MK4), nether star cable, chromnorox superconductor, optical line (UIV circuit), UIV components, casing and hull, UIV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/133-fork-umv.lua` | fusion reactor MK5 (advanced fusion coil II, casing MK4, rhugnor, flerovium, energy module), spacetime (UMV metal) and universium (UXV metal) from the MK5, spacetime cable, hypocosmium superconductor, exotic line (UMV circuit), UMV components, casing and hull, UMV science pack, energy hatch, machines and multiblock upgrades, techs; also the helpers shared with 134 and 135 (global table `FORK5B`) |
| `prototypes/134-fork-uxv.lua` | UXV: universium parts and cable, eternity superconductor, temporal line (UXV circuit), UXV components, casing and hull, UXV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/135-fork-endgame.lua` | endgame: the stargate and its parts from UXV parts, the MAX science pack, the tech `stargate` |
| `prototypes/136-fork-power.lua` | endgame power: fuel values of the plasmas, plasma balance (issue #32: helium-3 yield, fusion recipe times and inputs), large plasma turbines (LuV to UXV) with turbine output hatches for the cooled fluid, the naquadah fuel line (acid emulsion, emulsion, solution, light and heavy naquadah fuel, naquadah based fuel MK1 to MK3, the excited uranium and plutonium fuels), large naquadah reactors (UV to UXV), dynamo hatches LuV to UXV, techs |
| `prototypes/137-fork-endgame-materials.lua` | issues #39 and #36: the drafts removed for good (Thaumcraft, GT++ RuneScape plasmas, atomic separation catalyst and naquadah fuel cracking; deleted, `FORK-REMOVED` in the log), the circuit assembler recipe of the lapotronic energy orb cluster (tech `lapotronic-energy-orbs`), high density plutonium for the plutonium based liquid fuel; issue #36: super coolant (ledox and callisto ice from the end microminer), the space coolant cells, fluxed electrum, bedrockium and quantium with their techs, and the stand-ins they replace (hatches, UV coil, UHV/UEV/UMV components, grade 5 and 7 water, fusion MK3 controller, naquadah fuel MK2) |
| `prototypes/139-fork-endgame-multiblocks.lua` | phase 6a (issue #37): the dimensionally transcendent plasma forge (UMV; crude and resplendent catalyst, neutronium to universium with less input and reactor time than the fusion reactors) and the quantum force transformer (UMV; GT's platinum line and naquadah recipes, one recipe per main output), their parts and techs. Loads before 138, which sets the unit counts of its technologies |
| `prototypes/140-fork-godforge.lua` | phase 6b (issue #37): the godforge (UXV, 13x13, after the stargate, MAX science): raw star matter, the plasmas of the stellar catalyst, universium, time and space fluids, magmatter; the stellar catalyst tier of the plasma forge; the infinite `godforge-upgrades` (productivity, the long-term sink after victory) |
| `prototypes/141-fork-max.lua` | phase 6b: the MAX tier: magmatter parts and cable, the Planck line (MAX circuit), MAX components, casing, hull, voltage coil, energy and dynamo hatch, the MAX science pack from MAX parts, the MAX machines (`fork_make_tier_machine`), the MAX large plasma turbine, techs. 140 and 141 load before 138, which sets their unit counts |
| `prototypes/138-fork-research-balance.lua` | issue #30: the unit counts of the technologies from UV to `victory`, scaled so each costs about as long as a ZPM technology in the reference factory of its tier (see "Balance pass: endgame" in `docs/ROADMAP.md`) |
| `scripts/fork-power.lua` | the cooled fluid of the plasma turbines: the plasma a turbine burns (its energy, summed every tick) goes as the cooled fluid into the turbine output hatches next to it, one unit per unit |
| `scripts/fork-victory.lua` | researching the first level of the tech `victory` wins the game (the game can be continued) |
| `prototypes/150-fork-molds.lua` | molds stay in the machine: the mold is a module in a mold-only slot of alloy smelters, fluid solidifiers and extruders instead of an ingredient or machine component |
| `scripts/fork-molds.lua` | stops machines with a mold recipe and no mold ("Missing mold"); gives machines their mold once in saves from before they had a mold slot |
| `prototypes/fork-menu-simulations.lua` | main menu simulations (PR #65), loaded from `data-final-fixes.lua`: simulations that call `research_all_technologies()` get the bonuses of the vanilla techs Gregtorio disables (the laser defense simulation's character died without them); check with `devcheck.py menusim --sim all --compare` |
| `prototypes/190-fork-manual-labor.lua` | "manual labor" burner usage: fist instead of the gas pump in the fuel slot, "No manual labor" status |
| `scripts/fork-me-network.lua` | ME network core (issue #68): the cable graph (kept from the build and removal events), networks with their controller and status, storage cells and the storage API (insert, extract, count, contents), the ME Drive (slots, window, lights), the cable router, remote interface `gregtorio-me-network` |
| `scripts/fork-me-io.lua` | ME Interface and import/export buses, the I/O step every 15 ticks (also runs the fluid step), bus window, remote interface `gregtorio-me-io` |
| `scripts/fork-me-migrate.lua` | converts ME networks from before issue #68 (old drives into drives with cells, controller, interface, cables), checks the item totals, remote interface `gregtorio-me-migrate` |
| `scripts/fork-me-terminal.lua` | ME Terminal GUI (status line, storage tab with items, fluids and the player's inventory, crafting tab), routes the GUI events of every ME window |
| `scripts/fork-me-autocraft.lua` | autocrafting: patterns from provider-adjacent machines (item and fluid recipes), planner, jobs and crafting CPUs with their tiers (job slots, speed; bounded work every 20 ticks, fluid boxes filled and drained by index), remote interface `gregtorio-me-autocraft` |
| `scripts/fork-me-circuit.lua` | issue #38: ME Level Maintainer (keeps an item or fluid in stock by starting crafting jobs, circuit amount and on/off) and ME Circuit Interface (network contents on the circuit wire), a step hook of the autocrafting step; settings in blueprints; remote interface `gregtorio-me-circuit` |
| `scripts/fork-me-fluids.lua` | the ME Fluid Interface (import/export in the 15-tick I/O step, panel, settings in blueprints and paste) and the fluid calls of the other modules on top of the storage engine of `fork-me-network.lua`, remote interface `gregtorio-me-fluids` |
| `prototypes/198-fork-crafting-menu.lua` | machine recipes in the crafting menu (issue #49): shows every recipe whose category has a machine (red background, like vanilla), except the allow-list `FORK_CRAFTING_MENU_HIDDEN` (fluid voiding, replaced vanilla recipes, recipes vanilla hides); startup setting `gregtorio-continued-show-machine-recipes` (`settings.lua`, default on) |
| `prototypes/199-fork-finalize.lua` | draft guard (hides broken draft recipes) and auto-unlock of intermediates |
| `locale/en/fork.cfg` | generated names for entries without a translation |
| `tools/dev_link.py` | links the repo into the Factorio mods folder (working copy is loaded directly) |
| `tools/devcheck/` | headless test harness: load check, progression/craftability analysis, graphics and runtime checks |
| `tools/balance_model.py` | full-chain cost model for balance passes: time of a part or a technology in a reference factory per tier, from the balance dump of `devcheck.py check --balance-out`; `--dtpf` compares the plasma forge route with the fusion route |
| `tools/build.py` | builds `dist/gregtorio-continued_<version>.zip`, optionally installs it; `--portal` leaves out the Photoshop sources (mod portal zip) |
| `tools/check_syntax.py` | Lua syntax check (`--loaded` = only files `data.lua` actually loads) |
| `tools/gen_sprites.py` | machine sprites/icons from GT5-Unofficial textures (`--gt <path to checkout>`); tier hulls from UHV up, tier dynamo hatches on the turbines and reactors, tier energy hatch layers and icons for the IV to UXV upgrade multiblocks |
| `tools/gen_gt_icons.py` | item icons from GT textures for the items in `tools/gt-icon-items.txt` (GT texture of the item, GT material icon sets in GT's colours, or a composition of GT parts); `--gt`, `--core <NewHorizonsCoreMod checkout>` |
| `tools/gen_icons.py` | placeholder icons (recolored neighbor icons) for new items without an icon; replace them with `gen_gt_icons.py` (add the item to `tools/gt-icon-items.txt`) |
| `tools/gen_ae2_sprites.py` | ME network and autocrafting sprites, icons and tech icons (GT5-Unofficial casings + Pillow); `--fluids` derives the fluid drive, cell and interface graphics from the item PNGs without a GT checkout; `--r1` the cable, drive, controller and bus graphics of issue #68, `--r2` the fluid buses |
| `tools/gen_tech_icons.py` | technology icons instead of the "NYI" placeholder (from the main unlocked item, listed in `tools/tech-icons.tsv`) |
| `tools/gen_review_sheet.py` | before/after contact sheets of changed icons and sprites (`docs/graphics-review/`) |
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
| After victory: godforge, MAX tier | playable (fork, phase 6b); the godforge makes star matter, universium and magmatter, the MAX tier (Planck circuit, components, hatches, machines, turbine) is built from magmatter; the infinite `godforge-upgrades` and further `victory` levels are the long-term goal (see `docs/ROADMAP.md`, "Phase 6b: MAX tier and godforge") |
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
`info.json` lists `! Gregtorio`, so the two cannot be enabled together.

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

The ME network graphics (`tools/gen_ae2_sprites.py`) use only GT5-Unofficial casings and screens and shapes drawn
with Pillow; the ME cable, the ME Drive's cell bays, the bus plates and arrows of issue #68 are drawn by the script
or derived from those sprites. No textures of Applied Energistics 2 are used (its assets are not under a license
compatible with this mod's GPLv3).
