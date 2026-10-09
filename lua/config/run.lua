-- lua/config/run.lua
local M = {}

local function open_in_editor(file, line)
  if not file then
    return
  end

  local win = nil

  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    local buftype = vim.bo[buf].buftype
    local filetype = vim.bo[buf].filetype
    local win_config = vim.api.nvim_win_get_config(w)

    local is_normal_win = buftype ~= "terminal"
      and buftype ~= "nofile"
      and buftype ~= "prompt"
      and not filetype:match("^snacks_")
      and filetype ~= "NvimTree"
      and filetype ~= "neo-tree"
      and (not win_config.relative or win_config.relative == "")

    if is_normal_win then
      win = w
      break
    end
  end

  if not win then
    vim.cmd("vsplit")
    win = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_set_current_win(win)
  vim.cmd("edit " .. vim.fn.fnameescape(file))

  if line and line > 0 then
    local current_buf = vim.api.nvim_win_get_buf(win)

    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(current_buf) then
        local line_count = vim.api.nvim_buf_line_count(current_buf)
        local target_line = math.min(line, line_count)
        if target_line > 0 then
          vim.api.nvim_win_set_cursor(win, { target_line, 0 })
          vim.cmd("normal! zz")
        end
      end
    end)
  end
end

--------------------------------------------------------------------------------
-- Find the output of the latest cz-commit / cz-retry command
--------------------------------------------------------------------------------

local function last_cz_command_output_start(lines)
  for i = #lines, 1, -1 do
    -- Match the command anywhere on the echoed shell prompt line.
    if lines[i]:find("cz%-commit") or lines[i]:find("cz%-retry") then
      return i + 1
    end
  end

  return nil
end

--------------------------------------------------------------------------------
-- Shared buffer-specific navigator
--------------------------------------------------------------------------------

local function make_navigator(opts)
  local states = {}

  local function reset(buf)
    if buf then
      states[buf] = nil
    else
      states = {}
    end
  end

  local function parse(buf)
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
      return {}
    end

    return opts.parse(buf) or {}
  end

  local function get_state(buf)
    if not buf then
      return nil, false
    end

    if not states[buf] then
      local entries = parse(buf)

      if #entries == 0 then
        vim.notify(opts.empty_message, vim.log.levels.INFO)
        return nil, false
      end

      states[buf] = {
        entries = entries,
        index = #entries + 1,
      }

      return states[buf], true
    end

    return states[buf], false
  end

  local function navigate(buf, direction)
    local state, initialized = get_state(buf)

    if not state then
      return
    end

    if initialized then
      vim.defer_fn(function()
        -- Re-parse the buffer after 100 ms.
        reset(buf)
        local refreshed_state = get_state(buf)

        if not refreshed_state then
          return
        end

        -- allow cycling so if at 1 and go prev, go to last, and if at last and go next, go to 1

        local count = #refreshed_state.entries

        if count == 0 then
          return
        end

        local index = refreshed_state.index + direction

        if index < 1 then
          index = count
        elseif index > count then
          index = 1
        end

        refreshed_state.index = index
        opts.open(refreshed_state.entries[index])
      end, 100)

      return
    end

    -- Normal navigation on subsequent keypresses.
    total_entries = #state.entries
    if total_entries == 0 then
      return
    end

    -- cycling:
    state.index = state.index + direction
    if state.index < 1 then
      state.index = total_entries
    elseif state.index > total_entries then
      state.index = 1
    end

    opts.open(state.entries[state.index])
  end

  local function show(buf)
    local state = states[buf]

    if not state then
      local initialized
      state, initialized = get_state(buf)

      if not state then
        return
      end

      -- Interactive selection is allowed to initialize and open a location.
      if initialized then
        -- Continue below with the newly parsed entries.
      end
    end

    local items = {}
    for i, entry in ipairs(state.entries) do
      items[i] = opts.label(entry, i)
    end

    vim.ui.select(items, { prompt = opts.prompt }, function(_, idx)
      if not idx or not states[buf] then
        return
      end

      states[buf].index = idx
      opts.open(states[buf].entries[idx])
    end)
  end

  return {
    next = function(buf)
      navigate(buf, -1)
    end,
    prev = function(buf)
      navigate(buf, 1)
    end,
    reset = reset,
    show = show,
  }
end

--------------------------------------------------------------------------------
-- Ruff errors
--------------------------------------------------------------------------------

