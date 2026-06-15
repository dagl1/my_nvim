return {
  "saghen/blink.cmp",

  opts = {
    -- completion sources (THIS is the important part)
    sources = {
      default = {
        "lsp",
        "path",
        "buffer",
        -- ❌ NO "copilot"
      },
    },

    keymap = {
      preset = "super-tab",

      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback",
      },
    },

    signature = {
      enabled = false,
    },

    completion = {
      menu = {
        auto_show = true,
      },
      ghost_text = {
        enabled = false, -- IMPORTANT: Copilot handles ghost text, not blink
      },
    },
  },
}
