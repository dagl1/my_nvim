return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")

      require("dapui").setup({})
      require("nvim-dap-virtual-text").setup({
        enabled_commands = true,
        highlight_changed_variables = true, -- Highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = true, -- Highlight new variables in the same way as changed variables
        show_stop_reason = true, -- Show stop reason when stopped for exceptions
        commented = false,
        all_references = false,
        virt_text_pos = "inline",
        -- virt_text_pos = "eol", -- Position of virtual text, can be 'eol' or 'inline'
        -- - A callback that determines how a variable is displayed or whether it should be omitted
        --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
        --- @param buf number
        --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
        --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
        --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
        --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
        display_callback = function(variable, buf, stackframe, node, options)
          -- by default, strip out new line characters
          local max_len = 100
          if options.virt_text_pos == "inline" then
            local total_text = " = " .. variable.value:gsub("%s+", " ")
            if #total_text > max_len then
              return total_text:sub(1, max_len) .. "..."
            end

            return total_text
          else
            local total_text = variable.name .. " = " .. variable.value:gsub("%s+", " ")
            if #total_text > max_len then
              return total_text:sub(1, max_len) .. "..."
            end

            return total_text
          end
        end,
      })

      dap_python.setup("uv")

      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapBreakpointRejected", {
        text = "", -- or "❌"
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })

      vim.fn.sign_define("DapStopped", {
        text = "", -- or "→"
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      local opts = { noremap = true, silent = true }

      -- Toggle breakpoint
      vim.keymap.set("n", "<leader>db", function()
        dap.toggle_breakpoint()
      end, { desc = "Toggle Breakpoint", noremap = true, silent = true })

      -- Continue / Start
      vim.keymap.set("n", "<leader>dc", function()
        dap.continue()
      end, { desc = "Continue / Start", noremap = true, silent = true })

      -- Step Over
      vim.keymap.set("n", "<leader>do", function()
        dap.step_over()
      end, { desc = "Step Over", noremap = true, silent = true })

      -- Step Into
      vim.keymap.set("n", "<leader>di", function()
        dap.step_into()
      end, { desc = "Step Into", noremap = true, silent = true })

      -- Step Out
      vim.keymap.set("n", "<leader>dO", function()
        dap.step_out()
      end, {
        desc = "Step Out",
        noremap = true,
        silent = true,
      })

      -- Keymap to terminate debugging
      vim.keymap.set("n", "<leader>dq", function()
        require("dap").terminate()
      end, { desc = "Terminate Debugging", noremap = true, silent = true })

      -- Toggle DAP UI
      vim.keymap.set("n", "<leader>du", function()
        dapui.toggle()
      end, { desc = "Toggle DAP UI", noremap = true, silent = true })

      -- Keymap to resize/reset DAP UI windows
      vim.keymap.set("n", "<leader>dr", function()
        dapui.close()
        dapui.open({ reset = true })
      end, { desc = "Resize/Reset DAP UI Windows", noremap = true, silent = true })
    end,
  },
}
