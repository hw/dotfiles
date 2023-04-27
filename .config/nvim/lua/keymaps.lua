local dap_ok, dap = pcall(require, "dap")
local dapui_ok, dapui = pcall(require, "dapui")
local dap_bp_ok, dap_breakpoints = pcall(require, "dap.breakpoints")
local lspsaga_ok, lspsaga = pcall(require, "lspsaga")
local whichkey_ok, wk = pcall(require, "which-key")

if not dap_ok or not dap_bp_ok or not dapui_ok then
  vim.notify("DAP/DAP-UI not installed")
  return
end
if not lspsaga_ok or not whichkey_ok then
  vim.notify("Lspsaga/Which-Key not installed")
  return
end

local debugger = {}
debugger.start = function()
  local ft = vim.bo.filetype
  if ft == "rust" then
    vim.cmd("RustLastDebug")
  elseif ft == "go" or ft == "gomod" then
    vim.cmd("GoDebug")
  elseif ft == "python" then
    vim.cmd("DapContinue")
  elseif ft == "lua" then
    require("osv").run_this()
  elseif ft == "cpp" or ft == "c" then
    require("devtools").build_and_debug("codelldb")
  else
    vim.cmd("DapContinue")
  end
end

debugger.stop = function()
  dap.terminate()
  dapui.close()
end

debugger.set_target = function()
  require("devtools").select_build_executable()
end

debugger.launch_nvim_lua_debugger = function()
  local ok, osv = pcall(require, "osv")
  if not ok then
    vim.notify("one-small-step-for-vimkind not found")
  end
  osv.launch({port = 8086})
end

local toggle_lsp_line = function()
  local config = vim.diagnostic.config().virtual_lines
  if type(config) == "table" then
    vim.diagnostic.config({ virtual_lines = true })
  else
    vim.diagnostic.config({ virtual_lines = { only_current_line = true } })
  end
end

local mappings = {
  ["<F5>"] = {
    activate_debugger, "Activate Debugger"
  },
   ["<F8>"] = {
    function() dap_breakpoints.toggle() end, "Toggle Breakpoint",
  },
  ["<F10>"] = {
    function() dap.step_into() end, "Step Into"
  },
  ["<leader>b"] = {
    function() dap_breakpoints.toggle() end, "Toggle Breakpoint",
  },
  ["<leader>g"] = {
    "<cmd>Telescope buffers<cr>", "Buffers..",
  },
  ["<leader><leader>"] = {
    function() dap.step_over() end, "Step Over"
  },
  ["<leader><Down>"] = {
    function() dap.step_into() end, "Step Into"
  },
  ["<leader><Up>"] = {
    function() dap.step_out() end, "Step Out"
  },
   ["<leader><Left>"] = {
    function() vim.diagnostic.goto_prev({float = false}) end, "Previous Diagnostic"
  },
  ["<leader><Right>"] = {
    function() vim.diagnostic.goto_next({float = false}) end, "Next Diagnostic"
  },
  ["<leader>d"] = {
    name = "Debugger",
    q = { debugger.stop, "Terminate" },
    d = { debugger.start, "Debug" },
    b = { dap.pause, "Pause" },
    c = { dap.continue, "Continue" },
    C = { dap.run_to_cursor, "Run to Cursor" },
    s = { dap.step_into, "Step Into" },
    S = { dap.step_out, "Step Out" },
    t = { debugger.set_target, "Target" },
    u = { dapui.toggle, "Toggle UI" },
    l = {
      name = "Launch .. ",
      l = { debugger.launch_nvim_lua_debugger,  "Neovim Lua Debugger" },
    },
  },
  ["<leader>c"] = {
    name       = "Code",
    p          = { "<cmd>Copilot panel<cr>", "Copilot Panel" },
    c          = { "<cmd>Lspsaga code_action<cr>", "Code Action" },
    r          = { "<cmd>Lspsaga rename<cr>", "Rename" },
    f          = { "<cmd>Lspsaga lsp_finder<cr>", "Find" },
    d          = { "<cmd>Lspsaga goto_definition<cr>", "Goto Definition" },
    D          = { toggle_lsp_line, "Toggle Diagnostics" },
    F          = { function() vim.lsp.buf.format() end, "Format" },
  }
  ,
  ["<leader>f"] = {
    name      = "File",
    b         = { "<cmd>Telescope file_browser<cr>", "File Browser" },
    f         = { "<cmd>Telescope find_files<cr>", "Find File" },
    g         = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
  }
}

wk.register(mappings, { mode = "n" })
