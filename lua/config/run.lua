-- lua/config/run.lua
local M = {}

local function open_in_editor(file, line)
  if not file then
    return
  end

  -- find a normal window
  local win = nil

  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.bo[buf].buftype ~= "terminal" then
      win = w
      break
    end
  end

  if not win then
    vim.cmd("vsplit")
    win = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_set_current_win(win)
  vim.cmd("edit " .. file)

  if line and line > 0 then
    vim.api.nvim_win_set_cursor(win, { line, 0 })
  end
end
local function is_term_open(term)
  if term.window and vim.api.nvim_win_is_valid(term.window) then
    return true
  end
  return false
end

--------------------------------------------------------------------------------
-- Traceback navigation
--------------------------------------------------------------------------------

local traceback = {
  frames = nil,
  index = nil,
  ready = true,
}
local function parse_traceback(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local frames = {}

  local in_traceback = false

  for _, line in ipairs(lines) do
    if line:match("^Traceback %(most recent call last%):") then
      frames = {}
      in_traceback = true
    elseif in_traceback then
      local file, lnum = line:match('File "([^"]+)", line (%d+)')

      if file then
        -- Ignore stdlib/internal frames
        if not file:match("^<") and not file:match("^<frozen") and vim.fn.filereadable(file) == 1 then
          table.insert(frames, {
            file = file,
            line = tonumber(lnum),
          })
        end
      elseif #frames > 0 and line ~= "" then
        -- We've reached the exception message
        break
      end
    end
  end
  print(vim.inspect(frames))

  if #frames == 0 then
    traceback.frames = nil
    traceback.index = nil
    return
  end

  traceback.frames = frames
  traceback.index = #frames
end

local function update_traceback_from_runner()
  local runner = _G.python_runner
  if not runner or not runner.bufnr then
    return
  end
  if traceback.ready == false then
    return
  end

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(runner.bufnr) then
      parse_traceback(runner.bufnr)
    end
  end)
end

local function traceback_next()
  if traceback.ready then
    update_traceback_from_runner()
    traceback.ready = false
  end
  if not traceback.frames then
    return
  end

  traceback.index = math.max(1, traceback.index - 1)
  local frame = traceback.frames[traceback.index]
  open_in_editor(frame.file, frame.line)
end

