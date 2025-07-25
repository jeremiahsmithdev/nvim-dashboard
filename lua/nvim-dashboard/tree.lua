local M = {}

local utils = require('nvim-dashboard.utils')

local tree_data = {}

function M.populate(buf, path)
  tree_data = {}
  local lines = {}
  
  local items = utils.get_files_and_dirs(path)
  
  table.insert(lines, '📁 ' .. vim.fn.fnamemodify(path, ':t'))
  table.insert(tree_data, {
    path = path,
    type = 'directory',
    level = 0,
    expanded = true,
  })
  
  for _, item in ipairs(items) do
    local icon = item.type == 'directory' and '📂' or '📄'
    local line = '  ' .. icon .. ' ' .. item.name
    
    table.insert(lines, line)
    table.insert(tree_data, {
      path = item.path,
      type = item.type,
      level = 1,
      expanded = false,
      name = item.name,
    })
  end
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

function M.get_item_at_cursor()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1]
  
  if line_num > #tree_data then
    return nil
  end
  
  return tree_data[line_num]
end

function M.expand_directory(buf, item)
  if item.type ~= 'directory' or item.expanded then
    return
  end
  
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num = cursor[1]
  
  local items = utils.get_files_and_dirs(item.path)
  local new_lines = {}
  local new_data = {}
  
  for i, line_item in ipairs(tree_data) do
    if i == line_num then
      line_item.expanded = true
      table.insert(new_data, line_item)
      
      for _, sub_item in ipairs(items) do
        local icon = sub_item.type == 'directory' and '📂' or '📄'
        local indent = string.rep('  ', item.level + 1)
        local line = indent .. icon .. ' ' .. sub_item.name
        
        table.insert(new_lines, line)
        table.insert(new_data, {
          path = sub_item.path,
          type = sub_item.type,
          level = item.level + 1,
          expanded = false,
          name = sub_item.name,
        })
      end
    else
      table.insert(new_data, line_item)
    end
  end
  
  tree_data = new_data
  
  local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i = #new_lines, 1, -1 do
    table.insert(all_lines, line_num + 1, new_lines[i])
  end
  
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, all_lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

return M