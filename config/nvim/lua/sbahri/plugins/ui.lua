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
      terminal = {},
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
        "<leader>n",
        function()
          if Snacks.config.picker and Snacks.config.picker.enabled then
            Snacks.picker.notifications()
          else
            Snacks.notifier.show_history()
          end
        end,
        desc = "Notification history",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss all notifications",
      }
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      local function find_files()
        require("snacks.picker").files({
          prompt = "🍿 ",
          wrap = true,
          find_command = { "rg", "--files", "--no-require-git" },
        })
      end

      local function find_recent_files()
        require("snacks.picker").smart({
          multi = { "files" },
          format = "file",
          prompt = "🍿 ",
          wrap = true,
          matcher = {
            fuzzy = true,
            filename_bonus = false,
            history_bonus = false,
            sort_empty = true,
            frecency = false,
          },
          keys = {
            "<leader>q",
            require("snacks.picker").qflist,
            desc = "Add to quickfix list",
          },
          filter = { cwd = true },
        })
      end

      local function live_grep()
        require("snacks.picker").grep({ wrap = true, live = true })
      end

      vim.keymap.set("n", "<leader>fd", require("snacks.picker").diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fb", require("snacks.picker").buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>gb", require("snacks.picker").git_branches, { desc = "Git branches" })
      vim.keymap.set("n", "<leader>sw", require("snacks.picker").grep_word, { desc = "Search word" })

      vim.keymap.set("n", "<D-p>", find_files, { desc = "Find files" })
      vim.keymap.set("n", "<D-k>", find_recent_files, { desc = "Search recent files" })
      vim.keymap.set("n", "<D-S-f>", live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>sd", require("snacks.picker").diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>sD", require("snacks.picker").diagnostics_buffer, { desc = "Buffer diagnostics" })

      local function open_file_under_cursor_in_picker()
        local target = vim.fn.expand "<cfile>"
        vim.api.nvim_command "wincmd k"

        require("snacks.picker").files {
          prompt = "🍿 ",
          default_text = target,
          wrap = true,
          find_command = { "rg", "--files", "--no-require-git" },
        }
      end

      vim.keymap.set("n", "gs", open_file_under_cursor_in_picker, { desc = "Search file name under cursor" })

      vim.keymap.set("n", "<D-f>", function()
        require("snacks.picker").lines {
          layout = {
            preset = "select",
          },
        }
      end, { desc = "Fuzzily search in current buffer" })

      vim.keymap.set("n", "<D-s-;>", require("snacks.picker").commands, { desc = "Search commands" })
      vim.keymap.set("n", "<leader>sh", require("snacks.picker").help, { desc = "Search help" })

      vim.keymap.set({ "n", "x" }, "<leader>gg", function()
        require("snacks.gitbrowse").open()
      end, { desc = "Open git link in the browser", silent = true })
    end,
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
