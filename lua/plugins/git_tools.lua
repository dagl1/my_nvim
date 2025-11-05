return {
    {"tpope/vim-fugitive", },
    {
      'tanvirtin/vgit.nvim',
      dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
      -- Lazy loading on 'VimEnter' event is necessary.
      event = 'VimEnter',
      config = function() require("vgit").setup() end,
      settings = {
        live_gutter = {
          toggle_live_gutter = false,  -- disable live gutter on startup
        },
    }
    
}
