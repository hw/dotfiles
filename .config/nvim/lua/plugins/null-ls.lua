return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      -- defer to mason-null-ls
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup{
        ensure_installed = {
          -- Opt to list sources here, when available in mason.
          "black", "isort", "shfmt"
        },
        automatic_installation = true,
        handlers = {},
      }

      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
      local null_ls = require("null-ls")
      local sources = {
          -- Anything not supported by mason.
      }

      local auto_format_on_save = {}
      local options_ok, options = pcall(require, "options")
      if options_ok and type(options.auto_format_on_save) ~= "nil" then
        auto_format_on_save = options.auto_format_on_save
      end

      null_ls.setup{
        debug = true,
        sources = sources,

        -- automatic format 
        on_attach = function(client, bufnr)
          local buf_type = vim.api.nvim_buf_get_option(bufnr, "filetype")
          if auto_format_on_save[buf_type] and client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                  -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                  vim.lsp.buf.format({bufnr = bufnr})
              end,
            })
          end
        end
      }
    end
  }
}
