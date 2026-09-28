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
| 4 | UHV: wetware processors (UHV circuit), UHV components, fusion reactor MK3, UHV science pack, energy hatch and machines | **done** (`prototypes/128-fork-uhv.lua`) |
| 5 | UEV .. UXV and the endgame (stargate, victory) | open, next |
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

### Suggested next step (done in phase 4)

Phase 4 (UHV): fusion reactor MK3 (`fusion-machine-casing-mk2` is ready; move the neutronium recipe there), the
wetware line for the UHV circuit (bacterial vat and mutagen from phase 1: wetware circuit board, neuro processing
unit, wetware processor mainframe), UHV components, UHV energy hatch and machines with
`fork_make_tier_machine(base, "uv", "uhv", ...)`, and the UHV science pack (`electromagnetic-science-pack`). Then
switch the UV field generator to UHV circuits.

## Phase 4: UHV (done)

Numbers: researchable technologies 264 -> 274 of 313 -> 322 (the 9 new ones, plus `cryogenic-science-pack`, the
UEV science tech, which is now reachable but whose pack has no recipe yet), draft recipes hidden by the draft
guard 46 -> 41 (5 became real recipes), auto-unlocked recipes 53 -> 53 (nothing moved, see below), machines placed
by `devcheck runtime` 325 -> 362. Progression now stops at the UEV science pack (`cryogenic-science-pack`).

`27-uhv-age-item.lua` is still not loaded by `data.lua` (not valid Lua, mostly later tiers); the UHV parts are
rebuilt in `128-fork-uhv.lua` after the GT5-Unofficial recipes.

New technologies:

| Technology | Science | Unlocks |
|---|---|---|
| `uhv-materials` | UV | tritanium (ingot, plate, rod, long rod, frame, gear, large gear, ring, round, screw, rotor, wire, fine wire, foil) and the tritanium cable |
| `wetware-processors` | UV | stem cells, wetware printed circuit board, neuro processing unit, wetware processor, assembly and supercomputer |
| `wetware-processor-mainframes` | UV | wetware processor mainframe (the UHV circuit) |
| `uhv-components` | UV | UHV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator (all from the ZPM assembly line), UHV casing and hull, superdense americium plate |
| `uhv-machines` | UHV | the 23 basic machines one tier up (`uhv-macerator`, `uhv-assembling-machine`, ...) |
| `uhv-energy-hatches` | UHV | triamerotronium (dust, blast furnace, wire, superconductive wire), the alternative UHV superconducting coil block, tritanium coil, UHV voltage coil, UHV energy hatch |
| `uhv-multiblocks` | UHV | the 13 multiblock upgrades (EBF with tritanium coils, vacuum freezer, large chemical reactor, ...) |
| `fusion-reactor-mk3` | UHV | fusion machine casing MK2, advanced fusion coil, fusion reactor MK3 controller and reactor |
| `fusion-plasmas-mk3` | UHV | molten neutronium (the fast MK3 recipe), iron plasma |

Changed technologies: `electromagnetic-science-pack` (the UHV science tech) unlocks `uhv-science-pack` and requires
`uhv-components`; `cryogenic-science-pack` (UEV science) requires `uhv-multiblocks` and `fusion-plasmas-mk3`;
`uv-materials` unlocks the slow neutronium recipe instead of the fast one.

The UHV science pack (`uhv-science-pack`: UHV motor, 2 UHV circuits, 4 tritanium plates, 4 trinium coils, a UV
field generator and molten tritanium -> 10 packs) is made in the UV assembling machine.

Auto-unlock: `FORK-AUTOUNLOCK` is identical to phase 3 (no unlock lost its old tech). The UHV multiblock upgrades
give the replaced ZPM energy hatches and trinium coils back, but both are unlocked explicitly by their own techs
since phases 2 and 3.

Choices and deviations from GT:

