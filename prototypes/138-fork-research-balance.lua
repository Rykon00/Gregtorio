--- Fork: research counts from UV to victory (issues #30, #31, #33: "Balance pass: endgame" in docs/ROADMAP.md).
--- The upstream unit counts (1500 to 5000 per technology) cost 37 hours of pack production per UV technology
--- and 100 to 480 hours per UHV to UXV technology in the reference factory of their tier; a ZPM technology
--- costs about 8 hours. Every technology from UV up is scaled so it costs about as long as a ZPM technology
--- of the same count in the factory of its tier (the factory doubles with every tier, so the real cost still
--- doubles): UV /4.5, UHV and UEV /13.9, UIV /25.3, UMV /32.2, UXV /59.3, rounded. The UXV technologies and
--- the `stargate` technology then cost about as long as building the stargate (8 against 10 hours).
--- Loaded after every file that defines or changes technologies up to 141 (also after 139, the phase 6a multiblocks,
--- whose technologies get their counts here). The infinite `research-productivity` keeps its formula; the vanilla techs
--- in devcheck's UNRESEARCHABLE_OK are left alone. Issue #605: the files 145 to 166 load after this one, so their
--- technologies of UV science and up are in this table too and data-final-fixes.lua calls FORK_RESEARCH_BALANCE.apply()
--- once more at the end; devcheck fails for a technology of 9 or more packs whose count lies outside the band of its pack
--- count (from 50, the count of the reach and space elevator technologies, or the lowest count of this table at that pack
--- count if lower, to the highest count of this table at that pack count), unless it is in the allow-list
--- FORK_RESEARCH_OUTLIERS with its reason.
local FORK_RESEARCH_COUNTS = {
	-- UV (agricultural pack): /4.5
	["bedrockium"] = 900, -- 4000
	["complex-smds"] = 450, -- 2000
	["electromagnetic-science-pack"] = 350, -- 1600
	["large-naquadah-reactor"] = 675, -- 3000
	["tree-seeding"] = 10, -- 50
	["uhv-components"] = 1100, -- 5000
	["uhv-materials"] = 900, -- 4000
	["uv-energy-hatches"] = 450, -- 2000
	["uv-machines"] = 325, -- 1500
	["uv-multiblocks"] = 450, -- 2000
	["uv-plasma-turbine"] = 550, -- 2500
	["wetware-processor-mainframes"] = 1000, -- 4500
	["wetware-processors"] = 900, -- 4000
	-- UHV (electromagnetic pack): /13.9
	["bio-processor-mainframes"] = 250, -- 3500
	["bio-processors"] = 225, -- 3000
	["cryogenic-science-pack"] = 130, -- 1800
	["femto-power-ics"] = 225, -- 3000
	["fusion-plasmas-mk3"] = 250, -- 3500
	["fusion-reactor-mk3"] = 250, -- 3500
	["quantium"] = 225, -- 3000
	["space-coolant-cells"] = 180, -- 2500
	["uev-components"] = 300, -- 4000
	["uev-materials"] = 180, -- 2500
	["uhv-energy-hatches"] = 180, -- 2500
	["uhv-machines"] = 145, -- 2000
	["uhv-multiblocks"] = 180, -- 2500
	["uhv-naquadah-reactor"] = 225, -- 3000
	["uhv-plasma-turbine"] = 180, -- 2500
	-- UEV (cryogenic pack): /13.9
	["atto-power-ics"] = 225, -- 3000
	["fusion-plasmas-mk4"] = 300, -- 4000
	["fusion-reactor-mk4"] = 300, -- 4000
	["optical-processor-mainframes"] = 300, -- 4000
	["optical-processors"] = 250, -- 3500
	["promethium-science-pack"] = 145, -- 2000
	["uev-energy-hatches"] = 225, -- 3000
	["uev-machines"] = 180, -- 2500
	["uev-multiblocks"] = 225, -- 3000
	["uev-naquadah-reactor"] = 225, -- 3000
	["uev-plasma-turbine"] = 180, -- 2500
	["uiv-components"] = 325, -- 4500
	["uiv-materials"] = 225, -- 3000
	-- UIV (promethium pack): /25.3
	["exotic-processor-mainframes"] = 120, -- 3000
	["dimensionally-transcendent-plasma-forge"] = 120, -- phase 6a (139); UIV since issue #355 (GTNH's place)
	["exotic-processors"] = 100, -- 2500
	["fusion-coil-ii"] = 100, -- 2500
	["fusion-plasmas-mk5"] = 120, -- 3000
	["fusion-reactor-mk5"] = 120, -- 3000
	["uiv-energy-hatches"] = 140, -- 3500
	["uiv-machines"] = 120, -- 3000
	["uiv-multiblocks"] = 140, -- 3500
	["uiv-naquadah-reactor"] = 120, -- 3000
	["uiv-plasma-turbine"] = 100, -- 2500
	["umv-components"] = 120, -- 3000
	["umv-materials"] = 100, -- 2500
	["umv-science-pack"] = 90, -- 2300
	-- UMV: /32.2
	["quantum-force-transformer"] = 95, -- new in phase 6a
	["godforge"] = 95, -- phase 6b (140); between the UIV and UMV energy hatches since issue #355 (GTNH's place)
	["godforge-plasma-module"] = 95, -- issue #355: GT's plasma module upgrades for celestial tungsten plasma
	["temporal-processor-mainframes"] = 95, -- 3000
	["temporal-processors"] = 95, -- 3000
	["umv-energy-hatches"] = 95, -- 3000
	["umv-machines"] = 80, -- 2500
	["umv-multiblocks"] = 95, -- 3000
	["umv-naquadah-reactor"] = 95, -- 3000
	["umv-plasma-turbine"] = 80, -- 2500
	["uxv-components"] = 110, -- 3500
	["uxv-materials"] = 80, -- 2500
	["uxv-science-pack"] = 80, -- 2600
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
	["kevlar"] = 325, -- UV, 1500 (164)
	["prismatic-naquadah"] = 325, -- UV, 1500 (164)
	["thorium-based-liquid-fuel"] = 180, -- UHV, 2500 (164)
	["precise-electronic-unit-mk3"] = 180, -- UHV, 2500 (164)
	["naquadah-fuel-refinery"] = 110, -- UHV, 1500 (164)
	["beamline"] = 110, -- UHV, 1500 (164)
	["radox-polymer"] = 110, -- UEV, 1500 (164)
	["six-phased-copper"] = 50, -- UXV, 60 (164), as 138's UXV technologies
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
