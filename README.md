# Gregtorio (fork)

Fork of [Gregtorio](https://mods.factorio.com/mod/Gregtorio) by **Damien Reave**, a GregTech-style total overhaul mod for Factorio 2.0.

The upstream repository ([Damien-Reave/Gregtorio](https://github.com/Damien-Reave/Gregtorio)) only contains the LICENSE; the code was only published as zip files. This fork therefore starts from the unmodified **0.1.9** release from the mod portal (tag `v0.1.9-upstream`). Every change after that is a regular git commit.

## Layout

The repository root is the mod itself (`info.json`, `data.lua`, `prototypes/`, `graphics/`, `locale/`).

| Path | Contents |
|---|---|
| `prototypes/NN-*.lua` | upstream items, recipes and machines per tier (09 Steam … 31 UIV), `98-technology.lua` for the tech tree |
| `prototypes/100-fork-fixes.lua` | missing unlocks and recipes, chicken-and-egg fixes |
| `prototypes/101-fork-machines.lua` | tier categories, EV/IV machines and multiblocks, `fork_make_tier_machine` |
| `prototypes/102-fork-resources.lua` | disables the vanilla resource patches (no spawning, not minable) |
| `prototypes/110-fork-luv.lua` | LuV: materials, assembly line, LuV machines, science pack, techs |
| `prototypes/120-fork-ae2.lua` | AE2 / ME network on top of the logistic network: ME Drives with storage cells, ME Interface, ME Terminal, ME Controller, techs |
| `prototypes/125-fork-luv-endgame.lua` | LuV endgame: naquadah ore line and neutron activator, bacterial vat and mutagen, circuit assembly line and crystal processors, fusion reactor MK1 and the first plasmas |
| `prototypes/126-fork-zpm.lua` | ZPM: naquadah alloy parts, europium, ZPM components, casing and hull, ZPM science pack, ZPM energy hatch, ZPM machines and multiblock upgrades, techs |
| `prototypes/127-fork-uv.lua` | UV: naquadria, americium and neutronium (fusion), superconductors, UV circuit (crystal processor mainframe), ZPM assembly line, UV components, casing and hull, fusion reactor MK2 and its plasmas, UV science pack, UV energy hatch, UV machines and multiblock upgrades, techs |
| `prototypes/128-fork-uhv.lua` | UHV: tritanium and the triamerotronium superconductor, the wetware line (UHV circuit), UHV components, casing and hull, fusion reactor MK3 with advanced fusion coils, UHV science pack, UHV energy hatch, UHV machines and multiblock upgrades, techs |
| `prototypes/130-fork-molds.lua` | molds stay in the machine: the mold is a module in a mold-only slot of alloy smelters, fluid solidifiers and extruders instead of an ingredient or machine component |
| `scripts/fork-molds.lua` | stops machines with a mold recipe and no mold ("Missing mold"); gives machines their mold once in saves from before they had a mold slot |
| `prototypes/190-fork-manual-labor.lua` | "manual labor" burner usage: fist instead of the gas pump in the fuel slot, "No manual labor" status |
| `scripts/fork-me-terminal.lua` | runtime part of the ME network: terminal GUI (event driven), ME Interface default |
| `prototypes/199-fork-finalize.lua` | draft guard (hides broken draft recipes) and auto-unlock of intermediates |
| `locale/en/fork.cfg` | generated names for entries without a translation |
| `tools/dev_link.py` | links the repo into the Factorio mods folder (working copy is loaded directly) |
| `tools/devcheck/` | headless test harness: load check, progression/craftability analysis, graphics and runtime checks |
| `tools/build.py` | builds `dist/Gregtorio_<version>.zip`, optionally installs it |
| `tools/check_syntax.py` | Lua syntax check (`--loaded` = only files `data.lua` actually loads) |
| `tools/gen_sprites.py` | machine sprites/icons from GT5-Unofficial textures (`--gt <path to checkout>`) |
| `tools/gen_icons.py` | placeholder icons (recolored neighbor icons) for items without an icon |
| `tools/gen_ae2_sprites.py` | ME network sprites, icons and tech icons (GT5-Unofficial casings + Pillow) |
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
| UEV+ | draft; broken recipes are hidden on load (`FORK-DRAFT` in the log) |

## Workflow

```bash
# once: link the working copy into the Factorio mods folder
# (existing Gregtorio zips are moved to gregtorio-zips-backup/ next to the mods folder)
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

Note: the mod name in `info.json` stays `Gregtorio` so existing saves keep working.

## Contributing

See `CONTRIBUTING.md`. Everything on GitHub is in English.

## License

GPLv3 like the original (see `LICENSE`). Textures taken from [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) are LGPL-3.0.
