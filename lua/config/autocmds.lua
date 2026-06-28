-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.api.nvim_create_autocmd("VimEnter", {

  callback = function()
    local root = LazyVim.root()
    if root then
      vim.cmd("cd " .. root)
    end
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("persistence").load()
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "toggleterm",
  callback = function(args)
    vim.b.miniai_disable = true
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "copilot-chat",
  callback = function()
    vim.keymap.set({ "n", "i" }, "<C-c>", "<Esc>", { buffer = true })
  end,
})
-- 1. Automatically save Copilot Chat on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("CopilotChatAutoSave", { clear = true }),
  callback = function()
    -- Safely call the save command if CopilotChat is loaded
    local status, chat = pcall(require, "CopilotChat")
    if status then
      -- Saves the current session to a default 'last_session' file
      chat.save("last_session")
    end
  end,
})

-- 2. Automatically load Copilot Chat after Persistence loads a session
vim.api.nvim_create_autocmd("User", {
  pattern = "PersistenceLoadPost", -- This event fires exactly when persistence finishes loading
  group = vim.api.nvim_create_augroup("CopilotChatAutoLoad", { clear = true }),
  callback = function()
    -- Defer the execution slightly to ensure windows and layouts are settled
    vim.defer_fn(function()
      local status, chat = pcall(require, "CopilotChat")
      if status then
        -- Loads the 'last_session' we saved on exit
        chat.load("last_session")
      end
    end, 100) -- 100ms delay prevents UI layout race conditions
  end,
})
-------- give snacks notification history also highlights
---vim.api.nvim_create_autocmd("FileType", {
---  pattern = "markdown.snacks_picker_preview",
---  callback = function(ev)
---    local ns = vim.api.nvim_create_namespace("snacks_clone")
---
---    vim.api.nvim_buf_set_extmark(ev.buf, ns, 0, 0, {
---      virt_text = { { "●", "SnacksNotifierInfo" } },
---      virt_text_pos = "eol",
---    })
---  end,
---})
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "]m", function()
      local cur = vim.api.nvim_win_get_cursor(0)

      -- move one line down first so we don't re-match current position
      vim.api.nvim_win_set_cursor(0, { cur[1] + 1, 0 })

      vim.fn.search("\\v^\\s*(class|def|async def)", "W")

      vim.cmd("normal! zz")
      vim.cmd("normal! W")
      vim.cmd("normal! e")
    end, { buffer = ev.buf })

    vim.keymap.set("n", "[m", function()
      local cur = vim.api.nvim_win_get_cursor(0)

      vim.api.nvim_win_set_cursor(0, { math.max(cur[1] - 1, 1), 0 })

      vim.fn.search("\\v^\\s*(class|def|async def)", "bW")

      vim.cmd("normal! zz")
      vim.cmd("normal! W")
      vim.cmd("normal! e")
    end, { buffer = ev.buf })
  end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "trouble",
