return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.lsp.signature = {
      auto_open = { enabled = false },
    }
    -- opts.views = {
    --   notify = {
    --     replace = false,
    --   },
    -- }
    -- opts.routes.insert = {
    --   filter = { event = "notify" },
    --   opts = { replace = false },
    -- }
    -- opts.routes.insert = {
    --   filter = { event = "messages" },
    --   opts = { replace = false },
    -- }
    -- opts.routes.insert = {
    --   filter = { event = "notify", level = "info" },
    --   opts = { replace = false },
    -- }
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
