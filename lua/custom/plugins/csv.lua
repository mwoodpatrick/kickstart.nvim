-- https://github.com/emmanueltouzery/decisive.nvim
return {
  {
    'emmanueltouzery/decisive.nvim',
    config = function()
      require('decisive').setup{}
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<leader>cca', function() require('decisive').align_csv({}) end, opts)
      vim.keymap.set('n', '<leader>ccA', function() require('decisive').align_csv_clear({}) end, opts)
      vim.keymap.set('n', '[c', require('decisive').align_csv_prev_col, opts)
      vim.keymap.set('n', ']c', require('decisive').align_csv_next_col, opts)
    end,
    lazy = true,
    ft = { 'csv' },
  },
  {
    'cameron-wags/rainbow_csv.nvim',
    config = function()
      require('rainbow_csv').setup()
      -- Disable column notifications
      vim.g.disable_rainbow_hover = 1
    end,
    ft = {
      'csv',
    },
    cmd = {
        'RainbowDelim',
        'RainbowDelimSimple',
        'RainbowDelimQuoted',
        'RainbowMultiDelim'
    },
  },
}
