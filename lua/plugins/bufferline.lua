local FILE_NAME_ONLY = "file_name"
local PARENT_AND_FILE = "parent_folder/file_name"

local current_bufferline_name_style = FILE_NAME_ONLY

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  config = function()
    local bufferline = require("bufferline")

    local function get_options()
      return {
        options = {
          separator_style = "thin",
          always_show_bufferline = true,
          offsets = {
            {
              filetype = "snacks_layout_box",
              text = "   File Explorer",
              text_align = "left",
              separator = true,
            },
          },
          name_formatter = function(buf)
            if current_bufferline_name_style == FILE_NAME_ONLY then
              return buf.name
            end

            local path = vim.api.nvim_buf_get_name(buf.bufnr)
            if path == "" then
              return buf.name
            end

            local parent = vim.fn.fnamemodify(path, ":p:h:t")
            if parent and parent ~= "" then
              return parent .. "/" .. buf.name
            end

            return buf.name
          end,
        },
      }
    end

    bufferline.setup(get_options())

    vim.keymap.set("n", "<leader>bz", function()
      if current_bufferline_name_style == FILE_NAME_ONLY then
        current_bufferline_name_style = PARENT_AND_FILE
      else
        current_bufferline_name_style = FILE_NAME_ONLY
      end

      bufferline.setup(get_options())
      vim.cmd("redrawtabline")
    end, { desc = "Toggle bufferline name style" })
  end,
}
