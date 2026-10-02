--- The taker stands for me-network. Its guard against the old giver: version 1 of the giver defines the mod-data
--- "zz-handover-state" (the old Gregtorio defines "fork-me-network"); without a dependency on the taker the old giver
--- loads first, so the mod-data is there when this runs.
if data.raw["mod-data"] and data.raw["mod-data"]["zz-handover-state"] then
	error("zz-handover-taker: this version of zz-handover-giver contains the ME network itself. Update it.")
end
require("shared")
