
local get_dap_target = function(id)
  local ok, devtools = pcall(require, "devtools")
  if ok then
    return devtools.ui_select_executable(id)
  else
    -- fallback to using vim builtin input
    return vim.fn.input({
      prompt = "Executable:",
      completion = "file",
      default = vim.fn.getcwd()
    })
  end
end

return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local ok, mason_registry = pcall(require, "mason-registry")
      if not ok then
        return
      end

      local codelldb_root = mason_registry.get_package("codelldb"):get_install_path()
      local codelldb_path = codelldb_root .. "/extension/adapter/codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb_path,
          args = {"--port", "${port}"},
        }
      }

      local cpptools_root = mason_registry.get_package("cpptools"):get_install_path()
      local cpptools_path = cpptools_root .. "/extension/debugAdapters/bin/OpenDebugAD7"
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = cpptools_path,
      }

      dap.configurations.c = {
        {
          type = "codelldb",
          name = "Launch LLDB",
          request = "launch",
          cwd = '${workspaceFolder}',
          program = function() return get_dap_target("codelldb") end,
--          stopOnEntry = true,
        },
        {
          type = "cppdbg",
          name = "Launch GDB",
          request = "launch",
          MIMode = "gdb",
          cwd = '${workspaceFolder}',
          program = function() return get_dap_target("cppdbg") end,
          stopOnEntry = true,
        },
     }
      dap.configurations.cpp = dap.configurations.c
      dap.configurations.hpp = dap.configurations.c

    end,
  },
  -- Python
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local mason_registry_ok, mason_registry = pcall(require, 'mason-registry')
      local python_path = "python3"
      if mason_registry_ok then
        python_path = mason_registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python"
      end
      require("dap-python").setup(python_path)
    end
  },
  -- Lua
  {
    "jbyuki/one-small-step-for-vimkind",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require("dap")
      dap.adapters.nlua = function(callback, config)
        callback {
          type = "server", host = config.host or "127.0.0.1", port = config.port or 8086
        }
      end
      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim",
        }
      }
    end,
  },
  -- Go
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    build = function()
      require("go.install").update_all_sync()
    end,
    config = function()
      require("go").setup{
        icons = false,
        dap_debug_gui = false,
      }
    end,
  },
  -- Rust
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if not mason_registry_ok then return end
      local codelldb_root = mason_registry.get_package("codelldb"):get_install_path() .. "/extension/"
      local codelldb_path = codelldb_root .. "adapter/codelldb"
      local liblldb_path = codelldb_root .. "lldb/lib/liblldb.so"

      local rt = require("rust-tools")
      local opts = {
        executor = require("rust-tools.executors").quickfix,
        dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path),
        }
      }
      rt.setup(opts)
    end
  },
  -- Javascript / Typescript
  {
    "mxsdev/nvim-dap-vscode-js",
    ft = { "javascript", "typescript" },
    dependencies = {
      "mfussenegger/nvim-dap",
      {
        "microsoft/vscode-js-debug",
        build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
      }
    },
    config = function()
      require("dap-vscode-js").setup {
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { 'chrome', 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost', 'node', 'chrome' },
      }

      local dap = require("dap")
      for _, language in ipairs({ "typescript", "javascript" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            rootPath = "${workspaceFolder}",
            cwd = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Process",
            rootPath = "${workspaceFolder}",
            cwd = vim.fn.getcwd(),
            processId = require'dap.utils'.pick_process,
          },
        }
      end
    end
  },
} -- close for "return {"
