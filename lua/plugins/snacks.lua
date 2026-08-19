return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  -- [snacks.nvim](https://github.com/folke/snacks.nvim/tree/main#-snacksnvim)
  vim.pack.add { gh 'folke/snacks.nvim' }
  -- ==========================================
  -- Snacks.nvim Native Configuration
  -- ==========================================
  require('snacks').setup {
    bigfile = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    scroll = { enabled = true },

    -- [picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)
    picker = { enabled = true },

    -- [terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md)
    terminal = {
      enabled = true,
      -- Optional shell configuration (defaults to your system $SHELL)
      shell = vim.o.shell,
      -- Window appearance options for floating terminals
      win = {
        style = 'float',
        border = 'rounded',
        width = 0.8,
        height = 0.8,
      },
    },
  }

  -- ==========================================
  -- Optional Keymaps for Snacks Modules
  -- ==========================================
  -- Define Snacks as a global variable reference to ensure lua_ls knows about it
  _G.Snacks = _G.Snacks or {}
  local map = vim.keymap.set

  -- Toggle scratch buffer
  map('n', '<leader>z', function() Snacks.scratch() end, { desc = 'Toggle Scratch Buffer' })

  -- Find files using Snacks picker
  map('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Snacks Find Files' })

  -- Live grep text search
  map('n', '<leader>fw', function() Snacks.picker.grep() end, { desc = 'Snacks Live Grep' })

  -- View notification history
  map('n', '<leader>n', function() Snacks.notifier.show_history() end, { desc = 'Notification History' })

  vim.keymap.set(
    'n',
    '<leader>ta',
    function()
      Snacks.terminal('aider --model ollama_chat/gemma4', {
        win = {
          style = 'float',
          border = 'rounded',
          width = 0.85,
          height = 0.85,
        },
      })
    end,
    { desc = 'Run Aider in Snacks Terminal' }
  )
end
