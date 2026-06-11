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

    -- SHIFT-F4 (your F16)
    vim.keymap.set({ "n", "t" }, "<F16>", function()
      runner:toggle()
    end, { desc = "Python runner terminal" })

    vim.keymap.set("t", "<>", [[<C-\><C-n>]])
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])
  end,
}
