-- Install the debugger plugin stack
-- [DAP (Debug Adapter Protocol)](https://github.com/mfussenegger/nvim-dap)
return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { { src = gh 'mfussenegger/nvim-dap' } }
  --
  -- [nvim-dap-ui a UI for nvim-dap)](https://github.com/rcarriga/nvim-dap-ui)
  vim.pack.add { { src = gh 'rcarriga/nvim-dap-ui' } }

  -- [nvim-dap-ui a UI for nvim-dap)](https://github.com/jbyuki/one-small-step-for-vimkind)
  vim.pack.add { { src = gh 'jbyuki/one-small-step-for-vimkind' } }

  local dap = require 'dap'
  dap.configurations.lua = {
    {
      type = 'nlua',
      request = 'attach',
      name = 'Attach to running Neovim instance',
    },
  }

  dap.adapters.nlua = function(callback, config) callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 } end

  vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { noremap = true })
  vim.keymap.set('n', '<leader>dc', require('dap').continue, { noremap = true })
  vim.keymap.set('n', '<leader>do', require('dap').step_over, { noremap = true })
  vim.keymap.set('n', '<leader>di', require('dap').step_into, { noremap = true })
  vim.keymap.set('n', '<leader>dl', function() require('osv').launch { port = 8086 } end, { noremap = true })

  vim.keymap.set('n', '<leader>dw', function()
    local widgets = require 'dap.ui.widgets'
    widgets.hover()
  end)

  vim.keymap.set('n', '<leader>df', function()
    local widgets = require 'dap.ui.widgets'
    widgets.centered_float(widgets.frames)
  end)
end
