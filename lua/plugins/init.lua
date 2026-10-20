-- vim.print 'Hello from plugins'

-- ~/.config/nvim/lua/plugins/init.lua
local M = {}

local plugin_modules = {
  'plugins.ui', --  control how the cmdline, messages, and pager work
  'plugins.tree', -- Add a file explorer (Written In Lua)
  'plugins.snacks', -- A collection of small QoL plugins for Neovim
  'plugins.search', -- Fuzzy finder over lists. keymaps, LSP picker mappings
  'plugins.treesitter', -- Parser installation, syntax highlighting, folds, indentation
  'plugins.lsp', -- LSP keymaps, server configuration, Mason tools installations
  'plugins.formatting', -- Lightweight yet powerful formatter plugin for Neovim
  'plugins.completions', -- completion plugin with support for LSPs, cmdline, signature help, and snippets.
  'plugins.markdown', -- improve viewing Markdown files in Neovim
  'plugins.obsidian', -- Edit Obsidian files
  'plugins.opencode', -- Integrates with OpenCode the open source agent
  'plugins.minuet-ai', -- AI-powered code completion
  'plugins.codecompanion', -- AI coding assistant for coding with LLMs
  'plugins.example', -- An example plugin
  'plugins.dap', -- Install the debugger plugin stack
  'plugins.lean' -- Support for the Lean Theorem Prover
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
