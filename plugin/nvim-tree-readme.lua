if vim.g.loaded_nvim_tree_readme then
  return
end
vim.g.loaded_nvim_tree_readme = 1

-- Check if nvim-tree is available
if vim.fn.exists(':NvimTreeOpen') == 0 then
  vim.notify('nvim-tree-readme: nvim-tree is required but not found', vim.log.levels.ERROR)
  return
end

local readme_opener = require('nvim-tree-readme')

-- Watch for nvim-tree opening and auto-open README
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'NvimTree',
  callback = function()
    -- Small delay to let nvim-tree fully load
    vim.defer_fn(function()
      readme_opener.open_readme()
    end, 100)
  end,
})