- **Wetware line** (GT: LuV .. UHV, the mainframe is the UHV circuit). Follows the shape of the crystal line (circuit
  assembly line, 16 circuits per craft, 2 of the previous stage per circuit): stem cells -> wetware board + neuro
  processing unit -> wetware processor (also takes the crystal CPU) -> assembly -> supercomputer -> mainframe. GT breeds
  stem cells from an unknown crystal (GalaxySpace): 2 raw crystal chip parts stand in for it, and the vat's growth
  medium and bacterial sludge (the recipe returns the sludge) are used. Bio cells (UV, cosmic neutronium dust) are left
  out. No complex SMDs (water purification line), no ytterbium wire (niobium-titanium), the mainframe uses the UV
  superconductor wire. The wetware stages are separate items; the UV circuit is still the crystal mainframe. One UHV
  circuit costs about one craft of stem cells (64 per craft: 2 chip parts, 2 osmiridium dust, 1000 growth medium).
- **Tritanium instead of cosmic neutronium and bedrockium.** Neither can be made (no cosmic neutronium line, no
  bedrockium microminer). The UHV motor, piston, robot arm, emitter, sensor and field generator use tritanium (the fusion
  MK2 already makes its melt), and the cable is tritanium cable (GT: bedrockium). The tritanium recipe of the MK2 was
  the draft's 16 mB in 16 s (one motor = 9 minutes of a reactor); it is 3 titanium + 2 duranium -> 1 ingot of melt in
  3 s now, and the large tritanium gear is 4 ingots (the generic large gear would be 40). The cable is 1 wire per cable
  like GT (the UV cable needed 4).
- **UHV superconductor: triamerotronium.** GT: draconium 6, cosmic neutronium 7, tritanium 5, americium 6. Draconium and
  cosmic neutronium do not exist: equal parts of tritanium, americium and neutronium. Cooled like the UV one (UHV pump,
  neutronium melt, cryogenic helium). It is used by the UHV energy hatch; the UHV hull uses the UV superconductor wire
  like the draft. This also activates the alternative `superconducting-coil-block-uhv`.
- **Neutronium: MK3, with a bootstrap.** GT's neutronium (americium + naquadria) is a MK3 recipe; the MK3 recipe is
  the one of GT here (1:1, 3 s per ingot in the reactor MK3). The MK3 is built from UV energy hatches and the UV pump
  needs neutronium, so a MK3-only recipe would be a dead end. The MK2 keeps `molten-neutronium-bootstrap`: 2 melt of
  americium and naquadria for 1 of neutronium, 12 s (before: 1:1, 12 s). Saves that researched `uv-materials` get the
  bootstrap recipe from it, and `molten-neutronium` (now the MK3 recipe) moves to `fusion-plasmas-mk3`.
- **Fusion reactor MK3.** UV tier as in GT (16 UV energy hatches, 32 UV hulls, 79 fusion casings MK2), UHV circuits in
  the controller, UHPIC wafers instead of QPIC wafers (like MK1 and MK2). The advanced fusion coil (draft: the MK4 coil with
  UU matter and UEV circuits) has a UHV emitter and sensor, tritanium and neutronium melt instead of cinobite, octiron,
  astral titanium and UU matter. The reactor takes 8 of them (GT: 32). Superdense americium plate: 64 plates in the UV
  compressor. Iron plasma (the only MK3 plasma draft) is active; its fluid did not exist and was added.
- **UHV components** follow GT with these changes: fine wire and foil counts cut (GT: 512 fine neutronium wires, 256
  fluxed electrum foils; here motor 48 fine wires, emitter and sensor 32 foils, field generator 64 fine wires), gravistar
  counts as in the UV parts, the field generator needs 8 UHV circuits instead of 4 UEV circuits (none before phase 5).
  The recipes are in the ZPM assembly line (no new line needed) and take 30 GT seconds: 1 minute per component.
- **UHV voltage coil** uses fine tritanium wire (draft). GT's UHV blast furnace coil is fluxed electrum (not in
  Gregtorio); the UHV multiblocks use a tritanium coil (16 wires, 8 foils, a melt) instead. The UHV energy hatch uses
  UHPICs instead of quantum power ICs and cryogenic helium instead of super coolant cells, like the UV hatch.

Existing saves (unlocks that changed):

- `uv-field-generator`: 4 UHV circuits instead of 8 UV circuits (as requested). The recipe stays unlocked by
  `uv-components`, so saves that had it keep it; it is craftable once the UHV circuit is.
