return {
  "Aasim-A/scrollEOF.nvim",
  event = { "CursorMoved", "CursorMovedI" },
  config = function()
    require("scrollEOF").setup({
      -- This ensures it uses your global scrolloff setting to calculate the center
      disabled_filetypes = { "NvimTree", "neo-tree", "lazy", "mason" },
    })
  end,
}
