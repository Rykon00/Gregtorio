# Ore veins on the map (plan #494)

GT New Horizons' ore veins (`OreMixes.java` of GT5-Unofficial f2814df) are mixed ore patches on the map, and GTNH's T0
dimensions are surfaces of their own. Built in phases V0 to V9 (#495 to #505); this page has the final numbers.

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

The old vein recipes of Nauvis, the Nether and the Twilight Forest are gone (#505). The Dimension Mines keep the vein
recipes of the later dimensions (Moon and on, End Asteroids, the Toxic Everglades), the Void Miners theirs; the Twilight
Forest's small ores and amber vein, the Copper Tin vein (realgar) and the glowstone vein stay recipes too.

## Old saves

- #499: placed mines become Dimension Mines (JSON migration, the names went to the drills).
- #500: the surfaces get the veins (`regenerate_entity` on every generated chunk), a Dimension Mine on a vein of its
  surface becomes its drill, names of missing noise expressions are dropped from the map settings.
- #505: the deleted vein recipes become a placeholder of their planet (`removed-vein-<planet>-<kind>`, JSON); on that
  planet the mine becomes its drill, elsewhere it loses the recipe and a message names it.
- #529: the surfaces get the veins' controls at their defaults (`migrations/2026-10-23-issue-529-vein-controls.lua`); a
  save whose `gt-ore-veins` size is not 1 gets that size on every vein and 1 on the grid, so its cells and veins stay.
  A surface of a deleted Space Age planet is deleted by the engine on load.
