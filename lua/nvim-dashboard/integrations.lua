local M = {}

function M.has_nvim_tree()
  -- Check for the main module and the specific submodules we need
  local ok_main = pcall(require, 'nvim-tree')
  if not ok_main then
    return false
  end
  
  local ok_api = pcall(require, 'nvim-tree.api')
  if not ok_api then
    return false
  end
  
  local ok_view = pcall(require, 'nvim-tree.view')
  if not ok_view then
    return false
  end
  
  return true
end

function M.is_nvim_tree_open()
  if not M.has_nvim_tree() then
    return false
  end
  
  local success, result = pcall(function()
    local nvim_tree_view = require('nvim-tree.view')
    return nvim_tree_view.is_visible()
  end)
  
  return success and result
end

function M.disable_nvim_tree_hijacking()
  if not M.has_nvim_tree() then
    return false
  end
  
  -- Store original values
  local original_values = {}
  
  pcall(function()
    local nvim_tree_config = require('nvim-tree.config')
    original_values.hijack_netrw = nvim_tree_config.hijack_netrw
    original_values.disable_netrw = nvim_tree_config.disable_netrw
  end)
  
  -- Aggressively disable nvim-tree hijacking through multiple methods
  vim.g.nvim_tree_hijack_netrw = 0
  vim.g.nvim_tree_disable_netrw = 0
  
  -- Try to modify the loaded config
  pcall(function()
    local nvim_tree = require('nvim-tree')
    local config = require('nvim-tree.config')
    
    -- Temporarily modify config
    config.hijack_netrw = false
    config.disable_netrw = false
    
    -- Force a config update if possible
    if nvim_tree.setup then
      nvim_tree.setup({
        hijack_netrw = false,
        disable_netrw = false,
      })
    end
  end)
  
  -- Disable autocommands if they exist
  pcall(function()
    vim.api.nvim_del_augroup_by_name('nvim-tree')
  end)
  
  return {
    restore = function()
      vim.g.nvim_tree_hijack_netrw = original_values.hijack_netrw and 1 or 0
      vim.g.nvim_tree_disable_netrw = original_values.disable_netrw and 1 or 0
    end
  }
end

function M.replace_nvim_tree_with_dashboard(path)
  if not M.has_nvim_tree() then
    return false
  end
  
  local success = false
  
  -- Try multiple methods to detect and close nvim-tree
  pcall(function()
    local nvim_tree_view = require('nvim-tree.view')
    local nvim_tree_api = require('nvim-tree.api')
    
    if nvim_tree_view.is_visible() then
      nvim_tree_api.tree.close()
      success = true
    end
  end)
  
  -- Also check current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_filetype = vim.api.nvim_buf_get_option(current_buf, 'filetype')
  
  if buf_filetype == 'NvimTree' then
    pcall(function()
      vim.api.nvim_buf_delete(current_buf, { force = true })
    end)
    success = true
  end
  
  -- Check all buffers for nvim-tree
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      if ft == 'NvimTree' then
        pcall(function()
          vim.api.nvim_buf_delete(buf, { force = true })
        end)
        success = true
      end
    end
  end
  
  if success then
    vim.schedule(function()
      local dashboard = require('nvim-dashboard')
      dashboard.open(path)
    end)
    return true
  end
  
  return false
end

function M.setup_nvim_tree(tree_win, path)
  if not M.has_nvim_tree() then
    return false
  end
  
  local success = pcall(function()
    local nvim_tree_api = require('nvim-tree.api')
    local nvim_tree_view = require('nvim-tree.view')
    
    vim.api.nvim_set_current_win(tree_win)
    
    nvim_tree_api.tree.open({
      path = path,
      current_window = true,
    })
    
    vim.api.nvim_win_set_option(tree_win, 'winfixwidth', true)
  end)
  
  return success
end

function M.close_nvim_tree()
  if not M.has_nvim_tree() then
    return
  end
  
  pcall(function()
    local nvim_tree_api = require('nvim-tree.api')
    nvim_tree_api.tree.close()
  end)
end

function M.get_nvim_tree_config()
  if not M.has_nvim_tree() then
    return nil
  end
  
  return {
    disable_netrw = false,
    hijack_netrw = false,
    open_on_tab = false,
    hijack_cursor = false,
    update_cwd = false,
    respect_buf_cwd = true,
    view = {
      width = 30,
      side = 'left',
      preserve_window_proportions = false,
      number = false,
      relativenumber = false,
      signcolumn = 'yes',
    },
    renderer = {
      add_trailing = false,
      group_empty = false,
      highlight_git = false,
      highlight_opened_files = 'none',
      root_folder_modifier = ':~',
      indent_markers = {
        enable = false,
      },
      icons = {
        webdev_colors = true,
        git_placement = 'before',
        padding = ' ',
        symlink_arrow = ' ➛ ',
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    filters = {
      dotfiles = false,
      custom = {},
      exclude = {},
    },
  }
end

return M