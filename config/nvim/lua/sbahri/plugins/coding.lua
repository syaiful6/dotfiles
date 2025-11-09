return {
  {
    "nvim-mini/mini.pairs",
    version = "*",
    event = "VeryLazy",
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "ys",            -- Add surrounding in Normal and Visual modes
        delete = "ds",         -- Delete surrounding
        find = "",             -- Find surrounding (to the right)
        find_left = "",        -- Find surrounding (to the left)
        highlight = "",        -- Highlight surrounding
        replace = "cs",        -- Replace surrounding
        update_n_lines = "",   -- Update `n_lines`
      },
    },
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "smoka7/hop.nvim",
    config = function()
      local hop = require "hop"
      local directions = require("hop.hint").HintDirection

      hop.setup {}

      vim.keymap.set("", "<leader>f", function()
        hop.hint_char2 { current_line_only = false }
      end, { remap = true, desc = "Hop 2 characters" })

      vim.keymap.set("", "f", function()
        hop.hint_char1 { direction = directions.AFTER_CURSOR, current_line_only = true }
      end, { remap = true, desc = "Hop to next character (this line)" })
      vim.keymap.set("", "F", function()
        hop.hint_char1 { direction = directions.BEFORE_CURSOR, current_line_only = true }
      end, { remap = true, desc = "Hop to previous character (this line)" })
    end,
  }
}
