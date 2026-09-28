--------------------------------------------------------------------------------
--- FORK ENDGAME (roadmap phase 5b)
--- The last project of the mod: the stargate and what it opens.
---   * the stargate and its parts (ring blocks, chevron blocks, base, power unit, controller,
---     chevron upgrade, iris upgrade) are the drafts in 11-lv-age-item.lua, whose recipes used
---     each other as ingredients (dead ends). They are rebuilt here from UXV parts.
---   * the MAX science pack recipe of 11-lv-age-item.lua (1 stargate -> 1000 packs) is kept
---   * researching the technology `victory` wins the game (scripts/fork-victory.lua)
--- 90-uxv-age-item.lua (not loaded) has the GTNH version: block of magmatter, dark matter, mellion,
--- shirabon, the eye of harmony and the space assembler modules, hundreds of thousands of mB of
--- catalysts. Here every part is made of the metals of the last tiers (infinity, transcendent metal,
--- spacetime, universium), UXV components and fusion parts: depth without new chains.
--------------------------------------------------------------------------------

local F = FORK5B

--- Recipes of the parts run in the ZPM assembly line (4 fluid inputs, the biggest machine that is
--- not tied to a voltage tier); minutes as in the component recipes (a minute = 30 * ZPM_SPEED).
local AL = "zpm-assembly-line-recipes"
local function minutes(n) return n * 30 * ZPM_SPEED end

if not data.raw["item-subgroup"]["subgroup-stargate"] then
	data:extend({ { type = "item-subgroup", name = "subgroup-stargate", group = "processing-machine-recipes", order = "zz-stargate" } })
end

local function item(name, amount) return { type = "item", name = name, amount = amount } end
local function fluid(name, amount) return { type = "fluid", name = name, amount = amount } end



--------------------------------------------------------------------------------
--- 1) PARTS OF THE PARTS
--- Frame part: long rods of the four last metals. Radiation containment plate: the plates of the
--- last two metals and superdense neutronium. Chevron: universium and spacetime, a gravi star and
--- a UXV circuit. Iris blade: foils of the last two metals.
--------------------------------------------------------------------------------

create_item{
	name = "stargate-frame-part",
	category = AL,
	energy_required = minutes(4),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("long-infinity-rod", 4),
		item("long-transcendent-metal-rod", 4),
		item("long-spacetime-rod", 4),
		item("long-universium-rod", 4),
		item("universium-frame", 2),
		fluid("molten-universium", 576),
		fluid("molten-spacetime", 576),
		fluid("molten-indalloy-140", 288),
	},
}
create_item{
	name = "stargate-radiation-containment-plate",
	category = AL,
	energy_required = minutes(2),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("superdense-neutronium-plate", 1),
		item("universium-plate", 8),
		item("spacetime-plate", 8),
		item("polybenzimidazole-sheet", 16),
		fluid("molten-universium", 288),
		fluid("molten-indalloy-140", 288),
	},
}
create_item{
	name = "stargate-chevron",
	category = AL,
	energy_required = minutes(3),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("universium-frame", 2),
		item("spacetime-plate", 8),
		item("gravi-star", 4),
		item("uxv-circuit", 2),
		item("eternity-wire", 16),
		fluid("molten-universium", 288),
		fluid("molten-indalloy-140", 288),
	},
}
create_item{
	name = "stargate-iris-blade",
	category = AL,
	energy_required = minutes(2),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("universium-foil", 32),
		item("spacetime-foil", 32),
		item("superdense-neutronium-plate", 1),
		fluid("molten-universium", 288),
		fluid("molten-indalloy-140", 288),
	},
}



--------------------------------------------------------------------------------
--- 2) THE STARGATE PARTS (the drafts of 11-lv-age-item.lua, category and ingredients replaced)
--- Ring block: 16 of them in total (8 in the stargate, and the chevron blocks below need none
--- any more: the draft asked for a ring block in a chevron block and in the power unit, which
--- made them cyclic). Chevron block: 7 in the stargate, one chevron upgrade each.
--------------------------------------------------------------------------------

