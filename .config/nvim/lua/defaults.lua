-- defaults

local tabsize = 2

vim.opt.number = true
vim.opt.numberwidth = 3

vim.opt.tabstop = tabsize
vim.opt.softtabstop = tabsize
vim.opt.shiftwidth = tabsize
vim.opt.expandtab = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.hidden = true
vim.opt.swapfile = false

vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

vim.opt.signcolumn = "yes:2"
vim.opt.termguicolors = true

vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.keymodel = "startsel" -- select using Shift+Arrow keys 
vim.g.mapleader = " "
