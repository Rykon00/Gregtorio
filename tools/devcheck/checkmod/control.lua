--- The mod that created each recipe and the mods that changed it (runtime only: the data stage does not know it),
--- for the check that every Gregtorio recipe is unlocked by a researchable technology (issue #91).
--- `--create` runs on_init once.
script.on_init(function()
	local rows = {}
	for name, _ in pairs(prototypes.recipe) do
		local h = prototypes.get_history("recipe", name)
		rows[#rows + 1] = name .. "\t" .. (h and h.created or "") .. "\t" .. table.concat(h and h.changed or {}, ",")
	end
	log("DEVCHECK-OWNERS-BEGIN\n" .. table.concat(rows, "\n") .. "\nDEVCHECK-OWNERS-END")
end)
