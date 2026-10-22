--------------------------------------------------------------------------------
--- FORK ORE VEINS (plan #494, the maintainer's decision of 2026-10-22): GTNH's ore veins as mixed ore patches on the
--- map and the T0 dimensions as surfaces. Phase V1 (issue #496): the data of GT's ore mixes,
--- prototypes/data/ore-mixes.lua (tools/gen_ore_mixes.py from GT5-Unofficial's OreMixes.java), and the rule that
--- every ore of a vein on one of Gregtorio's surfaces has a raw ore with GTNH's chain. No map change yet.
---
--- FORK_ORE_MIX_SURFACES: GT's dimensions (DimNames) that are, or become, surfaces of Gregtorio, with their surface
--- property gt-dimension (#494: 1 Overworld, 2 Nether, 3 Twilight Forest, 4 End).
--- FORK_ORE_MIX_SKIPPED: what is left out on purpose, with the reason; keys are a material, "mix:<GT name>" (the vein
--- is dropped) or "dimension:<DimNames>" (a dimension of GT's veins that is not a surface).
--- FORK_ORE_MIX_NO_CHAIN: materials whose ore GT processes without the ore chain, with the reason.
--- devcheck fails for an ore of a vein on a surface without a raw ore and its chain (the ore washer's purified-<ore>)
--- that is in neither list, for a dimension of GT's veins that is neither a surface nor skipped, and for a stale entry.
--- Loads after 161 (every raw ore exists, 155 has made the chains).
--------------------------------------------------------------------------------

FORK_ORE_MIXES = require("prototypes.data.ore-mixes")

FORK_ORE_MIX_SURFACES = {
	OW = 1, NETHER = 2, TWILIGHT_FOREST = 3, THE_END = 4,
}

local THAUMCRAFT = "Thaumcraft's infused shard; the mod has no Thaumcraft (#494 decision 4)"
FORK_ORE_MIX_SKIPPED = {
	["electrotine"] = "Project Red's ore, left out as in #363; its tiles fall to the neighbouring layer (#494 decision 4)",
	["infused-air"] = THAUMCRAFT, ["infused-earth"] = THAUMCRAFT, ["infused-entropy"] = THAUMCRAFT,
	["infused-fire"] = THAUMCRAFT, ["infused-order"] = THAUMCRAFT, ["infused-water"] = THAUMCRAFT,
	["mix:AquaIgnis"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
	["mix:TerraAer"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
	["mix:PerditioOrdo"] = "Thaumcraft vein of the Twilight Forest, dropped (#494 decision 4)",
}
--- the dimensions that keep their mines and the Void Miner pools for now (#494: not in this plan)
for _, d in pairs({ "ENDASTEROID", "EVERGLADES", "MOON", "DEIMOS", "MARS", "PHOBOS", "ASTEROIDS", "CALLISTO", "CERES",
	"EUROPA", "GANYMEDE", "ROSS128B", "IO", "MERCURY", "VENUS", "ENCELADUS", "MIRANDA", "OBERON", "TITAN", "ROSS128BA",
	"PROTEUS", "TRITON", "HAUMEA", "KUIPERBELT", "MAKEMAKE", "PLUTO", "BARNARDC", "BARNARDE", "BARNARDF", "CENTAURIBB",
	"TCETIE", "VEGAB", "ANUBIS", "HORUS", "MAAHES", "MEHENBELT", "NEPER", "SETH" }) do
	FORK_ORE_MIX_SKIPPED["dimension:" .. d] = "stays a mine or Void Miner pool for now (#494: not in this plan)"
end

FORK_ORE_MIX_NO_CHAIN = {
	["oilsands"] = "GT has no ore chain for it: the LV centrifuge turns the raw ore into heavy oil and sand "
		.. "(ProcessingRawOre.java:48, 160's centrifuging-raw-oilsands)",
}
