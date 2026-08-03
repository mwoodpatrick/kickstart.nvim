-- 1. Define local variables or helper functions (hidden from the outside world)
-- vim.print("Loading my settings")
-- Local private variables representing module state
local module_version = '1.0.0'
local active_status = false
local default_indent = 4
local current_settings = {
  theme = 'default',
  debug_mode = false,
}
local function log_message(msg) print('[Settings Module]: ' .. msg) end
-- 2. Create the table that will hold your public interface
local M = {}
-- 3. Attach functions or configuration options to your module table
M.setup = function(opts)
  opts = opts or {}
  local indent = opts.indent or default_indent
  --   log_message 'Applying global configurations...'

  -- Example Neovim option setting
  vim.opt.shiftwidth = indent
  vim.opt.tabstop = indent
  vim.opt.expandtab = true
end
M.get_info = function()
  -- print 'This is a custom modular configuration file.'
  return {
    version = module_version,
    is_active = active_status,
    settings = current_settings,
  }
end
-- 4. CRITICAL: Return the table at the very end of the file
return M
