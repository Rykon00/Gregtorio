# GT New Horizons recipe dump (issue #679)

`gtnh-recipes.json.gz` holds every recipe of every GregTech `RecipeMap` as GT New Horizons registers it, plus the
crafting table and furnace recipes, made from GT5-Unofficial's own dev environment with the small dev mod in
`src/gtnhdump/GTNHRecipeDump.java`. `python tools/devcheck/devcheck.py gtnh-diff` compares Gregtorio's recipes with
it through `tools/gtnh_map.py` (a report in `.devcheck/gtnh-diff.md`, not part of `devcheck.py all`).

The dump in this folder: GT5-Unofficial `5.09.54.244-3-gec1f1d2` (commit `ec1f1d2669d8fc32e51157f634be7e8499417ef6`,
2026-10-24) with NewHorizonsCoreMod 2.9.97 (the newest core mod built against a GT version up to that commit; it adds
GTNH's own recipes: circuit assembler, more assembler, blast furnace and assembly line recipes); 109,185 recipes in
168 maps, 40,798 crafting table and 5,883 furnace recipes, 2.5 MB (47 MB of JSON). It is committed because it is
small and `gtnh-diff` needs all of it; the GT dev environment is not needed to run the comparison.

The dev environment loads what GT5-Unofficial's `dependencies.gradle` names (GT, GT++, bartworks, GoodGenerator,
kekztech, gtnhlanth, kubatech, TecTech, gtnhintergalactic, IC2, AE2, Avaritia, Draconic Evolution, EnderIO, Tinkers'
Construct, ...). Recipes GT or the core mod only add when another mod is loaded (Railcraft, Forestry, Thaumcraft,
Galacticraft, ...) are not in it.

## Making a new dump (Windows)

1. JDKs: GTNH's buildscript runs Gradle on **JDK 25** (`gradle/gradle-daemon-jvm.properties`) and Minecraft 1.7.10 on
   **JDK 8**; GTNH's CI also installs 17 and 21. Azul Zulu, as GTNH's CI uses:

   ```
   winget install --id Azul.Zulu.25.JDK
   winget install --id Azul.Zulu.21.JDK
   winget install --id Azul.Zulu.17.JDK
   winget install --id Azul.Zulu.8.JDK
   ```

   Then set `JAVA_HOME` to the JDK 25 (`[Environment]::SetEnvironmentVariable('JAVA_HOME',
   'C:\Program Files\Zulu\zulu-25', 'User')` is enough for `gradlew`) and open a new terminal.

2. A separate clone of GT5-Unofficial at the commit to dump (never a checkout you work in; the patch is local and is
   never pushed):

   ```
   git init GT5-Unofficial-dump
   cd GT5-Unofficial-dump
   git remote add origin https://github.com/GTNewHorizons/GT5-Unofficial.git
   git fetch --depth 4 origin <commit>
   git fetch --depth 1 origin tag <the GT version tag before it> --no-tags
   git checkout <commit>
   ```

   (The tag lets `git describe` and the buildscript find the version.)

3. Copy `src/gtnhdump/` of this folder to `src/main/java/gtnhdump/` of the clone and apply `dependencies.patch`
   (`git apply <Gregtorio>/tools/gtnh_dump/dependencies.patch`; if it does not apply to a newer GT, add its three
   `runtimeOnlyNonPublishable` lines to `dependencies.gradle` by hand). Pick the NewHorizonsCoreMod version whose own
   `dependencies.gradle` names a GT5-Unofficial version up to the one dumped: a newer core mod refers to GT items the
   dumped GT lacks and GT stops loading (2.9.98 needs GT 5.09.54.246: `NoSuchFieldError:
   Supermassive_Black_Hole_Opener`).

4. Accept Minecraft's EULA for the dev server (`run/server/eula.txt` with `eula=true`), then run

   ```
   gradlew.bat --console=plain runServer
   ```

   The first run downloads Minecraft, Forge, the mappings and every dependency (a few minutes); later runs take two.
   The dev mod writes `run/server/gtnh-recipes.json.gz` while the server starts (FMLServerStartingEvent, after
   post-init, load-complete and GT's server-start unification; `after:*` puts it last) and stops the server; the log
   line `[gtnhdump] wrote ... (<bytes>)` says where. `-Dgtnhdump.out=<file>` writes elsewhere,
   `-Dgtnhdump.keepRunning=true` keeps the server up. A world from a run with another mod set stops the next start at
   `/fml confirm`: delete `run/server/world`.

5. Copy the file over `tools/gtnh_dump/gtnh-recipes.json.gz`, update the version lines above and run
   `python tools/devcheck/devcheck.py gtnh-diff`.

## Format (format 1)

```
{
  "format": 1, "gt_version": "...", "git_commit": "...", "git_describe": "...", "created": "...",
  "mods": {"<mod id>": "<version>", ...},                          the mods the dev environment loaded
  "recipe_maps": {"<unlocalized map name>": {
      "amperage": 1, "backend": "<class>", "ui": {"maxItemInputs": 6, ...}, "count": N,
      "recipes": [{
        "eut": 30, "duration": 200,                                EU/t, ticks
        "special": 1500,                                           GT's special value when not 0
        "category": "gt.recipe.category.macerator_recycling",     GT's recipe category
        "in":  [{"id": "<registry name>:<meta>", "n": 1, "nc": true, "circuit": 3, "ore": "<ore name>",
                 "chance": 5000, "nbt": "..."}],                   nc: not consumed (count 0)
        "out": [{"id": "...", "n": 2, "chance": 2500}],            chance in 1/10000, left out at 10000
        "fin": [{"fluid": "<fluid name>", "l": 144}], "fout": [...], "fin_alt": [[...], ...],
        "special_items": ..., "meta": {"coil_heat": 1800, ...}, "nei_desc": [...],
        "hidden": true, "fake": true, "disabled": true}]}},
  "assembly_line_research": [{"output": {...}, "research_item": {...}, "research_time": 0, "research_voltage": 0}],
  "crafting": [{"class": "...", "out": {...}, "width": 3, "height": 3, "shapeless": true,
                "in": [null | {"id": ..., "n": ...} | {"ore": "plateIron"} | {"any": [...]}]}],
  "furnace": [{"in": {...}, "out": {...}}],
  "items": {"<registry name>:<meta>": {"unlocalized": "...", "name": "<English name>", "ore": ["dustIron"],
            "prefix": "dust", "material": "Iron", "material_amount": 3628800}}
}
```

`prefix` and `material` are GT's unification (`GTOreDictUnificator.getAssociation`); fluids are GT fluid names
(`molten.copper`, `sulfuricacid`). Metadata values that are objects are written as their public fields of simple
types, a GT material as its name.
