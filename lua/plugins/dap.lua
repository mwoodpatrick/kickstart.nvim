-- Install the debugger plugin stack
-- [DAP (Debug Adapter Protocol)](https://github.com/mfussenegger/nvim-dap)
return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { { src = gh 'mfussenegger/nvim-dap' } }
  --
  -- [nvim-dap-ui a UI for nvim-dap)](https://github.com/rcarriga/nvim-dap-ui)
  vim.pack.add { { src = gh 'rcarriga/nvim-dap-ui' } }
  --
  -- nvim-dap-ui depends on nvim-nio for async I/O
  vim.pack.add { { src = gh 'nvim-neotest/nvim-nio' } }

  -- [nvim-dap-ui a UI for nvim-dap)](https://github.com/jbyuki/one-small-step-for-vimkind)
  vim.pack.add { { src = gh 'jbyuki/one-small-step-for-vimkind' } }

  local dap = require 'dap'
  local dapui = require 'dapui'
  local osv = require 'osv'

  dapui.setup()

  -- Auto-open/close dapui when debugging starts/ends
  dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
  dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
  dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

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
  vim.keymap.set('n', '<leader>dl', function() osv.launch { port = 8086 } end, { noremap = true, desc = 'Launch OSV server' })
  vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { noremap = true, desc = 'Toggle DAP UI' })

  vim.keymap.set('n', '<leader>dw', function()
    local widgets = require 'dap.ui.widgets'
    widgets.hover()
  end, { noremap = true, desc = 'DAP hover widget' })

  vim.keymap.set('n', '<leader>df', function()
    local widgets = require 'dap.ui.widgets'
    widgets.centered_float(widgets.frames)
  end, { noremap = true, desc = 'DAP frames widget' })
end
