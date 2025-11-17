return  {
    {
        "jalvesaq/zotcite",
        branch = "no_pynvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        },
        config = function ()
            require("zotcite").setup({
                SQL_path = 'C:/Users/P70088775/Zotero/zotero.sqlite',
                sqlite_path = "C:/Tools/sqlite/sqlite3.exe",
            })
        end
    },
}
