require("scrollEOF").setup()

-------------------- Colors ---------------
local ghost_text_color = "#239129"
local CopilotSuggestion = {
  fg = ghost_text_color,
  bg = "none",
  italic = true,
}
local copilotGhostText = {
  fg = ghost_text_color,
  bg = "none",
  italic = true,
}
vim.api.nvim_set_hl(0, "CopilotSuggestion", CopilotSuggestion)
vim.api.nvim_set_hl(0, "copilotGhostText", copilotGhostText)
local set = vim.api.nvim_set_hl

-- FUNCTION DEFINITION (light blue)
local black_and_white = {
  fg = "#000000",
  bg = "#ffffff",
}
set(0, "@lsp.typemod.function.definition.python", {
  fg = "#81a1c1",
})

-- FUNCTION CALLS (NO COLOR)
set(0, "@function.call", {
  fg = "NONE",
})

set(0, "@lsp.type.function.python", {
  fg = "NONE",
})

-- BUILTINS (dark blue)
set(0, "@function.builtin.python", {
  fg = "#5e81ac",
})

-- KEYWORDS (orange)
set(0, "@keyword", { fg = "#d08770" })
set(0, "@keyword.return", { fg = "#d08770" })
set(0, "@keyword.operator", { fg = "#d08770" })
set(0, "@constant.builtin", { fg = "#d08770" })

-- self (purple)
set(0, "@lsp.type.selfParameter.python", {
  fg = "#b48ead",
})

-- attributes (dark orange)
set(0, "@property", {
  fg = "#c97a3d",
})

-- strings (light green)
set(0, "@string", {
  fg = "#98c379",
})

-- docstrings (dark green)
set(0, "@string.documentation", {
  fg = "#6a9955",
})
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local set = vim.api.nvim_set_hl

    local black_and_white = {
      fg = "#000000",
      bg = "#ffffff",
    }
    -- set(0, "@lsp.type.selfParameter.python", { fg = "#b48ead" })
    -- set(0, "@lsp.typemod.function.definition.python", { fg = "#81a1c1" })
    -- set(0, "@lsp.type.function.python", { fg = "NONE" })
    -- set(0, "@function.builtin.python", { fg = "#5e81ac" })
    -- set(0, "@property", { fg = "#c97a3d" })
    -- set(0, "@string", { fg = "#98c379" })
    -- set(0, "@string.documentation", { fg = "#6a9955" })
    -- set(0, "@keyword", { fg = "#d08770" })
    -- set(0, "@keyword.return", { fg = "#d08770" })
    set(0, "@lsp.type.selfParameter.python", black_and_white)
    set(0, "@lsp.typemod.function.definition.python", black_and_white)
    set(0, "@lsp.type.function.python", black_and_white)
    set(0, "@function.builtin.python", black_and_white)
    set(0, "@property", black_and_white)
    set(0, "@string", black_and_white)
    set(0, "@string.documentation", black_and_white)
    set(0, "@keyword", black_and_white)
    set(0, "@keyword.return", black_and_white)
  end,
})

--------------- notify settings ----------------

-------------------- noice setup --------------
---require("noice").setup({
---  -- Copilot, i want to have it so that the notifcaiton history does nto get replaced by
---  -- things of the same level ,specifically for messages:
---  views = {
---    notify = {
---      replace = false,
---      opts = {
---        stop = true,
---        replace = false,
---      },
---    },
---  },
---  -- it is still replacing the history, if i Inspect twice, i only see 1 info message, not 2, even though i have replace = false, so maybe this is a bug? or maybe i am misunderstanding what replace does?
---  routes = {
---    { filter = { event = "notify", level = "info" }, opts = { replace = false, stop = true } },
---    { filter = { event = "notify", level = "debug" }, opts = { replace = false, stop = true } },
---    { filter = { event = "notify", level = "Info" }, opts = { replace = false, stop = true } },
---    { filter = { event = "notify", level = "warning" }, opts = { replace = false, stop = true } },
---    { filter = { event = "notify", level = "Warning" }, opts = { replace = false, stop = true } },
---  },
---})
