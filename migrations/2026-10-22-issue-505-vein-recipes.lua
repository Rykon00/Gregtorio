--- Issue #505 (plan #494, V9): the vein recipes of Nauvis, the Nether and the Twilight Forest left the map-vein mode; the
--- dimension mines that ran one become mining drills or lose the recipe (scripts/fork-ore-veins.lua). Issue #563: the
--- JSON migration that mapped them onto placeholders is gone (the engine applied it in classic mode too); the recipes stay
--- prototypes of 166, and the script decides by the ore mode. For saves that had #500's migration already; for older ones
--- it ran it.
remote.call("fork-ore-veins", "migrate")
