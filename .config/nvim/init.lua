-- bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- defaults
pcall(require, "defaults")

-- plugins
require("lazy").setup("plugins")

-- configure plugins such as lsp, dap
pcall(require, "config.lsp")

-- keymaps
pcall(require, "keymaps")
