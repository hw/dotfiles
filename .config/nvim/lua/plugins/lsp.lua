local closing_delimiters = "[)\\%]}]"
local opening_delimiters = "[([{]"
local delimiter_pairs = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ["<"] = ">",
}

return {
  {
    "williamboman/mason.nvim",
    dependencies = { 
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "rcarriga/nvim-notify",
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
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua"
    },
    config = function()
      local notify = require("notify")
      local cmp = require("cmp")
      local tsutils = require("nvim-treesitter.ts_utils")

      cmp.setup{
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end
        },
        sources = cmp.config.sources{
          { name = "nvim_lua" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lsp" },
        },
        mapping = {
          ["<S-Tab>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, {"i","s"}),
          ["<Tab>"] = cmp.mapping(
            function(fallback) 
              if cmp.visible() then
                if #cmp.get_entries() == 1 then
                  -- if there is only one entry, select it when tab is pressed
                  cmp.confirm{ select = true }
                else
                  -- otherwise, move on to the next entry
                  cmp.select_next_item()
                end
              else
                local processed = false
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line_str = vim.api.nvim_get_current_line()
                local line_len = line_str:len()
                if col < line_len then 
                  if line_str:sub(col, col+1) == "()" then
                    vim.api.nvim_win_set_cursor(0, {line, col+1})
                    processed = true
                  else 
                    notify(tsutils.get_node_at_cursor():type())
                    local eosn = 1
                    while (tsutils.get_node_at_cursor():type() == "string_content") do
                      vim.api.nvim_win_set_cursor(0, {line, col+eosn})
                      eosn = eosn + 1
                    end
                    if tsutils.get_node_at_cursor():type() == "string" then
                      vim.api.nvim_win_set_cursor(0, {line, col+eosn})
                    end
                  end
                end
                if line_str:sub(col, col):match("%s") == nil then
                  -- invoke completion if the cursor is on part of a word (i.e., not a whitespace)
                  cmp.complete()
                  if #cmp.get_entries() == 1 then
                    -- if there is only one entry, select it when tab is pressed
                    cmp.confirm{ select = true }
                  end
                  processed = true
                end

                if not processed then
                  fallback()
                end
              end
            end, {"i", "s"}),
        }
      }
    end
  }
}

