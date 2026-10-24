--- Issue #560: the ore machines are furnaces. The JSON migration of the same name made the machines of the old save hidden
--- `legacy-<name>` assembling machines; scripts/fork-ore-furnaces.lua builds the furnace in each one's place with its
--- contents. The game runs this once per save, after the JSON migration (file names sort .json before .lua).
remote.call("fork-ore-furnaces", "migrate")
