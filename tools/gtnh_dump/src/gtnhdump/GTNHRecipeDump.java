package gtnhdump;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.zip.GZIPOutputStream;

import net.minecraft.item.Item;
import net.minecraft.item.ItemStack;
import net.minecraft.item.crafting.CraftingManager;
import net.minecraft.item.crafting.FurnaceRecipes;
import net.minecraft.item.crafting.IRecipe;
import net.minecraft.item.crafting.ShapedRecipes;
import net.minecraft.item.crafting.ShapelessRecipes;
import net.minecraft.server.MinecraftServer;
import net.minecraftforge.fluids.FluidStack;
import net.minecraftforge.oredict.OreDictionary;
import net.minecraftforge.oredict.ShapedOreRecipe;
import net.minecraftforge.oredict.ShapelessOreRecipe;

import com.google.gson.stream.JsonWriter;

import cpw.mods.fml.common.Loader;
import cpw.mods.fml.common.Mod;
import cpw.mods.fml.common.ModContainer;
import cpw.mods.fml.common.event.FMLServerStartingEvent;
import gregtech.GT_Version;
import gregtech.api.enums.Materials;
import gregtech.api.objects.ItemData;
import gregtech.api.recipe.RecipeMap;
import gregtech.api.recipe.RecipeMetadataKey;
import gregtech.api.recipe.metadata.IRecipeMetadataStorage;
import gregtech.api.util.GTOreDictUnificator;
import gregtech.api.util.GTRecipe;
import gregtech.api.util.GTUtility;

/**
 * Dev-only mod: while the dedicated server starts (after post-init, load-complete and GT's server-start
 * unification; "after:*" puts this handler last), writes every GT RecipeMap, the assembly line research data, the crafting table recipes and the
 * furnace recipes to one gzipped JSON file, then stops the server.
 * <p>
 * Output: system property gtnhdump.out, default gtnh-recipes.json.gz in the server's working directory.
 * Not part of GT5-Unofficial; kept in Gregtorio under tools/gtnh_dump/.
 */
@Mod(modid = "gtnhdump", name = "GTNH recipe dump", version = "1", dependencies = "after:*", acceptableRemoteVersions = "*")
public class GTNHRecipeDump {

    private static final int FORMAT = 1;

    /** Items referenced anywhere, keyed "registry:meta", described once in the "items" table. */
    private final Map<String, ItemStack> items = new TreeMap<>();
    /** OreDictionary.getOres lists by identity, to name the ore entry a crafting slot accepts. */
    private final Map<Object, String> oreLists = new IdentityHashMap<>();

    @Mod.EventHandler
    public void onServerStarting(FMLServerStartingEvent event) {
        String out = System.getProperty("gtnhdump.out", "gtnh-recipes.json.gz");
        long start = System.currentTimeMillis();
        try {
            for (String name : OreDictionary.getOreNames()) oreLists.put(OreDictionary.getOres(name), name);
            File file = new File(out).getAbsoluteFile();
            try (JsonWriter w = new JsonWriter(
                new OutputStreamWriter(new GZIPOutputStream(new FileOutputStream(file), 1 << 16), StandardCharsets.UTF_8))) {
                w.beginObject();
                writeHeader(w);
                writeRecipeMaps(w);
                writeAssemblyLineResearch(w);
                writeCrafting(w);
                writeFurnace(w);
                writeItems(w);
                w.endObject();
            }
            System.out.println(
                "[gtnhdump] wrote " + file + " (" + file.length() + " bytes) in "
                    + (System.currentTimeMillis() - start) + " ms");
        } catch (Throwable t) {
            System.out.println("[gtnhdump] FAILED");
            t.printStackTrace(System.out);
        }
        if (!Boolean.getBoolean("gtnhdump.keepRunning")) MinecraftServer.getServer().initiateShutdown();
    }

    // ---------------------------------------------------------------- header

