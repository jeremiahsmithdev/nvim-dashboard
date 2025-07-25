local M = {}

function M.find_readme(path)
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
  
  for _, pattern in ipairs(readme_patterns) do
    local readme_path = path .. '/' .. pattern
    if vim.fn.filereadable(readme_path) == 1 then
      return readme_path
    end
  end
  
  return nil
end

function M.get_files_and_dirs(path)
  local items = {}
  local handle = vim.loop.fs_scandir(path)
  
  if not handle then
    return items
  end
  
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    
    if not name:match('^%.') then
      table.insert(items, {
        name = name,
        path = path .. '/' .. name,
        type = type,
      })
    end
  end
  
  table.sort(items, function(a, b)
    if a.type ~= b.type then
      return a.type == 'directory'
    end
    return a.name < b.name
  end)
  
  return items
end

function M.center_window(width, height)
  local screen_w = vim.o.columns
  local screen_h = vim.o.lines - vim.o.cmdheight
  
  local window_w = math.ceil(screen_w * width)
  local window_h = math.ceil(screen_h * height)
  
  local center_x = (screen_w - window_w) / 2
  local center_y = ((vim.o.lines - window_h) / 2) - vim.o.cmdheight
  
  return {
    width = window_w,
    height = window_h,
    col = center_x,
    row = center_y,
  }
end

return M