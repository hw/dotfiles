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
      local mason_lspconfig = require("mason-lspconfig")
      require("mason").setup()
      mason_lspconfig.setup{
        ensure_installed = { "bashls", "lua_ls", "html", "jsonls", "yamlls" }
      }
      mason_lspconfig.setup_handlers{
        function(server_name)
          lspconfig[server_name].setup{
            capabilities = capabilities
          }
        end
      }
    end
  },
}

