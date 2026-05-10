return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      bigfile = {
        enabled = true,
        max_size = 2 * 1024 * 1024,
      },
      indent = { enabled = true },
      image = { enabled = true },
      terminal = {
        enabled = true,
        shell = { "/bin/zsh", "-i" },
      },
      picker = {
        prompt = "🍿 ",
        layout = { preset = "telescope" },
        hidden = true,
        file = true,
        current = true,
        matcher = {
          fuzzy = true,
          frecency = true,
          filename_bonus = false,
        },
      },
      notifier = {},
    },
    keys = {
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch buffer"
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch buffer"
      },
      {
        "fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Pick buffer"
      },
      {
        "<leader>n",
        function()
          vim.cmd("messages")
        end,
        desc = "Message history"
      },
      {
        "<C-`>",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle terminal"
      }
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
      }
    },
    config = function(_, opts)
      vim.opt.termguicolors = true
      require("bufferline").setup(opts)
    end,
  },
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<D-b>", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      outline_window = {
        position = "left",
        width = 35,
        auto_close = false,
        focus_on_open = false,
        relative_width = false,
        no_provider_message = "",
      },
    },
    config = function(_, opts)
      require("outline").setup(opts)
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local function count_normal_windows()
            local count = 0
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local config = vim.api.nvim_win_get_config(win)
              if config.relative == "" then -- Non-floating windows
                count = count + 1
              end
            end
            return count
          end

          if vim.bo.filetype == "Outline" and count_normal_windows() == 1 then
            vim.cmd "q"
          end
        end,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)"
      }
    }
  },
}