local function traceback_prev()
  if traceback.ready then
    update_traceback_from_runner()
    traceback.ready = false
  end

  if not traceback.frames then
    return
  end

  traceback.index = math.min(#traceback.frames, traceback.index + 1)
  local frame = traceback.frames[traceback.index]
  open_in_editor(frame.file, frame.line)
end

local function traceback_reset()
  vim.b.traceback = nil
end

local function show_traceback()
  if not traceback.frames then
    vim.notify("No traceback frames available", vim.log.levels.INFO)
    return
  end

  local items = {}
  for i, frame in ipairs(traceback.frames) do
    table.insert(items, string.format("%d: %s:%d", i, frame.file, frame.line))
  end

  vim.ui.select(items, {
    prompt = "Select traceback frame:",
  }, function(choice)
    if not choice then
      return
    end

    local index = tonumber(choice:match("^(%d+):"))
    if index then
      traceback.index = index
      local frame = traceback.frames[index]
      open_in_editor(frame.file, frame.line)
    end
  end)
end

vim.keymap.set("n", "<leader>tn", traceback_next, {
  desc = "Next traceback frame",
})

vim.keymap.set("n", "<leader>tN", traceback_prev, {
  desc = "Previous traceback frame",
})

vim.keymap.set("n", "<leader>tr", traceback_reset, {
  desc = "Reset traceback cache",
})

vim.keymap.set("n", "<leader>ts", show_traceback, {
  desc = "Show traceback frames",
})

local function to_bool(v)
  return v == "true" or v == "1" or v == "yes"
end
M.configs = {
  dev = {
    base_dir = vim.fn.getcwd(),
    source = "src",
    file = "main.py",
    venv = ".venv",
    args = "",
    use_module = false,
  },
}

M.active = "dev"

local function resolve_python(venv, base_dir)
  local path = base_dir .. "/" .. venv .. "/bin/python"
  if vim.fn.executable(path) == 1 then
    return path
  end
  return "python"
end

function M.get_active()
  return M.configs[M.active]
end

function M.run()
  local cfg = M.get_active()
  if not cfg then
    vim.notify("No active run config", vim.log.levels.ERROR)
    return
  end

  local base_dir = cfg.base_dir or vim.fn.getcwd()
  local source = cfg.source_dir or ""
  local venv = cfg.venv or ".venv"
  local python = resolve_python(venv, base_dir)
  local file = base_dir .. "/" .. cfg.file
  local module = cfg.module or ""
  local args = cfg.args or ""

  local cmd

  if cfg.use_module then
    if source ~= "" then
      source = "PYTHONPATH=" .. source
    end
    cmd = table.concat({
      "cd",
      base_dir,
      "&&",
      source,
      "uv run",
      "-m",
      module,
      args,
    }, " ")
  else
    cmd = table.concat({
      python,
      file,
      args,
    }, " ")
  end

  local runner = _G.python_runner
  if not runner then
    vim.notify("Runner not initialized", vim.log.levels.ERROR)
    return
  end

  local win = runner.window
  if win and vim.api.nvim_win_is_valid(win) then
    -- just focus existing window (NO new open)
    vim.api.nvim_set_current_win(win)
  else
    -- only open if it doesn't exist yet
    runner:open()
  end
  -- refresh window reference after open
  win = runner.window
  if not win or not vim.api.nvim_win_is_valid(win) then
    vim.notify("ToggleTerm window not ready", vim.log.levels.ERROR)
    return
  end
  if not win or not vim.api.nvim_win_is_valid(win) then
    vim.notify("ToggleTerm window not ready", vim.log.levels.ERROR)
    return
  end

  local height = vim.api.nvim_win_get_height(win)

  runner:send(string.rep("\n", height))
  runner:send(cmd .. "\n")
  traceback.ready = true
  if runner.bufnr and vim.api.nvim_buf_is_valid(runner.bufnr) then
    vim.b[runner.bufnr].traceback = nil
  end
end

function M.run_python_file()
  local file = vim.fn.expand("%:p")

  if not file:lower():match("%.py$") then
    local message = "File " .. file .. " is not a python file and thus cannot run!"
    vim.notify(message, vim.log.levels.ERROR)
    return
  end

  -- try venv first
  local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"
  local python = vim.fn.executable(venv_python) == 1 and venv_python or "python"

  local runner = _G.python_runner
  if not runner then
    vim.notify("Runner not initialized", vim.log.levels.ERROR)
    return
  end

  local win = runner.window
  if win and vim.api.nvim_win_is_valid(win) then
    -- just focus existing window (NO new open)
    vim.api.nvim_set_current_win(win)
  else
    -- only open if it doesn't exist yet
    runner:open()
  end
  -- refresh window reference after open
  win = runner.window
  if not win or not vim.api.nvim_win_is_valid(win) then
    vim.notify("ToggleTerm window not ready", vim.log.levels.ERROR)
    return
  end

  if not win or not vim.api.nvim_win_is_valid(win) then
    vim.notify("ToggleTerm window not ready", vim.log.levels.ERROR)
    return
  end
  local height = vim.api.nvim_win_get_height(win)
  runner:send(string.rep("\n", height))
  runner:send(python .. " '" .. file .. "'", true)
  traceback.ready = true
  if runner.bufnr and vim.api.nvim_buf_is_valid(runner.bufnr) then
    vim.b[runner.bufnr].traceback = nil
  end
end
function M.set_active(name)
  if M.configs[name] then
    M.active = name
    vim.notify("Active config: " .. name)
  else
    vim.notify("Config not found: " .. name, vim.log.levels.ERROR)
  end
  M.save()
end

function M.list()
  return vim.tbl_keys(M.configs)
end

function M.add(name, cfg)
  M.configs[name] = cfg
  M.save()
end

function M.prompt_add()
  vim.ui.input({ prompt = "Config name: " }, function(name)
    if not name or name == "" then
      return
    end

    vim.ui.input({ prompt = "Use module : ", default = "true" }, function(use_module)
      vim.ui.input({ prompt = "Base_dir : ", default = vim.fn.getcwd() }, function(base_dir)
        if not base_dir or base_dir == "" then
          return
        end

        vim.ui.input({ prompt = "source_dir : ", default = vim.fn.getcwd() }, function(source_dir)
          if not source_dir or source_dir == "" then
            return
          end
          -- default for file is buffer name
          vim.ui.input({ prompt = "File: ", default = vim.fn.expand("%:p") }, function(file)
            if not file then
              return
            end
            vim.ui.input({ prompt = "Args: " }, function(args)
              if not args then
                return
              end

              vim.ui.input({ prompt = "Venv (.venv): ", default = ".venv" }, function(venv)
                if use_module then
                  M.configs[name] = {
                    use_module = use_module,
                    base_dir = base_dir,
                    source_dir = source_dir,
                    module = file,
                    file = "",
                    venv = venv,
                    args = args,
                  }
                else
                  M.configs[name] = {
                    use_module = use_module,
                    base_dir = base_dir,
                    source_dir = "",
                    module = "",
                    file = file,

                    venv = venv,
                    args = args,
                  }
                end

                M.save()
                vim.notify("Added config: " .. name)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end
function M.remove(name)
  if not M.configs[name] then
    vim.notify("Config not found: " .. name, vim.log.levels.ERROR)
    return M.save()
  end

  M.configs[name] = nil

  if M.active == name then
    M.active = next(M.configs) -- fallback to another config
  end

  vim.notify("Removed config: " .. name)
end
function M.edit(name)
  local cfg = M.configs[name]
  if not cfg then
    vim.notify("Config not found: " .. name, vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Use module : ", default = tostring(cfg.use_module) }, function(use_module)
    use_module = to_bool(use_module)

    vim.ui.input({ prompt = "Base_dir", default = cfg.base_dir }, function(base_dir)
      if not base_dir then
        return
      end
      vim.ui.input({ prompt = "source_dir:", default = cfg.source_dir }, function(source_dir)
        if not source_dir then
          return
        end
        local default_file = use_module and (cfg.module or "") or (cfg.file or "")
        vim.ui.input({ prompt = "File/module:", default = default_file }, function(file)
          if not file then
            return
          end

          vim.ui.input({ prompt = "Venv:", default = cfg.venv or ".venv" }, function(venv)
            if not venv then
              return
            end

            vim.ui.input({ prompt = "Args:", default = cfg.args or "" }, function(args)
              if args == nil then
                return
              end

              if use_module then
                M.configs[name] = {
                  use_module = use_module,
                  base_dir = base_dir,
                  source_dir = source_dir,
                  module = file,
                  file = "",
                  venv = venv,
                  args = args,
                }
              else
                M.configs[name] = {
                  use_module = use_module,
                  base_dir = base_dir,
                  source_dir = "",
                  file = file,
                  venv = venv,
                  args = args,
                }
              end

              M.save()
              vim.notify("Updated config: " .. name)
            end)
          end)
        end)
      end)
    end)
  end)
  M.save()
end
function M.open_menu()
  local keys = vim.tbl_keys(M.configs)

  vim.ui.select(keys, {
    prompt = "Run config:",
  }, function(choice)
    if not choice then
      return
    end

    vim.ui.select({
      "run",
      "set active",
      "edit",
      "delete",
    }, {
      prompt = "Action for " .. choice,
    }, function(action)
      if action == "run" then
        M.set_active(choice)
        M.run()
      elseif action == "set active" then
        M.set_active(choice)
      elseif action == "edit" then
        M.edit(choice)
      elseif action == "delete" then
        M.remove(choice)
      end
    end)
  end)
end

local path = vim.fn.getcwd() .. "/.nvim-run.json"

local function read_file()
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return vim.fn.json_decode(content)
end

local function write_file(data)
  local f = io.open(path, "w")
  if not f then
    return
  end
  f:write(vim.fn.json_encode(data))
  f:close()
end

function M.load()
  local data = read_file()
  if data then
    M.configs = data.configs or {}
    M.active = data.active or next(M.configs)
  end
end

function M.save()
  write_file({
    configs = M.configs,
    active = M.active,
  })
end

return M
