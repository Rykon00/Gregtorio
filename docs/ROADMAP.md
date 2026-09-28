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
| 3 | UV: UV circuit (crystal processor mainframe), ZPM assembly line, UV components, fusion reactor MK2 and its plasmas, UV science pack, UV energy hatch and machines | **done** (`prototypes/127-fork-uv.lua`) |
| 4 | UHV: fusion reactor MK3, wetware processors (UHV circuit), UHV components | open, next |
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

### Suggested next step (done in phase 3)

Phase 3 (UV): fusion reactor MK2 (the `mk2-fusion-reactor-recipes` plasmas stay hidden until
then), the UV circuit (crystal processor mainframe or wetware), the UV components (naquadah alloy
cable, UV energy hatch), UV machines with `fork_make_tier_machine(base, "zpm", "uv", ...)` and the
UV science pack (`agricultural-science-pack`). Switch the ZPM field generator to UV circuits then.

## Phase 3: UV (done)

Numbers: researchable technologies 252 -> 264 of 303 -> 313 (the 10 new ones, plus `tree-seeding` and
`electromagnetic-science-pack`, which needed the UV science pack), draft recipes hidden by the draft guard
65 -> 46 (19 became real recipes), auto-unlocked recipes 53 -> 53 (nothing moved, see below), machines
placed by `devcheck runtime` 287 -> 325. Progression now stops at the UHV science pack
(`electromagnetic-science-pack` is researchable but the pack has no recipe yet).

`25-uv-age-item.lua` is still not loaded by `data.lua` (not valid Lua, mostly later tiers); the UV parts
are rebuilt in `127-fork-uv.lua` after the GT5-Unofficial recipes.

New technologies:

| Technology | Science | Unlocks |
|---|---|---|
| `zpm-superconductors` | LuV | palladium-naqindium superconductor (dust, blast furnace, wire, cooled wire), molten naquadah, the alternative ZPM superconducting coil block |
| `crystal-processor-mainframes` | ZPM | ITBTC alloy and its wire, the LuV superconductor wire, crystal processor mainframe (the UV circuit), ZPM field generator (moved here from `zpm-components`) |
| `zpm-assembly-line` | ZPM | ZPM assembly line, naquadah alloy foil, palladium ingot and foil, lapotron crystal chain, lapotronic energy orb cluster |
| `fusion-reactor-mk2` | ZPM | superdense europium plate, fusion machine casing, fusion reactor MK2 controller and reactor |
| `fusion-plasmas-mk2` | ZPM | molten aluminium, beryllium, titanium, silver, silicon, chrome, cobalt, lutetium (from the rare earth line), americium, tritanium, and the sulfur, nitrogen, zinc, niobium, tin, titanium, oxygen and krypton plasmas |
| `uv-materials` | ZPM | naquadria (ingot, melt, plate, foil), naquadah plate, naquadah alloy wire and cable, neutronium (melt from fusion, ingot, plate, rod, long rod, ring, round, gear, large gear, screw, rotor, frame), americium (ingot, plate, fine wire), gravistar |
| `uv-components` | ZPM | UV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator (all from the ZPM assembly line), osmium plate, UV casing and hull |
| `uv-machines` | UV | the 23 basic machines one tier up (`uv-macerator`, `uv-assembling-machine`, ...) |
| `uv-energy-hatches` | UV | naquamiridium superconductor, trinium wire and coil, UV voltage coil, UV energy hatch, the alternative UV superconducting coil block |
| `uv-multiblocks` | UV | the 13 multiblock upgrades (EBF with trinium coils, vacuum freezer, large chemical reactor, ...) |

Changed technologies: `agricultural-science-pack` (the UV science tech) unlocks `uv-science-pack` and requires
`uv-components`; `zpm-energy-hatches` requires `zpm-superconductors`; `zpm-materials` also unlocks the
enderium recipes; `electromagnetic-science-pack` (UHV science) requires `uv-multiblocks`.

The UV science pack (`uv-science-pack`: UV motor, 2 UV circuits, 4 neutronium plates, 4 naquadah coils, a ZPM
field generator and molten naquadria -> 10 packs) is made in the ZPM assembling machine.

Auto-unlock: `FORK-AUTOUNLOCK` is identical to phase 2 (no unlock lost its old tech). The UV multiblock
upgrades give the replaced naquadah coils back, but `naquadah-coil-block` is unlocked explicitly in
`zpm-energy-hatches` since phase 2, so it stays there. Two chains that the auto-unlock would have pulled
into new techs are listed explicitly instead: the osmium plate (`uv-components`) and the lapotron crystal
chain (`zpm-assembly-line`).

Choices and deviations from GT:

