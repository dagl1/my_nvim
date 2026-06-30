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
set(0, "@lsp.typemod.method.definition.python", {})

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
set(0, "DiagnosticUnnecessary", colors.comment_color)

-- BUILTINS (dark blue)
set(0, "@function.builtin.python", colors.built_in_blue)
set(0, "@lsp.type.builtin.python", colors.built_in_blue)

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
set(0, "@attribute.python", colors.yellow)

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
set(0, "@constant.builtin.python", colors.dark_orange)
set(0, "@string.escape", colors.dark_orange)

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

-- deduplicate trouble; ruff/ty erros

-- Save the original Neovim diagnostic publisher
local raw_diagnostic_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  -- If there are no diagnostics, pass it through normally
  if not result or not result.diagnostics then
    return raw_diagnostic_handler(err, result, ctx, config)
  end

  local seen = {}
  local filtered_diagnostics = {}

  for _, diagnostic in ipairs(result.diagnostics) do
    -- Create a fingerprint using: line, start column, end column, and error message text
    local fingerprint = string.format(
      "%d:%d:%d:%s",
      diagnostic.range.start.line,
      diagnostic.range.start.character,
      diagnostic.range["end"].character,
      diagnostic.message
    )

    -- Only keep the diagnostic if we haven't already processed an identical one
    if not seen[fingerprint] then
      seen[fingerprint] = true
      table.insert(filtered_diagnostics, diagnostic)
    end
  end

  -- Replace the raw list with our clean, unique list
  result.diagnostics = filtered_diagnostics

  -- Pass the unique errors to Neovim / Trouble.nvim
  raw_diagnostic_handler(err, result, ctx, config)
end
