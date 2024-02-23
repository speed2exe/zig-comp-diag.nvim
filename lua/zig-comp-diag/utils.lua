local vim = vim

local M = {}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.to_vim_severity = function(zig_comp_severity_untrimmed)
  local zig_comp_severity = trim(zig_comp_severity_untrimmed)
  if zig_comp_severity == "error" then
    return vim.diagnostic.severity.ERROR
  elseif zig_comp_severity == "warn" then
    return vim.diagnostic.severity.WARN
  elseif zig_comp_severity == "note" then
    return vim.diagnostic.severity.INFO
  elseif zig_comp_severity == "hint" then
    return vim.diagnostic.severity.HINT
  else
    print("Unknown severity: " .. zig_comp_severity)
    return vim.diagnostic.severity.INFO
  end
end

return M
