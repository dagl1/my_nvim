vim.g.lazyvim_python_lsp = "ty"
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false, autosetup = false },
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
                  transform = function(item)
                    local line = item.line or ""
                    local file = item.file or ""

                    local bonus = 0

                    -- imports = low priority
                    if line:match("^%s*from%s+") or line:match("^%s*import%s+") then
                      bonus = bonus + 100
                    end

                    -- init.py = even lower priority
                    if file:match("/__init__%.py$") then
                      bonus = bonus + 200
                    end

                    -- test in filepath
                    if file:match("/tests?/") then
                      bonus = bonus + 300
                    end

                    item.ref_penalty = bonus
                    item.score = (item.score or 0) - bonus
                    -- vim.notify(vim.inspect(item), vim.log.levels.DEBUG, { title = "LSP Reference Item" })

                    return item
                  end,
                  matcher = {
                    -- Set to true to enforce your sorting logic even when the query input is blank
                    sort_empty = true,
                  },

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
  vim.lsp.inlay_hint.enable(true),
}
