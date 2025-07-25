local M = {}

local state = {
  main_buf = nil,
  tree_buf = nil,
  readme_buf = nil,
  main_win = nil,
  tree_win = nil,
  readme_win = nil,
  path = nil,
  using_nvim_tree = false,
}

function M.get()
  return state
end

function M.set(key, value)
  state[key] = value
end

function M.reset()
  state.main_buf = nil
  state.tree_buf = nil
  state.readme_buf = nil
  state.main_win = nil
  state.tree_win = nil
  state.readme_win = nil
  state.path = nil
  state.using_nvim_tree = false
end

return M