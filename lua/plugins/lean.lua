-- https://github.com/Julian/lean.nvim

return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { gh 'Julian/lean.nvim' }

  vim.g.lean_config = {
    mappings = true, -- enables default <LocalLeader> keybindings
    infoview = {
      autoopen = true,
      width = 50,
      horizontal_position = 'bottom',
    },
    abbreviations = {
      enable = true, -- enables \to -> →, \le -> ≤, etc.
    },
    lsp = {
      enable = true,
    },
  }
end
