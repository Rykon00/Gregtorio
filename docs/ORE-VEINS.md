# Ore veins on the map (plan #494)

GT New Horizons' ore veins (`OreMixes.java` of GT5-Unofficial f2814df) are mixed ore patches on the map, and GTNH's T0
dimensions are surfaces of their own. Built in phases V0 to V9 (#495 to #505); this page has the final numbers. Since
#563 a startup setting can turn them off for the classic vein recipes ("The ore mode" below).

## Data

`tools/gen_ore_mixes.py --gt <GT5-Unofficial>` writes `prototypes/data/ore-mixes.lua`: 122 veins of 42 dimensions, with
GT's weight, density, size, the four ores (primary, secondary, between, sporadic), GT's label and the materials' names and
colours. `prototypes/165-fork-ore-veins.lua` reads it:

- `FORK_ORE_MIX_SURFACES`: the dimensions with a surface (Overworld 1, Nether 2, Twilight Forest 3, The End 4; the surface
  property `gt-dimension`).
- `FORK_ORE_MIX_SKIPPED`: left out on purpose with the reason: electrotine (Project Red), the Thaumcraft shards and the
  three Thaumcraft veins of the Twilight Forest (163's `FORK_ORE_VEINS.dropped`), the 38 dimensions from the Moon on.
- `FORK_ORE_MIX_NO_CHAIN`: oil sands (GT centrifuges the raw ore).

devcheck fails for an ore of a vein on a surface without a raw ore and its chain.

## The generator

Noise autoplace, one resource `gt-ore-<material>` per ore (category `gt-ore`, mined by hand into `raw-<material>`, 2 s).

| Setting | Value | Noise expression |
|---|---|---|
| cell size | 128 tiles / sqrt(grid frequency), at least 88 x the largest vein size of the planet | `gt_cell_base`, `gt_cell_size`, `gt_size_max` |
| cells with a vein | 75 % x grid size (at most all) | `gt_empty_share`, `gt_fill_share` |
| vein radius | 8 + 0..1 x GT's size tiles, x the vein's size slider | `gt_vein_r`, `gt_vein_scale` |
| fill | GT's chance x 3 | `gt_fill` |
| ore per tile | 1000 x grid richness x the vein's richness | `gt_ore_amount`, `gt_ore_richness`, `gt_vein_rich` |

- Each cell's values come from `voronoi_cell_id` at the cell (jitter 0, seeded by the map); a tile's roll from a voronoi
  cell per tile (`random_penalty` is not position-deterministic, #495).
- The vein of a cell is picked by GT's cumulative weights of the planet's veins (`gt-vein-id-<DimNames>`, set per planet in
  `property_expression_names`); on Nauvis the four cells around the origin hold the Coal, Iron, Copper and Cassiterite
  veins (at least half GT's size).
- GT's nine layers (`WorldgenGTOreLayer.java`) lie flat as bands across the vein: 1-3 secondary, 4 between (else
  secondary), 5 between, 6-7 primary (else between), 8-9 primary, sporadic in 1/7 of the tiles left; the density falls by
  chunks from the centre as GT's.
- `gt_vein_key = 8 x vein id + layer`; a tile holds one ore at most. An ore left out gives its layer to the neighbouring
  layer's ore.
- The vanilla resource controls are deleted, the Space Age planets' hidden (#508, #529).

## The map generator's controls (#529)

The Resources tab lists the grid control first, then one control per vein, `gt-vein-<GT's mix name>` (32: Nauvis 21,
the Nether 11, the Twilight Forest 15, The End 7, a vein on several surfaces once), named as the vein's chart tag with
its primary ore's icon, by surface and then by GT's weight. A vein's control is listed on the planets that place it.

| Control | Frequency | Size | Richness |
|---|---|---|---|
| `gt-ore-veins` "GT New Horizons vein grid" (every surface) | cell size: 128 / sqrt(frequency) | share of cells with a vein: 75 % x size | ore per tile of every vein |
| `gt-vein-<name>` | its weight in the pick (GT's weight x frequency) | magnifies it: radius x size, about size² the ore tiles; the cells of its planet keep room for it (88 x size) | its ore per tile |

Decisions (the maintainer's, 2026-10-23):
- The grid stays one control and keeps the name `gt-ore-veins` (not the map settings or a startup setting): it is per map,
  visible, and old saves keep their cells. Its size slider means coverage, as vanilla's.
- A vein whose checkbox is off (size or frequency 0) has weight 0: the other veins fill its cells, as GTNH leaves a
  disabled vein out of its weighted list; the share of empty cells stays.
- The four start veins of Nauvis ignore their frequency and take size and richness. A start vein that is off is not
  placed; its start cell takes a vein by the normal pick (or stays empty at the empty share).
- A size above 1.45 on one vein makes every cell of its planet larger (the cell keeps room for the largest vein), so the
  planet has fewer veins.
- Turning the grid control off removes every GT vein: the ores' autoplace names it.
- `scripts/fork-ore-veins.lua` tags a vein with GT's name when the chunk of its centre is charted.

## Surfaces

| Dimension | Planet | Reached by | Tier | Veins | Terrain |
|---|---|---|---|---|---|
| Overworld | `nauvis` | - | - | 21 | Nauvis |
| Nether | `gt-nether` | Nether Portal (10 obsidian, Flint and Steel), Reach the Nether | Steam | 11 | Vulcanus' volcanic rock and lava, no water, no sun; 1:8 |
| Twilight Forest | `gt-twilight` | Twilight Portal (4 buckets of water, Twilight Crystal), Reach the Twilight Forest | LV | 15 | Nauvis as a dense forest, permanent dusk, half the sun; 1:1 |
| The End | `gt-end` | End Portal (12 Eyes of Ender), Reach the End | HV | 7 | islands of end stone in the void, permanent night |

The planets are Space Age planets without a space connection; `scripts/fork-portals.lua` makes a surface at its first
portal. Space Age's own planets are deleted (#529, `data-final-fixes.lua`); the Nether keeps Vulcanus' terrain, and the
controls of Vulcanus' resources stay hidden because its lava reads their sliders. Recipes of one dimension carry `surface_conditions` on `gt-dimension` (nether air, glowstone, ender air, end stone;
the water drilling rig on Nauvis only). devcheck counts an ore placed only on a planet behind its reach technology as
obtainable from that technology on (`planet-mining:<resource>`).

Between the surfaces: EnderStorage's Ender Chest and Ender Tank (Ender Storage, MV; `scripts/fork-ender.lua`).

## Mining

| Machine | Area | Rate | Energy |
|---|---|---|---|
| hand | one tile | 2 s per ore | - |
| Manual Mine | 7 x 7 | 6.4 ores/s | manual labor (burner) |
| LV / MV / HV Miner | 17 x 17 / 33 x 33 / 49 x 49 | 64 ores in 24 / 12 / 6 s | EU8 |
| Ore Drilling Plant Mk I-IV | radius 40 / 48 / 64 / 96 | 64 ores in GT's base / 2^tier ticks | MV-IV; Drilling Fluid 200 per 64 ores; drain 100 / 100 / 80 / 60 % |

In map-vein mode the vein recipes of Nauvis, the Nether and the Twilight Forest are hidden (#505; since #563 they are
166's generated classic recipes, below). The Dimension Mines keep the vein recipes of the later dimensions (Moon and on,
End Asteroids, the Toxic Everglades), the Void Miners theirs; the Twilight Forest's small ores and amber vein, the Copper
Tin vein (realgar) and the glowstone vein stay recipes too.

## The ore mode (#563)

The startup setting `gregtorio-continued-ore-mode` (`settings.lua`, "Ore mode") is chosen per game: `map-veins` (the
default, everything above) or `vein-recipes`, the classic ore system of 0.5.5 and before. The maintainer's decisions of
2026-10-24 (the issue and its addendum): classic mode is generated from the data of the map veins, so it needs no extra
care when a vein, an ore or an unlock changes.

Classic mode:
- **No veins on the map.** The planets list no `gt-ore-*` resource, no vein control and no `gt_*` expression (165); the
  resources, noise expressions and controls stay for saves that switch (data-final-fixes.lua hides the controls, #508).
  The Nether, the Twilight Forest and The End stay surfaces with their terrain, portals and Ender storage.
- **The recipes** (`prototypes/166-fork-classic-veins.lua`, in both modes; hidden, disabled and never unlocked in map-vein
  mode, also not by 199's auto-unlock): one Manual Mine recipe per vein the map places (165's `FORK_ORE_VEINS.placed`: 32
  veins, a vein on several surfaces once), `mining-<GT's mix name in kebab case>-vein`, named "Mining <GT's vein name>
  Vein" as the chart tags, with its Ore Drilling Plant and Miner twins (163's `make_twins`). A name that is a recipe
  already keeps that recipe (CopperTin: upstream's Copper Tin Vein, the realgar source of both modes; its unlocks follow
  the rule below in classic mode).
- **Results:** 64 ores per operation (the iron vein's of 0.5.5) shared out by the expected ore tiles of each of GT's
  layers in the vein as 165 places it: size 1, the mean radius 8 + size / 2 tiles, GT's density falling by chunks from
  the centre, the nine bands and `gt_role_raw` (a band's first ore, its second, the sporadic ore in 1/7 of the rest),
  averaged over four directions of the bands; a left-out ore's layer goes to its neighbour (165's `ore_of`); largest
  remainder, every ore at least 1. 10 s, an iron pickaxe use and 8 manual labor (Overworld veins) or 24 (the other
  surfaces: 160's numbers since #363).
- **Unlocks:** a vein of the Overworld comes with every first technology (no other of them before it) that unlocks a
  recipe taking one of its raw ores. The ore chains are those of map-vein mode (155's `vein_techs` is the same in both
  modes), so a vein comes where its ores are first needed and moves along with the chain (#252); a recipe there from the
  start does not count, and a technology without the iron pickaxe is replaced by the pickaxe's (Smelt Iron Ingots). A
  vein of the other surfaces comes with its surfaces' reach technology. The twins come with the Mk I's and the LV
  Miner's technology, or with the vein's technologies when every one of them comes after it; the Dimension Mine with its
  first recipe (#556, called by 166 in this mode). Today: most Overworld veins with Smelt Iron Ingots, Small Coal Boiler
  or the Steam Forge Hammer (its raw ore crushing), the Nether's with Reach the Nether, the Twilight Forest's with Reach
  the Twilight Forest, the Oil Sand Vein with Ore Washing.
- **The stone pickaxe:** `mining-iron-vein-with-stone-pickaxe`, GT's Iron vein with half the ores and three times the
  labor (as in 0.5.5), with Craft Stone Tools next to #547's cobblestone; no twins.
- **The machines:** the Dimension Mine, the LV to HV Dimension Miners and the Dimension Drilling Plants Mk I to IV run
  the recipes anywhere, with the names of 0.5.5 (Manual Mine, LV/MV/HV Miner, Ore Drilling Plant Mk I-IV); their
  technologies: the Manual Mine's first recipe (Craft Stone Tools), LV Miner, Advanced MV Machines, HV Machines and the
  plants'. The mining drills are hidden, have no recipe and no next upgrade; their items place the dimension mine of
  their tier, so a drill picked up comes back as one (163).
- devcheck: `all` loads the mod a second time in this mode (`check` and `runtime` with `--set
  gregtorio-continued-ore-mode=vein-recipes`, then `switch`); `check` fails for a placed vein without its classic recipe
  and twins or with other ores (section CLASSICVEINS, read from `FORK_ORE_MIXES`, not from 166); `runtime`'s classic vein
  test runs Nauvis' iron vein in a Dimension Mine on plain ground and finds no vein ore on a planet's surface; a gt-ore
  resource that no planet places gives nothing to the model (no `planet-mining`, not from the start).

## Old saves and switching (#563)

`scripts/fork-ore-veins.lua`'s remote `migrate` (every migration file of the veins calls it, and
`migrations/2026-10-24-issue-563-ore-mode.lua` once more) decides by the mode and notes it in
`storage.fork_ore_veins.mode`; `on_configuration_changed` runs it again when a save's mode changed since its last load
(a startup setting is the player's, not the save's).

| Save | Map veins | Classic vein recipes |
|---|---|---|
| 0.5.5 or older | converted as in 0.5.6: veins in the generated chunks, a mine on a vein of its planet becomes the drill, one on another planet's vein loses the recipe (message) | every mine keeps its vein recipe; the 7 old names that are no generated name (chalcopyrite, salt, basaltic mineral sands, lignite, sphalerite, galena, saltpeter electrotine vein) stay hidden recipes and the mine gets the generated one of the same GT vein (Copper, Salts, MineralSand, LigniteCoal, Sulfur, TFGalena, SaltPeterElectrotine) |
| 0.5.6 or later (converted) | unchanged | the surfaces lose the veins in their map settings (new chunks get none; the veins' controls are no sign of a foreign map for #540); the ore on the map and the drills on it stay and keep mining; drill items build the classic mines |
| switched from classic to map veins | as a 0.5.5 save: veins in the generated chunks, mines on their planet's veins become drills, the others lose the recipe | - |

The engine applies a JSON migration that renames a recipe also when the old name still exists (tested headless for
#563), so V9's JSON migration onto `removed-vein-<planet>-<kind>` is gone: it would have taken every mine's recipe in
classic mode. Its placeholders stay hidden prototypes. devcheck: `migrate --set
gregtorio-continued-ore-mode=vein-recipes` loads an old save in classic mode, `switch` makes a map in one mode and loads
it in the other, both ways (`tools/devcheck/switchmod`).

## Old saves

- #499: placed mines become Dimension Mines (JSON migration, the names went to the drills).
- #500: the surfaces get the veins (`regenerate_entity` on every generated chunk; #534: on every generated chunk without
  vein ore, also when the map settings already named the veins, e.g. after a map settings editor), a Dimension Mine on a vein of its
  surface becomes its drill, names of missing noise expressions are dropped from the map settings.
- #505: on its vein's planet the mine becomes its drill, elsewhere it loses the recipe and a message names it (until #563
  through a JSON migration onto placeholders `removed-vein-<planet>-<kind>`; now by the mode, above).
- #529: the surfaces get the veins' controls at their defaults (`migrations/2026-10-23-issue-529-vein-controls.lua`); a
  save whose `gt-ore-veins` size is not 1 gets that size on every vein and 1 on the grid, so its cells and veins stay.
  A surface of a deleted Space Age planet is deleted by the engine on load.
- #540: a map made with Space Age kept every planet's autoplace controls on its Nauvis surface; since #529 and Factorio
  2.1 they placed Gleba's plants and decoratives in Nauvis' new chunks. The surfaces with veins keep only their planet's
  controls (the save's values), autoplace settings and expression names (and the ones of the map presets and climate
  sliders); a surface that had others gets its chunks without a building of a player (and without a placed tile) deleted,
  so they are generated anew, and the trees, plants, rocks, cliffs and decoratives of Space Age that its planet does not
  place removed from the kept chunks; their tiles stay (`migrations/2026-10-23-issue-540-foreign-map-gen.lua`). The
  Nether, Twilight Forest and End surfaces take their planet's settings when they are made (also in Factorio 2.0 and with
  a map whose settings list every control), and a map started with 0.5.7 is not touched.
