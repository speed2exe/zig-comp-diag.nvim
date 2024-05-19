local M = {}

local vim = vim
local zig_comp_diag_ns = vim.api.nvim_create_namespace('zig_comp_diag')
local utils = require('zig-comp-diag.utils')
local last_cmd = nil

local cur_comp_diag_by_bufnr = {}
local function on_stderr(_, output_lines, _)
  -- local comp_diag_by_bufnr = {}
  for _, line in ipairs(output_lines) do
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
            if cur_comp_diag_by_bufnr[bufnr] == nil then
              cur_comp_diag_by_bufnr[bufnr] = {}
            end

            -- add diagnostic for bufnr
            table.insert(cur_comp_diag_by_bufnr[bufnr], {
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
end

local function on_exit(_, exit_code, _)
  -- set the diagnostics for each buffer
  for bufnr, diagnostics in pairs(cur_comp_diag_by_bufnr) do
    vim.diagnostic.set(zig_comp_diag_ns, bufnr, diagnostics, {})
  end

  -- clear the table
  cur_comp_diag_by_bufnr = {}
  print("job (" .. table.concat(last_cmd, " ") .. ") exited with exit code: " .. exit_code)
end

M.runWithCmd = function(cmd)
  -- clear all diagnostics for the namespace
  vim.diagnostic.reset(zig_comp_diag_ns)
  vim.fn.jobstart(cmd, {
    on_stderr = on_stderr,
    on_exit = on_exit,
    stdout_buffered = true,
    stderr_buffered = true,
  })
  last_cmd = cmd
end

return M
