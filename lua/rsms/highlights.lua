-- Highlight definitions for rsms.nvim.
--
-- Every hue is a palette anchor or a derived shade (see palette.lua); no raw
-- color is written here. Syntax hues follow the source themes: keyword,
-- function, type, string/constant, variable, tag, punctuation. Decoration is
-- not banned, but it is an explicit allowlist below, taken from the source:
-- bold type/function names, bold/italic markdown, and functional underlines.
-- scripts/check.lua verifies that nothing else carries an attribute.

local M = {}

-- The only groups allowed to carry a text decoration. Any other group that
-- inherits one from Neovim's defaults is stripped in `apply`.
M.DECORATIONS = {
  bold = {
    ["Function"] = true,
    ["Type"] = true,
    ["@function"] = true,
    ["@function.method"] = true,
    ["@type"] = true,
    ["@type.definition"] = true,
    ["@constructor"] = true,
    ["@markup.heading"] = true,
    ["@markup.heading.1"] = true,
    ["@markup.heading.2"] = true,
    ["@markup.heading.3"] = true,
    ["@markup.heading.4"] = true,
    ["@markup.heading.5"] = true,
    ["@markup.heading.6"] = true,
    ["@markup.strong"] = true,
    ["@markup.list"] = true,
    ["@text.title"] = true,
    ["@text.strong"] = true,
  },
  italic = {
    ["@markup.italic"] = true,
    ["@text.emphasis"] = true,
  },
  underline = {
    ["MatchParen"] = true,
    ["Underlined"] = true,
  },
  strikethrough = {
    ["@markup.strikethrough"] = true,
    ["@text.strike"] = true,
  },
  undercurl = {
    ["SpellBad"] = true,
    ["SpellCap"] = true,
    ["SpellRare"] = true,
    ["SpellLocal"] = true,
    ["DiagnosticUnderlineError"] = true,
    ["DiagnosticUnderlineWarn"] = true,
    ["DiagnosticUnderlineInfo"] = true,
    ["DiagnosticUnderlineHint"] = true,
    ["DiagnosticUnderlineOk"] = true,
  },
}

