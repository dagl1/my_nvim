-- lua/config/run.lua
local M = {}

M.configs = {
  dev = {
    source_dir = vim.fn.getcwd(),
    file = "main.py",
    venv = ".venv",
    args = "",
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
  local file = vim.fn.getcwd() .. "/" .. cfg.file
  local args = cfg.args or ""

  local cmd = table.concat({
    "cd",
    source_dir,
    "&&",
    python,
    "-m",
    file,
    args or "",
  }, " ")

  vim.cmd("ToggleTerm direction=float")
  vim.cmd("TermExec cmd='" .. cmd .. "'")
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

    vim.ui.input({ prompt = "Source_dir : " }, function(source_dir)
      if not source_dir or source_dir == "" then
        return
      end

      vim.ui.input({ prompt = "File: " }, function(file)
        if not file then
          return
        end

        vim.ui.input({ prompt = "Venv (.venv): ", default = ".venv" }, function(venv)
          M.add(name, {
            file = file,
            venv = venv,
          })

          vim.notify("Added config: " .. name)
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

  vim.ui.input({ prompt = "source_dir:", default = cfg.source_dir }, function(file)
    if not file then
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

          M.configs[name] = {
            file = file,
            venv = venv,
            args = args,
          }

          vim.notify("Updated config: " .. name)
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

function M.run_python_file()
  local file = vim.fn.expand("%:p")

  -- try venv first
  local venv_python = vim.fn.getcwd() .. "/.venv/bin/python"

  local python = vim.fn.executable(venv_python) == 1 and venv_python or "python"

  vim.cmd("ToggleTerm direction=float")
  vim.cmd("TermExec cmd='" .. python .. " " .. file .. "'")
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
