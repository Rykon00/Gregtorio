--------------------------------------------------------------------------------
--- FORK GREENHOUSE (issue #165, variant A; follow-up of #153)
--- GT New Horizons has no tiered greenhouse: its plants come from farming and from one multiblock, the Extreme
--- Industrial Greenhouse (kubatech). Upstream had a greenhouse per tier (LV to EV, IV to MAX as upgrade multiblocks of
--- 101). Its tree recipe is Gregtorio's only automated wood and so the only base source of rubber from LV on, so the
--- maintainer chose one machine at the greenhouse's place in the technology tree (Greenhouse, LV) instead of GTNH's
--- IV/ZPM controller recipe:
---   * `lv-greenhouse` (its name kept: saves and the migration find it) is the Extreme Industrial Greenhouse (locale),
---     with its recipe, technology, size, ports and both recipes (growing-trees, growing-wheat) as before;
---   * the MV to EV greenhouses (upstream) are removed here with their items, recipes and unlocks; the IV to MAX ones
---     are no longer made (101's IV_UPGRADE_MACHINES).
--- Old saves: migrations/2026-10-06-issue-165-greenhouse.json turns every greenhouse (entity and item) into the
--- Extreme Industrial Greenhouse; its recipes stay valid, it runs at LV speed.
--- Loads after 141 (the last tier) and before 150, 196, 198 and 199.
--------------------------------------------------------------------------------

local TIERS = { "mv", "hv", "ev", "iv", "luv", "zpm", "uv", "uhv", "uev", "uiv", "umv", "uxv", "max" }

local eig = data.raw["assembling-machine"]["lv-greenhouse"]
if eig then eig.next_upgrade = nil end

local gone = {}
for _, t in ipairs(TIERS) do
	local name = t .. "-greenhouse"
	for _, kind in pairs({ "assembling-machine", "item", "recipe" }) do
		if data.raw[kind][name] then
			data.raw[kind][name] = nil
			log("FORK-REMOVED: " .. kind .. " " .. name)
			gone[name] = true
		end
	end
end
for _, tech in pairs(data.raw.technology) do
	if tech.effects then
		local keep = {}
		for _, e in pairs(tech.effects) do
			if not (e.type == "unlock-recipe" and gone[e.recipe]) then keep[#keep + 1] = e end
		end
		tech.effects = keep
	end
end
for _, r in pairs(data.raw.recipe) do
	for _, key in pairs({ "ingredients", "results" }) do
		for _, i in pairs(r[key] or {}) do
			if gone[i.name] then log("FORK-GREENHOUSE: " .. r.name .. " still names " .. i.name) end
		end
	end
end
