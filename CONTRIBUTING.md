# Contributing

## Language

**Everything that lands on GitHub is written in English:** code, comments, log messages,
locale entries, commit messages, pull requests, issues, README and other docs.

## Workflow

1. Work on a branch, open a pull request into `main`.
2. Keep upstream files (`prototypes/0*-*.lua` … `98-technology.lua`) as close to the original
   as possible. Fork changes go into the `prototypes/1xx-fork-*.lua` files.
3. For local testing link the repo into Factorio once: `python tools/dev_link.py`.
   After that, Factorio loads the working copy directly; restart Factorio after changes.
   Gregtorio depends on the mod me-network (the ME network, https://github.com/Rykon00/me-network, issue #83):
   link its clone too (`python tools/dev_link.py` there), or install it from the mod portal. ME changes go into that
   repository; here only `prototypes/120-fork-me-network-compat.lua` (the GT recipes and tiers of the ME items).
4. Before committing: `python tools/check_syntax.py --loaded`, and on Linux the headless
   harness `python tools/devcheck/devcheck.py all` (see `tools/devcheck/README.md`).
5. Changelog: the topmost section of `changelog.txt` is always the **next** version
   (`Version: X.Y.Z` without a `Date:` line). Every pull request into `main` that changes the
   game (prototypes, scripts, locale, graphics) adds its player-facing lines there, in the
   Factorio changelog format (`Features:`, `Changes:`, `Bugfixes:`, `Balancing:`, `Graphics:`,
   `Info:`). Pure tooling or docs changes need no entry. CI fails a game-changing pull request
   into `main` without a `changelog.txt` change unless it has the label `no changelog`.
6. Releases: `main` is development, `upstream/release` is the published state. Set `version` in
   `info.json` to the topmost changelog section, add its `Date: YYYY-MM-DD` line, then open
   a pull request from `main` into `upstream/release`. Its checks fail if the version is released
   already or has no changelog section. Merging it makes `.github/workflows/release.yml` create
   the GitHub release `vX.Y.Z` with the zip and upload the same zip to
   https://mods.factorio.com/mod/gregtorio-continued (repository secret `FACTORIO_MOD_API_KEY`:
   API key from https://factorio.com/profile with the permission "ModPortal: Upload Mods").
   Without the secret only the GitHub release is created; the zip can then be uploaded by hand
   (`python tools/build.py --portal`). A release that needs a newer me-network raises the version in the dependency
   `me-network >= X.Y.Z` of `info.json`, and that me-network version must be on the mod portal first. Note: `upstream/main` in a local clone is the remote of the
   original repository (Damien Reave), not a branch of this one.

## Commits

- Imperative subject line, max ~70 characters, blank line, then the why and the what.
- One logical change per commit.
- The mod name stays `Gregtorio` so existing saves keep working.
