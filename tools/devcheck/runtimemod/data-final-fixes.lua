--- Issue #820: the Substation powers a 64x64 area and reaches 64 tiles with its wires (prototypes/100-fork-fixes.lua). The
--- runtime tests stand tens of tiles apart, each scene with a substation and a power source of its own, and measure what that
--- source gives (the battery buffer, the supercapacitors, a turbine that must idle): with the new reach the substations of
--- neighbouring scenes wire up and their supply areas overlap, so every scene is fed by its neighbours' sources and the
--- power tests fail (found before the release of 0.5.12; the change itself had not been run with the suite). The tests are
--- about the machines, not about the pole: here the substation gets the vanilla numbers back, after a check that the mod
--- really sets the new ones (a load error otherwise, which fails the run).
local substation = data.raw["electric-pole"] and data.raw["electric-pole"]["substation"]
if substation then
	if substation.supply_area_distance ~= 32 or substation.maximum_wire_distance ~= 64 then
		error("devcheck runtime: the Substation should power 64x64 and reach 64 tiles (issue #820), it has supply_area_distance "
			.. tostring(substation.supply_area_distance) .. " and maximum_wire_distance " .. tostring(substation.maximum_wire_distance))
	end
	substation.supply_area_distance = 9
	substation.maximum_wire_distance = 18
end
