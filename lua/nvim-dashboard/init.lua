local M = {}

local dashboard = require('nvim-dashboard.dashboard')
local utils = require('nvim-dashboard.utils')

local config = {
  width = 0.8,
  height = 0.8,
  show_tree = true,
  show_readme = true,
  tree_width = 30,
  hijack_directories = true,  -- Take over directory opening from nvim-tree/netrw
}

function M.setup(opts)
  config = vim.tbl_extend('force', config, opts or {})
end

function M.open(path)
  local target_path = path or vim.fn.getcwd()
  
  if vim.fn.isdirectory(target_path) == 0 then
    vim.notify('Not a directory: ' .. target_path, vim.log.levels.ERROR)
    return
  end
  
  dashboard.create(target_path, config)
end

function M.close()
  dashboard.close()
end

function M.get_config()
  return config
end

return M