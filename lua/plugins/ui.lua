return function()
  require('vim._core.ui2').enable {
    enable = true,
    msg = {
      targets = 'cmd', -- Route messages through the modernized command area
      pager = {
        height = 1, -- Configure pager behavior for long outputs
      },
    },
    transparency = true,
  }

  -- The line beneath this is called `modeline`. See `:help modeline`
  -- vim: ts=2 sts=2 sw=2 et

  local function open_ranger()
    -- Define window dimensions (80% of editor size)
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    -- Create a scratch buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- Open floating window using modern API
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      col = col,
      row = row,
      style = 'minimal',
      border = 'rounded',
    })

    -- Bind to a convenient keymap (e.g., <leader>r)
    vim.keymap.set('n', '<leader>r', open_ranger, { desc = 'Open Ranger File Manager' })
    -- Start job/terminal natively via jobstart instead of bare termopen
    --
    vim.fn.jobstart('ranger', {
      term = true,
      on_exit = function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end,
    })

    -- Enter terminal mode automatically
    vim.cmd 'startinsert'
  end
  -- Fetch recent command-line history items programmatically
  vim.api.nvim_create_user_command('CreateHistoryBuffer', function()
    local history_items = {}
    for i = 1, vim.fn.histnr 'cmd' do
      local cmd = vim.fn.histget('cmd', i)
      if cmd ~= '' then table.insert(history_items, cmd) end
    end

    -- Open a new scratch buffer containing the history list for easy copying
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, history_items)
    vim.api.nvim_set_current_buf(buf)
  end, {})

  -- Bind it to a keymap for quick access (e.g., <leader>la)
  vim.keymap.set('n', '<leader>hb', '<cmd>CreateHistoryBuffer<CR>', { desc = 'Show history buffer' })

  -- Force Neovim to recognize .bash files and alias scripts as bash
  vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { '*.bash' },
    callback = function()
      -- vim.print("Opening bash file")
      vim.bo.filetype = 'bash'
    end,
  })
end
