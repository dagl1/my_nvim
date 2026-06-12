-- show generated suggestions as ghost text and not as tab completion options
-- tab cannot accept ghost text
-- copilot.lua
-- don't show suggestions as options in tab completion menu
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    -- event = "InsertEnter",
    lazy = false,
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          accept = false, -- you handle it yourself (good)
          accept_word = false,
          accept_line = false,
          next = false,
          prev = false,
          dismiss = false,
        },
      },
      panel = {
        enabled = false, -- 🚫 disables Copilot “side panel”
      },
    },
  },
  {
    { "zbirenbaum/copilot-cmp", enabled = false },
  },
}
