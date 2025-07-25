local M = {}

local tree = require('nvim-dashboard.tree')
local state_module = require('nvim-dashboard.state')

function M.open_file()
  local state = state_module.get()
  
  if state.using_nvim_tree then
    return
  end
  
  local item = tree.get_item_at_cursor()
  
  if not item then
    return
  end
  
  if item.type == 'directory' then
    if item.expanded then
      return
    end
    
    local buf = vim.api.nvim_get_current_buf()
    tree.expand_directory(buf, item)
  else
    if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
      vim.api.nvim_set_current_win(state.main_win)
      vim.cmd('edit ' .. item.path)
    end
  end
end

return M