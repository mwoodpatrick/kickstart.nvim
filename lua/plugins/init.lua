-- vim.print 'Hello from plugins'

-- ~/.config/nvim/lua/plugins/init.lua
local M = {}

local plugin_modules = {
  -- "plugins.treesitter",
  'plugins.tree',
  'plugins.codecompanion',
  'plugins.treesitter',
  'plugins.example',
}

function M.setup()
  for _, mod in ipairs(plugin_modules) do
    local ok, config_fn = pcall(require, mod)
    if ok and type(config_fn) == 'function' then
      config_fn()
      -- vim.print('loading plugin ' .. mod .. ' complete')
    else
      vim.print('loading plugin ' .. mod .. ' failed')
    end
  end
end

M.setup()
-- print 'plugin setup completed'
-- print 'Calling example setup'
-- require("example").setup({})
-- print 'After Calling example setup'
return M -- ~/.config/nvim/lua/plugins/init.lua