--
--   callback = function(args)
--     -- vim.wo.wrap = true
--     vim.schedule(function()
--       -- Grab the windows displaying the trouble buffer safely
--       local wins = vim.fn.win_findbuf(args.buf)
--       for _, win in ipairs(wins) do
--         if vim.api.nvim_win_is_valid(win) then
--           vim.api.nvim_win_set_option(win, "wrap", true)
--           vim.api.nvim_win_set_option(win, "linebreak", true)
--         end
--       end
--     end)
--     -- vim.wo.linebreak = true -- Prevents breaking words in half
--     -- vim.opt_local.wrap = true
--     -- vim.schedule(function()
--     --   vim.api.nvim_win_set_option(0, "winhighlight", "")
--     -- end)
--   end,
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = ruff_string_wrap_group,
  pattern = "*.py",
  callback = function()
    -- 1. Find single or double-quoted lines exceeding 88 characters (excluding docstrings)
    -- This specific Vim regex splits long string literals by injecting a backslash-break
    -- and wrapping them cleanly.
    local save_cursor = vim.fn.getpos(".")

    -- Command finds strings longer than 88 chars and inserts structural line breaks
    vim.cmd([[silent! g/\v^[^#]*['"]([^'"]){88,}/s/\v([^'"]{60,}\s)/&\n/g]])

    -- 2. Restore cursor location so your view doesn't jump
    vim.fn.setpos(".", save_cursor)

    -- 3. Trigger your standard LSP formatting/fixing
    -- (This gives the broken strings back to Ruff to add neat parentheses and alignment)
    vim.lsp.buf.format({ async = false })
  end,
})

local sniprun_md_group = vim.api.nvim_create_augroup("SniprunMarkdown", { clear = true })
local sniprun_buf = nil
local sniprun_terminal_win = nil
local left_markdown = false
--todo: add q to close terminal when leaving markdown buffer
vim.api.nvim_create_autocmd("BufEnter", {
  group = sniprun_md_group,
  callback = function()
    if not left_markdown then
      left_markdown = false
      return
    end

    local buf = vim.api.nvim_win_get_buf(0)

    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })

    if ft == "markdown" then
      return
    end

    if ft:match("^snacks_picker") then
      return
    end

    local ok = pcall(function()
      return vim.b[buf].sniprun_terminal
    end)

    if ok and vim.b[buf].sniprun_terminal then
      return
    end

    if sniprun_terminal_win and vim.api.nvim_win_is_valid(sniprun_terminal_win) then
      vim.api.nvim_win_close(sniprun_terminal_win, true)
    end
  end,
})
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*",
  group = sniprun_md_group,
  callback = function(args)
    local left_buf_ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

    if left_buf_ft == "markdown" then
      left_markdown = true
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  group = sniprun_md_group,
  callback = function()
    vim.keymap.set("n", "<leader>rb", function()
      local current_win = vim.api.nvim_get_current_win()
      local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
      local current_line = cursor_pos[1]
      local last_line = vim.api.nvim_buf_line_count(0)

      local start_line = nil
      local end_line = nil

      for i = current_line, 1, -1 do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
        if line:match("^```") then
          start_line = i
          break
        end
      end

      for i = current_line, last_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
        end_line = i
        if line:match("^```") and i ~= start_line then
          break
        end
      end

      if start_line and end_line then
        vim.api.nvim_win_set_cursor(current_win, { start_line, 0 })
        local keys = string.format("V%dG<leader>rb", end_line)
        local escape_keys = vim.api.nvim_replace_termcodes(keys, true, true, true)

        vim.api.nvim_feedkeys(escape_keys, "m", false)
      else
        vim.notify("Not inside codeblock", vim.log.levels.WARN)
      end
      vim.defer_fn(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)

          if vim.api.nvim_get_option_value("buftype", { buf = buf }) == "terminal" then
            sniprun_terminal_buf = buf
            sniprun_terminal_win = win

            vim.b[buf].sniprun_terminal = true
            break
          end
        end
      end, 100)

      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(current_win) then
          vim.api.nvim_win_set_cursor(current_win, cursor_pos)
        end
      end, 100)
    end, { buffer = true, silent = true, desc = "Trigger visual codeblock SnipRun" })
  end,
})

vim.keymap.set("n", "<leader>rt", function()
  if not sniprun_terminal_buf then
    vim.notify("No SnipRun terminal")
    return
  end

  if sniprun_terminal_win and vim.api.nvim_win_is_valid(sniprun_terminal_win) then
    vim.api.nvim_set_current_win(sniprun_terminal_win)
    return
  end

  vim.cmd("botright split")
  vim.api.nvim_win_set_buf(0, sniprun_terminal_buf)
  sniprun_terminal_win = vim.api.nvim_get_current_win()
end)
vim.keymap.set("n", "q", function()
  vim.api.nvim_win_close(0, true)
end, {
  buffer = sniprun_buf,
  desc = "Close SnipRun terminal",
})

-- fold docstrings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local only_docstrings_query = [[
      ;; Alleen module-level docstrings targeten
      (module . (expression_statement (string)) @fold)

      ;; Alleen functie docstrings targeten
      (function_definition
        body: (block . (expression_statement (string)) @fold))

      ;; Alleen klasse docstrings targeten
      (class_definition
        body: (block . (expression_statement (string)) @fold))
    ]]

    pcall(vim.treesitter.query.set, "python", "folds", only_docstrings_query)

    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

    vim.opt_local.foldlevel = 0
    vim.opt_local.foldenable = true

    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(0) then
        vim.cmd("normal! zx")
      end
    end, 50)
  end,
})
-- autofolding docstrings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- notification highlights
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.snacks_picker_preview",
  callback = function(ev)
    local bufname = vim.api.nvim_buf_get_name(ev.buf)

    if bufname:match("notifications") or bufname:match("history") then
      vim.bo[ev.buf].filetype = "snacks_notif"

      vim.wo.wrap = true
    end
  end,
})
