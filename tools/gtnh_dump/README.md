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

## Second source: the full-pack NEI dump (issue #714)

The dump above has only what GT5-Unofficial's dev environment loads. The full pack's recipes (NewHorizonsCoreMod's
machine recipes, every crafting table and furnace recipe of the pack, the other mods) come from **Learwin's NEI fork**:
branch `data-export` of https://github.com/Learwin/NotEnoughItems (LGPL-3.0, commit `d987255`, GTNH's
NotEnoughItems 2.8.170 with the client commands `/recipeid dump` and `/texturedump`). Thanks to Learwin for the fork
and for sharing it on the Gregtorio Discord. Nothing of the fork is committed here.

`nei_to_dump.py` turns that dump into this folder's format and merges it with `gtnh-recipes.json.gz` into
`gtnh-merged.json.gz`, which `devcheck.py gtnh-diff` reads when it exists (`--dump` picks either file).

### Building the jar (Windows)

```
git clone -b data-export https://github.com/Learwin/NotEnoughItems.git
cd NotEnoughItems
gradlew.bat build -x test -x spotlessCheck
```

with `JAVA_HOME` on the JDK 25 (the buildscript runs Gradle on 25, `gradle/gradle-daemon-jvm.properties`; it compiles
with Jabel for Java 8 and finds the JDK 17 toolchain of the Zulu install above). About two minutes. The jar is
`build/libs/NotEnoughItems-d987255.jar` (not the `-dev`, `-dev-preshadow` or `-sources` jars).

### Making the dump (needs a Minecraft account)

1. GT New Horizons **daily 2026-10-28+804** (GT5-Unofficial 5.09.54.252, NewHorizonsCoreMod 2.9.98,
   NotEnoughItems 2.8.169-GTNH, GTNHLib 0.11.54: the build closest to the fork's NotEnoughItems 2.8.170 and to the
   GT version above). The Prism Launcher / MultiMC instance `GTNH-daily-2026-10-28+804-mmcprism-java17-26.zip` is an
   artifact of DreamAssemblerXXL's run https://github.com/GTNewHorizons/DreamAssemblerXXL/actions/runs/40667352330
   (download while signed in to GitHub; it expires 2027-01-26). Older beta or stable packs have an older GTNHLib the
   fork's NEI may not load with.
2. Prism Launcher (`winget install PrismLauncher.PrismLauncher`): add the Microsoft account, Add Instance -> Import ->
   the zip. Instance settings -> Java: the Zulu 21 or 25, maximum memory 8192 MB.
3. In the instance's `.minecraft/mods/` delete `NotEnoughItems-2.8.169-GTNH.jar` and copy the fork's jar there.
4. If the instance has a `.minecraft/recipeid/` folder from an earlier dump, delete it: the dump appends to its files.
5. Start the game, create a single player world (creative, flat is enough) and wait until it is loaded. In the chat:
   `/recipeid dump`. The chat says `Start processing recipe handlers!` and, when done, `Finished processing recipe
   handlers!`; the fork's comment says about an hour, the log prints `(<n>/<total>). Processing ...` every 1000 items.
   Leave the game running until then (`fast-dump` writes the old format without the handler fields: not usable).
6. Quit the game. Zip the folder `.minecraft/recipeid/` (with `handlerformat/`, the `*_recipes.json` files and
   `recipeId.json`; a few GB of JSON, much smaller zipped) and `.minecraft/logs/latest.log` (its `MAPPEDEXPORT` lines
   name the field types the fork could not write).
7. `python tools/gtnh_dump/nei_to_dump.py <the zip> --pack "GTNH daily 2026-10-28+804"` writes
   `gtnh-merged.json.gz` and its report `.devcheck/nei-to-dump.md`; then `python tools/devcheck/devcheck.py gtnh-diff`.

### The NEI format

One JSON object per line, one file `<handler class>_recipes.json` per NEI handler class (every GT recipe map is the
one class `GTNEIDefaultHandler`); `handlerformat/<handler class>.json` lists the fields of the handler's cached recipe
class (`{"format": [{"field": "mRecipe", "type": "gregtech.api.util.GTRecipe"}, ...]}`). Each line has `handler` (the
class name) and the values of those fields: items as `{strId, Damage, Count, Name, tag}`, fluids as `{FluidName,
Amount}` (or a fluid display item `{neiFluidName, Count}`), a `GTRecipe` as `{recipeType, mInputs, mOutputs,
mFluidInputs, mFluidOutputs, chances, mDuration, mEUt}` (`recipeType`: GT's recipe category, the map's name for its
default category), a field type the fork cannot write as `null`. Handlers without such a format file go into
`recipeId.json` as NEI's recipe ids (`{handlerName, ingredients, result}`). The dump looks recipes up per item, so a
recipe is in its file once per product: the converter removes the copies.

What the converter maps, and what it cannot:

- **GT handlers** (every line with a `GTRecipe`): the map from `recipeType` (GT's categories through the categories
  of `gtnh-recipes.json.gz`), EU/t, ticks, chances, items with count 0 as not consumed, the programmed circuit. GT's
  special value (the blast furnace's coil heat, the fusion reactor's start energy), the special slot item and the map
  metadata are not in the dump: a recipe the GT5-Unofficial dump also has keeps that dump's line (source `both`).
- **Crafting table and furnace** (NEI's `ShapedRecipeHandler`, `ShapelessRecipeHandler`, `FurnaceRecipeHandler`):
  ingredients and result, but no shape and no ore dictionary names: an ingredient is the first item of its
  alternatives. A recipe counts as the GT5-Unofficial dump's when that dump has one with the same product whose
  ingredients match (the same item, an item of its ore dictionary name, or of its list). Recipes whose product comes
  from a mod outside the GT5-Unofficial dump's mod list and the core mod (`dreamcraft`) are only counted.
- **Everything else** (Thaumcraft, Botania, Forestry, Avaritia's table, NEI's fuel and information pages, ...): only
  counted per handler in the report, as are lines of kept handlers in an unknown shape.

### The merged dump (`gtnh-merged.json.gz`)

Format 1 as above, plus `"sources": {"gt5u": {...}, "nei": {...}}` (the versions, the handlers and their counts) and a
`"source"` on every recipe, crafting and furnace entry: `gt5u` (only the GT5-Unofficial dump), `nei` (only the NEI
dump), `both`. NEI's items the GT5-Unofficial dump does not know get an `items` entry with their English name only.
`gtnh-diff` counts its statuses per source. The size limit is the repository's: the converter stops above 45 MB.

`python tools/gtnh_dump/nei_to_dump.py --selftest` runs the converter on `nei_fixture/` (a few NEI lines of every
kind, written after the fork's code, and a small GT5-Unofficial dump of real recipes) and checks the counts and that
`tools/gtnh_map.py` reads the result.
