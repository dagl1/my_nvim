-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader keys
colors = {
  regular_color = { fg = "#C9D1D9" }, -- brighter gray (was #A9B7C6)
}
vim.api.nvim_set_hl(0, "Normal", colors.regular_color)
vim.api.nvim_set_hl(0, "NormalFloat", colors.regular_color)
vim.cmd("highlight clear")
vim.cmd("syntax reset")
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

-- wrapping
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- set line width to 94
vim.opt.textwidth = 94
-- show a visual indicator at 94 characters
vim.opt.colorcolumn = "94"

vim.opt.scrolloff = 68

vim.opt_local.formatoptions = "tcrq"
-- backup
vim.opt.backupdir = vim.fn.stdpath("data") .. "/backup//"
