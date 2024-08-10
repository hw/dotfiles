return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    confg = function()
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
        sync_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("tokyonight")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {  "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup{
        options = { theme = "tokyonight" }
      }
    end
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
  }
}