F.redo("stargate-ring-block", {
	category = AL,
	energy_required = minutes(5),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("universium-plate", 16),
		item("stargate-frame-part", 3),
		item("stargate-chevron", 1),
		item("stargate-radiation-containment-plate", 3),
		item("uxv-field-generator", 1),
		item("uxv-circuit", 4),
		fluid("molten-universium", 576),
		fluid("molten-indalloy-140", 288),
	},
})
F.redo("stargate-chevron-block", {
	category = AL,
	energy_required = minutes(5),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("universium-plate", 16),
		item("stargate-chevron-upgrade", 1),
		item("stargate-frame-part", 2),
		item("stargate-radiation-containment-plate", 2),
		item("uxv-emitter", 1),
		item("uxv-piston", 2),
		item("uxv-circuit", 4),
		fluid("molten-universium", 576),
		fluid("molten-indalloy-140", 288),
	},
})
F.redo("stargate-chevron-upgrade", {
	category = AL,
	energy_required = minutes(3),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("stargate-frame-part", 2),
		item("stargate-chevron", 1),
		item("uxv-sensor", 1),
		item("uxv-emitter", 1),
		item("uxv-piston", 2),
		fluid("molten-universium", 288),
		fluid("molten-indalloy-140", 288),
	},
})
F.redo("stargate-base", {
	category = AL,
	energy_required = minutes(10),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("uxv-field-generator", 4),
		item("uxv-emitter", 4),
		item("uxv-robot-arm", 4),
		item("advanced-fusion-coil-ii", 2),
		item("stargate-radiation-containment-plate", 4),
		item("stargate-frame-part", 4),
		item("uxv-circuit", 16),
		item("eternity-superconductive-wire", 32),
		fluid("molten-universium", 1152),
		fluid("molten-indalloy-140", 576),
	},
})
F.redo("stargate-power-unit", {
	category = AL,
	energy_required = minutes(10),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("advanced-fusion-coil-ii", 8),
		item("uxv-field-generator", 2),
		item("uxv-energy-hatch", 4),
		item("stargate-radiation-containment-plate", 4),
		item("universium-plate", 32),
		item("uxv-circuit", 8),
		item("eternity-superconductive-wire", 64),
		fluid("molten-universium", 1152),
		fluid("molten-indalloy-140", 576),
	},
})
F.redo("stargate-controller", {
	category = AL,
	energy_required = minutes(10),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("uxv-circuit", 32),
		item("uxv-sensor", 2),
		item("uxv-emitter", 2),
		item("uxv-conveyor-module", 4),
		item("gravi-star", 16),
		item("stargate-frame-part", 4),
		item("stargate-radiation-containment-plate", 4),
		fluid("molten-universium", 576),
		fluid("molten-indalloy-140", 576),
	},
})
F.redo("stargate-iris-upgrade", {
	category = AL,
	energy_required = minutes(5),
	subgroup = "subgroup-stargate",
	ingredients = {
		item("stargate-iris-blade", 8),
		item("universium-plate", 24),
		item("superdense-neutronium-plate", 2),
		fluid("molten-universium", 576),
		fluid("molten-indalloy-140", 288),
	},
})

--- The stargate: the assembly of everything above, in the UXV assembler (the UXV machines need the UXV
--- pack). The ingredient list of the draft is kept: 8 ring blocks, 7 chevron blocks, one of the rest.
F.redo("stargate", {
	category = "uxv-assembling-machine-recipes",
	energy_required = 120 * UXV_SPEED,
	subgroup = "subgroup-stargate",
})

--- The MAX science pack (draft recipe of 11-lv-age-item.lua, 1 stargate -> 1000 packs, UXV assembler).
--- One level of `victory` takes 1000 of them: a stargate is what the first level costs, every
--- further level doubles it.



--------------------------------------------------------------------------------
--- TECHNOLOGIES
--- The upstream `stargate` tech (UXV science) unlocks the parts, the stargate and the MAX science pack.
--- It now also unlocks the parts of the parts and requires the UXV machines, blast furnace coils
--- and multiblocks (the stargate is assembled in the UXV assembler and its parts need the UXV energy
--- hatch).
--------------------------------------------------------------------------------

for _, r in pairs({ "stargate-frame-part", "stargate-radiation-containment-plate", "stargate-chevron", "stargate-iris-blade" }) do
	fork_add_unlock("stargate", r)
end
table.insert(data.raw.technology["stargate"].prerequisites, "uxv-multiblocks")
