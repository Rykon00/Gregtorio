--------------------------------------------------------------------------------
--- FORK CIRCUIT VARIANT ICONS (issue #164)
--- In GT New Horizons every circuit of a tier is its own item with its own texture (Vacuum Tube ... Crystal Mainframe,
--- GT5-Unofficial MetaGeneratedItem01.java 700-706 and MetaGeneratedItem03.java 78-96, 305, 306), and a recipe takes any
--- circuit of the tier (the OreDict circuit tag). Factorio has no such tag, so Gregtorio keeps one item per tier
--- (electronic-circuit to uv-circuit) and every variant recipe gives it (maintainer's decision on #164): the variants
--- are told apart by their recipe icon, GT's texture of the item the recipe makes in GTNH (tools/gen_gt_icons.py,
--- graphics/icons/circuit-recipe-<recipe>.png). From the wetware line up the processor, assembly and supercomputer are
--- items of their own already; their mainframes are the only recipes of their tier item and keep its icon.
--- The GTNH item per recipe, matched by the ingredients (board, chip, tier); issue #445: the recipes show these names
--- (GT5-Unofficial en_US.lang, gt.item.circuit.*), except the three named after their tier item:
---   LV   electronic-circuit, basic-electronic-circuit         Basic Electronic Circuit (vacuum tubes, resin board)
---        basic-integrated-circuit                             Integrated Logic Circuit (ILC chip)
---        microchip (+ -smd, -cheap)                           Microprocessor (CPU chip, plastic board)
---   MV   advanced-circuit, good-electronic-circuit            Good Electronic Circuit (phenolic board, diodes)
---        good-integrated-circuit                              Good Integrated Circuit
---        microprocessor (+ -smd, -cheap)                      Integrated Processor
---   HV   processing-unit                                      Advanced Integrated Circuit (ILC and RAM chips)
---        microprocessor-assembly (+ -smd)                     Processor Assembly
---        nanoprocessor                                        Nano Processor
---   EV   microprocessor-supercomputer (+ -smd)                Workstation
---        nanoprocessor-assembly                               Nano Assembly
---        quantum-processor                                    Quantum Processor
---   IV   microprocessor-mainframe                             Mainframe
---        nanoprocessor-supercomputer                          Nano Supercomputer
---        quantum-processor-assembly                           Quantum Assembly
---        crystal-processor                                    Crystal Processor
---   LuV  nanoprocessor-mainframe                              Nano Mainframe
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



--------------------------------------------------------------------------------
--- ISSUE #450 (the maintainer's decisions of 2026-10-20)
--- (a) The ULV circuit tier: in GT New Horizons the Vacuum Tube (Circuit_Primitive) and the NAND Chip are ULV circuits
---     (OreDict circuitPrimitive / circuit ULV), and every recipe that takes a ULV circuit takes either. As the tiers above
---     (#164), Gregtorio has one item for the tier, `ulv-circuit`: the vacuum tube and NAND chip recipes give it (each
---     with its GTNH item's icon and name), and the recipes that took a vacuum tube or a NAND chip (the electronic
---     circuits, the ME storage components, the integral encasement) take it; the two items are gone (old saves:
---     migrations/2026-10-20-issue-450-ulv-circuit.json).
--- (b) The Nanoprocessor is GTNH's HV circuit (CircuitAssemblerRecipes.java:340-351: 600 EU/t, 10 s): its recipe in the HV
---     circuit assembler, its epoxy boards, foils, glowstone melt and carbon fibres with the HV technologies of their
---     inputs; its Nano CPU wafer stays EV as in GTNH (ChemicalReactorRecipes.java:265-268: RECIPE_EV), so the recipe
---     stays with Nanoprocessors.
--------------------------------------------------------------------------------
do
	local ULV = "ulv-circuit"
	local tube = data.raw.item["vacuum-tube"]
	data:extend({ {
		type = "item", name = ULV, icon = P .. ULV .. ".png", icon_size = 32,
		subgroup = tube and tube.subgroup or "subgroup-circuit-parts-assembler", order = "a[ulv-circuit]", stack_size = 64,
	} })
	local OLD = { ["vacuum-tube"] = true, ["nand-chip"] = true }
	local function swap(list)
		for _, i in pairs(list or {}) do
			if OLD[i.name] and i.type ~= "fluid" then i.name = ULV end
		end
	end
	for _, r in pairs(data.raw.recipe) do
		swap(r.ingredients)
		swap(r.results)
		if OLD[r.main_product or ""] then r.main_product = ULV end
	end
	for name in pairs(OLD) do data.raw.item[name] = nil end
	for _, name in pairs({ "vacuum-tube", "vacuum-tube-crafting-table", "nand-chip" }) do
		local r = data.raw.recipe[name]
		if r then
			r.icon = P .. "circuit-recipe-" .. name .. ".png"
			r.icon_size = 32
			r.icons = nil
		end
	end

	--- (b) the nanoprocessor at HV
	local nano = data.raw.recipe["nanoprocessor"]
	fork_set_category(nano, "hv-circuit-assembler-recipes")
	nano.energy_required = 10 * HV_SPEED
	--- (the gold foil comes earlier, with the good circuit board: issue #712, 164 section 57)
	local MOVE = {
		["epoxy-processing"] = { "epoxy-sheet", "electrum-foil", "epoxy-circuit-board", "epoxy-printed-circuit-board",
			"raw-carbon-fibers-epoxy", "molten-glowstone" },
		["ptfe"] = { "raw-carbon-fibers-ptfe" },
	}
	local moved = {}
	for tech, list in pairs(MOVE) do
		for _, r in pairs(list) do
			fork_add_unlock(tech, r)
			moved[r] = true
		end
	end
	local t = data.raw.technology["nanoprocessors"]
	local keep = {}
	for _, e in pairs(t.effects) do
		if not (e.type == "unlock-recipe" and moved[e.recipe]) then keep[#keep + 1] = e end
	end
	t.effects = keep
end
