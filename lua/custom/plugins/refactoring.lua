return {
  -- https://github.com/numToStr/Comment.nvim
  -- "gc" to comment visual regions/lines
  {
    'numToStr/Comment.nvim',
    opts = {},
  },
  -- https://github.com/smjonas/inc-rename.nvim
  -- LSP renaming with preview
  {
    'smjonas/inc-rename.nvim',
    config = function()
      require('inc_rename').setup()
      vim.keymap.set('n', '<leader>rn', ':IncRename ')
    end,
  },
  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  {
    -- config is in treesitter module
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  -- https://github.com/kylechui/nvim-surround
  -- ys to surround, cs to change surround
  {
    'kylechui/nvim-surround',
    version = '*',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },
}
