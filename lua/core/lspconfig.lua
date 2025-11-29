-- Python Jedi LSP
vim.lsp.config('jedi_language_server', {
    cmd = { "jedi-language-server" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml", "setup.py", "setup.cfg",
        "requirements.txt", "Pipfile", ".git"
    },
})

-- Lua LSP
vim.lsp.config('lua_ls', {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
        },
    },
})
