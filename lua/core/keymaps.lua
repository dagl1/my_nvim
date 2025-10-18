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

