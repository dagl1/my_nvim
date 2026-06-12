-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader keys
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Highlight and search
vim.opt.hlsearch = false

-- indentation behavior
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.cindent = false
vim.opt.indentexpr = ""
vim.opt.copyindent = true
vim.opt.preserveindent = true

-- optional but often helps Python feel stable
vim.g.python_recommended_style = 0

-- Persistence sessions
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,help"

-- Messages and feedbac
vim.opt.shortmess:append("cC")

-- Animate
vim.g.snacks_animate = false

-- Format options
-- vim.opt.formatoptions:remove({ "o" })

-- Yank and clipboard
vim.opt.clipboard = "unnamedplus"

-- Line movement/navigation
vim.opt.whichwrap:append("<,>,h,l,[,]")
vim.g.ai_cmp = false
