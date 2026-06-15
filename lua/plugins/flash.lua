return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    modes = {
      char = {
        -- 1. Keep the f/F/t/T motions active
        enabled = true,
        -- 2. Restrict the search highlights ONLY to the current line
        jump_labels = true,
        multi_line = false,
        -- 3. Turn off the gray/dim background backdrop completely
        jump = { backdrop = false },
        highlight = { backdrop = false },
      },
    },
  },
}
