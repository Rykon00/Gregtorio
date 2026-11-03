--- Fork: research counts from UV to victory (issues #30, #31, #33: "Balance pass: endgame" in docs/ROADMAP.md).
--- The upstream unit counts (1500 to 5000 per technology) cost 37 hours of pack production per UV technology
--- and 100 to 480 hours per UHV to UXV technology in the reference factory of their tier; a ZPM technology
--- costs about 8 hours. Every technology from UV up is scaled so it costs about as long as a ZPM technology
--- of the same count in the factory of its tier (the factory doubles with every tier, so the real cost still
--- doubles): UV /4.5, UHV and UEV /13.9, UIV /25.3, UMV /32.2, UXV /59.3, rounded. The UXV technologies and
--- the `stargate` technology then cost about as long as building the stargate (8 against 10 hours).
--- Issue #773: the parts and recipes that came since drifted the median technology of UV to UMV away from 8 hours
--- (UV 5.5, UHV 7.2, UEV 10.3, UIV 12.2, UMV 10.1 hours in tools/balance_model.py); the counts of these tiers are scaled
--- so the median is 8 hours again: UV x1.417 (/3.2), UHV x1.098 (/12.7), UEV x0.756 (/18.4), UIV x0.646 (/39.2), UMV
--- x0.764 (/42.1), rounded to 5 (to 25 above 200); the technologies of other files at their tier's cost with them.
--- Loaded after every file that defines or changes technologies up to 141 (also after 139, the phase 6a multiblocks,
--- whose technologies get their counts here). The infinite `research-productivity` keeps its formula; the vanilla techs
--- in devcheck's UNRESEARCHABLE_OK are left alone. Issue #605: the files 145 to 166 load after this one, so their
--- technologies of UV science and up are in this table too and data-final-fixes.lua calls FORK_RESEARCH_BALANCE.apply()
--- once more at the end; devcheck fails for a technology of 9 or more packs whose count lies outside the band of its pack
--- count (from 50, the count of the reach and space elevator technologies, or the lowest count of this table at that pack
--- count if lower, to the highest count of this table at that pack count), unless it is in the allow-list
--- FORK_RESEARCH_OUTLIERS with its reason.
local FORK_RESEARCH_COUNTS = {
	-- UV (agricultural pack): /3.2 (issue #773; /4.5 before, the counts x1.417)
	["bedrockium"] = 1275, -- 4000
	["complex-smds"] = 650, -- 2000
	["electromagnetic-science-pack"] = 500, -- 1600
	["large-naquadah-reactor"] = 950, -- 3000
	["tree-seeding"] = 15, -- 50
	["uhv-components"] = 1550, -- 5000
	["uhv-materials"] = 1275, -- 4000
	["uv-energy-hatches"] = 650, -- 2000
	["uv-machines"] = 450, -- 1500
	["uv-multiblocks"] = 650, -- 2000
	["uv-plasma-turbine"] = 775, -- 2500
	["wetware-processor-mainframes"] = 1425, -- 4500
	["wetware-processors"] = 1275, -- 4000
	-- UHV (electromagnetic pack): /12.7 (issue #773; /13.9 before, the counts x1.098)
	["bio-processor-mainframes"] = 275, -- 3500
	["bio-processors"] = 250, -- 3000
	["cryogenic-science-pack"] = 145, -- 1800
	["femto-power-ics"] = 250, -- 3000
	["fusion-plasmas-mk3"] = 275, -- 3500
	["fusion-reactor-mk3"] = 275, -- 3500
	["quantium"] = 250, -- 3000
	["space-coolant-cells"] = 200, -- 2500
	["uev-components"] = 325, -- 4000
	["uev-materials"] = 200, -- 2500
	["uhv-energy-hatches"] = 200, -- 2500
	["uhv-machines"] = 160, -- 2000
	["uhv-multiblocks"] = 200, -- 2500
	["uhv-naquadah-reactor"] = 250, -- 3000
	["uhv-plasma-turbine"] = 200, -- 2500
	-- UEV (cryogenic pack): /18.4 (issue #773; /13.9 before, the counts x0.756)
	["atto-power-ics"] = 170, -- 3000
	["fusion-plasmas-mk4"] = 225, -- 4000
	["fusion-reactor-mk4"] = 225, -- 4000
	["optical-processor-mainframes"] = 225, -- 4000
	["optical-processors"] = 190, -- 3500
	["promethium-science-pack"] = 110, -- 2000
	["uev-energy-hatches"] = 170, -- 3000
	["uev-machines"] = 135, -- 2500
	["uev-multiblocks"] = 170, -- 3000
	["uev-naquadah-reactor"] = 170, -- 3000
	["uev-plasma-turbine"] = 135, -- 2500
	["uiv-components"] = 250, -- 4500
	["uiv-materials"] = 170, -- 3000
	-- UIV (promethium pack): /39.2 (issue #773; /25.3 before, the counts x0.646)
	["exotic-processor-mainframes"] = 80, -- 3000
	["dimensionally-transcendent-plasma-forge"] = 165, -- phase 6a (139); UEV since issue #624 (GTNH's tier; 3000 / 13.9)
	["exotic-processors"] = 65, -- 2500
	["fusion-coil-ii"] = 65, -- 2500
	["fusion-plasmas-mk5"] = 80, -- 3000
	["fusion-reactor-mk5"] = 80, -- 3000
	["uiv-energy-hatches"] = 90, -- 3500
	["uiv-machines"] = 80, -- 3000
	["uiv-multiblocks"] = 90, -- 3500
	["uiv-naquadah-reactor"] = 80, -- 3000
	["uiv-plasma-turbine"] = 65, -- 2500
	["umv-components"] = 80, -- 3000
	["umv-materials"] = 65, -- 2500
	["umv-science-pack"] = 60, -- 2300
	-- UMV: /42.1 (issue #773; /32.2 before, the counts x0.764)
	["quantum-force-transformer"] = 75, -- new in phase 6a
	["godforge"] = 80, -- phase 6b (140); UIV science since issue #624 (GTNH's tier; 3000 / 25.3)
	["godforge-plasma-module"] = 75, -- issue #355: GT's plasma module upgrades for celestial tungsten plasma
	["temporal-processor-mainframes"] = 75, -- 3000
	["temporal-processors"] = 75, -- 3000
	["umv-energy-hatches"] = 75, -- 3000
	["umv-machines"] = 60, -- 2500
	["umv-multiblocks"] = 75, -- 3000
	["umv-naquadah-reactor"] = 75, -- 3000
	["umv-plasma-turbine"] = 60, -- 2500
	["uxv-components"] = 85, -- 3500
	["uxv-materials"] = 60, -- 2500
	["uxv-science-pack"] = 60, -- 2600
	-- UXV and MAX: /59.3
	["dtpf-resplendent-catalyst"] = 50, -- new in phase 6a
	["stargate"] = 50, -- 3000
	["uxv-energy-hatches"] = 50, -- 3000
	["uxv-machines"] = 50, -- 3000
	["uxv-multiblocks"] = 50, -- 3000
	["uxv-naquadah-reactor"] = 50, -- 3000
	["uxv-plasma-turbine"] = 40, -- 2500
	-- phase 6b (140-fork-godforge.lua, 141-fork-max.lua), MAX science: about 8 hours of pack production each in
	-- the MAX reference factory (the UXV one doubled, with godforges; tools/balance_model.py)
	["godforge-molten-module"] = 55,
	["godforge-exotic-module"] = 55,
	["dtpf-stellar-catalyst"] = 55,
	["max-materials"] = 55,
	["planck-processors"] = 55,
	["planck-processor-mainframes"] = 55,
	["max-components"] = 55,
	["max-machines"] = 55,
	["max-energy-hatches"] = 55,
	["max-multiblocks"] = 55,
	["max-plasma-turbine"] = 55,
	-- issue #249: the MAX recipes of the plasma forge and the QFT (141)
	["dtpf-max-recipes"] = 55,
	["qft-temporal-harmony"] = 55,
	-- issue #605: the technologies of 145 to 166 (loaded after this file) with their upstream-sized counts, scaled the
	-- same way
	["kevlar"] = 450, -- UV, 1500 (164)
	["prismatic-naquadah"] = 450, -- UV, 1500 (164)
	["thorium-based-liquid-fuel"] = 200, -- UHV, 2500 (164)
	["precise-electronic-unit-mk3"] = 200, -- UHV, 2500 (164)
	["naquadah-fuel-refinery"] = 120, -- UHV, 1500 (164)
	["beamline"] = 120, -- UHV, 1500 (164)
	["radox-polymer"] = 85, -- UEV, 1500 (164)
	["six-phased-copper"] = 50, -- UXV, 60 (164), as 138's UXV technologies
	-- issue #773: technologies of other files with UV to UMV packs (counts set there to their tier's cost), rescaled
	-- like the tiers above (count before in the comment)
	["froth-processing"] = 425, -- UV, 300
	["me-crafting-storage-4096k"] = 650, -- UV, 450
	["me-fluid-storage-4096k"] = 425, -- UV, 300
	["me-storage-4096k"] = 650, -- UV, 450
	["milling-and-flotation"] = 425, -- UV, 300
	["me-crafting-accelerators-2"] = 275, -- UHV, 250
	["me-crafting-storage-16384k"] = 250, -- UHV, 225
	["me-fluid-storage-16384k"] = 165, -- UHV, 150
	["me-storage-16384k"] = 250, -- UHV, 225
	["netherite"] = 325, -- UHV, 300
	["dyson-swarm"] = 80, -- UIV, 120
	["wireless-energy"] = 65, -- UIV, 100
	["chaotic-cores"] = 75, -- UMV, 95
	["dimensionally-shifted-superfluid"] = 75, -- UMV, 95
	["hypogen"] = 75, -- UMV, 95
	["large-hadron-collider"] = 75, -- UMV, 95
	["me-storage-singularity"] = 75, -- UMV, 95
	["nano-forge"] = 75, -- UMV, 95
	["naquadah-based-fuel-mk4"] = 75, -- UMV, 95
	["naquadah-based-fuel-mk5"] = 75, -- UMV, 95
	["rare-earth-ion-extraction"] = 75, -- UMV, 95
}
--- Issue #605: technologies of 9 or more packs whose count lies outside the band of devcheck's research count rule on
--- purpose (technology -> reason)
FORK_RESEARCH_OUTLIERS = {}
--- `final`: the last call (data-final-fixes.lua), which logs a name of the table that is no technology with a count
FORK_RESEARCH_BALANCE = { counts = FORK_RESEARCH_COUNTS }
function FORK_RESEARCH_BALANCE.apply(final)
	for name, count in pairs(FORK_RESEARCH_COUNTS) do
		local tech = data.raw.technology[name]
		if tech and tech.unit and tech.unit.count then
			tech.unit.count = count
		elseif final then
			log("FORK-RESEARCH: no counted technology " .. name)
		end
	end
end
FORK_RESEARCH_BALANCE.apply(false)

--- Victory: 15 units per level instead of 1000 (/59.3 like the UXV technologies). Level 1 costs the stargate
--- (1000 MAX packs from one stargate) and 15 units of the other 14 packs; the MAX packs of one stargate
--- last for the first six levels (15 * (2^6 - 1) = 945).
data.raw.technology["victory"].unit.count_formula = "15 * 2^(L-1)"

--- Phase 6b: the infinite `godforge-upgrades` (GT's graviton shard upgrades), the long-term sink after victory
--- with the further victory levels: level 1 costs as much as a MAX technology (8 hours), every level twice the one
--- before
data.raw.technology["godforge-upgrades"].unit.count_formula = "55 * 2^(L-1)"
