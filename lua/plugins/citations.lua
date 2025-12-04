return  {
    {
        "jalvesaq/zotcite",
        branch = "pynvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
        },
        config = function ()
            local paths = {
                "C:/Users/P70088775/Zotero/zotero.sqlite",
                "C:/Users/PCJelle/Zotero/zotero.sqlite"
            }

            -- Find the first existing path
            local sql_path
            for _, p in ipairs(paths) do
                if vim.loop.fs_stat(p) then
                    sql_path = p
                    break
                end
            end

            if not sql_path then
                vim.notify("Zotero database not found!", vim.log.levels.ERROR)
                return
            end

            -- Setup ZotCite
            require("zotcite").setup({
                SQL_path = sql_path,
                lsp_completion = true,
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
