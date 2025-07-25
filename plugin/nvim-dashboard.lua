if vim.g.loaded_nvim_dashboard then
  return
end
vim.g.loaded_nvim_dashboard = 1

local dashboard = require('nvim-dashboard')
local integrations = require('nvim-dashboard.integrations')

-- Create augroup for our autocommands
local augroup = vim.api.nvim_create_augroup('NvimDashboard', { clear = true })

vim.api.nvim_create_user_command('Dashboard', function(opts)
  local path = opts.args ~= '' and opts.args or vim.fn.getcwd()
  dashboard.open(path)
end, { nargs = '?' })

-- Very early hook to disable nvim-tree before it can activate
vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  group = augroup,
  callback = function()
    local config = dashboard.get_config()
    if config.hijack_directories then
      -- Aggressively disable nvim-tree hijacking
      vim.g.nvim_tree_hijack_netrw = 0
      vim.g.nvim_tree_disable_netrw = 0
      if vim.g.loaded_nvim_tree then
        pcall(function()
          require('nvim-tree').setup({
            hijack_netrw = false,
            disable_netrw = false,
          })
        end)
      end
    end
  end,
})

-- Primary VimEnter handler with multiple fallback strategies
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  group = augroup,
  nested = true,
  callback = function()
    local args = vim.fn.argv()
    if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
      local config = dashboard.get_config()
      if not config.hijack_directories then
        return
      end
      
      local path = args[1]
      
      -- Immediate attempt
      dashboard.open(path)
      
      -- Multiple delayed attempts to catch nvim-tree hijacking
      vim.schedule(function()
        if integrations.replace_nvim_tree_with_dashboard(path) then
          return
        end
        
        -- Check if we need to open dashboard
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_name = vim.api.nvim_buf_get_name(current_buf)
        local buf_filetype = vim.api.nvim_buf_get_option(current_buf, 'filetype')
        
        if buf_filetype == 'NvimTree' or 
           buf_name == '' or 
           vim.fn.isdirectory(buf_name) == 1 then
          dashboard.open(path)
        end
      end)
      
      -- Even more delayed attempt
      vim.defer_fn(function()
        if integrations.replace_nvim_tree_with_dashboard(path) then
          return
        end
        
        local current_buf = vim.api.nvim_get_current_buf()
        local buf_filetype = vim.api.nvim_buf_get_option(current_buf, 'filetype')
        
        if buf_filetype == 'NvimTree' then
          dashboard.open(path)
        end
      end, 50)
    end
  end,
})

-- Monitor for nvim-tree opening and immediately replace it
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  group = augroup,
  callback = function()
    local config = dashboard.get_config()
    if not config.hijack_directories then
      return
    end
    
    vim.schedule(function()
      local args = vim.fn.argv()
      local path
      
      if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
        path = args[1]
      else
        path = vim.fn.getcwd()
      end
      
      if integrations.replace_nvim_tree_with_dashboard(path) then
        return
      end
      
      -- Force close nvim-tree and open dashboard
      vim.cmd('silent! bdelete!')
      dashboard.open(path)
    end)
  end,
})

-- BufEnter handler for directory navigation
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*',
  group = augroup,
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
            return
          elseif vim.bo.filetype == 'netrw' then
            dashboard.open(buf_name)
          end
        end)
      end
    end
  end,
})

-- Additional safety net - monitor all buffer creations
vim.api.nvim_create_autocmd('BufNew', {
  pattern = '*',
  group = augroup,
  callback = function()
    local config = dashboard.get_config()
    if not config.hijack_directories then
      return
    end
    
    vim.schedule(function()
      local buf_filetype = vim.bo.filetype
      if buf_filetype == 'NvimTree' then
        local current_buf = vim.api.nvim_get_current_buf()
        local args = vim.fn.argv()
        local path
        
        if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
          path = args[1]
        else
          path = vim.fn.getcwd()
        end
        
        vim.api.nvim_buf_delete(current_buf, { force = true })
        dashboard.open(path)
      end
    end)
  end,
})