return {
  {
    "zbirenbaum/copilot.lua",
--    enabled = false,
    config = function ()
      require("copilot").setup {
        suggestion = { enabled = true },
        panel = { enabled = true },
      }
    end
  },
  {
    "zbirenbaum/copilot-cmp",
--    enabled = false,
    config = function()
      require("copilot_cmp").setup()
    end
  }
}
