-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>bs", function()
  require("sbahri.history").start_listening()
end, { desc = "Start listening to buffer changes" })
vim.keymap.set("n", "<leader>bS", function()
  require("sbahri.history").stop_listening()
end, { desc = "Stop listening to buffer changes" })
vim.keymap.set("n", "<leader>bC", function()
  require("sbahri.history").clear_history()
end, { desc = "Clear buffer change history" })
vim.keymap.set("n", "<leader>bD", function()
  local patch = require("sbahri.history").get_patch()
  if not patch then
    vim.print("No history changes available for the current buffer.")
    return
  end
  vim.schedule(function()
    vim.cmd("new")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(patch, "\n"))
    vim.bo[buf].filetype = "diff"
  end)
end, { desc = "Show buffer change patch" })
