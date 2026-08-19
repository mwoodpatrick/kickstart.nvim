-- ============================================================
-- FORMATTING
-- [conform.nvim](https://github.com/stevearc/conform.nvim) setup and keymap
-- ============================================================

return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    -- Conform will notify you when a formatter errors
    notify_on_error = true,
    -- Conform will notify you when no formatters are available for the buffer
    notify_no_formatters = true,
    -- If this is set, Conform will run the formatter asynchronously after save.
    -- It will pass the table to conform.format().
    -- This can also be a function that returns the table.
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      bash = { 'shfmt' },
      css = { 'prettier' },
      html = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      -- Conform will run the first available formatter
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      lua = { 'stylua' },
      markdown = { 'prettier' },
      nix = { 'nixfmt' },
      -- Conform will run multiple formatters sequentially
      python = { 'isort', 'black' },
      -- You can customize some of the format options for the filetype (:help conform.format)
      rust = { 'rustfmt', lsp_format = 'fallback' },
      sh = { 'shfmt' },
      typescript = { 'prettier' },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end