function M.apply(variant, config)
  local p = require("rsms.palette")[variant]
  assert(p, ("rsms: unknown variant %q"):format(tostring(variant)))

  local function set(name, opts)
    vim.api.nvim_set_hl(0, name, opts)
  end
  local function link(name, target)
    vim.api.nvim_set_hl(0, name, { link = target })
  end

  ----------------------------------------------------------------
  -- Editor UI
  ----------------------------------------------------------------
  set("Normal", { fg = p.fg, bg = p.bg })
  link("NormalNC", "Normal")
  set("NormalFloat", { fg = p.fg, bg = p.float })
  set("FloatBorder", { fg = p.border, bg = p.float })
  set("FloatTitle", { fg = p.info, bg = p.float })
  set("FloatFooter", { fg = p.comment, bg = p.float })

  set("Cursor", { fg = p.cursor_text, bg = p.cursor })
  link("lCursor", "Cursor")
  link("CursorIM", "Cursor")
  link("TermCursor", "Cursor")

  set("CursorLine", { bg = p.cursorline })
  link("CursorColumn", "CursorLine")
  link("ColorColumn", "CursorLine")
  set("CursorLineNr", { fg = p.fg })
  set("LineNr", { fg = p.linenr })
  link("LineNrAbove", "LineNr")
  link("LineNrBelow", "LineNr")
  set("SignColumn", { bg = p.bg })
  set("FoldColumn", { fg = p.linenr, bg = p.bg })
  set("Folded", { fg = p.comment, bg = p.cursorline })

  set("Visual", { fg = p.selection_fg, bg = p.selection })
  link("VisualNOS", "Visual")

  -- Find-match colors are exact source UI anchors (yellow on black).
  set("Search", { fg = p.find_fg, bg = p.find })
  set("IncSearch", { fg = p.find_fg, bg = p.incsearch })
  link("CurSearch", "IncSearch")
  link("Substitute", "IncSearch")
  set("MatchParen", { bg = p.matchparen_bg, underline = true, sp = p.cursor })

  set("Conceal", { fg = p.comment })
  set("NonText", { fg = p.nontext })
  link("SpecialKey", "NonText")
  link("EndOfBuffer", "NonText")
  link("Whitespace", "NonText")

  set("Directory", { fg = p.info })
  set("Title", { fg = p.type })
  set("Question", { fg = p.info })
  set("MoreMsg", { fg = p.ok })
  set("ModeMsg", { fg = p.fg })
  set("ErrorMsg", { fg = p.danger })
  set("WarningMsg", { fg = p.warn })

  set("Pmenu", { fg = p.fg, bg = p.float })
  set("PmenuSel", { fg = p.selection_fg, bg = p.selection })
  set("PmenuSbar", { bg = p.statusline })
  set("PmenuThumb", { bg = p.selection })
  link("WildMenu", "PmenuSel")

  set("StatusLine", { fg = p.fg, bg = p.statusline })
  set("StatusLineNC", { fg = p.comment, bg = p.bg })
  set("TabLine", { fg = p.comment, bg = p.bg })
  set("TabLineFill", { bg = p.bg })
  set("TabLineSel", { fg = p.fg, bg = p.statusline })

  set("WinSeparator", { fg = p.border })
  link("VertSplit", "WinSeparator")

  set("QuickFixLine", { bg = p.cursorline })

  ----------------------------------------------------------------
  -- Diffs
  ----------------------------------------------------------------
  set("DiffAdd", { bg = p.diff_add })
  set("DiffChange", { bg = p.diff_change })
  set("DiffDelete", { bg = p.diff_delete })
  set("DiffText", { bg = p.diff_text })
  set("Added", { fg = p.string, bg = p.diff_add })
  set("Changed", { fg = p.constant, bg = p.diff_change })
  set("Removed", { fg = p.danger, bg = p.diff_delete })

  ----------------------------------------------------------------
  -- Diagnostics (semantic scene: hue carries meaning)
  ----------------------------------------------------------------
  set("DiagnosticError", { fg = p.danger })
  set("DiagnosticWarn", { fg = p.warn })
  set("DiagnosticInfo", { fg = p.info })
  set("DiagnosticHint", { fg = p.hint })
  set("DiagnosticOk", { fg = p.ok })

  set("DiagnosticUnderlineError", { undercurl = true, sp = p.danger })
  set("DiagnosticUnderlineWarn", { undercurl = true, sp = p.warn })
  set("DiagnosticUnderlineInfo", { undercurl = true, sp = p.info })
  set("DiagnosticUnderlineHint", { undercurl = true, sp = p.hint })
  set("DiagnosticUnderlineOk", { undercurl = true, sp = p.ok })

  set("DiagnosticVirtualTextError", { fg = p.soft.danger })
  set("DiagnosticVirtualTextWarn", { fg = p.soft.warn })
  set("DiagnosticVirtualTextInfo", { fg = p.soft.info })
  set("DiagnosticVirtualTextHint", { fg = p.soft.hint })
  set("DiagnosticVirtualTextOk", { fg = p.soft.ok })
  link("DiagnosticVirtualLinesError", "DiagnosticVirtualTextError")
  link("DiagnosticVirtualLinesWarn", "DiagnosticVirtualTextWarn")
  link("DiagnosticVirtualLinesInfo", "DiagnosticVirtualTextInfo")
  link("DiagnosticVirtualLinesHint", "DiagnosticVirtualTextHint")
  link("DiagnosticVirtualLinesOk", "DiagnosticVirtualTextOk")

  set("DiagnosticDeprecated", { fg = p.comment })
  set("DiagnosticUnnecessary", { fg = p.comment })

  ----------------------------------------------------------------
  -- Legacy syntax: same roles as Treesitter below
  ----------------------------------------------------------------
  set("Comment", { fg = p.comment })

  set("Constant", { fg = p.constant })
  set("String", { fg = p.string })
  link("Character", "String")
  link("Number", "Constant")
  link("Boolean", "Constant")
  link("Float", "Constant")

  set("Identifier", { fg = p.variable })
  set("Function", { fg = p.fn, bold = true })

  set("Statement", { fg = p.keyword })
  link("Conditional", "Statement")
  link("Repeat", "Statement")
  link("Label", "Statement")
  link("Keyword", "Statement")
  link("Exception", "Statement")
  set("Operator", { fg = p.operator })

  set("PreProc", { fg = p.annotation })
  link("Include", "PreProc")
  link("Define", "PreProc")
  link("Macro", "PreProc")
  link("PreCondit", "PreProc")

  set("Type", { fg = p.type, bold = true })
  set("StorageClass", { fg = p.type_builtin })
  link("Structure", "Type")
  link("Typedef", "Type")

  set("Special", { fg = p.variable })
  set("SpecialChar", { fg = p.string_special })
  set("Tag", { fg = p.tag })
  set("Delimiter", { fg = p.muted })
  link("SpecialComment", "Comment")
  set("Debug", { fg = p.constant })

  -- Source decoration allowlist for legacy definitions.
  set("Bold", {})
  set("Italic", {})
  set("Underlined", { fg = p.type, underline = true })
  set("Ignore", { fg = p.nontext })
  set("Error", { fg = p.danger })
  set("Todo", { fg = p.bg, bg = p.info })

  ----------------------------------------------------------------
  -- Treesitter
  ----------------------------------------------------------------
  set("@comment", { fg = p.comment })
  set("@comment.documentation", { fg = p.doc })
  set("@comment.error", { fg = p.danger })
  set("@comment.warning", { fg = p.warn })
  set("@comment.note", { fg = p.info })
  set("@comment.hint", { fg = p.hint })
  link("@comment.todo", "Todo")

  set("@constant", { fg = p.constant })
  link("@constant.builtin", "Constant")
  link("@constant.macro", "PreProc")
  set("@string", { fg = p.string })
  link("@string.escape", "@string")
  set("@string.special", { fg = p.string_special })
  link("@string.special.symbol", "Constant")
  link("@string.special.url", "@markup.link.url")
  link("@string.documentation", "@comment.documentation")
  if p.regexp_bg then
    set("@string.regexp", { fg = p.regexp, bg = p.regexp_bg })
  else
    set("@string.regexp", { fg = p.regexp })
  end
  link("@character", "String")
  link("@number", "Number")
  link("@boolean", "Boolean")
  link("@float", "Float")

  set("@variable", { fg = p.variable })
  set("@variable.builtin", { fg = p.keyword_meta })
  set("@variable.parameter", { fg = p.variable })
  set("@variable.parameter.builtin", { fg = p.keyword_meta })
  set("@variable.member", { fg = p.variable })
  set("@property", { fg = p.variable })

  set("@function", { fg = p.fn, bold = true })
  set("@function.builtin", { fg = p.fn })
  set("@function.call", { fg = p.fn })
  set("@function.method", { fg = p.fn, bold = true })
  set("@function.method.call", { fg = p.fn })
  link("@function.macro", "PreProc")
  set("@constructor", { fg = p.type, bold = true })

  set("@type", { fg = p.type, bold = true })
  set("@type.builtin", { fg = p.type_builtin })
  set("@type.definition", { fg = p.type, bold = true })
  set("@type.qualifier", { fg = p.type_builtin })
  set("@storageclass", { fg = p.type_builtin })
  set("@attribute", { fg = p.annotation })
  set("@attribute.builtin", { fg = p.annotation })

  set("@label", { fg = p.keyword_meta })
  set("@punctuation.delimiter", { fg = p.muted })
  set("@punctuation.bracket", { fg = p.muted })
  set("@punctuation.special", { fg = p.muted })
  link("@operator", "Operator")

  set("@keyword", { fg = p.keyword })
  set("@keyword.control", { fg = p.keyword_control })
  set("@keyword.function", { fg = p.keyword })
  set("@keyword.operator", { fg = p.operator })
  set("@keyword.import", { fg = p.keyword })
  set("@keyword.export", { fg = p.keyword })
  set("@keyword.coroutine", { fg = p.keyword })
  set("@keyword.type", { fg = p.keyword })
  set("@keyword.modifier", { fg = p.keyword })
  set("@keyword.directive", { fg = p.annotation })
  set("@keyword.directive.define", { fg = p.annotation })
  set("@keyword.debug", { fg = p.keyword })
  set("@keyword.repeat", { fg = p.keyword_control })
  set("@keyword.return", { fg = p.keyword_control })
  set("@keyword.exception", { fg = p.keyword_control })
  set("@keyword.conditional", { fg = p.keyword_control })
  link("@exception", "@keyword")

  link("@module", "@type.builtin")
  link("@namespace", "@type.builtin")
  link("@symbol", "Constant")
  link("@include", "@keyword")
  link("@preproc", "PreProc")
  link("@define", "PreProc")
  link("@debug", "Constant")

  set("@tag", { fg = p.tag })
  link("@tag.builtin", "@tag")
  set("@tag.attribute", { fg = p.attribute })
  set("@tag.delimiter", { fg = p.muted })

  ----------------------------------------------------------------
  -- Markup (markdown, help, text)
  ----------------------------------------------------------------
  set("@markup.heading", { fg = p.fn, bold = true })
  for _, level in ipairs({ "1", "2", "3", "4", "5", "6" }) do
    local opts = { fg = p.fn, bold = true }
    if level == "1" or level == "2" then
      opts.bg = p.heading_bg
    end
    set("@markup.heading." .. level, opts)
  end

  set("@markup.strong", { bold = true })
  set("@markup.italic", { italic = true })
  set("@markup.strikethrough", { fg = p.muted, strikethrough = true })
  set("@markup.list", { fg = p.bullet, bold = true })
  set("@markup.list.checked", { fg = p.ok })
  set("@markup.list.unchecked", { fg = p.comment })
  set("@markup.link", { fg = p.fn })
  set("@markup.link.label", { fg = p.fn })
  set("@markup.link.url", { fg = p.muted })
  set("@markup.quote", { fg = p.comment })
  set("@markup.raw", { bg = p.markup_bg })
  set("@markup.raw.block", { bg = p.markup_bg })
  set("@markup.raw.markdown_inline", { bg = p.markup_bg })
  set("@markup.math", { fg = p.type_builtin })
  set("@markup.environment", { fg = p.tag })
  link("@text.title", "@markup.heading")
  link("@text.literal", "@markup.raw")
  link("@text.uri", "@markup.link.url")
  link("@text.reference", "@markup.link")
  set("@text.emphasis", { italic = true })
  set("@text.strong", { bold = true })
  set("@text.strike", { strikethrough = true })

  ----------------------------------------------------------------
  -- Diff captures
  ----------------------------------------------------------------
  set("@diff.plus", { fg = p.string })
  set("@diff.minus", { fg = p.danger })
  set("@diff.delta", { fg = p.warn })

  ----------------------------------------------------------------
  -- LSP semantic tokens: routed back to the same syntax roles
  ----------------------------------------------------------------
  link("@lsp.type.class", "@type")
  link("@lsp.type.comment", "@comment")
  link("@lsp.type.decorator", "@attribute")
  link("@lsp.type.enum", "@type")
  link("@lsp.type.enumMember", "@constant")
  link("@lsp.type.function", "@function.call")
  link("@lsp.type.interface", "@type")
  link("@lsp.type.keyword", "@keyword")
  link("@lsp.type.macro", "@preproc")
  link("@lsp.type.method", "@function.method.call")
  link("@lsp.type.namespace", "@namespace")
  link("@lsp.type.number", "@number")
  link("@lsp.type.operator", "@operator")
  link("@lsp.type.parameter", "@variable.parameter")
  link("@lsp.type.property", "@property")
  link("@lsp.type.string", "@string")
  link("@lsp.type.struct", "@type")
  link("@lsp.type.type", "@type")
  link("@lsp.type.typeParameter", "@type")
  link("@lsp.type.variable", "@variable")
  link("@lsp.type.builtinType", "@type.builtin")
  link("@lsp.type.selfKeyword", "@variable.builtin")
  set("@lsp.mod.deprecated", { fg = p.comment })
  set("@lsp.mod.unnecessary", { fg = p.comment })
  link("@lsp.typemod.variable.readonly", "@constant")

  set("LspReferenceText", { bg = p.cursorline })
  set("LspReferenceRead", { bg = p.cursorline })
  set("LspReferenceWrite", { bg = p.cursorline })
  set("LspCodeLens", { fg = p.comment })
  set("LspSignatureActiveParameter", { bg = p.matchparen_bg })
  link("LspInfoBorder", "FloatBorder")

  ----------------------------------------------------------------
  -- Plugin surfaces
  ----------------------------------------------------------------
  -- VS Code bracket-pair colors (editorBracketHighlight.foreground1..6).
  set("RainbowDelimiterRed", { fg = p.bracket[1] })
  set("RainbowDelimiterBlue", { fg = p.bracket[2] })
  set("RainbowDelimiterGreen", { fg = p.bracket[3] })
  set("RainbowDelimiterYellow", { fg = p.bracket[4] })
  set("RainbowDelimiterOrange", { fg = p.bracket[5] })
  set("RainbowDelimiterViolet", { fg = p.bracket[6] })
  for i, color in ipairs(p.bracket) do
    set("rainbowcol" .. i, { fg = color })
  end

  set("IblIndent", { fg = p.indent })
  set("IblWhitespace", { fg = p.indent })
  set("IblScope", { fg = p.border })

  ----------------------------------------------------------------
  -- Embedded terminal: resolved source anchors
  ----------------------------------------------------------------
  if config.terminal_colors then
    for i, color in ipairs(p.terminal) do
      vim.g["terminal_color_" .. (i - 1)] = color
    end
    vim.g.terminal_color_foreground = p.terminal_fg
    vim.g.terminal_color_background = p.terminal_bg
    vim.g.terminal_color_cursor = p.terminal_cursor
  else
    for i = 0, 15 do
      vim.g["terminal_color_" .. i] = nil
    end
    vim.g.terminal_color_foreground = nil
    vim.g.terminal_color_background = nil
    vim.g.terminal_color_cursor = nil
  end

  ----------------------------------------------------------------
  -- Decoration allowlist enforcement. Keep the source's bold/italic
  -- treatments; strip everything else inherited from Neovim's defaults.
  ----------------------------------------------------------------
  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if not hl.link then
      local changed = false
      for attr, allowed in pairs(M.DECORATIONS) do
        if not allowed[name] and (hl[attr] or (hl.cterm and hl.cterm[attr])) then
          hl[attr] = nil
          if hl.cterm then
            hl.cterm[attr] = nil
            if next(hl.cterm) == nil then
              hl.cterm = nil
            end
          end
          changed = true
        end
      end
      for _, attr in ipairs({ "underdouble", "underdotted", "underdashed" }) do
        if hl[attr] or (hl.cterm and hl.cterm[attr]) then
          hl[attr] = nil
          if hl.cterm then
            hl.cterm[attr] = nil
            if next(hl.cterm) == nil then
              hl.cterm = nil
            end
          end
          changed = true
        end
      end
      if changed then
        vim.api.nvim_set_hl(0, name, hl)
      end
    end
  end
end

return M
