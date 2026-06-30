return {
  "windwp/nvim-autopairs",
  opts = {
    check_ts = true,
    enabled = function(bufnr)
      local buf_type = vim.api.nvim_buf_get_option(bufnr, "buftype")
      if buf_type == "prompt" or buf_type == "nofile" then
        return false
      end
      return true
    end,
  },
  config = function(_, opts)
    local autopairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")

    autopairs.setup(opts)

    autopairs.add_rules({
      Rule('"""', '"""', "python"):with_pair(cond.not_after_text([["]])):with_move(cond.none()),
    })
  end,
}
