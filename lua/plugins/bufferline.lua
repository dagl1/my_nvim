return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      seperator_style = "thin",
      always_show_bufferline = true,
      name_formatter = function(buf)
        -- Get the full path of the buffer
        local path = vim.api.nvim_buf_get_name(buf.bufnr)
        if path == "" then
          return buf.name
        end

        -- Extract the parent folder name
        local parent = vim.fn.fnamemodify(path, ":p:h:t")

        -- Return "parent_folder/file_name"
        if parent and parent ~= "" then
          return parent .. "/" .. buf.name
        end
        return buf.name
      end,
    },
  },
}
