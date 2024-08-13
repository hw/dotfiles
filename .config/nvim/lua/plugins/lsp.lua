return {
  {
    "williamboman/mason.nvim",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason").setup()
      require("mason-lspconfig").setup_handlers{
        function(server_name)  
          lspconfig[server_name].setup{
            capabilities = capabilities
          }
        end
      }
    end
  },
}

