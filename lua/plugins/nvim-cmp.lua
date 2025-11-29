
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp",
    "jalvesaq/zotcite",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local cmp = require("cmp")
    cmp.setup {
      sources = {
        { name = "zotcite" },
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      }
    }
  end,
}

