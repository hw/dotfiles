-- Minimal Neovim Configuration
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Essential options
vim.g.mapleader = " " -- Set leader key to space
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true

-- Plugins
require("lazy").setup({
  -- Colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- Lualine statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
        },
      })
    end,
  },

  -- Web devicons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  -- Inline diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup()
      vim.diagnostic.config({ virtual_text = false })
    end
  },
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "javascript", "typescript", "json", "html", "css" },
        highlight = { enable = true },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "ts_ls" },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        root_dir = vim.fs.dirname(vim.fs.find({ '.luarc.json', '.luarc.jsonc', '.luacheckrc', 'stylua.toml', 'selene.toml' }, { upward = true })[1])
      }
      vim.lsp.config.pyright = {
        capabilities = capabilities,
        root_dir = vim.fs.dirname(vim.fs.find({ 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile' }, { upward = true })[1])
      }
      vim.lsp.config.ts_ls = {
        capabilities = capabilities,
        root_dir = vim.fs.dirname(vim.fs.find({ 'package.json', 'tsconfig.json', 'jsconfig.json' }, { upward = true })[1])
      }

      vim.lsp.enable('lua_ls')
      vim.lsp.enable('pyright')
      vim.lsp.enable('ts_ls')
    end,
  },

  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")

      -- Function to check if copilot is available
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false, -- Only confirm if explicitly selected
          }),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
        },
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
      })
    end,
  },

  -- GitHub Copilot
  {
    "github/copilot.vim",
    config = function()
      -- Disable copilot for certain filetypes where it conflicts
      vim.g.copilot_filetypes = {
        ["*"] = true,
      }

      -- Disable tab mapping to avoid conflicts
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true

      -- Use Ctrl+J to accept copilot suggestions
      vim.keymap.set("i", "<C-J>", 'copilot#Accept("<CR>")', {
        silent = true,
        expr = true,
        replace_keycodes = false
      })

      -- Dismiss copilot when cmp menu is visible
      vim.api.nvim_create_autocmd("User", {
        pattern = "CmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "CmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
})
