return {
    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      config = function()
            -- Python LSP
          vim.lsp.config("pyright", {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            root_markers = { "pyproject.toml", "setup.py", ".git" },
          })
          vim.lsp.enable("pyright")

          -- Lua LSP
          vim.lsp.config("lua_ls", {
            cmd = { "lua-language-server" },
            filetypes = { "lua" },
            root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                diagnostics = { globals = { "vim" } },
              },
            },
          })
          vim.lsp.enable("lua_ls")
      end,
    },
    {
        {
          "williamboman/mason.nvim",
          config = function()
            require("mason").setup()
          end
        },
        {
          "williamboman/mason-lspconfig.nvim",
          dependencies = { "williamboman/mason.nvim" },
          config = function()
            require("mason-lspconfig").setup({
              ensure_installed = { "jedi_language_server", "pylsp", "jsonls", "yamlls",
              "lua_ls" },
            })
          end
        },
    }
}
