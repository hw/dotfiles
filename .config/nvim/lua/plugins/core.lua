return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "rcarriga/nvim-notify",
    lazy = true,
    config = function()
      vim.notify = require("notify")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup{
        ensure_installed = {
          "vimdoc",
          "yaml", "xml", "json", "markdown", "markdown_inline",
          "html", "javascript", "typescript",
          "lua", "bash",
          "asm", "disassembly",
          "c", "cpp", "cmake",
          "c_sharp",
          "python",
          "rust",
          "go",
          "java",
          "proto"
        },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {  "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = "tokyonight" }
    }
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = {  "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    opts = {}
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/which-key.nvim",
    lazy = true,
  },
}

