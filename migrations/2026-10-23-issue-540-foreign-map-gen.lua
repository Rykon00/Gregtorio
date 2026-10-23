--- Issue #540: a map made with Space Age kept every planet's autoplace controls on its Nauvis surface, which since 0.5.7
--- place Gleba's plants and the other planets' tiles in Nauvis' new chunks. scripts/fork-ore-veins.lua gives the surfaces
--- with veins their planet's map settings (migrate) and cleans the chunks generated with the wrong ones (clean_chunks).
--- The game runs this once per save, also when the version did not change.
remote.call("fork-ore-veins", "migrate")
remote.call("fork-ore-veins", "clean_chunks")
