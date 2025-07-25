if vim.g.loaded_nvim_dashboard then
  return
end
vim.g.loaded_nvim_dashboard = 1

local dashboard = require('nvim-dashboard')
local integrations = require('nvim-dashboard.integrations')

vim.api.nvim_create_user_command('Dashboard', function(opts)
  local path = opts.args ~= '' and opts.args or vim.fn.getcwd()
  dashboard.open(path)
end, { nargs = '?' })

-- Early autocommand to try preventing nvim-tree hijacking
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    local args = vim.fn.argv()
    if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
      local config = dashboard.get_config()
      if not config.hijack_directories then
        return
      end
      
      local path = args[1]
      
      -- Try to disable nvim-tree hijacking temporarily
      local restore_hijacking = integrations.disable_nvim_tree_hijacking()
      
      -- Immediate attempt to open dashboard
      dashboard.open(path)
      
      -- Delayed check to handle nvim-tree hijacking
      vim.schedule(function()
        -- Check if nvim-tree opened instead and replace it
        if integrations.replace_nvim_tree_with_dashboard(path) then
          -- nvim-tree was replaced successfully
        else
          -- Ensure dashboard is open if nothing else happened
          local current_buf = vim.api.nvim_get_current_buf()
          local buf_name = vim.api.nvim_buf_get_name(current_buf)
          if buf_name == '' or vim.fn.isdirectory(buf_name) == 1 then
            dashboard.open(path)
          end
        end
        
        -- Restore nvim-tree hijacking settings
        if restore_hijacking and restore_hijacking.restore then
          restore_hijacking.restore()
        end
      end)
    end
  end,
})

-- Additional autocommand for BufEnter to catch directory navigation
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  callback = function()
    local config = dashboard.get_config()
    if not config.hijack_directories then
      return
    end
    
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= '' and vim.fn.isdirectory(buf_name) == 1 then
      -- Only trigger if this is a manual directory navigation, not startup
      if vim.v.vim_did_enter == 1 then
        vim.schedule(function()
          if integrations.replace_nvim_tree_with_dashboard(buf_name) then
            -- nvim-tree was replaced
          elseif vim.bo.filetype == 'netrw' then
            -- Replace netrw with dashboard
            dashboard.open(buf_name)
          end
        end)
      end
    end
  end,
})