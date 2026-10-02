# Notes for AI agents

- **Language:** everything that ends up on GitHub is English (code, comments, log messages,
  locale, commits, PRs, issues, docs). Chat with the maintainer may be in German.
- Read `CONTRIBUTING.md` and the layout table in `README.md` first.
- Upstream content lives in `prototypes/0*-*.lua` … `98-technology.lua`; keep changes there
  minimal. Fork logic lives in `prototypes/1xx-fork-*.lua`, loaded at the end of `data.lua`
  in this order: 100 fixes, 101 machines, 102 resources, 103 QoL techs (re-gates the vanilla inserter, belt and
  worker robot techs of issue #29 onto Gregtorio techs, GT recipes for bulk/stack inserters and express/turbo belts), 110 LuV, 120 AE2 (ME network since issue #68: cables,
  controller, drives with cells, interface, buses, storage bus, terminal; the old logistic-network prototypes stay
  hidden for saves; runtime in `scripts/fork-me-network.lua`, `fork-me-io.lua`, `fork-me-storagebus.lua`, `fork-me-fluid-storagebus.lua`,
  `fork-me-migrate.lua`, design record
  `docs/ME-REWORK.md`),
  121 AE2 autocrafting (pattern provider with 9 slots for encoded patterns, blank and encoded pattern items (issue #80),
  molecular assembler, crafting CPU and its IV/LuV tiers, level maintainer, circuit interface; runtime in
  `scripts/fork-me-autocraft.lua`, `scripts/fork-me-patterns.lua` and `scripts/fork-me-circuit.lua`, guide `docs/AE2.md`,
  pattern design in `docs/ME-REWORK.md`, "Encoded patterns"), 122 AE2 fluids (fluid cells for the ME Drive, fluid interface, fluid
  buses, fluid storage bus (runtime `scripts/fork-me-fluid-storagebus.lua`: one bus per fluid segment); the old fluid drives hidden; fluids are stored by `scripts/fork-me-network.lua`, the interface in `scripts/fork-me-fluids.lua`), 125 LuV endgame (naquadah, bacterial vat, crystal processors, fusion MK1), 126 ZPM, 127 UV
  (UV circuit, ZPM assembly line, UV components, fusion MK2), 128 UHV (wetware line, tritanium,
  UHV components, fusion MK3), 129 water purification (grades 1-8, NPIC/PPIC/QPIC/FPIC/APIC chips, complex SMDs; the FPIC/APIC users in 131-134 list its techs as prerequisites),
  131 UEV (bio line, UEV components, fusion MK4), 132 UIV (optical line, UIV components),
  133 UMV (fusion MK5, spacetime, exotic line, UMV components; also the shared helpers, global
  table `FORK5B`), 134 UXV (universium, temporal line, UXV components), 135 endgame (stargate,
  MAX science pack; researching `victory` wins the game via `scripts/fork-victory.lua`), 136 power
  (plasma fuel values, plasma balance of issue #32, large plasma turbines with turbine output hatches, naquadah fuel line, large
  naquadah reactors, dynamo hatches LuV to UXV; runtime in `scripts/fork-power.lua`: fuel check, turbine output hatch),
  137 endgame materials (issues #39 and #36: deletes the drafts removed for good, `FORK-REMOVED` in the log; the
  lapotronic energy orb cluster and high density plutonium drafts; super coolant, the 1080k super coolant cell, fluxed electrum,
  bedrockium and quantium with the stand-ins they replace; must load after 136, whose plutonium fuel and dynamo hatches it changes),
  139 endgame multiblocks (phase 6a, issue #37: the dimensionally transcendent plasma forge with its catalysts and metal recipes, the
  quantum force transformer and its recipes; loads after 137 and **before** 138, which sets the unit counts of its technologies;
  phase 6b hooks are marked `6b hook`), 140 godforge (phase 6b: the godforge, raw star matter, magmatter, the stellar catalyst of the
  plasma forge, the infinite `godforge-upgrades`), 141 MAX tier (phase 6b: magmatter parts, the Planck line and MAX circuit, MAX
  components, hatches, machines and turbine; needs 140's magmatter and adds its turbine to 136's mod data); 140 and 141 load after
  139 and **before** 138, 138 research balance (issue #30: explicit unit counts of the technologies from UV to `victory`; loads after every file that
  defines technologies; balance passes use `tools/balance_model.py` on `devcheck.py check --balance-out`),
  150 molds (mold slot instead of mold ingredient; must load after every file that creates
  machines), 190 manual-labor
  burner usage (fist icon in the fuel slot), 198 crafting menu (shows machine recipes, which upstream
  `create_recipe` hides; a recipe that must stay hidden goes into its allow-list
  `FORK_CRAFTING_MENU_HIDDEN`, devcheck fails otherwise; startup setting in `settings.lua`), 199 finalize.
  The phase plan is in `docs/ROADMAP.md`.
  Runtime fork code lives in `scripts/` and is required from `control.lua` (`fork-me-network.lua`, `fork-me-io.lua`,
  `fork-me-storagebus.lua`, `fork-me-fluid-storagebus.lua`, `fork-me-migrate.lua`, `fork-me-terminal.lua`, `fork-me-autocraft.lua` (with `fork-me-patterns.lua`), `fork-me-fluids.lua`, `fork-me-circuit.lua`,
  `fork-me-gui.lua`, `fork-me-windows.lua`, `fork-molds.lua`, `fork-victory.lua`, `fork-power.lua`). The ME modules use the storage API of
  `fork-me-network.lua`, never a logistic network. `fork-me-circuit.lua` registers no interval: it runs as a step hook
  of the autocrafting step (20); processing patterns catch their outputs through the network's insert functions
  (`N.on_arrival`, no tick); the fluid step and the storage bus visits (8 per step) run inside the I/O step of
  `fork-me-io.lua` (15); a storage bus is an external cell of the storage engine (`N.ext_*`), so is a fluid storage bus (8 visits per step too); the network's slow
  step (drive lights, sweep) and the refresh of open ME windows run inside the terminal step (60); the terminal
  module registers every GUI event and hands it to `fork-me-gui.lua` (`dispatch`: actions by the `fork_me_act` tag;
  one window style, the block windows are in `fork-me-windows.lua`, issue #68 R3); `control.lua` registers the build and removal events
  of all ME modules (the graph first on build, last on removal).
  Tick intervals in use: `on_nth_tick` 60 (ME terminal), 30 (molds), 20 (autocrafting), 15 (ME I/O and fluids);
  `on_tick` (fork-power: turbine energy every tick, fuel check and output hatches every 10th tick);
  registrations for the same interval (or a second `on_tick`) overwrite each other, so a new periodic
  task picks a free interval. `on_init` belongs to the ME terminal, so other scripts keep their state
  lazy (`storage.fork_ae2`, `storage.fork_me_fluids`, `storage.fork_me_net`, `storage.fork_me_io`, `storage.fork_me_sbus`, `storage.fork_me_fsbus`,
  `storage.fork_molds`,
  `storage.fork_power`); `on_configuration_changed` rebuilds the ME graph first, then runs the ME migration.
- `data-final-fixes.lua` disables vanilla techs (`disable_tech`: hidden, no effects). The main menu simulations that call
  `research_all_technologies()` get the bonuses of those techs from `prototypes/fork-menu-simulations.lua` (PR #65: the
  laser defense simulation's character died without them and its script stopped the menu); after changing the disabled
  techs or the character, run `python tools/devcheck/devcheck.py menusim --sim all --compare`.
- Generators (`generator` prototypes that burn fluids by fuel value, 136) are demand driven; an
  input-output fluid box keeps part of its fluid in the pipeline segment (`get_fluid_count` reports
  only the entity's part, `fluidbox.get_fluid_segment_contents` the rest), so tests count both.
- `199-fork-finalize.lua` hides draft recipes with missing parts (`FORK-DRAFT` in the log) and
  auto-unlocks intermediates (`FORK-AUTOUNLOCK`). Check the log after changes.
- New machines one tier up: `fork_make_tier_machine(base, from_tier, to_tier, frames, tech)`.
  Their sprites/icons come from `tools/gen_sprites.py --gt <GT5-Unofficial checkout>`;
  missing item icons from `tools/gen_icons.py` (a placeholder; the real icon from GT textures with
  `tools/gen_gt_icons.py` after adding the item to `tools/gt-icon-items.txt`), technology icons from
  `tools/gen_tech_icons.py` (`tools/tech-icons.tsv`), missing names from `tools/gen_locale.py`.
  Check graphics changes with the contact sheets of `tools/gen_review_sheet.py`.
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
