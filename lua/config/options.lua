-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.mapleader = ","
vim.g.maplocalleader = ","

vim.opt.clipboard = "unnamedplus"
-- stable indentation behavior (IDE-like, Python-friendly)

vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.cindent = false

-- CRITICAL: disables Treesitter-style indent recomputation
vim.opt.indentexpr = ""

-- makes indent stable when editing lines
vim.opt.copyindent = true
vim.opt.preserveindent = true

-- optional but often helps Python feel stable
vim.g.python_recommended_style = 0

vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help"
vim.opt.shortmess:append("cC")
