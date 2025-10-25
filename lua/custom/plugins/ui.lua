return {
  -- https://github.com/EdenEast/nightfox.nvim
  {
    'EdenEast/nightfox.nvim',
    priority = 1000,
    init = function()
      -- vim.opt.background = 'light'
      vim.cmd.colorscheme 'dayfox'
    end,
  },

  -- https://github.com/romgrk/barbar.nvim
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    config = function()
      require('barbar').setup {
        -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
        -- animation = true,
        -- insert_at_start = true,
        -- …etc.
      }

      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<leader>q', ':BufferClose<CR>', opts)
      vim.keymap.set('n', '<leader>Q', ':BufferClose!<CR>', opts)
      vim.keymap.set('n', '<leader>b', ':BufferPick<CR>', opts)
      vim.keymap.set('n', '<leader>ga', ':BufferMovePrevious<CR>', opts)
      vim.keymap.set('n', '<leader>gd', ':BufferMoveNext<CR>', opts)
      vim.keymap.set('n', '<leader>gA', ':BufferMoveStart<CR>', opts)
      vim.keymap.set('n', 'gt', ':BufferNext<CR>', opts)
      vim.keymap.set('n', 'gT', ':BufferPrevious<CR>', opts)
    end,
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
  },

  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    config = function()
      require('neo-tree').setup {}
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<leader>ft', ':Neotree toggle<CR>', opts)
      vim.keymap.set('n', '<leader>ff', ':Neotree reveal<CR>', opts)
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
      '3rd/image.nvim', -- Optional image support in preview window: See `# Preview Mode` for more information
    },
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },

  -- https://github.com/nvim-treesitter/nvim-treesitter-context
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {}
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<leader>tc', ':TSContext toggle<CR>', opts)
    end,
  },
}
