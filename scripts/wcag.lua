-- WCAG 2.1 contrast audit for rsms.nvim.
-- Contrast ratios use the standard relative-luminance formula:
--   (L_lighter + 0.05) / (L_darker + 0.05)
-- Tiers (WCAG AA):
--   body      >= 4.5 : readable code text
--   secondary >= 3.0 : secondary/incidental text (AA large-text level)
--   ui        >= 3.0 : non-text UI (WCAG 1.4.11)
--   exempt           : decorative markers and supplementary virtual text
--
-- Run both variants from the repo root:
--   nvim --clean --headless -l scripts/wcag.lua

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(root)
local palettes = require("rsms.palette")

local M = {}

M.TIER_TARGET = { body = 4.5, secondary = 3.0, ui = 3.0, exempt = nil }

local function srgb_to_linear(c)
  c = c / 255
  if c <= 0.04045 then
    return c / 12.92
  end
  return ((c + 0.055) / 1.055) ^ 2.4
end

local function luminance(hex)
  local r = srgb_to_linear(tonumber(hex:sub(2, 3), 16))
  local g = srgb_to_linear(tonumber(hex:sub(4, 5), 16))
  local b = srgb_to_linear(tonumber(hex:sub(6, 7), 16))
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

function M.contrast(fg, bg)
  local l1, l2 = luminance(fg), luminance(bg)
  if l2 > l1 then
    l1, l2 = l2, l1
  end
  return (l1 + 0.05) / (l2 + 0.05)
end

