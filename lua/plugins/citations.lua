return {
  "jalvesaq/zotcite",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
  },

  build = function(plugin)
    local patch = vim.fn.stdpath("config") .. "/patches/zotcite-lsp.patch"

    if vim.fn.filereadable(patch) == 0 then
      return
    end

    -- Check whether the patch can be applied.
    local check = vim.fn.system({
      "git",
      "-C",
      plugin.dir,
      "apply",
      "--check",
      patch,
    })

    if vim.v.shell_error == 0 then
      local result = vim.fn.system({
        "git",
        "-C",
        plugin.dir,
        "apply",
        patch,
      })

      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to apply Zotcite patch:\n" .. result, vim.log.levels.ERROR)
      end

      return
    end

    -- If it cannot be applied normally, check whether it is
    -- already applied.
    local reverse = vim.fn.system({
      "git",
      "-C",
      plugin.dir,
      "apply",
      "--reverse",
      "--check",
      patch,
    })

    if vim.v.shell_error == 0 then
      return -- already patched
    end

    vim.notify("Zotcite patch could not be applied:\n" .. check, vim.log.levels.ERROR)
  end,

  config = function()
    require("zotcite").setup({
      filetypes = {
        "markdown",
        "pandoc",
        "rmd",
        "quarto",
        "vimwiki",
        "tex",
      },
      key_type = "better-bibtex",
    })
  end,
}
