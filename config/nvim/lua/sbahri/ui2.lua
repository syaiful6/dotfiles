local M = {}

local function setup_ui2(enable, opts)
  opts = opts or {}
  require("vim._core.ui2").enable({
    enable = enable,
    msg = {
      target = "cmd",
    },
  })

  vim.g.ui2_enabled = enable and 1 or 0
  if not opts.silent then
    vim.notify("UI2 " .. (enable and "enabled" or "disabled"), vim.log.levels.INFO, { title = "UI" })
  end
end

function M.setup()
  if vim.g.ui2_enabled == nil then
    vim.g.ui2_enabled = 1
  end

  setup_ui2(vim.g.ui2_enabled == 1, { silent = true })

  if vim.g.ui2_commands_ready == 1 then
    return
  end

  vim.g.ui2_commands_ready = 1

  vim.api.nvim_create_user_command("Ui2Enable", function()
    setup_ui2(true)
  end, { desc = "Enable Neovim ui2" })

  vim.api.nvim_create_user_command("Ui2Disable", function()
    setup_ui2(false)
  end, { desc = "Disable Neovim ui2" })

  vim.api.nvim_create_user_command("Ui2Toggle", function()
    setup_ui2(vim.g.ui2_enabled ~= 1)
  end, { desc = "Toggle Neovim ui2" })
end

return M
