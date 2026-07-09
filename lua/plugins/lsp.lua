vim.g.lazyvim_python_lsp = { "ty" }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },

      servers = {
        ruff = {
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
          init_options = {
            settings = {
              lint = {
                select = { "F401" },
              },
            },
          },
        },

        ["cspell_ls"] = {
          filetypes = { "python", "markdown" },
        },

        ["harper_ls"] = {
          filetypes = vim.tbl_filter(function(ft)
            return ft ~= "python"
          end, vim.lsp.get_supported_filetypes or {}),
        },

        -- Pyright uitschakelen
        pyright = { enabled = false, autosetup = false },

        -- Ty configuratie
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

        -- Custom Snacks Picker shortcuts voor LSP References
        ["*"] = {
          keys = {
            { "gd", false },
            {
              "gd",
              function()
                Snacks.picker.lsp_references({
                  transform = function(item)
                    local line = item.line or ""
                    local file = item.file or ""

                    local line_number = item.pos[1]
                    local column_number = item.pos[2]

                    local penalty = 200

                    if line:match("^%s*def%s+") or line:match("^%s*class%s+") then
                      penalty = penalty - 100
                    end

                    if line_number < 20 and column_number == 4 then
                      penalty = penalty + 100
                    end

                    if line:match("^%s*from%s+") or line:match("^%s*import%s+") then
                      penalty = penalty + 100
                    end
                    if file:match("/__init__%.py$") then
                      penalty = penalty + 200
                    end
                    if file:match("/tests?/") then
                      penalty = penalty + 300
                    end

                    item.ref_penalty = penalty
                    item.score = (item.score or 0) - penalty
                    return item
                  end,
                  matcher = { sort_empty = true },
                  sort = {
                    fields = { "ref_penalty:asc", "score:desc", "#text", "idx" },
                  },
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
