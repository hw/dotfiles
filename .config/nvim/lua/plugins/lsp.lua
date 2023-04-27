return {
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig"
    },
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
  {
      "folke/neodev.nvim",
      config = function()
        require("neodev").setup()
      end
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- plugins that needs to be configure before nvim-lspconfig
      "folke/neodev.nvim"
    },
    config = function()
    end,
  }
}
