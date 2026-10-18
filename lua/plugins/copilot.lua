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
    config = function(_, opts)
      require("copilot").setup(opts)

      vim.keymap.set("n", "<leader>ct", function()
        require("copilot.suggestion").toggle_auto_trigger()
        vim.notify("Copilot auto-suggestions toggled")
      end, { desc = "Toggle Copilot Auto Suggestions" })
    end,
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
        reset = {
          normal = "<m-o>",
          insert = "<m-o>",
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
