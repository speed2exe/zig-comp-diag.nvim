local vim = vim

local M = {}

local source = require('zig-comp-diag.main')

-- Guess the zig build command
local function zig_comp_diag_cmd()
  -- local file_name = vim.fn.expand("%:p")
  return "zig build"
end

M.run = function()
  local cmd = zig_comp_diag_cmd()
  M.runWithCmd(cmd)
end

M.runWithCmd = source.runWithCmd

return M
