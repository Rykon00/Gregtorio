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
| `prototypes/110-fork-luv.lua` | LuV: materials, assembly line, LuV machines, science pack, techs |
| `prototypes/199-fork-finalize.lua` | draft guard (hides broken draft recipes) and auto-unlock of intermediates |
| `locale/en/fork.cfg` | generated names for entries without a translation |
| `tools/build.py` | builds `dist/Gregtorio_<version>.zip`, optionally installs it |
| `tools/check_syntax.py` | Lua syntax check (`--loaded` = only files `data.lua` actually loads) |
| `tools/gen_sprites.py` | machine sprites/icons from GT5-Unofficial textures (`--gt <path to checkout>`) |
| `tools/gen_icons.py` | placeholder icons (recolored neighbor icons) for items without an icon |
| `tools/gen_locale.py` | adds missing English names to `locale/en/fork.cfg` |

## Status

| Tier | State |
|---|---|
| Steam – EV | playable (upstream), gaps closed |
| IV | playable (fork 0.2.0) |
| LuV | playable (fork 0.2.0); crystal processors, bacterial vat and fusion are still drafts |
| ZPM+ | draft; broken recipes are hidden on load (`FORK-DRAFT` in the log) |

## Workflow

```bash
# after changes: build and drop it straight into the Factorio mods folder
python tools/build.py --install

# release
#   1. bump "version" in info.json
#   2. add a new section at the top of changelog.txt
#   3. commit, tag, push
git tag v0.2.0 && git push --follow-tags
```

Pushing a `v*` tag makes the GitHub Action build the zip and attach it to a GitHub release. The syntax check and the build run on every push and pull request.

Note: the mod name in `info.json` stays `Gregtorio` so existing saves keep working.

## License

GPLv3 like the original (see `LICENSE`). Textures taken from [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) are LGPL-3.0.
