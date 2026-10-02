--- version 1 (the old Gregtorio) owns the "ME" prototypes and its mod-data; version 2 (the new one) does not:
--- the taker defines them (prototype names stay, so the save finds its entities and items)
if tonumber(mods[ "zz-handover-giver" ]:match("^(%d+)")) == 1 then
	require("shared")
	data:extend({ { type = "mod-data", name = "zz-handover-state", data = {} } })
end
