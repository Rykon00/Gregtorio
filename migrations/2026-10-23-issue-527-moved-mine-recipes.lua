--- Issue #527 (follow-up of plan #494): an old Manual Mine whose recipe moved to the Dig Site or needs another surface
--- runs a placeholder now (2026-10-23-issue-527-moved-mine-recipes.json); scripts/fork-ore-veins.lua gives it the
--- recipe back on its planet or clears it with a message.
remote.call("fork-ore-veins", "migrate")
