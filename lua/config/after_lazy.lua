require("scrollEOF").setup()

require("config.colors_after")

--------------- Notify/Noice settings ----------------
-- Deduplicate trouble; ruff/ty erros
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
