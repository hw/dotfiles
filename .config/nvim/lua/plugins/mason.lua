-- plugins used by more than one configurations
return {
  "williamboman/mason.nvim",
  event = "VeryLazy",
  config = function()
    require("mason").setup()
  end
}

