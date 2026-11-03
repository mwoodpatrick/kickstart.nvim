-- AI coding assistant for coding with LLMs
--[codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)

local function env_or_default(key, fallback)
  local v = vim.fn.getenv(key)
  return v ~= vim.NIL and v ~= '' and v or fallback
end

return function()
  local utils = require 'user.utils'
  local gh = utils.gh
  local DEFAULT_URL = env_or_default('CODECOMPANION_URL', 'http://127.0.0.1:11434')
  local DEFAULT_PROVIDER = env_or_default('CODECOMPANION_PROVIDER', 'ollama')
  local DEFAULT_MODEL = env_or_default('CODECOMPANION_MODEL', 'gpt-oss:120b-cloud')
  local DEFAULT_ADAPTOR = { name = DEFAULT_PROVIDER, model = DEFAULT_MODEL }

  vim.g.codecompanion_url = vim.g.codecompanion_url or DEFAULT_URL
  vim.g.codecompanion_provider = vim.g.codecompanion_provider or DEFAULT_PROVIDER
  vim.g.codecompanion_model = vim.g.codecompanion_model or DEFAULT_MODEL
  vim.g.codecompanion_max_diff_len = 4096

  local function run_command(cmd)
    local result = vim.system({ 'sh', '-c', cmd }, { text = true }):wait()

    if result.code ~= 0 then
      local errmsg = string.format('Command failed (code %d). Stderr: %s', result.code, result.stderr)
      vim.fn.confirm(errmsg, '&Continue')
      vim.notify(errmsg, vim.log.levels.WARN, { title = 'CodeCompanion' })
      return nil, errmsg
    end
    return vim.trim(result.stdout)
  end

  local function get_git_output(args)
    return run_command('git ' .. args) -- returns (output, err)
  end
  -- -----------------------------------------------------------------
  -- Autocommand: load native packages *once* after UI is ready
  -- -----------------------------------------------------------------
  local aug = vim.api.nvim_create_augroup('CodeCompanionBoot', { clear = true })

  vim.api.nvim_create_autocmd('WinResized', {
    group = vim.api.nvim_create_augroup('CodeCompanionResize', { clear = true }),
    callback = function()
      local width = math.floor(vim.o.columns * 0.8)
      -- Re‑apply the width – the plugin reads it from its config on each open
      vim.g.codecompanion_palette_width = width
    end,
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = aug,
    once = true,
    callback = function()
      -- add native packages (guard against nil repo)
      -- Package stored in $XDG_DATA_HOME/nvim/site/pack/core/opt/codecompanion.nvim
      local ok, repo = pcall(gh, 'olimorris/codecompanion.nvim')
      if ok and repo then vim.pack.add { { src = repo } } end

      ok, repo = pcall(gh, 'lalitmee/codecompanion-spinners.nvim')
      if ok and repo then vim.pack.add { { src = repo } } end

      -- safely require the plugin
      local codecompanion
      ok, codecompanion = pcall(require, 'codecompanion')
      if not ok then
        vim.notify('CodeCompanion not found in runtime path!', vim.log.levels.WARN, { title = 'CodeCompanion' })
        return
      end

      codecompanion.setup {
        opts = {
          log_level = env_or_default('CODECOMPANION_LOG', 'INFO'),
          language = 'English',
        },
        interactions = {
          chat = { adapter = DEFAULT_ADAPTOR },
          inline = { adapter = DEFAULT_ADAPTOR },
          cmd = { adapter = DEFAULT_ADAPTOR },
          agent = { adapter = DEFAULT_ADAPTOR },
        },
        display = {
          -- control how inline edits and code modifications are rendered
          -- and presented inside your buffer.
          diff = {
            enabled = true,
            provider = 'default',
          },
          -- the Action Palette is the central interactive menu that lets you
          -- run context-aware commands, apply suggestions, manipulate code
          -- blocks, and trigger prompt actions across your buffers.
          action_palette = {
            width = math.floor(vim.o.columns * 0.8),
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
            claude_code = { cmd = 'claude', args = {}, description = 'Claude Code CLI', provider = 'terminal' },
            opencode = { cmd = 'opencode', args = {}, description = 'OpenCode CLI', provider = 'terminal' },
          },
        },
        background = {
          adapter = vim.deepcopy(DEFAULT_ADAPTOR),
        },
        adapters = {
          ollama = function()
            local adapters
            ok, adapters = pcall(require, 'codecompanion.adapters')
            if not ok then
              vim.notify('codecompanion.adapters missing', vim.log.levels.ERROR)
              return
            end
            return adapters.extend('ollama', {
              env = { url = DEFAULT_URL },
              schema = { model = { default = DEFAULT_MODEL } },
            })
          end,
        },
        extensions = {
          spinner = { enabled = true, opts = { style = 'fidget' } },
        },
        -- [Configuring the Prompt Library](https://codecompanion.olimorris.dev/configuration/prompt-library)
        prompt_library = {
          ['Local Review'] = {
            interaction = 'chat',
            description = 'Review code with a local model',
            prompts = {
              {
                role = 'user',
                content = 'Review #{buffer} for bugs and readability.',
              },
            },
            opts = {
              adapter = DEFAULT_ADAPTOR,
            },
          },
          ['Generate Commit Message'] = {
            interaction = 'chat',
            description = 'Review git diff and write a conventional commit message',
            prompts = {
              {
                -- A system prompt sets how the LLM behaves before it sees your first message.
                -- [Configuring System Prompts](https://codecompanion.olimorris.dev/configuration/system-prompt)
                role = 'system',
                content = [[
              You are **CodeCompanion**, an expert software engineer inside Neovim.  
              Your task:
              1. Read the **full `git diff`** provided below.
              2. Analyse the changes for new features, bug fixes, refactors, docs updates, style changes, etc.
              3. Detect any potential issues or edge‑case bugs introduced by the changes and list them briefly (if any).
              4. Produce a **Conventional Commit** message:
                 - Use one of the standard types (`feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `chore`, …).
                 - Keep the subject line ≤ 72 characters.
                 - Follow the subject with a blank line.
                 - Add an optional body with bullet points describing the main changes, rationale, and any caveats.
              
              **Output format**
              
              ```
              <type>(<scope?>): <short description>
              
              - • <bullet point 1>
              - • <bullet point 2>
              …
              ```
              
              If you find no obvious issues, append:
              
              ```
              No obvious regressions detected.
              ```
              
              Only return the commit message—no extra commentary.
              
              Below is the diff to process:
              ]],
              },
              {
                role = 'user',
                content = function()
                  local diff, err = get_git_output 'diff --cached'
                  if not diff or diff == '' then
                    diff, err = get_git_output 'diff'
                  end
                  if not diff or diff == '' then return ('Error: Unable to obtain git diff – %s'):format(err or 'unknown') end

                  -- Truncate very large diffs (prevent token overflow)

                  local max_len = tonumber(vim.g.codecompanion_max_diff_len) or 4096
                  if #diff > max_len then diff = diff:sub(1, max_len) .. '\n...truncated...' end

                  return string.format('Please review these code changes and generate a commit message:\n\n```diff\n%s\n```', diff)
                end,
              },
            },
            opts = {
              adapter = DEFAULT_ADAPTOR, -- The adapter and model to use, as below
              alias = 'commit_message', -- Run the prompt with :CodeCompanion /{alias} or require("codecompanion").prompt("{alias}")
              is_slash_cmd = true, -- Make a chat prompt available as a slash command, using its alias
              auto_submit = true, -- Send the prompt to the LLM straight away
            },
          },
        },
      }
      -- This module initializes CodeCompanion so no return needed
    end,
  })

  vim.keymap.set({ 'n', 'v' }, '<leader>cc', '<cmd>CodeCompanionChat Toggle<CR>', { desc = 'Toggle CodeCompanion Chat' })
  vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>CodeCompanionActions<CR>', { desc = 'CodeCompanion Actions' })
  vim.keymap.set('n', '<leader>ci', '<cmd>CodeCompanion<CR>', { desc = 'CodeCompanion Inline Prompt' })
end
