return {
  "nvimdev/lspsaga.nvim",
  event = "LspAttach",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("lspsaga").setup{
      lightbulb = {
        enabled = true,
        enabled_in_insert = false,
        sign = true,
        virtual_text = false
      }
    }
  end
}
