-- =====================================================================
-- MAIN ENTRY POINT: init.lua
-- =====================================================================

-- Explicitly append your custom project site directory to the runtime path
vim.opt.runtimepath:append '/mnt/wsl/projects/data/nvim/site'

-- Disable netrw at the very start to avoid conflicts with tree-based explorers
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 1. Load Core Configuration
-- These modules handle basic Vim options and global keybindings
require("config.options")
require("config.keymaps")

-- 2. Load Plugins
-- This calls the setup function in lua/plugins/init.lua, 
-- which iterates through your plugin registry and initializes them.
require("plugins").setup()

-- =====================================================================
-- END OF CONFIGURATION
-- =====================================================================
