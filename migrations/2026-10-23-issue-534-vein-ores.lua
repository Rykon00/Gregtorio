--- Issue #534: a save whose map settings named the veins while its chunks had no ore of them (a map settings editor)
--- skipped the ores in #500's migration; scripts/fork-ore-veins.lua now gives every generated chunk without an ore of the
--- veins its ores. The game runs this once per save, also when the version did not change.
remote.call("fork-ore-veins", "migrate")
