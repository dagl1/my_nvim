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
    local save_cursor = vim.fn.getpos(".")
    local bufnr = vim.api.nvim_get_current_buf()

    local max_len = vim.bo[bufnr].textwidth
    if max_len == 0 then
      local cc = vim.wo.colorcolumn
      max_len = tonumber(cc:match("(%d+)")) or 88
    end

    local split_target = max_len - 20
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local changed = false

    for i = #lines, 1, -1 do
      local line = lines[i]

      if not line:match("^%s*#") and #line > max_len then
        local start_idx, end_idx, prefix, quote = line:find("([fF]?)([\"'])")

        if start_idx then
          local rest_of_line = line:sub(end_idx + 1)
          -- CONTROLE: Check of de string sluit vóór het einde van de regel
          local is_closed = rest_of_line:match("^.-" .. quote)

          if not is_closed then
            local leading = line:sub(1, start_idx - 1)
            local content = rest_of_line

            if #content > 30 then
              local split_pos = content:sub(1, split_target):match(".*%s()")
              if split_pos then
                local part1 = content:sub(1, split_pos - 1)
                local part2 = content:sub(split_pos)

                lines[i] = leading .. prefix .. quote .. part1 .. quote
                local indent = line:match("^%s*") or ""
                local next_line = indent .. "    " .. prefix .. quote .. part2

                table.insert(lines, i + 1, next_line)
                changed = true
              end
            end
          end
        end
      end
    end

    if changed then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.fn.setpos(".", save_cursor)
    end
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
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sniprun_terminal", -- Controleer of jouw SnipRun-bestandstype zo heet (vaak 'sniprun_terminal')
  callback = function(args)
    vim.keymap.set("n", "q", function()
      vim.api.nvim_win_close(0, true)
    end, {
      buffer = args.buf,
      desc = "Close SnipRun terminal",
      silent = true,
    })
  end,
})

----------------------- Folding ----
-- Fold docstrings
_G.python_custom_foldexpr = function()
  local line_num = vim.v.lnum
  local line_text = vim.fn.getline(line_num)

  -- Check eerst op handmatige markers in de code
  if line_text:match("{{{") then
    return "a1"
  elseif line_text:match("}}}") then
    return "s1"
  end

  -- Val daarna pas terug op de docstrings query
  return vim.treesitter.foldexpr()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    local only_docstrings_query = [[
      (module . (expression_statement (string)) @fold)
      (function_definition body: (block . (expression_statement (string)) @fold))
      (class_definition body: (block . (expression_statement (string)) @fold))
    ]]
    pcall(vim.treesitter.query.set, "python", "folds", only_docstrings_query)

    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.python_custom_foldexpr()"

    vim.opt_local.foldlevel = 0
    vim.opt_local.foldenable = true

    -- ========================================================
    -- VOEG DIT TOE: Handmatige folds maken met 'zf' in Python
    -- ========================================================
    -- In Visual Mode: Selecteer tekst en druk op 'zf' om er markers omheen te zetten
    vim.keymap.set("v", "zf", function()
      -- Haal de begin- en eindregels van de visuele selectie op
      local start_line = vim.fn.line("v")
      local end_line = vim.fn.line(".")
      if start_line > end_line then
        start_line, end_line = end_line, start_line
      end

      -- Voeg de sluitende marker toe onderaan (eerst onderaan om regelnummers niet te verschuiven)
      vim.fn.append(end_line, "# }}}")
      -- Voeg de openende marker toe bovenaan
      vim.fn.append(start_line - 1, "# {{{")

      -- Forceer Neovim om de vouwen direct opnieuw te berekenen
      vim.cmd("normal! zx")
    end, { buffer = true, desc = "Create manual fold marker" })

    -- ========================================================

    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(0) then
        vim.cmd("normal! zx")
      end
    end, 50)
  end,
})

------------ Notifications
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
-- Create an augroup to manage our custom jump list tracking
local jump_track_group = vim.api.nvim_create_augroup("InsertJumpTracker", { clear = true })

-- 1. Track position right BEFORE entering Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  group = jump_track_group,
  callback = function()
    -- Mark the current location in the jump list
    vim.cmd("normal! m`")
  end,
})

-- 2. Track position right BEFORE leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = jump_track_group,
  callback = function()
    -- Mark the location where you finished typing
    vim.cmd("normal! m`")
  end,
})

local ns_id = vim.api.nvim_create_namespace("InlineLspReferences")

local function update_buffer_references()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    return
  end

  -- Clear all previous counts across the entire buffer
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Get every line in the file
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local doc_uri = vim.uri_from_bufnr(bufnr)

  for idx, line_text in ipairs(lines) do
    local actual_line_num = idx - 1

    -- Match lines containing a python definition
    if line_text:match("%f[%w]def%s") or line_text:match("%f[%w]class%s") then
      local _, keyword_end = line_text:find("%f[%w]def%s")
      if not keyword_end then
        _, keyword_end = line_text:find("%f[%w]class%s")
      end

      -- If we successfully found the start of the function/class identifier name
      if keyword_end then
        -- Lua strings are 1-indexed, Neovim LSP characters are 0-indexed
        local name_col = keyword_end

        -- Structure the parameter payload exactly how ty expects it
        local params = {
          textDocument = { uri = doc_uri },
          position = { line = actual_line_num, character = name_col },
          context = { includeDeclaration = false },
        }

        -- Fire the request to the active client
        vim.lsp.buf_request(bufnr, "textDocument/references", params, function(err, result, ctx, _)
          if err or not result or #result == 0 then
            return
          end

          -- Double check that the line still exists and hasn't been edited mid-request
          if vim.api.nvim_buf_is_valid(bufnr) then
            local current_text = vim.api.nvim_buf_get_lines(bufnr, actual_line_num, actual_line_num + 1, false)[1] or ""
            if not (current_text:match("%f[%w]def%s") or current_text:match("%f[%w]class%s")) then
              return
            end

            local count = #result
            if count > 1 then
              text = string.format("     %d usages", count)
            elseif count == 1 then
              text = "     1 usage"
            end
            vim.api.nvim_buf_set_extmark(bufnr, ns_id, actual_line_num, 0, {
              virt_text = { { text, "Comment" } },
              virt_text_pos = "eol",
            })
          end
        end)
      end
    end
  end
end

-- Automate tracking when saving the file or holding the cursor still
vim.api.nvim_create_autocmd({ "CursorHold", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("LspBufferReferences", { clear = true }),
  pattern = "*.py",
  callback = function()
    update_buffer_references()
  end,
})
