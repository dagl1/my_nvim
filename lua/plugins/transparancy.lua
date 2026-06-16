return {
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("monokai-pro").setup({
  --       transparent_background = false,
  --       -- filter = "spectrum",
  --     })
  --     vim.cmd.colorscheme("monokai-pro")
  --   end,
  -- },
  {
    "xiantang/darcula-dark.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "tokyonight-night"
      -- modify blinkcmpghostext and copilotsuggestion to be dark green

      local function transparent()
        local hl = vim.api.nvim_set_hl

        local groups = {
          "Normal",
          "NormalNC",
          "NormalFloat",
          "FloatBorder",
          "FloatTitle",
          "SignColumn",
          "EndOfBuffer",
          "VertSplit",
          "StatusLine",
          "StatusLineNC",
          "TabLine",
          "WinSeparator",
          -- "CursorLine",
          "CursorLineNr",
          "LineNr",
          ---- TROUBLE ---
          "TroubleNormal",
          "TroubleNormaleNC",
          "TroubleText",
          "TroubleCount",
        }

        for _, g in ipairs(groups) do
          hl(0, g, { bg = "none" })
        end
      end

      -- apply AFTER colorscheme loads
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "UIEnter", "WinEnter" }, {
        callback = transparent,
      })

      -- apply immediately
      vim.schedule(transparent)

      return opts
    end,
  },
}
