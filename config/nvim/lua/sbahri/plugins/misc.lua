return {
  {
    "jake-stewart/multicursor.nvim",
    event = "BufReadPost",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      vim.keymap.set({ "n", "x" }, "<C-A-k>", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor to line above" })
      vim.keymap.set({ "n", "x" }, "<C-A-j>", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor to line below" })
      vim.keymap.set({ "n", "x" }, "<C-A-up>", function()
        mc.lineAddCursor(-1)
      end, { desc = "Add cursor to line above" })
      vim.keymap.set({ "n", "x" }, "<C-A-down>", function()
        mc.lineAddCursor(1)
      end, { desc = "Add cursor to line below" })

      vim.keymap.set({ "n", "x" }, "<C-A-n>", function()
        mc.matchAddCursor(1)
      end, { desc = "Add cursor to next match" })
      vim.keymap.set({ "n", "x" }, "<C-A-s>", function()
        mc.matchSkipCursor(1)
      end, { desc = "Skip next match" })
      vim.keymap.set("i", "<C-A-N>", function()
        mc.matchAddCursor(-1)
      end, { desc = "Add cursor to previous match" })
      vim.keymap.set("i", "<C-A-S>", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Skip previous match" })

      vim.keymap.set("n", "<C-d>", "viw", { desc = "Select current word" })

      vim.keymap.set("x", "<C-d>", function()
        mc.addCursor("*")
      end, { desc = "Add cursor on next occurrence" })
      vim.keymap.set("x", "<C-A-d>", function()
        mc.skipCursor("*")
      end, { desc = "Skip current occurrence" })

      vim.keymap.set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle cursor" })

      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = "Navigate to previous cursor" })
        layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = "Navigate to next cursor" })

        layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor, { desc = "Delete cursor at position" })
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end, { desc = "Toggle/clear cursors" })
      end)
    end,
  },
}