local ruff_navigator = make_navigator({
  empty_message = "No Ruff errors found after the latest cz command",
  prompt = "Select Ruff error:",

  parse = function(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local first = last_cz_command_output_start(lines)

    vim.notify(("cz command starts at line %s (buffer has %d lines)"):format(tostring(first), #lines))
    vim.print(vim.api.nvim_buf_get_lines(_G.root_term.buf, 0, -1, false))

    if not first then
      return {}
    end

    local errors = {}

    for i = first, #lines do
      local file, lnum, col, code = lines[i]:match("^%s*(.-):(%d+):(%d+):%s+([A-Z]%d+)")

      if file and file ~= "" then
        table.insert(errors, {
          file = file,
          line = tonumber(lnum),
          col = tonumber(col),
          code = code,
        })
      end
    end

    return errors
  end,

  label = function(entry, i)
    return string.format("%d: %s:%d:%d [%s]", i, entry.file, entry.line, entry.col, entry.code)
  end,

  open = function(entry)
    open_in_editor(entry.file, entry.line, entry.col)
  end,
})

--------------------------------------------------------------------------------
-- Python traceback frames
--------------------------------------------------------------------------------

local function make_traceback_parser(command_scoped)
  return function(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local first = 1
    if command_scoped then
      first = last_cz_command_output_start(lines)
      if not first then
        return {}
      end
    end

    -- Find the last traceback within the selected output.
    local start
    for i = #lines, first, -1 do
      if lines[i]:match("^Traceback %(most recent call last%):") then
        start = i
        break
      end
    end

    if not start then
      return {}
    end

    local frames = {}

    for i = start + 1, #lines do
      local file, lnum = lines[i]:match('File "([^"]+)", line (%d+)')

      if file and not file:match("^<") and not file:match("^<frozen") and vim.fn.filereadable(file) == 1 then
        table.insert(frames, {
          file = file,
          line = tonumber(lnum),
        })
      end
    end

    return frames
  end
end

local traceback_navigator = make_navigator({
  empty_message = "No traceback frames available",
  prompt = "Select traceback frame:",
  parse = make_traceback_parser(false),

  label = function(frame, i)
    return string.format("%d: %s:%d", i, frame.file, frame.line)
  end,

  open = function(frame)
    open_in_editor(frame.file, frame.line)
  end,
})

local root_traceback_navigator = make_navigator({
  empty_message = "No traceback frames found after the latest cz command",
  prompt = "Select root terminal traceback frame:",
  parse = make_traceback_parser(true),

  label = function(frame, i)
    return string.format("%d: %s:%d", i, frame.file, frame.line)
  end,

  open = function(frame)
    open_in_editor(frame.file, frame.line)
  end,
})
--------------------------------------------------------------------------------
-- Resolve source buffers independently of the current buffer
--------------------------------------------------------------------------------

local function get_root_term_buf()
  local term = _G.root_term
  local buf = term and term.buf

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Root terminal is not available", vim.log.levels.WARN)
    return nil
  end

  return buf
end

local function get_python_runner_buf()
  local runner = _G.python_runner
  local buf = runner and runner.bufnr

  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Python runner buffer is not available", vim.log.levels.WARN)
    return nil
  end

  return buf
end

--------------------------------------------------------------------------------
-- Run cz-commit in the root terminal
--------------------------------------------------------------------------------

local function run_cz_retry()
  local term = _G.root_term
  local buf = get_root_term_buf()

  if not term or not buf then
    return
  end

  local previous_win = vim.api.nvim_get_current_win()

  -- Clear old results before starting a new run.
  traceback_navigator.reset(buf)
  ruff_navigator.reset(buf)

  term:show()

  local job = vim.b[buf].terminal_job_id
  if not job then
    vim.notify("Root terminal has no running job", vim.log.levels.WARN)
  else
    vim.api.nvim_chan_send(job, "cz-retry\n")
  end

  if vim.api.nvim_win_is_valid(previous_win) then
    vim.api.nvim_set_current_win(previous_win)
  end
end

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>gr", run_cz_retry, {
  desc = "Run cz-retry in root terminal",
})

vim.keymap.set("n", "<leader>gn", function()
  ruff_navigator.next(get_root_term_buf())
end, { desc = "Next root terminal Ruff error" })

vim.keymap.set("n", "<leader>gN", function()
  ruff_navigator.prev(get_root_term_buf())
end, { desc = "Previous root terminal Ruff error" })

vim.keymap.set("n", "<leader>gm", function()
  ruff_navigator.show(get_root_term_buf())
end, { desc = "Select root terminal Ruff error" })

-- Python runner traceback: also works from any current buffer.
vim.keymap.set("n", "<leader>tN", function()
  traceback_navigator.next(get_python_runner_buf())
end, { desc = "Next Python traceback frame" })

vim.keymap.set("n", "<leader>tn", function()
  traceback_navigator.prev(get_python_runner_buf())
end, { desc = "Previous Python traceback frame" })

vim.keymap.set("n", "<leader>tm", function()
  traceback_navigator.show(get_python_runner_buf())
end, { desc = "Select Python traceback frame" })

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
  if runner.bufnr and vim.api.nvim_buf_is_valid(runner.bufnr) then
    traceback_navigator.reset(runner.bufnr)
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
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
  if runner.bufnr and vim.api.nvim_buf_is_valid(runner.bufnr) then
    traceback_navigator.reset(runner.bufnr)
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
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
