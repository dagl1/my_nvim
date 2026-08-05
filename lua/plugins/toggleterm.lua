local function parse_file_and_line(text)
  local file = text:match("([%w%._%-%/]+%.%w+)")
  local line = text:match("[Ll]ine%s*(%d+)") or text:match(":(%d+):?") or text:match(",(%d+)") or 1

  return file, tonumber(line)
end

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

  -- print("Opened file: " .. file .. " at line: " .. line)
  if line and line > 0 then
    print("Jumping to line: " .. line)
    vim.api.nvim_win_set_cursor(win, { line, 0 })
  end
end

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    open_mapping = nil, -- disable default <C-\>
    hide_numbers = true,
    shade_terminals = true,
    start_in_insert = true,
    insert_mappings = true,
    terminal_mappings = true,
    persist_size = true,
    direction = "horizontal",
    size = 25,
  },

  config = function(_, opts)
    require("toggleterm").setup(opts)
    local Terminal = require("toggleterm.terminal").Terminal

    local runner

    if not _G.python_runner then
      runner = Terminal:new({
        hidden = true,
        start_in_insert = true,
      })

      _G.python_runner = runner
    else
      runner = _G.python_runner
    end

    local python_runner_func = function()
      runner:toggle()
    end

    local console

    if not _G.python_console then
      console = Terminal:new({
        hidden = true,
        start_in_insert = true,
      })

      _G.python_console = console
      console:toggle()
      console:send("uv run python")
      console:toggle()
    else
      console = _G.python_console
    end

    local python_console_func = function()
      console:toggle()
      vim.schedule(function()
        if console:is_open() then
          vim.cmd("startinsert!")
        end
      end)
    end
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(args)
        local buf = args.buf

        -- ONLY toggleterm buffers (optional safety)
        if vim.bo[buf].filetype ~= "toggleterm" and vim.bo[buf].buftype ~= "terminal" then
          return
        end

        -- gf = file only
        vim.keymap.set("n", "gf", function()
          local line = vim.api.nvim_get_current_line()
          local file, lnum = parse_file_and_line(line)
          -- local file = line:match('"([^"]+%..+)"') or line:match("([%w%._%-%/]+%..+)")
          open_in_editor(file, 1)
        end, { buffer = buf, silent = true })

        -- gF = file + line
        vim.keymap.set("n", "gF", function()
          local line = vim.api.nvim_get_current_line()
          local file, lnum = parse_file_and_line(line)
          open_in_editor(file, lnum)
        end, { buffer = buf, silent = true })
      end,
    })

    vim.keymap.set({ "n", "t" }, "<SHIFT-F4>", python_runner_func, { desc = "Python runner terminal toggle" })
    vim.keymap.set({ "n", "t" }, "<F16>", python_runner_func, { desc = "Python runner terminal toggle" })
    vim.keymap.set({ "n", "t" }, "<S-F4>", python_runner_func, { desc = "Python runner terminal toggle" })

    vim.keymap.set({ "n", "t" }, "<F6>", python_console_func, { desc = "Python console toggle" })
    vim.keymap.set("t", "<>", [[<C-\><C-n>]])
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
  end,
}
