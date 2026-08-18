return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  -- Defer native package loading until Neovim has booted its UI completely
  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      -- 1. Register native packages safely on boot
      vim.pack.add { { src = gh 'olimorris/codecompanion.nvim' } }
      vim.pack.add { { src = gh 'lalitmee/codecompanion-spinners.nvim' } }

      -- 2. Safely load and configure CodeCompanion after environment is ready
      local status_ok, codecompanion = pcall(require, 'codecompanion')

      if not status_ok then
        vim.notify('CodeCompanion plugin not found in runtime path!', vim.log.levels.WARN, { title = 'CodeCompanion' })
        return
      end

      codecompanion.setup {
        opts = {
          log_level = 'DEBUG',
          language = 'English',
        },

        strategies = {
          chat = {
            adapter = {
              name = 'ollama',
              model = 'gemma4:12b',
            },
          },
          inline = {
            adapter = {
              name = 'ollama',
              model = 'gemma4:12b',
            },
          },
          cmd = {
            adapter = {
              name = 'ollama',
              model = 'gemma4:12b',
            },
          },
          agent = {
            adapter = {
              name = 'ollama',
              model = 'gemma4:12b',
            },
          },
        },

        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = 'Prompt ',
            provider = 'snacks',
            opts = {
              show_preset_actions = true,
              show_preset_prompts = true,
              title = 'CodeCompanion actions',
            },
          },
        },

        cli = {
          agent = 'opencode',
          agents = {
            claude_code = {
              cmd = 'claude',
              args = {},
              description = 'Claude Code CLI',
              provider = 'terminal',
            },
            opencode = {
              cmd = 'opencode',
              args = {},
              description = 'OpenCode CLI',
              provider = 'terminal',
            },
          },
        },

        background = {
          adapter = {
            name = 'ollama',
            model = 'gemma4:12b',
          },
        },

        adapters = {
          ollama = function()
            return require('codecompanion.adapters').use('ollama', {
              schema = {
                model = {
                  default = 'gemma4',
                },
              },
            })
          end,
          openai = function()
            return require('codecompanion.adapters').extend('openai', {
              env = { api_key = 'YOUR_API_KEY' },
            })
          end,
        },

        extensions = {
          spinner = {
            enabled = true,
            opts = {
              style = 'fidget',
            },
          },
        },

        prompt_library = {
          ['Generate Commit Message'] = {
            strategy = 'chat',
            description = 'Review git diff and write a conventional commit message',
            opts = {
              index = 10,
              is_slash_cmd = true,
              short_name = 'commit',
              auto_submit = false,
              theming = {
                icon = 'git',
                color = 'yellow',
              },
            },
            prompts = {
              {
                role = 'system',
                content = [[You are an expert software engineer. Your task is to analyze the provided git diff, review the changes for potential issues or bugs, and then generate a concise, professional conventional commit message (e.g., feat:, fix:, refactor:, chore:) with a short description followed by a detailed bulleted body if necessary.]],
              },
              {
                role = 'user',
                content = function()
                  local handle = io.popen 'git diff --cached'
                  local result = nil

                  if handle then
                    result = handle:read '*a'
                    handle:close()
                  end

                  if not result or result == '' then
                    local handle_unstaged = io.popen 'git diff'
                    if handle_unstaged then
                      result = handle_unstaged:read '*a'
                      handle_unstaged:close()
                    end
                  end

                  if not result or result == '' then return 'Error: No git changes detected (staged or unstaged), or not inside a valid Git repository.' end

                  return 'Please review these code changes and generate a commit message:\n\n```diff\n' .. result .. '\n```'
                end,
              },
            },
          },
        },
      }
    end,
  })

  -- Keymaps can remain safely at the root since they don't force-require modules immediately
  vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle CodeCompanion Chat' })
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<CR>', { desc = 'CodeCompanion Actions' })
  vim.keymap.set('n', '<leader>ci', '<cmd>CodeCompanion<CR>', { desc = 'CodeCompanion Inline Prompt' })
end
