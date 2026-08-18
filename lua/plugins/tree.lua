-- Add a file explorer (Written In Lua)
-- https://github.com/nvim-tree/nvim-tree.lua

return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { gh 'nvim-tree/nvim-web-devicons' }
  vim.pack.add { gh 'nvim-tree/nvim-tree.lua' }

  local function nvim_tree_on_attach(bufnr)
    local api = require 'nvim-tree.api'

    local function opts(desc) return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true } end

    -- default mappings
    api.map.on_attach.default(bufnr)

    -- custom mappings
    vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts 'Up')
    vim.keymap.set('n', '?', api.tree.toggle_help, opts 'Help')
  end

  require('nvim-tree').setup {
    on_attach = nvim_tree_on_attach,
    sort = {
      sorter = 'case_sensitive',
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },

    -- There are many |netrw| features beyond the file browser. If you want to
    -- keep using |netrw| without its browser features please ensure:

    disable_netrw = false,
    hijack_netrw = true,
  }

  -- Optional: Add a keymap to toggle the file tree quickly
  vim.keymap.set('n', '<leader>ee', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
end
