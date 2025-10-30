return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    -- Example basic LSP setup
    local lspconfig = require("lspconfig")

    -- Example: enable pyright for Python
    lspconfig.pyright.setup{}

    -- Example: enable lua_ls for Lua
    lspconfig.lua_ls.setup{
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    }
  end,
}

