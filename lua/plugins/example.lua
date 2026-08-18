-- assumes the example plugin is installed in
-- $XDG_DATA_HOME/nvim/site/pack/core/start/example.nvim
-- Typically this is a link from $GIT_ROOT/example.nvim 
return function()
  local ok, example = pcall(require, 'example')
  -- vim.print 'loaded example'
  if ok then
    example.setup {
      prefix = '[MyExamplePlugin]: ',
      log_level = 'info',
    }
  else
    vim.notify('Failed to load local plugin: example', vim.log.levels.WARN)
  end
end
