local M = {}

local vim = vim
local zig_comp_diag_ns = vim.api.nvim_create_namespace('zig_comp_diag')
local utils = require('zig-comp-diag.utils')

local prev_comp_diag_by_bufnr = {}
M.runWithCmd = function(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if handle == nil then
    print("Failed to run command: " .. vim.g.zig_comp_diag_cmd)
    return
  end
  local output_string = handle:read("*a")
  handle:close()

  local comp_diag_by_bufnr = {}
  for line in output_string:gmatch("[^\r\n]+") do
    -- because lua doesn't have continue statement :(
    local file_name, remain1 = utils.splitStringAtDelimiter(line, ":")
    if remain1 ~= nil then
      local lnum, remain2 = utils.splitStringAtDelimiter(remain1, ":")
      if remain2 ~= nil then
        local col, remain3 = utils.splitStringAtDelimiter(remain2, ":")
        if remain3 ~= nil then
          local severity, message = utils.splitStringAtDelimiter(remain3, ":")
          if message ~= nil then
            -- buffer number from file name
            local bufnr = tonumber(vim.fn.bufadd(file_name))
            vim.fn.bufload(bufnr)

            -- initialize the table for buffer number if it doesn't exist
            if comp_diag_by_bufnr[bufnr] == nil then
              comp_diag_by_bufnr[bufnr] = {}
            end

            -- add diagnostic for bufnr
            table.insert(comp_diag_by_bufnr[bufnr], {
              bufnr = bufnr,
              lnum = tonumber(lnum) - 1,
              col = tonumber(col),
              severity = utils.toVimSeverity(severity),
              message = message,
            })
          end
        end
      end
    end
  end

  -- reset old diagnostics
  for bufnr, _ in pairs(prev_comp_diag_by_bufnr) do
    if comp_diag_by_bufnr[bufnr] == nil then
      vim.diagnostic.reset(zig_comp_diag_ns, bufnr)
    end
  end

  -- set new diagnostics
  for bufnr, diagnostics in pairs(comp_diag_by_bufnr) do
    vim.diagnostic.set(zig_comp_diag_ns, bufnr, diagnostics, {})
  end

  -- save old diagnostics
  prev_comp_diag_by_bufnr = comp_diag_by_bufnr
end

return M
