local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")

if lspconfig_ok and mason_lspconfig_ok and cmp_nvim_lsp_ok then
  local lsp_capabilities = cmp_nvim_lsp.default_capabilities()
  mason_lspconfig.setup_handlers{
    function(server_name)
      lspconfig[server_name].setup {
        capabilities = lsp_capabilities
      }
    end
  }
end

