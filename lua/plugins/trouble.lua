return {
  {
    "folke/trouble.nvim",
    opts = {
      win = {
        type = "split",
        relative = "win",
        position = "right",
        size = 0.36,
        wo = {
          wrap = true,
          linebreak = true,
        },
      },

      modes = {
        diagnostics = {
          filter = function(items)
            local rustc_errors = {}

            -- Collect Rust compiler diagnostics.
            for _, item in ipairs(items) do
              if item.source == "rustc" then
                local key = table.concat({
                  item.filename or "",
                  item.pos and item.pos[1] or 0,
                  item.pos and item.pos[2] or 0,
                  item.code or "",
                }, ":")

                rustc_errors[key] = true
              end
            end

            -- Hide matching rust-analyzer diagnostics only.
            return vim.tbl_filter(function(item)
              if item.source ~= "rust-analyzer" then
                return true
              end

              local key = table.concat({
                item.filename or "",
                item.pos and item.pos[1] or 0,
                item.pos and item.pos[2] or 0,
                item.code or "",
              }, ":")

              return not rustc_errors[key]
            end, items)
          end,
        },
      },
    },
  },
}
