--- The main menu simulations as the game shows them after every mod: copied into a mod-data prototype,
--- which control.lua reads, and listed in the log for devcheck.py (save file and length of each). Issue #591: a fourth
--- column for a Gregtorio scene's copy `<name>_copy<n>` (prototypes/fork-menu-simulations.lua): `copy of <name>`, or
--- `differs from <name>: <fields>` / `no scene <name>`.
local list = data.raw["utility-constants"]["default"].main_menu_simulations or {}
local copy = {}
local names = {}
for name, sim in pairs(list) do
  copy[name] = { save = sim.save, length = sim.length, init = sim.init, update = sim.update }
  names[#names + 1] = name
end
table.sort(names)
local lines = { "DEVCHECK-MENUSIMS-BEGIN" }
local function copy_of(name)
  local base = name:match("^(.+)_copy%d+$")
  if not base then return "" end
  local a, b = list[base], list[name]
  if not a then return "no scene " .. base end
  local differ = {}
  for _, key in ipairs({ "save", "length", "init", "update", "checkboard" }) do
    if a[key] ~= b[key] then differ[#differ + 1] = key end
  end
  return #differ == 0 and ("copy of " .. base) or ("differs from " .. base .. ": " .. table.concat(differ, ", "))
end
for _, name in ipairs(names) do
  lines[#lines + 1] = table.concat({ name, list[name].save or "", tostring(list[name].length or 0), copy_of(name) }, "\t")
end
lines[#lines + 1] = "DEVCHECK-MENUSIMS-END"
log("\n" .. table.concat(lines, "\n"))
data:extend({ { type = "mod-data", name = "zz-gregtorio-devcheck-menusim", data = copy } })
