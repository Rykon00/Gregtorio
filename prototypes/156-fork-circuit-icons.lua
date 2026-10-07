--------------------------------------------------------------------------------
--- FORK CIRCUIT VARIANT ICONS (issue #164)
--- In GT New Horizons every circuit of a tier is its own item with its own texture (Vacuum Tube ... Crystal Mainframe,
--- GT5-Unofficial MetaGeneratedItem01.java 700-706 and MetaGeneratedItem03.java 78-96, 305, 306), and a recipe takes any
--- circuit of the tier (the OreDict circuit tag). Factorio has no such tag, so Gregtorio keeps one item per tier
--- (electronic-circuit to uv-circuit) and every variant recipe gives it (maintainer's decision on #164): the variants
--- are told apart by their recipe icon, GT's texture of the item the recipe makes in GTNH (tools/gen_gt_icons.py,
--- graphics/icons/circuit-recipe-<recipe>.png). From the wetware line up the processor, assembly and supercomputer are
--- items of their own already; their mainframes are the only recipes of their tier item and keep its icon.
--- The GTNH item per recipe, matched by the ingredients (board, chip, tier):
---   LV   electronic-circuit, basic-electronic-circuit         Basic Electronic Circuit (vacuum tubes, resin board)
---        basic-integrated-circuit                             Integrated Logic Circuit (ILC chip)
---        microchip (+ -smd, -cheap)                           Microprocessor (CPU chip, plastic board)
---   MV   advanced-circuit, good-electronic-circuit            Good Electronic Circuit (phenolic board, diodes)
---        good-integrated-circuit                              Good Integrated Circuit
---        microprocessor (+ -smd, -cheap)                      Integrated Processor
---   HV   processing-unit                                      Advanced Integrated Circuit (ILC and RAM chips)
---        microprocessor-assembly (+ -smd)                     Processor Assembly
---        nanoprocessor                                        Nanoprocessor
---   EV   microprocessor-supercomputer (+ -smd)                Workstation
---        nanoprocessor-assembly                               Nanoprocessor Assembly
---        quantum-processor                                    Quantum Processor
---   IV   microprocessor-mainframe                             Mainframe
---        nanoprocessor-supercomputer                          Elite Nanocomputer
---        quantum-processor-assembly                           Quantum Assembly
---        crystal-processor                                    Crystal Processor
---   LuV  nanoprocessor-mainframe                              Nanoprocessor Mainframe
---        quantum-processor-supercomputer                      Quantum Supercomputer
---        crystal-processor-assembly                           Crystal Assembly
---   ZPM  quantum-processor-mainframe                          Quantum Mainframe
---        crystal-processor-supercomputer                      Crystal Supercomputer
---   UV   crystal-processor-mainframe                          Crystal Mainframe
--- Loads after 155 and before 196, 198 and 199 (they keep a recipe's own icon).
--------------------------------------------------------------------------------

local P = "__gregtorio-continued__/graphics/icons/"

FORK_CIRCUIT_RECIPE_ICONS = {
	"electronic-circuit", "basic-electronic-circuit", "basic-integrated-circuit",
	"microchip", "microchip-smd", "microchip-cheap",
	"advanced-circuit", "good-electronic-circuit", "good-integrated-circuit",
	"microprocessor", "microprocessor-smd", "microprocessor-cheap",
	"processing-unit", "microprocessor-assembly", "microprocessor-assembly-smd", "nanoprocessor",
	"microprocessor-supercomputer", "microprocessor-supercomputer-smd", "nanoprocessor-assembly", "quantum-processor",
	"microprocessor-mainframe", "nanoprocessor-supercomputer", "quantum-processor-assembly", "crystal-processor",
	"nanoprocessor-mainframe", "quantum-processor-supercomputer", "crystal-processor-assembly",
	"quantum-processor-mainframe", "crystal-processor-supercomputer",
	"crystal-processor-mainframe",
}

local set = 0
for _, name in pairs(FORK_CIRCUIT_RECIPE_ICONS) do
	local r = data.raw.recipe[name]
	if r then
		r.icon = P .. "circuit-recipe-" .. name .. ".png"
		r.icon_size = 32
		r.icons = nil
		set = set + 1
	else
		log("FORK-CIRCUIT-ICONS: no recipe " .. name)
	end
end
log("FORK-CIRCUIT-ICONS: " .. set .. " circuit recipes with their GTNH item's icon")
