-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.del("i", "<Tab>")
vim.keymap.del("i", "<S-Tab>")

-- Indent left and instantly exit visual mode
vim.keymap.set("v", "<", "<gv<Esc>", { desc = "Indent left and deselect", silent = true })

-- Indent right and instantly exit visual mode
vim.keymap.set("v", ">", ">gv<Esc>", { desc = "Indent right and deselect", silent = true })

-- vim.keymap.set("n","<C-/", )
---- Space behaves like b
vim.keymap.set({ "n", "v" }, "<Space>", "b", { noremap = true, silent = true })
-- Ctrl+Enter: split line at cursor, keep indentation
vim.keymap.set("i", "<C-CR>", "<C-o>o", { silent = true })

vim.keymap.set("n", "<C-CR>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local indent = line:match("^%s*") or ""
  local before = line:sub(1, col)
  local after = line:sub(col + 1)

  vim.api.nvim_set_current_line(before)
  vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. after })

  vim.api.nvim_win_set_cursor(0, { row + 1, #indent })
end, { silent = true })

-- Ctrl+/ toggle comment (normal + visual)
vim.keymap.set("n", "<C-_>", function()
  require("Comment.api").toggle.linewise.current()
end, { silent = true })

vim.keymap.set({ "n", "t" }, "<F4>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

-- vim.keymap.set("n", )

vim.keymap.set("v", "y", function()
  vim.cmd("normal! y")
  vim.cmd("normal! `>")
end, { desc = "Yank and go to bottom of selection" })

vim.keymap.set("v", "<C-_>", function()
  vim.cmd("normal gcc")
  vim.cmd("normal gv")
end, { desc = "Toggle comment" })

vim.keymap.set("n", "<C-_>", function()
  vim.cmd("normal gcc")
  vim.cmd("normal j")
end, { desc = "Toggle comment + move down" })

------------- PYTHON RUN KEYMAPS ---------------------------
local run = require("config.run")
run.load()

vim.keymap.set("n", "<leader>rf", run.run_python_file, { desc = "Run Python file" })
vim.keymap.set("n", "<leader>re", run.open_menu, { desc = "Run config menu" })
vim.keymap.set("n", "F22", run.run, { desc = "Run active config" })
vim.keymap.set("n", "<leader>ro", run.run, { desc = "Run active config" })
vim.keymap.set("n", "<leader>ra", run.prompt_add, { desc = "Add config" })
---------------------- code navigation ----------------------
vim.keymap.set("n", "gd", function()
  Snacks.picker.lsp_declarations()
end)
vim.schedule(function()
  pcall(vim.keymap.del, "n", "<leader>r")
  pcall(vim.keymap.del, "n", "<localleader>r")
end)
