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

    vim.keymap.set({ "n", "t" }, "<SHIFT-F4>", python_runner_func, { desc = "Python runner terminal toggle" })
    vim.keymap.set({ "n", "t" }, "<F16>", python_runner_func, { desc = "Python runner terminal toggle" })
    vim.keymap.set({ "n", "t" }, "<S-F4>", python_runner_func, { desc = "Python runner terminal toggle" })

    vim.keymap.set({ "n", "t" }, "<F6>", python_console_func, { desc = "Python console toggle" })

    vim.keymap.set("t", "<>", [[<C-\><C-n>]])
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
  end,
}
