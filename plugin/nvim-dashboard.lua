if vim.g.loaded_nvim_dashboard then
  return
end
vim.g.loaded_nvim_dashboard = 1

local dashboard = require('nvim-dashboard')

vim.api.nvim_create_user_command('Dashboard', function()
  dashboard.open()
end, {})

vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    local args = vim.fn.argv()
    if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
      vim.schedule(function()
        dashboard.open(args[1])
      end)
    end
  end,
})