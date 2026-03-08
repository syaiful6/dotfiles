return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = false,
      },
      panel = {
        enabled = false,
      },
      filetypes = {
        yaml = true,
        markdown = true,
        help = false,
        gitcommit = true,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      vim.lsp.enable("copilot")
    end,
  },
  {
    "giuxtaposition/blink-cmp-copilot",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
  },
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        tools = {
          pi = {
            cmd = { "pi" },
          }
        }
      }
    },
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").toggle() end,
        desc = "Toggle Sidekick",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Toggle Sidekick",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        desc = "Select CLI",
      },
    }
  },
}
