return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.lsp.signature = {
      auto_open = { enabled = false },
    }
  end,
  keys = {
    {
      "<C-i>",
      function()
        vim.lsp.buf.signature_help()
      end,
      mode = "i",
      desc = "Trigger LSP Signature Help",
    },
  },
}
