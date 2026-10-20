-- AI-powered code completion
-- [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)
return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  -- Defer native package loading until Neovim has booted its UI completely
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      -- 1. Register native packages safely on boot
      vim.pack.add { { src = gh 'milanglacier/minuet-ai.nvim' } }

      -- 2. Safely load and configure CodeCompanion after environment is ready
      local status_ok, minuet = pcall(require, 'minuet')

      if not status_ok then
        vim.notify('Minuet plugin not found in runtime path!', vim.log.levels.WARN, { title = 'Minuet' })
        return
      end

      minuet.setup {
        provider = 'openai_fim_compatible',
        n_completions = 1, -- recommend for local model for resource saving
        -- I recommend beginning with a small context window size and incrementally
        -- expanding it, depending on your local computing power. A context window
        -- of 512, serves as an good starting point to estimate your computing
        -- power. Once you have a reliable estimate of your local computing power,
        -- you should adjust the context window to a larger value.
        context_window = 512,
        provider_options = {
          openai_fim_compatible = {
            -- For Windows users, TERM may not be present in environment variables.
            -- Consider using APPDATA instead.
            api_key = 'TERM',
            name = 'Ollama',
            end_point = 'http://localhost:11434/v1/completions',
            model = 'qwen2.5-coder:7b',
            optional = {
              max_tokens = 56,
              top_p = 0.9,
            },
            -- stream = true,
          },
          --           virtualtext = {
          --             auto_trigger_ft = { 'lean', 'nix', 'lua', 'python' },
          --             keymap = {
          --               accept = '<A-a>',
          --               accept_line = '<A-l>',
          --               prev = '<A-[>',
          --               next = '<A-]>',
          --               dismiss = '<A-e>',
          --             },
          --           },
        },
        lsp = {
          enabled_ft = { 'toml', 'lua', 'cpp' },
          completion = {
            -- Enables automatic completion triggering using `vim.lsp.completion.enable`
            enabled_auto_trigger_ft = { 'cpp', 'lua' },
          },
        },
      }
    end,
  })
end
