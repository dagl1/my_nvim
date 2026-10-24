vim.g.lazyvim_python_lsp = { "ty" }

return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      local function is_same_diagnostic(a, b)
        return a.lnum == b.lnum
          and a.col == b.col
          and a.end_lnum == b.end_lnum
          and a.end_col == b.end_col
          and a.code == b.code
          and a.message == b.message
      end
      vim.g.rustfmt_autosave = 0
      local rust_fmt_group = vim.api.nvim_create_augroup("RustFormatting", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.rs",
        group = rust_fmt_group,
        callback = function()
          vim.lsp.buf.format({
            async = false,
            timeout_ms = 1000,
          })
        end,
      })
    end,

    opts = {
      inlay_hints = { enabled = true },

      -- Correctly disable LazyVim's built-in diagnostics here so they never trigger
      diagnostics = {
        virtual_text = false,
        virtual_lines = false,
        underline = true,
      },

      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              rustfmt = { extraArgs = {} },
            },
          },
        },
        ruff = {
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
          init_options = {
            settings = {
              lint = { select = { "F401" } },
            },
          },
        },

        ["cspell_ls"] = {
          filetypes = { "python", "markdown", "latex", "tex", "bib" },
        },

        ["harper_ls"] = {
          filetypes = vim.tbl_filter(function(ft)
            return ft ~= "python"
          end, vim.lsp.get_supported_filetypes or {}),
        },

        pyright = { enabled = false, autosetup = false },

        ty = {
          settings = {
            ty = {
              enable = true,
              diagnosticMode = "openFilesOnly",
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
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    config = function()
      -- Turn off built-in diagnostic floating popups globally
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
        float = true,
      })

      require("tiny-inline-diagnostic").setup({
        preset = "modern",
        options = {
          multilines = {
            enabled = true,
            always_show = true,
          },
        },
      })
    end,
  },
}
