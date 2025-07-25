local M = {}

function M.has_nvim_tree()
  -- Check if nvim-tree is available by looking for its commands
  return vim.fn.exists(':NvimTreeOpen') > 0
end

function M.is_nvim_tree_open()
  if not M.has_nvim_tree() then
    return false
  end
  
  -- Check if any buffer has nvim-tree filetype
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      if ft == 'NvimTree' then
        -- Check if this buffer is visible in any window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == buf then
            return true
          end
        end
      end
    end
  end
  
  return false
end

function M.disable_nvim_tree_hijacking()
  if not M.has_nvim_tree() then
    return false
  end
  
  -- Store original values if they exist
  local original_hijack = vim.g.nvim_tree_hijack_netrw
  local original_disable = vim.g.nvim_tree_disable_netrw
  
  -- Disable nvim-tree hijacking
  vim.g.nvim_tree_hijack_netrw = 0
  vim.g.nvim_tree_disable_netrw = 0
  
  return {
    restore = function()
      vim.g.nvim_tree_hijack_netrw = original_hijack
      vim.g.nvim_tree_disable_netrw = original_disable
    end
  }
end

function M.replace_nvim_tree_with_dashboard(path)
  if not M.has_nvim_tree() then
    return false
  end
  
  local success = false
  
  -- Check if nvim-tree is currently open
  if M.is_nvim_tree_open() then
    -- Close nvim-tree using command
    pcall(function()
      vim.cmd('NvimTreeClose')
    end)
    success = true
  end
  
  -- Also check and close any nvim-tree buffers
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
    -- Switch to the tree window
    vim.api.nvim_set_current_win(tree_win)
    
    -- Change to the target directory
    vim.cmd('cd ' .. vim.fn.fnameescape(path))
    
    -- Open nvim-tree in the current window
    vim.cmd('NvimTreeOpen')
    
    -- Set window options
    vim.api.nvim_win_set_option(tree_win, 'winfixwidth', true)
  end)
  
  return success
end

function M.close_nvim_tree()
  if not M.has_nvim_tree() then
    return
  end
  
  pcall(function()
    vim.cmd('NvimTreeClose')
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