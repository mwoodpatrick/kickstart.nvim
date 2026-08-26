-- ============================================================
-- SECTION 6: LSP
-- LSP keymaps, server configuration, Mason tools installations
-- ============================================================
return function()
  local utils = require 'user.utils'
  local gh = utils.gh
  local is_nixos = vim.fn.filereadable '/etc/NIXOS' == 1

  -- [[ LSP Configuration ]]
  -- Brief aside: **What is LSP?**
  --
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {
    -- Options related to notification integration
    notification = {
      window = {
        blend = 50, -- Window transparency (0-100)
      },
    },
  }

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- The following code creates a keymap to toggle inlay hints in your
      -- code, if the language server you are using supports them
      --
      -- This may be unwanted, since they displace some of your code
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  --  See  ~/.local/state/nvim/lsp.log for LSP log file
  ---@type table<string, vim.lsp.Config>
  local servers = {
    -- clangd = {},
    -- gopls = {},
    --  https://github.com/bash-lsp/bash-language-server
    bashls = {
      cmd = { 'bash-language-server', 'start' },
      filetypes = { 'sh', 'bash', 'zsh' },
      root_markers = { '.git' },
    },
    cssls = {
      cmd = { vim.fn.exepath 'vscode-css-language-server', '--stdio' },
      filetypes = { 'css', 'scss', 'less' },
      settings = {
        css = {
          validate = true,
        },
        scss = {
          validate = true,
        },
        less = {
          validate = true,
        },
      },
    },
    htmlls = {
      cmd = { vim.fn.exepath 'vscode-html-language-server', '--stdio' },
      filetypes = { 'html', 'templ' },
      settings = {
        html = {
          format = {
            enable = true,
          },
          suggest = {
            html5 = true,
          },
        },
      },
    },
    jsonls = {
      cmd = { vim.fn.exepath 'vscode-json-language-server', '--stdio' },
      filetypes = { 'json', 'jsonc' },
      settings = {
        json = {
          -- Automatically resolve schemas (great for $schema links in opencode.json)
          validate = { enable = true },
          schemas = {
            {
              fileMatch = { 'opencode.json' },
              url = 'https://opencode.ai/schema.json',
            },
          },
        },
      },
    },
    nil_ls = {
      cmd = { 'nil' },
      filetypes = { 'nix' },
      settings = {
        ['nil'] = {
          formatting = {
            command = { 'nixfmt' },
          },
        },
      },
    },
    nixd = {
      cmd = { 'nixd' },
      filetypes = { 'nix' },
      root_markers = { 'flake.nix', '.git', 'default.nix' },
      settings = {
        nixd = {
          nixpkgs = {
            expr = 'import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }',
          },
          formatting = {
            command = { 'alejandra' }, -- or "nixfmt"
          },
          options = {
            nixos = {
              expr = '(builtins.getFlake(toString ./.)).nixosConfigurations.nixos.options',
            },
            home_manager = {
              expr = '(builtins.getFlake(toString ./.)).homeConfigurations.mwoodpatrick.activationPackage.options',
            },
          },
        },
      },
    },
    pyright = {},
    -- rust_analyzer = {},
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`ts_ls`) will work just fine
    -- ts_ls = {},

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false }, -- Disable formatting (formatting is done by stylua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
  }

  -- On non-NixOS systems, use Mason to install LSPs and tools automatically.
  -- On NixOS these should be provided by the system package manager.
  if not is_nixos then
    vim.pack.add {
      gh 'mason-org/mason.nvim',
      gh 'mason-org/mason-lspconfig.nvim',
      gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
    }
    -- Automatically install LSPs and related tools to stdpath for Neovim
    require('mason').setup {}
  end

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
  })

  if not is_nixos then
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
  end

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
    -- vim.print(string.format("LSP server %s enabled", name))
  end

  -- Create a custom user command :LspInfo
  vim.api.nvim_create_user_command('LspInfo', function()
    local clients = vim.lsp.get_clients { bufnr = 0 }

    if #clients == 0 then
      print 'No Language Servers attached to this buffer.'
      return
    end

    print '=== Active LSP Clients for Current Buffer ==='
    for _, client in ipairs(clients) do
      print(string.format('- Name: %s (ID: %d)', client.name, client.id))
      print(string.format('  Root Dir: %s', client.config.root_dir or 'N/A'))
    end
  end, {})

  -- Bind it to a keymap for quick access (e.g., <leader>li)
  vim.keymap.set('n', '<leader>li', '<cmd>LspInfo<CR>', { desc = 'Show buffer LSP info' })

  vim.api.nvim_create_user_command('ListActiveLsp', function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
      print 'No active LSP clients found.'
      return
    end

    print '=== Active LSP Clients & Attached Buffers ==='
    for _, client in ipairs(clients) do
      print(string.format('💻 Server: %s (ID: %d)', client.name, client.id))

      -- client.attached_buffers is a table where keys are buffer numbers
      local bufs = vim.tbl_keys(client.attached_buffers)

      if #bufs == 0 then
        print '  (No buffers currently attached)'
      else
        table.sort(bufs)
        for _, bufnr in ipairs(bufs) do
          local buf_name = vim.api.nvim_buf_get_name(bufnr)
          if buf_name == '' then buf_name = '[No Name]' end
          print(string.format('    - [Buf %d] %s', bufnr, buf_name))
        end
      end
    end
  end, {})

  -- Bind it to a keymap for quick access (e.g., <leader>la)
  vim.keymap.set('n', '<leader>la', '<cmd>ListActiveLsp<CR>', { desc = 'Show buffer LSP info for all buffers' })
end
