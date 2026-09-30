# Notes for AI agents

- **Language:** everything that ends up on GitHub is English (code, comments, log messages,
  locale, commits, PRs, issues, docs). Chat with the maintainer may be in German.
- Read `CONTRIBUTING.md` and the layout table in `README.md` first.
- Upstream content lives in `prototypes/0*-*.lua` … `98-technology.lua`; keep changes there
  minimal. Fork logic lives in `prototypes/1xx-fork-*.lua`, loaded at the end of `data.lua`
  in this order: 100 fixes, 101 machines, 102 resources, 103 QoL techs (re-gates the vanilla inserter, belt and
  worker robot techs of issue #29 onto Gregtorio techs, GT recipes for bulk/stack inserters and express/turbo belts), 110 LuV, 120 AE2 (ME network),
  121 AE2 autocrafting (pattern provider, molecular assembler, crafting CPU; runtime in
  `scripts/fork-me-autocraft.lua`, guide `docs/AE2.md`), 122 AE2 fluids (fluid cells, fluid drives,
  fluid interface; runtime in `scripts/fork-me-fluids.lua`), 125 LuV endgame (naquadah, bacterial vat, crystal processors, fusion MK1), 126 ZPM, 127 UV
  (UV circuit, ZPM assembly line, UV components, fusion MK2), 128 UHV (wetware line, tritanium,
  UHV components, fusion MK3), 129 water purification (grades 1-8, NPIC/PPIC/QPIC/FPIC/APIC chips, complex SMDs; the FPIC/APIC users in 131-134 list its techs as prerequisites),
  131 UEV (bio line, UEV components, fusion MK4), 132 UIV (optical line, UIV components),
  133 UMV (fusion MK5, spacetime, exotic line, UMV components; also the shared helpers, global
  table `FORK5B`), 134 UXV (universium, temporal line, UXV components), 135 endgame (stargate,
  MAX science pack; researching `victory` wins the game via `scripts/fork-victory.lua`), 136 power
  (plasma fuel values, plasma balance of issue #32, large plasma turbines with turbine output hatches, naquadah fuel line, large
  naquadah reactors, dynamo hatches LuV to UXV; runtime in `scripts/fork-power.lua`: fuel check, turbine output hatch),
  137 endgame materials (issues #39 and #36: deletes the drafts removed for good, `FORK-REMOVED` in the log; the
  lapotronic energy orb cluster and high density plutonium drafts; must load after 136, whose plutonium fuel it changes),
  150 molds (mold slot instead of mold ingredient; must load after every file that creates
  machines), 190 manual-labor
  burner usage (fist icon in the fuel slot), 198 crafting menu (shows machine recipes, which upstream
  `create_recipe` hides; a recipe that must stay hidden goes into its allow-list
  `FORK_CRAFTING_MENU_HIDDEN`, devcheck fails otherwise; startup setting in `settings.lua`), 199 finalize.
  The phase plan is in `docs/ROADMAP.md`.
  Runtime fork code lives in `scripts/` and is required from `control.lua` (`fork-me-terminal.lua`,
  `fork-me-autocraft.lua`, `fork-me-fluids.lua`, `fork-molds.lua`, `fork-victory.lua`, `fork-power.lua`).
  Tick intervals in use: `on_nth_tick` 60 (ME terminal), 30 (molds), 20 (autocrafting), 15 (fluids);
  `on_tick` (fork-power: turbine energy every tick, fuel check and output hatches every 10th tick);
  registrations for the same interval (or a second `on_tick`) overwrite each other, so a new periodic
  task picks a free interval. `on_init` belongs to the ME terminal, so other scripts keep their state
  lazy (`storage.fork_ae2`, `storage.fork_me_fluids`, `storage.fork_molds`, `storage.fork_power`).
- Generators (`generator` prototypes that burn fluids by fuel value, 136) are demand driven; an
  input-output fluid box keeps part of its fluid in the pipeline segment (`get_fluid_count` reports
  only the entity's part, `fluidbox.get_fluid_segment_contents` the rest), so tests count both.
- `199-fork-finalize.lua` hides draft recipes with missing parts (`FORK-DRAFT` in the log) and
  auto-unlocks intermediates (`FORK-AUTOUNLOCK`). Check the log after changes.
- New machines one tier up: `fork_make_tier_machine(base, from_tier, to_tier, frames, tech)`.
  Their sprites/icons come from `tools/gen_sprites.py --gt <GT5-Unofficial checkout>`;
  missing item icons from `tools/gen_icons.py`, missing names from `tools/gen_locale.py`.
- **Test every change** with the headless harness: `python tools/devcheck/devcheck.py setup` once
  (needs network access to factorio.com and FACTORIO_USERNAME/FACTORIO_TOKEN for the dependency
  mods), then `python tools/devcheck/devcheck.py all`. It must end with `RESULT: OK`. For changes
  that could affect existing saves also run `migrate --from-ref 0e935ba` (upstream 0.1.9) or `--from-ref <previous release tag>`. See
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
  so pulling into it makes changes live after a Factorio restart.
