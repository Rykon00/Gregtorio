# Notes for AI agents

- **Language:** everything that ends up on GitHub is English (code, comments, log messages,
  locale, commits, PRs, issues, docs). Chat with the maintainer may be in German.
- Read `CONTRIBUTING.md` and the layout table in `README.md` first.
- Upstream content lives in `prototypes/0*-*.lua` … `98-technology.lua`; keep changes there
  minimal. Fork logic lives in `prototypes/1xx-fork-*.lua`, loaded at the end of `data.lua`
  in this order: 100 fixes, 101 machines, 102 resources, 110 LuV, 120 AE2 (ME network),
  121 AE2 autocrafting (pattern provider, molecular assembler, crafting CPU; runtime in
  `scripts/fork-me-autocraft.lua`, guide `docs/AE2.md`), 122 AE2 fluids (fluid cells, fluid drives,
  fluid interface; runtime in `scripts/fork-me-fluids.lua`), 125 LuV endgame (naquadah, bacterial vat, crystal processors, fusion MK1), 126 ZPM, 127 UV
  (UV circuit, ZPM assembly line, UV components, fusion MK2), 128 UHV (wetware line, tritanium,
  UHV components, fusion MK3), 129 water purification (grades 1-6, NPIC/PPIC/QPIC chips),
  131 UEV (bio line, UEV components, fusion MK4), 132 UIV (optical line, UIV components),
  133 UMV (fusion MK5, spacetime, exotic line, UMV components; also the shared helpers, global
  table `FORK5B`), 134 UXV (universium, temporal line, UXV components), 135 endgame (stargate,
  MAX science pack; researching `victory` wins the game via `scripts/fork-victory.lua`),
  150 molds (mold slot instead of mold ingredient; must load after every file that creates
  machines), 190 manual-labor
  burner usage (fist icon in the fuel slot), 199 finalize.
  The phase plan is in `docs/ROADMAP.md`.
  Runtime fork code lives in `scripts/` and is required from `control.lua` (`fork-me-terminal.lua`,
  `fork-me-autocraft.lua`, `fork-me-fluids.lua`, `fork-molds.lua`, `fork-victory.lua`). Tick intervals
  in use: `on_nth_tick` 60 (ME terminal), 30 (molds), 20 (autocrafting), 15 (fluids); registrations
  for the same interval overwrite each other, so a new periodic task picks a free interval.
  `on_init` belongs to the ME terminal, so other scripts keep their state lazy (`storage.fork_ae2`,
  `storage.fork_me_fluids`, `storage.fork_molds`).
- `199-fork-finalize.lua` hides draft recipes with missing parts (`FORK-DRAFT` in the log) and
  auto-unlocks intermediates (`FORK-AUTOUNLOCK`). Check the log after changes.
- New machines one tier up: `fork_make_tier_machine(base, from_tier, to_tier, frames, tech)`.
  Their sprites/icons come from `tools/gen_sprites.py --gt <GT5-Unofficial checkout>`;
  missing item icons from `tools/gen_icons.py`, missing names from `tools/gen_locale.py`.
- **Test every change** with the headless harness: `python tools/devcheck/devcheck.py setup` once
  (needs network access to factorio.com and FACTORIO_USERNAME/FACTORIO_TOKEN for the dependency
  mods), then `python tools/devcheck/devcheck.py all`. It must end with `RESULT: OK`. For changes
  that could affect existing saves also run `migrate --from-ref 0e935ba` (upstream 0.1.9) or `--from-ref <previous release tag>`. See
  `tools/devcheck/README.md`.
- Every referenced `__Gregtorio__/...` file must exist (headless Factorio does not check
  graphics, the real game crashes on missing files).
- The mod portal version is `gregtorio-continued` (built with `tools/build.py --portal`); the repo keeps
  the internal name `Gregtorio`. Never rename it in the repo.
- The maintainer's local clone is linked into the Factorio mods folder (`tools/dev_link.py`),
  so pulling into it makes changes live after a Factorio restart.
