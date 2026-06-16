vim.keymap.set("n", "<leader>ip", function()
  vim.cmd("write")

  local file = vim.fn.expand("%:p")

  -- Escape the file path for safety in the shell string
  local escaped_file = vim.fn.shellescape(file)

  vim.system({
    "sh",
    "-c",
    string.format("uv run ruff format %s && uv run ruff check --fix %s", escaped_file, escaped_file),
  }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        -- Show stderr if available, otherwise fallback to stdout hint
        local err_msg = (obj.stderr and obj.stderr ~= "") and obj.stderr or obj.stdout
        vim.notify(err_msg, vim.log.levels.ERROR)
        return
      end

      -- Reload buffer from disk
      vim.cmd("checktime")
      vim.notify("Formatted and fixed with Ruff", vim.log.levels.INFO)
    end)
  end)
end, { desc = "Ruff format & fix (uv)" })
