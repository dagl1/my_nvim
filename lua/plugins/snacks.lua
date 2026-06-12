return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.notifier = opts.notifier or {}

      -- notifications
      opts.notifier.timeout = 1000
      opts.notifier.enabled = true

      -- ONLY safe global picker options
      opts.picker = opts.picker or {}

      opts.picker.win = nil -- ❗ IMPORTANT: reset broken override

      opts.picker.sources = opts.picker.sources or {}

      -- explorer settings (safe ones only)
      opts.picker.sources.explorer = opts.picker.sources.explorer or {}
      opts.picker.sources.explorer.hidden = true

      opts.notifier = opts.notifier or {}
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = opts.picker.sources.explorer or {}
      opts.picker.sources.explorer.win = opts.picker.sources.explorer.win or {}
      opts.picker.sources.explorer.win.list = opts.picker.sources.explorer.win.list or {}
      opts.picker.sources.explorer.win.list.keys = opts.picker.sources.explorer.win.list.keys or {}

      -- disable Esc safely
      opts.picker.sources.explorer.win.list.keys["<Esc>"] = false
      opts.picker.sources.explorer.hidden = true
      -- Set snacks picker for recent files to close using escape

      ---------------------------------------------------------
      -- CUSTOM TOGGLE SORT BY LAST MODIFIED
      ---------------------------------------------------------
      -- 1. Safely initialize the picker actions table
      opts.picker.actions = opts.picker.actions or {}

      -- 2. Define the toggle action
      opts.picker.actions.toggle_sort_modified = function(picker)
        picker.opts.sort = picker.opts.sort or {}
        if picker.opts.sort.fields == "buf_lastused:desc" then
          -- Revert to default tree/fuzzy score sorting
          picker.opts.sort.fields = { "score:desc", "#text", "idx" }
        else
          -- Prioritize last modified / last used metadata
          picker.opts.sort.fields = { "buf_lastused:desc", "score:desc" }
        end
        picker:find({ refresh = true }) -- Refresh the explorer view
      end

      -- 3. Map the action specifically for the explorer view (Insert & Normal modes)
      opts.picker.sources.explorer.win.list.keys["<C-s>"] = { "toggle_sort_modified", mode = { "i", "n" } }

      opts.picker.win = opts.picker.win or {}
      opts.picker.win.preview = opts.picker.win.preview or {}

      opts.picker.win.preview.wo = vim.tbl_deep_extend("force", opts.picker.win.preview.wo or {}, {
        wrap = true,
        linebreak = true,
        breakindent = true,
      })
      return opts
    end,
  },
}
