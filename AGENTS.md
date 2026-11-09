# Agent notes

## Commands

```sh
nvim --clean --headless -l scripts/check.lua   # assertions + WCAG + assets
nvim --clean --headless -l scripts/wcag.lua    # full contrast report
scripts/preview.sh                             # HTML preview + PNG screenshot
```

`check.lua` and `wcag.lua` must pass before a palette or highlight change
lands; re-run `preview.sh` whenever rendered colors change.

## Conventions

- `lua/rsms/palette.lua` is the only place colors are defined. Anchors keep
  the exact source values (including `#rrggbbaa`); `highlights.lua` only reads
  resolved role names (`p.string`, `p.warn`, ...) and never writes hex.
- When adding an anchor, add the source value next to it and make sure its
  flattened output is opaque. `scripts/check.lua` rejects 8-digit colors in
  rendered groups.
- New decorations require an entry in `M.DECORATIONS`
  (`lua/rsms/highlights.lua`); the global sweep strips anything unlisted.
- Assets (`assets/rsms-dark`, `assets/rsms-bright`) are generated from the
  resolved palette. Update them whenever the terminal palette changes.
- Read `GLOSSARY.md` before naming a concept in code, a commit, or a test.

## Structure

```
colors/         colorscheme entry points (rsms, rsms-dark, rsms-bright)
lua/rsms/       init (load/setup), palette (anchors + derived), highlights
scripts/        headless check, WCAG report, preview generator
assets/         resolved palettes and the generated preview image
```
