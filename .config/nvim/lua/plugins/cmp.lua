local has_words_before = function()
  if vim.api.nvim_buf_get_option(0, 'buftype') == 'prompt' then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "neovim/nvim-lspconfig",  
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "L3MON4D3/LuaSnip",
    "onsails/lspkind.nvim",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    local lspkind = require("lspkind")

    local cmp_sources = cmp.config.sources {
      { name = "path" },
      { name = "nvim_lsp", group_index = 2 },
      { name = "nvim_lsp_signature_help", group_index = 2 },
      { name = "luasnip", group_index = 2 },
    }

    local has_copilot, _ = pcall(require, "copilot")
    if has_copilot then table.insert(cmp_sources, { name = "copilot", group_index = 2 }) end

    local map_funcs = {
      complete_item = function(fallback)
        if cmp.visible() and cmp.get_selected_entry() ~= nil then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end,

      select_next_item = function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
      end,

      select_next_item_if_has_word_before = function(fallback)
        if cmp.visible() and has_words_before() then
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
          fallback()
        end
      end,

      select_prev_item = function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
      end,

      select_prev_item_if_has_word_before = function(fallback)
        if cmp.visible() and has_words_before() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
      end,

    }

    cmp.setup {
      sources = cmp_sources,

      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      formatting = {
        format = lspkind.cmp_format{
          mode = "symbol",
          max_width = 50,
          symbol_map = { Copilot = "" }
        },
      },

      mapping = {
        ["<Enter>"]   = map_funcs.complete_item,
        ["<Tab>"]     = map_funcs.select_next_item_if_has_word,
        ["<Down>"]    = map_funcs.select_next_item,
        ["<S-Tab>"]   = map_funcs.select_prev_item_if_has_word,
        ["<Up>"]      = map_funcs.select_prev_item,
      }

    }

    local autopairs_ok, autopairs = pcall(require, "nvim-autopairs.completion.cmp")
    if autopairs_ok then
      cmp.event:on("confirm_done", autopairs.on_confirm_done)
    end

  end
}

