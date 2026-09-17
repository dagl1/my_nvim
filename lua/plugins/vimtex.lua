return {
  "lervag/vimtex",
  lazy = false, -- Required: do not lazy-load VimTeX to keep inverse search working

  init = function()
    -- Viewer Settings
    -- vim.g.vimtex_view_method = "zathura"
    vim.g.vimtex_view_method = "general"
    vim.g.vimtex_view_general_viewer = "okular"
    vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"

    -- Compiler Backend
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      backend = "nvim",
      build_dir = ".build",
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }

    vim.g.vimtex_compiler_latexrun = {
      build_dir = ".build",
      options = {
        "-O",
        ".build",
      },
    }
  end,
}
