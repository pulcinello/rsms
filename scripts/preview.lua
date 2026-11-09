-- Generates an HTML style preview using the exact rendered palette values.
-- Run from the repo root:
--   nvim --clean --headless -l scripts/preview.lua
-- Output: /tmp/rsms-preview/preview.html
-- If scripts/preview.sh is used, Chrome also writes assets/preview.png.

local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(root)
local palettes = require("rsms.palette")

local out_dir = "/tmp/rsms-preview"
vim.fn.mkdir(out_dir, "p")

local function esc(s)
  return (s:gsub("[<>&]", { ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" }))
end

local function t(cls, text)
  return ('<span class="%s">%s</span>'):format(cls, esc(text))
end

local function line(n, body, extra)
  return ('<div class="line%s"><span class="num">%d</span><span class="code">%s</span></div>')
    :format(extra and (" " .. extra) or "", n, body)
end

local lua_lines = {
  line(1, t("com", "-- rsms: muted chrome, loud code")),
  line(2, t("kw", "local") .. " " .. t("var", "M") .. " " .. t("punct", "=") .. " " .. t("punct", "{}")),
  line(3, ""),
  line(4, t("kw", "local") .. " " .. t("const", "DEFAULTS") .. " " .. t("punct", "=") .. " " .. t("punct", "{")
    .. t("var", "depth") .. " " .. t("punct", "=") .. " " .. t("const", "3") .. t("punct", ",")
    .. " " .. t("var", "verbose") .. " " .. t("punct", "=") .. " " .. t("const", "false") .. t("punct", "}")),
  line(5, ""),
  line(6, t("com", "--- Collect reachable nodes from the root.")),
  line(7, t("kw", "function") .. " " .. t("var", "M") .. t("punct", ".") .. t("fn", "collect")
    .. t("punct", "(") .. t("var", "root") .. t("punct", ",") .. " " .. t("var", "opts") .. t("punct", ")")),
  line(8, "  " .. t("var", "opts") .. " " .. t("punct", "=") .. " " .. t("var", "vim") .. t("punct", ".")
    .. t("fn", "tbl_extend") .. t("punct", "(") .. t("str", '"force"') .. t("punct", ",") .. " "
    .. t("const", "DEFAULTS") .. t("punct", ",") .. " " .. t("var", "opts") .. " " .. t("kw", "or")
    .. " " .. t("punct", "{}") .. t("punct", ")")),
  line(9, "  " .. t("kc", "if") .. " " .. t("var", "opts") .. t("punct", ".") .. t("var", "depth")
    .. " " .. t("op", "<=") .. " " .. t("const", "0") .. " " .. t("kc", "then"), "cursorline"),
  line(10, "    " .. t("kc", "return") .. " " .. t("punct", "{}")),
  line(11, "  " .. t("kc", "end")),
  line(12, "  " .. t("kw", "local") .. " " .. t("var", "seen") .. t("punct", ",") .. " " .. t("var", "queue")
    .. " " .. t("punct", "=") .. " " .. t("punct", "{}") .. t("punct", ",") .. " " .. t("punct", "{") .. " "
    .. t("var", "root") .. " " .. t("punct", "}")),
  line(13, "  " .. t("kc", "while") .. " " .. t("op", "#") .. t("var", "queue") .. " " .. t("op", ">")
    .. " " .. t("const", "0") .. " " .. t("kc", "do")),
  line(14, "    " .. t("kw", "local") .. " " .. t("var", "node") .. " " .. t("punct", "=") .. " "
    .. t("var", "table") .. t("punct", ".") .. t("fn", "remove") .. t("punct", "(") .. t("var", "queue")
    .. t("punct", ",") .. " " .. t("const", "1") .. t("punct", ")")),
  line(15, "    " .. t("kc", "if") .. " " .. t("kw", "not") .. " " .. t("var", "seen") .. t("punct", "[")
    .. t("var", "node") .. t("punct", ".") .. t("var", "id") .. t("punct", "]") .. " " .. t("kc", "then")),
  line(16, "      " .. t("var", "seen") .. t("punct", "[") .. t("var", "node") .. t("punct", ".")
    .. t("var", "id") .. t("punct", "]") .. " " .. t("punct", "=") .. " " .. t("const", "true")),
  line(17, "      " .. t("kc", "for") .. " " .. t("punct", "_") .. t("punct", ",") .. " " .. t("var", "edge")
    .. " " .. t("kw", "in") .. " " .. t("fn", "ipairs") .. t("punct", "(") .. t("var", "node")
    .. t("punct", ".") .. t("var", "edges") .. t("punct", ")") .. " " .. t("kc", "do")),
  line(18, "        " .. t("var", "queue") .. t("punct", "[") .. t("op", "#") .. t("var", "queue")
    .. " " .. t("op", "+") .. " " .. t("const", "1") .. t("punct", "]") .. " " .. t("punct", "=") .. " "
    .. t("var", "edge") .. t("punct", ".") .. t("var", "target")),
  line(19, "      " .. t("kc", "end")),
  line(20, "    " .. t("kc", "end")),
  line(21, "  " .. t("kc", "end")),
  line(22, "  " .. t("kc", "return") .. " " .. t("var", "seen")),
  line(23, t("kc", "end")),
  line(24, ""),
  line(25, t("kc", "return") .. " " .. t("var", "M")),
}

local ts_lines = {
  line(1, t("com", "// Types are bold; calls stay quiet.")),
  line(2, t("kw", "export") .. " " .. t("kw", "interface") .. " " .. t("type", "Cache") .. t("punct", "<")
    .. t("type", "T") .. t("punct", ">") .. " " .. t("punct", "{")),
  line(3, "  " .. t("fn", "get") .. t("punct", "(") .. t("var", "key") .. t("punct", ":") .. " "
    .. t("tb", "string") .. t("punct", "):") .. " " .. t("type", "T") .. " " .. t("op", "|") .. " "
    .. t("tb", "undefined")),
  line(4, "  " .. t("fn", "set") .. t("punct", "(") .. t("var", "key") .. t("punct", ":") .. " "
    .. t("tb", "string") .. t("punct", ",") .. " " .. t("var", "value") .. t("punct", ":") .. " "
    .. t("type", "T") .. t("punct", "):") .. " " .. t("tb", "void")),
  line(5, t("punct", "}")),
  line(6, ""),
  line(7, t("kw", "export") .. " " .. t("kw", "class") .. " " .. t("type", "BoundedCache")
    .. t("punct", "<") .. t("type", "T") .. t("punct", ">") .. " " .. t("kw", "implements") .. " "
    .. t("type", "Cache") .. t("punct", "<") .. t("type", "T") .. t("punct", ">") .. " " .. t("punct", "{")),
  line(8, "  " .. t("kw", "private") .. " " .. t("var", "entries") .. " " .. t("punct", "=") .. " "
    .. t("kw", "new") .. " " .. t("type", "Map") .. t("punct", "<") .. t("tb", "string")
    .. t("punct", ",") .. " " .. t("type", "T") .. t("punct", ">()")),
  line(9, ""),
  line(10, "  " .. t("kw", "constructor") .. t("punct", "(") .. t("kw", "private") .. " "
    .. t("kw", "readonly") .. " " .. t("var", "limit") .. t("punct", ":") .. " " .. t("tb", "number")
    .. " " .. t("punct", "=") .. " " .. t("const", "16") .. t("punct", ")") .. " " .. t("punct", "{}"),
    "cursorline"),
  line(11, ""),
  line(12, "  " .. t("fn", "get") .. t("punct", "(") .. t("var", "key") .. t("punct", ":") .. " "
    .. t("tb", "string") .. t("punct", "):") .. " " .. t("type", "T") .. " " .. t("op", "|") .. " "
    .. t("tb", "undefined") .. " " .. t("punct", "{")),
  line(13, "    " .. t("kc", "return") .. " " .. t("var", "this") .. t("punct", ".") .. t("var", "entries")
    .. t("punct", ".") .. t("fn", "get") .. t("punct", "(") .. t("var", "key") .. t("punct", ")")),
  line(14, "  " .. t("punct", "}")),
  line(15, ""),
  line(16, "  " .. t("fn", "set") .. t("punct", "(") .. t("var", "key") .. t("punct", ":") .. " "
    .. t("tb", "string") .. t("punct", ",") .. " " .. t("var", "value") .. t("punct", ":") .. " "
    .. t("type", "T") .. t("punct", "):") .. " " .. t("tb", "void") .. " " .. t("punct", "{")),
  line(17, "    " .. t("kc", "if") .. " " .. t("var", "this") .. t("punct", ".") .. t("var", "entries")
    .. t("punct", ".") .. t("var", "size") .. " " .. t("op", ">=") .. " " .. t("var", "this")
    .. t("punct", ".") .. t("var", "limit") .. " " .. t("punct", "{")),
  line(18, "      " .. t("kw", "const") .. " " .. t("var", "oldest") .. " " .. t("punct", "=") .. " "
    .. t("var", "this") .. t("punct", ".") .. t("var", "entries") .. t("punct", ".")
    .. t("fn", "keys") .. t("punct", "().") .. t("fn", "next") .. t("punct", "().") .. t("var", "value")),
  line(19, "      " .. t("var", "this") .. t("punct", ".") .. t("var", "entries") .. t("punct", ".")
    .. t("fn", "delete") .. t("punct", "(") .. t("var", "oldest") .. t("punct", ")")),
  line(20, "    " .. t("punct", "}")),
  line(21, "    " .. t("var", "this") .. t("punct", ".") .. t("var", "entries") .. t("punct", ".")
    .. t("fn", "set") .. t("punct", "(") .. t("var", "key") .. t("punct", ",") .. " " .. t("var", "value")
    .. t("punct", ")")),
  line(22, "  " .. t("punct", "}")),
  line(23, t("punct", "}")),
}

local md_lines = {
  line(1, '<span class="heading">rsms.nvim</span>', "heading"),
  line(2, ""),
  line(3, "A " .. t("strong", "faithful Neovim port") .. " of the "
    .. t("link", "rsms color themes") .. "."),
  line(4, ""),
  line(5, '<span class="heading2">Highlights</span>', "heading"),
  line(6, ""),
  line(7, " " .. t("bullet", "-") .. " Keywords are " .. t("inline-code", "steel blue") .. " or "
    .. t("inline-code", "indigo") .. ", strings are " .. t("inline-code", "green") .. "."),
  line(8, " " .. t("bullet", "-") .. " Types and functions are " .. t("strong", "bold") .. " like the source."),
  line(9, " " .. t("bullet", "-") .. " Chrome recedes; " .. t("em", "code carries the color") .. "."),
  line(10, ""),
  line(11, t("quote", "> AstroTurf is not a sport.")),
}

local function css(id, p)
  return ([[
#%(id)s {
  --bg: %(bg)s; --fg: %(fg)s; --comment: %(comment)s; --muted: %(muted)s;
  --keyword: %(keyword)s; --kcontrol: %(kcontrol)s; --fn: %(fn)s;
  --type: %(type)s; --tbuiltin: %(tbuiltin)s; --string: %(string)s;
  --constant: %(constant)s; --variable: %(variable)s; --op: %(operator)s;
  --cursorline: %(cursorline)s; --linenr: %(linenr)s; --border: %(border)s;
  --selection: %(selection)s; --selection-fg: %(selection_fg)s;
  --heading-bg: %(heading_bg)s; --markup-bg: %(markup_bg)s;
  --bullet: %(bullet)s; --statusline: %(statusline)s; --link: %(link)s;
}]])
    :gsub("%%%(([%w_]+)%)s", {
      id = id, bg = p.bg, fg = p.fg, comment = p.comment, muted = p.muted,
      keyword = p.keyword, kcontrol = p.keyword_control, fn = p.fn,
      type = p.type, tbuiltin = p.type_builtin, string = p.string,
      constant = p.constant, variable = p.variable, operator = p.operator,
      cursorline = p.cursorline, linenr = p.linenr, border = p.border,
      selection = p.selection, selection_fg = p.selection_fg,
      heading_bg = p.heading_bg, markup_bg = p.markup_bg, bullet = p.bullet,
      statusline = p.statusline, link = p.fn,
    })
end

local tpl = [[<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>rsms.nvim preview</title>
<style>
  * { box-sizing: border-box; }
  body { margin: 0; background: #202020; color: #ddd;
         font-family: ui-monospace, "JetBrains Mono", "SF Mono", monospace;
         display: flex; gap: 24px; padding: 24px; align-items: flex-start; }
  .variant { flex: 1; border-radius: 8px; overflow: hidden;
             border: 1px solid #3a3a3a; }
  .bar { display: flex; justify-content: space-between; align-items: center;
         padding: 8px 14px; background: var(--statusline); color: var(--fg);
         font-size: 12px; letter-spacing: 0.04em; }
  .bar .mode { font-weight: bold; }
  .bar .name { opacity: 0.75; }
  .panel { background: var(--bg); color: var(--fg); padding: 14px 0 18px; }
  .pane { padding: 0 0 10px; }
  .pane + .pane { border-top: 1px solid var(--border); padding-top: 12px; margin-top: 4px; }
  .pane h2 { margin: 0 16px 8px; font-size: 11px; font-weight: normal;
             color: var(--comment); letter-spacing: 0.1em; text-transform: uppercase; }
  .line { display: flex; line-height: 1.5; font-size: 13.5px; white-space: pre; }
  .line.cursorline { background: var(--cursorline); }
  .line.heading { background: var(--heading-bg); }
  .num { width: 44px; text-align: right; padding-right: 14px; color: var(--linenr);
         user-select: none; flex: none; }
  .code { padding-right: 16px; }
  .com { color: var(--comment); } .kw { color: var(--keyword); }
  .kc { color: var(--kcontrol); } .fn { color: var(--fn); font-weight: bold; }
  .type { color: var(--type); font-weight: bold; } .tb { color: var(--tbuiltin); }
  .str { color: var(--string); } .const { color: var(--constant); }
  .var { color: var(--variable); } .op { color: var(--op); }
  .punct { color: var(--muted); }
  .heading { color: var(--fn); font-weight: bold; }
  .heading2 { color: var(--fn); font-weight: bold; }
  .strong { font-weight: bold; }
  .em { font-style: italic; }
  .inline-code { background: var(--markup-bg); }
  .link { color: var(--link); }
  .bullet { color: var(--bullet); font-weight: bold; }
  .quote { color: var(--comment); }
  .selection { background: var(--selection); color: var(--selection-fg); }
@@CSS@@
</style>
</head>
<body>
@@BODY@@
</body>
</html>]]

local function variant_block(id, label, lua, ts, md)
  return ([[
<div class="variant">
  <div id="%(id)s">
    <div class="bar"><span class="mode">NORMAL</span><span class="name">%(label)s &nbsp;·&nbsp; lua &nbsp;·&nbsp; utf-8</span></div>
    <div class="panel">
      <div class="pane"><h2>Lua</h2>
        %(lua)s
      </div>
      <div class="pane"><h2>TypeScript</h2>
        %(ts)s
      </div>
      <div class="pane"><h2>Markdown</h2>
        %(md)s
      </div>
    </div>
  </div>
</div>]])
    :gsub("%%%(([%w_]+)%)s", { id = id, label = label, lua = lua, ts = ts, md = md })
end

local css_all = css("dark", palettes.dark) .. css("bright", palettes.bright)
local body = variant_block("dark", "rsms dark", table.concat(lua_lines, "\n"),
  table.concat(ts_lines, "\n"), table.concat(md_lines, "\n"))
  .. variant_block("bright", "rsms bright", table.concat(lua_lines, "\n"),
    table.concat(ts_lines, "\n"), table.concat(md_lines, "\n"))

local html = tpl:gsub("@@CSS@@", function() return css_all end)
html = html:gsub("@@BODY@@", function() return body end)

local path = out_dir .. "/preview.html"
local f = assert(io.open(path, "w"))
f:write(html)
f:close()
print("wrote " .. path)
