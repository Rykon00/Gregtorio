# Roadmap: GregTech: New Horizons progression

> Since issue #83 the ME network (the AE2 sections below: `120-122`, `scripts/fork-me-*.lua`, `docs/AE2.md`,
> `docs/ME-REWORK.md`, `tools/gen_ae2_sprites.py`) is the mod [me-network](https://github.com/Rykon00/me-network);
> the paths below are the ones of that time. Gregtorio keeps its recipes and tiers in
> `prototypes/120-fork-me-network-compat.lua` (`docs/SPLIT.md`).

The goal is the GTNH progression (tier gating, key materials, the big multiblocks) on top of
the upstream Gregtorio drafts, adapted to Factorio: fewer steps where GT only adds tedium, same
order of tiers and the same key materials. One phase per pull request.

Every phase leaves the game playable: the tier's science pack is craftable, its techs are
researchable, every unlocked recipe can be made, and everything unfinished stays a hidden
draft (`FORK-DRAFT` in the log). Checked with `tools/devcheck` (see its README).

Science packs: LuV = space, ZPM = metallurgic, UV = agricultural, UHV = electromagnetic,
UEV = cryogenic, UIV = promethium, then UMV / UXV / max (the stargate; since phase 6b also from MAX parts).

| Phase | Content | Status |
|---|---|---|
| 1 | Finish LuV: naquadah ore line, bacterial vat, mutagen, crystal processors, circuit assembly line, fusion reactor MK1 and the first plasmas | **done** (`prototypes/125-fork-luv-endgame.lua`) |
| 2 | ZPM: ZPM science pack, ZPM components and machines (europium, naquadah alloy, osmiridium), ZPM energy hatch | **done** (`prototypes/126-fork-zpm.lua`) |
| 3 | UV: UV circuit (crystal processor mainframe), ZPM assembly line, UV components, fusion reactor MK2 and its plasmas, UV science pack, UV energy hatch and machines | **done** (`prototypes/127-fork-uv.lua`) |
| 4 | UHV: wetware processors (UHV circuit), UHV components, fusion reactor MK3, UHV science pack, energy hatch and machines | **done** (`prototypes/128-fork-uhv.lua`) |
| 5a | UEV and UIV: bio and optical lines, cosmic neutronium / draconium / infinity / transcendent metal, UEV and UIV components, fusion MK4, science packs, energy hatches and machines | **done** (`prototypes/131-fork-uev.lua`, `132-fork-uiv.lua`) |
| 5b | UMV, UXV, MAX and the endgame (stargate, victory), fusion MK5 | **done** (`prototypes/133-fork-umv.lua`, `134-fork-uxv.lua`, `135-fork-endgame.lua`, `scripts/fork-victory.lua`) |
| side | Water purification line: grades 1-8, the NPIC to APIC chips and complex SMDs | **done** (`prototypes/129-fork-water-purification.lua`, see "Side quest: water purification grades 7 and 8") |
| side | AE2 autocrafting (patterns, molecular assembler on top of the ME network from `120-fork-ae2.lua`) and fluids in the ME network (fluid drives, fluid interface, fluid recipes as patterns) | **done** (`prototypes/121-fork-ae2-autocrafting.lua`, `122-fork-ae2-fluids.lua`, `scripts/fork-me-autocraft.lua`, `scripts/fork-me-fluids.lua`, `docs/AE2.md`) |
| side | AE2 extras (issue #38): level maintainer, crafting CPU tiers, circuit interface, fluid interface settings in blueprints | **done** (`prototypes/121-fork-ae2-autocrafting.lua`, `scripts/fork-me-circuit.lua`, see "AE2 extras" below) |
| side | Endgame power: plasma turbines (LuV to UXV, the UHV to UXV ones from issue #34), naquadah fuel line and large naquadah reactors, dynamo hatches LuV to UXV | **done** (`prototypes/136-fork-power.lua`, `scripts/fork-power.lua`, see "Side quest: endgame power") |
| side | Drafts and endgame materials: triage of every draft, super coolant, fluxed electrum, bedrockium, quantium (issues #39, #36) | **done** (`prototypes/137-fork-endgame-materials.lua`, see "Drafts and endgame materials") |
| side | Graphics: item and technology icons from GT textures instead of placeholders, own sprites for fusion MK4/MK5, a tier look for the UHV to UXV machines, plasma turbines and naquadah reactors (issues #40, #41) | **done** (`tools/gen_gt_icons.py`, `tools/gen_sprites.py`, review sheets and inventory in `docs/graphics-review/`) |
| 6a | Quantum force transformer and dimensionally transcendent plasma forge (issue #37, part 1) | **done** (`prototypes/139-fork-endgame-multiblocks.lua`, see "Phase 6a: QFT and DTPF") |
| 6b | MAX tier and the godforge (issue #37, part 2) | **done** (`prototypes/140-fork-godforge.lua`, `141-fork-max.lua`, see "Phase 6b: MAX tier and godforge") |
| side | Balance of the tiers from UHV up in the real game, and a look at the new graphics there | open |

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
  superconductor wire), ~~force plasma (arcanite)~~ (removed, issue #39), all MK2+ fusion recipes, ~~lapotronic energy orb
  cluster (qubit processing unit, naquadah alloy foil)~~ (issue #39, see "Drafts and endgame materials"), ~~the naquadah fuel line
  (`acid-naquadah-emulsion`, naquadah fuels for the naquadah generator)~~ (done in "Side quest: endgame power").
- ~~Plasmas are only ingredients so far; there is no plasma generator (GT plasma turbine).~~ Done in "Side quest: endgame power".
- Fusion in GT needs a start-up energy buffer per recipe; here it is a normal machine with a
  high power draw (40.96 MW).
- Balance: the assembly line now runs at IV speed (16) instead of 1, so assembly line recipes take
  GT time (a LuV motor took 8 minutes before); the circuit assembly line runs at 2x LuV speed.
- Graphics of the new multiblocks are generated placeholders from GT textures
  (`tools/gen_sprites.py`); they need a look in the real game.

Outside the phases: some vanilla technologies (armor equipment, inserter capacity bonus,
`bulk-inserter`, `explosives`, ...) are not researchable in `devcheck`; that was already the case
before phase 1 (listed and sorted in the final pass of phase 5b; the quality-of-life ones are researchable since issue #29).

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
  multiblock upgrades keep the graphics of the LuV version; item icons were recolored placeholders
  (`tools/gen_icons.py`), since issue #40 they come from GT textures (`tools/gen_gt_icons.py`).
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
- **UV voltage coil** uses ~~fine americium wire instead of fluxed electrum (not in Gregtorio)~~ fine fluxed electrum wire like GT since issue #36; the trinium coil
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
- Still drafts: ~~force plasma (arcanite), astral titanium and runite plasma~~ (removed, issue #39), ~~the liquid fuels and the naquadah
  fuel (`excited-*-liquid-fuel`, `naquadah-based-fuel-mk1`)~~ (done in "Side quest: endgame power"), `advanced-fusion-coil` (needs the UHV emitter).
- `fusion-machine-casing-mk2` is a real recipe now (americium plate) but no tech unlocks it: it belongs to the MK3.
- ~~Plasmas are still only ingredients; there is no plasma generator.~~ Done in "Side quest: endgame power".
- ~~Balance: the lutetium yield (4 rare earth dust -> 1 lutetium) and the 384 fine americium wires per UV motor make
  the UV motor the bottleneck (48 americium ingots = 4 minutes of one MK2 reactor).~~ Issue #31, see "Balance pass: endgame": 64 fine
  americium wires, the large neutronium gear 4 ingots, the lutetium yield kept on purpose.
- Still unused from `25-uv-age-item.lua`: research station, draconic fusion crafter tiers, nano forge, bio
  processors, cosmic neutronium, component assembly line, ~~UV dynamo hatch~~ (done in "Side quest: endgame power").
- Graphics: the UV basic machine sprites are generated from GT textures (tinted green), the MK2 reactor uses the
  GT fusion casing MK2 texture, item and technology icons were recolored placeholders (`tools/gen_icons.py`); since
  issue #40 they come from GT textures (`tools/gen_gt_icons.py`).

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
  MK2 already makes its melt), and the cable is tritanium cable (GT: bedrockium; bedrockium cable since issue #36). The tritanium recipe of the MK2 was
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
  UHPICs instead of quantum power ICs and cryogenic helium instead of super coolant cells, like the UV hatch (issue #36: GT's UHV
  hatch takes IC2 coolant, not super coolant, so the cryogenic helium stays).

Existing saves (unlocks that changed):

- `uv-field-generator`: 4 UHV circuits instead of 8 UV circuits (as requested). The recipe stays unlocked by
  `uv-components`, so saves that had it keep it; it is craftable once the UHV circuit is.
- `molten-neutronium`: moved from `uv-materials` to `fusion-plasmas-mk3`; `uv-materials` unlocks the bootstrap recipe
  instead, so no save loses a way to make neutronium. Factorio re-applies the effects of researched techs on load.
- `electromagnetic-science-pack` (researched in saves that reached the UHV science pack) has a new prerequisite; a
  researched tech stays researched. Its pack recipe is new.
- Everything else only adds recipes. `migrate --from-ref 0e935ba` and `--from-ref 5dd7c92` (before this phase) load.

Bottlenecks of the UHV parts (tritanium is 14.4 melt per ingot, 3 s per ingot in one MK2 reactor; 1 ingot needs 3
titanium and 2 duranium melt). **Before the balance pass:** these counts leave out the chain below the top metal (the two
duranium melts of a tritanium ingot take 58 s of an MK1); full-chain times in a reference factory are in "Balance pass: endgame":

| Part | Tritanium ingots | Other main inputs |
|---|---|---|
| UHV motor | 24 (1.2 min of a reactor) | 4 long magnetic samarium rods |
| UHV pump | 51 | motor, 12 neutronium plates |
| UHV conveyor module | 64 | 2 motors, 80 silicone rubber sheets |
| UHV piston | 64 | motor |
| UHV robot arm | 146 | 2 motors, piston, 2 UHV circuits |
| UHV emitter / sensor | 56 each | motor, 4 UHV circuits, 8 gravistars |
| UHV field generator | 256 (13 minutes) | 4 emitters, 8 UHV circuits |

~~The UV motor needs 48 americium ingots (4 minutes at 5 s per ingot), so a UHV motor is cheaper than the UV one~~ (full chain: the
UHV motor costs more, see "Balance pass: endgame"); the
field generator is about as expensive as the UV one. One MK3 needs about 900 tritanium ingots for the 8 advanced
fusion coils, 64 UHV circuits for their emitters and sensors, and 380 americium plates (casings and the superdense
plate). The UHV circuit chain costs one stem cell craft per circuit: 16 circuits need 32 supercomputers, 64
assemblies, 128 processors, 128 neuro processing units, 128 crystal CPUs and 224 wetware boards. Nothing was tuned
in game.

### Open points from phase 4

- Still drafts: ~~force plasma (arcanite), astral titanium and runite plasma~~ (removed, issue #39), ~~the liquid fuels and the naquadah fuel~~ (done in "Side quest: endgame power"),
  the MK4 and MK5 reactors (`fusion-reactor-mk4-controller` needs UEV circuits, `fusion-machine-casing-mk3` a category
  typo `uvh-...`, `advanced-fusion-coil-ii` the energy module), the UEV, UIV and UMV superconductor coil blocks,
  bio cells.
- ~~PPIC, NPIC and QPIC chips (water purification line) and complex SMDs: the MK3 controller, the ZPM to UHV hatches and
  the wetware mainframe use UHPICs and advanced SMDs.~~ Done in phase 5a and "Side quest: water purification grades 7 and 8".
- ~~Plasmas (also iron plasma) are still only ingredients; there is no plasma generator.~~ Done in "Side quest: endgame power".
- No ~~fluxed electrum~~, draconium, cosmic neutronium or ~~bedrockium~~: tritanium and triamerotronium stand in for them (fluxed electrum
  and bedrockium since issue #36; draconium and cosmic neutronium came in phase 5a).
- ~~The UV energy hatch cooling and the UHV one use cryogenic helium; there are no super coolant cells (draft
  `super-coolant` needs callisto ice).~~ Issue #36: super coolant and the 1080k super coolant cell exist; GT cools the UV and UHV hatches
  with IC2 coolant, so they keep cryogenic helium.
- Still unused from `27-uhv-age-item.lua`: ~~UHV dynamo hatch~~ (done in "Side quest: endgame power"), awakened draconium coil block (UEV), attuned tengam
  microminer, integrated ore factory, neutronium compressor, singularities.
- Graphics: the UHV basic machine sprites are generated from GT textures (tinted red), the MK3 reactor uses the GT
  fusion casing MK2 texture and the MK3 overlay, item and technology icons were recolored placeholders
  (`tools/gen_icons.py`) and the wetware items and stem cells reused unrelated neighbor icons. Since issues #40 and #41
  the icons come from GT textures and the UHV machines show the GT hull of their tier around the machine.
- Balance is untested in game (see the table above).

### Suggested next step (done in phase 5a)

Phase 5 (UEV and up) was split: 5a is UEV and UIV (below), 5b is UMV, UXV, MAX and the endgame.

## Phase 5a: UEV and UIV (done)

Numbers: researchable technologies 274 -> 296 of 322 -> 341 (the 19 new ones, plus `cryogenic-science-pack`,
`promethium-science-pack` and `umv-science-pack`, whose packs are now craftable or whose tier is reached), draft recipes hidden
by the draft guard 41 -> 36, auto-unlocked recipes 54 -> 54 (nothing moved, see below), machines placed by `devcheck runtime`
362 -> 436, unlocked but uncraftable recipes 0. Progression now stops at the UMV science pack (`umv-science-pack` is researchable
but the pack has no recipe yet).

`29-uev-age-item.lua` and `31-uiv-age-item.lua` are still not loaded (not valid Lua, mostly the quantum force transformer, the
dimensional plasma forge and the godforge); the parts of them that phase 5a needs are rebuilt in `131-fork-uev.lua` and
`132-fork-uiv.lua`. The molds file moved to `150-fork-molds.lua` to make room (it must load after every file that creates machines).

New technologies:

| Technology | Science | Unlocks |
|---|---|---|
| `water-purification` | LuV | activated carbon and mesh filter, ozone, polyaluminium chloride, water purification plant, grade 1 to 5 water |
| `nano-power-ics` | LuV | europium doped boule and wafer, NPIC wafer, NPIC chip (ZPM hatch, MK2 controller) |
| `pico-quantum-power-ics` | ZPM | grade 6 water, americium doped boule and wafer, PPIC and QPIC wafers and chips (UV/UHV hatches, MK3 and MK4 controllers) |
| `uev-materials` | UHV | draconium, the cosmic neutronium and infinity bootstrap melts, parts of the three metals, draconium cable |
| `bio-processors` | UHV | bio cells, bioware board, bio processing unit, bio processor, assembly, supercomputer |
| `bio-processor-mainframes` | UHV | bio processor mainframe (the UEV circuit) |
| `uev-components` | UHV | UEV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator, UEV casing and hull |
| `uev-machines` | UEV | the 23 basic machines one tier up |
| `uev-energy-hatches` | UEV | dracofinium (dust, blast furnace, wire, superconductive wire), the UEV superconducting coil block, awakened draconium coil, UEV voltage coil, UEV energy hatch |
| `uev-multiblocks` | UEV | the 13 multiblock upgrades |
| `fusion-reactor-mk4` | UEV | superdense neutronium plate, fusion machine casing MK3, MK4 controller and reactor |
| `fusion-plasmas-mk4` | UEV | the efficient cosmic neutronium and infinity melts |
| `uiv-materials` | UEV | transcendent metal (melt and all parts), nether star rod, wire and cable |
| `optical-processors` | UEV | optical fiber, optical board, optical processing unit, optical processor, assembly, supercomputer |
| `optical-processor-mainframes` | UEV | optical processor mainframe (the UIV circuit) |
| `uiv-components` | UEV | UIV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator, UIV casing and hull |
| `uiv-machines` | UIV | the 23 basic machines one tier up |
| `uiv-energy-hatches` | UIV | chromnorox (dust, blast furnace, wire, superconductive wire), the UIV superconducting coil block, infinity coil, UIV voltage coil, UIV energy hatch |
| `uiv-multiblocks` | UIV | the 13 multiblock upgrades |

Changed technologies: `cryogenic-science-pack` (UEV science tech) unlocks `uev-science-pack` and requires `uev-components`;
`promethium-science-pack` (UIV science tech) unlocks `uiv-science-pack` and requires `uiv-components`; `zpm-energy-hatches` and
`fusion-reactor-mk2` require `nano-power-ics`; `uv-energy-hatches`, `uhv-energy-hatches` and `fusion-reactor-mk3` require
`pico-quantum-power-ics`.

Science packs: `uev-science-pack` (UEV motor, 2 UEV circuits, 4 infinity plates, 4 tritanium coils, a UHV field generator and
molten infinity -> 10 cryogenic packs, UHV assembling machine); `uiv-science-pack` (UIV motor, 2 UIV circuits, 4 transcendent
metal plates, 4 awakened draconium coils, a UEV field generator and molten transcendent metal -> 10 promethium packs, UEV
assembling machine).

Auto-unlock: `FORK-AUTOUNLOCK` is identical to phase 4 except `filter-casing` (needed by the water purification plant, unlocked with
`water-purification`). The UEV and UIV multiblock upgrades give the replaced UV/UHV energy hatches and coils back, but all of them
are unlocked explicitly by their own techs. Making the europium and americium wafers craftable would have let the auto-unlock
pull two NAND wafer variants into the assembly line tech and turn the phosphorus NAND wafer into an explicit unlock; both NAND
variants are bound to the new chip techs and `nand-memory-wafer-pd` is bound to `assembly-line` explicitly, so no unlock moved.
The tech-by-tech diff against `origin/main` shows no lost unlock.

Choices and deviations from GT:

- **Water purification.** One plant (5x5) with a recipe per grade instead of eight units with linkage blocks. Grades 1-6 (water ->
  carbon filter -> ozone -> polyaluminium chloride -> acid/base -> helium plasma -> krypton plasma, 90 % yield per grade). GT's lenses,
  flocculation waste, super coolant and catalyst items are left out. Grade 6 needs krypton plasma from the MK2, so it sits in the ZPM
  tech. Grades 7 and 8 and the FPIC/APIC chips are open.
- **Power ICs.** ZPM hatch NPIC, UV hatch PPIC, UHV hatch QPIC as in GT; the UEV hatch uses 4 QPICs and the UIV hatch 8 (GT: FPIC and APIC).
  The MK2 controller uses NPIC wafers: GT's PPIC wafer needs americium, which only the MK2 makes. The MK3 and MK4 controllers use QPIC wafers.
  The wetware mainframe still uses advanced SMDs (complex SMDs come from GT's nanochip complex, which is not in the mod).
- **UEV metals are fusion products.** GT mines cosmic neutronium and gets draconium from Draconic Evolution; infinity comes from the infinity
  catalyst chain. Here: draconium = americium + iron plasma (MK3), cosmic neutronium = neutronium + tritanium, infinity = cosmic
  neutronium + draconium. The UEV hatches (and so the MK4) need all of them, so the MK3 has slow bootstrap recipes (2 melt for 1, 4 times
  slower) and the MK4 the efficient ones. Bedrockium is not built (nothing in UEV/UIV needs it), fluxed electrum and UU matter neither.
- **UHV parts stay tritanium and the UHV superconductor triamerotronium.** Switching them to cosmic neutronium and draconium would put the
  UEV metals in front of the UHV energy hatch and the UEV techs already need the UHV tier.
- **Bio and optical lines** have the shape of the wetware line (circuit assembly line, 16 circuits per craft, 2 of the previous stage per circuit).
  Bio cells come from stem cells, mutagen and growth medium (GT: cosmic neutronium dust); the bio processor takes wetware processors, the
  optical processor bio processors. The optical fiber is borosilicate glass (GT: lumiium, chromatic glass).
- **UEV components** follow GT with these changes: infinity parts, draconium cable and cosmic neutronium fine wire as in GT, but attuned
  tengam -> magnetic samarium rods, ~~quantium -> cosmic neutronium melt~~ (quantium since issue #36), infinity catalyst foil -> infinity foil,
  bedrockium/nether star plates -> cosmic neutronium plates (the casing takes bedrockium plates since issue #36); fine wire and foil counts cut (GT: 512 fine wires, 256 foils).
- **UIV components:** transcendent metal (a MK4 product from infinity melt and krypton plasma; GT: raw tesseract in the dimensionally
  transcendent plasma forge), nether star cable (1 nether star = 1 motor's cable), fine cosmic neutronium wire instead of proto-halkonite
  steel wire, infinity plates in the pump. The UEV field generator uses 4 UIV circuits like GT; the UIV one uses 8 UIV circuits (UMV circuits
  come in 5b).
- **Superconductors** `dracofinium` (UEV: draconium, infinity, cosmic neutronium) and `chromnorox` (UIV: transcendent metal, infinity,
  draconium) are the names of the drafts; the recipes are invented on the pattern of triamerotronium.
- **Fusion MK4** is the UEV tier (16 UEV hatches, 32 UEV hulls), casing MK3 has the category typo fixed and needs one UHV motor (the draft: 2 motors
  and a piston, 79 casings would have been 240 motors), 16 advanced fusion coils (draft 32, MK3 8). The MK4 reactor reused the MK3 art until issue #41 (now the art of GoodGenerator's compact fusion computer MK-IV).
- **Upstream stone recipes.** Upstream has `stone -> umv-science-pack` and `stone -> uxv-science-pack` placeholders. With the UIV pack craftable they
  would have opened the whole endgame for free, so both recipes are removed until 5b. Their techs stay (researchable, pack without recipe).

Existing saves (unlocks that changed):

- `uhv-field-generator`: 4 UEV circuits instead of 8 UHV circuits. Still unlocked by `uhv-components`; craftable once the UEV circuit is.
- `zpm-energy-hatch`, `uv-energy-hatch`, `uhv-energy-hatch`: NPIC/PPIC/QPIC instead of UHPICs. The recipes stay unlocked, but saves that already
  researched the hatch techs need `nano-power-ics` / `pico-quantum-power-ics` before they can craft them again (same as the field generator in phase 3).
- `fusion-reactor-mk2-controller` and `fusion-reactor-mk3-controller`: NPIC / QPIC wafers instead of UHPIC wafers, same note.
- `cryogenic-science-pack` and `promethium-science-pack` (researched in saves that reached them, e.g. by console) have new prerequisites; a researched
  tech stays researched. `umv-science-pack` and `uxv-science-pack` lose their stone recipes.
- Everything else only adds recipes. `migrate --from-ref 0e935ba` and `--from-ref dcb0e9e` (before this phase) load.

**Before the balance pass** (top metal only; full-chain times in "Balance pass: endgame"): bottlenecks of the new parts, in ingots of the metal (tritanium: the UHV row without the naquadria melt; 1 ingot = 14.4 mB). Every component takes
one minute in the ZPM assembly line. Cosmic neutronium is 1 neutronium + 1 tritanium per ingot, infinity 1 cosmic neutronium + 1 draconium (MK4: 1.5 s per
ingot, MK3 bootstrap: 6 s and twice the inputs), draconium 1 americium (+ iron plasma, 3 s in the MK3):

| Part | UEV: infinity / cosmic neutronium / draconium | UIV: transcendent / cosmic neutronium / nether stars |
|---|---|---|
| motor | 14 / 26 / 4 | 32 / 8 / 1 |
| pump | 37 / 56 / 8 | 73 / 8 / 2 (+12 infinity) |
| conveyor module | 40 / 70 / 12 | 94 / 16 / 3 |
| piston | 46 / 44 / 12 | 82 / 8 / 3 |
| robot arm | 96 / 114 / 32 | 186 / 24 / 8 |
| emitter / sensor | 32 / 44 / 18 each | 68 / 8 / 4.5 each |
| field generator | 130 / 208 / 88 | 306 / 32 / 22 |

The cosmic neutronium of a UEV part includes the 18 ingots of melt in its fluids. One MK4 needs 16 UEV hatches, 32 UEV hulls, 79 casings MK3 (79 UHV motors),
16 advanced fusion coils (each a UHV emitter and sensor) and 48 QPIC wafers. Nothing was tuned in game.

### Open points from phase 5a

- Fusion MK5: needs `advanced-fusion-coil-ii` (energy module, compact fusion coil, rhugnor plate), `fusion-machine-casing-mk4` (naquadah alloy block, chromatic
  glass) and molten rhugnor (infinity + molten quantum), which no line makes. The MK4 drafts `molten-rhugnor` and `molten-flerovium` (plutonium-241) stay drafts.
- ~~Water purification grades 7 and 8, FPIC/APIC chips, complex SMDs.~~ Done, see "Side quest: water purification grades 7 and 8".
- ~~Most plasmas (sulfur, nitrogen, zinc, niobium, tin, titanium, oxygen, neon, boron, calcium) are still only ingredients or unused; there is no plasma generator.~~ Done in "Side quest: endgame power".
- No ~~bedrockium, fluxed electrum~~, UU matter, ~~quantium~~, attuned tengam, ~~super coolant~~ (issue #36; UU matter is not built, see "Drafts and endgame materials"). The ~~quantum force transformer, dimensional plasma forge~~ (phase 6a), godforge
  and the rest of `29-uev-age-item.lua` / `31-uiv-age-item.lua` are for later.
- Graphics: the UEV/UIV basic machine sprites are generated from GT textures (tinted gold and blue, since issue #41 inside the GT hull of
  their tier), the MK4 reactor reused the MK3 art (own art since issue #41), the new items and technologies had recolored placeholder
  icons (`tools/gen_icons.py`, `tools/gen_tech_icons.py`; GT textures since issue #40).
- Balance is untested in game (see the table above).

### Suggested next step (done in phase 5b)

Phase 5b (UMV, UXV, MAX and the endgame): see below.

## Phase 5b: UMV, UXV, MAX and the endgame (done)

Numbers: researchable technologies 296 -> 316 of 341 -> 358 (the 17 new ones, and `uxv-science-pack`, `stargate` and `victory`,
which are now reachable), draft recipes hidden by the draft guard 36 -> 29 (`fusion-reactor-mk5`, its controller, `advanced-fusion-coil-ii`,
`fusion-machine-casing-mk4`, `molten-rhugnor`, `molten-flerovium` and `superconducting-coil-block-umv` are real recipes now), auto-unlocked
recipes 54 -> 54 (the `FORK-AUTOUNLOCK` lines are identical), machines placed by `devcheck runtime` 436 -> 509, unlocked but uncraftable
recipes 0. Progression no longer stops anywhere: every tier technology from LV to `victory` is researchable, and the runtime test wins the
game by researching `victory`.

`80-umv-age-item.lua` and `90-uxv-age-item.lua` are still not loaded (not valid Lua; they hold the GTNH chains for spacetime, magmatter,
dark matter, shirabon, mellion, the eye of harmony and coal recipes). What phase 5b needs is rebuilt in `133-fork-umv.lua`,
`134-fork-uxv.lua` and `135-fork-endgame.lua`. `133-fork-umv.lua` also defines the helpers of the three files (the global table
`FORK5B`: `metal`, `cable`, `circuit_line`, `components`, `tech`, ...), because a UXV part is a UMV part with the next metal.

New technologies (the counts were 2500-3500 units, one unit takes 60 s; upstream has 2300 for the UMV, 2600 for the UXV and 3000 for the
stargate tech; issue #30 cut them to 40-140, see "Balance pass: endgame"):

| Technology | Science | Unlocks |
|---|---|---|
| `fusion-coil-ii` | UIV | energy module, molten rhugnor and flerovium (MK4), rhugnor ingot and plate, advanced fusion coil II |
| `fusion-reactor-mk5` | UIV | fusion machine casing MK4, MK5 controller and reactor |
| `fusion-plasmas-mk5` | UIV | molten spacetime and molten universium |
| `umv-materials` | UIV | spacetime parts (ingot, plate, rods, frame, gears, ring, round, screw, rotor, wires, foil) and spacetime cable |
| `exotic-processors` | UIV | exotic board, exotic processing unit, exotic processor, assembly, supercomputer |
| `exotic-processor-mainframes` | UIV | exotic processor mainframe (the UMV circuit) |
| `umv-components` | UIV | UMV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator, UMV casing and hull |
| `umv-machines` | UMV | the 23 basic machines one tier up |
| `umv-energy-hatches` | UMV | hypocosmium (dust, blast furnace, wire, superconductive wire), UMV superconducting coil block, spacetime coil, UMV voltage coil, UMV energy hatch |
| `umv-multiblocks` | UMV | the 13 multiblock upgrades |
| `uxv-materials` | UMV | universium parts and universium cable |
| `temporal-processors` | UMV | temporal board, processing unit, processor, assembly, supercomputer |
| `temporal-processor-mainframes` | UMV | temporal processor mainframe (the UXV circuit) |
| `uxv-components` | UMV | UXV motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator, UXV casing and hull |
| `uxv-machines` | UXV | the 23 basic machines one tier up |
| `uxv-energy-hatches` | UXV | eternity (dust, blast furnace, wire, superconductive wire), UXV superconducting coil block, eternal coil, UXV voltage coil, UXV energy hatch |
| `uxv-multiblocks` | UXV | the 13 multiblock upgrades |

Changed technologies (all from the fork files): `umv-science-pack` requires `umv-components`, `uxv-science-pack` requires `uxv-components`, `stargate`
requires `uxv-multiblocks` and also unlocks the four parts of the parts (frame part, radiation containment plate, chevron, iris blade). The
upstream effects (`umv-science-pack` unlocks its pack, `stargate` the stargate parts and the MAX science pack) are kept.

Science packs: `umv-science-pack` (UMV motor, 2 UMV circuits, 4 spacetime plates, 4 infinity coils, a UIV field generator and molten spacetime ->
10 packs, UIV assembler), `uxv-science-pack` (UXV motor, 2 UXV circuits, 4 universium plates, 4 spacetime coils, a UMV field generator and molten
universium -> 10 packs, UMV assembler). Both replace the upstream stone recipes (`stone -> umv-science-pack` and `stone -> uxv-science-pack`),
which phase 5a had removed. `max-science-pack` is the upstream recipe: 1 stargate -> 1000 packs in the UXV assembler.

Auto-unlock: `FORK-AUTOUNLOCK` is identical to phase 5a. The tech-by-tech diff against `origin/main` shows no lost unlock; the only additions are the
UMV and UXV pack recipes (their techs had the effect, the recipes were removed) and the four stargate parts of parts.

Choices and deviations from GT:

- **Fusion MK5.** It is the UIV tier (16 UIV energy hatches, 32 UIV hulls); the draft asked for UEV hatches, which the MK4 uses since 5a. 16 advanced fusion
  coils II (draft: 32), 79 casings MK4. The drafts fixed: molten rhugnor is infinity + molten transcendent metal (draft: molten quantum, which no line
  makes), molten flerovium is americium + calcium plasma (draft: plutonium-241); both are MK4 recipes, so nothing that the MK5 makes is needed to
  build it and there is no bootstrap recipe. The energy module (GT: ZPM assembly line, not loaded before) uses UHPIC wafers instead of ASOC wafers.
  Coil II uses a UEV emitter and sensor: a UIV emitter or field generator would need UMV circuits, which need spacetime, which the MK5 makes. The
  controller uses UEV field generators (as the draft), UIV circuits, QPIC wafers (PICO wafers are not built) and chromnorox wire. The MK5 reused the MK3 art until issue #41 (now the art of GoodGenerator's compact fusion computer MK-V).
- **Spacetime and universium are MK5 products** (GT: tesseracts in the dimensionally transcendent plasma forge; since phase 6a the
  DTPF makes them too, with less input, see "Phase 6a: QFT and DTPF"). Spacetime = transcendent metal +
  rhugnor, universium = spacetime + flerovium, 1.5 s per ingot in one MK5. The parts are made like the transcendent metal ones (large gear 4 ingots).
- **Cables.** GT's UMV cable is quantium (since issue #36 the UMV components take quantium cable; the machines and the hull keep the spacetime one): spacetime cable (wire + rubber + sheet like the draconium cable); UXV: universium cable.
- **Superconductors.** `hypocosmium` (UMV: spacetime, infinity, rhugnor) is the name of the draft; `eternity` (UXV: universium, spacetime, hypocosmium)
  takes the name of the example in `03-helper-functions-module.lua`. Recipes invented on the pattern of chromnorox, cooled with cryogenic helium in the pump.
  The mainframes use the superconductor of the tier below (UMV: chromnorox, UXV: hypocosmium), like the earlier ones.
- **Exotic and temporal lines** have the shape of the optical line (circuit assembly line, 16 circuits per craft, 2 of the previous stage per circuit):
  board (previous board + foil), processing unit (previous unit + a gravi star, 4 per craft), processor (takes the processors of the previous line),
  assembly, supercomputer, mainframe. No exotic chips or optical SMDs (advanced SMDs again). One circuit needs 2 gravi stars, 15 boards, 8 processors of
  the previous line; a craft of 16 circuits takes about 32 minutes in one circuit assembly line (240 s, 480 s, ... like the earlier lines).
- **UMV and UXV components** are the UIV recipes with the new metal and cable (the pump takes 12 plates of the metal of the tier below: transcendent
  metal for the UMV pump, spacetime for the UXV pump); wire and foil counts as in 5a (motor 64 fine wires, emitter and sensor 32 foils, field generator
  64 fine wires). Each takes one minute in the ZPM assembly line. The UMV field generator uses UXV circuits (4) like GT once the UXV circuit exists, the
  UXV one 8 UXV circuits (GT: MAX circuits, not built).
- **Coils.** The UMV blast furnace coil is `spacetime-coil-block` (built like the infinity coil), the UXV one `eternal-coil-block` (the name of the draft). Voltage
  coils: `mega-ultimate-voltage-coil` and `extended-mega-ultimate-voltage-coil` (magnetic samarium rod + 16 fine wires). The energy hatches take 16 (UMV) and 32
  (UXV) QPICs, twice the previous hatch, because the QPIC stands in for the missing FPIC/APIC line.
- **Stargate.** Top level as in GT: 8 ring blocks, 7 chevron blocks, base, power unit, controller, chevron upgrade, iris upgrade. The upstream recipes of the parts
  used each other as ingredients (dead ends) and GT's chains (magmatter, dark matter, catalysts) do not exist here. Every part is now made of the metals of the last
  tiers (infinity, transcendent metal, spacetime, universium), UXV components, coils II and the eternity wire in the ZPM assembly line (the final stargate in the
  UXV assembler), with four new intermediates: frame part, radiation containment plate, chevron and iris blade. The ring block needs no chevron block and vice versa
  (the draft had a ring block in the chevron block and in the power unit).
- **Victory.** `victory` stays the upstream infinite tech (1000 * 2^(L-1) units of all 15 packs, prerequisite `stargate`). `scripts/fork-victory.lua` calls
  `game.set_game_state{ game_finished = true, player_won = true, can_continue = true, victorious_force = force }` the first time it is researched; the
  further levels are normal research. `devcheck runtime` researches it by script at tick 550 and expects `game.finished`. One level needed exactly 1000 MAX packs =
  one stargate, the next level two (issue #30: `15 * 2^(L-1)` units, one stargate lasts for the first six levels).
- **Placeholder recipes.** A search for recipes that turn cheap items into endgame items (stone, dirt, single plates -> UV or higher items) found only the two
  stone science pack recipes, which are replaced; the stargate parts of the draft (ingredients = themselves) are replaced too.

Existing saves (unlocks that changed):

- `uiv-field-generator`: 4 UMV circuits instead of 8 UIV circuits (as requested). The recipe stays unlocked by `uiv-components`, so saves that had it keep it;
  it is craftable once the UMV circuit is (needs `exotic-processor-mainframes`). Only the UMV science pack uses it. The same happens with the UMV
  field generator once the UXV circuit exists.
- `umv-science-pack` and `uxv-science-pack` (techs, researched in saves that got there by console) have a new prerequisite; a researched tech stays researched.
- Everything else only adds recipes and techs. `migrate --from-ref 0e935ba` and `--from-ref 5f00391` (before this phase) load.

**Before the balance pass** (top metal only; the stargate parts changed, full-chain times in "Balance pass: endgame"): bottlenecks of the new parts (ingots of the metal, melt and ingots together; 1 ingot = 14.4 mB; the melt comes from one MK5 at 1.5 s per ingot). Every
component takes one minute in the ZPM assembly line:

| Part | Ingots (spacetime for UMV, universium for UXV) | Other main inputs |
|---|---|---|
| motor | 44 | 4 long magnetic samarium rods |
| pump | 89 | motor, 12 plates of the metal below |
| conveyor module | 122 | 2 motors, 80 silicone rubber sheets |
| piston | 102 | motor |
| robot arm | 242 | 2 motors, piston, 14 circuits (2 of the tier, 4 and 8 of the two below) |
| emitter / sensor | 94 each | motor, 8 gravi stars, 4 circuits of the tier |
| field generator | 426 | 4 emitters, 36 gravi stars, 24 circuits of the tier (UMV: 4 UXV circuits + 16 UMV) |

Fusion MK5: 4900 transcendent metal, 1700 rhugnor and 630 flerovium ingots, 1600 infinity ingots, 240 UEV, 270 UHV and 45 UIV circuits, 620 gravi stars (510 nether
stars) and 79 UIV motors' worth of casings; the 16 coils II need 16 UEV emitters and sensors. Stargate (all parts, in ingots of universium equivalents): frame
part 48 (+44 spacetime), radiation containment plate 28 (+64 neutronium), chevron 24, ring block 730, chevron block 1040, chevron upgrade 530, base 3560, power
unit 1820 (4 coils II), controller 1210, iris upgrade 290 (+640 neutronium): the stargate is about 20 500 ingots of universium (8.5 hours of one MK5), 3400 of
spacetime, 4000 of neutronium, 1000 gravi stars, 620 UXV circuits. ~~(8.5 hours)~~ Issue #33: with the whole metal chain it was 32 hours of the UXV
reference factory; after the balance pass 10.6 hours, 2 UXV field generators and 196 UXV circuits.

~~The research of the tiers is far bigger than the stargate~~ (issue #30: scaled down from UV to `victory`, see "Balance pass: endgame"; the counts below are before it): the phase 5b techs alone (incl. the upstream `umv-science-pack`, `uxv-science-pack` and `stargate` techs) take
104 000 promethium, 47 100 UMV and 12 000 UXV packs (10 packs per craft, one UIV / UMV field generator per craft), and level 1 of `victory` another 5000 promethium,
3000 UMV, 2000 UXV and 1000 MAX packs (plus 256 000 automation packs ...). Every unit of the last techs needs packs of all tiers below. These counts come from the
upstream `SP` tables and are the first thing to tune in the real game.

### Final pass: technologies that cannot be researched

`devcheck check` now lists them with the disabled or missing prerequisites that block them (42 of 358; every tier technology from LV to `victory` is
researchable). All of them are blocked by vanilla technologies that Gregtorio disables (their science packs, items or recipes do not exist in the mod):

Intentional (vanilla equipment, armor and military techs the mod does not use; blocked by `solar-panel-equipment`, `heavy-armor`, `military-4`, `electric-engine`,
`processing-unit`, `advanced-circuit`, `rocket-turret`, `speed-module`, `efficiency-module`, `quantum-processor`): `battery-equipment`, `battery-mk2-equipment`,
`battery-mk3-equipment`, `belt-immunity-equipment`, `energy-shield-equipment`, `energy-shield-mk2-equipment`, `exoskeleton-equipment`, `fission-reactor-equipment`,
`fusion-reactor` (the vanilla one; Gregtorio has its own fusion techs), `fusion-reactor-equipment`, `mech-armor`, `modular-armor`, `night-vision-equipment`,
`personal-roboport-equipment`, `personal-roboport-mk2-equipment`, `power-armor`, `power-armor-mk2`, `spidertron`, `explosives` (`sulfur-processing`).

Quality-of-life (issue #29, done): the 23 techs whose vanilla gate is disabled (`advanced-circuit`, `carbon-fiber`, `lubricant`, `robotics`) are researchable
now. `prototypes/103-fork-qol-techs.lua` replaces their prerequisites with the Gregtorio tech of their tier and their packs with the Gregtorio packs of that tier,
with the counts and times of the neighbouring tier techs (MV 3 packs 30 s, HV 4 packs 30 s, EV 5 packs 45 s, IV 6 packs 60 s, LuV 7 packs 90 s, ZPM 8 packs 120 s;
the highest pack costs 1, the ones below 2, 3, 5, 8, 12, 18, 28 like in `98-technology.lua`). Nothing is hidden: the mod has construction and logistic robots
(`t1-construction-robot`, `t1-logistic-robot`, MV), so the worker robot techs have something to act on.

Numbers: researchable technologies 332 -> 355 of 374 (the 23), draft recipes hidden by the draft guard 21 -> 21, auto-unlocked recipes unchanged (the
`FORK-DRAFT` and `FORK-AUTOUNLOCK` lines are identical), the unlocks of every technology unchanged (the 23 unlock the same recipes as before), unlocked but
uncraftable recipes 0. `devcheck check` now fails if an enabled technology outside the 19 intentional ones (`UNRESEARCHABLE_OK`) cannot be researched, or if one of
the 23 (`QOL_TECHS`) is neither researchable nor hidden.

Belts follow the mod's own belts: the transport belt is LV (steam age), the fast belt MV with an LV conveyor module; express is HV with an MV conveyor module,
turbo EV with an HV conveyor module (splitters: two pistons of that tier). The vanilla recipes they unlock get GT recipes in `crafting-or-assembling-recipes`
(hand crafting and assembling machines, like the fast belts and inserters); their vanilla ingredients (lubricant, carbon fiber, jelly, tungsten plate, the vanilla
`processing-unit` counts) are gone, and the turbo recipes lose their Vulcanus-only surface condition. The recycling recipes follow the new ingredients (generated
by the quality mod after the data stage). No other technology depends on the 23, so saves are not affected (none of them could be researched before).

| Technology | Tier | Prerequisites | Packs, count | Recipe |
|---|---|---|---|---|
| `bulk-inserter` | MV | `fast-inserter`, `logistics-2`, `mv-components` | 3 packs, 300 | fast inserter, MV robot arm, 2 MV circuits, 2 aluminium plates |
| `inserter-capacity-bonus-1` | MV | `bulk-inserter` | 3 packs, 300 | (bulk inserter capacity +1 only, so it stays behind the bulk inserter) |
| `inserter-capacity-bonus-2` | MV | `inserter-capacity-bonus-1` | 3 packs, 360 | |
| `inserter-capacity-bonus-3` | HV | `inserter-capacity-bonus-2`, `chemical-science-pack` | 4 packs, 450 | |
| `inserter-capacity-bonus-4` | HV | `inserter-capacity-bonus-3` | 4 packs, 550 | |
| `inserter-capacity-bonus-5` | EV | `inserter-capacity-bonus-4`, `production-science-pack` | 5 packs, 600 | |
| `inserter-capacity-bonus-6` | EV | `inserter-capacity-bonus-5` | 5 packs, 600 | |
| `inserter-capacity-bonus-7` | IV | `inserter-capacity-bonus-6`, `utility-science-pack` | 6 packs, 800 | |
| `stack-inserter` | HV | `bulk-inserter`, `hv-components` | 4 packs, 500 | bulk inserter, HV robot arm, 2 HV circuits, 2 stainless steel plates |
| `logistics-3` | HV | `logistics-2`, `hv-components` | 4 packs, 450 | 4 fast belts + MV conveyor module -> 4; 2 fast undergrounds + MV conveyor module -> 2; fast splitter + 2 MV pistons |
| `turbo-transport-belt` | EV | `logistics-3`, `ev-components` | 5 packs, 600 | 4 express belts + HV conveyor module -> 4; 2 express undergrounds + HV conveyor module -> 2; express splitter + 2 HV pistons |
| `transport-belt-capacity-1` | EV | `stack-inserter`, `production-science-pack` | 5 packs, 600 | (belt stack size, used by stack inserters) |
| `transport-belt-capacity-2` | IV | `transport-belt-capacity-1`, `utility-science-pack` | 6 packs, 800 | |
| `worker-robots-speed-1` | MV | `construction-robotics`, `logistic-robotics` | 3 packs, 340 | |
| `worker-robots-speed-2` | HV | `worker-robots-speed-1`, `chemical-science-pack` | 4 packs, 450 | |
| `worker-robots-speed-3` | HV | `worker-robots-speed-2` | 4 packs, 550 | |
| `worker-robots-speed-4` | EV | `worker-robots-speed-3`, `production-science-pack` | 5 packs, 600 | |
| `worker-robots-speed-5` | IV | `worker-robots-speed-4`, `utility-science-pack` | 6 packs, 800 | |
| `worker-robots-speed-6` | LuV | `worker-robots-speed-5`, `space-science-pack` | 7 packs, 1000 | |
| `worker-robots-speed-7` | ZPM | `worker-robots-speed-6`, `metallurgic-science-pack` | 8 packs, `2^(L-6)*1000` (infinite, 2000 for level 7) | |
| `worker-robots-storage-1` | MV | `logistic-robotics` | 3 packs, 340 | |
| `worker-robots-storage-2` | HV | `worker-robots-storage-1`, `chemical-science-pack` | 4 packs, 500 | |
| `worker-robots-storage-3` | EV | `worker-robots-storage-2`, `production-science-pack` | 5 packs, 600 | |

The inserter capacity bonuses start at MV instead of LV: level 1 only raises the bulk inserter capacity, and the bulk inserter is MV.

### Open points from phase 5b

- The MK5 reused the MK3 art, the UMV/UXV basic machine sprites were tinted GT textures (violet and white), the new item icons were recolored placeholders
  (`tools/gen_icons.py`; the stargate parts and the exotic/temporal items reused unrelated neighbor icons), the new technologies have icons of their main item.
  Since issues #40 and #41: own MK5 art, the UMV/UXV machines inside the GT hull of their tier, item icons from GT textures (the stargate parts from
  the GTNH core mod).
- ~~Balance is untested in game: the pack counts of the last techs (see above), the stargate (20 500 universium ingots), the QPIC counts of the hatches.~~
  Issues #30, #31, #33: see "Balance pass: endgame" (the hatches use APICs since #52); still to be played.
- Not built: the GT ~~quantum force transformer, dimensional plasma forge~~ (phase 6a), godforge, magmatter, dark matter, mellion, shirabon, six-phased copper, the eye of harmony and the
  UXV/MAX-only items of `90-uxv-age-item.lua` (mega ultimate battery, ridiculously large capacitor, artificial universe cell, ...). There is no MAX tier: no MAX circuit,
  hatch or machines.
- Still drafts (29, 21 since the endgame power side quest): ~~force plasma (arcanite), astral titanium and runite plasma~~ (removed), ~~the liquid fuels and naquadah fuel~~, ~~plutonium/high-density plutonium~~ (made real), ~~super coolant~~ (made real), ~~UU
  matter (magic essence, void/shadow metal, ichorium)~~ (removed), ~~1080k space cell~~ (made real), ~~the naquadah cracking chains, orundum~~ (removed), ~~the lapotronic energy orb cluster draft~~ (made real), ~~bio cells for
  microminers~~ (the tier five infused gold microminer, removed). Issues #39 and #36, see "Drafts and endgame materials".

### Suggested next step

Side quests, in the order that helps the endgame most:

1. Balance and graphics in the real game: the tier from UHV up (see the bottleneck tables of 4, 5a and 5b), the pack counts of the last techs, the power IC counts
   (analysed and tuned in "Balance pass: endgame", issues #30, #31, #33; still to be played).
   ~~Real sprites for the MK4/MK5 reactors and the last machine tiers, real icons for the exotic/temporal lines and the stargate parts~~ (done, issues #40 and
   #41, `docs/graphics-review/`; still to be seen in the real game).
2. ~~Plasma generator (GT plasma turbine)~~ (done, see "Side quest: endgame power").
3. ~~Water purification grades 7 (degasifier) and 8 (quark extraction), FPIC/APIC chips and complex SMDs, which would let the QPIC stand-ins of the UEV to UXV hatches go.~~
   (done, see "Side quest: water purification grades 7 and 8").
4. ~~AE2 autocrafting~~ (done, see "Side quest: AE2 autocrafting").
5. ~~The technologies of the final pass list: decide for each "open" one whether it gets a Gregtorio gate or is hidden.~~ (done, issue #29: all 23 are
   researchable, see "Final pass" above).
6. A MAX tier (MAX circuit, hatch, machines, and the GT items the stargate could take) if the endgame should go on after `victory`
   (issue #37: phase 6a, the QFT and the DTPF, is done; phase 6b is the MAX tier and the godforge).

## Drafts and endgame materials (issues #39 and #36)

Two pull requests: **PR 1** (issue #39) triages every draft the draft guard still hid and closes the ones that need no new
material; **PR 2** (issue #36) adds the endgame materials the GT drafts expect and closes the drafts that depend on them.
Everything is in `prototypes/137-fork-endgame-materials.lua` (loaded after 136, whose plutonium fuel and dynamo hatches it
changes).

Decisions: **(a)** made real, built from what the mod has and adapted like the phases did; **(b)** removed for good: the
recipes and the items only they used are deleted in 137 (`FORK-REMOVED` in the log), so neither the draft guard nor the
crafting menu, Factoriopedia or the quality recycling recipes ever see them; **(c)** the missing part is replaced by an
existing item.

### Triage of the drafts (issue #39)

The 21 recipes of `FORK-DRAFT` before (the list of "Still drafts" in phases 1 to 5b):

| Draft recipe | Missing | Decision | Tier | Technology | PR |
|---|---|---|---|---|---|
| `lapotronic-energy-orb-cluster` (circuit assembler) | qubit processing unit | (c) GT's QBit processing unit is the qubit CPU chip | ZPM | `lapotronic-energy-orbs` (new) | 1 |
| `force-plasma` | molten arcanite | (b) GT++ RuneScape/WoW materials (arcanite: thorium, energy crystal and Thaumcraft aspects); nothing needs the plasma | - | - | 1 |
| `astral-titanium-plasma` | force plasma | (b) same chain | - | - | 1 |
| `runite-plasma` | astral titanium plasma, molten titansteel | (b) same chain (titansteel: Thaumcraft aspects) | - | - | 1 |
| `wrapped-plutonium-ingot` | plutonium oxide-uranium mixture | (c) its metal content: 3 plutonium 239 and 1 uranium 238 dust per wrap | ZPM | `naquadah-fuels` | 1 |
| `high-density-plutonium-nugget` | HSS-S dust (byproduct) | (c) byproduct left out | ZPM | `naquadah-fuels` | 1 |
| `high-density-plutonium-eic` | UEV electric implosion compressor | (b) GT's EIC is not built, the implosion compressors have no fluid input for its neutronium, and the nugget route makes the same item | - | - | 1 |
| `microminer-infused-gold` ("bio cells for microminers": the tier five microminer) | tier five microminer output | (b) Thaumcraft infused gold; the whole infused gold ore line goes with it | - | - | 1 |
| `magic-essence` | UU matter | (b) Thaumcraft (salis mundis) | - | - | 1 |
| `void-metal-dust` | UU matter | (b) Thaumcraft (thaumium goes with it) | - | - | 1 |
| `shadow-metal-dust` | UU matter | (b) Thaumcraft addon | - | - | 1 |
| `ichorium-dust` | UU matter | (b) Thaumic Tinkerer | - | - | 1 |
| `raw-atomic-separation-catalyst` | blaze powder | (b) GoodGenerator's catalyst of blaze powder, manyullyn/ardite (Tinkers) and orundum (Arknights); only the fuel cracking uses it | - | - | 1 |
| `orundum-plate` | tiberium plate | (b) same chain | - | - | 1 |
| `hot-atomic-separation-catalyst-ingot` | molten plutonium 239 | (b) same chain (the vacuum freezer step `atomic-separation-catalyst-ingot` goes with it) | - | - | 1 |
| `naquadah-solution-cracking` | cracked naquadah heavy fuel | (b) the naquadah fuel cracking needs the catalyst above, naquadah asphalt and thulium/thorium melts; the fuel line of the endgame power side quest works without it | - | - | 1 |
| `naquadah-heavy-fuel-cracking` | naquadah heavy fuel | (b) same | - | - | 1 |
| `naquadah-asphalt-cracking` | naquadah asphalt | (b) same | - | - | 1 |
| `super-coolant` | callisto ice dust | (a) with callisto ice and ledox from the end microminer | see materials | see materials | 2 (done) |
| `1080k-space-cell` | dense fluxed electrum plate | (a) with fluxed electrum | see materials | see materials | 2 (done) |
| `1080k-super-coolant-cell` | super coolant | (a) with super coolant | see materials | see materials | 2 (done) |

Removed with them (items only these drafts used): raw and crushed infused gold, infused gold dust (and the three ore
processing recipes), salis mundis, thaumium dust, magic essence, void metal, shadow metal and ichorium dust, raw atomic
separation catalyst, orundum plate, hot and cold atomic separation catalyst ingot, the bogus item
`high-density-plutonium-eic`: 14 items and 21 recipes (35 `FORK-REMOVED` lines). No technology unlocked any of them; the
fork-power mod data and the other recipes never referenced them (the draft guard would report a recipe that did). Their
icons stay in `graphics/icons/` (unused).

### Triage of the endgame materials (issue #36)

| Material | Built | How (GT source) | Replaces (stand-in -> real) | Tier | Technology | PR |
|---|---|---|---|---|---|---|
| super coolant | yes | the draft (HV mixer: ledox dust, callisto ice dust, lapis coolant); ledox and callisto ice from a new end microminer recipe (GT: ores on Europa/Callisto and space mining asteroids) | grade 5 water (GT: 100 super coolant per craft, none here before), grade 7 water (cryogenic helium), UIV/UMV/UXV energy and dynamo hatches (cryogenic helium; GT uses super coolant from UIV up, UHV and UEV use IC2 coolant) | LuV | `super-coolant` | 2 |
| 1080k super coolant cell | yes | the drafts: 180k -> 540k -> 1080k space cell (tungstensteel, the dense fluxed electrum plate), canned with 600 super coolant (GT: `Reactor_Coolant_Sp_6`) | UEV 2, UIV 4, UMV 6, UXV 8 cells per energy and dynamo hatch (GT) | UHV | `space-coolant-cells` | 2 |
| fluxed electrum | yes | electrum, redstone and naquadah dust -> ZPM blast furnace and vacuum freezer, melt from the ZPM alloy blast smelter (GT: 9000 K, the dust recipe is not in GT5-Unofficial, Redstone Arsenal's is electrum + redstone) | UV voltage coil (fine americium wire), UHV emitter and sensor (tritanium foil), fusion MK3 controller (tritanium melt), naquadah fuel MK2 (naquadria dust) | ZPM | `fluxed-electrum` | 2 |
| bedrockium | yes | new end microminer recipe (upstream draft `microminer-bedrockium`, GT: cosmic asteroid) -> the existing ore line -> UV blast furnace (GT: 9900 K) | UHV cable in the eight UHV components (tritanium cable), UEV casing (cosmic neutronium plates) | UV | `bedrockium` | 2 |
| quantium | yes | new end microminer recipe (GT: ore on Venus/Horus, niobium asteroid) -> UHV blast furnace (GT: 9900 K), melt from the extractor | UEV components (cosmic neutronium melt), UMV cable in the eight UMV components (spacetime cable) | UHV | `quantium` | 2 |
| UU matter | no | GT: mass fabricator (energy, optionally UU amplifier from scrap) | - | - | - | 2 |

Not switched, on purpose:

- **The UHV parts stay tritanium** (phase 5a): only their cable becomes bedrockium, which is a UV material here, so nothing moves
  in front of its tier. The tritanium cable stays in the UHV machines and hull.
- **The uranium based liquid fuel keeps naquadah dust** for GT's quantium dust: the fuel is ZPM (`naquadah-fuels`), quantium UHV.
- **The UHV and UEV hatches keep cryogenic helium** (GT: IC2 coolant, not super coolant).
- **The tritanium coil stays the UHV blast furnace coil**: GT's fluxed electrum coil is its 9901 K coil level, above the UHV one.
- **UU matter is not built.** Its magic consumers are removed. The rest are the MK4 fusion parts, where it is one of four fluids
  (with cinobite, octiron and astral titanium, none of them in the mod; tritanium and cosmic neutronium melt stand in for all four)
  and the UEV to UXV hatches (which leave it out). It needs GT's mass fabricator, a machine the fork does not have. Open point.

### Numbers

Both PRs against `origin/main`: researchable technologies 360 -> 366 of 379 -> 385, draft recipes hidden by the draft guard
21 -> 0 (`DRAFTS_OK` is empty), drafts removed for good 35 prototypes, auto-unlocked recipes 54 -> 53, machines placed by
`devcheck runtime` 510 -> 510 (no new machine), unlocked but uncraftable recipes 0, crafting menu 2745 -> 2784 machine recipes
shown, 241 kept hidden, 0 hidden without an allow-list entry.

PR 1: researchable technologies 360 -> 361 of 379 -> 380 (the new `lapotronic-energy-orbs`), draft recipes hidden by the
draft guard 21 -> 3 (the documented rest list `DRAFTS_OK` of `tools/devcheck/devcheck.py`: the three drafts of PR 2), auto-unlocked
recipes 54 -> 53, machines placed by `devcheck runtime` 510 -> 510, unlocked but uncraftable recipes 0, crafting menu check green
(2745 -> 2750 machine recipes shown, 241 kept hidden).

`FORK-AUTOUNLOCK` differs by one line, on purpose: `advanced-smds -> fine-niobium-titanium-wire` is gone because the wire is now
unlocked by `advanced-smds` explicitly. The cluster uses the wire, and the auto-unlock would have visited the new tech first and
moved the wire there (the tech-by-tech diff showed it); the explicit unlock keeps it where it was.

Tech by tech against `origin/main`: prerequisites and science packs of the 379 existing technologies are unchanged; the only
changed unlocks are `naquadah-fuels` (+ wrapped plutonium ingot, high density plutonium nugget, high density plutonium) and the
new tech (lapotronic energy orb, the cluster's circuit assembler recipe). No unlock was lost or moved (`advanced-smds` keeps the
fine niobium-titanium wire).

PR 2: researchable technologies 361 -> 366 of 380 -> 385 (`super-coolant` LuV, `fluxed-electrum` ZPM, `bedrockium` UV,
`space-coolant-cells` and `quantium` UHV), draft recipes 3 -> 0, `FORK-AUTOUNLOCK` identical to PR 1 (53 lines), machines placed
510 -> 510, uncraftable 0, crafting menu 2750 -> 2784 shown. Tech by tech against PR 1: the 380 technologies keep their science
packs and unlocks (every recipe of the new materials is unlocked explicitly by its new tech, none moved); five of them get one
prerequisite each, the material they now use first: `water-purification` + `super-coolant`, `uv-energy-hatches` +
`fluxed-electrum`, `uhv-components` + `bedrockium`, `uev-energy-hatches` + `space-coolant-cells`, `uev-components` + `quantium`.
Each new tech sits at or below the tier of its first user (LuV for LuV, ZPM before UV, UV for UV science, UHV for UHV and UEV
science).

Tests: `REQUIRED_RECIPES` of `devcheck check` lists the made-real drafts and the new materials (23 of 23 unlocked and craftable);
the recipe test of `devcheck runtime` crafts 14 more recipes once in a real machine (30 of 30), among them the circuit assembler
cluster, the plutonium steps, super coolant, the 1080k cell, the three hot ingots, the melts, naquadah fuel MK2, grade 5 water and
the UXV energy hatch.

### Existing saves

- `plutonium-based-liquid-fuel` takes 1 high density plutonium (GT) instead of 64 plutonium 239 dust; its three steps are
  unlocked by `naquadah-fuels`, which saves that have the fuel researched already.
- The removed items could never be made (no technology unlocked their recipes); if a save holds some (console), Factorio drops
  them on load.
- Issue #36 changes the ingredients of recipes that saves may have unlocked: grade 5 water (+100 super coolant) and grade 7 water
  (super coolant), the UEV to UXV energy and dynamo hatches (1080k super coolant cells, UIV up super coolant), the UV voltage coil,
  the UHV emitter and sensor, the eight UHV components (bedrockium cable), the fusion MK3 controller, naquadah fuel MK2, the UEV
  casing, the eight UEV components (quantium melt) and the eight UMV components (quantium cable). They stay unlocked; a save that
  researched them needs the new material tech before it can craft them again (as in phase 5a and the water purification side quest).
  Water purification plants on grade 5 stop until super coolant arrives. Researched techs stay researched when they get a new
  prerequisite.
- `migrate --from-ref v0.3.1` loads (both PRs).

### Open points

- UU matter (see above), and GT's super coolant in the bio and optical circuits, the PCB factory and the fridge casing.
- Fluxed electrum's dust recipe (electrum, redstone, naquadah) is invented: GT5-Unofficial has none (it is in the GTNH core mod).
- Icons of the new items and techs were recolored placeholders (`tools/gen_icons.py`, `tools/gen_tech_icons.py`); since issue #40 they come from GT
  textures (`tools/gen_gt_icons.py`).
- Balance of the new chains is untested in game.

## Side quest: endgame power (done)

Numbers: researchable technologies 319 -> 329 of 361 -> 371 (the 10 new ones), draft recipes hidden by the draft guard
29 -> 21 (the naquadah fuel line and the liquid fuels are real recipes now), auto-unlocked recipes 53 -> 54 (`FORK-AUTOUNLOCK`
differs by one line: `plasma-turbine` pulls in the long tungstensteel rod, which no technology unlocked before), machines
placed by `devcheck runtime` 510 -> 510 (generators are not assembling machines), unlocked but uncraftable recipes 0. Every
plasma the fusion reactors make is a fuel now; boron, calcium, helium, krypton and iron plasma stay ingredients as well.

Files: `prototypes/136-fork-power.lua` (loaded after 135 and before 150) and `scripts/fork-power.lua` (`on_tick`: the
energy of the plasma turbines every tick; every 10th tick the fuel check and the cooled fluid for the output hatches).

### Content

* **Fuel values.** Every plasma has GT5-Unofficial's plasma fuel value (`ProcessingCell.java`, EU per mB) with Gregtorio's
  1 EU = 1 kJ (32 EU/t of LV = 640 kW): helium 81.92 MJ per unit, boron 112.64, calcium 188.42, neon 20.48 (GT's default,
  1024 x mass), sulfur 170.39, nitrogen 129.02, zinc 226.3, niobium 269.52, tin 150, titanium 196.61, oxygen 131.07,
  krypton 86.02 (default), iron 206.44 MJ. The naquadah and liquid nuclear fuels have GoodGenerator's values (basic output
  x burning time per mB): excited uranium fuel 1.296 GJ, excited plutonium fuel 4.86 GJ, naquadah based fuel MK1 58.5 GJ,
  MK2 161 GJ, MK3 760.9 GJ per unit.
* **Large plasma turbines** (LuV to UXV; techs `plasma-turbine`, `zpm-plasma-turbine`, `uv-plasma-turbine`, and
  since issue #34 `uhv-plasma-turbine` ... `uxv-plasma-turbine`): 3x3 `generator` entities that burn only plasmas (fuel
  check below), capped at four amps of their tier (4 x EU32: 81.92, 163.84, 327.68, 655.36 MW, 1.31, 2.62, 5.24 and
  10.49 GW). The LuV one is built from a controller, the LuV dynamo hatch, 28 tungstensteel
  turbine casings, 14 tungstensteel frames and a tungstensteel turbine rotor (blades like the magnalium ones); ZPM to UXV
  are upgrades (previous turbine + dynamo hatch + hull, the replaced hatch and hull come back) like the multiblock upgrades
  of the tiers. See "Turbines above UV" below. GT's large plasma turbine returns the cooled fluid, one unit per unit of plasma: a Factorio generator has
  one fluid box and no output, so `scripts/fork-power.lua` credits every turbine with the plasma it burnt (the energy it
  generated, summed every tick, / fuel value; see "Cooled fluid" below) and pushes the cooled fluid into **turbine output
  hatches** (1x1 tanks, tech
  `plasma-turbine`) standing next to the turbine: helium plasma -> helium, nitrogen -> nitrogen, oxygen -> oxygen,
  krypton -> krypton, neon -> neon, tin -> molten tin, titanium -> molten titanium, iron -> molten iron. Without a hatch
  the cooled fluid is lost (GT voids it too); what does not fit into full hatches waits in the turbine. Zinc and niobium have
  no molten fluid here, boron, calcium and sulfur none at all, so those return nothing.
* **Naquadah fuel line** (tech `naquadah-fuels`, ZPM science, needs `fusion-plasmas-mk2` and `enriched-naquadah`): the
  drafts of `21-luv-age-item.lua` made real. 16 enriched naquadah dust + 300 hydrofluoric acid -> 200 acid naquadah
  emulsion + 3 radioactive sludge (EV blast furnace, 180 s); 8 quicklime + 100 acid emulsion -> 100 naquadah emulsion + 4
  fluorspar; 100 emulsion -> 50 naquadah solution + sludge (centrifuge); 20 solution -> 10 light naquadah fuel + 5 heavy
  naquadah fuel + 60 naquadah gas + 10 water (EV distillation tower, new name `naquadah-solution-distillation`: the draft's
  step was overwritten by two later drafts of the same name); 780 light + 360 heavy -> 100 naquadah based fuel MK1
  (fusion reactor MK2, 12.5 s, GT's amounts; the draft had a tenth). Radioactive sludge is centrifuged into enriched
  naquadah dust, uranium 238, plutonium 239 and radon (the draft without its calcium and tiberium dust). MK2 (tech
  `uhv-naquadah-reactor`): 100 MK1 + 1500 naquadah gas + 1 nether star + ~~16 naquadria dust~~ 32 fluxed electrum dust (issue #36) -> 100 MK2 in the UHV mixer
  (GT: nether star dust and fluxed electrum dust in a large chemical reactor). MK3 (tech `uev-naquadah-reactor`): 100 MK2
  + 800 heavy naquadah fuel + 32 uranium 238 dust + 16 plutonium 239 dust + 8 naquadria dust -> 100 MK3 in the UEV mixer
  (GT: the naquadah fuel refinery with extremely unstable naquadah, tiberium and high density uranium/plutonium). The
  liquid nuclear fuels of GoodGenerator: uranium based liquid fuel (64 uranium 238 dust, 8 potassium, 4 naquadah dust,
  1000 radon -> 1000; GT: high density uranium and quantium) and plutonium based liquid fuel (the draft with 2 neutronium ingots instead of neutronium dust, 1000 units like GT; it took 64 plutonium
  239 dust instead of high density plutonium until issue #39) are
  "excited" in the fusion reactor MK2 (the drafts: 10 uranium fuel + 100 hydrogen -> 10, 20 plutonium fuel + 16 molten
  lutetium -> 20).
* **Large naquadah reactors** (UV to UXV; techs `large-naquadah-reactor`, `uhv-naquadah-reactor` ... `uxv-naquadah-reactor`):
  5x5 `generator` entities like the turbines that burn only naquadah based fuel MK1 to MK3 and the excited uranium and
  plutonium fuels (fuel check below), capped at 4 x EU32 of the tier (327.68 MW, 655.36 MW, 1.31, 2.62, 5.24 and
  10.49 GW). The UV one: controller (UV hull, 4 UV circuits, 2 ZPM field generators, 4 ZPM pumps, naquadah and osmium
  plates, trinium and indalloy melt), the UV dynamo hatch, 48 naquadah reactor casings (4 naquadah plates, 4 lead plates, a
  thick neutron reflector, a europium plate) and 4 UV hulls; UHV to UXV are upgrades (previous reactor + dynamo hatch + 4
  hulls). GT's coolant bonus and depleted fuel output are left out.
* **Dynamo hatches LuV to UXV**: copies of the energy hatch recipe of the tier (same parts, category and time), like
  upstream's EV and IV dynamo hatches. Unlocked with the generator of their tier (UHV to UXV: by the plasma turbine and
  the naquadah reactor tech of the tier, whichever is researched first).
* **Fuel check** (issue #25). A `generator` burns any fluid with a fuel value, steam (100 kJ) included, and a fluid box
  filter takes a single fluid, so without a check a plasma turbine ran on naquadah fuel, a naquadah reactor on plasma
  (both at full output) and both on steam (6 MW, one unit per tick). `136-fork-power.lua` writes the accepted fuels of
  each generator into the mod data `fork-power` (`fuels`: the plasmas of the fuel value table for the turbines, the
  naquadah and excited fuels for the reactors, so a fuel added there is picked up). `scripts/fork-power.lua` tracks every
  generator (built, cloned, and all of them after a configuration change or once in an older save) and checks the fluid in
  its fluid box or pipeline segment every 10 ticks (round robin, at most 200 per step): a wrong fluid stops it
  (`disabled_by_script`, status "Wrong fuel: <fluid>"), the fluid stays in it; an empty generator is stopped too ("No
  fuel"), so a wrong fluid that arrives later is never burnt; with an accepted fuel it runs again (up to 10 ticks after the
  fuel arrives). Only generators the script stopped are switched back on. The window: a running generator whose fuel
  runs out and is replaced by a wrong fluid between two checks burns it until the next check, at most 10 ticks and one
  unit per tick (steam: 10 units, 1 MJ), once. The north/south input-output connection stays: generators are chained
  like steam engines, a generator in a steam or fuel line of the wrong fluid just stops and lets it through, and changing
  the connections would alter placed generators and their pipes.
* **Cooled fluid** (issue #28). A `generator` with effectivity 1 burns exactly energy / fuel value of its fluid, so the
  script adds up `energy_generated_last_tick` of every running turbine every tick (0 while it idles or runs dry; turbines
  stopped by a script are left out, a stopped generator keeps its last value) and every 10 ticks turns the sum into
  plasma burnt and owes the cooled fluid. The owed fluid goes into the hatches next to the turbine; what does not fit (full,
  or holding another fluid) stays owed for the next step without a limit, fractions included; without any hatch it is
  lost. When the plasma changes between two steps without the turbine being seen empty, the old plasma is credited with at
  most the amount it had at the start of the step and the rest of the step to the new fluid. Accuracy (`devcheck runtime`,
  "cooled fluid test"): 4, 2 and 1.5 helium plasma burnt to the last drop at full load, 40 % load and a 5-in-23-ticks
  burst load return 4.000004, 2.000002 and 1.500001 helium (float rounding of the tank, 1e-6); a full hatch keeps the rest
  owed and gets all of it once emptied; two turbines side by side on helium and nitrogen plasma fill only their own hatch.
  The test tolerance is 0.1 % + 0.001 units. The one-tick sample every 10 ticks it replaces returned 1.933 helium for 2
  plasma at 40 % load (-3.3 %), -1.7 % under a random load and -12 % under the burst load. Cost: one property read per
  running turbine per tick (about 0.25 µs), the fluid is read once per step.

### Balance

Energy per craft of a fusion recipe is the same in the MK1, MK2 and MK3 (each doubles speed and power: `energy_required` x
1.28 MJ); the MK4 and MK5 halve it (0.64 MJ). "Gain" is plasma energy out / reactor energy in per craft; "full chain" also
counts the machine energy of every input (see "Full-chain analysis" below). Issue #32 changed the values marked "before";
the new ones are in the table of `prototypes/136-fork-power.lua` (section 1b, plasma balance).

| Plasma | Fuel value per unit | Recipe (reactor) | Energy in per craft | Energy out per craft | Gain | Full chain | Units/s from one reactor | Plasma power |
|---|---|---|---|---|---|---|---|---|
| helium (D + He-3) | 81.92 MJ | 125 in 10 s (MK1; before 2 s) | 409.6 MJ | 10 240 MJ | 25x (before 125x) | 11.5x (before 29.6x) | 12.5 (before 62.5) | 1.02 GW (before 5.12) |
| helium (D + T) | 81.92 MJ | 125 in 10 s (MK1; before 4 s) | 409.6 MJ | 10 240 MJ | 25x (before 62.5x) | 6.2x (before 7.3x) | 12.5 (before 31.25) | 1.02 GW (before 2.56) |
| boron | 112.64 MJ | 14.4 in 12 s (MK1) | 491.5 MJ | 1622 MJ | 3.3x | 2.7x (before 3.0x) | 1.2 | 135 MW |
| calcium | 188.42 MJ | 16 in 32 s (MK1) | 1311 MJ | 3015 MJ | 2.3x | 2.2x | 0.5 | 94 MW |
| neon | 20.48 MJ | 1000 in 32 s (MK1) | 1311 MJ | 20 480 MJ | 2.7x (15.6x without its boron and calcium plasma) | 2.4x (before 2.5x) | 31.25 | 640 MW |
| sulfur | 170.39 MJ | 72 lithium + 72 aluminium melt -> 144 in 16 s (MK2; before 16 + 16 in 8 s) | 1311 MJ | 24 537 MJ | 18.7x (before 37x) | 16.8x (before 35.7x) | 9 (before 18) | 1.53 GW (before 3.07) |
| nitrogen | 129.02 MJ | 125 in 8 s (MK2; before 4 s) | 655.4 MJ | 16 128 MJ | 24.6x (before 49x) | 11.7x (before 15.3x) | 15.6 (before 31.25) | 2.02 GW (before 4.03) |
| zinc | 226.3 MJ | 72 in 8 s (MK2) | 655.4 MJ | 16 294 MJ | 25x | 6.0x | 9 | 2.04 GW |
| niobium | 269.52 MJ | 144 in 20 s (MK2; before 8 s) | 1638 MJ | 38 810 MJ | 23.7x (before 59x) | 15.6x (before 25.7x) | 7.2 (before 18) | 1.94 GW (before 4.85) |
| tin | 150 MJ | 288 in 24 s (MK2; before 8 s) | 1966 MJ | 43 200 MJ | 22x (before 66x) | 15.8x (before 55.8x) | 12 (before 36) | 1.8 GW (before 5.4) |
| titanium | 196.61 MJ | 144 in 80 s (MK2) | 6554 MJ | 28 312 MJ | 4.3x | 4.2x | 1.8 | 354 MW |
| oxygen | 131.07 MJ | 144 in 120 s (MK2) | 9830 MJ | 18 874 MJ | 1.3x (1.9x without its boron plasma) | 1.2x | 1.2 | 157 MW |
| krypton | 86.02 MJ | 144 in 16 s (MK2) | 1311 MJ | 12 386 MJ | 3.8x (9.4x without its niobium and zinc plasma) | 1.3x (before 1.5x) | 9 | 774 MW |
| iron | 206.44 MJ | 72 silicon + 72 magnesium melt -> 144 in 8 s (MK3; before 16 + 16 in 2 s) | 1311 MJ | 29 727 MJ | 22.7x (before 91x) | 17.2x (before 70.9x) | 18 (before 72) | 3.72 GW (before 14.9) |

Helium-3 (issue #32): `end-stone-centrifuging` makes 50 helium-3 per compressed end stone in 200 s (before 100 in 40 s),
1.92 MJ per unit like deuterium (before 0.19 MJ). The fuel values are unchanged (GT's). The recipes that use a plasma as an
ingredient keep their amounts: helium plasma in grade 5 water (10), boron plasma (14.4) and sunnarium (4); krypton plasma in
grade 6 water (10) and transcendent metal (14.4); boron and calcium plasma in neon plasma (144 and 16); boron plasma in
oxygen plasma (144); calcium plasma in flerovium (14.4); iron plasma in draconium (14.4); niobium and zinc plasma in krypton
plasma (144 each). They need little: a water purification plant on grade 5 water uses 0.5 helium plasma per second, one MK1
makes 12.5.

| Fuel | Fuel value per unit | Recipe (reactor) | Energy in per craft | Energy out per craft | Gain |
|---|---|---|---|---|---|
| excited uranium based liquid fuel | 1.296 GJ | 10 uranium fuel + 100 hydrogen -> 10 in 5 s (MK2) | 409.6 MJ | 12 960 MJ | 32x |
| excited plutonium based liquid fuel | 4.86 GJ | 20 plutonium fuel + 16 molten lutetium -> 20 in 5 s (MK2) | 409.6 MJ | 97 200 MJ | 237x |
| naquadah based fuel MK1 | 58.5 GJ | 780 light + 360 heavy naquadah fuel -> 100 in 12.5 s (MK2) | 1024 MJ | 5.85 TJ | 5700x |
| naquadah based fuel MK2 | 161 GJ | 100 MK1 + 1500 naquadah gas + nether star + naquadria -> 100 (UHV mixer) | - | 16.1 TJ | 2.75x MK1 |
| naquadah based fuel MK3 | 760.9 GJ | 100 MK2 + 800 heavy naquadah fuel + uranium, plutonium, naquadria -> 100 (UEV mixer) | - | 76.1 TJ | 4.7x MK2 |

Generators (4 amps of the tier) and what they burn at full load:

| Generator | Output | Helium plasma | Naquadah fuel MK1 | Excited uranium fuel | Cost |
|---|---|---|---|---|---|
| LuV large plasma turbine | 81.92 MW | 1/s | - | - | controller (LuV hull, 2 LuV circuits, 4 large naquadah alloy gears, 12 tungstensteel plates), LuV dynamo hatch (the parts of the LuV energy hatch), 28 tungstensteel turbine casings (168 tungstensteel plates, 28 titanium turbine casings), 14 tungstensteel frames, turbine rotor (16 plates, 8 screws, a long rod) |
| ZPM large plasma turbine | 163.84 MW | 2/s | - | - | LuV turbine + ZPM dynamo hatch + ZPM hull |
| UV large plasma turbine | 327.68 MW | 4/s | - | - | ZPM turbine + UV dynamo hatch + UV hull |
| UHV large plasma turbine | 655.36 MW | 8/s | - | - | UV turbine + UHV dynamo hatch + UHV hull |
| UEV large plasma turbine | 1.31 GW | 16/s | - | - | UHV turbine + UEV dynamo hatch + UEV hull |
| UIV large plasma turbine | 2.62 GW | 32/s | - | - | UEV turbine + UIV dynamo hatch + UIV hull |
| UMV large plasma turbine | 5.24 GW | 64/s | - | - | UIV turbine + UMV dynamo hatch + UMV hull |
| UXV large plasma turbine | 10.49 GW | 128/s | - | - | UMV turbine + UXV dynamo hatch + UXV hull |
| UV large naquadah reactor | 327.68 MW | - | 0.0056/s (1 unit per 3 min) | 0.25/s | controller (UV hull, 4 UV circuits, 2 ZPM field generators, 4 ZPM pumps, 8 naquadah and 8 osmium plates, 4 trinium ingots of melt, indalloy), UV dynamo hatch, 48 casings (192 naquadah plates, 192 lead plates, 48 thick neutron reflectors, 48 europium plates), 4 UV hulls |
| UHV large naquadah reactor | 655.36 MW | - | 1 unit per 89 s | 0.5/s | UV reactor + UHV dynamo hatch + 4 UHV hulls |
| UEV large naquadah reactor | 1.31 GW | - | 1 unit per 45 s | 1/s | + UEV dynamo hatch + 4 UEV hulls |
| UIV large naquadah reactor | 2.62 GW | - | 1 unit per 22 s | 2/s | + UIV dynamo hatch + 4 UIV hulls |
| UMV large naquadah reactor | 5.24 GW | - | 1 unit per 11 s | 4/s | + UMV dynamo hatch + 4 UMV hulls |
| UXV large naquadah reactor | 10.49 GW | - | 1 unit per 6 s | 8/s | + UXV dynamo hatch + 4 UXV hulls |

#### Full-chain analysis (issue #32)

Every machine here uses the same energy per recipe second at any tier (a LuV centrifuge is 32 times as fast as the LV one
and draws 32 times the power), so the energy of a chain does not depend on the machines the player builds: centrifuge
0.48 MJ, extractor 0.24 MJ, electrolyzer and electric blast furnace 0.6 MJ, fusion reactor 1.28 MJ per recipe second. The
full chain of a plasma is its reactor energy plus the machine energy of its inputs, charged fully to the main product
(byproducts such as the hydrogen of water electrolysis count as free), down to water and the microminer outputs. The
microverse projector, the ore processing up to the ingots and the poly-si dust are left out, so the metal plasmas are a
little dearer than shown. The inputs:

| Input | Recipe | Energy per unit | Per GW of plasma (new values) |
|---|---|---|---|
| deuterium | 100 water -> 5 in 20 s (centrifuge) | 1.92 MJ | 12.2/s for helium (1.5 LuV centrifuges, 244 water/s), 23.3/s for nitrogen |
| tritium | 160 deuterium -> 40 in 32 s (centrifuge) | 8.06 MJ | 12.2/s for D + T helium (another 49 deuterium/s) |
| helium-3 | 1 compressed end stone -> 50 in 200 s (centrifuge; before 100 in 40 s) | 1.92 MJ (before 0.19) | 12.2/s for helium (1.5 LuV centrifuges, 0.24 compressed end stone/s), 8.7/s for tin |
| molten metal | 1 ingot -> 14.4 in 19.2 s (extractor) | 0.32 MJ + the ingot | |
| silicon ingot | 1 poly-si dust in 127.2 s (electric blast furnace) | 76 MJ (5.3 MJ per unit of melt) | 0.17/s for iron (0.7 LuV blast furnaces), 0.26/s for niobium |
| aluminium ingot | 3 carbon + 10 alumina -> 4 in 120 s (electric blast furnace) | 18 MJ | 0.2/s for sulfur |
| lithium, magnesium | lepidolite and magnesia electrolysis | 6.4 MJ, 1.2 MJ | |

The raw materials are no limit: one EV microverse projector makes 64 tier three microminer outputs in 150 s, which are
4096 compressed end stone, and the ores come from the same microminers. What scaling costs is the reactor, the machines of
the chain and their power. Per GW of plasma power with the new values:

| Plasma | Reactors per GW | Reactor draw per GW | Chain draw per GW | Main inputs per GW |
|---|---|---|---|---|
| helium (D + He-3) | 0.98 MK1 | 40 MW | 47 MW (before: 0.2 MK1, 8 + 26 MW) | 12.2 deuterium + 12.2 helium-3/s |
| helium (D + T) | 0.98 MK1 | 40 MW | 122 MW | 12.2 deuterium + 12.2 tritium/s (61 deuterium/s in all) |
| nitrogen | 0.5 MK2 | 41 MW | 45 MW | 23.3 deuterium/s, 1 molten beryllium/s |
| sulfur | 0.65 MK2 | 53 MW | 6 MW | 2.9 molten lithium + 2.9 molten aluminium/s |
| niobium | 0.52 MK2 | 42 MW | 22 MW | 3.7 molten cobalt + 3.7 molten silicon/s |
| tin | 0.56 MK2 | 46 MW | 18 MW | 3.3 molten silver/s, 8.7 helium-3/s |
| iron | 0.27 MK3 | 44 MW | 14 MW | 2.4 molten silicon + 2.4 molten magnesium/s |

A base to compare with, one of every machine of a tier at full load (the machines `iv-*` to `uv-*`, multiblocks included):
IV 0.39 GW (53 machines), LuV 0.45 GW (38), ZPM 0.87 GW (37), UV 1.72 GW (36); one of each from IV to UV draws 3.4 GW.
Before, one MK1 on D + He-3 (5.12 GW) ran more than all of them together. Now one MK1 (1.02 GW) runs one of each IV and LuV
machine (0.84 GW); a ZPM base needs a second MK1 or an MK2 (2.05 GW on helium), a UV base an MK3 (4.1 GW on helium, 3.72 GW
on iron) or two MK2. The other power of these tiers: below fusion there is only steam (vanilla nuclear reactor and steam
turbines, 5.82 MW per turbine), so fusion stays by far the strongest option of LuV and ZPM. At UV the naquadah fuel line
arrives: naquadah based fuel MK1 is more than 100x its processing energy (the enriched naquadah left out), and one EV blast
furnace on acid naquadah emulsion feeds 2.08 GW; it is limited by the naquadah, not by energy (see "Open points").

The band: the cheap plasmas (helium, sulfur, nitrogen, niobium, tin, iron) are 11.5x to 17.2x over the full chain and 18.7x
to 25x at the reactor, so one reactor makes about 25 times its draw: 1 GW per MK1, 2 GW per MK2, 4 GW per MK3. Zinc (6x, it
needs tritium) and D + T helium (6.2x) stay below the band; boron, calcium, neon, titanium, oxygen and krypton (1.2x to
4.2x) are ingredients first and stay as they were. Order of the levers: the input cost first (helium-3 at the price of
deuterium; half an ingot of each metal for sulfur and iron, whose nugget inputs cost nothing), then the recipe time for the
output per reactor (helium x5, tin x3, niobium x2.5, nitrogen and sulfur x2, iron x4); the fuel values stay GT's. The input
cost alone could not do it: with the upstream times one MK1 would still make 5.12 GW, whatever its inputs cost.

#### Comparison with GT5-Unofficial

GT5-Unofficial (GTNH), `FusionReactorRecipes.java`, with 1 EU = 1 kJ like here. The fuel values are the same (EU per L,
`ProcessingCell.java`; the large plasma turbine makes fuel value x flow EU, times the plasma efficiency of its rotor):

| Plasma | GT recipe | GT energy per craft | GT gain at the reactor | Start-up energy | Here, new |
|---|---|---|---|---|---|
| helium (D + He-3) | 125 + 125 -> 125 in 16 ticks at 1920 EU/t | 30.7 MJ | 333x | 60 GJ | 25x |
| helium (D + T) | 125 + 125 -> 125 in 16 ticks at 3840 EU/t | 61.4 MJ | 167x | 40 GJ | 25x |
| sulfur | 16 aluminium + 16 lithium -> 144 in 32 ticks at 10 240 EU/t | 327.7 MJ | 75x | 240 GJ | 18.7x |
| nitrogen | 16 beryllium + 375 deuterium -> 125 in 16 ticks at 15 360 EU/t | 245.8 MJ | 66x | 180 GJ | 24.6x |
| niobium | 144 cobalt + 144 silicon -> 144 in 16 ticks at 49 152 EU/t | 786 MJ | 49x | 200 GJ | 23.7x |
| tin | 144 silver + 375 helium-3 -> 288 in 16 ticks at 49 152 EU/t | 786 MJ | 55x | 280 GJ | 22x |
| iron | 16 silicon + 16 magnesium -> 144 in 32 ticks at 7680 EU/t | 245.8 MJ | 121x | 360 GJ | 22.7x |

GT's reactor is even more generous than Gregtorio's was (one MK1 on D + He-3: 156 helium plasma per second, 12.8 GW). What
limits it there:

* **The inputs.** Hydrogen from water electrolysis (1000 water -> 2000 hydrogen, 100 s at 30 EU/t: 0.03 MJ per unit),
  deuterium from 160 hydrogen (8 s at 20 EU/t: 0.2 MJ), tritium from 160 deuterium (8 s at 80 EU/t: 1.12 MJ), helium-3 from
  80 helium (8 s at 80 EU/t) and the helium from endstone dust (36 dust -> 4320 helium in 9.6 min): 3.4 MJ and 0.13
  endstone dust per unit of helium-3. At the base tier of each machine GT's full chain is 21x for D + He-3 (helium-3 is the
  cost) and 45x for D + T, before start-up and turbines. Here deuterium was already 10 times GT's energy (1.92 MJ, water
  straight to deuterium) and helium-3 a twentieth of it (0.19 MJ); helium-3 now costs 1.92 MJ.
* **Overclocking.** A GT machine above the recipe's tier runs twice as fast for four times the power, so each tier doubles
  the energy per craft. The deuterium and helium-3 recipes are LV (20 and 80 EU/t); in LuV machines they cost 32 times the
  energy, and GT's chain falls to a few x unless the player builds many low tier machines. Gregtorio has no such loss (the
  energy per craft is the same at every tier), which is why its chain gains stayed high.
* **Start-up energy** (40 to 360 GJ, stored in the energy hatches before the first craft) and the reactor tier it needs: a
  one-time cost that is not built here (the reactor starts at once).
* **Turbines.** The flow of a large plasma turbine is set by its rotor, and the efficiency drops away from the optimal flow.
  Here the turbine is capped at four amps of its tier and burns at 100 %.

So the 11x to 17x here sits between GT's full chain at the base tier (21x to 45x for helium) and GT with overclocked
machines (a few x), with the reactor at about 25x instead of GT's 50x to 330x: the output per reactor, which GT limits
through input logistics and turbine flow, is limited here by the recipe time.

Net gain in practice (issue #32; before: one MK1 on D + He-3 made 62.5 helium plasma per second, 5.12 GW for 62 LuV
turbines, a net 5.08 GW): one MK1 on deuterium and helium-3 (40.96 MW) makes 12.5 helium plasma per second, 1.02 GW, and
its deuterium and helium-3 draw another 48 MW (3 LuV centrifuges), a net 0.94 GW. The turbines one reactor feeds on its cheap
plasmas (issue #34 added the UHV to UXV turbines and the MK4 and MK5; the turbine of the reactor's own machine tier in
bold, "before" is before issue #32):

| Reactor | Plasma | Plasma power | LuV | ZPM | UV | UHV | UEV | UIV | UMV | UXV | Before (LuV / ZPM / UV) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| MK1 (40.96 MW) | helium | 1.02 GW | **12.5** | 6.25 | 3.1 | 1.6 | 0.8 | 0.4 | 0.2 | 0.1 | 5.12 GW: 62.5 / 31 / 15.6 |
| MK2 (81.92 MW) | helium (MK1 recipe) | 2.05 GW | 25 | **12.5** | 6.25 | 3.1 | 1.6 | 0.8 | 0.4 | 0.2 | 10.24 GW: 125 / 62.5 / 31 |
| MK2 | nitrogen | 2.02 GW | 24.6 | **12.3** | 6.2 | 3.1 | 1.5 | 0.8 | 0.4 | 0.2 | 4.03 GW: 49 / 24.6 / 12.3 |
| MK2 | tin | 1.8 GW | 22 | **11** | 5.5 | 2.7 | 1.4 | 0.7 | 0.3 | 0.2 | 5.4 GW: 66 / 33 / 16.5 |
| MK3 (163.84 MW) | helium (MK1 recipe) | 4.1 GW | 50 | 25 | **12.5** | 6.25 | 3.1 | 1.6 | 0.8 | 0.4 | 20.5 GW: 250 / 125 / 62.5 |
| MK3 | nitrogen | 4.03 GW | 49 | 24.6 | **12.3** | 6.2 | 3.1 | 1.5 | 0.8 | 0.4 | 8.06 GW: 98 / 49 / 24.6 |
| MK3 | tin | 3.6 GW | 44 | 22 | **11** | 5.5 | 2.7 | 1.4 | 0.7 | 0.3 | 10.8 GW: 132 / 66 / 33 |
| MK3 | iron | 3.72 GW | 45 | 22.7 | **11.3** | 5.7 | 2.8 | 1.4 | 0.7 | 0.4 | 14.9 GW: 181 / 91 / 45 |
| MK4 (327.68 MW) | helium | 16.4 GW | 200 | 100 | 50 | 25 | **12.5** | 6.25 | 3.1 | 1.6 | 82 GW: 1000 / 500 / 250 |
| MK4 | nitrogen | 16.1 GW | 197 | 98 | 49 | 24.6 | **12.3** | 6.2 | 3.1 | 1.5 | 32 GW: 394 / 197 / 98 |
| MK4 | tin | 14.4 GW | 176 | 88 | 44 | 22 | **11** | 5.5 | 2.7 | 1.4 | 43 GW: 527 / 264 / 132 |
| MK4 | iron | 14.9 GW | 181 | 91 | 45 | 22.7 | **11.3** | 5.7 | 2.8 | 1.4 | 59 GW: 726 / 363 / 181 |
| MK5 (655.36 MW) | helium | 32.8 GW | 400 | 200 | 100 | 50 | 25 | **12.5** | 6.25 | 3.1 | 164 GW: 2000 / 1000 / 500 |
| MK5 | nitrogen | 32.3 GW | 394 | 197 | 98 | 49 | 24.6 | **12.3** | 6.2 | 3.1 | 65 GW: 787 / 394 / 197 |
| MK5 | tin | 28.8 GW | 352 | 176 | 88 | 44 | 22 | **11** | 5.5 | 2.7 | 86 GW: 1055 / 527 / 264 |
| MK5 | iron | 29.7 GW | 363 | 181 | 91 | 45 | 22.7 | **11.3** | 5.7 | 2.8 | 119 GW: 1452 / 726 / 363 |

Without the turbines of issue #34 one MK4 needed 50 UV turbines on helium and one MK5 100; with them it is 12.5 of the
reactor's own tier, as for the MK1 to MK3.

One EV blast furnace on acid naquadah emulsion (16 enriched naquadah dust per 180 s) feeds 0.036 naquadah fuel MK1 per
second through the line, worth 2.08 GW of naquadah reactor output; one enriched naquadah dust is 23.4 GJ of MK1 fuel. The
generators burn only their own fuels (fuel check above): steam, plasma in a naquadah reactor or naquadah fuel in a plasma
turbine stop them.

### Turbines above UV (issue #34)

Numbers: researchable technologies 355 -> 360 of 374 -> 379 (the 5 new ones), draft recipes hidden by the draft guard 21
-> 21, `FORK-DRAFT` and `FORK-AUTOUNLOCK` identical to main, unlocked but uncraftable recipes 0. Tech by tech: the 374
technologies of main keep their prerequisites, science packs and unlocks; the new ones unlock the dynamo hatch and the
turbine of their tier (the dynamo hatches UHV to UXV are now unlocked by two techs each, the plasma turbine and the
naquadah reactor of the tier).

| Turbine | Output | Helium plasma at full load | Recipe (60 s in the tier's assembling machine) | Technology (science) | Prerequisites |
|---|---|---|---|---|---|
| UHV large plasma turbine | 655.36 MW | 8/s | UV turbine + UHV dynamo hatch + UHV hull (UV dynamo hatch and UV hull back) | `uhv-plasma-turbine` (UHV, 2500) | `uv-plasma-turbine`, `uhv-energy-hatches` |
| UEV large plasma turbine | 1.31 GW | 16/s | UHV turbine + UEV dynamo hatch + UEV hull | `uev-plasma-turbine` (UEV, 2500) | `uhv-plasma-turbine`, `uev-energy-hatches` |
| UIV large plasma turbine | 2.62 GW | 32/s | UEV turbine + UIV dynamo hatch + UIV hull | `uiv-plasma-turbine` (UIV, 2500) | `uev-plasma-turbine`, `uiv-energy-hatches` |
| UMV large plasma turbine | 5.24 GW | 64/s | UIV turbine + UMV dynamo hatch + UMV hull | `umv-plasma-turbine` (UMV, 2500) | `uiv-plasma-turbine`, `umv-energy-hatches` |
| UXV large plasma turbine | 10.49 GW | 128/s | UMV turbine + UXV dynamo hatch + UXV hull | `uxv-plasma-turbine` (UXV, 2500) | `umv-plasma-turbine`, `uxv-energy-hatches` |

They are the same `generator` prototype as the LuV to UV turbines (fuel check, turbine output hatch, fast replace group),
listed in the mod data `fork-power`, so `scripts/fork-power.lua` picks them up without a code change or a migration.

**Fluid usage per tick.** A `generator` burns at most `fluid_usage_per_tick` units per tick, so with 1 unit (LuV to UV) it
could never make more than 60 x the fuel value per second: 4.92 GW on helium plasma, 1.23 GW on neon. The UXV turbine made
4.92 GW instead of 10.49 GW on helium, the UMV turbine was short as well, the UEV one on neon. `make_generator` now sets it
to the cap divided by the weakest accepted fuel (neon plasma for the turbines, excited uranium fuel for the reactors),
rounded up: 1 for LuV to UHV and every naquadah reactor (unchanged), 2, 3, 5 and 9 for UEV, UIV, UMV and UXV. The fuel
check window grows with it on those four: steam in a UXV turbine burns at most 90 units (9 MJ) in the 10 ticks.

**GT++'s XL plasma turbine** (`MTELargerTurbinePlasmaLegacy`: "runs as fast as 16 Large Turbines", 12 rotor hatches, any
number of dynamo hatches of mixed voltage, no tier of its own; plasma efficiency falls for high tier rotors on low grade
plasma) is not followed. Here there are no rotors and no flow; the tier of the dynamo hatch sets the output of every
generator (the turbines LuV to UV and the naquadah reactors UV to UXV). An XL turbine as 16 UV turbines would be a
5.24 GW generator from UV, skip the UHV to UMV hatches and give one step instead of a line. One turbine per tier keeps
the pattern of the reactors, uses the dynamo hatches that already exist and the fast replace upgrade. It gives the XL
turbine's advantage too, fewer entities per GW: a UXV turbine replaces 32 UV turbines, and the runtime cost is per turbine
(one property read per running turbine per tick, unchanged), so a 16 GW MK4 on helium is 12.5 UEV turbines (13 reads per
tick) instead of 50 UV turbines.

**MK4 and MK5 (decision: unchanged).** The MK4 and MK5 run the fusion recipes 16 and 32 times as fast as the MK1 because
they run at the speed of their tier (UEV_SPEED 512 and UIV_SPEED 1024, like every machine), and every reactor from MK1 to
MK5 feeds 12.5 turbines of its own machine tier on helium (11 to 12.3 on nitrogen, tin and iron; table in "Net gain in
practice"). Measured against one of every machine of the tier that researches it (IV 0.39, LuV 0.45, ZPM 0.87, UV 1.72,
UHV 3.44, UEV 6.88, UIV 13.76, UMV 27.5, UXV 55 GW), one reactor on helium runs 2.3 LuV bases (MK1), 2.4 ZPM (MK2), 2.4 UEV
(MK4) and 2.4 UIV bases (MK5). A change of the MK4 and MK5 would break this line; the one that is off is the MK3 (UV speed,
UHV research: 1.2 UHV bases, see "Open points"). What the MK4 and MK5 do change: half the energy per craft (0.64 MJ per
recipe second), so a reactor makes 44x to 50x its draw instead of 22x to 25x and the full chain rises from 11.5x to 14.9x
(helium), 11.7x to 15.3x (nitrogen), 15.7x to 24.5x (tin) and 17.2x to 27.7x (iron). Kept, and listed as an open point.

Tests (`devcheck runtime`): the fuel check test has a UXV turbine on steam and a UEV turbine on naquadah fuel (stopped
with "Wrong fuel", fluid kept, then they run on helium plasma); the new turbine tier test runs one UHV to UXV turbine each
(helium, nitrogen, iron plasma) and a UXV one on neon under twice their output: each makes exactly four amps of its tier
and its hatch holds the cooled fluid for the plasma burnt (helium, nitrogen, molten iron, neon; worst error 1.3e-7).

### Deviations from GT

* One generator entity per tier and fuel family instead of GT's single multiblocks whose output the dynamo hatch caps;
  no turbine rotor materials, fitting or overflow efficiency; the plasma efficiency is 100 %.
* No XL plasma turbine (GT++); the UHV to UXV turbines take its place (issue #34, see "Turbines above UV").
* The cooled fluid goes to a separate output hatch entity (runtime), up to 10 ticks after the plasma was burnt; it is
  exact (see "Cooled fluid" above). What does not fit into the hatches waits in the turbine instead of being voided.
* The naquadah reactor has no depleted fuel output and no coolant bonus; fuel MK4 to MK6 are not built (orundum, awakened
  draconium, hypogen, atomic separation catalyst are not in the mod). The chain skips naquadah asphalt, the cracking of the
  fuels (removed for good in issue #39 with the atomic separation catalyst), antimony trioxide, tiberium, high density uranium
  and ~~plutonium~~ (high density plutonium is built since issue #39) and the naquadah fuel refinery.
* GT's single-block naquadah reactors (naquadah rods) and single-block plasma generators are not built.

### Existing saves

Nothing that was unlocked changes; the recipes this side quest turns from drafts into real ones (`acid-naquadah-emulsion`,
`naquadah-emulsion`, `naquadah-solution`, `radioactive-sludge-centrifuging`, `naquadah-based-fuel-mk1`,
`plutonium-based-liquid-fuel`, the two excited fuels) were hidden before. The plasma recipes are unchanged. `migrate
--from-ref 0e935ba` and `--from-ref v0.3.0` load. Turbines placed with the sampling version of the cooled fluid (before
issue #28, not released) keep their owed fluid and run on; `migrate` builds one under load in the old save and checks the
helium for its plasma after the update (`plasma turbine of the old save`).
Issue #34 (UHV to UXV turbines): the prototypes of the LuV to UV turbines and of the reactors are unchanged (same names,
fluid usage 1), `storage.fork_power` keeps its layout; the new turbines are registered like the old ones when they are
built. Researched `*-naquadah-reactor` techs keep their dynamo hatch. `migrate --from-ref v0.3.1` loads, and its LuV
turbine returns 2.0000 helium for 2.0000 plasma after the update.

### Open points

* Balance is untested in game: the caps of the generators (4 amps), the plasma balance of issue #32 (about 1 GW per MK1,
  11x to 17x over the full chain for the cheap plasmas), the naquadah chain's yields, the recipe times of the turbine and
  reactor parts.
* The naquadah fuel line (UV) is more than 100x its processing energy and feeds 2.08 GW per EV blast furnace, stronger per
  unit of energy than any plasma; it is limited by enriched naquadah. Not changed in issue #32.
* ~~The MK4 and MK5 run the MK1 to MK3 plasma recipes 16 and 32 times as fast as the MK1 (one MK4 on helium: 16.4 GW for
  327.68 MW); there are no turbines above UV yet.~~ Issue #34: UHV to UXV turbines; the MK4 and MK5 speed stays (see
  "Turbines above UV").
* The MK3 runs at UV speed but is researched with UHV science (the MK1, MK2, MK4 and MK5 run at the speed of their
  research tier): at UHV one MK3 (4.1 GW on helium) runs 1.2 UHV bases instead of the 2.4 of the others, and the MK3 to
  MK4 step is 4x instead of 2x. UHV speed (8.2 GW, 12.5 UHV turbines) would fit the line; not changed in issue #34 (it
  changes the MK3 numbers of issue #32).
* The MK4 and MK5 need half the energy per craft (0.64 MJ per recipe second), so their plasmas are 44x to 50x their
  reactor draw and 15x (helium, nitrogen) to 28x (iron) over the full chain, above the 11x to 17x band of the MK1 to MK3.
  Kept: at UEV the reactor draw is a small part of the base (one of each UEV machine: 6.9 GW).
* Graphics: the turbines use the GT large turbine front (tungstensteel) as a top-down sprite, the reactors the GT naquadah
  reactor casing with the radiation proof casing inside; every tier shows four GT dynamo hatches of its tier on the corner
  tiles (issue #41; before, the tiers above LuV/UV were tinted copies); the output hatch is the ME fluid interface in
  orange; the hatch and part icons come from GT textures (issue #40; before, recolored placeholders).
* ~~The cooled fluid could become exact with a per-tick sample~~ (done, issue #28: the energy is summed every tick). An
  engine-only turbine (one `fusion-generator` entity per plasma with filtered input and output, or GT's single-block
  plasma generators) would drop the script and the hatch entity, but needs one entity per plasma and tier and a migration
  of placed turbines; not needed for accuracy any more.
* Left of the cooled fluid: a turbine switched off by another mod (`active = false`) keeps its last
  `energy_generated_last_tick` and would be counted; a plasma change within one step can shift at most that step's burn
  between the two plasmas.
* ~~The MK3 reactor and up make plasma faster than a few turbines burn it; higher tier turbines (UHV+, like GT++'s XL
  turbines) would use it.~~ Done in issue #34 (UHV to UXV turbines).
* Balance of the UHV to UXV turbines is untested in game: their recipe times (60 s of the tier's assembler), the flow
  of 128 helium plasma per second into one UXV turbine, and whether one per tier is enough steps.

## Side quest: water purification grades 7 and 8 (done)

Issue #35. Numbers: researchable technologies 329 -> 332 of 371 -> 374 (the 3 new ones), draft recipes hidden by the draft guard
21 -> 21 (the `FORK-DRAFT` lines are identical), auto-unlocked recipes 54 -> 54 (the `FORK-AUTOUNLOCK` lines are identical), machines
placed by `devcheck runtime` 510 -> 510 (no new machine; the new recipe test places 16 more above the grid), unlocked but uncraftable
recipes 0. The tech-by-tech unlock diff against `origin/main` only adds the 12 recipes of the new techs; no unlock was lost or moved, no
technology became unresearchable.

Everything is in `prototypes/129-fork-water-purification.lua`; the hatches and controllers that take the new chips are changed where they
are defined (131 to 134), and the dynamo hatches of 136 copy the energy hatch recipes, so they follow.

New technologies:

| Technology | Science | Prerequisites | Unlocks |
|---|---|---|---|
| `complex-smds` | UV | `uhv-materials` | complex SMD transistor, resistor, capacitor, diode, inductor |
| `femto-power-ics` | UHV | `pico-quantum-power-ics`, `uhv-energy-hatches`, `uev-materials` | grade 7 water, FPIC wafer, Femto Power IC |
| `atto-power-ics` | UEV | `femto-power-ics`, `uev-machines`, `optical-processor-mainframes` | quark creation catalyst, grade 8 water, APIC wafer, Atto Power IC |

Changed prerequisites: `wetware-processor-mainframes` + `complex-smds`; `uev-energy-hatches` + `femto-power-ics`; `fusion-reactor-mk4`
`femto-power-ics` instead of `pico-quantum-power-ics`; `uiv-energy-hatches`, `umv-energy-hatches`, `uxv-energy-hatches` and `fusion-reactor-mk5`
+ `atto-power-ics`.

Recipes:

- **Grade 7** (plant, 25 s): 1000 grade 6 water, 500 helium, 14.4 molten neutronium, 100 cryogenic helium, 1 triamerotronium dust -> 900.
- **Grade 8** (plant, 30 s): 1000 grade 7 water and a quark creation catalyst, which comes back in 9 of 10 crafts -> 900. The catalyst (ZPM
  assembly line, 1 min) is GT's catalyst housing: 16 plates each of neutronium, infinity, tritanium and cosmic neutronium, 32 fine tritanium
  and cosmic neutronium wires, 16 UHV and 8 UEV circuits, a UEV field generator, 16 ingots of melt each of the four metals.
- **FPIC wafer** (UHV laser engraver): americium doped wafer, infinity foil, 10 grade 7 water. **APIC wafer** (UEV laser engraver):
  americium doped wafer, infinity foil, 2 cosmic neutronium foils, 10 grade 8 water. **Chips**: 2 per wafer with lubricant (UHV / UEV
  assembling machine), like the NPIC to QPIC.
- **Complex SMDs** (UV assembling machine, 15 s, 16 per craft, 57.6 polybenzimidazole each): transistor = 2 tritanium foils, 16 fine
  tritanium wires, 4 neutronium screws; resistor = 4 graphene, 16 fine tritanium wires; capacitor = 8 thin PBI sheets, 2 tritanium foils,
  4 neutronium screws; diode = 2 indium gallium phosphide, 16 fine tritanium wires; inductor = neutronium ring, 32 fine tritanium wires,
  4 neutronium screws.

Where the chips go (GT: 2 chips of the tier per hatch; the fork has used 4 since phase 5a):

| Recipe | Before | Now | GT |
|---|---|---|---|
| UEV energy / dynamo hatch | 4 QPIC | 4 FPIC | 2 FPIC |
| UIV energy / dynamo hatch | 8 QPIC | 4 APIC | 2 APIC |
| UMV energy / dynamo hatch | 16 QPIC | 8 APIC | 2 ZPIC (not built) |
| UXV energy / dynamo hatch | 32 QPIC | 16 APIC | 2 YPIC (not built) |
| MK4 controller | 48 QPIC wafers | 48 FPIC wafers | 64 FPIC wafers |
| MK5 controller | 64 QPIC wafers | 64 APIC wafers | 64 APIC wafers |

Unchanged on purpose: the MK2 controller keeps NPIC wafers (GT: PPIC; the americium they need comes from the MK2 itself), the MK3 controller
QPIC wafers and the ZPM/UV/UHV hatches NPIC/PPIC/QPIC are GT's, the energy module keeps UHPIC wafers (GT: ASOC wafers, not a power IC).

Complex SMDs replace advanced SMDs in the recipes GT builds with them (GT takes 4 complex SMDs instead of 16 advanced ones, so the counts are
a quarter): wetware mainframe (32 inductors, 64 capacitors instead of 8 inductor and 16 capacitor wraps), bio supercomputer and mainframe,
optical assembly, supercomputer and mainframe. The exotic and temporal lines (133 and 134, no GT recipe with SMDs) follow the optical line.
The processors and the wetware and bio assemblies keep advanced SMDs, as in GT.

Choices and deviations from GT:

- **One plant, one recipe per grade**, no linkage blocks, 90 % yield like grades 1-6. The degasifier's control signals (one random inert gas,
  a superconductor, a catalyst and coolant per cycle) become one recipe with all of them; the gas is helium (GT: helium 10 000, neon 7500,
  krypton 5000 or xenon 2500 per cycle), because neon, krypton and xenon come only from liquid ender air, which no line makes. Super coolant
  is ~~cryogenic helium (like the UV to UXV hatches)~~ super coolant since issue #36 (100 per craft; grade 5 takes 100 as well, like GT); the superconductor is triamerotronium dust (GT: the base melt of the UHV superconductor).
- **Quark extraction without catalyst alignment.** GT puts two of six aligned quark catalysts in, gets two unaligned ones and stable baryonic
  matter out, and realigns them in a laser engraver (the first ones come from the plasma forge, UMV). Here one reusable catalyst item (GT's
  housing recipe) that breaks in 1 of 10 crafts; no baryonic matter. One catalyst lasts about 9000 grade 8 water, 900 APIC wafers.
- **FPIC and APIC wafers** follow the NPIC to QPIC pattern (americium doped wafer + purified water in the laser engraver). GT engraves the FPIC
  with a beamline mask prepared from the QPIC mask with infinity catalyst (hence the infinity foil); GT5-Unofficial has no recipe that makes the
  APIC wafer, so its extra foils are invented. Grade 7 and 8 water appear here and not elsewhere: GT uses them for the neutron accelerators and
  plasma forge recipes, which the mod does not have.
- **Tier placement.** Grade 7 needs triamerotronium (`uhv-energy-hatches`) and the FPIC an infinity foil (`uev-materials`), both UHV science.
  Grade 8's catalyst needs a UEV field generator, which takes UIV circuits since phase 5a, so `atto-power-ics` comes after the optical mainframe
  (UEV science). The UIV hatch techs need the UIV circuit anyway.
- **Complex SMDs** come from the UV assembling machine (GT: nanochip assembly complex with its own circuit components, not in the mod), shaped
  like the advanced SMD recipes one tier of materials up. They are UV science so the UHV circuit (wetware mainframe) can use them.

Existing saves:

- `uev-energy-hatch`, `uiv-energy-hatch`, `umv-energy-hatch`, `uxv-energy-hatch` (and their dynamo hatches), `fusion-reactor-mk4-controller`,
  `fusion-reactor-mk5-controller` and the circuit recipes above changed ingredients. They stay unlocked by their techs; saves that researched
  them need `femto-power-ics` / `atto-power-ics` / `complex-smds` before they can craft them again (same as in phase 5a). Researched techs stay
  researched when they get a new prerequisite.
- Everything else only adds recipes and techs. `migrate --from-ref 0e935ba`, `--from-ref v0.3.0` and `--from-ref origin/main` load.

Tests: `devcheck check` lists the 12 new recipes in `REQUIRED_RECIPES` (unlocked by a researchable tech, products obtainable); `devcheck runtime`
crafts grades 7 and 8, the wafers and chips, the five complex SMDs, the catalyst, the UEV and UIV energy hatches, the MK4 controller and the wetware
mainframe once each in a real machine (`recipe test: ok`).

The icons of the new items and techs come from GT textures since issue #40 (`tools/gen_gt_icons.py`). Open: balance (catalyst life, SMD and chip
costs) is untested in the real game.

## Side quest: AE2 autocrafting (done)

Player guide and the full design: `docs/AE2.md`. Summary:

* **Content** (`prototypes/121-fork-ae2-autocrafting.lua`, tech `me-autocrafting`, EV, after `me-storage-64k`): ME Pattern Provider,
  ME Molecular Assembler (item-only recipes, speed 6), ME Crafting CPU (2x2, needs power). Sprites and icons from
  `tools/gen_ae2_sprites.py`.
* **Patterns:** a provider next to any assembling machine or furnace inside the network makes that machine's recipe a pattern.
  Recipes with fluids work since the fluid support (below) when the used fluid boxes have no pipes; machines the network cannot
  use are counted per reason in the terminal.
* **Planning:** recursive, storage first, loops and shortfalls reported before the start; the job only starts when the plan is
  complete.
* **Jobs:** the planned items are taken into the job's own pool at the start; the CPU feeds idle pattern machines by script in bounded steps
  (20 ticks, 6 machine interactions per job and step) and collects their products; the pool is stored at the end. Cancel and failure give
  everything back. One CPU = one job at a time.
* **GUI:** the ME Terminal got a Crafting tab: craft list (also at 0 in stock), amount, plan preview, job list with progress, status
  and cancel.
* **Tests:** the runtime test of `tools/devcheck` builds a network and runs a two-level job, a job that lacks raw material, a queued job that is
  cancelled, CPU and machine removal during jobs and a GT machine as pattern machine. Existing saves: nothing changes for existing
  ME networks; the state is created lazily and rebuilt in `on_configuration_changed`.

### Fluids (done)

Numbers: researchable technologies 317 -> 319 of 359 -> 361 (the two new ones), unlocked but uncraftable recipes 0.

* **Content** (`prototypes/122-fork-ae2-fluids.lua`, techs `me-fluid-storage` (EV, after `me-autocrafting`) and `me-fluid-storage-256k`
  (IV, after `me-storage-256k`)): fluid storage cells (housing + storage component + pump, 8000 units per "1k"), ME Fluid Drives 1k to
  256k (four cells: 32 000 to 8 192 000 units, with disassembly recipes) and the ME Fluid Interface (1x1 tank of 5000 units).
  Graphics from `tools/gen_ae2_sprites.py --fluids` (derived from the item PNGs, no GT checkout needed).
* **Storage** (`scripts/fork-me-fluids.lua`): the logistic network has no fluids, so a fluid drive is a passive entity whose contents
  are a `fluid -> amount` table in `storage.fork_me_fluids`; the network total is the sum over the drives standing in the network
  (looked up on demand, so merging or splitting networks needs nothing). Fluids are stored by name without temperature. A picked up
  drive carries its contents on the item (tags, shown in the tooltip) and gives them back when placed; a destroyed drive loses them.
* **Interface:** import (default) empties the fluid segment connected to it into the network, export fills it with a chosen fluid up to
  a chosen level (panel next to the tank GUI). Every 15 ticks, 8 interfaces round robin, booking only the engine's return values.
* **Autocrafting:** items and fluids are resources (`fluid/<name>` keys) in stock, plan and job pool; a pattern machine with a fluid
  recipe is used when the boxes the recipe needs have no pipes: the CPU sets the input boxes by index (fixed point safe amounts plus
  a 0.01 margin), waits until less than one craft is left, drains the output boxes and counts crafts with `products_finished`.
  Ignored machines are counted per reason (`stack`, `fluid-box`, `fluid-pipes`, `fluid-temperature`).
* **GUI:** the terminal's storage tab lists the fluids and their capacity (not takeable by hand), the crafting tab lists fluids with
  their unit amounts, the "open GUI" key on a drive shows its contents.
* **Tests:** the runtime test of `tools/devcheck` (1500 ticks now) builds a second network with a tank feeding an import interface,
  an export interface, a drive round trip by script and by construction robots, a reactor with a pipe that must be ignored, a reported
  fluid shortfall and three fluid jobs (fluid in and out, out only, in only); fluid conservation and amounts are checked.

### Open points

* One temperature per fluid: exported at the default temperature (hot steam loses its heat); recipes that need another temperature
  are not patterns. No fluid contents in blueprints (documented limit; the fluid interface settings are kept since issue
  #38); no per-drive fluid type limits or filters; the export
  level applies to the interface's own box (connected pipes share it). The fluid GUIs are untested in the real game.
* Recovery (issue #26, done): a destroyed drive's fluid goes into the other drives of its network, the rest is kept as recovered
  fluid (per surface, with its position) that the next drive placed in that network (or the drive GUI's Take over button) takes
  over; reported in the chat. The disassembly recipe is hand crafting only and recovers the fluid of a loaded item.
* Recovery follow-up (issue #43, done): the drives of a network pull its recovered fluid in by themselves when they have room (fluid
  step, 4 entries per step, round robin, reported once per entry); upgrading a loaded drive (upgrade planner with robots or on a
  platform, fast replace by hand) moves its fluid into the new drive, the rest into the network, then into the recovered fluid, and
  the old item carries none. Old and new drive are linked by spot and tick (`to_be_upgraded()` for robots, `on_pre_build` for the
  hand path; see `docs/AE2.md`, "Upgrades"). Open: the hand fast replace, the hand craft and cancel events and the chat reports are
  untested in the real game (the headless run has no player).
* Only normal quality; no items with own data; no spoilage in the job pool.
* Furnaces (issue #27, done): the pattern provider holds a recipe choice for the furnaces next to it (window on the "open" key:
  researched recipes of their categories), a pattern at once without a first smelt; copied by settings paste, blueprints and
  cloning, `previous_recipe` as fallback, furnaces without either counted as `no-recipe`. Open: a furnace whose input fits two of
  its recipes may smelt the other one (the job fails and returns its items); the window, paste and blueprint event are untested
  in the real game.
* ~~One job per CPU, no co-processor or CPU storage tiers, no "keep N in stock", no circuit network interface.~~ Done in
  "AE2 extras (issue #38)": CPU tiers with job slots and speed (no CPU storage: job sizes stay unlimited), the level
  maintainer, the circuit interface. ~~No fluid in blueprints~~: fluid interface settings are kept (drive contents stay
  on the item by design).
* The terminal GUI cannot be run headless: its layout (tabs, craft list, job list) and the sprites need a look in the real game;
  balance of costs, speeds and tier is untested.

### AE2 extras (issue #38, done)

Player guide and design: `docs/AE2.md` ("CPU tiers", "Keeping items in stock", "Circuit network", "Settings in blueprints
and copy/paste"). Numbers: 3 new technologies (`me-automation` EV, `me-co-processing` IV, `me-quantum-crafting` LuV), all
researchable; 4 new recipes and nothing else unlocked or auto-unlocked (`FORK-AUTOUNLOCK` unchanged).

* **Keep N in stock:** ME Level Maintainer (1x1 lamp, 30 kW, EV): one item or fluid and an amount; below it, a crafting job for
  the difference starts when a pattern exists and a powered CPU has a free slot; no second job while a job of the network
  crafts that resource. The lamp's circuit condition switches it; "amount from the circuit" reads the resource's signal.
* **CPU tiers:** ME Co-Processing Crafting CPU (IV: 2 jobs, 2x hand-overs) and ME Quantum Crafting CPU (LuV: 4 jobs, 4x), upgrade
  planner chain from the ME Crafting CPU. Numbers in the mod-data `fork-me-autocraft`; all jobs of a step share 96 hand-overs.
* **Circuit interface:** ME Circuit Interface (constant combinator, EV tech): items (with quality) and fluids (floored) of the
  network, or only its filters (20), refreshed about once a second.
* **Fluids in blueprints:** the fluid interface's mode, fluid and level are blueprint tags and copied by settings paste and
  cloning; the fluid drive has no settings (its contents stay on the item).
* **Tick budget:** no new interval: a step hook of the autocrafting step (20 ticks) checks 4 maintainers (at most one job start)
  and updates 2 circuit interfaces, round robin.
* **Tests:** `tools/devcheck` runtime: level maintainer (exactly one job, stops at N, refills the difference, circuit amount and
  condition), CPU tiers (two jobs at once, a third waits, quantum slots), circuit interface (wire equals the contents, filters,
  change), settings copy (blueprint tags, built and revived, paste, clone). `migrate --from-ref v0.3.1`: a job started with the
  old version finishes on the old CPU after the update.

#### Open points

* Untested in the real game: the maintainer and circuit interface panels (relative to the lamp and combinator GUIs), the lamp
  GUI's circuit condition set by hand, settings paste by hand between fluid interfaces (the prototype allows it through
  `additional_pastable_entities`), the upgrade planner on CPUs, the new sprites, balance of costs and tiers.
* No crafting request of several resources from the circuit network (AE2's "craft what the signal asks for"); one maintainer per
  resource. No CPU storage (AE2 crafting storage): a job's size is not limited by its CPU.
* The circuit interface refreshes 2 interfaces per 20 ticks: with many interfaces each is refreshed less than once a second.

## Balance pass: endgame (issues #30, #31, #33)

Method as in issue #32: analyse first, write it down, then change as little as needed. Every number below comes from the final
prototypes (recipes with amounts and times, machine speeds and technology counts from `devcheck.py check --balance-out`, a new section
of the devcheck dump) and the model `tools/balance_model.py`. The numbers in the issues were from 0.3.0 and are outdated (FPIC/APIC
hatches since #52, the fusion times of #32, the materials of #36).

### The model

For every item the model sums the machine time of its whole chain, from the raw inputs through the fusion reactors to the part
(machine-seconds per machine class; recipe time / machine speed). The time of an item in a reference factory is the largest
work / capacity over the machines that limit the endgame, all of them busy with that one item:

* **fusion reactors**, nested: an MK*k* recipe runs in any reactor from MK*k* up (speed MK1 32, MK2 64, MK3 128, MK4 512, MK5 1024);
* **ZPM assembly lines** (speed 32: every component from UV to UXV and the stargate parts; the LuV assembly line, 16, at LuV);
* **circuit assembly lines** (64: every circuit line), **bacterial vats** (1) and **water purification plants** (1).

The basic machines of the tier (speed 128 at UV to 4096 at UXV) are counted but built as needed; recipes below IV are commodity
supply. Byproducts are free (as in #32) except the loop fluids bacterial sludge and P507; the raw crystal chip comes from GT's loop
recipe (25 mutagen per chip, not the 1000 of the start recipe); at UV the neutronium comes from the MK2 bootstrap recipe.

What the bottleneck tables of phases 4, 5a and 5b missed: they counted ingots of the top metal only. Every endgame metal is made of
one or two ingots of each metal below it (universium = spacetime + flerovium, spacetime = transcendent metal + rhugnor, rhugnor =
infinity + transcendent metal, transcendent metal = infinity + krypton plasma, infinity = cosmic neutronium + draconium, cosmic
neutronium = neutronium + tritanium, tritanium = titanium + 2 duranium from the MK1, ...). One universium ingot is 26 000
reactor-seconds (at speed 1) over its chain, 17 times its own MK5 recipe. The stargate took 32 hours of the UXV factory, not the
8.5 hours of one MK5 of phase 5b.

### Reference factory

One "unit" of a tier's power is 12.5 large plasma turbines of the tier on helium plasma (issue #34): LuV 1 MK1, ZPM 1 MK2, UV 2 MK2
(the MK3 is UHV research), UHV 2 MK3, UEV 1 MK4, UIV 1 MK5, UMV 2 MK5, UXV 4 MK5. The unit doubles with every tier, and it runs:

| Tier | Power | Metal reactors | ZPM assembly lines | Circuit assembly lines | Bacterial vats | Purification plants | Metal reactors' share of the unit |
|---|---|---|---|---|---|---|---|
| LuV | 1 MK1 (1.02 GW) | 2 MK1 | 1 (LuV line) | 1 | 4 | 1 | 8 % |
| ZPM | 1 MK2 (2.05 GW) | 2 MK2 + 2 MK1 | 2 | 2 | 4 | 1 | 12 % |
| UV | 2 MK2 (4.1 GW) | 4 MK2 + 2 MK1 | 2 | 2 | 8 | 2 | 10 % |
| UHV | 2 MK3 (8.2 GW) | 4 MK3 + 2 MK2 | 2 | 2 | 8 | 2 | 10 % |
| UEV | 1 MK4 (16.4 GW) | 2 MK4 + 2 MK3 | 4 | 4 | 16 | 4 | 6 % |
| UIV | 1 MK5 (32.8 GW) | 2 MK5 + 2 MK4 | 4 | 4 | 16 | 4 | 6 % |
| UMV | 2 MK5 (65.5 GW) | 4 MK5 + 2 MK4 | 8 | 8 | 32 | 8 | 5 % |
| UXV | 4 MK5 (131 GW) | 8 MK5 + 2 MK4 | 8 | 8 | 32 | 8 | 4.5 % |

Metal reactors: twice the power reactors of the newest MK plus two of the MK before. The rest of the unit runs the machines of the
tier (one of each at full load: UV 1.72 GW ... UXV 55 GW, see "Turbines above UV"); assembly lines, vats and plants draw 5 to 10 MW
each. Research: 20 labs with research speed 6 (x3.7). The pack production rate of a factory is its time per pack in the tables below;
a technology costs the pack production of all its packs (every tier, not only the highest) in the factory of its highest pack.

### Findings

* **UV motor (#31).** One UV motor took 1.6 minutes of the UV factory (62 americium ingots: 48 for the 384 fine wires, 14 for the
  bootstrap neutronium). That is less than the other UV parts (pump 2.7, piston 6.7, robot arm 14.3, field generator 14.6 minutes)
  and in line with the UHV motor (64 s in the UHV factory: its tritanium needs MK1 duranium). GT has the same 384 fine americium
  wires; the UV motor only looked expensive because phase 4 cut the UHV motor to 48 fine wires (GT: 512). The real outlier was the
  **large neutronium gear**: the generic 40 ingots of melt (phase 4 made the tritanium one 4), so a UV piston cost 172 americium
  ingots, as much as a UHV piston, and the robot arm (a piston and two motors) 390.
* **Lutetium.** One americium ingot needs one lutetium dust (GT: 16 L each); 4 rare earth (I) dust give 1 lutetium in the EV
  electrolyzer. GT gets lutetium from thorium (5 thorium dust -> 4 lutetium in the HTGR, depleted thorium rods) and from the lanthanide
  chain (4000 L monazite froth -> 16 lutetium among 120 lanthanide dusts, 13 %). The 25 % here sits between the two and costs almost
  nothing at UV speed (0.75 s per lutetium in a UV electrolyzer). **Kept deliberately** at 4:1; it is no bottleneck. Americium is as
  fast as in GT (5 s per ingot in the MK2; GT 4.8 s per 16 L).
* **Stargate (#33).** 32 hours of the UXV factory: the base alone 6.1 hours (4 UXV field generators, 4 robot arms), the power unit 3,
  the controller 2.1, the 8 ring blocks (a UXV field generator each) 10.5, the 7 chevron blocks (each with the emitter and pistons of
  its chevron upgrade once more) 9.3. The 14 UXV field generators and 624 UXV circuits were half of it.
* **UMV/UXV parts and hatches (#33).** No component or hatch takes hours: the UXV field generator is the largest (49.5 minutes of the
  UXV factory), the UMV and UXV energy hatches take 11 and 9 minutes (8 and 16 APICs since #52; the 16 and 32 QPICs of the issue are
  gone). From tier to tier in the same (UXV) factory the parts grow 1.0x to 3.8x (motors 8 s, 8 s, 11 s, 25 s, 96 s, 126 s; field
  generators 2.2, 3.9, 9.3, 11, 29, 50 minutes; hatches 35 s, 35 s, 52 s, 1.7, 6.0, 8.9 minutes); in the factory of their own tier,
  which doubles, they take about the same time. Nothing is an order of magnitude off its neighbours, so they stay as they are.
* **Research (#30).** Every technology from UV up cost far more than anything it unlocks. In the factory of its tier a typical
  technology (3000 units) took 2.5 hours at LuV, 8 at ZPM, 37 at UV, 113 at UHV and UEV, 206 at UIV, 267 at UMV and 482 at UXV. The
  technologies with UIV to MAX packs took 8200 hours, the stargate technology alone 482 (and 13.5 hours of labs at 1200 s per unit),
  level 1 of `victory` 288 (256 of them for the 14 lower packs, 1000 units of each). Most of a unit's cost is the packs below the
  highest one: a UXV unit needs 1 UXV, 2 UMV, 3 UIV, 5 UEV, 8 UHV, 12 UV and 18 ZPM packs, and the UXV pack is 3.6 of its 9.6 minutes.
  Cutting only UIV to victory would make those technologies cheaper than the UHV and UEV ones, so the pass scales everything from UV
  up (the maintainer's decision).
* **Fusion times (lever 3, not used).** Duranium takes 32 s per 16 L in the MK1 (GT: 3.2 s; every other fusion metal is within a few
  percent of GT) and is 90 % of the chain of tritanium, so of cosmic neutronium, infinity and everything above. Rhugnor takes 3276.8
  against 768 for the other MK4 metals and is half of spacetime. With both at the GT/MK4 value the stargate would take 22.5 instead of
  32 hours, but the UHV parts would become cheaper than the UV ones. Not needed for the targets; open point.

### Changes

Levers in the order of the issues: unit counts of technologies, ingredient counts of parts. No yield or recipe time changed, the
fusion values of #32 and the turbines of #34 are unchanged, no prototype is renamed.

* **UV motor** (`127-fork-uv.lua`): 64 fine americium wires instead of 384 and 8 long neutronium rods instead of 4 (the UHV to UXV
  motors have 48 to 64 fine wires and 8 long rods): 22 americium ingots instead of 62 with the bootstrap neutronium.
* **Large neutronium gear**: 4 ingots of melt (57.6) instead of 40, like the large tritanium to universium gears.
* **Stargate** (`135-fork-endgame.lua`, old counts in brackets):
  - ring block: no UXV field generator (1), 2 frame parts (3), 2 radiation containment plates (3), 288 molten universium (576);
  - chevron block: no emitter (1) and pistons (2) of its own, 1 frame part (2), 1 plate (2), 2 UXV circuits (4), 288 universium (576);
  - chevron upgrade: 1 frame part (2), 1 piston (2), no emitter (1);
  - base: 1 UXV field generator (4), 1 emitter (4), 1 robot arm (4), 1 coil II (2), 2 plates (4), 2 frame parts (4), 8 circuits (16),
    16 eternity superconductor wires (32), 288 universium (1152);
  - power unit: 1 coil II (4), 1 field generator (2), 2 UXV energy hatches (4), 2 plates (4), 16 universium plates (32), 4 circuits
    (8), 32 eternity superconductor wires (64), 288 universium (1152);
  - controller: 8 UXV circuits (32), 1 sensor (2), 1 emitter (2), 2 conveyor modules (4), 8 gravi stars (16), 2 frame parts (4),
    2 plates (4), 288 universium (576);
  - frame part: 288 molten universium and 288 molten spacetime (576 each).

  The top level (8 ring blocks, 7 chevron blocks, base, power unit, controller, chevron and iris upgrade) is unchanged. The stargate
  needs 2 UXV field generators and 196 UXV circuits instead of 14 and 624.
* **Research** (new file `138-fork-research-balance.lua`, loaded after 137): explicit unit counts for the 70 technologies from UV to
  UXV. Each tier is scaled so a technology costs about as long as a ZPM technology of the same count in the factory of its tier
  (seconds of pack production per unit, median over the tier's technologies; ZPM 9.8 s): UV /4.5, UHV /13.9, UEV /13.9, UIV /25.3,
  UMV /32.2, UXV /59.3, rounded to 5 (to 25 above 200). The factory doubles with every tier, so the real cost still doubles per tier.
  `victory`: `15 * 2^(L-1)` instead of `1000 * 2^(L-1)` (/59.3 like UXV). Left alone: the infinite `research-productivity`, the
  vanilla technologies that cannot be researched (`UNRESEARCHABLE_OK`), and the unit times (with the new counts the labs are never the
  limit; the stargate technology takes 13.5 minutes of labs). Level 1 of `victory` now costs the stargate (its 1000 MAX packs; the
  first six levels take 945 of them) plus 4 hours for 15 units of the other packs: 14.5 hours, 1.4 stargates, instead of 288 hours.

### Before and after

Times of one item in the reference factory of its tier and in the UXV factory (the same yardstick for every tier); "Limit" is the
machine class that sets the time after the pass.

UV components:

| Part | Factory | Time in the factory of its tier | Limit | Time in the UXV factory |
|---|---|---|---|---|
| uv-motor | UV | 1.6 min -> **70 s** | fusion | 8 s |
| uv-pump | UV | 2.7 min -> **2.2 min** | fusion | 15 s |
| uv-conveyor-module | UV | 3.9 min -> **3.0 min** | fusion | 22 s |
| uv-piston | UV | 6.7 min -> **2.9 min** | fusion | 15 s |
| uv-robot-arm | UV | 14.3 min -> **6.3 min** | fusion | 45 s |
| uv-emitter | UV | 2.9 min -> **2.5 min** | fusion | 30 s |
| uv-sensor | UV | 3.3 min -> **2.8 min** | fusion | 30 s |
| uv-field-generator | UV | 14.6 min -> **12.7 min** | fusion | 2.2 min |

One component of each tier:

| Part | Factory | Time in the factory of its tier | Limit | Time in the UXV factory |
|---|---|---|---|---|
| uv-motor | UV | 1.6 min -> **70 s** | fusion | 8 s |
| uhv-motor | UHV | 64 s | fusion | 8 s |
| uev-motor | UEV | 80 s | fusion | 11 s |
| uiv-motor | UIV | 74 s | fusion | 25 s |
| umv-motor | UMV | 2.9 min | fusion | 1.6 min |
| uxv-motor | UXV | 2.1 min | fusion | 2.1 min |
| uv-sensor | UV | 3.3 min -> **2.8 min** | fusion | 30 s |
| uhv-sensor | UHV | 3.0 min | circuit assembly line | 45 s |
| uev-sensor | UEV | 3.9 min | fusion | 1.7 min |
| uiv-sensor | UIV | 4.7 min | fusion | 2.3 min |
| umv-sensor | UMV | 10.1 min | fusion | 5.6 min |
| uxv-sensor | UXV | 9.3 min | fusion | 9.3 min |
| uv-field-generator | UV | 14.6 min -> **12.7 min** | fusion | 2.2 min |
| uhv-field-generator | UEV | 7.9 min | circuit assembly line | 3.9 min |
| uev-field-generator | UEV | 21.8 min | fusion | 9.3 min |
| uiv-field-generator | UIV | 27.6 min | fusion | 11.0 min |
| umv-field-generator | UXV | 28.7 min | fusion | 28.7 min |
| uxv-field-generator | UXV | 49.5 min | fusion | 49.5 min |

Energy hatches and fusion controllers:

| Part | Factory | Time in the factory of its tier | Limit | Time in the UXV factory |
|---|---|---|---|---|
| uv-energy-hatch | UV | 3.3 min -> **2.8 min** | fusion | 35 s |
| uhv-energy-hatch | UHV | 4.1 min -> **4.0 min** | fusion | 35 s |
| uev-energy-hatch | UEV | 4.9 min | fusion | 52 s |
| uiv-energy-hatch | UIV | 5.1 min | fusion | 1.7 min |
| umv-energy-hatch | UMV | 10.8 min | fusion | 6.0 min |
| uxv-energy-hatch | UXV | 8.9 min | fusion | 8.9 min |
| fusion-reactor-mk3-controller | UHV | 21.5 min | assembly line | 5.4 min |
| fusion-reactor-mk4-controller | UEV | 31.4 min -> **31.1 min** | fusion | 10.5 min |
| fusion-reactor-mk5-controller | UIV | 57.3 min | bacterial vat | 28.6 min |

Science packs (one pack; a craft makes 10, the MAX pack is 1/1000 of a stargate):

| Part | Factory | Time in the factory of its tier | Limit | Time in the UXV factory |
|---|---|---|---|---|
| agricultural-science-pack | UV | 28 s -> **26 s** | fusion | 6 s |
| electromagnetic-science-pack | UHV | 56 s | assembly line | 14 s |
| cryogenic-science-pack | UEV | 64 s | fusion | 26 s |
| promethium-science-pack | UIV | 2.1 min | bacterial vat | 62 s |
| umv-science-pack | UMV | 2.4 min | fusion | 82 s |
| uxv-science-pack | UXV | 3.6 min | fusion | 3.6 min |
| max-science-pack | UXV | 1.9 min -> **38 s** | fusion | 1.9 min -> 38 s |

Stargate:

| Part | Factory | Time in the factory of its tier | Limit | Time in the UXV factory |
|---|---|---|---|---|
| stargate-frame-part | UXV | 4.1 min -> **2.4 min** | fusion | 4.1 min -> 2.4 min |
| stargate-radiation-containment-plate | UXV | 1.7 min | fusion | 1.7 min |
| stargate-chevron | UXV | 4.2 min | fusion | 4.2 min |
| stargate-iris-blade | UXV | 1.7 min | fusion | 1.7 min |
| stargate-ring-block | UXV | 78.7 min -> **19.0 min** | fusion | 78.7 min -> 19.0 min |
| stargate-chevron-block | UXV | 79.8 min -> **29.9 min** | fusion | 79.8 min -> 29.9 min |
| stargate-chevron-upgrade | UXV | 41.7 min -> **21.7 min** | fusion | 41.7 min -> 21.7 min |
| stargate-base | UXV | 6.1 h -> **1.7 h** | fusion | 6.1 h -> 1.7 h |
| stargate-power-unit | UXV | 3.0 h -> **87.4 min** | fusion | 3.0 h -> 87.4 min |
| stargate-controller | UXV | 2.1 h -> **49.1 min** | fusion | 2.1 h -> 49.1 min |
| stargate-iris-upgrade | UXV | 17.0 min | fusion | 17.0 min |
| **stargate** (8 ring blocks, 7 chevron blocks, the rest once) | UXV | 32.0 h -> **10.6 h** | fusion | 32.0 h -> 10.6 h |

Research per tier (pack production in the factory of the tier; the intentionally unresearchable vanilla techs and the infinite research productivity left out):

| Tier (highest pack) | Techs | Sum before | Sum after | Typical tech (3000 units before) | Largest after |
|---|---|---|---|---|---|
| LUV | 20 | 33.5 h | 33.5 h | 2.5 h -> 2.5 h | 3.3 h (zpm-components) |
| ZPM | 16 | 102.7 h | 102.7 h | 8.1 h -> 8.1 h | 10.8 h (uv-components) |
| UV | 13 | 444.1 h | 99.0 h | 36.9 h -> 8.3 h | 13.5 h (uhv-components) |
| UHV | 15 | 1607.5 h | 117.4 h | 112.7 h -> 8.5 h | 11.3 h (uev-components) |
| UEV | 13 | 1582.3 h | 117.0 h | 113.0 h -> 8.5 h | 12.2 h (uiv-components) |
| UIV | 13 | 2559.3 h | 102.2 h | 205.8 h -> 8.2 h | 9.6 h (uiv-energy-hatches) |
| UMV | 10 | 2546.8 h | 79.0 h | 267.1 h -> 8.3 h | 9.6 h (uxv-components) |
| UXV | 7 | 3099.1 h | 50.6 h | 481.9 h -> 8.0 h | 8.0 h (stargate) |

UIV to victory, tech by tech:

| Technology | Tier | Units | Packs of the tier and up | Pack production | Labs (20 labs, research speed 6) |
|---|---|---|---|---|---|
| `exotic-processor-mainframes` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `exotic-processors` | UIV | 2500 -> 100 | 100 UIV | 171.5 h -> 6.9 h | 33.8 min -> 81 s |
| `fusion-coil-ii` | UIV | 2500 -> 100 | 100 UIV | 171.5 h -> 6.9 h | 33.8 min -> 81 s |
| `fusion-plasmas-mk5` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `fusion-reactor-mk5` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `uiv-energy-hatches` | UIV | 3500 -> 140 | 140 UIV | 240.1 h -> 9.6 h | 47.3 min -> 1.9 min |
| `uiv-machines` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `uiv-multiblocks` | UIV | 3500 -> 140 | 140 UIV | 240.1 h -> 9.6 h | 47.3 min -> 1.9 min |
| `uiv-naquadah-reactor` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `uiv-plasma-turbine` | UIV | 2500 -> 100 | 100 UIV | 171.5 h -> 6.9 h | 33.8 min -> 81 s |
| `umv-components` | UIV | 3000 -> 120 | 120 UIV | 205.8 h -> 8.2 h | 40.5 min -> 1.6 min |
| `umv-materials` | UIV | 2500 -> 100 | 100 UIV | 171.5 h -> 6.9 h | 33.8 min -> 81 s |
| `umv-science-pack` | UIV | 2300 -> 90 | 90 UIV | 157.8 h -> 6.2 h | 7.6 h -> 17.8 min |
| `temporal-processor-mainframes` | UMV | 3000 -> 95 | 190 UIV, 95 UMV | 267.1 h -> 8.3 h | 40.5 min -> 77 s |
| `temporal-processors` | UMV | 3000 -> 95 | 190 UIV, 95 UMV | 267.1 h -> 8.3 h | 40.5 min -> 77 s |
| `umv-energy-hatches` | UMV | 3000 -> 95 | 190 UIV, 95 UMV | 267.1 h -> 8.3 h | 40.5 min -> 77 s |
| `umv-machines` | UMV | 2500 -> 80 | 160 UIV, 80 UMV | 222.6 h -> 7.0 h | 33.8 min -> 65 s |
| `umv-multiblocks` | UMV | 3000 -> 95 | 190 UIV, 95 UMV | 267.1 h -> 8.3 h | 40.5 min -> 77 s |
| `umv-naquadah-reactor` | UMV | 3000 -> 95 | 190 UIV, 95 UMV | 267.1 h -> 8.3 h | 40.5 min -> 77 s |
| `umv-plasma-turbine` | UMV | 2500 -> 80 | 160 UIV, 80 UMV | 222.6 h -> 7.0 h | 33.8 min -> 65 s |
| `uxv-components` | UMV | 3500 -> 110 | 220 UIV, 110 UMV | 311.7 h -> 9.6 h | 47.3 min -> 89 s |
| `uxv-materials` | UMV | 2500 -> 80 | 160 UIV, 80 UMV | 222.6 h -> 7.0 h | 33.8 min -> 65 s |
| `uxv-science-pack` | UMV | 2600 -> 80 | 160 UIV, 80 UMV | 231.5 h -> 7.0 h | 10.2 h -> 18.7 min |
| `stargate` | UXV | 3000 -> 50 | 150 UIV, 100 UMV, 50 UXV | 481.9 h -> 8.0 h | 13.5 h -> 13.5 min |
| `uxv-energy-hatches` | UXV | 3000 -> 50 | 150 UIV, 100 UMV, 50 UXV | 481.9 h -> 8.0 h | 40.5 min -> 41 s |
| `uxv-machines` | UXV | 3000 -> 50 | 150 UIV, 100 UMV, 50 UXV | 481.9 h -> 8.0 h | 40.5 min -> 41 s |
| `uxv-multiblocks` | UXV | 3000 -> 50 | 150 UIV, 100 UMV, 50 UXV | 481.9 h -> 8.0 h | 40.5 min -> 41 s |
| `uxv-naquadah-reactor` | UXV | 3000 -> 50 | 150 UIV, 100 UMV, 50 UXV | 481.9 h -> 8.0 h | 40.5 min -> 41 s |
| `uxv-plasma-turbine` | UXV | 2500 -> 40 | 120 UIV, 80 UMV, 40 UXV | 401.6 h -> 6.4 h | 33.8 min -> 32 s |
| `victory` | UXV | 1000 -> 15 | 75 UIV, 45 UMV, 30 UXV, 15 MAX | 288.2 h -> 4.0 h | 4.5 h -> 4.1 min |

UIV to victory: 8205.2 h -> 231.8 h

Targets met: the stargate takes hours (10.6), not days; its largest part 1.7 hours; the UXV technologies and the stargate technology
8 hours each, about one stargate; level 1 of `victory` 1.4 stargates; the UV motor is in line with the UHV motor (70 s and 64 s in
the factories of their tiers). Not met, on purpose: the parts grow 1.0x to 3.8x per tier in a fixed factory instead of 2x to 4x
everywhere (UV to UHV about 1x, because the UHV metals are cheap apart from duranium; UMV to UXV 1.3x to 1.7x). No part stands out,
and raising the lower tiers would go against the issues.

Comparison with GT5-Unofficial (`AssemblyLineRecipes.java`, `ResearchStationAssemblyLine.java`): GT's UV motor has 384 fine americium
wires, its UHV to UMV motors 512 fine wires and 8 to 32 long rods, its sensors 192 to 256 foils, its field generators 384 to 512 fine
wires, its hatches 2 power ICs. The fork cuts the fine wires and foils of every tier to 48 to 64 (now the UV motor too) and keeps 4 to
16 power ICs. GT's stargate (NewHorizonsCoreMod: extreme crafting grids with 9 UXV field generators per ring block, BEC recipes of
8 000 000 s, grade 8 water by the billion) is a project of weeks and has no counterpart here; GT has no research.

### Numbers

`devcheck all`: RESULT OK (every runtime test, the victory test included); `migrate --from-ref v0.3.1`: loads, every old-save check
ok. Researchable technologies 369 of 388 (unchanged), draft recipes hidden 0, the `FORK-DRAFT`, `FORK-AUTOUNLOCK` (54) and
`FORK-REMOVED` (35) lines identical to main, unlocked but uncraftable recipes 0. Tech by tech against main: prerequisites, science
packs and unlocks of all 388 technologies identical, no unlock lost or moved; 71 unit counts changed. Recipes changed: the 9 above
(and the recycling recipes the quality mod generates from them).

### Existing saves

No unlock moves and no item is renamed. Research in progress keeps its progress as a fraction, so a technology whose count drops
finishes sooner; researched technologies stay researched. The nine recipes change their ingredients like any recipe change.

### Open points

* Balance in the real game: whether 10 hours for the stargate and 8 hours per technology feel right; the bacterial vats (the research
  of UIV and UXV is limited by the 16 and 32 vats of the reference factory; they are cheap LuV machines, but a player has to build
  them); the circuit assembly lines (the UXV circuits are 40 % of the stargate).
* Duranium (32 s per 16 L, GT 3.2 s) and rhugnor (4.3x the other MK4 metals): the largest levers left in the metal chains.
* The infinite `research-productivity` (75 hours per level at UEV) keeps its formula.
* The model counts no transport, no machine build cost and no start-up; the byproducts of the naquadah line are charged to its main
  product.

## Phase 6a: QFT and DTPF (issue #37, part 1)

GT's two big endgame processing multiblocks, on top of the UMV tier: the **dimensionally transcendent plasma forge** (DTPF,
GT's `MTEPlasmaForge`) and the **quantum force transformer** (QFT, GT++'s `MTEQuantumForceTransformer`). Everything is in
`prototypes/139-fork-endgame-multiblocks.lua`; it loads after 137 and before 138, which sets the unit counts of its technologies.
The MAX tier and the godforge are phase 6b; the spots it has to revisit are listed under "Hooks for 6b" below. Sources: the drafts
in `29-uev-age-item.lua`, `31-uiv-age-item.lua`, `80-umv-age-item.lua`, `90-uxv-age-item.lua` (not loaded) and GT5-Unofficial
(`MTEPlasmaForge`, `PlasmaForgeRecipes`, `TranscendentPlasmaMixerRecipes`, the core mod's `DTPFRecipes`/`DTPFCalculator`,
`MTEQuantumForceTransformer`, `RecipeLoaderChemicalSkips`, GoodGenerator's `NaquadahRecipeLoader`).

### Content

| Technology | Science | Prerequisites | Units | Unlocks |
|---|---|---|---|---|
| `dimensionally-transcendent-plasma-forge` | UMV | `umv-multiblocks`, `fusion-plasmas-mk5` | 95 (8.3 h) | dimensionally transcendent casing, dimensional bridge, DTPF controller, the DTPF, crude catalyst, the six crude metal recipes |
| `dtpf-resplendent-catalyst` | UXV | `dimensionally-transcendent-plasma-forge`, `uxv-multiblocks` | 50 (8.0 h) | resplendent catalyst, the six resplendent metal recipes |
| `quantum-force-transformer` | UMV | `umv-multiblocks` | 95 (8.3 h) | QFT coil casing, QFT controller, the QFT, its 29 recipes |

The unit counts are in `138-fork-research-balance.lua`: about 8 hours of pack production in the reference factory of the tier,
like the other UMV and UXV technologies.

Machines (both cloned from the fusion reactor MK5: electric, powered through the energy hatches in their recipe like the
reactors, one amp of their tier):

| Machine | Size | Tier | Power | Speed | Fluid ports | Recipe (UMV assembler, 5 min) |
|---|---|---|---|---|---|---|
| dimensionally transcendent plasma forge | 11x11 | UMV | 1310.72 MW | 2048 | 6 in (5 north, 1 west), 2 out (south) | controller, 48 dimensionally transcendent casings, 16 dimensional bridges, 32 spacetime coils, 2 UMV energy hatches, 8 UMV hulls |
| quantum force transformer | 9x9 | UMV | 1310.72 MW | 2048 | 4 in (north), 2 out (south) | controller, 16 QFT coil casings, 32 titanium reinforced borosilicate glass, 2 UMV energy hatches, 8 UMV hulls |

Parts: the DTPF casing (UMV assembler: osmiridium plates, spacetime screws, a 1080k super coolant cell, a UV emitter, a
triamerotronium superconductor wire), the dimensional bridge (ZPM assembly line: casing, UHV field generator, UV emitter and
circuits, PPIC wafers, triamerotronium wire), the DTPF controller (ZPM assembly line: 4 bridges, 4 UIV energy hatches, chromnorox
wire, 4 super coolant cells, 20 UMV circuits, 4 UIV field generators and pumps, superdense neutronium); the QFT coil casing (UMV
assembler: infinity coil, 4 super coolant cells, transcendent metal, a superconducting coil block) and the QFT controller (ZPM
assembly line: UIV circuits, pumps, field generators and robot arms). GT builds both at UIV with UEV parts; here they are UMV
machines (the techs are UMV science), so the parts are one tier up. GT items the mod does not have are left out (eternal singularity,
quantum anomaly, the ZPM battery, oganesson and californium; mutated living solder is indalloy 140, enriched naquadah is naquadah,
laurenium screws are spacetime screws, the microwave energy transmitter is a UV emitter).

**DTPF recipes** (2 catalysts, 12 metal recipes). The catalysts are made in the forge (5 s and 10 s):

| Catalyst | Inputs (100 each) | GT |
|---|---|---|
| excited dimensionally transcendent crude catalyst | helium, iron, calcium, niobium plasma | the same four plasmas (transcendent plasma mixer) |
| excited dimensionally transcendent resplendent catalyst | crude catalyst, boron, sulfur, nitrogen, zinc, titanium plasma | GT's resplendent catalyst also takes radon, nickel and silver plasma, which the mod does not have |

Each metal recipe is the fusion recipe of the metal (the MK3 to MK5 recipe, which stays the entry route) with two thirds of its
inputs per ingot, in a third of the reactor time (the DTPF and the reactors draw the same 0.64 MW per crafting speed), plus
catalyst; the resplendent tier makes twice the batch in the same time:

| Metal | Inputs per craft (crude / resplendent) | Output | Time | Catalyst crude / resplendent |
|---|---|---|---|---|
| neutronium | 96 / 192 each of americium, naquadria | 144 / 288 | 0.625 s | 5.6 / 3.75 |
| cosmic neutronium | neutronium, tritanium | 144 / 288 | 1.25 s | 11.25 / 7.5 |
| infinity | cosmic neutronium, draconium | 144 / 288 | 1.25 s | 11.25 / 7.5 |
| transcendent metal | infinity, krypton plasma | 144 / 288 | 1.25 s | 11.25 / 7.5 |
| spacetime | transcendent metal, rhugnor | 144 / 288 | 2.5 s | 22.5 / 15 |
| universium (6b hook) | spacetime, flerovium | 144 / 288 | 2.5 s | 22.5 / 15 |

The catalyst per craft is 1.5 crude (0.5 resplendent) per second that a MK5 would take for the batch (GT: the catalyst stands for
the energy of the normal route).

**QFT recipes** (29, 20 s; the naquadah ones 10 s). GT's recipes whose inputs and outputs the mod has, one recipe per main output,
each with 100 nitrogen plasma as the focus plasma; every output has its GT amount at 100 %, the focused one gets (N+1)/2N, the
others 1/2N (GT's neptunium focus with N outputs: 58 % and 8 % with six outputs):

| Input (GT name) | Outputs (64 each) | Recipes |
|---|---|---|
| 32 metallic platinum powder (platinum metallic powder) | platinum, palladium, iridium, osmium, rhodium, ruthenium dust | 6 |
| 32 metallic palladium powder (palladium metallic powder) | palladium, platinum, rhodium plated palladium dust | 3 |
| 32 iridium metal residue (iridium leach residue) | iridium, platinum, osmiridium dust | 3 |
| 32 rarest metal mixture (rarest metal residue) | osmium, iridium, osmiridium dust | 3 |
| 32 crude rhodium residue (crude rhodium metal) | rhodium, palladium, platinum, rhodium plated palladium dust | 4 |
| 32 iridium group sludge (leach residue) | iridium, osmium, rhodium, ruthenium dust | 4 |
| 32 naquadah oxide mixture (naquadah earth), 64 sodium, carbon, 1000 hydrogen, 1000 fluorine, 100 oxygen | 16 naquadahine dust, titanium dust, adamantium dust, gallium | 4 |
| 32 enriched naquadah oxide mixture (enriched naquadah earth), 64 zinc dust, carbon, 1000 sulfuric acid, 100 oxygen | 16 enriched naquadah sulphate, trinium dust; 1000 waste liquid | 2 |

Not built, because the mod lacks an input or output (the missing GT part in brackets): early plastics (polystyrene), rubbers
(styrene butadiene rubber, rubber), glues (stable adhesive), the two titanium/tungsten/indium recipes (tungsten carbide, rhenium and
hafnium dust), radioactives (thorium 232, uranium 233, plutonium 238 and 241), the monazite and bastnasite lines and the cerium-rich
mixture (monazite and bastnasite cannot be obtained; holmium, cerium, gadolinium, lanthanum dust), naquadria (naquadria earth,
naquadria supersolid), netherite, prismarine, stem cells, late plastics, Kevlar, biocells, seaweed and the temporal harmony recipe.
So the QFT has no rare earth recipe: none of GT's fits the mod's rare earth line (rare earth (I) dust).

What the QFT saves, per focused output against the mod's own line (input per output): platinum metallic powder 0.86 per dust (the
platinum line: 6 per rhodium, 96 per iridium, 144 per ruthenium, 240 per osmium dust); iridium group sludge 0.67 per iridium dust (4
in the line); naquadah oxide mixture 3.2 per naquadahine dust (7.8); enriched naquadah oxide mixture 0.75 per trinium dust (24). The
platinum numbers are GT's: the QFT is a chain skip of that size there too.

### Deviations from GT

- **DTPF catalysts.** No transcendent plasma mixer: the forge makes its two catalysts itself. Crude is GT's recipe, resplendent GT's
  without radon, nickel and silver plasma; prosaic (radon, nickel plasma), exotic (americium, bismuth plasma) and stellar (raw star
  matter) are not built. No dimensionally transcendent residue.
- **No heat, runtime discount or convergence.** GT gates the catalyst tiers by coil heat (10 800 to 13 500 K), cuts the catalyst by
  up to 50 % after 8 hours of running and trades catalyst for perfect overclocks with a transdimensional alignment matrix. Here every
  recipe has a fixed catalyst amount (the way the quark creation catalyst of the water purification plant has a fixed break chance);
  the technology of the catalyst stands for the coil tier.
- **DTPF metals.** GT makes neutronium from molten iron, cosmic neutronium from molten copper, transcendent metal from raw tesseracts
  and spacetime from energised tesseracts, infinity and hypogen; that would skip the whole fusion chain (and the mod has no
  tesseracts, hypogen or infinity catalyst). Here the DTPF takes the inputs of the fusion recipe: same chain, less of it, faster.
- **QFT focus.** GT chooses the focused output with a circuit and boosts all outputs with fermium plasma; parallels come from the
  number of catalyst items in a catalyst housing, the recipe and focus tiers from tiered casings. Here: one recipe per main output with
  GT's neptunium chances at the recipe's own tier, nitrogen plasma (GT's neptunium plasma is made from radon and nitrogen plasma), no
  catalysts, no tiered casings, no fermium.
- **QFT naquadah.** GT gives one inert naquadah dust per 32 naquadah earth (activated to 0.67 naquadah ingots in GT's neutron
  activator); the mod's line ends in naquadahine dust (3 make 30 hot naquadah ingots), so the QFT gives 16 naquadahine dust per craft
  at 100 % (10 at focus), about twice the yield of the line, and 16 enriched naquadah sulphate for GT's inert enriched naquadah.
  Fluids are scaled to the 1000 of a fluid port (GT: 64 000 hydrogen and fluorine, 16 000 sulfuric acid, 32 000 waste liquid).
- **Size and tier.** Single entities of 11x11 and 9x9 (GT: 33x24x33 and 15x21x15), UMV (GT: UIV controllers), one UMV amp.

### Efficiency: DTPF against the fusion reactors

`python tools/balance_model.py dump.json --dtpf` (dump from `devcheck.py check --balance-out`). The default model (and every number
of "Balance pass: endgame") still uses the fusion route; `--dtpf` puts the six DTPF recipes of a catalyst tier in place of the
fusion recipes of those metals. Energy is that of the metal machines over the whole chain (fusion reactors at 0.64 MW per crafting
speed, the DTPF at 1310.72 MW), per ingot (14.4 mB):

| Metal | Fusion | DTPF crude | DTPF resplendent |
|---|---|---|---|
| neutronium | 0.5 GJ | 0.3 GJ (1.6x) | 0.2 GJ (1.9x) |
| cosmic neutronium | 2.2 GJ | 1.4 GJ (1.6x) | 1.3 GJ (1.8x) |
| infinity | 3.3 GJ | 1.6 GJ (2.1x) | 1.4 GJ (2.3x) |
| transcendent metal | 4.0 GJ | 1.5 GJ (2.6x) | 1.3 GJ (3.1x) |
| spacetime | 14.2 GJ | 5.0 GJ (2.8x) | 4.4 GJ (3.2x) |
| universium | 16.7 GJ | 4.9 GJ (3.4x) | 4.3 GJ (3.9x) |

So per GW the DTPF route makes 1.6x (neutronium) to 3.4x (universium; 3.9x resplendent) the metal. Per input: one universium ingot
takes 7 americium, 3 naquadria, 3 tritanium, 3 draconium, 2 krypton plasma and 1 flerovium (in ingots; 3 infinity, 2 transcendent
metal, 1 spacetime on the way) through the fusion reactors, and 1.67 americium, 0.31 naquadria, 0.46 tritanium, 0.69 draconium, 0.59
krypton plasma and 0.67 flerovium (1.04 infinity, 0.89 transcendent metal, 0.67 spacetime) through the DTPF: 4.2x less americium,
1.5x to 9.8x less of the others. Each step alone takes two thirds of the inputs (1.5x).

In the reference factory, with DTPFs of the same power in place of MK5 metal reactors (one DTPF for two MK5; the best split of the 8
UXV / 4 UMV metal MK5s, the rest of the factory unchanged):

| Item | Factory | Fusion | DTPF crude | DTPF resplendent |
|---|---|---|---|---|
| UMV science pack | UMV | 2.4 min | 1.4 min (2 MK5 -> 1 DTPF) | - (UXV science) |
| UXV motor | UXV | 2.1 min | 0.8 min (4 MK5 -> 2 DTPF) | 0.5 min (2 MK5 -> 1 DTPF) |
| UXV field generator | UXV | 49.5 min | 20.0 min | 14.1 min |
| UXV science pack | UXV | 3.6 min | 1.6 min | 1.2 min |
| **stargate** | UXV | **10.6 h** (225 900 GJ) | **4.4 h** (73 300 GJ) | **3.0 h** (64 000 GJ) |

The stargate takes 2.4x (crude) and 3.5x (resplendent) less time and 3.1x and 3.5x less energy. Fusion stays the limit with crude
catalyst (the forge still needs the krypton, flerovium, rhugnor and catalyst plasmas from the reactors); one resplendent forge does
the work of two crude ones. The research per technology is unchanged (8 hours); the new technologies add 16.6 hours at UMV and 8 at
UXV.

### Hooks for 6b

GT uses no MAX-tier part in these two machines or their recipes (the DTPF controller is UIV, its eternal coil UMV, the QFT's top
casings UXV), so no UXV part had to stand in for a MAX part in this phase. The places where GT's version goes through the godforge
or the MAX tier (marked `6b hook` in `139-fork-endgame-multiblocks.lua` where there is code):

1. **Universium in the DTPF** (`molten-universium-dtpf-crude`, `-resplendent`): GT makes universium in the godforge and the eye of
   harmony, not in the DTPF. Here it is a DTPF recipe from spacetime and flerovium (the inputs of the MK5 recipe). 6b decides
   whether the godforge takes over; the recipes keep their names for saves. *(6b: the godforge's molten module makes universium too;
   the DTPF recipes stay as the pre-victory route.)*
2. **Stellar catalyst**: GT's top DTPF tier needs raw star matter (a godforge product), its exotic tier americium and bismuth plasma.
   The resplendent catalyst is the top tier here; 6b can add the stellar one and a third recipe tier. *(6b: done, `dtpf-stellar-catalyst`.)*
3. **MAX recipes of the DTPF and the QFT**, not built: timepiece, time and space conversion, chipped amalgatite (DTPF, MAX), the
   temporal harmony recipe (QFT: shirabon and eternity from a universium nanite and a timepiece). *(6b: still not built, their
   materials do not exist.)*
4. **The eye of harmony** takes four plasma forges (and four godforges) in GT: the item `dimensionally-transcendent-plasma-forge`
   is ready for that recipe. *(6b: the eye of harmony is not built, see "Phase 6b".)*

### Numbers

`devcheck all`: RESULT OK; `migrate --from-ref v0.3.2`: loads, every old-save check ok. Researchable technologies 369 -> 372 of
388 -> 391 (the three new ones), draft recipes hidden 0, the `FORK-DRAFT`, `FORK-AUTOUNLOCK` (54) and `FORK-REMOVED` (35) lines
identical to main (no auto-unlock moved: every recipe of the new machines is unlocked explicitly, and all their inputs have a
producer already), unlocked but uncraftable recipes 0. Tech by tech against main: prerequisites, science packs, unlocks and unit
counts of all 388 technologies identical; only additions. Machines placed by `devcheck runtime` 510 -> 512, crafting menu
2788 -> 2838 machine recipes shown (the 50 new ones), 241 kept hidden, 0 hidden without an allow-list entry. Required recipes of
`devcheck check` 23 -> 34; the recipe test of `devcheck runtime` 30 -> 33 (the crude catalyst and crude spacetime in the DTPF, the
platinum metallic powder recipe in the QFT; a main product with a probability only has to finish its craft). Graphics: sprites from
GT's DTPF (dimensionally transcendent casing, dimensional bridge, DTPF screen) and QFT (bulk production frame, QFT coil, controller
face) textures, 7 item icons, 3 technology icons, review sheets in `docs/graphics-review/phase-6a/`.

### Existing saves

Only additions: new items, recipes, technologies and two fluids; no prototype renamed, no recipe or technology of main changed.
Saves from 0.3.2 load (`migrate --from-ref v0.3.2`).

### Open points

- Balance in the real game: whether the DTPF (3x less energy per universium ingot, stargate 10.6 -> 3 to 4.4 hours) and the QFT
  (platinum group dusts for a fraction of the platinum line) are too strong at UMV; the levers are `DTPF_INPUT`, `DTPF_TIME` and the
  catalyst amounts at the top of the DTPF part of `139-fork-endgame-multiblocks.lua`.
- The QFT recipes GT has but the mod lacks materials for (see above); a rare earth recipe for the mod's rare earth (I) line.
- ~~6b: the hooks above~~ (see "Phase 6b: MAX tier and godforge").

## Phase 6b: MAX tier and godforge (issue #37, part 2)

What comes after the win: GT's Forge of the Gods (TecTech `MTEForgeOfGods` and its four modules) and a MAX tier on top of it, both
on MAX science (the packs of the stargate). `victory` stays the win condition and is unchanged. Content in two new files, loaded
after 139 and before 138 (which sets their unit counts): `prototypes/140-fork-godforge.lua` and `prototypes/141-fork-max.lua`.
Sources: GT5-Unofficial (TecTech `godforge/`, `Godforge.java`, `ResearchStationAssemblyLine.java`, `BECRecipes.java`,
`MTEExoticModule`, `MTEEyeOfHarmony`, `MixerRecipes`/`LaserEngraverRecipes` for the stellar catalyst), the core mod
(`DTPFRecipes`, `ScriptNanochipRecipes` for the Planck circuit, `ScriptGregtechPlusPlus` for the QFT's temporal harmony) and the
drafts `80-umv-age-item.lua` and `90-uxv-age-item.lua` (not loaded).

### Post-victory and the long-term sink

* **Gate.** `victory` is an infinite technology, and Factorio counts an infinite technology as researched for prerequisites only at
  its last level (checked headless: after level 1 a technology that needs it is still not accepted). So the 6b technologies follow
  `stargate` and need MAX packs. The MAX packs come from the stargate (1000 per stargate); level 1 of `victory` takes 15 of them, so
  in practice the first stargate wins the game and the rest of its packs start 6b. Researching `victory` is unchanged in old and new
  saves (the runtime test still wins the game, then researches a post-victory technology).
* **Sink.** Two infinite technologies: the further levels of `victory` (unchanged, `15 * 2^(L-1)`), and **`godforge-upgrades`** (GT's
  graviton shard upgrades): every level gives the godforge's star matter, universium and magmatter recipes +5 % productivity (up to the
  engine's +300 %), `55 * 2^(L-1)` units, level 1 about 8 hours. Both eat MAX packs, and the second MAX pack recipe (below) makes MAX
  packs a product of the MAX tier and the godforge, so the sink keeps the whole endgame running.

### Content

| Technology | Prerequisites | Units | Unlocks |
|---|---|---|---|
| `godforge` | `stargate`, `dtpf-resplendent-catalyst` | 55 | stellar energy siphon casing, singularity reinforced stellar shielding casing, remote graviton flow modulator, godforge controller, the godforge; raw star matter; lead, thorium and naquadria plasma (plasma module) |
| `godforge-molten-module` | `godforge` | 55 | universium in the godforge |
| `godforge-exotic-module` | `godforge-molten-module` | 55 | time and space from spacetime, the 7 magmatter recipes |
| `dtpf-stellar-catalyst` | `godforge` | 55 | stellar catalyst, the six stellar metal recipes of the plasma forge |
| `godforge-upgrades` (infinite) | `godforge-exotic-module` | `55 * 2^(L-1)` | +5 % productivity per level for raw star matter, godforge universium and magmatter |
| `max-materials` | `godforge-exotic-module` | 55 | magmatter parts (ingot, plate, rods, frame, gears, ring, round, screw, rotor, wires, foil), magmatter cable |
| `planck-processors` | `max-materials` | 55 | Planck board, processing unit, processor, assembly, supercomputer |
| `planck-processor-mainframes` | `planck-processors` | 55 | the Planck processor mainframe (= `max-circuit`) |
| `max-components` | `planck-processor-mainframes` | 55 | MAX motor, pump, conveyor module, piston, robot arm, emitter, sensor, field generator, MAX casing and hull, the MAX science pack from MAX parts |
| `max-machines` | `max-components` | 55 | the 23 basic machines one tier up |
| `max-energy-hatches` | `max-machines` | 55 | maximum voltage coil, MAX energy hatch |
| `max-multiblocks` | `max-energy-hatches` | 55 | the 13 multiblock upgrades |
| `max-plasma-turbine` | `max-energy-hatches`, `uxv-plasma-turbine` | 55 | MAX dynamo hatch, MAX large plasma turbine |

All with the 15 packs up to MAX, 60 s per unit. Machines:

| Machine | Size | Tier | Power | Speed | Technology | Recipe |
|---|---|---|---|---|---|---|
| godforge | 13x13 | UXV | 2621.44 MW (one UXV amp) | 4096 | `godforge` | UXV assembler, 5 min: controller, 64 shielding casings, 8 siphon casings, 4 graviton flow modulators, 2 UXV energy hatches, 8 UXV hulls |
| MAX basic machines (23) | 3x3 | MAX | twice the UXV machine (MAX assembler 1.97 GW) | 8192 | `max-machines` | the UXV recipe with every tiered part one tier up (`fork_make_tier_machine`) |
| MAX multiblock upgrades (13) | as the EV version | MAX | twice the UXV one (MAX EBF 4.92 GW) | 8192 | `max-multiblocks` | the UXV multiblock with MAX parts |
| MAX large plasma turbine | 3x3 | MAX | makes up to 20 971.52 MW (four MAX amps) | - | `max-plasma-turbine` | upgrade of the UXV turbine with the MAX dynamo hatch and a MAX hull (the old hatch and hull come back) |

The godforge has five fluid inputs north, one west and two outputs south, like the plasma forge. The MAX turbine is in the mod data of
`136-fork-power.lua`, so the fuel check and the turbine output hatch work for it.

**Godforge recipes** (category `godforge-recipes`; every recipe but the star matter burns 0.25 raw star matter per second of godforge
time, GT's star fuel):

| Recipe | Inputs | Output | Time | Module (GT) |
|---|---|---|---|---|
| raw star matter | 1000 hydrogen, 1000 helium, 10 crude catalyst | 100 raw star matter | 20 s | eye of harmony in GT |
| lead / thorium plasma | 1 lead ingot / 1 thorium dust | 144 plasma | 1 s | plasma module, tier 0 |
| naquadria plasma | 144 molten naquadria | 144 plasma | 10 s | plasma module, tier 1 |
| universium | 144 spacetime, 144 flerovium | 288 universium | 1.25 s | eye of harmony in GT |
| time and space | 288 molten spacetime | 144 tachyon rich temporal fluid, 144 spatially enlarged fluid | 10 s | GT: centrifuge from tesseracts |
| magmatter (7: from neutronium, tritanium, cosmic neutronium, draconium, infinity, rhugnor, flerovium) | 1000 molten metal, 7 of each fluid | 80 molten magmatter | 20 s | exotic module, magmatter mode |

**Stellar catalyst** (the 6b hook of 139): in the plasma forge, 100 resplendent catalyst, 100 lead plasma, 100 thorium plasma, 10
naquadria plasma and 2.5 raw star matter -> 100 stellar catalyst in 20 s (GT: 1000 exotic catalyst, 1000 lead and thorium plasma,
100 naquadria plasma, 25 raw star matter). Its six metal recipes make four times the crude batch (576) in the same time, for 0.25
stellar catalyst per second of MK5 time (crude 1.5, resplendent 0.5).

**MAX tier.** Magmatter is the MAX metal: its parts come from the UXV machines (`F.metal`), like every metal comes from the tier below.
The Planck line is the temporal line one step up (circuit assembly line, 16 per craft, 10 % slower), its mainframe uses the eternity
superconductor (UXV). The MAX components are the UXV recipes with magmatter and magmatter cable (`F.components`: universium plates in
the pump, MAX/UXV/UMV circuits in the robot arm, 8 MAX circuits in the field generator), a minute each in the ZPM assembly line. The
maximum voltage coil is a magnetic samarium rod with 16 fine magmatter wires (MAX assembler); the MAX energy and dynamo hatch take a
MAX hull, 8 eternity superconductor wires, 32 APICs, 2 MAX circuits, 2 coils, a MAX pump, super coolant and indalloy. The second MAX
science pack recipe (`max-science-pack-from-magmatter`, UXV assembler) takes a MAX motor, 2 MAX circuits, 4 magmatter plates, 4 eternal
coils, a UXV field generator and 144 molten magmatter and makes 100 packs; the stargate recipe stays.

New fluids: raw star matter, lead, thorium and naquadria plasma (no fuel value: the turbines do not burn them), tachyon rich temporal
fluid, spatially enlarged fluid, molten magmatter, the stellar catalyst. New items: 15 magmatter parts and the cable, 6 Planck items
(`max-circuit` included), 8 MAX components, MAX casing, hull, energy hatch, dynamo hatch, the maximum voltage coil, the 4 godforge parts
and the godforge, the 36 MAX machines and the MAX turbine.

### Deviations from GT

- **The godforge is one entity.** GT's controller only holds the star; up to 16 modules (smelting, molten, plasma, exotic) do the work,
  each a multiblock of its own, powered by wireless EU, and 31 upgrades bought with 112 graviton shards (from four milestones: EU used,
  recipes run, fuel burnt, structure) unlock the modules, rings, heat, parallels and voltage. Here one 13x13 machine runs every module's
  recipes; the modules are three technologies (forge with the plasma module, molten module, exotic module) and the upgrades one infinite
  technology (`godforge-upgrades`, productivity). No heat, fuel factor, rings, milestones or shards; power through the energy hatches in
  its recipe like the plasma forge. GT's smelting module and the molten module's EBF copies are not built (the MAX EBF covers them).
- **Fuel.** GT's star burns residue, raw star matter or MHDCSM per second while the modules run; here each recipe burns raw star matter
  by its time. Raw star matter is an eye of harmony product in GT (1e9 litres of hydrogen and helium per 1e5); here the godforge makes
  it itself, with crude catalyst to ignite the star.
- **Exotic module.** GT draws a random challenge every cycle (QGP mode: up to seven random plasmas; magmatter mode: a random metal's
  plasma and random amounts of temporal and spatial fluid). Here one magmatter recipe per metal, with the metal's melt instead of its
  plasma (the mod has no plasmas of these metals) at GT's average ratio (12.5 litres per litre of magmatter), and equal amounts of the
  two fluids so the spacetime split feeds it exactly. The player picks the metal (neutronium is the cheapest). Quark gluon plasma is not
  built: GT uses it only for nanites.
- **Universium** comes from the eye of harmony in GT (rocket tiers 7 to 9), never from the plasma forge. Here the godforge's molten
  module makes it from the MK5 inputs at half per ingot. The plasma forge recipes (6a) stay: universium is needed for the stargate, before
  the godforge, so they are the faster pre-victory route (6a hook 1: the godforge takes over after victory, nothing is removed).
- **No eye of harmony** (6a hook 4 stays open). GT's eye is a mining multiblock: per dimension it turns hydrogen and helium into the
  ore dusts of that dimension, plasmas, raw star matter and white or black dwarf matter (the "dark matter" of the drafts; GT has no dark
  matter), which feed nanites and MHDCSM. None of these has a consumer in the mod, and its two jobs here (raw star matter, universium) are
  done by the godforge. Its controller would take four godforges and four plasma forges; the item is ready if it comes later.
- **MAX tier.** GT has the MAX circuit (Planck-scale circuit, from the nanochip assembly complex) and the MAX component items, but no
  recipe for the components, no MAX energy, dynamo or laser hatch, no MAX superconductor and no MAX machines; its UXV parts already use
  magmatter and its generators stop at UXV. The fork builds the MAX tier by its UMV -> UXV pattern: magmatter as the metal, the eternity
  superconductor (UXV) in the hatches (GT's UXV hatch takes the UMV superconductor too), the eternal coil stays the top heating coil. The
  MAX circuit line is named after the Planck circuit: GT's own "transcendent" circuits are the icons of the fork's UXV (temporal) line.
- **UXV field generator** keeps 8 UXV circuits (GT: 4 MAX circuits): the stargate needs it, and the MAX circuit comes after the stargate.
- **MAX turbine.** GT has none (its dynamo hatches stop at UXV); here it continues the turbine table of issue #34 so the MAX machines
  (twice the UXV draw) have a generator of their tier.
- **6a hook 3, MAX recipes of the plasma forge and the QFT**, still not built: the timepiece, the time/space conversions and chipped
  amalgatite need tesseracts, quantum anomalies, dilithium, dark iron, nanites, gems and the stargate crystal slurry; the QFT's temporal
  harmony needs eternal singularities, energised tesseracts, primordial matter and shirabon. None exists in the mod. With equal amounts of
  time and space in the magmatter recipe the conversions have no job.

### Balance

`python tools/balance_model.py dump.json` (and `--max` for magmatter per metal and universium). The **MAX reference factory** is the
UXV one doubled: 8 MK5 of power (12.5 MAX turbines on helium plasma), 16 MK5 and 2 MK4 metal reactors, 16 ZPM and circuit assembly
lines, 64 bacterial vats, 16 purification plants, and 4 godforges (10.5 GW, 4 %). The technologies with MAX packs are counted in it,
except `victory` (researched with the UXV factory and stargate packs, as before); the MAX pack from MAX parts, magmatter from the
neutronium recipe (the fastest). Times of one item:

| Item | Factory | Time | Limit |
|---|---|---|---|
| godforge | UXV | 11.7 h (247 800 GJ; the stargate: 10.6 h, 225 900 GJ) | fusion |
| godforge | MAX | 6.2 h | fusion |
| raw star matter, 100 | MAX | 5 s (52 GJ) | godforge |
| magmatter ingot | MAX | 1.0 s (21 GJ; draconium 22, tritanium 32, flerovium 34, cosmic neutronium 43, infinity 56, rhugnor 132 GJ) | godforge |
| universium ingot, fusion / godforge | MAX | 1.5 s (16.7 GJ) / 0.7 s (8.5 GJ) | fusion |
| MAX circuit | MAX | 50 s | fusion |
| MAX motor / pump / piston / conveyor module | MAX | 44 s / 1.7 min / 1.7 min / 2.0 min | godforge, fusion |
| MAX emitter, sensor | MAX | 4.9 min each | fusion |
| MAX robot arm | MAX | 10.8 min | fusion |
| MAX field generator | MAX | 26.9 min | fusion |
| MAX energy hatch | MAX | 4.7 min | fusion |
| MAX large plasma turbine (from the UXV one) | MAX | 14.8 min | fusion |
| MAX science pack, from MAX parts / from the stargate | MAX / UXV | 19 s / 38 s | fusion |

A unit of a MAX technology (one pack of each tier) costs 8.4 minutes of the MAX factory, most of it the packs below MAX; 55 units are
7.7 hours, as long as a UXV technology in its factory (stargate: 50 units, 8.0 hours). The labs need 0.7 minutes. In the factory of
their own tier the MAX parts take 0.33x to 0.6x the time of the UXV parts (motor 2.1 -> 0.7 min, robot arm 17.9 -> 10.8 min, field
generator 49.5 -> 26.9 min, energy hatch 8.9 -> 4.7 min); from UMV to UXV it was 0.7x to 0.9x. A magmatter ingot from neutronium costs
about as much energy as a universium ingot from the fusion reactors (21 against 16.7 GJ) and the MAX factory is twice the UXV one, so the
MAX tier is not harder than the UXV tier; the levers are `MAGMATTER_RATIO` and the metal list in 140 (see open points).

### Numbers

`devcheck all`: RESULT OK; `migrate --from-ref v0.3.2`: loads, every old-save check ok. Researchable technologies 372 -> 385 of
391 -> 404 (the 13 new ones), draft recipes hidden 0, the `FORK-DRAFT`, `FORK-AUTOUNLOCK` (54) and `FORK-REMOVED` (35) lines
identical to phase 6a (every new recipe is unlocked explicitly), unlocked but uncraftable recipes 0. Tech by tech against phase 6a:
prerequisites, science packs, unlocks and unit counts of all 391 technologies identical, only additions; no recipe changed. Recipes
97 new (173 with the quality mod's recycling recipes). Machines placed by `devcheck runtime` 512 -> 549 (the godforge and the 36 MAX
machines), crafting menu 2838 -> 2935 machine recipes shown, 241 kept hidden, 0 hidden without an allow-list entry. Required recipes of
`devcheck check` 34 -> 57; the recipe test of `devcheck runtime` 33 -> 39 (raw star matter and neutronium magmatter in a godforge, the
stellar catalyst in a plasma forge, the MAX motor in a ZPM assembly line, the maximum voltage coil in a MAX assembler, the MAX pack
from MAX parts in a UXV assembler); the turbine tier test has two MAX turbines (helium and neon plasma: exactly four MAX amps, the
cooled fluid back to the drop); a new post-victory test researches `godforge-upgrades` after `victory` (accepted by the engine, level
1 gives +5 % productivity). Graphics: sprites from GT textures (godforge support and inner casing, controller; the MAX hull for the
basic machines, MAX energy and dynamo hatches on the upgrades and the turbine), 39 item icons (GT's magmatter icon set, the MAX
components and coil of `gt.metaitem`, GT's cosmic circuits for the Planck line, the core mod's Planck circuit), 13 technology icons,
review sheets in `docs/graphics-review/phase-6b/`.

### Existing saves

Only additions: new items, recipes, technologies and fluids; no prototype renamed, no recipe or technology of phase 6a changed, so no
`FORK-AUTOUNLOCK` change. Saves from 0.3.2 load (`migrate --from-ref v0.3.2`); `victory` wins the game as before. The 6a hooks that were
replaced: none removed (the DTPF universium recipes stay next to the godforge's).

### Open points

- Balance in the real game: the godforge (11.7 hours in the UXV factory, about one stargate); magmatter, which is cheap from neutronium
  (`MAGMATTER_RATIO` and `MAGMATTER_METALS` in 140; GT's random challenges do not let the player pick the cheapest metal), so the MAX
  parts take only a third to 0.6 of the UXV parts' time in the factory of their tier; the star fuel (`STAR_FUEL`) and the MAX pack from
  MAX parts.
- The eye of harmony, quark gluon plasma, the MAX recipes of the plasma forge and the QFT (see above).
- The godforge sprite is a plain field of GT's godforge casings with the controller; GT's star and rings are not drawn.

## Recipe audit (issue #91)

The audit of issue #91 (`devcheck check --balance-out` on main at 13a9245): recipes that exist but no technology unlocks,
casts the fluid solidifier does not have, melts the fluid extractor does not have, fluids nothing makes or uses. The
maintainer's decisions (issue comment): unlock all of them; every castable form of every material with a molten fluid in
the solidifier, with the one generic mold; a fluid extractor recipe for every ingot with a molten fluid and molten fluids
for the materials without one; the dead fluids get their GregTech producers and uses. Three pull requests, each based on
the one before.

### Part 1: unlocks (`prototypes/142-fork-recipe-unlocks.lua`)

Re-run of the audit: 331 Gregtorio recipes (created or changed by Gregtorio, not hidden) that no researchable technology
unlocked (the issue's 320, the 11 furnace recipes `raw-*-smelter` of the ore lines, `quantum-processor`, a vanilla recipe
Gregtorio rewrites). Each got a technology in the explicit table `UNLOCKS`, found like this: a research-order simulation of
the dump (technologies by tier, then by their number of prerequisites) gives the first technology after which a recipe
can be crafted; it was moved to the technology of its material or machine (the blocks, 16x wires, long rods and plates of
a metal to the technology of its ingot) or of its line where that is where a player looks, at or above the tier of the
simulation's choice. Exceptions, on EV technologies like upstream's other alloy blast smelter alloys although the smelter
needs IV parts: the GT++ alloys without a technology of their own (with `alloy-blast-smelter`) and the PBI recipes (with
`polybenzimidazole`). Lines whose product main makes later by another route went to that route's technology, so nothing
comes earlier than on main: bastnasite (neodymium) to `neodymium`, molybdenite (molybdenum) to `tungstate-processing`,
the PTFE carbon fibres to `nanoprocessors`, chromite to `titanium`. Unlocking new producers moved some of the auto-unlock's
earlier choices (its rule pulls the producer of an ingredient nothing unlocked makes); `KEEP` pins them where they were, and
every recipe main unlocks is on the same technologies as before.

Producers GT has and Gregtorio lacked, so the unlocked recipes can be made: signalum (EnderIO's alloy smelter recipe of
GTNH), the naquadah doped boule (GT's EBF recipe on Gregtorio's boule scale), charcoal byproducts (GT's pyrolyse oven),
super glue (GT++'s ten-step glue line condensed into seven recipes without the catalysts, new technology `super-glue`, IV),
the ender tanks as machines (the air collector with the ender tank recipes; upstream's entities were commented out), the
component assembly line (GoodGenerator's CoAL: GT's controller recipe, the ZPM assembly line's sprites, crafting speed 1 so
a recipe takes GT's base time) for the 32 `-coal` recipes, and microminer missions of the tier three microminer for the
ores of GT's space veins (neutronium, black plutonium, infinity catalyst, cosmic neutronium; chromite on the tier two
microminer). The depleted fuel rods are the burnt result of the fuel rods in the EV nuclear reactor; devcheck's model
counts burnt results now. The tier four microminer (the lunar mission, its signalum engine, moon dust) got the technology
`tier-four-microminers` (IV).

Stay locked (`FORK_RECIPES_LOCKED`, devcheck fails on any other locked Gregtorio recipe): calcium, cerium-rich mixture and
phosphorus (placeholders without ingredients: items from nothing), the ultimate extended crafting component, catalyst and
table (the component needs four of itself; Extended Crafting is not in GTNH), the five firestone recipes (no firestone ore:
GT has no firestone vein) and `plastic-circuit-board-peca` (its polyethylcyanoacrylate sheet is commented out upstream:
16 boards from copper foil and acid).

Not done: the large heat exchanger, large and high pressure steam turbine, fluid nuclear reactor and lapotronic
supercapacitor are unlocked but are items without an entity (upstream has none); the dusts of neutronium, black plutonium,
infinity catalyst and cosmic neutronium from the new missions have no use (GT turns them into ingots in the blast
furnace). Correction (issue #98): GT's fusion reactor makes only neutronium (`FusionReactorRecipes.java:131-137`);
Gregtorio's fusion recipes for cosmic neutronium, infinity and draconium (`131-fork-uev.lua`) are fork additions (GTNH
makes them in the plasma forge and, cosmic neutronium, through Avaritia). Neutronium and infinity catalyst dust have a
use (the neutronium chain of 23/127 and the infinity catalyst); black plutonium and cosmic neutronium dust go through
GT's blast furnace and vacuum freezer since #98 (`145-fork-gt-routes.lua`).

### Part 2: solidifier and melting (`prototypes/143-fork-casting.lua`)

GT's casts per form (GT litres per part, seconds; here a tenth of the litres, the time at the material's tier): ingot
144 1.6, plate 144 1.6, block 1296 (mass x 9 ticks; here 14.4 s), nugget 16 0.8, gear (GT's small gear) 144 0.8, large
gear (GT's gear) 576 6.4, rotor 612 (mass ticks; here 4.9 s like the upstream endgame casts), rod 72 7.5, long rod 144
15, bolt 18 2.5, ring 36 5, screw 18 2.5, round 16 2.5; the extractor melts an ingot into 144 in 24 ticks. Per material
the table `MATERIALS` has the solidifier tier (its ingot cast's tier, else the higher of its ingot recipe's machine tier
and its technology's tier) and the technology (the later of the material's and the tier's solidifier and extractor); the
forms are the items that exist and have no cast from the melt yet. 322 casts, 113 melt recipes (10 of them for materials
whose existing melt recipe is the IV extractor recipe of the fusion inputs, unlocked at LuV or ZPM), 45 new melts (not
for the mixed metal, wrapped plutonium and iridium alloy ingots, which are items; chromium has molten chrome). The casts
and melts are no producers for the auto-unlock of 199: ingot -> melt -> ingot would let an ingot stand in for itself and
the auto-unlock stopped pulling in 21 real recipes (iridium ingot among them, which broke LuV). Same amounts as the
machine routes, so the casts are no shortcut in material; they beat the lossy crafting table recipes, as in GT, and some
parts come a tier earlier than main's machine route (listed in the pull request).

### Part 3: dead fluids (`prototypes/144-fork-dead-fluids.lua`)

After parts 1 and 2 (the melts of black steel, blue steel, tantalum and tungsten with their casts; the nether and ender
air; charcoal byproducts; super glue; diluted hydrochloric acid's concentration) and leaving out the fluids that
generators burn (the plasmas and the naquadah and excited fuels have fuel values in 136 and are burnt by the plasma
turbines and large naquadah reactors; the audit counted only recipe uses), GregTech's uses and producers:

- neon, krypton, xenon: GT's blast furnace gases (`BlastFurnaceGasStat.java`): every blast furnace recipe with argon,
  helium or radon gets a variant with each, at GT's ratios to the gas it replaces (time x 0.6/0.5/0.4, gas x
  0.55/0.4/0.25 of the nitrogen base; argon 0.8 and 0.85, helium 0.9 and 1, radon 0.7 and 0.7); 23 recipes, 69 variants,
  unlocked with the base recipe and at the earliest with end-steel. Nitrogen recipes are left out (some use it as a
  reactant).
- nitrogen dioxide: GT's 2 NO2 + O + H2O -> 2 HNO3.
- gasoline: GT's raw gasoline and gasoline (two HV recipes, raw gasoline is a new fluid) and a gasoline cell for the
  combustion generator at GT's fuel value (576 EU per litre; Gregtorio's cells are 500 J per GT EU, 800 per cell).

No GT counterpart or no GT use Gregtorio could take, proposals in the pull request: high octane gasoline (GT: gasoline,
octane, nitrous oxide, toluene and anti-knock; octane comes from the distillation of hydrocracked light fuel, a cracking
line Gregtorio does not have), butyraldehyde (GT: hydroformylation of propene; its only use is butanol, whose uses are
GT++ chains Gregtorio does not have), imaginary time (not in GT; only the unloaded upstream drafts of
51-nuclear-module.lua use it), molten sunnarium (correction, issue #98: GT uses it, in the PPIC wafer, NH
`ChemicalReactorRecipes.java:251-257`, the PrNPIC mask of gtnhlanth, the DEFC draconic core of kubatech and the research
assembly line; Gregtorio's upstream draconic core is in the unloaded 23-zpm-age-item.lua) and
exhausted water (not in GT; a byproduct of upstream's deuterium recipe).

Issue #98 (`prototypes/145-fork-gt-routes.lua`) did the rest: the PECA board deleted (GT has no polyethylcyanoacrylate),
the printed board at GT's 40 s and its sodium persulfate variant, black plutonium and cosmic neutronium through GT's
blast furnace (every gas) and vacuum freezer, the high octane gasoline line (hydrocracked light fuel, octane, nitrous
oxide, anti-knock agent; the large chemical reactors from EV up got a fifth fluid input for it) with its cell, GT's
deuterium from hydrogen instead of upstream's water recipe, GT's PPIC wafer with molten sunnarium; exhausted water,
butyraldehyde and imaginary time deleted (old saves: exhausted water becomes water).

### Platinum line (issue #96, `prototypes/146-fork-platinum-line.lua`)

Upstream's platinum line (19-iv-age-item.lua: leachate, hexachloroplatinate, chloroplatinic acid, rarest metal
mixture) is GregTech CEu's. GTNH uses bartworks' chain (`bartworks/system/material/gtenhancement/
PlatinumSludgeRecipes.java`), which replaces it: part 1 (platinum and palladium) takes GT's sludge sources and sludge
centrifuge, the platinum concentrate (from the metallic powder and straight from the ores with platinum group metals),
platinum salt and reprecipitated platinum, palladium enriched ammonia, palladium salt and reprecipitated palladium, and
bartworks' rule that ore processing gives twice the metallic powder instead of platinum or palladium dust. The six
technologies keep their names. Part 2 replaces the rhodium, ruthenium, osmium and iridium branches with bartworks' (potassium
disulfate, rhodium sulfate, filter cake and reprecipitated rhodium; sodium ruthenate and ruthenium tetroxide; osmium
solution; iridium dioxide and iridium chloride; GT's fluid heater step of the ruthenium line is part of its
distillation, Gregtorio has no fluid heater). Per platinum residue: about 0.21 rhodium, 0.75 ruthenium, 0.31 iridium,
0.03 osmium (the GTCEu platinum group residue gave 0.67, 0.19, 0.29, 0.12). Per metallic platinum powder (salt loop closed): 0.71
platinum dust, 128 palladium enriched ammonia, 0.71 platinum residue; one palladium unit (a powder or 100 ammonia):
0.36 palladium dust.
