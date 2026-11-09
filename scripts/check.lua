-- Headless regression for rsms.nvim.
-- Run from the repo root:
--   nvim --clean --headless -l scripts/check.lua
--
-- Verifies: source anchors, rendered palette (assets/rsms-*), the syntax-role
-- hue mapping for both variants, the decoration allowlist, the embedded
-- terminal palette, and WCAG AA for every rendered fg/bg pair.

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(root)

local rsms = require("rsms")
local palettes = require("rsms.palette")
local highlights = require("rsms.highlights")
local wcag = dofile(root .. "/scripts/wcag.lua")

local failures = {}
local function check(label, ok, detail)
  if not ok then
    table.insert(failures, label .. (detail and (" — " .. detail) or ""))
  end
end

local function fg_of(group)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl.fg then
    return string.format("#%06x", hl.fg)
  end
  return nil
end

local function bg_of(group)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl.bg then
    return string.format("#%06x", hl.bg)
  end
  return nil
end

local function attr_of(group, attr)
  return vim.api.nvim_get_hl(0, { name = group, link = false })[attr] == true
end

local function sp_of(group)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl.sp then
    return string.format("#%06x", hl.sp)
  end
  return nil
end

local function read_assets(variant)
  local out = { palette = {} }
  for line in io.lines(root .. "/assets/rsms-" .. variant) do
    local slot, color = line:match("^palette = (%d+)=(#%x+)")
    if slot then
      out.palette[tonumber(slot)] = color
    else
      local key, value = line:match("^([%w%-]+) = (#%x+)")
      if key then
        out[key] = value
      end
    end
  end
  return out
end

local function check_hex(label, color)
  check(label .. " is 6-digit hex", type(color) == "string" and color:match("^#%x%x%x%x%x%x$") ~= nil, tostring(color))
end

-- 1. Source anchors: exact values from rsms/vscode-theme (alpha preserved).
local SOURCE = {
  dark = {
    bg = "#121212",
    fg = "#ffffffcc",
    comment = "#ffffff59",
    cursor = "#f76ec9",
    selection = "#66c2ff4c",
    inactive_selection = "#b3b3b333",
    keyword = "#94b2d1",
    string = "#94d1b3",
    constant = "#94d1b3",
    type = "#ffffff",
    property = "#6c9380",
    tag_delimiter = "#ffffff66",
    misspelling = "#ff5b4d",
    add_fg = "#9efacc",
    del_fg = "#e48981",
  },
  bright = {
    bg = "#fdfdfc",
    fg = "#000000",
    comment = "#00000078",
    cursor = "#0044ff",
    selection = "#a8dcff80",
    inactive_selection = "#a8dcff40",
    string = "#116432",
    constant = "#750054",
    type = "#0043a8",
    property = "#666666",
    tag_delimiter = "#66559b",
    add_fg = "#052e0e",
    del_fg = "#544645",
  },
}
for variant, anchors in pairs(SOURCE) do
  local p = palettes[variant]
  for key, expected in pairs(anchors) do
    check(("%s anchor %s"):format(variant, key), p.anchors[key] == expected,
      ("got %s, want %s"):format(tostring(p.anchors[key]), expected))
  end
end

-- 2. Rendered palette: every output is opaque, and assets match.
for _, variant in ipairs({ "dark", "bright" }) do
  local p = palettes[variant]
  local assets = read_assets(variant)
  for key, value in pairs(p) do
    if type(value) == "string" and value:sub(1, 1) == "#" then
      check_hex(("%s palette.%s"):format(variant, key), value)
    end
  end
  check(("%s assets background"):format(variant), assets.background == p.bg)
  check(("%s assets foreground"):format(variant), assets.foreground == p.fg)
  check(("%s assets cursor-color"):format(variant), assets["cursor-color"] == p.cursor)
  check(("%s assets cursor-text"):format(variant), assets["cursor-text"] == p.cursor_text)
  check(("%s assets selection-background"):format(variant), assets["selection-background"] == p.selection)
  check(("%s assets selection-foreground"):format(variant), assets["selection-foreground"] == p.selection_fg)
  for i = 0, 15 do
    check(("%s assets terminal slot %d"):format(variant, i), assets.palette[i] == p.terminal[i + 1],
      ("got %s, want %s"):format(tostring(assets.palette[i]), tostring(p.terminal[i + 1])))
  end
end

