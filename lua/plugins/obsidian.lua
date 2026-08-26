return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { gh 'obsidian-nvim/obsidian.nvim' }
  require('obsidian').setup {
    legacy_commands = false, -- Disable deprecated top-level global aliases
    workspaces = {
      {
        name = 'personal',
        -- FIXME: adjust to your local vault path
        path = '~/obsidian/vaults/personal',
      },
    },
    -- Optional: mappings, note ID formatting, etc.
    daily_notes = {
      folder = 'notes/dailies',
      date_format = '%Y-%m-%d',
    },
    ui = {
      enable = false, -- Disables obsidian's UI engine to hand full control to render-markdown
    },
  }

  -- Obsidian quick actions (Example bindings)
  -- vim.keymap.set('n', '<leader>of', '<cmd>ObsidianQuickSwitch<CR>', opts)
  -- vim.keymap.set('n', '<leader>ot', '<cmd>ObsidianToday<CR>', opts)
end
