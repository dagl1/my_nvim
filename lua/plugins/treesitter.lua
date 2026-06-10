return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.indent = opts.indent or {}
      opts.indent.enable = false
    end,
  },
}
