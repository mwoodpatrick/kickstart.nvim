-- AI coding assistant for coding with LLMs
--[codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim)

return function()
  local utils = require 'user.utils'
  local gh = utils.gh
  local debug = 0
  local DEFAULT_URL = os.getenv 'CODECOMPANION_URL' or 'http://127.0.0.1:11434'
  local DEFAULT_PROVIDER = os.getenv 'CODECOMPANION_PROVIDER' or 'ollama' -- can be overridden via env var
  local DEFAULT_MODEL = os.getenv 'CODECOMPANION_MODEL' or 'gpt-oss:120b-cloud' -- can be overridden via env var
  local DEFAULT_ADAPTOR = { name = DEFAULT_PROVIDER, model = DEFAULT_MODEL }

  local function run_command(cmd)
    local result = vim.system({ 'sh', '-c', cmd }, { text = true }):wait()

    if result.code ~= 0 then
      local errmsg = string.format('Command failed (code %d). Stderr: %s', result.code, result.stderr)
      vim.fn.confirm(errmsg, '&Continue')
      vim.notify(errmsg, vim.log.levels.WARN)
      return nil
    end

    local output = vim.trim(result.stdout)
    -- Successfully read and exited with code 0
    -- vim.fn.confirm('Debug breakpoint reached read completed\n', '&Continue')
    return output
  end

  local function get_git_output(args)
    local cmd = 'git ' .. args
    return run_command(cmd)
  end
  -- -----------------------------------------------------------------
  -- Autocommand: load native packages *once* after UI is ready
  -- -----------------------------------------------------------------
  local aug = vim.api.nvim_create_augroup('CodeCompanionBoot', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = aug,
    once = true,
    callback = function()
      -- add native packages (guard against nil repo)
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
          log_level = 'DEBUG',
          language = 'English',
        },
        interactions = {
          chat = { adapter = DEFAULT_ADAPTOR },
          inline = { adapter = DEFAULT_ADAPTOR },
          cmd = { adapter = DEFAULT_ADAPTOR },
          agent = { adapter = DEFAULT_ADAPTOR },
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
            claude_code = { cmd = 'claude', args = {}, description = 'Claude Code CLI', provider = 'terminal' },
            opencode = { cmd = 'opencode', args = {}, description = 'OpenCode CLI', provider = 'terminal' },
          },
        },
        background = {
          adapter = DEFAULT_ADAPTOR,
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
                content_old = [[You are an expert software engineer. Your task is to analyze the provided git diff, review the changes for potential issues or bugs, and then generate a concise, professional conventional commit message (e.g., feat:, fix:, refactor:, chore:) with a short description followed by a detailed bulleted body if necessary.]],

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
                  local result = get_git_output 'diff --cached' or get_git_output 'diff'
                  if not result then return 'Error: Unable to obtain git diff, error: ' end

                  -- Truncate very large diffs (prevent token overflow)
                  local MAX = 2048
                  if #result > MAX then result = result:sub(1, MAX) .. '\n...truncated...' end

                  return string.format('Please review these code changes and generate a commit message:\n\n```diff\n%s\n```', result)
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

  --mvim.keymap.set('n', '<leader>gc', generate_commit_message, { desc = 'Generate Conventional Commit' })
end