- `molten-neutronium`: moved from `uv-materials` to `fusion-plasmas-mk3`; `uv-materials` unlocks the bootstrap recipe
  instead, so no save loses a way to make neutronium. Factorio re-applies the effects of researched techs on load.
- `electromagnetic-science-pack` (researched in saves that reached the UHV science pack) has a new prerequisite; a
  researched tech stays researched. Its pack recipe is new.
- Everything else only adds recipes. `migrate --from-ref 0e935ba` and `--from-ref 5dd7c92` (before this phase) load.

Bottlenecks of the UHV parts (tritanium is 14.4 melt per ingot, 3 s per ingot in one MK2 reactor; 1 ingot needs 3
titanium and 2 duranium melt):

| Part | Tritanium ingots | Other main inputs |
|---|---|---|
| UHV motor | 24 (1.2 min of a reactor) | 4 long magnetic samarium rods |
| UHV pump | 51 | motor, 12 neutronium plates |
| UHV conveyor module | 64 | 2 motors, 80 silicone rubber sheets |
| UHV piston | 64 | motor |
| UHV robot arm | 146 | 2 motors, piston, 2 UHV circuits |
| UHV emitter / sensor | 56 each | motor, 4 UHV circuits, 8 gravistars |
| UHV field generator | 256 (13 minutes) | 4 emitters, 8 UHV circuits |

The UV motor needs 48 americium ingots (4 minutes at 5 s per ingot), so a UHV motor is cheaper than the UV one; the
field generator is about as expensive as the UV one. One MK3 needs about 900 tritanium ingots for the 8 advanced
fusion coils, 64 UHV circuits for their emitters and sensors, and 380 americium plates (casings and the superdense
plate). The UHV circuit chain costs one stem cell craft per circuit: 16 circuits need 32 supercomputers, 64
assemblies, 128 processors, 128 neuro processing units, 128 crystal CPUs and 224 wetware boards. Nothing was tuned
in game.

### Open points from phase 4

- Still drafts: force plasma (arcanite), astral titanium and runite plasma, the liquid fuels and the naquadah fuel,
  the MK4 and MK5 reactors (`fusion-reactor-mk4-controller` needs UEV circuits, `fusion-machine-casing-mk3` a category
  typo `uvh-...`, `advanced-fusion-coil-ii` the energy module), the UEV, UIV and UMV superconductor coil blocks,
  bio cells.
- PPIC, NPIC and QPIC chips (water purification line) and complex SMDs: the MK3 controller, the ZPM to UHV hatches and
  the wetware mainframe use UHPICs and advanced SMDs.
- Plasmas (also iron plasma) are still only ingredients; there is no plasma generator.
- No fluxed electrum, draconium, cosmic neutronium or bedrockium: tritanium and triamerotronium stand in for them.
- The UV energy hatch cooling and the UHV one use cryogenic helium; there are no super coolant cells (draft
  `super-coolant` needs callisto ice).
- Still unused from `27-uhv-age-item.lua`: UHV dynamo hatch, awakened draconium coil block (UEV), attuned tengam
  microminer, integrated ore factory, neutronium compressor, singularities.
- Graphics: the UHV basic machine sprites are generated from GT textures (tinted red), the MK3 reactor uses the GT
  fusion casing MK2 texture and the MK3 overlay, item and technology icons are recolored placeholders
  (`tools/gen_icons.py`); the wetware items and stem cells reuse unrelated neighbor icons and need real ones.
- Balance is untested in game (see the table above).

### Suggested next step

Phase 5 (UEV and up): the UEV science pack (`cryogenic-science-pack`) with UEV circuits (bioware / bio processors: bio
cells and the bio mainframe on top of the wetware line, plus the water purification line for the wafers), UEV
components, UEV machines with `fork_make_tier_machine(base, "uhv", "uev", ...)` (the shift rules need a `uev` table),
fusion MK4 (`advanced-fusion-coil` is ready, the MK4 needs UEV hatches and casing MK3 with its category typo fixed),
and the materials the drafts expect (cosmic neutronium, bedrockium, fluxed electrum, draconium, UU matter). The plasma
generator and the water purification line are the side quests that unlock most of the remaining drafts. Then UIV, UMV
and UXV follow the same recipe, ending with the stargate.
