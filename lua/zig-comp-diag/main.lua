local M = {}

local vim = vim

local zig_comp_diag_ns = vim.api.nvim_create_namespace('zig_comp_diag')

local utils = require('zig-comp-diag.utils')

local prev_comp_diag_by_bufnr = {}
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
        severity = utils.to_vim_severity(line_diag[4]),
        message = line_diag[5],
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
