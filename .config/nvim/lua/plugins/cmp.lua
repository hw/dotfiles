return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua"
    },
    config = function()
      local cmp = require("cmp")
      local tsutils = require("nvim-treesitter.ts_utils")

      cmp.setup{
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end
        },
        sources = cmp.config.sources{
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "nvim_lua" },
        },
        mapping = {
          ["<CR>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() and cmp.get_active_entry() then
                  cmp.confirm{ behavior = cmp.ConfirmBehavior.Replace, select = false }
                  cmp.close()
              else
                fallback()
              end
            end, {"i"}),
          ["<Down>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end,{"i"}),
          ["<Up>"] = cmp.mapping(
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end,{"i"}),
          ["<Tab>"] = cmp.mapping(
            function(fallback) 
              local processed = false
              if cmp.visible() then
                if #cmp.get_entries() == 1 then
                  cmp.confirm{ behavior = cmp.ConfirmBehavior.Replace, select = true}
                  processed = true
                elseif cmp.get_active_entry() then
                  cmp.confirm{ behavior = cmp.ConfirmBehavior.Replace, select = false }
                  processed = true
                end
              else
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                local line_str = vim.api.nvim_get_current_line()
                local line_len = line_str:len()
                if col < line_len then 
                  local next_char = line_str:sub(col+1, col+1)
                  if next_char == ")" or next_char == "," then
                    vim.api.nvim_win_set_cursor(0, {line, col+1})
                    processed = true
                  else 
                    local ts_node = tsutils.get_node_at_cursor()
                    while (ts_node:type():sub(1,6) == "string") do
                      -- skip through string
                      local start_row, start_col, end_row, end_col = ts_node:range()
                      vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col})
                      ts_node = tsutils.get_node_at_cursor()
                      processed = true
                    end
                  end
                elseif line_len > 0 and line_str:sub(col, col):match("%s") == nil then
                  -- invoke completion if the cursor is on part of a word (i.e., not a whitespace)
                  cmp.complete()
                  if #cmp.get_entries() == 1 then
                    -- if there is only one entry, select it when tab is pressed
                    cmp.confirm{ behavior = cmp.ConfirmBehavior.Replace, select = true}
                  end
                  processed = true
                end
              end
              if not processed then
                fallback()
              end
            end, {"i"}),
        }
      }
    end
  }
}