    private void writeHeader(JsonWriter w) throws Exception {
        w.name("format").value(FORMAT);
        w.name("gt_version").value(GT_Version.VERSION);
        w.name("git_commit").value(git("rev-parse", "HEAD"));
        w.name("git_describe").value(git("describe", "--tags"));
        w.name("created").value(new java.util.Date().toString());
        w.name("mods").beginObject();
        for (ModContainer mod : Loader.instance().getActiveModList()) w.name(mod.getModId()).value(mod.getVersion());
        w.endObject();
    }

    private static String git(String... args) {
        File dir = new File(System.getProperty("gtnhdump.gitDir", ".")).getAbsoluteFile();
        while (dir != null && !new File(dir, ".git").exists()) dir = dir.getParentFile();
        if (dir == null) return null;
        try {
            List<String> cmd = new ArrayList<>();
            cmd.add("git");
            for (String a : args) cmd.add(a);
            Process p = new ProcessBuilder(cmd).directory(dir).redirectErrorStream(true).start();
            try (BufferedReader r = new BufferedReader(new InputStreamReader(p.getInputStream(), StandardCharsets.UTF_8))) {
                String line = r.readLine();
                p.waitFor();
                return p.exitValue() == 0 ? line : null;
            }
        } catch (Exception e) {
            return null;
        }
    }

    // ---------------------------------------------------------------- recipe maps

    private void writeRecipeMaps(JsonWriter w) throws Exception {
        w.name("recipe_maps").beginObject();
        for (Map.Entry<String, RecipeMap<?>> e : new TreeMap<>(RecipeMap.ALL_RECIPE_MAPS).entrySet()) {
            RecipeMap<?> map = e.getValue();
            w.name(e.getKey()).beginObject();
            w.name("amperage").value(map.getAmperage());
            w.name("backend").value(map.getBackend().getClass().getName());
            writeUiProperties(w, map);
            Collection<GTRecipe> recipes = map.getAllRecipes();
            w.name("count").value(recipes.size());
            w.name("recipes").beginArray();
            for (GTRecipe r : recipes) writeRecipe(w, r);
            w.endArray();
            w.endObject();
        }
        w.endObject();
    }

    private void writeUiProperties(JsonWriter w, RecipeMap<?> map) throws Exception {
        Object ui = readField(map.getFrontend(), "uiProperties");
        if (ui == null) return;
        w.name("ui").beginObject();
        for (Field f : ui.getClass().getFields()) {
            if (Modifier.isStatic(f.getModifiers())) continue;
            Class<?> t = f.getType();
            if (t == int.class) w.name(f.getName()).value(f.getInt(ui));
            else if (t == boolean.class) w.name(f.getName()).value(f.getBoolean(ui));
        }
        w.endObject();
    }

