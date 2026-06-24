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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "trouble",

  callback = function(args)
    -- vim.wo.wrap = true
    vim.schedule(function()
      -- Grab the windows displaying the trouble buffer safely
      local wins = vim.fn.win_findbuf(args.buf)
      for _, win in ipairs(wins) do
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_option(win, "wrap", true)
          vim.api.nvim_win_set_option(win, "linebreak", true)
        end
      end
    end)
    -- vim.wo.linebreak = true -- Prevents breaking words in half
    -- vim.opt_local.wrap = true
    -- vim.schedule(function()
    --   vim.api.nvim_win_set_option(0, "winhighlight", "")
    -- end)
  end,
})

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
