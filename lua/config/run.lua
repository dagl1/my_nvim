-- lua/config/run.lua
local M = {}

local function is_term_open(term)
  if term.window and vim.api.nvim_win_is_valid(term.window) then
    return true
  end
  return false
end

local function to_bool(v)
  return v == "true" or v == "1" or v == "yes"
end

M.configs = {
  dev = {
    source_dir = vim.fn.getcwd(),
    file = "main.py",
    venv = ".venv",
    args = "",
    use_module = false,
  },
}

M.active = "dev"

local function resolve_python(venv, source_dir)
  local path = source_dir .. "/" .. venv .. "/bin/python"
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

  local source_dir = cfg.source_dir or vim.fn.getcwd()
  local venv = cfg.venv or ".venv"
  local python = resolve_python(venv, source_dir)
  local file = source_dir .. "/" .. cfg.file
  local module = cfg.module or ""
  local args = cfg.args or ""

  local cmd

  if cfg.use_module then
    cmd = table.concat({
      "cd",
      source_dir,
      "&&",
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

    vim.ui.input({ prompt = "Use module : " }, function(use_module)
      vim.ui.input({ prompt = "Source_dir : " }, function(source_dir)
        if not source_dir or source_dir == "" then
          return
        end

        vim.ui.input({ prompt = "File: " }, function(file)
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
                  source_dir = source_dir,
                  module = file,
                  file = "",
                  venv = venv,
                  args = args,
                }
              else
                M.configs[name] = {
                  use_module = use_module,
                  source_dir = source_dir,
                  module = "",
                  file = file,

                  venv = venv,
                  args = args,
                }
              end

              vim.notify("Added config: " .. name)
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

  vim.ui.input({ prompt = "Use module : " }, function(use_module)
    use_module = to_bool(use_module)
    vim.ui.input({ prompt = "source_dir:", default = cfg.source_dir }, function(source_dir)
      if not source_dir then
        return
      end
      vim.ui.input({ prompt = "File:", default = cfg.file }, function(file)
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
                source_dir = source_dir,
                module = file,
                file = "",
                venv = venv,
                args = args,
              }
            else
              M.configs[name] = {
                use_module = use_module,
                source_dir = source_dir,
                file = file,
                venv = venv,
                args = args,
              }
            end

            vim.notify("Updated config: " .. name)
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
