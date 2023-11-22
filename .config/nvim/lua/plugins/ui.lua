return {
  {
    "folke/tokyonight.nvim",
    priority = 99,
    config = function()
      local style = "night"
      require("tokyonight").setup{
        style = style,
      }
      vim.cmd.colorscheme("tokyonight-" .. style)
    end,
  },
  {
    "folke/which-key.nvim",
    priority = 95,
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup{
      }
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup{
        stages = "fade_in_slide_out",
        timeout = 2000,
      }
      vim.notify = notify
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim", main = "ibl",
    config = function()
      vim.opt.list = true
      vim.opt.listchars:append "eol:↴"
      require("ibl").setup{
      }
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    priority = 90,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup{
        options = { theme = 'tokyonight' }
      }
    end,
  },
  {
    "romgrk/barbar.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("barbar").setup{
        auto_hide = true,
      }
    end
  },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("dressing").setup()
    end
  },
  {
    "ray-x/guihua.lua",
    config = function()
      require("guihua").setup{
        highlight = "Visual",
        keymaps = {
          toggle = "<leader>h",
          clear = "<leader>h",
        },
      }
    end
  },
}
