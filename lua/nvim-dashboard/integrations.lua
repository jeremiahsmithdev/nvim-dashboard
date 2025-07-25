local M = {}

function M.has_nvim_tree()
  local ok, _ = pcall(require, 'nvim-tree')
  return ok
end

function M.is_nvim_tree_open()
  if not M.has_nvim_tree() then
    return false
  end
  
  local nvim_tree_view = require('nvim-tree.view')
  return nvim_tree_view.is_visible()
end

function M.disable_nvim_tree_hijacking()
  if not M.has_nvim_tree() then
    return false
  end
  
  local nvim_tree_config = require('nvim-tree.config')
  local original_hijack_netrw = nvim_tree_config.hijack_netrw
  local original_disable_netrw = nvim_tree_config.disable_netrw
  
  if original_hijack_netrw or original_disable_netrw then
    vim.g.nvim_tree_hijack_netrw = 0
    vim.g.nvim_tree_disable_netrw = 0
    
    return {
      restore = function()
        vim.g.nvim_tree_hijack_netrw = original_hijack_netrw and 1 or 0
        vim.g.nvim_tree_disable_netrw = original_disable_netrw and 1 or 0
      end
    }
  end
  
  return false
end

function M.replace_nvim_tree_with_dashboard(path)
  if not M.has_nvim_tree() then
    return false
  end
  
  local nvim_tree_view = require('nvim-tree.view')
  local nvim_tree_api = require('nvim-tree.api')
  
  if nvim_tree_view.is_visible() then
    nvim_tree_api.tree.close()
    
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
  
  local nvim_tree_api = require('nvim-tree.api')
  local nvim_tree_view = require('nvim-tree.view')
  
  vim.api.nvim_set_current_win(tree_win)
  
  nvim_tree_api.tree.open({
    path = path,
    current_window = true,
  })
  
  vim.api.nvim_win_set_option(tree_win, 'winfixwidth', true)
  
  return true
end

function M.close_nvim_tree()
  if not M.has_nvim_tree() then
    return
  end
  
  local nvim_tree_api = require('nvim-tree.api')
  nvim_tree_api.tree.close()
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