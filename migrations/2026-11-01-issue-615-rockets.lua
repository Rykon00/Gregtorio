--- Issue #615: the Reach technologies from the Moon on are craft-item triggers of their tier's rocket now, and the new
--- technologies Tier 1 to Tier 5 Rocketry (prototypes/174-fork-rockets.lua) took their units and prerequisites. A save
--- keeps its researched Reach technologies; the Rocketry technology of each of them is researched too, so the rocket
--- parts of that tier are unlocked as in a new game. The game runs this once per save.
local data = prototypes.mod_data["fork-rockets"]
local reach = data and data.data.reach or {}
for _, force in pairs(game.forces) do
	for r, rocketry in pairs(reach) do
		local t, rt = force.technologies[r], force.technologies[rocketry]
		if t and rt and t.researched and not rt.researched then
			rt.researched = true
			log("FORK-ROCKETS: " .. force.name .. ": " .. rocketry .. " researched (" .. r .. " was)")
		end
	end
end
