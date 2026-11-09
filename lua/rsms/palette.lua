-- Palette for rsms.nvim.
--
-- Source of truth: rsms/vscode-theme, themes/rsms-dark-color-theme.json and
-- themes/rsms-bright-color-theme.json. Anchors are the exact source values;
-- 8-digit hex carries CSS-style alpha (#rrggbbaa).
--
-- Neovim's highlight API has no alpha channel, so every translucent anchor is
-- flattened over the variant background before use ("alpha flattening" in
-- GLOSSARY.md). Everything that is not an anchor is a derived shade computed
-- from anchors; anchors are never tuned in place. Where the source's alpha
-- falls short of the WCAG floor for real text or UI, the derived shade is
-- raised and the source value is noted next to it.

local M = {}

local function to_rgb(hex)
  local h = hex:gsub("^#", "")
  local r = tonumber(h:sub(1, 2), 16)
  local g = tonumber(h:sub(3, 4), 16)
  local b = tonumber(h:sub(5, 6), 16)
  local a = #h == 8 and tonumber(h:sub(7, 8), 16) / 255 or nil
  return r, g, b, a
end

local function to_hex(r, g, b)
  return string.format("#%02x%02x%02x", math.floor(r + 0.5), math.floor(g + 0.5), math.floor(b + 0.5))
end

--- Composite a possibly translucent color over an opaque background.
local function flatten(hex, bg)
  local r, g, b, a = to_rgb(hex)
  if not a then
    return to_hex(r, g, b)
  end
  local br, bgc, bb = to_rgb(bg)
  return to_hex(r * a + br * (1 - a), g * a + bgc * (1 - a), b * a + bb * (1 - a))
end

--- Mix `fg` over `bg`: alpha 0 gives bg, 1 gives fg.
local function blend(fg, bg, alpha)
  local fr, fgc, fb = to_rgb(fg)
  local br, bgc, bb = to_rgb(bg)
  return to_hex(fr * alpha + br * (1 - alpha), fgc * alpha + bgc * (1 - alpha), fb * alpha + bb * (1 - alpha))
end

local function darken(hex, amount)
  return blend("#000000", hex, amount)
end

local function lighten(hex, amount)
  return blend("#ffffff", hex, amount)
end

local function build(a)
  local p = { anchors = a, label = a.variant }
  local bg = a.bg

  -- Opaque anchors and alpha-flattened anchors.
  p.bg = bg
  p.fg = flatten(a.fg, bg)
  p.comment = flatten(a.comment, bg)
  p.muted = flatten(a.muted, bg)
  p.attribute = flatten(a.attribute, bg)
  p.doc = flatten(a.doc, bg)
  p.keyword = flatten(a.keyword, bg)
  p.keyword_control = flatten(a.keyword_control, bg)
  p.keyword_meta = flatten(a.keyword_meta, bg)
  p.fn = flatten(a.fn, bg)
  p.type = flatten(a.type, bg)
  p.type_builtin = flatten(a.type_builtin, bg)
  p.string = flatten(a.string, bg)
  p.string_special = flatten(a.string_special, bg)
  p.constant = flatten(a.constant, bg)
  p.variable = flatten(a.variable, bg)
  p.annotation = flatten(a.annotation, bg)
  p.tag = flatten(a.tag, bg)
  p.bullet = flatten(a.bullet, bg)
  p.cursor = flatten(a.cursor, bg)
  p.cursor_text = flatten(a.cursor_text, bg)
  p.selection = flatten(a.selection, bg)
  p.selection_fg = flatten(a.selection_fg, bg)
  p.incsearch = flatten(a.incsearch, bg)
  p.markup_bg = flatten(a.markup_bg, bg)
  p.heading_bg = flatten(a.heading_bg, bg)
  p.indent = flatten(a.indent, bg)
  p.find = a.find
  p.find_fg = a.find_fg
  p.operator = a.operator and flatten(a.operator, bg) or p.keyword
  p.bracket = a.bracket

  -- Secondary text and UI chrome. WCAG floors are enforced by
  -- scripts/wcag.lua; a few source alphas sit just under them.
  p.linenr = blend(p.fg, bg, a.linenr_alpha) -- source #ffffff4c (0.30) / #cccccc
  p.border = blend(p.fg, bg, a.border_alpha) -- derived; holds the 3:1 floor
  p.nontext = blend(p.fg, bg, a.nontext_alpha) -- decorative

  if a.variant == "dark" then
    -- Overlay backgrounds are darkened (never lightened) so mid-luminance
    -- syntax colors keep their contrast wherever they are rendered.
    p.cursorline = darken(bg, 0.35)
    p.statusline = blend(p.fg, bg, 0.09)
    p.float = darken(bg, 0.25)

    p.diff_add = blend(a.ok, bg, 0.10)
    p.diff_change = blend(a.warn, bg, 0.08)
    p.diff_delete = blend(a.danger, bg, 0.12)
    p.diff_text = blend(a.info, bg, 0.18)
    p.matchparen_bg = blend(a.cursor, bg, 0.18)

    p.regexp = p.string
    p.regexp_bg = flatten(a.regexp_bg, bg)
    p.warn = a.warn
    p.hint = a.hint
    p.magenta = p.cursor
  else
    p.cursorline = flatten(a.cursorline, bg)
    p.statusline = flatten(a.statusline, bg)
    p.float = darken(bg, 0.02)

    p.diff_add = flatten(a.diff_add, bg)
    p.diff_delete = flatten(a.diff_delete, bg)
    p.diff_change = blend(a.find, bg, 0.16)
    p.diff_text = blend(a.find, bg, 0.30)
    p.matchparen_bg = flatten(a.matchparen, bg)

    -- Source hues that are legible as decoration but not as body text on the
    -- light background are darkened derived shades.
    p.regexp = darken(a.regexp, 0.30) -- #ff7598, 2.50 -> 4.79
    p.warn = darken(a.warn, 0.20) -- #aa8844, 3.15 -> 4.81
    p.hint = darken(a.hint, 0.40) -- #71c1c1, 1.96 -> 5.16
    p.magenta = a.bracket[6]
  end

  p.danger = a.danger
  p.info = a.info
  p.ok = a.ok
  p.invalid = a.invalid

  -- Diagnostic virtual text: supplementary, deliberately WCAG-exempt, and
  -- kept soft so it never competes with code.
  p.soft = {
    danger = blend(p.danger, bg, 0.62),
    warn = blend(p.warn, bg, 0.62),
    info = blend(p.info, bg, 0.62),
    hint = blend(p.hint, bg, 0.62),
    ok = blend(p.ok, bg, 0.62),
  }

  -- Terminal palette: resolved values, slots 0..15.
  if a.variant == "dark" then
    p.terminal = {
      blend(p.fg, bg, 0.10), p.danger, p.string, p.operator,
      p.info, p.cursor, p.hint, p.fg,
      blend(p.fg, bg, 0.38), lighten(p.danger, 0.12), lighten(p.string, 0.18),
      p.warn, p.keyword, lighten(p.cursor, 0.18), lighten(p.hint, 0.20), "#ffffff",
    }
  else
    p.terminal = {
      p.attribute, p.danger, p.string, p.warn,
      p.type, p.constant, p.hint, darken(bg, 0.60),
      p.comment, darken(p.invalid, 0.20), p.ok, a.warn,
      lighten(p.type, 0.15), a.bracket[6], darken(p.hint, 0.15), p.fg,
    }
  end
  p.terminal_fg = p.fg
  p.terminal_bg = p.bg
  p.terminal_cursor = p.cursor

  return p
end

local dark = {
  variant = "dark",
  bg = "#121212",
  fg = "#ffffffcc",
  comment = "#ffffff59",
  muted = "#ffffff66",
  cursor = "#f76ec9",
  cursor_text = "#121212",
  selection = "#66c2ff4c",
  selection_fg = "#ffffff",
  linenr_alpha = 0.42, -- source #ffffff4c (0.30) misses 3:1
  border_alpha = 0.46, -- derived; 3:1 non-text floor
  nontext_alpha = 0.16,

  keyword = "#94b2d1",
  keyword_control = "#94b2d1",
  keyword_meta = "#85ad99",
  operator = "#ffc799",
  fn = "#ffffff",
  type = "#ffffff",
  type_builtin = "#ffdbbd",
  string = "#94d1b3",
  string_special = "#ccffe6",
  constant = "#94d1b3",
  variable = "#6c9380",
  annotation = "#6c9380",
  tag = "#ffdbbd",
  attribute = "#ffffffcc",
  doc = "#ffffff59",

  danger = "#f7796e",
  warn = "#ffff99",
  info = "#75b2f0",
  hint = "#71c1c1",
  ok = "#3df599",
  invalid = "#ff1500",

  find = "#ffff00",
  find_fg = "#000000",
  incsearch = "#ffc799",
  regexp_bg = "#3399ff1a",
  markup_bg = "#ffffff12",
  heading_bg = "#bfb04033",
  indent = "#ffffff0f",
  bullet = "#ffff99",

  bracket = { "#f76ec9", "#75b2f0", "#3df599", "#ffff99", "#ffc799", "#ffdbbd" },
}

local bright = {
  variant = "bright",
  bg = "#fdfdfc",
  fg = "#000000",
  comment = "#00000078",
  muted = "#00003378",
  cursor = "#0044ff",
  cursor_text = "#ffffff",
  selection = "#a8dcff80",
  selection_fg = "#000000",
  cursorline = "#ffff004f",
  statusline = "#dddddd",
  linenr_alpha = 0.45, -- source #cccccc misses 3:1
  border_alpha = 0.45, -- derived; 3:1 non-text floor
  nontext_alpha = 0.14,

  keyword = "#00000099",
  keyword_control = "#000075ab",
  keyword_meta = "#00000099",
  operator = nil, -- source falls through to keyword
  fn = "#000000",
  type = "#0043a8",
  type_builtin = "#002233cc",
  string = "#116432",
  string_special = "#060e0c",
  constant = "#750054",
  variable = "#000000",
  annotation = "#422100ba",
  tag = "#66559b",
  attribute = "#333333",
  doc = "#333333",

  danger = "#990000",
  warn = "#aa8844", -- bracket anchor; darkened for text use
  info = "#0043a8",
  hint = "#71c1c1", -- bracket anchor; darkened for text use
  ok = "#2f7b0a",
  invalid = "#ff3300",

  find = "#ffe642",
  find_fg = "#000000",
  incsearch = "#e5b594",
  regexp = "#ff7598", -- source regexp pink; darkened for text use
  markup_bg = "#0000000a",
  heading_bg = "#fff70033",
  indent = "#0000000f",
  bullet = "#0043a8",

  matchparen = "#ffff0033",
  diff_add = "#dafbe1",
  diff_delete = "#fce6e3",

  bracket = { "#888888", "#aa8844", "#116432", "#750054", "#e5b594", "#aa2298" },
}

M.dark = build(dark)
M.bright = build(bright)

M.blend = blend
M.flatten = flatten

return M
