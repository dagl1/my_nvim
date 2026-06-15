return {
  "windwp/nvim-autopairs",
  opts = {
    check_ts = true,
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
