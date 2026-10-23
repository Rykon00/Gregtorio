--- Issue #529: one map generator control per vein; an existing save gets them (and an old size slider of gt-ore-veins
--- on every vein) through scripts/fork-ore-veins.lua. The game runs this once per save, also when the version did not
--- change.
remote.call("fork-ore-veins", "migrate")
