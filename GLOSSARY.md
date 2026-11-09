# rsms.nvim Glossary

A Neovim port of the rsms dark and bright color themes. This glossary pins the
vocabulary used when discussing its colors, layers, and style.

## Palette

**Source theme**: The upstream Sublime Text color schemes
(`rsms/sublime-theme`, also packaged for VS Code/Cursor as
`rsms/vscode-theme`) whose rules define the anchors. Hues and decoration
choices follow the source; the only deliberate deviations are WCAG-driven
darkenings of a few bright-variant text colors, noted in `palette.lua`.
_Avoid_: original theme, inspiration

**Palette anchor**: One of the exact hex values in the source `colors` and
`tokenColors` blocks, including CSS-style alpha for translucent values. Anchors
are never tuned in place.
_Avoid_: base color, brand color

**Alpha flattening**: Compositing a translucent anchor (`#rrggbbaa`) over the
variant background to produce an opaque `#rrggbb`, because Neovim highlights
have no alpha channel. Flattening happens once, in `palette.lua`.
_Avoid_: alpha blending, transparency emulation

**Resolved palette**: The opaque colors produced by alpha-flattening anchors
and by computing derived shades. The values in `assets/rsms-*` are resolved
palette values, not anchors.

**Derived shade**: A lighter or darker variant computed from an anchor, used
where anchors alone do not provide enough steps (chrome, diff tints,
diagnostic virtual text) or where a source alpha misses a WCAG floor.
_Avoid_: adjusted color, tweak

## Variants

**Variant**: One of the two source themes, `dark` or `bright`. A variant owns
its own background, anchors, and syntax hues; bright is not a computed inverse.
`:colorscheme rsms` chooses a variant from `'background'`.

**Decoration allowlist**: The explicit set of groups permitted to carry bold,
italic, underline, or strikethrough — bold type/function names, bold/italic
markdown, and functional underlines (match-paren, spelling, diagnostics).
Everything else is stripped after the palette is applied.

## Highlighting

**Syntax role**: The semantic class a token belongs to — keyword, function,
type, string/constant, variable, tag, punctuation. Hues are assigned per syntax
role, not per individual highlight group.
_Avoid_: token type, scope

**Semantic scene**: A highlighting context outside syntax where hue carries
fixed meaning — diagnostics, diff, git.
_Avoid_: semantic highlighting (reserved in Neovim for LSP tokens)

**Highlight surface**: A consumer of highlight groups: core UI + syntax,
Treesitter, LSP/diagnostics, plugins, or the embedded terminal.

**UI chrome**: Non-code editor furniture — statusline, line numbers,
separators, float borders — styled to recede rather than pop.
_Avoid_: interface elements

## Accessibility

**WCAG tiers (body / secondary / ui / exempt)**: The conformance grade applied
to each rendered color pair — body text ≥ 4.5:1, secondary text ≥ 3:1
(comments, line numbers, punctuation), non-text UI ≥ 3:1, and exempt for purely
decorative markers, bracket colors, and diagnostic virtual text.
