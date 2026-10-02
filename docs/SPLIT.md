# Splitting the ME network into its own mod (issue #83)

The ME network (issues #68, #38, #80: cables, controller, drives with cells, interface, buses, storage buses,
terminal, autocrafting, fluids) moves out of Gregtorio Continued into its own mod **`me-network`** ("ME Network",
https://github.com/Rykon00/me-network), which `gregtorio-continued` depends on. This is the plan, the record of
the checks made before anything moved (sections 1 to 6), and the record of the split itself (section 7).

Decided in the issue: mod name `me-network`, title "ME Network", author rykon_, GPLv3, first version 0.1.0,
Factorio 2.0, described as "inspired by Applied Energistics 2". **Every prototype name stays** (entities, items,
recipes, technologies, fluids, item subgroups, mod-data, custom inputs): saves find them by name. `me-network`
works on its own (vanilla recipes, its own technologies on vanilla science); Gregtorio overrides the recipes with
its GT ones and puts the technologies back on its tiers in one compat file, so a Gregtorio game is what it is today.
After the split Gregtorio contains no ME code except that compat file and the one-time state hand-over.

## 1. Inventory

Measured, not guessed: the prototypes that `prototypes/120-122` add or change were listed by instrumenting
`data.lua` (a snapshot of `data.raw` before 120 and after 122): 126 new prototypes, 6 changed upstream items with
their recipes (`fluix-cable`, `me-chest`, `me-controller`, `me-drive`, `me-interface`, `me-terminal`) and one changed
Gregtorio technology (`logistic-system`, which unlocks `me-chest` and `me-drive`). The files after 122 change ME
prototypes only through the generic passes (198 shows the recipes in the crafting menu, `hide_from_player_crafting`).

### What moves to me-network

| Part | Contents |
|---|---|
| `prototypes/120-fork-ae2.lua` | cable, underground cable, controller, drive, interface, import/export/storage bus, terminal, item cells, the hidden old prototypes of 0.3.2 (roboport controller, logistic chest drives, requester interface, old drive items), subgroups `fork-me-network`, `fork-me-drives`, `fork-me-cells`, custom input `fork-me-terminal-open`, mod-data `fork-me-network`, technologies `me-network`, `me-storage-64k`, `me-storage-256k` |
| `prototypes/121-fork-ae2-autocrafting.lua` | pattern provider, blank and encoded pattern, molecular assembler, crafting CPU and its two tiers, level maintainer, circuit interface, mod-data `fork-me-autocraft`, technologies `me-autocrafting`, `me-automation`, `me-co-processing`, `me-quantum-crafting` |
| `prototypes/122-fork-ae2-fluids.lua` | fluid cells, the hidden old fluid drives (items and entities), fluid interface, fluid import/export/storage bus, subgroups `fork-me-fluid-cells`, `fork-me-fluid-drives`, mod-data `fork-me-fluids`, technologies `me-fluid-storage`, `me-fluid-storage-256k` |
| ME items of the upstream file `prototypes/13-mv-age-item.lua` | the items `fluix-cable` (places the ME cable), `me-controller`, `me-interface`, `me-terminal`, `me-chest`, `me-drive`, `me-1k`…`me-256k-storage-component`, `basic-storage-housing` (their GT recipes stay in Gregtorio, see the compat file) |
| `scripts/fork-me-*.lua` (12 files, about 11 000 lines) | network, io, storagebus, fluid-storagebus, migrate, terminal, gui, windows, autocraft, patterns, fluids, circuit |
| `control.lua` (ME part) | the requires, the blueprint hooks, the build, clone, settings paste, blueprint setup, removal (with the event filter), rotation events, the ME part of `on_configuration_changed`; `on_init` (today the terminal's) |
| graphics (117 files referenced by the moved prototypes) | `graphics/entity/fork/ae2/` (58), `graphics/icons/fork/me-*` (38), `graphics/icons/me-*.png`, `fluix-cable.png`, `basic-storage-housing.png` (12, plus the five unused `me-*m-storage-component.png` of upstream), `graphics/technology/fork/me-*.png` (9). No file is shared with a prototype that stays (the only other users are the `*-recycling` recipes the quality mod makes for these items) |
| locale | `locale/en/fork-ae2.cfg`; the item names of the moved upstream items from `locale.cfg` (the recipe names `me-1k-storage-component-lv`/`-nand` stay: those recipes stay in Gregtorio) |
| docs | `docs/AE2.md`, `docs/ME-REWORK.md` |
| tools | `tools/gen_ae2_sprites.py`; the ME tests of `tools/devcheck/runtimemod` (graph, cells, terminal, io, autocrafting, furnace pattern, pattern switching, processing line, fluids, fluid cells, R3, storage bus, fluid storage bus, the issue #38 tests: about 3 300 of its 4 235 lines) |

### What stays in Gregtorio (GregTech materials and Gregtorio content)

Certus and nether quartz and their processing, charged certus quartz, fluix crystal/dust/seed/block, pure crystals,
the inscriber presses, printed circuits, logic/calculation/engineering processors, annihilation and formation cores,
certus and nether quartz rods/bolts/screws, quartz fiber, `computer-monitor` (also used by an IV machine), the
advanced and acceleration cards. They are made in GT machines and are ingredients of the GT recipes of the ME
blocks; the ME network has no function for them. The technologies `applied-energistics-crystals` and
`applied-energistics-components` stay (upstream techs that unlock GT materials and, by name, the cable, controller
and interface). The logistic chest recipes that use ME items (`requester-chest`, `storage-chest`, …), `roboport-mk1`,
`overworld-data` and the microverse data recipes stay (Gregtorio recipes that use ME items as ingredients).

The rule: an item moves when the ME network needs it to exist (it is placed, goes into a slot, or is the cell or
pattern itself) or it is part of the ME crafting chain that a standalone game needs (storage components and housing:
cell = component + housing as in AE2). Materials that GregTech processing makes stay.

## 2. Coupling and how each one is replaced

### ME code that uses Gregtorio

| Use | Where | Replacement |
|---|---|---|
| `create_item`, `create_recipe`, `ICON_PATH` | 120-122 | me-network's own local helpers; icons `__me-network__/` with the same relative paths |
| `LV_SPEED` … `LUV_SPEED`, `MV_SPEED`, `EU12_HV`, `SP01`…`SP07` | recipe times, the assembler's power, technology units | standalone values in me-network; the GT values only in the compat file |
| `fork_add_unlock("logistic-system", ...)` | 120 | compat file |
| GT items in ME recipes (hulls, emitters, pistons, pumps, processors, cores, cards, GT circuits, aluminium plate, certus quartz, …) | 120-122 and the upstream recipes in 13 | standalone recipes from vanilla items; the compat file puts the GT recipes back (exactly today's) |
| GT recipe categories (`lv-assembling-machine-recipes`, …) | every ME recipe | vanilla `crafting` / `advanced-crafting` standalone; compat |
| GT technologies as prerequisites (`logistic-system` in Gregtorio's tree, `nanoprocessors`, `advanced-hv-machines`, `industrial-precision-lathe`, `ev-machines`, `iv-components`, `luv-machines`, `circuit-network`) and GT recipes unlocked by ME techs (`me-storage-256k` unlocks the cards and the fiber-reinforced board chain) | 120, 121 | standalone prerequisites on vanilla techs; compat sets prerequisites, units and effects of all nine ME technologies to today's |
| Molecular assembler = copy of `hv-assembling-machine` with the LV-EV assembling categories, 6x speed, `EU12_HV` | 121 | API `make_molecular_assembler{ base, crafting_categories, crafting_speed, energy_usage }`; standalone from `assembling-machine-2` with the vanilla item categories; the compat calls it with today's values (the same code builds the entity, so it is identical) |
| subgroups of the components and the housing (`subgroup-*-recipes` of Gregtorio's item groups) | 13 | standalone: in `fork-me-cells`; compat moves them back |
| 198 crafting menu allow-list | none: no ME recipe is in `FORK_CRAFTING_MENU_HIDDEN`; 198 runs over every recipe after the compat file, so it treats the ME recipes as today |
| 199 finalize (draft guard, auto-unlock) | none: it runs over everything after the compat file |
| 150 molds, 101 tier machines | none: the snapshot shows no change to an ME prototype after 122 except the 198 pass; the molecular assembler gets no mold slot |
| runtime: Gregtorio names in `scripts/fork-me-*.lua` | none (checked: no GT item, category, setting or remote call; only the old drive item's extra `acceleration-card`, which is mod-data) | the runtime gives the extra item only if the prototype exists |
| step intervals (15, 20, 60 in use by ME; 30 by molds; `on_tick` by fork-power) | handlers are per mod | no conflict any more; me-network keeps 15/20/60 |
| `on_init` "belongs to the ME terminal" | control.lua | me-network has its own `on_init`; Gregtorio needs none |

### Gregtorio code that uses ME things

| Use | Replacement |
|---|---|
| upstream technologies unlock ME recipes by name (`applied-energistics-components`: cable, controller, interface; storage components in 4 techs; `basic-storage-housing`) | unchanged: the recipes keep their names (defined by the compat file) |
| ME items as ingredients (`roboport-mk1`, logistic chests, `storage-chest`, `overworld-data`, microverse data, an MV entity) | unchanged: the items exist through the dependency |
| `137-fork-endgame-materials.lua`: `me-storage-256k` is a prerequisite | unchanged: the technology keeps its name |
| devcheck uses the ME remote interfaces (`gregtorio-me-network`, …) | unchanged: me-network keeps the interface names (other mods and the tests use them) |

### The public data-stage API of me-network

A global table `ME_NETWORK` (me-network's `data.lua`, documented in its `docs/API.md`), for Gregtorio and any other
mod that depends on me-network:

- `ME_NETWORK.recipes`, `ME_NETWORK.technologies`: the names me-network owns.
- `ME_NETWORK.replace_recipe(def)`: replaces a recipe by a full definition (same name), keeps the technologies
  that unlock it.
- `ME_NETWORK.remove_recipe(name)`: deletes a recipe and its unlocks (Gregtorio uses it for the standalone
  `me-1k-storage-component` recipe; it has `me-1k-storage-component-lv` and `-nand` instead).
- `ME_NETWORK.set_technology(name, { prerequisites, unit, recipes })`: replaces those fields (unlocks by recipe name).
- `ME_NETWORK.make_molecular_assembler{ base, crafting_categories, crafting_speed, energy_usage }`: rebuilds the
  molecular assembler from another assembling machine.

At runtime the existing remote interfaces stay as they are (`gregtorio-me-network`, `-io`, `-storagebus`,
`-fluid-storagebus`, `-migrate`, `-terminal`, `-gui`, `-autocraft`, `-circuit`, `-fluids`): renaming them would break
the tests and anything that calls them, and the names are only names.

### The compat file in Gregtorio

`prototypes/120-fork-me-network-compat.lua` (loaded where 120-122 were): the GT recipes of every ME item (the
create_item/create_recipe calls of 13 and 120-122 as they are today, recipe only), the subgroups of the components
and the housing, the removal of the standalone 1k component recipe, the nine technologies with today's
prerequisites, units and unlocks, `logistic-system` unlocking `me-chest` and `me-drive`, and the molecular
assembler from `hv-assembling-machine`. The ME item definitions are removed from the upstream file
`13-mv-age-item.lua` (otherwise Gregtorio, loading after me-network, would overwrite the items).

**Proof that nothing changes:** a full dump of every prototype (`serpent` of each `data.raw` entry, both
`__gregtorio-continued__` and `__me-network__` normalised to one token) before the split and after it with both mods
loaded must be identical; every other difference is listed and explained in the split pull request.

## 3. The state hand-over

Script state is kept per mod. Today it lives in `gregtorio-continued`'s `storage`:

| Table | Contents |
|---|---|
| `fork_me_net` | graph (nodes with their entities, networks), drives with their cells and contents, external cells, the drives' light ids |
| `fork_me_io` | ME interfaces and buses |
| `fork_me_sbus`, `fork_me_fsbus` | storage buses, fluid storage buses (claims, cached looks) |
| `fork_ae2` | providers with their patterns, CPUs, jobs (pools of items and fluids in flight), level maintainers, circuit interfaces, pattern index |
| `fork_me_fluids` | fluid interfaces (and in 0.3.2 saves the old fluid drives' contents) |
| `fork_me_terminal` | per player: the terminal's entity, filter, sort, kind, crafting and pattern editor fields |
| `fork_me_gui_bypass` | per player: a block whose engine window is being bypassed (transient) |
| `fork_me_migrate`, `fork_me_migrate_fluids` | reports of the migrations of old networks (read by the tests) |

### Mechanism

- Gregtorio (new version) has a remote interface `gregtorio-me-handover` with `take()`: it returns those ten tables
  in **one** table, sets them to `nil` in its storage, closes its own ME windows (GUI elements belong to the mod that
  made them) and destroys its render objects (only the ME code draws any: the drive lights).
- me-network pulls in its `on_init` (it is a new mod in such a save): if the interface exists and has state, it takes
  the tables into its own `storage`, then initialises as today. me-network's `on_configuration_changed` then runs
  exactly what Gregtorio's does today for the ME part (graph rebuild, migrations of old networks, the modules).
- The tables, the keys and the code that reads them stay the same, so nothing has to be converted.
- Gregtorio sends a fingerprint of each table with it and logs it (`FORK-ME-HANDOVER: gave`); me-network computes
  the fingerprint of what it got (`ME-NETWORK-HANDOVER: got`), compares and logs `ok` or `MISMATCH`: an
  order-independent walk of the table with entities as their unit numbers and shared tables as references.
  `devcheck migrate` fails on a mismatch.

### Verified headless (Factorio 2.0.77): `devcheck.py handover`

Two stand-in mods in `tools/devcheck/handover/`: the giver (gregtorio-continued) in version 1 builds ME-like state
on a new map and saves it; version 2 depends on the taker and has only `take()`; the taker (me-network) is added in
the same load, defines the prototypes that move, and pulls in `on_init`. The result:

1. **Order** when me-network is added and Gregtorio is updated in the same load:
   `taker on_init` → `giver on_load` → `taker on_configuration_changed` → `giver on_configuration_changed`.
   The new mod's `on_init` runs before the old mod's `on_load`, and `on_configuration_changed` runs in load order
   (the dependency first). So me-network has the state before its own `on_configuration_changed`, and Gregtorio's
   `take()` must not depend on anything its `on_load` sets up (it only reads `storage`, which is loaded).
2. **What survives the remote call:** entity references (valid, same unit numbers, also of a prototype whose
   owning mod changed: the save finds it by name), a table shared by two tables stays one table (also across two
   top-level tables of the same call: so all tables go in one call), fractional numbers, item-with-tags data of a
   moved item prototype (tags and custom description) in a moved entity and in a vanilla chest.
3. **Render objects** of the giver are visible to the taker by id and can be destroyed by it. Gregtorio destroys
   its own anyway; me-network redraws the lights of every drive.
4. **Guards:** the old giver with the taker is refused at load (the taker's data stage finds the old giver's
   mod-data); the new giver without the taker is refused by the engine ("Missing required dependency").
5. **A broken hand-over is noticed:** with one table left out the taker's check fails.

### Who rebuilds what

| | after the hand-over |
|---|---|
| ME graph (nodes, networks) | rebuilt from the map by me-network (`on_init`, then `on_configuration_changed`, the only map scans, as on every update today); drive records with their cells are kept |
| pattern index | rebuilt by the autocrafting module's `on_configuration_changed` (marked dirty) |
| drive lights (render objects) | Gregtorio destroys its own in `take()`; me-network redraws every drive's lights |
| windows | closed by Gregtorio in `take()` (players open them again) |
| jobs, CPUs, maintainers, interface and bus settings, cell contents, patterns | kept as they are (handed over) |

### Cases

- **Gregtorio updated without me-network:** the hard dependency `me-network >= 0.1.0` stops the load; the game's
  mod manager offers to download it. Gregtorio's state stays untouched until me-network is there.
- **me-network added to a save with an old Gregtorio (< 0.5.0) first:** both define the ME prototypes and run the ME
  scripts. me-network's `data.lua` refuses to load if the mod-data `fork-me-network` already exists (only an old
  Gregtorio, which loads first without the dependency, defines it): "Gregtorio Continued before 0.5.0 contains its
  own ME network. Update Gregtorio Continued." Verified with the stand-ins.
- **A save of a me-network-only game gets Gregtorio:** `take()` has nothing; the compat file switches the recipes and
  technologies to the GT ones (`reset_technology_effects` in both mods' `on_configuration_changed`).
- **Gregtorio removed later, me-network kept:** the network keeps working on its own state (vanilla recipes).
- **Both mods have state** (cannot happen through the paths above): me-network keeps its own, does not merge, and
  logs it.
- **0.3.2 saves (logistic ME network):** the old tables are handed over like the new ones and me-network's
  `on_configuration_changed` runs both migration steps exactly as Gregtorio does today (`migrate --from-ref v0.3.2`).

## 4. Infrastructure

### Repository me-network

```
info.json            name me-network, title "ME Network", version 0.1.0, author rykon_, factorio_version 2.0,
                     dependencies: base >= 2.0, ? quality, ? space-age (load after them, as Gregtorio did, so the
                     copied vanilla prototypes are the same)
changelog.txt        Version: 0.1.0 (no Date)
README.md, LICENSE (GPLv3; the GT texture notice, LGPL-3.0, kept), CONTRIBUTING.md, CLAUDE.md, thumbnail.png
data.lua, control.lua
prototypes/          network.lua (120), autocrafting.lua (121), fluids.lua (122), each with its standalone recipes and
                     technologies next to the items; api.lua (ME_NETWORK)
scripts/             fork-me-*.lua (names kept: they require each other; renaming can follow)
graphics/            the same relative paths as in Gregtorio
locale/en/me-network.cfg
docs/                AE2.md, ME-REWORK.md (moved), API.md
tools/               build.py, check_syntax.py, dev_link.py, gen_ae2_sprites.py, devcheck/
.github/workflows/release.yml   like Gregtorio's: syntax check and zip on every push and PR, main -> upstream/release
                     releases (GitHub release + mod portal upload with the secret FACTORIO_MOD_API_KEY)
```

History: the moved files keep their history with `git filter-repo` on a copy of the Gregtorio clone (only the
moved paths; issue references in the messages rewritten to `Rykon00/Gregtorio#N`), then the restructuring commits
on top. If that is not practical, the first commit says where the files come from (Gregtorio at the merge commit
of this split) and credits the origin.

### Tests

- **me-network devcheck** (`tools/devcheck/devcheck.py` of me-network): `check` (loads, every unlocked recipe
  craftable in vanilla, missing files, sprite sizes) and `runtime` (all ME runtime tests), on vanilla and with
  `--with-gregtorio DIR` (a Gregtorio checkout as sibling mod: the same tests on the GT recipes and machines). The
  tests name a few GT machines and recipes (a macerator as pattern machine, HV chemical reactors and an EV extractor
  with fluid recipes, the GT gear recipe, an iron furnace with a dust recipe); without Gregtorio the test mod adds
  stand-ins with the same names, numbers, sizes and fluid boxes (test fixtures, not part of the mod), so the same
  test code runs in both.
- **Gregtorio devcheck:** `check` and `runtime` keep the GT tests (molds, power, fuel check, cooled fluid, turbine
  tiers, recipes, victory); `migrate` keeps the migration of old Gregtorio saves (the ME parts of `migratemod`
  stay: they test Gregtorio saves) and checks the hand-over fingerprints. It gets me-network as a sibling checkout
  (`../me-network`, or `--me-network DIR`, or `ME_NETWORK_DIR`), otherwise the `me-network_*.zip` that `setup`
  downloads from the portal like the other dependencies. The old version of a `migrate` run is loaded without
  me-network (it did not depend on it), the working copy with it.
- `devcheck.py handover` (this pull request) stays as the record of the engine behaviour above.

## 5. Release order and versions

- me-network **0.1.0** must be on the mod portal before the Gregtorio release that depends on it.
- Gregtorio: `info.json` gets `"me-network >= 0.1.0"`; the split lands in **0.5.0** (the topmost changelog section,
  together with the encoded patterns of issue #80).

Steps for the maintainer, in this order:

1. Merge the me-network pull request into its `main`.
2. me-network release PR `main` → `upstream/release` (version 0.1.0 with its `Date:`). Merging it creates the GitHub
   release v0.1.0 with the zip. **Do not add the secret yet**: the portal API cannot create a new mod, the upload
   step would fail (without the secret it is skipped).
3. Upload that zip by hand on https://mods.factorio.com (new mod `me-network`), set the thumbnail and description.
4. Add the repository secret `FACTORIO_MOD_API_KEY` to Rykon00/me-network (later releases upload themselves).
5. Merge the Gregtorio split pull request; then the Gregtorio release PR 0.5.0 as usual.
6. Local play: link me-network into the mods folder too (`python tools/dev_link.py` in the me-network clone);
   Gregtorio does not load without it.

## 6. Verification of the split (step 2)

- Prototype dump before/after with both mods (only the owning mod may differ; every other difference explained).
- me-network standalone: `devcheck.py all` (vanilla); with Gregtorio: `devcheck.py all --with-gregtorio`.
- Gregtorio + me-network: `devcheck.py all` with `RESULT: OK`, `FORK-DRAFT` 0, `FORK-AUTOUNLOCK` and the
  technology list compared with today (only moves).
- Migration: saves of v0.4.1 (last release) and of `main` before the split with an ME network (items and fluids in
  cells, a storage bus and a fluid storage bus, patterns in providers, a running job, a level maintainer, interface
  and bus settings, an underground cable pair) loaded with the new Gregtorio + me-network: totals equal before and
  after, the job finishes, the settings are kept, the hand-over fingerprints equal. `migrate --from-ref v0.3.2`
  (logistic ME network) still converts in two steps.
- The hand-over broken on purpose once (one table left out): the migrate test must fail.

No blocker was found: the engine runs the new mod's `on_init` first, a remote call keeps everything the ME state
holds, the portal name `me-network` is free (checked 2026-10-02), and every coupling has a replacement above.

## 7. The split (record)

Done in Rykon00/me-network (0.1.0) and in this repository (0.5.0). Measured with Factorio 2.0.77, headless.

### What moved, what stayed

As planned in sections 1 and 2. me-network got the history of the moved files (`git filter-repo` over the moved
paths, 128 commits, issue references rewritten to `Rykon00/Gregtorio#N`) and, on top, the restructuring: renamed
prototype files, `info.json`, `data.lua` (the guard), `control.lua`, `prototypes/api.lua`, the standalone recipes and
technologies next to the items, the receiving side of the hand-over, its devcheck, docs and release workflow.
Gregtorio keeps `prototypes/120-fork-me-network-compat.lua`, `scripts/fork-me-handover.lua`, the recipe names
`me-1k-storage-component-lv` and `-nand` in its locale, and the GT materials of section 1.

### Prototype dump: no difference

Every prototype (`serpent` of each `data.raw` entry, 15 664 of them) of `main` before the split (f08fafd) and of
this branch with me-network: **byte-identical** after `__gregtorio-continued__` and `__me-network__` are normalised
to one token. There is no other difference to explain: the same recipes (ingredients, categories, times, subgroups,
`hide_from_player_crafting`, `auto_recycle`), technologies (prerequisites, units, unlocks, icons), entities, items
(stack sizes, subgroups, orders, types), fluids, mod-data and custom inputs. Every one of the 7 641 referenced files
exists in the mod its path names (7 443 `__gregtorio-continued__/`, 198 `__me-network__/`). The log lines of 199 are
the same: `FORK-AUTOUNLOCK` 54 lines, identical (none involves an ME recipe), `FORK-DRAFT` hides 0 recipes (its 4
lines create subgroups), `FORK-REMOVED` 35, identical. The technology list is unchanged: the nine ME technologies
are made by me-network and given Gregtorio's prerequisites, science and unlocks by the compat file, so only their
owner moved.

### Tests

| Run | Result |
|---|---|
| Gregtorio + me-network, `devcheck.py all` | RESULT: OK. Check: 385 of 404 technologies researchable (the 19 of `UNRESEARCHABLE_OK`), 0 uncraftable, 57 of 57 required recipes, 0 drafts, crafting menu 2928 shown / 241 kept / 0 unexpected (as before). Runtime: 549 machines placed, molds, power, fuel check, cooled fluid, turbine tiers, recipes, victory, post-victory ok |
| `devcheck.py handover` (the prototype of section 3) | RESULT: OK (order, survival, both guards, broken hand-over noticed) |
| `migrate --from-ref v0.4.1` (last release) | ok: patterns, job and maintainer, the hand-over network (6 kinds of items and fluids equal, settings of 7 blocks kept, drive behind the underground pair connected), fingerprints ok (7 of 10 tables with state) |
| `migrate --from-ref f08fafd` (`main` before the split) | ok: the same as v0.4.1 (encoded patterns given in the old save), fingerprints ok (7 of 10 tables) |
| `migrate --from-ref v0.3.2` (logistic-network ME) | ok: fluid drives (52 754 units kept), logistic network converted (258 items, 39 cables, 0 differences), patterns, job; fingerprints ok (3 of 10 tables), the two migration steps run in me-network |
| `menusim` (laser defense simulation) | RESULT: OK |
| me-network `devcheck.py all` (vanilla, Space Age, quality) | RESULT: OK: 38 of 38 recipes, 9 of 9 technologies, all 17 runtime tests ok on the stand-ins |
| me-network `devcheck.py check --base-only` | RESULT: OK: all 251 unlocked recipes of the base game craftable |
| me-network `devcheck.py all --with-gregtorio` | RESULT: OK: 37 of 37 recipes (the standalone 1k component recipe removed by Gregtorio), all 17 runtime tests ok on Gregtorio's machines and recipes |

The hand-over broken on purpose (`fork_me_io` left out of `take()`): `migrate --from-ref v0.4.1` fails (exit 1) on
the interface config and the import and export bus filters of the old save
(`handover: interface settings {}, before {{amount = 10, name = "iron-plate", quality = "normal"}}`, and the same for
the two buses); the fingerprints of the other tables still match, as they should.

### What to check in a real game

- An old save (0.4.1 or `main` before the split) with an ME network, loaded with this version and me-network: the
  drives' cells (open a drive, the terminal's Cells tab), the items and fluids in the terminal, patterns in the
  providers, a running job finishing, level maintainers, interface config rows and bus filters, storage buses on
  their chests and tanks, the drive lights (drawn again by me-network). The log has `ME-NETWORK-HANDOVER: ok`.
- A new game with only me-network (vanilla, with and without Space Age): research ME Network (red and green
  science), craft cables, a controller, a drive with a 1k cell and a terminal, store items; ME Autocrafting (blue):
  encode a pattern in the terminal, a provider next to an assembler, a CPU, craft through the terminal.
- me-network next to Gregtorio 0.4.1: the game refuses to load with the message of me-network's `data.lua` (checked
  headless with the 0.4.1 zip: "this version of Gregtorio Continued (before 0.5.0) contains its own ME network").

