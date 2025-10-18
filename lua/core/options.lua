local data_path = vim.fn.stdpath("data")
local session_path = data_path .. "/last_session.vim"
local cwd_file = data_path .. "/last_cwd"

-- Function to load last session
local function load_last_session()
  if vim.fn.filereadable(session_path) == 1 then
    vim.cmd("silent! source " .. session_path)
  end

  if vim.fn.filereadable(cwd_file) == 1 then
    local f = io.open(cwd_file, "r")
    if f then
      local last_cwd = f:read("*l")
      f:close()
      if last_cwd and vim.fn.isdirectory(last_cwd) == 1 then
        vim.cmd("cd " .. last_cwd)
      end
    end
  end
end

-- Only load session if Neovim started with no files or empty args
if vim.fn.argc() == 0 then
  load_last_session()
end

-- Auto-save buffers, session, and cwd on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    -- Save all modifiable buffers
    vim.cmd("silent! wa")
    -- Save session
    vim.cmd("mksession! " .. session_path)
    -- Save current working directory
    local f = io.open(cwd_file, "w")
    if f then
      f:write(vim.fn.getcwd())
      f:close()
    end
  end,
})

vim.cmd("let g:netrw_banner = 0")

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "->"

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false

vim.opt.incsearch = true 
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.scrolloff = 8
vim.opt.signcolumn = "auto"

vim.opt.backspace = {"start","eol","indent"}

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "96"

vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true

vim.opt.mouse = "a"
vim.g.editorconfig = true

