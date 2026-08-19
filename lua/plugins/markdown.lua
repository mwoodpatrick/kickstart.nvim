-- https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki

return function()
  local utils = require 'user.utils'
  local gh = utils.gh

  vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
  require('render-markdown').setup {
    file_types = { 'markdown', 'Avante' },
    code = {
      sign = false,
      width = 'full',
      position = 'right',
    },
    checkbox = {
      enabled = true,
    },
  }

  -- Markdown-preview relies on a global function mapping or autocmd if native
  -- local opts = { buffer = 0 }
end
