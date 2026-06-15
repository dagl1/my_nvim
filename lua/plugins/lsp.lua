vim.g.lazyvim_python_lsp = "ty"
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          enabled = false,
          autosetup = false,
        },
        ty = {
          settings = {
            ty = {
              enable = true,
              callArgumentNames = "all",
              variableTypeHints = true,
              variableTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
        ["*"] = {
          keys = {
            { "gd", false },

            {
              "gd",
              function()
                Snacks.picker.lsp_references({
                  win = {
                    input = {
                      keys = {
                        ["<Esc>"] = { "close", mode = { "n", "i" } },
                      },
                    },
                  },
                })
              end,
              desc = "LSP References",
            },
          },
        },
      },
    },
  },
  vim.lsp.inlay_hint.enable(true),
}
