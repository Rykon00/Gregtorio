--- Issue #563: the startup setting gregtorio-continued-ore-mode chooses the map veins or the classic vein recipes. This
--- notes the mode in the save and migrates it (scripts/fork-ore-veins.lua): in map-vein mode as the migrations of plan
--- #494 do, in classic mode the surfaces lose the veins in their map settings and old mines get the generated vein
--- recipes. The game runs this once per save, also when the version did not change; a later switch of the setting is
--- seen by on_configuration_changed.
remote.call("fork-ore-veins", "migrate")
