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
local colors = {
  regular_color = { fg = "#C9D1D9" }, -- brighter gray (was #A9B7C6)
  comment_color = { fg = "#6A737D" }, -- more visible gray for comments
  text_green = { fg = "#6FC276" }, -- more visible green
  string_green = { fg = "#7FAF6A" }, -- slightly brighter, clearer
  dark_orange = { fg = "#E08A3A" }, -- stronger orange (was #CC7832)
  yellow = { fg = "#D4C24A" }, -- brighter yellow
  number_blue = { fg = "#7FB2E5" }, -- clearer blue
  built_in_blue = { fg = "#9AA4E8" }, -- stronger indigo-blue
  invalid_escape_effect_orange = {
    fg = "#E08A3A",
    bg = "none",
    undercurl = true,
    sp = "#E08A3A",
  },
  method_declaration = { fg = "#FFD08A" }, -- slightly brighter peach
  self_purple = { fg = "#B18BC7" }, -- more readable purple
  magic_method_purple = { fg = "#C85CFF" }, -- stronger magenta
  constant_color = { fg = "#B39DDB" }, -- more readable lavender
  keyword_color = { fg = "#D16A4A" }, -- stronger keyword contrast
  tag_color = { fg = "#B07A4A" }, -- slightly brighter brown-orange
}
-- local colors = {
--   -- regular color = gray
--   regular_color = { fg = "#A9B7C6" },
--   -- regular_color = { fg = "#FFF999" },
--   text_green = { fg = "#629755" },
--   string_green = { fg = "#6A8759" },
--   dark_orange = { fg = "#CC7832" },
--   yellow = { fg = "#BBB529" },
--   number_blue = { fg = "#6897BB" },
--   built_in_blue = { fg = "#8888C6" },
--   invalid_escape_effect_orange = {
--     fg = "#CC7832",
--     bg = "none",
--     special = "#",
--     sp = "#CC7832",
--     undercurl = true,
--   },
--   method_declaration = { fg = "#FFC66D" },
--   self_purple = { fg = "#94668d" },
--   magic_method_purple = { fg = "#B200B2" },
--   constant_color = { fg = "#9876AA" },
--   keyword_color = { fg = "#AA4926" },
--   tag_color = { fg = "#8A653B" },
-- }
-- set all colors to regular first, then override specific ones, so that if there are any missing highlights, they will at least be the regular color instead of default

----------------- IMPORTANT------------------------
-- Contains additional treesitter logic in ~/git/my_nvim/after/queries/python/highlights.scm
---------------------------------------------------
vim.api.nvim_set_hl(0, "@lsp.type.function.python", {})

-- - @lsp.type.parameter.python links to @variable.parameter   priority: 125
-- - @lsp.type.method.python links to Function   priority: 125
set(0, "@lsp.type.method.python", {})
set(0, "@lsp.type.property.python", {})
set(0, "@lsp.type.variable.python", {})
set(0, "@lsp.type.class.python", {})
set(0, "@lsp.type.parameter.python", {})
set(0, "@constructor.python", {})
set(0, "@lsp.type.string.python", {})
set(0, "@lsp.mod.documentation.python", {})
set(0, "@lsp.typemod.string.documentation.python", {})
-- FUNCTION CALLS (NO COLOR)
set(0, "@function.call", colors.regular_color)
set(0, "@variable.member", colors.regular_color)
set(0, "@variable", colors.regular_color)
set(0, "@variable.parameter", colors.regular_color)
set(0, "@operator.python", colors.regular_color)
set(0, "@function.method.call.python", colors.regular_color)
set(0, "@type", colors.regular_color)

set(0, "@lsp.typemod.function.definition", colors.regular_color)
-- set(0, "@lsp.type.function", colors.regular_color)
-- set(0, "@lsp.type.variable", colors.regular_color)
-- set(0, "@lsp.type.property", colors.regular_color)
-- set(0, "@lsp.type.method", colors.regular_color)
-- set(0, "@lsp.type.parameter", colors.regular_color)
-- set(0, "@lsp.type.class", colors.regular_color)
set(0, "@punctuation.delimiter.period", colors.regular_color)
set(0, "@punctuation.colon", colors.regular_color)
set(0, "@punctuation.delimiter.equals", colors.regular_color)
set(0, "@constant.python", colors.regular_color)

-- Comments
set(0, "@comment", colors.comment_color)

-- BUILTINS (dark blue)
set(0, "@function.builtin.python", colors.built_in_blue)
set(0, "@lsp.type.builtin.python", colors.built_in_blue)
set(0, "@constant.builtin.python", colors.dark_orange)

-- method definition/declaration
set(0, "@lsp.typemod.method.definition", colors.method_declaration)

-- number
-- set(0, "@lsp.type.number", colors.number_blue)
set(0, "@number", colors.number_blue)

-- string
set(0, "@string", colors.string_green)

-- docstrings (dark green)
set(0, "@string.documentation", colors.text_green)

-- decorators (yellow)
set(0, "@decorator", colors.yellow)
set(0, "@lsp.type.decorator.python", colors.yellow)
set(0, "@punctuation.delimiter.at", colors.yellow)

-- KEYWORDS (orange)
set(0, "@keyword", colors.dark_orange)
set(0, "@keyword.return", colors.dark_orange)
set(0, "@keyword.operator", colors.dark_orange)
set(0, "@keyword.conditional", colors.dark_orange)
set(0, "@keyword.repeat", colors.dark_orange)
set(0, "@keyword.function", colors.dark_orange)
set(0, "@keyword.import.python", colors.dark_orange)
set(0, "@keyword.from.python", colors.dark_orange)
set(0, "@keyword.as.python", colors.dark_orange)
set(0, "@keyword.exception.python", colors.dark_orange)
set(0, "@punctuation.comma.python", colors.dark_orange)
set(0, "@punctuation.semicomma.python", colors.dark_orange)
set(0, "@punctuation.special.python", colors.dark_orange)

-- Self parameter (purple)
set(0, "@lsp.type.selfParameter.python", colors.self_purple)
set(0, "@lsp.type.clsParameter.python", colors.self_purple)

-- Magic methods (purple)
set(0, "@variable.dunder.python", colors.magic_method_purple)

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
