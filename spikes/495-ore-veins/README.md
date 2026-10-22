# Spike #495: GT ore veins as noise autoplace (throwaway)

Not part of the mod. `mod/` is a standalone mod (base + space-age) with GT5-Unofficial f2814df's ore mixes
(`parse_mixes.py OreMixes.java mixes.json`, then the generated `mod/veins.lua`). Load it alone with
`factorio --mod-directory <dir with mod/ as gt-ore-spike and a mod-list.json> --create map.zip`; `on_init`
writes `script-output/spike/` (timings in the log, `result.txt`, the resource dumps that `render.py` draws,
`veins.txt` for `fill.py`). Map previews: `--generate-map-preview out.png --map-preview-planet gt-spike3`.
