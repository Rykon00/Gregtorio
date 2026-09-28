# Roadmap: GregTech: New Horizons progression

The goal is the GTNH progression (tier gating, key materials, the big multiblocks) on top of
the upstream Gregtorio drafts, adapted to Factorio: fewer steps where GT only adds tedium, same
order of tiers and the same key materials. One phase per pull request.

Every phase leaves the game playable: the tier's science pack is craftable, its techs are
researchable, every unlocked recipe can be made, and everything unfinished stays a hidden
draft (`FORK-DRAFT` in the log). Checked with `tools/devcheck` (see its README).

Science packs: LuV = space, ZPM = metallurgic, UV = agricultural, UHV = electromagnetic,
UEV = cryogenic, then promethium / UMV / UXV / max.

| Phase | Content | Status |
|---|---|---|
| 1 | Finish LuV: naquadah ore line, bacterial vat, mutagen, crystal processors, circuit assembly line, fusion reactor MK1 and the first plasmas | **done** (`prototypes/125-fork-luv-endgame.lua`) |
| 2 | ZPM: ZPM science pack, ZPM components and machines (europium, naquadah alloy, osmiridium), ZPM energy hatch | **done** (`prototypes/126-fork-zpm.lua`) |
| 3 | UV: fusion reactor MK2 (and its plasmas), wetware processors, crystal processor mainframe (UV circuit), UV components | open, next |
| 4 | UHV: fusion reactor MK3, UHV components and circuits | open |
| 5 | UEV .. UXV and the endgame (stargate, victory) | open |
| side | Water purification line (grades 1-8; the draft in `21-luv-age-item.lua` is commented out) | open |
| side | AE2 autocrafting (patterns, molecular assembler on top of the ME network from `120-fork-ae2.lua`) | open |

## Phase 1: LuV (done)

Numbers: researchable technologies 238 -> 246 of 290 -> 298 (the 8 new ones), draft recipes
hidden by the draft guard 88 -> 65. Progression now stops at the ZPM science pack
(`metallurgic-science-pack` is researchable but the pack has no recipe yet).

New technologies (all LuV science):

| Technology | Unlocks |
|---|---|
| `naquadah-processing` | naquadah from the end microminer, the GoodGenerator line (fluoroantimonic acid, emulsion, P-507, neutron activator), naquadah ingot and dust |
| `enriched-naquadah` | enriched naquadah, naquadria dust, trinium |
| `naquadah-alloy` | naquadah alloy (alloy blast smelter), osmiridium, their plates and dense plates |
| `bacterial-vat` | bacterial vat, growth medium, bacterial sludge, enriched sludge, mutagen |
| `circuit-assembly-line` | circuit assembly line (crystal processors, also every circuit assembler recipe up to LuV) |
| `crystal-processors` | emerald plates, raw/engraved crystal chips, crystal CPU, circuit wraps, crystal processor (IV), assembly (LuV), supercomputer (ZPM) |
| `fusion-reactor-mk1` | niobium-titanium foil, superconducting coil, fusion coil, fusion reactor MK1 |
| `fusion-plasmas-mk1` | tritium (from deuterium), helium-3 (from end stone), helium, boron, calcium and neon plasma, europium, duranium, sunnarium |

`metallurgic-science-pack` (the ZPM science tech) now requires `fusion-plasmas-mk1` and
`crystal-processors`.

### Open points from phase 1

- Still drafts, need later tiers: crystal processor mainframe (UV circuit, ITBTC/enderium
  superconductor wire), force plasma (arcanite), all MK2+ fusion recipes, lapotronic energy orb
  cluster (qubit processing unit, naquadah alloy foil), the naquadah fuel line
  (`acid-naquadah-emulsion`, naquadah fuels for the naquadah generator).
- Plasmas are only ingredients so far; there is no plasma generator (GT plasma turbine).
- Fusion in GT needs a start-up energy buffer per recipe; here it is a normal machine with a
  high power draw (40.96 MW).
- Balance: the assembly line now runs at IV speed (16) instead of 1, so assembly line recipes take
  GT time (a LuV motor took 8 minutes before); the circuit assembly line runs at 2x LuV speed.
- Graphics of the new multiblocks are generated placeholders from GT textures
  (`tools/gen_sprites.py`); they need a look in the real game.

Outside the phases: some vanilla technologies (armor equipment, inserter capacity bonus,
`bulk-inserter`, `explosives`, ...) are not researchable in `devcheck`; that was already the case
before phase 1 and has not been looked into yet.

### Suggested next step (done in phase 2)

