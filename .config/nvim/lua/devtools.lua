local M = {}
local ui_last_executable_path = {}

local PARENT_DIR = ".."
local ui_select_executable = function(path, show_hidden)
  local done = false
  while not done do
    path = vim.fs.normalize(path)

    local parent_dir = vim.fs.dirname(path)
    local files = {}
    local directories = {}
    if path ~= parent_dir then table.insert(directories, PARENT_DIR) end

    for name, item_type in vim.fs.dir(path) do
      if show_hidden or string.sub(name, 1, 1) ~= "." then
        if item_type == "directory" then
          table.insert(directories, name)
        else
          local full_path = path .. "/" .. name
          if vim.fn.executable(full_path) == 1 then
            table.insert(files, name)
          end
        end
      end
    end

    local listing = {}
    for _, item in pairs(directories) do table.insert(listing, item) end
    for _, item in pairs(files) do table.insert(listing, item) end

    local co = coroutine.running()
    vim.ui.select(listing, { prompt = path }, function(choice)
      if choice == nil then
        done = true -- user cancelled 
      else
        if choice == PARENT_DIR then
          path = vim.fs.dirname(path)
        else
          local new_path = "/" .. choice
          if path ~= parent_dir then  -- will not work on windows!
            new_path = path .. new_path
          end
          path = new_path

          if vim.fn.executable(path) == 1 then
            done = true -- user selected the debug target 
          end
        end
      end
      coroutine.resume(co)
    end)
    coroutine.yield() -- wait for vim.ui.select
  end
  return path
end

M.ui_select_executable = function(id, show_hidden)
  local path = ui_last_executable_path[id] or vim.fn.getcwd()
  return coroutine.create(function(parent_co)
    path = ui_select_executable(path, show_hidden)
    if path ~= nil then
      ui_last_executable_path[id] = vim.fs.dirname(path)
    end
    -- send result back to parent
    coroutine.resume(parent_co, path)
  end)
end

M.ui_input_executable = function(id)
  local co
  co = coroutine.create(function(parent_co)
    local path = ui_last_executable_path[id] or vim.fn.getcwd()
    vim.ui.input({
      prompt = "Executable:", completion = "file", default = path
    },
    function(entry)
      path = entry
      if entry ~= nil then
        ui_last_executable_path[id] = entry
      end
      coroutine.resume(co)
    end)
    coroutine.yield() -- wait for vim.ui.input
    coroutine.resume(parent_co, path)
  end)
  return co
end

M.generate_cpp_dap = function(id, program)
  local config = {
    type = id,
    request = "launch",
    cwd = "${workspaceFolder}",
    program = program
  }
  if id == "cppdbg" then
    config.MIMode = "gdb"
  end
  return config
end

M.start_cpp_dap = function(id, program)
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    vim.notify("dap not found")
    return
  end

  local config = M.generate_cpp_dap(id, program)
  dap.run(config)
end

local create_output_window = function(opts)
  opts = opts or { title = "Build", popup = false, height = 0.25 }
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")
  local buf = vim.api.nvim_create_buf(false, true)
  local win

  local buf_height = math.ceil((opts.height or 0.25) * height)
  if opts.popup == false then
    vim.cmd("split")
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_win_set_height(win, buf_height)
  else
    win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      style = "minimal",
      border = "single",
      row = height - buf_height,
      col = 1,
      width = width,
      height = buf_height,
    })
  end
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":bdelete<cr>", { silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":bdelete<cr>", { silent = true })
  vim.api.nvim_buf_set_name(buf, opts.title or "Build")

  return buf, win
end

local last_build_executable = nil
local select_build_executable = function(action)
  vim.ui.input({
      prompt = "Executable:", completion = "file", default = last_build_executable
    },
    function(entry)
      if entry ~= nil then
        last_build_executable = entry
        if type(action) == "function" then 
          action(entry)
        end
      end
    end
  )
end

M.select_build_executable = function()
  select_build_executable()
end

M.build_and_debug = function(id, compiler)
  local job_ok, Job = pcall(require, "plenary.job")
  if not job_ok then
    vim.notify("plenary not found")
    return
  end

  local src = vim.fn.expand("%:p")
  local target = nil
  local cmd = nil
  local args = {}

  if vim.fn.filereadable("Makefile") == 1 then
    cmd = "make"
    target = last_build_executable
  else
    target = vim.fs.dirname(src) .. "/" .. vim.fn.expand("%:r")
    if compiler == nil then
      if vim.fn.executable("clang") then
        compiler = "clang"
      else
        compiler = "gcc"
      end
    end
    cmd = compiler
    args = { "-g", src, "-lstdc++", "-o", target }
  end

  local buf, win = create_output_window({popup = false, title = cmd})
  local arg_str = table.concat(args, " ")
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, {"Command: " .. cmd .. " " ..arg_str, ""})

  Job:new{
    command = cmd,
    args = args,
    env = { ["PATH"] = vim.env.PATH, ["USER"] = vim.env.USER, ["HOME"] = vim.env.HOME },
    cwd = vim.fn.getcwd(),
    on_stdout = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, -1, -1, true, {line})
      end)
    end,
    on_stderr = function(_, line)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, -1, -1, true, {line})
      end)
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if (code ~= 0) then
          vim.api.nvim_buf_set_lines(buf, -1, -1, true, {"", "<Esc> or 'q' to close window"})
          vim.api.nvim_buf_set_option(buf, "modifiable", false)
          return
        end

        -- get rid of window if there are no errors
        vim.defer_fn(function()
          vim.api.nvim_win_close(win, true)
          vim.api.nvim_buf_delete(buf, { force = true })
        end, 5000)

        if target == nil then
          -- prompt for executable
          select_build_executable(function(entry)
             M.start_cpp_dap(id, entry)
          end)
        else
          M.start_cpp_dap(id, target)
        end
      end)
    end,
  }:start()
end

return M

