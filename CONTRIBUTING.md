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
4. Before committing: `python tools/check_syntax.py --loaded`, and on Linux the headless
   harness `python tools/devcheck/devcheck.py all` (see `tools/devcheck/README.md`).
5. Releases: bump `version` in `info.json`, add a section at the top of `changelog.txt`
   (Factorio changelog format), merge, then push a tag `vX.Y.Z`.

## Commits

- Imperative subject line, max ~70 characters, blank line, then the why and the what.
- One logical change per commit.
- The mod name stays `Gregtorio` so existing saves keep working.
