--- Issue #505 (plan #494, V9): the vein recipes of Nauvis, the Nether and the Twilight Forest are gone; the dimension
--- mines that ran one (now a placeholder of its planet, 2026-10-22-issue-505-vein-recipes.json) become mining drills or
--- lose the recipe (scripts/fork-ore-veins.lua). For saves that had #500's migration already; for older ones it ran it.
remote.call("fork-ore-veins", "migrate")