    private void writeRecipe(JsonWriter w, GTRecipe r) throws Exception {
        w.beginObject();
        w.name("eut").value(r.mEUt);
        w.name("duration").value(r.mDuration);
        if (r.mSpecialValue != 0) w.name("special").value(r.mSpecialValue);
        if (!r.mEnabled) w.name("disabled").value(true);
        if (r.mHidden) w.name("hidden").value(true);
        if (r.mFakeRecipe) w.name("fake").value(true);
        if (r.mNeedsEmptyOutput) w.name("needs_empty_output").value(true);
        if (r.isNBTSensitive) w.name("nbt_sensitive").value(true);
        if (r.getRecipeCategory() != null) w.name("category").value(r.getRecipeCategory().unlocalizedName);

        int[] oreIds = r instanceof GTRecipe.GTRecipe_WithAlt ? ((GTRecipe.GTRecipe_WithAlt) r).mOreDictIds : null;
        w.name("in").beginArray();
        for (int i = 0; i < r.mInputs.length; i++) {
            ItemStack s = r.mInputs[i];
            if (s == null) continue;
            w.beginObject();
            writeStackRef(w, s);
            if (s.stackSize == 0) w.name("nc").value(true);
            if (GTUtility.isAnyIntegratedCircuit(s)) w.name("circuit").value(s.getItemDamage());
            if (oreIds != null && i < oreIds.length && oreIds[i] >= 0) {
                w.name("ore").value(OreDictionary.getOreName(oreIds[i]));
            }
            if (r.mInputChances != null && i < r.mInputChances.length && r.mInputChances[i] != 10000) {
                w.name("chance").value(r.mInputChances[i]);
            }
            w.endObject();
        }
        w.endArray();

        w.name("out").beginArray();
        for (int i = 0; i < r.mOutputs.length; i++) {
            ItemStack s = r.mOutputs[i];
            if (s == null) continue;
            w.beginObject();
            writeStackRef(w, s);
            if (r.mOutputChances != null && i < r.mOutputChances.length && r.mOutputChances[i] != 10000) {
                w.name("chance").value(r.mOutputChances[i]);
            }
            w.endObject();
        }
        w.endArray();

        writeFluids(w, "fin", r.mFluidInputs, r.mFluidInputChances);
        writeFluids(w, "fout", r.mFluidOutputs, r.mFluidOutputChances);
        if (r.mAltFluidInputs != null) {
            w.name("fin_alt").beginArray();
            for (FluidStack[] alts : r.mAltFluidInputs) {
                w.beginArray();
                if (alts != null) for (FluidStack f : alts) if (f != null) writeFluid(w, f, 10000);
                w.endArray();
            }
            w.endArray();
        }
        if (r.mSpecialItems != null) {
            w.name("special_items");
            writeValue(w, r.mSpecialItems, 0);
        }
        writeMetadata(w, r.getMetadataStorage());
        String[] desc = r.getNeiDesc();
        if (desc != null && desc.length > 0) {
            w.name("nei_desc").beginArray();
            for (String d : desc) w.value(d);
            w.endArray();
        }
        if (r.owners != null && !r.owners.isEmpty()) {
            w.name("owners").beginArray();
            for (ModContainer m : r.owners) w.value(m.getModId());
            w.endArray();
        }
        w.endObject();
    }

    private void writeFluids(JsonWriter w, String key, FluidStack[] fluids, int[] chances) throws Exception {
        w.name(key).beginArray();
        if (fluids != null) for (int i = 0; i < fluids.length; i++) {
            if (fluids[i] == null || fluids[i].getFluid() == null) continue;
            writeFluid(w, fluids[i], chances != null && i < chances.length ? chances[i] : 10000);
        }
        w.endArray();
    }

    private static void writeFluid(JsonWriter w, FluidStack f, int chance) throws Exception {
        w.beginObject();
        w.name("fluid").value(f.getFluid().getName());
        w.name("l").value(f.amount);
        if (chance != 10000) w.name("chance").value(chance);
        w.endObject();
    }

    private void writeMetadata(JsonWriter w, IRecipeMetadataStorage storage) throws Exception {
        if (storage == null) return;
        Field idField = RecipeMetadataKey.class.getDeclaredField("identifier");
        idField.setAccessible(true);
        boolean open = false;
        for (Map.Entry<RecipeMetadataKey<?>, Object> e : storage.getEntries()) {
            if (!open) {
                w.name("meta").beginObject();
                open = true;
            }
            w.name((String) idField.get(e.getKey()));
            writeValue(w, e.getValue(), 0);
        }
        if (open) w.endObject();
    }

    // ---------------------------------------------------------------- assembly line research

    private void writeAssemblyLineResearch(JsonWriter w) throws Exception {
        w.name("assembly_line_research").beginArray();
        for (GTRecipe.RecipeAssemblyLine r : GTRecipe.RecipeAssemblyLine.sAssemblylineRecipes) {
            w.beginObject();
            if (r.mOutput != null) {
                w.name("output");
                writeStack(w, r.mOutput);
            }
            if (r.mResearchItem != null) {
                w.name("research_item");
                writeStack(w, r.mResearchItem);
            }
            w.name("research_time").value(r.mResearchTime);
            w.name("research_voltage").value(r.mResearchVoltage);
            w.endObject();
        }
        w.endArray();
    }

