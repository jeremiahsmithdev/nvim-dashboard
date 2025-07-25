local M = {}

function M.has_nvim_tree()
  local ok, _ = pcall(require, 'nvim-tree')
  return ok
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