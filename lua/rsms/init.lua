local M = {}

M.config = {
  terminal_colors = true,
}

local ALLOWED = { terminal_colors = true }

function M.setup(opts)
  opts = opts or {}
  for key, value in pairs(opts) do
    if not ALLOWED[key] then
      error(("rsms: unknown option %q (transparent is intentionally unsupported)"):format(key))
    end
    if type(value) ~= "boolean" then
      error(("rsms: option %q must be a boolean"):format(key))
    end
    M.config[key] = value
  end
end

--- Resolve the variant for a load. `variant` may be "dark", "bright", or nil
--- to follow 'background'.
function M.resolve(variant)
  if variant == nil then
    return vim.o.background == "light" and "bright" or "dark"
  end
  if variant ~= "dark" and variant ~= "bright" then
    error(("rsms: unknown variant %q (expected dark or bright)"):format(tostring(variant)))
  end
  return variant
end

function M.load(variant)
  local name = M.resolve(variant)

  if vim.g.colors_name then
    vim.cmd("highlight clear")
  end
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.termguicolors = true
  vim.o.background = name == "bright" and "light" or "dark"
  -- Mirror the colorscheme entry point: "rsms" follows 'background', while
  -- the explicit entries report themselves.
  vim.g.colors_name = variant and ("rsms-" .. name) or "rsms"

  require("rsms.highlights").apply(name, M.config)
end

return M
