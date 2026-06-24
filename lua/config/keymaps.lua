-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

------------------- Autocomplete suggestion (non-copilot) ----------------------
--- Super tab is set in ~/git/my_nvim/lua/plugins/blink.lua - vim.keymap.del("i", "<Tab>")
vim.keymap.del("i", "<S-Tab>")
-------------------------------------------------------

-- Indent left and instantly exit visual mode
vim.keymap.set("v", "<", "<gv<Esc>", { desc = "Indent left and deselect", silent = true })

-- Indent right and instantly exit visual mode
vim.keymap.set("v", ">", ">gv<Esc>", { desc = "Indent right and deselect", silent = true })

---- Space behaves like b
vim.keymap.set({ "n", "v" }, "<Space>", "b", { noremap = true, silent = true })

-- Ctrl+Enter: split line at cursor, keep indentation
vim.keymap.set("i", "<C-CR>", "<C-o>o", { silent = true })

vim.keymap.set("n", "<C-CR>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local indent = line:match("^%s*") or ""
  local before = line:sub(1, col)
  local after = line:sub(col + 1)

  vim.api.nvim_set_current_line(before)
  vim.api.nvim_buf_set_lines(0, row, row, false, { indent .. after })

  vim.api.nvim_win_set_cursor(0, { row + 1, #indent })
end, { silent = true })

----------------- Buffer navigation --------------
-- Helper function to jump and conditionally move forward one word
-- in ~/git/my_nvim/lua/config/autocmds.lua
------------------------------------------------------

-- File navigation
local picker_opts_global = {
  win = {
    input = {
      keys = {
        ["<Esc>"] = { "close", mode = { "n", "i" } },
      },
    },
  },
}
local picker_opts_cwd = vim.tbl_deep_extend("force", picker_opts_global, {
  filter = { cwd = true },
})
vim.keymap.set({ "n" }, "<leader>fR", LazyVim.pick("oldfiles", picker_opts_global), { desc = "Recent" })
vim.keymap.set({ "n" }, "<leader>fr", function()
  Snacks.picker.recent(picker_opts_cwd)
end, { desc = "Recent (cwd)" })

-- Ctrl+/ toggle comment (normal + visual)
vim.keymap.set({ "n", "i" }, "<C-_>", function()
  require("Comment.api").toggle.linewise.current()
end, { silent = true })

------------- Terminal only commands --------
vim.keymap.set("t", "<>", [[<C-\><C-n>]])
vim.keymap.set("t", "<Esc", [[<C-\><C-n>]])

------------- Toggle terminal ---------------
local root_term
vim.keymap.set({ "n", "t" }, "<F4>", function()
  if not root_term then
    root_term = Snacks.terminal(nil, {
      cwd = LazyVim.root(),
    })
  else
    root_term:toggle()
  end
end)

------------ Toggleterm terminal -------------
-- See ~/git/my_nvim/lua/plugins/toggleterm.lua, set to F16 (shift + F4)

-------------------- register yank paste ---------------------------------
local visual_state = {
  mode = nil,
  viw_start = nil,
}

vim.on_key(function(key)
  if key == "v" or key == "V" or key == "\22" then
    visual_state.mode = vim.fn.visualmode()
  end
end)

vim.keymap.set("n", "viw", function()
  visual_state.viw_start = vim.api.nvim_win_get_cursor(0)
  vim.cmd("normal! viw")
end)

vim.keymap.set("x", "y", function()
  vim.cmd.normal({ args = { "y" }, bang = true })
  if visual_state.viw_start then
    pcall(vim.api.nvim_win_set_cursor, 0, visual_state.viw_start)
    visual_state.viw_start = nil
    visual_state.mode = nil
    return
  end

  if visual_state.mode == "V" then
    vim.cmd.normal({ args = { "'>" }, bang = true })
    return
  end
end)

-- Special yank
vim.keymap.set({ "v", "n" }, "Z", '"ayiwviw"0p', { desc = "Non-overriding visual paste" })
-- Protect: Copies text AND its type (line/character) from @0 into safe storage @z
vim.keymap.set("n", "<Leader>py", function()
  local target_reg = "0"
  -- Check if the system clipboard has content (safely fetches from OS)
  local system_text = vim.fn.getreg("+")
  if system_text and system_text ~= "" then
    target_reg = "+"
  end

  local text = vim.fn.getreg(target_reg)
  local regtype = vim.fn.getregtype(target_reg)

  vim.fn.setreg("z", text, regtype)
end, { desc = "Protect last yank" })

-- Restore: Overwrites EVERY possible paste register with your safe text from @z
vim.keymap.set("n", "<Leader>yp", function()
  local text = vim.fn.getreg("z")
  local regtype = vim.fn.getregtype("z")

  -- Force it back into standard Vim registers
  vim.fn.setreg("0", text, regtype)
  vim.fn.setreg('"', text, regtype)

  -- Force it into system clipboard registers (Fixes clipboard=unnamed/unnamedplus)
  vim.fn.setreg("+", text, regtype)
  vim.fn.setreg("*", text, regtype)
end, { desc = "Restore protected yank" })

-------------------------------------------------------------------------------
-- Comments
vim.keymap.set("v", "<C-_>", function()
  vim.cmd("normal gcc")
  vim.cmd("normal gv")
end, { desc = "Toggle comment" })

vim.keymap.set("n", "<C-_>", function()
  vim.cmd("normal gcc")
  vim.cmd("normal j")
end, { desc = "Toggle comment + move down" })

------------- PYTHON RUN KEYMAPS ---------------------------
local run = require("config.run")
run.load()

vim.keymap.set("n", "<leader>rf", run.run_python_file, { desc = "Run Python file" })
vim.keymap.set("n", "<leader>re", run.open_menu, { desc = "Run config menu" })
vim.keymap.set("n", "F22", run.run, { desc = "Run active config" })
vim.keymap.set("n", "<leader>ro", run.run, { desc = "Run active config" })
vim.keymap.set("n", "<leader>ra", run.prompt_add, { desc = "Add config" })

---------------------- code navigation ----------------------
-- See ~/git/my_nvim/lua/plugins/snacks.lua for gd overwrite (from declaration to references)

--------------- Tooling keymaps and functions ---------------
require("config.tooling")

--------------- Copilot -------------------------------------
-- accept ghost text with alt-r
vim.keymap.set({ "i", "n" }, "<M-r>", function()
  local copilot = require("copilot.suggestion")
  if copilot.is_visible() then
    copilot.accept()
  else
    --
  end
end, { silent = true })

-- accept next word of ghost test with alt-l
vim.keymap.set({ "i", "n", "x" }, "<M-l>", function()
  local copilot = require("copilot.suggestion")
  if copilot.is_visible() then
    copilot.accept_word()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-l>", true, false, true), "n", true)
  end
end, { silent = true })

-- next line of ghost text with ctrl + alt + l
vim.keymap.set({ "i", "n", "x" }, "<C-M-l>", function()
  local copilot = require("copilot.suggestion")
  if copilot.is_visible() then
    copilot.accept_line()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-M-l>", true, false, true), "n", true)
  end
end, { silent = true })

local function copilot_usage()
  local username = "dagl1"
  local token = os.getenv("GITHUB_TOKEN")
  if not token then
    vim.notify("Missing GITHUB_TOKEN", vim.log.levels.ERROR)
    return
  end

  local cmd = string.format(
    'curl -s -L -H "Accept: application/vnd.github+json" '
      .. '-H "Authorization: Bearer %s" '
      .. '-H "X-GitHub-Api-Version: 2026-03-10" '
      .. "https://api.github.com/users/%s/settings/billing/premium_request/usage",
    token,
    username
  )

  local result = vim.fn.system(cmd)
  local ok, data = pcall(vim.fn.json_decode, result)
  if not ok then
    vim.notify("Failed to parse GitHub response", vim.log.levels.ERROR)
    return
  end

  local items = data.usageItems or {}
  if #items == 0 then
    vim.notify("No usage data found", vim.log.levels.WARN)
    return
  end

  local total_used = 0
  local total_cost = 0
  local by_model = {}

  for _, item in ipairs(items) do
    local used = tonumber(item.netQuantity) or 0
    local cost = tonumber(item.netAmount) or 0
    total_used = total_used + used
    total_cost = total_cost + cost

    -- try to get meaningful key (productName, sku, description, fallback)
    local key = item.productName or item.sku or item.description or "unknown"
    by_model[key] = (by_model[key] or 0) + used
  end

  -- print breakdown
  print("=== Copilot usage breakdown ===")
  for k, v in pairs(by_model) do
    print(string.format("%s : %s", k, tostring(v)))
  end
  print(string.format("Total used: %s", tostring(total_used)))
  print(string.format("Total cost: $%.2f", total_cost))

  -- optional percent of budget (adjust limit)
  local limit = 300
  local pct = (total_used / limit) * 100
  vim.notify(
    string.format("Copilot usage: %s / %d (%.1f%%) | $%.2f", tostring(total_used), limit, pct, total_cost),
    vim.log.levels.INFO
  )
end

vim.keymap.set("n", "<leader>cu", copilot_usage, { desc = "Copilot usage report" })

--------------- overwrite weird leader ----------------------
vim.schedule(function()
  pcall(vim.keymap.del, "n", "<leader>r")
  pcall(vim.keymap.del, "n", "<localleader>r")
end)

------------------ buffer line /tabs ----------------------
-- move next ctrl 7 ( `]` actually)
-- move previous with ctrl 4 ( `[`)
vim.keymap.set("n", "<C-É>", ":BufferLineCyclePrev<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-Ê>", ":BufferLineCycleNext<CR>", { desc = "Previous buffer" })

----- buffer undo
require("buffer-reopen").setup({})
-- is ctrl + t
vim.keymap.set("n", "", ":BufferHistory reopen<CR>", { desc = "Reopen closed buffer" })
----------------------------------------------------

-- proper exit
vim.keymap.set({ "i", "v" }, "<C-c>", "<Esc>", { desc = "Exit insert mode" })

-- Json format
vim.keymap.set("n", "<leader>jf", function()
  vim.cmd("%!jq .")
end, { desc = "Format JSON" })

-- snacks.picker.lsp_references() is a better version of vim.lsp.buf.references() that uses Snacks picker
-- lsp search references
-- vim.keymap.set("n", "gd", function()
--   sn
-- end, { desc = "LSP references" })

require("config.after_lazy")
