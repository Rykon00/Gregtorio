--- Issue #500 (plan #494, V4): an existing save gets the map veins, its mines on the Overworld's veins become the mining
--- drills (scripts/fork-ore-veins.lua). The game runs this once per save, also when the version did not change.
remote.call("fork-ore-veins", "migrate")
