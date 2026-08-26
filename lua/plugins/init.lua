-- vim.print 'Hello from plugins'

-- ~/.config/nvim/lua/plugins/init.lua
local M = {}

local plugin_modules = {
  'plugins.ui',
  'plugins.tree',
  'plugins.snacks',
  'plugins.search',
  'plugins.treesitter',
  'plugins.lsp',
  'plugins.formatting',
  'plugins.completions',
  'plugins.markdown',
  'plugins.obsidian',
  'plugins.opencode',
  'plugins.codecompanion',
  'plugins.example',
  'plugins.dap',
}

function M.setup()
  for _, mod in ipairs(plugin_modules) do
    local ok, result = pcall(require, mod)
    if ok and type(result) == 'function' then
      result()
    elseif ok then
      vim.print('loading plugin ' .. mod .. ' skipped: module did not return a function')
    else
      vim.print('loading plugin ' .. mod .. ' failed: ' .. tostring(result))
    end
  end
end

M.setup()
-- print 'plugin setup completed'
-- print 'Calling example setup'
-- require("example").setup({})
-- print 'After Calling example setup'
return M -- ~/.config/nvim/lua/plugins/init.lua
