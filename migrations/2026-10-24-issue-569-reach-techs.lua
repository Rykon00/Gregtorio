--- Issue #569: since 0.5.6 the reach technologies of the dimensions are prerequisites of older technologies (Reach the
--- Nether of Rubber, #501; Reach the Twilight Forest of Galena and Invar, #502). A save that researched those before keeps
--- them researched without the reach technology, so the vein recipes (classic ore mode, #563) and the veins (map-vein
--- mode) of that dimension stay locked, and a Manual Mine on one stops with "Recipe not researched". The maintainer's
--- decision: every reach technology that a researched technology has as a prerequisite is researched, with its own
--- prerequisites that are not. The game runs this once per save, also when the version did not change.
local REACH = { "reach-the-nether", "reach-the-twilight-forest", "reach-the-end" }

local function research(force, t, done)
	if t.researched then return end
	for _, p in pairs(t.prerequisites) do research(force, p, done) end
	t.researched = true
	done[#done + 1] = t.name
end

for _, force in pairs(game.forces) do
	for _, name in pairs(REACH) do
		local reach = force.technologies[name]
		if reach and not reach.researched then
			for _, t in pairs(force.technologies) do
				if t.researched and t.prerequisites[name] then
					local done = {}
					research(force, reach, done)
					log("FORK-REACH: " .. force.name .. ": " .. table.concat(done, ", ") .. " researched (" .. t.name
						.. " needs " .. name .. ")")
					force.print({ "fork-message.reach-researched", reach.localised_name, t.localised_name })
					break
				end
			end
		end
	end
end