-- 3. Roles, decorations, terminal, and WCAG per variant.
for _, variant in ipairs({ "dark", "bright" }) do
  rsms.load(variant)
  local p = palettes[variant]
  local function tag(label)
    return ("[%s] %s"):format(variant, label)
  end

  check(tag("Normal fg"), fg_of("Normal") == p.fg)
  check(tag("Normal bg"), bg_of("Normal") == p.bg)
  check(tag("Comment"), fg_of("Comment") == p.comment)
  check(tag("documentation comment"), fg_of("@comment.documentation") == p.doc)
  check(tag("LineNr"), fg_of("LineNr") == p.linenr)
  check(tag("CursorLineSign bg"), bg_of("CursorLineSign") == p.cursorline)
  check(tag("CursorLineFold bg"), bg_of("CursorLineFold") == p.cursorline)
  check(tag("WinSeparator"), fg_of("WinSeparator") == p.border)
  check(tag("Pmenu bg"), bg_of("Pmenu") == p.float)
  check(tag("heading bg"), bg_of("@markup.heading.1") == p.heading_bg)
  check(tag("heading bold"), attr_of("@markup.heading.1", "bold"))
  check(tag("markup italic"), attr_of("@markup.italic", "italic"))
  check(tag("markup list bold"), attr_of("@markup.list", "bold"))
  if p.regexp_bg then
    check(tag("regexp bg"), bg_of("@string.regexp") == p.regexp_bg)
  else
    check(tag("regexp has no bg"), bg_of("@string.regexp") == nil)
  end
  check(tag("Statement (keyword)"), fg_of("Statement") == p.keyword)
  check(tag("Function fg"), fg_of("Function") == p.fn)
  check(tag("Function bold"), attr_of("Function", "bold"))
  check(tag("@function fg"), fg_of("@function") == p.fn)
  check(tag("@function bold"), attr_of("@function", "bold"))
  check(tag("@function.call not bold"), not attr_of("@function.call", "bold"))
  check(tag("String"), fg_of("String") == p.string)
  check(tag("string escape"), fg_of("@string.escape") == p.string)
  check(tag("Constant"), fg_of("Constant") == p.constant)
  check(tag("Type fg"), fg_of("Type") == p.type)
  check(tag("Type bold"), attr_of("Type", "bold"))
  check(tag("@type.builtin"), fg_of("@type.builtin") == p.type_builtin)
  check(tag("@type.builtin not bold"), not attr_of("@type.builtin", "bold"))
  check(tag("Identifier"), fg_of("Identifier") == p.variable)
  check(tag("property"), fg_of("@property") == p.property)
  check(tag("variable.member"), fg_of("@variable.member") == p.property)
  check(tag("Operator"), fg_of("Operator") == p.operator)
  check(tag("Tag"), fg_of("Tag") == p.tag)
  check(tag("tag delimiter"), fg_of("@tag.delimiter") == p.tag_delimiter)
  check(tag("storageclass"), fg_of("@storageclass") == p.keyword)
  check(tag("type qualifier"), fg_of("@type.qualifier") == p.keyword)
  check(tag("legacy StorageClass"), fg_of("StorageClass") == p.keyword)
  check(tag("Search fg"), fg_of("Search") == p.find_fg)
  check(tag("Search bg"), bg_of("Search") == p.find)
  check(tag("Visual fg"), fg_of("Visual") == p.selection_fg)
  check(tag("Visual bg"), bg_of("Visual") == p.selection)
  check(tag("VisualNOS fg"), fg_of("VisualNOS") == p.selection_fg)
  check(tag("VisualNOS bg"), bg_of("VisualNOS") == p.inactive_selection)
  check(tag("MatchParen fg"), fg_of("MatchParen") == p.cursor)
  check(tag("MatchParen bold"), attr_of("MatchParen", "bold"))
  check(tag("LSP reference bg"), bg_of("LspReferenceText") == p.reference)
  check(tag("StatusLine fg"), fg_of("StatusLine") == p.fg)
  check(tag("StatusLine bg"), bg_of("StatusLine") == p.statusline)
  check(tag("DiagnosticError"), fg_of("DiagnosticError") == p.danger)
  check(tag("DiagnosticWarn"), fg_of("DiagnosticWarn") == p.warn)
  check(tag("DiagnosticInfo"), fg_of("DiagnosticInfo") == p.info)
  check(tag("DiagnosticHint"), fg_of("DiagnosticHint") == p.hint)
  check(tag("DiagnosticOk"), fg_of("DiagnosticOk") == p.ok)
  check(tag("SpellBad sp"), sp_of("SpellBad") == p.spell_bad)
  check(tag("Error fg"), fg_of("Error") == p.bg)
  check(tag("Error bg"), bg_of("Error") == p.danger)
  check(tag("Added fg"), fg_of("Added") == p.add_fg)
  check(tag("Added bg"), bg_of("Added") == p.diff_add)
  check(tag("Removed fg"), fg_of("Removed") == p.del_fg)
  check(tag("Removed bg"), bg_of("Removed") == p.diff_delete)
  check(tag("@diff.plus"), fg_of("@diff.plus") == p.add_fg)
  check(tag("@diff.minus"), fg_of("@diff.minus") == p.del_fg)
  check(tag("@diff.delta"), fg_of("@diff.delta") == p.hint)
  check(tag("diffOldFile"), fg_of("diffOldFile") == p.danger)
  check(tag("diffNewFile"), fg_of("diffNewFile") == p.ok)
  check(tag("GitSignsAdd"), fg_of("GitSignsAdd") == p.ok)
  check(tag("GitSignsChange"), fg_of("GitSignsChange") == p.warn)
  check(tag("GitSignsDelete"), fg_of("GitSignsDelete") == p.danger)
  check(tag("GitSignsUntracked"), fg_of("GitSignsUntracked") == p.info)
  check(tag("MiniDiffOverAdd bg"), bg_of("MiniDiffOverAdd") == p.diff_add)

  -- Terminal palette: resolved anchors, slot order preserved.
  for i = 0, 15 do
    check(tag("terminal slot " .. i), vim.g["terminal_color_" .. i] == p.terminal[i + 1])
  end
  check(tag("terminal fg"), vim.g.terminal_color_foreground == p.fg)
  check(tag("terminal bg"), vim.g.terminal_color_background == p.bg)
  check(tag("terminal cursor"), vim.g.terminal_color_cursor == p.cursor)

  -- Decoration allowlist: no stray bold/italic/underline/strikethrough and no
  -- undercurl outside the functional indicators.
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if not hl.link then
      for attr, allowed in pairs(highlights.DECORATIONS) do
        local gui = hl[attr] == true
        local cterm = hl.cterm ~= nil and hl.cterm[attr] == true
        if (gui or cterm) and not allowed[name] then
          check(tag("decoration " .. attr .. " on " .. name), false)
        end
      end
      for _, attr in ipairs({ "underdouble", "underdotted", "underdashed" }) do
        if hl[attr] or (hl.cterm and hl.cterm[attr]) then
          check(tag("stray " .. attr .. " on " .. name), false)
        end
      end
    end
  end

  -- WCAG AA for every rendered pair (see scripts/wcag.lua for the full report).
  for _, r in ipairs(wcag.results(variant)) do
    if not r.pass then
      check(tag(("WCAG %s %.2f < %s: %s"):format(r.tier, r.ratio, tostring(r.target), r.name)), false)
    end
  end
