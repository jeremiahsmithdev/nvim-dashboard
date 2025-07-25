local M = {}

-- Common README file patterns to search for
local readme_patterns = {
  'README.md',
  'readme.md',
  'README.rst',
  'readme.rst',
  'README.txt',
  'readme.txt',
  'README',
  'readme'
}

-- Find README file in the given directory
local function find_readme_file(directory)
  for _, pattern in ipairs(readme_patterns) do
    local readme_path = directory .. '/' .. pattern
    if vim.fn.filereadable(readme_path) == 1 then
      return readme_path
    end
  end
  return nil
end

-- Get the current nvim-tree root directory
local function get_nvim_tree_root()
  -- Try to get nvim-tree root directory
  local success, result = pcall(function()
    local nvim_tree_api = require('nvim-tree.api')
    local tree = nvim_tree_api.tree.get_node_under_cursor()
    if tree and tree.absolute_path then
      -- If it's a file, get its directory
      if vim.fn.isdirectory(tree.absolute_path) == 1 then
        return tree.absolute_path
      else
        return vim.fn.fnamemodify(tree.absolute_path, ':h')
      end
    end
    
    -- Fallback: get nvim-tree cwd
    return require('nvim-tree.core.init').get_cwd()
  end)
  
  if success and result then
    return result
  end
  
  -- Final fallback: current working directory
  return vim.fn.getcwd()
end

-- Open README file if found
function M.open_readme()
  local tree_root = get_nvim_tree_root()
  local readme_path = find_readme_file(tree_root)
  
  if not readme_path then
    return -- No README found, do nothing
  end
  
  -- Find a suitable window to open the README
  local nvim_tree_win = nil
  local other_win = nil
  
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')
    
    if filetype == 'NvimTree' then
      nvim_tree_win = win
    elseif filetype ~= 'NvimTree' then
      other_win = win
    end
  end
  
  -- If there's already a non-nvim-tree window, use it
  if other_win then
    vim.api.nvim_set_current_win(other_win)
    vim.cmd('edit ' .. vim.fn.fnameescape(readme_path))
  else
    -- Create a new split for the README
    vim.cmd('vsplit ' .. vim.fn.fnameescape(readme_path))
  end
end

return M