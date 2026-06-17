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
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",

    opts = {
      context = "buffers",
      trusted_tools = true,
      chat_autocomplete = false,
      auto_insert_mode = true,
      mappings = {
        close = {
          normal = "[][]",
          insert = "[][]",
        },
        complete = {
          insert = "<C-g>",
        },
        -- diff view not on gd but on
        -- c-j
        show_diff = {
          normal = "<C-j>",
          insert = "<C-j>",
        },
      },
    },
  },
}
