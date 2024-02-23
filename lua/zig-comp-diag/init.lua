local vim = vim
local M = {}

local main = require('zig-comp-diag.main')

-- TODO: Maybe there's a smarter to infer the zig build command?
local function zig_comp_diag_cmd()
  return { "zig", "build" }
end

-- Lua API
-- require('zig-comp-diag').run()
M.run = function()
  local cmd = zig_comp_diag_cmd()
  M.runWithCmd(cmd)
end
-- require('zig-comp-diag').runWithCmd({ "zig", "build" })
M.runWithCmd = main.runWithCmd

-- User command
-- :ZigCompDiag
-- :ZigCompDiag zig build
vim.api.nvim_create_user_command('ZigCompDiag', function(opts)
  local args = opts.fargs
  if #opts.fargs > 0 then
    main.runWithCmd(args)
  else
    main.runWithCmd(zig_comp_diag_cmd())
  end
end, { nargs = '?' })

return M
