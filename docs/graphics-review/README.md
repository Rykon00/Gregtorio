# Graphics review (issues #40 and #41)

Contact sheets to check the new graphics without starting the game: every entry shows the old file
(left, `origin/main` when the sheets were made) next to the new one (right), grouped by line.
Regenerate them with `python tools/gen_review_sheet.py all`.

| Sheets | What |
|---|---|
| `icons-*.png` | the 393 item icons that were placeholders |
| `techs-*.png` | the 66 technology icons that changed with them |
| `sprites-*.png` | the 131 machines with new sprites (idle and working) |
| `icon-sources.tsv` | for every item, the textures it is made of (`tools/gen_gt_icons.py --sources`) |

## How the graphics are made

All from textures of [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) (LGPL-3.0, including
the mods merged into it: GT++ "miscutils", GoodGenerator, bartworks) and, for the stargate parts and the
generic UMV/UXV circuits, [NewHorizonsCoreMod](https://github.com/GTNewHorizons/NewHorizonsCoreMod)
(GPL-3.0). Both checkouts are only needed to regenerate, not to play:

```
python tools/gen_gt_icons.py --gt <GT5-Unofficial> --core <NewHorizonsCoreMod>   # item icons (tools/gt-icon-items.txt)
python tools/gen_sprites.py --gt <GT5-Unofficial>                              # machine sprites and icons
python tools/gen_tech_icons.py --gt <GT5-Unofficial>                           # technology icons (tools/tech-icons.tsv)
python tools/gen_review_sheet.py all                                           # these sheets
```

* **Items with a GT texture** use it (first animation frame, 16x16 scaled 2x to the 32x32 of the other
  Gregtorio icons, without mipmaps like the other fork icons): LuV to UXV components, voltage coils, the
  wetware, bio, optical, exotic and temporal circuits (GT's "temporally transcendent" line for the
  temporal one), wafers, power ICs, complex SMDs, fusion casings and coils, stargate parts, space coolant cells.
* **Materials** (ingot, hot ingot, plate, dense and superdense plate, foil, rod, long rod, gear, large
  gear, ring, bolt, screw, rotor, round, nugget, dust, fine wire, frame, turbine blade) are rendered the
  way GT does it: the icon of the material's GT icon set (falling back to `NONE`) multiplied with GT's
  material colour, the `_OVERLAY` on top untinted. Icon sets and colours are read from GT's
  `MaterialsInit.java`; GT++ and bartworks materials and the superconductor bases Gregtorio names itself
  (the fork's LuV to UMV superconductors take GT's base of the same tier) are in `MATERIALS`.
* **Compositions** where GT has no flat texture: wires, cables and superconductor wires (GT renders
  them as blocks; drawn as the short diagonal bar of Gregtorio's own wires in the GT colour, cables
  insulated with the metal at the ends, superconductors with a pale blue sheen, 4x/16x as bundles),
  energy and dynamo hatches and hulls (the tier's GT hull with GT's hatch overlay of that tier), chip and
  SMD wraps (the chip under bartworks' wrap band), multiblock items (2x2 GT tiles: casing, coil or glass,
  controller face; the controller item is the face alone), the exotic and temporal processing units
  (GT's optically perfected CPU with the board of the line), the tritanium and spacetime coils (GT's
  trinium coil frame, winding in the metal), the 1080k super coolant cell (the 1080k space cell in GT's
  super coolant colour), the stargate iris blade (GT's turbine blade in neutronium).

## Sprites (#41)

* **Fusion reactor MK4 and MK5** no longer reuse the MK3 art. GT has no MK4/MK5 reactor of its own, so
  they take the art of GoodGenerator's compact fusion computers MK-IV and MK-V: GT++ fusion machine
  casing MK-III / MK-IV, compact fusion coil Mk-II prototype / finaltype, the GT++ screen as the
  controller face (idle and working). Same 9x9 layout and single-frame idle/working sprites as MK1 to MK3.
* **UHV to UXV basic machines** (23 each): the tier's GT hull (`MACHINE_<tier>_SIDE`, tier colour) as a
  frame of 3x3 tiles, the machine top (`MACHINE_<tier>_TOP` + GT overlay) on the middle 2x2. GT's hull
  patterns differ per tier (rings from UEV up), so the tiers differ in shape, not only in colour. Same
  size (3x3 tiles), same 6 working frames. IV to UV keep their look.
* **Large plasma turbines (LuV to UXV) and large naquadah reactors (UV to UXV)**: no tinted copies any
  more. Every tier shows the untinted GT turbine face / reactor casing with four dynamo hatches of its
  tier on the corner tiles (GT's hull of the tier + GT's 2A dynamo overlay of the tier), the way a GT
  generator shows its tier; their item icons carry the hatch as a badge. The LuV turbine and the UV
  reactor get their own tier's hatches, so every tier follows the same pattern.

## Inventory: placeholders before this change

**Item icons**: 393 items had an icon from `tools/gen_icons.py`: a neighbour icon recolored in a tier or
material hue, or an unrelated neighbour (the wetware items and stem cells, the exotic and temporal lines,
the stargate parts). All 393 now come from GT (tables below). 11 more generated icons are not used by
any item any more (the drafts removed for good in #39) and were left alone.

**Technology icons**: no technology shows "NYI"; 66 had the icon of a placeholder item (or of a tinted
machine) and are regenerated from the new icons. `tools/tech-icons.tsv` now lists which item every fork
technology shows (174 technologies; the 6 ME technologies come from `gen_ae2_sprites.py`).

**Entities that reused another entity's sprite**:

| Entity | Before | Now |
|---|---|---|
| fusion reactor MK4, MK5 | MK3 art | own art (above) |
| UHV, UEV, UIV, UMV, UXV basic machines (115) | GT tier texture + tint, mostly hidden under the overlay | tier hull frame |
| large plasma turbine ZPM to UXV (7) | LuV sprite tinted | tier dynamo hatches |
| large naquadah reactor UHV to UXV (5) | UV sprite tinted | tier dynamo hatches |
| IV to UXV upgrade multiblocks: electric blast furnace, vacuum freezer, large chemical reactor, microverse projector, both distillation towers, implosion compressor, cracker, multismelter, pyrolyse oven, greenhouse, drilling rig, alloy blast smelter | upstream art of the EV version | **unchanged**, see below |

### Still placeholders, and why

* **Upgrade multiblocks** (13 families, IV to UXV): they share the upstream art of their EV version,
  entity and item icon (upstream already shares it between HV and EV). They are animated multi-layer
  upstream sprites of different sizes; a tier mark needs an extra sprite layer per entity, which is a
  prototype change outside this graphics pass.
* **Fluids**: Gregtorio draws its 284 fluids with 78 shared colour icons (upstream's style). The 36
  fluids the fork added follow it (for example the grade 1 to 8 waters use the water icon). Replacing
  only those would make them the odd ones out; a GT fluid texture pass for all fluids is its own change.
* **Upstream items with identical icons** outside the fork's lines (for example crushed gypsum and
  crushed nether quartz) are upstream art and not part of this pass.

## What to look at in game

* The LuV+ components are GT's own textures, drawn differently from upstream's LV to IV components
  (GT's motor is a diamond, the UHV parts are dark). Check that the step from IV to LuV in the crafting
  menu is acceptable.
* Dark GT materials (naquadah alloy, universium, transcendent metal, tritanium, cosmic neutronium) are
  dark in GT as well; check that they are readable on the inventory background.
* Fusion reactors MK4/MK5 placed next to an MK3; the UHV to UXV machines in a row with a UV one; a row
  of turbines and reactors from LuV/UV to UXV (the corner hatches).
* The technology tree from UHV up: the technology icons follow the new item icons.

## Item icons by line

### Tier components (56)

[`icons-01-tier-components.png`](icons-01-tier-components.png)

| Item | Made from |
|---|---|
| `luv-conveyor-module` | GT item 01/635 |
| `luv-emitter` | GT item 01/685 |
| `luv-field-generator` | GT item 01/675 |
| `luv-motor` | GT item 01/606 |
| `luv-piston` | GT item 01/645 |
| `luv-pump` | GT item 01/615 |
| `luv-robot-arm` | GT item 01/655 |
| `luv-sensor` | GT item 01/695 |
| `uev-conveyor-module` | GT item 01/639 |
| `uev-emitter` | GT item 01/689 |
| `uev-field-generator` | GT item 01/679 |
| `uev-motor` | GT item 01/595 |
| `uev-piston` | GT item 01/649 |
| `uev-pump` | GT item 01/619 |
| `uev-robot-arm` | GT item 01/659 |
| `uev-sensor` | GT item 01/699 |
| `uhv-conveyor-module` | GT item 01/638 |
| `uhv-emitter` | GT item 01/688 |
| `uhv-field-generator` | GT item 01/678 |
| `uhv-motor` | GT item 01/596 |
| `uhv-piston` | GT item 01/648 |
| `uhv-pump` | GT item 01/618 |
| `uhv-robot-arm` | GT item 01/658 |
| `uhv-sensor` | GT item 01/698 |
| `uiv-conveyor-module` | GT item 01/29 |
| `uiv-emitter` | GT item 01/37 |
| `uiv-field-generator` | GT item 01/45 |
| `uiv-motor` | GT item 01/17 |
| `uiv-piston` | GT item 01/21 |
| `uiv-pump` | GT item 01/25 |
| `uiv-robot-arm` | GT item 01/33 |
| `uiv-sensor` | GT item 01/41 |
| `umv-conveyor-module` | GT item 01/30 |
| `umv-emitter` | GT item 01/38 |
| `umv-field-generator` | GT item 01/46 |
| `umv-motor` | GT item 01/18 |
| `umv-piston` | GT item 01/22 |
| `umv-pump` | GT item 01/26 |
| `umv-robot-arm` | GT item 01/34 |
| `umv-sensor` | GT item 01/42 |
| `uv-conveyor-module` | GT item 01/637 |
| `uv-emitter` | GT item 01/687 |
| `uv-field-generator` | GT item 01/677 |
| `uv-motor` | GT item 01/608 |
| `uv-piston` | GT item 01/647 |
| `uv-pump` | GT item 01/617 |
| `uv-robot-arm` | GT item 01/657 |
| `uv-sensor` | GT item 01/697 |
| `zpm-conveyor-module` | GT item 01/636 |
| `zpm-emitter` | GT item 01/686 |
| `zpm-field-generator` | GT item 01/676 |
| `zpm-motor` | GT item 01/607 |
| `zpm-piston` | GT item 01/646 |
| `zpm-pump` | GT item 01/616 |
| `zpm-robot-arm` | GT item 01/656 |
| `zpm-sensor` | GT item 01/696 |

### Casings, hulls and power hatches (34)

[`icons-02-casings-hulls-and-power-hatches.png`](icons-02-casings-hulls-and-power-hatches.png)

| Item | Made from |
|---|---|
| `luv-dynamo-hatch` | GT block MACHINE_LuV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_LuV |
| `luv-energy-hatch` | GT block MACHINE_LuV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_LuV |
| `luv-machine-casing` | GT block MACHINE_LuV_SIDE |
| `luv-machine-hull` | GT block MACHINE_LuV_SIDE, GT block OVERLAY_ENERGY_OUT_LuV |
| `uev-dynamo-hatch` | GT block MACHINE_UEV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UEV |
| `uev-energy-hatch` | GT block MACHINE_UEV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UEV |
| `uev-machine-casing` | GT block MACHINE_UEV_SIDE |
| `uev-machine-hull` | GT block MACHINE_UEV_SIDE, GT block OVERLAY_ENERGY_OUT_UEV |
| `uhv-dynamo-hatch` | GT block MACHINE_UHV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UHV |
| `uhv-energy-hatch` | GT block MACHINE_UHV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UHV |
| `uhv-machine-casing` | GT block MACHINE_UHV_SIDE |
| `uhv-machine-hull` | GT block MACHINE_UHV_SIDE, GT block OVERLAY_ENERGY_OUT_UHV |
| `uiv-dynamo-hatch` | GT block MACHINE_UIV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UIV |
| `uiv-energy-hatch` | GT block MACHINE_UIV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UIV |
| `uiv-machine-casing` | GT block MACHINE_UIV_SIDE |
| `uiv-machine-hull` | GT block MACHINE_UIV_SIDE, GT block OVERLAY_ENERGY_OUT_UIV |
| `umv-circuit` | core mod itemCircuitUMV |
| `umv-dynamo-hatch` | GT block MACHINE_UMV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UMV |
| `umv-energy-hatch` | GT block MACHINE_UMV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UMV |
| `umv-machine-casing` | GT block MACHINE_UMV_SIDE |
| `umv-machine-hull` | GT block MACHINE_UMV_SIDE, GT block OVERLAY_ENERGY_OUT_UMV |
| `uv-dynamo-hatch` | GT block MACHINE_UV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UV |
| `uv-energy-hatch` | GT block MACHINE_UV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UV |
| `uv-machine-casing` | GT block MACHINE_UV_SIDE |
| `uv-machine-hull` | GT block MACHINE_UV_SIDE, GT block OVERLAY_ENERGY_OUT_UV |
| `uxv-circuit` | core mod itemCircuitUXV |
| `uxv-dynamo-hatch` | GT block MACHINE_UXV_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_UXV |
| `uxv-energy-hatch` | GT block MACHINE_UXV_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_UXV |
| `uxv-machine-casing` | GT block MACHINE_UXV_SIDE |
| `uxv-machine-hull` | GT block MACHINE_UXV_SIDE, GT block OVERLAY_ENERGY_OUT_UXV |
| `zpm-dynamo-hatch` | GT block MACHINE_ZPM_SIDE, GT block OVERLAY_ENERGY_OUT_MULTI_2A_ZPM |
| `zpm-energy-hatch` | GT block MACHINE_ZPM_SIDE, GT block OVERLAY_ENERGY_IN_MULTI_2A_ZPM |
| `zpm-machine-casing` | GT block MACHINE_ZPM_SIDE |
| `zpm-machine-hull` | GT block MACHINE_ZPM_SIDE, GT block OVERLAY_ENERGY_OUT_ZPM |

### Wetware line and stem cells (6)

[`icons-03-wetware-line-and-stem-cells.png`](icons-03-wetware-line-and-stem-cells.png)

| Item | Made from |
|---|---|
| `neuro-processing-unit` | GT item 03/72 |
| `stem-cells` | GT item 03/73 |
| `wetware-printed-circuit-board` | GT item 03/105 |
| `wetware-processor` | GT item 03/92 |
| `wetware-processor-assembly` | GT item 03/93 |
| `wetware-processor-supercomputer` | GT item 03/94 |

### Bio line (6)

[`icons-04-bio-line.png`](icons-04-bio-line.png)

| Item | Made from |
|---|---|
| `bio-cells` | GT item 03/76 |
| `bio-processing-unit` | GT item 03/77 |
| `bio-processor` | GT item 03/97 |
| `bio-processor-assembly` | GT item 03/98 |
| `bio-processor-supercomputer` | GT item 03/99 |
| `bioware-printed-circuit-board` | GT item 03/8 |

### Optical line (6)

[`icons-05-optical-line.png`](icons-05-optical-line.png)

| Item | Made from |
|---|---|
| `optical-fiber` | GT item gt.circuitcomponent/processed/processedcableopticalfiber |
| `optical-printed-circuit-board` | GT item 03/728 |
| `optical-processing-unit` | GT item 03/726 |
| `optical-processor` | GT item 03/154 |
| `optical-processor-assembly` | GT item 03/155 |
| `optical-processor-supercomputer` | GT item 03/156 |

### Exotic line (5)

[`icons-06-exotic-line.png`](icons-06-exotic-line.png)

| Item | Made from |
|---|---|
| `exotic-printed-circuit-board` | GT item 03/729 |
| `exotic-processing-unit` | GT item 03/726, GT item 03/729 |
| `exotic-processor` | GT item 03/166 |
| `exotic-processor-assembly` | GT item 03/167 |
| `exotic-processor-supercomputer` | GT item 03/168 |

### Temporal line (5)

[`icons-07-temporal-line.png`](icons-07-temporal-line.png)

| Item | Made from |
|---|---|
| `temporal-printed-circuit-board` | GT item 03/731 |
| `temporal-processing-unit` | GT item 03/726, GT item 03/731 |
| `temporal-processor` | GT item 03/174 |
| `temporal-processor-assembly` | GT item 03/175 |
| `temporal-processor-supercomputer` | GT item 03/176 |

### Crystal chips and boards (6)

[`icons-08-crystal-chips-and-boards.png`](icons-08-crystal-chips-and-boards.png)

| Item | Made from |
|---|---|
| `crystal-cpu` | GT item 03/70 |
| `engraved-crystal-chip` | GT item 01/713 |
| `multilayered-fiber-reinforced-circuit-board` | GT item 01/712 |
| `multilayered-fiber-reinforced-printed-circuit-board` | GT item 03/104 |
| `raw-crystal-chip` | GT item 03/69 |
| `raw-crystal-chip-part` | GT item 03/74 |

### Water purification: wafers, power ICs, SMDs, catalyst (18)

[`icons-09-water-purification-wafers-power-ics-smds.png`](icons-09-water-purification-wafers-power-ics-smds.png)

| Item | Made from |
|---|---|
| `apic-wafer` | GT item 03/268 |
| `atto-power-ic` | GT item 03/269 |
| `complex-smd-capacitor` | GT item 03/181 |
| `complex-smd-diode` | GT item 03/179 |
| `complex-smd-inductor` | GT item 03/184 |
| `complex-smd-resistor` | GT item 03/178 |
| `complex-smd-transistor` | GT item 03/180 |
| `femto-power-ic` | GT item 03/267 |
| `fpic-wafer` | GT item 03/266 |
| `nano-power-ic` | GT item 03/161 |
| `npic-wafer` | GT item 03/160 |
| `pico-power-ic` | GT item 03/163 |
| `ppic-wafer` | GT item 03/162 |
| `qpic-wafer` | GT item 03/164 |
| `quantum-power-ic` | GT item 03/165 |
| `quark-creation-catalyst` | GT item 03/241 |
| `uhpic-wafer` | GT item 03/58 |
| `ultra-high-powered-integrated-circuit` | GT item 03/59 |

### Chip and SMD wraps (7)

[`icons-10-chip-and-smd-wraps.png`](icons-10-chip-and-smd-wraps.png)

| Item | Made from |
|---|---|
| `advanced-smd-capacitor-wrap` | bartworks items/WrapOverlay, GT item 03/27 |
| `advanced-smd-inductor-wrap` | bartworks items/WrapOverlay, GT item 03/183 |
| `advanced-smd-transistor-wrap` | bartworks items/WrapOverlay, GT item 03/26 |
| `nand-memory-chip-wrap` | bartworks items/WrapOverlay, GT item 03/41 |
| `nano-cpu-chip-wrap` | bartworks items/WrapOverlay, GT item 03/55 |
| `nor-memory-chip-wrap` | bartworks items/WrapOverlay, GT item 03/43 |
| `ram-chip-wrap` | bartworks items/WrapOverlay, GT item 03/39 |

### Fusion (17)

[`icons-11-fusion.png`](icons-11-fusion.png)

| Item | Made from |
|---|---|
| `advanced-fusion-coil` | GT++ block MACHINE_CASING_FUSION_COIL_II |
| `advanced-fusion-coil-ii` | GT++ block MACHINE_CASING_FUSION_COIL_III |
| `fusion-coil-block` | GT block MACHINE_CASING_FUSION_COIL |
| `fusion-machine-casing` | GT block MACHINE_CASING_FUSION |
| `fusion-machine-casing-mk2` | GT block MACHINE_CASING_FUSION_2 |
| `fusion-machine-casing-mk3` | GT++ block MACHINE_CASING_FUSION_3 |
| `fusion-machine-casing-mk4` | GT++ block MACHINE_CASING_FUSION_4 |
| `fusion-reactor-mk1` | GT block MACHINE_CASING_FUSION, GT block OVERLAY_FUSION1, GT block MACHINE_CASING_FUSION_COIL |
| `fusion-reactor-mk1-controller` | GT block MACHINE_CASING_FUSION, GT block OVERLAY_FUSION1 |
| `fusion-reactor-mk2` | GT block MACHINE_CASING_FUSION_2, GT block OVERLAY_FUSION2, GT block MACHINE_CASING_FUSION_COIL |
| `fusion-reactor-mk2-controller` | GT block MACHINE_CASING_FUSION_2, GT block OVERLAY_FUSION2 |
| `fusion-reactor-mk3` | GT block MACHINE_CASING_FUSION_2, GT block OVERLAY_FUSION3, GT block MACHINE_CASING_FUSION_COIL |
| `fusion-reactor-mk3-controller` | GT block MACHINE_CASING_FUSION_2, GT block OVERLAY_FUSION3 |
| `fusion-reactor-mk4` | GT++ block MACHINE_CASING_FUSION_3, GT++ block adv_machine_screen_random3, GoodGenerator blocks/fuison/4 |
| `fusion-reactor-mk4-controller` | GT++ block MACHINE_CASING_FUSION_3, GT++ block adv_machine_screen_random3 |
| `fusion-reactor-mk5` | GT++ block MACHINE_CASING_FUSION_4, GT++ block overlay_rainbowscreen, GoodGenerator blocks/fuison/5 |
| `fusion-reactor-mk5-controller` | GT++ block MACHINE_CASING_FUSION_4, GT++ block overlay_rainbowscreen |

### Coils (14)

[`icons-12-coils.png`](icons-12-coils.png)

| Item | Made from |
|---|---|
| `eternal-coil-block` | GT block MACHINE_COIL_ETERNAL |
| `extended-mega-ultimate-voltage-coil` | GT item 03/262 |
| `extremely-ultimate-voltage-coil` | GT item 03/259 |
| `highly-ultimate-voltage-coil` | GT item 03/149 |
| `insanely-ultimate-voltage-coil` | GT item 03/260 |
| `ludicrous-voltage-coil` | GT item 03/146 |
| `mega-ultimate-voltage-coil` | GT item 03/261 |
| `naquadah-coil-block` | GT block MACHINE_COIL_NAQUADAH |
| `spacetime-coil-block` | GT block MACHINE_COIL_TRINIUM_BACKGROUND, GT block MACHINE_COIL_TRINIUM_FOREGROUND, GT block set CUSTOM/spacetime/BLOCK_SPACETIME |
| `superconducting-coil-block` | GT block MACHINE_COIL_SUPERCONDUCTOR |
| `trinium-coil-block` | GT block MACHINE_COIL_TRINIUM |
| `tritanium-coil-block` | GT block MACHINE_COIL_TRINIUM_BACKGROUND, GT block MACHINE_COIL_TRINIUM_FOREGROUND |
| `ultimate-voltage-coil` | GT item 03/148 |
| `zero-point-module-voltage-coil` | GT item 03/147 |

### Power: plutonium, cells, storage, turbines, reactors (14)

[`icons-13-power-plutonium-cells-storage-turbines-r.png`](icons-13-power-plutonium-cells-storage-turbines-r.png)

| Item | Made from |
|---|---|
| `1080k-space-cell` | GT item gt.1080k_Space_Coolantcell |
| `1080k-super-coolant-cell` | GT item gt.1080k_Space_Coolantcell |
| `180k-space-cell` | GT item gt.180k_Space_Coolantcell |
| `540k-space-cell` | GT item gt.540k_Space_Coolantcell |
| `energy-module` | GT item 01/736 |
| `high-density-plutonium` | GoodGenerator items/highDensityPlutonium |
| `high-density-plutonium-nugget` | GoodGenerator items/highDensityPlutoniumNugget |
| `lapotronic-energy-orb-cluster` | GT item 01/599 |
| `large-naquadah-reactor-controller` | GT block NAQUADAH_REACTOR_CASING, GT block NAQUADAH_REACTOR_FLUID_FRONT |
| `large-plasma-turbine-controller` | GT block MACHINE_CASING_TURBINE_TUNGSTENSTEEL, GT block LARGETURBINE_TU5 |
| `radioactive-sludge` | GoodGenerator items/radioactiveWaste |
| `tungstensteel-turbine-blade` | colour of TungstenSteel #6464a0, GT icon set METALLIC/turbineBlade |
| `tungstensteel-turbine-rotor` | colour of TungstenSteel #6464a0, GT icon set NONE/toolTurbine |
| `wrapped-plutonium-ingot` | GoodGenerator items/wrappedPlutoniumIngot |

### Stargate parts (4)

[`icons-14-stargate-parts.png`](icons-14-stargate-parts.png)

| Item | Made from |
|---|---|
| `stargate-chevron` | core mod itemStargateChevron |
| `stargate-frame-part` | core mod itemStargateFramePart |
| `stargate-iris-blade` | colour of Neutronium #fafafa, GT icon set NONE/turbineBlade |
| `stargate-radiation-containment-plate` | core mod itemStargateShieldingFoil |

### Multiblocks (5)

[`icons-15-multiblocks.png`](icons-15-multiblocks.png)

| Item | Made from |
|---|---|
| `bacterial-vat` | GT block MACHINE_CASING_CLEAN_STAINLESSSTEEL, GT block OVERLAY_FRONT_BIOLOGICAL_COORDINATION, bartworks blocks/TitaniumReinforcedBoronSilicateGlassBlock |
| `bacterial-vat-controller` | GT block MACHINE_CASING_CLEAN_STAINLESSSTEEL, GT block OVERLAY_FRONT_BIOLOGICAL_COORDINATION |
| `circuit-assembly-line-controller` | GT block MACHINE_CASING_ASSEMBLER, GT block OVERLAY_FRONT_ASSEMBLY_MATRIX |
| `luv-circuit-assembly-line` | GT block MACHINE_CASING_ASSEMBLER, GT block OVERLAY_FRONT_ASSEMBLY_MATRIX, GT block MACHINE_CASING_GRATE |
| `zpm-assembly-line` | GT block MACHINE_CASING_ASSEMBLER, GT block OVERLAY_FRONT_ASSEMBLY_LINE, GT block MACHINE_CASING_GRATE |

### Endgame materials (issue #36) (16)

[`icons-16-endgame-materials-issue-36.png`](icons-16-endgame-materials-issue-36.png)

| Item | Made from |
|---|---|
| `bedrockium-cable` | GT icon set CUSTOM/bedrockium/ingot, colour of Bedrockium #2a2a2a |
| `bedrockium-plate` | GT icon set CUSTOM/bedrockium/plate |
| `bedrockium-wire` | GT icon set CUSTOM/bedrockium/ingot, colour of Bedrockium #2a2a2a |
| `callisto-ice-dust` | colour of CallistoIce #1eb1ff, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `dense-fluxed-electrum-plate` | GT icon set CUSTOM/fluxed/plateDense |
| `fine-fluxed-electrum-wire` | GT icon set CUSTOM/fluxed/wireFine, GT icon set NONE/wireFine_OVERLAY |
| `fluxed-electrum-dust` | GT icon set CUSTOM/fluxed/dust |
| `fluxed-electrum-plate` | GT icon set CUSTOM/fluxed/plate |
| `fluxed-electrum-wire` | GT icon set CUSTOM/fluxed/ingot, colour of ElectrumFlux #b37e43 |
| `hot-bedrockium-ingot` | GT icon set CUSTOM/bedrockium/ingotHot, GT icon set CUSTOM/bedrockium/ingotHot_OVERLAY |
| `hot-fluxed-electrum-ingot` | GT icon set CUSTOM/fluxed/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-quantium-ingot` | colour of Quantium #00d10b, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `quantium-cable` | colour of Quantium #00d10b |
| `quantium-dust` | colour of Quantium #00d10b, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `quantium-ingot` | colour of Quantium #00d10b, GT icon set SHINY/ingot, GT icon set SHINY/ingot_OVERLAY |
| `quantium-wire` | colour of Quantium #00d10b |

### Superconductors (39)

[`icons-17-superconductors.png`](icons-17-superconductors.png)

| Item | Made from |
|---|---|
| `chromnorox-dust` | colour of SuperconductorUIVBase #e558b1, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `chromnorox-ingot` | colour of SuperconductorUIVBase #e558b1, GT icon set SHINY/ingot, GT icon set SHINY/ingot_OVERLAY |
| `chromnorox-superconductive-wire` | colour of SuperconductorUIVBase #e558b1 |
| `chromnorox-wire` | colour of SuperconductorUIVBase #e558b1 |
| `dracofinium-dust` | colour of SuperconductorUEVBase #ae0808, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `dracofinium-ingot` | colour of SuperconductorUEVBase #ae0808, GT icon set SHINY/ingot, GT icon set SHINY/ingot_OVERLAY |
| `dracofinium-superconductive-wire` | colour of SuperconductorUEVBase #ae0808 |
| `dracofinium-wire` | colour of SuperconductorUEVBase #ae0808 |
| `eternity-dust` | GT icon set CUSTOM/eternity/dust, GT icon set CUSTOM/eternity/dust_OVERLAY |
| `eternity-superconductive-wire` | GT icon set CUSTOM/eternity/ingot, colour of Eternity #5d5369 |
| `eternity-wire` | GT icon set CUSTOM/eternity/ingot, colour of Eternity #5d5369 |
| `hot-chromnorox-ingot` | colour of SuperconductorUIVBase #e558b1, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-dracofinium-ingot` | colour of SuperconductorUEVBase #ae0808, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-eternity-ingot` | GT icon set CUSTOM/eternity/ingotHot, GT icon set CUSTOM/eternity/ingotHot_OVERLAY |
| `hot-hypocosmium-ingot` | colour of SuperconductorUMVBase #b526cd, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-itbtc-alloy-ingot` | colour of Tetraindiumditindibariumtitaniumheptacoppertetrakaidekaoxid #994c00, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-naquamiridium-ingot` | colour of Longasssuperconductornameforuvwire #e0d207, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-palladium-naqindium-ingot` | colour of Tetranaquadahdiindiumhexaplatiumosminid #0a0a0a, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hot-triamerotronium-ingot` | colour of Longasssuperconductornameforuhvwire #2681bd, GT icon set NONE/ingotHot, GT icon set NONE/ingotHot_OVERLAY |
| `hypocosmium-dust` | colour of SuperconductorUMVBase #b526cd, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `hypocosmium-ingot` | colour of SuperconductorUMVBase #b526cd, GT icon set SHINY/ingot, GT icon set SHINY/ingot_OVERLAY |
| `hypocosmium-superconductive-wire` | colour of SuperconductorUMVBase #b526cd |
| `hypocosmium-wire` | colour of SuperconductorUMVBase #b526cd |
| `itbtc-alloy-dust` | colour of Tetraindiumditindibariumtitaniumheptacoppertetrakaidekaoxid #994c00, GT icon set METALLIC/dust |
| `itbtc-alloy-ingot` | colour of Tetraindiumditindibariumtitaniumheptacoppertetrakaidekaoxid #994c00, GT icon set METALLIC/ingot |
| `itbtc-alloy-wire` | colour of Tetraindiumditindibariumtitaniumheptacoppertetrakaidekaoxid #994c00 |
| `luv-superconductor-wire-16x` |  |
| `naquamiridium-dust` | colour of Longasssuperconductornameforuvwire #e0d207, GT icon set METALLIC/dust |
| `naquamiridium-ingot` | colour of Longasssuperconductornameforuvwire #e0d207, GT icon set METALLIC/ingot |
| `naquamiridium-superconductive-wire` | colour of Longasssuperconductornameforuvwire #e0d207 |
| `naquamiridium-wire` | colour of Longasssuperconductornameforuvwire #e0d207 |
| `palladium-naqindium-dust` | colour of Tetranaquadahdiindiumhexaplatiumosminid #0a0a0a, GT icon set METALLIC/dust |
| `palladium-naqindium-ingot` | colour of Tetranaquadahdiindiumhexaplatiumosminid #0a0a0a, GT icon set METALLIC/ingot |
| `palladium-naqindium-superconductive-wire` | colour of Tetranaquadahdiindiumhexaplatiumosminid #0a0a0a |
| `palladium-naqindium-wire` | colour of Tetranaquadahdiindiumhexaplatiumosminid #0a0a0a |
| `triamerotronium-dust` | colour of Longasssuperconductornameforuhvwire #2681bd, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `triamerotronium-ingot` | colour of Longasssuperconductornameforuhvwire #2681bd, GT icon set SHINY/ingot, GT icon set SHINY/ingot_OVERLAY |
| `triamerotronium-superconductive-wire` | colour of Longasssuperconductornameforuhvwire #2681bd |
| `triamerotronium-wire` | colour of Longasssuperconductornameforuhvwire #2681bd |

### UEV to UXV metals (65)

[`icons-18-uev-to-uxv-metals.png`](icons-18-uev-to-uxv-metals.png)

| Item | Made from |
|---|---|
| `cosmic-neutronium-foil` | colour of CosmicNeutronium #323237, GT icon set NONE/foil, GT icon set CUSTOM/cosmicneutronium/foil_OVERLAY |
| `cosmic-neutronium-ingot` | colour of CosmicNeutronium #323237, GT icon set NONE/ingot, GT icon set CUSTOM/cosmicneutronium/ingot_OVERLAY |
| `cosmic-neutronium-plate` | colour of CosmicNeutronium #323237, GT icon set NONE/plate, GT icon set CUSTOM/cosmicneutronium/plate_OVERLAY |
| `draconium-cable` | colour of Draconium #7a44b0 |
| `draconium-ingot` | colour of Draconium #7a44b0, GT icon set NONE/ingot, GT icon set CUSTOM/draconium/ingot_OVERLAY |
| `draconium-wire` | colour of Draconium #7a44b0 |
| `fine-cosmic-neutronium-wire` | colour of CosmicNeutronium #323237, GT icon set NONE/wireFine, GT icon set CUSTOM/cosmicneutronium/wireFine_OVERLAY |
| `fine-spacetime-wire` | GT icon set CUSTOM/spacetime/wireFine, GT icon set CUSTOM/spacetime/wireFine_OVERLAY |
| `fine-transcendent-metal-wire` | colour of TranscendentMetal #323232, GT icon set NONE/wireFine, GT icon set NONE/wireFine_OVERLAY |
| `fine-universium-wire` | colour of Universium #263145, GT icon set CUSTOM/universium/wireFine, GT icon set CUSTOM/universium/wireFine_OVERLAY |
| `infinity-foil` | GT icon set CUSTOM/infinity/foil |
| `infinity-frame` | GT block set CUSTOM/infinity/frameGt |
| `infinity-gear` | GT icon set CUSTOM/infinity/gearGtSmall |
| `infinity-ring` | GT icon set CUSTOM/infinity/ring, GT icon set CUSTOM/infinity/ring_OVERLAY |
| `infinity-rod` | GT icon set CUSTOM/infinity/stick |
| `infinity-rotor` | GT icon set CUSTOM/infinity/rotor |
| `infinity-round` | GT icon set CUSTOM/infinity/round |
| `infinity-screw` | GT icon set CUSTOM/infinity/screw |
| `large-infinity-gear` | GT icon set CUSTOM/infinity/gearGt |
| `large-spacetime-gear` | GT icon set CUSTOM/spacetime/gearGt |
| `large-transcendent-metal-gear` | colour of TranscendentMetal #323232, GT icon set NONE/gearGt |
| `large-universium-gear` | colour of Universium #263145, GT icon set CUSTOM/universium/gearGt |
| `long-infinity-rod` | GT icon set CUSTOM/infinity/stickLong |
| `long-spacetime-rod` | GT icon set CUSTOM/spacetime/stickLong |
| `long-transcendent-metal-rod` | colour of TranscendentMetal #323232, GT icon set NONE/stickLong |
| `long-universium-rod` | colour of Universium #263145, GT icon set CUSTOM/universium/stickLong |
| `nether-star-cable` |  |
| `nether-star-rod` | GT icon set NETHERSTAR/stick, GT icon set NETHERSTAR/stick_OVERLAY |
| `nether-star-wire` |  |
| `rhugnor-ingot` | colour of rhugnor #be00ff, GT icon set CUSTOM/rhugnor/ingot, GT icon set CUSTOM/rhugnor/ingot_OVERLAY |
| `rhugnor-plate` | colour of rhugnor #be00ff, GT icon set CUSTOM/rhugnor/plate, GT icon set CUSTOM/rhugnor/plate_OVERLAY |
| `spacetime-cable` | GT icon set CUSTOM/spacetime/ingot, colour of SpaceTime #361b47 |
| `spacetime-foil` | GT icon set CUSTOM/spacetime/foil |
| `spacetime-frame` | GT block set CUSTOM/spacetime/frameGt |
| `spacetime-gear` | GT icon set CUSTOM/spacetime/gearGtSmall |
| `spacetime-ingot` | GT icon set CUSTOM/spacetime/ingot |
| `spacetime-plate` | GT icon set CUSTOM/spacetime/plate |
| `spacetime-ring` | GT icon set CUSTOM/spacetime/ring, GT icon set CUSTOM/spacetime/ring_OVERLAY |
| `spacetime-rod` | GT icon set CUSTOM/spacetime/stick |
| `spacetime-rotor` | GT icon set CUSTOM/spacetime/rotor |
| `spacetime-round` | GT icon set CUSTOM/spacetime/round |
| `spacetime-screw` | GT icon set CUSTOM/spacetime/screw |
| `spacetime-wire` | GT icon set CUSTOM/spacetime/ingot, colour of SpaceTime #361b47 |
| `transcendent-metal-foil` | colour of TranscendentMetal #323232, GT icon set NONE/foil |
| `transcendent-metal-frame` | colour of TranscendentMetal #323232, GT block set NONE/frameGt |
| `transcendent-metal-gear` | colour of TranscendentMetal #323232, GT icon set NONE/gearGtSmall |
| `transcendent-metal-ingot` | colour of TranscendentMetal #323232, GT icon set METALLIC/ingot |
| `transcendent-metal-plate` | colour of TranscendentMetal #323232, GT icon set METALLIC/plate |
| `transcendent-metal-ring` | colour of TranscendentMetal #323232, GT icon set METALLIC/ring, GT icon set METALLIC/ring_OVERLAY |
| `transcendent-metal-rod` | colour of TranscendentMetal #323232, GT icon set NONE/stick |
| `transcendent-metal-rotor` | colour of TranscendentMetal #323232, GT icon set NONE/rotor |
| `transcendent-metal-round` | colour of TranscendentMetal #323232, GT icon set NONE/round |
| `transcendent-metal-screw` | colour of TranscendentMetal #323232, GT icon set NONE/screw |
| `universium-cable` | colour of Universium #263145 |
| `universium-foil` | colour of Universium #263145, GT icon set CUSTOM/universium/foil |
| `universium-frame` | colour of Universium #263145, GT block set NONE/frameGt |
| `universium-gear` | colour of Universium #263145, GT icon set CUSTOM/universium/gearGtSmall |
| `universium-ingot` | colour of Universium #263145, GT icon set CUSTOM/universium/ingot |
| `universium-plate` | colour of Universium #263145, GT icon set CUSTOM/universium/plate |
| `universium-ring` | colour of Universium #263145, GT icon set CUSTOM/universium/ring, GT icon set CUSTOM/universium/ring_OVERLAY |
| `universium-rod` | colour of Universium #263145, GT icon set CUSTOM/universium/stick |
| `universium-rotor` | colour of Universium #263145, GT icon set CUSTOM/universium/rotor |
| `universium-round` | colour of Universium #263145, GT icon set CUSTOM/universium/round |
| `universium-screw` | colour of Universium #263145, GT icon set CUSTOM/universium/screw |
| `universium-wire` | colour of Universium #263145 |

### UV and UHV metals (50)

[`icons-19-uv-and-uhv-metals.png`](icons-19-uv-and-uhv-metals.png)

| Item | Made from |
|---|---|
| `americium-ingot` | colour of Americium #c8c8c8, GT icon set METALLIC/ingot |
| `americium-plate` | colour of Americium #c8c8c8, GT icon set METALLIC/plate |
| `dense-naquadah-alloy-plate` | colour of NaquadahAlloy #282828, GT icon set NONE/plateDense |
| `dense-osmiridium-plate` | colour of Osmiridium #6464ff, GT icon set NONE/plateDense |
| `fine-americium-wire` | colour of Americium #c8c8c8, GT icon set NONE/wireFine, GT icon set NONE/wireFine_OVERLAY |
| `fine-tritanium-wire` | colour of Tritanium #600000, GT icon set NONE/wireFine, GT icon set NONE/wireFine_OVERLAY |
| `large-naquadah-alloy-gear` | colour of NaquadahAlloy #282828, GT icon set NONE/gearGt |
| `large-neutronium-gear` | colour of Neutronium #fafafa, GT icon set NONE/gearGt |
| `large-tritanium-gear` | colour of Tritanium #600000, GT icon set NONE/gearGt |
| `long-naquadah-alloy-rod` | colour of NaquadahAlloy #282828, GT icon set NONE/stickLong |
| `long-neutronium-rod` | colour of Neutronium #fafafa, GT icon set NONE/stickLong |
| `long-tritanium-rod` | colour of Tritanium #600000, GT icon set NONE/stickLong |
| `naquadah-alloy-bolt` | colour of NaquadahAlloy #282828, GT icon set NONE/bolt |
| `naquadah-alloy-cable` | colour of NaquadahAlloy #282828 |
| `naquadah-alloy-foil` | colour of NaquadahAlloy #282828, GT icon set NONE/foil |
| `naquadah-alloy-frame` | colour of NaquadahAlloy #282828, GT block set NONE/frameGt |
| `naquadah-alloy-gear` | colour of NaquadahAlloy #282828, GT icon set NONE/gearGtSmall |
| `naquadah-alloy-nugget` | colour of NaquadahAlloy #282828, GT icon set METALLIC/nugget |
| `naquadah-alloy-ring` | colour of NaquadahAlloy #282828, GT icon set METALLIC/ring, GT icon set METALLIC/ring_OVERLAY |
| `naquadah-alloy-rod` | colour of NaquadahAlloy #282828, GT icon set NONE/stick |
| `naquadah-alloy-round` | colour of NaquadahAlloy #282828, GT icon set NONE/round |
| `naquadah-alloy-screw` | colour of NaquadahAlloy #282828, GT icon set NONE/screw |
| `naquadah-alloy-wire` | colour of NaquadahAlloy #282828 |
| `naquadah-cable` | colour of Naquadah #323232 |
| `naquadah-plate` | colour of Naquadah #323232, GT icon set METALLIC/plate |
| `naquadria-plate` | colour of Naquadria #1e1e1e, GT icon set SHINY/plate, GT icon set SHINY/plate_OVERLAY |
| `neutronium-frame` | colour of Neutronium #fafafa, GT block set NONE/frameGt |
| `neutronium-gear` | colour of Neutronium #fafafa, GT icon set NONE/gearGtSmall |
| `neutronium-ring` | colour of Neutronium #fafafa, GT icon set NONE/ring, GT icon set NONE/ring_OVERLAY |
| `neutronium-rod` | colour of Neutronium #fafafa, GT icon set DULL/stick |
| `neutronium-rotor` | colour of Neutronium #fafafa, GT icon set NONE/rotor |
| `neutronium-round` | colour of Neutronium #fafafa, GT icon set NONE/round |
| `neutronium-screw` | colour of Neutronium #fafafa, GT icon set NONE/screw |
| `osmiridium-rod` | colour of Osmiridium #6464ff, GT icon set NONE/stick |
| `rhodium-plated-palladium-dust` | colour of rhodium-plated-palladium #dcdcf0, GT icon set SHINY/dust, GT icon set SHINY/dust_OVERLAY |
| `ruridit-plate` | colour of ruridit #a4a4a4, GT icon set METALLIC/plate |
| `superdense-americium-plate` | colour of Americium #c8c8c8, GT icon set NONE/plateSuperdense |
| `superdense-europium-plate` | colour of Europium #f6b5ff, GT icon set SHINY/plateSuperdense, GT icon set SHINY/plateSuperdense_OVERLAY |
| `superdense-neutronium-plate` | colour of Neutronium #fafafa, GT icon set NONE/plateSuperdense |
| `trinium-foil` | colour of Trinium #c8c8d2, GT icon set NONE/foil |
| `tritanium-cable` | colour of Tritanium #600000 |
| `tritanium-foil` | colour of Tritanium #600000, GT icon set NONE/foil |
| `tritanium-frame` | colour of Tritanium #600000, GT block set NONE/frameGt |
| `tritanium-gear` | colour of Tritanium #600000, GT icon set NONE/gearGtSmall |
| `tritanium-plate` | colour of Tritanium #600000, GT icon set METALLIC/plate |
| `tritanium-ring` | colour of Tritanium #600000, GT icon set METALLIC/ring, GT icon set METALLIC/ring_OVERLAY |
| `tritanium-rod` | colour of Tritanium #600000, GT icon set NONE/stick |
| `tritanium-rotor` | colour of Tritanium #600000, GT icon set NONE/rotor |
| `tritanium-round` | colour of Tritanium #600000, GT icon set NONE/round |
| `tritanium-screw` | colour of Tritanium #600000, GT icon set NONE/screw |

### Other materials (20)

[`icons-20-other-materials.png`](icons-20-other-materials.png)

| Item | Made from |
|---|---|
| `enderium-ingot` | colour of Enderium #599187, GT icon set NONE/ingot |
| `enderium-plate` | colour of Enderium #599187, GT icon set NONE/plate |
| `hsss-bolt` | colour of HSSS #660033, GT icon set NONE/bolt |
| `hsss-frame` | colour of HSSS #660033, GT block set NONE/frameGt |
| `hsss-gear` | colour of HSSS #660033, GT icon set NONE/gearGtSmall |
| `hsss-nugget` | colour of HSSS #660033, GT icon set METALLIC/nugget |
| `hsss-plate` | colour of HSSS #660033, GT icon set METALLIC/plate |
| `hsss-ring` | colour of HSSS #660033, GT icon set METALLIC/ring, GT icon set METALLIC/ring_OVERLAY |
| `hsss-rod` | colour of HSSS #660033, GT icon set NONE/stick |
| `hsss-rotor` | colour of HSSS #660033, GT icon set NONE/rotor |
| `hsss-round` | colour of HSSS #660033, GT icon set NONE/round |
| `hsss-screw` | colour of HSSS #660033, GT icon set NONE/screw |
| `large-hsss-gear` | colour of HSSS #660033, GT icon set NONE/gearGt |
| `long-hsss-rod` | colour of HSSS #660033, GT icon set NONE/stickLong |
| `long-magnetic-samarium-rod` | colour of SamariumMagnetic #ffffcc, GT icon set MAGNETIC/stickLong, GT icon set MAGNETIC/stickLong_OVERLAY |
| `magnetic-samarium-rod` | colour of SamariumMagnetic #ffffcc, GT icon set MAGNETIC/stick, GT icon set MAGNETIC/stick_OVERLAY |
| `niobium-titanium-foil` | colour of NiobiumTitanium #1d1d29, GT icon set NONE/foil |
| `niobium-titanium-wire-4x` | colour of NiobiumTitanium #1d1d29 |
| `samarium-rod` | colour of Samarium #ffffcc, GT icon set NONE/stick |
| `vanadium-gallium-cable` | colour of VanadiumGallium #80808c |
