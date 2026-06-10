return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "tokyonight"

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
          "CursorLine",
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
