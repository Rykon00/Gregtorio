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
| `prototypes/110-fork-luv.lua` | LuV: materials, assembly line, LuV machines, science pack, techs |
| `prototypes/120-fork-ae2.lua` | AE2 / ME network on top of the logistic network: ME Drives with storage cells, ME Interface, ME Terminal, ME Controller, techs |
| `prototypes/121-fork-ae2-autocrafting.lua` | AE2 autocrafting: ME Pattern Provider, ME Molecular Assembler, ME Crafting CPU, tech `me-autocrafting` (guide: `docs/AE2.md`) |
| `prototypes/122-fork-ae2-fluids.lua` | AE2 fluids: fluid storage cells, ME Fluid Drives, ME Fluid Interface, techs `me-fluid-storage` and `me-fluid-storage-256k` (guide: `docs/AE2.md`) |
| `prototypes/125-fork-luv-endgame.lua` | LuV endgame: naquadah ore line and neutron activator, bacterial vat and mutagen, circuit assembly line and crystal processors, fusion reactor MK1 and the first plasmas |
| `prototypes/126-fork-zpm.lua` | ZPM: naquadah alloy parts, europium, ZPM components, casing and hull, ZPM science pack, ZPM energy hatch, ZPM machines and multiblock upgrades, techs |
| `prototypes/127-fork-uv.lua` | UV: naquadria, americium and neutronium (fusion), superconductors, UV circuit (crystal processor mainframe), ZPM assembly line, UV components, casing and hull, fusion reactor MK2 and its plasmas, UV science pack, UV energy hatch, UV machines and multiblock upgrades, techs |
| `prototypes/128-fork-uhv.lua` | UHV: tritanium and the triamerotronium superconductor, the wetware line (UHV circuit), UHV components, casing and hull, fusion reactor MK3 with advanced fusion coils, UHV science pack, UHV energy hatch, UHV machines and multiblock upgrades, techs |
| `prototypes/129-fork-water-purification.lua` | water purification plant (grades 1-6), europium/americium doped wafers, NPIC/PPIC/QPIC chips used by the ZPM/UV/UHV energy hatches and the MK2/MK3 controllers |
| `prototypes/131-fork-uev.lua` | UEV: cosmic neutronium, draconium and infinity (fusion), dracofinium superconductor, bio line (UEV circuit), UEV components, casing and hull, fusion reactor MK4, UEV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/132-fork-uiv.lua` | UIV: transcendent metal (MK4), nether star cable, chromnorox superconductor, optical line (UIV circuit), UIV components, casing and hull, UIV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/133-fork-umv.lua` | fusion reactor MK5 (advanced fusion coil II, casing MK4, rhugnor, flerovium, energy module), spacetime (UMV metal) and universium (UXV metal) from the MK5, spacetime cable, hypocosmium superconductor, exotic line (UMV circuit), UMV components, casing and hull, UMV science pack, energy hatch, machines and multiblock upgrades, techs; also the helpers shared with 134 and 135 (global table `FORK5B`) |
| `prototypes/134-fork-uxv.lua` | UXV: universium parts and cable, eternity superconductor, temporal line (UXV circuit), UXV components, casing and hull, UXV science pack, energy hatch, machines and multiblock upgrades, techs |
| `prototypes/135-fork-endgame.lua` | endgame: the stargate and its parts from UXV parts, the MAX science pack, the tech `stargate` |
| `scripts/fork-victory.lua` | researching the first level of the tech `victory` wins the game (the game can be continued) |
| `prototypes/150-fork-molds.lua` | molds stay in the machine: the mold is a module in a mold-only slot of alloy smelters, fluid solidifiers and extruders instead of an ingredient or machine component |
| `scripts/fork-molds.lua` | stops machines with a mold recipe and no mold ("Missing mold"); gives machines their mold once in saves from before they had a mold slot |
| `prototypes/190-fork-manual-labor.lua` | "manual labor" burner usage: fist instead of the gas pump in the fuel slot, "No manual labor" status |
| `scripts/fork-me-terminal.lua` | runtime part of the ME network: terminal GUI (storage tab with items and fluids, crafting tab, event driven), ME Interface default, routes the fluid GUI events |
| `scripts/fork-me-autocraft.lua` | autocrafting: patterns from provider-adjacent machines (item and fluid recipes), planner, jobs and crafting CPUs (bounded work every 20 ticks, fluid boxes filled and drained by index), remote interface `gregtorio-me-autocraft` |
| `scripts/fork-me-fluids.lua` | fluids in the ME network: virtual per-drive storage (`storage.fork_me_fluids`), fluid interface import/export every 15 ticks, drive contents on the picked up item, drive and interface GUIs, remote interface `gregtorio-me-fluids` |
| `prototypes/199-fork-finalize.lua` | draft guard (hides broken draft recipes) and auto-unlock of intermediates |
| `locale/en/fork.cfg` | generated names for entries without a translation |
| `tools/dev_link.py` | links the repo into the Factorio mods folder (working copy is loaded directly) |
| `tools/devcheck/` | headless test harness: load check, progression/craftability analysis, graphics and runtime checks |
| `tools/build.py` | builds `dist/gregtorio-continued_<version>.zip`, optionally installs it; `--portal` leaves out the Photoshop sources (mod portal zip) |
| `tools/check_syntax.py` | Lua syntax check (`--loaded` = only files `data.lua` actually loads) |
| `tools/gen_sprites.py` | machine sprites/icons from GT5-Unofficial textures (`--gt <path to checkout>`) |
| `tools/gen_icons.py` | placeholder icons (recolored neighbor icons) for items without an icon |
| `tools/gen_ae2_sprites.py` | ME network and autocrafting sprites, icons and tech icons (GT5-Unofficial casings + Pillow); `--fluids` derives the fluid drive, cell and interface graphics from the item PNGs without a GT checkout |
| `tools/gen_tech_icons.py` | technology icons instead of the "NYI" placeholder (from the main unlocked item) |
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
| MAX, stargate, victory | playable (fork); the stargate makes 1000 MAX science packs, the first level of `victory` wins the game. Balance of the last tiers is untested in the real game |
| Drafts | the rest of the GTNH endgame chains (plasma generator, UU matter, water purification grades 7-8, ...) is draft; broken recipes are hidden on load (`FORK-DRAFT` in the log) |

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
state (contents of ME Fluid Drives, running autocrafting jobs, open terminal windows); machines
with a mold recipe and an empty mold slot get a mold once.

## Contributing

See `CONTRIBUTING.md`. Everything on GitHub is in English.

## License

GPLv3 like the original by Damien Reave (see `LICENSE`). Textures taken from [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) are LGPL-3.0.
