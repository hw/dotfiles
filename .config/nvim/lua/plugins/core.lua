return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    confg = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup{
        ensure_installed = { "yaml", "html", "javascript", "lua", "c", "cpp", "python", "rust", "go", "java" },
        sync_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
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
}