--- Every fg/bg pair where themed text or UI is actually rendered.
--- Overlays that replace fg are audited as the overlay's own text color on
--- its tint; syntax colors never mix into them.
function M.situations(variant)
  local p = palettes[variant]
  assert(p, ("rsms: unknown variant %q"):format(tostring(variant)))
  local doc_tier = variant == "bright" and "body" or "secondary"

  local out = {
    -- Code text on the main background
    { "Normal text on bg", p.fg, p.bg, "body" },
    { "keyword on bg", p.keyword, p.bg, "body" },
    { "control keyword on bg", p.keyword_control, p.bg, "body" },
    { "meta keyword on bg", p.keyword_meta, p.bg, "body" },
    { "function on bg", p.fn, p.bg, "body" },
    { "type on bg", p.type, p.bg, "body" },
    { "builtin type on bg", p.type_builtin, p.bg, "body" },
    { "string on bg", p.string, p.bg, "body" },
    { "string escape on bg", p.string_special, p.bg, "body" },
    { "constant on bg", p.constant, p.bg, "body" },
    { "variable on bg", p.variable, p.bg, "body" },
    { "property on bg", p.property, p.bg, "body" },
    { "operator on bg", p.operator, p.bg, "body" },
    { "annotation on bg", p.annotation, p.bg, "body" },
    { "tag on bg", p.tag, p.bg, "body" },
    { "tag delimiter on bg", p.tag_delimiter, p.bg, "secondary" },
    { "attribute on bg", p.attribute, p.bg, "body" },
    { "bullet on bg", p.bullet, p.bg, "body" },
    { "regexp on bg", p.regexp, p.bg, "body" },

    -- Diagnostics and messages
    { "DiagnosticError on bg", p.danger, p.bg, "body" },
    { "DiagnosticWarn on bg", p.warn, p.bg, "body" },
    { "DiagnosticInfo on bg", p.info, p.bg, "body" },
    { "DiagnosticHint on bg", p.hint, p.bg, "body" },
    { "DiagnosticOk on bg", p.ok, p.bg, "body" },
    { "ErrorMsg on bg", p.danger, p.bg, "body" },
    { "Error text on Error bg", p.bg, p.danger, "body" },
    { "WarningMsg on bg", p.warn, p.bg, "body" },
    { "Todo text on Todo bg", p.bg, p.info, "body" },

    -- Text over background-only overlays
    { "Normal text on cursorline", p.fg, p.cursorline, "body" },
    { "keyword on cursorline", p.keyword, p.cursorline, "body" },
    { "function on cursorline", p.fn, p.cursorline, "body" },
    { "type on cursorline", p.type, p.cursorline, "body" },
    { "string on cursorline", p.string, p.cursorline, "body" },
    { "variable on cursorline", p.variable, p.cursorline, "body" },
    { "property on cursorline", p.property, p.cursorline, "body" },
    { "comment on cursorline", p.comment, p.cursorline, "secondary" },
    { "punctuation on cursorline", p.muted, p.cursorline, "secondary" },

    -- Overlays that replace fg
    { "Visual text on selection", p.selection_fg, p.selection, "body" },
    { "VisualNOS text on inactive selection", p.selection_fg, p.inactive_selection, "body" },
    { "Search fg on Search bg", p.find_fg, p.find, "body" },
    { "IncSearch fg on IncSearch bg", p.find_fg, p.incsearch, "body" },
    { "MatchParen fg on bg", p.cursor, p.bg, "body" },
    { "LSP reference text on reference bg", p.fg, p.reference, "body" },
    { "keyword on reference bg", p.keyword, p.reference, "body" },
    { "function on reference bg", p.fn, p.reference, "body" },
    { "type on reference bg", p.type, p.reference, "body" },
    { "string on reference bg", p.string, p.reference, "body" },
    { "variable on reference bg", p.variable, p.reference, "body" },
    { "property on reference bg", p.property, p.reference, "body" },
    { "Cursor text on cursor", p.cursor_text, p.cursor, "body" },
    { "Pmenu text on Pmenu bg", p.fg, p.float, "body" },
    { "PmenuSel text on selection", p.selection_fg, p.selection, "body" },
    { "StatusLine text on StatusLine bg", p.fg, p.statusline, "body" },
    { "Normal text on float", p.fg, p.float, "body" },

    -- Diffs: syntax text rendered on diff-tinted backgrounds
    { "Added text on DiffAdd", p.add_fg, p.diff_add, "body" },
    { "Changed text on DiffChange", p.constant, p.diff_change, "body" },
    { "Removed text on DiffDelete", p.del_fg, p.diff_delete, "body" },
    { "diffAdded on bg", p.add_fg, p.bg, "body" },
    { "diffRemoved on bg", p.del_fg, p.bg, "body" },
    { "diff delta on bg", p.hint, p.bg, "body" },
    { "Normal text on DiffText", p.fg, p.diff_text, "body" },
    { "string on DiffText", p.string, p.diff_text, "body" },
    { "string on DiffAdd bg", p.string, p.diff_add, "body" },

    -- Markdown headings carry their source background tint
    { "heading text on heading bg", p.fn, p.heading_bg, "body" },

    -- Secondary / incidental text
    { "comment on bg", p.comment, p.bg, "secondary" },
    { "punctuation on bg", p.muted, p.bg, "secondary" },
    { "LineNr on bg", p.linenr, p.bg, "secondary" },
    { "comment on float", p.comment, p.float, "secondary" },
    { "comment on reference bg", p.comment, p.reference, "secondary" },
    { "StatusLineNC on bg", p.comment, p.bg, "secondary" },
    { "TabLine on bg", p.comment, p.bg, "secondary" },
    { "Folded (comment) on Folded bg", p.comment, p.cursorline, "secondary" },
    { "documentation comment on bg", p.doc, p.bg, doc_tier },

    -- Non-text UI (WCAG 1.4.11)
    { "FloatBorder on float bg", p.border, p.float, "ui" },
    { "WinSeparator on bg", p.border, p.bg, "ui" },
    { "cursor on bg", p.cursor, p.bg, "ui" },
    { "invalid on bg", p.invalid, p.bg, "ui" },
    { "SpellBad undercurl sp vs bg", p.spell_bad, p.bg, "ui" },
    { "GitSignsAdd on bg", p.ok, p.bg, "ui" },
    { "GitSignsChange on bg", p.warn, p.bg, "ui" },
    { "GitSignsDelete on bg", p.danger, p.bg, "ui" },
    { "GitSignsUntracked on bg", p.info, p.bg, "ui" },
    { "SpellRare undercurl sp vs bg", p.magenta, p.bg, "ui" },

    -- Purely decorative markers: exempt from WCAG, recorded for the record
    { "NonText on bg", p.nontext, p.bg, "exempt" },
    { "indent guide on bg", p.indent, p.bg, "exempt" },
    { "virtual text error (soft) on bg", p.soft.danger, p.bg, "exempt" },
    { "virtual text warn (soft) on bg", p.soft.warn, p.bg, "exempt" },
    { "virtual text info (soft) on bg", p.soft.info, p.bg, "exempt" },
    { "virtual text hint (soft) on bg", p.soft.hint, p.bg, "exempt" },
    { "virtual text ok (soft) on bg", p.soft.ok, p.bg, "exempt" },
  }

  for i, color in ipairs(p.bracket) do
    out[#out + 1] = { "rainbow bracket " .. i, color, p.bg, "exempt" }
  end

  return out
end

function M.results(variant)
  local out = {}
  for _, s in ipairs(M.situations(variant)) do
    local name, fg, bg, tier = s[1], s[2], s[3], s[4]
    local ratio = M.contrast(fg, bg)
    local target = M.TIER_TARGET[tier]
    out[#out + 1] = {
      name = name, fg = fg, bg = bg, tier = tier,
      ratio = ratio, target = target,
      pass = (target == nil) or ratio >= target,
    }
  end
  return out
end

function M.print_report(variant)
  local n_fail = 0
  local results = M.results(variant)
  print(("=== rsms %s ==="):format(variant))
  for _, r in ipairs(results) do
    if not r.pass then
      n_fail = n_fail + 1
    end
    print(("%-40s %5.2f  (need %-4s for %-9s) %s  fg %s on %s"):format(
      r.name, r.ratio, tostring(r.target), r.tier,
      r.pass and (r.target == nil and "n/a " or "PASS") or "FAIL", r.fg, r.bg))
  end
  print(("---\n%d situations, %d fail their tier"):format(#results, n_fail))
  return n_fail
end

if arg and arg[0] and arg[0]:match("wcag%.lua$") then
  local failures = 0
  for _, variant in ipairs({ "dark", "bright" }) do
    failures = failures + M.print_report(variant)
  end
  os.exit(failures == 0 and 0 or 1)
end

return M
