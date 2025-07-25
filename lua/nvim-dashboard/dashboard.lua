local M = {}

local utils = require('nvim-dashboard.utils')
local tree = require('nvim-dashboard.tree')
local state_module = require('nvim-dashboard.state')

function M.create(path, config)
  local state = state_module.get()
  state_module.set('path', path)
  
  vim.cmd('tabnew')
  state_module.set('main_win', vim.api.nvim_get_current_win())
  state_module.set('main_buf', vim.api.nvim_create_buf(false, true))
  vim.api.nvim_win_set_buf(state.main_win, state.main_buf)
  
  vim.api.nvim_buf_set_option(state.main_buf, 'filetype', 'dashboard')
  vim.api.nvim_buf_set_option(state.main_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(state.main_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(state.main_buf, 'swapfile', false)
  vim.api.nvim_win_set_option(state.main_win, 'number', false)
  vim.api.nvim_win_set_option(state.main_win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.main_win, 'cursorline', false)
  
  if config.show_tree then
    M.create_tree_window(config)
  end
  
  if config.show_readme then
    M.create_readme_window(config)
  else
    M.show_project_info()
  end
  
  M.setup_keymaps()
end

function M.create_tree_window(config)
  local state = state_module.get()
  vim.cmd('topleft vertical ' .. config.tree_width .. 'split')
  state_module.set('tree_win', vim.api.nvim_get_current_win())
  state_module.set('tree_buf', vim.api.nvim_create_buf(false, true))
  vim.api.nvim_win_set_buf(state.tree_win, state.tree_buf)
  
  vim.api.nvim_buf_set_option(state.tree_buf, 'filetype', 'dashboard-tree')
  vim.api.nvim_buf_set_option(state.tree_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(state.tree_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(state.tree_buf, 'swapfile', false)
  vim.api.nvim_win_set_option(state.tree_win, 'number', false)
  vim.api.nvim_win_set_option(state.tree_win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.tree_win, 'winfixwidth', true)
  
  tree.populate(state.tree_buf, state.path)
  
  vim.api.nvim_win_set_cursor(state.tree_win, {1, 0})
  vim.api.nvim_set_current_win(state.main_win)
end

function M.create_readme_window(config)
  local state = state_module.get()
  local readme_path = utils.find_readme(state.path)
  
  if readme_path then
    vim.cmd('edit ' .. readme_path)
    state_module.set('readme_buf', vim.api.nvim_get_current_buf())
    vim.api.nvim_buf_set_option(state.readme_buf, 'readonly', true)
    vim.api.nvim_buf_set_option(state.readme_buf, 'modifiable', false)
  else
    M.show_project_info()
  end
end

function M.show_project_info()
  local state = state_module.get()
  local lines = {
    '',
    '  📁 ' .. vim.fn.fnamemodify(state.path, ':t'),
    '',
    '  📂 Project Dashboard',
    '',
    '  Path: ' .. state.path,
    '',
    '  No README found in this directory.',
    '',
    '  Navigation:',
    '    • Use the file tree on the left to browse files',
    '    • Press <CR> to open files/folders',
    '    • Press q to close the dashboard',
    '',
  }
  
  vim.api.nvim_buf_set_lines(state.main_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.main_buf, 'modifiable', false)
end

function M.setup_keymaps()
  local state = state_module.get()
  local opts = { noremap = true, silent = true }
  
  if state.tree_buf then
    vim.api.nvim_buf_set_keymap(state.tree_buf, 'n', '<CR>', '<cmd>lua require("nvim-dashboard.navigation").open_file()<CR>', opts)
    vim.api.nvim_buf_set_keymap(state.tree_buf, 'n', 'o', '<cmd>lua require("nvim-dashboard.navigation").open_file()<CR>', opts)
  end
  
  for _, buf in ipairs({state.main_buf, state.tree_buf, state.readme_buf}) do
    if buf then
      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>lua require("nvim-dashboard").close()<CR>', opts)
    end
  end
end

function M.close()
  local state = state_module.get()
  if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
    vim.api.nvim_win_close(state.main_win, true)
  end
  
  state_module.reset()
end

function M.get_state()
  return state_module.get()
end

return M