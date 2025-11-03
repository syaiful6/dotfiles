-- Core keymaps for lightweight config
vim.g.mapleader = " "
-- vim.g.maplocalleader = " "

local keymap = vim.keymap

-- General keymaps
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Buffer navigation
keymap.set("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete buffer" })
keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Delete other buffers" })
keymap.set("n", "<leader>bD", "<cmd>bd<CR>", { desc = "Delete buffer and window" })

-- Move lines
keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better indenting
keymap.set("v", "<", "<gv", { desc = "Indent left" })
keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Paste without yanking
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Quickfix navigation
keymap.set("n", "<leader>xq", "<cmd>copen<CR>", { desc = "Open quickfix list" })
keymap.set("n", "<leader>xQ", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })

-- Diagnostic keymaps
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Show diagnostic error" })
keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- Terminal
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })

-- Toggle terminal
local term_buf = nil
local term_win = nil

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    term_win = nil
    return
  end

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.cmd.split()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 12)
    vim.wo.winfixheight = true
    vim.api.nvim_win_set_buf(0, term_buf)
    term_win = vim.api.nvim_get_current_win()
  else
    vim.cmd.split()
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 12)
    vim.wo.winfixheight = true
    vim.cmd.term()
    term_buf = vim.api.nvim_get_current_buf()
    term_win = vim.api.nvim_get_current_win()
  end
end

vim.keymap.set("n", "<C-`>", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<C-`>", toggle_terminal, { desc = "Toggle terminal" })