- **UV circuit = crystal processor mainframe.** In GT the crystal line runs IV .. UV (mainframe) and the
  wetware line LuV .. UHV: the wetware processor mainframe is the *UHV* circuit and the UV one is the wetware
  supercomputer. The mainframe is a single recipe on the circuit assembly line and closes with the fork's own
  ITBTC/enderium superconductor draft; wetware (bacterial vat, mutagen) belongs to phase 4 where it is needed
  for UHV circuits.
- **Fusion.** MK2 is the ZPM tier as in GT (16 ZPM energy hatches, UV circuits in the controller). Americium is
  GT's lutetium + chrome. Lutetium comes from depleted thorium fuel rods in GT, which needs a nuclear reactor
  the fork does not have: it is a by-product of the rare earth line here (like zirconium in
  `100-fork-fixes.lua`). Neutronium is GT's americium + naquadria, which is a *MK3* recipe (600M EU threshold);
  the MK3 needs UHV circuits, so it runs in the MK2 for now. Times of the plasmas are the drafts'; americium
  takes 5 s per ingot.
- **Superconductors** are cooled like the IV one: a batch of base wire, one pump of the tier, a melt of the
  tier's pipe metal (enderium LuV, naquadah ZPM, neutronium UV) and cryogenic helium. The ZPM base alloy is
  blasted in the LuV blast furnace and the UV base in the ZPM one: each tier's own blast furnace needs that
  tier's energy hatch, which needs the superconductor. Enderium is made without thaumium and ender pearl dust
  (4 dusts -> 4 ingots) and solidifies in a vacuum freezer (a fluid solidifier has no output for the helium).
- **UV components** follow GT with these changes: the pump uses naquadah plates instead of the large naquadah
  pipe; the field generator needs 8 UV circuits instead of 4 UHV circuits (none before phase 4). The assembly
  line recipes take 30 GT seconds; the ZPM assembly line runs at speed 32 (twice the LuV one), so a component
  takes a minute.
- **UV voltage coil** uses fine americium wire instead of fluxed electrum (not in Gregtorio); the trinium coil
  (UV blast furnace) is the draft with `enriched-naquadah-foil`.
- **No PPIC/NPIC chips.** Their wafers need the europium and americium doped silicon, which needs grade 4 and
  6 water (the water purification side quest). The MK2 controller and the UV energy hatch use UHPIC wafers and
  chips, like the ZPM hatch did.
- Superdense europium plates (MK2 controller) are 64 plates in the ZPM compressor.
- Palladium had no ingot recipe (only the dust); a dust smelter recipe was added for the palladium foil of the
  multilayered circuit board (lapotronic energy orb cluster).
- Molten copper had only the foundry recipe from copper ore, which does not exist here: an extractor recipe
  (`molten-copper-extraction`) was added for the zinc plasma.

Closed open points from phase 2: the ZPM field generator uses 4 UV circuits, the ZPM energy hatch the ZPM
superconductor, the ZPM pump enderium plates (GT: enderium pipe), and the ZPM assembly line exists.
Existing saves that already researched `zpm-components` lose the ZPM field generator recipe until they research
`crystal-processor-mainframes` (it needs UV circuits now).

### Open points from phase 3

- Wetware processors (UHV circuit) and the UHV field generator: phase 4. The UV field generator stays on 8 UV
  circuits until then.
- PPIC and NPIC chips need the water purification line; the MK2 controller and the ZPM/UV hatches use UHPICs.
- Still drafts: force plasma (arcanite), astral titanium and runite plasma, the liquid fuels and the naquadah
  fuel (`excited-*-liquid-fuel`, `naquadah-based-fuel-mk1`), `advanced-fusion-coil` (needs the UHV emitter).
- `fusion-machine-casing-mk2` is a real recipe now (americium plate) but no tech unlocks it: it belongs to the MK3.
- Plasmas are still only ingredients; there is no plasma generator.
- Balance: the lutetium yield (4 rare earth dust -> 1 lutetium) and the 384 fine americium wires per UV motor make
  the UV motor the bottleneck (48 americium ingots = 4 minutes of one MK2 reactor). Nothing was tuned in game.
- Still unused from `25-uv-age-item.lua`: research station, draconic fusion crafter tiers, nano forge, bio
  processors, cosmic neutronium, component assembly line, UV dynamo hatch.
- Graphics: the UV basic machine sprites are generated from GT textures (tinted green), the MK2 reactor uses the
  GT fusion casing MK2 texture, item and technology icons are recolored placeholders (`tools/gen_icons.py`).

### Suggested next step

Phase 4 (UHV): fusion reactor MK3 (`fusion-machine-casing-mk2` is ready; move the neutronium recipe there), the
wetware line for the UHV circuit (bacterial vat and mutagen from phase 1: wetware circuit board, neuro processing
unit, wetware processor mainframe), UHV components, UHV energy hatch and machines with
`fork_make_tier_machine(base, "uv", "uhv", ...)`, and the UHV science pack (`electromagnetic-science-pack`). Then
switch the UV field generator to UHV circuits.
