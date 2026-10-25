-- ============================================================
-- AUTOCOMPLETE & SNIPPETS
-- completion plugin with support for LSPs, cmdline, signature help, and snippets.
-- [blink.cmp](https://github.com/Saghen/blink.cmp)
-- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
-- ============================================================

return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  -- [[ Snippet Engine ]]

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add {
    'https://github.com/saghen/blink.lib',
    'https://github.com/saghen/blink.cmp',
    'https://github.com/L3MON4D3/LuaSnip',
    'https://github.com/rafamadriz/friendly-snippets',
    'https://github.com/milanglacier/minuet-ai.nvim',
  }

  -- [LuaSnip Config-Options](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#config-options)
  require('luasnip').setup {
    history = true,
    delete_check_events = 'TextChanged',
    update_events = 'TextChanged,InsertLeave',
  }

  -- Load the friendly-snippets collection into LuaSnip
  require('luasnip.loaders.from_vscode').lazy_load()

  -- AI-powered code completion
  -- [minuet-ai.nvim](https://github.com/milanglacier/minuet-ai.nvim)
  -- [Configuration](https://github.com/milanglacier/minuet-ai.nvim#configuration)
  require('minuet').setup {
    -- Silences Minuet's warning advising against running as an
    -- in-process LSP when a completion engine is detected
    warn_on_blink_or_cmp = false,
    -- format requests using standard OpenAI /v1/chat/completions payloads.
    provider = 'openai_compatible',

    provider_options = {
      openai_compatible = {
        model = 'qwen2.5-coder:7b',
        -- Directs requests to my local Ollama server's
        -- OpenAI-compatible bridge
        end_point = 'http://localhost:11434/v1/chat/completions',
        -- Provide a dummy string to satisfy the non-empty API key
        -- requirement since we using a local model
        api_key = 'TERM',
        -- Enables token streaming for faster initial response times
        stream = true,
      },
    },
  }

  local cmp = require 'blink.cmp'

  cmp.setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',

      -- Manually invoke minuet completion.
      ['<A-y>'] = require('minuet').make_blink_map(),

      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- Recommended to avoid unnecessary request
      trigger = { prefetch_on_insert = false },
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
      providers = {
        -- minuet-ai provides AI-powered code completion
        minuet = {
          name = 'minuet',
          module = 'minuet.blink',
          async = true, -- don't wait for Minuet before showing LSP results
          -- Should match minuet.config.request_timeout * 1000,
          -- since minuet.config.request_timeout (default 3) is in seconds
          timeout_ms = 3000,
          -- Gives minuet higher priority among suggestions,
          -- higher than LSP (0) so it appears first, Boosts priority so AI suggestions rank near the top
          score_offset = 50,
        },
      },
    },
    -- Instructs Blink to use LuaSnip as its expansion engine
    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See `:help blink-cmp-config-fuzzy` for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' }, -- or use 'lua'

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end
