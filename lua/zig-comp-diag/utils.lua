local vim = vim

local M = {}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

M.toVimSeverity = function(zigCompSeverityUntrimmed)
  local zigCompSeverity = trim(zigCompSeverityUntrimmed)
  if zigCompSeverity == "error" then
    return vim.diagnostic.severity.ERROR
  elseif zigCompSeverity == "warn" then
    return vim.diagnostic.severity.WARN
  elseif zigCompSeverity == "note" then
    return vim.diagnostic.severity.INFO
  elseif zigCompSeverity == "hint" then
    return vim.diagnostic.severity.HINT
  else
    print("Unknown severity: " .. zigCompSeverity)
    return vim.diagnostic.severity.INFO
  end
end

M.splitStringAtDelimiter = function(str, delimiter)
  local delimiterPos = string.find(str, delimiter, 1, true)
  if delimiterPos then
    local firstPart = string.sub(str, 1, delimiterPos - 1)
    local remainingPart = string.sub(str, delimiterPos + 1)
    return firstPart, remainingPart
  else
    return str, nil
  end
end

return M
