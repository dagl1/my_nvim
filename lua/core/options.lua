local data_path = vim.fn.stdpath("data")
local session_path = data_path .. "/last_session.vim"
local cwd_file = data_path .. "/last_cwd"
local colorcolumn_num = 96

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
vim.opt.textwidth = 0
vim.opt.formatoptions:remove("t")

-- function to dynamically adjust wrapmargin for soft wrapping
local function set_soft_wrap_at_column(col)
  -- how many columns from right margin to start wrapping
  local win_width = vim.api.nvim_win_get_width(0)
  local margin = math.max(0, win_width - col)
  vim.opt_local.wrapmargin = margin
  vim.opt_local.colorcolumn = tostring(col)
end

-- update wrap margin on resize and BufEnter
vim.api.nvim_create_autocmd({ "VimResized", "BufEnter", "WinEnter" }, {
  callback = function()
    set_soft_wrap_at_column(colorcolumn_num)
  end,
})

-- Python: use hard wrap
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    print("in python file")
    vim.opt_local.textwidth = colorcolumn_num
    vim.opt_local.formatoptions:append("t")
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = false
    vim.opt_local.wrapmargin = 0
    vim.opt_local.colorcolumn = tostring(colorcolumn_num)
  end,
})

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

vim.opt.clipboard:append("unnamedplus")
vim.opt.hlsearch = true

vim.opt.mouse = "a"
vim.g.editorconfig = true


-- lsp configs -- todo : move to its own file
vim.lsp.config('jedi-language-server', {
    cmd = { "jedi-language-server" },
    filetypes = {"python"},
    rootmarkers = { 
        "pyproject.toml", "setup.py", "setup.cfg",
        "requirements.txt", "Pipfile", ".git" 
    },
})

vim.lsp.config['lua_ls'] = {
  -- Command and arguments to start the server.
  cmd = { 'lua-language-server' },
  -- Filetypes to automatically attach to.
  filetypes = { 'lua' },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
  -- Specific settings to send to the server. The schema is server-defined.
  -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      }
    }
  }
}
vim.lsp.enable('jedi_language_server')
vim.lsp.enable('lua_ls')
