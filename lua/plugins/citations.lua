return  {
    {
        "jalvesaq/zotcite",
        branch = "pynvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        },
        config = function ()
            require("zotcite").setup({
                -- SQL_path = 'C:/Users/P70088775/Zotero/zotero.sqlite',
                SQL_path = "C:/Users/PCJelle/Zotero/zotero.sqlite",
                lsp_completion = true,
                -- sqlite_path = "C:/Tools/sqlite/sqlite3.exe",
            }) 
            require('cmp').setup ({
              sources = {
                { name = 'zotcite' },
                { name = 'nvim_lsp' },
                { name = 'buffer' },
                { name = 'path' },
              }
          })
        end
    },
}
