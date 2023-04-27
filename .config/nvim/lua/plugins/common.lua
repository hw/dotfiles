return {
  {
    "nvim-lua/plenary.nvim",
    priority = 90
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      hightlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
         "c",
         "html",
         "javascript",
         "json",
         "lua",
         "markdown",
         "markdown_inline",
         "python",
         "typescript",
         "vim",
         "yaml",
      }
    },
  }
}
