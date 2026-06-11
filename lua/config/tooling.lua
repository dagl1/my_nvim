vim.keymap.set("n", "<leader>ip", function()
  vim.cmd("write")

  local file = vim.fn.expand("%:p")

  vim.system({
    "uv",
    "run",
    "ruff",
    "format",
    file,
  }, { text = true }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        vim.notify(obj.stderr, vim.log.levels.ERROR)
        return
      end

      -- 🔥 reload buffer from disk
      vim.cmd("checktime")

      vim.notify("Formatted with ruff", vim.log.levels.INFO)
    end)
  end)
end, { desc = "Ruff format (uv)" })
