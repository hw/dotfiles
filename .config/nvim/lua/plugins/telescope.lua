return {
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    build = "make",
    config = function ()
      local telescope = require("telescope")
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function ()
      local telescope = require("telescope")
   end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function ()
      local telescope = require("telescope")
   end
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function ()
      local telescope = require("telescope")
      local fb_actions = telescope.extensions.file_browser.actions
      telescope.setup {
        extensions = {
           fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          },
          file_browser = {
            hijack_netrw = true,
            mappings = {
              ["i"] = {
                ["<F2>"] = fb_actions.rename,
                ["<F5>"] = fb_actions.copy,
                ["<F6>"] = fb_actions.move,
                ["<F8>"] = fb_actions.remove,
              },
              ["n"] = {
                ["<F2>"] = fb_actions.rename,
                ["<F5>"] = fb_actions.copy,
                ["<F6>"] = fb_actions.move,
                ["<F8>"] = fb_actions.remove,
              }
            }
          },
          ["ui-select"] = {
          },
        }
      }
      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
--      telescope.load_extension("ui-select")
    end
  },
}

