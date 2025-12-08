return {
   "ggandor/leap.nvim",
  config = function()
    local leap = require("leap")
    --leap.add_default_mappings()

    -- ✅ Force label mode instead of instant jump
    leap.opts.safe_labels = {}
    leap.opts.labels = "asdfghjklqwertyuiopzxcvbnm"
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
    vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-from-window)")
  end,
}
