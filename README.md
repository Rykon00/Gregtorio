# Gregtorio (Fork)

Fork von [Gregtorio](https://mods.factorio.com/mod/Gregtorio) von **Damien Reave**: eine GregTech-artige Total-Overhaul-Mod für Factorio 2.0.

Das Upstream-Repository ([Damien-Reave/Gregtorio](https://github.com/Damien-Reave/Gregtorio)) enthält nur die LICENSE, der Code wurde nur als Zip veröffentlicht. Dieser Fork startet deshalb mit dem unveränderten Stand **0.1.9** aus dem Mod-Portal (Tag `v0.1.9-upstream`). Alle Änderungen danach laufen über normale Git-Commits.

## Aufbau

Das Repo-Root ist der Mod-Inhalt (`info.json`, `data.lua`, `prototypes/`, `graphics/`, `locale/`).

| Pfad | Inhalt |
|---|---|
| `prototypes/NN-*.lua` | Items, Rezepte und Maschinen pro Tier (09 Steam … 31 UIV), `98-technology.lua` für den Tech-Tree |
| `graphics/` | Icons und Entity-Sprites (meist Texturen aus GregTech 5) |
| `prototypes/100-fork-fixes.lua` | fehlende Freischaltungen und Rezepte, Henne-Ei-Fixes |
| `prototypes/101-fork-machines.lua` | Tier-Kategorien, EV-/IV-Maschinen und -Multiblocks, `fork_make_tier_machine` |
| `prototypes/110-fork-luv.lua` | LuV: Materialien, Assembly Line, LuV-Maschinen, Science Pack, Techs |
| `prototypes/199-fork-finalize.lua` | Draft-Guard (blendet kaputte Entwurfsrezepte aus) und Auto-Unlock von Vorprodukten |
| `locale/en/fork.cfg` | automatisch erzeugte Namen für Einträge ohne Übersetzung |
| `tools/build.py` | baut `dist/Gregtorio_<version>.zip` und installiert es optional |
| `tools/check_syntax.py` | Lua-Syntax-Check (`--loaded` = nur Dateien, die `data.lua` wirklich lädt) |
| `tools/gen_sprites.py` | Maschinen-Sprites/Icons aus GT5-Unofficial-Texturen (`--gt <Pfad zum Checkout>`) |
| `tools/gen_icons.py` | Platzhalter-Icons (umgefärbte Nachbar-Icons) für Items ohne Icon |
| `tools/gen_locale.py` | ergänzt fehlende englische Namen in `locale/en/fork.cfg` |

## Stand

| Tier | Zustand |
|---|---|
| Steam – EV | spielbar (Upstream), Lücken geschlossen |
| IV | spielbar (Fork 0.2.0) |
| LuV | spielbar (Fork 0.2.0); Crystal-Prozessoren, Bacterial Vat, Fusion noch Entwurf |
| ZPM+ | Entwurf; kaputte Rezepte werden beim Laden ausgeblendet (`FORK-DRAFT` im Log) |

## Workflow

```bash
# nach Änderungen: bauen und direkt in den Factorio-Mods-Ordner legen
python tools/build.py --install

# Release
#   1. info.json -> "version" erhöhen
#   2. changelog.txt -> neuen Abschnitt oben einfügen
#   3. committen, taggen, pushen
git tag v0.2.0 && git push --follow-tags
```

Beim Push eines Tags `v*` baut die GitHub Action das Zip und hängt es an ein GitHub-Release. Bei jedem Push und Pull Request laufen der Syntax-Check und der Build.

Wichtig: Der Mod-Name in `info.json` bleibt `Gregtorio`, damit bestehende Spielstände weiterlaufen.

## Lizenz

GPLv3 wie das Original (siehe `LICENSE`). Übernommene Texturen aus [GT5-Unofficial](https://github.com/GTNewHorizons/GT5-Unofficial) stehen unter LGPL-3.0.
