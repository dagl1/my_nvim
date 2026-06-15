return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = true,
  -- Uncomment next line if you want to follow only stable versions
  version = "*",
  keys = {
    {
      "<leader>cd",
      function()
        require("neogen").generate()
      end,
      desc = "Generate annotation",
    },
  },

  opts = function()
    return {
      languages = {
        python = {
          template = {
            annotation_convention = "my_own_google_docstrings",
            my_own_google_docstrings = require("themes.neogen_google_docstrings_template"),
          },
        },
      },
    }
  end,
}
