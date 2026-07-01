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

-- Folds
_G.fixed_width_foldtext = function()
  local fs = vim.v.foldstart
  local fe = vim.v.foldend
  local num_lines = fe - fs + 1
  local line_text = vim.fn.getline(fs)

  local fold_info = string.format("    %d lines ", num_lines)
  local main_text = line_text .. fold_info

  local display_width = vim.fn.strdisplaywidth(main_text)
  local target_width = 94

  local padding = target_width - display_width
  if padding > 0 then
    main_text = main_text .. string.rep(" ", padding)
  else
    main_text = vim.fn.strcharpart(main_text, 0, target_width)
  end

  return main_text
end

-- 2. Activeer de nieuwe foldtext wereldwijd
vim.opt.foldtext = "v:lua.fixed_width_foldtext()"

-- 3. Zorg dat de opvultekens (fillchars) buiten kolom 94 GEEN achtergrondkleur krijgen
vim.opt.fillchars:append({ fold = " " })
vim.api.nvim_set_hl(0, "Folded", { bg = "#190909" }) -- 85% opacity
