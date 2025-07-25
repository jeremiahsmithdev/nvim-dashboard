local M = {}

local tree = require('nvim-dashboard.tree')
local dashboard = require('nvim-dashboard.dashboard')

function M.open_file()
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
    local state = dashboard.get_state()
    if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
      vim.api.nvim_set_current_win(state.main_win)
      vim.cmd('edit ' .. item.path)
    end
  end
end

function M.close_dashboard()
  dashboard.close()
end

return M