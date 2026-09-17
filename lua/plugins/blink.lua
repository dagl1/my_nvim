return {
  "saghen/blink.cmp",
  -- Add blink.compat so blink can read the cmp-vimtex plugin
  dependencies = {
    "saghen/blink.compat",
    "micangl/cmp-vimtex", -- The source plugin
  },

  opts = {
    -- completion sources (THIS is the important part)
    sources = {
      default = {
        "lsp",
        "path",
        "buffer",
        "zotcite",
      },
      -- 2. Define the provider and hook it up using blink.compat
      providers = {

        zotcite = {
          name = "zotcite",
          module = "blink.compat.source",
        },
      },
    },

    keymap = {
      preset = "super-tab",

      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          elseif cmp.is_visible() then
            return cmp.select_and_accept()
          else
            return "\t"
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
        enabled = false,
      },
    },
  },
}
