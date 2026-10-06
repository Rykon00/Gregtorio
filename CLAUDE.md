# Notes for AI agents

- **Language:** everything that ends up on GitHub is English (code, comments, log messages,
  locale, commits, PRs, issues, docs). Chat with the maintainer may be in German.
- Read `CONTRIBUTING.md` and the layout table in `README.md` first.
- Upstream content lives in `prototypes/0*-*.lua` … `98-technology.lua`; keep changes there
  minimal. Fork logic lives in `prototypes/1xx-fork-*.lua`, loaded at the end of `data.lua`
  in this order: 100 fixes, 101 machines, 102 resources, 103 QoL techs (re-gates the vanilla inserter, belt and
  worker robot techs of issue #29 onto Gregtorio techs, GT recipes for bulk/stack inserters and express/turbo belts), 110 LuV, 120 the ME network on Gregtorio's tiers (issue #83: the ME network is the mod
  **me-network**, https://github.com/Rykon00/me-network, a dependency; `prototypes/120-fork-me-network-compat.lua` gives
  its items Gregtorio's GT recipes and its nine technologies Gregtorio's tiers through me-network's data-stage API
  `ME_NETWORK`, and builds the molecular assembler from the HV assembler; the ME items of the upstream file 13 are
  me-network's, their recipes are in the compat file; plan and record: `docs/SPLIT.md`), 125 LuV endgame (naquadah, bacterial vat, crystal processors, fusion MK1), 126 ZPM, 127 UV
  (UV circuit, ZPM assembly line, UV components, fusion MK2), 128 UHV (wetware line, tritanium,
  UHV components, fusion MK3), 129 water purification (grades 1-8, NPIC/PPIC/QPIC/FPIC/APIC chips, complex SMDs; the FPIC/APIC users in 131-134 list its techs as prerequisites),
  131 UEV (bio line, UEV components, fusion MK4), 132 UIV (optical line, UIV components),
  133 UMV (fusion MK5, spacetime, exotic line, UMV components; also the shared helpers, global
  table `FORK5B`), 134 UXV (universium, temporal line, UXV components), 135 endgame (stargate,
  MAX science pack; researching `victory` wins the game via `scripts/fork-victory.lua`), 136 power
  (plasma fuel values, plasma balance of issue #32, large plasma turbines with turbine output hatches, naquadah fuel line, large
  naquadah reactors, dynamo hatches LuV to UXV; runtime in `scripts/fork-power.lua`: fuel check, turbine output hatch
  with a ratio per fluid and the generator's effectivity from the mod data, used by 145's steam turbines, and the passive
  loss of 145's supercapacitors, mod data `capacitors`, and the carry-over of their energy when another tier replaces them, issue #124),
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
  147 GT routes (issue #98: the PECA board deleted, sodium persulfate, black plutonium and cosmic neutronium through the
  blast furnace and vacuum freezer, the high octane line, GT's deuterium and PPIC wafer; loads after 138 and **before** 142,
  whose block `UNLOCKS_98` unlocks its recipes, and 143, which casts the black plutonium ingot),
  146 platinum line (issue #96: GTNH's bartworks line instead of upstream's GTCEu line of 19, platinum, palladium and the
  rhodium, ruthenium, osmium and iridium branches, the direct platinum and palladium dust recipes turned into metallic powder; loads after 147 and before 142, block `UNLOCKS_96`; old saves map
  the removed intermediates with the JSON migrations of `migrations/`),
  142 recipe unlocks (issue #91: every Gregtorio recipe gets a technology from its explicit table `UNLOCKS`, the
  producers GT has and Gregtorio lacked, the component assembly line and the ender tanks; a recipe that must stay
  locked goes into the allow-list `FORK_RECIPES_LOCKED` with its reason, devcheck fails otherwise; `KEEP` pins what
  the auto-unlock of 199 placed before, so new unlocks do not move it), 143 casting (issue #91: solidifier casts of every
  form and extractor melts of every ingot from its table `MATERIALS` (tier, technology, the colour of a new melt);
  199's auto-unlock ignores these recipes (`FORK_CASTING.recipes`), else an ingot would count as its own producer;
  must load before 150, whose molds it needs, and before 196, 198 and 199), 145 power multiblocks (issue #97: the large
  steam turbine and the high pressure steam turbine as generators of 136 with superheated steam, the fluid nuclear reactor
  (burner recipe machine for the fuel rods) and the large heat exchanger with coolant and hot coolant, the lapotronic
  supercapacitor as an accumulator per capacitor tier (IV, LuV and ZPM upgrades); their technologies are
  named in 142's `UNLOCKS`, so it loads after 138 and **before** 142, and before 196 for its fluids; it takes 136's
  generator from the global `FORK_POWER` and adds to its mod data `fork-power`), 144 dead fluids (issue #91: GT's uses and
  producers of fluids nothing made or used; the blast furnace gas variants of `EBF_GASES` are in `FORK_GAS_VARIANTS`,
  which 199's auto-unlock ignores like the casts), 148 GTNH table items (issue #126: GTNH's machine recipes for the anvil, the firebrick block and paper, which the crafting table made; the reachable hand-only vanilla recipes (firearm magazine, light armor, rail ramp and support, wood processing) moved into `crafting-or-assembling-recipes`; the allow-list `FORK_RECIPES_TABLE_ONLY` of recipes of items that only the crafting table, the ME Molecular Assembler or the hand make, each with its reason; devcheck fails for a reachable item whose every recipe is such a recipe and not in it; loads after 144 and before 150), 149 early research (issue #127: the unit counts of the technologies with red and green packs only, 80 and more, cut to a quarter; the cheap research setting wins), 150 molds (mold slot instead of mold ingredient; must load after every file that creates
  machines), 190 manual-labor
  burner usage (fist icon in the fuel slot), 191 burner fire (issue #137: the fire animations of the stone and iron furnace and the small coal boiler, drawn only while they work; `tools/gen_fire_sprites.py`), 195 microminer tab (issue #120: the Microverse Projectors as the first row of the Microminer tab, one row per tier t1 to t4 with its microminer, data, mission and ender tank, empty rows deleted; devcheck fails for a projector recipe outside the tab), 196 subgroups (the Fluids tab: every Gregtorio fluid gets a row of the item
  group `fluids` by its explicit table or a name pattern; a new fluid goes into one, the fallback row
  `gregtorio-fluids-unsorted` is a devcheck warning; issue #119: Gregtorio icons for molten iron, molten copper and steam, the twelve unused vanilla fluids hidden (`FORK_FLUIDS_HIDDEN`); a fluid that keeps another mod's icon on purpose goes into `FORK_FLUID_ICONS_KEPT`, devcheck warns otherwise; loads after every file that creates fluids), 197 fluid steps (issue #117: every fluid amount of a recipe that is not a multiple of the engine's step 2^-24 is set on the grid, takes up, gives up and nine steps more, so n melted ingots cover every cast they are worth; loads after every file that makes or changes a recipe; devcheck fails for an amount off the grid), 198 crafting menu (shows machine recipes, which upstream
  `create_recipe` hides; a recipe that must stay hidden goes into its allow-list
  `FORK_CRAFTING_MENU_HIDDEN`, devcheck fails otherwise; startup setting in `settings.lua`), 199 finalize, 200 material parts (issues #118 and #145: the item group "Material parts", one row per form, the materials inside a row by the tier of the technology that unlocks their ingot (its highest science pack), else of any part; items only, the recipes keep their machine rows; devcheck warns for a material with no tier; loads after 199 so the final unlocks count).
  The phase plan is in `docs/ROADMAP.md`.
  Runtime fork code lives in `scripts/` and is required from `control.lua` (`fork-molds.lua`, `fork-victory.lua`,
  `fork-power.lua`, and `fork-me-handover.lua`: the one-time hand-over of the ME state of saves from before issue #83 to
  me-network through the remote interface `gregtorio-me-handover`, which me-network calls in its `on_init`; keep its
  table list and fingerprint function equal to me-network's `scripts/fork-me-handover.lua`). Everything else of the ME
  network (runtime, graphics, locale, its tests, `docs/AE2.md`, `docs/ME-REWORK.md`) is in the me-network repository;
  an ME change goes there, Gregtorio only changes the compat file when a recipe or a tier changes.
  Tick intervals in use: `on_nth_tick` 30 (molds); `on_tick` (fork-power: turbine energy every tick, fuel check,
  output hatches and the supercapacitor loss every 10th tick); registrations for the same interval (or a second `on_tick`) overwrite each other,
  so a new periodic task picks a free interval. The scripts keep their state lazy (`storage.fork_molds`,
  `storage.fork_power`).
- `data-final-fixes.lua` disables vanilla techs (`disable_tech`: hidden, no effects). The main menu simulations that call
  `research_all_technologies()` get the bonuses of those techs from `prototypes/fork-menu-simulations.lua` (PR #65: the
  laser defense simulation's character died without them and its script stopped the menu); after changing the disabled
  techs or the character, run `python tools/devcheck/devcheck.py menusim --sim all --compare`.
- Cheap research: the startup setting `gregtorio-continued-one-pack-research` (default off) makes every technology with
  science packs cost one research unit with one pack of each kind (`prototypes/fork-one-pack-research.lua`, required last
  in `data-final-fixes.lua`, after everything that sets unit counts). `devcheck.py all` loads the mod a second time with
  it on; `devcheck.py check --set <setting>=true|false` forces any bool startup setting for a run.
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
- **Machine names are GTNH's** (issue #156): a new machine, multiblock or controller takes the name GT New Horizons
  gives it, from the `en_US.lang` files of GT5-Unofficial (`src/main/resources/assets/*/lang/en_US.lang`, or the name
  in `gregtech/loaders/preload/LoaderMetaTileEntities.java`), not GregTech CEu's and not the one `tools/gen_locale.py`
  derives from the ID: overwrite the generated entry. Gregtorio's tier prefix stays ("LV Ore Washing Plant",
  "Industrial Mixing Machine (IV)"); GTNH's "Basic / Advanced / Elite" prefixes are not used. Prototype names keep
  the old IDs (`<tier>-ore-washer`, `godforge`): saves find them by name, so a rename changes the locale only.
- **Test every change** with the headless harness: `python tools/devcheck/devcheck.py setup` once
  (needs network access to factorio.com and FACTORIO_USERNAME/FACTORIO_TOKEN for the dependency
  mods; me-network is taken from a checkout next to this one, `../me-network`, or `ME_NETWORK_DIR`, else its portal zip),
  then `python tools/devcheck/devcheck.py all`. It must end with `RESULT: OK`. For changes
  that could affect existing saves also run `migrate --from-ref 0e935ba` (upstream 0.1.9) or `--from-ref <previous release tag>`
  (`--from-ref v0.5.0` needs `--old-me-network v0.1.0`: the old save is made with the me-network of its time, with a later
  one the helper mod's `on_init` fails and devcheck stops with `the map was not saved`). See
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