    // ---------------------------------------------------------------- crafting and furnace

    private void writeCrafting(JsonWriter w) throws Exception {
        w.name("crafting").beginArray();
        for (Object o : CraftingManager.getInstance().getRecipeList()) {
            IRecipe r = (IRecipe) o;
            ItemStack output = r.getRecipeOutput();
            if (output == null) continue;
            w.beginObject();
            w.name("class").value(r.getClass().getName());
            w.name("out");
            writeStack(w, output);
            if (r instanceof ShapedOreRecipe) {
                w.name("width").value((Integer) readField(r, "width"));
                w.name("height").value((Integer) readField(r, "height"));
                writeSlots(w, ((ShapedOreRecipe) r).getInput());
            } else if (r instanceof ShapelessOreRecipe) {
                w.name("shapeless").value(true);
                writeSlots(w, ((ShapelessOreRecipe) r).getInput().toArray());
            } else if (r instanceof ShapedRecipes) {
                ShapedRecipes s = (ShapedRecipes) r;
                w.name("width").value(s.recipeWidth);
                w.name("height").value(s.recipeHeight);
                writeSlots(w, s.recipeItems);
            } else if (r instanceof ShapelessRecipes) {
                w.name("shapeless").value(true);
                writeSlots(w, ((ShapelessRecipes) r).recipeItems.toArray());
            }
            w.endObject();
        }
        w.endArray();
    }

    /** One entry per slot: null, a stack, or {"ore": name} for an ore dictionary list. */
    private void writeSlots(JsonWriter w, Object[] slots) throws Exception {
        w.name("in").beginArray();
        for (Object slot : slots) {
            if (slot == null) w.nullValue();
            else if (slot instanceof ItemStack) writeStack(w, (ItemStack) slot);
            else if (slot instanceof List) {
                String ore = oreLists.get(slot);
                w.beginObject();
                if (ore != null) w.name("ore").value(ore);
                else {
                    w.name("any").beginArray();
                    for (Object s : (List<?>) slot) if (s instanceof ItemStack) writeStack(w, (ItemStack) s);
                    w.endArray();
                }
                w.endObject();
            } else w.value(String.valueOf(slot));
        }
        w.endArray();
    }

    private void writeFurnace(JsonWriter w) throws Exception {
        w.name("furnace").beginArray();
        for (Object o : FurnaceRecipes.smelting().getSmeltingList().entrySet()) {
            Map.Entry<?, ?> e = (Map.Entry<?, ?>) o;
            w.beginObject();
            w.name("in");
            writeStack(w, (ItemStack) e.getKey());
            w.name("out");
            writeStack(w, (ItemStack) e.getValue());
            w.endObject();
        }
        w.endArray();
    }

    // ---------------------------------------------------------------- items

    private static String itemKey(ItemStack s) {
        Object name = Item.itemRegistry.getNameForObject(s.getItem());
        return (name == null ? s.getItem().getClass().getName() : name.toString()) + ":" + s.getItemDamage();
    }

    /** Inline {"id", "n"[, "nbt"]} and remember the item for the "items" table. */
    private void writeStackRef(JsonWriter w, ItemStack s) throws Exception {
        String key = itemKey(s);
        if (!items.containsKey(key)) items.put(key, s);
        w.name("id").value(key);
        w.name("n").value(s.stackSize);
        if (s.hasTagCompound()) w.name("nbt").value(s.getTagCompound().toString());
    }

    private void writeStack(JsonWriter w, ItemStack s) throws Exception {
        w.beginObject();
        writeStackRef(w, s);
        w.endObject();
    }

