return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap"
    },
    config = function ()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup({
        expand = true,
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.4 },
              { id = "watches", size = 0.2 },
              { id = "stacks", size = 0.2 },
              { id = "breakpoints", size = 0.2 },
            },
            size = 0.3,
            position = "right",
          },
          {
            elements = {
              { id = "repl", size = 0.4 },
              { id = "console", size = 0.6 }
            },
            size = 0.3,
            position = "bottom",
          },
        },
      })
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap"
    },
    config = function ()
      require("nvim-dap-virtual-text").setup()
    end
  }
}

