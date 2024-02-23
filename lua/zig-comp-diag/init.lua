local vim = vim

local M = {}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function to_vim_severity(severity)
  if severity == "error" then
    return vim.diagnostic.severity.ERROR
  elseif severity == "warn" then
    return vim.diagnostic.severity.WARN
  elseif severity == "note" then
    return vim.diagnostic.severity.INFO
  elseif severity == "hint" then
    return vim.diagnostic.severity.HINT
  else
    print("Unknown severity: " .. severity)
    return vim.diagnostic.severity.INFO
  end
end

-- Zig Compiler Plugin
local zig_comp_diag_ns = vim.api.nvim_create_namespace('zig_comp_diag')

-- Default Command without specifying based on current file
local function zig_comp_diag_cmd()
  -- local file_name = vim.fn.expand("%:p")
  return "zig build"
end

local prev_comp_diag_by_bufnr = {}

-- infer by current buffer file name
-- traverse back directory to find zig.build file
-- if zig.build file is found, use `zig build`
M.run = function()
  local cmd = zig_comp_diag_cmd()
  M.runWithCmd(cmd)
end

M.runWithCmd = function(cmd)
  local handle = io.popen(cmd.." 2>&1")
  if handle == nil then
    print("Failed to run command: " .. vim.g.zig_comp_diag_cmd)
    return
  end
  local output_string = handle:read("*a")
  handle:close()

  local comp_diag_by_bufnr = {}
  for line in output_string:gmatch("[^\r\n]+") do
    local line_diag = {}
    for word in string.gmatch(line, "[^:]+") do
        table.insert(line_diag, word)
    end
    if #line_diag == 5 then
      local bufnr = tonumber(vim.fn.bufadd(line_diag[1]))
      if comp_diag_by_bufnr[bufnr] == nil then
        comp_diag_by_bufnr[bufnr] = {}
      end

      table.insert(comp_diag_by_bufnr[bufnr], {
        bufnr = bufnr,
        lnum = tonumber(line_diag[2])-1,
        col = tonumber(line_diag[3]),
        severity = to_vim_severity(trim(line_diag[4])),
        message = trim(line_diag[5]),
      })
    end
  end

  for bufnr, _ in pairs(prev_comp_diag_by_bufnr) do
    if comp_diag_by_bufnr[bufnr] == nil then
      vim.diagnostic.reset(zig_comp_diag_ns, bufnr)
    end
  end

  for bufnr, diagnostics in pairs(comp_diag_by_bufnr) do
    vim.diagnostic.set(zig_comp_diag_ns, bufnr, diagnostics, {})
  end
  prev_comp_diag_by_bufnr = comp_diag_by_bufnr
end

return M
