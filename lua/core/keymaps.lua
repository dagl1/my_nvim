local opts = { noremap = true, silent = true }

vim.g.mapleader = ","
vim.g.maplocalleader = ","
 
vim.keymap.set("n", "Z", '"ayiwviw"0p', 
    {desc = "Yank word to register a, then paste last yank" }
)

vim.keymap.set({"n","v"}, "<Space>", "b", 
    {desc = "Allow space to act like b "}
)
-- 
vim.keymap.set({"n","v"}, "<leader><Space>", "B",
    {desc = "Allow <leader>space to act like B"}
)
vim.keymap.set("v", "y", "ygv<Esc>",
    {desc = "Allow yank to remain at the start of the yank"}
)
-- Insert mode: Ctrl+[ acts like Escape
vim.keymap.set("i", "<C-[>", "<Esc>")


-- Normal mode: keep cursor centered when scrolling half-page up/down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- Normal mode: keep search results centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Allow both normal and visual mode j k to go down visual lines (softwrapped)
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("v", "j", "gj")
vim.keymap.set("v", "k", "gk")

vim.keymap.set({'v','x','s'}, 'd', function()
  vim.cmd('normal! x')
end, { noremap = true, silent = true })

vim.keymap.set('x', 'd', ':<C-u>normal! x<CR>', { noremap = true, silent = true })

-- Define session paths
local session_path = vim.fn.stdpath("data") .. "/last_session.vim"
-- Create a session (force overwrite)
vim.keymap.set("n", "<leader>mk", function()
  vim.cmd("silent! wa")  -- write all modified buffers
  vim.cmd("mksession! " .. session_path)
  print("💾 Session saved to " .. session_path)
end, { desc = "Make (save) session" })

-- Load the last session
vim.keymap.set("n", "<leader>lk", function()
  if vim.fn.filereadable(session_path) == 1 then
    vim.cmd("silent! source " .. session_path)
    print("📂 Session loaded from " .. session_path)
  else
    print("⚠️ No saved session found at " .. session_path)
  end
end, { desc = "Load last session" })

-- Open Neovim config folder
vim.keymap.set("n", "<leader>cg", function()
  vim.cmd("Explore")
end, { desc = "Go to folder of current file" })

vim.keymap.set("n", "<leader>cf", function()
  local config_dir = vim.fn.stdpath("config")
  vim.cmd("cd " .. config_dir)
  vim.cmd("Explore " .. config_dir .. "/")
end, { desc = "Go to lua config directory" })
-- TODO
-- -- In insert mode: Ctrl+Enter splits the line at cursor with smart indent
-- vim.keymap.set("n", "<C-M>", "<CR>")
-- vim.keymap.set("n", "<C-CR>", "<Esc>i<CR><Esc>^m`o<Esc>``izz", 
--     { noremap = true, silent = true, desc = "Smart line break at cursor" }
-- )
vim.keymap.set("n", "<leader><CR>", "<Esc>i<CR><Esc>^m`o<Esc>", 
    { noremap = true, silent = true, desc = "Smart line break at cursor" }
)
-- Visual mode: delete to end of screen line
-- Normal mode: delete to end of screen line
-- Yank to end of screen line
-- Change to end of screen line
vim.keymap.set("n", "d$", "dg$")
vim.keymap.set("v", "d$", "dg$")
vim.keymap.set("n", "c$", "cg$")
vim.keymap.set("n", "y$", "yg$")

-- In insert mode: Ctrl+Enter splits the line at cursor with smart indent
-- vim.keymap.set("i", "<C-CR>", "<Esc>i<CR><Esc>^m`o<Esc>``i",  
--     desc = {"Smart line break at cursor" }
-- )

-- "" Map \b to toggle the breakpoint on the current line
-- "map \b <Action>(ToggleLineBreakpoint)
-- nmap s :action KJumpAction.Char2<cr>
--
-- " Remap [[ to jump to the previous def
-- nnoremap [[ _b ?^\s*def\s<CR> ww
-- " Remap ]m to jump to the next def
-- nnoremap ]m /^\s*def\s<CR> ww
--
--