Phase 2 (ZPM): ZPM science pack recipe (europium, naquadah alloy, ZPM circuit), ZPM components
from the drafts in `23-zpm-age-item.lua`, ZPM machines with `fork_make_tier_machine(base, "luv",
"zpm", ...)` and the ZPM energy hatch. The MK2 plasma drafts stay hidden until phase 3 (fusion MK2).

## Phase 2: ZPM (done)

Numbers: researchable technologies 246 -> 252 of 298 -> 303 (the 5 new ones and
`agricultural-science-pack`, the UV science tech, which is now reachable but whose pack has no recipe
yet), draft recipes hidden by the draft guard 65 -> 65, auto-unlocked recipes 67 -> 53 (14 are now
unlocked explicitly, see below), machines placed by `devcheck runtime` 251 -> 287. Progression now
stops at the UV science pack (`agricultural-science-pack`).

`23-zpm-age-item.lua` is still not loaded by `data.lua`: it is not valid Lua (missing commas, bare
table literals) and most of it belongs to later tiers. Its ZPM parts are rebuilt in
`126-fork-zpm.lua` after the GT5-Unofficial recipes.

New technologies:

| Technology | Science | Unlocks |
|---|---|---|
| `zpm-materials` | LuV | naquadah alloy rod, long rod, ring, nugget, round, bolt, screw, gear, large gear, rotor, frame; europium plate and fine wire; trinium foil; osmiridium rod; naquadah wire and cable |
| `zpm-components` | LuV | ZPM motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator (LuV assembly line), ZPM machine casing (iridium) and hull |
| `zpm-machines` | ZPM | the 23 basic machines one tier up (`zpm-macerator`, `zpm-assembling-machine`, ...) |
| `zpm-energy-hatches` | ZPM | osmium ingot and foil, naquadah coil, ZPM voltage coil, ZPM energy hatch |
| `zpm-multiblocks` | ZPM | the 13 multiblock upgrades (EBF with naquadah coils, vacuum freezer, large chemical reactor, distillation towers, ...) |

The ZPM science pack (`zpm-science-pack`: ZPM motor, 2 ZPM circuits, europium plates, dense naquadah
alloy plates, HSS-G coils, a LuV field generator and molten naquadah alloy -> 10 packs) is unlocked
by `metallurgic-science-pack`, which now also requires `zpm-components`. `agricultural-science-pack`
(UV science) requires `zpm-multiblocks`.

Auto-unlock: two chains would have changed their tech, so they are unlocked explicitly now.
The HSS-G coil (with HSS-G wire and tungsten carbide foil) stays on `luv-machines`: the ZPM
multiblock upgrades give the replaced HSS-G coils back, which the auto-unlock counts as a producer.
The PBI chain stays on `advanced-smds`: the ZPM hull uses PBI sheets, and the auto-unlock visits
techs alphabetically in prerequisite order, so `agricultural-science-pack` pulled the ZPM techs in
first.

### Open points from phase 2

- Deviations from GT that later tiers can undo: the ZPM field generator uses 8 ZPM circuits
  instead of 4 UV circuits (none before phase 3); the ZPM pump uses osmiridium plates instead of
  the enderium pipe (no enderium line); the ZPM energy hatch uses UHPICs instead of NPICs, naquadah
  cable instead of the ZPM superconductor (`palladium-naqindium-superconductive-wire`, a draft) and
  cryogenic helium instead of coolant cells.
- No ZPM assembly line yet: the ZPM components and the energy hatch are LuV assembly line
  recipes (the assembly line runs at IV speed, so one component takes 60 s). The drafts that use
  `zpm-assembly-line-recipes` (energy module, hot isostatic pressurization unit, draconic fusion
  crafter) need one.
- Still unused from `23-zpm-age-item.lua`: ZPM dynamo hatch, trinium coil (UV), crystal matrix,
  energy module, black plutonium / bedrockium / neutronium microminers, hot isostatic
  pressurization unit, wetware processors, fusion MK2, draconic fusion crafter.
- Graphics: the ZPM basic machine sprites are generated from GT textures (tinted aqua); the
  multiblock upgrades keep the graphics of the LuV version; item icons are recolored placeholders
  (`tools/gen_icons.py`).
- Upgrade multiblocks return the replaced parts. In phase 3 the UV upgrades will return naquadah
  coils, so check the auto-unlock of the naquadah coil again.

### Suggested next step

Phase 3 (UV): fusion reactor MK2 (the `mk2-fusion-reactor-recipes` plasmas stay hidden until
then), the UV circuit (crystal processor mainframe or wetware), the UV components (naquadah alloy
cable, UV energy hatch), UV machines with `fork_make_tier_machine(base, "zpm", "uv", ...)` and the
UV science pack (`agricultural-science-pack`). Switch the ZPM field generator to UV circuits then.