    private void writeItems(JsonWriter w) throws Exception {
        w.name("items").beginObject();
        for (Map.Entry<String, ItemStack> e : new ArrayList<>(items.entrySet())) {
            ItemStack s = e.getValue();
            w.name(e.getKey()).beginObject();
            w.name("unlocalized").value(safe(() -> s.getUnlocalizedName()));
            w.name("name").value(safe(() -> s.getDisplayName()));
            if (s.getItemDamage() != OreDictionary.WILDCARD_VALUE) {
                int[] ids = OreDictionary.getOreIDs(s);
                if (ids.length > 0) {
                    w.name("ore").beginArray();
                    for (int id : ids) w.value(OreDictionary.getOreName(id));
                    w.endArray();
                }
                ItemData data = GTOreDictUnificator.getAssociation(s);
                if (data != null) {
                    w.name("prefix").value(data.mPrefix.name());
                    w.name("material").value(data.mMaterial.mMaterial.mName);
                    if (data.mMaterial.mAmount != 0) w.name("material_amount").value(data.mMaterial.mAmount);
                }
            } else w.name("wildcard").value(true);
            w.endObject();
        }
        w.endObject();
    }

    // ---------------------------------------------------------------- generic values

    private interface StringSupplier {

        String get() throws Throwable;
    }

    private static String safe(StringSupplier s) {
        try {
            return s.get();
        } catch (Throwable t) {
            return null;
        }
    }

    private static Object readField(Object o, String name) {
        for (Class<?> c = o.getClass(); c != null; c = c.getSuperclass()) {
            try {
                Field f = c.getDeclaredField(name);
                f.setAccessible(true);
                return f.get(o);
            } catch (NoSuchFieldException ignored) {} catch (IllegalAccessException e) {
                return null;
            }
        }
        return null;
    }

    private void writeValue(JsonWriter w, Object v, int depth) throws Exception {
        if (v == null) w.nullValue();
        else if (v instanceof Boolean) w.value((Boolean) v);
        else if (v instanceof Double && !Double.isFinite((Double) v)) w.value(v.toString());
        else if (v instanceof Float && !Float.isFinite((Float) v)) w.value(v.toString());
        else if (v instanceof Number) w.value((Number) v);
        else if (v instanceof CharSequence) w.value(v.toString());
        else if (v instanceof Enum) w.value(((Enum<?>) v).name());
        else if (v instanceof ItemStack) writeStack(w, (ItemStack) v);
        else if (v instanceof FluidStack) writeFluid(w, (FluidStack) v, 10000);
        else if (v instanceof Materials) w.value(((Materials) v).mName);
        else if (depth > 3) w.value(v.toString());
        else if (v.getClass().isArray()) {
            w.beginArray();
            for (int i = 0; i < Array.getLength(v); i++) writeValue(w, Array.get(v, i), depth + 1);
            w.endArray();
        } else if (v instanceof Collection) {
            w.beginArray();
            for (Object o : (Collection<?>) v) writeValue(w, o, depth + 1);
            w.endArray();
        } else if (v instanceof Map) {
            w.beginObject();
            for (Map.Entry<?, ?> e : ((Map<?, ?>) v).entrySet()) {
                w.name(String.valueOf(e.getKey()));
                writeValue(w, e.getValue(), depth + 1);
            }
            w.endObject();
        } else {
            // Plain data holders (research info, upgrade sets, ...): their public fields of simple types, else
            // toString (a reflective walk of GT's Materials or textures would write gigabytes).
            Map<String, Object> fields = new LinkedHashMap<>();
            for (Field f : v.getClass().getFields()) {
                if (!Modifier.isStatic(f.getModifiers()) && isSimple(f.getType())) fields.put(f.getName(), f.get(v));
            }
            if (fields.isEmpty()) w.value(v.toString());
            else {
                w.beginObject();
                w.name("class").value(v.getClass().getName());
                for (Map.Entry<String, Object> e : fields.entrySet()) {
                    w.name(e.getKey());
                    writeValue(w, e.getValue(), depth + 1);
                }
                w.endObject();
            }
        }
    }

    private static boolean isSimple(Class<?> t) {
        return t.isPrimitive() || Number.class.isAssignableFrom(t)
            || t == Boolean.class
            || t == String.class
            || t.isEnum()
            || t == ItemStack.class
            || t == FluidStack.class
            || t == Materials.class;
    }
}
