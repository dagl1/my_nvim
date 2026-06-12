return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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
}
