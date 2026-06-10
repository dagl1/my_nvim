return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      local map = vim.keymap.set

      local function u(rhs)
        return rhs .. "<C-g>u"
      end

      -- space + punctuation
      local keys = { " ", ".", ",", ";", ":", "!", "?" }

      for _, k in ipairs(keys) do
        map("i", k, u(k), { silent = true })
      end

      return opts
    end,
  },
}