end

-- 4. Variant resolution follows 'background'; explicit variants override it.
vim.o.background = "light"
rsms.load()
check("auto variant light", vim.o.background == "light" and fg_of("Normal") == palettes.bright.fg)
vim.o.background = "dark"
rsms.load()
check("auto variant dark", vim.o.background == "dark" and fg_of("Normal") == palettes.dark.fg)
rsms.load("bright")
check("explicit bright overrides dark background", vim.o.background == "light" and fg_of("Normal") == palettes.bright.fg)
rsms.load("dark")
check("explicit dark overrides light background", vim.o.background == "dark" and fg_of("Normal") == palettes.dark.fg)

-- 5. Unknown setup keys are rejected; terminal colors can be turned off.
check("unknown setup option rejected", not pcall(rsms.setup, { transparent = true }))
check("non-boolean setup option rejected", not pcall(rsms.setup, { terminal_colors = "yes" }))
rsms.setup({ terminal_colors = false })
rsms.load("dark")
check("terminal colors disabled", vim.g.terminal_color_0 == nil and vim.g.terminal_color_foreground == nil)
rsms.setup({ terminal_colors = true })
rsms.load("dark")
check("terminal colors re-enabled", vim.g.terminal_color_0 == palettes.dark.terminal[1])

-- WCAG per-tier worst case, for the record.
for _, variant in ipairs({ "dark", "bright" }) do
  local mins = {}
  for _, r in ipairs(wcag.results(variant)) do
    if r.target then
      local m = mins[r.tier]
      if not m or r.ratio < m.ratio then
        mins[r.tier] = r
      end
    end
  end
  for _, tier in ipairs({ "body", "secondary", "ui" }) do
    local m = mins[tier]
    if m then
      print(("wcag %-9s %s min %.2f (target %.1f) — %s"):format(variant, tier, m.ratio, m.target, m.name))
    end
  end
end

if #failures == 0 then
  print("PASS")
  os.exit(0)
else
  print("FAIL (" .. #failures .. ")")
  for _, f in ipairs(failures) do
    print("  - " .. f)
  end
  os.exit(1)
end
