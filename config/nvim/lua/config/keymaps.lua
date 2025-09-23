-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- File type specific search keybindings
vim.keymap.set("n", "<leader>stc", function()
  require("telescope.builtin").live_grep({
    glob_pattern = "*.{css,scss,sass,less}",
    prompt_title = "Search CSS/SCSS",
  })
end, { desc = "Search CSS/SCSS files" })

vim.keymap.set("n", "<leader>stj", function()
  require("telescope.builtin").live_grep({
    glob_pattern = "*.{js,ts,jsx,tsx,vue,svelte}",
    prompt_title = "Search JS/TS",
  })
end, { desc = "Search JavaScript/TypeScript files" })

vim.keymap.set("n", "<leader>str", function()
  require("telescope.builtin").live_grep({
    glob_pattern = "*.rs",
    prompt_title = "Search Rust",
  })
end, { desc = "Search Rust files" })

vim.keymap.set("n", "<leader>sto", function()
  require("telescope.builtin").live_grep({
    glob_pattern = "*.{ml,mli,re,rei}",
    prompt_title = "Search OCaml/Reason",
  })
end, { desc = "Search OCaml/Reason files" })

vim.keymap.set("n", "<leader>stw", function()
  require("telescope.builtin").live_grep({
    glob_pattern = "*.{python,php,html}",
    prompt_title = "Search Web files",
  })
end, { desc = "Search Web files" })
